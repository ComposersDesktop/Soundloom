#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#################
#	HISTORY		#
#################

#------ Administrate logs
#
#	 --------------------------------------------------------------
#	|						|									   |
#	| 	   THIS SESSION		|  		 	PREVIOUS SESSIONS		   |
#	|	   -----------		|	 ----  ------  ----------  ------- |
#	|	  |  SHOW LOG |		|	|QUIT|| SHOW ||(logname) ||DESTROY||
#	|	   -----------		|	 ----  ------  ----------  ------- |
#	|	 ---------------	|	 -------------------------------   |
#	|	| DUPLICATE LOG |	|	|			Log listing			|  |
#	|	 ---------------	|	|								|  |
#	|	dir	 [__________]	|	|								|  |
#	|	  -------------		|	|								|  |
#	|	 | DESTROY LOG |	|	|								|  |
#	|	  -------------		|	|								|  |
#	|	 ---------------	|	|								|  |
#	|	|SAVE TEXTFILES |	|	|								|  |
#	|	 ---------------	|	|								|  |
#	|	file [__________]	|	|								|  |
#	|		   				|	 -------------------------------   |
#	 --------------------------------------------------------------
#															   

proc DoLogCull {ending} {
	global log_complete pr_complete bakdir sl_real evv 
	global hst logs_count readonlyfg readonlybg

	if {!$sl_real} {
		Inf "The Soundloom Keeps A Date-and-Time-Stamped Record Of All Your Actions In A Session.\nYou Can Delete Any Of These 'Logs' When You No Longer Need Them."
		return
	}
	if {$ending} {
		wm title .blocker "Assembling All Logs"
	} else {
		Block "Assembling All Logs"
	}
	set f .log_complete
	eval {toplevel $f} -borderwidth $evv(BBDR)
	wm protocol $f WM_DELETE_WINDOW {set pr_complete 1}
	wm resizable $f 1 1
	wm title $f "Sort out Logs"

	set head [frame $f.head -borderwidth $evv(BBDR)]
	frame $f.line0 -height 1 -bg [option get . foreground {}]
	button $head.qu	 -text "Close" 	 	 -command "set pr_complete 1" -highlightbackground [option get . background {}]
	pack $head.qu -side top
	pack $f.head -side top
	pack $f.line0 -side top -fill x -expand true
	set prev [frame $f.prev -borderwidth $evv(BBDR)]
	if {$ending && [info exists hst(fileId)]} {
		set this [frame $f.this -borderwidth $evv(BBDR)]
		frame $f.line -width 1 -bg [option get . foreground {}]
		label  $this.lab -text "THIS SESSION" -width 12 -justify center -fg $evv(SPECIAL)
		button $this.pl	 -text "Show Current Log" 		 -command "PrintLog today" -highlightbackground [option get . background {}]
		button $this.dl	 -text "Destroy Current Log" 	 -command "DestroyTodaysLog $this" -highlightbackground [option get . background {}]
		pack $this.lab $this.pl $this.dl -side top -fill x
		pack $f.this -side left -fill both
		pack $f.line -side left -fill y -expand true
		pack $f.prev -side left -fill both
	} else {
		pack $f.prev -side left -fill both
	}

	label  $prev.lab -text "PREVIOUS SESSIONS" -width 17 -justify center  -fg $evv(SPECIAL)
	set btns [frame $prev.btns -borderwidth $evv(SBDR)]
	set btns1 [frame $prev.btns1 -borderwidth $evv(SBDR)]
	set btns2 [frame $prev.btns2 -borderwidth $evv(SBDR)]
	set btns2a [frame $prev.btns2a -borderwidth $evv(SBDR)]
	set btns3 [frame $prev.btns3 -borderwidth $evv(SBDR)]
	entry $prev.e  -textvariable hst(chosenname) -width 24 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	set ll [Scrolled_Listbox $prev.ll -width 24 -height 20 -selectmode single]
	pack $prev.lab $prev.btns $prev.btns1 $prev.btns2 $prev.btns2a $prev.btns3 $prev.e $prev.ll -side top

	button $btns.pl	 -text "Show Selected Log" 	 -width 22 -command "PrintLog past" -highlightbackground [option get . background {}]
	button $btns.dl	 -text "Destroy Selected Log" -width 22 -command "DestroyLog $ll $prev.e" -highlightbackground [option get . background {}]
	pack $btns.pl $btns.dl -side left -padx 1 -pady 2
	label $btns1.ll -text "MULTIPLE DELETIONS"
	pack $btns1.ll -side top -pady 2
	button $btns2.dd	 -text "All Logs On Day of Selected Log"  -width 40 -command "DestroyLogDay $ll $prev.e" -highlightbackground [option get . background {}]
	button $btns2a.db	 -text "All Before Date/Time Selected Log" -width 40 -command "DestroyLogBefore $ll $prev.e 0" -highlightbackground [option get . background {}]
	button $btns3.da	 -text "All At & After Date/Time Selected Log" -width 40 -command "DestroyLogBefore $ll $prev.e 1" -highlightbackground [option get . background {}]
	pack $btns2.dd -side top -padx 1 -pady 2
	pack $btns2a.db  -side top -padx 1 -pady 2
	pack $btns3.da -side left -padx 1 -pady 2

	bind $ll <ButtonRelease-1> {GetLogName %W .log_complete.prev.e}
	set logs_count 0
	incr logs_count	;#	TODAY'S
	foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(LOGDIR) "*"]]] {
		set fnam [file tail $fnam]
		if {![string match $fnam $hst(todaysname)]
		&&	![string match $fnam $evv(LOGCOUNT_FILE)$evv(CDP_EXT)]
		&&	![string match $fnam $evv(LOGSCNT_FILE)$evv(CDP_EXT)]} {	;#	List all logfiles except today's
			lappend logfile_list $fnam
			incr logs_count
		}
	}
	set logfile_list [SortLogList $logfile_list]
	foreach fnam $logfile_list {
		$ll insert end $fnam
	}		
	if {!$ending} {
		UnBlock
	}
	$ll yview moveto 1
	set hst(chosenname) ""
	ForceVal $prev.e $hst(chosenname)
	set pr_complete 0
	raise $f
	My_Grab 0 $f pr_complete
	tkwait variable pr_complete
	set qq1 [expr round(floor($logs_count / $evv(LOGS_MAX)))]	;#	e.g. 47 /int 10 = 4(qq1)
	set qq2 [expr round($qq1 * $evv(LOGS_MAX))]					;#	e.g. 4 * 10 = 40(qq2)
	if {$qq2 != $logs_count} {									;#	e.g. 40 != 47
		incr qq1												;#	e.g. 4+1  = 5(qq1)
		set qq2 [expr round($qq1 * $evv(LOGS_MAX))]				;#	e.g. 5 * 10 = 50	
	}															;#	THIS_LOGS_MAX is a multiple of LOGS_MAX
	set evv(THIS_LOGS_MAX) $qq2									;#	>= current  number of logs
	My_Release_to_Dialog $f
	destroy $f
}

#------ Show the current log on terminal

proc PrintLog {type} {
	global pr_zeehis log_zee hst evv
	
	switch -- $type {
		today {
			if {![info exists hst] || ![info exists hst(todaysname)]} {
				Inf "Sorry: can't find today's log"
				return
			}
			set name $hst(todaysname)
		}
		past {
			set name $hst(chosenname)
			if {[string length $name] <= 0} {
				Inf "No logname selected"
				return
			}
		}
	}
	set f .log_zee
	eval {toplevel $f} -borderwidth 5
	wm protocol $f WM_DELETE_WINDOW {set pr_zeehis 1}
	wm title $f "$name"
	set b [frame $f.b]
	set k [frame $f.k]		
	pack $f.b $f.k -side top -fill x
	button $b.ok -text "OK" -command "set pr_zeehis	1" -highlightbackground [option get . background {}]
	pack $b.ok -side top
	set t [Scrolled_Listbox $k.t -width 164 -height 14 -selectmode single]
	pack $k.t -side top
	set fullname [file join $evv(LOGDIR) $name]
	if [catch {open $fullname r} fileId] {
		Inf "Cannot open file '$name'"
		destroy $f
		return
	}
	set is_progline 1
	while {[gets $fileId line] >= 0} {
		if {$is_progline} {
			set prog_outline [GetProglineDisplay $line]
			set is_progline 0
		} else {
			if {[string match [lindex $prog_outline 0] "SLOOM:"]} {
				$t insert end $prog_outline
				set is_progline 1
				continue
			}
			if {[llength $line] > $evv(MAX_HDISPLAY_OUTFILES)} {
				set j $evv(MAX_HDISPLAY_OUTFILES)
				incr j -1
				set outline [lrange $line 0 $j]
				set outline [concat $outline "ETC"]
			} else {
				set outline $line
			}
			set outline [concat $prog_outline " -->>OUTPUTS: " $outline]
			$t insert end $outline
			set is_progline 1
		}
	}
	close $fileId
	set pr_zeehis 0
	raise $f
	My_Grab 0 $f pr_zeehis $t
	tkwait variable pr_zeehis
	My_Release_to_Dialog $f
	destroy $f
}
 
#------ Display the program line in a user-friendly form

proc GetProglineDisplay {progline} {
	global evv

	if {[string match [lindex $progline 0] "SLOOM:"]} {
		return $progline
	}
	return [SimplifyLogViewLine $progline]
}

#------ Destroy todays log file.

proc DestroyTodaysLog {f} {
	global hst wstk evv

	if {[string length $hst(todaysname)] <= 0} {
		Inf "No log name entered."
		return
	}
	set choice [tk_messageBox -type yesno -message "Are you sure you want to DESTROY this log: forever !" \
		-icon question -parent [lindex $wstk end]]
	if {$choice == "no"} {
		return
	}
	catch {close hst(fileId)}
	DoLogDeletion $hst(todaysname)
	$f.pl config -state disabled
	$f.dl config -state disabled
}

#------ Destroy an existing log file.

proc DestroyLog {ll b} {
	global hst wstk evv
	if {[string length $hst(chosenname)] <= 0} {
		Inf "No log name selected"
		return
	}
	set choice [tk_messageBox -type yesno -message "Are you sure you want to DESTROY this log: forever !" \
				-icon question -parent [lindex $wstk end]]
	if {$choice == "no"} {
		return
	}
	DoLogDeletion $hst(chosenname) $ll $b
}

#------ Delete a named log file, and delete reference to it in log-counts file

proc DoLogDeletion {name args} {
	global logs_count hst evv

	set thislogfile [file join $evv(LOGDIR) $name]

	if {[string match $name $hst(name)]} {
		Inf "Cannot delete log file $name now as it has been opened.\nDelete in your next session"
		return
	} elseif [catch {file delete -force $thislogfile} x] {
		Inf "Cannot delete log file $name now"
		return
	}
	set logcnt_filename [file join $evv(LOGDIR) $evv(LOGCOUNT_FILE)$evv(CDP_EXT)]
	if [catch {open $logcnt_filename r} logcntId] {
		Inf "Cannot open log count file."
		return
	}
	set found 0
	while {[gets $logcntId line] >= 0} {
		if {![string match $name [lindex $line 0]]} {
			lappend temp_store $line
		}
	}
	close $logcntId
	if [catch {open $evv(DFLT_TMPFNAME) w} fileId] {
		Inf "Cannot open temporary file while altering log count file."
		return
	} else {
		if [info exists temp_store] {
			foreach line $temp_store {
				puts $fileId $line
			}
		}
		close $fileId
		if [catch {file delete $logcnt_filename}] {
			ErrShow "Cannot delete existing log-counting file $logcnt_filename: Continue"
			return
		}
		if [catch {file rename $evv(DFLT_TMPFNAME) $logcnt_filename}] {
			ErrShow "Failed to save new log-counting file: Serious problem"
			return
		}
	}
	incr logs_count -1

	if {[llength $args] > 0} {
		set listing [lindex $args 0]
		set indx [$listing curselection]
		if {[string length $indx] > 0 } {
			$listing delete $indx
			set entri [lindex $args 1]
			set hst(chosenname) ""
			ForceVal $entri $hst(chosenname)
		}
	}
}

#------ Save final part of hst, at end of session

proc FinalHistoryStorage {} {
	global hst evv memory

	if {![string match $hst(name) $hst(todaysname)]} {	 ;#	If in midst of another hst
		catch {close $hst(fileId)}							 ;#	Restore todays logfile
		if [catch {open [file join $evv(LOGDIR) $hst(todaysname)] a} hst(fileId)] {
			ErrShow "Can't open file $hst(todaysname) to save (remainder of) today's session log."
			return												 
		}
		set hst(cnt) $hst(saved_cnt)					 ;# and todays hst-cnt
	}															 
																 ;#	Open the hst-COUNT file
	set linecnt $memory(cnt)									 ;#	Count the items in active-memory
	incr linecnt $memory(cnt)									 ;#	Double it: 2 lines per hst

	if {$linecnt > 0} {
		if [catch {open [file join $evv(LOGDIR) $evv(LOGCOUNT_FILE)$evv(CDP_EXT)] a} logcntId] {
			ErrShow "Cannot open file $evv(LOGCOUNT_FILE)$evv(CDP_EXT) to save count of today's session log."
		}
		set i 0									
		while {$i < $linecnt} {										 ;#	Store active-memory in hst
			puts $hst(fileId) "[lindex $memory(current) $i]"
			incr i							
		}
		incr hst(cnt) $memory(cnt) 								 ;#	Add active-memory to existing hst
		if {$hst(cnt) > 0} {
			lappend thisline $hst(todaysname) $hst(cnt)			 
			puts $logcntId "$thisline"					 			 ;#	Store name of log & its count 
		}
		close $logcntId
	}
	catch {close $hst(fileId)}
	if {$hst(cnt) <= 0} {
		set zz_fnam [file join $evv(LOGDIR) $hst(todaysname)]
		file stat $zz_fnam filestatus
		catch {close $filestatus(ino)}
		catch {file delete $zz_fnam}
		unset hst(fileId)		
	}
}

#------ Open file to record today's hst information

proc EstablishLog {f} {
	global CDPid logwindow pr_log hst memory logname logname_got do_log_cull
	global wstk firstlog cf2 automatic_logname_generation evv

	if {$automatic_logname_generation} {
#LISTINGS EMERGENCY MAY 2007
		LognameDerive
		set hst(todaysname) $logname
		if [catch {open [file join $evv(LOGDIR) $hst(todaysname)] a} hst(fileId)] {
			Inf "Cannot open log file $logname"
 			set automatic_logname_generation 0
		} else {
			set hst(cnt) 0
		}
	}
	set finished 0
	if {!$automatic_logname_generation} {
		$f.t config -text "Please enter a name for today's session."
		entry $f.e -textvariable logname -state normal
		pack $f.e -side left

		bind $f.e <Return> {}
		bind $f.e <Return> {set pr_log 1}

		set logname ""
		ForceVal $f.e $logname
		set pr_log 0
		focus $f.e
		while {!$finished} {
			tkwait variable pr_log
			set logname [FixTxt $logname "name"]
			if {[string length $logname] <= 0} {
				ForceVal $f.e $logname
				continue
			}
			set fileOK 1
			set llogname [string tolower $logname]
			foreach fnam [glob -nocomplain [file join $evv(LOGDIR) *]] {
				set fnm [string tolower [file tail $fnam]]
				if [string match $fnm $llogname] {
					if {[string match $llogname [string tolower $evv(LOGSCNT_FILE)$evv(CDP_EXT)]]
					|| [string match $llogname [string tolower $evv(LOGCOUNT_FILE)$evv(CDP_EXT)]]} {
						Inf "This is a reserved filename: please choose another"
						set fileOK 0
						break
					} else {
						set choice [tk_messageBox -type yesno -message "This session already exists: Overwrite it?" \
								-parent [lindex $wstk end]]
						if {$choice == "yes"} {
							if {[AreYouSure]} {
								file stat $fnam	filestatus
								if {$filestatus(ino) >= 0} {
									catch {close $filestatus(ino)}
								}
					
								if [catch {file delete $fnam} zorg] {
									Inf "Cannot delete the existing session log"
									set fileOK 0
								}
							} else {
								set fileOK 0
							}
						} else {
							set logname ""
							ForceVal $f.e $logname
							set fileOK 0
						}
						break
					}
				}
			}
			if {$fileOK} {
				set hst(todaysname) $logname
				if [catch {open [file join $evv(LOGDIR) $hst(todaysname)] a} hst(fileId)] {
					Inf "Cannot open log file '$logname'"
				} else {
					set finished 1
				}
				set hst(cnt) 0
			}
		}
	}
	set hst(name) $hst(todaysname)
	set hst(is_todays_latest) 1
	set memory(cnt) 	 0
	set hst(active)	 0
	set hst(baktrak) 0
	set hst(blokno) "End"
}

