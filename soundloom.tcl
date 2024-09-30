#
# SOUND LOOM RELEASE mac version 17.0.4E
# RWD: see line 490... code to read execloc.cdp at startup, instead of 
#  hard-coded path to local _cdprogs. Needed for multi-account install
#  e.g. where all executables are put in /usr/local/bin/cdp 
#
package require Tk
package require snack

#############
#	MAIN	#
#############

#RWD NB: for standalone version we must comment out call to exec below

#!/bin/sh
# the next line restarts with wish \
#exec wish "$0" "$@"

#RWD 30:Apr 2010:  look for file .sloomrc conataining path to _cdp installation folder
# additioanl option coudl include warning message if not found, and/or a tk directory selector
# to find the required folder.

proc findsloom {} {

	global env
	set homedir $env(HOME)
	set rcfnam [file join $homedir .sloomrc]
	set result ""
	if [catch {open $rcfnam "r"} rcid] {
		puts stdout [format "unable to open %s - not installed?\n" $rcfnam]
	} else {
		puts stdout [format "found %s\n" $rcfnam]
		if {[gets $rcid sldir] >= 0} {
			if {[string length $sldir] > 0} {
				puts stdout [format "sloom home dir = %s\n" $sldir]
				set result $sldir	
			} else {
				puts stdout [format "%s is empty!\n" $sldir]
			}
		} else {
   			puts stdout [format "failed to read .sloomrc - check system.\n"]
		}
		close $rcid
	}
	return $result
}

#RWD:  need this system for making path to tcl files
# I expect we can make this the same as the standalone verison for the PC.
# NB this preserves original _gui folder path and contents internally

# see also line 422:  sets final home path to _cdp folder
set home [file dirname [info script]]

set compiled_soundloom 0
source [file join $home _gui/_data.tcl]
source [file join $home _gui/_qikedit.tcl]
source [file join $home _gui/_thumbnails.tcl]
source [file join $home _gui/_mchantoolkit.tcl]
source [file join $home _gui/_eightchan.tcl]
source [file join $home _gui/_textstats.tcl]
source [file join $home _gui/_cleankit.tcl]
source [file join $home _gui/_newdisplay.tcl]
source [file join $home _gui/_suckandsee.tcl]
source [file join $home _gui/_seeres.tcl]
source [file join $home _gui/_mixmanage.tcl]
source [file join $home _gui/_updates.tcl]
source [file join $home _gui/_standalone.tcl]
source [file join $home _gui/_batch.tcl]
source [file join $home _gui/_tkgetdir.tcl]
namespace import tkgetdir::*
source [file join $home _gui/_blist.tcl]
source [file join $home _gui/_startup.tcl]
source [file join $home _gui/_history.tcl]
source [file join $home _gui/_environment.tcl]
source [file join $home _gui/_workspace.tcl]
source [file join $home _gui/_finish.tcl]
source [file join $home _gui/_graf.tcl]
source [file join $home _gui/_system.tcl]
source [file join $home _gui/_customize.tcl]
source [file join $home _gui/_instruments.tcl]
source [file join $home _gui/_general.tcl]
source [file join $home _gui/_gadgets.tcl]
source [file join $home _gui/_help.tcl]
source [file join $home _gui/_sliders.tcl]
source [file join $home _gui/_progmask.tcl]
source [file join $home _gui/_favorites.tcl]
source [file join $home _gui/_procinfo.tcl]
source [file join $home _gui/_parampage.tcl]
source [file join $home _gui/_processpage.tcl]
source [file join $home _gui/_paramtest.tcl]
source [file join $home _gui/_patches.tcl]
source [file join $home _gui/_pitchmarks.tcl]
source [file join $home _gui/_runwindow.tcl]
source [file join $home _gui/_brkpntfiles.tcl]
source [file join $home _gui/_textfiles.tcl]
source [file join $home _gui/_run.tcl]
source [file join $home _gui/_newuserhelp.tcl]
source [file join $home _gui/_bulk.tcl]
source [file join $home _gui/_srctrace.tcl]
source [file join $home _gui/_calculator.tcl]
source [file join $home _gui/_table_editor.tcl]
source [file join $home _gui/_tips.tcl]
source [file join $home _gui/_refvals.tcl]
source [file join $home _gui/_recent_names.tcl]
source [file join $home _gui/_notebook.tcl]
source [file join $home _gui/_mixrefresh.tcl]
source [file join $home _gui/_standard.tcl]
source [file join $home _gui/_staff.tcl]
source [file join $home _gui/_screensize.tcl]
source [file join $home _gui/_users.tcl]
source [file join $home _gui/_pdisplay.tcl]
source [file join $home _gui/_score.tcl]
source [file join $home _gui/_meta.tcl]
source [file join $home _gui/_props.tcl]
source [file join $home _gui/_syllables.tcl]
source [file join $home _gui/_tonal.tcl]
source [file join $home _gui/_private.tcl]

