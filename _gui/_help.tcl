#
# SOUND LOOM RELEASE mac version 17.0.4
#

#RWD June 27 2013
# ... changed message from "Active Window" etc to just "Active", trying to reduce overall width.

#############
#	HELP	#
#############

#------ Activate help mode WHEREVER IT'S CALLED and turn off the window

proc ActivateHelp {w} {
	global wksp_hlp_actv procmenu_hlp_actv ppg_hlp_actv qikedit_hlp_actv science_hlp_actv
	global brkedit_hlp_actv pdisplay_hlp_actv inspage_hlp_actv tabedit_hlp_actv tabed mixd2 ts_hlp_actv

	switch -- $w {
		.workspace.h -
		.workspace.c.canvas.f.h {
			DisableWorkspace $w
			ActivateWorkspaceHelp
			SetupTestbedHelp
			$w.hlp config -command "DisableHelpOnWorkspace $w"
			$w.con config -command "ReactivateWorkspace $w"
			set wksp_hlp_actv 1
		}
 		.menupage.help -
		.menupage.c.canvas.f.help {
			DisableProcmenu $w
			ActivatePrcH
			$w.hlp config -command "DisableHelpOnProcmenu $w"
			$w.con config -command "ReactivateProcmenu $w"
			set procmenu_hlp_actv 1
		}
		.ppg.help -
		.ppg.c.canvas.f.help {
			DisablePpg $w
			ActivatePpgH
			$w.hlp config -command "DisablePpgH $w"
			$w.con config -command "ReactivatePpg $w"
			set ppg_hlp_actv 1
		}
		.get_brkfile.help -
		.get_brkfile.c.canvas.f.help {
			DisableBrkedit $w
			ActivateBrkeditHelp
			$w.hlp config -command "DisableBrkeditHelp $w"
			$w.con config -command "ReactivateBrkedit $w"
			set brkedit_hlp_actv 1
		}
		.pdisplay.help -
		.pdisplay.c.canvas.f.help {
			DisablePdisplay $w
			ActivatePdisplayHelp
			$w.hlp config -command "DisablePdisplayHelp $w"
			$w.con config -command "ReactivatePdisplay $w"
			set pdisplay_hlp_actv 1
		}
		.inspage.help -
		.inspage.c.canvas.f.help {
			DisableInspage $w
			ActivateInspageHelp
			$w.hlp config -command "DisableInspageHelp $w"
			$w.con config -command "ReactivateInspage $w"
			set inspage_hlp_actv 1
		}
		.ted.help -
		.ted.c.canvas.f.help {
			DisableTabedit $w
			ActivateTabeditHelp
			$w.hlp config -command "DisableHelpOnTabedit $w"
			$w.con config -command "ReactivateTabedit $w"
			set tabedit_hlp_actv 1
		}
		.mixdisplay2.1.h -
		.mixdisplay2.c.canvas.f.1.h {
			DisableQikedit $w
			ActivateQikeditHelp
			$w.hlp config -command "DisableHelpOnQikedit $w"
			$w.con config -command "ReactivateQikedit $w"
			set qikedit_hlp_actv 1
		}
		.show_brkfile2.btns {
			DisableScience $w
			ActivateScienceHelp
			$w.hlp config -command "DisableScienceHelp $w"
			$w.con config -command "ReactivateScience $w"
			set science_hlp_actv 1
		}
		.ts.0 {
			DisableTs $w
			ActivateTsHelp
			$w.hlp config -command "DisableTsHelp $w"
			$w.con config -command "ReactivateTs $w"
			set ts_hlp_actv 1
		}
	}
	$w.hlp config -text "Quiet!"

	PutHelpInPassiveMode $w
	switch -- $w {
		.workspace.h -
		.workspace.c.canvas.f.h {
			$w.help config -bg [option get . activeBackground {}] -text "WINDOW INACTIVE: click any item on screen, or Testbed menu items, to see Help info here"
		}
		default {
			$w.help config -bg [option get . activeBackground {}] -text "WINDOW INACTIVE: click any item on screen to see Help info here"
		}
	}
}

#------ Disable help

proc DisableHelp {w} {
	global procmenu_emph wrksp_emph ppg_emph ww evv
	global brkedit_emph inspage_emph pdisplay_emph tabed ts_emph

	$w.conn config -text ""
	bind $w.conn <ButtonRelease-1> {}
	$w.con config -text "" -state disabled -bg [$ww cget -background] -borderwidth 0
	$w.hlp config -text "Help" -command "ActivateHelp $w"
	$w.help config -text "$evv(HELP_DEFAULT)" -bg [$ww cget -background] -fg [option get . foreground {}]
	switch -- $w {
		.workspace.h -
		.workspace.c.canvas.f.h {
			foreach emph $wrksp_emph {
				$emph config -bg $evv(EMPH)
			}
		}
 		.menupage.help -
		.menupage.c.canvas.f.help {
			if [info exists procmenu_emph] {
				foreach emph $procmenu_emph {
					$emph config -bg $evv(EMPH)
				}
			}
		}
		.ppg.help -
		.ppg.c.canvas.f.help {
			foreach emph $ppg_emph {
				$emph config -bg $evv(EMPH)
			}
		}
		.get_brkfile.help -
		.get_brkfile.c.canvas.f.help {
			if [info exists brkedit_emph] {
				foreach emph $brkedit_emph {
					$emph config -bg $evv(EMPH)
				}
			}
		}
		.pdisplay.help -
		.pdisplay.c.canvas.f.help {
			foreach emph $pdisplay_emph {
				$emph config -bg $evv(EMPH)
			}
		}
		.inspage.help -
		.inspage.c.canvas.f.help {
			foreach emph $inspage_emph {
				$emph config -bg $evv(EMPH)
			}
		}
		.ted.help -
		.ted.c.canvas.f.help { 
			;#	No emphasis on tabedit page
		}
		.ts.0 {
			foreach emph $ts_emph {
				$emph config -bg $evv(EMPH)
			}
		}
	}
}

#------ Reactivate help
#RWD shortened Active/Passive messages by removing "Window" 
proc PutHelpInActiveMode {w} {
	global wrksp_emph procmenu_emph ppg_emph ins_concluding azaz dl evv
	global brkedit_emph inspage_emph tabedit_bindcmd tabedit_bind2 tabedit_bind3 z1 tabed icp ts_emph

	if [info exists tabed] {
		set tk $tabed.bot.ktframe
		set tf $tabed.bot.fframe
	}
	set n "normal"
	if [info exists icp] {
		set ku $icp.files.nameslist.bbbb
	}
#RWD
	$w.conn config -text "Active" -fg black
	bind $w.conn <ButtonRelease-1> "MacActiveHelp 1 $w.help"
	$w.con config -text "Set Passive" -state normal -borderwidth $evv(SBDR)
	switch -- $w {
		.workspace.h -
		.workspace.c.canvas.f.h {
			foreach emph $wrksp_emph {
				$emph config -bg $evv(EMPH)
			}
			if [info exists dl] {
				bind $dl  <ButtonRelease-1> {+ PossiblyGetSubdir}
				bind $dl  <Double-1>		{+ PossiblyPlaySnd %W %y}
			}
		}
 		.menupage.help -
		.menupage.c.canvas.f.help {
			if [info exists procmenu_emph] {
				foreach emph $procmenu_emph {
					$emph config -bg $evv(EMPH)
				}
			}
		}
		.ppg.help -
		.ppg.c.canvas.f.help {
			foreach emph $ppg_emph {
				$emph config -bg $evv(EMPH)
			}
		}
		.get_brkfile.help -
		.get_brkfile.c.canvas.f.help {
			if [info exists brkedit_emph] {
				foreach emph $brkedit_emph {
					$emph config -bg $evv(EMPH)
				}
			}
		}
		.get_pdisplay.help -
		.get_pdisplay.c.canvas.f.help {
			foreach emph $pdisplay_emph {
				$emph config -bg $evv(EMPH)
			}
		}
		.inspage.help -
		.inspage.c.canvas.f.help { 
			foreach emph $inspage_emph {
				$emph config -bg $evv(EMPH)
			}
			if {$ins_concluding} {
				$ku.bb1 config -state $n
				$ku.bb2 config -state $n
				$ku.bb3 config -state $n
				$ku.bb4 config -state $n	
				bind $ku.bb1  <ButtonRelease-1> {InsH standard}
				bind $ku.bb2  <ButtonRelease-1> {InsH standard}
				bind $ku.bb3  <ButtonRelease-1> {InsH standard}
				bind $ku.bb4  <ButtonRelease-1> {InsH standard}
			}
		}
		.ted.help -
		.ted.c.canvas.f.help { 
			bind $tf.l.list <ButtonRelease-1> {}
			bind $tf.l.list <ButtonRelease-1> "$tabedit_bindcmd"
			bind $tf.l.list <ButtonRelease-1> {+ TedH files}
			bind $tk.names.list <ButtonRelease-1> {}
			if [info exists tabedit_bind2] {
				bind $tk.names.list <ButtonRelease-1> "$tabedit_bind2"
				bind $tk.names.list <ButtonRelease-1> {+ TedH rnames}
			} else {
				bind $tk.names.list <ButtonRelease-1> {TedH rnames}
			}
			if [info exists z1] {
				bind $z1 <ButtonRelease-1> {}
				if [info exists tabedit_bind3] {
					bind $z1 <ButtonRelease-1> "$tabedit_bind3"
					if [string match $z1 $tabed.bot.icframe.l.list] {
						bind $z1 <ButtonRelease-1> {+ TedH colin}
					} else {
						bind $z1 <ButtonRelease-1> {+ TedH colout}
					}
				} else {
					if [string match $z1 $tabed.bot.icframe.l.list] {
						bind $z1 <ButtonRelease-1> {TedH colin}
					} else {
						bind $z1 <ButtonRelease-1> {TedH colout}
					}
				}
			}
			;#	No button emphasis on tabedit page
		}
		.ts.0 {
			foreach emph $ts_emph {
				$emph config -bg $evv(EMPH)
			}
		}
	}
	MacActiveHelp 1 $w.help
}

#------ Put Help in PAssive Mode

proc PutHelpInPassiveMode {w} {
	global wrksp_emph procmenu_emph ppg_emph z1 ins_concluding dl evv
	global brkedit_emph inspage_emph ins_file_lst tabed icp ts_emph

	if [info exists icp] {
		set ku $icp.files.nameslist.bbbb
	}
#RWD
	$w.conn config -text "Passive" -fg  $evv(SPECIAL)
	bind $w.conn <ButtonRelease-1> "MacActiveHelp 0 $w.help"
	$w.con config -text "Set Active" -state normal -borderwidth $evv(SBDR) -bg $evv(EMPH)
	switch -- $w {
		.workspace.h -
		.workspace.c.canvas.f.h {
			foreach emph $wrksp_emph {
				$emph config -bg [option get . background {}]
			}
			if [info exists dl] {
				bind $dl  <ButtonRelease-1> {}
				bind $dl  <Double-1> {}
				bind $dl  <ButtonRelease-1> {WkH DirectoryListing}
			}
		}
 		.menupage.help -
		.menupage.c.canvas.f.help {
			if [info exists procmenu_emph] {
				foreach emph $procmenu_emph {
					$emph config -bg [option get . background {}]
				}
			}
		}
		.ppg.help -
		.ppg.c.canvas.f.help {
			foreach emph $ppg_emph {
				$emph config -bg [option get . background {}]
			}
		}
		.get_brkfile.help -
		.get_brkfile.c.canvas.f.help {
			if [info exists brkedit_emph] {
				foreach emph $brkedit_emph {
					$emph config -bg [option get . background {}]
				}
			}
		}
		.get_pdisplay.help -
		.get_pdisplay.c.canvas.f.help {
			foreach emph $pdisplay_emph {
				$emph config -bg [option get . background {}]
			}
		}
		.inspage.help -
		.inspage.c.canvas.f.help {
			foreach emph $inspage_emph {
				$emph config -bg [option get . background {}]
			}
			if {$ins_concluding} {
				bind $ku.bb1  <ButtonRelease-1> {InsH standard}
				bind $ku.bb2  <ButtonRelease-1> {InsH standard}
				bind $ku.bb3  <ButtonRelease-1> {InsH standard}
				bind $ku.bb4  <ButtonRelease-1> {InsH standard}
				bind $icp.files.nameslist.lbox.list <ButtonRelease-1> {}
				bind $icp.files.nameslist.lbox.list <ButtonRelease-1> {InsH RecentNames}
				bind $icp.files.nameslist.lboxb.list <ButtonRelease-1> {}
				bind $icp.files.nameslist.lboxb.list <ButtonRelease-1> {InsH SourceNames}
			} else {
				bind $ins_file_lst <ButtonRelease-1> {}	
				bind $ins_file_lst <ButtonRelease-1> {InsH filelist}	
			}
		}
		.ted.help -
		.ted.c.canvas.f.help { 
			bind $tabed.bot.fframe.l.list <ButtonRelease-1> {}
			bind $tabed.bot.fframe.l.list <ButtonRelease-1> {TedH files}
			bind $tabed.bot.ktframe.names.list <ButtonRelease-1> {}
			bind $tabed.bot.ktframe.names.list <ButtonRelease-1> {TedH rnames}
			if [info exists z1] {
				bind $z1 <ButtonRelease-1> {}
				if [string match $z1 $tabed.bot.icframe.l.list] {
					bind $tabed.bot.icframe.l.list <ButtonRelease-1> {TedH colin}
				} else {
					bind $tabed.bot.ocframe.l.list <ButtonRelease-1> {TedH colout}
				}
			}
			;#	No emphasis on tabedit page
		}
		.ts.0 {
			foreach emph $ts_emph {
				$emph config -bg [option get . background {}]
			}
		}
	}
	MacActiveHelp 0 $w.help
}

#------ HELP FOR WORKSPACE

proc ActivateWorkspaceHelp {} {
	global ww dl top_user evv
	set w $ww.1.a

	bind $ww <Key-space> {}
	bind $ww.1.b.de	<ButtonRelease-1> {WkH wksp_dirname}
	bind $ww.1.b.dm <ButtonRelease-1> {WkH wksp_dirname}
	bind $ww.1.b.db.db1	<ButtonRelease-1> {WkH Directory}
	bind $ww.1.b.db.db2	<ButtonRelease-1> {WkH Findfile}
	bind $ww.h.q 			<ButtonRelease-1> {WkH Quit}
	bind $w.endd.l.new2.cs 	<ButtonRelease-1> {WkH Search}
	bind $w.endd.l.new2.cs2	<ButtonRelease-1> {WkH SearchAgain}
	bind $w.endd.l.new2.ca 	<ButtonRelease-1> {WkH ConcertA}
	bind $w.endd.l.new2.pla <ButtonRelease-1> {WkH Play}
	bind $w.endd.l.new2.b 	<ButtonRelease-1> {WkH BakupWkspace}

	bind $w.endd.r.over.sel <ButtonRelease-1> {WkH ToSelectionMode}

	bind $w.endd.r.rr.cnts <ButtonRelease-1> {WkH CountChoice}
	bind $w.endd.r.rr.remem <ButtonRelease-1> {WkH RememberChoice}
	bind $w.endd.r.rr.resto <ButtonRelease-1> {WkH RestoreChoice}
	bind $w.endd.r.rr.tfile <ButtonRelease-1> {WkH ChoiceToFile}

	bind $w.endd.r.x1.cc	<ButtonRelease-1> {WkH ClearChoice}
	bind $w.endd.r.x1.ro	<ButtonRelease-1> {WkH ReorderChoice}
	bind $w.endd.r.x2.la	<ButtonRelease-1> {WkH GetLast}
	bind $w.endd.r.x2.cp	<ButtonRelease-1> {WkH GetPrevious}
	bind $w.endd.r.x1.ch	<ButtonRelease-1> {WkH GetOther}
	bind $w.endd.r.x2.da	<ButtonRelease-1> {WkH ChoiceData}

	bind $w.endd.l.cnts.al  <ButtonRelease-1> {WkH CountAll}
	bind $w.endd.l.cnts.all <ButtonRelease-1> {WkH CountAll}
	bind $w.endd.l.cnts.remem <ButtonRelease-1> {WkH RememberWkspace}
	bind $w.endd.l.cnts.resto <ButtonRelease-1> {WkH RestoreWkspace}
	bind $w.endd.l.cnts.nl  <ButtonRelease-1> {WkH CountNew}
	bind $w.endd.l.cnts.new <ButtonRelease-1> {WkH CountNew}

	bind $w.endd.l.new.all <ButtonRelease-1> {WkH OptionsAll}
	bind $w.endd.l.new.few <ButtonRelease-1> {WkH OptionsFew}
	bind $w.endd.l.new.cre <ButtonRelease-1> {WkH OptionsCre}

	bind $w.top.pro 		<ButtonRelease-1> {WkH Process}
	bind $w.top.machcr 	<ButtonRelease-1> {WkH CreateIns}
	bind $w.top.hist 		<ButtonRelease-1> {WkH Recall}
	bind $w.top.bulk 		<ButtonRelease-1> {WkH Bulk}
	bind $w.top.batch 		<ButtonRelease-1> {WkH Batchfile}
	bind $w.mez.tap 		<ButtonRelease-1> {WkH Tap}
	bind $w.mez.taptwo		<ButtonRelease-1> {WkH Taptwo}
	bind $w.mez.taptap		<ButtonRelease-1> {WkH Taptap}
	bind $w.mez.bkgd		<ButtonRelease-1> {WkH Bkgd}
	bind $w.top.calc	 	<ButtonRelease-1> {WkH Calculator}
	bind $w.mez.ref	 	<ButtonRelease-1> {WkH Ref}
	bind $w.mez.nns	 	<ButtonRelease-1> {WkH Notepad}
	bind $w.top.tedit	 	<ButtonRelease-1> {WkH TabEditor}
	bind $ww.h.syscon 	<ButtonRelease-1> {WkH SeeSys}
	bind $w.endd.l.title 	<ButtonRelease-1> {WkH MainListbox}
	bind $w.endd.r.l 		<ButtonRelease-1> {WkH ChoiceListing}

	bind $ww.1.a.endd.l.sub.qik.qik.qik <ButtonRelease-1> {WkH Qik}
	bind $ww.1.a.endd.l.sub.qik.qik.qset <ButtonRelease-1> {WkH Qikset}
	bind $ww.1.a.endd.l.sub.qik.which <ButtonRelease-1> {WkH WhichMenu}
	bind $ww.1.a.endd.l.sub.qik.refresh <ButtonRelease-1> {WkH WkRefresh}
	bind $ww.1.a.endd.l.sub.qik.main.play <ButtonRelease-1> {WkH MainPlay}
	bind $ww.1.a.endd.l.sub.qik.main.kill <ButtonRelease-1> {WkH MainDump}
	bind $ww.1.a.endd.l.sub.cho.tochos <ButtonRelease-1> {WkH Tochos}
	bind $ww.1.a.endd.l.sub.cho.adchos <ButtonRelease-1> {WkH Addchos}
	bind $ww.1.a.endd.l.sub.cho.totop  <ButtonRelease-1> {WkH Tochostop}
	bind $ww.1.a.endd.l.sub.cho.mix.lmix  <ButtonRelease-1> {WkH LastMix}
	bind $ww.1.a.endd.l.sub.cho.mix.mmix  <ButtonRelease-1> {WkH MainMix}
	bind $ww.1.a.endd.l.sub.cho.mix.rmix  <ButtonRelease-1> {WkH RecentMixes}
	catch [bind $ww.1.a.endd.l.sub.cho.thum.bb   <ButtonRelease-1> {WkH Thumbs}]
	bind $ww.1.a.endd.r.next.1         <ButtonRelease-1> {WkH Gettop}
	bind $ww.1.a.endd.r.next.2         <ButtonRelease-1> {WkH Addtop}
	bind $ww.1.a.endd.r.next2          <ButtonRelease-1> {WkH Addtopattop}
	bind $ww.1.a.endd.r.next3.lf       <ButtonRelease-1> {WkH Lastout}
	bind $ww.1.a.endd.r.next3.un       <ButtonRelease-1> {WkH Chundo}
	bind $ww.1.a.endd.r.next4.oa       <ButtonRelease-1> {WkH Oneatatime}
	bind $ww.1.a.endd.r.next4.nn       <ButtonRelease-1> {WkH Nextatatime}
	if [info exists dl] {
		ActivateDirDialogHelp
	}
}

proc WkH {subject} {
	global ww selection_mode evv
	set f $ww.h.help
	switch -- $subject {
		Shortcuts {
			$f config -text "Display keyboard (and mouse) shortcuts available on workspace"
		}
		wksp_dirname {
			$f config -text "Enter directory name: (in order to see files in directory OR bakup selected workspace files to it)"
		}
		ConcertA {
			$f config -text "Shift Click to Play Concert A pitch : Click to access other pitches to play."
		}
		Directory {
			$f config -text "See available directories. You can select a directory with the mouse."
		}
		Findfile {
			$f config -text "Find an existing file on your system : or find a file being used in existing mixfiles."
		}
		BakupWkspace {
			$f config -text "Bakup files that exist only in the working directory, to a named directory"
		}
		MainListbox {
			$f config -text "List of files working on, or have generated, in this session. (\"TAB\" highlights 'Chosen List' files)"
		}
		Quit {
			$f config -text "Quit this session. (Workspace state will be backed up, unless you specify not)"
		}
		ClearWkspace {
			$f config -text "Clear workspace of files, EXCEPT those not yet backed-up to specific directories (No Files Deleted)"
		}
		Search {
			$f config -text "Find a file on the Workspace, using (part of) its name as a search-string."
		}
		SearchAgain {
			$f config -text "Find another file on the Workspace, using the same search-string as before."
		}
		ToSelectionMode {
			if {$selection_mode} {
				$f config -text "Stop choosing files for processing: return to normal workspace mode."
			} else {
				$f config -text "Allow files on workspace to be chosen for processing."
			}
		}
		Play {
			$f config -text "See all SOUND files on workspace, and play file(s) you select."
		}
		CountChoice {
			$f config -text "Count of the number of files chosen."
		}
		CountAll {
			$f config -text "Count of the number of files on the workspace."
		}
		CountNew {
			$f config -text "Count of the number of newly created files (not yet backed up) on the workspace."
		}
		RememberChoice {
			$f config -text "Remember current (list of) selected file(s), to restore later."
		}
		RestoreChoice {
			$f config -text "Get a previously Stored (list of) selected file(s), and use it to replace the current list."
		}
		ChoiceToFile {
			$f config -text "Put the current list of chosen files into a textfile, and put that file on the workspace."
		}
		RememberWkspace {
			$f config -text "Remember current list of files on workspace, to restore later."
		}
		RestoreWkspace {
			$f config -text "Replace current workspace list by a remembered list. (Files not yet backed up, remain on workspace)."
		}
		ClearChoice {
			$f config -text "Clear list of files chosen for processing."
		}
		ReorderChoice {
			$f config -text "Reverse, Rotate or otherwise reorder files in the Chosen Files list."
		}
		GetLast {
			$f config -text "List the last output files, in the Chosen Files list."
		}
		GetOther {
			$f config -text "Get files of particular specifications: Or Modify files on Chosen List."
		}
		GetPrevious {
			$f config -text "Get some previous chosen-files-listing."
		}
		OptionsAll {
			$f config -text "Operations on all (appropriate) files on workspace:  : or Creation of files."
		}
		OptionsFew {
			$f config -text "Operations on cursor-selected files on the workspace."
		}
		OptionsCre {
			$f config -text "operations on cursor-selected Files of a Particular Type"
		}
		Stop {
			$f config -text "Stop soundfile play"
		}
		Process {
			$f config -text "Process the file(s) on the Chosen Files list"
		}
		CreateIns {
			if [string match [$ww.1.a.top.batch cget -state] "disabled"] {
				CDP_Specific_Usage $evv(INSTRUMENT) 0
			} else {
				$f config -text "Record the sequence of processes (and parameters) you use, building an instrument, to save"
			}
		}
		Recall {
			$f config -text "Recall a process (or instrument) used on a specific file, in this session or in a previous session."
		}
		Voicebox {
			$f config -text "Analysis file on Chosen List. Work with speech, or segmented snds. More \"Help\" inside VBOX window."
		}
		Display {
			$f config -text "Display, permanently, contents of selected textfile."
		}
		Bulk {
			$f config -text "Apply the same process to each of the files in the Chosen Files list."
		}
		Batchfile {
			if [string match [$ww.1.a.top.batch cget -state] "disabled"] {
				CDP_Specific_Usage $evv(BATCH) 0
			} else {
				$f config -text "Run a sequence of processes in a batchfile : (you can create batchfiles from Parameters page)."
			}
		}
		Tap {
			$f config -text "Tap twice, to measure time between those two taps - in seconds, and as a tempo marking."
		}
		Taptwo {
			$f config -text "Tap several times, then hit Stop button (which appears), to measure average tempo of taps."
		}
		Taptap {
			$f config -text "Create a list of times in a file, by tapping out a rhythm."
		}
		Bkgd {
			$f config -text "Various high level music facilities: Click on any menu item for more information."
		}
		Calculator {
			$f config -text "Calculator for converting between musical units, doing maths, and storing reference values."
		}
		Ref {
			$f config -text "See list of your own Reference Values ; Get or Keep a value, or Edit the list of values."
		}
		Notepad {
			$f config -text "Call up a notebook where you can keep notes about what you've done, or plan to do."
		}
		TabEditor {
			$f config -text "Manipulate (or create) columns of data in text files."
		}
		SeeSys {
			$f config -text "See/Reset System variables: Manage logs,refvals,Table Editor macros: edit saved Wkspace Lists etc."
		}
		tip {
			$f config -text "If you have a problem on this page, consult the 'Tips' information."
		}
		ChoiceListing {
			$f config -text "List of files you wish to process. When list highlighted, clicking on item REMOVES it from list."
		}
		DirectoryListing {
			$f config -text "List of files in directory whose name you have specified"
		}
		DirectoryExt {
			$f config -text "Name-Extension of soundfiles you are using"
		}
		DirectorySrate {
			$f config -text "Sampling Rate of soundfiles you are using"
		}
		DirList {																	 
			$f config -text "Display files of the directory you have named, in the Directory Listing below,"
		}
		Updir {																	 
			$f config -text "Go to the directory which contains the listed subdirectory"
		}
		DirGet {
			$f config -text "Add or copy selected files to workspace listing (only CDP compatible files will be grabbed)"
		}
		DirRefresh {
			$f config -text "Update data on files in the source directory listing."
		}
		Srate {
			$f config -text "Sndfiles can only be grabbed to workspace if they have specified sampling rate (change here)"
		}
		DirDest {
			$f config -text "Delete files in this source directory."
		}
		DirPlay {
			$f config -text "Play a (single) selected file in listed directory (if playable), or Read it (if readable)."
		}
		ChoiceData {
			$f config -text "Play or Read file(s), see properties, find maximum sample, or Refresh Data."
		}
		Qik {
			$f config -text "Quickly Activate a preset menu choice (See \"SET\" button to set this up)."
		}
		Qikset {
			$f config -text "Setup item in \"DO IT AGAIN\" box on menu to \"QIK\" button, for rapid future access."
		}
		WhichMenu  {
			$f config -text "Displays the appropriate menu for a desired action on the workspace."
		}
		WkRefresh  {
			$f config -text "Refresh all the property information about files on the Workspace."
		}
		MainPlay  {
			if {[$ww.1.a.endd.l.sub.qik.main.play cget -borderwidth] == 2} {
				$f config -text "Play the sound output of the \"Main Mix\"."
			}
		}
		MainDump {
			if {[$ww.1.a.endd.l.sub.qik.main.kill cget -borderwidth] == 2} {
				$f config -text "If the sound associated with the \"Main Mix\" is incorrect, disassociate it."
			}
		}
		Tochos {
			$f config -text "Replace Chosen Files list with files highlighted on workspace."
		}
		Addchos {
			$f config -text "Add files highlighted on workspace to end of files listed on Chosen Files list."
		}
		Tochostop {
			$f config -text "Add files highlighted on workspace to TOP of files listed on Chosen Files list."
		}
		LastMix  {
			$f config -text "Replace Chosen Files with Last Mixfile used."
		}
		MainMix  {
			$f config -text "Replace Chosen Files with Main Mixfile."
		}
		RecentMixes  {
			$f config -text "Display a list of recently used Mixfiles, and select one to use."
		}
		Thumbs  {
			$f config -text "Work with (mono) Thumbnail of multichannel sound on Chosen Files list."
		}
		Gettop {
			$f config -text "Replace Chosen Files list with file at top of workspace."
		}
		Addtop {
			$f config -text "Add file at top of workspace to end of list of files on Chosen Files list."
		}
		Addtopattop {
			$f config -text "Add file at top of workspace to top of list of files on Chosen Files list."
		}
		Lastout {
			$f config -text "Replace files on Chosen List by last (set of) output file(s)."
		}
		Chundo {
			$f config -text "UNDO the last change to the Chosen Files list."
		}
		Oneatatime {
			$f config -text "Process Chosen Files one-at-a-time."
		}
		Nextatatime {
			$f config -text "If processing Chosen Files one-at-a-time, get the next file to process."
		}
	}
}

proc DisableHelpOnWorkspace {wk} {
	global ww wl dl wrksp_actv wksp_hlp_actv top_user ch selection_mode showing_pmarks evv
	set w $ww.1.a

	bind $ww.1.b.de	<ButtonRelease-1> {}
	bind $ww.1.b.dm <ButtonRelease-1> {}
	bind $ww.1.b.db.db1 <ButtonRelease-1> {}
	bind $ww.1.b.db.db2 <ButtonRelease-1> {}
	bind $ww.h.q 			<ButtonRelease-1> {}
	bind $w.endd.l.new2.cs 	<ButtonRelease-1> {}
	bind $w.endd.l.new2.cs2	<ButtonRelease-1> {}
	bind $w.endd.l.new2.ca 	<ButtonRelease-1> {}
	bind $w.endd.l.new2.pla <ButtonRelease-1> {}
	bind $w.endd.l.new2.b 	<ButtonRelease-1> {}

	bind $w.endd.r.over.sel <ButtonRelease-1> {}

	bind $w.endd.r.rr.cnts <ButtonRelease-1> {}
	bind $w.endd.r.rr.remem <ButtonRelease-1> {}
	bind $w.endd.r.rr.resto <ButtonRelease-1> {}
	bind $w.endd.r.rr.tfile <ButtonRelease-1> {}

	bind $w.endd.r.x1.cc	<ButtonRelease-1> {}
	bind $w.endd.r.x1.ro	<ButtonRelease-1> {}
	bind $w.endd.r.x2.la	<ButtonRelease-1> {}
	bind $w.endd.r.x2.cp	<ButtonRelease-1> {}
	bind $w.endd.r.x1.ch	<ButtonRelease-1> {}
	bind $w.endd.r.x2.da	<ButtonRelease-1> {}

	bind $w.endd.l.cnts.al  <ButtonRelease-1> {}
	bind $w.endd.l.cnts.all <ButtonRelease-1> {}
	bind $w.endd.l.cnts.remem <ButtonRelease-1> {}
	bind $w.endd.l.cnts.resto <ButtonRelease-1> {}
	bind $w.endd.l.cnts.nl  <ButtonRelease-1> {}
	bind $w.endd.l.cnts.new <ButtonRelease-1> {}

	bind $w.endd.l.new.all <ButtonRelease-1> {}
	bind $w.endd.l.new.few <ButtonRelease-1> {}
	bind $w.endd.l.new.cre <ButtonRelease-1> {}

	bind $w.top.pro 		<ButtonRelease-1> {}
	bind $w.top.machcr 	<ButtonRelease-1> {}
	bind $w.top.hist 		<ButtonRelease-1> {}
	bind $w.top.bulk 		<ButtonRelease-1> {}
	bind $w.top.batch	 	<ButtonRelease-1> {}
	bind $w.mez.tap		 	<ButtonRelease-1> {}
	bind $w.mez.taptwo	 	<ButtonRelease-1> {}
	bind $w.mez.taptap	 	<ButtonRelease-1> {}
	bind $w.mez.bkgd	 	<ButtonRelease-1> {}
	bind $w.top.calc	 	<ButtonRelease-1> {}
	bind $w.mez.ref	 	<ButtonRelease-1> {}
	bind $w.mez.nns	 	<ButtonRelease-1> {}
	bind $w.top.tedit	 	<ButtonRelease-1> {}
	bind $ww.h.syscon 	<ButtonRelease-1> {}
	bind $w.endd.l.title 	<ButtonRelease-1> {}
	bind $w.endd.r.l 		<ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.qik.qik.qik <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.qik.qik.qset <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.qik.which	  <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.qik.refresh   <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.qik.main.play <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.qik.main.kill <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.cho.tochos <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.cho.adchos <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.cho.totop  <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.cho.mix.lmix  <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.cho.mix.mmix  <ButtonRelease-1> {}
	bind $ww.1.a.endd.l.sub.cho.mix.rmix  <ButtonRelease-1> {}
	catch [bind $ww.1.a.endd.l.sub.cho.thum.bb   <ButtonRelease-1> {}]
	bind $ww.1.a.endd.r.next.1         <ButtonRelease-1> {}
	bind $ww.1.a.endd.r.next.2         <ButtonRelease-1> {}
	bind $ww.1.a.endd.r.next2          <ButtonRelease-1> {}
	bind $ww.1.a.endd.r.next3.lf       <ButtonRelease-1> {}
	bind $ww.1.a.endd.r.next3.un       <ButtonRelease-1> {}
	bind $ww.1.a.endd.r.next4.oa       <ButtonRelease-1> {}
	bind $ww.1.a.endd.r.next4.nn       <ButtonRelease-1> {}

	if [info exists dl] {
		DisableDirDialogHelp
	}
	DisableHelp $wk
	set wksp_hlp_actv 0
	if {!$wrksp_actv} {
		ReactivateWorkspace $wk
	} else {
		bind $wl <ButtonRelease-1> {}
		bind $wl <Double-1> {PossiblyPlaySnd %W %y}
		bind $ch <ButtonRelease-1> {}
		if {$selection_mode} {
			bind $wl <ButtonRelease-1> {ModChlist %y}
			bind $ch <ButtonRelease-1> {ModSlist %y}
		}
		if {$showing_pmarks} {
			bind $wl <ButtonRelease-1> {+ ShowPitchmark %y}
		}
		bind $ww <Control-Key-p> {UniversalPlay ww 0}
		bind $ww <Control-Key-P> {UniversalPlay ww 0}
		bind $ww <Key-space>	 {UniversalPlay ww 0}
		bind $ww <Control-Key-F> {Show_Props workspace 0}
		bind $ww <Control-Key-f> {Show_Props workspace 0}
		bind $ww <Control-Key-c> {CopyToWkspace_or_QuickCopy}
		bind $ww <Control-Key-C> {CopyToWkspace_or_QuickCopy}
		bind $ww <Control-Key-r> {RemoveFromWkspace wk}
		bind $ww <Control-Key-R> {RemoveFromWkspace wk}
		bind $ww <Control-Key-d> {DeleteFromSystem 0}
		bind $ww <Control-Key-D> {DeleteFromSystem 0}
		bind $ww <Shift-Key-c> {SomewhereOnWkspace}
		bind $ww <Shift-Key-C> {SomewhereOnWkspace}
		bind $ww <Shift-Key-p> {PossiblyPut %y}
		bind $ww <Shift-Key-P> {PossiblyPut %y}
	}
	SilenceTestbedHelp
}

proc ReactivateWorkspace {wk} {
	global sndgraphics ww wl wst ch dl wrksp_actv wksp_hlp_actv selection_mode top_user showing_pmarks evv
 	global wksp_in_chose_mode
	set w $ww.1.a

	SilenceTestbedHelp
	set n "normal"
	set indx 0
	foreach st $wst {
		switch -exact -- $indx {
 			0 {$w.endd.r.x1.cc	config -state $st}
			1 {$w.endd.r.x1.ro	config -state $st}
			2 {$w.endd.r.x2.la	config -state $st}
			3 {$w.endd.r.x2.cp	config -state $st}
			4 {$w.endd.r.x1.ch	config -state $st}
			5 {$w.endd.r.x2.da	config -state $st}
			6 {$w.endd.l.new.all config -state $st}
			7 {$w.endd.l.new.few config -state $st}
			8 {$w.endd.l.new.cre config -state $st}
			9 {$w.endd.l.new2.cs	config -state $st}
			10 {$w.endd.l.new2.cs2	config -state $st}
			11 {$w.endd.l.new2.pla	config -state $st}
			12 {$w.endd.l.new2.b	config -state $st}
		}
		incr indx
	}
	if {$wksp_in_chose_mode} {
		bind $ww <Key-space> {ToWkspaceMode}
	} else {
		bind $ww <Key-space> {ToSelectionMode}
	}
	$ww.1.b.de 	config -state $n
	$ww.1.b.db.db1 	config -state $n
	$ww.1.b.db.db2 	config -state $n
	$ww.h.q		config -state $n -bg $evv(QUIT_COLOR)
	$w.endd.r.over.sel  config -state $n
	$w.endd.l.new2.ca	config -state $n -background $evv(HELP)

	$w.endd.r.rr.cnts config -state $n
	$w.endd.r.rr.remem config -state $n
	$w.endd.r.rr.resto config -state $n
	$w.endd.r.rr.tfile config -state $n
	$w.endd.l.cnts.remem config -state $n
	$w.endd.l.cnts.resto config -state $n

	$w.top.pro 	config -state $n
	$w.top.machcr 	config -state $n
	$w.top.hist 	config -state $n
	$w.top.bulk 	config -state $n
	$w.top.batch config -state $n
	$w.mez.tap   config -state $n
	$w.mez.taptwo config -state $n
	$w.mez.taptap config -state $n
	$w.top.calc	  config -state $n    -background $evv(HELP)
	$w.mez.ref		 config -state $n -background $evv(HELP)
	$w.mez.nns		 config -state $n -background $evv(HELP)
	$w.top.tedit	 config -state $n -background $evv(HELP)
	$ww.h.syscon	 config -state $n
	$ww.1.a.endd.l.sub.qik.qik.qik config -state $n
	$ww.1.a.endd.l.sub.qik.qik.qset config -state $n
	$ww.1.a.endd.l.sub.qik.which	 config -state $n
	$ww.1.a.endd.l.sub.qik.refresh	 config -state $n
	$ww.1.a.endd.l.sub.qik.main.play config -state $n
	$ww.1.a.endd.l.sub.qik.main.kill config -state $n
	$ww.1.a.endd.l.sub.cho.tochos config -state $n
	$ww.1.a.endd.l.sub.cho.adchos config -state $n
	$ww.1.a.endd.l.sub.cho.totop  config -state $n
	$ww.1.a.endd.l.sub.cho.mix.lmix config -state $n
	$ww.1.a.endd.l.sub.cho.mix.mmix config -state $n
	$ww.1.a.endd.l.sub.cho.mix.rmix config -state $n
	catch [$ww.1.a.endd.l.sub.cho.thum.bb config -state $n]
	$ww.1.a.endd.r.next.1 config -state $n
	$ww.1.a.endd.r.next.2 config -state $n
	$ww.1.a.endd.r.next2   config -state $n
	$ww.1.a.endd.r.next3.lf	config -state $n
	$ww.1.a.endd.r.next3.un config -state $n
	$ww.1.a.endd.r.next4.oa config -state $n
	$ww.1.a.endd.r.next4.nn config -state $n
	if [info exists dl] {
		$ww.1.b.buttons2.lis	config -state $n
		$ww.1.b.buttons2.up		config -state $n
		$ww.1.b.buttons2.play 	config -state $n
		$ww.1.b.buttons2.get 	config -state $n
		$ww.1.b.buttons.srate 	config -state $n
		$ww.1.b.buttons.refr	config -state $n
		$ww.1.b.buttons.dest 	config -state $n
	}
	set wrksp_actv 1
	bind $wl <ButtonRelease-1> {}
	bind $wl <Double-1> {PossiblyPlaySnd %W %y}

	bind $wl <ButtonRelease-1> {}
	bind $wl <Double-1> {PossiblyPlaySnd %W %y}
	bind $ww <Control-Key-a> {GetNextToChosen 1}
	bind $ww <Control-Key-A> {GetNextToChosen 1}
	bind $ww <Control-Key-b> {GetFilesFromInsideChosenMixfile 1}
	bind $ww <Control-Key-B> {GetFilesFromInsideChosenMixfile 0}
	bind $ww <Control-Key-c> {CopyToWkspace_or_QuickCopy}
	bind $ww <Control-Key-C> {CopyToWkspace_or_QuickCopy}
	bind $ww <Control-Key-d> {ZDeleteFromSystem}
	bind $ww <Control-Key-D> {ZDeleteFromSystem}
	bind $ww <Control-0> {KeyViewWkspaceFile 0}
	bind $ww <Control-e> {KeyViewWkspaceFile 1}
	bind $ww <Control-E> {KeyViewWkspaceFile 1}
	bind $ww <Control-Key-f> {Show_Props workspace 0; SetSel prop}
	bind $ww <Control-Key-F> {Show_Props workspace 0; SetSel prop}
	bind $ww <Control-Key-g> {GrabToWkspace_or_GetSndfilesInTxtfile}
	bind $ww <Control-Key-G> {GrabToWkspace_or_GetSndfilesInTxtfile}
	bind $ww <Control-Key-h> {GetNextToChosen 2}
	bind $ww <Control-Key-H> {GetNextToChosen 2}
	bind $ww <Control-Key-l> {HiliteLastOutfiles}
	bind $ww <Control-Key-L> {HiliteLastOutfiles}
	bind $ww <Control-Key-m> {GetLastMixfile 2}
	bind $ww <Control-Key-M> {GetMainMixfile}
	bind $ww <Control-Key-n> {RenameWkspaceFiles; SetSel name}
	bind $ww <Control-Key-N> {RenameWkspaceFiles; SetSel name}
	bind $ww <Control-Key-p> {UniversalPlay ww 0}
	bind $ww <Control-Key-P> {UniversalPlay ww 0}
	bind $ww <Key-space>	 {UniversalPlay ww 0}
	bind $ww <Control-Key-r> {RemoveFromWkspace wk}
	bind $ww <Control-Key-R> {RemoveFromWkspace wk}
	bind $ww <Control-Key-s> {SearchWorkspaceForFile 2}
	bind $ww <Control-Key-S> {SearchWorkspaceForFile 0}
	bind $ww <Control-Key-z> {StrSortWl 1}
	bind $ww <Control-Key-Z> {StrGetDl}
	bind $ww <Control-Key-t> {GetNextToChosen 0}
	bind $ww <Control-Key-T> {GetNextToChosen 0}
	bind $ww <Control-Key-v> {DoView}
	bind $ww <Control-Key-V> {DoView}
	bind $ww <Control-Key-w> {WkspaceToggle}
	bind $ww <Control-Key-W> {WkspaceToggle}
	bind $ww <Control-Delete> {DeleteFromSystem 0}
	bind $ww <Control-Down>  {$wl yview moveto 1.0}
	bind $ww <Control-Up> {$wl yview moveto 0.0}
	bind $ww <Shift-Key-c> {SomewhereOnWkspace}
	bind $ww <Shift-Key-C> {SomewhereOnWkspace}
	bind $ww <Shift-Key-p> {PossiblyPut %y}
	bind $ww <Shift-Key-P> {PossiblyPut %y}

	bind $ww <Command-Key-a> {SelectType anal}
	bind $ww <Command-Key-b> {SelectType batch}
	bind $ww <Command-Key-e> {SelectType envel}
	bind $ww <Command-Key-f> {SelectType formant}
	bind $ww <Command-Key-m> {SelectType mix}
	bind $ww <Command-Key-c> {SelectType multimix}
	bind $ww <Command-Key-n> {ShowReminder}
	bind $ww <Command-Key-N> {NnnSee ~~~$wl~~~}
	bind $ww <Command-Key-p> {SelectType props}
	bind $ww <Command-Key-o> {SelectType sndlist}
	bind $ww <Command-Key-s> {SelectType snd}
	bind $ww <Command-Key-t> {SelectType text}

	bind $ww <Command-Key-A> {GetDirExt ana}
	bind $ww <Command-Key-B> {GetDirExt bat}
	bind $ww <Command-Key-E> {GetDirExt evl}
	bind $ww <Command-Key-F> {GetDirExt for}
	bind $ww <Command-Key-M> {GetDirExt mix}
	bind $ww <Command-Key-C> {GetDirExt mmx}
	bind $ww <Command-Key-Q> {GetDirExt prp}
	bind $ww <Command-Key-O> {GetDirExt orc}
	bind $ww <Command-Key-S> {GetDirExt snd}
	bind $ww <Command-Key-T> {GetDirExt txt}

	bind $ww <Control-Command-m> {SndInMix}
	bind $ww <Control-Command-M> {SndInMix}

	if {$sndgraphics} {
		bind $wl <Command-ButtonRelease-1> {ToPlayWindow %y}
	}
	bind $ww <Control-Key-i> {InterleaveFile}
	bind $ww <Control-Key-I> {InterleaveFile}

	bind $ch <ButtonRelease-1> {}
	if {$selection_mode} {
		bind $wl <ButtonRelease-1> {ModChlist %y}
		bind $ch <ButtonRelease-1> {ModSlist %y}
	}
	if {$wksp_hlp_actv} {
		bind $wl <ButtonRelease-1> {+ WkH MainListbox}
		bind $ch <ButtonRelease-1> {+ WkH ChoiceListing}
		PutHelpInActiveMode $wk
	}
	if {$showing_pmarks} {
		bind $wl <ButtonRelease-1> {+ ShowPitchmark %y}
	}
	$wk.con config -command "DisableWorkspace $wk"
}

proc ActivateDirDialogHelp {} {
	global dir_dlg_help_actvtd ww dl

	bind $ww.1.b.buttons2.lis  <ButtonRelease-1> {WkH DirList}
	bind $ww.1.b.buttons2.up   <ButtonRelease-1> {WkH Updir}
	bind $ww.1.b.buttons2.play <ButtonRelease-1> {WkH DirPlay}
	bind $ww.1.b.buttons2.get <ButtonRelease-1> {WkH DirGet}
	bind $ww.1.b.buttons.srate <ButtonRelease-1> {WkH Srate}
	bind $ww.1.b.buttons.refr <ButtonRelease-1> {WkH DirRefresh}
	bind $ww.1.b.buttons.dest <ButtonRelease-1> {WkH DirDest}
	bind $ww.1.b.msg  <ButtonRelease-1> {WkH DirectoryListing}
	bind $ww.1.b.labels.msg2 <ButtonRelease-1> {WkH DirectoryExt}
	bind $ww.1.b.labels.msg3 <ButtonRelease-1> {WkH DirectorySrate}
	bind $dl <ButtonRelease-1> {}
	bind $dl <Double-1> {}
	bind $dl <ButtonRelease-1> {WkH DirectoryListing}

	set dir_dlg_help_actvtd 1
}

proc DisableDirDialogHelp {} {
	global dir_dlg_help_actvtd ww dl

	bind $ww.1.b.buttons2.lis <ButtonRelease-1> {}
	bind $ww.1.b.buttons2.up  <ButtonRelease-1> {}
	bind $ww.1.b.buttons2.play <ButtonRelease-1> {}
	bind $ww.1.b.buttons2.get <ButtonRelease-1> {}
	bind $ww.1.b.buttons.srate <ButtonRelease-1> {}
	bind $ww.1.b.buttons.refr <ButtonRelease-1> {}
	bind $ww.1.b.buttons.dest <ButtonRelease-1> {}
	bind $ww.1.b.msg  <ButtonRelease-1> {}
	bind $ww.1.b.labels.msg2 <ButtonRelease-1> {}
	bind $ww.1.b.labels.msg3 <ButtonRelease-1> {}

	bind $dl  <ButtonRelease-1> {}
	bind $dl  <Double-1> {}
	bind $dl  <ButtonRelease-1> {PossiblyGetSubdir}
	bind $dl  <Double-1> {PossiblyPlaySnd %W %y}
	set dir_dlg_help_actvtd 0
}

proc DisableWorkspace {wk} {
	global sndgraphics ww wst wl ch dl wrksp_actv top_user evv
 	set w $ww.1.a

	set d "disabled"
	set n "normal"

	#	REMEMBER STATE OF WKSPPAGE BUTTONS

	catch {unset wst}	

	lappend wst [$w.endd.r.x1.cc cget -state]
	lappend wst [$w.endd.r.x1.ro cget -state]
	lappend wst [$w.endd.r.x2.la cget -state]
	lappend wst [$w.endd.r.x2.cp cget -state]
	lappend wst [$w.endd.r.x1.ch cget -state]
	lappend wst [$w.endd.r.x2.da cget -state]
	lappend wst [$w.endd.l.new.all	cget -state]
	lappend wst [$w.endd.l.new.few	cget -state]
	lappend wst [$w.endd.l.new.cre	cget -state]
	lappend wst [$w.endd.l.new2.cs	cget -state]
	lappend wst [$w.endd.l.new2.cs2	cget -state]
	lappend wst [$w.endd.l.new2.pla	cget -state]
	lappend wst [$w.endd.l.new2.b	cget -state]

	$ww.1.b.de 	config -state $d
	$ww.1.b.db.db1 	config -state $d
	$ww.1.b.db.db2 	config -state $d
	$ww.h.q 	config -state $d  -disabledforeground $evv(HELP_DISABLED_FG) -background [option get . background {}]
	$w.endd.l.new2.cs  config -state $d
	$w.endd.l.new2.cs2 config -state $d
	$w.endd.l.new2.ca  config -state $d -disabledforeground $evv(HELP_DISABLED_FG) -background [option get . background {}]
	$w.endd.l.new2.pla config -state $d
	$w.endd.l.new2.b   config -state $d

	$w.endd.r.over.sel config -state $d

	$w.endd.r.rr.cnts config -state $d
	$w.endd.r.rr.remem config -state $d
	$w.endd.r.rr.resto config -state $d
	$w.endd.r.rr.tfile config -state $d
	$w.endd.l.cnts.remem config -state $d
	$w.endd.l.cnts.resto config -state $d

	$w.endd.r.x1.cc	 config -state $d
	$w.endd.r.x1.ro	 config -state $d
	$w.endd.r.x2.la	 config -state $d
	$w.endd.r.x2.cp	 config -state $d
	$w.endd.r.x1.ch	 config -state $d
	$w.endd.r.x2.da	 config -state $d

	$w.endd.l.new.all config -state $d
	$w.endd.l.new.few config -state $d
	$w.endd.l.new.cre config -state $d

	$w.top.pro 	config -state $d
	$w.top.machcr 	config -state $d
	$w.top.hist 	config -state $d
	$w.top.bulk 	config -state $d
	$w.top.batch config -state $d
	$w.mez.tap config -state $d
	$w.mez.taptwo config -state $d
	$w.mez.taptap config -state $d
	$w.top.calc	 config -state $d     -disabledforeground $evv(HELP_DISABLED_FG) -background [option get . background {}]
	$w.mez.ref		 config -state $d -disabledforeground $evv(HELP_DISABLED_FG) -background [option get . background {}]
	$w.mez.nns		 config -state $d -disabledforeground $evv(HELP_DISABLED_FG) -background [option get . background {}]
	$w.top.tedit	 config -state $d -disabledforeground $evv(HELP_DISABLED_FG) -background [option get . background {}]
	$ww.h.syscon	 config -state $d
	$ww.1.a.endd.l.sub.qik.qik.qik config -state $d
	$ww.1.a.endd.l.sub.qik.qik.qset config -state $d
	$ww.1.a.endd.l.sub.qik.which	 config -state $d
	$ww.1.a.endd.l.sub.qik.refresh	 config -state $d
	$ww.1.a.endd.l.sub.qik.main.play config -state $d
	$ww.1.a.endd.l.sub.qik.main.kill config -state $d
	$ww.1.a.endd.l.sub.cho.tochos config -state $d
	$ww.1.a.endd.l.sub.cho.adchos config -state $d
	$ww.1.a.endd.l.sub.cho.totop  config -state $d
	$ww.1.a.endd.l.sub.cho.mix.lmix config -state $d
	$ww.1.a.endd.l.sub.cho.mix.mmix config -state $d
	$ww.1.a.endd.l.sub.cho.mix.rmix config -state $d
	catch {$ww.1.a.endd.l.sub.cho.thum.bb config -state $d}
	$ww.1.a.endd.r.next.1 config -state $d
	$ww.1.a.endd.r.next.2 config -state $d
	$ww.1.a.endd.r.next2   config -state $d
	$ww.1.a.endd.r.next3.lf	config -state $d
	$ww.1.a.endd.r.next3.un config -state $d
	$ww.1.a.endd.r.next4.oa config -state $d
	$ww.1.a.endd.r.next4.nn config -state $d
	if [info exists dl] {
		$ww.1.b.buttons2.lis	config -state $d
		$ww.1.b.buttons2.up		config -state $d
		$ww.1.b.buttons2.play 	config -state $d
		$ww.1.b.buttons2.get 	config -state $d
		$ww.1.b.buttons.srate 	config -state $d
		$ww.1.b.buttons.refr 	config -state $d
		$ww.1.b.buttons.dest 	config -state $d
	}
	set wrksp_actv 0
	PutHelpInPassiveMode $wk
	bind $ch <ButtonRelease-1> {}
	bind $wl <ButtonRelease-1> {}
	bind $wl <Double-1> {}
	bind $wl <ButtonRelease-1> {WkH MainListbox}
	bind $ch <ButtonRelease-1> {WkH ChoiceListing}
	catch {destroy .pmark}

	$ww.h.con config -command "ReactivateWorkspace $wk"
	bind $ww <Control-Key-a> {}
	bind $ww <Control-Key-A> {}
	bind $ww <Control-Key-b> {}
	bind $ww <Control-Key-B> {}
	bind $ww <Control-Key-c> {}
	bind $ww <Control-Key-C> {}
	bind $ww <Control-Key-d> {}
	bind $ww <Control-Key-D> {}
	bind $ww <Control-0> {}
	bind $ww <Control-e> {}
	bind $ww <Control-E> {}
	bind $ww <Control-Key-f> {}
	bind $ww <Control-Key-F> {}
	bind $ww <Control-Key-g> {}
	bind $ww <Control-Key-G> {}
	bind $ww <Control-Key-h> {}
	bind $ww <Control-Key-H> {}
	bind $ww <Control-Key-l> {}
	bind $ww <Control-Key-L> {}
	bind $ww <Control-Key-m> {}
	bind $ww <Control-Key-M> {}
	bind $ww <Control-Key-n> {}
	bind $ww <Control-Key-N> {}
	bind $ww <Control-Key-p> {}
	bind $ww <Control-Key-P> {}
	bind $ww <Key-space> {}
	bind $ww <Control-Key-r> {}
	bind $ww <Control-Key-R> {}
	bind $ww <Control-Key-s> {}
	bind $ww <Control-Key-S> {}
	bind $ww <Control-Key-z> {}
	bind $ww <Control-Key-Z> {}
	bind $ww <Control-Key-t> {}
	bind $ww <Control-Key-T> {}
	bind $ww <Control-Key-v> {}
	bind $ww <Control-Key-V> {}
	bind $ww <Control-Key-w> {}
	bind $ww <Control-Key-W> {}
	bind $ww <Control-Down>  {}
	bind $ww <Control-Up>	 {}
	bind $ww <Control-Delete> {}
	bind $ww <Shift-Key-c> {}
	bind $ww <Shift-Key-C> {}
	bind $ww <Shift-Key-p> {}
	bind $ww <Shift-Key-P> {}

	bind $ww <Command-Key-a> {}
	bind $ww <Command-Key-b> {}
	bind $ww <Command-Key-e> {}
	bind $ww <Command-Key-f> {}
	bind $ww <Command-Key-m> {}
	bind $ww <Command-Key-c> {}
	bind $ww <Command-Key-n> {}
	bind $ww <Command-Key-N> {}
	bind $ww <Command-Key-p> {}
	bind $ww <Command-Key-o> {}
	bind $ww <Command-Key-s> {}
	bind $ww <Command-Key-t> {}
	bind $ww <Command-Key-A> {}
	bind $ww <Command-Key-B> {}
	bind $ww <Command-Key-E> {}
	bind $ww <Command-Key-F> {}
	bind $ww <Command-Key-M> {}
	bind $ww <Command-Key-C> {}
	bind $ww <Command-Key-Q> {}
	bind $ww <Command-Key-O> {}
	bind $ww <Command-Key-S> {}
	bind $ww <Command-Key-T> {}

	bind $ww <Control-Command-m> {}
	bind $ww <Control-Command-M> {}

	if {$sndgraphics} {
		bind $wl <Command-ButtonRelease-1> {}
	}
	bind $ww <Control-Key-i> {}
	bind $ww <Control-Key-I> {}

	SetupTestbedHelp
}

#------ HELP FOR PARAMS PAGE

proc PpgH {subject args} {
	global ins_creation ins pmcnt pprg mmod papag evv
	set f $papag.help.help

	if {$ins(run)} {
		set thing Instrument
		set thingy Instrument
	} else {
		set thing Process
		set thingy System
	}
	switch -- $subject {
		Shortcuts {
			$f config -text "Display Keyboard Shortcuts available on the parameters page."
		}
		quit {
			$f config -text "Quit this session. (Workspace state will be backed up, unless you specify not)"
		}
		WhatVal {
			$f config -text "Explanation of how to run a range of values."
		}
		prmgrd {
			$f config -text "Set the parameter values for the $thing you are running"
		}
		NewProcess {
			$f config -text "Return to previous page to set up a different process or instrument"
		}
		mabo {
			if {$ins(create)} {
				$f config -text "Abandon instrument creation (and all files produced from processes used)"
			} else {
				$f config -text "Use the (first) Output file from this process, as input to the next process"
			}
		}
		Calculator {
				$f config -text "Calculator for converting between musical units, doing maths, and storing reference values."
		}
		TabEditor {
				$f config -text "Manipulate columns of data in text files."
		}
		Ref {
			$f config -text "See list of your own Reference Values ; Get or Keep a value, or Edit the list of values."
		}
		Notepad {
			$f config -text "Call up a notebook where you can keep notes about what you've done, or plan to do."
		}
		NewFiles {
			$f config -text "Choose new files to process"
		}
		ThisProcess {
			$f config -text "The process or instrument that is running"
		}
		ThisParams {
			if {$pmcnt > 0} {
				$f config -text "Enter below the parameters for the process you are running"
			}
		}
		ResetValues {
			$f config -text "Reset parameter values to those of most recent run (or to defaults, if not yet run)"
		}
		ResetPenult {
			$f config -text "Reset parameter values to those used in the penultimate run (if any)"
		}
		GetDefaults {
			$f config -text "Reset parameter values to Get the $thingy default settings."
		}
		RunProgram {
			$f config -text "Start the $thing"
		}
		Play {
			$f config -text "Play any soundfile(s) output from the $thing"
		}
		PlayInput {
			if {$pprg == $evv(PSOW_EXTEND)} {
				$f config -text "View and Play Source Sound(s) in a window where brkpnt files can be created."
			} else {
				$f config -text "Play any soundfile(s) (or the soundfile sources of other files) input to the $thing"
			}
		}
		EditInput {
			set bstring [$papag.parameters.output.editsrc cget -text]

			switch -- $bstring {
				"Edit Mix" {
					$f config -text "Edit the input mixfile."
				}
				"Invert" {
					$f config -text "Invert the balance parameters in a mix-balance parameter file."
				}
				"Edit Env" {
					$f config -text "Edit the input envelope."
				}
				"NudgeTime" {
					$f config -text "Manipulate the time sequence used to create the output."
				}
				"Time+Beat" {
					$f config -text "Create data sequence using Metronome Mark, Meter and Bar Count information ."
				}
				"Max Harmnc" {
					$f config -text "Calculate max no of harmonics possible. Put in parameter entry box, if in range."
				}
				"MakeLocus" {
					$f config -text "Call facility to design locus & other parameters, for specified sound outcomes."
				}
				"Snd View" -
				"View Src" {
					$f config -text "View and Play Source Sound(s) in a window where brkpnt files can be created."
				}
				"VibLocal" {
					$f config -text "Localise the vibrato to the time-extended FOF segment."
				}
			}
		}
		QikEditInput {
			set bstring [$papag.parameters.output.editqik cget -text]
			if {[regexp {^[\*]+} $bstring]} {
				$f config -text "Click here to reset Gain parameter to the value [lrange $bstring 1 end]"
			} else {
				switch -- $bstring {
					"QikEdit" {		
						$f config -text "Rapid editing of the input mixfile."
					}
					"SndSwap" {		
						$f config -text "Reverse the order of the Sounds on Chosen Files List."
					}
					"TapTime" {		
						$f config -text "Tap twice on  mouse: Time between taps is placed in Time Step parameter."
					}
					"Invert" {
						$f config -text "Values in pan datafile are inverted in range."
					}
					"Nudge" {
						$f config -text "Move values of all the parameters by the same amount."
					}
					"Str->Sq" {
						$f config -text "Convert timestretch data to timesqueeze data, and vice versa."
					}
					"Gain" {
						$f config -text "After 1st run, show gain for better result: if > 1 click again to reset gain parameter."
					}
					"Randomise" {
						$f config -text "Create new filterdata file with pitch (and amplitude) random-varied over time"
					}
					"Artic" {
						ArticHelp 0
					}
					"FileDur" {
						$f config -text "Transfer maxtime in frq breakpoint file to synthesis duration parameter."
					}
					"Draw" {
						$f config -text "Create an EQ data file."
					}
					"Details" {
						$f config -text "Display Information about the pitch data being used."
					}
					"CutBy" {
						$f config -text "Show how much has been removed from file by top-and-tail process."
					}
					"Merge" {
						$f config -text "Merge overlapping time-pairs in multi-edit data."
					}
					"Line Dur" {
						$f config -text "Set duration parameter to duration of line given in param 1."
					}
				}
			}
		}
		PropInput {
			$f config -text "Show properties of file(s) input to the $thing"
		}
		View {
			$f config -text "Display contents of any sound, analysis etc. file(s) output from the $thing"
		}
		ReadFile {
			$f config -text "Display contents of any textfile(s) output from the $thing"
		}
		KeepOutput {
			if {$ins_creation} {
				$f config -text "Confirm you want to retain the process you've just run, as part of the instrument."
			} else {
				$f config -text "Retain file(s) output from the $thing, and give them names"
			}
		}
		OutputInfo {
			if {!$ins_creation} {
				$f config -text "Operations on the process Output"
			}
		}
		Properties {
			$f config -text "See the properties of the output file(s)."
		}
		MaxSamp {
			$f config -text "Get the maximum value in the output file(s)."
		}
		InMaxSamp {
			$f config -text "Get the maximum value in the input file(s)."
		}
		patchlist {
			if {$pmcnt > 0} {
				$f config -text "A list of parameter patches you have saved for use with this $thing"
			} else {
				$f config -text "$thing takes no parameters, and therefore no patches"
			}
		}
		batches {
			$f config -text "Convert the current process into a batchfile"
		}
		Curpatch {
			if {$pmcnt > 0} {
				$f config -text "The currently loaded patch (if any)"
			} else {
				$f config -text "$thing takes no parameters, and therefore no patches"
			}
		}
		LoadPatch {
			if {$pmcnt > 0} {
				$f config -text "Load a selected patch (a set of values for ALL the parameters) for this $thing"
			} else {
				$f config -text "$thing takes no parameters, and therefore no patches"
			}
		}
		DeletePatch {
			if {$pmcnt > 0} {
				$f config -text "Delete one or more of your patches"
			} else {
				$f config -text "$thing takes no parameters, and therefore no patches"
			}
		}
		SubPatch {
			if {$pmcnt > 0} {
				$f config -text "Save or Get SOME of the parameters."
			} else {
				$f config -text "$thing takes no parameters, and therefore no patches"
			}
		}
		StorePatch {
			if {$pmcnt > 0} {
				$f config -text "Store the parameter settings of the process or instrument you are running, as a patch"
			} else {
				$f config -text "$thing takes no parameters, and therefore no patches"
			}
		}
		PtoB {
			$f config -text "Save current process as a batchfile (named in 'Name' panel): BatchFiles run from Wkspace."
		}
		PtoB2 {
			$f config -text "Save process,with your output file name, as a new batchfile (named in'Name' panel)."
		}
		PatoB {
			$f config -text "Append current process to existing batchfile (named in 'Name' panel): BatchFiles run from Wkspace."
		}
		PatoB2 {
			$f config -text "Append process,with your output file name, to existing batchfile (named in'Name' panel)."
		}
		patchname {
			if {$pmcnt > 0} {
				$f config -text "Enter a name for a new patch you are saving (Or a batchfile name .. see batchfile Buttons below)"
			} else {
				$f config -text "$thing takes no parameters, and therefore no patches"
			}
		}
		RestoreVal {
			$f config -text "Individual parameters reset to point where you began, by these buttons"
		}
		ConvertHms {
			$f config -text "Convert Hrs:Mins:Secs (e.g. 1:2:6.7 = 1hr 2mins 6.7secs) to Seconds.......or Mins:Secs to seconds"
		}
		DefaultVal {
			$f config -text "Individual parameters values set to $thingy defaults, by these buttons"
		}
		OrigDefaultVal {
			if {$ins(run)} {
				$f config -text "Individual parameters values set to System defaults, by these buttons"
			}
		}
		PenultVal {
			$f config -text "Individual parameters set to values from penultimate process-run, by these buttons"
		}
		Info {
			$f config -text "Get information about this $thing"
		}
		Orig {
			if {$ins(run)} {
				$f config -text "Reset System default values (rather than Instrument defaults)"
			}
		}
		Tone {
			$f config -text "Play Concert A, comparison tone."
		}
		GetTextfiles {
			$f config -text "See textfiles on Workspage e.g. to extract a value to use as a parameter."
		}
		MidiToTransposParam {
			MidiToTransposParamHelp
		}
		default {
			ErrShow "Unknown option in PpgH"
		}
	}
}

proc DisablePpg {w} {
	global ppg_actv pst pmcnt papag evv extrahelp

	set d "disabled"

	set pp $papag.parameters
	#	REMEMBER STATE OF PARAMPAGE BUTTONS

	catch {unset pst}
	lappend pst [$pp.output.editsrc	 cget -state]
	lappend pst [$pp.output.run   cget -state]
	lappend pst [$pp.output.play  cget -state]
	lappend pst [$pp.output.view  cget -state]
	lappend pst [$pp.output.read  cget -state]
	lappend pst [$pp.output.keep  cget -state]
	lappend pst [$pp.output.props cget -state]
	lappend pst [$pp.output.mxsmp cget -state]
	lappend pst [$pp.buttons.orig cget -state]
	lappend pst [$pp.zzz.mabo     cget -state]
	lappend pst [$pp.zzz.calc     cget -state]
	lappend pst [$pp.zzz.ref	  cget -state]
	lappend pst [$pp.zzz.nns	  cget -state]
	lappend pst [$pp.zzz.aaa	  cget -state]
	lappend pst [$pp.zzz.tedit	  cget -state]
	lappend pst [$pp.output.editqik	 cget -state]
	lappend pst [$papag.patches.batch.2.b1 cget -state]
	lappend pst [$papag.patches.batch.2.b1 cget -text]
	lappend pst [$papag.patches.batch.2.b1 cget -bd]
	lappend pst [$papag.patches.batch.2.b2 cget -state]
	lappend pst [$papag.patches.batch.2.b2 cget -text]
	lappend pst [$papag.patches.batch.2.b2 cget -bd]

	$papag.help.ksh		config -state $d
	catch {$papag.help.star		config -state $d}
	$papag.help.quit	config -state $d
 	$pp.zzz.newp	config -state $d
 	$pp.zzz.newf	config -state $d
 	$pp.zzz.mabo	config -state $d
 	$pp.zzz.calc	config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 	$pp.zzz.ref		config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 	$pp.zzz.nns		config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 	$pp.zzz.aaa		config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 	$pp.zzz.tedit	config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 	$pp.buttons.reset	config -state $d
 	$pp.buttons.geti	config -state $d
 	$pp.buttons.repen	config -state $d
 	$pp.buttons.dflt	config -state $d
 	$pp.buttons.orig	config -state $d
 	$pp.buttons.info	config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 	$pp.output.run		config -state $d
	$pp.output.play 	config -state $d
	$pp.output.playsrc	config -state $d
	$pp.output.editsrc	config -state $d
	$pp.output.editqik	config -state $d
	$pp.output.propsrc	config -state $d
	$pp.output.propmax	config -state $d
	$pp.output.view		config -state $d
	$pp.output.read 	config -state $d
	$pp.output.keep 	config -state $d
	$pp.output.props	config -state $d
	$pp.output.mxsmp	config -state $d
	if {$pmcnt > 0} {
	 	$papag.patches.get.load			config -state $d
		$papag.patches.get.delete		config -state $d
		$papag.patches.get2.subp		config -state $d
		$papag.patches.get.store		config -state $d
	}	
	$papag.patches.batch.1.b1		config -state $d
	$papag.patches.batch.1.b2		config -state $d
	$papag.patches.batch.2.b1		config -state $d
	$papag.patches.batch.2.b2		config -state $d
	if {[info exists extrahelp(miditotransposparam)]} {
		DisableMidiTransposButton $extrahelp(miditotransposparam)
	}
	set ppg_actv 0
	PutHelpInPassiveMode $w
	$papag.help.con config -command "ReactivatePpg $w"
}	

proc ReactivatePpg {w} {
	global ppg_actv pst papag extrahelp
	global ppg_hlp_actv pmcnt
	set pp $papag.parameters
	set indx 0

	set n "normal"

	foreach st $pst {
		switch -exact -- $indx {
			0	{$pp.output.editsrc  config -state $st}
 			1	{$pp.output.run   config -state $st}
			2	{$pp.output.play  config -state $st}
			3	{$pp.output.view  config -state $st}
			4	{$pp.output.read  config -state $st}
			5	{$pp.output.keep  config -state $st}
			6	{$pp.output.props config -state $st}
			7	{$pp.output.mxsmp config -state $st}
			8	{$pp.buttons.orig config -state $st}
			9	{$pp.zzz.mabo     config -state $st}
			10	{$pp.zzz.calc     config -state $st}
			11	{$pp.zzz.ref	  config -state $st}
			12	{$pp.zzz.nns	  config -state $st}
			13	{$pp.zzz.aaa	  config -state $st}
			14	{$pp.zzz.tedit	  config -state $st}
			15	{$pp.output.editqik  config -state $st}
			16	{$papag.patches.batch.2.b1 config -state $st}
			17	{$papag.patches.batch.2.b1 config -text $st}
			18	{$papag.patches.batch.2.b1 config -bd $st}
			19	{$papag.patches.batch.2.b2 config -state $st}
			20	{$papag.patches.batch.2.b2 config -text $st}
			21	{$papag.patches.batch.2.b2 config -bd $st}
		}
		incr indx
	}

	$pp.output.playsrc	config -state $n
	$pp.output.propsrc	config -state $n
	$pp.output.propmax	config -state $n
 	$pp.buttons.info 	config -state $n
	$papag.help.ksh		config -state $n
	catch {$papag.help.star		config -state $n}
	$papag.help.quit	config -state $n
 	$pp.zzz.newp		config -state $n
	$pp.zzz.newf		config -state $n
 	$pp.buttons.reset	config -state $n
 	$pp.buttons.geti	config -state $n
 	$pp.buttons.repen	config -state $n
 	$pp.buttons.dflt	config -state $n
	if {$pmcnt > 0} {
	 	$papag.patches.get.load		config -state $n
		$papag.patches.get.delete	config -state $n
		$papag.patches.get2.subp	config -state $n
		$papag.patches.get.store	config -state $n
	}
	$papag.patches.batch.1.b1	config -state $n
	$papag.patches.batch.1.b2	config -state $n
	$papag.patches.batch.2.b1	config -state $n
	$papag.patches.batch.2.b2	config -state $n
	if {[info exists extrahelp(miditotransposparam)]} {
		EnableMidiTransposButton $extrahelp(miditotransposparam)
	}
	set ppg_actv 1
	if {$ppg_hlp_actv} {
		PutHelpInActiveMode $w
	}
	$papag.help.con config -command "DisablePpg $w"
}	

proc ActivatePpgH {} {
	global pmcnt pst ins papag
	set pp $papag.parameters

	bind $papag.help.ksh	<ButtonRelease-1> {PpgH Shortcuts}
	catch {bind $papag.help.star	<ButtonRelease-1> "PpgH WhatVal"}
	bind $papag.help.quit	<ButtonRelease-1> {PpgH quit}
	bind $pp.par			<ButtonRelease-1> {PpgH prmgrd}
 	bind $pp.zzz.newp		<ButtonRelease-1> {PpgH NewProcess}
 	bind $pp.zzz.newf		<ButtonRelease-1> {PpgH NewFiles}
	bind $pp.zzz.mabo		<ButtonRelease-1> {PpgH mabo}
	bind $pp.zzz.calc		<ButtonRelease-1> {PpgH Calculator}
	bind $pp.zzz.ref		<ButtonRelease-1> {PpgH Ref}
	bind $pp.zzz.nns		<ButtonRelease-1> {PpgH Notepad}
	bind $pp.zzz.aaa		<ButtonRelease-1> {PpgH Tone}
 	bind $pp.zzz.tedit		<ButtonRelease-1> {PpgH TabEditor}
	bind $pp.titles.params	<ButtonRelease-1> {PpgH ThisParams}
	bind $pp.titles.prgname	<ButtonRelease-1> {PpgH ThisProcess}
 	bind $pp.buttons.reset	<ButtonRelease-1> {PpgH ResetValues}
 	bind $pp.buttons.geti	<ButtonRelease-1> {PpgH GetTextfiles}
 	bind $pp.buttons.repen	<ButtonRelease-1> {PpgH ResetPenult}
 	bind $pp.buttons.dflt	<ButtonRelease-1> {PpgH GetDefaults}
 	bind $pp.buttons.orig	<ButtonRelease-1> {PpgH Orig}
 	bind $pp.output.run 	<ButtonRelease-1> {PpgH RunProgram}
 	bind $pp.buttons.info	<ButtonRelease-1> {PpgH Info}
	bind $pp.output.play 	<ButtonRelease-1> {PpgH Play}
	bind $pp.output.playsrc	<ButtonRelease-1> {PpgH PlayInput}
	if {[lindex $pst 0] == "normal"} {
		bind $pp.output.editsrc	<ButtonRelease-1> {PpgH EditInput}
	}
	if {[lindex $pst 14] == "normal"} {
		bind $pp.output.editqik	<ButtonRelease-1> {PpgH QikEditInput}
	}
	bind $pp.output.propsrc	<ButtonRelease-1> {PpgH PropInput}
	bind $pp.output.propmax	<ButtonRelease-1> {PpgH InMaxSamp}
	bind $pp.output.view 	<ButtonRelease-1> {PpgH View}
	bind $pp.output.read 	<ButtonRelease-1> {PpgH ReadFile}
	bind $pp.output.keep 	<ButtonRelease-1> {PpgH KeepOutput}
	bind $pp.output.oput 	<ButtonRelease-1> {PpgH OutputInfo}
	bind $pp.output.props	<ButtonRelease-1> {PpgH Properties}
	bind $pp.output.mxsmp	<ButtonRelease-1> {PpgH MaxSamp}

	if {$pmcnt > 0} {
		bind $pp.prd.res 			<ButtonRelease-1> {PpgH RestoreVal}
		bind $pp.prd.hms 			<ButtonRelease-1> {PpgH ConvertHms}
		bind $pp.prd.pen 			<ButtonRelease-1> {PpgH PenultVal}
		bind $pp.prd.def 			<ButtonRelease-1> {PpgH DefaultVal}
		if {$ins(run)} {
			bind $pp.prd.ori 		<ButtonRelease-1> {PpgH OrigDefaultVal}
		}
		bind $papag.patches.titles.patches		<ButtonRelease-1> {PpgH patchlist}
		bind $papag.patches.titles2.batch		<ButtonRelease-1> {PpgH batches}
		bind $papag.patches.current.l			<ButtonRelease-1> {PpgH Curpatch}
		bind $papag.patches.plist.patchlist 	<ButtonRelease-1> {PpgH patchlist}
	 	bind $papag.patches.get.load   			<ButtonRelease-1> {PpgH LoadPatch}
		bind $papag.patches.get.delete 			<ButtonRelease-1> {PpgH DeletePatch}
		bind $papag.patches.get2.subp 			<ButtonRelease-1> {PpgH SubPatch}
		bind $papag.patches.get.store  			<ButtonRelease-1> {PpgH StorePatch}
		bind $papag.patches.name.lab			<ButtonRelease-1> {PpgH patchname}
		bind $papag.patches.name.e 				<ButtonRelease-1> {PpgH patchname}
	 	bind $papag.patches.batch.1.b1 			<ButtonRelease-1> {PpgH PtoB}
	 	bind $papag.patches.batch.1.b2 			<ButtonRelease-1> {PpgH PatoB}
	 	bind $papag.patches.batch.2.b1 			<ButtonRelease-1> {PpgH PtoB2}
	 	bind $papag.patches.batch.2.b2 			<ButtonRelease-1> {PpgH PatoB2}
	}
}	

proc DisablePpgH {w} {
	global ppg_actv ppg_hlp_actv ins pmcnt papag
	set pp $papag.parameters

	bind $papag.help.ksh	<ButtonRelease-1> {}
	catch {bind $papag.help.star	<ButtonRelease-1> {}}
	bind $papag.help.quit	<ButtonRelease-1> {}
	bind $pp.par			<ButtonRelease-1> {}
 	bind $pp.zzz.newp		<ButtonRelease-1> {}
 	bind $pp.zzz.newf		<ButtonRelease-1> {}
 	bind $pp.zzz.mabo		<ButtonRelease-1> {}
 	bind $pp.zzz.calc		<ButtonRelease-1> {}
 	bind $pp.zzz.ref		<ButtonRelease-1> {}
 	bind $pp.zzz.nns		<ButtonRelease-1> {}
 	bind $pp.zzz.aaa		<ButtonRelease-1> {}
 	bind $pp.zzz.tedit		<ButtonRelease-1> {}
	bind $pp.titles.params	<ButtonRelease-1> {}
	bind $pp.titles.prgname	<ButtonRelease-1> {}
 	bind $pp.buttons.reset	<ButtonRelease-1> {}
 	bind $pp.buttons.geti	<ButtonRelease-1> {}
 	bind $pp.buttons.repen	<ButtonRelease-1> {}
 	bind $pp.buttons.dflt	<ButtonRelease-1> {}
 	bind $pp.buttons.orig	<ButtonRelease-1> {}
 	bind $pp.output.run 	<ButtonRelease-1> {}
 	bind $pp.buttons.info	<ButtonRelease-1> {}
	bind $pp.output.play 	<ButtonRelease-1> {}
	bind $pp.output.playsrc	<ButtonRelease-1> {}
	bind $pp.output.editsrc	<ButtonRelease-1> {}
	bind $pp.output.editqik	<ButtonRelease-1> {}
	bind $pp.output.propsrc	<ButtonRelease-1> {}
	bind $pp.output.propmax	<ButtonRelease-1> {}
	bind $pp.output.view 	<ButtonRelease-1> {}
	bind $pp.output.read 	<ButtonRelease-1> {}
	bind $pp.output.keep 	<ButtonRelease-1> {}
	bind $pp.output.oput 	<ButtonRelease-1> {}
	bind $pp.output.props	<ButtonRelease-1> {}
	bind $pp.output.mxsmp	<ButtonRelease-1> {}
	if {$pmcnt > 0} {
		bind $pp.prd.res 	<ButtonRelease-1> {}
		bind $pp.prd.hms 	<ButtonRelease-1> {}
		bind $pp.prd.pen 	<ButtonRelease-1> {}
		bind $pp.prd.def 	<ButtonRelease-1> {}
		if {$ins(run)} {	
			bind $pp.prd.ori <ButtonRelease-1> {}
		}
		bind $papag.patches.titles.patches	<ButtonRelease-1> {}
		bind $papag.patches.titles2.batch	<ButtonRelease-1> {}
		bind $papag.patches.current.l		<ButtonRelease-1> {}
		bind $papag.patches.plist.patchlist <ButtonRelease-1> {}
	 	bind $papag.patches.get.load   		<ButtonRelease-1> {}
		bind $papag.patches.get.delete 		<ButtonRelease-1> {}
		bind $papag.patches.get2.subp 		<ButtonRelease-1> {}
		bind $papag.patches.get.store  		<ButtonRelease-1> {}
		bind $papag.patches.name.lab	 	<ButtonRelease-1> {}
		bind $papag.patches.name.e 			<ButtonRelease-1> {}
	 	bind $papag.patches.batch.1.b1 		<ButtonRelease-1> {}
	 	bind $papag.patches.batch.1.b2 		<ButtonRelease-1> {}
	 	bind $papag.patches.batch.2.b1 		<ButtonRelease-1> {}
	 	bind $papag.patches.batch.2.b2 		<ButtonRelease-1> {}
	}
	set ppg_hlp_actv 0
	if {!$ppg_actv} {
		ReactivatePpg $w
	}
	DisableHelp $w
}	

#------ HELP FOR PROCESS-MENUS PAGE

proc DisableProcmenu {w} {
	global procmenu_actv menu_posting_blocked pim evv

	set d "disabled"

	bind $pim <Key-space> {}
	$pim.help.quit			config -state $d
	$pim.last.3  			config -state $d
	$pim.topbtns.info  		config -state $d  -disabledforeground $evv(HELP_DISABLED_FG)
	$pim.topbtns.infom  	config -state $d
	$pim.topbtns.infop  	config -state $d
	$pim.topbtns.find  		config -state $d  -disabledforeground $evv(HELP_DISABLED_FG)
	$pim.topbtns.tips  		config -state $d  -disabledforeground $evv(HELP_DISABLED_FG)
	$pim.topbtns.nbk  		config -state $d  -disabledforeground $evv(HELP_DISABLED_FG)
	$pim.topbtns.clc  		config -state $d  -disabledforeground $evv(HELP_DISABLED_FG)
	$pim.topbtns.ref  		config -state $d  -disabledforeground $evv(HELP_DISABLED_FG)
	$pim.topbtns.mabo  		config -state $d
	$pim.topbtns.newf  		config -state $d
	$pim.topbtns.again 		config -state $d
	$pim.alpha.fav.btns.use	config -state $d
	$pim.alpha.fav.btns.add	config -state $d
	$pim.alpha.fav.btns.all	config -state $d
	$pim.alpha.mac.btns.run config -state $d
	$pim.alpha.mac.btns.see config -state $d
	$pim.alpha.mac.btns.del config -state $d
	$pim.inpname.previous   config -state $d
	set i 0
	while {$i < $evv(MAXMENUNO)} {
		if {[winfo exists $pim.alpha.ppp.men.mb$i]}  {
			catch {$pim.alpha.ppp.men.mb$i config -state $d}
			catch {$pim.alpha.qqq.mb$i config -state $d}
		}
		incr i
	}
	set menu_posting_blocked 1
	set procmenu_actv 0
	PutHelpInPassiveMode $w
	$pim.help.con config -command "ReactivateProcmenu $w"
}	

proc ReactivateProcmenu {w} {
	global menustate procmenu_actv menu_posting_blocked pim evv
	global procmenu_hlp_actv
	set n "normal"
	bind $pim <Key-space> {GetProcInfo}
	$pim.help.quit     		config -state $n
	$pim.last.3	  		config -state $n
	$pim.topbtns.info  		config -state $n
	$pim.topbtns.infom  	config -state $n
	$pim.topbtns.infop  	config -state $n
	$pim.topbtns.find  		config -state $n
	$pim.topbtns.tips  		config -state $n
	$pim.topbtns.nbk  		config -state $n
	$pim.topbtns.clc  		config -state $n
	$pim.topbtns.ref  		config -state $n
	$pim.topbtns.mabo  		config -state $n
	$pim.topbtns.newf  		config -state $n
	$pim.topbtns.again 		config -state $n
	$pim.alpha.fav.btns.use	config -state $n
	$pim.alpha.fav.btns.add	config -state $n
	$pim.alpha.fav.btns.all	config -state $n
	$pim.alpha.mac.btns.run config -state $n
	$pim.alpha.mac.btns.see config -state $n
	$pim.alpha.mac.btns.del config -state $n
	$pim.inpname.previous   config -state $n
	set i 0
	while {$i < $evv(MAXMENUNO)} {
		if {[winfo exists $pim.alpha.ppp.men.mb$i]}  {
			catch {$pim.alpha.ppp.men.mb$i config -state $menustate($i)}
			catch {$pim.alpha.qqq.mb$i config -state $n}
		}
		incr i
	}
	unset menu_posting_blocked
	set procmenu_actv 1
	if {$procmenu_hlp_actv} {
		PutHelpInActiveMode $w
	}
	$pim.help.con config -command "DisableProcmenu $w"
}	

proc ActivatePrcH {} {
	global inslisting chosen_men menustate favors pim evv

	bind $pim <Key-space>	{}
	bind $pim.help.quit     		<ButtonRelease-1> {PrcH quit}
	bind $pim.topbtns.info  		<ButtonRelease-1> {PrcH info}
	bind $pim.topbtns.infom  		<ButtonRelease-1> {PrcH infom}
	bind $pim.topbtns.infop  		<ButtonRelease-1> {PrcH infop}
	bind $pim.topbtns.find  		<ButtonRelease-1> {PrcH find}
	bind $pim.topbtns.tips 			<ButtonRelease-1> {PrcH tips}
	bind $pim.topbtns.nbk 			<ButtonRelease-1> {PrcH nbk}
	bind $pim.topbtns.clc 			<ButtonRelease-1> {PrcH clc}
	bind $pim.topbtns.ref 			<ButtonRelease-1> {PrcH ref}
	bind $pim.topbtns.mabo  		<ButtonRelease-1> {PrcH mabo}
	bind $pim.topbtns.newf  		<ButtonRelease-1> {PrcH newfiles}
	bind $pim.topbtns.again 		<ButtonRelease-1> {PrcH again}
	bind $pim.alpha.fav.btns.use	<ButtonRelease-1> {PrcH favuse}
	bind $pim.alpha.fav.btns.add	<ButtonRelease-1> {PrcH favadd}
	bind $pim.alpha.fav.btns.all	<ButtonRelease-1> {PrcH favall}
	bind $pim.last.1				<ButtonRelease-1> {PrcH last}
	bind $pim.last.2				<ButtonRelease-1> {PrcH last}
	bind $pim.last.3				<ButtonRelease-1> {PrcH seechoice}
	bind $pim.alpha.qqq				<ButtonRelease-1> {PrcH current}
	bind $pim.alpha.qqq.title		<ButtonRelease-1> {PrcH current}
	bind $pim.alpha.ppp.men			<ButtonRelease-1> {PrcH master}
	bind $pim.alpha.ppp.men.title	<ButtonRelease-1> {PrcH master}
	bind $pim.alpha.fav				<ButtonRelease-1> {PrcH favlist}
	bind $favors <ButtonRelease-1> {PrcH favlist}
	bind $pim.alpha.fav.title		<ButtonRelease-1> {PrcH favlist}
	
	bind $pim.alpha.mac.lab 	   	<ButtonRelease-1> {PrcH maclist}
	bind $pim.alpha.mac.btns.run	<ButtonRelease-1> {PrcH macrun}
	bind $pim.alpha.mac.btns.del	<ButtonRelease-1> {PrcH macdel}
	bind $pim.alpha.mac.btns.see	<ButtonRelease-1> {PrcH macsee}
	bind $pim.inpname.previous		<ButtonRelease-1> {PrcH previous}
	bind $inslisting 				<ButtonRelease-1> {PrcH maclist}

	set i 0
	while {$i < $evv(MAXMENUNO)} {
		if {[winfo exists $pim.alpha.ppp.men.mb$i]}  {
			catch {bind $pim.alpha.ppp.men.mb$i <ButtonRelease-1> "PrcH masterbutton $menustate($i)"}
			catch {bind $pim.alpha.qqq.mb$i <ButtonRelease-1> "PrcH current"}
		}
		incr i
	}
	catch {bind $chosen_men <ButtonRelease-1> {PrcH chosenmenu}}
}	

proc PrcH {subject args} {
	global ins pim retrieve_info_state_saved
	set f $pim.help.help
	if {![info exists retrieve_info_state_saved]} {
		switch -- $subject {
			quit {
				$f config -text "Quit this session. (Workspace state will be backed up, unless you specify not)"
			}
			info {
				$f config -text "Get further information: drop down message should appear: IF NOT, press 'Info' again"
			}
			infom {
				$f config -text "Obtain information about the processes on a menu"
			}
			infop {
				$f config -text "Obtain information about a particular process"
			}
			tips {
				$f config -text "If you have a problem on this page, consult the 'Tips' information."
			}
			nbk {
				$f config -text "Call up a notebook where you can keep notes about what you've done, or plan to do."
			}
			clc {
				$f config -text "Calculator for converting between musical units, doing maths, and storing reference values."
			}
			ref {
				$f config -text "See list of your own Reference Values ; Get or Keep a value, or Edit the list of values."
			}
			find {
				$f config -text "Find a process appropriate to your needs"
			}
			mabo {
				if {$ins(create)} {
					$f config -text "Abandon instrument creation (and all files produced from processes used)"
				} else {
					$f config -text "Return to Workspace, from where you can Create an Instrument"
				}
			}
			newfiles {
				$f config -text "Choose new files to process"
			}
			again {
				$f config -text "Run the previously run process"
			}
			favuse {
				if [string match [$pim.alpha.fav.btns.use cget -text] "Use"] {
					$f config -text "Use the favourite process selected from the list"
				} else {
					$f config -text "Remove the selected process from the favourites list (it remains on the system)"
				}
			}
			favadd {
				if [string match [$pim.alpha.fav.btns.add cget -text] "Add Last Process"] {
					$f config -text "Add last process used (see top of page) to list of your favourite processes"
				}
			}
			favall {
				if [string match [$pim.alpha.fav.btns.all cget -text] "See All"] {
					$f config -text "List ALL your favourite processes (not just those applicable currently)"
				} else {
					$f config -text "List your favourite processes which are applicable to the current file(s)"
				}
			}
			last {
				$f config -text "The previous process you used"
			}
			seechoice {
				$f config -text "See the files you are using"
			}
			current {
				$f config -text "The menu that you are currently using"
			}
			master {
				$f config -text "The master menu of CDP processes"
			}
			favlist {
				$f config -text "A list of your favourite processes"
			}
			macrun {
				if {$ins(create)} {
					$f config -text "Existing Instruments CANNOT be run as part of a NEW instrument."
				} else {
					$f config -text "Run the instrument which you have selected."
				}
			}
			macsee {
				$f config -text "See a display of the instrument you have selected"
			}
			previous {
				$f config -text "See most recent processes used: Can select one of these with mouse"
			}
			macdel {
				$f config -text "Permanently destroy the instrument you have selected"
			}
			maclist {
				$f config -text "A list of your instruments"
			}
			masterbutton {
				switch -- [lindex $args 0] {
					normal {
						$f config -text "A menu of CDP processes (some of) which you can use with the current file(s)"
					}
					disabled {
						$f config -text "A menu of CDP processes which cannot be used with the current file(s)"
					}
					default {
						ErrShow "Unknown option in PrcH for masterbuttons"
					}
				}
			}
			chosenmenu {
				$f config -text "A selected menu of CDP processes"
			}
			default {
				ErrShow "Unknown option in PrcH"
			}
		}
	}
}

proc DisableHelpOnProcmenu {w} {
	global inslisting chosen_men
	global procmenu_hlp_actv procmenu_actv favors pim evv

	bind $pim <Key-space>	{GetProcInfo}
	bind $pim.help.quit     		<ButtonRelease-1> {}
	bind $pim.topbtns.info  		<ButtonRelease-1> {}
	bind $pim.topbtns.infom  		<ButtonRelease-1> {}
	bind $pim.topbtns.infop  		<ButtonRelease-1> {}
	bind $pim.topbtns.find  		<ButtonRelease-1> {}
	bind $pim.topbtns.tips  		<ButtonRelease-1> {}
	bind $pim.topbtns.nbk  			<ButtonRelease-1> {}
	bind $pim.topbtns.clc  			<ButtonRelease-1> {}
	bind $pim.topbtns.ref  			<ButtonRelease-1> {}
	bind $pim.topbtns.mabo  		<ButtonRelease-1> {}
	bind $pim.topbtns.newf  		<ButtonRelease-1> {}
	bind $pim.topbtns.again 		<ButtonRelease-1> {}
	bind $pim.alpha.fav.btns.use	<ButtonRelease-1> {}
	bind $pim.alpha.fav.btns.add	<ButtonRelease-1> {}
	bind $pim.alpha.fav.btns.all	<ButtonRelease-1> {}
	bind $pim.last.1				<ButtonRelease-1> {}
	bind $pim.last.2				<ButtonRelease-1> {}
	bind $pim.last.3				<ButtonRelease-1> {}
	bind $pim.alpha.qqq				<ButtonRelease-1> {}
	bind $pim.alpha.ppp.men			<ButtonRelease-1> {}
	bind $pim.alpha.ppp.men.title	<ButtonRelease-1> {}
	bind $pim.alpha.fav				<ButtonRelease-1> {}
	bind $pim.alpha.fav.title		<ButtonRelease-1> {}
	bind $favors <ButtonRelease-1> {}
	
	bind $pim.alpha.mac.lab			<ButtonRelease-1> {}
	bind $pim.alpha.mac.btns.run 	<ButtonRelease-1> {}
	bind $pim.alpha.mac.btns.see 	<ButtonRelease-1> {}
	bind $pim.alpha.mac.btns.del 	<ButtonRelease-1> {}
	bind $pim.inpname.previous		<ButtonRelease-1> {}
	bind $inslisting				<ButtonRelease-1> {}

	set i 0
	while {$i < $evv(MAXMENUNO)} {
		if {[winfo exists $pim.alpha.ppp.men.mb$i]}  {
			catch {bind $pim.alpha.ppp.men.mb$i <ButtonRelease-1> {}}
			catch {bind $pim.alpha.qqq.mb$i <ButtonRelease-1> {}}
		}
		incr i
	}
	catch {bind $chosen_men <ButtonRelease-1> {}}

	set procmenu_hlp_actv 0
	if {!$procmenu_actv} {
		ReactivateProcmenu $w
	}
	DisableHelp $w
}	

#------ HELP INFORMATION FOR THE GRAPHIC BRKTABLE PAGE

proc DisableBrkedit {w} {
	global brkedit_actv brkedit_hlp_actv bkst bkc bfw evv
	set g $bfw

	set d "disabled"

	catch {unset bkst}
	lappend bkst [$g.btns.name    cget -state]
	lappend bkst [$g.btns.abdn    cget -state]
	lappend bkst [$g.btns.calc    cget -state]
	lappend bkst [$g.btns.ref    cget -state]
	lappend bkst [$g.btns.load    cget -state]
	lappend bkst [$g.btns.save    cget -state]
	lappend bkst [$g.btns.use		cget -state]
	lappend bkst [$g.btns.options cget -state]
	lappend bkst [$g.btns.undo    cget -state]
	lappend bkst [$g.btns.resto   cget -state]
	lappend bkst [$g.btns.mouse   cget -state]
	lappend bkst [$g.btns.ftune   cget -state]

	lappend bkst [$g.l.quantise.ton  cget -state]
	lappend bkst [$g.l.quantise.tof  cget -state]
	lappend bkst [$g.l.quantise.te   cget -state]
	lappend bkst [$g.l.quantise.von  cget -state]
	lappend bkst [$g.l.quantise.vof  cget -state]
	lappend bkst [$g.l.quantise.ve   cget -state]

 	$g.btns.name	config -state $d
 	$g.btns.abdn 	config -state $d
 	$g.btns.calc 	config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 	$g.btns.ref 	config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 	$g.btns.load 	config -state $d
 	$g.btns.save 	config -state $d
 	$g.btns.use  	config -state $d
 	$g.btns.options config -state $d
 	$g.btns.undo 	config -state $d
 	$g.btns.resto	config -state $d
 	$g.btns.mouse	config -state $d
 	$g.btns.ftune	config -state $d

	$g.l.quantise.ton  config -state $d
	$g.l.quantise.tof  config -state $d
	$g.l.quantise.te   config -state $d
	$g.l.quantise.von  config -state $d
	$g.l.quantise.vof  config -state $d
	$g.l.quantise.ve   config -state $d

 	$g.help.quit	config -state $d

	bind $bkc(can) <ButtonRelease-1> 				{}
	bind $bkc(can) <Control-ButtonRelease-1>		{}
	bind $bkc(can) <Shift-ButtonPress-1> 			{}
	bind $bkc(can) <Shift-B1-Motion> 				{}
	bind $bkc(can) <Shift-ButtonRelease-1>			{}
	bind $bkc(can) <Control-Shift-ButtonRelease-1> 	{}
	bind $bkc(can) <Control-Command-ButtonRelease-1>	{}

	if {$brkedit_hlp_actv} {
		bind $bkc(can) <ButtonRelease-1> {BrkH Canvas}
	}

	set brkedit_actv 0
	PutHelpInPassiveMode $w
	$g.help.con config -command "ReactivateBrkedit $w"
}	

proc ReactivateBrkedit {w} {
	global bkst brkedit_actv bkc sfbbb brkedit_hlp_actv bfw
	set g $bfw
	set indx 0
	foreach st $bkst {
		switch -exact -- $indx {
 			0	{$g.btns.name 	config -state $st}
 			1	{$g.btns.abdn 	config -state $st}
 			2	{$g.btns.calc 	config -state $st}
 			3	{$g.btns.ref 	config -state $st}
 			4	{$g.btns.load 	config -state $st}
 			5	{$g.btns.save 	config -state $st}
 			6	{$g.btns.use  	config -state $st}
 			7	{$g.btns.options 	config -state $st}
 			8	{$g.btns.undo 	config -state $st}
 			9	{$g.btns.resto	config -state $st}
 			10	{$g.btns.mouse	config -state $st}
 			11	{$g.btns.ftune	config -state $st}
 			12	{$g.l.quantise.ton	config -state $st}
 			13	{$g.l.quantise.tof	config -state $st}
 			14	{$g.l.quantise.te	config -state $st}
 			15	{$g.l.quantise.von	config -state $st}
 			16	{$g.l.quantise.vof	config -state $st}
 			17	{$g.l.quantise.ve	config -state $st}
		}
		incr indx
	}

 	$g.help.quit config -state normal

	if {$brkedit_hlp_actv} {
		bind $bkc(can) <ButtonRelease-1> 			{}
		bind $bkc(can) <ButtonRelease-1> 			{CreatePoint %W %x %y ; BrkH Canvas}
	} else {
		bind $bkc(can) <ButtonRelease-1> 			{CreatePoint %W %x %y}
	}
	bind $bkc(can) <Control-ButtonRelease-1>		{DeletePoint %W %x %y}
	bind $bkc(can) <Shift-ButtonPress-1> 			{MarkPoint %W %x %y}
	bind $bkc(can) <Shift-B1-Motion> 				{DragPoint %W %x %y}
	bind $bkc(can) <Shift-ButtonRelease-1>			{RelocatePoint %W}
	bind $bkc(can) <Control-Shift-ButtonRelease-1> 	{DeleteFromPoint %W %x %y $sfbbb -1}
	bind $bkc(can) <Control-Command-ButtonRelease-1>	{CutTable %W %x %y $sfbbb}

	set brkedit_actv 1
	if {$brkedit_hlp_actv} {
		PutHelpInActiveMode $w
	}
	$g.help.con config -command "DisableBrkedit $w"
}	

proc ActivateBrkeditHelp {} {
	global get_brkfile brkval_list bkc bfw
	set g $bfw
	bind $g.help.quit 	<ButtonRelease-1> {BrkH Quit}
	bind $g.btns.abdn 	<ButtonRelease-1> {BrkH Abandon}
	bind $g.btns.calc 	<ButtonRelease-1> {BrkH Calculator}
	bind $g.btns.ref 	<ButtonRelease-1> {BrkH Ref}
	bind $g.btns.load 	<ButtonRelease-1> {BrkH NewFile}
	bind $g.btns.save 	<ButtonRelease-1> {BrkH Save}
	bind $g.btns.use  	<ButtonRelease-1> {BrkH Use}
	bind $g.btns.lab  	<ButtonRelease-1> {BrkH Filename}
	bind $g.btns.name  	<ButtonRelease-1> {BrkH Filename}
	bind $g.btns.mouse 	<ButtonRelease-1> {BrkH Mouse}
	bind $g.btns.ftune 	<ButtonRelease-1> {BrkH FineTune}
	bind $g.btns.options	<ButtonRelease-1> {BrkH Options}
	bind $g.btns.undo		<ButtonRelease-1> {BrkH Undo}
	bind $g.btns.resto	<ButtonRelease-1> {BrkH Restore}
	bind $g.l.z.brktime	<ButtonRelease-1> {BrkH TListing}
	bind $g.l.z.brkval	<ButtonRelease-1> {BrkH VListing}
	bind $brkval_list	 			<ButtonRelease-1> {BrkH Listing}

	bind $g.l.quantise.ton  <ButtonRelease-1> {BrkH qtime_on}
	bind $g.l.quantise.tof  <ButtonRelease-1> {BrkH qtime_off}
	bind $g.l.quantise.te   <ButtonRelease-1> {BrkH qtime_val}
	bind $g.l.quantise.von  <ButtonRelease-1> {BrkH qval_on}
	bind $g.l.quantise.vof  <ButtonRelease-1> {BrkH qval_off}
	bind $g.l.quantise.ve   <ButtonRelease-1> {BrkH qval_val}
	bind $g.l.quantise.lab  <ButtonRelease-1> {BrkH quantise}

	bind $bkc(can) 		<ButtonRelease-1> {BrkH Canvas}
}	

proc BrkH {subject args} {
	global brkedit_naming is_file_edit bfw brk
	set f $bfw.help.help

	if {$is_file_edit} {
		switch $subject {
			Quit 	   {$f config -text "Quit this session. (Workspace state will be backed up, unless you specify not)"}
			Abandon    {$f config -text "Stop editing breakpoint files, and leave the graphic breakpoint editor."}
			Calculator {$f config -text "Calculator for converting between musical units, doing maths, and storing reference values."}
			Ref 		{$f config -text "See list of your own Reference Values ; Get or Keep a value, or Edit the list of values."}
			NewFile    {$f config -text "Get a new breakpoint file to edit."}
			Save 	   {$f config -text "Save the edited file to the workspace."}
			Use {
				if {!$brk(from_wkspace)} {
					$f config -text "Use the displayed file as a parameter, and, if edited, save it to the workspace."
				}
			}
			Filename {
				if {$brkedit_naming} {
					$f config -text "Enter a new name for the file you have edited."
				} else {
					$f config -text "Name of the file you are editing."
				}
			}
			FineTune {$f config -text "Allow table values to be more precisely edited (as text) when table is saved."}
			Mouse 	 {$f config -text "Mouse operations which can be used to edit the table."}
			Options  {$f config -text "Globally transform (or restore) the table, using these options."}
			Undo 	 {$f config -text "Undo previous change to the displayed table. (Only the previous step)."}
			Restore  {$f config -text "Restore the unedited table."}
			Canvas 	 {$f config -text "Display of brkpoint table, which you can edit with Mouse or Global options (see menus)."}
			TListing {$f config -text "List of time coordinates in breakpoint table."}
			VListing {$f config -text "List of values associated with each time, in breakpoint table."}
			Listing  {$f config -text "List of time-value pairs associated with each point in breakpoint table."}
			qtime_on  {$f config -text "Turn on OR CHANGE quantisation of time (seconds)."}
			qtime_off {$f config -text "Turn Off time quantisation."}
			qtime_val {$f config -text "Time quantisation (seconds)."}
			qval_on   {$f config -text "Turn on OR CHANGE quantisation of values."}
			qval_off  {$f config -text "Turn Off value quantisation."}
			qval_val  {$f config -text "Value quantisation."}
			quantise  {$f config -text "You can quantise the time or the table values with these buttons."}
			default {
				ErrShow "Unknown option in BrkH"
			}
		}
	} else {
		switch $subject {
			Quit 	 {$f config -text "Quit this session. (Workspace state will be backed up, unless you specify not)"}
			Abandon  {$f config -text "Stop creating breakpoint files, and leave the Graphic Editor page."}
			Calculator {$f config -text "Calculator for converting between musical units, doing maths, and storing reference values."}
			Ref 		{$f config -text "See list of your own Reference Values ; Get or Keep a value, or Edit the list of values."}
			NewFile  {}
			Save 	 {$f config -text "Save the newly created file to the workspace."}
			Use 	 {
				if {!$brk(from_wkspace)} {
					$f config -text "Use the displayed file as a parameter, and save it to the workspace."
				}
			}
			Filename {
				if {$brkedit_naming} {
					$f config -text "Enter a new name for the file you have created."
				}
			}
			FineTune {$f config -text "Allow table values to be more precisely edited (as text) when table is saved."}
			Mouse 	 {$f config -text "Mouse operations which can be used to edit the table."}
			Options  {$f config -text "Globally transform (or restore) the table, using these options."}
			Undo 	 {$f config -text "Undo previous change to the displayed table. (Only the previous step)."}
			Restore  {$f config -text "Restore the initial state of the table."}
			Canvas 	 {$f config -text "Display of brkpoint table, which you can edit with Mouse or Global options (see menus)."}
			TListing {$f config -text "List of time coordinates in breakpoint table."}
			VListing {$f config -text "List of values associated with each time, in breakpoint table."}
			Listing  {$f config -text "List of time-value pairs associated with each point in breakpoint table."}
			qtime_on  {$f config -text "Turn on OR CHANGE quantisation of time (seconds)."}
			qtime_off {$f config -text "Turn Off time quantisation."}
			qtime_val {$f config -text "Time quantisation (seconds)."}
			qval_on   {$f config -text "Turn on OR CHANGE quantisation of values."}
			qval_off  {$f config -text "Turn Off value quantisation."}
			qval_val  {$f config -text "Value quantisation."}
			quantise  {$f config -text "You can quantise the time or the table values with these buttons."}
			default {
				ErrShow "Unknown option in BrkH"
			}
		}
	}
}

proc DisableBrkeditHelp {w} {
	global brkedit_actv brkedit_hlp_actv brkval_list bkc bfw
	set g $bfw
	bind $g.help.quit 	<ButtonRelease-1> {}

	bind $g.btns.abdn 	<ButtonRelease-1> {}
	bind $g.btns.calc 	<ButtonRelease-1> {}
	bind $g.btns.ref 	<ButtonRelease-1> {}
	bind $g.btns.load 	<ButtonRelease-1> {}
	bind $g.btns.save 	<ButtonRelease-1> {}
	bind $g.btns.use  	<ButtonRelease-1> {}
	bind $g.btns.lab  	<ButtonRelease-1> {}
	bind $g.btns.name  	<ButtonRelease-1> {}
	bind $g.btns.mouse	<ButtonRelease-1> {}
	bind $g.btns.ftune	<ButtonRelease-1> {}
	bind $g.btns.options	<ButtonRelease-1> {}
	bind $g.btns.undo		<ButtonRelease-1> {}
	bind $g.btns.resto	<ButtonRelease-1> {}
	bind $g.l.z.brktime	<ButtonRelease-1> {}
	bind $g.l.z.brkval	<ButtonRelease-1> {}
	bind $brkval_list	 			<ButtonRelease-1> {}

	bind $g.l.quantise.ton  <ButtonRelease-1> {}
	bind $g.l.quantise.tof  <ButtonRelease-1> {}
	bind $g.l.quantise.te   <ButtonRelease-1> {}
	bind $g.l.quantise.von  <ButtonRelease-1> {}
	bind $g.l.quantise.vof  <ButtonRelease-1> {}
	bind $g.l.quantise.ve   <ButtonRelease-1> {}
	bind $g.l.quantise.lab  <ButtonRelease-1> {}

	bind $bkc(can) <ButtonRelease-1> {}

	set brkedit_hlp_actv 0

	if {$brkedit_actv} {
		bind $bkc(can) <ButtonRelease-1> {CreatePoint %W %x %y}
	} else {
		ReactivateBrkedit $w
	}
	DisableHelp $w
}	

#------ HELP INFO FOR INSTRUMENT CREATION PAGE

proc DisableInspage {w} {
	global inspage_actv tree ins ins_concluding ins_file_lst azaz icp evv
	set t $icp.tree
	set f $icp.files
	set d "disabled"

	#	DISABLE INSPAGE BUTTONS

	if {$ins_concluding} {
		$t.btns.play	config -state $d
		$t.btns.view	config -state $d
		$t.btns.read	config -state $d 
		$t.btns.keep	config -state $d
		$t.btns.props  	config -state $d
		$t.btns.mxsmp  	config -state $d
		$t.btns.keepall	config -state $d
	} else {
		$t.btns.continue	config -state $d
		$f.btns.1.newfile	config -state $d
		$f.btns.1.clear		config -state $d
		$f.btns.2.props		config -state $d
		$f.btns.2.pl		config -state $d
		$f.btns.4.ro		config -state $d
		$t.btns.abort		config -state $d
	}
	$t.btns.conclude	config -state $d

	if {$ins(create)} {
		set i 0
		while {$i < $tree(files_icon_cnt)} {
			$t.tree.c.canvas.ff$i.button config -state $d
			incr i
		}
	}

	$icp.help.quit	config -state $d
	$icp.help.tips	config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
 
	set inspage_actv 0

	if {!$ins_concluding} {
		bind $ins_file_lst <ButtonRelease-1> {}	
		bind $ins_file_lst <ButtonRelease-1> {InsH filelist}	
	} else {
		bind $f.nameslist.lbox.list <ButtonRelease-1> {}
		bind $f.nameslist.lboxb.list <ButtonRelease-1> {}
		$f.nameslist.bbbb.bb1 config -state $d
		$f.nameslist.bbbb.bb2 config -state $d
		$f.nameslist.bbbb.bb3 config -state $d
		$f.nameslist.bbbb.bb4 config -state $d
	}
	PutHelpInPassiveMode $w
	$icp.help.con config -command "ReactivateInspage $w"
}	

proc ReactivateInspage {w} {
	global inspage_actv inspage_hlp_actv tree ins icp
	global ins_concluding ins_file_lst azaz
	set t $icp.tree
	set f $icp.files
	set n "normal"
	if {$ins_concluding} {
		$t.btns.play	config -state $n
		$t.btns.view	config -state $n
		$t.btns.read	config -state $n 
		$t.btns.keep	config -state $n
		$t.btns.props  	config -state $n
		$t.btns.mxsmp  	config -state $n
		$t.btns.keepall config -state $n
	} else {
		$t.btns.continue 	config -state $n
		$f.btns.1.newfile	config -state $n
		$f.btns.1.clear   	config -state $n
		$f.btns.2.props 	config -state $n
		$f.btns.2.pl	 	config -state $n
		$f.btns.4.ro	 	config -state $n
		$t.btns.abort    	config -state $n
	}
	$t.btns.conclude 	config -state $n

	if {$ins(create)} {
		set i 0
		while {$i < $tree(files_icon_cnt)} {
			$t.tree.c.canvas.ff$i.button config -state $n
			incr i
		}
	}

	$icp.help.quit	config -state $n
	$icp.help.tips	config -state $n

	set inspage_actv 1
	if {$inspage_hlp_actv} {
		if {!$ins_concluding} {
			bind $ins_file_lst <ButtonRelease-1> {}	
			$ins_file_lst selection clear 0 end
			bind $ins_file_lst <ButtonRelease-1> {RemovefromInsInfileListing ; InsH filelist}	
		} else {
			set zqz $f.nameslist.lbox.list
			set zqzb $f.nameslist.lboxb.list
			bind $zqz <ButtonRelease-1> {}
			bind $zqz <ButtonRelease-1> "NameListChoose $zqz $azaz ; InsH RecentNames"
			bind $zqzb <ButtonRelease-1> {}
			bind $zqzb <ButtonRelease-1> "NameListChoose $zqzb $azaz ; InsH SourceNames"
			$f.nameslist.bbbb.bb1 config -state $n
			$f.nameslist.bbbb.bb3 config -state $n
			$f.nameslist.bbbb.bb3 config -state $n
			$f.nameslist.bbbb.bb4 config -state $n
		}
		PutHelpInActiveMode $w
	}
	$icp.help.con config -command "DisableInspage $w"
}	

proc ActivateInspageHelp {} {
	global ins ins_file_lst tree ins_concluding icp
	set t $icp.tree
	set f $icp.files
	if {$ins_concluding} {
		bind $t.btns.conclude <ButtonRelease-1> {}
		bind $t.btns.conclude <ButtonRelease-1> {InsH conclude_conclude}
		bind $t.btns.play	 <ButtonRelease-1> {InsH play}
		bind $t.btns.view	 <ButtonRelease-1> {InsH view}
		bind $t.btns.read	 <ButtonRelease-1> {InsH read} 
		bind $t.btns.keep	 <ButtonRelease-1> {InsH keepout}
		bind $t.btns.props	 <ButtonRelease-1> {InsH outprops}
		bind $t.btns.mxsmp	 <ButtonRelease-1> {InsH outmaxi}
		bind $t.btns.keepall  <ButtonRelease-1> {InsH keepall}
		bind $f.btns.1.lab   <ButtonRelease-1> {InsH conclude_filelist}
		bind $f.filelist	 <ButtonRelease-1> {}
		bind $f.filelist	 <ButtonRelease-1> {InsH conclude_filelist}
		bind $f.nameslist.bbb   	<ButtonRelease-1> {InsH standard}
		bind $f.nameslist.bbbb.bb1  <ButtonRelease-1> {InsH standard}
		bind $f.nameslist.bbbb.bb2  <ButtonRelease-1> {InsH standard}
		bind $f.nameslist.bbbb.bb3  <ButtonRelease-1> {InsH standard}
		bind $f.nameslist.bbbb.bb4  <ButtonRelease-1> {InsH standard}
		bind $f.nameslist.laba   	<ButtonRelease-1> {InsH RecentNames}
		bind $f.nameslist.labb   	<ButtonRelease-1> {InsH SourceNames}
		bind $f.nameslist.lbox.list	<ButtonRelease-1> {}
		bind $f.nameslist.lbox.list	<ButtonRelease-1> {InsH RecentNames}
		bind $f.nameslist.lboxb.list <ButtonRelease-1> {}
		bind $f.nameslist.lboxb.list <ButtonRelease-1> {InsH SourceNames}

		bind $ins_file_lst 		<ButtonRelease-1> {}
		bind $ins_file_lst 		<ButtonRelease-1> {InsH conclude_filelist}
		bind $f.btns.2.l   	 	<ButtonRelease-1> {InsH name}
		bind $f.btns.2.e   	 	<ButtonRelease-1> {InsH name}
	} else {
		bind $t.btns.continue 	<ButtonRelease-1> {InsH continue}
		bind $t.btns.conclude 	<ButtonRelease-1> {InsH conclude}
		bind $t.btns.abort    	<ButtonRelease-1> {InsH abort}
		bind $f.btns.1.newfile  <ButtonRelease-1> {InsH newfile}
		bind $f.btns.1.clear   	<ButtonRelease-1> {InsH clear}
		bind $f.btns.2.props  	<ButtonRelease-1> {InsH props}
		bind $f.btns.2.pl	  	<ButtonRelease-1> {InsH PlaySrcs}
		bind $f.btns.4.ro	  	<ButtonRelease-1> {InsH reverse}
		if {$ins(create)} {
			set i 0
			while {$i < $tree(files_icon_cnt)} {
				bind $t.tree.c.canvas.ff$i.button <ButtonRelease-1> {InsH treebutton}
				incr i
			}
			set i 0
			while {$i < $tree(process_cnt)} {
				bind $t.tree.c.canvas.pp$i.label <ButtonRelease-1> {InsH treeproc}
				incr i
			}
		}
		bind $f.btns.3.lab  	<ButtonRelease-1> {InsH filelist}
		bind $f.filelist		<ButtonRelease-1> {InsH filelist}
		bind $ins_file_lst 		<ButtonRelease-1> {InsH filelist}
	}
	bind $icp.help.quit    	<ButtonRelease-1> {InsH quit}
	bind $icp.help.tips    	<ButtonRelease-1> {InsH tips}

	bind $t.key.key 	    <ButtonRelease-1> {InsH key}
	bind $t.key.snd      	<ButtonRelease-1> {InsH snd}
	bind $t.key.mono 		<ButtonRelease-1> {InsH mono}
	bind $t.key.anal     	<ButtonRelease-1> {InsH anal}
	bind $t.key.pitch    	<ButtonRelease-1> {InsH pitch}
	bind $t.key.trans    	<ButtonRelease-1> {InsH trans}
	bind $t.key.fmnt     	<ButtonRelease-1> {InsH fmnt}
	bind $t.key.env      	<ButtonRelease-1> {InsH env}
	bind $t.key.txt      	<ButtonRelease-1> {InsH txt}
	bind $t.key.pseud      	<ButtonRelease-1> {InsH pseud}
	if {$ins(run)} {			
		bind $t.key.keep 	<ButtonRelease-1> {InsH keep}
		bind $t.key.del 	<ButtonRelease-1> {InsH del}
	}
}	

proc ReconfigInsHelp {} {
	global inspage_hlp_actv tree icp
	set t $icp.tree
	if {[info exists inspage_hlp_actv] && $inspage_hlp_actv} {
		set i 0
		while {$i < $tree(files_icon_cnt)} {
			bind $icp.tree.tree.c.canvas.ff$i.button <ButtonRelease-1> {InsH treebutton}
			incr i
		}
		set i 0
		while {$i < $tree(process_cnt)} {
			bind $icp.tree.tree.c.canvas.pp$i.label <ButtonRelease-1> {InsH treeproc}
			incr i
		}
	}
}	

proc InsH {subject args} {
	global ins icp
	set f $icp.help.help
	switch $subject {
		quit {
			$f config -text "Quit this session. (Session state will be backed up, unless you specify not)"
		}
		tips {
			$f config -text "If you have a problem here, consult the 'Tips' information."
		}
		continue {
			$f config -text "Continue creating an instrument (by combining processes), using files you have selected"
		}
		conclude {
			$f config -text "Conclude instrument creation, saving selected outfiles, & the instrument itself."
		}
		abort {
			$f config -text "Abandon the instrument you're creating: forget its specification, delete its outfiles"
		}
		newfile {
			$f config -text "Get a new file, to use in the current process of the instrument"
		}
		props {
			$f config -text "Display properties of files selected from you list"
		}
		PlaySrcs {
			$f config -text "Play Chosen sounds, or the sound sources of other types of files, if they (still) exist."
		}
		reverse {
			$f config -text "Reverse the order of the files in the Chosen Files list."
		}
		clear {
			$f config -text "Clear the listing of files to be processed"
		}
		remove {
			$f config -text "Remove selected item(s) from list of files to be used in next process of the instrument"
		}
		treebutton {
			if {$ins(create)} {
				$f config -text "File already used by the instrument, which you may reuse in another process"
			} else {
				$f config -text "File processed by the instrument"
			}
		}
		treeproc {
			$f config -text "Process used by the instrument"
		}
		key {
			$f config -text "Color key indicating the type of any file used in the instrument (not functional on MAC)"
		}
		keep {
			$f config -text "The normal font for writing file names on the instrument tree"
		}
		del {
			$f config -text "this font indicates files which are DELETED after the instrument runs"
		}
		canvas {
			$f config -text "Tree diagram of your instrument"
		}
		filelist {
			$f config -text "List of files to use in the CURRENT process employed in your instrument"
		}
		conclude_conclude {
			$f config -text "Save no further outfiles. Save the instrument itself for future use."
		}
		play {
			$f config -text "Play any soundfiles output by any processes in the instrument."
		}
		view {
			$f config -text "View any viewable files output by any processes in the instrument."
		}
		read {
			$f config -text "Read any readable files output by any processes in the instrument."
		}
		keepout {
			$f config -text "Retain the output file you have selected from the list of instrument outfiles."
		}
		outprops {
			$f config -text "See the properties of the output files."
		}
		outmaxi {
			$f config -text "See the maximum value in the output file(s)."
		}
		keepall {
			$f config -text "Retain all the output files produced by the instrument, giving them a common name."
		}
		conclude_filelist {
			$f config -text "A list of all the files output by all the processes in the instrument."
		}
		RecentNames {
			$f config -text "A list of names you have used recently for naming output files."
		}
		SourceNames {
			$f config -text "A list of the names of source files for this process."
		}
		name {
			$f config -text "New name (or new generic name) for instrument outfile(s) to be retained."
		}
		standard { 
			$f config -text "Standard outputfile names for your output files."
		}
	}
}

proc DisableInspageHelp {w} {
	global inspage_actv inspage_hlp_actv ins ins_file_lst tree azaz icp
	global ins_concluding
	set t $icp.tree
	set f $icp.files
	set n "normal"
	if {$ins_concluding} {
		bind $t.btns.conclude <ButtonRelease-1> {}
		bind $t.btns.play	 <ButtonRelease-1> {}
		bind $t.btns.view	 <ButtonRelease-1> {}
		bind $t.btns.read	 <ButtonRelease-1> {} 
		bind $t.btns.keep	 <ButtonRelease-1> {}
		bind $t.btns.props	 <ButtonRelease-1> {}
		bind $t.btns.mxsmp	 <ButtonRelease-1> {}
		bind $t.btns.keepall  <ButtonRelease-1> {}
		bind $f.btns.1.lab   <ButtonRelease-1> {}
		bind $f.filelist	 <ButtonRelease-1> {}
		bind $f.nameslist.bbb   	<ButtonRelease-1> {}
		$f.nameslist.bbbb.bb1 config -state $n
		$f.nameslist.bbbb.bb2 config -state $n
		$f.nameslist.bbbb.bb3 config -state $n
		$f.nameslist.bbbb.bb4 config -state $n
		bind $f.nameslist.laba   	<ButtonRelease-1> {}
		bind $f.nameslist.labb   	<ButtonRelease-1> {}
		bind $f.nameslist.lbox.list <ButtonRelease-1> {}
		bind $f.nameslist.lbox.list <ButtonRelease-1> {NameListChoose $icp.files.nameslist.lbox.list $azaz}
		bind $f.nameslist.lboxb.list <ButtonRelease-1> {}
		bind $f.nameslist.lboxb.list <ButtonRelease-1> {NameListChoose $icp.files.nameslist.lboxb.list $azaz}

		bind $ins_file_lst 		 <ButtonRelease-1> {}
		bind $f.btns.2.l   		 <ButtonRelease-1> {}
		bind $f.btns.2.e   		 <ButtonRelease-1> {}
	} else {
		bind $t.btns.continue 	<ButtonRelease-1> {}
		bind $t.btns.conclude 	<ButtonRelease-1> {}
		bind $t.btns.abort    	<ButtonRelease-1> {}
		bind $f.btns.1.newfile  <ButtonRelease-1> {}
		bind $f.btns.1.clear   	<ButtonRelease-1> {}
		bind $f.btns.2.props  	<ButtonRelease-1> {}
		bind $f.btns.2.pl   	<ButtonRelease-1> {}
		bind $f.btns.4.ro   	<ButtonRelease-1> {}
		if {$ins(create)} {
			set i 0
			while {$i < $tree(files_icon_cnt)} {
				bind $t.tree.c.canvas.ff$i.button <ButtonRelease-1> {}
				incr i
			}
			set i 0
			while {$i < $tree(process_cnt)} {
				bind $t.tree.c.canvas.pp$i.label <ButtonRelease-1> {}
				incr i
			}
		}
		bind $f.btns.3.lab  <ButtonRelease-1> {}
		bind $f.filelist	<ButtonRelease-1> {}
		bind $ins_file_lst 	<ButtonRelease-1> {}
		bind $ins_file_lst 	<ButtonRelease-1> {RemovefromInsInfileListing}
	}
	bind $icp.help.quit <ButtonRelease-1> {}
	bind $icp.help.tips <ButtonRelease-1> {}

	bind $t.key.key		<ButtonRelease-1> {}
	bind $t.key.snd     <ButtonRelease-1> {}
	bind $t.key.mono 	<ButtonRelease-1> {}
	bind $t.key.anal    <ButtonRelease-1> {}
	bind $t.key.pitch   <ButtonRelease-1> {}
	bind $t.key.trans   <ButtonRelease-1> {}
	bind $t.key.fmnt    <ButtonRelease-1> {}
	bind $t.key.env     <ButtonRelease-1> {}
	bind $t.key.txt     <ButtonRelease-1> {}
	bind $t.key.pseud   <ButtonRelease-1> {}
	if {$ins(run)} {			
		bind $t.key.keep	<ButtonRelease-1> {}
		bind $t.key.del 	<ButtonRelease-1> {}
	}
	bind $t.tree 		<ButtonRelease-1> {}
	bind $t.tree.c 		<ButtonRelease-1> {}

	set inspage_hlp_actv 0
	if {!$inspage_actv} {
		ReactivateInspage $w
	}
	DisableHelp $w
}	

#------ HELP FOR TABLE-EDITOR PAGE

proc DisableTabedit {w} {
	global tabedit_actv j_st tabed evv

 	set t $tabed.top
 	set ta $tabed.topa
 	set t2 $tabed.top2
 	set t3 $tabed.top3
	set b $tabed.bot
	set m $tabed.mid
	set bgt $tabed.bot.gframe
	set bkc $tabed.bot.kcframe
	set bkt $tabed.bot.ktframe
	set bf  $tabed.bot.fframe.d
	set mm $tabed.message
 	set d "disabled"

	catch {unset j_st}
	lappend j_st [$ta.joi cget -state]
	lappend j_st [$t3.mat cget -state]
	lappend j_st [$t3.mus cget -state]
	lappend j_st [$t3.tim cget -state]
	lappend j_st [$t3.db  cget -state]
	lappend j_st [$t3.ord cget -state]
	lappend j_st [$t3.ran cget -state]
	lappend j_st [$t.cre cget -state]
	lappend j_st [$t.cre2 cget -state]
	lappend j_st [$ta.vec cget -state]		
	lappend j_st [$t3.for cget -state]
	lappend j_st [$t3.ins cget -state]
	lappend j_st [$bgt.ok cget -state]
	lappend j_st [$bgt.blob.skip cget -state]
	lappend j_st [$bgt.cse cget -state]
	lappend j_st [$bkc.oko cget -state]
	lappend j_st [$bkc.okr cget -state]
	lappend j_st [$bkc.oki cget -state]
	lappend j_st [$bkc.okk cget -state]
	lappend j_st [$bkc.ok cget -state]
	lappend j_st [$bkt.zz2.ok1 cget -state]
	lappend j_st [$bkt.zz2a.ok2 cget -state]
	lappend j_st [$bkt.zz2a.ok3 cget -state]
	lappend j_st [$bkt.zz2.ok4 cget -state]
	lappend j_st [$m.nor cget -state]
	lappend j_st [$m.chk cget -state]
	lappend j_st [$m.mul cget -state]
	lappend j_st [$m.fre cget -state]
	lappend j_st [$t.reset cget -state]
	lappend j_st [$m.gl cget -state]
	lappend j_st [$m.gr cget -state]
	lappend j_st [$ta.brk cget -state]
	lappend j_st [$t.same cget -state]
	lappend j_st [$ta.tab cget -state]
	lappend j_st [$bkc.oky cget -state]
	lappend j_st [$bkc.okz cget -state]
	lappend j_st [$b.itframe.tcop cget -state]
	lappend j_st [$bf.all cget -state]
	lappend j_st [$bf.mix cget -state]
	lappend j_st [$bf.brk cget -state]
	lappend j_st [$bkt.bbb.1 cget -state]
	lappend j_st [$bkt.bbb.2 cget -state]
	lappend j_st [$t.tes cget -state]		
	lappend j_st [$t3.ins2 cget -state]
	lappend j_st [$t.fin cget -state]
	lappend j_st [$b.icframe.zog.sw cget -state]
	lappend j_st [$t3.ins3 cget -state]
	lappend j_st [$ta.env cget -state]
	lappend j_st [$tabed.message.pref cget -state]
	lappend j_st [$tabed.message.pref2 cget -state]
	lappend j_st [$tabed.message.ree cget -state]
	lappend j_st [$tabed.message.ok cget -state]
	lappend j_st [$tabed.message.no cget -state]
 	lappend j_st [$t.der cget -state]
	lappend j_st [$bgt.cse2 cget -state]
	lappend j_st [$bkt.bbb1.3 cget -state]
	lappend j_st [$bkt.bbb1.4 cget -state]
	lappend j_st [$t3.int cget -state]
	lappend j_st [$ta.atc cget -state]
	lappend j_st [$bkt.bbb2.6 cget -state]
	lappend j_st [$t.ins4 cget -state]
	lappend j_st [$ta.seq cget -state]
	lappend j_st [$bkt.bxxb cget -state]

	$tabed.help.quit config -state $d
	$t2.ref config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
	$tabed.message.pref config -state $d
	$tabed.message.pref2 config -state $d
	$tabed.message.ree config -state $d
	$tabed.message.ok config -state $d
	$tabed.message.no config -state $d
	$tabed.help.nns config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
	$t2.calc config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
	$tabed.help.tips config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
	$t3.mat config -state $d
	$t3.mus config -state $d
	$t3.int config -state $d
	$t3.tim config -state $d
	$t3.db  config -state $d
	$t3.ord config -state $d
	$t3.ran config -state $d
	$t.cre config -state $d
	$t.cre2 config -state $d
	$t.der config -state $d
	$ta.vec config -state $d
	$t.tes config -state $d
	$t.fin config -state $d
	$t3.for config -state $d
	$t3.ins config -state $d
	$t3.ins2 config -state $d
	$t3.ins3 config -state $d
	$t.ins4 config -state $d
	$ta.tab config -state $d
	$ta.atc config -state $d
	$ta.env config -state $d
	$ta.joi config -state $d
	$m.gl config -state $d
	$m.gr config -state $d
	$m.par1 config -state $d
	$m.par2 config -state $d
	$b.icframe.io config -state $d
	$b.icframe.isu config -state $d
	$b.fframe.e.sort config -state $d
	$bf.all config -state $d
	$bf.mix config -state $d
	$bf.brk config -state $d
	$b.icframe.isu2 config -state $d
	$b.icframe.zog.sw config -state $d
	$b.ocframe.oi config -state $d
	$b.ocframe.rnd config -state $d
	$b.ocframe.rst config -state $d
	$bgt.e  config -state $d
	$bgt.ok config -state $d
	$bgt.blob.skip config -state $d
	$bgt.cse config -state $d
	$bgt.cse2 config -state $d
	$bkc.oko config -state $d
	$bkc.okr config -state $d
	$bkc.oki config -state $d
	$bkc.okk config -state $d
	$bkc.e config -state $d
	$bkc.oky config -state $d
	$bkc.okz config -state $d
	$bkc.ok config -state $d
	$b.otframe.rnd.rnd config -state $d
	$b.otframe.rnd.rec config -state $d
	$b.otframe.rnd.cle config -state $d
	$bkt.zz2.ok1 config -state $d
	$bkt.zz2a.ok2 config -state $d
	$bkt.zz2a.ok3 config -state $d
	$bkt.zz2.ok4 config -state $d
	$bkt.fnm config -state $d
	$bkt.bbb.1 config -state $d 
	$bkt.bbb.2 config -state $d
	$bkt.bbb1.3 config -state $d
	$bkt.bbb1.4 config -state $d
	$bkt.bxxb config -state $d
	$bkt.bbb2.6 config -state $d
	bind $bkt.names.list <ButtonRelease-1> {}

	$ta.brk config -state $d
	$ta.seq config -state $d
	$mm.e config -state $d

	$m.info config -state $d -disabledforeground $evv(HELP_DISABLED_FG)
	$m.bashelp config -state $d
	$t.which config -state $d -disabledforeground $evv(HELP_DISABLED_FG)

	$m.nor config -state $d
	$m.chk config -state $d
	$m.mul config -state $d
	$m.fre config -state $d
	$t.same config -state $d
	$t.reset config -state $d
	$t2.rmac config -state $d
	$t2.smac config -state $d
	$t2.lmac config -state $d
	$t2.dmac config -state $d

	set tabedit_actv 0
	PutHelpInPassiveMode $w
	$tabed.help.con config -command "ReactivateTabedit $w"
}	

proc ReactivateTabedit {w} {
	global tabedit_hlp_actv tabedit_actv j_st tabedit_bind2 tabedit_bind3 z1 tabed

 	set t $tabed.top
 	set ta $tabed.topa
 	set t2 $tabed.top2
 	set t3 $tabed.top3
	set b $tabed.bot
	set m $tabed.mid
	set bgt $tabed.bot.gframe
	set bkc $tabed.bot.kcframe
	set bkt $tabed.bot.ktframe
	set bf  $tabed.bot.fframe.d
	set mm $tabed.message
 	set n "normal"

	set indx 0
	foreach st $j_st {
		switch -exact -- $indx {
			0	{$ta.joi config -state $st}
			1	{$t3.mat config -state $st}
			2	{$t3.mus config -state $st}
			3	{$t3.tim config -state $st}
			4	{$t3.db  config -state $st}
			5	{$t3.ord config -state $st}
			6	{$t3.ran config -state $st}
			7	{$t.cre config -state $st}
			8	{$t.cre2 config -state $st}
			9	{$ta.vec config -state $st}
			10	{$t3.for config -state $st}
			11	{$t3.ins config -state $st}
			12	{$bgt.ok config -state $st}
			13	{$bgt.blob.skip config -state $st}
			14	{$bgt.cse config -state $st}
			15	{$bkc.oko config -state $st}
			16	{$bkc.okr config -state $st}
			17	{$bkc.oki config -state $st}
			18	{$bkc.okk config -state $st}
			19	{$bkc.ok config -state $st}
			20	{$bkt.zz2.ok1 config -state $st}
			21	{$bkt.zz2a.ok2 config -state $st}
			22	{$bkt.zz2a.ok3 config -state $st}
			23	{$bkt.zz2.ok4 config -state $st}
			24	{$m.nor config -state $st}
			25	{$m.chk config -state $st}
			26	{$m.mul config -state $st}
			27	{$m.fre config -state $st}
			28	{$t.reset config -state $st}
			29	{$m.gl config -state $st}
			30	{$m.gr config -state $st}
			31	{$ta.brk config -state $st}
			32	{$t.same config -state $st}
			33	{$ta.tab config -state $st}
			34	{$bkc.oky config -state $st}
			35	{$bkc.okz config -state $st}
			36	{$b.itframe.tcop config -state $st}
			37	{$bf.all config -state $st}
			38	{$bf.mix config -state $st}
			39	{$bf.brk config -state $st}
			40	{$bkt.bbb.1 config -state $st}
			41	{$bkt.bbb.2 config -state $st}
			42	{$t.tes config -state $st}
			43	{$t3.ins2 config -state $st}
			44	{$t.fin config -state $st}
			45	{$b.icframe.zog.sw config -state $st}
			46	{$t3.ins3 config -state $st}
			47	{$ta.env config -state $st}
			48	{$tabed.message.pref config -state $st}
			49	{$tabed.message.pref2 config -state $st}
			50	{$tabed.message.ree  config -state $st}
			51	{$tabed.message.ok config -state $st}
			52	{$tabed.message.no config -state $st}
			53	{$t.der config -state $st}
			54	{$bgt.cse2 config -state $st}
			55	{$bkt.bbb1.3 config -state $st}
			56	{$bkt.bbb1.4 config -state $st}
			57	{$t3.int config -state $st}
			58	{$ta.atc config -state $st}
			59	{$bkt.bbb2.6 config -state $st}
			60	{$t.ins4 config -state $st}
			61	{$ta.seq config -state $st}
			62	{$bkt.bxxb config -state $st}
		}
		incr indx
	}
	$tabed.help.quit config -state $n
 	$t2.ref config -state $n
 	$tabed.help.nns config -state $n
	$t2.calc config -state $n
	$tabed.help.tips config -state $n
	$m.par1 config -state $n
	$m.par2 config -state $n
	$b.icframe.io config -state $n
	$b.icframe.isu config -state $n
	$b.fframe.e.sort config -state $n
	$b.icframe.isu2 config -state $n
	$b.ocframe.oi config -state $n
	$b.ocframe.rnd config -state $n
	$b.ocframe.rst config -state $n
	$bgt.e  config -state $n
	$bkc.e config -state $n
	$b.otframe.rnd.rnd config -state $n
	$b.otframe.rnd.rec config -state $n
	$b.otframe.rnd.cle config -state $n
	$bkt.fnm config -state $n
	$t2.rmac config -state $n
	$t2.smac config -state $n
	$t2.lmac config -state $n
	$t2.dmac config -state $n

	if [info exists tabedit_bind2] {
		bind $bkt.names.list <ButtonRelease-1> $tabedit_bind2
	}
	if {[info exists z1] && [info exists tabedit_bind3]} {
		bind $z1 <ButtonRelease-1> $tabedit_bind3
	}

	$mm.e config -state $n
	$m.info config -state $n
	$m.bashelp config -state $n

	$t.which config -state $n

	set tabedit_actv 1
	if {$tabedit_hlp_actv} {
		PutHelpInActiveMode $w
	}
	$tabed.help.con config -command "DisableTabedit $w"
}	

proc ActivateTabeditHelp {} {
	global z1 tabedit_bind3 tabed

 	set t $tabed.top
 	set ta $tabed.topa
 	set t2 $tabed.top2
 	set t3 $tabed.top3
	set b $tabed.bot
	set m $tabed.mid
	set bgt $tabed.bot.gframe
	set bkc $tabed.bot.kcframe
	set bkt $tabed.bot.ktframe
	set bf  $tabed.bot.fframe.d
	set mm $tabed.message

	bind $tabed.help.quit <ButtonRelease-1> {TedH quit}
	bind $t2.ref <ButtonRelease-1> {TedH Ref}

	bind $tabed.message.pref <ButtonRelease-1> {TedH Pref}
	bind $tabed.message.pref2 <ButtonRelease-1> {TedH Pref2}
	bind $tabed.message.ree <ButtonRelease-1> {TedH Ree}
	bind $tabed.message.ok <ButtonRelease-1> {TedH Rok}
	bind $tabed.message.no <ButtonRelease-1> {TedH Rno}

	bind $tabed.help.nns <ButtonRelease-1> {TedH Notepad}
	bind $t2.calc <ButtonRelease-1> {TedH Calc}
	bind $tabed.help.tips <ButtonRelease-1> {TedH tips}
	bind $t3.mat <ButtonRelease-1> {TedH maths}
	bind $t3.mus <ButtonRelease-1> {TedH pitch}
	bind $t3.int <ButtonRelease-1> {TedH interval}
	bind $t3.tim <ButtonRelease-1> {TedH time}
	bind $t3.db  <ButtonRelease-1> {TedH loudness}
	bind $t3.ord <ButtonRelease-1> {TedH order}
	bind $t3.ran <ButtonRelease-1> {TedH random}
	bind $t.cre <ButtonRelease-1> {TedH create}
	bind $t.cre2 <ButtonRelease-1> {TedH special}
	bind $t.der <ButtonRelease-1> {TedH derived}
	bind $ta.vec <ButtonRelease-1> {TedH combine}
	bind $t.tes <ButtonRelease-1> {TedH test}
	bind $t.fin <ButtonRelease-1> {TedH find}
	bind $t3.for <ButtonRelease-1> {TedH format}
	bind $t3.ins <ButtonRelease-1> {TedH edit}
	bind $t3.ins2 <ButtonRelease-1> {TedH edito}
	bind $t3.ins3 <ButtonRelease-1> {TedH editc}
	bind $t.ins4 <ButtonRelease-1> {TedH tabsnd}
	bind $ta.tab <ButtonRelease-1> {TedH tab}
	bind $ta.atc <ButtonRelease-1> {TedH tabatc}
	bind $ta.joi <ButtonRelease-1> {TedH join}
	bind $ta.env <ButtonRelease-1> {TedH Env}
	bind $m.lab1 <ButtonRelease-1> {TedH prm}
	bind $m.par1 <ButtonRelease-1> {TedH prm}
	bind $m.lab2 <ButtonRelease-1> {TedH thresh}
	bind $m.par2 <ButtonRelease-1> {TedH thresh}
	bind $m.gl <ButtonRelease-1> {TedH gt}
	bind $m.gr <ButtonRelease-1> {TedH lt}
	bind $b.files <ButtonRelease-1> {TedH files}
	bind $b.cols <ButtonRelease-1> {TedH cols}
	bind $b.itab <ButtonRelease-1> {TedH intab}

	bind $b.itframe.tcop <ButtonRelease-1> {TedH tcop}
	bind $b.icframe.dummy.name <ButtonRelease-1> {TedH colin}
	bind $b.icframe.dummy.cnt  <ButtonRelease-1> {TedH colincnt}
	bind $b.icframe.io <ButtonRelease-1> {TedH io}
	bind $b.icframe.isu <ButtonRelease-1> {TedH InSitu}
	bind $b.fframe.e.sort <ButtonRelease-1> {TedH Sort}
	bind $bf.all <ButtonRelease-1> {TedH s_all}
	bind $bf.mix <ButtonRelease-1> {TedH s_mix}
	bind $bf.brk <ButtonRelease-1> {TedH s_brk}
	bind $b.icframe.isu2 <ButtonRelease-1> {TedH Normal}
	bind $b.icframe.zog.sw <ButtonRelease-1> {TedH swap}
	bind $b.ocframe.zog.sw <ButtonRelease-1> {TedH swap}
	bind $b.ocframe.oi <ButtonRelease-1> {TedH oi}
	bind $b.ocframe.dummy.name <ButtonRelease-1> {TedH colout}
	bind $b.ocframe.dummy.cnt <ButtonRelease-1> {TedH coloutcnt}
	bind $b.ocframe.rnd <ButtonRelease-1> {TedH cround}
	bind $b.ocframe.rst <ButtonRelease-1> {TedH restore}
	bind $bgt.e  <ButtonRelease-1> {TedH getcol}
	bind $bgt.name <ButtonRelease-1> {TedH getcol}
	bind $bgt.ok <ButtonRelease-1> {TedH getcolok}
	bind $bkc.name <ButtonRelease-1> {TedH keepcol}
	bind $b.otab <ButtonRelease-1> {TedH tabout}
	bind $bkt.name <ButtonRelease-1> {TedH savetab}
	bind $b.itframe.f.lab <ButtonRelease-1> {TedH colcnt}
	bind $b.itframe.f.e <ButtonRelease-1> {TedH colcnt}
	bind $b.itframe.f.lab2 <ButtonRelease-1> {TedH rowcnt}
	bind $b.itframe.f.e2 <ButtonRelease-1> {TedH rowcnt}
	bind $bgt.sk <ButtonRelease-1> {TedH skip}
	bind $bgt.blob.skip <ButtonRelease-1> {TedH skip}
	bind $bgt.got <ButtonRelease-1> {TedH colgot}
	bind $bgt.ddum <ButtonRelease-1> {TedH colgot}
	bind $bgt.cse <ButtonRelease-1> {TedH skipes}
	bind $bgt.cse2 <ButtonRelease-1> {TedH skipc}
	bind $ta.brk <ButtonRelease-1> {TedH brk}
	bind $ta.seq <ButtonRelease-1> {TedH seq}
	bind $bgt.lab <ButtonRelease-1> {TedH skipes}
	bind $bgt.lab2 <ButtonRelease-1> {TedH skipc}
	bind $bkc.oko <ButtonRelease-1> {TedH orig}
	bind $bkc.okr <ButtonRelease-1> {TedH replace}
	bind $bkc.oki <ButtonRelease-1> {TedH insert}
	bind $bkc.okk <ButtonRelease-1> {TedH itself}
	bind $bkc.lab <ButtonRelease-1> {TedH whichcol}
	bind $bkc.e <ButtonRelease-1> {TedH whichcol}
	bind $bkc.oky <ButtonRelease-1> {TedH to_inc}
	bind $bkc.okz <ButtonRelease-1> {TedH to_outc}
	bind $bkc.ok <ButtonRelease-1> {TedH putcolok}
	bind $b.otframe.cnt.e <ButtonRelease-1> {TedH occnt}
	bind $b.otframe.cnt.e2 <ButtonRelease-1> {TedH olcnt}
	bind $b.otframe.rnd.rnd <ButtonRelease-1> {TedH tround}
	bind $b.otframe.rnd.rec <ButtonRelease-1> {TedH trecyc}
	bind $b.otframe.rnd.cle <ButtonRelease-1> {TedH oclear}
	bind $bkt.zz2.ok1 <ButtonRelease-1> {TedH savetabl}
	bind $bkt.zz2a.ok2 <ButtonRelease-1> {TedH savecol}
	bind $bkt.zz2a.ok3 <ButtonRelease-1> {TedH saverow}
	bind $bkt.zz2.ok4 <ButtonRelease-1> {TedH savebatch}
	bind $bkt.lab4 <ButtonRelease-1> {TedH filename}
	bind $bkt.fnm <ButtonRelease-1> {TedH filename}
	bind $bkt.bbb.1 <ButtonRelease-1> {TedH standard}
	bind $bkt.bbb.2 <ButtonRelease-1> {TedH standard}
	bind $bkt.bbb1.3 <ButtonRelease-1> {TedH standard}
	bind $bkt.bbb1.4 <ButtonRelease-1> {TedH standard}
	bind $bkt.bxxb <ButtonRelease-1> {TedH standard2}
	bind $bkt.bbb2.6 <ButtonRelease-1> {TedH inname}
	bind $bkt.names.list <ButtonRelease-1> {TedH rnames}

	bind $mm.mes <ButtonRelease-1> {TedH message}
	bind $mm.e <ButtonRelease-1> {TedH message}
	bind $m.info <ButtonRelease-1> {TedH info}
	bind $m.bashelp <ButtonRelease-1> {TedH bashelp}

	bind $t.which <ButtonRelease-1> {TedH which}
	bind $m.nor <ButtonRelease-1> {TedH filtotab}
	bind $m.chk <ButtonRelease-1> {TedH filtocol}
	bind $m.mul <ButtonRelease-1> {TedH multifile}
	bind $m.fre <ButtonRelease-1> {TedH freetext}
	bind $t.reset <ButtonRelease-1> {TedH restart}
	bind $t.same <ButtonRelease-1> {TedH same}
	bind $t2.xmac <ButtonRelease-1> {TedH macro}
	bind $t2.rmac <ButtonRelease-1> {TedH mrecord}
	bind $t2.smac <ButtonRelease-1> {TedH msave}
	bind $t2.lmac <ButtonRelease-1> {TedH mload}
	bind $t2.dmac <ButtonRelease-1> {TedH mrun}

	bind $b.itframe.l.list <ButtonRelease-1> {TedH intab}
	bind $b.otframe.l.list <ButtonRelease-1> {TedH tabout}
	if {[info exists z1] && [info exists tabedit_bind3]} {
		bind $z1 <ButtonRelease-1> {}
	}
	bind $b.icframe.l.list <ButtonRelease-1> {TedH colin}
	bind $b.ocframe.l.list <ButtonRelease-1> {TedH colout}
	bind $b.fframe.l.list <ButtonRelease-1> {+ TedH files}
}	

proc TedH {subject args} {
	global tabedit_actv tabedit_hlp_actv rsto tabed
	set f $tabed.help.help
	switch -- $subject {
		quit {
			$f config -text "Quit the Table Editor and return to the Page you were working on."
		}
		Ref {
			$f config -text "Get one of your own Reference Values (entered directly or created on the Calculator)."
		}
		Pref {
			if [string match $rsto "ted"] {
				$f config -text "Enter a text to help identify your reference value."
			} else {
				$f config -text "Save the (named) output table as a Reference value, to use elsewhere."
			}
		}
		Pref2 {
			if [string match $rsto "tedmes"] {
				$f config -text "Enter a text to help identify your reference value."
			} else {
				$f config -text "Save the message as a Reference value, to use elsewhere."
			}
		}
		Ree {
			if [string match $rsto "ted"] {
				$f config -text "A text to identify the Reference Filename you are saving."
			}
		}
		Rok {
			if [string match $rsto "ted"] {
				$f config -text "Confirm that you wish to save the Reference Value, and its associated text."
			}
		}
		Rno {
			if [string match $rsto "ted"] {
				$f config -text "Abandon saving a filename as a Reference Value."
			}
		}
		Notepad {
			$f config -text "Call up a notebook where you can keep notes about what you've done, or plan to do."
		}
		Calc {
			$f config -text "Calculator for converting between musical units, doing maths, and storing reference values."
		}
		tips {
			$f config -text "If you have a problem on this page, consult the 'Tips' information."
		}
		restart {
			$f config -text "Clear the table and column displays, to begin a new process."
		}
		same {
			$f config -text "Repeat the previous process. (x1,x2...type processes require parameter entry)."
		}
		macro {
			$f config -text "Record a sequence of Table Editor operations, and then run it as a 'macro'."
		}
		mrecord {
			if [string match [$tabed.top2.rmac cget -text] "Record"] {
				$f config -text "Start recording a sequence of Table Editor operations, to make a macro."
			} else {
				$f config -text "Stop recording of Table Editor operations, to complete a macro."
			}
		}
		mcomplete {
			$f config -text "Finish recording a sequence of Table Editor operations."
		}
		msave {
			$f config -text "Save the current macro for future use."
		}
		mload {
			$f config -text "Get a previously created macro."
		}
		mrun {
			$f config -text "Run a recorded sequence of Table Editor operations."
		}
		maths {
			$f config -text "Mathematical processes to apply to each entry in Col Input."
		}
		pitch {
			$f config -text "Pitch manipulation processes to apply to each entry in Col Input."
		}
		interval {
			$f config -text "Interval manipulation processes to apply to each entry in Col Input."
		}
		time {
			$f config -text "Time calculations to apply to each entry in Col Input."
		}
		loudness {
			$f config -text "Loudness unit conversions to apply to each entry in Col Input."
		}
		order {
			$f config -text "Reorder, copy, group, count or rank the entries in Col Input."
		}
		random {
			$f config -text "Apply randomising operations to entries in Col Input."
		}
		create {
			$f config -text "Generate from scratch a new column of values."
		}
		special {
			$f config -text "Specialised operations to generate tables."
		}
		derived {
			$f config -text "Derive a new table from values in an existing table."
		}
		combine {
			$f config -text "Combine (usually pairwise) the values in Col Input, with those in Col Output."
		}
		test {
			$f config -text "Test properties of the data in a column."
		}
		find {
			$f config -text "Find particular values in a column."
		}
		format {
			$f config -text "Take the Table Input, Col Input or Col Output, and lay out the entries differently."
		}
		edit {
			$f config -text "Remove,Insert,Replace,Group or Mark items in Col Input or Trim column to a given size."
		}
		edito {
			$f config -text "Remove,Insert, or Replace values in OUTPUT column, or Trim output column to a given size."
		}
		editc {
			$f config -text "Remove,Insert, or Replace values at the Cursor position in a column."
		}
		tabsnd {
			$f config -text "Derive numerical information from the soundfiles chosen on the workspace page."
		}
		join {
			$f config -text "Combine the data from several files. (Only active in Multiple Files Mode)."
		}
		tab {
			$f config -text "Modify the data in a table, to make a new table."
		}
		tabatc {
			$f config -text "Modify the data in a table at the marked position, to make a new table."
		}
		Env {
			$f config -text "Modify the data in a normalised envelope data table."
		}
		prm {
			$f config -text "The parameter value N required by many of the processes in the menus."
		}
		thresh {
			$f config -text "The threshold value used with a few Maths menu operations, and elsewhere."
		}
		gt {
			$f config -text "Only values Greater than the threshold you enter are transformed. (Applies to only a few options)."
		}
		lt {
			$f config -text "Only values Less than the threshold you enter are transformed. (Applies to only a few options)."
		}
		filtotab {
			$f config -text "A selected File is displayed as the Input Table. (This is the default mode)."
		}
		filtocol {
			$f config -text "A selected File is displayed in the Col Output, BUT Only If It Is A Single Column Of Data."
		}
		multifile {
			$f config -text "Selected File are listed in the Output Table and may be conjoined by processes on 'Join' menu."
		}
		freetext {
			$f config -text "In 'Free text' mode Table Editor accepts ANY text file as input. Normally accepts data in columns only."
		}
		files {
			$f config -text "A list of all text files from the Workspace which you can work with."
		}
		intab {
			$f config -text "A display of the contents of the File you have selected from the Files List on the left."
		}
		tcop {
			$f config -text "Copy the input table directly to the output table display."
		}
		colcnt {
			$f config -text "The number of columns in the File you have selected and displayed."
		}
		rowcnt {
			$f config -text "The total number of rows in the File you have selected and displayed."
		}
		cols {
			$f config -text "The column of data you are working on."
		}
		colin {
			$f config -text "Displays single column selected from Input Table display, or a column you've created."
		}
		colincnt {
			$f config -text "A count of the number of rows in the input column."
		}
		oi {
			$f config -text "Copy contents of Output column into Input column."
		}
		io {
			$f config -text "Copy contents of Input column into Output column."
		}
		InSitu {
			$f config -text "Put result in the Input column (overwriting original values) rather than in the Output column."
		}
		swap {
			$f config -text "Swap the 2 columns around."
		}
		Normal {
			$f config -text "Put the result of calculations in the output column."
		}
		Sort {
			$f config -text "Sort the files into alphabetical order."
		}
		s_all {
			$f config -text "Display all types of table files."
		}
		s_mix {
			$f config -text "Display only mixfiles."
		}
		s_brk {
			$f config -text "Display only breakpoint data files. ('Brk' menu won't work on any single column files that may be listed.)"
		}
		colout {
			$f config -text "A Column generated from Column Input vals, or from scratch, or entered in 'File->Col' mode."
		}
		coloutcnt {
			$f config -text "The number of rows in the output column."
		}
		cround {
			$f config -text "Selecting this button causes each value in the Col Output to be rounded to the nearest integer value."
		}
		restore {
			$f config -text "Restore the previous state of Col Output (if there was one)."
		}
		tabout {
			$f config -text "The new table you have generated."
		}
		tround {
			$f config -text "Selecting this button causes each value in the Output Table to be rounded to the nearest integer value."
		}
		occnt {
			$f config -text "Number of columns in the output table."
		}
		olcnt {
			$f config -text "Number of rows in the output table."
		}
		trecyc {
			$f config -text "Recycle the Output Table as the new Input Table."
		}
		oclear {
			$f config -text "Clear values from the output table display."
		}
		savetab {
			$f config -text "The Output Table may be saved as a new file (or files) here."
		}
		getcol {
			$f config -text "Specify which column of the Input Table you would like to work on."
		}
		colgot {
			$f config -text "The Input Table column which you are currently working on."
		}
		getcolok {
			$f config -text "Grab the column of the Input Table you have specified. It will appear in Col Input."
		}
		skip {
			$f config -text "Specify how many lines of the Input Table you would like to skip before reading the Column data."
		}
		brk {
			$f config -text "Operate on a 2-column table representing paired times and values, a breakpoint file."
		}
		seq {
			$f config -text "Operate on 3-column table of grouped time, transposition, loudness values: a sequence file."
		}
		skipes {
			$f config -text "Comment lines (and 'e' and 's' lines in CSound data) will be ignored, if this option selected."
		}
		skipc {
			$f config -text "Comment lines (starting with ';') will be ignored, if this option is selected."
		}
		keepcol {
			$f config -text "Specify here what to do with the Col Output."
		}
		itself {
			$f config -text "With this option, Keep the Col Output as it is."
		}
		orig {
			$f config -text "With this option, replace the Column chosen from the Input Table with the Col Output."
		}
		replace {
			$f config -text "With this option, replace a specified Column in the Table, with the Col Output."
		}
		insert {
			$f config -text "With this option, insert the Col Output as a new column in the Table, at the specified position."
		}
		to_inc {
			$f config -text "If putting the new column into an existing table, put it in the INPUT table."
		}
		to_outc {
			$f config -text "If the new column is being put in an existing table, put it in the OUTPUT table."
		}
		whichcol {
			$f config -text "Specify where you wish to insert a column, or which column you wish to replace, in the Input Table."
		}
		putcolok {
			$f config -text "Transfer the specified Col Ouput to the Output Table in the manner chosen."
		}
		filename {
			$f config -text "Specify the name of the file (or files) in which you will save the Output Table data."
		}
		standard {
			$f config -text "Select a standard outputfile name for the table."
		}
		standard2 {
			$f config -text "Select a name for the table from the list of CDP standard names."
		}
		inname {
			$f config -text "Use name of input file (usually only when extracting Rows or Columns of out-table)."
		}
		rnames {
			$f config -text "Select (with the mouse) a recently used name as (part of) the name for the output table."
		}
		savetabl {
			$f config -text "Save the Output Table data to a named file."
		}
		savecol {
			$f config -text "Save each column of the Output Table to a separate file."
		}
		saverow {
			$f config -text "Save each row of the Output Table to a separate file."
		}
		savebatch {
			$f config -text "Save the table as a batch file, for Batchfile processing."
		}
		message {
			$f config -text "Messages, Warnings, or Special Results (e.g. the count of items in a column) will appear here."
		}
		info {
			$f config -text "Press here for further information about the Table Editor."
		}
		bashelp {
			$f config -text "Press here for an Introduction to the Table Editor."
		}
		which {
			$f config -text "Press here to help find a process on the Table Editor."
		}
		default {
			ErrShow "Unknown option in TedH"
		}
	}
}

proc DisableHelpOnTabedit {w} {
	global tabedit_hlp_actv tabedit_actv tabedit_bindcmd tabedit_bind2 tabedit_bind3 z1 tabed

 	set t $tabed.top
 	set ta $tabed.topa
 	set t2 $tabed.top2
 	set t3 $tabed.top3
	set b $tabed.bot
	set m $tabed.mid
	set bgt $tabed.bot.gframe
	set bkc $tabed.bot.kcframe
	set bkt $tabed.bot.ktframe
	set bf  $tabed.bot.fframe.d
	set mm $tabed.message

	bind $tabed.help.quit <ButtonRelease-1> {}
	bind $t2.ref <ButtonRelease-1> {}
	bind $tabed.message.pref <ButtonRelease-1> {}
	bind $tabed.message.pref2 <ButtonRelease-1> {}
	bind $tabed.message.ree <ButtonRelease-1> {}
	bind $tabed.message.ok <ButtonRelease-1> {}
	bind $tabed.message.no <ButtonRelease-1> {}
	bind $tabed.help.nns <ButtonRelease-1> {}
	bind $t2.calc <ButtonRelease-1> {}
	bind $tabed.help.tips <ButtonRelease-1> {}
	bind $t3.mat <ButtonRelease-1> {}
	bind $t3.mus <ButtonRelease-1> {}
	bind $t3.int <ButtonRelease-1> {}
	bind $t3.tim <ButtonRelease-1> {}
	bind $t3.db  <ButtonRelease-1> {}
	bind $t3.ord <ButtonRelease-1> {}
	bind $t3.ran <ButtonRelease-1> {}
	bind $t.cre <ButtonRelease-1> {}
	bind $t.cre2 <ButtonRelease-1> {}
	bind $t.der <ButtonRelease-1> {}
	bind $ta.vec <ButtonRelease-1> {}
	bind $t.tes <ButtonRelease-1> {}
	bind $t.fin <ButtonRelease-1> {}
	bind $t3.for <ButtonRelease-1> {}
	bind $t3.ins <ButtonRelease-1> {}
	bind $t3.ins2 <ButtonRelease-1> {}
	bind $t3.ins3 <ButtonRelease-1> {}
	bind $t.ins4 <ButtonRelease-1> {}
	bind $ta.tab <ButtonRelease-1> {}
	bind $ta.atc <ButtonRelease-1> {}
	bind $ta.env <ButtonRelease-1> {}
	bind $ta.joi <ButtonRelease-1> {}
	bind $m.lab1 <ButtonRelease-1> {}
	bind $m.par1 <ButtonRelease-1> {}
	bind $m.lab2 <ButtonRelease-1> {}
	bind $m.par2 <ButtonRelease-1> {}
	bind $m.gl <ButtonRelease-1> {}
	bind $m.gr <ButtonRelease-1> {}
	bind $b.files <ButtonRelease-1> {}
	bind $b.cols <ButtonRelease-1> {cols}
	bind $b.itab <ButtonRelease-1> {}
	bind $b.itframe.tcop <ButtonRelease-1> {}
	bind $b.icframe.dummy.name <ButtonRelease-1> {}
	bind $b.icframe.dummy.cnt  <ButtonRelease-1> {}
	bind $b.icframe.io <ButtonRelease-1> {}
	bind $b.icframe.isu <ButtonRelease-1> {}
	bind $b.fframe.e.sort <ButtonRelease-1> {}
	bind $bf.all <ButtonRelease-1> {}
	bind $bf.mix <ButtonRelease-1> {}
	bind $bf.brk <ButtonRelease-1> {}
	bind $b.icframe.isu2 <ButtonRelease-1> {}
	bind $b.icframe.zog.sw <ButtonRelease-1> {}
	bind $b.ocframe.zog.sw <ButtonRelease-1> {}
	bind $b.ocframe.oi <ButtonRelease-1> {}
	bind $b.ocframe.dummy.name <ButtonRelease-1> {}
	bind $b.ocframe.dummy.cnt <ButtonRelease-1> {}
	bind $b.ocframe.rnd <ButtonRelease-1> {}
	bind $b.ocframe.rst <ButtonRelease-1> {}
	bind $bgt.e  <ButtonRelease-1> {}
	bind $bgt.name <ButtonRelease-1> {}
	bind $bgt.ok <ButtonRelease-1> {}
	bind $bkc.name <ButtonRelease-1> {}
	bind $b.otab <ButtonRelease-1> {}
	bind $bkt.name <ButtonRelease-1> {}
	bind $b.itframe.f.lab <ButtonRelease-1> {}
	bind $b.itframe.f.e <ButtonRelease-1> {}
	bind $b.itframe.f.lab2 <ButtonRelease-1> {}
	bind $b.itframe.f.e2 <ButtonRelease-1> {}
	bind $bgt.sk <ButtonRelease-1> {}
	bind $bgt.blob.skip <ButtonRelease-1> {}
	bind $bgt.got <ButtonRelease-1> {}
	bind $bgt.ddum <ButtonRelease-1> {}
	bind $bgt.cse <ButtonRelease-1> {}
	bind $bgt.cse2 <ButtonRelease-1> {}
	bind $ta.brk <ButtonRelease-1> {}
	bind $ta.seq <ButtonRelease-1> {}
	bind $bgt.lab <ButtonRelease-1> {}
	bind $bgt.lab2 <ButtonRelease-1> {}
	bind $bkc.oko <ButtonRelease-1> {}
	bind $bkc.okr <ButtonRelease-1> {}
	bind $bkc.oki <ButtonRelease-1> {}
	bind $bkc.okk <ButtonRelease-1> {}
	bind $bkc.lab <ButtonRelease-1> {}
	bind $bkc.e <ButtonRelease-1> {}
	bind $bkc.oky <ButtonRelease-1> {}
	bind $bkc.okz <ButtonRelease-1> {}
	bind $bkc.ok <ButtonRelease-1> {}
	bind $b.otframe.cnt.e <ButtonRelease-1> {}
	bind $b.otframe.cnt.e2 <ButtonRelease-1> {}
	bind $b.otframe.rnd.rnd <ButtonRelease-1> {}
	bind $b.otframe.rnd.rec <ButtonRelease-1> {}
	bind $b.otframe.rnd.cle <ButtonRelease-1> {}
	bind $bkt.zz2.ok1 <ButtonRelease-1> {}
	bind $bkt.zz2a.ok2 <ButtonRelease-1> {}
	bind $bkt.zz2a.ok3 <ButtonRelease-1> {}
	bind $bkt.zz2.ok4 <ButtonRelease-1> {}
	bind $bkt.lab4 <ButtonRelease-1> {}
	bind $bkt.fnm <ButtonRelease-1> {}
	bind $bkt.bbb.1 <ButtonRelease-1> {}
	bind $bkt.bbb.2 <ButtonRelease-1> {}
	bind $bkt.bbb1.3 <ButtonRelease-1> {}
	bind $bkt.bbb1.4 <ButtonRelease-1> {}
	bind $bkt.bxxb <ButtonRelease-1> {}
	bind $bkt.bbb2.6 <ButtonRelease-1> {}

	bind $mm.mes <ButtonRelease-1> {}
	bind $mm.e <ButtonRelease-1> {}
	bind $m.info <ButtonRelease-1> {}
	bind $m.bashelp <ButtonRelease-1> {}

	bind $t.which <ButtonRelease-1> {}
	bind $m.nor <ButtonRelease-1> {}
	bind $m.chk <ButtonRelease-1> {}
	bind $m.mul <ButtonRelease-1> {}
	bind $m.fre <ButtonRelease-1> {}
	bind $t.reset <ButtonRelease-1> {}
	bind $t.same <ButtonRelease-1> {}
	bind $t2.xmac <ButtonRelease-1> {}
	bind $t2.rmac <ButtonRelease-1> {}
	bind $t2.smac <ButtonRelease-1> {}
	bind $t2.lmac <ButtonRelease-1> {}
	bind $t2.dmac <ButtonRelease-1> {}

	bind $b.itframe.l.list <ButtonRelease-1> {}
	bind $b.icframe.l.list <ButtonRelease-1> {}
	bind $b.ocframe.l.list <ButtonRelease-1> {}
	bind $b.otframe.l.list <ButtonRelease-1> {}


	bind $b.fframe.l.list <ButtonRelease-1> {}
	bind $b.fframe.l.list <ButtonRelease-1> "$tabedit_bindcmd"
	bind $bkt.names.list <ButtonRelease-1> {}
	if [info exists tabedit_bind2] {
		bind $bkt.names.list <ButtonRelease-1> "$tabedit_bind2"
	}
	if [info exists z1] {
		bind $z1 <ButtonRelease-1> {}
		if [info exists tabedit_bind3] {
			bind $z1 <ButtonRelease-1> "$tabedit_bind3"
		}
	}
	set tabedit_hlp_actv 0
	if {!$tabedit_actv} {
		ReactivateTabedit $w
	}
	DisableHelp $w
}	

#------ HELP INFORMATION FOR THE PITCH EDITOR

proc DisablePdisplay {w} {
	global pdisplay_actv pdisplay_hlp_actv pd_st pdc pdw
	set g $pdw

	set d "disabled"

	catch {unset pd_st}
	lappend pd_st [$g.btns1.cur cget -state]
	lappend pd_st [$g.btns1.cup cget -state]
	lappend pd_st [$g.btns1.cdn cget -state]

	$g.btns0.toe 	config -state $d
	$g.btns0.tse 	config -state $d
	$g.btns0.tte 	config -state $d
	$g.btns0.up  	config -state $d
	$g.btns0.dn  	config -state $d
	$g.btns0.dis 	config -state $d
	$g.btns0.zoo 	config -state $d
	$g.btns0.str 	config -state $d
	$g.btns0x.qui 	config -state $d
	$g.btns1.smo 	config -state $d
	$g.btns1.ins 	config -state $d
	$g.btns1.tra 	config -state $d
	$g.btns1.tre 	config -state $d
	$g.btns1.tze 	config -state $d
	$g.btns1.tup 	config -state $d
	$g.btns1.tdn 	config -state $d
	$g.btns1.tup8	config -state $d
	$g.btns1.tdn8	config -state $d
	$g.btns0x.und 	config -state $d
	$g.btns0x.pla 	config -state $d
	$g.btns0x.res 	config -state $d
	$g.btns1x.app 	config -state $d
	$g.btns1x.sav 	config -state $d
	$g.btns1x.sae 	config -state $d
	$g.btns1.fla 	config -state $d
	$g.btns1.cav 	config -state $d
	$g.btns1.vex 	config -state $d
	$g.btns1.cur 	config -state $d
	$g.btns1.cup 	config -state $d
	$g.btns1.cdn 	config -state $d

 	$g.help.quit	config -state $d

	bind $pdc(can) <ButtonRelease-1> 		{}
	bind $pdc(can) <ButtonPress-1> 			{}
	bind $pdc(can) <B1-Motion> 				{}
	bind $pdc(can) <Control-ButtonPress-1> 	{}
	bind $pdc(can) <Shift-ButtonPress-1> 	{}
	bind $pdc(can) <Control-Command-ButtonRelease-1> 		{}


	if {$pdisplay_hlp_actv} {
		bind $pdc(can) <ButtonRelease-1> {PdH Canvas}
	}

	set pdisplay_actv 0
	PutHelpInPassiveMode $w
	$g.help.con config -command "ReactivatePdisplay $w"
}	

proc ReactivatePdisplay {w} {
	global pdisplay_actv pdisplay_hlp_actv pdw pdc pd_st
	set g $pdw
	set n "normal"

	set indx 0
	foreach st $pd_st {
		switch -exact -- $indx {
			0	{$g.btns1.cur config -state $st}
			1	{$g.btns1.cup config -state $st}
			2	{$g.btns1.cdn config -state $st}
		}
		incr indx
	}

	$g.btns0.toe 	config -state $n
	$g.btns0.tse 	config -state $n
	$g.btns0.tte 	config -state $n
	$g.btns0.up  	config -state $n
	$g.btns0.dn  	config -state $n
	$g.btns0.dis 	config -state $n
	$g.btns0.zoo 	config -state $n
	$g.btns0.str 	config -state $n
	$g.btns0x.qui 	config -state $n
	$g.btns1.smo 	config -state $n
	$g.btns1.ins 	config -state $n
	$g.btns1.tra 	config -state $n
	$g.btns1.tre 	config -state $n
	$g.btns1.tze 	config -state $n
	$g.btns1.tup 	config -state $n
	$g.btns1.tdn 	config -state $n
	$g.btns1.tup8	config -state $n
	$g.btns1.tdn8	config -state $n
	$g.btns0x.und 	config -state $n
	$g.btns0x.pla 	config -state $n
	$g.btns0x.res 	config -state $n
	$g.btns1x.app 	config -state $n
	$g.btns1x.sav 	config -state $n
	$g.btns1x.sae 	config -state $n
	$g.btns1.fla 	config -state $n
	$g.btns1.cav 	config -state $n
	$g.btns1.vex 	config -state $n
	

 	$g.help.quit config -state $n

	if {$pdisplay_hlp_actv} {
		bind $pdc(can) <ButtonRelease-1> 			{}
		bind $pdc(can) <ButtonRelease-1> 			{BoxDelete %W %x ; PdH Canvas}
	} else {
		bind $pdc(can) <ButtonRelease-1> 			{BoxDelete %W %x}
	}
	bind $pdc(can) <ButtonPress-1> 			{BoxBegin %W %x}
	bind $pdc(can) <B1-Motion> 				{BoxDrag %W %x}
	bind $pdc(can) <Control-ButtonPress-1> 	{LineMark %W %x}
	bind $pdc(can) <Shift-ButtonPress-1> 	{IpointMark %W %x %y}
	bind $pdc(can) <Control-Command-ButtonRelease-1> 		{LineWhere %W %x}

	set pdisplay_actv 1
	if {$pdisplay_hlp_actv} {
		PutHelpInActiveMode $w
	}
	$g.help.con config -command "DisablePdisplay $w"
}	

proc ActivatePdisplayHelp {} {
	global pdc pdw
	set g $pdw

	bind $g.btns0.tot <ButtonRelease-1> {PdH FinalBlokNo}
	bind $g.btns0.toe <ButtonRelease-1> {PdH FinalBlokNo}
	bind $g.btns0.tsh <ButtonRelease-1> {PdH BlokShown}
	bind $g.btns0.tse <ButtonRelease-1> {PdH BlokShown}
	bind $g.btns0.tts <ButtonRelease-1> {PdH BlokToShow}
	bind $g.btns0.tte <ButtonRelease-1> {PdH BlokToShow}
	bind $g.btns0.up  <ButtonRelease-1> {PdH IncBlok}
	bind $g.btns0.dn  <ButtonRelease-1> {PdH DecBlok}
	bind $g.btns0.dis <ButtonRelease-1> {PdH DisplayBlok}
	bind $g.btns0.zoo <ButtonRelease-1> {PdH DisplayZoom}
	bind $g.btns0.str <ButtonRelease-1> {PdH DisplayStretch}
	bind $g.btns0x.qui <ButtonRelease-1> {PdH Quit}
	bind $g.btns1.smo <ButtonRelease-1> {PdH Smooth}
	bind $g.btns1.ins <ButtonRelease-1> {PdH Insert}
	bind $g.btns1.tra <ButtonRelease-1> {PdH Transpose}
	bind $g.btns1.tre <ButtonRelease-1> {PdH Transpose}
	bind $g.btns1.sem <ButtonRelease-1> {PdH Transpose}
	bind $g.btns1.tze <ButtonRelease-1> {PdH Tranzero}
	bind $g.btns1.tup <ButtonRelease-1> {PdH Tranup}
	bind $g.btns1.tdn <ButtonRelease-1> {PdH TranDn}
	bind $g.btns1.tup8 <ButtonRelease-1> {PdH Tranup8}
	bind $g.btns1.tdn8 <ButtonRelease-1> {PdH Trandn8}
	bind $g.btns0x.und <ButtonRelease-1> {PdH Undo}
	bind $g.btns0x.pla <ButtonRelease-1> {PdH Pplay}
	bind $g.btns0x.res <ButtonRelease-1> {PdH Restart}
	bind $g.btns1x.bb2 <ButtonRelease-1> {PdH ModData}
	bind $g.btns1x.app <ButtonRelease-1> {PdH ApplyToData}
	bind $g.btns1x.sav <ButtonRelease-1> {PdH Save}
	bind $g.btns1x.sae <ButtonRelease-1> {PdH Outname}

	bind $g.btns1.fla <ButtonRelease-1> {PdH Flat}
	bind $g.btns1.cav <ButtonRelease-1> {PdH Concave}
	bind $g.btns1.vex <ButtonRelease-1> {PdH Convex}
	bind $g.btns1.cur <ButtonRelease-1> {PdH Curvature}
	bind $g.btns1.cup <ButtonRelease-1> {PdH Curvup}
	bind $g.btns1.cdn <ButtonRelease-1> {PdH Curvdn}
	bind $g.btns1.dum <ButtonRelease-1> {PdH Curvature}

	bind $g.btns0.dm1  <ButtonRelease-1> {PdH Wincnt}
	bind $g.btns0.dum1 <ButtonRelease-1> {PdH Wincnt}
	bind $g.btns0.dm2  <ButtonRelease-1> {PdH Time}
	bind $g.btns0.dum2 <ButtonRelease-1> {PdH Time}
	bind $g.btns0.dm3  <ButtonRelease-1> {PdH Sampcnt}
	bind $g.btns0.dum3 <ButtonRelease-1> {PdH Sampcnt}
	bind $g.btns0.dm4  <ButtonRelease-1> {PdH Midi}
	bind $g.btns0.dum4 <ButtonRelease-1> {PdH Midi}
	bind $g.btns0.dm5  <ButtonRelease-1> {PdH Pitch}
	bind $g.btns0.dum5 <ButtonRelease-1> {PdH Pitch}

	bind $g.help.quit <ButtonRelease-1> {PdH EndSession}

	bind $pdc(can) 	  <ButtonRelease-1> {PdH Canvas}
}	

proc PdH {subject} {
	global pdw
	set f $pdw.help.help

	switch -- $subject {

		FinalBlokNo {$f config -text "Indicates the number of the last block of data in the input file."}
		BlokShown 	{$f config -text "The number of the data block currently being displayed."}
		BlokToShow 	{$f config -text "Shows the number of the data block you want to look at next."}
		IncBlok 	{$f config -text "Increment the number of the data block you want to look at next."}
		DecBlok 	{$f config -text "Decrement the number of the data block you want to look at next."}
		DisplayBlok {$f config -text "Display the block of data, whose number you have selected"}
		DisplayZoom {$f config -text "Magnify the pitch information to fill the display, or return to normal display."}
		DisplayStretch {$f config -text "Stretch the time information to fill the whole display, or return to normal."}
		ModifyDisplay {$f config -text "Operations which modify the data display (but not the data)."}
		Smooth 		{$f config -text "Smooth the pitch contour display in the area highlighted with the mouse."}
		Insert 		{$f config -text "Insert new pitch-point at marked point (Shift Mouse-Click), between edges of highlighted area."}
		Transpose 	{$f config -text "Transpose part of data display highlighted with mouse, by the number of semitones indicated."}
		Undo 		{$f config -text "Undo the previous display-altering action."}
		Pplay 		{$f config -text "Play pitch line : To play a contour you have CHANGED on the screen, you must press APPLY first."}
		Restart 	{$f config -text "Go back to the original   display of data (or the data after the last APPLY operation)."}
		ModData 	{$f config -text "Operations which modify the pitch data itself."}
		ApplyToData {$f config -text "Retain contour shown on display as the real pitch data. (It is NOT yet saved to file)"}
		Save 		{$f config -text "Save the pitch data to an output file."}
		Outname 	{$f config -text "Specify a name for the output pitchdata file, and exit."}
		Canvas 		{$f config -text "Display pitch contour of (part of) your pitch data. Highlight region with mousedrag, to modify."}
		Quit 		{$f config -text "Abandon pitch display, WITHOUT SAVING NEW DATA, and return to workspace."}
		EndSession	{$f config -text "Abandon the Sound Loom Session."}
		Flat		{$f config -text "Smooth using a linear pitch movement."}
		Concave		{$f config -text "Use a concave pitch slope, flatter at the top, or rounded at the cusp."}
		Convex		{$f config -text "For smoothing, use a convex pitch slope, steeper at the top, or pointed at the cusp."}
		Curvature	{$f config -text "The curvature for Convex or Concave smoothing curves. 1 = flat. Larger values curve more."}
		Curvup		{$f config -text "Increase the curvature of the smoothing curve."}
		Curvdn		{$f config -text "Reduce the curvature of the smoothing curve."}
		Tranzero	{$f config -text "Zero the transposition counter."}
		Tranup		{$f config -text "Increase transposition value by a semitone."}
		TranDn		{$f config -text "Lower transposition value by a semitone."}
		Tranup8		{$f config -text "Increase the transposition value by an octave."}
		Trandn8		{$f config -text "Reduce the transposition value by an octave."}
		Wincnt		{$f config -text "Window number in data, at cursor, with Control-Command-Mouseclick."}
		Time		{$f config -text "Time in data, at cursor, with Control-Command-Mouseclick."}
		Sampcnt		{$f config -text "Corresponding sample-count in source SOUND data, at cursor, with Control-Command-Mouseclick."}
		Midi		{$f config -text "Midi value in data, at cursor, with Control-Command-Mouseclick."}
		Pitch		{$f config -text "Approx pitch corresponding to MIDI value at cursor, with Control-Command-Mouseclick."}
		default {
			ErrShow "Unknown option in PdH"
		}
	}
}

proc DisablePdisplayHelp {w} {
	global pdisplay_actv pdisplay_hlp_actv pdc pdw
	set g $pdw

	bind $g.help.quit <ButtonRelease-1> {}

	bind $g.btns0.tot <ButtonRelease-1> {}
	bind $g.btns0.toe <ButtonRelease-1> {}
	bind $g.btns0.tsh <ButtonRelease-1> {}
	bind $g.btns0.tse <ButtonRelease-1> {}
	bind $g.btns0.tts <ButtonRelease-1> {}
	bind $g.btns0.tte <ButtonRelease-1> {}
	bind $g.btns0.up  <ButtonRelease-1> {}
	bind $g.btns0.dn  <ButtonRelease-1> {}
	bind $g.btns0.dis <ButtonRelease-1> {}
	bind $g.btns0.zoo <ButtonRelease-1> {}
	bind $g.btns0.str <ButtonRelease-1> {}
	bind $g.btns0x.qui <ButtonRelease-1> {}
	bind $g.btns1.smo <ButtonRelease-1> {}
	bind $g.btns1.ins <ButtonRelease-1> {}
	bind $g.btns1.tra <ButtonRelease-1> {}
	bind $g.btns1.tre <ButtonRelease-1> {}
	bind $g.btns1.sem <ButtonRelease-1> {}
	bind $g.btns1.tze <ButtonRelease-1> {}
	bind $g.btns1.tup <ButtonRelease-1> {}
	bind $g.btns1.tdn <ButtonRelease-1> {}
	bind $g.btns1.tup8 <ButtonRelease-1> {}
	bind $g.btns1.tdn8 <ButtonRelease-1> {}
	bind $g.btns0x.und <ButtonRelease-1> {}
	bind $g.btns0x.pla <ButtonRelease-1> {}
	bind $g.btns0x.res <ButtonRelease-1> {}
	bind $g.btns1x.bb2 <ButtonRelease-1> {}
	bind $g.btns1x.app <ButtonRelease-1> {}
	bind $g.btns1x.sav <ButtonRelease-1> {}
	bind $g.btns1x.sae <ButtonRelease-1> {}

	bind $g.btns1.fla <ButtonRelease-1> {}
	bind $g.btns1.cav <ButtonRelease-1> {}
	bind $g.btns1.vex <ButtonRelease-1> {}
	bind $g.btns1.cur <ButtonRelease-1> {}
	bind $g.btns1.cup <ButtonRelease-1> {}
	bind $g.btns1.cdn <ButtonRelease-1> {}
	bind $g.btns1.dum <ButtonRelease-1> {}

	bind $g.btns0.dm1  <ButtonRelease-1> {}
	bind $g.btns0.dum1 <ButtonRelease-1> {}
	bind $g.btns0.dm2  <ButtonRelease-1> {}
	bind $g.btns0.dum2 <ButtonRelease-1> {}
	bind $g.btns0.dm3  <ButtonRelease-1> {}
	bind $g.btns0.dum3 <ButtonRelease-1> {}
	bind $g.btns0.dm4  <ButtonRelease-1> {}
	bind $g.btns0.dum4 <ButtonRelease-1> {}
	bind $g.btns0.dm5  <ButtonRelease-1> {}
	bind $g.btns0.dum5 <ButtonRelease-1> {}
	bind $pdc(can) 	  <ButtonRelease-1> {}

	set pdisplay_hlp_actv 0

	if {$pdisplay_actv} {
		bind $pdc(can) <ButtonRelease-1> {BoxDelete %W %x}
	} else {
		ReactivatePdisplay $w
	}
	DisableHelp $w
}	

proc MacActiveHelp {active w} {
	if {$active} {
		$w config -text "Buttons: active + Help display ~~~ Menubuttons: active,  help display on long mouse press"
	} else {
		switch -- $w {
			.workspace.h -
			.workspace.c.canvas.f.h {
				$w config -bg [option get . activeBackground {}] -text "WINDOW INACTIVE: click any item on screen, or Testbed menu items, to see Help info here"
			}
			default {
				$w config -bg [option get . activeBackground {}] -text "WINDOW INACTIVE: click any item on screen to see Help info here"
			}
		}
	}
}

# 1 	DO IT AGAIN
# 2 	------------
# 3 	
# 4 	------------
# 5 	MUSIC FACILITIES
# 6 	------------
# 7 	BACKGROUND LISTINGS
# 8 	------------
# 9 	CLEANING KIT
# 10	------------
# 11	ENVELOPES
# 12	------------
# 13	FEATURE EXTRACTION
# 14	------------
# 15	FOFS
# 16	------------
# 17	HARMONY
# 18	------------
# 19	INTERP
# 20	------------
# 21	NAME GAMES
# 22	------------
# 23	PARTITION
# 24	------------
# 25	PITCH
# 26	------------
# 27	PITCH TEMPERED
# 28	------------
# 29	PITCH VARIBANK
# 30	------------
# 31	PITCH MARKS
# 32	------------
# 33	PITCH SEQUENCE MARKS
# 34	------------
# 35	PROPERTIES
# 36	------------
# 37	RHYTHM AND TIME
# 38	------------
# 49	SKETCH SCORE
# 40	------------
# 41	SPACE DESIGN
# 42	------------
# 43	TEXT
# 44	------------
# 45	TIMELINE



proc SetupTestbedHelp {} {
	global tbhelp released ww evv
	$ww.1.a.mez.bkgd config -menu $ww.1.a.mez.bkgd.help  -background $evv(HELP)
	if {![info exists tbhelp]} {
		set mfhelp [menu $ww.1.a.mez.bkgd.help -tearoff 0]
		$mfhelp add cascade -label "DO IT AGAIN" -command {MbH again} -background $evv(HELP)
		$mfhelp add separator
		$mfhelp add cascade -label "" -command {MbH againagain}
		$mfhelp add separator
		$mfhelp add cascade -label "MUSIC FACILITIES" -command {} -background $evv(HELP)
		$mfhelp add separator
		$mfhelp add cascade -label "Background Listings" -command {MbH envelopes}
		if {[info exists released(specnu)]} {
			$mfhelp add cascade -label "Cleaning Kit" -command {MbH cleaning}
		}
		$mfhelp add cascade -label "Envelopes" -command {MbH envelopes}
		if {[info exists released(features)]} {
			$mfhelp add command -label "Feature Extraction" -command {MbH features}
		}
		if {[info exists released(fofex)]} {
			$mfhelp add cascade -label "Fof Reconstruction" -command {MbH fofs}
		}
		$mfhelp add cascade -label "Harmony Workshop" -command {MbH harmony}
		$mfhelp add command -label "Interpolation Workshop" -command {MbH interp}
		$mfhelp add cascade -label "Name Games"   -command {MbH names}
		$mfhelp add cascade -label "Partition Soundfiles" -command {MbH partition}
		$mfhelp add cascade -label "Pitch Data Operations" -command {MbH pitchdata}
		$mfhelp add cascade -label "Pitch Data (Tempered) Operations" -command {MbH tempered}
		$mfhelp add cascade -label "Pitch Data (Varibank Filter) Operations" -command {MbH varibank}
		$mfhelp add cascade -label "Pitch Marks (Harmonic Field)" -command {MbH pmarks}
		$mfhelp add cascade -label "Pitch Sequence Markers (Melodic Line)" -command {MbH seqmarks}
		$mfhelp add cascade -label "Properties Files" -command {MbH props}
		$mfhelp add cascade -label "Rhythm And Time Operations" -command {MbH rhythm}
		$mfhelp add cascade -label "Sketch Score"  -command {MbH sketch}
		if {[info exists released(spacedesign)]} {
			$mfhelp add cascade -label "Space Design" -command {MbH space}
		}
		$mfhelp add cascade -label "Text Operations" -command {MbH text}
		$mfhelp add command -label "Timeline"   -command {MbH timeline}
		set tbhelp 1
	}
}

proc SilenceTestbedHelp {} {
	global ww musictestbed_established
	$ww.1.a.mez.bkgd config -menu $ww.1.a.mez.bkgd.menu -background [option get . background {}]
	if {![info exists musictestbed_established]} {
		set mfz [menu $ww.1.a.mez.bkgd.menu -tearoff 0]
		EstablishMusicTestbedMenu $mfz
	}
}

proc MbH {subject} {
	global ww
	set f $ww.h.help
	switch -- $subject {
		"again" {
			$f config -text "previous \"Testbed\" operation used, listed in box below, from where it can be quickly recalled."
		}
		"againagain" {
			$f config -text "Previous \"Testbed\" operation used, is listed here, from where it can be quickly recalled."
		}
		"background" {
			$f config -text "Store set of (backed-up) sounds in a named list, and recall or modify later."
		}
		"cleaning" {
			$f config -text "Clean sound source in detailed manner."
		}
		"envelopes" {
			$f config -text "Special operations on loudness envelopes of sounds."
		}
		"features" {
			$f config -text "Extract spectral-peak features of sound from analysis file."
		}
		"fofs" {
			$f config -text "Extract the FOFs in a sound: and use them to synthesize the pitch-contour."
		}
		"harmony" {
			$f config -text "Experiment with tonal or non-tonal harmonic fields."
		}
		"interp" {
			$f config -text "Interpolate between two sounds (by weighted mixing) in a detailed manner."
		}
		"names" {
			$f config -text "Modify and swap tags on filenames."
		}
		"partition" {
			$f config -text "Listen to sounds and partition them to different \"orchestra\" bins."
		}
		"pitchdata" {
			$f config -text "Extract, smooth and use pitchdata : Convert between pitchdata formats."
		}
		"tempered" {
			$f config -text "Associate tempered pitchline with sound : modify or extract specific pitches in sounds."
		}
		"varibank" {
			$f config -text "Derive varibank midi filter data from other data : Derive new varibank filters from original."
		}
		"pmarks" {
			$f config -text "Assign pitchmarks to sndfiles : compare and select sounds according to pitchmarks."
		}
		"seqmarks" {
			$f config -text "Assign melody descriptors to sndfiles : compare and select sounds according to descriptors."
		}
		"props" {
			$f config -text "Assign any number of (user defined) properties to sounds. Compare and select sounds by properties."
		}
		"rhythm" {
			$f config -text "Extract and synchronise rhythms of sounds : create or amplify accents : etc."
		}
		"sketch" {
			$f config -text "Arrange sounds on a rough score and test sequences of events."
		}
		"space" {
			$f config -text "Design the spatial trajectories of sounds."
		}
		"spec" {
			$f config -text "Display average spectrum (e.g. see formants)."
		}
		"text" {
			$f config -text "Sort texts, find rhymes etc."
		}
		"timeline" {
			$f config -text "Arrange sounds on a timeline, listen to the sequence and create equivalent mixfiles."
		}
	}
}

#------ HELP INFORMATION FOR THE QIKEDIT PAGE

proc DisableQikedit {qe} {
	global qikedit_actv qikedit_hlp_actv longqik evv mixd2 zobo mm_multichan

	set d "disabled"

	$mixd2.1.u.gp		config -state $d
	$mixd2.1.u.ii		config -state $d
	$mixd2.1.u.rs		config -state $d
	$mixd2.1.u.view	config -state $d
	$mixd2.1.u.getm	config -state $d
	$mixd2.1.u.get	config -state $d

	$mixd2.1.button.ok	config -state $d
	$mixd2.1.button.ed	config -state $d
	$mixd2.1.button.sk	config -state $d
	$mixd2.1.button.ag	config -state $d
	$mixd2.1.button.go	config -state $d
	$mixd2.1.button.ca	config -state $d
	$mixd2.1.button.re	config -state $d
	$mixd2.1.button.no	config -state $d
	$mixd2.1.button.aa	config -state $d

	$mixd2.1.see.00.stt	config -state $d
	$mixd2.1.see.00.end	config -state $d
	$mixd2.1.see.00.clc1	config -state $d
	$mixd2.1.see.00.clc2	config -state $d
	$mixd2.1.see.00.seel	config -state $d
	$mixd2.1.see.00.atten	config -state $d

	$mixd2.1.see.00x.clc1	config -state $d
	$mixd2.1.see.00x.clc2	config -state $d
	$mixd2.1.see.00x.stt	config -state $d
	$mixd2.1.see.00x.end	config -state $d
	$mixd2.1.see.00x.gai	config -state $d
	$mixd2.1.see.00x.gnw	config -state $d

	$mixd2.1.see.000.frm	config -state $d
	$mixd2.1.see.000.tap	config -state $d
	$mixd2.1.see.000.mm	config -state $d
	$mixd2.1.see.000.mev	config -state $d
	$mixd2.1.see.000.ll2	config -state $d
	$mixd2.1.see.000.dft	config -state $d

	bind $mixd2.1.see.1.seefile.list <ButtonRelease-1> {}

	$mixd2.1.see.1.foot.b		config -state $d
	$mixd2.1.see.1.foot.n		config -state $d
	$mixd2.1.see.1.foot.rr	config -state $d

	$mixd2.1.see.1.foot2.ss config -state $d
	$mixd2.1.see.1.foot2.mx config -state $d
	$mixd2.1.see.1.foot2.mq config -state $d
	$mixd2.1.see.1.foot2.vv config -state $d
	$mixd2.1.see.1.foot2.qq config -state $d

	$mixd2.1.see.1.foot2.pp config -state $d
	$mixd2.1.see.1.foot2.cc config -state $d

	$mixd2.2.3.1.mb	config -state $d
	$mixd2.2.3.1.mbb	config -state $d
	$mixd2.2.3.1.mt	config -state $d
	$mixd2.2.3.1.mtx	config -state $d
	$mixd2.2.3.1.mt2	config -state $d
	$mixd2.2.3.1.mz	config -state $d
	$mixd2.2.3.1.st	config -state $d
	$mixd2.2.3.1.ov	config -state $d
	$mixd2.2.3.1.ex	config -state $d
	$mixd2.2.3.1.ey	config -state $d
	$mixd2.2.3.1.ez	config -state $d
	$mixd2.2.3.1.tg	config -state $d
	$mixd2.2.3.1.qu	config -state $d
	$mixd2.2.3.1.wt	config -state $d
	$mixd2.2.3.1.ww	config -state $d
	
	if {$longqik} {
		$mixd2.2.t	config -state $d
		$mixd2.2.v	config -state $d

		$mixd2.2.3.1.ee config -state $d
		$mixd2.2.3.1.es config -state $d
		$mixd2.2.3.1.rt config -state $d
		$mixd2.2.3.1.lu config -state $d
		$mixd2.2.3.1.sm config -state $d
		$mixd2.2.3.1.so config -state $d
		$mixd2.2.3.1.ye config -state $d
		$mixd2.2.3.1.zr config -state $d
		$mixd2.2.3.1.gr config -state $d
		$mixd2.2.3.1.gg config -state $d
		$mixd2.2.3.1.xa config -state $d
		$mixd2.2.3.1.xc config -state $d

		$mixd2.2.3.2.po config -state $d
		$mixd2.2.3.2.op config -state $d
		$mixd2.2.3.2.sp config -state $d
		$mixd2.2.3.2.fl config -state $d
		$mixd2.2.3.2.sc config -state $d
		$mixd2.2.3.2.sw config -state $d
		$mixd2.2.3.2.sk config -state $d
		$mixd2.2.3.2.mi config -state $d
		if {$mm_multichan} {
			$mixd2.2.3.2.zq config -state $d
			$mixd2.2.3.2.tw config -state $d
			$mixd2.2.3.2.ge config -state $d
		}
		$mixd2.2.3.2.rf config -state $d
		$mixd2.2.3.2.sf config -state $d
		$mixd2.2.3.2.sn config -state $d
		$mixd2.2.3.2.wf config -state $d
		$mixd2.2.3.2.du config -state $d
		$mixd2.2.3.2.ds config -state $d
		$mixd2.2.3.2.nf config -state $d
		$mixd2.2.3.2.cf config -state $d
		$mixd2.2.3.2.lf config -state $d
		$mixd2.2.3.2.ce config -state $d
		$mixd2.2.3.2.cm config -state $d
		$mixd2.2.3.2.nw config -state $d
		$mixd2.2.3.2.nl config -state $d
		$mixd2.2.3.2.nm config -state $d
		$mixd2.2.3.2.si config -state $d
		$mixd2.2.3.2.dd config -state $d
		$mixd2.2.3.2.wi config -state $d

		$mixd2.2.3.3.ab config -state $d
		$mixd2.2.3.3.sl config -state $d
		$mixd2.2.3.3.ss config -state $d
		$mixd2.2.3.3.vv config -state $d
		$mixd2.2.3.3.mm config -state $d
		$mixd2.2.3.3.nn config -state $d
		$mixd2.2.3.3.ua config -state $d
		$mixd2.2.3.3.pm config -state $d
		$mixd2.2.3.3.h1 config -state $d
		$mixd2.2.3.3.fm config -state $d
		$mixd2.2.3.3.r1 config -state $d
		$mixd2.2.3.3.rc config -state $d
		$mixd2.2.3.3.om config -state $d
		$mixd2.2.3.3.mh config -state $d
		$mixd2.2.3.3.mf config -state $d
		$mixd2.2.3.3.rv config -state $d
		$mixd2.2.3.3.mk config -state $d
		$mixd2.2.3.3.ck config -state $d
		$mixd2.2.3.3.ko config -state $d
		$mixd2.2.3.3.sy config -state $d
		set zobo [$mixd2.2.3.3.co cget -state]
		$mixd2.2.3.3.co config -state $d
		$mixd2.2.3.3.ij config -state $d
		$mixd2.2.3.3.sj config -state $d
		$mixd2.2.3.3.sz config -state $d

	} else {
		$mixd2.2.hhh.t	config -state $d
		$mixd2.2.hhh.v	config -state $d

		$mixd2.2.3.1.rt config -state $d
		$mixd2.2.3.1.gr config -state $d
		$mixd2.2.3.1.gg config -state $d
		$mixd2.2.3.1.xa config -state $d
		$mixd2.2.3.1.xc config -state $d

		$mixd2.2.3.2.ee config -state $d
		$mixd2.2.3.2.es config -state $d
		$mixd2.2.3.2.lu config -state $d
		$mixd2.2.3.2.sm config -state $d
		$mixd2.2.3.2.so config -state $d
		$mixd2.2.3.2.ye config -state $d
		$mixd2.2.3.2.zr config -state $d
		$mixd2.2.3.2.po config -state $d
		$mixd2.2.3.2.op config -state $d
		$mixd2.2.3.2.sp config -state $d
		$mixd2.2.3.2.fl config -state $d
		$mixd2.2.3.2.sc config -state $d
		$mixd2.2.3.2.sw config -state $d
		$mixd2.2.3.2.sk config -state $d
		$mixd2.2.3.2.mi config -state $d
		if {$mm_multichan} {
			$mixd2.2.3.2.zq config -state $d
			$mixd2.2.3.2.tw config -state $d
			$mixd2.2.3.2.ge config -state $d
		}
		$mixd2.2.3.2.om config -state $d
		$mixd2.2.3.2.mh config -state $d
		$mixd2.2.3.3.mf config -state $d
		$mixd2.2.3.4.rv config -state $d

		$mixd2.2.3.3.rf config -state $d
		$mixd2.2.3.3.sf config -state $d
		$mixd2.2.3.3.sn config -state $d
		$mixd2.2.3.3.wf config -state $d
		$mixd2.2.3.3.du config -state $d
		$mixd2.2.3.3.ds config -state $d
		$mixd2.2.3.3.nf config -state $d
		$mixd2.2.3.3.cf config -state $d
		$mixd2.2.3.3.lf config -state $d
		$mixd2.2.3.3.ce config -state $d
		$mixd2.2.3.3.cm config -state $d
		$mixd2.2.3.3.nw config -state $d
		$mixd2.2.3.3.nl config -state $d
		$mixd2.2.3.3.nm config -state $d
		$mixd2.2.3.3.si config -state $d
		$mixd2.2.3.3.dd config -state $d
		$mixd2.2.3.3.wi config -state $d
		$mixd2.2.3.3.sy config -state $d
		set zobo [$mixd2.2.3.3.co cget -state]
		$mixd2.2.3.3.co config -state $d

		$mixd2.2.3.4.ab config -state $d
		$mixd2.2.3.4.sl config -state $d
		$mixd2.2.3.4.ss config -state $d
		$mixd2.2.3.4.vv config -state $d
		$mixd2.2.3.4.mm config -state $d
		$mixd2.2.3.4.nn config -state $d
		$mixd2.2.3.4.ua config -state $d
		$mixd2.2.3.4.pm config -state $d
		$mixd2.2.3.4.h1 config -state $d
		$mixd2.2.3.4.fm config -state $d
		$mixd2.2.3.4.r1 config -state $d
		$mixd2.2.3.4.rc config -state $d
		$mixd2.2.3.4.mk config -state $d
		$mixd2.2.3.4.ck config -state $d
		$mixd2.2.3.4.ko config -state $d
		$mixd2.2.3.4.ij config -state $d
		$mixd2.2.3.4.sj config -state $d
		$mixd2.2.3.4.sz config -state $d
	}
	
	bind $mixd2.1.see.1.seefile <Control-Key-p> {}
	bind $mixd2.1.see.1.seefile <Control-Key-P> {}
	bind $mixd2.1.see.1.seefile <Key-space>	  {}
	bind $mixd2.1.see.1.seefile <Control-Up>    {}
	bind $mixd2.1.see.1.seefile <Control-Down>  {}
	bind $mixd2.1.see.1.seefile <Control-Left>  {}
	bind $mixd2.1.see.1.seefile <Control-Right> {}
	bind $mixd2.1.see.1.seefile <Control-Key-D> {}
	bind $mixd2.1.see.1.seefile <Control-Key-d> {}
	bind $mixd2.1.see.1.seefile <Control-Home>  {}
	bind $mixd2.1.see.1.seefile <Control-End>   {}
	bind $mixd2.1.see.1.seefile <Control-Key-t> {}
	bind $mixd2.1.see.1.seefile <Control-Key-T> {}
	bind $mixd2.1.see.1.seefile.list <Double-1> {}
	if {$longqik} {
		bind $mixd2.2.v			  <Control-Up>    {}
		bind $mixd2.2.v			  <Control-Down>  {}
		bind $mixd2.2.v			  <Control-Left>  {}
		bind $mixd2.2.v			  <Control-Right> {}
	} else {
		bind $mixd2.2.hhh.v		  <Control-Up>    {}
		bind $mixd2.2.hhh.v		  <Control-Down>  {}
		bind $mixd2.2.hhh.v		  <Control-Left>  {}
		bind $mixd2.2.hhh.v		  <Control-Right> {}
	}
	set qikedit_actv 0
	PutHelpInPassiveMode $qe
	$qe.con config -command "ReactivateQikedit $qe"
}

proc ActivateQikeditHelp {} {
	global qikedit_actv qikedit_hlp_actv longqik evv mixd2 mm_multichan

	set d "disabled"

	bind $mixd2.1.u.gp		<ButtonRelease-1> {Qked PreviousState}
	bind $mixd2.1.u.ii		<ButtonRelease-1> {Qked InitialState}
	bind $mixd2.1.u.rs		<ButtonRelease-1> {Qked RestoreOrig	}
	bind $mixd2.1.u.view	<ButtonRelease-1> {Qked ViewSound}
	bind $mixd2.1.u.getm	<ButtonRelease-1> {Qked SndsToSubmix}
	bind $mixd2.1.u.get	<ButtonRelease-1> {Qked SndToWkspace}

	bind $mixd2.1.button.ok	<ButtonRelease-1> {Qked Abandon}
	bind $mixd2.1.button.ed	<ButtonRelease-1> {Qked SaveEdited}
	bind $mixd2.1.button.sk	<ButtonRelease-1> {Qked Search}
	bind $mixd2.1.button.ag	<ButtonRelease-1> {Qked SearchAgain}
	bind $mixd2.1.button.go	<ButtonRelease-1> {Qked GotoTime}
	bind $mixd2.1.button.ca	<ButtonRelease-1> {Qked Calculator}
	bind $mixd2.1.button.re	<ButtonRelease-1> {Qked RefVals}
	bind $mixd2.1.button.no	<ButtonRelease-1> {Qked Notebook}
	bind $mixd2.1.button.aa	<ButtonRelease-1> {Qked ConcertA}

	bind $mixd2.1.see.00.stt	<ButtonRelease-1> {Qked LineTimeToMixStartParam}
	bind $mixd2.1.see.00.end	<ButtonRelease-1> {Qked LineTimeToMixEndParam}
	bind $mixd2.1.see.00.clc1	<ButtonRelease-1> {Qked LineTimeToCalc}
	bind $mixd2.1.see.00.clc2	<ButtonRelease-1> {Qked LineTimeToCalcStore}
	if {[string length [$mixd2.1.see.00.seel cget -text]] > 0} {
		bind $mixd2.1.see.00.seel <ButtonRelease-1> {Qked InchanLevels}
	}
	if {[string length [$mixd2.1.see.00.atten cget -text]] > 0} {
		bind $mixd2.1.see.00.atten <ButtonRelease-1> {Qked ChannelAttenuators}
	}

	bind $mixd2.1.see.00x.clc1	<ButtonRelease-1> {Qked ValToCalc}
	bind $mixd2.1.see.00x.clc2	<ButtonRelease-1> {Qked ValToCalcStore}
	bind $mixd2.1.see.00x.stt	<ButtonRelease-1> {Qked ValToMixStartParam}
	bind $mixd2.1.see.00x.end	<ButtonRelease-1> {Qked ValToMixEndParam}
	bind $mixd2.1.see.00x.gai	<ButtonRelease-1> {Qked ValToMixGain}
	bind $mixd2.1.see.00x.gan	<ButtonRelease-1> {Qked MixGain}
	bind $mixd2.1.see.00x.gnw	<ButtonRelease-1> {Qked UnityGain}

	bind $mixd2.1.see.000.frm	<ButtonRelease-1> {Qked GetParamsInLine}
	bind $mixd2.1.see.000.tap	<ButtonRelease-1> {Qked TapTime}
	bind $mixd2.1.see.000.mm	<ButtonRelease-1> {Qked MM}
	bind $mixd2.1.see.000.mev	<ButtonRelease-1> {Qked EndTimes}
	bind $mixd2.1.see.000.ll2	<ButtonRelease-1> {Qked Selections}
	bind $mixd2.1.see.000.dft	<ButtonRelease-1> {Qked DoWholeMix}

	bind $mixd2.1.see.1.seefile.list <ButtonRelease-1> {}
	bind $mixd2.1.see.1.seefile.list <ButtonRelease-1> {Qked QikEditListing}

	bind $mixd2.1.see.1.foot.b		<ButtonRelease-1> {Qked CopyWithNewMixName}
	bind $mixd2.1.see.1.foot.n		<ButtonRelease-1> {Qked NewMixName}
	bind $mixd2.1.see.1.foot.rr	<ButtonRelease-1> {Qked RecallMixVersion}

	bind $mixd2.1.see.1.foot2.ss <ButtonRelease-1> {Qked SaveAndMix}
	bind $mixd2.1.see.1.foot2.mx <ButtonRelease-1> {Qked MaxSamp}
	bind $mixd2.1.see.1.foot2.mq <ButtonRelease-1> {Qked MaxChan}
	bind $mixd2.1.see.1.foot2.vv <ButtonRelease-1> {Qked ViewMixOutput}
	bind $mixd2.1.see.1.foot2.qq <ButtonRelease-1> {Qked KeepMixOutput}

	bind $mixd2.1.see.1.foot2.pp <ButtonRelease-1> {Qked PlaySound}
	bind $mixd2.1.see.1.foot2.cc <ButtonRelease-1> {Qked PlayChan}

	bind $mixd2.2.3.1.mb	<ButtonRelease-1> {Qked MoveTimeFwds}
	bind $mixd2.2.3.1.mbb	<ButtonRelease-1> {Qked MoveTimesBkwds}
	bind $mixd2.2.3.1.mt	<ButtonRelease-1> {Qked MoveTimesTo}
	bind $mixd2.2.3.1.mtx	<ButtonRelease-1> {Qked XpndTimesAt}
	bind $mixd2.2.3.1.mt2	<ButtonRelease-1> {Qked MoveStartTo}
	bind $mixd2.2.3.1.mz	<ButtonRelease-1> {Qked SetMixtartToZero}
	bind $mixd2.2.3.1.st	<ButtonRelease-1> {Qked SortTimeOrder}
	bind $mixd2.2.3.1.ov	<ButtonRelease-1> {Qked OverlapTimesBy}
	bind $mixd2.2.3.1.ex	<ButtonRelease-1> {Qked StretchTimeBy}
	bind $mixd2.2.3.1.ey	<ButtonRelease-1> {Qked StretchStepsBy}
	bind $mixd2.2.3.1.ez	<ButtonRelease-1> {Qked SetStepsTo}
	bind $mixd2.2.3.1.tg	<ButtonRelease-1> {Qked Stagger}
	bind $mixd2.2.3.1.qu	<ButtonRelease-1> {Qked QuantiseTimesTo}
	bind $mixd2.2.3.1.wt	<ButtonRelease-1> {Qked ShakeTimesBy}
	bind $mixd2.2.3.1.ww	<ButtonRelease-1> {Qked ShakeTimesWithin}

	if {$longqik} {
		bind $mixd2.2.t		<ButtonRelease-1> {Qked TemporaryChange}
		bind $mixd2.2.v		<ButtonRelease-1> {Qked Value}

		set ee  $mixd2.2.3.1.ee
		set es  $mixd2.2.3.1.es
		set rt	$mixd2.2.3.1.rt
		set lu	$mixd2.2.3.1.lu
		set sm  $mixd2.2.3.1.sm 
		set so  $mixd2.2.3.1.so 
		set ye  $mixd2.2.3.1.ye 
		set zr  $mixd2.2.3.1.zr
		set gr	$mixd2.2.3.1.gr
		set gg	$mixd2.2.3.1.gg
		set xa	$mixd2.2.3.1.xa
		set xc	$mixd2.2.3.1.xc

		set po	$mixd2.2.3.2.po
		set op	$mixd2.2.3.2.op
		set sp	$mixd2.2.3.2.sp
		set fl	$mixd2.2.3.2.fl
		set sc	$mixd2.2.3.2.sc
		set sw	$mixd2.2.3.2.sw
		set sk	$mixd2.2.3.2.sk
		set mi	$mixd2.2.3.2.mi
		if {$mm_multichan} {
			set zq	$mixd2.2.3.2.zq
			set tw	$mixd2.2.3.2.tw
			set ge	$mixd2.2.3.2.ge
		}
		set rf	$mixd2.2.3.2.rf
		set sf	$mixd2.2.3.2.sf
		set sn	$mixd2.2.3.2.sn
		set wf	$mixd2.2.3.2.wf
		set du	$mixd2.2.3.2.du
		set ds	$mixd2.2.3.2.ds
		set nf	$mixd2.2.3.2.nf
		set cf	$mixd2.2.3.2.cf
		set lf	$mixd2.2.3.2.lf
		set ce	$mixd2.2.3.2.ce
		set cm	$mixd2.2.3.2.cm
		set nw	$mixd2.2.3.2.nw
		set nl	$mixd2.2.3.2.nl
		set nm	$mixd2.2.3.2.nm
		set si	$mixd2.2.3.2.si
		set dd	$mixd2.2.3.2.dd
		set wi	$mixd2.2.3.2.wi

		set ab	$mixd2.2.3.3.ab
		set sl	$mixd2.2.3.3.sl
		set ss	$mixd2.2.3.3.ss
		set vv	$mixd2.2.3.3.vv
		set mm	$mixd2.2.3.3.mm
		set nn	$mixd2.2.3.3.nn
		set ua	$mixd2.2.3.3.ua
		set pm	$mixd2.2.3.3.pm
		set h1	$mixd2.2.3.3.h1
		set fm	$mixd2.2.3.3.fm
		set r1	$mixd2.2.3.3.r1
		set rc	$mixd2.2.3.3.rc
		set om	$mixd2.2.3.3.om
		set mh	$mixd2.2.3.3.mh
		set mf	$mixd2.2.3.3.mf
		set rv	$mixd2.2.3.3.rv
		set mk	$mixd2.2.3.3.mk
		set ck	$mixd2.2.3.3.ck
		set ko	$mixd2.2.3.3.ko
		set sy	$mixd2.2.3.3.sy
		set co	$mixd2.2.3.3.co
		set ij  $mixd2.2.3.3.ij
		set sj  $mixd2.2.3.3.sj
		set sz  $mixd2.2.3.3.sz
	} else {
		bind $mixd2.2.hhh.t			<ButtonRelease-1> {Qked TemporaryChange}
		bind $mixd2.2.hhh.v			<ButtonRelease-1> {Qked Value}

		set rt	$mixd2.2.3.1.rt
		set gr	$mixd2.2.3.1.gr
		set gg	$mixd2.2.3.1.gg
		set xa	$mixd2.2.3.1.xa
		set xc	$mixd2.2.3.1.xc

		set ee	$mixd2.2.3.2.ee
		set es	$mixd2.2.3.2.es
		set lu	$mixd2.2.3.2.lu
		set sm  $mixd2.2.3.2.sm 
		set so  $mixd2.2.3.2.so 
		set ye  $mixd2.2.3.2.ye 
		set zr  $mixd2.2.3.2.zr
		set po	$mixd2.2.3.2.po
		set op	$mixd2.2.3.2.op
		set sp	$mixd2.2.3.2.sp
		set fl	$mixd2.2.3.2.fl
		set sc	$mixd2.2.3.2.sc
		set sw	$mixd2.2.3.2.sw
		set sk	$mixd2.2.3.2.sk
		set mi	$mixd2.2.3.2.mi
		if {$mm_multichan} {
			set zq	$mixd2.2.3.2.zq
			set tw	$mixd2.2.3.2.tw
			set ge	$mixd2.2.3.2.ge
		}
		set om	$mixd2.2.3.2.om
		set mh	$mixd2.2.3.2.mh
		set mf	$mixd2.2.3.3.mf
		set rv	$mixd2.2.3.4.rv

		set rf	$mixd2.2.3.3.rf
		set sf	$mixd2.2.3.3.sf
		set sn	$mixd2.2.3.3.sn
		set wf	$mixd2.2.3.3.wf
		set du	$mixd2.2.3.3.du
		set ds	$mixd2.2.3.3.ds
		set nf	$mixd2.2.3.3.nf
		set cf	$mixd2.2.3.3.cf
		set lf	$mixd2.2.3.3.lf
		set ce	$mixd2.2.3.3.ce
		set cm	$mixd2.2.3.3.cm
		set nw	$mixd2.2.3.3.nw
		set nl	$mixd2.2.3.3.nl
		set nm	$mixd2.2.3.3.nm
		set si	$mixd2.2.3.3.si
		set dd	$mixd2.2.3.3.dd
		set wi	$mixd2.2.3.3.wi
		set sy	$mixd2.2.3.3.sy
		set co	$mixd2.2.3.3.co

		set ab	$mixd2.2.3.4.ab
		set sl	$mixd2.2.3.4.sl
		set ss	$mixd2.2.3.4.ss
		set vv	$mixd2.2.3.4.vv
		set mm	$mixd2.2.3.4.mm
		set nn	$mixd2.2.3.4.nn
		set ua	$mixd2.2.3.4.ua
		set pm	$mixd2.2.3.4.pm
		set h1	$mixd2.2.3.4.h1
		set fm	$mixd2.2.3.4.fm
		set r1	$mixd2.2.3.4.r1
		set rc	$mixd2.2.3.4.rc
		set mk	$mixd2.2.3.4.mk
		set ck	$mixd2.2.3.4.ck
		set ko	$mixd2.2.3.4.ko
		set ij  $mixd2.2.3.4.ij
		set sj  $mixd2.2.3.4.sj
		set sz  $mixd2.2.3.4.sz
	}
	bind $ee	<ButtonRelease-1> {Qked EndToEnd}
	bind $es	<ButtonRelease-1> {Qked StretchSilenceBy}
	bind $rt	<ButtonRelease-1> {Qked RetroTimePattern}
	bind $lu	<ButtonRelease-1> {Qked LineUpAtMarks}
	bind $sm	<ButtonRelease-1> {Qked SyncAtMarks}
	bind $so	<ButtonRelease-1> {Qked OffsetAtMarks}
	bind $ye	<ButtonRelease-1> {Qked SyncAtEnd}
	bind $zr	<ButtonRelease-1> {Qked ReplaceRetime}
	bind $gr	<ButtonRelease-1> {Qked CreateTimeGrid}
	bind $gg	<ButtonRelease-1> {Qked GetGridValue}
	bind $xa	<ButtonRelease-1> {Qked RoundAllTimes}
	bind $xc	<ButtonRelease-1> {Qked RoundSelected}
	bind $mk	<ButtonRelease-1> {Qked MakeClick}
	bind $ck	<ButtonRelease-1> {Qked MarkAsClick}
	bind $ko	<ButtonRelease-1> {Qked ClickOnOff}
	bind $sy	<ButtonRelease-1> {Qked Syntax}
	bind $co	<ButtonRelease-1> {Qked Collapse}
	bind $ij	<ButtonRelease-1> {Qked LevelStore}
	bind $sj	<ButtonRelease-1> {Qked LevelRestore}
	bind $sz	<ButtonRelease-1> {Qked AmpByMixLevel}
	bind $po	<ButtonRelease-1> {Qked SetPosition}
	bind $op	<ButtonRelease-1> {Qked Opposite}
	bind $sp	<ButtonRelease-1> {Qked SpreadPosition}
	bind $fl	<ButtonRelease-1> {Qked StepBetween}
	bind $sc	<ButtonRelease-1> {Qked ScatterPosition}
	bind $sw	<ButtonRelease-1> {Qked SwapPosition}
	bind $sk	<ButtonRelease-1> {Qked PermutePositions}
	bind $mi	<ButtonRelease-1> {Qked Mirror}
	if {$mm_multichan} {
		bind $zq	<ButtonRelease-1> {Qked ScatterPositions}
		bind $tw	<ButtonRelease-1> {Qked Twist}
		bind $ge	<ButtonRelease-1> {Qked Getpos}
	}
	bind $rf	<ButtonRelease-1> {Qked RetroFileOrder}
	bind $sf	<ButtonRelease-1> {Qked RandomiseOrder}
	bind $sn	<ButtonRelease-1> {Qked RandomiseNames}
	bind $wf	<ButtonRelease-1> {Qked SwapFiles}
	bind $du	<ButtonRelease-1> {Qked CopyFilesTo}
	bind $ds	<ButtonRelease-1> {Qked CopyFileSeq}
	bind $nf	<ButtonRelease-1> {Qked ReplaceNext}
	bind $cf	<ButtonRelease-1> {Qked ChangeFileTo}
	bind $lf	<ButtonRelease-1> {Qked ChangeFileToLastMade}
	bind $ce	<ButtonRelease-1> {Qked ChangeEvery}
	bind $cm	<ButtonRelease-1> {Qked ChangeMany}
	bind $nw	<ButtonRelease-1> {Qked AddNewFile}
	bind $nl	<ButtonRelease-1> {Qked AddLastMade}
	bind $nm	<ButtonRelease-1> {Qked AddMixfile}
	bind $si	<ButtonRelease-1> {Qked ShowRepeats}
	bind $om	<ButtonRelease-1> {Qked SortAllOrder}
	bind $mh	<ButtonRelease-1> {Qked MoveToTop}

	bind $mf	<ButtonRelease-1> {Qked MoveToFoot}
	bind $rv	<ButtonRelease-1> {Qked ReverseOrder}
	bind $dd	<ButtonRelease-1> {Qked HiliteAllDupls}
	bind $wi	<ButtonRelease-1> {Qked PermuteOrder}
	bind $ab	<ButtonRelease-1> {Qked AmplifyBy}
	bind $sl	<ButtonRelease-1> {Qked SetLevelTo}
	bind $ss	<ButtonRelease-1> {Qked StepLevelsBy}
	bind $vv	<ButtonRelease-1> {Qked VecLevelsBy}
	bind $mm	<ButtonRelease-1> {Qked MuteLines}
	bind $nn	<ButtonRelease-1> {Qked UnmuteLines}
	bind $ua	<ButtonRelease-1> {Qked UnmuteAll}
	bind $pm	<ButtonRelease-1> {Qked SwapMutingPair}
	bind $h1	<ButtonRelease-1> {Qked HiliteAllMuted}
	bind $fm	<ButtonRelease-1> {Qked AllMutedToEnd}
	bind $r1	<ButtonRelease-1> {Qked RemoveSelected}
	bind $rc	<ButtonRelease-1> {Qked RemoveAllMuted}
}

proc Qked {subject} {
	global ww mm_multichan  mixd2
	set f $mixd2.1.h.help
	switch -- $subject {
		"PreviousState" {
			$f config -text "Restore previous state of mixfile"
		}
		"InitialState" {
			$f config -text "Restore state of mixfile at start of CURRENT Qikedit session"
		}
		"RestoreOrig" {
			$f config -text "Restore original mixfile when you last left the workspace/parampage (ignore ALL subsequent Qikedits)"
		}
		"Abandon" {
			$f config -text "Restore mixfile at start of THIS qikedit, and Quit qikedit"
		}
		"SaveEdited" {
			$f config -text "Save current state of edited mixfile, and go to mix parameter page"
		}
		"Search" {
			$f config -text "Search for sound whose name contains a specified text"
		}
		"SearchAgain" {
			$f config -text "Search again for sound whose name contains a previously specified text"
		}
		"GotoTime" {
			$f config -text "Go to time (specified in \"Value\" box) in mixfile display"
		}
		"Calculator" {
			$f config -text "Go to the Calculator (Calculator output can be sent back to \"Value\" box)."
		}
		"RefVals" {
			$f config -text "Go to Get or Create a Reference Value"
		}
		"Notebook" {
			$f config -text "Go to the Notebook, to make or modify an entry"
		}
		"ConcertA" {
			$f config -text "Play Concert A  pitch"
		}
		"ViewSound" {
			$f config -text "See/Play selected snd (can also mark a time on graphic and grab - as time IN MIX - to \"Value\" box)."
		}
		"SndsToSubmix" {
			$f config -text "Grab highlighted sounds to create a separate submix."
		}
		"SndToWkspace" {
			$f config -text "Send highlighted sound to workspace and quit mixing (saving current state of mix, if desired)."
		}
		"LineTimeToMixStartParam" {
			$f config -text "Send Time in highlighted line to mix Start-time parameter."
		}
		"LineTimeToMixEndParam" {
			$f config -text "Send Time in highlighted line to mix End-time parameter."
		}
		"LineTimeToCalc" {
			$f config -text "Send Time in highlighted line to Calculator, and go to Calculator (whose output can be returned)."
		}
		"LineTimeToCalcStore" {
			$f config -text "Send Time in highlighted line to Calculator's Store, & go to Calculator (whose output can be returned)."
		}
		"InchanLevels" {
			$f config -text "See levels in each channel of soundfile in selected (active) line."
		}
		"ChannelAttenuators" {
			$f config -text "Adjust Mix Output Level, but only in specified output channels."
		}
		"ValToCalc" {
			$f config -text "Send value in \"Value\" box to Calculator, and go to Calculator (whose output can be returned)."
		}
		"ValToCalcStore" {
			$f config -text "Send value in \"Value\" box to Calculator's Store, & go to Calculator (whose output can be returned)."
		}
		"ValToMixStartParam" {
			$f config -text "Send value in \"Value\" box to mix Start-time parameter (on parameters page)."
		}
		"ValToMixEndParam" {
			$f config -text "Send value in \"Value\" box to mix End-time parameter (on parameters page)."
		}
		"ValToMixGain" {
			$f config -text "Send value in \"Value\" box to mix Gain parameter (on parameters page)."
		}
		"MixGain" {
			$f config -text "Display of current mix Gain parameter."
		}
		"UnityGain" {
			$f config -text "Set overall mix gain to 1.0."
		}
		"Selections" {
			$f config -text "Select ALL lines; all OTHER; lines Active or Starting AT TIME \"Value\"; CONTEMPORARY with selected lines."
		}
		"DoWholeMix" {
			$f config -text "Do the whole mix, even when new sounds are added at the end."
		}
		"GetParamsInLine" {
			$f config -text "Set or change val in \"Value\" box by some param (start or end time, level, position) in highlighted line."
		}
		"TapTime" {
			$f config -text "Generate a duration value and put it in the \"Value\" box, by tapping twice here."
		}
		"MM" {
			$f config -text "Specify a Metronome Mark: set or alter time in \"Value\" box by N beats at specified MM."
		}
		"EndTimes" {
			$f config -text "Get mix-end parameter OR endtime of whole mix (OR, if mix start > 0, true duration) to \"Value\" box."
		}
		"QikEditListing" {
			$f config -text "Display of (current edited state) of mixfile. (Double-Click on any line to PLAY sound in line)."
		}
		"CopyWithNewMixName" {
			$f config -text "Keep current edited state of mix, as a separate named mixfile."
		}
		"NewMixName" {
			$f config -text "Enter name for current edited state of mix, which you are saving separately."
		}
		"SaveAndMix" {
			$f config -text "Save current edited state of mix, and generate the sound output."
		}
		"MaxSamp" {
			$f config -text "Get the maximum sample of the (latest) sound output generated from the mix."
		}
		"MaxChan" {
			$f config -text "Display maximum sample in each channel of multichannel output."
		}
		"ViewMixOutput" {
			$f config -text "See/Play the (latest) sound output of the mix."
		}
		"KeepMixOutput" {
			$f config -text "Keep sound output of mix + current state of mix : exit to params page to name the sound."
		}
		"RecallMixVersion" {
			$f config -text "Recall a previous edited state of the mix, from a listing of previous states."
		}

		"TemporaryChange" {
			$f config -text "Lines which have been altered remain displayed, but commented out; tick box to prevent this."
		}
		"Value" {
			$f config -text "Set a Value here, to use in one of the operations below."
		}
		"AmplifyBy" {
			$f config -text "Amplify, by \"Value\", chosen sound OR (multichannel mix) one routing only (enter\"Routing Gain\")"
		}
		"SetLevelTo" {
			$f config -text "Set, to \"Value\", level of chosen sounds OR (multichannel mix) of one routing only (enter\"Routing Gain\")"
		}
		"StepLevelsBy" {
			$f config -text "Set level in each succesive line to \"Value\" times level in previous line."
		}
		"VecLevelsBy" {
			$f config -text "For each selected line, multiply (all) level(s) in line by corresponding value in list in (\"vector\") file."
		}
		"MoveTimeFwds" {
			$f config -text "Move start-times of highlighted sounds forward by \"Value\"."
		}
		"MoveTimesBkwds" {
			$f config -text "Move start-times of highlighted sounds backwards by \"Value\"."
		}
		"MoveTimesTo" {
			$f config -text "Move start-times of all highlighted sounds to time \"Value\"."
		}
		"XpndTimesAt" {
			$f config -text "Expand mix by inserting extra time \"Value\" (like a bar of silence) before each highlighted line."
		}
		"MoveStartTo" {
			$f config -text "Move start-time of highlighted sounds to time \"Value\", preserving their relative-times."
		}
		"SetMixtartToZero" {
			$f config -text "Adjust all times in mix so mix begins at time zero."
		}
		"SortTimeOrder" {
			$f config -text "Sort mix lines so they are in increasing time order (no change to mix output)."
		}
		"SortAllOrder" {
			$f config -text "Sort entire mix (including muted lines) to increasing time order (no change to mix output)."
		}
		"OverlapTimesBy" {
			$f config -text "Overlap start and end times of highlighted sound(file)s in mix by \"Value\"."
		}
		"StretchSilenceBy" {
			$f config -text "Stretch any silence between highlighted sound(file)s by \"Value\"."
		}
		"StretchTimeBy" {
			$f config -text "Multiply start-times of highlighted sounds by \"Value\". (Can be < 1)"
		}
		"StretchStepsBy" {
			$f config -text "Multiply time-steps between highlighted sounds by \"Value\". (Can be < 1)"
		}
		"SetStepsTo" {
			$f config -text "Set time-step between highlighted sounds to \"Value\"."
		}
		"Stagger" {
			$f config -text "Move 1st selected item by \"Value\": 2nd item by 2 * \"Value\": 3rd by 3 * \"Value\" etc."
		}
		"QuantiseTimesTo" {
			$f config -text "Quantise start-times of highlighted sounds over the time-unit \"Value\"."
		}
		"ShakeTimesBy" {
			$f config -text "Randomise start-times within some fraction (\"Value\" 0-1) of their existing time-separation."
		}
		"ShakeTimesWithin" {
			$f config -text "Randomise start-times within a time-range \"Value\" but not exceeding existing time-separation."
		}
		"EndToEnd" {
			$f config -text "Set times of highlighted sounds so each sound(file) starts as previous sound(file) ends."
		}
		"RetroTimePattern" {
			$f config -text "Retrograde pattern of start-times of highlighted sounds,(sounds remain in same order of entry)."
		}
		"LineUpAtMarks" {
			$f config -text "Mark a time in file(s), which you want to synchronise with Time Value in \"Value\" box."
		}
		"SyncAtMarks" {
			$f config -text "Mark a time in 2 files: time in 2nd is to be syncd to time in 1st."
		}
		"SyncAtEnd" {
			$f config -text "Sync all files in mix at their end times."
		}
		"ReplaceRetime" {
			$f config -text "Replace file, and retime step to next sound (e.g. Value \"0.2\" = .2 secs or \"3b\" = 3 beats)."
		}
		"OffsetAtMarks" {
			$f config -text "Mark a time in 2 files: time marked in 2nd offset from time in 1st by duration in \"Value\" box."
		}
		"CreateTimeGrid" {
			$f config -text "Generate a (quantisation) grid of times, to use with \"Get Grid Value\"."
		}
		"GetGridValue" {
			$f config -text "Get a time you have specified with \"Create Time Grid\", and put it in \"Value\" box."
		}
		"RoundAllTimes" {
			$f config -text "Round all start-times in mix to 4 significant figures."
		}
		"RoundSelected" {
			$f config -text "Round start-times of highlighted lines to 4 significant figures."
		}
		"MakeClick" {
			$f config -text "Generate a click-track of a specified duration, at a specified Metronome Mark."
		}
		"MarkAsClick" {
			$f config -text "Remember that the highlighted sound is the click-track."
		}
		"ClickOnOff" {
			$f config -text "Mute/Unmute any specified clicktrack sound."
		}
		"SetPosition" {
			if {$mm_multichan} {
				set msg "Rewrite routing information for a sound, to value in \"Value\" box.\n"
				append msg "\n"
				append msg "The following abbreviations can be used ....\n"
				append msg "\n"
				append msg "(1)  For a MONO INPUT, you can enter.\n"
				append msg "      (a)  A different outchannel (e.g. \"4\").\n"
				append msg "      (b)  A range (e.g. \"1-4\" or \"6-3\") of different outchannels.\n"
				append msg "      (c)  A list separated by commas (e.g. \"1,3,5\") of different outchannels.\n"
				append msg "\n"
				append msg "(2)  For TWO MONO INPUTS, or a STEREO INPUT.\n"
				append msg "      (a)  \"LR\" sends 1 channel or file to all channels on left of auditorium.\n"
				append msg "           and the other to all those on right of auditorium.\n"
				append msg "      (b)  \"LRC0\", as \"LR\" but sends no signal to centre front and rear channels.\n"
				append msg "      (c)  \"I\" sends 1 channel or file to alternate chans, and other to all others.\n"
				append msg "\n"
				append msg "(3)  For STEREO input\n"
				append msg "     (a)  A range (e.g. \"3-8\") or list (e.g.\"2,4,6,8\") of different outchannels\n"
				append msg "          with an EVEN number (E) of outchans, (e.g. \"3-8\" offers 6 outchans)\n"
				append msg "          offers the choice of .....\n"
				append msg "          (1)  E/2 sets of stereo (\"3-8\" gives 3 sets of stereo:  34, 56, 78).\n"
				append msg "          (2)  E identical mono outputs, mixing the stereo input to mono.\n"
				append msg "     (b)  \"front stereo\"\n"
				append msg "          will place output on the channels to left and right\n"
				append msg "          of the front-centre channel (1).\n"
				append msg "     (c)  \"wide stereo\"\n"
				append msg "          places output on 2 channels to the left and 2 to the right\n"
				append msg "          of the front-centre channel (1).\n"
				append msg "     (d)  \"antiphonal\",\"antiphony\" or \"antiphon\" will send\n"
				append msg "          --  stereo left to all chans on the left of the output frame, and\n"
				append msg "          --  stereo right to all chans on the right of the output frame.\n"
				append msg "           N.B.If there are an EVEN number of output channels....\n"
				append msg "           (1)  If output layout has channel 1 at the front CENTRE,\n"
				append msg "                      \"antiphon\" for e.g. 8-chan out, antiphonate between\n"
				append msg "                      channels 234 and 678, omitting centred channels (1 & 5)\n"
				append msg "           (2)  If not, \"Antiphon\" (with capital \"A\"), for 8-chan out,\n"
				append msg "                       antiphonates between channels 1234 and 5678.\n"
				append msg "     (e)  PAIRS of grouped numbers, pans stereo in groups (e.g. \"23,78\" pans 1 TO 2 & 3 and 2 TO 7 & 8\n"
				append msg "                       while \"246,753\" pans 1 TO 2,4 & 6 and 2 TO 7,5 & 3)\n"
				append msg "\n"
				append msg "CONTINUED ...\n"
				Inf $msg
				set msg "(4)  For 2 STEREO INPUTS.\n"
				append msg "      (1) \"SQ\" will divide one stereo between front chans, and other between rear chans.\n"
				append msg "      (2)  \"I\" alternates successive channels from stereo inputs.\n"
				append msg "\n"
				append msg "\n"
				append msg "(5)  For N-CHANNEL INPUT, you can enter\n"
				append msg "      (a) A range (e.g. \"1-3\" or \"7-2\") of N different outchannels.\n"
				append msg "      (b) A list separated by commas (e.g. \"1,3,5\") of N different outchannels.\n"
				append msg "             These will be assigned, in order, to the input channels.\n"
				append msg "\n"
				append msg "\n"
				append msg "CONTINUED ...\n"
				Inf $msg
				set msg "(6)  FOR A LINE WITH K DIFFERENT OUTPUT ROUTINGS,\n"
				append msg "      --  either to different channels (e.g. 1:1 2:2 3:3 4:4 = 4 routings)\n"
				append msg "      --  or to shared channels (e.g. 1:1 1:2 1:3 2:4 = 4 routings)\n"
				append msg "      you can enter a set of K new outchannels, separated by commas,\n"
				append msg "      (e.g. for 4 existing routings .... \"1,1,3,1\") \n"
				append msg "      which will be be assigned to change each existing routing in turn.\n"
				append msg "\n"
				append msg "      For lines where options (3) and (4) are ambiguous\n"
				append msg "      you are offered a choice.\n"
				append msg "\n"
				append msg "(7)  \"ROTATE\" the output frame\n"
				append msg "      Enter a rotation count and an \"r\" (or \"R\") e.g. \"3R\" or \"-2R\"\n"
				append msg "      Using \"3R\" for example ....\n"
				append msg "      The frame of the output is rotated so that \n"
				append msg "      anything which had been routed to channel 1 now goes to channel 4,\n"
				append msg "      anything which had been routed to channel 2 now goes to channel 5\n"
				append msg "      and so on.\n"
				append msg "\n"
				append msg "\n"
				append msg "(8)  \"ROTATE + MIRROR\" of the output frame\n"
				append msg "      Enter an output channel number and an \"m\" (or \"M\") e.g. \"3M\"\n"
				append msg "      Using \"3M\" for example ....\n"
				append msg "      (a)  The frame of the output is first rotated so that \n"
				append msg "               anything which had been routed to channel 1 now goes to channel 3.\n"
				append msg "      (b)  The whole output routing is then mirrored around channel 3.\n"
				append msg "      For example, a stereo file initially routed to channels 1 and 2\n"
				append msg "      would end up being routed to channel 3 and 2 (in that reversed order).\n"
				append msg "\n"
				append msg "CONTINUED ...\n"
				Inf $msg
				set msg "(9)  For 2 SELECTED LINES with the SAME NUMBER OF INPUT CHANNELS.\n"
				append msg "     (a)  \">\" Transfers the routing (and levels) from the 1st to the 2nd.\n"
				append msg "     (b)  \"<\" Transfers the routing (and levels) from the 2nd to the 1st.\n"
				append msg "     (c)  \"<>\" Swap routings (and levels).\n"
				append msg "\n"
				append msg "(10)  \"ODD\" puts (succesive) input channels on odd-numbered channels.\n"
				append msg "     \"EVEN\" puts (succesive) input channels on even-numbered channels.\n"
				append msg "     Output channel count must be even and a multiple of (2 * input-channel-count).\n"
				append msg "\n"
				append msg "(11)  \"COPY TO\" followed by a list of channels (e.g. 2,3,4,5).\n"
				append msg "     Copy existing N output routings, to N specified additional outputs.\n"
				append msg "\n"
				append msg "CONTINUED ...\n"
				Inf $msg
				set msg "(12)  \"REMAP\". A group of MONO files each currently routed to SINGLE output channels\n"
				append msg "     can be rerouted to a different list of output channels.\n"
				append msg "     (e.g. REMAP 1,8,6 sends\n"
				append msg "           1st selected line to output channel 1\n"
				append msg "           2nd selected line to output channel 8\n"
				append msg "           3rd selected line to output channel 6)\n"
				append msg "\n"
				append msg "(13)  \"+\". Reorient the mix output, so all outputs go to next channel.\n"
				append msg "     (e.g. 1->2,  2->3 etc. and, for N output channels, N->1\n"
				append msg "      \"+K\". Reorient the mix output, so all outputs move up K channels.\n"
				append msg "     (e.g. 1->1+K,  2->2+K etc.\n"
				append msg "\n"
				append msg "(14)  \"-\". Reorient the mix output, but anticlockwise.\n"
				append msg "\n"
				append msg "(15) In all other cases, the FULL routing information (with levels) must be used.\n"
				append msg "     (e.g. 1:2  1.0  1:4  1.0  2:6  0.5  2:8  0.5 )\n"
				Inf $msg
			} else {
				$f config -text "Set the position of the highlighted sounds to \"Value\"."
			}
		}
		"Opposite" {
			if {$mm_multichan} {
				$f config -text "Add further output channels to the multichannel output file of the mix."
			} else {
				$f config -text "Change position in \"Value\" box to its opposite position in the stereo space."
			}
		}
		"SpreadPosition" {
			if {$mm_multichan} {
				$f config -text "Change Numbering of output channels from Ring to Bilateral configuration."
			} else {
				$f config -text "Increase (> 0) or decrease (< 0) distance from stereo centre by 'fraction' \"Value\"."
			}
		}
		"StepBetween" {
			if {$mm_multichan} {
				$f config -text "Change Numbering of output channels from Bilateral to Ring configuration."
			} else {
				$f config -text "Set sounds equidistant from one another, between positions of 1st and last highlighted snd."
			}
		}
		"ScatterPosition" {
			if {$mm_multichan} {
				$f config -text "Mirror output channel configuration about \"Value\" channel, or midpoint between 2 chans."
			} else {
				$f config -text "Randomly move sounds by factor \"Value\" (0-1) of their current spatial separation."
			}
		}
		"ScatterPositions" {
			if {$mm_multichan} {
				$f config -text "Randomly permute positions of highlighted lines (all must have same channel-count)."
			}
		}
		"Twist" {
			if {$mm_multichan} {
				$f config -text "Rotate every sey of N lines by M chans, 2M chans, 3M chans etc. Where M is +ve or -ve."
			}
		}
		"Getpos" {
			if {$mm_multichan} {
				$f config -text "Get position data from (single) highlighted line, to Value box."
			}
		}
		"SwapPosition" {
			if {$mm_multichan} {
				$f config -text "Swap positions of 2 files, or rotate among the positions of chosen files."
			} else {
				$f config -text ""
			}
		}
		"PermutePositions" {
			$f config -text "Randomly permute the existing spatial positions of the highlighted sounds."
		}
		"Mirror" {
			if {$mm_multichan} {
				$f config -text "Rotate configuration of selected channels by \"Value\" around set of all output chans."
			} else {
				$f config -text "Mirror the stereo-image. Left becomes Right, Right becomes Left."
			}
		}
		"RetroFileOrder" {
			$f config -text "Retain existing sequence of start-timings, but Reverse order of files used."
		}
		"RandomiseOrder" {
			$f config -text "Retain existing sequence of start-timings, but Randomise order of files and routing used."
		}
		"RandomiseNames" {
			$f config -text "Retain existing sequence of start-timings and routings, but Randomise order of files used."
		}
		"SwapFiles" {
			$f config -text "Swap two files : 1st file gets starttime of 2nd : 2nd file gets starttime of 1st."
		}
		"CopyFilesTo" {
			$f config -text "Add copies of highlighted sounds to mix, all at time \"Value\"."
		}
		"CopyFileSeq" {
			$f config -text "Add copies of highlighted files to mix (preserving relative timings), starting at time \"Value\"."
		}
		"ReplaceNext" {
			$f config -text "Use the currently selected file to replace the next file you select."
		}
		"ChangeFileTo" {
			$f config -text "Change highlighted file to a diffferent file, selected from a displayed list of workspace files."
		}
		"ChangeFileToLastMade" {
			$f config -text "Change highlighted file to last file created on workspace."
		}
		"ChangeEvery" {
			$f config -text "Change every file which is same as highlighted file to different file, selected from displayed list."
		}
		"ChangeMany" {
			$f config -text "Change all highlighted files to a different file, selected from displayed list."
		}
		"AddNewFile" {
			$f config -text "Add new sound from workspace, either at time of highlighted line, at time \"Value\", or at time 0.0."
		}
		"AddLastMade" {
			$f config -text "Add last made file, either at time of highlighted line, at time \"Value\", or at time 0.0."
		}
		"AddMixfile" {
			$f config -text "Add sounds from another mixfile, preserving that mixfile's order, but starting at a specified time."
		}
		"ShowRepeats" {
			$f config -text "Highlight any sounds which are duplicates of the highlighted sound."
		}
		"MoveToTop" {
			$f config -text "Move highlighted sounds to top of listing (no change in start-times or mix output)."
		}
		"MoveToFoot" {
			$f config -text "Move highlighted sounds to foot of listing (no change in start-times or mix output)."
		}
		"ReverseOrder" {
			$f config -text "Reverse order of highlighted sounds in listing (no change in start-times or mix output)."
		}
		"MuteLines" {
			$f config -text "Mute the highlighted sounds."
		}
		"UnmuteLines" {
			$f config -text "Unmute the highlighted, previously muted, sounds."
		}
		"UnmuteAll" {
			$f config -text "Unmute All previously muted sounds."
		}
		"SwapMutingPair" {
			$f config -text "Select sounds pair, 1 muted, 1 not : Muted sound becomes unmuted, Unmuted sounds becomes muted."
		}
		"HiliteAllMuted" {
			$f config -text "Highlight all muted sounds in the mix."
		}
		"AllMutedToEnd" {
			$f config -text "Move all muted lines in the mix to the end of the mix."
		}
		"HiliteAllDupls" {
			$f config -text "Highlight all sounds which are repeated in the mix."
		}
		"RemoveAllMuted" {
			$f config -text "Remove ALL muted sounds in the mix."
		}
		"RemoveSelected" {
			$f config -text "Remove selected Muted lines in the mix."
		}
		"Syntax" {
			$f config -text "Check the syntax of the mixfile (use if mix sound-output fails)."
		}
		"Collapse" {
			$f config -text "Multichan mix only: collapse line, or entire file, to stereo format"
		}
		"LevelStore" {
			$f config -text "Store total mix level (from params page) as comment line in mixfile"
		}
		"LevelRestore" {
			$f config -text "Reset total mix level (params page) to value in comment line in mixfile"
		}
		"PlaySound" {
			$f config -text "Play last output of mix (if it exists)"
		}
		"PlayChan" {
			$f config -text "Play specific channel of last output of mix (if it exists)"
		}
		"PermuteOrder" {
			$f config -text "Permute order of selected sounds, specifying a permutation scheme."
		}
		"AmpByMixLevel" {
			$f config -text "Attenuate entire mix by attenuation-value set on parameters page."
		}
	}
}

proc DisableHelpOnQikedit {qe} {
	global qikedit_hlp_actv qikedit_actv longqik mixd2 mm_multichan

	bind $mixd2.1.u.gp	<ButtonRelease-1> {}
	bind $mixd2.1.u.ii	<ButtonRelease-1> {}
	bind $mixd2.1.u.rs	<ButtonRelease-1> {}
	bind $mixd2.1.u.view	<ButtonRelease-1> {}
	bind $mixd2.1.u.getm	<ButtonRelease-1> {}
	bind $mixd2.1.u.get	<ButtonRelease-1> {}

	bind $mixd2.1.button.ok	<ButtonRelease-1> {}
	bind $mixd2.1.button.ed	<ButtonRelease-1> {}
	bind $mixd2.1.button.sk	<ButtonRelease-1> {}
	bind $mixd2.1.button.ag	<ButtonRelease-1> {}
	bind $mixd2.1.button.go	<ButtonRelease-1> {}
	bind $mixd2.1.button.ca	<ButtonRelease-1> {}
	bind $mixd2.1.button.re	<ButtonRelease-1> {}
	bind $mixd2.1.button.no	<ButtonRelease-1> {}
	bind $mixd2.1.button.aa	<ButtonRelease-1> {}

	bind $mixd2.1.see.00.stt	<ButtonRelease-1> {}
	bind $mixd2.1.see.00.end	<ButtonRelease-1> {}
	bind $mixd2.1.see.00.clc1	<ButtonRelease-1> {}
	bind $mixd2.1.see.00.clc2	<ButtonRelease-1> {}
	bind $mixd2.1.see.00.seel  <ButtonRelease-1> {}
	bind $mixd2.1.see.00.atten <ButtonRelease-1> {}

	bind $mixd2.1.see.00x.clc1	<ButtonRelease-1> {}
	bind $mixd2.1.see.00x.clc2	<ButtonRelease-1> {}
	bind $mixd2.1.see.00x.stt	<ButtonRelease-1> {}
	bind $mixd2.1.see.00x.end	<ButtonRelease-1> {}
	bind $mixd2.1.see.00x.gai	<ButtonRelease-1> {}
	bind $mixd2.1.see.00x.gan	<ButtonRelease-1> {}
	bind $mixd2.1.see.00x.gnw	<ButtonRelease-1> {}

	bind $mixd2.1.see.000.frm	<ButtonRelease-1> {}
	bind $mixd2.1.see.000.tap	<ButtonRelease-1> {}
	bind $mixd2.1.see.000.mm	<ButtonRelease-1> {}
	bind $mixd2.1.see.000.mev	<ButtonRelease-1> {}
	bind $mixd2.1.see.000.ll2	<ButtonRelease-1> {}
	bind $mixd2.1.see.000.dft	<ButtonRelease-1> {}

	bind $mixd2.1.see.1.foot.b	<ButtonRelease-1> {}
	bind $mixd2.1.see.1.foot.n	<ButtonRelease-1> {}
	bind $mixd2.1.see.1.foot.rr	<ButtonRelease-1> {}

	bind $mixd2.1.see.1.foot2.ss <ButtonRelease-1> {}
	bind $mixd2.1.see.1.foot2.mx <ButtonRelease-1> {}
	bind $mixd2.1.see.1.foot2.mq <ButtonRelease-1> {}
	bind $mixd2.1.see.1.foot2.vv <ButtonRelease-1> {}
	bind $mixd2.1.see.1.foot2.qq <ButtonRelease-1> {}

	bind $mixd2.1.see.1.foot2.pp <ButtonRelease-1> {}
	bind $mixd2.1.see.1.foot2.cc <ButtonRelease-1> {}

	bind $mixd2.2.3.1.mb	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.mbb	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.mt	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.mtx	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.mt2	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.mz	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.st	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.ov	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.ex	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.ey	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.ez	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.tg	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.qu	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.wt	<ButtonRelease-1> {}
	bind $mixd2.2.3.1.ww	<ButtonRelease-1> {}
	if {$longqik} {
		bind $mixd2.2.t	<ButtonRelease-1> {}
		bind $mixd2.2.v	<ButtonRelease-1> {}

		bind $mixd2.2.3.1.ee	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.es	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.rt	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.lu	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.sm	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.so	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.ye	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.zr	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.gr	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.gg	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.xa	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.xc	<ButtonRelease-1> {}

		bind $mixd2.2.3.2.po	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.op	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sp	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.fl	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sc	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sw	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sk	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.mi	<ButtonRelease-1> {}
		if {$mm_multichan} {
			bind $mixd2.2.3.2.zq	<ButtonRelease-1> {}
			bind $mixd2.2.3.2.tw	<ButtonRelease-1> {}
			bind $mixd2.2.3.2.ge	<ButtonRelease-1> {}
		}
		bind $mixd2.2.3.2.rf	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sf	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sn	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.wf	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.du	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.ds	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.nf	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.cf	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.lf	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.ce	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.cm	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.nw	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.nl	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.nm	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.si	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.dd	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.wi	<ButtonRelease-1> {}

		bind $mixd2.2.3.3.ab	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.sl	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.ss	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.vv	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.mm	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.nn	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.ua	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.pm	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.h1	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.fm	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.r1	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.rc	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.om	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.mh	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.mf	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.rv	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.mk	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.ck	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.ko	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.sy	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.co	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.ij	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.sj	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.sz	<ButtonRelease-1> {}
	} else {
		bind $mixd2.2.hhh.t	<ButtonRelease-1> {}
		bind $mixd2.2.hhh.v	<ButtonRelease-1> {}

		bind $mixd2.2.3.1.rt	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.gr	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.gg	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.xa	<ButtonRelease-1> {}
		bind $mixd2.2.3.1.xc	<ButtonRelease-1> {}

		bind $mixd2.2.3.2.ee	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.es	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.lu	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sm	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.so	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.ye	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.zr	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.po	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.op	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sp	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.fl	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sc	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sw	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.sk	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.mi	<ButtonRelease-1> {}
		if {$mm_multichan} {
			bind $mixd2.2.3.2.zq	<ButtonRelease-1> {}
			bind $mixd2.2.3.2.tw	<ButtonRelease-1> {}
			bind $mixd2.2.3.2.ge	<ButtonRelease-1> {}
		}
		bind $mixd2.2.3.2.om	<ButtonRelease-1> {}
		bind $mixd2.2.3.2.mh	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.mf	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.rv	<ButtonRelease-1> {}

		bind $mixd2.2.3.3.rf	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.sf	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.sn	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.wf	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.du	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.ds	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.nf	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.cf	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.lf	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.ce	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.cm	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.nw	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.nl	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.nm	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.si	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.dd	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.wi	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.sy	<ButtonRelease-1> {}
		bind $mixd2.2.3.3.co	<ButtonRelease-1> {}

		bind $mixd2.2.3.4.ab	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.sl	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.ss	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.vv	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.mm	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.nn	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.ua	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.pm	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.h1	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.fm	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.r1	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.rc	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.mk	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.ck	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.ko	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.ij	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.sj	<ButtonRelease-1> {}
		bind $mixd2.2.3.4.sz	<ButtonRelease-1> {}
	}
	DisableHelp $qe
	set qikedit_hlp_actv 0

	if {!$qikedit_actv} {
		ReactivateQikedit $qe
	} else {
		bind $mixd2.1.see.1.seefile.list <ButtonRelease-1> {}
		bind $mixd2.1.see.1.seefile.list <Double-1> {PlaySndonQikEdit $mixd2.1.see.1.seefile.list %y}

		bind $mixd2.1.see.1.seefile <Control-Key-p> {QikEditor play}
		bind $mixd2.1.see.1.seefile <Control-Key-P> {QikEditor play}
		bind $mixd2.1.see.1.seefile <Key-space>	  {QikEditor play}
		bind $mixd2.1.see.1.seefile <Control-Up>    {MixModify up    $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.1.see.1.seefile <Control-Down>  {MixModify down  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.1.see.1.seefile <Control-Left>  {MixModify left  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.1.see.1.seefile <Control-Right> {MixModify right $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.1.see.1.seefile <Control-Key-D> {MixModify delcom  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.1.see.1.seefile <Control-Key-d> {MixModify delcom  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.1.see.1.seefile <Control-Home>  {$mixd2.1.see.1.seefile.list yview moveto 0.0}
		bind $mixd2.1.see.1.seefile <Control-End>   {$mixd2.1.see.1.seefile.list yview moveto 1.0}
		bind $mixd2.1.see.1.seefile <Control-Key-t> {QikShowText}
		bind $mixd2.1.see.1.seefile <Control-Key-T> {QikShowText}
		bind $mixd2.1.see.1.seefile.list <Double-1> {PlaySndonQikEdit $mixd2.1.see.1.seefile.list %y}
		if {$longqik} {
			bind $mixd2.2.v <Control-Up>    {focus $mixd2.1.see.1.seefile; MixModify up    $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
			bind $mixd2.2.v	<Control-Down>  {focus $mixd2.1.see.1.seefile; MixModify down  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
			bind $mixd2.2.v	<Control-Left>  {focus $mixd2.1.see.1.seefile; MixModify left  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
			bind $mixd2.2.v	<Control-Right> {focus $mixd2.1.see.1.seefile; MixModify right $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		} else {
			bind $mixd2.2.hhh.v <Control-Up>    {focus $mixd2.1.see.1.seefile; MixModify up    $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
			bind $mixd2.2.hhh.v	<Control-Down>  {focus $mixd2.1.see.1.seefile; MixModify down  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
			bind $mixd2.2.hhh.v	<Control-Left>  {focus $mixd2.1.see.1.seefile; MixModify left  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
			bind $mixd2.2.hhh.v	<Control-Right> {focus $mixd2.1.see.1.seefile; MixModify right $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		}
	}
}

proc ReactivateQikedit {qe} {
	global qikedit_actv qikedit_hlp_actv longqik evv mixd2 zobo mm_multichan

	set n "normal"

	$mixd2.1.u.gp		config -state $n
	$mixd2.1.u.ii		config -state $n
	$mixd2.1.u.rs		config -state $n
	$mixd2.1.u.view	config -state $n
	$mixd2.1.u.getm	config -state $n
	$mixd2.1.u.get	config -state $n

	$mixd2.1.button.ok	config -state $n
	$mixd2.1.button.ed	config -state $n
	$mixd2.1.button.sk	config -state $n
	$mixd2.1.button.ag	config -state $n
	$mixd2.1.button.go	config -state $n
	$mixd2.1.button.ca	config -state $n
	$mixd2.1.button.re	config -state $n
	$mixd2.1.button.no	config -state $n
	$mixd2.1.button.aa	config -state $n

	$mixd2.1.see.00.stt	config -state $n
	$mixd2.1.see.00.end	config -state $n
	$mixd2.1.see.00.clc1	config -state $n
	$mixd2.1.see.00.clc2	config -state $n
	$mixd2.1.see.00.seel	config -state $n
	$mixd2.1.see.00.atten	config -state $n

	$mixd2.1.see.00x.clc1	config -state $n
	$mixd2.1.see.00x.clc2	config -state $n
	$mixd2.1.see.00x.stt	config -state $n
	$mixd2.1.see.00x.end	config -state $n
	$mixd2.1.see.00x.gai	config -state $n
	$mixd2.1.see.00x.gnw	config -state $n

	$mixd2.1.see.000.frm	config -state $n
	$mixd2.1.see.000.tap	config -state $n
	$mixd2.1.see.000.mm	config -state $n
	$mixd2.1.see.000.mev	config -state $n
	$mixd2.1.see.000.ll2	config -state $n
	$mixd2.1.see.000.dft	config -state $n

	$mixd2.1.see.1.foot.b		config -state $n
	$mixd2.1.see.1.foot.n		config -state $n
	$mixd2.1.see.1.foot.rr	config -state $n

	$mixd2.1.see.1.foot2.ss config -state $n
	$mixd2.1.see.1.foot2.mx config -state $n
	$mixd2.1.see.1.foot2.mq config -state $n
	$mixd2.1.see.1.foot2.vv config -state $n
	$mixd2.1.see.1.foot2.qq config -state $n

	$mixd2.1.see.1.foot2.pp config -state $n
	$mixd2.1.see.1.foot2.cc config -state $n

	$mixd2.2.3.1.mb	config -state $n
	$mixd2.2.3.1.mbb	config -state $n
	$mixd2.2.3.1.mt	config -state $n
	$mixd2.2.3.1.mtx	config -state $n
	$mixd2.2.3.1.mt2	config -state $n
	$mixd2.2.3.1.mz	config -state $n
	$mixd2.2.3.1.st	config -state $n
	$mixd2.2.3.1.ov	config -state $n
	$mixd2.2.3.1.ex	config -state $n
	$mixd2.2.3.1.ey	config -state $n
	$mixd2.2.3.1.ez	config -state $n
	$mixd2.2.3.1.tg	config -state $n
	$mixd2.2.3.1.qu	config -state $n
	$mixd2.2.3.1.wt	config -state $n
	$mixd2.2.3.1.ww	config -state $n
	if {$longqik} {
		$mixd2.2.t			config -state $n
		$mixd2.2.v			config -state $n

		$mixd2.2.3.1.ee	config -state $n
		$mixd2.2.3.1.es	config -state $n
		$mixd2.2.3.1.rt	config -state $n
		$mixd2.2.3.1.lu	config -state $n
		$mixd2.2.3.1.sm	config -state $n
		$mixd2.2.3.1.so	config -state $n
		$mixd2.2.3.1.ye	config -state $n
		$mixd2.2.3.1.zr	config -state $n
		$mixd2.2.3.1.gr	config -state $n
		$mixd2.2.3.1.gg	config -state $n
		$mixd2.2.3.1.xa	config -state $n
		$mixd2.2.3.1.xc	config -state $n

		$mixd2.2.3.2.po	config -state $n
		$mixd2.2.3.2.op	config -state $n
		$mixd2.2.3.2.sp	config -state $n
		$mixd2.2.3.2.fl	config -state $n
		$mixd2.2.3.2.sc	config -state $n
		$mixd2.2.3.2.sw	config -state $n
		$mixd2.2.3.2.sk	config -state $n
		$mixd2.2.3.2.mi	config -state $n
		if {$mm_multichan} {
			$mixd2.2.3.2.zq	config -state $n
			$mixd2.2.3.2.tw	config -state $n
			$mixd2.2.3.2.ge	config -state $n
		}
		$mixd2.2.3.2.rf	config -state $n
		$mixd2.2.3.2.sf	config -state $n
		$mixd2.2.3.2.sn	config -state $n
		$mixd2.2.3.2.wf	config -state $n
		$mixd2.2.3.2.du	config -state $n
		$mixd2.2.3.2.ds	config -state $n
		$mixd2.2.3.2.nf	config -state $n
		$mixd2.2.3.2.cf	config -state $n
		$mixd2.2.3.2.lf	config -state $n
		$mixd2.2.3.2.ce	config -state $n
		$mixd2.2.3.2.cm	config -state $n
		$mixd2.2.3.2.nw	config -state $n
		$mixd2.2.3.2.nl	config -state $n
		$mixd2.2.3.2.nm	config -state $n
		$mixd2.2.3.2.si	config -state $n
		$mixd2.2.3.2.dd	config -state $n
		$mixd2.2.3.2.wi	config -state $n

		$mixd2.2.3.3.ab	config -state $n
		$mixd2.2.3.3.sl	config -state $n
		$mixd2.2.3.3.ss	config -state $n
		$mixd2.2.3.3.vv	config -state $n
		$mixd2.2.3.3.mm	config -state $n
		$mixd2.2.3.3.nn	config -state $n
		$mixd2.2.3.3.ua	config -state $n
		$mixd2.2.3.3.pm	config -state $n
		$mixd2.2.3.3.h1	config -state $n
		$mixd2.2.3.3.fm	config -state $n
		$mixd2.2.3.3.r1	config -state $n
		$mixd2.2.3.3.rc	config -state $n
		$mixd2.2.3.3.om	config -state $n
		$mixd2.2.3.3.mh	config -state $n
		$mixd2.2.3.3.mf	config -state $n
		$mixd2.2.3.3.rv	config -state $n
		$mixd2.2.3.3.mk	config -state $n
		$mixd2.2.3.3.ck	config -state $n
		$mixd2.2.3.3.ko	config -state $n
		$mixd2.2.3.3.sy	config -state $n
		$mixd2.2.3.3.co	config -state $zobo
		$mixd2.2.3.3.ij	config -state $n
		$mixd2.2.3.3.sj	config -state $n
		$mixd2.2.3.3.sz	config -state $n
	} else {
		$mixd2.2.hhh.t	config -state $n
		$mixd2.2.hhh.v	config -state $n

		$mixd2.2.3.1.rt	config -state $n
		$mixd2.2.3.1.gr	config -state $n
		$mixd2.2.3.1.gg	config -state $n
		$mixd2.2.3.1.xa	config -state $n
		$mixd2.2.3.1.xc	config -state $n

		$mixd2.2.3.2.ee	config -state $n
		$mixd2.2.3.2.es	config -state $n
		$mixd2.2.3.2.lu	config -state $n
		$mixd2.2.3.2.sm	config -state $n
		$mixd2.2.3.2.so	config -state $n
		$mixd2.2.3.2.ye	config -state $n
		$mixd2.2.3.2.zr	config -state $n
		$mixd2.2.3.2.po	config -state $n
		$mixd2.2.3.2.op	config -state $n
		$mixd2.2.3.2.sp	config -state $n
		$mixd2.2.3.2.fl	config -state $n
		$mixd2.2.3.2.sc	config -state $n
		$mixd2.2.3.2.sw	config -state $n
		$mixd2.2.3.2.sk	config -state $n
		$mixd2.2.3.2.mi	config -state $n
		if {$mm_multichan} {
			$mixd2.2.3.2.zq	config -state $n
			$mixd2.2.3.2.tw	config -state $n
			$mixd2.2.3.2.ge	config -state $n
		}
		$mixd2.2.3.2.om	config -state $n
		$mixd2.2.3.2.mh	config -state $n
		$mixd2.2.3.3.mf	config -state $n
		$mixd2.2.3.4.rv	config -state $n

		$mixd2.2.3.3.rf	config -state $n
		$mixd2.2.3.3.sf	config -state $n
		$mixd2.2.3.3.sn	config -state $n
		$mixd2.2.3.3.wf	config -state $n
		$mixd2.2.3.3.du	config -state $n
		$mixd2.2.3.3.ds	config -state $n
		$mixd2.2.3.3.nf	config -state $n
		$mixd2.2.3.3.cf	config -state $n
		$mixd2.2.3.3.lf	config -state $n
		$mixd2.2.3.3.ce	config -state $n
		$mixd2.2.3.3.cm	config -state $n
		$mixd2.2.3.3.nw	config -state $n
		$mixd2.2.3.3.nl	config -state $n
		$mixd2.2.3.3.nm	config -state $n
		$mixd2.2.3.3.si	config -state $n
		$mixd2.2.3.3.dd	config -state $n
		$mixd2.2.3.3.wi	config -state $n
		$mixd2.2.3.3.sy	config -state $n
		$mixd2.2.3.3.co	config -state $zobo

		$mixd2.2.3.4.ab	config -state $n
		$mixd2.2.3.4.sl	config -state $n
		$mixd2.2.3.4.ss	config -state $n
		$mixd2.2.3.4.vv config -state $n
		$mixd2.2.3.4.mm	config -state $n
		$mixd2.2.3.4.nn	config -state $n
		$mixd2.2.3.4.ua	config -state $n
		$mixd2.2.3.4.pm	config -state $n
		$mixd2.2.3.4.h1	config -state $n
		$mixd2.2.3.4.fm	config -state $n
		$mixd2.2.3.4.r1	config -state $n
		$mixd2.2.3.4.rc	config -state $n
		$mixd2.2.3.4.mk	config -state $n
		$mixd2.2.3.4.ck	config -state $n
		$mixd2.2.3.4.ko	config -state $n
		$mixd2.2.3.4.ij	config -state $n
		$mixd2.2.3.4.sj	config -state $n
		$mixd2.2.3.4.sz	config -state $n
	}
	bind $mixd2.1.see.1.seefile <Control-Key-p> {QikEditor play}
	bind $mixd2.1.see.1.seefile <Control-Key-P> {QikEditor play}
	bind $mixd2.1.see.1.seefile <Key-space>	  {QikEditor play}
	bind $mixd2.1.see.1.seefile <Control-Up>    {MixModify up    $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
	bind $mixd2.1.see.1.seefile <Control-Down>  {MixModify down  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
	bind $mixd2.1.see.1.seefile <Control-Left>  {MixModify left  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
	bind $mixd2.1.see.1.seefile <Control-Right> {MixModify right $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
	bind $mixd2.1.see.1.seefile <Control-Key-D> {MixModify delcom  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
	bind $mixd2.1.see.1.seefile <Control-Key-d> {MixModify delcom  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
	bind $mixd2.1.see.1.seefile <Control-Home>  {$mixd2.1.see.1.seefile.list yview moveto 0.0}
	bind $mixd2.1.see.1.seefile <Control-End>   {$mixd2.1.see.1.seefile.list yview moveto 1.0}
	bind $mixd2.1.see.1.seefile <Control-Key-t> {QikShowText}
	bind $mixd2.1.see.1.seefile <Control-Key-T> {QikShowText}
	bind $mixd2.1.see.1.seefile.list <Double-1> {PlaySndonQikEdit $mixd2.1.see.1.seefile.list %y}
	if {$longqik} {
		bind $mixd2.2.v <Control-Up>    {focus $mixd2.1.see.1.seefile; MixModify up    $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.2.v	<Control-Down>  {focus $mixd2.1.see.1.seefile; MixModify down  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.2.v	<Control-Left>  {focus $mixd2.1.see.1.seefile; MixModify left  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.2.v	<Control-Right> {focus $mixd2.1.see.1.seefile; MixModify right $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
	} else {
		bind $mixd2.2.hhh.v <Control-Up>    {focus $mixd2.1.see.1.seefile; MixModify up    $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.2.hhh.v	<Control-Down>  {focus $mixd2.1.see.1.seefile; MixModify down  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.2.hhh.v	<Control-Left>  {focus $mixd2.1.see.1.seefile; MixModify left  $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
		bind $mixd2.2.hhh.v	<Control-Right> {focus $mixd2.1.see.1.seefile; MixModify right $mixd2.1.see.1.seefile.list 0 $tempmix; set tempmix 1}
	}
	set qikedit_actv 1
	bind $mixd2.1.see.1.seefile.list <ButtonRelease-1> {}
	bind $mixd2.1.see.1.seefile.list <Double-1> {PlaySndonQikEdit $mixd2.1.see.1.seefile.list %y}

	if {$qikedit_hlp_actv} {
		PutHelpInActiveMode $qe
	}
	$qe.con config -command "DisableQikedit $qe"
}

proc MidiToTransposParamHelp {} {
	set msg "ENTERING TRANSPOSITION DATA FROM MIDI-ENTRY KEY\n"
	append msg "\n"
	append msg "To enter transposition data from MIDI key.\n"
	append msg "\n"
	append msg "(1) Play a SINGLE NOTE as REFERENCE pitch.\n"
	append msg "\n"
	append msg "(2) Enter melody line, defining transpositions\n"
	append msg "relative to this reference pitch.\n"
	append msg "\n"
	append msg "(3) Resulting transposition data file\n"
	append msg "are placed in TRANSPOSITION value box.\n"
	append msg "\n"
	append msg "(4) A loudness contour file is also made\n"
	append msg "reflecting duration & loudness of notes played.\n"
	append msg "and is placed in LOUDNESS CONTOUR value box,\n"
	append msg "if requested.\n"
	Inf $msg
}

proc DisableMidiTransposButton {f} {	
	bind $f.0 <ButtonPress-1>	"MidiToTransposParamHelp"
	bind $f.1.0 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.1.1 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.1.2 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.1.3 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.1.4 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.1.5 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.1.6 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.2.0 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.2.1 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.2.2 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.2.3 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.2.4 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.2.5 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.2.6 <ButtonPress-1> "MidiToTransposParamHelp"
	bind $f.3   <ButtonPress-1> "MidiToTransposParamHelp"
}

proc EnableMidiTransposButton {f} {	
	global evv
	bind $f.0 <ButtonPress-1>	"DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.1.0 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.1.1 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.1.2 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.1.3 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.1.4 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.1.5 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.1.6 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.2.0 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.2.1 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.2.2 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.2.3 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.2.4 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.2.5 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.2.6 <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
	bind $f.3   <ButtonPress-1> "DoTVCall $evv(MIDITOTRANSPOSPARAM) 6 $f 1"
}

################### DATA SETS PAGE development_version BELOW HEREH AND CHANGES TO HELP ABOVE

proc DisableScienceHelp {w} {
	global science_actv science_hlp_actv
	set g .show_brkfile2
	set j $g.btns2
	set k $g.btns3
	set y $g.btns4
	set x $g.btns9
	set z $g.outs

	bind $g.btns.es <ButtonRelease-1> {}
	bind $g.btns.nu <ButtonRelease-1> {}
	bind $g.btns.es <ButtonRelease-1> {}
	bind $g.btns.mod1 <ButtonRelease-1> {}
	bind $g.btns.mod2 <ButtonRelease-1> {}
	bind $g.btns.trn  <ButtonRelease-1> {}
#	bind $g.btns.spc  <ButtonRelease-1> {}
	bind $z.out		  <ButtonRelease-1> {}
	bind $z.ee		  <ButtonRelease-1> {}
	bind $z.all		  <ButtonRelease-1> {}
	bind $z.show	  <ButtonRelease-1> {}
	bind $z.hide	  <ButtonRelease-1> {}
	bind $z.top		  <ButtonRelease-1> {}
	if {[$z.toptest cget -bd] > 0} {
		bind $z.toptest	  <ButtonRelease-1> {}
	}
	bind $j.movie	  <ButtonRelease-1> {}
	bind $k.msp  	  <ButtonRelease-1> {}
	bind $y.zoom 	  <ButtonRelease-1> {}
	bind $x.frqa	  <ButtonRelease-1> {}	
	bind $x.frq		  <ButtonRelease-1> {}	

	set j 2
	set k 1
	set kk 0
	while {$k <= 128} {
		set item $g.btns$j
		append item ".$k"
		bind $item <ButtonRelease-1> {}
		incr k
		incr kk
		if {$kk >= 32} {
			incr j
			set kk 0
		}
	}
	set science_hlp_actv 0

	if {!$science_actv} {
		ReactivateScience $w
	}
	DisableHelp $w
}	

proc ReactivateScience {w} {
	global science_actv science_hlp_actv
	set g .show_brkfile2
	set j $g.btns2
	set k $g.btns3
	set y $g.btns4
	set x $g.btns9
	set z $g.outs
	set n "normal"

	$g.btns.es   config -state $n
	$g.btns.nu   config -state $n
	$g.btns.es   config -state $n
	$g.btns.mod1 config -state $n
	$g.btns.mod2 config -state $n
	$g.btns.trn  config -state $n
#	$g.btns.spc  config -state $n
	$z.out		 config -state $n
	$z.ee		 config -state $n
	$z.all		 config -state $n
	$z.show		 config -state $n
	$z.hide		 config -state $n
	$z.top		 config -state $n
	if {[$z.toptest cget -bd] > 0} {
		$z.toptest	 config -state $n
	}
	$j.movie	 config -state $n
	$y.zoom 	 config -state $n
	$k.msp  	 config -state $n
	$x.frq		 config -state $n

	set j 2
	set k 1
	set kk 0
	while {$k <= 128} {
		set item $g.btns$j
		append item ".$k"
		$item  config -state $n
		incr k
		incr kk
		if {$kk >= 32} {
			incr j
			set kk 0
		}
	}
	set science_actv 1
	if {$science_hlp_actv} {
		PutHelpInActiveMode $w
	}
	$g.btns.con config -command "DisableScience $w"
}	

proc DisableScience {w} {
	global science_actv science_hlp_actv
	set g .show_brkfile2
	set j $g.btns2
	set k $g.btns3
	set y $g.btns4
	set x $g.btns9
	set z $g.outs

	set d "disabled"

	$g.btns.es   config -state $d
	$g.btns.nu   config -state $d
	$g.btns.es   config -state $d
	$g.btns.mod1 config -state $d
	$g.btns.mod2 config -state $d
	$g.btns.trn  config -state $d
#	$g.btns.spc  config -state $d
	$z.out		 config -state $d
	$z.ee		 config -state $d
	$z.all		 config -state $d
	$z.show		 config -state $d
	$z.hide		 config -state $d
	$z.top		 config -state $d
	if {[$z.toptest cget -bd] > 0} {
		$z.toptest	 config -state $d
	}
	$j.movie	 config -state $d
	$y.zoom 	 config -state $d
	$k.msp  	 config -state $d
	$x.frq		 config -state $d

	set j 2
	set k 1
	set kk 0
	while {$k <= 128} {
		set item $g.btns$j
		append item ".$k"
		$item config -state $d
		incr k
		incr kk
		if {$kk >= 32} {
			incr j
			set kk 0
		}
	}
	set science_actv 0
	PutHelpInPassiveMode $w
	$g.btns.con config -command "ReactivateScience $w"
}	

proc ActivateScienceHelp {} {
	set g .show_brkfile2
	set z $g.outs
	set j $g.btns2
	set y $g.btns4
	set x $g.btns9
	set k $g.btns3

	bind $g.btns.es   <ButtonRelease-1> {ScH Quit 0}
	bind $g.btns.nu   <ButtonRelease-1>	{ScH NewCurves 0}
	bind $g.btns.mod1 <ButtonRelease-1>	{ScH Stage1 0}
	bind $g.btns.mod2 <ButtonRelease-1>	{ScH Stage2 0}
	bind $g.btns.trn  <ButtonRelease-1>	{ScH Transforms 0}
#	bind $g.btns.spc  <ButtonRelease-1>	{ScH Spectra 0}
	bind $z.out		  <ButtonRelease-1> {ScH DataOut 0}
	bind $z.ee		  <ButtonRelease-1> {ScH DataOutName 0}
	bind $z.all		  <ButtonRelease-1> {ScH DisplayAll 0}
	bind $z.show	  <ButtonRelease-1> {ScH Show 0}
	bind $z.hide	  <ButtonRelease-1> {ScH Hide 0}
	bind $z.top 	  <ButtonRelease-1> {ScH Max 0}
	if {[$z.toptest cget -bd] > 0} {
		bind $z.toptest	 <ButtonRelease-1> {ScH TestMax 0}
	}
	bind $j.movie	  <ButtonRelease-1> {ScH Movie 0}
	bind $y.zoom	  <ButtonRelease-1> {ScH Zoom 0}
	bind $k.msp  	  <ButtonRelease-1> {ScH MovieSpeed 0}
	bind $x.frqa	  <ButtonRelease-1> {ScH FreqShow 0}
	bind $x.frq		  <ButtonRelease-1> {ScH FreqShow 0}

	set j 2
	set k 1
	set kk 0
	while {$k <= 128} {
		set item $g.btns$j
		append item ".$k"
		bind $item  <ButtonRelease-1> "ScH DataShow $k"
		incr k
		incr kk
		if {$kk >= 32} {
			incr j
			set kk 0
		}
	}
}	

proc ScH {subject k} {
	set f .show_brkfile2.btns.help

	switch -- $subject {

		Quit {
			$f config -text "Abandon the currently displayed curves. (Control-Escape)"
		}
		NewCurves {
			$f config -text "Go to get new curves, saving current information (Escape)."
		}
		Stage1 {
			HelpCreateSpectrum
		}
		Stage2 {
			HelpGenerateSound
		}
		Transforms {
			HelpSaveUseTransforms
		}
		Spectra {
			$f config -text "Assemble successive spectra, interpolate, listen."
		}
		DataShow {
			$f config -text "If curve $k exists, display or hide it, and list data."
		}
		DataOut {
			$f config -text "Output spectral data files (text convertible to sound)."
		}
		DataOutName {
			$f config -text "Enter the name of a file for the new output data."
		}
		DisplayAll {
			$f config -text "Redisplay all the curves."
		}
		Show {
			$f config -text "Show curve selected with numbered button."
		}
		Hide {
			$f config -text "Hide curve selected with numbered button."
		}
		Max {
			$f config -text "Show display which has maximum value."
		}
		TestMax {
			$f config -text "Test sound output of maximal curves (to check levels)."
		}
		Movie {
			$f config -text "Display curve sequence as slow movie."
		}
		MovieSpeed {
			$f config -text "Set speed of movie display."
		}
		FreqShow {
			$f config -text "Show freq in displayed spectrum where mouse clicks."
		}
		Zoom {
			$f config -text "Zoom in display to specified range."
		}
	}
}


#############

proc HelpCreateSpectrum {} {
	set msg "CONVERTING DATA TO SOUND SPECTRUM\n"
	append msg "\n"
	append msg "Once you have established a transformation process\n"
	append msg "you can simply run it from the \"Save/Use Transform\" menu.\n"
	append msg "and play the sound output(s)\n"
	append msg "\n"
	append msg "This menu allows you to decide how to create the spectrum in a number of stages.\n"
	append msg "You can only do this with a SINGLE data set.\n"
	append msg "\n"
	append msg "CONVERTING A SINGLE SPECTRUM\n"
	append msg "\n"
	append msg "(0) Preliminaries\n"
	append msg "\n"
	append msg "Before you begin: set the sample rate and channel count\n"
	append msg "for the spectra you wish to synthesize.\n"
	append msg "\n"
	append msg "Conversion of the spectrum takes place in 4 stages.\n"
	append msg "YOU MUST APPLY EACH STAGE IN TURN.\n"
	append msg "\n"
	append msg "(1) Convert to sound-spectrum metric (Obligatory).\n"
	append msg "\n"
	append msg "This converts the raw data into the frequency range of the spectrum to be synthesized.\n"
	append msg "\n"
	append msg "(2) Modify spectral range. (Optional)\n"
	append msg "\n"
	append msg "Here you may modify or warp the frq range of the spectrum.\n"
	append msg "\n"
	append msg "(3) Smooth Curve (Obligatory)\n"
	append msg "\n"
	append msg "Here the data values are interpolated so that they adequately span\n"
	append msg "the spectral channels, ensuring the details of the spectral envelope\n"
	append msg "are adequately recorded in the available spectral channels.\n"
	append msg "\n"
	append msg "(3) Other modifications (Obligatory)\n"
	append msg "\n"
	append msg "Here you may isolate either the spectral peaks or the spectral troughs.\n"
	append msg "The peak (trough) data is used in the synthesis process.\n"
	append msg "\n"
	append msg "At the sound synthesis stage, you may make the spectral brightness\n"
	append msg "depend on the width of the spectral peaks (troughs) thus extracted.\n"
	append msg "However, if you want to do this, you must also\n"
	append msg "\"STORE PEAK WIDTHS\", at this stage.\n"
	append msg "\n"
	append msg "You may store the details of the conversion process at this stage\n"
	append msg "(\"Retain Pre-Sound Transform Sequence\")\n"
	append msg "or wait until sound has been generated, and store the conversion details\n"
	append msg "AND the synthesis parameters together.\n"
	append msg "\n"
	append msg "Once you have created and stored a transformation process\n"
	append msg "you may apply it to SEVERAL data sets at once\n"
	append msg "running it as the DEFAULT transform on the \"Save/Use Transform\" menu.\n"
	append msg "\n"
	Inf $msg
}

proc HelpGenerateSound {} {
	set msg "GENERATING SOUND FROM THE SPECTRUM\n"
	append msg "\n"
	append msg "This menu assumes that you have already converted your data\n"
	append msg "to a spectrum, on the \"Create/Modify Spectrum\" menu.\n"
	append msg "\n"
	append msg "DURATION OF OUTPUT SOUNDS\n"
	append msg "\n"
	append msg "Before you can generate sound you must specify the duration of the output.\n"
	append msg "\n"
	append msg "Conversion to sound takes place in TWO STAGES.\n"
	append msg "\n"
	append msg "(1) CONVERT TO PLAYABLE DATA\n"
	append msg "\n"
	append msg "This stage generates an analysis files with special markers\n"
	append msg "for the peaks and troughs of the spectrum.\n"
	append msg "\n"
	append msg "(2) CONVERT TO SOUND\n"
	append msg "\n"
	append msg "This stage interprets the spectral data to generate a playable output sound.\n"
	append msg "\n"
	append msg "Sound creation divides the spectrum into\n"
	append msg "\n"
	append msg "(1) Peaks (or troughs) which you have isolated.\n"
	append msg "(2) The remainder of the spectrum, the 'noise-background'\n"
	append msg "\n"
	append msg "To create the sound you will be asked to specify\n"
	append msg "\n"
	append msg "(1) The duration of the sound output.\n"
	append msg "(2) The number of harmonics to be added to peak (or trough) frequencies.\n"
	append msg "(3) Their brightness (relative loudness of successive harmonics).\n"
	append msg "(4) The frq spread of the peak pitches. If non-zero, peak pitches vary\n"
	append msg "        across a proportion of the peak's width, randomly through time.\n"
	append msg "\n"
	append msg "The amplitude of the noise-background can be made to fluctuate\n"
	append msg "          to (random) values lower than the amplitude curve of the spectrum.\n"
	append msg "\n"
	append msg "(5)\"Fraction of noise background fluctuating\"\n"
	append msg "          determines what proportion of these spectral channels fluctuate in this way.\n"
	append msg "(6)\"Max attenuation of fluctuating background\"\n"
	append msg "          determines the maximum level drop of these channels.\n"
	append msg "\n"
	append msg "(7)\"Overall attenuation of output\" allows the output level to be set\n"
	append msg "          to avoid overload distortion in the sound output.\n"
	append msg "\n"
	append msg "In addition, there are 6 options for determining peak constancy and brightness.\n"
	append msg "\n"
	append msg "(1) fixed brightness\n"
	append msg "(2) peakwidth determines brightness (narrower peaks are brighter)\n"
	append msg "(3) peak frq varies over the pkwidth, randomly through time\n"
	append msg "(4) frq of harmonics also vary over the pkwidth, randomly through time\n"
	append msg "(5) peakwidth determines brightness : frq varies over pkwidth\n"
	append msg "(6) peakwidth determines brightness : peak and harmonics also vary over pkwidth\n"
	append msg "\n"
	append msg "The sound may now by PLAYED (use the Space-bar)\n"
	append msg "\n"
	append msg "If you are satisfied with the result you can now \"SAVE+NAME THE CURRENT TRANSFORM\"\n"
	append msg "on the \"Save/Use Transform\" menu.\n"
	append msg "This saves the process of transformation AND the sound creation parameters.\n"
	append msg "\n"
	append msg "To apply it again, immediately, you need also to \"SET CURRENT TRANSFORM SEQUENCE AS DEFAULT\"\n"
	append msg "\n"
	append msg "The saved process can be applied, simultaneously, to SEVERAL data files.\n"
	append msg "\n"
	Inf $msg
}

proc HelpSaveUseTransforms {} {
	set msg "SAVING AND USING TRANSFORMS\n"
	append msg "\n"
	append msg "On this menu you can\n"
	append msg "\n"
	append msg "(1) Save a data-to-Sound transformation process you have just created.\n"
	append msg "\n"
	append msg "(2) Use an existing, named, transformation process\n"
	append msg "        applying it, simultaneously, to several data files.\n"
	append msg "\n"
	append msg "\"SAVE+NAME CURRENT TRANSFORM SEQUENCE\"\n"
	append msg "\n"
	append msg "Assumes you have just completed the steps of converting a spectrum\n"
	append msg "to a sound (see \"Create/Modify Spectrum\" and \"Generate Sound\" menus).\n"
	append msg "\n"
	append msg "You can name the transformation process you have just created,\n"
	append msg "and save it, so it can be recalled later.\n"
	append msg "\n"
	append msg "\"SET CURRENT TRANSFORM SEQUENCE AS DEFAULT\"\n"
	append msg "\n"
	append msg "In order to run your saved process again,\n"
	append msg "you must set it as the default, here.\n"
	append msg "\n"
	append msg "Previous named processes can also be recalled and run (see below).\n"
	append msg "\n"
	append msg "\"APPLY DEFAULT TRANSFORM SEQUENCE (#)\"\n"
	append msg "\n"
	append msg "Runs the data->sound transformation process you have set as the default.\n"
	append msg "\n"
	append msg "With several data files,you may choose between\n"
	append msg "(1) Creating 1 sound for each data file.\n"
	append msg "(2) Creating a single sound which fades from one data-set sound to the next\n"
	append msg "         in the order of the data-set listing.\n"
	append msg "\n"
	append msg "\"GET NAMED TRANSFORM SEQUENCE AS DEFAULT\"\n"
	append msg "\n"
	append msg "Lets you recall a previously saved (and named) transformation process\n"
	append msg "and use it to transform new data files.\n"
	append msg "\n"
	append msg "\"MODIFY LEVEL OF OUTPUT\"\n"
	append msg "\n"
	append msg "Lets you modify the output level from the transform.\n"
	append msg "\n"
	append msg "\"DELETE A NAMED TRANSFORM SEQUENCE\"\n"
	append msg "\n"
	append msg "Allows you to get rid of redundant transformation processes\n"
	append msg "(e.g. if better parameters are discovered for the wsork in hand).\n"
	append msg "\n"
	Inf $msg
}

################### TIMESERIES PAGE

proc DisableTsHelp {w} {
	global ts_actv ts_hlp_actv

	bind .ts.0.qu		<ButtonRelease-1> {}
	bind .ts.0.es		<ButtonRelease-1> {}
	bind .ts.0.k		<ButtonRelease-1> {}
	bind .ts.0.0.sav	<ButtonRelease-1> {}
	bind .ts.0.0.nnn	<ButtonRelease-1> {}
	bind .ts.0.0.eee	<ButtonRelease-1> {}
	bind .ts.0.0.lod	<ButtonRelease-1> {}
	bind .ts.a.1.ts		<ButtonRelease-1> {}
	bind .ts.a.1.sp		<ButtonRelease-1> {}
	bind .ts.a.1.zz		<ButtonRelease-1> {}
	bind .ts.a.2.go		<ButtonRelease-1> {}
	bind .ts.a.2.pp		<ButtonRelease-1> {}
	bind .ts.a.2.vv		<ButtonRelease-1> {}
	bind .ts.a.2.nn		<ButtonRelease-1> {}
	bind .ts.a.2.ee		<ButtonRelease-1> {}
	bind .ts.a.2.r1		<ButtonRelease-1> {}
	bind .ts.a.2.r2		<ButtonRelease-1> {}
	bind .ts.a.2.r3		<ButtonRelease-1> {}
	bind .ts.a.2a.ss	<ButtonRelease-1> {}
	bind .ts.a.2a.lo	<ButtonRelease-1> {}
	bind .ts.a.2a.strf  <ButtonRelease-1> {}
	bind .ts.a.2a.vts   <ButtonRelease-1> {}
	bind .ts.a.2a.dur   <ButtonRelease-1> {}
	bind .ts.a.2a.gpp   <ButtonRelease-1> {}
	bind .ts.a.2a.seq   <ButtonRelease-1> {}
	bind .ts.a.2a.mix   <ButtonRelease-1> {}
	bind .ts.a.2a.msp   <ButtonRelease-1> {}
	bind .ts.a.2a.ssm   <ButtonRelease-1> {}
	bind .ts.a.2a.chans <ButtonRelease-1> {}
	bind .ts.a.3.e		<ButtonRelease-1> {}
	bind .ts.a.3.e2		<ButtonRelease-1> {}
	bind .ts.a.4.cubic  <ButtonRelease-1> {}
	bind .ts.a.4.force  <ButtonRelease-1> {}
	bind .ts.a.4.dur	<ButtonRelease-1> {}
	bind .ts.a.5.ll		<ButtonRelease-1> {}
	bind .ts.a.5.e		<ButtonRelease-1> {}
	bind .ts.a.5.dro	<ButtonRelease-1> {}
	bind .ts.a.6.dro	<ButtonRelease-1> {}
	bind .ts.a.6.ll		<ButtonRelease-1> {}
	bind .ts.a.6.e		<ButtonRelease-1> {}
	bind .ts.a.7.ll		<ButtonRelease-1> {}
	bind .ts.a.7.e		<ButtonRelease-1> {}
	bind .ts.a.7.gf		<ButtonRelease-1> {}
	bind .ts.a.8.zz.sla <ButtonRelease-1> {}
	bind .ts.a.8.zz.sht <ButtonRelease-1> {}
	bind .ts.a.8.zz.lng <ButtonRelease-1> {}
	bind .ts.a.8.zz.lng2 <ButtonRelease-1> {}
	bind .ts.a.8.zz.see <ButtonRelease-1> {}
	bind .ts.a.8.zz.sec <ButtonRelease-1> {}

	bind .ts.b.0.1		<ButtonRelease-1> {}
	bind .ts.b.0.2		<ButtonRelease-1> {}
	bind .ts.b.0.3		<ButtonRelease-1> {}
	bind .ts.b.0.4		<ButtonRelease-1> {}
	bind .ts.b.0.5		<ButtonRelease-1> {}
	bind .ts.b.0.6		<ButtonRelease-1> {}
	bind .ts.b.0.7		<ButtonRelease-1> {}
	bind .ts.b.0.8		<ButtonRelease-1> {}
	bind .ts.b.0.9		<ButtonRelease-1> {}
	bind .ts.b.0.10		<ButtonRelease-1> {}
	bind .ts.b.0.11		<ButtonRelease-1> {}
	bind .ts.b.0.12		<ButtonRelease-1> {}
	bind .ts.b.0.13		<ButtonRelease-1> {}
	bind .ts.b.0.14		<ButtonRelease-1> {}
	bind .ts.b.0.15		<ButtonRelease-1> {}
	bind .ts.b.0.16		<ButtonRelease-1> {}
	bind .ts.b.0.17		<ButtonRelease-1> {}
	bind .ts.b.0.18		<ButtonRelease-1> {}
	bind .ts.b.0.19		<ButtonRelease-1> {}
	bind .ts.b.0.20		<ButtonRelease-1> {}
	bind .ts.b.0.a.21	<ButtonRelease-1> {}
	bind .ts.b.0.a.21loud <ButtonRelease-1> {}
	bind .ts.b.0.a.21spac <ButtonRelease-1> {}
	bind .ts.b.0x.other	<ButtonRelease-1> {}
	bind .ts.b.0a.rng	<ButtonRelease-1> {}
	bind .ts.b.1.p1		<ButtonRelease-1> {}
	bind .ts.b.1.ll1	<ButtonRelease-1> {}
	bind .ts.b.1.rmin	<ButtonRelease-1> {}
	bind .ts.b.1.min	<ButtonRelease-1> {}
	bind .ts.b.2.p2		<ButtonRelease-1> {}
	bind .ts.b.2.ll2	<ButtonRelease-1> {}
	bind .ts.b.2.rmax	<ButtonRelease-1> {}
	bind .ts.b.2.max	<ButtonRelease-1> {}
	bind .ts.b.3.p3		<ButtonRelease-1> {}
	bind .ts.b.3.ll3	<ButtonRelease-1> {}
	bind .ts.b.3.log	<ButtonRelease-1> {}
	bind .ts.b.4.p4		<ButtonRelease-1> {}
	bind .ts.b.4.ll4	<ButtonRelease-1> {}
	bind .ts.b.4.stp	<ButtonRelease-1> {}
	bind .ts.b.4.stl	<ButtonRelease-1> {}
	bind .ts.b.4a.cr	<ButtonRelease-1> {}
	bind .ts.b.4a.au	<ButtonRelease-1> {}
	bind .ts.b.01.rr	<ButtonRelease-1> {}
	bind .ts.b.01.ldur	<ButtonRelease-1> {}
	bind .ts.b.01.dur	<ButtonRelease-1> {}
	bind .ts.b.5.a.src	<ButtonRelease-1> {}
	bind .ts.b.5.a.eee	<ButtonRelease-1> {}
	bind .ts.b.5.run	<ButtonRelease-1> {}

	bind .ts.a.8.tit		<ButtonRelease-1> {}
	bind .ts.a.8.ss.ll.list	<ButtonRelease-1> {}
	bind .ts.a.8.ss.dd.list	<ButtonRelease-1> {}

	set ts_hlp_actv 0

	if {!$ts_actv} {
		ReactivateTs $w
	}
	DisableHelp $w
}	

proc ReactivateTs {w} {
	global ts_actv ts_hlp_actv tsoldloud tsoldspac

	set n "normal"

	.ts.0.qu	   config -state $n
	.ts.0.es	   config -state $n
	.ts.0.k		   config -state $n
	.ts.0.0.sav    config -state $n
	.ts.0.0.eee    config -state $n
	.ts.0.0.lod    config -state $n
	.ts.a.1.ts	   config -state $n
	.ts.a.1.sp	   config -state $n
	.ts.a.1.zz	   config -state $n
	.ts.a.2.go	   config -state $n
	.ts.a.2.pp	   config -state $n
	.ts.a.2.vv	   config -state $n
	.ts.a.2.nn	   config -state $n
	.ts.a.2.ee	   config -state $n
	.ts.a.2.r1	   config -state $n
	.ts.a.2.r2	   config -state $n
	.ts.a.2.r3	   config -state $n
	.ts.a.2a.ss	   config -state $n
	.ts.a.2a.lo	   config -state $n
	.ts.a.2a.strf  config -state $n
	.ts.a.2a.vts   config -state $n
	.ts.a.2a.dur   config -state $n
	.ts.a.2a.gpp   config -state $n
	.ts.a.2a.seq   config -state $n
	.ts.a.2a.mix   config -state $n
	.ts.a.2a.msp   config -state $n
	.ts.a.2a.ssm   config -state $n
	.ts.a.2a.chans config -state $n
	.ts.a.3.e	   config -state $n
	.ts.a.3.e2	   config -state $n
	.ts.a.4.cubic  config -state $n
	.ts.a.4.force  config -state $n
	.ts.a.4.dur		config -state $n
	.ts.a.5.e	   config -state $n
	.ts.a.5.dro	   config -state $n
	.ts.a.6.dro	   config -state $n
	.ts.a.6.e	   config -state $n
	.ts.a.7.e	   config -state $n
	.ts.a.7.gf	   config -state $n
	.ts.a.8.zz.sla config -state $n
	.ts.a.8.zz.sht config -state $n
	.ts.a.8.zz.lng config -state $n
	.ts.a.8.zz.lng2 config -state $n
	.ts.a.8.zz.see config -state $n
	.ts.a.8.zz.sec config -state $n

	.ts.b.0.1		config -state $n
	.ts.b.0.2		config -state $n
	.ts.b.0.3		config -state $n
	.ts.b.0.4		config -state $n
	.ts.b.0.5		config -state $n
	.ts.b.0.6		config -state $n
	.ts.b.0.7		config -state $n
	.ts.b.0.8		config -state $n
	.ts.b.0.9		config -state $n
	.ts.b.0.10		config -state $n
	.ts.b.0.11		config -state $n
	.ts.b.0.12		config -state $n
	.ts.b.0.13		config -state $n
	.ts.b.0.14		config -state $n
	.ts.b.0.15		config -state $n
	.ts.b.0.16		config -state $n
	.ts.b.0.17		config -state $n
	.ts.b.0.18		config -state $n
	.ts.b.0.19		config -state $n
	.ts.b.0.20		config -state $n
	.ts.b.0.a.21	config -state $n
	.ts.b.0.a.21loud config -state $tsoldloud
	.ts.b.0.a.21spac config -state $tsoldspac
	.ts.b.1.p1		config -state $n
	.ts.b.1.rmin	config -state $n
	.ts.b.2.p2		config -state $n
	.ts.b.2.rmax	config -state $n
	.ts.b.3.p3		config -state $n
	.ts.b.3.log		config -state $n
	.ts.b.4.p4		config -state $n
	.ts.b.4.stp		config -state $n
	.ts.b.4a.cr		config -state $n
	.ts.b.4a.au		config -state $n
	.ts.b.01.rr		config -state $n
	.ts.b.01.dur	config -state $n
	.ts.b.5.a.src	config -state $n
	.ts.b.5.a.eee	config -state readonly
	.ts.b.5.run		config -state $n

	.ts.a.8.ss.ll.list	config -state $n
	.ts.a.8.ss.dd.list	config -state $n

	set ts_actv 1
	if {$ts_hlp_actv} {
		PutHelpInActiveMode $w
	}
	.ts.0.con config -command "DisableTs $w"
}	

proc DisableTs {w} {
	global ts_actv tsoldloud tsoldspac

	set d "disabled"

	.ts.0.qu	   config -state $d
	.ts.0.es	   config -state $d
	.ts.0.k		   config -state $d
	.ts.0.0.sav    config -state $d
	.ts.0.0.eee    config -state $d
	.ts.0.0.lod    config -state $d
	.ts.a.1.ts	   config -state $d
	.ts.a.1.sp	   config -state $d
	.ts.a.1.zz	   config -state $d
	.ts.a.2.go	   config -state $d
	.ts.a.2.pp	   config -state $d
	.ts.a.2.vv	   config -state $d
	.ts.a.2.nn	   config -state $d
	.ts.a.2.ee	   config -state $d
	.ts.a.2.r1	   config -state $d
	.ts.a.2.r2	   config -state $d
	.ts.a.2.r3	   config -state $d
	.ts.a.2a.ss	   config -state $d
	.ts.a.2a.lo	   config -state $d
	.ts.a.2a.strf  config -state $d
	.ts.a.2a.vts   config -state $d
	.ts.a.2a.dur   config -state $d
	.ts.a.2a.gpp   config -state $d
	.ts.a.2a.seq   config -state $d
	.ts.a.2a.mix   config -state $d
	.ts.a.2a.msp   config -state $d
	.ts.a.2a.ssm   config -state $d
	.ts.a.2a.chans config -state $d
	.ts.a.3.e	   config -state $d
	.ts.a.3.e2	   config -state $d
	.ts.a.4.cubic  config -state $d
	.ts.a.4.force  config -state $d
	.ts.a.4.dur    config -state $d
	.ts.a.5.e	   config -state $d
	.ts.a.5.dro	   config -state $d
	.ts.a.6.dro	   config -state $d
	.ts.a.6.e	   config -state $d
	.ts.a.7.e	   config -state $d
	.ts.a.7.gf	   config -state $d
	.ts.a.8.zz.sla config -state $d
	.ts.a.8.zz.sht config -state $d
	.ts.a.8.zz.lng config -state $d
	.ts.a.8.zz.lng2 config -state $d
	.ts.a.8.zz.see config -state $d
	.ts.a.8.zz.sec config -state $d

	.ts.b.0.1		config -state $d
	.ts.b.0.2		config -state $d
	.ts.b.0.3		config -state $d
	.ts.b.0.4		config -state $d
	.ts.b.0.5		config -state $d
	.ts.b.0.6		config -state $d
	.ts.b.0.7		config -state $d
	.ts.b.0.8		config -state $d
	.ts.b.0.9		config -state $d
	.ts.b.0.10		config -state $d
	.ts.b.0.11		config -state $d
	.ts.b.0.12		config -state $d
	.ts.b.0.13		config -state $d
	.ts.b.0.14		config -state $d
	.ts.b.0.15		config -state $d
	.ts.b.0.16		config -state $d
	.ts.b.0.17		config -state $d
	.ts.b.0.18		config -state $d
	.ts.b.0.19		config -state $d
	.ts.b.0.20		config -state $d
	.ts.b.0.a.21	config -state $d
	set tsoldloud [.ts.b.0.a.21loud cget -state]
	set tsoldspac [.ts.b.0.a.21loud cget -state]
	.ts.b.0.a.21loud config -state $d
	.ts.b.0.a.21spac config -state $d
	.ts.b.1.p1		config -state $d
	.ts.b.1.rmin	config -state $d
	.ts.b.2.p2		config -state $d
	.ts.b.2.rmax	config -state $d
	.ts.b.3.p3		config -state $d
	.ts.b.3.log		config -state $d
	.ts.b.4.p4		config -state $d
	.ts.b.4.stp		config -state $d
	.ts.b.4a.cr		config -state $d
	.ts.b.4a.au		config -state $d
	.ts.b.01.rr		config -state $d
	.ts.b.01.dur	config -state $d
	.ts.b.5.a.src	config -state $d
	.ts.b.5.a.eee	config -state $d
	.ts.b.5.run		config -state $d

	.ts.a.8.ss.ll.list	config -state $d
	.ts.a.8.ss.dd.list	config -state $d

	set ts_actv 0
	PutHelpInPassiveMode $w
	.ts.0.con config -command "ReactivateTs $w"
}	

proc ActivateTsHelp {} {

	bind .ts.0.qu	    <ButtonRelease-1> {TsH Quit 0}
	bind .ts.0.es	    <ButtonRelease-1> {TsH EndSession 0}
	bind .ts.0.k	    <ButtonRelease-1> {TsH Shortcuts 0}
	bind .ts.0.0.sav    <ButtonRelease-1> {TsH SaveP 0}
	bind .ts.0.0.nnn    <ButtonRelease-1> {TsH SavePNam 0}
	bind .ts.0.0.eee    <ButtonRelease-1> {TsH SavePNam 0}
	bind .ts.0.0.lod    <ButtonRelease-1> {TsH LoadP 0}
	bind .ts.a.1.ts	    <ButtonRelease-1> {TsH Oscil 0}
	bind .ts.a.1.sp	    <ButtonRelease-1> {TsH Trace 0}
	bind .ts.a.1.zz	    <ButtonRelease-1> {TsH TraceP 0}
	bind .ts.a.2.go	    <ButtonRelease-1> {TsH Make 0}
	bind .ts.a.2.pp	    <ButtonRelease-1> {TsH Play 0}
	bind .ts.a.2.vv	    <ButtonRelease-1> {TsH View 0}
	bind .ts.a.2.nn	    <ButtonRelease-1> {TsH Save 0}
	bind .ts.a.2.ee	    <ButtonRelease-1> {TsH Name 0}
	bind .ts.a.2.r1	    <ButtonRelease-1> {TsH Generic 0}
	bind .ts.a.2.r2	    <ButtonRelease-1> {TsH Dataname 0}
	bind .ts.a.2.r3	    <ButtonRelease-1> {TsH Prefix 0}
	bind .ts.a.2a.ss	<ButtonRelease-1> {TsH SaveSet 0}
	bind .ts.a.2a.lo	<ButtonRelease-1> {TsH LoadSet 0}
	bind .ts.a.2a.strf  <ButtonRelease-1> {TsH Stretch 0}
	bind .ts.a.2a.vts   <ButtonRelease-1> {TsH SeeData 0}
	bind .ts.a.2a.dur   <ButtonRelease-1> {TsH SeeDur 0}
	bind .ts.a.2a.gpp   <ButtonRelease-1> {TsH Multichan 0}
	bind .ts.a.2a.seq   <ButtonRelease-1> {TsH Sequence 0}
	bind .ts.a.2a.mix   <ButtonRelease-1> {TsH Mix 0}
	bind .ts.a.2a.msp   <ButtonRelease-1> {TsH Spread 0}
	bind .ts.a.2a.ssm   <ButtonRelease-1> {TsH SaveMix 0}
	bind .ts.a.2a.chans <ButtonRelease-1> {TsH Chans 0}
	bind .ts.a.3.e	    <ButtonRelease-1> {TsH Tstretch 0}
	bind .ts.a.3.e2	    <ButtonRelease-1> {TsH Maxdur 0}
	if {[string length [.ts.a.4.cubic cget -text]] > 0} {
		bind .ts.a.4.cubic <ButtonRelease-1> {TsH Cubic 0}
	}
	if {[string length [.ts.a.4.force cget -text]] > 0} {
		bind .ts.a.4.force <ButtonRelease-1> {TsH Loop 0}
	}
	bind .ts.a.4.dur	   <ButtonRelease-1> {TsH InDur 0}
	if {[string length [.ts.a.5.ll cget -text]] > 0} {
		bind .ts.a.5.ll    <ButtonRelease-1> {TsH Frq 0}
		bind .ts.a.5.e     <ButtonRelease-1> {TsH Frq 0}
	}
	bind .ts.a.5.dro	     <ButtonRelease-1> {TsH OutDur 0}
	bind .ts.a.6.dro	     <ButtonRelease-1> {TsH OutDurMin 0}
	if {[string length [.ts.a.6.ll cget -text]] > 0} {
		bind .ts.a.6.ll    <ButtonRelease-1> {TsH Range 0}
		bind .ts.a.6.e     <ButtonRelease-1> {TsH Range 0}
	}
	if {[string length [.ts.a.7.ll cget -text]] > 0} {
		bind .ts.a.7.ll    <ButtonRelease-1> {TsH Partials 0}
		bind .ts.a.7.e     <ButtonRelease-1> {TsH Partials 0}
		bind .ts.a.7.gf    <ButtonRelease-1> {TsH HFileGet 0}
	}
	bind .ts.a.8.zz.sla    <ButtonRelease-1> {TsH All 0}
	bind .ts.a.8.zz.sht    <ButtonRelease-1> {TsH Shortest 0}
	bind .ts.a.8.zz.lng    <ButtonRelease-1> {TsH Longest 0}
	bind .ts.a.8.zz.lng2   <ButtonRelease-1> {TsH NextLongest 0}
	bind .ts.a.8.zz.see    <ButtonRelease-1> {TsH SeeDataAsSnd 0}
	bind .ts.a.8.zz.sec    <ButtonRelease-1> {TsH SeeControl 0}

	bind .ts.b.0.1		<ButtonRelease-1> {TsH Function1 0}
	bind .ts.b.0.2		<ButtonRelease-1> {TsH Function2 0}
	bind .ts.b.0.3		<ButtonRelease-1> {TsH Function3 0}
	bind .ts.b.0.4		<ButtonRelease-1> {TsH Function4 0}
	bind .ts.b.0.5		<ButtonRelease-1> {TsH Function5 0}
	bind .ts.b.0.6		<ButtonRelease-1> {TsH Function6 0}
	bind .ts.b.0.7		<ButtonRelease-1> {TsH Function7 0}
	bind .ts.b.0.8		<ButtonRelease-1> {TsH Function8 0}
	bind .ts.b.0.9		<ButtonRelease-1> {TsH Function9 0}
	bind .ts.b.0.10		<ButtonRelease-1> {TsH Function10 0}
	bind .ts.b.0.11		<ButtonRelease-1> {TsH Function11 0}
	bind .ts.b.0.12		<ButtonRelease-1> {TsH Function12 0}
	bind .ts.b.0.13		<ButtonRelease-1> {TsH Function13 0}
	bind .ts.b.0.14		<ButtonRelease-1> {TsH Function14 0}
	bind .ts.b.0.15		<ButtonRelease-1> {TsH Function15 0}
	bind .ts.b.0.16		<ButtonRelease-1> {TsH Function16 0}
	bind .ts.b.0.17		<ButtonRelease-1> {TsH Function17 0}
	bind .ts.b.0.18		<ButtonRelease-1> {TsH Function18 0}
	bind .ts.b.0.19		<ButtonRelease-1> {TsH Function19 0}
	bind .ts.b.0.20		<ButtonRelease-1> {TsH Function20 0}
	bind .ts.b.0.a.21	<ButtonRelease-1> {TsH Function21 0} 
	if {[string length [.ts.b.0.a.21loud cget -text]] > 0} {
		bind .ts.b.0.a.21loud <ButtonRelease-1> {TsH SeqAtten 0}
	}
	if {[string length [.ts.b.0.a.21spac cget -text]] > 0} {
		bind .ts.b.0.a.21spac <ButtonRelease-1> {TsH SeqSpace 0}
	}
	
	if {[string length [.ts.b.0x.other cget -text]] > 0} {
		bind .ts.b.0x.other	<ButtonRelease-1> {TsH Params 0}
	}
	if {[string length [.ts.b.0a.rng cget -text]] > 0} {
		bind .ts.b.0a.rng	<ButtonRelease-1> {TsH FuncRange 0}
	}
	if {[.ts.b.1.p1 cget -bd]} {
		bind .ts.b.1.p1		<ButtonRelease-1> {TsH ParamEntry 0}
	}
	if {[string length [.ts.b.1.ll1	cget -text]] > 0} {
		bind .ts.b.1.ll1	<ButtonRelease-1> {TsH ParamEntry 0}
	}
	if {[.ts.b.1.rmin	cget -bd]} {
		bind .ts.b.1.rmin	<ButtonRelease-1> {TsH RangeMin 0}
		bind .ts.b.3.log	<ButtonRelease-1> {TsH RangeLog 0}
	}
	if {[string length [.ts.b.1.min	cget -text]] > 0} {
		bind .ts.b.1.min	<ButtonRelease-1> {TsH RangeMin 0}
	}
	if {[.ts.b.2.p2		cget -bd]} {
		bind .ts.b.2.p2		<ButtonRelease-1> {TsH ParamEntry 0}
	}
	if {[string length [.ts.b.2.ll2	cget -text]] > 0} {
		bind .ts.b.2.ll2	<ButtonRelease-1> {TsH ParamEntry 0}
	}
	if {[.ts.b.2.rmax	cget -bd]} {
		bind .ts.b.2.rmax	<ButtonRelease-1> {TsH RangeMax 0}
	}
	if {[string length [.ts.b.2.max	cget -text]] > 0} {
		bind .ts.b.2.max	<ButtonRelease-1> {TsH RangeMax 0}
	}
	if {[.ts.b.3.p3	cget -bd]} {
		bind .ts.b.3.p3		<ButtonRelease-1> {TsH ParamEntry 0}
	}
	if {[string length [.ts.b.3.ll3	cget -text]] > 0} {
		bind .ts.b.3.ll3	<ButtonRelease-1> {TsH ParamEntry 0}
	}
	if {[.ts.b.4.p4	cget -bd]} {
		bind .ts.b.4.p4		<ButtonRelease-1> {TsH ParamEntry 0}
	}
	if {[.ts.b.4.stp cget -bd]} {
		bind .ts.b.4.stp	<ButtonRelease-1> {TsH BrkStep 0}
		bind .ts.b.4.stl	<ButtonRelease-1> {TsH BrkStep 0}
		bind .ts.b.4a.au	<ButtonRelease-1> {TsH AutoStep 0}
	}
	if {[string length [.ts.b.4.ll4	cget -text]] > 0} {
		bind .ts.b.4.ll4	<ButtonRelease-1> {TsH ParamEntry 0}
		bind .ts.b.4a.cr	<ButtonRelease-1> {TsH ClockRand 0}
	} elseif {[string match [.ts.b.4a.cr cget -text] "no repet"]} {
		bind .ts.b.4a.cr	<ButtonRelease-1> {TsH Qcompact 0}
	}
	bind .ts.b.01.ldur	<ButtonRelease-1> {TsH FuncDur 0}
	bind .ts.b.01.dur	<ButtonRelease-1> {TsH FuncDur 0}
	bind .ts.b.01.rr	<ButtonRelease-1> {TsH DurEq 0}
	if {[.ts.b.5.a.eee cget -bd] > 0} {
		bind .ts.b.5.a.src	<ButtonRelease-1> {TsH FuncSrc 0}
		bind .ts.b.5.a.eee	<ButtonRelease-1> {TsH FuncSrc 0}
	}
	bind .ts.b.5.run	<ButtonRelease-1> {TsH FuncRun 0}

	bind .ts.a.8.tit		<ButtonRelease-1> {TsH DataList 0}
	bind .ts.a.8.ss.ll.list	<ButtonRelease-1> {TsH DataList 0}
	bind .ts.a.8.ss.dd.list	<ButtonRelease-1> {TsH DataLen 0}
}	

proc TsH {subject k} {
	global tsdatatype
	set f .ts.0.help

	switch -- $subject {

		Quit {
			$f config -text "Return to Workspace"
		}
		EndSession {
			$f config -text "ENd the Session and Quit the Sound Loom"
		}
		Shortcuts {
			$f config -text "Keyboard Shortcuts on this page"
		}
		Oscil {
			$f config -text "Treat the data as an amplitude plot for a soundwave"
		}
		Trace {
			$f config -text "Treat the data as a pitch-trace for an oscillator"
		}
		TraceP {
			$f config -text "Treat each selected datafile as pitch-trace for a partial in partials file"
		}
		Make {
			$f config -text "Generate sound(s) from the selected data file(s)"
		}
		Play {
			$f config -text "Play the sound(s) generated"
		}
		View {
			$f config -text "View (and play) the sounds generated"
		}
		Save {
			$f config -text "Save the generated sounds to the workspace"
		}
		Name {
			$f config -text "A (generic) name, or (generic) prefix, for the sounds created"
		}
		Generic {
			$f config -text "Use the entered name as a (generic) name for the sounds created"
		}
		Dataname {
			$f config -text "Use the datafile name(s) as the name(s) for the soundfile(s)"
		}
		Prefix {
			$f config -text "Prefix name of datafile(s) used with given prefix, and use as sound name(s)"
		}
		SaveSet {
			$f config -text "Name and save the parameter settings used to generate sounds"
		}
		LoadSet {
			$f config -text "Load a named set of parameters to generate sounds"
		}
		Stretch {
			$f config -text "List possible time-streching files, and load a selected file"
		}
		SeeData {
			$f config -text "See data in currently selected file"
		}
		SeeDur {
			$f config -text "See (maximum) duration of output sound(s)"
		}
		Tstretch {
			$f config -text "Amount of timestrertching or downsampling to apply"
		}
		Maxdur {
			$f config -text "Set a maximum duration for the output sound(s)"
		}
		Cubic {
			$f config -text "Apply cubic-spline interpolation when timestretching the data"
		}
		Loop {
			$f config -text "Force the sound output duration to the givem maximum, looping if ness"
		}
		InDur {
			$f config -text "(Max) Duration of the input data, treated as samples at standard srate"
		}
		Frq {
			$f config -text "Centre frequency of the oscillator"
		}
		OutDur {
			$f config -text "(Max) Duration of the output sound(s), using given parameters"
		}
		OutDurMin {
			$f config -text "(Min) Duration of the output sound(s), using given parameters"
		}
		Range {
			$f config -text "Maximum digression of the oscillator pitch, in semitones"
		}
		Partials {
			if {$tsdatatype == 2} {
				$f config -text "Optional File of partials used in oscillator: = partial-number amplitude pairs"
			} else {
				$f config -text "Obligatory File of partials  = partial-number amplitude pairs: one for each datafile selected"
			}
		}
		HFileGet {
			$f config -text "List possible partials files and load selected file"
		}
		All {
			$f config -text "Select all the displayed datafiles, for processing"
		}
		Shortest {
			$f config -text "Select the shortest datafile displayed"
		}
		Longest {
			$f config -text "Select the longest datafile displayed"
		}
		NextLongest {
			$f config -text "Add next longest datafile to the selection"
		}
		Multichan {
			$f config -text "Play a group of sound outputs as a multichannel sound"
		}
		Sequence {
			$f config -text "Play group of sound outputs in a sequence"
		}
		Mix {
			$f config -text "Mix all the sound outputs"
		}
		Spread {
			$f config -text "Mix all sound outputs, spread across stereo stage"
		}
		Chans {
			$f config -text "Number of output sounds to play in groups"
		}
		Function1 {
			$f config -text "Texture of regularly-timed events: speed control by time-series data"
		}
		Function2 {
			$f config -text "Texture of events: speed (density) control by time-series data"
		}
		Function3 {
			$f config -text "Texture of events: pitch-range control by time-series data"
		}
		Function4 {
			$f config -text "Rising envelopes measured in wavesets: waveset-group-cnt controlled by data"
		}
		Function5 {
			$f config -text "Falling envelopes measured in wavesets: waveset-group-cnt controlled by data"
		}
		Function6 {
			$f config -text "Troughed envelopes measured in wavesets: waveset-group-cnt controlled by data"
		}
		Function7 {
			$f config -text "Wavesets replaced by silence: proportion of silence controlled by data"
		}
		Function8 {
			$f config -text "Loudness tremolo: frequency controlled by time-series data"
		}
		Function9 {
			$f config -text "Loudness tremolo: loudness-depth controlled by time-series data"
		}
		Function10 {
			$f config -text "Pitch vibrato: frequency controlled by time-series data"
		}
		Function11 {
			$f config -text "Pitch vibrato: pitch-depth controlled by time-series data"
		}
		Function12 {
			$f config -text "Read back and forth in sound: zig or zag ends determined by time-series data"
		}
		Function13 {
			$f config -text "Drunken walk through source: locus-at-which-file-is-read controlled by data"
		}
		Function14 {
			$f config -text "Drunken walk through source: ambitus-within-which-file-read controlled by data"
		}
		Function15 {
			$f config -text "Drunken walk through source: length-of-segments-read controlled by data"
		}
		Function16 {
			$f config -text "Filterbank of harmonics of a pitch: Q controlled by time-series data"
		}
		Function17 {
			$f config -text "Filterbank of subharmonics: Q controlled by time-series data"
		}
		Function18 {
			$f config -text "Spectral shift of analysis file: shift controlled by time-series data"
		}
		Function19 {
			$f config -text "Spectral stretch of analysis file: stretch controlled by time-series data"
		}
		Function20 {
			$f config -text "Mix of TWO source sounds: balance controlled by time-series data"
		}
		Function21 {
			$f config -text "Sequencing of several sounds: sequence controlled by time-series data"
			set msg "     SEQUENCE FUNCTION\n"
			append msg "\n"
			append msg "Unlike other functions, takes several source-snd files\n"
			append msg "and generates a sequence of them controlled by a data file.\n"
			append msg "\n"
			append msg "(It is also possible to select a set of sounds\n"
			append msg "listed in a snd-listing textfile - use \"Sndlist files\" option\n"
			append msg "on the sources listing page).\n"
			append msg "\n"
			append msg "There are 3 different options\n"
			append msg "\n"
			append msg "(1) Select a number of source-snds (or a SINGLE snd-listing).\n"
			append msg "       Select 1 or several data files.\n"
			append msg "       A datafile controls which sound is selected\n"
			append msg "       at each moment in the output.\n"
			append msg "       Produces an output-sound for each data file used,\n"
			append msg "       all outputs using the selected src-sounds.\n"
			append msg "\n"
			append msg "(2) Select a number of source-snds (or a SINGLE snd-listing)\n"
			append msg "       Activate \"ATTEN\" and/or \"SPACE\" on the interface.\n"
			append msg "       Select a specific number of data files.\n"
			append msg "       The first datafile controls which sounds is selected\n"
			append msg "       at each moment in the output.\n"
			append msg "       The other selected datafiles control the level AND/OR position\n"
			append msg "       of the selected items.\n"
			append msg "       Produces a SINGLE output-sound, using the selected src-sounds.\n"
			append msg "\n"
			append msg "(3) If SEVERAL (more than one) snd-listings are selected\n"
			append msg "       The datafile controlling the sound-sequencing\n"
			append msg "       controls which GROUP of sounds is selected from\n"
			append msg "       at each moment in the output.\n"
			append msg "\n"
			Inf $msg
		}
		Params {
			$f config -text "Fixed Parameters for a Process applied to a sound"
		}
		FuncRange {
			$f config -text "Range of the parameter controlled by the time-series data"
		}
		ParamEntry {
			$f config -text "Fixed Parameter for a Process applied to sound"
		}
		RangeMin {
			$f config -text "Minimum of range of parameter controlled by time-series data"
		}
		RangeMax {
			$f config -text "Maximum of the range of parameter controlled by time-series data"
		}
		FuncDur {
			$f config -text "Output duration: determines time-stretch of longest datafile"
		}
		FuncSrc {
			$f config -text "Sound(s) to be modified by process (selected above) controlled by time-series data"
		}
		FuncRun {
			$f config -text "Run a process, controlled by time0-series data, on a sound."
		}
		DataList {
			TimeSeriesOptions
		}
		DataLen {
			$f config -text "Length of data in time-series data files."
		}
		DurEq  {
			$f config -text "For >1 files: All outputs same duration: else durs relate to data length"
		}
		RangeLog {
			$f config -text "Scan range values logarithmically, when mapping to control file"
		}
		LoadP {
			$f config -text "Load a previously used control-file process"
		}
		SaveP {
			$f config -text "Save the recently run control-file process"
		}
		SavePNam {
			$f config -text "Name for a process which is to be saved"
		}
		ClockRand {
			$f config -text "Randomise Clockrate for Drunkwalk"
		}
		BrkStep {
			$f config -text "Time step between entries in datafile"
		}
		SeeDataAsSnd {
			$f config -text "View data file as if it were a soundfile (scaled between -1 and 1)"
		}
		SeeControl {
			$f config -text "List last control file generated from data"
		}
		AutoStep {
			$f config -text "Set step through (shortest) datafile, to reach end at end of specified duration"
		}
		SaveMix {
			$f config -text "Save any output mix made (stereo, sequential or multichannel)"
		}
		Qcompact {
			$f config -text "On selecting sounds (or groups) to sequence, sound-(group)-repetitions are eliminated."
		}
		SeqAtten {
			$f config -text "Apply another selected data files to control levels in sound-sequence."
		}
		SeqSpace {
			$f config -text "Apply different data files to control spatial positions in sound-sequence."
		}
	}
}

proc TimeSeriesOptions {} {
	set msg "       TIME SERIES DATA FILES FROM WORKSPACE CHOSEN LIST\n"
	append msg "\n"
	append msg "For DATA AS SOUND\n"
	append msg "\n"
	append msg "Choose any number of data files, to convert to sound.\n"
	append msg "\n"
	append msg "For DATA AS CONTROL FILE\n"
	append msg "\n"
	append msg "Choose either.\n"
	append msg "\n"
	append msg "(1) Any number of data files, to control ONE source sound.\n"
	append msg "        (or TWO sounds, in case of mixing process \[20\]).\n"
	append msg "\n"
	append msg "(2) ONE data file to control SEVERAL source sounds.\n"
	append msg "\n"
	append msg "(3) N data files, each controlling just one of N source sounds.\n"
	append msg "        (NOT applicable to mixing process).\n"
	Inf $msg
}