#------ Return date logname	: OLD

proc SetLogname {} {
	global CDPid logname logname_got
	if [eof $CDPid] {
		set logname_got 1
		catch {close $CDPid}
		return
	} else {
		while {[gets $CDPid line] >= 0} {
			set logname [string trim $line]
		}
	}
}			

#------ Edit Previous Logs

proc EditLogs {} {
	global sl_real evv

	if {!$sl_real} {
		Inf "The Soundloom Keeps A Record Of All Your Actions In Each Session You Run, As A 'Log'.\nYou Can Delete Any Or All Of These 'Logs' When They Are No Longer Required."
		return
	}
	if [catch {open [file join $evv(LOGDIR) $evv(LOGSCNT_FILE)$evv(CDP_EXT)] w} fileId] {
		ErrShow "Cannot open log counting file $evv(LOGSCNT_FILE)$evv(CDP_EXT)"
		return
	}
	DoLogCull 0
	puts $fileId $evv(THIS_LOGS_MAX)
	catch {close $fileId}
}

#################################
# SAVING HISTORY INFORMATION	#
#################################

#------ Save half of current hst (appending) to log file
#	Instrument History = 
#	LINE 1: Instrumentname infilecnt infilenames (ins)params(only)
#	LINE 2: Name-conversions ofKeptFiles
#
#	Process History = 
#	LINE 1: Process cmdline
#	LINE 2: Name-conversions ofKeptFiles
#

proc DoHistory {} {
	global memory ins saved_cmd hst bulk from_instr is_blocked is_dummy_history inside_ins_create evv				

	if {[info exists saved_cmd] && [IsMchanToolkitProgname [lindex $saved_cmd 0]]} {
		return
	}
	if {$bulk(run) && !$is_dummy_history} {
		set cnt 0
		lappend memory(current) "SLOOM: BULK PROCESS FOLLOWS"
		lappend memory(current) "SLOOM: BULK PROCESS FOLLOWS"
		incr memory(cnt)
		if {$memory(cnt) >= $evv(MAX_HISTORY_SIZE)} {
			UpdateLog
		}
		foreach saved_cmd $hst(bulk) outf $hst(bulkout) {
			if [regexp {\->} $outf] {
				lappend memory(current) $saved_cmd
				lappend memory(current) $outf
				incr memory(cnt)
				if {$memory(cnt) >= $evv(MAX_HISTORY_SIZE)} {
					UpdateLog
				}
				incr cnt
			}
		}
		lappend memory(current) "SLOOM: BULK PROCESS WAS APPLIED TO $cnt FILES"
		lappend memory(current) "SLOOM: BULK PROCESS WAS APPLIED TO $cnt FILES"
		incr memory(cnt)
		if {$memory(cnt) >= $evv(MAX_HISTORY_SIZE)} {
			UpdateLog
		}
		set hst(active) 0
		return
	}
	if {$ins(create)} {
		set ins_create_concluded 0
		if {[info exists ins(name)]} {
			set createins_cmd $ins(name)
			if [info exists hst(ins_infiles)] { 
				lappend createins_cmd [llength $hst(ins_infiles)]
				foreach fnm $hst(ins_infiles) {
					lappend createins_cmd $fnm
				}
			}
			if [info exists hst(ins_params)] { 
				foreach hparam $hst(ins_params) {
					lappend createins_cmd $hparam
				}
			}
			lappend memory(current) "$createins_cmd"
			set ins_create_concluded 1
		} elseif {[info exists inside_ins_create]} {
			lappend memory(current) "$saved_cmd"
		}
	} elseif {[info exists from_instr]} {
		lappend memory(current) "$hst(doins_cmd)"
	} else {
		if {[IsStandaloneProgWithNonCDPFormat [file tail [lindex $saved_cmd 0]]]} {
			set saved_cmd [CreateDummyStandaloneCmd 0]
		}
		lappend memory(current) "$saved_cmd"
	}
	if {[info exists ins_create_concluded] && !$ins_create_concluded} {
		if {[info exists inside_ins_create]} {
			lappend memory(current) "$saved_cmd"
		}
	} else {
		if {[string match [lindex [lindex $memory(current) end] 0] "SLOOM:"]} {
			lappend memory(current) "$saved_cmd"
		} else {
			lappend memory(current) "$hst(outlist)"
		}
	}
	if {[info exists ins_create_concluded] && !$ins_create_concluded} {
		if [info exists inside_ins_create] {
			incr memory(cnt)
		}
	} else {
		incr memory(cnt)
	}
	if {$memory(cnt) >= $evv(MAX_HISTORY_SIZE)} {
		UpdateLog
	}
	set hst(active) 0
}

#------ Does hst command start with a ins-name ??

proc IsIns {str} {
	global ins
	set str [string tolower [file tail $str]]
	if [info exists ins(names)] {
		foreach m $ins(names) {
			if [string match $str [string tolower $m]] {
				return 1
			}
		}
	}
	return 0
}

#------ Transfer clicked-on name to display-box

proc GetLogName {w e} {
	global hst
	set indx [$w curselection]
	if {[string length $indx] <= 0} {
		Inf "No item selected"
	} else {
		set hst(index) $indx
		set hst(list) $w
		set hst(chosenname) [$w get $indx]
		ForceVal $e $hst(chosenname)
	}
}

#################################
# RECALLING HISTORY INFORMATION	#
#################################

#------ Allow use of bakdup-to-file Current History, or hst in a pre-existing Log file

proc DisplayHistory {activated} {
	global hl history_listing pr_history hst memory abs_linecnt sl_real action_src logsrch evv readonlyfg readonlybg wl
	global panprocess real_chlist chlist thumbnailed set_thumbnailed ww

	if {!$sl_real} {
		Inf "The Soundloom Keeps A Record Of All Your Actions:\nThese 'Logs' Can Be Recalled During This Session Or In A Later Session.\n\nIndividual Logs, Logs Prior To A Given Date Etc. Etc. Can Be Deleted."
		return
	}
	if {[info exists panprocess]} {
		return
	}
	if {[info exists real_chlist]} {
		Inf "ABANDONING MONO-THUMBNAIL PROCESSING"
		set chlist $real_chlist
		unset real_chlist
		catch {unset thumbnailed}
		catch {unset set_thumbnailed}
		$ww.1.a.mez.bkgd config -state normal
	}

	if {![RememberCurrentLog]} {			;#	Remember current state of file-logged hst, for restoration if ness
		return
	}
	set hst(step) 0
	set hst(active) 0					;#	Initialise the hst(active) flag
	set hst(ins) 0					;#	Initialise the hst(ins) flag
	set hst(is_current) 1				;#	Initially we're pointing at current hst
	set hst(baktrak) 0					;#	Initialise the baktrak blok-cnt
	set hst(blokno) "End"
	set hst(name) $hst(todaysname)	;#	Initially set the current-log-we're-dealing-with to todays log

	set abs_linecnt $hst(cnt)
	incr abs_linecnt $hst(cnt)			;#	Total number of lines stored in current file

	set f .history_listing
	eval {toplevel $f} -borderwidth $evv(SBDR)
	wm protocol $f WM_DELETE_WINDOW "set pr_history 0"
	wm title $f "RECALL"

	button $f.qu -text "Close" 	 	 -command "set pr_history 0" -highlightbackground [option get . background {}]
	button $f.he -text "Help" -command "HistoryHelp"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	label $f.sr -text "Search this log for" 
	entry $f.ee -textvariable action_src -width 20
	button $f.do -text "Do Search" -command SearchActionDisplay -highlightbackground [option get . background {}]
	button $f.rf -text "Ref Vals" -command "RefSee 4"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	button $f.rr -text "Get Remembered Log" -command "LogRecall" -width 18 -highlightbackground [option get . background {}]
	button $f.rx -text "Search All Logs" -command {SearchLogs "" 1} -width 18 -highlightbackground [option get . background {}]
	frame $f.line0 -width 1 -bg [option get . foreground {}] -height 2

	grid $f.he   -row 0 -column 0 -sticky  w -padx 6
	grid $f.sr   -row 0 -column 1 -sticky  w
	grid $f.ee   -row 0 -column 2 -sticky  w
	grid $f.do   -row 0 -column 4 -sticky  w
	grid $f.rf   -row 0 -column 5 -sticky  w
	grid $f.rr   -row 0 -column 6 -columnspan 3 -sticky  w
	grid $f.rx   -row 0 -column 9 -columnspan 3 -sticky  w
	grid $f.qu   -row 0 -column 14 -sticky e -padx 6
	grid $f.line0 -row 1 -column 0 -columnspan 15 -sticky ew -pady 2

	label $f.lir -text "Which Log?"
	frame $f.line -width 1  -bg [option get . foreground {}] -height 2
	label $f.lhr -text "Where in Log?"
	frame $f.line2 -width 1 -bg [option get . foreground {}] -height 2
	grid $f.lir   -row 2 -column 0  -columnspan 3 -sticky ew
	grid $f.line  -row 2 -column 3  -rowspan 3 -sticky ns -padx 4
	grid $f.lhr   -row 2 -column 4  -columnspan 9 -sticky ew
	grid $f.line2 -row 2 -column 13 -rowspan 3 -sticky ns -padx 4

	frame $f.line3 -width 2 -bg [option get . foreground {}] -height 1
	grid $f.line3 -row 3 -column 0 -columnspan 15 -sticky ew -pady 2

	menubutton $f.gl -text "Get Log" -menu $f.gl.sub1 -width 15 -relief raised -width 9
	set gl1 [menu $f.gl.sub1 -tearoff 0]
	$gl1 add command -label "CHOOSE A LOG" -command "ChooseLog $f 0" -foreground black
	$gl1 add separator
	$gl1 add command -label "NEXT LOG" -command "GetNextLog $f 0" -foreground black
	$gl1 add command -label "PREVIOUS LOG" -command "GetNextLog $f 1" -foreground black
	$gl1 add separator
	$gl1 add command -label "LOGS FOUND IN LAST SEARCH" -command "ChooseLog $f 1" -foreground black
	entry  $f.ln   -textvariable hst(chosenname) -width 17 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	button $f.rt   -text "Restore Current Log" -command "RestoreTodaysLog $f" -highlightbackground [option get . background {}]

	entry  $f.step -textvariable hst(step) -width 3 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	button $f.ll   -text "Later Block"    -command "incr hst(step)" -highlightbackground [option get . background {}]
	button $f.ea   -text "Earlier Block"  -command "incr hst(step) -1" -highlightbackground [option get . background {}]
	button $f.goto -text "Move by Blocks" -command "ShowNewHistoryBlok $f" -highlightbackground [option get . background {}]
	button $f.pad1 -text "" -width 4 -command {} -state disabled -borderwidth 0 -highlightbackground [option get . background {}]
	button $f.stt  -text "Start"  -command "GetHistoryStart $f" -highlightbackground [option get . background {}]
	button $f.end  -text "End" 	 -command "GetHistoryEnd $f" -highlightbackground [option get . background {}]
	label $f.bklno -text "Block No."
	entry $f.bklne -textvariable hst(blokno) -width 3 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg

	if {$activated} {
		button $f.rc -text "Recall Action" 	 -command "set pr_history 1" -bg $evv(EMPH) -bd 2 -highlightbackground [option get . background {}]
	} else {
		button $f.rc -text "" -command {} -bg [option get . background {}] -bd 0 -highlightbackground [option get . background {}]
	}

	grid $f.gl 	 -row 4 -column 0  -sticky ew -padx 1
	grid $f.ln 	 -row 4 -column 1  -sticky ew -padx 1
	grid $f.rt 	 -row 4 -column 2  -sticky ew -padx 1

	grid $f.ll 	 -row 4 -column 4  -sticky ew -padx 1
	grid $f.ea 	 -row 4 -column 5  -sticky ew -padx 1
	grid $f.step -row 4 -column 6  -sticky ew -padx 1
	grid $f.goto -row 4 -column 7  -sticky ew -padx 1
	grid $f.pad1 -row 4 -column 8  -sticky ew
	grid $f.stt  -row 4 -column 9  -sticky ew -padx 1
	grid $f.end  -row 4 -column 10  -sticky ew -padx 1
	grid $f.bklno -row 4 -column 11  -sticky ew -padx 1
	grid $f.bklne -row 4 -column 12  -sticky ew -padx 1

	grid $f.rc 	 -row 4 -column 14 -sticky ew -padx 1

	bind .history_listing <Delete> {set action_src ""}

	ForceVal $f.step $hst(step)
	ForceVal $f.bklne $hst(blokno)
	set hst(chosenname) $hst(todaysname)
	ForceVal $f.ln $hst(chosenname)
	set hl [Scrolled_Listbox $f.hl -height $evv(HISTORY_BLOK) -selectmode single]
	grid $f.hl -row 5 -column 0 -columnspan 15 -sticky news
	if {![DisplayImmediateHistoryInListbox]} {			 ;#	Display the current active (mainly unbakdup) hst
		ErrShow "Invalid hst found in current log."
		destroy $f					
		return
	}
	set zomb [$wl curselection]
	if {([llength $zomb] == 1) && ($zomb != -1)} {
		set action_src [file tail [$wl get $zomb]]
	}
	$hl yview moveto 1.0
	wm resizable $f 1 1
	set pr_history 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 $f
#	if {[info exists logsrch] && ([string length $logsrch] > 0)} {
#		set action_src [file rootname $logsrch]
#	}
	My_Grab 0 $f pr_history
	while {!$finished} {								 ;#	Wait for RECALL or QUIT
		tkwait variable pr_history					
		if {$pr_history} {							 ;#	If RECALL
			set hi [$hl curselection]				 	 ;#	Find which item on hst list is selected
			if {[string length $hi] <= 0} {		
				Inf "No item selected for recall."	 ;#	If none, stay in dialog
				continue
			}
			incr hi $hi									;# (2 stored lines per displayed hst-item)
			set hst(this) "[lindex $memory(current) $hi]"	 ;#	Activate the hst
			set check [lindex $hst(this) 0]
			set str $evv(CDPROGRAM_DIR)
			append str "*"
			if {[string match "SLOOM:" $check]} {
				Inf "This is a Workspace or Textfile action\n\n            or a Graphic Edit\n\n      which cannot be recalled."
				set hst(active) 0
				set hst(ins) 0
				continue
			}
			if {![string match $str $check] && ![IsIns $check]} {
				Inf "Instrument no longer exists."
				set hst(active) 0
				set hst(ins) 0
				break
			}
			incr hi
			set hst(outfiles) "[lindex $memory(current) $hi]"
			set hst(active) 1						 ;#	Flag that hst is active.
			SetupHistoryInfiles							 ;# Reconfigure workspace to reflect infiles to historic event
			if {$hst(active)} {						 ;#	If infiles were accepted we exit
				set finished 1							 ;# and leave dialog
			}
		} else {
			set hst(active) 0						 ;#	Flag that hst is NOT active.
			set hst(ins) 0
			set finished 1								 ;#	QUIT (leave dialog)
		}
	}
	RestoreCurrentLog $f		;#	Restore current state of todays hst.

	My_Release_to_Dialog $f		;#	Return to workspace dialog,
	destroy $f					;#	destroying hst display.

	if {$hst(active)} {
		GotoGetAProcess	   			;#	Go to run program or ins directly, 
									;#	but fall thro to process-menus page, if hst aborts
	}
	set hst(active)  0		;#	On return, turn off the actvhistory flags!
	set hst(ins) 0
}