proc TestForReleaseChange {} {
	global evv
	set evv(LAST_MAX_RELEASE_PROGNO) 352
	if {$evv(LAST_MAX_RELEASE_PROGNO) != $evv(MAX_RELEASE_PROGNO)} {
		Inf "Warning To Developer!!!!!!\n\nRead The Following Instructions Carefully!!!!"
		Inf "Instruction 1\n\nIf just released recently developed programs\n\nset \$evv(LAST_MAX_RELEASE_PROGNO) in 'soundloom.tcl' equal to\n\nprevious value of\n\n\$evv(MAX_RELEASE_PROGNO)"
	}
}

#---- FIX: DECEMBER 2007 : release 10.0.5 : to put status data files into correct directories
#
#	Rationalisation of storage of user data, especially for multi-user systems,
#	ensuring that data relevant to ALL users is stored in the _cdpenv subdirectory in the TOP-users base directory,
#	while data specific to a particular user is stored in the _userenv subdirectory in the INDIVIDUAL users' base directory.
#	
#	Once completed, the rationalisation is flagged up by creating a file in the _cdpenv subdir
#	so that this rationalisation function is not called again.
#

proc RationaliseStatusData {} {
	global evv
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(RATIONALISE_MULTI)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		return
	}
	set other_dirs {}
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(USERTYPE)$evv(CDP_EXT)]
	if {[file exists $fnam] && ![catch {open $fnam "r"} zit]} {
		gets $zit line
		close $zit
		set line [string trim $line]
		if {([string length $line] > 0) && [regexp {^[0-9]+$} $line] && ($line > 1)} {
			set fnam [file join $evv(CDPRESOURCE_DIR) $evv(USERS)$evv(CDP_EXT)]
			if {[file exists $fnam] && ![catch {open $fnam "r"} zit]} {
				set cnt 0
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] > 0} {
						catch {unset nuline}	
						set line [split $line]
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] > 0} {
								lappend nuline $item
							}
						}
						if {[llength $nuline] != 3} {
							incr cnt
							continue
						}
						if {$cnt > 0} {
							lappend other_dirs [lindex $nuline 2]
						}
						incr cnt
					}					
				}
				close $zit
			}
		}
	}
	set OK 1
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(LMO)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		foreach od $other_dirs {
			set fnamnu [file join $od $evv(URES_DIR) $evv(LMO)$evv(CDP_EXT)]
			catch {file copy $fnam $fnamnu}
		}
		set fnamnu [file join $evv(URES_DIR) $evv(LMO)$evv(CDP_EXT)]
		if [catch {file copy $fnam $fnamnu} zit] {
			Inf "Cannot Move File $evv(LMO)$evv(CDP_EXT) From Dir $evv(CDPRESOURCE_DIR) To Dir $evv(URES_DIR)"
			set OK 0
		} else {
			catch {file delete $fnam}
		}
	}
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(FREE)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		foreach od $other_dirs {
			set fnamnu [file join $od $evv(URES_DIR) $evv(FREE)$evv(CDP_EXT)]
			catch {file copy $fnam $fnamnu}
		}
		set fnamnu [file join $evv(URES_DIR) $evv(FREE)$evv(CDP_EXT)]
		if [catch {file copy  $fnam $fnamnu} zit] {
			Inf "Cannot Move File $evv(FREE)$evv(CDP_EXT) From Dir $evv(CDPRESOURCE_DIR) To Dir $evv(URES_DIR)"
			set OK 0
		} else {
			catch {file delete $fnam}
		}
	}
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(ALGEBRA)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		foreach od $other_dirs {
			set fnamnu [file join $od $evv(URES_DIR) $evv(ALGEBRA)$evv(CDP_EXT)]
			catch {file copy $fnam $fnamnu}
		}
		set fnamnu [file join $evv(URES_DIR) $evv(ALGEBRA)$evv(CDP_EXT)]
		if [catch {file copy  $fnam $fnamnu} zit] {
			Inf "Cannot Move File $evv(ALGEBRA)$evv(CDP_EXT) From Dir $evv(CDPRESOURCE_DIR) To Dir $evv(URES_DIR)"
			set OK 0
		} else {
			catch {file delete $fnam}
		}
	}
	set fnam [file join $evv(URES_DIR) $evv(CDP_TESTS)$evv(CDP_EXT)]
	set fnamnu [file join $evv(CDPRESOURCE_DIR) $evv(CDP_TESTS)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {file copy $fnam $fnamnu} zit] {
			Inf "Cannot Move File $evv(CDP_TESTS)$evv(CDP_EXT) From Dir $evv(URES_DIR) To Dir $evv(CDPRESOURCE_DIR)"
			set OK 0
		} else {
			catch {file delete $fnam}
		}
	}
	if {$OK} {
		set fnam [file join $evv(CDPRESOURCE_DIR) $evv(RATIONALISE_MULTI)$evv(CDP_EXT)]
		if [catch {open $fnam "w"} zit] {
			set msg "Successfuly Moved Your System-Status Files\n\n"
			append msg "But Cannot Create File '$fnam' To Flag That This Has Been Done."
			Inf $msg
		}
		close $zit
	}
	return
}

