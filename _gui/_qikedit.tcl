#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD June 30 2013
# ... fixup button rectangles

######################
# QIK MIXFILE EDITOR #
######################

#------ Display a named mixfile for editing, from Paramspage

proc EditSrcMixfile {typ} {
	global pr12_34 wl do_parse_report pa mix_outchans bulk ins evv
	global pr3 pr2 favors current_favorites chlist pprg vm_i longqik lastlongqik origmixdur
	global rememd actvhi tempmix mixval m_list mlst last_mix prm initial_mlst mlsthead mchanqikfnam
	global mm_multichan qikeditmixname qikeditext wstk mixrestorename qik_typ qik_bakups_cnt qikwhole qikmixdur
	global qiki qikclik qikgain last_qikfnam last_qikparams last_main_qikparams main_qiki main_qikclik main_mix is_the_main
	global stage_output_chans qikmixset qe_last_sel dobakuplog plchan_max qikkeepfnam qikdelfnams collapsemenu
	global mixd2 small_screen qkvbox qikmixstart lastmixval qikedval qikedvalup qikedvaldn

	set qikmixstart ""
	if {[info exists lastlongqik] && ($longqik != $lastlongqik)} {
		destroy .mixdisplay2
	}
	catch {unset plchan_max}
	catch {unset mlsthead}
	set qikwhole 0
	set tempmix 1
	catch {destroy .cpd}
	set save_mixmanage 0
	set qik_typ $typ
	set OK 1
	if {$typ == "mix"} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			return
		}
		set fnam [lindex $chlist 0]
		if {[IsAMixfile $pa($fnam,$evv(FTYP))]} {
			set mm_multichan 0
			set mix_outchans 2
		} elseif {$pa($fnam,$evv(FTYP)) == $evv(MIX_MULTI)} {
			set mm_multichan 1
			set mix_outchans $pa($fnam,$evv(OUT_CHANS))
		} else {
			Inf "$fnam Is Not A Mixfile"
			return
		}
		set qikmixstart $prm(0)
		update idletasks
	} elseif {$typ == "mix3"} {
		set fnam $mchanqikfnam
		set mix_outchans $stage_output_chans
		set mm_multichan 1
		set prm(0) 0
		set prm(1) $pa($fnam,$evv(DUR))
		set prm(2) 1.0
	} elseif {$typ == "mix0"} {
		set fnam [lindex $chlist 0]
		catch {destroy .mixdisplay2}
		set mix_outchans $pa($fnam,$evv(OUT_CHANS))
		if {![IsAMixfile $pa($fnam,$evv(FTYP))]} {
			set mm_multichan 1
		} else {
			set mm_multichan 0
		}
		set typ "mix"
		set qik_typ $typ
	} else {
		catch {destroy .mixdisplay2}
		if {![info exists vm_i] || ($vm_i < 0)} {
			Inf "No Mixfile Selected"
			return
		}
		set fnam [.scvumix2.e.1.ll.list get $vm_i]
		set mix_outchans 2
		set mm_multichan 0
		set prm(0) 0
		set prm(1) $pa($fnam,$evv(DUR))
		set prm(2) 1.0
	}
	set mixrestorename $fnam
	if {[info exists main_mix(fnam)] && [string match $mixrestorename $main_mix(fnam)]} {
		set is_the_main 1
	} else {
		set is_the_main 0
	}
	if {![info exists qikmixset]} {
		if {$is_the_main} {
			if {[info exists last_main_qikparams]} {
				set prm(0) [lindex $last_main_qikparams 0]
				set prm(1) [lindex $last_main_qikparams 1]
				set prm(2) [lindex $last_main_qikparams 2]
			}
		} elseif {[info exists last_qikfnam] && [string match $fnam $last_qikfnam]} {
			if {[info exists last_qikparams]} {
				set prm(0) [lindex $last_qikparams 0]
				set prm(1) [lindex $last_qikparams 1]
				set prm(2) [lindex $last_qikparams 2]
			}
		} 
		set qikmixset 1
	}
	set qikeditext [file extension $fnam]

	if [Dlg_Create .mixdisplay2 $fnam "set pr12_34 0" -borderwidth $evv(BBDR) -width 1200] {

		if {$small_screen} {
			set can [Scrolled_Canvas .mixdisplay2.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 1300 $evv(SCROLL_HEIGHT)"]
			pack .mixdisplay2.c -side top -fill x -expand true
			set f [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $f
			set mixd2 $f
		} else {
			set f .mixdisplay2
			set mixd2 $f
		}	
		set f1  [frame $f.1 -borderwidth $evv(SBDR)]
		set help [frame $f1.h]
#RWD Oct 2024
		if { $::tcl_platform(platform) == "windows" } {
			button $help.hlp -text "Help" -bg $evv(HELP) -command "ActivateHelp $mixd2.1.h" -width 4
		} else {		
			button $help.hlp -text "Help" -bg $evv(HELP) -command "ActivateHelp $mixd2.1.h" -width 4 -highlightbackground [option get . background {}]
		}
		label  $help.conn -text "" -width 13
#RWD Oct 2024
		if { $::tcl_platform(platform) == "windows" } {
			button $help.con -text "" -borderwidth 0 -state disabled -width 8
			label $help.help -width 84 -text "$evv(HELP_DEFAULT)"
		} else {
			button $help.con -text "" -borderwidth 0 -state disabled -width 8 -highlightbackground [option get . background {}]
			label $help.help -width 84 -text "$evv(HELP_DEFAULT)" -fg [option get . foreground {}]
		}
		pack $help.hlp $help.conn $help.con $help.help -side left
		if {$longqik} {
			button $help.tips -text "Tips" -bg $evv(HELP) -command "TipsQik" -width 4 -highlightbackground [option get . background {}]
			pack $help.tips -side left
		}
		pack $help -side top -padx 1 -anchor w
		set f2  [frame $f.2 -borderwidth $evv(SBDR)]
		set bb [frame $f1.title -borderwidth $evv(SBDR)]
		set b  [frame $f1.button -borderwidth $evv(SBDR)]
		label $bb.title -text "STANDARD MIXFILE" -font bigfnt
		pack $bb.title -side top -pady 8
		set u  [frame $f1.u -borderwidth $evv(SBDR)]
#RWD Oct 2024
		if { $::tcl_platform(platform) == "windows" } {
			button $u.gp -text "Get Previous State"  -width 17 -command {MixModify reinstate $m_list $mixval $tempmix; set tempmix 1} -background $evv(EMPH)
			button $u.ii -text "Get Initial State"  -width 17 -command {MixRestore 0} -background $evv(EMPH) 
		} else {	
			button $u.gp -text "Get Previous State"  -width 17 -command {MixModify reinstate $m_list $mixval $tempmix; set tempmix 1} -background $evv(EMPH) -highlightbackground [option get . background {}]
			button $u.ii -text "Get Initial State"  -width 17 -command {MixRestore 0} -background $evv(EMPH) -highlightbackground [option get . background {}]
		}
		
		button $u.rs -text "Restore Original"  -width 17 -command {MixRestore 1} -background $evv(EMPH) -highlightbackground [option get . background {}]
		button $u.view -text "View Selected Sound" -command "QikEditor view" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $u.getm  -text "Sounds To Submix" -command "QikEditGet 1" -bg $evv(QUIT_COLOR) -highlightbackground [option get . background {}]
		button $u.get  -text "Sound To Wkspace" -command "QikEditGet 0" -bg $evv(QUIT_COLOR) -highlightbackground [option get . background {}]
		pack $u.gp $u.ii $u.rs $u.view $u.getm $u.get -side left -padx 2
		set s  [frame $f1.see -borderwidth $evv(SBDR)]
		button $b.ok -text "Quit (no edit)" -width 14 -command "set pr12_34 0" -bg $evv(QUIT_COLOR) -highlightbackground [option get . background {}]
		button $b.ed -text "Keep Edited Version" -width 19 -command "set pr12_34 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.sk -text "Search" -width 5 -command "SearchQikEdit 0" -highlightbackground [option get . background {}]
		button $b.ag -text "Again" -width 5 -command "SearchQikEdit 1" -highlightbackground [option get . background {}]
		button $b.go -text "Go To time(Value)"	-command GotoTimeQik -highlightbackground [option get . background {}]
		button $b.ca -text "Calculator" -width 8 -command "MusicUnitConvertor 6 0" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $b.re -text "Ref" -width 4 -command "QikRef" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $b.no -text "Notebook" -width 8 -command NnnSee -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $b.aa -text "A" -bd 4 -command "PlaySndfile $evv(TESTFILE_A) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $b.kk -text "K" -command "Shortcuts qik" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $b.ed -side left -padx 1
		pack $b.ok $b.go $b.ag $b.sk $b.ca $b.re $b.no $b.aa $b.kk -side right -padx 2
		frame $s.00 
		label $s.00.sel -text " Time In Line: To Mix Param"	
		button $s.00.stt -text "Start" -command "QikEditor stt" -width 5 -highlightbackground [option get . background {}]
		button $s.00.end -text "End" -command "QikEditor end" -width 5 -highlightbackground [option get . background {}]
		label $s.00.sel2 -text " Time In Line: To Calculator"	
		button $s.00.clc1 -text "Value" -command "QikEdToCalc calcv" -width 5 -highlightbackground [option get . background {}]
		button $s.00.clc2 -text "Store" -command "QikEdToCalc calcs" -width 5 -highlightbackground [option get . background {}]
		label $s.00.atte1 -text "Channel Levels " 
		button $s.00.seel -text " See " -command "SeeChannelLevels" -highlightbackground [option get . background {}]
		button $s.00.atten -text "Attenuate" -command "SetChannelAttenuation" -highlightbackground [option get . background {}]
		pack $s.00.sel $s.00.stt $s.00.end $s.00.sel2 $s.00.clc1 $s.00.clc2 -side left -padx 1
		pack $s.00.atte1 -side left -padx 6
		pack $s.00.seel $s.00.atten -side left -padx 2
		pack $s.00 -side top -pady 10
		frame $s.00x
		label $s.00x.dum -text "" -width 0
		label $s.00x.sel -text " SEND VALUE: To Calculator"	
		button $s.00x.clc1 -text "Value" -command "QikEdToCalc calcvv" -width 5 -highlightbackground [option get . background {}]
		button $s.00x.clc2 -text "Store" -command "QikEdToCalc calcsv" -width 5 -highlightbackground [option get . background {}]
		label $s.00x.sel2 -text " To Mix Params"	
		button $s.00x.stt -text "Start" -command "QikEditor sttval" -width 5 -highlightbackground [option get . background {}]
		button $s.00x.end -text "End"   -command "QikEditor endval" -width 5 -highlightbackground [option get . background {}]
		button $s.00x.gai -text "Gain"  -command "QikEditor mixamp" -width 5 -highlightbackground [option get . background {}]
		label $s.00x.ggg -text "Gain is now "
		entry $s.00x.gan -textvariable qikgain  -width 8 -state readonly
		button $s.00x.gnw -text "1.0"  -command {set prm(2) 1.0; set qikgain 1.0} -highlightbackground [option get . background {}]

		pack $s.00x.dum $s.00x.sel $s.00x.clc1 $s.00x.clc2 $s.00x.sel2 $s.00x.stt $s.00x.end $s.00x.gai $s.00x.ggg $s.00x.gan $s.00x.gnw -side left -padx 1
		pack $s.00x -side top -pady 4
		frame $s.000
		label $s.000.ll -text "SET VAL To"
		menubutton $s.000.frm -text "LineParam" -menu $s.000.frm.m -bd 2 -relief raised -width 15
		set m [menu $s.000.frm.m -tearoff 0]
		$m add command -label "TIME IN LINE" -command {} -background $evv(HELP) -foreground black
		$m add separator
		$m add command -label "End Time of Entire Mix" -command {MixfileLinevalToVal mixend} -foreground black
		$m add separator
		$m add command -label "Start Time Of Snd In Line" -command {MixfileLinevalToVal time} -foreground black
		$m add command -label "End Time Of Snd In Line"	  -command {MixfileLinevalToVal timend} -foreground black
		$m add command -label "Time Of Marked Event In Snd"	-command {MixfileLinevalToVal timemark} -foreground black
		$m add command -label "Duration Of Snd In Line"   -command "QikEditor dur" -foreground black
		$m add separator
		$m add command -label "TIME DIFFERENCE (2 LINES)" -command {} -background $evv(HELP) -foreground black
		$m add separator
		$m add command -label "Gap Between Start Times Of Snds" -command {MixfileLinevalToVal timediff} -foreground black
		$m add command -label "Gap Between End Times Of Snds"	-command {MixfileLinevalToVal timendiff} -foreground black
		$m add separator
		$m add command -label "COMPARE TIMES IN LINE & IN VALUE BOX" -command {} -background $evv(HELP) -foreground black
		$m add separator
		$m add command -label "Time Difference" -command {MixfileLinevalToVal timediff2} -foreground black
		$m add command -label "Time Sum"		-command {MixfileLinevalToVal timesum} -foreground black
		$m add separator
		$m add command -label "LEVEL" -command {} -background $evv(HELP) -foreground black
		$m add separator
		$m add command -label "Level Of Snd In Line" -command {MixfileLinevalToVal level} -foreground black
		$m add command -label "Maxgain Of Snd In Line (Cntrl g)" -command "MixfileLinevalToVal norm" -foreground black
		$m add command -label "Maxgain Of Snd In Line (force)" -command "MixfileLinevalToVal norm2" -foreground black
		$m add separator
		$m add command -label "POSITION" -command {} -background $evv(HELP) -foreground black
		$m add separator
		$m add command -label "Position Of Snd In Line" -command {MixfileLinevalToVal pos} -foreground black
		$m add separator
		$m add command -label "SUBMIX TIME" -command {} -background $evv(HELP) -foreground black
		$m add separator
		$m add command -label "Remember Starttime Of This Mix" -command {MixfileLinevalToVal memtimeset} -foreground black
		$m add command -label "Recall Remembered Starttime" -command {MixfileLinevalToVal memtimerecall} -foreground black

		button $s.000.tap -text "TapTime" -command MixTime -highlightbackground [option get . background {}]
		menubutton $s.000.mm -text "MM" -menu $s.000.mm.mm -bd 2 -relief raised -width 8
		set mm [menu $s.000.mm.mm -tearoff 0]
		$mm add command -label "Current Metronome Mark"			-command {QikSeeMM} -foreground black
		$mm add separator
		$mm add command -label "Set New Metronome Mark"			   -command {QikEditMM 0 0} -foreground black
		$mm add separator
		$mm add command -label "Add Beats At MM To Time In Value Box" -command {AddAtMM 0} -foreground black
		$mm add separator
		$mm add command -label "Add Beats At MM To Time In Lines" -command {AddAtMM 1} -foreground black
		$mm add separator
		$mm add command -label "Get Time-Equivalent Of MM Beats" -command {SetMMTime} -foreground black
		$mm add separator
		$mm add command -label "Round (Value Box) Time To Nearest MM Beat" -command {QikEditMMRound 1} -foreground black
		$mm add separator
		$mm add command -label "Express (Value Box) Time As MM Beat-Count" -command {QikEditMMRound 0} -foreground black
		$mm add separator
		$mm add command -label "File Starttime Placing Event At Beat In MM" -command {QikEditGetTimeAtMMBeat} -foreground black

		menubutton $s.000.mev -text "MixEnd" -menu $s.000.mev.m -bd 2 -relief raised -width 12
		set m2 [menu $s.000.mev.m -tearoff 0]
		$m2 add command -label "PARAMETER" -command {} -background $evv(HELP) -foreground black
		$m2 add separator
		$m2 add command -label "End-Of-Mix Parameter" -command "MixEndValQik 0" -foreground black
		$m2 add separator
		$m2 add command -label "~CURRENT~ MIX OUTPUT" -command {} -background $evv(HELP) -foreground black
		$m2 add separator
		$m2 add command -label "End-Time (Relative To Mix Timings)" -command "MixEndValQik 1" -foreground black
		$m2 add separator
		$m2 add command -label "Real Duration" -command "MixEndValQik 2" -foreground black
# RWD Oct 2024
		# here, this would be better on Mac as a label, but later on it becomes a real button)   
    	button $s.000.dumm1 -text "" -command {} -bd 0 -width 11 -highlightbackground [option get . background {}]
    	
			
		menubutton $s.000.ll2 -text "SelectLines" -menu $s.000.ll2.m -bd 2 -relief raised -width 13
		set m3 [menu $s.000.ll2.m -tearoff 0]
		$m3 add command -label "All" -command "QikEditorSelectAll" -foreground black
		$m3 add separator
		$m3 add command -label "All Unselected" -command "QikEditorSelectAllOther" -foreground black
		$m3 add separator
		$m3 add command -label "Starting At Time (in 'Value' box)" -command "QikEditorSelectAtTime 2" -foreground black
		$m3 add separator
		$m3 add command -label "Playing At Time (in 'Value' box)" -command "QikEditorSelectAtTime 0" -foreground black
		$m3 add separator
		$m3 add command -label "Contemporary (With selected lines)" -command "QikEditorSelectAtTime 1" -foreground black
		$m3 add separator
		$m3 add command -label "With N Channel Input" -command "QikEditorSelectInchans 0" -foreground black
		$m3 add separator
		$m3 add command -label "With Other Than N Channel Input" -command "QikEditorSelectInchans 1" -foreground black
		$m3 add separator
		$m3 add command -label "With No More Than N Channel Input" -command "QikEditorSelectInchans 2" -foreground black
		$m3 add separator
		$m3 add command -label "With More Than N Channel Input" -command "QikEditorSelectInchans 3" -foreground black
		$m3 add separator
		$m3 add command -label "String in \"Value\" Box" -command {} -background $evv(HELP) -foreground black
		$m3 add separator
		$m3 add command -label "Filename Contains String" -command "QikEditorSelectBystring 0" -foreground black
		$m3 add separator
		$m3 add command -label "Filename-segment Starts With String" -command "QikEditorSelectBystring 1" -foreground black
		$m3 add separator
		$m3 add command -label "Get Filename to \"Value\" Box" -command "GetFilenameToVal" -foreground black
# RWD Oct 2024
		if { $::tcl_platform(platform) == "windows" } { 
			button $s.000.dumm2 -text ""  -command {} -bd 0 -width 11
		} else {
			label $s.000.dumm2 -text "" -width 11
		}
		button $s.000.dft -text "Do Whole Mix" -command "QikEditor dflts" -width 13 -highlightbackground [option get . background {}]
		pack $s.000.ll $s.000.frm $s.000.mev $s.000.tap $s.000.mm $s.000.dumm1 $s.000.ll2 $s.000.dumm2 -side left -padx 1 
		pack $s.000.dft -side left -padx 4 
		pack $s.000 -side top -pady 2
		frame $s.1 
		if {$longqik} {
			set qikwid 85
		} else {
			set qikwid 100
		}
		set m_list [Scrolled_Listbox $s.1.seefile -width $qikwid -height $evv(QIKEDITLEN) -selectmode extended]
		pack $s.1.seefile -side top -fill both -expand true
		frame $s.1.foot2
		button $s.1.foot2.ss -text "Save And Mix Version" -command "QikSaveAndMix" -bg $evv(EMPH) -width 24 -highlightbackground [option get . background {}]
		button $s.1.foot2.mx -text "MaxSamp" -command "QikMaxsamp" -highlightbackground [option get . background {}]
		button $s.1.foot2.mq -text "MaxChan" -command MaxsampMultichanChans -highlightbackground [option get . background {}]
		label $s.1.foot2.ll -text "Last Output" -width 11
		button $s.1.foot2.pp -text "Play Sound" -command "QikOutView 0" -width 11 -highlightbackground [option get . background {}]
		button $s.1.foot2.cc -text "Play Chans" -command "PlayChannel 1" -width 9 -highlightbackground [option get . background {}]
		button $s.1.foot2.vv -text "View Sound" -command "QikOutView 1" -bg $evv(SNCOLOR) -width 11 -highlightbackground [option get . background {}]
		button $s.1.foot2.qq -text "Keep Sound Mixed Here" -command "QikKeep" -bg $evv(QUIT_COLOR) -width 24 -highlightbackground [option get . background {}]
		pack $s.1.foot2.ss $s.1.foot2.mx $s.1.foot2.mq $s.1.foot2.ll $s.1.foot2.pp $s.1.foot2.cc $s.1.foot2.vv $s.1.foot2.qq -side left -padx 2
		pack $s.1.foot2 -side top -pady 4
		frame $s.1.foot
		button $s.1.foot.b -text "Keep Copy Of Mix With New Name" -command SaveQikEditMix -highlightbackground [option get . background {}]
		label $s.1.foot.ll -text "Filename"
		entry $s.1.foot.n -textvariable qikeditmixname -width 24
		button $s.1.foot.rr -text "Recall A Previously Mixed Version" -command "QikRecall" -width 36 -highlightbackground [option get . background {}]
		pack $s.1.foot.b $s.1.foot.ll $s.1.foot.n $s.1.foot.rr -side left -padx 6 -pady 4
		pack $s.1.foot -side top -pady 2
		pack $s.1 -side top -pady 4
		pack $f1.button $f1.title -side top -fill x -expand true
		pack $f1.u -side top -pady 4
		pack $f1.see -side top -fill x -expand true
		if {$longqik} {
			label $f2.h -text "Modify Selected Lines"
			checkbutton $f2.t -variable tempmix -text "Temporary change only"
			frame $f2.l
			label $f2.l.vv -text "Value" -font bigfnt  -foreground black
			radiobutton $f2.l.la -text "Last" -variable qikedval -value 0 -command {QikLastVal} -foreground black
			radiobutton $f2.l.laup -text "Up" -variable qikedvalup -value 0 -command {QikUpVal 0} -foreground black
			radiobutton $f2.l.ladn -text "Dn" -variable qikedvaldn -value 0 -command {QikUpVal 1} -foreground black
			pack $f2.l.vv $f2.l.la $f2.l.laup $f2.l.ladn -side left
			set qkvbox [entry $f2.v -textvariable mixval -width 40]
		} else {
			frame $f2.hhh
			label $f2.hhh.l -text "Value" -font bigfnt 
			set qkvbox [entry $f2.hhh.v -textvariable mixval -width 40]
			checkbutton $f2.hhh.t -variable tempmix -text "Temp changes"
			button $f2.hhh.tips -text "Tips" -bg $evv(HELP) -command "TipsQik" -width 4 -highlightbackground [option get . background {}]
			pack $f2.hhh.l $f2.hhh.v $f2.hhh.t $f2.hhh.tips -side left
		}
		set f3 [frame $f2.3 -borderwidth $evv(SBDR)]
		set f31 [frame $f3.1 -borderwidth $evv(SBDR)]
		set f32 [frame $f3.2 -borderwidth $evv(SBDR)]
		set f33 [frame $f3.3 -borderwidth $evv(SBDR)]
		set f34 [frame $f3.4 -borderwidth $evv(SBDR)]
		label $f31.l2 -text "Timings" -fg $evv(SPECIAL)
		button $f31.mb -text "Move Time --> By"   -width 17 -command {MixModify move    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.mbb -text "Move Time <-- By"  -width 17 -command {MixModify move2   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.mt -text "Move Time(s) To"    -width 17 -command {MixModify moveto  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.mtx -text "Expand Times At"   -width 17 -command {MixModify move3   $m_list $mixval $tempmix; TempmixReset}
		button $f31.mt2 -text "Start Of Times To" -width 17 -command {MixModify moveto2 $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.mz -text "Mix Start To Zero"  -width 17 -command {MixModify tozero  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.st -text "Time Order Sounds"  -width 17 -command {MixModify sort    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		label $f31.l5 -text "Retime" -fg $evv(SPECIAL)
		button $f31.ov -text "Overlap Times By"   -width 17 -command {MixModify over    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.tg -text "Stagger By"         -width 17 -command {MixModify stagger $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.ex -text "Stretch Time By"    -width 17 -command {MixModify expand  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.ey -text "Stretch Steps By"   -width 17 -command {MixModify expandy $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.ez -text "Set Steps To"       -width 17 -command {MixModify stepset $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.qu -text "Quantise Times To"  -width 17 -command {MixModify quant   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.wt -text "Shake Times By"     -width 17 -command {MixModify scatt   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.ww -text "Shake Times Within" -width 17 -command {MixModify scatw   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.rt -text "Retro Time Pattern" -width 17 -command {MixModify retrot  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.gr -text "Create Time Grid"   -width 17 -command MakeGridVals -highlightbackground [option get . background {}]
		button $f31.gg -text "Get Grid Value"     -width 17 -command GetGridVal -highlightbackground [option get . background {}]
		button $f31.xa -text "Round All Times"	  -width 17 -command {MixModify trndall $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		button $f31.xc -text "Round Selected"	  -width 17 -command {MixModify trnd    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
		if {$longqik} {
			label $f31.l3 -text "Sound Sync" -fg $evv(SPECIAL)
			button $f31.ee -text "Files End-To-End"   -width 17 -command {MixModify etoe    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f31.es -text "Stretch Silence By" -width 17 -command {MixModify expsil  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f31.lu -text "Line Up At Mark"    -width 17 -command {MixModify lineup  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f31.sm -text "Sync At Marks"      -width 17 -command {MixModify syncup  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f31.so -text "Offset Marks"       -width 17 -command {MixModify offmark $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f31.ye -text "Sync At End"        -width 17 -command {MixModify syncend $m_list $mixval $tempmix; TempmixReset}
			button $f31.zr -text "Replace/Retime"     -width 17 -command {MixModify repret  $m_list $mixval $tempmix; TempmixReset}

			label $f32.l1 -text "Spatial Data" -fg $evv(SPECIAL)
			button $f32.po -text "Set Position"       -width 17 -command {MixModify posset  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.op -text "Opposite"           -width 17 -command Opposite -highlightbackground [option get . background {}]
			button $f32.sp -text "Spread Position"    -width 17 -command {MixModify posspr  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.fl -text "Step Between"       -width 17 -command {MixModify posftol $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.sc -text "Scatter Position"   -width 17 -command {MixModify poscat  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.sk -text "Permute Psitions"   -width 17 -command {MixModify posrnd $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.sw -text "Swap Positions"	  -width 17 -command {MixModify poswap $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.mi -text "Mirror Sound"       -width 17 -command {MixModify mirror  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.zq -text "Scatter Psitions"   -width 17 -command {MixModify pozcat  $m_list $mixval $tempmix; TempmixReset}
			button $f32.tw -text "Twist Positions"    -width 17 -command {MixModify twist   $m_list $mixval $tempmix; TempmixReset}
			button $f32.ge -text "Get Position"       -width 17 -command {MixPosget $m_list}

			label $f32.l2 -text "Sound Pattern" -fg $evv(SPECIAL)
			button $f32.rf -text "Retro File Order"   -width 17 -command {MixModify retrof  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.sf -text "Randomise Order"    -width 17 -command {MixModify scatf   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.sn -text "Randomise Names"    -width 17 -command {MixModify scatn   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.wf -text "Swap Files"         -width 17 -command {MixModify swap    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.du -text "Copy File(s) To"    -width 17 -command {MixModify dupl    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.ds -text "Copy File Seq"      -width 17 -command {MixModify duplseq $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.nf -text "Replace Next"       -width 17 -command {MixModify nextfile $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.cf -text "Change File To"     -width 17 -command {MixModify file    $m_list $mixval $tempmix; TempmixReset} -bg $evv(EMPH) -highlightbackground [option get . background {}]
			button $f32.lf -text "... To Last Made"   -width 17 -command {MixModify lastfile $m_list $mixval $tempmix; TempmixReset} -bg $evv(EMPH) -highlightbackground [option get . background {}]
			button $f32.ce -text "Change Every"       -width 17 -command {MixModify every   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.cm -text "Change Many"        -width 17 -command {MixModify many    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.nw -text "Add New File (at)"  -width 17 -command {MixModify adfile  $m_list $mixval $tempmix; TempmixReset} -bg $evv(EMPH) -highlightbackground [option get . background {}]
			button $f32.nl -text "... Last Made (at)" -width 17 -command {MixModify adfilel $m_list $mixval $tempmix; TempmixReset} -bg $evv(EMPH) -highlightbackground [option get . background {}]
			button $f32.nm -text "Add Mixfile (at)"   -width 17 -command {MixModify admfile $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.si -text "Show Snd Dupls"	  -width 17 -command {MixModify identic $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.dd -text "Show ~ALL~ Dupls"   -width 17 -command {MixModify identic2 $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f32.wi -text "Permute Order"      -width 17 -command {MixModify wiggle  $m_list $mixval $tempmix; TempmixReset}

			label $f33.l0 -text "Levels" -fg $evv(SPECIAL)
			button $f33.ab -text "Amplify By"         -width 17 -command {MixModify gain    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.sl -text "Set Level To"       -width 17 -command {MixModify gainset $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.ss -text "Step Levels By"     -width 17 -command {MixModify gainstp $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.vv -text "VectorSet Levls"	  -width 17 -command {MixModify vector  $m_list $mixval $tempmix; TempmixReset}
			button $f33.ij -text "Store Mix Levl"     -width 17 -command {MixModify inject  $m_list $mixval -1; TempmixReset}
			button $f33.sj -text "Set Stored Levl"    -width 17 -command {MixModify reinject $m_list $mixval -1; TempmixReset; set pr12_34 0}
			button $f33.sz -text "Amp By Mix Levl"    -width 17 -command {MixModify mgain   $m_list $mixval $tempmix; TempmixReset}
			label $f33.l3 -text "Muting" -fg $evv(SPECIAL)
			button $f33.mm -text "Mute Lines"         -width 17 -command {MixModify mute    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.nn -text "Unmute Lines"       -width 17 -command {MixModify unmute  $m_list $mixval -1; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.ua -text "Unmute ~All~"       -width 17 -command {UnMuteAll} -highlightbackground [option get . background {}]
			button $f33.pm -text "Swap Muted/Not"     -width 17 -command {MixModify muteswap  $m_list $mixval -1; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.h1 -text "Show ~All~ Muted"	  -width 17 -command {MixModify hicom    $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.fm -text "All Muted To End"	  -width 17 -command {MixModify movembot $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			label $f33.rr -text "Remove Muted Lines" -fg $evv(SPECIAL)
			button $f33.r1 -text "Remove Selected"	  -width 17 -command {MixModify delcom  $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.rc -text "Remove ~All~"		  -width 17 -command {MixModify clear   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]

			label $f33.lo -text "Line Order" -fg $evv(SPECIAL)
			button $f33.om -text "Order All Lines"    -width 17 -command {MixModify muteorder $m_list $mixval -1; TempmixReset} -highlightbackground [option get . background {}]
			label $f33.sh -text "Selected Lines" -fg $evv(SPECIAL)
			button $f33.mh -text "Move To Top"		  -width 17 -command {MixModify movetop	$m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.mf -text "Move To Foot"		  -width 17 -command {MixModify movebot $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.rv -text "Reverse Order"	  -width 17 -command {MixModify reverse $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]

			label $f33.l4 -text "Click" -fg $evv(SPECIAL)
			button $f33.mk -text "Make Click"		  -width 17 -command {Do_MakeMM} -highlightbackground [option get . background {}]
			button $f33.ck -text "Mark As Click"      -width 17 -command {MixModify clik   $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			button $f33.ko -text "Click On/Off"       -width 17 -command {MixModify clikon $m_list $mixval $tempmix; TempmixReset} -highlightbackground [option get . background {}]
			label $f33.l6 -text "Mix Syntax" -fg $evv(SPECIAL)
			button $f33.sy -text "Check Syntax"       -width 17 -command "CheckMixSyntax" -highlightbackground [option get . background {}]
			menubutton $f33.co -text "Collapse->Stereo"   -menu $f33.co.men -bd 2 -relief raised
			set collapsemenu [menu $f33.co.men -tearoff 0]

			pack $f31.l2 $f31.mb $f31.mbb $f31.mt $f31.mtx $f31.mt2 $f31.mz $f31.st $f31.l5 $f31.ov $f31.ex $f31.ey $f31.ez $f31.tg $f31.qu $f31.wt \
				$f31.ww $f31.rt $f31.gr $f31.gg $f31.xa $f31.xc $f31.l3 $f31.ee $f31.es $f31.lu $f31.sm $f31.so $f31.ye $f31.zr -side top -pady 2
			pack $f32.l1 $f32.po $f32.op $f32.sp $f32.fl $f32.sc $f32.sk $f32.sw $f32.mi $f32.zq $f32.tw $f32.ge $f32.l2 $f32.rf $f32.sf $f32.sn \
				$f32.wf $f32.du $f32.ds $f32.nf $f32.cf $f32.lf $f32.ce $f32.cm $f32.nw $f32.nl $f32.nm $f32.si $f32.dd $f32.wi -side top -pady 2
			pack $f33.l0 $f33.ab $f33.sl $f33.ss $f33.vv $f33.ij $f33.sj $f33.sz $f33.l3 $f33.mm $f33.nn $f33.ua $f33.pm $f33.h1 $f33.fm $f33.rr $f33.r1 $f33.rc \
				$f33.lo $f33.om $f33.sh $f33.mh $f33.mf $f33.rv $f33.l4 $f33.mk $f33.ck $f33.ko $f33.l6 $f33.sy $f33.co -side top -pady 2
			pack $f3.1 $f3.2 $f3.3 -side left -padx 2 -anchor n
			pack $f2.h $f2.t $f2.l $f2.v $f2.3 -side top -pady 2	
		} else {
			button $f31.dumm -text ""	  -width 17 -command {} -bd 0
			label $f31.sh -text "Selected Lines-->" -fg $evv(SPECIAL)

			label $f32.l3 -text "Sound Sync" -fg $evv(SPECIAL)

			button $f32.ee -text "Files EndtoEnd"   -width 17 -command {MixModify etoe    $m_list $mixval $tempmix; TempmixReset}
			button $f32.es -text "Stretch Silence" -width 17 -command {MixModify expsil  $m_list $mixval $tempmix; TempmixReset}
			button $f32.lu -text "Line Up At Mark"    -width 17 -command {MixModify lineup  $m_list $mixval $tempmix; TempmixReset}
			button $f32.sm -text "Sync At Marks"      -width 17 -command {MixModify syncup  $m_list $mixval $tempmix; TempmixReset}
			button $f32.so -text "Offset Marks"      -width 17 -command  {MixModify offmark $m_list $mixval $tempmix; TempmixReset}
			button $f32.ye -text "Sync At End"        -width 17 -command {MixModify syncend $m_list $mixval $tempmix; TempmixReset}
			button $f32.zr -text "Replace/Retime"	  -width 17 -command {MixModify syncend $m_list $mixval $tempmix; TempmixReset}

			label $f32.l1 -text "Spatial Data" -fg $evv(SPECIAL)
			button $f32.po -text "Set Position"       -width 17 -command {MixModify posset  $m_list $mixval $tempmix; TempmixReset}
			button $f32.op -text "Opposite"           -width 17 -command Opposite
			button $f32.sp -text "Spread Position"    -width 17 -command {MixModify posspr  $m_list $mixval $tempmix; TempmixReset}
			button $f32.fl -text "Step Between"       -width 17 -command {MixModify posftol $m_list $mixval $tempmix; TempmixReset}
			button $f32.sc -text "Scatter Position"   -width 17 -command {MixModify poscat  $m_list $mixval $tempmix; TempmixReset}
			button $f32.sk -text "Permute Psitions"   -width 17 -command {MixModify posrnd  $m_list $mixval $tempmix; TempmixReset}
			button $f32.sw -text "Swap Positions"	  -width 17 -command {MixModify poswap  $m_list $mixval $tempmix; TempmixReset}
			button $f32.mi -text "Mirror Sound"       -width 17 -command {MixModify mirror  $m_list $mixval $tempmix; TempmixReset}
			button $f32.zq -text "Scatter Psitions"   -width 17 -command {MixModify pozcat  $m_list $mixval $tempmix; TempmixReset}
			button $f32.tw -text "Twist Positions"    -width 17 -command {MixModify twist   $m_list $mixval $tempmix; TempmixReset}
			button $f32.ge -text "Get Position"       -width 17 -command {MixPosget $m_list}

			label $f32.lo -text "Line Order" -fg $evv(SPECIAL)
			button $f32.om -text "Order All Lines"    -width 17 -command {MixModify muteorder $m_list $mixval -1; TempmixReset}
			button $f32.dumm -text ""    -width 17 -command {} -bd 0
			button $f32.mh -text "Move To Top"		  -width 17 -command {MixModify movetop	$m_list $mixval $tempmix; TempmixReset}


			label $f33.l2 -text "Sound Pattern" -fg $evv(SPECIAL)
			button $f33.rf -text "Retro File Order"   -width 17 -command {MixModify retrof  $m_list $mixval $tempmix; TempmixReset}
			button $f33.sf -text "Randomise Order"    -width 17 -command {MixModify scatf   $m_list $mixval $tempmix; TempmixReset}
			button $f33.sn -text "Randomise Names"    -width 17 -command {MixModify scatn   $m_list $mixval $tempmix; TempmixReset}
			button $f33.wf -text "Swap Files"         -width 17 -command {MixModify swap    $m_list $mixval $tempmix; TempmixReset}
			button $f33.du -text "Copy File(s) To"    -width 17 -command {MixModify dupl    $m_list $mixval $tempmix; TempmixReset}
			button $f33.ds -text "Copy File Seq"      -width 17 -command {MixModify duplseq $m_list $mixval $tempmix; TempmixReset}
			button $f33.nf -text "Replace Next"       -width 17 -command {MixModify nextfile $m_list $mixval $tempmix; TempmixReset}
			button $f33.cf -text "Change File To"     -width 17 -command {MixModify file    $m_list $mixval $tempmix; TempmixReset}  -bg $evv(EMPH)
			button $f33.lf -text "... To Last Made"   -width 17 -command {MixModify lastfile $m_list $mixval $tempmix; TempmixReset} -bg $evv(EMPH)
			button $f33.ce -text "Change Every"       -width 17 -command {MixModify every   $m_list $mixval $tempmix; TempmixReset}
			button $f33.cm -text "Change Many"        -width 17 -command {MixModify many    $m_list $mixval $tempmix; TempmixReset}
			button $f33.nw -text "Add New File (at)"  -width 17 -command {MixModify adfile  $m_list $mixval $tempmix; TempmixReset} -bg $evv(EMPH)
			button $f33.nl -text "... Last Made (at)" -width 17 -command {MixModify adfilel $m_list $mixval $tempmix; TempmixReset} -bg $evv(EMPH)
			button $f33.nm -text "Add Mixfile (at)"   -width 17 -command {MixModify admfile $m_list $mixval $tempmix; TempmixReset}
			button $f33.si -text "Show Snd Dupls"	  -width 17 -command {MixModify identic $m_list $mixval $tempmix; TempmixReset}
			button $f33.dd -text "Show ~ALL~ Dupls"   -width 17 -command {MixModify identic2 $m_list $mixval $tempmix; TempmixReset}
			button $f33.wi -text "Permute Order"      -width 17 -command {MixModify wiggle  $m_list $mixval $tempmix; TempmixReset}
			label $f33.l6 -text "Mix Syntax" -fg $evv(SPECIAL)
			button $f33.sy -text "Check Syntax"       -width 17 -command "CheckMixSyntax"
			menubutton $f33.co -text "Collapse->Stereo"   -menu $f33.co.men -bd 2 -relief raised
			set collapsemenu [menu $f33.co.men -tearoff 0]
			button $f33.dumm -text ""    -width 17 -command {} -bd 0
			button $f33.mf -text "Move To Foot"		  -width 17 -command {MixModify movebot $m_list $mixval $tempmix; TempmixReset}

			label $f34.l0 -text "Levels" -fg $evv(SPECIAL)
			button $f34.ab -text "Amplify By"         -width 17 -command {MixModify gain    $m_list $mixval $tempmix; TempmixReset}
			button $f34.sl -text "Set Level To"       -width 17 -command {MixModify gainset $m_list $mixval $tempmix; TempmixReset}
			button $f34.ss -text "Step Levels By"     -width 17 -command {MixModify gainstp $m_list $mixval $tempmix; TempmixReset}
			button $f34.vv -text "Vector Set Levls"  -width 17 -command {MixModify vector  $m_list $mixval $tempmix; TempmixReset}
			button $f34.ij -text "Store Mix Levl"    -width 17 -command {MixModify inject  $m_list $mixval -1; TempmixReset}
			button $f34.sj -text "Set Stored Levl"	  -width 17 -command {MixModify reinject $m_list $mixval -1; TempmixReset; set pr12_34 0}
			button $f34.sz -text "Amp By Mix Levl"   -width 17 -command {MixModify mgain   $m_list $mixval $tempmix; TempmixReset}
			label $f34.l3 -text "Muting" -fg $evv(SPECIAL)
			button $f34.mm -text "Mute Lines"         -width 17 -command {MixModify mute    $m_list $mixval $tempmix; TempmixReset}
			button $f34.nn -text "Unmute Lines"       -width 17 -command {MixModify unmute  $m_list $mixval -1; TempmixReset}
			button $f34.ua -text "Unmute ~ALL~"       -width 17 -command {UnMuteAll}
			button $f34.pm -text "Swap Muted/Not"    -width 17 -command {MixModify muteswap $m_list $mixval -1; TempmixReset}
			button $f34.h1 -text "Show ~ALL~ Muted"	  -width 17 -command {MixModify hicom   $m_list $mixval $tempmix; TempmixReset}
			button $f34.fm -text "All Muted To End"	  -width 17 -command {MixModify movembot $m_list $mixval $tempmix; TempmixReset}
			label $f34.rr -text "Remove Muted Lines" -fg $evv(SPECIAL)
			button $f34.r1 -text "Remove Selected"	  -width 17 -command {MixModify delcom  $m_list $mixval $tempmix; TempmixReset}
			button $f34.rc -text "Remove ~ALL~"		  -width 17 -command {MixModify clear   $m_list $mixval $tempmix; TempmixReset}
			label $f34.l4 -text "Click" -fg $evv(SPECIAL)
			button $f34.mk -text "Make Click"		  -width 17 -command {Do_MakeMM}
			button $f34.ck -text "Mark As Click"      -width 17 -command {MixModify clik    $m_list $mixval $tempmix; TempmixReset}
			button $f34.ko -text "Click On/Off"       -width 17 -command {MixModify clikon  $m_list $mixval $tempmix; TempmixReset}
			button $f34.rv -text "Reverse Order"	  -width 17 -command {MixModify reverse $m_list $mixval $tempmix; TempmixReset}
			pack $f31.l2 $f31.mb $f31.mbb $f31.mt $f31.mtx $f31.mt2 $f31.mz $f31.st $f31.l5 $f31.ov \
				$f31.ex $f31.ey $f31.ez $f31.tg $f31.qu $f31.wt $f31.ww $f31.rt $f31.gr $f31.gg $f31.xa $f31.xc $f31.dumm -side top
			pack $f31.sh -side top -pady 4
			pack $f32.l3 $f32.ee $f32.es $f32.lu $f32.sm $f32.so $f32.ye $f32.zr \
				$f32.l1 $f32.po $f32.op $f32.sp $f32.fl $f32.sc $f32.sk $f32.sw $f32.mi $f32.zq $f32.tw $f32.ge \
				$f32.lo $f32.om $f32.dumm -side top
			pack $f32.mh -side top -pady 12
			pack $f33.l2 $f33.rf $f33.sf $f33.sn\
				$f33.wf $f33.du $f33.ds $f33.nf $f33.cf $f33.lf $f33.ce $f33.cm $f33.nw $f33.nl $f33.nm $f33.si $f33.dd $f33.wi $f33.l6 $f33.sy $f33.co $f33.dumm $f33.mf -side top
			pack $f34.l0 $f34.ab $f34.sl $f34.ss $f34.vv $f34.ij $f34.sj $f34.sz $f34.l3 $f34.mm $f34.nn $f34.ua $f34.pm $f34.h1 $f34.fm $f34.rr $f34.r1 $f34.rc \
				$f34.l4 $f34.mk $f34.ck $f34.ko -side top
			pack $f34.rv -side top -pady 16
			pack $f3.1 $f3.2 $f3.3 $f3.4 -side left -padx 2 -anchor n
			pack $f2.hhh $f2.3 -side top	
		}
		$collapsemenu add command -label "Whole File To Stereo Mixfile Format" -command {CollapseMix} -foreground black
		$collapsemenu add separator
		$collapsemenu add command -label "Selected Lines Collapsed To Stereo" -command {QikDoStandardUnstage} -foreground black

		pack $f.1 $f.2 -side left
		wm resizable .mixdisplay2 0 0
		bind $m_list <ButtonRelease-1> {focus $mixd2.1.see.1.seefile}
		bind .mixdisplay2				  <Control-Key-p> {QikEditor play}
		bind .mixdisplay2				  <Control-Key-P> {QikEditor play}
		bind $mixd2.1.see.1.seefile <Key-space>	  {QikEditor play}
		bind .mixdisplay2				  <Control-Key-D> {MixModify delcom  $m_list 0 $tempmix; TempmixReset}
		bind .mixdisplay2				  <Control-Key-d> {MixModify delcom  $m_list 0 $tempmix; TempmixReset}
		bind .mixdisplay2				  <Control-Up>    {$m_list yview moveto 0.0}
		bind .mixdisplay2				  <Control-Down>  {$m_list yview moveto 1.0}
		bind $mixd2.1.see.1.seefile <Control-Key-t> {QikShowText}
		bind $mixd2.1.see.1.seefile <Control-Key-T> {QikShowText}
		bind $mixd2.1.see.1.seefile.list <Double-1> {PlaySndonQikEdit $mixd2.1.see.1.seefile.list %y}
		bind .mixdisplay2			      <Shift-Up>      {MixModify movetop	$m_list $mixval $tempmix; TempmixReset}
		bind .mixdisplay2			      <Shift-Down>    {MixModify movebot	$m_list $mixval $tempmix; TempmixReset}
		bind $mixd2.1.see.1.seefile <Up>			  {QikNext 1}
		bind $mixd2.1.see.1.seefile <Down>		  {QikNext 0}
		bind $mixd2.1.see.1.seefile <Shift-Left>    {MixModify mute    $m_list $mixval $tempmix; TempmixReset}
		bind .mixdisplay2				  <Shift-Left>    {MixModify mute    $m_list $mixval $tempmix; TempmixReset}
		bind .mixdisplay2			      <Shift-Right>   {MixModify unmute  $m_list $mixval -1; TempmixReset}
		bind .mixdisplay2					<Control-q>	{QikOutView 1}
		bind .mixdisplay2					<Control-Q>	{QikOutView 1}

		bind .mixdisplay2 <Control-Key-n>	"MixfileLinevalToVal number"
		bind .mixdisplay2 <Control-Key-N>	"MixfileLinevalToVal number"
		bind .mixdisplay2 <Control-Key-a>	"MixfileLinevalToVal add"
		bind .mixdisplay2 <Control-Key-A>	"MixfileLinevalToVal add"
		bind .mixdisplay2 <Control-Key-s>	"MixfileLinevalToVal time"
		bind .mixdisplay2 <Control-Key-S>	"MixfileLinevalToVal time"
		bind .mixdisplay2 <Control-Key-e>	"MixfileLinevalToVal timend"
		bind .mixdisplay2 <Control-Key-E>	"MixfileLinevalToVal timend"
		bind .mixdisplay2 <Control-Key-g>	"MixfileLinevalToVal norm2"
		bind .mixdisplay2 <Control-Key-G>	"MixfileLinevalToVal norm2"
		if {$longqik} {
			bind .mixdisplay2.2.v <Control-Key-h>	{DoHilite}
			bind .mixdisplay2.2.v <Control-Key-H>	{DoHilite}
		} else {
			bind .mixdisplay2.2.hhh.v <Control-Key-h>	{DoHilite}
			bind .mixdisplay2.2.hhh.v <Control-Key-H>	{DoHilite}
		}
		bind .mixdisplay2 <Command-Key-p>	{QikEditorSelectAtTime 0}
		bind .mixdisplay2 <Command-Key-P>	{QikEditorSelectAtTime 0}

		bind $qkvbox		  <Up>			  {MixvalIncr 0}
		bind $qkvbox		  <Down>          {MixvalIncr 1}
		bind $f <Return> {set pr12_34 1}
		bind $f <Escape> {QikEscape}
	}
	if {$mm_multichan && ($mix_outchans == 8)} {
		$mixd2.1.see.000.dumm1 config -text "SEE PANS" -command "PanDiagram" -state normal -bd 2
	} else {
#RWD Oct 2024 see above; was an empty button (so better as a label), now here changed to a real button
		$mixd2.1.see.000.dumm1 config -text "" -command {} -state disabled -background [option get . background {}] -bd 0
	}
	set f $mixd2
	set qikgain $prm(2)
	set qikeditmixname ""
	if {$mm_multichan} {
		catch {$f.2.3.3.co config -state normal}
		$f.1.title.title  config -text "MULTI-CHANNEL MIXFILE : $mix_outchans chans"
		$f.2.3.2.po config -text "Reroute" -command {MixModify reroute $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.op config -text "More Channels" -command {MixModify nuchans $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.sp config -text "Ring -> Bilatrl" -command {MixModify tobilat $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.fl config -text "Bilatrl -> Ring" -command {MixModify frmbilat $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.sc config -text "Mirror Frame"    -command {MixModify mirfram $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.sk config -text "Permute Psitions" -command {MixModify posrnd $m_list $mixval $tempmix; TempmixReset} -bd 2
		$f.2.3.2.sw config -text "Swap Positions"  -command {MixModify poswap $m_list $mixval $tempmix; TempmixReset} -bd 2
		$f.2.3.2.mi config -text "Rotate Psitions" -command {MixModify posrot $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.zq config -text "Scatter Psitions" -command {MixModify pozcat $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.tw config -text "Twist Positions" -command {MixModify twist $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.ge config -text "Get Position" -command {MixPosget $m_list}
		$f.1.see.00.atte1 config -text "Channel Levels"
		$f.1.see.00.seel config  -text " See " -command "SeeChannelLevels" -bd 2
		$f.1.see.00.atten config -text "Attenuate" -command "SetChannelAttenuation" -bd 2
		$f.1.see.1.foot2.mq config -text "MaxChan" -command MaxsampMultichanChans  -bd 2
		bind $mixd2.1.see.1.seefile <Command-Up>		  {}
		bind $mixd2.1.see.1.seefile <Command-Down>	  {}
		bind $mixd2.1.see.1.seefile <Command-Left>	  {}
		bind $mixd2.1.see.1.seefile <Command-Right>	  {}
		bind $qkvbox			  <Command-Up>        {}
		bind $qkvbox			  <Command-Down>	  {}
		bind $qkvbox			  <Command-Left>	  {}
		bind $qkvbox			  <Command-Right>	  {}
		bind .mixdisplay2				  <Command-Key-s>	{ShowStage}
		bind .mixdisplay2				  <Command-Key-S>	{ShowStage}
	} else {
		catch {$f.2.3.4.co config -state disabled}
		catch {$f.2.3.3.co config -state disabled}
		$f.1.title.title  config -text "STANDARD MIXFILE"
		$f.2.3.2.po config -text "Set Position"       -command {MixModify posset  $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.op config -text "Opposite"           -command Opposite
		$f.2.3.2.sp config -text "Spread Position"    -command {MixModify posspr  $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.fl config -text "Step Between"       -command {MixModify posftol $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.sc config -text "Scatter Position"   -command {MixModify poscat  $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.sk config -text "" -command {} -bd 0
		$f.2.3.2.sw config -text "" -command {} -bd 0
		$f.2.3.2.mi config -text "Mirror Sound"       -command {MixModify mirror $m_list $mixval $tempmix; TempmixReset}
		$f.2.3.2.zq config -text "Show Stereo"        -command {MixShowChans 2}
		$f.2.3.2.tw config -text "Show Mono"          -command {MixShowChans 1}
		$f.2.3.2.ge config -text "Get Position"       -command {MixPosget $m_list}
		$f.1.see.00.atte1 config -text ""
		$f.1.see.00.seel config  -text "" -command {} -bd 0
		$f.1.see.00.atten config -text "" -command {} -bd 0
		$f.1.see.1.foot2.mq config -text "" -command {} -bd 0
		bind $mixd2.1.see.1.seefile <Command-Up>		  {MixModify up    $m_list 0 $tempmix; TempmixReset}
		bind $mixd2.1.see.1.seefile <Command-Down>	  {MixModify down  $m_list 0 $tempmix; TempmixReset}
		bind $mixd2.1.see.1.seefile <Command-Left>	  {MixModify left  $m_list 0 $tempmix; TempmixReset}
		bind $mixd2.1.see.1.seefile <Command-Right>	  {MixModify right $m_list 0 $tempmix; TempmixReset}
		bind $qkvbox			  <Command-Up>        {focus $mixd2.1.see.1.seefile; MixModify up    $m_list 0 $tempmix; TempmixReset}
		bind $qkvbox			  <Command-Down>	  {focus $mixd2.1.see.1.seefile; MixModify down  $m_list 0 $tempmix; TempmixReset}
		bind $qkvbox			  <Command-Left>	  {focus $mixd2.1.see.1.seefile; MixModify left  $m_list 0 $tempmix; TempmixReset}
		bind $qkvbox			  <Command-Right>	  {focus $mixd2.1.see.1.seefile; MixModify right $m_list 0 $tempmix; TempmixReset}
		bind .mixdisplay2				  <Command-Key-s>	{}
		bind .mixdisplay2				  <Command-Key-S>	{}
	}
	bind .mixdisplay2				  <Command-Key-b>	{SelectAllActiveLinesBelow}
	bind .mixdisplay2				  <Command-Key-B>	{SelectAllActiveLinesBelow}
	if {([string length $qikmixstart] > 0) && ($qikmixstart > 0)} {
		wm title .mixdisplay2 "Editing mixfile $fnam FROM $qikmixstart"
	} else {
		wm title .mixdisplay2 "Editing mixfile $fnam"
	}
	set qik_bakups_cnt 0
	set finished 0
 	catch {unset mlst}
	if [catch {open $fnam r} fileId] {
		Inf $fileId							;#	If textfile cannot be opened
		Dlg_Dismiss $f							;#	Hide the dialog
		return		
	}
	if {$typ != "sketchmix" && !$ins(run) && !$bulk(run)} {
		$mixd2.1.see.1.foot2.ss config -text "Save And Mix Version" -command "QikSaveAndMix" -bg $evv(EMPH) -bd 2
		$mixd2.1.see.1.foot2.pp config -text "Play Sound" -command "QikOutView 0" -bd 2
		$mixd2.1.see.1.foot2.cc config -text "Play Chans" -command "PlayChannel 1" -bd 2
		$mixd2.1.see.1.foot2.vv config -text "View Sound" -command "QikOutView 1" -bg $evv(SNCOLOR) -bd 2
		$mixd2.1.see.1.foot2.qq config -text "Keep Sound Mixed Here" -command "QikKeep" -bg $evv(QUIT_COLOR) -bd 2
		$mixd2.1.see.1.foot.rr config -text "Recall A Previously Mixed Version" -command "QikRecall" -bd 2
	} else {
		$mixd2.1.see.1.foot2.ss config -text "" -command {} -bg [option get . background {}] -bd 0
		$mixd2.1.see.1.foot2.pp config -text "" -command {} -bd 0
		$mixd2.1.see.1.foot2.cc config -text "" -command {} -bd 0
		$mixd2.1.see.1.foot2.vv config -text "" -command {} -bg [option get . background {}] -bd 0
		$mixd2.1.see.1.foot2.qq config -text "" -command {} -bg [option get . background {}] -bd 0
		$mixd2.1.see.1.foot.rr config  -text "" -command {} -bd 0
	}
	while { [gets $fileId thisline] >= 0} {			;#	Read lines from textfile into text-listing
		set thisline [split $thisline]
		set k [llength $thisline]
		set n 0
		while {$n < $k} {		
			set item [string trim [lindex $thisline $n]]
			if {[string length $item] <= 0} {
				set thisline [lreplace $thisline $n $n]
				incr  k -1
			} else { 
				if {$n==0} {
					if {![string match [string index $item 0] ";"]} {
						set item [RegulariseDirectoryRepresentation $item]
						set thisline [lreplace $thisline 0 0 $item]
					}
				}
				incr n
			}
		}
		if {[llength $thisline] > 0} {
			lappend mlst $thisline
		}
	}
	if {$mm_multichan} {
		set mlsthead [lindex $mlst 0]
		set orig_mlsthead $mlsthead
		set mlst [lrange $mlst 1 end]
	}
	close $fileId
	QikGetToWkspace
	DisplayMixlist 0
	set initial_mlst $mlst
	if {[info exists qe_last_sel]} {
		if {[string match [lindex $qe_last_sel 0] $fnam]} {
			foreach ii [lindex $qe_last_sel 1] {
				$m_list selection set $ii
			}
		}
		unset qe_last_sel
	}

	if {$prm(0) > 0.0} {		;#	Scroll display to relevant area
		set linecnt 0
		set gotline -1
		foreach line $mlst {
			if {[string match [string index $line 0] ";"]} {
				incr linecnt
				continue
			}
			set cnt 0
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt == 1} {
					if {$item >= $prm(0)} {
						set gotline $linecnt
					}
					break
				}
				incr cnt
			}
			if {$gotline >= 0} {
				break
			}
			incr linecnt
		}
		if {$gotline >= $evv(QIKEDITLEN)} {
			set k [expr double($gotline) / double([llength $mlst])]
			$m_list yview moveto $k
		}
	}
	if {$is_the_main} {
		if {[info exists qiki_main]} {
			set qiki $qiki_main				;#	Establish qiki tied to main_mix, if this is main_mix
		}
	}
	if {[info exists qiki]} {					;#	Establish if cliktrak line still exists
		if {$qiki >= [llength $mlst]} {
			unset qiki
		} else {
			set line [$m_list get $qiki]
			if {[string match [string index $line 0] ";"]} {
				set line [string range $line 1 end]
			}
			if {![string match $line $qikclik]} {
				unset qiki
			}
		}
	}
	set qikmixdur $pa($mixrestorename,$evv(DUR))
	set origmixdur $qikmixdur
	ColourWholeMixButton
	set pr12_34 0
	raise .mixdisplay2
	update idletasks
	QikeditPosition .mixdisplay2
	My_Grab 0 .mixdisplay2 pr12_34 $f.1.see.1.seefile
	while {!$finished} {
		tkwait variable pr12_34						;#	Wait for OK to be pressed
		switch -- $pr12_34 {
			3 -
			1 {
				if {$pr12_34 == 1} {
					set rewrite 1
					if {$dobakuplog} {
						set rewrite 0
						if {[info exists mlsthead] && ($mlsthead != $orig_mlsthead)} {
							set rewrite 1
						}
						set len [llength $initial_mlst]
						if {[llength $mlst] != $len} {
							set rewrite 1
						} else {
							set n 0
							while {$n < $len} {
								catch {unset nuline}
								set line [lindex $mlst $n]
								set origline [lindex $initial_mlst $n]
								set line [split $line]
								foreach item $line  {
									set item [string trim $item]
									if {[string length $item] > 0} {
										lappend nuline $item
									}
								}
								set line $nuline
								catch {unset nuline}
								set origline [split $origline]
								foreach item $origline  {
									set item [string trim $item]
									if {[string length $item] > 0} {
										lappend nuline $item
									}
								}
								set origline $nuline
								if {![string match $origline $line]} {
									set rewrite 1
									break
								}
								incr n
							}
						}
					}
					if {!$rewrite} {
						RememberHilite $fnam
						set finished 1
						break
					}
				}
				set tmpfnam $evv(DFLT_TMPFNAME)
				if [catch {open $tmpfnam w} fileId] {
					Inf "Cannot Open Temporary File To Do Updating.\n"
					continue
				}
				if {[info exists mixcomments]} {
					foreach line $mixcomments {
						puts $fileId $line
					}
				}
				if {$mm_multichan} {
					puts $fileId $mlsthead
				}
				foreach line [$m_list get 0 end] {
					puts $fileId $line
				}
				close $fileId
				set do_parse_report 0
				if {[DoParse $tmpfnam $wl 0 0] <= 0} {
					ErrShow "Parsing failed for edited file."
					continue
				}
				if [catch {set ftype $pa($tmpfnam,$evv(FTYP))} xzit] {
					Inf "Cannot Find Properties Of Edited File."
					continue
				}
				if {$mm_multichan} {
					if {$ftype != $evv(MIX_MULTI)} {
						Inf "Edited File Is No Longer A Valid Multi-Channel Mixfile."
						PurgeArray $tmpfnam
						continue
					}
				} elseif {![IsAMixfile $ftype]} {
					Inf "Edited File Is No Longer A Valid Mixfile."
					PurgeArray $tmpfnam
					continue
				}
				if {$typ == "mix"} {
					set duratend0 0
					set duratend1 0
					set dur $pa($tmpfnam,$evv(DUR))
					set indur $pa($fnam,$evv(DUR))
					if {[Flteq $prm(0) $indur]} {
						set duratend0 1
					}
					if {[Flteq $prm(1) $indur]} {
						set duratend1 1
					}
				}
				if [catch {file delete $fnam}] {
					Inf "Cannot Remove The Original File To Replace It With New Values"
					PurgeArray $tmpfnam
					continue
				}
				DeleteFileFromSrcLists $fnam
				if {$typ == "sketchmix"} {
					.scvumix2.e.2.ll.list delete 0 end
				}
				if [catch {file rename $tmpfnam $fnam} in] {
					UpdateBakupLog $fnam delete 1
					ErrShow "$in"
					Inf "Cannot Substitute The New File: Original File Lost."
					PurgeArray $tmpfnam
					PurgeArray $fnam				;#	can't remove unbakdup files!!
					RemoveFromChosenlist $fnam
					RemoveFromDirlist $fnam
					if {[string match $last_mix $fnam]} {
						set last_mix ""
					}
					set i [LstIndx $fnam $wl]
					if {$i >= 0} {
						$wl delete $i
						WkspCnt $fnam -1
						catch {unset rememd}
					}
					set OK 0
					DummyHistory $fnam "LOST"
					if {[MixMDelete $fnam 0]} {
						set save_mixmanage 1
					}
					if {$typ == "sketchmix"} {
						.scvumix2.e.1.ll.list delete $vm_i
						set vm_i -1
					}
					RememberHilite $fnam
					set finished 1
				} else {									
					UpdateBakupLog $fnam modify 1
					DummyHistory $fnam "EDITED"
					PurgeArray $fnam				
					RenameProps $tmpfnam $fnam 0
					if {[MixMUpdate $fnam 0]} {
						set save_mixmanage  1
					}
					if {$typ == "sketchmix"} {
						foreach line [$m_list get 0 end] {
							.scvumix2.e.2.ll.list insert end $line
						}
					}
					if {$typ == "mix"} {
						ReEstablishMixRange $dur $duratend0 $duratend1
					}
					set prm(1) [DecPlacesTrunc $prm(1) 6]
					RememberHilite $fnam
					set finished 1
				}
			}
			2 {													;#	Exit after having mixed a final edited version of mixfile
				RememberHilite $fnam 
				set finished 1									;#	Or having already restored the original state of mixfile at call to parampage
			}
			0 {
				set origfnam $evv(DFLT_TMPFNAME)				;#	Restore pre-qikedit-session version of mixfile
				append origfnam 0 $evv(TEXT_EXT)
				if {[file exists $origfnam]} {
					if [catch {file delete $mixrestorename} zit] {
						UpdateBakupLog $mixrestorename modify 1
						Inf "Cannot Delete Updated Mixfile"
					} elseif [catch {file rename $origfnam $mixrestorename} zit] {
						Inf "Cannot Rename Mixfile To Its Original Name:\nData Is In File '$origfnam,\n\nRename This ~~NOW~~ Outside The Loom\nOr You Will Lose It"
					} elseif {$prm(1) > $origmixdur} {
						set prm(1) $origmixdur
					}
					catch {PurgeArray $origfnam}
				}
				RememberHilite $fnam
				set finished 1
			}
		}
	}
	if {$save_mixmanage} {
		MixMStore
	}
	if {$pprg == $evv(MIX) || $pprg == $evv(MIXMAX) || $pprg == $evv(MIXGAIN) || $pprg == $evv(MIXMULTI)} {
		set dur $pa($fnam,$evv(DUR))
		if {$dur != $actvhi(0)} {
			AlterParamDisplay $dur
		}
	}
	catch {PurgeArray $tmpfnam}
	if {($typ == "mix") || ($typ == "mix3")} {
		if {$typ == "mix"} {
			set last_qikfnam $mixrestorename
			if {$is_the_main} {
				set last_main_qikparams [list $prm(0) $prm(1) $prm(2)]
			}
			set last_qikparams [list $prm(0) $prm(1) $prm(2)]
			My_Release_to_Dialog $f
			Dlg_Dismiss $f								;#	Hide the dialog
			if {[info exists qikkeepfnam]} {
				DeleteAllTemporarySndfilesExcept $qikkeepfnam
			}
			if {[info exists qikdelfnams]} {
				foreach outfnam $qikdelfnams {
					catch {unset pa($outfnam,$evv(CHANS))}
				}
			}
			if {!$OK} {
				catch {$favors delete 0 end}			;#	If file lost, return to workspace.
				catch {unset current_favorites}
				set pr3 0
				set pr2 0
			}
		} else {
			My_Release_to_Dialog $f
			Dlg_Dismiss $f								;#	Hide the dialog
		}
		set n 0
		while {$n < $qik_bakups_cnt} {				;#	If bakup versions of mix exitsd (QikEdit)
			set bakfnam $evv(DFLT_TMPFNAME)			;#	Delete files and their props-lists
			append bakfnam $n $evv(TEXT_EXT)
			catch {file delete $bakfnam}
			catch {PurgeArray $bakfnam}
			incr n
		}
	} else {
		My_Release_to_Dialog .mixdisplay2
		Dlg_Dismiss .mixdisplay2
	}
	set lastlongqik $longqik
	catch {close $fileId}
}

#------- Edit mixfile in situ

proc MixModify {action m_list val istemp} {
	global pa mix_perm mlst previous_linestore mm_multichan out_pos m_list_restore qiki qikclik mix_modified wstk evv
	global mixrestorename main_mix qiki_main qikclik_main is_the_main m_previous_yview mixval wl mlsthead mix_outchans
	global qiksync qknext hilitecheck displayjiggle dont_undo_tempmix mixd2 prm qikpperm qiktwist hi lo is_mgain lastmixval
	catch {unset hilitecheck}
	catch {unset displayjiggle}
	catch {unset is_mgain}
	set lastmixval $mixval
	switch -- $action {
		"move"		-
		"move2"		-
		"move3"		-
		"moveto"	-
		"moveto2"	-
		"over"		-
		"stagger"	-
		"expand"	-
		"expandy"	-
		"stepset"	-
		"quant"		-
		"scatt"		-
		"scatw"		-
		"retrot"	-
		"etoe"		-
		"expsil"	-
		"lineup"	-
		"syncup"	-
		"offmark"	-
		"posset"	-
		"posspr"	-
		"posftol"	-
		"poscat"	-
		"pozcat"	-
		"posrnd"	-
		"poswap"	-
		"mirror"	-
		"retrof"	-
		"scatf"		-
		"scatn"		-
		"swap"		-
		"dupl"		-
		"duplseq"	-
		"nextfile"	-
		"file"		-
		"lastfile"	-
		"every"		-
		"many"		-
		"adfile"	-
		"adfilel"	-
		"admfile"	-
		"gain"	-
		"mgain"	-
		"gainset"	-
		"gainstp"	-
		"vector"	-
		"mirfram"	-
		"posrnd"	-
		"poswap"	-
		"repret"	-
		"posrot"	{
			foreach line [$m_list get 0 end] {
				lappend displayjiggle $line
			}
		}
	}
	if {$istemp < 0} {	;#	CHANGES WHICH DON'T CREATE NEW COMMENTED LINES, AS THEY AFFECT EXISTING COMMENTED LINES
		set istemp 0
	}
	catch {unset qknext}
	if {[string match $action "nuchans"]} {
		if {![regexp {^[0-9]+$} $val] || ($val < 1)} {
			Inf "Invalid Channel-Count"
			return
		}
		if {$val < $mix_outchans} {
			Inf "You Cannot Decrease The Number Of Output Channels Here"
			return
		} elseif {$val == $mix_outchans} {
			Inf "This Is Already A Mix With $mix_outchans Channels"
			return
		}
		set mlsthead $val
		set mix_outchans $val
		set checkdata 1
		Inf "Output Channel-Count Changed To $mix_outchans"
		$mixd2.1.title.title  config -text "MULTI-CHANNEL MIXFILE : $mix_outchans chans"
	} else {
		set mix_modified 1
		catch {unset m_list_restore}
		catch {unset m_previous_yview}
		set val [string trim $val]
		set checkdata -1
	}
	while {$checkdata < 0} {
		if {[string match $action "reinstate"]} {
			if {![info exists previous_linestore]} {
				return
			}
			set zab $mlst
			catch {unset mlst}
			foreach item $previous_linestore {
				lappend mlst $item
			}
			set previous_linestore $zab
			set checkdata 2
			set m_previous_yview [$m_list yview]
			break
		}
		set previous_linestore $mlst

		if {[string match $action "move3"]} {
			set atend 0
			if {![IsNumeric $val] || ($val < 0.0)} {
				Inf "Invalid time shift ($val) entered : must be positive"
				raise .mixdisplay2
				return
			}
			set ilist [$m_list curselection]
			set len [llength $ilist]
			if {($len <= 0) || (($len == 1) && ($ilist == -1))} {
				return
			}
			catch {unset linestore}
			foreach line $mlst {
				lappend linestore $line
			}
			set i [lindex $ilist 0]
			if {$i == 0} {
				set msg "Insert silence before first line in mix ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					if {$len == 1} {
						return
					} else {
						set ilist [lrange $ilist 1 end]
						set i [lindex $ilist 0]
						incr len -1
					}
				}
			}
			if {$len == 1} {
				set j [llength $mlst]
			} else {
				set j [lindex $ilist 1]
			}
			set n 1
			while {1} {
				while {$i < $j} {
					set line [lindex $linestore $i]
					if {![string match [string index $line 0] ";"]} {
						set time [lindex $line 1]
 						set time [expr $time + ($val * double($n))]
						set line [lreplace $line 1 1 $time]
						set newstring [lindex $line 0]
						append newstring "  "
						foreach item [lrange $line 1 end] {
							append newstring $item "  "
						}
						set newstring [string trimright $newstring]
						set mlst [lreplace $mlst $i $i $newstring]	;#	Insert/replace the new line
					}
					incr i
				}
				set i $j
				incr n
				if {$atend} {
					break
				}
				if {$n >= $len} {
					set j [llength $mlst]
					set atend 1
				} else {
					set j [lindex $ilist $n]
				}
			}
			set checkdata 2
			break
		}
		if {[string match $action "muteswap"]} {
			set ilist [$m_list curselection]
			if {[llength $ilist] < 2} {
				Inf "Select At Least Two Lines, Some Muted And Some Not"
				return
			}
			foreach i $ilist {
				set line [$m_list get $i]
				if {[string match [string index $line 0] ";"]} {
					lappend mutelines $i
				} else {
					lappend unmutelines $i
				}
			}
			if {![info exists mutelines] || ![info exists unmutelines]} {
				Inf "Select Lines, Some Muted And Some Not"
				return
			}
			foreach i $mutelines {
				set line [$m_list get $i]
				set line [string range $line 1 end]
				set zline [split $line]
				set zfnam [lindex $zline 0]
				if {![file exists $zfnam]} {
					Inf "File '$zfnam' In Muted Line Does Not Exist"	
					return
				}
			}
			set hilitecheck $ilist
			foreach i $mutelines {
				set line [$m_list get $i]
				set line [string range $line 1 end]
				set mlst [lreplace $mlst $i $i $line]
			}
			foreach i $unmutelines {
				set line ";"
				append line [$m_list get $i]
				set mlst [lreplace $mlst $i $i $line]
			}
			set checkdata 2
			break
		}
		if {[string match $action "inject"]} {
			if {([string length $prm(2)] <= 0) || ![IsNumeric $prm(2)] || ($prm(2) <= 0.0) || ($prm(2) > 1.0)} {
				Inf "Mix Level ($prm(2)) Set On Parameters Page Is Not A Valid Value"
				return
			}
			set line ";MIX LEVEL $prm(2)"
			set oldline [lindex $mlst 0]
			set OK 0
			if {[string first ";" $oldline] > 0} {
				set OK 1
				set oldline [split $oldline]
				set cnt 0
				foreach item $oldline {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					switch -- $cnt {
						0 {
							set item [StripCurlies $item]
							if {![string match $item ";MIX"]} {
								set OK 0
								break
							}
						}
						1 {
							if {![string match $item "LEVEL"]} {
								set OK 0
								break
							}
						}
						2 {
							if {([string length $item] <= 0) || ![IsNumeric $item] || ($item <= 0.0) || ($item > 1.0)} {
								set OK 0
							}
							break
						}
					}
					incr cnt
				}
			}
			if {$OK} {
				set msg "Replace Existing \"MIX LEVEL\" Comment Line ??"
				set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					set mlst [lreplace $mlst 0 0 $line]
					set ijreplaced 1
				} else {
					set msg "Insert New \"MIX LEVEL\" Comment Line ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						return
					}
				}
			}
			if {![info exists ijreplaced]} {
				set mlst [linsert $mlst 0 $line]
			}
			catch {unset ijreplaced}
			set checkdata 2
			break
		}
		if {[string match $action "reinject"]} {
			set line [lindex $mlst 0]
			if {[string first ";" $line] < 0} {
				Inf "No Level Value Found In A First (comment) Line Of Mixfile"
				return
			}
			set line [split $line]
			set cnt 0
			set OK 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						set item [StripCurlies $item]
						if {![string match $item ";MIX"]} {
							break
						}
					}
					1 {
						if {![string match $item "LEVEL"]} {
							break
						}
					}
					2 {
						if {([string length $item] > 0) && [IsNumeric $item] && ($item > 0.0) && ($item <= 1.0)} {
							set prm(2) $item
							set OK 1
						}
						break
					}
				}
				incr cnt
			}
			if {!$OK} {
				Inf "No Valid Level Value Found In First (comment) Line Of Mixfile"
			}
			set checkdata 2
			break
		}
		if {[string match $action "clik"]} {
			set ilist [$m_list curselection]
			if {[llength $ilist] != 1} {
				Inf "Select Just One Line"
				return
			}
			set i [lindex $ilist 0] 
			if {$i == -1} {
				Inf "No Line Selected"
				return
			}
			set line [$m_list get  $i]
			if {[string match [string index $line 0] ";"]} {
				set line [string range $line 1 end]
			}
			set qiki $i
			set qikclik $line
			if {$is_the_main} {
				set qiki_main $qiki
				set qikclik_main $qikclik
			}
			$m_list selection clear 0 end
			$m_list selection set $qiki
			set k [$m_list index end]
			set k [expr double($qiki) / double($k)]
			$m_list yview moveto $k
			DuplTest
			return
		}
		if {[string match $action "clikon"]} {
			if {![info exists qiki]} {
				Inf "No Click Line Set"
				return
			}
			set len [llength $mlst]
			if {$qiki < $len} {
				set line [$m_list get $qiki]
				if {[string match [string index $line 0] ";"]} {
					set clickon 0
					set line [string range $line 1 end]
				} else {
					set clickon 1
				}
				if {![string match $line $qikclik]} {
					unset clickon
				}
			}
			if {![info exists clickon]} {
				set kk 0
				while {$kk < $len} {
					set line [$m_list get $kk]
					if {[string match [string index $line 0] ";"]} {
						set click_on 0
						set line [string range $line 1 end]
					} else {
						set click_on 1
					}
					if {[string match $line $qikclik]} {
						set gotqiki $kk
						break
					}
					incr kk
				}
				if {![info exists gotqiki]} {
					Inf "Click Line No Longer Exists"
					unset qiki
					unset qikclik		
					if {$is_the_main} {
						catch {unset qiki_main}
						catch {unset qikclik_main}
					}		
					return
				}
				set qiki $gotqiki
				set clickon $click_on
			}
			if {$clickon} {
				set nuline ";"
				append nuline $line
				set line $nuline
			}
			set mlst [lreplace $mlst $qiki $qiki $line]
			set checkdata 2
			break
		}
		if {[string match $action "movetop"] || [string match $action "movebot"]} {
			set ilist [$m_list curselection]
			set ilen [llength $ilist]
			if {($ilen <= 0) || (($ilen == 1) && ([lindex $ilist 0] == -1))} {
				Inf "No Lines Selected"
				return
			}
			catch {unset mlst}
			foreach i $ilist {
				lappend mlst [$m_list get $i]
			}
			set len [$m_list index end]
			set k 0
			catch {unset zlst}
			while {$k < $len} {
				if {[lsearch $ilist $k] < 0} {
					lappend zlst [$m_list get $k]
				}
				incr k
			}
			if {![info exists zlst]} {
				return
			}
			catch {unset m_list_restore}
			if {[string match $action "movetop"]} {
				foreach item $zlst {
					lappend mlst $item
				}
				set kk 0
				while {$kk < $ilen} {
					lappend m_list_restore $kk
					incr kk
				}
			} else {
				set kk [llength $zlst]
				foreach item $mlst {
					lappend zlst $item
					lappend m_list_restore $kk
					incr kk
				}
				set mlst $zlst
			}
			set checkdata 0
			break
		}
		if {[string match $action "movembot"]} {
			catch {unset morder}
			$m_list selection clear 0 end
			foreach line [$m_list get 0 end] {
				if {[string match ";" [string index [lindex $line 0] 0]]} {
					lappend mutedlist $line
				} else {
					lappend unmutedlist $line
				}
			}
			if {![info exists mutedlist]} {
				Inf "No muted lines"
			}
			set len [llength $mutedlist]
			if {$len > 1} {
				foreach line $mutedlist {
					lappend morder [lindex $line 1]
				}
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					set line_n [lindex $mutedlist $n]
					set time_n [lindex $morder $n]
					set m $n
					incr m
					while {$m < $len} {
						set line_m [lindex $mutedlist $m]
						set time_m [lindex $morder $m]
						if {$time_m < $time_n} {
							set mutedlist [lreplace $mutedlist $n $n $line_m]
							set mutedlist [lreplace $mutedlist $m $m $line_n]
							set morder [lreplace $morder $n $n $time_m]
							set morder [lreplace $morder $m $m $time_n]
							set line_n [lindex $mutedlist $n]
							set time_n [lindex $morder $n]
						}
						incr m
					}
					incr n
				}
			}
			set mlst [concat $unmutedlist $mutedlist]
			set kk [llength $unmutedlist]
			set jj [llength $mlst]
			while {$kk < $jj} {
				lappend m_list_restore $kk
				incr kk
			}
			set checkdata 0
			break
		}
		if {[string match $action "reverse"]} {
			set ilist [$m_list curselection]
			set m_list_restore $ilist
			if {[llength $ilist] < 2} {
				Inf "Select At Least Two Lines"
				return
			}
			set len [$m_list index end]
			catch {unset mlst}
			set revilist [ReverseList $ilist]
			set j 0
			set thisval  [lindex $ilist $j]
			set thatval  [lindex $revilist $j]
			set ilen [llength $ilist]
			set k 0
			while {$k < $len} {
				if {$k < $thisval} {
					lappend mlst [$m_list get $k]
				} else {
					lappend mlst [$m_list get $thatval]
					incr j
					if {$j >= $ilen} {
						set thisval 100000
					} else {
						set thisval [lindex $ilist $j]
						set thatval [lindex $revilist $j]
					}
				}
				incr k
			}		
			set checkdata 0
			break
		}
		if {[string match $action "tozero"]} {
			set linecnt 0
			catch {unset mlst}
			foreach line [$m_list get 0 end] {
				set line [string trim $line]
				if {[string match ";" [string index $line 0]]} {
					lappend mlst $line
					incr linecnt
					continue
				}
				set line [split $line]
				set cnt 0
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					if {$cnt == 1} {
						if {![info exists mintime]} {
							set mintime $item
						} elseif {$item < $mintime} {
							set mintime $item
						}
					}
					lappend nuline $item
					incr cnt
				}
				lappend mlst $nuline
				incr linecnt
			}
			if {![info exists mintime]} {
				return
			}
			if {$mintime == 0.0} {
				Inf "Mix Already Starts At Zero"
				raise .mixdisplay2
				return
			}
			set n 0
			while {$n < $linecnt} {
				set line [lindex $mlst $n]
				if {[string match ";" [string index $line 0]]} {
					incr n
					continue
				}
				set thistime [lindex $line 1]
				set thistime [expr $thistime - $mintime]
				set line [lreplace $line 1 1 $thistime]
				set mlst [lreplace $mlst $n $n $line]
				incr n
			}
			set checkdata 1
			break
		} elseif {[string match $action "muteorder"]} {
			catch {unset times}
			catch {unset timenos}
			set n 0
			foreach line $mlst {
				set linex [RemoveCurlies $line]
				if {[string match ";" [string index $linex 0]]} {
					if {[llength $linex] < 2} {
						lappend times "C"		;#	mark REAL comments (not muted lines), untimed so far
					} else {
						set ctime [lindex $linex 1]
						if {[IsNumeric $ctime] && ($ctime >= 0.0)} {
							lappend times $ctime
							set lasttime [lindex $times end]
						} else {
							lappend times "C"		;#	mark REAL comments (not muted lines), untimed so far
						}
					}
				} else {
					lappend times [lindex $line 1]
					set lasttime [lindex $times end]
				}
				lappend timenos $n
				incr n
			}
			if {![info exists times]} {
				Inf "NO TIMED LINES FOUND"
				return
			}
			set line_cnt $n
			set m $n
			incr m -1
			set n 0
			while {$n < $line_cnt} {	;#	Comments get time of line AFTER THEM (as list is in reverse order)
				set time [lindex $times $n]
				if {[string match $time "C"]} {
					if {$n == $m} {
						set times [lreplace $times $n $n $lasttime]
					} else {
						set k [expr $n + 1]
						while {$k < $line_cnt} {
							set nexttime [lindex $times $k]
							if {![string match $nexttime "C"]} {
								set times [lreplace $times $n $n $nexttime]
								break
							}	
							incr k
						}
						if {$k == $line_cnt} {
							set times [lreplace $times $n $n $lasttime]
						}
					}
				}
				incr n
			}
				
			set k 0
			while {$k < $m} {	
				set time1 [lindex $times $k] 
				set timeno1 [lindex $timenos $k]
				set j [expr $k + 1]
				while {$j < $n} {	
					set time2 [lindex $times $j] 
					set timeno2 [lindex $timenos $j]
					if {$time1 < $time2} {
						set times [lreplace $times $k $k $time2]
						set times [lreplace $times $j $j $time1]
						set timenos [lreplace $timenos $k $k $timeno2]
						set timenos [lreplace $timenos $j $j $timeno1]
						set time1 $time2
						set timeno1 $timeno2
					}
					incr j
				}
				incr k
			}
			set k 0
			while {$k < $n} {
				set index [lindex $timenos $k]
				lappend new_linestore [lindex $mlst $index]
				incr k
			}
			set new_linestore [ReverseList $new_linestore]
			set k 0
			while {$k < $n} {
				set line [lindex $new_linestore $k]
				if {[string first ";" $line] >= 0} {
					if {([llength $line] < 2) || ![IsNumeric [lindex $line 1]] || ([lindex $line 1] < 0.0)} {
						lappend clist comment
					} else {
						lappend clist muted
					}
				} else {
					lappend clist timed
				}
				incr k
			}
			set k 0
			catch {unset lasttime}
			while {$k < $n} {
				set item [lindex $clist $k]
				switch -- $item {
					"comment" {
						if {[info exists lasttime_index]} {
							set lasttimeline [lindex $new_linestore $lasttime_index]
							set thiscomment  [lindex $new_linestore $k]
							set new_linestore [lreplace $new_linestore $lasttime_index $lasttime_index $thiscomment]
							set new_linestore [lreplace $new_linestore $k $k $lasttimeline]
							set clist [lreplace $clist $k $k "timed"]
							set clist [lreplace $clist $lasttime_index $lasttime_index "comment"]
							set lasttime_index $k
						}
					}
					"timed" {
						if {![info exists lasttime_index] || ([lindex [lindex $new_linestore $k] 1] > $lasttime)} {
							set lasttime_index $k
							set lasttime [lindex [lindex $new_linestore $k] 1]
						}
					}
				}
				incr k
			}
			set mlst $new_linestore
			set checkdata 1
			break
		}
		if {$action == "mgain"} {
			set ilist {}
			set i 0
			foreach line [$m_list get 0 end] {
				set line [string trim $line]
				if {[string match ";" [string index $line 0]]} {
					incr i
					continue
				}
				lappend ilist $i
				incr i
			}
		} else {
			set ilist [$m_list curselection]
		}
		if {[llength $ilist] >= 1} {
			set m_list_restore $ilist
		}
		if {[string match $action "nextfile"]} {
			set ilist [$m_list curselection]
			set k [llength $ilist]
			if {$k <= 0} {
				Inf "No Mixfile Line Selected"
				raise .mixdisplay2
				return
			}
			if {$k > 1} {
				Inf "Select A Single Mixfile Line"
				raise .mixdisplay2
				return
			}
			if {$mm_multichan} {
				set zline [$m_list get $ilist]
				set zline0 [lindex $zline 0]
				if {[string match ";" [string index $zline 0]]} {
					Inf "No Operational Line Chosen"
					raise .mixdisplay2
					return
				}
				set inchans [lindex $zline 2]
			}
			set zline [$m_list get $ilist]
			set zline0 [lindex $zline 0]
			if {[string match ";" [string index $zline 0]]} {
				Inf "No Operational Line Chosen"
				raise .mixdisplay2
				return
			}
			set qknext $zline0
			return
		} elseif {[string match $action "file"] || [string match $action "lastfile"]} {
			set ilist [$m_list curselection]
			set k [llength $ilist]
			if {$k <= 0} {
				Inf "No Mixfile Line Selected"
				raise .mixdisplay2
				return
			}
			catch {unset inchans}
			foreach i $ilist {
				set zline [$m_list get $i]
				set zline0 [lindex $zline 0]
				if {[string match ";" [string index $zline 0]]} {
					Inf "Non-Operational Line Chosen"
					raise .mixdisplay2
					return
				}
				if {![info exists inchans]} {
					set inchans [lindex $zline 2]
				} elseif {![string match $inchans [lindex $zline 2]]} {
					Inf "Not All Chosen Lines Have Same Number Of Channels"
					raise .mixdisplay2
					return
				}
				lappend zlines $zline
			}
			if {[string match $action "lastfile"]} {
				set val [$wl get 0]
				if {$val == $mixrestorename} {
					set val [$wl get 1]
				}
				if {$pa($val,$evv(FTYP)) != $evv(SNDFILE)} {
					Inf "Last File Made Was Not A Soundfile"
					raise .mixdisplay2
					return
				}
				if {$mm_multichan} {
					if {$pa($val,$evv(CHANS)) > $mix_outchans} {
						Inf "Last File Made Has Too Many Channels For This Mixfile"
						raise .mixdisplay2
						return
					}
				} else {
					if {$pa($val,$evv(CHANS)) > 2} {
						Inf "Last File Made Has Too Many Channels For This Mixfile"
						raise .mixdisplay2
						return
					}
				}
			} else {
				set val [GetWkspaceFileForQikEdit $mm_multichan]
				if {[string length $val] <= 0} {
					Inf "No Filename Entered"
					raise .mixdisplay2
					return
				}
				set k [string first "." $val]
				if {$k < 0} {
					set val $val$evv(SNDFILE_EXT)
					if {![info exists pa($val,$evv(FTYP))]} {
						Inf "File $val Is Not On The Workspace"
						raise .mixdisplay2
						return
					} elseif {$pa($val,$evv(FTYP)) != $evv(SNDFILE)} {
						Inf "File $val Is Not A Soundfile"
						raise .mixdisplay2
						return
					}
				}
			}
			if {$mm_multichan} {
				if {$pa($val,$evv(CHANS)) != $inchans} {
					set msg "New File $val Has Different Channel Count ($pa($val,$evv(CHANS))) To Existing Files ($inchans)"
					append msg "\nReplace File Anyway ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						raise .mixdisplay2
						return
					} else {
						set mm_list $m_list
						foreach zline $zlines i $ilist {
							set max_lev 0
							set zline [split $zline]
							set zzcnt 0
							foreach itemm $zline {
								set itemm [string trim $itemm]
								if {[string length $itemm] > 0} {
									if {$zzcnt == 1} {
										set tttime $itemm
										if {![IsNumeric $tttime] || ($tttime < 0.0)} {
											Inf "Invalid Time On One Of Selected Mixfile Lines"
											raise .mixdisplay2
											return
										}
									} elseif {($zzcnt > 2) && [IsEven $zzcnt]} {
										if {$itemm > $max_lev} {
											set max_lev $itemm
										}
									}
									incr zzcnt
								}
							}
							if {![info exists tttime]} {
								Inf "No Time Found On One Of Selected Mixfile Lines"
								raise .mixdisplay2
								return
							}
							set ch_ans $pa($val,$evv(CHANS))
							set nu_line $val 
							append nu_line " " $tttime " " $ch_ans
							set z 1
							while {$z <= $ch_ans} {
								set route [ChanToRoute $z]
								append nu_line " " $route " " $max_lev
								incr z
							}
							catch {unset mlst}
							set kk 0
							while {$kk < $i} {
								set item [$mm_list get $kk]
								lappend mlst $item
								incr kk
							}
							lappend mlst $nu_line
							incr kk
							while {$kk < [$mm_list index end]} {
								set item [$mm_list get $kk]
								lappend mlst $item
								incr kk
							}
							set mm_list $mlst
						}
						set linecnt [llength $mlst]
						set mlst [ReverseList $mlst]
						set mlst [SortMix $linecnt $mlst]
						set mlst [ReverseList $mlst]
						set checkdata 2
						break
					}
				}
			} elseif {$pa($val,$evv(CHANS)) > 2} {
				Inf "File $val Has Too Many Channels"
				raise .mixdisplay2
				return
			}
			foreach i $ilist {
				$m_list selection set $i
			}
		} elseif {[string match $action "every"]} {
			set ilist [$m_list curselection]
			set k [llength $ilist]
			if {$k <= 0} {
				Inf "No Mixfile Line Selected"
				raise .mixdisplay2
				return
			}
			if {$k > 1} {
				Inf "Select A Single Mixfile Line"
				raise .mixdisplay2
				return
			}
			set zline [$m_list get $ilist]
			set zline0 [lindex $zline 0]
			if {[string match ";" [string index $zline 0]]} {
				Inf "No Operational Line Chosen"
				raise .mixdisplay2
				return
			}
			set inchans [lindex $zline 2]
			set val [GetWkspaceFileForQikEdit $mm_multichan]
			if {[string length $val] <= 0} {
				Inf "No Filename Entered"
				raise .mixdisplay2
				return
			}
			set k [string first "." $val]
			if {$k < 0} {
				set val $val$evv(SNDFILE_EXT)
				if {![info exists pa($val,$evv(FTYP))]} {
					Inf "File '$val' Is Not On The Workspace"
					raise .mixdisplay2
					return
				} elseif {$pa($val,$evv(FTYP)) != $evv(SNDFILE)} {
					Inf "File '$val' Is Not A Soundfile"
					raise .mixdisplay2
					return
				}
			}
			if {$mm_multichan} {
				if {$pa($val,$evv(CHANS)) != $inchans} {
					Inf "New File '$val' Has Different Channel Count ($pa($val,$evv(CHANS))) To Existing File ($inchans)"
					raise .mixdisplay2
					return
				}
			} elseif {$pa($val,$evv(CHANS)) > 2} {
				Inf "File '$val' Has Too Many Channels"
				raise .mixdisplay2
				return
			}
			set n 0
			catch {unset ilist}
			foreach line [$m_list get 0 end] {
				set zfnam [lindex $line 0]
				if {[string match $zfnam $zline0]} {
					lappend ilist $n
				}
				incr n
			}
			foreach i $ilist {
				$m_list selection set $i
			}
		} elseif {[string match $action "many"]} {
			set ilist [$m_list curselection]
			catch {unset z_fnam}
			catch {unset z_any}
			catch {unset inchans}
			foreach i $ilist {
				set zline [$m_list get $i]
				set zfnam [lindex $zline 0]
				if {[string match ";" [string index $zfnam 0]]} {
					Inf "SOME SELECTED LINES ARE NOT ACTIVE"
					raise .mixdisplay2
					return
				}
				if {![info exists z_fnam]} {
					set z_fnam $zfnam
				} elseif {![info exists z_any]} {
					if {![string match $z_fnam $zfnam]} {
						set msg "Not All Selected Files Are The Same: Proceed To Replace Anyway ??"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "no"} {
							raise .mixdisplay2
							return
						} else {
							set z_any 1
						}
					}
				}
				if {![info exists inchans]} {
					set inchans [lindex $zline 2]
				} elseif {$inchans != [lindex $zline 2]} {
					Inf "Not All Selected Files Have Same Number Of Channels: Cannot Proceed"
					raise .mixdisplay2
					return
				}
			}
			set val [GetWkspaceFileForQikEdit $mm_multichan]
			if {[string length $val] <= 0} {
				Inf "No Filename Entered"
				raise .mixdisplay2
				return
			}
			set k [string first "." $val]
			if {$k < 0} {
				set val $val$evv(SNDFILE_EXT)
				if {![info exists pa($val,$evv(FTYP))]} {
					Inf "File '$val' Is Not On The Workspace"
					raise .mixdisplay2
					return
				} elseif {$pa($val,$evv(FTYP)) != $evv(SNDFILE)} {
					Inf "File '$val' Is Not A Soundfile"
					raise .mixdisplay2
					return
				}
			}
			catch {unset many_newchans}
			set many_unity {}
			if {$pa($val,$evv(CHANS)) != $inchans} {
				set many_newchans $pa($val,$evv(CHANS))
				set msg "New File '$val' Has Different Channel Count ($pa($val,$evv(CHANS))) To Existing Files ($inchans): Proceed Anyway ??"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "no"} {
					raise .mixdisplay2
					return
				}
				foreach i $ilist {
					catch {unset levv}
					set line [$m_list get $i]
					set cnt 0
					foreach item [lrange $line 4 end] {
						if {![IsEven $cnt]} {
							incr cnt
							continue
						}
						if {![info exists levv]} {
							set levv $item
						} elseif {$levv != $item} {
							set msg "File '$ifnam' Output Level Ambiguous ($levv or $item):\n\nDefault To Unity Gain For This File ??\n"
							set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
							if {$choice == "no"}  {
								raise .mixdisplay2
								return
							} else {
								lappend many_unity [lindex $line 0]
							}
						}
						incr cnt
					}
				}
			}
		} elseif {[string match $action "tobilat"] || [string match $action "frmbilat"]} {
			catch {unset mlst}
			foreach item [$m_list get 0 end] {
				lappend mlst [string trim $item]
			}
			set len [llength $mlst]
			set k 0
			while {$k < $len} {
				set line [lindex $mlst $k]
				set line [string trim $line]
				if {[string match ";" [string index $line 0]]} {
					incr k
					continue
				}
				catch {unset nuline}
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					if {[regexp {:} $item] && ![file exists $item]} {
						switch -- $action {
							"tobilat" {
								set item [Bilateral $item 0 $mix_outchans]
							}
							"frmbilat" {
								set item [Bilateral $item 1 $mix_outchans]
							}
						}
					}
					lappend nuline $item
				}
				set mlst [lreplace $mlst $k $k $nuline]
				incr k
			}
			set checkdata 0
			break
		} elseif {[string match $action "mirfram"]} {
			set ilist [$m_list curselection]
			if {([llength $ilist] ==1) && ($ilist == -1)} {
				Inf "No Lines Selected"
				return
			}
			if {[string length $mixval] <= 0} {
				Inf "No Mirror Axis Given"
				return
			} elseif {![IsNumeric $mixval]} {
				Inf "Invalid Mirror Axis Given"
				return
			}
			set q [split $mixval "."]
			set mirrorplane [lindex $q 0]
			if {($mirrorplane < 1) || ($mirrorplane > $mix_outchans)} {
				Inf "Mirror Axis Incompatible With Number Of Output Channels ($mix_outchans)"
				return
			}
			if {[llength $q] > 1} {
				if {[lindex $q 1] != 5} {
					Inf "Mirror Axis Must Be An Integer, Or A Half Integer (e.g. 2.5, 4.5)"
					return
				}
			}
			foreach i $ilist {
				set line [lindex $mlst $i]
				set line [string trim $line]
				if {[string first ";" $line] >= 0} {
					continue
				}
				catch {unset nuline}
				set line [split $line]
				set cnt 0
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					if {[regexp {:} $item] && ![file exists $item]} {
						set item [MirrorFrame $item $mix_outchans $mixval]
					}
					lappend nuline $item
				}
				if {$istemp} {
					set line ";"
					append line [lindex $mlst $i] 
					set mlst [lreplace $mlst $i $i $line $nuline]
				} else {
					set mlst [lreplace $mlst $i $i $nuline]
				}
			}
			set checkdata 0
			break
		} elseif {[string match $action "hicom"]} {
			$m_list selection clear 0 end
			set kk 0
			foreach line [$m_list get 0 end] {
				if {[string match ";" [string index [lindex $line 0] 0]]} {
					$m_list selection set $kk
					if {![info exists jj]} {
						set jj $kk
					}
				}
				incr kk				
			}
			if {[info exists jj]} {
				set k [$m_list index end]
				if {$k > 0.0} {
					set k [expr double($jj) / double($k)]
					$m_list yview moveto $k
				}
			} else {
				Inf "No Muted Lines"
			}
			return
		} elseif {[string match $action "trndall"]} {
			set msg "Round All Times To 4 Sigfig ??"
			set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "no"} {
				return
			}
			$m_list selection clear 0 end
			set endd [$m_list index end]
			set kk 0
			while {$kk < $endd} {
				set line [$m_list get $kk]
				if {![string match ";" [string index [lindex $line 0] 0]]} {
					set tim [lindex $line 1]
					set tim [DecPlaces $tim 4]
					set line [lreplace $line 1 1 $tim]
					$m_list delete $kk
					$m_list insert $kk $line
				}
				incr kk
			}
			if {[info exists m_list_restore]} {
				foreach i $m_list_restore {
					$m_list selection set $i
				}
			}
			RedefineMixfileEnd
			DuplTest
			return
		} elseif {[string match $action "trnd"]} {
			set ilist [$m_list curselection]
			$m_list selection clear 0 end
			foreach i $ilist {
				set line [$m_list get $i]
				if {![string match ";" [string index [lindex $line 0] 0]]} {
					set tim [lindex $line 1]
					set tim [DecPlaces $tim 4]
					set line [lreplace $line 1 1 $tim]
					$m_list delete $i
					$m_list insert $i $line
					lappend jlist $i
				}
			}
			if {[info exists jlist]} {
				foreach i $jlist {
					$m_list selection set $i
				}
			}
			RedefineMixfileEnd
			DuplTest
			return
		} elseif {[string match $action "identic"]} {
			set ilist [$m_list curselection]
			set k [llength $ilist]
			if {$k <= 0} {
				Inf "No Mixfile Line Selected"
				raise .mixdisplay2
				return
			}
			if {$k > 1} {
				Inf "Select A Single Mixfile Line"
				raise .mixdisplay2
				return
			}
			set msg "Show Duplicates In Muted Lines As Well As Operational Lines ??"
			set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "yes"} {
				set show_and_dupls 1
			} else {
				set show_and_dupls 0
			}
			set line [$m_list get [lindex $ilist 0]]
			set fnam [lindex $line 0]
			if {[string match ";" [string index $fnam 0]]} {
				if {$show_and_dupls} {
					set fnam [string range $fnam 1 end]
					if {![file exists $fnam]} {
						Inf "There Is No Existing Soundfile In This Line"
						raise .mixdisplay2
						return
					}
				} else {
					Inf "No Operational Line Selected"
					raise .mixdisplay2
					return
				}
			}
			$m_list selection clear 0 end
			set kk 0
			set jj 0
			foreach line [$m_list get 0 end] {
				set thisfnam [lindex $line 0]
				if {$show_and_dupls && [string match ";" [string index $thisfnam 0]]} {
					set thisfnam [string range $thisfnam 1 end]
				}
				if {[string match $fnam $thisfnam]} {
					$m_list selection set $kk
					incr jj
				}
				incr kk				
			}
			if {$jj <= 1} {
				Inf "No Repeats Found"
				raise .mixdisplay2
			}
			return
		} elseif {[string match $action "identic2"]} {
			set m_list_restore {}
			set len [$m_list index end]
			set len_less_one [expr $len - 1]
			set n 0
			while {$n < $len_less_one} {
				set line_n [$m_list get $n]
				if {[string match ";" [string index $line_n 0]]} {
					incr n
					continue
				}
				set fnam_n [lindex $line_n 0]
				set m $n
				incr m
				while {$m < $len} {
					set line_m [$m_list get $m]
					if {[string match ";" [string index $line_m 0]]} {
						incr m
						continue
					}
					set fnam_m [lindex $line_m 0]
					if {[string match $fnam_m $fnam_n]} {
						if {[lsearch $m_list_restore $m] < 0} {
							lappend m_list_restore $m
						}
						if {[lsearch $m_list_restore $n] < 0} {
							lappend m_list_restore $n
						}
					}
					incr m
				}
				incr n
			}
			$m_list selection clear 0 end
			if {[llength $m_list_restore] == 0} {
				Inf "No Repeated Sounds Found"
				raise .mixdisplay2
			} else {
				$m_list selection clear 0 end
				foreach kk $m_list_restore {
					$m_list selection set $kk
				}
			}
			return
		} elseif {[string match $action "adfile"] || [string match $action "adfilel"]} {
			set i_list [$m_list curselection]
			set zax 1
			if {([llength $i_list] > 1) || (([llength $i_list] == 1) && ([lindex $i_list 0] != -1))} {
				set msg "At Time Of Highlighted Line ?"
				set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "no"} {
					set zax 2
				} elseif {[llength $i_list] != 1} {
					Inf "If You Want To Insert The File At Same Time As A Specific File In The Mix,\nSelect Just One Line On The Display."
					raise .mixdisplay2
					return
				} else {
					set zzline [$m_list get $i_list]
					if {[string match [string index $zzline 0] ";"]} {
						set msg "Selected Line Is A Comment Line : Use Time In Comment ??"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "no"} {
							raise .mixdisplay2
							return
						}
					}
				}
			} else {
				set zax 2
			}
			if {$zax == 2} {
				if {([string length $val] > 0) && [IsNumeric $val] && ($val >= 0.0)} {
					set msg "At Time In 'Value' Box ?"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						set zax 0
					}
				} else {
					set zax 0
				}
			}
			switch -- $zax {
				0 {
					set tttime 0.0
					set m_list_restore 0
				}
				1 {
					set zzline [split $zzline]
					set zzcnt 0
					foreach itemm $zzline {
						set itemm [string trim $itemm]
						if {[string length $itemm] > 0} {
							if {$zzcnt == 1} {
								set tttime $itemm
								if {![IsNumeric $tttime] || ($tttime < 0.0)} {
									Inf "Invalid Time On This Line"
									raise .mixdisplay2
									return
								}
								break
							}
							incr zzcnt
						}
					}
					if {![info exists tttime]} {
						Inf "No Time Found"
						raise .mixdisplay2
						return
					}
					set m_list_restore [lindex $i_list 0]
				}
				2 {
					set tttime $val
					set m_list_restore [LineIndexAtTimeInQikEdit $tttime]
				}
			}
			if {[string match $action "adfilel"]} {
				set val [$wl get 0]
				if {$val == $mixrestorename} {
					set val [$wl get 1]
				}
				if {$pa($val,$evv(FTYP)) != $evv(SNDFILE)} {
					Inf "Last File Made Was Not A Soundfile"
					raise .mixdisplay2
					return
				} elseif {$pa($val,$evv(CHANS)) > $mix_outchans} {
					Inf "Last File Made Has Too Many Channels For This Mix"
					raise .mixdisplay2
					return
				}
			} else {
				set val [GetWkspaceFileForQikEdit $mm_multichan]
			}
			if {[string length $val] <= 0} {
				Inf "No New File Selected"
				raise .mixdisplay2
				return
			}
			set ch_ans $pa($val,$evv(CHANS))
			if {$mm_multichan} {
				set nu_line $val 
				append nu_line " " $tttime " " $ch_ans
				set z 1
				while {$z <= $ch_ans} {
					set route [ChanToRoute $z]
					append nu_line " " $route " " 1
					incr z
				}
			} else {
				switch -- $ch_ans {
					1 {
						set nu_line $val 
						append nu_line " " $tttime " " $ch_ans " " 1.0 " " C
					}
					2 {
						set nu_line $val 
						append nu_line " " $tttime " " $ch_ans " " 1.0 " " L " " 1.0 " " R
					}
				}
			}
			set added 0
			catch {unset mlst}
			foreach item [$m_list get 0 end] {
				if {[string first ";" $item] >= 0} {
					lappend mlst $item
				} else {
					set item [string trim $item]
					set kitem [split $item]
					set cntz 0
					foreach qk $kitem {
						set qk [string trim $qk]
						if {[string length $qk] <= 0} {
							continue
						}
						incr cntz
						if {$cntz == 2} {
							set thistime $qk
							break
						}
					}
					if {!$added} {
						if {[Flteq $thistime $tttime]} {
							lappend mlst $item
							lappend mlst $nu_line
							set added 1
						} elseif {$thistime > $tttime} {
							lappend mlst $nu_line
							lappend mlst $item
							set added 1
						} else {
							lappend mlst $item
						}
					} else {
						lappend mlst $item
					}
				}
			}
			if {!$added} {
				lappend mlst $nu_line
			}
			if {[info exists m_list_restore]} {
				set xoldline [$m_list get $m_list_restore]
				set xoldline [RemoveCurlies $xoldline]
				set oldline ";"
				append oldline $xoldline
			}
			set mlst [ReverseList $mlst]
			set linecnt [llength $mlst]
			set mlst [SortMix $linecnt $mlst]
			set mlst [ReverseList $mlst]
			if {$istemp && ![DuplTest2 $mlst] && ($zax == 1) && [info exists oldline]} {	;#	Force inserted line to be below
				set len [llength $mlst]														;#	commented out old line
				set k 0
				while {$k < $len} {
					set line [lindex $mlst $k]
					if {[string match $line $nu_line]} {
						set newli $k
					} elseif {[string match $line $oldline]} {
						set oldli $k
					}
					incr k
				}
				if {[info exists newli] && [info exists oldli]} {
					set nexli [expr $oldli + 1]
					if {$newli != $nexli} {
						while {$newli > $nexli} {
							set mlst [lreplace $mlst $newli $newli [lindex $mlst [expr $newli - 1]]]
							incr newli -1
						}
						set mlst [lreplace $mlst $nexli $nexli $nu_line]
					} elseif {$newli < $nexli} {
						while {$newli < $oldli} {
							set mlst [lreplace $mlst $newli $newli [lindex $mlst [expr $newli + 1]]]
							incr newli
						}
						set mlst [lreplace $mlst $newli $newli $nu_line]
					}
				}
			}
			set checkdata 2
			break
		} elseif {[string match $action "repret"]} {
			set i_list [$m_list curselection]
			if {[llength $i_list] == 1} {
				set zzline [$m_list get $i_list]
				if {[string match [string index $zzline 0] ";"]} {
					Inf "Selected line is a comment line"
					raise .mixdisplay2
					return
				}
				set m_list_restore $i_list
			} else {
				Inf "Select one line on the display."
				raise .mixdisplay2
				return
			}
			set zzline [split $zzline]
			set zzcnt 0
			foreach itemm $zzline {
				set itemm [string trim $itemm]
				if {[string length $itemm] > 0} {
					if {$zzcnt == 1} {
						set tttime $itemm
						if {![IsNumeric $tttime] || ($tttime < 0.0)} {
							Inf "Invalid time on this line"
							raise .mixdisplay2
							return
						}
						break
					}
					incr zzcnt
				}
			}
			if {![info exists tttime]} {
				Inf "No time found in selected line"
				raise .mixdisplay2
				return
			}
			set mixval [string trim $mixval]
			if {[string length $mixval] <= 0} {
				Inf "No timestep value entered"
				raise .mixdisplay2
				return
			}
			catch {unset is_beats}
			if {[string match [string tolower [string index $mixval end]] "b"]} {
				set is_beats 1
				set mmmlen [string length $mixval]
				if {$mmmlen < 2} {
					Inf "Invalid timestep value entered"
					raise .mixdisplay2
					return
				}					
				incr mmmlen -2
				set mmixval [string range $mixval 0 $mmmlen]
				if {![regexp {^[0-9]+$} $mmixval] || ![IsNumeric $mmixval] || ($mmixval == 0)} {
					Inf "Invalid number of beats entered (must be an integer > 0)"
					raise .mixdisplay2
					return
				}
				set qstep [FindQuantisationDuration]
				if {$qstep <= 0.0} {
					raise .mixdisplay2
					return
				}
				set mixval [expr $mmixval * $qstep]
			} else {
				if {![IsNumeric $mixval] || ($mixval <= 0)} {
					Inf "Invalid timestep entered (must be  > 0.0)"
					raise .mixdisplay2
					return
				}
			}
			set val [GetWkspaceFileForQikEdit $mm_multichan]
			if {[string length $val] <= 0} {
				Inf "No new file selected"
				raise .mixdisplay2
				return
			}
			set ch_ans $pa($val,$evv(CHANS))
			if {$mm_multichan} {
				set nu_line $val 
				append nu_line " " $tttime " " $ch_ans
				set z 1
				while {$z <= $ch_ans} {
					set route [ChanToRoute $z]
					append nu_line " " $route " " 1
					incr z
				}
			} else {
				switch -- $ch_ans {
					1 {
						set nu_line $val 
						append nu_line " " $tttime " " $ch_ans " " 1.0 " " C
					}
					2 {
						set nu_line $val 
						append nu_line " " $tttime " " $ch_ans " " 1.0 " " L " " 1.0 " " R
					}
				}
			}
			catch {unset mlst}
			foreach item [$m_list get 0 end] {
				lappend mlst $item
			}
			if {$istemp} {
				set xoldline [$m_list get $m_list_restore]
				set xoldline [RemoveCurlies $xoldline]
				set oldline ";"
				append oldline $xoldline
			}
			set mlst [lreplace $mlst $i_list $i_list $nu_line]
			if {$istemp} {
				set mlst [linsert $mlst $i_list $oldline]
			}
			set mlst [ReverseList $mlst]
			set linecnt [llength $mlst]
			set mlst [SortMix $linecnt $mlst]
			set mlst [ReverseList $mlst]
			if {$istemp && ![DuplTest2 $mlst] && [info exists oldline]} {	;#	Force inserted line to be below
				set len [llength $mlst]										;#	commented out old line
				set k 0
				while {$k < $len} {
					set line [lindex $mlst $k]
					if {[string match $line $nu_line]} {
						set newli $k
					} elseif {[string match $line $oldline]} {
						set oldli $k
					}
					incr k
				}
				if {[info exists newli] && [info exists oldli]} {
					set nexli [expr $oldli + 1]
					if {$newli != $nexli} {
						while {$newli > $nexli} {
							set mlst [lreplace $mlst $newli $newli [lindex $mlst [expr $newli - 1]]]
							incr newli -1
						}
						set mlst [lreplace $mlst $nexli $nexli $nu_line]
					} elseif {$newli < $nexli} {
						while {$newli < $oldli} {
							set mlst [lreplace $mlst $newli $newli [lindex $mlst [expr $newli + 1]]]
							incr newli
						}
						set mlst [lreplace $mlst $newli $newli $nu_line]
					}
				}
			}
			;#	FIND LAST ACTIVE LINE IN LIST
			set jkj 0
			catch {unset lastjkj}
			foreach line $mlst {
				if {[string first ";" $line] < 0} {
					set lastjkj $jkj
				}
				incr jkj
			}
			if {![info exists lastjkj]} {
				Inf "No active lines found in mix"
				set mlst $m_list_restore
				raise .mixdisplay2
				return
			}
			set jkj 0
			;#	SEARCH FOR THE NEW LINE
			foreach line $mlst {
				if {[string match $line $nu_line]} {
					break
				}
				incr jkj
			}
			if {$jkj >= $lastjkj} {
				Inf "Can't increase step at last (unmuted) line in mix"
				set mlst $m_list_restore
				raise .mixdisplay2
				return
			}
			incr jkj
			set origstep [expr [lindex [lindex $mlst $jkj] 1] - $tttime]
			set stepchange [expr $mixval - $origstep]
			while {$jkj < $linecnt} {
				set line [lindex $mlst $jkj]
				set time [expr [lindex $line 1] + $stepchange]
				set line [lreplace $line 1 1 $time]
				set mlst [lreplace $mlst $jkj $jkj $line]
				incr jkj
			}
			set checkdata 2
			break
		} elseif {[string match $action "admfile"]} {
			set i_list [$m_list curselection]
			set zax 1
			if {([llength $i_list] > 1) || (([llength $i_list] == 1) && ([lindex $i_list 0] != -1))} {
				set msg "At Time Of Highlighted Line ?"
				set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "no"} {
					set zax 2
				} elseif {[llength $i_list] != 1} {
					Inf "If You Want To Insert The File At Same Time As A Specific File In The Mix,\nSelect Just One Line On The Display."
					raise .mixdisplay2
					return
				} else {
					set zzline [$m_list get $i_list]
					if {[string match [string index $zzline 0] ";"]} {
						set msg "Selected Line Is A Comment Line : Use Time In Comment ??"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "no"} {
							raise .mixdisplay2
							return
						}
					}
				}
			} else {
				set zax 2
			}
			if {$zax == 2} {
				if {([string length $val] > 0) && [IsNumeric $val] && ($val >= 0.0)} {
					set msg "At Time In 'Value' Box ?"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						set zax 0
					}
				} else {
					set zax 0
				}
			}
			catch {unset set no_zax_sort}
			switch -- $zax {
				0 {
					set tttime 0.0
					set m_list_restore 0
					set msg "Keep Inserted Lines Together At Start Of Listing ?"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						set no_zax_sort 1
					}
				}
				1 {
					set zzline [split $zzline]
					set zzcnt 0
					foreach itemm $zzline {
						set itemm [string trim $itemm]
						if {[string length $itemm] > 0} {
							if {$zzcnt == 1} {
								set tttime $itemm
								if {![IsNumeric $tttime] || ($tttime < 0.0)} {
									Inf "Invalid Time-Value On Highlighted Line"
									raise .mixdisplay2
									return
								}
								break
							}
							incr zzcnt
						}
					}
					if {![info exists tttime]} {
						Inf "No Time Found"
						raise .mixdisplay2
						return
					}
					set m_list_restore [lindex $i_list 0]
				}
				2 {
					set tttime $val
					set m_list_restore [LineIndexAtTimeInQikEdit $tttime]
				}
			}
			set mfil [GetWkspaceMfileForQikEdit]
			if {[string length $mfil] <= 0} {
				Inf "No Mixfile Selected"
				raise .mixdisplay2
				return
			}
			if [catch {open $mfil "r"} zit] {
				Inf "Canot Open Mixfile '$mfil'"
				return
			}
			set nu_fnams {}
			set c_c_nt 0
			catch {unset reset_mmhead}
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				if {($c_c_nt == 0) && $mm_multichan} {
					if {$line > $mlsthead} {		;#	Compare chan-cnt in input with output chan-cnt
						set reset_mmhead $line
					}
					incr c_c_nt
					continue
				}
				set nu_fnam [lindex $line 0]
				if {[file exists $nu_fnam] && ([LstIndx $nu_fnam $wl] < 0)} {
					if {[lsearch $nu_fnams $nu_fnam] < 0} {
						lappend nu_fnams $nu_fnam
					}
				} 
				set timm [lindex $line 1]
				if {[IsNumeric $timm]} {		;#	Don't try to modify TRUE comment lines (as opposed to muted lines)
					set timm [expr $timm + $tttime]
					set line [lreplace $line 1 1 $timm]
				}
				lappend nuulines $line
				incr c_c_nt
			}
			close $zit
			if {![info exists nuulines]} {
				Inf "No Data Found In Mixfile '$mfil'"
				return
			}
			if {[info exists reset_mmhead]} {		;#	If ness, reset output chan count
				set mlsthead $reset_mmhead
			}
			if {[llength $nu_fnams] > 0} {
				foreach nu_fnam $nu_fnams {
					FileToWkspace $nu_fnam 0 0 0 0 0
				}
			}
			catch {unset mlst}
			if {[info exists no_zax_sort]} {
				foreach item $nuulines {
					lappend mlst $item
				}
				foreach item [$m_list get 0 end] {
					lappend mlst $item
				}
			} else {
				foreach item [$m_list get 0 end] {
					lappend mlst $item
				}
				foreach item $nuulines {
					lappend mlst $item
				}
			}
			set linecnt [llength $mlst]
			if {![info exists no_zax_sort]} {
				set mlst [ReverseList $mlst]
				set mlst [SortMix $linecnt $mlst]
				set mlst [ReverseList $mlst]
			}
			set checkdata 2
			break
		} elseif {[string match $action "dupl"]} {
			set mutes_asked 0
			set activate_mutes 0
			set ilist [$m_list curselection]
			if {([llength $ilist] <= 0) || ($ilist == -1)} {
				Inf	"No Files Selected For Duplication"
				raise .mixdisplay2
				return
			}
			foreach i $ilist {
				set line [$m_list get $i]
				set line [string trim $line]
				if {[string match [string index $line 0] ";"]} {
					if {!$mutes_asked} {
						if {[file exists [string range [lindex $line 0] 1 end]]} {
							set mutes_asked 1
							set msg "Activate Muted Line(s) ??"
							set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
							if {$choice  == "yes"} {
								set activate_mutes 1
							}
						}
					}
					if {$activate_mutes && [file exists [string range [lindex $line 0] 1 end]]} {
						set line [string range $line 1 end]
					} else {
						continue
					}
				}
				lappend nu_lines $line
			}
			if {![info exists nu_lines]} {
				Inf "No Active Lines Selected"
				raise .mixdisplay2
				return
			}
			if {![IsNumeric $val] || ($val < 0.0)} {
				Inf "Invalid Value For Entrytime Of Duplicated Lines"
				raise .mixdisplay2
				return
			}
			set linecnt 0
			foreach line $nu_lines {
				set line [split $line]
				set cnt 0
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					if {$cnt == 1} {
						lappend nuline $val
					} else {
						lappend nuline $item
					}
					incr cnt
				}
				set nuline [join $nuline]
				lappend nuout $nuline
				incr linecnt
			}
			catch {unset mlst}	
			foreach item [$m_list get 0 end] {
				lappend mlst $item
			}
			foreach item $nuout {
				lappend mlst $item
			}
			set linecnt [llength $mlst]
			set mlst [SortMix $linecnt $mlst]
			set mlst [ReverseList $mlst]
			set m_list_restore [LineIndexAtTimeInQikEdit $val]
			set checkdata 2
			break
		} elseif {[string match $action "duplseq"]} {
			set ilist [$m_list curselection]
			if {([llength $ilist] <= 0) || ($ilist == -1)} {
				Inf	"No Files Selected For Duplication"
				raise .mixdisplay2
				return
			}
			foreach i $ilist {
				set line [$m_list get $i]
				set line [string trim $line]
				if {[string match [string index $line 0] ";"]} {
					continue
				}
				lappend nu_lines $line
			}
			if {![info exists nu_lines]} {
				Inf "No Active Lines Selected"
				raise .mixdisplay2
				return
			}
			if {![IsNumeric $val] || ($val < 0.0)} {
				Inf "Invalid Value For Entrytime Of First Duplicated Lines"
				raise .mixdisplay2
				return
			}
			set linecnt 0
			foreach line $nu_lines {
				set line [split $line]
				set cnt 0
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					if {$cnt == 1} {
						if {$linecnt == 0} {
							set bastim $item
						}
						set item [expr $item - $bastim]
						lappend nuline [expr $val + $item]
					} else {
						lappend nuline $item
					}
					incr cnt
				}
				set nuline [join $nuline]
				lappend nuout $nuline
				incr linecnt
			}
			catch {unset mlst}	
			foreach item [$m_list get 0 end] {
				lappend mlst $item
			}
			foreach item $nuout {
				lappend mlst $item
			}
			set linecnt [llength $mlst]
			set mlst [SortMix $linecnt $mlst]
			set mlst [ReverseList $mlst]
			set m_list_restore [LineIndexAtTimeInQikEdit $val]
			set checkdata 2
			break
		}
		if {[string match sort  $action] || [string match expsil $action] \
		||  [string match quant $action] || [string match clear $action]} {
			catch {unset ilist}		
			set n 0 
			foreach item $mlst {
				lappend ilist $n				;# Get indeces of ALL lines
				incr n
			}
		} elseif {![string match tozero $action] && ![string match many $action] && ![string match mgain $action]} {
			set ilist [$m_list curselection]
		}
		if {$action == "syncend"} {
			catch {unset orig_lines}
			foreach line $mlst {
				lappend orig_lines $line
				set line [split $line]
				set kk [llength $line]
				if {$kk <= 0} {							;#	Mark empty lines
					lappend linestore "-"
					continue
				}
				set nn 0		   						;#	Mark blank list entries
				while {$nn < $kk} {
					if {[string length [string trim [lindex $line $nn]]] <= 0} {
						set line [lreplace $line $nn $nn]
						incr kk -1
					} else {
						incr nn
					}
				}
				if {[llength $line] <= 0} {				;#	Mark lines of just empty space
					lappend linestore "-"
					continue
				}										;#	Mark comment lines except for (non-temporary) deletion case

				set this_item [StripCurlies [lindex $line 0]]

				if {[string match ";" [string index $this_item 0]]} {
					lappend linestore "-"
					continue
				}
				if {[llength $line] < 4} {				;#	Mark invalid lines
					lappend linestore "-"
					continue
				}
				lappend linestore $line					;#	Store valid lines
			}
			catch {unset start_times}
			catch {unset nu_start_times}
			catch {unset end_times}
			foreach line $linestore {
				if {[string match $line "-"]} {
					continue
				}
				set start_time [lindex $line 1]
				lappend start_times $start_time
				set thisfnam [lindex $line 0]
				if {![info exists pa($thisfnam,$evv(DUR))]} {
					Inf "Sound $thisfnam Is Not On The Workspace: Cannot Determine Its Duration." 
					return
				}
				lappend end_times [expr $start_time + $pa($thisfnam,$evv(DUR))]
			}
			set max_endtime -1
			foreach etime $end_times {
				if {$etime > $max_endtime} {
					set max_endtime $etime
				}
			}
			set min_start_time 1000000
			foreach start_time $start_times end_time $end_times {
				set move_it [expr $max_endtime - $end_time]
				set nu_start_time [expr $start_time + $move_it]
				if {$nu_start_time < $min_start_time} {
					set min_start_time $nu_start_time
				}
				lappend nu_start_times $nu_start_time
			}
			if {$min_start_time > 0.0} {
				set orig_nu_starttimes $nu_start_times
				unset nu_start_times
				foreach start_time $orig_nu_starttimes {
					set start_time [expr $start_time - $min_start_time]
					if {$start_time < 0.0} {
						set start_time 0.0
					}
					lappend nu_start_times $start_time
				}
			}
			set llen [llength $linestore]
			set nn 0
			set mm 0
			while {$nn < $llen} {
				set line [lindex $linestore $nn]
				if {[string match $line "-"]} {
					set line [lindex $orig_lines $nn]
					set linestore [lreplace $linestore $nn $nn $line]
				} else {
					set nu_start_time [lindex $nu_start_times $mm]
					incr mm
					set line [lreplace $line 1 1 $nu_start_time]
					set linestore [lreplace $linestore $nn $nn $line]
				}
				incr nn
			}
			set mlst $linestore
			break
		}
		set k [llength $ilist]
		if {$k <= 0} {
			Inf "No Items Selected"
			set dont_undo_tempmix 1
			raise .mixdisplay2
			return
		}
		if {$action == "delcom"} {
			foreach i $ilist {
				set line [$m_list get $i]
				if {![string match ";" [string index [lindex $line 0] 0]]} {
					Inf "Line [expr $i + 1] Is Not A Comment Line"
					raise .mixdisplay2
					return
				}
			}
			set ilist [ReverseList $ilist]
			foreach i $ilist {
				set mlst [lreplace $mlst $i $i]
			}
			set checkdata 0
			break
		}
		set n 0 
		while {$n < $k} {
			set line [lindex $mlst [lindex $ilist $n]]	;#	Get each selected line
			set line [split $line]
			set kk [llength $line]
			if {$kk <= 0} {							;#	Reject empty lines
				set ilist [lreplace $ilist $n $n]
				incr k -1
				continue
			}
			set nn 0		   						;#	Remove blank list entries
			while {$nn < $kk} {
				if {[string length [string trim [lindex $line $nn]]] <= 0} {
					set line [lreplace $line $nn $nn]
					incr kk -1
				} else {
					incr nn
				}
			}
			if {[llength $line] <= 0} {				;#	Reject lines of just empty space
				set ilist [lreplace $ilist $n $n]
				incr k -1
				continue
			}										;#	Reject comment lines except for (non-temporary) deletion case

			set this_item [StripCurlies [lindex $line 0]]

			if {[string match ";" [string index $this_item 0]]} {
				if {($action != "unmute") && ($mixval != ">") && ($mixval != "<") && ($mixval != "<>") && ($mixval != "><")} {
					set ilist [lreplace $ilist $n $n]
					incr k -1
					continue
				}
			} else {
				if {$action == "unmute"} {
					set ilist [lreplace $ilist $n $n]
					incr k -1
					continue
				}
			}
			if {[llength $line] < 4} {				;#	Reject invalid lines
				set ilist [lreplace $ilist $n $n]
				incr k -1
				continue
			}
			lappend linestore $line					;#	Store valid lines
			incr n
		}
		if {$action == "mgain"} {
			set zsel $ilist
		} else {
			set zsel [$m_list curselection]
		}
		if {[llength $zsel] <= 0} {
			if {$action == "unmute"} {
				Inf "No Muted Lines Selected"
				raise .mixdisplay2
			} elseif {$action != "clear"} {
				Inf "No Operational Lines Selected"
				raise .mixdisplay2
				return
			}
		} elseif {$action == "unmute"} {
			if {![info exists linestore]} {
				Inf "No Muted Line Selected"
				raise .mixdisplay2
				return
			}
		} elseif {!$istemp} {
			if {$action == "moveto"} {
				ActivateAndMoveMutedLine $zsel $val 0
				return
			} elseif {$action == "move"} {
				ActivateAndMoveMutedLine $zsel $val 1
				return
			} elseif {$action == "move2"} {
				ActivateAndMoveMutedLine $zsel $val -1
				return
			} elseif {$action == "moveto2"} {
				ActivateAndMoveMutedLine $zsel $val -2
				return
			}
		} else {
			if {($action == "moveto") || ($action == "move") || ($action == "move2") || ($action == "moveto2")} {
				if {![info exists linestore]} {
					Inf "To Move Muted Lines, Unset The \"Temporary Change only\" Box"
					raise .mixdisplay2
					return
				}
			}
		}
		if {[string match $action "over"] && ([llength $ilist] <= 1)} {
			Inf "Insufficient Lines Selected."
			raise .mixdisplay2
			return
		}
		if {[string match $action "swap"]} {
			if {[llength $ilist] < 2} {
				Inf "You Need To Select Two Active Mixfile Lines To Do A Swap"
				raise .mixdisplay2
				return
			} elseif {[llength $ilist] > 2} {
				Inf "You Need To Selelct Only Two Mixfile Lines To Do A Swap"
				raise .mixdisplay2
				return
			} 
		}
		set n 0
		if {![info exists linestore]} {
			if {![string match $action "mute"]} {
				Inf "No Active Lines Selected"
			}
			raise .mixdisplay2
			return

		}
		set l_length [llength $linestore]
		set total_line_cnt 0
		foreach item $mlst {
			incr total_line_cnt
		}

		# CHECK FOR VALID PARAMETERS (where necessary, in relation to lines to be processed)

		switch -- $action {
			"posspr" {
				if {![IsNumeric $val] || $val < -1.0 || $val > 1.0} {
					Inf "Invalid Spatial Spread Value ($val) Entered (-1 = Max Squeeze, 1 = Max Stretch)"
					raise .mixdisplay2
					return
				}
			}
			"posset" {
				if {[IsNumeric $val]} {
					if {$val < -1.0 || $val > 1.0} {
						Inf "Invalid Spatial Position Value ($val) Entered (-1 Is Full Left : 1 Is Full Right)"
						raise .mixdisplay2
						return
					}
				} else {
					if {([string match "l" $val] || [string match "r" $val] || [string match "c" $val])} {
						set val [string toupper $val]
						set mixval $val
					}
					if {!([string match "L" $val] || [string match "R" $val] || [string match "C" $val])} {
						Inf "Invalid Spatial Position Value Entered (Range -1 to 1 : or 'L', 'R', 'C')"
						raise .mixdisplay2
						return
					}
				}
			}
			"poscat" {
				if {![IsNumeric $val] || $val <= 0.0 || $val > 1.0} {
					Inf "Invalid Spatialisation Value ($val) Entered (>0-1)"
					raise .mixdisplay2
					return
				}
			}
			"posrot" {
				if {![regexp {^[0-9\-]+$} $val] || ![IsNumeric $val] || ($val == 0)} {
					Inf "Invalid Rotation Value ($val) Entered"
					raise .mixdisplay2
					return
				}
			}
			"scatw" -
			"scatt" {
				if {[string match scatt $action]} {
					if {![IsNumeric $val] || $val <= 0.0 || $val > 1.0} {
						Inf "Invalid Time Randomisation ($val) Entered (>0-1)"
						raise .mixdisplay2
						return
					}
				} elseif {![IsNumeric $val] || $val <= 0.0} {
					Inf "Invalid Time Randomisation ($val) Entered (Greater Than Zero)"
					raise .mixdisplay2
					return
				}
				set zz [GetLocalTimeGaps $linestore	$ilist $total_line_cnt $mlst]
				if {[string match "0" $zz]} {
					Inf "Times Are Not All In Ascending Order : Cannot Proceed"
					raise .mixdisplay2
					return
				}
				set timegaps_below [lindex $zz 0]
				set timegaps_above [lindex $zz 1]
			}
			"retrot" {
				set timegaps [GetTimegaps $linestore $l_length]
				if [string match "0" $timegaps] {
					return
				}
			}
			"quant" {
				if {![IsNumeric $val] || $val <= 0.0} {
					Inf "Invalid Quantisation Value ($val) Entered"
					raise .mixdisplay2
					return
				}
			}
			"mgain" {
				if {([string length $prm(2)] <= 0) || ![IsNumeric $prm(2)] || ($prm(2) > $hi(2)) || ($prm(2) < $lo(2))} {
					Inf "Invalid Or Out Of Range Gain Value On Mix Page"
					raise .mixdisplay2
					return
				}
				set nuval $prm(2)
				set n 0
				while {$n < $l_length} {			;#	Check gain vals in lines, if ness convert from dB
					set lineno [expr [lindex $ilist $n] + 1]
					set line [lindex $linestore $n]
					if {$mm_multichan} {
						set linelen [llength $line]
						set gainloc 4
						while {$gainloc < $linelen} {
							set gain [lindex $line $gainloc]
							set newgain [CheckGainVal $gain $lineno 1]
							if {$newgain < 0.0} {
								return
							}
							incr gainloc 2
						}
					} else {
						set gain [lindex $line 3]
						set newgain [CheckGainVal $gain $lineno 1]
						if {$newgain < 0.0} {
							return
						}
						if {[llength $line] == 7} {
							set gain [lindex $line 5]
							set newgain [CheckGainVal $gain $lineno 1]
							if {$newgain < 0.0} {
								return
							}
						}
					}
					incr n
				}
				set val    $prm(2)
				set mixval $prm(2)
				set action "gain"
				set is_mgain 1
			}
			"gain" {
				set nuval [IsGainVal $val]
				if {[string length $nuval] <= 0} {
					Inf "Invalid Amplification Value ($val) Entered"
					raise .mixdisplay2
					return
				} elseif {[string first ":" $nuval] > 0} {
					set action gainchan
					set n 0
					while {$n < $l_length} {			;#	Check gain vals in lines, if ness convert from dB
						set line [lindex $linestore $n]
						if {[lsearch $line $nuval] < 0} {
							Inf "(Some Of) Selected Lines Do Not Use The Specified Routing"
							return
						}
						incr n
					}
				} else {
					set val $nuval
					set n 0
					while {$n < $l_length} {			;#	Check gain vals in lines, if ness convert from dB
						set lineno [expr [lindex $ilist $n] + 1]
						set line [lindex $linestore $n]
						if {$mm_multichan} {
							set linelen [llength $line]
							set gainloc 4
							while {$gainloc < $linelen} {
								set gain [lindex $line $gainloc]
								set newgain [CheckGainVal $gain $lineno 1]
								if {$newgain < 0.0} {
									return
								}
								incr gainloc 2
							}
						} else {
							set gain [lindex $line 3]
							set newgain [CheckGainVal $gain $lineno 1]
							if {$newgain < 0.0} {
								return
							}
							if {[llength $line] == 7} {
								set gain [lindex $line 5]
								set newgain [CheckGainVal $gain $lineno 1]
								if {$newgain < 0.0} {
									return
								}
							}
						}
						incr n
					}
				}
			}
			"expand" -
			"expandy" {
				if {![IsNumeric $val] || ($val < 0.0)} {
					Inf "Invalid Stretch Value ($val) Entered"
					raise .mixdisplay2
					return
				}
			}
			"stepset" {
				if {![IsNumeric $val] || ($val < 0.0)} {
					Inf "Invalid Step Value ($val) Entered"
					raise .mixdisplay2
					return
				}
			}
			"stagger" {
				if {![IsNumeric $val] || [Flteq $val 0.0]} {
					Inf "Invalid Or Zero Stagger Value ($val) Entered"
					raise .mixdisplay2
					return
				}
			}
			"moveto" {
				if {[string match [string tolower [string index $val end]] "b"]} {
					set mmmlen [string length $val]
					if {$mmmlen < 2} {
						Inf "Invalid timestep value entered"
						raise .mixdisplay2
						return
					}
					set selectlen [llength [$m_list curselection]] 			
					incr mmmlen -2
					set mmixval [string range $val 0 $mmmlen]
					if {![regexp {^[0-9]+$} $mmixval] || ![IsNumeric $mmixval] || ($mmixval == 0)} {
						Inf "Invalid number of beats entered (must be an integer > 0)"
						raise .mixdisplay2
						return
					}
					set qstep [FindQuantisationDuration]
					if {$qstep <= 0.0} {
						raise .mixdisplay2
						return
					}
					set val [expr $mmixval * $qstep]
				} else {
					set selectlen [llength [$m_list curselection]] 
					if {![IsNumeric $val] || ($val < 0.0)} {
						Inf "Invalid time value ($val) entered"
						raise .mixdisplay2
						return
					}
				}
				if {$selectlen != [llength $linestore]}  {
					set msg "To move both muted & unmuted lines, unset the \"Temporary Change Only\" box\n\n"
					append msg "Move ~only~ the unmuted lines ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						raise .mixdisplay2
						return
					}
				}
				if {($l_length > 1) && ([llength $mlst] >= $evv(QIKEDITLEN))} {
					set msg "Move $l_length lines"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						raise .mixdisplay2
						return
					}
				}
			}
			"moveto2" {
				if {![IsNumeric $val] || ($val < 0.0)} {
					Inf "Invalid Time Value ($val) Entered"
					raise .mixdisplay2
					return
				}
				if {[llength [$m_list curselection]] != [llength $linestore]}  {
					set msg "To Move Both Muted & Unmuted Lines, Unset The \"Temporary Change only\" Box\n\n"
					append msg "Move ~ONLY~ The Unmuted Lines ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						raise .mixdisplay2
						return
					}
				}
				if {($l_length > 1) && ([llength $mlst] >= $evv(QIKEDITLEN))} {
					set msg "Move $l_length Lines"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						raise .mixdisplay2
						return
					}
				}
				set tstart [lindex [lindex $linestore 0] 1]
			}
			"over" {
				if {![IsNumeric $val]} {
					Inf "Invalid Time Value ($val) Entered (Must Be Numeric)"
					raise .mixdisplay2
					return
				}
			}
			"move" -
			"move2" {
				if {![IsNumeric $val]} {
					Inf "Invalid Time Shift ($val) Entered"
					raise .mixdisplay2
					return
				}
				if {($l_length > 1) && ([llength $mlst] >= $evv(QIKEDITLEN))} {
					set msg "Move $l_length Lines"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						raise .mixdisplay2
						return
					}
				}
				if {$action == "move2"} {
					set val [expr -$val]
				}
				if {$val < 0.0} {
					set n 0
					while {$n < $l_length} {	;#	Check no existing time is moved to less than zero
						set lineno [expr [lindex $ilist $n] + 1]
						set line [lindex $linestore $n]
						set time [lindex $line 1]
						if {![IsNumeric $time]} {
							Inf "Invalid Time Value $time At Line $lineno" 
							raise .mixdisplay2
							return
						}
						if {$time + $val < 0.0} {
							Inf "Cannot Move Time $time At Line $lineno By $val"
							raise .mixdisplay2
							return
						}
						incr n
					}
				}
				if {[llength [$m_list curselection]] != [llength $linestore]}  {
					set msg "To Move Both Muted & Unmuted Lines, Unset The \"Temporary Change only\" Box\n\n"
					append msg "Move ~ONLY~ The Unmuted Lines ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						raise .mixdisplay2
						return
					}
				}
			}
			"gainset" {
				set testval [IsGainVal $val]
				if {[string first ":" $testval] > 0} {
					set action gainsetchan
					set n 0
					while {$n < $l_length} {			;#	Check gain vals in lines, if ness convert from dB
						set line [lindex $linestore $n]
						if {[lsearch $line $testval] < 0} {
							Inf "(Some Of) Selected Lines Do Not Use The Specified Routing"
							return
						}
						incr n
					}
				} elseif {[string length $testval] <= 0} {
					Inf "Invalid Gain Value ($val) Entered"
					raise .mixdisplay2
					return
				}
			}
			"gainstp" {
				if {[llength $linestore] < 2} {
					Inf "This Option Only Works With More Than 1 Line"
					raise .mixdisplay2
					return
				}
				if {![IsNumeric $val] || ($val <= 0.0)} {
					Inf "Invalid Gain-Step Value ($val) Entered"
					raise .mixdisplay2
					return
				}
				set knt 0
				foreach line $linestore {
					if {$knt == 0} {
						set len [llength $line]
					} else {
						if {[llength $line] != $len} {
							Inf "All Lines Must Have Same Number Of Entries For This Option"
							return
						}
					}
					incr knt
				}
				set zstep [llength $linestore]
				incr zstep -1
				catch {unset gain_ztep}
				set line [lindex $linestore 0]
				set linelen [llength $line]
				if {$mm_multichan} {
					set gainloc 4
					while {$gainloc < $linelen} {
						lappend gain_ztep [lindex $line $gainloc]
						incr gainloc 2
					}
				} else {
					set gain_ztep [lindex $line 3]
					if {[llength $line] == 7} {
						lappend gain_ztep [lindex $line 5]					
					}
				}
			}
			"vector" {
				catch {unset vec_tor}
				if {![file exists $val]} {
					Inf "Invalid Amplitude Vector File"
					raise .mixdisplay2
					return
				}
				if [catch {open $val "r"} zit] {
					Inf "Cannot Open Amplitude Vector File"
					raise .mixdisplay2
					return
				}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					if {![IsNumeric $line]} {
						Inf "Invalid Value ($line) In Amplitude Vector File"
						close $zit
						raise .mixdisplay2
						return
					}
					lappend vec_tor $line
				}
				close $zit
				if {![info exists vec_tor]} {
					Inf "No Data In Amplitude Vector File"
					raise .mixdisplay2
					return
				}
				set veclen [llength $vec_tor]
				if {[llength $linestore] != $veclen} {
					Inf "Number Of Selected Lines Does Not Correspond To Number Of Entries In Vector File"
					raise .mixdisplay2
					return
				}
				set vec_tor [ReverseList $vec_tor]	;#	Lines are updated in reverse order
			}
			"lastfile" -
			"file" -
			"every" {
				if {![file exists $val]} {
					Inf "File $val Does Not Exist"
					raise .mixdisplay2
					return
				}
				if {![info exists pa($val,$evv(FTYP))]} {
					Inf "File $val Is Not On The Workspace"
					raise .mixdisplay2
					return
				}
				set line [lindex $linestore 0]
				set chans [lindex $line 2]
				set newchans $pa($val,$evv(CHANS))
				if {($newchans < $chans) && ([llength $line] == 7)} {
					if {![Flteq [lindex $line 3] [lindex $line 5]]} {
						Inf "Cannot Replace Stereo File '[lindex $line 0]' By Mono File '$val', In This Case"
						raise .mixdisplay2
						return
					}
				}
			}
			"many" {
				if {![file exists $val]} {
					Inf "File '$val' Does Not Exist"
					raise .mixdisplay2
					return
				}
				if {![info exists pa($val,$evv(FTYP))]} {
					Inf "File '$val' Is Not On The Workspace"
					raise .mixdisplay2
					return
				}
			}
			"expsil" {
				if {![IsNumeric $val] || ($val < 0.0)} {
					Inf "Invalid Time Value ($val) Entered"
					raise .mixdisplay2
					return
				}
			}
			"reroute" {
				set inlinecnt 1
				set ambiguous 0
				catch {unset routinfos}
				if {([string first "-" $val] == 0) && ![string match -nocase "r" [string index $val end]]} {
					append val "R"	;#	convert e.g. -2 to -2R
				}
				if {($val == "LR") || ($val == "LRC0") || ($val == "I")} {
					if {($mix_outchans < 4) || ![IsEven $mix_outchans]} {
						Inf "This Option Only Works For Output Mixes With Even Numbers Of Channels, Greater Than 2"
						raise .mixdisplay2
						return
					}
					if {[llength $linestore] == 1} {
						set line0 [lindex $linestore 0]
						set zzfnam0 [lindex $line0 0]
						if {$pa($zzfnam0,$evv(CHANS)) != 2} {
							Inf "Single Chosen File Must Be Stereo For This Option"
							raise .mixdisplay2
							return
						}
						set zzstereo 1
					} elseif {[llength $linestore] == 2} {
						set line0 [lindex $linestore 0]
						set line1 [lindex $linestore 1]
						set zzfnam0 [lindex $line0 0]
						set zzfnam1 [lindex $line1 0]
						if {$val == "I"} {
							if {($pa($zzfnam0,$evv(CHANS)) > 2) || ($pa($zzfnam0,$evv(CHANS)) != $pa($zzfnam1,$evv(CHANS)))} {
								Inf "Both Files Must Be Mono Or Both Stereo For This Option"
								raise .mixdisplay2
								return
							}
							if {$pa($zzfnam0,$evv(CHANS)) == 2} {
								set zzstereo 2
							}
						} elseif {($pa($zzfnam0,$evv(CHANS)) != 1) || ($pa($zzfnam1,$evv(CHANS)) != 1)} {
							Inf "Two Chosen Files Must Be Mono For This Option"
							raise .mixdisplay2
							return
						} else {
							set zzstereo 0
						}
					} else {
						Inf "Chose One Stereo Or Two Mono Lines From The Mix"
						raise .mixdisplay2
						return
					}
					switch -- $val {
						"LR" -
						"LRC0" {
							set kk 1
							if {$val == "LRC0"} {
								incr kk
							}
							set routinfo {}
							while {$kk <= [expr $mix_outchans/2]} {
								set rout 1:
								append rout $kk
								lappend routinfo $rout 1.0
								incr kk
							}
							if {$val == "LRC0"} {
								incr kk
							}
							if {$zzstereo} {
								while {$kk <= $mix_outchans} {
									set rout 2:
									append rout $kk
									lappend routinfo $rout 1.0
									incr kk
								}
								set routinfos [list $routinfo]
							} else {
								set routinfos [list $routinfo]
								set routinfo {}
								while {$kk <= $mix_outchans} {
									set rout 2:
									append rout $kk
									lappend routinfo $rout 1.0
									incr kk
								}
								lappend routinfos $routinfo
								set routinfos [ReverseList $routinfos]
							}				
						}
						"I" {
							set kk 1
							set routinfo {}
							if {$zzstereo == 2} {
								set routinfo2 {}
								set inchan 1
								set thisrout routinfo
								while {$kk <= $mix_outchans} {
									set rout $inchan
									append rout :$kk
									if {$thisrout == "routinfo"} {
										lappend routinfo $rout 1.0
										set thisrout routinfo2
									} else {
										lappend routinfo2 $rout 1.0
										set thisrout routinfo
										incr inchan
										if {$inchan > 2} {
											set inchan 1
										}
									}
									incr kk
								}
								set routinfos [list $routinfo2 $routinfo]
							} else {
								while {$kk <= $mix_outchans} {
									set rout 1:
									append rout $kk
									lappend routinfo $rout 1.0
									incr kk 2
								}
								if {$zzstereo} {
									set kk 2
									while {$kk <= $mix_outchans} {
										set rout 2:
										append rout $kk
										lappend routinfo $rout 1.0
										incr kk 2
									}
									set routinfos [list $routinfo]
								} else {
									set routinfos [list $routinfo]
									set routinfo {}
									set kk 2
									while {$kk <= $mix_outchans} {
										set rout 2:
										append rout $kk
										lappend routinfo $rout 1.0
										incr kk 2
									}
									lappend routinfos $routinfo
									set routinfos [ReverseList $routinfos]
								}				
							}
						}
					}
				} elseif {$val == "SQ"} {
					if {($mix_outchans < 4) || ([expr $mix_outchans % 4] != 0)} {
						Inf "This Option Only Works For Output Mixes With Multiples Of 4 Channels"
						raise .mixdisplay2
						return
					}
					set gpsz [expr $mix_outchans / 4]
					if {[llength $linestore] != 2} {
						Inf "CHOOSE TWO STEREO LINES FROM THE MIX"
						raise .mixdisplay2
						return
					}
					set line0 [lindex $linestore 0]
					set line1 [lindex $linestore 1]
					set zzfnam0 [lindex $line0 0]
					set zzfnam1 [lindex $line1 0]
					if {($pa($zzfnam0,$evv(CHANS)) != 2) || ($pa($zzfnam1,$evv(CHANS)) != 2)} {
						Inf "Two Chosen Files Must Be Stereo For This Option"
						raise .mixdisplay2
						return
					}
					set routinfos {}
					set routinfo {}
					set gplim $gpsz
					set inchan 1
					set kk 1
					while {$kk <= $mix_outchans} {
						set rout $inchan
						append rout ":" $kk
						lappend routinfo $rout 1.0
						if {$kk >= $gplim} {
							incr inchan
							if {$inchan > 2} {
								lappend routinfos $routinfo
								set routinfo {}
								set inchan 1
							}
							incr gplim $gpsz
						}
						incr kk
					}
					set routinfos [ReverseList $routinfos]
				} elseif {($val == ">") || ($val == "<") || ($val == "<>") || ($val == "><")} {
					if {[llength $linestore] != 2} {
						Inf "Select Two Mix Lines"
						return {}
					}
					set line0 [lindex $linestore 0]
					set line1 [lindex $linestore 1]
					set this_chans [lindex $line0 2]
					if {![IsNumeric $this_chans]} {
						Inf "Don't Select Comment Lines"
						return {}
					}
					set that_chans [lindex $line1 2]
					if {![IsNumeric $that_chans]} {
						Inf "Don't Select Comment Lines"
						return {}
					}
					set routinfo0 [lrange $line0 3 end]
					set routinfo1 [lrange $line1 3 end]
					set do_out_by_chans 1
					if {$this_chans != $that_chans} {
						if {[llength $routinfo0] != [llength $routinfo1]} {
							Inf "Select Two Active Mix Lines With\nThe Same Number Of Input Channels\nOr The Same Number Of Output Routes"
							return {}
						} else {
							set do_out_by_chans 0
						}
					}
					if {([llength $routinfo0] == [llength $routinfo1]) && ($this_chans == $that_chans)} {
						set swap_inrouts 0
						set swap_outrouts 0
						foreach {rout0 lev0} $routinfo0 {rout1 lev1} $routinfo1 {
							set rout0 [split $rout0 ":"]
							lappend inrouts0  [lindex $rout0 0]
							lappend outrouts0 [lindex $rout0 1]
							set rout1 [split $rout1 ":"]
							lappend inrouts1  [lindex $rout1 0]
							lappend outrouts1 [lindex $rout1 1]
						}
						foreach r0 $inrouts0 r1 $inrouts1 {
							if {$r0 != $r1} {
								set swap_inrouts 1
								break
							}
						}
						foreach r0 $outrouts0 r1 $outrouts1 {
							if {$r0 != $r1} {
								set swap_outrouts 1
								break
							}
						}
						if {$swap_inrouts && $swap_outrouts} {
							set msg "AMBIGUOUS AT TO WHETHER TO USE INPUT CHANNEL ASSIGNMENT, OR OUTPUT ROUTE ASSIGNMENT.\n\n"
							append msg "USE INPUT CHANNEL ASSIGNMENT ??"
							set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
							if {$choice == "no"} {
								set do_out_by_chans 0
							}
						}
					}
					if {$do_out_by_chans} {
						if {$val == ">"} {
							set routinfo [lrange $line0 3 end]
							set linestore [list [lindex $linestore 1]]
							set ilist [lindex $ilist 1]
						} elseif {$val == "<"} {
							set routinfo [lrange $line1 3 end]
							set linestore [list [lindex $linestore 0]]
							set ilist [lindex $ilist 0]
						} else {
							set routinfo [lrange $line0 3 end]
							lappend routinfos $routinfo
							set routinfo [lrange $line1 3 end]
						}
					} else {
						foreach {rout lev} $routinfo0 {
							set rout [split $rout ":"]
							lappend routes0 [lindex $rout 1]
						}
						foreach {rout lev} $routinfo1 {
							set rout [split $rout ":"]
							lappend routes1 [lindex $rout 1]
						}
						if {$val == ">"} {
							foreach {rout lev} $routinfo1 nuout $routes0 {
								set rout [split $rout ":"]
								set rout [lreplace $rout 1 1 $nuout]
								set rout [join $rout ":"]
								lappend nu_rout $rout $lev
							}
							set routinfo $nu_rout
							set linestore [list [lindex $linestore 1]]
							set ilist [lindex $ilist 1]
						} elseif {$val == "<"} {
							foreach {rout lev} $routinfo0 nuout $routes1 {
								set rout [split $rout ":"]
								set rout [lreplace $rout 1 1 $nuout]
								set rout [join $rout ":"]
								lappend nu_rout $rout $lev
							}
							set routinfo $nu_rout
							set linestore [list [lindex $linestore 0]]
							set ilist [lindex $ilist 0]
						} else {
							foreach {rout lev} $routinfo1 nuout $routes0 {
								set rout [split $rout ":"]
								set rout [lreplace $rout 1 1 $nuout]
								set rout [join $rout ":"]
								lappend nu_rout $rout $lev
							}
							set routinfo $nu_rout
							lappend routinfos $routinfo
							unset nu_rout
							foreach {rout lev} $routinfo0 nuout $routes1 {
								set rout [split $rout ":"]
								set rout [lreplace $rout 1 1 $nuout]
								set rout [join $rout ":"]
								lappend nu_rout $rout $lev
							}
							set routinfo $nu_rout
						}
					}
					lappend routinfos $routinfo
				} elseif {[string first "remap" [string tolower $val]] == 0} {
					set routinfos [RemapRouting $linestore $val]
					if {[llength $routinfos] <= 0} {
						raise .mixdisplay2
						return
					}
					set routinfos [ReverseList $routinfos]
				} elseif {[string first "+" $val] == 0} {
					set routinfos [TurnRouting $linestore $val]
					if {[llength $routinfos] <= 0} {
						raise .mixdisplay2
						return
					}
				} else {
					foreach line $linestore {
						set inchan [lindex $line 2]
						set routinfo [IsValidRouteString $val $inchan $line $inlinecnt]
						if {[llength $routinfo] <= 0} {
							raise .mixdisplay2
							return
						}
						lappend routinfos $routinfo
						incr inlinecnt
					}
					set routinfos [ReverseList $routinfos]
				}
			}
			"right" - 
			"up" {
				set val 0.1
			}
			"left"  - 
			"down" {
				set val -0.1
				foreach index $ilist line $linestore {
					switch -- $action {
						"down" {
							set gain [lindex $line 3]
							set gain [expr $gain + $val]
							if {$gain <= 0.0} {
								Inf "Cannot Set A Gain At Or Below Zero"
								return
							}
							if {[llength $line] == 7} {
								set gain [lindex $line 5]
								set gain [expr $gain + $val]
								if {$gain <= 0.0} {
									Inf "Cannot Set A Gain At Or Below Zero"
									return
								}
							}
						}
						"left" {
							set time [lindex $line 1]
 							set time [expr $time + $val]
							if {$time < 0.0} {
								Inf "Cannot Set A Time Below Zero"
								return
							}
						}
					}
				}
			}
			"lineup" {
				if {![IsNumeric $val] || $val < 0.0} {
					Inf "Synchronisation Time Invalid"
					raise .mixdisplay2
					return
				}
			}
			"syncup" {
				if {[llength $linestore] != 2} {
					Inf "Choose a pair of lines: to sync 2nd to 1st. Reverse Order if necessary"
					raise .mixdisplay2
					return
				}
			}
			"offmark" {
				if {[llength $linestore] != 2} {
					Inf "Choose A Pair Of Lines: To Offset 2nd From 1st. Reverse Order If Necessary."
					raise .mixdisplay2
					return
				}
				if {![IsNumeric $mixval]} {
					Inf "Offseting Time (In Value Box) Invalid"
					raise .mixdisplay2
					return
				}
			}
			"twist" {
				catch {unset qiktwist}
				MixTwist
				if {![info exists qiktwist]} {
					raise .mixdisplay2
					return
				}
			}
			"wiggle" {
				catch {unset qikpperm}
				ChangeAsPattern 
				if {![info exists qikpperm]} {
					raise .mixdisplay2
					return
				}
			}
		}
		if {[string match pos* $action]} {

			# CONVERT POSITION MNEMONICS TO NUMERIC VALUES

			set n 0 
			foreach line $linestore {
				if {[llength $line] > 4} {
					if {[string match "L" [lindex $line 4]]} {
						set line [lreplace $line 4 4 -1.0]
						set	linestore [lreplace $linestore $n $n $line]
					} elseif {[string match "R" [lindex $line 4]]} {
						set line [lreplace $line 4 4 1.0]
						set	linestore [lreplace $linestore $n $n $line]
					} elseif {[string match "C" [lindex $line 4]]} {
						set line [lreplace $line 4 4 0.0]
						set	linestore [lreplace $linestore $n $n $line]
					}
				}
				if {[llength $line] > 6} {
					if {[string match "L" [lindex $line 6]]} {
						set line [lreplace $line 6 6 -1.0]
						set	linestore [lreplace $linestore $n $n $line]
					} elseif {[string match "R" [lindex $line 6]]} {
						set line [lreplace $line 6 6 1.0]
						set	linestore [lreplace $linestore $n $n $line]
					} elseif {[string match "C" [lindex $line 6]]} {
						set line [lreplace $line 6 6 0.0]
						set	linestore [lreplace $linestore $n $n $line]
					}
				}
				incr n
			}
		}
		if [string match "wiggle" $action] {
			set permlen [llength $qikpperm]
			set lllen [llength $linestore]
			set bas 0
			set nnn 0
			set mmm 0
			catch {unset nulines}
			while {$nnn < $lllen} {
				set kkk [expr $bas + [lindex $qikpperm $mmm]]
				set oodlin [lindex $linestore $nnn]
				set nuline [lindex $linestore $kkk]
				set thisnd [lindex $nuline 0]
				set nuline [lreplace $oodlin 0 0 $thisnd]
				lappend nulines $nuline
				incr mmm
				if {$mmm >= $permlen} {
					set mmm 0
					incr bas $permlen
				}
				incr nnn
			}
			set linestore $nulines
			set mlst $linestore
			set checkdata 0
			break
		}
		if [string match "twist" $action] {
			set twist [lindex $qiktwist 0]
			set thistwist 0
			set step  [lindex $qiktwist 1]
			set thisstep 0
			set kkk 0
			set twist_origs $linestore
			foreach line $linestore {
				set len [llength $line]
				set nnn 3
				while {$nnn < $len} {
					set rout [lindex $line $nnn]
					set rout [split $rout ":"]
					set inch [lindex $rout 0]
					set ouch [lindex $rout 1]
					incr ouch $thistwist
					while {$ouch > $mix_outchans} {
						incr ouch -$mix_outchans
					}
					set rout $inch
					append rout ":" $ouch
					set line [lreplace $line $nnn $nnn $rout]
					incr nnn 2
				}
				set linestore [lreplace $linestore $kkk $kkk $line]
				incr thisstep
				if {$thisstep >= $step} {
					set thisstep 0
					incr thistwist $twist
					while {$thistwist > $mix_outchans} { 
						incr thistwist -$mix_outchans
					}
				}
				incr kkk
			}
			set m_cnt 0
			foreach line $mlst {
				set t_cnt 0
				foreach tline $twist_origs {
					if [string match $tline $line] {
						set mlst [lreplace $mlst $m_cnt $m_cnt [lindex $linestore $t_cnt]]
						break
					}
					incr t_cnt
				}
				incr m_cnt
			}
			set checkdata 0
			break
		}
		if [string match "clear" $action] {
			set msg "Delete All Muted Lines ??"
			set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "no"} {
				return
			}
			set mlst $linestore
			set checkdata 0
			break
		}
		set ilist [lsort -integer -decreasing $ilist]	;#	Due to possible line insertion, work in reverse order
		set k [llength $linestore]						;#	And invert linestor list
		while {$k > 0} {
			incr k -1
			lappend zzz [lindex $linestore $k]
		}
		set linestore $zzz
		if {$action == "etoe"} {						;# Must work in increasing order, to sum file durs...
			set non_op_lines {}
			set cnt 0									;# First check where comment lines are
			foreach line $mlst {
				if {[string match [string index [lindex $line 0] 0] ";"]} {
					lappend non_op_lines $cnt
				}
				incr cnt
			}
			set ilist [ReverseList $ilist]
			set linestore [ReverseList $linestore]
			if {([llength $ilist] < 2) || ![ConsecutiveLines $ilist $non_op_lines]} {
				Inf "This Option Only Works With 2 Or More Consecutive Lines"
				raise .mixdisplay2
				return
			}
			foreach line $linestore {
				if {![info exists etoe_start]} {
					set etoe_start [lindex $line 1] 
					lappend fend $etoe_start
				} else {
					set etoe_start [expr $etoe_start + $dur]
					lappend fend $etoe_start
				}
				set fnam [lindex $line 0] 
				if {![info exists pa($fnam,$evv(DUR))]} {
					Inf "File $fnam Is Not On The Workspace: Cannot Determine It's Duration"
					raise .mixdisplay2
					return
				}
				set dur $pa($fnam,$evv(DUR))
			}
			set fend [ReverseList $fend]
			set ilist [ReverseList $ilist]
			set linestore [ReverseList $linestore]

		} elseif {$action == "stepset"} {

			set linestore [ReverseList $linestore]
			set line [lindex $linestore 0]
			set firsttime [lindex $line 1]
			set nn 0
			set len [llength $linestore]
			while {$nn < $len} {
				set line [lindex $linestore $nn]
				set line [lreplace $line 1 1 $firsttime]
				set linestore [lreplace $linestore $nn $nn $line]
				set firsttime [expr $firsttime + $val]
				incr nn
			}
			set linestore [ReverseList $linestore]
		} elseif {$action == "stagger"} {
			set nulinestore [ReverseList $linestore]
			set thisstagger 0
			set stagger $val
			set nn 0
			set len [llength $nulinestore]
			while {$nn < $len} {
				set thisstagger [expr $thisstagger + $stagger]
				set line [lindex $nulinestore $nn]
				set thistime [lindex $line 1]
				set nutime [expr $thistime + $thisstagger]
				if {$nutime < 0.0} {
					Inf "Stagger ($val) Impossible With Selected Lines"
					raise .mixdisplay2
					return
				}
				set line [lreplace $line 1 1 $nutime]
				set nulinestore [lreplace $nulinestore $nn $nn $line]
				incr nn
			}
			set linestore [ReverseList $nulinestore]
		}
		if {[string match swap $action]} {
			set line0 [lindex $linestore 0]
			set index0 [lindex $ilist 0]
			set time0 [lindex $line0 1]
			set line1 [lindex $linestore 1]
			set index1 [lindex $ilist 1]
			set time1 [lindex $line1 1]
			set line0 [lreplace $line0 1 1 $time1]				;# swap times
			set line1 [lreplace $line1 1 1 $time0]
			set mlst [lreplace $mlst $index0 $index0 $line1]	;# swap lines
			set mlst [lreplace $mlst $index1 $index1 $line0]
			set checkdata 2
			break
		} 
		if {[string match scatf $action] || [string match scatn $action] || [string match retro* $action] \
		||  [string match sort  $action] || [string match quant  $action]} {
			set line_cnt [llength $ilist]
			switch -- $action {
				"scatf" {
					set linestore [RandomiseFilenamesWithRoutes $linestore $line_cnt]
					set checkdata 2
				}
				"scatn" {
					set linestore [RandomiseFilenames $linestore $line_cnt]
					set checkdata 2
				}
				"retrof" {
					set linestore [RetroFilenames $linestore $line_cnt]
					set checkdata 2
				}
				"retrot" {
					set n [expr $line_cnt -1]
					set m $n
					set time 0.0
					set k 0
					while {$k < $m} {
						if {$k < $m} {
							set nexttime [expr $time + [lindex $timegaps $k]]
						}
						set line [lindex $linestore $n]
						set line [lreplace $line 1 1 $time]
						set linestore [lreplace $linestore $n $n $line]
						set time $nexttime
						incr n -1
						incr k
					}
					set linestore [SortMix $line_cnt $linestore]
					set checkdata 2
				}
				"sort" {
					set linestore [SortMix $line_cnt $linestore]
					set checkdata 0
				}
				"quant" {
					set linestore [QuantiseMix $line_cnt $linestore $val]
					set checkdata 2
				}
			}
			foreach index $ilist line $linestore {
				set mlst [lreplace $mlst $index $index $line]
			}
			break
		}
		set cnt 0
		if {[string match over $action]} {
			set k [llength $linestore]
			set overcnt $k
			incr k -2
			set linestore [lrange $linestore 0 $k]
			set ilist [lrange $ilist 0 $k]
			set origval $val
			incr overcnt -1
			set val [expr $val * $overcnt]
		} elseif {[string match expsil $action]} {
			foreach line $linestore {
				set ffnam [lindex $line 0]
				if {![info exists pa($ffnam,$evv(DUR))]} {
					Inf "File '$ffnam' Is Not On The Workspace.\nDuration Unknown.\n\nTherefore Cannot Find Silences."	
					raise .mixdisplay2
					return
				}
				set start [lindex $line 1]
				lappend expsil_stts $start
				lappend expsil_ends [expr $pa($ffnam,$evv(DUR)) + $start]
			}
			set cnt 0
			foreach ending $expsil_ends  {
				set cnt2 0
				catch {unset mingap}
				set OK 1
				foreach start2 $expsil_stts ending2 $expsil_ends  {
					if {$cnt != $cnt2} {
						if {$ending >= $ending2} {
							continue
						}
						set gap [expr $start2 - $ending]
						if {![info exists mingap]} {
							set mingap $gap
							set silstart $ending
						} elseif {$gap < $mingap} {
							set mingap $gap
							set silstart $ending
						}
					}
					incr cnt2 
				}
				if {[info exists mingap] && ($mingap > 0)} {
					lappend silences $silstart $mingap
				}
				incr cnt
			}
			if {![info exists silences]} {
				Inf "No Silences Found (There May Be Silences Inside The Soundfiles)"
				raise .mixdisplay2
				return
			}
		}
		if {$action == "expandy"} {
			set line [lindex $linestore end]
			set lasttime [lindex $line 1]
		}
		set z_cnt [llength $linestore]
		incr z_cnt -1
		if {$action == "poscat" } {
			set offcentre 0
			foreach index $ilist line $linestore {
				set linelen [llength $line]
				if {$linelen == 4} {
					set ch_ans [lindex $line 2]
					if {$ch_ans > 1} {
						set offcentre 1	;#	STEREO FILES WITH NO CHANNEL INFO, CANNOT KNOW IF THEY ARE ALL PANNED TO CENTRE, SO ASSUME NOT
						break
					}
				} else {
					if {$linelen >= 5} {
						set position [lindex $line 4]
						if {($position != 0.0) && ($position != "C")} {
							set offcentre 1
							break
						}
					}
					if {$linelen == 7} {
						set position [lindex $line 6]
						if {($position != 0.0) && ($position != "C")} {
							set offcentre 1
							break
						}
					}
				}
			}
			if {!$offcentre} {
				Inf "All Sounds At Centre : Scattering Over Range $val"
				set action poscat2
				set repos2 1
			}
		} elseif {$action == "pozcat"} {
			set zxq 0
			foreach line $linestore {
				if {$zxq == 0} {
					set ch_ans [lindex $line 2]
				} else {
					if {$ch_ans != [lindex $line 2]} {
						Inf "Not All Sounds Have Same Chanel Count: Cannot Scatter Positions"
						return
					}
				}
				incr zxq
			}
			foreach line $linestore {
				set spacey [lrange $line 3 end]
				lappend spaceys $spacey
			}
			set xpermlen [llength $spaceys]
			set xn 0
			set xn_plus_1 1
			set xendindex -1
			set xseqperm {}
			while {$xn < $xpermlen} {
				set xt [expr int(floor(rand() * $xn_plus_1))]
				if {$xt==$xn} {
					set xq [concat $xn $xseqperm]
					set xseqperm $xq
				} else {
					incr xt
					if {$xt > $xendindex} {
						lappend xseqperm $xn
					} else {
						set xseqperm [linsert $xseqperm $xt $xn]
					}
				}
				incr xn
				incr xn_plus_1
				incr xendindex
			}
			set xn 0
			set orig_linestore $linestore
			foreach line $linestore {
				set line [lrange $line 0 2]
				set spacey [lindex $spaceys [lindex $xseqperm $xn]]
				set line [concat $line $spacey]
				set linestore [lreplace $linestore $xn $xn $line]
				incr xn
			}
			foreach index $ilist line $linestore origline $orig_linestore {
				if {$istemp} {
					set item ";"
					append item [lindex $origline 0]		;#	Make a Commented out version of the line
					set dummyline [lreplace $origline 0 0 $item]
					set newstring [lindex $dummyline 0]
					append newstring "  "
					foreach item [lrange $dummyline 1 end] {
						append newstring $item "  "
					}
					set newstring [string trimright $newstring]
					set mlst [linsert $mlst $index $newstring]	;#	Insert commented line
					incr index
				}
				set newstring [lindex $line 0]
				append newstring "  "
				foreach item [lrange $line 1 end] {
					append newstring $item "  "
				}
				set newstring [string trimright $newstring]
				set mlst [lreplace $mlst $index $index $newstring]	;#	Insert/replace the new line
			}
			break
		} elseif {($action == "posrnd") || ($action == "poswap")} {
			catch {unset ch_ans}
			catch {unset out_pos}
			foreach index $ilist line $linestore {
				if {![info exists ch_ans]} {
					set ch_ans [lindex $line 2]
				} elseif {![string match $ch_ans [lindex $line 2]]} {
					Inf "Not All Highlighted Lines Have Same Number Of Channels"
					return
				}
				set linelen [llength $line]
				if {$linelen == 4} {	;#	Stereo with no position info
					set outpos [list [lindex $line 3] L [lindex $line 3] R]
				} else {
					set outpos [lrange $line 3 end]
					set max_lev [lindex $outpos 1]
					set llen [llength $outpos]
					set kk 3
					while {$kk < $llen} {
						set thislev [lindex $outpos $kk]
						if {$thislev > $max_lev} {
							set max_lev $thislev
						}
						incr kk 2
					}
				}
				lappend out_pos $outpos
				lappend max_levs $max_lev
			}
			set thislev [lindex $max_levs 0]
			foreach max_lev [lrange $max_levs 1 end] {
				if {![Flteq $max_lev $thislev]} {
					set msg "Sounds Have Different Levels, Which Will Be Exchanged: Proceed ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						return
					}
				}
			}
			set len [llength $out_pos]
			if {$action == "poswap"} {
				set n 0
				set m 1
				while {$n < $len} {
					set mix_perm($n) $m
					incr n
					incr m
				}
				set mix_perm([expr $len - 1]) 0
			} else {
				if {$len == 2} {
					set mix_perm(0) 1
					set mix_perm(1) 0
				} else {
					RandomiseOrder $len
				}
			}
			catch {unset nu_pos}
			set n 0
			while {$n < $len} {
				lappend nu_pos [lindex $out_pos $mix_perm($n)]
				incr n
			}
			set out_pos $nu_pos
		} elseif {$action == "posrot"} {
			if {[expr abs($mixval)] >= $mix_outchans} {
				Inf "Rotation Must Be Less Than (+-) Number Of Channels In Output File"
				return
			}
		}
		if {[string match lineup $action]} {
			set orig_linestore $linestore
			catch {unset qiksyncs}
			catch {unset newstarts}
			foreach line $linestore {
				catch {unset qiksync}
				set this_fnam [lindex $line 0]
				while {![info exists qiksync]} {
					SnackDisplay $evv(SN_SINGLETIME) qikedit3 0 $this_fnam
				}
				lappend qiksyncs $qiksync
			}
			set cc 0
			foreach line $linestore {
				set origstart [lindex $line 1]
				set eventpos [expr $origstart + [lindex $qiksyncs $cc]]
				set step [expr $mixval - $eventpos]
				set newstart [expr $origstart + $step]
				if {$newstart < 0.0} {
					Inf "Cannot Sync The Lines At Time $mixval"
					raise .mixdisplay2
					return
				}
				lappend newstarts $newstart
				incr cc
			}
			set cc 0
			foreach line $linestore {
				set newstart [DecPlaces [lindex $newstarts $cc] 4]
				set line [lreplace $line 1 1 $newstart]
				set linestore [lreplace $linestore $cc $cc $line]
				incr cc
			}
			set checkdata 1

			foreach index $ilist line $linestore origline $orig_linestore {
				if {$istemp} {
					set item ";"
					append item [lindex $origline 0]		;#	Make a Commented out version of the line
					set dummyline [lreplace $origline 0 0 $item]
					set newstring [lindex $dummyline 0]
					append newstring "  "
					foreach item [lrange $dummyline 1 end] {
						append newstring $item "  "
					}
					set newstring [string trimright $newstring]
					set mlst [linsert $mlst $index $newstring]	;#	Insert commented line
					incr index
				}
				set newstring [lindex $line 0]
				append newstring "  "
				foreach item [lrange $line 1 end] {
					append newstring $item "  "
				}
				set newstring [string trimright $newstring]
				set mlst [lreplace $mlst $index $index $newstring]	;#	Insert/replace the new line
			}
			break
		} elseif {[string match syncup $action] || [string match offmark $action]} {
			set orig_linestore $linestore
			catch {unset qiksyncs}
			set linestore [ReverseList $linestore]		;#	lines are held in reverse order
			foreach line $linestore {
				catch {unset qiksync}
				set this_fnam [lindex $line 0]
				while {![info exists qiksync]} {
					SnackDisplay $evv(SN_SINGLETIME) qikedit3 0 $this_fnam
				}
				lappend qiksyncs $qiksync
			}
			set line [lindex $linestore 0]
			set linestart [lindex $line 1]
			set qiksync [lindex $qiksyncs 0]
			set synctime [expr $qiksync + $linestart]		;#	Find absolute time of synchronisation point
			if {[string match offmark $action]} {
				set synctime  [expr $synctime + $mixval]
			}
			set line [lindex $linestore 1]
			set linestart [lindex $line 1]
			set qiksync [lindex $qiksyncs 1]
			set marktime  [expr $qiksync + $linestart]		;#	Find absolute time of markpoint to be moved
			set linemove [expr $synctime - $marktime]		;#	Amount we need to move 2nd line
			set newstart [expr $linestart + $linemove]		;#	Time to which start of 2nd line must therefore be moved
			if {$newstart < 0.0} {
				if {[string match offmark $action]} {
					Inf "Cannot Offset Lines By This Amount At These Time Marks"
				} else {
					Inf "Cannot Synchronise Lines At These Time Marks"
				}
				return
			}
			set line [lreplace $line 1 1 $newstart]
			set linestore [lreplace $linestore 1 1 $line]
			set linestore [ReverseList $linestore]		;#	restore lines to reverse order
			set checkdata 1
			set cc 0 
			foreach index $ilist line $linestore origline $orig_linestore {
				if {$cc == 0} {
					if {$istemp} {
						set item ";"
						append item [lindex $origline 0]		;#	Make a Commented out version of the line
						set dummyline [lreplace $origline 0 0 $item]
						set newstring [lindex $dummyline 0]
						append newstring "  "
						foreach item [lrange $dummyline 1 end] {
							append newstring $item "  "
						}
						set newstring [string trimright $newstring]
						set mlst [linsert $mlst $index $newstring]	;#	Insert commented line
						incr index
					}
					set newstring [lindex $line 0]
					append newstring "  "
					foreach item [lrange $line 1 end] {
						append newstring $item "  "
					}
					set newstring [string trimright $newstring]
					set mlst [lreplace $mlst $index $index $newstring]	;#	Insert/replace the new line
				}
				incr cc
			}
			break
		}
		set cnt 0
		foreach index $ilist line $linestore {
			if {$istemp || [string match $action "mute"]} {
				set item ";"
				append item [lindex $line 0]		;#	Make a Commented out version of the line
				set dummyline [lreplace $line 0 0 $item]
				set newstring [lindex $dummyline 0]
				append newstring "  "
				foreach item [lrange $dummyline 1 end] {
					append newstring $item "  "
				}
				set newstring [string trimright $newstring]
				set mlst [linsert $mlst $index $newstring]	;#	Insert commented line
				incr index
			}
			set do_new 1
			switch -- $action {
				posset -
				posspr -
				poscat {
					set linelen [llength $line]
					if {$linelen == 4} {
						set position 0.0
						set position [RePosition $action $position $val]
						lappend line $position
					} elseif {$linelen >= 5} {
						set position [lindex $line 4]
						set position [RePosition $action $position $val]
						set line [lreplace $line 4 4 $position]
					}
					if {$linelen == 7} {
						set position [lindex $line 6]
						set position [RePosition $action $position $val]
						set line [lreplace $line 6 6 $position]
					}
					set checkdata 2
				}
				poswap -
				posrnd {
					set line [lrange $line 0 2]
					set position [lindex $out_pos $cnt]
					set line [concat $line $position]
					set checkdata 2
				}
				posrot {
					set sttl [lrange $line 0 2]
					set endl [lrange $line 3 end]
					set len [llength $endl]
					set n 0
					set nuline $sttl
					while {$n < $len} {
						set zot [lindex $endl $n]
						set k [string first ":" $zot]
						set rtrt [string range $zot 0 $k]
						incr k
						set rtout [string range $zot $k end]
						incr rtout $mixval	;#	THE ROTATION
						if {$rtout > $mix_outchans} {
							incr rtout [expr -$mix_outchans]
						}					;#	REMAIN WITHIN RANGE
						if {$rtout < 1} {
							incr rtout $mix_outchans
						}
						append rtrt $rtout 
						lappend nuline $rtrt
						incr n
						lappend nuline [lindex $endl $n]
						incr n
					}
					set line $nuline
					set checkdata 2
				}
				poscat2 {
					set linelen [llength $line]
					set position [expr rand() * $val * $repos2]
					set repos2 [expr -$repos2]
					if {$linelen == 4} {
						lappend line $position
					} elseif {$linelen >= 5} {
						set line [lreplace $line 4 4 $position]
					}
					if {$linelen == 7} {
						set position [expr rand() * $val * $repos2]
						set repos2 [expr -$repos2]
						set line [lreplace $line 6 6 $position]
					}
					set checkdata 2
				}
				posftol {
					if {$z_cnt < 2} {
						Inf "Too Few Lines Highlighted"
						return
					}
					if {$cnt == 0} {
						foreach this_line $linestore {
							if {![IsMonoMixline $this_line]} {
								Inf "Highlighted Lines Must Be Mono For This Option"
								return
							}
						}
						set start_pos [GetMonoMixPos $line]
						set end_pos [GetMonoMixPos [lindex $linestore $z_cnt]]
						set pos_step [expr ($end_pos - $start_pos) / double($z_cnt)]
						if {[Flteq $pos_step 0.0]} {
							Inf "First And Last Highlighted Lines Must Be At Different Positions"
							return
						}
					} elseif {$cnt < $z_cnt} {
						set this_pos [FiveSigFig [expr $start_pos + ($cnt * $pos_step)]]
						set linelen [llength $line]
						if {$linelen == 4} {
							lappend line $this_pos
						} else {
							set line [lreplace $line 4 4 $this_pos]
						}
					}
					set checkdata 2
				}
				scatt {
					set time [lindex $line 1]
					set timegap_below [lindex $timegaps_below $cnt]
					set timegap_above [lindex $timegaps_above $cnt]
					set scatter [expr (rand() * 2.0) - 1.0]
					set newval [expr $scatter * $val]
					if {(($newval >= 0.0) && ($timegap_above <= 0.0)) \
					||  (($newval <  0.0) && ($timegap_below <= 0.0))} {
						set newval [expr -$newval]
					}
					if {$newval >= 0.0} {
						set newval [expr $timegap_above * $newval]
					} else {
						set newval [expr $timegap_below * $newval]
					}
					set time [expr $time + $newval]
					set line [lreplace $line 1 1 $time]
					set checkdata 2
				}
				scatw {
					set time [lindex $line 1]
					set timegap_below [lindex $timegaps_below $cnt]
					set timegap_above [lindex $timegaps_above $cnt]
					set scatter [expr (rand() * 2.0) - 1.0]
					if {$timegap_below > $val} {
						set timegap_below $val					
					}
					if {$timegap_above > $val} {
						set timegap_above $val					
					}
					if {$scatter >= 0.0} {
						set offset [expr $timegap_above * $scatter]
					} else {
						set offset [expr $timegap_below * $scatter]
					}
					set time [expr $time + $offset]
					set line [lreplace $line 1 1 $time]
					set checkdata 2
				}
				"mute" {
					set do_new 0
					set mlst [lreplace $mlst $index $index]	 ;#	Delete original line
					set checkdata 1
				}
				"unmute" {
					set do_new 0
					catch {unset nuline}
					set fnam [StripCurlies [lindex $line 0]]
					if {[string match [string index $fnam 0] ";"]} {
						set origline $line
						set fnam [string range $fnam 1 end]
						set line [concat $fnam [lrange $line 1 end]]
						set len [llength $line]
						set the_fnam [lindex $line 0]
						set O_K 0
						if {[file exists $the_fnam]} {
							set O_K 1
							if {![info exists pa($the_fnam,$evv(FTYP))]} {
								set msg "File '$the_fnam' Is Not On The Workspace:\n\nMust Be On The Workspace To Proceed: \n\nGrab To Workspace ??"
								set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
								set O_K 0
								if {$choice == "yes"} {
									if {[FileToWkspace $the_fnam 0 0 0 0 0] > 0} {
										set O_K 1
									}
								}
							}
						} else {
							Inf "File $the_fnam no longer exists"
						}	
						if {!$O_K} {
							return
						}
						if {$mm_multichan} {
							if {[CheckMultiChanLineSyntax $line 0 0]} {
								set mlst [lreplace $mlst $index $index $line]
							}
						} else {
							if {($len == 4) || ($len == 5) || ($len == 7)} {
								set chan [lindex $line 2]
								if {(($chan == 1) && ($len == 5)) || (($chan == 2) && ($len != 5))} {
									if {[file exists $fnam]} {
										set mlst [lreplace $mlst $index $index $line]
									}
								}
							}
						}
					}
					set checkdata 2
				}
				"gain" {								;#	Modify the original line
					if {$mm_multichan} {
						set linelen [llength $line]
						set gainloc 4
						while {$gainloc < $linelen} {
							set gain [lindex $line $gainloc]
							set gain [DecPlaces [expr $gain * $val] 4]
							set line [lreplace $line $gainloc $gainloc $gain]
							incr gainloc 2
						}
					} else {
						set gain [lindex $line 3]
						set gain [expr $gain * $val]
						set line [lreplace $line 3 3 $gain]
						if {[llength $line] == 7} {
							set gain [lindex $line 5]
							set gain [DecPlaces [expr $gain * $val] 4]
							set line [lreplace $line 5 5 $gain]
						}
					}
					set checkdata 2
				}
				"gainchan" {							;#	Modify the original line
					set vals [split $val]
					catch {unset nuvals}
					foreach item $vals {
						if {[string length $item] > 0} {
							lappend nuvals $item
						}
					}
					if {![info exists nuvals] || ([llength $nuvals] != 2)} {
						Inf "Invalid Routing Or Level Information."
						raise .mixdisplay2
						return
					}
					set rout [lindex $nuvals 0]
					set ampl [lindex $nuvals 1]
					set k [lsearch $line $rout]
					incr k
					set lev [lindex $line $k]
					set lev [expr $lev * $ampl]
					set line [lreplace $line $k $k $lev]
					set checkdata 2
				}
				"up" - 
				"down" {
					set gain [lindex $line 3]
					set gain [expr $gain + $val]
					set line [lreplace $line 3 3 $gain]
					if {[llength $line] == 7} {
						set gain [lindex $line 5]
						set gain [expr $gain + $val]
						set line [lreplace $line 5 5 $gain]
					}
					set checkdata 2
				}
				"gainset" {
					if {$mm_multichan} {
						set linelen [llength $line]
						set gainloc 4
						while {$gainloc < $linelen} {
							set line [lreplace $line $gainloc $gainloc $val]
							incr gainloc 2
						}
					} else {
						set line [lreplace $line 3 3 $val]
						if {[llength $line] == 7} {
							set line [lreplace $line 5 5 $val]
						}
					}
						set checkdata 2
				}
				"gainsetchan" {
					set vals [split $val]
					catch {unset nuvals}
					foreach item $vals {
						if {[string length $item] > 0} {
							lappend nuvals $item
						}
					}
					if {![info exists nuvals] || ([llength $nuvals] != 2)} {
						Inf "Invalid Routing Or Level Information."
						raise .mixdisplay2
						return
					}
					set rout [lindex $nuvals 0]
					set lev  [lindex $nuvals 1]
					set k [lsearch $line $rout]
					incr k
					set line [lreplace $line $k $k $lev]
					set checkdata 2
				}
				"gainstp" {
					catch {unset nu_gain_ztep}
					foreach gz $gain_ztep {
						set kk 0
						while {$kk < $zstep} {
							set gz [expr $gz * $mixval]
							incr kk
						}
						lappend nu_gain_ztep [DecPlaces $gz 4]
					}
					set linelen [llength $line]
					if {$mm_multichan} {
						set gainloc 4
						set kkk 0
						while {$gainloc < $linelen} {
							set line [lreplace $line $gainloc $gainloc [lindex $nu_gain_ztep $kkk]]
							incr kkk
							incr gainloc 2
						}
					} else {
						set line [lreplace $line 3 3 [lindex $nu_gain_ztep 0]]
						if {[llength $line] == 7} {
							set line [lreplace $line 5 5 [lindex $nu_gain_ztep 1]]
						}
					}
					incr zstep -1
					set checkdata 2
				}
				"vector" {
					if {$mm_multichan} {
						set gainloc 4
						set linelen [llength $line]
						while {$gainloc < $linelen} {
							set val [lindex $line $gainloc]
							set val [expr $val * [lindex $vec_tor $cnt]]
							set line [lreplace $line $gainloc $gainloc $val]
							incr gainloc 2
						}
					} else {
						set val [lindex $line 3]
						set val [expr $val * [lindex $vec_tor $cnt]]
						set line [lreplace $line 3 3 $val]
						if {[llength $line] == 7} {
							set val [lindex $line 5]
							set val [expr $val * [lindex $vec_tor $cnt]]
							set line [lreplace $line 5 5 $val]
						}
					}
				}
				"left"  -
				"right" -
				"move" -
				"move2" {
					set time [lindex $line 1]
 					set time [expr $time + $val]
					set line [lreplace $line 1 1 $time]
					set checkdata 2
				}
				"over" {
					set time [lindex $line 1]
					if {$val != 0.0} {
						set time [expr $time - $val]
						if {$time < 0.0} {
							Inf "Overlap Too Great For Files Used."
							raise .mixdisplay2
							return
						}
						set val [expr $val - $origval]
					}
					set line [lreplace $line 1 1 $time]
					set checkdata 2
				}
				"expand" {
					set time [lindex $line 1]
 					set time [expr $time * $val]
					set line [lreplace $line 1 1 $time]
					set checkdata 2
				}
				"expandy" {
					set time [lindex $line 1]
					set gap [expr $time - $lasttime]
					set gap [expr double($gap) * $val]
					set time [expr $lasttime  + $gap]
					if {$time < 0} {
						Inf "Time Of Selected Line [expr $cnt + 1] Would Be Less Than Zero"
						raise .mixdisplay2
						return
					}
					set line [lreplace $line 1 1 $time]
					set checkdata 2
				}
				"moveto" {
					set line [lreplace $line 1 1 $val]
					set checkdata 2
				}
				"moveto2" {
					set time [lindex $line 1]
					set time [expr $time - $tstart]
					set time [expr $val + $time]
					if {$time < 0} {
						Inf "Time Of Selected Line [expr $cnt + 1] Would Be Less Than Zero"
						raise .mixdisplay2
						return
					}
					set line [lreplace $line 1 1 $time]
					set checkdata 2
				}
				"every" -
				"lastfile" -
				"file" {						;#	Modify the original line
					set chans [lindex $line 2]
					set newchans $pa($val,$evv(CHANS))
					if {$chans == $newchans} {
						set line [lreplace $line 0 0 $val]
					} else {
						set line [lreplace $line 0 0 $val]		;# replace name
						set line [lreplace $line 2 2 $newchans]	;# replace channel count
						set line [lrange $line 0 3]				;# remove spatialisation data
					}
					set checkdata 2
				}
				"many" {					;#	Change filename in original line
					if {[info exists many_newchans]} {	;#	And reset chan levels where ness
						set ifnam [lindex $line 0]
						set timm [lindex $line 1]
						if {[lsearch $many_unity $ifnam] >= 0} {
							set levv 1.0
						} else {
							set levv [lindex $line 4]
						}
						set line [list $val $timm $many_newchans]
						set chch 1 
						while {$chch <= $many_newchans} {
							set rout $chch
							append rout ":" $chch
							lappend line $rout $levv
							incr chch
						}
					} else {
						set line [lreplace $line 0 0 $val]
					}
					set checkdata 2
				}
				"etoe" {
					set line [lreplace $line 1 1 [lindex $fend $cnt]]
					set checkdata 2
				}
				"mirror" {
					set chancnt [lindex $line 2]
					set linelen [llength $line]
					if {$chancnt == 2} {
						if {$linelen == 4} {
							set loudness [lindex $line 3]
							lappend line "R" $loudness "L"
						} else {
							set loud_l [lindex $line 3]
							set pos_l [lindex $line 4]
							set loud_r [lindex $line 5]
							set pos_r [lindex $line 6]
							set line [lreplace $line 3 end $loud_r $pos_r $loud_l $pos_l]
						}
					} elseif {$linelen > 4} {
						set pos_mono [lindex $line 4]
						switch -- $pos_mono {
							"L" {
								set line [lreplace $line 4 4 "R"]
							}
							"R" {
								set line [lreplace $line 4 4 "L"]
							} "C" {
								;#
							}
							default {
								set line [lreplace $line 4 4 [expr -$pos_mono]]
							}
						}
					}
					set checkdata 2
				}
				"expsil" {
					set time [lindex $line 1]
					foreach {siltime silgap} $silences  {
						if {$time > $siltime} {
							set time [expr $time + ($silgap * ($val - 1.0))]
						}
					}
					set line [lreplace $line 1 1 $time]
					set checkdata 2
				}
				"reroute" {
					set line [concat [lrange $line 0 2] [lindex $routinfos $cnt]]
					set checkdata 0
				} 
			}
			if {$do_new} {
				set newstring [lindex $line 0]
				append newstring "  "
				foreach item [lrange $line 1 end] {
					append newstring $item "  "
				}
				set newstring [string trimright $newstring]
				set mlst [lreplace $mlst $index $index $newstring]	;#	Insert/replace the new line
			}
			incr cnt
		}
		break
	}
	DisplayMixlist $checkdata
	catch {unset ilist}
	if {[info exists displayjiggle]} {
		set i 0
		foreach line [$m_list get 0 end] {
			if {[lsearch $displayjiggle $line] < 0} {
				set line [RemoveCurlies $line]
				if {![string match [string index $line 0] ";"]} {
					lappend ilist $i
				}
			}
			incr i
		}
		if {[info exists ilist]} {
			set firsti [lindex $ilist 0]
			set lasti [lindex $ilist end]
			$m_list selection clear 0 end
			foreach i $ilist {
				$m_list selection set $i
			}
			if {$firsti >= $evv(QIKEDITLEN)} {
				if {$firsti == $lasti} {
					set firsti [expr $firsti - ($evv(QIKEDITLEN)/3)]
				} else {
					set span [expr $lasti - $firsti]
					if {$span < $evv(QIKEDITLEN)} {
						set midspan [expr ($span/2) + $firsti]
						set firsti [expr $midspan - ($evv(QIKEDITLEN)/3)]
					}
				}
				set len [$m_list index end]
				set ratio [expr double($firsti)/double($len)]
				$m_list yview moveto $ratio
			}
		}
	}
}

##########################
# SPATIALISATION OPTIONS #
##########################

#---- Reposition sounds in mixfile

proc RePosition {action position val} {
	switch -- $action {
		posset {
			set position $val
		}
		posspr -
		poscat {
			if [string match poscat $action] {
				set scatter [expr (rand() * 2.0) - 1.0]
				set val [expr $scatter * $val]
			}
			set spread_len 0.0
			if {[Flteq $position 0.0]} {
				set spread_len 0.0				
			} elseif {$position > 0.0} {
				if {$val > 0.0} {
					set spread_len [expr 1.0 - $position]
				} else {
					set spread_len $position
				}
			} else {
				if {$val > 0.0} {
					set spread_len [expr 1.0 + $position]
				} else {
					set spread_len -$position
				}
			}
			set spread_len [expr $spread_len * $val]
			if {$position >= 0.0} {
				set position [expr $position + $spread_len]
			} else {
				set position [expr $position - $spread_len]
			}
		}
	}
	return $position
}

#---- Rotate a set

proc RotateOrder {setlen howmuch} {
	global mix_perm
	set howmuch [expr $howmuch % $setlen]
	set n 0
	while {$n < $setlen} {
		lappend setlist $n
		incr n
	}
	set rot [lrange $setlist 0 [expr $howmuch - 1]]
	set setlist [concat $setlist $rot]
	set setlist [lrange $setlist $howmuch end]
	set n 0
	while {$n < $setlen} {
		set mix_perm($n) [lindex $setlist $n]
		incr n
	}
}

#---- Get opposite position

proc Opposite {} {
	global mixval
	if {[string match "C" $mixval]} {
		return
	} elseif {[string match "L" $mixval]} {
		set mixval R
	} elseif {[string match "R" $mixval]} {
		set mixval L
	} elseif {[IsNumeric $mixval]} {
		if {$mixval == 0.0} {
			return
		} else {
			set mixval [expr -$mixval]
		}
	}
	return
}

#------ Change multichan outrotes from ring-mapping to biltareal mapping, or vice versa

proc Bilateral {route frombi outchans} {

	set route [split $route ":"]
	set ichan [lindex $route 0]
	set ochan [lindex $route 1]
	set outchanover [expr $outchans + 1]
	if {$frombi} {
		if {[IsEven $ochan]} {
			set ochan [expr $outchanover - ($ochan/2)]
		} else {
			set ochan [expr ($ochan/2) + 1]
		}
	} else {
		set k [expr ceil(double($outchans)/2.0)]
		if {$ochan <= $k} {
			set ochan [expr ($ochan * 2) - 1]
		} else {
			set ochan [expr ($outchanover - $ochan) * 2]
		}
	}
	set route $ichan
	append route ":" $ochan
	return $route
}

#------ Mirror multichannel routing about a channel ,or midpoint between 2 chans

proc MirrorFrame {route outchans mirrorplane} {
	set between 0
	set outchans [expr double($outchans)]
	set route [split $route ":"]
	set ichan [lindex $route 0]
	set ochan [lindex $route 1]
	set mirrorplane [expr double($mirrorplane) - 1.0]	;#	Change to 0  to (outchans-1) numbering
	set ochan [expr double($ochan) - 1.0]
	set gap [expr $ochan - $mirrorplane]
	set ochan [expr $mirrorplane - $gap]
	while {$ochan >= $outchans} {
		set ochan [expr $ochan - $outchans]
	}
	while {$ochan < 0} {
		set ochan [expr $ochan + $outchans]
	}
	set ochan [expr int(round($ochan))]
	incr ochan				;#	Change back to 1 to outchans numbering
	set route $ichan
	append route ":" $ochan
	return $route
}

#--- Check syntax of mchan routing string entered in QikEdit Value Box

proc IsValidRouteString {str inchans line inlinecnt} {
	global mix_outchans pa wstk evv

	set origstr [string trim $str]
	set str [split $origstr]
	foreach item $str {
		set item [string trim $item]
		if {[string length $item] > 0} {
			lappend routinfo $item
		}
	}
	if {![info exists routinfo]} {
		Inf "No Route Data Entered"
		return {}
	}
	if {[string match "copy" [string tolower [lindex $routinfo 0]]]} {
		if {[llength $routinfo] !=2} {
			Inf "No (Valid) Output Channels Listed, To Copy To"
			return {}
		}

		set nuochans [split [lindex $routinfo 1] ","]
		foreach item $nuochans {
			if {![regexp {^[0-9]+$} $item]} {
				Inf "Invalid Routing Data For \"Copy\""
				return {}
			}
			if {($item<= 0) || ($item > $mix_outchans)} {
				Inf "Invalid Channel Number ($item) In Routing Data"
				return  {}
			}
		}
		set copylen [llength $nuochans]
		set endline [lrange $line 3 end]
		set linelen [llength $endline]
		if {[expr $copylen * 2] != $linelen} {
			Inf "Number Of Out-routes Specified Does Not Correspond With Number Of Out-routes Already In Line"
			return {}
		}
		set routinfo {}
		foreach {rout lev} $endline {ochan} $nuochans {
			set rout [split $rout ":"]
			set rout [lindex $rout 0]
			append rout ":" $ochan
			lappend routinfo $rout
			lappend routinfo $lev
		}
		set routinfo [concat $endline $routinfo]
		foreach {rout lev} $routinfo {
			lappend routs $rout
		}
		set len [llength $routs]
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set thisrout [lindex $routs $n]
			set m $n
			incr m
			while {$m < $len} {
				set thatrout [lindex $routs $m]
				if {[string match $thisrout $thatrout]} {
					Inf "Channel In-out Routing Duplicated With This Choice Of Output Channels"
					return {}
				}
				incr m
			}
			incr n
		}
		return $routinfo
	}
	if {[string match "odd" [string tolower $origstr]] || [string match "even" [string tolower $origstr]]} {
		set OK 0
		set multip [expr 2 * $inchans]
		set kk $multip
		while {$kk <= $mix_outchans} {
			if {$kk == $mix_outchans} {
				set OK 1
				break
			}
			incr kk $multip
		}
		if {!$OK} {
			Inf "Selected Line $inlinecnt\nInvalid Route Data For An Input File With $inchans Channels"
			return {}
		}
		set kk 3
		set lenlin [llength $line]
		while {$kk < $lenlin} {
			set rout [lindex $line $kk]
			incr kk
			set rout [split $rout ":"]
			set ichan [lindex $rout 0]
			if {![info exists llev($ichan)]} {
				set llev($ichan) [lindex $line $kk]
			} else {
				if {$llev($ichan) != [lindex $line $kk]} {
					Inf "Selected Line $inlinecnt\nAmbiguous $ichan Channel Level"
					return {}
				}
			}
			incr kk
		}
		if {[string match "odd" [string tolower $origstr]]} {
			set ochan 1
		} else {
			set ochan 2
		}
		set ichan 1
		set routinfo {}
		while {$ochan <= $mix_outchans} {
			set rout $ichan
			append rout ":" $ochan
			lappend routinfo $rout $llev($ichan)
			incr ichan
			if {$ichan > $inchans} {
				set ichan 1
			}
			incr ochan 2
		}
		return $routinfo
	}
	if {([string first "wide" [string tolower $origstr]] >= 0) || ([string first "front" [string tolower $origstr]] >= 0)} {
		if {[string first "stereo" [string tolower $origstr]] < 0} {
			Inf "Invalid Routing Data ($origstr)"
			return {}
		}
	}
	if {[string first "stereo" [string tolower $origstr]] >= 0} {
		if {$inchans > 2} {		
			Inf "Selected Line $inlinecnt\nInvalid Route Data For An Input File That Is Not Mono Or Stereo"
			return {}
		}
		if {(($inchans == 2) && ([llength $line] < 7)) || (($inchans == 1) && ([llength $line] < 5))}  {
			Inf "Selected Line $inlinecnt\nOriginal Route Data Invalid"
			return {}
		}
		if {(($inchans == 2) && ([llength $line] > 7)) || (($inchans == 1) && ([llength $line] > 5))}  {
			set kk 3
			set lenlin [llength $line]
			while {$kk < $lenlin} {
				set rout [lindex $line $kk]
				incr kk
				set rout [split $rout ":"]
				set inchan [lindex $rout 0]
				if {$inchan == 1} {
					if {![info exists llevel]} {
						set llevel [lindex $line $kk]
					} else {
						if {$llevel != [lindex $line $kk]} {
							Inf "Selected Line $inlinecnt\nAmbiguous Left Channel Level"
							return {}
						}
					}
				} else {
					if {![info exists rlevel]} {
						set rlevel [lindex $line $kk]
					} else {
						if {$rlevel != [lindex $line $kk]} {
							Inf "Selected Line $inlinecnt\nAmbiguous Right Channel Level"
							return {}
						}
					}
				}
				incr kk
			}
		} else {
			set llevel [lindex $line 4]
			if {$inchans == 2} {
				set rlevel [lindex $line 6]
			}
		}
		if {([string first "front" [string tolower $origstr]] >= 0) && ([string first "wide" [string tolower $origstr]] < 0)} {
			if {$mix_outchans < 3} {
				Inf "Selected Line $inlinecnt\nInvalid Route Data For An Output File With Less Than 3 Channels"
				return {}
			}
			set routinfo {}
			set ll $mix_outchans
			set rr 2
			set rout "1:$ll"
			lappend routinfo $rout $llevel
			if {$inchans == 2} {
				set rout "2:$rr"
				lappend routinfo $rout $rlevel
			} else {
				set rout "1:$rr"
				lappend routinfo $rout $llevel
			}
			return $routinfo
		} elseif {[string first "wide" [string tolower $origstr]] >= 0} {
			if {$mix_outchans < 5} {
				Inf "Selected Line $inlinecnt\nInvalid Route Data For An Output File With Less Than 5 Channels"
				return {}
			}
			set routinfo {}
			set ll [expr $mix_outchans - 1]
			set rr 2
			set rout "1:$ll"
			lappend routinfo $rout $llevel
			incr ll
			set rout "1:$ll"
			lappend routinfo $rout $llevel
			if {$inchans == 2} {
				set rout "2:$rr"
				lappend routinfo $rout $rlevel
				incr rr
				set rout "2:$rr"
				lappend routinfo $rout $rlevel
			} else {
				set rout "1:$rr"
				lappend routinfo $rout $llevel
				incr rr
				set rout "1:$rr"
				lappend routinfo $rout $llevel
			}
			return $routinfo
		} else {
			Inf "Invalid Route Data"
			return {}
		}
	} elseif {([string length $routinfo] > 1) && [string match -nocase [string index $routinfo end] "m"]} {		;#	e.g."7M"
		set len [string length $routinfo]																		;# move to 7 and mirror
		incr len -2
		set rinfo [string range $routinfo 0 $len]
		if {![IsNumeric $rinfo] || ![regexp {^[0-9]+$} $rinfo] || ($rinfo < 1) || ($rinfo > $mix_outchans)} {
			Inf "Invalid Route Data"
			return {}
		}
		incr rinfo -1						;#	change from e.g 1-8 frame to 0-7 frame, for calcs
		set routinfo [lrange $line 3 end]
		set len [llength $routinfo]
		set k 0
		while {$k < $len} {
			set rout [lindex $routinfo $k]
			set rout [split $rout ":"]
			set routin  [lindex $rout 0]
			set routout [lindex $rout 1]
			set offset [expr $routout - 1]							;#	displacement of current output chan from channel 1
			set routout [expr ($rinfo - $offset) % $mix_outchans]	;#	invert displacement (mirror), then offset from NEW centre
			incr routout											;#	change from e.g 0-7 frame to 1-8 frame, for output
			set rout $routin
			append rout ":" $routout
			set routinfo [lreplace $routinfo $k $k $rout]
			incr k 2
		}			
		return $routinfo
	} elseif {([string length $routinfo] > 1) && [string match -nocase [string index $routinfo end] "r"]} {		;#	e.g."3r"
		set len [string length $routinfo]																		;# ROTATE by 3 steps
		incr len -2
		set rinfo [string range $routinfo 0 $len]
		if {![IsNumeric $rinfo] || ![regexp {^[0-9\-]+$} $rinfo] || ($rinfo == 0)} {
			Inf "Invalid Route Data"
			return {}
		}
		if {$rinfo < 0} {
			incr rinfo $mix_outchans
		}
		if {($rinfo < 1) || ($rinfo >= $mix_outchans)} {
			Inf "Invalid Route Data"
			return {}
		}
		set routinfo [lrange $line 3 end]
		set len [llength $routinfo]
		set k 0
		while {$k < $len} {
			set rout [lindex $routinfo $k]
			set rout [split $rout ":"]
			set routin  [lindex $rout 0]
			set routout [lindex $rout 1]
			set routout [expr $routout + $rinfo]		;#	Rotate route output info
			if {$routout > $mix_outchans} {
				set routout [expr $routout - $mix_outchans]
			}
			set rout $routin
			append rout ":" $routout
			set routinfo [lreplace $routinfo $k $k $rout]
			incr k 2
		}			
		return $routinfo
	} elseif {([string first "," $routinfo] > 0)} {
		set qzab 0
		if {$mix_outchans == 8} {
			set qzab 1
			while {$qzab} {
				set kf 0
				set comma_cnt 0
				while {$kf < [string length $routinfo]} {
					if {[string match [string index $routinfo $kf] ","]} {
						incr comma_cnt
					}
					incr kf
				}
				if {$comma_cnt != 1} {
					set qzab 0
					break
				}					
				set kf 0
				set zub [string trim $routinfo]
				set zub [split $zub ","]
				set lchans [lindex $zub 0]
				set rchans [lindex $zub 1]
				if {[string length $lchans] != [string length $rchans]} {
					set qzab 0
					break
				}
				set qlen [string length $lchans]
				if {![IsNumeric $lchans] || ![regexp {^[0-9]+$} $lchans] || ($lchans < 12) || ($lchans > 8765)} {
					set qzab 0
					break
				}
				if {![IsNumeric $rchans] || ![regexp {^[0-9]+$} $rchans] || ($rchans < 12) || ($rchans > 8765)} {
					set qzab 0
					break
				}
				set kf 0
				while {$kf < $qlen} {
					set vall [string index $lchans $kf]
					if {($vall > 8) || ($vall < 1)} {
						set qzab 0
						break
					}
					set vall [string index $rchans $kf]
					if {($vall > 8) || ($vall < 1)} {
						set qzab 0
						break
					}
					incr kf
				}
				if {$qzab == 0} {
					break
				}
				set cnt 0
				foreach item [lrange $line 4 end] {
					if {![IsEven $cnt]} {
						incr cnt
						continue
					}
					if {![info exists levv]} {
						set levv $item
					} elseif {$levv != $item} {
						set msg "File '$ifnam' output level ambiguous ($levv or $item):\n\ndefault to unity gain for this file ??\n"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "no"}  {
							return {}
						} else {
							set levv 1.0
						}
					}
					incr cnt
				}
				set routinfo {}
				set kf 0
				while {$kf < $qlen} {
					set rout "1:"
					append rout [string index $lchans $kf]
					lappend routinfo $rout $levv
					incr kf
				}
				set kf 0
				while {$kf < $qlen} {
					set rout "2:"
					append rout [string index $rchans $kf]
					lappend routinfo $rout $levv
					incr kf
				}
				break
			}
		}	
		if {!$qzab} {
			set rinfo [split $routinfo ","]
			foreach item $rinfo {
				if {![regexp {^[0-9]+$} $item] || ($item < 1) || ($item > $mix_outchans)} {
					Inf "Invalid Route Data"
					return {}
				}
			}
			if {$inchans == 1} {
				set cnt 0
				foreach item [lrange $line 4 end] {
					if {![IsEven $cnt]} {
						incr cnt
						continue
					}
					if {![info exists levv]} {
						set levv $item
					} elseif {$levv != $item} {
						set msg "File '$ifnam' Output Level Ambiguous ($levv or $item):\n\nDefault To Unity Gain For This File ??\n"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "no"}  {
							return {}
						} else {
							set levv 1.0
						}
					}
					incr cnt
				}
				set routinfo {}
				foreach val $rinfo {
					set rout 1
					append rout ":" $val
					lappend routinfo $rout $levv
				}
			} else {
				set routinfo [lrange $line 3 end]
				set len [llength $routinfo]
				set lenrinfo [llength $rinfo]
				set routslen [expr $len / 2]
				if {$routslen != $lenrinfo} {
					set chanratio [expr $lenrinfo / $inchans]
					if {[expr $chanratio * $inchans] ==  $lenrinfo} {		;#	If number of outrouts in instruction is integral multiple of file channelcount
						catch {unset lev}
						set testline [lrange $line 3 end]
						set cnt 0
						foreach item $testline {
							if {[IsEven $cnt]} {
								set rout [split $item ":"]
								set ichan [lindex $rout 0]
							} else {
								if {![info exists lev($ichan)]} {
									set lev($ichan) $item
								} elseif {$lev($ichan) != $item} {
									set msg "Selected Line $inlinecnt\nOutput Level From Channel $ichan Ambiguous ($lev($ichan) or $item): Default To Unity Gain ??\n"
									set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
									if {$choice == "no"}  {
										return {}
									} else {
										set kk 1
										while {$kk <= $inchans} {
											set lev($kk) 1.0
											incr kk
										}
										break
									}
								}
							}
							incr cnt
						}
						set routinfo {}
						set kk 0
						set cc 1
						while {$kk < $lenrinfo} {
							set rout $cc
							append rout ":" [lindex $rinfo $kk]
							lappend routinfo $rout $lev($cc)
							incr kk
							incr cc
							if {$cc > $inchans} {
								set cc 1
							}
						}
						return $routinfo

					} else {
						Inf "Selected Line $inlinecnt\nInvalid Route Data For Line Of This Length"
						return {}
					}
				} elseif {$inchans == [llength $rinfo]} {
					set choice_ness 0
					set testline [lrange $line 3 end]
					set cnt 0
					set ch_no 1
					foreach item $testline {
						if {[IsEven $cnt]} {
							set rout [split $item ":"]
							if {[lindex $rout 0] != $ch_no} {
								set choice_ness 1
								break
							}
							incr ch_no
						}
						incr cnt
					}
					if {$choice_ness} {
						set msg "You Can Either Send Each Input Channel To Each Of These Output Channels\n"
						append msg "Or Each Existing Route To Each Of These Output Channels\n"
						append msg "\n"
						append msg "Send Each Input Channel To Each Of These Output Channels ??"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "yes"}  {
							catch {unset lev}
							set testline [lrange $line 3 end]
							set cnt 0
							foreach item $testline {
								if {[IsEven $cnt]} {
									set rout [split $item ":"]
									set ichan [lindex $rout 0]
								} else {
									if {![info exists lev($ichan)]} {
										set lev($ichan) $item
									} elseif {$lev($ichan) != $item} {
										set msg "Selected Line $inlinecnt\nOutput Level From Channel $ichan Ambiguous ($lev($ichan) or $item): Default To Unity Gain ??\n"
										set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
										if {$choice == "no"}  {
											return {}
										} else {
											set kk 1
											while {$kk <= $inchans} {
												set lev($kk) 1.0
												incr kk
											}
											break
										}
									}
								}
								incr cnt
							}
							set routinfo {}
							set jj 0
							set kk 1
							while {$kk <= $inchans} {
								set rout $kk
								append rout ":" [lindex $rinfo $jj]
								lappend routinfo $rout $lev($kk)
								incr kk
								incr jj
							}
							return $routinfo
						}
					}
				}
				set k 0
				while {$k < $len} {
					set rout [lindex $routinfo $k]
					set rout [split $rout ":"]
					set rout [lindex $rout 0]
					append rout ":" [lindex $rinfo [expr $k/2]]
					set routinfo [lreplace $routinfo $k $k $rout]
					incr k 2
				}
			}
		}
		return $routinfo
	} elseif {[string first "antiphon" [string tolower $routinfo]] == 0} {
		if {$inchans != 2} {		
			Inf "Antiphony Only Works For Stereo Input Files"
			return {}
		}
		catch {unset lev}
		set testline [lrange $line 3 end]
		set cnt 0
		foreach item $testline {
			if {[IsEven $cnt]} {
				set rout [split $item ":"]
				set ichan [lindex $rout 0]
			} else {
				if {![info exists lev($ichan)]} {
					set lev($ichan) $item
				} elseif {$lev($ichan) != $item} {
					set msg "Selected Line $inlinecnt\nOutput Level From Channel $ichan Ambiguous ($lev($ichan) or $item): Default To Unity Gain ??\n"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"}  {
						return {}
					} else {
						set lev(1) 1.0
						set lev(2) 1.0
						break
					}
				}
			}
			incr cnt
		}
		set halfchans [expr $mix_outchans / 2]
		if {[IsEven $mix_outchans]} {
			if {[string match "Antiphon" $routinfo]} {
				set k 1				;#	For 8-chan ... halfchans == 4: routes to 1234 then 5678
			} else {
				set k 2				;#	For 8-chan ... routes to 234 (omits 1)
				set omitrearchan 1	;#  ..... skips 5, then routes to 678
			}
		} else {				;#	For 7-chan
			incr halfchans		;#	 ... halfchans, 3 --> 4	
			set k 2				;#	 ... routes to 234 then  567 (omits 1)
		}
		set routinfo {}
		while {$k <= $halfchans} {
			set rout "1:"
			append rout $k
			lappend routinfo $rout $lev(1)
			incr k
		}
		if {[info exists omitrearchan]} {
			incr k
		}
		while {$k <= $mix_outchans} {
			set rout "2:"
			append rout $k
			lappend routinfo $rout $lev(2)
			incr k
		}
		return $routinfo
	} elseif {[IsNumeric $routinfo]} {
		if {![regexp {^[0-9]+$} $routinfo] || ($routinfo < 1) || ($routinfo > $mix_outchans)} {
			if {($inchans == 1) && [IsNumeric $routinfo] && ($routinfo < [expr $mix_outchans + 1]) && ($routinfo >= 0)} {
				set rinfo [lrange $line 3 end]
				set len [llength $rinfo]			;#	MONO INPUT CAN BE ROUTED TO FRACTIONAL POSITIONS
				set k 1
				catch {unset monlev}
				while {$k < $len} {
					if {![info exists monlev]} {
						set monlev [lindex $rinfo $k]
					} elseif {$monlev != [lindex $rinfo $k]} {
						set msg "Ambiguous Levels In Line '$line': Default To Unity Gain ??"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "no"}  {
							return {}
						}
						set monlev 1.0
						break
					}
					incr k 2
				}
				set routinfo [MonoInterspkrPosition $routinfo $monlev]
				return $routinfo
			} else {
				Inf "Invalid Route Data"
				return {}
			}
		}
		set rinfo [lrange $line 3 end]
		set len [llength $rinfo]
		set k 0
		while {$k < $len} {
			set thisrout [lindex $rinfo $k]
			set thisrout [split $thisrout ":"]
			set in_c [lindex $thisrout 0]
			if {$in_c != 1} {
				Inf "Selected Line $inlinecnt\nRoute Data Insufficient For This Type Of Line"
				return {}
			}
			incr k
			if {![info exists llev]} {
				set llev [lindex $rinfo $k]
			} elseif {![info exists levset] && ([lindex $rinfo $k] != $llev)} {
				set msg "Selected Line '$inlinecnt'\nAmbiguous Level Data In Existing Line: Use Unity Gain ??"
				set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "no"}  {
					return {}
				} else {
					set llev 1.0
					set levset 1
				}
			}	
			incr k
		}
		set routinfo 1
		append routinfo ":" $str
		lappend routinfo $llev
		return $routinfo
	} elseif {[string first "-" $routinfo] > 0} {
		set k [string first "-" $routinfo]
		incr k -1
		set chanlo [string range $routinfo 0 $k]
		if {![IsNumeric $chanlo] || ($chanlo < 1) || ($chanlo > $mix_outchans)} {
			Inf "Invalid Route Data"
			return {}
		}
		incr k 2
		if {$k >= [string length $routinfo]} {
			Inf "Invalid Route Data"
			return {}
		}
		set chanhi [string range $routinfo $k end]
		if {![IsNumeric $chanhi] || ($chanhi < 1) || ($chanhi > $mix_outchans)} {
			Inf "Invalid Route Data"
			return {}
		}
		if {$chanhi == $chanlo} {
			Inf "Invalid Route Data"
			return {}
		}
		set zfnam [lindex $line 0]
		set outchan_cnt 1
		set qq $chanlo
		while {$qq != $chanhi} {
			incr outchan_cnt
			incr qq
			if {$qq > $mix_outchans} {
				set qq 1
			}
		}
		if {![info exists pa($zfnam,$evv(CHANS))]} {
			set msg "Selected Line $inlinecnt\nRoute Data Inappropriate For This Type Of Line : Must Be One Of\n"
			append msg "(1) Mono Sent To N Channels At Same Level (changed To Mono To All Specified Chans At Same Level)\n"
			append msg "(2) Stereo.\n"
			Inf $msg
			return {}
		}
		set in_chans ($pa($zfnam,$evv(CHANS))
		if {$inchans == 2} {
			if {[llength $line] < 7} {
				Inf "Selected Line $inlinecnt\nRoute Data Inappropriate For This Type Of Line:\n(Level Of Each Input Channel Must Be Already Set).\n"
				return {}
			} else {
				catch {unset lev}
				set testline [lrange $line 3 end]
				set cnt 0
				foreach item $testline {
					if {[IsEven $cnt]} {
						set rout [split $item ":"]
						set ichan [lindex $rout 0]
					} else {
						if {![info exists lev($ichan)]} {
							set lev($ichan) $item
						} elseif {$lev($ichan) != $item} {
							set msg "Selected Line $inlinecnt\nOutput Level From Channel $ichan Ambiguous ($lev($ichan) or $item): Default To Unity Gain ??\n"
							set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
							if {$choice == "no"}  {
								return {}
							} else {
								set lev(1) 1.0
								set lev(2) 1.0
								break
							}
						}
					}
					incr cnt
				}
				set multistereo 0
				if {[IsEven $outchan_cnt]} {
					set msg "Selected Line $inlinecnt\nRoute To [expr $outchan_cnt / $inchans] Sets Of Stereo ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						set multistereo 1
					}
				}
				if {!$multistereo} {
					set msg "Selected Line $inlinecnt\nMix Stereo To Mono ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						return {}
					}
				}
			}
		} elseif {($inchans != 1) && ($inchans != $outchan_cnt)} {
			Inf "Selected Line $inlinecnt\nRoute Data Inappropriate For This Type Of Line (Must Be Mono Sent To N Channels, or $outchan_cnt Channels)"
			return {}
		}
		if {$inchans == 1} {
			set levindex 4
			set routlev [lindex $line $levindex]
			incr levindex 2
			while {$levindex < [llength $line]} {
				if {[lindex $line $levindex] != $routlev} {
					Inf "Selected Line $inlinecnt\nRoute Data Inappropriate For This Type Of Mono Line (Must Be Mono To N Channels At Same Level)"
					return {}
				}
				incr levindex 2
			}
			unset routinfo
			set thischan $chanlo
			if {$chanhi < $chanlo} {
				set chanhi [expr $chanhi + $mix_outchans]
			}
			while {$thischan <= $chanhi} {
				set nur "1:"
				append nur $thischan
				lappend routinfo $nur $routlev
				incr thischan
				if {$thischan > $mix_outchans} {
					set thischan 1
					set chanhi [expr $chanhi - $mix_outchans]
				}
			}
		} elseif {$inchans == 2} {
			unset routinfo
			if {$multistereo} {
				set kk 1
				set outch $chanlo
				while {$kk <= $outchan_cnt} {
					set rout "1:"
					append rout $outch
					lappend routinfo $rout $lev(1)					
					incr outch
					if {$outch > $mix_outchans} {
						set outch 1
					}
					incr kk
					set rout "2:"
					append rout $outch
					lappend routinfo $rout $lev(2)
					incr outch
					if {$outch > $mix_outchans} {
						set outch 1
					}
					incr kk
				}
			} else {
				set lev(1) [DecPlaces [expr $lev(1) / 2.0] 2]
				set lev(2) [DecPlaces [expr $lev(2) / 2.0] 2]
				set kk 1
				set outch $chanlo
				while {$kk <= $outchan_cnt} {
					set rout "1:"
					append rout $outch
					lappend routinfo $rout $lev(1)
					set rout "2:"
					append rout $outch
					lappend routinfo $rout $lev(2)
					incr outch
					if {$outch > $mix_outchans} {
						set outch 1
					}
					incr kk
				}
			}
		} else {
			unset routinfo
			set thisoutchan $chanlo
			set rtindex 3
			while {$rtindex < [llength $line]} {
				set rtt [lindex $line $rtindex]
				set rtt [split $rtt ":"]
				set rtt [lreplace $rtt 1 1 $thisoutchan]
				set rtt [join $rtt ":"]
				incr rtindex
				lappend routinfo $rtt [lindex $line $rtindex]
				incr rtindex
				incr thisoutchan
				if {$thisoutchan > $mix_outchans} {
					set thisoutchan 1
				}
			}
		}
		return $routinfo
	}
	set islevel 0
	set entrycnt 1
	foreach val $routinfo {
		if {$islevel} {
			if {![IsNumeric $val] || ($val < 0.0)} {
				Inf "Selected Line $inlinecnt\nInvalid Level ($val) Value For Route $entrycnt (Format \"inchan:outchan\")"
				return {}
			}
		} else {
			catch {unset mm}
			set len [string length $val]
			set n 0
			while {$n < $len} {
				set thischar [string index $val $n]
				if {[regexp {^[0-9]$} $thischar]} {
					incr n
					continue
				} else {
					if {![info exists mm]} {
						if {($n == 0) || ![string match $thischar ":"]} {
							Inf "Selected Line $inlinecnt\nInvalid Routing Code ($val) For Route $entrycnt (Format \"inchan:outchan\")"
							return {}
						}
						set in_chan [string range $val 0 [expr $n - 1]]
						if {($in_chan == 0) || ($in_chan > $inchans)} {
							Inf "Selected Line $inlinecnt\nInvalid Routing Code ($val) For Route $entrycnt (Input Channel not Valid)"
							return {}
						}
						set mm [expr $n + 1]
					}
				}
				incr n
			}
			if {![info exists mm] || ($mm >= $n)} {
				Inf "Selected Line $inlinecnt\nInvalid Routing Code ($val) For Route $entrycnt (Format \"inchan:outchan\")"
				return {}
			}
			set out_chan [string range $val $mm end]
			if {($out_chan == 0) || ($out_chan > $mix_outchans)} {
				Inf "Selected Line $inlinecnt\nInvalid Routing Code ($val) For Route $entrycnt (Output Channel not Valid)"
				return {}
			}

		}
		if {$islevel} {
			incr entrycnt
		}
		set islevel [expr !$islevel]
	}
	if {$islevel} {
		Inf "Selected Line $inlinecnt\nRouting Codes And Levels Not Paired Correctly (Enter a Routing Code and a Level)"
		return {}
	}
	return $routinfo
}

#################################
#			LINE ORDER			#
#################################

#---- Randomly reorder a set

proc RandomiseOrder {setlen} {
	global mix_perm
	set n 0
	while {$n < $setlen} {
		set mix_perm($n) $n
		incr n
	}
	set n 0
	while {$n < $setlen} {
		set t [expr int(floor((rand() * ($n+1))))]
		if {$t==$n} {
			Hprefix $setlen $n
		} else {
			Hinsert $setlen $n $t
		}
		incr n
	}
}

proc Hinsert {setlen m t} {
	global mix_perm
	incr t
	Hshuflup $setlen $t
    set mix_perm($t) $m
}

proc Hprefix {setlen m} {
	global mix_perm
	Hshuflup $setlen 0
    set mix_perm(0) $m
}

proc Hshuflup {setlen k} {
	global mix_perm
	incr setlen -1
    set i $setlen
	set j $i
	incr j -1
	set n $setlen
	while {$n > $k} {
		set mix_perm($i) $mix_perm($j)
		incr i -1
		incr j -1
		incr n -1
    }
}

proc SortMix {line_cnt linestore} {
	set n 0
	while {$n < $line_cnt} {
		set line [lindex $linestore $n]
		set linex [StripCurlies $line]
		if {[string match ";" [string index $linex 0]]} {
			lappend times "C"
		} else {
			lappend times [lindex $line 1]
			set lasttime [lindex $times end]
		}
		lappend timenos $n
		incr n
	}
	if {![info exists times]} {
		Inf "NO ACTIVE LINES"
		return
	}
	set m $n
	incr m -1
	set n 0
	while {$n < $line_cnt} {	;#	Comments get time of line AFTER THEM
		set time [lindex $times $n]
		if {[string match $time "C"]} {
			if {$n == $m} {
				set times [lreplace $times $n $n $lasttime]
			} else {
				set k [expr $n + 1]
				while {$k < $line_cnt} {
					set nexttime [lindex $times $k]
					if {![string match $nexttime "C"]} {
						set times [lreplace $times $n $n $nexttime]
						break
					}	
					incr k
				}
				if {$k == $line_cnt} {
					set times [lreplace $times $n $n $lasttime]
				}
			}
		}
		incr n
	}
		
	set k 0
	while {$k < $m} {	
		set time1 [lindex $times $k] 
		set timeno1 [lindex $timenos $k]
		set j [expr $k + 1]
		while {$j < $n} {	
			set time2 [lindex $times $j] 
			set timeno2 [lindex $timenos $j]
			if {$time1 < $time2} {
				set times [lreplace $times $k $k $time2]
				set times [lreplace $times $j $j $time1]
				set timenos [lreplace $timenos $k $k $timeno2]
				set timenos [lreplace $timenos $j $j $timeno1]
				set time1 $time2
				set timeno1 $timeno2
			}
			incr j
		}
		incr k
	}
	set k 0
	while {$k < $n} {
		set index [lindex $timenos $k]
		lappend new_linestore [lindex $linestore $index]
		incr k
	}
	return $new_linestore
}

proc RandomiseFilenamesWithRoutes {linestore line_cnt} {
	global mix_perm
	RandomiseOrder $line_cnt
	set n 0
	while {$n < $line_cnt} {
		set m $mix_perm($n)
		set line1 [lindex $linestore $n]
		set line2 [lindex $linestore $m]
		set time1 [lindex $line1 1]
		set time2 [lindex $line2 1]
		set line1 [lreplace $line1 1 1 $time2]
		set line2 [lreplace $line2 1 1 $time1]
		set linestore [lreplace $linestore $n $n $line1]
		set linestore [lreplace $linestore $m $m $line2]
		incr n
	}
	set linestore [SortMix $line_cnt $linestore]
	return $linestore
}

proc RandomiseFilenames {linestore line_cnt} {
	global mix_perm pa evv
	set fnam [lindex [lindex $linestore 0] 0]
	if {![info exists pa($fnam,$evv(CHANS))]} {
		Inf "Not All Files Selected Are On The Workspace: Cannot Check Channel Compatibility"
		return $linestore
	}
	set chans $pa($fnam,$evv(CHANS))
	set n 1
	while {$n < $line_cnt} {
		set fnam [lindex [lindex $linestore $n] 0]
		if {![info exists pa($fnam,$evv(CHANS))]} {
			Inf "Not All Files Selected Are On The Workspace: Cannot Check Channel Compatibility"
			return $linestore
		}
		if {$pa($fnam,$evv(CHANS)) != $chans} {
			Inf "Not All Files Have Same Channel-Count: Cannot Safely Randomise Filenames"
			return $linestore
		}
		incr n
	}
	RandomiseOrder $line_cnt
	set n 0
	while {$n < $line_cnt} {
		set m $mix_perm($n)
		set line1 [lindex $linestore $n]
		set line2 [lindex $linestore $m]
		set name1 [lindex $line1 0]
		set name2 [lindex $line2 0]
		set line1 [lreplace $line1 0 0 $name2]
		set line2 [lreplace $line2 0 0 $name1]
		set linestore [lreplace $linestore $n $n $line1]
		set linestore [lreplace $linestore $m $m $line2]
		incr n
	}
	set linestore [SortMix $line_cnt $linestore]
	return $linestore
}


proc RetroFilenames {linestore line_cnt} {
	set n 0
	set m $line_cnt
	incr m -1
	while {$n < $m} {
		set line1 [lindex $linestore $n]
		set line2 [lindex $linestore $m]
		set time1 [lindex $line1 1]
		set time2 [lindex $line2 1]
		set line1 [lreplace $line1 1 1 $time2]
		set line2 [lreplace $line2 1 1 $time1]
		set linestore [lreplace $linestore $n $n $line1]
		set linestore [lreplace $linestore $m $m $line2]
		incr n
		incr m -1
	}
	set linestore [SortMix $line_cnt $linestore]
	return $linestore
}

#############################
#		TIME ORDERING		#
#############################

proc GetTimegaps {linestore line_cnt} {
	set n 1
	set m 0
	if {$line_cnt < 2} {
		Inf "Must Select At Least 2 Lines"
		return 0
	}
	while {$n < $line_cnt} {
		set nexttime [lindex [lindex $linestore $n] 1]
		set thistime [lindex [lindex $linestore $m] 1]
		set timegap [expr $nexttime - $thistime]
		if {$timegap < 0.0} {
			Inf "Times Are Not In Ascending Order: Cannot Proceed"
			return 0
		}
		if {$m == 0} {		;# Store timegaps reversed, as linestore will be reversed
			lappend timegaps $timegap
		} else {
			set timegaps [linsert $timegaps 0 $timegap]
		}
		incr m
		incr n
	}
	return $timegaps
}

proc GetLocalTimeGaps {linestore ilist total_line_cnt ml} {

	foreach line $linestore index $ilist {
		set time [lindex $line 1]
		if {[Flteq $time 0.0]} {
			lappend timegaps_below 0.0
			lappend timegaps_above 0.0
		} else {
			set lastindex $index
			incr lastindex -1
			catch {unset lasttime}
			while {$lastindex >= 0} {
				set lastline [lindex $ml $lastindex]
				if {![string match ";" [string index [lindex $lastline 0] 0]]} {
					set lasttime [lindex $lastline 1]
					break
				}			
				incr lastindex -1
			}
			if {![info exists lasttime]} {
				set lasttime $time
			}
			set timegap_below [expr ($time - $lasttime) / 2.0]
			if {$timegap_below < 0.0} {
				return 0
			}
			set nextindex $index
			incr nextindex
			catch {unset nexttime}
			while {$nextindex < $total_line_cnt} {
				set nextline [lindex $ml $nextindex]
				if {![string match ";" [string index [lindex $nextline 0] 0]]} {
					set nexttime [lindex $nextline 1]
					break
				}			
				incr nextindex
			}
			if {![info exists nexttime]} {
				set nexttime $time
			}
			set timegap_above [expr ($nexttime - $time) / 2.0]
			if {$timegap_above < 0.0} {
				return 0
			}
			lappend timegaps_below $timegap_below
			lappend timegaps_above $timegap_above
		}
	}
	set k [llength $timegaps_below]
	incr k -1
	while {$k >= 0} {	;#	Reverse order of data, as linestore will be reversed
		lappend newlist_below [lindex $timegaps_below $k]
		lappend newlist_above [lindex $timegaps_above $k]
		incr k -1
	}
	set time_gaps [list $newlist_below $newlist_above]
	return $time_gaps
}

proc QuantiseMix {line_cnt linestore val} {

	set n 0
	while {$n < $line_cnt} {
		set line [lindex $linestore $n]
		set time [lindex $line 1]
		set kk [expr int(round($time / $val))]
		set time [expr (double($kk) * $val)]
		set line [lreplace $line 1 1 $time]
		set linestore [lreplace $linestore $n $n $line]
		incr n
	}
	return $linestore
}

##########################################
#		SAVING AND DISPLAYING MIXES      #  
##########################################

proc SaveQikEditMix {} {
	global mm_multichan qikeditmixname qikeditext m_list mlsthead pa evv
	if {[string length $qikeditmixname] <= 0} {
		Inf "No Mix Filename Entered"
		return
	}
	set qikeditmixname [string tolower $qikeditmixname]
	if {![ValidCDPRootname $qikeditmixname]} { 
		return
	}
	set fnam $qikeditmixname
	append fnam $qikeditext
	if {[file exists $fnam]} {
		Inf "File '$fnam' Already Exists: You Cannot Overwrite It Here"
		return
	}
	if [catch {open $fnam w} fileId] {
		Inf "Cannot Create New File To Do Updating.\n"
		return
	}
	if {$mm_multichan} {
		puts $fileId $mlsthead
	}
	foreach line [$m_list get 0 end] {
		puts $fileId $line
	}
	close $fileId
	DummyHistory $fnam "CREATED"
	FileToWkspace $fnam 0 0 0 0 1
	if [catch {set ftype $pa($fnam,$evv(FTYP))}] {
		Inf "Cannot Find Properties Of Edited File."
		return
	}
	if {$mm_multichan} {
		if {$ftype != $evv(MIX_MULTI)} {
			Inf "Edited File Is No Longer A Valid Multi-Channel Mixfile."
		}
	} elseif {![IsAMixfile $ftype]} {
		Inf "Edited File Is No Longer A Valid Mixfile."
	} else {
		MixMUpdate $fnam 1
		Inf "Saved Current State Of Mix In '$fnam'"
	}
}

#---- Display or Redisplay mixlisting in QikEditor

proc DisplayMixlist {checkdata} {
	global m_list m_list_restore mlst m_previous_yview evv hilitecheck is_mgain prm
	
	$m_list delete 0 end

	if {[info exists hilitecheck]} {
		set line0 [lindex $mlst [lindex $hilitecheck 0]]
		set line1 [lindex $mlst [lindex $hilitecheck 1]]
	}
	if {[info exists hilitecheck]} {
		set kk 0
		foreach line $mlst {
			if {[string match $line $line0]} {
				lappend hilited $kk
			} elseif {[string match $line $line1]} {
				lappend hilited $kk
			}
			incr kk
		}
		if {[info exists hilited]} {
			set m_list_restore $hilited
		}
	}

	foreach line $mlst {
		set n 0
		catch {unset newstring}
		foreach item $line {		
			set item [StripCurlies $item]
			if {$n == 0} {
				set newstring $item
				append newstring "    "
			} else {
				append newstring $item "    "
			}
			incr n
		}
		set newstring [string trimright $newstring]
		$m_list insert end $newstring
	}
	if {[info exists m_list_restore]} {
		set first_list_restore [lindex $m_list_restore 0]
		set k [$m_list index end]
		if {$k > 0.0 && ($first_list_restore > $evv(QIKEDITLEN))} {
			set j [expr $first_list_restore - 4]
			if {$j < 0} {
				set j 0
			}
			set k [expr double($j) / double($k)]
			$m_list yview moveto $k
		}
		$m_list selection clear 0 end
		foreach ss $m_list_restore {
			$m_list selection set $ss
		}
		unset m_list_restore
	}
	if {[info exists m_previous_yview]} {
		$m_list yview moveto [lindex $m_previous_yview 0]
	}
	switch -- $checkdata {
		0 {
			;#	No Checks
		}
		1 {
			RedefineMixfileEnd	;#	Check for change in mixfile end time
		}
		2 {
			RedefineMixfileEnd	;#	Check for change in mixfile end time
			if {[info exists is_mgain]} {
				set prm(2) 1.0
				if {[string first ";MIX    LEVEL" [$m_list get 0]] == 0} {
					$m_list delete 0
				}
				unset is_mgain
			}
			DuplTest			;#	Check for duplicated lines
		}
	}
}

#---- Get text bracketed in curly-brackets

proc StripCurlies {str} {
	set j [string first "\{" $str]
	if {$j >= 0} {
		incr j
	} else {
		set j 0
	}
	set k [string first "\}" $str]
	if {$k >= 0} {
		incr k -1
	} else {
		set k "end"
	}
	set string [string range $str $j $k]
}

#---- Remove any curly brackets used in a list of items

proc RemoveCurlies {str} {
	set nustr $str
	set j [string first "\{" $nustr]
	while {$j >= 0} {
		if {$j > 0} {
			incr j -1
			set partstr [string range $nustr 0 $j]
			incr j 2
			set nustr [concat $partstr [string range $nustr $j end]]
		} else {
			set nustr [string range $nustr 1 end]
		}
		set k [string first "\}" $nustr]
		if {$k >= 0} {
			incr k -1
			set partstr [string range $nustr 0 $k]
			incr k 2
			set nustr [concat $partstr [string range $nustr $k end]]
		}
		set j [string first "\{" $nustr]
	}
	return $nustr
}

#---- On QikEdit Page, save current state of mixfile, AND mix it.

proc QikSaveAndMix {} {
	global evv m_list wl pa mm_multichan prm last_mix rememd qik_typ mixrestorename chlist pr12_34
	global CDPidrun prg_dun prg_abortd wstk qik_bakups_cnt mix_modified qikgain qikwhole mlsthead mchanqikfnam
	global mixd2

	if {$qikwhole} {
		if {![QikEditor dflts2]} {
			set qikwhole 0
			focus $mixd2.1.see.1.seefile
			return 0
		}
	}
	set keepfnam $evv(DFLT_TMPFNAME)
	append keepfnam $qik_bakups_cnt $evv(TEXT_EXT)

	set fnam $mixrestorename
	set tmpfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tmpfnam w} fileId] {
		Inf "Cannot Open Temporary File To Do Updating.\n"
		focus $mixd2.1.see.1.seefile
		return 0
	}
	if {$mm_multichan} {
		puts $fileId $mlsthead
	}
	foreach line [$m_list get 0 end] {
		puts $fileId $line
	}
	close $fileId
	set do_parse_report 0
	if {[DoParse $tmpfnam $wl 0 0] <= 0} {
		ErrShow "Parsing failed for edited file."
		focus $mixd2.1.see.1.seefile
		return 0
	}
	if [catch {set ftype $pa($tmpfnam,$evv(FTYP))} xzit] {
		Inf "Cannot Find Properties Of Edited File."
		focus $mixd2.1.see.1.seefile
		return 0
	}
	if {$mm_multichan} {
		if {$ftype != $evv(MIX_MULTI)} {
			Inf "Edited File Is No Longer A Valid Multi-Channel Mixfile."
			PurgeArray $tmpfnam
			focus $mixd2.1.see.1.seefile
			return 0
		}
	} elseif {![IsAMixfile $ftype]} {
		Inf "Edited File Is No Longer A Valid Mixfile."
		PurgeArray $tmpfnam
		focus $mixd2.1.see.1.seefile
		return 0
	}
	if [catch {file copy $fnam $keepfnam} in] {
		if {$qik_bakups_cnt == 0} {
			set msg "Cannot Backup Original Mix : Do You Wish To Proceed ?"
		} else {
			set msg "Cannot Preserve Copy Of Previous Version : Do You Wish To Proceed ??"
		}
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if [string match no $choice] {
			focus $mixd2.1.see.1.seefile
			return 0
		}
	} else {
		CopyProps $fnam $keepfnam
		incr qik_bakups_cnt
	}
	if {![QikRecreateMixfile $fnam $tmpfnam 0]} {
		focus $mixd2.1.see.1.seefile
		return 0
	}
	if {($qik_typ == "mix") || ($qik_typ == "mix0")} {
		set infnam [lindex $chlist 0]
	} elseif {$qik_typ == "mix3"} {
		set infnam $mchanqikfnam
	}
	if {$prm(0) >= $pa($infnam,$evv(DUR))} {
		Inf "Mixing Starttime Incompatible With Mixfile Data"
		focus $mixd2.1.see.1.seefile
		return 0
	}
	if {$prm(1) > $pa($infnam,$evv(DUR))} {
		set prm(1) $pa($infnam,$evv(DUR))
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput snd 0
	set outfnam $evv(DFLT_OUTNAME)0$evv(SNDFILE_EXT)
	if {$mm_multichan} {
		set cmd [file join $evv(CDPROGRAM_DIR) newmix]
		lappend cmd multichan $infnam $outfnam -s$prm(0) -e$prm(1) -g$prm(2)
	} else {
		set cmd [file join $evv(CDPROGRAM_DIR) submix]
		lappend cmd mix $infnam $outfnam -s$prm(0) -e$prm(1) -g$prm(2)
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	Block "Mixing"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Failed To Do Mixing : But Mixfile Updated\n\nCheck Mix Syntax"
		DeleteAllTemporaryFilesWhichAreNotCDPOutput snd 0
		UnBlock
		focus $mixd2.1.see.1.seefile
		return 0
   	} else {
   		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	RememberCurrentParams
	RememberLastRunVals
	if {!$prg_dun || ![file exists $outfnam]} {
		UnBlock
		Inf "Failed To Do Mixing : But Mixfile Updated\n\nDo Mix From Parameters Page"
		DeleteAllTemporaryFilesWhichAreNotCDPOutput snd 0
		focus $mixd2.1.see.1.seefile
		return 0
	}
	set outfnam [DoOutputParse $outfnam]
	UnBlock
	if {[string length $outfnam] <= 0} {
		Inf "Failed to GetProperties of Mix (Sound) Output File : But Mixfile Updated"
		focus $mixd2.1.see.1.seefile
		return 0
	}
	catch {unset mix_modified}
	set qikgain $prm(2)
	focus $mixd2.1.see.1.seefile
	return 1
}

#----- After a sequence of mixfile edits on QikEdit page, and enable naming of final output sndfile on params page, and exit to params page

proc QikKeep {} {
	global pr12_34 papag sndsout smpsout vwbl_sndsysout asndsout txtsout prg_ocnt wstk mix_modified
	global qik_typ mchanqikfnam pr_qikmmname qikmmname rememd wl evv
	if {[info exists mix_modified]} {
		set msg "Mix Data Has Been Modified Since Last Mix Was Run.\n\n"
		append msg "Preserve These Post-Mixing Changes ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if [string match yes $choice] {
			if {![QikSaveAndMix]} {
				return
			}
		} else {
			set msg "Proceed To Save Sound Without Preserving These Post-Mixing Changes ??"
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			if [string match no $choice] {
				return
			}
		}
	}
	catch {unset mix_modified}
	set sndsout 1
	set smpsout 1
	set vwbl_sndsysout 1
	set txtsout 0
	set asndsout 0
	set prg_ocnt 1
#TEST SHOULD THIS BE ADDED HERE
#	RememberCurrentParams
	if {$qik_typ == "mix"} {
		EnableOutputButtons $papag.parameters.output $papag.parameters.zzz.newp $papag.parameters.zzz.newf
	} else {
		set tempfnam $evv(DFLT_OUTNAME)0$evv(SNDFILE_EXT)
		set msg "Save With Name '[file rootname [file tail $mchanqikfnam]]' ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if [string match yes $choice] {
			set qikmmname [file rootname [file tail $mchanqikfnam]]
		} else {
			set qikmmname ""
		}
		set f .qikmmname
		if [Dlg_Create $f "MULTICHAN OUTFILE NAME" "set pr_qikmmname 0" -width 80] {
			frame $f.b0
			frame $f.b1
			button $f.b0.ok -text "Set Name"  -command {set pr_qikmmname 1} -highlightbackground [option get . background {}]
			button $f.b0.qu -text "Abandon" -command {set pr_qikmmname 0} -highlightbackground [option get . background {}]
			pack $f.b0.ok -side left
			pack $f.b0.qu -side right
			label $f.b1.ll -text "Outfile Name "
			entry $f.b1.e -textvariable qikmmname -width 30
			pack $f.b1.ll $f.b1.e -side left -pady 1
			pack $f.b0 $f.b1 -side top -fill x -expand true -pady 2
#			wm resizable $f 0 0
			bind $f <Escape> {set pr_qikmmname 0}
			bind $f <Return> {set pr_qikmmname 1}
		}
		raise $f
		set pr_qikmmname 0
		set finished 0
		My_Grab 0 $f pr_qikmmname $f.b1.e
		while {!$finished} {
			tkwait variable pr_qikmmname
			if {$pr_qikmmname} {
				if {[string length $qikmmname] <= 0} {
					Inf "No Name Entered."
					continue
				}
				set outname [string tolower $qikmmname]
				if {![ValidCDPRootname $outname]} { 
					continue
				}
				append outname $evv(SNDFILE_EXT)
				if {[file exists $outname]} {
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
							-message "File exists: overwrite it ?"]
					if {$choice == "no"} {
						continue
					}
					if {![DeleteFileFromSystem $outname 0 1]} {
						Inf "Cannot Delete Existing File $outname"
						continue
					} else {
						DummyHistory $outname "DESTROYED"
						if {[IsInAMixfile $outname]} {
							if {[MixM_ManagedDeletion $outname]} {
								MixMStore
							}
						}
						set i [LstIndx $outname $wl]	;#	remove from workspace listing, if there
						if {$i >= 0} {
							$wl delete $i
							WkspCnt $outname -1
							catch {unset rememd}
						}
					}
				}
				if [catch {file rename $tempfnam $outname} zit] {
					Inf "Cannot Name The Sound Output Of The Mix: Abandoning It For Now"
					break
				}
				FileToWkspace $outname 0 0 0 0 1
				Inf "File '$outname' Is On The Workspace"
				set finished 1
			} else {
				set msg "Abandon The Sound Output ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
						-message "File exists: overwrite it ?"]
				if {$choice == "no"} {
					continue
				}
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	}
	set pr12_34 2
}

#----- OnQikEdit Page, recall a previous version of the mixfile, made during the current sequence of edits

proc QikRecall {} {
	global pr_qikrecall mixrestorename qik_bakups_cnt qik_typ qikrec m_list wstk evv
	set pr_qikrecall 0
	set f .qikrecall
	if {$qik_bakups_cnt == 0} {
		Inf "No Previous Versions To Recall"
		return
	}
	if [Dlg_Create $f "RECALL MIXFILE VERSION" "set pr_qikrecall 0" -width 80] {
		frame $f.b0
		frame $f.b00
		frame $f.b1
		frame $f.b2
		frame $f.b3
		button $f.b0.ok -text "Select"  -command {set pr_qikrecall 1} -highlightbackground [option get . background {}]
		button $f.b0.qu -text "Abandon" -command {set pr_qikrecall 0} -highlightbackground [option get . background {}]
		pack $f.b0.ok -side left
		pack $f.b0.qu -side right
		label $f.b00.ll1 -text  "NB: This recalls the MIXFILE, but NOT the mixed sound it produces." -fg $evv(SPECIAL)
		label $f.b00.ll2 -text  "       A mix must be run on this version to produce the sound output." -fg $evv(SPECIAL)
		pack $f.b00.ll1 $f.b00.ll2 -side top -pady 2
		label $f.b1.ll -text "Version" -font bigfnt
		pack $f.b1.ll -side top -pady 2
		set n 0
		set k 0
		frame $f.b2.$k
		while {$n < $qik_bakups_cnt} {
			radiobutton $f.b2.$k.$n -text "$n" -variable qikrec -value $n -command "DisplayOldQik $n"
			pack $f.b2.$k.$n -side left
			incr n
			if {[expr $n % 20] == 0} {
				pack $f.b2.$k -side top
				incr k
				frame $f.b2.$k
			}
		}
		pack $f.b2.$k -side top
		Scrolled_Listbox $f.b3.wlst -width 128 -height 32 -selectmode single
		pack $f.b3.wlst -side top -fill both -expand true -pady 2 
		pack $f.b0 $f.b00 $f.b1 $f.b2 $f.b3 -side top -fill x -expand true -pady 2
#		wm resizable $f 0 0
		bind $f <Return> {set pr_qikrecall 1}
		bind $f <Escape> {set pr_qikrecall 0}
	}
	$f.b1.ll config -text ""
	set qikrec -1
	$f.b3.wlst.list delete 0 end
	foreach line [$m_list get 0 end] {
		$f.b3.wlst.list insert end $line
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_qikrecall 0
	set finished 0
	My_Grab 0 $f pr_qikrecall
	while {!$finished} {
		tkwait variable pr_qikrecall
		if {$pr_qikrecall} {
			if {$qikrec < 0} {
				Inf "No Previous Version Selected"
				continue
			}
			set oldfnam $evv(DFLT_TMPFNAME)
			append oldfnam $qikrec $evv(TEXT_EXT)
			if {![file exists $oldfnam]} {
				Inf "This Version No Longer Exists"
				continue
			}
			if {![QikRecreateMixfile $mixrestorename $oldfnam 1]} {
				break
			}
			set keepfnam $evv(DFLT_TMPFNAME)
			append keepfnam $qik_bakups_cnt $evv(TEXT_EXT)
			if [catch {file copy $mixrestorename $keepfnam} in] {
				Inf "Cannot Preserve A Copy Of This Recalled-Version In The Sequence Of Bakup Files\n(If Recall Needed Later, Use The Version You Are Using Now)"
			} else {
				CopyProps $oldfnam $keepfnam
				incr qik_bakups_cnt
			}
			$m_list delete 0 end
			foreach line [$f.b3.wlst.list get 0 end] {
				$m_list insert end $line
			}
			set finished 1
		} else {
			set finished 1
		}

	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#------- QikEdit page: display a previous edited-version of the mixfile

proc DisplayOldQik {n} {
	global mm_multichan evv
	set oldfnam $evv(DFLT_TMPFNAME)
	append oldfnam $n $evv(TEXT_EXT)
	if {![file exists $oldfnam]} {
		Inf "This Old Version No Longer Exists"
		return
	}
	if [catch {open $oldfnam "r"} zit] {
		Inf "Cannot Open This Old Version"
		return
	}
	.qikrecall.b3.wlst.list delete 0 end
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] > 0} {
			if {$mm_multichan && ($cnt == 0)} {
				incr cnt
				continue
			}
			.qikrecall.b3.wlst.list insert end $line
		}
		incr cnt
	}
	.qikrecall.b1.ll config -text "Version $n" -font bigfnt
	close $zit
}

#------- QikEdit page: replace the original version of the mixfile, with a newly edited version

proc QikRecreateMixfile {fnam tmpfnam frombakups} {
	global last_mix wl rememd qik_typ

	if [catch {file delete -force $fnam}] {
		Inf "Cannot Remove The Original File To Replace It With New Values"
		PurgeArray $tmpfnam
		return 0
	}
	DeleteFileFromSrcLists $fnam
	if [catch {file rename -force $tmpfnam $fnam} in] {
		ErrShow "$in"
		set msg "Cannot Substitute The New File: Original File Lost\n\n"
		if {$frombakups} {
			append msg "New Data Is In File '$tmpfnam' : Rename It ~~NOW~~, Outside The Loom, If You Wish To Preserve It"
		} else {
			append msg "It Can Be Replaced From Previous Versions"
		}
		Inf $msg
		PurgeArray $tmpfnam
		PurgeArray $fnam				;#	can't remove unbakdup files!!
		RemoveFromChosenlist $fnam
		RemoveFromDirlist $fnam
		if {[string match $last_mix $fnam]} {
			set last_mix ""
		}
		set i [LstIndx $fnam $wl]
		if {$i >= 0} {
			$wl delete $i
			WkspCnt $fnam -1
			catch {unset rememd}
		}
		set OK 0
		DummyHistory $fnam "LOST"
		if {[MixMDelete $fnam 0]} {
			MixMStore
		}
		return 0
	} else {									
		DummyHistory $fnam "EDITED"
		PurgeArray $fnam				
		RenameProps $tmpfnam $fnam 0
		if {[MixMUpdate $fnam 0]} {
			MixMStore
		}
	}
	return 1
}

#----- Qikedit page: Copy props of newly edited mixfile to a bakup copy, which may be recalled

proc CopyProps {fnam newname} {
	global pa evv
	set propno 0
	while {$propno < ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
		if {[info exists pa($fnam,$propno)]} {
			set pa($newname,$propno) $pa($fnam,$propno)
		}
		incr propno
	}
}

############################################################
#		FUNCTIONS CONNECTED WITH OPERATION ON MIXFILE	   #
############################################################

proc IsGainVal {val} {
	global mm_multichan
	if {[string first ":" $val] > 0} {
		if {!$mm_multichan} {
			return ""
		}
		set val [split $val]
		set cnt 0
		foreach item $val {
			if {[string length $item] > 0} {
				switch -- $cnt {
					0 {
						set routing $item
						set rout [split $item ":"]
						if {[llength $rout] != 2} {
							return ""
						}
						set ichan [lindex $rout 0]
						set ochan [lindex $rout 1]
						if {![regexp {^[0-9]+$} $ichan] || ($ichan < 1)} {
							return ""
						}
						if {![regexp {^[0-9]+$} $ochan] || ($ichan < 1)} {
							return ""
						}
					}
					1 {
						if {![IsNumeric $item] || ($item <= 0.0)} {
							return ""
						}
					}
					default {
						return ""
					}
				}
				incr cnt
			}
		}
		if {$cnt != 2} {
			return ""
		}
		return $routing
	}
	set val [string tolower $val]
	set len [string length $val]
	set k [string first "db" $val]
	if {$k > 0} {
		incr k 2
		if {$k != $len} {
			return ""
		}
		incr k -3
		set val [string range $val 0 $k]
		if {![IsNumeric $val]} {
			return ""
		}
		if {[Flteq $val 0.0]} {
			return 1.0
		}
		set isneg 0
		if {$val < 0.0} {
			set val [expr -($val)]
			set isneg 1
		}
		set val [expr double($val) / 20.0]
		set val [expr pow(10.0,$val)]
		if {$isneg} {
			set val [expr 1.0 / $val]
		}
		return $val
	} elseif {![IsNumeric $val] || ($val <= 0.0)} {
		return ""
	}
	return $val
}

#--- Check validity of gain value, converting to numeric if ness

proc CheckGainVal {gain lineno report} {

	if {[string length $gain] > 2} {
		set q [string first "d" [string tolower $gain]]
		if {$q > 0} {
			incr q
			if {[string match "b" [string tolower [string index $gain $q]]]} {
				incr q -2
				set gain [string range $gain 0 $q]
				if {![IsNumeric $gain]} {
					if {$report} {
						Inf "Invalid Gain Value On Line $lineno"
					}
					return -1
				}
				return [dBtoGain $gain]
			} else {
				if {$report} {
					Inf "Invalid Gain Value On Line $lineno"
				}
				return -1
			}
		}
	}
	if {![IsNumeric $gain]} {
		if {$report} {
			Inf "Invalid Gain Value On Line $lineno"
		}
		return -1
	}
	return $gain
}

#--- Convert dB val to gain

proc dBtoGain {val} {
	global mu

	set is_neg 0
	if {$val <= $mu(MIN_DB_ON_16_BIT)} {
		return 0.0
	}
	if [Flteq $val 0.0] {
		return 1.0
	}
	if {$val < 0.0} {
		set val -$val
		set is_neg 1
	}
	set val [expr $val / 20.0]
	set val [expr pow(10.0,$val)]
	if {$is_neg} {
		set val [expr 1.0 / $val]
	}
	return $val
}

proc ConsecutiveLines {ilist non_op_lines}  {
	set lastline [lindex $ilist 0]
	incr lastline
	foreach thisline [lrange $ilist 1 end] {
		while {$thisline != $lastline} {
			if {[lsearch $non_op_lines $lastline] >= 0} {
				incr lastline
			} else {
				return 0
			}
		}
		set lastline $thisline
		incr lastline
	}
	return 1
}

proc GetMonoMixPos {line} {
	set chans [lindex $line 2]
	if {[llength $line] < 5} {
		set pos 0
	} else {
		set pos [lindex $line 4]
		switch -- $pos {
			"C"	{set pos 0}
			"L" {set pos -1}
			"R" {set pos 1}
		}
	}
	return $pos
}	
	
proc IsMonoMixline {line} {
	set chans [lindex $line 2]
	if {$chans == 1} {
		return 1
	}
	return 0
}

#--- Finding times in QikEdit Mixfile

proc LineIndexAtTimeInQikEdit {thistime} {
	global mlst
	set i 0
	foreach line $mlst {
		if {[lindex $line 1] >= $thistime} {
			return $i
		}
		incr i
	}
	return $i
}

#################################################################
#	GETTING VALS RELATED TO, OR VIEWING SND IN, A QIKEDIT LINE	#
#################################################################

proc QikEditor {typ} {
	global m_list pa prm chlist qikval qikstor mixval evv pa prm mixrestorename qikgain wstk qikwhole

	if {($typ == "calcvv") || ($typ == "calcsv") || ($typ == "sttval") || ($typ == "endval") || ($typ == "mixamp")} {
		if {![IsNumeric $mixval]} {
			Inf "Value Is Not Numeric"
			return 0
		}
		if {($typ == "sttval") || ($typ == "endval")} {
			if {($mixval < 0.0) || ($mixval > $pa($mixrestorename,$evv(DUR)))} {
				Inf "Value Is Not Valid For Mix Start Or End Time (Try Saving 'Edited Version')"
				return 0
			}
			if {$typ == "sttval"} {
				if {$mixval >= $prm(1)} {
					Inf "Value Is Not Valid For Mix Start Time, Given Current End Time ($prm(1))"
					return 0
				}
			} else {
				if {$mixval <= $prm(0)} {
					Inf "Value Is Not Valid For Mix End Time, Given Current Start Time ($prm(0))"
					return 0
				}
			}
		}			
		if {$typ == "mixamp"} {
			if {$mixval <= 0.0} {
				Inf "Value Is Not Valid For Mix Gain"
				return 0
			}
			if {$mixval > 1.0} {
				set msg "Are You Sure You Want To Set Mix Gain To '$mixval' ??"
				set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "no"} {
					return 0
				}
			}
		}
		switch -- $typ {
			"calcvv" {
				set qikval $mixval
			}
			"calcsv" {
				set qikstor $mixval
			}
			"sttval" {
				set prm(0) $mixval
				SetScale 0 linear
				ColourWholeMixButton
				set qikwhole 0
				Inf "Mix Start-Time Set to $mixval"
			}
			"endval" {
				set prm(1) $mixval
				SetScale 1 linear
				ColourWholeMixButton
				set qikwhole 0
				Inf "Mix End-Time Set to $mixval"
			}
			"mixamp" {
				set prm(2) $mixval
				set qikgain $prm(2)
				Inf "Mix Gain Set to $mixval"
			}
		}
		return 1
	}
	if {($typ == "dflts") || ($typ == "dflts2")} {
		set endnow 0
		foreach line [$m_list get 0 end] {
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			set f_n_am [lindex $line 0]
			set ti_m   [lindex $line 1]
			if {![info exists pa($f_n_am,$evv(DUR))]} {
				Inf "Not All The Mixfiles Are On The Workspace: Cannot Calculate True Mix End"
				set qikwhole 0
				return 0
			}
			set dur $pa($f_n_am,$evv(DUR))
			set thisend [expr $ti_m + $dur]
			if {$thisend > $endnow} {
				set endnow $thisend
			}
		}
		set prm(0) 0
		SetScale 0 linear
		set prm(1) $endnow
		SetScale 1 linear
		ColourWholeMixButton
		set qikwhole 1
		if {$typ != "dflts2"} {
			Inf "DOING THE WHOLE MIX"
		}
		return 1
	}
	set i [$m_list curselection]
	if {$i < 0} {
		if {$typ == "play"} {
			set	qfnam $evv(DFLT_OUTNAME)						;#	First look for file output from current use of MIX process
			append qfnam 0 $evv(SNDFILE_EXT)
			if {[file exists $qfnam]} {
				set fnam $qfnam
			} elseif {[info exists chlist]} {
				set qfnam [file rootname [lindex $chlist 0]]	;#	Look for a soundfile with same name and dir as mixfile
				append qfnam $evv(SNDFILE_EXT)
				if {[file exists $qfnam]} {
					set msg "Use output file '$qfnam' ??"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set fnam $qfnam
					} else {
						return 0
					}
				} else {
					Inf "No output file exists"
					return 0
				}
			} else {
				Inf "No output file exists"
				return 0
			}
		} else {
			Inf "No sound selected"
			return 0
		}
	} else {
		if {[llength $i] > 1} {
			Inf "Select Just One Sound"
			return 0
		}
		set line [$m_list get $i]
		set line [string trim $line]
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {![info exists nuline]} {
			Inf "Select A Line In The Display"
			return 0
		}
		set line $nuline
		set fnam [lindex $line 0]
		if {[string match [string index $fnam 0] ";"]} {
			set fnam [string range $fnam 1 end]
			if {![file exists $fnam]} {
				Inf "You Have Selected A Comment Line With No Playable Soundfile"
				return 0
			}
		}
	}
	switch -- $typ {
		"play" -
		"view" -
		"dur" {
			if {![file exists $fnam]} {
				Inf "File $fnam Does Not Exist"
				return 0
			} else {
				set ftyp [FindFileType $fnam]
				if {($ftyp == -1) || !($ftyp == $evv(SNDFILE))} { 
					Inf "The File $fnam Is Not A Soundfile"
					return 0
				}
				switch -- $typ {
					"play" { 
						PlaySndfile $fnam 0 
					}
					"view" { 
						SnackDisplay $evv(SN_TIMEDIFF) qikedit2 0 $fnam
					}
					"dur"   {
						if {![info exists pa($fnam,$evv(DUR))]} {
							Inf "Sound Is Not On The Workspace: Cannot Determine Its Duration." 
							return 0
						}
						set msg "Duration = $pa($fnam,$evv(DUR))\n\nPut Duration In 'Value' Box ??"
						set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
						if {$choice == "yes"} {
							set mixval $pa($fnam,$evv(DUR))
						}
						raise .mixdisplay2
					}
				}
			}
		}
		"stt" -
		"end" -
		"calcv" -
		"calcs" {
			set time [lindex $line 1]
			if {![IsNumeric $time] || ($time < 0.0)} {
				Inf "Selected Line Does Not Have A Time Value"
				return 0
			}
			switch -- $typ {
				"stt" {
					set prm(0) $time
					if {$time != 0.0} {
						set qikwhole 0
						ColourWholeMixButton
					}
					Inf "Mix Starttime reset to $prm(0)"
				} 
				"end" {
					set prm(1) $time
					set qikwhole 0
					ColourWholeMixButton
					Inf "Mix Endtime reset to $prm(1)"
				}
				"calcv" {
					set qikval $time
				}
				"calcs" {
					set qikstor $time
				}
			}
		}
	}
	return 1
}

################################################
#	GETTING SOUNDS TO OR FROM THE QIKEDIT MIX  #
################################################

#------ Getting specified QikEdit Lines to a submix, or sound-therein to wkspace

proc QikEditGet {ismix} {
	global m_list ch chlist wl chcnt pr12_34 pr_qiksubmix qiksubfnam evv wstk qegreturn
	global mm_multichan mlsthead qe_last_sel mixrestorename initial_mlst mlst

	set qegreturn 0
	set ilist [$m_list curselection]
	if {([llength $ilist] <= 0) || ([lindex $ilist 0] < 0)} {
		Inf "No Sound Selected"
		return
	}
	foreach i $ilist {
		set line [$m_list get $i]
		set line [string trim $line]
		set orig_line $line
		set line [split $line]
		foreach fnam $line {
			set fnam [string trim $fnam]
			if {[llength $fnam] > 0} {
				if {[string match [string index $fnam 0] ";"]} {
					set fnam [string range $fnam 1 end]
					if {![file exists $fnam]} {
						set badlines 1
						break
					}
				} elseif {![file exists $fnam]} {
					lappend badfiles $fnam
					break
				}
				set ftyp [FindFileType $fnam]
				if {($ftyp == -1) || !($ftyp == $evv(SNDFILE))} { 
					lappend badfiles $fnam
					break
				}
				lappend outlist $fnam
				lappend outlines $orig_line
				break
			}
		}
	}
	if {![info exists outlist]} {
		if {[info exists badfiles]} {
			set msg "The Sounds You Selected Are Not Currently Existing Soundfiles"
		} elseif {[info exists badlines]} {
			set msg "The Lines You Selected Are All Comment Lines"
		}
		Inf $msg
		return
	}
	if {[info exists badfiles]} {
		set cnt 0
		set msg "The Following Files Are Not Currently Existing Soundfiles\n\n"
		foreach fnam $badfiles {
			incr cnt
			if {$cnt > 20} {
				append msg "\n\nAnd More"
				break
			}
			append msg $fnam "  "
		}
		append msg "\n\nDo You Wish To Proceed ??"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			return
		}
	}
	catch {unset badfiles}
	set cnt 0
	set len [llength $outlist]
	if {$ismix} {
		set f .qiksubmix
		if [Dlg_Create $f "SUBMIX NAME" "set pr_qiksubmix 0" -width 80 -borderwidth $evv(SBDR)] {
			set b0 [frame $f.b0 -borderwidth $evv(SBDR)]
			set b1 [frame $f.b1 -borderwidth $evv(SBDR)]
			button $b0.cr -text "Create" -command {set pr_qiksubmix 1} -highlightbackground [option get . background {}]
			button $b0.qu -text "Abandon" -command {set pr_qiksubmix 0} -highlightbackground [option get . background {}]
			pack $b0.cr -side left
			pack $b0.qu -side right
			label $b1.ll -text "Submix name "
			entry $b1.e -textvariable qiksubfnam -width 16
			pack $b1.ll $b1.e -side left
			pack $b0 -side top -fill x -expand true
			pack $b1 -side top -pady 2
#			wm resizable $f 0 0
			bind $f <Escape> {set pr_qiksubmix 0}
			bind $f <Return> {set pr_qiksubmix 1}
		}
		set qiksubfnam ""
		raise $f
		set pr_qiksubmix 0
		set finished 0
		My_Grab 0 $f pr_qiksubmix $f.b1.e
		while {!$finished} {
			tkwait variable pr_qiksubmix
			if {$pr_qiksubmix} {
				if {[string length $qiksubfnam] <= 0} {
					Inf "No Filename Entered"
					continue
				}
				if {![ValidCDPRootname $qiksubfnam]} {
					continue
				}
				set outfnam [string tolower $qiksubfnam]
				if {$mm_multichan} {
					append outfnam [GetTextfileExtension mmx]
				} else {
					append outfnam [GetTextfileExtension mix]
				}
				if {[file exists $outfnam]} {
					Inf "File '$outfnam' Already Exists : Choose A Different Filename"
					continue
				}
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot Open Submix File '$outfnam'"
					continue
				}
				if {$mm_multichan} {
					puts $zit $mlsthead
				}
				foreach line $outlines {
					puts $zit $line
				}
				close $zit
				MixMUpdate $outfnam 1
				FileToWkspace $outfnam 0 0 0 0 1
				set finished 1
			} else {
				set qegreturn 1
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		if {$qegreturn} {
			return
		}
		set msg "Return To Workspace ?"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			return
		}
		set rewrite 0
		set len [llength $initial_mlst]
		if {[llength $mlst] != $len} {
			set rewrite 1
		} else {
			set n 0
			while {$n < $len} {
				catch {unset nuline}
				set line [lindex $mlst $n]
				set origline [lindex $initial_mlst $n]
				set line [split $line]
				foreach item $line  {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				set line $nuline
				catch {unset nuline}
				set origline [split $origline]
				foreach item $origline  {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				set origline $nuline
				if {![string match $origline $line]} {
					set rewrite 1
					break
				}
				incr n
			}
		}
		if {$rewrite} {
			set msg "Save Current State Of Mix ?"
			set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "yes"} {
				set pr12_34 3
			} else {
				set pr12_34 0
			}
		} else {
			set pr12_34 0
		}
		GetNewFilesFromPpg
	} else {
		while {$cnt < $len} {
			set fnam [lindex $outlist $cnt]
			if {([LstIndx $fnam $wl] < 0) && ([FileToWkspace $fnam 0 0 0 1 0] <= 0)} {
				lappend badfiles $fnam
				set outlist [lreplace $outlist $cnt $cnt]				
				incr len -1
			} else {
				incr cnt
			}
		}
		if {[llength $outlist] <= 0} {
			Inf "Cannot Get Any Of The Files To The Workspace"
			return
		} elseif {[info exists badfiles]} {
			set cnt 0
			set msg "Cannot Get The Following Files To The Workspace\n\n"
			foreach fnam $badfiles {
				incr cnt
				if {$cnt > 20} {
					append msg "\n\nAnd More"
					break
				}
				append msg $fnam "  "
			}
		}
		DoChoiceBak
		ClearWkspaceSelectedFiles
		set outlist [RemoveDupls $outlist]
		foreach fnam $outlist {
			lappend chlist $fnam		;#	add to end of list
			$ch insert end $fnam		;#	add to end of display
			incr chcnt
		}
		set rewrite 0
		set len [llength $initial_mlst]
		if {[llength $mlst] != $len} {
			set rewrite 1
		} else {
			set n 0
			while {$n < $len} {
				catch {unset nuline}
				set line [lindex $mlst $n]
				set origline [lindex $initial_mlst $n]
				set line [split $line]
				foreach item $line  {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				set line $nuline
				catch {unset nuline}
				set origline [split $origline]
				foreach item $origline  {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				set origline $nuline
				if {![string match $origline $line]} {
					set rewrite 1
					break
				}
				incr n
			}
		}
		if {$rewrite} {
			set msg "Save Current State Of Mix ?"
			set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "yes"} {
				set pr12_34 3
				if {[llength $ilist] == 1} {
					set qe_last_sel [concat $mixrestorename $ilist]
				}
			} else {
				set pr12_34 0
			}
		} else {
			set pr12_34 0
		}
		GetNewFilesFromPpg
	}
}

#------- Geting soundfiles for QikEditor

proc GetWkspaceFileForQikEdit {multichan} {
	global wl pa pr_gwffqe gwffqe_val chlist qikedsrch dl_sstr_zz evv
	set gwffqe_val ""
	set f .gwffqe
	if [Dlg_Create $f "Files" "set pr_gwffqe 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set c [frame $f.c -borderwidth $evv(SBDR)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		button $b.sel -text  "Select" -command "set pr_gwffqe 1" -width 6 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.sort -text  "Sort" -command "set pr_gwffqe 3"  -width 6 -highlightbackground [option get . background {}]
		button $b.srch -text  "Search for.." -command "set pr_gwffqe 4" -highlightbackground [option get . background {}]
		entry $b.e -textvariable qikedsrch -width 16
		button $b.quit -text "Abandon" -command "set pr_gwffqe 0" -highlightbackground [option get . background {}]
		pack $b.sel $b.sort $b.srch $b.e -side left -padx 2
		pack $b.quit -side right
		label $c.lab -text "SELECT FILE WITH MOUSE-CLICK"
		label $c.lab2 -text "Double-Click to Play Sound"
		pack $c.lab $c.lab2 -side top -pady 1
		Scrolled_Listbox $d.wlst -width 128 -height 32 -selectmode single
		pack $d.wlst -side top -fill both -expand true -pady 2 
		pack $b $c $d -side top -pady 2 -fill x -expand true	
		bind $d.wlst.list <Double-1> {PlaySndonQikEdit .gwffqe.d.wlst.list %y}
		wm resizable $f 0 1
		bind $f <Escape> {set pr_gwffqe 0}
		bind $f <Return> {set pr_gwffqe 1}
	}
	set srate $pa([lindex $chlist 0],$evv(SRATE))
	set mfnam [lindex $chlist 0]
	$f.d.wlst.list delete 0 end
	set cnt 0
	Block "Getting Workspace Files"
	foreach fnam [$wl get 0 end] {
		if {$multichan} {
			if {[info exists pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) \
			&& ($pa($fnam,$evv(SRATE)) == $srate)} {
				lappend the_list $fnam
				lappend the_nams [file tail $fnam]
				incr cnt
			}
		} else {
			if {[info exists pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) \
			&& ($pa($fnam,$evv(CHANS)) == 1) || ($pa($fnam,$evv(CHANS)) == 2) \
			&& ($pa($fnam,$evv(SRATE)) == $srate)} {
				lappend the_list $fnam
				lappend the_nams [file tail $fnam]
				incr cnt
			}
		}
	}
	UnBlock
	if {$cnt == 0} {
		Inf "No Appropriate Soundfiles On Workspace"
		Dlg_Dismiss $f
		return ""
	}
	set orig_list $the_list
	set len [llength $the_list]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n    [lindex $the_nams $n]
		set bignam_n [lindex $the_list $n]
		set m $n
		incr m
		while {$m < $len} {
			set nam_m    [lindex $the_nams $m]
			set bignam_m [lindex $the_list $m]
			if {[string compare $nam_m $nam_n] < 0} {
				set the_nams [lreplace $the_nams $m $m $nam_n]
				set the_nams [lreplace $the_nams $n $n $nam_m]
				set the_list [lreplace $the_list $m $m $bignam_n]
				set the_list [lreplace $the_list $n $n $bignam_m]
				set nam_n $nam_m
				set bignam_n $bignam_m
			} else {
				incr m
			}
		}
		incr n
	}
	foreach fnam $orig_list {
		$f.d.wlst.list insert end $fnam
	}
	set srchat -1
	set lastsrchstr ""
	set is_orig 1
	set pr_gwffqe 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_gwffqe $f.d.wlst.list
	while {!$finished} {
		tkwait variable pr_gwffqe
		switch -- $pr_gwffqe {
			1 -
			2 {
				set i [.gwffqe.d.wlst.list curselection]
				if {$i < 0} {
					Inf "No Soundfile Chosen"
					continue
				}
				set gwffqe_val [.gwffqe.d.wlst.list get $i]
				if {$pr_gwffqe == 2} {
					PlaySndfile $gwffqe_val 0
				} else {
					break
				}
			}
			3 {
				$f.d.wlst.list delete 0 end
				if {$is_orig} {
					foreach fnam $the_list {
						$f.d.wlst.list insert end $fnam
					}
					set is_orig 0
				} else {
					foreach fnam $orig_list {
						$f.d.wlst.list insert end $fnam
					}
					set is_orig 1
				}
				set srchat -1
			}
			4 {
				if {[string length $qikedsrch] <= 0} {
					Inf "No Valid Search-String Entered"
					continue
				}
				set qikedsrch [string tolower $qikedsrch]
				if {![ValidCDPRootname $qikedsrch]} {
					Inf "INVALID SEARCH-STRING ENTERED"
					continue
				}
				set dl_sstr_zz $qikedsrch
				if {[string match $lastsrchstr $qikedsrch]} {
					incr srchat
					if {$srchat >= $len} {
						set srchat 0
					}
				} else {
					set	lastsrchstr $qikedsrch
					set srchat 0
				}
				if {$is_orig} {
					set searchlist $orig_list
				} else {
					set searchlist $the_list
				}
				set srchstt $srchat
				set found 0
				while {!$found} {
					set f_nam [lindex $searchlist $srchat]
					set basf_nam [file rootname [file tail $f_nam]]
					if {[string first $qikedsrch $basf_nam] >= 0} {
						$f.d.wlst.list selection clear 0 end
						$f.d.wlst.list selection set $srchat
						set kk [expr double($srchat)/double($len)]
						$f.d.wlst.list yview moveto $kk
						set gwffqe_val $f_nam
						set found 1
						break
					}
					incr srchat
					if {$srchat >= $len} {
						set srchat 0
					}
					if {$srchat == $srchstt} {
						Inf "No (Further) Match Found"
						break
					}
				}

			}
			0 {
				set gwffqe_val ""
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $gwffqe_val
}

#-------- Adding mixfile to qikedit mixfile 

proc GetWkspaceMfileForQikEdit {} {
	global wl pa pr_gwffqem gwffqe_val chlist qikedsrchm mm_multichan evv
	set gwffqem_val ""
	set f .gwffqem
	if [Dlg_Create $f "MixFiles" "set pr_gwffqem 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set c [frame $f.c -borderwidth $evv(SBDR)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		button $b.sel -text  "Select" -command "set pr_gwffqem 1" -width 6 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.play -text  "View" -command "set pr_gwffqem 2"  -width 6 -highlightbackground [option get . background {}]
		button $b.sort -text  "Sort" -command "set pr_gwffqem 3"  -width 6 -highlightbackground [option get . background {}]
		button $b.srch -text  "Search for.." -command "set pr_gwffqem 4" -highlightbackground [option get . background {}]
		entry $b.e -textvariable qikedsrchm -width 16
		button $b.quit -text "Abandon" -command "set pr_gwffqem 0" -highlightbackground [option get . background {}]
		pack $b.sel $b.play $b.sort $b.srch $b.e -side left -padx 2
		pack $b.quit -side right
		label $c.lab -text "Select File With Mouse-Click"
		pack $c.lab -side top
		Scrolled_Listbox $d.wlst -width 128 -height 32 -selectmode single
		pack $d.wlst -side top -fill both -expand true -pady 2 
		pack $b $c $d -side top -pady 2 -fill x -expand true	
		wm resizable $f 0 1
		bind $f <Escape> {set pr_gwffqem 0}
	}
	set mfnam [lindex $chlist 0]
	$f.d.wlst.list delete 0 end
	set thismix [lindex $chlist 0]
	set cnt 0
	foreach fnam [$wl get 0 end] {
		if {[info exists pa($fnam,$evv(FTYP))]} {
			if {$mm_multichan} {
				if {$pa($fnam,$evv(FTYP)) == $evv(MIX_MULTI)} {
					set the_nam [file tail $fnam]
					if {![string match $thismix $the_nam]} {
						lappend the_list $fnam
						lappend the_nams [file tail $fnam]
						incr cnt
					}
				}
			} elseif {[IsAMixfile $pa($fnam,$evv(FTYP))]} {
				set the_nam [file tail $fnam]
				if {![string match $thismix $the_nam]} {
					lappend the_list $fnam
					lappend the_nams [file tail $fnam]
					incr cnt
				}
			}
		}
	}
	if {$cnt == 0} {
		Inf "No Appropriate Mixfiles On Workspace"
		return ""
	}
	set orig_list $the_list
	set len [llength $the_list]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n    [lindex $the_nams $n]
		set bignam_n [lindex $the_list $n]
		set m $n
		incr m
		while {$m < $len} {
			set nam_m    [lindex $the_nams $m]
			set bignam_m [lindex $the_list $m]
			if {[string compare $nam_m $nam_n] < 0} {
				set the_nams [lreplace $the_nams $m $m $nam_n]
				set the_nams [lreplace $the_nams $n $n $nam_m]
				set the_list [lreplace $the_list $m $m $bignam_n]
				set the_list [lreplace $the_list $n $n $bignam_m]
				set nam_n $nam_m
				set bignam_n $bignam_m
			} else {
				incr m
			}
		}
		incr n
	}
	foreach fnam $orig_list {
		$f.d.wlst.list insert end $fnam
	}
	set srchat -1
	set lastsrchstr ""
	set is_orig 1
	set pr_gwffqem 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_gwffqem $f.d.wlst.list
	while {!$finished} {
		tkwait variable pr_gwffqem
		switch -- $pr_gwffqem {
			1 -
			2 {
				set i [.gwffqem.d.wlst.list curselection]
				if {$i < 0} {
					Inf "No Mixfile Chosen"
					continue
				}
				set gwffqem_val [.gwffqem.d.wlst.list get $i]
				if {$pr_gwffqem == 2} {
					SimpleDisplayTextfile $gwffqem_val
				} else {
					break
				}
			}
			3 {
				$f.d.wlst.list delete 0 end
				if {$is_orig} {
					foreach fnam $the_list {
						$f.d.wlst.list insert end $fnam
					}
					set is_orig 0
				} else {
					foreach fnam $orig_list {
						$f.d.wlst.list insert end $fnam
					}
					set is_orig 1
				}
				set srchat -1
			}
			4 {
				if {[string length $qikedsrchm] <= 0} {
					Inf "No Valid Search-String Entered"
					continue
				}
				set qikedsrchm [string tolower $qikedsrchm]
				if {![ValidCDPRootname $qikedsrchm]} {
					Inf "Invalid Search-String Entered"
					continue
				}
				if {[string match $lastsrchstr $qikedsrchm]} {
					incr srchat
					if {$srchat >= $len} {
						set srchat 0
					}
				} else {
					set	lastsrchstr $qikedsrchm
					set srchat 0
				}
				if {$is_orig} {
					set searchlist $orig_list
				} else {
					set searchlist $this_list
				}
				set srchstt $srchat
				set found 0
				while {!$found} {
					set f_nam [lindex $searchlist $srchat]
					set basf_nam [file rootname [file tail $f_nam]]
					if {[string first $qikedsrchm $basf_nam] >= 0} {
						$f.d.wlst.list selection clear 0 end
						$f.d.wlst.list selection set $srchat
						set kk [expr double($srchat)/double($len)]
						$f.d.wlst.list yview moveto $kk
						set gwffqem_val $f_nam
						set found 1
						break
					}
					incr srchat
					if {$srchat >= $len} {
						set srchat 0
					}
					if {$srchat == $srchstt} {
						Inf "No (Further) Match Found"
						break
					}
				}

			}
			0 {
				set gwffqem_val ""
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $gwffqem_val
}

#################################
#------- TIME GRID OPTION		#
#################################

proc MakeGridVals {} {
	global grid_tempo grid_maxt pr_gridvals tempo_grid evv wstk
	set callcentre [GetCentre [lindex $wstk end]]
	set f .tempogrid
	if [Dlg_Create $f "CREATE LIST OF TIMES" "set pr_gridvals 0" -bd 2] {
		frame $f.0
		frame $f.1
		button $f.0.cre -text "Create Grid" -command "set pr_gridvals 1" -highlightbackground [option get . background {}]
		button $f.0.qui -text "Abandon" -command "set pr_gridvals 0" -highlightbackground [option get . background {}]
		pack $f.0.cre -side left
		pack $f.0.qui -side right
		label $f.1.templ -text "tempo (MM)"
		entry $f.1.tempo -textvariable grid_tempo -width 8
		label $f.1.maxl -text "Max Time"
		entry $f.1.max -textvariable grid_maxt -width 8
		pack $f.1.templ $f.1.tempo $f.1.maxl $f.1.max -side left
		pack $f.1 $f.0 -side top -fill both -expand true -pady 4
		bind $f <Return> {set pr_gridvals 1}
		bind $f <Escape> {set pr_gridvals 0}
	}
#	wm resizable $f 0 0
	set pr_gridvals 0
	set finished 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 1 $f pr_gridvals $f.1.tempo
	wm geometry $f $geo
	while {!$finished} {
		tkwait variable pr_gridvals
		if {$pr_gridvals} {
			if {![IsNumeric $grid_tempo] || ($grid_tempo <= 0)} {
				Inf "Invalid Tempo Value"
				continue
			}
			if {![IsNumeric $grid_maxt] || ($grid_maxt <= 0)} {
				Inf "Invalid Maximum Time"
				continue
			}
			set tempo_grid {}
			set t 0.0000
			set step [expr 60.0 / double($grid_tempo)]
			while {$t <= $grid_maxt} {
				lappend tempo_grid [DecPlaces $t 4]
				set t [expr $t + $step]
			}
		}
		Inf "Created Grid Times At Tempo $grid_tempo Up To Time $grid_maxt"
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetGridVal {} {
	global pr_gridvals2 tempo_grid wstk m_list tempogrid_loc evv
	if {![info exists tempo_grid] || ([llength $tempo_grid] <= 0)} {
		Inf "No Grid Times Created"
		return
	}
	set ilist [$m_list curselection]
	if {[llength $ilist] > 1} {
		Inf "Select A Single Mixfile Line"
		return
	}
	set i [lindex $ilist 0]
	if {$i < 0} {
		Inf "No Line Selected"
		return
	}
	set line [$m_list get $i]
	set line [string trim $line]
	if {[string match [string index $line 0] ";"]} {
		Inf "Comment Line Selected"
		return
	}
	set tempogrid_loc $i
	set callcentre [GetCentre [lindex $wstk end]]
	set f .tempogrid2
	if [Dlg_Create $f "GRID TIMES" "set pr_gridvals2 0" -bd 2] {
		button $f.quit -text "Close" -command "set pr_gridvals2 0" -highlightbackground [option get . background {}]
		label $f.lab -text "Select Time with Mouse"
		Scrolled_Listbox $f.ll -width 64 -height 32 -selectmode single
		pack $f.quit $f.lab $f.ll -side top -pady 4
		bind $f.ll.list <ButtonRelease-1> {SetGridTempoVal %y}
		bind $f <Escape> {set pr_gridvals2 0}
	}
	$f.ll.list delete 0 end
	foreach item $tempo_grid {
		$f.ll.list insert end $item
	}
#	wm resizable $f 0 0
	set pr_gridvals2 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 1 $f pr_gridvals2 $f.ll.list
	wm geometry $f $geo
	tkwait variable pr_gridvals2
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SetGridTempoVal {y} {
	global m_list pr_gridvals2 tempogrid_loc previous_linestore mlst
	set val ""
	set i [.tempogrid2.ll.list nearest $y]
	if {$i >= 0} {
		set val [.tempogrid2.ll.list get $i]
	}
	if {[string length $val] <= 0} {
		return
	}
	set previous_linestore $mlst
	set line [$m_list get $tempogrid_loc]
	set line [string trim $line]
	set line [split $line]
	set cnt 0
	foreach item $line {
		set item [string trim $item]
		if {[llength $item] > 0} {
			if {$cnt == 1} {
				lappend nuline $val
			} else {
				lappend nuline $item
			}
			incr cnt
		}
	}
	$m_list delete $tempogrid_loc
	$m_list insert $tempogrid_loc $nuline
	set mlst [lreplace $mlst $tempogrid_loc $tempogrid_loc $nuline]
	set pr_gridvals2 0
}

##############################################
#---- FUNCTIONS ON PARAM(S) IN LINE  MENU	 #
##############################################

proc MixfileLinevalToVal {typ} {
	global mixval m_list done_maxsamp maxsamp_line qiksync CDPmaxId pa wstk mm_multichan evv submixtime

	set i [$m_list curselection]
	switch -- $typ {
		"number" {
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select a mixfile line"
				return
			}
			set mixval [expr $i + 1]
			return
		}
		"time" {
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select A Mixfile Line"
				return
			}
			set line [$m_list get $i]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Time In Muted Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$cnt} {
						if {![IsNumeric $item] || ($item < 0.0)} {
							Inf Invalid Time Value In Line"
							return
						}
						set mixval $item
						return
					}
					incr cnt
				}
			}
			if {$cnt < 2} {
				Inf "No Valid Time Value Found"
				return
			}
		}
		"add" {
			if {![info exists mixval] || ([string length $mixval] <= 0) || ![IsNumeric $mixval]} {
				Inf "Non-numeric value in value box"
				return
			}
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select a mixfile line"
				return
			}
			set line [$m_list get $i]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use time in muted line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$cnt} {
						if {![IsNumeric $item] || ($item < 0.0)} {
							Inf "Invalid time value in line"
							return
						}
						set mixval [expr $mixval + $item]
						return
					}
					incr cnt
				}
			}
			if {$cnt < 2} {
				Inf "No valid time value found"
				return
			}
		}
		"memtimeset" {
			set mintime 100000
			foreach line [$m_list get 0 end] {
				if {[string match [string index $line 0] "\{"]} {
					set line [StripCurlies $line]
				}
				if {[string match ";" [string index $line 0]]} {
					continue
				} else {
					set line [split $line]
					set cnt 0
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						switch -- $cnt {
							1 {
								if {$item < $mintime} {
									set mintime $item
								}
								break
							}
						}
						incr cnt
					}
				}
			}
			if {$mintime == 100000} {
				Inf "Failed To Find Start Time Of Mix"
				return
			} elseif {$mintime == 0} {
				set msg "Submix Starts At Time Zero : Remember This Anyway ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set submixtime $mintime
			Inf "Start Time $submixtime Remembered"
		}
		"memtimerecall" {
			if {![info exists submixtime]} {
				Inf "No Submix Start Time Remembered"
				return
			}
			set mixval $submixtime
		}
		"timend" {
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select A Mixfile Line"
				return
			}
			set line [$m_list get $i]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Time In Muted Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					switch -- $cnt {
						0 {
							if {[string match [string index $item 0] ";"]} {
								set item [string range $item 1 end]
							}
							if {![file exists $item]} {
								Inf "No Valid Soundfile Found"
								return
							}
							if {![info exists pa($item,$evv(FTYP))]} {
								Inf "Soundfile Is Not On The Workspace: Cannot Determine End Time Of File"
								return
							}
							if {$pa($item,$evv(FTYP)) != $evv(SNDFILE)} {
								Inf "File On Line Is Not A Soundfile"
								return
							}
							set dur $pa($item,$evv(DUR))
						}
						1 {
							if {[IsNumeric $item] && ($item >= 0.0)} {
								set time $item
							} else {
								Inf "No Valid Time Value Found"
								return
							}
							set mixval [expr $time + $dur]
							return
						}
						default {
							return
						}	
					}
					incr cnt
				}
			}
			if {$cnt < 2} {
				Inf "No Valid Time Value Found"
				return
			}
		}
		"mixend" {
			set maxend_val 0
			foreach line [$m_list get 0 end] {
				if {[string match [string index $line 0] ";"]} {
					continue
				}
				set line [split $line]
				set cnt 0
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						switch -- $cnt {
							0 {
								if {![file exists $item]} {
									Inf "File $item does not exist"
									return
								}
								if {![info exists pa($item,$evv(FTYP))]} {
									Inf "File $item is not on the workspace: cannot determine end time of file"
									return
								}
								set dur $pa($item,$evv(DUR))
							}
							1 {
								if {[IsNumeric $item] && ($item >= 0.0)} {
									set time $item
								} else {
									Inf "No valid time value found for file $item "
									return
								}
								set end_val [expr $time + $dur]
								if {$end_val > $maxend_val} {
									set maxend_val $end_val
								}
							}
							default {
								break
							}	
						}
						incr cnt
					}
				}
			}
			if {$maxend_val <= 0} {
				Inf "No output duration found"
				return
			}
			set mixval $maxend_val
		}
		"timemark" {
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select A Mixfile Line"
				return
			}
			set line [$m_list get $i]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Time In Muted Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$cnt} {
						if {![IsNumeric $item] || ($item < 0.0)} {
							Inf "Invalid Time Value In Line"
							return
						}
						set starttime $item
						break
					} else {
						set fnam $item
					}
					incr cnt
				}
			}
			if {$cnt != 1} {
				Inf "No Valid Start-Time Value Found In Line"
				return
			}
			SnackDisplay $evv(SN_SINGLETIME) qikedit3 0 $fnam
			if {![info exists qiksync]} {
				set mixval ""
			} else {
				set mixval [DecPlaces [expr $starttime + $qiksync] 4]
			}
			return
		}
		"timediff" {
			if {[llength $i] != 2} {
				Inf "Select Two Mixfile Lines"
				return
			}
			set line0 [$m_list get [lindex $i 0]]
			set gotmute 0
			if {[string match [string index $line0 0] ";"]} {
				set msg "Use Time In Muted Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
				set gotmute 1
			}
			set line1 [$m_list get [lindex $i 1]]
			if {[string match [string index $line1 0] ";"]} {
				if {!$gotmute} {
					set msg "Use Time In Muted Line ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if [string match no $choice] {
						return
					}
				}
			}
			set line0 [split $line0]
			set cnt 0
			foreach item $line0 {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$cnt} {
						set val0 $item
						break
					}
					incr cnt
				}
			}
			if {![info exists val0]} {
				Inf "No Start-Time Information In First Line"
				return
			}
			if {![IsNumeric $val0] || ($val0 < 0.0)} {
				Inf "Invalid Time ($val0) In First Line"
				return
			}
			set line1 [split $line1]
			set cnt 0
			foreach item $line1 {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$cnt} {
						set val1 $item
						break
					}
					incr cnt
				}
			}
			if {![info exists val1]} {
				Inf "No Start-Time Information In Second Line"
				return
			}
			if {![IsNumeric $val1] || ($val1 < 0.0)} {
				Inf "Invalid Time ($val1) In Second Line"
				return
			}
			set diff [expr double($val1) - double($val0)]
			if {$diff < 0.0} {
				set diff [expr -$diff]
			}
			set mixval $diff
		}
		"timendiff" {
			if {[llength $i] != 2} {
				Inf "Select Two Mixfile Lines"
				return
			}
			set line [$m_list get [lindex $i 0]]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Time In Muted (First) Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					switch -- $cnt {
						0 {
							if {[string match [string index $item 0] ";"]} {
								set item [string range $item 1 end]
							}
							if {![file exists $item]} {
								Inf "No Valid Soundfile Found In First Line"
								return
							}
							if {![info exists pa($item,$evv(FTYP))]} {
								Inf "Soundfile In First Line ($item) Not On The Workspace: Cannot Determine End Time Of File"
								return
							}
							if {$pa($item,$evv(FTYP)) != $evv(SNDFILE)} {
								Inf "File On First Line ($item) Is Not A Soundfile"
								return
							}
							set dur $pa($item,$evv(DUR))
						}
						1 {
							if {[IsNumeric $item] && ($item >= 0.0)} {
								set time $item
							} else {
								Inf "No Valid Time Value Found On First Line"
								return
							}
							set endtime1 [expr $time + $dur]
						}
					}
					incr cnt
					if {$cnt == 2} {
						break
					}
				}
			}
			if {$cnt < 2} {
				Inf "No Valid Time Value Found On First Line"
				return
			}
			set line [$m_list get [lindex $i 1]]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Time In Muted (Second) Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					switch -- $cnt {
						0 {
							if {[string match [string index $item 0] ";"]} {
								set item [string range $item 1 end]
							}
							if {![file exists $item]} {
								Inf "No Valid Soundfile Found In Second Line"
								return
							}
							if {![info exists pa($item,$evv(FTYP))]} {
								Inf "Soundfile In Second Line ($item) Not On The Workspace: Cannot Determine End Time Of File"
								return
							}
							if {$pa($item,$evv(FTYP)) != $evv(SNDFILE)} {
								Inf "File On Second Line ($item) Is Not A Soundfile"
								return
							}
							set dur $pa($item,$evv(DUR))
						}
						1 {
							if {[IsNumeric $item] && ($item >= 0.0)} {
								set time $item
							} else {
								Inf "No Valid Time Value Found On Second Line"
								return
							}
							set endtime2 [expr $time + $dur]
						}
					}
					incr cnt
					if {$cnt == 2} {
						break
					}
				}
			}
			if {$cnt < 2} {
				Inf "No Valid Time Value Found On Second Line"
				return
			}
			set outval [expr $endtime2 - $endtime1]
			if {$outval < 0.0} {
				Inf "First File Ends After Second"
				set outval [expr -$outval]
			}
			set mixval $outval
		}
		"timediff2" -
		"timesum" {
			if {![IsNumeric $mixval]} {
				Inf "No (Valid) Time Value In 'value' Box"
				return
			}
			if {[llength $i] != 1} {
				Inf "Select One Mixfile Line"
				return
			}
			set line [$m_list get [lindex $i 0]]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Time In Muted Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$cnt} {
						if {![IsNumeric $item] || ($item < 0.0)} {
							Inf "Invalid Time In Line"
							return
						}
						set val $item
						break
					}
					incr cnt
				}
			}
			if {![info exists val]} {
				Inf "No Start-Time Information In Line"
				return
			}
			if {$typ == "timesum"} {
				set val [expr double($mixval) + double($val)]
			} else {
				set val [expr double($mixval) - double($val)]
				if {$val < 0.0} {
					set val [expr -$val]
				}
			}
			set mixval $val
		}
		"level" {
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select A Mixfile Line"
				return
			}
			set line [$m_list get $i]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Level In Muted Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$mm_multichan} {
						if {($cnt > 3) && [IsEven $cnt]} {
							if {![IsNumeric $item] || ($item < 0.0)} {
								Inf "Invalid Level In Line"
								return
							}
							if {![info exists val]} {
								set val $item
							} elseif {![Flteq $val $item]} {
								Inf "Level Ambiguous: Multichannel File"
								return
							}
						}
					} else {
						if {$cnt == 3} {
							if {![IsNumeric $item] || ($item < 0.0)} {
								Inf "Invalid Level In Line"
								return
							}
							set val $item
						}
						if {$cnt == 5} {
							if {![IsNumeric $item] || ($item < 0.0)} {
								Inf "Invalid Level In Line"
								return
							}
							if {$val != $item} {
								Inf "Level Ambiguous: Stereo File"
								return
							}
						}
					}
					incr cnt
				}
			}
			if {![info exists val]} {
				Inf "No Level Value In Line"
				return
			}
			set mixval $val
		}
		"pos" {
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select A Mixfile Line"
				return
			}
			set line [$m_list get $i]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Position In Muted Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set cnt 0
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$mm_multichan} {
					if {$cnt >= 3} {
						lappend val $item
					}
				} else {
					if {$cnt == 4} {
						if {![IsNumeric $item] && !(($item == "C") || ($item == "L") || ($item == "R"))} {
							Inf "Invalid Position ($item) Value In Line"
							return
						}
						if {[IsNumeric $item] && (($item < -1.0) || ($item > 1.0))} {
							Inf "Invalid Position ($item) Value In Line"
							return
						}
						set val $item
					}
					if {$cnt == 6} {
						if {![IsNumeric $item] && !(($item == "C") || ($item == "L") || ($item == "R"))} {
							Inf "Invalid Position ($item) Value In Line"
							return
						}
						if {[IsNumeric $item] && (($item < -1.0) || ($item > 1.0))} {
							Inf "Invalid Position ($item) Value In Line"
							return
						}
						if {$val != $item} {
							Inf "Position Ambiguous: Stereo File"
							return
						}
					}
				}
				incr cnt
			}
			if {![info exists val]} {
				Inf "No Position Information In Line"
				return
			}
			set mixval $val
		}
		"norm2" -
		"norm" {
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select A Mixfile Line"
				return
			}
			set line [$m_list get $i]
			if {[string match [string index $line 0] ";"]} {
				set msg "Use Muted Line ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					return
				}
			}
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					set fnam $item
					break
				}
			}
			if {![info exists fnam]} {
				Inf "No Filename In Line"
				return
			}
			if {[string match [string index $fnam 0] ";"]} {
				set fnam [string range $fnam 1 end]
			}
			if {![file exists $fnam]} {
				Inf "File '$fnam' No Longer Exists"
				return
			}
			set ftyp [FindFileType $fnam]
			if {$ftyp != $evv(SNDFILE)} {
				Inf "File '$fnam' Is Not A Soundfile"
				return
			}
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			if [info exists maxsamp_missing] {
				Inf "maxsamp2$evv(EXEC) Is Not On Your System.\nCannot Search File For Maximum Sample In File."
				return
			} else {
				if [ProgMissing $cmd "Cannot search file for maximum sample in file."] {
					set maxsamp_missing 1
					return
				}
			}
			set done_maxsamp 0
			catch {unset maxsamp_line}
			lappend cmd $fnam
			if {$typ == "norm2"} {
				lappend cmd 1
			}
			if [catch {open "|$cmd"} CDPmaxId] {
				ErrShow "$CDPmaxId"
				return
   			} else {
   				fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
			}
 			vwait done_maxsamp
			catch {close $CDPmaxId}
			set n 0
			if {![info exists maxsamp_line]} {
				Inf "No Maximum Sample Information Retrieved"
				return
			}
			set maxsamp [lindex $maxsamp_line 0]
			if {$maxsamp <= 0.0} {
				Inf "Sound at zero level: cannot normalise"
				return
			}
			set mixval [expr (1.0/$maxsamp) - 0.01]
		}
	}
}

#############################
#--- QIKEDITOR TIME TAP		#
#############################

proc MixTime {} {
	global tap_on tap_t wstk mixval evv mixd2

	set tap_t($tap_on) [clock clicks]
	incr tap_on
	if {$tap_on > 1} {
		$mixd2.1.see.000.tap config -state disabled -bg [option get . background {}]
		set tap_on 0
		set secs [expr (double($tap_t(1) - $tap_t(0))) / $evv(CLOCK_TICK)]
		set durmsg "Duration $secs secs"
		if {[IsNumeric $mixval] && ($mixval >= 0.0)} {
			set msg "$durmsg: You Can Put This Time In The Value Box ~OR~ Add It To The Value In The Value Box\n\n"
			append msg "~ADD~ This Time To Value In Value Box ??"
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set mixval [expr $mixval + $secs]
				$mixd2.1.see.000.tap config -state normal
				return
			}
		}
		set msg "$durmsg: Put Time In Value Box ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set mixval $secs
		}
		$mixd2.1.see.000.tap config -state normal
	} else {
		$mixd2.1.see.000.tap config -bg $evv(EMPH)
	}
}

#################################################
#--- VIEW SOUND OUTPUT OF MIX ON QIKEDIT PAGE	#
#################################################

proc QikOutView {view} {
	global chlist lastmixio sn wstk wl pa evv qikaborig mixd2 qikoffset prm
	set qikoffset 0
	catch {unset qikaborig}
	set fnam $evv(DFLT_OUTNAME)												;#	First look for file output from current use of MIX process
	append fnam 0 $evv(SNDFILE_EXT)
	set orig_fnam $fnam
	set nofile_yet 0
	Block "Getting File"
	if {![file exists $fnam]} {												;#	If there is one, use it, else
		set nofile_yet 1
		if {[info exists lastmixio]} {
			if {[string match [lindex $chlist 0] [lindex $lastmixio 0]]} {	;#	If mixfile used in previous call to mixing-process was same as this one
				set fnam [lindex $lastmixio 1]								;#	look for output of that previous call
				if {[file exists $fnam]} {									;#	And if it exists, use it	
					catch {file copy $fnam $orig_fnam}
					set nofile_yet 0
				} else {													;#	But if the file produced then no longer exists
					catch {unset lastmixio}									;#	delete the 'lastmixio' info
				}															
			} else {														;#	Or if we're not using the same mixfile as previously
				catch {unset lastmixio}										;#	also delete the 'lastmixio' info	
			}
		}
		if {$nofile_yet} {													;#	If still not found an appropriate output file
			set fnam [file rootname [lindex $chlist 0]]						;#	Look for a soundfile with same name and dir as mixfile
			append fnam $evv(SNDFILE_EXT)
			if {[file exists $fnam]} {
				set msg "Use Output File '$fnam' ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					catch {file copy $fnam $orig_fnam}
					set nofile_yet 0
				}
			}
			if {$nofile_yet} {												;#	Then look for any soundfile with same name as mixfile	
				set fnam [file tail $fnam]									;#	in base directory
				foreach wfnam [$wl get 0 end] {
					if {($pa($wfnam,$evv(FTYP)) == $evv(SNDFILE)) && [string match [file tail $wfnam] $fnam]} {
						set msg "Use Output File '$wfnam' ??"
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set fnam $wfnam
							catch {file copy $fnam $orig_fnam}
							set nofile_yet 0
							break
						}
					}
				}
			}
			if {$nofile_yet} {												;#	Then look for any soundfile starting with same name as mixfile	
				set fnam [file rootname [file tail $fnam]]					;#	in base directory
				foreach wfnam [$wl get 0 end] {
					if {$pa($wfnam,$evv(FTYP)) == $evv(SNDFILE)} {
						if {[string first $fnam [file tail $wfnam]] == 0} {
							set msg "Use Output File '$wfnam' ??"
							set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								set fnam $wfnam
								catch {file copy $fnam $orig_fnam}
								set nofile_yet 0
								break
							} else {
								break
							}
						}
					}
				}
			}
			if {!$nofile_yet} {
				set qikaborig 1
			}
		}
	} elseif {$prm(0) > 0.0} {
		set qikoffset $prm(0) 
	}

	if {$nofile_yet} {
		Inf "No Mix Output To View"
		focus $mixd2.1.see.1.seefile
		UnBlock
		return
	}
	if {$view} {
		if {![info exists pa($fnam,$evv(FTYP))]} {
			if {[DoParse $fnam 0 0 0] <= 0} {
				focus $mixd2.1.see.1.seefile
				UnBlock
				return
			}
		}
		UnBlock
		SnackDisplay $evv(SN_TIMEDIFF) qikedit 0 $fnam
	} else {
		UnBlock
		PlaySndfile $fnam 0
	}
	focus $mixd2.1.see.1.seefile
}

#########################################
#---- RESTORING PREVIOUS MIX STATES		#
#########################################

proc MixRestore {orig} {
	global mixrestorename origmixbak pr12_34 wstk evv initial_mlst mm_multichan mlsthead
	global fileId prm mlst m_list qiki_main qiki qikclik qikmixdur pa origmixdur is_the_main last_main_qikparams last_qikparams last_qikfnam

	if {$orig} {
		if {![file exists $origmixbak] } {
			Inf "Original Version Of Mix Does Not Exist"
			return
		}
		set msg "This Operation Abandons ~All~ Mixfile Edits Made\n"
		append msg "On This Call To The Mixing Program.\n\n"
		append msg "Use 'Abandon (No Edit)' Button To Abandon Only Current Edits.\n\n"
		append msg "Abandon ~All~ Mixfile Edits Made, And Restore Original ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if [string match no $choice] {
			return
		}
	} else {
		set msg "Are You Sure You Want To Restore The Initial State Of The Mix ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if [string match no $choice] {
			return
		}
	}
	if {$orig} {
		if {![file exists $origmixbak]} {
			Inf "CANNOT RESTORE ORIGINAL MIX."
			return
		}
	} else {
		set origfnam $evv(DFLT_TMPFNAME)				;#	Look for copy of pre-qikedit-session version of mixfile, made if any (edited) mix has since been run
		append origfnam 0 $evv(TEXT_EXT)
		if {![file exists $origfnam]} {					;#	If no edit has been run, there is no saved file-copy of the original,
			set mlst $initial_mlst						;#  And the file at start of this QikEdit session has not yet been overwritten,
			DisplayMixlist 0							;#  but we know the initial state of the list
			return
		}
	}
	if [catch {file delete $mixrestorename} zat] {
		Inf "Cannot Delete Updated Version Of Mix"
		return
	}
	if {$orig} {
		if [catch {file	copy $origmixbak $mixrestorename} zat] {
			set msg "Cannot Restore Name Of Original Mix.\n"
			append msg "Original Mix Is In File '$origmixbak'.\n"
			append msg "Rename It NOW (Outside The Loom) Before Proceeding, Or It Will Be Deleted."
			Inf $msg
		}
	} else {
		if [catch {file rename $origfnam $mixrestorename} zit] {
			Inf "Cannot Rename Mixfile To Its Original Name:\nData Is In File '$origfnam,\n\nRename This ~~NOW~~ Outside The Loom\nOr You Will Lose It"
		} elseif {$prm(1) > $origmixdur} {
			set prm(1) $origmixdur
		}
		catch {PurgeArray $origfnam}
	}
	set msg "Quit The Mix Page ??"
	set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
	if [string match yes $choice] {
		set pr12_34 2						;#	Return to parampage
		return
	}
	$m_list delete 0 end
	catch {unset mlst}
	set fnam $mixrestorename
	if [catch {open $fnam r} fileId] {
		Inf "Cannot Open Original Mixfile"	;#	If textfile cannot be opened
		set pr12_34 2						;#	Return to parampage
		return
	}
	if {[info exists main_mix(fnam)] && [string match $mixrestorename $main_mix(fnam)]} {
		set is_the_main 1
	} else {
		set is_the_main 0
	}
	if {$is_the_main} {
		if {[info exists last_main_qikparams]} {
			set prm(0) [lindex $last_main_qikparams 0]
			set prm(1) [lindex $last_main_qikparams 1]
			set prm(2) [lindex $last_main_qikparams 2]
		}
	} elseif {[info exists last_qikfnam] && [string match $fnam $last_qikfnam]} {
		if {[info exists last_qikparams]} {
			set prm(0) [lindex $last_qikparams 0]
			set prm(1) [lindex $last_qikparams 1]
			set prm(2) [lindex $last_qikparams 2]
		}
	} 
	while { [gets $fileId thisline] >= 0} {			;#	Read lines from textfile into text-listing
		set thisline [split $thisline]
		set k [llength $thisline]
		set n 0
		while {$n < $k} {		
			set item [string trim [lindex $thisline $n]]
			if {[string length $item] <= 0} {
				set thisline [lreplace $thisline $n $n]
				incr  k -1
			} else { 
				if {$n==0} {
					set item [RegulariseDirectoryRepresentation $item]
					set thisline [lreplace $thisline 0 0 $item]
				}
				incr n
			}
		}
		if {[llength $thisline] > 0} {
			lappend mlst $thisline
		}
	}
	if {$mm_multichan} {
		set mlsthead [lindex $mlst 0]
		set mlst [lrange $mlst 1 end]
	}
	close $fileId
	DisplayMixlist 0

	if {$prm(0) > 0.0} {		;#	Scroll display to relevant area
		set linecnt 0
		set gotline -1
		foreach line $mlst {
			if {[string match [string index $line 0] ";"]} {
				incr linecnt
				continue
			}
			set cnt 0
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt == 1} {
					if {$item >= $prm(0)} {
						set gotline $linecnt
					}
					break
				}
				incr cnt
			}
			if {$gotline >= 0} {
				break
			}
			incr linecnt
		}
		if {$gotline >= $evv(QIKEDITLEN)} {
			set k [expr double($gotline) / double([llength $mlst])]
			$m_list yview moveto $k
		}
	}
	if {$is_the_main} {
		if {[info exists qiki_main]} {
			set qiki $qiki_main				;#	Establish qiki tied to main_mix, if this is main_mix
		}
	}
	if {[info exists qiki]} {					;#	Establish if cliktrak line still exists
		if {$qiki >= [llength $mlst]} {
			unset qiki
		} else {
			set line [$m_list get $qiki]
			if {[string match [string index $line 0] ";"]} {
				set line [string range $line 1 end]
			}
			if {![string match $line $qikclik]} {
				unset qiki
			}
		}
	}
	set qikmixdur $pa($mixrestorename,$evv(DUR))
	set origmixdur $qikmixdur
	ColourWholeMixButton
}

#################################
#--- SEARCHES ON QIK EDITOR		#
#################################

proc SearchQikEdit {again} {
	global m_list pr_qefilfnd qefilstr total_wksp_cnt qeig qeigm evv

	if {$again} {
		if {[info exists qefilstr]} {
			QeFileSearch $qefilstr
		} else {
			Inf "No Previous Search Made"
		}
		return
	} else {
		$m_list selection clear 0 end
	}
	set f .qefile_find
	if [Dlg_Create $f "FIND FILE" "set pr_qefilfnd 0" -width 80 -borderwidth $evv(SBDR)] {
		set b1 [frame $f.b1 -borderwidth $evv(SBDR)]
		set b0 [frame $f.b0 -borderwidth $evv(SBDR)]
		set b2 [frame $f.b2 -borderwidth $evv(SBDR)]
		button $b1.se -text Search -command {set pr_qefilfnd 1} -highlightbackground [option get . background {}]
		button $b1.dum -text "" -command {} -bd 0 -width 20 -highlightbackground [option get . background {}]
		button $b1.qu -text Close -command {set pr_qefilfnd 0} -highlightbackground [option get . background {}]
		pack $b1.se $b1.dum -side left -pady 1
		pack $b1.qu -side right -pady 1
		label $b0.l -text "STRING TO MATCH"
		pack $b0.l -side top -pady 1
		entry $b0.e -textvariable qefilstr -width 16
		pack $b0.e -side top -pady 1
		checkbutton $b2.ig -variable qeig -text "Ignore directory pathname"
		checkbutton $b2.igm -variable qeigm -text "Ignore muted lines"
		pack $b2.ig $b2.igm -side top -pady 2
		pack $b1 $b0 $b2 -side top -fill x -expand true
#		wm resizable $f 0 0
		bind $f <Escape> {set pr_qefilfnd 0}
	}
	set qeig 1
	set qeigm 1
	raise $f
	set pr_qefilfnd 0
	set finished 0
	My_Grab 0 $f pr_qefilfnd $f.b0.e
	while {!$finished} {
		tkwait variable pr_qefilfnd
		if {$pr_qefilfnd} {
			if {[QeFileSearch $qefilstr]} {
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Search for a file on the Qikedit listing

proc QeFileSearch {str} {
	global m_list qeig qeigm
	set len [$m_list index end]
	if {[string length $str] <= 0} {
		Inf "No Search String Entered"
		return 0
	} elseif {[regexp {[^A-Za-z0-9\-\_]+} $str]} {
		Inf "Invalid Characters In Search String '$str'\n\nYou cannot use directory paths or file extensions here."
		return 0
	}
	set ilist [$m_list curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		set start 0
	} else {
		set start [lindex $ilist end]
		incr start
		if {$start >=  $len} {
			set start 0 
		}
	}
	set i $start
	foreach line [$m_list get $start end] {
		set fnam [lindex $line 0]
		if {$qeigm && [string match [string index $fnam 0] ";"]} {
			incr i
			continue
		}
		if {$qeig} {
			set fnam [file tail $fnam]
		}
		if {[string first [string tolower $str] [string tolower $fnam]] >= 0} {
			$m_list selection clear 0 end
			$m_list selection set $i
			$m_list yview moveto [expr double($i)/double([$m_list index end])]
			return 1
		}
		incr i
	}
	if {$start != 0} {
		set end $start
		set i 0
		foreach line [$m_list get 0 $end] {
			set fnam [lindex $line 0]
			if {$qeigm && [string match [string index $fnam 0] ";"]} {
				incr i
				continue
			}
			if {$qeig} {
				set fnam [file tail $fnam]
			}
			if {[string first [string tolower $str] [string tolower $fnam]] >= 0} {
				$m_list selection clear 0 end
				$m_list selection set $i
				$m_list yview moveto [expr double($i)/double([$m_list index end])]
				return 1
			}
			incr i
		}
	}
	Inf "Cannot Find Any File Whose Name Contains The String '$str'"
	return  0
}

proc GotoTimeQik {} {
	global mixval m_list mlst evv
	if {([string length $mixval] <= 0) || ![IsNumeric $mixval] || ($mixval < 0.0)} {
		Inf "Invalid Value For Time"
		return
	}
	$m_list selection clear 0 end
	set i 0
	foreach line $mlst {
		set thistime [lindex $line 1]
		if {$thistime >= $mixval} {
			break
		}
		incr i
	}
	if {![info exists thistime]} {
		$m_list yview moveto 1.0
		$m_list selection set end
		return
	}
	if {$thistime != $mixval}  {
		incr i -1
		if {$i < 0} {
			set i 0
		}
	}
	$m_list selection set $i
	set k [llength $mlst]
	if {$i >= $evv(QIKEDITLEN)} {
		set k [expr double($i) / double($k)]
		$m_list yview moveto $k
	}
}

#########################################################
#	ADJUSTMENTS BETWEEN QIKEDIT PAGE AND PARAMS PAGE	#
#########################################################

#------- Transfer endtime of mix (as defined on parameters page) to value box in QikEditor

proc MixEndValQik {time} {
	global mixrestorename prm mixval main_mix wl pa evv m_list
	if {$time} {
		set fnam $evv(DFLT_OUTNAME)
		append fnam 0 $evv(SNDFILE_EXT)
		if {![file exists $fnam]} {
			if {![info exists main_mix] || ![string match $main_mix(fnam) $mixrestorename]} {
				Inf "No Outfile Created Yet"
				return
			} else {
				set fnam $main_mix(fnam)
				set k [LstIndx $fnam $wl]
				if {$k < 0} {
					Inf "'$fnam' Is Not On The Workspace"
					return
				}
			}
		}
		if {![info exists pa($fnam,$evv(DUR))]} {
			Inf "Unknown"
			return
		}
		if {$time == 2} {
			set mixval $pa($fnam,$evv(DUR))
			return
		}
		set mintime 100000
		foreach line [$m_list get 0 end] {						;#	IF first time in mix is not zero
			if {[string match [string index $line 0] ";"]} {	;#	This must be added to outdur, to get coords relative to mix
				continue
			}
			set line [string trim $line]
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt} {
					if {$item < $mintime} {
						set mintime $item
					}
					break
				}
				incr cnt
			}
		}
		if {$mintime == 100000} {
			Inf "Unknown"
			return
		}
		if {$prm(0) > $mintime} {								;#	However, if start-time of mix is LATER than mintime
			set mintime $prm(0)									;#	Offset by starttime-of-mix instead
		}
		set mixval [expr $pa($fnam,$evv(DUR)) + $mintime]
		return
	}
	set mixval $prm(1)
}

#------- Colour 'Whole Mix' button

proc ColourWholeMixButton {} {
	global prm qikmixdur evv mixd2
	if {($prm(0) > 0) || ($prm(1) < $qikmixdur)} {
		$mixd2.1.see.000.dft config -bg $evv(EMPH)
	} else {
		$mixd2.1.see.000.dft config -bg [option get . background {}]
	}
}

#---- Redefine end of qikedit mixfile (if e.g. new snds added, or sounds removed)

proc RedefineMixfileEnd {} {
	global prm qikmixdur m_list pa evv
	if {![Flteq $prm(1) $qikmixdur]} {
		ColourWholeMixButton
		return
	}
	set maxend 0
	foreach line [$m_list get 0 end] {
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [string trim $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					set fnam $item
				}
				1 {
					set time $item
				}
				default {
					break
				}
			}
			incr cnt
		}
		if {![info exists pa($fnam,$evv(DUR))]} {
			Inf "Not All Files In Mix Are On Workspace\n\nCannot Check Endtime Of Mix"
			return		
		} 
		set thisend [expr $time + $pa($fnam,$evv(DUR))]
		if {$thisend > $maxend} {
			set maxend $thisend
		}
	}
	if {$maxend != $qikmixdur} {
		set qikmixdur $maxend
		set prm(1) $qikmixdur
	}
}

#################################
#--- MM OPERATIONS IN QIK EDIT	#
#################################

proc QikSeeMM {} {
	global qebeat
	if {![info exists qebeat]} {
		Inf "No MM Set At Present"
	} else {
		set qemm [expr 60.0 / $qebeat]
		set kk [expr int(round($qemm))]
		set aa [expr $qemm - double($kk)]
		if {$aa < .001 && $aa > -.001} {
			set qemm $kk
		}
		Inf "MM = $qemm"
	}
}

proc QikEditMM {beats add} {
	global mixval qemm qebeat pr_qemm evv
	if {$beats != 0} {
		if {![info exists qebeat]} {
			Inf "No MM Set"	
			return
		}
		set val [expr ($qebeat * double($beats))]
		if {$add} {
			if {![IsNumeric $mixval]} {
				Inf "Cannot Add Time To Existing (Non-Numeric) Value"
				return
			}
			if {$add == 1} {
				set val [expr $mixval + $val]
			} else {	;# $add == -1
				set val [expr $mixval - $val]
				if {$val < 0.0} {
					Inf "Subtracting The Beat(s) Gives A Time Before Zero"
					return
				}
			}
		}
		set mixval [DecPlaces $val 4]
		return
	}	
	set f .qe_mm
	if [Dlg_Create $f "SET MM" "set pr_qemm 0" -width 80] {
		frame $f.b0
		frame $f.b1
		button $f.b0.ok -text "Set MM"  -command {set pr_qemm 1} -highlightbackground [option get . background {}]
		button $f.b0.qu -text "Abandon" -command {set pr_qemm 0} -highlightbackground [option get . background {}]
		pack $f.b0.ok -side left
		pack $f.b0.qu -side right
		label $f.b1.ll -text "MM  "
		entry $f.b1.e -textvariable qemm -width 8
		pack $f.b1.ll $f.b1.e -side left -pady 1
		pack $f.b0 $f.b1 -side top -fill x -expand true -pady 2
#		wm resizable $f 0 0
		bind $f <Return> {set pr_qemm 1}
		bind $f <Escape> {set pr_qemm 0}
	}
	raise $f
	set pr_qemm 0
	set finished 0
	My_Grab 0 $f pr_qemm $f.b1.e
	while {!$finished} {
		tkwait variable pr_qemm
		if {$pr_qemm} {
			if {([string length $qemm] <= 0) || (![IsNumeric $qemm]) || ($qemm < 20) || ($qemm > 4000)} {
				Inf "Invalid MM Value"
				continue
			}
			set qebeat [expr 60.0 / double($qemm)]
			set mixval $qebeat
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- QikEdit: Make cliktrack at specified MM, and place in mixfile in QikEdit, marking as cliktrak line

proc Do_MakeMM {} {
	global qiki qikclik m_list qiki_main qikclik_main is_the_main wstk
	if {[info exists qiki]} {
		set msg "Clicktrack Already Exists For This Mix: Make A Different One ?"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if [string match no $choice] {
			return
		} else {
			unset qiki
			catch {unset qikclik}
		}
	}
	if {[MakeMM]} {
		set qiki 0
		set qikclik [$m_list get 0]
		if {$is_the_main} {
			set qiki_main $qiki
			set qikclik_main $qikclok
		}
	}
}

proc MakeMM {} {
	global pr_makeclik makeclick_mm makeclick_dur makeclick_fnam wstk CDPidrun prg_dun prg_abortd mlst qemm evv
	global makeclik_rval
	if {[info exists qemm]} {
		set msg "Clicktrack At MM $qemm ?"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if [string match yes $choice] {
			set gotqemm $qemm
		}
	}
	set f .makeclik
	if [Dlg_Create $f "CREATE CLICKTRACK" "set pr_makeclik 0" -width 80] {
		frame $f.b0
		frame $f.b1
		frame $f.b2
		frame $f.b3
		button $f.b0.ok -text "Create"  -command {set pr_makeclik 1} -highlightbackground [option get . background {}]
		button $f.b0.qu -text "Abandon" -command {set pr_makeclik 0} -highlightbackground [option get . background {}]
		pack $f.b0.ok -side left
		pack $f.b0.qu -side right
		label $f.b1.mm -text "MM "
		entry $f.b1.e -textvariable makeclick_mm -width 6
		pack $f.b1.mm $f.b1.e -side left
		label $f.b2.dur -text "Duration (secs) "
		entry $f.b2.e -textvariable makeclick_dur -width 6
		pack $f.b2.dur $f.b2.e -side left
		label $f.b3.nam -text "Click Filename"
		entry $f.b3.e -textvariable makeclick_fnam -width 6
		label $f.b3.num -text "(The MM value will be appended to the name)" -fg $evv(SPECIAL)
		pack $f.b3.nam $f.b3.e $f.b3.num -side left -padx 2
		pack $f.b0 $f.b1 $f.b2 $f.b3 -side top -fill x -expand true -pady 2
#		wm resizable $f 0 0
		bind $f <Return> {set pr_makeclik 1}
		bind $f <Escape> {set pr_makeclik 0}
	}
	if {[info exists gotqemm]} {
		set makeclick_mm $gotqemm
	} else {
		set makeclick_mm ""
	}
	set makeclick_dur ""
	set makeclick_fnam "click"
	raise $f
	update idletasks
	StandardPosition $f
	set pr_makeclik 0
	set finished 0
	My_Grab 0 $f pr_makeclik $f.b1.e
	while {!$finished} {
		tkwait variable pr_makeclik
		if {$pr_makeclik} {
			if {![IsNumeric $makeclick_mm] || ($makeclick_mm < 20) || ($makeclick_mm > 4000)} {
				Inf "Invalid MM (Range 20 - 4000)"
				continue
			}
			if {![IsNumeric $makeclick_dur] || ($makeclick_dur <= 1.0)} {
				Inf "Invalid Length (One second minimum)"
				continue
			}			
			if {[string length $makeclick_fnam] <= 0} {
				Inf "No Clicktrack Filename Entered"
				continue
			}
			if {![ValidCDPRootname $makeclick_fnam]} {
				continue
			}

			;#	APPEND METRONOME MARK TO FILENAME

			set outfnam $makeclick_fnam
			append outfnam "_mm"
			set makeclick_mm [string trim $makeclick_mm]
			set len [string length $makeclick_mm]
			set n 0
			while {$n < $len} {
				set val [string index $makeclick_mm $n]
				if {[string match $val "."]} {
					append outfnam "p"
				} else {
					append outfnam $val
				}
				incr n
			}
			set outfnamdata $outfnam
			append outfnamdata $evv(TEXT_EXT)
			append outfnam $evv(SNDFILE_EXT)

			;#	CHECK IF METRONOME MARK DATA OR SND FILES ALREADY EXIST

			if {[file exists $outfnamdata]} {
				set msg "Datafile $outfnamdata Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					continue
				}
				if {![DeleteClikDataFile $outfnamdata]} {
					continue
				}					
			}
			if {[file exists $outfnam]} {
				if {[IsInAMixfile $outfnam]} {	;#	if it was in an existing mixfile
					set msg "Clicktrack File $outfnam Exists, And Is Used In Existing Mixfiles: Overwrite It ?"
				} else {
					set msg "Clicktrack File $outfnam Exists: Overwrite It ?"
				}
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					continue
				}
				if {![DeleteClikFile $outfnam]} {
					DeleteClikDataFile $outfnamdata
					continue
				}
			}

			;#	WRITE MM DATA FILE

			set beatdur [expr 60.0/double($makeclick_mm)]
			set bardur [expr $beatdur * 4.0]						;#	click is at 4:4 here
			set barcount [expr round(ceil($makeclick_dur / $bardur))]

			set outdata "1\t1="
			append outdata "$makeclick_mm\t"
			append outdata "4:4\t"
			append outdata "$barcount\t"
			append outdata "1..."
			if [catch {open $outfnamdata "w"} zit] {
				Inf "Cannot Open Data File '$outfnamdata' To Write Click Data"
				continue
			} 
			puts $zit $outdata
			close $zit
			if {[FileToWkspace $outfnamdata 0 0 0 0 1] <= 0} {
				DeleteClikDataFile $outfnamdata
				continue
			}

			;#	GENERATE CLICKTRACK

			set cmd [file join $evv(CDPROGRAM_DIR) synth]
			lappend cmd "clicks" 1 $outfnam $outfnamdata -s0 -e32767 -z1		;#	32767 forces all of data to be used
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			Block "Creating Clicktrack"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Create Clicktrack"
				DeleteClikDataFile $outfnamdata
				UnBlock
				continue
   			} else {
   				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			UnBlock
			if {!$prg_dun || ![file exists $outfnam]} {
				Inf "Failed To Create Clicktrack"
				DeleteClikDataFile $outfnamdata
				continue
			}
			if {[FileToWkspace $outfnam 0 0 0 0 1] <= 0} {
				DeleteClikFile $outfnam
				DeleteClikDataFile $outfnamdata
				continue
			}
			set clickline $outfnam
			lappend clickline 0.0000 1 1.0 C
			lappend nu_mlst $clickline
			foreach line $mlst {
				lappend nu_mlst $line
			}
			set mlst $nu_mlst
			DisplayMixlist 2
			set makeclik_rval 1
			break
		} else {
			set makeclik_rval 0
			break
		}
	}			
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $makeclik_rval
}

proc DeleteClikDataFile {outfnamdata} {
	global mixmanage wl rememd

	if {![DeleteFileFromSystem $outfnamdata 0 1]} {
		Inf "Cannot Delete Existing Clicktrack Datafile $outfnamdata"
		return 0
	} else {
		DummyHistory $outfnamdata "DESTROYED"
		if {[info exists mixmanage($outfnamdata)]} {	;#	if a mixfile has been deleted
			unset mixmanage($outfnamdata)
			MixMStore
		}
		set i [LstIndx $outfnamdata $wl]	;#	remove from workspace listing, if there
		if {$i >= 0} {
			$wl delete $i
			WkspCnt $outfnamdata -1
			catch {unset rememd}
		}
	}
	return 1
}

proc DeleteClikFile {outfnam} {
	global blist_change background_listing wl rememd

	set blist_change 0
	if {![DeleteFileFromSystem $outfnam 0 1]} {
		Inf "Cannot Delete Existing Clicktrack File $outfnam"
		return 0
	} else {
		DummyHistory $outfnam "DESTROYED"
		if {[IsInAMixfile $outfnam]} {	;#	if it was in an existing mixfile
			if {[MixM_ManagedDeletion $outfnam]} {
				MixMStore
			}
		}
		if {$blist_change} {
			SaveBL $background_listing
		}
		set i [LstIndx $outfnam $wl]	;#	remove from workspace listing, if there
		if {$i >= 0} {
			$wl delete $i
			WkspCnt $outfnam -1
			catch {unset rememd}
		}
	}
	return 1
}

#--- Conver time value to beats value, or round time to a nearest beat-count

proc QikEditMMRound {timeround} {
	global mixval qebeat
	if {![info exists qebeat]} {
		Inf "No MM Set"	
		return
	}
	if {![IsNumeric $mixval] || ($mixval < 0.0)} {
		Inf "\"Value\" In Value Box Is Not A Valid Time"
		return
	}
	set outval [expr double($mixval)/double($qebeat)]
	if {$timeround} {
		set outval [expr int(round($outval))]
		set mixval [expr double($outval) * double($qebeat)]
		return
	}
	set mixval $outval
}

#---- Set Qikedit Value to MM beats

proc SetMMTime {} {
	global pr_setmm readonlybg readonlyfg setmm setmmval qebeat mixval evv

	if {![info exists qebeat]} {
		Inf "NOT MM SET"
		return
	}
	set f .setmm
	if [Dlg_Create $f "METRONOMIC BEATS" "set pr_setmm 0" -width 80] {
		frame $f.0
		button $f.0.to -text "Get Value"  -command {set pr_setmm 1} -highlightbackground [option get . background {}]
		label $f.0.ll -text "Use UP/DOWN arrows to change Beat Count" -fg $evv(SPECIAL)
		button $f.0.qu -text "Quit" -command {set pr_setmm 0} -highlightbackground [option get . background {}]
		pack $f.0.to $f.0.ll -side left -padx 4
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.0 -text "GET" -variable setmm -value 0
		radiobutton $f.1.1 -text "ADD" -variable setmm -value 1
		radiobutton $f.1.2 -text "SUBTRACT" -variable setmm -value	-1
		label $f.1.ll -text " Time equivalent of Beats"
		pack $f.1.0 $f.1.1 $f.1.2 $f.1.ll -side left
		pack $f.1 -side top -pady 2 -fill x -expand true 
		frame $f.2
		label $f.2.ll -text "Beat Count"
		entry $f.2.e -textvariable setmmval -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f.2.ll $f.2.e -side top -pady 2
		pack $f.2 -side top -pady 2
#		wm resizable $f 0 0
		bind $f <Up>   {BeatChange 1}
		bind $f <Down> {BeatChange 0}
		set setmmval 1
		bind $f <Escape>  {set pr_setmm 0}
	}
	set setmm 0
	raise $f
	update idletasks
	StandardPosition $f
	set pr_setmm 0
	set finished 0
	My_Grab 0 $f pr_setmm
	while {!$finished} {
		tkwait variable pr_setmm
		switch -- $pr_setmm {
			1 {
				if {$setmm && (![IsNumeric $mixval] || ($mixval < 0.0))} {
					Inf "Existing Value In \"Value Box\" Is Not A Valid Time"
					continue
				}
				if [GetMMTime $setmm $setmmval] {
					break
				}
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetMMTime {addit val} {
	global mixval qebeat
	switch -- $addit {
		0  {
			set outval [expr $val * $qebeat]
		}
		1  {
			set outval [expr $mixval + ($val * $qebeat)]
		}
		-1  {
			set outval [expr $mixval - ($val * $qebeat)]
			if {[string first "e-" $outval] >= 0} {
				set outval 0.0
			}
		}
	}
	if {$outval < 0.0} {
		Inf "Time Less Than Zero Generated"
		return 0
	}
	set mixval $outval
	return 1
}

proc BeatChange {up} {
	global setmmval
	if {$up} {
		if {$setmmval == 0.25} {
			set setmmval 0.5
		} elseif {$setmmval == 0.5} {
			set setmmval 1
		} elseif {$setmmval >= 16} {
			set setmmval 0.25
		} else {
			incr setmmval
		}
	} else {
		if {$setmmval == 0.25} {
			set setmmval 16
		} elseif {$setmmval == 0.5} {
			set setmmval 0.25
		} elseif {$setmmval == 1} {
			set setmmval 0.5
		} else {
			incr setmmval -1
		}
	}
}

#----- Calc time in mix from MM, beat count, offset of mix, and offset of new sound

proc QikEditGetTimeAtMMBeat {} {
	global pr_gtammb gtammbval gtammbmm gtammboff gtammbmxoff gtammb_no gtammbinoff readonlyfg readonlybg mixval qebeat evv 

	set f .gtammb
	if [Dlg_Create $f "TIME AT METRONOME BEAT" "set pr_gtammb 0" -width 80] {
		frame $f.0
		button $f.0.to -text "Get Time"  -command {set pr_gtammb 1} -highlightbackground [option get . background {}]
		label $f.0.ll -text "Use UP/DOWN arrows to change Beat Count" -fg $evv(SPECIAL)
		button $f.0.qu -text "Quit" -command {set pr_gtammb 0} -highlightbackground [option get . background {}]
		pack $f.0.to $f.0.ll -side left -padx 4
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		label $f.0a -text "WARNING: Ensure first entry in mix starts at time ZERO" -fg $evv(SPECIAL)
		pack $f.0a -side top -pady 2
		frame $f.1
		label $f.1.mm -text "MM "
		entry $f.1.e -textvariable gtammbmm -width 6
		label $f.1.ll -text "        Beat Count (from zero)"
		entry $f.1.e2 -textvariable gtammbval -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f.1.mm $f.1.e $f.1.ll $f.1.e2 -side left -padx 2
		pack $f.1 -side top -pady 2
		frame $f.1a
		label $f.1a.0 -text "Beat Offset"
		radiobutton $f.1a.1 -text "-1/2" -variable gtammboff -value	-3
		radiobutton $f.1a.2 -text "-1/3" -variable gtammboff -value	-2
		radiobutton $f.1a.3 -text "-1/4" -variable gtammboff -value	-1
		radiobutton $f.1a.4 -text "Zero" -variable gtammboff -value	 0
		radiobutton $f.1a.5 -text "+1/4" -variable gtammboff -value	 1
		radiobutton $f.1a.6 -text "+1/3" -variable gtammboff -value	 2
		radiobutton $f.1a.7 -text "+1/2" -variable gtammboff -value	 3
		pack $f.1a.0 $f.1a.1 $f.1a.2 $f.1a.3 $f.1a.4 $f.1a.5 $f.1a.6 $f.1a.7 -side left -pady 2
		pack $f.1a -side top -pady 2
		frame $f.2
		entry $f.2.e -textvariable gtammbmxoff -width 6
		label $f.2.off -text " Offset of initial beat in mix"
		pack $f.2.e $f.2.off -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3
		entry $f.3.e -textvariable gtammbinoff -width 6
		label $f.3.off -text " (initial beat offset in new sound to add)"
		checkbutton $f.3.h -variable gtammb_no -text "        No new snd" -command SetGtammbinoff
		pack $f.3.e $f.3.off $f.3.h -side left -padx 2
		pack $f.3 -side top -pady 2
		bind $f <Up>   {BeatCChange 1}
		bind $f <Down> {BeatCChange 0}
		set gtammbmm 60
		set gtammbmxoff 0.0
		set gtammbinoff 0.0
#		wm resizable $f 0 0
		bind $f <Return> {set pr_gtammb 1}
		bind $f <Escape> {set pr_gtammb 0}
	}
	if {[info exists qebeat]} {
		set gtammbmm [DecPlaces [expr $qebeat * 60.0] 2]
	}
	if {![info exists gtammbval] || ([string length $gtammbval] <= 0)} {
		set gtammbval 0
	} 
	set gtammb_no 0
	set gtammboff 0
	raise $f
	update idletasks
	StandardPosition $f
	set pr_gtammb 0
	set finished 0
	My_Grab 0 $f pr_gtammb
	while {!$finished} {
		tkwait variable pr_gtammb
		if {$pr_gtammb} {
			if {$gtammbmm == 0} {
				Inf "Invalid Metronome Mark"
				continue
			}
			if {[string length $gtammbmxoff] <= 0} {
				Inf "No Mix Offset Entered"
				continue
			}
			if {![IsNumeric $gtammbmxoff] || ($gtammbmxoff < 0.0)} {
				Inf "Invalid Mix Offset ($gtammbmxoff) Entered"
				continue
			}
			if {[string length $gtammbinoff] <= 0} {
				Inf "No New Sound Offset Entered (Set To Zero, If No New Sound)"
				continue
			}
			if {![IsNumeric $gtammbinoff] || ($gtammbinoff < 0.0)} {
				Inf "Invalid New Sound Offset ($gtammbinoff) Entered"
				continue
			}
			set beats [expr double($gtammbval)]
			switch -- $gtammboff {
				"-3" {
					set beats [expr $beats - 0.5]
				}
				"-2" {
					set beats [expr $beats - 0.3333333333]
				}
				"-1" {
					set beats [expr $beats - 0.25]
				}
				"1" {
					set beats [expr $beats + 0.25]
				}
				"2" {
					set beats [expr $beats + 0.3333333333]
				}
				"3" {
					set beats [expr $beats + 0.5]
				}
			}
			set time [expr (60.0/double($gtammbmm)) * $beats]
			set time [expr $time + $gtammbmxoff]
			set time [expr $time - $gtammbinoff]
			set mixval $time
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc BeatCChange {up} {
	global gtammbval
	if {$up} {
		incr gtammbval
	} elseif {$gtammbval > 0} {
		incr gtammbval -1
	}
}

proc SetGtammbinoff {} {
	global gtammbinoff gtammb_no
	if {$gtammb_no} {
		set gtammbinoff 0.0
		set gtammb_no 0
	}
}

proc AddAtMM {toline} {
	global qebeat pr_mmadd mmaddno evv m_list mixval tempmix

	if {![info exists qebeat]} {
		Inf "NO MM ESTABLISHED"
		return
	}
	set f .pr_mmadd
	if [Dlg_Create $f "ADD BEATS AT EXISTING MM" "set pr_mmadd 0" -width 80] {
		frame $f.0
		button $f.0.to -text "Add Beats"  -command {set pr_mmadd 1} -highlightbackground [option get . background {}]
		label $f.0.ll -text "UP/DOWN arrows change Beat Count" -fg $evv(SPECIAL)
		button $f.0.qu -text "Abandon" -command {set pr_mmadd 0} -highlightbackground [option get . background {}]
		pack $f.0.to $f.0.ll -side left -padx 4
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.bb -text "Number of beats "
		entry $f.1.e -textvariable mmaddno -width 6
		pack $f.1.bb $f.1.e -side left -padx 2
		pack $f.1 -side top -pady 2
		bind $f <Up>   {BeatsKhange 1}
		bind $f <Down> {BeatsKhange 0}
#		wm resizable $f 0 0
		bind $f <Return> {set pr_mmadd 1}
		bind $f <Escape> {set pr_mmadd 0}
	}
	set mmaddno 0
	raise $f
	update idletasks
	StandardPosition $f
	set pr_mmadd 0
	set finished 0
	My_Grab 0 $f pr_mmadd
	while {!$finished} {
		tkwait variable pr_mmadd
		if {$pr_mmadd} {
			if {![IsNumeric $mmaddno]} {
				Inf "No Valid Beat Count Entered" 
				continue
			}
			if {$toline} {
				set val [expr ($qebeat * double($mmaddno))]
				MixModify move $m_list $val $tempmix
				set tempmix 1	
			} else {
				QikEditMM $mmaddno 1
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc BeatsKhange {up} {
	global mmaddno
	if {![IsNumeric $mmaddno]} {
		return
	}
	if {$up} {
		set mmaddno [expr $mmaddno + 1.0]
	} else {
		set mmaddno [expr $mmaddno - 1.0]
	}
}

###################################
#	GETTING TO AND FROM QIKEDIT	  #
###################################

#----- Qikedit page: Grab to workspace any files in mix which are not already on workspace

proc QikGetToWkspace {} {
	global mlst wl
	set filcnt 0
	Block "Grabbing Files to Workspace"
	foreach line $mlst {
		set fnam [StripCurlies [lindex $line 0]]
		if {[string match [string index $fnam 0] ";"]} {
			continue
		}
		if {![file exists $fnam]} {
			lappend nonfiles $fnam
			continue
		}
		if {[LstIndx $fnam $wl] < 0} {
			if {[FileToWkspace $fnam 0 0 0 1 0 ] <= 0} {
				lappend badfiles $fnam
			} else {
				incr filcnt
			}
		}
	}
	UnBlock
	set msg ""
	if {$filcnt} {
		append msg "$filcnt Files Grabbed To Workspace\n\n"
	}
	if {[info exists nonfiles]} {
		append msg "The Following Files No Longer Exist\n\n"
		set cnt 0
		foreach fnam $nonfiles {
			if {$cnt >= 20} {
				append msg "\nAnd More\n\n"
				break
			}
			append msg "$fnam    "
			incr cnt
		}
	}
	if {[info exists badfiles]} {
		append msg "The Following Files Could Not Be Grabbed To The Workspace\n\n"
		set cnt 0
		foreach fnam $badfiles {
			if {$cnt >= 20} { 
				append msg "\nAnd More"
				break
			}
			append msg "$fnam    "
			incr cnt
		}
	}
	if {[string length $msg] > 0} {
		Inf $msg
	}
}

#####################################
#--- GET MAX SAMP ON QIKEDIT PAGE	#
#####################################

proc QikMaxsamp {} {
	global chlist lastmixio CDPmaxId done_maxsamp maxsamp_line prm sn pa wstk qikgain mixval evv
	set fnam $evv(DFLT_OUTNAME)												;#	Look for file output from current use of MIX process
	append fnam 0 $evv(SNDFILE_EXT)
	set OK 1
	if {![file exists $fnam]} {												;#	If there is one, use it, else
		set OK 0
		if {[info exists lastmixio]} {
			set OK 1
			if {[string match [lindex $chlist 0] [lindex $lastmixio 0]]} {	;#	If last mixout-sndfile came from same mixfile
				set fnam [lindex $lastmixio 1]								;#	Assume last output of this mix is the file produced
				if {![file exists $fnam]} {									;#	when mixfile was last used.
					set OK 0
					unset {lastmixio}										;#	But if the file produced then no longer exists
				}															;#	Or we're not using the same same mixfile as previously
			} else {														;#	delete the 'lastmixio' info
				set OK 0
				unset {lastmixio}											
				return
			}
		}
	}
	if {!$OK} {
		Inf "No Mix Output Yet"
		return
	}
	set done_maxsamp 0
	catch {unset maxsamp_line}
	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	if [info exists maxsamp_missing] {
		Inf "maxsamp2$evv(EXEC) Is Not On Your System.\nCannot Search For Maximum Sample In File."
		return
	} elseif [ProgMissing $cmd "Cannot search for maximum sample in file."] {
		return
	}
	lappend cmd $fnam
	lappend cmd 1
	if [catch {open "|$cmd"} CDPmaxId] {
		ErrShow "$CDPmaxId"
		return
	} else {
		Block "Calculating maximum"
	   	fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
	}
	vwait done_maxsamp
	UnBlock
	if {![info exists maxsamp_line]} {
		Inf "No Maximum Sample Information Retrieved"
	} else {
		set maxsamp [lindex $maxsamp_line 0]
		if {$maxsamp <= 0.0} {
			Inf "Maximum sample is zero"
		} elseif {$maxsamp > .98} {
			set msg "Overload: Reducing Gain By 50%"
			append msg "\n\nRun Mix Again, And Get Maxsamp Again, To Calculate Optimum Level."
			append msg "\nThen Run Mix A 2nd Time."
			Inf $msg
			set gain 0.1
			set prm(2) $gain
			set qikgain $gain
		} else {
			set gain [expr (0.98 / $maxsamp) * $prm(2)]
			set gain [expr int(floor($gain * 100.0))]
			set gain [ChopFig [expr $gain/100.0] 2]		;#	i.e. chop off dec places beyond 2nd
			if {$gain > 1.0} {
				set gain 1.0
			}
			set msg "Maximum Sample = $maxsamp"
			if {($prm(2) < 1.0) && ![Flteq $prm(2) $gain]} {
				append msg " : Increase Mix Gain To $gain ???"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match yes $choice] {
					set prm(2) $gain
					set qikgain $gain
				}
				return
			} else {
				if {$maxsamp < 0.979} {
					append msg " : Mix Events Could Perhaps Be Louder"
					set kk [expr 0.98 / $maxsamp]
					if {$kk > 1.0} {
						append msg "\n\nPut Possible Gain In 'Value' Box ??"
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if [string match yes $choice] {
							set mixval [DecPlaces $kk 4]
						}
						return
					}
				}
			}
			Inf $msg
		}
	}
}

#------ Chop of value at N places beyond dec point (gives value lower than actual value, for gain adjustments in mixes: avoid overload)

proc ChopFig {val places} {
	set len [string length $val]
	set endchar [expr $len - 1]
	if {[string first "e-" $val] >= 0} {	;#	-ve exponential vals set to 0
		set val "0."
		set k 0
		while {$k < $places} {
			append val "0"
			incr k
		}
		return $val
	}
	set decpos [string first "." $val]					
	if {$decpos < 0} {
		return $val
	}	
	if {$decpos == $endchar} {
		incr endchar -1
		set val [string range $val 0 $endchar]
		return $val
	}
	set decfigs [expr $endchar - $decpos]
	set surplus [expr $decfigs - $places]
	if {$surplus <= 0} {
		return $val
	}
	set val [string range $val 0 [expr $endchar - $surplus]]
	return $val
}

###################################
#---- OPERATIONS ON MUTED LINES	  #
###################################

proc UnMuteAll {} {
	global previous_linestore m_list mlst mm_multichan mlsthead wstk pa evv

	set msg "Are You Sure You Want To Unmute ~~ALL~~ Muted Lines ??"
	set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
	if [string match no $choice] {
		return
	}
	set i 0
	foreach line [$m_list get 0 end] {
		if {[string match [string index $line 0] ";"]} {
			lappend mute_lines $i
		}
		incr i
	}
	if {![info exists mute_lines]} {
		Inf "No Muted Lines"
		return
	}
	foreach i $mute_lines {
		set line [$m_list get $i]
		set line [string range $line 1 end]
		set line [split $line]
		set cnt 0
		set OK 1
		catch {unset nuline}
		if {$mm_multichan} {
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {![file exists $item]} {
							set OK 0
						}
						if {![info exists pa($item,$evv(FTYP))]} {
							set msg "Some Files On Muted Lines Are Not On Workspace\n"
							append msg "Or Some Lines Are Pure Comments.\n\nCannot Proceed"
							Inf $msg
							return
						}
						if {$pa($item,$evv(FTYP)) != $evv(SNDFILE)} {
							set OK 0
						}
						set chans $pa($item,$evv(CHANS))
					}
					1 {
						if {![IsNumeric $item] || ($item < 0.0)} {
							set OK 0
						}
					}
					2 {
						if {![IsNumeric $item] || ($item != $chans)} {
							set OK 0
						}
					}
					default {
						if {[IsEven $cnt]} {
							if {[CheckGainVal $item 0 0] < 0.0} {
								set OK 0
							}
						} else {
							set len [string length $item]
							set n 0
							catch {unset mm}
							while {$n < $len} {
								set thischar [string index $item $n]
								if {[regexp {^[0-9]$} $thischar]} {
									incr n
									continue
								} else {
									if {![info exists mm]} {
										if {($n == 0) || ![string match $thischar ":"]} {
											set OK 0
											break
										}
										set in_chan [string range $item 0 [expr $n - 1]]
										if {($in_chan == 0) || ($in_chan > $chans)} {
											set OK 0
											break
										}
										set mm [expr $n + 1]
									}
								}
								incr n
							}
							if {![info exists mm] || ($mm >= $n)} {
								set OK 0
								break
							}
							set out_chan [string range $item $mm end]
							if {($out_chan == 0) || ($out_chan > $mlsthead)} {
								set OK 0
								break
							}
						}
					}
				}
				lappend nuline $item
				incr cnt
			}
			if {$OK && ($cnt > 4) && ![IsEven $cnt]} {
				lappend nulines $nuline
			} else {
				set origline ";"
				append origline $nuline
				lappend nulines $origline
			}
		} else {
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {![file exists $item]} {
							set OK 0
						}
						if {![info exists pa($item,$evv(FTYP))]} {
							set msg "Some Files On Muted Lines Are Not On Workspace\n"
							append msg "Or Some Lines Are Pure Comments.\n\nCannot Proceed"
							Inf $msg
							return
						}
						if {$pa($item,$evv(FTYP)) != $evv(SNDFILE)} {
							set OK 0
						}
						set chans $pa($item,$evv(CHANS))
					}
					1 {
						if {![IsNumeric $item] || ($item < 0.0)} {
							set OK 0
						}
					}
					2 {
						if {![IsNumeric $item] || ($item != $chans)} {
							set OK 0
						}
					}
					3 {
						if {![IsNumeric $item] || ($item <= 0.0)} {
							set OK 0
						}
					}
					4 {
						if {![IsNumeric $item]} {
							if {($item != "C") && ($item != "L") && ($item != "R")} {
								set OK 0
							}
						} elseif {$item <= 0.0} {
							set OK 0
						}
					}
					5 {
						if {$chans != 2} {
							set OK 0
						}
						if {![IsNumeric $item] || ($item <= 0.0)} {
							set OK 0
						}

					}
					6 {
						if {![IsNumeric $item]} {
							if {($item != "C") && ($item != "L") && ($item != "R")} {
								set OK 0
							}
						} elseif {$item <= 0.0} {
							set OK 0
						}
					}
					default {
						set OK 0
					}
				}
				lappend nuline $item
				incr cnt
			}
			if {$OK && (($cnt == 4) || ($cnt == 5) || ($cnt == 7))} {
				lappend nulines $nuline
			} else {
				set origline ";"
				append origline $nuline
				lappend nulines $origline
			}
		}
	}
	set previous_linestore $mlst
	foreach i $mute_lines line $nulines {
		catch {unset nuline}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set mlst [lreplace $mlst $i $i $nuline]
	}
	DisplayMixlist 2
}

proc ActivateAndMoveMutedLine {zsel val addon} {
	global m_list mlst wstk m_list_restore 
	set len [llength $zsel]
	if {$len <= 0} {
		return 0
	} elseif {($len == 1) && ($zsel == -1)} {
		return 0
	}
	foreach z $zsel {
		set fnam [lindex [$m_list get $z] 0]
		if {[string match [string index $fnam 0] ";"]} {
			set fnam [string range $fnam 1 end]
			if {![file exists $fnam]} {
				continue
			} else {
				set aremuted 1
			}
			lappend fnams $fnam
			lappend nuzsel $z
		} else {
			lappend fnams $fnam
			lappend nuzsel $z
		}
	}
	if {![info exists nuzsel]} {
		return 0
	}
	set zsel $nuzsel
	if {[info exists aremuted]} {
		set msg "Activate Muted Lines ??"	
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			return 0
		}
	}
	if {![IsNumeric $val] || ($val < 0.0)} {
		Inf "Invalid Time Value ($val) Entered"
		return 0
	}
	set orig_mlst $mlst
	set origval $val
	set kk 0
	foreach z $zsel {
		set line [$m_list get $z]
		if {[string match ";" [string index $line 0]]} {
			set line [string range $line 1 end]
		}
		if {$addon == -2} {
			set oldval [lindex $line 1]
			if {$kk == 0} {
				set gap [expr $val - $oldval]
			} else {
				set val [expr $oldval + $gap]
				if {$val < 0.0} {
					Inf "Invalid Starttime (< 0.0) Generated"
					set mlst $orig_mlst
					return 0
				}
			}
		} elseif {$addon != 0} {
			set oldval [lindex $line 1]
			if {$addon < 0} {
				set val [expr $oldval - $origval]
				if {$val < 0.0} {
					Inf "Invalid Starttime (< 0.0) Generated"
					set mlst $orig_mlst
					return 0
				}
			} else {
				set val [expr $oldval + $origval]
			}
		}
		set line [lreplace $line 1 1 $val]
		lappend nulines $line
		set mlst [lreplace $mlst $z $z $line]
		incr kk
	}
	set linecnt [llength $mlst]
	set mlst [SortMix $linecnt $mlst]
	set mlst [ReverseList $mlst]
	set i 0
	catch {unset m_list_restore}
	foreach line $mlst {
		if {[lsearch $nulines $line] >= 0} {
			lappend m_list_restore $i
		}
		incr i
	}
	DisplayMixlist 2
	return 1
}

#########################################
#	DISPLAYING 'TEXT' PROPERTY OF SND	#
#########################################

#----- Show text associated with any sound having a text property, in Qikedit Window

proc QikShowText {} {
	global m_list propfiles_list pa evv
	if {![info exists propfiles_list] || ([llength $propfiles_list] == 0)} {
		Inf "No Known Properties Files On The Workspace"
		return
	}
	set badp 0
	set i [$m_list curselection]
	if {([llength $i] != 1) || ($i == -1)} {
		Inf "Select One Line"
		return
	}
	set line [$m_list get $i]
	set line [split $line]
	set fnam [lindex $line 0]
	if {[string match ";" [string index $fnam 0]]} {
		set fnam [string range $fnam 1 end]
	}
	if {![file exists $fnam]} {
		Inf "No Soundfile In This Line"
		return
	}
	if {![info exists pa($fnam,$evv(FTYP))]} {
		Inf "File In Line Is Not On The Workspace"
		return
	}
	if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		Inf "File In Line Is Not A Soundfile"
		return
	}
	foreach pfil $propfiles_list {
		if [catch {open $pfil "r"} zit] {
			incr badp
			continue
		}
		catch {unset propfile}
		while {[gets $zit line] >= 0} {
			lappend propfile $line
		}
		close $zit
		set propline [lindex $propfile 0]
		set propline [string tolower $propline]
		set propline [split $propline]
		set k [lsearch $propline "text"]
		if {$k < 0} {
			continue
		}
		incr k
		set propfile [lrange $propfile 1 end]
		foreach line $propfile {
			set thisfnam [lindex $line 0]
			if {[string match $thisfnam $fnam]} {
				set thistext [lindex $line $k]
				set thistext [split $thistext "_"]
				Inf $thistext
				return
			}
		}
	}	
	set msg ""
	if {$badp > 0} {
		append msg "$badp Of The Property Files Could Not Be Opened\n\n"
	}
	append msg "No Text Found"
	Inf $msg
}

#############################################
#--- DOUBLE-CLICK : PLAY OR READ A SOUND	#
#############################################

proc PlaySndonQikEdit {ll y} {
	global m_list evv

	set i [$ll nearest $y]
	if {$i < 0} {
		return
	}
	set line [$ll get $i]
	set line [split $line]
	set fnam [lindex $line 0]
	if {[string match $ll $m_list]} {
		if {[string match [string index $fnam 0] ";"]} {
			set fnam [string range $fnam 1 end]
		}
		if {![file exists $fnam]} {
			Inf "If There Was A Soundfile On This Line, It No Longer Exists"
			return
		}
		set ftyp [FindFileType $fnam]	
		if {$ftyp != $evv(SNDFILE)} {
			Inf "File On This Line Is Not A Soundfile"
		}
	}
	PlaySndfile $fnam 0
}

#########################################################
#---- TESTS FOR DUPLICATED SOUNDS IN QIKEDIT MIXFILE	#
#########################################################

proc DuplTest {} {
	global m_list
	set lastline [$m_list get 0]
	set k 0
	foreach line [$m_list get 1 end] {
		if {[string match $line $lastline]} {
			set msg "Line Duplication Found\n"
			Inf $msg
			break
		}
		set lastline $line
		incr k
	}
}

proc DuplTest2 {lst} {
	set lastline [lindex $lst 0]
	set len [llength $lst]
	set k 1
	while {$k < $len} {
		set line [lindex $lst $k]
		if {[string match $line $lastline]} {
			return 1
		}
		set lastline $line
		incr k
	}
	return 0
}

#########################################
#--- REFERENCE BUTTON ON QIKEDIT PAGE	#
#########################################

proc QikRef {} {
	global pr_qkref mixval refval
	set f .qkref
	if [Dlg_Create $f "REFERENCE VALUES" "set pr_qkref 0" -width 80] {
		frame $f.b0
		button $f.b0.to -text "Store Val"  -command {set pr_qkref 2} -highlightbackground [option get . background {}]
		button $f.b0.fr -text "Get Val"  -command {set pr_qkref 1} -highlightbackground [option get . background {}]
		button $f.b0.qu -text "Quit" -command {set pr_qkref 0} -highlightbackground [option get . background {}]
		pack $f.b0.to $f.b0.fr -side left -padx 2
		pack $f.b0.qu -side right
		pack $f.b0 -side top
#		wm resizable $f 0 0
		bind $f <Escape>  {set pr_qkref 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_qkref 0
	set finished 0
	My_Grab 0 $f pr_qkref
	tkwait variable pr_qkref
	switch -- $pr_qkref {
		1 {
			RefSee 6
		}
		2 {
			if {[string length $mixval] <= 0} {
				Inf "No Value To Store"
				break
			}
			set refval $mixval
			RefSee 5
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#########################
#---- MIX SYNTAX		#
#########################

proc CheckMixSyntax {} {
	global mm_multichan m_list wl pa evv
	set linecnt 0
	if {$mm_multichan} {
		foreach line [$m_list get 0 end] {
			incr linecnt
			set line [split $line]
			if {![CheckMultiChanLineSyntax $line $linecnt 1]} {
				return	
			}
		}
		Inf "Mixfile Syntax Is OK"
		return
	}
	foreach line [$m_list get 0 end] {
		incr linecnt
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {[string match ";" [string index $item 0]]} {
						break
					}
					set fnam $item
					if {![file exists $fnam] || [file isdirectory $fnam]} {
						set badmsg "FILE '$fnam' (line $linecnt) NO LONGER EXISTS"
						lappend badmsgs $badmsg
						set cnt 0
						break
					} 
					if {[LstIndx $fnam $wl] < 0} {
						Inf "Not All Files Are On Workspace\nCannot Do Syntax Check"
						return
					}
					set chancnt $pa($fnam,$evv(CHANS))
				}
				1 {
					if {![IsNumeric $item] || ($item < 0.0)} {
						set badmsg "Bad Start-Time For File '$fnam' (line $linecnt)"
						lappend badmsgs $badmsg
						set cnt 0
						break
					}						
				}
				2 {
					if {![regexp {^[0-9]+$} $item]} {
						set badmsg "Bad Channel Count For File '$fnam' (line $linecnt)"
						lappend badmsgs $badmsg
						set cnt 0
						break
					}
					if {$item != $chancnt} {
						set badmsg "File '$fnam' (line $linecnt) Should Have Channel Count $chancnt"
						lappend badmsgs $badmsg
						set cnt 0
						break
					}
				}
				3 -
				5 {
					if {![IsNumeric $item] || ($item < 0.0)} {
						set badmsg "Bad Level For File '$fnam' (line $linecnt)"
						lappend badmsgs $badmsg
						set cnt 0
						break
					}						
				}
				4 -
				6 {
					if {[IsNumeric $item] && (($item < -1.0) || ($item > 1))} {
						set badmsg "Bad Position Value For File '$fnam' (line $linecnt)"
						lappend badmsgs $badmsg
						set cnt 0
						break
					}						
					if {![IsNumeric $item] && !(($item == "L") || ($item == "R") || ($item == "C"))} {
						set badmsg "Bad Position Value For File '$fnam' (line $linecnt)"
						lappend badmsgs $badmsg
						set cnt 0
						break
					}						
				}
				default {
					set badmsg "Too Many Entries In Line $linecnt"
					lappend badmsgs $badmsg
					set cnt 0
					break
				}
			}
			incr cnt
		}
		if {$cnt == 0} {
			continue
		}	
		if {$cnt < 4} {
			set badmsg "Too Few Entries In Line $linecnt"
			lappend badmsgs $badmsg
			continue
		}
		switch -- $chancnt {
			1 {
				if {$cnt > 5} {
					set badmsg "Too Many Entries In Line $linecnt"
					lappend badmsgs $badmsg
				}
			}
			2 {
				if {($cnt != 4) && ($cnt != 7)} {
					set badmsg "Wrong Number Of Entries In Line $linecnt"
					lappend badmsgs $badmsg
				}
			}
		}
	}
	if {[info exists badmsgs]} {
		set msg [lindex $badmsgs 0]
		foreach badmsg [lrange $badmsgs 1 end] {
			append msg "\n$badmsg"
		}
	} else {
		set msg "Mixfile Syntax Is OK"
	}
	Inf $msg
}

#------ Check Syntax of line in multichannel mixfile

proc CheckMultiChanLineSyntax {line linecnt report} {
	global mlsthead pa evv 
	set cnt 0
	set OK 1
	foreach item $line {
		if {[string length $item] <= 0} {
			continue
		}
		switch -- $cnt {
			0 {
				if {[string match ";" [string index $item 0]]} {
					return 1
				}
				if {![file exists $item]} {
					if {$report} {
						Inf "File '$item' Does Not Exist : Line $linecnt"
					}
					return 0
				}
				if {![info exists pa($item,$evv(FTYP))]} {
					if {$report} {
						Inf "File Data For File '$item' Does Not Exist : Line $linecnt"
					}
					return 0
				}
				if {$pa($item,$evv(FTYP)) != $evv(SNDFILE)} {
					if {$report} {
						Inf "File '$item' Is Not A Soundfile : Line $linecnt"
					}
					return 0
				}
				set chans $pa($item,$evv(CHANS))
			}
			1 {
				if {![IsNumeric $item] || ($item < 0.0)} {
					if {$report} {
						Inf "Time Value Is Not Numeric : Line $linecnt"
					}
					return 0
				}
			}
			2 {
				if {![IsNumeric $item] || ($item != $chans)} {
					if {$report} {
						Inf "Channel Count Incorrect : Line $linecnt"
					}
					return 0
				}
			}
			default {
				if {[IsEven $cnt]} {
					if {[CheckGainVal $item 0 0] < 0.0} {
						if {$report} {
							Inf "Invalid Gain Value : Line $linecnt"
						}
						return 0
					}
				} else {
					set len [string length $item]
					set n 0
					catch {unset mm}
					while {$n < $len} {
						set thischar [string index $item $n]
						if {[regexp {^[0-9]$} $thischar]} {
							incr n
							continue
						} else {
							if {![info exists mm]} {
								if {($n == 0) || ![string match $thischar ":"]} {
									if {$report} {
										Inf "Invalid Routing Value ($item) : Line $linecnt"
									}
									return 0
								}
								set in_chan [string range $item 0 [expr $n - 1]]
								if {($in_chan == 0) || ($in_chan > $chans)} {
									if {$report} {
										Inf "Invalid Input Channel In Routing Value ($item) : Line $linecnt"
									}
									return 0
								}
								set mm [expr $n + 1]
							}
						}
						incr n
					}
					if {![info exists mm] || ($mm >= $n)} {
						if {$report} {
							Inf "Invalid Routing Value ($item) : Line $linecnt"
						}
						return 0
					}
					set out_chan [string range $item $mm end]
					if {($out_chan == 0) || ($out_chan > $mlsthead)} {
						if {$report} {
							Inf "Invalid Output Channel In Routing Value ($item) : Line $linecnt"
						}
						return 0
					}
				}
			}
		}
		incr cnt
	}
	if {!$OK | ($cnt <= 4) || [IsEven $cnt]} {
		if {$report} {
			Inf "Invalid Number Of Items In Line : Line $linecnt"
		}
		return 0
	}
	return 1
}

#########################
#---- MISCELLANEOUS		#
#########################

#--- Qiked line value to Calculator

proc QikEdToCalc {typ} {
	switch -- $typ {
		"calcvv" {
			if {[QikEditor calcvv]} {
				MusicUnitConvertor 6 0
			}
		}
		"calcsv" {
			if {[QikEditor calcsv]} {
				MusicUnitConvertor 6 0
			}
		}
		"calcv" {
			if {[QikEditor calcv]} {
				MusicUnitConvertor 6 0
			}
		}
		"calcs" {
			if {[QikEditor calcs]} {
				MusicUnitConvertor 6 0
			}
		}
	}
}

#--- Position QikEdit Window

proc QikeditPosition {w} {
	set xy [wm geometry $w]
	set xy [split $xy +]
	set xy [lindex $xy 0]
	set xy [split $xy x]
	set x [lindex $xy 0]
	set y [lindex $xy 1]
	incr y 20
	set k $x
	append k x
	append k $y
	append k "+0+25"
	wm geometry $w $k
}

#############################################
#---- INDIVIDUAL INPUT OR OUTPUT CHANNELS	#
#############################################

proc SetChannelAttenuation {} {
	global pr_chatten mix_outchans mix_atten readonlyfg readonlybg evv
	global previous_linestore mlst m_list m_list_restore
	set f .chatten
	if [Dlg_Create $f "ATTENUATE CHANNEL(S) IN MIX" "set pr_chatten 0" -width 80] {
		frame $f.0
		button $f.0.to -text "Set Attenuation"  -command {set pr_chatten 1} -highlightbackground [option get . background {}]
		button $f.0.qu -text "Abandon" -command {set pr_chatten 0} -highlightbackground [option get . background {}]
		pack $f.0.to -side left -padx 4
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		set n 1
		while {$n <= $mix_outchans} {
			frame $f.1.$n
			label $f.1.$n.ll -text "Channel $n"
			entry $f.1.$n.e -textvariable mix_atten($n) -width 4 -state readonly -fg $readonlyfg -bg $readonlybg
			pack $f.1.$n.e $f.1.$n.ll -side left -padx 2
			pack $f.1.$n -side top
			bind $f.1.$n.e <Up> "IncrMixAtten $n 0"
			bind $f.1.$n.e <Down> "IncrMixAtten $n 1"
			incr n
		}
		pack $f.1 -side top -pady 4
		label $f.2 -text "Adjust an attenuator by clicking on it, then using Up/Down Keys" -fg $evv(SPECIAL)
		pack $f.2 -side top -pady 4
#		wm resizable $f 0 0
		bind $f <Return> {set pr_chatten 1}
		bind $f <Escape> {set pr_chatten 0}
	}
	set n 1
	while {$n <= $mix_outchans} {
		set mix_atten($n) 1.0
		incr n
	}
	set mset 0
	raise $f
	update idletasks
	StandardPosition $f
	set pr_chatten 0
	My_Grab 0 $f pr_chatten
	tkwait variable pr_chatten
	if {$pr_chatten} {
		set n 1
		while {$n <= $mix_outchans} {
			if {![Flteq $mix_atten($n) 1.0]} {
				set mset 1
				break
			}
			incr n
		}
		if {$mset} {
			set previous_linestore $mlst
			set m_previous_yview [$m_list yview]
			catch {unset m_list_restore}
			set len [llength $mlst]
			set n 0 
			while {$n < $len} {
				set line [lindex $mlst $n]
				if {[string match [string index $line 0] ";"]} {
					incr n
					continue
				}
				set do_atten 0
				set is_atten 0
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					set k [string first ":" $item]
					if {$k > 0} {
						incr k
						set ochan [string range $item $k end]
						if {$mix_atten($ochan) < 1.0} {
							set do_atten 1
							set is_atten 1
						}
					} elseif {$do_atten} {		;#	set at previous item
						set item $mix_atten($ochan)
						set do_atten 0
					}
					lappend nuline $item
				}
				if {$is_atten} {
					set mlst [lreplace $mlst $n $n $nuline]
				}
				incr n
			}
			DisplayMixlist 0
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f	
}

proc SeeChannelLevels {} {
	global pr_chatlev mix_outchans mix_atten readonlyfg readonlybg evv
	global previous_linestore mlst m_list
	global CDPidrun prg_dun prg_abortd maxsamp_line pa
	set evv(DAWDLE) 10
	set i [$m_list curselection]
	if {![info exists i] || ([llength $i] != 1) || ($i < 0)} {
		Inf "Select An Active Mixfile Line"
		return
	}
	set line [lindex $mlst $i]
	set line [StripCurlies [string trim $line]]
	if {[string match ";" [string index $line 0]]} {
		Inf "Select An Active Mixfile Line"
		return
	}
	set line [split $line]
	set fnam [lindex $line 0]
	if {![file exists $fnam]} {
		Inf "File '$fnam' No Longer Exists"
		return
	}
	set inchans $pa($fnam,$evv(CHANS))
	set innam $evv(DFLT_OUTNAME)
	append innam 0000
	foreach zfnam [glob -nocomplain $innam*] {
		catch {file delete $zfnam}
	}
	if {$inchans == 1} {
		set outnam $innam
		append outnam _c1 $evv(SNDFILE_EXT)
		if [catch {file copy $fnam $outnam} zit] {
			Inf "Failed To Copy Soundfile '$fnam'"
			return
		}
	} else {
		set outnam $innam
		append outnam "_c"
		append innam $evv(SNDFILE_EXT)
		if [catch {file copy $fnam $innam} zit] {
			Inf "Failed To Copy Soundfile '$fnam'"
			return
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
			UnBlock
			return
		}
		set n 1
		while {$n <= $inchans} {
			set ofnam $outnam
			append ofnam $n $evv(SNDFILE_EXT)
			if {![file exists $ofnam]} {
				Inf "Channel Extraction Failed"
				set k 1
				while {$k <= $inchans} {
					set ofnam $outnam
					append ofnam $k $evv(SNDFILE_EXT)
					if {[file exists $ofnam]} {
						catch {file delete $ofnam}
					}
					incr k
				}
				catch {file delete $innam}
				UnBlock
				return
			}
			incr n
		}
		UnBlock
	}
	Block "Assessing Channel Levels"		
	set n 1
	while {$n <= $inchans} {
		set ofnam $outnam
		append ofnam $n $evv(SNDFILE_EXT)
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset maxsamp_line}
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $ofnam
		wm title .blocker "PLEASE WAIT :      ASSESSING LEVEL IN CHANNEL $n"
		if [catch {open "|$cmd"} CDPidrun] {
			lappend levs -1
			incr n
			continue
   		} else {
   			fileevent $CDPidrun readable "Assemble_Maxsamp_Info"
		}
		vwait prg_dun
		if {!$prg_dun} {
			lappend levs -1
			incr n
			continue
		}
		if {[info exists maxsamp_line]} {
			lappend levs [lindex $maxsamp_line 0]
		} else {
			lappend levs -1
		}
		incr n
	}
	UnBlock
	if {![info exists levs]} {
		Inf "Failed To Extract Levels"
		return
	}
	set len [llength $levs]
	set n 0
	set ch 1
	set msg "CHANNEL LEVELS\n\n"
	while {$n < $len} {
		set val [lindex $levs $n]
		if {$val < 0.0} {
			append msg "Channel $ch: Unknown\n"
		} else {
			append msg "Channel $ch: $val\n"
		}
		incr n
		incr ch
	}
	Inf $msg
}

proc IncrMixAtten {n down} {
	global mix_atten
	if {$down} {
		if {$mix_atten($n) > 0.0} {
			set mix_atten($n) [DecPlaces [expr $mix_atten($n) - 0.02] 2]
			if {[Flteq $mix_atten($n) 0.0]} {
				set mix_atten($n) 0.0
			}
		}
	} else {
		if {$mix_atten($n) < 1.0} {
			set mix_atten($n) [DecPlaces [expr $mix_atten($n) + 0.02] 2]
			if {[Flteq $mix_atten($n) 1.0]} {
				set mix_atten($n) 1.0
			}
		}
	}
}

#################################
#	LINE SELECTION FROM BUTTONS #
#################################

#-------- Select All active mixfile lines

proc QikEditorSelectAll {} {
	global m_list
	set ilist {}
	set i 0
	foreach line [$m_list get 0 end] {
		if {![string match [string index $line 0] ";"]} {
			lappend ilist $i
		}
		incr i
	}
	$m_list selection clear 0 end
	foreach i $ilist {
		$m_list selection set $i
	}
}

proc QikEditorSelectAllOther {} {
	global m_list
	set ilist [$m_list curselection]
	if {([llength $ilist] == 1) && ($ilist == -1)} {
		return
	}
	set i 0
	foreach line [$m_list get 0 end] {
		if {([lsearch $ilist $i] < 0) && ![string match [string index $line 0] ";"]} {
			lappend nuilist $i
		}
		incr i
	}
	$m_list selection clear 0 end
	foreach i $nuilist {
		$m_list selection set $i
	}
}

#----- Select Lines active at specified time

proc QikEditorSelectAtTime {contemp} {
	global mixval lastmixval mlst m_list pa evv wstk
	switch -- $contemp {
		1 {
			set ilist [$m_list curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)  || (([llength $ilist] == 1) && ($ilist == -1))} {
				Inf "No Lines Selected"
				return
			}
			foreach i $ilist {
				set line [$m_list get $i]
				if {[string match [string index $line 0] "\{"]} {
					set line [StripCurlies $line]
				}
				if {[string match ";" [string index $line 0]]} {
					continue
				} else {
					set line [split $line]
					set cnt 0
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						switch -- $cnt {
							0 {
								set dur $pa($item,$evv(DUR))
							}
							1 {
								set time $item
								if {![info exists mintime]} {
									set mintime $time
								} elseif {$time < $mintime} {
									set mintime $time
								}
								set endtime [expr $time + $dur]
								if {![info exists maxtime]} {
									set maxtime $endtime
								} elseif {$endtime > $maxtime} {
									set maxtime $endtime
								}
								break
							}
						}
						incr cnt
					}
				}
			}
			if {![info exists mintime]} {
				Inf "No Active Lines Selected"
				return
			}
		} 
		0 -
		2 {
			if {[string length $mixval] <= 0} {
				Inf "No Time Given In \"Value\" Box"
				return
			} elseif {![IsNumeric $mixval] || ($mixval < 0.0)} {
				Inf "Invalid Time In \"Value\" Box"
				return
			}
			set lastmixval $mixval
			set mintime $mixval
			set maxtime $mixval
		}
	}
	set n 0
	foreach line $mlst {
		if {[string match [string index $line 0] "\{"]} {
			set line [StripCurlies $line]
		}
		if {[string match [string index $line 0] ";"]} {
			incr n
			continue
		}
		set starttime [lindex $line 1]
		if {$contemp == 2} {
			if {![Flteq $starttime $maxtime]} {
				incr n
				continue
			}
		} else {
			if {$starttime >= $maxtime} {
				incr n
				continue
			}
			set fnam [lindex $line 0]
			set dur $pa($fnam,$evv(DUR))
			set endtime [expr $starttime + $dur]
			if {$endtime <= $mintime} {
				incr n
				continue
			}
		}
		lappend ilist $n
		incr n
	}
	if {![info exists ilist]} {
		if {$contemp == 2} {
			set msg "No Active Lines Start At This Time; Search Muted Lines ??"
			set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "yes"} {
				set n 0
				foreach line $mlst {
					if {[string match [string index $line 0] "\{"]} {
						set endline [lrange $line 1 end]
						set line [StripCurlies $line]
					}
					if {![string match [string index $line 0] ";"]} {
						incr n
						continue
					}
					set starttime [lindex $endline 0]
					if {![IsNumeric $starttime] || ![Flteq $starttime $maxtime]} {
						incr n
						continue
					}
					lappend ilist $n
					incr n
				}
				if {![info exists ilist]} {
					Inf "No Lines Start At This Time"
					return
				}
			} else {
				return
			}
		} else {
			Inf "No Lines Are Active At This Time"
			return
		}
	}
	$m_list selection clear 0 end
	foreach i $ilist {
		$m_list	selection set $i
	}
	set i [lindex $ilist 0] 
	if {$i >= $evv(QIKEDITLEN)} {
		set kk [expr double($i) /double([llength $mlst])]
		$m_list	yview moveto $kk
	}
}

#------ Display info returned by maxsamp

proc Assemble_Maxsamp_Info {} {
	global CDPidrun prg_dun maxsamp_line evv
		set prg_dun 0
	if [eof $CDPidrun] {
		catch {close $CDPidrun}
		set prg_dun 1
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		set x 0
		after $evv(DAWDLE) {set x 1}
		vwait x
		if [string match KEEP:* $line] {
			set maxsamp_line [string range $line 6 end]
		} else {
			catch {close $CDPidrun}
			set prg_dun 1
			return
		}
	}
	update idletasks
}

proc TipsQik {} {
	set msg "PROBLEMS WITH MULTICHANNEL MIXER ??\n"
	append msg "\n"
	append msg "Multichannel mixer does not like\n"
	append msg "Comment Lines containing filenames with hyphens (-)"
	Inf $msg
}

proc MixvalIncr {down} {
	global mixval
	if {![IsNumeric $mixval] || ![regexp {^[\-0-9]+$} $mixval]} {
		return
	}
	if {$down} {
		incr mixval -1
	} else {
		incr mixval
	}
}

#------ Display output loudspeakers associated with selected mixfile line

proc ShowStage {} {
	global total_stage_outchans stage_outchans stage_outstage stagcan stage_inchans pr_stage2 is_stage1 stage_inchans_set stage_done_chans stagecnt stage_eight_done 
	global stagemix pa chlist stage_last axcolor stage_fnam stage_chans stage_outlines chchans pr2 evv mm_multichan
	global stage_outbal stage_outlevels readonlybg readonlyfg mchanqikfnam stage_output_chans oct2disp m_list mix_outchans

	if {!$mm_multichan || (($mix_outchans != 5) && ($mix_outchans != 7) && ($mix_outchans != 8))} {
		return
	}
	set klist [$m_list curselection]
	if {([llength $klist] < 1) || (([llength $klist] == 1) && ($klist < 0))} {
		Inf "Choose At Least One Mixfile Line"
		return
	}
	set oct2disp {}
	foreach k $klist {
		catch {unset nuline}
		set line [$m_list get $k]
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set line $nuline
		set routinfo [lrange $line 3 end]
		foreach {rout lev} $routinfo {
			set rout [split $rout ":"]
			if {[lsearch $oct2disp $rout] < 0} {
				lappend oct2disp [lindex $rout 1]
			}
		}
	}
	if {[llength $oct2disp] <= 0} {
		return
	}
	set chchans $mix_outchans
	if {$chchans > 8} {
		Inf "Program Only Handles Files With Maximum Of 8 Input Channels"
		return
	}
	set stage_output_chans $mix_outchans
	set axcolor(1) red
	set axcolor(2) orange
	set axcolor(3) yellow
	set axcolor(4) green
	set axcolor(5) "\{dark green\}"
	set axcolor(6) "\{dark blue\}"
	set axcolor(7) blue
	set axcolor(8) magenta
	set stage_fnam [lindex $chlist 0]
	catch {unset stage_inchans}
	catch {unset stage_outchans}
	set stage_outstage {}
	set total_stage_outchans {}
	set is_stage1 {}
	set stage_done_chans {}
	set stage_inchans_set 0
	set stagecnt 1
	set stage_chans [lindex $chchans 0]
	set f .octagonx
	if [Dlg_Create $f "OUTPUT CHANNELS USED" "set pr_stage2 0" -width 184 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1 -bg black -width 1
		frame $f.2
		frame $f.2.3
		frame $f.2.4 -bg black -width 1
	
		button $f.0.q  -text "Quit"  -command "set pr_stage2 0" -highlightbackground [option get . background {}]
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top -fill x -expand true -pady 4


		set stagcan [canvas $f.2.3.c -height 400 -width 400 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		$stagcan create text 50 14 -text "OUTPUT STAGE" -fill $evv(POINT) -tag setup
		frame $stagcan.ff -bd 0

		pack $f.2.3.c -side left
		pack $f.2.3 -side left
		pack $f.2.4 -side left -fill y -expand true -padx 4
		pack $f.1 $f.2 -side top -pady 2
#		wm resizable $f 0 0
		bind $f <Return> {set pr_stage2 0}
		bind $f <Escape> {set pr_stage2 0}
		bind $f <Key-space> {set pr_stage2 0}
	}
	switch -- $chchans {
		5 {
			EstablishOutputStageDisplay2 5
		}
		7 {
			EstablishOutputStageDisplay2 7
		}
		8 {
			EstablishOutputStageDisplay2 8
		}
	}

	set pr_stage2 0
	raise .octagonx
	update idletasks
	StandardPosition .octagonx
	My_Grab 0 .octagonx pr_stage2
	tkwait variable pr_stage2
	My_Release_to_Dialog .octagonx
	Dlg_Dismiss .octagonx
}

#---- Draw appropriate output stage

proc EstablishOutputStageDisplay2 {n} {
	global stagcan stage_output_chans stage_chans stage_fnam eightchan_stereo_centred evv oct2disp
	set eightchan_stereo_centred 0
	$stagcan delete lspkr
	$stagcan delete lspkrno
	if {$n == 8} {
		set eightchan_stereo_centred 0
	}
	set n 1
	while {$n <= $stage_output_chans} { 
		if {[lsearch $oct2disp $n] >= 0} {
			set thefill($n) "dark magenta"
		} else {
			set thefill($n) [option get . background {}]
		}
		incr n
	}
	set obj [$stagcan find withtag setup]
	$stagcan itemconfig $obj -text ""
	switch --  $stage_output_chans {
		8 {
			if {$eightchan_stereo_centred} {
				$stagcan create line 150 40 250 40 320 110 320 210 250 280 150 280 80 210 80 110 150 40 -width 1 -fill $evv(POINT)
				$stagcan create rect 147 37  153 43  -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT) -fill $thefill(1)
				$stagcan create text 140 30 -text "1" -fill $evv(POINT)  -tag lspkrno
				$stagcan create rect 247 37  253 43  -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT) -fill $thefill(2)
				$stagcan create text 260 30 -text "2" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 317 107 323 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT) -fill $thefill(3)
				$stagcan create text 330 110 -text "3" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT) -fill $thefill(4)
				$stagcan create text 330 210 -text "4" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 247 277 253 283 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT) -fill $thefill(5)
				$stagcan create text 260 290 -text "5" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 147 277 153 283 -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT) -fill $thefill(6)
				$stagcan create text 140 290 -text "6" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 77  207 83  213 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT) -fill $thefill(7)
				$stagcan create text 70 210 -text "7" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 77  107 83  113 -fill [option get . background {}] -tag {lspkr k8} -outline $evv(POINT) -fill $thefill(8)
				$stagcan create text 70 110 -text "8" -fill $evv(POINT) -tag lspkrno
			} else {
				$stagcan create line 200 40 280 90 330 170 280 250 200 300 120 250 70 170 120 90 200 40 -width 1 -fill $evv(POINT)
				$stagcan create rect 197 37 203 43  -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT) -fill $thefill(1)
				$stagcan create text 200 27 -text "1" -fill $evv(POINT)  -tag lspkrno
				$stagcan create rect 277 87  283 93  -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT) -fill $thefill(2)
				$stagcan create text 290 85 -text "2" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 327 167 333 173 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT) -fill $thefill(3)
				$stagcan create text 340 170 -text "3" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 277 247 283 253 -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT) -fill $thefill(4)
				$stagcan create text 290 255 -text "4" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 197 297 203 303 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT) -fill $thefill(5)
				$stagcan create text 200 313 -text "5" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 117 247 123 253 -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT) -fill $thefill(6)
				$stagcan create text 110 255 -text "6" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 67 167 73 173 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT) -fill $thefill(7)
				$stagcan create text 60 170 -text "7" -fill $evv(POINT) -tag lspkrno
				$stagcan create rect 117 87 123 93 -fill [option get . background {}] -tag {lspkr k8} -outline $evv(POINT) -fill $thefill(8)
				$stagcan create text 110 85 -text "8" -fill $evv(POINT) -tag lspkrno
			}
		}
		7 {
			$stagcan create line 80 310 80 210 120 110 200 60 280 110 320 210 320 310 -width 1 -fill $evv(POINT)
			$stagcan create rect 77 307  83 313  -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT) -fill $thefill(5)
			$stagcan create text 70 310 -text "5" -fill $evv(POINT)  -tag lspkrno
			$stagcan create rect 77 207  83 213  -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT) -fill $thefill(6)
			$stagcan create text 70 205 -text "6" -fill $evv(POINT) -tag lspkrno
			$stagcan create rect 117 107 123 113 -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT) -fill $thefill(7)
			$stagcan create text 110 100 -text "7" -fill $evv(POINT) -tag lspkrno
			$stagcan create rect 197  57  203  63 -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT) -fill $thefill(1)
			$stagcan create text 200 50 -text "1" -fill $evv(POINT) -anchor c -tag lspkrno
			$stagcan create rect 277 107 283 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT) -fill $thefill(2)
			$stagcan create text 290 100 -text "2" -fill $evv(POINT) -tag lspkrno
			$stagcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT) -fill $thefill(3)
			$stagcan create text 330 205 -text "3" -fill $evv(POINT) -tag lspkrno
			$stagcan create rect 317 307 323 313 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT) -fill $thefill(4)
			$stagcan create text 330 310 -text "4" -fill $evv(POINT) -tag lspkrno
		}
		5 {
			$stagcan create line 80 210 120 110 200 60 280 110 320 210 -width 1 -fill $evv(POINT)
			$stagcan create rect 77 207  83 213  -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT) -fill $thefill(4)
			$stagcan create text 70 205 -text "4" -fill $evv(POINT) -tag lspkrno
			$stagcan create rect 117 107 123 113 -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT) -fill $thefill(5)
			$stagcan create text 110 100 -text "5" -fill $evv(POINT) -tag lspkrno
			$stagcan create rect 197  57  203  63 -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT) -fill $thefill(1)
			$stagcan create text 200 50 -text "1" -fill $evv(POINT) -tag lspkrno
			$stagcan create rect 277 107 283 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT) -fill $thefill(2)
			$stagcan create text 290 100 -text "2" -fill $evv(POINT) -tag lspkrno
			$stagcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT) -fill $thefill(3)
			$stagcan create text 330 205 -text "3" -fill $evv(POINT) -tag lspkrno
		}
	}
}

#----- Display maxima in each channel of multichan mix output

proc MaxsampMultichanChans {} {
	global plchan evv mix_outchans plchan_max plchan_at plchan_over done_maxsamp maxsamp_line CDPmaxId prg_dun prg_abortd CDPidrun
	global qikkeepfnam qikdelfnams pr_qikmaxchan plchan_secs qikmaxchantime prm

	if {![info exists plchan_max]} {
		set k 1
		while {$k <= $mix_outchans} {
			set file_to_findmax $evv(DFLT_OUTNAME)
			append file_to_findmax "_c" $k $evv(SNDFILE_EXT)
			if {![file exists $file_to_findmax]} {
				set fnam $evv(DFLT_OUTNAME)
				append fnam 0 $evv(SNDFILE_EXT)
				if {![file exists $fnam]} {
					Inf "No Mix To Examine"
					return
				}
				Block "Extracting Channels"
				DeleteAllTemporarySndfilesExcept $fnam
				set fnamsrc $evv(DFLT_OUTNAME)
				set xx_basfnam $fnamsrc 
				append fnamsrc $evv(SNDFILE_EXT)
				if [catch {file copy $fnam $fnamsrc} zit] {
					Inf "Cannot Copy File '$fnam'"
					UnBlock
					return
				}
				set prg_dun 0
				set prg_abortd 0
				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd chans 2 $fnamsrc
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Channel Separation Failed"
					DeleteAllTemporarySndfilesExcept $fnam
					UnBlock
					return
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Channel Separation Failed"
					DeleteAllTemporarySndfilesExcept $fnam
					UnBlock
					return
				}
				set outfnams {}
				set n 1
				while {$n <= $mix_outchans} {
					set outfnam [file rootname $fnamsrc]
					append outfnam "_c" $n $evv(SNDFILE_EXT)
					if {![file exists $outfnam]} {
						Inf "Not All Channels Were Extracted"
						DeleteAllTemporarySndfilesExcept $fnam
						UnBlock
						return
					}
					lappend outfnams $outfnam
					incr n
				}
				UnBlock
				set qikkeepfnam $fnam
				set qikdelfnams $outfnams
			}
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			lappend cmd $file_to_findmax
			catch {unset maxsamp_line}
			set done_maxsamp 0
			if [catch {open "|$cmd"} CDPmaxId] {
				ErrShow "$CDPmaxId"
				return
   			} else {
   				fileevent $CDPmaxId readable "Maxsamp_Info3"
			}
 			vwait done_maxsamp
			catch {close $CDPmaxId}
			if {![info exists maxsamp_line]} {
				set plchan_max($k) unknown
			} else {
				set plchan_at($k) {}
				set valline [lindex $maxsamp_line 0]
				set valline [StripCurlies $valline]
				set valline [split $valline]
				set plchan_max($k) [lindex $valline end]
				if {$plchan_max($k) > 0.99} {
					set plchan_over($k) "***"
				} else {
					set plchan_over($k) ""
				}
				set locline [lindex $maxsamp_line 1]
				set locline [StripCurlies $locline]
				set locline [split $locline]
				set cnt 0
				foreach item $locline {
					set item [string trim $item]
					if {[string length $item] > 0} {
						incr cnt
						if {$cnt >= 6} {
							lappend plchan_at($k) $item
						}
					}
				}
				set plchan_secs($k) [expr ([lindex $plchan_at($k) 0] * 60.0) + [lindex $plchan_at($k) 2]]
				set plchan_at($k) $plchan_secs($k)
				set plchan_secs($k) [expr $plchan_secs($k) + $prm(0)]
			}
			incr k
		}
	}
	set f .qikmaxchan
	set qikmaxchantime 0
	if [Dlg_Create $f "MAXIMUM LEVELS IN CHANNELS" "set pr_qikmaxchan 0" -width 120] {
		frame $f.0
		button $f.0.qu -text "Quit" -command {set pr_qikmaxchan 0} -highlightbackground [option get . background {}]
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.rr -text ""
		set n 0
		grid $f.1.rr -row 0 -column 0 -sticky ew
		label $f.1.ll1_$n -text "Channel: "
		label $f.1.ll2_$n -text "Absolute Time: "
		label $f.1.ll3_$n -text "Time from mix start: "
		label $f.1.ll4_$n -text "Max: "
		label $f.1.ll5_$n -text "Overload?"
		grid $f.1.ll1_$n -row $n -column 1 -sticky ew
		grid $f.1.ll2_$n -row $n -column 2 -sticky ew
		grid $f.1.ll3_$n -row $n -column 3 -sticky ew
		grid $f.1.ll4_$n -row $n -column 4 -sticky ew
		grid $f.1.ll5_$n -row $n -column 5 -sticky ew
		incr n
		while {$n <= $mix_outchans} {
			radiobutton $f.1.rr_$n -variable qikmaxchantime -value $n -command "QikMaxChanTimeGet"
			grid $f.1.rr_$n -row $n -column 0 -sticky ew
			label $f.1.ll1_$n -text "$n:"
			label $f.1.ll2_$n -text "$plchan_secs($n)"
			label $f.1.ll3_$n -text "$plchan_at($n)"
			label $f.1.ll4_$n -text "$plchan_max($n)"
			label $f.1.ll5_$n -text "$plchan_over($n)"
			grid $f.1.ll1_$n -row $n -column 1 -sticky ew
			grid $f.1.ll2_$n -row $n -column 2 -sticky ew
			grid $f.1.ll3_$n -row $n -column 3 -sticky ew
			grid $f.1.ll4_$n -row $n -column 4 -sticky ew
			grid $f.1.ll5_$n -row $n -column 5 -sticky ew
			incr n
		}
		pack $f.1 -side top -pady 4
		label $f.2 -text "Select Time to send to QikEditor, with buttons at right" -fg $evv(SPECIAL)
		pack $f.2 -side top -pady 4
#		wm resizable $f 0 0
		bind $f <Return> {set pr_qikmaxchan 0}
		bind $f <Escape> {set pr_qikmaxchan 0}
		bind $f <Key-space> {set pr_qikmaxchan 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_qikmaxchan 0
	My_Grab 0 $f pr_qikmaxchan
	tkwait variable pr_qikmaxchan
	My_Release_to_Dialog .qikmaxchan
	Dlg_Dismiss .qikmaxchan
	destroy .qikmaxchan
}

#---- Time of channel peak to QikEditor Value Box

proc QikMaxChanTimeGet {} {
	global qikmaxchantime plchan_secs pr_qikmaxchan mixval
	set mixval $plchan_secs($qikmaxchantime)
	set pr_qikmaxchan 0
}

#--- Check Escape is valid !!

proc QikEscape {} {
	global pr12_34 initial_mlst mlst wstk
	set rewrite 0
	set len [llength $initial_mlst]
	if {[llength $mlst] != $len} {
		set rewrite 1
	} else {
		set n 0
		while {$n < $len} {
			catch {unset nuline}
			set line [lindex $mlst $n]
			set origline [lindex $initial_mlst $n]
			set line [split $line]
			foreach item $line  {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set line $nuline
			catch {unset nuline}
			set origline [split $origline]
			foreach item $origline  {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set origline $nuline
			if {![string match $origline $line]} {
				set rewrite 1
				break
			}
			incr n
		}
	}
	if {$rewrite} {
		set msg "Quit without Saving ?"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			return
		}
	}
	set pr12_34 0
}

#---- Move up and down qikedit display, using Up Down keys

proc QikNext {up} {
	global mixd2
	set len [$mixd2.1.see.1.seefile.list index end] 
	set i [$mixd2.1.see.1.seefile.list curselection]
	if {$i < 0} {
		return
	}
	if {[llength $i] > 1} {
		return
	}
	if {$up} {
		incr i -1
		if {$i < 0} {
			set i [expr $len - 1]
		}
	} else {
		incr i
		if {$i >= $len} {
			set i 0
		}
	}
	$mixd2.1.see.1.seefile.list selection clear 0 end
	$mixd2.1.see.1.seefile.list selection set $i
}

#---- Deal with fractional mono positions

proc MonoInterspkrPosition {pos lev} {
	global mix_outchans  
	if {$pos < 1} {
		set pos [expr $pos + double($mix_outchans)]
	}
	set lpos [expr int(floor($pos))]
	set rpos [expr $lpos + 1]
	if {$rpos > $mix_outchans} {
		set rpos [expr $rpos - $mix_outchans]
	}
	set stereopos [expr $pos - double($lpos)]
	set rlev [expr $stereopos * $lev]
	set llev [expr (1.0 - $stereopos) * $lev]
	set lrout "1:$lpos"
	set rrout "1:$rpos"
	set routinfo [list $lrout $llev $rrout $rlev]
	return $routinfo
}

#---- Don't reset tempmix if, by accident, no lines hilighted

proc TempmixReset {} {
	global dont_undo_tempmix tempmix
	if {![info exists dont_undo_tempmix]} {
		set tempmix 1
	} else {
		unset dont_undo_tempmix
	}
}

#----- Select Lines having (or not having) specified number of input channels

proc QikEditorSelectInchans {nothave} {
	global mixval lastmixval mlst m_list evv
	if {([string length $mixval] <= 0) || ![regexp {^[0-9]+$} $mixval] || ($mixval == 0)} {
		Inf "INVALID CHANNEL COUNT ENTERED IN \"Value\""
		return
	}
	set lastmixval $mixval
	set i 0
	foreach line [$m_list get 0 end] {
		if {[string match [string index $line 0] "\{"]} {
			set line [StripCurlies $line]
		}
		if {[string match ";" [string index $line 0]]} {
			incr i
			continue
		} else {
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					2 {
						switch -- $nothave {
							0 {
								if {$item == $mixval} {
									lappend ilist $i
								}
							}
							1 {
								if {$item != $mixval} {
									lappend ilist $i
								}
							}
							2 {
								if {$item <= $mixval} {
									lappend ilist $i
								}
							}
							3 {
								if {$item > $mixval} {
									lappend ilist $i
								}
							}
						}
						break
					}
				}
				incr cnt
			}
			incr i
			if {$cnt < 2} {
				Inf "INVALID LINE ($i) ENCOUNTERED\n\n$line"
				return
			}
		}
	}
	if {![info exists ilist]} {
		Inf "NO MIXFILE LINES HAVE $mixval INPUT CHANNELS"
		return
	}
	$m_list selection clear 0 end
	foreach i $ilist {
		$m_list	selection set $i
	}
	set i [lindex $ilist 0] 
	if {$i >= $evv(QIKEDITLEN)} {
		set kk [expr double($i)/double([llength $mlst])]
		$m_list	yview moveto $kk
	}
}

proc CollapseMix {} {
	global mixval mix_outchans m_list mm_multichan pr_collapse collapsename mix_outchans
	set msga "This Option Collapses A Multichannel Mix With Mono Or Stereo Input Files (ONLY)\n"
	append msga "To A Standard Stereo Mixfile Format\n"
	if {!$mm_multichan} {
		Inf $msga
		return
	}
	set msg $msga
	append msg "\n"
	append msg "Specify Which Outputs Are To Go To The Left Channel Of The Stereo\n"
	append msg "And Which Outputs Are To Go To The Right, In Format Left:Right\n"
	append msg "e.g. \"7=8:2=3\" Means Data Being Output To Channels 7 & 8 Is To Go To The Left,\n"
	append msg "And Data Being Output To Channels 2 & 3 Is To Go To The Right\n"
	append msg "(All Output Routings Of The Multichannel Mix Must Be Accounted For).\n"
	if {[string first ":" $mixval] < 1} {
		Inf $msg
		return
	}
	set inval [split $mixval ":"]
	if {[llength $inval] != 2} {
		Inf $msg
		return
	}
	set leftchans [lindex $inval 0]
	if {[string first "=" $leftchans] > 0} {
		set leftchans [split $leftchans "="]
	}
	set rightchans [lindex $inval 1]
	if {[string first "=" $rightchans] > 0} {
		set rightchans [split $rightchans "="]
	}
	foreach chan $leftchans {
		if {![regexp {^[0-9]+$} $chan] || ($chan < 1) || ($chan > $mix_outchans)} {
			Inf "\"$chan\" Is Not A Valid Output Routing In This Multichannel Mixfile"
			Inf $msg
			return
		}
	}
	foreach chan $rightchans {
		if {![regexp {^[0-9]+$} $chan] || ($chan < 1) || ($chan > $mix_outchans)} {
			Inf "\"$chan\" Is Not A Valid Output Routing In This Multichannel Mixfile"
			Inf $msg
			return
		}
	}
	foreach chanl $leftchans {
		foreach chanr $rightchans {
			if {$chanl == $chanr} {
				Inf "You Cannot Reroute Data From Out-route $chanl To Both Left And Right Channels"
				return
			}
		}
	}
	set i 0
	set incnt 1
	foreach line [$m_list get 0 end] {
		if {[string match [string index $line 0] "\{"]} {
			set line [StripCurlies $line]
		}
		if {[string match ";" [string index $line 0]]} {
			incr incnt
			continue
		} else {
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			set leftlevcnt 0
			set rightlevcnt 0
			set leftlev 0.0
			set rightlev 0.0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						set snd $item				
					}
					1 {
						set tim $item				
					}
					2 {
						if {$item > 2} {
							Inf "Line $incnt Has Too Many Input Channels For This Option"
							return
						}
						set chn $item				
					}
					default {
						if {![IsEven $cnt]} {
							set rout [split $item ":"]
							set rout [lindex $rout 1]
							if {[lsearch $leftchans $rout] >= 0} {
								set nextlev "llev"
							} elseif {[lsearch $rightchans $rout] >= 0} {
								set nextlev "rlev"
							} else {
								Inf "In Line $incnt Output-Channel-Routings Not Specified By You Are Used: Cannot Proceed"
								return
							}
						} else {
							switch -- $nextlev {
								"llev" {
									set leftlev [expr $leftlev + $item]
									incr leftlevcnt
								}
								"rlev" {
									set rightlev [expr $rightlev + $item]
									incr rightlevcnt
								}
							}
						}
					}
				}
				incr cnt
			}
			set leftlev  [expr $leftlev/double($leftlevcnt)]			
			set rightlev [expr $rightlev/double($rightlevcnt)]			
			set nuline [concat $snd $tim $chn]
			if {$chn == 1} {
				set nuline2 $nuline
				lappend nuline2 $leftlev "L"
				lappend nuline $rightlev "R"
				lappend nulines $nuline2
			} else {
				lappend nuline $leftlev "L" $rightlev "R"
			}
			lappend nulines $nuline
		}
	}
	if {![info exists nulines]} {
		Inf "Failed To Create New Mix Stereo File"
		return
	}
	set f .collapse
	if [Dlg_Create $f "NAME OF STEREO MIX" "set pr_collapse 0" -width 120] {
		frame $f.0
		button $f.0.ok -text "Save" -command {set pr_collapse 1} -highlightbackground [option get . background {}]
		button $f.0.qu -text "Quit" -command {set pr_collapse 0} -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.rr -text "Mixfile Name "
		entry $f.1.e -textvariable collapsename -width 40
		pack $f.1.rr $f.1.e -side left
		pack $f.1 -side top -pady 4
		set collapsename ""
#		wm resizable $f 0 0
		bind $f <Escape> {set pr_collapse 0}
		bind $f <Return> {set pr_collapse 1}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_collapse 0
	set finished 0
	My_Grab 0 $f pr_collapse $f.1.e
	while {!$finished} {
		tkwait variable pr_collapse
		if {$pr_collapse} {
			if {[string length $collapsename] <= 0} {
				Inf "No Mixfile Name Entered"
				continue
			}
			if {![ValidCDPRootname $collapsename]} {
				continue
			}
			set outname $collapsename
			append outname [GetTextfileExtension mix]
			if {[file exists $outname]} {
				Inf "File $outname Exists: Please Choose A Different Name"
				continue
			}
			if [catch {open $outname "w"} zit] {
				Inf "Cannot Open File $outname To Write New Mixdata"
				continue
			}
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outname 0 0 0 0 1
			Inf "File $outname Is On The Workspace"
			set finished 1
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Reroute group of mono input files each currently routed to single output chans, to different set of output chans

proc RemapRouting {linestore val} {
	global mix_outchans

	set val [string trim $val]
	set val [split $val]
	foreach item $val {
		string trim $item
		if {[string length $item] <= 0} {
			continue
		}
		lappend nuvals $item
	}
	if {![info exists nuvals] || [llength $nuvals] != 2} {
		Inf "Invalid Remapping Information (List of Output Chans Separated By Commas)"
		return {}
	}
	set outchans [lindex $nuvals 1]
	set outchans [split $outchans ","]
	set len 0
	foreach item $outchans {
		if {![regexp {^[0-9]+$} $item] || ($item < 1) || ($item > $mix_outchans)} {
			Inf "Invalid Output Channel ($item)"
			return {}
		}
		incr len
	}
	if {$len != [llength $linestore]} {
		Inf "Number Of Mapping Channels Does Not Match Number Of Lines Selected"
		return {}
	}
	set k 0
	foreach line $linestore {
		set inchan [lindex $line 2]
		if {$inchan != 1} {
			Inf "Remapping Only Works With Mono Files"
			return {}
		}
		set routinfo [lrange $line 3 end]
		if {[llength $routinfo] != 2} {
			Inf "Remapping Only Works With Mono Files Routed To Single Outchannels"
			return {}
		}
		set rout [lindex $routinfo 0]
		set rout [split $rout ":"]
		set rout [lindex $rout 0]
		append rout ":" [lindex $outchans $k]
		set routinfo [lreplace $routinfo 0 0 $rout]
		lappend routinfos $routinfo
		incr k
	}
	return $routinfos
}

#--- Reroute outfiles to next channel (1->2 2->3 etc)

proc TurnRouting {linestore val} {
	global mix_outchans

	set val [string trim $val]
	set val [split $val]
	if {[llength $val] > 1} {
		Inf "Invalid Routing Info"
		return {}
	}
	set val [lindex $val 0]
	if {[string length $val] == 1} {
		set push 1
	} else {
		set push [string range $val 1 end]
		if {![regexp {^[0-9]+$} $push] || ($push < 1) || ($push > 16)} {
			Inf "Invalid Routing Info"
			return {}
		}
	}
	foreach line $linestore {
		set routinfo [lrange $line 3 end]
		set len [llength $routinfo]
		set n 0
		while {$n < $len} {
			set rout [lindex $routinfo $n]
			set rout [split $rout ":"]
			set rin  [lindex $rout 0]
			set rto  [lindex $rout 1]
			incr rto $push
			while {$rto > $mix_outchans} {
				incr rto -$mix_outchans
			}
			set rout $rin
			append rout ":" $rto
			set routinfo [lreplace $routinfo $n $n $rout]
			incr n 2
		}
		lappend routinfos $routinfo
	}
	set routinfos [ReverseList $routinfos]
	return $routinfos
}

proc ChangeAsPattern {} {
	global pr_chasp chasperm1 chasperm2 qikpperm
	set f .chasp
	if [Dlg_Create $f "CHANGE BY PERMUTING ORDER" "set pr_chasp 0" -width 120] {
		frame $f.0
		button $f.0.ok -text "Permute" -command {set pr_chasp 1}
		button $f.0.qu -text "Quit" -command {set pr_chasp 0}
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.rr -text "Original order"
		entry $f.1.e -textvariable chasperm1 -width 40
		pack $f.1.rr $f.1.e -side left
		pack $f.1 -side top -pady 4
		frame $f.2
		label $f.2.rr -text "Final order"
		entry $f.2.e -textvariable chasperm2 -width 40
		pack $f.2.rr $f.2.e -side left
		pack $f.2 -side top -pady 4
		wm resizable $f 0 0
		bind $f <Escape> {set pr_chasp 0}
		bind $f <Return> {set pr_chasp 1}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_chasp 0
	set finished 0
	My_Grab 0 $f pr_chasp $f.1.e
	while {!$finished} {
		tkwait variable pr_chasp
		if {$pr_chasp} {
			if {([string length $chasperm1] <= 0) || ([string length $chasperm2] <= 0)} {
				Inf "At Least One Of The Permutation Strings Is Empty"
				continue
			}
			if {![regexp {^[0-9a-zA-Z]+$} $chasperm1]} {
				Inf "Permutation String 1 Has (Some) None-Alphanumeric Characters"
				continue
			}
			if {![regexp {^[0-9a-zA-Z]+$} $chasperm2]} {
				Inf "Permutation String 2 Has (Some) None-Alphanumeric Characters"
				continue
			}
			if {[string length $chasperm1] != [string length $chasperm2]} {
				Inf "Permutation Strings Are Not Same Length"
				continue
			}
			set len [string length $chasperm1]
			set len_less_one [expr $len - 1]
			set n 0
			set OK 1
			while {$n < $len_less_one} {
				set cn [string index $chasperm1 $n]
				set m $n
				incr m
				while {$m < $len} {
					set cm [string index $chasperm1 $m]
					if {$cn == $cm} {
						Inf "Duplicated Character ($cn) In Permutation String 1"
						set OK 0
						break
					}
					incr m
				}
				if {!$OK} {
					break
				}
				incr n
			}
			if {!$OK} {
				continue
			}
			set n 0
			set OK 1
			while {$n < $len_less_one} {
				set cn [string index $chasperm2 $n]
				set m $n
				incr m
				while {$m < $len} {
					set cm [string index $chasperm2 $m]
					if {$cn == $cm} {
						Inf "Dupicated Character ($cn) In Permutation String 2"
						set OK 0
						break
					}
					incr m
				}
				if {!$OK} {
					break
				}
				incr n
			}
			if {!$OK} {
				continue
			}
			set n 0
			catch {unset perm}
			while {$n < $len} {
				set cn [string index $chasperm1 $n]
				set m 0
				set OK 0
				while {$m < $len} {
					set cm [string index $chasperm2 $m]
					if {$cn == $cm} {
						set OK 1
						lappend perm $m
						break
					}
					incr m
				}
				if {!$OK} {
					break
				}
				incr n
			}
			if {!$OK} {
				Inf "PERMUTATION STRINGS DO NOT CONTAIN (ALL) THE SAME CHARACTERS"
				continue
			}
			set qikpperm $perm
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc MixTwist {} {
	global pr_mxtwist mxtwister mxtwistep qiktwist mix_outchans
	set f .mxtwist
	if [Dlg_Create $f "TWISTING THE MIX" "set pr_mxtwist 0" -width 120] {
		frame $f.0
		button $f.0.ok -text "Twist" -command {set pr_mxtwist 1}
		button $f.0.qu -text "Quit" -command {set pr_mxtwist 0}
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.rr -text "Twist by N chans"
		entry $f.1.e -textvariable mxtwister -width 40
		pack $f.1.rr $f.1.e -side left
		pack $f.1 -side top -pady 4
		frame $f.2
		label $f.2.rr -text "Twist Step : increment twist after M lines"
		entry $f.2.e -textvariable mxtwistep -width 40
		pack $f.2.rr $f.2.e -side left
		pack $f.2 -side top -pady 4
		wm resizable $f 0 0
		bind $f <Escape> {set pr_mxtwist 0}
		bind $f <Return> {set pr_mxtwist 1}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_mxtwist 0
	set finished 0
	My_Grab 0 $f pr_mxtwist $f.1.e
	while {!$finished} {
		tkwait variable pr_mxtwist
		if {$pr_mxtwist} {
			if {[string length $mxtwister] <= 0} {
				Inf "No Twist Value Entered"
				continue
			}
			if {![IsNumeric $mxtwister] || ![regexp {^[0-9\-]+$} $mxtwister] || ($mxtwister == 0)} {
				Inf "Invalid Twist Value : +ve Or -ve Integer""
				continue
			}
			if {[string length $mxtwistep] <= 0} {
				Inf "No Twist Step Value Entered"
				continue
			}
			if {![IsNumeric $mxtwistep] || ![regexp {^[0-9]+$} $mxtwistep] || ($mxtwistep < 0)} {
				Inf "Invalid Twist Step (> 0)"
				continue
			}
			while {$mxtwister < 0} {
				incr mxtwister $mix_outchans
			}
			set qiktwist [list $mxtwister $mxtwistep]
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Get position data in a multichannel mixfile line

proc MixPosget {m_list} {
	global mixval lastmixval wstk mm_multichan
	set is_comment 0
	set bum 0
	set ilist [$m_list curselection]
	if {[llength $ilist] != 1} {
		Inf "Select just one line, for this option"
		return
	}
	set line [$m_list get $ilist]
	if {[string match [string index $line 0] ";"]} {
		set line [string range $line 1 end]
		set is_comment 1
	}
	if {$is_comment} {
		set msg "Is this a valid muted mix line ??"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			return
		}
	}
	set lastmixval mixval
	if {$mm_multichan} {
		set line [lrange $line 3 end]
	} else {
		set len   [llength $line]
		switch -- $len {
			4 { 
				set chans [lindex $line 2]
				set lev   [lindex $line 3]
				if {$chans == 1} {
					set line "C"
				} else {
					set line [list $lev L $lev R]
				}
			}
			5 {
				set line [lindex $line 4]
			}
			7 {
				set line [lrange $line 3 end]
			}
		}
	}
	set mixval $line
}


proc FindQuantisationDuration {} {
	global segment pr_qbeat evv wstk
	set segment(dirname) [file join $evv(URES_DIR) segdir]
	if {![file exists $segment(dirname)]} {
		Inf "There are no existing tempo files"
		return 0
	}
	catch {unset segment(MM)}
	foreach fnam [glob -nocomplain [file join $segment(dirname) *]] {
		set basfnam [file rootname [file tail $fnam]]
		if {[string first "_mm" $basfnam] == [expr [string length $basfnam] - 3]} {	;#	If file has "beat" extension
			lappend segment(MM) $fnam											;#	List it
		}
	}
	if {![info exists segment(MM)]} {
		Inf "There are no existing tempo files"
		return 0
	}
	set f .qbeat
	if [Dlg_Create $f "SELECT TEMPO (MM)" "set pr_qbeat 0" -width 120] {
		frame $f.0
		button $f.0.ok -text "Select" -command {set pr_qbeat 1}
		button $f.0.qu -text "Quit" -command {set pr_qbeat 0}
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		Scrolled_Listbox $f.1.ll -width 64 -height 32 -selectmode single
		pack $f.1.ll -side top -pady 4
		pack $f.1 -side top -fill both -expand true
		wm resizable $f 0 0
		bind $f <Escape> {set pr_qbeat 0}
		bind $f <Return> {set pr_qbeat 1}
	}
	$f.1.ll.list delete 0 end
	foreach fnam $segment(MM) {
		set fnam [file rootname [file tail $fnam]]
		set len [string length $fnam]
		set item [string range $fnam 0 [expr $len - 4]]
		$f.1.ll.list insert end $item
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_qbeat 0
	set finished 0
	My_Grab 0 $f pr_qbeat $f.1.ll.list
	while {!$finished} {
		tkwait variable pr_qbeat
		switch -- $pr_qbeat {
			1 {
				set i [$f.1.ll.list curselection]
				if {$i < 0} {
					Inf "No item selected"
					continue
				}
				set fnam [lindex $segment(MM) $i]
				if [catch {open $fnam "r"} zit] {
					Inf "Cannot open file $fnam to read tempo (mm)"
					continue
				}
				set OK 0
				set warned 0
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					if {![IsNumeric $line] || ($line <= 0.0)} {
						Inf "Invalid tempo ($line) in file $fnam"
						set warned 1
						break
					}
					set mm $line
					set OK 1
					break
				}
				close $zit
				if {!$OK} {
					if {!$warned} {
						Inf "No tempo data found in file $fnam"
					}
					continue
				}
				set segment(qbeat) [expr 60.0/double($mm)]
				set msg "Tempo : MM $mm : (Beat Duration $segment(qbeat)) OK ??"
				set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "no"} {
					continue
				}
				set finished 1
			}
			0 {
				set segment(qbeat) 0.0
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $segment(qbeat)
}

#--- Random succession of stereo pans across multichannel space: takes a mixfile or multichan mixfile

proc MultiChanRandStereoPan {} {
	global hopperm chlist wl evv pa pr_mstpan mstpanchans mstpanchans_in mstpanfnam mstpan_reuse mstpan_doubled mstpan_bigstep rememd wstk mstpan_multichan_in
	set OK 0
	set mstpan_multichan_in 0 
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set mfnam [lindex $chlist 0]
		if {[IsAMixfile $pa($mfnam,$evv(FTYP))]} {
			set OK 1
		} elseif {[IsAMixfileIncludingMultichan $pa($mfnam,$evv(FTYP))]} {
			set OK 1
			set mstpan_multichan_in 1
		}
	}
	if {!$OK} {
		set ilist [$wl curselection]
		if {[llength $ilist] == 1} {
			set mfnam [$wl get [lindex $ilist 0]]
			if {[IsAMixfile $pa($mfnam,$evv(FTYP))]} {
				set OK 1
			}
			if {[IsAMixfileIncludingMultichan $pa($mfnam,$evv(FTYP))]} {
				set OK 1
				set mstpan_multichan_in 1
			}
		}
	}
	if {!$OK} {
		Inf "Select a mixfile containing stereo files only, or a multichannel mixfile with stereo files in it"
		return
	}
	if [catch {open $mfnam "r"} zit] {
		Inf "Cannot open mixfile $mfnam to read it"
		return
	}
	set stereocnt 0
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match ";" [string index $line 0]]} {
			continue
		}
		set line [split $line]
		set cnt 0
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {$mstpan_multichan_in && ($linecnt == 0)} {
				set mstpanchans_in $item
			}
			if {$cnt == 2} {
				if {$mstpan_multichan_in} {
					if {$item == 2} {
						incr stereocnt
					}
				} else {
					if {$item != 2} {
						Inf "File [file rootname [file tail $item]] in the mixfile is not a stereo file"
						close $zit
						return
					}
				}
			}
			lappend nuline $item
			incr cnt
		}
		lappend nulines $nuline
		incr linecnt
	}
	close $zit
	if {![info exists nulines]} {
		Inf "No valid lines found in mixfile $mfnam"
		return
	}

	if {$mstpan_multichan_in && ($stereocnt < 2) } {
		Inf "Not more than one stereo file found in mixfile $mfnam"
		return
	}
	set inlines $nulines

	set f .mstpan
	if [Dlg_Create $f "CREATE RANDPANNED STEREOS" "set pr_mstpan 0" -width 120] {
		frame $f.0
		button $f.0.ok -text "Create" -command {set pr_mstpan 1}
		button $f.0.qu -text "Abandon" -command {set pr_mstpan 0}
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output Channel count" -width 20
		entry $f.1.e -textvariable mstpanchans -width 4
		frame $f.1.1
		checkbutton $f.1.1.ch -text "Pan in PAIRS of adjacent channels" -variable mstpan_doubled
		checkbutton $f.1.1.ch2 -text "NO STEPS to adjacent chan (8,16 chan)" -variable mstpan_bigstep
		set mstpan_doubled 0
		set mstpan_bigstep 0
		pack $f.1.1.ch $f.1.1.ch2 -side top -anchor w
		pack $f.1.ll $f.1.e $f.1.1 -side left
		pack $f.1 -side top -fill both -expand true
		frame $f.2
		label $f.2.ll -text "Multichan Mixfile Name"
		entry $f.2.e -textvariable mstpanfnam -width 32
		checkbutton $f.2.ch -text "Reuse Name of input mixfile" -variable mstpan_reuse
		pack $f.2.ll $f.2.e $f.2.ch -side left
		pack $f.2 -side top -fill both -expand true
		wm resizable $f 0 0
		bind $f <Escape> {set pr_mstpan 0}
		bind $f <Return> {set pr_mstpan 1}
	}
	if {$mstpan_multichan_in} {
		set mstpanfnam [file rootname [file tail $mfnam]]
		set mstpan_reuse 0
	} else {
		set mstpan_reuse 1
	}
	if {$mstpan_multichan_in} { 
		$f.1.ll config -text ""
		set mstpanchans ""
		$f.1.e  config -state disabled -bd 0 -bg [option get . background {}]
	} else {
		$f.1.ll config -text "Output Channel count"
		$f.1.e  config -state normal -bd 2
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_mstpan 0
	set finished 0
	My_Grab 0 $f pr_mstpan $f.1.e
	while {!$finished} {
		tkwait variable pr_mstpan
		switch -- $pr_mstpan {
			1 {
				if {$mstpan_doubled} {
					set minchans 5
				} else {
					set minchans 4
				}
				if {$mstpan_multichan_in} {
					set mstpanchans $mstpanchans_in
				} else {
					if {[string length $mstpanchans] <= 0} {
						Inf "No output channel count entered"
						continue
					}
					if {![IsNumeric $mstpanchans] || ![regexp {^[0-9]+$} $mstpanchans]} {
						Inf "Invalid output channel count"
						continue
					}
					if {($mstpanchans < $minchans) || ($mstpanchans > 16)} {
						if {$mstpan_doubled} {
							set msg "Output channel count out of range : must be at least 5 for paired-channel panning (and no more than 16)"
						} else {
							set msg "Output channel count out of range : must be at least 4 (and no more than 16)"
						}
						Inf $msg
						continue
					}
				}
				if {$mstpan_bigstep} {
					if {($mstpanchans != 8) && ($mstpanchans != 16)} {
						Inf "Invalid channel count: must be 8 or 16 to avoid stepping to an adjacent pair"
						continue
					}
				}
				if {$mstpan_reuse} {
					set ofnam [file rootname $mfnam]
				} else {
					set ofnam [string tolower $mstpanfnam]
					if {![ValidCDPRootname $ofnam]} {
						continue
					}
				}
				append ofnam [GetTextfileExtension mmx]
				if {[file exists $ofnam]} {
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message "FILE EXISTS: OVERWRITE IT ?"]
					if {$choice == "no"} {
						if {$mstpan_reuse} {
							set mstpan_reuse 0
						}
						continue
					}
					if {![DeleteFileFromSystem $ofnam 0 1]} {
						Inf "Cannot delete existing file $ofnam"
						continue
					} else {
						DummyHistory $ofnam "DESTROYED"
						if {[IsInAMixfile $ofnam]} {
							if {[MixM_ManagedDeletion $ofnam]} {
								MixMStore
							}
						}
						set i [LstIndx $ofnam $wl]	;#	remove from workspace listing, if there
						if {$i >= 0} {
							$wl delete $i
							WkspCnt $ofnam -1
							catch {unset rememd}
						}
					}
				}
				set mchans $mstpanchans
				set double $mstpan_doubled

				set lastperm -1
				catch {unset nulines}
				set nulines $mchans

				if {$mstpan_bigstep} {								;#	Look for mutual primes of 8 and 16, which are not 1 or (chans-1)
					if {$mchans == 8} {
						set k [expr int(floor(rand() * 2.0))]		;#	Range 0.0 to < 2.0 --> 0 or 1
					} else {
						set k [expr int(floor(rand() * 6.0))]		;#	Range 0.0 to < 6.0 --> 0 1 2 3 4 5
					}
					set k [expr (($k+1) * 2) + 1]					;#	(k+1) 1 2 (*2) 2 4 (+1) 3 5  OR
																	;#	(k+1) 1 2 3 4 5 6 (*2) 2 4 6 8 10 12 (+1) 3 5 7 9 11 13
					set hopperm [expr int(floor(rand() * $mchans))]	;#	Start at an arbitrary channel 0 1 2 .... N
					set lastperm $hopperm
					set j 1
					while {$j < $mchans} {							;#	Step round start chan in odd no of counts > 1 & not (equivalent of) -1
						set nextperm [expr ($lastperm + $k) % $mchans]
						lappend hopperm $nextperm
						set lastperm $nextperm 
						incr j
					}
				} else {
					randperm $mchans								;#	PERMUTE the N multichans
				}
				set lastperm [lindex $hopperm end]					;#	Remember final perm value
				set pancnt 0
				set linecnt 1
				foreach line $inlines {
					if {$mstpan_multichan_in} {
						if {$linecnt == 1} {
							set bad_levels ""
							lappend nulines $line
							incr linecnt
							continue
						}
					}
					if {$mstpan_multichan_in} {
						set inchans [lindex $line 2]
						if {$inchans != 2} {
							lappend nulines $line
							incr linecnt
							continue
						} else {
							set nuline [lrange $line 0 2]			;#	i.e. copy fnam time and orig chancnt (stereo)
							set len [llength $line]
							set k 3
							set j 4
							set f_nam [file rootname [file tail [lindex $line 0]]]
							set llev 0
							set rlev 0
							set llev_warned 0
							set rlev_warned 0
							while {$k < $len} {						;#	Set left and right levels to max levels used in input
								set inrout [lindex $line $k]
								set inrout [string index $inrout 0]
								if {$inrout == 1} {
									if {($llev > 0) && ([lindex $line $j] != $llev)} {
										if {!$llev_warned} {
											append bad_levels "Ambiguous left channel level for file $f_nam, line $linecnt : using MAX\n"
											set llev_warned 1
										}
									}
									if {[lindex $line $j] > $llev} {
										set llev [lindex $line $j]
									}
								} elseif {$inrout == 2} {
									if {($rlev > 0) && ([lindex $line $j] != $rlev)} {
										if {!$rlev_warned} {
											append bad_levels "Ambiguous right channel level for file $f_nam, line $linecnt : using MAX\n"
											set rlev_warned 1
										}
									}
									if {[lindex $line $j] > $rlev} {
										set rlev [lindex $line $j]
									}
								}
								incr k 2
								incr j 2
							}
							if {$llev == 0} {
								append bad_levels "No left channel level for file $f_nam, line $linecnt : defaulting to 1\n"
								set llev 1
							}
							if {$rlev == 0} {
								append bad_levels "No right channel level for file $f_nam, line $linecnt : defaulting to 1\n"
								set rlev 1
							}
						}	
					} else {
						set nuline [lrange $line 0 2]
						if {[llength $line] == 4} {	
							set llev [lindex $line 3]
							set rlev [lindex $line 3]
						} else {
							set llev [lindex $line 3]
							set rlev [lindex $line 5]
						}
					}
					set pan [lindex $hopperm $pancnt]
																	;#	IN 0-7 (MOD 8) FRAME
					set L1 [expr $pan % $mchans]					;#	e.g.	pan	0					pan 5					pan 7
					set R1 [expr ($L1 + 2) % $mchans]				;#			from 0 to 2				from 5 to 7				9 -> 1
																	;#															from 7 to 1 
					if {$double} {									;#	
						set L2 [expr $L1 - 1]						;#			-1 -> 7					4						6
						if {$L2 < 0} {								;#			 
							incr L2 $mchans							;#
						}											;#			11 -> 3					8 -> 0					10 -> 2
						set R2 [expr ($L2 + 4) % $mchans]			;#			from 7 to 3				from 4 to 0				from 6 to 2															
					}												;#
					incr L1											;#	IN 1-8 (CHANNELS) FRAME
					incr R1											;#
					set rout [list "1:$L1" $llev "2:$R1" $rlev]		;#			from 1 to 3				from 6 to 8				from 8 to 2
					if {$double} {									;#			from 8 to 4				from 5 to 1				from 7 to 3
						incr L2										;#
						incr R2										;#
						lappend rout "1:$L2" $llev "2:$R2" $rlev	;#				x1						x1						o
					}												;#		  x8		  o			  x8		  o			  x8		  x2
					set nuline [concat $nuline $rout]				;#			   \					  Q
					lappend nulines $nuline							;#				\					  | 					---------Q
					incr pancnt										;#		o		  \		x3		o	  |			o		x7				x3
					if {$pancnt >= $mchans} {						;#				   \				  |
						if {$mstpan_bigstep} {						;#                  Q				  |
							if {$mchans == 8} {						 ;#		   o		  x4		  x6		  o			  o			  o
								set k [expr int(floor(rand() * 2.0))] ;#			o						x5						o
							} else {
								set k [expr int(floor(rand() * 6.0))]
							}
							set k [expr (($k+1) * 2) + 1]
							set hopperm [expr int(floor(rand() * $mchans))]
							while {$hopperm == $lastperm} {
								set hopperm [expr int(floor(rand() * $mchans))]
							}
							set lastperm $hopperm
							set j 1
							while {$j < $mchans} {
								set nextperm [expr ($lastperm + $k) % $mchans]
								lappend hopperm $nextperm
								set lastperm $nextperm 
								incr j
							}
						} else {
							randperm $mchans
							while {[lindex $hopperm 0] == $lastperm} {
								randperm $mchans
							}											
						}
						set lastperm [lindex $hopperm end]			
						set pancnt 0
					}
					incr linecnt
				}
				if {$mstpan_multichan_in && ([string length $bad_levels] > 0)} {
					append bad_levels "\nDo you wish to proceed ??"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $bad_levels]
					if {$choice == "no"} {
						continue
					}
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write new mixdata"
					continue
				}
				foreach line $nulines {
					puts $zit $line
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					set msg "File $ofnam is on the worksapce"
				} else {
					set msg "File $ofnam has been created, but is not on the workspace"
				}
				Inf $msg
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

#--- Place stereo SOUND in multichannel space.

proc MultiChanStereoPan {} {
	global chlist wl evv pa pr_mstpansnd mstpansndchans mstpansndfnam mstpansnd_reuse mstpansnd_doubled rememd wstk
	global mstpansnd_leftchan_to mstpansnd_rightchan_to mstpansnd_leftchan_to2 mstpansnd_rightchan_to2
	global CDPidrun prg_dun prg_abortd

	set OK 0
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 2)} {
			set OK 1
		}
	}
	if {!$OK} {
		set ilist [$wl curselection]
		if {[llength $ilist] == 1} {
			set fnam [$wl get [lindex $ilist 0]]
			if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 2)} {
				set OK 1
			}
		}
	}
	if {!$OK} {
		Inf "SELECT A STEREO FILE"
		return
	}
	set f .mstpansnd
	if [Dlg_Create $f "PLACE STEREO SND IN MULTICHAN SPACE" "set pr_mstpansnd 0" -width 120] {
		frame $f.0
		button $f.0.ok -text "Run" -command {set pr_mstpansnd 1}
		button $f.0.qu -text "Abandon" -command {set pr_mstpansnd 0}
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output Channel count" -width 20
		entry $f.1.e -textvariable mstpansndchans -width 4
		checkbutton $f.1.ch -text "Pan in PAIRED channels" -variable mstpansnd_doubled -command DoublupMultiStereo
		pack $f.1.ll $f.1.e $f.1.ch -side left
		pack $f.1 -side top -fill both -expand true
		frame $f.2
		label $f.2.ff -text "Left Channel To " -width 20
		entry $f.2.ef -textvariable mstpansnd_leftchan_to -width 4
		label $f.2.tt -text "Right Channel To " -width 20
		entry $f.2.et -textvariable mstpansnd_rightchan_to -width 4

		label $f.2.ff2 -text "Left Channel Also To" -width 20
		entry $f.2.ef2 -textvariable mstpansnd_leftchan_to2 -width 4
		label $f.2.tt2 -text "Right Channel Also To" -width 20
		entry $f.2.et2 -textvariable mstpansnd_rightchan_to2 -width 4
		pack $f.2.ff $f.2.ef $f.2.tt $f.2.et $f.2.ff2 $f.2.ef2 $f.2.tt2 $f.2.et2 -side left
		pack $f.2 -side top -fill both -expand true

		frame $f.3
		label $f.3.ll -text "Output File Name"
		entry $f.3.e -textvariable mstpansndfnam -width 32
		checkbutton $f.3.ch -text "Reuse Name of input file" -variable mstpansnd_reuse -command {set mstpansndfnam ""}
		set mstpansnd_reuse 1
		pack $f.3.ll $f.3.e $f.3.ch -side left
		pack $f.3 -side top -fill both -expand true
		wm resizable $f 0 0
		bind $f.1.e <Down> {focus .mstpansnd.2.ef}
		bind $f.2.ef <Up> {focus .mstpansnd.1.e}
		bind $f.2.ef <Right> {focus .mstpansnd.2.et}
		bind $f.2.et <Left> {focus .mstpansnd.2.ef}
		bind $f.2.et <Up> {focus .mstpansnd.1.e}
		bind $f.2.ef <Down>  {focus .mstpansnd.3.e}
		bind $f.2.et <Down>  {focus .mstpansnd.3.e}
		bind $f.2.ef <Down>  {focus .mstpansnd.3.e}
		bind $f.3.e <Up>  {focus .mstpansnd.2.ef}

		bind $f.2.ef2 <Up> {focus .mstpansnd.1.e}
		bind $f.2.ef2 <Right> {focus .mstpansnd.2.et2}
		bind $f.2.et2 <Left> {focus .mstpansnd.2.ef2}
		bind $f.2.et2 <Up> {focus .mstpansnd.1.e}

		set mstpansnd_doubled 0
		DoublupMultiStereo

		bind $f <Escape> {set pr_mstpansnd 0}
		bind $f <Return> {set pr_mstpansnd 1}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_mstpansnd 0
	set finished 0
	My_Grab 0 $f pr_mstpansnd $f.1.e
	while {!$finished} {
		tkwait variable pr_mstpansnd
		switch -- $pr_mstpansnd {
			1 {
				if {[string length $mstpansndchans] <= 0} {
					Inf "No output channel count entered"
					continue
				}
				if {![IsNumeric $mstpansndchans] || ![regexp {^[0-9]+$} $mstpansndchans]} {
					Inf "Invalid output channel count"
					continue
				}
				if {($mstpansndchans < 4) || ($mstpansndchans > 16)} {
					Inf "Output channel count out of range : must be at least 4 and no more than 16"
					continue
				}
				if {[string length $mstpansnd_leftchan_to] <= 0} {
					Inf "No left_channel placement entered"
					continue
				}
				if {![IsNumeric $mstpansnd_leftchan_to] || ![regexp {^[0-9]+$} $mstpansnd_leftchan_to]} {
					Inf "Invalid left_channel placement"
					continue
				}
				if {($mstpansnd_leftchan_to < 1) || ($mstpansnd_leftchan_to > $mstpansndchans)} {
					Inf "Left_channel placement out of range : must be at least 1 and no more than $mstpansndchans"
					continue
				}
				if {[string length $mstpansnd_rightchan_to] <= 0} {
					Inf "No right_channel placement entered"
					continue
				}
				if {![IsNumeric $mstpansnd_rightchan_to] || ![regexp {^[0-9]+$} $mstpansnd_rightchan_to]} {
					Inf "Invalid right_channel placement"
					continue
				}
				if {($mstpansnd_rightchan_to < 1) || ($mstpansnd_rightchan_to > $mstpansndchans)} {
					Inf "Right_channel placement out of range : must be at least 1 and no more than $mstpansndchans"
					continue
				}
				if {$mstpansnd_doubled} {
					if {[string length $mstpansnd_leftchan_to2] <= 0} {
						Inf "No 2nd left_channel placement entered"
						continue
					}
					if {![IsNumeric $mstpansnd_leftchan_to2] || ![regexp {^[0-9]+$} $mstpansnd_leftchan_to2]} {
						Inf "Invalid 2nd left_channel placement"
						continue
					}
					if {($mstpansnd_leftchan_to2 < 1) || ($mstpansnd_leftchan_to2 > $mstpansndchans)} {
						Inf "2nd left_channel placement out of range : must be at least 1 and no more than $mstpansndchans"
						continue
					}
					if {[string length $mstpansnd_rightchan_to2] <= 0} {
						Inf "No 2nd right_channel placement entered"
						continue
					}
					if {![IsNumeric $mstpansnd_rightchan_to2] || ![regexp {^[0-9]+$} $mstpansnd_rightchan_to2]} {
						Inf "Invalid 2nd right_channel placement"
						continue
					}
					if {($mstpansnd_rightchan_to2 < 1) || ($mstpansnd_rightchan_to2 > $mstpansndchans)} {
						Inf "2nd right_channel placement out of range : must be at least 1 and no more than $mstpansndchans"
						continue
					}
				}

				if {$mstpansnd_reuse} {
					set mstpansndfnam [file rootname [file tail $fnam]]
					append mstpansndfnam "_$mstpansndchans" "chan"
				} else {
					set ofnam [string tolower $mstpansndfnam]
					if {![ValidCDPRootname $ofnam]} {
						continue
					}
				}
				set ofnam $mstpansndfnam
				append ofnam $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message "FILE EXISTS: OVERWRITE IT ?"]
					if {$choice == "no"} {
						if {$mstpansnd_reuse} {
							set mstpansnd_reuse 0
						}
						continue
					}
					if {![DeleteFileFromSystem $ofnam 0 1]} {
						Inf "Cannot delete existing file $ofnam"
						continue
					} else {
						DummyHistory $ofnam "DESTROYED"
						if {[IsInAMixfile $ofnam]} {
							if {[MixM_ManagedDeletion $ofnam]} {
								MixMStore
							}
						}
						set i [LstIndx $ofnam $wl]	;#	remove from workspace listing, if there
						if {$i >= 0} {
							$wl delete $i
							WkspCnt $ofnam -1
							catch {unset rememd}
						}
					}
				}
				Block "PLEASE WAIT: CREATING MULTICHANNEL OUTPUT FILE"
				catch {unset nulines}
				set line $mstpansndchans
				lappend nulines $line
				set line [list $fnam 0.0 2]
				set rout 1:
				append rout $mstpansnd_leftchan_to
				lappend line $rout 1.0
				if {$mstpansnd_doubled} {
					set rout 1:
					append rout $mstpansnd_leftchan_to2
					lappend line $rout 1.0
				}
				set rout 2:
				append rout $mstpansnd_rightchan_to
				lappend line $rout 1.0
				if {$mstpansnd_doubled} {
					set rout 2:
					append rout $mstpansnd_rightchan_to2
					lappend line $rout 1.0
				}
				lappend nulines $line

				set mfnam $evv(DFLT_OUTNAME)
				append mfnam "0" [GetTextfileExtension mmx]

				if {[file exists $mfnam ] && [catch {file delte $mfnam} zit]} {
					Inf "Cannot remove existing temporary mixfile $mfnam"
					UnBlock
					continue
				}
				if [catch {open $mfnam "w"} zit] {
					Inf "Cannot open temporary mixfile $mfnam to write multichan mixdata"
					UnBlock
					continue
				}
				foreach line $nulines {
					puts $zit $line
				}
				close $zit

				set prg_dun 0
				set prg_abortd 0
				set cmd [file join $evv(CDPROGRAM_DIR) newmix]
				lappend cmd multichan $mfnam $ofnam
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed to run multichannel mixing"
					 if [catch {file delete $mfnam} zit] {
						Inf "Cannot delete temporary mixfile $mfnam"
						UnBlock
						break
					}
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
					Inf "Multichannel mixing failed"
					 if [catch {file delete $mfnam} zit] {
						Inf "Cannot delete temporary mixfile $mfnam"
						UnBlock
						break
					}
					UnBlock
					continue
				}
				if {![file exists $ofnam]} {
					Inf "No multichannel sndfile created"
					 if [catch {file delete $mfnam} zit] {
						Inf "Cannot delete temporary mixfile $mfnam"
						UnBlock
						break
					}
					UnBlock
					continue
				}
				UnBlock
				catch {file delete $mfnam}
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					set msg "File $ofnam is on the workspace"
				} else {
					set msg "File $ofnam has been created, but is not on the workspace"
				}

				Inf $msg
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

proc DoublupMultiStereo {} {
	global mstpansnd_doubled mstpansnd_leftchan_to2 mstpansnd_rightchan_to2
	set mstpansnd_leftchan_to2 ""
	set mstpansnd_rightchan_to2 ""
	switch -- $mstpansnd_doubled {
		1 {
			.mstpansnd.2.ff2 config -text "Left Channel Also To"
			.mstpansnd.2.ef2 config -state normal -bd 2
			.mstpansnd.2.tt2 config -text "Right Channel Also To"
			.mstpansnd.2.et2 config -state normal -bd 2
			bind .mstpansnd.2.et <Right>  {focus .mstpansnd.2.ef2}
			bind .mstpansnd.2.ef2 <Left>  {focus .mstpansnd.2.et}
			bind .mstpansnd.2.ef2 <Right> {focus .mstpansnd.2.et2}
			bind .mstpansnd.2.et2 <Left>  {focus .mstpansnd.2.ef2}
			bind .mstpansnd.2.ef2 <Down>  {focus .mstpansnd.3.e}
			bind .mstpansnd.2.et2 <Down>  {focus .mstpansnd.3.e}
		}
		0 {
			.mstpansnd.2.ff2 config -text ""
			.mstpansnd.2.ef2 config -state disabled -bd 0 -disabledbackground [option get . background {}]
			.mstpansnd.2.tt2 config -text ""
			.mstpansnd.2.et2 config -state disabled -bd 0 -disabledbackground [option get . background {}]
			bind .mstpansnd.2.et <Right>  {}
			bind .mstpansnd.2.ef2 <Left>  {}
			bind .mstpansnd.2.ef2 <Right> {}
			bind .mstpansnd.2.et2 <Left>  {}
			bind .mstpansnd.2.ef2 <Down>  {}
			bind .mstpansnd.2.et2 <Down>  {}
		}
	}
}

#--- Display Panning

proc PanDiagram {} {
	global pand evv pr_pand
	set pand(colorlist) [list red DarkOrange yellow3 green ForestGreen CadetBlue blue DarkOrchid]
	set pand(colorlen) [llength $pand(colorlist)]

	if {![OrderMixlinePans]} {
		return
	}
	ExtractRoutings

	if {![info exists pand(routings)]} {
		Inf "No panning information extracted"
	}
	set f .pand
	if [Dlg_Create $f "DISPLAY PANNING IN ORDER" "set pr_pand 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.1
		button $f.1.help -text Help -command PandHelp -bg $evv(HELP)
		button $f.1.quit -text Quit -command "set pr_pand 0"
		pack $f.1.help -side left
		pack $f.1.quit -side right
		pack $f.1 -side top -fill x -expand true
		frame $f.00
		frame $f.00.1
		label $f.00.1.stt -text "1st" -width 4
		entry $f.00.1.sttfil -textvariable pand(sttfile) -width 80 -state readonly
		pack $f.00.1.stt $f.00.1.sttfil -side left 
		frame $f.00.2
		label $f.00.2.end -text "last" -width 4
		entry $f.00.2.endfil -textvariable pand(endfile) -width 80 -state readonly
		pack $f.00.2.end $f.00.2.endfil -side left 
		pack $f.00.1 $f.00.2 -side top -pady 2
		pack $f.00 -side top
		frame $f.2
		label $f.2.sl -text "Start Pan"
		entry $f.2.stt -textvariable pand(sttno) -width 4 -state readonly
		entry $f.2.end -textvariable pand(endno) -width 4 -state readonly
		label $f.2.el -text "End Pan"
		pack $f.2.sl $f.2.stt $f.2.end $f.2.el -side left -fill x -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3
		button $f.3.next -text "+Next" -command AddNextPan   -width 7
		button $f.3.less -text "CutLast" -command "DeleteLastPan 0" -width 7
		button $f.3.les1 -text "Cut 1st" -command "DeleteLastPan 1" -width 7
		button $f.3.shp -text "Shift+" -command "PanShift 0" -width 7
		button $f.3.shm -text "Shift-" -command "PanShift 1" -width 7
		pack $f.3.next $f.3.les1 $f.3.less $f.3.shp $f.3.shm -side left -fill x -padx 2
		pack $f.3 -side top -pady 2
		frame $f.4
		button $f.4.clear -text "Clear All" -command "ClearPand 1" -width 6
		pack $f.4.clear  -side left -fill x -padx 2
		pack $f.4 -side top -pady 2
		frame $f.5

		set pand(can) [canvas $f.5.c -height 400 -width 400 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL) -background white]
		$pand(can) create line 200 40 280 90 330 170 280 250 200 300 120 250 70 170 120 90 200 40 -width 3 -fill $evv(POINT)
		$pand(can) create rect 197 37 203 43  -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT)
		$pand(can) create text 200 27 -text "1" -fill $evv(POINT) 
		$pand(can) create text 200 12 -text "" -fill red -tag {outo outo1}
		$pand(can) create rect 277 87  283 93  -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT)
		$pand(can) create text 290 85 -text "2" -fill $evv(POINT)
		$pand(can) create text 300 80 -text "" -fill red -tag {outo outo2} -anchor w
		$pand(can) create rect 327 167 333 173 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT)
		$pand(can) create text 340 170 -text "3" -fill $evv(POINT)
		$pand(can) create text 350 170 -text "" -fill red -tag {outo outo3} -anchor w
		$pand(can) create rect 277 247 283 253 -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT)
		$pand(can) create text 290 255 -text "4" -fill $evv(POINT)
		$pand(can) create text 300 260 -text "" -fill red -tag {outo outo4} -anchor w
		$pand(can) create rect 197 297 203 303 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT)
		$pand(can) create text 200 313 -text "5" -fill $evv(POINT)
		$pand(can) create text 200 328 -text "" -fill red -tag {outo outo5}
		$pand(can) create rect 117 247 123 253 -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT)
		$pand(can) create text 110 255 -text "6" -fill $evv(POINT)
		$pand(can) create text 100 260 -text "" -fill red -tag {outo outo6} -anchor e
		$pand(can) create rect 67 167 73 173 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT)
		$pand(can) create text 60 170 -text "7" -fill $evv(POINT)
		$pand(can) create text 50 170 -text "" -fill red -tag {outo outo7} -anchor e
		$pand(can) create rect 117 87 123 93 -fill [option get . background {}] -tag {lspkr k8} -outline $evv(POINT)
		$pand(can) create text 110 85 -text "8" -fill $evv(POINT)
		$pand(can) create text 100 80 -text "" -fill red -tag {outo outo8} -anchor e
		$pand(can) create text 200 370 -text "" -fill $evv(POINT) -tag filename
		pack $f.5.c -side left
		pack $f.5 -side left
		bind $f <Up>   {IncrPanStart 0} 
		bind $f <Down> {IncrPanStart 1} 
		bind $f <Delete> {ClearPand 1}
		wm resizable $f 0 0
		bind $f <Escape> {set pr_pand 0}
		bind $f <Return> {set pr_pand 0}
		set pand(sttfile) ""
		ForceVal .pand.00.1.sttfil $pand(sttfile)
		set pand(endfile) ""
		ForceVal .pand.00.2.endfil $pand(endfile)
	}
	set pr_pand 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_pand
	tkwait variable pr_pand
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc IncrPanStart {down} {
	global pand
	if {[string length $pand(sttno)] <= 0} {
		if {$down} {
			set pand(sttno) [expr $pand(pancnt) - 1] 
			set pand(sttcolorno) [expr $pand(colorlen) - 1]
			ForceVal .pand.2.stt $pand(sttno)
			set pand(endno) $pand(sttno) 
			set pand(endcolorno) $pand(sttcolorno)
			ForceVal .pand.2.end $pand(endno)
		} else {
			set pand(sttno) 0
			set pand(sttcolorno) 0
			ForceVal .pand.2.stt $pand(sttno)
			set pand(endno) 0
			set pand(endcolorno) 0
			ForceVal .pand.2.end $pand(endno)
		}
	} else {
		if {$down} {
			if {$pand(sttno) <= 0} {
				return
			}
			incr pand(sttno) -1
			incr pand(sttcolorno) -1
			if {$pand(sttcolorno) < 0} {
				incr pand(sttcolorno) $pand(colorlen)
			}
			ForceVal .pand.2.stt $pand(sttno)
		} else {
			if {$pand(sttno) >= [expr $pand(pancnt) - 1]} {
				return
			}
			incr pand(sttno)
			incr pand(sttcolorno) $pand(colorlen)
			set pand(sttcolorno) [expr $pand(sttno) % $pand(colorlen)]
			ForceVal .pand.2.stt $pand(sttno)
			if {$pand(endno) <= $pand(sttno)} {
				set pand(endno) $pand(sttno)
				set pand(endcolorno) $pand(sttcolorno)
				ForceVal .pand.2.end $pand(endno)
			}
		}
	}
	ClearPand 0
	set thiscolorno $pand(sttcolorno)
	set thiscolor [lindex $pand(colorlist) $thiscolorno]
	set k $pand(sttno)
	while {$k <= $pand(endno)} {
		set routing [lindex $pand(routings) $k]
		DrawPan $routing $thiscolor $k
		incr thiscolorno
		set thiscolorno [expr $thiscolorno % $pand(colorlen)]
		set thiscolor [lindex $pand(colorlist) $thiscolorno]
		incr k
	}
	set pand(sttfile) [file rootname [file tail [lindex $pand(files) $pand(sttno)]]]
	ForceVal .pand.00.1.sttfil $pand(sttfile)
	set pand(endfile) [file rootname [file tail [lindex $pand(files) $pand(endno)]]]
	ForceVal .pand.00.2.endfil $pand(endfile)
}

#--- Modifying pan display

proc AddNextPan {} {
	global pand
	if {[string length $pand(sttno)] == 0} {
		set pand(sttno) 0
		set pand(endno) 0
		set pand(sttcolorno) 0
		set pand(endcolorno) 0
	} elseif {[string length $pand(endno)] == 0} {
		set pand(endno) $pand(sttno)
		if {$pand(endno) >= [expr $pand(pancnt) - 1]} {
			Inf "No more pans to display"
			return 0
		}
		incr pand(endno)
		ForceVal .pand.2.end $pand(endno)
		set pand(endcolorno) $pand(sttcolorno) 
		incr pand(endcolorno)
		set pand(endcolorno) [expr $pand(endcolorno) % $pand(colorlen)]
	} else {
		if {$pand(endno) >= [expr $pand(pancnt) - 1]} {
			Inf "No more pans to display"
			return 0
		}
		incr pand(endno)
		ForceVal .pand.2.end $pand(endno)
		if {![info exists pand(endcolorno)]} {
			if {![info exists pand(sttcolorno)]} {
				set pand(sttcolorno) [expr $pand(sttno) % $pand(colorlen)]
			}
			set diff [expr $pand(endno) - $pand(sttno)]
			set pand(endcolorno) [expr $pand(sttcolorno) + $diff]
		}
		incr pand(endcolorno)
		set pand(endcolorno) [expr $pand(endcolorno) % $pand(colorlen)]
	}
	set pand(endcolor) [lindex $pand(colorlist) $pand(endcolorno)]
	set routing [lindex $pand(routings) $pand(endno)]		
	DrawPan $routing $pand(endcolor) $pand(endno)
	set pand(endfile) [file rootname [file tail [lindex $pand(files) $pand(endno)]]]
	ForceVal .pand.00.2.endfil $pand(endfile)
	return 1
}

proc DeleteLastPan {first} {
	global pand wstk
	if {$first} {
		if {[string length pand(sttno)] <= 0} {
			Inf "No pan displays to delete"
			return 0
		}
		if {$pand(endno) == $pand(sttno)} {
			set msg "Delete all pans and start again ??"
			set choice [tk_messageBox -type yesno -icon question -default no -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return 0	
			}
		}
		DeleteArrows $pand(sttno)
		if {$pand(endno) == $pand(sttno)} {
			set pand(endno) ""
			ForceVal .pand.2.end $pand(endno)
			set pand(sttno) ""
			ForceVal .pand.2.stt $pand(sttno)
			set pand(sttcolorno) 0
			set pand(endcolorno) 0
		} else {
			incr pand(sttno)
			ForceVal .pand.2.stt $pand(sttno)
			incr pand(sttcolorno)
			set pand(sttcolorno) [expr $pand(sttcolorno) % $pand(colorlen)]
		}
		set pand(sttfile) [file rootname [file tail [lindex $pand(files) $pand(sttno)]]]
		ForceVal .pand.00.1.sttfil $pand(sttfile)
	} else {
		if {[string length pand(endno)] <= 0} {
			Inf "No pan displays to delete"
			return 0
		}
		if {$pand(endno) == $pand(sttno)} {
			set msg "Delete all pans and start again ??"
			set choice [tk_messageBox -type yesno -icon question -default no -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return 0	
			}
		}
		DeleteArrows $pand(endno)
		if {$pand(endno) == $pand(sttno)} {
			set pand(endno) ""
			ForceVal .pand.2.end $pand(endno)
			set pand(sttno) ""
			ForceVal .pand.2.stt $pand(sttno)
			set pand(sttcolorno) 0
			set pand(endcolorno) 0
		} else {
			incr pand(endno) -1
			ForceVal .pand.2.end $pand(endno)
			incr pand(endcolorno) -1
			if {$pand(endcolorno) < 0} {
				incr pand(endcolorno) $pand(colorlen)
			}
		}
		set pand(endfile) [file rootname [file tail [lindex $pand(files) $pand(endno)]]]
		ForceVal .pand.00.2.endfil $pand(endfile)
	}
	return 1
}

proc PanShift {back} {
	global pand
	if {[string length pand(sttno)] <= 0} {
		Inf "NO PAN DISPLAYS TO SHIFT"
		return 0
	} elseif {[string length pand(endno)] <= 0} {
		set pand(endno) $pand(sttno)
		set pand(endcolorno) $pand(sttcolorno)
	}
	if {$back} {
		if {$pand(sttno) <= 0} {
			Inf "No more pans to display"
			return 0
		}
		incr pand(sttno) -1
		set routing [lindex $pand(routings) $pand(sttno)]
		incr pand(sttcolorno) -1
		if {$pand(sttcolorno) < 0} {
			incr pand(sttcolorno) $pand(colorlen)
		}
		set pand(sttcolor) [lindex $pand(colorlist) $pand(sttcolorno)]
		DrawPan $routing $pand(sttcolor) $pand(sttno)
		DeleteArrows $pand(endno)
		incr pand(endno) -1
		incr pand(endcolorno) -1
		if {$pand(endcolorno) < 0} {
			incr pand(endcolorno) $pand(colorlen)
		}
		set pand(sttfile) [file rootname [file tail [lindex $pand(files) $pand(sttno)]]]
		ForceVal .pand.00.1.sttfil $pand(sttfile)
		set pand(endfile) [file rootname [file tail [lindex $pand(files) $pand(endno)]]]
		ForceVal .pand.00.2.endfil $pand(endfile)
		return 1

	} else {

		if {$pand(endno) >= [expr $pand(pancnt) - 1]} {
			Inf "NO MORE PANS TO DISPLAY"
			return 0
		}
		DeleteArrows $pand(sttno)
		incr pand(sttno)
		incr pand(sttcolorno)
		set pand(sttcolorno) [expr $pand(sttcolorno) % $pand(colorlen)]
		incr pand(endno)
		set routing [lindex $pand(routings) $pand(endno)]		
		incr pand(endcolorno)
		set pand(endcolorno) [expr $pand(endcolorno) % $pand(colorlen)]
		set pand(endcolor) [lindex $pand(colorlist) $pand(endcolorno)]
		DrawPan $routing $pand(endcolor) $pand(endno)
		set pand(sttfile) [file rootname [file tail [lindex $pand(files) $pand(sttno)]]]
		ForceVal .pand.00.1.sttfil $pand(sttfile)
		set pand(endfile) [file rootname [file tail [lindex $pand(files) $pand(endno)]]]
		ForceVal .pand.00.2.endfil $pand(endfile)
		return 1
	}
}

#--- Put mixlines in correct order

proc OrderMixlinePans {} {
	global mlst m_list pand pr_mxorder evv wstk evv chlist
	set pand(order_return) 0
	set f .mxorder
	if [Dlg_Create $f "ORDER MIX LINES FOR PAN DISPLAY" "set pr_mxorder 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Use This Order" -command "set pr_mxorder 1" -bg $evv(EMPH)
		button $f.0.h -text "Help" -command PandReorderHelp -bg $evv(HELP)
		button $f.0.q -text "Abandon" -command "set pr_mxorder 0"
		frame $f.0.0
		button $f.0.0.save -text "Save New Order" -command "set pr_mxorder 2"   -width 16
		button $f.0.0.load -text "Load Known Order" -command "set pr_mxorder 3" -width 16
		button $f.0.0.lmix -text "Load Current Mix" -command "set pr_mxorder 4" -width 16
		label $f.0.0.lcnt -text "Lines"
		entry $f.0.0.cnt -textvariable pand(ccnt) -width 4 -state readonly
		pack $f.0.0.save $f.0.0.load $f.0.0.lmix $f.0.0.lcnt $f.0.0.cnt -side left -padx 2
		pack $f.0.s $f.0.h $f.0.0 -side left -padx 12
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		button $f.1.up -text "Move up"   -command "OrderMix 0" -width 9
		button $f.1.dn -text "Move down" -command "OrderMix 1" -width 9
		button $f.1.ig -text "Ignore"    -command "OrderMix 2" -width 9
		button $f.1.pl -text "Play"		 -command "PlayOrdermixFile" -width 9
		pack $f.1.up $f.1.dn $f.1.ig $f.1.pl -side left -padx 2
		pack $f.1 -side top -pady 2
		frame $f.1a
		button $f.1a.re -text "Add New"   -command "RefreshPmix" -width 9
		pack $f.1a.re -side left -padx 2
		pack $f.1a -side top -pady 2
		frame $f.2
		Scrolled_Listbox $f.2.ll -width 120 -height 24 -selectmode single
		pack $f.2.ll -side top -pady 2
		pack $f.2 -side top -pady 2 -fill x -expand true
		wm resizable $f 0 0
		bind $f <Double-1> {PlayOrdermixFile}
		bind $f <Escape> {set pr_mxorder 0}
		bind $f <Return> {set pr_mxorder 1}
	}
	.mxorder.2.ll.list delete 0 end
	if {[info exists pand(mixorder)]} {
		set orig_mixorder $pand(mixorder)
		foreach line $pand(mixorder) {
			.mxorder.2.ll.list insert end $line
		}
	} else {
		foreach line $mlst {
			if {[string match [string index [lindex $line 0] 0] ";"]} {
				continue
			}
			.mxorder.2.ll.list insert end $line
		}
	}
	set pand(ccnt) [.mxorder.2.ll.list index end]
	ForceVal .mxorder.0.0.cnt $pand(ccnt)
	set savfnam	[file rootname [file tail [lindex $chlist 0]]]
	append savfnam ".mxo"
	set savfnam [file join $evv(URES_DIR) $savfnam]
	set pr_mxorder 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_mxorder
	while {!$finished} {
		tkwait variable pr_mxorder
		switch -- $pr_mxorder {
			1 {
				catch {unset pand(mixorder)} 
				foreach line [.mxorder.2.ll.list get 0 end] {
					lappend pand(mixorder) $line
				}
				set finished 1
			}
			2 {
				if {[file exists $savfnam]} {
					set msg "Overwrite existing ordering ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if [catch {open $savfnam "w"} zit] {
					Inf "Cannot open file [file tail $savfnam] to write data"
					continue
				}
				catch {unset pand(mixorder)} 
				foreach line [.mxorder.2.ll.list get 0 end] {
					if {[string match [string index $line 0] ";"]} {
						continue
					}
					lappend pand(mixorder) $line
				}
				foreach line $pand(mixorder) {
					puts $zit $line
				}
				close $zit
				set pand(ccnt) [llength $pand(mixorder)]
				ForceVal .mxorder.0.0.cnt $pand(ccnt)
				.mxorder.2.ll.list delete 0 end
				foreach line $pand(mixorder) {
					.mxorder.2.ll.list insert end $line
				}
				Inf "Ordering data saved"
			}
			3 {
				if {![file exists $savfnam]} {
					Inf "Cannot find any ordering-data previously saved"
					continue
				}
				if [catch {open $savfnam "r"} zit] {
					Inf "Cannot open file [file tail $savfnam] to read data"
					continue
				}
				catch {unset pand(mixorder)} 
				while {[gets $zit line] >= 0} {
					lappend pand(mixorder) $line
				}
				close $zit
				.mxorder.2.ll.list delete 0 end
				foreach line $pand(mixorder) {
					.mxorder.2.ll.list insert end $line
				}
				set pand(ccnt) [llength $pand(mixorder)]
				ForceVal .mxorder.0.0.cnt $pand(ccnt)
			}
			4 {
				.mxorder.2.ll.list delete 0 end
				foreach line [$m_list get 0 end] {
					if {[string match [string index [lindex $line 0] 0] ";"]} {
						continue
					}
					.mxorder.2.ll.list insert end $line
				}
				set pand(ccnt) [.mxorder.2.ll.list index end]
				ForceVal .mxorder.0.0.cnt $pand(ccnt)
		}
			0 {
				if {[info exists orig_mixorder]} {
					set pand(mixorder) $orig_mixorder
				}
				My_Release_to_Dialog $f
				Dlg_Dismiss $f
				return 0
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return 1
}

proc OrderMix {down} {
	set qq .mxorder.2.ll.list
	set i [$qq curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No item selected"
		return
	}
	switch -- $down {
		2 {								;# IGNORE
			set line ";"
			append line [$qq get $i]
			$qq  delete $i
			$qq  insert $i $line
			return
		}
		1 {								;#	MOVE DOWN
			if {$i >= [$qq index end]} {
				return
			}
			set line [$qq get $i]
			$qq  delete $i
			incr i
			$qq  insert $i $line
			$qq selection set $i
		} 
		0 {								;#	MOVE UP
			if {$i == 0} {
				return
			}
			set line [$qq get $i]
			$qq  delete $i
			incr i -1
			$qq  insert $i $line
			$qq selection set $i
		}
	}

}

proc RefreshPmix {} {
	global pand m_list
	if {![info exists pand(mixorder)]} {
		Inf "No ordering loaded or saved"
		return
	}
	foreach line [$m_list get 0 end] {
		if {[string match [string index [lindex $line 0] 0] ";"]} {
			continue
		}
		set line [string trim $line]
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		lappend nulines $nuline
	}
	foreach line $nulines {
		set line [string trim $line]
		set line [split $line]
		catch {unset set xline}
		foreach item $line {
			string trim $item
			if {[string length $item] > 0} {
				lappend xline $item
			}
		}
		lappend xlines $xline
	}
	set xlines $nulines

	set len [llength $nulines]
	set k 0
	catch {unset addlines}
	while {$k < $len} {
		set nuline [lindex $nulines $k]
		if {[lsearch $pand(mixorder) $nuline] < 0} {
			lappend addlines $nuline
		}
		incr k
	}
	if {[info exists addlines]} {
		set pand(mixorder) [concat $pand(mixorder) $addlines]
		.mxorder.2.ll.list delete 0 end
		foreach line $pand(mixorder) {
			.mxorder.2.ll.list insert end $line
		}
	} else {
		Inf "No new lines added"
		return
	}
}

proc ExtractRoutings {} {
	global pand
	catch {unset pand(routings)}
	catch {unset pand(files)}
	foreach line $pand(mixorder) {
		if {[string match [string index [lindex $line 0] 0] ";"]} {
			continue
		}
		catch {unset nuline}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set line $nuline
		lappend pand(files) [lindex $line 0]
		set chans [lindex $line 2]
		set len [llength $line]
		if {$chans == 2} {
			set k 3
			catch {unset f_rom}
			catch {unset t_ooo}
			while {$k < $len} {
				set rout [lindex $line $k]
				set rout [split $rout ":"]
				if {[lindex $rout 0] == 1} {
					lappend f_rom [lindex $rout 1]
				} elseif {[lindex $rout 0] == 2} {
					lappend t_ooo [lindex $rout 1]
				}
				incr k 2
			}
			set maxlen 0
			set flen 0
			if {[info exists f_rom]} {
				set flen [llength $f_rom]
				set maxlen $flen
			}
			set tlen 0
			if {[info exists t_ooo]} {
				set tlen [llength $t_ooo]
				if {$tlen > $maxlen} {
					set maxlen $tlen
				}
			}
			set k 0
			catch {unset routing}
			while {$k < $maxlen} {
				if {$k < $tlen} {
					set lastt [lindex $t_ooo $k]
				}
				if {$k < $flen} {
					set lastf [lindex $f_rom $k]
				}
				set rout [list $lastf $lastt]
				lappend routing $rout
				incr k
			}
			if {[info exists routing]} {

				if {[llength $routing] == 2} {			;#	Force double panning arrows not to cross each other
					set rt0 [lindex $routing 0]
					set rt1 [lindex $routing 1]
					set x1 [lindex $rt0 0]
					set y1 [lindex $rt0 1]
					set x2 [lindex $rt1 0]
					set y2 [lindex $rt1 1]

					if {$x1 > $x2} {
						set temp $x1
						set x1 $x2						;#	Put stt_chans in numeric order
						set x2 $temp
					}
					if {$y1 > $y2} {
						set temp $y1
						set y1 $y2						;#	Put end-chans in numeric order
						set y2 $temp					
					}
					set diff [expr $x2 - $x1]
					if {$diff > 4} {					;#	If distance between stt-chans > 4 (1/2 way round circle)
						set temp $x1
						set x1 $x2						;#	Swap order of pan stt-chans
						set x2 $temp					;#	Forcing clockwise order
					}
					set diff [expr $y2 - $y1]			
					if {$diff > 4} {					;#	If distance between end-chans > 4 (1/2 way round circle)
						set temp $y1
						set y1 $y2						;#	Swap order of pan end-chans
						set y2 $temp					;#	Forcing clockwise order
					}
					set temp $y1
					set y1 $y2							;#	Then force anticlockwise order of end-chans
					set y2 $temp
					set rt0 [list $x1 $y1]
					set rt1 [list $x2 $y2]
					set routing [list $rt0 $rt1]
				} elseif {[llength $routing] == 3} {	;#	Force TRIPLE panning arrows not to cross each other
					set rt0 [lindex $routing 0]
					set rt1 [lindex $routing 1]
					set rt2 [lindex $routing 2]
					set x1 [lindex $rt0 0]
					set y1 [lindex $rt0 1]
					set x2 [lindex $rt1 0]
					set y2 [lindex $rt1 1]
					set x3 [lindex $rt2 0]
					set y3 [lindex $rt2 1]

					set xx [lsort [list $x1 $x2 $x3]]
					set x1 [lindex $xx 0]				;#	Put stt_chans in numeric order
					set x2 [lindex $xx 1]
					set x3 [lindex $xx 2]

					set yy [lsort [list $y1 $y2 $y3]]
					set y1 [lindex $yy 0]				;#	Put end-chans in numeric order
					set y2 [lindex $yy 1]
					set y3 [lindex $yy 2]
					
					set diff [expr $x2 - $x1]			;#	Forcing clockwise order of stt chans
					if {$diff > 4} {
						set xx [list $x2 $x3 $x1]
					} else {
						set diff [expr $x3 - $x1]
						if {$diff > 4} {
							set xx [list $x3 $x1 $x2]
						} else {
							set xx [list $x1 $x2 $x3]
						}
					}
					set diff [expr $y2 - $y1]			;#	Forcing clockwise order of end chans
					if {$diff > 4} {
						set yy [list $y2 $y3 $y1]
					} else {
						set diff [expr $y3 - $y1]
						if {$diff > 4} {
							set yy [list $y3 $y1 $y2]
						} else {
							set yy [list $y1 $y2 $y3]
						}
					}
					set yy [ReverseList $yy]	;#	Then force anticlockwise order of end-chans
					set rt0 [list [lindex $xx 0] [lindex $yy 0] ]
					set rt1 [list [lindex $xx 1] [lindex $yy 1] ]
					set rt2 [list [lindex $xx 2] [lindex $yy 2] ]
					set routing [list $rt0 $rt1 $rt2]
				}
				lappend pand(routings) $routing
			}
		} else {
			set k 3
			set routing "X"
			while {$k < $len} {
				set rout [lindex $line $k]
				set rout [split $rout ":"]
				set rout [lindex $rout 1]
				append rout "x"
				lappend routing $rout
				incr k 2
			}
			lappend pand(routings) $routing
		}
	}
	if {[info exists pand(routings)]} {
		set pand(pancnt) [llength $pand(routings)]
	}
}

proc PanDisplayWhere {routpos} {
	switch -- $routpos {
		1 {
			set pos [list 200 40]
		}
		1x {
			set pos [list 200 49]
		}
		2 {
			set pos [list 280 90]
		}
		2x {
			set pos [list 275 95]
		}
		3 {
			set pos [list 330 170]
		}
		3x {
			set pos [list 321 170]
		}
		4 {
			set pos [list 280 250]
		}
		4x {
			set pos [list 275 245]
		}
		5 {
			set pos [list 200 300]
		}
		5x {
			set pos [list 200 291]
		}
		6 {
			set pos [list 120 250]
		}
		6x {
			set pos [list 125 245]
		}
		7 {
			set pos [list 70 170]
		}
		7x {
			set pos [list 79 170]
		}
		8 {
			set pos [list 120 90]
		}
		8x {
			set pos [list 125 95]
		}
	}
	return $pos
}

proc DrawPan {routing thiscolor thisno} {
	global pand
	if {[string match [string index $routing 0] "X"]} {		;#	Not a (stereo) pan
		set coords {}
		foreach pos [lrange $routing 1 end] {
			set coords [concat $coords [PanDisplayWhere $pos]]
		}
		$pand(can) create line $coords -fill white -tag pan$thisno
		$pand(can) create line $coords -fill $thiscolor -tag pan$thisno
		return
	}
	foreach rout $routing {
		set stt  [lindex $rout 0]
		set endd [lindex $rout 1]
		set coords    [PanDisplayWhere $stt]
		set endcoords [PanDisplayWhere $endd]
		set coords [concat $coords $endcoords]
		$pand(can) create line $coords -fill $thiscolor -arrow last -tag pan$thisno
	}
}

proc DeleteArrows {thisno} {
	global pand
	$pand(can) delete pan$thisno
}


proc ClearPand {all} {
	global pand
	set k 0
	set safety 10
	while {$k < [expr $pand(pancnt) + $safety]} {
		DeleteArrows $k
		incr k
	}
	if {$all} {
		set pand(sttno) ""
		set pand(endno) ""
		set pand(sttfile) ""
		set pand(endfile) ""
		ForceVal .pand.00.1.sttfil $pand(sttfile)
		ForceVal .pand.00.2.endfil $pand(endfile)
	}
}

proc PandHelp {} {

	set msg "Display assumes that panned files are\n"
	append msg "\n"
	append msg "    (1)  Stereo.\n"
	append msg "    (2)  Originally panned from Left to Right.\n"
	append msg "\n"
	append msg "To set or advance start position of pans display\n"
	append msg "         Use \"Up\" and \"Down\" Keys .\n"
	append msg "\n"
	append msg "\"Delete\" Key will clear the display.\n"
	append msg "\n"
	append msg "\n"
	Inf $msg
}

proc PandReorderHelp {} {

	set msg "REORDERING LINES IN MIXFILE, FOR DISPLAY OF PANNING\n"
	append msg "\n"
	append msg "The timing (and therefore order) of panning-events \n"
	append msg "may not correspond to the order of sound starts in the mix.\n"
	append msg "\n"
	append msg "This function allows the mix to be reordered to correspond to\n"
	append msg "the order of panning events in the mix.\n"
	append msg "\n"
	append msg "NB NB The display will assume that panned files are . . . .\n"
	append msg "\n"
	append msg "    (1)  STEREO only.\n"
	append msg "    (2)  Originally panned from LEFT TO RIGHT.\n"
	append msg "\n"
	append msg "\n"
	append msg "TO MOVE LINES, Use \"Move Up\" or \"Move Down\" buttons.\n"
	append msg "\n"
	append msg "TO IGNORE LINES (e.g. non-panned lines) use "\Ignore\" button".\n"
	append msg "\n"
	append msg "TO ADD ADITIONAL FILES TO AN EXISTING ORDERING\n"
	append msg "Use \"Add New\" button.\n"
	append msg "\n"
	append msg "This adds any new lines found in the mix\n"
	append msg  which are not in your existing ordering.\n"
	append msg "\n"
	append msg "ONLY USE THIS if new lines have been ADDED to an existing mix.\n"
	append msg "\n"
	append msg "If mixlines have been ALTERED, get the new mix, and order that.\n"
	Inf $msg
}

proc PlayOrdermixFile {} {
	set i [.mxorder.2.ll.list curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No item selected"
		return
	}
	set line [.mxorder.2.ll.list get $i]
	if {[string match [string index $line 0] ";"]} {
		Inf "Item selected is set to be ignored"
		return
	}
	set fnam [lindex $line 0]
	PlaySndfile $fnam 0
}

proc MixShowChans {chans} {
	global m_list
	set i 0
	catch {unset sel_ect}
	foreach line [$m_list get 0 end] {
		set line [StripCurlies $line]
		set line [string trim $line]
		if {[string length $line] <= 0} {
			incr i
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			incr i
			continue
		}
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend nuline $item
			if {$cnt == 2} {
				break
			}
			incr cnt
		}
		set chanval [lindex $nuline 2]
		if {$chanval == $chans} {
			lappend sel_ect $i
		}
		incr i
	}
	if {![info exists sel_ect]} {
		Inf "There are no files with channel-cnt $chans"
		return
	}
	$m_list selection clear 0 end
	foreach i $sel_ect {
		$m_list selection set $i
	}
}

proc DoHilite {} {
	global mixval m_list mlst evv
	set eend [$m_list index end]
	if {![info exists mixval] || ([string length $mixval] <= 0) || ![IsNumeric $mixval] || ![regexp {^[0-9]+$} $mixval] || ($mixval < 1)} {
		Inf "Not a valid line number"
		return
	}
	set qq [expr $mixval - 1]
	if {$mixval > $eend} {
		Inf "There are only $eend lines in the display"
		return
	}
	set qq [expr $mixval - 1]
	$m_list selection clear 0 end
	$m_list selection set $qq
	if {$qq >= $evv(QIKEDITLEN)} {
		set kk [expr double($qq)/double([llength $mlst])]
		$m_list	yview moveto $kk
	} else {
		$m_list	yview moveto 0
	}
	return
}

proc SelectAllActiveLinesBelow {} {
	global mlst m_list
	set ilist [$m_list curselection]
	if {([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
		return
	}
	set i [lindex $ilist end]
	set len [llength $mlst]
	set j $i
	while {$j < $len} {
		set line [$m_list get $j]
		if {[string match ";" [string index $line 0]]} {
			incr j
			continue
		}
		$m_list selection set $j
		incr j
	}
}

#----- Select Lines where the filename contains the string entered

proc QikEditorSelectBystring {starter} {
	global mixval lastmixval mlst m_list evv
	if {([string length $mixval] <= 0) || ![ValidCDPRootname $mixval]} {
		Inf "Invalid string entered in \"value\""
		return
	}
	set lastmixval $mixval
	set str [string tolower $mixval]
	set i 0
	foreach line [$m_list get 0 end] {
		if {[string match [string index $line 0] "\{"]} {
			set line [StripCurlies $line]
		}
		if {[string match ";" [string index $line 0]]} {
			set line [string range $line 1 end]
		}
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {[file exists $item]} {
				set item [file rootname [file tail $item]]
				set k [string first $str $item]
				if {$k >= 0} {
					if {$starter} {
						if {$k == 0} {
							lappend ilist $i
						} else {
							set kk [string index $item [expr $k - 1]]
							if {[regexp {[\_\-]} $kk]} { 
								lappend ilist $i
							}
						}
					} else {
						lappend ilist $i
					}
				}
			}
			break
		}
		incr i
	}
	if {![info exists ilist]} {
		Inf "No mixfile lines have $mixval in the filename"
		return
	}
	$m_list selection clear 0 end
	foreach i $ilist {
		$m_list	selection set $i
	}
	set i [lindex $ilist 0] 
	if {$i >= $evv(QIKEDITLEN)} {
		set kk [expr double($i)/double([llength $mlst])]
		$m_list	yview moveto $kk
	}
}

proc QikLastVal {} {
	global mixval lastmixval qikedval
	if {[info exists lastmixval]} {
		set temp $mixval
		set mixval $lastmixval
		set lastmixval $temp
	} else {
		set lastmixval $mixval
	}
	set qikedval 0
}

proc GetFilenameToVal {} {
	global mixval laxtmixval m_list
	set ilist [$m_list curselection]
	if {([llength $ilist] != 1) || ($ilist == -1)} {
		Inf "Select (only) one mixfile line"
		return
	}
	set lastmixval $mixval
	set line [$m_list get $ilist]
	if {[string match [string index $line 0] "\{"]} {
		set line [StripCurlies $line]
	}
	if {[string match ";" [string index $line 0]]} {
		set line [string range $line 1 end]
	}
	set line [split $line]
	set cnt 0
	foreach item $line {
		set item [string trim $item]
		if {[string length $item] <= 0} {
			continue
		}
		if {[file exists $item]} {
			set item [file rootname [file tail $item]]
			set mixval $item
		}
		break
	}
}

proc QikUpVal {down} {
	global mixval lastmixval qikedvalup qikedvaldn
	if {[IsNumeric $mixval]} {
		set lastmixval $mixval
		if {[regexp {^[0-9]+$} $mixval]} {
			if {$down} {
				incr mixval -1
			} else {
				incr mixval
			}
		} elseif {$down} {
			set mixval [expr $mixval - 1]
		} else {
			set mixval [expr $mixval + 1]
		}
	}
	set qikedvalup 0
	set qikedvaldn 0
}

#-- Remember hiliting on qikedit listing

proc RememberHilite {fnam} {
	global qe_last_sel m_list
	if {[info exists m_list]} {
		set qe_last_sel [$m_list curselection]
		set qe_last_sel [list $fnam $qe_last_sel]
	}
}
