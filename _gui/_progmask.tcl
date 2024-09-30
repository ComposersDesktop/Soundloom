#
# SOUND LOOM RELEASE mac version 17.0.4
#

#############################################
# WHICH PROCESSES ARE APPROPRIATE TO FILES	#
#############################################

#------ THE TK-TCL command to call the C-programs which evaluates file prop 
#
#	PROGMACH.C Reads and compares properties of infiles, saving output in 5 flags
#
#	Initial defaults of this flag are:-
#
#	0)	0		Count of input files
#	1)	-1 		Filetype of 1st infile
#	2)	-1 		Filetype of last infile
#	3)	-1 		Shared filetype (if any)
#	4)	30 		Bitflag re file compatibility (16+8+4+2)
#					16 	= all infiles of same type
#					8	= all infiles of same srate
#					4	= all infiles of same channel count
#					2	= all infiles have all other properties compatible
#					1	= At least 1 of infiles is a binary sndsystem file
#
#	GOBO.C	Uses these flags to assess which programs will run with the given file-list
#

proc GetProgsmask {} {
	global chlist pa ins the_gobo gobo_got CDPid CDPidd cumulist_got cumulist evv
	global pmask procmenu chosen_menu show_the_gobo 

	set gobo_got 0

	set last_pmask 0
	if [info exists pmask] {
		set last_pmask [string range $pmask 1 end]
	}

	if {$ins(create)} {
		if [info exists ins(chlist)] {
			set thischosenlist "$ins(chlist)"
		}
	} else {
		if [info exists chlist] {
			set thischosenlist "$chlist"
		}
	}
	if {[info exist chlist] && ([llength $chlist] == 1) && ($pa([lindex $chlist 0],$evv(FTYP)) == $evv(MIX_MULTI))} {
		set the_gobo [GetPmaskForMultichanMixfile]
	} else {
		Block "Checking file validity"
		set cumulist [list 0 -1 -1 -1 30 0 0 0 0 0 0 0 0 0 0 0]		;# 5 flags, and 12 spaces for props of 1st input file	
		set i 0
		if [info exists thischosenlist] {
			foreach fnam $thischosenlist {
				catch {unset inslist}
				lappend inslist $pa($fnam,$evv(FTYP))				;# 0th item from props list 
				lappend inslist $pa($fnam,$evv(SRATE))				;# 3 
				lappend inslist $pa($fnam,$evv(CHANS))				;# 4 
				lappend inslist $pa($fnam,$evv(ARATE))				;# 8 
				lappend inslist $pa($fnam,$evv(STYPE))				;# 12 
				lappend inslist $pa($fnam,$evv(ORIGSTYPE))			;# 13 
				lappend inslist $pa($fnam,$evv(ORIGRATE))			;# 14 
				lappend inslist $pa($fnam,$evv(MLEN))				;# 15 
				lappend inslist $pa($fnam,$evv(DFAC))				;# 16 
				lappend inslist $pa($fnam,$evv(ORIGCHANS))			;# 17 
				lappend inslist $pa($fnam,$evv(SPECENVCNT))			;# 18 
				lappend inslist $pa($fnam,$evv(DESCRIPTOR_BYTES))	;# 20 
				set cmd [file join $evv(CDPROGRAM_DIR) progmach]
				set cmd [concat $cmd $cumulist $inslist]	;#	PROGMACH counts & compares props of input files
				set cumulist_got 0
				if [catch {open "|$cmd"} CDPid] {
					ErrShow "program 'progmach' failed to run\n$CDPid"
					catch {unset CDPid}
					UnBlock
					return 0
				} else {
		  			fileevent $CDPid readable AccumulateProgsmask
					fconfigure $CDPid -buffering line
				}
				vwait cumulist_got
				incr i
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) gobo] ;#	GOBO tests validity of file data against all prog specs
		lappend cmd $i $ins(create)				 ;#	Discounts programs not useable in ins mode
		if {$evv(DFLT_SR) > 0} {				 ;#	Discounts programs that alter srate
			lappend cmd 1
		} else {
			lappend cmd 0
		}

		if {$i > 0} {								;#	If at least 1 input file
			set chancnt [lindex $cumulist 6]
			set cumulist [concat [lrange $cumulist 1 2]	[lindex $cumulist 4]]
													;# Keep just the testing data that gobo needs: 3 items.
			lappend cumulist $chancnt				;# Append the channel count.
			set cmd [concat $cmd $cumulist]
		}
		See_Gobo_Cmd $cmd
		if [catch {open "|$cmd"} CDPidd] {
			ErrShow "Failed to run GetProgsmask"
			catch {unset CDPidd}
			UnBlock
			return 0
		} else {										
   			fileevent $CDPidd readable ReadGobo
			fconfigure $CDPidd -buffering line
		}												
		vwait gobo_got
		UnBlock
	#AUGUST 2000			
		if {![string match $the_gobo $last_pmask]} {	;#	If valid-processes-setting changes:
			catch {destroy $procmenu}					;#	 destroy any chosen-menu from previous use of process page
			catch {destroy $chosen_menu}
		}
		if {$show_the_gobo} {
			set glen [string length $the_gobo]
			set glen_less_one [expr $glen - 1]
			set k 0
			set j 31
			set msg "gobo\n\n[string range $the_gobo $k $j]"
			incr k 32
			incr j 32
			while {$k < $glen} {
				if {$j >= $glen} {
					set j $glen_less_one
				}
				append msg "\n[string range $the_gobo $k $j]"
				incr k 32
				incr j 32
			}
			Inf $msg
		}
		set the_gobo [DoCryptoProgs $the_gobo]
	}
	return $the_gobo
}