proc GetColourAtStart {} {
	global CDPcolour evv
	global startfontlarge startfonttiny startfontsmall startfontmid startemph startbackground

	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(COLOUR)$evv(CDP_EXT)]
	set CDPcolour 0
	SetCDPres

	if {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Read Sound Loom Colour Style"
		} else {
			while {[gets $zit val] >= 0} {
				set val [string trim $val]
				if {[string length $val] <= 0} {
					continue
				}
				switch -- $val {
					0 -
					1	{
						set CDPcolour $val
						break
					}
					default {
						Inf "Unknown Data In File '$fnam' For Sound Loom Colour Style"
						break
					}
				}
			}
			close $zit
		}
	} else {
		SetLEEDScolours
		ChangeColour 1
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot Open File '$fnam' To Remember Colour Style Choice"
			set CDPcolour 0
		} else {
			puts $zit $CDPcolour
			close $zit
		}
	}
	if {$CDPcolour == 1} {
		SetLEEDSres
		font create startfontlarge -family tahoma -size 36 -weight bold
		font create startfonttiny -family tahoma -size 10 -weight bold
		font create startfontsmall -family tahoma -size 12 -weight bold
		font create startfontmid -family tahoma -size 20 -weight bold
		set startemph slategrey
		set startbackground black
	} else {
		SetCDPres
		font create startfontlarge -family times -size 36 -weight bold
		font create startfonttiny -family times -size 10 -weight bold
		font create startfontsmall -family times -size 12 -weight bold
		font create startfontmid -family times -size 20 -weight bold
		set startemph $evv(EMPH)
		set startbackground LemonChiffon3
	}
}