#------ Restore current state of (internal) hst, at end of hst query

proc RestoreCurrentLog {f} {
	global hst evv

	set hst(cnt) $hst(saved_cnt)
	set hst(maxbaktrak) $hst(saved_maxbaktrak)
	set hst(baktrak) 0
	set hst(blokno) "End"
	ForceVal $f.bklne $hst(blokno)
	set fullname [file join $evv(LOGDIR) $hst(todaysname)]
	if [file exists $fullname] {
		catch {close $hst(fileId)}
		if [catch {open $fullname a} hst(fileId)] {
			ErrShow "Cannot reopen current log file to continue recording session."
		}
	}
	set hst(name) $hst(todaysname)	
	RetrieveCurrentHistory
	set hst(is_todays_latest) 1
}

#------ Retrieve the current active hst (mainly not bakd up to file)

proc RetrieveCurrentHistory {} {
	global memory

	catch {unset memory(current)}
	if [info exists memory(saved)] {
		foreach line $memory(saved) {
			lappend memory(current) "$line"
		}
	}
}

#------ Remember current state of (internal) hst, for restoration at end of hst query

proc RememberCurrentLog {} {
	global hst evv

	set hst(saved_cnt) $hst(cnt)
	set hst(saved_maxbaktrak) $hst(maxbaktrak)
	set fullname [file join $evv(LOGDIR) $hst(todaysname)]
	if [file exists $fullname] {
		catch {close $hst(fileId)}
		if [catch {open $fullname r} hst(fileId)] {
			ErrShow "Cannot reopen current log file to read a hst of your work."
			return 0
		}
	} else {
		return 0
	}
	SaveCurrentHistory
	return 1
}

#------ Save the current (mostly non-bakdup to file) hst

proc SaveCurrentHistory {} {
	global memory
	catch {unset memory(saved)}
	if [info exists memory(current)] {
		foreach line $memory(current) {
			lappend memory(saved) "$line"
		}
	}
}

#------ Display the current (not yet backed-up to file) hst in the hst list box

proc DisplayImmediateHistoryInListbox {} {
	global hst hl memory evv

	if {!$hst(is_todays_latest)} {	;#	If necessary, retrieve the very latest active hst
		catch {unset memory(current)}
		if [info exists memory(saved)] { 
			foreach line $memory(saved) {
				lappend memory(current) "$line"
			}
		}
		set hst(is_todays_latest) 1
	}
	set lineno 0
	$hl delete 0 end							;#	Empty the existing display
	set display_cnt 0 
	while {$display_cnt < $memory(cnt)} {		;#	Display the lines
		set hst(to_display)  "[lindex $memory(current) $lineno]"
		incr lineno
		if {[string match [lindex $memory(current) 0] "SLOOM:"]} {
			set hst(outfiles_to_display) ""
		} else {
			set hst(outfiles_to_display) "[lindex $memory(current) $lineno]"
		}
		incr lineno
		DisplayHistoryLine
		incr display_cnt
	}
	return 1
}

#------ Construct a single-line-display of hst data, for user, from 2 lines of hst data

proc DisplayHistoryLine {} {
	global hl evv hst

	set prog_outline [GetProglineDisplay $hst(to_display)]
	if {[string match [lindex $prog_outline 0] "SLOOM:"]} {
		$hl insert end $prog_outline
		return
	}
	if {[llength $hst(outfiles_to_display)] > $evv(MAX_HDISPLAY_OUTFILES)} {
		set j $evv(MAX_HDISPLAY_OUTFILES)
		incr j -1
		set outline [lrange $hst(outfiles_to_display) 0 $j]
		set outline [concat $outline "ETC"]
	} else {
		set outline $hst(outfiles_to_display)
	}
	set outline [concat $prog_outline " -->>OUTPUTS: " $outline]
	$hl insert end $outline
	return
}

#------ Go to start of current hst and display it.

proc GetHistoryStart {f} {
	global hst abs_linecnt
	seek $hst(fileId) 0 start
	set abs_linecnt 0
	set hst(baktrak) $hst(maxbaktrak)
	set hst(blokno) 0
	ForceVal $f.bklne $hst(blokno)
	RetrieveAndDisplayHistoryBlok $f
}

#------ Go to end of current hst and display it.

proc GetHistoryEnd {f} {
	global hst abs_linecnt evv
	if {$hst(is_current)} {
		if {$hst(baktrak) == 0} {
			return
		}
		set hst(baktrak) 0
		set hst(blokno) "End"
		ForceVal $f.bklne $hst(blokno)
		if {![DisplayImmediateHistoryInListbox]} {
			ErrShow "Invalid hst found in current log."
			return
		}
		seek $hst(fileId) 0 end	  			;#	Locate linepointer at end of existing file
		set abs_linecnt $hst(cnt)	
		incr abs_linecnt $hst(cnt)
	} else {
		if {$hst(baktrak) == 1} {
			return
		}
		set hst(step) $hst(baktrak)		;#	distance from where we are to end
		incr hst(step) -1 		 			;#	Don't need to step over the last blok (we'll read it)
		incr hst(step) -1					;#	Don't need to step over current blok (at end of it)
		if {$hst(step)} {
			set i 0
			set skiplines 0
			while {$i < $hst(step)} {		;#	Calculate how many lines to skip before read
				incr skiplines $evv(HISTORY_LINESTORE)
				incr i
			}
			if {![SkipLines $skiplines]} {		;#	Skip those lines
				set hst(step) 0
				return
			}
		}
		set hst(baktrak) 1
		set hst(blokno) "End"
		ForceVal $f.bklne $hst(blokno)
		RetrieveAndDisplayHistoryBlok $f
	}
}

#------ Display a previous set of hst lines

proc RetrieveAndDisplayHistoryBlok {f} {
	global hst hl memory abs_linecnt evv

	set hst(step) 0
	ForceVal $f.step $hst(step)
	set lines_to_read $evv(HISTORY_LINESTORE) 				;#	Default
	switch -- $hst(baktrak) { 
		0 {
			if {$hst(is_current)} {						;#	Current hst, at its most recent
				if {![DisplayImmediateHistoryInListbox]} {	;#	Display the immediate (mainly unbackedup) hst
					ErrShow "Invalid hst found in current log."
					return
				}
			} else {
				Inf "Reached end of recorded log."
			}
			return
		}
		1 {	 												
			if {![string match $hst(name) $hst(todaysname)]} {
				if {$hst(end_blok) != 0} {				;#	If non-current hst, at its end block
					set lines_to_read $hst(end_blok)	;#	Deal with possible short block at end of log
				}
			}
		}
	}
	set linecnt 0
 	$hl delete 0 end										;#	Clear existing display
	
	catch {unset memory(current)}
	while {$linecnt < $lines_to_read} {						;#	Fill display and rewrite hst
		if {[gets $hst(fileId) hst(to_display)] < 0} {
			ErrShow "Miscalculation in count of lines in log file. Try Again."
			return
		}
		lappend memory(current) "$hst(to_display)"
		incr linecnt
		if {[gets $hst(fileId) hst(outfiles_to_display)] < 0} {
			ErrShow "Miscalculation in count of lines in log file. Try Again."
			return
		}
		lappend memory(current) "$hst(outfiles_to_display)"
		incr linecnt
	 	DisplayHistoryLine
		incr abs_linecnt 2
	}
	set hst(is_todays_latest) 0					;#	Remember this is not todays latest active hst
	return 1
}

#------ Skip over a number of lines in file.

proc SkipLines {lines_to_skip} {
	global hst abs_linecnt
	if {$lines_to_skip < 0} {
		ErrShow "Miscalculation in count of lines to skip in log file. Can't proceed."
		return 0
	}
	set linecnt 0
	while {$linecnt < $lines_to_skip} { 					;#	Skip unwanted lines
		if {[gets $hst(fileId) line] < 0} {
			ErrShow "Miscalculation in count of lines in log file. Can't proceed."
			return 0
		}
		incr linecnt
		incr abs_linecnt
	}
	return 1
}

#------ Search for a new blok in a log file, and display it

proc ShowNewHistoryBlok {f} {
	global hst abs_linecnt evv

	if {[string length $hst(step)] <= 0} {
		return
	} elseif {$hst(step) == 0} {								;#	No movement specified: return
		return
	} elseif {$hst(step) > 0} {						   			;#	If moving to later in hst

																	;#	If at baktrak 0 in current hst 
																	;#	or at baktrak 1 in non-current hst
		if {($hst(is_current) && ($hst(baktrak) == 0))
		||  (!$hst(is_current) && ($hst(baktrak) == 1))} {	
			Inf "At end of recorded log."						;#	we're already at end of displayable hst
			set hst(step) 0
			ForceVal $f.step $hst(step)
			return
		} else {													;#	Otherwise.....
			set possible_step $hst(baktrak)						;#	we can't advance more steps than value of baktrak
			if {!$hst(is_current)} {							;#	and non-current histories end at baktrak 1
				incr possible_step -1								;#	so we can advance 1 less block in those cases...
			}
			if {$hst(step) > $possible_step} {					;#	Truncate the forward-step if ness (safety)
				set hst(step) $possible_step
			}
			incr hst(baktrak) [expr -($hst(step))]			;#	Change the baktrak place to its new val after move

			if {($hst(is_current) && ($hst(baktrak) == 0))
			||  (!$hst(is_current) && ($hst(baktrak) == 1))} {	
				set hst(blokno) "End"
			} else {
				set hst(blokno) [expr $hst(maxbaktrak) - $hst(baktrak)]
			}
			ForceVal $f.bklne $hst(blokno)

			incr hst(step) -1									;#	We're at end of current blok, so discount that,
			if {$hst(step) > 0} {								;#	but step over any others
				set i 0
				set skiplines 0
				while {$i < $hst(step)} {						;#	Calculate how many lines to skip before read
					incr skiplines $evv(HISTORY_LINESTORE)
					incr i
				}
				if {![SkipLines $skiplines]} {				;#	Skip those lines
					set hst(step) 0
					ForceVal $f.step $hst(step)
					return
				}
			}
		}
	} else {										   		;#	If moving earlier in hst
		if {$hst(baktrak) == $hst(maxbaktrak)} {
			Inf "No earlier data in this log."
			set hst(step) 0
			ForceVal $f.step $hst(step)
			return
		}
		if [catch {seek $hst(fileId) 0 start} a] {		 ;#	Go to start of file (reference point for reading lines)
			ErrShow "Cannot rewind the log file"
			return
		}															
		set history_bakstep [expr -$hst(step)]			 ;#	Note no. of steps backwards
		set orig_baktrak $hst(baktrak)					 ;#	Save orig baktrak position
		incr hst(baktrak) $history_bakstep				 ;#	Calculate new baktrak value
		if {$hst(baktrak) > $hst(maxbaktrak)} {
			set hst(baktrak) $hst(maxbaktrak)		 ;#	Stop us falling off start of file
		}
		set hst(blokno) [expr $hst(maxbaktrak) - $hst(baktrak)]
		ForceVal $f.bklne $hst(blokno)	 ;#	Note which blok we're now in

		if {$hst(baktrak) == $hst(maxbaktrak)} {	 ;#	If at start of file
			set abs_linecnt 0								 ;#	Set block position to start of file
			RetrieveAndDisplayHistoryBlok $f				 ;#	Read first blok
			return
		}
		set baklines 0										 ;#	Initialise count of lines to move backwards
		set i 0											
															 ;#	If at end of current log, No blok to step back over
		if {!($hst(is_current) && $orig_baktrak == 0)} { ;#	(we're displaying memory not yet recorded to file) 
			incr history_bakstep							 ;#	Otherwise we have to step back over the current blok
		}
															 ;#	It at end of ancient log
		if {!($hst(is_current)) && ($orig_baktrak == 1) && ($hst(end_blok) != 0)} {
			incr baklines $hst(end_blok)				 ;#	Deal with any non-standard endblok-length
			incr i
		}

		while {$i < $history_bakstep} {						 ;#	Count standard blocks
			incr baklines $evv(HISTORY_LINESTORE)		
			incr i
		}
															 ;#	Calculate number of lines to skip from file_start
		set lines_to_skip [expr int($abs_linecnt - $baklines)]
		set abs_linecnt 0									 ;#	Set block position to start of file
		if {![SkipLines $lines_to_skip]} {
			set hst(step) 0								 ;#	Skip lines
			ForceVal $f.step $hst(step)
			return
		}
	}
	RetrieveAndDisplayHistoryBlok $f						 ;#	rewrite hst and display it
}

#------ Restore the log we are using in today's session

proc RestoreTodaysLog {f} {
	global hst
	set hst(chosenname) $hst(todaysname)
	ForceVal $f.ln $hst(chosenname)
	GetNewLog $f
}

#------ Restore the log we are using in today's session

proc GetNextLog {f previous} {
	global hst evv
	if {![info exists hst(chosenname)] ||[string match $hst(chosenname) $hst(todaysname)]} {
		if {$previous} {
			set getfinal 1
		} else {
			Inf "There Are No Logs More Recent Than This."
			return
		}
	}
	Block "Retrieving Log"
	set j 0
	foreach fnam [lsort -dictionary [glob [file join $evv(LOGDIR) "*"]]] {
		set fnam [file tail $fnam]
		if {![string match $fnam $evv(LOGSCNT_FILE)$evv(CDP_EXT)] \
		&&	![string match $fnam $evv(LOGCOUNT_FILE)$evv(CDP_EXT)] \
		&&	![string match $fnam $hst(todaysname)] } {
			lappend log_listing $fnam
			incr j
		}
	}
	if {![info exists log_listing]} {
		UnBlock
		Inf "No Logs Found."
		return
	}
	set log_listing [SortLogList $log_listing]

	if {[info exists getfinal]} {
		set hst(chosenname) [lindex $log_listing end] 
		ForceVal $f.ln $hst(chosenname)
		GetNewLog $f
		UnBlock
		return
	}
	set i [lsearch -exact $log_listing $hst(chosenname)]
	if {$i < 0} {
		Inf "Can't Find Current Log Amongst Logs!!"
		UnBlock
		return
	}
	if {$previous} {
		incr i -1
		if {$i < 0} { 
			Inf "There Are No Logs Before '$hst(chosenname)'"
			UnBlock
			return
		} else {
			set hst(chosenname) [lindex $log_listing $i]
		}
	} else {
		incr i 
		if {$i >= $j} {
			set hst(chosenname) $hst(todaysname)
		} else {
			set hst(chosenname) [lindex $log_listing $i]
		}
	}
	ForceVal $f.ln $hst(chosenname)
	GetNewLog $f
	UnBlock
}

#------ Select new logfile from display

