#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 28 June 2013
# ... fixup background for all buttons
# ...  reduce lengths, and padding of grid buttons to zero in most cases
# ... TODO: reduce overall window size a lot
# ... and display ~above~ calling window

#################################
# MUSICAL UNITS CALCULATION PAD	#
#################################

#------ Musical Units Calculation Pad

proc MusicUnitConvertor {flag valin} {
	global pr_mu pdi last_pdi pdo pdf active_inpads tempo pr_tempo mu_recyc was_rec mu time_limitval text_sf
	global nstor orig_pdf last_pdf pdf_store pr_ref ref from_tabedit tedit_message tabed small_screen muc evv
	global is_drawn lastpdo last_mu_recyc sampsize_convertor readonlyfg readonlybg qikval qikstor oclcnt mixval

	set last_mu_recyc ""
	if {[info exists mu(recyc)]} {
		set last_mu_recyc $mu(recyc)
	}
	if [winfo exists .cpd] {
	    focus .cpd
	    catch {grab .cpd}
		raise .cpd
	}
	set oclcnt 0
	set is_drawn 1
	set from_tabedit 0
	set from_tabedit2 0
	set from_parampage 0
	set edit_datafile 0
	set edit_textfile 0
	set edit_mixfile 0
	switch -- $flag {
		1 {set from_tabedit 1}
		2 {set from_parampage 1}
		3 {set from_tabedit2 1}
		4 {set edit_datafile 1}
		5 {set edit_textfile 1}
		6 {set edit_mixfile 1}
	}
	set d "disabled"
	set mu(recyc) ""
	set last_pdi ""
	set nstor ""
	set last_pdf ""
	set pdf_store ""
	set orig_pdf 0
	set was_rec 0
	set time_limitval 0
	if [winfo exists .cpd] {
		return
	}
	set pdf 0
	set active_inpads 0
	set spacer10 "          "
	set msg $spacer10
	set n 0
	while {$n < 9} {
		append msg $spacer10
		incr n
	}
	append msg "MUSICAL UNIT CONVERTOR"
	if [Dlg_Create .cpd $msg "DestroyCalc" -borderwidth $evv(BBDR)] {
		if {$small_screen} {
			set can [Scrolled_Canvas .cpd.c -width $evv(SMALL_WIDTH) -height $evv(MUSCALC_HEIGHT) \
								-scrollregion "0 0 $evv(LARGE_WIDTH) $evv(SCROLL_HEIGHT)"]
			pack .cpd.c -side top -fill x -expand true
			set f [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $f
			set muc $f
		} else {
			set muc .cpd
		}	

		set gv   [frame $muc.vtop -borderwidth $evv(SBDR)]
		set gv2  [frame $muc.vtop2 -borderwidth $evv(SBDR)]
		set gt   [frame $muc.top -borderwidth $evv(SBDR)]
		set mid  [frame $muc.mid -height 1 -bg $evv(POINT)]
		set glom [frame $muc.lom -borderwidth $evv(SBDR)]
		set glom2 [frame $muc.lom2 -borderwidth $evv(SBDR)]
		set glb  [frame $muc.lb -height 1 -bg $evv(POINT)]
		set gbot [frame $muc.bot -borderwidth $evv(SBDR)]
#	 	button $gv.info -text "Info" -command "CDP_Specific_Usage $evv(INFO_MUSUNITS) 0" -highlightbackground [option get . background {}]
	 	button $gv2.info -text "Info" -command "CDP_Specific_Usage $evv(INFO_MUSUNITS) 0" -highlightbackground [option get . background {}]
	 	button $gv2.ref -text "Keep for Reference" -command "RefStore clc" -highlightbackground [option get . background {}]
	 	radiobutton $gv2.refin -variable ref(out) -text "Input" -value 0
	 	radiobutton $gv2.refout -variable ref(out) -text "Output" -value 1
	
	 	entry $gv2.ree -textvariable ref(text) -width 32 -state readonly -borderwidth 0 -readonlybackground [option get . background {}]
		button $gv2.ok -text "" -command {set pr_ref 1} -state  $d -width 2 -borderwidth 0 -highlightbackground [option get . background {}]
		button $gv2.no -text "" -command {set pr_ref 0} -state  $d -width 2 -borderwidth 0 -highlightbackground [option get . background {}]
		button $gv2.qq -text "Close" -command "DestroyCalc" -highlightbackground [option get . background {}]
		pack $gv2.refin $gv2.refout $gv2.ref $gv2.ree $gv2.ok $gv2.no -side left
	 	button $gv2.rfg -text "Get Ref Val" -command "RefGet pdi" -highlightbackground [option get . background {}]
		pack $gv2.qq $gv2.info $gv2.rfg -side right
#	 	button $gv.rfg -text "Get Ref Val" -command "RefGet pdi" -highlightbackground [option get . background {}]
		if {$from_parampage} {
		 	button $gv.par -text "Use As Param" -command "CalculatorOutputAsParam" -highlightbackground [option get . background {}]
		} elseif {$from_tabedit2} {
		 	button $gv.par -text "Use As Param" -command "CalculatorOutputAsTEParam" -highlightbackground [option get . background {}]
		} elseif {$edit_datafile} {
		 	button $gv.par -text "Use As Value" -command "CalculatorOutputAsValue .maketext.k.t" -highlightbackground [option get . background {}]
		} elseif {$edit_textfile} {
		 	button $gv.par -text "Use As Value" -command "CalculatorOutputAsValue $text_sf" -highlightbackground [option get . background {}]
		} elseif {$edit_mixfile} {
		 	button $gv.par -text "Use As Value" -command "CalculatorOutputAsQikEditParam" -highlightbackground [option get . background {}]
		}
#		pack $gv.info -side left
#		pack $gv.rfg -side right -padx 2
		if {$from_parampage || $from_tabedit2 || $edit_datafile || $edit_textfile || $edit_mixfile} {
			pack $gv.par -side right -padx 2
		}
		label  $gbot.r -text "RESULT" -fg $evv(SPECIAL)
		label  $gbot.ed -text "EXTRA DATA"
		entry  $gbot.o -textvariable pdo -width 48 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		button $gbot.rr -text "Recycle" -width 8 -command {NumCalcRecyc recycle} -state  $d -highlightbackground [option get . background {}]
		button $gbot.at -text "" -width 27 -command "set pr_tempo 1" -state  $d -fg $evv(SPECIAL) -highlightbackground [option get . background {}]
		entry  $gbot.ot -textvariable tempo -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg

		button $gbot.lv -text "" -width 9 -command "GetLastNumout" -highlightbackground [option get . background {}]
		button $gbot.lw -text "" -width 9 -command "GetStordNumout" -highlightbackground [option get . background {}]
	 	button $gbot.rfg -text "" -width 9 -command "RefGet tempo" -highlightbackground [option get . background {}]
		pack $gbot.rr $gbot.o $gbot.r -side right -padx 4
		pack $gbot.ed $gbot.at $gbot.ot $gbot.lv $gbot.lw $gbot.rfg -side left -padx 2 -pady 2

		#	TITLES
		label $gt.enter -text "ENTER VALUES"
		label $gt.convert -text "CONVERT UNITS"

#		label $gt.other -text "OTHER"
   		frame $gt.zz -height 1 -bg $evv(POINT)
   		frame $gt.zz1 -height 1 -bg $evv(POINT)
   		frame $gt.zz2 -height 1 -bg $evv(POINT)
#
#		set gs  [frame $gt.srate -borderwidth $evv(SBDR)]
#
		set g0  [frame $gt.0 -width 1 -bg $evv(POINT)]
		set gn  [frame $gt.numeric -borderwidth $evv(SBDR)]
		set g1  [frame $gt.1 -width 1 -bg $evv(POINT)]
		set gp  [frame $gt.pitch -borderwidth $evv(SBDR)]
		set gq  [frame $gt.qtone -borderwidth $evv(SBDR)]
		set g3  [frame $gt.3 -width 1 -bg $evv(POINT)]
		set gi  [frame $gt.interval -borderwidth $evv(SBDR)]
		set g4  [frame $gt.4 -width 3 -bg $evv(POINT)]
		set gb  [frame $gt.buttons -borderwidth $evv(SBDR)]
		set g5  [frame $gt.5 -width 3 -bg $evv(POINT)]
		set gii [frame $gt.input -borderwidth $evv(SBDR)]
		set g6  [frame $gt.6 -width 1 -bg $evv(POINT)]
		set gou [frame $gt.output -borderwidth $evv(SBDR)]
		set g7  [frame $gt.7 -width 3 -bg $evv(POINT)]

		set gcal [frame $muc.11 -borderwidth $evv(SBDR)] 
 		label $gcal.n -text "MATHS"
		button $gcal.l1 -text "V+S" -command {Numc 1} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l2 -text "V-S" -command {Numc 2} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l3 -text "S-V" -command {Numc 3} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l4 -text "V*S" -command {Numc 4} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l5 -text "V/S" -command {Numc 5} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l6 -text "S/V" -command {Numc 6} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l7 -text "1/V" -command {Numc 7} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l8 -text "Rnd" -command {Numc 8} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l9 -text "Flr" -command {Numc 9} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l10 -text "Cei" -command {Numc 10} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l11 -text "Neg" -command {Numc 11} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l12 -text "Abs" -command {Numc 12} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l13 -text "Log" -command {Numc 13} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l14 -text "Ln" -command {Numc 14} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l15 -text "Sq" -command {Numc 15} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l16 -text "Sqrt" -command {Numc 16} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l17 -text "Mod" -command {Numc 17} -width 3 -highlightbackground [option get . background {}]
		button $gcal.l18 -text "Exp" -command {Numc 18} -width 3 -highlightbackground [option get . background {}]
#RWD
		menubutton $gcal.l19 -text "Algebra" -menu $gcal.l19.sub -relief raised ; # -width 8
		menu $gcal.l19.sub -tearoff 0
		$gcal.l19.sub add command -label "Enter Formula" -command MakeAlgebra -foreground black
		$gcal.l19.sub add separator
		$gcal.l19.sub add command -label "Get Formula" -command "GetAlgebra 0" -foreground black
		label $gcal.dum -text "" -width 6
		label $gcal.duma -text "" -width 6
		button $gcal.l$evv(NUMEMORY) -text "AGAIN" -command {Numc $evv(NUMEMORY)} -width 5 -highlightbackground [option get . background {}]

		pack $gcal.n $gcal.l$evv(NUMEMORY) $gcal.l1 $gcal.l2 $gcal.l3 $gcal.l4 $gcal.l5 $gcal.l6 $gcal.l7 \
	 		$gcal.l15 $gcal.l17 $gcal.l8 $gcal.l9 $gcal.l10 $gcal.l11 $gcal.l12 $gcal.l13 $gcal.l14 $gcal.l16 \
			$gcal.l18 $gcal.l19 -side left

#	 	grid $gcal.n -row 0 -column 10 -columnspan 2
#	 	grid $gcal.l$evv(NUMEMORY) -row 1 -column 0
#	 	grid $gcal.duma -row 1 -column 1
#	 	grid $gcal.l1 -row 1 -column 2 
#	 	grid $gcal.l2 -row 1 -column 3 
#	 	grid $gcal.l3 -row 1 -column 4 
#	 	grid $gcal.l4 -row 1 -column 5 
#	 	grid $gcal.l5 -row 1 -column 6 
#	 	grid $gcal.l6 -row 1 -column 7 
#	 	grid $gcal.l7 -row 1 -column 8 
#	 	grid $gcal.l15 -row 1 -column 9 
#	 	grid $gcal.l17 -row 1 -column 10 
#	 	grid $gcal.l8 -row 1 -column 11
#	 	grid $gcal.l9 -row 1 -column 12 
#	 	grid $gcal.l10 -row 1 -column 13 
#	 	grid $gcal.l11 -row 1 -column 14 
#	 	grid $gcal.l12 -row 1 -column 15 
#	 	grid $gcal.l13 -row 1 -column 16 
#	 	grid $gcal.l14 -row 1 -column 17 
#	 	grid $gcal.l16 -row 1 -column 18 
#	 	grid $gcal.l18 -row 1 -column 19 
#	 	grid $gcal.dum -row 1 -column 20
#	 	grid $gcal.l19 -row 1 -column 21

		set gs  [frame $muc.33  -borderwidth $evv(SBDR)]
		set gsn [frame $gs.name	 -borderwidth $evv(SBDR)]
		set gsp [frame $gs.pad	 -borderwidth $evv(SBDR)]
		set gz  [frame $muc.34 -borderwidth $evv(SBDR)]
		set gzn [frame $gz.name	 -borderwidth $evv(SBDR)]
		set gzp [frame $gz.pad	 -borderwidth $evv(SBDR)]
#		label $gsn.name -text "SRATE"
#		pack $gsn.name -side top
		label $gsp.name -text "SRATE"
		button $gsp.96 -text "96K"   -width 3 -command {set tempo 96000} -state  $d -highlightbackground [option get . background {}]
		button $gsp.88 -text "88.2"  -width 4 -command {set tempo 88200} -state  $d -highlightbackground [option get . background {}]
		button $gsp.48 -text "48K"   -width 3 -command {set tempo 48000} -state  $d -highlightbackground [option get . background {}]
		button $gsp.44 -text "44.1"  -width 4 -command {set tempo 44100} -state  $d -highlightbackground [option get . background {}]
		button $gsp.32 -text "32K"   -width 3 -command {set tempo 32000} -state  $d -highlightbackground [option get . background {}]
		button $gsp.24 -text "24K"   -width 3 -command {set tempo 24000} -state  $d -highlightbackground [option get . background {}]
		button $gsp.22 -text "22.05" -width 5 -command {set tempo 22050} -state  $d -highlightbackground [option get . background {}]
		button $gsp.16 -text "16K"   -width 3 -command {set tempo 16000} -state  $d -highlightbackground [option get . background {}]
		label $gsp.dum -text "Count Samps\nin all Chans" -width 11
		button $gsp.cs2 -text "2" -width 1 -command {SetSrmul 2 cs2} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs3 -text "3" -width 1 -command {SetSrmul 3 cs3} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs4 -text "4" -width 1 -command {SetSrmul 4 cs4} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs5 -text "5" -width 1 -command {SetSrmul 5 cs5} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs6 -text "6" -width 1 -command {SetSrmul 6 cs6} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs7 -text "7" -width 1 -command {SetSrmul 7 cs7} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs8 -text "8" -width 1 -command {SetSrmul 8 cs8} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs9 -text "9" -width 1 -command {SetSrmul 9 cs9} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs12 -text "12" -width 2 -command {SetSrmul 12 cs12} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs13 -text "13" -width 2 -command {SetSrmul 13 cs13} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cs16 -text "16" -width 2 -command {SetSrmul 16 cs16} -state  $d -highlightbackground [option get . background {}]
		button $gsp.cp -text "Count Frames" -width 12 -command {SetSrmul 1 cp} -state  $d -highlightbackground [option get . background {}]
		label $gsp.dum2 -text "" -width 6
		button $gsp.ag -text "AGAIN" -width 5 -command {SetSrmul $evv(NUMEMORY) ag} -state $d -highlightbackground [option get . background {}]

		pack $gsp.name $gsp.ag -side left
		pack $gsp.96 $gsp.88 $gsp.48 $gsp.44 $gsp.32 $gsp.24 $gsp.22 $gsp.16 -side left

#		grid $gsp.ag -row 0 -column 4
#		grid $gsp.96 -row 0 -column 9
#		grid $gsp.88 -row 0 -column 10
#		grid $gsp.48 -row 0 -column 11
#		grid $gsp.44 -row 0 -column 12
#		grid $gsp.32 -row 0 -column 13
#		grid $gsp.24 -row 0 -column 14
#		grid $gsp.22 -row 0 -column 15
#		grid $gsp.16 -row 0 -column 16

		pack $gsp.cp $gsp.dum $gsp.cs2 $gsp.cs3 $gsp.cs4 $gsp.cs5 $gsp.cs6 $gsp.cs7 $gsp.cs8 $gsp.cs9 $gsp.cs12 \
			$gsp.cs13 $gsp.cs16 -side left

#		grid $gsp.cp  -row 1 -column 0 -columnspan 2
#		grid $gsp.dum -row 1 -column 2 -columnspan 4
#		grid $gsp.cs2 -row 1 -column 6
#		grid $gsp.cs3 -row 1 -column 7
#		grid $gsp.cs4 -row 1 -column 8
#		grid $gsp.cs5 -row 1 -column 9
#		grid $gsp.cs6 -row 1 -column 10
#		grid $gsp.cs7 -row 1 -column 11
#		grid $gsp.cs8 -row 1 -column 12
#		grid $gsp.cs9 -row 1 -column 13
#		grid $gsp.cs12 -row 1 -column 14
#		grid $gsp.cs13 -row 1 -column 15
#		grid $gsp.cs16 -row 1 -column 16

		#BITSIZE KEYPAD
#		label $gzn.name -text "BITSIZE"
#		pack $gzn.name -side top
		label $gzp.name -text "BITSIZE"
		button $gzp.32 -text "32 bit" -width 6 -command {SetBsize 32} -state  $d -highlightbackground [option get . background {}]
		button $gzp.24 -text "24 bit" -width 6 -command {SetBsize 24} -state  $d -highlightbackground [option get . background {}]
		button $gzp.16 -text "16 bit" -width 6 -command {SetBsize 16} -state  $d -highlightbackground [option get . background {}]
		button $gzp.8  -text "8 bit" -width 6 -command {SetBsize 8}   -state  $d -highlightbackground [option get . background {}]
		button $gzp.ag -text "AGAIN" -width 6 -command {SetBsize $evv(NUMEMORY)} -state $d -highlightbackground [option get . background {}]

		pack $gzp.name $gzp.ag -side left -padx 16
		pack $gzp.32 $gzp.24 $gzp.16 $gzp.8 -side left

#		grid $gzp.ag -row 0 -column 4
#		grid $gzp.32 -row 0 -column 9
#		grid $gzp.24 -row 0 -column 10
#		grid $gzp.16 -row 0 -column 11
#		grid $gzp.8  -row 0 -column 12

		#	NAMES

		set gnn [frame $gn.name	 -borderwidth $evv(SBDR)]
		set gnp [frame $gn.pad	 -borderwidth $evv(SBDR)]

		set gpn [frame $gp.name	 -borderwidth $evv(SBDR)]
		set gpp [frame $gp.pad	 -borderwidth $evv(SBDR)]

		set gqn [frame $gq.name	 -borderwidth $evv(SBDR)]
		set gqp [frame $gq.pad	 -borderwidth $evv(SBDR)]

		set gin [frame $gi.name	 -borderwidth $evv(SBDR)]
		set gip [frame $gi.pad	 -borderwidth $evv(SBDR)]

		set ginn [frame $gii.name -borderwidth $evv(SBDR)]
		set ginp [frame $gii.pad  -borderwidth $evv(SBDR)]

		set goun [frame $gou.name -borderwidth $evv(SBDR)]
		set goup [frame $gou.pad  -borderwidth $evv(SBDR)]

		label $gnn.name -text "NUMERIC" 
		pack $gnn.name -side top
		label $gpn.name -text "PITCH" 
		pack $gpn.name -side top
		label $gin.name -text "INTERVAL" 
		pack $gin.name -side top
		label $ginn.name -text "INPUT UNITS" 
		pack $ginn.name -side top
		label $goun.name -text "OUTPUT UNITS" 
		pack $goun.name -side top

		#	NUMERIC KEYPAD

		button $gnp.1   -text "1" -width 2 -command {AddOn 1 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.2   -text "2" -width 2 -command {AddOn 2 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.3   -text "3" -width 2 -command {AddOn 3 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.4   -text "4" -width 2 -command {AddOn 4 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.5   -text "5" -width 2 -command {AddOn 5 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.6   -text "6" -width 2 -command {AddOn 6 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.7   -text "7" -width 2 -command {AddOn 7 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.8   -text "8" -width 2 -command {AddOn 8 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.9   -text "9" -width 2 -command {AddOn 9 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.0   -text "0" -width 2 -command {AddOn 0 $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.dot -text "." -width 2 -command {AddOn "." $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.neg -text "_" -width 2 -command {AddOn "-" $mu(NPAD)} -highlightbackground [option get . background {}]
		label $gnp.nul1 -text ""
		label $gnp.nul2 -text ""
		label $gnp.nul3 -text ""
		label $gnp.tim -text "TIMING"
		button $gnp.hrs -text "Hrs"  -width 2 -command {AddOn "hrs:" $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.min -text "Min" -width 2 -command {AddOn "mins:" $mu(NPAD)} -highlightbackground [option get . background {}]
		button $gnp.sec -text "Sec" -width 2 -command {AddOn "secs" $mu(NPAD)} -highlightbackground [option get . background {}]

		grid $gnp.1 $gnp.2 $gnp.3 -row 0 -sticky ew -padx 2
		grid $gnp.4 $gnp.5 $gnp.6 -row 1 -sticky ew -padx 2
		grid $gnp.7 $gnp.8 $gnp.9 -row 2 -sticky ew -padx 2
		grid $gnp.0 $gnp.dot $gnp.neg -row 3 -sticky  ew -padx 2
		grid $gnp.nul1 -row 4 -sticky ew -padx 2
		grid $gnp.nul2 -row 5 -sticky ew -padx 2
		grid $gnp.nul3 -row 6 -sticky ew -padx 2
		grid $gnp.tim -row 7 -columnspan 3
		grid $gnp.hrs $gnp.min $gnp.sec -row 8 -sticky ew -padx 2

		if {$from_parampage} {
			label $gnp.dum -text ""
			grid $gnp.dum -row 9 -columnspan 3 -pady 4
			label $gnp.fp0 -text "PARAMETER"
			grid $gnp.fp0 -row 10 -column 0 -columnspan 3
			label $gnp.fp1 -text "FROM PROCESS"
			grid $gnp.fp1 -row 11 -column 0 -columnspan 3
			button $gnp.fpa -text "Get Param" -command "GetParamToCalc 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]
			grid $gnp.fpa -row 12 -column 0 -columnspan 3 -pady 2
			button $gnp.fps -text "Param to Store" -command "GetParamToCalc 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
			grid $gnp.fps -row 13 -column 0 -columnspan 3 -pady 2
		}

		#	PITCH KEYPAD

		button $gpp.c  -text "C"  -width 2 -command {AddOn "C"  $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.cs -text "C#" -width 2 -command {AddOn "C#" $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.d  -text "D"  -width 2 -command {AddOn "D"  $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.eb -text "Eb" -width 2 -command {AddOn "Eb" $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.e  -text "E"  -width 2 -command {AddOn "E"  $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.f  -text "F"  -width 2 -command {AddOn "F"  $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.fs -text "F#" -width 2 -command {AddOn "F#" $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.g  -text "G"  -width 2 -command {AddOn "G"  $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.ab -text "Ab" -width 2 -command {AddOn "Ab" $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.a  -text "A"  -width 2 -command {AddOn "A"  $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.bb -text "Bb" -width 2 -command {AddOn "Bb" $mu(PPAD)} -highlightbackground [option get . background {}]
		button $gpp.b  -text "B"  -width 2 -command {AddOn "B"  $mu(PPAD)} -highlightbackground [option get . background {}]

		label $gpp.nul0 -text ""
		label $gpp.msg1 -text "C0 = middle C"
		label $gpp.nul1 -text ""
		label $gpp.msg2 -text "semitone higher"
		label $gpp.msg3 -text "C#0"
		label $gpp.msg4 -text "semitone lower"
		label $gpp.msg5 -text "B-1"
#RWD set padding as a var
        set pkPadding 0
		grid $gpp.c  $gpp.cs $gpp.d  -row 0 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.eb $gpp.e  $gpp.f  -row 1 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.fs $gpp.g  $gpp.ab -row 2 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.a  $gpp.bb $gpp.b  -row 3 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.nul0  -row 4 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.msg1  -row 5 -column 0 -columnspan 3 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.nul1  -row 6 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.msg2  -row 7 -column 0 -columnspan 3 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.msg3  -row 8 -column 0 -columnspan 3 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.msg4  -row 9 -column 0 -columnspan 3 -sticky ew -padx $pkPadding -pady $pkPadding
		grid $gpp.msg5  -row 10 -column 0 -columnspan 3 -sticky ew -padx $pkPadding -pady $pkPadding

		frame $gpp.ddum -height 20
		grid $gpp.ddum -row 11 -column 1 -columnspan 1 -sticky ew -padx $pkPadding -pady $pkPadding
		frame $gpp.kbd
		MakeKeyboardKey $gpp.kbd $evv(MIDITOCALC) 0
		grid $gpp.kbd -row 12 -column 1 -columnspan 1 -sticky ew -padx $pkPadding -pady $pkPadding

		#	INTERVAL KEYPAD

		button $gip.m2 -text "m2"  -width 2  -command {AddOn "m2" $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.2  -text "2"   -width 2  -command {AddOn "2"  $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.m3 -text "m3"  -width 2  -command {AddOn "m3" $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.3  -text "3"   -width 2  -command {AddOn "3"  $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.4  -text "4"   -width 2  -command {AddOn "4"  $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.tr -text "#4"  -width 2  -command {AddOn "#4" $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.5  -text "5"   -width 2  -command {AddOn "5"  $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.m6 -text "m6"  -width 2  -command {AddOn "m6" $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.6  -text "6"   -width 2  -command {AddOn "6"  $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.m7 -text "m7"  -width 2  -command {AddOn "m7" $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.7  -text "7"   -width 2  -command {AddOn "7"  $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.8  -text "+8"  -width 2  -command {AddOctToEntry "8"} -highlightbackground [option get . background {}]
		button $gip.up -text "up"   -width 4 -command {AddOn "up" $mu(IPAD)} -highlightbackground [option get . background {}]
		button $gip.dn -text "down" -width 4 -command {AddOn "dn" $mu(IPAD)} -highlightbackground [option get . background {}]
		label $gip.11 -text "  "
		frame $gip.00 -height 1 -bg $evv(POINT)

		#	QUARTER-TONE KEYPAD

		label $gip.name -text "QUARTER TONE"
		button $gip.qup -text "+"  -width 2  -command {AddOn "u" -1} -highlightbackground [option get . background {}]
		button $gip.qdn -text "_"  -width 2 -command  {AddOn "d" -1} -highlightbackground [option get . background {}]
		button $gip.qzz -text "no" -width 2 -command  {AddOn "z" -1} -highlightbackground [option get . background {}]

		# REINSTATE LAST OUTPUT

		label $gip.dum1 -text ""
		label $gip.dum2 -text ""
		frame $gip.000 -height 1 -bg $evv(POINT)
		button $gip.last -text "RESTORE LAST OUT VAL" -command CalcRestoreOval -highlightbackground [option get . background {}]
#RWD usa var for padding
        set ikPadding 0
		grid $gip.m2 $gip.2  $gip.m3 $gip.3  -row 0 -sticky w -padx $ikPadding -pady $ikPadding
		grid $gip.4  $gip.tr $gip.5  $gip.m6 -row 1 -sticky w -padx $ikPadding -pady $ikPadding
		grid $gip.6  -row 2 -column 0 -sticky w -padx $ikPadding -pady $ikPadding
		grid $gip.m7 -row 2 -column 1 -sticky w -padx $ikPadding -pady $ikPadding
		grid $gip.7  -row 2 -column 2 -sticky w -padx $ikPadding -pady $ikPadding
		grid $gip.8  -row 2 -column 3 -sticky w -padx $ikPadding -pady $ikPadding
		grid $gip.up -row 3 -column 0 -columnspan 2 -sticky w -padx $ikPadding -pady $ikPadding
		grid $gip.dn -row 3 -column 2 -columnspan 2 -sticky e -padx $ikPadding -pady $ikPadding
		grid $gip.11 -row 4 -column 0 -columnspan 4 -sticky ew -pady $ikPadding
		grid $gip.00 -row 5 -column 0 -columnspan 4 -sticky ew -pady $ikPadding
		grid $gip.name -row 6 -column 0 -columnspan 4 -sticky ew -pady $ikPadding

		grid $gip.qup -row 7 -column 1 -pady $ikPadding
		grid $gip.qdn -row 7 -column 2 -pady $ikPadding
		grid $gip.qzz -row 8 -column 1 -columnspan 2 -pady $ikPadding

		grid $gip.dum1  -row 9 -column 1 -columnspan 2
		grid $gip.000 -row 10 -column 0 -columnspan 4 -sticky ew -pady $ikPadding
		grid $gip.dum2  -row 11 -column 1 -columnspan 2
		grid $gip.last -row 12 -column 1 -columnspan 2 -pady $ikPadding

		#	ACTION FRAME

		button $gb.c -text "Clear" -command {ClearPad 0} -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $gb.last -text "Use Last" -width 7 -command {NumCalcRecyc last} -highlightbackground [option get . background {}]
		button $gb.stor -text "Use Store" -width 7 -command {NumCalcRecyc stored} -highlightbackground [option get . background {}]
		label  $gb.n -text "VALUE  (V)"
		entry  $gb.e -textvariable pdi -width 16 -state  readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $gb.v1 -text "LAST VALUE"
		entry  $gb.v2 -textvariable last_pdi -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $gb.dum2 -text ""
		button $gb.s -text "Store Value" -width 11 -command "StoreNumval" -highlightbackground [option get . background {}]
		button $gb.r2 -text "Store Result" -width 11 -command {NumCalcRecyc storout} -state  $d -highlightbackground [option get . background {}]
		label  $gb.v3 -text "STORED VALUE  (S)"
		entry  $gb.v4 -textvariable nstor -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		button $gb.tt -text "Tap Time" -command CalcTimer -bd 4 -highlightbackground [option get . background {}]

		pack $gb.c $gb.n $gb.e $gb.last $gb.stor $gb.v1 $gb.v2 \
			$gb.dum2 $gb.s $gb.r2 $gb.v3 $gb.v4 -side top -pady 1 -fill y
		pack $gb.tt -side top -pady 4

		#	INPUT FRAME
#RWD  clearly we need a common widht here, so best use a variable
        set ifWidth 9
		button $ginp.bar -text "BARS" 	   -width $ifWidth -command {OutOn Bars 1} 	-state  $d -highlightbackground [option get . background {}]
		button $ginp.bea -text "BEATS"     -width $ifWidth -command {OutOn Beats 1}	 -state  $d -highlightbackground [option get . background {}]
		button $ginp.db  -text "DB"        -width $ifWidth -command {OutOn dB 1}       -state  $d -highlightbackground [option get . background {}]
		button $ginp.del -text "DELAY(MS)" -width $ifWidth -command {OutOn Delay 1}	 -state  $d -highlightbackground [option get . background {}]
		button $ginp.frq -text "FRQ"       -width $ifWidth -command {OutOn Frq 1}      -state  $d	 -highlightbackground [option get . background {}]
		button $ginp.fr  -text "FRQRATIO"  -width $ifWidth -command {OutOn Ratio 1}    -state  $d -highlightbackground [option get . background {}]
		button $ginp.gai -text "GAIN"      -width $ifWidth -command {OutOn Gain 1}     -state  $d -highlightbackground [option get . background {}]
		button $ginp.hrs -text "HR:MIN:SEC" -width $ifWidth -command {OutOn Hours 1} 	-state  $d -highlightbackground [option get . background {}]
		button $ginp.int -text "INTERVAL"  -width $ifWidth -command {OutOn Interval 1} -state  $d -highlightbackground [option get . background {}]
		button $ginp.mid -text "MIDI"      -width $ifWidth -command {OutOn Midi 1}     -state  $d -highlightbackground [option get . background {}]
		button $ginp.mm  -text "MM"         -width $ifWidth -command {OutOn MM 1} 	-state  $d -highlightbackground [option get . background {}]
		button $ginp.not -text "NOTE"      -width $ifWidth -command {OutOn Note 1}     -state  $d -highlightbackground [option get . background {}]
		button $ginp.oct -text "OCTAVES"   -width $ifWidth -command {OutOn Octave 1}   -state  $d -highlightbackground [option get . background {}]
		button $ginp.smp -text "SAMPLECNT" -width $ifWidth -command {OutOn Samples 1} -state  $d -highlightbackground [option get . background {}]
		button $ginp.smv -text "16bitSAMP" -width $ifWidth -command {OutOn Sampv 1} 	-state  $d -highlightbackground [option get . background {}]
		button $ginp.sem -text "SEMITONES" -width $ifWidth -command {OutOn Semitone 1} -state  $d -highlightbackground [option get . background {}]
		button $ginp.tem -text "TEMPO"     -width $ifWidth -command {OutOn Tempo 1}	 -state  $d -highlightbackground [option get . background {}]
		button $ginp.tim -text "TIME(secs)" -width $ifWidth -command {OutOn Time 1}	 -state  $d -highlightbackground [option get . background {}]
		button $ginp.str -text "TIMESTRCH" -width $ifWidth -command {OutOn Tstretch 1} -state  $d -highlightbackground [option get . background {}]
		button $ginp.mtr -text "METRES"    -width $ifWidth -command {OutOn Metres 1} -state  $d -highlightbackground [option get . background {}]
		button $ginp.ech -text "ECHOTIME"  -width $ifWidth -command {OutOn Echo 1} -state  $d -highlightbackground [option get . background {}]
		button $ginp.kbi -text "KB Filesiz"    -width $ifWidth -command {OutOn Kbytes 1} -state  $d -highlightbackground [option get . background {}]
#RWD set padding for all objects
        set ifPadding 0
		grid $ginp.bar $ginp.bea -row 0 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.db  $ginp.del -row 1 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.frq $ginp.fr  -row 2 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.gai $ginp.hrs -row 3 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.int $ginp.mid -row 4 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.mm  $ginp.not -row 5 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.oct $ginp.smp -row 6 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.smv $ginp.sem -row 7 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.tem $ginp.tim -row 8 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.str $ginp.mtr -row 9 -sticky w -padx $ifPadding -pady $ifPadding
		grid $ginp.ech $ginp.kbi -row 10 -sticky w -padx $ifPadding -pady $ifPadding

		#	OUTPUT FRAME
#RWD ditto here
        set ofWidth 9
		button $goup.bar -text "BARS" 	   -width $ofWidth -command "RunMC Bars"	-state  $d -highlightbackground [option get . background {}]
		button $goup.bea -text "BEATS"     -width $ofWidth -command "RunMC Beats"   -state  $d -highlightbackground [option get . background {}]
		button $goup.db  -text "DB"        -width $ofWidth -command "RunMC dB"       -state  $d -highlightbackground [option get . background {}]
		button $goup.del -text "DELAY(MS)" -width $ofWidth -command "RunMC Delay"   -state  $d -highlightbackground [option get . background {}]
		button $goup.frq -text "FRQ"       -width $ofWidth -command "RunMC Frq"      -state  $d -highlightbackground [option get . background {}]
		button $goup.fr  -text "FRQRATIO"  -width $ofWidth -command "RunMC Ratio"   -state  $d -highlightbackground [option get . background {}]
		button $goup.gai -text "GAIN"      -width $ofWidth -command "RunMC Gain"     -state  $d -highlightbackground [option get . background {}]
		button $goup.hrs -text "HR:MIN:SEC" -width $ofWidth -command "RunMC Hours" -state  $d -highlightbackground [option get . background {}]
		button $goup.int -text "INTERVAL"  -width $ofWidth -command "RunMC Interval" -state  $d -highlightbackground [option get . background {}]
		button $goup.mid -text "MIDI"      -width $ofWidth -command "RunMC Midi"     -state  $d -highlightbackground [option get . background {}]
		button $goup.mm  -text "MM" 		-width $ofWidth -command "RunMC MM"	-state  $d -highlightbackground [option get . background {}]
		button $goup.not -text "NOTE"      -width $ofWidth -command "RunMC Note"     -state  $d -highlightbackground [option get . background {}]
		button $goup.oct -text "OCTAVES"   -width $ofWidth -command "RunMC Octave"   -state  $d -highlightbackground [option get . background {}]
		button $goup.smp -text "SAMPLECNT" -width $ofWidth -command "RunMC Samples" -state  $d -highlightbackground [option get . background {}]
		button $goup.smv -text "16bitSAMP" -width $ofWidth -command "RunMC Sampv"   -state  $d -highlightbackground [option get . background {}]
		button $goup.sem -text "SEMITONES" -width $ofWidth -command "RunMC Semitone" -state  $d -highlightbackground [option get . background {}]
		button $goup.tem -text "TEMPO" 	   -width $ofWidth -command "RunMC Tempo"   -state  $d -highlightbackground [option get . background {}]
		button $goup.tim -text "TIME(secs)" -width $ofWidth -command "RunMC Time"	  -state  $d -highlightbackground [option get . background {}]
		button $goup.str -text "TIMESTRCH" -width $ofWidth -command "RunMC Tstretch" -state  $d -highlightbackground [option get . background {}]
		button $goup.mtr -text "METRES"    -width $ofWidth -command "RunMC Metres" -state  $d -highlightbackground [option get . background {}]
		button $goup.ech -text "ECHOTIME"  -width $ofWidth -command "RunMC Echo" -state  $d -highlightbackground [option get . background {}]
		button $goup.kbi -text "KB Filesiz" -width $ofWidth -command "RunMC Kbytes" -state  $d -highlightbackground [option get . background {}]
#RWD and the padding
        set ofPadding 0
		grid $goup.bar $goup.bea -row 0 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.db  $goup.del -row 1 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.frq $goup.fr  -row 2 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.gai $goup.hrs -row 3 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.int $goup.mid -row 4 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.mm  $goup.not -row 5 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.oct $goup.smp -row 6 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.smv $goup.sem -row 7 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.tem $goup.tim -row 8 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.str $goup.mtr -row 9 -sticky w -padx $ofPadding -pady $ofPadding
		grid $goup.ech $goup.kbi -row 10 -sticky w -padx $ofPadding -pady $ofPadding

		#	TEMPO FRAME
		label $glom.tpi -text "METRE"
		button $glom.2 -text "2" -width 1 -command {UpMetre 2} -state $d -highlightbackground [option get . background {}]
		button $glom.3 -text "3" -width 1 -command {UpMetre 3} -state $d -highlightbackground [option get . background {}]
		button $glom.4 -text "4" -width 1 -command {UpMetre 4} -state $d -highlightbackground [option get . background {}]
		button $glom.5 -text "5" -width 1 -command {UpMetre 5} -state $d -highlightbackground [option get . background {}]
		button $glom.6 -text "6" -width 1 -command {UpMetre 6} -state $d -highlightbackground [option get . background {}]
		button $glom.7 -text "7" -width 1 -command {UpMetre 7} -state $d -highlightbackground [option get . background {}]
		button $glom.8 -text "8" -width 1 -command {UpMetre 8} -state $d -highlightbackground [option get . background {}]
		button $glom.9 -text "9" -width 1 -command {UpMetre 9} -state $d -highlightbackground [option get . background {}]
		button $glom.10 -text "10" -width 2 -command {UpMetre 10} -state $d -highlightbackground [option get . background {}]
		button $glom.11 -text "11" -width 2 -command {UpMetre 11} -state $d -highlightbackground [option get . background {}]
		button $glom.12 -text "12" -width 2 -command {UpMetre 12} -state $d -highlightbackground [option get . background {}]
		button $glom.13 -text "13" -width 2 -command {UpMetre 13} -state $d -highlightbackground [option get . background {}]
		button $glom.14 -text "14" -width 2 -command {UpMetre 14} -state $d -highlightbackground [option get . background {}]
		button $glom.15 -text "15" -width 2 -command {UpMetre 15} -state $d -highlightbackground [option get . background {}]
		button $glom.16 -text "16" -width 2 -command {UpMetre 16} -state $d -highlightbackground [option get . background {}]
		button $glom.17 -text "17" -width 2 -command {UpMetre 17} -state $d -highlightbackground [option get . background {}]
		label $glom.tpi2 -text "over"
		button $glom.2d -text "2" -width 1 -command {DnMetre 2} -state $d -highlightbackground [option get . background {}]
		button $glom.4d -text "4" -width 1 -command {DnMetre 4} -state $d -highlightbackground [option get . background {}]
		button $glom.8d -text "8" -width 1 -command {DnMetre 8} -state $d -highlightbackground [option get . background {}]
		button $glom.16d -text "16" -width 2 -command {DnMetre 16} -state $d -highlightbackground [option get . background {}]
		button $glom.32d -text "32" -width 2 -command {DnMetre 32} -state $d -highlightbackground [option get . background {}]
		pack $glom.tpi $glom.2 $glom.3 $glom.4 $glom.5 $glom.6 $glom.7 $glom.8 $glom.9 $glom.10 $glom.11 $glom.12 \
		$glom.13 $glom.14 $glom.15 $glom.16 $glom.17 $glom.tpi2 $glom.2d $glom.4d $glom.8d $glom.16d $glom.32d \
		-side left -padx 1

		button $glom.clik -text "Time+Beats" -width 10 -command {ClikCalculator} -highlightbackground [option get . background {}]
		pack $glom.clik -side left -padx 1

		pack $gs.name $gs.pad -side top
		pack $gz.name $gz.pad -side top
		pack $gn.name $gn.pad -side top
		pack $gp.name $gp.pad -side top
		pack $gq.name $gq.pad -side top
		pack $gi.name $gi.pad -side top
		pack $gii.name $gii.pad -side top
		pack $gou.name $gou.pad -side top

		grid $gt.zz -row 0 -column 0 -columnspan 15 -sticky ew
		grid $gt.enter -row 1 -column 0 -columnspan 7
		grid $gt.convert -row 1 -column 10 -columnspan 3
		grid $gt.interval -row 3 -column 0 -sticky n
		grid $gt.zz1 -row 2 -column 0 -columnspan 8 -sticky ew
		grid $gt.zz2 -row 2 -column 9 -columnspan 6 -sticky ew
		grid $gt.1 		-row 3 -column 1 -sticky ns
		grid $gt.qtone 	-row 3 -column 2 -sticky n
		grid $gt.pitch 	-row 3 -column 4 -sticky n
		grid $gt.3 		-row 3 -column 5 -sticky ns
		grid $gt.numeric -row 3 -column 6 -sticky n
		grid $gt.4 		-row 1 -rowspan 3 -column 7 -sticky ns
		grid $gt.buttons -row 3 -column 8 -sticky n
		grid $gt.5 		-row 1 -rowspan 3 -column 9 -sticky ns
		grid $gt.input 	-row 3 -column 10 -sticky n
		grid $gt.6 		-row 3 -column 11 -sticky ns
		grid $gt.output -row 3 -column 12 -sticky n
		grid $gt.7 		-row 1 -rowspan 3 -column 13 -sticky ns

		frame $muc.00 -height 1 -bg [option get . foreground {}]
		frame $muc.22 -height 1 -bg [option get . foreground {}]

		pack $muc.vtop2 $muc.vtop $muc.top $muc.mid $muc.lom $muc.lom2 $muc.00 $muc.11 $muc.22 $muc.33 $muc.34 $muc.lb $muc.bot -side top -fill x
		wm resizable .cpd 1 1
		ClearPad 0
		set tempo ""
		ForceVal $muc.bot.ot $tempo
		bind .cpd  <Escape> {DestroyCalc}
	}
	switch -- $sampsize_convertor {
		 255 	 { set evv(BITRES) 8 }
		 32767 	 { set evv(BITRES) 16 }
		 524287  { set evv(BITRES) 20 }
		 8388607 { set evv(BITRES) 24 }
		 1.0 	 { set evv(BITRES) float }
	}
	if {[string match $evv(BITRES) "float"]} {
		set zubb floatSAMP
	} else {
		set zubb $evv(BITRES)
		append zubb "bitSAMP"
	}
	if {$edit_mixfile} {
		if {[info exists mixval] && [IsNumeric $mixval]} { 
			set pdi $mixval
			ForceVal $muc.top.buttons.e $pdi
			set pdf $mu(NPAD)
		}
	}
	$muc.top.input.pad.smv config -text $zubb
	$muc.top.output.pad.smv config -text $zubb

	if {$small_screen} {
		set muc .cpd.c.canvas.f
	} else {
		set muc .cpd
	}	
	set pr_mu 0

 	$muc.vtop2.ree config -textvariable ref(text) -state readonly -borderwidth 0 -readonlybackground [option get . background {}]
	$muc.vtop2.ok config -text "" -state $d -borderwidth 0
	$muc.vtop2.no config -text "" -state $d -borderwidth 0
	set ref(out) 1
	set last_pdi ""
	ForceVal $muc.top.buttons.v2 ""
	set nstor ""
	ForceVal $muc.top.buttons.v4 ""
	if {[info exists qikstor]} {
		InputNumberToCalc $qikstor 3
		unset qikstor
	}
	if {[info exists qikval]} {
		InputNumberToCalc $qikval 2
		unset qikval
	}
	My_Grab 0 .cpd pr_mu
	if {$from_tabedit} {
		if [IsNumeric $valin] {
			set len [string length $valin]
			set i 0
			while {$i < $len} {
				AddOn [string index $valin $i] $mu(NPAD)
				incr i
			}
		} else {
			switch -- $valin {
				"C"  -
				"C#" -
				"D"  -
				"Eb" -
				"E"  -
				"F"  -
				"F#" -
				"G"  -
				"Ab" -
				"A"  -
				"Bb" -
				"B" {
				 	AddOn $valin $mu(PPAD)
				}
				default {
					Inf "Invalid value sent to Calculator."
					set pr_ref 0
					catch {My_Release_to_Dialog .cpd}
					catch {Dlg_Dismiss .cpd}
				}
			}
		}
	}
	
	update idletasks
	StandardPosition .cpd
	
	tkwait variable pr_mu
	if {$pr_mu} {
		if {$from_tabedit} {
			set tedit_message $pdo
		 	$tabed.message.e config -bg $evv(EMPH)
		} 
		if {[info exists pdo]} {
			set lastpdo [list $pdo]
		} elseif [info exists lastpdo] {
			set lastpdo [lindex $lastpdo 0]
		}
		if {$from_tabedit || $from_tabedit2 || $edit_datafile || $edit_textfile || $edit_mixfile} {
			set pr_ref 0
		}
	}
	My_Release_to_Dialog .cpd
	Dlg_Dismiss .cpd
	destroy .cpd
}

#------ Put button-induced value on end of input string, if valid.

proc AddOn {item padno} {
	global pdi pdf mu isqtone octpos time_limitval muc evv oclcnt

	set oclcnt 0
	if {![info exists pdi] || ([string length $pdi] == 0)} {
		if [regexp {^[udz]} $item] {
			return 1
		}
		if [regexp {hrs:|mins:|secs} $item] {
			return 1
		}
		set pdn $item
		SetValueEntryPadStates $padno 0
		SetPadInput $item

	} else {

		switch -- $item {
			"0" -
			"1" -
			"2" -
			"3" -
			"4" -
			"5" -
			"6" -
			"7" -
			"8" -
			"9" {
				if {$pdf == $mu(PPAD)} {
					if [regexp {[0-9]} $pdi] {
						tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
						return 1
					}
					if [regexp {\-} $pdi] {
						if {[regexp {d} $pdi] && [regexp {C} $pdi]} {
					 		if {$item > 4} {
								tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
								return 1
							}
						} else {
					 		if {$item > 5} {
								tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
								return 1
							}
						}
					} else {
						if {[regexp {u} $pdi] && [regexp {G} $pdi]} {
					 		if {$item > 4} {
								tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
								return 1
							}
						} elseif {$item > 5} {
							tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
							return 1
						} elseif {($item > 4) && [regexp {[AB]} $pdi]} {
							tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
							return 1
						}
					}
					if {$octpos < 0} {			;#	otherwise its an octaviation value
						set octpos [string length $pdi]
					}
				} elseif {$pdf == $mu(IPAD)} {
					if [regexp {[^0169]} $item] {
				 		set pdi $item
						set octpos -1	 	;#	redundant
						set isqtone 0
						ForceVal $muc.top.buttons.e $pdi
					}						;#	interval name after another, replaces it
					return 1
				} elseif {$pdf == $mu(NPAD)} {
					set zxv $pdi$item
					if {$time_limitval} {		;#	Eliminate mins,secs vals >= 60
						set z [string last ":" $zxv]
						incr z
						set zxv [string range $zxv $z end]
						if {$zxv >= 60} {
							return 1
						}
					} elseif {$zxv > 596523} {	;#	Hrs: calculation out of range : maxlong/3600
						$muc.top.numeric.pad.hrs config -state disabled -bg [option get . background {}]
					} elseif {$zxv > 35791377} {;#	Mins:secs calculation out of range : maxlong/3600
						$muc.top.numeric.pad.min config -state disabled -bg [option get . background {}]
						$muc.top.numeric.pad.sec config -state disabled -bg [option get . background {}]
					}
				}
			}
			"-" {
				if [regexp {\-} $pdi] {
					return 1					;#	never 2 negatives
				} elseif {$pdf == $mu(IPAD)} {
					return 1					;#	No negs with intervals (use up,dn instead)
				} elseif {$pdf == $mu(PPAD)} {
					if {($octpos < 0)} {
						set octpos [string length $pdi]
					} else {
						return 1				;#	Can't set octpos twice
					}
				} elseif {$pdf == $mu(NPAD)} {
					$muc.top.numeric.pad.hrs config -state disabled -bg [option get . background {}]
					$muc.top.numeric.pad.min config -state disabled -bg [option get . background {}]
					$muc.top.numeric.pad.sec config -state disabled -bg [option get . background {}]
				}
			}
			"dn" {
				if {($pdf == $mu(IPAD)) && ![regexp {^\-} $pdi]} {
					set pdi -$pdi									;#	Can't add minus sign if there
					ForceVal $muc.top.buttons.e $pdi
				}				
				return 1
			}
			"up" {
				if {($pdf == $mu(IPAD)) && [regexp {^\-} $pdi]} {	;#	Can't remove minus sign if not there
					set pdi [string range $pdi 1 end]
					ForceVal $muc.top.buttons.e $pdi
				}
				return 1
			}
			"." {
				if {$pdf != $mu(NPAD) || [regexp {\.} $pdi]} {
					return 1					;#	Can't have 2 decimal points, or 1 with non-numbers
				} elseif {$pdf == $mu(NPAD)} {
					$muc.top.numeric.pad.hrs config -state disabled -bg [option get . background {}]
					$muc.top.numeric.pad.min config -state disabled -bg [option get . background {}]
					$muc.top.numeric.pad.sec config -state disabled -bg [option get . background {}]
				}
			}
			"Ab" -
			"A"  -
			"Bb" -
			"B"  -
			"C"  -
			"C#" -
			"D"  -
			"Eb" -
			"E"  -
			"F"  -
			"F#" -
			"G"  {
				if {$pdf == $mu(PPAD)} {
				 	set pdi $item
					set octpos -1
					set isqtone 0
					ForceVal $muc.top.buttons.e $pdi
				}						;#	Pitch name after anything else replaces it
				return 1					
			}
			"m2" -
			"m3" -
			"#4" -
			"m6" -
			"m7" {
				if {$pdf == $mu(IPAD)} {
				 	set pdi $item
					set octpos -1	 ;#	redundant
					set isqtone 0
					ForceVal $muc.top.buttons.e $pdi
				}						;#	interval name after anything else replaces it
				return 1
			}
			"u" {
				if {$pdf == $mu(NPAD)} {
					return 1							;#	Safety only
				} elseif {($pdf == $mu(PPAD)) && [regexp {G5} $pdi]} {
					tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
					return 1							;#	quartertones beyond range edges invalid
				}
				if [regexp {u} $pdi] {
					return 1				   			;#	can't go up any more
				} elseif [regexp {d} $pdi] {	;#	substitute up for down
					set k [string first "d" $pdi]
					incr k -1
					set padstart [string range $pdi 0 $k]
					incr k 2
					if {$k < [string length $pdi]} {
						set padend [string range $pdi $k end]
						set pdi $padstart
						append pdi "u" $padend
					} else {
						set pdi $padstart
						append pdi "u"
					}
					set isqtone 1
					ForceVal $muc.top.buttons.e $pdi
					return 1					;#	can't have two quartertone offsets
				}
				set isqtone 1
			}
			"d" {
				if {$pdf == $mu(NPAD)} {
					return 1				;#	Safety only
				} elseif {($pdf == $mu(PPAD)) && [regexp {C-5} $pdi]} {
					tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
					return 1					;#	quartertones beyond range edges invalid
				}
				if [regexp {d} $pdi] {
					return 1
				} elseif [regexp {u} $pdi] {
					set k [string first "u" $pdi]
					incr k -1
					set padstart [string range $pdi 0 $k]
					incr k 2
					if {$k < [string length $pdi]} {
						set padend [string range $pdi $k end]
						set pdi $padstart
						append pdi "d" $padend
					} else {
						set pdi $padstart
						append pdi "d"
					}
					set isqtone -1
					ForceVal $muc.top.buttons.e $pdi
					return 1					;#	can't have two quartertone offsets
				}
				set isqtone -1
			}
			"z" {
				if {$pdf == $mu(NPAD)} {
					return 1					;#	Safety only
				} elseif {![regexp {[ud]} $pdi]} {
					return 1
				} else {
					if {[set k [string first "u" $pdi]] < 1} {
						set k [string first "d" $pdi]
					}
					incr k -1
					set padstart [string range $pdi 0 $k]
					incr k 2
					if {$k < [string length $pdi]} {
						set padend [string range $pdi $k end]
						set pdi $padstart
						append pdi $padend
					} else {
						set pdi $padstart
					}
					set isqtone 0
					ForceVal $muc.top.buttons.e $pdi
					return 1					;#	can't have two quartertone offsets
				}
				set isqtone 0
			}
			"hrs:" {
				if {![info exists pdi] || ([string length $pdi] <= 0) || [regexp {[^0-9]} $pdi]} {
					return 1
				}
				$muc.top.numeric.pad.hrs config -state disabled -bg [option get . background {}]
				set time_limitval 1
			}
			"mins:" {
				if {![info exists pdi] || ([string length $pdi] <= 0)} {
					return 1
				}
				if {![regexp {[^0-9]} $pdi]} {
					 if {$pdi < 0} {
					 	return 1
					 }
				} elseif { ![regexp {^[0-9]+hrs:[0-9]+$} $pdi]} {
					return 1
				}
				$muc.top.numeric.pad.hrs config -state disabled -bg [option get . background {}]
				$muc.top.numeric.pad.min config -state disabled -bg [option get . background {}]
				set time_limitval 1
			}
			"secs" {
				if {![info exists pdi] || ([string length $pdi] <= 0)} {
					return 1
				}
				if {![regexp {[^0-9]} $pdi]} {
					 if {$pdi < 0} {
					 	return 1
					 }
				} elseif { ![regexp {^[0-9]+hrs:[0-9]+$} $pdi] \
						&& ![regexp {^[0-9]+mins:[0-9]+$} $pdi] \
						&& ![regexp {^[0-9]+hrs:[0-9]+mins:[0-9]+$} $pdi]} {
					return 1
				}
				set time_limitval 0
			}
		}
		set pdn $pdi$item			;#	in all other cases., add new character to entry val
	}

	if {($pdf == $mu(NPAD))} {								;#	For numeric pad entries
		if {[regexp {[0-9]} $item] && !$time_limitval} {	;#	when numerals entered
			set pdn [ResetInPads $pdn]						;#	Reset Input buttons according to range
			if {[string length $pdn] <= 0} {
				return 0
			}
		} elseif [regexp {hrs:|mins:|secs} $item] { 		;# If timemarker added, switch to time options
			$muc.top.numeric.pad.dot config -state disabled -bg [option get . background {}]
			$muc.top.numeric.pad.neg config -state disabled -bg [option get . background {}]
			$muc.top.numeric.name.name config -bg [option get . background {}]
			$muc.top.numeric.pad.tim config -bg $evv(EMPH)
			PadInOff Midi Frq Ratio Tstretch Gain Semitone Octave dB Delay Tempo Beats Time Samples Kbytes Sampv Bars MM Metres Echo
			PadInOn Hours
			if [regexp {secs} $item] {
				SetValueEntryPadStates -1 1
			}
		}
	}
	set pdi $pdn
	ForceVal $muc.top.buttons.e $pdi
	return 1
}

#------ Adjust Input Pads according to range of input val

proc ResetInPads {pdn} {
	global time_limitval muc mu evv

	if {([string length $pdn] > 1)} {
		if {[regexp {^0[^\.]+} $pdn]} {
			set pdn [string range $pdn 1 end]			;#	Drop leading zero (or '-0') if not a decimal
		} elseif {[regexp {^\-0[^\.]+} $pdn]} {
			set pdn -[string range $pdn 2 end]			
		}
	}
	if {$pdn > $mu(MAXSAMPS) || $pdn < [expr -$mu(MAXSAMPVAL) - 1]} {
		tk_messageBox -message "Out of Range" -type ok -parent $muc -icon warning
		PadInOff all
		return ""
	}
	if {$pdn < 1} {
		PadInOff Bars
		PadInOff Samples
	} else {
		PadInOn Bars
		PadInOn Samples
	}
	if {$pdn < $evv(CDP_HEADSIZE)} {
		PadInOff Kbytes
	} else {
		PadInOn Kbytes
	}
	if {$pdn < $mu(MINMMVAL) || $pdn > $mu(MAXMMVAL)} {
		PadInOff MM
	} else {
		PadInOn MM
	}
	if {$pdn > $mu(MAXSAMPVAL)} {
		PadInOff Sampv
	} else {
		PadInOn Sampv
	}
	if {$pdn < 0.0  || $pdn > $mu(MAXTIME)} {
		PadInOff Time
		PadInOff Echo
	} else {
		PadInOn Time
		PadInOn Echo
	}
	if {$pdn < 0.0  || $pdn > [expr (double($mu(MAXTIME)) * $evv(SPEED_OF_SOUND)) / 2.0]} {
		PadInOff Metres
	} else {
		PadInOn Metres
	}
	if {$pdn > $mu(MAXMFRQ) || $pdn < $mu(MINPITCH)} {
		PadInOff Frq
		PadInOff Res
	} else {
		PadInOn Frq
		PadInOn Res
	}
	if {$pdn > $mu(MAXSEMIT) || $pdn < $mu(MINSEMIT)} {
		PadInOff Semitone
	} else {
		PadInOn Semitone
	}
	if {$pdn > $mu(MAXFRQRATIO) || $pdn < $mu(MINFRQRATIO)} {
		PadInOff Ratio Tstretch
	} else {
		PadInOn Ratio Tstretch
	}
	if {$pdn > $mu(MAXGAIN) || $pdn <$mu(MINGAIN)} {
		PadInOff Gain
	} else {
		PadInOn Gain
	}
	if {$pdn > $mu(MIDIMAX) ||$pdn < $mu(MIDIMIN)} {
		PadInOff Midi
	} else {
		PadInOn Midi
	}
	if {$pdn > $mu(MAXDB) || $pdn < $mu(MINDB)} {
		PadInOff dB
	} else {
		PadInOn dB
	}
	if {$pdn > $mu(MAXOCT) || $pdn < $mu(MINOCT)} {
		PadInOff Octave
	} else {
		PadInOn Octave
	}
	if {$pdn > $mu(MAXTDEL) || $pdn < $mu(MINDEL)} {
		PadInOff Delay
	} else {
		PadInOn Delay
	}
	if {$pdn > $mu(MAXTEMPO) || $pdn < $mu(MINTEMPO)} {
		PadInOff Tempo
	} else {
		PadInOn Tempo
	}
	return $pdn
}

#------ Adjust interval value up or downm by an octave (within valid ranges)

proc AddOctToEntry {item} {
	global pdi pdf mu muc

	if {$pdf == $mu(PPAD) || $pdf == $mu(NPAD)} {
		return
	}
	if {[info exists pdi] && ([set len [string length $pdi]] > 0)} {
		if {[string match m* $pdi] || [string match -m* $pdi]} {
			set k [string first "m" $pdi]
			incr k
			if [regexp {m[23679][^0-9]*} $pdi] {
				ResetEntry [string index $pdi $k] $len $k
			} elseif [regexp {m[1][0-5][^0-9]*} $pdi] {
				set j [expr $k + 1]
				ResetEntry [string range $pdi $k $j] $len $k
			}
		} elseif {[string match #* $pdi] || [string match -#* $pdi]} {
			set k [string first "#" $pdi]
			incr k
			if [regexp {\#4} $pdi] {
				ResetEntry "4" $len $k
			} elseif [regexp {\#11} $pdi] {
				set j [expr $k + 1]
				ResetEntry "11" $len $k
			}
		} elseif {[regexp {^[-]*[1-9]+} $pdi]} {
			if [string match "-" [string index $pdi 0]] {
				set k 1
			} else {
				set k 0
			}
			if [regexp {^[-]*2[^0-9]*} $pdi] {
				ResetEntry "2" $len $k
			} elseif [regexp {^[-]*3[^0-9]*} $pdi] {
				ResetEntry "3" $len $k
			} elseif [regexp {^[-]*4[^0-9]*} $pdi] {
				ResetEntry "4" $len $k
			} elseif [regexp {^[-]*5[^0-9]*} $pdi] {
				ResetEntry "5" $len $k
			} elseif [regexp {^[-]*6[^0-9]*} $pdi] {
				ResetEntry "6" $len $k
			} elseif [regexp {^[-]*7[^0-9]*} $pdi] {
				ResetEntry "7" $len $k
			} elseif [regexp {^[-]*8[^0-9]*} $pdi] { 
				ResetEntry "8" $len $k
			} elseif [regexp {^[-]*9[^0-9]*} $pdi] {
				ResetEntry "9" $len $k
			} elseif [regexp {^[-]*10} $pdi] {
				ResetEntry "10" $len $k
			} elseif [regexp {^[-]*11} $pdi] {
				ResetEntry "11" $len $k
			} elseif [regexp {^[-]*12} $pdi] {
				ResetEntry "12" $len $k
			} elseif [regexp {^[-]*13} $pdi] {
				ResetEntry "13" $len $k
			} elseif [regexp {^[-]*14} $pdi] {
				ResetEntry "14" $len $k
			} elseif [regexp {^[-]*15} $pdi] {
				ResetEntry "15" $len $k
			}
		}
	} else {
		set pdi "8"
		SetValueEntryPadStates $mu(IPAD) 0
		SetPadInput $item
	}
	ForceVal $muc.top.buttons.e $pdi
}

#------ Do octave adjustment of string

proc ResetEntry {item len k} {
	global pdi muc

	incr k -1
	if {$k < 0} {
		set padstart ""
	} else {
		set padstart [string range $pdi 0 $k]
	}
	incr k
	incr k [string length $item]
	if {$k >= $len} {
		set padend ""
	} else {
		set padend [string range $pdi $k end]
	}
	if {$item > 8} {
		incr item -7
		$muc.top.interval.pad.8 config -text "+8"
	} else {
		incr item 7
		$muc.top.interval.pad.8 config -text "-8"
	}
	set pdi $padstart
	append pdi $item $padend
}

#------ Set Value-Entry Pads active or inactive, as flagged

proc SetValueEntryPadStates {val force} {
	global pdf mu time_limitval

	PadOff srate
	PadOff bsize
	switch -- $val {
		-1 {
			set pdf -1
			PadOff numerals
			PadOff pitch
			PadOff intervals
			PadOff qtones
			set time_limitval 0
		}
		0 {
			set pdf 0
			PadOn numerals
			PadOn pitch
			PadOn intervals
			PadOff qtones
			set time_limitval 0
		}
		1 {
			if {$force || ($pdf == 0)} {
				set pdf $mu(NPAD)
				PadOff pitch
				PadOff intervals
			}
		}
		2 {
			if {$force || ($pdf == 0)} {
				set pdf $mu(PPAD)
				PadOff decimal
				PadOff timing
				PadOff intervals
				PadOn qtones
			}
		}
		3 {
			if {$force || ($pdf == 0)} {
				set pdf $mu(IPAD)
				PadOff numerals
				PadOff pitch
				PadOn qtones
			}
		}
	}
}

#------ Set Value-Entry Buttons inactive, as flagged

proc PadOff {str} {
	global muc
	set z $muc.34
	set s $muc.33
	set j $muc.top.numeric
	set p $muc.top.pitch
	set i $muc.top.interval
	set d "disabled"
	switch -- $str {
		"bsize" {
			$z.pad.name config -bg [option get . background {}]
			$z.pad.32 config -state $d -bg [option get . background {}]
			$z.pad.24 config -state $d -bg [option get . background {}]
			$z.pad.16 config -state $d -bg [option get . background {}]
			$z.pad.8 config -state $d -bg [option get . background {}]
		}
		"srate" {
			$s.pad.name config -bg [option get . background {}]
			$s.pad.96 config -state $d -bg [option get . background {}]
			$s.pad.88 config -state $d -bg [option get . background {}]
			$s.pad.48 config -state $d -bg [option get . background {}]
			$s.pad.44 config -state $d -bg [option get . background {}]
			$s.pad.32 config -state $d -bg [option get . background {}]
			$s.pad.24 config -state $d -bg [option get . background {}]
			$s.pad.22 config -state $d -bg [option get . background {}]
			$s.pad.16 config -state $d -bg [option get . background {}]
			$s.pad.cs2 config -state $d -bg [option get . background {}]
			$s.pad.cs3 config -state $d -bg [option get . background {}]
			$s.pad.cs4 config -state $d -bg [option get . background {}]
			$s.pad.cs5 config -state $d -bg [option get . background {}]
			$s.pad.cs6 config -state $d -bg [option get . background {}]
			$s.pad.cs7 config -state $d -bg [option get . background {}]
			$s.pad.cs8 config -state $d -bg [option get . background {}]
			$s.pad.cs9 config -state $d -bg [option get . background {}]
			$s.pad.cs12 config -state $d -bg [option get . background {}]
			$s.pad.cs13 config -state $d -bg [option get . background {}]
			$s.pad.cs16 config -state $d -bg [option get . background {}]
			$s.pad.cp config -state $d -bg [option get . background {}]
			$s.pad.ag config -state $d -bg [option get . background {}]
		}
		"numerals" {
			$j.name.name config -bg [option get . background {}]
			$j.pad.1 config -state $d -bg [option get . background {}]
			$j.pad.2 config -state $d -bg [option get . background {}]
			$j.pad.3 config -state $d -bg [option get . background {}]
			$j.pad.4 config -state $d -bg [option get . background {}]
			$j.pad.5 config -state $d -bg [option get . background {}]
			$j.pad.6 config -state $d -bg [option get . background {}]
			$j.pad.7 config -state $d -bg [option get . background {}]
			$j.pad.8 config -state $d -bg [option get . background {}]
			$j.pad.9 config -state $d -bg [option get . background {}]
			$j.pad.0 config -state $d -bg [option get . background {}]
			$j.pad.dot config -state $d -bg [option get . background {}]
			$j.pad.neg config -state $d -bg [option get . background {}]
			$j.pad.hrs config -state $d -bg [option get . background {}]
			$j.pad.min config -state $d -bg [option get . background {}]
			$j.pad.sec config -state $d -bg [option get . background {}]
		}
		"decimal" {
			$j.pad.dot config -state $d -bg [option get . background {}]
		}
		"timing" {
			$j.pad.hrs config -state $d -bg [option get . background {}]
			$j.pad.min config -state $d -bg [option get . background {}]
			$j.pad.sec config -state $d -bg [option get . background {}]
		}
		"pitch" {
			$p.name.name config -bg [option get . background {}]
			$p.pad.c  config -state $d -bg [option get . background {}]
			$p.pad.cs config -state $d -bg [option get . background {}]
			$p.pad.d  config -state $d -bg [option get . background {}]
			$p.pad.eb config -state $d -bg [option get . background {}]
			$p.pad.e  config -state $d -bg [option get . background {}]
			$p.pad.f  config -state $d -bg [option get . background {}]
			$p.pad.fs config -state $d -bg [option get . background {}]
			$p.pad.g  config -state $d -bg [option get . background {}]
			$p.pad.ab config -state $d -bg [option get . background {}]
			$p.pad.a  config -state $d -bg [option get . background {}]
			$p.pad.bb config -state $d -bg [option get . background {}]
			$p.pad.b  config -state $d -bg [option get . background {}]
		}			
		"intervals" {
			$i.name.name config -bg [option get . background {}]
			$i.pad.m2 config -state $d -bg [option get . background {}]
			$i.pad.2  config -state $d -bg [option get . background {}]
			$i.pad.m3 config -state $d -bg [option get . background {}]
			$i.pad.3  config -state $d -bg [option get . background {}]
			$i.pad.4  config -state $d -bg [option get . background {}]
			$i.pad.tr config -state $d -bg [option get . background {}]
			$i.pad.5  config -state $d -bg [option get . background {}]
			$i.pad.m6 config -state $d -bg [option get . background {}]
			$i.pad.6  config -state $d -bg [option get . background {}]
			$i.pad.m7 config -state $d -bg [option get . background {}]
			$i.pad.7  config -state $d -bg [option get . background {}]
			$i.pad.8  config -state $d -bg [option get . background {}] -text "+8"
			$i.pad.up config -state $d -bg [option get . background {}]
			$i.pad.dn config -state $d -bg [option get . background {}]
		}
		"qtones" {
			$muc.top.interval.pad.qup config -state $d -bg [option get . background {}]
			$muc.top.interval.pad.qdn config -state $d -bg [option get . background {}]
			$muc.top.interval.pad.qzz config -state $d -bg [option get . background {}]
		}
	}
}

#------ Set Value-Entry Buttons active, as flagged

proc PadOn {str} {
	global muc evv
	set z $muc.34
	set s $muc.33
	set j $muc.top.numeric
	set p $muc.top.pitch
	set i $muc.top.interval
	set n "normal"

	switch -- $str {
		"bsize" {
			$z.pad.name config -bg $evv(EMPH)
			$z.pad.32 config -state $n -bg $evv(EMPH)
			$z.pad.24 config -state $n -bg $evv(EMPH)
			$z.pad.16 config -state $n -bg $evv(EMPH)
			$z.pad.8 config -state $n -bg $evv(EMPH)
			$z.pad.ag config -state $n -bg [option get . background {}]
		}
		"srate" {
			$s.pad.name config -bg $evv(EMPH)
			$s.pad.96 config -state $n -bg $evv(EMPH)
			$s.pad.88 config -state $n -bg $evv(EMPH)
			$s.pad.48 config -state $n -bg $evv(EMPH)
			$s.pad.44 config -state $n -bg $evv(EMPH)
			$s.pad.32 config -state $n -bg $evv(EMPH)
			$s.pad.24 config -state $n -bg $evv(EMPH)
			$s.pad.22 config -state $n -bg $evv(EMPH)
			$s.pad.16 config -state $n -bg $evv(EMPH)
			$s.pad.cs2 config -state $n -bg [option get . background {}]
			$s.pad.cs3 config -state $n -bg [option get . background {}]
			$s.pad.cs4 config -state $n -bg [option get . background {}]
			$s.pad.cs5 config -state $n -bg [option get . background {}]
			$s.pad.cs6 config -state $n -bg [option get . background {}]
			$s.pad.cs7 config -state $n -bg [option get . background {}]
			$s.pad.cs8 config -state $n -bg [option get . background {}]
			$s.pad.cs9 config -state $n -bg [option get . background {}]
			$s.pad.cs12 config -state $n -bg [option get . background {}]
			$s.pad.cs13 config -state $n -bg [option get . background {}]
			$s.pad.cs16 config -state $n -bg [option get . background {}]
			$s.pad.cp config -state $n -bg $evv(EMPH)
			$s.pad.ag config -state $n -bg [option get . background {}]
		}
		"numerals" {
			$j.name.name config -bg $evv(EMPH)
			$j.pad.tim config -bg [option get . background {}]
			$j.pad.1 config -state $n -bg $evv(EMPH)
			$j.pad.2 config -state $n -bg $evv(EMPH)
			$j.pad.3 config -state $n -bg $evv(EMPH)
			$j.pad.4 config -state $n -bg $evv(EMPH)
			$j.pad.5 config -state $n -bg $evv(EMPH)
			$j.pad.6 config -state $n -bg $evv(EMPH)
			$j.pad.7 config -state $n -bg $evv(EMPH)
			$j.pad.8 config -state $n -bg $evv(EMPH)
			$j.pad.9 config -state $n -bg $evv(EMPH)
			$j.pad.0 config -state $n -bg $evv(EMPH)
			$j.pad.dot config -state $n -bg $evv(EMPH)
			$j.pad.neg config -state $n -bg $evv(EMPH)
			$j.pad.hrs config -state $n -bg $evv(EMPH)
			$j.pad.min config -state $n -bg $evv(EMPH)
			$j.pad.sec config -state $n -bg $evv(EMPH)
		}
		"pitch" {
			$p.name.name config -bg $evv(EMPH)
			$p.pad.c  config -state $n -bg $evv(EMPH)
			$p.pad.cs config -state $n -bg $evv(EMPH)
			$p.pad.d  config -state $n -bg $evv(EMPH)
			$p.pad.eb config -state $n -bg $evv(EMPH)
			$p.pad.e  config -state $n -bg $evv(EMPH)
			$p.pad.f  config -state $n -bg $evv(EMPH)
			$p.pad.fs config -state $n -bg $evv(EMPH)
			$p.pad.g  config -state $n -bg $evv(EMPH)
			$p.pad.ab config -state $n -bg $evv(EMPH)
			$p.pad.a  config -state $n -bg $evv(EMPH)
			$p.pad.bb config -state $n -bg $evv(EMPH)
			$p.pad.b  config -state $n -bg $evv(EMPH)
		}			
		"intervals" {
			$i.name.name config -bg $evv(EMPH)
			$i.pad.m2 config -state $n -bg $evv(EMPH)
			$i.pad.2  config -state $n -bg $evv(EMPH)
			$i.pad.m3 config -state $n -bg $evv(EMPH)
			$i.pad.3  config -state $n -bg $evv(EMPH)
			$i.pad.4  config -state $n -bg $evv(EMPH)
			$i.pad.tr config -state $n -bg $evv(EMPH)
			$i.pad.5  config -state $n -bg $evv(EMPH)
			$i.pad.m6 config -state $n -bg $evv(EMPH)
			$i.pad.6  config -state $n -bg $evv(EMPH)
			$i.pad.m7 config -state $n -bg $evv(EMPH)
			$i.pad.7  config -state $n -bg $evv(EMPH)
			$i.pad.8  config -state $n -bg $evv(EMPH) -text "+8"
			$i.pad.dn config -state $n -bg $evv(EMPH)
			$i.pad.up config -state $n -bg $evv(EMPH)
		}
		"qtones" {
			$muc.top.interval.pad.qup config -state $n -bg $evv(EMPH)
			$muc.top.interval.pad.qdn config -state $n -bg $evv(EMPH)
			$muc.top.interval.pad.qzz config -state $n -bg $evv(EMPH)
		}
	}
}

#------ Set Input-type Buttons active, as flagged

proc SetPadInput {item} {
	global pdf mu

	switch -regexp -- $pdf \
		^$mu(PPAD)$ {
			PadInOn Note
		} \
		^$mu(IPAD)$ {
			PadInOn Interval
		} \
		^$mu(NPAD)$ {
			switch -- $item {
				"-" {
					PadInOn Semitone Octave dB
				}
				"." {}
				default {
					PadInOn Midi Frq Ratio Tstretch Gain Semitone Octave dB Delay Tempo Beats Time Samples Kbytes MM Metres Echo
				}
			}
		}
}

#------ Set Input-type Buttons active

proc PadInOn {args} {
	global active_inpads muc evv
	set q $muc.top.input.pad
	set n "normal"
	foreach item $args {
		switch -- $item {
			"Note" {     
				$q.not config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 1]
			}
			"Interval" { 
				$q.int config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 2]
			}
			"Semitone" {
				$q.sem config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 4]
			}
			"Octave" {
				$q.oct config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 8]
			}
			"dB" {
				$q.db  config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 16]
			}
			"Midi" {
				$q.mid config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 32]
			}
			"Frq" {
				$q.frq config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 64]
			}
			"Ratio" {
				$q.fr  config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 128]
			}
			"Tstretch" {
				$q.str config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 256]
			}
			"Gain" {
				$q.gai config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 512]
			}
			"Delay" {
				$q.del config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 1024]
			}
			"Tempo" {
				$q.tem config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 2048]
			}
			"Beats" {
				$q.bea config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 4096]
			}
			"Time" {
				$q.tim config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 8192]
			}
			"Samples" {
				$q.smp config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 16384]
			}
			"Sampv" {
				$q.smv config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 32768]
			}
			"Bars" {
				$q.bar config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 65536]
			}
			"Hours" {
				$q.hrs config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 131072]
			}
			"MM" {
				$q.mm config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 262144]
			}
			"Metres" {
				$q.mtr config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 524288]
			}
			"Echo" {
				$q.ech config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 1048576]
			}
			"Kbytes" {
				$q.kbi config -state $n -bg $evv(EMPH)
				set active_inpads [expr $active_inpads | 2097152]
			}
		}
	}
	if {$active_inpads} {
		switch -- $active_inpads {
			1   { OutOn Note 0}
			2   { OutOn Interval 0}
			4   { OutOn Semitone 0}
			8   { OutOn Octave 0}
			16  { OutOn dB 0}
			32  { OutOn Midi 0}
			64  { OutOn Frq 0}
			128 { OutOn Ratio 0}
			256 { OutOn Tstretch 0}
			512 { OutOn Gain 0}
			1024 { OutOn Delay 0}
			2048 { OutOn Tempo 0}
			4096 { OutOn Beats 0}
			8192 { OutOn Time 0}
			16384 { OutOn Samples 0}
			32768 { OutOn Sampv 0}
			65536 { OutOn Bars 0}
			131072 { OutOn Hours 0}
			262144 { OutOn MM 0}
			524288 { OutOn Metres 0}
			1048576 { OutOn Echo 0}
			2097152 { OutOn Kbytes 0}
		}
	}
}

#------ Set Input-type Buttons Inactive

proc PadInOff {args} {
	global active_inpads muc
	set q $muc.top.input.pad
	set d "disabled"
	foreach item $args {
		switch -- $item {
			"all" {
				$q.not config -state $d -bg [option get . background {}]
				$q.int config -state $d -bg [option get . background {}]
				$q.sem config -state $d -bg [option get . background {}]
				$q.oct config -state $d -bg [option get . background {}]
				$q.db  config -state $d -bg [option get . background {}]
				$q.mid config -state $d -bg [option get . background {}]
				$q.frq config -state $d -bg [option get . background {}]
				$q.fr  config -state $d -bg [option get . background {}]
				$q.str config -state $d -bg [option get . background {}]
				$q.gai config -state $d -bg [option get . background {}]
				$q.del config -state $d -bg [option get . background {}]
				$q.tem config -state $d -bg [option get . background {}]
				$q.bea config -state $d -bg [option get . background {}]
				$q.tim config -state $d -bg [option get . background {}]
				$q.smp config -state $d -bg [option get . background {}]
				$q.smv config -state $d -bg [option get . background {}]
				$q.bar config -state $d -bg [option get . background {}]
				$q.hrs config -state $d -bg [option get . background {}]
				$q.mm  config -state $d -bg [option get . background {}]
				$q.mtr config -state $d -bg [option get . background {}]
				$q.ech config -state $d -bg [option get . background {}]
				$q.kbi config -state $d -bg [option get . background {}]
				set active_inpads 0
			}
			"Note" {
				$q.not config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -2]
			}
			"Interval" {
				$q.int config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -3]
			}
			"Semitone" {
				$q.sem config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -5]
			}
			"Octave" {
				$q.oct config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -9]
			}
			"dB" {
				$q.db  config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -17]
			}
			"Midi" {
				$q.mid config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -33]
			}
			"Frq" {
				$q.frq config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -65]
			}
			"Ratio" {
				$q.fr  config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -129]
			}
			"Tstretch" {
				$q.str config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -257]
			}
			"Gain" {
				$q.gai config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -513]
			}
			"Delay" {
				$q.del config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -1025]
			}
			"Tempo" {
				$q.tem config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -2049]
			}
			"Beats" {
				$q.bea config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -4097]
			}
			"Time" {
				$q.tim config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -8193]
			}
			"Samples" {
				$q.smp config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -16385]
			}
			"Sampv" {
				$q.smv config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -32769]
			}
			"Bars" {
				$q.bar config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -65537]
			}
			"Hours" {
				$q.hrs config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -131073]
			}
			"MM" {
				$q.mm config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -262145]
			}
			"Metres" {
				$q.mtr config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -524289]
			}
			"Echo" {
				$q.ech config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -1048577]
			}
			"Kbytes" {
				$q.kbi config -state $d -bg [option get . background {}]
				set active_inpads [expr $active_inpads & -2097153]
			}
		}
	}
	if {$active_inpads} {
		switch -- $active_inpads {
			1   { OutOn Note 0}
			2   { OutOn Interval 0}
			4   { OutOn Semitone 0}
			8   { OutOn Octave 0}
			16  { OutOn dB 0}
			32  { OutOn Midi 0}
			64  { OutOn Frq 0}
			128 { OutOn Ratio 0}
			256 { OutOn Tstretch 0}
			512 { OutOn Gain 0}
			1024 { OutOn Delay 0}
			2048 { OutOn Tempo 0}
			4096 { OutOn Beats 0}
			8192 { OutOn Time 0}
			16384 { OutOn Samples 0}
			32768 { OutOn Sampv 0}
			65536 { OutOn Bars 0}
			131072 { OutOn Hours 0}
			262144 { OutOn MM 0}
			524288 { OutOn Metres 0}
			1048576 { OutOn Echo 0}
			2097152 { OutOn Kbytes 0}
		}
	}
}