global bombout window_stack_index blocker user_resource_changed	from_runpage
global blocker pr_hello wstk ins file_overwrite brk ref sysname record_temacro evv
global pprg normalfnt fine_tune memory outfilename viewcnt chcnt wltxt col_ungapd_numeric
global ins_creation o_nam only_looking prg_abortd pmcnt from_dirl srmul auto_cs
global current_menu_index hst do_log_cull playcnt current_drive is_crypto colpar threshold
global pr_beta prg_ocnt is_terminating qval qtime last_colmode version_number
global bulk has_saved_at_all has_saved do_redesign in_recycle from_chosen from_mcreate
global wksp_cnt total_wksp_cnt ch_remem ch_resto
global ino ino tw_testing renam ot_has_fnams new_nnn rsto done_mixrfrsh nch_cnt files_deleted
global ins_concluding sl_real playcmd pr_play badcmd update_wait bakup_hiding
global gobo_testing sampsize_convertor orig_sampsize_convertor system_initialisation
global pr_cdp fallback_progfuncs top_user usertype tap_on twotap excluded_batchfiles
global new_cdp_extensions text_edit_style development_version allow_numeric_filenames cmdline_testing
global has_standalones grain_rrr_cut_available colorable
global startfontlarge startfonttiny startfontsmall startfontmid startbackground startemph
global multiple_file_extensions can_change_environment_variables do_reinstall 
global snack_enabled numacfnt

# NEXT RELEASE MUST INCLUDE ARPEGG FLAGS REVISION (1 less flag)
# FOF PROGRAMS
# AND GRAIN_RRR_EXTEND MODE 3 (345)
# PARTIALS_HARM (285)
# SPECROSS (286)

global next_CDP_release

set evv(DFLT_TMPFNAME)	"cdptemp"
set evv(BKGD)			"wksp_bkgd"

#SYSTEM DEVELOPMENT FLAGS
set evv(MAX_RELEASE_PROGNO) 352
set development_version 0	;# If set to 1: May crash if used ONLY with released CDP programs
if {$development_version} {
	set next_CDP_release 1			;# Set to 0 if arpegg revision ETC is not CDP released, and esp. multichannel mix!!
} else {
	set next_CDP_release 0			;# Set to 0 if arpegg revision ETC is not CDP released
}

set new_cdp_extensions 1		;# Change to 1 to allow new file extensions with next CDP release
set allow_numeric_filenames 1	;# Change to 1 to allow numeric filenames, or fnames starting with number
set colorable 0					;# Change to 1 if we figure out how to colour-code mac buttons (but need to fix code too!!)
set multiple_file_extensions 0 			;# set to 1 if we are able to implement .wav and .aiff on PC 
set can_change_environment_variables 0	;# set to 1 if we can genuinely change environment variables from Loom 
										;# (rather than just extension being placed on sfile)

#SYSTEM TESTING FLAGS
set gobo_testing 0			;# If reset to 1: (from System State menu) Causes gobo cmdline to be shown
set tw_testing 0			;# If reset to 1: (from System State menu) Runs sloom without loading or saving workspace
set cmdline_testing 0		;# If reset to 1: (from System State menu) Displays cmdlines, when Sloom runs.
set bakup_hiding 0			;# If reset to 1: (from System State menu) Runs sloom without remembering or showing bakup dirs used
set text_edit_style 0		;# If reset to 1 or 2: (from System State menu) Allows either ONLY text edit or ONLY graphic edir, of textfiles

set ins(names) {}
set tap_on 0
set twotap 0
set pr_cdp 0
set fallback_progfuncs 0

set wltxt "w_files are lists of workspace files.\n"
append wltxt "c_files are chosen-files listings.\n"
append wltxt "Rest of filename is date followed by time of saving, in hrs,mins,secs + year."

set excluded_batchfiles autoexec 
lappend excluded_batchfiles tmpdelis winstart