proc ChooseLog {f from_search} {
	global loglist pr_chooselog hst foundlogs evv

	if {$from_search && ![info exists foundlogs]} { 
		Inf "No logs recovered from search"
		return
	}
	Block "Retrieving Logs"
	set g .log_list
	if [Dlg_Create $g "Previous Session Logs" "set pr_chooselog 0" -borderwidth $evv(BBDR)] {
		button $g.quit -text "Close" -command "set pr_chooselog 0" -highlightbackground [option get . background {}]
		message $g.msg -text "Please choose a log" -aspect 1000 -justify center
		set loglist [Scrolled_Listbox $g.ll -width 20 -height 20 -selectmode single]
		pack $g.quit $g.msg $g.ll -side top -fill x
		bind $loglist <ButtonRelease-1> "GetLogName %W $f.ln ; set pr_chooselog 1"
		bind $g <Escape> {set pr_chooselog 0}
	}
	wm resizable $g 1 1
	$loglist delete 0 end
	if {$from_search} {
		set	log_listing $foundlogs
	} else {
		foreach fnam [lsort -dictionary [glob [file join $evv(LOGDIR) "*"]]] {
			set fnam [file tail $fnam]
			if {![string match $fnam $evv(LOGSCNT_FILE)$evv(CDP_EXT)] \
			&&	![string match $fnam $evv(LOGCOUNT_FILE)$evv(CDP_EXT)] \
			&&	![string match $fnam $hst(todaysname)] } {
				lappend log_listing $fnam
			}
		}
	}
	if {[info exists log_listing]} {
		set log_listing [SortLogList $log_listing]
		foreach fnam $log_listing {
			$loglist insert end $fnam
		}
	}
	UnBlock
	$loglist yview moveto 1
	set hst(chosenname) ""
	ForceVal $f.ln $hst(chosenname)
	set pr_chooselog 0
	raise $g
	My_Grab 0 $g pr_chooselog $g.ll
	tkwait variable pr_chooselog
	if {$pr_chooselog} {
		GetNewLog $f
	}
	My_Release_to_Dialog $g
	Dlg_Dismiss $g
}

#------ Get a new logfile

proc GetNewLog {f} {
	global pr_history hst abs_linecnt wstk evv
	if {[string length [string trim $hst(chosenname)]] <= 0} {
		return
	}
													;#	If user asks for currently displayed log
	if [string match $hst(name) $hst(chosenname)] {	;#	go to most ancient display of current log
		set hst(baktrak) $hst(maxbaktrak)
		set hst(blokno) 0
		ForceVal $f.bklne $hst(blokno)
		seek $hst(fileId) 0 start
		set abs_linecnt 0
		RetrieveAndDisplayHistoryBlok $f
		return
	}								   						;#	OTHERWISE

	if [file exists [file join $evv(LOGDIR) $hst(name)]] {
		catch {close $hst(fileId)}						;#	Close the current logfile
	}														;#	and open the new one
	set hst(name) $hst(chosenname)
	set zoobidoo [file join $evv(LOGDIR) $hst(name)]
	if [catch {open $zoobidoo r} hst(fileId)] {
		ErrShow "Cannot open log file $hst(name)"
		set pr_history 0
		return
	}
	if [string match $hst(name) $hst(todaysname)] {		;#	If the new log is today's log 
		set hst(is_current) 1							;#	Mark it as such
		set hst(end_blok) 0								;#	Current log always has whole no of bloks in it
		set hst(cnt) $hst(saved_cnt)				;#	Restore hst(cnt) directly
	} else {
		if [catch {open [file join $evv(LOGDIR) $evv(LOGCOUNT_FILE)$evv(CDP_EXT)] r} logcntId] {
			Inf "Cannot open log count file."
			close $hst(fileId)
			set pr_history 0							;#	Otherwise, restore hst(cnt) from file
			return
		}
		set found 0
		while {[gets $logcntId line] >= 0} {
			if [string match $hst(name) [lindex $line 0]] {
				set hst(cnt) [lindex $line 1]
				set found 1
				break
			}
		}
		if {!$found} {
			ErrShow "Cannot find count for log $hst(name) in log-count file. PROBABLY EMPTY."
			close $hst(fileId)
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
				-message "Do you wish to delete this log file ?"]
			if {$choice == "yes"} {								;#	If different either
				if [catch {file delete $zoobidoo} zif] {
					Inf "Cannot delete the log file"
				} else {
				 	catch {$hst(list) delete $hst(index)}
				}
			}
			close $logcntId
			set pr_history 0
			return
		} else {	
			set hst(is_current) 0
			set hst(end_blok) [expr round($hst(cnt) % $evv(HISTORY_BLOK))]
		}
		close $logcntId
	}													   	
	set hst(maxbaktrak) [expr int($hst(cnt) / $evv(HISTORY_BLOK))]

	if {$hst(end_blok) > 0} {
		incr hst(maxbaktrak)						;#	Find baktrak size of logfile
	}														
	incr hst(end_blok) $hst(end_blok)			;#	Convert hst-size of odd last blok, to line-size

	set hst(step) 0
	ForceVal $f.step $hst(step)

	if {$hst(is_current)} {
		set hst(baktrak) 0							;#	Go to end of current file
		seek $hst(fileId) 0 end						;#	(Unstored data will be displayed)
		set abs_linecnt $hst(cnt)
		incr abs_linecnt $hst(cnt)
	} else {
		set hst(baktrak) 1							;#	Go to end of stored data
		seek $hst(fileId) 0 start
		set h_step [expr $hst(maxbaktrak) - $hst(baktrak)]
		set j 0
		set lines_to_skip 0
		while {$j < $h_step} {
			incr lines_to_skip $evv(HISTORY_LINESTORE)
			incr j
		}
		if {![SkipLines $lines_to_skip]} {				;#	Skip lines
			set hst(blokno) "???"
			ForceVal $f.bklne $hst(blokno)
			return
		}
	}
	set hst(blokno) "End"
	ForceVal $f.bklne $hst(blokno)
	RetrieveAndDisplayHistoryBlok $f
}

#------ Help Info for History Recall

proc HistoryHelp {} {
	global hhlist pr_histhelp evv

	set f .log_help

	if [Dlg_Create $f "Keeping And Editing Logs" "set pr_histhelp 0" -borderwidth $evv(BBDR)] {
		button $f.ok -text "OK" -command "set pr_histhelp 0" -highlightbackground [option get . background {}]
		set hhlist [Scrolled_Listbox $f.ll -width 84 -height 23 -selectmode single]
		pack $f.ok $f.ll -side top
		set msg "                                                    SESSION LOGS"
		$hhlist insert end $msg
		set msg ""
		$hhlist insert end $msg
		set msg "Each action of your session is recorded in a dated log."
		$hhlist insert end $msg
		set msg "You can view the current log, and previous logs, on this page, block by block."
		$hhlist insert end $msg
		set msg "You can also rerun Actions, (Recall Act) if the files are still available."
		$hhlist insert end $msg
		set msg ""
		$hhlist insert end $msg
		set msg "You can convert the log data to a more easily readable form"
		$hhlist insert end $msg
		set msg "using the CDP utility 'histconv'."
		$hhlist insert end $msg
		set msg ""
		$hhlist insert end $msg
		set msg "You are advised NOT to edit the original data, or rename the log files, OUTSIDE the Sound Loom,"
		$hhlist insert end $msg
		set msg "as, if you alter the particular syntax, the Sound Loom's 'History' function will no longer"
		$hhlist insert end $msg
		set msg "recognise the Log file."
		$hhlist insert end $msg
		set msg ""
		$hhlist insert end $msg
		bind $f <Return> {set pr_histhelp 0}
		bind $f <Escape> {set pr_histhelp 0}
		bind $f <Key-space> {set pr_histhelp 0}
	}
	wm resizable $f 1 1
	raise $f
	set pr_histhelp 0
	My_Grab 0 $f pr_histhelp
	tkwait variable pr_histhelp
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#########################
# ACTIVATING A HISTORY	#
#########################

#------ Find and check the infiles specified in a History

proc SetupHistoryInfiles {} {
	global hst wl evv chlist ch pprg mmod ins wstk pa chcnt only_for_mix parse_the_max

	if [IsIns [lindex $hst(this) 0]] {
		set hst(ins) 1									 				;#	flags it's a ins-line
		set infilecnt [lindex $hst(this) $evv(HISTORY_INFILECNT)] 			;#	get infilecnt for ins
		set hst(location_in) $evv(HISTORY_INFILES)							;#	go to start of infiles list
	} else {
		set pprg [lindex $hst(this) $evv(CMD_PROCESSNO)]	;#	Get the process-idents from the active-hst
		set mmod [lindex $hst(this) $evv(CMD_MODENO)]
		set infilecnt [lindex $hst(this) $evv(CMD_INFILECNT)]	;#	get infilecnt for process
		if {$infilecnt > 0} {
			set hst(location_in) $evv(CMD_INFILES)				;#	go to start of infiles list
		} else {
			set hst(location_in) $evv(CMD_INFILECNT)
			incr hst(location_in)
		}
	}
	set i 0
	catch {unset chlist}
	set chcnt 0
	$ch delete 0 end
	set history_infile_cnt 0
	set hindx -1
	while {$i < $infilecnt} {
		set fnam [lindex $hst(this) $hst(location_in)]	;#	Get each hst-infile in turn
		if [file exists $fnam] {								;#	IF IT STILL EXISTS
			set hindx [LstIndx $fnam $wl]				;#	Find if it is on workspace
			if {$hindx < 0} {										;#	If not, load it onto workspace
				if {[FileToWkspace $fnam 0 0 0 1 0] <= 0} {		;#	(automatically parsing file,and saving props)
					lappend chlist $evv(DUMMY_DISPLAY)			;#	If load fails, mark a space on chlist
					incr chcnt
					incr i											;#	Note that file has been got to wkspace
					continue
				} elseif {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)}  {
					if {![info exists pa($fnam,$evv(MAXREP))] && $parse_the_max} {	;#	Otherwise it's already known
						GetMaxsampOnInput $fnam
					}
				}
				set hindx [$wl index end]			 				;#	Note its position on workspace
			}
																	;#	Check infile props against those known in hst
			if {($i == 0) && !$hst(ins) && ![IsSameFileAsInHistory $fnam]} {
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
					-message "WARNING: File $fnam is not same file as used originally. Proceed ?"]
				if {$choice != "yes"} {								;#	If different either
					RestoreOriginalChoiceList						;#	Abort the hst recall
					set hst(active) 0
					set hst(ins) 0
	 				return
				} elseif {!$hst(ins)} {						;#	OR substitute the props of new file in hst
					SubstituteNewPropsIntoHistory $fnam
				}
			}
			lappend chlist $fnam							;#	Append infile to chlist
			incr chcnt
			incr history_infile_cnt									;#	Increment count of files actually found
		} else {
			lappend chlist $evv(DUMMY_DISPLAY)
			incr chcnt
		}		 
		incr i														;#	Count the files listed in hst
		incr hst(location_in)									;#	Move along hst data
	}
	if {!$hst(ins)} {										;#	For process only (not Instruments)
		incr hst(location_in) 									;#	Jump over the outfilename
	}																;#	to leave hst(location_in) at start of params

																	;#	Count if any files are missing,
	set hst(incomplete) [expr int($infilecnt - $history_infile_cnt)]
	if {$hst(incomplete)} {						;#	If files are missing
		if [ContinueWithHistory] {					;# 	Consult user
			CompleteInfilesToHistory 				;#	try to replace these missing files, in the infiles list
		}
	}												;#	automatically modifies hindx if it it selects files
	
	if {$hst(incomplete)} {						;#	If files still missing from infiles list
		RestoreOriginalChoiceList					
		set hst(active) 0						;#	abort hst
		set hst(ins) 0
	} else {
		if {$hindx >= 0} {							;#	If any files were found
			$wl selection anchor $hindx				;#	mark-as-selected the last selected line (??? works ???) in wkspace
		}
		if [info exists chlist] {
			foreach fnam $chlist {	
				$ch insert end $fnam		 ;#	Display selectedfiles on 'chosen' list on wkspace
			}
			if {[ChlistDupls]} {
				set only_for_mix 1
			}
		}
	}
}

#------ Substitute props of NEw file 1 into hst.

proc SubstituteNewPropsIntoHistory {fnam} {
	global pa hst evv
	set propno 0									;#	so that prm ranges calculated correctly
	set i $evv(CMD_PROPS_OFFSET)
	while {$propno < $evv(CDP_PROPS_CNT)} {
		set $hst(this) [lreplace $hst(this) $i $i $pa($fnam,$propno)]
		incr propno
		incr i
	}
}

#------ Compare file props with props logged in hst.

proc IsSameFileAsInHistory {fnam} {
	global evv pa hst

	set i $evv(CMD_PROPS_OFFSET)							
	set propno 0
	while {$propno < $evv(CDP_PROPS_CNT)} {
		if {![string match $pa($fnam,$propno) [lindex $hst(this) $i]]} {
			return 0
		}
		incr propno
		incr i
	}
	return 1
}

#------ Inform the user there are insufficient files for the selected hst to work.

proc ContinueWithHistory {} {
	global hst wstk
	if {$hst(ins)} {
		set thisprocess "instrument"
	} else {
		set thisprocess "process"
	}
	set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
		-message "Not all files needed for this $thisprocess could be found: $hst(incomplete) more needed.\nContinue ?"]
	if {$choice == "yes"} {
		return 1
	}
	set hst(ins) 0
	return 0

}

#------ Remove any 'file-absent' markers from the list of selected files

proc RestoreOriginalChoiceList {} {
	global chlist ch chcnt
	catch {unset chlist}
	set chcnt 0
	foreach fnam [$ch get 0 end] {					;#	Restore original chlist
		lappend chlist $fnam
		incr chcnt
	}
}

#------ Complete the list of infiles to the hst, where this is incomplete

proc CompleteInfilesToHistory {} {
	global wl missing_list pr_missing missing_location hst chlist wstk chcnt evv

	if {$hst(ins)} {
		set item "Instrument"
	} else {
		set item "Process"
	}
	set titelitem [string toupper $item]

	set f .missing_list
	eval {toplevel $f} -borderwidth $evv(SBDR)
	wm protocol $f WM_DELETE_WINDOW "set pr_missing 0"
	wm title $f "Complete the list of files required for this $titelitem"

	set item [string toupper $item]
	button $f.help -text "Help" -command "HelpMissing $f"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	label  $f.hinf -text "" -width 60 
	button $f.quit -text "Close" -command "set pr_missing 0" -highlightbackground [option get . background {}]
	label  $f.wksp -text "Workspace Files"
	label  $f.sel  -text "Files For $item"
	set tochoos [Scrolled_Listbox $f.tochoos -width 36 -height 32 -selectmode single]
	set hchosen [Scrolled_Listbox $f.hchosen -width 36 -height 32 -selectmode single]

	grid $f.help   	-row 0 -column 0 -sticky w
	grid $f.hinf	-row 0 -column 1 -columnspan 6 -sticky ew
	grid $f.quit   	-row 0 -column 7 -sticky e
	grid $f.sel    	-row 1 -column 0 -columnspan 4 -sticky ew
	grid $f.hchosen -row 2 -column 0 -columnspan 4 -sticky news
	grid $f.wksp   	-row 1 -column 4 -columnspan 4 -sticky ew
	grid $f.tochoos	-row 2 -column 4 -columnspan 4 -sticky news
	foreach fnam [$wl get 0 end] {
		$tochoos insert end $fnam
	}
	if [info exists chlist] {
		foreach fnam $chlist {
			$hchosen insert end $fnam
		}
	}
	bind $hchosen <ButtonRelease-1> {GetLocation %W}
	bind $tochoos <ButtonRelease-1> "MoveFile %W $hchosen $item"
	wm resizable $f 1 1
	raise $f
	set missing_location -1
	set pr_missing 0
	My_Grab 0 $f pr_missing
	while {$hst(incomplete) > 0} {				;#	variable changes as files are replaced
		tkwait variable pr_missing 				;#	Await file replacement or quit
		if {$pr_missing == 0} {	   				;#	QUIT pressed, quits
			break		
		}
	} 
	if {$hst(incomplete) == 0} {				;#	If all missing files are replaced
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
			-message "List of files OK ?"]
		if {$choice == "yes"} {		
			catch {unset chlist}
			set chcnt 0
			foreach fnam [$hchosen get 0 end] {	;#	Copy files from the current listbox
				lappend chlist $fnam		;#	To the real chlist
				incr chcnt
			}										;#	(Copied to displayd 'chosen' list in calling function
		} else {
			set hst(incomplete) 1
		}
	}
	My_Release_to_Dialog $f
	destroy $f
}	