#------ Set Output-type Buttons Inactive

proc PadOutputInactivate {} {
	global muc
	set q $muc.top.output.pad
	set d "disabled"
	$q.not config -state $d -bg [option get . background {}]
	$q.int config -state $d -bg [option get . background {}]
	$q.sem config -state $d -bg [option get . background {}]
	$q.oct config -state $d -bg [option get . background {}]
	$q.db  config -state $d -bg [option get . background {}]
	$q.mid config -state $d -bg [option get . background {}]
	$q.frq config -state $d -bg [option get . background {}]
	$q.fr  config -state $d -bg [option get . background {}]
	$q.str config -state $d -bg [option get . background {}]
	$q.gai config -state $d -bg [option get . background {}]
	$q.del config -state $d -bg [option get . background {}]
	$q.tem config -state $d -bg [option get . background {}]
	$q.bea config -state $d -bg [option get . background {}]
	$q.tim config -state $d -bg [option get . background {}]
	$q.smp config -state $d -bg [option get . background {}]
	$q.smv config -state $d -bg [option get . background {}]
	$q.bar config -state $d -bg [option get . background {}]
	$q.hrs config -state $d -bg [option get . background {}]
	$q.mm  config -state $d -bg [option get . background {}]
	$q.mtr config -state $d -bg [option get . background {}]
	$q.ech config -state $d -bg [option get . background {}]
	$q.kbi config -state $d -bg [option get . background {}]
}