set system_initialisation 0
set badcmd 0
set colpar ""
set threshold ""
set record_temacro 0
set srmul 0
set auto_cs 0
set col_ungapd_numeric 0
set is_crypto 0
set files_deleted 0
set nch_cnt 0
set rsto ""
set done_mixrfrsh 0
set ino 0
set renam 0
set ot_has_fnams 0
set new_nnn 1

set version_number "17.0.4E"
set current_drive ""
set ref(cnt) 0
set sysname(1) "a1"
set sysname(2) "a2"
set sysname(3) "mix1"
set sysname(4) "mix2"
set sysname(5) "mix_current"

set ch_remem 0
set ch_resto 0
set chcnt 0
set from_dirl 0

set in_recycle 0
set from_chosen 0
set from_mcreate 0
set wksp_cnt 0
set total_wksp_marked 0
set total_wksp_cnt 0
set pr_beta 0
set last_colmode ""

set bulk(run) 0
set bulk(lastrun) 0
set has_saved 0
set has_saved_at_all 0
set qval 0
set qtime 0
set prg_ocnt 0
set is_terminating 0
set playcnt 0
set ins(was_penult_process) 0
set do_log_cull 0
set hst(maxbaktrak) 0
set current_menu_index -1
set prg_abortd 0
set window_stack_index -1
set file_overwrite 0
set fine_tune 0
set pprg 0
set bombout 0
set memory(cnt) 0
set viewcnt 0
set from_runpage 0
set ins_creation 0
set ins_concluding 0
set ins(thisprocess_finished) 0
set ins(cnt) 0
set ins(create) 0
set ins(run) 0
set only_looking 0
set ins(recall) 0
set ins(was_last_process_used) 0
set pmcnt 0
set brk(from_wkspace) 0
set do_redesign 0

font create fnt_for_tree	 	-family tahoma -size 8
font create general_fnt	 	-family tahoma -size 12
font create displ_fnt	-family tahoma -size 9
font create tiny_fnt	-family tahoma -size 7
font create flats_fnt	-family tahoma -size 16

set evv(SAMPSIZE_DEFAULT)	32767
set evv(MIN_MAXLOGS)		10
set evv(PI)					3.141592653589793238462643

#RWD 30 Apr 2010: find where users cdp installation is
#if not found, revert to default system

set sloomdir [findsloom]
if {[file exists $sloomdir]} {
	set home $sloomdir
}

set cdpdirfound  0
cd $home

while {!$cdpdirfound} {
  set thisdir [file tail [pwd]] 
#  Inf "In folder '$thisdir'"
  if {$thisdir eq ""} {
     Inf "No _cdp folder found! "
# RWD: probably have to quit in this extreme situation?
      break
  }
  if {[string match $thisdir "_cdp"]} {
  	set $cdpdirfound  1
#  	Inf "found _cdp dir"
  	break
  } else {
  	cd ..
  }
}

# GLOBAL SYSTEM DIRECTORIES

set evv(CDPRESOURCE_DIR)	"_cdpenv"	;#	Directory for CDP resources, and saved workspace
set evv(CDPGUI_DIR)			"_gui"		;#	Directory for GUI code
#set evv(CDPROGRAM_DIR) 	"_cdprogs"	;#	ORIGINAL Directory where CDP programs are located

#RWD support multiuser system, programs expected to be in /usr/local/bin/cdp
set gotxdir ""
set exloc [file join [pwd] _cdpenv/execloc.cdp]
if [catch {open $exloc "r"} rcid] {
     Inf "unable to open execloc.cdp to find program path - please check installation"
} else {
	if {[gets $rcid progdir] > 0} {
		if {[string length $progdir] > 0} {
			set gotxdir $progdir
		} else {
			Inf "execloc.cdp is empty! Please check installation\n"
		}
	}
}
#set evv(CDPROGRAM_DIR) 		"/usr/local/bin/cdp"	;
set evv(CDPROGRAM_DIR) $gotxdir         ;

# GLOBAL SYSTEM FILES