#------ Provide help for missing-file-subsitution page.

proc HelpMissing {f} {
	global evv
	$f.hinf config -text "Select location (----) from list 1 : Select appropriate file from list2" -bg $evv(EMPH)
	$f.help config -text "Quiet!" -command "UnHelpMissing $f"
}	

#------ Hide help on missing-file-subsitution page.

proc UnHelpMissing {f} {
	$f.hinf config -text "" -bg [option get . background {}]
	$f.help config -text "Help" -command "HelpMissing $f"
}	

#------ Get location in chosen-list of marker for missing file.

proc GetLocation {w} {
	global missing_location evv
	set missing_location [$w curselection]
	if {[string length $missing_location] > 0}  {
		set fnam [$w get $missing_location]
		if {![string match $fnam $evv(DUMMY_DISPLAY)]} {
			set missing_location -1
		}
	}
}	

#------ Move selected file to location selected in chosen-list.

proc MoveFile {w hchosen item} {
	global missing_location pr_missing hst wstk
	if {$missing_location < 0} {
		Inf "No available position in files for $item list has been marked."
		return
	} 
	set hindx [$w curselection]
	if {[string length $hindx] <= 0} {
		Inf "No file selected"
		return
	}
	set fnam [$w get $hindx]
	foreach existing_filename [$hchosen get 0 end] {
		if [string match $fnam $existing_filename] {
			Inf "File is already in list"
			return
		}
	}
	set choice [tk_messageBox -type yesno -message "Put file $fnam at selected location on list ?" \
	 	-icon question -parent [lindex $wstk end]]
	if {$choice == "yes"} {
		$hchosen delete $missing_location
		$hchosen insert $missing_location $fnam
		incr hst(incomplete) -1
		if {$missing_location == 0} {		;#	If 1st file replaced, put its props into hst!!
			if {!$hst(ins)} {
				SubstituteNewPropsIntoHistory $fnam
			}
		}
		set missing_location -1				;#	Force marking of new missing location
	}
	set pr_missing 1
}

#########################
# RUNNING A HISTORY		#
#########################

#------ Run hst (rather than consult process menu or ins-listing)

proc RunHistory {} {
	global hst ins pmask evv pprg mmod
	global selected_menu pprg
	set selected_menu [MenuForProcess $pprg]

	if {$hst(ins)} {

		set ins(run) 1
		RunIns			;#	Uses ins name in active-hst
	} else {
		set p_no [lindex $hst(this) $evv(CMD_PROCESSNO)]
		if {![string index $pmask $p_no]} {
			set hst(active) 0
			Inf "This previous process will not work with the input files given."
			return
		} elseif {![ProcessIsAvailable $p_no]} {
			Inf "This previous process is not on your system."
			return
		} else { 
			GotoProgram 	;#	Uses vals of $pprg $mmod set by hst
		}
	}
}

#------ Return menu which has process

proc MenuForProcess {pno} {
	global cdpmenu pprg evv
	set OK 0
	set thismenu 0
	while {$thismenu < $evv(MAXMENUNO)} {
		if [info exists cdpmenu($thismenu)] {
			foreach p_no [lrange $cdpmenu($thismenu) $evv(MENUPROGS_INDEX) end] {
				if {$p_no == $pno} {
					return $thismenu
				}
			}
		}
		incr thismenu
	}
}

#------ Setup the historical parameters in the parameter-dialog displays.

proc EstablishHistoricalParams {} {
 	global pmcnt hst prm patchparam parname dfault prmgrd gdg_typeflag evv

	set pcnt 0
	set gcnt 0

	foreach parameter [lrange $hst(this) $hst(location_in) end] {
		if {$pcnt >= $pmcnt} {
			Inf "WARNING: Too many parameters in recalled process."
			continue
		}

		set par_name [StripName $parname($gcnt)]
		set gtype $gdg_typeflag($gcnt)

		set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) $par_name $gtype $pcnt $gcnt]
		if [string match $evv(NUM_MARK)* $parameter] {
			set prm($pcnt) [string range $parameter 1 end]
		} else {
			set prm($pcnt) $parameter
		}
		if {[string length $prm($pcnt)] <= 0} {
			Inf "Invalid $par_name parameter: Defaulting to $dfault($pcnt)."
			set prm($pcnt) $dfault($pcnt)
		}
		incr pcnt
	}
	if {$pcnt != $pmcnt} {
		Inf "Too few parameters in recalled process: Defaulting later parameters."
	}
	set i 0

	while {$i <$pmcnt} {
		set patchparam($i) $prm($i)
		incr i
	}
	TestParamsWithReversion
}

#------ Displaying original renaming of outfiles, in historical process

proc OriginalHistoryOutfilesDisplay {} {
	global history_outdisplay pr_hod hst evv

	if {[llength $hst(outfiles)] <= 0} {
		return
	}
	set f .history_outdisplay
	eval {toplevel $f} -borderwidth $evv(BBDR)
	wm protocol $f WM_DELETE_WINDOW "set pr_hod 1"
	wm title $f "Original Outputfile Names"
	set ff [frame $f.ff -borderwidth $evv(BBDR)]
	pack $f.ff -side top -fill both
	button $ff.btn -text "OK" -command "set pr_hod 1" -highlightbackground [option get . background {}]
	set hod [Scrolled_Listbox $ff.hod -width 64 -height 12]
	pack $ff.btn $ff.hod -side top
	wm resizable $f 1 1
	bind $f <Return> {set pr_hod 1}
	bind $f <Escape> {set pr_hod 1}
	foreach outfline $hst(outfiles) {
		set here [string first "." $outfline]
		if {$here < 0} {
			$hod insert end $outfline
			continue
		}
		incr here -1
		set outline [string range $outfline 0 $here]
		set here [string first "->" $outfline]
		if {$here < 0} {
			$hod insert end $outfline
			continue
		}
		set there [string last "." $outfline]
		if {$there == $here} {
			$hod insert end $outfline
			continue
		}
		incr there -1
		set outline [append outline [string range $outfline $here $there]]
		$hod insert end $outline
	}
	set pr_hod 0
	raise $f
	My_Grab 0 $f pr_hod
	tkwait variable pr_hod
	My_Release_to_Dialog $f
	destroy $f
}

#------ Clear all existing logs except today's

proc ClearLogs {} {
	global hst wstk sl_real evv

	if {!$sl_real} {
		Inf "You Can Clear Out All The Records Of Previous Actions, If Starting A Completely New Project."
		return
	}

	set choice [tk_messageBox -type yesno -default yes \
		-message "Are You Sure You Want To DESTROY ALL Your Log Files???" \
		-icon question -parent [lindex $wstk end]]
	if {$choice == "no"} {
		return
	}
	if [info exists hst(todaysname)] {
		set check_todays 1
	} else {
		set check_todays 0
	}
	foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(LOGDIR) *]]] {
		set shortname [file tail $fnam]
		if {$check_todays && [string match $shortname $hst(todaysname)]} {
			continue
		} elseif [string match $shortname $evv(LOGCOUNT_FILE)$evv(CDP_EXT)] {
			if [catch {open $fnam w} lfId] {
				Inf "Cannot empty log count file '$evv(LOGCOUNT_FILE)$evv(CDP_EXT)'"
			} else {
				close $lfId
			}
		} elseif [string match $shortname $evv(LOGSCNT_FILE)$evv(CDP_EXT)] {	
			if [catch {open $fnam w} lfId] {
				Inf "Cannot empty open file '$evv(LOGSCNT_FILE)$evv(CDP_EXT)'"
				continue
			}
			puts $lfId $evv(LOGS_MAX)
			close $lfId
		} else {
			if {![catch {file stat $fnam filestatus} in]} {
				if {$filestatus(ino) >= 0} {
					catch {close $filestatus(ino)}
				}
			}
			if [catch {file delete $fnam} in] {
				Inf "Cannot delete log file '$shortname'"
			}
		}
	}
	set evv(LOGS_MAX) $evv(MIN_MAXLOGS)
}

#----- Remove logs for which no count exists (logs created during crashes)