#------ Set Output-type Buttons Active as flagged from Input-type

proc OutOn {item disable_keypads} {
	global pdi invaltype orig_pdf pdf mu pr_tempo muc evv oclcnt

	set oclcnt 0
	set q $muc.top.output.pad
	set n "normal"
	set d "disabled"

	if {$pdf > 0} {						;#	Save pdf, if this is first entry to OutOn
		set orig_pdf $pdf
	}
	if {$disable_keypads} {
		SetValueEntryPadStates -1 0			;#	disable pads for input values
	}
	PadOutputInactivate		;#	Ensure output functions are cleared before resetting
	set invaltype $item

	OddResetCalcpad ""

	set pr_tempo 0 ;# Forces any hanging tempo loop to fall out

	switch -- $item {
		"Midi" {
			$q.frq config -state $n -bg $evv(EMPH)
			$q.not config -state $n -bg $evv(EMPH)
			$q.del config -state $n -bg $evv(EMPH)
		}		
		"Frq" {
			$q.mid config -state $n -bg $evv(EMPH)
			$q.not config -state $n -bg $evv(EMPH)
			$q.tim config -state $n -bg $evv(EMPH)
			$q.mtr config -state $n -bg $evv(EMPH)
			if {$pdi <= $mu(MAXDFRQ)} {
				$q.del config -state $n -bg $evv(EMPH)
			}
		}
		"Note" {
			$q.mid config -state $n -bg $evv(EMPH)
			$q.frq config -state $n -bg $evv(EMPH)
			$q.del config -state $n -bg $evv(EMPH)
		}
		"Ratio" {
			$q.sem config -state $n -bg $evv(EMPH)
			$q.int config -state $n -bg $evv(EMPH)
			$q.oct config -state $n -bg $evv(EMPH)
			$q.str config -state $n -bg $evv(EMPH)
		}
		"Interval" {
			$q.fr  config -state $n -bg $evv(EMPH)
			$q.str config -state $n -bg $evv(EMPH)
			$q.sem config -state $n -bg $evv(EMPH)
		}
		"Semitone" {
			$q.fr  config -state $n -bg $evv(EMPH)
			$q.int config -state $n -bg $evv(EMPH)
			$q.oct config -state $n -bg $evv(EMPH)
			$q.str config -state $n -bg $evv(EMPH)
		}
		"Octave" {
			$q.fr  config -state $n -bg $evv(EMPH)
			$q.sem config -state $n -bg $evv(EMPH)
			$q.str config -state $n -bg $evv(EMPH)
		}
		"Tstretch" {
			$q.fr  config -state $n -bg $evv(EMPH)
			$q.int config -state $n -bg $evv(EMPH)
			$q.oct config -state $n -bg $evv(EMPH)
			$q.sem config -state $n -bg $evv(EMPH)
		}
		"Gain" {
			$q.db  config -state $n -bg $evv(EMPH)
			$q.smv config -state $n -bg $evv(EMPH)
		}
		"dB" {
			$q.gai config -state $n -bg $evv(EMPH)
			$q.smv config -state $n -bg $evv(EMPH)
		}
		"Delay" {
			if {$pdi <= $mu(MAXDEL) && $pdi >= $mu(MINDEL)} {
				$q.frq config -state $n -bg $evv(EMPH)
				$q.mid config -state $n -bg $evv(EMPH)
				$q.not config -state $n -bg $evv(EMPH)
			} else {
				$q.frq config -state $d -bg [option get . background {}]
				$q.mid config -state $d -bg [option get . background {}]
				$q.not config -state $d -bg [option get . background {}]
			}
			if {$pdi <= $mu(MAXTDEL) && $pdi >= $mu(MINTDEL)} {
				$q.tem config -state $n -bg $evv(EMPH)
			} else {
				$q.tem config -state $d -bg [option get . background {}]
			}
		}
		"Tempo" {
			$q.del config -state $n -bg $evv(EMPH)
		}
		"Beats" {
			$q.tim config -state $n -bg $evv(EMPH)
			$q.bar config -state $n -bg $evv(EMPH)
		}
		"Time" {
			$q.bea config -state $n -bg $evv(EMPH)
			$q.smp config -state $n -bg $evv(EMPH)
			$q.bar config -state $n -bg $evv(EMPH)
			$q.hrs config -state $n -bg $evv(EMPH)
			$q.frq config -state $n -bg $evv(EMPH)
			if {$pdi >= [expr 60.0 / $mu(MAXMMVAL)] && $pdi <= [expr 60.0 / $mu(MINMMVAL)]} {
				$q.mm  config -state $n -bg $evv(EMPH)
			} else {
				$q.mm config -state $d -bg [option get . background {}]
			}
			$q.kbi config -state $n -bg $evv(EMPH)
		}
		"Samples" {
			$q.tim config -state $n -bg $evv(EMPH)
		}
		"Sampv" {
			$q.db  config -state $n -bg $evv(EMPH)
			$q.gai config -state $n -bg $evv(EMPH)
		}
		"Bars" {
			$q.bea config -state $n -bg $evv(EMPH)
			$q.tim config -state $n -bg $evv(EMPH)
		}
		"Hours" {
			$q.tim config -state $n -bg $evv(EMPH)
		}
		"MM" {
			$q.tim config -state $n -bg $evv(EMPH)
			$q.frq config -state $n -bg $evv(EMPH)
		}
		"Metres" {
			$q.ech config -state $n -bg $evv(EMPH)
			$q.frq config -state $n -bg $evv(EMPH)
		}
		"Echo" {
			$q.mtr config -state $n -bg $evv(EMPH)
		}
		"Kbytes" {
			$q.tim config -state $n -bg $evv(EMPH)
		}
	}
	ForceVal $muc.bot.o ""
	$muc.bot.o config -bg [option get . background {}]
}