set evv(EXECDIR) 		    "execloc"	  ;#	File where location of CDP programs is located!!
set evv(USERTYPE)			"multi"		  ;#	File containing details of users
set evv(USERS)				"users"		  ;#	File containing details of users
set evv(USERS_BAKUP)		"usersb"	  ;#	File containing details of users
set evv(CDPRES)				"CDPres"   	  ;#	File for CDP environment settings
set evv(INIT)			    "init"	 	  ;#	If it exists, user has used system once: stores screensize
set evv(SYS)			    "sys" 	 	  ;#	If it exists, user has used system once: stores OS type
set evv(PLAYDIR)			"playdir"	  ;#	File in which to find play program
set evv(PLAYCMD)			"playcmd"	  ;#	File in which to find play command
set evv(TESTFILE)			"testfile"	  ;#	Test file for play command
set evv(SAMPSIZE)			"sampsize"	  ;#	Default size of sound sample
set evv(UPDATE_FILE)		"update" 	  ;#	File with latest version (just received) update info
set evv(LAST_UPDATE_FILE)	"last_update" ;#	File with current version update info
set evv(SYSTEM_CLOCK)	    "clock"  	  ;#	File with current system speed
set evv(CDP_TESTS)	    	"tests"  	  ;#	File with testflags
set evv(NEWSYS)				"fltsys"	  ;#	If exists, message re new float-point release has been displayed already
set evv(CDPVER)				"cdpver"	  ;#	Pre and Dec 2004 release versions CDP
set evv(FLOAT)				"float"		  ;#	Signals that system output is forced to floating-point
set evv(COLOUR)				"colour"	  ;#	Saves colour style: orig or leeds
set evv(NODIRS)				"nodirs"	  ;#	Prevent display of bakup dirs at session start
set evv(OTHER_DRIVE)		"other_drive" ;#	Name of network drive being used by multiuser system (if any)
set evv(CDP_TEMPDIR)		"__cdpx"	  ;#	Dirname of temporary directory when environmnet copied frm network disk to local disk
set evv(NB_DISPLAYED)		"nb"		  ;#	Flags Notebook is displayed
set evv(NTBKRETAIN)			"ntbkretain"     ;#	Flags Notebook to be retained on desktop
set evv(NETWORK_LOCAL)		"netwloc"	     ;#	File contains address of network directory and local temp directory
set evv(EDIT_STYLE)			"edit_style_set" ;#	Flag text editing style (text, graphics)
set evv(FIRSTINS)			"ins1"		     ;#	Signals that message re Instruments has been given
set evv(RATIONALISE_MULTI)	"rationalised"	 ;#	Flag rationalised distribution of state files between "_cdpev" and "_userenv"
set evv(VISTA)				"vista"			 ;# Flags PC user is running windows VISTA

#USER DIRECTORIES

set evv(PATCH_DIRECTORY) 	"_cdpatch"	;#	Directory to store (named) parameter-patches
set evv(SUBPATCH_DIRECTORY)	"_cdsubpa"	;#	Directory to store (named) parameter-subpatches
set evv(INS_DIR)			"_cdpins"	;#	Directory for Instruments info
set evv(MACRO_DIR)			"_macros"	;#	Directory for Table Editor macros
set evv(URES_DIR)			"_userenv"	;#	Directory for user's environment
set evv(LOGDIR)				"_userlog" 	;#	Directory for histories

#USER FILES