proc ClearBadLogs {} {
	global hst sl_real in_tidyup evv

	if {!$sl_real && !$in_tidyup} {
		Inf "You Can Clear Out All Records Of Previous Actions Which Contain No Information"
		return
	}
	set zfile $evv(LOGSCNT_FILE)$evv(CDP_EXT)

	set cntfile $evv(LOGCOUNT_FILE)$evv(CDP_EXT)
	set z_cntfile [file join $evv(LOGDIR) $cntfile]
	if {![file exists $z_cntfile]} {
		return
	}
	if [catch {open $z_cntfile r} logcntId] {
		if {$sl_real} {
			Inf "Cannot open log count file."
		}
		return
	}
	while {[gets $logcntId line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set lname [lindex $line 0]
		if {[string length $lname] <= 0} {
			continue
		}
		lappend loglines $line
		lappend lognames $lname
	}
	close $logcntId

#IF NO FILES ARE LISTED IN LIST-OF-FILES-AND-FILECNTS, DELETE ALL EXISTING LOFGILES

	if {![info exists lognames]} {
		foreach fnamfull [glob -nocomplain [file join $evv(LOGDIR) *]] {
			set fnam [file tail $fnamfull]
			if {[string match $cntfile $fnam] || [string match $zfile $fnam] || ([info exists hst(todaysname)] && [string match $hst(todaysname) $fnam])} {
				continue
			}
			if {![catch {file stat $fnamfull filestatus} in]} {
				catch {close $filestatus(ino)}
			}
			if [catch {file delete $fnamfull} zik] {
				Inf "Cannot delete bad log '$fnam'"
			}
		}
		return
	}

#DELETE ANY LOGFILES NOT LISTED IN LIST-OF-FILES-AND-FILECNTS

	foreach fnamfull [glob -nocomplain [file join $evv(LOGDIR) *]] {
		set fnam [file tail $fnamfull]
		if {[string match $cntfile $fnam] || [string match $zfile $fnam]} {
			continue
		} elseif {[info exists hst(todaysname)] && [string match $hst(todaysname) $fnam]} {
		    lappend existing_files $fnam
			continue
		}
		lappend existing_files $fnam
		set OK 0
		foreach item $lognames {
			if [string match $fnam $item] {
				set OK 1
				break
			}
		}
		if {!$OK} {
			if {![catch {file stat $fnamfull filestatus} in]} {
				catch {close $filestatus(ino)}
			}
			if [catch {file delete $fnamfull} zik] {
				Inf "Cannot delete bad log '$fnam'"
			}
		}
	}

#DELETE ANY ITEM IN LIST-OF-FILES-AND-FILECNTS NOT CORRESPONDING TO AN EXISTING LOGFILE

	set origlen [llength $loglines]
	set newlen 0
	foreach line $loglines {
		set item [lindex $line 0]
		set OK 0
		foreach fnam $existing_files {
			if [string match $fnam $item] {
				set OK 1
				break
			}
		}
		if {!$OK} {
			set loglines [lreplace $loglines $newlen $newlen]
		} else {
			incr newlen
		}
	}
	if {$newlen != $origlen} {
		if [catch {open $evv(DFLT_TMPFNAME) w} fileId] {
			Inf "Cannot open temporary file while attempting to update log count file."
			return
		}
		foreach line $loglines {
			puts $fileId $line
		}
		close $fileId
		if [catch {file delete $z_cntfile}] {
			ErrShow "Cannot delete existing log-counting file $z_cntfile"
			return
		}
		if [catch {file rename $evv(DFLT_TMPFNAME) $z_cntfile}] {
			ErrShow "Failed to save new log-counting file: Serious problem\n\ndata exists as file $evv(DFLT_TMPFNAME)\n\nRename this file to $z_cntfile, outside the Sound Loom, before proceeding"
			return
		}
	}
}

#------ Destroy all existing log files on a particular day.

proc DestroyLogDay {ll b} {
	global hst wstk evv
	if {[string length $hst(chosenname)] <= 0} {
		Inf "No log name selected"
		return
	}
	set choice [tk_messageBox -type yesno -message "Are you sure you want To DESTROY ALL This Day's Logs: FOREVER !" \
				-icon question -parent [lindex $wstk end]]
	if {$choice == "no"} {
		return
	}
	set k [string first "." $hst(chosenname)]
	incr k
	set thisyear [string range $hst(chosenname) $k end]
	set k [string first "_" $hst(chosenname)]
	incr k -1
	set thisday [string range $hst(chosenname) 0 $k]

	set inname $hst(chosenname)
	foreach name [$ll get 0 end] {
		if [string match $name $hst(chosenname)] {
			continue
		}
		set k [string first "." $name]
		incr k
		set year [string range $name $k end]
		if [string match $year $thisyear] {
			set k [string first "_" $name]
			incr k -1
			set day [string range $name 0 $k]
			if [string match $day $thisday] {
				DoLogDeletion $name
				lappend delnames $name
			}
		}
	}
	DoLogDeletion $hst(chosenname) $ll $b
	if [info exists delnames] {
		set i 0
		foreach name [$ll get 0 end] {
			foreach deld $delnames {
				if [string match $name $deld] {
					lappend delindex $i
					break
				}
			}
			incr i
		}
		foreach i [lsort -integer -decreasing $delindex] {
			$ll delete $i
		}
	}
}

#------ Destroy all existing log files on a particular day.

proc DestroyLogBefore {ll b after} {
	global hst wstk evv

	set inname $hst(chosenname)

	if {[string length $hst(chosenname)] <= 0} {
		Inf "No log name selected"
		return
	}
	if {$after} {
		set msg "Are you sure you want to DESTROY This Log And All Later Logs: FOREVER !"
	} else {
		set msg "Are you sure you want to DESTROY All Logs Before This One: FOREVER !"
	}
	set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
	if {$choice == "no"} {
		return
	}
	set k [string first "." $hst(chosenname)]
	incr k
	set thisyear [string range $hst(chosenname) $k end]
	set k [string first "_" $hst(chosenname)]
	incr k -1
	set thisday [string range $hst(chosenname) 0 $k]
	set z [string length $thisday]
	set x 0
	while {$x < $z} {
		if [string match {[0-9]} [string index $thisday $x]] {
			break
		}
		incr x
	}
	set thisdate [string range $thisday $x end]
	incr x -1
	set thismonth [string range $thisday 0 $x]


	incr k 2
	set rest [string range $hst(chosenname) $k end]
	set k [string first "-" $rest]
	incr k -1
	set thishour [string range $rest 0 $k]
	incr k 2
	set rest [string range $rest $k end]
	set k [string first "." $rest]
	incr k -1
	set thismin [string range $rest 0 $k]

	foreach name [$ll get 0 end] {
		if {$after} {
			if {![IsEarlier $name $thisyear $thismonth $thisdate $thishour $thismin]} {
				DoLogDeletion $name
				lappend delnames $name
			}
		} elseif {[IsEarlier $name $thisyear $thismonth $thisdate $thishour $thismin]} {
			DoLogDeletion $name
			lappend delnames $name
		}
	}
	if [info exists delnames] {
		set i 0
		foreach name [$ll get 0 end] {
			foreach deld $delnames {
				if [string match $name $deld] {
					lappend delindex $i
					break
				}
			}
			incr i
		}
		foreach i [lsort -integer -decreasing $delindex] {
			$ll delete $i
		}
	}
}

proc MonthCompare {thismonth month} {

	set base [GetMonthNumber [string tolower $thismonth]]
	set now  [GetMonthNumber [string tolower $month]]
	return [expr $now - $base]
}

proc GetMonthNumber {month} {

	if [string match ja* $month] { 
		return 1
	} elseif [string match f* $month] { 
		return 2
	} elseif [string match mar* $month] { 
		return 3
	} elseif [string match ap* $month] { 
		return 4
	} elseif [string match may* $month] { 
		return 5
	} elseif [string match jun* $month] { 
		return 6
	} elseif [string match jul* $month] { 
		return 7
	} elseif [string match au* $month] { 
		return 8
	} elseif [string match s* $month] { 
		return 9
	} elseif [string match o* $month] { 
		return 10
	} elseif [string match n* $month] { 
		return 11
	}
	return 12
}

proc SortLogList {loglist} {

	foreach fnam $loglist {
		set k [string first "." $fnam]
		incr k
		set thisyear [string range $fnam $k end]
		set k [string first "_" $fnam]
		incr k -1
		set thisday [string range $fnam 0 $k]
		set z [string length $thisday]
		set x 0
		while {$x < $z} {
			if [string match {[0-9]} [string index $thisday $x]] {
				break
			}
			incr x
		}
		set thisdate [string range $thisday $x end]
		incr x -1
		set thismonth [GetMonthNumber [string tolower [string range $thisday 0 $x]]]

		incr k 2
		set rest [string range $fnam $k end]
		set k [string first "-" $rest]
		incr k -1
		set thishour [string range $rest 0 $k]
		incr k 2
		set rest [string range $rest $k end]
		set k [string first "." $rest]
		incr k -1
		set thismin [string range $rest 0 $k]
		catch {unset date_info}
		lappend date_info $thisyear $thismonth $thisdate $thishour $thismin $fnam
		lappend sortlist $date_info
	}
	set len2 [llength $sortlist]
	set len1 [expr $len2 - 1]
	set n 0
	while {$n < $len1} {
		set item1 [lindex $sortlist $n]
		set m [expr $n + 1]
		while {$m < $len2} {
			set item2 [lindex $sortlist $m]
			if {[lindex $item2 0] < [lindex $item1 0]} {
				set sortlist [lreplace $sortlist $n $n $item2]
				set sortlist [lreplace $sortlist $m $m $item1]
				set item1 $item2
			} elseif {[lindex $item2 0] == [lindex $item1 0]} {
				if {[lindex $item2 1] < [lindex $item1 1]} {
				    set sortlist [lreplace $sortlist $n $n $item2]
					set sortlist [lreplace $sortlist $m $m $item1]
					set item1 $item2
				} elseif {[lindex $item2 1] == [lindex $item1 1]} {
					if {[lindex $item2 2] < [lindex $item1 2]} {
						set sortlist [lreplace $sortlist $n $n $item2]
						set sortlist [lreplace $sortlist $m $m $item1]
						set item1 $item2
					} elseif {[lindex $item2 2] == [lindex $item1 2]} {
						if {[lindex $item2 3] < [lindex $item1 3]} {
							set sortlist [lreplace $sortlist $n $n $item2]
							set sortlist [lreplace $sortlist $m $m $item1]
							set item1 $item2
						} elseif {[lindex $item2 3] == [lindex $item1 3]} {
							if {[lindex $item2 4] < [lindex $item1 4]} {
								set sortlist [lreplace $sortlist $n $n $item2]
								set sortlist [lreplace $sortlist $m $m $item1]
								set item1 $item2
							}
						}
					}
				}
			}
			incr m
		}
		incr n
	}
	foreach item $sortlist {
		lappend newlist [lindex $item 5]
	}
	return $newlist
}	

#-------- Search logfiles for given text

proc SearchLogs {str getlog} {
	global pr_slog logsrch loglisting logviewing foundlogs action_src evv

	if {([string length $str] <= 0) && [info exists action_src] && ([string length $action_src] > 0)} {
			set logsrch $action_src
	} else {
		set logsrch $str
	}
	set f .slog

	if [Dlg_Create $f "FIND RELEVANT LOG" "set pr_slog 0" -borderwidth $evv(BBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		button $f1.quit -text "Close" -command "set pr_slog 0" -highlightbackground [option get . background {}]
		button $f1.search -text "Search" -command "set pr_slog 1" -highlightbackground [option get . background {}]
		message $f1.msg -text "Text to search for" -aspect 1000 -justify center
		menubutton $f1.get -text "Preselected Text"  -menu $f1.get.sub -relief raised -width 20
		set f1g [menu $f1.get.sub -tearoff 0]
		$f1g add command -label "WORKSPACE FILE" -command "SearchLogsGet wl" -foreground black
		$f1g add separator
		$f1g add command -label "CHOSEN LIST FILE" -command "SearchLogsGet ch" -foreground black
		$f1g add separator
		$f1g add command -label "DIRECTORY LIST FILE" -command "SearchLogsGet dl" -foreground black
		entry $f1.e  -textvariable logsrch -width 24
		button $f1.r -text "Reference" -command "RefSee 3"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $f1.rr -text "Remember Selected Log" -command "LogRemem" -highlightbackground [option get . background {}]
		pack $f1.quit $f1.rr -side right -padx 1
		pack $f1.search $f1.msg $f1.e $f1.get $f1.r -side left -padx 1
		label $f.msg2 -text "LOGS CONTAINING THE TEXT"
		label $f.msg3 -text "LINES IN SELECTED LOG CONTAINING THE TEXT"
		frame $f.2 -bg [option get . foreground {}] -height 1
		frame $f.3 -bg [option get . foreground {}] -height 1
		frame $f.4 -bg [option get . foreground {}] -height 1
		frame $f.5 -bg [option get . foreground {}] -height 1
		set loglisting [Scrolled_Listbox $f.ll -width 30 -height 16 -selectmode single]
		set logviewing [Scrolled_Listbox $f.lv -width 120 -height 16 -selectmode single]
		pack $f.1 -side top -fill x
		pack $f.2 $f.msg2 $f.3 -side top -fill x -expand true -pady 2
		pack $f.ll -side top
		pack $f.4 $f.msg3 $f.5 -side top -fill x -expand true -pady 2
		pack $f.lv -side top
		bind $loglisting <ButtonRelease-1> "DisplayChosenLog %W"
		bind $f <Escape> {set pr_slog 0}
		bind $f <Return> {set pr_slog 1}
	}
	if {$getlog} {
		.slog.1.rr config -text "Get Selected Log" -command "LogGet"
	} else {
		.slog.1.rr config -text "Remember Selected Log" -command "LogRemem"
	}
	wm resizable $f 1 1
	$loglisting delete 0 end
	$logviewing delete 0 end
	set pr_slog 0
	set finished 0
	set firsttime 1
	raise $f
	My_Grab 0 $f pr_slog $f.1.e
	while {!$finished} {
		tkwait variable pr_slog
		if {$pr_slog > 0} {
			catch {unset foundlogs}
			catch {unset badlogs}
			$loglisting delete 0 end
			$logviewing delete 0 end
			if {[string length $logsrch] <= 0} {
				Inf "No search text given"
				continue
			}
			set logsrch [RegulariseDirectoryRepresentation $logsrch]
			set alogsrch ">"
			append alogsrch $logsrch
			set dlogsrch "/"
			append dlogsrch $logsrch
			if {$firsttime} {
				Block "Searching Logs"
				foreach item [glob -nocomplain [file join $evv(LOGDIR) *]] {
					if {![string match [file extension $item] $evv(CDP_EXT)]} {
						lappend logslist [file tail $item]
					}
				}
				UnBlock
				set firsttime 0
			}
			if {![info exists logslist]} {
				Inf "No log files found"
				set finished 1
				break
			}
			foreach fnam $logslist {
				if [catch {open [file join $evv(LOGDIR) $fnam] "r"} fId] {
					lappend badlogs $fnam
					continue
				}
				while {[gets $fId line] >= 0} {
					if {[regexp " $logsrch" $line] || [regexp "$dlogsrch" $line] || [regexp "$alogsrch" $line]} {
						lappend foundlogs $fnam
						break
					}
				}
				catch {close $fId}
			}
			if [info exists badlogs] {
				if {[llength $badlogs] > 20} {
					Inf "20 (or more) log files failed to open"
				} else {
					set blog ""
					foreach badlog $badlogs {
						append blog $badlog " "
					}
					Inf "Failed to Open the following log files....\n\n$blog"
				}
			}
			if {![info exists foundlogs]} {
				Inf "No references found to this text"
				continue
			}
			set foundlogs [SortLogList $foundlogs]
			foreach foundlog $foundlogs {
				$loglisting insert end $foundlog
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc DisplayChosenLog {w} {
	global logsrch logviewing evv

	if {[string length $logsrch] <= 0} {
		Inf "No search text given"
		return
	}
	set alogsrch ">"
	append alogsrch $logsrch
	set dlogsrch "/"
	append dlogsrch $logsrch

	$logviewing delete 0 end
	set indx [$w curselection]
	if {[string length $indx] <= 0} {
		Inf "No log file selected"
		return
	}
	set fnam [$w get $indx]
	if [catch {open [file join $evv(LOGDIR) $fnam] "r"} fId] {
		Inf "Cannot open log '$fnam'"
		return
	}
	set i 0
	while {[gets $fId line] >= 0} {
		if [IsEven $i] {
			set toview 0
			set line0 $line
		} else {
			set line1 $line
		}
		if {[regexp " $logsrch" $line] || [regexp "$dlogsrch" $line] || [regexp "$alogsrch" $line]} {
			set toview 1
		}
		if {![IsEven $i] && $toview} {
			if {![string match [lindex $line0 0] "SLOOM:"]} {
				set line0 [SimplifyLogViewLine $line0]
				append line0 " ::OUTFILES:: " $line1
			}
			$logviewing insert end $line0
		}
		incr i
	}
	close $fId
}

proc SimplifyLogViewLine {progline} {
	global prg evv

	set dirlen [string length $evv(CDPROGRAM_DIR)]
	incr dirlen
	set proc_name [lindex $progline 0] 
	if [string match $evv(CDPROGRAM_DIR)* $proc_name] {				;#	process, not ins
		lappend outstring [string range $proc_name $dirlen end]
		set prog_no [lindex $progline 1]
		set proc_name [split [lindex $prg($prog_no) 1]]
		set proc_name [join $proc_name _]
		lappend outstring $proc_name
		set mode_no [lindex $progline 2]
		if {$mode_no > 0} {
			incr mode_no 2
			set mode_name [split [lindex $prg($prog_no) $mode_no]]
			set mode_name [join $mode_name _]
			lappend outstring $mode_name
		}
		set here 3
		set incnt [lindex $progline $here]							;#	count of infiles
		set skip 1													;#	skip the infile count
		if {$incnt > 0} {
			incr skip $evv(CDP_PROPS_CNT)							;#	skip the infile props
		}
		incr here $skip
		set j 0
		while {$j < $incnt} {						 				;#	Keep the infile names
			if {$j < $evv(MAX_HDISPLAY_INFILES)} {
				lappend outstring [lindex $progline $here]
			}
			incr here
			incr j
		}
		if {$j > $evv(MAX_HDISPLAY_INFILES)} {
			lappend outstring "ETC."
		}

		incr here													;#	Skip the outfilename
	} else {
		lappend outstring [lindex $progline 0]						;#	ins name
		set here 1
		set incnt [lindex $progline $here]							;#	count of infiles
		incr here													;#	skip the infile count
		set j 0
		while {$j < $incnt} {						 				;#	Keep the infile names
			if {$j < $evv(MAX_HDISPLAY_INFILES)} {
				lappend outstring [lindex $progline $here]
			}
			incr here
			incr j
		}
		if {$j > $evv(MAX_HDISPLAY_INFILES)} {
			lappend outstring "ETC."
		}
	}
	set temp [lrange $progline $here end]							;#	get params list
	set pcnt [llength $temp]									
	if {$pcnt > 0} {
		lappend outstring "--PARAMS:"
		set j 0
		while {$j < $pcnt} {
			set thisparam [lindex $temp $j]								;#	list all params
		 	if [string match $evv(NUM_MARK)* $thisparam] {		;#	dropping any markers
				lappend outstring [string range $thisparam 1 end] 
			} else {
				lappend outstring $thisparam
			}
			incr j
		}
	}
	return $outstring
}

#---- Create a History for a non-CDP event

proc DummyHistory {fnam str} {
	global saved_cmd ins hst from_instr is_dummy_history

	set saved_cmd "SLOOM: "
	append saved_cmd " $fnam" " $str"
	set is_dummy_history 1
	DoHistory
	set is_dummy_history 0
}

proc SearchActionDisplay {} {
	global action_src last_action_src hl lastactstart evv

	if {[string length $action_src] <= 0}  {
		Inf "No Seach String Given"
		return
	}
	set len 0
	foreach item [$hl get 0 end] {
		incr len
	}
	if {$len == 0} {
		Inf "No Display To Search"
		return
	}
	if {[info exists last_action_src] && [string match $last_action_src $action_src]} {
		set i $lastactstart
		foreach item [$hl get $lastactstart end] {
			if {[string first $action_src $item] >= 0} {
				$hl selection clear 0 end
				$hl selection set $i
				incr i
				if {$i >= $len} {
					set i 0
				}
				set lastactstart $i	
				set last_action_src $action_src
				return
			}
			incr i
		}
	} else {
		set lastactstart "end"
	}
	set i 0
	foreach item [$hl get 0 $lastactstart] {
		if {[string first $action_src $item] >= 0} {
			$hl selection clear 0 end
			$hl selection set $i
			incr i
			if {$i >= $len} {
				set i 0
			}		
			set lastactstart $i
			set last_action_src $action_src
			return
		}
		incr i
	}
	catch {unset last_action_src}
	catch {unset lastactstart}
	Inf "Not Found : Try a later or earlier Block??"
}

#--- Cureent date ealier then reference date

proc IsEarlier {name thisyear thismonth thisdate thishour thismin} {

	set k [string first "." $name]
	incr k
	set year [string range $name $k end]
	if {$year < $thisyear} {
		return 1
	} elseif {$year > $thisyear} {
		return 0
	}
	set k [string first "_" $name]
	incr k -1
	set day [string range $name 0 $k]
	set z [string length $day]
	set x 0
	while {$x < $z} {
		if [string match {[0-9]} [string index $day $x]] {
			break
		}
		incr x
	}
	set date [string range $day $x end]
	incr x -1
	set month [string range $day 0 $x]
	set monthskip [MonthCompare $thismonth $month]
	if {$monthskip < 0} {
		return 1
	} elseif {$monthskip > 0} {
		return 0
	}
	if {$date < $thisdate} {
		return 1
	} elseif {$date > $thisdate} {
		return 0
	}
	incr k 2
	set rest [string range $name $k end]
	set k [string first "-" $rest]
	incr k -1
	set hour [string range $rest 0 $k]
	incr k 2
	set rest [string range $rest $k end]
	set k [string first "." $rest]
	incr k -1
	set min [string range $rest 0 $k]
	if {$hour < $thishour} {
		return 1
	} elseif {$hour > $thishour} {
		return 0
	}
	if {$min < $thismin} {
		return 1
	}
	return 0
}


proc UpdateLog {} {
	global is_blocked hst memory evv
	if {![info exists is_blocked]} {
		Block "Updating Log"
		set hblocking 1
	}
	if [file exists [file join $evv(LOGDIR) $hst(todaysname)]] {  				
		set i 0									;#	May have been lost during hst recall, or error or etc
		while {$i < $evv(HISTORY_LINESTORE)} {	;# 	Save half of current hst, append to log file
			puts $hst(fileId) "[lindex $memory(current) $i]"
			incr i
		}
		incr hst(cnt) $evv(HISTORY_BLOK)
	}
	incr hst(maxbaktrak)
	set memory(current) [lreplace $memory(current) 0 $evv(HALF_HISTORY_INDEX)]	;#	Remove past half of hst store
	set memory(cnt) $evv(HISTORY_BLOK)
	if {[info exists hblocking]} {
		UnBlock
		unset hblocking
	}
}

proc LogRemem {} {
	global loglisting log_remembered
	if {[$loglisting index end] == 1} {
		set log_remembered [$loglisting get 0]
		Inf "Remembered Logname '$log_remembered'"
		return
	}
	set i [$loglisting curselection]
	if {$i < 0} {
		Inf "No Log File Selected"
		return
	}
	set log_remembered [$loglisting get $i]
	Inf "Remembered Logname '$log_remembered'"
}

proc LogRecall {} {
	global log_remembered hst evv
	if {![info exists log_remembered] || ([string length $log_remembered] <= 0)} {
		Inf "No Log File Remembered"
		return
	}
	set fnam [file join $evv(LOGDIR) $log_remembered]
	if {![file exists $fnam]} {
		unset log_remembered
		Inf "The Log '$log_remembered' No Longer Exists"
		return
	}
	set hst(chosenname) $log_remembered
	ForceVal .history_listing.ln $hst(chosenname)
	GetNewLog .history_listing
}

proc LogGet {} {
	global loglisting log_remembered hst action_src logsrch pr_slog evv
	set i [$loglisting curselection]
	if {$i < 0} {
		if {[$loglisting index end] == 1} {
			set i 0
		} else {
			Inf "NO LOG FILE SELECTED"
			return
		}
	}
	set log_remembered [$loglisting get $i]
	set fnam [file join $evv(LOGDIR) $log_remembered]
	if {![file exists $fnam]} {
		unset log_remembered
		Inf "The Log '$log_remembered' No Longer Exists"
		return
	}
	set hst(chosenname) $log_remembered
	ForceVal .history_listing.ln $hst(chosenname)

	if {[info exists logsrch] && ([string length $logsrch] > 0)} {
		set action_src [file rootname $logsrch]
	}
	GetNewLog .history_listing
	set pr_slog 0
}

proc SearchLogsGet {where} {
	global wl ch dl chlist logsrch
	switch -- $where {
		"wl" {set listing $wl}
		"ch" {set listing $ch}
		"dl" {set listing $dl}
	}
	if {$where == "ch"} {
		if {![info exists chlist] || ([llength $chlist] <= 0)} {
			Inf "No File On The Chosen List"
			return
		} elseif {[llength $chlist] > 1} {
			Inf "More Than One File On The Chosen List: Using The First"
		}
		set i 0
	} else {
		set ilist [$listing curselection]
		if {[llength $ilist] > 1} {
			Inf "Too Many Files Selected: Using The First"
		}
		set i [lindex $ilist 0]
		if {$i < 0} {
			Inf "No File Selected"
			return
		}
	}
	set logsrch [file tail [$listing get $i]]
}

#
#	There can only be duplicates if we've been running MIX etc (sndfiles) or VBOX (mono snds or anal) or RHYTHMIC KNOTS or DATA PROGS
#

proc ChlistDupls {} {
	global chlist evv pa dupl_txt dupl_mix dupl_vbx ch_analy ww
	set f $ww.1.a.endd.r.rr.cnts
	set dupl_mix 0
	set dupl_vbx 0
	set dupl_txt 0
	set ch_analy 0
	if {![info exists chlist] || ([llength $chlist] < 2)} {
		$f config -readonlybackground [option get . readonlybackground {}]
		return 0
	}
	set anatyp 0
	set montyp 0
	set mlttyp 0
	set txttyp 0
	set anadupl 0
	set txtdupl 0
	set mondupl 0
	set mltdupl 0
	set ftp 0
	set len [llength $chlist]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set fn [lindex $chlist $n]
		set ftyp $pa($fn,$evv(FTYP))
		if {$ftyp == $evv(ANALFILE)} {
			set anatyp 1								;#	Note which filetype(s) are in list
			set ftp 1
		} elseif {$ftyp & $evv(IS_A_TEXTFILE)} {
			set txttyp 1
			set ftp 2
		} elseif {$ftyp == $evv(SNDFILE)} {
			if {$pa($fn,$evv(CHANS)) == 1} {
				set montyp 1
				set ftp 3
			} else {
				set mlttyp 1
				set ftp 4
			}
		}
		set m $n
		incr m
		while {$m < $len} {
			set fm [lindex $chlist $m]					;#	Note which filetypes are duplicated in list
			if {[string match $fn $fm]} {
				switch -- $ftp {
					1 { set anadupl 1 }
					2 { set txtdupl 1 }
					3 { set mondupl 1 }
					4 { set mltdupl 1 }
				}
			}
			incr m
		}
		incr n
	}
	set fn [lindex $chlist $n]
	set ftyp $pa($fn,$evv(FTYP))						;#	Do'nt forget to get type of last file in list
	if {$ftyp == $evv(ANALFILE)} {
		set anatyp 1
		set ftp 1
	} elseif {$ftyp & $evv(IS_A_TEXTFILE)} {
		set txttyp 1
		set ftp 2
	} elseif {$ftyp == $evv(SNDFILE)} {
		if {$pa($fn,$evv(CHANS)) == 1} {
			set montyp 1
			set ftp 3
		} else {
			set mlttyp 1
			set ftp 4
		}
	}
	if {$ftp == 0} {															;#	chlist contains files that are not text, snd or anal files
		$f config -readonlybackground [option get . readonlybackground {}]			;#	not a viable vbox, mix or rhythmic-knots/data listing		
		return 0																
	}
	if {$txttyp} {																;#	chlist contains text files
		if {([expr $anatyp + $montyp + $mlttyp] == 0) && ($txtdupl)} {			;#	does not contain ana or snd files, and contains duplicate text files.
			set dupl_txt 1														;#	Only viable as rhythmic-knots/data process listing,
		}
	} elseif {$anatyp} {														;#	chlist contains no text files and has "analysis" files
		set ch_analy 1															;#	(mark existence of analfile in chlist)
		if {!$mlttyp} {															;#	does not contain non-mono snds
			if {$anadupl || $mondupl} {											;#	and has duplicate analysis files.
				set dupl_vbx 1													;#	Only viable as voicebox listing.
			}
		}
	} elseif {$mlttyp} {														;#	chlist contains no text or analysis files
		if {$mltdupl} {															;#	and contains non-mono sndfiles, in duplicate.
			set dupl_mix 1														;#	Only viable as mixfile, texture etc listing.
		}
	} elseif {$mondupl} {														;#	chlist contains no text, or analysis, or non-mono files
		set dupl_mix 1															;#	and has multiple mono sndfiles.
		set dupl_vbx 1															;#	Viable as both mixfile, texture etc listing, and as voicelbox listing.
	}
	set dupls [expr $dupl_txt + $dupl_mix + $dupl_vbx]
	if {$dupls} {
		$f config -readonlybackground green
	} else {
		$f config -readonlybackground [option get . readonlybackground {}]
	}
	return $dupls																;#	Returns 0 if NO duplicates
}

#LISTINGS EMERGENCY MAY 2007

proc DateByHand {} {
	global last_dbh pr_dbh dbh_mo dbh_d dbh_h dbh_pm dbh_mi dbh_y evv logname wstk

	set dbh_mo 0
	set dbh_d  0
	set dbh_h  -1
	set dbh_pm 0
	set dbh_mi -1
	set dbh_y  0

	set f .dbh
	if [Dlg_Create $f "Enter Date and Time by Hand" "set pr_dbh 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.00 -bg [option get . foreground {}] -height 1
		frame $f.1
		button $f.0.set -text "Set Date and Time" -command "set pr_dbh 1" -highlightbackground [option get . background {}]
		button $f.0.qq -text "Abandon" -command "set pr_dbh 0" -highlightbackground [option get . background {}]
		pack $f.0.set -side left
		pack $f.0.qq -side right
		set year  [frame $f.1.year]
		frame $f.1.1 -bg [option get . foreground {}] -width 1
		set month [frame $f.1.month]
		frame $f.1.2 -bg [option get . foreground {}] -width 1
		set day   [frame $f.1.day]
		frame $f.1.3 -bg [option get . foreground {}] -width 1
		set hour  [frame $f.1.hour]
		frame $f.1.4 -bg [option get . foreground {}] -width 1
		set min   [frame $f.1.min]
		label $month.0 -text "MONTH"
		radiobutton $month.1  -text "Jan" -variable dbh_mo -value 1 -command "SetDays 31"
		radiobutton $month.2  -text "Feb" -variable dbh_mo -value 2 -command "SetDays leap"
		radiobutton $month.3  -text "Mar" -variable dbh_mo -value 3 -command "SetDays 31"
		radiobutton $month.4  -text "Apr" -variable dbh_mo -value 4 -command "SetDays 30"
		radiobutton $month.5  -text "May" -variable dbh_mo -value 5 -command "SetDays 31"
		radiobutton $month.6  -text "Jun" -variable dbh_mo -value 6 -command "SetDays 30"
		radiobutton $month.7  -text "Jul" -variable dbh_mo -value 7 -command "SetDays 31"
		radiobutton $month.8  -text "Aug" -variable dbh_mo -value 8 -command "SetDays 31"
		radiobutton $month.9  -text "Sep" -variable dbh_mo -value 9 -command "SetDays 30"
		radiobutton $month.10 -text "Oct" -variable dbh_mo -value 10 -command "SetDays 31"
		radiobutton $month.11 -text "Nov" -variable dbh_mo -value 11 -command "SetDays 30"
		radiobutton $month.12 -text "Dec" -variable dbh_mo -value 12 -command "SetDays 31"
		pack $month.0 $month.1 $month.2 $month.3 $month.4 $month.5 $month.6 \
		  $month.7 $month.8 $month.9 $month.10 $month.11 $month.12 -side top -fill y
		label $day.0 -text "DAY"
		frame $day.1
		frame $day.1.0
		frame $day.1.1
		frame $day.1.2
		radiobutton $day.1.0.1  -text "1" -variable dbh_d -value 1
		radiobutton $day.1.0.2  -text "2" -variable dbh_d -value 2
		radiobutton $day.1.0.3  -text "3" -variable dbh_d -value 3
		radiobutton $day.1.0.4  -text "4" -variable dbh_d -value 4
		radiobutton $day.1.0.5  -text "5" -variable dbh_d -value 5
		radiobutton $day.1.0.6  -text "6" -variable dbh_d -value 6
		radiobutton $day.1.0.7  -text "7" -variable dbh_d -value 7
		radiobutton $day.1.0.8  -text "8" -variable dbh_d -value 8
		radiobutton $day.1.0.9  -text "9" -variable dbh_d -value 9
		radiobutton $day.1.0.10 -text "10" -variable dbh_d -value 10
		pack $day.1.0.1 $day.1.0.2 $day.1.0.3 $day.1.0.4 $day.1.0.5 $day.1.0.6 $day.1.0.7 $day.1.0.8 $day.1.0.9 $day.1.0.10 -side top -fill y -expand true -fill y
		radiobutton $day.1.1.11 -text "11" -variable dbh_d -value 11
		radiobutton $day.1.1.12 -text "12" -variable dbh_d -value 12
		radiobutton $day.1.1.13 -text "13" -variable dbh_d -value 13
		radiobutton $day.1.1.14 -text "14" -variable dbh_d -value 14
		radiobutton $day.1.1.15 -text "15" -variable dbh_d -value 15
		radiobutton $day.1.1.16 -text "16" -variable dbh_d -value 16
		radiobutton $day.1.1.17 -text "17" -variable dbh_d -value 17
		radiobutton $day.1.1.18 -text "18" -variable dbh_d -value 18
		radiobutton $day.1.1.19 -text "19" -variable dbh_d -value 19
		radiobutton $day.1.1.20 -text "20" -variable dbh_d -value 20
		pack $day.1.1.11 $day.1.1.12 $day.1.1.13 $day.1.1.14 $day.1.1.15 $day.1.1.16 $day.1.1.17 $day.1.1.18 $day.1.1.19 $day.1.1.20 -side top -fill y -expand true -fill y
		radiobutton $day.1.2.21 -text "21" -variable dbh_d -value 21
		radiobutton $day.1.2.22 -text "22" -variable dbh_d -value 22
		radiobutton $day.1.2.23 -text "23" -variable dbh_d -value 23
		radiobutton $day.1.2.24 -text "24" -variable dbh_d -value 24
		radiobutton $day.1.2.25 -text "25" -variable dbh_d -value 25
		radiobutton $day.1.2.26 -text "26" -variable dbh_d -value 26
		radiobutton $day.1.2.27 -text "27" -variable dbh_d -value 27
		radiobutton $day.1.2.28 -text "28" -variable dbh_d -value 28
		radiobutton $day.1.2.29 -text "29" -variable dbh_d -value 29
		radiobutton $day.1.2.30 -text "30" -variable dbh_d -value 30
		radiobutton $day.1.2.31 -text "31" -variable dbh_d -value 31
		pack $day.1.2.21 $day.1.2.22 $day.1.2.23 $day.1.2.24 $day.1.2.25 $day.1.2.26 $day.1.2.27 $day.1.2.28 $day.1.2.29 $day.1.2.30 $day.1.2.31 -side top -fill y -expand true -fill y
		pack $day.1.0 $day.1.1 $day.1.2 -side left
		pack $day.0 $day.1 -side top -fill y

		frame $hour.00
		label $hour.00.0 -text "HOUR"
		pack $hour.00.0 -side top
		frame $hour.0
		radiobutton $hour.0.am  -text "am"  -variable dbh_pm -value 0 -command NoonMidnight
		radiobutton $hour.0.pm  -text "pm"  -variable dbh_pm -value 1 -command NoonMidnight
		pack $hour.0.am $hour.0.pm -side left -fill x -expand true
		pack $hour.0.am $hour.0.pm -side left -fill x -expand true
		frame $hour.01
		label $hour.01.1 -text "MORNING"
		pack $hour.01.1 -side top
		frame $hour.1
		radiobutton $hour.1.12 -text "12 Midnight" -variable dbh_h -value 0
		radiobutton $hour.1.1  -text "1"  -variable dbh_h -value 1
		radiobutton $hour.1.2  -text "2"  -variable dbh_h -value 2
		radiobutton $hour.1.3  -text "3"  -variable dbh_h -value 3
		radiobutton $hour.1.4  -text "4"  -variable dbh_h -value 4
		radiobutton $hour.1.5  -text "5"  -variable dbh_h -value 5
		radiobutton $hour.1.6  -text "6"  -variable dbh_h -value 6
		radiobutton $hour.1.7  -text "7"  -variable dbh_h -value 7
		radiobutton $hour.1.8  -text "8"  -variable dbh_h -value 8
		radiobutton $hour.1.9  -text "9"  -variable dbh_h -value 9
		radiobutton $hour.1.10 -text "10" -variable dbh_h -value 10
		radiobutton $hour.1.11 -text "11" -variable dbh_h -value 11
		pack $hour.1.12 $hour.1.1 $hour.1.2 $hour.1.3 $hour.1.4 $hour.1.5 $hour.1.6 $hour.1.7 $hour.1.8 $hour.1.9 $hour.1.10 $hour.1.11 -side top
		pack $hour.00 $hour.0 $hour.01 $hour.1 -side top -fill y

		label $min.0 -text "MIN"
		frame $min.1
		frame $min.1.0
		frame $min.1.1
		frame $min.1.2
		radiobutton $min.1.0.0  -text "0"  -variable dbh_mi -value 0  
		radiobutton $min.1.0.1  -text "1"  -variable dbh_mi -value 1  
		radiobutton $min.1.0.2  -text "2"  -variable dbh_mi -value 2  
		radiobutton $min.1.0.3  -text "3"  -variable dbh_mi -value 3  
		radiobutton $min.1.0.4  -text "4"  -variable dbh_mi -value 4  
		radiobutton $min.1.0.5  -text "5"  -variable dbh_mi -value 5  
		radiobutton $min.1.0.6  -text "6"  -variable dbh_mi -value 6  
		radiobutton $min.1.0.7  -text "7"  -variable dbh_mi -value 7  
		radiobutton $min.1.0.8  -text "8"  -variable dbh_mi -value 8  
		radiobutton $min.1.0.9  -text "9" -variable dbh_mi  -value 9  
		radiobutton $min.1.0.10 -text "10" -variable dbh_mi -value 10 
		radiobutton $min.1.0.11 -text "11" -variable dbh_mi -value 11 
		radiobutton $min.1.0.12 -text "12" -variable dbh_mi -value 12 
		radiobutton $min.1.0.13 -text "13" -variable dbh_mi -value 13 
		radiobutton $min.1.0.14 -text "14" -variable dbh_mi -value 14 
		radiobutton $min.1.0.15 -text "15" -variable dbh_mi -value 15 
		radiobutton $min.1.0.16 -text "16" -variable dbh_mi -value 16 
		radiobutton $min.1.0.17 -text "17" -variable dbh_mi -value 17 
		radiobutton $min.1.0.18 -text "18" -variable dbh_mi -value 18 
		radiobutton $min.1.0.19 -text "19" -variable dbh_mi -value 19 
		pack $min.1.0.0 $min.1.0.1 $min.1.0.2 $min.1.0.3 $min.1.0.4 $min.1.0.5 $min.1.0.6 $min.1.0.7 $min.1.0.8 $min.1.0.9 \
		 $min.1.0.10 $min.1.0.11 $min.1.0.12 $min.1.0.13 $min.1.0.14 $min.1.0.15 $min.1.0.16 $min.1.0.17 $min.1.0.18 $min.1.0.19 -side top
		radiobutton $min.1.1.20 -text "20" -variable dbh_mi -value 20 
		radiobutton $min.1.1.21 -text "21" -variable dbh_mi -value 21 
		radiobutton $min.1.1.22 -text "22" -variable dbh_mi -value 22 
		radiobutton $min.1.1.23 -text "23" -variable dbh_mi -value 23 
		radiobutton $min.1.1.24 -text "24" -variable dbh_mi -value 24 
		radiobutton $min.1.1.25 -text "25" -variable dbh_mi -value 25 
		radiobutton $min.1.1.26 -text "26" -variable dbh_mi -value 26 
		radiobutton $min.1.1.27 -text "27" -variable dbh_mi -value 27 
		radiobutton $min.1.1.28 -text "28" -variable dbh_mi -value 28 
		radiobutton $min.1.1.29 -text "29" -variable dbh_mi -value 29 
		radiobutton $min.1.1.30 -text "30" -variable dbh_mi -value 30 
		radiobutton $min.1.1.31 -text "31" -variable dbh_mi -value 31 
		radiobutton $min.1.1.32 -text "32" -variable dbh_mi -value 32 
		radiobutton $min.1.1.33 -text "33" -variable dbh_mi -value 33 
		radiobutton $min.1.1.34 -text "34" -variable dbh_mi -value 34 
		radiobutton $min.1.1.35 -text "35" -variable dbh_mi -value 35 
		radiobutton $min.1.1.36 -text "36" -variable dbh_mi -value 36 
		radiobutton $min.1.1.37 -text "37" -variable dbh_mi -value 37 
		radiobutton $min.1.1.38 -text "38" -variable dbh_mi -value 38 
		radiobutton $min.1.1.39 -text "39" -variable dbh_mi -value 39 
		pack $min.1.1.20 $min.1.1.21 $min.1.1.22 $min.1.1.23 $min.1.1.24 $min.1.1.25 $min.1.1.26 $min.1.1.27 $min.1.1.28 $min.1.1.29 \
			$min.1.1.30 $min.1.1.31 $min.1.1.32 $min.1.1.33 $min.1.1.34 $min.1.1.35 $min.1.1.36 $min.1.1.37 $min.1.1.38 $min.1.1.39 -side top
		radiobutton $min.1.2.40 -text "40" -variable dbh_mi -value 40 
		radiobutton $min.1.2.41 -text "41" -variable dbh_mi -value 41 
		radiobutton $min.1.2.42 -text "42" -variable dbh_mi -value 42 
		radiobutton $min.1.2.43 -text "43" -variable dbh_mi -value 43 
		radiobutton $min.1.2.44 -text "44" -variable dbh_mi -value 44 
		radiobutton $min.1.2.45 -text "45" -variable dbh_mi -value 45 
		radiobutton $min.1.2.46 -text "46" -variable dbh_mi -value 46 
		radiobutton $min.1.2.47 -text "47" -variable dbh_mi -value 47 
		radiobutton $min.1.2.48 -text "48" -variable dbh_mi -value 48 
		radiobutton $min.1.2.49 -text "49" -variable dbh_mi -value 49 
		radiobutton $min.1.2.50 -text "50" -variable dbh_mi -value 50 
		radiobutton $min.1.2.51 -text "51" -variable dbh_mi -value 51 
		radiobutton $min.1.2.52 -text "52" -variable dbh_mi -value 52 
		radiobutton $min.1.2.53 -text "53" -variable dbh_mi -value 53 
		radiobutton $min.1.2.54 -text "54" -variable dbh_mi -value 54 
		radiobutton $min.1.2.55 -text "55" -variable dbh_mi -value 55 
		radiobutton $min.1.2.56 -text "56" -variable dbh_mi -value 56 
		radiobutton $min.1.2.57 -text "57" -variable dbh_mi -value 57 
		radiobutton $min.1.2.58 -text "58" -variable dbh_mi -value 58 
		radiobutton $min.1.2.59 -text "59" -variable dbh_mi -value 59 
		pack $min.1.2.40 $min.1.2.41 $min.1.2.42 $min.1.2.43 $min.1.2.44 $min.1.2.45 $min.1.2.46 $min.1.2.47 $min.1.2.48 $min.1.2.49 \
			$min.1.2.50 $min.1.2.51 $min.1.2.52 $min.1.2.53 $min.1.2.54 $min.1.2.55 $min.1.2.56 $min.1.2.57 $min.1.2.58 $min.1.2.59 -side top
		pack $min.1.0 $min.1.1 $min.1.2 -side left
		pack $min.0 $min.1 -side top

		label $year.0 -text "YEAR"
		radiobutton $year.2007 -text "2007" -variable dbh_y -value 2007
		radiobutton $year.2008 -text "2008" -variable dbh_y -value 2008
		radiobutton $year.2009 -text "2009" -variable dbh_y -value 2009
		radiobutton $year.2010 -text "2010" -variable dbh_y -value 2010
		radiobutton $year.2011 -text "2011" -variable dbh_y -value 2011
		radiobutton $year.2012 -text "2012" -variable dbh_y -value 2012
		radiobutton $year.2013 -text "2013" -variable dbh_y -value 2013
		radiobutton $year.2014 -text "2014" -variable dbh_y -value 2014
		radiobutton $year.2015 -text "2015" -variable dbh_y -value 2015
		radiobutton $year.2016 -text "2016" -variable dbh_y -value 2016
		radiobutton $year.2017 -text "2017" -variable dbh_y -value 2017
		radiobutton $year.2018 -text "2018" -variable dbh_y -value 2018
		radiobutton $year.2019 -text "2019" -variable dbh_y -value 2019
		radiobutton $year.2020 -text "2020" -variable dbh_y -value 2020
		pack $year.0 $year.2007 $year.2008 $year.2009 $year.2010 $year.2011 $year.2012 $year.2013 \
			$year.2014 $year.2015 $year.2016 $year.2017 $year.2018 $year.2019 $year.2020 -side top -fill y

		pack $min -side right
		pack $f.1.4 -side right -fill y -expand true
		pack $hour -side right -fill y -expand true
		pack $f.1.3 -side right -fill y -expand true
		pack $day -side right -fill y -expand true
		pack $f.1.2 -side right -fill y -expand true
		pack $month -side right -fill y -expand true
		pack $f.1.1 -side right -fill y -expand true
		pack $year -side right -fill y -expand true

		pack $f.0 -side top -fill x -expand true
		pack $f.00 -side top -fill x -expand true
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Escape> {set pr_dbh 0}
		bind $f <Return> {set pr_dbh 1}
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_dbh 0
	set finished 0
	My_Grab 0 $f pr_dbh $f
	while {!$finished} {
		tkwait variable pr_dbh
		if {!$dbh_mo} {
			Inf "No Month Set"
			continue
		}
		if {!$dbh_d} {
			Inf "No Date Set"
			continue
		}
		if {!$dbh_h < 0} {
			Inf "No Hour Set"
			continue
		}
		if {$dbh_mi < 0} {
			Inf "No Minute Set"
			continue
		}
		if {!$dbh_y} {
			Inf "No Year Set"
			continue
		}
		switch -- $dbh_mo {
			1  { set outstr "Jan"}
			2  { set outstr "Feb"}
			3  { set outstr "Mar"}
			4  { set outstr "Apr"}
			5  { set outstr "May"}
			6  { set outstr "Jun"}
			7  { set outstr "Jul"}
			8  { set outstr "Aug"}
			9  { set outstr "Sep"}
			10 { set outstr "Oct"}
			11 { set outstr "Nov"}
			12 { set outstr "Dec"}
		}
		if {[string length $dbh_d] == 1} {
			append outstr 0
		}
		append outstr $dbh_d "_"
		if {$dbh_pm} {
			incr dbh_h 12
		}
		if {[string length $dbh_h] == 1} {
			append outstr 0
		}
		append outstr $dbh_h "-"
		if {[string length $dbh_mi] == 1} {
			append outstr 0
		}
		append outstr $dbh_mi "-00." $dbh_y
		set msg2 [RationalDate $dbh_y $dbh_mo $dbh_d $dbh_h $dbh_mi]
		if {[string length $msg2] > 0} {
			set msg "The Entered Date Does Not Tally With Existing Logs: ($msg2): Are You Sure This Is Correct ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				continue
			}
		}
		set logname $outstr
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc SetDays {val} {
	global dbh_d dbh_mo dbh_y
	switch -- $val {
		30 { 
			if {$dbh_d == 31} {
				set dbh_d 0
			}
			.dbh.1.day.1.2.29 config -text "29" -state normal
			.dbh.1.day.1.2.30 config -text "30" -state normal
			.dbh.1.day.1.2.31 config -text "" -state disabled
		}
		31 { 
			.dbh.1.day.1.2.29 config -text "29" -state normal
			.dbh.1.day.1.2.30 config -text "30" -state normal
			.dbh.1.day.1.2.31 config -text "31" -state normal
		}
		leap {
			if {$dbh_y == 0} {
				Inf "Set Year First"
				set dbh_d 0
				set dbh_mo 0
			}
			set leap 0
			if {([expr $dbh_y % 4] == 0) && ([expr $dbh_y % 1000] != 0)} {
				set leap 1
			}
			if {!$leap} {
				if {$dbh_d > 28} {
					set dbh_d 0
				}
				.dbh.1.day.1.2.29 config -text "" -state disabled
			} else {
				if {$dbh_d > 29} {
					set dbh_d 0
				}
				.dbh.1.day.1.2.29 config -text "29" -state normal
			}
			.dbh.1.day.1.2.30 config -text "" -state disabled
			.dbh.1.day.1.2.31 config -text "" -state disabled
		}
	}
}

proc NoonMidnight {} {
	global dbh_pm
	if {$dbh_pm} {
		.dbh.1.hour.1.12 config -text "Noon"
		.dbh.1.hour.01.1 config -text "AFTERNOON"

	} else {
		.dbh.1.hour.1.12 config -text "Midnight"
		.dbh.1.hour.01.1 config -text "MORNING"
	}
}

proc CheckListingNameSecs {zname} {
	global evv
	set zstart [string range $zname 0 13]
	set zend   [string range $zname 16 end]
	set zsecs  [string range $zname 14 15]
	if {[string match [string index $zsecs 0] "0"]} {
		set zsecs [string range $zsecs 1 end]
	}
	foreach fnm [glob -nocomplain [file join $evv(URES_DIR) *]] {	
		set fnm [file tail $fnm]
		set start [string range $fnm 0 13]
		set end   [string range $fnm 16 end]
		if {[string match $zstart $start] && [string match $zend $end]} {
			set secs  [string range $fnm 14 15]
			if {[string match [string index $secs 0] "0"]} {
				set secs [string range $secs 1 end]
			}
			if {$zsecs <= $secs} {
				set zname $zstart
				incr secs
				set zsecs $secs
				if {[string length $zsecs] < 2} {
					append zname "0"
				}
				append zname $zsecs $zend
			}
		}
	}
	return $zname
}

proc LognameDerive {} {
	global superlog logname
	set logname [string range $superlog 0 10]
	append logname [string range $superlog 14 end]
}

proc RationalDate {y mo d h mi} {
	global evv
	foreach fnam [glob -nocomplain [file join $evv(LOGDIR) *]]] {
		set fnam [file tail $fnam]
		set fy	[string range [file extension $fnam] 1 end]
		if {![regexp {^[0-9]+$} $fy]} {
			continue
		}
		if {$y < $fy} {
			return "Incorrect Year"
		} elseif {$fy < $y} {
			continue
		}
		set fmo [string range $fnam 0 2]
		switch -- $fmo {
			Jan { set fmo 1 }
			Feb { set fmo 2 }
			Mar { set fmo 3 }
			Apr { set fmo 4 }
			May { set fmo 5 }
			Jun { set fmo 6 }
			Jul { set fmo 7 }
			Aug { set fmo 8 }
			Sep { set fmo 9 }
			Oct { set fmo 10}
			Nov { set fmo 11}
			Dec { set fmo 12}
		}
		if {$mo < $fmo} {
			return "Incorrect Month"
		} elseif {$fmo < $mo} {
			continue
		}
		set fd  [string range $fnam 3 4]
		if {[string match [string index $fd 0] "0"]} {
			set fd [string range $fd 1 end]
		}
		if {$d < $fd} {
			return "Incorrect Day"
		} elseif {$fd < $d} {
			continue
		}
		set fh  [string range $fnam 6 7]
		if {[string match [string index $fh 0] "0"]} {
			set fh [string range $fh 1 end]
		}
		if {$h < $fh} {
			return "Incorrect Hour"
		} elseif {$fh < $h} {
			continue
		}
		set fmi [string range $fnam 9 10]
		if {[string match [string index $fmi 0] "0"]} {
			set fmi [string range $fmi 1 end]
		}
		if {$mi <= $fmi} {
			return "Incorrect Minute"
		}
	}
	return ""
}
