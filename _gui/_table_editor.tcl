#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD: June 27 2013
# ... removed white background rectangles from all buttons using " -highlightbackground [option get . background {}]"
# ... removed width specs from most widget text labels - need to ensure all text readable.
# ...  I think a width value is only needed for dynamic widgets where the title will change.
# ... added call to update idletasks towards end of TableEditor proc,
# ... so text boxes are activated as expected when the window launches.
# ... Tap Time dialog: removed fixed width for "Tap time here" button


#################
# TABLE EDITOR	#
#################

proc TableEditor {} {
	global pr_te pr_mu incolget col_ungapd_numeric tedit_message threshtype threshold colpar evv
	global col_skiplines eflag eflag2 col_tabname coltype wl pa tot_inlines chf tcop col_infnam
	global c_incols c_inlines col_infilelist inlines outlines tot_outlines outcolcnt
	global savestyle incols tabedit_bindcmd tabedit_bind2 tabedit_ns io oi trst okz tls tet brk_stat seq_stat
	global colinmode freetext tround ttround p_pg lmo insitu orig_inlines orig_incolget
	global ttrecyc ttclear sysname nu_names oio pr_ref env_stat rcolno tabed small_screen papag ww
	global tabed_outfile readonlyfg readonlybg otablist tab_ness columnsversion

#JUNE 2000: These prevent Double-Click hangs at TableEditor buttons
	$ww.1.a.top.tedit config -state disabled
	catch {$papag.parameters.zzz.tedit config -state disabled}

	if {[ProgMissing [file join $evv(CDPROGRAM_DIR) columns] "Cannot run the Table Editor."] \
	||	[ProgMissing [file join $evv(CDPROGRAM_DIR) getcol] "Cannot run the Table Editor."] \
	||	[ProgMissing [file join $evv(CDPROGRAM_DIR) putcol] "Cannot run the Table Editor."] \
	||	[ProgMissing [file join $evv(CDPROGRAM_DIR) vectors] "Cannot run the Table Editor."]} {
		$ww.1.a.top.tedit config -state normal
		catch {$papag.parameters.zzz.tedit config -state normal}
		return
	}
	set tab_ness 0
	catch {destroy .pmark}
	catch {destroy .cpd}
	catch {unset tabed_outfile}
	set d "disabled"
	set spacer10 "          "
	set msg $spacer10
	set n 0

    
	while {$n < 9} {
		append msg $spacer10
		incr n
	}
	append msg "TABLE EDITOR"
	if [Dlg_Create .ted $msg "set pr_te 0" -borderwidth 1] {

		if {$small_screen} {
		set can [Scrolled_Canvas .ted.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 $evv(LARGE_WIDTH) $evv(TABEDIT_HEIGHT)"]
			pack .ted.c -side top -fill x -expand true
			set f [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $f
			set tabed $f
		} else {
			set tabed .ted
		}	

		set help [frame $tabed.help -borderwidth $evv(SBDR)]
		frame $tabed.qw -height 1 -bg [option get . foreground {}]
		set gt [frame $tabed.top -borderwidth $evv(SBDR)]
		label $gt.t -text "ON COLUMN    "  -fg $evv(SPECIAL)
		pack $gt.t -side left -padx 2
		set gt2 [frame $tabed.top2 -borderwidth $evv(SBDR)]
		set gt3 [frame $tabed.top3 -borderwidth $evv(SBDR)]
		set gta [frame $tabed.topa -borderwidth $evv(SBDR)]
		frame $gta.zz -bg $evv(POINT) -width 1
		label $gta.t -text  "ON A TABLE  "  -fg $evv(SPECIAL)
		label $gta.t2 -text "SEVERAL TABLES" -fg $evv(SPECIAL)
		frame $gta.dum -bg $evv(POINT) -width 1

		label $gt.dum2 -text "GENERAL" -width 8 -fg $evv(SPECIAL)
		frame $gt.dum2a -bg $evv(POINT) -width 1
		button $gt.which -text "Which ?" -width 8 -command TEWhich -font bigfnt -highlightbackground [option get . background {}];# -bg $evv(HELP)

		frame $tabed.l2 -height 1 -bg $evv(POINT)
		frame $tabed.l2a -height 1 -bg $evv(POINT)
		frame $tabed.l1a -height 1 -bg $evv(POINT)
		set gmi [frame $tabed.mid -borderwidth $evv(SBDR)]
		frame $tabed.l3 -height 3 -bg $evv(SPECIAL)
		set gb [frame $tabed.bot -borderwidth $evv(SBDR)]
		frame $tabed.l4 -height 3 -bg $evv(SPECIAL)
		set gm [frame $tabed.message -borderwidth $evv(SBDR)]
#RWD width was 4
		button $help.hlp  -text "Help" -width 6 -command "ActivateHelp $tabed.help"  -highlightbackground [option get . background {}] ;# -bg $evv(HELP)
#RWD width was 13, messgaes now just "Active" or "Passive"
		label  $help.conn -text "" -width 8
		button $help.con  -text "" -borderwidth 0 -state $d -width 8 -highlightbackground [option get . background {}]
		label $help.help -width 72 -text "$evv(HELP_DEFAULT)" -fg [option get . foreground {}]

		button $help.tips -text "Tips" -width 9 -command "Tips ted" -highlightbackground [option get . background {}];# -bg $evv(HELP)
 	 	button $help.nns  -text "Notebook"  -width 9 -command NnnSee -highlightbackground [option get . background {}];# -bg $evv(HELP)
 		button $help.quit -text "Close" -command "set pr_mu 1 ; set pr_te 1" -highlightbackground [option get . background {}]
#RWD width was 7
		menubutton $gt.cre -text "Create"  -menu $gt.cre.create  -relief raised
#was 9
		menubutton $gt.cre2 -text "Create2"  -menu $gt.cre2.create -relief raised
#RWD width was 7
		menubutton $gt.der -text "Derive"  -menu $gt.der.derive -relief raised
#was 11
		menubutton $gt.ins4 -text "From Snds"  -menu $gt.ins4.snd -relief raised
#RWD width was 6
		menubutton $gt3.mat -text "Maths"  -menu $gt3.mat.maths 	 -relief raised
		menubutton $gt3.mus -text "Pitch"  -menu $gt3.mus.music 	 -relief raised
#RWD width was 8
        menubutton $gt3.int -text "Interval" -menu $gt3.int.intv	 -relief raised
#RWD next four: width was 6
		menubutton $gt3.tim -text "Time"  -menu $gt3.tim.time   	 -relief raised
		menubutton $gt3.db -text  "Gain"  -menu $gt3.db.db   	 -relief raised
		menubutton $gt3.ran -text "Rand"  -menu $gt3.ran.random  -relief raised
		menubutton $gt3.ord -text "Order"  -menu $gt3.ord.order  -relief raised
#RWD width was 8
		menubutton $gt3.for -text "Format" -menu $gt3.for.format -relief raised
#was 10
		menubutton $gta.vec -text "Combine"  -menu $gta.vec.vector -relief raised
#was 8
		menubutton $gt3.ins -text "Edit In"  -menu $gt3.ins.edit -relief raised
#next two were 10
		menubutton $gt3.ins2 -text "Edit Out"  -menu $gt3.ins2.edit -relief raised
		menubutton $gt3.ins3 -text "At Cursor"  -menu $gt3.ins3.edit -relief raised
#RWD width was 7
		menubutton $gta.tab -text "Tables"  -menu $gta.tab.tabs -relief raised
		menubutton $gta.brk -text ""  -width 6  -menu $gta.brk.brkk -relief raised -state $d
#RWD width was 6
		menubutton $gta.env -text "Envel"  -menu $gta.env.envs -relief raised
		menubutton $gta.seq -text "" -width 5 -menu $gta.seq.seqs -relief raised -state $d
# was 10
		menubutton $gta.atc -text "At Cursor"  -menu $gta.atc.atco -relief raised
		menubutton $gta.joi -text "" -width 5 -menu $gta.joi.join -relief raised -state $d
#next two, width was 5		
		menubutton $gt.tes -text "Test" -menu $gt.tes.test -relief raised
		menubutton $gt.fin -text "Find" -menu $gt.fin.find -relief raised
		label $gt.dmu1 -text "    "
		label $gt.dmu2 -text "      "

		label $gta.dmu3 -text "ON 2 COLUMNS" -fg $evv(SPECIAL)

		label $gmi.lab1a -text "    PARAMETERS" -font bigfnt -fg $evv(SPECIAL)
		label $gmi.lab1 -text "    N"
		entry $gmi.par1 -textvariable colpar -width 12
		label $gmi.lab2 -text "Threshold"
		radiobutton $gmi.gr -variable threshtype -text "<" -value 1
		radiobutton $gmi.gl -variable threshtype -text ">" -value 0
		entry $gmi.par2 -textvariable threshold -width 8

		menubutton $gmi.bashelp -text "How to Use" -menu $gmi.bashelp.menu -relief raised -width 13 ;# -background $evv(HELP)
		set shlurp [menu $gmi.bashelp.menu  -tearoff 0]
		$shlurp add command -label "HOW TO USE TABLE EDITOR" -command {}  -foreground black
		$shlurp add separator ;# -background $evv(HELP)
		$shlurp add command -label "Typical Basic Operation" -command "TEBasicOpsHelp" -foreground black
		$shlurp add command -label "Typical Problems" -command "TEProblemsHelp" -foreground black
		$shlurp add command -label "Alternative Ways To Use Output Column" -command "TEOutColOptionsHelp" -foreground black
		$shlurp add separator ;# -background $evv(HELP)
		$shlurp add command -label "OTHER OPERATING MODES" -command {}  -foreground black
		$shlurp add separator ;# -background $evv(HELP)
		$shlurp add command -label "Working Directly On A Table" -command "TETableHelp" -foreground black
		$shlurp add command -label "Working With More Than One File" -command "TEManyFilesHelp" -foreground black
		$shlurp add command -label "Creating Data From Scratch" -command "TECreateHelp" -foreground black
		$shlurp add command -label "Working With Soundfile Data" -command "TESndfileDataHelp" -foreground black
		$shlurp add separator ;# -background $evv(HELP)
		$shlurp add command -label "OTHER INFORMATION" -command {}  -foreground black
		$shlurp add separator ;# -background $evv(HELP)
		$shlurp add command -label "Types Of Files To Use" -command "TEFileTypesHelp" -foreground black
		$shlurp add command -label "Alternative Ways To Save Output Table" -command "TEOutOptionsHelp" -foreground black
#RWD width was 10, title was "More info" ; changed for compatibility with Windows version
		menubutton $gmi.info -text "Info"  -menu $gmi.info.info -relief raised ;# -bg $evv(HELP)
		set inff [menu $gmi.info.info -tearoff 0]
		$inff add command -label "GENERAL" -command {} -foreground black
		$inff add separator ;# -background $evv(HELP) ;# -background $evv(HELP)
		$inff add command -label "Data Input Modes" -command "CDP_Specific_Usage $evv(TE_1) 0" -foreground black
		$inff add command -label "Menu Functions" -command "CDP_Specific_Usage $evv(TE_2) 0" -foreground black
		$inff add command -label "Parameters" -command "CDP_Specific_Usage $evv(TE_4) 0" -foreground black
		$inff add command -label "Threshold" -command "CDP_Specific_Usage $evv(TE_5) 0" -foreground black
		$inff add command -label "Types of Use" -command "CDP_Specific_Usage $evv(TE_3) 0" -foreground black
		$inff add separator ;# -background $evv(HELP)
		$inff add command -label "TERMS USED IN FUNCTIONS" -command {} -foreground black
		$inff add separator ;# -background $evv(HELP)
		$inff add command -label "Curvature" -command "CDP_Specific_Usage $evv(TE_6) 0" -foreground black
		$inff add command -label "Density" -command "CDP_Specific_Usage $evv(TE_7) 0" -foreground black
		$inff add command -label "Grouping" -command "CDP_Specific_Usage $evv(TE_8) 0" -foreground black
		$inff add command -label "Overlap" -command "CDP_Specific_Usage $evv(TE_9) 0" -foreground black
		$inff add command -label "Partitions" -command "CDP_Specific_Usage $evv(TE_10) 0" -foreground black
		$inff add command -label "Power" -command "CDP_Specific_Usage $evv(TE_11) 0" -foreground black
		$inff add command -label "Randomisation" -command "CDP_Specific_Usage $evv(TE_21) 0" -foreground black
		$inff add command -label "Rank" -command "CDP_Specific_Usage $evv(TE_12) 0" -foreground black
		$inff add command -label "Scatter over Quantised Grid" -command "CDP_Specific_Usage $evv(TE_13) 0" -foreground black
		$inff add command -label "Slope" -command "CDP_Specific_Usage $evv(TE_14) 0" -foreground black
		$inff add command -label "Span" -command "CDP_Specific_Usage $evv(TE_15) 0" -foreground black
		$inff add command -label "Stack" -command "CDP_Specific_Usage $evv(TE_16) 0" -foreground black
		$inff add command -label "Sum Absolute Differences" -command "CDP_Specific_Usage $evv(TE_17) 0" -foreground black
		$inff add command -label "Superimpose Envelopes" -command "CDP_Specific_Usage $evv(TE_18) 0" -foreground black
		$inff add command -label "Temper" -command "CDP_Specific_Usage $evv(TE_19) 0" -foreground black
		$inff add command -label "Time Sequence" -command "CDP_Specific_Usage $evv(TE_20) 0" -foreground black
		$inff add separator ;# -background $evv(HELP)
		$inff add command -label "BATCHFILES" -command {} -foreground black
		$inff add separator ;# -background $evv(HELP)
		$inff add command -label "Vectored Batchfiles: what are they?" -command "CDP_Specific_Usage $evv(TE_22) 0" -foreground black
		$inff add command -label "Vectored Batchfiles: How to create them." -command "CDP_Specific_Usage $evv(TE_23) 0" -foreground black
		$inff add command -label "Vectored Batchfiles: Parameters,Save,Run." -command "CDP_Specific_Usage $evv(TE_24) 0" -foreground black
		$inff add command -label "" -command {} -foreground black
		$inff add command -label "Texture Commands: Which Column has which parameter ?" -command "TexCrib" -foreground black
		$inff add command -label "" -command {} -foreground black

		button $gt.same -text "Again" -width 5 -command TabRep -highlightbackground [option get . background {}]
		button $gt.reset -text "Clear" -width 5 -command ResetTableEditor -highlightbackground [option get . background {}]

		frame $gt2.kbd 
		MakeKeyboardKey $gt2.kbd $evv(MIDITOTABED) 0 
		button $gt2.calc -text "Calculator" -width 9 -command "MusicUnitConvertor 0 0" -highlightbackground [option get . background {}];# -bg $evv(HELP)
 	 	button $gt2.ref -text "Get Ref Val" -width 9 -command "RefGet colpar" -highlightbackground [option get . background {}];# -bg $evv(HELP)
		frame $gt2.xmaca -bg $evv(POINT) -width 1

		label  $gt2.xmac -text "MACRO    " -fg $evv(SPECIAL)
		button $gt2.dmac -text "Run"    -width 4 -command DoTEMacro -highlightbackground [option get . background {}]
		button $gt2.rmac -text "Record" -width 7 -command RecordTEMacro -highlightbackground [option get . background {}]
		button $gt2.smac -text "Save"   -width 4 -command SaveTEMacro -highlightbackground [option get . background {}]
		button $gt2.lmac -text "Load"   -width 4 -command LoadTEMacro -highlightbackground [option get . background {}]

		frame $gt2.ltit -bg $evv(EMPH)
#RWD width was 57 - this reduces overall window width very usefully!
		label $gt2.ltit.tit -text "PROCESSES" -font bigfnt -fg $evv(SPECIAL) -bg $evv(EMPH) -width 40
		pack $gt2.ltit.tit -side top

		set ff [frame $gb.fframe  -borderwidth 2]
		frame $gb.l0  -width 3 -bg $evv(SPECIAL)
		set it [frame $gb.itframe -borderwidth 0]
		set gc [frame $gb.gframe  -borderwidth 0]
		frame $gb.l1  -width 3 -bg $evv(SPECIAL)
		set ic [frame $gb.icframe -borderwidth 0]
		set oc [frame $gb.ocframe -borderwidth 0]
		frame $gb.l2  -width 1 -bg $evv(POINT)
		set kc [frame $gb.kcframe -borderwidth 0]
		frame $gb.l3  -width 3 -bg $evv(SPECIAL)
		set ot [frame $gb.otframe -borderwidth 0]
		frame $gb.l4  -width 1 -bg $evv(POINT)
		set kt [frame $gb.ktframe -borderwidth 0]

		label $gb.files -text "FILES"  -font bigfnt -fg $evv(SPECIAL) -bg $evv(EMPH) 

		frame $ff.d
        radiobutton $ff.d.all -variable tet -value 0 -text "valid files" -command {TEListSelect all}
		radiobutton $ff.d.mix -variable tet -value 1 -text "mix" -command {TEListSelect mix}
		radiobutton $ff.d.brk -variable tet -value 2 -text "brk" -command {TEListSelect brk}
		pack $ff.d.all -side top
		pack $ff.d.mix $ff.d.brk -side left -padx 1
		frame $ff.e
        radiobutton $ff.e.bat -variable tet -value 3 -text "bat" -command {TEListSelect bat}
		radiobutton $ff.e.sort -variable tls -text "sort" -value 1 -command {ListSort $tabed.bot.fframe.l.list}
		pack $ff.e.bat $ff.e.sort -side left -padx 1
		label $gb.itab -text "INPUT TABLE" -font bigfnt -fg $evv(SPECIAL) -bg $evv(EMPH) 
		label $gb.cols -text "COLUMN"  -font bigfnt -fg $evv(SPECIAL) -bg $evv(EMPH)
		frame $gb.r1 -height 1 -bg $evv(POINT)

		label $gc.name -text "Get\nColumn?" -font bigfnt -fg $evv(SPECIAL)
		frame $gc.zoig -height 1 -bg $evv(POINT)
		label $gc.zaig -text "SKIPPING"
		frame $ic.dummy
		label $ic.dummy.name -text "INPUT"  -font bigfnt  -fg $evv(SPECIAL) -bg $evv(EMPH)
		entry $ic.dummy.cnt -textvariable inlines -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		radiobutton $ic.io -variable io -text "Copy to OUT  " -value 1 \
			-command {set col_ungapd_numeric 1; GenerateNewColumn "copy" 0 ; set io 0}
		radiobutton $ic.isu -variable insitu -text  "Result HERE  " -value 1 -command {LiteCol i}
		radiobutton $ic.isu2 -variable insitu -text "Result to OUT" -value 0 -command {LiteCol o} -bg $evv(EMPH)
		radiobutton $oc.oi -variable oi -text "Copy to IN" -value 1 \
			-command {set col_ungapd_numeric 1; GenerateNewColumn "recycle" 0; set oi 0}
		frame $ic.zog 
		frame $oc.zog 
		radiobutton $ic.zog.sw -variable oio -text "" -value 1 -command {SwapCols; set oio 0}
		pack $ic.zog.sw -side right
		frame $oc.dummy
		label $oc.zog.sw -text "Swap"
		pack $oc.zog.sw -side left
		label $oc.dummy.name -text "OUTPUT"  -font bigfnt  -fg $evv(SPECIAL) -bg $evv(EMPH)
		entry $oc.dummy.cnt -textvariable outlines -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		radiobutton $oc.rnd -variable tround -text "round         " -value 1 -command "RoundOutcols col"
		radiobutton $oc.rst -variable trst -text "restore      " -value 1 -command "RestoreColumn ; set trst 0"

		label $kc.name -text "Keep OutCol?" -font bigfnt  -fg $evv(SPECIAL) 
		label $gb.otab -text "OUTPUT TABLE"  -font bigfnt -fg $evv(SPECIAL) -bg $evv(EMPH) 
		label $kt.name -text "Save Table?" -font bigfnt -fg $evv(SPECIAL)
		
		set filelist [Scrolled_Listbox $ff.l -width 14 -height 16]
		label $ff.tell -text "Cmd-Clik Bigger" -fg $evv(SPECIAL)
		bind $filelist <Command-ButtonRelease-1> TabEdBigFiles

		label  $it.f0 -text "\n\n" -width 30 -fg $evv(SPECIAL)
		frame $it.f
		label  $it.f.lab -text "columns"
		entry  $it.f.e -textvariable incols -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $it.f.lab2 -text "rows"
		entry  $it.f.e2 -textvariable tot_inlines -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $it.f.lab $it.f.e $it.f.lab2 $it.f.e2 -side left -padx 1
		radiobutton $it.tcop -text "Copy to output" -variable tcop -value 1 -command CopyTabToOut -state $d
		set itablist [Scrolled_Listbox $it.l -width 26 -height 16]

		entry  $gc.e  -textvariable incolget -width 4 -state $d
		entry  $gc.got -textvariable orig_incolget -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		frame $gc.qqq -height 1 -bg $evv(POINT)
		button $gc.ok -text "OK" -command "GetColumnFromATable" -state $d -highlightbackground [option get . background {}]
		frame $gc.lina -bg $evv(POINT) -height 1
		label $gc.ddum -text "Chosen col"
		label $gc.sk -text "K title lines"
		frame $gc.blob -bd 2
		label $gc.blob.sksk -text "K = "
		entry $gc.blob.skip -textvariable col_skiplines -width 4 -state $d
		pack $gc.blob.sksk $gc.blob.skip -side left
		label $gc.lab -text "comments &\n'e','s' lines\n(CSound)"
		checkbutton $gc.cse -variable eflag -state $d
		label $gc.lab2 -text "comments"
		checkbutton $gc.cse2 -variable eflag2 -state $d

		set incol  [Scrolled_Listbox $ic.l -width 12 -height 14 -bg $evv(EMPH)]
		set outcol [Scrolled_Listbox $oc.l -width 12 -height 14]

		frame $kc.zzz0 -bg $evv(POINT) -height 2
		radiobutton $kc.okk -variable coltype -text "Keep\nby itself" -value "k" -command {RepKeep} -state $d
		frame $kc.zzz1 -bg $evv(POINT) -height 2
		radiobutton $kc.oko -variable coltype -text "Replace\nOrig col" -value "o" -command {RepCom 0} -state $d
		frame $kc.zzz2 -bg $evv(POINT) -height 2
		frame $kc.zzz3 -bg $evv(POINT) -height 2
		radiobutton $kc.okr -variable coltype -text "Replace as Col" -value "r" -command {InsCom 0} -state $d
		radiobutton $kc.oki -variable coltype -text "Insert as Col" -value "i" -command {InsCom 0} -state $d
		label $kc.lab -text "at position\n(Col No)"
		entry $kc.e -textvariable rcolno -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		radiobutton $kc.oky -variable okz -text "in Input\nTable" -value 1 -command {SetInout 1} -state $d
		radiobutton $kc.okz -variable okz -text "in Output\nTable" -value 0 -command {SetInout 0} -state $d
		button $kc.ok -text "OK" -command "PutAColumnIntoATable" -state $d -highlightbackground [option get . background {}]
		frame $ot.cnt
		label  $ot.cnt.lab -text "columns"
		entry  $ot.cnt.e -textvariable outcolcnt -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $ot.cnt.lab2 -text "rows"
		entry  $ot.cnt.e2 -textvariable tot_outlines -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $ot.cnt.lab $ot.cnt.e $ot.cnt.lab2 $ot.cnt.e2 -side left -padx 1
		frame $ot.rnd
		radiobutton $ot.rnd.rnd -variable ttround -text "round" -value 1 -command "RoundOutcols tab"
		radiobutton $ot.rnd.rec -variable ttrecyc -text "Recycle" -value 1 -command "TabRecyc"
		radiobutton $ot.rnd.cle -variable ttclear -text "clear" -value 1 -command "TabClear"
		pack $ot.rnd.rnd $ot.rnd.rec $ot.rnd.cle -side left
		set otablist [Scrolled_Listbox $ot.l -width 26 -height 16]

		frame $kt.zz2 -borderwidth $evv(SBDR)
		frame $kt.zz2a -borderwidth $evv(SBDR)
		frame $kt.zz3 -bg $evv(POINT) -height 1
		button $kt.zz2.ok1 -text "All" -command "set savestyle 0; SaveNewTable" -state $d  -width 4  -highlightbackground [option get . background {}]
		button $kt.zz2a.ok2 -text "Cols" -command "set savestyle 2; SaveNewTable" -state $d -width 4 -highlightbackground [option get . background {}]
		button $kt.zz2a.ok3 -text "Rows" -command "set savestyle 1; SaveNewTable" -state $d -width 4 -highlightbackground [option get . background {}]
		button $kt.zz2.ok4 -text "Batch" -command "set savestyle 3; SaveNewTable" -state $d -width 4 -highlightbackground [option get . background {}]
		pack $kt.zz2.ok1 $kt.zz2.ok4 -side left -expand true
		pack $kt.zz2a.ok3 $kt.zz2a.ok2 -side left -expand true
		label $kt.lab4 -text "Enter (Generic) Name"
		entry $kt.fnm -textvariable col_tabname -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		Scrolled_Listbox $kt.names -width 12 -height 10 -selectmode single
		frame $kt.bbb ;# -borderwidth $evv(SBDR)
		frame $kt.bbb1 ;# -borderwidth $evv(SBDR)
		frame $kt.bbb2 ;# -borderwidth $evv(SBDR)
		button $kt.bbb.1 -text "$sysname(1)" -command "set col_tabname $sysname(1)" -state $d -width 2 -highlightbackground [option get . background {}] 
		button $kt.bbb.2 -text "$sysname(2)" -command "set col_tabname $sysname(2)" -state $d -width 2 -highlightbackground [option get . background {}]
		button $kt.bbb.3 -text "$sysname(3)" -command "set col_tabname $sysname(3)" -state $d -width 3 -highlightbackground [option get . background {}]
		button $kt.bbb1.4 -text "$sysname(4)" -command "set col_tabname $sysname(4)" -state $d -width 3 -highlightbackground [option get . background {}]
		menubutton $kt.bxxb -text "" -menu $kt.bxxb.menu -bd 2 -relief raised -state $d -width 16
		set zlob [menu $kt.bxxb.menu  -tearoff 0]
		MakeStandardNamesMenu $zlob $kt.fnm 0
		button $kt.bbb1.6 -text "Input Name" -width 10 -command {set col_tabname [file rootname [file tail $col_infnam]]} -state $d  -highlightbackground [option get . background {}]
#		pack $kt.bbb1.6 -side top
		pack $kt.bbb.1 $kt.bbb.2  $kt.bbb.3 -side left -expand true
		pack $kt.bbb1.4 $kt.bbb1.6 -side left -expand true

#'CREATE1' MENU
		set creo [menu $gt.cre.create -tearoff 0]
#SUBSTITUTABLE
		$creo add command -label "ALSO SEE TABLES MENU" -command {} -background $evv(EMPH) -foreground  $evv(SPECIAL)
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "BY TYPING TEXT, KEY-TAPPING, OR TEMPO" -command {}  -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "Type Values into a column." -command {set col_ungapd_numeric 1; CreateNewColumn "Ii" 0} -foreground black
		$creo add command -label "Type Strings into a column." -command {set col_ungapd_numeric 1; CreateNewColumn "Iis" 0} -foreground black
		$creo add command -label "Enter Times by Tapping Out A Rhythm." -command {set col_ungapd_numeric 1; CreateNewColumn "tT" 0} -foreground black
		$creo add command -label "Create Times From Tempo & Duration." -command {set col_ungapd_numeric 1; CreateNewColumn "Td" 2} -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "FROM STAFF NOTATION" -command {}  -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add cascade -label "from Pitch Notation" -menu  $creo.sub3 -foreground black
		set c_3 [menu $creo.sub3 -tearoff 0]
		$c_3 add command -label "Midi Values" -command {set col_ungapd_numeric 1; StaffToMidi 0} -foreground black
		$c_3 add command -label "Note Names" -command {set col_ungapd_numeric 1; StaffToMidi 1} -foreground black
		$creo add cascade -label "from Rhythm Notation" -menu  $creo.sub4 -foreground black
		set c_4 [menu $creo.sub4 -tearoff 0]
		$c_4 add command -label "Note Lengths in beats" -command {set col_ungapd_numeric 1; StaffToBeats 0} -foreground black
		$c_4 add command -label "Attack Times in beats" -command {set col_ungapd_numeric 1; StaffToBeats 1} -foreground black
		$c_4 add command -label "Accents & Attack Times" -command {set col_ungapd_numeric 1; StaffToBeats 2} -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "N EQUAL VALUES" -command {}  -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "Make One-valued Column , value N" -command {set col_ungapd_numeric 1; CreateNewColumn "Iip" 0} -foreground black
		$creo add command -label "x1 Equal Values, value x2" -command {set col_ungapd_numeric 1; CreateNewColumn "ie" 2} -foreground black
		$creo add command -label "Copies Of Text in N, 'threshold' times" -command {set col_ungapd_numeric 0; CreateNewColumn "iE" 0} -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "VALUES IN A SEQUENCE, WITH FIXED STEP BETWEEN" -command {}  -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "From Zero, x1 Values With Step x2 between each pair" -command {set col_ungapd_numeric 1; CreateNewColumn "ic" 2} -foreground black
		$creo add command -label "From Zero, x1 Vals Step A btwn, x1 Vals Step B etc: Incol has A,B,...." -command {set col_ungapd_numeric 1; CreateNewColumn "Ic" 1} -foreground black
		$creo add command -label "x1 Values With Step x2 between each pair, starting at value x3" -command {set col_ungapd_numeric 1; CreateNewColumn "iC" 3} -foreground black
		$creo add command -label "x1 Equal Steps in interval between x2 and x3" -command {set col_ungapd_numeric 1; CreateNewColumn "iQ" 3} -foreground black
		$creo add command -label "Equal Steps Of Size x1 in interval between x2 and x3" -command {set col_ungapd_numeric 1; CreateNewColumn "i=" 3} -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "UNEQUAL STEPS BETWEEN TWO GIVEN VALUES" -command {}  -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "x1 Values With Ratio x2 between each pair, starting at value x3" -command {set col_ungapd_numeric 1; CreateNewColumn "iR" 3} -foreground black
		$creo add command -label "x1 Log-Equal Steps in interval between x2 and x3" -command {set col_ungapd_numeric 1; CreateNewColumn "L" 3} -foreground black
		$creo add command -label "x1 Steps With Curvature, in interval between x2 and x3, curvature x4" -command {set col_ungapd_numeric 1; CreateNewColumn "Q" 4} -foreground black
		$creo add cascade -label "Sinusoidal" -menu $creo.sub5 -foreground black
		set c_5 [menu $creo.sub5 -tearoff 0]
		$c_5 add command -label "Sinusoidal Sequence between limits x1:x2 startphase(degrees) x3 for x4 cycles: x5 vals per cycle" -command {set col_ungapd_numeric 1; CreateNewColumn "ss" 5} -foreground black
		$c_5 add command -label "Cosin Join from x1 to x2, times x3 to x4, number of points x5" -command {set col_ungapd_numeric 1; CreateNewColumn "sc" 5} -foreground black
		$c_5 add command -label "Concave Sinus Join from x1 to x2, times x3 to x4, number of points x5" -command {set col_ungapd_numeric 1; CreateNewColumn "sv" 5} -foreground black
		$c_5 add command -label "Convex Sinus Join from x1 to x2, times x3 to x4, number of points x5" -command {set col_ungapd_numeric 1; CreateNewColumn "sx" 5} -foreground black
		$creo add cascade -label "Fibonacci Series" -menu $creo.sub6 -foreground black
		set c_6 [menu $creo.sub6 -tearoff 0]
		$c_6 add cascade -label "Series Values" -command {set col_ungapd_numeric 1; CreateNewColumn "FS" 0} -foreground black
		$c_6 add cascade -label "Series Ratios" -command {set col_ungapd_numeric 1; CreateNewColumn "fs" 0} -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "FIXED DURATION SEQUENCES" -command {}  -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "Time Sequence Of Total Duration x1, from initial step x2 to final x3" -command {set col_ungapd_numeric 1; CreateNewColumn "At" 3} -foreground black
		$creo add command -label "Time Sequence  From Starttime, Total Dur x1, initial step x2 to final x3, starttime x4" -command {set col_ungapd_numeric 1; CreateNewColumn "AT" 4} -foreground black
		$creo add command -label "Sequence Of Durations Of Total Duration x1, start dur x2, end dur x3" -command {set col_ungapd_numeric 1; CreateNewColumn "Ad" 3} -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add command -label "RANDOM SETS AND CUTS" -command {}  -foreground black
		$creo add separator ;# -background $evv(HELP)
		$creo add cascade -label "All Values" -menu $creo.sub1 -foreground black
		set c_1 [menu $creo.sub1 -tearoff 0]
		$c_1 add command -label "x1 Values In Range x2 to x3" -command {set col_ungapd_numeric 1; CreateNewColumn "Rv" 3} -foreground black
		$c_1 add separator
		$c_1 add command -label "Cut x1 Into Chunks of min size x2, max size x3" -command {set col_ungapd_numeric 1; CreateNewColumn "Rc" 3} -foreground black
		$c_1 add command -label "Cut x1 Into x2 Chunks: randomisation x3" -command {set col_ungapd_numeric 1; CreateNewColumn "Rr" 3} -foreground black

		$creo add cascade -label "Integers Only" -menu $creo.sub2 -foreground black
		set c_2 [menu $creo.sub2 -tearoff 0]
		$c_2 add command -label "RANDOM SETS AND PATTERNS" -command {}  -foreground black
		$c_2 add separator ;# -background $evv(HELP)
		$c_2 add command -label "x1 Random Values From 1 TO x2: " -command {set col_ungapd_numeric 1; CreateNewColumn "Ri" 2} -foreground black
		$c_2 add command -label "Ditto, evenly spread: runs of adjacent equal vals no longer than x3" -command {set col_ungapd_numeric 1; CreateNewColumn "RI" 3} -foreground black
		$c_2 add command -label "x1 Rand Vals From Range x2 TO x3, startval x4, endval x5, max adjacent equal vals x6" -command {set col_ungapd_numeric 1; CreateNewColumn "rz" 6} -foreground black
		$c_2 add separator
		$c_2 add command -label "ZIGZAGS" -command {}  -foreground black
		$c_2 add separator ;# -background $evv(HELP)
		$c_2 add command -label "x1 vals Random Zigzagging within range x2 TO x3, ending at x4" -command {set col_ungapd_numeric 1; CreateNewColumn "qz" 4} -foreground black
		$c_2 add separator
		$c_2 add command -label "RANDOM 0s AND 1s" -command {}  -foreground black
		$c_2 add separator ;# -background $evv(HELP)
		$c_2 add command -label "0s AND 1s, Random Sequence of x1 of these" -command {set col_ungapd_numeric 1; CreateNewColumn "Rg" 1} -foreground black
		$c_2 add command -label "Ditto, with no more than x2 consecutive repeats" -command {set col_ungapd_numeric 1; CreateNewColumn "RG" 2} -foreground black
		$c_2 add separator
		$c_2 add command -label "PAIR OF INTEGERS IN RANDOM SEQUENCE" -command {}  -foreground black
		$c_2 add separator ;# -background $evv(HELP)
		$c_2 add command -label "Any Pair Of Integers x1,x2, Random Sequence of x3 of these" -command {set col_ungapd_numeric 1; CreateNewColumn "rG" 3} -foreground black
		$c_2 add command -label "Ditto, with no more than x4 consecutive repeats" -command {set col_ungapd_numeric 1; CreateNewColumn "rJ" 4} -foreground black



		$creo add command -label "" -command {} -foreground black

#'CREATE2' MENU
		set creo2 [menu $gt.cre2.create -tearoff 0]
#SUBSTITUTABLE
		$creo2 add command -label "ALSO SEE TABLES MENU" -command {} -background $evv(EMPH) -foreground  $evv(SPECIAL)
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "ALTERNATING PATTERNS" -command {}  -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add cascade -label "Alternating Patterns" -menu $creo2.sub1 -foreground black
		set c2_1 [menu $creo2.sub1 -tearoff 0]
		$c2_1 add command -label "ABAB..     x1 values (x2=A  x3=B)" -command {set col_ungapd_numeric 1; CreateNewColumn "zX" 3} -foreground black
		$c2_1 add command -label "AABBAABB.. x1 values (x2=A  x3=B)" -command {set col_ungapd_numeric 1; CreateNewColumn "zY" 3} -foreground black
		$c2_1 add command -label "ABBAABBAA..x1 values (x2=A  x3=B)" -command {set col_ungapd_numeric 1; CreateNewColumn "zZ" 3} -foreground black
		$c2_1 add  separator
		$c2_1 add command -label "ArAr..     x1 vals (x2=A  r = randvals-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zA" 4} -foreground black
		$c2_1 add command -label "rArA..     x1 vals (x2=A  r = randvals-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zB" 4} -foreground black
		$c2_1 add  separator
		$c2_1 add command -label "AAr1r1AAr2r2..     x1 vals (x2=A  r1,r2.. randval-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zG" 4} -foreground black
		$c2_1 add command -label "r1r1AAr2r2AA..     x1 vals (x2=A  r1,r2.. randval-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zH" 4} -foreground black
		$c2_1 add command -label "Ar1r1AAr2r2AA..    x1 vals (x2=A  r1,r2.. randval-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zI" 4} -foreground black
		$c2_1 add command -label "r1AAr2r2AAr3r3AA.. x1 vals (x2=A  r1,r2.. randval-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zJ" 4} -foreground black
		$c2_1 add  separator
		$c2_1 add command -label "AAr1r2AAr3r4..     x1 vals (x2=A  r1,r2.. randval-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zC" 4} -foreground black
		$c2_1 add command -label "r1r2AAr3r4AA..     x1 vals (x2=A  r1,r2.. randval-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zD" 4} -foreground black
		$c2_1 add command -label "Ar1r2AAr3r4AA..    x1 vals (x2=A  r1,r2.. randval-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zE" 4} -foreground black
		$c2_1 add command -label "r1AAr2r3AAr4r5AA.. x1 vals (x2=A  r1,r2.. randval-in-range x3-x4)" -command {set col_ungapd_numeric 1; CreateNewColumn "zF" 4} -foreground black
		$c2_1 add command -label "" -command {} -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "INTEGER ALTERNATING PATTERNS" -command {}  -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add cascade -label "Integer Alternating Patterns" -menu $creo2.sub2 -foreground black
		set c2_2 [menu $creo2.sub2 -tearoff 0]
		$c2_2 add command -label "111...r1r2...111...r3r4.. x1 integer vals (x2=count of '1's: x3 = count of rand ints, in each group)" -command {set col_ungapd_numeric 1; NewPatterns ZB 3} -foreground black
		$c2_2 add command -label "Ditto : but x4 = total number of items from which to select rand ints" -command {set col_ungapd_numeric 1; NewPatterns ZE 4} -foreground black
		$c2_2 add command -label "123...r1r2...123...r3r4.. x1 integer vals (x2=count of fixed ints '12..': x3 = count of rand ints, in each group)" -command {set col_ungapd_numeric 1; NewPatterns ZC 3} -foreground black
		$c2_2 add command -label "Ditto : but x4 = total number of items from which to select rand ints" -command {set col_ungapd_numeric 1; NewPatterns ZD 4} -foreground black
		$c2_2 add separator
		$c2_2 add command -label "x1 outputs from set of x2 vals: in sequence x3,x4,x5,x6 fixed,changing,fixed,changing: change-steps in x7" -command {set col_ungapd_numeric 1; NewPatterns ZF 7} -foreground black
		$c2_2 add command -label "                                                             More Information" -command HelpComplexPattern -foreground $evv(SPECIAL)
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "ADVANCING PATTERNS" -command {}  -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "e.g. ABCD,BCDE,CDEF..   start at x1, step by x2, x3 times, then baktrak by x4: etc. stop at x5" -command {set col_ungapd_numeric 1; CreateNewColumn "ZA" 5} -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "JUST INTONATION SCALES" -command {}  -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "Midi Vals, Tuned Around Midi Value x1, In Midi Range x2 and x3" -command {set col_ungapd_numeric 1; GenerateNewColumn "Zm" 3} -foreground black
		$creo2 add command -label "Freq Vals, Tuned Around Frq Value x1, In Frq Range x2 and x3" -command {set col_ungapd_numeric 1; GenerateNewColumn "ZH" 3} -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "GAPPED GRIDS" -command {}  -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "Sequence From 0, Step x1, Omitting Items Falling Between values-pairs in In-Col" -command {set col_ungapd_numeric 1; GenerateNewColumn "ys" 1} -foreground black
		$creo2 add command -label "Sequence From 0, Step x1, Omitting Items Falling Outside values-pairs in In-Col" -command {set col_ungapd_numeric 1; GenerateNewColumn "yS" 1} -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "SCATTER OVER A QUANTISED GRID" -command {}  -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "x1 Vals, Quantised Over x2, In Interval x3, With Randomisation x4" -command {set col_ungapd_numeric 1; CreateNewColumn "zq" 4} -foreground black
		$creo2 add command -label "x1 Random Vals Quantised Over x2, Between Each Input Col Pair: rand vals min of x3, max of x4, " -command {set col_ungapd_numeric 1; GenerateNewColumn "yq" 4} -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add command -label "TIMESTRETCH DATA" -command {}  -foreground black
		$creo2 add separator ;# -background $evv(HELP)
		$creo2 add cascade -label "Make A Set Of Timestretch Data Files" -command {} -menu $creo2.sub3 -foreground black
		$creo2 add command -label "                          More Information" -command {TimeStretchHelp} -foreground $evv(SPECIAL)
		set c2_3 [menu $creo2.sub3 -tearoff 0]
		$c2_3 add command -label "FILES WHICH WARP AT START ONLY" -command {}  -foreground black
		$c2_3 add separator
		$c2_3 add command -label "Fixed Times: Changing Values" -command {StrMak "tS"} -foreground black
		$c2_3 add command -label "Fixed Values: Changing Times" -command {StrMak "Ts"} -foreground black
		$c2_3 add command -label "Changing Values And Times" -command {StrMak "TS"} -foreground black
		$c2_3 add separator
		$c2_3 add command -label "FILES WHICH WARP AT END ONLY" -command {}  -foreground black
		$c2_3 add separator
		$c2_3 add command -label "Fixed Times: Changing Values" -command {StrMak "tV"} -foreground black
		$c2_3 add command -label "Fixed Values: Changing Times" -command {StrMak "Tv"} -foreground black
		$c2_3 add command -label "Changing Values And Times" -command {StrMak "TV"} -foreground black
		$c2_3 add separator

#MATHS MENU
		set matho [menu $gt3.mat.maths -tearoff 0]
#SUBSTITUTABLE
		$matho add cascade -label "Increment, Floor Or Shift" -menu $matho.subz -foreground black
		set ma_z [menu $matho.subz -tearoff 0]
		$ma_z add command -label "Increment (add 1)" -command {set col_ungapd_numeric 1; GenerateNewColumn "ai" 0} -foreground black
		$ma_z add command -label "Decrement (subtract 1)" -command {set col_ungapd_numeric 1; GenerateNewColumn "ad" 0} -foreground black
		$ma_z add command -label "Floor (shift vals, so 1st val is zero)" -command {set col_ungapd_numeric 1; GenerateNewColumn "af" 0} -foreground black
		$ma_z add command -label "Shift To (shift vals, so 1st val is N)" -command {set col_ungapd_numeric 1; GenerateNewColumn "as" 0} -foreground black
		$matho add cascade -label "Arithmetic (on vals < \[or >\] threshold)" -menu $matho.sub0 -foreground black
		set ma_0 [menu $matho.sub0 -tearoff 0]
		$ma_0 add command -label "Add N" -command {set col_ungapd_numeric 1; GenerateNewColumn "a" 0} -foreground black
		$ma_0 add command -label "Subtract N" -command {set col_ungapd_numeric 1; GenerateNewColumn "an" 0} -foreground black
		$ma_0 add command -label "Multiply by N" -command {set col_ungapd_numeric 1; GenerateNewColumn "m" 0} -foreground black
		$ma_0 add command -label "Divide by N" -command {set col_ungapd_numeric 1; GenerateNewColumn "d" 0} -foreground black
		$ma_0 add command -label "Reciprocals" -command {set col_ungapd_numeric 1; GenerateNewColumn "RR" 0} -foreground black
		$ma_0 add command -label "N Divided By values" -command {set col_ungapd_numeric 1; GenerateNewColumn "R" 0} -foreground black
		$ma_0 add command -label "Raise To Power of N (positive vals only)" -command {set col_ungapd_numeric 1; GenerateNewColumn "P" 0} -foreground black
		$matho add cascade -label "Algebra & Golden Section" -menu $matho.sub1 -foreground black
		set ma_1 [menu $matho.sub1 -tearoff 0]
		$ma_1 add command -label "ALGEBRA" -command {} -foreground black
		$ma_1 add separator
		$ma_1 add command -label "Apply Algebraic Formula, using variable 'Z': in parameter 'N' box" -command {set col_ungapd_numeric 1; AlgebraCol} -foreground black
		$ma_1 add command -label "Save Algebraic Formula Now In 'N' Box" -command KeepAlgebra -foreground black
		$ma_1 add command -label "Get Algebraic Formula From Store" -command "GetAlgebra 1" -foreground black
		$ma_1 add separator
		$ma_1 add command -label "GOLDEN SECTION" -command {}  -foreground black
		$ma_1 add separator
		$ma_1 add command -label "Multiply By Golden Section" -command {set col_ungapd_numeric 1; GenerateNewColumn "gold0" 0} -foreground black
		$ma_1 add command -label "Divide By Golden Section" -command {set col_ungapd_numeric 1; GenerateNewColumn "gold1" 0} -foreground black
		$matho add cascade -label "Cyclic Substitution" -menu $matho.sub2 -foreground black
		set ma_2 [menu $matho.sub2 -tearoff 0]
		$ma_2 add command -label "Add x1 To Every x2th Value starting at item x3" -command {set col_ungapd_numeric 1; GenerateNewColumn "Ca" 3} -foreground black
		$ma_2 add command -label "Multiply By x1 Every x2th Value starting at item x3" -command {set col_ungapd_numeric 1; GenerateNewColumn "Cm" 3} -foreground black
		$ma_2 add command -label "Add x1 To 2nd Item, (2 * x1) To 3rd Item, (3 * x1) To 4th etc" -command {set col_ungapd_numeric 1; GenerateNewColumn "ga" 1} -foreground black
		$matho add cascade -label "Fix Limits Or Rescale Values" -menu $matho.sub3 -foreground black
		set ma_3 [menu $matho.sub3 -tearoff 0]
		$ma_3 add command -label "Reduce values Above N to N" -command {set col_ungapd_numeric 1; GenerateNewColumn "bg" 0} -foreground black
		$ma_3 add command -label "Increase values Below N to N" -command {set col_ungapd_numeric 1; GenerateNewColumn "bl" 0} -foreground black
		$ma_3 add command -label "Zero (Gate) values Below N" -command {set col_ungapd_numeric 1; GenerateNewColumn "bz" 0} -foreground black
		$ma_3 add command -label "Scale Interval Between x1 And Value, by x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "sf" 2} -foreground black
		$ma_3 add command -label "Scale interval between x1 and values Above x1, by x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "sa" 2} -foreground black
		$ma_3 add command -label "Scale interval between x1 and values Below x1, by x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "sb" 2} -foreground black
		$ma_3 add command -label "Set values above threshold to N" -command {set col_ungapd_numeric 1; GenerateNewColumn "SaN" 0} -foreground black
		$ma_3 add command -label "Set values below threshold to N" -command {set col_ungapd_numeric 1; GenerateNewColumn "SbN" 0} -foreground black
		$ma_3 add command -label "Set values above threshold to 1/val" -command {set col_ungapd_numeric 1; GenerateNewColumn "SaR" 0} -foreground black
		$ma_3 add command -label "Set values below threshold to 1/val" -command {set col_ungapd_numeric 1; GenerateNewColumn "SbR" 0} -foreground black

		$matho add command -label "Make Binary (0->0 all else ->1)" -command {set col_ungapd_numeric 1; GenerateNewColumn "bb" 2} -foreground black
		$matho add cascade -label "Special Sums & Ratios" -menu $matho.sub4 -foreground black
		set ma_4 [menu $matho.sub4 -tearoff 0]
		$ma_4 add command -label "Sum In Groups of N" -command {set col_ungapd_numeric 1; GenerateNewColumn "sn" 0} -foreground black
		$ma_4 add command -label "Stack Values from zero (overlap N)" -command {set col_ungapd_numeric 1; GenerateNewColumn "s" 0} -foreground black
		$ma_4 add command -label "Stack Values from zero (overlap N) BUT OMIT LAST VALUE" -command {set col_ungapd_numeric 1; GenerateNewColumn "sz" 0} -foreground black
		$ma_4 add command -label "Find Ratios Between Successive Vals" -command {set col_ungapd_numeric 1; GenerateNewColumn "ra" 0} -foreground black
		$matho add cascade -label "Graphical" -menu $matho.sub5 -foreground black
		set ma_5 [menu $matho.sub5 -tearoff 0]
		$ma_5 add command -label "Change Slope by factor N" -command {set col_ungapd_numeric 1; GenerateNewColumn "sl" 0} -foreground black
		$ma_5 add command -label "" -command {} -foreground black

#LOUDNESS MENU
		set dbo [menu $gt3.db.db -tearoff 0]
#SUBSTITUTABLE
		$dbo add command -label "UNIT CONVERSION" -command {}  -foreground black
		$dbo add separator ;# -background $evv(HELP)
		$dbo add command -label "dB to Gain" -command {set col_ungapd_numeric 1; GenerateNewColumn "DB" 0} -foreground black
		$dbo add command -label "dB to 16-bit Sample Values" -command {set col_ungapd_numeric 1; GenerateNewColumn "Ds" 0} -foreground black
		$dbo add command -label "Gain to dB" -command {set col_ungapd_numeric 1; GenerateNewColumn "db" 0} -foreground black
		$dbo add command -label "Gain to 16-bit Sample Values" -command {set col_ungapd_numeric 1; GenerateNewColumn "gs" 0} -foreground black
		$dbo add command -label "16-bit Sample Values to dB" -command {set col_ungapd_numeric 1; GenerateNewColumn "sD" 0} -foreground black
		$dbo add command -label "16-bit Sample Values to Gain" -command {set col_ungapd_numeric 1; GenerateNewColumn "sg" 0} -foreground black
		$dbo add command -label "" -command {} -foreground black

#TIME MENU
		set timo [menu $gt3.tim.time -tearoff 0]
#SUBSTITUTABLE
		$timo add command -label "CONVERT TIME UNITS" -command {}  -foreground black
		$timo add separator ;# -background $evv(HELP)
		$timo add command -label "Time + Beats Calculator" -command ClikCalculator -foreground $evv(SPECIAL)
		$timo add cascade -label "Beats To Time" -menu $timo.sub1 -foreground black
		set ti_1 [menu $timo.sub1 -tearoff 0]
		$ti_1 add command -label "Count-of-beats To Time, Tempo N"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Tc" 0} -foreground black
		$ti_1 add command -label "Lengths Of Succesive Beats To Their Entry Times, Tempo N" -command {set col_ungapd_numeric 1; GenerateNewColumn "Tl" 0} -foreground black
		$ti_1 add command -label "Positions-of-beats To Times, for Beat duration N (counting beats from 1)"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Tp" 0} -foreground black
		$ti_1 add command -label "Positions-of-beats To Times, With Initial Offset, Beat duration N, offset=Threshold (count beats from 1)" -command {set col_ungapd_numeric 1; GenerateNewColumn "TP" 0} -foreground black
		$ti_1 add command -label "Beat-in-bar To Time : (4:2.5 = beat 2.5 in bar 4) x1=metre (3.4 = metre 3:4) x2 = crotchet tempo" -command {set col_ungapd_numeric 1; GenerateNewColumn "Tb" 2} -foreground black
		$ti_1 add command -label "Beat-in-bar To Time, With Initial Offset x1 = metre, x2 = crotchet tempo, x3 = time offset" -command {set col_ungapd_numeric 1; GenerateNewColumn "TB" 3} -foreground black

		$timo add cascade -label "Time To Beats" -menu $timo.sub2 -foreground black
		set ti_2 [menu $timo.sub2 -tearoff 0]
		$ti_2 add command -label "Times Of Events To Beat Count, Crotchet duration N (Approx only with tapped times!)"	-command {set col_ungapd_numeric 1; GenerateNewColumn "tC" 0} -foreground black
		$ti_2 add command -label "Times Of Events To Beat Values, Crotchet duration N (Approx only with tapped times!)"	-command {set col_ungapd_numeric 1; GenerateNewColumn "tB" 0} -foreground black

		$timo add cascade -label "Samples To & From Time" -menu $timo.sub3 -foreground black
		set ti_3 [menu $timo.sub3 -tearoff 0]
		$ti_3 add command -label "Sample Count To Time at Srate N" -command {set col_ungapd_numeric 1; GenerateNewColumn "st" 0} -foreground black
		$ti_3 add command -label "Time To Sample Count at Srate N" -command {set col_ungapd_numeric 1; GenerateNewColumn "ts" 0} -foreground black

		$timo add cascade -label "Delay Times To Pitch" -menu $timo.sub4 -foreground black
		set ti_4 [menu $timo.sub4 -tearoff 0]
		$ti_4 add command -label "Delay Times (mS) to Midi" -command {set col_ungapd_numeric 1; GenerateNewColumn "dM" 0} -foreground black
		$ti_4 add command -label "Delay Times (mS) to Frq"  -command {set col_ungapd_numeric 1; GenerateNewColumn "dh" 0} -foreground black

		$timo add cascade -label "Pitch To Delay Times" -menu $timo.sub5 -foreground black
		set ti_5 [menu $timo.sub5 -tearoff 0]
		$ti_5 add command -label "Midi to Delay Times (mS)" -command {set col_ungapd_numeric 1; GenerateNewColumn "Md" 0} -foreground black
		$ti_5 add command -label "Frq to Delay Times (mS)"  -command {set col_ungapd_numeric 1; GenerateNewColumn "hd" 0} -foreground black

		$timo add cascade -label "Timestretch To Pitch Intervals" -menu $timo.sub6 -foreground black
		set ti_6 [menu $timo.sub6 -tearoff 0]

		$ti_6 add command -label "Timestretch to Frq Ratio"	-command {set col_ungapd_numeric 1; set colpar ""; GenerateNewColumn "rT" 0} -foreground black
		$ti_6 add command -label "Timestretch to Semitones"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Ts" 0} -foreground black
		$ti_6 add command -label "Timestretch to Octaves"	-command {set col_ungapd_numeric 1; GenerateNewColumn "TO" 0} -foreground black

		$timo add separator ;# -background $evv(HELP)
		$timo add command -label "QUANTISE" -command {}  -foreground black
		$timo add separator ;# -background $evv(HELP)
		$timo add command -label "Quantise Times to multiples of N" -command {set col_ungapd_numeric 1; GenerateNewColumn "A" 0} -foreground black
		$timo add separator ;# -background $evv(HELP)
		$timo add command -label "MAINTAIN LAYER DENSITY N" -command {}  -foreground black
		$timo add separator ;# -background $evv(HELP)
		$timo add command -label "Specify Entrytimes for events of listed durations" -command {set col_ungapd_numeric 1; GenerateNewColumn "td" 0} -foreground black
		$timo add separator ;# -background $evv(HELP)
		$timo add command -label "DURATION STRETCH" -command {}  -foreground black
		$timo add separator ;# -background $evv(HELP)
		$timo add command -label "Stretch factors forcing durs to selected dur" -command {set col_ungapd_numeric 1; GenerateNewColumn "Sf" 0} -foreground black

#PITCH ETC MENU
		set muso [menu $gt3.mus.music -tearoff 0]
#SUBSTITUTABLE
		$muso add command -label "PLAY PITCH SETS IN INPUT COLUMN" -command {}  -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add command -label "Play Frequencies List, As Chord" -command {PlayChordset 0 2} -foreground black
		$muso add command -label "Play Midi List (Possibly fractional), AS CHORD" -command {PlayChordset 0 1} -foreground black
		$muso add command -label "Play Midi Chord Sequence (separate by '#')" -command {PlayChordset 0 3} -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add command -label "TONAL HARMONY WORKSHOP ON MIDI VALUES" -command {}  -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add cascade -label "Transpose,Invert,Rotate,Contract,Complement,Maj<->Min etc" -menu $muso.sub1 -foreground black
		set mu_1 [menu $muso.sub1 -tearoff 0]
		$mu_1 add command -label "Input Table" -command {set col_ungapd_numeric 1; PitchManips 1} -foreground black
		$mu_1 add command -label "Input Column" -command {set col_ungapd_numeric 1; PitchManips 2} -foreground black
#		$muso add command -label "Major to Minor in Key N (Midi)"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Mm" 0} -foreground black
#		$muso add command -label "Minor to Major in Key N (Midi)" -command {set col_ungapd_numeric 1; GenerateNewColumn "mM" 0} -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add command -label "CONVERSION & TRANSPOSITION" -command {}  -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add cascade -label "Unit & Data Conversion" -menu $muso.sub2 -foreground black
		set mu_2 [menu $muso.sub2 -tearoff 0]
		$mu_2 add command -label "Midi to Note representations" -command {set col_ungapd_numeric 0; GenerateNewColumn "Mt" 0} -foreground black
		$mu_2 add command -label "Notes to Midi" -command {set col_ungapd_numeric 1; GenerateNewColumn "nM" 0} -foreground black
		$mu_2 add command -label "Notes to Frq" -command {set col_ungapd_numeric 1; GenerateNewColumn "nF" 0} -foreground black
		$mu_2 add command -label "Frq to Notes" -command {set col_ungapd_numeric 0; GenerateNewColumn "ft" 0} -foreground black
		$mu_2 add command -label "Frq to Midi"	-command {set col_ungapd_numeric 1; GenerateNewColumn "hM" 0} -foreground black
		$mu_2 add command -label "Midi to Frq"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Mh" 0} -foreground black
		$mu_2 add separator
		$mu_2 add command -label "Frq to Pvoc Channel: Srate N: Anal Chans thresh"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Fc" 0} -foreground black
		$mu_2 add command -label "Midi to Pvoc Channel: Srate N: Anal Chans thresh"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Mc" 0} -foreground black
		$mu_2 add separator
		$mu_2 add command -label "Remove Data Zeros From Frq List" -command {set col_ungapd_numeric 1; GenerateNewColumn "RD" 0} -foreground black
		$mu_2 add command -label "Shrink Rounded Data Vals To Sequence" -command {set col_ungapd_numeric 1; GenerateNewColumn "R" 0} -foreground black
		$muso add cascade -label "Notes To Transpositions relative to a Given Note (N)" -menu $muso.sub4 -foreground black
		set mu_4 [menu $muso.sub4 -tearoff 0]
		$mu_4 add command -label "Text Notation (e.g.c#0)" -command {set col_ungapd_numeric 0; GenerateNewColumn "nT" 0} -foreground black
		$mu_4 add command -label "Midi Values" -command {set col_ungapd_numeric 0; GenerateNewColumn "KKan" 0} -foreground black
		$mu_4 add command -label "Frq Values" -command {set col_ungapd_numeric 0; GenerateNewColumn "KKd" 0} -foreground black
		$muso add separator
		$muso add cascade -label "Note (N) Transposed By Set Of Transpositions" -menu $muso.sub5 -foreground black
		set mu_5 [menu $muso.sub5 -tearoff 0]
		$mu_5 add command -label "Midi Values" -command {set col_ungapd_numeric 0; GenerateNewColumn "KKa" 0} -foreground black
		$mu_5 add command -label "Frq Values" -command {set col_ungapd_numeric 0; GenerateNewColumn "KKm" 0} -foreground black
		$muso add command -label "Frq Transposed By N Semitones" -command {set col_ungapd_numeric 1; GenerateNewColumn "KKz" 0} -foreground black
		$muso add cascade -label "Conversion To Delay Times" -menu $muso.sub3 -foreground black
		set mu_3 [menu $muso.sub3 -tearoff 0]
		$mu_3 add command -label "Midi to Delay Times in milliseconds" -command {set col_ungapd_numeric 1; GenerateNewColumn "Md" 0} -foreground black
		$mu_3 add command -label "Frq to Delay Times in ms"  -command {set col_ungapd_numeric 1; GenerateNewColumn "hd" 0} -foreground black
		$mu_3 add command -label "Delay Times (ms) to Midi" -command {set col_ungapd_numeric 1; GenerateNewColumn "dM" 0} -foreground black
		$mu_3 add command -label "Delay Times (ms) to Frq"  -command {set col_ungapd_numeric 1; GenerateNewColumn "dh" 0} -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add command -label "TEMPERAMENT" -command {}  -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add cascade -label "To Tempered Values" -menu $muso.sub6 -foreground black
		set mu_6 [menu $muso.sub6 -tearoff 0]
		$mu_6 add command -label "Temper Frqs (to N-note scale) (around reference frq 'threshold')" -command {set col_ungapd_numeric 1; GenerateNewColumn "Th" 0} -foreground black
		$mu_6 add command -label "Temper Midi Vals (to N-note scale) (around reference midival 'threshold')"	-command {set col_ungapd_numeric 1; GenerateNewColumn "TM" 0} -foreground black
		$mu_6 add command -label "Temper Frqs To Just Intonation around reference frq 'N'" -command {set col_ungapd_numeric 1; GenerateNewColumn "Zh" 0} -foreground black
		$mu_6 add command -label "Temper Midi Vals To Just Intonation around reference frq 'N'"	-command {set col_ungapd_numeric 1; GenerateNewColumn "ZM" 0} -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add command -label "OCTAVE DUPLICATION, NOTE REPETITION, GROUPING" -command {}  -foreground black
		$muso add separator ;# -background $evv(HELP)
		$muso add command -label "Duplicate Midi List in another N octaves" -command {set col_ungapd_numeric 1; GenerateNewColumn "do" 0} -foreground black
		$muso add command -label "Duplicate Frq List in another N octaves" -command {set col_ungapd_numeric 1; GenerateNewColumn "dO" 0} -foreground black
		$muso add command -label "Rearrange To Avoid Frq Repeats (within N notes)" -command {set col_ungapd_numeric 1; GenerateNewColumn "fr" 0} -foreground black
		$muso add command -label "Rearrange To Avoid Midi Repeats (within N notes)" -command {set col_ungapd_numeric 1; GenerateNewColumn "Mr" 0} -foreground black
		$muso add command -label "Harmonically Group Frqs (N semitone error)" -command {set col_ungapd_numeric 0; GenerateNewColumn "Hg" 0} -foreground black
		$muso add command -label "Rank By Number Of Occurences Of Frqs in Input Column: N = semitone err" -command {set col_ungapd_numeric 0 ; GenerateNewColumn "V" 0} -foreground black
		$muso add command -label "Rank By Number Of Occurences Of Frqs in Output Column: N = semitone err" -command {set col_ungapd_numeric 0 ; GenerateNewColumn "V" -1} -foreground black
		$muso add command -label "" -command {} -foreground black

#INTERVAL MENU
		set into [menu $gt3.int.intv -tearoff 0]
#SUBSTITUTABLE
		$into add command -label "MUSIC-INTERVALS : UNIT CONVERT" -command {}  -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add cascade -label "Semitones to.." -menu $into.sub1 -foreground black
		set i_1 [menu $into.sub1 -tearoff 0]
		$i_1 add command -label "Semitones to Frq Ratio"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Ir" 0} -foreground black
		$i_1 add command -label "Semitones to Octaves"	-command {set col_ungapd_numeric 1; GenerateNewColumn "sO" 0} -foreground black
		$i_1 add command -label "Semitones to Timestretch"	-command {set col_ungapd_numeric 1; GenerateNewColumn "sT" 0} -foreground black
		$into add cascade -label "Frq Ratio to.." -menu $into.sub2 -foreground black
		set i_2 [menu $into.sub2 -tearoff 0]
		$i_2 add command -label "Frq Ratio to Semitones"	-command {set col_ungapd_numeric 1; GenerateNewColumn "rI" 0} -foreground black
		$i_2 add command -label "Frq Ratio to Octaves"	-command {set col_ungapd_numeric 1; GenerateNewColumn "ro" 0} -foreground black
		$i_2 add command -label "Frq Ratio to Timestretch"	-command {set col_ungapd_numeric 1; GenerateNewColumn "rT" 0} -foreground black
		$into add cascade -label "Octaves to.." -menu $into.sub3 -foreground black
		set i_3 [menu $into.sub3 -tearoff 0]
		$i_3 add command -label "Octaves to Frq Ratio"	-command {set col_ungapd_numeric 1; GenerateNewColumn "or" 0} -foreground black
		$i_3 add command -label "Octaves to Semitones"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Os" 0} -foreground black
		$i_3 add command -label "Octaves to Timestretch"	-command {set col_ungapd_numeric 1; GenerateNewColumn "OT" 0} -foreground black
		$into add cascade -label "Timestretch to.." -menu $into.sub4 -foreground black
		set i_4 [menu $into.sub4 -tearoff 0]
		$i_4 add command -label "Timestretch to Frq Ratio"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Tr" 0} -foreground black
		$i_4 add command -label "Timestretch to Semitones"	-command {set col_ungapd_numeric 1; GenerateNewColumn "Ts" 0} -foreground black
		$i_4 add command -label "Timestretch to Octaves"	-command {set col_ungapd_numeric 1; GenerateNewColumn "TO" 0} -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add command -label "MUSIC-INTERVALS : MOTIVIC OPERATIONS" -command {}  -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add command -label "Motivically Invert (Midi vals)" -command {set col_ungapd_numeric 1; GenerateNewColumn "iM" 0} -foreground black
		$into add command -label "Motivically Invert (Frq vals)" -command {set col_ungapd_numeric 1; GenerateNewColumn "ih" 0} -foreground black
		$into add command -label "Motivically Rotate by N" -command {set col_ungapd_numeric 1; GenerateNewColumn "rm" 0} -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add command -label "STEPS BETWEEN VALUES : GET/REPEAT" -command {}  -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add command -label "Get Steps Between Successive Vals" -command {set col_ungapd_numeric 1; GenerateNewColumn "i" 0;} -foreground black
		$into add command -label "Repeat Sequence Of Steps (N times)" -command {set col_ungapd_numeric 1; GenerateNewColumn "ir" 0} -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add command -label "STEPS BETWEEN VALUES : MODIFY" -command {}  -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add command -label "Add N To Steps between values" -command {set col_ungapd_numeric 1; GenerateNewColumn "ia" 0} -foreground black
		$into add command -label "Multiply Steps by N" -command {set col_ungapd_numeric 1; GenerateNewColumn "im" 0} -foreground black
		$into add command -label "Reverse Sequence Of Steps" -command {set col_ungapd_numeric 1; GenerateNewColumn "tR" 0} -foreground black
		$into add command -label "Limit Steps To Less than N" -command {set col_ungapd_numeric 1; GenerateNewColumn "iL" 0} -foreground black
		$into add command -label "Limit Steps To Greater than N" -command {set col_ungapd_numeric 1; GenerateNewColumn "il" 0} -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add command -label "STEPS BETWEEN VALUES : INTERPOLATE" -command {}  -foreground black
		$into add separator ;# -background $evv(HELP)
		$into add command -label "Find Intermediate Values" -command {set col_ungapd_numeric 1; GenerateNewColumn "iv" 0} -foreground black
		$into add command -label "Insert Intermediate Values" -command {set col_ungapd_numeric 1; GenerateNewColumn "iV" 0} -foreground black
		$into add command -label "Insert N Intermediate Values" -command {set col_ungapd_numeric 1; GenerateNewColumn "IV" 0} -foreground black
		$into add command -label "Insert Intermediate Vals Between Successive Pairs" -command {set col_ungapd_numeric 1; GenerateNewColumn "ip" 0} -foreground black
		$into add command -label "Add Extra Value, After a Step Of N" -command {set col_ungapd_numeric 1; GenerateNewColumn "aS" 0} -foreground black
		$into add command -label "" -command {} -foreground black



#ORDER MENU
		set ordo [menu $gt3.ord.order -tearoff 0]
#SUBSTITUTABLE
		$ordo add command -label "REORDER" -command {}  -foreground black
		$ordo add separator ;# -background $evv(HELP)
		$ordo add command -label "Numerically Order" -command {set col_ungapd_numeric 1; GenerateNewColumn "o" 0} -foreground black
		$ordo add command -label "Alpha-Numerically Order" -command {set col_ungapd_numeric 1; GenerateNewColumn "As" 0} -foreground black
		$ordo add command -label "Reverse Order"	   -command {set col_ungapd_numeric 1; GenerateNewColumn "rr" 0} -foreground black
		$ordo add cascade -label "Rotate Order"	-menu $ordo.sub1 -foreground black
		set or_1 [menu $ordo.sub1 -tearoff 0]
		$or_1 add command -label "Rotate Order"	   -command {set col_ungapd_numeric 1; GenerateNewColumn "rR" 0} -foreground black
		$or_1 add command -label "Reverse Rotate Order"	 -command {set col_ungapd_numeric 1; GenerateNewColumn "rX" 0} -foreground black
		$or_1 add command -label "Rotate Order by N" -command {set col_ungapd_numeric 1; GenerateNewColumn "rRn" 0} -foreground black
		$or_1 add command -label "Rotate Item At Cursor To Top"	-command {set col_ungapd_numeric 1; CursRotate} -foreground black
		$ordo add command -label "Forward + Reverse (end value not duplicated) e.g. ABCD -->> ABCDCBA" -command {set col_ungapd_numeric 1; GenerateNewColumn "ZC" 0} -foreground black
		$ordo add separator ;# -background $evv(HELP)
		$ordo add command -label "REGROUP" -command {}  -foreground black
		$ordo add separator ;# -background $evv(HELP)
		$ordo add command -label "Group xth Items, cyclically" -command {set col_ungapd_numeric 0; GenerateNewColumn "G" 0} -foreground black
		$ordo add command -label "Group N Values, then skip 1" -command {set col_ungapd_numeric 0; GenerateNewColumn "sK" 0} -foreground black
		$ordo add command -label "Group 1 Value, then skip N"	-command {set col_ungapd_numeric 0; GenerateNewColumn "sk" 0} -foreground black
		$ordo add separator
		$ordo add command -label "Repattern using pattern in N : e.g. ace:aecc:3"	-command {set col_ungapd_numeric 0; RepatternCol} -foreground black
		$ordo add command -label "                          More Information" -command {RepatternHelp} -foreground $evv(SPECIAL)
		$ordo add separator ;# -background $evv(HELP)
		$ordo add command -label "COPY" -command {}  -foreground black
		$ordo add separator ;# -background $evv(HELP)
		$ordo add command -label "N Copies Of List" -command {set col_ungapd_numeric 1; GenerateNewColumn "dl" 0} -foreground black
		$ordo add command -label "N Copies Without Repeating 1st Value e.g. ABCBA -->> ABCBABCBABCBA" -command {set col_ungapd_numeric 1; GenerateNewColumn "ZD" 0} -foreground black
		$ordo add command -label "x1 Copies Stepping By x2 from Last Val of one copy to start val of next" -command {set col_ungapd_numeric 1; GenerateNewColumn "dL" 2} -foreground black
		$ordo add command -label "x1 Copies,stepping by x2 from Start Val of one copy to start val of next" -command {set col_ungapd_numeric 1; GenerateNewColumn "dd" 2} -foreground black
		$ordo add command -label "N Copies Of Each Value in list" -command {set col_ungapd_numeric 1; GenerateNewColumn "dv" 0} -foreground black
		$ordo add separator ;# -background $evv(HELP)
		$ordo add command -label "OTHER" -command {}  -foreground black
		$ordo add separator ;# -background $evv(HELP)
		$ordo add command -label "Cyclical: Get Every x1th Item starting at item x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "yC" 2} -foreground black
		$ordo add command -label "Rank Values by no. of occurences" -command {set col_ungapd_numeric 0 ; GenerateNewColumn "v" 0} -foreground black
		$ordo add command -label "Positions Of Vals equal to value at cursor (within error range 'threshold')" -command {} -foreground $evv(SPECIAL) ;# -background $evv(HELP)
		$ordo add separator ;# -background $evv(HELP)
		$ordo add command -label "Transfer To Output Table, values at these positions in the Other column" -command {Vectors "py"} -foreground black
		$ordo add command -label "Transfer To Output Table. values Not at these positions in the Other column" -command {Vectors "pn"} -foreground black
		$ordo add command -label "" -command {} -foreground black

#EDIT MENU
		set edio [menu $gt3.ins.edit -tearoff 0]
#SUBSTITUTABLE
		$edio add command -label "TRIM TO SIZE" -command {}  -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add command -label "Delete 1 Item From Bottom" -command {set col_ungapd_numeric 1; TrimColumn "tb1"} -foreground black
		$edio add command -label "Delete 1 Item From Top" -command {set col_ungapd_numeric 1; TrimColumn "tt1"} -foreground black
		$edio add command -label "Trim To Size N, deleting From Bottom" -command {set col_ungapd_numeric 1; TrimColumn "tb"} -foreground black
		$edio add command -label "Trim To Size N, deleting From Top" -command {set col_ungapd_numeric 1; TrimColumn "tt"} -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add command -label "DELETE VALUES" -command {}  -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add cascade -label "Delete Values" -menu $edio.sub0 -foreground black
		set ed_0 [menu $edio.sub0 -tearoff 0]
		$ed_0 add command -label "Value(s) Equal To N" -command {set col_ungapd_numeric 1; GenerateNewColumn "e" 0} -foreground black
		$ed_0 add command -label "Values Less than N"	-command {set col_ungapd_numeric 1; GenerateNewColumn "el" 0} -foreground black
		$ed_0 add command -label "Values Greater than N" -command {set col_ungapd_numeric 1; GenerateNewColumn "eg" 0} -foreground black
		$ed_0 add command -label "Duplicates Of Values (Within range N)" -command {set col_ungapd_numeric 1; GenerateNewColumn "ed" 0} -foreground black
		$ed_0 add command -label "x1th To x2th Values" -command {set col_ungapd_numeric 1; GenerateNewColumn "yd" 2} -foreground black
		$ed_0 add command -label "Every 2nd Item" -command {set col_ungapd_numeric 1; GenerateNewColumn "ee" 0} -foreground black
		$ed_0 add command -label "Items Separated By <= N (ascending vals only)" -command {set col_ungapd_numeric 1; GenerateNewColumn "di" 0} -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add command -label "REPLACE VALUES" -command {}  -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add cascade -label "By Fixed Value" -menu $edio.sub1 -foreground black
		set ed_1 [menu $edio.sub1 -tearoff 0]
		$ed_1 add command -label "At Position x1, by value x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "yr" 2} -foreground black
		$ed_1 add command -label "Equal TO x1, by x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "ye" 2} -foreground black
		$ed_1 add command -label "Less Than x1, by x2"	-command {set col_ungapd_numeric 1; GenerateNewColumn "yl" 2} -foreground black
		$ed_1 add command -label "Greater Than x1, by x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "yg" 2} -foreground black

		$edio add cascade -label "By Random Values" -menu $edio.sub2 -foreground black
		set ed_2 [menu $edio.sub2 -tearoff 0]
		$ed_2 add command -label "Equal To x1, By Rand Vals in range x2 to x3" -command {set col_ungapd_numeric 1; GenerateNewColumn "ya" 3} -foreground black
		$ed_2 add command -label "Less Than x1, By Rand Vals in range x2 to x3"	-command {set col_ungapd_numeric 1; GenerateNewColumn "yb" 3} -foreground black
		$ed_2 add command -label "Greater Than x1, By Rand Vals in range x2 to x3" -command {set col_ungapd_numeric 1; GenerateNewColumn "yc" 3} -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add command -label "INSERT VALUES" -command {}  -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add cascade -label "Insert Values" -menu $edio.sub3 -foreground black
		set ed_3 [menu $edio.sub3 -tearoff 0]
		$ed_3 add command -label "At Start Insert value x1" -command {set col_ungapd_numeric 1; GenerateNewColumn "yB" 1} -foreground black
		$ed_3 add command -label "At End Insert value x1" -command {set col_ungapd_numeric 1; GenerateNewColumn "yE" 1} -foreground black
		$ed_3 add command -label "In Correct Place In An Ascending Order Column Insert value x1" -command {set col_ungapd_numeric 1; GenerateNewColumn "yo" 1} -foreground black
		$ed_3 add command -label "At Position x1, insert the value x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "yi" 2} -foreground black
		$ed_3 add command -label "Insert After (First) Value x1 the value x2" -command {set col_ungapd_numeric 1; GenerateNewColumn "yA" 2} -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add command -label "MARK VALUES" -command {}  -foreground black
		$edio add separator ;# -background $evv(HELP)
		$edio add command -label "Greater than N" -command {set col_ungapd_numeric 0; GenerateNewColumn "mg" 0} -foreground black
		$edio add command -label "Less than N"	-command {set col_ungapd_numeric 0; GenerateNewColumn "ml" 0} -foreground black
		$edio add command -label "Multiples of N (to within error 'threshold')" -command {set col_ungapd_numeric 0; GenerateNewColumn "mm" 0} -foreground black
		$edio add command -label "" -command {} -foreground black
		$edio add command -label "Remove Marks" -command {DelColMarks i} -foreground black
		$edio add command -label "" -command {} -foreground black

#EDIT OUTPUT MENU
		set edio2 [menu $gt3.ins2.edit -tearoff 0]
#SUBSTITUTABLE
		$edio2 add command -label "TRIM TO SIZE" -command {}  -foreground black
		$edio2 add separator ;# -background $evv(HELP)
		$edio2 add command -label "To Match Size Of Input, deleting From Bottom" -command {set col_ungapd_numeric 1; TrimColumn "mb"} -foreground black
		$edio2 add command -label "To Match Size Of Input, deleting From Top" -command {set col_ungapd_numeric 1; TrimColumn "mt"} -foreground black
		$edio2 add separator ;# -background $evv(HELP)
		$edio2 add command -label "MARK" -command {}  -foreground black
		$edio2 add separator ;# -background $evv(HELP)
		$edio2 add command -label "Remove Marks" -command {DelColMarks o} -foreground black
		$edio2 add command -label "" -command {}

#EDIT AT CURSOR MENU
		set edio3 [menu $gt3.ins3.edit -tearoff 0]

		$edio3 add command -label "REPLACE" -command {}  -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add cascade -label "Values Only" -menu $edio3.sub1 -foreground black
		set e_1 [menu $edio3.sub1 -tearoff 0]
		$e_1 add command -label "Replace Value at cursor by value N" -command {set col_ungapd_numeric 1 ; CursCol r} -foreground black
		$edio3 add cascade -label "Strings or Values" -menu $edio3.sub2 -foreground black
		set e_2 [menu $edio3.sub2 -tearoff 0]
		$e_2 add command -label "Replace Item at cursor by string N" -command {set col_ungapd_numeric 1 ; CursCol rs} -foreground black
		$e_2 add command -label "Replace Matches to item at cursor by string N" -command {set col_ungapd_numeric 1 ; CursCol e} -foreground black
		$e_2 add command -label "Replace Items Not Matching items at cursor by N" -command {set col_ungapd_numeric 1 ; CursCol ne} -foreground black
		$e_2 add command -label "Replace Matches By Numbered Strings Nn, where n increases from zero" -command {set col_ungapd_numeric 1 ; CursCol i} -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "INSERT" -command {}  -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add cascade -label "Values Only" -menu $edio3.sub3 -foreground black
		set e_3 [menu $edio3.sub3 -tearoff 0]
		$e_3 add command -label "Before Cursor, insert value N" -command {set col_ungapd_numeric 1 ; CursCol b} -foreground black
		$e_3 add command -label "After Cursor, insert value N" -command {set col_ungapd_numeric 1 ; CursCol a} -foreground black
		$edio3 add cascade -label "Strings or Values" -menu $edio3.sub4 -foreground black
		set e_4 [menu $edio3.sub4 -tearoff 0]
		$e_4 add command -label "Before Cursor, insert string N" -command {set col_ungapd_numeric 1 ; CursCol bs} -foreground black
		$e_4 add command -label "After Cursor, insert string N" -command {set col_ungapd_numeric 1 ; CursCol as} -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "DELETE" -command {}  -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "Item At Cursor" -command {set col_ungapd_numeric 1 ; CursCol d} -foreground black
		$edio3 add command -label "All items At And Before cursor" -command {set col_ungapd_numeric 1 ; CursCol db} -foreground black
		$edio3 add command -label "All items At And After cursor" -command {set col_ungapd_numeric 1 ; CursCol da} -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "GET" -command {}  -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "Get Item At Cursor To Parameter N" -command {set col_ungapd_numeric 1 ; CursCol dg} -foreground black
		$edio3 add command -label "Get Item At Cursor to Reference Store" -command {set col_ungapd_numeric 1 ; RefStore colcurs} -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "SUBSTITUE" -command {}  -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "Substitute All Vals Equal To Val At Cursor By N" -command {set col_ungapd_numeric 1; GenerateNewColumn "sui" 0} -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "PERFORM CALCULATION" -command {} ;# -background $evv(HELP) -foreground black
		$edio3 add separator ;# -background $evv(HELP)
		$edio3 add command -label "Column Item At Cursor To Calculator" -command {set col_ungapd_numeric 1 ; CursCol cc} -foreground black
		$edio3 add command -label "make calculation: see result here" -command {set col_ungapd_numeric 1 ; CursCol cc} -foreground black

#SNDFILES MENU
		set sndio [menu $gt.ins4.snd -tearoff 0]

		$sndio add command -label "CREATE DATA FROM SNDFILES CHOSEN ON WORKSPACE" -command {}  -foreground black
		$sndio add separator ;# -background $evv(HELP)
		$sndio add command -label "List Soundfile Names" -command {set col_ungapd_numeric 1; CreateNewColumn "Sn" 0} -foreground black
		$sndio add command -label "List Maximum Levels" -command {set col_ungapd_numeric 1; CreateNewColumn "Sm" 0} -foreground black
		$sndio add command -label "List Durations" -command {set col_ungapd_numeric 1; CreateNewColumn "Sl" 0} -foreground black
		$sndio add command -label "List Entry Times For Each File, if joined end to end, with overlap N" -command {set col_ungapd_numeric 1; CreateNewColumn "Sj" 0} -foreground black

		$sndio add separator ;# -background $evv(HELP)
		$sndio add command -label "CREATE DATA FROM SNDFILES LISTED IN INPUT COLUMN" -command {}  -foreground black
		$sndio add separator ;# -background $evv(HELP)
		$sndio add command -label "List Maximum Levels" -command {set col_ungapd_numeric 1; CreateNewColumn "Smc" 0} -foreground black
		$sndio add command -label "List Durations" -command {set col_ungapd_numeric 1; CreateNewColumn "Slc" 0} -foreground black
		$sndio add command -label "List Entry Times For Each File, if joined end to end, with overlap N" -command {set col_ungapd_numeric 1; CreateNewColumn "Sjc" 0} -foreground black

		$sndio add separator ;# -background $evv(HELP)
		$sndio add command -label "CREATE DATA FROM MIXFILES CHOSEN ON WORKSPACE" -command {}  -foreground black
		$sndio add separator ;# -background $evv(HELP)
		$sndio add command -label "List Durations" -command {set col_ungapd_numeric 1; CreateNewColumn "SK" 0} -foreground black

		$sndio add separator ;# -background $evv(HELP)
		$sndio add command -label "CREATE DATA FROM ANY FILES CHOSEN ON WORKSPACE" -command {}  -foreground black
		$sndio add separator ;# -background $evv(HELP)
		$sndio add command -label "List File Names" -command {set col_ungapd_numeric 1; CreateNewColumn "Sk" 0} -foreground black
		$sndio add command -label "Set Parameter N From First Chosen File On Workspace" -command {FileAsParam 0} -foreground black
		$sndio add command -label "Set Parameter 'Threshold' From First Chosen File On Workspace" -command {FileAsParam 1} -foreground black
		$sndio add separator ;# -background $evv(HELP)
		$sndio add command -label "WORK ON A LIST OF (POSSIBLE) FILENAMES IN AN INPUT TABLE" -command {}  -foreground black
		$sndio add separator ;# -background $evv(HELP)
		$sndio add cascade -label "Work On Filenames" -menu $sndio.sub0 -foreground black
		set s_0 [menu $sndio.sub0 -tearoff 0]
		$s_0 add command -label "Extract All Soundfiles" -command {set col_ungapd_numeric 1; NameGames extract_s} -foreground black
		$s_0 add command -label "Extract All Soundfiles On Workspace" -command {set col_ungapd_numeric 1; NameGames extract_sw} -foreground black
		$s_0 add command -label "Extract All Soundfiles ~not~ On Workspace" -command {set col_ungapd_numeric 1; NameGames extract_snw} -foreground black
		$s_0 add command -label "Extract All Sounds Listed More Than Once" -command {set col_ungapd_numeric 1; NameGames find_dupls} -foreground black
		$s_0 add command -label "Count All Sounds Listed More Than Once" -command {set col_ungapd_numeric 1; NameGames find_dupcnt} -foreground black
		$s_0 add command -label "Check That All Listed Items Are Soundfiles" -command {set col_ungapd_numeric 1; NameGames extract_ch} -foreground black
		$s_0 add command -label "Extract All Items That Are ~not~ Soundfiles" -command {set col_ungapd_numeric 1; NameGames extract_ns} -foreground black
		$s_0 add command -label "Remove All Items That Are ~not~ Soundfiles" -command {set col_ungapd_numeric 1; NameGames remove_ns} -foreground black
		$s_0 add command -label "Force All Listed Soundfiles Onto Workspace" -command {set col_ungapd_numeric 1; NameGames extract_tow} -foreground black
		$s_0 add command -label "Force....& Make Copies Of Any Duplicated Sounds" -command {set col_ungapd_numeric 1; NameGames extract_cop} -foreground black
		$s_0 add command -label "If Filenames Contain String, Change Seg1 -> Seg2 " -command {set col_ungapd_numeric 1; NameGames condsubf}	  -foreground black
		$sndio add separator
		$sndio add command -label "Extract Transformation Pairs" -command {set col_ungapd_numeric 1; NameGames transpairs} -foreground black
		$sndio add command -label "                          More Information" -command {TransPairsInfo}  -foreground $evv(SPECIAL)
		$sndio add command -label "Split Transformation Pairs To Lists For Bulk Processing" -command {set col_ungapd_numeric 1; SplitTransforms} -foreground black
		$sndio add command -label "                          More Information" -command {SplitPairsInfo}  -foreground $evv(SPECIAL)
		$sndio add command -label "Process Transformations Pairs With Batchfiles" -command {TransformationBatchfileHelp} -foreground black
		$sndio add command -label "                          More Information" -command {TransformationBatchfileHelp}  -foreground $evv(SPECIAL)

#RANDOM MENU
		set rando [menu $gt3.ran.random -tearoff 0]
#SUBSTITUTABLE
		$rando add command -label "VALUE RANDOMISE" -command {}  -foreground black
		$rando add separator ;# -background $evv(HELP)
		$rando add command -label "Add Random Val Within Range 0 to N" -command {set col_ungapd_numeric 1; GenerateNewColumn "RA" 0} -foreground black
		$rando add command -label "Add Random Val Within Range -N to N" -command {set col_ungapd_numeric 1; GenerateNewColumn "Ra" 0} -foreground black
		$rando add command -label "Add Random Separation Between Vals Within Range N to threshold" -command {set col_ungapd_numeric 1; GenerateNewColumn "rS" 0} -foreground black
		$rando add command -label "Multiply By Rand Val, range 0 to N" -command {set col_ungapd_numeric 1; GenerateNewColumn "Rm" 0} -foreground black
		$rando add command -label "Scatter Vals Over Steps Between Them: with randomisation N (range 0-1) or file" -command {set col_ungapd_numeric 1; GenerateNewColumn "Rs" 0} -foreground black
		$rando add separator ;# -background $evv(HELP)
		$rando add command -label "ORDER RANDOMISE" -command {}  -foreground black
		$rando add separator ;# -background $evv(HELP)
		$rando add command -label "Randomise Order" -command {set col_ungapd_numeric 1; GenerateNewColumn "Ro" 0} -foreground black
		$rando add command -label "N Copies, Each Order-randomised (No item repeats between copies)" -command {set col_ungapd_numeric 1; GenerateNewColumn "Rx" 0} -foreground black
		$rando add separator ;# -background $evv(HELP)
		$rando add command -label "DELETE AT RANDOM" -command {}  -foreground black
		$rando add separator ;# -background $evv(HELP)
		$rando add command -label "Delete N randomly chosen items" -command {set col_ungapd_numeric 1; GenerateNewColumn "Re" 0} -foreground black
		$rando add command -label "" -command {} -foreground black

#VECTOR MENU
		set veco [menu $gta.vec.vector -tearoff 0]
		$veco add command -label "RESULT GOES DIRECTOLY TO FILES" -command {}  -foreground black
		$veco add separator -background $evv(HELP)
		$veco add command -label "Interpolate Vals In col1 To Vals In col2 In 'N' Steps (to Files Named 'Threshold')" -command {Vectors "ii"} -foreground black
		$veco add separator -background $evv(HELP)
		$veco add command -label "RESULT GOES TO OUTPUT TABLE" -command {}  -foreground black
		$veco add separator ;# -background $evv(HELP)
		$veco add command -label "Gradually Interp Vals In col1 To Vals In col2 (warp Factor 'Threshold')" -command {Vectors "iw"} -foreground black
		$veco add cascade -label "Combine Lists" -menu $veco.sub4 -foreground black
		set v_4 [menu $veco.sub4 -tearoff 0]
		$v_4 add command -label "List col1 Followed By col2" -command {Vectors "la"} -foreground black
		$v_4 add command -label "List col2 Followed By col1" -command {Vectors "lb"} -foreground black
		$v_4 add command -label "Replace 1st N Items col1 By 1st N Items col2" -command {Vectors "nn"} -foreground black
		$v_4 add command -label "Combine And Sort All Vals from both columns" -command {Vectors "ls"} -foreground black
		$v_4 add command -label "Join Text In Column2 Onto Text In Column 1" -command {Vectors "jt"} -foreground black
		$v_4 add command -label "" -command {} -foreground black

		$veco add cascade -label "Morph Lists" -menu $veco.sub14
		set v_14 [menu $veco.sub14 -tearoff 0]
		$v_14 add command -label "Morph vals in col1 to those in col2, starting at item x1, ending at item x2" -command {Vectors "MO"} -foreground black
		$v_14 add command -label "Morph sequence of steps in col1 to that in col2, starting at item x1, ending at item x2" -command {Vectors "Mo"} -foreground black

		$veco add cascade -label "Compare Lists" -menu $veco.sub13 -foreground black
		set v_13 [menu $veco.sub13 -tearoff 0]
		$v_13 add command -label "Find All Elements That Are Only In One Of Lists" -command {Vectors "oo"} -foreground black
		$v_13 add command -label "Find All Elements That Are Only In List 1" -command {Vectors "o1"} -foreground black
		$v_13 add command -label "Find All Elements That Are Only In List 2" -command {Vectors "o2"} -foreground black
		$v_13 add command -label "Find All Elements That Are In Both Lists" -command {Vectors "ob"} -foreground black
		$v_13 add command -label "" -command {}
		$veco add cascade -label "Maths" -menu $veco.sub1 -foreground black
		set v_1 [menu $veco.sub1 -tearoff 0]
		$v_1 add command -label "Add col2 to col1" -command {Vectors "a"} -foreground black
		$v_1 add command -label "Subtract col2 from col1" -command {Vectors "s"} -foreground black
		$v_1 add command -label "Multiply col1 by col2" -command {Vectors "m"} -foreground black
		$v_1 add command -label "Divide col1 by col2" -command {Vectors "d"} -foreground black
		$v_1 add command -label "Raise col1 To Power in col2" -command {Vectors "P"} -foreground black
		$v_1 add command -label "Get Maxima" -command {Vectors "b"} -foreground black
		$v_1 add command -label "Get Minima" -command {Vectors "B"} -foreground black
		$v_1 add command -label "Get Mean" -command {Vectors "A"} -foreground black
		$v_1 add command -label "" -command {}
		$veco add command -label "Quantise col1 vals onto vals in col2" -command {Vectors "q"} -foreground black
		$veco add cascade -label "Random" -menu $veco.sub3 -foreground black
		set v_3 [menu $veco.sub3 -tearoff 0]
		$v_3 add command -label "Add To col1 Random Vals which lie between + - val in col2" 	 -command {Vectors "Ra"} -foreground black
		$v_3 add command -label "Multiply col1 By Random Vals which lie between 0 and col2 val" -command {Vectors "Rm"} -foreground black
		$v_3 add command -label "Random Scatter col1 VAL: col2 = degree of scatter\[0-1\]" -command {Vectors "Rs"} -foreground black
		$v_3 add command -label "" -command {} -foreground black
		$veco add cascade -label "Insert Vals In Other Column" -menu $veco.sub5 -foreground black
		set v_5 [menu $veco.sub5 -tearoff 0]
		$v_5 add command -label "Interleave Vals from col1 and col2" 	-command {Vectors "I"} -foreground black
		$v_5 add command -label "Interleave Text from col1 and col2" 	-command {VVectors "I"} -foreground black
		$v_5 add command -label "Interleave Text from col1 and col2 Using A Pattern" -command {Vectors "IP"} -foreground black
		$v_5 add command -label "Insert Successive col2 vals at start and after every xth val in col 1" -command {Vectors "i"} -foreground black
		$v_5 add command -label "Substitute: Each val equal to N in col1, substituted by successive vals from col2" -command {Vectors "S"} -foreground black
		$v_5 add command -label "Overwrite: 1st and every xth col1 val substituted by successive vals from col2" -command {Vectors "o"} -foreground black
		$v_5 add command -label "Substitute col2 vals Over Numeric Part Of Vals In col1" -command {Vectors "O"} -foreground black
		$v_5 add command -label "" -command {} -foreground black
		$veco add cascade -label "Work On Value Blocks (Ascending order in both columns)" -menu $veco.sub6 -foreground black
		set v_6 [menu $veco.sub6 -tearoff 0]
		$v_6 add command -label "(Ascending order in both columns)" -command {} -foreground $evv(SPECIAL)
		$v_6 add command -label "Retain Items in col1 which are Between the pairs of values in col2" -command {Vectors "KK"} -foreground black
		$v_6 add command -label "Delete Items in col1 which are Between the pairs of values in col2" -command {Vectors "KD"} -foreground black
		$v_6 add command -label "" -command {} -foreground black
		$veco add cascade -label "Work On Listed Positions" -menu $veco.sub7 -foreground black
		set v_7 [menu $veco.sub7 -tearoff 0]
		$v_7 add command -label "Retain Items in col1 which are at the Positions Listed in col2" -command {Vectors "Kk"} -foreground black
		$v_7 add command -label "Delete Items in col1 which are at the Positions Listed in col2" -command {Vectors "Kd"} -foreground black
		$v_7 add command -label "ascending order in 2nd column" -command {} -foreground $evv(SPECIAL)
		$v_7 add command -label "Retain Items in col1 at the Positions Listed in col2, in each successive block of N values" -command {Vectors "kk"} -foreground black
		$v_7 add command -label "Delete Items in col1 at the Positions Listed in col2, in each successive block of N values" -command {Vectors "kd"} -foreground black
		$v_7 add command -label "" -command {} -foreground black

		$veco add cascade -label "Work On Matched Positions" -menu $veco.sub11 -foreground black
		set v_11 [menu $veco.sub11 -tearoff 0]
		$v_11 add command -label "At Each Match of x1 in col1, get x2 vals from col2 at this position" -command {Vectors "M"} -foreground black
		$v_11 add command -label "" -command {} -foreground black

		$veco add cascade -label "Duplications" -menu $veco.sub8 -foreground black
		set v_8 [menu $veco.sub8 -tearoff 0]
		$v_8 add command -label "Delete items in col1 which are Duplicated in col2" -command {Vectors "Kc"} -foreground black
		$v_8 add command -label "Insert into col1 items in col2 which are Not Duplicates, and Sort" -command {Vectors "KS"} -foreground black
		$v_8 add command -label "" -command {} -foreground black
		$veco add command -label "Use Pattern In Col1 To Sequence Vals In Col2" -command {Vectors "VP"} -foreground black
		$veco add command -label "Repeat Time Pattern In Col2 Starting At Every Time In Col1" -command {Vectors "RR"} -foreground black
		$veco add separator ;# -background $evv(HELP)
		$veco add command -label "RESULT GOES TO A COLUMN DISPLAY" -command {}  -foreground black
		$veco add separator ;# -background $evv(HELP)
		$veco add cascade -label "Combine Lists" -menu $veco.sub12  -foreground black
		set v_12 [menu $veco.sub12 -tearoff 0]
		$v_12 add command -label "List col1 Followed By col2" -command {Vectors "laX"} -foreground black
		$v_12 add command -label "List col2 Followed By col1" -command {Vectors "lbX"} -foreground black
		$v_12 add command -label "Combine And Sort All Vals from both columns" -command {Vectors "lsX"} -foreground black
		$v_12 add command -label "Join Text In Column2 Onto Text In Column 1" -command {Vectors "jtX"} -foreground black
		$v_12 add command -label "" -command {} -foreground black
		$veco add separator
		$veco add command -label "Substitute col2 vals Over Numeric Part Of Vals In col1" -command {Vectors "Oo"} -foreground black
		$veco add separator
		$veco add cascade -label "Cursor Insert To In Col" -menu $veco.sub9 -foreground black
		set v_9 [menu $veco.sub9 -tearoff 0]
		$v_9 add command -label "Vals in Out Col Replace val at Cursor in In Col" -command {CursVec i r} -foreground black
		$v_9 add command -label "Vals in Out Col Listed Below val at Cursor in In Col" -command {CursVec i b} -foreground black
		$v_9 add command -label "Vals in Out Col Listed Above val at Cursor in In Col" -command {CursVec i a} -foreground black
		$v_9 add command -label "" -command {} -foreground black
		$veco add cascade -label "Cursor Insert To Out Col" -menu $veco.sub10 -foreground black
		set v_10 [menu $veco.sub10 -tearoff 0]
		$v_10 add command -label "Vals in In Col Replace val at Cursor in Out Col" -command {CursVec o r} -foreground black
		$v_10 add command -label "Vals in In Col Listed Below val at Cursor in Out Col" -command {CursVec o b} -foreground black
		$v_10 add command -label "Vals in In Col Listed Above val at Cursor in Out Col" -command {CursVec o a} -foreground black
		$v_10 add command -label "" -command {} -foreground black
		$veco add separator ;# -background $evv(HELP)
		$veco add command -label "TRANSFER VALUES FROM ONE COL TO OTHER" -command {}  -foreground black
		$veco add command -label "(select item with cursor to initiate: HALT to Stop)" -command {}  -foreground $evv(SPECIAL) -foreground black
		$veco add separator ;# -background $evv(HELP)
		$veco add command -label "ALL COLUMNS" -command {} -foreground $evv(SPECIAL)
		$veco add separator ;# -background $evv(HELP)
		$veco add command -label "Transfer Value at cursor in In Column to Out column" -command {set col_ungapd_numeric 1 ; CursCop i t} -foreground black
		$veco add command -label "Transfer Value at cursor in Out Column to In column" -command {set col_ungapd_numeric 1 ; CursCop o t} -foreground black
		$veco add separator ;# -background $evv(HELP)
		$veco add command -label "COLUMNS OF ASCENDING VALUES ONLY" -command {} -foreground $evv(SPECIAL)
		$veco add separator ;# -background $evv(HELP)
		$veco add command -label "Transfer Value at cursor in In Col to Correct Position in Out col" -command {set col_ungapd_numeric 1 ; CursCop i T} -foreground black
		$veco add command -label "Transfer Value at cursor in Out Col to Correct Position in In col" -command {set col_ungapd_numeric 1 ; CursCop o T} -foreground black
		$veco add command -label "" -command {} -foreground black
		$veco add command -label "Halt transfering" -command {HaltCursCop} -foreground black
		$veco add command -label "" -command {} -foreground black


#DERIVE MENU MENU
		set dero [menu $gt.der.derive -tearoff 0]
#SUBSTITUTABLE
		$dero add command -label "SYSTEMIC PATTERNS" -command {}  -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add command -label "Plain Bob bell-ringing sequence on entered values" -command {set col_ungapd_numeric 1; GenerateNewColumn "B" 0} -foreground black
		$dero add command -label "Frequencies Of Harmonics above a given pitch-name or frequency (in parameter N)" -command {set col_ungapd_numeric 1; CreateNewColumn "H" 0} -foreground black
		$dero add command -label "Frequencies Of Octaves above a given pitch-name or frequency (in parameter N)" -command {set col_ungapd_numeric 1; CreateNewColumn "O" 0} -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add command -label "GET PROCESS PARAMETERS" -command {}  -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add command -label "List Parameter Values from last run process or instrument" -command {set col_ungapd_numeric 1; CreateNewColumn "P" 0} -foreground black
#		$dero add command -label "Create Normalising Envelope for Portion Of Sound Frozen By Iteration" -command {TabMake "ie"} -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add command -label "SELECT VALUES FROM EXISTING COLUMN" -command {}  -foreground black
		$dero add command -label "Initiate by selecting a new item with cursor : Stop by selecting HALT" -command {} -foreground $evv(SPECIAL) -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add command -label "Input Column: Copy Cursor-selected Items to make a New column" -command {set col_ungapd_numeric 1 ; CursCop i c} -foreground black
		$dero add command -label "Input Column: Move Cursor-selected Items to make a New column" -command {set col_ungapd_numeric 1 ; CursCop i m} -foreground black
		$dero add command -label "Output Column: Copy Cursor-selected Items to make a New column" -command {set col_ungapd_numeric 1 ; CursCop o c} -foreground black
		$dero add command -label "Output Column: Move Cursor-selected items to make a New column" -command {set col_ungapd_numeric 1 ; CursCop o m} -foreground black
		$dero add command -label "" -command {} -foreground black
		$dero add command -label "Halt selecting" -command {HaltCursCop} -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add command -label "GROUP OR GROUP DELETE OR SUBSTITUTE ITEMS IN COLUMN" -command {}  -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add command -label "Isolate Groups Of Events using separation <= N (ascending only)" -command {set col_ungapd_numeric 1; GenerateNewColumn "me" 0} -foreground black
		$dero add command -label "Randomly Delete x1 items,but <= x2 ADJACENT items: sets of adjacent items remaining <= x3" -command {set col_ungapd_numeric 1; GenerateNewColumn "yR" 3} -foreground black
		$dero add command -label "Substitute All values, by value at N" -command {set col_ungapd_numeric 1; GenerateNewColumn "sU" 0} -foreground black
		$dero add command -label "Substitute Values equal to 'threshold' by value at N" -command {set col_ungapd_numeric 1; GenerateNewColumn "su" 0} -foreground black
		$dero add command -label "Pairs in reverse numeric order, replaced by 2 ordered vals close to mean" -command {set col_ungapd_numeric 1; GenerateNewColumn "rp" 0} -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add command -label "OTHER" -command {}  -foreground black
		$dero add separator ;# -background $evv(HELP)
		$dero add cascade -label "Convert Times A:B:C:D... To Edit Partitions   A-N  B+N : B-N  C+N: C-N etc" -command {Inf "See the 'Tables' menu"} -foreground black
		$dero add command -label "Expand All Peaks Above threshold To Height Of Largest" -command {set col_ungapd_numeric 1; GenerateNewColumn "xp" 0} -foreground black
		$dero add cascade -label "Span Values In Existing Column By Others" -menu $dero.sub1 -foreground black
		set d_1 [menu $dero.sub1 -tearoff 0]
		$d_1 add command -label "Pre-span    Each value (T) goes to (T-threshold,T)" -command {set col_ungapd_numeric 1; GenerateNewColumn "sR" 0} -foreground black
		$d_1 add command -label "Post-span  Each value (T) goes to (T,T+threshold)" -command {set col_ungapd_numeric 1; GenerateNewColumn "sF" 0} -foreground black
		$d_1 add command -label "Span        Each value (T) goes to (T-threshold,T,T+threshold)" -command {set col_ungapd_numeric 1; GenerateNewColumn "sX" 0} -foreground black
		$d_1 add command -label "Span To Pair   Each value (T) goes to (T-threshold,T,T+N,T+N+threshold)" -command {set col_ungapd_numeric 1; GenerateNewColumn "sP" 0} -foreground black
		$d_1 add command -label "Span-Pair    Each pair (T1,T2) goes to (T1-threshold,T1,T2+N,T2+N+threshold)" -command {set col_ungapd_numeric 1; GenerateNewColumn "sp" 0} -foreground black
		$d_1 add command -label "Span-All      Put 0 before and N after the values in the column" -command {set col_ungapd_numeric 1; GenerateNewColumn "sA" 0} -foreground black
		$dero add cascade -label "Generate Tailored Control Files" -menu $dero.sub2 -foreground black
		set d_2 [menu $dero.sub2 -tearoff 0]
		$d_2 add command -label "Side-to-Side Panfile: with extreme positions placed at times specified in input column" -command {set col_ungapd_numeric 1; ColtoTab "yP" 5} -foreground black
		$d_2 add command -label "                           x1 = half-lingertime at pan-extreme; x2 = 1st pan-extreme position" -command {set col_ungapd_numeric 1; ColtoTab "yP" 5} -foreground black
		$d_2 add command -label "                           x3 = start position; x4 = end position; x5 = endtime" -command {set col_ungapd_numeric 1; ColtoTab "yP" 5} -foreground black
		$d_2 add command -label "Side-to-Side Panfile, Pinched: extreme-position times in input column: corresponding halfwidth, in output col" -command {set col_ungapd_numeric 1; VectorstoTab "yz" 4} -foreground black
		$d_2 add command -label "                           x1 = half-lingertime at pan-extreme; x2 = start position" -command {set col_ungapd_numeric 1; VectorstoTab "yz" 4} -foreground black
		$d_2 add command -label "                           x3 = end position; x4 = endtime" -command {set col_ungapd_numeric 1; VectorstoTab "yz" 4} -foreground black
		$d_2 add command -label "Time-Targeted Stretching: start and endtimes of stretched segments in input column" -command {set col_ungapd_numeric 1; ColtoTab "yx" 2} -foreground black
		$d_2 add command -label "                           x1 = time-step-from unstretched to stretched segments; x2 = stretch value" -command {set col_ungapd_numeric 1; ColtoTab "yx" 2} -foreground black
		$dero add command -label "Make Excise File in samples From Sample Position Of Clicks" -command {SpliceMak "SM" 4} -foreground black
		$dero add command -label "Extract Any Repeating Cycle Of Values In A Pattern" -command {Patex} -foreground black

#SEQUENCE MENU MENU
		set seqo [menu $gta.seq.seqs -tearoff 0]
#SUBSTITUTABLE
		$seqo add command -label "MODIFY PITCH" -command {}  -foreground black
		$seqo add separator ;# -background $evv(HELP)
		$seqo add command -label "Expand Pitch Intervals by factor 'N'" -command {TabMod "Wc"} -foreground black
		$seqo add command -label "Expand Pitch Intervals by factor 'N' using existing vals & their 8va equivalents only" -command {TabMod "WE"} -foreground black
		$seqo add command -label "Transpose by 'N' semitones" -command {TabMod "Wt"} -foreground black
		$seqo add command -label "Invert Pitch Contour" -command {TabMod "Wi"} -foreground black
		$seqo add command -label "Invert Pitch Contour using existing vals & their 8va equivalents only" -command {TabMod "WI"} -foreground black
		$seqo add separator ;# -background $evv(HELP)
		$seqo add command -label "MODIFY TIMING" -command {}  -foreground black
		$seqo add separator ;# -background $evv(HELP)
		$seqo add command -label "Change Tempo of events by multiplier N" -command {TabMod "Wm"} -foreground black
		$seqo add command -label "Accelerate Events so last is at (duration * N), accel-shape (>0 - 1: try 0.3) in 'threshold'" -command {TabMod "WM"} -foreground black
		$seqo add command -label "to Warp Time of events, using a brkpnt table, see JOIN menu" -command {} -foreground $evv(SPECIAL)
		$seqo add separator ;# -background $evv(HELP)
		$seqo add command -label "REVERSE SEQUENCE" -command {}  -foreground black
		$seqo add separator ;# -background $evv(HELP)
		$seqo add command -label "Reverse Specified Items In Sequence" -command Sequence_Reversal -foreground black
		$seqo add separator ;# -background $evv(HELP)
		$seqo add command -label "EXPAND SEQUENCE" -command {}  -foreground black
		$seqo add separator ;# -background $evv(HELP)
		$seqo add command -label "Repeat Sequence of events N times, with a gap of 'threshold'" -command {TabMod "Wl"} -foreground black
		$seqo add command -label "CONVERT FORMAT" -command {}  -foreground black
		$seqo add separator ;# -background $evv(HELP)
		$seqo add command -label "Convert Sequencer <--> Multi-Src Sequencer Format: N = sample midi, 'threshold' = orig ref midi" -command {TabMod "Sq"} -foreground black
		$seqo add command -label "" -command {} -foreground black
		$seqo add command -label "See JOIN menu, to join two different sequences" -command {} -foreground black

#BRKTABLE MENU MENU
		set brko [menu $gta.brk.brkk -tearoff 0]
#SUBSTITUTABLE
		$brko add command -label "MODIFY" -command {}  -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add cascade -label "Modify Times"   -menu $brko.sub1 -foreground black
		set b_1 [menu $brko.sub1 -tearoff 0]
		$b_1 add command -label "Quantise Table Times over the time quantum 'N'" -command {TabMod "qt"} -foreground black
		$b_1 add command -label "Scale All Times by factor 'N'" -command {TabMod "ef"} -foreground black
		$b_1 add command -label "Scale All Times, Giving Total Duration 'N'" -command {TabMod "et"} -foreground black
		$b_1 add command -label "Extend Final Value In Table to time 'N'" -command {TabMod "ex"} -foreground black
		$b_1 add command -label "Cut Off Table at time 'N'" -command {TabMod "ct"} -foreground black
		$b_1 add command -label "Reverse Sequence of timesteps" -command {set col_ungapd_numeric 1; MassageBrk "tr" 0} -foreground black
		$b_1 add command -label "Deglitch Envelope (N = min risetime mS)" -command {set col_ungapd_numeric 1; TabMod "Sk"} -foreground black
		$b_1 add command -label "To Warp Time, using a 2nd brkfile, see JOIN menu" -command {} -foreground $evv(SPECIAL)
		$brko add cascade -label "Modify Values"   -menu $brko.sub2 -foreground black
		set b_2 [menu $brko.sub2 -tearoff 0]
		$b_2 add command -label "Scale All Values by factor 'N'" -command {TabMod "ev"} -foreground black
		$b_2 add command -label "Limit Values To Maximum 'N' (minimum 'Threshold')" -command {TabMod "lv"} -foreground black
		$b_2 add command -label "Reverse Order of values" -command {set col_ungapd_numeric 1; MassageBrk "r" 0} -foreground black
		$b_2 add command -label "Invert Values in range 0-1 (e.g. envelopes, balance functions)" -command {set col_ungapd_numeric 1; MassageBrk "Iv" 0} -foreground black
		$b_2 add command -label "Invert Values In Range x1 to x2" -command {set col_ungapd_numeric 1; MassageBrk "yI" 2} -foreground black
		$b_2 add command -label "Invert Values About Pivot x1 (e.g. pan vals)" -command {set col_ungapd_numeric 1; MassageBrk "yp" 1} -foreground black
		$brko add cascade -label "Modify Table or Table Format"   -menu $brko.sub3 -foreground black
		set b_3 [menu $brko.sub3 -tearoff 0]
		$b_3 add command -label "Exponentialise The Slope, Concave (e.g. envelope)" -command {set col_ungapd_numeric 1; TabMod "EX"} -foreground black
		$b_3 add command -label "Exponentialise The Slope, Convex (e.g. envelope)" -command {set col_ungapd_numeric 1; TabMod "Ex"} -foreground black
		$b_3 add command -label "Derive Cosinusoidal Sweeps From 0/1 Values" -command "TabMod co" -foreground black
		$b_3 add separator
		$b_3 add command -label "Convert Spatial Position Vals From Pan Format To Texture Format" -command {set col_ungapd_numeric 1; MassageBrk "Ys" 0} -foreground black
		$b_3 add command -label "Convert Spatial Position Vals From Texture Format To Pan Format" -command {set col_ungapd_numeric 1; MassageBrk "YS" 0} -foreground black
		$b_3 add command -label "Convert Balance Format To Balance-many Format" -command {set col_ungapd_numeric 1; MassageBrk "BC" 0} -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "OPERATIONS AT CURSOR" -command {}  -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "Insert value N At Intermediate Time Before cursor position" -command {RowInsertBrk 1}  -foreground black
		$brko add command -label "Insert value N At Intermediate Time After cursor position" -command {RowInsertBrk 0} -foreground black
		$brko add command -label "Move N values (At and Beyond Cursor) by 'threshold' in time" -command {RowsJiggleBrk m}  -foreground black
		$brko add command -label "Exponential Transition To Next Row: curve given by N (>0)" -command {RowInsert 2} -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "SLICING OPERATIONS" -command {}  -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "get times where N Cuts The Trajectory of the value graph" -command {MassageBrk "tc" 0} -foreground black
		$brko add command -label "get times where the Values Lie In The Range x1 to x2" -command {MassageBrk "bb" 2} -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "COLUMN SEPARATION" -command {}  -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "Display Both Columns of a time/value brktable file." -command {GetDblColFromTable} -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "GENERATE TAILORED CONTROL FILES" -command {}  -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "Side-to-Side Panfile, Pinched: extreme-position times & corresponding halfwidth" -command {MassageBrk "yQ" 4} -foreground black
		$brko add command -label "                           paired in input table" -command {MassageBrk "yQ" 4} -foreground black
		$brko add command -label "                           x1 = half-lingertime at pan-extreme; x2 = start position" -command {MassageBrk "yQ" 4} -foreground black
		$brko add command -label "                           x3 = end position; x4 = endtime" -command {MassageBrk "yQ" 4} -foreground black
		$brko add command -label "" -command {} -foreground black
		$brko add command -label "Most TABLE processes can be applied to brktables." -command {} -foreground $evv(SPECIAL)
		$brko add command -label "ENVEL processes can be applied to brktables with values in range 0 to 1." -command {} -foreground $evv(SPECIAL)
		$brko add command -label "Most COLUMN processes can be applied to columns extracted from a brktable." -command {} -foreground $evv(SPECIAL)
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "ADD VALUE PAIR AT END OF BREAKPOINT FILE" -command {}  -foreground black
		$brko add separator ;# -background $evv(HELP)
		$brko add command -label "Add Value N At Time Zero" -command {EnvOp "bB"} -foreground black
		$brko add command -label "Add Value N Beyond End Time" -command {EnvOp "bE"} -foreground black
		$brko add command -label "" -command {} -foreground black

#FORMAT MENU
		set foro [menu $gt3.for.format -tearoff 0]
#SUBSTITUTABLE
		$foro add command -label "REFORMAT NUMERIC DATA" -command {}  -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add cascade -label "To Rows" -menu $foro.sub1 -foreground black
		set f_1 [menu $foro.sub1 -tearoff 0]
		$f_1 add command -label "Format Col Output to N rows" -command {ColFormat "o"} -foreground black
		$f_1 add command -label "Format Col Input to N rows"	-command {ColFormat "i"} -foreground black
		$foro add cascade -label "To Columns" -menu $foro.sub2 -foreground black
		set f_2 [menu $foro.sub2 -tearoff 0]
		$f_2 add command -label "Format Col Output to N columns"	-command {ColFormat "ro"} -foreground black
		$f_2 add command -label "Format Col Input to N columns" -command {ColFormat "ri"} -foreground black
		$foro add command -label "Convert To Engineering Notation" -command {GenerateNewColumn "Ee" 0} -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add command -label "REFORMAT TEXT DATA" -command {}  -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add cascade -label "To Rows" -menu $foro.sub3 -foreground black
		set f_3 [menu $foro.sub3 -tearoff 0]
		$f_3 add command -label "Format Col Output to N rows" -command {ColFormat "To"} -foreground black
		$f_3 add command -label "Format Col Input to N rows"	-command {ColFormat "Ti"} -foreground black
		$foro add cascade -label "To Columns" -menu $foro.sub4 -foreground black
		set f_4 [menu $foro.sub4 -tearoff 0]
		$f_4 add command -label "Format Col Output to N columns"	-command {ColFormat "Tro"} -foreground black
		$f_4 add command -label "Format Col Input to N columns" -command {ColFormat "Tri"} -foreground black
		$foro add command -label "Convert From Engineering Notation" -command {GenerateNewColumn "Eex" 0} -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add command -label "UNRAVEL MIXED NUMERIC AND TEXT DATA" -command {}  -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add command -label "Remove Leading Text (flag) in any entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "kT" 0} -foreground black
		$foro add command -label "Remove Trailing Text in any entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "kX" 0} -foreground black
		$foro add command -label "Remove All Text in any entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "kY" 0} -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add command -label "EDIT TEXT IN FILENAMES" -command {}  -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add cascade -label "Edit Text In Filenames" -menu $foro.sub6 -foreground black
		set f_6 [menu $foro.sub6 -tearoff 0]
		$f_6 add command -label "Remove Directory Path in any entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "kA" 0} -foreground black
		$f_6 add command -label "Remove File Extension in any entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "kB" 0} -foreground black
		$f_6 add command -label "Remove Path And Extension in any entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "kC" 0} -foreground black
		$f_6 add command -label "Add Directory Name (N) to each entry" -command {set col_ungapd_numeric 1; ExtCol d} -foreground black
		$f_6 add command -label "Append Text (N) Before File Rootname in each entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "Fs" 0} -foreground black
		$f_6 add command -label "Append Text (N) After File Rootname in each entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "Fe" 0} -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add command -label "EDIT TEXT ENTRIES IN A COLUMN OF TEXT VALUES" -command {}  -foreground black
		$foro add separator ;# -background $evv(HELP)
		$foro add cascade -label "Edit Text Entries" -menu $foro.sub5 -foreground black
		set f_5 [menu $foro.sub5 -tearoff 0]
		$f_5 add command -label "Append Text (N) Before each entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "aT" 0} -foreground black
		$f_5 add command -label "Append Text (N) After each entry" -command {set col_ungapd_numeric 1; GenerateNewColumn "aX" 0} -foreground black
		$f_5 add command -label "Insert Text (N) Within each entry at position 'Threshold'" -command {set col_ungapd_numeric 1; InsText} -foreground black
		$f_5 add command -label "Remove Text specified at 'N'" -command {set col_ungapd_numeric 1; KillText "kC"} -foreground black
		$f_5 add command -label "Remove Text Beyond Item specified at 'N'" -command {set col_ungapd_numeric 1; KillText "kD"} -foreground black
		$f_5 add command -label "Remove Text Beyond And Including Item specified at 'N'" -command {set col_ungapd_numeric 1; KillText "kE"} -foreground black
		$f_5 add command -label "Remove Text Up To Item specified at 'N'" -command {set col_ungapd_numeric 1; KillText "kF"} -foreground black
		$f_5 add command -label "Remove Text Up To And Including Item specified at 'N'" -command {set col_ungapd_numeric 1; KillText "kG"} -foreground black
		$f_5 add command -label "Remove Last N Characters" -command {set col_ungapd_numeric 1; KillText "EN"} -foreground black
		$f_5 add command -label "Substitute Text In 'N' By Text In Threshold" -command {set col_ungapd_numeric 1; GenerateNewColumn "kH" 0} -foreground black
		$f_5 add command -label "Get Numeric Part Only" -command {set col_ungapd_numeric 1; GenerateNewColumn "kI" 0} -foreground black

#JOIN FILES MENU
		set joio [menu $gta.joi.join -tearoff 0]
#SUBSTITUTABLE
		$joio add command -label "CONCATENATE DATA" -command {}  -foreground black
		$joio add separator
		$joio add cascade -label "Concatenate Data" -menu $joio.sub1 -foreground black
		$joio add cascade -label "Order File 1 Using File 2"  -menu $joio.sub11 -foreground black
		set j_11 [menu $joio.sub11 -tearoff 0]
		$j_11 add command -label "Sort File1 So Col 'N' File1 Is Same Order As Col 'threshold' File2" -command {ColJoin "ss"} -foreground black
		$j_11 add command -label "Eliminate File1 Row If Item In Col 'N' Is Anywhere In Col 'threshold' File2" -command {ColJoin "E"} -foreground black
		$j_11 add command -label "Eliminate File1 Row If Item In Col 'N' Is Not In Col 'threshold' File2" -command {ColJoin "En"} -foreground black
		$joio add command -label "Rename Wkspace Soundfiles In File1 With Names In File2" -command {ColJoin "rf"} -foreground black
		set j_1 [menu $joio.sub1 -tearoff 0]
		$j_1 add command -label "ANY NUMBER OF ROWS OR COLUMNS" -command {}  -foreground black
		$j_1 add separator
		$j_1 add command -label "All Rows Of One File Before All Rows Of Next" -command {ColJoin "Wd"} -foreground black
		$j_1 add command -label "Interleave The Rows Of The Files" -command {ColJoin "WD"} -foreground black
		$j_1 add command -label "Concatenate All Files To Single Column" -command {ColJoin "C"} -foreground black
		$j_1 add command -label "Concatenate, Selecting Items Cyclically" -command {ColJoin "Cc"} -foreground black
		$j_1 add separator
		$j_1 add command -label "SAME NUMBER OF ROWS" -command {}  -foreground black
		$j_1 add separator
		$j_1 add command -label "Put Cols Of One Next To Cols Of Other" -command {ColJoin "J"} -foreground black
		$j_1 add command -label "Insert Cols Of One After Col N Of Other" -command {ColJoin "Jj"} -foreground black
		$j_1 add separator
		$j_1 add command -label "SAME NUMBER OF COLUMNS" -command {}  -foreground black
		$j_1 add separator
		$j_1 add command -label "Put Rows Of One Below Rows Of Other" -command {ColJoin "jj"} -foreground black
		$j_1 add command -label "Put Rows Of One Below Row N Of Other" -command {ColJoin "j"} -foreground black
		$j_1 add command -label "Cyclically Substitute File1 Lines By File2 Lines" -command {}  -foreground black
		$j_1 add command -label "Substitute Every Nth Line, Starting At Line 'threshold'" -command {ColJoin "Su"} -foreground black
		$joio add cascade -label "Envelopes (Normalised) Combine" -menu $joio.sub2 -foreground black
		set j_2 [menu $joio.sub2 -tearoff 0]
		$j_2 add command -label "APPEND 2ND ENVELOPE TO 1ST" -command {}  -foreground black
		$j_2 add separator
		$j_2 add command -label "...At Time N Beyond End Of 1st, " -command {ColJoin "Za"} -foreground black
		$j_2 add separator
		$j_2 add command -label "Abutt Env Files (Times Must Increase From 1st To 2nd)" -command {ColJoin "Ae"} -foreground black
		$j_2 add separator
		$j_2 add command -label "SUPERIMPOSE" -command {}  -foreground black
		$j_2 add separator
		$j_2 add command -label "Superimpose 2nd Env On 1st" -command {ColJoin "Zs"} -foreground black
		$j_2 add separator
		$j_2 add command -label "..but Start Superimpose At Time N" -command {ColJoin "es"} -foreground black
		$j_2 add separator
		$j_2 add command -label "Inverse Of 2nd Env On 1st" -command {ColJoin "Zi"} -foreground black
		$j_2 add separator
		$j_2 add command -label "..but Start Superimpose At Time N" -command {ColJoin "ei"} -foreground black

		$joio add cascade -label "Breakpoint Data : Combine " -menu $joio.sub3 -foreground black
		set j_3 [menu $joio.sub3 -tearoff 0]
		$j_3 add command -label "Append Brkdata 2 To Brkdata 1" -command {}  -foreground black
		$j_3 add separator
		$j_3 add command -label "...at Time N Beyond End Of Brkdata1" -command {ColJoin "ea"} -foreground black
		$j_3 add separator
		$j_3 add command -label "Abutt Brk Files (Times Must Increase From 1st To 2nd)" -command {ColJoin "Ab"} -foreground black
		$j_3 add separator
		$j_3 add command -label "COMBINE BRKDATA " -command {}  -foreground black
		$j_3 add command -label "(if N specified, Start combine action at time N)" -command {}  -foreground black
		$j_3 add command -label "Add 2nd To 1st" -command {ColJoin "eA"} -foreground black
		$j_3 add command -label "Subtract 2nd From 1st" -command {ColJoin "eS"} -foreground black
		$j_3 add command -label "multiply 1st By 2nd" -command {ColJoin "eM"} -foreground black
		$j_3 add command -label "Take Maximum At Any Time" -command {ColJoin "em"} -foreground black
		$joio add separator
		$joio add command -label "MIXFILES" -command {}  -foreground black
		$joio add separator
		$joio add cascade -label "Merge Two" -menu $joio.sub8
		set j_8 [menu $joio.sub8 -tearoff 0]
		$j_8 add command -label "2nd Starts As 1st Ends" -command {MergeMixfiles 2} -foreground black
		$j_8 add command -label "2nd Starts At Offset 'N'" -command {MergeMixfiles 0} -foreground black
		$j_8 add separator
		$j_8 add command -label "1st Snd Of Mix-2 Becomes Last Snd Of Mix-1" -command {MergeMixfiles 1} -foreground black
		$joio add cascade -label "Move Times To Coincide With Sound Peaks" -menu $joio.sub7 -foreground black
		set j_7 [menu $joio.sub7 -tearoff 0]
		$j_7 add command -label "Using Peak-Offsets From Start, In 2nd File" -command {SyncMidships 2} -foreground black
		$j_7 add command -label "Using Peak Offsets From End, In 2nd File" -command {SyncMidships 1} -foreground black
		$j_7 add command -label "Using Soundfile Durations And Peak Offsets" -command {RepositionMixtimes} -foreground black
		$j_7 add command -label "                          More Information" -command {InfoRepositionMixtimes} -foreground $evv(SPECIAL)

		$joio add separator
		$joio add command -label "Exclude Sounds In 2nd Mix From 1st Mix" -command {ColJoin "mm"} -foreground black
		$joio add separator
		$joio add command -label "BATCHFILES (ETC)" -command {} ;# -background $evv(HELP) -foreground black
		$joio add separator
		$joio add command -label "Duplicate File1 Rows, Indexing Copies With Vals In File2" -command {IndexedDuplication "id" 2} -foreground black
		$joio add separator
		$joio add command -label "SEQUENCE FILES"  -command {}  -foreground black
		$joio add separator
		$joio add command -label "Join Two (single-sound) Sequences, time N(>=0) apart" -command {ColJoin "Wb"} -foreground black
		$joio add command -label "Join Two Multisound Sequences, time N(>=0) apart" -command {ColJoin "Kb"} -foreground black
		$joio add separator
		$joio add command -label "WARP DATA OR TIME WITH WARPFILE"  -command {}  -foreground black
		$joio add separator
		$joio add cascade -label "Timewarp Times" -menu $joio.sub4 -foreground black
		set j_4 [menu $joio.sub4 -tearoff 0]
		$j_4 add command -label "Timewarp A List Of Times" -command {ColJoin "ew"} -foreground black
		$j_4 add command -label "Timewarp Timings Of A Brkpoint File" -command {ColJoin "eW"} -foreground black
		$j_4 add command -label "...ditto, Warp Times Are Outfile Times" -command {ColJoin "eY"} -foreground black
		$j_4 add command -label "Timewarp Timings Of A Sequence File" -command {ColJoin "eQ"} -foreground black
		$j_4 add command -label "Timewarp Timings Of A Mixfile" -command {ColJoin "eZ"} -foreground black
		$joio add cascade -label "Warp Values" -menu $joio.sub4a -foreground black
		$joio add command -label "                          More Information" -command {CDP_Specific_Usage $evv(TE_25) 0} -foreground $evv(SPECIAL)
		set j_4a [menu $joio.sub4a -tearoff 0]
		$j_4a add command -label "Warp Values In A List" -command {ColJoin "eL"} -foreground black
		$j_4a add command -label "Warp Values In A Brkpoint File" -command {ColJoin "eX"} -foreground black
		$j_4a add command -label "Warp Levels In A Mixfile" -command {ColJoin "mX"} -foreground black
		$joio add cascade -label "Calculate Results Of Timewarping" -menu $joio.sub5 -foreground black
		set j_5 [menu $joio.sub5 -tearoff 0]
		$j_5 add command -label "New Val Of Times In File2 When Stretched By File 1" -command {ColJoin "wt"} -foreground black
		$j_5 add command -label "Offset Of Times In File2 (from Orig), When Stretched By File 1" -command {ColJoin "wo"} -foreground black
		$joio add separator
		$joio add command -label "OTHER"  -command {}  -foreground black
		$joio add separator
		$joio add command -label "Create A Vectored Batchfile" -command {set col_ungapd_numeric 1; VectoredBatchfile "vB"} -foreground black
		$joio add command -label "                          More Information" -command {VectoredBatchfileHelp} -foreground $evv(SPECIAL)
		$joio add command -label "Extend Batch Process To New Files" -command {set col_ungapd_numeric 1; BatchfileExtend "Be"} -foreground black
		$joio add command -label "Process Transformations Pairs With Batchfiles" -command {set col_ungapd_numeric 1; AssembleTransformBatch} -foreground black
		$joio add command -label "                          More Information" -command {TransformationBatchfileHelp} -foreground $evv(SPECIAL)
		$joio add command -label "Keep The Listed Filenames To Put In A Textfile" -command {ColJoin "kf"} -foreground black


#TABLES MENU OLD
		set tabo [menu $gta.tab.tabs -tearoff 0]
#SUBSTITUTABLE
		$tabo add command -label "CREATE" -command {}  -foreground black
		$tabo add separator ;# -background $evv(HELP)
		$tabo add cascade -label "Create Data" -menu $tabo.sub0 -foreground black
		set t_0 [menu $tabo.sub0 -tearoff 0]
		$t_0 add command -label "FROM SOUNDVIEW DISPLAY" -command {}  -background $evv(HELP) -foreground black
		$t_0 add separator -background $evv(HELP)
		$t_0 add cascade -label "Create Output Table from Soundview Display" -command {TabSnack} -foreground black
		$t_0 add separator -background $evv(HELP)
		$t_0 add command -label "BY TYPING TEXT" -command {}   -foreground black
		$t_0 add separator ;# -background $evv(HELP)
		$t_0 add command -label "Create Output Table, by writing values directly" -command {TabMake o} -foreground black
		$t_0 add command -label "Create Input Table, by writing values directly" -command {TabMake i} -foreground black
		$t_0 add separator ;# -background $evv(HELP)
		$t_0 add command -label "GENERATE SPECIFIC TYPES OF DATA" -command {}   -foreground black
		$t_0 add separator ;# -background $evv(HELP)
		$t_0 add command -label "Create Simple Envelope off/on/off, total duration x1, dovetails x2" -command {BrkMak} -foreground black
		$t_0 add separator
		$t_0 add command -label "Create Pan Back/Forth File inner halfwidth x1 outer halfwidth x2 startpos x3" -command {TabMake pp} -foreground black
		$t_0 add command -label "proportion of time spent at edges x4 time for back-forth pass x5 total duration x6" -command {TabMake pp} -foreground black
		$t_0 add command -label "starting by moving leftwards x7 = 1 (else = 0)" -command {TabMake pp} -foreground black
		$t_0 add separator
		$t_0 add command -label "Create x1 Pseudo Exponential Steps: (x1=multiple of 2) between times x2 & x3, vals x4 & x5" -command {TabMake ze} -foreground black
		$tabo add separator ;# -background $evv(HELP)
		$tabo add command -label "GET" -command {}  -foreground black
		$tabo add separator ;# -background $evv(HELP)
		$tabo add command -label "Get Both Columns From A Table" -command {set col_ungapd_numeric 0; GetBothColumnsFromATable} -foreground black
		$tabo add command -label "Get Last Run Information as a table" -command {set col_ungapd_numeric 0; TabRunMsgs} -foreground black
		$tabo add separator ;# -background $evv(HELP)
		$tabo add command -label "DELETE, KEEP, DUPLICATE, SORT" -command {}  -foreground black
		$tabo add separator ;# -background $evv(HELP)
		$tabo add cascade -label "Delete/Keep Columns" -menu $tabo.sub1 -foreground black
		set t_1 [menu $tabo.sub1 -tearoff 0]
		$t_1 add command -label "Delete Column N from table" -command {ColDelete 0} -foreground black
		$t_1 add command -label "Keep First N Columns of table" -command {ColDelete 1} -foreground black
		$t_1 add command -label "Keep Last N Columns of table" -command {ColDelete 2} -foreground black
		$tabo add cascade -label "Delete/Keep Rows" -menu $tabo.sub2 -foreground black
		set t_2 [menu $tabo.sub2 -tearoff 0]
		$t_2 add command -label "Delete Row N from table" -command {RowDelete 0} -foreground black
		$t_2 add command -label "Keep First N Rows of table" -command {RowDelete 1} -foreground black
		$t_2 add command -label "Keep Last N Rows of table" -command {RowDelete 2} -foreground black
		$t_2 add command -label "Delete All Comments And Blank Lines" -command {RowDelete 9} -foreground black
		$t_2 add command -label "Delete N Rows At Random" -command {RowDelete 10} -foreground black
		$t_2 add command -label "Delete Duplicated Rows" -command {RowDelete 11} -foreground black
		$t_2 add command -label "Delete Adjacent Duplicated Rows" -command {RowDelete 12} -foreground black
		$t_2 add command -label "Delete Adjacent Rows Duplicated After 1st Col" -command {RowDelete 13} -foreground black
		$tabo add cascade -label "Duplicate"  -menu $tabo.sub5 -foreground black
		set t_5 [menu $tabo.sub5 -tearoff 0]
		$t_5 add command -label "Duplicate All Rows, N times" -command {TabDupl 0} -foreground black
		$t_5 add command -label "Duplicate All Rows, Numerically Indexing The Copied Contents" -command {IndexedDuplication "ID" 3} -foreground black
		$t_5 add command -label "Duplicate Rows N Times, omitting 1st value of repeated rows" -command {TabPattern "ZZD"} -foreground black
		$t_5 add command -label "Duplicate At Time-steps of 'Threshold', all rows, N times, " -command {TabDupl 1} -foreground black
		$t_5 add command -label "Duplicate In Pattern start row x1,step by x2 rows, x3 times, then baktrak by x4, stop at row x5" -command {TabPattern "ZZA"} -foreground black
		$t_5 add command -label "Add Rows In Reverse Order To End Of Existing Rows" -command {TabPattern "ZZB"} -foreground black
		$t_5 add command -label "Add Rows In Reverse Order To End Of Existing Rows, omitting 1st value of reversed row" -command {TabPattern "ZZC"} -foreground black
		$tabo add cascade -label "Sort, Invert Or Rotate  Rows"  -menu $tabo.sub12 -foreground black
		set t_12 [menu $tabo.sub12 -tearoff 0]
		$t_12 add command -label "Sort Rows Numerically  by vals in column N" -command {RowSort} -foreground black
		$t_12 add command -label "Sort Rows Alphabetically by entries in column N" -command {RowAlphaSort} -foreground black
		$t_12 add command -label "Keep Rows If vals In Col x1 are in Range x2 to x3" -command {TabMod rr} -foreground black
		$t_12 add command -label "Invert Order of rows" -command {RowInvert} -foreground black
		$t_12 add command -label "Rotate Bottom (N) item(s) To Top" -command {RowRotate 0} -foreground black
		$t_12 add command -label "Rotate Top (N) item(s) To Bottom" -command {RowRotate 1} -foreground black
		$tabo add cascade -label "Swap Rows Or Columns,            Or Exchange Data Between Them"  -menu $tabo.sub13 -foreground black
		set t_13 [menu $tabo.sub13 -tearoff 0]
		$t_13 add command -label "ROWS" -command {}  -foreground black
		$t_13 add command -label "Swap Row 'N' With Row 'threshold'" -command {RowSwap 0} -foreground black
		$t_13 add command -label "COLUMNS" -command {}  -foreground black
		$t_13 add command -label "Swap Column 'N' With Column 'threshold'" -command {RowSwap 1} -foreground black
		$t_13 add command -label "Replace Data In Column 'N' With Data In Column 'threshold'" -command {RowSwap 2} -foreground black
		$t_13 add command -label "Replace Numeric Part Of Data In Column 'N' With Data In Column 'threshold'" -command {RowSwap 3} -foreground black
		$tabo add cascade -label "Random Operations"  -menu $tabo.sub6 -foreground black
		set t_6 [menu $tabo.sub6 -tearoff 0]
		$t_6 add command -label "Randomise Order Of Rows" -command {RowRandomise 0} -foreground black
		$t_6 add command -label "Randomise Order Of Rows in groups of N" -command {RowRandomise 1} -foreground black
		$t_6 add command -label "One Item From Each Row, Random Column Choice" -command {RandColSelect 0} -foreground black
		$t_6 add command -label "One Item From Each Column, Random Row Choice" -command {RandColSelect 1} -foreground black
		$tabo add cascade -label "Cyclic Selection or Modification Of Items In List" -menu $tabo.sub11 -foreground black
		set t_11 [menu $tabo.sub11 -tearoff 0]
		$t_11 add command -label "LIST OF LINES OF DATA (OR SINGLE ITEMS)" -command {}  -foreground black
		$t_11 add separator ;# -background $evv(HELP)
		$t_11 add command -label "Select Every Nth Item To Output Table Starting At threshold" -command {Cyclics gettab} -foreground black
		$t_11 add command -label "Remove Every Kth Item" -command {set col_ungapd_numeric 1; NameGames delfiles}	  -foreground black
		$t_11 add separator ;# -background $evv(HELP)
		$t_11 add command -label "LIST OF SINGLE ITEMS" -command {}  -foreground black
		$t_11 add separator ;# -background $evv(HELP)
		$t_11 add command -label "Select Every Kth Item To Input Column" -command {Cyclics get} -foreground black
		$t_11 add command -label "Substitute New Item At Every Kth" -command {set col_ungapd_numeric 1; NameGames subfiles}	  -foreground black
		$t_11 add command -label "Replace Every Kth Item With Items In Output Column" -command {Cyclics put} -foreground black

		$tabo add separator ;# -background $evv(HELP)
		$tabo add command -label "FORMAT DATA" -command {}  -foreground black
		$tabo add separator ;# -background $evv(HELP)
		$tabo add cascade -label "Reformat Data" -menu $tabo.sub3 -foreground black
		set t_3 [menu $tabo.sub3 -tearoff 0]
		$t_3 add command -label "Rows Become Columns : Columns become rows" -command {ColsBecomeRows} -foreground black
		$t_3 add separator ;# -background $evv(HELP)
		$t_3 add command -label "READING NUMERIC DATA:   ROW1 LEFT->RIGHT, ROW2 ETC: " -command {}  -foreground black
		$t_3 add separator ;# -background $evv(HELP)
		$t_3 add command -label "Format To N Rows:          write Row1 left->right, Row2 etc." -command {ColFormat "t"} -foreground black
		$t_3 add command -label "Format To N Columns:     write Row1 left->right, Row2 etc." -command {ColFormat "rT"} -foreground black
		$t_3 add command -label "Format To N Columns:     write Col1 top->bottom, Col2 etc." -command {ColFormat "rt"} -foreground black
		$t_3 add separator ;# -background $evv(HELP)
		$t_3 add command -label "READING TEXT DATA:   ROW1 LEFT->RIGHT, ROW2 ETC: " -command {}  -foreground black
		$t_3 add separator ;# -background $evv(HELP)
		$t_3 add command -label "Format To N Rows:          write Row1 left->right, Row2 etc." -command {ColFormat "Tt"} -foreground black
		$t_3 add command -label "Format To N Columns:     write Row1 left->right, Row2 etc." -command {ColFormat "TrT"} -foreground black
		$t_3 add command -label "Format To N Columns:     write Col1 top->bottom, Col2 etc." -command {ColFormat "Trt"} -foreground black
		$tabo add command -label "Global Edit: Replace Text In 'N' By Text In 'Threshold'" -command {GlobalEditTable} -foreground black
		$tabo add cascade -label "Partition Data Into Files Of Generic Name 'N'"  -menu $tabo.sub14 -foreground black
		set t_14 [menu $tabo.sub14 -tearoff 0]
		$t_14 add command -label "Files Of Line-Count 'threshold'" -command {SplitTable "yt"} -foreground black
		$t_14 add command -label "Partition At Marker 'threshold'" -command {SplitTable "xt"} -foreground black
		$t_14 add command -label "HF Statistics By Harmonic Clustering" -command {SplitTable "hh"} -foreground black

		$tabo add separator ;# -background $evv(HELP)
		$tabo add command -label "SPECIFIC DATA TYPES" -command {}  -foreground black
		$tabo add command -label "Input tables for these processes can be created above" -command {} -foreground $evv(SPECIAL)
		$tabo add separator ;# -background $evv(HELP)

		$tabo add cascade -label "Play Pitch Data As Chords" -menu  $tabo.sub17 -foreground black
		$tabo add cascade -label "Frq Data <-> Midi Data: + Smooth,Quantise,VocRange" -menu  $tabo.sub18 -foreground black
		$tabo add command -label "Remove N Lines Of Pitch Data, Including Highlighted Line" -command {TabMod CR} -foreground black
		$tabo add cascade -label "Frq And Midi To Tempered Values" -menu $tabo.sub19 -foreground black
		set t_19 [menu $tabo.sub19 -tearoff 0]
		$t_19 add command -label "Temper Frqs (to N-note scale) (around reference frq 'threshold')" -command {QuantiseBrk "Th"} -foreground black
		$t_19 add command -label "Temper Midi Vals (to N-note scale) (around reference midival 'threshold')"	-command {QuantiseBrk "TM"} -foreground black
		$t_19 add command -label "Temper Frqs To Just Intonation around reference frq 'N'" -command {QuantiseBrk "Zh"} -foreground black
		$t_19 add command -label "Temper Midi Vals To Just Intonation around reference frq 'N'"	-command {QuantiseBrk "ZM"} -foreground black
		$t_19 add separator
		$tabo add cascade -label "Frq And Midi To Sustained Tempered Values" -menu $tabo.sub20 -foreground black
		set t_20 [menu $tabo.sub20 -tearoff 0]
		$t_20 add command -label "Temper Frqs (to N-note scale) (around reference frq 'threshold')" -command {QuantiseBrk "ThS"} -foreground black
		$t_20 add command -label "Temper Midi Vals (to N-note scale) (around reference midival 'threshold')"	-command {QuantiseBrk "TMS"} -foreground black
		$t_20 add command -label "Temper Frqs To Just Intonation around reference frq 'N'" -command {QuantiseBrk "ZhS"} -foreground black
		$t_20 add command -label "Temper Midi Vals To Just Intonation around reference frq 'N'"	-command {QuantiseBrk "ZMS"} -foreground black
		$t_20 add separator
		$t_20 add command -label "Remove Ornaments From Sustained Data"	-command {QuantiseBrk "NO"} -foreground black

		set t_17 [menu $tabo.sub17 -tearoff 0]
		$t_17 add command -label "Play Frequencies List, As Chord" -command {PlayChordset 0 8} -foreground black
		$t_17 add command -label "Play Midi List (possibly fractional), As Chord" -command {PlayChordset 0 7} -foreground black
		$t_17 add command -label "Play Midi Chord Sequence (separate by '#')" -command {PlayChordset 0 9} -foreground black
		$t_17 add command -label "Play Midi Row Selected By Cursor" -command {PlayChordset 0 10} -foreground black
		set t_18 [menu $tabo.sub18 -tearoff 0]
		$t_18 add cascade -label "Frq, Quantise & Smooth" -command {TabMod "sR"} -foreground black
		$t_18 add cascade -label "Frq, Quantise, Smooth & Remove Nonvocal Range" -command {TabMod "Sv"} -foreground black
		$t_18 add cascade -label "Frq, Smooth & Remove Nonvocal Range" -command {TabMod "Xv"} -foreground black
		$t_18 add cascade -label "Frq, Smooth & Remove MIDI-Specified Range" -command {TabMod "Tsm"} -foreground black
		$t_18 add separator
		$t_18 add cascade -label "Frq -> Midi (Removing Zeros)" -command {TabMod "Sr"} -foreground black
		$t_18 add cascade -label "Frq -> Quantised Midi, Smoothed" -command {TabMod "SR"} -foreground black
		$t_18 add cascade -label "Frq -> Quantised Midi, Smoothed & Nonvocal Range Removed" -command {TabMod "SV"} -foreground black
		$t_18 add cascade -label "Frq -> Quantised Midi In Multi-Instr Sequencer File" -command {TabMod "SRM"} -foreground black
		$t_18 add separator
		$t_18 add cascade -label "Frq -> Notatable Timed-Midi, Smoothed" -command {TabMod "ZR"} -foreground black
		$t_18 add cascade -label "Frq -> Notatable Timed-Midi, Quantised, Smoothed, & Nonvocal Range Removed" -command {TabMod "ZV"} -foreground black
		$t_18 add separator
		$t_18 add cascade -label "Frq -> Untimed Quantised Midi Sequence, Smoothed" -command {TabMod "sr"} -foreground black
		$t_18 add cascade -label "Frq -> Untimed Quantised Midi, Smoothed, & Nonvocal Range Removed" -command {TabMod "sV"} -foreground black
		$t_18 add separator
		$t_18 add cascade -label "Frq : Quantised Data Only: -> Envelope For Staccato" -command {TabMod "Qs"} -foreground black
		$t_18 add separator
		$t_18 add cascade -label "Midi  Quantise & Smooth" -command {TabMod "sM"} -foreground black
		$t_18 add cascade -label "Midi, Quantise, Smooth & Remove Nonvocal Range" -command {TabMod "Sm"} -foreground black
		$t_18 add command -label "Midi, Smooth Pitch Excursions briefer than 'N'" -command {TabMod "S"}		 -foreground black
		$t_18 add separator
		$t_18 add cascade -label "Midi -> Notatable Timed-midi" -command {TabMod "xm"} -foreground black
		$t_18 add cascade -label "Midi -> Notatable Timed-midi, Quantise & Smooth" -command {TabMod "xM"} -foreground black
		$t_18 add cascade -label "Midi -> Notatable Timed-midi, Quantise, Smooth & Remove Nonvocal Range" -command {TabMod "Xm"} -foreground black
		$t_18 add separator
		$t_18 add cascade -label "Midi : Notatable Timed-midi -> Untimed Midi" -command {TabMod "ZM"} -foreground black
		$t_18 add cascade -label "Midi : Notatable Timed-midi -> Timed Midi, Duration N" -command {TabMod "zm"} -foreground black
		$t_18 add separator
		$t_18 add cascade -label "Midi -> Frq" -command {TabMod "mf"} -foreground black
		$t_18 add cascade -label "Midi -> Frq, Removing Nonvocal Range" -command {TabMod "mF"} -foreground black
		$tabo add cascade -label "Derive Edit Data From Listed Timings" -menu $tabo.sub15 -foreground black
		$t_18 add separator
		$t_18 add command -label "                          More Information" -command HelpFrqMidi -foreground $evv(SPECIAL)
		set t_15 [menu $tabo.sub15 -tearoff 0]
		$t_15 add command -label "Convert Times A:B:C:D...(in a Table) To Overlapping Edits A-N to B+N : B-N to C+N etc" -command {ColFormat "sE"} -foreground black
		$t_15 add command -label "Convert Times A:B:C:D...(in a Table) To Edit Slice File 0 to A : A to B ...  N to End" -command {ColFormat "sS"} -foreground black
		$t_15 add command -label "Invert Edit List : Convert A-B, C-D, E-F etc to B-C, D-E etc" -command {ColFormat "iE"} -foreground black
		$t_15 add command -label "" -command {} -foreground black
		$t_15 add command -label "Make Batchfile To Cut Sound At Zero-Crossings Near Times Listed In A Table" -command {Zcuts 0} -foreground black
		$t_15 add command -label "Make Batchfile To Cut Sound At Zero-crossings Near (Grouped) Sample Counts Listed In A Table" -command {Zcuts 1} -foreground black
		$tabo add cascade -label "Mixfiles, Rhythm Ideals" -menu $tabo.sub7 -foreground black
		set t_7 [menu $tabo.sub7 -tearoff 0]
		$t_7 add command -label "Mixfiles" -command {} -foreground black
		$t_18 add separator
		$t_7 add command -label "Make Basic Mixfile (sync at zero) using input table List Of Soundfiles" -command {MixMak 2} -foreground black
		$t_7 add command -label "Make Basic Mixfile (end to end) using input table List Of Soundfiles" -command {MixMak 3} -foreground black
		$t_7 add command -label "Make Basic Mixfile (end to end) using Pattern Table and Chosen List Sounds" -command {MixMak 4} -foreground black
		$t_7 add command -label "Make Pseudo-Mixfile Using Input Table Times: for sound named 'N', channel count 'threshold'" -command {MixMak 0} -foreground black
		$t_7 add command -label "Make Pseudo-Mixfile With Numeric-indices: 'N'=generic sndfilename: indices (from 0) added at end" -command {MixMak 1} -foreground black
		$t_7 add command -label "Modify Mixfile So That Moments 'N' secs From Snd End (e.g. peaks) Lie At Orig Times" -command {SyncMidships 0} -foreground black
		$t_7 add command -label "Randomise Sound Order so any Offsets From original regular Time Pattern Remain" -command {RandomiseWithVariance} -foreground black
		$t_18 add separator
		$t_7 add command -label "Rhythm Ideals" -command {} -foreground black
		$t_7 add separator
		$t_7 add command -label "Move Accent To Selected Line" -command "TabMod ii" -foreground black

		$tabo add cascade -label "Varibank Filters" -command {} -menu $tabo.sub8 -foreground black
		$tabo add cascade -label "Synthesis Partials" -command {} -menu $tabo.sub24 -foreground black
		$tabo add cascade -label "Envelope, Pitch And Balance Files" -menu $tabo.sub16 -foreground black
		$tabo add cascade -label "Harmonic Field Statistics" -menu $tabo.sub21 -foreground black

		set t_21 [menu $tabo.sub21 -tearoff 0]
		$t_21 add command -label "Select By Intervals Between Adjacent Vals" -command {TabMod "ii1"} -foreground black
		$t_21 add command -label "Select By Intervals Between Any Vals" -command {TabMod "ii2"} -foreground black
		$t_21 add command -label "Select By Note(s) In Common" -command {TabMod "ii4"} -foreground black
		$t_21 add command -label "Select By Note (Group)s In Common" -command {TabMod "ii3"} -foreground black
		$t_21 add command -label "Select By 'threshold' No. Of Note(s) In Common" -command {TabMod "ii8"} -foreground black
		$t_21 add command -label "Convert HF Names To Sndlist Filenames" -command {TabMod "ii5"} -foreground black
		$t_21 add command -label "Convert Sndlist Filenames To HF Names" -command {TabMod "ii6"} -foreground black
		$t_21 add command -label "Find Sndlists With HF Names In Given Dir" -command {TabMod "ii7"} -foreground black

		set t_16 [menu $tabo.sub16 -tearoff 0]
		$t_16 add command -label "Derive Envelope Files From Balance File" -command "TabMod be" -foreground black
		$t_16 add command -label "Derive Balance File By Gating (at N) Envelope File" -command "TabMod eb" -foreground black
		$t_16 add command -label "Derive Balance File From Pitch Data With Pitch Zeros" -command "TabMod ez" -foreground black
		$t_16 add command -label "Derive Gating Envelope From Beat Markers" -command "TabMod ge" -foreground black
		$t_16 add command -label "                          More Information" -command HelpBalance -foreground $evv(SPECIAL)
		$tabo add separator
		set t_8 [menu $tabo.sub8 -tearoff 0]
		$t_8 add command -label "Transpose Midi Vals In Varibank Filter Data File by N Semitones" -command {Vtrans 1} -foreground black
		$t_8 add command -label "Transpose Freq Vals In Varibank Filter Data File, by N Semitones" -command {Vtrans 0} -foreground black
		$t_8 add command -label "Derive Varibank Midi Data From List Of Midi Vals In A Table" -command {Vtrans 2} -foreground black
		$t_8 add command -label "Derive Varibank Frq Data From List Of Freq Vals In A Table" -command {Vtrans 3} -foreground black
		$t_8 add command -label "Derive Varibank Midi Data From Time & Frq Vals In a (Pitchtrack) Table" -command {Vtrans 5} -foreground black
		$t_8 add command -label "Derive Varibank Rounded Midi-type Data From A (Pitchtrack) Table" -command {Vtrans 9} -foreground black
		$t_8 add command -label "Derive Varibank Frq Data From Time & Frq Vals In a (Pitchtrack) Table" -command {Vtrans 4} -foreground black
		$t_8 add command -label "Convert Midi Values To Freq In A Varibank Filter Data File" -command {Vtrans 6} -foreground black
		$t_8 add command -label "Convert Freq Values To Midi In A Varibank Filter Data File" -command {Vtrans 7} -foreground black
		$t_8 add command -label "Convert Freq Values To Rounded Midi In A Varibank Filter Data File" -command {Vtrans 8} -foreground black
		$t_8 add command -label "Normalise Amplitudes In A Varibank Filter Data File" -command {Vtrans 10} -foreground black
		$t_8 add command -label "Add Lower Octave To A Varibank Filter Data File" -command {Vtrans 11} -foreground black

		$tabo add command -label "WORK ON SEGMENTS OF LISTED NAMES" -command {}  -foreground black
		$tabo add separator ;# -background $evv(HELP)
		$tabo add cascade -label "Modify Segments In Listed Names" -menu $tabo.sub9 -foreground black
		set t_9 [menu $tabo.sub9 -tearoff 0]
		$tabo add cascade -label "Sort On Segments Of Listed Names" -menu $tabo.sub10 -foreground black
		set t_10 [menu $tabo.sub10 -tearoff 0]
		$t_9 add command -label "WORK ON FIRST & LAST SEGMENT OF NAME" -command {}  -foreground black
		$t_9 add separator ;# -background $evv(HELP)
		$t_9 add command -label "Add Head Segment" -command {set col_ungapd_numeric 1; NameGames addhead} -foreground black
		$t_9 add command -label "Add Tail Segment" -command {set col_ungapd_numeric 1; NameGames addtail}	  -foreground black
		$t_9 add command -label "Delete Head Segment" -command {set col_ungapd_numeric 1; NameGames delhead}	  -foreground black
		$t_9 add command -label "Delete Tail Segment" -command {set col_ungapd_numeric 1; NameGames deltail}	  -foreground black
		$t_9 add command -label "Move Head Segment To Tail" -command {set col_ungapd_numeric 1; NameGames headtail}	  -foreground black
		$t_9 add command -label "Move Tail Segment To Head" -command {set col_ungapd_numeric 1; NameGames tailhead}	  -foreground black
		$t_9 add separator ;# -background $evv(HELP)

		$t_9 add command -label "REVERSE ALL SEGMENTS" -command {}  -foreground black
		$t_9 add separator ;# -background $evv(HELP)
		$t_9 add command -label "Reverse All Segments" -command {set col_ungapd_numeric 1; NameGames reverse} -foreground black
		$t_9 add separator
		$t_9 add command -label "WORK ON Nth SEGMENT OF NAME" -command {}  -foreground black
		$t_9 add separator ;# -background $evv(HELP)
		$t_9 add command -label "Add Segment At Character N" -command {set col_ungapd_numeric 1; NameGames addat}	  -foreground black
		$t_9 add command -label "Add Segment After Segment N" -command {set col_ungapd_numeric 1; NameGames addatseg}	  -foreground black
		$t_9 add command -label "Swap Segments M & N" -command {set col_ungapd_numeric 1; NameGames swapseg}	  -foreground black
		$t_9 add command -label "Delete Segment N" -command {set col_ungapd_numeric 1; NameGames delseg}	  -foreground black
		$t_9 add separator ;# -background $evv(HELP)

		$t_9 add command -label "ITEMS CONTAINING SPECIFIC SEGMENT VALUES" -command {}  -foreground black
		$t_9 add separator ;# -background $evv(HELP)
		$t_9 add command -label "Remove All Segments Of A Given Value" -command {set col_ungapd_numeric 1; NameGames delsegval}	  -foreground black
		$t_9 add command -label "If Items Contain String, Change Seg1 To Seg2" -command {set col_ungapd_numeric 1; NameGames condsub}	  -foreground black

		$t_9 add command -label "DEAL WITH EVERY Kth ITEM IN LIST" -command {}  -foreground black
		$t_9 add separator ;# -background $evv(HELP)
		$t_9 add command -label "Get Segment N From Every Kth Item" -command {set col_ungapd_numeric 1; NameGames getsegs}	  -foreground black
		$t_9 add command -label "Substitute Segment N In Every Kth Item" -command {set col_ungapd_numeric 1; NameGames substitute}	  -foreground black

		$t_10 add command -label "SORT ON Nth SEGMENT OF NAME" -command {}  -foreground black
		$t_10 add separator ;# -background $evv(HELP)
		$t_10 add command -label "Sort Alphabetically" -command {set col_ungapd_numeric 1; NameGames alphabet}	  -foreground black
		$t_10 add command -label "Sort On Start Consonant" -command {set col_ungapd_numeric 1; NameGames startcons}	  -foreground black
		$t_10 add command -label "Sort On End Consonant" -command {set col_ungapd_numeric 1; NameGames endcons}	  -foreground black
		$t_10 add command -label "Sort On Vowel" -command {set col_ungapd_numeric 1; NameGames vowel}	  -foreground black
		$t_10 add command -label "Numeric Sort" -command {set col_ungapd_numeric 1; NameGames number}	  -foreground black
		$t_10 add command -label "Pitch-Class Sort" -command {set col_ungapd_numeric 1; NameGames pclass}	  -foreground black
		$t_10 add separator ;# -background $evv(HELP)

		$t_10 add command -label "KEEP EQUAL NUMBERS OF EACH TYPE AFTER SORT ON SEGMENT N" -command {}  -foreground black
		$t_10 add separator ;# -background $evv(HELP)
		$t_10 add command -label "Keep After Alphabetic Sort" -command {set col_ungapd_numeric 1; NameGames alphabet_r}	  -foreground black
		$t_10 add command -label "Keep After Sort On Start Consonant" -command {set col_ungapd_numeric 1; NameGames startcons_r}	  -foreground black
		$t_10 add command -label "Keep After Sort On End Consonant" -command {set col_ungapd_numeric 1; NameGames endcons_r}	  -foreground black
		$t_10 add command -label "Keep After Sort On Vowel" -command {set col_ungapd_numeric 1; NameGames vowel_r}	  -foreground black
		$t_10 add command -label "Keep After Numeric Sort" -command {set col_ungapd_numeric 1; NameGames number_r}	  -foreground black
		$t_10 add command -label "Keep After Pitch-class Sort" -command {set col_ungapd_numeric 1; NameGames pclass_r}	  -foreground black
		$t_10 add separator ;# -background $evv(HELP)

		$t_10 add command -label "INTERLEAVE TYPES AFTER SORT ON SEGMENT N" -command {}  -foreground black
		$t_10 add separator ;# -background $evv(HELP)
		$t_10 add command -label "Interleave After  Alphabetic Sort" -command {set col_ungapd_numeric 1; NameGames ialphabet_ch}	  -foreground black
		$t_10 add command -label "Interleave After Sort On Start Consonant" -command {set col_ungapd_numeric 1; NameGames istartcons_ch}	  -foreground black
		$t_10 add command -label "Interleave After Sort On End Consonant" -command {set col_ungapd_numeric 1; NameGames iendcons_ch}	  -foreground black
		$t_10 add command -label "Interleave After Sort On Vowel" -command {set col_ungapd_numeric 1; NameGames ivowel_ch}	  -foreground black
		$t_10 add command -label "Interleave After Numeric Sort" -command {set col_ungapd_numeric 1; NameGames inumber_ch}	  -foreground black
		$t_10 add command -label "Interleave After Pitch-class Sort" -command {set col_ungapd_numeric 1; NameGames ipclass_ch}	  -foreground black
		$t_10 add separator
		$t_10 add command -label "ITEMS CONTAINING SPECIFIC SEGMENT VALUE" -command {}  -foreground black
		$t_10 add separator ;# -background $evv(HELP)
		$t_10 add command -label "Sort On Items Containing Specific Segment Value" -command {set col_ungapd_numeric 1; NameGames delsegval}	  -foreground black
		$tabo add separator
		$tabo add command -label "SELECT LINES BY CONTENT" -command {} -background $evv(HELP)  -foreground black
		$tabo add separator ;# -background $evv(HELP)
		$tabo add cascade -label "Select By Contents 'N' In Any Column" -menu $tabo.sub22 -foreground black
		$tabo add command -label "(Distinguish separate items with \",\")" -command {} -foreground $evv(SPECIAL)
		$tabo add cascade -label "Select Items In Tables From List Of Tables" -menu $tabo.sub23 -foreground black
		set t_22 [menu $tabo.sub22 -tearoff 0]
		$t_22 add command -label "Select Line" -command {TabMod ST0} -foreground black
		$t_22 add command -label "Select Item In Col 'threshold'" -command {TabMod ST1} -foreground black
		$t_22 add command -label " + Convert To CDP 'txt' Format" -command {TabMod ST2} -foreground black
		$t_22 add command -label " + Use 'N' for Outfile Name" -command {TabMod ST3} -foreground black
		$t_22 add command -label " + Use 'N' for Outfile Name" -command {TabMod ST3} -foreground black
		set t_23 [menu $tabo.sub23 -tearoff 0]
		$t_23 add command -label "Select Items From First Tab, Col 'threshold'" -command {}  -foreground black
		$t_23 add command -label "That Are Not In Any Of Other Tables" -command {TabMod St0} -foreground black
		$t_23 add command -label "+ Even Converted To CDP 'txt' Format" -command {TabMod St1} -foreground black
		set t_24 [menu $tabo.sub24 -tearoff 0]
		$t_24 add command -label "Set All Level Vals To" -command {TabMod SY1} -foreground black
		$t_24 add command -label "Add To All Level Values" -command {TabMod SY2} -foreground black
		$t_24 add command -label "Multiply All Level Values" -command {TabMod SY3} -foreground black
		$t_24 add command -label "Add To All Partial Values" -command {TabMod SY4} -foreground black
		$t_24 add command -label "Multiply All Partial Values" -command {TabMod SY5} -foreground black


#TABLES AT CURSOR MENU
		set atco [menu $gta.atc.atco -tearoff 0]

		$atco add command -label "DELETE/KEEP/MOVE ROW(S)" -command {}  -foreground black
		$atco add separator ;# -background $evv(HELP)
		$atco add cascade -label "Delete Row(s)" -menu $atco.sub1 -foreground black
		set at_1 [menu $atco.sub1 -tearoff 0]
		$at_1 add command -label "Row under cursor" -command {RowDelete 3} -foreground black
		$at_1 add command -label "All Rows From cursor onwards" -command {RowDelete 7} -foreground black
		$at_1 add command -label "All Rows Up To And Including cursor" -command {RowDelete 8} -foreground black
		$at_1 add command -label "Delete N Rows from cursor onwards" -command {RowDelete 4} -foreground black
		$at_1 add command -label "Delete Every Nth Row from cursor onwards" -command {RowDelete 5} -foreground black
		$at_1 add command -label "At Every Nth Row from cursor onwards, Delete 'Threshold' Rows" -command {RowDelete 6} -foreground black
		$atco add separator
		$atco add cascade -label "Keep Row(s)" -menu $atco.sub2 -foreground black
		$atco add separator
		$atco add command -label "Move (threshold) Rows from cursor onwards, by N secs" -command {RowsMove} -foreground black
		set at_2 [menu $atco.sub2 -tearoff 0]
		$at_2 add command -label "Row under cursor" -command {RowKeep 0} -foreground black
		$atco add separator ;# -background $evv(HELP)
		$atco add command -label "INSERT ROW(S)" -command {}  -foreground black
		$atco add separator ;# -background $evv(HELP)
		$atco add command -label "At Position After cursor" -command {RowInsert 0} -foreground black
		$atco add command -label "At Position Before cursor" -command {RowInsert 1} -foreground black
		$atco add separator ;# -background $evv(HELP)
		$atco add command -label "VARIBANK FILTER: SEE ROW PITCHES AS STAFF NOTATION" -command {}  -foreground black
		$atco add separator ;# -background $evv(HELP)
		$atco add command -label "Frequency Varibank data" -command {VbankRow 0} -foreground black
		$atco add command -label "Midi Varibank data" -command {VbankRow 1} -foreground black
		$atco add separator
		$atco add command -label "" -command {} -foreground black

#ENVELOPES MENU
		set envo [menu $gta.env.envs -tearoff 0]

		$envo add command -label "MODIFY TIMES" -command {}  -foreground black
		$envo add separator ;# -background $evv(HELP)
		$envo add command -label "Quantise Envelope Times over the time quantum 'N'" -command {TabMod "qt"} -foreground black
		$envo add command -label "Scale All Times by factor 'N'" -command {TabMod "ef"} -foreground black
		$envo add command -label "Scale All Times, To Give Total Duration 'N'" -command {TabMod "et"} -foreground black
		$envo add command -label "Extend Final Value in envelope to time 'N'" -command {TabMod "ex"} -foreground black
		$envo add command -label "Cut Off Envelope at time 'N'" -command {TabMod "ct"} -foreground black
		$envo add command -label "To Warp Envelope Time, using another brkfile, see JOIN menu" -command {} -foreground $evv(SPECIAL)
		$envo add separator ;# -background $evv(HELP)
		$envo add command -label "MODIFY VALUES" -command {}  -foreground black
		$envo add separator ;# -background $evv(HELP)
		$envo add command -label "Quantise Envelope Values over the value quantum 'N'" -command {TabMod "eqv"} -foreground black
		$envo add command -label "Scale All Envelope Values by factor 'N'" -command {TabMod "eev"} -foreground black
		$envo add command -label "Limit Envelope Values to maximum 'N' (minimum 'Threshold')" -command {TabMod "elv"} -foreground black
		$envo add command -label "Gate Envelope Values below 'N'" -command {TabMod "elg"} -foreground black
		$envo add command -label "Invert Envelope" -command {set col_ungapd_numeric 1; MassageBrk "Iv" 0} -foreground black
		$envo add command -label "Change Staccato Duration To 'N'" -command {set col_ungapd_numeric 1; MassageBrk "stac" 0} -foreground black
		$envo add command -label "Create Envelope To Add Attacks" -command {EnvOp "Ea"} -foreground black
		$envo add command -label "Inverse : Delay Input Envelope to start at time N: Then create Inverse" -command {EnvOp "eD"} -foreground black
		$envo add command -label "Plateau Level from start to level at cursor-selected line" -command {EnvOp "eP"} -foreground black
		$envo add separator ;# -background $evv(HELP)
		$envo add command -label "ADD VALUE PAIR AT END OF ENVELOPE FILE" -command {}  -foreground black
		$envo add separator ;# -background $evv(HELP)
		$envo add command -label "Add Value N At Time Zero" -command {EnvOp "eB"} -foreground black
		$envo add command -label "Add Value N Beyond End Time" -command {EnvOp "eE"} -foreground black
		$envo add command -label "" -command {} -foreground black
		$envo add separator ;# -background $evv(HELP)
		$envo add command -label "OTHER" -command {}  -foreground black
		$envo add separator ;# -background $evv(HELP)
		$envo add command -label "Extract Peak Times" -command {EnvOp "Ep"} -foreground black
		$envo add command -label "Generate Gate (0 if below N, 1 if above)" -command {EnvOp "Gg"} -foreground black

#TESTS MENU
		set teso [menu $gt.tes.test -tearoff 0]
		$teso add cascade -label "Tests On Input Column" -menu $teso.sub1 -foreground black
		set te_1 [menu $teso.sub1 -tearoff 0]
		$te_1 add command -label "Which Item Is This?" -command {WhichItem incol 0} -foreground black
		$te_1 add command -label "Which Item Has Value 'N'?" -command {WhichItem incol 1} -foreground black
		$te_1 add command -label "Check For Ascending Order" -command {GenerateNewColumn "ao" 0} -foreground black
		$te_1 add command -label "Greatest" -command {GenerateNewColumn "g" 0} -foreground black
		$te_1 add command -label "Least" -command {GenerateNewColumn "l" 0} -foreground black
		$te_1 add command -label "Mean Value" -command {GenerateNewColumn "M" 0} -foreground black
		$te_1 add command -label "Minimum Interval between vals" -command {GenerateNewColumn "mi" 0} -foreground black
		$te_1 add command -label "Maximum Interval between vals" -command {GenerateNewColumn "mI" 0} -foreground black
		$te_1 add command -label "Mean Interval between vals" -command {GenerateNewColumn "MI" 0} -foreground black
		$te_1 add command -label "Sum" -command {GenerateNewColumn "t" 0} -foreground black
		$te_1 add command -label "Sum The Absolute Differences (overlap N)" -command {GenerateNewColumn "sd" 0} -foreground black
		$te_1 add command -label "Sum, Minus Overlaps N" -command {GenerateNewColumn "so" 0} -foreground black
		$te_1 add command -label "Product" -command {GenerateNewColumn "p" 0} -foreground black
		$te_1 add separator
		$te_1 add command -label "Difference (2 Vals Only)" -command {GenerateNewColumn "DI" 0} -foreground black
		$te_1 add command -label "Ratio (2 Vals Only)" -command {GenerateNewColumn "IR" 0} -foreground black
		$te_1 add separator
		$te_1 add command -label "Mean Tempo Of Regular Times" -command {GenerateNewColumn "te" 0} -foreground black
		$te_1 add command -label "Variance From Regular Increasing Sequence" -command {GenerateNewColumn "dg" 0} -foreground black
		$teso add cascade -label "Tests On Output Column" -menu $teso.sub2 -foreground black
		set te_2 [menu $teso.sub2 -tearoff 0]
		$te_2 add command -label "Which Item Is This?" -command {WhichItem outcol 0 } -foreground black
		$te_2 add command -label "Which Item Has Value 'N'?" -command {WhichItem outcol 1} -foreground black
		$te_2 add command -label "Check For Ascending Order" -command {GenerateNewColumn "ao" -1} -foreground black
		$te_2 add command -label "Greatest" -command {GenerateNewColumn "g" -1} -foreground black
		$te_2 add command -label "Least" -command {GenerateNewColumn "l" -1} -foreground black
		$te_2 add command -label "Mean Value" -command {GenerateNewColumn "M" -1} -foreground black
		$te_2 add command -label "Minimum Interval between vals" -command {GenerateNewColumn "mi" -1} -foreground black
		$te_2 add command -label "Maximum Interval between vals" -command {GenerateNewColumn "mI" -1} -foreground black
		$te_2 add command -label "Mean Interval between vals" -command {GenerateNewColumn "MI" -1} -foreground black
		$te_2 add command -label "Sum" -command {GenerateNewColumn "t" -1} -foreground black
		$te_2 add command -label "Sum The Absolute Differences (overlap N)" -command {GenerateNewColumn "sd" -1} -foreground black
		$te_2 add command -label "Sum, Minus Overlaps N" -command {GenerateNewColumn "so" -1} -foreground black
		$te_2 add separator
		$te_2 add command -label "Difference (2 Vals Only)" -command {GenerateNewColumn "DI" -1} -foreground black
		$te_2 add command -label "Ratio (2 Vals Only)" -command {GenerateNewColumn "IR" -1} -foreground black
		$te_2 add separator
		$te_2 add command -label "Product" -command {GenerateNewColumn "p" -1} -foreground black
		$te_2 add command -label "Mean Tempo Of Regular Times" -command {GenerateNewColumn "te" -1} -foreground black
		$te_2 add command -label "Variance From Regular Increasing Sequence" -command {GenerateNewColumn "dg" -1} -foreground black
		$teso add cascade -label "Tests On Both Columns" -menu $teso.sub3 -foreground black
		set te_3 [menu $teso.sub3 -tearoff 0]
		$te_3 add command -label "Compare Values (within error range N, if entered)" -command {Vectors "C"} -foreground black
		$te_3 add command -label "Check each Col2 val > corresponding Col1 val" -command {Vectors "CC"} -foreground black
		$te_3 add command -label "Find All Elements That Are Only In One Of Lists" -command {Vectors "oo"} -foreground black
		$te_3 add command -label "Find All Elements That Are Only In List 1" -command {Vectors "o1"} -foreground black
		$te_3 add command -label "Find All Elements That Are Only In List 2" -command {Vectors "o2"} -foreground black
		$te_3 add command -label "Find All Elements That Are In Both Lists" -command {Vectors "ob"} -foreground black
		$teso add cascade -label "Tests On Input Table"  -menu $teso.sub4 -foreground black
		set te_4 [menu $teso.sub4 -tearoff 0]
		$te_4 add command -label "Which Item Is This?" -command {WhichItem intab 0} -foreground black
		$te_4 add separator
		$te_4 add command -label "Duration Produced By Timestretch ratios in Input brktable (at infile time N)" -command {TabStr i 0} -foreground black
		$te_4 add command -label "Duration Produced By Semitone Pitch/Time Shift in Input brktable (at infile time N)" -command {TabStr i 1} -foreground black
		$teso add cascade -label "Tests On Output Table" -menu $teso.sub5 -foreground black
		set te_5 [menu $teso.sub5 -tearoff 0]
		$te_5 add command -label "Which Item Is This?" -command {WhichItem outtab 0} -foreground black
		$te_5 add command -label "Duration Produced By Timestretch ratios on Output table (at infile time N)" -command {TabStr o 0} -foreground black
		$te_5 add command -label "Duration Produced By Semitone Pitch/Time Shift in Output table (at infile time N)" -command {TabStr o 1} -foreground black

#FIND MENU
		set fino [menu $gt.fin.find -tearoff 0]
		$fino add command -label "INPUT COLUMN" -command {}  -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "Find Value N (to within error 'threshold', if entered)" -command {FindInCol i} -foreground black
		$fino add command -label "Find Item number N" -command {FindInCol ik} -foreground black
		$fino add command -label "" -command {} -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "OUTPUT COLUMN" -command {}  -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "Find Value N (to within error 'threshold', if entered)" -command {FindInCol o} -foreground black
		$fino add command -label "Find Item number N" -command {FindInCol ok} -foreground black
		$fino add command -label "" -command {} -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "BOTH COLUMNS" -command {}  -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "Select Element At Same Position in other column" -command {CursHilite p} -foreground black
		$fino add command -label "Select (First) Equal Value in other column (within error range 'threshold')" -command {CursHilite v} -foreground black
		$fino add command -label "" -command {} -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "TABLES" -command {}  -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "Find Row number N in INPUT Table" -command {FindInCol ir} -foreground black
		$fino add command -label "Find Row number N in OUTPUT Table" -command {FindInCol or} -foreground black
		$fino add command -label "" -command {} -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "ANY TABLE OR COLUMN" -command {}  -foreground black
		$fino add separator ;# -background $evv(HELP)
		$fino add command -label "What Number Item is this, counting from the top?" -command {FindNum} -foreground black
		$fino add command -label "" -command {}

		label $gm.mes -text "Messages"
		entry $gm.e -textvariable tedit_message -width 60

	 	button $gm.pref -text "Outfil->Ref" -command "RefStore ted" -highlightbackground [option get . background {}]
	 	button $gm.pref2 -text "Msg->Ref" -command "RefStore tedmes" -highlightbackground [option get . background {}]
	 	button $gm.pref3 -text "Outfil->Prm" -command "TabEdParam" -highlightbackground [option get . background {}]
	 	entry  $gm.ree -textvariable ref(text2) -width 26 -borderwidth 0 -state readonly -readonlybackground [option get . background {}]
		button $gm.ok -text "" -command {set pr_ref 1} -state  $d -width 2 -borderwidth 0 -highlightbackground [option get . background {}]
		button $gm.no -text "" -command {set pr_ref 0} -state  $d -width 2 -borderwidth 0 -highlightbackground [option get . background {}]

		label $gmi.mod -text "MODE" -font bigfnt -fg $evv(SPECIAL)
		radiobutton $gmi.nor -variable colinmode -text "File to Table" -value 0 -command {ChangeColSelect 1}
		radiobutton $gmi.chk -variable colinmode -text "File->Col" -value 1 -command {ChangeColSelect 1}
		radiobutton $gmi.mul -variable colinmode -text "ManyFiles" -value 2 -command {ChangeColSelect 1}
		checkbutton $gmi.fre -variable freetext -text "Free text" -command {ChangeColTextMode}
		frame $gmi.zwq1 -width 1 -bg $evv(POINT)
		frame $gmi.zwq2 -width 1 -bg $evv(POINT)
		pack $gmi.mod $gmi.nor $gmi.chk $gmi.mul -side left
		pack $gmi.zwq1 -side left -fill y -padx 2
		pack $gmi.fre -side left
		pack $gmi.zwq2 -side left -fill y -padx 2

		pack $ff.d $ff.e $ff.l $ff.tell -side top
		pack $it.f0 $it.f $it.tcop $it.l -side top -anchor e
		pack $gc.name $gc.e -side top
		pack $gc.zoig $gc.zaig -side top -fill x

		pack $gc.sk $gc.blob $gc.lab2 $gc.cse2 $gc.lab $gc.cse -side top
		pack $gc.qqq -side top -fill x
		pack $gc.ok -side top
		pack $gc.lina -side top -fill x
		pack $gc.ddum $gc.got -side top
 		pack $ic.dummy.name $ic.dummy.cnt -side left
 		pack $ic.dummy  -side top
 		pack $ic.isu $ic.isu2 $ic.io -side top
 		pack $ic.zog -side top -fill x -expand true
 		pack $ic.l -side top
		pack $oc.dummy.name $oc.dummy.cnt -side left
 		pack $oc.dummy  -side top
		pack $oc.rnd $oc.rst $oc.oi -side top
		pack $oc.zog -side top -fill x -expand true
		pack $oc.l -side top

		pack $kc.name -side top
		pack $kc.zzz0 -side top -fill x -expand true
		pack $kc.okk -side top
		pack $kc.zzz1 -side top -fill x -expand true
		pack $kc.oko -side top
		pack $kc.zzz2 -side top -fill x -expand true
		pack $kc.okr $kc.oki $kc.lab $kc.e -side top
		pack $kc.oky $kc.okz -side top
		pack $kc.zzz3 -side top -fill x -expand true
		pack $kc.ok -side top

		pack $ot.cnt $ot.rnd $ot.l -side top
		pack $kt.name $kt.zz2 $kt.zz2a $kt.lab4 $kt.fnm $kt.zz3 -side top -fill x -expand true
		pack $kt.bbb $kt.bbb1 $kt.bbb2 -side top -fill x -expand true
		pack $kt.bxxb -side top
		pack $kt.names -side top -fill x -expand true

		pack $help.hlp $help.conn $help.con $help.help $help.nns $help.tips $help.quit -side left -padx 1

		pack $gt.cre $gt.cre2 $gt.der $gt.ins4 $gt.dmu1 -side left
		pack $gt3.mat $gt3.mus $gt3.int $gt3.tim $gt3.db $gt3.ran $gt3.ord $gt3.for -side left
		pack $gt3.ins $gt3.ins2 $gt3.ins3 -side left

		pack $gta.dmu3 $gta.vec -side left
		pack $gta.zz -side left -fill y -padx 12

		pack $gta.t $gta.tab $gta.brk $gta.env $gta.seq $gta.atc -side left
		pack $gta.dum -side left -fill y -padx 12
		pack $gta.t2 $gta.joi -side left

		pack $gmi.lab1a $gmi.lab1 $gmi.par1 $gmi.lab2 $gmi.par2 $gmi.gr $gmi.gl $gmi.bashelp $gmi.info -side left

		pack $gt2.ltit -side left
		pack $gt2.kbd $gt2.calc $gt2.ref  -side left
		pack $gt2.xmaca -side left -fill y -padx 12
		pack $gt2.xmac $gt2.dmac $gt2.rmac $gt2.smac $gt2.lmac -side left

		pack $gt.dum2a -side left -fill y -padx 12

		pack $gt.dum2 $gt.same -side left
		pack $gt.fin $gt.tes -side left -ipady 1
		pack $gt.reset -side left

		pack $gt.which $gm.mes $gm.e -side right -padx 1 -anchor w
		pack $gm.no $gm.ok $gm.ree $gm.pref2 $gm.pref $gm.pref3 -side left -padx 1

		grid $gb.files -row 0 -column 0 -sticky ew
		grid $gb.l0 -row 0 -rowspan 3 -column 1 -sticky ns
		grid $gb.itab -row 0 -column 2 -columnspan 2 -sticky ew

		grid $gb.l1 -row 0 -rowspan 3 -column 4 -sticky ns
		grid $gb.cols -row 0 -column 5 -columnspan 4 -sticky ew
		grid $gb.l2 -row 0 -rowspan 3 -column 7 -sticky ns
		grid $gb.l3 -row 0 -rowspan 3 -column 9 -sticky ns
		grid $gb.otab -row 0 -column 10 -columnspan 4 -sticky ew
		grid $gb.l4 -row 0 -rowspan 3 -column 11 -sticky ns
		grid $gb.r1 -row 1 -column 0 -columnspan 13 -sticky ew
		grid $gb.fframe -row 2 -column 0
		grid $gb.itframe -row 2 -column 2
		grid $gb.gframe -row 2 -column 3
		grid $gb.icframe -row 2 -column 5
		grid $gb.ocframe -row 2 -column 6
		grid $gb.kcframe -row 2 -column 8
		grid $gb.otframe -row 2 -column 10
		grid $gb.ktframe -row 2 -column 12
		
		frame $tabed.hl -height 1
		frame $tabed.hl.z -height 1 -bg $evv(POINT) -width 495
		pack $tabed.hl.z -side right
		
		pack $tabed.help -side top -fill x
		pack $tabed.qw -side top -fill x
		pack $tabed.mid $tabed.l3 -side top -fill x
		pack $tabed.top2 $tabed.l2 -side top -fill x 
		pack $tabed.top -side top -fill x
		pack $tabed.hl -side top -fill x
		pack $tabed.top3 -side top -fill x
		pack $tabed.l2a -side top -fill x
		pack $tabed.topa $tabed.l1a -side top -fill x
		pack $tabed.message -side top -fill x
		pack $tabed.l4 $tabed.bot -side top -fill x

		bind $ff.l.list <ButtonRelease-1> {GetTableFromFilelist %W -1 0}
		bind $tabed.bot.ktframe.zz2.ok4 <ButtonRelease-1> {$tabed.bot.ktframe.zz2.ok4 config -bg [option get . background {}]}
		set tabedit_bindcmd [bind $ff.l.list <ButtonRelease-1>]
		set tabedit_ns {NameListChoose $tabed.bot.ktframe.names.list $tabed.bot.ktframe.fnm}

		bind $tabed.mid.par1 <Right> {focus $tabed.mid.par2}
		bind $tabed.mid.par2 <Left> {focus $tabed.mid.par1}
		bind $tabed.mid.par1 <Control-Key-P> {UniversalPlay tabed 0}
		bind $tabed.mid.par1 <Control-Key-p> {UniversalPlay tabed 0}
		bind $tabed.mid.par1 <Key-space>	 {UniversalPlay tabed 0}
		bind $tabed.mid.par2 <Control-Key-P> {UniversalPlay tabed 0}
		bind $tabed.mid.par2 <Control-Key-p> {UniversalPlay tabed 0}
		bind $tabed.mid.par2 <Key-space>	 {UniversalPlay tabed 0}
		bind $tabed.bot.gframe.e <Control-Key-P> {UniversalPlay tabed 0}
		bind $tabed.bot.gframe.e <Control-Key-p> {UniversalPlay tabed 0}
		bind $tabed.bot.gframe.e <Key-space>	 {UniversalPlay tabed 0}
		bind $tabed.bot.kcframe.e <Control-Key-P> {UniversalPlay tabed 0}
		bind $tabed.bot.kcframe.e <Control-Key-p> {UniversalPlay tabed 0}
		bind $tabed.bot.kcframe.e <Key-space>	  {UniversalPlay tabed 0}

		bind $tabed.bot.gframe.e <Up> {IncIncolget 0}
		bind $tabed.bot.gframe.e <Down> {IncIncolget 1}

		bind $tabed.bot.ktframe.fnm <Up>	"AdvanceNameIndex 1 col_tabname 0"
		bind $tabed.bot.ktframe.fnm <Down>	"AdvanceNameIndex 0 col_tabname 0"
		bind $tabed.bot.ktframe.fnm <Control-Up>	"AdvanceNameIndex 1 col_tabname 1"
		bind $tabed.bot.ktframe.fnm <Control-Down>	"AdvanceNameIndex 0 col_tabname 1"
		bind .ted <Escape> {set pr_te 0}
	}
	if {$p_pg} {
		$tabed.message.pref3 config -text "Outfil->Prm" -state normal -bd 2
	} else {
		$tabed.message.pref3 config -text "" -state disabled -bd 0
	}
	if {$small_screen} {
		set tabed .ted.c.canvas.f
	} else {
		set tabed .ted
	}	
	
	wm resizable .ted 1 1

	set rcolno ""
	set tot_inlines ""
	set tot_outlines ""
	SetInout 0
	$tabed.top2.rmac config -text "Record" -command RecordTEMacro

	set kt $tabed.bot.ktframe
	if [info exists nu_names] { 
		$kt.names.list delete 0 end
		foreach nname $nu_names {	;#	Post recent names
			$kt.names.list insert end $nname
		}					
	}

	set inlines ""
	set outlines ""
	catch {unset tot_inlines}
	catch {unset c_incols}
	catch {unset c_inlines}
	catch {unset col_infilelist}
	catch {unset inlines}
	catch {unset outlines}
	catch {unset incolget}
	set threshold ""
	set colpar ""
	set col_tabname ""
	set freetext 0
	set colinmode 0
	set savestyle 0
 	set orig_inlines 0
 	set orig_incolget ""
	set col_infnam ""
	set tcop 0
	$tabed.bot.gframe.got config -bg [option get . background {}]

	ForceVal $tabed.message.e ""
	ForceVal $tabed.bot.gframe.e ""
	set threshtype 1
	set coltype "o"
	set eflag 0
	set eflag2 0
	set col_skiplines 0
	ForceVal $tabed.bot.gframe.blob.skip $col_skiplines
	foreach fnam [$wl get 0 end] {
		if {[info exists pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST))} {
			$tabed.bot.fframe.l.list insert end $fnam			
		}
	}
	set tet 0
	set brk_stat $d
	set env_stat $d
	set seq_stat $d
	set tls 0
	set insitu 0
	$tabed.bot.icframe.l.list config -bg $evv(EMPH)
	LiteCol "o"
	set lmo X
	
	;#	LOAD LAST USED TABLE EDITOR ACTION AND PARAMS

	set fnam [file join $evv(URES_DIR) $evv(LMO)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {open $fnam r} zorba] {
			Inf "Cannot find information about last Table Editor process used."
		} else {
			set j 0
			while {[gets $zorba zz] >= 0} {
				set zz [split $zz]
				switch -- $j {
					0 {
						set i 0
						foreach item $zz  {
							if {[string length $item] > 0} {
								if {$i == 0} {
									set lmo $item
									incr i
								} else {
									append lmo " " $item
								}
							}
						}
					}
					1 {
						set i 0
						foreach item $zz {
							if {[string length $item] > 0} {
								if {$i == 0} {
									if {![string match $item "-"]} {
										set colpar $item
									}
								} elseif {$i == 1} {
									if {![string match $item "-"]} {
										set threshold $item
									}
								}
								incr i
							}
						}
					}
				}
				incr j
			}
			close $zorba
		}
	}
	set pr_te 0
	set col_ungapd_numeric 0
	SetEnvState 0
	if {$colinmode == 2} {
		focus $tabed.mid.par1
	} else {
		focus $tabed.bot.gframe.e
	}
#RWD need to enable entry boxes when opened (sets focus etc)
    update idletasks

	My_Grab 1 .ted pr_te
	StandardPosition2 .ted
	tkwait variable pr_te
	if [winfo exists .cpd] {
		DestroyCalc
	}
	catch {file delete $evv(COLFILE1)}
	catch {file delete $evv(COLFILE2)}
	catch {file delete $evv(COLFILE3)}

	;#	SAVE LAST USED TABLE EDITOR ACTION AND PARAMS

	set fnam [file join $evv(URES_DIR) $evv(LMO)$evv(CDP_EXT)]
	if [catch {open $fnam w} zorba] {
		Inf "Cannot save last Table Editor process used."
	} else {
		set clat ""
		set i 0 
		foreach item $lmo {
			if {$i == 0} {
				append clat $item
			} else {
				append clat " " $item
			}
			incr i
		}
		puts $zorba $clat
		if {[string length $colpar] <= 0} {
			set clat "-"
		} else {
			set clat $colpar
		}
		if {[string length $threshold] <= 0} {
			append clat " -"
		} else {
			append clat " " $threshold
		}
		puts $zorba $clat
		catch {close $zorba}
	}
	My_Release_to_Dialog .ted
	Dlg_Dismiss .ted

	$ww.1.a.top.tedit config -state normal
	catch {$papag.parameters.zzz.tedit config -state normal}
}

#------ Clear and Reset Table Editor

proc ResetTableEditor {} {
	global incolget threshtype threshold colpar col_skiplines eflag eflag2 coltype tot_inlines orig_inlines brk_stat
	global c_incols c_inlines col_infilelist inlines outlines tot_outlines last_oc col_tabname orig_incolget seq_stat
	global savestyle incols colinmode freetext tround ttround col_infnam col_ungapd_numeric evv lmo okz tcop tls tet
	global tabedit_bindcmd tabedit_bind2 insitu ref env_stat tabed

	set n "normal"
	set d "disabled"

	$tabed.bot.icframe.isu config -bg [option get . background {}]
	$tabed.bot.icframe.isu2 config -bg $evv(EMPH)

	set tb $tabed.bot
	set tt $tabed.top
	set tta $tabed.topa
	set tt2 $tabed.top2
	set tt3 $tabed.top3
	set fl $tabed.bot.fframe.l.list
	set kt $tabed.bot.ktframe

#	REINITIALISE ALL MENUS

	$tt3.mat config -state $n -text "Maths"
	$tt3.mus config -state $n -text "Pitch"
	$tt3.int config -state $n -text "Interval"
	$tt3.tim config -state $n -text "Time"
	$tt3.db config  -state $n -text  "Gain"
	$tt3.ord config -state $n -text "Order"
	$tt3.ran config -state $n -text "Rand"
	$tt.cre config -state $n -text "Create"
	$tt.cre2 config -state $n -text "Create2"
	$tta.vec config -state $n -text "Combine"
	$tt.der config -state $n -text "Derive"
	$tt.tes config -state $n -text "Test"
	$tt.fin config -state $n -text "Find"
	$tta.brk config -state $d -text ""
	$tta.seq config -state $d -text ""
	$tt3.for config -state $n -text "Format"
	$tt3.ins config -state $n -text "Edit In"
	$tt3.ins2 config -state $n -text "Edit Out"
	$tt3.ins3 config -state $n -text "At Cursor"
	$tt.ins4 config -state $n -text "From Snds"
	$tta.tab config -state $n -text "Tables"
	$tta.env config -state $d -text ""
	$tta.atc config -state $n -text "At Cursor"
	$tta.joi config -state $d -text ""

#	REINITIALISE ALL Get Column BUTTONS

	$tb.gframe.ok config -state $d
	$tb.gframe.blob.skip config -state $d

#	REMEMBER CURRENT STATE OF OUTPUT COL

	if {[info exists outlines] && ($outlines > 0)} {
		set last_oc [$tb.ocframe.l.list get 0 end]
		set last_cr $col_ungapd_numeric
	}

#	CLEAR ALL TABLES, EXCEPT FILE LISTING

	$tb.itframe.l.list delete 0 end
	$tb.icframe.l.list delete 0 end
	$tb.ocframe.l.list delete 0 end
	$tb.otframe.l.list delete 0 end
	$tb.itframe.f0 config -text "\n\n"


#	REINITIALISE ALL Keep Column BUTTONS

	SetInout 0
	DisableOutputColumnOptions
#	REINITIALISE ALL Keep Table BUTTONS

	DisableOutputTableOptions 0

#	EMPTY ALL Value or Name DISPLAYS

	ForceVal $tb.itframe.f.e ""
	ForceVal $tb.itframe.f.e2 ""
	ForceVal $tb.gframe.e ""
	ForceVal $tb.gframe.blob.skip ""
	ForceVal $tb.kcframe.e ""
	ForceVal $tb.ktframe.fnm ""
	ForceVal $tabed.message.e ""

#	UNSET OR RESET ALL VARIABLES

	catch {unset c_incols}
	catch {unset c_inlines}
	catch {unset col_infilelist}
	set tot_inlines ""
	ForceVal $tabed.bot.itframe.f.e2 $tot_inlines
	$tb.itframe.tcop config -state $d

	set tot_outlines ""
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	set inlines ""
	ForceVal $tabed.bot.icframe.dummy.cnt $inlines
	set outlines ""
	ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	catch {unset tot_inlines}
	catch {unset tot_outlines}
	catch {unset inlines}
	catch {unset outlines}
	catch {unset incolget}
	set threshold ""
	set colpar ""
	set col_tabname ""
	set savestyle 0
	set tround 0
	set ttround 0
	set threshtype 1
	set coltype "o"
	set col_skiplines 0
	ForceVal $tb.gframe.blob.skip $col_skiplines

#	DELETE ALL ASSOCIATED TEMPFILES

	catch {file delete $evv(COLFILE1)}
	catch {file delete $evv(COLFILE2)}
	catch {file delete $evv(COLFILE3)}
	set col_infnam ""

	$tb.fframe.d.all config -state $n
	$tb.fframe.d.mix config -state $n
	$tb.fframe.d.brk config -state $n -text "Brk"

	$tabed.message.pref config -text "OutFile->Ref" \
	 	-bg [option get . background {}] -fg [option get . foreground {}]
	set ref(text2) ""
	$tabed.message.ree config -state readonly -borderwidth 0 -readonlybackground [option get . background {}]
	$tabed.message.ok config -text "" -state  $d -borderwidth 0
	$tabed.message.no config -text "" -state  $d -borderwidth 0

	set brk_stat $d
	set env_stat $d
	set seq_stat $d
	set tet 0
	set tls 0
	HaltCursCop
	set lmo X
	set colinmode 0
	set insitu 0
	LiteCol "o"
	set orig_inlines 0
	set orig_incolget ""
	ForceVal $tabed.bot.gframe.got $orig_incolget
	set tcop 0
	$tabed.bot.gframe.got config -bg [option get . background {}]
	bind $fl <ButtonRelease-1> {GetTableFromFilelist %W -1 0}
	set tabedit_bindcmd [bind $fl <ButtonRelease-1>]
}

#------ Format data into columns

proc ColFormat {colmode} {
	global col_infnam outlines inlines colpar docol_OK CDPcolrun record_temacro temacro evv
	global outcolcnt tot_outlines tot_inlines lmo col_ungapd_numeric tabedit_ns tabedit_bind2 temacrop threshold
	global col_tabname tabed incols

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	HaltCursCop
	set lmo F
	lappend lmo $col_ungapd_numeric $colmode

	set tb $tabed.bot

	set is_cols 0
	set is_txt 0
	set is_swap 0

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {[string index $colmode 0] == "T"} {
		set colmode [string range $colmode 1 end]
		set is_txt 1
	}
	if {[string index $colmode 0] == "r"} {
		set colmode [string range $colmode 1 end]
		set is_cols 1
		if {[string match $colmode "T"]} {
			set is_swap 1
		}
	}
	switch -- $colmode {
		"o" {
			if {![info exists outlines] || ($outlines <= 0)} {
				ForceVal $tabed.message.e "No Col Output exists"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set thisfile $evv(COLFILE2)
		}
		"i" {
			if {![info exists inlines] || ($inlines <= 0)} {
				ForceVal $tabed.message.e "No Col Input exists"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set thisfile $evv(COLFILE1)
		}
		"t" -
		"T" {	
			if {![info exists tot_inlines] || ($tot_inlines <= 0)} {
				ForceVal $tabed.message.e "No Table Input exists"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set thisfile $col_infnam
		}
		"sS" -
		"sE" {	
			if {![info exists tot_inlines] || ($tot_inlines <= 0)} {
				ForceVal $tabed.message.e "No Table Input exists"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			} elseif {$incols !=1} {
				ForceVal $tabed.message.e "This process only works with a SINGLE column table"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set thisfile $col_infnam
		}
		"iE" {	
			if {![info exists tot_inlines] || ($tot_inlines <= 0)} {
				ForceVal $tabed.message.e "No Table Input exists"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			} elseif {$incols !=2} {
				ForceVal $tabed.message.e "This process only works with a TWO COLUMN table"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set thisfile $col_infnam
		}
	}
	if {($colmode != "sE") && ($colmode != "sS") && ($colmode != "iE")} {
		if {$is_swap} {
			if {![info exists colpar] || ![IsNumeric $colpar] || ([expr round($colpar)] < 1)} {
				ForceVal $tabed.message.e "Invalid parameter value at 'N'"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set zat 0
			foreach line [$tabed.bot.itframe.l.list get 0 end] {
				foreach item $line {
					incr zat
				}
			}
			set nucolpar [expr ceil(double($zat) / double($colpar))]
			set is_cols 0
		}
		if {$is_txt} {
			if {$is_cols} {
				set colmode "FR"
			} else {
				set colmode "Ff"
			}
		} else {
			if {$is_cols} {
				set colmode "Fr"
			} else {
				set colmode "F"
			}
		}
	}
	set colcmd [file join $evv(CDPROGRAM_DIR) columns]
	lappend colcmd $thisfile 
	if {($colmode == "sE") || ($colmode == "sS") || ($colmode == "iE")} {
		foreach line [$tabed.bot.itframe.l.list get 0 end] {
			foreach item $line {
				if {![IsNumeric $item]} {
					ForceVal $tabed.message.e "This option only works with numeric data"
				 	$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
		}
	}
	if {$colmode == "iE"} {
		set cnt 0
		foreach line [$tabed.bot.itframe.l.list get 0 end] {
			set line [string trim $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				incr cnt
				if {$cnt == 1} {
					if {![Flteq $item 0.0]} {
						lappend outlist 0
						lappend outlist $item
					} else {
						;# 0.0 val is deleted
					}
				} else {
					lappend outlist $item
				}
			}
		}
		set len [llength $outlist]
		incr len -1
		if {($len < 2) || ![IsEven $len]} {
			ForceVal $tabed.message.e "Invalid output table generated."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		incr len -1
		set outlist [lrange $outlist 0 $len]
		foreach {a b} $outlist {
			set line $a
			append line " " $b
			$tb.otframe.l.list insert end $line
		}
		set docol_OK 1
	} elseif {$colmode == "sS"} {
		if {([string length $colpar] <= 0) || ![IsNumeric $colpar] || ($colpar <= 0.0)} {
			ForceVal $tabed.message.e "Require \"N\" to be a valid endtime for the output data."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}	
		set cnt 0
		set lastvval 0.0
		foreach line [$tabed.bot.itframe.l.list get 0 end] {
			set line [string trim $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				incr cnt
				if {($cnt == 1) && [Flteq $item 0.0]} {
					continue
				}
				if {$item <= $lastvval} {
					ForceVal $tabed.message.e "Input table must have increasing times (all greater than zero)."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				lappend outlist $item
				set lastvval $item
			}
		}
		if {$colpar <= [lindex $outlist end]} {
			ForceVal $tabed.message.e "Endtime (N = $colpar) must be beyond end ([lindex $outlist end]) of listed times."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set lastvval 0.0
		set len [llength $outlist]
		set kk 0
		catch {unset lines}
		while {$kk < $len} {
			set vval [lindex $outlist $kk]
			set line [list $lastvval $vval]
			lappend lines $line
			set lastvval $vval
			incr kk
		}
		set line [list $lastvval $colpar]
		lappend lines $line
		foreach line $lines {
			$tb.otframe.l.list insert end $line
		}
		set docol_OK 1
	} else {
		if {![TestColParam $colmode]} {
			ForceVal $tabed.message.e "Parameter value missing"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$record_temacro} {
			lappend temacro $lmo
			set zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		DisableOutputTableOptions 1
		set colparam -$colmode
		if {[info exists nucolpar]} {
			append colparam $nucolpar
		} else {
			append colparam $colpar
		}
		lappend colcmd $colparam
		set docol_OK 0

		set sloom_cmd [linsert $colcmd 1 "#"]

		if [catch {open "|$sloom_cmd"} CDPcolrun] {
			ErrShow "$CDPcolrun"
   		} else {
   			fileevent $CDPcolrun readable "DisplayNewColumn $tb.otframe.l.list"
			vwait docol_OK
   		}
	}
	if {$docol_OK} {
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
	} else {
		DisableOutputTableOptions 1
	}
}

#------ Join files into a single output table

proc ColJoin {colmode} {
	global col_files_list col_fnames outcolcnt CDPcolrun docol_OK tot_outlines pa record_temacro temacro evv
	global lmo col_ungapd_numeric colpar tot_inlines tabedit_ns tabedit_bind2 ot_has_fnams colinmode temacrop threshold
	global col_tabname col_infnam tabed couldbe_seq2 last_couldbe_seq2

	set orig_mode ""
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	HaltCursCop
	set lmo J
	lappend lmo $col_ungapd_numeric $colmode
	set tb $tabed.bot
	ForceVal $tabed.message.e ""
	$tabed.message.e config -bg [option get . background {}]
	if {$ot_has_fnams} {						 ;#	If new fnames entered, use them - else use previous
		catch {unset col_files_list}
		foreach fnam [$tb.otframe.l.list get 0 end] {
			lappend col_files_list $fnam
		}
	}
	if {![info exists col_files_list] || ([set len [llength $col_files_list]] <= 0)} {
		ForceVal $tabed.message.e "No files selected."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {($colmode == "j") || ($colmode == "Jj") || [string match e* $colmode] || $colmode == "Wb" || $colmode == "Kb" \
	|| $colmode == "wt" || $colmode == "wo" || $colmode == "ss" || $colmode == "rf" || $colmode == "mm"} {
		if {$len != 2} {
			ForceVal $tabed.message.e  "This option only works with TWO files."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {[string match E* $colmode]} {
		if {$len != 2} {
			ForceVal $tabed.message.e  "This option only works with TWO files."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists colpar] || ![regexp {^[0-9]+$} $colpar] || ($colpar < 1)} {
			ForceVal $tabed.message.e  "Invalid Firstfile Column number in 'N'."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists threshold] || ![regexp {^[0-9]+$} $threshold] || ($threshold < 1)} {
			ForceVal $tabed.message.e  "Invalid Secondfile Column number in 'threshold'."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {$colmode == "WD"} {
		if {$len < 2} {
			ForceVal $tabed.message.e  "This option only works with TWO OR MORE files."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {$colmode == "Su"} {
		if {$len != 2} {
			ForceVal $tabed.message.e  "This option only works with TWO files."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists colpar] || ![regexp {^[0-9]+$} $colpar] || ($colpar < 1)} {
			ForceVal $tabed.message.e  "Invalid Cycle step in 'N'."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists threshold] || ![regexp {^[0-9]+$} $threshold] || ($threshold < 1)} {
			ForceVal $tabed.message.e  "Invalid startline in 'threshold'."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$threshold > $pa([lindex $col_files_list 0],$evv(LINECNT))} {
			ForceVal $tabed.message.e  "Invalid startline in 'threshold'. Too large for 1st file."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if {$colmode == "Kb"} {
		if {!$couldbe_seq2} {
			ForceVal $tabed.message.e  "Incompatible files (not multisound-type, or using different no. of sounds)"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if {[string match Z* $colmode] || [string match Ae $colmode]} {
		foreach fnam $col_files_list {
			if {![IsANormdBrkfile $pa($fnam,$evv(FTYP))]} {
				ForceVal $tabed.message.e  "This option only works with normalised breakpoint files."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	} elseif [string match Ab $colmode] {
		foreach fnam $col_files_list {
			if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
				ForceVal $tabed.message.e  "This option only works with breakpoint files."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		set colmode "Ae"
	} elseif [string match e* $colmode] {
		switch -- [string index $colmode 1] {
			"m" -
			"s" -
			"i" {
				foreach fnam $col_files_list {
					if {![IsANormdBrkfile $pa($fnam,$evv(FTYP))]} {
						ForceVal $tabed.message.e  "This option only works with normalised breakpoint files."
						$tabed.message.e config -bg $evv(EMPH)
						return
					}
				}
			}
			"X" {
				set fnam [lindex $col_files_list 0]
				if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
					ForceVal $tabed.message.e  "This option only works when 1st file is a brkpoint file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set fnam [lindex $col_files_list 1]
				if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
					ForceVal $tabed.message.e  "This option only works when 2nd file is a brkpnt file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			"Q" {
				set fnam [lindex $col_files_list 0]
				if {![IsAListofNumbers $pa($fnam,$evv(FTYP))] || !($pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST))} {
					ForceVal $tabed.message.e  "This option only works when 1st file is a sequence file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set fnam [lindex $col_files_list 1]
				if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
					ForceVal $tabed.message.e  "This option only works when 2nd file is a brkpnt file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			"L" {
				set fnam [lindex $col_files_list 0]
				if {![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
					ForceVal $tabed.message.e  "This option only works when 1st file is a list of numbers."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set fnam [lindex $col_files_list 1]
				if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
					ForceVal $tabed.message.e  "This option only works when 2nd file is a brkpnt file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			"w" {
				set fnam [lindex $col_files_list 0]
				if {![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
					ForceVal $tabed.message.e  "This option only works when 1st file is a list of times."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set fnam [lindex $col_files_list 1]
				set ftype $pa($fnam,$evv(FTYP))
				if {$ftype == $evv(MIX_MULTI)} {
					ForceVal $tabed.message.e  "This option only works when 2nd file is positive valued brkpnt file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				if {!(($ftype & $evv(IS_A_TRANSPOS_BRKFILE)) \
				||  ($ftype & $evv(IS_A_NORMD_BRKFILE)) \
				||  ($ftype & $evv(POSITIVE_BRKFILE)))} {
					ForceVal $tabed.message.e  "This option only works when 2nd file is positive valued brkpnt file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			"W" {
				set fnam [lindex $col_files_list 0]
				if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
					ForceVal $tabed.message.e  "This option only works when 1st file is a brkpoint file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set fnam [lindex $col_files_list 1]
				set ftype $pa($fnam,$evv(FTYP))
				if {$ftype == $evv(MIX_MULTI)} {
					ForceVal $tabed.message.e  "This option only works when 2nd file is positive valued brkpnt file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				if {!(($ftype & $evv(IS_A_TRANSPOS_BRKFILE)) \
				||  ($ftype & $evv(IS_A_NORMD_BRKFILE)) \
				||  ($ftype & $evv(POSITIVE_BRKFILE)))} {
					ForceVal $tabed.message.e  "This option only works when 2nd file is positive valued brkpnt file."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			"a" -
			"A" -
			"S" -
			"M" {
				foreach fnam $col_files_list {
					if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
						ForceVal $tabed.message.e  "This option only works with breakpoint files."
						$tabed.message.e config -bg $evv(EMPH)
						return
					}
				}
				if [string match "eM" $colmode] {
					set colmode "es"		  	;#	Same function on different filetype
				}
			}
		}
	}
	if {$colmode == "es" || $colmode == "ei" || $colmode == "j" || $colmode == "Jj"} {
		if {![info exists colpar] || ![IsNumeric $colpar]} {
			ForceVal $tabed.message.e  "No insertion position given."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			append colmode $colpar
		}
	} elseif {$colmode == "ea" || $colmode == "Za"} {
		set colmode "ea"
		if {![info exists colpar] || ![IsNumeric $colpar] || ($colpar <= 0.0)} {
			ForceVal $tabed.message.e  "No valid append time given."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			append colmode $colpar
		}				
	} elseif {($colmode == "Wb") || ($colmode == "Kb")} {
		if {![info exists colpar] || ![IsNumeric $colpar] || ($colpar <= 0.0)} {
			ForceVal $tabed.message.e  "No valid timestep value (N) given."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			append colmode $colpar
		}				
	} elseif {$colmode == "ss"} {
		if {![info exists colpar] || ![regexp {^[0-9]+$} $colpar] || ($colpar < 1)} {
			ForceVal $tabed.message.e  "Invalid column value in 'N'."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists threshold] || ![regexp {^[0-9]+$} $threshold] || ($threshold < 1)} {
			ForceVal $tabed.message.e  "Invalid column value in 'threshold'."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {$colmode == "rf"} {
		set fnam [lindex $col_files_list 0]
		if {![info exists pa($fnam,$evv(FTYP))]} {
			ForceVal $tabed.message.e  "Cannot find Workspace data on file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ftyp $pa($fnam,$evv(FTYP))
		if {![IsASndlist $ftyp]} {
			ForceVal $tabed.message.e  "File $fnam is not a list of soundfile names."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[ChlistDupls] != 0} {
			ForceVal $tabed.message.e  "Chosen Files list contains duplicates: cannot proceed."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if [string match Z* $colmode] {		;#	convert Zx -> ex, Zs -> es
		set orig_mode $colmode
		set q [string index $colmode 1]
		set colmode "e"
		append colmode $q
	}
	if {$len < 2} {
		switch -- $colmode {
			"Wb" -
			"Kb" -
			"Wd" -
			"Ae" -
			"jj" -
			"Cc" -
			"kf" -
			"J" {
				ForceVal $tabed.message.e  "At least 2 files required for this option."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}								;# file order essential with warping-of-time, & data concatenation.
	} elseif {($colmode =="C") || ($colmode == "ew") || ($colmode == "eW") || ($colmode == "eY") || ($colmode == "em") \
	|| ($colmode == "eL") || ($colmode == "eX") || ($colmode == "mX") || ($colmode == "eQ") || ($colmode == "eZ")} {
		set col_fnames $col_files_list
	} elseif {($orig_mode == "Zs") || ($colmode == "ss") || ($colmode == "rf")} {	  	;# Order irrelevant with superimposed envelopes
		set col_fnames $col_files_list							
	} else {
		if {![OrderColumnFiles]} {
			return
		}
	}
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$colmode != "kf"} {
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set outcolcnt 0
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines 0
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	}
	DisableOutputTableOptions 0

	if {$colmode == "Wd"} {
		set docol_OK [JoinTables $col_fnames]
	} elseif {$colmode == "WD"} { 
		set docol_OK [InterpJoinTables $col_fnames]
	} elseif {$colmode == "ss"} { 
		set docol_OK [OrderByColumn]
	} elseif {$colmode == "rf"} { 
		set docol_OK [RenameTableFiles]
	} elseif {$colmode == "mm"} { 
		set docol_OK [ExcludeSndsFromMix $col_fnames]
	} elseif {$colmode == "Su"} { 
		set fnam [lindex $col_files_list 0]
		if [catch {open $fnam r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				lappend in_lines $line
			}
		}
		close $zit
		set fnam [lindex $col_files_list 1]
		if [catch {open $fnam r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				lappend in_lines2 $line
			}
		}
		close $zit
		set cnt1 0
		set cnt2 0
		set qq $threshold
		incr qq -1
		foreach line $in_lines {
			if {$cnt1 == $qq} {
				incr qq $colpar
				lappend outlines [lindex $in_lines2 $cnt2]
				incr cnt2
				if {$cnt2 >= [lindex $in_lines2 end]} {
					set qq -1
				}
			} else {
				lappend outlines $line
			}
			incr cnt1
		}
		set to $tabed.bot.otframe.l.list
		$to delete 0 end
		foreach line $outlines {
			$to insert end $line
		}
		set docol_OK 1
	} elseif {$colmode == "E" || $colmode == "En"} { 
		set loc $colpar
		incr loc -1
		set loct $threshold
		incr loct -1
		set fnam [lindex $col_files_list 1]
		if [catch {open $fnam r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				if {[llength $nuline] >= $threshold} {
					lappend in_vals [lindex $nuline $loct]
				}
			}
		}
		close $zit
		if {![info exists in_vals]} {
			ForceVal $tabed.message.e  "Insufficient columns in file '$fnam'."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set fnam [lindex $col_files_list 0]
		if [catch {open $fnam r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set linecnt 0
		while {[gets $zit line] >= 0} {
			incr linecnt
			set line [string trim $line]
			if {[string length $line] > 0} {
				set origline $line
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				if {[llength $nuline] < $colpar} {
					ForceVal $tabed.message.e  "Insufficient columns in row $linecnt of file '$fnam'."
					$tabed.message.e config -bg $evv(EMPH)
					close $zit
					return
				}
				switch -- $colmode {
					"En" {
						if {[lsearch $in_vals [lindex $nuline $loc]] >= 0} {
							lappend outlines $origline
						}
					}
					"E" {
						if {[lsearch $in_vals [lindex $nuline $loc]] < 0} {
							lappend outlines $origline
						}
					}
				}
			}
		}
		close $zit
		if {![info exists outlines]} {
			ForceVal $tabed.message.e  "No rows of file '$fnam' satisfy these criteria."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set to $tabed.bot.otframe.l.list
		$to delete 0 end
		foreach line $outlines {
			$to insert end $line
		}
		set docol_OK 1
	} elseif {$colmode == "kf"} {
		set docol_OK 1
	} elseif {$colmode == "eZ"} {
		if {[llength $col_files_list] != 2} {
			ForceVal $tabed.message.e  "Select a mixfile and a warpfile."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set fnam [lindex $col_files_list 1]
		if {![IsABrkfile $pa($fnam,$evv(FTYP))] || ($pa($fnam,$evv(MINBRK)) <= $evv(FLTERR))} {
			ForceVal $tabed.message.e  "File $fnam is not a warp file."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif [catch {open $fnam "r"} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
			}
			lappend warplines $nuline
		}
		close $zit
		set fnam [lindex $col_files_list 0]
		if {![IsAMixfile $pa($fnam,$evv(FTYP))]} {
			ForceVal $tabed.message.e  "File $fnam is not a mix file."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif [catch {open $fnam r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set linecnt 0
		catch {unset mixlines}
		catch {unset mixtimes}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				if {[string match [string index $line 0] ";"]} {
					lappend mixlines $line
					continue
				}
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				lappend mixtimes [lindex $nuline 1]
				lappend mixlines $nuline
			}
		}
		close $zit
		set mixtimes [MixtimeWarp $mixtimes $warplines]
		catch {unset outlines}
		set n 0
		foreach line $mixlines {
			if {![string match [string index $line 0] ";"]} {
				set line [lreplace $line 1 1 [lindex $mixtimes $n]]
				incr n
			}
			lappend outlines $line
		}

		set to $tabed.bot.otframe.l.list
		$to delete 0 end
		foreach line $outlines {
			$to insert end $line
		}
		set docol_OK 1
	} elseif {$colmode == "mX"} {
		if {[llength $col_files_list] != 2} {
			ForceVal $tabed.message.e  "Select a mixfile and a warpfile."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set fnam [lindex $col_files_list 1]
		if {![IsABrkfile $pa($fnam,$evv(FTYP))] || ($pa($fnam,$evv(MINBRK)) <= $evv(FLTERR))} {
			ForceVal $tabed.message.e  "File $fnam is not a warp file."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif [catch {open $fnam "r"} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
			}
			lappend warplines $nuline
		}
		close $zit
		set fnam [lindex $col_files_list 0]
		if {![IsAMixfile $pa($fnam,$evv(FTYP))]} {
			ForceVal $tabed.message.e  "File $fnam is not a mix file."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif [catch {open $fnam r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set linecnt 0
		catch {unset mixlines}
		catch {unset mixtimes}
		catch {unset mlevels}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				if {[string match [string index $line 0] ";"]} {
					lappend mixlines $line
					continue
				}
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				lappend mixtimes [lindex $nuline 1]
				set thislevel [lindex $nuline 3]
				if {[llength $nuline] >= 6} {
					lappend thislevel [lindex $nuline 5]
				}
				lappend mlevels $thislevel
				lappend mixlines $nuline
			}
		}
		close $zit
		set mlevels [MixLevelWarp $mlevels $mixtimes $warplines]
		if {[llength $mlevels] <= 0} {
			ForceVal $tabed.message.e  "Mixfile times must be in increasing order."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		catch {unset outlines}
		set n 0
		foreach line $mixlines {
			if {![string match [string index $line 0] ";"]} {
				set line [lreplace $line 3 3 [lindex [lindex $mlevels $n] 0]]
				if {[llength $line] >= 6} {
					set line [lreplace $line 5 5 [lindex [lindex $mlevels $n] 1]]
				}
				incr n
			}
			lappend outlines $line
		}
		set to $tabed.bot.otframe.l.list
		$to delete 0 end
		foreach line $outlines {
			$to insert end $line
		}
		set docol_OK 1
	} else {
		set colcmd [file join $evv(CDPROGRAM_DIR) columns]
		foreach fnam $col_fnames {
			lappend colcmd $fnam
		}
		if {[string match Kb* $colmode]} {
			lappend colcmd $couldbe_seq2
		}
		lappend colcmd -$colmode
		set docol_OK 0
		set sloom_cmd [linsert $colcmd 1 "#"]
		if [catch {open "|$sloom_cmd"} CDPcolrun] {
			ErrShow "$CDPcolrun"
		} else {
  			fileevent $CDPcolrun readable "DisplayNewColumn $tb.otframe.l.list"
			vwait docol_OK
  		}
	}
	if {$docol_OK} {
		if {[WriteOutputTable $evv(LINECNT_NOT_RESET)]} {
			EnableOutputTableOptions 0 1
			switch -- $colmode {
				"es" -
				"ei" { set outcolcnt 2}
				"j" { set outcolcnt $incols}
				"J" { set outcolcnt [llength $col_fnames]}
				"C"  -
				"Cc" -
				"kf" -
				"R" { set outcolcnt 1}
			}
			ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		}
	} else {
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set tot_outlines 0
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		set outcolcnt 0
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	}
	set colinmode 0
	set ot_has_fnams 0
	ChangeColSelect 0
	catch {unset last_couldbe_seq2}
}

#------ Operations on a table to produce table out

proc EnvOp {colmode} {
	global outcolcnt CDPcolrun docol_OK tot_outlines pa lmo col_ungapd_numeric record_temacro temacro evv
	global lmo col_ungapd_numeric colpar tot_inlines tabedit_ns tabedit_bind2 temacrop threshold
	global col_tabname col_infnam tabed col_x

	HaltCursCop
	if {![info exists col_infnam] || ([string length $col_infnam] <= 0)} {
		ForceVal $tabed.message.e "No input table"
		return
	}
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	ForceVal $tabed.message.e ""
	$tabed.message.e config -bg [option get . background {}]

	if {($colmode == "bB") || ($colmode == "bE")} { 
		if {![IsABrkfile $pa($col_infnam,$evv(FTYP))]} {
			ForceVal $tabed.message.e  "This option only works with breakpoint files."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} 
	} elseif {![IsANormdBrkfile $pa($col_infnam,$evv(FTYP))]} {
		ForceVal $tabed.message.e  "This option only works with normalised breakpoint files."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tb $tabed.bot
	
	set lmo CO
	lappend lmo $col_ungapd_numeric $colmode

	if {$colmode == "eP"} {
		set i [$tb.itframe.l.list curselection]
		if {![info exists i] || ($i < 0)} {
			ForceVal $tabed.message.e  "No line selected."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		incr i
		set colpar $i
	}

	$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
	set outcolcnt 0
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines 0
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines

	DisableOutputTableOptions 0

	set colcmd [file join $evv(CDPROGRAM_DIR) columns]
	lappend colcmd $col_infnam
	switch -- $colmode {
		"eD" {
			if {[info exists colpar] && [IsNumeric $colpar]} {
				append colmode $colpar
			} else {
				ForceVal $tabed.message.e  "Parameter missing."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"Gg" {
			if {![info exists colpar]} {
				ForceVal $tabed.message.e  "Parameter missing."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![IsNumeric $colpar] || ($colpar <= 0.0) || ($colpar >= 1.0)} {
				ForceVal $tabed.message.e  "Invalid Parameter."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"eP" { 
			append colmode $colpar
		}
	}
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$colmode == "eB" || $colmode == "eE" || $colmode == "bB" || $colmode == "bE"} {
		if {![info exists colpar]} {
			ForceVal $tabed.message.e  "Parameter missing."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![IsNumeric $colpar]} {
			ForceVal $tabed.message.e  "Invalid Parameter N given."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$colmode == "eB" || $colmode == "eE"} {
			if {($colpar < 0.0) || ($colpar > 1.0)} {
				ForceVal $tabed.message.e  "Invalid Parameter N given."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		$tb.otframe.l.list delete 0 end
		if {$colmode == "eB" || $colmode == "bB"} {
			set line "0.000000 $colpar"
			$tb.otframe.l.list insert end $line
			foreach line [$tb.itframe.l.list get 0 end] {
				$tb.otframe.l.list insert end $line
			}	
		} else {
			foreach line [$tb.itframe.l.list get 0 end] {
				$tb.otframe.l.list insert end $line
			}	
			set line "1000.000 $colpar"
			$tb.otframe.l.list insert end $line
		}
		set docol_OK 1
	} elseif {$colmode == "Gg"} {
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			set time [lindex $line 0]
			set val [lindex $line end]
			if {$val <= $colpar} {
				set val 0.0
			} else {
				set val 1.0
			}
			set nuline [list $time $val]
			$tb.otframe.l.list insert end $nuline
		}
		set docol_OK 1
	} elseif {$colmode == "Ea"} {
		if {![CreateColumnParams $colmode 2]} {
			return
		}
		if {$col_x(1) <= 1.0} {
			ForceVal $tabed.message.e  "Attack gain must be 1.0 or more."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$col_x(2) <= 0.0} {
			ForceVal $tabed.message.e  "Attack risetime must be > 0.0."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		catch {unset times}
		catch {unset vals}
		catch {unset nutimes}
		catch {unset nuvals}
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			set time [lindex $line 0]
			set val [lindex $line end]
			lappend times $time
			lappend vals $val
		}
		set len [llength $times]
		if {$len <= 3} {
			ForceVal $tabed.message.e  "Insufficient lines to do this process."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set nutimes $times
		foreach val $vals {
			lappend nuvals 1.0									;#	START WITH A FLAT ENVELOPE
		}
		set k 0
		set m 1
		set n 2
		while {$n < $len} {
			set val_k [lindex $vals $k]
			set val_m [lindex $vals $m]
			set val_n [lindex $vals $n]
			set tim_k [lindex $times $k]
			set tim_m [lindex $times $m]
			if {($val_n > $val_m) && ($val_m > $val_k)} {		;#	ENVELOPE RISES TWICE
				set maxgain [expr 1.0/$val_m]
				set nuval [expr ($val_n / $val_m) * $col_x(1)]	;#	APPLY GAIN TO ENVELOPE
				if {$nuval > $maxgain} {
					set nuval $maxgain
				}
				set nuvals [lreplace $nuvals $m $m $nuval]
				set nutime [expr $tim_k + $col_x(2)]			;#	ADJUST TIME OF THIS SUDDEN RISE
				if {$nutime < $tim_m} {
					set nutimes [lreplace $nutimes $m $m $nutime]
				}
				set i $n
				set j $i
				incr j
				while {$j < $len} {								;#	MOVE OVER THE PEAK
					if {[lindex $vals $j] > [lindex $vals $i]} {
						incr i
						incr j
					} else {
						break
					}
				}
				set k $j
				set m [expr $j + 1]
				set n [expr $j + 2]
			} else {
				incr k
				incr m
				incr n
			}
		}
		foreach time $nutimes val $nuvals {
			set nuline [list $time $val]
			$tb.otframe.l.list insert end $nuline
		}
		set docol_OK 1
	}  elseif {$colmode == "Ep"} {
		$tb.otframe.l.list delete 0 end
		set nulist [GetEnvPeaks [$tb.itframe.l.list get 0 end]]
		if {[llength $nulist] > 0} {
			foreach line $nulist {
				$tb.otframe.l.list insert end $line
			}
			if {[WriteOutputTable $evv(LINECNT_RESET)]} {
				EnableOutputTableOptions 0 1
				return
			}
		}
		set docol_OK 0
	}  else {
		lappend colcmd -$colmode
		set docol_OK 0
		set sloom_cmd [linsert $colcmd 1 "#"]
		if [catch {open "|$sloom_cmd"} CDPcolrun] {
			ErrShow "$CDPcolrun"
		} else {
  			fileevent $CDPcolrun readable "DisplayNewColumn $tb.otframe.l.list"
			vwait docol_OK
  		}
	}
	if {$docol_OK} {
		if {[WriteOutputTable $evv(LINECNT_NOT_RESET)]} {
			EnableOutputTableOptions 0 1
			switch -- $colmode {
				"eD" { 
					set outcolcnt $incols
					ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
				}
			}
		}
	} else {
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set tot_outlines 0
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		set outcolcnt 0
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	}
}

#------ Allow user to put selected files into desired order

proc OrderColumnFiles {} {
	global col_files_list col_fnames pr_colorder tabed evv

	ForceVal $tabed.message.e  ""
 	$tabed.message.e config -bg [option get . background {}]
	if {[llength $col_files_list] < 2} {
		ForceVal $tabed.message.e  "At least 2 files required for this option."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set f .colorder
	if [Dlg_Create $f "Arrange Files in Order" "set pr_colorder 0" -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(SBDR)] 
		set f2 [frame $f.2 -borderwidth $evv(SBDR)] 
		button $f1.ok1 -text "Use Original"  -width 12 -command "set pr_colorder 2" -highlightbackground [option get . background {}]
		button $f1.ok2 -text "Use Reordered" -width 12 -command "set pr_colorder 1" -highlightbackground [option get . background {}]
		button $f1.quit -text "Close" -command "set pr_colorder 0" -highlightbackground [option get . background {}]
		pack $f1.ok1 $f1.ok2 -side left -padx 1
		pack $f1.quit -side right
		set ffl [frame $f2.l -borderwidth $evv(SBDR)] 
		set ffr [frame $f2.r -borderwidth $evv(SBDR)] 
		label $ffl.name -text "Original Files"
		set choices [Scrolled_Listbox $ffl.choices -width 20 -height 10]
		label $ffr.name -text "Reordered Files"
		set picked  [Scrolled_Listbox $ffr.picked -width 20 -height 10]
		pack $ffl.name $ffl.choices -side top
		pack $ffr.name $ffr.picked -side top
		pack $f2.l $f2.r -side left -fill both
		bind $choices <ButtonRelease-1> "ListTransferSel %W $picked"
		bind $picked <ButtonRelease-1> {ListDeleteSel %W}
		pack $f.1 $f.2 -side top -fill both
		wm resizable $f 1 1
		bind $f <Escape>  {set pr_colorder 0}
	}
	.colorder.2.l.choices.list delete 0 end
	.colorder.2.r.picked.list delete 0 end
	foreach fnam $col_files_list {
		.colorder.2.l.choices.list insert end $fnam
	}
	set pr_colorder 0
	set finished 0
	My_Grab 0 $f pr_colorder
	while {!$finished} {
		tkwait variable pr_colorder
		if {$pr_colorder > 0} {
			catch {unset col_fnames}
			if {$pr_colorder > 1} {					
				foreach fnam [.colorder.2.l.choices.list get 0 end] {
					lappend col_fnames $fnam
				}
				set finished 1
			} else {
				set i 0
				foreach fnam [.colorder.2.r.picked.list get 0 end] {
					lappend col_fnames $fnam
					incr i
				}
				switch -- $i {
					"0" {	Inf "No files selected" }
					"1" {	Inf "Only one file selected: At least two required." }
					default { set finished 1 }
				}
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $pr_colorder
}

proc ListTransferSel {src dst} {
	foreach i [$src curselection] {
		$dst insert end [$src get $i]
	}
}

proc ListDeleteSel {src} {
	foreach i [lsort -integer -decreasing [$src curselection]] {
		$src delete $i
	}
}

#------ Trim Out Column to a defined size

proc TrimColumn {colmode} {
	global colpar coltype rcolno inlines tot_inlines outlines last_oc last_cr tabed evv
	global col_ungapd_numeric lmo orig_inlines orig_incolget insitu record_temacro temacro temacrop threshold

	HaltCursCop
	if {![info exists inlines] || ($inlines <= 0)} {
		ForceVal $tabed.message.e "No input column to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set lmo T
	lappend lmo $col_ungapd_numeric $colmode
	set n "normal"
	set d "disabled"
	set tb $tabed.bot
	
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set do_trim 0
	set q [string index $colmode 0]
	switch -- $q {
		"m" {
			set insitu 0	   				;#	Force action to output column
			LiteCol "o"
			set fnam $evv(COLFILE2)

			if [info exists inlines] {
				set do_trim [expr $outlines - $inlines]
			} else {
				set do_trim [expr $outlines - $tot_inlines]
			}
		}
		"t" {
			if {$insitu} {
				set fnam $evv(COLFILE1)
			} else {
				set fnam $evv(COLFILE2)
			}
			if {([string length $colmode] > 2) && ([string index $colmode 2] == "1")} {	;#	tt1 tb1
				set $colmode [string range $colmode 0 1]
				set colpar [expr $inlines - 1]
			}
			if {[string length $colpar] > 0} {
				if {$colpar > 0} {
					set do_trim [expr $inlines - $colpar]
				} else {
					ForceVal $tabed.message.e "Impossible value of parameter N"
				 	$tabed.message.e config -bg $evv(EMPH)
					return
				}
			} else {
				ForceVal $tabed.message.e "No parameter entered"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	}
	if {$do_trim <= 0} {
		ForceVal $tabed.message.e "Can't delete this many lines."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if [catch {open $fnam "w"} cfileId] {
		ForceVal $tabed.message.e "Cannot open temporary file $fnam to write trimmed data"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {!$insitu} {
		set last_oc [$tb.ocframe.l.list get 0 end]
		set last_cr $col_ungapd_numeric
	}
	set qq [string index $colmode 1]
	switch -- $q {
		"m" {
			switch -- $qq {
				"b" {
					set do_trim [expr $outlines - $do_trim]
					set outlines $do_trim
					ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
					$tb.ocframe.l.list delete $do_trim end
				}
				"t" {
					incr outlines -$do_trim
					ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
					incr do_trim -1
					$tb.ocframe.l.list delete 0 $do_trim
				}
			}
		}
		"t" {
			switch -- $qq {
				"b" {
					set do_trim [expr $inlines - $do_trim]
					if {$insitu} {
						set inlines $do_trim
						ForceVal $tb.icframe.dummy.cnt $inlines
						incr do_trim -1
						foreach item [$tb.icframe.l.list get 0 $do_trim] {
							lappend tmp $item
						}
						$tb.icframe.l.list delete 0 end
						foreach item $tmp {
							$tb.icframe.l.list insert end $item
						}
					} else {
						set outlines $do_trim
						ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
						incr do_trim -1
						$tb.ocframe.l.list delete 0 end
						foreach item [$tb.icframe.l.list get 0 $do_trim] {
							$tb.ocframe.l.list insert end $item
						}
					}
				}
				"t" {
					if {$insitu} {
						foreach item [$tb.icframe.l.list get $do_trim end] {
							lappend tmp $item
						}
						$tb.icframe.l.list delete 0 end
						foreach item $tmp {
							$tb.icframe.l.list insert end $item
						}
						set inlines [expr $inlines - $do_trim]
						ForceVal $tb.icframe.dummy.cnt $inlines
					} else {
						$tb.ocframe.l.list delete 0 end
						foreach item [$tb.icframe.l.list get $do_trim end] {
							$tb.ocframe.l.list insert end $item
						}
						set outlines [expr $inlines - $do_trim]
						ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
					}
				}
			}
		}
	}
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$insitu} {
		foreach item [$tb.icframe.l.list get 0 end] {
			puts $cfileId $item
		}
	} else {
		foreach item [$tb.ocframe.l.list get 0 end] {
			puts $cfileId $item
		}
	}
	close $cfileId
	if {!$insitu} {
		if {[info exists tot_inlines] && ($tot_inlines > 0)} {
			if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
				SetKCState "o"
			} elseif {$outlines == $tot_inlines} {
				set coltype "i"
				$tb.kcframe.oki config -state $n
				$tb.kcframe.oko config -state $d
				$tb.kcframe.okr config -state $n
				if [info exists inlines] {
					set rcolno $orig_incolget
				}
				ForceVal $tb.kcframe.e $rcolno
				$tb.kcframe.e config -state $n -foreground [option get . foreground {}]
			} else {
				SetKCState "k"
			}
		} elseif {[info exists tot_outlines] && ($tot_outlines > 0) \
		&& ($outlines == $tot_outlines)} {
		 	SetKCState "i"
		} else {
			SetKCState "k"
		}
		ForceVal $tb.kcframe.e $rcolno
		$tb.kcframe.okk config -state $n
		$tb.kcframe.oky config -state $n
		$tb.kcframe.okz config -state $n
		$tb.kcframe.ok config -state $n
	}
}

#------ Restore Out Column to previous state

proc RestoreColumn {} {
	global coltype tot_inlines outlines
	global last_oc last_cr col_ungapd_numeric orig_inlines tabed evv

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set n "normal"
	set d "disabled"
	set tb $tabed.bot

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists last_oc] || ([llength $last_oc] <= 0)} {
		return
	}
	if [catch {open $evv(COLFILE2) "w"} cfileId] {
		ForceVal $tabed.message.e "Cannot open temporary file $evv(COLFILE2) to write restored data"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if [info exists last_cr] {
		set col_ungapd_numeric $last_cr
	}
	$tb.ocframe.l.list delete 0 end
	set outlines 0
	foreach item $last_oc {
		$tb.ocframe.l.list insert end $item
		puts $cfileId $item
		incr outlines
	}
	ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	close $cfileId
	$tb.kcframe.oky config -state $n
	$tb.kcframe.okz config -state $n
	if {!$col_ungapd_numeric} {
		SetKCState "k"
		$tb.kcframe.oky config -state $d
		$tb.kcframe.okz config -state $d
	} elseif {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
		SetKCState "o"
	} elseif {[info exists tot_inlines] && ($tot_inlines == $outlines)} {
		SetKCState 1
	} else {
		SetKCState "k"
	}
}

#------ Create a new column fron scratch

proc CreateNewColumn {colmode p_cnt} {
	global threshold CDPcolrun docol_OK outlines threshtype tedit_message last_oc evv
	global inlines tot_inlines coltype rcolno orig_incolget tround col_x cc_out tabed
	global last_cr col_ungapd_numeric tot_outlines ocl lmo orig_inlines insitu colpar record_temacro temacro temacrop

	HaltCursCop

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set lmo C
	lappend lmo $col_ungapd_numeric $colmode $p_cnt
	set tb $tabed.bot

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {$insitu} {
		set ll $tb.icframe.l.list
		set lcnt "inlines"
		set zfile $evv(COLFILE1)
	} else {
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
		set zfile $evv(COLFILE2)
	}
	if {!$insitu} {
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		DisableOutputColumnOptions
	}
	$ll delete 0 end		;#	Clear existing listing of column
	set $lcnt 0				;#	Set col linecnt to zero
	if {$lcnt == "inlines"} {
		ForceVal $tb.icframe.dummy.cnt $inlines
	} else {
		ForceVal $tb.ocframe.dummy.cnt $outlines
	}
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$colmode == "Iip"} {
		if {![info exists colpar] || ([string length $colpar] <= 0)} {
			ForceVal $tabed.message.e "No parameter given"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			$ll insert end $colpar
			set docol_OK 1
		}
	} elseif {$colmode == "Ii" || $colmode == "Iis"} {
		set docol_OK 0
		ScratchCol $colmode
		if {[info exists ocl] && ([llength $ocl] > 0)} {
			foreach item $ocl {
				$ll insert end $item
			}
			set docol_OK 1
		} else {
			set docol_OK 0
		}
		catch {unset ocl}
	} elseif {$colmode == "tT"} {
		set docol_OK 0
		DoTimer
		if {[info exists ocl] && ([llength $ocl] > 0)} {
			foreach item $ocl {
				$ll insert end $item
			}
			set docol_OK 1
		} else {
			set docol_OK 0
		}
		catch {unset ocl}
	} elseif [string match S* $colmode] {
		TabSndsDur $colmode
		if {[info exists ocl] && ([llength $ocl] > 0)} {
			foreach item $ocl {
				$ll insert end $item
			}
			set docol_OK 1
		} else {
			set docol_OK 0
		}
	} elseif {$colmode == "iE"} {

		if {([string length $threshold] <= 0) || ![IsNumeric $threshold]} {
			set tedit_message "Must have positive integer in  'threshold'"
			ForceVal $tabed.message.e $tedit_message
		 	$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
		} else {
			set threshold [expr int(round($threshold))]
			if {$threshold <= 0} {
				set tedit_message "Must have positive integer in  'threshold'"
				ForceVal $tabed.message.e $tedit_message
			 	$tabed.message.e config -bg $evv(EMPH)
				set docol_OK 0
			} elseif {[string length $colpar] <= 0} {
				set tedit_message "No entry made in 'N'"
				ForceVal $tabed.message.e $tedit_message
			 	$tabed.message.e config -bg $evv(EMPH)
				set docol_OK 0
			} else {
				set hj 0
				while {$hj < $threshold} {	
					$ll insert end $colpar
					incr hj
				}
				set docol_OK 1
			}
		}
	} elseif {($colmode == "H") || ($colmode == "O")} {
		if {![info exists colpar] || ([string length $colpar] <= 0)} {
			ForceVal $tabed.message.e "Missing parameter N (fundamental note, or frequency)"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {[IsNumeric $colpar]} {
			if {$colpar <= 1.0} {
				ForceVal $tabed.message.e "Invalid frequency in parameter N: must be positive number >= 1.0"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set frqq $colpar
		} else {
			set frqq [NoteToFrq $colpar]
			if {$frqq <= 0.0} {
				ForceVal $tabed.message.e "Bad note in param N (C-6 to B6: see representation in CALCULATOR)"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}					
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set hrqq $frqq

		if {$colmode == "H"} {
			while {$hrqq < 24000} {
				$ll insert end $hrqq
				set hrqq [expr $hrqq + $frqq]
			}
		} else {
			while {$hrqq < 24000} {
				$ll insert end $hrqq
				set hrqq [expr $hrqq * 2.0]
			}
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "P"} {
		set var [GetLastRunParams]
		if {[llength $var] <= 0} {
			return
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		foreach item $var {
			$ll insert end $item
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {($colmode == "FS") || ($colmode == "fs")} {
		set colpar ""
		set threshold ""
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set f1 1
		set f2 1
		if {$colmode == "FS"} {
			$ll insert end 1
			$ll insert end 1
			set fcnt 2
		} else {
			$ll insert end 1
			set fcnt 1
		}
		set gold "1."
		append gold [string range $evv(GOLDEN) 2 end]
		set fibratio 1
		while {![string match $fibratio $gold]} {
			set f3 [expr $f1 + $f2]
			set fibratio [DecPlaces [expr double($f3) / double($f2)] 6]
			if {$colmode == "FS"} {
				$ll insert end $f3
			} else {
				$ll insert end $fibratio
			}
			set f1 $f2
			set f2 $f3
			incr fcnt
		}
		if {$colmode == "FS"} {
			ForceVal $tabed.message.e "Last 2 terms are in Golden Ratio (to within 6 decimal places)"
		} else {
			ForceVal $tabed.message.e "Reached Golden Ratio (to within 6 decimal places)"
		}
 		$tabed.message.e config -bg $evv(EMPH)
		set docol_OK 1
	} elseif {$colmode == "Ic"} {
		if {![info exists colpar] || ([string length $colpar] <= 0)} {
			ForceVal $tabed.message.e "Missing repetitions value N"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {![IsNumeric $colpar] || ![regexp {^[0-9]+$} $colpar] || ($colpar < 2)} {
			ForceVal $tabed.message.e "Invalid Repetitions parameter N: must be positive number >= 2"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set sum 0.0
		set outvals $sum
		catch {unset invals}
		foreach val [$tb.icframe.l.list get 0 end] {
			lappend invals $val
		}
		if {![info exists invals]} {
			ForceVal $tabed.message.e "No input column to process."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach val $invals {
			set n 0
			while {$n < $colpar} {
				set sum [expr $sum + $val]
				lappend outvals $sum
				incr n
			}
		}
		set len [llength $outvals]
		incr len -2
		set outvals [lrange $outvals 0 $len]
		set threshold ""
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		foreach val $outvals {
			$ll insert end $val
			incr $lcnt
		}
		set docol_OK 1
	} else {
		set docol_OK 0
		if {![CreateColumnParams $colmode $p_cnt]} {
			return
		}
		if {!$cc_out} {
			set $lcnt ""
			if {$lcnt == "inlines"} {
				ForceVal $tb.icframe.dummy.cnt $inlines
			} else {
				ForceVal $tb.ocframe.dummy.cnt $outlines
			}
			return
		}
		if {$colmode == "ZA"} {
			set docol_OK [DoAdvance $col_x(1) $col_x(2) $col_x(3) $col_x(4) $col_x(5) $ll]
		} elseif {$colmode == "Td"} {
			if {$col_x(1) <= 0} {
				ForceVal $tabed.message.e "Bad Value for Meter"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$col_x(2) <= 0} {
				ForceVal $tabed.message.e "Bad Duration Value"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$insitu} {
				set ll $tb.icframe.l.list
				set lcnt "inlines"
			} else {
				set ll $tb.ocframe.l.list
				set lcnt "outlines"
			}
			$ll delete 0 end
			set $lcnt 0
			set step [expr 60.0 / double($col_x(1))]
			set val 0.0
			while {$val <= $col_x(2)} {
				$ll insert end $val
				incr $lcnt
				set val [DecPlaces [expr $val + $step] 4]
			}
			set docol_OK 1
		} else {
			set colcmd [file join $evv(CDPROGRAM_DIR) columns]
			lappend colcmd $evv(COLFILE1)
			set i 1
			while {$i <= $p_cnt} {
				lappend colcmd $col_x($i)
				incr i
			}
			lappend colcmd -$colmode
			set sloom_cmd [linsert $colcmd 1 "#"]
			if [catch {open "|$sloom_cmd"} CDPcolrun] {
				ErrShow "$CDPcolrun"
	   		} else {
	   			fileevent $CDPcolrun readable "DisplayNewColumn $ll"
				vwait docol_OK
	   		}
		}
	}
	if {$docol_OK} {
		WriteOutputColumn $zfile $ll $lcnt 1 0 1
	} else {
		$ll delete 0 end		;#	Clear existing listing of output 
		set $lcnt ""
		set k $lcnt
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $k
		} else {
			ForceVal $tb.ocframe.dummy.cnt $k
		}
	}
}

#------ Dialog to get parameters for Create columns options

proc CreateColumnParams {colmode p_cnt} {
	global pr_cc cc_out last_colmode col_x last_col_x inlines tabed bbbatch chlist wstk evv advecval truncvecval

	catch {destroy .cpd}
	set callcentre [GetCentre [lindex $wstk end]]

	set f .colcreate
	if [Dlg_Create $f "Table Creation Parameters" "set pr_cc 0" -borderwidth $evv(BBDR)] {
		
		label $f.name -text "" -width 60 
		frame $f.pp -borderwidth $evv(SBDR)
		label $f.pp.lab -text "PARAMETERS"
		button $f.pp.prev  -text "Recall Values" -width 11 -command "PreviousColParams $f $p_cnt" -highlightbackground [option get . background {}]
		button $f.pp.clear -text "Clear Values" -width 11 -command "ClearColParams $f" -highlightbackground [option get . background {}]
		button $f.pp.calc -text "Calculator" -width 11 -command "MusicUnitConvertor 0 0" -highlightbackground [option get . background {}] ;# -bg $evv(HELP)
		pack $f.pp.lab -side left -padx 1
		pack $f.pp.calc $f.pp.clear $f.pp.prev -side right -padx 1
		set i 1
		while {$i <= 8} {
			frame $f.$i -borderwidth $evv(SBDR)
			incr i
		}
		frame $f.9 -borderwidth $evv(SBDR)
		button $f.9.ok   -text "OK" -command "set pr_mu 1 ; set pr_cc 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		entry $f.9.e   -text "" -width 40
		button $f.9.quit -text "Close" -command "set pr_mu 1 ; set pr_cc 0" -highlightbackground [option get . background {}]
		pack $f.9.ok -side left -padx 1
		pack $f.9.quit $f.9.e -side right -padx 1
		frame $f.10 -borderwidth $evv(SBDR)
		frame $f.11 -borderwidth $evv(SBDR)
		set i 1
		while {$i <= 8} {
			label $f.$i.x -text "" -width 2
			entry $f.$i.xe -textvariable col_x($i) -width 12 -state disabled -disabledbackground [option get . background {}]
			button $f.$i.bb -text "" -width 8 -command "RefGet col_x($i)" -state disabled -highlightbackground [option get . background {}]
			pack $f.$i.x $f.$i.xe $f.$i.bb -side left -padx 1
			incr i
		}
		if {$colmode == "vB"} {
			button .colcreate.10.syn -text "Batchfile Syntax" -command BatchSyntaxDisplay -highlightbackground [option get . background {}]
			set xx [Scrolled_Listbox .colcreate.11.list1 -width 40 -height 12]
			set yy [Scrolled_Listbox .colcreate.11.list2 -width 40 -height 12]
			pack .colcreate.10.syn -side top
			pack .colcreate.11.list1 .colcreate.11.list2 -side left
			checkbutton $f.1.vv -variable advecval -text "Add vectorval to outname"
			pack $f.1.vv -side right
			checkbutton $f.2.vv -variable truncvecval -text "Truncate vecval in outname"
			pack $f.2.vv -side right
		}
		if {![info exists advecval]} {
			set advecval 0
			set truncvecval 0
		}
		pack $f.name $f.pp $f.1 $f.2 $f.3 $f.4 $f.5 $f.6 $f.7 $f.8 $f.9 $f.10 $f.11 -side top  -fill x
		bind $f <Return> {set pr_cc 1}
		bind $f <Escape> {set pr_cc 0}
	}
	wm resizable $f 1 1
	focus .colcreate.1.xe
	switch -exact -- $colmode {
		"0"	 {$f.name config -text "Duration x1 ; dovetails x2"}
		"At" {$f.name config -text "Accel Times, dur x1, minstep x2 to max x3"}
		"AT" {$f.name config -text "Accel Times, dur x1, minstep x2 to max x3, starttime x4"}
		"Ad" {$f.name config -text "Accel durations, total dur x1, min dur x2, max x3"}
		"B"  {$f.name config -text "Plain Bob bell-ringing sequence on 8 entered values"}
		"bb" {$f.name config -text "get times where vals lie in range x1 to x2"}
		"Ca" {$f.name config -text "Add x1 to every x2th value starting at item x3"}
		"Cm" {$f.name config -text "Multiply by x1 every x2th value starting at item x3"}
		"dd" {$f.name config -text "Copy all vals, x1 times; step of x2 between copy starts"}
		"dL" {$f.name config -text "Copy all vals, x1 times; step x2 between end of one & start of next"}
		"Ea" {$f.name config -text "peak gain x1 peak rise-time x2"}
		"ga" {$f.name config -text "add x1 to 2nd item, (2*x1) to 3rd, (3*x1) to 4th, etc"}
		"ie" {$f.name config -text "Create x1 equal values x2"}
		"ic" {$f.name config -text "x1 vals with step x2 between each pair"}
		"iC" {$f.name config -text "x1 vals with step x2 between each pair, startvalue x3"}
		"ID" {$f.name config -text "x1 copies, replacing strings x2 in each copy by index starting at x3"}
		"id" {$f.name config -text "x1 copies, replacing strings x2 by indeces listed in other file"}
		"iR" {$f.name config -text "x1 vals with ratio x2 between each pair, startvalue x3"}
		"cs" {$f.name config -text "x1 vals cosin-sweep from x2 to x3, sweep skewed by x4 (1.0 = NO skew)"}
		"iQ" {$f.name config -text "x1 vals with equal steps between, startval x2, endval x3"}
		"i=" {$f.name config -text "equal steps of size x1 in interval between x2 and x3"}
		"IP" {$f.name config -text "between x1 & x2 vals of col1,then betwn x3 & x4 vals col2, cyclically"}
		"L"  {$f.name config -text "x1 log-equal steps in interval between x2 and x3"}
		"M"  {$f.name config -text "At each match of x1 in col1, get x2 vals from col2"}
		"Mo" {$f.name config -text "Morph col1 sequence to col2 seq, starting at x1th entry, ending at x2th"}
		"MO" {$f.name config -text "Morph col1 to col2, starting at x1th entry, ending at x2th"}
		"pp" {$f.name config -text "Backforth, width x1 outer x2 start x3 prop x4 bckfrth x5 dur x6 left? x7"}
		"Q"  {$f.name config -text "x1 steps in interval between x2 and x3, curvature x4"}
		"qz" {$f.name config -text "x1 vals random-zigzagging within range x2 to x3, ending at x4"}
		"Rc" {$f.name config -text "Cut x1 into random chunks, min size x2, max size x3"}
		"Rg" {$f.name config -text "random sequence of x1 0s and 1s"}
		"RG" {$f.name config -text "random sequence of x1 0s and 1s, no more than x2 consecutive repeats"}
		"rG" {$f.name config -text "pair of integers x1,x2, random sequence of x3 of these"}
		"Ri" {$f.name config -text "Get random sequence of x1 ints, chosen from vals 1 to x2"}
		"RI" {$f.name config -text "random sequence of x1 ints, vals 1 to x2, max repets x3"}
		"rJ" {$f.name config -text "pair of ints x1,x2, random seq x3 of these, no more than x4 repeats"}
		"Rr" {$f.name config -text "Cut x1 into x2 chunks: randomisation x3"}
		"Rv" {$f.name config -text "x1 random values in range x2 to x3"}
		"rz" {$f.name config -text "x1 randvals from x2 to x3, start x4, end x5, max equalval run x6"}
		"sa" {$f.name config -text "Scale interval between x1 and values above x1, by x2"}
		"sb" {$f.name config -text "Scale interval between x1 and values below x1, by x2"}
		"sf" {$f.name config -text "Scale interval between x1 and value, by x2"}
		"sc" {$f.name config -text "Cosin Join: x1 to x2: times x3 x4: with x5 points"}
		"sr" {$f.name config -text "Scale all values into interval between x1 and x2"}
		"ss" {$f.name config -text "Sinus: max-min x1,x2: startphase(degrees) x3: cycles x4: vals per cyc x5"}
		"sv" {$f.name config -text "Concave Join: x1 to x2: times x3 x4: with x5 points"}
		"sx" {$f.name config -text "Convex Join: x1 to x2: times x3 x4: with x5 points"}
		"SM" {$f.name config -text "x1 splice(mS); x2 srate; x3 chans; x4 no. chans per 'sample'"}
		"Tb" {$f.name config -text "metre x1 (3.4 = metre 3:4) : CROTCHET tempo x2"}
		"Td" {$f.name config -text "Tempo (beats per minute) x1: Duration x2"}
		"Tsm" {$f.name config -text "Min midi pitch x1: Max midi pitch x2: Range > 0"}
		"vB" {
			$f.name config -text "x1,x2 are cols for infile,outfile: x3 (etc) cols for vector-params"
			$xx insert end "BATCHFILE COLUMNS"
			$xx insert end ""
			set qxq 1
			foreach item $bbbatch {
				$xx insert end "COLUMN $qxq:  $item"
				incr qxq
			}
			$yy insert end "CURRENT CHOSEN FILES"
			$yy insert end ""
			if {[info exists chlist] && ([llength $chlist] > 0)} {
				foreach item $chlist {
					$yy insert end $item
				}
			}
		}
		"zq" {$f.name config -text "x1 vals, quantise x2, interval x3, randomisation x4"}
		"ya" {$f.name config -text "Replace value = x1 by randval in range x2 to x3"}
		"yA" {$f.name config -text "Insert after (the first) value x1, the value x2"} 
		"yb" {$f.name config -text "Replace value < x1 by randval in range x2 to x3"}
		"yB" {$f.name config -text "Insert x1 at start of column"}
		"yc" {$f.name config -text "Replace value > x1 by randval in range x2 to x3"}
		"yC" {$f.name config -text "Select every x1th item, starting at item x2"}
		"yd" {$f.name config -text "Remove x1th to x2th values"}
		"yE" {$f.name config -text "Insert x1 at end of column"}
		"ye" {$f.name config -text "Replace value = x1 by value x2"}
		"yg" {$f.name config -text "Replace value > x1 by value x2"}
		"yi" {$f.name config -text "Insert at position x1 the value x2"}
		"yI" {$f.name config -text "Invert values in range x1 to x2"}
		"yl" {$f.name config -text "Replace value < x1 by value x2"}
		"yo" {$f.name config -text "x1 is value to insert into ascending order column"} 
		"yp" {$f.name config -text "Invert values about pivot x1"} 
		"yP" {$f.name config -text "x1 halflinger: x2 1st panextreme: x3 startpos: x4 endpos: x5 endtime"} 
		"yq" {$f.name config -text "x1 rand vals quantised over x2; min x3 max x4 between incol val pairs"}
		"yQ" {$f.name config -text "x1 halflinger: x2 startpos: x3 endpos: x4 endtime"}
		"yr" {$f.name config -text "Replace value at position x1 by value x2"}
		"yR" {$f.name config -text "Rand delete x1 items, deleted gpsize <= x2, remainder gpsize <= x3"}
		"ys" {$f.name config -text "Sequence step x1, omit items between val pairs"}
		"yS" {$f.name config -text "Sequence step x1, omit items outside val pairs"}
		"yx" {$f.name config -text "x1 timestep: x2 stretch"}
		"yz" {$f.name config -text "x1 halflinger: x2 startpos: x3 endpos: x4 endtime"} 
		"zA" {$f.name config -text "x1 alt vals (x2=A  r=rand,range x3-x4) ArAr.."}
		"zB" {$f.name config -text "x1 alt vals (x2=A  r=rand,range x3-x4) rArA.."}
		"zC" {$f.name config -text "x1 alt vals (x2=A  r1,r2...rand,range x3-x4) AAr1r2AAr3r4.."}
		"zD" {$f.name config -text "x1 alt vals (x2=A  r1,r2...rand,range x3-x4) r1r2AAr3r4AA.."}
		"zE" {$f.name config -text "x1 alt vals (x2=A  r1,r2...rand,range x3-x4) Ar1r2AAr3r4AA.."}
		"ze" {$f.name config -text "x1 (multiple of 2) 'exponential' steps between times x2,x3 values x4,x5"}
		"zF" {$f.name config -text "x1 alt vals (x2=A  r1,r2...rand,range x3-x4) r1AAr2r3AAr4r5AA.."}
		"zG" {$f.name config -text "x1 alt vals (x2=A  r1,r2...rand,range x3-x4) AAr1r1AAr2r2.."}
		"zH" {$f.name config -text "x1 alt vals (x2=A  r1,r2...rand,range x3-x4) r1r1AAr2r2AA.."}
		"zI" {$f.name config -text "x1 alt vals (x2=A  r1,r2...rand,range x3-x4) Ar1r1AAr2r2AA.."}
		"zJ" {$f.name config -text "x1 alt vals (x2=A  r1,r2...rand,range x3-x4) r1AAr2r2AAr3r3AA.."}
		"zX" {$f.name config -text "x1 alt vals (x2=A  x3=B) ABAB.."}
		"zY" {$f.name config -text "x1 alt vals (x2=A  x3=B) AABBAABB.."}
		"zZ" {$f.name config -text "x1 alt vals (x2=A  x3=B) ABBAABBAA.."}
		"ZA" {$f.name config -text "x1 start, step by x2, x3 times, baktrak by x4: stop at x5"}
		"ZB" {$f.name config -text "x1 vals, x2 are '1', x3 random, Pattern  11..r1r2..11..r3r4.."}
		"ZC" {$f.name config -text "x1 vals, x2 are fixed, x3 random, Pattern  12..r1r2..12..r3r4.."}
		"ZD" {$f.name config -text "x1 vals from set of x4: x2 fixed,x3 rand: Pattern 12..r1r2..12..r3r4.."}
		"ZE" {$f.name config -text "x1 vals from set of x4: x2 '1', x3 rand: Pattern 11..r1r2..11..r3r4.."}
		"ZH" {$f.name config -text "just intonation vals around frqval x1 in range x2 to x3"}
		"Zm" {$f.name config -text "just intonation vals around midival x1 in range x2 to x3"}
	}
	set i 1
	while {$i <= 8} {
		$f.$i.xe config -state disabled -bd 0
		$f.$i.bb config -state disabled -bd 0
		bind $f.$i.xe <Up> {}
		bind $f.$i.xe <Down> {}
		incr i
	}
	switch -- $p_cnt {
		8 {
			set i 1
			set j 2
			set k 8
			while {$i <= 8} {
				$f.$i.xe config -state normal -bd 2
				$f.$i.bb config -text "Get Ref Val" -state normal -bd 2
				bind $f.$i.xe <Down> "focus $f.$j.xe"
				bind $f.$i.xe <Up> "focus $f.$k.xe"
				incr i
				incr j
				incr k 
				if {$j > 8} {
					set j 1
				}
				if {$k > 8} {
					set k 1
				}
			}
		}
		default {
			set i 1
			set j 2
			set k $p_cnt
			while {$i <= $p_cnt} {
				$f.$i.x  config -text "x$i"
				$f.$i.xe config -state normal -bd 2
				$f.$i.bb config -text "Get Ref Val" -state normal -bd 2
				bind $f.$i.xe <Up> "focus $f.$k.xe"
				bind $f.$i.xe  <Down> "focus $f.$j.xe"
				incr i
				incr j
				incr k 
				if {$j > $p_cnt} {
					set j 1
				}
				if {$k > $p_cnt} {
					set k 1
				}
			}
		}
	}
	if {$colmode != $last_colmode} {
		set i 1
	} else {
		set i $p_cnt
		incr i
	}
	while {$i <= 8} {
		if {[info exists col_x($i)] && ([string length $col_x($i)] > 0)} {
			set last_col_x($i) $col_x($i)
		} else {
			catch {unset last_col_x($i)}
		}
		set col_x($i) ""
		incr i
	}
	set pr_cc 0
	set finished 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 1 $f pr_cc
	wm geometry $f $geo
	while {!$finished} {
		tkwait variable pr_cc
		ForceVal $f.9.e ""
	 	$f.9.e config -bg [option get . background {}]
		if {$pr_cc} {
			if {($p_cnt == 2) && [string match "end" $col_x(1)]} {
				if {$colmode == "yi"} {
					set col_x(1) [expr $inlines + 1]
				} elseif {$colmode == "yr"} {
					set col_x(1) $inlines
				}
			}
			set n 1
			set OK 1
			while {$n <= $p_cnt} {
				set col_x($n) [string trim $col_x($n)]
				if {([string length $col_x($n)] <= 0) || ![IsNumeric $col_x($n)]} {
					if {($n != 1) || ($colmode != "vB")} {
						set OK 0
						break
					}
				}
				incr n
			}
			if {!$OK} {
				ForceVal $f.9.e "Insufficient (valid) parameters entered."
				$f.9.e config -bg $evv(EMPH)
			} else {
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	set i 0
	if [winfo exists .cpd] {
		DestroyCalc
	}
	My_Release_to_Dialog $f
	set i 0
	set cc_out $pr_cc
	set last_colmode $colmode
	catch {destroy .cpd}
	Dlg_Dismiss $f
	focus $tabed.mid.par1
	return $cc_out
}

#------ Wipe the values in the column=params window

proc ClearColParams {f} {
	set i 1
	while {$i <= 8} {
		set col($i) ""
		ForceVal $f.$i.xe $col($i)
		incr i
	}
	ForceVal $f.9.e ""
 	$f.9.e config -bg [option get . background {}]
}

#------ Restore previous values in the column-params window

proc PreviousColParams {f p_cnt} {
	global last_col_x
	set i 1
	while {$i <= $p_cnt} {
		if [info exists last_col_x($i)] {
			set col($i) $last_col_x($i)
			ForceVal $f.$i.xe $col($i)
			incr i
		} else {
			break
		}
	}
}

#------ Setup Column-Number for Insertion, In Keep case

proc RepKeep {} {
	global rcolno tabed readonlyfg readonlybg

	set rcolno ""
	ForceVal $tabed.bot.kcframe.e $rcolno
	$tabed.bot.kcframe.e config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
}

#------ Setup Column-Number for Insertion, In Replace case

proc RepCom {val} {
	global rcolno orig_incolget	tabed readonlyfg readonlybg

	set rcolno $orig_incolget
	ForceVal $tabed.bot.kcframe.e $orig_incolget
	$tabed.bot.kcframe.e config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
}

#------ Allow entry of Column-Number for Insertion, In Insert case

proc InsCom {val} {
	global tabed
	$tabed.bot.kcframe.e config -state normal -fg [option get . foreground {}]
}

#------ Get contents of a table-file to table display
											 
proc GetTableFromFilelist {w index created} {
	global incols c_inlines c_incols col_infilelist tot_inlines col_infnam tedit_message pa evv
	global incolget coltype outlines brk_stat env_stat seq_stat freetext orig_inlines orig_incolget tab_ness
	global tabedit_bind2 colinmode rcolno couldbe_seq2 last_couldbe_seq2
	global col_tabname tabed readonlyfg readonlybg


	if {[string length $index] <= 0} {
		return
	}
	set d "disabled"
	set n "normal"
	set tb $tabed.bot
	set tab_ness 0
	if {$created} {
		set fnam $evv(DFLT_OUTNAME)
		append fnam "0" $evv(TEXT_EXT)
		set col_infnam $fnam
		set col_preset 0
	} else {
		if {$index < 0} {
			set index [$w curselection]
			if {$index < 0} {
				return
			}
		}
		set fnam [$w get $index]
		set tab_ness [IsAValidNessFile $fnam 1 0 0]
		set col_infnam $fnam
		set col_preset 0
	}
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if [catch {open $fnam "r"} cfileId] {
		ForceVal $tabed.message.e "Cannot open file $fnam"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	catch {unset incolget}
	set orig_incolget ""
	$tabed.bot.gframe.got config -bg [option get . background {}]
	ForceVal $tabed.bot.gframe.got $orig_incolget
	ForceVal $tb.gframe.e ""
	$tb.itab config -text "INPUT TABLE"
	$tb.itframe.f0 config -text "\n\n"

	$tb.itframe.l.list delete 0 end
	SetInout 0
	set is_brk 0
	set is_env 0
	set is_seq 0
	if {$colinmode != 2} {
		if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
			set is_brk 1
		}
		if {[IsANormdBrkfile $pa($fnam,$evv(FTYP))]} {
			set is_env 1
		}
	}
	SetEnvState 1
	if {[info exists col_infilelist] && [set index [lsearch -exact $col_infilelist $fnam]]>=0} {
		set incols [lindex $c_incols $index]
		ForceVal $tabed.bot.itframe.f.e $incols
		set tot_inlines [lindex $c_inlines $index]
		ForceVal $tabed.bot.itframe.f.e2 $tot_inlines
		set col_preset 1
	}
	set llcnt 0
	set baslin 0
	set incols 0
	set maxcols 0
	set couldbe_seq2 0
	set has_non_comment_lines 0
	while { [gets $cfileId line] >= 0} {
		catch {unset new_colline}
		set indata [split $line]
		foreach item $indata {
			if {[string length $item] > 0} {
				if {$baslin == 0} {
					incr incols
				}
				lappend new_colline $item
			}
		}
		ForceVal $tabed.bot.itframe.f.e $incols
		if [info exists new_colline] {
			if {$freetext} {
				set test [lindex $new_colline 0]
				if {!([string match \;* $test] || [string match "e" $test] || [string match "s" $test])} {
					if {![info exists first_incols]} {
						set first_incols $incols
					} elseif {![info exists other_incols]} {
						set other_incols $incols
						if {$other_incols == 5} {
							set couldbe_seq2 $first_incols
						}
					} elseif {$incols != $other_incols} {
						set couldbe_seq2 0
					}
					if {$incols > $maxcols} {		;#	Don't count columns in comments, or e and s lines
						set maxcols $incols				
					}
				} elseif {![string match \;* $test]} {
					set has_non_comment_lines 1		;#	Check if any non-comment lines exist with just 'e' or 's'
				}
				set incols 0
				ForceVal $tabed.bot.itframe.f.e $incols
			} else {
				set baslin 1			   			;#	If not in free text mode, we have the column count: stop looking
			}
			set ll [llength $new_colline]
			set i 0
			set zort ""
			while {$i < $ll} {
				append zort [lindex $new_colline $i] " "
				incr i
			}				
			set zlen [string length $zort]
			incr zlen -2
			set zort [string range $zort 0 $zlen]
			$tb.itframe.l.list insert end $zort
			incr llcnt
		}
	}
	if {$freetext} {
		if {$maxcols <= 0} {
			if {$has_non_comment_lines} {	   	;#	i.e. has lines of 'e' or 's' only !!
				set incols 1
			} else {
				ForceVal $tabed.message.e "No significant data found in file. (All comments)"
			 	$tabed.message.e config -bg $evv(EMPH)
				catch {close $cfileId}
				return
			}
		} else {
			set incols $maxcols
		}
	}
	if {$colinmode != 2} {
		catch {unset last_couldbe_seq2}
	}
	if {$colinmode == 2} {
		$tabed.topa.seq config -state $d -text ""
		set seq_stat "disabled"
		if {$couldbe_seq2} {
			if {![info exists last_couldbe_seq2]} {
				set last_couldbe_seq2 $couldbe_seq2
			} elseif {$couldbe_seq2 != $last_couldbe_seq2} {
				set last_couldbe_seq2 0
				set couldbe_seq2 0
			}
		}
	} elseif {($incols != 3) && (!$couldbe_seq2)} {
		$tabed.topa.seq config -state $d -text ""
		set seq_stat "disabled"
	} else {
		$tabed.topa.seq config -state $n -text "Seq"
		set brk_stat "disabled"
		set env_stat "disabled"
		set seq_stat "normal"
		set is_env 0
		set is_brk 0
	}
	if {$is_brk && ($incols == 2)} {
		$tabed.topa.brk config -state $n -text "Brk"
		set brk_stat "normal"
		set seq_stat "disabled"
	} else {
		$tabed.topa.brk config -state $d -text ""
		$tabed.topa.env config -state $d -text ""
		set env_stat "disabled"
		set seq_stat "disabled"
	}
	if {$is_env} {
		set env_stat "normal"
		set seq_stat "disabled"
	} else {
		set env_stat "disabled"
	}
	close $cfileId
	if {!$col_preset} {
		lappend col_infilelist $fnam
		lappend c_incols $incols
		lappend c_inlines $llcnt
		set tot_inlines $llcnt
		ForceVal $tabed.bot.itframe.f.e2 $tot_inlines
	}
	SetInout 1
	$tabed.bot.itframe.l.list config -bg $evv(EMPH)
	$tabed.bot.otframe.l.list config -bg [option get . background {}]

	ForceVal $tb.itframe.f.e $incols

	$tb.gframe.e config -state $n
	$tb.gframe.ok config -state $n
	set incolget 1
	ForceVal $tb.gframe.e $incolget
	$tb.gframe.blob.skip config -state $n
	DisableOutputColumnOptions 
	ForceVal $tb.kcframe.e ""
	set coltype "o"
	if {$created} {
		$tb.ktframe.bbb1.6 config -state $d
	} else {
		$tb.ktframe.bbb1.6 config -state $n
	}
	if [info exists outlines] {
		if {$outlines > 0} {
			set coltype "k"
			$tb.kcframe.okk config -state $n
			$tb.kcframe.oky config -state $n
			$tb.kcframe.okz config -state $n
			$tb.kcframe.ok  config -state $n
		}
		if {$tot_inlines == $outlines} {
			$tb.kcframe.oki config -state $n
			$tb.kcframe.okr config -state $n
			$tb.kcframe.okk config -state $n
			$tb.kcframe.ok  config -state $n
			set rcolno $incolget
			ForceVal $tb.kcframe.e $rcolno
		}
	} else {
		$tb.ktframe.fnm config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		bind $tb.ktframe.names.list <ButtonRelease-1> {}
		catch {unset tabedit_bind2}
		$tb.ktframe.bbb.1 config -state $d
		$tb.ktframe.bbb.2 config -state $d
		$tb.ktframe.bbb.3 config -state $d
		$tb.ktframe.bbb1.4 config -state $d
		$tb.ktframe.bxxb config -state $d -text ""
		$tb.ktframe.bbb1.6 config -state $d
	}
	$tb.itframe.f0 config -text "FILENAME: [file tail $fnam]\n\n"

	$tb.itframe.tcop config -state $n
	set orig_inlines 0
	$tb.itframe.l.list xview moveto 0.0
}

#------ Get name of a table to table-out display
											 
proc GetSeveralTablesFromFilelist {w} {
	global tot_inlines ot_has_fnams tabed

	set ll $tabed.bot.otframe.l.list
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	if {!$ot_has_fnams} {
		$ll delete 0 end
	}
	set i [$w curselection]
	if [info exists i] {
		set fnam [$w get $i]
		set ot_has_fnams 1
		GetTableFromFilelist $w $i 0 
		$tabed.bot.otframe.l.list insert end $fnam
	}
}

#------ Change function of file-selection with mouse

proc ChangeColSelect {clik} {
	global colinmode freetext col_ungapd_numeric wl pa tabedit_hlp_actv tabedit_bindcmd brk_stat tet tot_inlines evv
	global ot_has_fnams lmo env_stat tot_outlines outcolcnt auto_cs seq_stat
	global col_tabname col_infnam tabed eflag eflag2

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set n "normal"
	set d "disabled"
	set tt $tabed.top
	set tta $tabed.topa
	set tt2 $tabed.top2
	set tt3 $tabed.top3
	set tb $tabed.bot
	set tbk $tabed.bot.ktframe
	$tb.fframe.l.list selection clear 0 end
	HaltCursCop
	if {$clik} {
		if {!$auto_cs} {								;#	first manual OR manual+manual, forgets action
			if {$lmo != "Sy"} {
				set lmo "X"								;#	auto+manual, doesn't forget action
			}
		}
		set auto_cs 0
	} else {
		set auto_cs 1									;#	auto, doesn't forget action
	}
	switch -- $colinmode {
		0 {
			$tb.otab config -text "OUTPUT TABLE"
			$tb.ktframe.name config -text "Save Table?"
			if {$ot_has_fnams} {						;#	ot_has_fnams indicates filenames in otable
				$tb.otframe.l.list delete 0 end			
				set ot_has_fnams 0
			}
			$tt3.mat config -state $n -text "Maths"
			$tt3.mus config -state $n -text "Pitch"
			$tt3.int config -state $n -text "Interval"
			$tt3.tim config -state $n -text "Time"
			$tt3.db config -state $n -text  "Gain"
			$tt3.ord config -state $n -text "Order"
			$tt3.ran config -state $n -text "Rand"
			$tt.cre config -state $n -text "Create"
			$tt.cre2 config -state $n -text "Create2"
			$tta.vec config -state $n -text "Combine"
			$tt.der config -state $n -text "Derive"
			$tt.tes config -state $n -text "Test"
			$tt.fin config -state $n -text "Find"
			$tta.brk config -state $brk_stat
			if {[string match [$tta.brk config -state] "normal"]} {
				$tta.brk config -text "Brk"
			} else {
				$tta.brk config -text ""
			}			 
			$tta.env config -state $env_stat
			if {[string match [$tta.env config -state] "normal"]} {
				$tta.env config -text "Envel"
			} else {
				$tta.env config -text ""
			}			 
			$tta.seq config -state $seq_stat
			if {[string match [$tta.seq config -state] "normal"]} {
				$tta.seq config -text "Seq"
			} else {
				$tta.seq config -text ""
			}			 
			$tt3.for config -state $n -text "Format"
			$tt3.ins config -state $n -text "Edit In"
			$tt3.ins2 config -state $n -text "Edit Out"
			$tt3.ins3 config -state $n -text "At Cursor"
			$tt.ins4 config -state $n -text "From Snds"
			$tta.tab config -state $n -text "Tables"
			$tta.atc config -state $n -text "At Cursor"
			$tta.joi config -state $d -text ""
			bind $tb.fframe.l.list <ButtonRelease-1> {}
			bind $tb.fframe.l.list <ButtonRelease-1> {GetTableFromFilelist %W -1 0}
			set tabedit_bindcmd [bind $tb.fframe.l.list <ButtonRelease-1>]
			if {[info exists tabedit_hlp_actv] && $tabedit_hlp_actv} {
				bind $tb.fframe.l.list <ButtonRelease-1> {+ TedH files}
			}
			bind $tb.otframe.l.list <ButtonRelease-1> {}
			$tabed.top.same config -state $n
			focus $tabed.bot.gframe.e
		}
		1 {
			$tb.otab config -text "OUTPUT TABLE"
			$tb.ktframe.name config -text "Save Table?"
			if {$ot_has_fnams} {
				$tb.otframe.l.list delete 0 end
				set ot_has_fnams 0
			}
			if {$freetext} {
				set freetext 0
				$tb.fframe.l.list delete 0 end
				foreach fnam [$wl get 0 end] {
					if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST)} {
						$tb.fframe.l.list insert end $fnam			
					}
				}
				$tb.fframe.d.all config -state $n
				$tb.fframe.d.mix config -state $n
				$tb.fframe.d.brk config -state $n -text "Brk"
				set tet 0
				set eflag 0
				set eflag2 0
				$tb.gframe.cse config -state $d
				$tb.gframe.cse2 config -state $d
			}
			$tt3.mat config -state $n -text "Maths"
			$tt3.mus config -state $n -text "Pitch"
			$tt3.int config -state $n -text "Interval"
			$tt3.tim config -state $n -text "Time"
			$tt3.db config -state $n -text  "Gain"
			$tt3.ord config -state $n -text "Order"
			$tt3.ran config -state $n -text "Rand"
			$tt.cre config -state $n -text "Create"
			$tt.cre2 config -state $n -text "Create2"
			$tta.vec config -state $n -text "Combine"
			$tt.der config -state $n -text "Derive"
			$tt.tes config -state $n -text "Test"
			$tt.fin config -state $n -text "Find"
			$tta.brk config -state $brk_stat
			if {[string match [$tta.brk config -state] "normal"]} {
				$tta.brk config -text "Brk"
			} else {
				$tta.brk config -text ""
			}
			$tta.env config -state $env_stat
			if {[string match [$tta.env config -state] "normal"]} {
				$tta.env config -text "Envel"
			} else {
				$tta.env config -text ""
			}
			$tta.seq config -state $seq_stat
			if {[string match [$tta.seq config -state] "normal"]} {
				$tta.seq config -text "Seq"
			} else {
				$tta.seq config -text ""
			}
			$tt3.for config -state $n -text "Format"
			$tt3.ins config -state $n -text "Edit In"
			$tt3.ins2 config -state $n -text "Edit Out"
			$tt3.ins3 config -state $n -text "At Cursor"
			$tt.ins4 config -state $n -text "From Snds"
			$tta.tab config -state $n -text "Tables"
			$tta.atc config -state $n -text "At Cursor"
			$tta.joi config -state $d -text ""
			bind $tb.fframe.l.list <ButtonRelease-1> {}
			bind $tb.fframe.l.list <ButtonRelease-1> {set col_ungapd_numeric 1; GetFileWithASingleColumn %W}
			set tabedit_bindcmd [bind $tb.fframe.l.list <ButtonRelease-1>]
			if {[info exists tabedit_hlp_actv] && ($tabedit_hlp_actv)} {
				bind $tb.fframe.l.list <ButtonRelease-1> {+ TedH files}
			}
			bind $tb.otframe.l.list <ButtonRelease-1> {}
			$tabed.top.same config -state $n
			focus $tabed.bot.gframe.e
		}
		2 {
			$tb.otab config -text "LIST OF INPUT TABLES SELECTED"
			$tb.ktframe.name config -text ""
			$tt3.mat config -state $d -text ""
			$tt3.mus config -state $d -text ""
			$tt3.int config -state $d -text ""
			$tt3.tim config -state $d -text ""
			$tt3.db config -state $d -text ""
			$tt3.ord config -state $d -text ""
			$tt3.ran config -state $d -text ""
			$tt.cre config -state $d -text ""
			$tt.cre2 config -state $d -text ""
			$tta.vec config -state $d -text ""
			$tt.der config -state $d -text ""
			$tt.tes config -state $d -text ""
			$tt.fin config -state $d -text ""
			set brk_stat [$tta.brk cget -state]
			set env_stat [$tta.env cget -state]
			set seq_stat [$tta.seq cget -state]
			$tta.brk config -state $d -text ""
			$tta.env config -state $d -text ""
			$tta.seq config -state $d -text ""
			$tt3.for config -state $d -text ""
			$tt3.ins config -state $d -text ""
			$tt3.ins2 config -state $d -text ""
			$tt3.ins3 config -state $d -text ""
			$tt.ins4 config -state $d -text ""
			$tta.tab config -state $d -text ""
			$tta.atc config -state $d -text ""
			$tta.joi config -state $n -text "Join"
			bind $tb.fframe.l.list <ButtonRelease-1> {}
			bind $tb.fframe.l.list <ButtonRelease-1> {GetSeveralTablesFromFilelist %W}
			set tabedit_bindcmd [bind $tb.fframe.l.list <ButtonRelease-1>]
			if {[info exists tabedit_hlp_actv] && ($tabedit_hlp_actv)} {
				bind $tb.fframe.l.list <ButtonRelease-1> {+ TedH files}
			}
			DisableOutputTableOptions 1
			bind $tb.otframe.l.list <ButtonRelease-1> {ListDeleteSel %W}
			focus $tabed.mid.par1
		}
	}
}

#------ Round values in Out Column , and in associated tempfile

proc RoundOutcols {src} {
	global tround ttround last_oc last_cr col_ungapd_numeric tot_outlines outlines tabed evv

	switch -- $src {
		col {
			if {![info exists outlines] || ($outlines <= 0)} {
				set tround 0
				return
			}
			set fnam $evv(COLFILE2)
			set tl $tabed.bot.ocframe.l.list
		}
		tab {
			if {![info exists outlines] || ($tot_outlines <= 0)} {
				set ttround 0
				return
			}
			set fnam $evv(COLFILE3)
			set tl $tabed.bot.otframe.l.list
		}
	}
	if [catch {open $fnam "w"} cfileId] {
		ForceVal $tabed.message.e "Cannot open temporary file $fnam to do rounding"
	 	$tabed.message.e config -bg $evv(EMPH)
		set tround 0
		set ttround 0
		return
	}
	if {$src == "col"} {
		catch {unset last_oc}
		set last_cr $col_ungapd_numeric
		foreach val [$tl get 0 end] {
			lappend last_oc $val
			if {![IsNumeric $val]} {
				ForceVal $tabed.message.e "Non-numeric value $val encountered. Cannot do rounding."
	 			$tabed.message.e config -bg $evv(EMPH)
				set tround 0
				catch {close $cfileId}
				return
			}
			lappend newlist [expr int(round($val))]
		}
		$tabed.bot.ocframe.l.list delete 0 end
		foreach val $newlist {
			$tl insert end $val
			puts $cfileId $val
		}
		set tround 0
	} else {
		foreach line [$tl get 0 end] {
			set newline ""
			foreach val $line {
				if {![IsNumeric $val]} {
					ForceVal $tabed.message.e "Non-numeric value $val encountered. Cannot do rounding."
	 				$tabed.message.e config -bg $evv(EMPH)
					set ttround 0
					catch {close $cfileId}
					return
				}
				if {[string length [set val [string trim $val]]] > 0} {
					lappend newline [expr int(round($val))]
				}
			}
			lappend newlist $newline
		}
		$tl delete 0 end
		foreach val $newlist {
			$tl insert end $val
			puts $cfileId $val
		}
		set ttround 0
	}
	close $cfileId
}

#------ Recycle output TABLE to input

proc TabRecyc {} {
	global incols outlines outcolcnt tot_inlines col_infnam incolget coltype colinmode ttrecyc pa evv okz
	global brk_stat env_stat seq_stat freetext orig_incolget orig_inlines ot_has_fnams sl_real wl tabed

	if {!$sl_real} {
		Inf "The Output Table Can Be Recycled As The Input Table\nAnd Further Processes Applied To It"
		return
	}

	set n "normal"
	set d "disabled"
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set ttrecyc 0

	if {$ot_has_fnams} {
		return
	}

	set tb $tabed.bot
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists outcolcnt] || ($outcolcnt <= 0)} {
		ForceVal $tabed.message.e "There is no Output Table to recycle"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}		
	set fnam $evv(DFLT_OUTNAME)
	append fnam "0" $evv(TEXT_EXT)
	if [file exists $fnam] {
		if {![catch {file stat $fnam filestatus} in]} {
			if {$filestatus(ino) >= 0} {
				catch {close $filestatus(ino)}
			}
		}
		if [catch {file delete $fnam} in] {
			ForceVal $tabed.message.e  "Cannot delete existing temporary file $fnam"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if {![catch {file stat $evv(COLFILE3) filestatus} in]} {
		if {$filestatus(ino) >= 0} {
			catch {close $filestatus(ino)}
		}
	}
	if [catch {file copy $evv(COLFILE3) $fnam} in] {
		ForceVal $tabed.message.e  "Cannot recycle the table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}

	if {[DoParse $fnam $wl 0 0] <= 0} {
		ForceVal $tabed.message.e  "Parsing failed for Recycled file."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set is_seq 0
	if {$outcolcnt == 3} {
		set is_seq 1
	}
	set is_brk 0
	if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
		set is_brk 1
	}
	set is_env 0
	if {[IsANormdBrkfile $pa($fnam,$evv(FTYP))]} {
		set is_env 1
	}
	if [catch {open $fnam "r"} cfileId] {
		ForceVal $tabed.message.e "Cannot open temporary file $fnam"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	catch {unset incolget}
	set orig_incolget ""
	ForceVal $tabed.bot.gframe.got $orig_incolget
	$tabed.bot.gframe.got config -bg [option get . background {}]
	ForceVal $tb.gframe.e ""

	$tb.itframe.f0 config -text "\n\n"

	$tb.itframe.l.list delete 0 end
	SetInout 0
	set llcnt 0
	set incols 0
	while { [gets $cfileId line] >= 0} {
		catch {unset new_colline}
		set indata [split $line]
		foreach item $indata {
			if {[string length $item] > 0} {
				if {$llcnt == 0} {
					incr incols
				}
				lappend new_colline $item
			}
		}
		if [info exists new_colline] {
			$tb.itframe.l.list insert end $new_colline
		}
		incr llcnt
	}
	if {$is_seq} {
		$tabed.topa.seq config -state $n -text "Seq"
		set seq_stat 1
		set is_brk 0
		set is_env 0
	} else {
		set seq_stat 0
		$tabed.topa.seq config -state $d -text ""
	}
	if {$is_brk} {
		$tabed.topa.brk config -state $n -text "Brk"
		set brk_stat "normal"
	} else {
		$tabed.topa.brk config -state $d -text ""
		set brk_stat "disabled"
	}
	if {$is_env} {
		$tabed.topa.env config -state $n -text "Envel"
		set env_stat "normal"
	} else {
		$tabed.topa.env config -state $d -text ""
		set env_stat "disabled"
	}
	close $cfileId
	set tot_inlines $llcnt
	ForceVal $tabed.bot.itframe.f.e2 $tot_inlines
	SetInout 1
	
	$tabed.bot.itframe.l.list config -bg $evv(EMPH)
	$tabed.bot.otframe.l.list config -bg [option get . background {}]
	ForceVal $tb.itframe.f.e $incols

	$tb.gframe.e config -state $n
	$tb.gframe.ok config -state $n
	set incolget 1
	ForceVal $tb.gframe.e $incolget
	$tb.gframe.blob.skip config -state $n
	if {([string length $outlines] > 0) && ($outlines > 0)} {
		$tb.kcframe.oki config -state $n
		$tb.kcframe.oko config -state $d
		$tb.kcframe.okr config -state $n
		$tb.kcframe.okk config -state $n
		$tb.kcframe.oky config -state $n
		$tb.kcframe.okz config -state $n
		$tb.kcframe.ok  config -state $n
		$tb.kcframe.e   config -state $n -fg [option get . foreground {}]
		set coltype "k"
#RADICAL JAN 2004
		set okz -1
	} else {
		DisableOutputColumnOptions 
		set coltype "o"
	}

	ForceVal $tb.kcframe.e ""
	set col_infnam $fnam
	SetEnvState 1
	$tb.itframe.f0 config -text "FILENAME: [file tail $col_infnam]\n\n"

	$tb.ktframe.bbb1.6 config -state $d
	catch {unset orig_inlines}
}

#------ Change type of file used

proc ChangeColTextMode {} {
	global freetext colinmode tot_inlines eflag eflag2 wl pa tet tabed evv

	set d "disabled"
	set n "normal"
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set tb $tabed.bot
	if {$colinmode == 1} {
		set freetext 0
		return
	}
	$tb.fframe.l.list delete 0 end
	if {$freetext} {
		foreach fnam [$wl get 0 end] {
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
				$tb.fframe.l.list insert end $fnam			
			}
			set eflag 1
			set eflag2 0
			$tb.gframe.cse config -state $n
			$tb.gframe.cse2 config -state $n
			$tb.fframe.d.all config -state $n
			$tb.fframe.d.mix config -state $n
			$tb.fframe.d.brk config -state $n -text "Brk"
			set tet 0
		}
	} else {
		foreach fnam [$wl get 0 end] {
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST)} {
				$tb.fframe.l.list insert end $fnam			
			}
			set eflag 0
			set eflag2 0
			$tb.gframe.cse config -state $d
			$tb.gframe.cse2 config -state $d
			$tb.fframe.d.all config -state $n
			$tb.fframe.d.mix config -state $n
			$tb.fframe.d.brk config -state $n -text "Brk"
			set tet 0
		}
	}
}

#------ Get contents of a a single column file to output column display

proc GetFileWithASingleColumn {w} {
	global c_inlines c_incols col_infilelist outlines coltype tedit_message insitu tabed okz readonlyfg readonlybg
	global tot_inlines tot_outlines rcolno tround last_oc last_cr col_ungapd_numeric orig_inlines orig_incolget evv
	
	set n "normal"
	set d "disabled"

	set insitu 0
	LiteCol "o"
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set tb $tabed.bot
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	set index [$w curselection]
	set fnam [$w get $index]
	set col_preset 0

	if {[info exists col_infilelist] && [set index [lsearch -exact $col_infilelist $fnam]]>=0} {
		set xincolcnt [lindex $c_incols $index]
		if {$xincolcnt != 1} {
			ForceVal $tabed.message.e "This is not a single-column file"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set outlines [lindex $c_inlines $index]
		ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		set col_preset 1
	}
	if [catch {open $fnam "r"} cfileId] {
		ForceVal $tabed.message.e "Cannot open file $fnam"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set i 0

	set xincolcnt 1
	set OK 1
	while { [gets $cfileId line] >= 0} {
		set yincolcnt 0
		set indata [split $line]
		foreach item $indata {
			if {[string length $item] > 0} {
				incr yincolcnt
			}
		}
		switch -- $yincolcnt {
			0 {	;#	Ignore empty lines
			}
			1 {		
				lappend singlecol [string trim $line]
				incr i
			}
			default {
				set xincolcnt $yincolcnt
				set OK 0
			}
		}
		if {!$OK} {
			break
		}
	}
	close $cfileId
	if {($xincolcnt != 1) || ($i <= 0)} {
		ForceVal $tabed.message.e "This is not a single-column file"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	} elseif {!$col_preset} {
		lappend col_infilelist $fnam
		lappend c_inlines $i
		lappend c_incols $xincolcnt
		set outlines $i
		ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	}
	set last_oc [$tb.ocframe.l.list get 0 end]
	set last_cr $col_ungapd_numeric

	if [catch {open $evv(COLFILE2) "w"} cfileId] {
		ForceVal $tabed.message.e "Cannot open temporary file to write column data"
	 	$tabed.message.e config -bg $evv(EMPH)
		set outlines ""
		ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		return
	}
	set tround 0
	$tb.ocframe.l.list delete 0 end
	foreach item $singlecol {
		puts $cfileId $item
		$tb.ocframe.l.list insert end $item
	}
	catch {close $cfileId}

	$tb.kcframe.oky config -state $n
	$tb.kcframe.okz config -state $n
	if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
		$tb.kcframe.oki config -state $n
		if [info exists orig_incolget] {
			SetKCState "o"
		} else {
			set coltype "i"
			set rcolno 1
			$tb.kcframe.oki config -state $n
			$tb.kcframe.e config -state $n -fg [option get . foreground {}]
		}
		ForceVal $tb.kcframe.e $rcolno
		$tb.kcframe.okk config -state $n
	} else {
		if {[info exists tot_inlines] && ($outlines == $tot_inlines)} {
			$tb.kcframe.oki config -state $n
			$tb.kcframe.okr config -state $n
			set rcolno 1
			set coltype "i"
			$tb.kcframe.oki config -state $n
			$tb.kcframe.e config -state $n -fg [option get . foreground {}]
		} else {
			set rcolno ""
			set coltype "k"
#RADICAL JAN 2004
			set okz -1
			$tb.kcframe.e config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		}
		ForceVal $tb.kcframe.e $rcolno
		$tb.kcframe.okk config -state $n
	}
	$tb.kcframe.ok config -state $n
}

#------ Get a single column from a table

proc GetColumnFromATable {} {
	global incolget incols inlines outlines tot_inlines col_skiplines eflag eflag2
	global CDPcolget incol_OK evv rcolno coltype orig_inlines readonlyfg readonlybg
	global col_infnam col_from_table tedit_message col_lines_skipped orig_incolget tabed

	set n "normal"
	set d "disabled"

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set tb $tabed.bot
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]
	catch {unset col_from_table}

	if {![info exists incolget] || ([string length $incolget] < 0)} {
		ForceVal $tabed.message.e "No (valid) column number entered"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	} elseif {![regexp {^[0-9]+$} $incolget]} {
		ForceVal $tabed.message.e  "Invalid characters used for column number"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	} elseif {($incolget > $incols) || ($incolget < 1)} {
		ForceVal $tabed.message.e  "Column number out of range"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set getcol_cmd [file join $evv(CDPROGRAM_DIR) getcol]
	lappend getcol_cmd $col_infnam $evv(COLFILE1) $incolget

	if {[info exists col_skiplines]	&& ([string length $col_skiplines] > 0)} {
		if {$tot_inlines <= $col_skiplines} {
			ForceVal $tabed.message.e  "Entire file skipped!"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {$col_skiplines > 0} {
			lappend getcol_cmd $col_skiplines
		}
	}
	if {[info exists eflag] && $eflag} {
		lappend getcol_cmd "-e"
	} elseif {[info exists eflag2] && $eflag2} {
		lappend getcol_cmd "-ec"
	}
	set incol_OK 1

	$tb.icframe.l.list delete 0 end
	set inlines ""
	ForceVal $tb.icframe.dummy.cnt $inlines
 	set orig_incolget ""
	$tabed.bot.gframe.got config -bg [option get . background {}]
	ForceVal $tabed.bot.gframe.got $orig_incolget

	set sloom_cmd [linsert $getcol_cmd 1 "#"]
	if [catch {open "|$sloom_cmd"} CDPcolget] {
		ErrShow "$CDPcolget"
   	} else {
   		fileevent $CDPcolget readable "DisplayColumnFromTable"
		vwait incol_OK
   	}

	if {![info exists col_from_table]} {
		if {[string length $tedit_message] <= 0} {
			ForceVal $tabed.message.e  "No column data found."
		 	$tabed.message.e config -bg $evv(EMPH)
		}
		set incol_OK 0
	}

	if {$incol_OK} {
		if [catch {open $evv(COLFILE1) "w"} fileic] {
			ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE1) to write column data"
		 	$tabed.message.e config -bg $evv(EMPH)
			$tb.icframe.l.list delete 0 end		;#	Clear existing listing of input column
		} else {
			set inlines 0
			foreach line $col_from_table {
				$tb.icframe.l.list insert end $line
				puts $fileic $line
				incr inlines
			}
			ForceVal $tb.icframe.dummy.cnt $inlines
			close $fileic							;#	Write data to file
			set col_lines_skipped $col_skiplines
			set orig_inlines $inlines
			set orig_incolget $incolget
			ForceVal $tabed.bot.gframe.got $orig_incolget
			$tabed.bot.gframe.got config -bg $evv(EMPH)
			if {[info exists outlines] && ($inlines == $outlines)} {
				set coltype "r"
				set rcolno $incolget
				ForceVal $tb.kcframe.e $rcolno
				$tb.kcframe.e config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
				$tb.kcframe.oko config -state $n
				$tb.kcframe.okr config -state $n
				$tb.kcframe.oki config -state $n
			} else {
				SetKCState "0"
			}
		}
	} else {
		$tb.icframe.l.list delete 0 end		;#	Clear existing listing of input column
		set inlines ""
		ForceVal $tb.icframe.dummy.cnt $inlines
	}
}

#------ Put a single column into a table

proc PutAColumnIntoATable {} {
	global newtab_OK col_lines_skipped eflag eflag2 inlines outlines col_ungapd_numeric outcolcnt incols coltype evv
	global CDPcolput rcolno tot_outlines tedit_message col_to_table tot_inlines wstk
	global ino orig_inlines orig_incolget tabedit_ns tabedit_bind2
	global col_tabname col_infnam tabed isEe
	
	set n "normal"

	set line_cnt -1
	set is_itab 1
	set tb $tabed.bot
	set col_exception 0
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]
	DisableOutputTableOptions 0
	if {![info exists outlines] || ([llength $outlines] <= 0)} {
		set line "No values generated"
		ForceVal $tabed.message.e $line
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$ino} {
		if {![info exists tot_inlines] || ($tot_inlines <= 0)} {
			if {[info exists tot_outlines] && ($tot_outlines > 0)} {
				set line_cnt $tot_outlines
				set is_itab 0					;#	Working on output table
				set ino 0

			} else {
				set line_cnt 0					;#	Working on input table
			}
		} else {
			if {[info exists orig_inlines] && ($orig_inlines > 0)} {
				set line_cnt $orig_inlines
				if {$orig_inlines != $outlines} {
					if {[info exists tot_inlines] && ($tot_inlines == $outlines) \
					&& (![info exists col_lines_skipped] || ($col_lines_skipped <= 0))} {
						set line_cnt $tot_inlines
					}
				}
			} elseif [info exists tot_inlines] {
				set line_cnt $tot_inlines
			}
		}
	} else {
		set is_itab 0							;#	Working on output table
		if {[info exists tot_outlines] && ($tot_outlines > 0)} {
			set line_cnt $tot_outlines
		} else {
			set line_cnt 0					
			set outcolcnt 0
			ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		}
	}
	if {$coltype == "k"} {
		if {[file exists $evv(COLFILE3)]} {
			if [catch {file copy -force $evv(COLFILE2) $evv(COLFILE3)} in] {
				ForceVal $tabed.message.e  "Cannot overwrite existing temporary table file"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		} else {
			if [catch {file copy $evv(COLFILE2) $evv(COLFILE3)} in] {
				ForceVal $tabed.message.e  "Cannot overwrite existing temporary table file"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		$tb.otframe.l.list delete 0 end
		set tot_outlines 0
		foreach item [$tb.ocframe.l.list get 0 end] {
			$tb.otframe.l.list insert end $item
			incr tot_outlines
		}		
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		if {$tot_outlines == $tot_inlines} {
			$tb.kcframe.oki config -state $n
			$tb.kcframe.okr config -state $n
		}
	} elseif {$ino && ($line_cnt != $outlines)} {
		set line "Cannot replace existing column with new values.\nInvalid column number, OR wrong number of values.\nKeep the new column by itself?"
		set choice [tk_messageBox -message $line -type yesno -parent [lindex $wstk end] -icon question]
		if {$choice == "yes"} {
			if {[file exists $evv(COLFILE3)]} {
				if [catch {file copy -force $evv(COLFILE2) $evv(COLFILE3)} in] {
					ForceVal $tabed.message.e  "Cannot overwrite existing temporary table file"
			 		$tabed.message.e config -bg $evv(EMPH)
					return
				}
			} else {
				if [catch {file copy $evv(COLFILE2) $evv(COLFILE3)} in] {
					ForceVal $tabed.message.e  "Cannot overwrite existing temporary table file"
			 		$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			set col_exception 1
			$tb.otframe.l.list delete 0 end
			set tot_outlines 0
			foreach item [$tb.ocframe.l.list get 0 end] {
				$tb.otframe.l.list insert end $item
				incr tot_outlines
			}		
			ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
			$tb.kcframe.oki config -state $n
			$tb.kcframe.oko config -state $n
		} else {
			return
		}
	} else {
		if {$ino && ($col_ungapd_numeric == 0)} {
			if {!$isEe} {
				set line "Values are not numeric: Replace column anyway ?"
				set choice [tk_messageBox -message $line -type yesno -parent [lindex $wstk end] -icon question]
				if {$choice == "no"} {
					return
				}
			}
			set isEe 0
			set altered 1
			set col_ungapd_numeric 1
		}
		set thiscoltype $coltype
		if {$coltype == "i" || $coltype == "r"} {
			if {![info exists rcolno] || ([string length $rcolno] <= 0)} {
				ForceVal $tabed.message.e  "No Column position specified for insertion"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			} else {
				if {$coltype == "i"} {
					if {$is_itab} {
						set end_col [expr $incols + 1]
					} else {
						set end_col [expr $outcolcnt + 1]
					}
				} else {
					if {$is_itab} {
						set end_col $incols
					} else {
						set end_col $outcolcnt
					}
				}
				if {$rcolno > $end_col} {
					if {$end_col == 1} {
						ForceVal $tabed.message.e  "Column positions beyond 1 are not available."
					} else {
						ForceVal $tabed.message.e  "Column position is not available (range is 1 to $end_col)"
					}
				 	$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
		} elseif {$ino} {
			set rcolno $orig_incolget
			if {$coltype == "o"} {
				set thiscoltype r
			}
		}
		$tb.otframe.l.list delete 0 end
		set tot_outlines 0
		set putcol_cmd [file join $evv(CDPROGRAM_DIR) putcol]
		if {$ino && ([info exists tot_inlines] && ($tot_inlines > 0))} {
			lappend putcol_cmd $evv(COLFILE2) $col_infnam $evv(COLFILE3) $rcolno -$thiscoltype
		} else {
			lappend putcol_cmd $evv(COLFILE2) $evv(COLFILE3) $evv(COLFILE3) $rcolno -$thiscoltype
		}
	 	if {$ino && ([info exists col_lines_skipped] && ($col_lines_skipped > 0))} {
			lappend putcol_cmd $col_lines_skipped
		}
		if {$ino && ([info exists eflag] && $eflag)} {
			lappend putcol_cmd "-e"
		} elseif {$ino && ([info exists eflag2] && $eflag2)} {
			lappend putcol_cmd "-ec"
		}
		set tot_outlines 0
		catch {unset col_to_table}
		if {!$col_ungapd_numeric} {
			set col_ungapd_numeric 1
			foreach val [$tb.otframe.l.list get 0 end] {
				if {![IsNumeric $val]} {
					set col_ungapd_numeric 0
					break
				}
			}
		}
		if {$col_ungapd_numeric} {
			set newtab_OK 0
			set sloom_cmd [linsert $putcol_cmd 1 "#"]
			if [catch {open "|$sloom_cmd"} CDPcolput] {
				ErrShow "$CDPcolput"
		   	} else {
		   		fileevent $CDPcolput readable "DisplayNewTable"
				vwait newtab_OK
		   	}
		}
		if {[info exists altered]} {
			set col_ungapd_numeric 0
		}
		if [info exists col_to_table] {
			if [catch {open $evv(COLFILE3) "w"} thisfileId] {
				ForceVal $tabed.message.e "Cannot open temporary file $evv(COLFILE3) to write new table"
			 	$tabed.message.e config -bg $evv(EMPH)
				catch {unset col_to_table}
				return
			}
	
			foreach line $col_to_table {
				catch {unset newline}
				set line [split $line]
				set zort ""
				foreach item $line {
					if {[string length $item] > 0} {
						append zort $item " "
					}				
				}
				if {[set zlen [string length $zort]] > 0} {
					incr zlen -2
					set zort [string range $zort 0 $zlen]
					$tb.otframe.l.list insert end $zort
					puts $thisfileId $zort
					incr tot_outlines
				}
			}
			ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
			close $thisfileId
		}
	}
	EnableOutputTableOptions 0 1
	if {$col_exception} {
		set outcolcnt 1
	} elseif {$coltype == "k"} {
		set outcolcnt 1
		if {!$ino} {
			SetKCState "i"
		}
	} else {
		if {$is_itab} {
			set outcolcnt $incols 
		}
		if {$coltype == "i"} {
			incr outcolcnt
		}
	}
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
#FOCUS ON TABLE NAME ENTRY
	focus $tabed.bot.ktframe.fnm
}

#------ Generate a new column from existing column

proc GenerateNewColumn {colmode p_cnt} {
	global colpar threshold CDPcolrun docol_OK outlines threshtype tedit_message last_oc last_cr evv wstk
	global inlines coltype rcolno col_ungapd_numeric orig_incolget tround tot_outlines col_x pa
	global colmode_exception tot_inlines lmo insitu orig_inlines record_temacro temacro temacrop tabed isEe
	set orig_colmode ""
	set isEe 0
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {	   	;#	If there's an input TABLE
		SetInout 1												;#	Reset default to act on input TABLE
	}
	HaltCursCop

	if {![string match "copy" $colmode] && ![string match "recycle" $colmode]} {
		set lmo G
		lappend lmo $col_ungapd_numeric $colmode $p_cnt						;#	 Remember last action.
	}
	set tb $tabed.bot
	;# CHECK TRESHOLD VALUE
	switch -- $colmode {
		"a"	 -
		"an" -
		"m"	 -
		"d"	 -
		"RR" -
		"R"	 -
		"P"	 {
			if {([string length $threshold] > 0) && [IsNumeric $threshold]} {
				if {$threshtype} {
					set msg "Calculate For Values Less Than $threshold ??"
				} else {
					set msg "Calculate For Values Greater Than $threshold ??"
				}
				set choice [tk_messageBox -message $msg -type yesno -parent [lindex $wstk end] -icon question]
				if {$choice == "no"} {
					set threshold ""
				}
			}
		}
		"Th" -
		"TM" -
		"ThS" -
		"TMS" {
			if {([string length $threshold] > 0) && [IsNumeric $threshold]} {
				if {$threshtype} {
					set msg "Temper Values Around Reference Value $threshold ??"
				}
				set choice [tk_messageBox -message $msg -type yesno -parent [lindex $wstk end] -icon question]
				if {$choice == "no"} {
					set threshold ""
				}
			}
		}
		"rS" {
			if {(![string length $threshold] > 0) || ![IsNumeric $threshold] || ($threshold < 0.0)} {
				ForceVal $tabed.message.e "Invalid threshold value"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"KKa" -
		"KKan" -
		"KKm" -
		"KKd" {
			set threshold ""
			set colmode [string range $colmode 2 end]
		}
		"KKz" {
			set threshold ""
			set orig_colpar $colpar
			set colpar [expr pow(2.0,($colpar / 12.0))]
			set colmode "m"
		}
		"Mc" -
		"Fc" {
			if {![regexp {^[0-9]+$} $threshold] || ($threshold < 1) || ($threshold > 4096)} {
				ForceVal $tabed.message.e "Invalid PVOC Channel Count parameter 'threshold'."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![IsEven $threshold]} {
				ForceVal $tabed.message.e "Invalid PVOC Channel Count parameter 'threshold'."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"SaN" -
		"SbN" -
		"SaR" -
		"SbR" {
			if {([string length $colpar] <= 0) || ![IsNumeric $colpar]} {
				ForceVal $tabed.message.e "No valid 'N' value."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {([string length $threshold] <= 0) || ![IsNumeric $threshold]} {
				ForceVal $tabed.message.e "No valid 'threshold' value."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			foreach val [$tb.icframe.l.list get 0 end] {
				if {![IsNumeric $val]} {
					ForceVal $tabed.message.e "Process only works with numeric values."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
		}
	}

	if {$colmode == "o"} {
		foreach val [$tb.icframe.l.list get 0 end] {
			if {![IsNumeric $val]} {
				set colmode "on"
				break
			}
		}
	}
	if [string match "sui" $colmode] {
		set ilist [$tb.icframe.l.list curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0)} {
			ForceVal $tabed.message.e "No input column value selected"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set i [lindex $ilist 0]
		set val [$tb.icframe.l.list get $i]
		if {![IsNumeric $val] || ![IsNumeric $colpar]}  {
			set choice [tk_messageBox -message "Selected Values are not numeric: make text substitution??" -type yesno -parent [lindex $wstk end] -icon question]
			if {$choice == "no"} {
				ForceVal $tabed.message.e "Selected Value is not numeric"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![info exists colpar] || ([llength $colpar] <= 0)} {
				ForceVal $tabed.message.e "No value given in 'N'"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set colmode "suit"
			set expa $val
		} else {
			set threshold $val
			set orig_colmode "sui"
			set colmode "su"
		}
	}
	set colparam $colmode

	catch {unset colmode_exception}
	if {[string match "recycle" $colmode] || ($p_cnt < 0)} {
		if {![file exists $evv(COLFILE2)] || ($outlines <= 0)} {
			ForceVal $tabed.message.e "No output column exists"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {($colmode != "ZH") && ($colmode != "Zm")} {
		if {![file exists $evv(COLFILE1)]} {
			ForceVal $tabed.message.e "No column selected"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	set tround 0

	if [string match "recycle" $colmode] {
		if {$col_ungapd_numeric} {
			if [catch {open $evv(COLFILE1) "w"} cfileId] {
				ForceVal $tabed.message.e "Cannot open temporary file to recycle column"
			 	$tabed.message.e config -bg $evv(EMPH)
			} else {			
				set inlines 0
				$tb.icframe.l.list delete 0 end
				foreach line [$tb.ocframe.l.list get 0 end] {
					$tb.icframe.l.list insert end $line
					puts $cfileId $line
					incr inlines
				}
				ForceVal $tb.icframe.dummy.cnt $inlines
				close $cfileId
			}
			if {$record_temacro} {
				lappend temacro "recycle"
				lappend zxz $colpar
				lappend zxz $threshold
				lappend temacrop $zxz
			}
		} else {
			ForceVal $tabed.message.e "Cannot recycle in this case."
		 	$tabed.message.e config -bg $evv(EMPH)
		}
		return
	} elseif [string match "copy" $colmode] {
		set io 0
		set ll $tb.ocframe.l.list
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		$ll delete 0 end	;#	Clear existing listing of output column
		set outlines ""
		foreach line [$tb.icframe.l.list get 0 end] {
			$ll insert end $line
		}
		set outlines $inlines
		ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		set lcnt outlines
		if {$record_temacro} {
			lappend temacro "copy"
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1								  
	} elseif [string match "Ee" $colmode] {
		set io 0
		set ll $tb.ocframe.l.list
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		$ll delete 0 end	;#	Clear existing listing of output column
		set outlines ""
		catch {unset x_lins}
		foreach line [$tb.icframe.l.list get 0 end] {
			if {![IsNumeric $line]} {
				ForceVal $tabed.message.e "Input Column must be numeric."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set line [Engineer $line]
			lappend x_lins $line
		}
		foreach lin $x_lins {
			$ll insert end $lin
		}
		set outlines $inlines
		set lcnt outlines
		if {$record_temacro} {
			lappend temacro "Ee"
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set isEe 1
		set docol_OK 1								  
	} elseif [string match "Eex" $colmode] {
		set io 0
		set ll $tb.ocframe.l.list
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		$ll delete 0 end	;#	Clear existing listing of output column
		set outlines ""
		catch {unset x_lins}
		foreach line [$tb.icframe.l.list get 0 end] {
			if {[IsEngineeringNotation $line]} {
				set line [UnEngineer $line]
			} elseif {![IsNumeric $line]} {
				ForceVal $tabed.message.e "Input Column must be in Engineering Notation."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			lappend x_lins $line
		}
		foreach lin $x_lins {
			$ll insert end $lin
		}
		set outlines $inlines
		set lcnt outlines
		if {$record_temacro} {
			lappend temacro "Eex"
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set isEe 1
		set docol_OK 1								  
	} elseif {($colmode == "ZC") || ($colmode == "ZD")} {
		foreach val [$tb.icframe.l.list get 0 end] {
			lappend zlines $val
		}
		if {$colmode == "ZC"} {
			set zzlines [ReverseList $zlines]
			set zzlines [lrange $zzlines 1 end]
			set zlines [concat $zlines $zzlines]
		} else {
			if {![info exists colpar] || ![IsNumeric $colpar] || ($colpar < 2)} {
				ForceVal $tabed.message.e "Invalid parameter N (number of repeats) : must be positive integer >= 2"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set zzlines [lrange $zlines 1 end]
			set knt 1
			while {$knt < $colpar} {
				set zlines [concat $zlines $zzlines]
				incr knt
			}
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $zlines {
			$ll insert end $val
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {($colmode == "SaN") || ($colmode == "SbN") || ($colmode == "SaR") || ($colmode == "SbR")} {
		switch -- $colmode {
			"SaN" {
				foreach val [$tb.icframe.l.list get 0 end] {
					if {$val > $threshold} {
						lappend zlines $colpar
					} else {
						lappend zlines $val
					}
				}
			}
			"SbN" {
				foreach val [$tb.icframe.l.list get 0 end] {
					if {$val < $threshold} {
						lappend zlines $colpar
					} else {
						lappend zlines $val
					}
				}
			}
			"SaR" {
				foreach val [$tb.icframe.l.list get 0 end] {
					if {$val > $threshold} {
						lappend zlines [expr 1.0/double($val)]
					} else {
						lappend zlines $val
					}
				}
			}
			"SbR" {
				foreach val [$tb.icframe.l.list get 0 end] {
					if {$val < $threshold} {
						lappend zlines [expr 1.0/double($val)]
					} else {
						lappend zlines $val
					}
				}
			}
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $zlines {
			$ll insert end $val
			incr $lcnt
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "rRn"} {
		if {![IsNumeric $colpar] || ![regexp {^[0-9\-]*$} $colpar] || ($colpar == 0)} {
			ForceVal $tabed.message.e "Invalid parameter N (number of items to rotation) : must be non-zero integer"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach val [$tb.icframe.l.list get 0 end] {
			lappend zlines $val
		}
		set rot $colpar
		if {$rot < 0} {
			set rot [expr -$rot]
			set rot [expr $rot % $inlines]
			set rot [expr -$rot]
			incr rot $inlines
		} else {
			set rot [expr $rot % $inlines]
		}
		set rotstart [expr $inlines - $rot]
		set n $rotstart
		lappend zzlines [lindex $zlines $n]
		incr n
		set n [expr $n % $inlines]
		while {$n != $rotstart} {
			lappend zzlines [lindex $zlines $n]
			incr n
			set n [expr $n % $inlines]
		}
		set zlines $zzlines
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $zlines {
			$ll insert end $val
			incr $lcnt
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "suit"} {
			foreach val [$tb.icframe.l.list get 0 end] {
				if {[string match $val $expa]} {
					lappend zlines $colpar
				} else {
					lappend zlines $val
				}
			}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $zlines {
			$ll insert end $val
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "on"} {
		set newvvs {}
		foreach val [$tb.icframe.l.list get 0 end] {
			set len [string length $val]
			set cnt 0
			set innum 0
			set gotnum 0
			set newvv ""
			while {$cnt < $len} {
				set vv [string index $val $cnt]
				if {!$innum} {
					if {[regexp {[0-9]} $vv]} {
						if {$gotnum} {
							ForceVal $tabed.message.e "More than one number in value ($val)"
		 					$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set innum 1
						append newvv $vv
					}
				} elseif {![regexp {[0-9]} $vv]} {
					set innum 0
					set gotnum 1
				} else {
					append newvv $vv
				}
				incr cnt
			}
			if {!$gotnum && !$innum} {
				ForceVal $tabed.message.e "Invalid value ($val) for numeric sort"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			lappend newvvs $newvv
			lappend vals $val
		}
		set len [$tb.icframe.l.list index end]
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set thisval [lindex $vals $n]
			set thisvvs [lindex $newvvs $n]
			set m $n
			incr m
			while {$m < $len} {
				set thatval [lindex $vals $m]
				set thatvvs [lindex $newvvs $m]
				if {$thatvvs <= $thisvvs} {
					set vals [lreplace $vals $n $n $thatval]
					set vals [lreplace $vals $m $m $thisval]
					set newvvs [lreplace $newvvs $n $n $thatvvs]
					set newvvs [lreplace $newvvs $m $m $thisvvs]
					set thisval $thatval
					set thisvvs $thatvvs
				}
				incr m
			}
			incr n
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $vals {
			$ll insert end $val
			incr $lcnt
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "RD"} {
		set ccnt 0
		foreach val [$tb.icframe.l.list get 0 end] {
			if {![IsNumeric $val]} {
				ForceVal $tabed.message.e "Invalid data ($val) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$val < 0} { 
				if {![info exists at_start]} {
					set at_start $ccnt
					if {$ccnt != 0} {
						set atstartval $lastval
					}
				}
			} else {
				if {[info exists at_start]} {
					if {$at_start == 0} {
						while {$at_start < $ccnt} {
							lappend out_vals $val
							incr at_start
						}
					} else {
						set midistart [HzToMidi $atstartval]
						set midiend   [HzToMidi $val]
						set steps [expr $ccnt - $at_start + 1]
						set midistep [expr $midiend - $midistart]
						set midistep [expr double($midistep) / double($steps)]
						set thismidi $midistart
						while {$at_start < $ccnt} {
							set thismidi [expr $thismidi + $midistep]
							lappend out_vals [MidiToHz $thismidi]
							incr at_start
						}
					}
					unset at_start
				}
				lappend out_vals $val
				set lastval $val
			}
			incr ccnt
		}
		if {[info exists at_start]} {
			while {$at_start < $ccnt} {
				lappend out_vals $lastval
				incr at_start
			}
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $out_vals {
			$ll insert end $val
			incr $lcnt
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "SR"} {
		set ccnt 0
		foreach val [$tb.icframe.l.list get 0 end] {
			if {![IsNumeric $val]} {
				ForceVal $tabed.message.e "Invalid data ($val) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$ccnt == 0} {
				lappend out_vals $val
			} elseif {![Flteq $val $lastval]} {
				lappend out_vals $val
			}
			set lastval $val
			incr ccnt
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $out_vals {
			$ll insert end $val
			incr $lcnt
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "sr"} {
		if {![CreateColumnParams $colmode 2]} {	;#	an alternative way to get colpar values
			return
		}
		set ccnt 0
		foreach val [$tb.icframe.l.list get 0 end] {
			if {![IsNumeric $val]} {
				ForceVal $tabed.message.e "Invalid data ($val) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$ccnt == 0} {
				set max_in_val $val
				set min_in_val $val
			} else {
				if {$val > $max_in_val} {
					set max_in_val $val
				} elseif {$val < $min_in_val} {
					set min_in_val $val
				}
			}
			incr ccnt
		}
		set in_range [expr $max_in_val - $min_in_val]
		if {[Flteq $in_range 0.0]} {
			ForceVal $tabed.message.e "Range too small for this process"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set out_range [expr $col_x(2) - $col_x(1)]
		set expander [expr double($out_range) / double($in_range)]
		foreach val [$tb.icframe.l.list get 0 end] {
			set val [expr $val - $min_in_val]
			set val [expr $val * $expander]
			set val [expr $val + $col_x(1)]
			lappend out_vals $val
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $out_vals {
			$ll insert end $val
			incr $lcnt
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "bb"} {
		foreach val [$tb.icframe.l.list get 0 end] {
			if {![IsNumeric $val]} {
				ForceVal $tabed.message.e "Invalid data ($val) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$val == 0.0} {
				lappend out_vals 0
			} else {
				lappend out_vals 1
			}
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $out_vals {
			$ll insert end $val
			incr $lcnt
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {($colmode == "Fs") || ($colmode == "Fe")} {
		if {![info exists colpar] || ([string length $colpar] <= 0)} {
			ForceVal $tabed.message.e "Parameter value missing"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach val [$tb.icframe.l.list get 0 end] {
			lappend zlines $val
		}
		if {$colmode == "Fs"} {
			set zlines [FileNameInsert $zlines $colpar 0]
		} else {
			set zlines [FileNameInsert $zlines $colpar 1]
		}
		if {[llength $zlines] <= 0} {
			ForceVal $tabed.message.e "Invalid filenames generated"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $zlines {
			$ll insert end $val
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {($colmode == "kH")} {
		if {![info exists colpar] || ([string length $colpar] <= 0)} {
			ForceVal $tabed.message.e "Parameter value missing"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists threshold] || ([string length $threshold] <= 0)} {
			ForceVal $tabed.message.e "2nd Parameter value missing (in Threshold)"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set jcnt 0
		set kcnt 0
		set collen [string length $colpar]
		set thrlen [string length $threshold]
		foreach val [$tb.icframe.l.list get 0 end] {
			set qk [string first $colpar $val]
			if {$qk < 0} {
				lappend zlines $val
				incr kcnt
				continue
			}
			incr qk -1
			set zek [string range $val 0 $qk]
			append zek $threshold
			incr qk
			incr qk [string length $colpar]
			append zek [string range $val $qk end]
			lappend zlines $zek
			incr jcnt
			incr kcnt
		}
		if {$jcnt == 0} {
			ForceVal $tabed.message.e "The string '$colpar' was not found."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$jcnt != $kcnt} {
			ForceVal $tabed.message.e "Not all the entries were altered."
		 	$tabed.message.e config -bg $evv(EMPH)
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $zlines {
			$ll insert end $val
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "kI"} {
		foreach val [$tb.icframe.l.list get 0 end] {
			if {![regexp {[0-9]+} $val]} {
				ForceVal $tabed.message.e "The value '$val' does not contain numeric information."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set numends [GetNumericPart $val]
			set val [string range $val [lindex $numends 0] [lindex $numends 1]]
			lappend zlines $val
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $zlines {
			$ll insert end $val
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {[string match gold* $colmode]} {
		foreach val [$tb.icframe.l.list get 0 end] {
			if {[string match 0 [string index $colmode end]]} {
				lappend zlines [expr $val * $evv(GOLDEN)]
			} else {
				if {[Flteq $val 0.0]} {
					ForceVal $tabed.message.e "ZERO value in input column: cannot proceed."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
				lappend zlines [expr $val / $evv(GOLDEN)]
			}
		}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $zlines {
			$ll insert end $val
			incr $lcnt
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		set docol_OK 1
	} elseif {$colmode == "rS"} {
		if {$colpar <0.0} {
			ForceVal $tabed.message.e "Invalid Parameter value"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set rang [expr $threshold - $colpar]
		if {$rang < 0.0} {
			set rang [expr -$rang]
		}
		catch {unset rSvals}
		if {$insitu} {
			set ll $tb.icframe.l.list
			set lcnt inlines
		} else {
			set ll $tb.ocframe.l.list
			set lcnt outlines
		}
		foreach val [$tb.icframe.l.list get 0 end] {
			lappend rSvals $val
		}
		set lastval [lindex $rSvals 0]
		set lastnuval $lastval
		set rSnuvals  $lastval
		foreach val [lrange $rSvals 1 end] {
			set diff [expr $val - $lastval]
			if {$diff < 0} {
				ForceVal $tabed.message.e "Input values do not continually increase"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set diff [expr $diff + (rand() * $rang)]
			set nuval [expr $lastnuval + $diff]
			lappend rSnuvals $nuval
			set lastval $val
			set lastnuval $nuval
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $rSnuvals {
			$ll insert end $val
			incr $lcnt
		}
		set docol_OK 1
	} elseif {$colmode == "Sf"} {
		set ic $tb.icframe.l.list
		set i [$ic curselection]
		if {$i < 0} {
			ForceVal $tabed.message.e "No time value selected"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set bas [$ic get $i]
		if {$bas <= 0} {
			ForceVal $tabed.message.e "$bas is not a valid duration value"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$insitu} {
			set ll $ic
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		set j 0
		foreach val [$ic get 0 end] {
			if {$i == $j}  {
				set val [DisplayToDecPlace 1 6]
			} else {
				if {$val <= 0} {
					ForceVal $tabed.message.e "Entry [expr $j + 1] ($val) is not a valid duration value"
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set val [expr double($bas) / double($val)]
				set val [DisplayToDecPlace $val 6]
			}
			lappend rSvals $val
			incr j
		}
		$ll delete 0 end
		set $lcnt 0
		foreach val $rSvals {
			$ll insert end $val
			incr $lcnt
		}
		set docol_OK 1
	} elseif {$colmode == "xp"} {
		if {![IsNumeric $threshold] || ($threshold < 0)} {
			ForceVal $tabed.message.e "Invalid threshold value"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}	
		set ic $tb.icframe.l.list
		if {$insitu} {
			set ll $ic
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		set maxval 0.0
		foreach	val [$ic get 0 end] {
			if {$val > $maxval} {
				set maxval $val
			}
		}
		if {$maxval <= $threshold} {
			ForceVal $tabed.message.e "No values above threshold value"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set scaler [expr double($maxval) - double($threshold)]
		set thismax $threshold
		set thisstart 0
		set startval [$ic get 0]
		if {$startval > $threshold} {
			set inpeak 1
		} else {
			set inpeak 0
		}
		set lastcnt 0
		set cnt 0
		foreach	val [$ic get 0 end] {
			if {$inpeak} {
				if {$val > $threshold} {
					if {$val > $thismax} {
						set thismax $val
					}
				} else {
					set thismax [expr $thismax - $threshold]
					set thisscaler [expr $scaler / $thismax]
					set thiscnt [expr $cnt - 1]
					foreach val2 [$ic get $lastcnt $thiscnt] {
						set val2 [expr double($val2) - double($threshold)]
						set val2 [expr $val2 * $thisscaler]
						set val2 [expr double($val2) + double($threshold)]
						lappend nulist $val2
					}
					lappend nulist $val 
					set inpeak 0
				}
			} else {
				if {$val > $threshold} {
					set thismax $val
					set lastcnt $cnt
					set inpeak 1
				} else {
					lappend nulist $val 
				}
			}
			incr cnt
		}
		if {$inpeak} {
			set thiscnt [expr $cnt - 1]
			foreach val2 [$ic get $lastcnt $thiscnt] {
				set val2 [expr double($val2) - double($threshold)]
				set val2 [expr $val2 * $thisscaler]
				set val2 [expr double($val2) + double($threshold)]
				lappend nulist $val2
			}
		}
		$ll delete 0 end
		set $lcnt 0
		set outlines 0
		foreach val $nulist {
			$ll insert end $val
			incr $lcnt
		}
		set docol_OK 1
	} elseif {$colmode == "bz"} {
		if {![IsNumeric $colpar]}  {
			ForceVal $tabed.message.e "Invalid parameter N value"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ic $tb.icframe.l.list
		if {$insitu} {
			set ll $ic
			set lcnt "inlines"
		} else {
			set ll $tb.ocframe.l.list
			set lcnt "outlines"
		}
		foreach	val [$ic get 0 end] {
			if {$val < $colpar} {
				set val 0.000000
			}
			lappend nulist $val 
		}
		$ll delete 0 end
		set $lcnt 0
		set outlines 0
		foreach val $nulist {
			$ll insert end $val
			incr $lcnt
		}
		set docol_OK 1
	} else {
		if {$colmode == "B"} {
			set dobob 0
			foreach val [$tb.icframe.l.list get 0 end] {
				if {![IsNumeric $val]} {
					set dobob 1
					break
				}
			}
			if {$dobob} {	
				set nulist [PlainBob]
				if {[llength $nulist] > 0} {
					if {$insitu} {
						set ll $tb.icframe.l.list
						set lcnt "inlines"
					} else {
						set ll $tb.ocframe.l.list
						set lcnt "outlines"
					}
					$ll delete 0 end
					set $lcnt 0
					set outlines 0
					foreach val $nulist {
						$ll insert end $val
						incr $lcnt
					}
					if {$insitu} {
						set fnam $evv(COLFILE1)
					} else {
						set fnam $evv(COLFILE2)
					}
					WriteOutputColumn $fnam $ll $lcnt 0 0 0
				} else {
					ForceVal $tabed.message.e "Plain Bob permutation failed"
		 			$tabed.message.e config -bg $evv(EMPH)
				}
				return
			}
		}
		if {($colmode == "as") || ($colmode == "af")} { 
			set threshold ""
		} elseif {($colmode == "TM") || ($colmode == "TMS") || ($colmode == "ZM") || ($colmode == "ZMS") || ($colmode == "Mc")} {
			foreach val [$tb.icframe.l.list get 0 end] {
				if {$val < 0 || $val > 127} {
					ForceVal $tabed.message.e "The value '$val' is out of MIDI range."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			if {($colmode == "ZM") || ($colmode == "ZMS")} {
				if {$colpar < 0 || $colpar > 127} {
					ForceVal $tabed.message.e "The N value '$val' is out of MIDI range."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}	
		} elseif {($colmode == "Th") || ($colmode == "ThS") || ($colmode == "Zh") || ($colmode == "ZhS")} {
			set subkOK 0
			foreach val [$tb.icframe.l.list get 0 end] {
				if {$val < $evv(FLTERR)} {
					if {(($colmode == "Th") || ($colmode == "ThS")) && !$subOK} {
						set msg "(Subzero) Pitchmarkers Found: Preserve These ??"
						set choice [tk_messageBox -message $msg -type yesno -parent [lindex $wstk end] -icon question]
						if {$choice == "yes"} {
							set subkOK 1
							continue
						}
					}
					ForceVal $tabed.message.e "The value '$val' is out of FRQ range."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			if {($colmode == "Zh") || ($colmode == "ZhS")} {
				if {$colpar < $evv(FLTERR) || $colpar > 12000.0} {
					ForceVal $tabed.message.e "The N value '$val' is out of FRQ reference value range."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}	
		} elseif {$colmode == "R"} {	;# 1/val
			if {![info exists colpar] || ![IsNumeric $colpar]} {
				ForceVal $tabed.message.e "Process requires a value in 'N'."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		} elseif {$colmode == "RR"} {	;# straight reciprocals 
			set colpar ""
			set colmode "R"
			set colparam "R"
		} elseif {($colmode == "ts") || ($colmode == "st")} {
			if {![IsPositiveNumber $colpar]} {
				ForceVal $tabed.message.e "Invalid Parameter value in N"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {([string length $threshold] > 0) && [regexp {^[0-9]+$} $threshold]} {
				set msg "Count samples in groups of $threshold channels"
				set choice [tk_messageBox -message $msg -type yesno -parent [lindex $wstk end] -icon question]
				if {$choice == "yes"} {
					foreach val [$tb.icframe.l.list get 0 end] {
						lappend old_sr_vals $val
						set val [expr $val / double($threshold)]
						if {$colmode == "st"} {
							set val [expr int(round($val))]
						}
						lappend nu_sr_vals $val
					}
					if [catch {open $evv(COLFILE1) "w"} zit] {
						ForceVal $tabed.message.e "Cannot reopen column temp file"
		 				$tabed.message.e config -bg $evv(EMPH)
						return
					}
					foreach val $nu_sr_vals {
						puts $zit $val
					}
					close $zit
				} else {
					set threshold ""
				}
			} else {
				set threshold ""
			}
		} elseif {($colmode == "Rs") && [file exists $colpar]} {
			if {![info exists pa($colpar,$evv(FTYP))]} {
				ForceVal $tabed.message.e "File $colpar is not on the workspace"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![IsABrkfile $pa($colpar,$evv(FTYP))]} {
				ForceVal $tabed.message.e "File $colpar is not a normalised breakfile"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set colparam "Zs"
		}
		if {![TestColParam $colmode]} {							;#	Tests params and flags actions with no DATA output
			ForceVal $tabed.message.e "Parameter value missing"	;#	as 'colmode_exception's
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		if {$colmode == "DI"} {
			if {$p_cnt < 0} {
				set thislist $tb.ocframe.l.list
			} else {
				set thislist $tb.icframe.l.list
			}
			if {[$thislist index end] != 2} {
				ForceVal $tabed.message.e "Process only works when there are (only) 2 values in column."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set diff [expr [$thislist get 0] - [$thislist get 1]]
			ForceVal $tabed.message.e "$diff"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {$colmode == "MI"} {
			if {$p_cnt < 0} {
				set thislist $tb.ocframe.l.list
			} else {
				set thislist $tb.icframe.l.list
			}
			if {[$thislist index end] < 2} {
				ForceVal $tabed.message.e "Process only works when there are at least 2 values in column."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set ssum 0.0
			set sumcnt 0
			set lastval [$thislist get 0]
			foreach val [$thislist get 1 end] {
				set diff [expr $val - $lastval]
				set lastval $val
				set ssum [expr $ssum + $diff]
				incr sumcnt
			}
			set ssum [expr double($ssum)/double($sumcnt)]
			ForceVal $tabed.message.e "$ssum"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {$colmode == "IR"} {
			if {$p_cnt < 0} {
				set thislist $tb.ocframe.l.list
			} else {
				set thislist $tb.icframe.l.list
			}
			if {[$thislist index end] != 2} {
				ForceVal $tabed.message.e "Process only works when there are (only) 2 values in column."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set de_nom [$thislist get 1]
			if {[Flteq $de_nom 0.0]} {
				ForceVal $tabed.message.e "Infinity"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set rat_io [expr [$thislist get 0]/$de_nom]
			ForceVal $tabed.message.e "$rat_io"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {$colmode == "aS"} {
			if {![IsNumeric $colpar] || ($colpar < 0)} {
				ForceVal $tabed.message.e "Invalid step value N"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		if {![info exists colmode_exception] && !$insitu} {
			set last_oc [$tb.ocframe.l.list get 0 end]
			set last_cr $col_ungapd_numeric					;#	In normal situation.
			DisableOutputColumnOptions
		}													;#	Special varieites of addition
		if {[string match  a* $colmode] && ([string length $colmode] > 1)} {
			switch -- [string index $colmode 1] {
				"i" {
					set colmode a
					set colparam $colmode
					set threshold ""
					append colparam 1 			;#	increment
				}
				"d" {
					set colmode a
					set colparam $colmode
					set threshold ""
					append colparam -1			;#	decrement
				}
				"n" {							;#	subtract
					set colmode a		
					set colparam $colmode
					if {[string match [string index $colpar 0] "-"]} {
						set colpar [string range $colpar 1 end]
						append colparam $colpar
					} else {
						append colparam -$colpar	
					}
				}
				"f" {							;#	floor = subtract 1st val in table
					set zqw [$tb.icframe.l.list get 0]
					set colmode a
					set colparam $colmode
					if {[string match [string index $zqw 0] "-"]} {
						set xcolpar [string range $zqw 1 end]
						append colparam $xcolpar
					} else {
						append colparam -$zqw	
					}
				}
				"s" {
					set zqw [expr $colpar - [$tb.icframe.l.list get 0]]
					set colmode a
					set colparam $colmode
					append colparam $zqw		;#	shift
				}
				"T" {							;# append flag
					append colparam $colpar
					set threshold ""
				}
				"X" {							;# append flag
					append colparam $colpar
					set threshold ""
				}
				"S" {
					append colparam $colpar
					set threshold ""
				}
			}
		} elseif {$colmode == "Mc"} {
			if {![ValidSrate $colpar]} {
				ForceVal $tabed.message.e "Invalid Srate : parameter N."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set nyqq [expr $colpar / 2.0]
			foreach val [$tb.icframe.l.list get 0 end] {
				set val [[MidiToHz $val]
				if {($val < $evv(FLTERR)) || ($val >= $nyqq)} {
					ForceVal $tabed.message.e "The value '$val' is out of FRQ range."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
		} elseif {$colmode == "Fc"} {
			if {![ValidSrate $colpar]} {
				ForceVal $tabed.message.e "Invalid Srate : parameter N."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set nyqq [expr $colpar / 2.0]
			foreach val [$tb.icframe.l.list get 0 end] {
				if {($val < $evv(FLTERR)) || ($val >= $nyqq)} {
					ForceVal $tabed.message.e "The value '$val' is out of FRQ range."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
		} elseif {[info exists colpar] && ([string length $colpar] > 0)} {
			append colparam $colpar
		}
		if {$colmode == "ed"} {
			foreach item [$tabed.bot.icframe.l.list get 0 end] {
				if {![IsNumeric $item]} {
					set colmode "eb"
					set colparam "eb"
					break
				}
			}
		}
		if {$colmode == "aS"} {
			set val [$tb.icframe.l.list get end]
			set val [expr $val + $colpar]
			if {$insitu} {
				set ll $tb.icframe.l.list
				set lcnt "inlines"
			} else {
				set ll $tb.ocframe.l.list
				set lcnt "outlines"
			}
			set zcnt 0
			foreach item [$tb.icframe.l.list get 0 end] {
				lappend tmpset $item
				incr zcnt
			}
			lappend tmpset $val
			incr zcnt
			$ll delete 0 end
			set $lcnt ""
			foreach item $tmpset {
				$ll insert end $item
			}
			set $lcnt $zcnt
			set docol_OK 1
		} elseif {($colmode == "Mc") || ($colmode == "Fc")} {
			if {$insitu} {
				set ll $tb.icframe.l.list
				set lcnt "inlines"
			} else {
				set ll $tb.ocframe.l.list
				set lcnt "outlines"
			}
			set zcnt 0
			set bcnt [expr $threshold / 2]
			incr bcnt
			set bwidth [expr double($colpar/2.0) / double($bcnt)]
			set hwidth [expr $bwidth / 2.0]
			foreach item [$tb.icframe.l.list get 0 end] {
				if {$colmode == "Mc"} {
					set item [MidiToHz $item]
				}
				set item [expr $item + $hwidth]	
				set item [expr int(floor($item / $bwidth))]
				lappend tmpset $item
				incr zcnt
			}
			$ll delete 0 end
			set $lcnt ""
			foreach item $tmpset {
				$ll insert end $item
			}
			set $lcnt $zcnt
			set docol_OK 1
		} else {
			set colcmd [file join $evv(CDPROGRAM_DIR) columns]
			if {$p_cnt < 0} {									;#	-ve p_cnt used to flag operation on output column
				lappend colcmd $evv(COLFILE2)
			} else {											;#	otherwise ops are on input col
				lappend colcmd $evv(COLFILE1)
			}
			if {$p_cnt > 0} {									;#	p_cnt > 0 indicates...
				if {![CreateColumnParams $colmode $p_cnt]} {	;#	an alternative way to get colpar values
					return
				}
				set i 1
				while {$i <= $p_cnt} {
					lappend colcmd $col_x($i)
					incr i
				}
			}
			lappend colcmd -$colparam							;#	Check for threshold val, where optional
			if {[string match {[RamdP]} $colmode] || [string match mm $colmode]} {
				if {[info exists threshold] && [IsNumeric $threshold] && ($threshold > 0)} {
					if {$threshtype} {
						set thresh_val "@"
					} else {
						set thresh_val "+"
					}
					append thresh_val $threshold
					lappend colcmd $thresh_val
				}												;#	Check for threshold val, where obligatory
			} elseif {[string match "sp" $colmode] || [string match "sP" $colmode] || [string match "sX" $colmode] \
				   || [string match "sR" $colmode] || [string match "sF" $colmode] || [string match TP $colmode]} {
				if {![info exists threshold] || ![IsNumeric $threshold] || ($threshold < 0)} {
					ForceVal $tabed.message.e "Threshold value missing or invalid"
			 		$tabed.message.e config -bg $evv(EMPH)
					return
				} else {
					set thresh_val "+"
					append thresh_val $threshold
					lappend colcmd $thresh_val
				}
			} elseif {[string match "su" $colmode]} {
				if {![info exists threshold] || ![IsNumeric $threshold]} {
					ForceVal $tabed.message.e "Threshold value missing or invalid"
			 		$tabed.message.e config -bg $evv(EMPH)
					return
				} else {
					set thresh_val "+"
					append thresh_val $threshold
					lappend colcmd $thresh_val
						if {$orig_colmode == "sui"} {
						set threshold ""
					}
			}
			} elseif {[string match "Th" $colmode] || [string match "TM" $colmode]} {
				if {[info exists threshold] && ([string length $threshold] > 0)} {
					if {![IsNumeric $threshold]} {
						ForceVal $tabed.message.e "Threshold value invalid"
			 			$tabed.message.e config -bg $evv(EMPH)
						return
					}
					if {$colmode == "Th"} {
						if {($threshold < .1)  || ($threshold > 12000.0)} {
							ForceVal $tabed.message.e "Threshold value out of range"
			 				$tabed.message.e config -bg $evv(EMPH)
							return
						}
					} elseif {($threshold < 0)  || ($threshold > 127.0)} {
						ForceVal $tabed.message.e "Threshold value out of range"
			 			$tabed.message.e config -bg $evv(EMPH)
						return
					}
					set thresh_val "+"
					append thresh_val $threshold
					lappend colcmd $thresh_val
				}
			} elseif {![info exists nu_sr_vals]} {
				set threshold ""
 				ForceVal $tabed.mid.par2 $threshold
			}
			if {![info exists colmode_exception]} {				;#	In normal case, where there is column output data
				if {$insitu} {									;#	establish which col to act on
					foreach item [$tb.icframe.l.list get 0 end] {
						lappend tmpst $item
					}
					set ll $tb.icframe.l.list
					set lcnt "inlines"
				} else {
					set ll $tb.ocframe.l.list
					set lcnt "outlines"
				}
				$ll delete 0 end
				set $lcnt ""
				if {$lcnt == "inlines"} {
					ForceVal $tb.icframe.dummy.cnt $inlines
				} else {
					ForceVal $tb.ocframe.dummy.cnt $outlines
				}
			} elseif {$p_cnt < 0} { 							;# Otherwise (where there is no out data)
				set ll $tb.ocframe.l.list						;#	set ops on input col
			} else {
				set ll $tb.icframe.l.list						;#	set ops on output col
			}
			set docol_OK 0

			set sloom_cmd [linsert $colcmd 1 "#"]
			if [catch {open "|$sloom_cmd"} CDPcolrun] {
				ErrShow "$CDPcolrun"
	   		} else {
   				fileevent $CDPcolrun readable "DisplayNewColumn $ll"
				vwait docol_OK
	   		}
		}
	}
	if [info exists colmode_exception] {					;#	where there is no data output, quit
		return
	}
	if {$docol_OK} {
		if {$colmode == "ts"} {
			foreach val [$ll get 0 end] {
				lappend out_vvals [expr int(round($val))]
			}
			$ll delete 0 end
			foreach val $out_vvals  {
				$ll insert end $val
			}
			if {[info exists old_sr_vals]} {
				if [catch {open $evv(COLFILE1) "w"} zit] {
					ForceVal $tabed.message.e "Cannot reopen column temp file to restore values"
 					$tabed.message.e config -bg $evv(EMPH)
				}
				foreach val $old_sr_vals {
					puts $zit $val
				}
				close $zit
			}
		}
		if {$insitu && ($colmode != "copy")} {
			set fnam $evv(COLFILE1)
		} else {
			set fnam $evv(COLFILE2)
		}
		if {$colmode == "copy"} {
			WriteOutputColumn $fnam $ll $lcnt 0 1 0
		} else {
			WriteOutputColumn $fnam $ll $lcnt 0 0 0
		}
	} else {
		$ll delete 0 end		;#	Clear existing listing of output column
		set $lcnt ""
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		if {$insitu && [info exists tmpst]} {	  ;#	If its a self-overwrite, restore orig column
			set $lcnt 0
			foreach item $tmpst {
				$ll insert end $item
				incr $lcnt
			}
			if {$lcnt == "inlines"} {
				ForceVal $tb.icframe.dummy.cnt $inlines
			} else {
				ForceVal $tb.ocframe.dummy.cnt $outlines
			}
		}
	}
	if {[info exists orig_colpar]} {
		set colpar $orig_colpar
		unset orig_colpar
	}
}

#------ Test for existence of parameters

proc TestColParam {colmode} {
	global colpar colmode_exception

	if { [string match "ao" $colmode] || [string match "g" $colmode]  || [string match "mi" $colmode] \
	  || [string match "l" $colmode]  || [string match "M" $colmode]  || [string match "t" $colmode]  \
	  || [string match "p" $colmode]  || [string match "so" $colmode] || [string match sd $colmode] \
	  || [string match "mI" $colmode] || [string match "te" $colmode] || [string match DI $colmode] \
	  || [string match IR $colmode]   || [string match "MI" $colmode] } {
		set colmode_exception 1   ;# TEst procedures that give no output, except on message line
	}
	if { [regexp {^[BCgIiJlMoprt]$} $colmode] } {
		set colpar ""
		return 1								   	;#	Force NO parameter in these cases
	}
	switch -- $colmode {
		As  -
		af  -
		ao  -
		B   -
		bb  -
		BC  -
		Ca  -
		cl  -
		Cm  -
		DB  -
		db  -
		dd  - 
		dL  - 
		dh  -
		dg  -
		dM  -
		Ds  -
		ee  -
		ft  -
		ga  -
		gs  -
		mi  -
		mI  -
		MI  -
		hd  -
		hM  -
		Ir  -
		ih  -
		iM  -
		ip  -
		iv  -
		Iv  -
		iV  -
		kA  -
		kB  -
		kC  -
		kT  -
		kX  -
		kY  -
		Md  -
		Mh  -
		Mt  -
		nF  -		
		nM  -
		or  -
		Os  -
		r   -
		ra  -
		Rg  -
		rI  -
		Ro  -
		ro  -
		rr  -
		rR  -
		rT  -
		rX  -
		sa  -
		sb  -
		sD  -
		sf  -
		Sf  -
		sF  -
		sX  -
		sg  -
		sO  -
		sR  -
		sr  -
		sT  -
		St  -
		Tb  -
		TB  -
		TO  -
		te  -
		tr  -
		tR  -
		Tr  -
		rp  -
		Ts  -
		Ys  -
		YS {
			set colpar ""
			return 1								   	;#	Force NO parameter in these cases
		}
	}
	if { [string match do $colmode] || [string match dO $colmode] || [string match ir $colmode]} {
		if {![info exists colpar] || ([string length $colpar] <=0)} {
			set colpar 1							;#	Set NO parameter to mean value 1
		}
	} elseif [string match ed $colmode] {
		if {![info exists colpar] || ([string length $colpar] <=0) || ![IsNumeric $colpar]} {
			set colpar 0							;#	Set NO parameter to mean value 0
		}
	} elseif {![regexp {^[ERsv]$} $colmode] \
	&& ![string match fr $colmode] && ![string match Hg $colmode] && ![string match Mr $colmode] \
	&& ![string match sd $colmode] && ![string match Th $colmode] && ![string match TM $colmode] \
	&& ![string match ThS $colmode] && ![string match TMS $colmode] \
	&& ![string match y* $colmode] && ![string match ai $colmode] && ![string match ad $colmode] \
	&& ![string match DI $colmode] && ![string match IR $colmode] && ![string match sz $colmode] \
	&& ![string match rS $colmode] } {
		if {![info exists colpar] || ([string length $colpar] <= 0)} {
			return 0								;#	Apart from cases with optional parameter
		}											;#	All other cases must have a parameter
	}
	return 1
}

#------ Do vector operations, using Columns programme return capture routine

proc Vectors {colmode} {
	global colpar threshold CDPcolrun docol_OK tedit_message pvec record_temacro temacro temacrop evv
	global coltype col_ungapd_numeric outcolcnt tot_outlines col_x lmo tot_inlines tabedit_ns tabedit_bind2
	global col_tabname col_infnam tabed outlines insitu orig_incolget inlines

	ForceVal $tabed.message.e ""

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	HaltCursCop
	set lmo V
	lappend lmo $col_ungapd_numeric $colmode
	set tb $tabed.bot
	set colparam $colmode
	set pvec "x"

	if {([$tb.icframe.l.list index end] <= 0) || ([$tb.ocframe.l.list index end] <= 0)} {
		ForceVal $tabed.message.e "One or more columns missing."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	DisableOutputTableOptions 1

	set out_to_col 0
	if {([string length $colmode] == 3) && [string match [string index $colmode 2] "X"]} {
		set colmode [string range $colmode 0 1]
		set out_to_col 1
	}
	if {![TestVecParam $colmode]} {
		return
	}
	if {$record_temacro} {
		if {($colmode == "ii") || ($colmode == "iw")} {
			Inf "This Process Cannot Be Used In A Macro"
			return
		}
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$pvec == "o"} { 
		if {$colmode == "py"} {
			set colmode pY
		} else {
			set colmode pN
		}
	}

	if {[info exists colpar] && ([string length $colpar] > 0)} {
		append colparam $colpar
	} elseif {($colmode == "M") || ($colmode == "Mo") || ($colmode == "MO")} {
		if {![CreateColumnParams $colmode 2]} {	;#	This is an alternative to colpar values
			return
		}
		append colparam $col_x(1)
	} elseif {$colmode == "IP"} {
		if {![CreateColumnParams $colmode 4]} {	;#	This is an alternative to colpar values
			return
		}
	}
	if {($colmode == "Mo") || ($colmode == "MO")} {
		set minlines $inlines
		if {$outlines < $minlines} {
			set minlines $outlines
		}
		if {$col_x(1) > $col_x(2)} {
			ForceVal $tabed.message.e "Start entry for morph ($col_x(1)) cannot be after end entry ($col_x(2))."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set col_x(1) [expr int(round($col_x(1)))]
		set col_x(2) [expr int(round($col_x(2)))]
		set mostart $col_x(1)
		set moend   $col_x(2)
		incr mostart -1
		incr moend -1
		if {($mostart < 0) || ($mostart >= $minlines) } {
			ForceVal $tabed.message.e "Start entry for morph ($col_x1) is out of range (1 to $minlines)."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {($moend < 0) || ($moend >= $minlines) } {
			ForceVal $tabed.message.e "End entry for morph ($col_x2) is out of range (1 to $minlines)."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if {$colmode == "jt"} {
		set zz 0
		foreach item [$tb.icframe.l.list get 0 end] {
			set len [string length $item]
			incr len -1
			if {[CDP_Restricted_Directory [string range $item 0 $len] 1]} {
				ForceVal $tabed.message.e "$item is a reserved CDP directory."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			append item [$tb.ocframe.l.list get $zz]
			if {$out_to_col} {
				lappend outvals $item
			} else {
				$tb.otframe.l.list insert end $item
			}
			incr zz
		}
		if {$out_to_col} {
			$tb.ocframe.l.list delete 0 end
			foreach item $outvals {
				$tb.ocframe.l.list insert end $item
			}
		}
		set docol_OK 1
	} elseif {$colmode == "CC"} {
		set q_cnt 1
		foreach item1 [$tb.icframe.l.list get 0 end] item2 [$tb.ocframe.l.list get 0 end] {
			if {$item1 >= $item2} {
				ForceVal $tabed.message.e "Entry $q_cnt : Col1 ($item1) not less than Col2 ($item2)"
	 			$tabed.message.e config -bg $evv(EMPH)
				set q_cnt 0
				break
			}
			incr q_cnt
		}
		if {$q_cnt > 0} {
			ForceVal $tabed.message.e "OK"
			$tabed.message.e config -bg $evv(EMPH)
		}
		set docol_OK 1
	} elseif {$colmode == "RR"} {
		foreach item [$tb.icframe.l.list get 0 end] {
			if {![IsNumeric $item]} {
				ForceVal $tabed.message.e "This option only works with numeric data"
	 			$tabed.message.e config -bg $evv(EMPH)
			}
		}
		foreach item [$tb.ocframe.l.list get 0 end] {
			if {![IsNumeric $item]} {
				ForceVal $tabed.message.e "This option only works with numeric data"
	 			$tabed.message.e config -bg $evv(EMPH)
			}
		}
		foreach item1 [$tb.icframe.l.list get 0 end] {
			foreach item2 [$tb.ocframe.l.list get 0 end] {
				lappend outvals [expr $item1 + $item2]
			}
		}
		$tb.ocframe.l.list delete 0 end
		foreach item $outvals {
			$tb.otframe.l.list insert end $item
		}
		set docol_OK 1

	} elseif {$colmode == "VP"} {
		foreach item [$tb.icframe.l.list get 0 end] {
			if {![regexp {^[0-9]+$} $item]} {
				ForceVal $tabed.message.e "Pattern values (column 1) must be integers"
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			lappend z_llist $item
		}
		set jh [llength $z_llist]
		set aj 0
		set found_vals {}
		while {$aj < $jh} {
			set thisval [lindex $z_llist $aj]
			if {[lsearch $found_vals $thisval] < 0} {
				lappend found_vals $thisval
			}
			incr aj
		}	
		set valcnt [llength $found_vals]
		set aj 0
		while {$aj < $jh} {
			set k [lsearch $found_vals [lindex $z_llist $aj]]
			set z_llist [lreplace $z_llist $aj $aj $k]
			incr aj
		}	
		if {$valcnt > $outlines} { 
			ForceVal $tabed.message.e "Insufficient values in Column 2, to use given pattern in Column 1"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach patval $z_llist {
			$tb.otframe.l.list insert end [$tb.ocframe.l.list get $patval]
		}
		set docol_OK 1
	} elseif {$colmode == "O"} {
		foreach swapcol1 [$tb.icframe.l.list get 0 end] swapcol2 [$tb.ocframe.l.list get 0 end] {
			if {![regexp {[0-9]+} $swapcol1]}  {
				ForceVal $tabed.message.e "No numeric part to value '$swapcol1' in line $ccnt."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set numends [GetNumericPart $swapcol1]
			set startnum [lindex $numends 0]
			set endnum [lindex $numends 1]
			incr endnum 1
			incr startnum -1
			set newval ""
			if {$startnum >= 0} {
				append newval [string range $swapcol1 0 $startnum]
			}
			append newval $swapcol2 [string range $swapcol1 $endnum end]
			lappend nuvals $newval
		}
		$tb.otframe.l.list delete 0 end
		foreach val $nuvals {
			$tb.otframe.l.list insert end $val
		}
		set docol_OK 1
	} elseif {$colmode == "Oo"} {
		foreach swapcol1 [$tb.icframe.l.list get 0 end] swapcol2 [$tb.ocframe.l.list get 0 end] {
			if {$insitu} {
				lappend tmpst $swapcol1
			} else {
				lappend tmpst $swapcol2
			}
			if {![regexp {[0-9]+} $swapcol1]}  {
				ForceVal $tabed.message.e "No numeric part to value '$swapcol1' in line $ccnt."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set numends [GetNumericPart $swapcol1]
			set startnum [lindex $numends 0]
			set endnum [lindex $numends 1]
			incr endnum 1
			incr startnum -1
			set newval ""
			if {$startnum >= 0} {
				append newval [string range $swapcol1 0 $startnum]
			}
			append newval $swapcol2 [string range $swapcol1 $endnum end]
			lappend nuvals $newval
		}
		if {$insitu} {
			$tb.icframe.l.list delete 0 end
			foreach val $nuvals {
				$tb.icframe.l.list insert end $val
			}
		} else {
			$tb.ocframe.l.list delete 0 end
			foreach val $nuvals {
				$tb.ocframe.l.list insert end $val
			}
		}
		set docol_OK 1
	} elseif {($colmode == "la") || ($colmode == "lb")} {
		set nulist1 [$tb.icframe.l.list get 0 end]
		set nulist2 [$tb.ocframe.l.list get 0 end]
		if {$colmode == "la"} {
			set nulist1 [concat $nulist1 $nulist2]
		} else {
			set nulist1 [concat $nulist2 $nulist1]
		}
		if {$out_to_col} {
			if {$insitu} {
				$tb.icframe.l.list delete 0 end
				foreach val $nulist1 {
					$tb.icframe.l.list insert end $val
				}
			} else {
				$tb.ocframe.l.list delete 0 end
				foreach val $nulist1 {
					$tb.ocframe.l.list insert end $val
				}
			}
		} else {
			$tb.otframe.l.list delete 0 end
			foreach val $nulist1 {
				$tb.otframe.l.list insert end $val
			}
		}
		set docol_OK 1
	} elseif {($colmode == "oo") || ($colmode == "o1") || ($colmode == "o2") || ($colmode == "ob")} {
		foreach item [$tb.icframe.l.list get 0 end] {
			if {[LstIndx $item $tb.ocframe.l.list] >= 0} {
				lappend both $item
			} else {
				lappend list1 $item
			}
		}
		foreach item [$tb.ocframe.l.list get 0 end] {
			if {[LstIndx $item $tb.icframe.l.list] < 0} {
				lappend list2 $item
			}
		}
		switch -- $colmode {
			"oo" {
				if {![info exists list1] && ![info exists list2]} {
					ForceVal $tabed.message.e "There are NO ITEMS that occur in only one of the lists."
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
				$tb.otframe.l.list delete 0 end
				if {[info exists list1]} {
					foreach val $list1 {
						$tb.otframe.l.list insert end $val
					}
				}
				if {[info exists list2]} {
					foreach val $list2 {
						$tb.otframe.l.list insert end $val
					}
				}
			}
			"o1" {
				if {![info exists list1]} {
					ForceVal $tabed.message.e "There are NO ITEMS that occur in list 1 only."
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
				$tb.otframe.l.list delete 0 end
				foreach val $list1 {
					$tb.otframe.l.list insert end $val
				}
			}
			"o2" {
				if {![info exists list2]} {
					ForceVal $tabed.message.e "There are NO ITEMS that occur in list 2 only."
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
				$tb.otframe.l.list delete 0 end
				foreach val $list2 {
					$tb.otframe.l.list insert end $val
				}
			}
			"ob" {
				if {![info exists both]} {
					ForceVal $tabed.message.e "There are NO ITEMS that occur in both lists."
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
				$tb.otframe.l.list delete 0 end
				foreach val $both {
					$tb.otframe.l.list insert end $val
				}
			}
		}
		set docol_OK 1
	} elseif {$colmode == "nn"} {
		set k $colpar
		incr k -1
		foreach val [$tb.ocframe.l.list get 0 $k] {
			lappend nuvals $val 
		}
		foreach val [$tb.icframe.l.list get $colpar end] {
			lappend nuvals $val
		}
		$tb.otframe.l.list delete 0 end
		foreach val $nuvals {
			$tb.otframe.l.list insert end $val
		}
		set docol_OK 1
	} elseif {$colmode == "ii"} {
		set docol_OK 0
		set jj 0
		foreach val1 [$tb.icframe.l.list get 0 end] val2 [$tb.ocframe.l.list get 0 end] {
			set bass($jj) $val1
			set diff($jj) [expr $val2 -$val1]
			incr jj
		}
		set diffcnt $jj
		set tot [expr $colpar + 1]
		set k 1
		while {$k <= $colpar} {
			set ratio [expr double($k) / double($tot)]
			catch {unset newtable}
			set jj 0
			while {$jj < $diffcnt} {
				set val [expr $diff($jj) * $ratio]
				set val [expr $val + $bass($jj)]
				lappend newtable $val
				incr jj
			}
			set fnam $threshold
			append fnam $k $evv(TEXT_EXT)
			if [catch {open $fnam "w"} zit] {
				ForceVal $tabed.message.e "Can't open file $fnam (later files not made): see wkspace for output files."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			foreach val $newtable {
				puts $zit $val
			}
			close $zit
			FileToWkspace $fnam 0 0 0 0 1
			incr k
		}
		Inf "See Workspace For Output Files."
	} elseif {$colmode == "iw"} {
		set docol_OK 0
		set jj 0
		if {[string length $threshold] <= 0} {
			set warper 1
		} elseif {![IsNumeric $threshold] || ($threshold < .1) || ($threshold > 10)} {
			ForceVal $tabed.message.e "Invalid Warp value in 'threshold' (range 0.1 to 10)."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			set warper $threshold
		}
		catch {unset nuvals}
		foreach val1 [$tb.icframe.l.list get 0 end] val2 [$tb.ocframe.l.list get 0 end] {
			set ratio [expr double($jj)/double($inlines)]
			set ratio [expr pow($ratio,$warper)]
			set diff [expr $val2 - $val1]
			set diff [expr $diff * $ratio]
			set val [expr $val1 + $diff]
			lappend nuvals $val
			incr jj
		}
		foreach val $nuvals {
			$tb.otframe.l.list insert end $val
		}
		set docol_OK 1
	} else {
		set veccmd [file join $evv(CDPROGRAM_DIR) vectors]
		lappend veccmd $evv(COLFILE1) $evv(COLFILE2) -$colparam
		if {($colmode == "M") || ($colmode == "Mo") || ($colmode == "MO")} {
			lappend veccmd $col_x(2)
		}
		if {$colmode == "IP"} {
			lappend veccmd $col_x(1) $col_x(2) $col_x(3) $col_x(4)
		}
		if {[string match S $colmode] || [string match p* $colmode]} {
			if {[info exists threshold] && ([string length $threshold] > 0)} {
				set errorbnd $threshold
				if {$errorbnd <= 0} {
					set errorbnd -$errorbnd
				}
				if {$errorbnd < $evv(FLTERR)} {
					set errorbnd $evv(FLTERR)
					set threshold ""
					ForceVal $tabed.mid.par2 $threshold
				}
				lappend veccmd $errorbnd
			} else {
				set threshold ""
					ForceVal $tabed.mid.par2 $threshold
			}
		}
		set docol_OK 0
		set sloom_cmd [linsert $veccmd 1 "#"]
		if {$out_to_col} {
			$tb.ocframe.l.list delete 0 end
			if [catch {open "|$sloom_cmd"} CDPcolrun] {
				ErrShow "$CDPcolrun"
   			} else {
   				fileevent $CDPcolrun readable "DisplayNewColumn $tb.ocframe.l.list"
				vwait docol_OK
   			}
		} else {
			if [catch {open "|$sloom_cmd"} CDPcolrun] {
				ErrShow "$CDPcolrun"
   			} else {
   				fileevent $CDPcolrun readable "DisplayNewColumn $tb.otframe.l.list"
				vwait docol_OK
   			}
		}
	}
	if {$docol_OK} {
		if {($colmode == "Oo") || $out_to_col} {
			if {$insitu} {
				set fnam $evv(COLFILE1)
				set ll $tb.icframe.l.list
				set lcnt "inlines"
			} else {
				set fnam $evv(COLFILE2)
				set ll $tb.ocframe.l.list
				set lcnt "outlines"
			}
			WriteOutputColumn $fnam $ll $lcnt 0 0 0
		} else {
			if {[WriteOutputTable $evv(LINECNT_ONE)]} {
				EnableOutputTableOptions 0 1
			}
		}
	} else {
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
	}
}

#------ Test for existence of vector parameters

proc TestVecParam {colmode} {
	global colpar pvec tabed inlines outlines threshold evv

 	set ic $tabed.bot.icframe.l.list
 	set oc $tabed.bot.ocframe.l.list

	if {$colmode == "py" || $colmode == "pn"} {
		set i [$ic curselection]
		if {![info exists i] || ($i < 0)} {
			set i [$oc curselection]
			if {![info exists i] || ($i < 0)} {
				ForceVal $tabed.message.e "No value selected with cursor."
			 	$tabed.message.e config -bg $evv(EMPH)
				return 0
			}
			set colpar [$oc get $i]
			set pvec "o"
		} else {
			set colpar [$ic get $i]
		}
	} elseif {$colmode == "C"} {
		if [IsNumeric $colpar] {
		 	if {$colpar < 0.0} {
				set colpar -$colpar
			}
		} else {
			set colpar ""
		}
		return 1
	} elseif {($colmode == "b") || ($colmode == "B") || ($colmode == "M") || ($colmode == "IP")} {
		set colpar ""
		return 1
	} elseif {[regexp {^[Soic]$} $colmode] || [string match k* $colmode]} {
		if {![info exists colpar] || ([string length $colpar] <=0)} {
			ForceVal $tabed.message.e "No parameter given"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0								;#	These cases must have a parameter
		}
		if {(($colmode == "o") || ($colmode == "i") || [string match k* $colmode]) && ($colpar < 1.0)} {
			ForceVal $tabed.message.e "Parameter out of range (>= 1)"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0								;#	These cases must have a parameter >= 1
		}
	} elseif {$colmode == "nn"} {
		if {![info exists colpar] || ([string length $colpar] <=0)} {
			ForceVal $tabed.message.e "No parameter given"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		if {![regexp {^[0-9]+$} $colpar] || ($colpar <= 0)} {
			ForceVal $tabed.message.e "Invalid parameter"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		if {$colpar > $inlines} {
			ForceVal $tabed.message.e "Insufficient lines in input column for parameter N ($colpar)"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		if {$colpar > $outlines} {
			ForceVal $tabed.message.e "Insufficient lines in output column for parameter N ($colpar)"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
	} elseif {$colmode == "ii"} {
		if {$inlines != $outlines} {
			ForceVal $tabed.message.e "Start and end tables must be of the same length"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		if {![info exists colpar] || ([string length $colpar] <=0)} {
			ForceVal $tabed.message.e "No parameter 'N' given"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		if {![regexp {^[0-9]+$} $colpar] || ($colpar <= 1)} {
			ForceVal $tabed.message.e "Invalid parameter 'N' (>=1)"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		if {![info exists threshold] || ([string length $threshold] <=0)} {
			ForceVal $tabed.message.e "No filename entered in 'threshold' box"
		 	$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		set jj 1
		while {$jj <= $colpar} {
			set fnam $threshold
			append fnam $jj $evv(TEXT_EXT)
			if {[file exists $fnam]} {
				ForceVal $tabed.message.e "A file '$fnam' already exists: please CHOOSE A DIFFERENT NAME"
		 		$tabed.message.e config -bg $evv(EMPH)
				return 0
			}
			incr jj
		}
	} else {
		set colpar ""
		ForceVal $tabed.mid.par1 $colpar
	}
	return 1
}

#------ Display new column resulting from editing

proc DisplayNewColumn {listing} {
	global CDPcolrun docol_OK tabed evv

	if [eof $CDPcolrun] {
		set docol_OK 1
		catch {close $CDPcolrun}
		return
	} else {
		gets $CDPcolrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match INFO:* $line] {
			set line [string range $line 6 end] 
			$listing insert end $line
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
		} elseif [string match END:* $line] {
			set docol_OK 1
			catch {close $CDPcolrun}
			return
		} else {
			set line "Invalid Message ($line) received from program."
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
			catch {close $CDPcolrun}
			return
		}
	}
	update idletasks
}			

#------ Display a single column got from a table

proc DisplayColumnFromTable {} {
	global CDPcolget incol_OK col_from_table tabed evv

	if [eof $CDPcolget] {
		set incol_OK 1
		catch {close $CDPcolget}
		return
	} else {
		gets $CDPcolget line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match INFO:* $line] {
			if {[string length $line] > 6} {
				lappend col_from_table [string range $line 6 end]
			}
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set incol_OK 0
			catch {close $CDPcolget}
			return
		} elseif [string match END:* $line] {
			set incol_OK 1
			catch {close $CDPcolget}
			return
		} else {
			set line "Invalid Message ($line) received from program."
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set incol_OK 0
			catch {close $CDPcolget}
			return
		}
	}
	update idletasks
}			

#------ Display a new (edited) table

proc DisplayNewTable {} {
	global CDPcolput newtab_OK col_to_table tabed evv

	if [eof $CDPcolput] {
		set newtab_OK 1
		catch {close $CDPcolput}
		return
	} else {
		gets $CDPcolput line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match INFO:* $line] {
			set line [string range $line 6 end] 
			lappend	col_to_table $line
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set newtab_OK 0
			catch {close $CDPcolput}
			return
		} elseif [string match END:* $line] {
			set newtab_OK 1
			catch {close $CDPcolput}
			return
		} else {
			set line "Invalid Message ($line) received from program."
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set newtab_OK 0
			catch {close $CDPcolput}
			return
		}
	}
	update idletasks
}			

#------ Save a new (edited) table to file

proc SaveNewTable {} {
	global col_tabname col_infilelist c_incols c_inlines wl ch tedit_message outcolcnt tot_outlines evv
	global wstk col_infnam savestyle rememd p_pg tot_inlines sl_real tabed excluded_batchfiles pa tabed_outfile
	global mixmanage otablist tab_ness nesstype

	set save_mixmanage 0
	set nessupdate 0
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists outcolcnt] || ($outcolcnt <= 0)} {
		ForceVal $tabed.message.e "There is no Output Table to save"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}		
	if {![info exists col_tabname] || ([string length $col_tabname] <= 0)} {
		ForceVal $tabed.message.e  "No Name given for the new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {!$sl_real} {
		return
	}
#JUNE 30 UC-LC FIX
	set col_tabname [string tolower $col_tabname]
	set xxx [file tail $col_tabname]
	if {![string match $col_tabname $xxx]} {
		ForceVal $tabed.message.e  "You cannot use directory paths here"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set col_tabname [file rootname $xxx]
	set col_tabname [FixTxt $col_tabname "table name"]
	if {[string length $col_tabname] <= 0} {
		return
	}
	if {($savestyle != 0 && $savestyle != 3) && ![GenericTablefileNameIsValid $col_tabname]} {
		return
	}

	switch -- $savestyle {
		3 - 
		0	{	;#	To a single file
			if {$savestyle==3} {
				if {[lsearch $excluded_batchfiles $col_tabname] >= 0} {
					Inf "This Is A Reserved Batchfile Name: Please Choose Another Name."
					return
				}
				set fnam $col_tabname$evv(BATCH_EXT)
			} else {
				set ftyp [FindFileType $evv(COLFILE3)]
				if {$ftyp < 0} {
					set this_ext $evv(TEXT_EXT)
				} else {
					set ntyp [IsAValidNessFile $evv(COLFILE3) 0 $tab_ness 0]
					if {$ntyp != $tab_ness} {
						set msg "OUTPUT IS NO LONGER A VALID PHYSICAL MODELLING DATA FILE: KEEP IT ??"
						set choice [tk_messageBox -message $msg -type yesno -default "no" -parent [lindex $wstk end] -icon question]
						if {$choice == "no"} {
							return
						} else {
							set ntyp 0
						}
					}
					if {$ntyp == 0} {
						set this_ext [AssignTextfileExtension $ftyp]
						if {[string match $this_ext [GetTextfileExtension brk]] && ![string match $this_ext $evv(TEXT_EXT)]} {
							if {![HasBrkpntStructure $otablist 0]} {
								set this_ext $evv(TEXT_EXT)
							}
						}
					} else {
						set this_ext $evv(NESS_EXT)
					}
				}
				set fnam $col_tabname$this_ext
			}
			if {$p_pg} {
				if {[set i [LstIndx $fnam $ch]] >= 0} {
					Inf "You cannot overwrite a file you are currently using in a process."
					return
				}
			}
			if {[info exists col_infnam] && [string match $fnam $col_infnam]} {
				ForceVal $tabed.message.e "Cannot overwrite input file (force overwrite? select another file at left)"
			 	$tabed.message.e config -bg $evv(EMPH)
				set col_tabname ""
				return
			}
			if [file exists $fnam] {
				set choice [tk_messageBox -message "File '$fnam' exists. Overwrite it?" -type yesno -parent [lindex $wstk end] -icon question]
				if {$choice == "yes"} {
					if [catch {file delete $fnam} in] {
						ForceVal $tabed.message.e  "Cannot delete existing file $fnam"
					 	$tabed.message.e config -bg $evv(EMPH)
						return
					} else {
						DummyHistory $fnam "OVERWRITTEN"
						if {[info exists mixmanage($fnam)]} {
							unset mixmanage($fnam)
							set save_mixmanage 1
						}
						if {[info exists nesstype($fnam)]} {
							PurgeNessData $fnam
							set nessupdate 1
						}
					}
					if {[set i [LstIndx $fnam $wl]] >= 0} {
						$wl delete $i
						WkspCntSimple -1
						catch {unset rememd}
					}
					PurgeArray $fnam
					RemoveFromChosenlist $fnam
					DeleteFileFromSrcLists  $fnam
					if [info exists col_infilelist] {
						if {[set index [lsearch $col_infilelist $fnam]] >= 0} {
							set col_infilelist [lreplace $col_infilelist $index $index]
							set c_incols   [lreplace $c_incols $index $index]
							set c_inlines  [lreplace $c_inlines $index $index]
						}
					}
					if {[set i [LstIndx $fnam $tabed.bot.fframe.l.list]] >= 0} {
						$tabed.bot.fframe.l.list delete $i
					}
				} else {
					return
				}
			} else {
				DummyHistory $fnam "CREATED"
			}
			if [catch {file copy $evv(COLFILE3) $fnam} in] {
				ForceVal $tabed.message.e  "Cannot save the new table $fnam"
			 	$tabed.message.e config -bg $evv(EMPH)
				set col_tabname ""
				MixMPurge 1						;# ORIGINAL $fnam POSSIBLY DESTROYED ABOVE
				NessMPurge 1
				return
			} else {
				set te_st [FileToWkspace $fnam 0 0 0 0 1]
				if {[UpdatedIfAMix $fnam 0]} {	;#	FILE CREATED: THIS WILL UPDATE MIX MANAGER, EVEN IF FileToWkspace FAILS
					set save_mixmanage 1
				} elseif {[UpdatedIfANessFull $fnam]} {
					set nessupdate 1
				}
				if {$te_st <= 0} {
					if {$save_mixmanage}  {
						MixMStore
					}
					if {$nessupdate}  {
						NessMStore
					}
					return
				}
			}
			set tabed_outfile $fnam
			$tabed.bot.fframe.l.list insert 0 $fnam
			lappend col_infilelist $fnam
			lappend c_incols   $outcolcnt			;#	Must be same as input column count
			lappend c_inlines  $tot_outlines		;#	Must be same as input line count
			AddNameToNameslist $col_tabname $tabed.bot.ktframe.names.list
		}
		1 {	;#	Rows to separate files
			if {$p_pg} {
				set i 1
				foreach line [$tabed.bot.otframe.l.list get 0 end] {
					set fnam $col_tabname$i$evv(TEXT_EXT)
					if {[set i [LstIndx $fnam $ch]] >= 0} {
						Inf "You cannot overwrite a file you are currently using in a process."
						return
					}
					incr i
				}
			}
			set i 1
			foreach line [$tabed.bot.otframe.l.list get 0 end] {
				set llcnt 0
				set nu_line [string trim $line]
				set nu_line [split $nu_line]
				foreach item $nu_line {
					if {[string length $item] > 0} {
						incr llcnt
					}
				}
				if {$llcnt > 0} {
					set fnam $col_tabname$i$evv(TEXT_EXT)
					if [catch {open $fnam "w"} cfileId] {
						incr i
						continue
					}
					if {[info exists mixmanage($fnam)]} {
						unset mixmanage($fnam)
						set save_mixmanage 1
					}
					puts $cfileId $line
					close $cfileId
					lappend outlist $i
					if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
						incr i
						if {[UpdatedIfAMix $fnam 0]} { ;# fnam CREATED, POSSIBLE OVERWRITE
							set save_mixmanage 1
						}
						continue
					} else {
						if {[UpdatedIfAMix $fnam 0]} { ;# fnam CREATED, POSSIBLE OVERWRITE
							set save_mixmanage 1
						}
					}
					lappend w_outlist $i
					$tabed.bot.fframe.l.list insert 0 $fnam
					lappend col_infilelist $fnam
					lappend c_incols  $llcnt
					lappend c_inlines  1	;#	Must be 1
				}
				incr i
			}
			if {[info exists w_outlist]} {
				set msg "Written files '$col_tabname' for rows $w_outlist"
				AddNameToNameslist $col_tabname $tabed.bot.ktframe.names.list
			} elseif {[info exists outlist]} {
				set msg "Written rows to outfiles '$col_tabname', but files not on workspace."
			} else {
				set msg "Failed to write any rows to outfiles."
			}
			ForceVal $tabed.message.e $msg
		 	$tabed.message.e config -bg $evv(EMPH)
		}
		2 {	;#	Columns to separate files
			set maxk 0
			foreach line [$tabed.bot.otframe.l.list get 0 end] {
				set k 1
				foreach val $line {
					if {[string length $val] > 0} {
						lappend out_list($k) $val
					}
					incr k
				}
				if {$k > $maxk} {
					set maxk $k
				}
			}
			if {$p_pg} {
				set i 1
				while {$i < $maxk} {
					set fnam $col_tabname$i$evv(TEXT_EXT)
					if {[set i [LstIndx $fnam $ch]] >= 0} {
						Inf "You cannot overwrite a file you are currently using in a process."
						return
					}
					incr i
				}
			}
			set i 1
			while {$i < $maxk} {
				set fnam $col_tabname$i$evv(TEXT_EXT)
				if [catch {open $fnam "w"} cfileId] {
					incr i
					continue
				}
				if {[info exists mixmanage($fnam)]} {
					unset mixmanage($fnam)
					set save_mixmanage 1
				}
				set line_cnt 0
				foreach val $out_list($i) {
					puts $cfileId $val
					incr line_cnt
				}
				lappend outlist $i
				set out_lines($i) $line_cnt
				incr i
				close $cfileId
			}
			if [info exists outlist] {		
				foreach i $outlist {
					set fnam $col_tabname$i$evv(TEXT_EXT)
					$tabed.bot.fframe.l.list insert 0 $fnam
					if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
						if {[UpdatedIfAMix $fnam 0]} {	;# fnam CREATED, POSSIBLE OVERWRITE
							set save_mixmanage  1
						}
						continue
					}
					if {[UpdatedIfAMix $fnam 0]} {		;# fnam CREATED, POSSIBLE OVERWRITE
						set save_mixmanage  1
					}
					lappend col_infilelist $fnam
					lappend c_incols   1				;#	Must be 1
					lappend c_inlines  $out_lines($i)
				}
				set msg "Written files '$col_tabname' for columns $outlist"
				AddNameToNameslist $col_tabname $tabed.bot.ktframe.names.list
			} else {
				set msg "Failed to write any columns to outfiles."
			}
			ForceVal $tabed.message.e $msg
		 	$tabed.message.e config -bg $evv(EMPH)
		}
	}
	if {[MixMPurge 0]} {			;# ORIGINAL $fnam POSSIBLY DESTROYED ABOVE
		set save_mixmanage 1
	}
	if {$save_mixmanage} {
		MixMStore
	}
	set savestyle 0
#FOCUS BACK ON PARAM BOX
	focus $tabed.mid.par1
}

#------

proc GenericTablefileNameIsValid {fnam} {
	global tabed evv

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if [regexp {[0-9]} [string range $fnam end end]] {
		ForceVal $tabed.message.e "Numerals not allowed at end of a generic filename."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	set len [string length $fnam]
	foreach fnm [glob -nocomplain $fnam*$evv(TEXT_EXT)] {	
		set fnm [file rootname $fnm]
		if {[string length $fnm] > $len} {
			set zstr [string range $fnm $len end]
			if [regexp {^[0-9]+$} $zstr] {
				ForceVal $tabed.message.e "Generic filename already in use."
				$tabed.message.e config -bg $evv(EMPH)
				return 0
			}
		}
	}
	return 1
}

#--- Which? Facility on TabEditor

proc TEWhich {} {
	global pr_tew view_offset evv
	
	set f .tew
	if [Dlg_Create $f "WHICH MENU?              (Hit a keyboard letter, to search)" "set pr_tew 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(SBDR)] 
		set f1 [frame $f.1 -borderwidth $evv(SBDR)] 
		frame $f.1a -height 1 -bg $evv(POINT)
		set f2 [frame $f.2 -borderwidth $evv(SBDR)] 
		button $f0.ok -text "Close" -command "set pr_tew 0" -highlightbackground [option get . background {}]
   		pack $f0.ok -side top

		label $f1.xx1 -text "TYPE OF PROCESS"
		label $f1.yy1 -text "MENU TO USE        "
		pack $f1.xx1 -side left
		pack $f1.yy1 -side right

		set c [Scrolled_Canvas $f2.c -width 600 -height 470 -scrollregion {0 0 500 4100}]
;#NB EXTEND scrollregion-4th-value by c.20 units, when adding items to display!!
		pack $f2.c -fill both -expand true

		set fi [frame $c.fi -bd 2]
		$c create window 0 0 -anchor nw -window $fi
		frame $fi.ve -width 1 -bg $evv(POINT)
		grid $fi.ve -row 0 -column 1 -rowspan 212 -sticky ns
;#NB ADD 1 to rowspan for each new entry added
		label $fi.xx3 -text "Advancing Patterns . . . . . . . . . . . . . . . ."
		label $fi.yy3 -text "CREATE2"
		grid $fi.xx3 -row 3 -column 0 -sticky w
		grid $fi.yy3 -row 3 -column 2 -sticky w
		label $fi.xx4 -text "Algebra . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy4 -text "MATHS"
		grid $fi.xx4 -row 4 -column 0 -sticky w
		grid $fi.yy4 -row 4 -column 2 -sticky w
		label $fi.xx5 -text "Alternating patterns . . . . . . . . . . . . . . . ."
		label $fi.yy5 -text "CREATE2"
		grid $fi.xx5 -row 5 -column 0 -sticky w
		grid $fi.yy5 -row 5 -column 2 -sticky w
		label $fi.xx6 -text "Arithmetic Operations . . . . . . . . . . . . . . ."
		label $fi.yy6 -text "MATHS, COMBINE"
		grid $fi.xx6 -row 6 -column 0 -sticky w
		grid $fi.yy6 -row 6 -column 2 -sticky w
		label $fi.xx7 -text "Attacks . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy7 -text "ENV"
		grid $fi.xx7 -row 7 -column 0 -sticky w
		grid $fi.yy7 -row 7 -column 2 -sticky w
		label $fi.xx8 -text "Balance, Convert to Balance-Many format . . ."
		label $fi.yy8 -text "BRK (Modify Table)"
		grid $fi.xx8 -row 8 -column 0 -sticky w
		grid $fi.yy8 -row 8 -column 2 -sticky w
		label $fi.xx9 -text "Balance, Convert to Envelopes (listed in sequence) . . ."
		label $fi.yy9 -text "TABLES (Specific Data Types)"
		grid $fi.xx9 -row 9 -column 0 -sticky w
		grid $fi.yy9 -row 9 -column 2 -sticky w
		label $fi.xx10 -text "Balance, Invert . . . . . . . . . . . . . . ."
		label $fi.yy10 -text "BRK (Modify Values)"
		grid $fi.xx10 -row 10 -column 0 -sticky w
		grid $fi.yy10 -row 10 -column 2 -sticky w
		label $fi.xx11 -text "Batchfiles: extract-(edit)-insert specific lines only"
		label $fi.yy11 -text "TABLES (Cyclic), JOIN (Concatenate)"
		grid $fi.xx11 -row 11 -column 0 -sticky w
		grid $fi.yy11 -row 11 -column 2 -sticky w
		label $fi.xx12 -text "Batchfiles: Duplicate with numeric indexing of duplicates"
		label $fi.yy12 -text "TABLES (Duplicate), JOIN (Batchfiles)"
		grid $fi.xx12 -row 12 -column 0 -sticky w
		grid $fi.yy12 -row 12 -column 2 -sticky w
		label $fi.xx13 -text "Batchfiles: for zero-crossing editing"
		label $fi.yy13 -text "TABLES (Specific Data Types, Edit Data)"
		grid $fi.xx13 -row 13 -column 0 -sticky w
		grid $fi.yy13 -row 13 -column 2 -sticky w
		label $fi.xx14 -text "Beats . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy14 -text "TIME"
		grid $fi.xx14 -row 14 -column 0 -sticky w
		grid $fi.yy14 -row 14 -column 2 -sticky w
		label $fi.xx15 -text "Beats to Time . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy15 -text "TIME"
		grid $fi.xx15 -row 15 -column 0 -sticky w
		grid $fi.yy15 -row 15 -column 2 -sticky w
		label $fi.xx16 -text "Bell-ringing . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy16 -text "DERIVE"
		grid $fi.xx16 -row 16 -column 0 -sticky w
		grid $fi.yy16 -row 16 -column 2 -sticky w
		label $fi.xx17 -text "Chord Data: Play it . . . . . . . . . . . . . . ."
		label $fi.yy17 -text "PITCH, TABLES(Play Pitch Set)"
		grid $fi.xx17 -row 17 -column 0 -sticky w
		grid $fi.yy17 -row 17 -column 2 -sticky w
		label $fi.xx18 -text "Combine columns . . . . . . . . . . . . . . . . . ."
		label $fi.yy18 -text "COMBINE"
		grid $fi.xx18 -row 18 -column 0 -sticky w
		grid $fi.yy18 -row 18 -column 2 -sticky w
		label $fi.xx19 -text "Combine tables . . . . . . . . . . . . . . . . . . ."
		label $fi.yy19 -text "JOIN"
		grid $fi.xx19 -row 19 -column 0 -sticky w
		grid $fi.yy19 -row 19 -column 2 -sticky w
		label $fi.xx20 -text "Comment Lines: remove them. . . . . . . . . . . . ."
		label $fi.yy20 -text "TABLES (Delete Rows)"
		grid $fi.xx20 -row 20 -column 0 -sticky w
		grid $fi.yy20 -row 20 -column 2 -sticky w
		label $fi.xx21 -text "Compare . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy21 -text "COMBINE, TEST"
		grid $fi.xx21 -row 21 -column 0 -sticky w
		grid $fi.yy21 -row 21 -column 2 -sticky w
		label $fi.xx22 -text "Compare and Sort or Remove . . . . . . . ."
		label $fi.yy22 -text "JOIN(Order)"
		grid $fi.xx22 -row 22 -column 0 -sticky w
		grid $fi.yy22 -row 22 -column 2 -sticky w
		label $fi.xx23 -text "Concatenate . . . . . . . . . . . . . . . . . . ."
		label $fi.yy23 -text "JOIN"
		grid $fi.xx23 -row 23 -column 0 -sticky w
		grid $fi.yy23 -row 23 -column 2 -sticky w
		label $fi.xx24 -text "Concave, Convex Joins  . . . . . . . ."
		label $fi.yy24 -text "CREATE(Unequal Steps, Sinusoidal)"
		grid $fi.xx24 -row 24 -column 0 -sticky w
		grid $fi.yy24 -row 24 -column 2 -sticky w
		label $fi.xx25 -text "Convert Units . . . . . . . . . . . . . . . . ."
		label $fi.yy25 -text "GAIN, PITCH, INTERVAL, TIME"
		grid $fi.xx25 -row 25 -column 0 -sticky w
		grid $fi.yy25 -row 25 -column 2 -sticky w
		label $fi.xx26 -text "Convert Data Type . . . . . . . . . . . . ."
		label $fi.yy26 -text "TABLES"
		grid $fi.xx26 -row 26 -column 0 -sticky w
		grid $fi.yy26 -row 26 -column 2 -sticky w
		label $fi.xx27 -text "Copies . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy27 -text "ORDER"
		grid $fi.xx27 -row 27 -column 0 -sticky w
		grid $fi.yy27 -row 27 -column 2 -sticky w
		label $fi.xx28 -text "Copy individual values . . . . . . . . ."
		label $fi.yy28 -text "DERIVE"
		grid $fi.xx28 -row 28 -column 0 -sticky w
		grid $fi.yy28 -row 28 -column 2 -sticky w
		label $fi.xx29 -text "Copy . . . . . . . . . . . . . . . . . .  . . . . . . . . ."
		label $fi.yy29 -text "see also 'DUPLICATE'"
		grid $fi.xx29 -row 29 -column 0 -sticky w
		grid $fi.yy29 -row 29 -column 2 -sticky w
		label $fi.xx30 -text "Cosinusoidal sweep, or join . . . . . . . . ."
		label $fi.yy30 -text "CREATE(Unequal Steps, Sinusoidal),BRK(Modify Table)"
		grid $fi.xx30 -row 30 -column 0 -sticky w
		grid $fi.yy30 -row 30 -column 2 -sticky w
		label $fi.xx31 -text "Create . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy31 -text "CREATE, CREATE2, TABLES"
		grid $fi.xx31 -row 31 -column 0 -sticky w
		grid $fi.yy31 -row 31 -column 2 -sticky w
		label $fi.xx32 -text "Cut . . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy32 -text "BRK"
		grid $fi.xx32 -row 32 -column 0 -sticky w
		grid $fi.yy32 -row 32 -column 2 -sticky w
		label $fi.xx33 -text "Cut up . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy33 -text "ORDER, RAND"
		grid $fi.xx33 -row 33 -column 0 -sticky w
		grid $fi.yy33 -row 33 -column 2 -sticky w
		label $fi.xx34 -text "Cyclic . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy34 -text "ORDER, TABLES(Sort), JOIN(Concatenate), MATHS(Substitution)"
		grid $fi.xx34 -row 34 -column 0 -sticky w
		grid $fi.yy34 -row 34 -column 2 -sticky w
		label $fi.xx35 -text "Decreasing sequence . . . . . . . . . . ."
		label $fi.yy35 -text "CREATE"
		grid $fi.xx35 -row 35 -column 0 -sticky w
		grid $fi.yy35 -row 35 -column 2 -sticky w
		label $fi.xx36 -text "Decrement . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy36 -text "MATHS"
		grid $fi.xx36 -row 36 -column 0 -sticky w
		grid $fi.yy36 -row 36 -column 2 -sticky w
		label $fi.xx37 -text "Delete items (or keep only some items or rows) . ."
		label $fi.yy37 -text "EDIT IN,AT CURSOR,RAND,TABLES,CREATE2,JOIN(Order)"
		grid $fi.xx37 -row 37 -column 0 -sticky w
		grid $fi.yy37 -row 37 -column 2 -sticky w
		label $fi.xx38 -text "Density . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy38 -text "TIME"
		grid $fi.xx38 -row 38 -column 0 -sticky w
		grid $fi.yy38 -row 38 -column 2 -sticky w
		label $fi.xx39 -text "Duplicate (Repeat)"
		label $fi.yy39 -text "TABLES, COMBINE, SEQ"
		grid $fi.xx39 -row 39 -column 0 -sticky w
		grid $fi.yy39 -row 39 -column 2 -sticky w
		label $fi.xx40 -text "Duplicate with numeric indexing of duplicates"
		label $fi.yy40 -text "TABLES (Duplicate)"
		grid $fi.xx40 -row 40 -column 0 -sticky w
		grid $fi.yy40 -row 40 -column 2 -sticky w
		label $fi.xx41 -text "Duplicate Soundfiles . . . . . . . . . ."
		label $fi.yy41 -text "FROM SNDS"
		grid $fi.xx41 -row 41 -column 0 -sticky w
		grid $fi.yy41 -row 41 -column 2 -sticky w
		label $fi.xx42 -text "Duplicates: Remove . . . . . . . . . . . ."
		label $fi.yy42 -text "EDIT, PITCH"
		grid $fi.xx42 -row 42 -column 0 -sticky w
		grid $fi.yy42 -row 42 -column 2 -sticky w
		label $fi.xx43 -text "Duration, Fixed . . . . . . . . . . . . . . ."
		label $fi.yy43 -text "CREATE"
		grid $fi.xx43 -row 43 -column 0 -sticky w
		grid $fi.yy43 -row 43 -column 2 -sticky w
		label $fi.xx44 -text "Duration, Stretch . . . . . . . . . . . . . . ."
		label $fi.yy44 -text "JOIN, TIME, CREATE2"
		grid $fi.xx44 -row 44 -column 0 -sticky w
		grid $fi.yy44 -row 44 -column 2 -sticky w
		label $fi.xx45 -text "Edit, Convert list of times to list of edits"
		label $fi.yy45 -text "TABLES (Derive Edit Data)"
		grid $fi.xx45 -row 45 -column 0 -sticky w
		grid $fi.yy45 -row 45 -column 2 -sticky w
		label $fi.xx46 -text "Edit Cyclically (extract specific lines, replace same)"
		label $fi.yy46 -text "TABLES (Sort), JOIN (Concatenate)"
		grid $fi.xx46 -row 46 -column 0 -sticky w
		grid $fi.yy46 -row 46 -column 2 -sticky w
		label $fi.xx47 -text "Edit Globally, Edit at Zero Crossings . . ."
		label $fi.yy47 -text "TABLES, DERIVE(Other)"
		grid $fi.xx47 -row 47 -column 0 -sticky w
		grid $fi.yy47 -row 47 -column 2 -sticky w
		label $fi.xx48 -text "Engineering Notation . . . . . . . . ."
		label $fi.yy48 -text "FORMAT"
		grid $fi.xx48 -row 48 -column 0 -sticky w
		grid $fi.yy48 -row 48 -column 2 -sticky w
		label $fi.xx49 -text "Enter specific values . . . . . . . . ."
		label $fi.yy49 -text "CREATE"
		grid $fi.xx49 -row 49 -column 0 -sticky w
		grid $fi.yy49 -row 49 -column 2 -sticky w
		label $fi.xx50 -text "Envelope . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy50 -text "JOIN, TABLES"
		grid $fi.xx50 -row 50 -column 0 -sticky w
		grid $fi.yy50 -row 50 -column 2 -sticky w
		label $fi.xx51 -text "Equal intervals  . . . . . . . . . . . . ."
		label $fi.yy51 -text "CREATE"
		grid $fi.xx51 -row 51 -column 0 -sticky w
		grid $fi.yy51 -row 51 -column 2 -sticky w
		label $fi.xx52 -text "Equal values . . . . . . . . . . . . . . . . . ."
		label $fi.yy52 -text "CREATE"
		grid $fi.xx52 -row 52 -column 0 -sticky w
		grid $fi.yy52 -row 52 -column 2 -sticky w
		label $fi.xx53 -text "Exponential sequences, create . . . . . . . . ."
		label $fi.yy53 -text "CREATE (Unequal Steps), TABLE (Create Data)"
		grid $fi.xx53 -row 53 -column 0 -sticky w
		grid $fi.yy53 -row 53 -column 2 -sticky w
		label $fi.xx54 -text "Exponential step: convert to . . . . . . . "
		label $fi.yy54 -text "BRK (Modify Table Format), BRK(At Cursor)"
		grid $fi.xx54 -row 54 -column 0 -sticky w
		grid $fi.yy54 -row 54 -column 2 -sticky w
		label $fi.xx55 -text "Fibonacci Series . . . . . . .  . . ."
		label $fi.yy55 -text "CREATE (Unequal Steps)"
		grid $fi.xx55 -row 55 -column 0 -sticky w
		grid $fi.yy55 -row 55 -column 2 -sticky w
		label $fi.xx56 -text "Filenames (sort, change, duplicate etc.) . . ."
		label $fi.yy56 -text "TABLES"
		grid $fi.xx56 -row 56 -column 0 -sticky w
		grid $fi.yy56 -row 56 -column 2 -sticky w
		label $fi.xx57 -text "Filenames (change names of existing files) . ."
		label $fi.yy57 -text "JOIN"
		grid $fi.xx57 -row 57 -column 0 -sticky w
		grid $fi.yy57 -row 57 -column 2 -sticky w
		label $fi.xx58 -text "Filters (Varibank Data). . . . . . . ."
		label $fi.yy58 -text "TABLES"
		grid $fi.xx58 -row 58 -column 0 -sticky w
		grid $fi.yy58 -row 58 -column 2 -sticky w
		label $fi.xx59 -text "Find . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy59 -text "FIND"
		grid $fi.xx59 -row 59 -column 0 -sticky w
		grid $fi.yy59 -row 59 -column 2 -sticky w
		label $fi.xx60 -text "Find same position . . . . . . . . . . . ."
		label $fi.yy60 -text "FIND"
		grid $fi.xx60 -row 60 -column 0 -sticky w
		grid $fi.yy60 -row 60 -column 2 -sticky w
		label $fi.xx61 -text "Find same value . . . . . . . . . . . . . . ."
		label $fi.yy61 -text "FIND"
		grid $fi.xx61 -row 61 -column 0 -sticky w
		grid $fi.yy61 -row 61 -column 2 -sticky w
		label $fi.xx62 -text "Fixed Duration . . . . . . . . . . . . . . . ."
		label $fi.yy62 -text "CREATE"
		grid $fi.xx62 -row 62 -column 0 -sticky w
		grid $fi.yy62 -row 62 -column 2 -sticky w
		label $fi.xx63 -text "Format . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy63 -text "FORMAT, TABLES"
		grid $fi.xx63 -row 63 -column 0 -sticky w
		grid $fi.yy63 -row 63 -column 2 -sticky w
		label $fi.xx64 -text "Frequency, Frq Ratio . . . . . . . . . . . . . . . . . ."
		label $fi.yy64 -text "PITCH, INTERVAL"
		grid $fi.xx64 -row 64 -column 0 -sticky w
		grid $fi.yy64 -row 64 -column 2 -sticky w
		label $fi.xx65 -text "Frequency List, Play. . . . . . . . . . . . . . . . . ."
		label $fi.yy65 -text "PITCH, TABLES (Play Pitch Set)"
		grid $fi.xx65 -row 65 -column 0 -sticky w
		grid $fi.yy65 -row 65 -column 2 -sticky w
		label $fi.xx66 -text "Frequency to Phase Vocoder Channel . ."
		label $fi.yy66 -text "PITCH, TABLES (Play Pitch Set)"
		grid $fi.xx66 -row 66 -column 0 -sticky w
		grid $fi.yy66 -row 66 -column 2 -sticky w
		label $fi.xx67 -text "From Scratch . . . . . . . . . . . . . . . . . ."
		label $fi.yy67 -text "CREATE"
		grid $fi.xx67 -row 67 -column 0 -sticky w
		grid $fi.yy67 -row 67 -column 2 -sticky w
		label $fi.xx68 -text "Gate . . . . . . . . . . . . . . . . . . ."
		label $fi.yy68 -text "MATHS(Fix Limits),ENVEL,TABLES(Specific Data Types)"
		grid $fi.xx68 -row 68 -column 0 -sticky w
		grid $fi.yy68 -row 68 -column 2 -sticky w
		label $fi.xx69 -text "Global Editing . . . . . . . . . . . . . . . . . . ."
		label $fi.yy69 -text "TABLES"
		grid $fi.xx69 -row 69 -column 0 -sticky w
		grid $fi.yy69 -row 69 -column 2 -sticky w
		label $fi.xx70 -text "Golden Section . . . . . . . . . . . . . . . . . . ."
		label $fi.yy70 -text "MATHS (Algebra)"
		grid $fi.xx70 -row 70 -column 0 -sticky w
		grid $fi.yy70 -row 70 -column 2 -sticky w
		label $fi.xx71 -text "Greatest . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy71 -text "TEST"
		grid $fi.xx71 -row 71 -column 0 -sticky w
		grid $fi.yy71 -row 71 -column 2 -sticky w
		label $fi.xx72 -text "Grids with Gaps . . . . . . . . . . . . . . ."
		label $fi.yy72 -text "CREATE2"
		grid $fi.xx72 -row 72 -column 0 -sticky w
		grid $fi.yy72 -row 72 -column 2 -sticky w
		label $fi.xx73 -text "Group items together . . . . . . . . . ."
		label $fi.yy73 -text "ORDER, DERIVE, TABLES (Sort on Segments)"
		grid $fi.xx73 -row 73 -column 0 -sticky w
		grid $fi.yy73 -row 73 -column 2 -sticky w
		label $fi.xx74 -text "Groups summed . . . . . . . . . . . . . . . . ."
		label $fi.yy74 -text "MATHS"
		grid $fi.xx74 -row 74 -column 0 -sticky w
		grid $fi.yy74 -row 74 -column 2 -sticky w
		label $fi.xx75 -text "Harmonics . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy75 -text "DERIVE"
		grid $fi.xx75 -row 75 -column 0 -sticky w
		grid $fi.yy75 -row 75 -column 2 -sticky w
		label $fi.xx76 -text "Harmonic Fields . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy76 -text "TABLES (Partition Data, Harmonic Fields)"
		grid $fi.xx76 -row 76 -column 0 -sticky w
		grid $fi.yy76 -row 76 -column 2 -sticky w
		label $fi.xx77 -text "Harmony . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy77 -text "PITCH, INTERVAL, TABLES (Play Pitch Set)"
		grid $fi.xx77 -row 77 -column 0 -sticky w
		grid $fi.yy77 -row 77 -column 2 -sticky w
		label $fi.xx78 -text "Increasing sequence . . . . . . . . . . ."
		label $fi.yy78 -text "CREATE"
		grid $fi.xx78 -row 78 -column 0 -sticky w
		grid $fi.yy78 -row 78 -column 2 -sticky w
		label $fi.xx79 -text "Increment . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy79 -text "MATHS"
		grid $fi.xx79 -row 79 -column 0 -sticky w
		grid $fi.yy79 -row 79 -column 2 -sticky w
		label $fi.xx80 -text "Insert . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy80 -text "EDIT IN, AT CURSOR, COMBINE"
		grid $fi.xx80 -row 80 -column 0 -sticky w
		grid $fi.yy80 -row 80 -column 2 -sticky w
		label $fi.xx81 -text "Interleave Columns . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy81 -text "COMBINE (Insert vals in other column)"
		grid $fi.xx81 -row 81 -column 0 -sticky w
		grid $fi.yy81 -row 81 -column 2 -sticky w
		label $fi.xx82 -text "Interleave Files. . . . . . . . . . . . . . . . . . . ."
		label $fi.yy82 -text "JOIN (Concatenate Data), TABLES (Sort)"
		grid $fi.xx82 -row 82 -column 0 -sticky w
		grid $fi.yy82 -row 82 -column 2 -sticky w
		label $fi.xx83 -text "Intermediate values . . . . . . . . . . ."
		label $fi.yy83 -text "INTERVAL, BRK"
		grid $fi.xx83 -row 83 -column 0 -sticky w
		grid $fi.yy83 -row 83 -column 2 -sticky w
		label $fi.xx84 -text "Interpolate values in 2 columns. . . . . . . . . . ."
		label $fi.yy84 -text "COMBINE"
		grid $fi.xx84 -row 84 -column 0 -sticky w
		grid $fi.yy84 -row 84 -column 2 -sticky w
		label $fi.xx85 -text "Interval . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy85 -text "INTERVAL, SEQ, CREATE"
		grid $fi.xx85 -row 85 -column 0 -sticky w
		grid $fi.yy85 -row 85 -column 2 -sticky w
		label $fi.xx86 -text "Inverse Edit . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy86 -text "TABLES (Specific Data Types)"
		grid $fi.xx86 -row 86 -column 0 -sticky w
		grid $fi.yy86 -row 86 -column 2 -sticky w
		label $fi.xx87 -text "Invert . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy87 -text "PITCH, INTERVAL, BRK, ENVEL, SEQ"
		grid $fi.xx87 -row 87 -column 0 -sticky w
		grid $fi.yy87 -row 87 -column 2 -sticky w
		label $fi.xx88 -text "Invert Balance. . . . . . . . . . . . . . . . ."
		label $fi.yy88 -text "BRK (modify Values)"
		grid $fi.xx88 -row 88 -column 0 -sticky w
		grid $fi.yy88 -row 88 -column 2 -sticky w
		label $fi.xx89 -text "Join . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy89 -text "JOIN"
		grid $fi.xx89 -row 89 -column 0 -sticky w
		grid $fi.yy89 -row 89 -column 2 -sticky w
		label $fi.xx90 -text "Just Intonation . . . . . . . . . . . . . ."
		label $fi.yy90 -text "PITCH, CREATE2"
		grid $fi.xx90 -row 90 -column 0 -sticky w
		grid $fi.yy90 -row 90 -column 2 -sticky w
		label $fi.xx91 -text "Key . . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy91 -text "PITCH"
		grid $fi.xx91 -row 91 -column 0 -sticky w
		grid $fi.yy91 -row 91 -column 2 -sticky w
		label $fi.xx92 -text "Least . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy92 -text "TEST"
		grid $fi.xx92 -row 92 -column 0 -sticky w
		grid $fi.yy92 -row 92 -column 2 -sticky w
		label $fi.xx93 -text "Loudness . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy93 -text "GAIN"
		grid $fi.xx93 -row 93 -column 0 -sticky w
		grid $fi.yy93 -row 93 -column 2 -sticky w
		label $fi.xx94 -text "Major / Minor  . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy94 -text "PITCH"
		grid $fi.xx94 -row 94 -column 0 -sticky w
		grid $fi.yy94 -row 94 -column 2 -sticky w
		label $fi.xx95 -text "Mark . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy95 -text "EDIT IN, EDIT OUT"
		grid $fi.xx95 -row 95 -column 0 -sticky w
		grid $fi.yy95 -row 95 -column 2 -sticky w
		label $fi.xx96 -text "Maths operations . . . . . . . . . . . . . ."
		label $fi.yy96 -text "MATHS, COMBINE"
		grid $fi.xx96 -row 96 -column 0 -sticky w
		grid $fi.yy96 -row 96 -column 2 -sticky w
		label $fi.xx97 -text "Mean . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy97 -text "TEST, COMBINE (Maths)"
		grid $fi.xx97 -row 97 -column 0 -sticky w
		grid $fi.yy97 -row 97 -column 2 -sticky w
		label $fi.xx98 -text "Metronome Mark (Tempo) . . . . "
		label $fi.yy98 -text "TIME, SEQ, TEST"
		grid $fi.xx98 -row 98 -column 0 -sticky w
		grid $fi.yy98 -row 98 -column 2 -sticky w
		label $fi.xx99 -text "Midi . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy99 -text "PITCH, INTERVAL,TABLES (Play Pitch Set)"
		grid $fi.xx99 -row 99 -column 0 -sticky w
		grid $fi.yy99 -row 99 -column 2 -sticky w
		label $fi.xx100 -text "Minimum . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy100 -text "TEST"
		grid $fi.xx100 -row 100 -column 0 -sticky w
		grid $fi.yy100 -row 100 -column 2 -sticky w
		label $fi.xx101 -text "Minor / Major  . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy101 -text "PITCH"
		grid $fi.xx101 -row 101 -column 0 -sticky w
		grid $fi.yy101 -row 101 -column 2 -sticky w
		label $fi.xx102 -text "Mixfiles: durations of mixfiles on wkspace chosen list"
		label $fi.yy102 -text "FROM SNDS"
		grid $fi.xx102 -row 102 -column 0 -sticky w
		grid $fi.yy102 -row 102 -column 2 -sticky w
		label $fi.xx103 -text "Mixfiles: (extract specific lines, replace same)"
		label $fi.yy103 -text "TABLES (Sort), JOIN (Concatenate)"
		grid $fi.xx103 -row 103 -column 0 -sticky w
		grid $fi.yy103 -row 103 -column 2 -sticky w
		label $fi.xx104 -text "Mixfile: generate from sounds, times or patterns . ."
		label $fi.yy104 -text "TABLES"
		grid $fi.xx104 -row 104 -column 0 -sticky w
		grid $fi.yy104 -row 104 -column 2 -sticky w
		label $fi.xx105 -text "Mixfile: merge mixfiles . . . . . . . . . . . . ."
		label $fi.yy105 -text "JOIN"
		grid $fi.xx105 -row 105 -column 0 -sticky w
		grid $fi.yy105 -row 105 -column 2 -sticky w
		label $fi.xx106 -text "Mixfile: move timings to sound peaks (warp times)"
		label $fi.yy106 -text "TABLES, JOIN"
		grid $fi.xx106 -row 106 -column 0 -sticky w
		grid $fi.yy106 -row 106 -column 2 -sticky w
		label $fi.xx107 -text "Mixfile: offsets from reg pattern: retain on randomising order."
		label $fi.yy107 -text "TABLES, JOIN"
		grid $fi.xx107 -row 107 -column 0 -sticky w
		grid $fi.yy107 -row 107 -column 2 -sticky w
		label $fi.xx108 -text "Motif . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy108 -text "INTERVAL"
		grid $fi.xx108 -row 108 -column 0 -sticky w
		grid $fi.yy108 -row 108 -column 2 -sticky w
		label $fi.xx109 -text "Move individual values  . . . . . . . ."
		label $fi.yy109 -text "DERIVE"
		grid $fi.xx109 -row 109 -column 0 -sticky w
		grid $fi.yy109 -row 109 -column 2 -sticky w
		label $fi.xx110 -text "Names: Get Filenames from Workspace . . . . ."
		label $fi.yy110 -text "FROM SNDS"
		grid $fi.xx110 -row 110 -column 0 -sticky w
		grid $fi.yy110 -row 110 -column 2 -sticky w
		label $fi.xx111 -text "Names: Organise using name segments . . . . ."
		label $fi.yy111 -text "TABLES"
		grid $fi.xx111 -row 111 -column 0 -sticky w
		grid $fi.yy111 -row 111 -column 2 -sticky w
		label $fi.xx112 -text "Octave . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy112 -text "PITCH,DERIVE"
		grid $fi.xx112 -row 112 -column 0 -sticky w
		grid $fi.yy112 -row 112 -column 2 -sticky w
		label $fi.xx113 -text "Order . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy113 -text "ORDER, RAND, TEST"
		grid $fi.xx113 -row 113 -column 0 -sticky w
		grid $fi.yy113 -row 113 -column 2 -sticky w
		label $fi.xx114 -text "Ornaments, remove . . . . . . . . . . . . . . ."
		label $fi.yy114 -text "TABLES (PITCH: SUSTAINED TEMPERED)"
		grid $fi.xx114 -row 114 -column 0 -sticky w
		grid $fi.yy114 -row 114 -column 2 -sticky w
		label $fi.xx115 -text "Pan position values  (pan <-> texture). . . . . . . ."
		label $fi.yy115 -text "BRK (Modify Format), TABLES (Create Data)"
		grid $fi.xx115 -row 115 -column 0 -sticky w
		grid $fi.yy115 -row 115 -column 2 -sticky w
		label $fi.xx116 -text "Partition . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy116 -text "ORDER, TABLES"
		grid $fi.xx116 -row 116 -column 0 -sticky w
		grid $fi.yy116 -row 116 -column 2 -sticky w
		label $fi.xx117 -text "Pair up values (for editing) . . . . . . . . . . . ."
		label $fi.yy117 -text "TABLES (Specific Data Types)"
		grid $fi.xx117 -row 117 -column 0 -sticky w
		grid $fi.yy117 -row 117 -column 2 -sticky w
		label $fi.xx118 -text "Patterns . . . . . . . . . . . . . . . . . . . . . . . "
		label $fi.yy118 -text "CREATE2, TABLES, COMBINE, ORDER (Repattern)"
		grid $fi.xx118 -row 118 -column 0 -sticky w
		grid $fi.yy118 -row 118 -column 2 -sticky w
		label $fi.xx119 -text "Patterns for envelopes . . . . . . . ."
		label $fi.yy119 -text "CREATE2"
		grid $fi.xx119 -row 119 -column 0 -sticky w
		grid $fi.yy119 -row 119 -column 2 -sticky w
		label $fi.xx120 -text "Patterns for mixfiles . . . . . . . ."
		label $fi.yy120 -text "TABLES (Specific Data Types)"
		grid $fi.xx120 -row 120 -column 0 -sticky w
		grid $fi.yy120 -row 120 -column 2 -sticky w
		label $fi.xx121 -text "Peak expand . . . . . . . . . . . . . . . . . . ."
		label $fi.yy121 -text "DERIVE (Other)"
		grid $fi.xx121 -row 121 -column 0 -sticky w
		grid $fi.yy121 -row 121 -column 2 -sticky w
		label $fi.xx122 -text "Peak times extract . . . . . . . . ."
		label $fi.yy122 -text "ENV (Extract Peak Times)"
		grid $fi.xx122 -row 122 -column 0 -sticky w
		grid $fi.yy122 -row 122 -column 2 -sticky w
		label $fi.xx123 -text "Phase Vocoder Channel. . . . . . . . ."
		label $fi.yy123 -text "PITCH (Unit & Data Conversion)"
		grid $fi.xx123 -row 123 -column 0 -sticky w
		grid $fi.yy123 -row 123 -column 2 -sticky w
		label $fi.xx124 -text "Pitch . . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy124 -text "PITCH, TABLES (Play Pitch Set)"
		grid $fi.xx124 -row 124 -column 0 -sticky w
		grid $fi.yy124 -row 124 -column 2 -sticky w
		label $fi.xx125 -text "Pitch, Convert to other data . . . . . . . . . ."
		label $fi.yy125 -text "TABLES (Varibank Data, Envelope Pitch & Balance)"
		grid $fi.xx125 -row 125 -column 0 -sticky w
		grid $fi.yy125 -row 125 -column 2 -sticky w
		label $fi.xx126 -text "Pitch to Phase Vocoder Channel . . . . . ."
		label $fi.yy126 -text "TABLES (Varibank Data, Envelope Pitch & Balance)"
		grid $fi.xx126 -row 126 -column 0 -sticky w
		grid $fi.yy126 -row 126 -column 2 -sticky w
		label $fi.xx127 -text "Pitch, Play Pitch Set Data . . . . . . . . . ."
		label $fi.yy127 -text "PITCH, TABLES (Play Pitch Set)"
		grid $fi.xx127 -row 127 -column 0 -sticky w
		grid $fi.yy127 -row 127 -column 2 -sticky w
		label $fi.xx128 -text "Position . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy128 -text "COMBINE"
		grid $fi.xx128 -row 128 -column 0 -sticky w
		grid $fi.yy128 -row 128 -column 2 -sticky w
		label $fi.xx129 -text "Product . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy129 -text "TEST, MATHS"
		grid $fi.xx129 -row 129 -column 0 -sticky w
		grid $fi.yy129 -row 129 -column 2 -sticky w
		label $fi.xx130 -text "PVOC Channel. . . . . . . . ."
		label $fi.yy130 -text "PITCH (Unit & Data Conversion)"
		grid $fi.xx130 -row 130 -column 0 -sticky w
		grid $fi.yy130 -row 130 -column 2 -sticky w
		label $fi.xx131 -text "Quantise . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy131 -text "TIME, COMBINE"
		grid $fi.xx131 -row 131 -column 0 -sticky w
		grid $fi.yy131 -row 131 -column 2 -sticky w
		label $fi.xx132 -text "Quantised times . . . . . . . . . . . . . . ."
		label $fi.yy132 -text "CREATE"
		grid $fi.xx132 -row 132 -column 0 -sticky w
		grid $fi.yy132 -row 132 -column 2 -sticky w
		label $fi.xx133 -text "Quantised times with gaps . . . . ."
		label $fi.yy133 -text "CREATE 2"
		grid $fi.xx133 -row 133 -column 0 -sticky w
		grid $fi.yy133 -row 133 -column 2 -sticky w
		label $fi.xx134 -text "Random cut-up . . . . . . . . . . . . . . . . ."
		label $fi.yy134 -text "CREATE"
		grid $fi.xx134 -row 134 -column 0 -sticky w
		grid $fi.yy134 -row 134 -column 2 -sticky w
		label $fi.xx135 -text "Random deletion of table rows . . . . . . . . . . . ."
		label $fi.yy135 -text "TABLES (Delete or Keep)"
		grid $fi.xx135 -row 135 -column 0 -sticky w
		grid $fi.yy135 -row 135 -column 2 -sticky w
		label $fi.xx136 -text "Random integers . . . . . . . . . . . . . . ."
		label $fi.yy136 -text "CREATE"
		grid $fi.xx136 -row 136 -column 0 -sticky w
		grid $fi.yy136 -row 136 -column 2 -sticky w
		label $fi.xx137 -text "Random interval expansion . . . . . . ."
		label $fi.yy137 -text "RANDOM"
		grid $fi.xx137 -row 137 -column 0 -sticky w
		grid $fi.yy137 -row 137 -column 2 -sticky w
		label $fi.xx138 -text "Random selection of table rows or columns . . . . . . ."
		label $fi.yy138 -text "TABLES (Sort)"
		grid $fi.xx138 -row 138 -column 0 -sticky w
		grid $fi.yy138 -row 138 -column 2 -sticky w
		label $fi.xx139 -text "Random values . . . . . . . . . . . . . . . . ."
		label $fi.yy139 -text "CREATE, RAND, COMBINE"
		grid $fi.xx139 -row 139 -column 0 -sticky w
		grid $fi.yy139 -row 139 -column 2 -sticky w
		label $fi.xx140 -text "Random values, but on quantised times."
		label $fi.yy140 -text "CREATE2"
		grid $fi.xx140 -row 140 -column 0 -sticky w
		grid $fi.yy140 -row 140 -column 2 -sticky w
		label $fi.xx141 -text "Randomise . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy141 -text "RAND, COMBINE"
		grid $fi.xx141 -row 141 -column 0 -sticky w
		grid $fi.yy141 -row 141 -column 2 -sticky w
		label $fi.xx142 -text "Randomise Order . . . . . . . . . . . . . . ."
		label $fi.yy142 -text "RAND"
		grid $fi.xx142 -row 142 -column 0 -sticky w
		grid $fi.yy142 -row 142 -column 2 -sticky w
		label $fi.xx143 -text "Range . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy143 -text "MATHS, TABLE"
		grid $fi.xx143 -row 143 -column 0 -sticky w
		grid $fi.yy143 -row 143 -column 2 -sticky w
		label $fi.xx144 -text "Rank . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy144 -text "PITCH, ORDER"
		grid $fi.xx144 -row 144 -column 0 -sticky w
		grid $fi.yy144 -row 144 -column 2 -sticky w
		label $fi.xx145 -text "Relationships between values . ."
		label $fi.yy145 -text "MATHS"
		grid $fi.xx145 -row 145 -column 0 -sticky w
		grid $fi.yy145 -row 145 -column 2 -sticky w
		label $fi.xx146 -text "Remove items (or keep only some items or rows) . . . . "
		label $fi.yy146 -text "EDIT IN,AT CURSOR,RAND,TABLES,CREATE2,JOIN(Order)"
		grid $fi.xx146 -row 146 -column 0 -sticky w
		grid $fi.yy146 -row 146 -column 2 -sticky w
		label $fi.xx147 -text "Reorder . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy147 -text "ORDER, RAND"
		grid $fi.xx147 -row 147 -column 0 -sticky w
		grid $fi.yy147 -row 147 -column 2 -sticky w
		label $fi.xx148 -text "Repeat (Duplicate) \\ Avoid Repeats . . . . . . . ."
		label $fi.yy148 -text "SEQ, TABLES, COMBINE \\ PITCH"
		grid $fi.xx148 -row 148 -column 0 -sticky w
		grid $fi.yy148 -row 148 -column 2 -sticky w
		label $fi.xx149 -text "Replace . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy149 -text "EDIT IN, AT CURSOR"
		grid $fi.xx149 -row 149 -column 0 -sticky w
		grid $fi.yy149 -row 149 -column 2 -sticky w
		label $fi.xx150 -text "Reverse . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy150 -text "ORDER, BRK, SEQ, INTERVAL, TABLES"
		grid $fi.xx150 -row 150 -column 0 -sticky w
		grid $fi.yy150 -row 150 -column 2 -sticky w
		label $fi.xx151 -text "Rhythm . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy151 -text "CREATE"
		grid $fi.xx151 -row 151 -column 0 -sticky w
		grid $fi.yy151 -row 151 -column 2 -sticky w
		label $fi.xx152 -text "Rhythm from Envelope . . . . . . . . ."
		label $fi.yy152 -text "ENV (Extract Peak Times)"
		grid $fi.xx152 -row 152 -column 0 -sticky w
		grid $fi.yy152 -row 152 -column 2 -sticky w
		label $fi.xx153 -text "Rotate . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy153 -text "INTERVAL"
		grid $fi.xx153 -row 153 -column 0 -sticky w
		grid $fi.yy153 -row 153 -column 2 -sticky w
		label $fi.xx154 -text "Samples to Time . . . . . . . . . . . . . . ."
		label $fi.yy154 -text "TIME"
		grid $fi.xx154 -row 154 -column 0 -sticky w
		grid $fi.yy154 -row 154 -column 2 -sticky w
		label $fi.xx155 -text "Scatter . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy155 -text "RAND"
		grid $fi.xx155 -row 155 -column 0 -sticky w
		grid $fi.yy155 -row 155 -column 2 -sticky w
		label $fi.xx156 -text "Scatter over quantised times . ."
		label $fi.yy156 -text "CREATE2"
		grid $fi.xx156 -row 156 -column 0 -sticky w
		grid $fi.yy156 -row 156 -column 2 -sticky w
		label $fi.xx157 -text "Select specific values . . . . . . . ."
		label $fi.yy157 -text "CREATE"
		grid $fi.xx157 -row 157 -column 0 -sticky w
		grid $fi.yy157 -row 157 -column 2 -sticky w
		label $fi.xx158 -text "Select on string in N (from specific col) . . . . ."
		label $fi.yy158 -text "TABLES"
		grid $fi.xx158 -row 158 -column 0 -sticky w
		grid $fi.yy158 -row 158 -column 2 -sticky w
		label $fi.xx159 -text "Segments of Names . . . . . . . ."
		label $fi.yy159 -text "TABLES"
		grid $fi.xx159 -row 159 -column 0 -sticky w
		grid $fi.yy159 -row 159 -column 2 -sticky w
		label $fi.xx160 -text "Semitones . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy160 -text "PITCH, INTERVAL"
		grid $fi.xx160 -row 160 -column 0 -sticky w
		grid $fi.yy160 -row 160 -column 2 -sticky w
		label $fi.xx161 -text "Sequence of Notes . . . . . . . . . . . . . . . . . .  . ."
		label $fi.yy161 -text "SEQ, JOIN"
		grid $fi.xx161 -row 161 -column 0 -sticky w
		grid $fi.yy161 -row 161 -column 2 -sticky w
		label $fi.xx162 -text "Sequence of Notes using several sounds.. ."
		label $fi.yy162 -text "SEQ, JOIN ('Free Text' Mode),TABLES (Frq Data <-> Midi)"
		grid $fi.xx162 -row 162 -column 0 -sticky w
		grid $fi.yy162 -row 162 -column 2 -sticky w
		label $fi.xx163 -text "Sequence of Times . . . . . . . . . . . . . . . . . .  . ."
		label $fi.yy163 -text "CREATE"
		grid $fi.xx163 -row 163 -column 0 -sticky w
		grid $fi.yy163 -row 163 -column 2 -sticky w
		label $fi.xx164 -text "Set boundaries . . . . . . . . . . . . . . . ."
		label $fi.yy164 -text "MATHS"
		grid $fi.xx164 -row 164 -column 0 -sticky w
		grid $fi.yy164 -row 164 -column 2 -sticky w
		label $fi.xx165 -text "Set limits . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy165 -text "MATHS"
		grid $fi.xx165 -row 165 -column 0 -sticky w
		grid $fi.yy165 -row 165 -column 2 -sticky w
		label $fi.xx166 -text "Sinusoidal sequence . . . .  . . . . . . . . ."
		label $fi.yy166 -text "CREATE"
		grid $fi.xx166 -row 166 -column 0 -sticky w
		grid $fi.yy166 -row 166 -column 2 -sticky w
		label $fi.xx167 -text "Size . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy167 -text "EDIT IN, EDIT OUT"
		grid $fi.xx167 -row 167 -column 0 -sticky w
		grid $fi.yy167 -row 167 -column 2 -sticky w
		label $fi.xx168 -text "Slope . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy168 -text "MATHS"
		grid $fi.xx168 -row 168 -column 0 -sticky w
		grid $fi.yy168 -row 168 -column 2 -sticky w
		label $fi.xx169 -text "Smooth Pitch Values . . . . . . . . . . . . . ."
		label $fi.yy169 -text "TABLE"
		grid $fi.xx169 -row 169 -column 0 -sticky w
		grid $fi.yy169 -row 169 -column 2 -sticky w
		label $fi.xx170 -text "Sort . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy170 -text "TABLES, JOIN, ORDER, TEST"
		grid $fi.xx170 -row 170 -column 0 -sticky w
		grid $fi.yy170 -row 170 -column 2 -sticky w
		label $fi.xx171 -text "Soundfiles in list : do they exist ? . . . . . . . ."
		label $fi.yy171 -text "FROM SNDS"
		grid $fi.xx171 -row 171 -column 0 -sticky w
		grid $fi.yy171 -row 171 -column 2 -sticky w
		label $fi.xx172 -text "Soundfiles in list : Duplicates ? . . . . . . . ."
		label $fi.yy172 -text "FROM SNDS"
		grid $fi.xx172 -row 172 -column 0 -sticky w
		grid $fi.yy172 -row 172 -column 2 -sticky w
		label $fi.xx173 -text "Soundfiles in list : Pair up srcs & transformations . ."
		label $fi.yy173 -text "FROM SNDS"
		grid $fi.xx173 -row 173 -column 0 -sticky w
		grid $fi.yy173 -row 173 -column 2 -sticky w
		label $fi.xx174 -text "Space position values (pan <-> texture). . . . . . . ."
		label $fi.yy174 -text "BRK"
		grid $fi.xx174 -row 174 -column 0 -sticky w
		grid $fi.yy174 -row 174 -column 2 -sticky w
		label $fi.xx175 -text "'Sound View' times to table. . . . . . . ."
		label $fi.yy175 -text "TABLES(Create)"
		grid $fi.xx175 -row 175 -column 0 -sticky w
		grid $fi.yy175 -row 175 -column 2 -sticky w
		label $fi.xx176 -text "Span values . . . . . . . . . . . . . . . . . . ."
		label $fi.yy176 -text "DERIVE"
		grid $fi.xx176 -row 176 -column 0 -sticky w
		grid $fi.yy176 -row 176 -column 2 -sticky w
		label $fi.xx177 -text "Specific Duration Sequence . . . ."
		label $fi.yy177 -text "CREATE"
		grid $fi.xx177 -row 177 -column 0 -sticky w
		grid $fi.yy177 -row 177 -column 2 -sticky w
		label $fi.xx178 -text "Staccato . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy178 -text "TABLES(Frq Data <-> Midi Data),ENV(Modify Vals)"
		grid $fi.xx178 -row 178 -column 0 -sticky w
		grid $fi.yy178 -row 178 -column 2 -sticky w
		label $fi.xx179 -text "Stack . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy179 -text "MATHS"
		grid $fi.xx179 -row 179 -column 0 -sticky w
		grid $fi.yy179 -row 179 -column 2 -sticky w
		label $fi.xx180 -text "Staff Notation . . . . . . . . . . . . . . . . ."
		label $fi.yy180 -text "CREATE"
		grid $fi.xx180 -row 180 -column 0 -sticky w
		grid $fi.yy180 -row 180 -column 2 -sticky w
		label $fi.xx181 -text "Statistics . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy181 -text "TEST"
		grid $fi.xx181 -row 181 -column 0 -sticky w
		grid $fi.yy181 -row 181 -column 2 -sticky w
		label $fi.xx182 -text "Step (between values) . . . . . . ."
		label $fi.yy182 -text "INTERVAL, CREATE"
		grid $fi.xx182 -row 182 -column 0 -sticky w
		grid $fi.yy182 -row 182 -column 2 -sticky w
		label $fi.xx183 -text "Stretch or Warp Time . . . . . . ."
		label $fi.yy183 -text "JOIN, TIME, CREATE2"
		grid $fi.xx183 -row 183 -column 0 -sticky w
		grid $fi.yy183 -row 183 -column 2 -sticky w
		label $fi.xx184 -text "Substitute (on basis of Segments of Names)"
		label $fi.yy184 -text "TABLES"
		grid $fi.xx184 -row 184 -column 0 -sticky w
		grid $fi.yy184 -row 184 -column 2 -sticky w
		label $fi.xx185 -text "Substitute one column for another"
		label $fi.yy185 -text "TABLES (Swap), COMBINE (Insert Vals in Other Column)"
		grid $fi.xx185 -row 185 -column 0 -sticky w
		grid $fi.yy185 -row 185 -column 2 -sticky w
		label $fi.xx186 -text "Sum . . . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy186 -text "TEST, MATHS"
		grid $fi.xx186 -row 186 -column 0 -sticky w
		grid $fi.yy186 -row 186 -column 2 -sticky w
		label $fi.xx187 -text "Swap . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy187 -text "TABLES"
		grid $fi.xx187 -row 187 -column 0 -sticky w
		grid $fi.yy187 -row 187 -column 2 -sticky w
		label $fi.xx188 -text "Tap out times on keyboard  . . . . . . . ."
		label $fi.yy188 -text "CREATE"
		grid $fi.xx188 -row 188 -column 0 -sticky w
		grid $fi.yy188 -row 188 -column 2 -sticky w
		label $fi.xx189 -text "Temper . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy189 -text "PITCH"
		grid $fi.xx189 -row 189 -column 0 -sticky w
		grid $fi.yy189 -row 189 -column 2 -sticky w
		label $fi.xx190 -text "Tempo . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy190 -text "TIME, SEQ, TEST"
		grid $fi.xx190 -row 190 -column 0 -sticky w
		grid $fi.yy190 -row 190 -column 2 -sticky w
		label $fi.xx191 -text "Test Regularity of Rising Sequence . ."
		label $fi.yy191 -text "TEST"
		grid $fi.xx191 -row 191 -column 0 -sticky w
		grid $fi.yy191 -row 191 -column 2 -sticky w
		label $fi.xx192 -text "Text: Add to entries . . . . . . . . . . . . . . ."
		label $fi.yy192 -text "FORMAT"
		grid $fi.xx192 -row 192 -column 0 -sticky w
		grid $fi.yy192 -row 192 -column 2 -sticky w
		label $fi.xx193 -text "Text: Remove (part of) from entries . . . ."
		label $fi.yy193 -text "FORMAT"
		grid $fi.xx193 -row 193 -column 0 -sticky w
		grid $fi.yy193 -row 193 -column 2 -sticky w
		label $fi.xx194 -text "Text: Untangle from numbers . . . . . . . . ."
		label $fi.yy194 -text "FORMAT"
		grid $fi.xx194 -row 194 -column 0 -sticky w
		grid $fi.yy194 -row 194 -column 2 -sticky w
		label $fi.xx195 -text "Thresholds (find) . . . . . . . . . . . . ."
		label $fi.yy195 -text "BRK"
		grid $fi.xx195 -row 195 -column 0 -sticky w
		grid $fi.yy195 -row 195 -column 2 -sticky w
		label $fi.xx196 -text "Time Entry by tapping . . . . . . . . . . . . ."
		label $fi.yy196 -text "CREATE"
		grid $fi.xx196 -row 196 -column 0 -sticky w
		grid $fi.yy196 -row 196 -column 2 -sticky w
		label $fi.xx197 -text "Time to Beats . . . . . . . . . . . . . . . . ."
		label $fi.yy197 -text "TIME"
		grid $fi.xx197 -row 197 -column 0 -sticky w
		grid $fi.yy197 -row 197 -column 2 -sticky w
		label $fi.xx198 -text "Time to Samples . . . . . . . . . . . . . . ."
		label $fi.yy198 -text "TIME"
		grid $fi.xx198 -row 198 -column 0 -sticky w
		grid $fi.yy198 -row 198 -column 2 -sticky w
		label $fi.xx199 -text "Time Stretching or Warping  . . . . . ."
		label $fi.yy199 -text "JOIN, TIME, CREATE2"
		grid $fi.xx199 -row 199 -column 0 -sticky w
		grid $fi.yy199 -row 199 -column 2 -sticky w
		label $fi.xx200 -text "Tonal Pitch Set Operations . . . . . . . . ."
		label $fi.yy200 -text "PITCH"
		grid $fi.xx200 -row 200 -column 0 -sticky w
		grid $fi.yy200 -row 200 -column 2 -sticky w
		label $fi.xx201 -text "Transfer . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy201 -text "AT CURSOR"
		grid $fi.xx201 -row 201 -column 0 -sticky w
		grid $fi.yy201 -row 201 -column 2 -sticky w
		label $fi.xx202 -text "Transformed Sounds in list : Pair up with Srcs in list . ."
		label $fi.yy202 -text "FROM SNDS"
		grid $fi.xx202 -row 202 -column 0 -sticky w
		grid $fi.yy202 -row 202 -column 2 -sticky w
		label $fi.xx203 -text "Trim . . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy203 -text "EDIT IN, EDIT OUT"
		grid $fi.xx203 -row 203 -column 0 -sticky w
		grid $fi.yy203 -row 203 -column 2 -sticky w
		label $fi.xx204 -text "Transposition . . . . . . . . . . . . . . . . ."
		label $fi.yy204 -text "PITCH, SEQ, TABLES(Varibank Filters)"
		grid $fi.xx204 -row 204 -column 0 -sticky w
		grid $fi.yy204 -row 204 -column 2 -sticky w
		label $fi.xx205 -text "Unite . . . . . . . . . . . . . . . . . . . . . . . ."
		label $fi.yy205 -text "JOIN"
		grid $fi.xx205 -row 205 -column 0 -sticky w
		grid $fi.yy205 -row 205 -column 2 -sticky w
		label $fi.xx206 -text "Units convert . . . . . . . . . . . . . . . ."
		label $fi.yy206 -text "GAIN, PITCH, INTERVAL, TIME"
		grid $fi.xx206 -row 206 -column 0 -sticky w
		grid $fi.yy206 -row 206 -column 2 -sticky w
		label $fi.xx207 -text "Variance from Regular Increasing Sequence"
		label $fi.yy207 -text "TEST"
		grid $fi.xx207 -row 207 -column 0 -sticky w
		grid $fi.yy207 -row 207 -column 2 -sticky w
		label $fi.xx208 -text "Varibank Filter Data  . . . . . . . . . ."
		label $fi.yy208 -text "TABLES, (Tables)AT CURSOR"
		grid $fi.xx208 -row 208 -column 0 -sticky w
		grid $fi.yy208 -row 208 -column 2 -sticky w
		label $fi.xx209 -text "Vectored Batchfiles . . . . . . . . . ."
		label $fi.yy209 -text "JOIN"
		grid $fi.xx209 -row 209 -column 0 -sticky w
		grid $fi.yy209 -row 209 -column 2 -sticky w
		label $fi.xx210 -text "Warp Data or Time . . . . . . . . . ."
		label $fi.yy210 -text "JOIN, CREATE2"
		grid $fi.xx210 -row 210 -column 0 -sticky w
		grid $fi.yy210 -row 210 -column 2 -sticky w
		label $fi.xx211 -text "Workspace Chosen Files . . . . . . . . . ."
		label $fi.yy211 -text "FROM SNDS"
		grid $fi.xx211 -row 211 -column 0 -sticky w
		grid $fi.yy211 -row 211 -column 2 -sticky w
		label $fi.xx212 -text "Zero crossing edits . . . . . . . . . ."
		label $fi.yy212 -text "TABLES (Specific Data Types)"
		grid $fi.xx212 -row 212 -column 0 -sticky w
		grid $fi.yy212 -row 212 -column 2 -sticky w
		label $fi.xx213 -text "Zigzagging patterns . . . . . . . . . ."
		label $fi.yy213 -text "CREATE (Random sets and cuts, Integer)"
		grid $fi.xx213 -row 213 -column 0 -sticky w
		grid $fi.yy213 -row 213 -column 2 -sticky w

		pack $f.0 $f.1 -side top -fill both
		pack $f.1a -side top -fill both -expand true
		pack $f.2 -side top -fill both

		set view_offset 4
		bind $f <KeyPress> {
			if [string match {[a-zA-Z]} %A] {
				set q [string toupper %A]
				switch -- $q {
					A { set k [expr double(2 - $view_offset) / double(213)]}
					B { set k [expr double(9 - $view_offset) / double(213)]}					
					C { set k [expr double(18 - $view_offset) / double(213)]}					
					D { set k [expr double(36 - $view_offset) / double(213)]}					
					E { set k [expr double(45 - $view_offset) / double(213)]}					
					F { set k [expr double(54 - $view_offset) / double(213)]}					
					G { set k [expr double(67 - $view_offset) / double(213)]}					
					H { set k [expr double(74 - $view_offset) / double(213)]}					
					I { set k [expr double(77 - $view_offset) / double(213)]}					
					J { set k [expr double(88 - $view_offset) / double(213)]}					
					K { set k [expr double(90 - $view_offset) / double(213)]}					
					L { set k [expr double(91 - $view_offset) / double(213)]}					
					M { set k [expr double(92 - $view_offset) / double(213)]}					
					N { set k [expr double(108 - $view_offset) / double(213)]}					
					O { set k [expr double(110 - $view_offset) / double(213)]}					
					P { set k [expr double(113 - $view_offset) / double(213)]}					
					Q { set k [expr double(129 - $view_offset) / double(213)]}					
					R { set k [expr double(132 - $view_offset) / double(213)]}					
					S { set k [expr double(151 - $view_offset) / double(213)]}					
					T { set k [expr double(185 - $view_offset) / double(213)]}					
					U { set k [expr double(204 - $view_offset) / double(213)]}					
					V { set k [expr double(206 - $view_offset) / double(213)]}					
					W { set k [expr double(210 - $view_offset) / double(213)]}					
					X -
					Y -
					Z { set k [expr double(213 - $view_offset) / double(213)]}				
				}
				.tew.2.c.canvas yview moveto $k 
			}
		}
		bind $f <Return> {set pr_tew 0}
		bind $f <Escape> {set pr_tew 0}
		bind $f <Key-space> {set pr_tew 0}
		wm resizable $f 1 1
	}
	set pr_tew 0
	My_Grab 1 $f pr_tew
	tkwait variable pr_tew
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Add text extension to vals in col

proc ExtCol {typ} {
	global colpar outlines tedit_message last_oc last_cr record_temacro temacro temacrop threshold evv
	global inlines coltype rcolno col_ungapd_numeric orig_incolget tround tot_outlines tabed
	global tot_inlines lmo insitu orig_inlines

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {	   	;#	If there's an input TABLE
		SetInout 1												;#	Reset default to act on input TABLE
	}
	HaltCursCop
	set lmo EC
	lappend lmo $col_ungapd_numeric	0									;#	 Remember last action.
	set tround 0

	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		if {$typ == "e"} {
			ForceVal $tabed.message.e "No extension entered (at N)"
		} elseif {$typ == "d"} {
			ForceVal $tabed.message.e "No directory name entered (at N)"
		} else {
			ForceVal $tabed.message.e "No prefix entered (at N)"
		}
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$typ == "d"} {
		set dirname [CheckDirectoryName $colpar "directory name" 1 1]
		if {[string length $dirname] <= 0} {
		 	return
		}
	}
	set n "normal"
	set d "disabled"
	set tb $tabed.bot
	if {![file exists $evv(COLFILE1)]} {
		ForceVal $tabed.message.e "No column selected"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$insitu} {									;# establish which col to output to on
		set fnam $evv(COLFILE1)
		set ll $tb.icframe.l.list
		set lcnt "inlines"
		foreach zz [$ll get 0 end] {
			lappend tmpst $zz
		}
	} else {
		set fnam $evv(COLFILE2)
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
		set last_oc [$tb.ocframe.l.list get 0 end]
		set last_cr $col_ungapd_numeric						 	;#	In normal situation.
		DisableOutputColumnOptions 
	}
	$ll delete 0 end

	if {$typ == "p"} {
		if {$insitu} {
			foreach zz $tmpst {
				$ll insert end $colpar$zz
			}
		} else {
			foreach zz [$tb.icframe.l.list get 0 end] {
				$ll insert end $colpar$zz
			}
		}
	} elseif {$typ == "d"} {
		if {$insitu} {
			foreach zz $tmpst {
				$ll insert end [file join $dirname $zz]
			}
		} else {
			foreach zz [$tb.icframe.l.list get 0 end] {
				$ll insert end [file join $dirname $zz]
			}
		}
	} else {
		if {$insitu} {
			foreach zz $tmpst {
				$ll insert end $zz$colpar
			}
		} else {
			foreach zz [$tb.icframe.l.list get 0 end] {
				$ll insert end $zz$colpar
			}
		}
	}
	set outlines $inlines
	ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	if [catch {open $fnam "w"} fileoc] {
		ForceVal $tabed.message.e  "Cannot open temporary file $fnam to write new column data"
	 	$tabed.message.e config -bg $evv(EMPH)
		$ll delete 0 end		;#	Clear existing listing
		set $lcnt ""
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
	} else {
		set $lcnt 0
		foreach line [$ll get 0 end] {
			puts $fileoc $line
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		close $fileoc						;#	Write data to file
  		if {!$insitu} {
			$tb.kcframe.oky config -state $n
			$tb.kcframe.okz config -state $n
			if {[info exists tot_inlines] && ($tot_inlines > 0)} {
				if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
					SetKCState "o"
					ForceVal $tb.kcframe.e $rcolno
				} elseif {$outlines == $tot_inlines} {
					set coltype "i"
					$tb.kcframe.oki config -state $n
					$tb.kcframe.oko config -state $d
					$tb.kcframe.okr config -state $n
					set rcolno $orig_incolget
					ForceVal $tb.kcframe.e $rcolno
					$tb.kcframe.e config -state $n -fg [option get . foreground {}]
				} else {
					SetKCState "k"
				}
			} elseif {[info exists tot_outlines] && ($tot_outlines > 0)} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
			$tb.kcframe.okk config -state $n
			$tb.kcframe.ok config -state $n
		}
	}
}

#------ Alter state of Envelope Menubutton on Table Editor

proc SetEnvState {typ} {
	global col_infnam pa tabed evv
	if {$typ && [IsANormdBrkfile $pa($col_infnam,$evv(FTYP))]} {
		$tabed.topa.env config -state normal -text "Envel"
	} else {
		$tabed.topa.env config -state disabled -text ""
	}
}

#------ Sort table rows on basis of a column

proc RowSort {} {
	global tabedit_ns tabedit_bind2 tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		ForceVal $tabed.message.e "No column specified."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {($colpar < 1) || ($colpar > $incols)} {
		ForceVal $tabed.message.e "This column does not exist."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set llcnt 0
	foreach line [$it get 0 end] {
		set c_cnt 0
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				incr c_cnt
				if {$c_cnt == $colpar} {
					if {![IsNumeric $item]} {
						ForceVal $tabed.message.e "Non-numeric value ($item) in the column. Cannot use it for sorting."
					 	$tabed.message.e config -bg $evv(EMPH)
						return
					}
					set dat [list $llcnt $item]
					lappend datlst $dat
				}
			}
		}
		if {$c_cnt < $colpar} {
			ForceVal $tabed.message.e "Some lines do not have enough columns to do this sort."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		incr llcnt
   	}
	if {![info exists datlst]} {
		ForceVal $tabed.message.e "No column data found."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}

	set lmo "RS"
	lappend lmo $col_ungapd_numeric 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set len [llength $datlst]
	incr len -1
	set i 0
	while {$i < $len} {
		set j $i
		incr j
		while {$j <= $len} {
			set zn [lindex $datlst $i]
			set zm [lindex $datlst $j]
			if {[lindex $zm 1] < [lindex $zn 1]} {
				set datlst [lreplace $datlst $i $i $zm] 
				set datlst [lreplace $datlst $j $j $zn] 
			}
			incr j
		}
		incr i
	}
	$ot delete 0 end
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach itm $datlst {
		set line [$it get [lindex $itm 0]]
		$ot insert end $line
		puts $fileot $line
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
}

#--- Delete marks

proc DelColMarks {typ} {
	global insitu last_oc last_cr ino orig_inlines tot_inlines tot_outlines outlines col_ungapd_numeric lmo evv
	global record_temacro temacro temacrop threshold colpar tabed

	set e $tabed.message.e
 	set ic $tabed.bot.icframe.l.list
 	set oc $tabed.bot.ocframe.l.list

	HaltCursCop

	ForceVal $e ""
	$e config -bg [option get . background {}]

	set itoo 0
	switch -- $typ {
		"i" {
			set inl $ic
			if {$insitu} {
				set outl $ic			
				set fnam $evv(COLFILE1)	
			} else {
				set outl $oc			
				set fnam $evv(COLFILE2)
				set last_oc [$oc get 0 end]
				set last_cr $col_ungapd_numeric
				set itoo 1
			}
		}
		"o"	{
			set inl $oc
			set outl $oc
			set fnam $evv(COLFILE2)
			set last_oc [$oc get 0 end]
			set last_cr $col_ungapd_numeric
		}
	}
	if [catch {open $fnam "w"} fId] {
		ForceVal $e "Cannot open temporary file $fnam to write new values."
	 	$e config -bg $evv(EMPH)
		return
	}	
	set lmo "DM"
	lappend lmo $col_ungapd_numeric $typ
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	foreach item [$inl get 0 end] {
		if [string match {\**} $item] {
			set item [string range $item 1 end]
		}
		lappend tmp $item
	}
	$outl delete 0 end
	foreach item $tmp {
		$outl insert end $item
		puts $fId $item
	}
	close $fId
	if {$itoo} { 			;#	Data copied into outcol
		if {$ino} {
			if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
				SetKCState "o"
			} elseif {$outlines == $tot_inlines} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		} else {
			if {[info exists tot_outlines] && ($tot_outlines > 0) && ($outlines == $tot_outlines)} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		}
	}
	set col_ungapd_numeric 1
}

#--- Creating new col by copying vals from other

proc CursCop {val typ} {
	global inlines outlines col_ungapd_numeric last_oc last_cr z1 z2 unset tabedit_bind3 insitu lmo cctyp tabed evv

	set e $tabed.message.e
 	set ic $tabed.bot.icframe.l.list
 	set oc $tabed.bot.ocframe.l.list

	HaltCursCop
	set cctyp $typ

	ForceVal $e ""
	$e config -bg [option get . background {}]

	if {$typ == "T"} {
		if {([string length $inlines] > 0) && ($inlines > 0)} {
			set i 0
			foreach item [$ic get 0] {
				if {![IsNumeric $item]} {
					ForceVal $e "In Column contains the non-numeric value $item."
				 	$e config -bg $evv(EMPH)
					return
				}
				if {$i} {
					if {$item <= $lasti} {
						ForceVal $e "In Column is not in ascending order."
					 	$e config -bg $evv(EMPH)
						return
					}
				} else {
					set lasti $item
				}
				incr i
			}
		}
		if {([string length $outlines] > 0) && ($outlines > 0)} {
			set i 0
			foreach item [$oc get 0] {
				if {![IsNumeric $item]} {
					ForceVal $e "Out Column contains the non-numeric value $item."
				 	$e config -bg $evv(EMPH)
					return
				}
				if {$i} {
					if {$item <= $lasti} {
						ForceVal $e "Out Column is not in ascending order."
					 	$e config -bg $evv(EMPH)
						return
					}
				} else {
					set lasti $item
				}
				incr i
			}
		}
	}			
	if {$typ == "t" || $typ == "T"} {
		set insitu 0
		LiteCol "o"
	}
	set itoo 0
	switch -- $val {
		"i"	{
			set z1 $ic	;#	initial list in Incol, and its tempfile
			set z2 $oc	;#	other list in Outcol
			if {[$z1 index end] <= 0} {
				ForceVal $e "No values in this column."
			 	$e config -bg $evv(EMPH)
				return
			}
			set last_oc [$oc get 0 end]
			set last_cr $col_ungapd_numeric 		;# ????
			if {$typ != "t" && $typ != "T"} {
				set outlines 0
				ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
				set insitu 1
				LiteCol "i"
			}
		}
		"o"	{
			set z1 $oc	;#	initial list in Outcol, and its tempfile
			set z2 $ic	;#	other list in Incol
			if {[$z1 index end] <= 0} {
				ForceVal $e "No values in this column."
			 	$e config -bg $evv(EMPH)
				return
			}
			if {$typ != "t" && $typ != "T"} {
				set inlines 0
				ForceVal $tabed.bot.icframe.dummy.cnt $inlines
			}
			set insitu 0
			LiteCol "o"
		}
	}
	set lmo "Z"
	lappend lmo $col_ungapd_numeric $val $typ
	if {$typ != "t" && $typ != "T"} {
		$z2 delete 0 end
	}
	$tabed.bot.icframe.zog.sw config -state disabled
	bind $z1 <ButtonRelease-1> "Movcol $typ"
	set tabedit_bind3 [bind $z1 <ButtonRelease-1>]
}

proc HaltCursCop {} {
	global ino outlines orig_inlines tot_inlines tot_outlines z1 z2 unset tabedit_bind3 lmo col_ungapd_numeric cctyp evv
	global tabed

	if {$lmo != "Z"} {
		return
	}
	set e $tabed.message.e
 	set ic $tabed.bot.icframe.l.list
 	set oc $tabed.bot.ocframe.l.list

	bind $z1 <ButtonRelease-1> {}
	ForceVal $e ""
	$e config -bg [option get . background {}]
	set itoo 0

	if {$z2 == $ic} { 			;#	if val copied to out
		set fnam $evv(COLFILE1)
	} else {
		set fnam $evv(COLFILE2)
		if {$ino} {
			if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
				SetKCState "o"
			} elseif {$outlines == $tot_inlines} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		} else {
			if {[info exists tot_outlines] && ($tot_outlines > 0) && ($outlines == $tot_outlines)} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		}
	}
	if [catch {open $fnam "w"} fId] {
		ForceVal $e "Cannot write temporary file.\nFOR SAFETY quit the Table Editor"
		return
	}
	foreach item [$z2 get 0 end] {
		puts $fId $item
	}
	close $fId
	if {$cctyp == "t" || $cctyp == "T"} {
		if {$z1 == $ic} { 			;#	if val transferred from in
			set fnam $evv(COLFILE1)
		} else {
			set fnam $evv(COLFILE2)
		}		
		if [catch {open $fnam "w"} fId] {
			ForceVal $e "Cannot write temporary file.\nFOR SAFETY quit the Table Editor"
			return
		}
		foreach item [$z1 get 0 end] {
			puts $fId $item
		}
		close $fId
	}
	$tabed.bot.icframe.zog.sw config -state normal
	catch {unset tabedit_bind3}
	set lmo "X"
}

proc Movcol {typ} {
	global z1 z2 inlines outlines tabed evv

	set ic $tabed.bot.icframe.l.list
	set oc $tabed.bot.ocframe.l.list
	set delsrc 0
	if [string match {[mtT]} $typ] {
		set delsrc 1
	}
	set i [$z1 curselection]
	if {[info exists i] && ($i >= 0)} {
		set item [$z1 get $i]
		if {$delsrc} {
			$z1 delete $i
		}
	}
	if {$typ == "T"} {
		if {![info exists item]} {
			ForceVal $e "No item selected."
		 	$e config -bg $evv(EMPH)
			return
		}
		set cheklist 0
		if [string match $z2 $oc] {
			if {([string length $outlines] > 0) && ($outlines > 0)} {
				set cheklist 1
			}
		} elseif {([string length $inlines] > 0)  && ($inlines > 0)} {
			set cheklist 1
		}
		if {$cheklist} {
			set done 0
			foreach item2 [$z2 get 0 end] {
				if {$done || ($item2 < $item)} {
					lappend nlst $item2
				} else { 
					lappend nlst $item $item2
					set done 1
				}
			}
			if {!$done} {
				lappend nlst $item
			}
		} else {
			set nlst $item
		}
		$z2 delete 0 end
		foreach item $nlst {
			$z2 insert end $item
		}
	} else {
		$z2 insert end $item
	}

	if [string match $z1 $ic] {
		if {$delsrc} {
			incr inlines -1
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		}
		if {[string length $outlines] <= 0} {
			set outlines 1
			ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		} else {
			incr outlines
			ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		}
	} else {
		if {$delsrc} {
			incr outlines -1
			ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		}
		if {[string length $inlines] <= 0} {
			set inlines 1
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		} else {
			incr inlines
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		}
	}
}

#--- Insert one column in other, at cursor

proc CursVec {val typ} {
	global colpar insitu ino outlines inlines orig_inlines tot_inlines orig_incolget col_ungapd_numeric lmo evv
	global last_oc last_cr outcolcnt tot_outlines record_temacro temacro temacrop threshold tabed

	set e $tabed.message.e
 	set ic $tabed.bot.icframe.l.list
 	set oc $tabed.bot.ocframe.l.list
	set t $tabed.bot.ktframe

	HaltCursCop
	ForceVal $e ""
	$e config -bg [option get . background {}]
	if {([$ic index end] <= 0) || ([$oc index end] <= 0)} {
		ForceVal $e "One or more columns missing."
	 	$e config -bg $evv(EMPH)
		return
	}
	set itoo 0
	switch -- $val {
		"i"	{
			set inl $ic	;#	initial list in Incol, and its tempfile
			set inl2 $oc	;#	other list in Outcol
			if {$insitu} {
				set fnam $evv(COLFILE1)		;#	which tempfile to write data to
			} else {
				set fnam $evv(COLFILE2)
				set last_oc [$oc get 0 end]
				set last_cr $col_ungapd_numeric
			}
		}
		"o"	{
			set inl $oc	;#	initial list in Outl, and its tempfile
			set inl2 $ic	;#	other list in Incol
			set fnam $evv(COLFILE2)
			set last_oc [$oc get 0 end]
			set last_cr $col_ungapd_numeric
		}
	}
	set i [$inl curselection]

	if {![info exists i] || ($i < 0)} {
		ForceVal $e "No position selected."
		$e config -bg $evv(EMPH)
		return
	}

	set lmo "CV"
	lappend lmo $col_ungapd_numeric $val $typ
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {($val == "o") || $insitu} {
		set outl $inl						;#	copy here to here
	} else {
		set outl $oc						;#	copy in->out
		set itoo 1
	}
	switch -- $typ {
		"b" {								;#	below
			set a [$inl get 0 $i]
			set kk 0
			foreach jj [$inl get 0 end] {
				incr kk
			}
			incr kk -1
			if {$i >= $kk} {
				set b ""
			} else {
				incr i 1
				set b [$inl get $i end]
			}
		}
		"a" {								;#	above
			if {$i == 0} {
				set a ""
				set b [$inl get 0 end]
			} else {
				incr i -1
				set a [$inl get 0 $i]
				incr i 1
				set b [$inl get $i end]
			}
		}
		"r" {
			if {$i == 0} {
				set a ""
				set b [$inl get 1 end]
			} else {
				incr i -1
				set a [$inl get 0 $i]
				incr i 2
				set b [$inl get $i end]
			}
		}
	}
	set a [concat $a [$inl2 get 0 end] $b]
 	set cntt [llength $a]
	$outl delete 0 end
	foreach item $a {
		$outl insert end $item
	}
	if {$insitu} {		   
		set inlines $cntt
		ForceVal $tabed.bot.icframe.dummy.cnt $inlines
	} else {
		set outlines $cntt
		ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	}
	if {($outl == $oc) \
	 && ($itoo || ($typ == "a") || ($typ == "b"))} { ;#	if val copied in->out or no. of vals in outcol changes
		if {$ino} {
			if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
				SetKCState "o"
			} elseif {$outlines == $tot_inlines} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		} else {
			if {[info exists tot_outlines] && ($tot_outlines > 0) && ($outlines == $tot_outlines)} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		}
	}
	if [catch {open $fnam "w"} fId] {
		ForceVal $e "Cannot write temporary file.\nFOR SAFETY quit the Table Editor"
		return
	}
	foreach item [$outl get 0 end] {
		puts $fId $item
	}
	close $fId
}

#--- Insert, Replace,Delete at Cursor position

proc CursCol {typ} {
	global colpar insitu ino outlines inlines orig_inlines tot_inlines orig_incolget col_ungapd_numeric evv
	global last_oc last_cr lmo record_temacro temacro temacrop threshold tabed

	set e $tabed.message.e
 	set ic $tabed.bot.icframe.l.list
 	set oc $tabed.bot.ocframe.l.list

	HaltCursCop

	set lmo CC
	lappend lmo $col_ungapd_numeric $typ
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	ForceVal $e ""
	$e config -bg [option get . background {}]

	set itoo 0
	set strsub 0
	if {$typ != "cc"} {
		if {[string match {[ei]} $typ] || [string match "ne" $typ] || [string match ?s $typ]} {
			if {[string length $colpar] <= 0} {
				ForceVal $e "No string entered."
				$e config -bg $evv(EMPH)
				return
			}
			set strsub 1
		} elseif {![string match d* $typ] && ![IsNumeric $colpar]} {
			ForceVal $e "No value entered."
			$e config -bg $evv(EMPH)
			return
		}
	}
	set i [$ic curselection]
	if {![info exists i] || ($i < 0)} {
		set i [$oc curselection]
		if {![info exists i] || ($i < 0)} {
			ForceVal $e "No position selected."
			$e config -bg $evv(EMPH)
			return
		} else {
			if [string match "dg" $typ] {
				set colpar [$oc get $i]
				return
			}
			set inl $oc							;#	values from OutCol
			set outl $inl					  	;#	copy here to here
			set fnam $evv(COLFILE2)
			set last_oc [$oc get 0 end]
			set last_cr $col_ungapd_numeric
			set fnam $evv(COLFILE2)
		}
	} else {
		if [string match "dg" $typ] {
			set colpar [$ic get $i]
			return
		}
		set inl $ic								;#	values from InCol
		if {$insitu} {		
			set outl $inl					  	;#	copy here to here
			set fnam $evv(COLFILE1)				
		} else {
			set outl $oc						;#	copy in->out
			set itoo 1
			set fnam $evv(COLFILE2)
			set last_oc [$oc get 0 end]
			set last_cr $col_ungapd_numeric
		}
	}

	if {$typ == "cc"} {
 		MusicUnitConvertor 1 [$inl get $i]
		return
	}

	if {$strsub} {
		if {[string match {[ei]} $typ] || [string match "ne" $typ]} {
			set subs [$inl get $i]
		} else {
			set subs $colpar
		}
	}
	foreach item [$inl get 0 end] {			 ;#	keep input list (in case output = input)
		lappend tmp $item
	}
	$outl delete 0 end
	set icnt 0
	set cntt 0
	set zntt 0
	set done 0
	set over 0
	foreach item $tmp {
		if {$typ == "e"} {
			if [string match $item $subs] {
				$outl insert end $colpar
			} else {
				$outl insert end $item
			}
		} elseif {$typ == "ne"} {
			if {![string match $item $subs]} {
				$outl insert end $colpar
			} else {
				$outl insert end $item
			}
		} elseif {$typ == "i"} {
			if [string match $item $subs] {
				$outl insert end $colpar$icnt
				incr icnt
			} else {
				$outl insert end $item
			}
		} elseif {($typ == "db") && ($zntt <= $i)} {
			set done 1
			incr zntt
			continue
		} elseif {!$done && ($cntt == $i)} {
			switch -- $typ {
				"r" {
					$outl insert end $colpar
				}
				"rs" {
					$outl insert end $subs
				}
				"a" {
					$outl insert end $item
					$outl insert end $colpar
					incr cntt
				}
				"as" {
					$outl insert end $item
					$outl insert end $subs
					incr cntt
				}
				"b" {
					$outl insert end $colpar
					$outl insert end $item
					incr cntt
				}
				"bs" {
					$outl insert end $subs
					$outl insert end $item
					incr cntt
				}
				"d" {
					incr cntt -1
				}
				"da" {
					incr cntt -1
					set over 1
				}
			}
			set done 1
		} else {
			$outl insert end $item
		}	
		incr cntt
		if {$over} {
			break
		}
	}
	if {$insitu} {		   
		set inlines $cntt
		ForceVal $tabed.bot.icframe.dummy.cnt $inlines
	} else {
		set outlines $cntt
		ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	}
	switch -- $typ {
		"a"  -
		"b"  -
		"as" -
		"bs" -
		"d"  -
		"db" -
		"da" {
			set itoo 1
		}
	}
	if {$itoo} {				;#	if val copied in -> out or number of vals changes
		if {$ino} {
			if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
				SetKCState "o"
			} elseif {$outlines == $tot_inlines} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		} else {
			if {[info exists tot_inlines] && ($tot_inlines > 0)} {
			 	if {[info exists orig_inlines] && ($outlines == $orig_inlines) && ([string length $orig_incolget] > 0)} {
					SetKCState "o"
				} elseif {$tot_inlines == $outlines} {
					SetKCState 1
				} else {
					SetKCState "k"
				}
			} else {
				SetKCState "k"
			}
		}
	}
	if [catch {open $fnam "w"} fId] {
		ForceVal $e "Cannot write temporary file.\nFOR SAFETY quit the Table Editor"
		return
	}
	foreach item [$outl get 0 end] {
		puts $fId $item
	}
	close $fId
}

#---- Hilite corrsponding element in other column

proc CursHilite {typ} {
	global outlines inlines lmo col_ungapd_numeric threshold record_temacro temacro temacrop threshold colpar tabed evv

	HaltCursCop
	set e $tabed.message.e
 	set ic $tabed.bot.icframe.l.list
 	set oc $tabed.bot.ocframe.l.list

	set lmo "CH" 
	lappend lmo $col_ungapd_numeric $typ
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	ForceVal $e ""
	$e config -bg [option get . background {}]
	set inl $ic							;#	assume current selection is in Incol
	set outl $oc						;#	final list in Outcol
	set olen $outlines			
	set i [$inl curselection]
	if {![info exists i] || ($i < 0)} {	;#	if assumption fails
		set inl $oc						;#	assume current selection is in Outcol
		set outl $ic					;#	final list in Incol
		set olen $inlines			
	}
	set i [$inl curselection]

	if {![info exists i] || ($i < 0)} {
		ForceVal $e "No position selected."
		$e config -bg $evv(EMPH)
		return
	} elseif {[string length $olen] <= 0} {
		ForceVal $e "Other column has no data."
		$e config -bg $evv(EMPH)
		return
	}
	switch -- $typ {
		"p" {
			if {$i > $olen} {
				ForceVal $e "No corresponding element in the other column."
				$e config -bg $evv(EMPH)
				return
			}
			$outl selection clear 0 end
			$outl selection set $i
			$inl yview moveto [expr double($i)/double([$inl index end])]
			$outl yview moveto [expr double($i)/double([$outl index end])]
		}
		"v" {
			set val [$inl get $i]
			set isnum 1
			if {![IsNumeric $val]} {
				set isnum 0
			}
			set israng 0
			if [IsNumeric $threshold] {
				if {!$isnum} {
					ForceVal $e "Cannot do numeric comparison within range $threshold on a nun-numeric value."
					$e config -bg $evv(EMPH)
					return
				}
				if {$threshold < 0.0} {
					set threshold -$threshold
				}
				set uplim [expr $val + $threshold]
				set dnlim [expr $val - $threshold]
				set israng 1
			}
			set j 0
			set got 0
			foreach v [$outl get 0 end] {
				if {$israng} {
					if {($v <= $uplim) && ($v >= $dnlim)} {
						set got 1
					}
				} elseif {$isnum} { 
					if [Flteq $v $val] {
						set got 1
					}
				} elseif [string match $v $val] {
					set got 1
				}
				if {$got} {					
					$outl selection clear 0 end
					$outl selection set $j
					$inl yview moveto [expr double($i)/double([$inl index end])]
					$outl yview moveto [expr double($j)/double([$outl index end])]
					return
				}
				incr j
			}
			ForceVal $e "No corresponding element in the other column."
			$e config -bg $evv(EMPH)
			return
		}
	}
}

#---- Find particular element in other column

proc FindInCol {typ} {
	global colpar threshold outlines inlines lmo col_ungapd_numeric tot_inlines tot_outlines 
	global record_temacro temacro temacrop tabed evv

	HaltCursCop
	set got 0
	set e $tabed.message.e
	ForceVal $e ""
	$e config -bg [option get . background {}]
	set lmo "FC"
	lappend lmo $col_ungapd_numeric $typ
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![IsNumeric $colpar]} {
		ForceVal $e "No search value entered."
		$e config -bg $evv(EMPH)
		return
	}	
	switch -- $typ {
		"ir" {
	 		set c $tabed.bot.itframe.l.list
			set len $tot_inlines			
		}
		"or" {
	 		set c $tabed.bot.otframe.l.list
			set len $tot_outlines			
		}
		"i" - 
		"ik" {
	 		set c $tabed.bot.icframe.l.list
			set len $inlines			
		}
		"o" -
		"ok" {
	 		set c $tabed.bot.ocframe.l.list
			set len $outlines
		}
	}
	if {[string length $typ] > 1} {
		if {$len < $colpar} {	
			ForceVal $e "The list does not have enough entries."
			$e config -bg $evv(EMPH)
			return
		}
		set i $colpar
		incr i -1
		$c selection clear 0 end
		$c yview moveto [expr double($i) / double($len)]
		$c selection set $i $i
	} else {
		if {[string length $len] <= 0} {
			ForceVal $e "The column has no data."
			$e config -bg $evv(EMPH)
			return
		}	
		set i 0
		set upl $colpar
		set dnl $colpar
		if [IsNumeric $threshold] {
			set upl [expr $colpar + $threshold]
			set dnl [expr $colpar - $threshold]
		}
		foreach val [$c get 0 end] {
			if {($val <= $upl) && ($val >= $dnl)} {
				$c selection clear 0 end
				$c selection set $i
				$c yview moveto [expr double($i) / double($len)]
				set got 1
				break
			}
			incr i
		}
		if {$i >= $len} {
			ForceVal $e "Value not found in this column."
			$e config -bg $evv(EMPH)
			return
		}	
	}
}

#----- Hilite Input or Output Col

proc LiteCol {val} {
	global tabed evv
	set t $tabed.bot
	switch -- $val {
		"i" {
			$t.icframe.isu config -bg $evv(EMPH)
			$t.icframe.isu2 config -bg [option get . background {}]
			$t.icframe.l.list config -relief solid
			$t.ocframe.l.list config -relief sunken
		}
		"o" {
			$t.icframe.isu2 config -bg $evv(EMPH)
			$t.icframe.isu config -bg [option get . background {}]
			$t.ocframe.l.list config -relief solid
			$t.icframe.l.list config -relief sunken
		}
	}
}

#----- Swap the Input and Output Cols

proc SwapCols {} {
	global inlines outlines tot_inlines tot_outlines col_ungapd_numeric last_oc last_cr ino tabed evv

	set tb $tabed.bot

	if {![info exists inlines]  || ([string length $inlines] <= 0)  || ($inlines <= 0) \
	||  ![info exists outlines] || ([string length $outlines] <= 0) || ($outlines <= 0)} {
		return
	}
	set li $tb.icframe.l.list
	set lo $tb.ocframe.l.list
	set last_oc [$lo get 0 end]
	set last_cr $col_ungapd_numeric
	foreach item [$lo get 0 end] {
		lappend tmp $item
	}
	$lo delete 0 end
	foreach item [$li get 0 end] {
		$lo insert end $item
	}
	$li delete 0 end
	foreach item $tmp {
		$li insert end $item
	}
	set fnam $evv(DFLT_OUTNAME)
	append fnam "0" $evv(TEXT_EXT)
	set k $inlines
	set inlines $outlines
	ForceVal $tabed.bot.icframe.dummy.cnt $inlines
	set outlines $k
	ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	set OK 1
	while {$OK} {
		if {![catch {file stat $evv(COLFILE1) filestatus} in]} {
			if {$filestatus(ino) >= 0} {
				catch {close $filestatus(ino)}
			}
		}
		if {[file exists $fnam]} {
			if [catch {file rename -force $evv(COLFILE1) $fnam} in] {
				set OK 0
				break
			}
		} else {
			if [catch {file rename $evv(COLFILE1) $fnam} in] {
				set OK 0
				break
			}
		}
		if {![catch {file stat $evv(COLFILE2) filestatus} in]} {
			if {$filestatus(ino) >= 0} {
				catch {close $filestatus(ino)}
			}
		}
		if {[file exists $evv(COLFILE1)]} {
			if [catch {file rename -force $evv(COLFILE2) $evv(COLFILE1)} in] {
				set OK 0
				break
			}
		} else {
			if [catch {file rename $evv(COLFILE2) $evv(COLFILE1)} in] {
				set OK 0
				break
			}
		}
		if [catch {file rename $fnam $evv(COLFILE2)} in] {
			set OK 0
			break
		}
		break		
	}
	if {!$OK} {
		ForceVal $tabed.message.e  "Can't swap temporary files : EXIT TABLE EDITOR, FOR SAFETY!!"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$inlines != $outlines} {
		if {$ino} {
			if {$tot_inlines == $outlines} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		} else {
			if {$tot_outlines == $outlines} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
		}
	}
}

#----- Rationalise resetting of 'Keep Column' buttons.

proc SetKCState {val} {
	global coltype rcolno orig_incolget tabed

	set t $tabed.bot.kcframe
	set d "disabled"
	set n "normal"
	switch -- $val {
		"1" {				   ;#	Insert State with insert col defaulted to 1
			set coltype "i"		
			$t.oko config -state $d
			$t.okr config -state $n
			$t.okk config -state $n
			$t.oki config -state $n
			$t.ok config -state $n
			$t.e config -state $n
			set rcolno 1
		}
		"i" {					;#	Insert State, no default
			set coltype "i"		
			set rcolno ""
			$t.oko config -state $d
			$t.okr config -state $n
			$t.okk config -state $n
			$t.oki config -state $n
			$t.ok config -state $n
			$t.e config -state $n
			ForceVal $t.e $rcolno
		}
		"o" {					;#	Replace Original Column State
			set coltype "o"		
			$t.oko config -state $n
			$t.okr config -state $n
			$t.okk config -state $n
			$t.oki config -state $n
			$t.ok config -state $n
			$t.e config -state $d
			set rcolno $orig_incolget
		}
		"k" {					;#	Keep as is, state
			set coltype "k"		
			set rcolno ""
			set tb $tabed.bot.kcframe
			$t.okk config -state $n
			$t.oko config -state $d
			$t.okr config -state $d
			$t.oki config -state $d
			$t.ok config -state $n
			$t.e config -state $d
			ForceVal $t.e $rcolno
		}
		"0" {					;#	Non-operational state
			set rcolno ""
			set tb $tabed.bot.kcframe
			$t.okk config -state $d
			$t.oko config -state $d
			$t.okr config -state $d
			$t.oki config -state $d
			$t.ok config -state $n
			$t.e config -state $d
			ForceVal $t.e $rcolno
		}
		"r" {					;#	Replace col (NOT original col) state
			set coltype "r"
			set rcolno 1
			$t.e config -state $d
			$t.oko config -state $n
			$t.okr config -state $n
			$t.oki config -state $n
			$t.ok config -state $n
			ForceVal $t.e $rcolno
		}
	}
}

#----- Clear Output Table.

proc TabClear {} {
	global outcolcnt tot_outlines col_tabname ttclear tabedit_bind2 tabed last_couldbe_seq2 evv

	set ttclear 0
	set t $tabed.bot.otframe
	set k $tabed.bot.ktframe
	catch {unset last_couldbe_seq2}

	if [file exists $evv(COLFILE3)] {
		if [catch {file delete $evv(COLFILE3)} in] {
			ForceVal $tabed.message.e "Cannot delete temporary file $evv(COLFILE3)"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	set col_tabname ""
	DisableOutputTableOptions 1
	SetInout 1
}

#------ Select partic filetypes to list on Tab Editor

proc TEListSelect {typ} {
	global freetext wl pa tabed evv

	set n "normal"
	set d "disabled"
	set tb $tabed.bot
	set t $tb.fframe.l.list
	$t delete 0 end
	switch -- $typ {
		"all" {
			if {$freetext} {
				foreach fnam [$wl get 0 end] {
					if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
						$t insert end $fnam			
					}
					set eflag 1
					set eflag2 0
					$tb.gframe.cse config -state $n
					$tb.gframe.cse2 config -state $n
					$tb.fframe.d.all config -state $n
					$tb.fframe.d.mix config -state $n
					$tb.fframe.d.brk config -state $n -text "Brk"
					set tet 0
				}
			} else {
				foreach fnam [$wl get 0 end] {
					if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST)} {
						$t insert end $fnam			
					}
					set eflag 0
					set eflag2 0
					$tb.gframe.cse config -state $d
					$tb.gframe.cse2 config -state $d
					$tb.fframe.d.all config -state $n
					$tb.fframe.d.mix config -state $n
					$tb.fframe.d.brk config -state $n -text "Brk"
					set tet 0
				}
			}
		}
		"brk" {
			foreach fnam [$wl get 0 end] {
				if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
					$t insert end $fnam			
				}
			}
		}
		"bat" {
			foreach fnam [$wl get 0 end] {
				if {[string match [file extension $fnam] ".bat"]} {
					$t insert end $fnam			
				}
			}
		}
		"mix" {
			foreach fnam [$wl get 0 end] {
				set ftyp $pa($fnam,$evv(FTYP))
				if {($ftyp & $evv(MIXFILE)) && ($ftyp != $evv(WORDLIST))} {
					$t insert end $fnam			
				}
			}
		}
	}
}

#------ Copy table from in to out

proc CopyTabToOut {} {
	global tot_outlines tedit_message tot_inlines col_infnam tcop outcolcnt incols tabedit_ns tabedit_bind2 evv
	global col_tabname tabed okz
	
	set k $tabed.bot.ktframe
	set tcop 0
	set tb $tabed.bot
	set tedit_message ""
	HaltCursCop
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ([llength $tot_inlines] <= 0)} {
		set line "No input table selected"
		ForceVal $tabed.message.e $line
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	} else {
		set outcolcnt $incols
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines $tot_inlines
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	}
	if {[file exists $evv(COLFILE3)]} {
		if [catch {file copy -force $col_infnam $evv(COLFILE3)} in] {
			ForceVal $tabed.message.e  "Cannot overwrite existing temporary table file"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} else {
		if [catch {file copy $col_infnam $evv(COLFILE3)} in] {
			ForceVal $tabed.message.e  "Cannot overwrite existing temporary table file"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	$tb.otframe.l.list delete 0 end
	foreach item [$tb.itframe.l.list get 0 end] {
		$tb.otframe.l.list insert end $item
	}		
	EnableOutputTableOptions 1 1
	if {[info exists outlines] && ($tot_outlines != $outlines)} {
		if {$okz == 0} {
			set okz -1
		}
		$tb.kcframe.okz config -state disabled
	}
}

#------ generate a new table of data

proc TabMake {typ} {
	global pr_maketext wstk prm wl record_temacro temacro temacrop threshold colpar evv
	global isbrktype wl src lmo col_ungapd_numeric tabedit_ns tot_outlines outcolcnt sl_real tabed search_string 
	global tstandard tlist col_x CDPcolrun docol_OK freetext
	global pstore pmcnt pprg mmod keepfreeze col_x incols

	if {$freetext} {
		set asked_re_oddrows 1
	} else {
		set asked_re_oddrows 0
	}
	if {!$sl_real} {
		Inf "You Can Create Tables By Writing The Values Directly As Text.\nThese Tables Can Then Be Processed Further With The Table Editor,"
		return
	}
	ForceVal $tabed.message.e  ""
 	$tabed.message.e config -bg [option get . background {}]

	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe
	set tb $tabed.bot

	HaltCursCop
	if {$typ == "i"} {
		set fnam $evv(DFLT_OUTNAME)
		append fnam "0" $evv(TEXT_EXT)
	} else {
		set fnam $evv(COLFILE3)
	}
	if [catch {open $fnam "w"} fId] {
		ForceVal $tabed.message.e  "Cannot open temporary file $fnam"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set lmo TM
	lappend lmo $col_ungapd_numeric $typ
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$typ == "ze"} {
		set colcmd [file join $evv(CDPROGRAM_DIR) columns]
		lappend colcmd 0 ;# DUMMY PARAM
		if {![CreateColumnParams $typ 5]} {	;#	an alternative way to get colpar values
			catch {close $fId}
			return
		}
		set i 1
		while {$i <= 5} {
			lappend colcmd $col_x($i)
			incr i
		}
		lappend colcmd -$typ
		set docol_OK 0
		$ot delete 0 end
		set sloom_cmd [linsert $colcmd 1 "#"]
		if [catch {open "|$sloom_cmd"} CDPcolrun] {
			ErrShow "$CDPcolrun"
	   	} else {
   			fileevent $CDPcolrun readable "DisplayNewColumn $ot"
			vwait docol_OK
	   	}
		if {$docol_OK} {
			set tot_outlines 0
			foreach line [$ot get 0 end] {
				puts $fId $line
				incr tot_outlines
			}
			ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
			close $fId
			set outcolcnt 2
			ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
			EnableOutputTableOptions 1 0
		} else {
			catch {close $fId}
		}
	} elseif {$typ == "ie"} {
		if {$pprg != $evv(ITERATE_EXTEND) || ($mmod != 1)} {
			if {![info exists keepfreeze]} {
				ForceVal $tabed.message.e "No data from 'FREEZE SOUND BY ITERATION' in 'DURATION' mode."
				$tabed.message.e config -bg $evv(EMPH)
				catch {close $fId}
				return
			}
		}
		if {![info exists colpar] || ([string length $colpar] == 0)} {
			set scaling 1.0
		} elseif {![IsNumeric $colpar] || ($colpar > 1.0)} {
			ForceVal $tabed.message.e  "Invalid scaling value in N (amount by which normalising is REDUCED: less than 1.0)."
			$tabed.message.e config -bg $evv(EMPH)
			catch {close $fId}
			return
		} else {
			set scaling $colpar
		}
		if {$pprg == $evv(ITERATE_EXTEND) && ($mmod == 1)} {
			if {![info exists pstore] || ![info exists pmcnt] || ($pmcnt < 8)} {
				ForceVal $tabed.message.e "Cannot get (all) parameters."
				$tabed.message.e config -bg $evv(EMPH)
				catch {close $fId}
				return
			}
			set i 0
			while {$i < $pmcnt} {
				if {![IsNumeric $pstore($i)]} {
					ForceVal $tabed.message.e "Only works with numeric parameters (no filenames)."
					$tabed.message.e config -bg $evv(EMPH)
					catch {close $fId}
					return
				}
				incr i
			}
			set i 0
			while {$i < $pmcnt} {
				set keepfreeze($i) $pstore($i)
				incr i
			}
		}
		set seglen [expr $keepfreeze(6) - $keepfreeze(5)]
		set rectifier [expr ($seglen / $keepfreeze(1)) * $scaling]
		$ot delete 0 end
		set line "0.0"
		append line "     " $rectifier
		$ot insert end $line
		set line $keepfreeze(5)
		append line "     " $rectifier
		$ot insert end $line
		set line $keepfreeze(6)
		append line "     " 1.0
		$ot insert end $line
		set line $keepfreeze(0)
		append line "     " 1.0
		$ot insert end $line
		set line [expr $keepfreeze(0) + $seglen]
		append line "     " $rectifier
		$ot insert end $line
		set line "10000.0"
		append line "     " $rectifier
		$ot insert end $line
		set tot_outlines 0
		foreach line [$ot get 0 end] {
			puts $fId $line
			incr tot_outlines
		}
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		close $fId
		set outcolcnt 2
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		EnableOutputTableOptions 1 0
		SetInout 1
	} elseif {$typ == "pp"} {
		$ot delete 0 end
		set colcmd [file join $evv(CDPROGRAM_DIR) columns]
		lappend colcmd 0 ;# DUMMY PARAM
		if {![CreateColumnParams $typ 7]} {	;#	an alternative way to get colpar values
			catch {close $fId}
			return
		}
		if {($col_x(1) > 1.0) || ($col_x(1) < $evv(FLTERR))} {
			ForceVal $tabed.message.e "Inner pan range invalid (must be > 0 and <= 1)."
			$tabed.message.e config -bg $evv(EMPH)
			catch {close $fId}
			return
		}
		if {($col_x(2) <= $col_x(1))} {
			ForceVal $tabed.message.e "Outer pan range must be > inner pan range ($col_x(1))."
			$tabed.message.e config -bg $evv(EMPH)
			catch {close $fId}
			return
		}
		if {($col_x(3) > $col_x(2)) || ($col_x(3) < [expr -$col_x(2)])} {
			ForceVal $tabed.message.e "Start position is outside outer width."
			$tabed.message.e config -bg $evv(EMPH)
			catch {close $fId}
			return
		}
		if {$col_x(4) > 1.0} {
			ForceVal $tabed.message.e "Time proportion at edges must be less than 1.0."
			$tabed.message.e config -bg $evv(EMPH)
			catch {close $fId}
			return
		}

		if {$col_x(5) < .01} {
			ForceVal $tabed.message.e "Back-forth duration must be >= 0.01"
			$tabed.message.e config -bg $evv(EMPH)
			catch {close $fId}
			return
		}
		if {$col_x(6) < $col_x(5)} {
			ForceVal $tabed.message.e "Total duration must be >= Back-forth duration"
			$tabed.message.e config -bg $evv(EMPH)
			catch {close $fId}
			return
		}
		if {[expr $col_x(6) / $col_x(5)] >= 1000.0} {
			set msg "This Will Create A Very Large File: Do You Want To Continue ??"
	
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				catch {close $fId}
				return
			}
		}
		if {![string match "0" $col_x(7)] && ![string match "1" $col_x(7)]} {
			ForceVal $tabed.message.e "7th parameter must be 1 initial motion leftwards, 0 for rightwards."
			$tabed.message.e config -bg $evv(EMPH)
			catch {close $fId}
			return
		}
		set i 1
		while {$i <= 7} {
			lappend colcmd $col_x($i)
			incr i
		}
		lappend colcmd -$typ
		set docol_OK 0
		$ot delete 0 end
		set sloom_cmd [linsert $colcmd 1 "#"]
		if [catch {open "|$sloom_cmd"} CDPcolrun] {
			ErrShow "$CDPcolrun"
	   	} else {
   			fileevent $CDPcolrun readable "DisplayNewColumn $ot"
			vwait docol_OK
	   	}
		if {$docol_OK} {
			set tot_outlines 0
			foreach line [$ot get 0 end] {
				puts $fId $line
				incr tot_outlines
			}
			ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
			close $fId
			set outcolcnt 2
			ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
			EnableOutputTableOptions 1 0
			SetInout 1
		} else {
			catch {close $fId}
		}
	} else {
		set f .maketext
		if [Dlg_Create $f "Create A Datafile" "set pr_maketext 0" -borderwidth $evv(BBDR)] {
			EstablishTextWindow $f 0
		}
#		$f.b.k config -text "K" -width 2 -bd 2 -command "Shortcuts textfile" -bg $evv(HELP)
		$f.b.k config -text "" -width 0 -bd 0 -command {}
		$f.z.0.src config -bg [option get . background {}]
		$f.z.0.ss  config -bg [option get . background {}]
		$f.b.undo config -text "" -bd 0 -command {}

#		InstallMeterKeystrokes $f
		set tstandard .maketext.z.z.t
		$tstandard config -state normal
		$tstandard delete 1.0 end
		$tstandard config -state disabled
		set tlist .maketext.k.t
		set search_string ""
		$f.b.find config -text "" -bd 0 -state disabled
		$f.b.ref config -command "RefSee $f.k.t"
		$f.b.l config -text "" 
		$f.b.e config -borderwidth 0 -state readonly -readonlybackground [option get . background {}]
		$f.b.m config -borderwidth 0  -state disabled -text ""

		.maketext.b.keep config -text "Keep Data"

		.maketext.b.cancel config -text "Abandon"
		wm title $f "Create Table Data"
		ForceVal $f.b.e  ""
		set t $f.k.t
		$t delete 1.0 end
		set pr_maketext 0
		set finished 0

		raise $f
		My_Grab 0 $f pr_maketext $f.k.t
		while {!$finished} {
			tkwait variable pr_maketext
			set OK 1
			if {$pr_maketext} {
				set llcnt 0
				set icols 0
				set i 1
				while {$i >= 0} {
					set line [$t get $i.0 $i.end]
					catch {unset newl}
					set indata [split $line]
					set ccnt 0
					foreach item $indata {
						if {[string length $item] > 0} {
							incr ccnt
							if {$llcnt == 0} {
								incr icols
							}
							lappend newl $item
						}
					}
					if {$ccnt <= 0} {
						break
					}
					if {($llcnt > 0) && ($ccnt != $icols)} {
						if {!$asked_re_oddrows} {
							if {$typ == "i"} {
								Inf "Invalid data:\n\nto Create Input Tables with different row-lengths\n\ngo to 'Free text' Mode"
								catch {unset zz}
								set OK 0			
								break
							} else {
								set msg "Table has rows of different lengths: Is this OK??"
								set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									catch {unset zz}
									set OK 0			
									break
								} else {
									set asked_re_oddrows 1
								}
							}
						}
					}
					if [info exists newl] {
						lappend zz $newl
						incr llcnt
					}
					incr i
				}
				if {!$OK} {
					continue
				}
				if {$llcnt <= 0} {
					ForceVal $f.b.e "Invalid data"
					continue
				}
				foreach line $zz {
					puts $fId $line
				}
				ForceVal $f.b.e ""
				set finished 1			

			} else {
				set finished 1
			}
		}
		close $fId
#		UninstallMeterKeystrokes $f
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		if {$pr_maketext} {
			if {[DoParse $fnam $wl 0 0] <= 0} {
				ErrShow "Parsing failed for new file."
			} else {
				if {$typ == "i"} {
	 				GetTableFromFilelist 0 0 1
				} else {
					$ot delete 0 end
					set tot_outlines 0
					foreach line $zz {
						$ot insert end $line
						incr tot_outlines
					}
					ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
					set outcolcnt $icols
					ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
					EnableOutputTableOptions 1 0
					SetInout 1
				}
			}
		}
	}
}

#------ Find dur generated from timestr brktable

proc TabStr {typ mode} {
	global lmo col_ungapd_numeric col_infnam pa outcolcnt colpar incol_OK CDPcolget 
	global record_temacro temacro temacrop threshold evv tabed

	HaltCursCop
	set lmo "TS"
	lappend lmo $col_ungapd_numeric $typ $mode
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$typ == "i"} {
		if {![info exists col_infnam] || ![file exists $col_infnam]} {
			ForceVal $tabed.message.e  "No input table exists"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists pa($col_infnam,$evv(FTYP))] || ![IsABrkfile $pa($col_infnam,$evv(FTYP))]} {
			ForceVal $tabed.message.e  "Input table has inappropriate number of columns."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set fnam $col_infnam
	} else {
		if {![file exists $evv(COLFILE3)]} {
			ForceVal $tabed.message.e  "No output table exists"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists outcolcnt] || ($outcolcnt != 2)} {
			ForceVal $tabed.message.e  "Output table has inappropriate number of columns."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set fnam $evv(COLFILE3)
	}
	if {[info exists colpar] && [IsNumeric $colpar]} { 
		if {$colpar <= 0.0} {
			ForceVal $tabed.message.e  "Invalid time parameter given at N."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set zz $colpar
	} else {
		set zz 0
	}
	set cmd [file join $evv(CDPROGRAM_DIR) brkdur]
	lappend cmd $fnam $mode $zz
	set incol_OK 1
	if [catch {open "|$cmd"} CDPcolget] {
		ErrShow "$CDPcolget"
   	} else {
   		fileevent $CDPcolget readable "DisplayStretchFromTable"
		vwait incol_OK
   	}
}

#------ Display info got from a table

proc DisplayStretchFromTable {} {
	global CDPcolget incol_OK col_from_table tabed evv

	if [eof $CDPcolget] {
		set incol_OK 1
		catch {close $CDPcolget}
		return
	} else {
		gets $CDPcolget line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match INFO:* $line] {
			set line [string range $line 6 end] 
			ForceVal $tabed.message.e $line
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
		} else {
			set line "Invalid Message ($line) received from program."
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
		}
		set incol_OK 0
		catch {close $CDPcolget}
		return
	}
	update idletasks
}			

#------ generate simple envelope

proc BrkMak {} {
	global col_x wl lmo col_ungapd_numeric record_temacro temacro temacrop colpar threshold sl_real tabed evv

	if {!$sl_real} {
		Inf "You Can Create Breakpoint Tables By Writing The Values Directly As Text.\nThese Tables Can Then Be Processed Further With The Table Editor,"
		return
	}

	HaltCursCop
	set fnam $evv(DFLT_OUTNAME)
	append fnam "0" $evv(TEXT_EXT)
	if [catch {open $fnam "w"} fId] {
		ForceVal $tabed.message.e  "Cannot open temporary file $fnam"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![CreateColumnParams 0 2]} {
		catch {close $fId}
		return
	}
	set splices [expr $col_x(2) * 2.0]
	if {$splices > $col_x(1)} {
		ForceVal $tabed.message.e  "Dovetails too long."
	 	$tabed.message.e config -bg $evv(EMPH)
		catch {close $fId}
		return
	} else {
		set lmo BM
		lappend lmo $col_ungapd_numeric 0
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
		lappend line "0"
		lappend line "0"
		puts $fId $line
		unset line
		lappend line $col_x(2)
		lappend line "1"
		puts $fId $line
		unset line
		if {![Flteq $splices $col_x(1)]} {
			lappend line [expr $col_x(1) - $col_x(2)]
			lappend line "1"
			puts $fId $line
			unset line
		}											  
		lappend line $col_x(1)
		lappend line "0"
		puts $fId $line
	}
	close $fId
	if {[DoParse $fnam $wl 0 0] <= 0} {
		ErrShow "Parsing failed for new file."
	} else {
 		$tabed.bot.itframe.l.list delete 0 end
 		GetTableFromFilelist 0 0 1
	}
}

#------ generate pseudo mixfile

proc MixMak {typ} {
	global wl lmo col_ungapd_numeric threshold colpar wstk tot_inlines incols tot_outlines outcolcnt tabedit_ns evv
	global record_temacro temacro temacrop pa files_to_wkspace_from_tabed chlist
	global col_tabname col_infnam tabed

	HaltCursCop
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <= 0)} {
		ForceVal $tabed.message.e  "No input table to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	SetInout 1

	set lmo MM 
	if [info exists col_ungapd_numeric] {
		lappend lmo $col_ungapd_numeric $typ
	} else {
		lappend lmo 0 $typ
	}
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	if {$typ < 2} {
		if {![info exists colpar] || ([string length $colpar] <= 0)} {
			ForceVal $tabed.message.e  "No name given for sound file in mix. (Enter as 'N')"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set colpar_p [file tail $colpar]
		set colpar_e ""
		set k [string first "." $colpar_p] 
		if {$k >= 0} {
			set colpar_e [string range $colpar_p $k end]
			incr k -1
			set colpar_p [string range $colpar_p 0 $k]
		}
		if {$typ == 1} {
			if [regexp {[0-9]$} $colpar_p] {
				ForceVal $tabed.message.e  "Generic soundfilename cannot have a number at the end, for this process."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		} elseif {[IsNumeric $colpar]} {
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
				-message "Filename, entered as parameter N, is a number ($colpar). Is this correct?"]
			if {$choice == "no"} {
				return
			}
		}
		set fnam $colpar
		set xa [file rootname [file tail $fnam]]
		set xb [file dirname $fnam]
		if {![ValidCdpFilename $xa 1]} {
			return
		}
		if {[info exists xb] && ![file isdirectory $xb]} {
			ForceVal $tabed.message.e  "No such file directory exists."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[string length $colpar_e] > 0} {
			if {![string match $colpar_e $evv(SNDFILE_EXT)]} {
				ForceVal $tabed.message.e  "Invalid soundfile extension used in name."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		if {![info exists threshold] || ([string length $threshold] <= 0)} {
			ForceVal $tabed.message.e  "No channel count given. (Enter as 'threshold')"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {!([IsNumeric $threshold] && [string match {[12]} $threshold])} {
			ForceVal $tabed.message.e  "Invalid channel count entered in 'threshold' (use 1 or 2 only)."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ffnam $fnam
		if {[string length $colpar_e] <= 0} {
			append ffnam $evv(SNDFILE_EXT) 
		} elseif {$typ} {
			set fnam [file rootname $ffnam]
		}
 		set fcnt 0
		foreach line [$ti get 0 end] {
			set c_cnt 0
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					set it $item
					incr c_cnt
				}
			}
			if {$c_cnt < 1} {
				continue
			} elseif {$c_cnt != 1} {
				ForceVal $tabed.message.e "This process only works with single column tables."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![IsNumeric $it] || ($it < 0.0)} {
				ForceVal $tabed.message.e "Invalid time value ($it) encountered in input table."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			catch {unset row_s}
			if {$typ} {
				if {[string length $colpar_e] > 0} {
					set ffnam $fnam$fcnt$colpar_e
				} else {
					set ffnam $fnam$fcnt$evv(SNDFILE_EXT) 
				}
				incr fcnt
			}
			set row_s [list $ffnam $it $threshold "1.0"]
			lappend mxf $row_s
		}
		catch {unset row_s}
		if {![info exists mxf]} {
			ForceVal $tabed.message.e "No valid data found in input table."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {$typ == 4} {

		if {$incols != 1} {
			ForceVal $tabed.message.e  "Input table is not a pattern list."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set patmax 0
		foreach n [$ti get 0 end] {
			if {![regexp {^[0-9]+$} $n] || ($n < 1)} {
				ForceVal $tabed.message.e "Invalid pattern n '$n' in Table."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$n > $patmax} {
				set patmax $n
			}
		}
		if {![info exists chlist]} {
			ForceVal $tabed.message.e "No files selected on Chosen List on Workspace."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set cnt 0
		foreach fnam $chlist {
			if {![info exists pa($fnam,$evv(FTYP))]} {
				ForceVal $tabed.message.e "No data available on file $fnam"
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				ForceVal $tabed.message.e "File $fnam, on Chosen Files list, is not a soundfile."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$pa($fnam,$evv(CHANS)) > 2} {
				ForceVal $tabed.message.e "File $fnam, on Chosen Files list, is not mono or stereo."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			incr cnt
		}
		if {$cnt < $patmax} {
			ForceVal $tabed.message.e "Insufficient files ($cnt) on Chosen List for pattern (maxval $patmax)."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}			
		set sum 0.0
		foreach n [$ti get 0 end] {
			incr n -1
			set fnam [lindex $chlist $n]
			set chans $pa($fnam,$evv(CHANS))
			set dur $pa($fnam,$evv(DUR))
			set line $fnam
			append line " " $sum " " $chans " " 1.0
			if {$chans == 1} {
				append line " " C
			}
			lappend mxf $line
			set sum [expr $sum + $dur]
		}
	} else {
		set sumdur 0.0
		foreach line [$ti get 0 end] {
			set fnam [string trim $line]
			if {[string length $fnam] <= 0} {
				continue
			}
			if {![file exists $fnam] || [file isdirectory $fnam]} {
				RemoveFromWkspace tabed
				ForceVal $tabed.message.e "Item $fnam in your table is not an existing file."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}	
			if {![info exists pa($fnam,$evv(FTYP))]} {
				if {[DoMinParse $fnam] <= 0} {
					RemoveFromWkspace tabed
					ForceVal $tabed.message.e "Item $fnam in your table is not a CDP compatible file."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				} elseif {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
					RemoveFromWkspace tabed
					ForceVal $tabed.message.e "Item $fnam in your table is not a sound file."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}				 
				unset pa($fnam,$evv(FTYP))
				if {[FileToWkspace $fnam 0 0 0 1 0] <= 0} {
					RemoveFromWkspace tabed
					ForceVal $tabed.message.e "Cannot use soundfile $fnam in your table."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
				lappend files_to_wkspace_from_tabed $fnam
			} elseif {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				RemoveFromWkspace tabed
				ForceVal $tabed.message.e "Item $fnam in your table is not a sound file."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {($pa($fnam,$evv(CHANS)) < 1) || ($pa($fnam,$evv(CHANS)) > 2)} {
				RemoveFromWkspace tabed
				ForceVal $tabed.message.e "Item $fnam in your table has wrong number of channels."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}			
			if {[info exists srate]} {
				if {$srate != $pa($fnam,$evv(SRATE))} {
					RemoveFromWkspace tabed
					ForceVal $tabed.message.e "Incompatible sample rates in files [$ti get 0] and $fnam."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			} else {
				set srate $pa($fnam,$evv(SRATE))
			}
			set outline $fnam
			if {$typ == 3} {
				set dur $pa($fnam,$evv(DUR))
				append outline " $sumdur 1 1.0"
				set sumdur [expr $sumdur + $dur]
			} else {
				append outline " 0 1 1.0"
			}
			lappend mxf $outline
		}
		catch {unset files_to_wkspace_from_tabed}
		if {![info exists mxf]} {
			ForceVal $tabed.message.e "No data found in input file."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		unset mxf
	} else {
		$to delete 0 end
		foreach line $mxf {
			$to insert end $line
			puts $fileot $line
		}
		close $fileot						;#	Write data to file
		set outcolcnt 4
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines $tot_inlines
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		EnableOutputTableOptions 1 1
	}
}

#------ tabeditor output to outtable, or intable.

proc SetInout {val}  {
	global okk okr oko oki okz outlines tot_outlines tot_inlines orig_inlines 
	global outcolcnt ino coltype orig_incolget tabed evv

	set n "normal"
	set d "disabled"
	set t $tabed.bot.kcframe
	set tol $tabed.bot.otframe.l.list
	set til $tabed.bot.itframe.l.list
	switch -- $val {
		0 {
			$tol config -bg $evv(EMPH)
			$til config -bg [option get . background {}]
			$t.oko config -state $d
#RADICAL JAN 2004 , MOVED FROM END OF THIS BRACKET
			set okz 0
			if {[info exists tot_outlines] && ([string length $tot_outlines] > 0)} {
				if {$tot_outlines > 0 && ($outlines == $tot_outlines)} {
					if {($coltype == "o") || ($coltype == "k")} {
						set coltype "r"
						$t.e config -state $n
					}
					$t.okr config -state $n
					$t.oki config -state $n
				} elseif {($tot_outlines <= 0) || ($outlines != $tot_outlines)} {
#					if {$coltype == "o"} {
#						set coltype "k"
#						$t.okr config -state $d
#						$t.oki config -state $d
#RADICAL JAN 2004
#						set okz -1
#					}
					set coltype "k"
					$t.okr config -state $d
					$t.oki config -state $d
#RADICAL JAN 2004
					set okz -1
				}
			} else {
				set coltype "k"
				$t.okr config -state $d
				$t.oki config -state $d
				set okz -1
			}
			$t.oky config -fg [option get . foreground {}]
			$t.okz config -fg $evv(SPECIAL)
			set ino 0
		}
		1 {
			set coltype ""
			set okz 1
			if {[info exists tot_inlines] && ($tot_inlines > 0)} {
			 	if {[info exists orig_inlines] && ($outlines == $orig_inlines) && ([string length $orig_incolget] > 0)} {
					SetKCState "o"
				} elseif {$tot_inlines == $outlines} {
					SetKCState 1
				} else {
					SetKCState "k"
					set okz -1
				}
			} elseif {[info exists outlines] && ($outlines > 0)} {
				SetKCState "k"
				set okz -1
			}
			set ino 1
			$t.oky config -fg $evv(SPECIAL)
			$t.okz config -fg [option get . foreground {}]
		}
	}
}

#------ Rearrange a listbox, in alphabetical order

proc ListSort {ll} {
	global tls
	foreach z [$ll get 0 end] {
		lappend zz $z
	}
	if [info exists zz] {
		$ll delete 0 end
		foreach z [lsort -dictionary $zz] {
			$ll insert end $z
		}
	}
	set tls 0
}

#------ Recall previous TabEdit process

proc TabRep {} {
	global col_ungapd_numeric lmo oi tabed evv

	HaltCursCop
	if {![info exists lmo]} {
		ForceVal $tabed.message.e "No previous process recorded."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set str [lindex $lmo 0]
	if {$str == "X"} {
		ForceVal $tabed.message.e "No previous process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set col_ungapd_numeric [lindex $lmo 1]
	if {[llength $lmo] > 2} {
		set mm [lindex $lmo 2]
		if {[llength $lmo] >= 4} {
			set jj [lindex $lmo 3]
		}
	}
	switch -- $str {
		"recycle" { set col_ungapd_numeric 1 ; GenerateNewColumn "recycle" 0; set oi 0}
		"copy" 	  { GenerateNewColumn "copy" 0 ; set io 0}
		"AF" { AlgebraCol }
		"atb" { AssembleTransformBatch }
		"Be" { BatchfileExtend $mm}
		"BM" { BrkMak }
		"C"	 { CreateNewColumn $mm $jj }
		"CBR" { ColsBecomeRows }
		"CC" { CursCol $mm }
		"CD" { ColDelete $mm}
		"CH" { CursHilite $mm }
		"CO" { EnvOp $mm }
		"CR" { CursRotate }
		"CT" { ColtoTab $mm $jj}
		"CV" { CursVec $mm $jj }
		"cy" { Cyclics $mm }
		"Dg" { RandomiseWithVariance}
		"DM" { DelColMarks $mm }
		"EC" { ExtCol $mm }
		"F"  { ColFormat $mm }
		"FC" { FindInCol $mm }
		"FN" { FindNum }
		"G"	 { GenerateNewColumn $mm $jj }
		"GA" { GetAlgebra 1 }
		"GD" { GetDblColFromTable }
		"GE" { GlobalEditTable }
		"I"	 { InsText}
		"ID" { IndexedDuplication $mm $jj}
		"J"	 { ColJoin $mm }
		"K"	 { KillText $mm}
		"KA" { KeepAlgebra}
		"MB" { MassageBrk $mm $jj}
		"MM" { MixMak $mm}
		"Mm" { MergeMixfiles $mm}
		"MT" { TabMod $mm}
		"NG" { NameGames $mm }
		"NP" { NewPatterns $mm $jj }
		"pm" { PitchManips $mm}
		"Pc" { PlayChordset $mm $jj}
		"PX" { Patex }
		"IA" { Minimax }
		"RB" { RowInsertBrk $mm }
		"RC" { RepatternCol }
		"RCS" { RandColSelect 0 }
		"RD" { RowDelete $mm }
		"RI" { RowInsert $mm }
		"RJ" { RowsJiggleBrk $mm }
		"RK" { RowKeep $mm}
		"RR" { RowRandomise 0}
		"RRN" { RowRandomise 1}
		"RRS" { RandColSelect 1 }
		"Rs" { RowSwap $mm}
		"RS" { RowSort }
		"rA" { RowAlphaSort }
		"RP" { RepositionMixtimes}
		"rr" { RowRotate $mm }
		"RV" { RowInvert }
		"SC" { RowSwap $mm}
		"SM" { SpliceMak $mm $jj}
		"sm" { StrMak $mm }
		"st" { SplitTransforms }
		"STM" { StaffToMidi $mm }
		"STR" { StaffToBeats $mm }
		"Sy" { SyncMidships $mm}
		"T"	 { TrimColumn $mm }
		"TDs" { TabDupl 1}
		"TD" { TabDupl 0}
		"TM" { TabMake $mm }
		"TS" { TabStr $mm $jj }
		"TT" { SplitTable $mm}
		"V"	 { Vectors $mm }
		"Vb" { VbankRow $mm }
		"vB" { VectoredBatchfile $mm}
		"VT" { VectorstoTab $mm $jj}
		"Vt" { Vtrans $mm }
		"VV" { VVectors $mm }
		"Z"  { CursCop $mm $jj}
		"Zc" { Zcuts $mm }
		"ZZA" { TabPattern "ZZA" }
		"ZZB" { TabPattern "ZZB" }
		"ZZC" { TabPattern "ZZC" }
		"ZZD" { TabPattern "ZZD" }
	}
	return
}

#------ Get both columns from a table

proc GetDblColFromTable {} {
	global incols inlines outlines tot_inlines col_skiplines eflag eflag2 tabed 
	global CDPcolget incol_OK evv last_oc last_cr coltype lmo col_ungapd_numeric colpar
	global col_infnam col_from_table tedit_message col_lines_skipped record_temacro temacro temacrop threshold

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	HaltCursCop
  	set n "normal"
	set d "disabled"
	if {$incols != 2} {
		return
	}
	set is_skip 0
	set is_eflag 0
	set is_eflag2 0
	set tb $tabed.bot
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]
	catch {unset col_from_table}

	$tb.icframe.l.list delete 0 end
	$tb.ocframe.l.list delete 0 end
	set getcol_cmd [file join $evv(CDPROGRAM_DIR) getcol]
	lappend getcol_cmd $col_infnam $evv(COLFILE1) 1
	if {[info exists col_skiplines]	&& ([string length $col_skiplines] > 0)} {
		if {$tot_inlines <= $col_skiplines} {
			ForceVal $tabed.message.e  "Entire file skipped!"
		 	$tabed.message.e config -bg $evv(EMPH)
			set inlines ""
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
			return
		} elseif {$col_skiplines > 0} {
			lappend getcol_cmd $col_skiplines
		}
		set is_skip 1
	}
	if {[info exists eflag] && $eflag} {
		lappend getcol_cmd "-e"
		set is_eflag 1
	}
	if {[info exists eflag2] && $eflag2} {
		lappend getcol_cmd "-ec"
		set is_eflag2 1
	}
	set incol_OK 1

	set sloom_cmd [linsert $getcol_cmd 1 "#"]
	if [catch {open "|$sloom_cmd"} CDPcolget] {
		ErrShow "$CDPcolget"
   	} else {
   		fileevent $CDPcolget readable "DisplayColumnFromTable"
		vwait incol_OK
   	}

	if {![info exists col_from_table] || ([llength $col_from_table] < 2)} {
		ForceVal $tabed.message.e  "Insufficient data in file."
	 	$tabed.message.e config -bg $evv(EMPH)
		$tb.icframe.l.list delete 0 end
		set incol_OK 0
	}		
	if {$incol_OK} {
		set lo [lindex $col_from_table 0]
		foreach hi [lrange $col_from_table 1 end] {
			if {$hi <= $lo} {
				ForceVal $tabed.message.e  "Column 1 values not in ascending order. Cannot be brkpnt data"
			 	$tabed.message.e config -bg $evv(EMPH)
				$tb.icframe.l.list delete 0 end
				set incol_OK 0
				break
			}
			set lo $hi
		}
	}
	set lmo GD
	lappend lmo $col_ungapd_numeric 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$incol_OK} {
		if [catch {open $evv(COLFILE1) "w"} fileic] {
			ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE1) to write column data"
		 	$tabed.message.e config -bg $evv(EMPH)
			$tb.icframe.l.list delete 0 end
		} else {
			set inlines 0
			foreach line $col_from_table {
				$tb.icframe.l.list insert end $line
				puts $fileic $line
				incr inlines
			}
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
			close $fileic							;#	Write data to file
			set col_lines_skipped $col_skiplines

			if {[info exists outlines] && ($inlines == $outlines)} {
				SetKCState "r"
				$tb.kcframe.oky config -state $n
				$tb.kcframe.okz config -state $n
			} else {
				SetKCState "k"
				$tb.kcframe.okk config -state $d
				$tb.kcframe.oky config -state $d
				$tb.kcframe.okz config -state $d
			}
		}
	} else {
		$tb.icframe.l.list delete 0 end		;#	Clear existing listing of input column
		set inlines ""
		ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		$tabed.topa.brk config -state $d -text ""
		return
	}

	set getcol_cmd [file join $evv(CDPROGRAM_DIR) getcol]
	lappend getcol_cmd $col_infnam $evv(COLFILE2) 2
	if {$is_skip} {
		lappend getcol_cmd $col_skiplines
	}
	if {$is_eflag} {
		lappend getcol_cmd "-e"
	} elseif {$is_eflag2} {
		lappend getcol_cmd "-ec"
	}
	set incol_OK 1
	catch {unset col_from_table}
	set sloom_cmd [linsert $getcol_cmd 1 "#"]
	if [catch {open "|$sloom_cmd"} CDPcolget] {
		ErrShow "$CDPcolget"
   	} else {
   		fileevent $CDPcolget readable "DisplayColumnFromTable"
		vwait incol_OK
   	}

	if {$incol_OK} {
		if [catch {open $evv(COLFILE2) "w"} fileic] {
			ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE2) to write 2nd column of data"
		 	$tabed.message.e config -bg $evv(EMPH)
			$tb.ocframe.l.list delete 0 end		;#	Clear existing listing of output column
		} else {
			set outlines 0
			foreach line $col_from_table {
				$tb.ocframe.l.list insert end $line
				puts $fileic $line
				incr outlines
			}
			ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
			close $fileic							;#	Write data to file

			$tb.kcframe.okk config -state $n
			SetKCState "r"
			$tb.kcframe.oky config -state $n
			$tb.kcframe.okz config -state $n
		}
	} else {
		$tb.ocframe.l.list delete 0 end		;#	Clear existing listing of input column
		set outlines ""
		ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		$tabed.topa.brk config -state $d -text ""
	}
	set last_oc [$tb.ocframe.l.list get 0 end]
	set last_cr 1
}

#------ Delete column from table

proc ColDelete {zz} {
	global outcolcnt tot_outlines colpar tot_inlines incols tabedit_ns tabedit_bind2 lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold
	global col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	} else {
		ForceVal $tabed.message.e "No input table has been selected."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tb $tabed.bot
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		ForceVal $tabed.message.e "No Column-number parameter (N) given."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "Unable to find any columns in the input table."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	switch -- $zz {
		"0" {
			if {($colpar < 1) || ($colpar > $incols)} {
				ForceVal $tabed.message.e "This column does not exist."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set k [expr $colpar - 1]
		}
		"1" -
		"2" {
			if {$colpar < 1} {
				ForceVal $tabed.message.e "You cannot delete less than 1 column."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$colpar >= $incols} {
				ForceVal $tabed.message.e "This would delete the entire table."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$zz == 1} {
				set k $colpar
			} else {
				set k [expr $incols - $colpar - 1]
			}
		}
	}
	if {$incols < 2} {
		ForceVal $tabed.message.e "Deletion will remove the whole table."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}

	set lmo "CD"
	lappend lmo $col_ungapd_numeric 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	$tb.otframe.l.list delete 0 end
	foreach line [$tb.itframe.l.list get 0 end] {
		catch {unset col_s}
		set c_cnt 0
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend col_s $item
				incr c_cnt
			}
		}
		if [info exists lastc_cnt] {
			if {$c_cnt != $lastc_cnt} {
				ForceVal $tabed.message.e "Lines do not all have same number of columns."
			 	$tabed.message.e config -bg $evv(EMPH)
				$tb.otframe.l.list delete 0 end
				return
			}
		}
		set lastc_cnt $c_cnt
		switch -- $zz {
			"0" {
				set col_s [lreplace $col_s $k $k]
			}
			"1" {
				set col_s [lreplace $col_s $k end]
			}
			"2" {
				set col_s [lreplace $col_s 0 $k]
			}
		}
		set line ""
		foreach item $col_s {
			append line $item " "
		}
		set line [string trim $line]
		$tb.otframe.l.list insert end $line
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
	} else {
		set outcolcnt 0
		set tot_outlines 0
		foreach line [$tb.otframe.l.list get 0 end] {
			if {!$outcolcnt} {
				foreach val $line {
					set val [string trim $val]
					if {[string length $val] > 0} {
						 incr outcolcnt
					}
				}
			}
			incr tot_outlines
			puts $fileot $line
		}
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		close $fileot						;#	Write data to file
	}
	EnableOutputTableOptions 1 1
}

#------ Delete row from table

proc RowDelete {n} {
	global outcolcnt tot_outlines colpar threshold tot_inlines incols tabedit_ns tabedit_bind2 lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop
	global col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set tb $tabed.bot
	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "RD"
	lappend lmo $col_ungapd_numeric $n
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <= 0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {($n != 3) && ($n != 7) && ($n != 8) && ($n != 9) && ($n != 11) && ($n != 12) && ($n != 13)} {
		if {![info exists colpar] || ![IsNumeric $colpar]} {
			ForceVal $tabed.message.e "No (valid) parameter given."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			set colpar [expr int(round($colpar))]
		}
	}
	if {$n == 6} {
	 	if {![info exists threshold] || ![IsNumeric $threshold] || ($threshold < 1)} {
			ForceVal $tabed.message.e "No (valid) threshold parameter given."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			set threshold [expr int(round($threshold))]
		}
	}
	set OK 1
	switch -- $n {
		0 {
			if {$tot_inlines < 2} {
				ForceVal $tabed.message.e "Deletion will remove the whole table."
				set OK 0
			}
			if {($colpar < 1) || ($colpar > $tot_inlines)} {
				ForceVal $tabed.message.e "This row does not exist."
				set OK 0
			}
			set k $colpar
			incr k -1
		}
		1 -
		2 {
			if {$colpar < 1} {
				ForceVal $tabed.message.e "Too few rows to keep."
				set OK  0
			} elseif {$colpar > [expr $tot_inlines - 1]} {
				ForceVal $tabed.message.e "Too many rows to keep."
				set OK 0
			}
			set k $colpar
		}
		3 -
		4 -
		7 - 
		8 {
			set i [$tb.itframe.l.list curselection]
			if {![info exists i] || ($i < 0)} {
				ForceVal $tabed.message.e "No item selected with cursor."
				set OK 0
			} else {
				set k $i
			}
			if {$OK && ($n == 4)} {
				if {$colpar < 1} {
					ForceVal $tabed.message.e "Too few rows to delete."
					set OK  0
				}
			}
		}
		5 -
		6 {
			set i [$tb.itframe.l.list curselection]
			if {![info exists i] || ($i < 0)} {
				ForceVal $tabed.message.e "No item selected with cursor."
				set OK  0
			} else {
				set k $i
				if {$colpar < 1} {
					ForceVal $tabed.message.e "Invalid parameter given."
					set OK  0
				}
			}
			if {$n == 6} {
				if {$threshold > $colpar} {
					ForceVal $tabed.message.e "The two parameters are incompatible."
					set OK  0
				} elseif {$threshold == $colpar} {
					ForceVal $tabed.message.e "All rows beyond $i would be deleted."
					set OK  0
				}
			}					
		}
		10 {
			if {$colpar < 1} {
				ForceVal $tabed.message.e "Zero lines to delete ???."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			} elseif {$colpar >= $tot_inlines} {
				ForceVal $tabed.message.e "This will delelete all the lines."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	}
	if {!$OK} {
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}

	$tb.otframe.l.list delete 0 end
	set i 0
	switch -- $n {
		0 -
		3 {
			foreach line [$tb.itframe.l.list get 0 end] {
				if {$i != $k} {
					$tb.otframe.l.list insert end $line
				}
				incr i
			}
		}
		1 -
		7 {
			foreach line [$tb.itframe.l.list get 0 end] {
				if {$i < $k} {
					$tb.otframe.l.list insert end $line
				} else {
					break
				}
				incr i
			}
		}
		8 {
			foreach line [$tb.itframe.l.list get 0 end] {
				if {$i > $k} {
					$tb.otframe.l.list insert end $line
				}
				incr i
			}
		}
		2 {
			foreach line [$tb.itframe.l.list get 0 end] {
				incr i
			}
			set k [expr $i - $k]
			set i 0
			foreach line [$tb.itframe.l.list get 0 end] {
				if {$i >= $k} {
					$tb.otframe.l.list insert end $line
				}
				incr i
			}
		}
		4 {
			set j $k
			incr j $colpar
			incr j -1
			foreach line [$tb.itframe.l.list get 0 end] {
				if {($i < $k) || ($i > $j)} {
					$tb.otframe.l.list insert end $line
				}
				incr i
			}
		}
		5 {
			set j $k
			foreach line [$tb.itframe.l.list get 0 end] {
				if {$i < $j} {
					$tb.otframe.l.list insert end $line
				} else {
					incr j $colpar
				}
				incr i
			}
		}
		6 {
			set th $threshold
			incr th -1
			set start $k
			set end [expr $start + $th]
			set nextstart [expr $start + $colpar]
			foreach line [$tb.itframe.l.list get 0 end] {
				if {$i >= $nextstart} {
					incr start $colpar
					incr nextstart $colpar
					incr end $colpar
				}
				if {$i < $start || $i > $end} {
					$tb.otframe.l.list insert end $line
				}
				incr i
			}
		}
		9 {
			foreach line [$tb.itframe.l.list get 0 end] {
				set line [string trim $line]
				if {([string length $line] > 0) && ![string match ";" [string index $line 0]]} {
					$tb.otframe.l.list insert end $line
				}
			}
		}
		10 {
			foreach line [$tb.itframe.l.list get 0 end] {
				$tb.otframe.l.list insert end $line
			}
			set outcnt $tot_inlines
			set kk 0
			while {$kk < $colpar} {
				set qq [expr int(round(rand() * double($outcnt)))]
				$tb.otframe.l.list delete $qq
				incr outcnt -1
				incr kk
			}
		}
		11 {
			foreach line [$tb.itframe.l.list get 0 end] {
				lappend in_lines $line
			}
			set len [llength $in_lines]
			set origlen $len
			set len_less_one [expr $len - 1]
			set n 0
			while {$n < $len_less_one} {
				set line_n [lindex $in_lines $n]
				set m $n
				incr m
				while {$m < $len} {
					set line_m [lindex $in_lines $m]
					if {[string match $line_n $line_m]} {
						set in_lines [lreplace $in_lines $m $m]
						incr len -1
						incr len_less_one -1
					} else {
						incr m
					}
				}
				incr n
			}
			if {$origlen == $len} {
				ForceVal $tabed.message.e "No rows deleted."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			foreach line $in_lines {
				$tb.otframe.l.list insert end $line
			}
		}
		12 {
			foreach line [$tb.itframe.l.list get 0 end] {
				lappend in_lines $line
			}
			set len [llength $in_lines]
			set origlen $len
			set len_less_one [expr $len - 1]
			set n 0
			while {$n < $len_less_one} {
				set line_n [lindex $in_lines $n]
				set m $n
				incr m
				set line_m [lindex $in_lines $m]
				if {[string match $line_n $line_m]} {
					set in_lines [lreplace $in_lines $m $m]
					incr len -1
					incr len_less_one -1
				}
				incr n
			}
			if {$origlen == $len} {
				ForceVal $tabed.message.e "No rows deleted."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			foreach line $in_lines {
				$tb.otframe.l.list insert end $line
			}
		}
		13 {
			foreach line [$tb.itframe.l.list get 0 end] {
				catch {unset nuline}
				set line [string trim $line]
				if {[string length $line] > 0} {
					set line [split $line]
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] > 0} {
							lappend nuline $item
						}
					}
				}
				if {[info exists nuline]} {
					lappend in_lines $nuline
				}
			}
			set origlen [llength $in_lines]
			if {$origlen  > 1} {
				set len [llength $in_lines]
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					set line_n [lindex $in_lines $n]
					set m $n
					incr m
					set line_m [lindex $in_lines $m]
					if {([llength $line_n] > 1) && ([llength $line_m] > 1)} {
						if {[string match [lrange $line_n 1 end] [lrange $line_m 1 end]]} {
							set in_lines [lreplace $in_lines $m $m]
							incr len -1
							incr len_less_one -1
						}
					}
					incr n
				}
				if {$origlen == $len} {
					ForceVal $tabed.message.e "No rows deleted."
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			} else {
				ForceVal $tabed.message.e "No rows deleted."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			foreach line $in_lines {
				$tb.otframe.l.list insert end $line
			}
		}
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set tot_outlines 0
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		return
	} else {
		set outcolcnt $incols
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines 0
		foreach line [$tb.otframe.l.list get 0 end] {
			incr tot_outlines
			puts $fileot $line
		}
		close $fileot						;#	Write data to file
	}
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
}

#------ Create column from scratch

proc ScratchCol {typ} {
	global pr_maketext textfilename is_file_edit docol_OK wstk ocl search_string tstandard tlist evv

	HaltCursCop
	set is_file_edit 0
	set f .maketext
	catch {unset ocl}
	if [Dlg_Create $f "Create A Column" "set pr_maketext 0" -borderwidth $evv(BBDR)] {
		EstablishTextWindow $f 0
	}
	$f.b.k config -text "K" -width 0 -bd 0 -command {} -bg [option get . background {}]
	$f.z.0.src config -bg [option get . background {}]
	$f.z.0.ss  config -bg [option get . background {}]
	$f.b.undo config -text "" -bd 0 -command {}
	set tstandard .maketext.z.z.t
	$tstandard config -state normal
	$tstandard delete 1.0 end
	$tstandard config -state disabled
	set tlist .maketext.k.t
	set search_string ""
	$f.b.find config -text "" -bd 0 -state disabled
	$f.b.ref config -command "RefSee $f.k.t"
	$f.b.l config -text ""
	$f.b.e config -borderwidth 0 -state readonly -readonlybackground [option get . background {}]
	$f.b.m config -borderwidth 0 -state disabled -text ""

	.maketext.b.keep config -text "Save Col"
	.maketext.b.cancel config -text "Close"
	wm title $f "Create a Column"
	set t $f.k.t
	$t delete 1.0 end
	set textfilename ""
	ForceVal $f.b.e $textfilename
	set pr_maketext 0
	set OK 0
	raise $f
	My_Grab 0 $f pr_maketext $f.k.t
	while {!$OK} {
		tkwait variable pr_maketext
		set j 0
		if {$pr_maketext} {
			set n 1
			set m 2
			set nn $n
			append nn ".0"
			set mm $m
			append mm ".0"
			while {![catch {set val [$t get $nn $mm]} in]} {
				set val [string trim $val]
				if {[string length $val] <= 0} {
					if {$j > 0} {
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
							-message "$j lines entered : OK?"]
						if {$choice == "no"} {
							set j 0
							catch {unset ocl}
						}
					}
					break
				}
				if {$typ == "Ii"} {
					if {![IsNumeric $val]} {
						Inf "Invalid entry $val at line $n"
						set j 0
						break
					}
				}
				lappend ocl $val
				incr j
				incr n
				incr m
				set nn $n
				append nn ".0"
				set mm $m
				append mm ".0"
			}
			if {$j > 0} {
				set OK 1
			}
		} else {
			set OK 1								;#	CANCEL: exit dialog
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ generate duplicates of table, at stepped time intervals

proc TabDupl {stepped} {
	global wl lmo col_ungapd_numeric threshold colpar wstk tot_inlines incols tot_outlines outcolcnt tabedit_ns evv
	global record_temacro temacro temacrop
	global col_tabname col_infnam tabed

	HaltCursCop
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e  "No input table to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	SetInout 1

	if {$stepped} {
		set lmo "TDs"
	} else {
		set lmo "TD"
	}
	lappend lmo $col_ungapd_numeric 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	if {![info exists colpar] || ([string length $colpar] <= 0) || ![IsNumeric $colpar] || ($colpar < 1)} {
		ForceVal $tabed.message.e  "No (valid) duplication parameter given."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$stepped} {
		if {![info exists threshold] || ([string length $threshold] <= 0) || ![IsNumeric $threshold] || ($threshold < 0)} {
			ForceVal $tabed.message.e  "No (valid) timestep given. (Enter as 'threshold')"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach line [$ti get 0 end] {
			set c_cnt 0
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$c_cnt == 0} {
						if {![IsNumeric $item]} {
							ForceVal $tabed.message.e  "This process only works where first column could be interpreted as time data."
					 		$tabed.message.e config -bg $evv(EMPH)
							return
						}
					}
					incr c_cnt
				}
			}
			if {$c_cnt < 1} {
				continue
			} else {
				lappend lines $line
			}
		}
	} else {
		foreach line [$ti get 0 end] {
			lappend lines $line
		}
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
	} else {
		$to delete 0 end
		foreach line $lines {
			$to insert end $line
			puts $fileot $line
		}
		if {$stepped} {
			set i 1
			set j $threshold
			while {$i < $colpar} {
				foreach line $lines {
					set time [lindex $line 0]
					set time [expr $time + $j]
					set line [lreplace $line 0 0 $time]
					$to insert end $line
					puts $fileot $line
				}
				set j [expr $j + $threshold]
				incr i
			}
		} else {
			set i 1
			while {$i < $colpar} {
				foreach line $lines {
					$to insert end $line
					puts $fileot $line
				}
				incr i
			}
		}
		close $fileot						;#	Write data to file
		set outcolcnt $incols
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines [expr $tot_inlines * $colpar]
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		EnableOutputTableOptions 1 1
	}
}

#------ Do operations on brkpnt tables

proc MassageBrk {colmode p_cnt} {
	global tot_inlines lmo col_ungapd_numeric record_temacro temacro colpar threshold temacrop tedit_message
	global col_x docol_OK CDPcolrun tabedit_ns outcolcnt tot_outlines col_infnam tabedit_bind2
	global col_tabname col_infnam tabed evv
	
	set tb $tabed.bot
	set kt $tabed.bot.ktframe
 	set ot $tabed.bot.otframe.l.list
	 
	HaltCursCop

	if {![info exists col_infnam] || ([string length $col_infnam] <= 0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set lmo MB
	lappend lmo $col_ungapd_numeric $colmode $p_cnt						;#	 Remember last action.
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]
	set colparam $colmode

	set colcmd [file join $evv(CDPROGRAM_DIR) columns]
	lappend colcmd $col_infnam
	if {$p_cnt > 0} {									;#	p_cnt > 0 indicates...
		if {![CreateColumnParams $colmode $p_cnt]} {	;#	an alternative way to get colpar values
			return
		}
		set i 1
		while {$i <= $p_cnt} {
			lappend colcmd $col_x($i)
			incr i
		}
	} elseif {$p_cnt == 0} {
		if {![TestColParam $colmode]} {
			ForceVal $tabed.message.e "Parameter value missing"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[info exists colpar] && ([string length $colpar] > 0)} {
			append colparam $colpar
		}
	}
	lappend colcmd -$colparam

	$ot delete 0 end

	set docol_OK 0
	if {$colmode == "BC"} {
		set docol_OK [BalanceConvert $tabed.bot.itframe.l.list $ot]
	} elseif {$colmode == "stac"} {
		if {![IsNumeric $colpar] || ($colpar <= 0.0)} {
			ForceVal $tabed.message.e "Invalid staccato note duration at 'N'."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach line [$tabed.bot.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nuvals $item
				}
			}
		}
		set cnt 0
		foreach {time val} $nuvals {
			if {[IsEven $cnt]} {
				if {$cnt > 0} {
					if {[Flteq $val 0.0] && ($lastval > 0.0)} {
						set time [expr $lasttime + $colpar]
					}
				}
			} else {
				if {$cnt == 1} {
					if {$val != $lastval} {
						incr cnt 1
					}
				} else {
					if {$val != $lastval} {
						ForceVal $tabed.message.e "Envelope values incorrectly paired: not 'staccato' file."
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
					if {$val > 0.0} {
						set time [expr $lasttime + $colpar]
					}

				}
			}
			set lastval $val
			set lasttime $time
			lappend gnuvals [list $time $val]
			incr cnt
		}
		$tabed.bot.otframe.l.list delete 0 end
		foreach item $gnuvals {
			$tabed.bot.otframe.l.list insert end $item
		}
		set docol_OK 1
	} else {
		set sloom_cmd [linsert $colcmd 1 "#"]
		if [catch {open "|$sloom_cmd"} CDPcolrun] {
			ErrShow "$CDPcolrun"
   		} else {
			fileevent $CDPcolrun readable "DisplayNewColumn $ot"
			vwait docol_OK
   		}
	}
	if {$docol_OK} {
		if [catch {open $evv(COLFILE3) "w"} fileot] {
			ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
		 	$tabed.message.e config -bg $evv(EMPH)
			$ot delete 0 end		;#	Clear existing listing of output table
			set outcolcnt ""
			ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
			return
		} else {
			set outcolcnt 0
			set tot_outlines 0
			foreach line [$ot get 0 end] {
				if {!$outcolcnt} {
					foreach val $line {
						set val [string trim $val]
						if {[string length $val] > 0} {
							 incr outcolcnt
						}
					}
				}
				incr tot_outlines
				puts $fileot $line
			}
			close $fileot						;#	Write data to file
			ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
			ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		}
		EnableOutputTableOptions 1 1
	}
}

#------ show position of row in table, or item in column

proc FindNum {} {
	global lmo col_ungapd_numeric colpar record_temacro temacro temacrop threshold tabed evv

	HaltCursCop
	set e $tabed.message.e
 	set ic $tabed.bot.icframe.l.list
 	set oc $tabed.bot.ocframe.l.list
 	set it $tabed.bot.itframe.l.list
 	set ot $tabed.bot.otframe.l.list

	set lmo "FN" 
	lappend lmo $col_ungapd_numeric 0
	ForceVal $e ""
	$e config -bg [option get . background {}]
	set i [$ic curselection]
	if {![info exists i] || ($i < 0)} {
		set i [$oc curselection]
		if {![info exists i] || ($i < 0)} {
			set i [$it curselection]
			if {![info exists i] || ($i < 0)} {
				set i [$ot curselection]
				if {![info exists i] || ($i < 0)} {
					ForceVal $e "No position selected."
					$e config -bg $evv(EMPH)
					return
				}
			}
		}
	}
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	incr i
	ForceVal $e "position $i"
	$e config -bg $evv(EMPH)
}

#------ generate a new row of data and insert in table

proc RowInsert {before} {
	global pr_maketext tabedit_ns colpar record_temacro temacro temacrop threshold evv
	global lmo col_ungapd_numeric incols tot_inlines tot_outlines outcolcnt search_string
	global col_tabname col_infnam tabed tstandard tlist

	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list

	HaltCursCop
	set lmo RI
	lappend lmo $col_ungapd_numeric $before
	set cl [$it curselection]
	if {![info exists cl] || ($cl < 0)} {
		ForceVal $tabed.message.e  "No line selected."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$before == 2} {
		if {$cl >= [expr [$it index end] - 1]} {
			ForceVal $tabed.message.e  "No following line to interpolate to."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists colpar] || ([string length $colpar] <= 0)} {
			set colpar 1.585
		} elseif {![IsNumeric $colpar] || ($colpar < .01) || ($colpar > 100)} {
			ForceVal $tabed.message.e  "Invalid slope value given at 'N' (range .01 to 100, or leave blank)."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$before < 2} {
		set f .maketext
		if [Dlg_Create $f "Create A Row" "set pr_maketext 0" -borderwidth $evv(BBDR)] {
			EstablishTextWindow $f 0
		}
#		$f.b.k config -text "K" -width 2 -bd 2 -command "Shortcuts textfile" -bg $evv(HELP) NOT AVAILABLE ON THE MAC
		$f.b.k config -text "" -width 0 -bd 0 -command {}
		$f.z.0.src config -bg [option get . background {}]
		$f.z.0.ss  config -bg [option get . background {}]
		$f.b.undo config -text "" -bd 0 -command {}
#		InstallMeterKeystrokes $f
		set tstandard .maketext.z.z.t
		$tstandard config -state normal
		$tstandard delete 1.0 end
		$tstandard config -state disabled
		set tlist .maketext.k.t
		set search_string ""
		$f.b.ref config -command "RefSee $f.k.t"
		$f.b.find config -text "" -bd 0 -state disabled
		$f.b.l config -text "" 
		$f.b.e config -borderwidth 0 -state readonly -readonlybackground [option get . background {}]
		$f.b.m config -borderwidth 0  -state disabled -text ""
		.maketext.b.keep config -text "Keep Data"
		.maketext.b.cancel config -text "Abandon"
		wm title $f "Create A Row"
		ForceVal $f.b.e  ""
		set t $f.k.t
		$t delete 1.0 end
		set pr_maketext 0
		set finished 0

		raise $f
		My_Grab 0 $f pr_maketext $t
		while {!$finished} {
			tkwait variable pr_maketext
			catch {unset newls}
			if {$pr_maketext} {
				set OK 1
				set llcnt 0
				set i 1
				while {$i > 0} {
					set line [$t get $i.0 $i.end]
					set indata [split $line]
					catch {unset line}
					set ccnt 0
					foreach item $indata {
						if {[string length $item] > 0} {
							incr ccnt
							lappend line $item
						}
					}
					if {$ccnt == 0} {
						if {$llcnt == 0} {
							ForceVal $f.b.e "No data in line 1"
							set OK 0			
						}
						set i -1
					} elseif {$ccnt != $incols} {
						ForceVal $f.b.e "Bad column cnt: line $i"
						set OK 0			
						set i -1
					} else {
						lappend newls $line
					}
					incr i
					incr llcnt
				}
				if {$llcnt <= 0} {
					ForceVal $f.b.e "No data."
					set OK 0
				} 
				if {$OK} {
					set finished 1
				}
			} else {
				set finished 1
			}
		}
	} else {	;# Exponential insert
		set vale {}
		while {[llength $vale] < 2} {
			set line [$it get $cl]
			set line [string trim $line]
			if {[string length $line] <= 0} {
				ForceVal $tabed.message.e  "No data on line [expr $cl + 1]."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set line [split $line]
			catch {unset nuline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			if {![info exists nuline] || ([llength $nuline] != 2)} {
				ForceVal $tabed.message.e  "Invalid data on line [expr $cl + 1]."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			lappend time [lindex $nuline 0]
			lappend vale [lindex $nuline 1]
			incr cl
		}
		incr cl -2
		set valbase [lindex $vale 0]
		set timebase [lindex $time 0]
		set tdiff [expr [lindex $time 1] - $timebase]
		set vdiff [expr [lindex $vale 1] - $valbase]
		if {$vdiff == 0} {
			ForceVal $tabed.message.e  "Value does not change here."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set tfrac .125
		while {![Flteq $tfrac 1.0]} {
			set vfrac [expr pow($tfrac,$colpar)]
			set newtime [expr ($tdiff * $tfrac) + $timebase]
			set nuline $newtime
			set newval [expr ($vdiff * $vfrac) + $valbase]
			lappend nuline $newval
			lappend newls $nuline
			set tfrac [expr $tfrac + .125]
		}
		set pr_maketext 1
	}
	if {$pr_maketext} {
		set i 0
		foreach line [$it get 0 end] {
			if {$i == $cl} {
				if {$before == 1} {
					if [info exists zz] {
						set zz [concat $zz $newls]
					} else {
						set zz $newls
					}
					lappend zz $line
				} else {
					lappend zz $line
					set zz [concat $zz $newls]
				}
			} else {
				lappend zz $line
			}
			incr i
		}				
		if [catch {open $evv(COLFILE3) "w"} fId] {
			ForceVal $tabed.message.e  "Cannot open temporary file to write new table"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		$ot delete 0 end
		set tot_outlines 0
		foreach line $zz {
			$ot insert end $line	
			puts $fId $line
			incr tot_outlines
		}
		close $fId
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		set outcolcnt $incols
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		ForceVal $tabed.message.e ""
	 	$tabed.message.e config -bg [option get . background {}]
		set tbk $tabed.bot.ktframe
		EnableOutputTableOptions 1 1
		SetInout 1
	}
	if {$before < 2} {
		ForceVal $f.b.e ""
#		UninstallMeterKeystrokes $f
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	}
}

#------ generate a new row of data and insert in table

proc RowInsertBrk {before} {
	global colpar tabedit_ns record_temacro temacro temacrop threshold evv
	global lmo col_ungapd_numeric incols tot_inlines tot_outlines outcolcnt
	global col_tabname col_infnam tabed

	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list

	HaltCursCop
	set lmo RB
	lappend lmo $col_ungapd_numeric $before
	set cl [$it curselection]
	if {![info exists cl] || ($cl < 0)} {
		ForceVal $tabed.message.e  "No line selected."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		ForceVal $tabed.message.e  "No value entered."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$before} {
		if {$cl <= 0} {
			ForceVal $tabed.message.e  "There are no other values before the selected line. Cannot interpolate time."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set kl $cl
		incr kl -1
		set val1 [lindex [$it get $cl] 0]
		set val2 [lindex [$it get $kl] 0]
		set newls [expr ($val1 + $val2) / 2.0]
		lappend newls $colpar
		set i 0
		foreach line [$it get 0 end] {
			if {$i == $cl} {
				lappend zz $newls
				lappend zz $line
			} else {
				lappend zz $line
			}
			incr i
		}				
	} else {
		if {$cl >= [expr $tot_inlines - 1]} {
			ForceVal $tabed.message.e  "There are no other values beyond the selected line. Cannot interpolate time."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set kl $cl
		incr kl
		set val1 [lindex [$it get $cl] 0]
		set val2 [lindex [$it get $kl] 0]
		set newls [expr ($val1 + $val2) / 2.0]
		lappend newls $colpar
		set i 0
		foreach line [$it get 0 end] {
			if {$i == $cl} {
				lappend zz $line
				lappend zz $newls
			} else {
				lappend zz $line
			}
			incr i
		}				
	}
	if [catch {open $evv(COLFILE3) "w"} fId] {
		ForceVal $tabed.message.e  "Cannot open temporary file to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	$ot delete 0 end
	set tot_outlines 0
	foreach line $zz {
		$ot insert end $line	
		puts $fId $line
		incr tot_outlines
	}
	close $fId
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	ForceVal $tabed.message.e ""
	$tabed.message.e config -bg [option get . background {}]
	set tbk $tabed.bot.ktframe
	EnableOutputTableOptions 1 1
	SetInout 1
}

#------ Move N elements in Table by threshold in time

proc RowsJiggleBrk {typ} {
	global colpar tabedit_ns record_temacro temacro temacrop threshold evv
	global lmo col_ungapd_numeric incols tot_inlines tot_outlines outcolcnt
	global col_tabname col_infnam tabed

	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list

	HaltCursCop
	set lmo RJ
	lappend lmo $col_ungapd_numeric $typ
	switch -- $typ {
		"m" {
			set cl [$it curselection]
			if {![info exists cl] || ($cl < 0)} {
				ForceVal $tabed.message.e  "No line position indicated."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![info exists colpar] || ([string length $colpar] <= 0)} {
				ForceVal $tabed.message.e  "No line count given."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![info exists threshold] || ![IsNumeric $threshold]} {
				ForceVal $tabed.message.e  "No time shift count given."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$threshold < 0.0} {
				set val [lindex [$it get $cl] 0]
				if {[expr double($val) + double($threshold)] < 0.0} {
					ForceVal $tabed.message.e  "Some breakpoint events will occur before zero time: Impossible."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			set n 0
			while {$n < $cl} {
				set line [$it get $n]
				lappend zz $line
				incr n
			}
			incr cl [expr int(round($colpar))]
			while {$n < $cl} {
				set line [$it get $n]
				set val [lindex $line 0]
				set val [expr double($val) + double($threshold)]
				set line [lreplace $line 0 0 $val]		
				lappend zz $line
				incr n
				if {$n >= $tot_inlines} {
					break
				}
			}
			while {$n < $tot_inlines} {
				set line [$it get $n]
				lappend zz $line
				incr n
			}
	
			set len $tot_inlines
			incr len -1
			set i 0
			while {$i < $len} {
				set j $i
				incr j
				while {$j <= $len} {
					set zn [lindex $zz $i]
					set zm [lindex $zz $j]
					if {[lindex $zm 0] < [lindex $zn 0]} {
						set zz [lreplace $zz $i $i $zm] 
						set zz [lreplace $zz $j $j $zn] 
					}
					incr j
				}
				incr i
			}
		}
		"d" {
			if {![info exists colpar] || ![IsNumeric $colpar] || $colpar <= 0.0} {
				ForceVal $tabed.message.e  "Invalid duration value given."
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set olddur [lindex [$it get end] 0]
			if {$olddur <= $evv(FLTERR)} {
				ForceVal $tabed.message.e  "Final duration in brkpnt file too small for this option."
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set factor [expr double($colpar) / double($olddur)]
			foreach line [$it get 0 end] {
				set val [lindex $line 0]
				set val [expr $val * $factor]
				set line [lreplace $line 0 0 $val]		
				lappend zz $line
			}
		}
	}
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if [catch {open $evv(COLFILE3) "w"} fId] {
		ForceVal $tabed.message.e  "Cannot open temporary file to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	$ot delete 0 end
	set tot_outlines 0
	foreach line $zz {
		$ot insert end $line	
		puts $fId $line
		incr tot_outlines
	}
	close $fId
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	ForceVal $tabed.message.e ""
	$tabed.message.e config -bg [option get . background {}]
	set tbk $tabed.bot.ktframe
	EnableOutputTableOptions 1 1
	SetInout 1
}

#######################
# TABLE EDITOR MACROS #
#######################

#---- Record sequence of Table Editor operations as a macro

proc RecordTEMacro {} {
	global temacro temacrop record_temacro tabed evv
	catch {unset temacro}
	catch {unset temacrop}
	set record_temacro 1
	$tabed.top2.rmac config -bg $evv(EMPH) -text "Conclude" -command EndTEMacro
}

#---- Finish recording sequence of Table Editor operations as a macro

proc EndTEMacro {} {
	global record_temacro tabed
	set record_temacro 0
	$tabed.top2.rmac config -bg [option get . background {}] -text "Record" -command RecordTEMacro 
}

#----- Run a Table Editor macro

proc DoTEMacro {} {
	global lmo temacro record_temacro temacrop colpar threshold tabed

	$tabed.top2.rmac config -bg [option get . background {}] -text "Record"
	if {![info exists temacro]} {
		return
	}
	if {$record_temacro} {
		set record_temacro 0
	}
	set origlmo $lmo
	set origcolp $colpar
	set origthre $threshold
	foreach lmo $temacro zxz $temacrop {
		set colpar    [lindex $zxz 0]
		set threshold [lindex $zxz 1]
		TabRep
	}
	set lmo $origlmo
	set colpar $origcolp
	set threshold $origthre
}

#---- Save Table Editor macro to file

proc SaveTEMacro {} {
	global pr_smac macname temacro temacrop last_temacro last_temacrop last_macname wstk sl_real evv

	if {!$sl_real} {
		Inf "You Can Save Your Macro, To Use Again Later\nIn This Session, Or Any Later Session"
		return
	}
	if [catch {file mkdir $evv(MACRO_DIR)} in] {
		Inf "Cannot create a directory to store macros."
		return
	}
	if {![info exists temacro] || ([llength $temacro] <= 0)} {
		Inf "No macro has been recorded yet."
		return
	}
	set OK 1
	if [info exists last_macname] {
		set OK 0
		foreach item $temacro lastitem $last_temacro {
			if {![string match $item $lastitem]} {
				set OK 1
				break
			}
		}
		if {!$OK} {
			foreach item $temacrop lastitem $last_temacrop {
				if {![string match $item $lastitem]} {
					set OK 1
					break
				}
			}
		}
	}
	if {!$OK} {
		Inf "You have already recorded this macro as $last_macname"
		return
	}
	set f .macsave
	if [Dlg_Create $f "Name the macro" "set pr_smac 0" -width 36 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set e [frame $f.e -borderwidth $evv(SBDR)]
		button $b.ok -text "OK"   -command "set pr_smac 1" -highlightbackground [option get . background {}]
		button $b.q -text "Close" -command "set pr_smac 0" -highlightbackground [option get . background {}]
		label $f.e.l -text "macro name"
		entry $f.e.e -textvariable macname -width 24
		pack $f.e.l -side left
		pack $f.e.e -side right
		pack $f.b.ok -side left
		pack $f.b.q -side right
		pack $f.b $f.e -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_smac 1}
		bind $f <Escape> {set pr_smac 0}
	}
	raise $f
	set macname ""
	set pr_smac 0
	set finished 0
	My_Grab 0 $f pr_smac $f.e.e
	while {!$finished} {
		tkwait variable pr_smac
		if {$pr_smac} {
			if {[string length $macname] <= 0} {
				Inf "No name entered for macro."
				continue
			}
			set fnam $macname$evv(TEXT_EXT)
			set OK 1
			foreach filename [glob -nocomplain [file join $evv(MACRO_DIR) *]] {	
				if [string match [file tail $filename] $fnam] {
					set choice [tk_messageBox -message "macro '$macname' already exists. Overwrite it ?" \
						-type yesno -parent [lindex $wstk end] -icon question]
					if {$choice == "no"} {
						set OK 0
						break
					} else {
						break
					}
				}
			}
			if {$OK} {
				set fnam [file join $evv(MACRO_DIR) $fnam]
				if {![catch {file stat $fnam filestatus} in]} {
					if {$filestatus(ino) >= 0} {
						catch {close $filestatus(ino)}
					}
				}
				if [catch {open $fnam "w"} zot] {
					Inf "$zot\nCan't open file $fnam to store macro"
				} else {
					puts $zot $temacro
					puts $zot $temacrop
					set last_temacro $temacro
					set last_temacrop $temacrop
					set last_macname $macname
					close $zot
					set finished 1
				}
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Select Table Editor macro to load from file

proc LoadTEMacro {} {
	global pr_lmac macname evv

	if {![file isdirectory $evv(MACRO_DIR)]} {
		set msg "There are NO existing Table Editor Macros."
		append msg "\nThis could be because...."
		append msg "\n(1) You have not created any macros."
		append msg "\n(2) You have deleted all the macros you had created."
		append msg "\n(3) The directory \"$evv(MACRO_DIR)\" has been deleted or moved."
		Inf $msg
		return 0
	}
	set i 0
	foreach fnam [glob -nocomplain [file join $evv(MACRO_DIR) *]] {	
		lappend mac_ros [file rootname [file tail $fnam]]
		incr i
	}
	if {$i <= 0} {
		Inf "There are no existing Table Editor Macros."
		return 0
	}
	set f .macload
	if [Dlg_Create $f "Load Macro" "set pr_lmac 1" -width 36 -borderwidth $evv(SBDR)] {
		button $f.b -text "Close" -command "set pr_lmac 1" -highlightbackground [option get . background {}]
		Scrolled_Listbox $f.ll -width 20 -height 20
		pack $f.b $f.ll -side top
		wm resizable $f 1 1
		bind $f.ll.list <ButtonRelease-1> "GetTEMacro $f.ll.list"
		bind $f <Return> {set pr_lmac 1}
		bind $f <Escape> {set pr_lmac 1}
		bind $f <Key-space> {set pr_lmac 1}
	}
	$f.ll.list delete 0 end
	foreach macc $mac_ros {
		$f.ll.list insert end $macc
	}	
	raise $f
	set pr_lmac 0
	set finished 0
	My_Grab 0 $f pr_lmac $f.ll.list
	while {!$finished} {
		tkwait variable pr_lmac
		if {$pr_lmac} {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Load Table Editor macro from file

proc GetTEMacro {ll} {
	global temacro temacrop pr_lmac evv

	set i [$ll curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No macro selected"
		return
	}
	set mnam [$ll get $i]
	if {[string length $mnam] <= 0} {
		Inf "No macro selected"
		return
	}
	set fnam [file join $evv(MACRO_DIR) $mnam$evv(TEXT_EXT)]
	if [catch {open $fnam "r"} zot] {
		Inf "Can't open file $fnam to load macro"
		return
	} else {
		set i 0
		while {($i < 2) && [gets $zot line]} {
			switch -- $i {
				0 { set temacro $line }
				1 { set temacrop $line }
			}
			incr i
		}
		close $zot
		if {$i != 2} {
			Inf "Insufficient data in macro file $fnam"
			return
		}
	}
	set pr_lmac 1
	return
}

#---- Delete Table Editor macro file(s)

proc EditTEMacrosList {} {
	global pr_emac macname wstk sl_real evv

	if {!$sl_real} {
		Inf "If You Have Created Macros In The Table Editor, You Can Delete Some Or All Of Them Here."
		return
	}
	if {![file isdirectory $evv(MACRO_DIR)]} {
		Inf "Can't find Table Editor Macros directory '$evv(MACRO_DIR)'"
		return 0
	}
	set i 0
	foreach fnam [glob -nocomplain [file join $evv(MACRO_DIR) *]] {	
		lappend mac_ros [file rootname [file tail $fnam]]
		incr i
	}
	if {$i <= 0} {
		Inf "There are no existing Table Editor Macros."
		return 0
	}
	set f .macdel
	if [Dlg_Create $f "EDIT LIST OF MACROS" "set pr_emac 0" -width 40 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		label $b.l -text "TO DELETE:\nSELECT macro from list\nand CONFIRM deletion"
		button $b.b -text "Close" -command "set pr_emac 0" -highlightbackground [option get . background {}]
		pack $b.l -side left
		pack $b.b -side right
		Scrolled_Listbox $f.ll -width 40 -height 20
		pack $f.b $f.ll -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f.ll.list <ButtonRelease-1> "set pr_emac 1"
		bind $f <Escape>  {set pr_emac 0}
	}
	$f.ll.list delete 0 end
	foreach macc $mac_ros {
		$f.ll.list insert end $macc
	}	
	raise $f
	set pr_emac 0
	set finished 0
	My_Grab 0 $f pr_emac $f.ll.list
	while {!$finished} {
		tkwait variable pr_emac
		if {$pr_emac} {
			set i [$f.ll.list curselection]
			if {![info exists i] || ($i < 0)} {
				Inf "No macro selected"
				continue
			}
			set mnam [$f.ll.list get $i]
			if {[string length $mnam] <= 0} {
				Inf "No macro selected"
				continue
			}
			set choice [tk_messageBox -message "Delete the macro '$mnam' ?" \
				-type yesno -parent [lindex $wstk end] -icon question]
			if {$choice == "no"} {
				continue
			}
			set fnam [file join $evv(MACRO_DIR) $mnam$evv(TEXT_EXT)]
			if [catch {file delete $fnam} zot] {
				Inf "Can't delete the macro file '$fnam'"
			}
			$f.ll.list delete $i
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Tabulate durations of list of soundfiles

proc TabSndsDur {typ} {
	global chlist pa ocl colpar tabed maxsamp_missing maxsamp_line mu CDPmaxId evv

	set sum 0
	if {[string match $typ "Sj"] || [string match $typ "Sjc"]} {
		if {![info exists colpar] || ![IsNumeric $colpar]} {
			ForceVal $tabed.message.e  "No overlap value given."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if {($typ == "Smc") || ($typ == "Slc") || ($typ == "Sjc")} {
		foreach fnam [$tabed.bot.icframe.l.list get 0 end] {
			if {![file exists $fnam]} {
				ForceVal $tabed.message.e  "$fnam is not a File."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			lappend ch_list $fnam
		}
		if {![info exists ch_list]} {
			ForceVal $tabed.message.e  "No values in Input column."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set typ [string range $typ 0 1]
	} else {
		if {![info exists chlist] || ([llength $chlist] <= 0)} {
			ForceVal $tabed.message.e  "No files have been selected on the workspace page."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ch_list $chlist
	}
	catch {unset ocl}
	foreach fnam $ch_list {
		if {$typ == "Sk"} {
			lappend ocl $fnam
			continue
		}
		if {$typ == "SK"} {
			set ftyp $pa($fnam,$evv(FTYP))
			if {!(($ftyp & $evv(MIXFILE)) && ($ftyp != $evv(WORDLIST)))} {
				ForceVal $tabed.message.e  "Not all the chosen files are mixfiles."
	 			$tabed.message.e config -bg $evv(EMPH)
				catch {unset ocl}
				return
			}
		} elseif {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			ForceVal $tabed.message.e  "Some of the chosen files are not soundfiles."
		 	$tabed.message.e config -bg $evv(EMPH)
			catch {unset ocl}
			return
		}
		switch -- $typ {
			"Sn" {
				lappend ocl $fnam
			}
			"Sl" -
			"SK" {
				lappend ocl $pa($fnam,$evv(DUR))
			}
			"Sj" { 
				lappend ocl $sum
				set sum [expr $sum + $pa($fnam,$evv(DUR)) - $colpar]	
			}
			"Sm" {
				if {![info exists pa($fnam,$evv(MAXREP))]} {
					catch {unset maxsamp_line}
					set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
					if [info exists maxsamp_missing] {
						Inf "maxsamp2$evv(EXEC) is not on your system.\nCannot search file for maximum sample in file."
						My_Release_to_Dialog $f
						Dlg_Dismiss $f
						return
					} elseif [ProgMissing $cmd "Cannot search file for maximum sample in file."] {
						set maxsamp_missing 1
						My_Release_to_Dialog $f
						Dlg_Dismiss $f
						return
					}
					lappend cmd $fnam
					if [catch {open "|$cmd"} CDPmaxId] {
						ForceVal $tabed.message.e "$CDPmaxId"
						$tabed.message.e config -bg $evv(EMPH)
						return
	   				} else {
	   					fileevent $CDPmaxId readable "Display_Maxsamp_Info_Ted"
					}
	 				vwait done_maxsamp
					if {![info exists maxsamp_line]} {
						Inf "Cannot Retrieve Maximum Sample Information For '$fnam'"
						catch {unset ocl}
						return
					}
					set pa($fnam,$evv(MAXSAMP)) [lindex $maxsamp_line 0]
					set pa($fnam,$evv(MAXLOC))  [lindex $maxsamp_line 1]
					set pa($fnam,$evv(MAXREP))  [lindex $maxsamp_line 2]
					lappend ocl $pa($fnam,$evv(MAXSAMP))
					catch {unset maxsamp_line}
				} else {
					lappend ocl $pa($fnam,$evv(MAXSAMP))
				}
			}
		}
	}
}

#---- Modify table of values

proc TabMod {colmode} {
	global record_temacro temacro tot_inlines incols col_ungapd_numeric colpar threshold col_infnam tabed evv
	global outcolcnt tot_outlines tabedit_ns tabedit_bind2 col_infnam col_tabname pa lmo CDPcolrun docol_OK wstk
	global couldbe_seq2 mu col_x

	set evv(BALSPLICE) 0.002
	set evv(TWO_BALSPLICES) [expr $evv(BALSPLICE) * 2.0]

	set thresh_val "@"
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	HaltCursCop

	set tb $tabed.bot
	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "MT"
	lappend lmo $col_ungapd_numeric $colmode
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <= 0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set nopar 0
	if {[string index $colmode 0] == "W"} {
		if [regexp {[AIPRTZair]} [string index $colmode 1]] {
			set nopar 1
		}
	} elseif {($colmode == "EX") || ($colmode == "Ex") || ($colmode == "co") || ($colmode == "be") \
		|| ($colmode == "SR") || ($colmode == "sr") || ($colmode == "Sr") || ($colmode == "sR") || ($colmode == "mf") || ($colmode == "mF") \
		|| ($colmode == "SV") || ($colmode == "sV") || ($colmode == "Sv") || ($colmode == "sM") || ($colmode == "Sm") \
		|| ($colmode == "ZR") || ($colmode == "ZV") || ($colmode == "ZM") || ($colmode == "xM") || ($colmode == "Xm") || ($colmode == "xm") \
		|| ($colmode == "Xv") || ($colmode == "ez") || ($colmode == "Tsm") || ($colmode == "SRM") || ($colmode == "rr") \
		|| ($colmode == "ii5")|| ($colmode == "ii6")} {
		set nopar 1
	}
	if {$colmode == "ge"} {
		if {![info exists colpar] || ![IsNumeric $colpar] || ($colpar < 10)} {
			ForceVal $tabed.message.e "Invalid or missing parameter MM in parameter 'N'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists threshold] || ![IsNumeric $threshold] || ($threshold <= 0.0)} {
			ForceVal $tabed.message.e "Invalid or missing parameter event dur in threshold"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {[string first ST $colmode] == 0} {
		if {[string length $colpar] <= 0} {
			ForceVal $tabed.message.e "Enter a string in 'N'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ki [string index $colmode 2]
		if {$ki} {
			if {[string length $threshold] > 0} {
				if {![regexp {^[0-9]+$} $threshold] || ($threshold < 1)} {
					ForceVal $tabed.message.e "Invalid selection column in 'threshold'"
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
		}
	} elseif {[string first SY $colmode] == 0} {
		if {[IsEven $incols] || ($incols < 3)} {
			ForceVal $tabed.message.e "Invalid number of columns in input data"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[string length $colpar] <= 0} {
			ForceVal $tabed.message.e "Enter a value in 'N'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![IsNumeric $colpar]} {
			ForceVal $tabed.message.e "Invalid value entered in 'N'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {[string first St $colmode] == 0} {
		if {[string length $threshold] <= 0} {
			ForceVal $tabed.message.e "Enter a column number in 'threshold'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![regexp {^[0-9]+$} $threshold] || ($threshold < 1)} {
			ForceVal $tabed.message.e "Invalid selection column in 'threshold'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {($colmode == "ii1") || ($colmode == "ii2")} {
		set intvals [split $colpar ","]
		set len [llength $intvals]
		if {$len == 0} {
			set msg "Invalid interval(s): use semitone counts (separate by commas)."
			ForceVal $tabed.message.e $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach intval $intvals {
			if {![regexp {^[0-9]+$} $intval]} {
				set msg "Invalid interval(s): use semitone counts (separate by commas)."
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	} elseif {($colmode == "ii3") || ($colmode == "ii4") || ($colmode == "ii8")} {
		if {![regexp {^[A-G\#]+$} $colpar]} {
			set msg "Invalid notes-string: use A-G and \"#\" only."
			ForceVal $tabed.message.e $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$colmode == "ii8"} {
			if {![info exists threshold] || ![regexp {^[0-9]+$} $threshold] || ($threshold < 1)} {
				set msg "Invalid number of notes in common (threshold value)."
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	} elseif {($colmode == "ii7")} {
		if {![file exists $colpar] || ![file isdirectory $colpar]} {
			set msg "Invalid directory name '$colpar'."
			ForceVal $tabed.message.e $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach ffnam [glob -nocomplain [file join $colpar *.*]] {
			set zext [GetTextfileExtension sndlist]
			if {[string match [file extension $ffnam] $zext]} {
				lappend ii7list $ffnam
			}
		}
		if {![info exists ii7list]} {
			ForceVal $tabed.message.e "No sndlist files in specified directory"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {!$nopar && ![string match $colpar Sq]} {
		if {![info exists colpar] || ![IsNumeric $colpar]} {
			ForceVal $tabed.message.e "Invalid or missing parameter 'N'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}	
	if {$colmode == "rr"} {
		if {![CreateColumnParams rr 3]} {
			return
		}
		if {($col_x(1) < 1) || ($col_x(1) > $incols)} {
			ForceVal $tabed.message.e "Column $col_x(1) does not exist"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {$colmode == "Tsm"} {
		if {![CreateColumnParams Tsm 2]} {
			return
		}
		if {($col_x(1) < 0) || ($col_x(1) > 127) || ($col_x(2) < 0) || ($col_x(2) > 127)} {
			ForceVal $tabed.message.e "At least 1 val not in MIDI range"
			$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {[expr $col_x(2) - $col_x(1)] <= 0} {
			ForceVal $tabed.message.e "Range too small or inverted"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set hifrq [MidiToHz $col_x(1)]
		set lofrq [MidiToHz $col_x(2)]
	}
	switch -- $colmode {
		"eqv" {
			if {$colpar > 1.0} {
				ForceVal $tabed.message.e "Quantisation value 'N' too large for normalised envelope file."
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set colmode "qv"
		}
		"eev" {
			if {[expr $pa($col_infnam,$evv(MAXBRK)) * $colpar] > 1.0} {
				ForceVal $tabed.message.e "Expansion/Contraction value 'N' too large for this normalised envelope file."
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set colmode "ev"
		}
		"elv" {
			if {$colpar < 0.0} {
				ForceVal $tabed.message.e "Limit value 'N' too low for normalised envelope file."
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {[info exists threshold] && ([string length $threshold] > 0)} {
				if {![IsNumeric $threshold]} {
					ForceVal $tabed.message.e "Invalid threshold value."
				 	$tabed.message.e config -bg $evv(EMPH)
					return
				} elseif {$threshold < 0.0 || $threshold > 1.0} {
					ForceVal $tabed.message.e "Lower Limit value 'threshold' out of range for a normalised envelope file."
				 	$tabed.message.e config -bg $evv(EMPH)
					return
				} elseif {$threshold > $colpar} {
					ForceVal $tabed.message.e "Threshold value cannot be greater than limit value."
				 	$tabed.message.e config -bg $evv(EMPH)
					return
				} else {
					append thresh_val $threshold
				}
			}
			set colmode "lv"
		}
		"elg" {
			if {$colpar < 0.0} {
				ForceVal $tabed.message.e "Limit value 'N' too low."
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$incols != 2} {
				set msg "Wrong number of columns in input table (2 only)."
				ForceVal $tabed.message.e  $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"lv" {
			if {[info exists threshold] && ([string length $threshold] > 0)} {
				if {![IsNumeric $threshold]} {
					ForceVal $tabed.message.e "Invalid threshold value."
				 	$tabed.message.e config -bg $evv(EMPH)
					return
				} elseif {$threshold > $colpar} {
					ForceVal $tabed.message.e "Threshold value cannot be greater than limit value."
				 	$tabed.message.e config -bg $evv(EMPH)
					return
				} else {
					append thresh_val $threshold
				}
			}
		}
		"ct" {
			if {$colpar >= $pa($col_infnam,$evv(DUR))} {
				ForceVal $tabed.message.e "Cut value is at or beyond end of file."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"ex" {
			if {$colpar <= $pa($col_infnam,$evv(DUR))} {
				ForceVal $tabed.message.e "Extend time value is before end of file."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"ef" -
		"et" -
		"qv" -
		"ev" -
		"ef" -
		"et" {
		}
		"qt" {
			if {$colpar > $pa($col_infnam,$evv(DUR))} {
				ForceVal $tabed.message.e "Quantisation unit exceeds file duration."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"Wc" {
			if {$colpar <= $evv(FLTERR)} {
				ForceVal $tabed.message.e "Expansion must be > 0"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"Wt" {
			if {$colpar < -96 || $colpar > 96} {
				ForceVal $tabed.message.e "Transposition is out of range (8 octaves)"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"WE" {
			if {$colpar <= 1.0 || $colpar > 8} {
				ForceVal $tabed.message.e "Expansion is out of range (>1 - 8)"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"Wm" {
			if {$colpar <= 0.1 || $colpar > 10} {
				ForceVal $tabed.message.e "Tempo change is out of range (0.1 - 10)"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"WM" {
			if {$colpar <= 0.1 || $colpar > 10} {
				ForceVal $tabed.message.e "Acceleration is out of range (0.1 - 10)"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {[info exists threshold] && [IsNumeric $threshold] && ($threshold > 0 || $threshold > 1.0)} {
				set thresh_val $threshold
				if {$threshold <= 0.0} {
					ForceVal $tabed.message.e "Accel-curve (in 'threshold') must be > 0.0"
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set zqz "@"
				append zqz $thresh_val
				set thresh_val $zqz
			} else {
				ForceVal $tabed.message.e "No value (or value out of range) for accel-curve given in 'threshold'"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"Wl" {
			if {$colpar <= 1.0 || $colpar > 256} {
				ForceVal $tabed.message.e "Loopcnt ($colpar) is out of range (2 - 256)"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {[info exists threshold] && [IsNumeric $threshold] && ($threshold > 0)} {
				set thresh_val $threshold
				if {$threshold <= 0.0} {
					ForceVal $tabed.message.e "Loop step (in 'threshold') must be > 0.0"
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set zqz "@"
				append zqz $thresh_val
				set thresh_val $zqz
			} else {
				ForceVal $tabed.message.e "No value (or value < 0) for loopstep given in 'threshold'"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"co" {
			set it $tabed.bot.itframe.l.list
			foreach line [$it get 0 end] {
				set line [string trim $line]
				set line [split $line]
				foreach item $line {
					lappend vals $item
				}
			}
			foreach {cotime coval} $vals {
				if {!([Flteq $coval 0.0] || [Flteq $coval 1.0])} {
					ForceVal $tabed.message.e "Option only works if all table values are either zero or 1."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				lappend cotimes $cotime
				lappend covals $coval
			}
		}
		"Qs" {
			if {$incols != 2} {
				ForceVal $tabed.message.e "Input is not a Frq breakpoint file."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$colpar <= 0.0} {
				ForceVal $tabed.message.e "Staccato duration, N, Invalid."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"be" {
			if {$incols < 2} {
				ForceVal $tabed.message.e "Input is not a balance file."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set it $tabed.bot.itframe.l.list
			foreach line [$it get 0 end] {
				set line [string trim $line]
				set line [split $line]
				set gottime 0
				catch {unset time}
				foreach item $line {
					if {![IsNumeric $item] || ($item < 0.0)} {
						ForceVal $tabed.message.e "Invalid value in balance file."
						$tabed.message.e config -bg $evv(EMPH)
						return
					}
					if {!$gottime} {
						if {[info exists time] && ($item <= $time)} {
							ForceVal $tabed.message.e "Times not in ascending order in Balance file."
							$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set time $item
						set gottime 1
					}
					lappend bevals $item
				}
			}
		}
		"EX" -
		"Ex" -
		"WZ" -
		"WT" -
		"Wa" -
		"Wr" -
		"Wi" -
		"WI" -
		"WP" -
		"WA" -
		"WR" {
		}
		"xm" -
		"Xm" -
		"xM" -
		"Xv" -
		"ZR" -
		"ZV" -
		"ZM" -
		"zm" -
		"SV" -
		"sV" -
		"Sv" -
		"sr" -
		"SR" -
		"SRM" -
		"Sr" -
		"sR" -
		"sM" -
		"Sm" -
		"mf" -
		"mF" -
		"Tsm" -
		"CR" -
		"eb" -
		"ii1" -
		"ii2" -
		"ii3" -
		"ii4" -
		"ii5" -
		"ii7" -
		"ii8" -
		"ez" {
			if {$incols != 2} {
				set msg "Wrong number of columns in input table (2 only)."
				ForceVal $tabed.message.e  $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"ii6" {
			if {$incols != 1} {
				set msg "Wrong number of columns in input table (1 only)."
				ForceVal $tabed.message.e  $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"S" -
		"Sk" {
			if {$incols != 2} {
				set msg "Wrong number of columns in input table (2 only)."
				ForceVal $tabed.message.e  $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$colpar <= 0.0} {
				set msg "Invalid time value in N."
				ForceVal $tabed.message.e  $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"Sq" {
			if {($colpar < 0) || ($colpar > 127)} {
				ForceVal $tabed.message.e "New sample pitch (N) must be in MIDI range"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"ii" {
			set j [$tb.itframe.l.list curselection]
			if {$j < 0} {
				ForceVal $tabed.message.e "No line selected with mouse"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$j < 1} {
				ForceVal $tabed.message.e "Invalid line selected with mouse"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		"rr" -
		"ST0" -
		"ST1" -
		"ST2" -
		"ST3" -
		"St0" -
		"St1" -
		"SY1" -
		"SY2" -
		"SY3" -
		"SY4" -
		"SY5" {
			;#
		}
		"ge" {
			if {$incols != 2} {
				set msg "Wrong number of columns in input table (2 only)."
				ForceVal $tabed.message.e  $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set it $tabed.bot.itframe.l.list
			set linecnt 1
			foreach line [$it get 0 end] {
				string trim $line
				set line [split $line]
				set cnt 1
				foreach item $line {
					string trim $item
					if {[string length $item] > 0} {
						if {$cnt > 0} {
							if {$item != $linecnt} {
								set msg "Invalid beat number (should be $linecnt) at line $linecnt."
								ForceVal $tabed.message.e  $msg
	 							$tabed.message.e config -bg $evv(EMPH)
								return
							}
						} else {
							if {($item != 1) && ($item != 0)} {
								set msg "Invalid on/off value (0/1) at line $linecnt."
								ForceVal $tabed.message.e  $msg
	 							$tabed.message.e config -bg $evv(EMPH)
								return
							}
							lappend sw_itches $item
						}
					}
					set cnt [expr -$cnt]
				}
				incr linecnt
			}
			if {![info exists sw_itches]} {
				set msg "No valid data in table."
				ForceVal $tabed.message.e  $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		default {
			ErrShow "Invalid mode ($colmode) encountered"
			return
		}
	}
	if {[string first "SY" $colmode] == 0} {
		set syoption [string range $colmode 2 end]
		DisableOutputTableOptions 1
		if {$tot_inlines <= 0} {
			ForceVal $tabed.message.e "No input table"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set it $tabed.bot.itframe.l.list
		catch {unset outlines}
		foreach line [$it get 0 end] {
			catch {unset outline}
			string trim $line
			set line [split $line]
			set knt 0
			foreach item $line {
				string trim $item
				if {[string length $item] < 0} {
					continue
				}
				if {[IsEven $knt]} {
					if {$knt > 0} {
						switch -- $syoption {
							1 {		;#	Replace level
								set item $colpar
							}
							2 {		;#	Add to level
								set item [expr $item + $colpar]
							}
							3 {		;#	Multiply level
								set item [expr $item * $colpar]
							}
						}
					}
				} else {
					switch -- $syoption {
						4 {		;#	Add to partial
							set item [expr $item + $colpar]
						}
						5 {		;#	Multiply partial
							set item [expr $item * $colpar]
						}
					}
				}
				lappend outline $item
				incr knt
			}
			lappend outlines $outline
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach line $outlines {
			$ol insert end $line
		}
		if {[WriteOutputTable $evv(LINECNT_NOT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {($colmode == "EX") || ($colmode == "Ex")} {
		DisableOutputTableOptions 1
		if {$tot_inlines <= 0} {
			ForceVal $tabed.message.e "No input table"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set it $tabed.bot.itframe.l.list
		foreach line [$it get 0 end] {
			string trim $line
			set line [split $line]
			foreach item $line {
				string trim $item
				if {[string length $item] > 0} {
					lappend tab $item
				}
			}
		}
		set n 0
		foreach {time val} $tab {
			if {($n > 0) && ![Flteq $val $lastval]} {
				set diff [expr double($time) - double($lasttime)]
				set timestep [expr double($diff)/8.0]
				set diff [expr double($val) - double($lastval)]
				set etime(0) $lasttime
				set m 1
				set j 0
				while {$m < 8} {
					set etime($m) [expr $etime($j) + $timestep]
					incr m
					incr j
				}
				if {($colmode == "EX")} {
					set k 2.0
				} else {
					set k 1.0
				}
				if {$val > $lastval} {
					set eval(4) [expr (($diff/3.0) * $k) + $lastval]
					set thisdiff [expr $eval(4) - $lastval]
					set eval(2) [expr (($thisdiff/3.0) * $k) + $lastval]
					set thisdiff [expr $eval(2) - $lastval]
					set eval(1) [expr (($thisdiff/3.0) * $k) + $lastval]
					set thisdiff [expr $val - $eval(4)]
					set eval(6) [expr (($thisdiff/3.0) * $k) + $eval(4)]
					set thisdiff [expr $val - $eval(6)]
					set eval(7) [expr (($thisdiff/3.0) * $k) + $eval(6)]
					set thisdiff [expr $eval(6) - $eval(4)]
					set eval(5) [expr (($thisdiff/3.0) * $k) + $eval(4)]
					set thisdiff [expr $eval(4) - $eval(2)]
					set eval(3) [expr (($thisdiff/3.0) * $k) + $eval(2)]
				} else {
					set diff [expr -$diff]
					set eval(4) [expr (($diff/3.0) * $k) + $val]
					set thisdiff [expr $eval(4) - $val]
					set eval(6) [expr (($thisdiff/3.0) * $k) + $val]
					set thisdiff [expr $eval(6) - $val]
					set eval(7) [expr (($thisdiff/3.0) * $k) + $val]
					set thisdiff [expr $lastval - $eval(4)]
					set eval(2) [expr (($thisdiff/3.0) * $k) + $eval(4)]
					set thisdiff [expr $lastval - $eval(2)]
					set eval(1) [expr (($thisdiff/3.0) * $k) + $eval(2)]
					set thisdiff [expr $eval(4) - $eval(6)]
					set eval(5) [expr (($thisdiff/3.0) * $k) + $eval(6)]
					set thisdiff [expr $eval(2) - $eval(4)]
					set eval(3) [expr (($thisdiff/3.0) * $k) + $eval(4)]
				}
				set m 1
				while {$m < 8} {
					lappend nutab $etime($m) $eval($m)
					incr m
				}
			}
			lappend nutab $time $val
			set lasttime $time
			set lastval $val
			incr n		
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach {time val} $nutab {
			set outline $time
			lappend outline $val
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "ii"} {
		DisableOutputTableOptions 1
		set thisline [$tb.itframe.l.list get 0]
		set accenttime [lindex $thisline 1]
		set goalpos [$tb.itframe.l.list curselection]
		set goalline [$tb.itframe.l.list get $goalpos]
		set current_time [lindex $goalline 1]
		set diff [expr $accenttime - $current_time]
		catch {unset outlines}
		lappend outlines [$tb.itframe.l.list get 0]
		foreach thisline [$tb.itframe.l.list get 1 end] {
			set thistime [lindex $thisline 1]
			set thistime [expr $thistime + double($diff)]
			set thisline [lreplace $thisline 1 1 $thistime]
			lappend outlines $thisline
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach line $outlines {
			$ol insert end $line
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {[string match "ii*" $colmode]} {

		if {($colmode == "ii4") || ($colmode == "ii8")} {
			set note_set [ExtractNoteSet $colpar]
		}
		catch {unset outlines}
		foreach line [$tabed.bot.itframe.l.list get 0 end] {
			set origline $line
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			catch {unset nuline}
			foreach item $line {
				set hstr [string trim $item]
				if {[string length $hstr] <= 0} {
					continue
				}
				break
			}
			if {![info exists hstr]} {
				if {$colmode == "ii6"} {
					set msg "Invalid data found (should be filename)."
				} else {
					set msg "Invalid data found (should be pitch string and count)."
				}
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {($colmode != "ii6") && ![IsHFstr $hstr]} {
				set msg "Invalid data found (should be HF-name count)."
			}
			lappend hstrs $hstr
			lappend origlines $origline
		}
		switch -- $colmode {
			"ii1" -
			"ii2" { set msg "No HF contains these intervals." }
			"ii3" -
			"ii4" -
			"ii8" { set msg "No HF contains these notes." }
			"ii5" { set msg "Failed to convert HF name to associated sndlist name." }
			"ii6" { set msg "Not all Sndlist names are valid HF-set names." }
		}
		foreach hstr $hstrs origline $origlines {
			switch -- $colmode {
				"ii1" {
					if {[ContainsIntervals $hstr $intvals 1]} {
						lappend outlines $origline
					}
				}
				"ii2" {
					if {[ContainsIntervals $hstr $intvals 0]} {
						lappend outlines $origline
					}
				}
				"ii3" {
					if {[string first $colpar $hstr] >= 0} {
						lappend outlines $origline
					}
				}
				"ii4" {
					set in_note_set [ExtractNoteSet $hstr]
					set OK 1
					foreach nott $note_set {
						if {[lsearch $in_note_set $nott] < 0} {
							set OK 0
							break
						}
					}
					if {$OK} {
						lappend outlines $origline
					}
				}
				"ii8" {
					set in_note_set [ExtractNoteSet $hstr]
					set hascnt 0
					foreach nott $note_set {
						if {[lsearch $in_note_set $nott] >= 0} {
							incr hascnt
						}
					}
					if {$hascnt >= $threshold} {
						lappend outlines $origline
					}
				}
				"ii5" {
					set hstr [SharpToAscii $hstr]
					if {[string length $hstr] <= 0} {
						catch {unset outlines}
						break
					}
					lappend outlines $hstr
				}
				"ii6" {
					set hstr [AsciiToSharp $hstr]
					if {[string length $hstr] <= 0} {
						catch {unset outlines}
						break
					}
					lappend outlines $hstr
				}
				"ii7" {
					set hstr [SharpToAscii $hstr]
					if {[string length $hstr] <= 0} {
						catch {unset outlines}
						break
					}
					set endchar [string index $hstr end]
					set gotit 0
					foreach ffnam $ii7list {
						set origffnam $ffnam
						set ffnam [string tolower [file rootname [file tail $ffnam]]]
						if {[string match $ffnam $hstr]} {					;#	name = e.g. aashc OR abcsh
							lappend outlines $origffnam
							set gotit 1
							break
						}
						set k [string first $hstr $ffnam]					
						if {$k == 0} {										;#	name = e.g. aashcETC OR abcshETC
							set k [string length $hstr]
							set thischar [string index $ffnam $k]
							if {[string match $endchar "h"]} {
								if {![regexp {^[A-Ga-g]$} $thischar]} {		;#	name = e.g. abcshETC and NOT e.g. abcshd
									lappend outlines $origffnam
									set gotit 1
									break
								}
							} elseif {![regexp {^[A-Ga-gs]$} $thischar]} {	;#	name = e.g. aashcETC and NOT e.g. aashcsh OR aashcd
								lappend outlines [string tolower $origffnam]
								set gotit 1
								break
							}
						}
					}
					if {!$gotit} {
						set msg "At least one HF does not correspond to an existing sndlist."
						ForceVal $tabed.message.e $msg
	 					$tabed.message.e config -bg $evv(EMPH)
					}
				}
			}
		}
		if {![info exists outlines]} {
			ForceVal $tabed.message.e $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach outline $outlines {
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "ge"} {
		catch {unset outlines}
		set timestep [expr 60.0/$colpar]
		set time $threshold
		foreach swi $sw_itches {
			if {$time <= $threshold} {
				if {$threshold != 0.0} {
					set outline [list 0.0 $swi]
					lappend outlines $outline
				}
				set outline [list [DecPlaces $time 4] $swi]
				lappend outlines $outline
				set lastswi $swi
			} else {
				if {$swi != $lastswi} {
					set pretime [expr $time - 0.005]
					set outline [list [DecPlaces $pretime 4] $lastswi]
					lappend outlines $outline
					set outline [list [DecPlaces $time 4] $swi]
					lappend outlines $outline
				}
				set lastswi $swi
			}
			set time [expr $time + $timestep]
		}
		set outline [list [DecPlaces $time 4] $lastswi]
		lappend outlines $outline
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach outline $outlines {
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {[string first ST $colmode] == 0} {
		set comp [split $colpar ","]
		set ki [string index $colmode 2]
		set fromcol -1
		if {$ki} {
			if {[string length $threshold] >= 0} {
				set fromcol [expr $threshold - 1]
			}
		}
		set it $tabed.bot.itframe.l.list
		DisableOutputTableOptions 1
		catch {unset outlines}
		foreach line [$it get 0 end] {
			catch {unset nuline}
			set origline $line
			string trim $line
			set line [split $line]
			set nulinecnt 0
			set got 0
			foreach item $line {
				string trim $item
				if {[string length $item] > 0} {
					set ismatch 1
					foreach compitem $comp {
						if {[string first $compitem $item] < 0} {
							set ismatch 0
						}
					}
					if {$ismatch} {
						if {$fromcol < 0} {
							lappend outlines $origline
							break
						} else {
							set got 1
						}
					}
					lappend nuline $item
					incr nulinecnt
				}
			}
			if {$got && ($nulinecnt > $fromcol)} {
				set nuitem [lindex $nuline $fromcol]
				if {$ki > 1} {
					set nuitem [ConverDataNameToCDPFileFormat $nuitem]
				}
				lappend outlines $nuitem
			}
		}
		if {![info exists outlines]} {
			ForceVal $tabed.message.e "No lines selected"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach outline $outlines {
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		if {$ki == 3} {
			set	col_tabname [ReplaceCommas $colpar]
		}
		return
	} elseif {[string first St $colmode] == 0} {
		set ki [string index $colmode 2]
		set fromcol $threshold
		set it $tabed.bot.itframe.l.list
		DisableOutputTableOptions 1
		catch {unset outlines}
		set gotitems {}
		set contents {}
		set filecnt 0
		foreach zfnam [$it get 0 end] {
			if {![file exists $zfnam]} {
				ForceVal $tabed.message.e "File $zfnam does not exist"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if [catch {open $zfnam "r"} zit] {
				ForceVal $tabed.message.e "Cannot open file $zfnam"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				set itemcnt 0
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					incr itemcnt
					if {$filecnt == 0} {
						if {$itemcnt == $fromcol} {
							if {$ki} {
								set item [ConverDataNameToCDPFileFormat $item]
							}
							lappend contents $item
						}
					} else {

						if {[lsearch $gotitems $item] < 0} {
							lappend gotitems $item
						}
					}
				}
			}
			incr filecnt
		}
		catch {unset outlines}
		foreach item $contents {
			if {[lsearch $gotitems $item] < 0} {
				lappend outlines $item
			}
		}
		if {![info exists outlines]} {
			ForceVal $tabed.message.e "All items are in first file"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach outline $outlines {
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		if {$ki == 3} {
			set	col_tabname [ReplaceCommas $colpar]
		}
		return
	} elseif {$colmode == "elg"} {
		DisableOutputTableOptions 1
		if {$tot_inlines <= 0} {
			ForceVal $tabed.message.e "No input table"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set it $tabed.bot.itframe.l.list
		foreach line [$it get 0 end] {
			string trim $line
			set line [split $line]
			foreach item $line {
				string trim $item
				if {[string length $item] > 0} {
					lappend tab $item
				}
			}
		}
		foreach {time val} $tab {
			if {$val < $colpar} {
				set val 0.000000
			}
			lappend newvals $val
			lappend newtimes $time
		}
		set len [llength $newvals]
		if {$len >= 3} {
			incr len -2
			set n 0
			while {$n < $len} {
				set m $n
				incr m
				set k $m
				incr k
				if {[Flteq [lindex $newvals $n] [lindex $newvals $m]] \
				&&  [Flteq [lindex $newvals $m] [lindex $newvals $k]]} {
					set newvals  [lreplace $newvals  $m $m]
					set newtimes [lreplace $newtimes $m $m]
					incr len -1
					incr n -1
				}
				incr n
			}
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach time $newtimes val $newvals {
			set outline $time
			lappend outline $val
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "S"} {
		DisableOutputTableOptions 1
		if {$tot_inlines <= 0} {
			ForceVal $tabed.message.e "No input table"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set it $tabed.bot.itframe.l.list
		foreach line [$it get 0 end] {
			string trim $line
			set line [split $line]
			foreach item $line {
				string trim $item
				if {[string length $item] > 0} {
					lappend tab $item
				}
			}
		}
		set len [llength $tab]
		set n 0
		set k 4
		while {$k < $len} {
			set starttime [lindex $tab $n]
			set startval  [lindex $tab [expr $n + 1]]
			set endtime   [lindex $tab $k]
			set endval    [lindex $tab [expr $k + 1]]
			while {[expr $endtime - $starttime] < $colpar} {
				set j $n
				while {$j < [expr $k - 2]} {
					set startval [lindex $tab [expr $j + 1]]
					if {$startval == $endval} {
						set tab [lreplace $tab [expr $j + 2] [expr $k - 1]]
						set dist [expr $k - $j - 2]
						set len [expr $len - $dist]
						set k   [expr $k - $dist]
						break
					}
					incr j 2
				}
				incr k 2
				if {$k >= $len} {
					break
				}
				set endtime   [lindex $tab $k]
				set endval    [lindex $tab [expr $k + 1]]
			}
			incr k 2
			set n [expr $k - 4]
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach {time val} $tab {
			set outline $time
			lappend outline $val
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "Sk"} {
		DisableOutputTableOptions 1
		if {$tot_inlines <= 0} {
			ForceVal $tabed.message.e "No input table"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set it $tabed.bot.itframe.l.list
		catch {unset times}
		catch {unset vals}
		foreach line [$it get 0 end] {
			set line [string trim $line]
			set line [split $line]
			lappend times [lindex $line 0]
			lappend vals  [lindex $line 1]
		}
		if {[llength $times] < 3} {
			ForceVal $tabed.message.e "Too few times to do smoothing."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set minrise [expr $colpar * $evv(MS_TO_SECS)]
		set penutime 0
		set lasttime [lindex $times 0]
		set lastval  [lindex $vals 0]
		set len [llength $times]
		set last 0
		set this 1
		set next 2
		while {$this < $len} {
			set time [lindex $times $this]
			set val  [lindex $vals  $this]
			set valdiff [expr $val - $lastval]
			if {$valdiff != 0.0} {
				set timediff [expr $time - $lasttime]
				if {$timediff <= $minrise} {
					if {$valdiff > 0} {
						set nulasttime [expr $time - $minrise]
						if {$nulasttime <= $penutime} {
							set nutime [expr $lasttime + $minrise]
							if {$next < $len} {
								set nexttime [lindex $times $next]
								if {$nutime >= $nexttime} {
									ForceVal $tabed.message.e "Failed to move point at $time"
	 								$tabed.message.e config -bg $evv(EMPH)
									return
								}
							}
							set times [lreplace $times $this $this $nutime]
						} else {
							set times [lreplace $times $last $last $nulasttime]
						}
					} else {
						set nutime [expr $lasttime + $minrise]
						if {$next < $len} {
							set nexttime [lindex $times $next]
							if {$nutime >= $nexttime} {
								set nulasttime [expr $time - $minrise]
								if {$nulasttime <= $penutime} {
									ForceVal $tabed.message.e "Failed to move point at $time"
	 								$tabed.message.e config -bg $evv(EMPH)
									return
								} else {
									set times [lreplace $times $last $last $nulasttime]
								}						
							} else {
								set times [lreplace $times $this $this $nutime]
							}
						} else {
							set times [lreplace $times $this $this $nutime]
						}
					}
				}
			}
			set penutime [lindex $times $last]
			set lasttime [lindex $times $this]
			set lastval	$val
			incr last
			incr this
			incr next
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach time $times val $vals {
			set outline $time
			lappend outline $val
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_NOT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "Sq"} {
		DisableOutputTableOptions 1
		if {$tot_inlines < 2} {
			set line "Too few lines to convert sequence."
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set multi_seq 0
		catch {unset nuline}
		catch {unset seq}
		set it $tabed.bot.itframe.l.list
		set cnt0 0
		set line [$it get 0]
		string trim $line
		set line [split $line]
		foreach item $line {
			string trim $item
			if {[string length $item] > 0} {
				incr cnt0
				lappend nuline $item
			}
		}
		if [info exists nuline] {
			lappend seq $nuline
			unset nuline
		}
		set cnt1 0
		set line [$it get 1]
		string trim $line
		set line [split $line]
		foreach item $line {
			string trim $item
			if {[string length $item] > 0} {
				incr cnt1
				lappend nuline $item
			}
		}
		if [info exists nuline] {
			lappend seq $nuline
			unset nuline
		}
		if {$cnt0 == $cnt1} {
			set msg "Is This A Sequence File For Multiple Sounds?"
			set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "yes"} {
				set multi_seq 1
			}
		} else {
			set multi_seq 1
		}
		foreach line [$it get 2 end] {
			string trim $line
			set line [split $line]
			foreach item $line {
				string trim $item
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			if [info exists nuline] {
				lappend seq $nuline
				unset nuline
			}
		}
		if {$multi_seq} {
			set midi $colpar
			foreach line [lrange $seq 1 end] {
				set time [lindex $line 1]
				set trns [expr [lindex $line 2] - $midi]
				set loud [lindex $line 3]
				set nuline [list $time $trns $loud]
				lappend nulines $nuline
			}
		} else {
			if {($threshold < 0) || ($threshold > 127)} {
				ForceVal $tabed.message.e "Old sample pitch (threshold) must be in MIDI range"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set numidi $colpar
			set oldmidi $threshold

			set midigap [expr $oldmidi - $numidi]
			catch {unset times}
			foreach line $seq {
				set time [lindex $line 0]
				set trns [lindex $line 1]
				set loud [lindex $line 2]
				set midi [expr $oldmidi + $trns]
				set nuline [list 1 $time $midi $loud]
				lappend nulines $nuline
				lappend times $time
			}
			catch {unset durs}
			set lasttime [lindex $times 0]
			foreach time [lrange $times 1 end] {
				set dur [expr $time - $lasttime]
				lappend durs $dur
				set lasttime $time
			}
			lappend durs $dur
			set n 0
			set len [llength $nulines]
			while {$n < $len} {
				set line [lindex $nulines $n]
				set dur  [lindex $durs $n]
				lappend line $dur
				lappend xlines $line
				incr n
			}
			unset nulines
			set topline [list $numidi]
			lappend nulines $topline
			foreach line $xlines {
				lappend nulines $line
			}
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach line $nulines {
			$ol insert end $line
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {($colmode == "ez") || ($colmode == "eb")} {
		DisableOutputTableOptions 1
		if {$tot_inlines <= 0} {
			ForceVal $tabed.message.e "No input table"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set it $tabed.bot.itframe.l.list
		foreach line [$it get 0 end] {
			string trim $line
			set line [split $line]
			foreach item $line {
				string trim $item
				if {[string length $item] > 0} {
					lappend tab $item
				}
			}
		}
		if {$colmode == "ez"} {
			foreach {time val} $tab {
				if {$val < 0} {
					set val 0
				} else {
					set val 1
				}
				lappend newvals $val
				lappend newtimes $time
			}
		} else {
			set OK 0
			foreach {time val} $tab {
				if {$val < $colpar} {
					set val 0.000000
					set OK 1
				}
				lappend newvals $val
				lappend newtimes $time
			}
			if {!$OK} {
				ForceVal $tabed.message.e "Gate has not changed the envelope"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		set len [llength $newvals]		;#	SQUEEZE OUT VALS DUPLICATED MORE THAN TWICE
		if {$len >= 3} {
			incr len -2
			set n 0
			while {$n < $len} {
				set m $n
				incr m
				set k $m
				incr k
				if {[Flteq [lindex $newvals $n] [lindex $newvals $m]] \
				&&  [Flteq [lindex $newvals $m] [lindex $newvals $k]]} {
					set newvals  [lreplace $newvals  $m $m]
					set newtimes [lreplace $newtimes $m $m]
					incr len -1
					incr n -1
				}
				incr n
			}
		}
		unset tab
		foreach time $newtimes val $newvals {
			lappend tab $time $val
		}
		if {$colmode == "eb"} {
			set cnt 0
			catch {unset lasttime}
			foreach {time val} $tab {		;#	CONVERT 0.0/>0.0 TO 0/1
				if {$cnt == 0} {			;#	SQUEEZE OUT ALL BUT START AND END TIMES OF EACH ON (OR OFF) SEGMENT
					if {$val > 0.0} {
						set val 1
						set ison 1
					} else {
						set val 0
						set ison 0
					}
					lappend nuvals $time $val
				} elseif {$ison} {
					if {$val > 0.0} {
						set lasttime $time
					} else {
						if {[info exists lasttime]} {
							lappend nuvals $lasttime 1
							unset lasttime
						}
						lappend nuvals $time 0
						set ison 0
					}
				} else {
					if {[Flteq $val 0.0]} {
						set lasttime $time
					} else {
						if {[info exists lasttime]} {
							lappend nuvals $lasttime 0
							unset lasttime
						}
						lappend nuvals $time 1
						set ison 1
					}
				}
				incr cnt
			}
			if {[info exists lasttime]} {
				if {[Flteq $val 0.0]} {
					lappend nuvals $lasttime 0
				} else {
					lappend nuvals $lasttime 1
				}
			}
		} else {
			set nuvals $tab
		}
		unset tab
		set srctab_cnt 0
		set outtab_cnt 0
		set lasttime -1 ;# DUMMY
		set lastval  -1 ;# DUMMY
		foreach {time val} $nuvals {	;#	ADD SPLICES, TRAKING CARE TO ELIMINATE TOO-SHORT SEGS
			switch -- $srctab_cnt {
				0 {	;#
				}
				2 {																		;#	2nd Val in table
					if {$val != $lastval} {
						if {[expr $time - $lasttime] <= $evv(BALSPLICE)} {
							set tab [lreplace $tab 1 1 $val]							;#	Eliminate Too Short Seg
						} else {
							set done 0
							if {[llength $nuvals] >= 6} {								;#	If Enough Entries In Table
								set nextval [lindex $nuvals 5]
								if {($val == 1) && ($nextval == 0) && ([expr $time - $lasttime] >= $evv(TWO_BALSPLICES))} {
									set thistime [expr $time - $evv(TWO_BALSPLICES)]	;#	If timestep > Splicelen, + 'Cover'
									lappend tab $thistime $lastval						;#  Move previous off (startsplice) forward
									set time [expr $time - $evv(BALSPLICE)]				;#	Move ON Event (start) back...
									set done 1											;#  to 'Cover' Point Singularity
								}
							} 
							if {!$done} {
								set thistime [expr $time - $evv(BALSPLICE)]				;#	Else, move ON Event (start) back as far as pos
								lappend tab $thistime $lastval							;#	to 'Cover' Point Singularity
							}
							set lasttime $thistime
							incr outtab_cnt 2
						}
					}
				}																		;#	3rd Val onwards
				default {																		
					if {$val != $lastval} {
						if {$lastval == 0} {											;#	If signal switches ON
							set splicestart [expr $time - $evv(BALSPLICE)]
							if {$lalastval == $lastval} {								;#	If previous OFF seg has start+end
								if {[expr $time - $lalasttime] <= $evv(BALSPLICE)} {
									set k $outtab_cnt									;#	If Whole OFFseg Is Too Short For Splice
									incr k -1											;#	Eliminate Both OFFSeg Entries
									set tab [lreplace $tab $k $k $val]
									set lastval $val
									incr k -2									
									set tab [lreplace $tab $k $k $val]
									set lalastval $val
								} else {												;#  But If OFFSeg Long Enough
									set k [expr $srctab_cnt + 3]
									if {$k < [llength $nuvals]} {						;#	If Not at Tab End
										set nextval [lindex $nuvals $k]
										incr k -1
										set nexttime [lindex $nuvals $k]
										if {$nextval == 0} {							;#	If Current ON is a Singularity
											set step [expr $time - $lasttime]			;#	If pos, Convert To 2 ONs that 'cover' point
											if {$step > $evv(BALSPLICE)} {
												set mintime_of_1_event   [expr $time - $evv(BALSPLICE)]
												set min_endtime_upsplice [expr $lasttime + $evv(BALSPLICE)]
												set backstep $evv(BALSPLICE)			;#	If time for both full splice and 'Cover'
												if {$mintime_of_1_event > $min_endtime_upsplice} {
													set lasttime [expt $time - $evv(TWO_BALSPLICES)]
													set k $outtab_cnt
													incr k 2							;#	Move Previous OFFend (splicestart) Forward
													set tab [lreplace $tab $k $k $lasttime]
												} else {
													set backstep [expr $backstep - ($min_endtime_upsplice - $mintime_of_1_event)]

												}
												set lalastval $lastval					;#	Convert Singularity to 2 ONs
												set lalasttime $lasttime				;#	by inserting New ON, pre current time
												set lasttime [expr $time - $backstep]
												set lastval 1
												lappend tab $lasttime $lastval
												incr outtab_cnt 2						;#	and if enough Space after orig ON 
																						;#	Advance Orig ON to 'cover' end of singularity
												if {[expr $nexttime - $time] > $evv(BALSPLICE)} {
													set maxtime_dnsplice_start [expr $nexttime - $evv(BALSPLICE)]
													set maxtime_of_1_event [expr $time + $evv(BALSPLICE)]
													if {$maxtime_of_1_event < $maxtime_dnsplice_start} {
														set maxtime_of_1_event $maxtime_dnsplice_start
													}
													set time $maxtime_of_1_event
												}
											}
										}
									} else {											;#	If At End Of Table
										set k $outtab_cnt
										incr k -2										;#	Move OFFSeg End, To latest Splicestart pos
										set tab [lreplace $tab $k $k $splicestart]
										set lasttime $splicestart
									}
								}														
							} else {													;# Previous OFFseg is Singularity
								if {[expr $time - $lalasttime] <= $evv(TWO_BALSPLICES)} {
									set k $outtab_cnt									;#	If too short for 2 splices
									incr k -1											;#	Eliminate
									set tab [lreplace $tab $k $k $val]					
									set lastval $val
								} else {												;#	Else
									set spliceend [expr $lalasttime + $evv(BALSPLICE)]	;#	Move Start OFFSeg To Spliceend from prev ON
									set k $outtab_cnt							
									incr k -2
									set tab [lreplace $tab $k $k $spliceend]
									if {[expr $time - $spliceend] > $evv(BALSPLICE)} {	;#	If enough time, we can
										set k $srctab_cnt								;#	convert OFF singularity to 2 OFF points
										incr k 2
										if {[llength $nuvals] > $k} {					;#  If Not At Table End
											set nexttime [lindex $nuvals $k]			;#	Look at point ahead
											incr k 1
											set nextval [lindex $nuvals $k]
											if {$nextval == 0} {						;# If zero, Current point is an ON singularity
												set splicestart	[expr $time - $evv(TWO_BALSPLICES)]
												if {$spliceend >= $splicestart} {		;#	Set upsplice start
													set splicestart $spliceend			;#	to allow space for ON singularity
												}										;#	to also be expanded to 2 ON points
												lappend tab $splicestart $lastval		
												set lalasttime $spliceend
												set lalastval  $lastval					;#	Insert 2nd OFF point
												set lasttime   $splicestart
												incr outtab_cnt 2						;#	Move ON back to 'Cover' Singularity start
												set time [ expr $splicestart + $evv(BALSPLICE)]
												if {[expr $nexttime - $time] > $evv(BALSPLICE)} {
													lappend tab $time $val				;#	If sufficent time, expand ON Singularity
													set lalasttime $lasttime			;#	to 2 ON points
													set lalastval  $lastval				
													set lasttime   $time
													set lastval		$val
													incr outtab_cnt 2					;#	moving 2nd ON point as far forward as pos
													set time [expr $nexttime - $evv(BALSPLICE)]
												}
												set done 1
											}
										}
									}
								}
							}
						} else {														;#	Switching ON
							set splicestart [expr $time - $evv(BALSPLICE)]
							if {$lalastval == $lastval} {								;#	Previous OFFseg has Start & End
								if {[expr $time - $lalasttime] <= $evv(BALSPLICE)} {
									set k $outtab_cnt									;#	If Previous OFF Too Short For Splice
									incr k -1											;#	Eliminate BOTH OFF points
									set tab [lreplace $tab $k $k $val]
									set lastval $val
									incr k -2									
									set tab [lreplace $tab $k $k $val]
									set lalastval $val
								} else {												;#  Previous OFFseg long enough
									if {[expr $time - $lasttime] > $evv(BALSPLICE)} {
										set time [expr $lasttime + $evv(BALSPLICE)]		;#	If poss, advance upsplice start
									}														
								}
							} else {													;#	Previous OFFseg is singularity
								if {[expr $time - $lalasttime] <= $evv(TWO_BALSPLICES)} {
									set k $outtab_cnt
									incr k -1
									set tab [lreplace $tab $k $k $val]					;#	If too short, eliminate
									set lastval $val
								} else {												;#	Else
									set lalasttime [expr $lalasttime + $evv(BALSPLICE)]
									set lalastval 1										;#	Replace Single OFF by 2 Points
									set k $outtab_cnt
									incr k -2
									set tab [lreplace $tab $k $k $lalasttime]
									incr k
									set tab [lreplace $tab $k $k $lalastval]
									set lasttime [expr $time - $evv(BALSPLICE)]
									set lastval 1
									lappend tab $lasttime $lastval
									incr outtab_cnt 2
								}
							}
						}
					}
				}
			}
			lappend tab $time $val
			incr outtab_cnt 2
			set lalasttime $lasttime
			set lalastval  $lastval
			set lasttime $time
			set lastval  $val
			incr srctab_cnt 2
		}
		unset nuvals
		set cnt 0
		foreach {time val} $tab {	;#	SQUEEZE OUT ALL BUT START AND END TIMES OF EACH ON (OR OFF) SEGMENT
			if {$cnt == 0} {
				if {$val == 1} {
					set ison 1
				} else {
					set ison 0
				}
				lappend nuvals $time $val
			} elseif {$ison} {
				if {$val == 1} {
					set lasttime $time
				} else {
					lappend nuvals $lasttime 1
					lappend nuvals $time 0
					set ison 0
				}
			} else {
				if {$val == 0} {
					set lasttime $time
				} else {
					lappend nuvals $lasttime 0
					lappend nuvals $time 1
					set ison 1
				}
			}
			incr cnt
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach {time val} $nuvals {
			set outline $time
			lappend outline $val
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "rr"} {
		DisableOutputTableOptions 1
		if {$tot_inlines <= 0} {
			ForceVal $tabed.message.e "No input table"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set it $tabed.bot.itframe.l.list
		foreach line [$it get 0 end] {
			string trim $line
			set line [split $line]
			set cnt 0
			catch {unset tab}
			set itemOK 0
			foreach item $line {
				string trim $item
				if {[string length $item] <= 0} {
					continue
				}
				lappend tab $item
				incr cnt
				if {$cnt == $col_x(1)} {
					if {![IsNumeric $item]} {
						ForceVal $tabed.message.e "Not all entries in column $col_x(1) are numeric"
						$tabed.message.e config -bg $evv(EMPH)
						return
					}
					if {($item >= $col_x(2)) && ($item <= $col_x(3)) } {
						set itemOK 1
					}
				}
			}
			if {$itemOK} {
				lappend outlines $tab
			}
		}
		if {![info exists outlines]} {
			ForceVal $tabed.message.e "No entries lie within the specified range"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach line $outlines {
			$ol insert end $line
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {($colmode == "SR") || ($colmode == "sr") || ($colmode == "Sr") || ($colmode == "sR") \
	|| ($colmode == "SV") || ($colmode == "sV") || ($colmode == "Sv") || ($colmode == "sM") || ($colmode == "Sm") \
	|| ($colmode == "ZR") || ($colmode == "ZV") || ($colmode == "xM") || ($colmode == "Xm") || ($colmode == "xm") \
	|| ($colmode == "Xv") || ($colmode == "Tsm") || ($colmode == "SRM")} {
		DisableOutputTableOptions 1
		set ccnt 0
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nulines $item
				}
			}
		}
		if {($colmode == "Sm") || ($colmode == "sM") || ($colmode == "xM") || ($colmode == "Xm")} {	;#	MIDI DATA: QUANTISE MIDI
			foreach {time val} $nulines {
				lappend nuvals $time [expr int(round($val))]
			}
			set nulines $nuvals
		} elseif {$colmode == "Tsm"} {		;#	FRQ DATA, REMOVE OUT-OF-RANGE
			foreach {time val} $nulines {
				if {$val > $hifrq} {
					while {$val > $hifrq} {
						set val [expr $val / 2.0]
						if {$val < $lofrq} {
							set val $hifrq
							break
						}
					}
				} elseif {$val < $lofrq} {
					while {$val < $lofrq} {
						set val [expr $val * 2.0]
						if {$val > $hifrq} {
							set val $lofrq
							break
						}
					}
				}
				lappend nuvals $time $val
			}
			set nulines $nuvals
		} elseif {$colmode != "xm"} {										;#	PITCH DATA
			foreach {time val} $nulines {
				lappend ztimes $time
				lappend zvals $val
			}
			foreach val $zvals {											;#	REMOVE PITCH ZEROS
				if {![IsNumeric $val]} {
					ForceVal $tabed.message.e "Invalid data ($val) for this process"
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
				if {$val < 0} { 
					if {![info exists at_start]} {
						set at_start $ccnt
						if {$ccnt != 0} {
							set atstartval $lastval
						}
					}
				} else {
					if {[info exists at_start]} {
						if {$at_start == 0} {
							while {$at_start < $ccnt} {
								lappend nuvals $val
								incr at_start
							}
						} else {
							set midistart [HzToMidi $atstartval]
							set midiend   [HzToMidi $val]
							set steps [expr $ccnt - $at_start + 1]
							set midistep [expr $midiend - $midistart]
							set midistep [expr double($midistep) / double($steps)]
							set thismidi $midistart
							while {$at_start < $ccnt} {
								set thismidi [expr $thismidi + $midistep]
								lappend nuvals [MidiToHz $thismidi]
								incr at_start
							}
						}
						unset at_start
					}
					lappend nuvals $val
					set lastval $val
				}
				incr ccnt
			}
			if {[info exists at_start]} {
				while {$at_start < $ccnt} {
					lappend nuvals $lastval
					incr at_start
				}
			}
			catch {unset nulines}
			if {($colmode == "Sr") || ($colmode == "Xv")} {		;#	CONVERT VALS TO UNQUANTISED MIDI
				foreach time $ztimes val $nuvals {
					set val [StripTrailingZeros [DecPlaces [HzToMidi $val] 3]]
					lappend nulines $time $val
				}
			} else {									;#	CONVERT VALS TO QUANTISED MIDI
				foreach time $ztimes val $nuvals {
					lappend nulines $time [expr int(round([HzToMidi $val]))]
				}
			}
		}
		catch {unset nuvals}
		catch {unset sustained}
		set ccnt 0
		foreach {time val} $nulines {				;#	REMOVE CONSECUTIVE DUPLICATED VALS
			if {$ccnt == 0} {
				lappend nuvals $time $val
			} else {
				if {[Flteq $val $lastval]} {
					set sustained 1
				} else {
					if {[info exists sustained]} {
						lappend nuvals $lasttime $lastval
						unset sustained
					}
					lappend nuvals $time $val
				}
			}
			set lasttime $time
			set lastval $val
			incr ccnt
		}
		if {[info exists sustained]} {
			lappend nuvals $lasttime $lastval
		}			
		set nulines $nuvals
		catch {unset nuvals}
		set ccnt 0
		if {($colmode == "Sr") || ($colmode == "Xv") || ($colmode == "Tsm")} {	;#	IF UNQUANTISED MIDI (or FRQ) , KEEP
			set out_vals $nulines
		} else {
			foreach {time val} $nulines {			;#	ELSE, SMOOTH OUTPUT VALUES (REMOVE BRIEF PITCH DIGRESSIONS)
				if {$ccnt > 1} {
					set step   [expr $val - $lastval]
					set lastep [expr $lastval - $lalastval]
					if {(($step > 0) && ($lastep < 0)) \
					||  (($step < 0) && ($lastep > 0))} {
						if {[expr $time - $lasttime] < 0.05} {
							if {$step < 0} {
								set step [expr -$step]
							}
							if {$lastep < 0} {
								set lastep [expr -$lastep]
							}
							if {$step > $lastep} {
								set lastval $lalastval
							} else {
								set lastval $val
							}
						}
					}
				}
				if {$ccnt > 0} {
					set lalastval $lastval
					if {($colmode == "sr") || ($colmode == "sV")} {
						lappend nuvals $lastval
					} else {
						lappend nuvals $lasttime $lastval
					}
				}
				set lastval $val
				set lasttime $time
				incr ccnt
			}
			if {($colmode == "sr") || ($colmode == "sV")} {
				lappend nuvals $lastval
			} else {
				lappend nuvals $lasttime $lastval
			}
			set ccnt 0
			if {($colmode == "sr") || ($colmode == "sV")} {		;#		FOR UNTIMED DATA, REMOVE CONSECUTIVE DUPLICATES
				foreach val $nuvals {
					if {$ccnt > 0} {
						if {![Flteq $val $lastval]} {
							lappend out_vals $val
						}
					} else {
						lappend out_vals $val
					}
					set lastval $val
					incr ccnt
				}
			} elseif {$colmode == "SRM"} {											;#		FOR TIMED DATA, REMOVE CONSECUTIVE DUPLICATES 
				foreach {time val} $nuvals {
					if {$ccnt > 0} {
						set timestep [expr $time - $lasttime]
						if {($timestep < 0.05) || [Flteq $val $lastval]} {
							incr ccnt
							continue
						} else {
							lappend out_vals $time $val
						}
					} else {
						lappend out_vals $time $val
					}
					set lastval $val
					set lasttime $time
					incr ccnt
				}
			} else {											;#		FOR TIMED DATA, REMOVE CONSECUTIVE DUPLICATES 
				catch {unset waiting}
				foreach {time val} $nuvals {
					if {$ccnt > 0} {
						if {[Flteq $val $lastval]} {
							set waiting 1
						} else {
							if {[info exists waiting]} {
								lappend out_vals $lasttime $lastval
								unset waiting
							}
							lappend out_vals $time $val
						}
					} else {
						lappend out_vals $time $val
					}
					set lastval $val
					set lasttime $time
					incr ccnt
				}
				if {[info exists waiting]} {
					lappend out_vals $lasttime $lastval
				}
			}
		}
		if {($colmode == "SV") || ($colmode == "Sv") || ($colmode == "Sm") \
		|| ($colmode == "ZV") || ($colmode == "Xm") || ($colmode == "Xv")} {	;#	REMOVE NONVOCAL RANGE IN TIMED DATA
			set ccnt 0
			catch {unset sustained}
			catch {unset nuvals}
			foreach {time val} $out_vals {
				if {($val < 36 ) || ($val > 84)} {
					if {![info exists sustained]} {
						set sustained 1
						if {$ccnt == 0} {
							set startsustain 0.0
						} else {
							set startsustain $lasttime
							set valsustain $lastval
						}
					}
				} else {
					if [info exists sustained] {
						if {[Flteq $startsustain 0.0]} {
							lappend nuvals 0.0 $val
						} else {
							set timegap [expr $time - $startsustain]
							if {$timegap > 0.1} {
								set midtime [expr $startsustain + ($timegap/2.0)]
								lappend nuvals [expr $midtime - 0.025] $valsustain
								lappend nuvals [expr $midtime + 0.025] $val
							}
						}
						catch [unset sustained]
					}
					lappend nuvals $time $val
				}
				set lasttime $time
				set lastval $val
				incr ccnt
			}
			if [info exists sustained] {
				if {![info exists nuvals]} {
					set msg "There are no values within the vocal range."
					ForceVal $tabed.message.e  $msg
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
				lappend nuvals $lasttime $valsustain
			}
			set out_vals $nuvals
			unset nuvals
			set ccnt 0
			catch {unset sustain}
			foreach {time val} $out_vals {
				if {$ccnt == 0} {
					lappend nuvals $time $val
				} else {
					if {[Flteq $val $lastval]} {
						set sustain 1
					} else {
						if {[info exists sustain]} {
							lappend nuvals $lasttime $lastval
							unset sustain
						}
						lappend nuvals $time $val
					}
				}
				set lasttime $time
				set lastval $val
				incr ccnt
			}
			if {[info exists sustain]} {
				lappend nuvals $lasttime $lastval
				unset sustain
			}
			set out_vals $nuvals
		} elseif {$colmode == "sr"} {								;#	REMOVE NONVOCAL RANGE, FOR UNTIMED DATA
			catch {unset nuvals}
			foreach val $out_vals {
				if {($val >= 36 ) && ($val <= 84)} {
					lappend nuvals $val
				}
				if {![info exists nuvals]} {
					set msg "There are no values within the vocal range."
					ForceVal $tabed.message.e  $msg
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			set out_vals $nuvals
		}
		if {($colmode == "ZR") || ($colmode == "ZV") || ($colmode == "xM") || ($colmode == "xm") || ($colmode == "Xm")} {
			if {($colmode == "xM") || ($colmode == "xm") || ($colmode == "Xm")} {
				set out_vals $nuvals
			}
			set ccnt 0														;#  CHANGE TO IMPLIED-SUSTAIN FORMAT
			catch {unset nuvals}
			foreach {time val} $out_vals {
				if {$ccnt == 0} {
					lappend nuvals $time $val
				} elseif {![Flteq $val $lastval]} {
					lappend nuvals $time $val
				}
				set lastval $val
				incr ccnt
			}
			set out_vals $nuvals
		}
		if {($colmode == "sR") || ($colmode == "Sv") || ($colmode == "Xv")} {	;#	CONVERT MIDI (BACK) TO FRQ
			catch {unset nuvals}
			foreach {time val} $out_vals {
				lappend nuvals $time [MidiToHz $val]
			}
			set out_vals $nuvals
		}
		if {$colmode == "SRM"} {	;#	CONVERT MIDI to multi-instr sequencer format
			set ol $tabed.bot.otframe.l.list
			$ol delete 0 end
			catch {unset nuvals}
			$ol insert end 60
			set cnt 0
			foreach {time val} $out_vals {
				if {$cnt} {
					set dur [expr $time - $lasttime]
					lappend nuvals $dur
					$ol insert end $nuvals
					unset nuvals
				}
				lappend nuvals 1 $time $val 1.0
				set lasttime $time
				incr cnt
			}
			lappend nuvals $dur
			$ol insert end $nuvals
		} else {
			set ol $tabed.bot.otframe.l.list
			$ol delete 0 end
			if {($colmode == "sr") || ($colmode == "sV")} {				;#	WRITE UNTIMED DATA
				foreach val $out_vals {
					$ol insert end $val
				}
			} else {													;#	WRITE TIMED DATA
				foreach {time val} $out_vals {
					set line $time
					lappend line $val
					$ol insert end $line
				}
			}
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "Qs"} {
		DisableOutputTableOptions 1
		set ccnt 0
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nulines $item
				}
			}
		}
		if {[llength $nulines] < 4} {
			set msg "Insufficient values in table for this option."
			ForceVal $tabed.message.e  $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set mtf_pglide $evv(MTF_PGLIDE)
		set k [expr $colpar / 2.0]
		if {$k < $mtf_pglide} {
			set mtf_pglide $k
		}
		foreach {time val} $nulines {
			if {[IsEven $ccnt]}  {
				if {$ccnt > 0} {
					set timestep [expr $time - $lasttime]
					if {$timestep <= [expr $colpar + $mtf_pglide]} {
						set msg "Some notes too short ($timestep secs) for staccato + fades."
						ForceVal $tabed.message.e  $msg
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
				}
				set lasttime $time
				set lastval  $val
			} else {
				if {![Flteq $val $lastval]} {
					set msg "This is not quantised frequency data. (Equal frq values must be paired)"
					ForceVal $tabed.message.e  $msg
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			incr ccnt
		}
		set ccnt 0
		foreach {time val} $nulines {
			if {[IsEven $ccnt]}  {
				if {$ccnt > 0} {
					set timestep [expr $time - $lasttime]
					if {$ccnt == 2} {
						lappend evals $lasttime 0.0
					}
					set uptime [expr $lasttime + $mtf_pglide]
					lappend evals $uptime 1.0
					set intime [expr $lasttime + $colpar]
					lappend evals $intime 1.0
					set intime [expr $intime + $mtf_pglide]
					lappend evals $intime 0.0
					lappend evals $time 0.0
				}
				set lasttime $time
				set lastval  $val
			}
			incr ccnt
		}
		set endtime $time
		set k [llength $evals]
		incr k -2
		set lasttime [lindex $evals $k]
		set uptime [expr $lasttime + $mtf_pglide]
		lappend evals $uptime 1.0
		set intime [expr $lasttime + $colpar]
		lappend evals $intime 1.0
		set intime [expr $intime + $mtf_pglide]
		lappend evals $intime 0.0
		lappend evals [expr $endtime + 100] 0.0
		set ol $tabed.bot.otframe.l.list
		foreach {time val} $evals {
			set line $time
			lappend line $val
			$ol insert end $line
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {($colmode == "mf") || ($colmode == "mF")} {
		set ccnt 0
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nulines $item
				}
			}
		}
		foreach {time val} $nulines {
			if {![IsNumeric $val]} {
				ForceVal $tabed.message.e "Invalid data ($val) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {($val > $mu(MIDIMAX)) || ($val < $mu(MIDIMIN))} {
				ForceVal $tabed.message.e "MIDI VAL ($val) OUT OF RANGE"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		if {$colmode == "mF"} {		;#	REMOVE NONVOCAL RANGE
			set ccnt 0
			catch {unset sustained}
			foreach {time val} $nulines {
				if {($val < 36 ) || ($val > 84)} {
					set sustained 1
					if {$ccnt == 0} {
						set startsustain 0.0
					} else {
						set startsustain $lasttime
						set valsustain $lastval
					}
				} else {
					if [info exists sustained] {
						if {[Flteq $startsustain 0.0]} {
							lappend nuvals 0.0 $val
						} else {
							set timegap [expr $time - $startsustain]
							if {$timegap > 0.1} {
								set midtime [expr $startsustain + ($timegap/2.0)]
								lappend nuvals [expr $midtime - 0.025] $valsustain
								lappend nuvals [expr $midtime + 0.025] $val
							}
						}
						catch [unset sustained]
					}
					lappend nuvals $time $val
				}
				set lasttime $time
				set lastval $val
				incr ccnt
			}
			if [info exists sustained] {
				if {![info exists nuvals]} {
					set msg "There are no values within the vocal range."
					ForceVal $tabed.message.e  $msg
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
				lappend nuvals $lasttime $valsustain
			}
		}
		set out_vals $nuvals
		catch {unset nuvals}
		foreach {time val} $out_vals {
			lappend nuvals $time [MidiToHz $val]
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach {time val} $nuvals {
			set line $time
			lappend line $val
			$ol insert end $line
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {($colmode == "ZM")} {
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nulines $item
				}
			}
		}
		set ccnt 0
		foreach {time val} $nulines {
			if {![IsNumeric $time]} {
				ForceVal $tabed.message.e "Invalid time data ($time) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$ccnt == 0} {
				if {![Flteq $time 0.0]} {
					ForceVal $tabed.message.e "Initial time is not zero in data file"
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			} else {
				if {$time <= $lasttime} {
					ForceVal $tabed.message.e "Times do not advance after $lasttime in data file"
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			if {![IsNumeric $val]} {
				ForceVal $tabed.message.e "Invalid data ($val) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {($val > $mu(MIDIMAX)) || ($val < $mu(MIDIMIN))} {
				ForceVal $tabed.message.e "Midi val ($val) out of range"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set lasttime $time
			lappend nuvals $val
			incr ccnt
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach val $nuvals {
			$ol insert end $val
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {($colmode == "zm")} {
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nulines $item
				}
			}
		}
		set ccnt 0
		foreach {time val} $nulines {
			if {![IsNumeric $time]} {
				ForceVal $tabed.message.e "Invalid time data ($time) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$ccnt == 0} {
				if {![Flteq $time 0.0]} {
					ForceVal $tabed.message.e "Initial time is not zero in data file"
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			} else {
				if {$time <= $lasttime} {
					ForceVal $tabed.message.e "Times do not advance after $lasttime in data file"
		 			$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			if {![IsNumeric $val]} {
				ForceVal $tabed.message.e "Invalid data ($val) for this process"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {($val > $mu(MIDIMAX)) || ($val < $mu(MIDIMIN))} {
				ForceVal $tabed.message.e "MIDI VAL ($val) OUT OF RANGE"
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set lasttime $time
			incr ccnt
		}
		if {$colpar <= $lasttime} {
			ForceVal $tabed.message.e "Duration Parameter N must be > $lasttime"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ccnt 0
		foreach {time val} $nulines {
			if {$ccnt == 0} {
				lappend nuvals $time $val
			} else {
				if {![Flteq $val $lastval]} {
					set midtime [expr $time - 0.025]
					if {$midtime > $lasttime} {
						lappend nuvals $midtime $lastval
					}
				}
				lappend nuvals $time $val
			}
			set lasttime $time
			set lastval $val
			incr ccnt
		}
		lappend nuvals $colpar $lastval

		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach {time val} $nuvals {
			set line $time
			lappend line $val
			$ol insert end $line
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "CR"} {
		if {![IsNumeric $colpar] || ($colpar < 1) || ($colpar >= [expr $tot_inlines - 2])} {
			ForceVal $tabed.message.e "Invalid value of parameter N ($val) for this process"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set i [$tabed.bot.itframe.l.list curselection]
		if {$i < 0} {
			ForceVal $tabed.message.e "No row selected"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {$i == [expr $tot_inlines - 1]} {
			ForceVal $tabed.message.e "No lines to remove after this position"
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set j [expr $i + $colpar]
		if {$j > $tot_inlines} {
			set j $tot_inlines
		}
		if {$i == 0} {
			set thisline [$tb.itframe.l.list get $colpar]
			set thisline [string trim $thisline]
			set thisline [split $thisline]
			foreach item $thisline {
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set val [lindex $nuline 1]
			set outline 0.0
			append outline " " $val
			lappend outlines $outline
			foreach line [$tb.itframe.l.list get $colpar end] {
				lappend outlines $line
			}
		} elseif {$j == $tot_inlines} {
			set k $i
			incr k -1
			foreach line [$tb.itframe.l.list get 0 $k] {
				lappend outlines $line
			}
			set thisline [$tb.itframe.l.list get $k]
			set thisline [string trim $thisline]
			set thisline [split $thisline]
			foreach item $thisline {
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set val [lindex $nuline 1]
			set thisline [$tb.itframe.l.list get end]
			set thisline [string trim $thisline]
			set thisline [split $thisline]
			unset nuline
			foreach item $thisline {
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set outline [lindex $nuline 0]
			append outline " " $val
			lappend outlines $outline
		} else {
			set k $i
			incr k -1
			set thisline [$tb.itframe.l.list get $k]
			set thisline [string trim $thisline]
			set thisline [split $thisline]
			foreach item $thisline {
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set time0 [lindex $nuline 0]
			set val0  [lindex $nuline 1]

			set k $j
			set thisline [$tb.itframe.l.list get $k]
			set thisline [string trim $thisline]
			set thisline [split $thisline]
			unset nuline
			foreach item $thisline {
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set time1 [lindex $nuline 0]
			set val1  [lindex $nuline 1]
			set timegap [expr $time1 - $time0]
			set k $i
			incr k -1
			foreach line [$tb.itframe.l.list get 0 $k] {
				lappend outlines $line
			}
			if {![Flteq $val0 $val1] && ($timegap > 0.1)} {
				set midtime [expr ($time0 + $time1)/2.0]
				set thisline [expr $midtime - 0.025]
				append thisline " " $val0
				lappend outlines $thisline
				set thisline [expr $midtime + 0.025]
				append thisline " " $val1
				lappend outlines $thisline
			}
			foreach line [$tb.itframe.l.list get $j end] {
				lappend outlines $line
			}
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach line $outlines {
			$ol insert end $line
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "co"} {
		DisableOutputTableOptions 1
		set n 0
		foreach time $cotimes val $covals {
			if {$n != 0} {
				if {$val != $lastval} {
					set timestep [expr (double($time) - double($lasttime))/8.0]
					set m 1
					set thistime $lasttime
					while {$m < 7} {
						set thisval [expr double($m)/8.0]
						set thisval [expr cos($thisval * $evv(PI))]
						if {$val == 0} {
							set thisval [expr 1.0 + $thisval]
						} else {				
							set thisval [expr 1.0 - $thisval]
						}
						set thisval [expr $thisval/2.0]
						set thistime [expr $thistime + $timestep]
						lappend outvals $thistime $thisval
						incr m
					}
				}
			}
			lappend outvals $time $val
			set lasttime $time
			set lastval $val
			incr n
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		foreach {time val} $outvals {
			set outline $time
			lappend outline $val
			$ol insert end $outline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	} elseif {$colmode == "be"} {
		DisableOutputTableOptions 1
		if {$incols == 2} {
			catch {unset evals}
			foreach {time val} $bevals {
				lappend evals(0) $time $val
				set val [expr 1.0 - $val]
				lappend evals(1) $time $val
			}
			set k 0
		} else {
			set indxx 0
			set ccnt 0
			foreach val $bevals {			;# Normalise
				if {$indxx == 0} {
					set sum 0
				} else {
					set sum [expr $sum + $val]
				}
				incr indxx
				if {$indxx == $incols} {
					set norma [expr 1.0/$sum]
					set k [expr $ccnt - $incols + 2]
					while {$k <= $ccnt} {
						set valq [lindex $bevals $k]
						set valq [expr $valq * $norma]
						set bevals [lreplace $bevals $k $k $valq] 
						incr k
					}
					set indxx 0
				}
				incr ccnt
			}
			set len [llength $bevals]
			set indxx 1
			set vindx $indxx
			set tindx 0
			catch {unset evals}
			while {$indxx < $incols} {
				lappend evals($indxx) [lindex $bevals $tindx]
				lappend evals($indxx) [lindex $bevals $vindx]
				incr tindx $incols
				incr vindx $incols
				if {$tindx >= $len} {
					incr indxx
					set tindx 0
					set vindx $indxx
				}
			}
			set k 1
		}
		set ol $tabed.bot.otframe.l.list
		$ol delete 0 end
		while {$k < $incols} {
			foreach {time val} $evals($k) {
				set outline $time
				lappend outline $val
				$ol insert end $outline
			}
			$ol insert end  ""
			incr k
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
		return
	}
	if {[string match [string index $colmode 0] "W"]} {
		set isseq 1
		if {$tot_inlines > 1} {
			set it $tabed.bot.itframe.l.list
			set cnt0 0
			set line [$it get 0]
			string trim $line
			set line [split $line]
			foreach item $line {
				string trim $item
				if {[string length $item] > 0} {
					incr cnt0
				}
			}
			set cnt1 0
			set line [$it get 1]
			string trim $line
			set line [split $line]
			foreach item $line {
				string trim $item
				if {[string length $item] > 0} {
					incr cnt1
				}
			}
			if {$cnt0 == $cnt1} {
				set msg "Is This A Sequence File For Multiple Sounds?"
				set choice [tk_messageBox -type yesno -message $msg -icon question]
				if {$choice == "yes"} {
					set multiseq [$it get 0]
				}
			} else {
				set multiseq [$it get 0]
			}
			if {[info exists multiseq]} {
				set q_q "K"
				append q_q [string index $colmode 1]
				set colmode $q_q
			}
		}
	}
	DisableOutputTableOptions 1
	set colcmd [file join $evv(CDPROGRAM_DIR) columns]
	lappend colcmd $col_infnam
	if {[string match [string index $colmode 0] "K"]} {
		lappend colcmd $couldbe_seq2
	}
	set colparam -$colmode
	append colparam $colpar
	lappend colcmd $colparam
	if {![string match "@" $thresh_val]} {
		lappend colcmd $thresh_val
	}
	set docol_OK 0

	set sloom_cmd [linsert $colcmd 1 "#"]

	if [catch {open "|$sloom_cmd"} CDPcolrun] {
		ErrShow "$CDPcolrun"
   	} else {
   		fileevent $CDPcolrun readable "DisplayNewColumn $tb.otframe.l.list"
		vwait docol_OK
   	}
	if {$docol_OK} {
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
	} else {
		DisableOutputTableOptions 1
	}
}

#------ Invert table rows

proc RowInvert {} {
	global tabedit_ns tabedit_bind2 tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	lappend datlst "0"
	set len -1
	foreach line [$it get 0 end] {
		set datlst [linsert $datlst 0 $line]
   		incr len
	}
	set datlst [lrange $datlst 0 $len]
	set lmo "RV"
	lappend lmo $col_ungapd_numeric 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	$ot delete 0 end
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach itm $datlst {
		$ot insert end $itm
		puts $fileot $itm
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
}

#------ Sort table rows on basis of a column

proc RowAlphaSort {} {
	global tabedit_ns tabedit_bind2 tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		ForceVal $tabed.message.e "No column specified."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {($colpar < 1) || ($colpar > $incols)} {
		ForceVal $tabed.message.e "This column does not exist."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set llcnt 0
	foreach line [$it get 0 end] {
		set c_cnt 0
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				incr c_cnt
				if {$c_cnt == $colpar} {
					set dat [list $llcnt $item]
					lappend datlst $dat
				}
			}
		}
		if {$c_cnt < $colpar} {
			ForceVal $tabed.message.e "Some lines do not have enough columns to do this sort."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
		incr llcnt
   	}
	if {![info exists datlst]} {
		ForceVal $tabed.message.e "No column data found."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}

	set lmo "rA"
	lappend lmo $col_ungapd_numeric 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set len [llength $datlst]
	incr len -1
	set i 0
	while {$i < $len} {
		set j $i
		incr j
		while {$j <= $len} {
			set zn [lindex $datlst $i]
			set zm [lindex $datlst $j]
			if {[string compare [lindex $zm 1] [lindex $zn 1]] < 0} {
				set datlst [lreplace $datlst $i $i $zm] 
				set datlst [lreplace $datlst $j $j $zn] 
			}
			incr j
		}
		incr i
	}
	$ot delete 0 end
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach itm $datlst {
		set line [$it get [lindex $itm 0]]
		$ot insert end $line
		puts $fileot $line
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
}

#----- See column number for texture params

proc TexCrib {} {
	global p_prg in_filecnt pr_texcrib tex_col evv

	set f .texcrib

	eval {toplevel $f} -borderwidth $evv(BBDR)
	wm protocol $f WM_DELETE_WINDOW {set pr_texcrib 1}
	wm resizable $f 1 1
	wm title $f "Find Column of Texture Param "


	set fu [frame $f.upper -bd 2]
	frame $f.line -height 1 -bg $evv(POINT)
	set ff [frame $f.lower -bd 2]


	label $fu.l0 -text "ENTER COUNT OF INFILES FIRST" -fg $evv(SPECIAL)
	button $fu.q -text "Close" -command {set pr_texcrib 1} -highlightbackground [option get . background {}]
	label $fu.l -text "Number of Infiles"
	entry $fu.e -textvariable in_filecnt -width 4
	label $fu.dummy -text "                "
	button $fu.c -text "Confirm File Count" -command {CheckTexfileCnt} -highlightbackground [option get . background {}]
	label $fu.l2 -text "Column Number"
	entry $fu.e2 -textvariable tex_col -width 16 -state disabled

	pack $fu.l0 $fu.l $fu.e $fu.c $fu.dummy $fu.l2 $fu.e2 -side left -padx 2
	pack $fu.q -side right

	set ff0 [frame $ff.0 -bd 2]
	frame $ff.line -width 1 -bg $evv(POINT)
	set ff1 [frame $ff.1 -bd 2]
	set ff2 [frame $ff.2 -bd 2]

	button $ff0.1 -text "Simple" -width 30 -command {set p_prg 124 ; EnableTexparams 1} -state disabled -highlightbackground [option get . background {}]
	button $ff0.2 -text "Of Groups" -width 30 -command {set p_prg 125 ; EnableTexparams 2} -state disabled -highlightbackground [option get . background {}]
	button $ff0.3 -text "Decorated" -width 30 -command {set p_prg 126 ; EnableTexparams 3} -state disabled -highlightbackground [option get . background {}]
	button $ff0.4 -text "Pre-Decorated" -width 30 -command {set p_prg 127 ; EnableTexparams 4} -state disabled -highlightbackground [option get . background {}]
	button $ff0.5 -text "Post-Decorated" -width 30 -command {set p_prg 128 ; EnableTexparams 5} -state disabled -highlightbackground [option get . background {}]
	button $ff0.6 -text "Ornamented" -width 30 -command {set p_prg 129 ; EnableTexparams 6} -state disabled -highlightbackground [option get . background {}]
	button $ff0.7 -text "Preornate" -width 30 -command {set p_prg 130 ; EnableTexparams 7} -state disabled -highlightbackground [option get . background {}]
	button $ff0.8 -text "Postornate" -width 30 -command {set p_prg 131 ; EnableTexparams 8} -state disabled -highlightbackground [option get . background {}]
	button $ff0.9 -text "Of Motifs" -width 30 -command {set p_prg 132 ; EnableTexparams 9} -state disabled -highlightbackground [option get . background {}]
	button $ff0.10 -text "Motifs In Hf" -width 30 -command {set p_prg 133 ; EnableTexparams 10} -state disabled -highlightbackground [option get . background {}]
	button $ff0.11 -text "Timed" -width 30 -command {set p_prg 134 ; EnableTexparams 11} -state disabled -highlightbackground [option get . background {}]
	button $ff0.12 -text "Timed Groups" -width 30 -command {set p_prg 135 ; EnableTexparams 12} -state disabled -highlightbackground [option get . background {}]
	button $ff0.13 -text "Timed Motifs" -width 30 -command {set p_prg 136 ; EnableTexparams 13} -state disabled -highlightbackground [option get . background {}]
	button $ff0.14 -text "Timed Mtfs In Hf" -width 30 -command {set p_prg 137 ; EnableTexparams 14} -state disabled -highlightbackground [option get . background {}]

	pack $ff0.1 $ff0.2 $ff0.3 $ff0.4 $ff0.5 $ff0.6 $ff0.7 $ff0.8 $ff0.9 $ff0.10 $ff0.11 $ff0.12 $ff0.13 $ff0.14 -side top

	button $ff1.1 -text "mode" -width 30 -command {ShowTexCol $p_prg $in_filecnt "mode"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.2 -text "outfile name" -width 30 -command {ShowTexCol $p_prg $in_filecnt "outfile name"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.3 -text "note data" -width 30 -command {ShowTexCol $p_prg $in_filecnt "note data"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.4 -text "output duration" -width 30 -command {ShowTexCol $p_prg $in_filecnt "output duration"} -state disabled -highlightbackground [option get . background {}]
	frame $ff1.z -bd 2
	button $ff1.z.1 -text "event packing" -width 12 -command {ShowTexCol $p_prg $in_filecnt "event packing"		} -state disabled -highlightbackground [option get . background {}]
	button $ff1.z.2 -text "skip between group|motif onsets"	 -width 27 -command {ShowTexCol $p_prg $in_filecnt "skip between group|motif onsets"	} -state disabled
	button $ff1.z.3 -text "pause before line repeats" -width 27 -command {ShowTexCol $p_prg $in_filecnt "pause before line repeats"} -state disabled -highlightbackground [option get . background {}]
	pack $ff1.z.2 $ff1.z.1 $ff1.z.3 -side left -padx 1
	button $ff1.5 -text "event scatter" -width 30 -command {ShowTexCol $p_prg $in_filecnt "event scatter"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.6 -text "time grid unit" -width 30 -command {ShowTexCol $p_prg $in_filecnt "time grid unit"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.7 -text "first sound used" -width 30 -command {ShowTexCol $p_prg $in_filecnt "first sound used"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.8 -text "last sound used" -width 30 -command {ShowTexCol $p_prg $in_filecnt "last sound used"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.9 -text "minumum event gain" -width 30 -command {ShowTexCol $p_prg $in_filecnt "minumum event gain"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.10 -text "maximum event gain" -width 30 -command {ShowTexCol $p_prg $in_filecnt "maximum event gain"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.11 -text "minimum event sustain" -width 30 -command {ShowTexCol $p_prg $in_filecnt "minimum event sustain"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.12 -text "maximum event sustain" -width 30 -command {ShowTexCol $p_prg $in_filecnt "maximum event sustain"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.13 -text "minimum pitch" -width 30 -command {ShowTexCol $p_prg $in_filecnt "minimum pitch"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.14 -text "maximum pitch" -width 30 -command {ShowTexCol $p_prg $in_filecnt "maximum pitch"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.15 -text "time grid for note groups" -width 30 -command {ShowTexCol $p_prg $in_filecnt "time grid for note groups"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.16 -text "group spatialisation type" -width 30 -command {ShowTexCol $p_prg $in_filecnt "group spatialisation type"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.17 -text "group spatialisation range" -width 30 -command {ShowTexCol $p_prg $in_filecnt "group spatialisation range"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.18 -text "group amplitude change" -width 30 -command {ShowTexCol $p_prg $in_filecnt "group amplitude change"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.19 -text "group amp contour type" -width 30 -command {ShowTexCol $p_prg $in_filecnt "group amp contour type"} -state disabled -highlightbackground [option get . background {}]
	button $ff1.20 -text "min group size" -width 30 -command {ShowTexCol $p_prg $in_filecnt "min group size"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.21 -text "max group size" -width 30 -command {ShowTexCol $p_prg $in_filecnt "max group size"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.22 -text "min group-packing time" -width 30 -command {ShowTexCol $p_prg $in_filecnt "min group-packing time"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.23 -text "max group-packing time" -width 30 -command {ShowTexCol $p_prg $in_filecnt "max group-packing time"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.24 -text "min group pitchrange" -width 30 -command {ShowTexCol $p_prg $in_filecnt "min group pitchrange"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.25 -text "max group pitchrange" -width 30 -command {ShowTexCol $p_prg $in_filecnt "max group pitchrange"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.26 -text "pitch centring" -width 30 -command {ShowTexCol $p_prg $in_filecnt "pitch centring"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.27 -text "min motif-duration multiplier" -width 30 -command {ShowTexCol $p_prg $in_filecnt "min motif-duration multiplier"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.28 -text "max motif-duration multiplier" -width 30 -command {ShowTexCol $p_prg $in_filecnt "max motif-duration multiplier"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.29 -text "attenuation" -width 30 -command {ShowTexCol $p_prg $in_filecnt "attenuation"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.30 -text "spatial position" -width 30 -command {ShowTexCol $p_prg $in_filecnt "spatial position"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.31 -text "spatial spread" -width 30 -command {ShowTexCol $p_prg $in_filecnt "spatial spread"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.32 -text "random seeding value" -width 30 -command {ShowTexCol $p_prg $in_filecnt "random seeding value"} -state disabled -highlightbackground [option get . background {}]
	label $ff2.y -text "FLAGS" -fg $evv(SPECIAL)
	button $ff2.33 -text "play all of insound" -width 30 -command {ShowTexCol $p_prg $in_filecnt "play all of insound"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.34 -text "fixed timestep in group" -width 30 -command {ShowTexCol $p_prg $in_filecnt "fixed timestep in group"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.35 -text "fixed note-sustain in motifs" -width 30 -command {ShowTexCol $p_prg $in_filecnt "fixed note-sustain in motifs"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.36 -text "scatter decor|ornament instrs" -width 30 -command {ShowTexCol $p_prg $in_filecnt "scatter decor|ornament instrs"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.37 -text "decor|ornaments to highest note" -width 30 -command {ShowTexCol $p_prg $in_filecnt "decor|ornaments to highest note"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.38 -text "decor|ornaments on every note" -width 30 -command {ShowTexCol $p_prg $in_filecnt "decor|ornaments on every note"} -state disabled -highlightbackground [option get . background {}]
	button $ff2.39 -text "discard original line" -width 30 -command {ShowTexCol $p_prg $in_filecnt "discard original line"} -state disabled -highlightbackground [option get . background {}]
	pack $ff1.1 $ff1.2 $ff1.3 $ff1.4 $ff1.z $ff1.5 $ff1.6 $ff1.7 $ff1.8 $ff1.9 $ff1.10 $ff1.11 $ff1.12 $ff1.13 $ff1.14 $ff1.15 -side top
	pack $ff1.16 $ff1.17 $ff1.18 $ff1.19 $ff1.20 -side top
	pack $ff2.21 $ff2.22 $ff2.23 $ff2.24 $ff2.25 $ff2.26 $ff2.27 $ff2.28 $ff2.29 $ff2.30 -side top
	pack $ff2.31 $ff2.32 $ff2.y $ff2.33 $ff2.34 $ff2.35 $ff2.36 $ff2.37 $ff2.38 $ff2.39 -side top
	pack $ff.0 -side left -fill y -expand true
	pack $ff.line -side left -fill y -expand true
	pack $ff.1 $ff.2 -side left -fill y -expand true
	pack $f.upper -side top -fill x -expand true
	pack $f.line -side top -fill x -expand true
	pack $f.lower -side top


	set in_filecnt ""
	set pr_texcrib 0

	raise $f
	My_Grab 0 $f pr_texcrib
	tkwait variable pr_texcrib
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc ShowTexCol {p_prg in_filecnt paramstr} {
	global tex_col evv

	.texcrib.lower.1.1 config -bg [option get . background {}]
	.texcrib.lower.1.2 config -bg [option get . background {}]
	.texcrib.lower.1.3 config -bg [option get . background {}]
	.texcrib.lower.1.4 config -bg [option get . background {}]
	.texcrib.lower.1.z.1 config -bg [option get . background {}]
	.texcrib.lower.1.z.2 config -bg [option get . background {}]
	.texcrib.lower.1.z.3 config -bg [option get . background {}]
	.texcrib.lower.1.5 config -bg [option get . background {}]
	.texcrib.lower.1.6 config -bg [option get . background {}]
	.texcrib.lower.1.7 config -bg [option get . background {}]
	.texcrib.lower.1.8 config -bg [option get . background {}]
	.texcrib.lower.1.9 config -bg [option get . background {}]
	.texcrib.lower.1.10 config -bg [option get . background {}]
	.texcrib.lower.1.11 config -bg [option get . background {}]
	.texcrib.lower.1.12 config -bg [option get . background {}]
	.texcrib.lower.1.13 config -bg [option get . background {}]
	.texcrib.lower.1.14 config -bg [option get . background {}]
	.texcrib.lower.1.15 config -bg [option get . background {}]
	.texcrib.lower.1.16 config -bg [option get . background {}]
	.texcrib.lower.1.17 config -bg [option get . background {}]
	.texcrib.lower.1.18 config -bg [option get . background {}]
	.texcrib.lower.1.19 config -bg [option get . background {}]
	.texcrib.lower.1.20 config -bg [option get . background {}]
	.texcrib.lower.2.21 config -bg [option get . background {}]
	.texcrib.lower.2.22 config -bg [option get . background {}]
	.texcrib.lower.2.23 config -bg [option get . background {}]
	.texcrib.lower.2.24 config -bg [option get . background {}]
	.texcrib.lower.2.25 config -bg [option get . background {}]
	.texcrib.lower.2.26 config -bg [option get . background {}]
	.texcrib.lower.2.27 config -bg [option get . background {}]
	.texcrib.lower.2.28 config -bg [option get . background {}]
	.texcrib.lower.2.29 config -bg [option get . background {}]
	.texcrib.lower.2.30 config -bg [option get . background {}]
	.texcrib.lower.2.31 config -bg [option get . background {}]
	.texcrib.lower.2.32 config -bg [option get . background {}]
	.texcrib.lower.2.33 config -bg [option get . background {}]
	.texcrib.lower.2.34 config -bg [option get . background {}]
	.texcrib.lower.2.35 config -bg [option get . background {}]
	.texcrib.lower.2.36 config -bg [option get . background {}]
	.texcrib.lower.2.37 config -bg [option get . background {}]
	.texcrib.lower.2.38 config -bg [option get . background {}]
	.texcrib.lower.2.39 config -bg [option get . background {}]

	switch -- $paramstr {
		"mode" { 
			set colno 3
			.texcrib.lower.1.1   config -bg $evv(EMPH)
		}
		"outfile name"		{
			set colno [expr 4 + $in_filecnt]
			.texcrib.lower.1.2   config -bg $evv(EMPH)
		}
		"note data"			{
			set colno [expr 5 + $in_filecnt]
			.texcrib.lower.1.3   config -bg $evv(EMPH)
		}
		"output duration"	{
			if {$p_prg == 137} {		;# tmotifsin
				set colno "NOT USED"
			} else {
				set colno [expr 6 + $in_filecnt]
			}
			.texcrib.lower.1.4   config -bg $evv(EMPH)
		}
		"event packing" {
			switch -- $p_prg {
				124 { set colno [expr 7 + $in_filecnt]	;# simple}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.z.1   config -bg $evv(EMPH)
		}
		"skip between group|motif onsets" {
			switch -- $p_prg {
				125 -
				132 -
				133 { set colno [expr 7 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.z.2   config -bg $evv(EMPH)
		}
		"pause before line repeats" {
			switch -- $p_prg {
				126 -
				127 -
				128 { set colno [expr 7 + $in_filecnt]	;# decor}
				129 -
				130 -
				131 { set colno [expr 7 + $in_filecnt]	;# ornate}
				134 { set colno [expr 7 + $in_filecnt]	;# timed}
				135 { set colno [expr 7 + $in_filecnt]	;# tgrouped}
				136 { set colno [expr 7 + $in_filecnt]	;# tmotifs}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.z.3   config -bg $evv(EMPH)
		}
		"event scatter" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 8 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.5   config -bg $evv(EMPH)
		}
		"time grid unit" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 9 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.6   config -bg $evv(EMPH)
		}
		"first sound used" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 10 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				137 { set colno [expr 6 + $in_filecnt]	;# tmotifsin}
				default {set colno [expr 8 + $in_filecnt]}
			}
			.texcrib.lower.1.7   config -bg $evv(EMPH)
		}
		"last sound used" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 11 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				137 { set colno [expr 7 + $in_filecnt]	;# tmotifsin}
				default {set colno [expr 9 + $in_filecnt]}
			}
			.texcrib.lower.1.8   config -bg $evv(EMPH)
		}
		"minumum event gain" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 12 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				137 { set colno [expr 10 + $in_filecnt]	;# tmotifsin}
				default {set colno [expr 8 + $in_filecnt]}
			}
			.texcrib.lower.1.9   config -bg $evv(EMPH)
		}
		"maximum event gain" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 13 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				137 { set colno [expr 11 + $in_filecnt]	;# tmotifsin}
				default {set colno [expr 9 + $in_filecnt]}
			}
			.texcrib.lower.1.10   config -bg $evv(EMPH)
		}
		"minimum event sustain" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 14 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				137 { set colno [expr 12 + $in_filecnt]	;# tmotifsin}
				default {set colno [expr 10 + $in_filecnt]}
			}
			.texcrib.lower.1.11   config -bg $evv(EMPH)
		}
		"maximum event sustain" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 15 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				137 { set colno [expr 13 + $in_filecnt]	;# tmotifsin}
				default {set colno [expr 11 + $in_filecnt]}
			}
			.texcrib.lower.1.12   config -bg $evv(EMPH)
		}
		"minimum pitch" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 16 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				134 -
				135 -
				136 { set colno [expr 14 + $in_filecnt]	;# timed,tgroups,tmotifs}
				133 { set colno [expr 12 + $in_filecnt]	;# tmotifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.13   config -bg $evv(EMPH)
		}
		"maximum pitch" {
			switch -- $p_prg {
				124 -
				125 -
				132 -
				133 { set colno [expr 17 + $in_filecnt]	;# simple,grouped,motifs,motifsin}
				134 -
				135 -
				136 { set colno [expr 15 + $in_filecnt]	;# timed,tgroups,tmotifs}
				133 { set colno [expr 13 + $in_filecnt]	;# tmotifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.14   config -bg $evv(EMPH)
		}
		"time grid for note groups" {
			switch -- $p_prg {
				125 -
				132 -
				133 { set colno [expr 18 + $in_filecnt] ;# grouped,motifs,motifsin}
				135 - 
				136 { set colno [expr 16 + $in_filecnt] ;# tgrouped,tmotifs}
				126 -
				127 -
				128 -
				129 -
				130 -
				131 -
				137 { set colno [expr 14 + $in_filecnt] ;# all dec, all orn, tnotifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.15   config -bg $evv(EMPH)
		}
		"group spatialisation type" {
			switch -- $p_prg {
				125 -
				132 -
				133 { set colno [expr 19 + $in_filecnt] ;# grouped,motifs,motifsin}
				135 - 
				136 { set colno [expr 17 + $in_filecnt] ;# tgrouped,tmotifs}
				126 -
				127 -
				128 -
				129 -
				130 -
				131 -
				137 { set colno [expr 15 + $in_filecnt] ;# all dec, all orn, tnotifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.16   config -bg $evv(EMPH)
		}
		"group spatialisation range" {
			switch -- $p_prg {
				125 -
				132 -
				133 { set colno [expr 20 + $in_filecnt] ;# grouped,motifs,motifsin}
				135 - 
				136 { set colno [expr 18 + $in_filecnt] ;# tgrouped,tmotifs}
				126 -
				127 -
				128 -
				129 -
				130 -
				131 -
				137 { set colno [expr 16 + $in_filecnt] ;# all dec, all orn, tnotifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.17   config -bg $evv(EMPH)
		}
		"group amplitude change" {
			switch -- $p_prg {
				125 -
				132 -
				133 { set colno [expr 21 + $in_filecnt] ;# grouped,motifs,motifsin}
				135 - 
				136 { set colno [expr 19 + $in_filecnt] ;# tgrouped,tmotifs}
				126 -
				127 -
				128 -
				129 -
				130 -
				131 -
				137 { set colno [expr 17 + $in_filecnt] ;# all dec, all orn, tnotifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.18   config -bg $evv(EMPH)
		}
		"group amp contour type" {
			switch -- $p_prg {
				125 -
				132 -
				133 { set colno [expr 22 + $in_filecnt] ;# grouped,motifs,motifsin}
				135 - 
				136 { set colno [expr 20 + $in_filecnt] ;# tgrouped,tmotifs}
				126 -
				127 -
				128 -
				129 -
				130 -
				131 -
				137 { set colno [expr 18 + $in_filecnt] ;# all dec, all orn, tnotifsin}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.19   config -bg $evv(EMPH)
		}
		"min group size" {
			switch -- $p_prg {
				125 { set colno [expr 23 + $in_filecnt] ;# grouped}
				136 { set colno [expr 21 + $in_filecnt] ;# tgrouped}
				126 -
				127 -
				128 { set colno [expr 19 + $in_filecnt] ;# all dec}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.1.20   config -bg $evv(EMPH)
		}
		"max group size" {
			switch -- $p_prg {
				125 { set colno [expr 24 + $in_filecnt] ;# grouped}
				136 { set colno [expr 22 + $in_filecnt] ;# tgrouped}
				126 -
				127 -
				128 { set colno [expr 20 + $in_filecnt] ;# all dec}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.21   config -bg $evv(EMPH)
		}
		"min group-packing time" {
			switch -- $p_prg {
				125 { set colno [expr 25 + $in_filecnt] ;# grouped}
				136 { set colno [expr 23 + $in_filecnt] ;# tgrouped}
				126 -
				127 -
				128 { set colno [expr 21 + $in_filecnt] ;# all dec}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.22   config -bg $evv(EMPH)
		}
		"max group-packing time" {
			switch -- $p_prg {
				125 { set colno [expr 26 + $in_filecnt] ;# grouped}
				136 { set colno [expr 24 + $in_filecnt] ;# tgrouped}
				126 -
				127 -
				128 { set colno [expr 22 + $in_filecnt] ;# all dec}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.23   config -bg $evv(EMPH)
		}
		"min group pitchrange" {
			switch -- $p_prg {
				125 { set colno [expr 27 + $in_filecnt] ;# grouped}
				136 { set colno [expr 25 + $in_filecnt] ;# tgrouped}
				126 -
				127 -
				128 { set colno [expr 23 + $in_filecnt] ;# all dec}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.24   config -bg $evv(EMPH)
		}
		"max group pitchrange" {
			switch -- $p_prg {
				125 { set colno [expr 28 + $in_filecnt] ;# grouped}
				136 { set colno [expr 26 + $in_filecnt] ;# tgrouped}
				126 -
				127 -
				128 { set colno [expr 24 + $in_filecnt] ;# all dec}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.25   config -bg $evv(EMPH)
		}
		"pitch centring" {
			switch -- $p_prg {
				128 { set colno [expr 25 + $in_filecnt] ;# all dec}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.26   config -bg $evv(EMPH)
		}
		"min motif-duration multiplier" {
			switch -- $p_prg {
				129 -
				130 -
				131 - 
				137 { set colno [expr 19 + $in_filecnt] ;# all orn, tmotifsin}
				136 { set colno [expr 21 + $in_filecnt] ;# tmotifs}
				132 -
				133 { set colno [expr 21 + $in_filecnt] ;# motifs,motifsin}
				default {set colno "NOT USED"}

			}
			.texcrib.lower.2.27   config -bg $evv(EMPH)
		}
		"max motif-duration multiplier" {
			switch -- $p_prg {
				129 -
				130 -
				131 - 
				137 { set colno [expr 20 + $in_filecnt] ;# all orn, tmotifsin}
				136 { set colno [expr 22 + $in_filecnt] ;# tmotifs}
				132 -
				133 { set colno [expr 24 + $in_filecnt] ;# motifs,motifsin}
				default {set colno "NOT USED"}

			}
			.texcrib.lower.2.28   config -bg $evv(EMPH)
		}
		"attenuation" {
			switch -- $p_prg {
				124 { set colno [expr 18 + $in_filecnt] ;# simple}
				125 { set colno [expr 29 + $in_filecnt] ;# timed}
				126 -
				127 -
				128 { set colno [expr 26 + $in_filecnt] ;# all dec}
				129 -
				130 -
				131 -
				137 { set colno [expr 21 + $in_filecnt] ;# all orn,tmotifsin}
				132 -
				133 { set colno [expr 25 + $in_filecnt] ;# motifs,motifsin}
				134 { set colno [expr 16 + $in_filecnt] ;# timed}
				135 { set colno [expr 27 + $in_filecnt] ;# tgrouped}
				136 { set colno [expr 23 + $in_filecnt] ;# tmotifs}
			}
			.texcrib.lower.2.29   config -bg $evv(EMPH)
		}
		"spatial position" {
			switch -- $p_prg {
				124 { set colno [expr 19 + $in_filecnt] ;# simple}
				125 { set colno [expr 30 + $in_filecnt] ;# timed}
				126 -
				127 -
				128 { set colno [expr 27 + $in_filecnt] ;# all dec}
				129 -
				130 -
				131 -
				137 { set colno [expr 22 + $in_filecnt] ;# all orn,tmotifsin}
				132 -
				133 { set colno [expr 26 + $in_filecnt] ;# motifs,motifsin}
				134 { set colno [expr 17 + $in_filecnt] ;# timed}
				135 { set colno [expr 28 + $in_filecnt] ;# tgrouped}
				136 { set colno [expr 24 + $in_filecnt] ;# tmotifs}
			}
			.texcrib.lower.2.30   config -bg $evv(EMPH)
		}
		"spatial spread" {
			switch -- $p_prg {
				124 { set colno [expr 20 + $in_filecnt] ;# simple}
				125 { set colno [expr 31 + $in_filecnt] ;# timed}
				126 -
				127 -
				128 { set colno [expr 28 + $in_filecnt] ;# all dec}
				129 -
				130 -
				131 -
				137 { set colno [expr 23 + $in_filecnt] ;# all orn,tmotifsin}
				132 -
				133 { set colno [expr 27 + $in_filecnt] ;# motifs,motifsin}
				134 { set colno [expr 18 + $in_filecnt] ;# timed}
				135 { set colno [expr 29 + $in_filecnt] ;# tgrouped}
				136 { set colno [expr 25 + $in_filecnt] ;# tmotifs}
			}
			.texcrib.lower.2.31   config -bg $evv(EMPH)
		}
		"random seeding value" {
			switch -- $p_prg {
				124 { set colno [expr 21 + $in_filecnt] ;# simple}
				125 { set colno [expr 32 + $in_filecnt] ;# timed}
				126 -
				127 -
				128 { set colno [expr 29 + $in_filecnt] ;# all dec}
				129 -
				130 -
				131 -
				137 { set colno [expr 24 + $in_filecnt] ;# all orn,tmotifsin}
				132 -
				133 { set colno [expr 28 + $in_filecnt] ;# motifs,motifsin}
				134 { set colno [expr 19 + $in_filecnt] ;# timed}
				135 { set colno [expr 30 + $in_filecnt] ;# tgrouped}
				136 { set colno [expr 26 + $in_filecnt] ;# tmotifs}
			}
			.texcrib.lower.2.32   config -bg $evv(EMPH)
		}
		"play all of insound" {
			switch -- $p_prg {
				124 { set colno [expr 22 + $in_filecnt] ;# simple}
				125 { set colno [expr 33 + $in_filecnt] ;# timed}
				126 -
				127 -
				128 { set colno [expr 30 + $in_filecnt] ;# all dec}
				129 -
				130 -
				131 -
				137 { set colno [expr 25 + $in_filecnt] ;# all orn,tmotifsin}
				132 -
				133 { set colno [expr 29 + $in_filecnt] ;# motifs,motifsin}
				134 { set colno [expr 20 + $in_filecnt] ;# timed}
				135 { set colno [expr 31 + $in_filecnt] ;# tgrouped}
				136 { set colno [expr 27 + $in_filecnt] ;# tmotifs}
			}
			.texcrib.lower.2.33   config -bg $evv(EMPH)
		}
		"fixed timestep in group" {
			switch -- $p_prg {
				125 { set colno [expr 34 + $in_filecnt] ;# timed}
				126 -
				127 -
				128 { set colno [expr 31 + $in_filecnt] ;# all dec}
				135 { set colno [expr 32 + $in_filecnt] ;# tgrouped}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.34   config -bg $evv(EMPH)
		}
		"fixed note-sustain in motifs" {
			switch -- $p_prg {
				129 -
				130 -
				131 -
				137 { set colno [expr 26 + $in_filecnt] ;# all orn}
				132 -
				133 { set colno [expr 30 + $in_filecnt] ;# motifs,motifsin}
				136 { set colno [expr 28 + $in_filecnt] ;# tmotifs}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.35   config -bg $evv(EMPH)
		}
		"scatter decor|ornament instrs" {
			switch -- $p_prg {
				125 { set colno [expr 35 + $in_filecnt] ;# timed}
				126 -
				127 -
				128 { set colno [expr 32 + $in_filecnt] ;# all dec}
				129 -
				130 -
				131 { set colno [expr 27 + $in_filecnt] ;# all orn}
				133 { set colno [expr 31 + $in_filecnt] ;# motifsin}
				135 { set colno [expr 33 + $in_filecnt] ;# tgrouped}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.36   config -bg $evv(EMPH)
		}
		"decor|ornaments to highest note" {
			switch -- $p_prg {
				126 -
				127 -
				128 { set colno [expr 33 + $in_filecnt] ;# all dec}
				129 -
				130 -
				131 { set colno [expr 28 + $in_filecnt] ;# all orn}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.37   config -bg $evv(EMPH)
		}
		"decor|ornaments on every note" {
			switch -- $p_prg {
				126 -
				127 -
				128 { set colno [expr 34 + $in_filecnt] ;# all dec}
				129 -
				130 -
				131 { set colno [expr 29 + $in_filecnt] ;# all orn}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.38   config -bg $evv(EMPH)
		}
		"discard original line" {
			switch -- $p_prg {
				126 -
				127 -
				128 { set colno [expr 35 + $in_filecnt] ;# all dec}
				default {set colno "NOT USED"}
			}
			.texcrib.lower.2.39   config -bg $evv(EMPH)
		}
	}
	.texcrib.upper.e2 config -state normal -bg $evv(EMPH)
	set tex_col $colno
	.texcrib.upper.e2 config -state disabled
}

proc EnableTexparams {no} {
	global tex_col evv

	set n 1
	while {$n <= 14} {
		if {$n == $no} {
			.texcrib.lower.0.$n config -bg $evv(EMPH)
		} else {
			.texcrib.lower.0.$n config -bg [option get . background {}]
		}
		incr n
	}
	.texcrib.upper.e2 config -state normal -bg [option get . background {}]
	set tex_col ""
	.texcrib.upper.e2 config -state disabled

	.texcrib.lower.1.1 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.2 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.3 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.4 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.z.1 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.z.2 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.z.3 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.5 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.6 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.7 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.8 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.9 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.10 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.11 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.12 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.13 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.14 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.15 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.16 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.17 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.18 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.19 config -state normal -bg [option get . background {}]
	.texcrib.lower.1.20 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.21 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.22 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.23 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.24 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.25 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.26 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.27 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.28 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.29 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.30 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.31 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.32 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.33 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.34 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.35 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.36 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.37 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.38 config -state normal -bg [option get . background {}]
	.texcrib.lower.2.39 config -state normal -bg [option get . background {}]
}


proc CheckTexfileCnt {} {
	global in_filecnt tex_col evv

	if {[string length $in_filecnt] <= 0} {
		Inf "No input filecount entered"
		return
	} elseif {![IsNumeric $in_filecnt] || ($in_filecnt < 1)} {
		Inf "Invalid filecount entered"
		return
	}
	.texcrib.upper.e2 config -state normal -bg [option get . background {}]
	set tex_col ""
	.texcrib.upper.e2 config -state disabled

	.texcrib.lower.0.1 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.2 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.3 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.4 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.5 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.6 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.7 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.8 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.9 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.10 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.11 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.12 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.13 config -state normal -bg [option get . background {}]
	.texcrib.lower.0.14 config -state normal -bg [option get . background {}]

	.texcrib.lower.1.1 config -bg [option get . background {}]
	.texcrib.lower.1.2 config -bg [option get . background {}]
	.texcrib.lower.1.3 config -bg [option get . background {}]
	.texcrib.lower.1.4 config -bg [option get . background {}]
	.texcrib.lower.1.z.1 config -bg [option get . background {}]
	.texcrib.lower.1.z.2 config -bg [option get . background {}]
	.texcrib.lower.1.z.3 config -bg [option get . background {}]
	.texcrib.lower.1.5 config -bg [option get . background {}]
	.texcrib.lower.1.6 config -bg [option get . background {}]
	.texcrib.lower.1.7 config -bg [option get . background {}]
	.texcrib.lower.1.8 config -bg [option get . background {}]
	.texcrib.lower.1.9 config -bg [option get . background {}]
	.texcrib.lower.1.10 config -bg [option get . background {}]
	.texcrib.lower.1.11 config -bg [option get . background {}]
	.texcrib.lower.1.12 config -bg [option get . background {}]
	.texcrib.lower.1.13 config -bg [option get . background {}]
	.texcrib.lower.1.14 config -bg [option get . background {}]
	.texcrib.lower.1.15 config -bg [option get . background {}]
	.texcrib.lower.1.16 config -bg [option get . background {}]
	.texcrib.lower.1.17 config -bg [option get . background {}]
	.texcrib.lower.1.18 config -bg [option get . background {}]
	.texcrib.lower.1.19 config -bg [option get . background {}]
	.texcrib.lower.1.20 config -bg [option get . background {}]
	.texcrib.lower.2.21 config -bg [option get . background {}]
	.texcrib.lower.2.22 config -bg [option get . background {}]
	.texcrib.lower.2.23 config -bg [option get . background {}]
	.texcrib.lower.2.24 config -bg [option get . background {}]
	.texcrib.lower.2.25 config -bg [option get . background {}]
	.texcrib.lower.2.26 config -bg [option get . background {}]
	.texcrib.lower.2.27 config -bg [option get . background {}]
	.texcrib.lower.2.28 config -bg [option get . background {}]
	.texcrib.lower.2.29 config -bg [option get . background {}]
	.texcrib.lower.2.30 config -bg [option get . background {}]
	.texcrib.lower.2.31 config -bg [option get . background {}]
	.texcrib.lower.2.32 config -bg [option get . background {}]
	.texcrib.lower.2.33 config -bg [option get . background {}]
	.texcrib.lower.2.34 config -bg [option get . background {}]
	.texcrib.lower.2.35 config -bg [option get . background {}]
	.texcrib.lower.2.36 config -bg [option get . background {}]
	.texcrib.lower.2.37 config -bg [option get . background {}]
	.texcrib.lower.2.38 config -bg [option get . background {}]
	.texcrib.lower.2.39 config -bg [option get . background {}]

}

#---- Convert col to table of values

proc ColtoTab {colmode p_cnt} {
	global record_temacro temacro tot_inlines incols col_ungapd_numeric colpar threshold col_infnam tabed evv
	global outcolcnt tot_outlines tabedit_ns tabedit_bind2 col_infnam col_tabname pa lmo CDPcolrun docol_OK col_x

	if {![file exists $evv(COLFILE1)]} {
		ForceVal $tabed.message.e "There is no data in the input table"
 		$tabed.message.e config -bg [option get . background {}]
		return
	}
	HaltCursCop

	set t $tabed.bot.kcframe
	set tol $tabed.bot.otframe.l.list
	set til $tabed.bot.itframe.l.list

	$tol config -bg $evv(EMPH)
	$til config -bg [option get . background {}]
	DisableOutputColumnOptions2
	set tb $tabed.bot
	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "CT"
	lappend lmo $col_ungapd_numeric $colmode $p_cnt
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	catch {unset colmode_exception}
	DisableOutputTableOptions 1

	if {![CreateColumnParams $colmode $p_cnt]} {
		return
	}
	set colcmd [file join $evv(CDPROGRAM_DIR) columns]
	lappend colcmd $evv(COLFILE1)
	set i 1
	while {$i <= $p_cnt} {
		lappend colcmd $col_x($i)
		incr i
	}
	lappend colcmd -$colmode							;#	Check for threshold val, where optional
	set threshold ""
	ForceVal $tabed.mid.par2 $threshold
	set docol_OK 0

	set sloom_cmd [linsert $colcmd 1 "#"]

	if [catch {open "|$sloom_cmd"} CDPcolrun] {
		ErrShow "$CDPcolrun"
   	} else {
   		fileevent $CDPcolrun readable "DisplayNewColumn $tb.otframe.l.list"
		vwait docol_OK
   	}

	if {$docol_OK} {
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
	} else {
		DisableOutputTableOptions 1
	}
}

#------ Do vector operations, using Columns programme return capture routine

proc VectorstoTab {colmode p_cnt} {
	global colpar threshold CDPcolrun docol_OK tedit_message pvec record_temacro temacro temacrop evv
	global coltype col_ungapd_numeric outcolcnt tot_outlines col_x lmo tot_inlines tabedit_ns tabedit_bind2
	global col_tabname col_infnam tabed

	if {![file exists $evv(COLFILE1)]} {
		ForceVal $tabed.message.e "There is no data in the input table"
 		$tabed.message.e config -bg [option get . background {}]
		return
	}
	if {![file exists $evv(COLFILE2)]} {
		ForceVal $tabed.message.e "There is no data in the output table"
 		$tabed.message.e config -bg [option get . background {}]
		return
	}
	HaltCursCop

	set t $tabed.bot.kcframe
	set tol $tabed.bot.otframe.l.list
	set til $tabed.bot.itframe.l.list

	$tol config -bg $evv(EMPH)
	$til config -bg [option get . background {}]
	DisableOutputColumnOptions2

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo VT
	lappend lmo $col_ungapd_numeric $colmode $p_cnt

	set tb $tabed.bot
	set colparam $colmode
	set pvec "x"
	DisableOutputTableOptions 1

	if {![CreateColumnParams $colmode $p_cnt]} {
		return
	}
	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	set veccmd [file join $evv(CDPROGRAM_DIR) vectors]
	lappend veccmd $evv(COLFILE1) $evv(COLFILE2) -$colmode
	set i 1
	while {$i <= $p_cnt} {
		lappend veccmd $col_x($i)
		incr i
	}
	set docol_OK 0
	set sloom_cmd [linsert $veccmd 1 "#"]
	if [catch {open "|$sloom_cmd"} CDPcolrun] {
		ErrShow "$CDPcolrun"
   	} else {
   		fileevent $CDPcolrun readable "DisplayNewColumn $tb.otframe.l.list"
		vwait docol_OK
   	}
	if {$docol_OK} {
		if {[WriteOutputTable $evv(LINECNT_ONE)]} {
			EnableOutputTableOptions 0 1
		}
	} else {
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
	}
}

#---------- Split Table at markers

proc SplitTable {colmode} {
	global evv tabed coltype ino okz col_ungapd_numeric outcolcnt tot_outlines tabedit_bind2 record_temacro colpar threshold ch lmo
	global rememd

	HaltCursCop

	set t $tabed.bot.kcframe
	set tol $tabed.bot.otframe.l.list
	set til $tabed.bot.itframe.l.list

	$tol config -bg $evv(EMPH)
	$til config -bg [option get . background {}]
	DisableOutputColumnOptions2 

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo TT
	lappend lmo $col_ungapd_numeric $colmode

	set tb $tabed.bot
	DisableOutputTableOptions 1

	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	set linecnt [$tabed.bot.itframe.l.list index end]
	if {$linecnt <= 0} {
		ForceVal $tabed.message.e "There is no data in the input table display."
 		$tabed.message.e config -bg [option get . background {}]
		return
	}
	set file_ext [string trim [$tabed.bot.itframe.f0 cget -text]]
	set file_ext [split $file_ext]
	set file_ext [file extension [lindex $file_ext end]]
	if {![info exists file_ext] || ([string length $file_ext] <= 0)} {
		ForceVal $tabed.message.e "Cannot get file extension of input file"
 		$tabed.message.e config -bg [option get . background {}]
		return
	}

	if {[string length $colpar] <= 0} {
		set msg "No generic output filename given at N."
		ForceVal $tabed.message.e $msg
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set colpar [string tolower $colpar]
	set fnam [file rootname [file tail $colpar]]
	if {![ValidCDPRootname $fnam]} {
		set msg "Invalid output file generic name given at N."
		ForceVal $tabed.message.e $msg
	 	$tabed.message.e config -bg $evv(EMPH)
		return

	}
	set dir [file dirname $colpar]
	if {([string length $dir] <= 1) || [string match [pwd] $dir]} {
		set colpar [file tail $colpar]
	}
	switch -- $colmode {
		"yt" {
			if {[string length $threshold] <= 0} {
				set msg "No outputfile line length given at 'threshold'."
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![regexp {^[0-9]+$} $threshold] || ($threshold < 1)} {
				set msg "Invalid value for outputfile line length given at 'threshold'."
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set OK 0
			set step $threshold
			while {$step <= $linecnt} {
				if {$step == $linecnt} {
					set OK 1
					break
				}
				incr step $threshold
			}
			if {!$OK} {
				set msg "Input table (length $linecnt) will not divide equally by $threshold."
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set outfcnt [expr $linecnt / $threshold]
			set i 1
			while {$i <= $outfcnt} {
				set fnam $colpar$i$file_ext
				if {[string match $fnam [file tail $fnam]]} {
					set fnam [file join [pwd] $fnam]
				}
				if {[file exists $fnam]} {
					set msg "File '$fnam' already exists."
					ForceVal $tabed.message.e $msg
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
				incr i
			}
		}
		"xt" {
			if {[string length $threshold] <= 0} {
				set msg "No marker character given at 'threshold'."
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set outfcnt 1
			set fnam $colpar$outfcnt$file_ext
			if {[string match $fnam [file tail $fnam]]} {
				set fnam [file join [pwd] $fnam]
			}
			if {[file exists $fnam]} {
				set msg "File '$fnam' already exists."
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			foreach line [$tabed.bot.itframe.l.list get 0 end] {
				set line [string trim $line]
				if [string match $line $threshold] {
					incr outfcnt
					set fnam $colpar$outfcnt$file_ext
					if {[string match $fnam [file tail $fnam]]} {
						set fnam [file join [pwd] $fnam]
					}
					if {[file exists $fnam]} {
						set msg "File '$fnam' already exists."
						ForceVal $tabed.message.e $msg
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
				}
			}
		}
		"hh" {
			foreach fnam [glob -nocomplain [file join $colpar*]] {	
				set j [string length $colpar]
				set substr [string range $fnam $j end]
				set k [string first "." $substr]
				if {$k > 0} {
					incr k $j
					incr k -1
					set teststr [string range $fnam $j $k]
					if {[regexp {^[0-9]+$} $teststr]} {
						set msg "File $fnam already exists. Choose a different generic name."
						ForceVal $tabed.message.e $msg
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
				}
			}
		}
	}
	Block "Partitioning Data"
	set i 1
	set fnam $colpar$i$file_ext
	if {$colmode == "hh"} {
		catch {unset hmncty} 
		foreach line [$tabed.bot.itframe.l.list get 0 end] {
			set origline $line
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			catch {unset nuline}
			foreach item $line {
				set hstr [string trim $item]
				if {[string length $hstr] <= 0} {
					continue
				}
				break
			}
			if {![info exists hstr]} {
				set msg "Invalid data found (should be pitch string and count)."
				ForceVal $tabed.message.e $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set hstringval [ScoreHarmonicity $hstr]
			lappend hmncty($hstringval) $origline
		}
		if {![info exists hmncty]} {
			set msg "No harmonicity values found."
			ForceVal $tabed.message.e $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set nams [array names hmncty]
		set len [llength $nams]				
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set n_nam [lindex $nams $n]
			set m $n
			incr m
			while {$m < $len} {
				set m_nam [lindex $nams $m]
				if {$m_nam < $n_nam} {
					set nams [lreplace $nams $n $n $m_nam]
					set nams [lreplace $nams $m $m $n_nam]
					set n_nam $m_nam
				}
				incr m
			}
			incr n
		}
		set outcnt 0
		set outfcnt 0
		catch {unset outlist}
		foreach nam $nams {
			set fnam $colpar$outcnt$file_ext
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot open file $fnam for harmonicity value $hmncty"
				incr outfcnt		
				continue
			}
			foreach line $hmncty($nam) {
				puts $zit $line
			}
			close $zit
			lappend outlist $fnam
			incr outcnt		
			incr outfcnt
		}
		set outlist [ReverseList $outlist]		
	} elseif {![catch {open $fnam "w"} cfileId]} {
		switch -- $colmode {
			"xt" {
				foreach line [$tabed.bot.itframe.l.list get 0 end] {
					set line [string trim $line]
					if [string match $line $threshold] {
						catch {close $cfileId}
						lappend outlist $fnam
						incr i
						set fnam $colpar$i$file_ext
						if [catch {open $fnam "w"} cfileId] {
							break
						}
					} else {
						puts $cfileId $line
					}
				}
			}
			"yt" {
				set cnt 0
				set totalcnt 0
				foreach line [$tabed.bot.itframe.l.list get 0 end] {
					set line [string trim $line]
					puts $cfileId $line
					incr cnt
					incr totalcnt
					if {$totalcnt >= $linecnt} {
						break
					}
					if {$cnt >= $threshold} {
						catch {close $cfileId}
						lappend outlist $fnam
						incr i
						set fnam $colpar$i$file_ext
						if [catch {open $fnam "w"} cfileId] {
							break
						}
						set cnt 0
					}
				}
			}
		}
		catch {close $cfileId}
		lappend outlist $fnam
	}
	set bum 0
	set ccnt 0
	if [info exists outlist] {
		foreach fnam $outlist {
			if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
				incr bum
				continue
			}
			incr ccnt
		}
		set outcnt [llength $outlist]
		set outfailed [expr $outfcnt - $outcnt]	
		if {$ccnt > 0} {
			catch {unset rememd}
			set msg "Written $ccnt files to wkspace"
			if {$bum > 0} {
				append msg " & $bum not on wkspace"
			}
			AddNameToNameslist $colpar $tabed.bot.ktframe.names.list
		} else {
			set msg "Written $bum files, but not on workspace"
		}
		if {$outfailed} {
			append msg " & failed to write $outfailed."
		}
	} else {
		set msg "Failed to write any outfiles."
	}
	ForceVal $tabed.message.e $msg
 	$tabed.message.e config -bg $evv(EMPH)
	UnBlock
}

#------ Do vector operations, with NO params, and NOT CALLING external program

proc VVectors {colmode} {
	global colpar threshold CDPcolrun docol_OK tedit_message pvec record_temacro temacro temacrop evv
	global coltype col_ungapd_numeric outcolcnt tot_outlines col_x lmo tot_inlines tabedit_ns tabedit_bind2
	global col_tabname col_infnam tabed

	ForceVal $tabed.message.e ""

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	HaltCursCop
	set lmo VV
	lappend lmo $col_ungapd_numeric $colmode
	set tb $tabed.bot
	set colparam $colmode
	set pvec "x"

	if {([$tb.icframe.l.list index end] <= 0) || ([$tb.ocframe.l.list index end] <= 0)} {
		ForceVal $tabed.message.e "One or more columns missing."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]
	DisableOutputTableOptions 1

	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set len 0
	foreach c1 [$tb.icframe.l.list get 0 end] {
		lappend bazo $c1
		incr len
	}
	set i 1
	foreach c2 [$tb.ocframe.l.list get 0 end] {
		if {$i < $len} {
			set bazo [linsert $bazo $i $c2]
			incr i 2
			incr len
		} else {
			lappend bazo $c2
		}
	}
	foreach item $bazo {
		$tb.otframe.l.list insert end $item
	}
	if {[WriteOutputTable $evv(LINECNT_ONE)]} {
		EnableOutputTableOptions 0 1
	}
}

#------ Randomise table rows

proc RowRandomise {colmode} {
	global tabedit_ns tabedit_bind2 tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold col_tabname col_infnam tabed mix_perm

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$colmode == 0} {
		set colpar ""
		set lmo "RR"
	} elseif {![regexp {^[0-9]+$} $colpar] || $colpar < 2} {
		ForceVal $tabed.message.e "Invalid Value for size of groups."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	} else {
		set lmo "RRN"
	}
	lappend lmo $col_ungapd_numeric $colmode
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set len 0
	if {$colmode == 1} {
		set cnt 0
		set zz 0
		foreach item [$it get 0 end] {
			lappend gp($zz) $item
			incr cnt
			if {$cnt >= $colpar} {
				incr zz
				set cnt 0
			}
		}
		set len $zz
	} else {
		set len 0
		foreach item [$it get 0 end] {
			incr len
		}
	}
	RandomiseOrder $len
	set i 0
	if {$colmode == 1} {
		while {$i < $len} {
			foreach item $gp($mix_perm($i)) {
				lappend datlst $item
			}
			incr i
		}
	} else {
		while {$i < $len} {
			lappend datlst [$it get $mix_perm($i)]
			incr i
		}
	}
	$ot delete 0 end
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach itm $datlst {
		$ot insert end $itm
		puts $fileot $itm
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
}

#--- Do algebraic operation on column values

proc AlgebraCol {} {
	global colpar outlines tedit_message last_oc last_cr record_temacro temacro temacrop threshold evv
	global inlines coltype rcolno col_ungapd_numeric orig_incolget tround tot_outlines tabed
	global tot_inlines lmo insitu orig_inlines

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {	   	;#	If there's an input TABLE
		SetInout 1												;#	Reset default to act on input TABLE
	}
	HaltCursCop
	set lmo AF
	lappend lmo $col_ungapd_numeric	0									;#	 Remember last action.
	set tround 0

	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		ForceVal $tabed.message.e "No algebraic expression entered at 'N'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set newcolpar $colpar
	set n 0

;# FIND POSITIONS OF ALL VARIABLES IN ALGEBRAIC EXPRESSION

	while {$n < [string length $newcolpar]} {
		if {[regexp {^[Zz]$} [string index $newcolpar $n]]} {
			lappend nlist $n
		}
		incr n
	}
	if {![info exists nlist]} {
		ForceVal $tabed.message.e "Algebraic expression does not contain a 'Z': cannot proceed"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set i 0
	set OK 1

;# CONVERT TO FLOAT, IF NECESSARY

	set isfloated 0
	set iend [expr ([string length $newcolpar] - 1)]
	while {$OK} {
		if {[regexp {[0-9]} [string index $newcolpar $i]]} {	;# ignore 'log10' and atan2
			if {$i > 2} {
				set j [expr ($i - 3)]
				if {[regexp {log} [string range $newcolpar $j [expr ($i - 1)]]]} {
					incr i
					continue
				}
			}
			if {$i > 3} {
				set j [expr ($i - 4)]
				if {[regexp {log1|atan} [string range $newcolpar $j [expr ($i - 1)]]]} {
					incr i
					continue
				}
			}
			set j $i	
			while {[regexp {[0-9]} [string index $newcolpar $j]]} {
				incr j
				if {$j > $iend} {
					append newcolpar ".0"
					set iend [expr ([string length $newcolpar] - 1)]
					set isfloated 1
					set OK 0
					break
				}
			}
			if {$OK} {
				if {![regexp {[\.Zz]} [string index $newcolpar $j]]} {
					if {($i > 0 ) && [regexp {\.} [string index $newcolpar [expr $i - 1]]]} {
						set i $j
						continue
					} 
					set zz [string range $newcolpar 0 [expr ($j - 1)]]
					append zz ".0"
					append zz [string range $newcolpar $j end]
					set newcolpar $zz
					set iend [expr ([string length $newcolpar] - 1)]
					incr j 2
					set i $j
					set isfloated 1
				}
			}
		}
		incr i
		if {$i >= $iend} {
			break
		}
	}

;# RECALCULATE POSITIONS OF ALL VARIABLES IN ALGEBRAIC EXPRESSION

	set n 0
	if {$isfloated} {
		unset nlist
		while {$n < [string length $newcolpar]} {
			if {[regexp {^[Zz]$} [string index $newcolpar $n]]} {
				lappend nlist $n
			}
			incr n
		}
	}
	set i 0
	set OK 1


;#	CHANGE TO VALID EXPRESSION FORMAT e.g "-5.222N" to "(-5.222 * N)"

	while {$OK} {
		set iend [expr ([string length $newcolpar] - 1)]
		if {[set pos [lsearch $nlist $i]] >= 0} {		;#	if this character is a 'Z'
			if {$i < $iend} {
				set j [expr ($i + 1)]
				if {[regexp {[0-9\^\|]} [string index $newcolpar $j]]} {
					ForceVal $tabed.message.e "Invalid algebraic expression: cannot proceed"
 					$tabed.message.e config -bg $evv(EMPH)
					return
				}
			}
			if {$i > 0} {								;#  and it's not the first character
				set j [expr ($i - 1)]					;#  if the preceding character is a number (e.g. making 2Z)
				if {[regexp {[0-9]} [string index $newcolpar $j]]} {
					set k $j							;#  search backwards for a whole numeric expression (e.g.  -5.222Z)
					while {$k > 0} {
						incr  k -1
						if {![IsNumeric [string range $newcolpar $k $j]]} {
							incr k
							break
						}
					}
					if {$k > 0} {
						set newstr [string range $newcolpar 0 [expr ($k - 1)]]
					} else {
						set newstr ""
					}
					append newstr "("					;#  replace it with a brackted expression (e.g. (-5.222 * Z))
					append newstr [string range $newcolpar $k $j]
					append newstr " * Z)"
					append newstr [string range $newcolpar [expr ($i + 1)] end]
					set newcolpar $newstr
					catch {unset newnlist}				;#  re-evaluate positions of 'N's both here, and beyond here , in 'nlist'
					if {$pos > 0} {
						lappend newnlist [lrange $nlist 0 [expr ($pos - 1)]]
					}
					lappend newnlist [expr ($i + 4)]		;# move this 'N'-position by 4 places
					incr pos
					foreach uu [lrange $nlist $pos end] {
						lappend newnlist [expr ($uu + 5)]	;# move subsequent 'N'-positions vals by 5 places
					}
					set nlist $newnlist
					incr i 5							;#  force character cnt forward by 5 (skips inserted brkts,star and 2 spaces)
				}
			}
		}
		incr i
		if {$i >= [string length $newcolpar]} {
			break
		}
	}						
	set n "normal"
	set d "disabled"
	set tb $tabed.bot
	if {![file exists $evv(COLFILE1)]} {
		ForceVal $tabed.message.e "No column selected"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {$insitu} {									;# establish which col to output to on
		set fnam $evv(COLFILE1)
		set ll $tb.icframe.l.list
		set lcnt "inlines"
		foreach zz [$ll get 0 end] {
			lappend tmpst $zz
		}
	} else {
		set fnam $evv(COLFILE2)
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
		set last_oc [$tb.ocframe.l.list get 0 end]
		set last_cr $col_ungapd_numeric					;#	In normal situation.
		DisableOutputColumnOptions
	}
	$ll delete 0 end

	if {$insitu} {
		foreach zz $tmpst {
			set yy [DoAlgebra $nlist $newcolpar $zz]
			if {[string length $yy] <= 0} {
				return
			}
			lappend outlist $yy
		}
		foreach yy $outlist {
			$ll insert end $yy
		}
	} else {
		foreach zz [$tb.icframe.l.list get 0 end] {
			set yy [DoAlgebra $nlist $newcolpar $zz]
			if {[string length $yy] <= 0} {
				return
			}
			lappend outlist $yy
		}
	}
	foreach yy $outlist {
		$ll insert end $yy
	}
	set outlines $inlines
	ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	if [catch {open $fnam "w"} fileoc] {
		ForceVal $tabed.message.e  "Cannot open temporary file $fnam to write new column data"
	 	$tabed.message.e config -bg $evv(EMPH)
		$ll delete 0 end		;#	Clear existing listing
		set $lcnt ""
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
	} else {
		set $lcnt 0
		foreach line [$ll get 0 end] {
			puts $fileoc $line
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		close $fileoc						;#	Write data to file
  		if {!$insitu} {
			$tb.kcframe.oky config -state $n
			$tb.kcframe.okz config -state $n
			if {[info exists tot_inlines] && ($tot_inlines > 0)} {
				if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
					SetKCState "o"
					ForceVal $tb.kcframe.e $rcolno
				} elseif {$outlines == $tot_inlines} {
					set coltype "i"
					$tb.kcframe.oki config -state $n
					$tb.kcframe.oko config -state $d
					$tb.kcframe.okr config -state $n
					set rcolno $orig_incolget
					ForceVal $tb.kcframe.e $rcolno
					$tb.kcframe.e config -state $n -fg [option get . foreground {}]
				} else {
					SetKCState "k"
				}
			} elseif {[info exists tot_outlines] && ($tot_outlines > 0)} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
			$tb.kcframe.okk config -state $n
			$tb.kcframe.ok config -state $n
		}
	}
}

# Substitute value 'zz' in algebraic expression 'algform' at positions listed in 'nlist'

proc DoAlgebra {nlist algform zz} {
	global tabed evv

	set par_end [expr ([string length $algform] - 1)]
	set algexpr ""
	set lastpos 0
	foreach pos $nlist {
		if {$pos > 0} {
			append algexpr [string range $algform $lastpos [expr ($pos - 1)]]
		}
		append algexpr $zz
		set lastpos [expr ($pos + 1)]
	}
	if {$pos < $par_end} {
		append algexpr [string range $algform $lastpos end]
	}
	if [catch {set zz [expr ($algexpr)]} zub] {
		ForceVal $tabed.message.e "Invalid algebraic expression : '$algform' produces '$algexpr'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return ""
	}
	return $zz
}

#------ Swap table rows or columns

proc RowSwap {colmode} {
	global tabedit_ns tabedit_bind2 tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold col_tabname col_infnam tabed record_temacro temacrop lmo

	HaltCursCop
	set lmo SC
	lappend lmo $col_ungapd_numeric	$colmode

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}

	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists colpar] || ![regexp {[0-9]} $colpar]} {
		ForceVal $tabed.message.e "No valid parameter N value given."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists threshold] || ![regexp {[0-9]} $threshold]} {
		ForceVal $tabed.message.e "No valid threshold value given."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set cpar  [expr $colpar -1]
	set thold [expr $threshold -1]
	switch -- $colmode {
		1 -
		2 -
		3 {		;#	SWAP COLUMNS
			if {$cpar == $thold} {
				ForceVal $tabed.message.e "You can't swap a column with itself."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$cpar >= $incols || $cpar < 0} {
				ForceVal $tabed.message.e "Parameter N is out of range."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			} elseif {$thold >= $incols || $thold < 0} {
				ForceVal $tabed.message.e "'Threshold' is out of range."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set ccnt 1
			foreach line [$it get 0 end] {
				set line [split $line]
				catch {unset gog}
				foreach item $line {
					if {[string length $item] > 0} {
						lappend gog $item
					}
				}
				set swapcol1 [lindex $gog $cpar]
				set swapcol2 [lindex $gog $thold]
				switch -- $colmode {
					1 {
						set gog [lreplace $gog $thold $thold $swapcol1]
						set gog [lreplace $gog $cpar $cpar $swapcol2]
					}
					2 {	;#	COPY VALS IN COL threshold TO COL N
						set gog [lreplace $gog $cpar $cpar $swapcol2]
					}
					3 { ;#	REPLACE NUMERIC PART OF VAL IN COL N by THRESHOLD
						if {![regexp {[0-9]+} $swapcol1]}  {
							ForceVal $tabed.message.e "No numeric part to value '$swapcol1' in line $ccnt."
	 						$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set len [string length $swapcol1]
						set gg 0
						catch {unset startnum}
						catch {unset endnum}
						while {$gg < $len} {
							set char [string index $swapcol1 $gg]
							if {![info exists startnum]} {
								if {[regexp {[0-9]} $char]} {
									if {$gg > 0} {
										incr gg -1
										if {[regexp {\.} $char]} {
											if {$gg > 0} {
												incr gg -1
												if {[regexp {\-} $char]} {
													set startnum $gg
													incr gg 2
												} else {
													incr gg
													set startnum $gg
													incr gg
												}
											} else {
												set startnum $gg
												incr gg
											}
										} else {
											incr gg
											set startnum $gg
										}
									} else {
										set startnum $gg
									}
								}
							} elseif {![regexp {[0-9]} $char]} {
								set endnum $gg
								break
							}
							incr gg
						}
						if {![info exists endnum]} {
							set endnum  $gg
						}
						incr startnum -1
						set newval ""
						if {$startnum >= 0} {
							append newval [string range $swapcol1 0 $startnum]
						}
						append newval $swapcol2 [string range $swapcol1 $endnum end]
						set gog [lreplace $gog $cpar $cpar $newval]
					}
				}
				set line [lindex $gog 0]
				foreach item [lrange $gog 1 end] {
					append line " " $item
				}
				lappend datlst $line
				incr ccnt
			}
		} 
		0 {	;#	SWAP ROWS
			if {$cpar == $thold} {
				ForceVal $tabed.message.e "You can't swap a row with itself.."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$cpar >= $tot_inlines || $cpar < 0} {
				ForceVal $tabed.message.e "Parameter N is out of range."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			} elseif {$thold >= $tot_inlines || $thold < 0} {
				ForceVal $tabed.message.e "'Threshold' is out of range."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			foreach line [$it get 0 end] {
				lappend datlst $line
			}
			set swapline1 [lindex $datlst $cpar]
			set swapline2 [lindex $datlst $thold]
			set datlst [lreplace $datlst $thold $thold $swapline1]
			set datlst [lreplace $datlst $cpar $cpar $swapline2]
		}
	}
	$ot delete 0 end
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach itm $datlst {
		$ot insert end $itm
		puts $fileot $itm
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
}

#------ Get rid of text in entries

proc KillText {colmode} {
	global colpar threshold CDPcolrun docol_OK outlines threshtype tedit_message last_oc last_cr evv
	global inlines coltype rcolno col_ungapd_numeric orig_incolget tround tot_outlines col_x
	global colmode_exception tot_inlines lmo insitu orig_inlines record_temacro temacro temacrop tabed

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		ForceVal $tabed.message.e "No comparison text given at 'N'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {($colmode == "EN") && (![regexp {^[0-9]+$} $colpar] || ($colpar <= 0))} {
		ForceVal $tabed.message.e "Numeric value needed in 'N'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return

	}
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {	   	;#	If there's an input TABLE
		SetInout 1												;#	Reset default to act on input TABLE
	}
	HaltCursCop
	if {![string match "copy" $colmode] && ![string match "recycle" $colmode]} {
		set lmo K
		lappend lmo $col_ungapd_numeric $colmode				;#	 Remember last action.
	}
	set tb $tabed.bot
	set colparam $colmode

	catch {unset colmode_exception}
	if {![file exists $evv(COLFILE1)]} {
		ForceVal $tabed.message.e "No column selected"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tround 0

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {!$insitu} {
		set last_oc [$tb.ocframe.l.list get 0 end]
		set last_cr $col_ungapd_numeric					;#	In normal situation.
		DisableOutputColumnOptions 
	}													;#	Special varieites of addition
	set threshold ""
	ForceVal $tabed.mid.par2 $threshold
	
	if {$insitu} {									;#	establish which col to act on
		set ll $tb.icframe.l.list
		set lcnt "inlines"
	} else {
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
	}
	set zcnt [string length $colpar]
	set docol_OK 1

	if {$colmode == "EN"} {
		set changed 1
		foreach item [$tb.icframe.l.list get 0 end] {
			set thislen [string length $item]
			if {$thislen <= $colpar} {
				ForceVal $tabed.message.e "Some line(s) too short to delete $colpar characters"
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			lappend nulist [string range $item 0 [expr $thislen - $colpar - 1]]
		}
	} else {
		foreach item [$tb.icframe.l.list get 0 end] {
			set ycnt [string length $item]
			set k [string first $colpar $item]
			if {$k >= 0} {
				if {$ycnt == $zcnt} {
					set changed 1
					ForceVal $tabed.message.e "This process will delete at least one entire row entry: Cannot proceed"
	 				$tabed.message.e config -bg $evv(EMPH)
					set docol_OK 0
					break
				}
				switch -- $colmode {
					"kC" {
						set zup ""
						if {$k > 0} {
							incr k -1
							append zup [string range $item 0 $k]
							incr k
						}
						incr k $zcnt
						if {$k < $ycnt} {
							append zup [string range $item $k end]
						}
						lappend nulist $zup
						set changed 1
					}
					"kD" {
						incr k $zcnt
						incr k -1
						set item [string range $item 0 $k]
						lappend nulist $item
						if {$k < [expr $ycnt - 1]} {
							set changed 1
						}
					}
					"kE" {
						set changed 1
						if {$k == 0} {
							ForceVal $tabed.message.e "This process will delete at least one entire row entry: Cannot proceed"
	 						$tabed.message.e config -bg $evv(EMPH)
							set docol_OK 0
							break
						}
						incr k -1
						set item [string range $item 0 $k]
						lappend nulist $item
					}
					"kF" {
						set changed 1
						set item [string range $item $k end]
						lappend nulist $item
					}
					"kG" {
						set changed 1
						incr k $zcnt
						if {$k >= $ycnt} {
							ForceVal $tabed.message.e "This process will delete at least one entire row entry: Cannot proceed"
	 						$tabed.message.e config -bg $evv(EMPH)
							set docol_OK 0
							break
						}
						set item [string range $item $k end]
						lappend nulist $item
					}
				}

			} else {
				lappend nulist $item
			}
		}
	}
	if {![info exists changed]} {
		ForceVal $tabed.message.e "This process will not change the input column"
		$tabed.message.e config -bg $evv(EMPH)
		set docol_OK 0
	}
	if {$docol_OK} {
		$ll delete 0 end
		foreach item $nulist {
			$ll insert end $item
		}
		if {$insitu && ($colmode != "copy")} {
			set fnam $evv(COLFILE1)
		} else {
			set fnam $evv(COLFILE2)
		}
		WriteOutputColumn $fnam $ll $lcnt 0 0 0
	}
}

proc DoTimer {} {
	global pr_timer ocl evv

	catch {unset ocl}
	set f .timer
	if [Dlg_Create $f "TIME TAP PAD" "set pr_timer 0" -borderwidth $evv(SBDR)] {
		frame $f.0 -borderwidth $evv(SBDR)
		frame $f.1 -borderwidth $evv(SBDR)
		frame $f.2 -borderwidth $evv(SBDR)
		button $f.0.quit  -text "Close" -command "catch {unset ocl}; set pr_timer 0" -highlightbackground [option get . background {}]
		pack $f.0.quit -side top
#RWD width was 8
		button $f.1.times -text "Tap Times Here" -command "Timer"  -highlightbackground [option get . background {}]
		pack $f.1.times -side top
		button $f.2.stop -text "Keep Times"  -width 12 -command {set pr_timer [TimeCalc]} -highlightbackground [option get . background {}]
		button $f.2.res  -text "Start Again" -width 12 -command {catch {unset ocl}} -highlightbackground [option get . background {}]
		pack $f.2.stop $f.2.res -side left -padx 2
		pack $f.0 $f.1 $f.2 -side top -fill x -expand true
		bind $f <Escape> {set pr_timer 0}
	}
	.timer.1.times config -state normal -bg $evv(EMPH)
	.timer.2.stop  config -state normal
	raise $f
	set pr_timer 0
	set finished 0
	My_Grab 0 $f pr_timer $f.1.times
	while {!$finished} {
		tkwait variable pr_timer
		if {$pr_timer == 0} {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Timer {} {
	global ocl
	lappend ocl [clock clicks]
}

proc TimeCalc {} {
	global ocl evv

	if {![info exists ocl] || ([llength $ocl] <= 0)} {
		return 1
	}
	.timer.1.times config -state disabled -bg [option get . background {}]
	.timer.2.stop  config -state disabled
	set baseval [expr double([lindex $ocl 0]) / $evv(CLOCK_TICK)]
	set n 0
	foreach time $ocl {
		set time [expr (double($time) / $evv(CLOCK_TICK)) - $baseval]
		set ocl [lreplace $ocl $n $n $time]
		incr n
	}
	set ocl [lreplace $ocl 0 0 0.0]
	return 0
}

#################

proc TabRunMsgs {} {
	global col_infnam freetext incolget orig_incolget col_infilelist incols tot_inlines tabed evv
	global colinmode seq_stat brk_stat env_stat c_incols c_inlines coltype outlines coltype rcolno 
	global tabedit_bind2 orig_inlines okz readonlyfg readonlybg


	HaltCursCop
	set n "normal"
	set d "disabled"
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set tb $tabed.bot
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set fnam [file join $evv(URES_DIR) $evv(RUNMSGS)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		ForceVal $tabed.message.e "No information on previous process runs"
		return
	}
	if [catch {open $fnam "r"} cfileId] {
		ForceVal $tabed.message.e "Cannot open file $fnam"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}

	set col_infnam $evv(DFLT_OUTNAME)
	append col_infnam "0" $evv(TEXT_EXT)
	set col_preset 0
	ChangeColSelect 0
	set freetext 1
	ChangeColTextMode

	catch {unset incolget}
	set orig_incolget ""
	ForceVal $tabed.bot.gframe.got $orig_incolget
	$tabed.bot.gframe.got config -bg [option get . background {}]
	ForceVal $tb.gframe.e ""
	$tb.itab config -text "INPUT TABLE"
	$tb.itframe.f0 config -text "\n\n"

	$tb.itframe.l.list delete 0 end
	SetInout 0
	set is_brk 0
	set is_env 0
	set is_seq 0
	SetEnvState 0
	set llcnt 0
	set incols 0
	set maxcols 0
	set has_non_comment_lines 0
	while { [gets $cfileId line] >= 0} {
		catch {unset new_colline}
		set indata [split $line]
		foreach item $indata {
			if {[string length $item] > 0} {
				incr incols
				lappend new_colline $item
			}
		}
		if [info exists new_colline] {
			set test [lindex $new_colline 0]
			if {!([string match \;* $test] || [string match "e" $test] || [string match "s" $test])} {
				if {$incols > $maxcols} {		;#	Don't count columns in comments, or e and s lines
					set maxcols $incols				
				}
			} elseif {![string match \;* $test]} {
				set has_non_comment_lines 1		;#	Check if any non-comment lines exist with just 'e' or 's'
			}
			set incols 0
			set ll [llength $new_colline]
			set i 0
			set zort ""
			while {$i < $ll} {
				append zort [lindex $new_colline $i] " "
				incr i
			}				
			set zlen [string length $zort]
			incr zlen -2
			set zort [string range $zort 0 $zlen]
			$tb.itframe.l.list insert end $zort
			incr llcnt
		}
	}
	if {$maxcols <= 0} {
		if {$has_non_comment_lines} {	   	;#	i.e. has lines of 'e' or 's' only !!
			set incols 1
		} else {
			ForceVal $tabed.message.e "No significant data found in file. (All comments)"
		 	$tabed.message.e config -bg $evv(EMPH)
			catch {close $cfileId}
			return
		}
	} else {
		set incols $maxcols
	}
	if {[file exists $col_infnam]} {
		if [catch {file copy -force $fnam $col_infnam} zit] {
			Inf "Cannot get data from Run message file to Table Editor file"
			$tb.itframe.l.list delete 0 end
			catch {close $cfileId}
			return
		}
	} else {
		if [catch {file copy $fnam $col_infnam} zit] {
			Inf "Cannot get data from Run message file to Table Editor file"
			$tb.itframe.l.list delete 0 end
			catch {close $cfileId}
			return
		}
	}
	if {$colinmode == 2} {
		$tabed.topa.seq config -state $d -text ""
		set seq_stat "disabled"
	} elseif {$incols != 3} {
		$tabed.topa.seq config -state $d -text ""
		set seq_stat "disabled"
	} else {
		$tabed.topa.seq config -state $n -text "Seq"
		set brk_stat "disabled"
		set env_stat "disabled"
		set seq_stat "normal"
		set is_env 0
		set is_brk 0
	}
	if {$is_brk && ($incols == 2)} {
		$tabed.topa.brk config -state $n -text "Brk"
		set brk_stat "normal"
		set seq_stat "disabled"
	} else {
		$tabed.topa.brk config -state $d -text ""
		$tabed.topa.env config -state $d -text ""
		set env_stat "disabled"
		set seq_stat "disabled"
	}
	if {$is_env} {
		set env_stat "normal"
		set seq_stat "disabled"
	} else {
		set env_stat "disabled"
	}
	close $cfileId
	if {!$col_preset} {
		lappend col_infilelist $fnam
		lappend c_incols $incols
		lappend c_inlines $llcnt
		set tot_inlines $llcnt
		ForceVal $tabed.bot.itframe.f.e2 $tot_inlines
	}
	SetInout 1
	$tabed.bot.itframe.l.list config -bg $evv(EMPH)
	$tabed.bot.otframe.l.list config -bg [option get . background {}]

	ForceVal $tb.itframe.f.e $incols

	$tb.gframe.e config -state $n
	$tb.gframe.ok config -state $n
	set incolget 1
	ForceVal $tb.gframe.e $incolget
	$tb.gframe.blob.skip config -state $n
	DisableOutputColumnOptions 
	ForceVal $tb.kcframe.e ""
	set coltype "o"
	$tb.ktframe.bbb1.6 config -state $d
	if [info exists outlines] {
		if {$outlines > 0} {
			set coltype "k"
#RADICAL JAN 2004
			set okz -1
			$tb.kcframe.okk config -state $n
			$tb.kcframe.oky config -state $n
			$tb.kcframe.okz config -state $n
			$tb.kcframe.ok  config -state $n
		}
		if {$tot_inlines == $outlines} {
			$tb.kcframe.oki config -state $n
			$tb.kcframe.okr config -state $n
			$tb.kcframe.okk config -state $n
			$tb.kcframe.ok  config -state $n
			set rcolno $incolget
			ForceVal $tb.kcframe.e $rcolno
		}
	} else {
		$tb.ktframe.fnm config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		bind $tb.ktframe.names.list <ButtonRelease-1> {}
		catch {unset tabedit_bind2}
		$tb.ktframe.bbb.1 config -state $d
		$tb.ktframe.bbb.2 config -state $d
		$tb.ktframe.bbb.3 config -state $d
		$tb.ktframe.bbb1.4 config -state $d
		$tb.ktframe.bxxb config -state $d -text ""
		$tb.ktframe.bbb1.6 config -state $d
	}
	$tb.itframe.f0 config -text "FILENAME: [file tail $fnam]\n\n"

	$tb.itframe.tcop config -state $n
	set orig_inlines 0
	$tb.itframe.l.list xview moveto 0.0
}


#----- Create vectored batchfile

proc VectoredBatchfile {colmode} {
	global col_files_list outcolcnt CDPcolrun docol_OK tot_outlines pa record_temacro temacro evv
	global lmo col_ungapd_numeric colpar tot_inlines tabedit_ns tabedit_bind2 ot_has_fnams colinmode temacrop threshold
	global col_tabname col_infnam tabed ocl chlist ch col_x pa bbbatch advecval truncvecval 

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	HaltCursCop
	set lmo vB
	lappend lmo $col_ungapd_numeric $colmode
	set tb $tabed.bot
	ForceVal $tabed.message.e ""
	$tabed.message.e config -bg [option get . background {}]
	if {$ot_has_fnams} {						 ;#	If new fnames entered, use them - else use previous
		catch {unset col_files_list}
		foreach fnam [$tb.otframe.l.list get 0 end] {
			lappend col_files_list $fnam
		}
	}
	if {![info exists col_files_list] || ([set param_cnt [llength $col_files_list]] < 2)} {
		ForceVal $tabed.message.e "Not enough files selected."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$param_cnt > 9} {
		ForceVal $tabed.message.e "Too many files selected"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	incr param_cnt	;# no of params = number if vedotrs input (no-of-files minus 1) + vals for position of infile and outfile

	set is_synth 0

	set progline [lindex $col_files_list 0]
	if [catch {open $progline "r"} fId] {
		Inf "Cannot open the vector file '$vectorfile'"
		return
	}
	set cntt 0 
	while {[gets $fId line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				if {$cntt == 0} {
					if {![string match $item "synth"]} {
						break
					} 
				} else {
					switch -- $item {
						"wave"  {
							set is_synth 1
						}
						"noise" {
							set is_synth 2
						}
						"silence" {
							set is_synth 3
						}
					}
					break
				}
				
			}
			incr cntt
		}
		break
	}
	close $fId
	if {!$is_synth} {
		if {![info exists chlist] || ([llength $chlist] <= 0)} {
			ForceVal $tabed.message.e  "No files have been selected on the workspace page."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	set icnt 0
	if {!$is_synth} {
		set thistype $pa([lindex $chlist 0],$evv(FTYP))
		foreach fnam $chlist {
			if {$pa($fnam,$evv(FTYP)) != $thistype} {
				ForceVal $tabed.message.e  "Not all files on the CHOSEN FILES LIST are of the same type."
		 		$tabed.message.e config -bg $evv(EMPH)
				catch {unset ocl}
				return
			}
			lappend infiles $fnam
			incr icnt
		}
	}
	set vector_no 1
	foreach vectorfile [lrange $col_files_list 1 end] {
		if [catch {open $vectorfile "r"} fId] {
			Inf "Cannot open the vector file '$vectorfile'"
			return
		}
		set vcnt 0
		while {[gets $fId line] >= 0} {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend vector($vector_no) $item
					incr vcnt
				}
			}
		}
		catch {close $fId}
		if {$icnt > 0} {
			if {($icnt != 1) && ($vcnt != $icnt)} {
				ForceVal $tabed.message.e  "No. of vector vals in file [expr $vector_no + 1] ($vcnt) not same as no. of chosen files ($icnt)"
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	}

	set fnam [lindex $col_files_list 0]
	if [catch {open $fnam "r"} fId] {
		ForceVal $tabed.message.e  "Cannot open the batchfile $fnam"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set bcnt 0
	catch {unset bbbatch}
	while {[gets $fId line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend bbbatch $item
				incr bcnt
			}
		}
	}
	catch {close $fId}
	
	if {![CreateColumnParams "vB" $param_cnt]} {
		return
	}
	if {$is_synth} {
		set col_x(1) 0
	} elseif {$col_x(1) < 1} {
		ForceVal $tabed.message.e  "First column number cannot be less than 1"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$bcnt < $col_x(1)} {
		ForceVal $tabed.message.e  "Batchfile does not have enough columns to tally with input parameters"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set param_no 2
	while {$param_no <= $param_cnt} {
		if {!$is_synth} {
			if {$col_x(1) >= $col_x($param_no)} {
				ForceVal $tabed.message.e  "Column numbers not consistent (Infile col must be before outfile and param cols)"
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		if {$bcnt < $col_x($param_no)} {
			ForceVal $tabed.message.e  "Batchfile does not have enough columns to tally with input parameters"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set m [expr $param_no - 1]
		set k $param_no
		while {$k <= $param_cnt} {
			if {$col_x($m) == $col_x($k)} {
				ForceVal $tabed.message.e  "You cannot use the same column for 2 different items"
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			incr k
		}
		incr param_no
	}
	$tb.ocframe.l.list delete 0 end		;#	Clear existing listing of output col
	$tb.icframe.l.list delete 0 end		;#	Clear existing listing of input col
	$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
	set outcolcnt 0
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines 0
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	DisableOutputTableOptions 0

	if {$record_temacro} {
		lappend temacro $lmo
		set zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set i 0
	if {!$is_synth} {
		set thisext [file extension [lindex $infiles 0]]
	}
	set param_no 1
	while {$param_no <= $param_cnt} {
		set col_xx($param_no)  [expr $col_x($param_no) - 1]
		incr param_no
	}
	if {$icnt == $vcnt} {
		while {$i < $vcnt} {
			set vector_no 1
			set j ""
			if {$advecval} {
				set j [ReplaceDotsAndTrailingZerosInValue [lindex $vector($vector_no) $i]]
				if {$truncvecval} {
					set j [TruncVecVal $j]
				}
			}
			set fnam [lindex $infiles $i]
			set rnam [file rootname [file tail $fnam]]
			set thisline [lreplace $bbbatch $col_xx(1) $col_xx(1) $fnam]
			set thisline [lreplace $thisline $col_xx(2) $col_xx(2) $rnam$evv(BATCHOUT_EXT)$j]
			set param_no 3
			while {$param_no <= $param_cnt} {
				set thisline [lreplace $thisline $col_xx($param_no) $col_xx($param_no) [lindex $vector($vector_no) $i]]
				incr param_no
				incr vector_no
			}
			$tb.otframe.l.list insert end $thisline
			incr i
		}
	} else {
		switch -- $is_synth {
			0 {			;#	Normal case, base of outfilename is from chosen files list
				set fnam [lindex $infiles 0]
				set rnam [file rootname [file tail $fnam]]
			}
			1 {			;#	Synthesis cases use orig-outfilename as basis for new names
				set fnam [lindex $bbbatch 3]
				set rnam [file rootname [file tail $fnam]]
			}
			default {
				set fnam [lindex $bbbatch 2]
				set rnam [file rootname [file tail $fnam]]
			}
		}
		while {$i < $vcnt} {
			set vector_no 1
			if {$is_synth} {
				set thisline $bbbatch		;#	No inputfilename to replace
			} else {
				set thisline [lreplace $bbbatch $col_xx(1) $col_xx(1) $fnam]
			}
			set j $i					;#	Names indexed from batchfile line-nos
			if {$advecval} {			;#	Except if specified to index with vector value
				set j [ReplaceDotsAndTrailingZerosInValue [lindex $vector($vector_no) $i]]
				if {$truncvecval} {
					set j [TruncVecVal $j]
				}
			}
			set thisline [lreplace $thisline $col_xx(2) $col_xx(2) $rnam$evv(BATCHOUT_EXT)$j]
			set param_no 3
			while {$param_no <= $param_cnt} {
				set thisline [lreplace $thisline $col_xx($param_no) $col_xx($param_no) [lindex $vector($vector_no) $i]]
				incr param_no
				incr vector_no
			}
			$tb.otframe.l.list insert end $thisline
			incr i
		}
	}
	if [catch {open $evv(COLFILE3) "w"} fileoc] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set tot_outlines 0
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		set outcolcnt 0
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	} else {
		set outcolcnt 0
		foreach line [$tb.otframe.l.list get 0 end] {
			if {$tot_outlines == 0} {
				set zline [split $line]
				foreach item $zline {
					if {[string length $item] > 0} {
						incr outcolcnt
					}
				}
			}
			puts $fileoc $line
			incr tot_outlines
		}
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		close $fileoc
		EnableOutputTableOptions 0 1
	}
	set colinmode 0
	set ot_has_fnams 0
	ChangeColSelect 0
}

proc VectoredBatchfileHelp {} {
	global pr_vbhelp  vbl evv

	set f .vbhelp
	if [Dlg_Create $f "VECTORED BATCHFILES" "set pr_vbhelp 0" -borderwidth $evv(BBDR)] {
		set fb [frame $f.butn -borderwidth $evv(SBDR)]		;#	frame for buttons
		button $fb.ok0   -text "Close"   -command "set pr_vbhelp 0" -highlightbackground [option get . background {}]
		button $fb.ok1   -text "What Are They?" -command "set pr_vbhelp 1" -width 20 -highlightbackground [option get . background {}]
		button $fb.ok2   -text "How To Make Them" -command "set pr_vbhelp 2" -width 20 -highlightbackground [option get . background {}]
		button $fb.ok3   -text "Parameters,Save,Run" -command "set pr_vbhelp 3" -width 20 -highlightbackground [option get . background {}]
		label $fb.dum -text "              "
		pack $fb.ok0 -side right
		pack $fb.ok1 $fb.ok2 $fb.ok3 $fb.dum -side left -padx 1
		pack $f.butn -side top -fill x
		bind $f <Escape> {set pr_vbhelp 0}
	}
	wm resizable $f 1 1
	set pr_vbhelp 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_vbhelp
	while {!$finished} {
		tkwait variable pr_vbhelp
		switch -- $pr_vbhelp {
			0 { set finished 1 }
			1 { CDP_Specific_Usage $evv(TE_22) 0 }
			2 { CDP_Specific_Usage $evv(TE_23) 0 }
			3 { CDP_Specific_Usage $evv(TE_24) 0 }
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ generate excise file in samples

proc SpliceMak {colmode p_cnt} {
	global wl lmo col_ungapd_numeric threshold colpar wstk tot_inlines incols tot_outlines outcolcnt tabedit_ns evv
	global record_temacro temacro temacrop col_x CDPcolrun docol_OK
	global col_tabname col_infnam tabed insitu inlines

	SetInout 0
	HaltCursCop
	catch {unset colmode_exception}
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists inlines] || ([string length $inlines] <= 0) || ($inlines <= 0)} {
		Inf "No column listed"
		return
	}

	set lmo SM
	if [info exists col_ungapd_numeric] {
		lappend lmo $col_ungapd_numeric
	} else {
		lappend lmo 0
	}
	lappend lmo $colmode $p_cnt

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	if {![CreateColumnParams $colmode $p_cnt]} {
		return
	}
	set colcmd [file join $evv(CDPROGRAM_DIR) columns]
	lappend colcmd $evv(COLFILE1)
	set i 1
	while {$i <= $p_cnt} {
		lappend colcmd $col_x($i)
		incr i
	}
	lappend colcmd -$colmode
	set colpar ""
	ForceVal $tabed.mid.par1 $colpar
	set threshold ""
	ForceVal $tabed.mid.par2 $threshold
	set docol_OK 0

	set sloom_cmd [linsert $colcmd 1 "#"]

	$tb.otframe.l.list delete 0 end

	if [catch {open "|$sloom_cmd"} CDPcolrun] {
		ErrShow "$CDPcolrun"
   	} else {
   		fileevent $CDPcolrun readable "DisplayNewColumn $tb.otframe.l.list"
		vwait docol_OK
   	}

	if {$docol_OK} {
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
	} else {
		DisableOutputTableOptions 1
	}
}

#---- Display maximum sampleval

proc Display_Maxsamp_Info_Ted {} {
	global CDPmaxId done_maxsamp maxsamp_line tabed evv

	if {[info exists CDPmaxId] && [eof $CDPmaxId]} {
		catch {close $CDPmaxId}
		set done_maxsamp 1
		return
	} else {
		gets $CDPmaxId line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		} elseif [string match INFO:* $line] {
			return
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			ForceVal $tabed.message.e  "$line"
		 	$tabed.message.e config -bg $evv(EMPH)
			catch {close $CDPmaxId}
			set done_maxsamp 1
			return
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			ForceVal $tabed.message.e  "$line"
		 	$tabed.message.e config -bg $evv(EMPH)
			catch {close $CDPmaxId}
			set done_maxsamp 1
			return
		} elseif [string match KEEP:* $line] {
			set line [string range $line 6 end] 
			set maxsamp_line $line
			catch {close $CDPmaxId}
			set done_maxsamp 1
			return
		} else {
			ForceVal $tabed.message.e "Invalid Message received from maxsamp program."
		 	$tabed.message.e config -bg $evv(EMPH)
			catch {close $CDPmaxId}
			set done_maxsamp 1
			return
		}
	}
	update idletasks
}			

#---- Join tables, one after the other.

proc JoinTables {filenames} {
	global tabed

	set tb $tabed.bot
	set cnt 0
	foreach fnam $filenames {
		if [catch {open $fnam "r"} zfId] {
			Inf "Cannot Open File '$fnam'"
			return 0 
		}
		while {[gets $zfId line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			lappend linelist $line
			incr cnt
		}
		close $zfId
	}
	if {$cnt <= 0} {
		return 0
	}
	foreach line $linelist {
		$tb.otframe.l.list insert end $line			
	}
	return 1
}

#---- Interleave the rows odf 2 tables

proc InterpJoinTables {filenames} {
	global tabed

	set tb $tabed.bot
	set cnt 0
	set filecnt 0
	foreach fnam $filenames {
		set here $filecnt
		set instep [expr $filecnt + 1]
		if [catch {open $fnam "r"} zfId] {
			Inf "Cannot Open File '$fnam'"
			return 0 
		}
		while {[gets $zfId line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {$filecnt == 0} {
				lappend linelist $line
			} else {
				set linelist [linsert $linelist $here $line]
				if {![string match $here "end"]} {
					incr here $instep
					if {$here > $cnt} {
						set here "end"
					}
				}
			}
			incr cnt
		}
		close $zfId
		incr filecnt
	}
	if {$cnt <= 0} {
		return 0
	}
	foreach line $linelist {
		$tb.otframe.l.list insert end $line			
	}
	return 1
}

#-- Extra Help into re Warp Processes.

proc WarpHelp {} {
	global pr_vbhelp  vbl evv

	set f .vbhelp
	if [Dlg_Create $f "WARPING DATA OR TIME" "set pr_vbhelp 0" -borderwidth $evv(BBDR)] {
		set fb [frame $f.butn -borderwidth $evv(SBDR)]		;#	frame for buttons
		button $fb.ok0   -text "Close"   -command "set pr_vbhelp 0" -highlightbackground [option get . background {}]
		button $fb.ok1   -text "What Are They?" -command "set pr_vbhelp 1" -width 20 -highlightbackground [option get . background {}]
		button $fb.ok2   -text "How To Make Them" -command "set pr_vbhelp 2" -width 20 -highlightbackground [option get . background {}]
		button $fb.ok3   -text "Parameters,Save,Run" -command "set pr_vbhelp 3" -width 20 -highlightbackground [option get . background {}]
		label $fb.dum -text "              "
		pack $fb.ok0 -side right
		pack $fb.ok1 $fb.ok2 $fb.ok3 $fb.dum -side left -padx 1
		pack $f.butn -side top -fill x
		bind $f <Escape>  {set pr_vbhelp 0}
	}
	wm resizable $f 1 1
	set pr_vbhelp 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_vbhelp
	while {!$finished} {
		tkwait variable pr_vbhelp
		switch -- $pr_vbhelp {
			0 { set finished 1 }
			1 { CDP_Specific_Usage $evv(TE_22) 0 }
			2 { CDP_Specific_Usage $evv(TE_23) 0 }
			3 { CDP_Specific_Usage $evv(TE_24) 0 }
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Get first file on Workspace Chosen List, as parameter (N)

proc FileAsParam {isthresh} {
	global colpar chlist threshold
	if {![info exists chlist] || [llength $chlist] < 1} {
		Inf "No files in Chosen Files List"
		return
	}
	if {$isthresh} {
		set threshold [lindex $chlist 0]
		return
	}
	set colpar [lindex $chlist 0]
}

#---- Creating advancing pattern of values

proc DoAdvance {startval step forwardsteps backstep endval ll} {

	if {($step == 0) || ($startval == $endval) || (($endval > $startval) && ($step <= 0)) || (($startval > $endval) && ($step >= 0))} {
		Inf "Step does not advance to end"
		return 0
	}
	if {$step > 0} {
		if {$backstep > 0} {
			set backstep [expr -($backstep)]
		}
	} else {
		if {$backstep < 0} {
			set backstep [expr -($backstep)]
		}
	}
	if {[expr abs($backstep)] >= [expr abs(($forwardsteps - 1) * $step)]} {
		Inf "Sequence does not advance because backtracking is too large"
		return 0
	}
	$ll delete 0 end
	set stepcnt 0
	set val $startval
	set OK 1
	while {$OK} {
		if {(($step > 0) && ($val > $endval)) || (($step < 0) && ($val < $endval))} {
			break
		}
		$ll insert end $val
		if {$val == $endval} {
			break
		}
		incr stepcnt
		if {$stepcnt >= $forwardsteps} {
			incr val $backstep
			set stepcnt 0
		} else {
			incr val $step
		}
	}
	return 1
}

#------ generate patterns from table input lines

proc TabPattern {qq} {
	global lmo col_ungapd_numeric threshold colpar tot_inlines incols tot_outlines outcolcnt tabedit_ns evv
	global record_temacro temacro temacrop col_x colpar
	global col_tabname col_infnam tabed

	if {![info exists tot_inlines] || ($tot_inlines <= 0)} {
		ForceVal $tabed.message.e  "No input table to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set lmo $qq
	lappend lmo $col_ungapd_numeric 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	switch -- $qq {
		"ZZA" {
			if {![CreateColumnParams $qq 5]} {
				return
			}
			set startval [expr round($col_x(1))]
			set step [expr round($col_x(2))]
			set forwardsteps [expr round($col_x(3))]
			set backstep [expr round($col_x(4))]
			set endval [expr round($col_x(5))]
			if {$endval > $tot_inlines} {
				Inf "Pattern end value exceeds number of lines in input table"
				return 0
			}
			if {$endval < 1} {
				Inf "Pattern end value less than 1: impossible"
				return 0
			}
			if {$startval > $tot_inlines} {
				Inf "Pattern start value exceeds number of lines in input table"
				return 0
			}
			if {$startval < 1} {
				Inf "Pattern start value less than 1: impossible"
				return 0
			}
			if {($step == 0) || ($startval == $endval) || (($endval > $startval) && ($step <= 0)) || (($startval > $endval) && ($step >= 0))} {
				Inf "Step does not advance to end"
				return 0
			}
			if {$step > 0} {
				if {$backstep > 0} {
					set backstep [expr -($backstep)]
				}
			} else {
				if {$backstep < 0} {
					set backstep [expr -($backstep)]
				}
			}
			if {[expr abs($backstep)] >= [expr abs(($forwardsteps - 1) * $step)]} {
				Inf "Sequence does not advance because backtracking is too large"
				return 0
			}
		}
		"ZZD" {
			if {![info exists colpar] || ![IsNumeric $colpar] || ($colpar < 2)} {
				Inf "Parameter Value N is invalid or missing (must be positive integer >= 2)"
				return
			}
			set dupls [expr round($colpar)]
			if {$dupls < 2} {
				Inf "Cannot have less than two duplicates"
				return 0
			}
		}
	}


	HaltCursCop
	SetInout 1
	set lmo $qq
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	switch -- $qq {
		"ZZA" {
			set stepcnt 0
			set val $startval
			set OK 1
			while {$OK} {
				if {(($step > 0) && ($val > $endval)) || (($step < 0) && ($val < $endval))} {
					break
				}
				set line [$ti get [expr $val -1]]
				lappend lines $line
				if {$val == $endval} {
					break
				}
				incr stepcnt
				if {$stepcnt >= $forwardsteps} {
					incr val $backstep
					set stepcnt 0
				} else {
					incr val $step
				}
			}
		}
		"ZZB" {
			foreach line [$ti get 0 end] {
				lappend lines $line
			}
			set lines2 [ReverseList $lines]
			set lines [concat $lines $lines2]
		}
		"ZZC" {
			foreach line [$ti get 0 end] {
				lappend lines $line
			}
			set lines2 [lrange [ReverseList $lines] 1 end]
			set lines [concat $lines $lines2]
		}
		"ZZD" {
			foreach line [$ti get 0 end] {
				lappend lines $line
			}
			set cnt 1
			while {$cnt < $dupls} {
				foreach line [$ti get 1 end] {
					lappend lines $line
				}
				incr cnt
			}
		}
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
	} else {
		$to delete 0 end
		foreach line $lines {
			$to insert end $line
			puts $fileot $line
		}
		close $fileot						;#	Write data to file
		set outcolcnt $incols
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines [llength $lines]
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		EnableOutputTableOptions 1 1
	}
}

#------ Create a new column fron scratch

proc NewPatterns {colmode p_cnt} {
	global threshold docol_OK outlines tedit_message last_oc evv
	global inlines tot_inlines coltype rcolno orig_incolget col_x cc_out tabed
	global last_cr col_ungapd_numeric tot_outlines lmo orig_inlines insitu colpar record_temacro temacro temacrop
	global mix_perm

	HaltCursCop

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set lmo NP
	lappend lmo $col_ungapd_numeric $colmode $p_cnt
	set tb $tabed.bot

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {$insitu} {
		set ll $tb.icframe.l.list
		set lcnt "inlines"
		set zfile $evv(COLFILE1)
	} else {
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
		set zfile $evv(COLFILE2)
	}
	if {!$insitu} {
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		DisableOutputColumnOptions 
	}
	$ll delete 0 end		;#	Clear existing listing of column
	set $lcnt 0				;#	Set col linecnt to zero

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![CreateColumnParams $colmode $p_cnt]} {
		return
	}
	if {!$cc_out} {
		set $lcnt ""
		if {$lcnt == "inlines"} {
			ForceVal $tb.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tb.ocframe.dummy.cnt $outlines
		}
		return
	}
	if {$colmode == "ZF"} {
		set nn 1
		while {$nn < 8} {
			set col_x($nn) [expr int(round($col_x($nn)))]
			incr nn
		}
		if {$col_x(1) <= 0} {
			set tedit_message "Zero outputs specified"
			ForceVal $tabed.message.e $tedit_message
 			$tabed.message.e config -bg [option get . background {}]
			return
		}
		if {$col_x(3) < 0 ||  $col_x(4) < 0 || $col_x(5) < 0 || $col_x(6) < 0} {
			set tedit_message "Cannot have less than zero entries of any type"
			ForceVal $tabed.message.e $tedit_message
 			$tabed.message.e config -bg [option get . background {}]
			return
		}
		if {$col_x(2) < [expr $col_x(3) + $col_x(4) + $col_x(5) + $col_x(6)]} {
			set tedit_message "Size of set too small to generate any pattern"
			ForceVal $tabed.message.e $tedit_message
 			$tabed.message.e config -bg [option get . background {}]
			return
		}
		set varsize [expr $col_x(4) + $col_x(6)]
		if {[string length $col_x(7)] != $varsize} {
			set tedit_message "Number of step increments does not tally with number of changing pattern-items"
			ForceVal $tabed.message.e $tedit_message
 			$tabed.message.e config -bg [option get . background {}]
			return
		}
		set nn 0
		set fixcnt [expr $col_x(3) + $col_x(5)]
		set varsetsize [expr $col_x(2) - $fixcnt]
		while {$nn < $varsize} {
			if {[string index $col_x(7) $nn] >= $varsetsize} {
				set tedit_message "Step increment [string index $col_x(7) $nn] is too large for size of set, once fixed values accounted for."
				ForceVal $tabed.message.e $tedit_message
 				$tabed.message.e config -bg [option get . background {}]
				return
			}
			incr nn
		}
		set outcnt 0
		set initial_val 1
		set m 0
		while {$m < $col_x(3)} {
			set aa($m) $initial_val
			incr initial_val
			incr m
		}
		set m 0
		while {$m < $col_x(5)} {
			set cc($m) $initial_val
			incr initial_val
			incr m
		}
		set m 0
		while {$m < $col_x(4)} {
			set bb($m) $initial_val
			incr initial_val
			incr m
		}
		set m 0
		while {$m < $col_x(6)} {
			set dd($m) $initial_val
			incr initial_val
			incr m
		}
		set OK 1
		while {$OK} {
			set m 0			;#	FIRST SET OF FIXED VALS
			while {$m < $col_x(3)} {
				$ll insert end $aa($m)
				incr m
				incr outcnt
				if {$outcnt >= $col_x(1)} {
					set OK 0
					break
				}
			}
			if {!$OK} {
				break
			}
			set m 0			;#	FIRST SET OF ADVANCING VALS
			while {$m < $col_x(4)} {
				$ll insert end $bb($m)
				incr bb($m) [string index $col_x(7) $m]
				if {$bb($m) > $col_x(2)} {
					incr bb($m) -$varsetsize
				}
				incr m
				incr outcnt
				if {$outcnt >= $col_x(1)} {
					set OK 0
					break
				}
			}
			if {!$OK} {
				break
			}
			set m 0			;#	SECOND SET OF FIXED VALS
			while {$m < $col_x(5)} {
				$ll insert end $cc($m)
				incr m
				incr outcnt
				if {$outcnt >= $col_x(1)} {
					set OK 0
					break
				}
			}
			if {!$OK} {
				break
			}
			set m 0			;#	SECOND SET OF ADVANCING VALS
			while {$m < $col_x(6)} {
				$ll insert end $dd($m)
				incr dd($m) [string index $col_x(7) [expr $col_x(4) + $m]]
				if {$dd($m) > $col_x(2)} {
					incr dd($m) -$varsetsize
				}
				incr m
				incr outcnt
				if {$outcnt >= $col_x(1)} {
					set OK 0
					break
				}
			}
		}
	} else {
		set fulgrpsize [expr $col_x(2) + $col_x(3)]
		set fulgrps [expr $col_x(1) / $fulgrpsize]
		set rand_cnt [expr $fulgrps * $col_x(3)]
		set leftovr [expr $col_x(1) - ($fulgrps * $fulgrpsize)]
		incr leftovr -$col_x(2)
		if {$leftovr > 0} { 
			incr rand_cnt $leftovr
		}
		if {$rand_cnt <= 0} {
			set tedit_message "Total number of vals too small to generate any pattern"
			ForceVal $tabed.message.e $tedit_message
 			$tabed.message.e config -bg [option get . background {}]
			return
		}
		if {$colmode == "ZE"} {
			set rand_cnt [expr $col_x(4) - 1]
		} elseif {$colmode == "ZD"} {
			set rand_cnt [expr $col_x(4) - $col_x(2)]
		}
		if {$rand_cnt <= 0} {
			set tedit_message "Total number of vals too small to generate any pattern"
			ForceVal $tabed.message.e $tedit_message
 			$tabed.message.e config -bg [option get . background {}]
			return
		}

		RandomiseOrder $rand_cnt
		set fixcnt 1
		set rancnt 0
		set ranindx 0
		set cnt 0
		while {$cnt < $col_x(1)} {
			if {$rancnt > 0} {
				if {$rancnt >= $col_x(3)} {
					set rancnt 0
					set fixcnt 1
					continue
				} else {
					if {$ranindx >= $rand_cnt} {
						RandomiseOrder $rand_cnt
						set ranindx 0
					}
					set val [Do_Rand $colmode $ranindx]
					incr ranindx
					incr rancnt
				}
			} else {
				if {$fixcnt > $col_x(2)} {
					if {$ranindx >= $rand_cnt} {
						RandomiseOrder $rand_cnt
						set ranindx 0
					}
					set val [Do_Rand $colmode $ranindx]
					incr ranindx
					incr rancnt
				} else {
					if {$colmode == "ZB" || $colmode == "ZE"} {
						set val 1
					} elseif {$colmode == "ZC" || $colmode == "ZD"} {
						set val $fixcnt
					}
					incr fixcnt
				}
			}
			$ll insert end $val
			incr cnt
		}
	}
	WriteOutputColumn $zfile $ll $lcnt 1 0 1
}

proc Patex {} {
	global threshold outlines tedit_message last_oc evv
	global inlines tot_inlines coltype rcolno orig_incolget tabed
	global last_cr col_ungapd_numeric tot_outlines lmo orig_inlines insitu colpar record_temacro temacro temacrop

	HaltCursCop

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set lmo PX
	lappend lmo $col_ungapd_numeric 0
	set tb $tabed.bot

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {$insitu} {
		set ll $tb.icframe.l.list
		set lcnt "inlines"
		set zfile $evv(COLFILE1)
	} else {
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
		set zfile $evv(COLFILE2)
	}
	if {!$insitu} {
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		DisableOutputColumnOptions 
	}
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set nn 1
	while {$nn < $inlines} {
		catch {unset partit}
		set partit_cnt 0
		set indx 0
		catch {unset OK}
		foreach item [$tb.icframe.l.list get 0 end] {
			lappend partit($partit_cnt) $item
			incr indx
			if {$indx >= $nn} {
				incr partit_cnt
				set indx 0
				if {$partit_cnt > 1} {
					set OK 1
					set last_partit [expr $partit_cnt - 1]
					set penu_partit [expr $partit_cnt - 2]
					foreach z0 $partit($penu_partit) z1 $partit($last_partit) {
						if {![string match $z0 $z1]} {
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
		if {[info exists OK] && $OK} {
			break
		}
		incr nn
	}
	if {![info exists OK] || !$OK} {
		ForceVal $tabed.message.e  "There is no recurring pattern of values"
		$tabed.message.e config -bg $evv(EMPH)
		return
	} else {
		$ll delete 0 end
		foreach val $partit(0) {
			$ll insert end $val
		}
	}
	WriteOutputColumn $zfile $ll $lcnt 1 0 1
}

proc Do_Rand {colmode ranindx} {
	global mix_perm col_x
	set val $mix_perm($ranindx)
	incr val
	if {$colmode == "ZB" || $colmode == "ZE"} {
		incr val
	} elseif {$colmode == "ZC" || $colmode == "ZD"} {
		incr val $col_x(2)
	}
	return $val
}

proc HelpComplexPattern {} {
	set msg    "Sequence of x1 outputs, taken from set of x2 values.\n"
	append msg "\n"
	append msg "There are x3 fixed vals followed by x4 changing vals\n"
	append msg "followed by x5 fixed vals then by x6 changing vals.\n"
	append msg "\n"
	append msg "Each changing val changes by a fixed increment\n"
	append msg "and these increments are given in x7...\n"
	append msg "e.g. 1217 means.....1st changing val steps by 1,\n"
	append msg "2nd by 2,  3rd by 1,   4th by 7\n"
	append msg "\n"
	append msg "Increments > 9 (or less than 0) cannot be used."
	Inf $msg
}

#------ Insert text in entries

proc InsText {} {
	global colpar threshold docol_OK outlines tedit_message last_oc last_cr evv
	global inlines coltype rcolno col_ungapd_numeric orig_incolget tround tot_outlines
	global colmode_exception tot_inlines lmo insitu orig_inlines record_temacro temacro temacrop tabed

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		ForceVal $tabed.message.e "No insertion text given at 'N'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists threshold] || ![regexp {^[0-9]+$} $threshold] || ($threshold == 0)} {
		ForceVal $tabed.message.e "Invalid insertion position given at 'threshold'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {	   	;#	If there's an input TABLE
		SetInout 1												;#	Reset default to act on input TABLE
	}
	HaltCursCop
	set lmo I
	lappend lmo $col_ungapd_numeric								;#	 Remember last action.
	set tb $tabed.bot
	set colparam $colpar

	catch {unset colmode_exception}
	if {![file exists $evv(COLFILE1)]} {
		ForceVal $tabed.message.e "No column selected"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tround 0

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {!$insitu} {
		set last_oc [$tb.ocframe.l.list get 0 end]
		set last_cr $col_ungapd_numeric					;#	In normal situation.
		DisableOutputColumnOptions 
	}													;#	Special varieites of addition
	
	if {$insitu} {									;#	establish which col to act on
		set ll $tb.icframe.l.list
		set lcnt "inlines"
	} else {
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
	}
	set zcnt [string length $colpar]
	set docol_OK 1
	set posit [expr $threshold - 1]
	foreach item [$tb.icframe.l.list get 0 end] {
		set ycnt [string length $item]
		if {$posit > $ycnt} {
			ForceVal $tabed.message.e "Some lines are too short to insert text at specified position."
 			$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
			break
		}		 
		set zup ""
		if {$posit > 0} {
			incr posit -1
			append zup [string range $item 0 $posit]
			incr posit
		}
		append zup $colparam
		if {$posit < $ycnt} {
			append zup [string range $item $posit end]
		}
		lappend nulist $zup
		set changed 1
	}
	if {$docol_OK} {
		$ll delete 0 end
		foreach item $nulist {
			$ll insert end $item
		}
		if {$insitu && ($colmode != "copy")} {
			set fnam $evv(COLFILE1)
		} else {
			set fnam $evv(COLFILE2)
		}
		WriteOutputColumn $fnam $ll $lcnt 0 0 0
	}
}

proc NoteToFrq {val} {

	set isneg 0
	set ht 0
	set val [string tolower $val]
	switch -- [string index $val 0] {
		c { set midi 0 }
		d { set midi 2 }
		e { set midi 4 }
		f { set midi 5 }
		g { set midi 7 }
		a { set midi 9 }
		b { set midi 11 }
		default {
			return 0
		}
	}
	set n 1
	switch -- [string index $val $n] {
		"#"	{ incr midi; incr n}
		"b" { incr midi -1; incr n}
	}
	if {[string match [string index $val $n] "u"]} {
		set ht 1
		incr n
	} elseif {[string match [string index $val $n] "d"]} {
		set ht -1
		incr n
	}
	if {[string match [string index $val $n] "-"]} {
		set isneg 1
		incr n
	}
	switch -- [string index $val $n] {
		0 -
		1 -
		2 -
		3 -
		4 -
		5 -
		6 {
			set oct [string index $val $n]
		}
		default {
			return 0
		}
	}
	incr n
	if {$n != [string length $val]} {
		if {$ht != 0} {
			return 0
		}
		switch -- [string index $val $n] {
			u {set ht 1} 
			d {set ht -1}
			default {
				return 0
			}
		}
		incr n
	}
	if {$n != [string length $val]} {
		return 0
	}
	if {$isneg} {
		set oct -$oct
	}
	if {$midi < 0} {
		incr midi 12
	} elseif {$midi >= 12} {
		incr midi -12
	}
	set oct [expr pow(2.0,$oct)]
	switch -- $midi {
		0 { set frq 261.625565 }
		1 { set frq 277.182631 }
		2 { set frq 293.664768 }
		3 { set frq 311.126984 }
		4 { set frq 329.627557 }
		5 { set frq 349.228231 }
		6 { set frq 369.994423 }
		7 { set frq 391.995436 }
		8 { set frq 415.304698 }
		9 { set frq 440.000000 }
		10 { set frq 466.163762 }
		11 { set frq 493.883301 }
	}
	set frq [expr $frq * $oct]
	switch -- $ht {
		"1" { set frq [expr $frq * 1.02932022366]}
		"-1" { set frq [expr $frq * 0.97153194116]}
	}
	return $frq
}

proc GetLastRunParams {} {
	global pstore pmcnt tabed evv
	
	if {[info exists pstore] && [info exists pmcnt]} {
		if {$pmcnt <= 0} {
			ForceVal $tabed.message.e "Current process or instrument has no parameters."
			$tabed.message.e config -bg $evv(EMPH)
		} else {
			set i 0
			while {$i < $pmcnt} {
				lappend val $pstore($i)
				incr i
			}
			return $val
		}
	} else {
		ForceVal $tabed.message.e "No parameters have yet been set"
		$tabed.message.e config -bg $evv(EMPH)
	}
	return {}
}

#------ Transpose pitches in Varibank filter data file

proc Vtrans {ismidi} {
	global wl lmo col_ungapd_numeric threshold colpar wstk tot_inlines incols tot_outlines outcolcnt tabedit_ns mu evv
	global record_temacro temacro temacrop
	global col_tabname col_infnam tabed

	HaltCursCop
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e  "No input table to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	SetInout 1

	set lmo "Vt"
	lappend lmo $col_ungapd_numeric $ismidi
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	if {($ismidi == 6) || ($ismidi == 7) || ($ismidi == 8)} {					;#	frq <--> midi in varibank
		set line_ccnt 1
		foreach line [$ti get 0 end] {
			if {[string match [string index $line 0] ";"]} {
				append outlines $line
				incr line_ccnt
				continue
			}
			set c_cnt 0
			set line [split $line]
			catch {unset outline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] < 0} {
					continue
				}
				if {![IsNumeric $item]} {
					ForceVal $tabed.message.e  "This process only works with filter varibank data."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				if {[IsEven $c_cnt]} {
					lappend outline $item
				} else {
					if {$ismidi == 6} {		;#	Midi --> Frq
						if {($item > 127) || ($item < 0)} {
							ForceVal $tabed.message.e  "Invalid Midi value ($item) on line $line_ccnt"
	 						$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set nuitem [MidiToHz $item]
					} else {
						if {($item > 12544) || ($item < 12.978272)} {
							ForceVal $tabed.message.e  "Frq value ($item) out of midi range on line $line_ccnt"
	 						$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set nuitem [HzToMidi $item]
						if {$ismidi == 8} {
							set nuitem [expr int(round($nuitem))]
						}
					}
					lappend outline $nuitem
				}
				incr c_cnt
			}
			if {[IsEven $c_cnt]} {
				ForceVal $tabed.message.e  "This process only works with filter varibank data."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}			
			lappend outlines $outline
			incr line_ccnt
		}
	} elseif {$ismidi == 10} {					;#	normalise
		set line_ccnt 1
		set lasttime -1.0
		catch {unset outlines}
		foreach line [$ti get 0 end] {
			if {[string match [string index $line 0] ";"]} {
				lappend outlines $line
				incr line_ccnt
				continue
			}
			set c_cnt 0
			set line [split $line]
			catch {unset nuline}
			set maxlevel 0.0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] < 0} {
					continue
				}
				if {![IsNumeric $item]} {
					ForceVal $tabed.message.e  "This process only works with filter varibank data."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				if {[IsEven $c_cnt]} {
					if {$item < 0.0} {
						ForceVal $tabed.message.e  "This process only works with filter varibank data."
						$tabed.message.e config -bg $evv(EMPH)
						return
					}
					if {$c_cnt == 0} {
						if {$item < $lasttime} {
							ForceVal $tabed.message.e  "This process only works with filter varibank data."
							$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set lasttime $item
					} else {
						if {$item > $maxlevel} {
							set maxlevel $item
						}
					}
				} else {
					if {($item > 12544) || ($item < 12.978272)} {
						ForceVal $tabed.message.e  "Frq value ($item) out of range on line $line_ccnt"
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
				}
				lappend nuline $item
				incr c_cnt
			}
			if {[IsEven $c_cnt]} {
				ForceVal $tabed.message.e  "This process only works with filter varibank data."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			lappend outlines $nuline	
			incr line_ccnt
		}
		if {$maxlevel == 0.0} {
			ForceVal $tabed.message.e  "This process only works with filter varibank data."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$maxlevel == 1.0} {
			ForceVal $tabed.message.e  "Amplitudes already normalised."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set normer [expr 1.0 / $maxlevel]
		set len [llength $outlines]
		set k 0
		while {$k < $len} {
			set line [lindex $outlines $k]
			if {[string match [string index $line 0] ";"]} {
				incr k
				continue
			}
			set n 2
			while {$n < $c_cnt} {
				set levl [lindex $line $n]
				set levl [expr $levl * $normer]
				if {[Flteq $levl 1.0]} {
					set levl 1.0
				}
				if {[Flteq $levl 0.0]} {
					set levl 0.0
				}
				set line [lreplace $line $n $n $levl]
				incr n 2			
			}
			set outlines [lreplace $outlines $k $k $line]
			incr k
		}
	} elseif {$ismidi == 11} {					;#	add suboctave
		set line_ccnt 1
		set lasttime -1.0
		catch {unset outlines}
		foreach line [$ti get 0 end] {
			if {[string match [string index $line 0] ";"]} {
				lappend outlines $line
				incr line_ccnt
				continue
			}
			set c_cnt 0
			set line [split $line]
			catch {unset nuline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] < 0} {
					continue
				}
				if {![IsNumeric $item]} {
					ForceVal $tabed.message.e  "This process only works with filter varibank data."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				if {[IsEven $c_cnt]} {
					if {$item < 0.0} {
						ForceVal $tabed.message.e  "This process only works with filter varibank data."
						$tabed.message.e config -bg $evv(EMPH)
						return
					}
					if {$c_cnt == 0} {
						if {$item < $lasttime} {
							ForceVal $tabed.message.e  "This process only works with filter varibank data."
							$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set lasttime $item
					} elseif {$c_cnt == 2} {
						lappend nupair $item
					}
				} else {
					if {($item > 12544) || ($item < 12.978272)} {
						ForceVal $tabed.message.e  "Frq value ($item) out of range on line $line_ccnt"
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
					if {$c_cnt == 1} {
						if {$item < 26.0} {
							ForceVal $tabed.message.e  "Frq value ($item) out of range for this process on line $line_ccnt"
	 						$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set nupair [expr $item / 2.0]
					}
				}
				lappend nuline $item
				incr c_cnt
			}
			if {[IsEven $c_cnt]} {
				ForceVal $tabed.message.e  "This process only works with filter varibank data."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set znuline [concat [lindex $nuline 0] $nupair [lrange $nuline 1 end]]
			lappend outlines $znuline	
			incr line_ccnt
		}
	} elseif {$ismidi == 12} {					;#	convert to  MIDI list
		set line_ccnt 1
		set lasttime -1.0
		catch {unset outlines}
		foreach line [$ti get 0 end] {
			if {[string match [string index $line 0] ";"]} {
				incr line_ccnt
				continue
			}
			set c_cnt 0
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {![IsNumeric $item]} {
					ForceVal $tabed.message.e  "This process only works with filter varibank data."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				if {[IsEven $c_cnt]} {
					if {$item < 0.0} {
						ForceVal $tabed.message.e  "This process only works with filter varibank data."
						$tabed.message.e config -bg $evv(EMPH)
						return
					}
					if {$c_cnt == 0} {
						set bum 0
						if {$line_ccnt == 0} {
							if {$item != 0.0} {
								set bum 1
							}
						} elseif {$item <= $lasttime} {
							set bum 1
						}
						if {$bum} {
							ForceVal $tabed.message.e  "This process only works with filter varibank data."
							$tabed.message.e config -bg $evv(EMPH)
							return
						}
						set lasttime $item
					}
				} else {
					if {($item > 127) || ($item < 0)} {
						ForceVal $tabed.message.e  "MIDI value ($item) out of range on line $line_ccnt"
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
					lappend outlines $item
				}
				incr c_cnt
			}
			if {[IsEven $c_cnt]} {
				ForceVal $tabed.message.e  "This process only works with filter varibank data."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			incr line_ccnt
		}
		if {![info exists outlines]} {
			ForceVal $tabed.message.e  "Wrong type of input file ??"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set outlines [lsort -increasing $outlines]
		set outlines [RemoveDuplicates $outlines]
		set klines {}
		foreach val $outlines {
			lappend klines $val
		}
		set outlines $klines
	} elseif {($ismidi == 4) || ($ismidi == 5) || ($ismidi == 9)} {			;#	time-frq --> varibank
		set linecnt 1
		foreach line [$ti get 0 end] {
			if {[string match [string index $line 0] ";"]} {
				incr linecnt
				continue
			}
			set line [split $line]
			set knt 0
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				if {![IsNumeric $item]} {
					ForceVal $tabed.message.e  "Non-numeric data in input table."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				switch -- $knt {
					0 {
						if {![info exists lasttime]} {
							if {![Flteq $item 0.0]} {
								ForceVal $tabed.message.e  "First time in input data is not zero."
								$tabed.message.e config -bg $evv(EMPH)
								return
							}
						} else {
							if {$item <= $lasttime} {
								ForceVal $tabed.message.e  "Time values do not increase at line $linecnt in input table."
								$tabed.message.e config -bg $evv(EMPH)
								return
							}
						}
						set lasttime $item
						lappend ttimes $item
					} 
					1 {
						if {$item > 16000} {
							ForceVal $tabed.message.e  "Frequency value too high ($val) at line $linecnt."
	 						$tabed.message.e config -bg $evv(EMPH)
							return 
						}
						lappend ffrqs $item
					} 
					default {
						ForceVal $tabed.message.e  "Too many items on line $linecnt"
						$tabed.message.e config -bg $evv(EMPH)
						return
					}
				}
				incr knt
			}
			if {$knt != 2} {
				ForceVal $tabed.message.e  "Too few items on line $linecnt"
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			incr linecnt
		}
		if {![info exists ffrqs]} {
			ForceVal $tabed.message.e  "No valid data found in input table."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set nn 0
		set islo 0
		set nufrqs $ffrqs
		foreach val $ffrqs {			;#	Replace signal zeros, and frqs too low for filter
			if {$val < 9.0} {
				if {!$islo} {
					set islo 1
					set lostart $nn
				}
			} else {
				if {$islo} {
					if {$lostart == 0} {
						set mm 0
						while {$mm < $nn} {
							set nufrqs [lreplace $nufrqs $mm $mm $val]
							incr mm
						}
					} else {
						set startsemi [HzToMidi $lasttruval]
						set endsemi   [HzToMidi $val]
						set semistep [expr $endsemi - $startsemi]
						set step [expr $nn - $lostart + 1]
						set semistep [expr $semistep/$step]
						set thissemi $startsemi
						set mm $lostart
						while {$mm < $nn} {
							set thissemi [expr $thissemi + $semistep]
							set thisfrq [MidiToHz $thissemi]
							set nufrqs [lreplace $nufrqs $mm $mm $thisfrq]
							incr $mm
						}
					}
				}
				set islo 0
				set lasttruval $val
				set pend $nn
			}
			set lastval $val
			incr nn
		}
		if {$lastval < 9.0} {
			set mm $pend
			while {$mm < $nn} {
				set nufrqs [lreplace $nufrqs $mm $mm $lasttruval]
				incr mm
			}	
		}
		set linecnt $nn
		set nn 0
		set outlines {}
		while {$nn < $linecnt} {
			set line [lindex $ttimes $nn]
			if {$ismidi == 5} {
				lappend line [HzToMidi [lindex $nufrqs $nn]]
			} elseif {$ismidi == 9} {
				lappend line [expr int(round([HzToMidi [lindex $nufrqs $nn]]))]
			} else {
				lappend line [lindex $nufrqs $nn]
			}
			lappend line "1"
			lappend outlines $line
			incr nn
		}
	} elseif {$ismidi >= 2} {
		set nn 0
		foreach line [$ti get 0 end] {
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			set val [split $line]
			if {[string length $val] <= 0} {
				continue
			}
			if {$ismidi==2} {
				if {![IsNumeric $val] || ($val < $mu(MIDIMIN)) || ($val > $mu(MIDIMAX))} {
					ForceVal $tabed.message.e  "Invalid midi value given."
	 				$tabed.message.e config -bg $evv(EMPH)
					return 
				}
			} elseif {![IsNumeric $val] || ($val > 16000) || ($val < 9.00)} {
				ForceVal $tabed.message.e  "Invalid frequency value given."
	 			$tabed.message.e config -bg $evv(EMPH)
				return 
			}
			lappend vals $val
			incr nn
		}
		set len $nn
		set len_less_one $len
		incr len_less_one -1
		set nn 0
		while {$nn < $len_less_one} {
			set mm $nn
			incr mm
			set valn [lindex $vals $nn]
			while {$mm < $len} {
				set valm [lindex $vals $mm]
				if {$valm < $valn} {
					set vals [lreplace $vals $mm $mm $valn]
					set vals [lreplace $vals $nn $nn $valm]
					set val $valn
					set valn $valm
					set valm $val
				}
				incr mm
			}
			incr nn
		}
		set nn 0
		foreach val $vals {
			if {$nn == 0} {
				set nuline0 "0  "
				set nuline1 "1000  "
			}
			append nuline0 "$val  1  "
			append nuline1 "$val  1  "
			incr nn
		}
		set outlines [list $nuline0 $nuline1]
	} else {
		if {![info exists colpar] || ([string length $colpar] <= 0) || ![IsNumeric $colpar]} {
			ForceVal $tabed.message.e  "No (valid) transposition parameter given."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$colpar > 127 || $colpar < -127} {
			ForceVal $tabed.message.e  "Transposition parameter out of range."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {!$ismidi} {
			set tratio [expr $colpar/12.0]
			set tratio [expr pow(2.0,$tratio)]
		}
		foreach line [$ti get 0 end] {
			if {[string match [string index $line 0] ";"]} {
				append outlines $line
				continue
			}
			set c_cnt 0
			set line [split $line]
			catch {unset outline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] < 0} {
					continue
				}
				if {![IsNumeric $item]} {
					ForceVal $tabed.message.e  "This process only works with filter varibank data."
					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				if {[IsEven $c_cnt]} {
					lappend outline $item
				} else {
					if {$ismidi} {
						set nuitem [expr $item + $colpar] 
						if {($nuitem > 127) || ($nuitem < 0)} {
							set bum 1
						}
					} else {
						set nuitem [expr $item * $tratio] 
						if {($nuitem > 22000) || ($nuitem < 8)} {
							set bum 1
						}
					}
					if {[info exists bum]} {
						ForceVal $tabed.message.e  "Transposition causes some pitches to be out of range."
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
					lappend outline $nuitem
				}
				incr c_cnt
			}
			if {[IsEven $c_cnt]} {
				ForceVal $tabed.message.e  "This process only works with filter varibank data."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}			
			lappend outlines $outline
		}
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
	} else {
		$to delete 0 end
		set ccnt 0
		foreach line $outlines {
			$to insert end $line
			puts $fileot $line
			incr ccnt
		}
		close $fileot						;#	Write data to file
		if {$ismidi <= 1} {
			set outcolcnt $incols						;#	Transposition only
		} else {
			set outcolcnt [expr ($tot_inlines * 2) + 1]	;# Create datafile from midi or frq list
		}
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines $ccnt
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		EnableOutputTableOptions 1 1
	}
}

#------ Randomise order of sounds in mixfile: But, where they are palced at sem iregular time-intervals
#------ ensure that the sounds which arfe irregularly placed in the original, are similarly offset in
#------ the new output mixfile

proc RandomiseWithVariance {} {
	global wl lmo col_ungapd_numeric threshold colpar wstk tot_inlines incols tot_outlines outcolcnt tabedit_ns evv
	global record_temacro temacro temacrop CDPcolrun docol_OK
	global col_tabname col_infnam tabed
	global diff_listing evv pa gp mix_perm

	HaltCursCop
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e  "No input table to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	SetInout 1

	set lmo "Dg"
	lappend lmo $col_ungapd_numeric
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

;# GET LINES FROM INPUT TABLE AND TEST, AND EXTRACT SNDFILENAMES AND TIMES
	set nn 0
	foreach line [$tb.itframe.l.list get 0 end] {
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {![info exists nuline]} {
			continue
		}
		if {([llength $nuline] != 4) && ([llength $nuline] != 5) && ([llength $nuline] != 7)} {
			ForceVal $tabed.message.e  "This process only works on mixfiles."
			$tabed.message.e config -bg $evv(EMPH)
			return

		}
		if {$nn == 0} {
			set len [llength $nuline]
		} elseif {[llength $nuline] != $len} {
			ForceVal $tabed.message.e  "This process only works on mixfiles where lines have the same length."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		lappend snds  [lindex $nuline 0]
		lappend times [lindex $nuline 1]
		lappend nulines $nuline
	}
;# TEST THAT SNDS ARE EXISTING FILES AND THAT TIMES ARE NUMERIC
	foreach fnam $snds time $times {
		if {![file exists $fnam] || [file isdirectory $fnam]} {
			ForceVal $tabed.message.e  "This process only works on mixfiles. $fnam is not a file."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![IsNumeric $time] || ($time < 0.0)} {
			ForceVal $tabed.message.e  "This process only works on mixfiles. 2nd column must be Time Values."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
# TEST THAT TIMES INCREASE
#	set lasttime -1.0
#	foreach time $times {
#		if {$time <= $lasttime} {
#			ForceVal $tabed.message.e  "This process only works on mixfiles where sounds are in ascending time order."
#			$tabed.message.e config -bg $evv(EMPH)
#			return
#		}
#		set lasttime $time
#	}
#

;# STORE THE TIMES IN A TEMPORARY FILE
	if [catch {open $evv(COLFILE1) "w"} zit] {
		ForceVal $tabed.message.e  "Cannot open temporary file to store mix time data."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach time $times {
		puts $zit $time
	}
	close $zit
;# RUN THE GRID VARIANCE PROGRAM, PUTTING DATA INTO A GLOBALLY-DEFINED LIST
	set colcmd [file join $evv(CDPROGRAM_DIR) columns]
	lappend colcmd $evv(COLFILE1) -dg
	set docol_OK 0
	set diff_listing {}
	set sloom_cmd [linsert $colcmd 1 "#"]
	if [catch {open "|$sloom_cmd"} CDPcolrun] {
		ErrShow "$CDPcolrun"
	} else {
   		fileevent $CDPcolrun readable "KeepNewColumn"
		vwait docol_OK
	}

	if {$docol_OK} {
;# CALCULATE THE GRID STEP
		set gridstep [expr [lindex $times 1] - [lindex $times 0] - [lindex $diff_listing 1]]
		set len [llength $snds]
;# RANDOMISED ORDER OF SOUNDS, WITH THEIR APPROPRIATE TIME-OFFSETS TIED TO THEM
		RandomiseOrder $len
		set nn 0
		set time [lindex $times 0]
		while {$nn < $len} {
			lappend nusnds [lindex $snds $mix_perm($nn)]
			lappend nutimes [expr $time + [lindex $diff_listing $mix_perm($nn)]]
			set time [expr $time + $gridstep]
			incr nn
		}
;# PROCEED TO OUTPUT TABLE AS NORMALLY
		$tb.otframe.l.list delete 0 end
		foreach nuline $nulines nutime $nutimes nusnd $nusnds {
			set nuline [lreplace $nuline 0 1 $nusnd $nutime]
			$tb.otframe.l.list insert end $nuline
		}
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
	} else {
		DisableOutputTableOptions 1
	}
}

proc KeepNewColumn {} {
	global CDPcolrun docol_OK tabed diff_listing evv

	if [eof $CDPcolrun] {
		set docol_OK 1
		catch {close $CDPcolrun}
		return
	} else {
		gets $CDPcolrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match INFO:* $line] {
			set line [string range $line 6 end] 
			lappend diff_listing $line
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
		} elseif [string match END:* $line] {
			set docol_OK 1
			catch {close $CDPcolrun}
			return
		} else {
			set line "Invalid Message ($line) received from program."
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
			catch {close $CDPcolrun}
			return
		}
	}
	update idletasks
}			

#------ Generate new lists of (file) names from given names, esp names with segmentation

proc NameGames {typ} {
	global lmo col_ungapd_numeric threshold colpar tot_inlines incols tot_outlines outcolcnt tabedit_ns evv
	global record_temacro temacro temacrop docol_OK col_tabname col_infnam tabed

	HaltCursCop
	set lmo "NG"
	lappend lmo $col_ungapd_numeric $typ
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <= 0)} {
		ForceVal $tabed.message.e  "No input table to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$typ == "condsubf"} {
		foreach fnam [$tabed.bot.itframe.l.list get 0 end] {
			if {![file exists $fnam] || [file isdirectory $fnam]} {
				ForceVal $tabed.message.e  "Item $fnam in input table is not a file."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	}

	SetInout 1

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	switch -- $typ {
		"addhead"		{ set docol_OK [MassageFilenames addhead	0 $tabed.bot.itframe.l.list] }
		"addtail"		{ set docol_OK [MassageFilenames addtail    0 $tabed.bot.itframe.l.list] }
		"addat"			{ set docol_OK [MassageFilenames addat      0 $tabed.bot.itframe.l.list] }
		"addatseg"		{ set docol_OK [MassageFilenames addatseg   0 $tabed.bot.itframe.l.list] }
		"swapseg"		{ set docol_OK [MassageFilenames swapsegs   0 $tabed.bot.itframe.l.list] }
		"delhead"		{ set docol_OK [MassageFilenames deletehead 0 $tabed.bot.itframe.l.list] }
		"deltail"		{ set docol_OK [MassageFilenames deletetail 0 $tabed.bot.itframe.l.list] }
		"delseg"		{ set docol_OK [MassageFilenames deleteseg  0 $tabed.bot.itframe.l.list] }
		"substitute"	{ set docol_OK [MassageFilenames cycfiles   0 $tabed.bot.itframe.l.list] }
		"getsegs"		{ set docol_OK [MassageFilenames getsegs    0 $tabed.bot.itframe.l.list] }
		"delfiles"		{ set docol_OK [MassageFilenames delfiles   0 $tabed.bot.itframe.l.list] }
		"subfiles"		{ set docol_OK [MassageFilenames subfiles   0 $tabed.bot.itframe.l.list] }
		"headtail"		{ set docol_OK [HeadVTail 1 0 $tabed.bot.itframe.l.list] }
		"tailhead"		{ set docol_OK [HeadVTail 0 0 $tabed.bot.itframe.l.list] }
		"reverse"		{ set docol_OK [MassageFilenames reverse    0 $tabed.bot.itframe.l.list] }
		"alphabet"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list alphabet   0 sort] }
		"startcons"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list startcons  0 sort] }
		"endcons"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list endcons	   0 sort] }
		"vowel"			{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list vowel	   0 sort] }
		"number"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list numeric	   0 sort] }
		"pclass"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list pitchclass 0 sort] }
		"ialphabet_ch"	{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list alphabet   0 interleave] }
		"istartcons_ch" { set docol_OK [SortFilenames $tabed.bot.itframe.l.list startcons  0 interleave] }
		"iendcons_ch"	{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list endcons    0 interleave] }
		"ivowel_ch"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list vowel	   0 interleave] }
		"inumber_ch"	{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list numeric	   0 interleave] }
		"ipclass_ch"	{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list pitchclass 0 interleave] }
		"alphabet_r"	{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list alphabet   0 reduce] }
		"startcons_r"	{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list startcons  0 reduce] }
		"endcons_r"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list endcons    0 reduce] }
		"vowel_r"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list vowel      0 reduce] }
		"number_r"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list numeric    0 reduce] }
		"pclass_r"		{ set docol_OK [SortFilenames $tabed.bot.itframe.l.list pitchclass 0 reduce] }
		"delsegval"		{ set docol_OK [MassageFilenames delsegval 0 $tabed.bot.itframe.l.list] }
		"extract_s"		{ set docol_OK [IsItASound extract_s]  }
		"extract_sw"	{ set docol_OK [IsItASound extract_sw] }
		"extract_snw"	{ set docol_OK [IsItASound extract_snw]}
		"extract_ns"	{ set docol_OK [IsItASound extract_ns] }
		"remove_ns"		{ set docol_OK [IsItASound remove_ns] }
		"extract_ch"	{ set docol_OK [IsItASound extract_ch] }
		"extract_tow"	{ set docol_OK [IsItASound extract_tow] }
		"extract_cop"	{ set docol_OK [IsItASound extract_cop] }
		"find_dupls"	{ set docol_OK [IsItASound find_dupls] }
		"find_dupcnt"	{ set docol_OK [IsItASound find_dupcnt] }
		"transpairs"	{ set docol_OK [ExtractTransformationPairs]}
		"condsub"		{ set docol_OK [MassageFilenames condsub   0 $tabed.bot.itframe.l.list]}
		"condsubf"		{ set docol_OK [MassageFilenames condsubf  0 $tabed.bot.itframe.l.list]}
	}
	if {$docol_OK} {

;# PROCEED TO OUTPUT TABLE AS NORMALLY
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
	} else {
		DisableOutputTableOptions 1
	}
}

#------ Various procedures to check if a listed item is a sound, or a duplicated sound

proc IsItASound {selection} {
	global tabed pa evv
	set is_blocked 0
	set all_are_sounds 1
	set not_copied 0
	set orig_list [$tabed.bot.itframe.l.list get 0 end]
	if {($selection == "find_dupls") || ($selection == "find_dupcnt")} {
		set dupl_list [CountDuplicates $orig_list]
		if {[llength $dupl_list] <= 0} {
			ForceVal $tabed.message.e "There are NO duplicate soundfiles in the list"
			$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		foreach item $dupl_list {
			lappend reduced_list [lindex $item 0]					;#	LIST TO SEARCH CONSISTS ONLY OF DUPLICATED ITEMS
		}
	} elseif {$selection == "remove_ns"} {
		set reduced_list $orig_list									;#	LIST TO SEARCH INCLUDES ALL ENTRIES, INCLUDING DUPLICATES
		set selection "extract_s"
	} else {
		set reduced_list [RemoveDuplicates $orig_list]				;#	LIST TO SEARCH INCLUDES NO DUPLICATIONS
	}
	set orig_selection $selection
	if {$selection == "extract_cop"} {
		set selection "extract_tow"
	}
	set cnt 0
	foreach fnam $reduced_list {
		if {[file exists $fnam]} {									;#	FILE EXISTS
			if {[info exists pa($fnam,$evv(FTYP))]} {				;#	FILE IS ON WORKSPACE
				if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE))} {		;#	FILE IS A SOUNDFILE
					switch -- $selection {
						"extract_s" -
						"extract_sw" {
							lappend nunames $fnam
						}				
					}												;#	ITEM IS NOT A SOUNDFILE
				} elseif {($selection == "extract_ns") || ($selection == "extract_ch")} {
					lappend nunames $fnam
				} elseif {($selection == "find_dupls") || ($selection == "find_dupcnt")} {
					set dupl_list [lreplace $dupl_list $cnt $cnt]
					if {[llength $dupl_list] <= 0} {
						break
					}
				}
			} else {
				if {$selection == "extract_sw"} {					;# FILE IS NOT ON WORKSPACE
					continue
				}
				if {!$is_blocked} {
					Block "CHECKING SOUNDFILES WHICH ARE NOT ON WORKSPACE"
					set is_blocked 1
				}
				set ftyp [FindFileType $fnam]
				if {$ftyp == $evv(SNDFILE)} {						;# FILE IS A SOUNDFILE, BUT NOT ON WORKSPACE
					if {$selection == "extract_s" || $selection == "extract_snw"} {
						lappend nunames $fnam
					} elseif {$selection == "extract_tow"} {
						if {[FileToWkspace $fnam 0 0 0 0 0] <= 0} {
							lappend nunames $fnam
						}
					}
																	;# FILE EXISTS BUT IS NOT A SOUNDFILE
				} elseif {($selection == "extract_ns") || ($selection == "extract_ch") || ($selection == "extract_tow")} {
					lappend nunames $fnam
				} elseif {($selection == "find_dupls") || ($selection == "find_dupcnt")} {
					set dupl_list [lreplace $dupl_list $cnt $cnt]
					if {[llength $dupl_list] <= 0} {
						break
					}
				}
			}														;# SUCH A FILE DOES NOT EXIST, OR IS CDP-INCOMPATIBLE
		} elseif {($selection == "extract_ns") || ($selection == "extract_ch") || ($selection == "extract_tow")} {
			lappend nunames $fnam
		}
		incr cnt
	}
	$tabed.bot.otframe.l.list delete 0 end
	if {$is_blocked} {
		UnBlock
	}
	set selection $orig_selection
	switch -- $selection {
		"extract_ch" {
			if {![info exists nunames]} {
				ForceVal $tabed.message.e "All files are soundfiles"
				$tabed.message.e config -bg $evv(EMPH)
				return 0
			} else {
				ForceVal $tabed.message.e "Files which are NOT soundfiles shown in output table"
				$tabed.message.e config -bg $evv(EMPH)
			}
		} 
		"extract_tow" {
			if {![info exists nunames]} {
				ForceVal $tabed.message.e "All items which are soundfiles moved onto workspace"
				$tabed.message.e config -bg $evv(EMPH)
				return 0
			} else {
				ForceVal $tabed.message.e "Items NEITHER ON NOR MOVED TO WORKSPACE shown in output table"
				$tabed.message.e config -bg $evv(EMPH)
			}
		}
		"extract_cop" {
			if {[info exists nunames]} {
				ForceVal $tabed.message.e "Some files NOT MOVED TO WKSPACE (see output table): CAN'T PROCEED"
				$tabed.message.e config -bg $evv(EMPH)
			} else {
				set innames $orig_list
				set nunames [GenerateCopiesWhereNess $innames]
				set changed 0
				foreach inname $innames nuname $nunames {
					if {![string match $inname $nuname]} {
						set changed 1
						break
					}
				}
				if {!$changed} {
					ForceVal $tabed.message.e "No copies were needed"
					$tabed.message.e config -bg $evv(EMPH)
					return 0
				}
			}
		}
		"find_dupcnt" -
		"find_dupls" {
			if {[llength $dupl_list] <= 0} {
				ForceVal $tabed.message.e "There are NO duplicate soundfiles in the list"
				$tabed.message.e config -bg $evv(EMPH)
				return 0
			}
			if {$selection == "find_dupls"} {
				foreach item $dupl_list {
					lappend nunames [lindex $item 0]
				}
			} else {
				foreach item $dupl_list {
					set val [lindex $item 1]
					append val " X  " [lindex $item 0]
					lappend nunames $val
				}
			}
		}
	}
	if {![info exists nunames]} {
		ForceVal $tabed.message.e "There are no such files in the table"
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	foreach fnam $nunames {
		$tabed.bot.otframe.l.list insert end $fnam
	}
	return 1
}

#--- Make copies of soundfiles, where duplicates are needed

proc GenerateCopiesWhereNess {sndfilenames} {
	global wl wstk
	set is_blocked 0
	set cnt [llength $sndfilenames]
	set cnt_less_one [expr $cnt - 1]
	set n 0
	set use_all_existing_copies 0
	while {$n < $cnt_less_one} {
		set file_n [lindex $sndfilenames $n]
		set m $n
		incr m
		set copcnt 0
		if {$use_all_existing_copies} {
			set use_existing_copies 1
		} else {
			set use_existing_copies 0
		}
		while {$m < $cnt} {
			set file_m [lindex $sndfilenames $m]
			if {[string match $file_m $file_n]} {
				if {!$is_blocked} {
					Block "MAKING COPIES OF SOUNDS"
					set is_blocked 1
				}
				set is_pwd 0
				set dir [file dirname $file_n]
				if {[string length $dir] <= 1} {
					set dir ""
					set is_pwd 1
				}
				set ext [file extension $file_n]
				set basename [file rootname [file tail $file_n]]
				append basename "_cop"
				set thisname $basename$copcnt
				if {$is_pwd} {
					set test_nufnam [file join [pwd] $thisname]
				} else {
					set test_nufnam [file join $dir $thisname]
				}
				append test_nufnam $ext
				set nufnam [file join $dir $thisname]
				append nufnam $ext
				set file_preexists 0
				while {[file exists $test_nufnam]} {
					if {$use_existing_copies} {
						set file_preexists 1
						break	
					} else {
						set msg "Copied Files With The Name '$file_m' Already Exist: Use Those ?"
						set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "yes"} {
							set use_existing_copies 1
							set file_preexists 1

							set msg "Use Existing Copied Files In All Cases ?"
							set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
							if {$choice == "yes"} {
								set use_all_existing_copies 1
							}
							break	
						}
					}
					incr copcnt
					set thisname $basename$copcnt
					if {$is_pwd} {
						set test_nufnam [file join [pwd] $thisname]
					} else {
						set test_nufnam [file join $dir $thisname]
					}
					append test_nufnam $ext
					set nufnam [file join $dir $thisname]
					append nufnam $ext
				}
				incr copcnt
				if {!$file_preexists} { 
					if {[catch {file copy $file_n $nufnam} zit]} {
						Inf "Failed To Copy File '$file_n' To '$nufnam'"
					} else {
						if {[HasPmark $file_n]} {
							CopyPmark $file_n $nufnam
						}
						if {[HasMmark $file_n]} {
							CopyMmark $file_n $nufnam
						}
						DummyHistory $nufnam "CREATED"
					}
				}
				if {[LstIndx $nufnam $wl] < 0} {
					FileToWkspace $nufnam 0 0 0 0 1
				}
				set sndfilenames [lreplace $sndfilenames $m $m $nufnam]
			}	
			incr m
		}
		incr n
	}
	if {$is_blocked} {
		UnBlock
	}
	return $sndfilenames
}

#----- Remove duplicated items in a list

proc RemoveDuplicates {origlist} {

	set len [llength $origlist]
	if {$len < 2} {
		return $origlist
	}
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set fnam_n [lindex $origlist $n]
		set m [expr $n + 1]
		while {$m < $len} {
			set fnam_m [lindex $origlist $m]
			if {[string match $fnam_n $fnam_m]} {
				set origlist [lreplace $origlist $m $m]
				incr m -1
				incr len -1
				incr len_less_one -1
			}
			incr m
		}
		incr n
	}
	return $origlist
}
	
#----- Save & Count duplicated items in a list

proc CountDuplicates {origlist} {

	set len [llength $origlist]
	if {$len < 2} {
		return $origlist
	}
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set fnam_n [lindex $origlist $n]
		set m [expr $n + 1]
		while {$m < $len} {
			set fnam_m [lindex $origlist $m]
			if {[string match $fnam_n $fnam_m]} {
				if {![info exists dupl($fnam_n)]} {
					set dupl($fnam_n) 2
				} else {
					incr dupl($fnam_n)
				}
				set origlist [lreplace $origlist $m $m]
				incr m -1
				incr len -1
				incr len_less_one -1
			}
			incr m
		}
		incr n
	}
	if {![info exists dupl]} {
		return {}
	}
	foreach name [array names dupl] {
		set item $name
		lappend item $dupl($name)
		lappend dupl_list $item
	}
	return $dupl_list
}

#------ Cyclically extract items from table list, to input column: or cyclically insert from outcol to outtab

proc Cyclics {typ} {
	global lmo col_ungapd_numeric threshold colpar tot_inlines incols tot_outlines outcolcnt tabedit_ns evv
	global record_temacro temacro temacrop docol_OK col_tabname col_infnam tabed cycle_list outlines coltype
	global inlines

	HaltCursCop
	set lmo "cy"
	lappend lmo 0 $typ
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <= 0)} {
		ForceVal $tabed.message.e  "No input table to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
	set co $tabed.bot.ocframe.l.list
	set ci $tabed.bot.icframe.l.list
 	set kt $tabed.bot.ktframe
	if {$typ == "put"} {
		if {![info exists outlines] || ($outlines <= 0)} {
			ForceVal $tabed.message.e  "No output column to use."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists cycle_list] || ([llength $cycle_list] <= 0)} {
			ForceVal $tabed.message.e  "No memory of extraction cycle: Cannot cyclically insert."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[lindex $cycle_list end] != $outlines} {
			ForceVal $tabed.message.e  "Length of output column does not tally with insert cycle."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {$typ == "gettab"} {
		if {![info exists colpar] || ![regexp {^[0-9]+$} $colpar] || ($colpar < 1)} {
			ForceVal $tabed.message.e  "Invalid cycle value at N."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists threshold] || ![regexp {^[0-9]+$} $threshold] || ($threshold < 1)} {
			ForceVal $tabed.message.e  "Invalid start value at 'threshold'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$threshold > [$ti index end]} {
			ForceVal $tabed.message.e  "Insufficient lines in input table, for startline in 'threshold'"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	SetInout 1

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set docol_OK 0
	switch -- $typ {
		"get" {
			set docol_OK [MassageFilenames getfiles 0 $ti]
			if {[info exists cycle_list]} {
				set docol_OK 1 
			}
		}
		"gettab" {
			set g [expr $threshold - 1]
			set cnt 0
			foreach item [$ti get 0 end]  {
				if {$cnt == $g} {
					lappend nulines $item
					incr g $colpar
				}
				incr cnt
			}
			$to delete 0 end
			foreach item $nulines {
				$to insert end $item
			}
			set docol_OK 1
		}
		"put" {
			set dataend [llength $cycle_list]
			incr dataend -2
			set ocol [$co get 0 end]
			set otab [$ti get 0 end]
			foreach i [lrange $cycle_list 0 $dataend] item $ocol {
				set otab [lreplace $otab $i $i $item] 
			}
			$tb.otframe.l.list delete 0 end
			foreach item $otab {
				$to insert end $item
			}
			set docol_OK 1
		}
	}
	switch -- $typ {
		"put" {
			if {$docol_OK} {
				if {[WriteOutputTable $evv(LINECNT_RESET)]} {
					EnableOutputTableOptions 0 1
				}
			} else {
				DisableOutputTableOptions 1
			}
		}
		"get" {
			if {$docol_OK} {
				catch {close $fileoc}
				if [catch {open $evv(COLFILE1) "w"} fileoc] {
					ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE1) to write column data"
		 			$tabed.message.e config -bg $evv(EMPH)
					$ci delete 0 end		;#	Clear existing listing of input column
					set inlines ""
					ForceVal $tabed.bot.icframe.dummy.cnt $inlines
					catch {unset cycle_list}
				} else {
					set inlines 0
					foreach line [$ci get 0 end] {
						puts $fileoc $line
						incr inlines
					}
					ForceVal $tabed.bot.icframe.dummy.cnt $inlines
					close $fileoc						;#	Write data to file

					set orig_incolget ""
					ForceVal $tabed.bot.gframe.got $orig_incolget
					if {($outlines > 0) && ($coltype == "o")} {
						SetKCState "i"
					}
				}
			} else {
				$ci delete 0 end		;#	Clear existing listing of output 
				set inlines ""
				ForceVal $tabed.bot.icframe.dummy.cnt $inlines
				catch {unset cycle_list}
			}
		}
		"gettab" {
			if {$docol_OK} {
				if {[WriteOutputTable $evv(LINECNT_RESET)]} {
					EnableOutputTableOptions 0 1
				}
			} else {
				DisableOutputTableOptions 1
			}
		}
	}
}

#------ User Info on Transformation Pair extraction

proc TransPairsInfo {} {
	set msg "EXTRACT TRANSFORMATION PAIRS\n"
	append msg "________________________________\n"
	append msg "\n"
	append msg "Assumes your list consists of\n"
	append msg "sounds and their transformations\n"
	append msg "and that transformations are indicated\n"
	append msg "by Segments added to the sound Names.\n"
	append msg "\n"
	append msg "Where a sound is transformed more than once\n"
	append msg "those segments must be in the order\n"
	append msg "in which the transfomations take place...\n"
	append msg "                                     either\n"
	append msg "Tail segments in the order left to right\n"
	append msg "(with the final transformation to the right)\n"
	append msg "                                     or\n"
	append msg "Head segments in the order right to left\n"
	append msg "(with the final transformation to the left).\n"
	append msg "\n"
	append msg "This process extracts sounds in pairs, such that ...\n"
	append msg "1) Left Hand item is transformed into Right Hand item.\n"
	append msg "2) Earlier transformations listed Before later ones.\n"
	append msg "3) Transformations of a single type\n"
	append msg "      are grouped together in the list.\n"
	append msg "\n"
	append msg "If desired, transformations where the Output Sound\n"
	append msg "ALREADY EXISTS may be omitted from the output list.\n"
	append msg "\n"
	append msg "From this data, Bulk Processing ('Bulk Proc')\n"
	append msg "can be run on the Workspace\n"
	append msg "(see 'Split Transformation Pairs').\n"
	Inf $msg
}

#------ User Info on Transformation Pair Splitting

proc SplitPairsInfo {} {
	set msg "SPLIT TRANSFORMATION PAIRS\n"
	append msg "_____________________________\n"
	append msg "\n"
	append msg "Take The Output File From\n"
	append msg "'Extract Transformation Pairs' ('From Snds' menu)\n"
	append msg "And Generate Set Of Textfiles Which Are\n"
	append msg "Soundfile Lists.\n"
	append msg "\n"
	append msg "Each Textfile Contains All The Input Files\n"
	append msg "(the 1st of each pair) For A Particular Process.\n"
	append msg "\n"
	append msg "Each Textfile Takes Its Name From Segment Added\n"
	append msg "To The 1st File In The Pair, To Generate The 2nd.\n"
	append msg "\n"
	append msg "Using These Data Files,\n"
	append msg "Groups Of Sounds Can Be Selected\n"
	append msg "& Bulk-Processed ('Bulk Proc') On The Workspace.\n"
	Inf $msg
}

#------ Insert elements into rootname of a file.

proc FileNameInsert {inlist addition atend} {

	foreach item $inlist {
		set ext [file extension $item]
		set dir [file dirname $item]
		if {[string length $dir] <= 1} {
			set dir ""
		}
		set basename [file rootname [file tail $item]]
		if {$atend} {
			append basename $addition
		} else {
			set zz $addition
			append zz $basename
			set basename $zz
		}
		if {![ValidCdpFilename $basename 1]} {
			return {}
		}
		set fnam [file join $dir $basename]
		append fnam $ext
		lappend nunames $fnam
	}
	return $nunames
}

#---------- Global Edit Table

proc GlobalEditTable {} {
	global col_ungapd_numeric tabed coltype ino okz lmo record_temacro colpar threshold temacrop outcolcnt tot_outlines tabedit_bind2 evv
	global tabedit_ns col_infnam col_tabname incols tot_inlines

	HaltCursCop

 	set kt $tabed.bot.ktframe
	set t $tabed.bot.kcframe
	set ot $tabed.bot.otframe.l.list
	set it $tabed.bot.itframe.l.list

	$ot config -bg $evv(EMPH)
	$it config -bg [option get . background {}]
	DisableOutputColumnOptions2 

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "GE"
	lappend lmo $col_ungapd_numeric
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	set tb $tabed.bot
	DisableOutputTableOptions 1

	set linecnt [$tabed.bot.itframe.l.list index end]
	if {$linecnt <= 0} {
		ForceVal $tabed.message.e "There is no data in the input table display."
 		$tabed.message.e config -bg [option get . background {}]
		return
	}
	set inlen [string length $colpar]
	set outlen [string length $threshold]
	if {$inlen <= 0} {
		set msg "No text to replace provided in 'N'."
		ForceVal $tabed.message.e $msg
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$outlen <= 0} {
		set msg "No replacement text provided in 'theshold'."
		ForceVal $tabed.message.e $msg
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set docol_OK 0
	foreach line [$tabed.bot.itframe.l.list get 0 end] {
		set basek 0
		set subline [string range $line $basek end]
		while {[set k [string first $colpar $subline]] >= 0} {
			incr k -1
			set line [string range $line 0 [expr $basek + $k]]
			incr k
			incr basek $k
			append line $threshold
			incr basek $outlen
			incr k $inlen
			append line [string range $subline $k end]
			set subline [string range $line $basek end]
			set docol_OK 1
		}
		lappend nulines $line
	}
	if {$docol_OK} {
		$ot delete 0 end
		foreach item $nulines {
			$ot insert end $item
		}
		if [catch {open $evv(COLFILE3) "w"} fileot] {
			ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach item $nulines {
			puts $fileot $item
		}
		close $fileot
		set outcolcnt $incols
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines $tot_inlines
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		EnableOutputTableOptions 1 1
	} else {
		ForceVal $tabed.message.e  "No information has been changed."
 		$tabed.message.e config -bg $evv(EMPH)
		return
	}
}

proc SyncMidships {colmode} {
	global col_ungapd_numeric tabed coltype ino okz lmo record_temacro colpar threshold temacrop outcolcnt tot_outlines tabedit_bind2 evv
	global tabedit_ns col_infnam col_tabname incols tot_inlines pa ot_has_fnams col_files_list

	HaltCursCop

 	set kt $tabed.bot.ktframe
	set t $tabed.bot.kcframe
	set ot $tabed.bot.otframe.l.list
	set it $tabed.bot.itframe.l.list

	$ot config -bg $evv(EMPH)
	$it config -bg [option get . background {}]
	DisableOutputColumnOptions2 

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "Sy"
	lappend lmo $col_ungapd_numeric $colmode
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	set tb $tabed.bot

	if {$colmode == 0} {
		if {$colmode == 0} {
			if {![info exists colpar] || ![IsNumeric $colpar] || ($colpar <= 0.0)} {
				ForceVal $tabed.message.e  "Invalid value at 'N'.  Must be positive numeric."
 				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		if {[$it index end] < 0} {
			ForceVal $tabed.message.e  "No input table."
 			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set in_lines [$it get 0 end]
		foreach line $in_lines {
			set fnam [lindex $line 0]
			set fnam [string trim $fnam]
			if {[string match ";*" $fnam]} {
				continue
			}
			if {![file exists $fnam]} {
				ForceVal $tabed.message.e  "File must be a mixfile."
 				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {![info exists pa($fnam,$evv(FTYP))] || ($pa($fnam,$evv(FTYP)) != $evv(SNDFILE))} {
				ForceVal $tabed.message.e  "Items listed in file must be Sounds currently on workspace."
 				$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	} else {
		if {$ot_has_fnams} {						 ;#	If new fnames entered, use them - else use previous
			catch {unset col_files_list}
			foreach fnam [$tb.otframe.l.list get 0 end] {
				lappend col_files_list $fnam
			}
		} else {
			ForceVal $tabed.message.e "Items in output table are not files."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists col_files_list] || ([set len [llength $col_files_list]] <= 0)} {
			ForceVal $tabed.message.e "No files selected."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$len != 2} {
			ForceVal $tabed.message.e  "This option only works with TWO files."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set fnam1 [lindex $col_files_list 0]
		set fnam2 [lindex $col_files_list 1]
		set ftyp $pa($fnam1,$evv(TYP))
		if {!(($ftyp & $evv(MIXFILE)) && ($ftyp != $evv(WORDLIST)))} {
			ForceVal $tabed.message.e  "First file must be a mixfile."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set ftyp $pa($fnam2,$evv(TYP))
		if {!($ftyp & $evv(NUMLIST))} {
			ForceVal $tabed.message.e  "2nd file must be a list of times."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if [catch {open $fnam1 r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam1 to read data."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set inlinecnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			set line [split $line]
			set fnam [lindex $line 0]
			if {[string match ";*" $fnam]} {
				set line [join $line]
				lappend in_lines $line
				continue
			}
			catch {unset nuline}
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set line [join $nuline]
			lappend in_lines $line
			incr inlinecnt
		}
		close $zit
		if {$inlinecnt == 0} {
			ForceVal $tabed.message.e  "No data in file $fnam1."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if [catch {open $fnam2 r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam2 to read data."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			foreach item $line {
				if {[string length $item] > 0} {
					lappend synctimes $item
				}
			}
		}
		close $zit
		if {![info exists synctimes]} {
			ForceVal $tabed.message.e  "No data in file $fnam2."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[llength $synctimes] != $inlinecnt} {
			ForceVal $tabed.message.e  "Number of mix times and number of offset times do not tally."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	DisableOutputTableOptions 1

	set cnt 0
	set realcnt 0
	set minstarttime 0.0

	foreach line $in_lines {
		set fnam [lindex $line 0]
		set fnam [string trim $fnam]
		if {[string match ";*" $fnam]} {
			lappend nulines $line
			incr cnt
			continue
		}
		set starttime [lindex $line 1]
		set dur $pa($fnam,$evv(DUR))
		switch -- $colmode {
			0 {	
				set syncpnt $colpar 
				set backshift [expr $dur - $syncpnt]
			}
			1 { 
				set syncpnt [lindex $synctimes $realcnt]
				set backshift [expr $dur - $syncpnt]
			}
			2 { 
				set backshift [lindex $synctimes $realcnt]
			}
		}
		if {$backshift < 0} {
			ForceVal $tabed.message.e  "File $fnam is too short."
 			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set starttime [expr $starttime - $backshift]
		if {$starttime < $minstarttime} {
			set minstarttime $starttime
		}
		set line [lreplace $line 1 1 $starttime]
		lappend nulines $line
		incr cnt
		incr realcnt
	}
	if {$minstarttime < 0} {
		set jj 0
		while {$jj < $cnt} {
			set line [lindex $nulines $jj]
			set fnam [lindex $line 0]
			if {[string match ";*" $fnam]} {
				incr jj
				continue
			}
			set starttime [lindex $line 1]
			set starttime [expr $starttime - $minstarttime]
			set line [lreplace $line 1 1 $starttime]
			set nulines [lreplace $nulines $jj $jj $line]
			incr jj
		}
	}
	$ot delete 0 end
	foreach item $nulines {
		$ot insert end $item
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach item $nulines {
		puts $fileot $item
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
	set ot_has_fnams 0
}

#------ Merge 2 mixfiles, with time-offset

proc MergeMixfiles {colmode} {
	global col_ungapd_numeric tabed coltype ino okz lmo record_temacro colpar threshold temacrop outcolcnt tot_outlines tabedit_bind2 evv
	global tabedit_ns col_infnam col_tabname incols tot_inlines pa ot_has_fnams col_files_list

	HaltCursCop

 	set kt $tabed.bot.ktframe
	set t $tabed.bot.kcframe
	set ot $tabed.bot.otframe.l.list
	set it $tabed.bot.itframe.l.list

	$ot config -bg $evv(EMPH)
	$it config -bg [option get . background {}]
	DisableOutputColumnOptions2 

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "Mm"
	lappend lmo $col_ungapd_numeric $colmode
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	set tb $tabed.bot

	if {$ot_has_fnams} {						 ;#	If new fnames entered, use them - else use previous
		catch {unset col_files_list}
		foreach fnam [$tb.otframe.l.list get 0 end] {
			lappend col_files_list $fnam
		}
	} else {
		ForceVal $tabed.message.e "Items in output table are not files."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists col_files_list] || ([set len [llength $col_files_list]] <= 0)} {
		ForceVal $tabed.message.e "No files selected."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$len != 2} {
		ForceVal $tabed.message.e  "This option only works with TWO files."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set fnam1 [lindex $col_files_list 0]
	set fnam2 [lindex $col_files_list 1]
	set ftyp $pa($fnam1,$evv(TYP))
	if {!(($ftyp & $evv(MIXFILE)) && ($ftyp != $evv(WORDLIST)))} {
		ForceVal $tabed.message.e  "First file must be a mixfile."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set ftyp $pa($fnam2,$evv(TYP))
	if {!(($ftyp & $evv(MIXFILE)) && ($ftyp != $evv(WORDLIST)))} {
		ForceVal $tabed.message.e  "2nd file must be a mixfile."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	switch -- $colmode {
		0 {
			if {![info exists colpar] || ([string length $colpar] <= 0)} {
				set colpar 0.0
			} elseif {![IsNumeric $colpar] || ($colpar < 0.0)} {
				ForceVal $tabed.message.e  "Invalid value at 'N'.  Must be positive numeric."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set offset $colpar
		}
		2 {
			if {![info exists pa($fnam1,$evv(DUR))]} {
				ForceVal $tabed.message.e  "Cannot get duration of 1st infile."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set offset $pa($fnam1,$evv(DUR))
			set colmode 0
		}
	}
	switch -- $colmode {
		0 {
			if [catch {open $fnam1 r} zit] {
				ForceVal $tabed.message.e  "Cannot open file $fnam1 to read data."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set inlinecnt 0
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				set fnam [lindex $line 0]
				if {[string match ";*" $fnam]} {
					set line [join $line]
					continue
				}
				catch {unset nuline}
				foreach item $line {
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				lappend in_lines $nuline
				incr inlinecnt
			}
			close $zit

			if [catch {open $fnam2 r} zit] {
				ForceVal $tabed.message.e  "Cannot open file $fnam2 to read data."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				set fnam [lindex $line 0]
				if {[string match ";*" $fnam]} {
					set line [join $line]
					continue
				}
				catch {unset nuline}
				foreach item $line {
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				set starttime [lindex $nuline 1]
				set starttime [expr $starttime + $offset]
				set nuline [lreplace $nuline 1 1 $starttime]
				lappend in_lines $nuline
				incr inlinecnt
			}
			close $zit
		}
		1 {
			if [catch {open $fnam1 r} zit] {
				ForceVal $tabed.message.e  "Cannot open file $fnam1 to read data."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set inlinecnt 0
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				set fnam [lindex $line 0]
				if {[string match ";*" $fnam]} {
					set line [join $line]
					continue
				}
				catch {unset nuline}
				foreach item $line {
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				lappend in_lines $nuline
				incr inlinecnt
			}
			close $zit
			set lastsnd [lindex [lindex $in_lines end] 0]
			set lasttime [lindex [lindex $in_lines end] 1]
			set len [llength $in_lines]
			if {$len <= 0} {
				ForceVal $tabed.message.e  "No data in file $fnam1."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			incr len -2
			set in_lines [lrange $in_lines 0 $len]
			if [catch {open $fnam2 r} zit] {
				ForceVal $tabed.message.e  "Cannot open file $fnam2 to read data."
				$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set cnt2 0
			set in_lines
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				set fnam [lindex $line 0]
				if {[string match ";*" $fnam]} {
					set line [join $line]
					continue
				}
				catch {unset nuline}
				foreach item $line {
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				set time [expr [lindex $nuline 1] + $lasttime]
				set nuline [lreplace $nuline 1 1 $time]
				set time
				if {$cnt2 == 0} {
					set firstsnd [lindex $nuline 0]
					if {![string match $lastsnd $firstsnd]} {
						ForceVal $tabed.message.e  "Sound at end of mix1, not same as snd at start of mix2."
						$tabed.message.e config -bg $evv(EMPH)
					}
				}
				lappend in_lines $nuline
				incr cnt2
			}
			close $zit
		}
	}
	DisableOutputTableOptions 1

	set cnt 0
	set realcnt 0
	set minstarttime 0.0

	set len $inlinecnt
	set len_less_one [expr $len - 1]
	set k 0

	while {$k < $len_less_one} {
		set line_k [lindex $in_lines $k]
		set time_k [lindex $line_k 1]
		set j [expr $k + 1]
		while {$j < $len} {
			set line_j [lindex $in_lines $j]
			set time_j [lindex $line_j 1]
			if {$time_j < $time_k} {
				set in_lines [lreplace $in_lines $k $k $line_j]
				set in_lines [lreplace $in_lines $j $j $line_k]
				set time_k $time_j
				set line_k $line_j
			}
			incr j
		}
		incr k
	}
	$ot delete 0 end
	foreach item $in_lines {
		$ot insert end $item
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach item $in_lines {
		puts $fileot $item
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	EnableOutputTableOptions 1 1
	set tot_outlines [$ot index end]
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	set ot_has_fnams 0
}

#------- Reposition times in grid to accord with peaks in snds.

proc RepositionMixtimes {} {
	global col_ungapd_numeric tabed coltype ino okz lmo record_temacro colpar threshold temacrop outcolcnt tot_outlines tabedit_bind2 evv
	global tabedit_ns col_infnam col_tabname incols tot_inlines pa ot_has_fnams col_files_list

	HaltCursCop

 	set kt $tabed.bot.ktframe
	set t $tabed.bot.kcframe
	set ot $tabed.bot.otframe.l.list
	set it $tabed.bot.itframe.l.list

	$ot config -bg $evv(EMPH)
	$it config -bg [option get . background {}]
	DisableOutputColumnOptions2 

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "RP"
	lappend lmo $col_ungapd_numeric
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	if {$ot_has_fnams} {						 ;#	If new fnames entered, use them - else use previous
		catch {unset col_files_list}
		foreach ffnam [$ot get 0 end] {
			lappend col_files_list $ffnam
		}
	} else {
		ForceVal $tabed.message.e "Items in output table are not files."
 		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists col_files_list] || ([set len [llength $col_files_list]] <= 0)} {
		ForceVal $tabed.message.e "No files selected."
 		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$len != 3} {
		ForceVal $tabed.message.e  "This option only works with THREE files."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}

;#	IF OFFSET IS NEGATIVE, IT'S OFFSET FROM END


	set fnam(0) [lindex $col_files_list 0]
	set fnam(1) [lindex $col_files_list 1]
	set fnam(2) [lindex $col_files_list 2]

	set ftyp $pa($fnam(0),$evv(TYP))
	if {($ftyp & $evv(MIXFILE)) && ($ftyp != $evv(WORDLIST))} {
		set is_a_mix 1
	} elseif {$ftyp & $evv(NUMLIST)} {
		set is_a_mix 0
	} else {
		ForceVal $tabed.message.e  "File $fnam($k) is neither a mixfile nor a list of numeric values."
 		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set k 1
	while {$k < 3} {
		if {!($pa($fnam($k),$evv(FTYP)) & $evv(NUMLIST))} {
			ForceVal $tabed.message.e  "File $fnam($k) is not a list of numeric values."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		incr k
	}
	if {$is_a_mix} {
		if {$pa($fnam(1),$evv(NUMSIZE)) != $pa($fnam(2),$evv(NUMSIZE))} {
			ForceVal $tabed.message.e  "Files do not have same number of entries."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} else {
		if {($pa($fnam(0),$evv(NUMSIZE)) != $pa($fnam(1),$evv(NUMSIZE))) \
		||  ($pa($fnam(0),$evv(NUMSIZE)) != $pa($fnam(2),$evv(NUMSIZE)))} {
			ForceVal $tabed.message.e  "Files do not have same number of entries."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	set k 0
	while {$k < 3} {
		if {($k == 1) && $is_a_mix} {
			if {[llength $vals(0)] != $pa($fnam(1),$evv(NUMSIZE))} {
				ForceVal $tabed.message.e  "Files do not haver same number of entries."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
		if [catch {open $fnam($k) r} zit] {
			ForceVal $tabed.message.e  "Cannot open file $fnam($k) to read data."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			catch {unset nuline}
			set line [split $line]
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set line $nuline
			if {($k == 0) && $is_a_mix} {
				if {[string match ";*" [lindex $line 0]]} {
					set line [join $line]
					lappend mixlines $line
					continue
				}
				lappend vals($k) [lindex $line 1]
				lappend mixlines $line
			} else {
				foreach item $line {
					if {[string length $item] > 0} {
						lappend vals($k) $item
					}
				}
			}
		}
		close $zit
		incr k
	}
	foreach item $vals(1) {
		if {$item <= 0.0} {
			ForceVal $tabed.message.e  "Invalid (negative or zero) duration values in file 2."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	set minpos 0.0
	foreach pos $vals(0) dur $vals(1) offset $vals(2) {
		if {$offset < 0.0} {
			set offset [expr $dur + $offset]
		}
		set pos [expr $pos - $offset]
		if {$pos < $minpos} {
			set minpos $pos
		}
		lappend nulines $pos
	}
	if {$minpos < 0.0} {
		set minpos [expr -$minpos]
		foreach val $nulines { 
			set val [expr $val + $minpos]
			lappend nupos $val
		}
		set nulines $nupos
	}
	if {$is_a_mix} {
		set mixlen [llength $mixlines]
		set valcnt 0
		set mixcnt 0
		while {$mixcnt < $mixlen} {
			set line [lindex $mixlines $mixcnt]
			if {[string match ";*" [lindex $line 0]]} {
				incr mixcnt
				continue
			}
			set line [lreplace $line 1 1 [lindex $nulines $valcnt]]
			set mixlines [lreplace $mixlines $mixcnt $mixcnt $line]
			incr valcnt
			incr mixcnt
		}
		set nulines $mixlines
	}
	$ot delete 0 end
	foreach item $nulines {
		$ot insert end $item
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach item $nulines {
		puts $fileot $item
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
	ForceVal $tabed.message.e  "Output positions offset from original zero by $minpos"
 	$tabed.message.e config -bg $evv(EMPH)
	set ot_has_fnams 0
}

proc InfoRepositionMixtimes {} {
	set msg    "REPOSITION MIXTIMES TO COINCIDE WITH SOUND PEAKS\n"
	append msg "\n"
	append msg "Use Three files.\n"
	append msg "\n"
	append msg "1) A mixfile OR\n"
	append msg "     A file with a list of mix sound-onset times\n"
	append msg "     (column 2 of a mixfile).\n"
	append msg "\n"
	append msg "2) A file with a list of the sndfile durations.\n\n"
	append msg "3) A file with a list of the time-offset\n"
	append msg "      of the peak within each sound.\n"
	append msg "      A NEGATIVE Value Of Offset indicates\n"
	append msg "      peak position is measured from END of sound.\n"
	append msg "      (useful if snd start has been time-stretched).\n"
	append msg "\n"
	append msg "\n"
	append msg "\n"
	append msg "Output is either a new mixfile\n"
	append msg "or list of new times for sounds within the mix,\n"
	append msg "Plus an indication of how much whole new sequence\n"
	append msg "is Offset From Time Zero of the original.\n"
	Inf $msg
}

proc TimeStretchHelp {} {
	set msg    "GENERATING SEVERAL TIME-WARP FILES\n"
	append msg "WHICH WARP TIME AT FILE START OR END ONLY\n"
	append msg "\n"
	append msg "Process generates set of Time Stretch data files\n"
	append msg "of these forms....\n"
	append msg "\n"
	append msg "STRETCH AT START\n"
	append msg "   0                      val\n"
	append msg "   endtime           val\n"
	append msg "   endtime+step   1\n"
	append msg "   1000                1\n"
	append msg "\n"
	append msg "STRETCH AT END\n"
	append msg "   0                      1\n"
	append msg "   starttime           1\n"
	append msg "   starttime+step   val\n"
	append msg "   1000                val\n"
	Inf $msg
	set msg "There are 3 different ways this can be done.\n"
	append msg "\n"
	append msg "1) Set of files where timewarping has fixed value\n"
	append msg "      but begins at a different time in each file.\n"
	append msg "\n"
	append msg "      Create file of times. Enter this as the table.\n"
	append msg "      and select it as a column.\n"
	append msg "      Give Fixed Timewarp Value value in 'N'\n"
	append msg "      Give a STEP value in 'Threshold'\n"
	append msg "\n"
	append msg "2) Set of files where timewarping begins (or ends) at\n"
	append msg "      fixed time, but has different val in each file.\n"
	append msg "\n"
	append msg "      Create file of values. Enter this as the table,\n"
	append msg "      and select it as a column.\n"
	append msg "      Put Fixed Timewarp Starttime (or Endtime) in 'N'\n"
	append msg "      Give a STEP value in 'Threshold'\n"
	append msg "\n"
	append msg "3) Set of files where timewarp begins at different times\n"
	append msg "      and has a different value in each file.\n"
	append msg "\n"
	append msg "     Create a file of values AND a file of times.\n"
	append msg "     Put the list of times in the Output column.\n"
	append msg "     Put the list of values in the Input column.\n"
	append msg "     Give a Step value in 'Threshold'\n"
	append msg "\n"
	append msg "Output Filenames are derived from the name of\n"
	append msg "the LAST File Entered Onto Input Table List.\n"
	Inf $msg
}

#------ generate set of tstretch files for stretching at start or at end ONLY.

proc StrMak {colmode} {
	global col_x wl lmo col_ungapd_numeric record_temacro temacro temacrop colpar threshold sl_real tabed evv

	if {!$sl_real} {
		Inf "You Can Create Sets Of Timestretch Data,"
		return
	}

	HaltCursCop

	set ci $tabed.bot.icframe.l.list
	set co $tabed.bot.ocframe.l.list

	set lmo "sm"
	lappend lmo $col_ungapd_numeric $colmode

	if {![file exists $evv(COLFILE1)]} {
		ForceVal $tabed.message.e "No (input) column selected."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {($colmode == "TV") || ($colmode == "TS")} {
		if {![file exists $evv(COLFILE2)]} {
			ForceVal $tabed.message.e "No (output) column (of times) selected."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[$ci index end] != [$co index end]} {
			ForceVal $tabed.message.e "Number of values is different to the number of times."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	if {![info exists threshold] || ![IsNumeric $threshold] || ($threshold <= 0)} {
		ForceVal $tabed.message.e  "Invalid STEP value entered in 'threshold'."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set step $threshold
	set colmode1 [string index $colmode 0]
	set colmode2 [string index $colmode 1]
	set at_end 1
	if {[string match [string tolower $colmode2] "s"]} {
		set at_end 0
	}
	if {($colmode1 == "t") || ($colmode2 == "s") || ($colmode2 == "v")} {
		if {![info exists colpar] || ![IsNumeric $colpar] || ($colpar <= 0)} {
			ForceVal $tabed.message.e  "Invalid value or time in 'N'."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	set file_base [string trim [$tabed.bot.itframe.f0 cget -text]]
	set file_base [split $file_base]
	set file_base [file rootname [file tail [lindex $file_base end]]]
	set len [$ci index end]
	set k 0
	while {$k < $len} {
		set fnam $file_base
		append fnam "_" $k [GetTextfileExtension brk]
		if {[file exists $fnam]} {
			ForceVal $tabed.message.e "File $fnam already exists. Cannot proceed."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		incr k
	}			

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	set k 0
	Block "CREATING TIMESTRETCH FILES"
	switch -- $colmode {
		tS -	
		tV {	;#	FIXED TIMES: CHANGING VALUES
			set time $colpar 
			if {$at_end} {
				set pretime [expr $time - $step]
			} else {
				set pretime $time
				set time [expr $pretime + $step]
			}
			if {$pretime <= 0} {
				ForceVal $tabed.message.e "Step (in threshold) is too large for time (in N) given."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			foreach val [$ci get 0 end]	{
				set fnam $file_base
				append fnam "_" $k [GetTextfileExtension brk]
				if [catch {open $fnam w} zit] {
					lappend badfiles $fnam
					incr k
					continue
				}
				MakeStrFile $val $pretime $time $at_end $zit
				close $zit
				lappend nufiles $fnam
				incr k
			}
		}
		Ts -
		Tv {	;#	FIXED VALUES: CHANGING TIMES
			set val $colpar 
			foreach time [$ci get 0 end] {
				if {$at_end} {
					set pretime [expr $time - $step]
				} else {
					set pretime $time
					set time [expr $pretime + $step]
				}
				if {$pretime <= 0} {
					lappend badtimes $time
					incr k
					continue
				}
				set fnam $file_base
				append fnam "_" $k [GetTextfileExtension brk]
				if [catch {open $fnam w} zit] {
					lappend badfiles $fnam
					incr k
					continue
				}
				MakeStrFile $val $pretime $time $at_end $zit
				close $zit
				lappend nufiles $fnam
				incr k
			}
		}
		TS -
		TV {	;#	CHANGING VALUES AND TIMES
			foreach val [$ci get 0 end]	time  [$co get 0 end] 	{
				if {$at_end} {
					set pretime [expr $time - $step]
				} else {
					set pretime $time
					set time [expr $pretime + $step]
				}
				if {$pretime <= 0} {
					lappend badtimes $time
					incr k
					continue
				}
				set fnam $file_base
				append fnam "_" $k [GetTextfileExtension brk]
				if [catch {open $fnam w} zit] {
					lappend badfiles $fnam
					incr k
					continue
				}
				MakeStrFile $val $pretime $time $at_end $zit
				close $zit
				lappend nufiles $fnam
				incr k
			}
		}
	}
	UnBlock
	set bfil 0
	set btim 0
	set icnt [$ci index end]
	if {[info exists badfiles]} {
		set bfil [llength $badfiles]
	}
	if {[info exists badtimes]} {
		set btim [llength $badtimes]
	}
	if {[expr $bfil + $btim] >= $icnt} {
		if {$btim == $icnt}  {
			ForceVal $tabed.message.e "No files created. All times were too small for STEP value given."
	 		$tabed.message.e config -bg $evv(EMPH)
			return

		} elseif {$btim > 0} {
			ForceVal $tabed.message.e "No files created. $bfil files failed. $btim times too small for STEP value."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			ForceVal $tabed.message.e "No files created."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} elseif {[expr $bfil + $btim] > 0} {
		set msg ""
		if {$bfil > 0} {
			append msg "The Following Files Could Not Be Created\n\n"
			set k 0
			foreach fnam $badfiles {
				if {$k >= 20} {
					append msg "\n\nAnd More"
					break
				}
				append msg $fnam "   "
				incr k
			}
			append msg "\n\n"
		}
		if {$btim > 0} {
			append msg "The Following Times Were Too Small For The Step Value Given\n\n"
			set k 0
			foreach time $badtimes {
				if {$k >= 20} {
					append msg "\n\nAnd More"
					break
				}
				append msg $time "   "
				incr k
			}
		}
		Inf $msg
	}
	set nufiles [ReverseList $nufiles]
	foreach fnam $nufiles {
		FileToWkspace $fnam 0 0 0 0 1
	}
	ForceVal $tabed.message.e "Files created are on the workspace."
	$tabed.message.e config -bg $evv(EMPH)
}

#----- Make a timestretch file, for stretching at start on ly, or at end only.

proc MakeStrFile {val pretime time at_end zit} {
	if {$at_end} {
		set line [list 0 1]
		puts $zit $line
		set line [list $pretime 1]
		puts $zit $line
		set line [list $time $val]
		puts $zit $line
		set line [list 1000 $val]
		puts $zit $line
	} else {
		set line [list 0 $val]
		puts $zit $line
		set line [list $pretime $val]
		puts $zit $line
		set line [list $time 1]
		puts $zit $line
		set line [list 1000 1]
		puts $zit $line
	}
}

proc GetNumericPart {val} {
	set gg 0
	set pntcnt 0
	set len [string length $val]
	set len_less_one [expr $len - 1]
	while {$gg < $len} {
		set char [string index $val $gg]
		if {![info exists startnum]} {
			if {[regexp {[0-9]} $char]} {
				if {$gg > 0} {
					incr gg -1
					if {[regexp {\.} [string index $val $gg]]} {
						if {$gg > 0} {
							incr gg -1
							if {[regexp {\-} [string index $val $gg]]} {
								set startnum $gg
								incr gg 2
							} else {
								incr gg
								set startnum $gg
								incr gg
							}
						} else {
							set startnum $gg
							incr gg
						}
					} elseif {[regexp {\-} [string index $val $gg]]} {
						set startnum $gg
						incr gg
					} else {
						incr gg
						set startnum $gg
					}
				} else {
					set startnum $gg
				}
			}
		} elseif {![regexp {[0-9]} $char]} {
			if {$gg == $len_less_one} {								;#	END OF STRING
				set endnum $gg
				break
			} elseif {![regexp {\.} [string index $val $gg]]} {		;#	NOT A DECIMAL POINT
				set endnum $gg
				break
			} elseif {$pntcnt == 1} {								;#	ALREADY A DECIMAL POINT
				set endnum $gg
				break
			}
			incr pntcnt
			set ggnext [expr $gg + 1]
			if {($ggnext > $len_less_one) || ![regexp {[0-9]} [string index $val $ggnext]]} {			
				set endnum $gg										;#	NO NUMBER AFTER DECIMAL POINT
				break
			} else {
				incr gg												;#	SKIP NUMBER AFTER DECPOINT (already checked)
			}
		}
		incr gg
	}
	if {![info exists endnum]} {
		set endnum  $gg
	}
	incr endnum -1
	return [list $startnum $endnum]
}

#---------- Copy lines, indexing them numerically

proc IndexedDuplication {colmode p_cnt} {
	global col_ungapd_numeric tabed coltype ino okz lmo record_temacro colpar threshold temacrop outcolcnt tot_outlines tabedit_bind2 evv
	global tabedit_ns col_infnam col_tabname incols tot_inlines ot_has_fnams col_files_list colinmode col_x wstk

	HaltCursCop

 	set kt $tabed.bot.ktframe
	set t $tabed.bot.kcframe
	set ot $tabed.bot.otframe.l.list
	set it $tabed.bot.itframe.l.list

	$ot config -bg $evv(EMPH)
	$it config -bg [option get . background {}]
	DisableOutputColumnOptions2 

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "ID"
	lappend lmo $col_ungapd_numeric $colmode $p_cnt
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	set tb $tabed.bot

	if {$colmode == "id"} { 						 ;#	Use list of substition values
		if {$ot_has_fnams} {
			catch {unset col_files_list}
			foreach fnam [$tb.otframe.l.list get 0 end] {
				lappend col_files_list $fnam
			}
		} else {								;#	Check for existence, and correct no of infiles
			ForceVal $tabed.message.e "Items in output table are not files."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {![info exists col_files_list] || ([set len [llength $col_files_list]] <= 0)} {
			ForceVal $tabed.message.e "No files selected."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$len != 2} {
			ForceVal $tabed.message.e  "This option only works with TWO files."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}										;#	Open and read first infile	
		if [catch {open [lindex $col_files_list 0] r} zit] {
			ForceVal $tabed.message.e  "Cannot open file [lindex $col_files_list 0]."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				lappend inlines $line
			}
		}
		close $zit								;#	Open and read second infile	
		if [catch {open [lindex $col_files_list 1] r} zit] {
			ForceVal $tabed.message.e  "Cannot open file [lindex $col_files_list 1]."
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				if {[string length $item] > 0} {
					lappend subvals $item
				}
			}
		}
		close $zit
		if {![CreateColumnParams $colmode $p_cnt]} {
			return
		}
		set duplcnt $col_x(1)				;#	Get parameters
		set lookfor $col_x(2)
		if {[llength $subvals] < $duplcnt} {
			ForceVal $tabed.message.e  "File 2 has insufficient values to use for substitution."
			$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif  {[llength $subvals] > $duplcnt} {
			set msg "File 2 Has More Values Than Needed For The Substitution. Continue ??"
			set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "no"} {
				return
			}
		}
		set indxval -1
	} else {
		set linecnt [$tabed.bot.itframe.l.list index end]
		if {$linecnt <= 0} {
			ForceVal $tabed.message.e "There is no data in the input table display."
 			$tabed.message.e config -bg [option get . background {}]
			return
		}
		foreach line [$tabed.bot.itframe.l.list get 0 end] {
			lappend inlines $line
		}
		if {![CreateColumnParams $colmode $p_cnt]} {
			return
		}
		set duplcnt $col_x(1)
		set lookfor $col_x(2)
		set indxval $col_x(3)
	}
	set inlen [string length $lookfor]
	DisableOutputTableOptions 1
	set cnt 0
	set docol_OK 0
	while {$cnt < $duplcnt} {
		foreach line $inlines {
			set basek 0
			set endchar [expr [string length $line] -1]
			set subline [string range $line $basek end]
			while {[set k [string first $lookfor $subline]] >= 0} {

				;# CHECK THAT ONLY THIS NUMBER HAS BEEN FOUND!!
				set goodmatch 1
				while {$goodmatch} {
					set j [expr $basek + $k]
					if {$j > 0} {
						set jj [expr $j - 1]
						if {[regexp {[0-9\-]} [string index $line $jj]]} {
							set goodmatch 0
							break
						} elseif {[regexp {\.} [string index $line $jj]]} {
							incr jj -1
							if {$jj >= 0} {
								if {[regexp {[0-9]} [string index $line $jj]]} {
									set goodmatch 0
									break
								}
							}
						}
					}
					incr j [string length $lookfor]
					if {$j <= $endchar} {
						if {[regexp {[0-9]} [string index $line $j]]} {
							set goodmatch 0
							break
						} elseif {[regexp {\.} [string index $line $j]]} {
							incr j
							if {$j <= $endchar} {
								if {[regexp {[0-9]} [string index $line $j]]} {
									set goodmatch 0
									break
								}
							}
						}
					}
					break
				}
				if {$goodmatch} {
					incr k -1
					set line [string range $line 0 [expr $basek + $k]]
					incr k
					incr basek $k
					if {$colmode == "id"} {
						set val [lindex $subvals $cnt]
					} else {
						set val $indxval
					}
					append line $val
					set outlen [string length $val]
					incr basek $outlen
					incr k $inlen
					append line [string range $subline $k end]
					set subline [string range $line $basek end]
					incr endchar [expr $outlen - $inlen] 
					set docol_OK 1
				} else {
					incr basek $k
					incr basek [string length $lookfor]
					set subline [string range $line $basek end]
				}
			}
			lappend nulines $line
		}
		incr cnt
		incr indxval
	}
	if {$docol_OK} {
		$ot delete 0 end
		foreach item $nulines {
			$ot insert end $item
		}
		if [catch {open $evv(COLFILE3) "w"} fileot] {
			ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
 			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach item $nulines {
			puts $fileot $item
		}
		close $fileot
		set outcolcnt $incols
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines $tot_inlines
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		EnableOutputTableOptions 1 1
		if {$colmode == "id"} {
			set colinmode 0
			set ot_has_fnams 0
			ChangeColSelect 0
		}
	} else {
		ForceVal $tabed.message.e  "No information has been changed."
 		$tabed.message.e config -bg $evv(EMPH)
		return
	}
}

#------ Invert table rows

proc RowRotate {colmode} {
	global tabedit_ns tabedit_bind2 tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {[info exists colpar] && ([string length $colpar] > 0)} {
		if {![regexp {^[0-9]+$} $colpar] || ($colpar < 1)} {
			ForceVal $tabed.message.e "Invalid rotation value in parameter N."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		} elseif {$colpar >= $tot_inlines} {
			ForceVal $tabed.message.e "Parameter N too large for this table."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set rotation $colpar
	} else {
		set rotation 1
	}
	set lmo "rr"
	lappend lmo $col_ungapd_numeric $colmode
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	$ot delete 0 end
	switch -- $colmode {
		0 {
			set movlins [expr $tot_inlines - $rotation]
			foreach item [$it get $movlins end] {
				$ot insert end $item
			}
			incr movlins -1
			foreach item [$it get 0 $movlins] {
				$ot insert end $item
			}
		}
		1 {
			foreach item [$it get $rotation end] {
				$ot insert end $item
			}
			incr rotation -1
			foreach item [$it get 0 $rotation] {
				$ot insert end $item
			}
		}
	}
	foreach itm [$ot get 0 end] {
		puts $fileot $itm
	}
	close $fileot
	set outcolcnt $incols
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	EnableOutputTableOptions 1 1
}

proc OrderByColumn {} {
	global colpar threshold tabed col_files_list evv
	set fnam [lindex $col_files_list 0]
	if [catch {open $fnam r} zit] {
		ForceVal $tabed.message.e  "Cannot open file $fnam."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	set linecnt1 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set colcnt [llength $nuline]
		if {$colcnt < $colpar} {
			ForceVal $tabed.message.e  "Insufficient columns in file1."
	 		$tabed.message.e config -bg $evv(EMPH)
			close $zit
			return 0
		} else {
			lappend lines1 $nuline
			lappend col1 [lindex $nuline [expr $colpar - 1]]
		}
		incr linecnt1
	}
	close $zit
	if {$linecnt1 < 1} {
		ForceVal $tabed.message.e  "No data found in file $fnam."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	set fnam [lindex $col_files_list 1]
	if [catch {open $fnam r} zit] {
		ForceVal $tabed.message.e  "Cannot open file $fnam."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	set linecnt2 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set colcnt [llength $nuline]
		if {$colcnt < $threshold} {
			ForceVal $tabed.message.e  "Insufficient columns in file2."
	 		$tabed.message.e config -bg $evv(EMPH)
			close $zit
			return 0
		} else {
			lappend lines2 $nuline
			lappend col2 [lindex $nuline [expr $threshold - 1]]
		}
		incr linecnt2
	}
	close $zit
	if {$linecnt1 != $linecnt2} {
		ForceVal $tabed.message.e  "Files do not have the same number of rows."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	set len [llength $col1]
	set n 1
	while {$n < $len} {
		set m $n
		incr m -1
		if {[lsearch [lrange $col1 $n end] [lindex $col1 $m]] >= 0} {
			ForceVal $tabed.message.e  "Specified column contains duplicate entries: Cannot use for sort."
			$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		incr n
	}

	foreach item $col1 {
		if {[lsearch $col2 $item] < 0} {
			ForceVal $tabed.message.e  "Specified columns in the two files have different set of values."
			$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
	}
	foreach item $col2 {
		set k [lsearch $col1 $item]
		lappend outlines [lindex $lines1 $k]	
	}	
	foreach line $outlines {
		$tabed.bot.otframe.l.list insert end $line
	}
	return 1
}

proc RenameTableFiles {} {
	global tabed col_files_list wl evv
	set fnam [lindex $col_files_list 0]
	if [catch {open $fnam r} zit] {
		ForceVal $tabed.message.e  "Cannot open file $fnam."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	set linecnt1 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set colcnt [llength $nuline]
		if {$colcnt != 1} {
			ForceVal $tabed.message.e  "File $fnam is not a list of filenames."
	 		$tabed.message.e config -bg $evv(EMPH)
			close $zit
			return 0
		} else {
			lappend fnams1 $nuline
		}
		incr linecnt1
	}
	close $zit
	if {$linecnt1 < 1} {
		ForceVal $tabed.message.e  "No data found in file $fnam."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	set fnam [lindex $col_files_list 1]
	if [catch {open $fnam r} zit] {
		ForceVal $tabed.message.e  "Cannot open file $fnam."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	set linecnt2 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set colcnt [llength $nuline]
		if {$colcnt != 1} {
			ForceVal $tabed.message.e  "File $fnam is not a list of new names."
	 		$tabed.message.e config -bg $evv(EMPH)
			close $zit
			return 0
		}		
		set tail [file tail $item]
		if {![string match $tail $item]} {
			ForceVal $tabed.message.e  "You cannot use directory paths in the renaming file."
	 		$tabed.message.e config -bg $evv(EMPH)
			close $zit
			return 0
		}
		set root [file rootname $item]
		if {![ValidCDPRootname $root]} {
			close $zit
			return 0
		}
		lappend fnams2 $root
		incr linecnt2
	}
	close $zit
	if {$linecnt1 != $linecnt2} {
		ForceVal $tabed.message.e  "Files do not have the same number of rows."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	foreach origfnam $fnams1 nufnam $fnams2 {
		set direc [file dirname $origfnam]
		if {[string length $direc] <= 1} {
			set direc ""
		}
		set ext  [file extension $origfnam]
		append nufnam $ext
		set nufnam [file join $direc $nufnam]
		if {[file exists $nufnam]} {
			ForceVal $tabed.message.e  "Renamed file $nufnam already exists: cannot proceed."
			$tabed.message.e config -bg $evv(EMPH)
			return 0
		}
		lappend nufnams $nufnam
	}
	set badcnt 0
	set cnt 0
	Block "RENAMING FILES"
	foreach origfnam $fnams1 nufnam $nufnams {
		if [catch {file rename $origfnam $nufnam} zit] {
			incr badcnt
			lappend badfiles $origfnam
		} else {
			Update_Workspace_Fname $origfnam $nufnam
		}
		incr cnt
	}
	UnBlock
	if {$badcnt == $cnt} {
		ForceVal $tabed.message.e  "Failed to rename any files."
		$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	if {$badcnt > 0} {
		set msg "Failed To Rename The Following Files\n\n"
		set cnt 0
		foreach fnam $badfiles {
			if {$cnt >= 20} {
				append msg "\nAnd More"
				break
			}
			append msg $fnam "   "
			incr cnt
		}
		Inf $msg
	}
	ForceVal $tabed.message.e  "The files have been renamed."
	$tabed.message.e config -bg $evv(EMPH)
	return 1
}

#--- Update wkspace when file renamed

proc Update_Workspace_Fname {origfnam nufnam} {
	global wl ch chlist chcnt scores_refresh rememd

	set ren_blist 0
	if [HasPmark $origfnam] {
		MovePmark $fnam $nufnam
	}
	if [HasMmark $origfnam] {
		MoveMmark $fnam $nufnam
	}
	if [IsInBlists $origfnam] {
		if [RenameInBlists $origfnam $nufnam] {
			set ren_blist 1
		}
	}
	if [IsOnScore $origfnam] {
		RenameOnScore $origfnam $nufnam
	}
	set i [LstIndx $origfnam $wl]
	if {$i >= 0} {
		set oldname_pos_on_chosen [LstIndx $origfnam $ch]
		$wl delete $i								
		$wl insert $i $nufnam						;#	rename workspace item
		UpdateChosenFileMemory $origfnam $nufnam
		catch {unset rememd}
		if {$oldname_pos_on_chosen >= 0} {
			RemoveFromChosenlist $origfnam
			set chlist [linsert $chlist $oldname_pos_on_chosen $nufnam]
			incr chcnt
			$ch insert $oldname_pos_on_chosen $nufnam
		}
		RenameProps	$origfnam $nufnam 1				;#	rename props
	}
	DummyHistory $origfnam "RENAMED_$nufnam"
	RenameOnDirlist $origfnam $nufnam
	if {$ren_blist} {
		SaveBL $background_listing
	}		
	set scores_refresh 1
	catch {unset rememd}
}

#------ Transpose pitches in Varibank filter data file

proc Zcuts {issams} {
	global wl lmo col_ungapd_numeric threshold colpar tot_inlines incols tot_outlines outcolcnt tabedit_ns mu evv
	global record_temacro temacro temacrop chlist pa
	global col_tabname col_infnam tabed

	HaltCursCop
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e  "No input table to process."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$incols != 1} {
		ForceVal $tabed.message.e  "Input table must be a single column of data."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	SetInout 1

	set lmo "Zc"
	lappend lmo $col_ungapd_numeric $issams
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set tb $tabed.bot
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		set msg "Wrong number of files on workspace Chosen list."
		ForceVal $tabed.message.e  $msg
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set fnam [lindex $chlist 0]
	if {![info exists pa($fnam,$evv(FTYP))] || ($pa($fnam,$evv(FTYP)) != $evv(SNDFILE))} {
		set msg "Chosen File list, on workspace, must list (only) the soundfile you wish to edit."
		ForceVal $tabed.message.e  $msg
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach val [$ti get 0 end] {
		if {$issams} {
			if {![regexp {^[0-9]+$} $val]} {
				set msg "Invalid data in table: must be a list of integers >= 0"
				ForceVal $tabed.message.e  $msg
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
		} elseif {![IsPositiveNumber $val] && ![Flteq $val 0.0]} {
			set msg "Invalid data in table: must be a list of positive numbers >= 0.0"
			ForceVal $tabed.message.e  $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		lappend vals $val
	}
	if {$issams} {
		set vals [lsort -integer $vals]
		set modeval 3
	} else {
		set vals [lsort -real $vals]
		set modeval 1
	}
	set firstval [lindex $vals 0]
	set finalval  [lindex $vals end]
	if {$issams} {
		set maxval [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	} else {	
		set maxval $pa($fnam,$evv(DUR))
	}
	if {$finalval > $maxval} {
		set msg "Some table values are larger than the file duration ($maxval)"
		ForceVal $tabed.message.e  $msg
 		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {[llength $vals] == 1} {
		set val [lindex $vals 0]
		if {[Flteq $val 0.0] || [Flteq $val $maxval]} {
			set msg "You cannot cut up the file using this data."
			ForceVal $tabed.message.e  $msg
 			$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	set lastval 0
	set outlines {}
	if {![Flteq $firstval 0.0]} {
		set line [list sfedit zcut $modeval $fnam start 0 $firstval]
		lappend outlines $line
		set lastval $firstval
	}
	if {![Flteq $finalval $maxval]} {
		set finalline [list sfedit zcut $modeval $fnam end $finalval $maxval]
	}
	set cnt 1
	foreach val [lrange $vals 1 end] {
		if {[Flteq $lastval 0.0]} {
			set line [list sfedit zcut $modeval $fnam start $lastval $val]
		} else {
			set line [list sfedit zcut $modeval $fnam z$cnt $lastval $val]
			incr cnt
		}
		lappend outlines $line
		set lastval $val
	}
	if {[info exists finalline]} {
		lappend outlines $finalline
	} else {
		set finalline [lindex $outlines end]
		set finalline [lreplace $finalline 4 4 "end"]
		set outlines [lreplace $outlines end end $finalline]
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
	} else {
		$to delete 0 end
		set ccnt 0
		foreach line $outlines {
			$to insert end $line
			puts $fileot $line
			incr ccnt
		}
		close $fileot
		set outcolcnt 7
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines $ccnt
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		EnableOutputTableOptions 1 1
	}
}

proc TabEdParam {} {
	global col_tabname tabed_outfile evv
	if {![info exists col_tabname] || ([string length $col_tabname] <= 0)} {
		Inf "No Valid Output Table Named"
		return
	}
	if {![info exists tabed_outfile]} {
		Inf "Output Table Named Has Not Been Saved"
		return
	}
	if {![string match $col_tabname [file rootname $tabed_outfile]]} {
		Inf "Output Table Named Has Not Been Saved"
		return
	}
	ValToParam 0 pr_te
}

proc WhichItem {where from_n} {
	global tabed colpar evv
	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
	set ci $tabed.bot.icframe.l.list
	set co $tabed.bot.ocframe.l.list
	set iscol 0
	
	if {$from_n} {
		if {[string length $colpar] <= 0} {
			ForceVal $tabed.message.e  "No value entered at 'N'"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$where == "incol"} {
			set thiscol $ci
		} else {
			set thiscol $co
		}
		set isnum 0
		if {[IsNumeric $colpar]} {
			set isnum 1
		}
		set cnt 0
		foreach val [$thiscol get 0 end] {
			if {[string match $val $colpar] \
			|| ($isnum && [IsNumeric $val] && ($val == $colpar))} {
				set i $cnt
				$thiscol selection clear 0 end
				$thiscol selection set $i
				set rat [expr double($i) / double([$thiscol index end])]
				$thiscol yview moveto $rat
				ForceVal $tabed.message.e  "Value '$colpar' appears at row [expr $i  + 1]"
				return
			}
			incr cnt
		}
		ForceVal $tabed.message.e  "Value '$colpar' does not appear in this column"
		return
	}
	switch -- $where {
		"incol" {
			set item "INPUT COLUMN"
			set i [$ci curselection]
			set iscol 1
		}
		"outcol" {
			set item "OUTPUT COLUMN"
			set i [$co curselection]
			set iscol 1
		}
		"intab" {
			set item "INPUT TABLE"
			set i [$ti curselection]
		}
		"outtab" {
			set item "OUTPUT TABLE"
			set i [$to curselection]
		}
	}
	if {$i < 0} {
		ForceVal $tabed.message.e  "Either no data in $item, or no item selected."
		return
	}
	incr i
	set item [string tolower $item]
	if {$iscol} {
		ForceVal $tabed.message.e  "Selected item in $item is at position $i"
	} else {
		ForceVal $tabed.message.e  "Selected item in $item is at row $i"
	}
 	$tabed.message.e config -bg $evv(EMPH)
}

proc TEBasicOpsHelp {} {
	global pr_tebasicops evv
	set f .tebasicops
	if [Dlg_Create $f "TYPICAL BASIC OPERATION OF THE TABLE EDITOR" "set pr_tebasicops 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_tebasicops 0" -highlightbackground [option get . background {}]
		label $f.00 -text "TYPICAL BASIC OPERATIONS"
		label $f.1 -text ""
		label $f.2 -text "1) LOAD A FILE from the 'FILES' listing, the leftmost panel."
		label $f.3 -text "          Click on filename with mouse."
		label $f.4 -text "          Its contents appear in the next panel."
		label $f.5 -text ""
		label $f.6 -text "2) CHOOSE A COLUMN from the file."
		label $f.7 -text "          Type a column number under 'GET COLUMN'."
		label $f.8 -text "          Column appears in next panel. 'COLUMN', 'INPUT'."
		label $f.9 -text ""
		label $f.10 -text "3) PERFORM AN OPERATION on the column of data."
		label $f.11 -text "          Use an operation from one of the Menu Buttons."
		label $f.11x -text "          (use the 'Which ?' button to find an appropriate operation)."
		label $f.11a -text "          Enter parameter(s) for the operation at 'N' (& 'threshold')"
		label $f.11b -text "          at 'PARAMETERS' in top panel, or in parameter box which appears."
		label $f.12 -text "          Output OF OPERATION occurs in 'COLUMN', 'OUTPUT'."
		label $f.13 -text ""
		label $f.14 -text "4) PUT THE TRANSFORMED COLUMN BACK IN THE TABLE."
		label $f.15 -text "          Hit OK button at foot of 'KEEP OUPUT COLUMN' panel."
		label $f.16 -text ""
		label $f.17 -text "5) SAVE THE NEW TABLE."
		label $f.18 -text "          Enter filename at 'Enter (Generic) Name', top of rightmost panel."
		label $f.19 -text "          Press 'All' Button."
		label $f.20 -text ""
		pack $f.0  -side top
		pack $f.00 -side top
		pack $f.1 -side top -anchor w
		pack $f.2 -side top -anchor w
		pack $f.3 -side top -anchor w
		pack $f.4 -side top -anchor w
		pack $f.5 -side top -anchor w
		pack $f.6 -side top -anchor w
		pack $f.7 -side top -anchor w
		pack $f.8 -side top -anchor w
		pack $f.9 -side top -anchor w
		pack $f.10 -side top -anchor w
		pack $f.11 -side top -anchor w
		pack $f.11x -side top -anchor w
		pack $f.11a -side top -anchor w
		pack $f.11b -side top -anchor w
		pack $f.12 -side top -anchor w
		pack $f.13 -side top -anchor w
		pack $f.14 -side top -anchor w
		pack $f.15 -side top -anchor w
		pack $f.16 -side top -anchor w
		pack $f.17 -side top -anchor w
		pack $f.18 -side top -anchor w
		pack $f.19 -side top -anchor w
		pack $f.20 -side top -anchor w
		bind $f <Return> {set pr_tebasicops 0}
		bind $f <Escape> {set pr_tebasicops 0}
		bind $f <Key-space> {set pr_tebasicops 0}
	}
	wm resizable .tebasicops 1 1
	set pr_tebasicops 0
	raise $f
	My_Grab 0 $f pr_tebasicops
	tkwait variable pr_tebasicops
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TETableHelp {} {
	global pr_tedirecttab evv
	set f .tedirecttab
	if [Dlg_Create $f "WORKING DIRECTLY ON A TABLE" "set pr_tedirecttab 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_tedirecttab 0" -highlightbackground [option get . background {}]
		label $f.1 -text "WORKING DIRECTLY ON A TABLE."
		label $f.2 -text ""
		label $f.3 -text "When you display a table (in INPUT TABLE display)"
		label $f.3a -text "You don't have to extract a column from the table."
		label $f.4 -text ""
		label $f.5 -text "You can work directly on a table from 'TABLES'"
		label $f.6 -text "and 'AT CURSOR' menus in the 'ON A TABLE' panel."
		label $f.7 -text ""
		label $f.8 -text "If the table is of the appropriate type,"
		label $f.9 -text "other table operations become active."
		label $f.10 -text ""
		label $f.11 -text "If the table could be a BREAKPOINT TABLE,"
		label $f.12 -text "the 'BRK' menu becomes active."
		label $f.13 -text ""
		label $f.14 -text "If the Table could be an ENVELOPE,"
		label $f.15 -text "the 'ENVEL' menu becomes active."
		label $f.16 -text ""
		label $f.17 -text "If the Table could be a SEQUENCE,"
		label $f.18 -text "the SEQ menu becomes active."
		label $f.19 -text ""
		pack $f.0  -side top
		pack $f.1 -side top
		pack $f.2 -side top -anchor w
		pack $f.3 -side top -anchor w
		pack $f.3a -side top -anchor w
		pack $f.4 -side top -anchor w
		pack $f.5 -side top -anchor w
		pack $f.6 -side top -anchor w
		pack $f.7 -side top -anchor w
		pack $f.8 -side top -anchor w
		pack $f.9 -side top -anchor w
		pack $f.10 -side top -anchor w
		pack $f.11 -side top -anchor w
		pack $f.12 -side top -anchor w
		pack $f.13 -side top -anchor w
		pack $f.14 -side top -anchor w
		pack $f.15 -side top -anchor w
		pack $f.16 -side top -anchor w
		pack $f.17 -side top -anchor w
		pack $f.18 -side top -anchor w
		pack $f.19 -side top -anchor w
		bind $f <Return> {set pr_tedirecttab 0}
		bind $f <Escape> {set pr_tedirecttab 0}
		bind $f <Key-space> {set pr_tedirecttab 0}
	}
	wm resizable .tedirecttab 1 1
	set pr_tedirecttab 0
	raise $f
	My_Grab 0 $f pr_tedirecttab
	tkwait variable pr_tedirecttab
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TEManyFilesHelp {} {
	global pr_temanyfiles evv
	set f .temanyfiles
	if [Dlg_Create $f "WORKING WITH MORE THAN ONE FILE" "set pr_temanyfiles 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_temanyfiles 0" -highlightbackground [option get . background {}]
		label $f.1 -text "WORKING WITH MORE THAN ONE FILE"
		label $f.2 -text ""
		label $f.2a -text "You can combine data in 2 (or more) tables, directly."
		label $f.2b -text ""
		label $f.3 -text "1) Select MODE, Many Files. At top of display."
		label $f.4 -text ""
		label $f.5 -text "2) When you now Select files from the left panel,"
		label $f.6 -text "    their names appear in the OUTPUT TABLE panel."
		label $f.7 -text ""
		label $f.8 -text "3) The Button JOIN will be activated."
		label $f.9 -text "    This menu has operations to combine data"
		label $f.10 -text "    in 2 or more tables."
		label $f.11 -text ""

		pack $f.0  -side top
		pack $f.1 -side top
		pack $f.2 -side top -anchor w
		pack $f.2a -side top -anchor w
		pack $f.2b -side top -anchor w
		pack $f.3 -side top -anchor w
		pack $f.4 -side top -anchor w
		pack $f.5 -side top -anchor w
		pack $f.6 -side top -anchor w
		pack $f.7 -side top -anchor w
		pack $f.8 -side top -anchor w
		pack $f.9 -side top -anchor w
		pack $f.10 -side top -anchor w
		pack $f.11 -side top -anchor w
		bind $f <Return> {set pr_temanyfiles 0}
		bind $f <Escape> {set pr_temanyfiles 0}
		bind $f <Key-space> {set pr_temanyfiles 0}
	}
	wm resizable .temanyfiles 1 1
	set pr_temanyfiles 0
	raise $f
	My_Grab 0 $f pr_temanyfiles
	tkwait variable pr_temanyfiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TECreateHelp {} {
	global pr_tescratch evv
	set f .tescratch
	if [Dlg_Create $f "CREATING DATA FROM SCRATCH" "set pr_tescratch 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_tescratch 0" -highlightbackground [option get . background {}]
		label $f.1 -text "CREATING DATA FROM SCRATCH"
		label $f.2 -text ""
		label $f.3 -text "Use the 'CREATE' OR 'CREATE2' menus,"
		label $f.4 -text "or the CREATE option on the 'TABLES' menu"
		label $f.5 -text ""
		pack $f.0  -side top
		pack $f.1 -side top
		pack $f.2 -side top -anchor w
		pack $f.3 -side top -anchor w
		pack $f.4 -side top -anchor w
		pack $f.5 -side top -anchor w
		bind $f <Return> {set pr_tescratch 0}
		bind $f <Escape> {set pr_tescratch 0}
		bind $f <Key-space> {set pr_tescratch 0}
	}
	wm resizable .tescratch 1 1
	set pr_tescratch 0
	raise $f
	My_Grab 0 $f pr_tescratch
	tkwait variable pr_tescratch
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TESndfileDataHelp {} {
	global pr_tesnddata evv
	set f .tesnddata
	if [Dlg_Create $f "WORKING WITH SOUNDFILE DATA" "set pr_tesnddata 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_tesnddata 0" -highlightbackground [option get . background {}]
		label $f.1 -text "YOU CAN WORK WITH SOUNDFILES CHOSEN ON WORKSPACE"
		label $f.2 -text "or from Soundfiles listed in the INPUT COLUMN"
		label $f.3 -text ""
		label $f.4 -text "Use the 'FROM SNDS' menu."
		label $f.5 -text ""
		label $f.6 -text "You can list, and work with ..."
		label $f.7 -text "soundfile NAMES"
		label $f.8 -text "soundfile DURATIONS."
		label $f.9 -text "soundfile AMPLITUDES."
		label $f.10 -text ""
		label $f.11 -text "YOU CAN ALSO WORK WITH PROPERTIES OR NAMES"
		label $f.12 -text "OF MIXFILES, or OTHER FILES"
		label $f.13 -text "from this same menu."
		label $f.14 -text ""
		pack $f.0  -side top
		pack $f.1 -side top
		pack $f.2 -side top
		pack $f.3 -side top -anchor w
		pack $f.4 -side top -anchor w
		pack $f.5 -side top -anchor w
		pack $f.6 -side top -anchor w
		pack $f.7 -side top -anchor w
		pack $f.8 -side top -anchor w
		pack $f.9 -side top -anchor w
		pack $f.10 -side top -anchor w
		pack $f.11 -side top
		pack $f.12 -side top
		pack $f.13 -side top
		pack $f.14 -side top
		bind $f <Return> {set pr_tesnddata 0}
		bind $f <Escape> {set pr_tesnddata 0}
		bind $f <Key-space> {set pr_tesnddata 0}
	}
	wm resizable .tesnddata 1 1
	set pr_tesnddata 0
	raise $f
	My_Grab 0 $f pr_tesnddata
	tkwait variable pr_tesnddata
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TEProblemsHelp {} {
	global pr_teproblems evv
	set f .teproblems
	if [Dlg_Create $f "TYPICAL TABLE EDITOR PROBLEMS" "set pr_teproblems 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_teproblems 0" -highlightbackground [option get . background {}]
		label $f.1 -text "TYPICAL PROBLEMS"
		label $f.2 -text ""
		label $f.3 -text "A) THERE ARE NO FILES LISTED in the 'FILES' listing."
		label $f.5 -text "          This is because you have no  TEXTfiles on the Workspace."
		label $f.7 -text "          You can still use the 'CREATE' menus"
		label $f.8 -text "          to generate data from scratch."
		label $f.9 -text ""
		label $f.10 -text "B) I CANNOT EXTRACT COLUMN N from the input file."
		label $f.12 -text "          The input table probably does not have an entry for column N"
		label $f.13 -text "          ON EVERY LINE."
		label $f.15 -text "          See 'TYPES OF FILES' and 'WORKING DIRECTLY ON A TABLE'."
		label $f.16 -text ""
		label $f.17 -text "C) I CANNOT PUT THE OUTPUT COLUMN INTO THE INPUT TABLE."
		label $f.19 -text "          The output column probably has the wrong number of entries."
		label $f.21 -text "           See 'ALTERNATIVE OPERATIONS ON THE OUPUT COLUMN'."
		label $f.22 -text ""
		label $f.23 -text "D) I CANNOT DECIDE WHICH PROCESS TO USE."
		label $f.25 -text "           See the 'Which?' menu."
		label $f.26 -text ""
		label $f.27 -text "E) I CANNOT FIND THE PROCESS I WANT TO USE."
		label $f.29 -text "           See the 'Which?' menu."
		label $f.30 -text ""
		pack $f.0  -side top
		pack $f.1 -side top
		pack $f.2 -side top -anchor w
		pack $f.3 -side top -anchor w
		pack $f.5 -side top -anchor w
		pack $f.7 -side top -anchor w
		pack $f.8 -side top -anchor w
		pack $f.9 -side top -anchor w
		pack $f.10 -side top -anchor w
		pack $f.12 -side top -anchor w
		pack $f.13 -side top -anchor w
		pack $f.15 -side top -anchor w
		pack $f.16 -side top -anchor w
		pack $f.17 -side top -anchor w
		pack $f.19 -side top -anchor w
		pack $f.21 -side top -anchor w
		pack $f.22 -side top -anchor w
		pack $f.23 -side top -anchor w
		pack $f.25 -side top -anchor w
		pack $f.26 -side top -anchor w
		pack $f.27 -side top -anchor w
		pack $f.29 -side top -anchor w
		pack $f.30 -side top -anchor w
		bind $f <Return> {set pr_teproblems 0}
		bind $f <Escape> {set pr_teproblems 0}
		bind $f <Key-space> {set pr_teproblems 0}
	}
	wm resizable .teproblems 1 1
	set pr_teproblems 0
	raise $f
	My_Grab 0 $f pr_teproblems
	tkwait variable pr_teproblems
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TEFileTypesHelp {} {
	global pr_tefiletypes evv
	set f .tefiletypes
	if [Dlg_Create $f "TYPES OF FILE WHICH CAN BE USED" "set pr_tefiletypes 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_tefiletypes 0" -highlightbackground [option get . background {}]
		label $f.1 -text "TYPES OF FILE WHICH CAN BE USED"
		label $f.2 -text ""
		label $f.3 -text "1) DIFFERENT CATEGORIES OF TEXTFILES"
		label $f.4 -text "    can be listed in the 'FILES' panel on the left."
		label $f.5 -text ""
		label $f.6 -text "    Use the dot-buttons above the left panel."
		label $f.7 -text ""
		label $f.8 -text "2) IF FILES DON'T SIMPLY CONTAIN COLUMNS OF VALUES"
		label $f.9 -text "    (e.g. they contain comment lines,"
		label $f.10 -text "    or they have lines of different lengths)"
		label $f.11 -text ""
		label $f.12 -text "    use 'FREE TEXT' mode (in the top Panel),"
		label $f.13 -text "    to ensure these are listed."
		label $f.14 -text ""
		label $f.15 -text "    You can then use"
		label $f.16 -text "    'SKIPPING' 'Title Lines' or 'Comments'"
		label $f.17 -text "    when selecting a column,"
		label $f.18 -text "    to skip over data you don't want to process."
		label $f.19 -text ""
		label $f.20 -text "    The Table Editor remembers to reinsert these"
		label $f.21 -text "    into the Output Table."
		label $f.22 -text ""
		pack $f.0  -side top
		pack $f.1 -side top
		pack $f.2 -side top -anchor w
		pack $f.3 -side top -anchor w
		pack $f.4 -side top -anchor w
		pack $f.5 -side top -anchor w
		pack $f.6 -side top -anchor w
		pack $f.7 -side top -anchor w
		pack $f.8 -side top -anchor w
		pack $f.9 -side top -anchor w
		pack $f.10 -side top -anchor w
		pack $f.11 -side top -anchor w
		pack $f.12 -side top -anchor w
		pack $f.13 -side top -anchor w
		pack $f.14 -side top -anchor w
		pack $f.15 -side top -anchor w
		pack $f.16 -side top -anchor w
		pack $f.17 -side top -anchor w
		pack $f.18 -side top -anchor w
		pack $f.19 -side top -anchor w
		pack $f.20 -side top -anchor w
		pack $f.21 -side top -anchor w
		pack $f.22 -side top -anchor w
		bind $f <Return> {set pr_tefiletypes 0}
		bind $f <Escape> {set pr_tefiletypes 0}
		bind $f <Key-space> {set pr_tefiletypes 0}
	}
	wm resizable .tefiletypes 1 1
	set pr_tefiletypes 0
	raise $f
	My_Grab 0 $f pr_tefiletypes
	tkwait variable pr_tefiletypes
	My_Release_to_Dialog $f
	destroy $f
}


proc TEOutColOptionsHelp {} {
	global pr_tecolops evv
	set f .tecolops
	if [Dlg_Create $f "ALTERNATIVE OPERATIONS ON THE OUPUT COLUMN" "set pr_tecolops 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_tecolops 0" -highlightbackground [option get . background {}]
		label $f.1 -text "ALTERNATIVE OPERATIONS ON THE OUPUT COLUMN"
		label $f.2 -text ""
		label $f.3 -text "1) KEEP THE COLUMN BY ITSELF."
		label $f.4 -text "    Select 'Keep by itself' in the COLUMN, OUTPUT panel."
		label $f.5 -text ""
		label $f.6 -text "2) INSERT COLUMN into the OUTPUT TABLE, as a new column."
		label $f.7 -text "   (Instead of into the Input Column)"
		label $f.8 -text "    You can only do this if..."
		label $f.9 -text "    a) an output TABLE exists"
		label $f.10 -text "    b) output column has the same number of entries"
		label $f.11 -text "          as columns in the output table."
		label $f.12 -text ""
		label $f.13 -text "    Select 'in Output Column', then 'Insert as Col'."
		label $f.14 -text ""
		label $f.15 -text "3) REPLACE an existing column in the OUTPUT table."
		label $f.16 -text "    You can only do this if output column has same"
		label $f.17 -text "    number of entries as the columns in output table."
		label $f.18 -text ""
		label $f.19 -text "    Select 'in Output Column', then 'Replace as Col'."
		label $f.20 -text ""
		label $f.21 -text "4) IF YOU CHANGE NUMBER OF ENTRIES IN COLUMN YOU'RE PROCESSING"
		label $f.22 -text "    it can no longer be placed back into original table."
		label $f.23 -text "    But you can still keep the Column BY ITSELF: OR"
		label $f.24 -text "    Insert or Replace it in OUTPUT table (if that exists),"
		label $f.25 -text "    provided the column has same number of entries as"
		label $f.26 -text "    the columns in the output table. "
		label $f.27 -text ""
		pack $f.0  -side top
		pack $f.1 -side top
		pack $f.2 -side top -anchor w
		pack $f.3 -side top -anchor w
		pack $f.4 -side top -anchor w
		pack $f.5 -side top -anchor w
		pack $f.6 -side top -anchor w
		pack $f.7 -side top -anchor w
		pack $f.8 -side top -anchor w
		pack $f.9 -side top -anchor w
		pack $f.10 -side top -anchor w
		pack $f.11 -side top -anchor w
		pack $f.12 -side top -anchor w
		pack $f.13 -side top -anchor w
		pack $f.14 -side top -anchor w
		pack $f.15 -side top -anchor w
		pack $f.16 -side top -anchor w
		pack $f.17 -side top -anchor w
		pack $f.18 -side top -anchor w
		pack $f.19 -side top -anchor w
		pack $f.20 -side top -anchor w
		pack $f.21 -side top -anchor w
		pack $f.22 -side top -anchor w
		pack $f.23 -side top -anchor w
		pack $f.24 -side top -anchor w
		pack $f.25 -side top -anchor w
		pack $f.26 -side top -anchor w
		pack $f.27 -side top -anchor w
		bind $f <Return> {set pr_tecolops 0}
		bind $f <Escape> {set pr_tecolops 0}
		bind $f <Key-space> {set pr_tecolops 0}
	}
	wm resizable .tecolops 1 1
	set pr_tecolops 0
	raise $f
	My_Grab 0 $f pr_tecolops
	tkwait variable pr_tecolops
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TEOutOptionsHelp {} {
	global pr_teoutops evv
	set f .teoutops 
	if [Dlg_Create $f "ALTERNATIVE OPERATIONS ON THE OUPUT COLUMN" "set pr_teoutops 1" -borderwidth $evv(BBDR)] {
		button $f.0 -text "Close" -command "set pr_teoutops 0" -highlightbackground [option get . background {}]
		label $f.1 -text "ALTERNATIVE WAYS TO SAVE THE OUTPUT TABLE"
		label $f.2 -text ""
		label $f.3 -text "1) SAVE INDIVIDUAL COLUMNS or ROWS of the output"
		label $f.4 -text "    as separate files."
		label $f.6 -text "    Use the 'Cols' or 'Rows' buttons."
		label $f.7 -text ""
		label $f.8 -text "2) SAVE Ouptut Table AS A BATCHFILE"
		label $f.9 -text "    (a batchfile is a list of CDP command lines"
		label $f.10 -text "    to execute as a group)."
		label $f.11 -text "   Only appropriate if output table IS a Batch File!!"
		label $f.13 -text "   Use the 'Batch' button."
		label $f.14 -text ""
		label $f.15 -text "3) SAVE IN THE REFERENCES STORE the Output Table name "
		label $f.16 -text "   (or the message in the 'Messages' Panel')."
		label $f.18 -text "    Use the buttons 'Outfile->Ref'"
		label $f.19 -text "    or 'Message->Ref'"
		label $f.20 -text ""
		label $f.21 -text "4) USE Output Table AS PARAMETER TO A PROCESS"
		label $f.23 -text "    You can ONLY do this..."
		label $f.24 -text "    a) If you called the Table Editor"
		label $f.25 -text "            from the PARAMETERS PAGE OF A PROCESS."
		label $f.26 -text "    b) AFTER you've SAVED the Output Table to use."
		label $f.28 -text "    Use the 'Outfile->Param' button."
		label $f.29 -text ""
		pack $f.0  -side top
		pack $f.1 -side top
		pack $f.2 -side top -anchor w
		pack $f.3 -side top -anchor w
		pack $f.4 -side top -anchor w
		pack $f.6 -side top -anchor w
		pack $f.7 -side top -anchor w
		pack $f.8 -side top -anchor w
		pack $f.9 -side top -anchor w
		pack $f.10 -side top -anchor w
		pack $f.11 -side top -anchor w
		pack $f.13 -side top -anchor w
		pack $f.14 -side top -anchor w
		pack $f.15 -side top -anchor w
		pack $f.16 -side top -anchor w
		pack $f.18 -side top -anchor w
		pack $f.19 -side top -anchor w
		pack $f.20 -side top -anchor w
		pack $f.21 -side top -anchor w
		pack $f.23 -side top -anchor w
		pack $f.24 -side top -anchor w
		pack $f.25 -side top -anchor w
		pack $f.26 -side top -anchor w
		pack $f.28 -side top -anchor w
		pack $f.29 -side top -anchor w
		bind $f <Return> {set pr_teoutops 0}
		bind $f <Escape> {set pr_teoutops 0}
		bind $f <Key-space> {set pr_teoutops 0}
	}
	wm resizable .teoutops 1 1
	set pr_teoutops 0
	raise $f
	My_Grab 0 $f pr_teoutops
	tkwait variable pr_teoutops
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc BalanceConvert {it ot} {
	set returnval 0
	foreach line [$it get 0 end] {
		catch {unset nuline}
		string trim $line
		set line [split $line]
		foreach val $line {
			string trim $val
			if {[string length $val] > 0} {
				lappend nuline $val
			}
		}
		set nuval [expr 1.0 - [lindex $nuline 1]]
		lappend nuline $nuval
		$ot insert end $nuline
		set returnval 1
	}
	return $returnval
}


proc Sequence_Reversal {} {
	global pr_seqrev seqrevtim seqrevpch seqrevacc seqrevblank evv
	set f .seqrev
	if [Dlg_Create $f "SEQUENCE PATTERN REVERSALS" "set pr_seqrev 0" -borderwidth 2] {
		frame $f.0 -borderwidth $evv(SBDR)
		frame $f.1 -borderwidth $evv(SBDR)
		button $f.0.ok -text "Do Reversal" -command "set pr_seqrev 1" -highlightbackground [option get . background {}]
		label $f.0.dum -text "" -width 36
		pack $f.0.ok $f.0.dum -side left
		button $f.0.quit -text "Close" -command "set pr_seqrev 0" -highlightbackground [option get . background {}]
		pack $f.0.quit -side right
		checkbutton $f.1.t -variable seqrevtim -text Time   -command {.seqrev.0.dum config -text "" -bg [option get . background {}]}
		checkbutton $f.1.p -variable seqrevpch -text Pitch  -command {.seqrev.0.dum config -text "" -bg [option get . background {}]}
		checkbutton $f.1.a -variable seqrevacc -text Accent -command {.seqrev.0.dum config -text "" -bg [option get . background {}]}
		set seqrevtim 0
		set seqrevpch 0
		set seqrevacc 0
		pack $f.1.t $f.1.p $f.1.a -side left
		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top -padx 12
		bind $f <Return> {set pr_seqrev 1}
		bind $f <Escape> {set pr_seqrev 0}
	}
	wm resizable $f 1 1
	set pr_seqrev 0
	set finished 0
	My_Grab 1 $f pr_seqrev
	while {!$finished} {
		raise $f
		tkwait variable pr_seqrev
		if {$pr_seqrev} {
			if {$seqrevtim} {
				if {$seqrevpch} {
					if {$seqrevacc} {
						TabMod "WZ"		;#	Time, Pitch, Accent
					} else {
						TabMod "WT"		;#	Time, Pitch
					}
				} elseif {$seqrevacc} {
					TabMod "Wa"			;#	Time, Accent		
				} else {
					TabMod "Wr"			;#	Time		
				}
			} elseif {$seqrevpch} {
				if {$seqrevacc} {
					TabMod "WR"			;#	Pitch, Accent
				} else {
					TabMod "WP"			;#	Pitch
				}
			} elseif {$seqrevacc} {
				TabMod "WA"				;#	Accent
			} else {
				$f.0.dum config -text "NO REVERSAL(S) SPECIFIED" -bg $evv(EMPH)
				continue
			}
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Display on Staff Notation, pitches in cursor-selected row of varibank filter data

proc VbankRow {ismidi} {
	global outcolcnt tot_outlines colpar threshold tot_inlines incols tabedit_ns tabedit_bind2 lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop mu
	global col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set tb $tabed.bot
	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "Vb"
	lappend lmo $col_ungapd_numeric $ismidi
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <= 0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set i [$tb.itframe.l.list curselection]
	if {![info exists i] || ($i < 0)} {
		ForceVal $tabed.message.e "No item selected with cursor."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set cnt 0
	foreach item [$tb.itframe.l.list get $i] {
		if {![IsEven $cnt]} {
			lappend vals $item
		}
		incr cnt
	}
	if {($cnt < 3) || [IsEven $cnt]} {
		ForceVal $tabed.message.e "Not a valid line for varibank filter data."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set cnt 0
	set minfrq [MidiToHz 0.0]
	set maxfrq [MidiToHz $mu(MIDIMAX)]
	foreach val $vals {
		incr cnt 2
		if {$ismidi} {
			if {($val < 0.0) || ($val > $mu(MIDIMAX))} {
				ForceVal $tabed.message.e "Item $cnt is out of range for a MIDI value."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set val [expr int(round($val))]	
			lappend nuvals $val
		} else {
			if {($val < $minfrq) || ($val > $maxfrq)} {
				ForceVal $tabed.message.e "Item $cnt is out of range for a frequency value."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set val [expr int(round([HzToMidi $val]))]
			lappend nuvals $val
		}
	}
	set vals [RemoveDuplicatesInList $vals]
	set vals [lsort -integer -decreasing $nuvals]
	DoVbankPitchDisplay $vals
}

proc DoVbankPitchDisplay {midilist} {
	global pr_vbp vbankgrafix evv

	set f .vbank_pitches
	if [Dlg_Create $f "PITCH DISPLAY" "set pr_vbp 0" -width 120 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		button $b.lab -text "OK" -command "set pr_vbp 0" -highlightbackground [option get . background {}]
		pack $b.lab -side top
		set vbankgrafix [EstablishPmarkDisplay $d]
		pack $vbankgrafix -side top
		pack $b $d -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_vbp 0}
		bind $f <Escape> {set pr_vbp 0}
		bind $f <Key-space> {set pr_vbp 0}
	}
	ClearPitchGrafix $vbankgrafix
	InsertPitchGrafix $midilist $vbankgrafix
	raise $f
	set pr_vbp 0
	My_Grab 0 $f pr_vbp $f.b.lab
	tkwait variable pr_vbp
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Draw note on varibank-filter-data graphics display

proc InsertPitchGrafix {midilist which} {
	global vbankgrafix pbankgrafix maxpcol evv shortwindows

	set maxpcol -1
	set thisdisplay $which

	if {[llength $midilist] <= 0} {
		return
	}
	set informed 0
	set informed2 0
	set n 0
	set midilist [lsort -real -decreasing $midilist]
	foreach midival $midilist {
		if {$midival > $evv(MAX_TONAL)} {
			if {!$informed} {
				set informed 1
				Inf "Cannot Graphically Represent Midi Vals Above $evv(MAX_TONAL)" 
			}
			continue
		} elseif {$midival < $evv(MIN_TONAL)} {
			if {!$informed2} {
				set informed2 1
				Inf "Cannot Graphically Represent MIDI Vals Below $evv(MIN_TONAL)" 
			}
			break
		}
		set col [GetXpos $midival]	;#	Find position of notes (allowing for other notes on staff)
		switch -- $col {
			0 { set xpos1 128 }
			1 { set xpos1 156 }
			2 { set xpos1 184 }
			3 { set xpos1 212 }
			default {
				Inf "Error in display : Unknown column position"
			}
		}
		set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
		set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
		set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
								;#	draw note heads
#
# NB: MAC "b"-flat-signs y-position are 2 > PC "b" flat positions
#
		if {[info exists shortwindows]} {
			switch -- $midival {	

				108	{
						set noteC4  [$thisdisplay create oval $xpos1 17 $xpos2 23 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger0}
						catch {$thisdisplay delete ledger1}
						$thisdisplay create line $xpos1leg 20 $xpos2leg 20 -tag {ledger0 ledger} -fill $evv(POINT)
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1 ledger} -fill $evv(POINT)
				}
				107	{
						set noteB3  [$thisdisplay create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger1a}
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1a ledger} -fill $evv(POINT)
				}
				106	{
						$thisdisplay create text [expr $xpos1 - 7] 31 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb3 [$thisdisplay create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger1c}
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1c ledger} -fill $evv(POINT)
				}
				105	{
						set noteA3  [$thisdisplay create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger1d}
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1d ledger} -fill $evv(POINT)
				}
				104	{
						$thisdisplay create text [expr $xpos1 - 7] 36 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb3 [$thisdisplay create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger1e}
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1e ledger} -fill $evv(POINT)
				}
				103	{
						set noteG3  [$thisdisplay create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				102	{
						$thisdisplay create text [expr $xpos1 - 7] 41 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb3 [$thisdisplay create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				}
				101	{
						set noteF3  [$thisdisplay create oval $xpos1 37 $xpos2 43 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				100	{
						set noteE3  [$thisdisplay create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				99	{
						$thisdisplay create text [expr $xpos1 - 7] 51 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb3 [$thisdisplay create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				98	{
						set noteD3  [$thisdisplay create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				97	{
						$thisdisplay create text [expr $xpos1 - 7] 56 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb3 [$thisdisplay create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				96	{
						set noteC3  [$thisdisplay create oval $xpos1 52 $xpos2 58 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				95	{
						set noteB2  [$thisdisplay create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				94	{
						$thisdisplay create text [expr $xpos1 - 7] 66 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb2 [$thisdisplay create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				93	{
						set noteA2  [$thisdisplay create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				92	{
						$thisdisplay create text [expr $xpos1 - 7] 71 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb2 [$thisdisplay create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				}
				91	{
						set noteG2  [$thisdisplay create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				90	{
						$thisdisplay create text [expr $xpos1 - 7] 76 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb2 [$thisdisplay create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				89	{
						set noteF2  [$thisdisplay create oval $xpos1 72 $xpos2 78 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				88	{
						set noteE2  [$thisdisplay create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				87	{	
						$thisdisplay create text [expr $xpos1 - 7] 86 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb2 [$thisdisplay create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				86	{
						set noteD2  [$thisdisplay create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				85	{	
						$thisdisplay create text [expr $xpos1 - 7] 91 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb2 [$thisdisplay create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				}
				84	{
						set noteC2  [$thisdisplay create oval $xpos1 87 $xpos2 93 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger1z}
						$thisdisplay create line $xpos1leg 90 $xpos2leg 90 -tag {ledger1z ledger} -fill $evv(POINT)
				}
				83	{
						set noteB1  [$thisdisplay create oval $xpos1 142 $xpos2 148 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger3}
						$thisdisplay create line $xpos1leg 150 $xpos2leg 150 -tag {ledger3 ledger} -fill $evv(POINT)
				}
				82	{	
						$thisdisplay create text [expr $xpos1 - 7] 151 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb1 [$thisdisplay create oval $xpos1 142 $xpos2 148 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger3a}
						$thisdisplay create line $xpos1leg 150 $xpos2leg 150 -tag {ledger3a ledger} -fill $evv(POINT)
				}
				81	{	
						set noteA1  [$thisdisplay create oval $xpos1 147 $xpos2 153 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger3b}
						$thisdisplay create line $xpos1leg 150 $xpos2leg 150 -tag {ledger3b ledger} -fill $evv(POINT)
				}
				80	{	
						$thisdisplay create text [expr $xpos1 - 7] 156 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb1 [$thisdisplay create oval $xpos1 147 $xpos2 153 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger3c}
						$thisdisplay create line $xpos1leg 150 $xpos2leg 150 -tag {ledger3c ledger} -fill $evv(POINT)
					}
				79	{
						set noteG1  [$thisdisplay create oval $xpos1 152 $xpos2 158 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				78	{	
						$thisdisplay create text [expr $xpos1 - 7] 161 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb1 [$thisdisplay create oval $xpos1 152 $xpos2 158 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				77	{
						set noteF1  [$thisdisplay create oval $xpos1 157 $xpos2 163 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				76	{
						set noteE1  [$thisdisplay create oval $xpos1 162 $xpos2 168 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				75	{	
						$thisdisplay create text [expr $xpos1 - 7] 171 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb1 [$thisdisplay create oval $xpos1 162 $xpos2 168 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				74	{
						set noteD1  [$thisdisplay create oval $xpos1 167 $xpos2 173 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				73	{	
						$thisdisplay create text [expr $xpos1 - 7] 176 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb1 [$thisdisplay create oval $xpos1 167 $xpos2 173 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				72	{
						set noteC1  [$thisdisplay create oval $xpos1 172 $xpos2 178 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				71	{
						set noteB0  [$thisdisplay create oval $xpos1 177 $xpos2 183 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				70	{	
						$thisdisplay create text [expr $xpos1 - 7] 186 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb0 [$thisdisplay create oval $xpos1 177 $xpos2 183 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				69	{
						set noteA0  [$thisdisplay create oval $xpos1 182 $xpos2 188 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				68	{	
						$thisdisplay create text [expr $xpos1 - 7] 191 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb0 [$thisdisplay create oval $xpos1 182 $xpos2 188 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				67	{
						set noteG0  [$thisdisplay create oval $xpos1 187 $xpos2 193 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				66	{	
						$thisdisplay create text [expr $xpos1 - 7] 196 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb0 [$thisdisplay create oval $xpos1 187 $xpos2 193 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				65	{
						set noteF0  [$thisdisplay create oval $xpos1 192 $xpos2 198 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				64	{
						set noteE0  [$thisdisplay create oval $xpos1 197 $xpos2 203 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				63	{	
						$thisdisplay create text [expr $xpos1 - 7] 206 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb0 [$thisdisplay create oval $xpos1 197 $xpos2 203 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				62	{
						set noteD0  [$thisdisplay create oval $xpos1 202 $xpos2 208 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				61	{	
						$thisdisplay create text [expr $xpos1 - 7] 211 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb0 [$thisdisplay create oval $xpos1 202 $xpos2 208 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				}
				60	{
						set noteC0  [$thisdisplay create oval $xpos1 207 $xpos2 213 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger3d}
						$thisdisplay create line $xpos1leg 210 $xpos2leg 210 -tag {ledger3d ledger} -fill $evv(POINT)
				}
				59	{
						set noteB-1  [$thisdisplay create oval $xpos1 212 $xpos2 218 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				58	{	
						$thisdisplay create text [expr $xpos1 - 7] 221 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-1 [$thisdisplay create oval $xpos1 212 $xpos2 218 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				57	{
						set noteA-1  [$thisdisplay create oval $xpos1 217 $xpos2 223 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				56	{	
						$thisdisplay create text [expr $xpos1 - 7] 226 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-1 [$thisdisplay create oval $xpos1 217 $xpos2 223 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				55	{
						set noteG-1  [$thisdisplay create oval $xpos1 222 $xpos2 228 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				54	{	
						$thisdisplay create text [expr $xpos1 - 7] 231 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-1 [$thisdisplay create oval $xpos1 222 $xpos2 228 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				53	{
						set noteF-1  [$thisdisplay create oval $xpos1 227 $xpos2 233 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				52	{
						set noteE-1  [$thisdisplay create oval $xpos1 232 $xpos2 238 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				51	{	
						$thisdisplay create text [expr $xpos1 - 7] 241 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-1 [$thisdisplay create oval $xpos1 232 $xpos2 238 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				50	{
						set noteD-1  [$thisdisplay create oval $xpos1 237 $xpos2 243 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				49	{	
						$thisdisplay create text [expr $xpos1 - 7] 246 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-1 [$thisdisplay create oval $xpos1 237 $xpos2 243 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				48	{
						set noteC-1  [$thisdisplay create oval $xpos1 242 $xpos2 248 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				47	{
						set noteB-2  [$thisdisplay create oval $xpos1 247 $xpos2 253 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				46	{	
						$thisdisplay create text [expr $xpos1 - 7] 256 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-2 [$thisdisplay create oval $xpos1 247 $xpos2 253 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				45	{
						set noteA-2  [$thisdisplay create oval $xpos1 252 $xpos2 258 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				44	{	
						$thisdisplay create text [expr $xpos1 - 7] 261 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-2 [$thisdisplay create oval $xpos1 252 $xpos2 258 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				43	{
						set noteG-2  [$thisdisplay create oval $xpos1 257 $xpos2 263 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				42	{	
						$thisdisplay create text [expr $xpos1 - 7] 268 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-2 [$thisdisplay create oval $xpos1 257 $xpos2 263 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				41	{
						set noteF-2  [$thisdisplay create oval $xpos1 262 $xpos2 268 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				40	{
						set noteE-2  [$thisdisplay create oval $xpos1 267 $xpos2 273 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger4}
						$thisdisplay create line $xpos1leg 270 $xpos2leg 270 -tag {ledger4 ledger} -fill $evv(POINT)
				}
				39	{	
						$thisdisplay create text [expr $xpos1 - 7] 276 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-2 [$thisdisplay create oval $xpos1 267 $xpos2 273 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger4a}
						$thisdisplay create line $xpos1leg 270 $xpos2leg 270 -tag {ledger4a ledger} -fill $evv(POINT)
					}
				38	{	
						set noteD-2  [$thisdisplay create oval $xpos1 272 $xpos2 278 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger4b}
						$thisdisplay create line $xpos1leg 270 $xpos2leg 270 -tag {ledger4b ledger} -fill $evv(POINT)
				}
				37	{	
						$thisdisplay create text [expr $xpos1 - 7] 281 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-2 [$thisdisplay create oval $xpos1 272 $xpos2 278 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger4c}
						$thisdisplay create line $xpos1leg 270 $xpos2leg 270 -tag {ledger4c ledger} -fill $evv(POINT)
					}
				36	{	
						set noteC-2  [$thisdisplay create oval $xpos1 277 $xpos2 283 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger4d}
						catch {$thisdisplay delete ledger5}
						$thisdisplay create line $xpos1leg 270 $xpos2leg 270 -tag {ledger4d ledger} -fill $evv(POINT)
						$thisdisplay create line $xpos1leg 280 $xpos2leg 280 -tag {ledger5 ledger} -fill $evv(POINT)
				}
				35	{
						set noteB-3  [$thisdisplay create oval $xpos1 332 $xpos2 338 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				}
				34	{	
						$thisdisplay create text [expr $xpos1 - 7] 341 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-3 [$thisdisplay create oval $xpos1 332 $xpos2 338 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				33	{	
						set noteA-3  [$thisdisplay create oval $xpos1 337 $xpos2 343 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				}
				32	{	
						$thisdisplay create text [expr $xpos1 - 7] 346 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-3 [$thisdisplay create oval $xpos1 337 $xpos2 343 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				31	{
						set noteG-3  [$thisdisplay create oval $xpos1 342 $xpos2 348 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				30	{	
						$thisdisplay create text [expr $xpos1 - 7] 351 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-3 [$thisdisplay create oval $xpos1 342 $xpos2 348 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				29	{
						set noteF-3  [$thisdisplay create oval $xpos1 347 $xpos2 353 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				28	{
						set noteE-3  [$thisdisplay create oval $xpos1 352 $xpos2 358 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				27	{	
						$thisdisplay create text [expr $xpos1 - 7] 361 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-3 [$thisdisplay create oval $xpos1 352 $xpos2 358 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				26	{
						set noteD-3  [$thisdisplay create oval $xpos1 357 $xpos2 363 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				25	{	
						$thisdisplay create text [expr $xpos1 - 7] 366 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-3 [$thisdisplay create oval $xpos1 357 $xpos2 363 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				24	{
						set noteC-3  [$thisdisplay create oval $xpos1 362 $xpos2 368 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				23	{
						set noteB-4  [$thisdisplay create oval $xpos1 367 $xpos2 373 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				22	{	
						$thisdisplay create text [expr $xpos1 - 7] 376 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-4 [$thisdisplay create oval $xpos1 367 $xpos2 373 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				21	{
						set noteA-4  [$thisdisplay create oval $xpos1 372 $xpos2 378 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				20	{	
						$thisdisplay create text [expr $xpos1 - 7] 381 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-4 [$thisdisplay create oval $xpos1 372 $xpos2 378 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				19	{
						set noteG-4  [$thisdisplay create oval $xpos1 377 $xpos2 383 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				18	{	
						$thisdisplay create text [expr $xpos1 - 7] 386 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-4 [$thisdisplay create oval $xpos1 377 $xpos2 383 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				17	{
						set noteF-4  [$thisdisplay create oval $xpos1 382 $xpos2 388 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				16	{	
						set noteE-4  [$thisdisplay create oval $xpos1 387 $xpos2 393 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger6}
						$thisdisplay create line $xpos1leg 390 $xpos2leg 390 -tag {ledger6 ledger} -fill $evv(POINT)
				}
				15	{	
						$thisdisplay create text [expr $xpos1 - 7] 396 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-4 [$thisdisplay create oval $xpos1 387 $xpos2 393 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger6a}
						$thisdisplay create line $xpos1leg 390 $xpos2leg 390 -tag {ledger6a ledger} -fill $evv(POINT)
					}
				14	{	
						set noteD-4  [$thisdisplay create oval $xpos1 392 $xpos2 398 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger6b}
						$thisdisplay create line $xpos1leg 390 $xpos2leg 390 -tag {ledger6b ledger} -fill $evv(POINT)
				 }
				13	{	
						$thisdisplay create text [expr $xpos1 - 7] 401 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-4 [$thisdisplay create oval $xpos1 392 $xpos2 398 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger6c}
						$thisdisplay create line $xpos1leg 390 $xpos2leg 390 -tag {ledger6c ledger} -fill $evv(POINT)
				}
				12	{	
						set noteC-4  [$thisdisplay create oval $xpos1 397 $xpos2 403 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger6d}
						catch {$thisdisplay delete ledger7}
						$thisdisplay create line $xpos1leg 390 $xpos2leg 390 -tag {ledger6d ledger} -fill $evv(POINT)
						$thisdisplay create line $xpos1leg 400 $xpos2leg 400 -tag {ledger7 ledger} -fill $evv(POINT)
				}
				default {
					Inf "CANNOT GRAPHICALLY REPRESENT MIDIVALS BELOW $evv(MIN_TONAL) or ABOVE $evv(MAX_TONAL)"
				}
			}
		} else {
			switch -- $midival {	

				108	{
						set noteC4  [$thisdisplay create oval $xpos1 17 $xpos2 23 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger0}
						catch {$thisdisplay delete ledger1}
						$thisdisplay create line $xpos1leg 20 $xpos2leg 20 -tag {ledger0 ledger} -fill $evv(POINT)
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1 ledger} -fill $evv(POINT)
				}
				107	{
						set noteB3  [$thisdisplay create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger1a}
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1a ledger} -fill $evv(POINT)
				}
				106	{
						$thisdisplay create text [expr $xpos1 - 7] 31 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb3 [$thisdisplay create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger1c}
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1c ledger} -fill $evv(POINT)
				}
				105	{
						set noteA3  [$thisdisplay create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger1d}
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1d ledger} -fill $evv(POINT)
				}
				104	{
						$thisdisplay create text [expr $xpos1 - 7] 36 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb3 [$thisdisplay create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger1e}
						$thisdisplay create line $xpos1leg 30 $xpos2leg 30 -tag {ledger1e ledger} -fill $evv(POINT)
				}
				103	{
						set noteG3  [$thisdisplay create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				102	{
						$thisdisplay create text [expr $xpos1 - 7] 41 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb3 [$thisdisplay create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				}
				101	{
						set noteF3  [$thisdisplay create oval $xpos1 37 $xpos2 43 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				100	{
						set noteE3  [$thisdisplay create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				99	{
						$thisdisplay create text [expr $xpos1 - 7] 51 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb3 [$thisdisplay create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				98	{
						set noteD3  [$thisdisplay create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				97	{
						$thisdisplay create text [expr $xpos1 - 7] 56 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb3 [$thisdisplay create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				96	{
						set noteC3  [$thisdisplay create oval $xpos1 52 $xpos2 58 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				95	{
						set noteB2  [$thisdisplay create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				94	{
						$thisdisplay create text [expr $xpos1 - 7] 66 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb2 [$thisdisplay create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				93	{
						set noteA2  [$thisdisplay create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				92	{
						$thisdisplay create text [expr $xpos1 - 7] 71 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb2 [$thisdisplay create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				}
				91	{
						set noteG2  [$thisdisplay create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				90	{
						$thisdisplay create text [expr $xpos1 - 7] 76 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb2 [$thisdisplay create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				89	{
						set noteF2  [$thisdisplay create oval $xpos1 72 $xpos2 78 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				88	{
						set noteE2  [$thisdisplay create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				87	{	
						$thisdisplay create text [expr $xpos1 - 7] 86 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb2 [$thisdisplay create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				86	{
						set noteD2  [$thisdisplay create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				85	{	
						$thisdisplay create text [expr $xpos1 - 7] 91 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb2 [$thisdisplay create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				}
				84	{
						set noteC2  [$thisdisplay create oval $xpos1 87 $xpos2 93 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger1z}
						$thisdisplay create line $xpos1leg 90 $xpos2leg 90 -tag {ledger1z ledger} -fill $evv(POINT)
				}
				83	{
						set noteB1  [$thisdisplay create oval $xpos1 172 $xpos2 178 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger3}
						$thisdisplay create line $xpos1leg 180 $xpos2leg 180 -tag {ledger3 ledger} -fill $evv(POINT)
				}
				82	{	
						$thisdisplay create text [expr $xpos1 - 7] 181 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb1 [$thisdisplay create oval $xpos1 172 $xpos2 178 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger3a}
						$thisdisplay create line $xpos1leg 180 $xpos2leg 180 -tag {ledger3a ledger} -fill $evv(POINT)
				}
				81	{	
						set noteA1  [$thisdisplay create oval $xpos1 177 $xpos2 183 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger3b}
						$thisdisplay create line $xpos1leg 180 $xpos2leg 180 -tag {ledger3b ledger} -fill $evv(POINT)
				}
				80	{	
						$thisdisplay create text [expr $xpos1 - 7] 186 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb1 [$thisdisplay create oval $xpos1 177 $xpos2 183 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger3c}
						$thisdisplay create line $xpos1leg 180 $xpos2leg 180 -tag {ledger3c ledger} -fill $evv(POINT)
					}
				79	{
						set noteG1  [$thisdisplay create oval $xpos1 182 $xpos2 188 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				78	{	
						$thisdisplay create text [expr $xpos1 - 7] 191 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb1 [$thisdisplay create oval $xpos1 182 $xpos2 188 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				77	{
						set noteF1  [$thisdisplay create oval $xpos1 187 $xpos2 193 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				76	{
						set noteE1  [$thisdisplay create oval $xpos1 192 $xpos2 198 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				75	{	
						$thisdisplay create text [expr $xpos1 - 7] 201 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb1 [$thisdisplay create oval $xpos1 192 $xpos2 198 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				74	{
						set noteD1  [$thisdisplay create oval $xpos1 197 $xpos2 203 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				73	{	
						$thisdisplay create text [expr $xpos1 - 7] 206 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb1 [$thisdisplay create oval $xpos1 197 $xpos2 203 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				72	{
						set noteC1  [$thisdisplay create oval $xpos1 202 $xpos2 208 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				71	{
						set noteB0  [$thisdisplay create oval $xpos1 207 $xpos2 213 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				70	{	
						$thisdisplay create text [expr $xpos1 - 7] 216 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb0 [$thisdisplay create oval $xpos1 207 $xpos2 213 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				69	{
						set noteA0  [$thisdisplay create oval $xpos1 212 $xpos2 218 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				68	{	
						$thisdisplay create text [expr $xpos1 - 7] 221 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb0 [$thisdisplay create oval $xpos1 212 $xpos2 218 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				67	{
						set noteG0  [$thisdisplay create oval $xpos1 217 $xpos2 223 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				66	{	
						$thisdisplay create text [expr $xpos1 - 7] 226 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb0 [$thisdisplay create oval $xpos1 217 $xpos2 223 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				65	{
						set noteF0  [$thisdisplay create oval $xpos1 222 $xpos2 228 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				64	{
						set noteE0  [$thisdisplay create oval $xpos1 227 $xpos2 233 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				63	{	
						$thisdisplay create text [expr $xpos1 - 7] 236 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb0 [$thisdisplay create oval $xpos1 227 $xpos2 233 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				62	{
						set noteD0  [$thisdisplay create oval $xpos1 232 $xpos2 238 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				61	{	
						$thisdisplay create text [expr $xpos1 - 7] 241 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb0 [$thisdisplay create oval $xpos1 232 $xpos2 238 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				}
				60	{
						set noteC0  [$thisdisplay create oval $xpos1 237 $xpos2 243 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger3d}
						$thisdisplay create line $xpos1leg 240 $xpos2leg 240 -tag {ledger3d ledger} -fill $evv(POINT)
				}
				59	{
						set noteB-1  [$thisdisplay create oval $xpos1 242 $xpos2 248 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				58	{	
						$thisdisplay create text [expr $xpos1 - 7] 251 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-1 [$thisdisplay create oval $xpos1 242 $xpos2 248 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				57	{
						set noteA-1  [$thisdisplay create oval $xpos1 247 $xpos2 253 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				56	{	
						$thisdisplay create text [expr $xpos1 - 7] 256 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-1 [$thisdisplay create oval $xpos1 247 $xpos2 253 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				55	{
						set noteG-1  [$thisdisplay create oval $xpos1 252 $xpos2 258 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				54	{	
						$thisdisplay create text [expr $xpos1 - 7] 261 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-1 [$thisdisplay create oval $xpos1 252 $xpos2 258 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				53	{
						set noteF-1  [$thisdisplay create oval $xpos1 257 $xpos2 263 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				52	{
						set noteE-1  [$thisdisplay create oval $xpos1 262 $xpos2 268 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				51	{	
						$thisdisplay create text [expr $xpos1 - 7] 271 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-1 [$thisdisplay create oval $xpos1 262 $xpos2 268 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				50	{
						set noteD-1  [$thisdisplay create oval $xpos1 267 $xpos2 273 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				49	{	
						$thisdisplay create text [expr $xpos1 - 7] 276 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-1 [$thisdisplay create oval $xpos1 267 $xpos2 273 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				48	{
						set noteC-1  [$thisdisplay create oval $xpos1 272 $xpos2 278 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				47	{
						set noteB-2  [$thisdisplay create oval $xpos1 277 $xpos2 283 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				46	{	
						$thisdisplay create text [expr $xpos1 - 7] 286 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-2 [$thisdisplay create oval $xpos1 277 $xpos2 283 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				45	{
						set noteA-2  [$thisdisplay create oval $xpos1 282 $xpos2 288 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				44	{	
						$thisdisplay create text [expr $xpos1 - 7] 291 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-2 [$thisdisplay create oval $xpos1 282 $xpos2 288 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				43	{
						set noteG-2  [$thisdisplay create oval $xpos1 287 $xpos2 293 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				42	{	
						$thisdisplay create text [expr $xpos1 - 7] 296 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-2 [$thisdisplay create oval $xpos1 287 $xpos2 293 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				41	{
						set noteF-2  [$thisdisplay create oval $xpos1 292 $xpos2 298 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				40	{
						set noteE-2  [$thisdisplay create oval $xpos1 297 $xpos2 303 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger4}
						$thisdisplay create line $xpos1leg 300 $xpos2leg 300 -tag {ledger4 ledger} -fill $evv(POINT)
				}
				39	{	
						$thisdisplay create text [expr $xpos1 - 7] 306 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-2 [$thisdisplay create oval $xpos1 297 $xpos2 303 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger4a}
						$thisdisplay create line $xpos1leg 300 $xpos2leg 300 -tag {ledger4a ledger} -fill $evv(POINT)
					}
				38	{	
						set noteD-2  [$thisdisplay create oval $xpos1 302 $xpos2 308 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger4b}
						$thisdisplay create line $xpos1leg 300 $xpos2leg 300 -tag {ledger4b ledger} -fill $evv(POINT)
				}
				37	{	
						$thisdisplay create text [expr $xpos1 - 7] 311 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-2 [$thisdisplay create oval $xpos1 302 $xpos2 308 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger4c}
						$thisdisplay create line $xpos1leg 300 $xpos2leg 300 -tag {ledger4c ledger} -fill $evv(POINT)
					}
				36	{	
						set noteC-2  [$thisdisplay create oval $xpos1 307 $xpos2 313 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						catch {$thisdisplay delete ledger4d}
						catch {$thisdisplay delete ledger5}
						$thisdisplay create line $xpos1leg 300 $xpos2leg 300 -tag {ledger4d ledger} -fill $evv(POINT)
						$thisdisplay create line $xpos1leg 310 $xpos2leg 310 -tag {ledger5 ledger} -fill $evv(POINT)
				}
				35	{
						set noteB-3  [$thisdisplay create oval $xpos1 392 $xpos2 398 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				}
				34	{	
						$thisdisplay create text [expr $xpos1 - 7] 401 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-3 [$thisdisplay create oval $xpos1 392 $xpos2 398 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				33	{	
						set noteA-3  [$thisdisplay create oval $xpos1 397 $xpos2 403 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				}
				32	{	
						$thisdisplay create text [expr $xpos1 - 7] 406 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-3 [$thisdisplay create oval $xpos1 397 $xpos2 403 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				31	{
						set noteG-3  [$thisdisplay create oval $xpos1 402 $xpos2 408 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				30	{	
						$thisdisplay create text [expr $xpos1 - 7] 411 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-3 [$thisdisplay create oval $xpos1 402 $xpos2 408 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				29	{
						set noteF-3  [$thisdisplay create oval $xpos1 407 $xpos2 413 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				28	{
						set noteE-3  [$thisdisplay create oval $xpos1 412 $xpos2 418 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				27	{	
						$thisdisplay create text [expr $xpos1 - 7] 421 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-3 [$thisdisplay create oval $xpos1 412 $xpos2 418 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				26	{
						set noteD-3  [$thisdisplay create oval $xpos1 417 $xpos2 423 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				25	{	
						$thisdisplay create text [expr $xpos1 - 7] 426 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-3 [$thisdisplay create oval $xpos1 417 $xpos2 423 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				24	{
						set noteC-3  [$thisdisplay create oval $xpos1 422 $xpos2 428 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				23	{
						set noteB-4  [$thisdisplay create oval $xpos1 427 $xpos2 433 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				22	{	
						$thisdisplay create text [expr $xpos1 - 7] 436 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-4 [$thisdisplay create oval $xpos1 427 $xpos2 433 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				21	{
						set noteA-4  [$thisdisplay create oval $xpos1 432 $xpos2 438 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				20	{	
						$thisdisplay create text [expr $xpos1 - 7] 441 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-4 [$thisdisplay create oval $xpos1 432 $xpos2 438 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				19	{
						set noteG-4  [$thisdisplay create oval $xpos1 437 $xpos2 443 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				18	{	
						$thisdisplay create text [expr $xpos1 - 7] 446 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-4 [$thisdisplay create oval $xpos1 437 $xpos2 443 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
					}
				17	{
						set noteF-4  [$thisdisplay create oval $xpos1 442 $xpos2 448 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				}
				16	{	
						set noteE-4  [$thisdisplay create oval $xpos1 447 $xpos2 453 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger6}
						$thisdisplay create line $xpos1leg 450 $xpos2leg 450 -tag {ledger6 ledger} -fill $evv(POINT)
				}
				15	{	
						$thisdisplay create text [expr $xpos1 - 7] 456 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-4 [$thisdisplay create oval $xpos1 447 $xpos2 453 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger6a}
						$thisdisplay create line $xpos1leg 450 $xpos2leg 450 -tag {ledger6a ledger} -fill $evv(POINT)
					}
				14	{	
						set noteD-4  [$thisdisplay create oval $xpos1 452 $xpos2 458 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger6b}
						$thisdisplay create line $xpos1leg 450 $xpos2leg 450 -tag {ledger6b ledger} -fill $evv(POINT)
				 }
				13	{	
						$thisdisplay create text [expr $xpos1 - 7] 461 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-4 [$thisdisplay create oval $xpos1 452 $xpos2 458 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
						catch {$thisdisplay delete ledger6c}
						$thisdisplay create line $xpos1leg 450 $xpos2leg 450 -tag {ledger6c ledger} -fill $evv(POINT)
				}
				12	{	
						set noteC-4  [$thisdisplay create oval $xpos1 457 $xpos2 463 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						catch {$thisdisplay delete ledger6d}
						catch {$thisdisplay delete ledger7}
						$thisdisplay create line $xpos1leg 450 $xpos2leg 450 -tag {ledger6d ledger} -fill $evv(POINT)
						$thisdisplay create line $xpos1leg 460 $xpos2leg 460 -tag {ledger7 ledger} -fill $evv(POINT)
				}
				default {
					Inf "Cannot Graphically Represent MIDI Vals Below $evv(MIN_TONAL) or Above $evv(MAX_TONAL)"
				}
			}
		}
	}
}

#---- Clear all notes from VaribankGrafix display

proc ClearPitchGrafix {w} {
	catch {$w delete notes}
	catch {$w delete flats}
	catch {$w delete ledger}
}

#------ GENERAL PURPOSE TABEDITOR FUNCTIONS

proc WriteOutputTable {linecnt_setting} {
	global outcolcnt tot_outlines tabed evv

	set ol $tabed.bot.otframe.l.list
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
		$tabed.message.e config -bg $evv(EMPH)
		$ol delete 0 end		;#	Clear existing listing of output table
		set outcolcnt ""
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		return 0
	} else { 
		switch -regexp -- $linecnt_setting \
			^$evv(LINECNT_RESET)$ {
				set outcolcnt 0
				set tot_outlines 0
				foreach line [$ol get 0 end] {
					if {!$outcolcnt} {
						foreach val $line {
							set val [string trim $val]
							if {[string length $val] > 0} {
								 incr outcolcnt
							}
						}
					}
					incr tot_outlines
					puts $fileot $line
				}
			} \
			^$evv(LINECNT_NOT_RESET)$ {
				foreach line [$ol get 0 end] {
					if {$tot_outlines == 0} {
						set zline [split $line]
						foreach item $zline {
							if {[string length $item] > 0} {
								incr outcolcnt
							}
						}
					}
					puts $fileot $line
					incr tot_outlines
				}
			} \
			^$evv(LINECNT_ONE)$ {
				set i 0
				foreach line [$ol get 0 end] {
					puts $fileot $line
					incr i
				}
				set outcolcnt 1
				set tot_outlines $i
			}

		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	}
	close $fileot
	return 1
}

#----- Write Output Column to file, and set buttons in keep-column panel
#
# outline_tot -- is set if (outlines MUST EQUAL tot_outlines) for insert mode to be activated
# copymode ----- is set if 'copy' is being used
# insitu_check - is set if the output column could be written into the input column
#

proc WriteOutputColumn {fnam ll lcnt outline_tot copymode insitu_check} {
	global tot_inlines tot_outlines orig_inlines orig_incolget rcolno coltype inlines outlines tabed insitu colmode evv

	set tb $tabed.bot.kcframe

	if [catch {open $fnam "w"} fileoc] {
		ForceVal $tabed.message.e  "Cannot open temporary file $fnam to write new column data"
		$tabed.message.e config -bg $evv(EMPH)
		$ll delete 0 end		;#	Clear existing listing of output column
		set $lcnt ""
		if {$lcnt == "inlines"} {
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		}
	} else {
		set $lcnt 0
		foreach line [$ll get 0 end] {
			puts $fileoc $line
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		}
		close $fileoc						;#	Write data to file

		if {!$insitu || $copymode} {
			set outtable_exists 0
			if {[info exists tot_outlines] && ([string length $tot_outlines] > 0) && ($tot_outlines > 0)} {
				set outtable_exists 1
			}
			$tb.oky config -state normal
			$tb.okz config -state normal
			if {[info exists tot_inlines] && ([string length $tot_inlines] > 0) && ($tot_inlines > 0)} {
				if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
					SetKCState "o"
					ForceVal $tb.e $rcolno
				} elseif {$outlines == $tot_inlines} {
					set coltype "i"
					$tb.oki config -state normal
					$tb.oko config -state disabled
					$tb.okr config -state normal
					set rcolno $orig_incolget
					ForceVal $tb.e $rcolno
					$tb.e config -state normal
				} else {
					SetKCState "k"
				}
			} elseif {!$outtable_exists} {
				SetKCState "k"
			} elseif {($outline_tot && ($outlines == $tot_outlines)) || !$outline_tot} {
				if {$outtable_exists} {
					SetKCState "i"
				} else {
					SetKCState "k"
				}
			}
			$tb.okk config -state normal
			$tb.ok config -state normal
		} elseif {$insitu_check && $insitu} {
			set orig_incolget ""
			ForceVal $tabed.bot.gframe.got $orig_incolget
			if {($outlines > 0) && ($coltype == "o")} {
				SetKCState "i"
			}
		} elseif {[info exists tot_outlines] && ([string length $tot_outlines] > 0) && ($tot_outlines > 0)} {
			SetKCState "k"
		}
	}
}

#---------

proc DisableOutputTableOptions {outclear} {
	global outcolcnt tot_outlines tabedit_bind2 tabed evv readonlyfg readonlybg

	if {$outclear} {
		$tabed.bot.otframe.l.list delete 0 end		;#	Clear existing listing of output table
 		set outcolcnt 0
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines 0
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	}
	set tb $tabed.bot.ktframe
	$tb.fnm config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	bind $tb.names.list <ButtonRelease-1> {}
	catch {unset tabedit_bind2}
	$tb.bbb.1 config -state disabled
	$tb.bbb.2 config -state disabled
	$tb.bbb.3 config -state disabled
	$tb.bbb1.4 config -state disabled
	$tb.bxxb config -state disabled -text ""
	$tb.bbb1.6 config -state disabled
	$tb.zz2.ok1 config -state disabled
	$tb.zz2a.ok2 config -state disabled
	$tb.zz2a.ok3 config -state disabled
	$tb.zz2.ok4 config -state disabled -bg [option get . background {}]
}

#---------

proc EnableOutputTableOptions {dehilite_batchbutton rename} {
	global tabed tabedit_ns tabedit_bind2 col_infnam col_tabname evv

	set t $tabed.bot.ktframe

	$t.fnm config -state normal -fg [option get . foreground {}]
	bind $t.names.list <ButtonRelease-1> $tabedit_ns
	set tabedit_bind2 [bind $t.names.list <ButtonRelease-1>]
	$t.bbb.1 config -state normal
	$t.bbb.2 config -state normal
	$t.bbb.3 config -state normal
	$t.bbb1.4 config -state normal
	$t.bxxb config -state normal -text "Standd Names"
	if {$rename} {	;# USE OF THIS SEEMS A BIT ARBITRARY, NEEDS RATIONALISATION, IF IT'S EVEN USEFUL!!
		if {([string length $col_infnam] > 0) && ![string match $evv(DFLT_OUTNAME)* $col_infnam]} {
			$t.bbb1.6 config -state normal
		} else {
			$t.bbb1.6 config -state disabled
		}
	}
	$t.zz2.ok1 config -state normal
	$t.zz2a.ok2 config -state normal
	$t.zz2a.ok3 config -state normal
	if {$dehilite_batchbutton} {
		$t.zz2.ok4 config -state normal -bg [option get . background {}]
	} else {
		$t.zz2.ok4 config -state normal
	}
}

#---------

proc DisableOutputColumnOptions {} {
	global tabed
	set t $tabed.bot.kcframe
	$t.oko config -state disabled
	$t.okr config -state disabled
	$t.oki config -state disabled
	$t.okk config -state disabled
	$t.oky config -state disabled
	$t.okz config -state disabled
	$t.e config -state disabled
	$t.ok config -state disabled
}

#---------

proc DisableOutputColumnOptions2 {} {
	global tabed ino okz coltype
	set t $tabed.bot.kcframe

	$t.oko config -state disabled
	set coltype ""
	$t.okk config -state disabled
	$t.okr config -state disabled
	$t.oki config -state disabled
	$t.oky config -fg [option get . foreground {}] -state disabled
	$t.okz config -fg [option get . foreground {}] -state disabled
	set ino 0
	set okz 0
}

proc PlayChordset {fnam typ} {
	global tabed CDPidrun prg_dun prg_abortd program_messages col_infnam wstk col_ungapd_numeric lmo mu evv

	set lmo "Pc"
	lappend lmo $col_ungapd_numeric $fnam $typ
	set maxfrq [MidiToHz 127]
	set minfrq [MidiToHz 0]
	set bum 0
	if {$typ != 0} {
		if {$typ > 6} {
			if {![info exists col_infnam] || ([string length $col_infnam] <=0)} {
				ForceVal $tabed.message.e "No Input Table Selected"
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {$typ == 10} {
				set i [$tabed.bot.itframe.l.list curselection]
				if {$i < 0} {
					ForceVal $tabed.message.e "No row selected with cursor."
	 				$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set line [$tabed.bot.itframe.l.list get $i]
				set line [split $line]
				foreach item $line {
					if {![IsNumeric $item] || ($item < $mu(MIDIMIN)) || ($item > $mu(MIDIMAX))} {
						ForceVal $tabed.message.e "Value ($item) out of range."
	 					$tabed.message.e config -bg $evv(EMPH)
						return
					}
					lappend thislist $item
				}
			} else {
				set thislist [$tabed.bot.itframe.l.list get 0 end]
			}
		} else {
			set thislist [$tabed.bot.icframe.l.list get 0 end]
		}
		if [catch {open cdptest00.txt "w"} zit] {
			ForceVal $tabed.message.e "Cannot open file cdptest00.txt"
 			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set cnt 0
		set chordcnt 1
		foreach val $thislist {
			switch -- $typ {
				1 -
				7 {
					if {![IsNumeric $val]} {
						ForceVal $tabed.message.e "Values are not all numeric"
	 					$tabed.message.e config -bg $evv(EMPH)
						close $zit
						return
					}
					if {($val < 0) || ($val > 127)} {
						set bum 1
					}
				}
				2 -
				8 {
					if {![IsNumeric $val]} {
						ForceVal $tabed.message.e "Values are not all numeric"
	 					$tabed.message.e config -bg $evv(EMPH)
						close $zit
						return
					}
					if {($val < $minfrq) || ($val > $maxfrq)} {
						set bum 1
					} else {
						set val [HzToMidi $val]
					}
				}
				3 -
				9 {
					if {[string match #* $val]} {
						if {$cnt == 0} {
							ForceVal $tabed.message.e "Chord marker (#) at start of list"
	 						$tabed.message.e config -bg $evv(EMPH)
							close $zit
							return
						}
						if {[info exists chordat] && ($cnt == [expr $chordat + 1])} {
							ForceVal $tabed.message.e "Adjacent Chord markers (#) in file"
	 						$tabed.message.e config -bg $evv(EMPH)
							close $zit
							return
						}
						set chordat $cnt
						set val -100.0
						incr chordcnt
					} elseif {![IsNumeric $val]} {
						ForceVal $tabed.message.e "Values (apart from markers) are not all numeric"
	 					$tabed.message.e config -bg $evv(EMPH)
						close $zit
						return
					} elseif {($val < 0) || ($val > 127)} {
						set bum 1
					}
				}
			}
			if {$bum} {
				ForceVal $tabed.message.e "Value '$val' is out of range"
	 			$tabed.message.e config -bg $evv(EMPH)
				close $zit
				return
			}
			puts $zit $val
			incr cnt
		}
		if {(($typ == 3) || ($typ == 9)) && ($chordat == [expr $cnt - 1])} {
			incr chordcnt -1
		}
		close $zit
		if {$cnt == 0} {
			ForceVal $tabed.message.e "No data in the output column"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {$typ > 6} {
			incr typ -6
		}
		set fnam "cdptest00.txt"
	}
	catch {file delete cdptest00.wav}
	Block "CREATING CHORD"
	if {$typ == 3} {
		set outdur [expr 1.5 * double($chordcnt)]
		set CDP_cmd [list synth chord 3 cdptest00.wav $fnam 48000 1 $outdur -a.3 -t4096]
	} else {
		set CDP_cmd [list synth chord 1 cdptest00.wav $fnam 48000 1 4 -a.3 -t4096]
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set firstword [lindex $CDP_cmd 0]
	set firstword [file join $evv(CDPROGRAM_DIR) $firstword]
	set CDP_cmd [lreplace $CDP_cmd 0 0 $firstword]
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Chord"
		UnBlock
		return
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		set errorline "Create Chord Process Failed"
	}
	if [info exists errorline] {
		Inf "$errorline"
	}
	if [info exists program_messages] {
		Inf "$program_messages"
		unset program_messages
	}
	UnBlock
	if {[file exists "cdptest00.wav"]} {
		PlaySndfile cdptest00.wav 0			;# PLAY OUTPUT
	}
}

#--- Change pattern in column of vals

proc RepatternCol {} {
	global colpar outlines tedit_message last_oc last_cr record_temacro temacro temacrop threshold evv
	global inlines coltype rcolno col_ungapd_numeric orig_incolget tround tot_outlines tabed
	global tot_inlines lmo insitu orig_inlines

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {	   	;#	If there's an input TABLE
		SetInout 1												;#	Reset default to act on input TABLE
	}
	HaltCursCop
	set lmo "RC"
	lappend lmo $col_ungapd_numeric									;#	 Remember last action.

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	set n "normal"
	set d "disabled"
	set tb $tabed.bot
	if {![file exists $evv(COLFILE1)]} {
		ForceVal $tabed.message.e "No column selected"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists colpar] || ([string length $colpar] <= 0)} {
		ForceVal $tabed.message.e "No pattern expression entered at 'N'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set colpar [string tolower $colpar]
	set map [TestMapPattern]
	if {[llength $map] <= 0} {
		return
	}
	set len [llength $map]
	incr len -1
	set patstep [lindex $map $len]
	incr len -1
	set goallen [lindex $map $len]
	incr len -1
	set srclen [lindex $map $len]
	incr len -1
	set map [lrange $map 0 $len]

	foreach zz [$tb.icframe.l.list get 0 end] {
		lappend tmpst $zz
	}
	if {$insitu} {									;# establish which col to output to on
		set fnam $evv(COLFILE1)
		set ll $tb.icframe.l.list
		set lcnt "inlines"
	} else {
		set fnam $evv(COLFILE2)
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
		set last_oc [$tb.ocframe.l.list get 0 end]
		set last_cr $col_ungapd_numeric					;#	In normal situation.
		DisableOutputColumnOptions
	}
	$ll delete 0 end

	set len [llength $tmpst]
	set len_less_one [expr $len - 1]
	set nn 0
	set m [expr $srclen - 1]
	if {$m >= $len_less_one} {
		set m $len_less_one
	}
	set outlist {}
	while {$nn < $len} {
		set remaining_set [lrange $tmpst $nn $m]
		set newlist [DoMapping $remaining_set $srclen $goallen $map]
		if {[llength $newlist] > 0} {
			set outlist [concat $outlist $newlist]
		}
		if {[llength $newlist] < $goallen} {
			break
		}
		incr nn $patstep
		incr m $patstep
		if {$m >= $len_less_one} {
			set m $len_less_one
		}
	}
	foreach yy $outlist {
		$ll insert end $yy
	}
	set outlines $inlines
	ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	if [catch {open $fnam "w"} fileoc] {
		ForceVal $tabed.message.e  "Cannot open temporary file $fnam to write new column data"
	 	$tabed.message.e config -bg $evv(EMPH)
		$ll delete 0 end		;#	Clear existing listing
		set $lcnt ""
		if {$lcnt == "inlines"} {
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		}
	} else {
		set $lcnt 0
		foreach line [$ll get 0 end] {
			puts $fileoc $line
			incr $lcnt
		}
		if {$lcnt == "inlines"} {
			ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		} else {
			ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
		}
		close $fileoc						;#	Write data to file
  		if {!$insitu} {
			$tb.kcframe.oky config -state $n
			$tb.kcframe.okz config -state $n
			if {[info exists tot_inlines] && ($tot_inlines > 0)} {
				if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
					SetKCState "o"
					ForceVal $tb.kcframe.e $rcolno
				} elseif {$outlines == $tot_inlines} {
					set coltype "i"
					$tb.kcframe.oki config -state $n
					$tb.kcframe.oko config -state $d
					$tb.kcframe.okr config -state $n
					set rcolno $orig_incolget
					ForceVal $tb.kcframe.e $rcolno
					$tb.kcframe.e config -state $n -fg [option get . foreground {}]
				} else {
					SetKCState "k"
				}
			} elseif {[info exists tot_outlines] && ($tot_outlines > 0)} {
				SetKCState "i"
			} else {
				SetKCState "k"
			}
			$tb.kcframe.okk config -state $n
			$tb.kcframe.ok config -state $n
		}
	}
}

proc MakeMap {src goal} {
	set map {}
	set maxsrcpos 0
	set n 0
	set lensrc [string length $src]
	set lengoal [string length $goal]
	while {$n < $lensrc} {
		set item [string index $src $n]
		switch -- $item {
			"a" { set srcposition 0}
			"b" { set srcposition 1}
			"c" { set srcposition 2}
			"d" { set srcposition 3}
			"e" { set srcposition 4}
			"f" { set srcposition 5}
			"g" { set srcposition 6}
			"h" { set srcposition 7}
			"i" { set srcposition 8}
			"j" { set srcposition 9}
			"k" { set srcposition 10}
			"l" { set srcposition 11}
			"m" { set srcposition 12}
			"n" { set srcposition 13}
			"o" { set srcposition 14}
			"p" { set srcposition 15}
			"q" { set srcposition 16}
			"r" { set srcposition 17}
			"s" { set srcposition 18}
			"t" { set srcposition 19}
			"u" { set srcposition 20}
			"v" { set srcposition 21}
			"w" { set srcposition 22}
			"x" { set srcposition 23}
			"y" { set srcposition 24}
			"z" { set srcposition 25}
		}
		if {$srcposition > $maxsrcpos} {
			set maxsrcpos $srcposition
		}
		set goalposition 0
		while {$goalposition < $lengoal} {
			set item2 [string index $goal $goalposition]
			if {[string match $item $item2]} {
				lappend map $srcposition $goalposition
			}
			incr goalposition
		}
		incr n
	}
	lappend map [expr $maxsrcpos + 1]
	return $map
}

proc DoMapping {remaining_set srclen goallen map}  {
	set len [llength $remaining_set]
	set n 0
	while {$n < $goallen} {
		lappend outvals "#"
		incr n
	}
	foreach {srcpos goalpos} $map {
		if {$srcpos >= $len} {
			break
		}
		set val [lindex $remaining_set $srcpos]
		set outvals [lreplace $outvals $goalpos $goalpos $val]
	}
	if {[string match "#" [lindex $outvals 0]]} {
		return {}
	}
	set outend 0
	foreach val [lrange $outvals 1 end] {
		if {[string match $val "#"]} {
			set outvals [lrange $outvals 0 $outend]
			break
		}
		incr outend
	}
	return $outvals
}

proc TestMapPattern {} {
	global colpar tabed evv
	set colpar [string tolower $colpar]
	set sep [string first ":" $colpar]
	if {$sep < 0} {
		ForceVal $tabed.message.e "No separator ':' in pattern expression."
	 	$tabed.message.e config -bg $evv(EMPH)
		return {}
	}
	if {$sep < 1} {
		ForceVal $tabed.message.e "No sequence before separator ':' in pattern expression."
	 	$tabed.message.e config -bg $evv(EMPH)
		return {}
	}
	set len [string length $colpar]
	set endindex [expr $len - 1]
	if {$sep == $endindex} {
		ForceVal $tabed.message.e "No sequence after separator ':' in pattern expression."
	 	$tabed.message.e config -bg $evv(EMPH)
		return {}
	}
	set sepcnt 0
	set n 0
	while {$n < $len} {
		set item [string index $colpar $n]
		if {[string match $item ":"]} {
			incr sepcnt
			if {$sepcnt == 2} {
				set sep2 $n
			}
		}
		incr n
	}
	if {$sepcnt != 2} {
		ForceVal $tabed.message.e "Not enough separators ':' in pattern expression."
	 	$tabed.message.e config -bg $evv(EMPH)
		return {}
	}
	if {$sep2 == $endindex} {
		ForceVal $tabed.message.e "No numeric step at end of pattern."
	 	$tabed.message.e config -bg $evv(EMPH)
		return {}
	}
	incr sep2
	set patstep [string range $colpar $sep2 end]
	if {![regexp {^[0-9]+$} $patstep]} {
		ForceVal $tabed.message.e "No numeric step at end of pattern."
	 	$tabed.message.e config -bg $evv(EMPH)
		return {}
	}
	if {$patstep <= 0} {
		ForceVal $tabed.message.e "Invalid numeric step at end of pattern."
	 	$tabed.message.e config -bg $evv(EMPH)
		return {}
	}
	incr sep2 -2
	set newcolpar [string range $colpar 0 $sep2]
	if {![regexp {^[a-z:]+$} $newcolpar]} {
		ForceVal $tabed.message.e "Pattern must contain only alphabetic characters and separator ':'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return {}
	}
	incr sep -1
	set srcpat [string range $newcolpar 0 $sep]
	incr sep 2
	set goalpat [string range $newcolpar $sep end]
	set lengoal [string length $goalpat]
	set lensrc  [string length $srcpat]

	set n 0 
	while {$n < $lengoal} {
		set test [string index $goalpat $n]
		if {[string first $test $srcpat] < 0} {
			ForceVal $tabed.message.e "Item '$test' in goal pattern is not in source pattern."
	 		$tabed.message.e config -bg $evv(EMPH)
			return  {}
		}
		incr n
	}
	set map [MakeMap $srcpat $goalpat]
	if {[llength $map] <= 0} {
		return {}
	}
	lappend map $lengoal $patstep
	return $map
}

proc RepatternHelp {} {
	set msg "REPATTERN PROCESS\n\n"
	append msg "With column of values\n"
	append msg "12  13  14  15  16  17  18  19  20 ....\n"
	append msg "\n"
	append msg "and pattern          'ace:aecc:3'\n"
	append msg "\n"
	append msg "1) Get vals at positions 1,3,5 (ace)\n"
	append msg "      i.e.    12  14  16\n"
	append msg "2) Reorder as 'aecc'  i.e. 12  16  14  14\n"
	append msg "3) Then move by 3 steps in input column\n"
	append msg "      i.e. to ....15 17 19 ....\n"
	append msg "      and repeat the process\n"
	append msg "      (i.e. output  15  19  17  17)\n"
	append msg "\n"
	append msg "and so on, until input column is exhausted.\n"
	Inf $msg
}

#------ Get a columns from a table

proc GetBothColumnsFromATable {} {
	global rcolno coltype tedit_message CDPcolget col_ungapd_numeric
	global incolget incols tot_inlines tabed col_from_table evv col_infnam inlines orig_incolget incol_OK
	global col_lines_skipped orig_inlines orig_incolget outlines tot_outlines outline_tot 

	set n "normal"
	set d "disabled"
	if {![info exists tot_inlines] || ($tot_inlines <= 0)} {
		ForceVal $tabed.message.e "No input table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$incols != 2} {
		ForceVal $tabed.message.e "Input table does not have 2 columns"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set tb $tabed.bot
	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]
	catch {unset col_from_table}

	set getcol_cmd [file join $evv(CDPROGRAM_DIR) getcol]
	lappend getcol_cmd $col_infnam $evv(COLFILE1) 1

	set incol_OK 1

	set inlines ""
	ForceVal $tabed.bot.icframe.dummy.cnt $inlines
 	set orig_incolget ""
	ForceVal $tabed.bot.gframe.got $orig_incolget
	$tb.icframe.l.list delete 0 end		;#	Clear existing listing of input column
	$tb.ocframe.l.list delete 0 end		;#	Clear existing listing of output column
	$tabed.bot.gframe.got config -bg [option get . background {}]

	set sloom_cmd [linsert $getcol_cmd 1 "#"]
	if [catch {open "|$sloom_cmd"} CDPcolget] {
		ErrShow "$CDPcolget"
   	} else {
   		fileevent $CDPcolget readable "DisplayColumnFromTable"
		vwait incol_OK
   	}

	if {![info exists col_from_table]} {
		if {[string length $tedit_message] <= 0} {
			ForceVal $tabed.message.e  "No 1st column data found."
		 	$tabed.message.e config -bg $evv(EMPH)
		}
		set incol_OK 0
	}
	if {!$incol_OK} {
		$tb.icframe.l.list delete 0 end		;#	Clear existing listing of input column
		set inlines ""
		ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		return
	}
	set col_lines_skipped ""
	set incolget 1
	set col_ungapd_numeric 1
	if [catch {open $evv(COLFILE1) "w"} fileic] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE1) to write column data"
		$tabed.message.e config -bg $evv(EMPH)
		$tb.icframe.l.list delete 0 end		;#	Clear existing listing of input column
		set inlines ""
		ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		set incolget ""
		set orig_inlines ""
		set orig_incolget ""
		ForceVal $tabed.bot.gframe.got $orig_incolget
		return
	} else {
		set inlines 0
		foreach line $col_from_table {
			$tb.icframe.l.list insert end $line
			if {![IsNumeric $line]} {
				set col_ungapd_numeric 0
			}
			puts $fileic $line
			incr inlines
		}
		ForceVal $tabed.bot.icframe.dummy.cnt $inlines
		close $fileic							;#	Write data to file
		set orig_inlines $inlines
		set orig_incolget $incolget
		ForceVal $tabed.bot.gframe.got $orig_incolget
		$tabed.bot.gframe.got config -bg $evv(EMPH)
	}
	catch {unset col_from_table}

	set getcol_cmd [file join $evv(CDPROGRAM_DIR) getcol]
	lappend getcol_cmd $col_infnam $evv(COLFILE2) 2

	set incol_OK 1

	set sloom_cmd [linsert $getcol_cmd 1 "#"]
	if [catch {open "|$sloom_cmd"} CDPcolget] {
		ErrShow "$CDPcolget"
   	} else {
   		fileevent $CDPcolget readable "DisplayColumnFromTable"
		vwait incol_OK
   	}

	if {![info exists col_from_table]} {
		if {[string length $tedit_message] <= 0} {
			ForceVal $tabed.message.e  "No 2nd column data found."
		 	$tabed.message.e config -bg $evv(EMPH)
		}
	}
	if {!$incol_OK} {
		return
	}
	set outlines 0	
	if [catch {open $evv(COLFILE2) "w"} fileoc] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE2) to write column data"
		$tabed.message.e config -bg $evv(EMPH)
		$tb.ocframe.l.list delete 0 end		;#	Clear existing listing of output column
	} else {
		foreach line $col_from_table {
			$tb.ocframe.l.list insert end $line
			if {![IsNumeric $line]} {
				set col_ungapd_numeric 0
			}
			puts $fileoc $line
			incr outlines
		}
		close $fileoc							;#	Write data to file
	}
	ForceVal $tabed.bot.ocframe.dummy.cnt $outlines
	set outtable_exists 0
	if {[info exists tot_outlines] && ([string length $tot_outlines] > 0) && ($tot_outlines > 0)} {
		set outtable_exists 1
	}
	set tb $tabed.bot.kcframe
	$tb.oky config -state normal
	$tb.okz config -state normal
	if {[info exists tot_inlines] && ([string length $tot_inlines] > 0) && ($tot_inlines > 0)} {
		if {[info exists orig_inlines] && ($outlines == $orig_inlines)} {
			SetKCState "o"
			ForceVal $tb.e $rcolno
		} elseif {$outlines == $tot_inlines} {
			set coltype "i"
			$tb.oki config -state normal
			$tb.oko config -state disabled
			$tb.okr config -state normal
			set rcolno $orig_incolget
			ForceVal $tb.e $rcolno
			$tb.e config -state normal
		} else {
			SetKCState "k"
		}
	} elseif {!$outtable_exists} {
		SetKCState "k"
	} else {
		if {$outtable_exists} {
			SetKCState "i"
		} else {
			SetKCState "k"
		}
	}
	$tb.okk config -state normal
	$tb.ok config -state normal
}

#------ Select one item from each row (col) chosing a random col (row)

proc RandColSelect {colmode} {
	global tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold tabed mix_perm

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$colmode == 0} {
		set lmo "RCS"
	} else {
		set lmo "RRS"
	}
	lappend lmo 0 $colmode
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set len 0
	if {$colmode == 0} {
		if {$incols <= 1} {
			ForceVal $tabed.message.e "Only one input column: cannot randomise."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set incols_less_one [expr $incols - 1]
		set cnt 0
		RandomiseOrder $incols
		foreach line [$it get 0 end] {
			set line [string trim $line]
			set line [split $line]
			catch {unset items}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend items $item
				}
			}
			lappend nucol [lindex $items $mix_perm($cnt)]
			incr cnt
			if {$cnt >= $incols} {
				set lastval $mix_perm($incols_less_one)
				set firstval $lastval
				while {$firstval == $lastval} {
					RandomiseOrder $incols
					set firstval $mix_perm(0)
				}
				set cnt 0
			}
		}
	} else {
		if {$tot_inlines <= 1} {
			ForceVal $tabed.message.e "Only one input row: cannot randomise."
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set tot_inlines_less_one [expr $tot_inlines - 1]
		foreach line [$it get 0 end] {
			set line [string trim $line]
			set line [split $line]
			set zz 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend cols($zz) $item
					incr zz
				}
			}
		}
		set zz 0 
		set cnt 0
		RandomiseOrder $tot_inlines
		while {$zz < $incols} {
			lappend nucol [lindex $cols($zz) $mix_perm($cnt)]
			incr cnt
			if {$cnt >= $tot_inlines} {
				set lastval $mix_perm($tot_inlines_less_one)
				set firstval $lastval
				while {$firstval == $lastval} {
					RandomiseOrder $tot_inlines
					set firstval $mix_perm(0)
				}
				set cnt 0
			}
			incr zz
		}
	}
	if {![info exists nucol]} {
		ForceVal $tabed.message.e  "Failed to generate output data"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	$ot delete 0 end
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$colmode == 0} {
		foreach itm $nucol {
			$ot insert end $itm
			puts $fileot $itm
		}
		set outcolcnt 1
		set tot_outlines $tot_inlines
	} else {
		set outrow [lindex $nucol 0]
		foreach itm [lrange $nucol 1 end] {
			append outrow "  " $itm
		}
		$ot insert end $outrow
		puts $fileot $outrow
		set outcolcnt $incols
		set tot_outlines 1
	}
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	close $fileot
	EnableOutputTableOptions 1 1
}

proc ColsBecomeRows {} {
	global tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold tabed mix_perm

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set it $tabed.bot.itframe.l.list
	set ot $tabed.bot.otframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <=0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set lmo "CBR"
	lappend lmo 0 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set len 0
	foreach line [$it get 0 end] {
		set line [string trim $line]
		set line [split $line]
		set zz 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend cols($zz) $item
				incr zz
			}
		}
	}
	set zz 0 
	while {$zz < $incols} {
		set line [lindex $cols($zz) 0]
		foreach item [lrange $cols($zz) 1 end] {
			append line "  " $item
		}
		lappend nulines $line
		incr zz
	}
	if {![info exists nulines]} {
		ForceVal $tabed.message.e  "Failed to generate output data"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	$ot delete 0 end
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach itm $nulines {
		$ot insert end $itm
		puts $fileot $itm
	}
	set outcolcnt $tot_inlines
	ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
	set tot_outlines $incols
	ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	close $fileot
	EnableOutputTableOptions 1 1
}

proc CursRotate {} {
	global tot_inlines colpar incols outcolcnt tot_outlines lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop threshold tabed inlines insitu

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set ic $tabed.bot.icframe.l.list
	set oc $tabed.bot.ocframe.l.list
 	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	if {![info exists inlines] || ($inlines <= 0)} {
		ForceVal $tabed.message.e "No Col Input exists"
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set lmo "CR"
	lappend lmo 0 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	set start [$ic curselection]
	if {$start < 0} {
		Inf "No Item Selected In Input Column"
		return
	}
	if {$start == 0} {
		Inf "Selecting The First Item In Input Column Has No Effect"
		return
	}
	set len [$ic index end]
	set i $start
	while {$i < $len} {
		lappend nulst [$ic get $i]
		incr i
	}
	set i 0
	while {$i < $start} {
		lappend nulst [$ic get $i]
		incr i
	}
	if {$insitu} {
		set ll $ic
		set fnam $evv(COLFILE1)
		set lcnt "inlines"
	} else {
		set ll $oc
		set fnam $evv(COLFILE2)
		set lcnt "outlines"
	}
	$ll delete 0 end
	foreach item $nulst {
		$ll insert end $item
	}
	WriteOutputColumn $fnam $ll $lcnt 1 0 1
}

proc KeepAlgebra {} {
	global colpar tabed evv lmo algebras algname

;# CHECK EXPRESSION

	set lmo "KA"
	lappend lmo 0 0
	set algalg [CheckAlgebraicExpression $colpar 1]
	if {[llength $algalg] != 2} {
		return
	}
	set nlist [lindex $algalg 0]
	set newcolpar [lindex $algalg 1]
	if {[info exists algebras]} {
		foreach {inline algform name} $algebras {
			if {[string match $newcolpar $algform]} {
				Inf "Algebraic Expression Already Stored"
				return
			}
		}
	}
	GetAlgname
	lappend algebras $colpar $newcolpar $algname
	Inf "Saved Algebraic Expression $colpar"
}

proc GetAlgebra {totabed} {
	global pr_algebra colpar lmo record_temacro temacrop temacro evv algebras calgebra pdi oclcnt

	set oclcnt 0
	if {![info exists algebras] || ([llength $algebras] <= 0)} {
		Inf "There Are No Stored Algebraic Formulae"
		if {!$totabed} {
			catch {raise .cpd}
		}
		return
	}
	if {$totabed} {
		set lmo "GA"
		lappend lmo 0 0
		if {$record_temacro} {
			lappend temacro $lmo
			lappend zxz $colpar
			lappend zxz $threshold
			lappend temacrop $zxz
		}
	} elseif {[string length $pdi] <= 0} {
		Inf "Enter A Value(V) First"
		raise .cpd
		return
	}
	set f .algebra

	if [Dlg_Create $f "ALGEBRAIC FORMULAE" "set pr_algebra 0" -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(SBDR)] 
		set f2 [frame $f.2 -borderwidth $evv(SBDR)] 
		set f3 [frame $f.3 -borderwidth $evv(SBDR)] 
		button $f1.sel  -text "Select" -command "set pr_algebra 1" -highlightbackground [option get . background {}]
		button $f1.del  -text "Delete" -command "set pr_algebra 2" -highlightbackground [option get . background {}]
		button $f1.quit -text "Close" -command "set pr_algebra 0" -highlightbackground [option get . background {}]
		pack $f1.sel $f1.del -side left -padx 4
		pack $f1.quit -side right
		label $f2.lab -text "Select Formula with Mouse"
		pack $f2.lab -side top
		Scrolled_Listbox $f3.ll -width 64 -height 20
		pack $f3.ll -side top -fill x -expand true
		pack $f1 -side top -fill x -expand true
		pack $f2 $f3 -side top
		wm resizable .algebra 1 1
		bind $f <Escape>  {set pr_algebra 0}
	}
	$f.3.ll.list delete 0 end
	if {[info exists algebras]} {
		foreach {a b c} $algebras {
			$f.3.ll.list insert end "$c : $a"
		}
	}
	set pr_algebra 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_algebra $f.3.ll.list
	while {!$finished} {
		tkwait variable pr_algebra
		switch -- $pr_algebra {
			1 {
				set i [$f.3.ll.list curselection]
				if {$i < 0} {
					Inf "No Item Selected"
					continue
				} else {
					set val [$f.3.ll.list get $i]
					set k [string first ":" $val]
					incr k 2
					set val [string range $val $k end]
					if {$totabed} {
						set colpar $val
					} else {
						AlgebraCalc $val
					}
				}
				set finished 1
			} 
			2 {
				set i [$f.3.ll.list curselection]
				if {$i < 0} {
					Inf "No Item Selected"
					continue
				} 
				if {[AreYouSure]} {
					$f.3.ll.list delete $i
					set j [expr $i * 3]
					set k $j
					incr k 2
					set algebras [lreplace $algebras $j $k]
					if {[llength $algebras] <= 0} {
						unset algebras
						break
					}
				}
				raise $f
				focus $f
			} 
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {!$totabed} {
		catch {raise .cpd}
	}
}

proc SaveAlgebra {} {
	global algebras evv
	if {![info exists algebras]} {
		return
	}
	set algfile [file join $evv(URES_DIR) $evv(ALGEBRA)$evv(CDP_EXT)]
	set tempfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
	if [catch {open $tempfnam "w"} zit] {
		Inf "Cannot Open Temporary File To Store Algebraic Expressions From Table Editor"
		return
	}
	foreach item $algebras {
		puts $zit $item
	}
	close $zit
	if {[file exists $algfile]} {
		if [catch {file delete $algfile} zit] {
			Inf "Cannot Delete Existing Algebra File '$algfile'\n\nYou Must Delete It And Replace It With '$tempfnam' Now\nIf You Want To Keep Your Algebraic Formulae"
			return
		}
	}
	if [catch {file rename $tempfnam $algfile} zit] {
		Inf "Cannot Rename The Temporary File '$tempfnam' To '$algfile'\n\nYou Must Do This Now If You Want To Keep Your Algebraic Formulae"
		return
	}
}

proc LoadAlgebra {} {
	global algebras evv
	set algfile [file join $evv(URES_DIR) $evv(ALGEBRA)$evv(CDP_EXT)]
	if {![file exists $algfile]} {
		return
	}
	if [catch {open $algfile "r"} zit] {
		Inf "Cannot Open File To Read Your Stored Algebraic Expressions For Table Editor"
		return
	}
	while {[gets $zit item] >= 0} {
		lappend algebras $item
	}
	close $zit
}

proc CheckAlgebraicExpression {str fromtabed} {
	global tabed evv

	if {![info exists str] || ([string length $str] <= 0)} {
		if {$fromtabed} {
			set msg "No algebraic expression entered at 'N'"
			ForceVal $tabed.message.e $msg
		 	$tabed.message.e config -bg $evv(EMPH)
		} else {
			set msg "No algebraic expression entered'"
			Inf $msg
		}
		return {}
	}
	set vlist [CheckAlgebra $str $fromtabed]
	if {[llength $vlist] <= 0} {
		return {}
	}
	set str [lindex $vlist 0]
	set nlist [lindex $vlist 1]
	set outval [list $nlist	$str]
	return $outval
}

#------ Delete row from table

proc RowKeep {n} {
	global outcolcnt tot_outlines colpar threshold tot_inlines incols tabedit_ns tabedit_bind2 lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop
	global col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set tb $tabed.bot
	set tl $tb.itframe.l.list
	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "RK"
	lappend lmo $col_ungapd_numeric $n
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <= 0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {($n != 0)} {
		if {![info exists colpar] || ![IsNumeric $colpar]} {
			ForceVal $tabed.message.e "No (valid) parameter given."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			set colpar [expr int(round($colpar))]
		}
	}
	set OK 1
	switch -- $n {
		0 {
			if {$tot_inlines < 2} {
				ForceVal $tabed.message.e "Deletion will remove the whole table."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set i [$tb.itframe.l.list curselection]
			if {$i < 0} {
				ForceVal $tabed.message.e "No row selected."
	 			$tabed.message.e config -bg $evv(EMPH)
				return
			}
			set nuline [$tl get $i]
		}
	}

	$tb.otframe.l.list delete 0 end
	switch -- $n {
		0 {
			$tb.otframe.l.list insert end $nuline
		}
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set outcolcnt 0
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines 0
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
		return
	} else {
		set outcolcnt $incols
		ForceVal $tabed.bot.otframe.cnt.e $outcolcnt
		set tot_outlines 0
		foreach line [$tb.otframe.l.list get 0 end] {
			incr tot_outlines
			puts $fileot $line
		}
		close $fileot						;#	Write data to file
		ForceVal $tabed.bot.otframe.cnt.e2 $tot_outlines
	}
	EnableOutputTableOptions 1 1
}

proc GetAlgname {} {
	global pr_algname algname alg_name algebras evv
	set f .algname
	if [Dlg_Create $f "Give Name for Algebraic Formula" "set pr_algname 0" -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(SBDR)] 
		set f2 [frame $f.2 -borderwidth $evv(SBDR)] 
		button $f1.ok -text "Keep Name" -command "set pr_algname 1" -highlightbackground [option get . background {}]
		button $f1.qu -text "No Name" -command "set pr_algname 0" -highlightbackground [option get . background {}]
		pack $f1.ok -side left 
		pack $f1.qu -side right
		label $f2.ll -text "Name for Algebraic operation (max 16 characters) "
		entry $f2.e -textvariable alg_name -width 24
		pack $f2.ll $f2.e -side left
		pack $f1 -side top -fill x -expand true
		pack $f2 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_algname 1}
		bind $f <Escape> {set pr_algname 0}
	}
	set finished 0
	set pr_algname 0
	set alg_name ""
	raise $f
	My_Grab 0 $f pr_algname $f.2.e
	while {!$finished} {
		tkwait variable pr_algname
		if {$pr_algname} {
			set len [string length $alg_name]
			if {$len > 16} {
				set alg_name [string range $alg_name 0 15]
				set len 16
			}
			set n 0
			set zz ""
			while {$n < $len} {
				set char [string index $alg_name $n]
				if {[string match $char ":"]} {
					set char ";"
				}
				append zz $char
				incr n
			}
			set alg_name $zz
			set n $len
			set nualgname $alg_name
			while {$n < 16} {
				append nualgname "~"
				incr n
			}
			set OK 1
			if {[info exists algebras] && ([llength $algebras] > 0)} {
				set len [llength $algebras]
				set n 2
				while {$n < $len} {
					if {[string match [lindex $algebras $n] $nualgname]} {
						Inf "This name already exists"
						raise .cpd
						raise $f
						focus $f
						set OK 0
						break
					}
					incr n 3
				}
			}
			if {$OK} {
				break
			} else {
				set alg_name ""
			}
		} else {
			set nualgname ""
			set n 0
			while {$n < 16} {
				append nualgname "~"
				incr n
			}
			break
		}
	}
	set algname $nualgname
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc BatchfileExtend {colmode} {
	global col_files_list outcolcnt tot_outlines evv
	global lmo col_ungapd_numeric tot_inlines ot_has_fnams colinmode tabed ocl

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	HaltCursCop
	set lmo vB
	lappend lmo $col_ungapd_numeric $colmode
	set tb $tabed.bot
	ForceVal $tabed.message.e ""
	$tabed.message.e config -bg [option get . background {}]
	if {$ot_has_fnams} {						 ;#	If new fnames entered, use them - else use previous
		catch {unset col_files_list}
		foreach fnam [$tb.otframe.l.list get 0 end] {
			lappend col_files_list $fnam
		}
	}
	if {![info exists col_files_list] || ([llength $col_files_list] != 2)} {
		ForceVal $tabed.message.e "Wrong number of files selected."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set vectorfile [lindex $col_files_list 1]
	if [catch {open $vectorfile "r"} fId] {
		ForceVal $tabed.message.e "Cannot open the vector file '$vectorfile'"
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set vcnt 0
	while {[gets $fId line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		set itemcnt 0 
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend vectors $item
			}
			incr itemcnt
		}
		if {$itemcnt != 2} {
			ForceVal $tabed.message.e  "line [expr $vcnt + 1] of file '$vectorfile' does not have 2 entries (infilename outfilename)"
	 		$tabed.message.e config -bg $evv(EMPH)
			close $fId
			return
		}
		incr vcnt
	}
	catch {close $fId}
	if {$vcnt < 2} {
		ForceVal $tabed.message.e  "Insufficient data in file $vectorfile"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set inf0  [lindex $vectors 0]
	set outf0 [lindex $vectors 1]
	set fnam [lindex $col_files_list 0]
	if [catch {open $fnam "r"} fId] {
		ForceVal $tabed.message.e  "Cannot open the file '$fnam'"
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set match0 0
	set match1 0
	while {[gets $fId line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				if {!$match0} {
					if {[string match $item $inf0]} {
						set match0 1
					}
				}
				if {!$match1} {
					if {[string match $item $outf0]} {
						set match1 1
					}
				}
				lappend nuline $item
			}
		}
		lappend nulines $nuline
	}
	catch {close $fId}
	if {!($match1 && $match0)} {
		set msg "Cannot find both '$inf0' & '$outf0' in file $fnam"
		ForceVal $tabed.message.e  $msg
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	foreach {inf outf} [lrange $vectors 2 end] {
		if {![file exists $inf]} {
			set msg "File '$inf' (named as an infile in your list) does not exist."
			ForceVal $tabed.message.e  $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[file exists $outf]} {
			set msg "File '$outf' (named as an outfile in your list) already exists."
			ForceVal $tabed.message.e  $msg
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}
	$tb.otframe.l.list delete 0 end
	foreach {inf outf} [lrange $vectors 2 end] {
		foreach line $nulines {
			catch {unset nuline}
			foreach item $line {
				if {[string match $item $inf0]} {
					set item $inf
				} elseif {[string match $item $outf0]} {
					set item $outf
				}
				lappend nuline $item
			}
			$tb.otframe.l.list insert end $nuline
		}
	}
	if [catch {open $evv(COLFILE3) "w"} fileoc] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set tot_outlines 0
		set outcolcnt 0
	} else {
		foreach line [$tb.otframe.l.list get 0 end] {
			if {$tot_outlines == 0} {
				set zline [split $line]
				foreach item $zline {
					if {[string length $item] > 0} {
						incr outcolcnt
					}
				}
			}
			puts $fileoc $line
			incr tot_outlines
		}
		close $fileoc
		EnableOutputTableOptions 0 1
	}
	set colinmode 0
	set ot_has_fnams 0
	ChangeColSelect 0
}

proc HelpFrqMidi {} {

	set msg "MIDI : FREQUENCY CONVERSIONS\n"
	append msg "\n"
	append msg "MIDI DATA = pairs of Time, Midivalue\n"
	append msg "  describe evolution of Pitch (as Midi value) over time.\n"
	append msg "  Midi can be fractional: data not restricted to tempered scale\n"
	append msg "  and pitch GLIDES from one value to the next.\n"
	append msg "NOTATABLE TIMED MIDI DATA = pairs of Time, Midivalue\n"
	append msg "  As 'Midi Data' (above) but\n"
	append msg "  each pitch value SUSTAINED until next value appears.\n"
	append msg "  Can be used to represent timed note-events.\n"
	append msg "QUANTISED VALUES = (Frq or Midi) confined to tempered scale.\n"
	append msg "SMOOTHED VALUES  = remove brief pitch excursions from steady vals.\n"
	append msg "VOCAL RANGE  = 2 8vas below middle C, to 2 8vas above, retained.\n"
	append msg "  Other pitches removed.\n\n"
	append msg "Smoothing & Vocal Range useful for correcting pitch-data\n"
	append msg "extracted directly from human speech.\n"
	append msg "data can be further refined from 'MODIFY' option in\n"
	append msg "'PITCH SEQUENCE MARKERS' on MUSIC TESTBED.\n"
	Inf $msg
}

proc IncIncolget {down} {
	global incolget incols
	if {![IsNumeric $incolget]} {
		return
	}
	set i $incolget
	incr i -1
	if {$down} {
		incr  i -1
	} else {
		incr i
	}
	set i [expr $i % $incols]
	incr i
	set incolget $i
}

proc HelpBalance {} {
	set msg "DERIVE ENVELOPE FILES FROM BALANCE FILE\n"
	append msg "\n"
	append msg "Balance files gives relative level of K files in a mix, as they vary over time.\n"
	append msg "This process generates a loudness-envelope file for each of the K files.\n"
	append msg "These envelopes could be applied to the sources, to produce K new files\n"
	append msg "which, when mixed, woudl produce the same result as the originasl balance file.\n"
	append msg "\n"
	append msg "DERIVE BALANCE FILE BY GATING (at N) ENVELOPE FILE\n"
	append msg "\n"
	append msg "This procedure first gates the envelope (reducing all values below N to zero),\n"
	append msg "then sets all values greater than zero to 1.0\n"
	append msg "e.g. if a signal has very low frequency bumps which a filter will not remove, \n"
	append msg "1) pass source through a lo-pass filter to isoate these 'bumps'\n"
	append msg "2) extract the envelope of these bumps.\n"
	append msg "3) Use this procedure to generate a gate envelope to finely splice out these 'bumps'\n"
	append msg "OR, if the source with 'bumps' was derived from a 'bumpfree' sound \n"
	append msg "4) Use the final envelope as a balance file to switch between the 'bumpy' sound\n"
	append msg "and the 'bumpfree' source, just at those moments where the bumps occur.\n"
	append msg "\n"
	append msg "DERIVE BALANCE FILE FROM PITCH DATA WITH PITCH ZEROS\n"
	append msg "\n"
	append msg "This procedure first replaces all no-pitch or no-signal markers\n"
	append msg "(marked as values below zero) with zero,\n"
	append msg "then sets all values greater than zero to 1.\n"
	append msg "It also constructs a viable 'shoulder' around singular no-pitch(signal) areas.\n"
	append msg "The resulting envelope could be applied to the source sound,\n"
	append msg "to gate out no-signal and no-pitch areas..\n"
	append msg "\n"
	append msg "DERIVE GATING ENVELOPE FROM BEAT MARKERS\n"
	append msg "\n"
	append msg "Generates envelope to gate out specific beats in sound contaning distinct events.\n"
	append msg "Provide a 2-column table, where column 1 is the beat numbers (successively)\n"
	append msg "And column 2 marks them as On (1) or Off (0).\n"
	append msg "Parameter N is a MM.\n"
	append msg "Threshold is offset of 1st beat in soundfile to which envelope to be applied.\n"
	Inf $msg
}

proc ValidSrate {srate} {
	set srate_r [expr int(round($srate))]
	if {$srate_r != $srate} {
		return 0
	}
	switch -- $srate_r {
		24000 -
		32000 -
		44100 -
		48000 -
		88200 -
		96000 {
			return 1
		}
	}
	return 0
}

proc TabSnack {} {
	global tabed CDPsnack outcolcnt evv
	set otab $tabed.bot.otframe.l.list
	$otab delete 0 end
	SnackDisplay $evv(SN_TIMESLIST) $otab $evv(TIME_OUT) 0
	if {[$otab index end] >= 1} {
		set fnam $evv(COLFILE3)
		if [catch {open $fnam "w"} fId] {
			$otab delete 0 end
			ForceVal $tabed.message.e  "Cannot open temporary file $fnam"
	 		$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach val [$otab get 0 end] {
			puts $fId $val
		}
		close $fId
		set outcolcnt [$otab index end]
		EnableOutputTableOptions 0 1
	}
}

proc GetEnvPeaks {env} {
	set outtimes {}
	foreach line $env {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		catch {unset nuline}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] >= 0} {
				lappend nuline $item
			}
		}
		if {![info exists nuline] || ([llength $nuline] != 2)} {
			return {}
		}
		lappend times [lindex $nuline 0]
		lappend vals [lindex $nuline 1]
	}
	set lastval [lindex $vals 0]
	set cnt 0
	set gotpeak 0
	foreach val [lrange $vals 1 end] {
		if {$val < $lastval} {
			if {!$gotpeak} {
				lappend peaks $cnt
				set gotpeak 1
			}
		} elseif {$val > $lastval} {
			set gotpeak 0
		}
		set lastval $val
		incr cnt
	}	
	if {!$gotpeak} {
		lappend peaks [expr $cnt - 1]	
	}
	foreach peak $peaks {
		lappend outtimes [lindex $times $peak]
	}
	return $outtimes
}

#--- Quantise pitch/midi tables

proc QuantiseBrk {colmode} {
	global colpar threshold CDPcolrun docol_OK threshtype evv wstk tot_outlines
	global tot_inlines orig_inlines tabed armadillo
	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	ForceVal $tabed.message.e ""
	$tabed.message.e config -bg [option get . background {}]

	HaltCursCop
	set tb $tabed.bot
	switch -- $colmode {
		"Th" -
		"TM" -
		"ThS" -
		"TMS" {
			if {([string length $threshold] > 0) && [IsNumeric $threshold]} {
				if {$threshtype} {
					set msg "Temper Values Around Reference Value $threshold ??"
				}
				set choice [tk_messageBox -message $msg -type yesno -parent [lindex $wstk end] -icon question]
				if {$choice == "no"} {
					set threshold ""
				}
			}
		}
	}
	set colparam $colmode
	if {($colmode == "Th") || ($colmode == "ThS") || ($colmode == "Zh") || ($colmode == "ZhS")} {
		set subOK 0
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			set val [lindex $line end]
			if {$val < $evv(FLTERR)} {
				if {(($colmode == "Th") || ($colmode == "ThS")) && !$subOK} {
					set msg "(Subzero) Pitchmarkers Found: Preserve These ??"
					set choice [tk_messageBox -message $msg -type yesno -parent [lindex $wstk end] -icon question]
					if {$choice == "yes"} {
						set subkOK 1
						continue
					}
				}
				ForceVal $tabed.message.e "The value '$val' is out of FRQ range."
		 		$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	}
	if {($colmode == "Zh") || ($colmode == "ZhS")} {
		if {$colpar < $evv(FLTERR) || $colpar > 12000.0} {
			ForceVal $tabed.message.e "The N value '$val' is out of FRQ reference value range."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
	}	
	if {[string match "Th" $colmode] || [string match "ThS" $colmode] || [string match "TM" $colmode] || [string match "TMS" $colmode]} {
		if {[info exists threshold] && ([string length $threshold] > 0)} {
			if {![IsNumeric $threshold]} {
				ForceVal $tabed.message.e "Threshold value invalid"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
			if {($colmode == "Th") || ($colmode == "ThS")} {
				if {($threshold < .1)  || ($threshold > 12000.0)} {
					ForceVal $tabed.message.e "Threshold value out of range"
			 		$tabed.message.e config -bg $evv(EMPH)
					return
				}
			} elseif {($threshold < 0)  || ($threshold > 127.0)} {
				ForceVal $tabed.message.e "Threshold value out of range"
			 	$tabed.message.e config -bg $evv(EMPH)
				return
			}
		}
	}
	catch {unset nutimes}
	catch {unset nuvals}
	catch {unset intimes}
	catch {unset armadillo}
	if {$colmode == "NO"} {
		set done 0
		set ccnt 0
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			lappend nutimes [lindex $line 0]
			lappend nuvals [lindex $line end]
			incr ccnt
		}
		set j 0
		set m 1
		set n 2
		while {$n < $ccnt} {
			set pretim  [lindex $nutimes $j]
			set lasttim [lindex $nutimes $m]
			set thistim [lindex $nutimes $n]
			set preval  [lindex $nuvals $j]
			set lastval [lindex $nuvals $m]
			set thisval [lindex $nuvals $n]
			if {($lastval != $preval) && ($thisval != $lastval)} {	;#	ELIMINATE SINGLE VALS
				set nutime [expr $thistim - 0.01]
				if {$nutime > $pretim} {
					set nutimes [lreplace $nutimes $j $j $nutime]
				}
				set nutimes [lreplace $nutimes $m $m]
				set nuvals [lreplace $nuvals $m $m]
				incr ccnt -1
			} elseif  {($lastval == $preval) && ([expr $lasttim - $pretim] < .1)}  {	;#	ELIMINATE TOO SHORT VALS
				set done 1
				set nutimes [lreplace $nutimes $n $n $pretim]
				set nutimes [lreplace $nutimes $j $m]
				set nuvals [lreplace $nuvals $j $m]
				incr ccnt -2
			} else {
				incr j
				incr m
				incr n
			}
		}
		if {!$done} {
			ForceVal $tabed.message.e "No ornaments found"
			$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
		} else {
			set docol_OK 1
		}
	} else {
		set sustainer 0
		if {[string length $colmode] > 2} {
			set sustainer 1
			set colmode [string range $colmode 0 1]
		}
		if {![TestColParam $colmode]} {
			ForceVal $tabed.message.e "Parameter value missing"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		if {[info exists colpar] && ([string length $colpar] > 0)} {
			append colparam $colpar
		}
		if [catch {open $evv(COLFILE1) "w"} zit] {
			ForceVal $tabed.message.e "Cannot open temporary file"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		foreach line [$tb.itframe.l.list get 0 end] {
			set line [string trim $line]
			set line [split $line]
			lappend intimes [lindex $line 0]
			puts $zit [lindex $line end]
		}
		close $zit
		set colcmd [file join $evv(CDPROGRAM_DIR) columns]
		lappend colcmd $evv(COLFILE1)
		lappend colcmd -$colparam							;#	Check for threshold val, where optional
		if {[string match "Th" $colmode] || [string match "TM" $colmode] } {
			if {[info exists threshold] && ([string length $threshold] > 0)} {
				set thresh_val "+"
				append thresh_val $threshold
				lappend colcmd $thresh_val
			}
		}
		$tb.otframe.l.list delete 0 end
		set docol_OK 0
		set sloom_cmd [linsert $colcmd 1 "#"]
		if [catch {open "|$sloom_cmd"} CDPcolrun] {
			ErrShow "$CDPcolrun"
		} else {
   			fileevent $CDPcolrun readable "RetainNewColumn"
			vwait docol_OK
		}
		if {$docol_OK} {
			if {$sustainer} {
				set ccnt 0
				foreach time $intimes val $armadillo {
					if {$ccnt} {
						if {$val != $lastval} {
							set nutime [expr $time - 0.01]
							if {$nutime > $lasttime} {
								lappend nutimes $nutime
								lappend nuvals $lastval
							}
						}
					}
					lappend nutimes $time
					lappend nuvals $val
					set lastval $val
					set lasttime $time
					incr ccnt
				}
			} else {
				set nutimes $intimes
				set nuvals $armadillo
			}
		}
	}
	if {$docol_OK} {
		set len [llength $nuvals]
		# REMOVE TRIPLES AND MORE
		set j 0
		set m 1
		set n 2
		while {$n < $len} {
			set preval  [lindex $nuvals $j]
			set lastval [lindex $nuvals $m]
			set thisval [lindex $nuvals $n]
			if {($lastval == $preval) && ($thisval == $lastval)}  {
				set nutimes [lreplace $nutimes $m $m]
				set nuvals  [lreplace $nuvals  $m $m]
				incr len -1
			} else {
				incr j
				incr m
				incr n
			}
		}
		catch {unset armadillo}
		foreach time $nutimes val $nuvals {
			set line [list $time $val]
			lappend armadillo $line
		}
		$tb.otframe.l.list delete 0 end
		set tot_outlines 0
		foreach line $armadillo {
			$tb.otframe.l.list insert end $line
			incr tot_outlines 
		}
		set outcolcnt 2
		if {[WriteOutputTable $evv(LINECNT_RESET)]} {
			EnableOutputTableOptions 0 1
		}
	} else {
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set tot_outlines 0
		set outcolcnt 0
	}
}

#------ Display new column resulting from editing

proc RetainNewColumn {} {
	global CDPcolrun docol_OK tabed evv armadillo

	if [eof $CDPcolrun] {
		set docol_OK 1
		catch {close $CDPcolrun}
		return
	} else {
		gets $CDPcolrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match INFO:* $line] {
			set line [string range $line 6 end] 
			lappend armadillo $line
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
		} elseif [string match END:* $line] {
			set docol_OK 1
			catch {close $CDPcolrun}
			return
		} else {
			set line "Invalid Message ($line) received from program."
			ForceVal $tabed.message.e $line
		 	$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
			catch {close $CDPcolrun}
			return
		}
	}
	update idletasks
}			

proc PlainBob {} {
	global tabed
	set tb $tabed.bot
	set cnt 0
	foreach val [$tb.icframe.l.list get 0 end] {
		lappend vals $val
		incr cnt
	}
	set cnt_less_one [expr $cnt - 1]
	foreach val $vals {
		lappend nuvals $val
	}
	set m 0
	while {$m < $cnt_less_one} {
		set k 0
		while {$k < $cnt_less_one} {
			set vals [BellPerm 1 $vals $cnt]
			foreach val $vals {
				lappend nuvals $val
			}
			set vals [BellPerm 2 $vals $cnt]
			foreach val $vals {
				lappend nuvals $val
			}
			incr k
		}
		set vals [BellPerm 1 $vals $cnt]
		foreach val $vals {
			lappend nuvals $val
		}
		set vals [BellPerm 3 $vals $cnt]
		foreach val $vals {
			lappend nuvals $val
		}
		incr m
	}
	return $nuvals
}

proc BellPerm {type vals cnt} {
	switch -- $type {
		1 {
			set j 0
			set k 1
		}
		2 {
			set j 2
			set k 1
		}
		3 {
			set j 2
			set k 3
		}
	}
	while {$j < $cnt} {
		set val_j [lindex $vals $j]
		set val_k [lindex $vals $k]
		set vals [lreplace $vals $j $j $val_k]
		set vals [lreplace $vals $k $k $val_j]
		incr j 2
		incr k 2
	}
	return $vals
}

proc MixtimeWarp {mixtimes warplines} {
	global evv
	set zero_inserted 0
	set firstmixtime [lindex $mixtimes 0]
	if {$firstmixtime != 0.0} {		;#	FORCE MIXTIME VALUE AT ZERO TIME
		if {$firstmixtime <= $evv(FLTERR)} { 
			set mixtimes [lreplace $mixtimes 0 0 0.0]
		} else {
			set mixtimes [concat 0.0 $mixtimes]
			set zero_inserted 1
		}
	}
	set firstwarptime [lindex [lindex $warplines 0] 0]
	if {$firstwarptime != 0.0} {		;#	FORCE WARPTIME VALUE AT ZERO TIME
		set warpline [list 0.0 [lindex [lindex $warplines 0] 1]]
		if {$firstwarptime <= $evv(FLTERR)} { 
			set warplines [lreplace $warplines 0 0 $warpline]
		} else {
			set warplines [linsert $warplines 0 $warpline]
		}
	}
	set lenmix  [llength $mixtimes]
	set lenwarp [llength $warplines]
	set lenwarp_less_one [expr $lenwarp - 1]
	set lastwarp [lindex [lindex $warplines $lenwarp_less_one] 1]
	set sum 0.0
	set n 1
	set pre_n 0
	set m 0
	set outmixtimes [lindex $mixtimes 0]
	while {$n < $lenmix} {
		set mixtime [lindex $mixtimes $n]
		while {$m < $lenwarp} {
			set warptime [lindex [lindex $warplines $m] 0]
			if {$warptime > $mixtime} {
				break
			}
			incr m
		}
		if {$m < $lenwarp} {
			set nexttime [lindex [lindex $warplines $m] 0]
			set nextval  [lindex [lindex $warplines $m] 1]
			incr m -1
			set thistime [lindex [lindex $warplines $m] 0]
			set thisval  [lindex [lindex $warplines $m] 1]
			incr m
			set timestep [expr $nexttime - $thistime]
			set frac [expr double($mixtime - $thistime)/double($timestep)]
			set valstep [expr $nextval - $thisval]
			set val [expr ($valstep * $frac) + $thisval]
		} else {
			set val $lastwarp
		}
		set gap [expr [lindex $mixtimes $n] - [lindex $mixtimes $pre_n]]
		set val [expr $val * $gap]
		set sum [expr $sum + $val]
		lappend outmixtimes $sum
		incr n
		incr pre_n
	}
	if {$zero_inserted} {
		set outmixtimes [lrange $outmixtimes 1 end]
	}
	return $outmixtimes
}

proc MixLevelWarp {mlevels mixtimes warplines} {
	set lasttime -1
	set lenmix  [llength $mixtimes]
	set n 0
	while {$n < $lenmix} {
		set mixtime [lindex $mixtimes $n]
		if {$mixtime < $lasttime} {
			return {}
		}
		set lasttime $mixtime
		incr n
	}
	set lenmix  [llength $mixtimes]
	set lenwarp [llength $warplines]
	set lenwarp_less_one [expr $lenwarp - 1]
	set lastwarp [lindex [lindex $warplines $lenwarp_less_one] 1]
	set n 0
	set m 0
	set outmixtimes [lindex $mixtimes 0]
	while {$n < $lenmix} {
		set mixtime [lindex $mixtimes $n]
		set mixlevel [lindex $mlevels $n]
		while {$m < $lenwarp} {
			set warptime [lindex [lindex $warplines $m] 0]
			if {$warptime > $mixtime} {
				break
			}
			incr m
		}
		if {$m < $lenwarp} {
			set nexttime [lindex [lindex $warplines $m] 0]
			set nextval  [lindex [lindex $warplines $m] 1]
			if {$m > 0} {
				incr m -1
				set thistime [lindex [lindex $warplines $m] 0]
				set thisval  [lindex [lindex $warplines $m] 1]
				incr m
				set timestep [expr $nexttime - $thistime]
				set frac [expr double($mixtime - $thistime)/double($timestep)]
				set valstep [expr $nextval - $thisval]
				set val [expr ($valstep * $frac) + $thisval]
			} else {
				set val $nextval
			}
		} else {
			set val $lastwarp
		}
		catch {unset nulevel}
		foreach lev $mixlevel {
			set lev [DecPlaces [expr $lev * $val] 4]
			lappend nulevel $lev
		}
		set mlevels [lreplace $mlevels $n $n $nulevel]
		incr n
	}
	return $mlevels
}

proc ExcludeSndsFromMix {fnams} {
	global tabed evv pa
	set mix1 [lindex $fnams 0]
	set mix2 [lindex $fnams 1]
	if [catch {open $mix2 "r"} zit] {
		ForceVal $tabed.message.e  "Cannot open file $mix2"
	 	$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set line [StripCurlies $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match ";" [string index $line 0 ]]} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend snds $item
				break
			}
		}
	}
	if {![info exists snds]} {
		ForceVal $tabed.message.e  "No sounds found in $mix2"
	 	$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	if [catch {open $mix1 "r"} zit] {
		ForceVal $tabed.message.e  "Cannot open file $mix1"
	 	$tabed.message.e config -bg $evv(EMPH)
		return 0
	}
	if {$pa($mix1,$evv(FTYP)) == $evv(MIX_MULTI)} {
		set gotchancnt 0
	} else {
		set gotchancnt 1
	}
	set activelines 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set line [StripCurlies $line]
		if {[string length $line] <= 0} {
			continue
		}
		set iscomment 0
		if {[string match ";" [string index $line 0 ]]} {
			set iscomment 1
		}
		if {!$gotchancnt} {
			lappend nulines $line
			set gotchancnt 1
			continue
		}
		set line [split $line]
		set OK 1
		set cnt 0
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				if {($cnt == 0) && !$iscomment} {
					set snd $item
					if {[lsearch $snds $snd] >= 0} {
						set OK 0
						break
					}
				}
				lappend nuline $item
			}
			incr cnt
		}
		if {$OK} {
			lappend nulines $nuline
			if {!$iscomment} {
				incr activelines
			}
		}
	}
	if {![info exists nulines]} {
		ForceVal $tabed.message.e  "No sounds in $mix1 that are not in $mix2"
	 	$tabed.message.e config -bg $evv(EMPH)
		return 0
	} elseif {!$activelines} {
		set msg "There Are No Unmuted Lines Now Remaining In File $mix1: Keep It ??"
		set choice [tk_messageBox -message $msg -type yesno -parent [lindex $wstk end] -icon question]
		if {$choice == "no"} {
			return 0
		}
	}
	set to $tabed.bot.otframe.l.list
	$to delete 0 end
	foreach line $nulines {
		$to insert end $line
	}
	return 1
}

#----- Given a string of form CD#F (upper case note-names, with or without '#').
#----- Define harmonicity (score 1/2 for semitone, 1 for tone, 2 for anything larger) ... then divide by note-length of string
#----- Semitone at bottom of HF score only 1/4

proc ScoreHarmonicity {str} {
	set len [string length $str]
	set n 0
	while {$n < $len} {
		set val [string index $str $n]
		switch -- $val {
			"C" {
				lappend midivals 0
			}
			"D" {
				lappend midivals 2
			}
			"E" {
				lappend midivals 4
			}
			"F" {
				lappend midivals 5
			}
			"G" {
				lappend midivals 7
			}
			"A" {
				lappend midivals 9
			}
			"B" {
				lappend midivals 11
			}
			"#" {
				set lastval [lindex $midivals end]
				incr lastval
				set midivals [lreplace $midivals end end $lastval]
			}
		}
		incr n
	}
	set len [llength $midivals]
	set n 0
	set m 1
	set hmncty 0.0
	while {$m < $len} {
		set diff [expr [lindex $midivals $m] - [lindex $midivals $n]]
		if {$diff < 0} {
			set diff [expr $diff + 12]
		}
		switch -- $diff {
			1 {
				if {$m == 1} {
					set hmncty [expr $hmncty + 0.25]
				} else {
					set hmncty [expr $hmncty + 0.5]
				}
			}
			2 {
				set hmncty [expr $hmncty + 1.0]
			}
			default {
				set hmncty [expr $hmncty + 2.0]
			}
		}
		incr n
		incr m
	}
	set hmncty [expr $hmncty /double([expr $len - 1])]
	set hmncty [DecPlaces $hmncty 3]
	return $hmncty
}

#---- search HF code string for specific intervals

proc ContainsIntervals {str ints_to_find adj} {
	set len [string length $str]
	set intlen [llength $ints_to_find]
	set n 0
	while {$n < $len} {
		set val [string index $str $n]
		switch -- $val {
			"C" {
				lappend midivals 0
			}
			"D" {
				lappend midivals 2
			}
			"E" {
				lappend midivals 4
			}
			"F" {
				lappend midivals 5
			}
			"G" {
				lappend midivals 7
			}
			"A" {
				lappend midivals 9
			}
			"B" {
				lappend midivals 11
			}
			"#" {
				set lastval [lindex $midivals end]
				incr lastval
				set midivals [lreplace $midivals end end $lastval]
			}
		}
		incr n
	}
	set midilen [llength $midivals]
	if {$midilen < 2} {
		return 0
	}
	if {$adj} {
		set foundintslen [expr $midilen - 1]
		if {$foundintslen < $intlen} {
			return 0
		}
		set lastmidi [lindex $midivals 0]
		set n 1
		while {$n < $midilen} {
			set thismidi [lindex $midivals $n]
			set thisint [expr abs($thismidi - $lastmidi)]
			lappend ints_in_HF $thisint
			set lastmidi $thismidi
			incr n
		}
	} else {
		set ints_in_HF {}
		set len_less_one [expr $midilen - 1]
		set n 0
		while {$n < $len_less_one} {
			set lastmidi [lindex $midivals $n]
			set m $n
			incr m
			while {$m < $midilen} {
				set thismidi [lindex $midivals $m]
				set thisint [expr abs($thismidi - $lastmidi)]
				lappend ints_in_HF $thisint
				incr m
			}
			incr n
		}
		set foundintslen [llength $ints_in_HF]
		if {$foundintslen < $intlen} {
			return 0
		}
	}
	set n 0
	while {$n < $intlen} {
		set int [lindex $ints_to_find $n]
		set k [lsearch $ints_in_HF $int]
		if {$k >= 0} {
			incr intlen -1
			if {$intlen == 0} {
				return 1
			} else {
				set ints_in_HF [lreplace $ints_in_HF $k $k]
				set ints_to_find [lreplace $ints_to_find $n $n]
				incr n -1
			}
		}
		incr n
	}
	return 0
}

#---- Extract individual notenames from a HF string e.g. C#ADF# ->C#  A   D   F#

proc ExtractNoteSet {str} {
	set len [string length $str]
	set outval [string index $str 0]
	set n 1
	set done 0
	while {$n < $len} {
		set thischar [string index $str $n]
		if {[string match $thischar "#"]} {
			append outval "#"
			lappend outvals $outval
			set done 1
		} else {
			if {!$done} {
				lappend outvals $outval
			}
			set outval $thischar
			set done 0
		}
		incr n
	}
	if {!$done} {
		lappend outvals $outval
	}
	return $outvals
}

#---- Convert HF string to ascii filename for associated sndlist e.g. A#BC# --> ashbcsh

proc SharpToAscii {str} {
	set outstr ""
	set len [string length $str]
	set n 0
	while {$n < $len} {
		set thischar [string index $str $n]
		if {[string match $thischar "#"]} {
			set thischar "sh"
		} else {
			set thischar [string tolower $thischar]
		}
		append outstr $thischar

		incr n
	}
	return $outstr
}

#---- name of sndlist assocd with HF , to HF name e.g. ashbcsh --> A#BC# 

proc AsciiToSharp {str} {
	set outstr ""
	set startsharp 0
	set gotsharp 0
	set str [file rootname [file tail $str]]
	set len [string length $str]
	set n 0
	while {$n < $len} {
		set thischar [string index $str $n]
		if {$startsharp} {
			if {[string match $thischar "h"]} {
				append outstr "#"
				set startsharp 0
				set gotsharp 1
			} else {
				return ""
			}
		} else {
			if {[regexp {^[a-g]$} $thischar]} {
				append outstr [string toupper $thischar]
				set gotsharp 0
			} elseif {[string match $thischar "s"]} {
				if {$gotsharp} {
					return ""
				}
				set startsharp 1
			} else {
				return ""
			}
		}
		incr n
	}
	return $outstr
}

#--- String is valid HF name (i.e. A-Ga-g +- "#")

proc IsHFstr {str} {
	set len [string length $str]
	set havenotename 0
	set n 0
	while {$n < $len} {
		set thischar [string index $str $n]
		if {[regexp {^[A-Ga-g]$} $thischar]} {
			set havenotename 1
		} elseif {[string match $thischar "#"]} {
			if {$havenotename} {
				set havenotename 0
			} else {
				return 0
			}
		} else {
			return 0
		}
		incr n
	}
	return 1
}

#------ Move rows within table

proc RowsMove {} {
	global outcolcnt tot_outlines colpar threshold tot_inlines incols tabedit_ns tabedit_bind2 lmo col_ungapd_numeric evv
	global record_temacro temacro temacrop
	global col_tabname col_infnam tabed

	HaltCursCop
	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set tb $tabed.bot
	set kt $tabed.bot.ktframe

	ForceVal $tabed.message.e ""
 	$tabed.message.e config -bg [option get . background {}]

	set lmo "RM"
	lappend lmo $col_ungapd_numeric 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	if {![info exists tot_inlines] || ($tot_inlines <= 0) || ![info exists incols] || ($incols <= 0)} {
		ForceVal $tabed.message.e "No input table exists."
	 	$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {![info exists colpar] || ![IsNumeric $colpar]} {
		ForceVal $tabed.message.e "No (valid) parameter given."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set i [$tb.itframe.l.list curselection]
	if {![info exists i] || ($i < 0)} {
		ForceVal $tabed.message.e "No row selected with cursor."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}			
	if {[info exists threshold] && ([string length $threshold] > 0)} {
		if {![IsNumeric $threshold] || ($threshold < 1)} {
			ForceVal $tabed.message.e "Threshold parameter (number of rows to move) invalid."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		} else {
			set threshold [expr int(round($threshold))]
		}
		set endline [expr $i + $threshold]
		if {$endline > $tot_inlines} {
			set msg "All Rows After Cursor-Selected Row Will Be Moved: OK ??"
			set choice [tk_messageBox -message $msg -type yesno -parent [lindex $wstk end] -icon question]
			if {$choice == "no"} {
				return
			}
			set endline $tot_inlines
		} 
	} else {
		set endline $tot_inlines
	}
	set cursorline [$tb.itframe.l.list get $i]
	set thistime [lindex $cursorline 0]
	if {$colpar < 0.0} {
		set nustart [expr $thistime + $colpar]
		if {$nustart < 0.0} {
			ForceVal $tabed.message.e "Cannot move lines back this far."
		 	$tabed.message.e config -bg $evv(EMPH)
			return
		}
	} else {
		set nustart $thistime
	}
	set i 0 
	foreach line [$tb.itframe.l.list get 0 end] {
		set thattime [lindex $line 0]
		if {$thattime < $nustart} {
			lappend outlines $line
		} elseif {$thattime >= $thistime} {
			if {$i < $endline} {
				set thattime [expr $thattime + $colpar]
				set nuline [concat $thattime [lrange $line 1 end]]
				lappend outlines $nuline
			} else {
				lappend outlines $line
			}
		}
		incr i
	}
	$tb.otframe.l.list delete 0 end
	foreach line $outlines {
		$tb.otframe.l.list insert end $line
	}
	if [catch {open $evv(COLFILE3) "w"} fileot] {
		ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
	 	$tabed.message.e config -bg $evv(EMPH)
		$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		set tot_outlines 0
	} else {
		set outcolcnt $incols
		set tot_outlines 0
		foreach line [$tb.otframe.l.list get 0 end] {
			incr tot_outlines
			puts $fileot $line
		}
		close $fileot						;#	Write data to file
	}
	EnableOutputTableOptions 1 1
}

proc ReplaceCommas {str} {

	set len [string length $str]
	set n 0
	set nustr ""
	while {$n < $len} {
		set char [string index $str $n]
		if {[string match $char ","]} {
			set char "_"
		}
		append nustr $char
		incr n
	}
	return $nustr
}

proc ConverDataNameToCDPFileFormat {fnam} {
	global evv
	set zdir [file dirname $fnam]
	if {[string match $zdir "."]} {
		set zdir ""
	}
	set fnam [file tail $fnam]
	set fnam [ReplaceDots $fnam]
	set ext [file extension $fnam]
	set fnam [file rootname $fnam]
	append fnam $evv(TEXT_EXT)
	set fnam [file join $zdir $fnam]
	set fnam [string tolower $fnam]
	return $fnam
}

proc ReplaceDotsAndTrailingZerosInValue {val} {
	set val [split $val "."]
	set k [llength $val]
	if {$k > 1} {
		foreach item $val {
			set item [string trim $item]
			if {[string length $item] > 0} {
				append nuval $item "p"
			}
		}
		set len [string length $nuval]
		incr len -2
		set val [string range $nuval 0 $len]
		set len [string length $val]
		incr len -1
		while {[string match [string index $val $len] "0"]} {
			incr len -1
			set val [string range $val 0 $len]
		}
		if {[string match [string index $val end] "p"]} {
			set len [string length $val]
			incr len -2
			set val [string range $val 0 $len]
		}
	}
	return $val
}

proc TruncVecVal {str} {		;#	Trucate 2 two dec places (if appropriate)
	set atpoint [string first "p" $str]
	if {$atpoint >= 0} {
		set len [string length $str]
		if {[expr $len - $atpoint] >= 3} {
			incr atpoint 2
			set str [string range $str 0 $atpoint]
		}
	}
	return $str
}

#--- Display local minima and maxima of sequence	

proc Minimax {} {
	global threshold outlines tedit_message last_oc evv
	global inlines tot_inlines tabed last_cr col_ungapd_numeric lmo insitu colpar record_temacro temacro temacrop

	HaltCursCop

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set lmo IA
	lappend lmo $col_ungapd_numeric 0
	set tb $tabed.bot

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {$insitu} {
		set ll $tb.icframe.l.list
		set lcnt "inlines"
		set zfile $evv(COLFILE1)
	} else {
		set ll $tb.ocframe.l.list
		set lcnt "outlines"
		set zfile $evv(COLFILE2)
	}
	if {!$insitu} {
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		DisableOutputColumnOptions 
	}
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}
	catch {unset OK}
	set nn 0
	foreach item [$tb.icframe.l.list get 0 end] {
		switch --  $nn {
			0 {
				lappend minimax $item
				set ismax 0
			}
			default {
				switch -- $ismax {
					0 {				;#	level
						if {$item > $lastval} {
							set ismax 1
						} elseif {$item < $lastval} {
							set ismax -1
						}
					}
					1 {								;#	previously ascending
						if {$item < $lastval} {		;#	now descending
							lappend minimax $lastval
							set ismax -1
						}
					}
					-1 {							;#	previously descending
						if {$item > $lastval} {		;#	now ascending
							lappend minimax $lastval
							set ismax 1
						}
					}
				}
			}
		}
		set lastval $item
		incr nn
	}
	lappend minimax [$tb.icframe.l.list get end]
	$ll delete 0 end
	foreach val $minimax {
		$ll insert end $val
	}
	WriteOutputColumn $zfile $ll $lcnt 1 0 1
}

proc TabEdBigFiles {} {
	global tabed pr_tabedbigf evv bigedold
	catch {unset bigedold}
	foreach fnam [$tabed.bot.fframe.l.list get 0 end] {
		lappend nulist $fnam
	}
	if {![info exists nulist] || ([llength $nulist] <= 0)} {
		Inf "NO FILES IN TABLE EDITOR LISTING"
		return
	}
	set f .tabedbigf
	if [Dlg_Create $f "Table Editor Files List" "set pr_tabedbigf 0" -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(SBDR)] 
		set f2 [frame $f.2 -borderwidth $evv(SBDR)] 
		button $f1.st -text "Sort" -command "SortBigEd 0" -width 8
		button $f1.re -text "Restore" -command "SortBigEd 1" -width 8
		button $f1.qu -text "Quit" -command "set pr_tabedbigf 0"
		pack $f1.st $f1.re -side left -padx 2
		pack $f1.qu -side right
		pack $f1 -side top -fill x -expand true
		Scrolled_Listbox $f2.ll -width 120 -height 20 -selectmode single
		pack $f2.ll -side top
		pack $f2 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_tabedbigf 0}
		bind $f2.ll.list <ButtonRelease-1> {TabEdBigSelect %W}
	}
	.tabedbigf.2.ll.list delete 0 end
	foreach fnam $nulist {
		.tabedbigf.2.ll.list insert end $fnam
	}
	set pr_tabedbigf 0
	raise $f
	My_Grab 0 $f pr_tabedbigf
	tkwait variable pr_tabedbigf
	My_Release_to_Dialog $f
	destroy $f
}

proc TabEdBigSelect {w} {
	global colinmode pr_tabedbigf
	switch -- $colinmode {
		0 {
			GetTableFromFilelist $w -1 0
			set pr_tabedbigf 0
		}
		1 {
			GetFileWithASingleColumn $w
			set pr_tabedbigf 0
		}
		2 {
			GetSeveralTablesFromFilelist $w
		}
	}
}

proc SortBigEd { restore} {
	global tabed bigedold
	if {$restore} {
		if {![info exists bigedold]} {
			return
		}
		set nulist $bigedold
	} else {
		foreach fnam [$tabed.bot.fframe.l.list get 0 end] {
			lappend nulist $fnam
		}
		set bigedold $nulist
		set nulist [lsort $nulist]
	}
	.tabedbigf.2.ll.list delete 0 end
	foreach fnam $nulist {
		.tabedbigf.2.ll.list insert end $fnam
	}
}

proc NewGetMaxsamplesOnWkspace {} {
	global ocl_wksp wl evv pa maxsamp_line CDPmaxId done_maxsamp pr_oclwksp
	catch {unset ocl_wksp}
	set ilist [$wl curselection]
	if {([llength $ilist] > 1) || (([llength $ilist] == 1) && ($ilist != -1))} {
		foreach i $ilist {
			set fnam [$wl get $i]
			if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
				lappend fnams $fnam
			}
		}
		if {![info exists fnams]} {
			Inf "No soundfiles selected"
			return
		}
	} else {
		Inf "NO Files selected"
		return
	}
	foreach fnam $fnams {
		if {![info exists pa($fnam,$evv(MAXREP))]} {
			catch {unset maxsamp_line}
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			lappend cmd $fnam
			if [catch {open "|$cmd"} CDPmaxId] {
				Inf "Cannot run maxsamp2 process for file [file rootname [file tail $fnam]]"
				lappend ocl_wksp "UNKNOWN     [file rootname [file tail $fnam]]"
				catch {unset CDPmaxId}
				continue
	   		} else {
	   			fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
			}
	 		vwait done_maxsamp
			if {![info exists maxsamp_line]} {
				Inf "Cannot retrieve maximum sample information for [file rootname [file tail $fnam]]"
				lappend ocl_wksp "UNKNOWN     [file rootname [file tail $fnam]]"
				catch {unset CDPmaxId}
				continue
			}
			set pa($fnam,$evv(MAXSAMP)) [lindex $maxsamp_line 0]
			set pa($fnam,$evv(MAXLOC))  [lindex $maxsamp_line 1]
			set pa($fnam,$evv(MAXREP))  [lindex $maxsamp_line 2]
			lappend ocl_wksp "$pa($fnam,$evv(MAXSAMP))     [file rootname [file tail $fnam]]"
			catch {unset maxsamp_line}
		} else {
			lappend ocl_wksp "$pa($fnam,$evv(MAXSAMP))     [file rootname [file tail $fnam]]"
		}
	}
	set f .oclwksp
	if [Dlg_Create $f "Maximum Levels" "set pr_oclwksp 0" -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(SBDR)] 
		set f2 [frame $f.2 -borderwidth $evv(SBDR)] 
		button $f1.st -text "OK" -command "set pr_oclwksp 0"
		pack $f1.st -side left
		pack $f1 -side top -pady 2 -fill x
		Scrolled_Listbox $f2.ll -width 120 -height 20 -selectmode single
		pack $f2.ll -side top
		pack $f2 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Escape> {set pr_oclwksp 0}
		bind $f <Return> {set pr_oclwksp 0}
	}
	.oclwksp.2.ll.list delete 0 end
	foreach line $ocl_wksp {
		.oclwksp.2.ll.list insert end $line
	}
	set pr_oclwksp 0
	raise $f
	update idletasks
	StandardPosition $f
	Simple_Grab 0 $f pr_oclwksp
	tkwait variable pr_oclwksp
	Simple_Release_to_Dialog $f
	destroy $f
}