#------ Deal with output of PROGMACH program

proc AccumulateProgsmask {} {
	global CDPid cumulist_got cumulist evv
	if [eof $CDPid] {						
		set cumulist_got 0
		catch {close $CDPid}
		return
	} else {
		gets $CDPid str
		set str [string trim $str]
		if {[llength $str] <= 0} {
			set zago 0
		} elseif [string match ERROR:* $str] {
			set zago 0
			ErrShow $str
		} elseif [string match WARNING:* $str] {
			set zago 0
			Inf $str
		} elseif [string match INFO:* $str] {
			set str [string range $str 6 end]
			set zago 0
			Inf $str
		} else {
			set cumulist $str
			set zago 1
		}
		set cumulist_got $zago
		catch {close $CDPid}				 
	}
}

#------ Deal with output of GOBO program

proc ReadGobo {} {
	global CDPidd the_gobo gobo_got
	if [eof $CDPidd] {
		catch {close $CDPidd}				 
		return
	} else {
		gets $CDPidd line
		set str [string trim $line]
		if [string match ERROR:* $line] {
			set err [string range $line [string first "ERROR:" $line] end] 
			ErrShow $err
			set gobo_got 1
			catch {close $CDPidd}				 
			return
		} elseif [string match WARNING:* $line] {
			set err [string range $line [string first "WARNING:" $line] end] 
			Inf $err
		# FOR TESTING ONLY
		} elseif [string match INFO:* $line] {
			set indx [string wordend $line 0]
			incr indx 2
			set err [string range $line $indx end] 
			Inf $err
		} elseif {[string length $line] > 0} {
			set the_gobo $line
			set gobo_got 1
		}
	}
}

proc SetCryptoProgs {} {
	global cryptoprogs evv
	set cryptoprogs [list $evv(ENV_CONTOUR) $evv(MOD_LOUDNESS)]
	;# append more pairs to list, where 1st of pair is a psuedo-prog
	;# defined in _environment and assigned to relavant menus (see 95 as example)
}

proc DoCryptoProgs {mask} {
	global cryptoprogs
	set woof 0
	set mask [append woof $mask]	;#	Program count starts at 1, pmask starts at 0. SORRY!!
	foreach {j k} $cryptoprogs {
		if {[string match [string index $mask $k] "1"]} {
			incr  j -1
			set numask [string range $mask 0 $j]
			incr j 2
			append numask 1 [string range $mask $j end]
			set mask $numask
		}
	}
	return [string range $mask 1 end]
}

proc GetPmaskForMultichanMixfile {} {
	set p_mask 	 "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000001"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	append p_mask "00000000000000000000000000000000"
	return $p_mask
}