#------ Set Mode and RunPRogram, on pressing Output-type Button

proc RunMC {item} {
	global invaltype orig_pdf pdi mu pprg mmod CDPidrun CDP_cmd isqtone octpos pmcnt evv
	global pdo tempo srmul mpp from_tabedit pr_mu badcmd muc oclcnt

	set oclcnt 0
	set mu(recyc) ""
	$muc.bot.rr config -state disabled
	$muc.top.buttons.r2 config -state disabled
	set existing_prog $pprg
	set existing_mode $mmod

	MetreOff
	set pprg $evv(INFO_MUSUNITS)
	switch -- $invaltype {
		"Midi" {
			switch -- $item {
				Frq  {set mmod $mu(MU_MIDI_TO_FRQ)}
				Note {set mmod $mu(MU_MIDI_TO_NOTE)}
				Delay {set mmod $mu(MU_MIDI_TO_DELAY)}
			}
		}		
		"Frq" {
			switch -- $item {
				Midi {set mmod $mu(MU_FRQ_TO_MIDI)}
				Note {set mmod $mu(MU_FRQ_TO_NOTE)}
				Delay {set mmod $mu(MU_FRQ_TO_DELAY)}
				Time {set mmod $mu(MU_FRQ_TO_SECS)}
				Metres {set mmod $mu(MU_FRQ_TO_METRES)}
			}
		}
		"Note" {
			switch -- $item {
				Midi {set mmod $mu(MU_NOTE_TO_MIDI)}
				Frq  {set mmod $mu(MU_NOTE_TO_FRQ)}
				Delay {set mmod $mu(MU_NOTE_TO_DELAY)}
			}
		}
		"Ratio" {
			switch -- $item {
				Semitone {set mmod $mu(MU_FRQRATIO_TO_SEMIT)}
				Interval {set mmod $mu(MU_FRQRATIO_TO_INTVL)}
				Octave   {set mmod $mu(MU_FRQRATIO_TO_OCTS)}
				Tstretch {set mmod $mu(MU_FRQRATIO_TO_TSTRETH)}
			}
		}
		"Interval" {
			switch -- $item {
				Ratio    {set mmod $mu(MU_INTVL_TO_FRQRATIO)}
				Tstretch {set mmod $mu(MU_INTVL_TO_TSTRETCH)}
				Semitone {set mmod $mu(MU_INTVL_TO_SEMIT)}
			}
		}
		"Semitone" {
			switch -- $item {
				Ratio    {set mmod $mu(MU_SEMIT_TO_FRQRATIO)}
				Interval {set mmod $mu(MU_SEMIT_TO_INTVL)}
				Octave   {set mmod $mu(MU_SEMIT_TO_OCTS)}
				Tstretch {set mmod $mu(MU_SEMIT_TO_TSTRETCH)}
			}
		}
		"Octave" {
			switch -- $item {
				Ratio    {set mmod $mu(MU_OCTS_TO_FRQRATIO)}
				Tstretch {set mmod $mu(MU_OCTS_TO_TSTRETCH)}
				Semitone {set mmod $mu(MU_OCTS_TO_SEMIT)}
			}
		}
		"Tstretch" {
			switch -- $item {
				Ratio    {set mmod $mu(MU_TSTRETCH_TO_FRQRATIO)}
				Interval {set mmod $mu(MU_TSTRETCH_TO_INTVL)}
				Octave   {set mmod $mu(MU_TSTRETCH_TO_OCTS)}
				Semitone {set mmod $mu(MU_TSTRETCH_TO_SEMIT)}
			}
		}
		"Gain" {
			switch -- $item {
				dB		{set mmod $mu(MU_GAIN_TO_DB)}
				Sampv 	{set mmod $mu(MU_GAIN_TO_SAMPV)}
			}
		}
		"dB" {
			switch -- $item {
				Gain 	{set mmod $mu(MU_DB_TO_GAIN)}
				Sampv 	{set mmod $mu(MU_DB_TO_SAMPV)}
			}
		}
		"Delay" {
			switch -- $item {
				Midi {set mmod $mu(MU_DELAY_TO_MIDI)}
				Frq  {set mmod $mu(MU_DELAY_TO_FRQ)}
				Note {set mmod $mu(MU_DELAY_TO_NOTE)}
				Tempo {set mmod $mu(MU_DELAY_TO_TEMPO)}
			}
		}
		"Tempo" {
			switch -- $item {
				Delay {set mmod $mu(MU_TEMPO_TO_DELAY)}
			}
		}
		"Time" {
			switch -- $item {
				Beats {set mmod $mu(MU_TIME_TO_BEATS)}
				Samples {set mmod $mu(MU_TIME_TO_SAMPLES)}
				Bars {set mmod $mu(MU_TIME_TO_BARS) ; UpMetreOn}
				Hours {set mmod $mu(MU_SECS_TO_HMS)}
				MM {set mmod $mu(MU_SECS_TO_MM)}
				Frq {set mmod $mu(MU_SECS_TO_FRQ)}
				Kbytes {set mmod $mu(MU_TIME_TO_KBITS)}
			}
		}
		"Beats" {
			switch -- $item {
				Time {set mmod $mu(MU_BEATS_TO_TIME)}
				Bars {set mmod $mu(MU_BEATS_TO_BARS) ; UpMetreOn}
			}										 
		}
		"Samples" {
			switch -- $item {
				Time {set mmod $mu(MU_SAMPLES_TO_TIME)}
			}
		}
		"Sampv" {
			switch -- $item {
				Gain 	{set mmod $mu(MU_SAMPV_TO_GAIN)}
				dB 		{set mmod $mu(MU_SAMPV_TO_DB)}
			}
		}
		"Bars" {
			switch -- $item {
				Beats	{set mmod $mu(MU_BARS_TO_BEATS) ; UpMetreOn}
				Time 	{set mmod $mu(MU_BARS_TO_TIME)  ; UpMetreOn}
			}
		}
		"Hours" {
			switch -- $item {
				Time {set mmod $mu(MU_HMS_TO_SECS)}
			}
		}
		"MM" {
			switch -- $item {
				Time {set mmod $mu(MU_MM_TO_SECS)}
				Frq  {set mmod $mu(MU_MM_TO_FRQ)}
			}
		}
		"Metres" {
			switch -- $item {
				Echo {set mmod $mu(MU_METRES_TO_ECHO)}
				Frq  {set mmod $mu(MU_METRES_TO_FRQ)}
			}
		}
		"Echo" {
			switch -- $item {
				Metres {set mmod $mu(MU_ECHO_TO_METRES)}
			}
		}
		"Kbytes" {
			switch -- $item {
				Time {set mmod $mu(MU_KBITS_TO_TIME)}
			}
		}
		default {
			tk_messageBox -message "Error in MusicPad Logic" -type ok -parent $muc -icon error
			set existing_prog $pprg
			set existing_mode $mmod
			return
		}
	}
	if {$orig_pdf == $mu(PPAD)} {
		set pdi [DoAdjustsToPadParams $pdi]
	}
	if {$mmod < 0} {
		DoInternalCalc $existing_prog $existing_mode
	} else {
		set old_paramcnt $pmcnt
		set pmcnt 0
		set badcmd 0
		set CDP_cmd [AssembleCmdline 1]
		if {$badcmd} {
			set badcmd 0
			return
		}
		set pmcnt $old_paramcnt
		ModifyModeRepresentation
		if {$orig_pdf == $mu(NPAD)} {
			set pdn $evv(NUM_MARK)
			append pdn $pdi
			lappend CDP_cmd $pdn		
		} else {
			lappend CDP_cmd $pdi
		}
		set CDPidrun 0
		set mpp 0
		set sloom_cmd [linsert $CDP_cmd 1 "#"]
		if [catch {open "|$sloom_cmd"} CDPidrun] {
			ErrShow "$CDPidrun"
			ErrShow "Cannot run process [lindex $CDP_cmd 1]"
   		} else {
   			fileevent $CDPidrun readable "DisplayMusicPadResult"
			vwait mpp
   		}
		if {($mmod != $mu(MU_FRQ_TO_NOTE)) && ($mmod != $mu(MU_MIDI_TO_NOTE)) \
		 &&	($mmod != $mu(MU_FRQRATIO_TO_INTVL)) && ($mmod != $mu(MU_SEMIT_TO_INTVL)) \
		 && ($mmod != $mu(MU_TSTRETCH_TO_INTVL))} {
			set mu(recyc) [GetMuNumericPart]
		}
		set pprg $existing_prog
		set mmod $existing_mode
	}
	if {[string length $mu(recyc)] > 0} {
		$muc.bot.rr config -state normal
		$muc.top.buttons.r2 config -state normal
		catch {$muc.vtop.par config -bg $evv(EMPH)}
	}
	if {$from_tabedit} {
		set pr_mu 1
	}
}