set evv(WORKSPACE)			"workspace"	  ;#	File containing backup of workspace from last run
set evv(CHOSEN)			    "chosen"      ;#	File containing backup of listing of chosen files
set evv(REF_FILE)			"refs"		  ;#	File containing reference values
set evv(NOTEBOOK)			"notebook"	  ;#	Users notes
set evv(LOGSCNT_FILE)		"logmax"	  ;#	File contains total number of logs to allow before cull
set evv(RUNMSGS)			"runmsgs"	  ;#	File containing any text from last process run window
set evv(BAKUP_DATA)			"bakupdata"	  ;#	File containing information about where files have been backed up
set evv(DUPLS)				"dupls"		  ;#	Data re file duplicates on workspace
set evv(SKETCH)				"sketch"	  ;#	Data re sketch scoreworkspace
set evv(CDP_SURF)			"wsc"		  ;#	Copyright Notice from Wavesurfer
set evv(STANDALONE)			"standalone"  ;#	Exists if prog has standalone progs, and message has been delivered
set evv(MIXMANAGE)			"mixmanage"	  ;#	Info on snds in mixfiles
set evv(AUTO_MIXMANAGE)		"automix"	  ;#	Saves flag which Sets Automatic mix management on or off
set evv(LASTMIX)			"lastmix"	  ;#	Info on last mixfile used in previous session
set evv(PITCHMARK)			"pmarks"	  ;#	File to store pitchmarks
set evv(MTFMARK)			"mmarks"	  ;#	File to store motif marks
set evv(BLIST_BACK)			"blist_back"  ;#	Stores details of last blist used
set evv(SKMIX)				"scmix"		  ;#	Stores details of mixfiles being viewed from Sketch score
set evv(PROPDIR)			"propdir"	  ;#	Stores directory of soundfiles listed in last used special properties file
set evv(PROPFILES_LIST)		"propfiles"	  ;#	Stores names of known properties files
set evv(PRIVATE)			"private"	  ;#	List of users private directories, inaccessible from CDP
set evv(ALGEBRA)			"algebra"	  ;#	Stores algebraic expressions from Table Editor
set evv(FREE)				"free"		  ;#	Saves params of free harmony workshop
set evv(LMO)				"lmo"		  ;#	Last used table editor actions
set evv(EXPROPNAME)			"__exprops"	  ;#	Generic name of files storing explanations of properties
set evv(HFPROP_FNAME)		"__hfprp"	  ;#	Generic name for HF soundfiles associated with HF property

set evv(CDP_EXT)			".cdp"   	  ;#	Extension for resources and environment files

set evv(SINGLE_USER)	1
set evv(MULTI_USER)		2
set evv(MAX_ATTEMPTS)	3

set evv(PVPLAY_DFLT_BUFSIZE) 4096
set evv(PVPLAY_MIN_BUFSIZE)	 1024
set evv(PVPLAY_MAX_BUFSIZE)	 16384
set evv(PVPLAY_VERSION_WITH_BFLAG) 1000

wm withdraw .
Establish_SmallScreen_Sizes				;#	Set default displaysize for smallscreen-display option.
DisplayUpdateInfo

lappend wstk .
incr window_stack_index
GetColourAtStart

set qqq .cdphello
if [Dlg_Create $qqq "Sound Loom" "TidyUpAfterAbort" -borderwidth 2] {
	set cf [frame $qqq.f -borderwidth 5 -width 600 -height 400]
	pack $qqq.f -fill both -expand true
	bind all <Alt-ButtonRelease-1> {raise [lindex $wstk end]}
	bind $cf <Destroy> "catch {destroy .starthelp}"
	set c [canvas $cf.c -width 600 -height 350 -bg $startbackground]
	set cf2 [frame $cf.c2 -borderwidth 5]
	pack $cf.c $cf.c2 -side top -fill x
	set t [$c create text 0 0 -text "SOUND LOOM" -fill white -font startfontlarge]
	$c move $t 300 125
	set t [$c create text 0 0 -text "A composer interface to the CDP environment" -fill white -font startfontsmall]
	$c move $t 300 175
	set t [$c create text 0 0 -text "version $version_number" -fill white -font startfontsmall]
	$c move $t 300 225
	set t [$c create text 0 0 -text "Trevor Wishart" -fill white -font startfontmid]
	$c move $t 300 300
	set t [$c create text 0 0 -text "with thanks to Folkmar Hein,the DAAD Berlin, and the AHRB UK" -fill white -font startfonttiny]
	$c move $t 300 340
}

set pr_hello 0
raise $qqq
set x 0
after 2000 {set x 1}
vwait x

My_Grab 0 $qqq pr_hello $qqq
set user_resource_changed 0

label $cf2.t -text "" -width 50
pack $cf2.t -side left

RationaliseStatusData

if [file exists [file join $evv(CDPRESOURCE_DIR) numacfnt$evv(CDP_EXT)]] {
	set numacfnt 1
} else {
	set numacfnt 0
}
SetSystem
if {![info exists evv(SYSTEM)]} {
	exit
}

set evv(24BITNAMEFLAG) "_x"
set evv(SFSYSEX) 0

if {![SetSystemDependentVariables]} {
	exit
}
if {![CheckUserDirectories]} {
	exit
}

InitialCDPsetup
ChangeSampsize 1

CheckSys
if {$sl_real} {
	if {![EstablishPlayLocation 1]} {
		exit
	}
} else {
	if {[ProgMissing [file join $evv(CDPROGRAM_DIR) cdparsyn] "Cannot set up the SoundLoom, even for Demonstration."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) columns] "Cannot set up the SoundLoom, even for Demonstration."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) getcol] "Cannot set up the SoundLoom, even for Demonstration."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) gobo] "Cannot set up the SoundLoom, even for Demonstration."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) putcol] "Cannot set up the SoundLoom, even for Demonstration."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) sndinfo] "Cannot set up the SoundLoom, even for Demonstration."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) synth] "Cannot set up the SoundLoom, even for Demonstration."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) tkusage] "Cannot set up the SoundLoom, even for Demonstration."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) vectors] "Cannot set up the SoundLoom, even for Demonstration."]} {
		TidyUp
		exit
	}
}
if {![EstablishScreenSize 1]} {
	if [catch {file delete -force [file join $evv(CDPRESOURCE_DIR) $evv(INIT)]} zat] {
		Inf "Cannot delete $evv(INIT) file in directory $evv(CDPRESOURCE_DIR)\n\nPlease delete by hand before starting the system again."
	}
	exit
} elseif {$sl_real} {
	set system_initialisation 0
}

set top_user 1
set usertype $evv(SINGLE_USER)

$cf2.t config -text "Establishing CDP Environment"

#TEMPORARILY, UNTIL DLL PROBLEM FIXED

set fallback_progfuncs 1

CheckNewReleases
SetupCDPenvironment
if {!$sl_real} {
	Demo_Only
}

set normalfnt [option get . font {}]

set snack_enabled 0
GetSnackState 1
SetupProgramMenus

TestForReleaseChange

set evv(MAX_RELEASE_PROGNO) $evv(MAX_PROCESS_NO)

Preset_Menu_Format
if {$sl_real} {
	DelStordFlistings 1
	if {[ProgMissing [file join $evv(CDPROGRAM_DIR) cdparams] "Cannot set up the SoundLoom."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) cdparse] "Cannot set up the SoundLoom."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) gobo] "Cannot set up the SoundLoom."] \
	||  [ProgMissing [file join $evv(CDPROGRAM_DIR) progmach] "Cannot set up the SoundLoom."]} {
		TidyUp
		exit
	}
}
if [CheckExecs] {
	if [LoadInsNames] {
		LoadInsInfo
	}
	if {$sl_real} {
		EstablishLog $cf2
	} else {
		set hst(active) 0
		set hst(cnt) 0
	}
	$cf2.t config -text "Creating and Loading Workspace" -bg $startemph

	DeleteAllTemporaryFiles
	if {$sl_real} {
		GetLastRunValsFromFile
		LoadRefs
	}
	MACdisclaimer
	SaveStandalone
	Create_Workspace $cf2

	TidyUp
	if [info exists .starthelp] {
		destroy .starthelp
	}
	catch {My_Release_to_Dialog $qqq}
	catch {destroy $qqq}
}
if {[info exists do_reinstall]} {
	DoTheReinstall
}
exit