#------ Calculator calcs done in GUI

proc DoInternalCalc {existing_prog existing_mode} {
	global pprg mmod pdi tempo mu upm dnm lastsrmul lastsrate srmul muc evv

	set mu(recyc) ""
	set e $muc.bot.o 
	set cb $muc.bot
	set ct $muc.top
	switch -regexp -- $mmod \
		^$mu(MU_BEATS_TO_TIME)$ - \
		^$mu(MU_TIME_TO_BEATS)$ {
			GetTempo
			if {[string length $tempo] > 0} {
				switch -regexp -- $mmod \
					^$mu(MU_BEATS_TO_TIME)$ {
						set tot	 [expr (($pdi * 60.0) / $tempo)]
						HoursMinsSecs $tot $e "Duration"
						set mu(recyc) $tot
					} \
					^$mu(MU_TIME_TO_BEATS)$ {
						set yxy [expr (($pdi / 60.0) * $tempo)]
						ForceVal $e "Number of beats is $yxy"
						set mu(recyc) $yxy
					}

				OddResetCalcpad beats
			}
		} \
		^$mu(MU_SAMPLES_TO_TIME)$ - \
		^$mu(MU_TIME_TO_SAMPLES)$ - \
		^$mu(MU_TIME_TO_KBITS)$	  - \
		^$mu(MU_KBITS_TO_TIME)$ {
			if {$srmul == 0} {
				set srmul 1
			}
			GetSrate 			;#	sets parameter 'tempo' with 'srate'
			if {[string length $tempo] > 0} {
				switch -regexp -- $mmod \
					^$mu(MU_SAMPLES_TO_TIME)$ {
						set tot	 [expr (double($pdi) / double($tempo * $srmul))]
						HoursMinsSecs $tot $e "Duration"
						set mu(recyc) $tot
						OddResetCalcpad srate
					} \
					^$mu(MU_TIME_TO_SAMPLES)$ {
						set yxy [expr round($pdi * $tempo * $srmul)]
						ForceVal $e "Number of samples is $yxy"
						set mu(recyc) $yxy
						OddResetCalcpad srate
					} \
					^$mu(MU_TIME_TO_KBITS)$ {
						set lastsrmul $srmul
						set lastsrate $tempo
						set ttt $tempo
						GetBsize
						set yxy [expr round(($pdi * ($tempo/8.0) * $srmul * $ttt)/1024.00) + $evv(CDP_HEADSIZE)]
						set srmul 0
						ForceVal $e "Filesize approx $yxy Kb"
						set mu(recyc) $yxy
						OddResetCalcpad bsize
					} \
					^$mu(MU_KBITS_TO_TIME)$ {
						set lastsrmul $srmul
						set lastsrate $tempo
						set ttt $tempo
						GetBsize
						set tot	 [expr (double(($pdi - $evv(CDP_HEADSIZE)) * 1024.0) / double(($tempo/8.0) * $srmul * $ttt))]
						set tot [expr int(round($tot * 1000.0))]
						set tot [DecPlaces [expr $tot /1000.0] 3]
						set srmul 0
						HoursMinsSecs $tot $e "Approx Duration"
						set mu(recyc) $tot
						OddResetCalcpad bsize
					}

			}
		} \
		^$mu(MU_SAMPV_TO_GAIN)$ - \
		^$mu(MU_SAMPV_TO_DB)$ {
			set val [expr ($pdi / double($mu(MAXSAMPVAL)))]
			if {$val < -1.0} {
				set val -1.0
			}
			if {$mmod == $mu(MU_SAMPV_TO_DB)} {
				set val [expr abs($val)]
				set out_str "Corresponds to value of "
				if {$val > [expr 1.0 - $evv(FLTERR)]} {
					set val 0
				} elseif {[flteq $val 0.0]} {
					set val $mu(MINDB)
					append out_str "less than "
				} else {
					set val [expr 1.0 / $val]
					set val [expr log10($val) * 20.0]
					set val [expr -$val]
				}
				if {$val < $mu(MINDB)} {
					set val $mu(MINDB)
					append out_str "less than "
				}
				append out_str "$val dB"
				ForceVal $e $out_str
			} else {
				ForceVal $e "Equivalent to gain value $val"
			}
			set mu(recyc) [GetMuNumericPart]
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_GAIN_TO_SAMPV)$ {
			if {$pdi > 1.0} {
				ForceVal $e "Gain above 1 doesn't correspond to a sample value."
			} else {
				if {$evv(BITRES) == "float"} {
					ForceVal $e "Corresponds to sample val $pdi"
				} else {
					ForceVal $e "Corresponds to sample val [expr round($pdi * $mu(MAXSAMPVAL))]"
				}
				set mu(recyc) [GetMuNumericPart]
			}
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_DB_TO_SAMPV)$ {
			if {$pdi > 0.0} {
				ForceVal $e "dB vals above 0 don't correspond to sample values."
			} elseif {$pdi > -$evv(FLTERR)} {
				ForceVal $e "Corresponds to sample value $mu(MAXSAMPVAL)"
				set mu(recyc) [GetMuNumericPart]
			} else {
				set val [expr (-$pdi / 20.0)]
				set val [expr pow(10.0,$val)]
				set val [expr $mu(MAXSAMPVAL) / $val]
				if {$evv(BITRES) != "float"} {
					set val [expr round($val)]
				}
				ForceVal $e "Corresponds to sample value $val"
				set mu(recyc) [GetMuNumericPart]
			}
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_BARS_TO_BEATS)$ - \
		^$mu(MU_BARS_TO_TIME)$ {
			set OK 1
			GetMetre
			if {[string length $tempo] > 0} {
				set tempo ""
				set bars [expr round(floor($pdi))]
				set beats [expr $pdi - $bars]
				if {$beats > 0} {
					set beats [string range $beats [expr [string first "." $beats] + 1] end]
					if {$beats > $upm} {
						ForceVal $e "Value must be \"bars.beats\" (beats < barlength)"
						set OK 0
					} 
				}
				if {$OK} {
					incr beats [expr $bars * $upm]
					if {$mmod == $mu(MU_BARS_TO_BEATS)} {
						set qwe $upm
						append qwe ":" $dnm
						ForceVal $e "$beats beats of 1/$dnm type at tempo $qwe "
						set mu(recyc) [GetMuNumericPart]
						$cb.o config -bg $evv(EMPH)
					} else {
						set upm $beats
						GetTempo
						if {[string length $tempo] > 0} {
							set tot	 [expr (($upm * 60.0) / $tempo)]
							set mu(recyc) $tot
							HoursMinsSecs $tot $e "Duration"
							OddResetCalcpad bars
						}
					}
				}
			}
		} \
		^$mu(MU_BEATS_TO_BARS)$ - \
		^$mu(MU_TIME_TO_BARS)$ {
			set OK 1
			GetMetre
			if {[string length $tempo] > 0} {
				set tempo ""
				if {$mmod == $mu(MU_TIME_TO_BARS)} {
					set OK 0
					ForceVal $muc.bot.ot ""
					GetTempo
					if {[string length $tempo] > 0} {
						set OK 1
					}
					set beats [expr ((double($pdi) * $tempo) / 60.0)]
					set tempo ""
				} else {
					set beats $pdi
				}
				if {$OK} {
					set bars [expr int(floor(double($beats) / $upm))]
					set beats [expr int($beats - ($bars * $upm))]
					append bars "." $beats
					set qwe $upm
					append qwe ":" $dnm
					if {$beats > 0} {
						ForceVal $e "There are $bars   $qwe bars (and extra beats)"
					} else {
						set bars [expr round($bars)]
						ForceVal $e "There are $bars    $qwe bars"
					}
					set mu(recyc) [GetMuNumericPart]
					$cb.o config -bg $evv(EMPH)
				}
			}
		} \
		^$mu(MU_HMS_TO_SECS)$ {
			set OK 1
			set hasmins 0
			set hms $pdi
			set sum 0
			if [regexp {hrs:} $hms] {
				set x [string first "hrs:" $hms]
				incr x -1
				set y [string range $hms 0 $x]
				incr sum [expr $y * 3600]
				incr x 5
				set hms [string range $hms $x end] 
				if {([string length $hms] > 0) && ![regexp {[^0-9]} $hms]} {
					ErrShow "Is the final value in MINUTES or SECONDS ??"
					$muc.top.numeric.pad.min config -state normal -bg $evv(EMPH)
					$muc.top.numeric.pad.sec config -state normal -bg $evv(EMPH)
					$muc.top.output.pad.sec  config -state disabled -bg [option get . background {}]
					set OK 0
				}
			}
			if {$OK} {
				if [regexp {mins:} $hms] {
					set hasmins 1
					set x [string first "mins:" $hms]
					incr x -1
					set y [string range $hms 0 $x]
					incr sum [expr $y * 60]
					incr x 6
					set hms [string range $hms $x end] 
				}
				if [regexp {secs} $hms] {
					set x [string first "secs" $hms]
					incr x -1
					set y [string range $hms 0 $x]
					incr sum $y
				} elseif {$hasmins && ([string length $hms] > 0)} {
					incr sum $hms
				}
				ForceVal $e "There are $sum seconds in $pdi"
				set mu(recyc) [GetMuNumericPart]
				$cb.o config -bg $evv(EMPH)
			}
		} \
		^$mu(MU_SECS_TO_MM)$ {
			set mm [DecPlaces [expr 60.0 / $pdi] 4]
			ForceVal $e "$mm MM has beat duration $pdi seconds"
			set mu(recyc) [GetMuNumericPart]
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_MM_TO_SECS)$ {
			set secs [expr 60.0 / $pdi]
			ForceVal $e "$secs seconds per beat at MM of $pdi"
			set mu(recyc) [GetMuNumericPart]
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_MM_TO_FRQ)$ {
			set hz [expr $pdi / 60.0]
			ForceVal $e "$hz Hz equivalent to MM of $pdi"
			set mu(recyc) [GetMuNumericPart]
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_INTVL_TO_SEMIT)$ {
			set smts ""
			set k 0
			if {[string match [string index $pdi 0] "-"]} {
				append smts "-"
				incr k
			}
			set sincr 0.0
			if {[string match [string index $pdi $k] "m"]} {
				set sincr -1.0
				incr k
			} elseif {[string match [string index $pdi $k] "#"]} {
				set sincr 1.0
				incr k
			}
			set j [expr [string length $pdi] - 1]
			if {[string match [string index $pdi $j] "u"]} {
				set sincr [expr $sincr + .5]
				incr j -1
			} elseif {[string match [string index $pdi $j] "d"]} {
				set sincr [expr $sincr - .5]
				incr j -1
			}
			set snum [string range $pdi $k $j]
			if {$snum >= 8} {
				set sincr [expr $sincr + 12.0]
				incr snum -7
			}
			switch -- $snum {
				"0" { set sout 0.0 }
				"2" { set sout 2.0 }
				"3" { set sout 4.0 }
				"4" { set sout 5.0 }
				"5" { set sout 7.0 }
				"6" { set sout 9.0 }
				"7" { set sout 11.0}
			}
			set sout [expr $sout + $sincr]
			append smts $sout
			ForceVal $e "$smts semitones"
			set mu(recyc) [GetMuNumericPart]
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_SECS_TO_HMS)$ {
			set secs $pdi
			set mins 0
			set hrs 0
			set outstr ""
			if {$secs > 60} {
				set mins [expr floor($secs / 60)]
				set secs [expr $secs - ($mins * 60)]
			}
			if {$mins > 60} {
				set hrs [expr floor($mins / 60)]
				set mins [expr $mins - ($hrs * 60)]
			}
			if {$hrs > 0} {
				append outstr $hrs " hrs: "
			}
			if {$mins > 0} {
				append outstr $mins " mins: "
			}
			append outstr $secs " secs"
			ForceVal $e "$pdi seconds = $outstr"
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_SECS_TO_FRQ)$ {
			set secs $pdi
			set outstr [expr 1.0 / double ($pdi)]
			set mu(recyc) $outstr
			ForceVal $e "$pdi seconds between events = a frequency of $outstr"
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_FRQ_TO_SECS)$ {
			set secs $pdi
			set outstr [expr 1.0 / double ($pdi)]
			set mu(recyc) $outstr
			ForceVal $e "$pdi Hz = cycle length of $outstr"
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_METRES_TO_ECHO)$ {
			set val [DecPlaces [expr (double($pdi) / $evv(SPEED_OF_SOUND)) * 2.0] 3]
			if {$val > 60.0} {
				HoursMinsSecs $val $e "Echo time: "
			} else {
				ForceVal $e "Echo time is $val secs"
			}
			set mu(recyc) $val
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_METRES_TO_FRQ)$ {
			set val [DecPlaces [expr $evv(SPEED_OF_SOUND) / (double($pdi)* 2.0)] 3]
			ForceVal $e "Frq is $val Hz"
			set mu(recyc) $val
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_FRQ_TO_METRES)$ {
			set val [DecPlaces [expr $evv(SPEED_OF_SOUND) / (double($pdi) * 2.00)] 3]
			ForceVal $e "Room Dimension is approx $val metres"
			set mu(recyc) $val
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_ECHO_TO_METRES)$ {
			set val [DecPlaces [expr ($pdi * $evv(SPEED_OF_SOUND)) / 2.0] 3]
			set mu(recyc) $val
			set msg "Distance is approx $val metres"
			if {$val > 1000.0} {
				append msg " = [DecPlaces [expr $val/1000.0] 3] km"
			}
			ForceVal $e $msg
			set mu(recyc) $val
			$cb.o config -bg $evv(EMPH)
		} \
		^$mu(MU_DELAY_TO_NOTE)$ {
			set val [expr $evv(SECS_TO_MS) / double($pdi)]
			if {($val > $mu(MAXMFRQ)) || ($val < $mu(MINMFRQ))} {
				ForceVal $e "Note is out of range"
			} else {
				set val [expr int(round([HzToMidi $val]))]
				set oct [expr int(floor($val / 12.0)) - 5]
				set val [MidiToNote $val]
				ForceVal $e "Note is (approx) $val$oct"
			}
			$cb.o config -bg $evv(EMPH)
		}

	set pprg $existing_prog
	set mmod $existing_mode
}

#------ Reset calcpad after doing options requiring 2nd inval

proc OddResetCalcpad {str} {
	global mu tempo srmul lastsrmul lastsrate muc evv readonlyfg readonlybg
	set d "disabled"

	set cb $muc.bot
	set ct $muc.top
	if {$str == ""} {
		$muc.bot.rr config -state disabled
	} else {
		$muc.bot.rr config -state normal
	}
	$ct.buttons.r2 config -state normal
#
#	set mu(recyc) [GetMuNumericPart]
#
	$cb.o config -bg $evv(EMPH)
	$cb.at config -state $d -bg [option get . background {}] -text ""
	$cb.lv config -state $d -bg [option get . background {}] -text ""
	$cb.lw config -state $d -bg [option get . background {}] -text ""
	$cb.rfg config -state $d -bg [option get . background {}] -text ""
	$cb.ot config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	if {$str == "srate"} {
		set lastsrmul $srmul
		set lastsrate $tempo
		set srmul 0
	}
	set tempo ""
}

#------ Hrs, Mins, Secs display, from secs

proc HoursMinsSecs {tot e str} {
	global mu
	set secs $tot
	set mins [expr floor($secs / 60.0)]
	set secs [expr $secs - ($mins * 60.0)]
	set hrs [expr floor($mins / 60.0)]
	set mins [expr $mins - ($hrs * 60.0)]
	if {$mins <= 0.0} {
		ForceVal $e "$str $secs seconds"
		set mu(recyc) [GetMuNumericPart]
	} elseif {$hrs <= 0.0} {
		ForceVal $e "$str $tot secs ( = $mins mins $secs secs)"
	} else {
		ForceVal $e "$str $tot secs ( = $hrs hrs $mins mins $secs secs)"
	}
}

#------ Internal to external representation: converted back in Cmdline parsing

proc ModifyModeRepresentation {} {
	global CDP_cmd

	set exmode [lindex $CDP_cmd 2]
	incr exmode
	set CDP_cmd [lreplace $CDP_cmd 2 2 $exmode]
}

#------ Diplay output of MusUnits calculation (or Error message) in results window

proc DisplayMusicPadResult {} {
	global CDPidrun pdo mpp muc evv

	if [eof $CDPidrun] {
		set mpp 0
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match INFO:* $line] {
			set line [string range $line 6 end] 
			set pdo $line
			ForceVal $muc.bot.o $line
			$muc.bot.o config -bg $evv(EMPH)
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			ForceVal $muc.bot.o $line
			$muc.bot.o config -bg $evv(EMPH)
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			ForceVal $muc.bot.o $line
			$muc.bot.o config -bg $evv(EMPH)
			set mpp 0
			catch {close $CDPidrun}
			return
		} elseif [string match END:* $line] {
			set mpp 0
			catch {close $CDPidrun}
			return
		} else {
			ErrShow "Invalid Message ($line) received from program."
			set mpp 0
			catch {close $CDPidrun}
			return
		}
	}
	update idletasks
}			

#------ Clear state of pad, to use it once again

proc ClearPad {recycle} {
	global pdi last_pdi lastpdo pdo isqtone tempo octpos pr_tempo was_rec orig_pdf muc readonlyfg readonlybg lastpdorecall oclcnt

	set oclcnt 0
	SetValueEntryPadStates 0 0
	PadInOff all
	PadOutputInactivate
	set isqtone 0
	set octpos -1

	if {$recycle} {
		if [StorePadflag last_pdf] {
			set last_pdi $pdi
			ForceVal $muc.top.buttons.v2 $pdi
		}
	} elseif {!$was_rec} {
		if [StorePadflag last_pdf] {
			set last_pdi $pdi
			ForceVal $muc.top.buttons.v2 $pdi
		}
	}

	set pdi ""
	if {[info exists pdo] && ([llength $pdo] > 0)} {
		if {![info exists lastpdo]} {
			set lastpdo [list $pdo]
		} elseif {![info exists lastpdorecall] || ($lastpdorecall == 0) } {
			if {![string match [lindex $lastpdo 0] $pdo]} {
				set lastpdo [linsert $lastpdo 0 $pdo]
			}
		}
	}
	set pdo ""
	$muc.bot.o config -bg  [option get . background {}]
	catch {$muc.vtop.par config -bg [option get . background {}]}
	set was_rec 0
	if {$recycle} {
		set was_rec 1
	}
	ForceVal $muc.top.buttons.e $pdi
	ForceVal $muc.bot.o $pdo
	$muc.bot.at config -bg [option get . background {}] -state disabled
	$muc.bot.lv config -bg [option get . background {}] -state disabled -text ""
	$muc.bot.lw config -bg [option get . background {}] -state disabled -text ""
	$muc.bot.rfg config -bg [option get . background {}] -state disabled -text ""
	set tempo ""
	ForceVal $muc.bot.ot $tempo
	$muc.bot.ot config -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	$muc.bot.rr config -state disabled
	set pr_tempo 0
	set orig_pdf 0
	catch {unset lastpdorecall}
}

#------ Ensure 'u' or 'd' comes before octave-number in pitch representation

proc DoAdjustsToPadParams {str} {
	global isqtone octpos

	set len [string length $str]
 	if {$octpos < 0} {					;#	If no octave specified, insert 0
		set is_end 0
		set endstr $len
		incr endstr -1
		if [regexp {[ud]$} $str] {
			incr endstr -1
			set is_end 1
		}	
		set pdn [string range $str 0 $endstr]
		append pdn 0
		set octpos [expr $endstr + 1]
		if {$is_end} {
			incr endstr
			append pdn [string range $str $endstr end]
		}			
		set str $pdn
	}
 	if {$isqtone && ($octpos >= 0)} {	;#	Ensure correct order of 1/4 tone and octave info
		incr len -1							  			;#	index of final character
		if {$isqtone > 0} {
			set k [string first u $str]
		} else {
			set k [string first d $str]
		}
		if {$k == $len} {								;#	if 'u' or 'd' is at end of expression
			incr octpos -1
			set pdn [string range $str 0 $octpos]
			if {$isqtone > 0} {
				append pdn u							;#	insert 'u' or 'd' before it
			} else {
				append pdn d
			}
			incr octpos
			incr len -1								 	;#	drop 'u' or 'd' off end
			append pdn [string range $str $octpos $len]
			set str $pdn
		}
	}
	return $str
}

#------ Entry of metre value on Calcpad p

proc GetMetre {} {
	global muc evv
	set pr_tempo 0
	UpMetreOn
	while {0 == 0} {
		tkwait variable pr_tempo
		if {$pr_tempo < 0} {
			return
		}
		if {!$pr_tempo} {
			set tempo ""
			break
		} elseif {([string length $tempo] <= 0)} {
			ForceVal $muc.bot.o "No metre entered"
			$muc.bot.o config -bg $evv(EMPH)
			continue
		}
		break
	}
	MetreOff
}

proc MetreOff {} {
	global muc
	if {![info exists .cpd]} {
		return
	}
	UpMetreOff
	DnMetreOff
	$muc.bot.at config -bg [option get . background {}] -state disabled -text ""
	$muc.lom.tpi config -bg [option get . background {}]
}

proc UpMetre {val} {
	global dnmtron tempo upm muc oclcnt
	set oclcnt 0
	UpMetreHi $val
	set i 2
	while {$i < 33} {
		set btn "$muc.lom."
		append btn $i "d"
		$btn config -state normal -bg [option get . background {}]
		incr i $i
	}
	set tempo ""
	if {![info exists dnmtron]} {
		DnMetreOn
	}
	set upm $val
}

proc DnMetre {val} {
	global dnm upm tempo oclcnt
	set oclcnt 0
	DnMetreHi $val
	set dnm $val
	set tempo "$upm : $dnm"
}

proc UpMetreOn {} {
	global tempo muc evv
	set i 2
	while {$i < 18} {
		$muc.lom.$i config -state normal -fg $evv(SPECIAL)
		incr i
	}
	$muc.bot.at config -state normal -text "METRE (Enter value & click here)" -bg $evv(EMPH)
	$muc.lom.tpi config -bg $evv(EMPH)
}

proc UpMetreOff {} {
	global muc
	set i 2
	while {$i < 18} {
		$muc.lom.$i config -state disabled -bg [option get . background {}] -fg [option get . foreground {}]
		incr i
	}
}

proc DnMetreOn {} {
	global dnmtron muc evv
	set i 2
	while {$i < 33} {
		set btn "$muc.lom."
		append btn $i "d"
		$btn config -state normal -fg $evv(SPECIAL)
		incr i $i
	}
	set dnmtron 1
}

proc DnMetreOff {} {
	global dnmtron muc
	set i 2
	while {$i < 33} {
		set btn "$muc.lom."
		append btn $i "d"
		$btn config -state disabled -bg [option get . background {}] -fg [option get . foreground {}]
		incr i $i
	}
	catch {unset dnmtron}
}

proc UpMetreHi {val} {
	global muc evv
	set i 2
	while {$i < 18} {
		if {$i == $val} {
			$muc.lom.$i config -bg $evv(EMPH)
		} else {
			$muc.lom.$i config -bg [option get . background {}]
		}
		incr i
	}
}

proc DnMetreHi {val} {
	global muc evv
	set i 2
	while {$i < 33} {
		set btn "$muc.lom."
		append btn $i "d"
		if {$i == $val} {
			$btn config -bg $evv(EMPH)
		} else {
			$btn config -bg [option get . background {}]
		}
		incr i $i
	}
}

#------ CALCULATOR kbits<->time, using bitsize (sets the parameter 'tempo' as bsize)

proc GetBsize {} {
	global pr_tempo tempo evv muc bsizemul mu
	set pr_tempo 0
	PadOn "bsize"
	$muc.bot.at config -bg $evv(EMPH) -state normal -text "SAMPSIZE (enter val & click here)"
	$muc.bot.lv config -state normal -text "Last value"
	$muc.bot.lw config -state normal -text "Stored val"
	$muc.bot.rfg config -state normal -text "Ref value"
	$muc.bot.ot config -state normal -foreground [option get . foreground {}]
	while {0 == 0} {
		tkwait variable pr_tempo
		if {$pr_tempo < 0} {
			return
		}
		if {!$pr_tempo} {
			set tempo ""
			break
		} elseif { ([string length $tempo] <= 0)} {
			ForceVal $muc.bot.o "No Sample size entered."
			$muc.bot.o config -bg $evv(EMPH)
			continue
		} elseif { ![IsNumeric $tempo] || ![ValidBsize $tempo]} {
			ForceVal $muc.bot.o "Invalid Sample size ($tempo) : (Only 32,24,16,8)"
			$muc.bot.o config -bg $evv(EMPH)
			continue
		}
		break
	}
	PadOff "bsize"
}

#------ CALCULATOR samples<->time, using srate (sets the parameter 'tempo' as srate)

proc GetSrate {} {
	global pr_tempo tempo evv muc mu
	set pr_tempo 0
	PadOn "srate"
	$muc.bot.at config -bg $evv(EMPH) -state normal -text "SRATE (enter value & click here)"
	$muc.bot.lv config -state normal -text "Last value"
	$muc.bot.lw config -state normal -text "Stored val"
	$muc.bot.rfg config -state normal -text "Ref value"
	$muc.bot.ot config -state normal -foreground [option get . foreground {}]
	while {0 == 0} {
		tkwait variable pr_tempo
		if {$pr_tempo < 0} {
			return
		}
		if {!$pr_tempo} {
			set tempo ""
			break
		} elseif { ([string length $tempo] <= 0)} {
			ForceVal $muc.bot.o "No sample rate entered."
			$muc.bot.o config -bg $evv(EMPH)
			continue
		} elseif { ![IsNumeric $tempo] || ![ValidSrate $tempo]} {
			ForceVal $muc.bot.o "Invalid Srate ($tempo) : (Only 48000,44100,32000,24000,22050,16000)"
			$muc.bot.o config -bg $evv(EMPH)
			continue
		}
		break
	}
	PadOff "srate"
}

#------ Check for valid srate

proc ValidSrate {srate} {
	switch -- $srate {
		96000 -
		88200 -
		48000 -
		44100 -
		32000 -
		24000 -
		22050 -
		16000   {}
		default	{return 0}
	}
	return 1
}

#------ Check for valid bitsize

proc ValidBsize {bsize} {
	switch -- $bsize {
		32 -
		24 -
		16 -
		8   {}
		default	{return 0}
	}
	return 1
}

#------ exclusive-highlight sample-pairing type button

proc SetSrmul {val btn} {
	global srmul lastsrmul lastsrate tempo existing_prog existing_mode muc evv oclcnt

	set oclcnt 0
 	set f $muc.33.pad
	if {$val == $evv(NUMEMORY)} {
		if {[info exists lastsrmul] && [info exists lastsrate]} {
			set srmul $lastsrmul
			set tempo $lastsrate
			ForceVal $muc.bot.ot $tempo
			ForceVal $muc.bot.o "Hit sample rate button."
			$muc.bot.o config -bg $evv(EMPH)
		} else {
			ForceVal  $muc.bot.o "Sample rate not previously used."
			$muc.bot.o config -bg $evv(EMPH)
			return
		}
	} else {
		set srmul $val
	}
	$f.cs2 config -bg [option get . background {}]
	$f.cs3 config -bg [option get . background {}]
	$f.cs4 config -bg [option get . background {}]
	$f.cs5 config -bg [option get . background {}]
	$f.cs6 config -bg [option get . background {}]
	$f.cs7 config -bg [option get . background {}]
	$f.cs8 config -bg [option get . background {}]
	$f.cs9 config -bg [option get . background {}]
	$f.cs12 config -bg [option get . background {}]
	$f.cs13 config -bg [option get . background {}]
	$f.cs16 config -bg [option get . background {}]
	$f.cp config -bg [option get . background {}]
	$f.ag config -bg [option get . background {}]
	switch -- $btn {
		cs2 { $f.cs2 config -bg $evv(EMPH) }
		cs3 { $f.cs3 config -bg $evv(EMPH) }
		cs4 { $f.cs4 config -bg $evv(EMPH) }
		cs5 { $f.cs5 config -bg $evv(EMPH) }
		cs6 { $f.cs6 config -bg $evv(EMPH) }
		cs7 { $f.cs7 config -bg $evv(EMPH) }
		cs8 { $f.cs8 config -bg $evv(EMPH) }
		cs9 { $f.cs9 config -bg $evv(EMPH) }
		cs12 { $f.cs12 config -bg $evv(EMPH) }
		cs13 { $f.cs13 config -bg $evv(EMPH) }
		cs16 { $f.cs16 config -bg $evv(EMPH) }
		cp { $f.cp config -bg $evv(EMPH) }
	}
}

#------ Set Bite Size

proc SetBsize {val} {
	global lastbsize lastbsize tempo muc evv oclcnt

	set oclcnt 0
 	set f $muc.34.pad
	if {$val == $evv(NUMEMORY)} {
		if {[info exists lastbsize]} {
			set tempo $lastbsize
			ForceVal $muc.bot.ot $tempo
			ForceVal $muc.bot.o "Hit Sample Size button."
			$muc.bot.o config -bg $evv(EMPH)
		} else {
			ForceVal $muc.bot.o "Sample Size not previously used."
			$muc.bot.o config -bg $evv(EMPH)
			return
		}
	} else {
		set lastbsize $val
		set tempo $val
		ForceVal $muc.bot.ot $tempo
		ForceVal $muc.bot.o "Hit Sample Size button."
		$muc.bot.o config -bg $evv(EMPH)
	}
	$f.ag config -bg [option get . background {}]
}

#------ Find numeric part of Calculator result (if any)

proc GetMuNumericPart {} {
	global pdo
	set str $pdo
	set len [string length $str]
	set atfin 0
	set pntcnt 0
	set finished 0
	while {!$finished} {
		set k 0
		while {![regexp {[0-9\.\-]} [string index $str $k]]} {
			incr k
			if {$k >= $len} {					;#	if at end of string, no possble numeric string (pns) chars found
				return ""
			}
		}
		set str [string range $str $k end]		;#	set up a searchstring starting at pns start
		set len [string length $str]	
		set firstchar [string index $str 0]		;#	remember first char of pns
		set k 1
		set this [string index $str $k] 		;#	get next char of ditto
		while {[regexp {[0-9\.]} $this]} {		;#	while subsequent chars are part of a pns
			if [string match "." $this] {		;#	count decimal points
				incr pntcnt
				if {$pntcnt > 1} {				;#	if a 2nd point occurs, we're at end of a pns
					break						;#	so break from this inner loop
				}
			}
			incr k								;#	proceed to next char
			if {$k >= $len} {					;#	if at end of string, break from inner loop
				set atfin 1
				break
			}
			set this [string index $str $k] 	;#	Get next char of pns
		}
												;#	On reaching end of pns
		set fin $k								;#  note the end-of-pns index
		incr fin -1								;#	(indeces are inclusive)
												;#	if only 1 char in pns, and its a '.' or a '-': not a number
		if {($fin == 0) && [regexp {[\.\-]} $firstchar]} {
			if {$atfin} {							;#	if at string end, return
				return ""
			} else {								;# otherwise start looking again from this position
				set pntcnt 0
				set str [string range $str $k end]
				set len [string length $str]	
			}
		} else {
			set finished 1						;#	otherwise we've found a numeric string, break from outer loop
		}
	}
	set str [string range $str 0 $fin]
	return $str
}

#------ Set Calculator val to output, previous or stored val, and reset calculator entry-state

proc NumCalcRecyc {item} {
	global pdi pdf last_pdi last_pdf pdf_store nstor mu muc oclcnt

	set oclcnt 0
	switch -- $item {
		recycle {
			set pdn $mu(recyc)
			if {[string length $pdn] <= 0} {
				return
			}
			ClearPad 1
			set pdf $mu(NPAD)
			SetupAsNumeric $pdn
			$muc.bot.rr config -state disabled
			$muc.top.buttons.r2 config -state disabled
			return
		}
		storout {
			if {[string length $mu(recyc)] <= 0} {
				return
			}
			set nstor $mu(recyc)
			ForceVal $muc.top.buttons.v4 $mu(recyc)
			set pdf $mu(NPAD)
			StorePadflag pdf_store
			return
		}
		last {
			if {$last_pdf <= 0} {
				return
			}
			set pdn $last_pdi
			set pdf $last_pdf
			set zz $pdf 
			ClearPad 1
			set pdf $zz
		}
		stored {
			if {$pdf_store <= 0} {
				return
			}
			set pdn $nstor
			set pdf $pdf_store
			set zz $pdf 
			ClearPad 1
			set pdf $zz
		}
	}		
	if {$pdf == $mu(NPAD)} {
		SetupAsNumeric $pdn
	} else {
		set orig_pdf $pdf
		set pdf -1
		SetValueEntryPadStates $pdf 1
		PadOutputInactivate
		if {$orig_pdf == $mu(PPAD)} {
			PadInOn Note
		} else {
			PadInOn Interval
		}
		set pdi $pdn
	}
}

#----- Setup calculator in numeric entry state

proc SetupAsNumeric {pdn} {
	global pdi pdf

	PadOff qtones

	SetValueEntryPadStates $pdf 1
	if [regexp {\.} $pdn] {
		PadOff decimal
	}
	set pdn [ResetInPads $pdn]
	PadOutputInactivate
	if {[string length $pdn] > 0} {
		if {$pdn > 0} {
			PadInOn Beats
			PadInOn Time
		}
		set pdi $pdn
	}
}

#----- Get previous value as Tempo or Srate

proc GetLastNumout {} {
	global tempo last_pdi
	if [IsNumeric $last_pdi] {
		set tempo $last_pdi
	}
}

#----- Get stored value as Tempo or Srate

proc GetStordNumout {} {
	global tempo nstor
	if [IsNumeric $nstor] {
		set tempo $nstor
	}
}

#----- Store entered value

proc StoreNumval {} {
	global nstor pdi pdf_store muc oclcnt
	set oclcnt 0
	if [StorePadflag pdf_store] {
		set nstor $pdi
		ForceVal $muc.top.buttons.v4 $pdi
	}
}

#----- Remember which input pad was used

proc StorePadflag {str} {
	global pdf orig_pdf pdf_store last_pdf

	if {$pdf <= 0} {
		if {$orig_pdf > 0} {
			set $str $orig_pdf
			return 1
		}
	} elseif {$pdf > 0} {
		set $str $pdf
		return 1
	}
	return 0
}

#----- Arithmetic operations on Calculator

proc Numc {item} {
	global nstor pdi pdo mu lastnumop muc evv oclcnt
	set oclcnt 0
	set val ""
	set OK 1
	if {$item == $evv(NUMEMORY)} {
		if [info exists lastnumop] {
			set item $lastnumop
		} else {
			set pdo "No previous numerical calculation."
			$muc.bot.o config -bg $evv(EMPH)
			return
		}
	}
	set lastnumop $item
	if [IsNumeric $pdi] {
		if {$item < 7} {
			if [IsNumeric $nstor] {
				if {($nstor < $evv(FLTERR)) && ($nstor > -$evv(FLTERR)) && ($item == 5 || $item == 7)} {
					set pdo "Divide by zero ??"
					set OK 0
				}
				if {($pdi < $evv(FLTERR)) && ($pdi > -$evv(FLTERR)) && $item == 6} {
					set pdo "Divide by zero ??"
					set OK 0
				}
			} else {
				set pdo "Cannot operate on non-numeric data"
				set OK 0
			}
		} elseif {$item==7} {
			if {$pdi < $evv(FLTERR) && $pdi > -$evv(FLTERR)} {
				set pdo "Divide by zero ??"
				set OK 0
			}
		} elseif {($pdi < $evv(FLTERR)) && ($item == 13 || $item == 14)} {
			set pdo "No log values for zero or negative numbers."
			set OK 0
		} elseif {($pdi < 0) && ($item == 16)} {
			set pdo "No square roots of negative numbers."
			set OK 0
		}
		if {$OK} {
			switch -- $item {
				1 {set val [expr $pdi + $nstor]}
				2 {set val [expr $pdi - $nstor]}
				3 {set val [expr $nstor - $pdi]}
				4 {set val [expr $pdi * $nstor]}
				5 {set val [expr double($pdi) / double($nstor)]}
				6 {set val [expr double($nstor) / double($pdi)]}
				7 {set val [expr 1.0 / $pdi]}
				8 {set val [expr round($pdi)]}
				9 {set val [expr floor($pdi)]}
				10 {set val [expr ceil($pdi)]}
				11 {	
					if {$pdi == 0.0} {
						set val 0
					} else {
						set val [expr -$pdi]
					}
				}
				12 {set val [expr abs($pdi)]}
				13 {set val [expr log10($pdi)]}
				14 {set val [expr log($pdi)]}
				15 {set val [expr $pdi * $pdi]}
				16 {set val [expr sqrt($pdi)]}
				17 {set val [expr fmod(double($pdi),double($nstor))]}
				18 {set val [expr exp($pdi)]}
			}
			set pdo $val
			set mu(recyc) $val
			$muc.bot.rr config -state normal
			$muc.top.buttons.r2 config -state normal
		}
	} else {
		set pdo "Cannot operate on non-numeric data"
	}
	$muc.bot.o config -bg $evv(EMPH)
}

proc GetTempo {} {
	global pr_tempo tempo evv mu muc
	set pr_tempo 0
	$muc.bot.at config -bg $evv(EMPH) -state normal -text "TEMPO (enter value & click here)"
	$muc.bot.lv config -state normal -text "Last value"
	$muc.bot.lw config -state normal -text "Stored value"
	$muc.bot.rfg config -state normal -text "Ref value"
	$muc.bot.ot config -state normal -foreground [option get . foreground {}]
	while {0 == 0} {
		tkwait variable pr_tempo
		if {!$pr_tempo} {
			set tempo ""
			break
		} elseif { ([string length $tempo] <= 0) || ![IsNumeric $tempo]} {
			ForceVal  $muc.bot.o "Invalid tempo value entered."
			$muc.bot.o config -bg $evv(EMPH)
			continue
		} elseif { $tempo < $mu(MINTEMPO) || $tempo > $mu(MAXTEMPO)} {
			ForceVal  $muc.bot.o "Tempo value is out of range."
			$muc.bot.o config -bg $evv(EMPH)
			continue
		}
		break
	}
}

proc DestroyCalc {} {
	global pr_mu
	set pr_mu 0
}

proc CalculatorOutputAsParam {} {
	global mu
	if {![info exists mu(recyc)] || ([string length $mu(recyc)] <= 0)} {
		Inf "No Valid Output Value"
		raise .cpd
		return
	}
	ValToParam .cpd 0
}

proc CalculatorOutputAsQikEditParam {} {
	global mu mixval pr_mu
	if {![info exists mu(recyc)] || ([string length $mu(recyc)] <= 0)} {
		Inf "No Valid Output Value"
		raise .cpd
		return
	}
	set mixval $mu(recyc)
	set pr_mu 1
}

proc CalculatorOutputAsTEParam {} {
	global tabed colpar mu pr_mu
	if {![info exists mu(recyc)] || ([string length $mu(recyc)] <= 0)} {
		Inf "No Valid Output Value"
		raise .cpd
		return
	}
	set colpar $mu(recyc)
	ForceVal $tabed.mid.par1 $colpar
	set pr_mu 1
}

proc CalculatorOutputAsValue {ll} {
	global mu pr_mu
	if {![info exists mu(recyc)] || ([string length $mu(recyc)] <= 0)} {
		Inf "No Valid Output Value"
		raise .cpd
		return
	}
	$ll insert insert $mu(recyc)
	set pr_mu 1
}

proc GetParamToCalc {tostore} {
	global validplist prm pmcnt refp pr_ptoc gdg_typeflag parname evv oclcnt
	set oclcnt 0
	switch -- $pmcnt {
		0 {	return }
		1 {
			if {!$refp(0) || ![IsNumeric $prm(0)]} {
				return
			}
			InputNumberToCalc 0 $tostore
			return
		}
	}
	set f .ptocalc
	if [Dlg_Create .ptocalc "Get Parameter Value" "set pr_ptoc 0" -borderwidth $evv(BBDR)] {
		button $f.quit -text "Close" -command "set pr_ptoc 0"
		pack $f.quit -side top -pady 2
		Scrolled_Listbox $f.ll -width 80 -height 20
		pack $f.ll -side top -fill both -expand true
		bind $f.ll.list <ButtonRelease-1> "GetPvalForCalc %y $tostore"
		bind $f <Return> {set pr_ptoc 0}
		bind $f <Escape> {set pr_ptoc 0}
		bind $f <Key-space> {set pr_ptoc 0}
	}
	set p_cnt 0
	set g_cnt 0
	set j 1
	catch {unset validplist}
	while {$p_cnt < $pmcnt} {
		if {[IsDeadParam $p_cnt]} {
			incr g_cnt
			incr p_cnt
			continue
		}
		if {$gdg_typeflag($g_cnt) == $evv(SWITCHED)} {
			incr p_cnt
		}
		if {$refp($p_cnt) && [IsNumeric $prm($p_cnt)]} {
			catch {unset line}
			set name $parname($g_cnt) 
			set name [string trim $name]
			set name [split $name "_"]
			set line $j
			append line " : " $name
			$f.ll.list insert end $line
			lappend validplist $p_cnt
		}
		incr p_cnt
		incr g_cnt
		incr j
	}
	if {![info exists validplist]} {
		Inf "No Numeric Parameter Values"
		catch {destroy .ptocalc}
		return
	}
	set pr_ptoc 0
	raise $f
	My_Grab 1 .ptocalc pr_ptoc
	tkwait variable pr_ptoc
	My_Release_to_Dialog .ptocalc
	Dlg_Dismiss .ptocalc
}

proc GetPvalForCalc {y tostore} {
	global validplist
	set i [.ptocalc.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	set k [lindex $validplist $i]
	InputNumberToCalc $k $tostore
}


proc InputNumberToCalc {k tostore} {
	global prm pr_ptoc time_limitval mu nstor muc
	switch -- $tostore {
		0 {			;# Param val to value
			set val $prm($k)
		}
		1 {			;# Paramval to store
			set nstor $prm($k)
			set pr_ptoc 0
			return
		}
		2 {			;# Qikedit val to value
			set val $k
		}
		3 {			;# Qikedit val to store
			set nstor $k
			set pr_ptoc 0
			return
		}
	}
	set len [string length $val]
	ClearPad 0
	PadOff pitch
	PadOff intervals
	PadOff qtones
	PadOn numerals
	set time_limitval 0
	set n 0
	while {$n < $len} {
		set char [string index $val $n]
		if {![AddOn $char $mu(NPAD)]} {
			ClearPad 0
			PadInOff all
			SetValueEntryPadStates 0 0
			break
		}
		incr n
	}
	set pr_ptoc 0
}

proc CalcRestoreOval {} {
	global pdo lastpdo lastpdorecall muc mu last_mu_recyc oclcnt
	set oclcnt 0
	if {[info exists lastpdo]} {
		if {![info exists lastpdorecall]} {
			if {[info exists pdo] && ([string length $pdo] > 0) && ![string match [lindex $lastpdo 0] $pdo]} {
				set lastpdo [linsert $lastpdo 0 $pdo]
				set pdo [lindex $lastpdo 1]
				ForceVal $muc.bot.o $pdo
				set last_mu_recyc [GetMuNumericPart]
				set lastpdorecall 1
			} else {
				set pdo [lindex $lastpdo 0]
				ForceVal $muc.bot.o $pdo
				set last_mu_recyc [GetMuNumericPart]
				set lastpdorecall 0
			}
		} else {
			set len [llength $lastpdo]
			incr lastpdorecall
			if {$lastpdorecall >= $len} {
				set lastpdorecall 0
			}
			set pdo [lindex $lastpdo $lastpdorecall]
			ForceVal $muc.bot.o $pdo
			set last_mu_recyc [GetMuNumericPart]
		}
	}
	set mu(recyc) $last_mu_recyc
	$muc.bot.r config -state normal
}

#--- Do algebraic operation on calculator values

proc AlgebraCalc {algexp} {
	global pdi pdo muc mu from_tabedit evv

	if {![IsNumeric $pdi]} {
		Inf "Cannot Do Algebra On Non-Numeric Values"
		return
	}
	set vlist [CheckAlgebra $algexp 0]
	if {[llength $vlist] <= 0} {
		return
	}
	set algexp [lindex $vlist 0]
	set nlist [lindex $vlist 1]
	set par_end [expr ([string length $algexp] - 1)]
	set algexpr ""
	set lastpos 0
	foreach pos $nlist {
		if {$pos > 0} {
			append algexpr [string range $algexp $lastpos [expr ($pos - 1)]]
		}
		append algexpr $pdi
		set lastpos [expr ($pos + 1)]
	}
	if {$pos < $par_end} {
		append algexpr [string range $algexp $lastpos end]
	}
	if [catch {set zz [expr ($algexpr)]} zub] {
		Inf "Invalid algebraic expression : '$algexp' produces '$algexpr'"
		return
	}
	set pdo $zz
	ForceVal $muc.bot.o $pdo
	$muc.bot.o config -bg $evv(EMPH)
	$muc.bot.rr config -state normal
	$muc.top.buttons.r2 config -state normal
	set mu(recyc) $pdo
	if {$from_tabedit} {
		set pr_mu 1
	}
}

proc MakeAlgebra {} {
	 global pr_calgebra colpar algebras calgebra wstk algname pdi evv oclcnt

	set oclcnt 0
	if {[string length $pdi] <= 0} {
		Inf "Enter A Value(V) First"
		return
	} elseif {![IsNumeric $pdi]} {
		Inf "Cannot Do Algebra On Non-Numeric Values"
		return
	}
	set f .calgebra
	set calgebra ""
	if [Dlg_Create $f "CREATE ALGEBRAIC FORMULAE" "set pr_calgebra 0" -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(SBDR)] 
		set f2 [frame $f.2 -borderwidth $evv(SBDR)] 
		set f3 [frame $f.3 -borderwidth $evv(SBDR)] 
		button $f1.sel  -text "Use" -command "set pr_calgebra 1"
		button $f1.quit -text "Abandon" -command "set pr_calgebra 0"
		pack $f1.sel -side left -padx 4
		pack $f1.quit -side right
		label $f2.lab -text "Algebraic Formula with 'z'"
		entry $f2.e -textvariable calgebra
		pack $f2.lab $f2.e -side left -pady 2 -padx 2
		pack $f1 -side top -fill x -expand true
		pack $f2 -side top
		wm resizable .calgebra 1 1
		bind $f <Return> {set pr_calgebra 1}
		bind $f <Escape> {set pr_calgebra 0}
	}
	set pr_calgebra 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_calgebra $f.2.e
	while {!$finished} {
		tkwait variable pr_calgebra
		switch -- $pr_calgebra {
			1 {
				set algalg [CheckAlgebraicExpression $calgebra 0]
				if {[llength $algalg] != 2} {
					continue
				}
				set nlist [lindex $algalg 0]
				set newcolpar [lindex $algalg 1]
				set stored 0
				if {[info exists algebras]} {
					foreach {inline algform} $algebras {
						if {[string match $newcolpar $algform]} {
							set stored 1
							break
						}
					}
				}
				if {!$stored} {
					set msg "Keep This Algebraic Formula For Future Use ?"
					set choice [tk_messageBox -message $msg -type yesno -icon question]
					if {$choice == "yes"} {
						GetAlgname
						lappend algebras $calgebra $newcolpar $algname
					}
				}
				AlgebraCalc $newcolpar
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

#----- Check validity of algebraic expression

proc CheckAlgebra {algexp fromtabed} {
	global tabed evv

;# CHECK FOR VARIABLE IN ALGEBRAIC EXPRESSION

	if {([string first z $algexp] < 0) && ([string first Z $algexp] < 0)} {
		set msg "Algebraic expression does not contain a 'Z': cannot proceed"
		if {$fromtabed} {
			ForceVal $tabed.message.e $msg
			$tabed.message.e config -bg $evv(EMPH)
		} else {
			Inf $msg
		}
		return {}
	}
	set i 0
	set OK 1

;# CONVERT TO FLOAT, IF NECESSARY

	set gotpoint 0
	set gotint 0
	set isfloated 0
	set iend [expr ([string length $algexp] - 1)]
	while {$OK} {
		set char [string index $algexp $i]
		if {[regexp {[0-9]} $char]} {				;# ignore 'log10' and atan2
			set gotint 1
			if {$i > 2} {
				set j [expr ($i - 3)]
				if {[regexp {log} [string range $algexp $j [expr ($i - 1)]]]} {
					incr i
					continue
				}
			}
			if {$i > 3} {
				set j [expr ($i - 4)]
				if {[regexp {log1|atan} [string range $algexp $j [expr ($i - 1)]]]} {
					incr i
					continue
				}
			}
			set j $i	
			while {[regexp {[0-9]} [string index $algexp $j]]} {
				incr j
				if {$j > $iend} {
					if {!$gotpoint} {
						append algexp ".0"
						set iend [expr ([string length $algexp] - 1)]
						set OK 0
						break
					}
				}
			}
			if {$OK} {
				if {![regexp {[\.Zz]} [string index $algexp $j]]} {
					if {($i > 0 ) && $gotpoint} {
						set i $j
						set gotpoint 0
						set gotint 0
						continue
					} 
					set zz [string range $algexp 0 [expr ($j - 1)]]
					append zz ".0"
					append zz [string range $algexp $j end]
					set algexp $zz
					set iend [expr ([string length $algexp] - 1)]
					incr j 2
					set i $j
				}
			}
		} elseif {[string match $char "."]} {
			set gotpoint 1
		} else {
			if {$gotpoint && !$gotint} {
				set msg "Invalid algebraic expression: cannot proceed"
				if {$fromtabed} {
					ForceVal $tabed.message.e $msg
 					$tabed.message.e config -bg $evv(EMPH)
				} else {
					Inf $msg
				}
				return {}
			}
			set gotpoint 0
			set gotint 0
		}
		incr i
		if {$i >= $iend} {
			break
		}
	}

;# CALCULATE POSITIONS OF ALL VARIABLES IN ALGEBRAIC EXPRESSION

	set n 0
	while {$n < [string length $algexp]} {
		if {[regexp {^[Zz]$} [string index $algexp $n]]} {
			lappend nlist $n
		}
		incr n
	}
	set i 0
	set OK 1


;#	CHANGE TO VALID EXPRESSION FORMAT e.g "-5.222N" to "(-5.222 * N)"

	while {$OK} {
		set iend [expr ([string length $algexp] - 1)]
		if {[set pos [lsearch $nlist $i]] >= 0} {		;#	if this character is a 'Z'
			if {$i < $iend} {
				set j [expr ($i + 1)]
				if {[regexp {[0-9\^\|]} [string index $algexp $j]]} {
					set msg "Invalid algebraic expression: cannot proceed"
					if {$fromtabed} {
						ForceVal $tabed.message.e $msg
 						$tabed.message.e config -bg $evv(EMPH)
					} else {
						Inf $msg
					}
					return {}
				}
			}
			if {$i > 0} {								;#  and it's not the first character
				set j [expr ($i - 1)]					;#  if the preceding character is a number (e.g. making 2Z)
				if {[regexp {[0-9]} [string index $algexp $j]]} {
					set k $j							;#  search backwards for a whole numeric expression (e.g.  -5.222Z)
					while {$k > 0} {
						incr  k -1
						if {![IsNumeric [string range $algexp $k $j]]} {
							incr k
							break
						}
					}
					if {$k > 0} {
						set newstr [string range $algexp 0 [expr ($k - 1)]]
					} else {
						set newstr ""
					}
					append newstr "("					;#  replace it with a brackted expression (e.g. (-5.222 * Z))
					append newstr [string range $algexp $k $j]
					append newstr " * Z)"
					append newstr [string range $algexp [expr ($i + 1)] end]
					set algexp $newstr
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
		if {$i >= [string length $algexp]} {
			break
		}
	}
	return [list $algexp $nlist]
}

proc InputMidiToCalc {midival} {
	global prm pr_ptoc time_limitval mu nstor muc
	set len [string length $midival]
	ClearPad 0
	PadOff pitch
	PadOff intervals
	PadOff qtones
	PadOn numerals
	set time_limitval 0
	set n 0
	while {$n < $len} {
		set char [string index $midival $n]
		if {![AddOn $char $mu(NPAD)]} {
			ClearPad 0
			PadInOff all
			SetValueEntryPadStates 0 0
			break
		}
		incr n
	}
	set pr_ptoc 0
}

proc CalcTimer {} {
	global ocl oclcnt mu evv
	lappend ocl [clock clicks]
	incr oclcnt
	if {$oclcnt == 2} {
		set val [expr [lindex $ocl 1] - [lindex $ocl 0]]
		set val [DecPlaces [expr double($val) / double($evv(CLOCK_TICK))] 4]
		set oclcnt 0
		unset ocl
		ClearPad 0
		set len [string length $val]
		set k 0
		while {$k < $len} {
			AddOn [string index $val $k] $mu(NPAD)
			incr k
		}
	}
}


