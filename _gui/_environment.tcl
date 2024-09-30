#
# SOUND LOOM RELEASE mac version 17.0.4
#

# RWD: changed for OS X	 Feb 04;
# Line 1301	  , comment out call to Block
# TW: Mar 2011 Refs to paplay removed
# RWD TEST VERSION for multi-user operation - expect progs in /usr/local/bin/cdp via execloc.cdp
# see line 3936 etc, 5050

#RWD 28 June 2013
# ... fixup button rectangles



#############################
# SETUP WORKING ENVIRONMENT	#
#############################

proc InitialCDPsetup {} {
	global evv CDPcolour
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(CDPRES)$evv(CDP_EXT)]
	if {![info exists CDPcolour]} {
		option readfile $fnam				;#	Setup the standard resources
	}
	SetCDPenv 								;#	Setup the standard environment
}

#------ Setup the environment for the whole application

proc SetupCDPenvironment {} {
	global current_logcnt default_extension tostick evv

	GetShowStick
	if {[info exists tostick]} {
		CopyFromStick
	}
	set current_logcnt 0
	SetMaxLogCnt
	RememberCDPDefaults					;#	Save both, in case user wants to revert to them.
	Release6CheckLogNames
	set fnam [file join $evv(URES_DIR) $evv(USERRES)$evv(CDP_EXT)]
	if [file exists $fnam] {			;#	If user has own variation of resources
		option readfile $fnam			;#	Override standard resources with user-defined resources
	}
	set fnam [file join $evv(URES_DIR) $evv(USERENV)$evv(CDP_EXT)]
	if [file exists $fnam] {		;#	If user has own variation of environment
		if [catch {open $fnam r} fileUserEnvId] {
			Inf "Cannot open the User environment file: using default settings."
		} else {
			ReadUserEnvironment $fileUserEnvId		;#	Override user-accessible environment variables
			close $fileUserEnvId					;#	with user-defined environment variables
			if {$evv(SNDFILE_EXT) != ".wav"} {
				Release6CheckForWav
			}
		}									
	}

	RememberUserEnvironment					;#	Save the current environment & resources (may be the standard one)
											;#	We can hence check if the user's environment changes, 
											;#	and create or update User env & res files, on exit.
	set default_extension $evv(SNDFILE_EXT)
	SetupNewUserHelp
	set evv(HELP_DEFAULT) ""

	if {$evv(NEWUSER_HELP)} {
		GetNewUserHelp start
	}

	if {$evv(REDESIGN)} {
		Block "Establishing Interface Specification Dialog"
		Customize_Appearance_Dialog
		UnBlock
	}
	set fnam [file join $evv(URES_DIR) $evv(FAVORITES)$evv(CDP_EXT)]
	if [file exists $fnam] {			;#	If user has own favorite processes
		if [catch {open $fnam r} fileId] {
			Inf "Cannot open the Favourite processes file."
		} else {
			ReadFavorites $fileId			;#	Override user-accessible environment variables
			close $fileId					;#	with user-defined environment variables
		}									
	}
	set fnam [file join $evv(URES_DIR) $evv(NUNAMES)$evv(CDP_EXT)]
	if [file exists $fnam] {			;#	If user has recent names
		if [catch {open $fnam r} fileId] {
			Inf "Cannot open the Recent Names file."
		} else {
			ReadRecentNames $fileId			;#	Override user-accessible environment variables
			close $fileId					;#	with user-defined environment variables
		}									
	}
	SetTreeBoxDimensions
	SetPnamesForTree
	SetBrkTextConstants						;#	Pixel size of width of essential x-axis texts on brktable display
											;#	and their positions
	GetSavedSamplesize
}

#------ Establish the CDP default-environment variables
#
#	NB Many of These MUST TALLY WITH CDP-include-DATA IN filetype.h!!
#

proc SetCDPenv {} {
	global evv mu treefnt treedeletefnt treekeyfnt sl_real multiple_file_extensions compiled_soundloom month_end
	set OK 0

	set fnam [file join $evv(URES_DIR) $evv(WORKSPACE)$evv(CDP_EXT)]
	set evv(WORKSPACE_FILE)	$fnam
	set fnam [file join $evv(URES_DIR) $evv(CHOSEN)$evv(CDP_EXT)]
	set evv(CHOSEN_FILE) $fnam

	set evv(COMMENT)	";"					;#	Comment character in mixfiles

	set evv(TCL_EXT)	".tcl"

#	Allow user to redesign the interface

	set evv(REDESIGN)	0
	set evv(DFLT_SR) 	0

	set evv(BBDR)		4
	set evv(SBDR)	2

	set evv(MAX_LISTBOX_HEIGHT) 32

	set evv(SCALELEN)		256
	set evv(SLIDERSIZE) 	15
	set evv(RANGEWIDTH) 	6

# Process-menu display-size

	set evv(DISPLAYPAGE_FONTSIZE) 9			;#	Font for display-alteration page display!!
	set evv(MAX_FONTSIZE)		  16
	set evv(MIN_FONTSIZE)		  8
	if {$evv(SYSTEM) == "MAC"} {
		set evv(T_FONT_STYLE) 	  times		;#	Font for tree display
		set evv(T_FONT_SIZE) 	  10
		set evv(T_FONT_TYPE) 	  roman
	} else {
		set evv(T_FONT_STYLE) 	  times		;#	Font for tree display
		set evv(T_FONT_SIZE) 	  8
		set evv(T_FONT_TYPE) 	  roman
	}
	set evv(MAX_TREE_FONT_SIZE)   11
	set evv(MIN_TREE_FONT_SIZE)   8
	set evv(T_DELETE_TYPE) 	  italic 	;#	Font for tree display of deleted file

	font create treefnt -family $evv(T_FONT_STYLE) -size $evv(T_FONT_SIZE) -slant $evv(T_FONT_TYPE)
	font create treedeletefnt -family $evv(T_FONT_STYLE) -size $evv(T_FONT_SIZE) -slant $evv(T_DELETE_TYPE)
	font create treekeyfnt -family $evv(T_FONT_STYLE) -size $evv(T_FONT_SIZE) -weight bold
	font create microfnt -family $evv(T_FONT_STYLE) -size 7 -slant $evv(T_FONT_TYPE)

# Filetypes

	set evv(BRKFILE)		  8192
	set evv(DB_BRKFILE)		  4096
	set evv(UNRANGED_BRKFILE) 2048
	set evv(LINELIST)		  512
	set evv(NUMLIST)		  256
	set evv(SNDLIST)		  128
	set evv(SYNCLIST)		  64
	set evv(MIXFILE)		  32
	set evv(SNDFILE)		  1
	set evv(PSEUDO_SND)	  	  65536			;#	Not in the stadard set of values
	set evv(ANALFILE)		  24
	set evv(PITCHFILE)		  25
	set evv(TRANSPOSFILE)	  26
	set evv(FORMANTFILE)	  27
	set evv(ENVFILE)		  16
	set evv(TEXTFILE)		  96
	set evv(IS_A_BRKFILE)	  64512
	set evv(MIX_MULTI)		  57344			;#	1110000000000000
	set evv(IS_PITCH_OR_TRANS) 49920		;#  1100001100000000

 #	Filetype interrogators

	set evv(IS_A_PITCH_BRKFILE)		16384
	set evv(IS_A_TRANSPOS_BRKFILE)	32768
	set evv(IS_A_NORMD_BRKFILE)		 8192
	set evv(IS_A_DB_BRKFILE)		 4096
	set evv(IS_AN_UNRANGED_BRKFILE)	 3072
	set evv(IS_A_NUMLIST)			  256
	set evv(IS_A_SNDLIST)			  128
	set evv(IS_A_SYNCLIST)			   64
	set evv(IS_A_MIXFILE)		       32
	set evv(IS_A_LINELIST)			  512
	set evv(IS_A_SNDFILE)				1
	set evv(IS_AN_ANALFILE)			   24
	set evv(IS_A_PITCHFILE)			   25
	set evv(IS_A_TRANSPOSFILE)		   26
	set evv(IS_A_FORMANTFILE)		   27
	set evv(IS_AN_ENVFILE)			   16
	set evv(IS_A_SNDSYSTEM_FILE)	   31
	set evv(IS_A_TEXTFILE)			65504
	set evv(IS_ANALDERIVED)			    8
	set evv(IS_A_SNDLIST_FIXEDSR)	  192
	set evv(IS_A_NUMBER_LINELIST)	  768
	set evv(IS_MIX_OR_SNDLST_FIXSR)	  224
#AUG 2011
#	set evv(IS_A_BRKFILE)			63488
#AUG 2011
	set evv(IS_A_BRKFILE)			64512
	set evv(IS_A_P_OR_T_BRK)		39152
	set evv(POSITIVE_BRKFILE)		 1024
#
#	set evv(IS_AN_ENV_OR_DB_BRK)	12288
#
	set evv(POSSIBLY_FILENAMES)		  928
	set evv(IS_ANYFILE)				65535
	set evv(IS_NOT_PURE_NUMS_TEXT)	65248
	set evv(IS_NOT_PURENUMS_OR_MIX_TEXT)	65216
	set evv(IS_NOT_MIX_TEXT)		65472
 	set evv(WORDLIST)				288
	set evv(TR_OR_PB_OR_N_OR_W)	 	49408
	set evv(TR_OR_UB_OR_N_OR_W) 	35072
	set evv(NBK_OR_N_OR_WL)			8448

# File properties in pa

	set evv(SAMP_SHORT)			0
	set evv(SAMP_FLOAT)			1

	set evv(FTYP)				0
	set evv(FSIZ)				1
	set evv(INSAMS)			 	2
	set evv(SRATE)			 	3
	set evv(CHANS)				4
	set evv(WANTED)			 	5
	set evv(WLENGTH)			6
	set evv(LINECNT)			7
	set evv(ARATE)			 	8
	set evv(FRAMETIME)		 	9
	set evv(NYQUIST)			10
	set evv(DUR)				11
	set evv(STYPE)			 	12
	set evv(ORIGSTYPE)		 	13
	set evv(ORIGRATE)			14
	set evv(MLEN)				15
	set evv(DFAC)				16
	set evv(ORIGCHANS)		 	17
	set evv(SPECENVCNT)		 	18
	set evv(OUT_CHANS)		 	19
	set evv(DESCRIPTOR_BYTES)	20
	set evv(IS_TRANSPOS)		21
	set evv(COULD_BE_TRANSPOS)	22
	set evv(COULD_BE_PITCH)	 	23
	set evv(DIFFERENT_SRATES)	24
	set evv(DUPLICATE_SNDS)	 	25
	set evv(BRKSIZE)			26
	set evv(NUMSIZE)			27
	set evv(ALL_WORDS)		 	28
	set evv(WINDOW_SIZE)		29
	set evv(MINBRK)			 	30
	set evv(MAXBRK)			 	31
	set evv(MINNUM)			 	32
	set evv(MAXNUM)			 	33

	set evv(CDP_PROPS_CNT) 	 	 	 34		
	set evv(CDP_MAXSAMP_CNT) 	 	 3		
	set evv(CDP_FIRSTPASS_ITEMS) 	 12
	set evv(CDP_FIRSTPASS_ENDINDEX)	 11

	set evv(MAXSAMP)			34			;#	additional properties to add later
	set evv(MAXLOC)				35			;#	additional properties to add later
	set evv(MAXREP)				36			;#	additional properties to add later

	set evv(DEFAULT_DUR)		1000
	set evv(DEFAULT_LINECNT)	100
	set evv(THIS_DFAC) 			12
	set evv(THIS_ORIGCHANS)		13

# Positions of params on main cmdline

	set evv(CMD_PROCESSNO) 		  	 1		;#	position of process-no on cmdline
	set evv(CMD_MODENO) 		  	 2		;#	position of mode-no on cmdline
	set evv(CMD_INFILECNT) 		  	 3		;#	position of infilecnt on cmdline
	set evv(CMD_PROPS_OFFSET)	  	 4		;#	(progname,process,mode,infilecnt)
	set evv(CMD_INFILES) 		    38		;#	startposition of infiles on cmdline 
											;#	evv(CMD_PROPS_OFFSET) + evv(CDP_PROPS_CNT)
# temporary filenames for internal processes

	set evv(FLOAT_OUT)		"-f"
	set evv(DFLT_OUTNAME)	"cdptest"
	set evv(DFLT_NTBK)		"nbk.cdp"
	set evv(DFLT_RNAM)		"rna.cdp"
	set evv(DFLT_REFS)		"drf.cdp"
	set evv(WORDEQUIV)		"equiv.cdp"

# extension for CDP outfiles

	if {$multiple_file_extensions} {
		set evv(SNDFILE_EXTS)		{".wav" ".aif" ".aiff"}
	} else {
		set evv(SNDFILE_EXTS)		{".wav"}
	}
	set evv(SNDFILE_EXT)		".wav"		
	set evv(ANALFILE_EXT)		".ana"
;# 2023/2
	set evv(ANALFILE_OUT_EXT)	".ana"
	set evv(PITCHFILE_EXT)		".frq"
	set evv(TRANSPOSFILE_EXT)	".trn"
	set evv(FORMANTFILE_EXT)	".for"
	set evv(ENVFILE_EXT)		".evl"
	set evv(TEXT_EXT)			".txt"
	set evv(SPEC_EXT)			".spe"
	set evv(SPEK_EXT)			".spk"
	set evv(SPKK_EXT)			".skk"
	if {$evv(SYSTEM) == "PC"} {
		set evv(MIDI_EXT)			".rmi"	;#	PC .rmi format files
	} else {
		set evv(MIDI_EXT)			".mid"	;#	Standard MIDI data file (binary)
	}

# extension used for ins-tree coding only (not a filename extension)

 	set evv(MONO_EXT)			".mon"	;#	Mono file-input to ins
 	set evv(PSEUDO_EXT)			".psu"	;#	Pseudo file-input to ins
												
# Reserved filename extensions for Instrumentdata	;#	All forbidden extensions begin with '#',
												;#	so certain programs can avoid these
	set evv(INS_LIST)	     "instrs.cdp"	;#	file of names of existing Instruments
	set evv(INS_GADGETS)		".mg"	;#	gadget specs for ins variables
	set evv(INS_BATCH)			".mb"	;#	ins batchfile
	set evv(INS_FILEPROPS)		".mf"	;#	required properties of inputfiles for ins
	set evv(INS_TREE)			".mt"	;#	tree display data for ins
	set evv(INS_FNAMES)			".mn"	;#	filenames for tree
	set evv(INS_PNAMES)			".mp"	;#	processnames for tree
	set evv(INS_DEFAULTS)		".md"	;#	default vals for ins params
	set evv(INS_SUBDEFAULTS)	".ms"	;#	default vals for ins params
	set evv(INS_TIMETYPE)		".my"	;#	information re time-typed params
	set evv(MACH_OUTFNAME)		"_out"	;#	generic name of ins outfiles
	set evv(GUI_NAME)			"soundloom"	;#	name of the GUI program!!
	if {$compiled_soundloom} {
		set evv(SOUNDLOOM)	$evv(GUI_NAME)$evv(EXEC)
	} else {
		set evv(SOUNDLOOM)	$evv(GUI_NAME)$evv(TCL_EXT)
	}


# Process-menu colors (etc)

	set evv(ON_COLOR)		LemonChiffon1
	set evv(OFF_COLOR)	   	LemonChiffon3
	set evv(HELP) 	 		LightBlue2
	set evv(SNCOLOR)		DarkSeaGreen3
	set evv(SNCOLOROFF)		pink3
	set evv(EMPH) 	 		LemonChiffon2
	set evv(SPECIAL) 	 	blue
	set evv(QUIT_COLOR) 	PaleVioletRed2
	set evv(UNAVAILABLE) 	Grey
	set evv(MENU_COLCNT)  	4

# Gadget colors

	set evv(DISABLE_COLOR) 	 	grey

#	Instrument process returns

	set evv(INS_CONTINUES)	1
	set evv(INS_COMPLETED)	0
	set evv(INS_ABORTED)	-1

# Gadget-type specifiers

	set evv(CHECKBUTTON)	 	0
	set evv(SWITCHED)			1
	set evv(LINEAR)				2
	set evv(LOG)				3
	set evv(PLOG)				4
	set evv(FILE_OR_VAL)		5
	set evv(FILENAME)			6
	set evv(NUMERIC)			7
	set evv(GENERICNAME)		8
	set evv(STRING_A)			10
	set evv(STRING_B)			11
	set evv(STRING_C)			12
	set evv(STRING_D)			13
	set evv(TIMETYPE)			14
	set evv(SRATE_GADGET)		15
	set evv(TWOFAC)				16
	set evv(WAVETYPE)			17
	set evv(POWTWO)				18
	set evv(MIDI_GADGET)		19
	set evv(OCT_GADGET)			20
	set evv(CHORD_GADGET)		21
	set evv(DENSE_GADGET)		22
	set evv(VOWELS)				23
	set evv(LOGNUMERIC)			24
	set evv(OPTIONAL_FILE)		25
	set evv(STRING_E)			26

	set evv(ONE_OVER_LN2)		1.442695
	set evv(ROOT2)				1.41421356237

# columns in gadget-grid

	set evv(LORANGE)			0
	set evv(RANGE_SWITCH) 		1
	set evv(HIRANGE)			2  	
	set evv(VAL_ENTRY)			3
	set evv(PARAM_SPACE)		4
	set evv(SLIDER_BAR)			5
	set evv(PITCH_DSPLY) 		6	
	set evv(PITCH_FIX) 			7	
	set evv(PARAM_SPACE2)		8
	set evv(GET_FILE)			9
	set evv(MAKE_FILE)			10
	set evv(SWITCHED_SWITCHA)	9	;#	same numbers, alternatives
	set evv(SWITCHED_SWITCHB)	10
	set evv(INS_VARIABLE) 	11

# constants used in gadgets
							 
	set evv(MINRANGE_SET)		  1
	set evv(MAXRANGE_SET)		  0
	set evv(LOGLOWCFRQ)		  	  2.10120181	;#	logE of C at MIDI 0 (8.175799 Hz)
	set evv(12OVERLOG2)		  	  17.31234049	;#	12/logE-of-2
	set evv(SEMITONES_PER_OCTAVE) 12

#tree-display parameters

	set evv(CANVAS_DISPLAYED_WIDTH)	 400	;#	Display area of canvas for tree
	set evv(CANVAS_DISPLAYED_HEIGHT) 550

	set evv(NEUTRAL_TC)		LemonChiffon3
	set evv(SOUND_TC)		"deep sky blue"
	set evv(PSEUDO_TC)		grey
	set evv(ANALYSIS_TC)	red
	set evv(PITCH_TC)		yellow
	set evv(TRANSPOS_TC)	orange
	set evv(FORMANT_TC)		pink
	set evv(ENVELOPE_TC)	green
	set evv(TEXT_TC)		white
	set evv(MONO_TC)		turquoise2

	set evv(T_ACTIVEBKGD)		blue
	set evv(T_ACTIVEFGND)		pink

	set evv(T_NAME_WIDTH)		15		;#	characters
	set evv(T_NAME_END)			12
	set evv(T_CELLWIDTH)		   100		;#	pixels
	set evv(T_HALF_CELLWIDTH)    50		;#	pixels : Must be exactly half of evv(T_CELLWIDTH)
	set evv(T_QUARTER_CELLWIDTH) 25		;#	pixels : Must be exactly half of evv(T_HALF_CELLWIDTH)
	set evv(T_CELLHEIGHT)		60
	set evv(T_DISPLAY_XOFFSET)	60
	set evv(T_DISPLAY_YOFFSET)	20
	set evv(TREELINE_WIDTH)			 1		;#	pixels:  Width of connecting lines on tree
	set evv(T_ARROW_OFFSET)		15		;#	Arrowhead offset from goal-text
											;#	so not obscured by goal-text

#	Process identification

#	ALL MUST TALLY WITH CDP include FILE processno.h modeno.h

	set evv(GAIN)				1
	set	evv(LIMIT)				2
	set evv(BARE)				3
	set evv(CLEAN)				4
	set evv(CUT)				5  	
	set evv(GRAB)				6
	set evv(MAGNIFY)			7
	set evv(STRETCH)			8
	set	evv(TSTRETCH)			9
	set evv(ALT)				10
	set evv(OCT)				11 	
	set evv(SHIFTP)				12
	set evv(TUNE)				13
	set evv(PICK)				14
	set	evv(MULTRANS)			15
	set evv(CHORD)				16
	set evv(FILT)				17
	set evv(GREQ)				18
	set evv(SPLIT)				19
	set evv(ARPE)				20
	set evv(PLUCK)				21
	set evv(S_TRACE)			22
	set evv(BLTR)				23
	set evv(ACCU)				24
	set evv(EXAG)				25
	set evv(FOCUS)				26
	set evv(FOLD)				27
	set evv(FREEZE)				28
	set evv(STEP)				29
	set evv(AVRG)				30
	set evv(BLUR)				31
	set evv(SUPR)				32
	set evv(CHORUS)				33
	set evv(DRUNK)				34 	
	set evv(SHUFFLE)			35
	set evv(WEAVE)				36
	set evv(NOISE)				37
	set evv(SCAT)				38 	
	set evv(SPREAD)				39
	set evv(SHIFT)				40
	set evv(GLIS)				41
	set evv(WAVER)				42
	set	evv(WARP)				43
	set evv(INVERT)				44 	
	set evv(GLIDE)				45
	set evv(BRIDGE)				46
	set evv(MORPH)				47
	set evv(PITCH)				48
	set evv(TRACK)				49
	set evv(P_APPROX)			50
	set evv(P_EXAG)				51				
	set evv(P_INVERT)			52
	set evv(P_QUANTISE)			53
	set evv(P_RANDOMISE)		54
	set evv(P_SMOOTH)			55
	set evv(P_TRANSPOSE)		56
	set evv(P_VIBRATO)			57
	set evv(P_CUT)				58
	set evv(P_FIX)				59
	set evv(REPITCH)			60
	set evv(REPITCHB)			61
	set evv(TRNSP)				62
	set evv(TRNSF)				63
	set evv(FORMANTS)			64
	set evv(FORM)				65
	set evv(VOCODE)				66
	set evv(FMNTSEE)			67 	
	set evv(FORMSEE)			68
	set evv(MAKE)				69
	set evv(SUM)				70
	set evv(DIFF)				71
	set evv(LEAF)				72
	set evv(MAX)				73
	set evv(MEAN)				74
	set evv(CROSS)				75
	set	evv(WINDOWCNT)			76
	set	evv(CHANNEL)			77
	set	evv(FREQUENCY)			78
	set	evv(LEVEL)				79
	set	evv(OCTVU)				80
	set	evv(PEAK)				81
	set evv(REPORT)				82
	set	evv(PRINT)				83
	set evv(P_INFO)				84
	set evv(P_ZEROS)			85
	set evv(P_SEE)				86
	set evv(P_HEAR)				87
	set evv(P_WRITE)			88
	set evv(SPECTOVF2)			89	;#	 !!!!!!!! not YET PUT ON SYSTEM!!!
	set evv(MTON)				90	
	set evv(FLUTTER)			91
	set evv(SETHARES)			92
	set evv(MCHSHRED)			93
	set evv(MCHZIG)				94

	set	evv(MCHSTEREO)			95
	set evv(FOOT_OF_GROUCHO_PROCESSES) $evv(MCHSTEREO)
	set	evv(MANY_ZCUTS)			96
	set	evv(MULTI_SYN)			97
	set	evv(MIXBALANCE)			98
	set	evv(INFO_MAXSAMP2)		99
	set	evv(DISTORT_CYCLECNT)	100 
	set	evv(DISTORT)			101	 
	set	evv(DISTORT_ENV)		102	 
	set	evv(DISTORT_AVG)		103	 
	set	evv(DISTORT_OMT)		104	 
	set	evv(DISTORT_MLT)		105	 
	set	evv(DISTORT_DIV)		106	 
	set	evv(DISTORT_HRM)		107	 
	set	evv(DISTORT_FRC)		108	 
	set	evv(DISTORT_REV)		109	 
	set	evv(DISTORT_SHUF)		110	 
	set	evv(DISTORT_RPT)		111	 
	set	evv(DISTORT_INTP)		112	 
	set	evv(DISTORT_DEL)		113	 
	set	evv(DISTORT_RPL)		114	 
	set	evv(DISTORT_TEL)		115	 
	set	evv(DISTORT_FLT)		116	 
	set	evv(DISTORT_INT)		117	 
	set	evv(DISTORT_PCH)		118	 
	set	evv(ZIGZAG)				119	 
	set	evv(LOOP)				120	 
	set	evv(SCRAMBLE)			121	 
	set	evv(ITERATE)			122	 
	set	evv(DRUNKWALK)			123	 
	set	evv(SIMPLE_TEX)			124	 
	set	evv(GROUPS)				125	 
	set	evv(DECORATED)			126	 
	set	evv(PREDECOR)			127	 
	set	evv(POSTDECOR)			128	 
	set	evv(ORNATE)				129	 
	set	evv(PREORNATE)			130	 
	set	evv(POSTORNATE)			131	 
	set	evv(MOTIFS)				132	 
	set	evv(MOTIFSIN)			133	 
	set	evv(TIMED)				134
	set	evv(TGROUPS)			135
	set	evv(TMOTIFS)			136 
	set	evv(TMOTIFSIN)			137
	set evv(GRAIN_COUNT)		138
	set evv(GRAIN_OMIT)			139
	set evv(GRAIN_DUPLICATE)	140
	set evv(GRAIN_REORDER)		141
	set evv(GRAIN_REPITCH)		142
	set evv(GRAIN_RERHYTHM)		143
	set evv(GRAIN_REMOTIF)		144
	set evv(GRAIN_TIMEWARP)		145
	set evv(GRAIN_GET)			146
	set evv(GRAIN_POSITION)		147
	set evv(GRAIN_ALIGN)		148
	set evv(GRAIN_REVERSE)		149
	set evv(ENV_CREATE)			150
	set evv(ENV_EXTRACT)		151
	set evv(ENV_IMPOSE)			152
	set evv(ENV_REPLACE)		153
	set evv(ENV_WARPING)		154
	set evv(ENV_RESHAPING)		155
	set evv(ENV_REPLOTTING)		156
	set evv(ENV_DOVETAILING)	157
	set evv(ENV_CURTAILING)		158
	set evv(ENV_SWELL)			159
	set evv(ENV_ATTACK)			160
	set evv(ENV_PLUCK)			161
	set evv(ENV_TREMOL)			162
	set evv(ENV_ENVTOBRK)		163
	set evv(ENV_ENVTODBBRK)		164
	set evv(ENV_BRKTOENV)		165
	set evv(ENV_DBBRKTOENV)		166
	set evv(ENV_DBBRKTOBRK)		167
	set evv(ENV_BRKTODBBRK)		168
	set	evv(MIXTWO)				169
	set	evv(MIXCROSS)			170
	set	evv(MIXINTERL)			171
	set	evv(MIXINBETWEEN)		172
	set	evv(MIX)				173
	set	evv(MIXMAX)				174
	set	evv(MIXGAIN)			175
	set	evv(MIXSHUFL)			176
	set	evv(MIXTWARP)			177
	set	evv(MIXSWARP)			178
	set	evv(MIXSYNC)			179
	set	evv(MIXSYNCATT)			180
	set	evv(MIXTEST)			181
	set	evv(MIXFORMAT)			182
	set	evv(MIXDUMMY)			183	
	set	evv(MIXVAR)				184
	set evv(EQ)					185	
	set evv(LPHP)				186	
	set evv(FSTATVAR)			187	
	set evv(FLTBANKN)			188	
	set evv(FLTBANKC)			189	
	set evv(FLTBANKU)			190	
	set evv(FLTBANKV)			191	
	set evv(FLTSWEEP)			192	
	set evv(FLTITER)			193	
	set evv(ALLPASS)			194		
	set	evv(MOD_LOUDNESS)		195
	set	evv(MOD_SPACE)			196
	set	evv(MOD_PITCH)			197
	set	evv(MOD_REVECHO)		198
	set	evv(BRASSAGE)			199
	set	evv(SAUSAGE)			200
	set	evv(MOD_RADICAL)		201
	set	evv(PVOC_ANAL)			202
	set	evv(PVOC_SYNTH)			203
	set	evv(PVOC_EXTRACT)		204
	set	evv(WORDCNT)			205	
	set	evv(EDIT_CUT)			206
	set	evv(EDIT_CUTEND)		207
	set	evv(EDIT_ZCUT)			208
	set	evv(EDIT_EXCISE)		209
	set	evv(EDIT_EXCISEMANY)	210
	set	evv(EDIT_INSERT)		211
	set	evv(EDIT_INSERTSIL)		212
	set	evv(EDIT_JOIN)			213
	set	evv(HOUSE_COPY)			214
	set	evv(HOUSE_CHANS)		215
	set	evv(HOUSE_EXTRACT)		216
	set	evv(HOUSE_SPEC)			217
	set	evv(HOUSE_BUNDLE)		218
	set	evv(HOUSE_SORT)			219
	set	evv(HOUSE_BAKUP)		220
	set	evv(HOUSE_RECOVER)		221
	set	evv(HOUSE_DISK)			222
	set evv(INFO_PROPS)			223
	set evv(INFO_SFLEN)			224
	set evv(INFO_TIMELIST)		225
	set evv(INFO_TIMESUM)		226
	set evv(INFO_TIMEDIFF)		227
	set evv(INFO_SAMPTOTIME)	228
	set evv(INFO_TIMETOSAMP)	229
	set evv(INFO_MAXSAMP)		230
	set evv(INFO_LOUDCHAN)		231
	set evv(INFO_FINDHOLE)		232
	set evv(INFO_DIFF)			233
	set evv(INFO_CDIFF)			234
	set evv(INFO_PRNTSND)		235
	set evv(INFO_MUSUNITS)		236
	set evv(SYNTH_WAVE)			237
	set evv(SYNTH_NOISE)		238
	set evv(SYNTH_SIL)			239
	set evv(UTILS_GETCOL)		240
	set evv(UTILS_PUTCOL)		241
	set evv(UTILS_JOINCOL)		242
	set evv(UTILS_COLMATHS)		243	
	set evv(UTILS_COLMUSIC)		244
	set evv(UTILS_COLRAND)		245
	set evv(UTILS_COLLIST)		246
	set evv(UTILS_COLGEN)		247
	set	evv(FREEZE2)			248
	set	evv(HOUSE_DEL)			249
	set	evv(UTILS_VECTORS)		250
	set evv(INSERTSIL_MANY) 	251
	set evv(RANDCUTS) 			252
	set evv(RANDCHUNKS) 		253
	set evv(SIN_TAB) 			254
	set evv(ACC_STREAM) 		255

	set evv(BOT_OF_PRIV)		256

	set evv(MIXMULTI)			256
	set evv(ANALJOIN)			257
	set evv(PTOBRK)				258
	set evv(PSOW_STRETCH)		259
	set evv(PSOW_DUPL)			260
	set evv(PSOW_DEL)			261
	set evv(PSOW_STRFILL)		262
	set evv(ONEFORM_GET)		263
	set evv(ONEFORM_PUT)		264
	set evv(ONEFORM_COMBINE)	265
	set evv(PSOW_FREEZE)		266
	set evv(PSOW_CHOP)			267
	set evv(PSOW_INTERP)		268
	set evv(NEWGATE)			269
	set evv(PSOW_FEATURES)		270
	set evv(PSOW_SYNTH)			271
	set evv(PSOW_IMPOSE)		272
	set evv(PSOW_SPLIT)			273
	set evv(PSOW_SPACE)			274
	set evv(PSOW_INTERLEAVE)	275
	set evv(PSOW_REPLACE)		276
	set evv(PSOW_EXTEND)		277
	set evv(PSOW_LOCATE)		278
	set evv(PSOW_CUT)			279
	set evv(SPEC_REMOVE)		280
	set evv(PSOW_EXTEND2)		281
	set evv(PREFIXSIL)			282
	set evv(STRANS_MULTI)		283
	set evv(PSOW_REINF)			284
	set evv(PARTIALS_HARM)		285
	set evv(SPECROSS)			286
	set evv(MCHITER)			287

	set evv(TOP_OF_PRIV)		288

	set evv(HF_PERM1) 			289
	set evv(HF_PERM2) 			290
	set evv(DEL_PERM) 			291
	set evv(DEL_PERM2) 			292
	set evv(SYNTH_SPEC) 		293
	set evv(DISTORT_OVERLOAD) 	294
	set evv(TWIXT) 				295
	set evv(SPHINX) 			296
	set evv(INFO_LOUDLIST)		297
	set evv(P_SYNTH)			298
	set evv(P_INSERT)			299
	set evv(P_PTOSIL)			300
	set evv(P_NTOSIL)			301
	set evv(P_SINSERT)			302
	set evv(ANALENV)			303
	set evv(MAKE2)				304
	set evv(P_VOWELS)			305
	set evv(HOUSE_DUMP)			306
	set evv(HOUSE_GATE)			307
	set evv(MIX_ON_GRID)		308
	set evv(P_GEN)				309
	set evv(P_INTERP)			310
	set evv(AUTOMIX)			311
	set evv(EDIT_CUTMANY)		312
	set evv(STACK)				313
	set evv(VFILT)				314	
	set evv(ENV_PROPOR)			315
	set	evv(SCALED_PAN)			316
	set	evv(MIXMANY)			317
	set evv(DISTORT_PULSED) 	318
	set evv(NOISE_SUPRESS) 		319
	set evv(TIME_GRID) 			320
	set evv(SEQUENCER) 			321
	set evv(CONVOLVE) 			322
	set evv(BAKTOBAK) 			323
	set evv(ADDTOMIX) 			324
	set evv(EDIT_INSERT2) 		325
	set evv(MIX_PAN) 			326
	set evv(SHUDDER) 			327
	set evv(MIX_AT_STEP) 		328
	set evv(FIND_PANPOS) 		329
	set evv(CLICK) 				330
	set evv(DOUBLETS) 			331
	set evv(SYLLABS) 			332
	set evv(JOIN_SEQ) 			333
	set evv(MAKE_VFILT) 		334
	set evv(BATCH_EXPAND) 		335
	set evv(MIX_MODEL) 			336
	set evv(CYCINBETWEEN) 		337
	set evv(JOIN_SEQDYN) 		338
	set evv(ITERATE_EXTEND) 	339
	set evv(DISTORT_RPTFL) 		340
	set evv(TOPNTAIL_CLICKS) 	341
	set evv(P_BINTOBRK) 		342
	set evv(ENVSYN) 			343
	set evv(SEQUENCER2)			344
	set evv(RRRR_EXTEND)		345
	set evv(HOUSE_GATE2)		346
	set evv(GRAIN_ASSESS)		347
	set evv(FLTBANKV2)			348
	set evv(DISTORT_RPT2)		349
	set evv(ZCROSS_RATIO)		350
	set evv(SSSS_EXTEND)		351
	set evv(GREV)				352
	set evv(TAPDELAY)			353
	set evv(RMRESP)				354
	set evv(RMVERB)				355
	set evv(LUCIER_GETF)		356
	set evv(LUCIER_GET)			357
	set evv(LUCIER_PUT)			358
	set evv(LUCIER_DEL)			359
	set evv(SPECLEAN)			360
	set evv(SPECTRACT)			361
	set evv(PHASE)				362
	set evv(FEATURES)			363
	set evv(BRKTOPI)			364
	set evv(SPECSLICE)			365
	set evv(FOFEX_EX)			366
	set evv(FOFEX_CO)			367
	set evv(GREV_EXTEND)		368
	set evv(PEAKFIND)			369
	set evv(CONSTRICT)			370
	set evv(EXPDECAY)			371
	set evv(PEAKCHOP)			372
	set evv(MCHANPAN)			373
	set evv(TEX_MCHAN)			374
	set evv(MANYSIL)			375
	set evv(RETIME)				376
	set evv(HOVER)				378
	set evv(MULTIMIX)			379
	set evv(FRAME)				380
	set evv(SEARCH)				381
	set evv(MCHANREV)			382
	set evv(WRAPPAGE)			383
	#	NB Numbers used for Data Analysis programs
	#	SPEKTRUM	384
	#	SPEKVARY	385
	#	SPEKFRMT	386
	#	TS_OSCIL	387
	#	TS_TRACE	388
	set evv(SPECAV)				389
	set evv(SPECANAL)			390
	set evv(SPECSPHINX)			391
	set evv(SUPERACCU)			392
	set evv(PARTITION)			393
	set evv(SPECGRIDS)			394
	set evv(GLISTEN)			395
	set evv(TUNEVARY)			396
	set evv(ISOLATE)			397
	set evv(REJOIN)				398
	set evv(PANORAMA)			399
	set evv(TREMOLO)			400
	set evv(ECHO)				401
	set evv(PACKET)				402
	set evv(SYNTHESIZER)		403
	set evv(TAN_ONE)			404
	set evv(TAN_TWO)			405
	set evv(TAN_SEQ)			406
	set evv(TAN_LIST)			407
	set evv(SPECTWIN)			408
	set evv(TRANSIT)			409
	set evv(TRANSITF)			410
	set evv(TRANSITD)			411
	set evv(TRANSITFD)			412
	set evv(TRANSITS)			413
	set evv(TRANSITL)			414
	set evv(CANTOR)				415
	set evv(SHRINK)				416
	set evv(NEWTEX)				417
	set evv(CERACU)				418
	set evv(MADRID)				419
	set evv(SHIFTER)			420
	set evv(FRACTURE)			421
	set evv(SUBTRACT)			422
	set evv(SPEKLINE)			423
	set evv(SPECMORPH)			424
	set evv(SPECMORPH2)			425
	set	evv(NEWDELAY)			426
	set	evv(FILTRAGE)			427
	set	evv(ITERLINE)			428
	set	evv(ITERLINEF)			429
	set	evv(SPECRAND)			431
	set	evv(SPECSQZ)			432
	set	evv(HOVER2)				433
	set	evv(SELFSIM)			434
	set	evv(ITERFOF)			435
	set	evv(PULSER)				436
	set	evv(PULSER2)			437
	set	evv(PULSER3)			438
	set	evv(CHIRIKOV)			439
	set	evv(MULTIOSC)			440
	set	evv(SYNFILT)			441
	set	evv(STRANDS)			442
	set	evv(REFOCUS)			443
	set	evv(CHANPHASE)			447
	set	evv(SILEND)				448
	set	evv(SPECULATE)			449
	set	evv(SPECTUNE)			450
	set	evv(REPAIR)				451
	set	evv(DISTSHIFT)			452
	set	evv(QUIRK)				453
	set	evv(ROTOR)				454
	set	evv(DISTCUT)			455
	set	evv(ENVCUT)				456
	set	evv(SPECFOLD)			458
	set	evv(BROWNIAN)			459
	set	evv(SPIN)				460
	set	evv(SPINQ)				461
	set	evv(CRUMBLE)			462
	set	evv(TESSELATE)			463
	set	evv(PHASOR)				465
	set	evv(CRYSTAL)			466
	set	evv(WAVEFORM)			467
	set	evv(DVDWIND)			468
	set	evv(CASCADE)			469
	set	evv(SYNSPLINE)			470
	set	evv(FRACTAL)			471
	set	evv(FRACSPEC)			472
	set	evv(SPLINTER)			473
	set	evv(REPEATER)			474
	set	evv(VERGES)				475
	set	evv(MOTOR)				476
	set	evv(STUTTER)			477
	set	evv(SCRUNCH)			478
	set	evv(IMPULSE)			479
	set	evv(TWEET)				480
	set	evv(BOUNCE)				481
	set	evv(SORTER)				482
	set	evv(SPECFNU)			483
	set	evv(FLATTEN)			484
	set	evv(DISTMARK)			488
	set	evv(DISTREP)			496
	set	evv(TOSTEREO)			497
	set	evv(SUPPRESS)			498
	set	evv(CALTRAIN)			499
	set	evv(SPECENV)			500
	set	evv(CLIP)				503
	set	evv(SPECEX)				504
	set evv(TOTAL_PROCS)  $evv(SPECEX)

	set evv(VBOX)				2000	;#	Special application for viewing syllable slices of voices

	#	MULTICHANNEL TOOLKIT, lies between 900 and ABFPAN2P (which must be max in TOOLKLIT)

	set evv(ABFPAN)				900
	set evv(ABFPAN2)			901
	set evv(CHANNELX)			902
	set evv(CHORDER)			903
	set evv(CHXFORMAT)			904
	set evv(COPYSFX)			905
	set evv(FMDCODE)			906
	set evv(INTERLX)			907
	set evv(NJOIN)				908
	set evv(NMIX)				909
	set evv(RMSINFO)			910
	set evv(SFEXPROPS)			911
	set evv(CHXFORMATM)			912
	set evv(CHXFORMATG)			913
	set evv(NJOINCH)			914
	set evv(ABFPAN2P)			915

	set evv(SLICE)				1000	;# pseudo prog, uses Sound View differently for existing progs
	set evv(SNIP)				1001	;# pseudo prog, uses Sound View differently for existing progs
	set	evv(ENV_CONTOUR)		1002	;#	Crypto prg = mod_loudness, mode "gain"
	set	evv(ELASTIC)			1003	;#	Crypto prg = spectral time-stretch
	set	evv(PAD)				1004	;#	Crypto prg = silend from edit menu

	set evv(SYNTHSEQ)			2000	;#	Testbed applics for synth sequences
	set evv(SYNTHSEQ2)			2001	;#	Testbed applics for other synth sequences

	set evv(TOP_OF_CDP)			$evv(GREV)

	set evv(GR_ONEBAND)		 	 0			;#	modes
	set evv(GR_MULTIBAND)	 	 1
	set evv(TRNS_RATIO)		 	 0
	set evv(TRNS_OCT)		 	 1
	set evv(TRNS_SEMIT)		 	 2
	set evv(TRNS_BIN)		 	 3
	set evv(TUNE_FRQ)		 	 0
	set evv(TUNE_MIDI)		 	 1
	set evv(DISTORTE_USERDEF) 	 3
	set evv(ZIGZAG_USER)	 	 1
	set evv(ENVSYN_USERDEF)		 3
	set evv(TEXTURE_INSHI)		 5

	set evv(ENV_ENVFILE_OUT) 	 0
	set evv(ENV_BRKFILE_OUT) 	 1
	set evv(ENV_LIFTING)		 4
 	set evv(ENV_TSTRETCHING)	 5
	set evv(ENV_GATING)			 7
	set evv(ENV_INVERTING)		 8
	set evv(ENV_LIMITING)		 9
	set evv(ENV_EXPANDING)		11
	set evv(ENV_TRIGGERING) 	12
	set evv(ENV_DUCKED)			14
	set evv(ENV_ATK_GATED) 	     0

 	set evv(ENV_SNDFILE_IN)		 0
 	set evv(ENV_ENVFILE_IN)		 1
 	set evv(ENV_BRKFILE_IN)		 2
 	set evv(ENV_DB_BRKFILE_IN)	 3
 
 	set evv(MOD_STADIUM)		 2

	set evv(DUPL)				 1
	set evv(HOUSE_CHANNEL)		 0
	set evv(HOUSE_CHANNELS)		 1
	set evv(HOUSE_ZCHANNEL)		 2
	set evv(STOM)				 3
	set evv(MTOS)				 4
	set evv(HOUSE_CUTGATE)		 0
	set evv(HOUSE_TOPNTAIL)		 2
	set evv(HOUSE_RECTIFY)		 3
	set evv(HOUSE_ONSETS)		 5

 	set evv(MOD_SCRUB)			 2
 	set evv(MOD_CROSSMOD)		 5
	set evv(MOD_REVERSE)		 0
	set evv(MOD_LOBIT)			 3
	set evv(MOD_LOBIT2)			 6

	set evv(MOD_PAN)			 0
	set evv(MOD_MIRROR)			 1
	set evv(MOD_MIRRORPAN)		 2
	set evv(MOD_NARROW)			 3

	set evv(HFP_TEXTOUT)		 2
	set evv(HFP_MIDIOUT)		 3

	set evv(MOD_RINGMOD)		 4
	set evv(LOUDNESS_GAIN)		 0
	set evv(LOUDNESS_DBGAIN)	 1
	set evv(LOUDNESS_NORM)		 2
	set evv(LOUDNESS_SET)		 3
	set evv(LOUDNESS_BALANCE)	 4
	set evv(LOUDNESS_PHASE)	 	 5
	set evv(LOUDNESS_LOUDEST)	 6
	set evv(LOUDNESS_EQUALISE)	 7
	set evv(LOUD_PROPOR)		 10
	set evv(LOUD_DB_PROPOR)		 11
	set evv(PPT)		 		 0
	set evv(FROMTIME)	 		 0
	set evv(ANYWHERE)	 		 1
	set evv(FILTERING)	  		 2
	set evv(COMPARING)	  		 3
	set evv(ITERATE_DUR)		 0
	set evv(ENV_ATK_TIMED) 	   	 1
	set evv(ENV_ATK_XTIME)		 2
	set evv(MTW_TIMESORT)		 0  
	set evv(MSW_TWISTALL)		 6
	set evv(MSW_TWISTONE)		 7
	set evv(PAN_PAN)			 0
	set evv(MOD_ACCEL)			 4
	set evv(MOD_VDELAY)			 1
	set evv(MOD_SHRED)			 1
	set evv(HAS_SOBER_MOMENTS) 	 1
	set evv(MOD_TRANSPOS_INFO)	 	 2
	set evv(MOD_TRANSPOS_SEMIT_INFO) 3
	set evv(GREV_GET)				 5
	set evv(PTP) 					 1
	set evv(PICH_TO_BIN) 			 0
	set evv(TSTR_LENGTH) 			 1
	set evv(HOUSE_CUTGATE_PREVIEW)	 1
	set evv(EDIT_SECS)				 0
	set evv(EDIT_SAMPS)				 1
	set evv(EDIT_STSAMPS)			 2
	set evv(TEX_HF)			  		 0
	set evv(TEX_HFS)		  		 1
	set evv(TEX_HS)	  				 2
	set evv(TEX_HSS)	  			 3
	set evv(TEX_NEUTRAL)	  		 4
	set evv(FLT_HZ)					 0
	set evv(MIX_LEVEL_ONLY)			 0
	set evv(MIX_LEVEL_AND_CLIPS)	 2
	set evv(ENV_TREM_LIN)			 0
	set evv(ENV_TREM_LOG)			 1
	set evv(IN_SEQUENCE)			 0
	set evv(RAND_REORDER)			 1
	set evv(RAND_SEQUENCE)			 2
	set evv(TRUE_EDIT)				 3
	set evv(TWIXT_PREVIEW_CRYPTO) 	 4
	set evv(TWIXT_ONSETS_CRYPTO)	 5
	set evv(SHRM_FINDMX)			 4
	set evv(SYNTH_SPIKES)			 3

	set evv(ENV_EXTRACT_CRYPTO)		 2	;#	modes which actually call completely different program
	set evv(MOD_LOUDNESS_FRQ_CRYPTO) 8	;#
	set evv(MOD_LOUDNESS_PCH_CRYPTO) 9	;#

	set evv(ARPE_SUST)		  8			;#	PARAMETER NUMBERS FOR SPECIFIC CDP PROGS
	set evv(BLUR_BLURF)		  0
	set evv(BRG_OFFSET)		  0
	set evv(BRG_STIME)		  5
	set evv(BRG_ETIME)		  6
	set evv(CL_SKIPT)		  0
	set evv(DRNK_RANGE)		  0
	set evv(DRNK_STIME)		  1
	set evv(GRAB_FRZTIME)	  0
	set evv(LEAF_SIZE)		  0
	set evv(MAG_FRZTIME)	  0
	set evv(MPH_STAG)		  6
	set evv(MPH_ASTT)		  0
	set evv(OCTVU_TSTEP)	  6
	set evv(PA_TRANG)		  1
	set evv(PA_SRANG)		  2
	set evv(PC_STT)			  0
	set evv(PC_END)			  1
	set evv(PF_SCUT)		  0
	set evv(PF_ECUT)		  1
	set evv(PR_TSTEP)		  1 
	set evv(PS_TFRAME)		  0 
	set evv(PEAK_TWINDOW)	  1
	set evv(WARP_TRNG)		  1
	set evv(WARP_SRNG)		  2
	set evv(WAVER_VIB)		  0
	set evv(ZIGZAG_START)	  0
	set evv(ZIGZAG_END)		  1
	set evv(ZIGZAG_DUR)		  2
	set evv(ZIGZAG_MIN)		  3
	set evv(ZIGZAG_MAX)		  5
	set evv(LOOP_START)		  2
	set evv(LOOP_LEN)		  3
	set evv(LOOP_STEP)		  4
	set evv(LOOP_SRCHF)		  6
	set evv(SCRAMBLE_MIN)	  0
	set evv(SCRAMBLE_MAX)	  1
	set evv(SCRAMBLE_LEN)	  0
	set evv(ITER_DUR)		  0
	set evv(GR_GATE)		  3
	set evv(GR_MINTIME)		  4
	set evv(GR_WINSIZE)		  5
	set evv(ENV_WSIZE)		  0
	set evv(ENV_TRIGDUR)	  3
	set evv(ENV_STARTTRIM)	  0	
	set evv(ENV_ENDTRIM)	  1
	set evv(ENV_STARTTIME)	  0
	set evv(ENV_ENDTIME)	  1
	set evv(ENV_PEAKTIME)	  0		
	set evv(ENV_ATK_TAIL)	  3
	set evv(ENV_ATK_ATTIME)	  0
	set evv(ENV_PLK_ENDSAMP)  0
	set evv(ENV_PEAKCNT) 	  15
	set evv(MCR_STAGGER) 	  0
	set evv(MCR_BEGIN)		  1
	set evv(MIX_STAGGER)	  0
	set evv(MSH_ENDLINE)	  3
	set evv(MSH_STARTLINE)	  2
	set evv(MSW_TWLINE)		  0
	set evv(FLT_OUTDUR)		  3
	set evv(FLT_DELAY)		  2
	set evv(ACCEL_GOALTIME)	  1
	set evv(ACCEL_STARTTIME)  2
	set evv(DELAY_LFODELAY)	  6
	set evv(SHRED_CHLEN)	  1
	set evv(SCRUB_TOTALDUR)	  0
	set evv(SCRUB_STARTRANGE) 3
	set evv(SCRUB_ESTART)	  4
	set evv(GRS_GRAINSIZE)	  4
	set evv(GRS_HGRAINSIZE)	  10
	set evv(GRS_SRCHRANGE)	  16
	set evv(WRAP_GRAINSIZE)	  8
	set evv(WRAP_HGRAINSIZE)  9
	set evv(WRAP_SRCHRANGE)	  18
	set evv(CUT_CUT)		  0
	set evv(CUT_END)		  1
	set evv(DRNK_TOTALDUR)	  0
	set evv(DRNK_LOCUS)		  1
	set evv(DRNK_AMBITUS)	  2
	set evv(DRNK_GSTEP)		  3
	set evv(DRNK_CLOKTIK)	  4
	set evv(DRNK_SPLICELEN)	  7
	set evv(DRNK_MIN_PAUS)	  11
	set evv(DRNK_MAX_PAUS)	  12
	set evv(MIX_ATTEN)		  2
	set evv(MIX_GAIN)		  0
	set evv(SHR_GAP)		  2
	set evv(SHR_DUR)		  4
	set evv(SHR_AFTER)		  4

#	Typology of files used as inputs to ins

	set evv(TYP)	0	;#	FILETYPE ( i.e. PREVIOUS_OUTFILE, PREVIOUS_INFILE or NEW_INFILE)
	set evv(FNO)	1	;#	ABSOLUTE FILE NO (in ins listing of files used)
	set evv(INO)	2	;#	INFILE NUMBER (in ins index of INfiles used)
	set evv(PREVIOUS_OUTFILE) 0
	set evv(PREVIOUS_INFILE)  1
	set evv(NEW_INFILE)		  2

#	Position of ins data in ins(uberlist)

	set evv(MSUPER_BATCH)	  	 1	;#	Indices of ins data in ins(uberlist)
	set evv(MSUPER_GADGETS) 	 2
	set evv(MSUPER_CONDITIONS) 	 3
	set evv(MSUPER_TREE) 		 4
	set evv(MSUPER_FNAMES) 		 5
	set evv(MSUPER_PNAMES) 		 6
	set evv(MSUPER_DEFAULTS)	 7
	set evv(MSUPER_SUBDEFAULTS)	 8
	set evv(MSUPER_TIMETYPE)	 9

#	Special textmarkers

	set evv(NUM_MARK)	"@"	;#	Code passed to cdpmain to differentiate numeric vals from brkfile names
	set evv(INFIL_MARK)		"~"	;#	In saved-cmdlines used in 'doInstrument'
	set evv(VARP_MARK)	"#"	;#	In saved-cmdlines used in 'doInstrument'

	set evv(DELMARK)	"@"	;#	Marks deleted file in sources listing
	set evv(SRCLISTS)			"srclist" 		;# File for sources listing
	set evv(RECDIRS)			"recdirs" 		;# File for recently used directories
	set evv(LASTRUNVALS) 		"lastruns"		;# File for parameter values on last run of each prog or ins
	set evv(DIRLISTING) 		"dirlist"		;# File for directory which is listed on the workspace (if any)

#	Program-output display

	set evv(WARN_COLR)				blue	;#	Color of text of warning messages
	set evv(ERR_COLR)				red		;#	Color of text of error messages
	set evv(INF_COLR)				black	;#	Color of text of information messages

#	Progress-bar display

	set evv(PBAR_SEPARATOR_HEIGHT)		1		;#	Width of line dividing progress-bar from info-display
	set evv(PBAR_HEIGHT)		 		24		;#	Height of progress-bar
	set evv(PBAR_ENDSIZE)				10		;#	Width of endblock at start of progress-bar
	set evv(PBAR_ENDCOLOR)				black	;#	Color of endblocks at each end ofprogress-bar
	set evv(PBAR_LENGTH) 				256		;#	Length of progress-bar *** MUST TALLY WITH CDP CODE *** 
	set evv(PBAR_DONECOLOR)				DarkGoldenrod3	;#	Color of progress-bar
	set evv(PBAR_NOTDONECOLOR)			LemonChiffon1	;#	Color of background of progress-bar
	set evv(PROGRESS_START)				0		;#	Start length of progress-bar (is 0 OK, if not, use 1)

	set evv(HISTORY_BLOK)				24		;#	size of hst block to store at one go
	set evv(MAX_HISTORY_SIZE)			48		;#	Max size of hst before storage takes place
	set evv(HISTORY_LINESTORE)			48		;#	No of hst lines to store at one go  = 2 * HISTORY_BLOK
	set evv(HALF_HISTORY_INDEX)			47		;#	Index of last hst line = HISTORY_LINESTORE - 1
	set evv(LOGS_MAX)					10		;#	Default max number of logs to store on disk before cull called

#	History_blok is the basic number of hst-line-pairs we will keep in memory for display
#	Once the number of lines is DOUBLE this, we store a History_blok to file
#	NB: NB: NB:	we actually save 2 * history_blok lines, = History_store
#	
	set evv(DUMMY_DISPLAY)				"-------"
	set evv(MAX_HDISPLAY_INFILES)		2		 	;#	Max no of infiles displayed on hst-display
	set evv(MAX_HDISPLAY_OUTFILES)		2		 	;#	Max no of outfiles displayed on hst-display
	set evv(HISTORY_INFILECNT)			1			;#	Position of infilecnt on ins-hst line
	set evv(HISTORY_INFILES)			2			;#	Position of list of infiles on ins-hst line
	set evv(LOGCOUNT_FILE)				"log.ct"	;#	File contains count of databloks in each logfile

	set evv(USERENV)					"USERenv"   ;#	File for user environment settings
	set evv(USERRES)					"USERres"   ;#	File for user resource settings
	set evv(BHELP)						"bhelp"   ;#	File for user help indication
	set evv(FAVORITES)					"favors" 	;#	File for user resource settings
	set evv(NUNAMES)					"nunames" 	;#	File for recently used namess

#	Dimensions of brkfile creation display

	set evv(XWIDTH)					600			;#	Size of drawing canvas on brktable display
	set evv(YHEIGHT)				400
	set evv(PWIDTH)					2			;#	Half-Size of points on brktable display
	set evv(BWIDTH)					60			;#	Size of borders around brktable display
	set evv(BPWIDTH)	   [expr int($evv(BWIDTH) + round($evv(PWIDTH)/2.0))]
	set evv(BRKOFFSET)				10			;#	Ammount by which text is offset from edge of brktable area, xwise
	set evv(MINBRKDUR)				0.0001		;#	Minimum brktable length, for user to enter
	set evv(ZEROTIME)				"0.0secs"	;#	Display of time-zero on brktables graph
	set evv(TIME)					"Time"		;#	Text for time-axis on brktable display
	set evv(VALUE)					"Value"		;#	Text for time-axis on brktable display
	set evv(XTEXT_SPACER)			30			;#	Clear space on either side of "text" word on x-axis
	set evv(MAX_XCHAR)				5			;#	Max no. of chars on X-axis display of range vals, 
												;#	MUST BE AT LEAST length of set evv(VALUE)
	set evv(QUITBRK)				0			;#	Flag values for exiting brkfile editing or creation
	set evv(SAVEBRK)				1
	set evv(USEBRK)					2
	set evv(MAX_BRKVAL_WIDTH)		14			;#	max width of label displaying name of val required by brkediting
	set evv(MAX_BRKVAL_RWIDTH)		40			;#	max width of label displaying range of val required by brkediting
	set evv(GARBAGE)		 "123456789.8642"	;#	Preset garbage val
	set evv(GARBAGE2)		 		-1			;#	Preset garbage val for numbers that can't be -ve (e.g. ratios,flags)
	set evv(MAXDUR)					3600		;#	Brktable max timedisplay: 1 hour
	set evv(MINDUR)					.01			;#	Brktable min timedisplay: 10 ms (approx 500 samples)
	set evv(MAXSTRETCH)				1000		;#	Brktable max-stretchfactor for time-display
	set evv(MINSTRETCH)				.001		;#	Brktable min-shrinkfactor for time-display
	set evv(FLTERR)					0.000002	;#	Permissible error in flteq calculations
	set evv(ROUNDERR)				0.000001	;#	Rounding Error correction for decimal comparisons

	set	evv(UMBREL_INDX)			0			;#	Indeces to program data
	set evv(PROGNAME_INDEX)			1			
	set evv(MODECNT_INDEX)			2
	set evv(MODENAMES_BASE)			3

	set	evv(MENUNAME_INDEX)			0			;#	Indeces to menu data
	set	evv(MENUTYPE_INDEX)			1
	set	evv(MENUPROGS_INDEX)		2

;# FEB 2004 The "if info exists" brackets are new idea to allow system dependent fontsize to be set in "EstablishFont"
	if {![info exists evv(FONT_FAMILY)]} {
		set evv(FONT_FAMILY)		tahoma
	}
	if {![info exists evv(FONT_SIZE)]} {
		set evv(FONT_SIZE)		    8
	}
	if {![info exists evv(BIG_FONT_SIZE)]} {
		set evv(BIG_FONT_SIZE)		10
	}

	set evv(MAX_BRKLIST_WIDTH)		32
	set evv(DO_GRAB)				1
	set evv(DO_COPY)				2
	set evv(GRAB_ALL)				3
	set evv(DELETE_ALL)				4
	set evv(DELETE_SOME)			5
	set evv(DO_FIND)				6
	set evv(DO_SPECIAL_COPY)		7

	set evv(TOPLEFT)				"+0+0"
	set evv(T_CURVE_OFFSET)		1.5
	set evv(T_VERTL_OFFSET)		0.26		;#	i.e. > 1/4 to force rounding up

	set evv(HELP_DEFAULT)			""

	set evv(NSTORLEN)	12	;#	Names stored for info

	set evv(PARSE_FAILED)	-2

	catch {font create userfnt -family $evv(FONT_FAMILY) -size $evv(FONT_SIZE)}
	font create bigfnt -family $evv(FONT_FAMILY) -size $evv(BIG_FONT_SIZE)
	font create bigfntbold -family $evv(FONT_FAMILY) -size $evv(BIG_FONT_SIZE) -weight bold
	set evv(MID_FONT_SIZE) [expr ($evv(FONT_SIZE) + $evv(BIG_FONT_SIZE))/2]
	font create midfnt -family $evv(FONT_FAMILY) -size $evv(MID_FONT_SIZE)
	option add *font userfnt

	set mu(NPAD) 1
	set mu(PPAD) 2
	set mu(IPAD) 3

	set mu(MU_MIDI_TO_FRQ)			0
	set mu(MU_FRQ_TO_MIDI)			1
	set mu(MU_NOTE_TO_FRQ)			2  	
	set mu(MU_NOTE_TO_MIDI)			3
	set mu(MU_FRQ_TO_NOTE)			4
	set mu(MU_MIDI_TO_NOTE)			5
	set mu(MU_FRQRATIO_TO_SEMIT)	6
	set mu(MU_FRQRATIO_TO_INTVL)	7
	set mu(MU_INTVL_TO_FRQRATIO)	8
	set mu(MU_SEMIT_TO_FRQRATIO)	9
	set mu(MU_OCTS_TO_FRQRATIO)		10
	set mu(MU_OCTS_TO_SEMIT)		11
	set mu(MU_FRQRATIO_TO_OCTS)		12
	set mu(MU_SEMIT_TO_OCTS)		13
	set mu(MU_SEMIT_TO_INTVL)		14
	set mu(MU_FRQRATIO_TO_TSTRETH)	15
	set mu(MU_SEMIT_TO_TSTRETCH)	16
	set mu(MU_OCTS_TO_TSTRETCH)		17
	set mu(MU_INTVL_TO_TSTRETCH)	18
	set mu(MU_TSTRETCH_TO_FRQRATIO)	19
	set mu(MU_TSTRETCH_TO_SEMIT)	20
	set mu(MU_TSTRETCH_TO_OCTS)		21
	set mu(MU_TSTRETCH_TO_INTVL)	22
	set mu(MU_GAIN_TO_DB)			23
	set mu(MU_DB_TO_GAIN)			24
	set mu(MU_DELAY_TO_FRQ)			25
	set mu(MU_DELAY_TO_MIDI)		26
	set mu(MU_FRQ_TO_DELAY)			27
	set mu(MU_MIDI_TO_DELAY)		28
	set mu(MU_NOTE_TO_DELAY)		29  	
	set mu(MU_TEMPO_TO_DELAY)		30
	set mu(MU_DELAY_TO_TEMPO)		31
	set mu(MU_BEATS_TO_TIME)		-1	;#	internal GUI modes
	set mu(MU_TIME_TO_BEATS)		-2
	set mu(MU_TIME_TO_SAMPLES)		-3
	set mu(MU_SAMPLES_TO_TIME)		-4
	set mu(MU_SAMPV_TO_DB)			-5
	set mu(MU_SAMPV_TO_GAIN)		-6
	set mu(MU_GAIN_TO_SAMPV)		-7
	set mu(MU_DB_TO_SAMPV)			-8
	set mu(MU_BARS_TO_BEATS)		-9
	set mu(MU_BARS_TO_TIME)			-10
	set mu(MU_BEATS_TO_BARS)		-11
	set mu(MU_TIME_TO_BARS)			-12
	set mu(MU_HMS_TO_SECS)			-13
	set mu(MU_SECS_TO_HMS)			-14
	set mu(MU_MM_TO_SECS)			-15
	set mu(MU_SECS_TO_MM)			-16
	set mu(MU_INTVL_TO_SEMIT)		-17
	set mu(MU_FRQ_TO_SECS)			-18
	set mu(MU_SECS_TO_FRQ)			-19
	set mu(MU_MM_TO_FRQ)			-20
	set mu(MU_METRES_TO_ECHO)		-21
	set mu(MU_ECHO_TO_METRES)		-22
	set mu(MU_METRES_TO_FRQ)		-23
	set mu(MU_TIME_TO_KBITS)		-24
	set mu(MU_KBITS_TO_TIME)		-25
	set mu(MU_FRQ_TO_METRES)		-26
	set mu(MU_DELAY_TO_NOTE)		-27

	set mu(MAXMFRQ) 	12543.853951	;#	midi 127
	set mu(MINMFRQ) 	8.175799		;#	midi 0
	set mu(MAXDFRQ) 	10000
	set mu(MAXFRQRATIO) 256
	set mu(MAXMMVAL)	512.0
	set mu(MINMMVAL)	1.0
	set mu(MAXGAIN) 	128
	set mu(MIDIMAX)	 	127
	set mu(MAXSEMIT) 	96
	set mu(MAXDB)	 	[expr log10($mu(MAXGAIN)) * 20.0]
	set mu(MAXOCT)		8
	set mu(MINPITCH) 	10
	set mu(MINFRQRATIO) 0.003906
	set mu(MINGAIN)	 	0.000016
	set mu(MIDIMIN)	 	0
	set mu(MINOCT)		-8
	set mu(MINDB)		-96
	set mu(MINSEMIT)	-96
	set mu(MAXSAMPS)	172800000
	set mu(MAXTIME)		22369
	set mu(MINDEL)		0.1
	set mu(MAXDEL)		100
	set mu(MINTDEL)		1.0
	set mu(MAXTDEL)		2000.0
	set mu(MINTEMPO)	30
	set mu(MAXTEMPO)	1000

	set mu(SPACS) 12
	set mu(MIN_DB_ON_16_BIT) -96.0

	set evv(TE_1) -1
	set evv(TE_2) -2
	set evv(TE_3) -3
	set evv(TE_4) -4
	set evv(TE_5) -5
	set evv(TE_6) -6
	set evv(TE_7) -7
	set evv(TE_8) -8
	set evv(TE_9) -9
	set evv(TE_10) -10
	set evv(TE_11) -11
	set evv(TE_12) -12
	set evv(TE_13) -13
	set evv(TE_14) -14
	set evv(TE_15) -15
	set evv(TE_16) -16
	set evv(TE_17) -17
	set evv(TE_18) -18
	set evv(TE_19) -19
	set evv(TE_20) -20
	set evv(TE_21) -21
	set evv(TE_22) -22
	set evv(TE_23) -23
	set evv(TE_24) -24
	set evv(TE_25) -25
	set evv(TE_26) -26
	set evv(TE_27) -27
	set evv(TE_28) -28
	set evv(TE_29) -29
	set evv(TE_30) -30
	set evv(TE_31) -31
	set evv(INSTRUMENT) -101

	set evv(COLFILE1)	$evv(DFLT_OUTNAME)$evv(TEXT_EXT)
	set evv(COLFILE2)	$evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
	set evv(COLFILE3)	$evv(MACH_OUTFNAME)$evv(TEXT_EXT)

	set evv(MAX_NEWFILES) 32
	set evv(MAX_WKSPFILES) 100

	set evv(OUTOFDATE_LIST) 21 	;#	21 'days' for saved workspaces or choicelists to become out of date
	set evv(NUMEMORY)	99		;#	Process memory button of calculator

	set evv(LOW_A) 				   6.875	;# Frequency of A below MIDI 0
	set evv(CONVERT_LOG10_TO_LOG2) 3.321928	;# MiditoHz conversions
	set evv(PDISPLAY_MAXWINDOWS)   60000	;# Guess, as each windowval stored in a string list
	set evv(MAXCURVE)   20					;# Maximum curvature for pitch smoothing
	set evv(MAXTRANSP)  $mu(MIDIMAX)
	set evv(MINTRANSP)	[expr -$mu(MIDIMAX)]
	set evv(BATCH) -100
	set evv(BATCH_EXT)	".bat"
	set evv(BATCHOUT_EXT) "_b"
	set evv(NOTEWIDTH) 8
	set evv(LEDGELEN) [expr $evv(NOTEWIDTH) + 6]
	set evv(HALF_NOTEWIDTH) [expr $evv(NOTEWIDTH) / 2]
	set evv(LEDGE_OFFSET) [expr ($evv(LEDGELEN) - $evv(NOTEWIDTH)) / 2]
	set evv(CREATE_PMARK) 0
	set evv(DEL_PMARK) 1
	set evv(SHOW_PMARK) 2
	set evv(DISPLAY_PMARK) 3
	set evv(SETUP_PMARK) 4
	set evv(COMPARE_PMARK) 5
	set evv(SCORENAMELEN) 10
	set evv(SCORECUT) 5.0
	set evv(SCORE_MINDX) 60
	set evv(SCORE_MINDY) 40
	set evv(SF_MAXFILES) 1000	;# these 4 vals must tally with CDP
	set evv(MIX_MINLINE) 4
	set evv(MINPAN)	-32767.0
	set evv(MAXPAN)	32767.0
	set evv(SIN30) 0.5
	set evv(COS60) $evv(SIN30)
	set evv(SIN60) 0.8660
	set evv(COS30) $evv(SIN60) 
	set evv(SIN45) [expr 1.0/$evv(ROOT2)]
	set evv(COS45) $evv(SIN45)

	set evv(DELETE_ENTIRE_PROP)	1
	set evv(ADD_VOID_PROP)	3
	set evv(ADD_VECTOR_PROP) 4

	# TABLE EDITOR

	set evv(LINECNT_NOT_RESET) 0
	set evv(LINECNT_RESET) 1
	set evv(LINECNT_ONE) 2

	# TONALITY WORKSHOP

	set evv(MIN_TONAL)	12
	set evv(MAX_TONAL)	108

	set evv(NAMED_SCORE) -1
	set evv(BITS_PER_BYTE) 8

	set mu(MIN16BIT)	-32768
	set mu(MAX16BIT)	32767
	set evv(SEMITONE_RATIO) 1.05946309436
	set evv(ABOUT)	white
	set evv(GRAF) black
	set evv(POINT) black
	set evv(BOX) black
	set evv(PGRID)	gray12
	set evv(HELP_DISABLED_FG) cornsilk4
	set evv(BRKTABLE_BORDER) [option get . foreground {}]
	set evv(GRAFSND) blue
	SetLEEDScolours

	set evv(SPEED_OF_SOUND) 346.5

	;# Motfi manipulation

	set evv(MTF_NUDGE) 0.05			;#	Time-distance notes are moved on display
	set evv(MTF_HLFNUDGE) 0.025		;#	Min closeness of notes (when moved) on display
	set evv(MTF_PGLIDE)   0.025		;#	Step between notes for synthesis
	set evv(MTF_OFFSET) 36
	set evv(REDOMIX) 2
	set evv(NEWMLEN) 3

	set evv(CDP_HEADSIZE) 3			;#	Approx headersize of CDP files, in KB

	set evv(SECS_TO_MS)	1000
	set evv(MS_TO_SECS)	"0.001"

	set evv(FLT_MINFRQ)	10.0

	set evv(SD_START)	0.0
	set evv(SD_FILT)	2000
	set evv(SD_WIDTH)	.9
	set evv(SD_LINGER)	.15
	set evv(SD_DEPTH)	1.35
	set evv(SD_LEAD)	.15

	set evv(LASTPROCLIST_MAX) 12
	set evv(SNACK) sview_state
	set evv(TIME_OUT) 1
	set evv(SMPS_OUT) 2
	set evv(GRPS_OUT) 0

	;#	Define type of data returned from Snack Displays

	set evv(SN_TIMEPAIRS)		0
	set evv(SN_BRKPNTPAIRS)		1
	set evv(SN_SINGLETIME)		2
	set evv(SN_TIMESLIST)		3
	set evv(SN_MULTIFILES)		4
	set evv(SN_BRKPNT_TIMEONLY)	5
	set evv(SN_WITHALPHA)		6
	set evv(SN_UNSORTED_TIMES)	7
	set evv(SN_MOVETIME_ONLY)	8
	set evv(SN_MOVETIME_ONLY2)	9
	set evv(SN_SINGLEFRQ)		10
	set evv(SN_FRQBAND)			11
	set evv(SN_FEATURES_PEAKS)	12
	set evv(SN_TIMEDIFF)		13

	;#	Snack File Display, from where ?

	set evv(SN_FROM_WKSP_NO_OUTPUT)	0
	set evv(SN_FROM_PRMPAGE_NO_OUTPUT)	-1

		;#	All these options send a filename to SnackDisplay and Give NO OUTPUT

	;# WARNING: DON'T DEFINE VALUES BELOW evv(SN_SENDFILE_NO_OUTPUT_TOP) FOR CASES WHERE OUTPUT IS REQUIRED
	;#	INSERT VALUES NEEDING A RETURN Above THESE, AND SHIFT evv(SN_SENDFILE_NO_OUTPUT_TOP) DOWNWARDS !!

	set evv(SN_SENDFILE_NO_OUTPUT_TOP) -2
	set evv(SN_FILE_PRMPAGE_NO_OUTPUT)		$evv(SN_SENDFILE_NO_OUTPUT_TOP)
	set evv(SN_FROM_CLEANKIT_NO_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 1]
	set evv(SN_FROM_PROPSPAGE_NO_OUTPUT)	[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 2]
	set evv(SN_FROM_PROPSTAB_NO_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 3]
	set evv(SN_FROM_PROPSRHYTHM_NO_OUTPUT)	[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 4]
	set evv(SN_FROM_PROPSHF_NO_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 5]
	set evv(SN_FROM_FOFCNSTR_NO_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 6]
	set evv(SN_FROM_SMOOTHER_NO_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 7]
	set evv(SN_FROM_ENGINEER_NO_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 8]
	set evv(SN_FROM_MULTICHAN_CHANVIEW)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 9]
	set evv(SN_FROM_DEGRADE_NO_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 10]
	set evv(SN_FROM_POLYF_NO_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 11]
	set evv(SN_FROM_CLEANKIT_OUTPUT)		[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 12]
	set evv(SN_FROM_REVDIST_OUTPUT)			[expr $evv(SN_SENDFILE_NO_OUTPUT_TOP) - 13]

	;# WARNING: DON'T DEFINE VALUES BELOW evv(SN_SENDFILE_NO_OUTPUT_TOP) FOR CASES WHERE OUTPUT IS REQUIRED
	;#	INSERT VALUES NEEDING A RETURN Above THESE, AND SHIFT evv(SN_SENDFILE_NO_OUTPUT_TOP) DOWNWARDS !!

	;#	File for property explanations

	set evv(EXPROPS) $evv(EXPROPNAME)$evv(CDP_EXT)

	set evv(NULL_PROP) "-"					;#	Null property in property files
	set evv(TEXTJOIN) "_"					;#	Separator character in texts stored as properties
	set evv(MAX_STATSPHRASE) 10				;#	max length of word-phrases examined by text-stats on properties				
	set evv(HFMIN_PROP) 53					;#	Min and MAx of Midi vals used to represent HFs in property files
	set evv(HFMAX_PROP) 88
	set evv(HFPROP_DUMMYFRQ)	10			;#	Dummy frequency used in creating HF sounds for Props display
	set evv(HFPROP_DUR)			3.0			;#	Duration of HF sounds for Props display
	set evv(HFPROP_STEPTIME)	.005		;#	Timestep of freq change between HFs in HF creation process
	set evv(HFPROP_SPLICETIME)	.050		;#	Splice length for cutting individual HFs from the HF-sausage
	set evv(HFPROP_MSSPLICE)	50			;#	..ditto in mS

	set evv(SN_FORMTOP)			6000
	set evv(SN_SPEECHTOP)		10000
	set evv(SN_SCALE_OFFSET)	36
	set evv(SN_TEXTTRIM)		6

	set evv(MIDITOPARAM)	0	;#	midi pitch(es) sent to specific parameter boxes
	set evv(MIDIFILT)		1	;#	midi pitches sent to cursor position on listing, with amp 1 added
	set evv(MIDIPITCHES)	2	;#	list of midipitches to a listing
	set evv(MIDIPITCHVEL)	3	;#	list of times and midipitches to a listing
	set evv(MIDITEXTURE)	4	;#  sets in motion getting MIDI notedata for the various TEXTURE processes
	set evv(TEXTURENOTES)	5	;#	midi data for creation of notedatafile or sequencer src pitches, 
	set evv(TEXTURELINE)	6	;#	midi data for creation of notedatafile melodic-or-timed line
	set evv(TEXTUREHF)		7	;#	midi data for creation of notedatafile HFs
	set evv(TEXTUREMOTIF)	8	;#	midi data for creation of notedatafile motifs
	set evv(MIDISEQUENCER)	9	;#	sets in motion getting MIDI data for the sequencer processes
	set evv(SEQUENCEMOTIF)	10	;#	midi data for creation of sequence for sequencer data
	set evv(MIDITOCALC)		11	;#	midi data input to Calculator
	set evv(MIDITOTABED)	12	;#	sets in motion getting MIDI data to Table Editor
	set evv(MIDITOTRANSPOSPARAM)	13	;#	midi transpositions sent to specific parameter box: durations stored elsewhere
	set evv(GETTROFLINE)	14	;#	midi data for creation of pitch line for Gettrof
	set evv(GETTROFTUNING)	15	;#	midi data for creation of HFs for Gettrof
	set evv(GETTROFMOTIF)	16	;#	midi and time data for imposing Motif on segmented data in Voicebox
	set evv(GETTROFTIMING)	17	;#	timing data for ReTiming segmented data in Voicebox

	set evv(TV_TIME)	0
	set evv(TV_CHAN)	1
	set evv(TV_PITCH)	2
	set evv(TV_VEL)		3
	set evv(TV_DUR)		4
	
	set evv(MIDISYNCERROR)	0.05
	set evv(FE_WINSIZ_DFLT)	500.0

	set evv(PSEUDO_PROGS_BASE)	1000

	set	evv(PCR_OUTSHOW)	  0	;#	PITCH CORRECTION PARAMS
	set	evv(PCR_OCTCORR)	  1
	set	evv(PCR_LO)			  2 
	set	evv(PCR_HI)			  3
	set	evv(PCR_NOSIBIL)	  4
	set	evv(PCR_NUJD)		  5
	set	evv(PCR_STARTVAL)	  6
	set	evv(PCR_ENDVAL)		  7
	set	evv(PCR_ORIGSTARTVAL) 8 
	set	evv(PCR_ORIGENDVAL)	  9
	set evv(PCR_ORIGINAL)	 [list 0 0 0 0 0 0 -1 -1 -1 -1]
	set evv(PCR_NULL_NUDGE)  [list -1 -1 -1 -1]

	set evv(VOCALLO_MIDI)	36
	set evv(VOCALHI_MIDI)	84

	set evv(ASSIGN_SEQ)			1		;#	OUTPUT OF PITCH-ASSOCIATION PROCESS
	set evv(ASSIGN_SEQ_OFFSET)	2
	set evv(ASSIGN_FRQBRK)		3
	set evv(ASSIGN_FBRK_OFFSET)	4
	set evv(ASSIGN_FILTDATA)	5
	set evv(ASSIGN_FRQFILTDATA)	6
	set evv(ASSIGN_FRQBRK_GLISS)	  7
	set evv(ASSIGN_FBRK_OFFSET_GLISS) 8
	set evv(ASSIGN_FILTDATA_GLISS)	  9
	set evv(ASSIGN_FRQFILTDATA_GLISS) 10

	set evv(SEQ_TAG)	"_seq"	;# For a MIDI sequence : Added to srcfilename by AssignMotif called from Properties Table Display
	set evv(FILT_TAG)	"_flt"	;# For a varibank filter data file: Added to srcfilename by AssignMotif called from Properties Table Display
	set evv(PCH_TAG)	"_pch"	;# For (tempered) frq brkpnt data file: Added to srcfilename by AssignMotif called from Properties Table Display
	set evv(FREQ_TAG)	"_frq"	;# For untempered frq brkpnt data file: Added to srcfilename by FOF reconstruction process
	set evv(FEX_TAG)	"_fex"	;# Added to srcfilename by "Bulk Pitch Extract" (indicates pitchdata: can be frq, midi, seq and quantised or not)
	set evv(ENV_TAG)	"_env"	;# Added to srcfilename (a loudness breakpoint file, range 0-1)

	set evv(RHYME_DICTIONARY) "rhymdic"
	set evv(NEW_WORDS)	"__new_words"
	set evv(NEW_RHYMES)	"__new_rhymes"
	set evv(REVERSETEXT_SORT) "__reverse_sorted"
	set evv(RHYME_SORT) "__rhymesorted"

	set evv(FOFGPMAX) 16
	set evv(FOFEX_ORNDUR)  0.02
	set evv(FOFEX_STACDUR) 0.02
	set evv(FOFEX_DECEXP)  2.00
	set evv(FOFEX_TW) 2.0
	set evv(FOFEX_TWQ) 0.0

	set evv(QIKEDITLEN) 34
	set evv(SNIPDUR) 0.03

	set evv(SECS_BEFORE_2010) 1262217600
	set evv(YEAR_SECS)	      31536000
	set evv(LEAP_YEAR_SECS)   31622400

	set evv(SECS_PER_DAY) 86400
	set evv(SECS_PER_HOUR) 3600
	set evv(SECS_PER_MIN) 60


	set month_end(0,0) 0
	set month_end(1,0) 2678400
	set month_end(2,0) 5097600
	set month_end(3,0) 7776000
	set month_end(4,0) 10368000
	set month_end(5,0) 13046400
	set month_end(6,0) 15638400
	set month_end(7,0) 18316800
	set month_end(8,0) 20995200
	set month_end(9,0) 23587200
	set month_end(10,0) 26265600
	set month_end(11,0) 28857600
	set month_end(12,0) 31536000

	set month_end(0,1) 0
	set month_end(1,1) 2678400
	set month_end(2,1) 5184000
	set month_end(3,1) 7862400
	set month_end(4,1) 10454400
	set month_end(5,1) 13132800
	set month_end(6,1) 15724800
	set month_end(7,1) 18403200
	set month_end(8,1) 21081600
	set month_end(9,1) 23673600
	set month_end(10,1) 26352000
	set month_end(11,1) 28944000
	set month_end(12,1) 31622400

	;# DATA
	set evv(DISPLAY_NEWK) 0
	set evv(DISPLAY_ABSNEWK) 1
	set evv(DISPLAY_DATA_SPEK) 2
	set evv(LOAD_NAMED_DATA_SPEK) 3
	set evv(DELETE_DATA_SPEK) 4
	set evv(DELETE_NAMED_DATA_SPEK) 5

	;#	TABLE EDITOR

	set evv(PI) 3.141592653589793
	set evv(GOLDEN) 0.618034

	;#	NESS PHYSICAL MODELLING

	set evv(NESS_EXT)		".m"
	set evv(MAX_REORDERED_SEGS)	256

	set evv(MEGABYTE) 1048576
}

#------ Establish the max number of logfiles to store before asking user if wants to cull

proc SetMaxLogCnt {} {
	global firstlog evv
	set fnam [file join $evv(LOGDIR) $evv(LOGSCNT_FILE)$evv(CDP_EXT)]
	if [catch {open $fnam r} fileId] {
		Inf "Cannot open file '$fnam' to read max count of logs before cull request: defaulting to $evv(LOGS_MAX)"
		set evv(THIS_LOGS_MAX) $evv(LOGS_MAX)
	} else {
		gets $fileId val
		set val [string trim $val]
		if {[string length $val] <= 0						 
		|| ![regexp {^[0-9]+$} $val]} {
			Inf "Invalid data on max count of logs before cull request: defaulting."
			set evv(THIS_LOGS_MAX) $evv(LOGS_MAX)
		} elseif {$val <= 0} {						;#	At startup, will be 0
			set firstlog 1
			set evv(THIS_LOGS_MAX) $evv(LOGS_MAX)
		} else {
			set evv(THIS_LOGS_MAX) $val
		}
		catch {close $fileId}
	}
}

#------ Remember CDP-default settings (from Resource Database or built-in environment variables)
#
#	Remember (only) those items which user can alter.
#	In case user wishes to revert to originals!!
#

proc RememberCDPDefaults {} {
	global CDPd evv

	set CDPd(redesign) 			$evv(REDESIGN)
	set CDPd(default_srate) 		$evv(DFLT_SR)

	#	FILE EXTENSIONS AND DIRECTORIES

	set CDPd(sndfile_extension) 	$evv(SNDFILE_EXT)

	#	GENERAL COLORS

	set CDPd(background)			[option get . background {}]
	set CDPd(foreground)			[option get . foreground {}]
	set CDPd(activeBackground)	[option get . activeBackground {}]
	set CDPd(activeForeground)	[option get . activeForeground {}]
	set CDPd(selectColor)			[option get . selectColor {}]
	set CDPd(selectForeground)	[option get . selectForeground {}]
	set CDPd(selectBackground)	[option get . selectBackground {}]
	set CDPd(troughColor)			[option get . troughColor {}]
	set CDPd(disabledForeground)	[option get . disabledForeground {}]
	set CDPd(fnt)				general_fnt

	set CDPd(quit_color) 			$evv(QUIT_COLOR)

	#	PROCESS MENU COLORS

	set CDPd(on_color) 			$evv(ON_COLOR)
	set CDPd(off_color) 			$evv(OFF_COLOR)
	set CDPd(help_color) 			$evv(HELP)
	set CDPd(emphasis) 			$evv(EMPH)
	set CDPd(special) 			$evv(SPECIAL)

	#	GADGET COLORS

	set CDPd(disable_color) 		$evv(DISABLE_COLOR)

	#	TREE COLORS AND FONT

	set CDPd(tree_fnt_style)		$evv(T_FONT_STYLE)
	set CDPd(tree_fnt_sz)		$evv(T_FONT_SIZE)
	set CDPd(tree_fnt_type)		$evv(T_FONT_TYPE)
	set CDPd(tree_deleted_type)	$evv(T_DELETE_TYPE)
	set CDPd(tree_activebkgd) 	$evv(T_ACTIVEBKGD)
	set CDPd(tree_activefgnd) 	$evv(T_ACTIVEFGND)

	#	PROGRESS BAR COLORS

	set CDPd(pbar_endcolor) 		$evv(PBAR_ENDCOLOR)
	set CDPd(pbar_donecolor)  	$evv(PBAR_DONECOLOR)
	set CDPd(pbar_notdonecolor)  	$evv(PBAR_NOTDONECOLOR)

	#	PROCESS TREE DISPLAY COLORS

	set CDPd(neutral_treecolor)	$evv(NEUTRAL_TC)
	set CDPd(sound_treecolor)		$evv(SOUND_TC)
	set CDPd(analysis_treecolor)	$evv(ANALYSIS_TC)
	set CDPd(pitch_treecolor)		$evv(PITCH_TC)
	set CDPd(transpos_treecolor)	$evv(TRANSPOS_TC)
	set CDPd(formant_treecolor)	$evv(FORMANT_TC)
	set CDPd(envelope_treecolor)	$evv(ENVELOPE_TC)
	set CDPd(text_treecolor)		$evv(TEXT_TC)
	set CDPd(mono_treecolor)		$evv(MONO_TC)

	# PROGRAM RUN MESSAGES TEXT-COLORS

	set CDPd(warning_textcolor)	$evv(WARN_COLR)
	set CDPd(error_textcolor)	$evv(ERR_COLR)
	set CDPd(INF_COLR)			$evv(INF_COLR)

	set CDPd(system)			$evv(SYSTEM)
	set CDPd(bitres)			$evv(BITRES)

	set CDPd(fnt_family)		$evv(FONT_FAMILY)
	set CDPd(fnt_sz)			$evv(FONT_SIZE)
}

#------ Restore original CDP values of user-changeable design settings
#

proc RestoreCDPDefaults {} {
	global CDPd evv

	if {![AreYouSure]} {
		return
	}
	if {![string match $evv(SYSTEM) "MAC"]} {
		Block "Restoring the default environment."
	}

	set evv(REDESIGN)			$CDPd(redesign) 			
	set evv(DFLT_SR)		$CDPd(default_srate) 			

	#	FILE EXTENSIONS AND DIRECTORIES

	set evv(SNDFILE_EXT)	$CDPd(sndfile_extension) 	

	#	GENERAL COLORS			

	option clear

	option add *background			$CDPd(background)			
	option add *foreground			$CDPd(foreground)			
	option add *activeBackground	$CDPd(activeBackground)	
	option add *activeForeground	$CDPd(activeForeground)	
	option add *selectColor			$CDPd(selectColor)			
	option add *selectForeground	$CDPd(selectForeground)	
	option add *selectBackground	$CDPd(selectBackground)	
	option add *troughColor			$CDPd(troughColor)		
	option add *disabledForeground	$CDPd(disabledForeground)	
	option add *font				$CDPd(fnt)

	set evv(QUIT_COLOR)				$CDPd(quit_color)

	#	TREE COLORS AND FONT

	set evv(T_FONT_STYLE)	$CDPd(tree_fnt_style)		  
	set evv(T_FONT_SIZE)		$CDPd(tree_fnt_sz)		  
	set evv(T_FONT_TYPE)		$CDPd(tree_fnt_type)		  
	set evv(T_DELETE_TYPE)	$CDPd(tree_deleted_type)		  

	set evv(T_ACTIVEBKGD)	$CDPd(tree_activebkgd) 
	set evv(T_ACTIVEFGND)	$CDPd(tree_activefgnd) 

	#	PROGRESS BAR COLORS		   

	set evv(PBAR_ENDCOLOR)		$CDPd(pbar_endcolor) 
	set evv(PBAR_DONECOLOR)		$CDPd(pbar_donecolor)  
	set evv(PBAR_NOTDONECOLOR)	$CDPd(pbar_notdonecolor)  

	#	PROCESS MENU COLORS

	set evv(ON_COLOR)			$CDPd(on_color)		
	set evv(OFF_COLOR)			$CDPd(off_color)		
	set evv(HELP)			$CDPd(help_color)		
	set evv(EMPH)			$CDPd(emphasis)		
	set evv(SPECIAL)		$CDPd(special)		

	#	GADGET COLORS

	set evv(DISABLE_COLOR)		$CDPd(disable_color)	

	#	PROCESS TREE DISPLAY COLORS

	set evv(NEUTRAL_TC)	$CDPd(neutral_treecolor)	
	set evv(SOUND_TC)	$CDPd(sound_treecolor)		
	set evv(ANALYSIS_TC)	$CDPd(analysis_treecolor)	
	set evv(PITCH_TC)	$CDPd(pitch_treecolor)		
	set evv(TRANSPOS_TC)	$CDPd(transpos_treecolor)	
	set evv(FORMANT_TC)	$CDPd(formant_treecolor)	
	set evv(ENVELOPE_TC)	$CDPd(envelope_treecolor)	
	set evv(TEXT_TC)		$CDPd(text_treecolor)		
	set evv(MONO_TC)		$CDPd(mono_treecolor)		

	# PROGRAM RUN MESSAGES TEXT-COLORS

	set evv(WARN_COLR)	$CDPd(warning_textcolor)	
	set evv(ERR_COLR)	$CDPd(error_textcolor)		
	set evv(INF_COLR)	$CDPd(INF_COLR)		
	set evv(SYSTEM)		$CDPd(system)		
	set evv(BITRES)		$CDPd(bitres)		

	set evv(FONT_FAMILY)		$CDPd(fnt_family)
	set evv(FONT_SIZE)			$CDPd(fnt_sz)

	if {![string match $evv(SYSTEM) "MAC"]} {
	 	UnBlock
	}
}

#------ Read User-defined Environment defaults
#
#	These are users values for the user-accessible environment variables
#	User-accesible resources are loaded from a different file.
#

proc ReadUserEnvironment {fileId} {
	global evv
	set i 0 
	while {[gets $fileId line] >= 0} {
		switch -- $i {
			0  {set evv(REDESIGN) "$line"}
			1  {set evv(DFLT_SR) "$line"}
			2  {set evv(SNDFILE_EXT) "$line"}
			3  {set evv(T_FONT_STYLE)  "$line"}
   			4  {set evv(T_FONT_SIZE)	  "$line"}
   			5  {set evv(T_FONT_TYPE)	  "$line"}
   			6  {set evv(T_DELETE_TYPE) "$line"}
			7  {set evv(T_ACTIVEBKGD)  "$line"}
			8  {set evv(T_ACTIVEFGND)  "$line"}
			9  {set evv(PBAR_ENDCOLOR) "$line"}
			10 {set evv(PBAR_DONECOLOR) "$line"}
			11 {set evv(PBAR_NOTDONECOLOR) "$line"}
			12 {set evv(QUIT_COLOR) "$line"}
			13 {set evv(ON_COLOR) "$line"}
			14 {set evv(OFF_COLOR) "$line"}
			15 {set evv(HELP) "$line"}
			16 {set evv(EMPH) "$line"}
			17 {set evv(SPECIAL) "$line"}
			18 {set evv(DISABLE_COLOR) "$line"}
			19 {set evv(NEUTRAL_TC) "$line"}
			20 {set evv(SOUND_TC) "$line"}
			21 {set evv(ANALYSIS_TC) "$line"}
			22 {set evv(PITCH_TC) "$line"}
			23 {set evv(TRANSPOS_TC) "$line"}
			24 {set evv(FORMANT_TC) "$line"}
			25 {set evv(ENVELOPE_TC) "$line"}
			26 {set evv(TEXT_TC) "$line"}
			27 {set evv(MONO_TC) "$line"}
			28 {set evv(WARN_COLR) "$line"}
			29 {set evv(ERR_COLR) "$line"}
			30 {set evv(INF_COLR) "$line"}
			31 {set evv(SYSTEM) "$line"}
			32 {set evv(BITRES) "$line"}
			33 {set evv(FONT_FAMILY) "$line"}
			34 {set evv(FONT_SIZE) "$line"}
			35 {set evv(OUTOFDATE_LIST) "$line"}
			default {
				ErrShow "WARNING: Too many lines in User environment file"
				return
			}
		}
		incr i
	}
	if {$i != 36} {
		ErrShow "WARNING: Too few lines in User environment file: CDP defaults used for missing items"
	}

	font config userfnt -family $evv(FONT_FAMILY) -size $evv(FONT_SIZE)
	option add *font userfnt
}

#------ Read User-defined System type

proc ReadUserSys {fileId} {
	global evv
	set i 0 
	while {[gets $fileId line] >= 0} {
		switch -- $i {
			0  -
			1  -
			2  -
			3  -
   			4  -
   			5  -
   			6  -
			7  -
			8  -
			9  -
			10 -
			11 -
			12 -
			13 -
			14 -
			15 -
			16 -
			17 -
			18 -
			19 -
			20 -
			21 -
			22 -
			23 -
			24 -
			25 -
			26 -
			27 -
			28 -
			29 -
			30 {}
			31 {set evv(SYSTEM) "$line"}
			32 -
			33 -
			34 -
			35 {}
			default {
				ErrShow "WARNING: Too many lines in User environment file"
				return
			}
		}
		incr i
	}
	if {$i != 36} {
		ErrShow "WARNING: Too few lines in User environment file: CDP defaults used for missing items"
	}
}

#------ Remember user's initial Environment
#
#	Remember the users environment. If it changes, we update user-environment and user-resources files.
#

proc RememberUserEnvironment {} {
	global evv
	global uv

	#	ENABLE OR DISABLE REDESIGN WINDOW

	set uv(redesign)			$evv(REDESIGN)
	set uv(default_srate)		$evv(DFLT_SR)

	#	FILE EXTENSIONS AND DIRECTORIES

	set uv(sndfile_extension)	$evv(SNDFILE_EXT)

	#	TREE ACTIVE COLORS AND FONT

	set uv(tree_fnt_style)	$evv(T_FONT_STYLE)
	set uv(tree_fnt_sz)		$evv(T_FONT_SIZE)
	set uv(tree_fnt_type)		$evv(T_FONT_TYPE)
	set uv(tree_delete_type)	$evv(T_DELETE_TYPE)
	set uv(tree_activebkgd)	$evv(T_ACTIVEBKGD)
	set uv(tree_activefgnd)	$evv(T_ACTIVEFGND)

	#	PROGRESS BAR COLORS		   

	set uv(pbar_endcolor)		$evv(PBAR_ENDCOLOR)
	set uv(pbar_donecolor)		$evv(PBAR_DONECOLOR)
	set uv(pbar_notdonecolor)	$evv(PBAR_NOTDONECOLOR)

	#	GENERAL COLORS

	set uv(background)			[option get . background {}]
	set uv(foreground)			[option get . foreground {}]
	set uv(activeBackground)	[option get . activeBackground {}]
	set uv(activeForeground)	[option get . activeForeground {}]
	set uv(selectColor)		[option get . selectColor {}]
	set uv(selectForeground)	[option get . selectForeground {}]
	set uv(selectBackground)	[option get . selectBackground {}]
	set uv(troughColor)		[option get . troughColor {}]
	set uv(disabledForeground) [option get . disabledForeground {}]

	set uv(quit_color) 	$evv(QUIT_COLOR)

	#	PROCESS MENU COLORS

	set uv(on_color) 		$evv(ON_COLOR)
	set uv(off_color) 		$evv(OFF_COLOR)
	set uv(help_color) 	$evv(HELP)
	set uv(emphasis) 		$evv(EMPH)
	set uv(special) 		$evv(SPECIAL)

	#	GADGET COLORS

	set uv(disable_color) 	$evv(DISABLE_COLOR)

	#	PROCESS TREE DISPLAY COLORS

	set uv(neutral_treecolor)   $evv(NEUTRAL_TC)
	set uv(sound_treecolor) 	 $evv(SOUND_TC)
	set uv(analysis_treecolor)  $evv(ANALYSIS_TC)
	set uv(pitch_treecolor) 	 $evv(PITCH_TC)
	set uv(transpos_treecolor)  $evv(TRANSPOS_TC)
	set uv(formant_treecolor)   $evv(FORMANT_TC)
	set uv(envelope_treecolor)  $evv(ENVELOPE_TC)
	set uv(text_treecolor) 	 $evv(TEXT_TC)
	set uv(mono_treecolor) 	 $evv(MONO_TC)

	# PROGRAM RUN MESSAGES TEXT-COLORS

	set uv(warning_textcolor)	 $evv(WARN_COLR)
	set uv(error_textcolor) 	 $evv(ERR_COLR)
	set uv(INF_COLR) 	 $evv(INF_COLR)

	set uv(system) 	 	$evv(SYSTEM)
	set uv(bitres) 	 	$evv(BITRES)

	set uv(fnt_family)	$evv(FONT_FAMILY)		
	set uv(fnt_sz)	$evv(FONT_SIZE)			
	set uv(ofd_lst)	$evv(OUTOFDATE_LIST)			

	font config userfnt -family $uv(fnt_family) -size $uv(fnt_sz)
}

#------ Restore Environment set by user at start of session

proc RestoreUserEnvironment {with_question} {
	global uv evv

	if {$with_question && ![AreYouSure]} {
		return
	}
	#	ENABLE OR DISABLE REDESIGN WINDOW

	set evv(REDESIGN)			$uv(redesign)			
	set evv(DFLT_SR)		$uv(default_srate)			

	#	FILE EXTENSIONS AND DIRECTORIES

	set evv(SNDFILE_EXT)	$uv(sndfile_extension)	

	#	TREE ACTIVE COLORS AND FONT

	set evv(T_FONT_STYLE)	$uv(tree_fnt_style)
	set evv(T_FONT_SIZE)		$uv(tree_fnt_sz)
	set evv(T_FONT_TYPE)		$uv(tree_fnt_type)
	set evv(T_DELETE_TYPE)	$uv(tree_delete_type)
	set evv(T_ACTIVEBKGD)	$uv(tree_activebkgd)	
	set evv(T_ACTIVEFGND)	$uv(tree_activefgnd)	

	#	PROGRESS BAR COLORS		   

	set evv(PBAR_ENDCOLOR)		$uv(pbar_endcolor)		
	set evv(PBAR_DONECOLOR)		$uv(pbar_donecolor)		
	set evv(PBAR_NOTDONECOLOR)	$uv(pbar_notdonecolor)	

	#	GENERAL COLORS

	option clear

	option add *background			$uv(background)
	option add *foreground			$uv(foreground)
	option add *activeBackground	$uv(activeBackground)
	option add *activeForeground	$uv(activeForeground)
	option add *selectColor			$uv(selectColor)
	option add *selectForeground	$uv(selectForeground)
	option add *selectBackground	$uv(selectBackground)
	option add *troughColor			$uv(troughColor)
	option add *disabledForeground	$uv(disabledForeground)
	option add *font				userfnt

	set evv(QUIT_COLOR)			 	$uv(quit_color)	

	#	PROCESS MENU COLORS

	set evv(ON_COLOR)			 	$uv(on_color)	
	set evv(OFF_COLOR)			 	$uv(off_color)	
	set evv(HELP)			 	$uv(help_color)	
	set evv(EMPH)				$uv(emphasis)	
	set evv(SPECIAL)			$uv(special)	

	#	GADGET COLORS

	set evv(DISABLE_COLOR)		 	$uv(disable_color)	

	#	PROCESS TREE DISPLAY COLORS

	set evv(NEUTRAL_TC)	$uv(neutral_treecolor)   
	set evv(SOUND_TC)	$uv(sound_treecolor) 	 
	set evv(ANALYSIS_TC)	$uv(analysis_treecolor)  
	set evv(PITCH_TC)	$uv(pitch_treecolor) 	 
	set evv(TRANSPOS_TC)	$uv(transpos_treecolor)  
	set evv(FORMANT_TC)	$uv(formant_treecolor)   
	set evv(ENVELOPE_TC)	$uv(envelope_treecolor)  
	set evv(TEXT_TC)		$uv(text_treecolor) 	 
	set evv(MONO_TC)		$uv(mono_treecolor) 	 

	# PROGRAM RUN MESSAGES TEXT-COLORS

	set evv(WARN_COLR)	$uv(warning_textcolor)	 
	set evv(ERR_COLR)	$uv(error_textcolor) 	 
	set evv(INF_COLR)		$uv(INF_COLR) 	 
	set evv(SYSTEM)			$uv(system)
	set evv(BITRES)			$uv(bitres)
	set evv(FONT_FAMILY)	$uv(fnt_family)
	set evv(FONT_SIZE)		$uv(fnt_sz)
	set evv(OUTOFDATE_LIST)	$uv(ofd_lst)
}

#------ Save User-defined Environment & resources to Files, if it has changed

proc SaveUserEnvironmentAndResources {} {
	global fileUserEnvId evv
	global uv user_resource_changed	;#	Also set elsewhere at customize

	set env_saved 0
	set res_saved 1
	if {$user_resource_changed} {
		if [SaveUserEnvironment] {
			set env_saved 1
		}

		if [catch {open $evv(DFLT_TMPFNAME) w} fileId] {
			Inf "Cannot open temporary file to save your new resource settings"
			return
		}					;#	Save user's resources to a temporary file
		set val $uv(background)
		set line "*background: $val"
		puts $fileId "$line"
		set val $uv(foreground)
		set line "*foreground: $val"
		puts $fileId "$line"
		set val $uv(activeBackground)
		set line "*activeBackground: $val"
		puts $fileId "$line"
		set val $uv(activeForeground)
		set line "*activeForeground: $val"
		puts $fileId "$line"
		set val $uv(selectColor)
		set line "*selectColor: $val"
		puts $fileId "$line"
		set val $uv(selectForeground)
		set line "*selectForeground: $val"
		puts $fileId "$line"
		set val $uv(selectBackground)
		set line "*selectBackground: $val"
		puts $fileId "$line"
		set val $uv(troughColor)
		set line "*troughColor: $val"
		puts $fileId "$line"
		set val $uv(disabledForeground)
		set line "*disabledForeground: $val"
		puts $fileId "$line"
  				   ;#	Replace any existing user resources file
		close $fileId
		set fnam [file join $evv(URES_DIR) $evv(USERRES)$evv(CDP_EXT)]

		if [catch {file delete $fnam} zorg] {
 			Inf "Cannot delete existing user resource settings to save new settings"
			set re_saved 0
		} elseif [catch {file rename $evv(DFLT_TMPFNAME) $fnam}] {
 			Inf "Failed to save user resource settings"
			set re_saved 0
		}
	}
	if {$env_saved && $res_saved} {
		set user_resource_changed 0
	}
}

#------ Save User-defined Environment.

proc SaveUserEnvironment {} {
	global fileUserEnvId evv
	global uv ;#	Also set elsewhere at customize

	if [catch {open $evv(DFLT_TMPFNAME) w} fileId] {
		Inf "Cannot open temporary file to save your new environment settings"
		return 0
	}				;#	Save user's environment to a temporary file
	puts $fileId "$uv(redesign)"
	puts $fileId "$uv(default_srate)"
	puts $fileId "$uv(sndfile_extension)"
	puts $fileId "$uv(tree_fnt_style)"
	puts $fileId "$uv(tree_fnt_sz)"
	puts $fileId "$uv(tree_fnt_type)"
	puts $fileId "$uv(tree_delete_type)"
	puts $fileId "$uv(tree_activebkgd)"
	puts $fileId "$uv(tree_activefgnd)"
	puts $fileId "$uv(pbar_endcolor)"
	puts $fileId "$uv(pbar_donecolor)"
	puts $fileId "$uv(pbar_notdonecolor)"
	puts $fileId "$uv(quit_color)"
	puts $fileId "$uv(on_color)"
	puts $fileId "$uv(off_color)"
	puts $fileId "$uv(help_color)"
	puts $fileId "$uv(emphasis)"
	puts $fileId "$uv(special)"
	puts $fileId "$uv(disable_color)"
	puts $fileId "$uv(neutral_treecolor)"
	puts $fileId "$uv(sound_treecolor)"
	puts $fileId "$uv(analysis_treecolor)"
	puts $fileId "$uv(pitch_treecolor)"
	puts $fileId "$uv(transpos_treecolor)"
	puts $fileId "$uv(formant_treecolor)"
	puts $fileId "$uv(envelope_treecolor)"
	puts $fileId "$uv(text_treecolor)"
	puts $fileId "$uv(mono_treecolor)"
	puts $fileId "$uv(warning_textcolor)"
	puts $fileId "$uv(error_textcolor)"
	puts $fileId "$uv(INF_COLR)"
	puts $fileId "$uv(system)"
	puts $fileId "$uv(bitres)"
	puts $fileId "$uv(fnt_family)"
	puts $fileId "$uv(fnt_sz)"
	puts $fileId "$uv(ofd_lst)"
					 ;#	Replace any existing user environment file
	close $fileId
	catch {close $fileUserEnvId}
	set fnam [file join $evv(URES_DIR) $evv(USERENV)$evv(CDP_EXT)]
	if [catch {file delete $fnam} zorg] {
		Inf "Cannot delete CDP environment settings to save user settings"
		return 0
	} elseif [catch {file rename $evv(DFLT_TMPFNAME) $fnam}] {
		Inf "Failed to save user environment settings"
	}
	return 1
}

#------ Size tree display boxes to fit fntsize

proc SetTreeBoxDimensions {} {
	global evv
	set tree_fntsize $evv(T_FONT_SIZE)
	set boxwidth [expr ($evv(T_NAME_WIDTH) - 2) * $tree_fntsize]
	set evv(T_HALFBOXWIDTH)  [expr round($boxwidth / 2)]
	incr tree_fntsize 6
	set evv(T_HALFBOXHEIGHT) $tree_fntsize

	set  evv(T_CELLWIDTH)	  $boxwidth
	set  evv(T_HALF_CELLWIDTH) $evv(T_HALFBOXWIDTH)
	set  evv(T_CELLHEIGHT)	  $evv(T_HALFBOXHEIGHT)
	incr evv(T_CELLHEIGHT)	  $evv(T_CELLHEIGHT)
	incr evv(T_CELLHEIGHT)	  $evv(T_CELLHEIGHT)
}

#------ Set dimensions of x-axis text-display on brktable-creation page

proc SetBrkTextConstants {} {
	global uv brk bkc brk_can brkxfnt evv

	set bkc(halfwidth) [expr int($evv(XWIDTH) / 2)]		;#	Half width of drawing canvas on brktable display
	incr bkc(halfwidth) $evv(BWIDTH)						;#	On outer canvas, so adjust for borderwidth

	set bkc(ztimetextwidth) [string length $evv(ZEROTIME)]	;#	Width of time-zero text on brktable display
	set bkc(timetextwidth) [string length $evv(TIME)]		;#	Width of "time"-word on brktable display

	set  fntsize $uv(fnt_sz)

	set  bkc(ytext_top) [expr $evv(BWIDTH) - $fntsize - 1]	;#	Position of text ABOVE display

	set  bkc(ztimetextwidth) [expr int($bkc(ztimetextwidth) * $fntsize)]
	set  textwidth [expr int($bkc(timetextwidth) * $fntsize)]
	incr textwidth [expr int($evv(XTEXT_SPACER) * 2)]	;#	Space on either side of "time" text
	set  bkc(timetextwidth) $textwidth

	set  bkc(effective_yheight) [expr int($evv(YHEIGHT) + $evv(PWIDTH))]	 ;#Allow for width of points
	set  bkc(effective_xwidth)  [expr int($evv(XWIDTH)  + $evv(PWIDTH))]	 ;#Allow for width of points

 	set  bkc(mouse_yheight) $evv(YHEIGHT)
 	set  bkc(mouse_xwidth)  $evv(XWIDTH)
	set  bkc(effective_mouse_yheight) $bkc(effective_yheight)
	set  bkc(effective_mouse_xwidth)  $bkc(effective_xwidth)
	incr bkc(effective_mouse_yheight) $evv(BWIDTH)
	incr bkc(effective_mouse_xwidth)  $evv(BWIDTH)
	incr bkc(mouse_yheight) 		  $evv(BWIDTH)
	incr bkc(mouse_xwidth)  		  $evv(BWIDTH)

	set  bkc(actual_xwidth_end)  [expr int($bkc(effective_xwidth) + $evv(BWIDTH))]

	set  bkc(text_yposition) $evv(BWIDTH)		 	 ;#	offset text-yposition by width of border above display
	incr bkc(text_yposition) $bkc(effective_yheight) ;#	offset text-yposition by height of display, measured from top
# MARCH 7 2005
	set bkc(timemarktop) $bkc(text_yposition)
	incr bkc(text_yposition) $evv(BRKOFFSET)		 ;#	offset text-yposition by text-offset from border
# MARCH 7 2005
	set bkc(timemarkbot) $bkc(text_yposition)
	incr bkc(text_yposition) $evv(BRKOFFSET)		 ;#	offset text-yposition by text-offset from border
	incr bkc(text_yposition) $fntsize				 ;#	offset text-yposition by font height [??? halftext height ????]

	set  bkc(bottomedge) [expr int($evv(BWIDTH) + $evv(YHEIGHT))] ;#	bottom edge point display, relative to outer-canvas

	set  bkc(zerotext_xposition) [expr int($evv(BWIDTH) + $bkc(effective_xwidth) + $evv(BRKOFFSET))]

	set  max_xwidth $evv(MAX_XCHAR)				 ;#	max width of numeric text to left of brktable graph
	incr max_xwidth 2							 ;#	Add a space for clarity of display and space for minus-sign
	set  k [string length $evv(VALUE)]			 ;#	width of "value" string
	incr k										 ;#	Add a space ditto
	if {$k > $max_xwidth} {
		set  max_xwidth $k
	}
	set  bkc(xfntsize) [expr int($evv(BWIDTH) / $max_xwidth)]
												 ;#	Calculate allowable size of font
	if {$bkc(xfntsize) > $fntsize} {
		set bkc(xfntsize) $fntsize
	}
	font create brkxfnt -family $evv(T_FONT_STYLE) -size $bkc(xfntsize) -slant $evv(T_FONT_TYPE)

#FUDGE FACTOR 4 : CHECK OK WITH LONGER VALUES
	set  bkc(rangetext_xoffset) [expr $bkc(xfntsize) * 4]	;#	Offset texts from edge of canvas
	set  brktext_yoffset [expr int($bkc(xfntsize) / 2)] 	;#	Allow for fntsize
															;#	y-Position of text showing bottom-of-range value
	set  bkc(text_rangebot) [expr int($evv(BWIDTH) + $evv(YHEIGHT) - $brktext_yoffset)]
															;#	y-Position of text showing top-of-range value
	set  bkc(text_rangetop) [expr int($evv(BWIDTH) + $brktext_yoffset)]
	set  bkc(rangetext) [expr int($evv(YHEIGHT) / 2)]
	incr bkc(rangetext) $evv(BWIDTH)						;#	y-Position of text "Value"
	set  bkc(rangetextmax) [expr pow(10,$evv(MAX_XCHAR))]	;#	Maximum text-displayable top-of-range value
	set  bkc(rangetextmin) -$bkc(rangetextmax)				;#	Minimum text-displayable bottom-of-range value

	set  bkc(height) [expr int($bkc(effective_yheight) + $evv(BWIDTH) + $evv(BWIDTH))]
	set  bkc(width)  [expr int($bkc(effective_xwidth) + $evv(BWIDTH) + $evv(BWIDTH))]

	set  bkc(rectx1) [expr int($evv(BWIDTH) -1 )]			;#	Create a slightly large (by 1 pixel) rectangle
	set  bkc(recty1) [expr int($evv(BWIDTH) - 1)]			;#	To enclose the inner canvas
	set  bkc(rectx2) [expr int($evv(BWIDTH) + $bkc(effective_xwidth) + 1)]
	set  bkc(recty2) [expr int($evv(BWIDTH) + $bkc(effective_yheight) + 1)]
}

#------ Establish desired format of main menus
#
#	This should be done ONCE, at workspace setup
#	These commands determine 
#	(a)	In what order the menus appear
#	(b)	which programs appear on which menus
#	Menus will be accessed only from 0 up to (& including) 'maxmenuno'
#	All menus used must be declared as global, here and in 'Dlg_Process_and_Ins_Menus'
#
#	MARCH 2002: modified to display only RELEASED CDP processes

proc Preset_Menu_Format {} {
	global cdpmenu cdpmenulist lastpmask prg evv
	global snack_enabled

				   #MENUNAME : TYPE
	set cdpmenu(0)  {"EDIT" "Sound processes"}
	set cdpmenu(1)  {"DISTORT" "Sound processes"}
	set cdpmenu(2)  {"EXTEND" "Sound processes"}
	set cdpmenu(3)  {"TEXTURE" "Sound processes"}
	set cdpmenu(4)  {"GRAIN" "Sound processes"}
	set cdpmenu(5)  {"ENVELOPE" "Sound processes"}
	set cdpmenu(6)  {"MIX" "Sound processes"}
	set cdpmenu(7)  {"FILTER" "Sound processes"}
	set cdpmenu(8)  {"LOUDNESS" "Sound processes"}
	set cdpmenu(9)  {"SPACE" "Sound processes"}
	set cdpmenu(10) {"PITCH:SPEED" "Sound processes"}
	set cdpmenu(11) {"REVERB:ECHO" "Sound processes"}
	set cdpmenu(12) {"CHANNELS" "Sound processes"}
	set evv(CHANS_MENU) 12
	set cdpmenu(13) {"BRASSAGE" "Sound processes"}
	set cdpmenu(14) {"RADICAL" "Sound processes"}
	set cdpmenu(15) {"SYNTHESIS" "Sound processes"}
	set cdpmenu(16) {"FOFS" "Sound processes"}
	set cdpmenu(17) {"MULTICHAN" "Sound processes"}
	set cdpmenu(18) {"RHYTHM" "Sound processes"}
	set cdpmenu(19) {"PVOC" "Sound to Spectrum"}
	set evv(PVOC_MENU) 19
	set cdpmenu(20) {"SIMPLE" "Spectral processes"}
	set cdpmenu(21) {"STRETCH" "Spectral processes"}
	set cdpmenu(22) {"HIGHLIGHT" "Spectral processes"}
	set cdpmenu(23) {"FOCUS" "Spectral processes"}
	set cdpmenu(24) {"BLUR" "Spectral processes"}
	set cdpmenu(25) {"FORMANTS" "Spectral processes"}
	set cdpmenu(26) {"STRANGE" "Spectral processes"}
	set cdpmenu(27) {"PITCH:HARMONY" "Spectral processes"}
	set cdpmenu(28) {"REPITCH" "Spectral processes"}
	set cdpmenu(29) {"COMBINE" "Spectral processes"}
	set cdpmenu(30) {"MORPH" "Spectral processes"}
	set cdpmenu(31) {"SOUND INFO" "Utilities"}
	set cdpmenu(32) {"SPECTRAL INFO" "Utilities"}
	set cdpmenu(33) {"PITCH INFO" "Utilities"}
	set cdpmenu(34) {"HOUSEKEEP" "Utilities"}
	set cdpmenu(35) {"HARMONIC FLD" "Structure"}
	set cdpmenu(36) {"DATA CREATE" "Structure"}
	set cdpmenu(37) {"VOICEBOX" "Speech"}

	set evv(MAXMENUNO) 38

				   #ASSOCIATED PROCESSES
	if {$snack_enabled} {
		set cdpmenulist(0) [SetCdpMenulist 206 312 456 207 208 96 455 1000 397 398 402 209 210 211 325 212 375 282 448 251 1001 213 333 338 295 296 252 253 393 319 332 370]
	} else {
		set cdpmenulist(0) [SetCdpMenulist 206 312 456 207 208 96 455 209 210 211 325 212 282 448 251 213 333 338 295 296 252 253 393 319 332 370]
	}
	set cdpmenulist(1)  [SetCdpMenulist 103 294 100 113 106 102 116 108 107 117 112 105 104 118 318 111 349 340 114 101 109 110 115 452 453 478 488 496 503]
	set cdpmenulist(2)  [SetCdpMenulist 119 378 433 120 121 122 428 429 435 339 123 255 323 331 1004 481]
	set cdpmenulist(3)  [SetCdpMenulist 124 125 126 127 128 129 130 131 132 133 134 135 136 137 374 417]
	set cdpmenulist(4)  [SetCdpMenulist 138 347 139 140 141 142 143 144 145 146 147 148 149 345 351 352 368]
	set cdpmenulist(5)  [SetCdpMenulist 150 343 151 303 152 315 153 155 156 163 164 165 166 167 168 157 158 371 159 160 161 162 400 1002 154 320 369 443 484]
	set cdpmenulist(6)  [SetCdpMenulist 169 317 98 311 170 172 337 173 174 183 328 308 324 336 179 180 175 176 177 178 326 181 182]
	set cdpmenulist(7)  [SetCdpMenulist 185 186 187 188 189 190 191 348 192 193 194 356 357 358 359 427]
	set cdpmenulist(8)  [SetCdpMenulist 195]
	set cdpmenulist(9)  [SetCdpMenulist 196 316 254 329 399 404 405 406 407 409 410 411 412 413 414 460 461 459 497]
	set cdpmenulist(10) [SetCdpMenulist 197]
	set cdpmenulist(11) [SetCdpMenulist 198 322 353 354 355 401 426]
	set cdpmenulist(12) [SetCdpMenulist 215 171 362 447 90 451]
	set cdpmenulist(13) [SetCdpMenulist 199 200]
	set cdpmenulist(14) [SetCdpMenulist 201 313 327 415 416 421 436 437 454 462 463 465 466 467 468 469 471 472 473 474 475 476 477 482]
	set cdpmenulist(15) [SetCdpMenulist 237 238 239 293 330 97 309 403 423 438 439 440 441 442 470 479]
	set cdpmenulist(16) [SetCdpMenulist 259 260 261 262 270 266 277 281 278 279 267 268 271 272 273 284 274 275 276 366 367 480]
	set cdpmenulist(17) [SetCdpMenulist 256 379 283 382 373 91 93 94 287 95 383 380]
	set cdpmenulist(18) [SetCdpMenulist 321 344 372 376 418 419 420]
	set cdpmenulist(19) [SetCdpMenulist 202 203 204]
	set cdpmenulist(20) [SetCdpMenulist 1 2 3 4 360 361 280 5 6 7 257]
	set cdpmenulist(21) [SetCdpMenulist 8 9 1003 504]
	set cdpmenulist(22) [SetCdpMenulist 17 314 18 19 20 21 22 23 365]
	set cdpmenulist(23) [SetCdpMenulist 24 392 25 26 27 28 248 29 434]
	set cdpmenulist(24) [SetCdpMenulist 30 31 32 33 34 35 36 37 38 39 395 431 432 498 499]
	set cdpmenulist(25) [SetCdpMenulist 64 65 66 67 68 263 264 500]
	set cdpmenulist(26) [SetCdpMenulist 40 41 42 44 394 449 458]
	set cdpmenulist(27) [SetCdpMenulist 10 11 12 13 396 14 15 16]
	set cdpmenulist(28) [SetCdpMenulist 62 63 450 48 92 309 342 258 364 53 50 51 52 54 55 56 57 58 60 61 59 310 299 302 300 301 298 305]
	set cdpmenulist(29) [SetCdpMenulist 69 265 304 70 71 72 73 74 75 391 408]
	set cdpmenulist(30) [SetCdpMenulist 45 46 47 286 424 425]
	set cdpmenulist(31) [SetCdpMenulist 223 224 225 226 227 228 229 230 99 297 231 232 233 234 235 350 381]
	set cdpmenulist(32) [SetCdpMenulist 76 77 78 79 80 81 82 83 285]
	set cdpmenulist(33) [SetCdpMenulist 84 85 86 87 88]
	set cdpmenulist(34) [SetCdpMenulist 214 216 269 341 346 307 217 218 219 220 422]
	set cdpmenulist(35) [SetCdpMenulist 289 290 291 292]
	set cdpmenulist(36) [SetCdpMenulist 334 335]
	set cdpmenulist(37) [SetCdpMenulist 483]
 	set n 0
					;# forms full menu descrip i.e. MENUNAME : TYPE : ASSOCIATED PROCESSES
					;# EXCLUDING PROGS NOT ON USERS SYSTEM

	EstablishMenuInverse
	while {$n < $evv(MAXMENUNO)} {
		foreach j $cdpmenulist($n) {
			set prgname [lindex $prg($j) 0]
			if {![file exists [file join $evv(CDPROGRAM_DIR) $prgname$evv(EXEC)]]} {
				continue
			}
			lappend cdpmenu($n) $j
		}
		incr n
	}
	set evv(MENU_MAXNAME)		13			;#	Current maxbutton size (max string length of menu name, above)
	set evv(MAX_PROGNAMEWIDTH)	14			;#	Widest item on any menu
	set	lastpmask ""
}

##############################################
# ESTABLISH CDP PROGRAM- & PROGRAM-MENU DATA #
##############################################

#------ Establish all information about programs, with list no. corresponding to program no.
#
#	This should be done ONCE, at workspace setup
#

proc SetupProgramMenus {} {
	global prg evv snack_enabled released gate_version modify_version specnu_version
		#	UMBRELLA_PROG	PROGNAME-FOR-MENUS 	  MODECNT		MODENAMES-FOR-MENUS
	set prg(1)  {"spec"	 	 "gain"			 		0}
	set prg(2)  {"spec"	 	 "gate"					0}
	set prg(3)  {"spec"	 	 "bare partials"		0}
	set prg(4)  {"spec"	 	 "clean" 				4 "from specified time" "anywhere" "above specified frq" \
										 						"by comparison method"}
	set prg(5)  {"spec"		 "cut" 					0}
	set prg(6)  {"spec"		 "grab window" 			0}
	set prg(7)  {"spec"	 	 "magnify window"		0}
	set prg(8)  {"stretch"   "spectrum"				2 "above given frq" "below given frq"}
	set prg(9)  {"stretch"	 "time"  				2 "do time_stretch" "get output length"}
	set prg(10) {"pitch"     "alternate harmonics"	2 "delete odd harmonics" "delete even harmonics"}
	set prg(11) {"pitch"     "octave shift"	  		3 "up" "down" "down with bass boost"}
	set prg(12) {"pitch"	 "pitch shift"			6 "8va shift up, above" "8va shift down, below" "8va shift up and down" \
																"shift above frq divide" "shift below frq divide" "shift above and below"}
	set prg(13) {"pitch"	 "tune spectrum"		2 "tunings as frqs" "tunings as midi"}
	set prg(14) {"pitch"	 "choose partials"		5 "harmonic series" "octaves" "odd harmonics only" \
																"linear frq steps" "displaced harmonics" }
	set prg(15) {"pitch"	 "chord"				0}
	set prg(16) {"pitch"	 "chord (keep fmnts)"	0}
	set prg(17) {"hilite" 	 "filter"	  			12 "high pass" "high pass normalised" "low pass" \
																"low pass normalised" "high pass with gain" \
																"low pass with gain" "bandpass" "bandpass normalised" \
																"notch" "notch normalised" "bandpass with gain" \
																"notch with gain"}
	set prg(18) {"hilite"	 "graphic eq"			2 "standard bandwidth" "various bandwidths"}
	set prg(19) {"hilite"	 "bands"				0}
	set prg(20) {"hilite"	 "arpeggiate"			8 "on" "boost" "boost below" "boost above" "on below" \
																"on above" "once below" "once above"}
	set prg(21) {"hilite"	 "pluck"				0}
	set prg(22) {"hilite"	 "tracery"				4 "trace all" "trace above frq" "trace below frq" \
																"trace between frqs"}
	set prg(23) {"hilite"	 "blur & trace"			0}
	set prg(24) {"focus"	 "accumulate"	  		0}
	set prg(25) {"focus" 	 "exaggerate"	  		0}
	set prg(26) {"focus" 	 "focus"	  			0}
	set prg(27) {"focus" 	 "fold in"  			0}
	set prg(28) {"focus" 	 "freeze"	  			3 "amplitudes" "frequencies" "amps & frqs"}
	set prg(29) {"focus" 	 "step through"	  		0}
	set prg(30) {"blur"	 	 "average"  			0}
	set prg(31) {"blur"		 "blur"	  				0}
	set prg(32) {"blur"		 "supress"				0}
	set prg(33) {"blur"		 "chorus"	  			7 "scatter amps" "scatter frqs" "scatter frqs up" \
																"scatter frqs down" "scatter amps & frqs" \
																"scatter amps,& frqs up" "scatter amps,& frqs down"}
	set prg(34) {"blur"	 	 "drunkwalk"			0}
	set prg(35) {"blur"	 	 "shuffle"  			0}
	set prg(36) {"blur"	 	 "weave"  				0}
	set prg(37) {"blur"	 	 "noise"	  			0}
	set prg(38) {"blur"	 	 "scatter"				0}
	set prg(39) {"blur"	 	 "spread"	  			0}
	set prg(40) {"strange" 	 "linear shift"			5 "shift all" "shift above frq" "shift below frq" \
															"shift between frqs" "shift outside frqs"}
	set prg(41) {"strange"	 "inner glissando"	  	3 "shepard tone glis" "inharmonic glis" "self glis"}
	set prg(42) {"strange" 	 "waver"	  			2 "standard" "user specified"}
	set prg(43) {"strange" 	 "warp"	  				0}
	set prg(44) {"strange" 	 "invert"	  			2 "standard" "retain src envelope"}
	set prg(45) {"morph" 	 "glide"	  			0}
	set prg(46) {"morph" 	 "bridge"	  			6 "standard" "outlevel follows minimum" \
															"outlevel follows file1" "outlevel follows file2" \
															"outlevel moves from 1 to 2" "outlevel moves from 2 to 1"}
	set prg(47) {"morph" 	 "morph"	  			2 "linear or curved" "cosinusoidal"}
	set prg(48) {"repitch"	 "extract pitch from analysis data"	2 "to binary file" "to textfile"}
	set prg(49) {"repitch"	 "track pitch"			2 "to binary file" "to textfile"}
	set prg(50) {"repitch"	 "approximate pitch"	2 "pitch data out" "transposition data out"}
	set prg(51) {"repitch"	 "exaggerate contour"	6 "range: pitch out" "range: transposition out" \
															"contour: pitch out" "contour: transpos out" \
															"range & contour: pitch out" \
															"range & contour: transpos out"}
	set prg(52) {"repitch"	 "invert pitch contour" 2 "pitch data out" "transposition data out"}
	set prg(53) {"repitch"	 "quantise pitch"		2 "pitch data out" "transposition data out"}
	set prg(54) {"repitch"	 "randomise pitch"		2 "pitch data out" "transposition data out"}
	set prg(55) {"repitch"	 "smooth pitch contour"	2 "pitch data out" "transposition data out"}
	set prg(56) {"repitch"	 "shift pitch"			2 "shift by ratio" "shift by semitones"}
	set prg(57) {"repitch"	 "vibrato pitch data"	2 "pitch data out" "transposition data out"}
	set prg(58) {"repitch"	 "cut pitchfile"		3 "from starttime" "to endtime" "between times"}
	set prg(59) {"repitch"	 "EDIT PITCHFILE (not recycled files!)"	    0}
	set prg(60) {"repitch"	 "repitch pitchdata"	3 "pitch+pitch to transpos" "pitch+transpos to pitch" \
															"transpos+transpos to transpos"}
	set prg(61) {"repitch"   "repitch (to textfile)" 3 "pitch+pitch to transpos" "pitch+transpos to pitch" \
															"transpos+transpos to transpos"}
	set prg(62) {"repitch"   "transpose"		 	4 "transpos as ratio" "transpos in octaves" \
															"transpos in semitones" "transpos as binary data"}
	set prg(63) {"repitch" 	 "transpose(keep fmnts)" 4 "transpos as ratio" "transpos in octaves" \
															"transpos in semitones" "transpos as binary data"}
	set prg(64) {"formants"	 "extract"		 		0}
	set prg(65) {"formants"	 "impose"  				2 "replace formants" "superimpose formants"}
	set prg(66) {"formants"	 "vocode"	  			0}
	set prg(67) {"formants"	 "view"     			0}
	set prg(68) {"formants"	 "get & view" 			0}
	set prg(69) {"combine"	 "add formants to pitch" 0}
	set prg(70) {"combine"	 "sum"					0}
	set prg(71) {"combine"	 "difference" 			0}
	set prg(72) {"combine"	 "interleave"			0}
	set prg(73) {"combine"	 "windowwise max"		0}
	set prg(74) {"combine"	 "mean" 				8 "mean amp & pitch" "mean amp & frq" \
																"amp file1: mean pich" "amp file1: mean frq" \
																"amp file2: mean pich" "amp file2: mean frq" \
																"max amp: mean pitch" "max amp: mean frq"}
	set prg(75) {"combine"	 "cross channels"		0}
	set prg(76) {"specinfo"	 "window count" 		0}
	set prg(77) {"specinfo"	 "channel"  			0}
	set prg(78) {"specinfo"	 "get frequency" 		0}
	set prg(79) {"specinfo"	 "view level as pseudo-sndfile"	0}
	set prg(80) {"specinfo"	 "print octbands to file"       0}
	set prg(81) {"specinfo"	 "print energy centres to file" 0}
	set prg(82) {"specinfo"	 "print freq peaks to file"		4 "order by frq & time" "order by loudness & time" \
																"order by frq (untimed)" "order by loudness (untimed)"}
	set prg(83) {"specinfo"	 "print analysis data to file only" 0}
	set prg(84) {"pitchinfo" "display info on pitchfile"	0}
	set prg(85) {"pitchinfo" "check for pitch zeros" 0}
	set prg(86) {"pitchinfo" "pitch view as psuedo-sndfile"	2 "see pitch" "see transposition"}
	set prg(87) {"pitchinfo" "pitch to testtone spectrum"	0}
	set prg(88) {"pitchinfo" "print pitch data to file only"	0}
	if {[info exists released(mton)]} {
		set prg(90) {"mton" "mono to multichannel"	 0 }
	}
	if {[info exists released(flutter)]} {
		set prg(91) {"flutter" "multichannel flutter"	 0 }
	}
	if {[info exists released(peak)]} {
		set prg(92) {"peak"	 "extract peaks from analysis data"	4 "list time-varying peaks" "stream max no of peaks" "stream most prominent peaks" "output averaged peaks"}
	}
	if {[info exists released(mchshred)]} {
		set prg(93) {"mchshred"	 "multichannel shred" 2 "shred mono file to multichannel" "shred multichannel file"}
	}
	if {[info exists released(mchzig)]} {
		set prg(94) {"mchzig"	 "multichannel zigzag" 2 "random" "user specified"}
	}
	if {[info exists released(mchstereo)]} {
		set prg(95) {"mchstereo" "position stereos in multichannel"	 0 }
	}
	set prg(96) {"sfedit"	 "cutout many at zero-crossings" 2 "time in seconds" "time as sample count"}
	set prg(97) {"synth"	 "chord"				2 "midi values" "frq values"}
	set prg(98) {"submix"	 "balance between 2 sounds"		0}
	set prg(99)  {"sndinfo"	 "maximum sample in timerange" 	0}

	set prg(100) {"distort"	 "cyclecnt" 			0}
	set prg(101) {"distort"	 "reshape"			 	8 "fixed level square" "square" "fixed level triangle" \
																"triangle" "invert halfcycles" "click" "sine" \
																"exaggerate contour"}
	set prg(102) {"distort"	 "envelope"    		 	4 "rising" "falling" "troughed" "user defined"}
	set prg(103) {"distort"	 "average"     		 	0}
	set prg(104) {"distort"	 "omit"        		 	0}
	set prg(105) {"distort"  "multiply"    		 	0}
	set prg(106) {"distort"	 "divide"    		 	0}
	set prg(107) {"distort"  "harmonic"    		 	0}
	set prg(108) {"distort"	 "fractal"     		 	0}
	set prg(109) {"distort"	 "reverse"     		 	0}
	set prg(110) {"distort"	 "shuffle"     		 	0}
	set prg(111) {"distort"	 "repeat"      		 	0}
	set prg(112) {"distort"  "interpolate" 			0}
	set prg(113) {"distort"	 "delete"      		 	3 "in given order" "retain loudest" "delete weakest"}
	set prg(114) {"distort"	 "replace"     		 	0}
	set prg(115) {"distort"  "telescope"   			0}
	set prg(116) {"distort"	 "filter"      		 	3 "high pass" "low pass" "band pass"}
	set prg(117) {"distort"  "interact"    		 	2 "interleave" "resize"}
	set prg(118) {"distort"	 "pitch"       		 	0}
	set prg(119) {"extend"	 "zigzag"  	 		 	2 "random" "user specified"}
	set prg(120) {"extend"	 "loop"	  	 		 	3 "loop advances to end" "give output duration" \
																"give loop repetitions"}
	set prg(121) {"extend"	 "scramble"	 		 	2 "completely random" "scramble src:then again.."}
	set prg(122) {"extend"	 "iterate"	 		 	2 "give duration" "give count"}
	set prg(123) {"extend"	 "drunkwalk"	 		2 "completely drunk" "sober moments"}
	set prg(124) {"texture"	 "simple" 	 		 	5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(125) {"texture"	 "of groups"	 		5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(126) {"texture"  "decorated"	 		5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(127) {"texture"  "pre-decorations"   	5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(128) {"texture"  "post-decorations"  	5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(129) {"texture"	 "ornamented" 	 		5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(130) {"texture"  "pre-ornate"   		5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(131) {"texture"  "post-ornate"  		5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(132) {"texture"	 "of motifs"  			5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(133) {"texture"  "motifs in hf" 		4 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets"}
	set prg(134) {"texture"	 "timed"			 	5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(135) {"texture"  "timed groups" 		5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(136) {"texture"	 "timed motifs"			5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	set prg(137) {"texture"  "timed mtfs in hf"		4 "over harmonic field" "over harmonic fields" \
																"over harmonic set" "over harmonic sets"}
	set prg(138) {"grain"	 "count"	    		0}
	set prg(139) {"grain"	 "omit" 	    		0}
	set prg(140) {"grain"	 "duplicate"			0}
	set prg(141) {"grain"	 "reorder" 				0}
	set prg(142) {"grain"	 "repitch"				2 "no grain repeats" "repeat each grain"}
	set prg(143) {"grain"	 "rerhythm"				2 "no grain repeats" "repeat each grain"}
	set prg(144) {"grain"	 "remotif"				2 "no grain repeats" "repeat each grain"}
	set prg(145) {"grain"	 "timewarp"				0}
	set prg(146) {"grain"	 "get"					0}
	set prg(147) {"grain"	 "position"				0}
	set prg(148) {"grain"	 "align"				0}
	set prg(149) {"grain"	 "reverse" 				0}
	set prg(150) {"envel"	 "create"				2 "binary output" "textfile output"}
	set prg(151) {"envel"	 "extract"			 	3 "binary output" "textfile output" "viewable pseudo-sndfile"}
	set prg(152) {"envel"	 "impose"			 	4 "env from other sndfile" "env in binary file" \
															"env in textfile" "env in db textfile"}
	set prg(153) {"envel"	 "replace"				4 "env from other sndfile" "env in binary file" \
															"env in textfile" "env in db textfile"}
	set prg(154) {"envel"	 "warp envelope of sndfile" 15 "normalise" "time reverse" "exaggerate" "attenuate" \
															"lift all" "time-stretch" "flatten" "gate" "invert" \
															"limit" "corrugate" "expand" "trigger bursts" \
															"to ceiling" "ducked" "peak count"}
	set prg(155) {"envel"	 "reshape binary envelope" 15 "normalise" "time reverse" "exaggerate" "attenuate" \
															"lift all" "time-stretch" "flatten" "gate" "invert" \
															"limit" "corrugate" "expand" "trigger bursts" \
															"to ceiling" "ducked" "peak count"}
	set prg(156) {"envel"	 "replot textfile envelope" 15 "normalise" "time reverse" "exaggerate" "attenuate" \
															"lift all" "time-stretch" "flatten" "gate" "invert" \
															"limit" "corrugate" "expand" "trigger bursts" \
															"to ceiling" "ducked" "peak count"}
	set prg(157) {"envel"	 "dovetailing"		 	2 "standard" "double strength"}
	set prg(158) {"envel"	 "curtailing"		 	6 "give start & end of fade" "give start & dur of fade" \
													 		"give start of fade-to-end" \
											   				"give start & end of fade : double strength" \
											   				"give start & dur of fade : double strength" \
															"give start of fade-to-end: double strength"}
	set prg(159) {"envel"	 "swell"			 	0}
	set prg(160) {"envel"	 "attack"			 	4 "where gate exceeded" "near time given" \
																"at exact time given" "at max level in file"}
	set prg(161) {"envel"	 "pluck"				0}
	set prg(162) {"envel"	 "tremolo"			 	2 "frqwise" "pitchwise"}
	set prg(163) {"envel"	 "convert binary to text"		 	0}
	set prg(164) {"envel"	 "convert binary to text in dB"	 	0}
	set prg(165) {"envel"	 "convert text to binary"		 	0}
	set prg(166) {"envel"	 "convert dB-text to binary"	 	0}
	set prg(167) {"envel"	 "convert dB text to gain text"	 	0}
	set prg(168) {"envel"	 "convert gain text to dB text"	 	0}
	set prg(169) {"submix"	 "merge two sounds"		0}
	set prg(170) {"submix"	 "crossfade"	 		2 "linear" "cosinusoidal"}
	set prg(171) {"submix"	 "merge channels" 		0}
	set prg(172) {"submix"	 "inbetweening" 		2 "automatic" "give mix ratios"}
	set prg(173) {"submix"	 "MIX FROM MIXFILE"	 	0}
	set prg(174) {"submix"	 "get level in mixfile"	3 "maximum level" "clipping times" "maxlevel & cliptimes"}
	set prg(175) {"submix"	 "attenuate mixfile"	0}
	set prg(176) {"submix"	 "shuffle mixfile" 	 	7 "duplicate lines" "reverse order filenames" \
															"scatter order filenames" "first filename to all" \
															"omit lines" "omit alternate lines" \
															"dupl lines, new filename"}
	set prg(177) {"submix"	 "timewarp mixfile"		16 "sort entry times" "reverse timing pattern" \
															"reverse timing & names" "freeze timegaps" \
															"freeze timegaps & names" "scatter entry times" \
															"shuffle up entry times" "add to timegaps" \
															"create timegap 1" "create timegap 2" \
															"create timegap 3" "create timegap 4" \
															"enlarge timegap 1" "enlarge timegap 2" \
															"enlarge timegap 3" "enlarge timegap 4"}
	set prg(178) {"submix"  "spacewarp mixfile"		8 "fix position" "narrow" \
															"sequence leftwards" "sequence rightwards" \
															"scatter" "scatter alternating" \
															"twist whole mix" "twist a line"}
	set prg(179) {"submix"	"sync sounds in mixfile" 3 "at midtimes" "at endtimes" "at start"}
	set prg(180) {"submix"  "sync attacks in mixfile" 0}
	set prg(181) {"submix"	 "test mixfile"		 	0}
	set prg(182) {"submix"	 "mixfile format" 	 	0}
	set prg(183) {"submix"	 "create a mixfile"	 	3 "superimposed" "end to end" "different channels"}
	set prg(184) {"submix"	 "variable"	 		 	0}
	set prg(185) {"filter"	 "fixed"	   	 	 	3 "boost-or-cut below frq" "boost-or-cut above frq" \
															"boost-or-cut around frq"}
	set prg(186) {"filter"	 "lopass/hipass" 	 	2 "bands as frq (hz)" "bands as midi"}
	set prg(187) {"filter"	 "variable"	 		 	4 "notch" "band pass" "low pass" "high pass"}
	set prg(188) {"filter"	 "bank"	 	 		 	6 "harmonics" "alternate harmonics" "subharmonics" \
															"harmonics with offset" "fixed number of bands" \
															"fixed interval between"}
	set prg(189) {"filter"	 "bank frqs" 			6 "harmonics" "alternate harmonics" "subharmonics" \
															"harmonics with offset" "fixed number of bands" \
															"fixed interval between"}
	set prg(190) {"filter"	 "userbank" 	 		2 "bands as frq (hz)" "bands as midi"}
	set prg(191) {"filter"	 "varibank"	 			2 "bands as frq (hz)" "bands as midi"}
	set prg(192) {"filter"	 "sweeping"	 			4 "notch" "band pass" "low pass" "high pass"}
	set prg(193) {"filter"	 "iterated" 	 		2 "bands as frq (hz)" "bands as midi"}
	set prg(194) {"filter"	 "phasing"	 			2 "phase shift filter" "phasing effect"}
	set prg(195) {"modify"	 "loudness"				12 "gain" "dBgain" "normalise" "force level" "balance srcs" \
															"invert phase" "find loudest" "equalise loudness" "tremolo frqwise" "tremolo pitchwise" \
															"envelope timescaled to infile dur" "dB envelope timescaled to infile dur" }
	set prg(196) {"modify"	 "spatialisation"		4 "pan" "mirror" "mirror panning file" "narrow"}
	set prg(197) {"modify"	 "pitch"				6 "tape transpose by time-ratio" "tape transpose by semitones" \
													  "see transposition by time-ratio" "see transposition by semitones" \
													  "tape accelerate" "tape vibrato"}
	set prg(198) {"modify"	 "rev/echo"				3 "delay" "varying delay" "stadium"}
	set prg(199) {"modify"	 "brassage"				7 "pitchshift" "timesqueeze" "reverb" "scramble" \
															"granulate" "brassage" "full monty"}
	set prg(200) {"modify"	 "sausage"				0}
	if {[info exists modify_version] && ($modify_version >= 9)} {
		set prg(201) {"modify"	 "radical"				7 "reverse" "shred" "scrub over heads" "lower resolution" \
																"ring modulate" "cross modulate"  "bit quantise"}
	} else {
		set prg(201) {"modify"	 "radical"				6 "reverse" "shred" "scrub over heads" "lower resolution" \
																"ring modulate" "cross modulate"}
	}
	set prg(202) {"pvoc"	 "analysis"				3 "standard" "get spec envelope only" \
															"get spec magnitudes only"}
	set prg(203) {"pvoc"	 "synthesis"			0}
	set prg(204) {"pvoc"	 "extract"			 	0}
	set prg(206) {"sfedit"	 "cutout & keep"		3 "time in seconds" "time as sample count" \
														"time as grouped samples"}
	set prg(207) {"sfedit"	 "cutend & keep"	 	3 "time in seconds" "time as sample count" \
															"time as grouped samples"}
	set prg(208) {"sfedit"	 "cutout at zero-crossings" 3 "time in seconds" "time as sample count" \
															"time as grouped samples"}
	set prg(209) {"sfedit"	 "remove segment"	 	3 "time in seconds" "time as sample count" \
															"time as grouped samples"}
	set prg(210) {"sfedit"	 "remove many segments"	3 "time in seconds" "time as sample count" \
															"time as grouped samples"}
	set prg(211) {"sfedit"	 "insert sound"		 	3 "time in seconds" "time as sample count" \
															"time as grouped samples"}
	set prg(212) {"sfedit"	 "insert silence"	 	3 "time in seconds" "time as sample count" \
															"time as grouped samples"}
	set prg(213) {"sfedit"	 	"join"						0}
	set prg(214) {"housekeep"	"multiples"		 			2 "make a copy" "make multiple copies"}
	set prg(215) {"housekeep" 	"extract/convert channels" 	5 "extract a channel" "extract all channels" \
																"zero a channel" "convert to mono" \
																"convert mono to 'stereo'"}
	set prg(216) {"housekeep" "select & clean"	 		5 "gated extraction" "preview extraction" \
														"top and tail" "remove d.c." "" "list onsets"}
	set prg(217) {"housekeep" "change specification" 	3 "change sampling rate" "" ""}
	set prg(218) {"housekeep" "bundle"			 		5 "any files" "non-text files" "same type" \
																"same properties" "same channels"}
	set prg(219) {"housekeep"	 "sort files"		 	6 "by filetype" "by sampling rate" \
																"by duration" "by log duration" \
																"into duration order" "find rogues"}
	set prg(220) {"housekeep"	 "store files in soundfile" 0}
	set prg(221) {"housekeep" 	 "recover files from filedump"	0}
	set prg(222) {"housekeep"	 "diskspace"		 	0}
	set prg(223) {"sndinfo"		 "properties"		 	0}
	set prg(224) {"sndinfo"		 "duration"				0}
	set prg(225) {"sndinfo"		 "list sound durations"	0}
	set prg(226) {"sndinfo"		 "sum durations"	 	0}
	set prg(227) {"sndinfo"	 "subtract durations" 	0}
	set prg(228) {"sndinfo"	 "sample count as time" 0}
	set prg(229) {"sndinfo"	 "time as sample count"	0}
	set prg(230) {"sndinfo"	 "maximum sample"	 	0}
	set prg(231) {"sndinfo"	 "loudest channel"	 	0}
	set prg(232) {"sndinfo"	 "largest hole"		 	0}
	set prg(233) {"sndinfo"	 "compare files"	 	0}
	set prg(234) {"sndinfo"	 "compare channels"	 	0}
	set prg(235) {"sndinfo"	 "print sound data"	 	0}
	set prg(236) {"sndinfo"	 "convert units"		25 "midi to frq" "frq to midi" "note to frq" "note to midi" \
															"frq to note" "midi to note" \
															"frq ratio to semitones" "frq ratio to interval" \
															"interval to frq ratio" "semitones to frq ratio" \
															"octaves to frq ratio" "octaves to semitones" \
															"frq ratio to octaves" "semitones to octaves" \
															"semitones to interval" "frq ratio to time ratio" \
															"semitones to time ratio" "octaves to time ratio" \
															"interval to time ratio" "time ratio to frq ratio" \
															"time ratio to semitones" "time ratio to octaves" \
															"time ratio to interval" "gain factor to db gain" \
															"db gain to gain factor"}
	set prg(237) {"synth"	 "waveform"				4 "sine" "square" "saw" "ramp"}
	set prg(238) {"synth"	 "noise"				0}
	set prg(239) {"synth"	 "silent file"			0}
	set prg(248) {"focus"	 "hold"			 		0}
	set prg(249) {"housekeep" "remove copies"		0}
	set prg(251) {"sfedit"	 "silence masks"		3 "time in seconds" "time as sample count" \
														"time as grouped samples"}
	set prg(252) {"sfedit"	 "random sliced"		0}
	set prg(253) {"sfedit"	 "random chunks"		0}
	set prg(254) {"modify"	 "create sinusoidal pan-control" 0}
	set prg(255) {"extend"	 "repetitions"	 		0}
	if {[info exists released(newmix)]} {
		set prg(256) {"newmix"	 "MULTICHANNEL MIX"	 	0}
	}
	if {[info exists released(analjoin)]} {
		set prg(257) {"analjoin" "join"	 	0}
	}
	if {[info exists released(ptobrk)]} {
		set prg(258) {"ptobrk"   "ditto, BUT retain no-signal info"	 	0}
	}
	if {[info exists released(psow)]} {
		set prg(259) {"psow"     "Stretch using fofs"	 	0}
		set prg(260) {"psow"     "Duplicate fofs"	 		0}
		set prg(261) {"psow"     "Delete fofs"	 			0}
		set prg(262) {"psow"     "Stretch & transpose using fofs"	 0}
		set prg(266) {"psow"     "grab and use a fof"	 0}
		set prg(267) {"psow"     "chop up between specified fofs"	 0}
		set prg(268) {"psow"     "interpolate between single fofs"	 0}
		set prg(270) {"psow"     "add features to sound analysed into fofs"	 2 \
											"transposing involves timewarp" "transposing involves double pitches"}
		set prg(271) {"psow"     "add fofs to defined oscillators"	 5 \
											"fixed frq bands" "fixed midi bands" "variable frq bands" "variable midi bands" "noise"}
		set prg(272) {"psow"     "add fofs to a 2nd sound"	 0}
		set prg(273) {"psow"     "subharmonics and transposition"	 0}
		set prg(274) {"psow"     "spatialise fofs"	 0}
		set prg(275) {"psow"     "interpolate fofs of 2 snds"	 0}
		set prg(276) {"psow"     "replace fofs with those of another snd"	 0}
		set prg(277) {"psow"     "sustain a specific FOF within a sound"	 0}
		set prg(278) {"psow"     "Exact start time of nearest grain"	 0}
		set prg(279) {"psow"     "cut at exact grain time" 2	 "keep snd before grain"  "keep snd at and after grain"}
		set prg(281) {"psow"     "sustain explicitly specified FOF"	 0}
		set prg(284) {"psow"     "reinforce harmonics"	 2  "reinforce harmonics"  "add inharmonic constitutents"}
	}
	if {[info exists released(oneform)]} {
		set prg(263) {"oneform"	 "extract single-moment formants"		 0}
		set prg(264) {"oneform"	 "impose single-moment formants" 2 "replace formants" "superimpose formants"}
		set prg(265) {"oneform"	 "add single-moment formants to pitch" 0}
	}
	if {[info exists released(gate)]} {
		if {$gate_version < 6} {
			set prg(269) {"gate"     "gate"	 0}
		} else {
			set prg(269) {"gate"     "gate"	 2  "low level signal to zero"  "low level signal removed (shorten)"}
		}
	}
	if {[info exists released(specnu)]} {
		set prg(280) {"specnu"	 "handle pitch component"	 	2 "remove pitch component"  "remove nonpitch component"}
		set prg(360) {"specnu"    "clean better"	0}
		set prg(361) {"specnu"    "clean by subtraction"	0}
		set prg(365) {"specnu"	 "slice or pivot spectrum"	 	5 "slice by anal channel"  "slice by frequency"  "slice by pitch"  \
																		"slice by harmonics"  "pivot spectrum"}
	}
	if {[info exists released(prefix)]} {
		set prg(282) {"prefix"	 "add silence at start"	 	0}
	}
	if {[info exists released(strans)]} {
		set prg(283) {"strans"	 "transpose: accel: vibrato"  4 "tape transpose by time-ratio" "tape transpose by semitones" "tape accelerate" "vibrato"}
	}
	if {[info exists released(get_partials)]} {
		set prg(285) {"get_partials"  "get partials contour"	 4  "frq from single window file"  "midi from single window file" \
														"frq from multiple window file"  "midi from multiple window file" }
	}
	if {[info exists released(specross)]} {
		set prg(286) {"specross" "interpolate harmonics"	 0 }
	}
	if {[info exists released(mchiter)]} {
		set prg(287) {"mchiter" "iterate across space"	 2 "give duration" "give count"}
	}
	set prg(289) {"hfperm"	 "fields as chords"	 	4 "output sounds" "sounds grouped in separate files" \
															"output pitches as text" "output midi data"}
	set prg(290) {"hfperm"	 "sets as chords"	 	4 "output sounds" "sounds grouped in separate files" \
															"output pitches as text" "output midi data"}
	set prg(291) {"hfperm"	 "permutations with delay"	0}
	set prg(292) {"hfperm"	 "perms+delays on input"	0}
	set prg(293) {"synth"	 "spectral bands"		0}
	set prg(294) {"distort"	 "clip"					2 "noise clip" "oscillator clip"}
	set prg(295) {"sfedit"	  "switch between files"	6 "time-segments in sequence" "time-segments permuted" \
													"time-segments at random" "test switch times" \
													"preview source1 envelope" "extract switch times"}
	set prg(296) {"sfedit"	 "make a sphinx"		3 "time-segments in sequence" "time-segments permuted" \
													"time-segments at random"}
	set prg(297) {"sndinfo"	 "list levels"			0}
	set prg(298) {"repitch"	 "spectrum over pitchfile"	0}
	set prg(299) {"repitch"	 "insert unpitched windows"	2 "time: seconds" "time: sample-cnt in source-snd"}
	set prg(300) {"repitch"	 "replace pitch by silence"	0}
	set prg(301) {"repitch"	 "replace noise by silence"	0}
	set prg(302) {"repitch"	 "insert silent windows"	2 "time: seconds" "time: sample-cnt in source-snd"}
	set prg(303) {"repitch"  "extract from analfile"	0}
	set prg(304) {"combine"  "pitch + formants + envelope"			0}
	set prg(305) {"repitch"  "vowels over pitchfile"	0}
	set prg(306) {"housekeep" "store files in filedump"	0}
	set prg(307) {"housekeep" "chop at amplitude zeros" 0}
	set prg(308) {"submix"    "create mixfile on timegrid"  0}
	set prg(309) {"repitch"   "Synth pitchdata from note-names or midi"  0}
	set prg(310) {"repitch"   "interpolate pitch thro' noise or silence"  2 "glide" "sustain"}
	set prg(311) {"submix"   "balance between several sounds" 0}
	set prg(312) {"sfedit"	 "cutout & keep many" 3 "time in seconds" "time as sample count" \
														"time as grouped samples"}
	set prg(313) {"modify"  "stack" 0}
	set prg(314) {"hilite"  "impose vowels" 0}
	set prg(315) {"envel"	"impose scaled-to-fit envelope"	0}
	set prg(316) {"modify"	"pan, scaled to file duration" 0}
	set prg(317) {"submix"	 "merge many sounds" 0}
	set prg(318) {"distort"	 "impose pulsetrain" 3 "impose on source" "synthesize over source" "synth with integer params"}
	set prg(319) {"sfedit"	 "suppress noise" 0}
	set prg(320) {"envel"	 "partition to time grids" 0}
	set prg(321) {"extend"	 "sequencer" 0}
	set prg(322) {"modify"	 "convolve" 2 "normal" "time varying"}
	set prg(323) {"extend"	 "back to back" 0}
	set prg(324) {"submix"	 "add sounds to mix" 0}
	set prg(325) {"sfedit"	 "replace segment of sound" 0}
	set prg(326) {"submix"	 "pan sound positions in mixfile" 0}
	set prg(327) {"modify"	 "shudder sound" 0}
	set prg(328) {"submix"	 "create mixfile with timestep" 0}
	set prg(329) {"modify"	 "find pan position" 0}
	set prg(330) {"synth"	 "generate clicktrack" 2 "between given times" "between given datalines"}
	set prg(331) {"extend"	 "make doublets" 0}
	set prg(332) {"sfedit"	 "separate syllables" 3 "time in seconds" "time as sample count" \
															"time as grouped samples"}
	set prg(333) {"sfedit"	 "join in patterned sequence" 0}
	set prg(334) {"filter"	 "make fixed-pitch vfilters" 0}
	set prg(335) {"housekeep" "use batchfile as model" 2 "single valued param" "many valued param"}
	set prg(336) {"submix"   "replace sounds in mixfile" 0}
	set prg(337) {"submix"   "inbetween with zerosyncs" 0}
	set prg(338) {"sfedit"	 "join in loudness patterned sequence" 0}
	set prg(339) {"extend"   "freeze portion of sound by iteration" 2 "give duration" "give count"}
	set prg(340) {"distort"  "repeat cycles below max frq" 0}
	set prg(341) {"housekeep" "remove edge clicks" 0}
	set prg(342) {"repitch"  "convert binary pitchdata to text" 0}
	set prg(343) {"envel"    "create cyclic envelope" 4 "rising" "falling" "troughed" "user defined"}
	set prg(344) {"extend"	 "multisound sequencer" 0}
	set prg(345) {"grain"	 "extend an iterative sound (e.g. \"rrr\")" 3 "specify location" "find location" "separate the iters"}
	set prg(346) {"housekeep" "remove glitches" 0}
	set prg(347) {"grain"     "assess max no. of grains" 0}
	set prg(348) {"filter"	 "varipartials" 2 "bands as frq (hz)" "bands as midi"}
	set prg(349) {"distort"	 "repeat then skip (no timestretch)" 0}
	set prg(350) {"sndinfo"	 "Proportion of zero-crossings" 0}
	set prg(351) {"grain"	 "extend 1st noise in source (e.g. \"sss\")" 0}
	set prg(352) {"grain"	 "find grains between trough zeros" 7 "reverse" "repeat" "delete" "omit" "time stretch" \
																  "write times to a textfile" "reposition at given times"}
	set prg(353) {"tapdelay"  "multiple delays + positioning"	0}
	set prg(354) {"rmresp"    "room characteristics -> reverb data"	0}
	set prg(355) {"rmverb"    "reverb with room characteristics"	0}
	if {[info exists released(lucier)]} {
		set prg(356) {"lucier"    "extract room resonance to filter data"	0}
		set prg(357) {"lucier"    "extract room resonance to analfile"	0}
		set prg(358) {"lucier"    "add room resonance to source"	0}
		set prg(359) {"lucier"    "subtract room resonance from source"	0}
	}
	if {[info exists released(phase)]} {
		set prg(362) {"phase"     "modify phase"	2 "invert phase" "enhance stereo" }
	}
	if {[info exists released(features)]} {
		set prg(363) {"features"  "convert text pitchdata to binary" 0}	;# ACTUALLY 7 MODES, BUT NOT YET COMPLETED!!
	}
	if {[info exists released(brktopi)]} {
		set prg(364) {"brktopi"   "convert text pitchdata to binary" 0}
	}
	if {[info exists released(fofex)]} {
		set prg(366) {"fofex"	 "Extract FOFs"   3 "All FOFs to 1 file for reconstruction" "One FOF to soundfile" "All FOFs to soundfiles"}
		set prg(367) {"fofex"	 "FOF reconstruction" 7 "Single FOF" "Sum all FOFs" "Sum all low range FOFs" "Sum all mid range FOFs" "Sum all high range FOFs" \
														"2 FOFs vary with pitch" "3 FOFs vary w pitch & level"}
	}
	if {[info exists released(grainex)]} {
		set prg(368) {"grainex"	 "extend grainy part of sound"	0}
	}
	if {[info exists released(peakfind)]} {
		set prg(369) {"peakfind"	"list times of sound peaks"	0}
	}
	if {[info exists released(constrict)]} {
		set prg(370) {"constrict"	"shorten zerolevel segments"	0}
	}
	if {[info exists released(envnu)]} {
		set prg(371) {"envnu"	"curtail with true exponential"	0}
	}
	if {[info exists released(envnu)]} {
		set prg(372) {"envnu"	"isolate peaks"	2 "play peaks at tempo" "output isolating envelope"}
	}
	if {[info exists released(mchanpan)]} {
		set prg(373) {"mchanpan" "multichannel pan"	10 "pan round multichan space" "switch events between outchans" "spread events around outchans" "spread src over outchans" \
							"antiphony on events"  "antiphony of sounds" "pan all across centre" "pan a process" "rotate a mono file" "switch events between random outchans"}
	}
	if {[info exists released(texmchan)]} {
		set prg(374) {"texmchan" "multichannel texture"	5 "over harmonic field" "over harmonic fields" \
															"over harmonic set" "over harmonic sets" "neutral"}
	}
	if {[info exists released(manysil)]} {
		set prg(375) {"manysil" "insert silences"	0}
	}
	if {[info exists released(retime)]} {
		set prg(376) {"retime" "retime events"	14  "sync user-specified peaks to MM" "change rhythm and MM" "narrow existing peaks" \
													"regular pulse found peaks at MM" "change tempo of found peaks" "reposition events at beats" \
													"reposition events at times" "repeat event in tempo" "mask events" \
													"change event accents" "find shortest event" "find sound start" \
													"move so found peak at new time" "move so specified peak at new time" }
	}
	if {[info exists released(hover)]} {
		set prg(378) {"hover" "hovering zigzag"	0}
	}
	if {[info exists released(multimix)]} {
		set prg(379) {"multimix" "create multichannel mixfile" 8 "superimposed" "end to end" "with fixed timestep" \
															"distribute single stereo to 4 of 8 channels" "distribute single stereo to 8 channels" \
															"N mono to N outchans" "N mono to K outchans" "superimposed to K outchans"}
	}
	if {[info exists released(frame)]} {
		set prg(380) {"frame" "frame operations" 8	"rotation"  "double rotation" "reorient frame" "mirror frame" "to/from bilateral numbering" \
													"swap two channels" "modify some channels only" "to/from BEAST bilateral"}
	}
	if {[info exists released(search)]} {
		set prg(381) {"search" "start of signal(s)"	0}
	}
	if {[info exists released(mchanrev)]} {
		set prg(382) {"mchanrev" "multichannel echo/reverb"	0}
	}
	if {[info exists released(wrappage)]} {
		set prg(383) {"wrappage"  "multifile moving brassage"	0}
	}
	set prg(390) "specanal"
	if {[info exists released(specsphinx)]} {
		set prg(391) {"specsphinx"	 "specsphinx"		3   "impose channel amplitudes"  "multiply spectra"  "carve 1st spectrum with 2nd"}
	}
	if {[info exists released(superaccu)]} {
		set prg(392) {"superaccu"	 "super accumulate"		4   "natural"  "tempered"  "tuned to harmonic set"  "tuned to harmonic field"}
	}
	if {[info exists released(partition)]} {
		set prg(393) {"partition"	 "partition to grids"	2  "using wavesets"  "using durations"}
	}
	if {[info exists released(specgrids)]} {
		set prg(394) {"specgrids"	 "partition spectrum channels to grid"	0}
	}
	if {[info exists released(glisten)]} {
		set prg(395) {"glisten"	 "glisten"	0}
	}
	if {[info exists released(tunevary)]} {
		set prg(396) {"tunevary"  "varitune spectrum"	0}
	}
	if {[info exists released(isolate)]} {
		set prg(397) {"isolate"  "isolate segments in place"	5  "isolate segments" "isolate sets of segments" "isolate 1 set segs by dB threshold" \
															"slice whole file to segments" "slice whole file with overlaps"}
	}
	if {[info exists released(rejoin)]} {
		set prg(398) {"rejoin"  "rejoin isolated segments"	2  "rejoin segment-files only" "rejoin segments and remnant"}
	}
	if {[info exists released(panorama)]} {
		set prg(399) {"panorama"  "panoramic spread of sounds"	2  "give count and spread of lspkrs" "give list of lspkr positions"}
	}
	if {[info exists released(tremolo)]} {
		set prg(400) {"tremolo"  "squeezed tremolo"			 	2 "frqwise" "pitchwise"}
	}
	if {[info exists released(sfecho)]} {
		set prg(401) {"sfecho"  "create echos"			 	0}
	}
	if {[info exists released(packet)]} {
		set prg(402) {"packet"  "create sound packet"		2	"find packet" "force packet"}
	}
	if {[info exists released(newsynth)]} {
		set prg(403) {"newsynth"  "complex synthesis"		4	"complex tones" "wave packet streams" "glistening" "fractal spikes"}
	}
	if {[info exists released(tangent)]} {
		set prg(404) {"tangent"  "one sound tangent to 8-chan ring"		  2 "far tangent" "tangent"}
		set prg(405) {"tangent"  "sound-pair tangent to 8-chan ring"	  2 "far tangent" "tangent"}
		set prg(406) {"tangent"  "sound-sequence tangent to 8-chan ring"  2 "far tangent" "tangent"}
		set prg(407) {"tangent"  "listed-sequence tangent to 8-chan ring" 2 "far tangent" "tangent"}
	}
	if {[info exists released(spectwin)]} {
		set prg(408) {"spectwin"  "crossbreed spectra"		4	"formants snd1 with formants snd2"  "formants snd1 with absolute snd2" \
																"absolute snd1 with formants snd2"	"absolute snd1 with absolute snd" }
	}
	if {[info exists released(transit)]} {
		set prg(409) {"transit"  "one sound crossing 8-chan ring"				5 "glancing" "edgewise" "crossing" "close" "central"}
		set prg(410) {"transit"  "sound-pair crossing 8-chan ring"				5 "glancing" "edgewise" "crossing" "close" "central"}
		set prg(411) {"transit"  "sound with doppler crossing 8-chan ring"		5 "glancing" "edgewise" "crossing" "close" "central"}
		set prg(412) {"transit"  "sound-pair with doppler crossing 8-chan ring" 5 "glancing" "edgewise" "crossing" "close" "central"}
		set prg(413) {"transit"  "sound sequence crossing 8-chan ring"			5 "glancing" "edgewise" "crossing" "close" "central"}
		set prg(414) {"transit"  "sounds (in textfile) crossing 8-chan ring"	5 "glancing" "edgewise" "crossing" "close" "central"}
	}
	if {[info exists released(cantor)]} {
		set prg(415) {"cantor"  "make cantor-set holes in source"		3 "holesize proportional to segsize"  "fixed holesize" "superimposed sinus envelopes"}
	}
	if {[info exists released(shrink)]} {
		set prg(416) {"shrink"  "repeat with shrinkage"		6 "repeat+shrink from end"  "repeat+shrink around middle" "repeat+shrink from start" "repeat+shrink around specified time" \
															  "find peaks and shrink"   "specify peaks and shrink"}
	}
	if {[info exists released(newtex)]} {
		set prg(417) {"newtex"  "spatialised textures"		3 "granulate transpose src"   "granulate mix srcs"  "drunkwalk mix srcs"}
	}
	if {[info exists released(ceracu)]} {
		set prg(418) {"ceracu"  "cyclic poyrhythm"		0}
	}
	if {[info exists released(madrid)]} {
		set prg(419) {"madrid"  "spatialised accents"		2 "one or more sounds"  "sounds used in specified sequence"}
	}
	if {[info exists released(shifter)]} {
		set prg(420) {"shifter"  "focus-shifting streams"	2 "one sound: many streams" "many sounds: 1 per stream"}
	}
	if {[info exists released(fracture)]} {
		set prg(421) {"fracture"  "fracture to spatialised fragments"	2 "fracture to static frame" "fracture to moving frame"}
	}
	if {[info exists released(subtract)]} {
		set prg(422) {"subtract"  "subtract one file from another"	0}
	}
	if {[info exists released(spectrum)]} {
		set prg(423) {"spectrum"  "spectrum from spectral-line data"	2  "create spectrum"  "create filter data"}
	}
	if {[info exists released(newmorph)]} {
		set prg(424) {"newmorph"  "morph between very different spectra"	7  "linear between average peaks"  "cosinusoidal between average peaks" \
																				"linear between momentwise peaks"  "cosinusoidal between momentwise peaks" \
																				"tune 1st gradually to HF of 2nd" "tune 1st cosin-gradually to HF of 2nd" \
																				"generate intermediate files" }
	}
	if {[info exists released(newmorph)]} {
		set prg(425) {"newmorph"  "morph peaks of spectrum"	3  "extract frqs of average peaks"  "tune peaks to textfile vals" "tune peaks cosinwise to textfile vals"}
	}
	if {[info exists released(newdelay)]} {
		set prg(426) {"newdelay"  "pitching via delay with feedback"	2 "pitch over whole sound" "pitch on head portion"}
	}
	if {[info exists released(filtrage)]} {
		set prg(427) {"filtrage"  "random filter data"	2  "fixed filters" "time-varying filters"}
	}
	if {[info exists released(iterline)]} {
		set prg(428) {"iterline"  "iterate sound on pitchline"	2  "interpolate between transpositions" "step between transpositions"}
	}
	if {[info exists released(iterlinef)]} {
		set prg(429) {"iterlinef"  "iterate soundset on pitchline"	2  "interpolate between transpositions" "step between transpositions"}
	}
	if {[info exists released(specnu)]} {
		if {$specnu_version >= 7} {
			set prg(431) {"specnu"  "time-randomise spectrum"	0}
			set prg(432) {"specnu"  "squeeze frq range of spectrum"	0}
		}
		if {$specnu_version >= 8} {
			set prg(504) {"specnu"  "timestretch spectrum with randomisation"	0}
		}
	}
	if {[info exists released(hover2)]} {
		set prg(433) {"hover2" "hovering zigzag around zero-crossings"	0}
	}
	if {[info exists released(selfsim)]} {
		set prg(434) {"selfsim" "Make spectrum more self-similar"	0}
	}
	if {[info exists released(iterfof)]} {
		set prg(435) {"iterfof" "iterate soundpacket on pitchline"	4 "interpolate between transpositions of FOF" "step between transpositions of FOF" \
																	  "interpolate between MIDI pitches" "step between MIDI pitches"}
	}
	if {[info exists released(pulser)]} {
		set prg(436) {"pulser" "Stream of pitched packets from single src"	3  "packets from src brightness" "packets from src start" "packets from within src" }
		set prg(437) {"pulser" "Stream of pitched packets from many srcs"	3  "packets from src brightness" "packets from src start" "packets from within src" }
		set prg(438) {"pulser" "Packet stream synthesized from partials" 3 "fixed spectra" "time-varying spectra" "random varying spectra"}
	}
	if {[info exists released(chirikov)]} {
		set prg(439) {"chirikov" "Chirikov and Circular iterative maps" 4 "sound from Chirikov map" "sound from Circular map" "pitch brkpnt data from Chirikov map" "pitch brkpnt data from Circular map"}
	}
	if {[info exists released(multiosc)]} {
		set prg(440) {"multiosc" "Interacting oscillators" 3 "Oscillation of oscilation" "Oscil of oscil of oscil" "Oscil of oscil of oscil of oscil"}
	}
	if {[info exists released(synfilt)]} {
		set prg(441) {"synfilt" "filtered noise" 2 "single pitch centre" "simultaneous pitch centres"}
	}
	if {[info exists released(strands)]} {
		set prg(442) {"strands" "banded flow" 3 "output synth-control data" "output sound" "data: bands with different threadcnts"}
	}
	if {[info exists released(refocus)]} {
		set prg(443) {"refocus" "focus layers" 5 "at random" "rising sequences" "falling sequences" "rising/falling cycles" "falling/rising cycles"}
	}
	if {[info exists released(chanphase)]} {
		set prg(447) {"chanphase"     "modify channel phase"	0 }
	}
	if {[info exists released(silend)]} {
		set prg(448) {"silend"     "pad end of sound with silence"	2 "specify duration of added silence"  "specify new duration of outfile"}
	}
	if {[info exists released(speculate)]} {
		set prg(449) {"speculate"     "systematically permute analysis chans" 0}
	}
	if {[info exists released(spectune)]} {
		set prg(450) {"spectune"     "tune sound to nearest pitch in tuning-set" 4 "to tempered scale" "to one of given pitches" \
																				   "to one of given pitches in any octave" "report median pitch"}
	}
	if {[info exists released(repair)]} {
		set prg(451) {"repair"     "recontruct several multichan files from mono srcs" 0 }
	}
	if {[info exists released(distshift)]} {
		set prg(452) {"distshift"     "timeshift" 2 "shift" "pairwise swap"}
	}
	if {[info exists released(quirk)]} {
		set prg(453) {"quirk"     "power scale" 2 "scale within each half-waveset" "scale over entire sound"}
	}
	if {[info exists released(rotor)]} {
		set prg(454) {"rotor"     "generate cycling scales" 3 "at fixed timesteps" "timesteps vary with set-speeds" "edge-events overlayed"}
	}
	if {[info exists released(distcut)]} {
		set prg(455) {"distcut"     "slice-by-waveset-cnt and envelope" 2 "disjunct segments"  "independent segments"}	
	}
	if {[info exists released(envcut)]} {
		set prg(456) {"envcut"     "slice and envelope" 2 "disjunct segments"  "independent segments"}	
	}
	if {[info exists released(specfold)]} {
		set prg(458) {"specfold"   "permute spectral channels"	3 "fold the spectrum"  "invert the spectrum"  "randomise the spectrum"}	
	}
	if {[info exists released(brownian)]} {
		set prg(459) {"brownian"   "brownian motion"	2 "use source as waveform"  "use source as transposable event"}	
	}
	if {[info exists released(spin)]} {
		set prg(460) {"spin"   "spin stereo image"	3 "in the stereo space" "in multichannel space" "in squeezed multichannel space"}	
		set prg(461) {"spin"   "spin double stereo image" 2 "in multichan space" "in squeezed multichan space"}	
	}
	if {[info exists released(crumble)]} {
		set prg(462) {"crumble"   "disintegrate sound" 2 "into 8-channel space" "into 16-channel space"}	
	}
	if {[info exists released(tesselate)]} {
		set prg(463) {"tesselate"   "tesselate space+time" 0}	
	}
	if {[info exists released(phasor)]} {
		set prg(465) {"phasor"   "phasing of source" 0}	
	}
	if {[info exists released(crystal)]} {
		set prg(466) {"crystal"   "rotate 3d crystal" 10 "mono" "stereo" "2 non-adjacent chans of multichan" "ditto, rotates clockwise" "ditto anticlockwise" "ditto random" \
														 "2 adjacent chans, rotates clockwise" "ditto anticlockwise" "ditto random" "stereo multifile output"}	
	}
	if {[info exists released(waveform)]} {
		set prg(467) {"waveform"   "create waveform" 3 "from half-wavesets" "from mS sampling" "combined with sinusoid"}	
	}

	if {[info exists released(dvdwind)]} {
		set prg(468) {"dvdwind"   "shrink by skipping" 0}	
	}
	if {[info exists released(cascade)]} {
		set prg(469) {"cascade"   "echo cascade" 10 "SEGMENT DURS : N channel" "mono to stereo : left to right" "mono to stereo : centre to left & right" \
						                             "mono to 8chan clockwise" "mono to 8chan clock then anticlock" \
													 "CUT TIMES : N channel" "mono to stereo : left to right" "to stereo : centre to left & right" \
						                             "mono to 8chan clockwise" "cut times : mono to 8chan clock then anticlock"}	
	}
	if {[info exists released(synspline)]} {
		set prg(470) {"synspline"   "synth with random overtones" 0}	
	}
	if {[info exists released(fractal)]} {
		set prg(471) {"fractal"   "create fractal" 2 "from a waveform"  "over a source snd"}	
		set prg(472) {"fractal"   "create fractal spectrum" 0}	
	}
	if {[info exists released(splinter)]} {
		set prg(473) {"splinter"   "splinter a sound" 4 "falling splinters merge into source" "rising splinters emerge from source"  \
														"steady-pitch splinters merge into source" "steady-pitch splinters emerge from source" }	
	}
	if {[info exists released(repeater)]} {
		set prg(474) {"repeater"   "play snd with elements repeated" 2 "specify delay between repeat starts" "specify offset between repeat end and next start" }	
	}
	if {[info exists released(verges)]} {
		set prg(475) {"verges"   "Add glissed accents to sound" 0}	
	}
	if {[info exists released(motor)]} {
		set prg(476) {"motor"  "pulsed pulses" 9 "one src : advance+regress" "several segs from one src : advance+regress" "many srcs : advance+regress" \
												 "one src : advance" "several segs from one src : advance" "many srcs : advance" \
												 "one src : advance or regress" "several segs from one src : advance or regress" "many srcs : advance or regress" }	
	}
	if {[info exists released(stutter)]} {
		set prg(477) {"stutter"   "Stutter: stream of cuts from src elements" 0}	
	}
	if {[info exists released(scramble)]} {
		set prg(478) {"scramble"   "Scramble order of (groups of) wavesets." 14 "Permute order randomly" "Select groups randomly" \
																				"order by increasing size (falling pitch)" "order by decreasing size (rising pitch)" \
																				"segment and order by increasing size" "segment and order by decreasing size" \
																				"segment + order alternately by increasing and decreasing size" "segment + order alternately by decreasing and increasing size" \
																				"order by increasing loudness" "order by decreasing loudness" \
																				"segment and order by increasing loudness" "segment and order by decreasing loudness" \
																				"segment + order alternately by increasing and decreasing loudness" "segment + order alternately by decreasing and increasing loudness" }
	}
	if {[info exists released(impulse)]} {
		set prg(479) {"impulse"   "Generate impulse (stream)" 0}	
	}
	if {[info exists released(tweet)]} {
		set prg(480) {"tweet"   "Replace FOFs" 3 "by varying chirps" "by fixed chirps" "by noise"}	
	}
	if {[info exists released(bounce)]} {
		set prg(481) {"bounce"   "\"Bouncing\" repetition" 0}	
	}
	if {[info exists released(sorter)]} {
		set prg(482) {"sorter"   "Reorder sound elements" 5 "by crescendo" "by decrescendo" "by accelerando" "by ritardando" "at random"}	
	}
	if {[info exists released(specfnu)]} {
		set prg(483) {"specfnu"   "Process speech"  23  "narrow formants" "squeeze spectrum around formant" "invert formants" "rotate formants" \
									"spectral negative" "suppress formants" "generate filterdata from formants" "move formants by" "move formants to"  \
									"arpeggiate spectrum, under formants" "octave-shift, under formants" "transpose, under formants" "frqshift, under formants"  \
									"respace partials, under formants" "pitch-invert, under formants" "pitch-exaggerate/smooth, under formants" \
									"quantise pitch, under formants" "pitch randomise, under formants" "randomise spectrum, under formants" "see spectral envelopes" \
									"list peaks & troughs in spectrum" "list times of troughs between syllables" "sinus speech"}
	}
	if {[info exists released(flatten)]} {
		set prg(484) {"flatten"   "Balance level of sound elements" 0}	
	}
	if {[info exists released(distmark)]} {
		set prg(488) {"distmark"   "Wavset interp between markers" 0}	
	}
	if {[info exists released(distrep)]} {
		set prg(496) {"distrep"   "Wavset repeat with splices" 2  "Output timestretched" "No timestretch"}	
	}
	if {[info exists released(tostereo)]} {
		set prg(497) {"tostereo"   "Mono-merge to true stereo" 0}	
	}
	if {[info exists released(suppress)]} {
		set prg(498) {"suppress"   "Suppress partials in bands" 0}	
	}
	if {[info exists released(caltrain)]} {
		set prg(499) {"caltrain"   "Blur higher freqency band" 0}	
	}
	if {[info exists released(specenv)]} {
		set prg(500) {"specenv"   "Impose spectral envelope of File2 on File1" 0}	
	}
	if {[info exists released(clip)]} {
		set prg(503) {"clip"   "Clip peaks of sound" 2 "at given level" "in each waveset"}	
	}
	set evv(MAX_PROCESS_NO) 504
# PSEUDO-PROCESSES : PROGRAMS MASQUERADING AS OTHER PROGRAMS
	if {$snack_enabled} {
		set prg(1000) {"sfedit"	 "slice" 3 "time in seconds" "time as sample count" \
															"time as grouped samples"}
		if {[info exists released(manysil)]} {
			set prg(1001) {"manysil" "snip"	0}
		}
		set prg(1003) {"stretch"	 "around times" 2 "do time_stretch" "get output length"}
	}
	set prg(1002) {"envel"	 "impose contour" 0}
	if {[info exists released(silend)]} {
		set prg(1004) {"silend"  "pad end of sound with silence"	2 "specify duration of added silence"  "specify new duration of outfile"}
	}
}

#------ Establish short names for each process/mode, for display on ins tree

proc SetPnamesForTree {} {
	global tpn gate_version modify_version
	set tpn(1)  {"gain"}
	set tpn(2)  {"gate"}
	set tpn(3)  {"bare"}
	set tpn(4)  {"clean" "clean" "clean" "clean"}
	set tpn(5)  {"cut"}
	set tpn(6)  {"grab"}
	set tpn(7)  {"magnify"}
	set tpn(8)  {"specstretch" "specstretch"}
	set tpn(9)  {"time stretch" "time stretch?"}
	set tpn(10) {"alternate(-odd)" "alternate(-evn)"}
	set tpn(11) {"octave shift up" "octave shift dn" "octav shift dn+"}
	set tpn(12) {"pshift +8va,above" "pshift -8va,below" "pitchshift +-8" \
						"pshift above" "pshift below" "pshift above&below"}
	set tpn(13) {"tune spectrum" "tune spectrum"}
	set tpn(14) {"partials(harm)" "partials(oct)" "partials(odd)" "partials(lin)" "partials(dspl)"}
	set tpn(15) {"chord"}
	set tpn(16) {"chord(fmnts)"}
	set tpn(17) {"filter hipas" "filter hipas(n)" "filter lopas" "filter lopas(n)" \
				  		"filter hipas+" "filter lopas+" "filter bandp" "filter bandp(n)" \
				  		"filter notch" "filter notch(n)" "filter bandp+" "filter notch+"}
	set tpn(18) {"graphic eq" "graph eq(bands)"}
	set tpn(19) {"do bands"}
	set tpn(20) {"arpeg on" "arpeg boost" "arpeg boost blw" "arpeg boost abv" \
				  		"arpeg on below" "arpeg on above" "arpeg once blw" "arpeg once abv"}
	set tpn(21) {"pluck"}
	set tpn(22) {"trace all" "trace above frq" "trace below frq" "trace btwn frqs"}
	set tpn(23) {"blur & trace"}
	set tpn(24) {"accumulate"}
	set tpn(25) {"exaggerate"}
	set tpn(26) {"focus"}
	set tpn(27) {"fold in"}
	set tpn(28) {"freeze amps" "freeze freqs" "freez amps+frqs"}
	set tpn(29) {"step thro"}
	set tpn(30) {"average"}
	set tpn(31) {"blur"}
	set tpn(32) {"supress"}
	set tpn(33) {"chorus(amps)" "chorus(frqs)" "chorus(frqs up)" "chorus(frqs dn)" \
	  			  		"chorus(a+f)" "chorus(a+f up)" "chorus(a+f dn)"}
	set tpn(34) {"drunkwalk"}
	set tpn(35) {"shuffle"}
	set tpn(36) {"weave"}
	set tpn(37) {"noise"}
	set tpn(38) {"scatter"}
	set tpn(39) {"spread"}
	set tpn(40) {"lin shift(all)" "lin shift(abv)" "lin shift(blw)" "lin shift(btwn)" "lin shift(outs)"}
	set tpn(41) {"innerglis(shep)" "innerglis(inh)" "innerglis(self)"}
	set tpn(42) {"waver" "waver(user)"}
	set tpn(43) {"warp"}
	set tpn(44) {"invert" "invert(keepenv)"}
	set tpn(45) {"glide"}
	set tpn(46) {"bridge" "bridge" "bridge" "bridge" "bridge" "bridge"}
	set tpn(47) {"morph" "morph(cosin)"}
	set tpn(48) {"extract pitch" "extract pitch"}
	set tpn(49) {"track pitch" "track pitch"}
	set tpn(50) {"approx" "approx"}
	set tpn(51) {"exaggerate(rng)" "exaggerate(rng)" "exaggerate(cnt)" "exaggerate(cnt)" \
						"exaggerate(r+c)" "exaggerate(r+c)"}
	set tpn(52) {"invert" "invert"}
	set tpn(53) {"quantise" "quantise"}
	set tpn(54) {"randomise" "randomise"}
	set tpn(55) {"smooth" "smooth"}
	set tpn(56) {"transpose" "transpose"}
	set tpn(57) {"vibrato" "vibrato"}
	set tpn(58) {"cut from time" "cut to endtime" "cut btwn times"}
	set tpn(59) {"fix" "fix"}
	set tpn(60) {"repitch" "repitch" "repitch"}
	set tpn(61) {"repitch" "repitch" "repitch"}
	set tpn(62) {"transpose" "transpose" "transpose" "transpose"}
	set tpn(63) {"transpos(keep)" "transpos(keep)" "transpos(keep)" "transpos(keep)"}
	set tpn(64) {"extract fmnts"}
	set tpn(65) {"impose fmnts" "impose fmnts(+)"}
	set tpn(66) {"vocode"}
	set tpn(67) {"view fmnts"}
	set tpn(68) {"get &view fmnts"}
	set tpn(69) {"add pitch+fmnts"}
	set tpn(70) {"sum"}
	set tpn(71) {"difference"}
	set tpn(72) {"interleave"}
	set tpn(73) {"windowwise max"}
	set tpn(74) {"mean (a+p)" "mean (a+f)" "mean (amp1+p)" "mean (amp1+f)" \
				  "mean (amp2+p)" "mean (amp2+f)" "mean (maxamp+p)" "mean (maxamp+f)"}
	set tpn(75) {"cross channels"}
	set tpn(76) {"window count"}
	set tpn(77) {"show channel"}
	set tpn(78) {"show frequency"}
	set tpn(79) {"view level"}
	set tpn(80) {"print octbands"}
	set tpn(81) {"print energy"}
	set tpn(82) {"print frq peaks" "print frq peaks" "print frq peaks" "print frq peaks"}
	set tpn(83) {"print"}
	set tpn(84) {"info"}
	set tpn(85) {"check zeros"}
	set tpn(86) {"view" "view"}
	set tpn(87) {"to testtone"}
	set tpn(88) {"write"}
	set tpn(90) {"mono to multichan"}
	set tpn(91) {"multichan flutter"}
	set tpn(92) {"list varying peaks" "stream max no peaks" "stream best peaks" "list averaged peaks"}
	set tpn(93) {"mono to multichan shred" "multichan shred"}
	set tpn(94) {"multichan random zig" "multichan defined zig"}

	set tpn(95) {"place stereos in mchan"}
	set tpn(96) {"cut many at zeros" "cut many at zeros"}
	set tpn(97) {"chord (midi)" "chord (frq)"}
	set tpn(98) {"mix with function"}
	set tpn(99) {"maxsamp in range"}
	set tpn(100) {"cyclecnt"}
	set tpn(101) {"distort(maxsqr)" "distort(square)" "distort(maxtri)" "distort(triang)" \
				   "distort(invert)" "distort(click)" "distort(sine)" "distort(exagg)"}
	set tpn(102) {"distrt env rise" "distrt env fall" "distrt env trof" "distrt env user"}
	set tpn(103) {"distort average"}
	set tpn(104) {"distort omit"}
	set tpn(105) {"distort multply"}
	set tpn(106) {"distort divide"}
	set tpn(107) {"distort harmnic"}
	set tpn(108) {"distort fractal"}
	set tpn(109) {"distort reverse"}
	set tpn(110) {"distort shuffle"}
	set tpn(111) {"distort repeat"}
	set tpn(112) {"distort interp"}
	set tpn(113) {"distort delete" "distort del(l)" "distort del(w)"}
	set tpn(114) {"distort replace"}
	set tpn(115) {"distort telescp"}
	set tpn(116) {"distort filt(h)" "distort filt(l)" "distort filt(b)"}
	set tpn(117) {"dist interleave" "distort resize"}
	set tpn(118) {"distort pitch"}
	set tpn(119) {"zigzag(rand)" "zigzag(user)"}
	set tpn(120) {"loop (to end)" "loop (duration)" "loop (n times)"}
	set tpn(121) {"scramble" "scrambl(&again)"}
	set tpn(122) {"iterate(dur)" "iterate(count)"}
	set tpn(123) {"drunk" "drunk+sober"}
	set tpn(124) {"texture on hf" "texture on hfs" "texture on hs" "texture on hss" "neutral texture"}
	set tpn(125) {"groups on hf" "groups on hfs" "groups on hs" "groups on hss" "groups texture"}
	set tpn(126) {"decor on hf" "decor on hfs" "decor on hs" "decor on hss" "decor texture"}
	set tpn(127) {"predecor hf" "predecor hfs" "predecor hs" "predecor hss" "predecor textur"}
	set tpn(128) {"postdecor hf" "postdecor hfs" "postdecor hs" "postdecor hss" "postdec texture"}
	set tpn(129) {"ornate on hf" "ornate on hfs" "ornate on hs" "ornate on hss" "ornate texture"}
	set tpn(130) {"preornate hf" "preornate hfs" "preornate hs" "preornate hss" "preorn texture"}
	set tpn(131) {"postornat hf" "postornat hfs" "postornat hs" "postornat hss" "postorn texture"}
	set tpn(132) {"motifs on hf" "motifs on hfs" "motifs on hs" "motifs on hss" "motifs texture"}
	set tpn(133) {"motifs in hf" "motifs in hfs" "motifs in hs" "motifs in hss"}
	set tpn(134) {"timed on hf" "timed on hfs" "timed on hs" "timed on hss" "timed texture"}
	set tpn(135) {"timed grps hf" "timed grps hfs" "timed grps hs" "timed grps hss" "timed groups"}
	set tpn(136) {"timed mtf on hf" "timed mtf onhfs" "timed mtf on hs" "timed mtf onhss" "timed motifs"}
	set tpn(137) {"timed mtf in hf" "timed mtf inhfs" "timed mtf in hs" "timed mtf inhss"}
	set tpn(138) {"grain count"}
	set tpn(139) {"grain omit"}
	set tpn(140) {"grain duplicate"}
	set tpn(141) {"grain reorder"}
	set tpn(142) {"grain repitch" "grn repitch rpt"}
	set tpn(143) {"grain rerhythm" "grn rerhytm rpt"}
	set tpn(144) {"grain remotif" "grn remotif rpt"}
	set tpn(145) {"grain timewarp"}
	set tpn(146) {"grain get"}
	set tpn(147) {"grain position"}
	set tpn(148) {"grain align"}
	set tpn(149) {"grain reverse"}
	set tpn(150) {"envel create" "envel create"}
	set tpn(151) {"envel extract" "envel extract"}
	set tpn(152) {"envel impose" "envel impose" "envel impose" "envel impose"}
	set tpn(153) {"envel replace" "envel replace" "envel replace" "envel replace"}
	set tpn(154) {"envel normalise" "env time retro" "envel exagg" "envel attenuate" "envel lift" \
				   "envel t-stretch" "envel flatten" "envel gate" "envel invert" "envel limit" \
				   "envel corrugate" "envel expand" "envel triggers" "envel to ceiling" "envel ducked"}
	set tpn(155) {"envel normalise" "env time retro" "envel exagg" "envel attenuate" "envel lift" \
				   "envel t-stretch" "envel flatten" "envel gate" "envel invert" "envel limit" \
				   "envel corrugate" "envel expand" "envel triggers" "envel to ceiling" "envel ducked"}
	set tpn(156) {"envel normalise" "env time retro" "envel exagg" "envel attenuate" "envel lift" \
				   "envel t-stretch" "envel flatten" "envel gate" "envel invert" "envel limit" \
		 		  "envel corrugate" "envel expand" "envel triggers" "envel to ceiling" "envel ducked"}
	set tpn(157) {"dovetail"}
	set tpn(158) {"curtail(xtoy)" "curtail(dur)" "curtail(xtoend)" "curtail(xtoy)" "curtail(dur)" "curtail(xtoend)"} 
	set tpn(159) {"swell"}
	set tpn(160) {"attack(at gate)" "attack(near)" "attack(at time)" "attack(at max)"}
	set tpn(161) {"pluck"}
	set tpn(162) {"tremolo (frq)" "tremolo (pitch)"}
	set tpn(163) {"to brk"}
	set tpn(164) {"to db-brk"}
	set tpn(165) {"to binary"}
	set tpn(166) {"db to binary"}
	set tpn(167) {"to db"}
	set tpn(168) {"to db"}
	set tpn(169) {"merge sounds"}
	set tpn(170) {"crossfade" "crossfade (cos)"}
	set tpn(171) {"mix interleave"}
	set tpn(172) {"inbetweening" "inbetween(vals)"}
	set tpn(173) {"mix"}
	set tpn(174) {"mix maxlevel" "mix clip times" "mix level &clips"}
	set tpn(175) {"attenuate mix"}
	set tpn(176) {"duplicate lines" "reverse names" "scatter names" "all take name 1" \
				   "omit lines" "omit odd lines" "duplic + rename"}
	set tpn(177) {"sort entry times" "reverse timing" "reverse all" "freeze timegaps" \
	  			   "frz gaps+names" "scatter times" "shuffl up times" "add to timegaps" \
		 		  "create gaps 1" "create gaps 2" "create gaps 3" "create gaps 4" \
		 		  "enlarge gaps 1" "enlargegaps 2" "enlargegaps 3" "enlargegaps 4"}
	set tpn(178) {"fix position" "narrow" "move leftwards" "move rightwards" \
		 		   "spatial scatter" "space scat l:r" "twist whole mix" "twist a line"}
	set tpn(179) {"sync at middle" "sync at end"}
	set tpn(180) {"sync attack"}
	set tpn(181) {"test mix"}
	set tpn(182) {"format"}
	set tpn(183) {"overlay mixfile" "end-to-end mixfile" "chan-to-chan mixfile"}
	set tpn(184) {"variable mix"}
	set tpn(185) {"filter below" "filter above" "filter around"}
	set tpn(186) {"lopass/hipass" "lopass/hipass"}
	set tpn(187) {"varifilt hi" "varifilt lo" "varifilt band" "varifilt notch"}
	set tpn(188) {"filtbank harms" "filtbank oddhms" "filtbank subhms" \
				   "filtbank offset" "filtbank number" "filtbank intvls"}
	set tpn(189) {"fltbank harms?" "fltbank oddhms?" "fltbank subhms?" \
				   "fltbank offset?" "fltbank number?" "fltbank intvls?"}
	set tpn(190) {"filter userbank" "filter userbank"}
	set tpn(191) {"filter varibank" "filter varibank"}
	set tpn(192) {"sweep hipass" "sweep lopass" "sweep bndpass" "sweep notch"}
	set tpn(193) {"iterated filter" "iterated filter"}
	set tpn(194) {"phase shift" "phasing"}
	set tpn(195) {"gain" "dBgain" "normalise" "force level" "balance srcs" "invert phase" \
				"find loudest" "equalise loudness" "trem frqwise" "trem pitchwise" "timescaled env" "timescaled dB env" }
	set tpn(196) {"pan" "mirror" "mirror pandata" "narrow"}
	set tpn(197) {"transpose(ratio)" "transpose(semitones)" \
					    "transpose(ratio)info" "transpose(semitones)info" \
						"tape accel" "tape vibrato"}
	set tpn(198) {"delay/reverb" "varidelay" "stadium echo"}
	set tpn(199) {"brass pitchshft" "brassage timestr" "brassage reverb" "brassage scrambl" \
				   "brass granulate" "brassage" "brassage full"}
	set tpn(200) {"sausage"}
	if {[info exists modify_version] && ($modify_version >= 9)} {
		set tpn(201) {"reverse" "shred" "scrub" "low resolution" "ring modulate" "cross modulate"}
	} else {
		set tpn(201) {"reverse" "shred" "scrub" "low resolution" "ring modulate" "cross modulate" "bit quantise"}
	}
	set tpn(202) {"pvoc analysis" "pvoc anal(env)" "pvoc anal(mag)"}
	set tpn(203) {"pvoc synthesis"}
	set tpn(204) {"pvoc extract"}
	set tpn(206) {"cutout and keep" "cutout and keep" "cutout and keep"}
	set tpn(207) {"cutend and keep" "cutend and keep" "cutend and keep"}
	set tpn(208) {"cut at zeros" "cut at zeros" "cut at zeros"}
	set tpn(209) {"remove segment" "remove segment" "remove segment"}
	set tpn(210) {"remove segments" "remove segments" "remove segments"}
	set tpn(211) {"insert sound" "insert sound" "insert sound"}
	set tpn(212) {"insert silence" "insert silence" "insert silence"}
	set tpn(213) {"join"}
	set tpn(214) {"copy" "multicopies"}
	set tpn(215) {"extract channel" "extract chans" "zero a channel" "stereo to mono" "mono to stereo"}
	set tpn(216) {"select & clean" "preview extract" "top and tail" "remove d.c." "" "get onsets"}
	set tpn(217) {"change samprate" "" ""}
	set tpn(218) {"bundle all" "bundle non-text" "bundle type=" "bundl props=" "bundl chans="}
	set tpn(219) {"sort by filetyp" "sort by srate" "sort by dur" "sort by log-dur" "in dur order" "find rogues"}
	set tpn(220) {"store as 1 sndfile"}
	set tpn(221) {"recover filedump"}
	set tpn(222) {"diskspace"}
	set tpn(223) {"properties"}
	set tpn(224) {"duration"}
	set tpn(225) {"list snd durs"}
	set tpn(226) {"sum durations"}
	set tpn(227) {"subtract durs"}
	set tpn(228) {"time->sampcnt" "time->smpsets"}
	set tpn(229) {"sampcnt->time" "smpsets->time"}
	set tpn(230) {"max sample"}
	set tpn(231) {"loudest channel"}
	set tpn(232) {"largest hole"}
	set tpn(233) {"compare files"}
	set tpn(234) {"compare chans"}
	set tpn(235) {"print"}
	set tpn(237) {"synth sine" "synth square" "synth saw" "synth ramp"}
	set tpn(238) {"synth noise"}
	set tpn(239) {"make silentfile"}
	set tpn(248) {"spec freeze2"}
	set tpn(249) {"remove copies"}
	set tpn(251) {"silence masks"}
	set tpn(252) {"random sliced"}
	set tpn(253) {"random chunks"}
	set tpn(254) {"sinusoidal pan"}
	set tpn(255) {"repetitions"}
	set tpn(256) {"multichan mix"}
	set tpn(257) {"join analfiles"}
	set tpn(258) {"convert to text"}
	set tpn(259) {"stretch using fofs"}
	set tpn(260) {"duplicate fofs"}
	set tpn(261) {"delete fofs"}
	set tpn(262) {"stretchtrans fofs"}
	set tpn(263) {"get one formant"}
	set tpn(264) {"impose one formant"}
	set tpn(265) {"pitch + one formant"}
	set tpn(266) {"grab+use fofs"}
	set tpn(267) {"chop up at fofs"}
	set tpn(268) {"interp between fofs"}
	if {$gate_version < 6} {
		set tpn(269) {"gate"}
	} else {
		set tpn(269) {"gate" "gate shorten"}
	}
	set tpn(270) {"add features via fofs"}
	set tpn(271) {"fof imposed on synth"}
	set tpn(272) {"fof imposed on 2nd snd"}
	set tpn(273) {"fof subharms+transpos"}
	set tpn(274) {"spatialise fofs"}
	set tpn(275) {"interp fofs of 2 snds"}
	set tpn(276) {"replace fofs by other fofs"}
	set tpn(277) {"sustain fof within sound"}
	set tpn(278) {"nearest grain time"}
	set tpn(279) {"cut at grain time"}
	set tpn(280) {"remove pitch component"}
	set tpn(281) {"sustain explicit fof"}
	set tpn(282) {"add silence at start"}
	set tpn(283) {"speedchange multichan" "transpose multichan" accel multichan" "vibrato multichan"}
	set tpn(284) {"reinforce fof(in)harmonics"}
	set tpn(285) {"get partials contour"}
	set tpn(286) {"morph partials"}
	set tpn(287) {"iter space: give dur" "iter space: give repets"}
	set tpn(289) {"hfield chords"}
	set tpn(290) {"hset chords"}
	set tpn(291) {"delay perms"}
	set tpn(292) {"delay perms"}
	set tpn(293) {"specband synth"}
	set tpn(294) {"clip with noise" "clip with oscil"}
	set tpn(295) {"sequential fileswitches" "nonsequential fileswitches" "random fileswitches" "test times" "see envelope" "get times"}
	set tpn(296) {"sequential sphinx" "nonsequential sphinx" "random sphinx"}
	set tpn(297) {"list levels"}
	set tpn(298) {"spectrum over pitch"}
	set tpn(299) {"unpitch at sectimes"	"unpitch at samptimes"}
	set tpn(300) {"pitch to silence"}
	set tpn(301) {"noise by silence"}
	set tpn(302) {"silence at sectimes"	"silence at samptimes"}
	set tpn(303) {"envelope from analfile"}
	set tpn(304) {"pitch+formants+envelope"}
	set tpn(305) {"vowels over pitch"}
	set tpn(306) {"store as filedump"}
	set tpn(307) {"chop at amp zeros"}
	set tpn(308) {"mixfile on timegrid"}
	set tpn(309) {"pitch from notes:midi"}
	set tpn(310) {"interp pitch: glide" "interp pitch: sustain"}
	set tpn(311) {"mixmany with function"}
	set tpn(312) {"cut many segments"}
	set tpn(313) {"stack"}
	set tpn(314) {"impose vowels"}
	set tpn(315) {"envel proportional"}
	set tpn(316) {"pan proportional"}
	set tpn(317) {"merge many sounds"}
	set tpn(318) {"impose pulsetrain" "synth pulsetrain" "synth pulsetrain(i)"}
	set tpn(319) {"suppress noise"}
	set tpn(320) {"time grids"}
	set tpn(321) {"sequencer"}
	set tpn(322) {"convolve" "timevarying convolve"}
	set tpn(323) {"back to back"}
	set tpn(324) {"add to mix"}
	set tpn(325) {"replace segment"}
	set tpn(326) {"pan mix positions"}
	set tpn(327) {"shudder"}
	set tpn(328) {"timestepped mixfile"}
	set tpn(329) {"find pan pos"}
	set tpn(330) {"click between times" "click between lines"}
	set tpn(331) {"doublets"}
	set tpn(332) {"syllables"}
	set tpn(333) {"join in pattern"}
	set tpn(334) {"make vfilters"}
	set tpn(335) {"batchfile model"}
	set tpn(336) {"mixfile new sounds"}
	set tpn(337) {"inbetween zerosyncd"}
	set tpn(338) {"loudness pattern"}
	set tpn(339) {"freeze by iteration"}
	set tpn(340) {"distrt repet < maxfrq"}
	set tpn(341) {"remove edge clicks"}
	set tpn(342) {"convert to text"}
	set tpn(343) {"create cyclic env"}
	set tpn(344) {"multisound sequencer"}
	set tpn(345) {"extend iterative"}
	set tpn(346) {"remove glitches"}
	set tpn(347) {"assess grains"}
	set tpn(348) {"filter varipartials"}
	set tpn(349) {"distort repeat-skip"}
	set tpn(350) {"sndinfo zerocross"}
	set tpn(351) {"extend noise"}
	set tpn(352) {"grain btwn troughs"}
	set tpn(353) {"multidelay+pos"}
	set tpn(354) {"room->reverbdata"}
	set tpn(355) {"reverb of room"}
	set tpn(356) {"room res to filtdata"}
	set tpn(357) {"room res to analfile"}
	set tpn(358) {"add room res"}
	set tpn(359) {"subtract room res"}
	set tpn(360) {"clean better"}
	set tpn(361) {"clean by subtract"}
	set tpn(362) {"invert phase" "enhance stereo"}
	set tpn(363) {"features"}
	set tpn(364) {"convert to binary"}
	set tpn(365) {"slice or pivot"}
	set tpn(366) {"all FOFs to FOF-file" "extract one FOF" "extract all FOFs"}
	set tpn(367) {"FOFconstr single" "FOFconstr all" "FOFconstr low" "FOFconstr mid" "FOFconstr high" "FOFconstr 2 FOFs" "FOFconstr 3 FOFs"}
	set tpn(368) {"extend grainy part"}
	set tpn(369) {"list peaktimes"}
	set tpn(370) {"shorten zerosegs"}
	set tpn(371) {"curtail exponential"}
	set tpn(372) {"peaks at tempo" "get peak-isolate env"}
	set tpn(373) {"multichannel pan" "multichan switching" "multichan stepspread" "multichan panspread" "antiphonal events" "antiphonal sounds" \
					"cross centre" "pan process" "rotate mono" "multichan randswitch"}
	set tpn(374) {"multichannel texture"}
	set tpn(375) {"insert silences"}
	set tpn(376) {"sync specd peaks" "rerhythm peaks" "narrow peaks" "regular pulse peaks" "varispeed peaks" "reposition at beats" "reposition at times" \
					"repeat event" "mask events" "accent pattern" "shortest event" "find snd start" "move found peak" "move specifd peak"}
	set tpn(378) {"hovering zigzag"}
	set tpn(379) {"multichan mix" "multimix endtoend" "multimix timestep" "1 stereo to 4of8" "1 stereo to 8" "N mono to N outchs" "N mono to K outchs" "N files to K outchans"}
	set tpn(380) {"frame rotate" "double rotate" "frame reorient" "frame mirror" "frame bilateral" "swap two chans" "modify some chans" "frame BEAST"}
	set tpn(381) {"search sigstart"}
	set tpn(382) {"multichan revecho"}
	set tpn(383) {"moving multibrassage"}
	set tpn(391) {"specsphinx chanamp" "specsphinx multiply" "spec carve"}
	set tpn(392) {"superaccum" ""superaccum tempered" "superaccum tuned"  "superaccum HF tuned"}
	set tpn(393) {"to grids:use wavesets" "to grids:use durations"}
	set tpn(394) {"partition spectrum"}
	set tpn(395) {"glisten spectrum"}
	set tpn(396) {"varitune spectrum"}
	set tpn(397) {"isolate segments" "isolate set of segs" "isolate by threshold" "whole file to segs" "file to ovlaping segs" }
	set tpn(398) {"rejoin segments" "rejoin segs & remnant"}
	set tpn(399) {"panorama cnt and sprd" "panorama list lspkr pos"}
	set tpn(400) {"squeezed trem (frq)" "squeezed trem (pitch)"}
	set tpn(401) {"create echos"}
	set tpn(402) {"find soundpacket" "force soundpacket"}
	set tpn(403) {"complex tones" "wave-packet strms" "glistening" "fractal spikes"}
	set tpn(404) {"snd tangnt to 8ring (far)" "snd tangnt to 8ring"}
	set tpn(405) {"sndpair tangnt to 8ring(far)" "sndpair tangnt to 8ring"}
	set tpn(406) {"seqnce tangnt to 8ring(far)" "seqnce tangnt to 8ring"}
	set tpn(407) {"seqlist tangnt to 8ring(far)" "seqlist tangnt to 8ring"}
	set tpn(408) {"spec crossbreed 1" "spec crossbreed 2" "spec crossbreed 3" "spec crossbreed 4"}
	set tpn(409) {"cross 8ring:glance" "cross 8ring:edgewise" "cross 8ring:cross" "cross 8ring:close" "cross 8ring:central"}
	set tpn(410) {"cross 8ring+filt:glance" "cross 8ring+filt:edgewise" "cross 8ring+filt:cross" "cross 8ring+filt:close"  "cross 8ring+filt:central" }
	set tpn(411) {"cross 8ring+dopl:glance" "cross 8ring+dopl:edgewise" "cross 8ring+dopl:cross" "cross 8ring+dopl:close"  "cross 8ring+dopl:central" }
	set tpn(412) {"cross 8ring+dop+filt:glance" "cross 8ring++dop+filt:edgewise" "cross 8ring+dop+filt:cross" "cross 8ring+dop+filt:close"  "cross 8ring+dop+filt:central" }
	set tpn(413) {"seqnce cross8ring:glance" "seqnce cross8ring:edgewise" "seqnce cross8ring:cross" "seqnce cross8ring:close" "seqnce cross8ring:central"}
	set tpn(414) {"sndlist cross8ring:glance" "sndlist cross8ring:edgewise" "sndlist cross8ring:cross" "sndlist cross8ring:close" "sndlist cross8ring:central"}
	set tpn(415) {"cantor set holes" "cantor holes fixedsize" cantor holes + sinenv"}
	set tpn(416) {"shrink from end" "shrink from middle" "shrink from start" "shrink around time" "shrink at found peaks"  "shrink at specified peaks"}
	set tpn(417) {"spatialised texture 1" "spatialised texture 2" "spatialised texture 3"}
	set tpn(418) {"cyclic polyrhythm"}
	set tpn(419) {"spatialised accents" "spatialised accents on seq"}
	set tpn(420) {"focus-shift streams 1 snd" "focshift streams: many snds" }
	set tpn(421) {"fracture static" "fracture moving"}
	set tpn(422) {"subtract"}
	set tpn(423) {"specline spectrum" "speclines filter"}
	set tpn(424) {"morphdiff average" "morphdiff cos average" "morphdiff momentwise" "morphdiff cos momentwise" "morphdiff tune" "morphdiff cos tune" "morphdiff intermediates"}
	set tpn(425) {"extract peak frqs" "morph to peak frqs" "cosmorph to peak frqs"}
	set tpn(426) {"pitch by delay" "pitch head by delay"}
	set tpn(427) {"fixed random filter" "timevarying rand filter"}
	set tpn(428) {"iterate on interpd pitchline" "iterate on stepped pitchline"}
	set tpn(429) {"iterate set on interpd pitchline" "iterate set on stepped pitchline"}
	set tpn(431) {"time-randomise spectrum"}
	set tpn(432) {"squeeze frq-range of spectrum"}
	set tpn(433) {"hovering zigzag at zerocrossings"}
	set tpn(434) {"make spectrum self-similar"}
	set tpn(435) {"packet transpositions" "packet step-transpositions" "packet on MIDI glide" "packet on MIDI steps" }
	set tpn(436) {"brightness packets" "src packets" "random src packets"}
	set tpn(437) {"multi-src brightness packets" "multi-src packets" "random multi-src packets"}
	set tpn(438) {"fixed spectral packets" "timevaried spectral packets" "randvaried spectral packets" }
	set tpn(439) {"sound from Chirikov map" "sound from Circular map" "pitchdata from Chirikov map" "pitch data from Circular map"}
	set tpn(440) {"oscil of oscil" "oscil of osc of osc" "oscil of osc of osc of osc"}
	set tpn(441) {"filtnoise pitched" "filtnois multipitched"}
	set tpn(442) {"banded flow data" "banded flow sounds" "banded flow data, thrdcnts differ"}
	set tpn(443) {"random layers" "rising layers" "falling layers" "rise/fall cycling layers" "fall/rise cycling layers"}
	set tpn(447) {"invert channel phase"}
	set tpn(448) {"extend with silence of dur" "expand to dur, with silence"}
	set tpn(449) {"speculation"}
	set tpn(450) {"tune to tempered scale" "tune to tuning set" "tune to any 8va of tuning set" "report pitch"}
	set tpn(451) {"reconstruct multichannel"}
	set tpn(452) {"distort shift" "distort pairwise-swap"}
	set tpn(453) {"distort powscale wavesets" "distort powscale all"}
	set tpn(454) {"cyclers fixed-timestep" "cyclers variable-timetep" "cyclers edge-overlayed"}
	set tpn(455) {"distort cut+env disjunct" "distort cut+env independent"}
	set tpn(456) {"cut+env disjunct" "cut+env independent"}
	set tpn(458) {"fold spectrum" "invert spectrum" "randomise spectrum"}	
	set tpn(459) {"brownian motion synth" "brownian motion src"}	
	set tpn(460) {"spin stereo" "spin stereo in multichan" "spin stereo multichan sqzd"}	
	set tpn(461) {"spin 2 stereos" "spin 2 stereos squeezed"}	
	set tpn(462) {"disintegrate to 8 chans" disintegrate to 16 chans"}	
	set tpn(463) {"tesselate space+time"}	
	set tpn(465) {"phasing of source"}	
	set tpn(466) {"crystal rotate mono" "crystal rotate stereo" "crystal multich 2-offset" "crystal multich 2-offset clkwise" "crystal multich 2-offset anticlkw" "crystal multich 2-offset rand" \	
					"crystal multich 2-adj clkwise" "crystal multich 2-adj anticlkw" "crystal multich 2-adj rand" "crystal multifile out"}
	set tpn(467) {"waveform from wavesets" "waveform from mS sample" "waveform on sinusoid"}
	set tpn(468) {"shrink by skipping"}
	set tpn(469) {"cascade segs N-chan" "cascade segs L to R" "cascade segs centre to L/R" "cascade segs 8-chan clock" "cascade segs 8ch clk/anticlk" \
				  "cascade cuts N-chan" "cascade cuts L to R" "cascade cuts centre to L/R" "cascade cuts 8-chan clock" "cascade cuts 8ch clk/anticlk"}
	set tpn(470) {"synth with rand overtones"}
	set tpn(471) {"fractal from waveform" "fractal over source snd"}
	set tpn(472) {"fractal over spectrum"}
	set tpn(473) {"falling splinters before" "rising splinters after" "steady splinters before" "steady splinters after"}
	set tpn(474) {"play with repeat segs(delay)" "play with repeat segs(offset)"}
	set tpn(475) {"add glissed accents to sound"}
	set tpn(476) {"motor:1src:fwd&bak" "motor:slice1src:fwd&bak" "motor:>1src:fwd&bak" "motor:1src:fwd" "motor:slice1src:fwd" "motor:>1src:fwd" \
					"motor:1src:fwdorbak" "motor:slice1src:fwdorbak" "motor:>1src:fwdorbak" }
	set tpn(477) {"Stutter: cut elements & stream"}
	set tpn(478) {"scramble wavesets random" "scramble wavesets permuted" "order wavesets increasing size"  "order wavesets decreasing size" \
					"order wvsets of segs, incr" "order wvsets of segs, decr" "order wvsets of segs inc-decr"  "order wvsets of segs decr-incr" \
					"order wavesets crescendo"  "order wavesets decrescendo" \
					"wvsets of segs, cresc" "wvsets of segs, decresc" "wvsets of segs cresc-decresc"  "wvsets of segs decresc-cresc" }
	set tpn(479) {"generate impulse (stream)"}
	set tpn(480) {"replace FOFs by vari-chirps" "replace FOFs by fixed chirps" "replace FOFs by noise"}
	set tpn(481) {"\"Bouncing\" repetition"}
	set tpn(482) {"Reorder sound elements" "by crescendo" "by decrescendo" "by accelerando" "by ritardando" "at random"}
	set tpn(483) {"Narrow formants" "Squeeze around formant" "Invert formants" "Rotate formants" \
				  "Spectral negative" "Suppress formants" "Filter from formants" "Move formants by" "Move formants to"  \
				  "Arpeggiate spectrum" "8va-shift under fmnts" "Transpose under fmnts" "Frqshift under fmnts"  \
				  "Respace partials" "Pitch-invert under fmnts" "Pitch-exag under fmnts" "Quantise pitch under fmnts" "Pitch randomise under fmnts" \
				  "Randomise spectrum under fmnts" "See spectral envelopes" "List peaks:trofs in spectrum" "list trof-times between syllabs" "sinus speech"}
	set tpn(484) {"Equalise level of elements"}
	set tpn(488) {"Waveset interp btwn markers"}
	set tpn(496) {"Waveset repet spliced tstretched" "Waveset repet spliced"}
	set tpn(497) {"Mono-merge to true-stereo"}
	set tpn(498) {"Suppress partials in bands"}
	set tpn(499) {"Blur high frq band"}
	set tpn(500) {"Impose spectral envelope"}
	set tpn(503) {"Clip peaks at given level" "Clip peaks of wavesets"}
	set tpn(504) {"timestretch with randomisation"}
# PSEUDO-PROCESSES
	set tpn(1000) {"slice"}
	set tpn(1001) {"snip"}
	set tpn(1003) {"stretchabout"}
}

#####################################################################
#	RETRIEVING THE PARAMETERS USED IN PREVIOUS RUN OF EACH PROGRAM	#
#####################################################################

#------ Get values of params last used in each of programs, from file

proc GetLastRunValsFromFile {} {
	global lastrunvals penultrangetype prg ins evv

	set fnam [file join $evv(URES_DIR) $evv(LASTRUNVALS)$evv(CDP_EXT)]

	if [file exists $fnam] {
		if [catch {open $fnam r} fileId] {
			Inf "Cannot open file of Last Run Values"
			return		
		}
	} else {
		return
	}

	set data_complete 0

	while { [gets $fileId line] >= 0} {			;#	Read lines from file
		switch -- $data_complete {
			0 { set val_line $line }
			1 { set rng_line $line }
		}
		if {$data_complete} {
			set validname 0
			if {([llength $val_line] >= 2) && ([llength $rng_line] >= 1)} {
				set validname 1
				set index [lindex $val_line 0]
			}
			if {$validname} {
				if [regexp {^[0-9]+,[0-9]+$} $index] {
					set i [string first , $index]
					incr i -1
					set progno [string range $index 0 $i]
					if {![info exists prg($progno)]} {
						set validname 0		;#	Forget names with invalid program numbers
					}
					if {$validname} {
						incr i 2
						set modeno [string range $index $i end]
						set modecnt [lindex $prg($progno) $evv(MODECNT_INDEX)]
						if {$modeno > $modecnt} {
							set validname 0		;#	Forget names with invalid mode numbers
						}
					}
				} else {
					set validname 0
					foreach mname $ins(names) {
						if [string match $mname $index] {
							set validname 1
							break
						}
					}
				}
			}
			if {$validname} {
				set lastrunvals($index) [lrange $val_line 1 end]
				set penultrangetype($index) $rng_line
			}
		}
		set data_complete [expr !$data_complete]
	}											;#	Automatically forgets any unpaired line at end of file
	close $fileId
}

################################################
#	CHECK WHICH CDP EXECUTABLES ARE ON SYSTEM  #
################################################

proc CheckExecs {} {
	global cdpmenu execslist execscnt sl_real sndgraphics evv
	set modifychecked 0

	set i 0
	while {$i < $evv(MAXMENUNO)} {
		set umbrellaname [lindex $cdpmenu($i) 0]
		switch  -- $umbrellaname {
			"EDIT" {
				if [file exists [file join $evv(CDPROGRAM_DIR) sfedit$evv(EXEC)]] {
					lappend execslist $i
				} else {
					set editprog [file join $evv(CDPROGRAM_DIR) editsf$evv(EXEC)]
					if {[file exists $editprog]} {
						set pwd [pwd]
						cd $evv(CDPROGRAM_DIR)
						if {![catch {file rename editsf$evv(EXEC) sfedit$evv(EXEC)} zit]} { 
							lappend execslist $i
						}
						cd $pwd
					}
				}
			}
			"DISTORT" {
				if [file exists [file join $evv(CDPROGRAM_DIR) distort$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"EXTEND" {
				if [file exists [file join $evv(CDPROGRAM_DIR) extend$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"CHANNELS" {
				if {[file exists [file join $evv(CDPROGRAM_DIR) housekeep$evv(EXEC)]] 
				&&  [file exists [file join $evv(CDPROGRAM_DIR) submix$evv(EXEC)]]} {
					lappend execslist $i
				}
			}
			"TEXTURE" {
				if [file exists [file join $evv(CDPROGRAM_DIR) texture$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"GRAIN" {
				if [file exists [file join $evv(CDPROGRAM_DIR) grain$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"ENVELOPE" {
				if [file exists [file join $evv(CDPROGRAM_DIR) envel$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"MIX" {
				if [file exists [file join $evv(CDPROGRAM_DIR) submix$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"FILTER" {
				if [file exists [file join $evv(CDPROGRAM_DIR) filter$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"SYNTHESIS" {
				if [file exists [file join $evv(CDPROGRAM_DIR) synth$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"FOFS" {
				if [file exists [file join $evv(CDPROGRAM_DIR) psow$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"PVOC" {
				if [file exists [file join $evv(CDPROGRAM_DIR) pvoc$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"SIMPLE" {
				if [file exists [file join $evv(CDPROGRAM_DIR) spec$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"STRETCH" {
				if [file exists [file join $evv(CDPROGRAM_DIR) stretch$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"HIGHLIGHT" {
				if [file exists [file join $evv(CDPROGRAM_DIR) hilite$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"FOCUS" {
				if [file exists [file join $evv(CDPROGRAM_DIR) focus$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"BLUR" {
				if [file exists [file join $evv(CDPROGRAM_DIR) blur$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"FORMANTS" {
				if [file exists [file join $evv(CDPROGRAM_DIR) formants$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"STRANGE" {
				if [file exists [file join $evv(CDPROGRAM_DIR) strange$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"PITCH:HARMONY" {
				if [file exists [file join $evv(CDPROGRAM_DIR) pitch$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"REPITCH" {
				if [file exists [file join $evv(CDPROGRAM_DIR) repitch$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"COMBINE" {
				if [file exists [file join $evv(CDPROGRAM_DIR) combine$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"MORPH" {
				if [file exists [file join $evv(CDPROGRAM_DIR) morph$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"SOUND INFO" {
				if [file exists [file join $evv(CDPROGRAM_DIR) sndinfo$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"SPECTRAL INFO" {
				if [file exists [file join $evv(CDPROGRAM_DIR) specinfo$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"PITCH INFO" {
				if [file exists [file join $evv(CDPROGRAM_DIR) pitchinfo$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"HOUSEKEEP" {
				if [file exists [file join $evv(CDPROGRAM_DIR) housekeep$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"LOUDNESS"	{
				if [file exists [file join $evv(CDPROGRAM_DIR) modify$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"SPACE"	{
				if [file exists [file join $evv(CDPROGRAM_DIR) modify$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"PITCH:SPEED" {
				if [file exists [file join $evv(CDPROGRAM_DIR) modify$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"REVERB:ECHO" {
				if [file exists [file join $evv(CDPROGRAM_DIR) modify$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"BRASSAGE"	{
				if [file exists [file join $evv(CDPROGRAM_DIR) modify$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"RADICAL" {
				if [file exists [file join $evv(CDPROGRAM_DIR) modify$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"HARMONIC FLD" {
				if [file exists [file join $evv(CDPROGRAM_DIR) hfperm$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"DATA CREATE" {
				if [file exists [file join $evv(CDPROGRAM_DIR) hfperm$evv(EXEC)]] {
					lappend execslist $i
				}
			}
			"MULTICHAN" {
				if {[file exists [file join $evv(CDPROGRAM_DIR) newmix$evv(EXEC)]]
				&& [file exists [file join $evv(CDPROGRAM_DIR) strans$evv(EXEC)]]} {
					lappend execslist $i
				}
			}
			"RHYTHM" {
				if {[file exists [file join $evv(CDPROGRAM_DIR) extend$evv(EXEC)]]} {
					lappend execslist $i
				}
			}
			"VOICEBOX" {
				if {[file exists [file join $evv(CDPROGRAM_DIR) specfnu$evv(EXEC)]]} {
					lappend execslist $i
				}
			}
		}
		incr i
	}
	if {![info exists execslist]} {
		if {$sl_real} {
			Inf "There are no executable CDP processes on your system.\n"
			return 0
		}
	} else {
		set execscnt [SortExecsToAscendingOrderWithoutDuplicates]
	}
	SetExecFlags
	set sndgraphics [CheckSndGraphicsExecs]
	return 1
}

#------ Sort list into ascending order with no duplicates

proc SortExecsToAscendingOrderWithoutDuplicates {} {
	global execslist

	set len [llength $execslist]
	set lenlessone $len
	incr lenlessone -1
	set n 0
	while {$n < $lenlessone} {			;#	Sort
		set m $n
		incr m
		while {$m < $len} {
			if {[set lm [lindex $execslist $m]] < [set ln [lindex $execslist $n]]} {
				set execslist [lreplace $execslist $m $m $ln]
				set execslist [lreplace $execslist $n $n $lm]
			}
			incr m
		}
		incr n
	}
	set j -1
	set n 0
	set m 1
	while {$n < $lenlessone} {			;#	Eliminate duplicates
		if {[lindex $execslist $n] == [lindex $execslist $m]} {
			if {$n == 0} {
				set newlist	[lrange $execslist 1 end]
			} else {
				set newlist [lrange $execslist 0 $j]
				lappend newlist [lrange $execslist $m end]
			}
			set execslist $newlist
			incr lenlessone -1
		} else {
			incr j
			incr m
			incr n
		}
	}
	set len $lenlessone
	incr len
	return $len
}

#------ Set 'bitflag' to establish which execs are available

proc SetExecFlags {} {
	global execslist execscnt execsflag evv

	set done 0
	set j 0
	set k [lindex $execslist $j]
	set i 0
	while {$i < $evv(MAXMENUNO)} {
		if {$done || ($i < $k)} {
			append execsflag 0					;#	Unavailable progs will get 2 added to the 0 or 1 in pmask
		} else {
			append execsflag 1
			incr j
			if {$j >= $execscnt} {
				set done 1
			} else {
				set k [lindex $execslist $j]
			}
		}
		incr i
	}
}

proc CheckSys {} {
	global sl_real evv
	set sl_real 0
	if [file exists [file join $evv(CDPROGRAM_DIR) cdparams$evv(EXEC)]] {
		set sl_real 1
	} else {
		set msg "Cannot find any further CDP software on your system.\n\nSetting Up A Sound Loom Demo Instead."
		Inf $msg
	}
}

proc Demo_Only {} {
	global sl_real evv
	.cdphello.f.c create text 300 255 -text "Cannot find the CDP software." -font {times 15 bold}
	.cdphello.f.c create text 300 285 -text "Therefore this is a" -font {times 15}
	.cdphello.f.c create text 300 315 -text "DEMONSTRATION ONLY" -font {times 18 bold}
	set x 0
	after 3000 {set x 1}
	vwait x
	catch {file delete -force $evv(URES_DIR)}
	catch {file delete -force $evv(PATCH_DIRECTORY)}
	set evv(REDESIGN) 0
	return 1
}

####################################################
# ESTABLISH THE NAME AND LOCATION OF PLAY FUNCTION #
####################################################

#--- Assumptions here are 
#	PC command MAY have parameters, so directory is attached to 1st item in the cmd list,
#	and cmdlist is stored WITHOUT inverted commas around it (so it is retrieved as a true list).
#	MAC command has NO params (so is not a true list), but has gaps in the directory path (at least)
#	so directory is attached to the entire cmd 
#	BUT cmd is stored and retrieved WITH inverted commas around it.

proc EstablishPlayLocation {startup} {
	global evv play_dir playcmd pr_play playcmd_dummy playdir_dummy wstk system_initialisation devicelist device_val
	global startemph tcl_platform is_snowleopard pr_pcop CDPpcop pa

	set OK_cmd 0
	set OK_dir 0
	set abandon_it 0
	set playcmd_dummy ""
	set playdir_dummy ""
	set finished_cmd 0
	set finished_dir 0
	if {$system_initialisation} {

		switch -- $evv(SYSTEM) {
			SGI {
				set playcmd_dummy sfplay
#				set playdir_dummy ???
			}
			MAC {

				######################	INITIALISING NEW SYSTEM : SPECIFY THE OPERATING SYSTEM ######################

				set f .pcop
				set CDPpcop 0
				set pr_pcop 0
				if [Dlg_Create $f "Operating System" "set pr_pcop 0" -borderwidth 2 -height 24] {
					frame $f.0
					label $f.0.ll -text "Select Your Operating System"
					pack $f.0.ll -side top -pady 4 -pady 4
					frame $f.1
					radiobutton $f.1.0 -variable CDPpcop -text "OS X or earlier" -value 1 -command SetPCOpsystem
					radiobutton $f.1.1 -variable CDPpcop -text "Snow Leopard or later"    -value 2 -command SetPCOpsystem
					button $f.1.b -text OK -command "set pr_pcop 0" -highlightbackground [option get . background {}]
					pack $f.1.0 $f.1.1 -side left -padx 16 -pady 40
					pack $f.1.b -side right -padx 16 -pady 40
					pack $f.0 $f.1 -side top
					label $f.2 -text ""
					pack $f.2 -side top -pady 40
					wm resizable $f 1 1
				}
				raise $f
				set finished 1
				My_Grab 1 $f pr_pcop
				while {!$finished} {			
					tkwait variable pr_pcop
					switch -- $CDPpcop {
						0 {
							Inf "PLEASE SELECT YOUR OPERATING SYSTEM BY CLICKING ON ONE OF THE BUTTONS"
							continue
						}
						1 {
							set msg "YOU HAVE SELECTED \"OS X or earlier\".  IS THIS CORRECT ??"
						}
						2 {
							set msg "YOU HAVE SELECTED \"Snow Leopard or later\".  IS THIS CORRECT ??"
						}
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							catch {unset is_snowleopard}
							continue
						}
					}
				}
				My_Release_to_Dialog $f
				Dlg_Dismiss $f

				###################### ESTABLISH DEFAULT SOUND PLAYER FOR OPERATING SYSTEM IN USE ######################

				set fnam [file join $evv(CDPRESOURCE_DIR) snowleopard$evv(CDP_EXT)]
				if {[info exists is_snowleopard]} {
					if [catch {open $fnam "w"} zit] {
						Inf "Cannot open status file '$fnam' to remember you are running Snow Leopard or later"
					} else {
						close $zit
					}
				} else {
					catch {file delete $fnam}
				}
				SetupPlayProgram 0 1
			}
			LINUX {
#				set playcmd_dummy ?????
#				set playdir_dummy ???
#			}
		}

		###################### CHECK THAT THE DEFAULT SOUND PLAYER EXISTS ON USER'S SYSTEM ######################

		if {[file exists $playcmd$evv(EXEC)]} {

			foreach exxt $evv(SNDFILE_EXTS) {
				set fnam [file join $evv(CDPRESOURCE_DIR) $evv(TESTFILE)$exxt]
				if {[file exists $fnam]} {
					break
				}
			}
			if {![file exists $fnam]} {
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
				-message "Cannot test your play program\nas the testfile $evv(TESTFILE) is not on your system.\n\nDo you still wish to go ahead with the setup?"]
				if {$choice == "no"} {
					DoWkspaceQuit 0 1
				}
			} else {
				set pa($fnam,$evv(CHANS)) 1
				if {![PlaySndfile $fnam 0]} {
					set msg "The Default Player Cannot Play The Test Soundfile: Please Select Another Player"
					set carryon 1
				}
				unset pa($fnam,$evv(CHANS))
			}
			if {[file exists $fnam]} {
				set sndfile_ext [file extension $fnam]
				set evv(TESTFILE_A) $fnam
				set evv(TESTFILE_C)  [file join $evv(CDPRESOURCE_DIR) testfilec$sndfile_ext]
				set evv(TESTFILE_Db) [file join $evv(CDPRESOURCE_DIR) testfiledb$sndfile_ext]
				set evv(TESTFILE_D)  [file join $evv(CDPRESOURCE_DIR) testfiled$sndfile_ext]
				set evv(TESTFILE_Eb) [file join $evv(CDPRESOURCE_DIR) testfileeb$sndfile_ext]
				set evv(TESTFILE_E)  [file join $evv(CDPRESOURCE_DIR) testfilee$sndfile_ext]
				set evv(TESTFILE_F)  [file join $evv(CDPRESOURCE_DIR) testfilef$sndfile_ext]
				set evv(TESTFILE_Gb) [file join $evv(CDPRESOURCE_DIR) testfilegb$sndfile_ext]
				set evv(TESTFILE_G)  [file join $evv(CDPRESOURCE_DIR) testfileg$sndfile_ext]
				set evv(TESTFILE_Ab) [file join $evv(CDPRESOURCE_DIR) testfileab$sndfile_ext]
				set evv(TESTFILE_Bb) [file join $evv(CDPRESOURCE_DIR) testfilebb$sndfile_ext]
				set evv(TESTFILE_B)  [file join $evv(CDPRESOURCE_DIR) testfileb$sndfile_ext]
				set evv(TESTFILE_C2) [file join $evv(CDPRESOURCE_DIR) testfilec2$sndfile_ext]
			}

		######################### IF EVERYTHING WORKS OK, REMEMBER SOUND PLAYER, AND QUIT #######################

			if {![info exists carryon]} {
				return 1
			}
		}

	} elseif {$startup} {

		############################# IF NOT INITIALISATION OF NEW SYSTEM ################################

		######################## FIND USER'S OPERATING SYSTEM, AND PLAYCMD IN USE ########################


		set fnam [file join $evv(CDPRESOURCE_DIR) snowleopard$evv(CDP_EXT)]
		if {[file exists $fnam]} {
			set is_snowleopard 1
		}
		SetupPlayProgram 0 0

	} else {
		SetupPlayProgram 1 0
	}

	if {$system_initialisation} {
		Inf "If you want to CHANGE the play command or audio drivers LATER,\n\nyou can do this from the SYSTEM STATE menu on the workspace."
	}
	return 1
}

#-------- Show any info on version update
#RWD 2023 used PC code here - see commented-out lines																
proc DisplayUpdateInfo {} {
	global pr_udpate evv

	set bakup_valid 0
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(UPDATE_FILE)$evv(CDP_EXT)]
	if [file exists $fnam] {
		if [catch {open $fnam r} ufId] {
			tk_messageBox -type ok -message "Cannot get the version update information to display.\nThe file '$evv(UPDATE_FILE)$evv(CDP_EXT)' cannot be opened." -icon info
		} else {
			set lfnam [file join $evv(CDPRESOURCE_DIR) $evv(LAST_UPDATE_FILE)$evv(CDP_EXT)]
			if [catch {open $lfnam w} lufId] {
				tk_messageBox -type ok -message "Can't open file '$evv(LAST_UPDATE_FILE)$evv(CDP_EXT)'.\n\nIF YOU WANT TO KEEP VERSION UPDATE INFO, print the file '$evv(UPDATE_FILE)$evv(CDP_EXT)' in directory $evv(URES_DIR), NOW." -icon info
			} else {
				set bakup_valid 1
			}
			set f .update
			if [Dlg_Create $f "UPDATE INFORMATION" "set pr_update 0" -borderwidth 10] {
#				button $f.b0 -text "OK" -command "set pr_update 0" -highlightbackground [option get . background {}]
				button $f.b0 -text "OK" -command "set pr_update 0"
				Scrolled_Listbox $f.updates -width 96 -height 32 -selectmode single
				pack $f.b0 -side top
				pack $f.updates -side top -fill x -expand true
				bind $f <Return> {set pr_update 0}
				bind $f <Escape> {set pr_update 0}
				bind $f <Key-space> {set pr_update 0}
			}
			while {[gets $ufId line] >= 0} {
				$f.updates.list insert end $line
				if {$bakup_valid} {
					puts $lufId $line
				}
			}
			close $ufId
			wm resizable $f 1 1
			set pr_update 0
			raise $f
#			My_Grab 1 $f pr_update
            Simple_Grab 1 $f pr_update
			tkwait variable pr_update
			if {$bakup_valid} {
				close $lufId
			}
			if [catch {file delete $fnam} zab] {
				tk_messageBox -type ok -message "Cannot delete your update info file.\n\nDelete the file from your computer if you do not want to see this information\nevery time you start a session." -icon info
			} elseif {$bakup_valid} {	
				tk_messageBox -type ok -message \
				"The update information can now be found\nin the textfile       '$evv(LAST_UPDATE_FILE)$evv(CDP_EXT)'\nin the directory     '$evv(CDPRESOURCE_DIR)'\n\nIt will not be displayed in future sessions." -icon info
			}
#			My_Release_to_Dialog $f
            Simple_Release_to_Dialog $f
			Dlg_Dismiss $f
		}
	}
}

#--- Inform system of typical size of samples being used

proc GetSavedSamplesize {} {
	global sampsize_convertor orig_sampsize_convertor evv
	
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(SAMPSIZE)$evv(CDP_EXT)]
	if [catch {open $fnam "r"} fId] {
		Inf "Cannot find sample size information: defaulting to $sampsize_convertor"
		return
	} elseif {([gets $fId line] < 0) || ([string length $line] <= 0)} {
		Inf "Cannot read sample size information: defaulting to $sampsize_convertor"
		close $fId
		return
	}
	close $fId
	set line [string trim $line]
 	if {![IsNumeric $line]} {
		Inf "Cannot read sample size information: defaulting to $sampsize_convertor"
		return
	}
	set sampsize_convertor $line
	set orig_sampsize_convertor $sampsize_convertor
	return
} 

#--- To test the GOBO function

proc See_Gobo_Cmd {cmd} {
	global new_gobo_testing
	if {$new_gobo_testing} {
		Inf "To Test GOBO Functioning Correctly With This Program\nRun The Command\n$cmd \nFollowed By The program number from 'processno.h'"
	}
}

#--- Check if sound graphics programs are available

proc CheckSndGraphicsExecs {} {
	global evv
	if {[file exists [file join $evv(CDPROGRAM_DIR) pview$evv(EXEC)]] \
	&&  [file exists [file join $evv(CDPROGRAM_DIR) paview$evv(EXEC)]] \
	&&  [file exists [file join $evv(CDPROGRAM_DIR) pagrab$evv(EXEC)]] } {
		return 1
	}
	return 0
}

proc SetCDPres {} {
	global evv
	option clear
	option add *background	   		LemonChiffon3
	option add *foreground			black
	option add *activeBackground	LemonChiffon1
	option add *activeForeground	blue
	option add *selectColor			LemonChiffon1
	option add *selectForeground	white
	option add *selectBackground	LemonChiffon4
	option add *troughColor			LemonChiffon2
	option add *disabledForeground	cornsilk4
	option add *insertBackground	black
	set evv(T_FONT_STYLE)  times
	set evv(T_FONT_SIZE)	  8
	set evv(T_FONT_TYPE)	  roman
	set evv(T_DELETE_TYPE) italic
	set evv(T_ACTIVEBKGD)  blue
	set evv(T_ACTIVEFGND)  pink
	set evv(PBAR_ENDCOLOR) black
	set evv(PBAR_DONECOLOR) DarkGoldenrod3
	set evv(PBAR_NOTDONECOLOR) LemonChiffon1
	set evv(QUIT_COLOR) PaleVioletRed2
	set evv(ON_COLOR) LemonChiffon1
	set evv(OFF_COLOR) LemonChiffon3
	set evv(HELP) LightBlue2
	set evv(EMPH) LemonChiffon2
	set evv(SPECIAL) blue
	set evv(DISABLE_COLOR) grey
	set evv(NEUTRAL_TC) LemonChiffon3
	set evv(SOUND_TC) "deep sky blue"
	set evv(ANALYSIS_TC) red
	set evv(PITCH_TC) yellow
	set evv(TRANSPOS_TC) orange
	set evv(FORMANT_TC) pink
	set evv(ENVELOPE_TC) green
	set evv(TEXT_TC) white
	set evv(MONO_TC) turquoise2
	set evv(WARN_COLR) blue
	set evv(ERR_COLR) red
	set evv(INF_COLR) black
	set evv(FONT_FAMILY) tahoma
	set evv(FONT_SIZE) 8
	set evv(ABOUT) white
	set evv(GRAF) black
	set evv(POINT) black
	set evv(BOX) black
	set evv(PGRID)	gray12
	set evv(HELP_DISABLED_FG) cornsilk4
	set evv(BRKTABLE_BORDER) [option get . foreground {}]
	set evv(GRAFSND) blue
	catch {font create userfnt -family $evv(FONT_FAMILY) -size $evv(FONT_SIZE)}
	option add *font userfnt
}

proc SetLEEDScolours {} {
	global evv
	set evv(LEEDS_BG) DarkSlateGrey
	set evv(LEEDS_FG) white
	set evv(LEEDS_ACTIVE_BG) black
	set evv(LEEDS_ACTIVE_FG) lightblue3
	set evv(LEEDS_SELECT) SlateGrey
	set evv(LEEDS_SELECT_BG) black
	set evv(LEEDS_TROUGH) grey
	set evv(LEEDS_DISABLED_FG) grey49
}

proc SetLEEDSres {} {
	global evv
	option clear
	SetLEEDScolours
	option add *background	   		$evv(LEEDS_BG)
	option add *foreground			$evv(LEEDS_FG)
	option add *activeBackground	$evv(LEEDS_ACTIVE_BG)
	option add *activeForeground	$evv(LEEDS_ACTIVE_FG)
	option add *selectColor			$evv(LEEDS_SELECT)
	option add *selectForeground	$evv(LEEDS_ACTIVE_FG)
	option add *selectBackground	$evv(LEEDS_SELECT_BG)
	option add *troughColor			$evv(LEEDS_TROUGH)
	option add *disabledForeground	$evv(LEEDS_DISABLED_FG)
	option add *insertBackground	white
	set evv(T_FONT_STYLE)  times
	set evv(T_FONT_SIZE)	  8
	set evv(T_FONT_TYPE)	  roman
	set evv(T_DELETE_TYPE) italic
	set evv(T_ACTIVEBKGD)  white
	set evv(T_ACTIVEFGND)  hotpink
	set evv(PBAR_ENDCOLOR) DarkSlateGrey
	set evv(PBAR_DONECOLOR) yellow2
	set evv(PBAR_NOTDONECOLOR) DarkSlateGrey
	set evv(QUIT_COLOR) HotPink4
	set evv(ON_COLOR) SlateGrey
	set evv(OFF_COLOR) DarkSlateGrey
	set evv(HELP) DarkSeaGreen4
	set evv(EMPH) LightSlateGrey
	set evv(SPECIAL) Ivory3
	set evv(DISABLE_COLOR) grey
	set evv(NEUTRAL_TC) $evv(LEEDS_BG)
	set evv(SOUND_TC) black
	set evv(ANALYSIS_TC) firebrick3
	set evv(PITCH_TC) LightGoldenrod4
	set evv(TRANSPOS_TC) DarkOrange3
	set evv(FORMANT_TC) IndianRed3
	set evv(ENVELOPE_TC) DarkGreen
	set evv(TEXT_TC) DarkOrchid4
	set evv(MONO_TC) blue4
	set evv(WARN_COLR) white
	set evv(ERR_COLR) black
	set evv(INF_COLR) AntiqueWhite
	set evv(FONT_FAMILY) tahoma
	set evv(FONT_SIZE) 8
	set evv(ABOUT) darkslategrey
	set evv(GRAF) yellow2
	set evv(POINT) ivory3
	set evv(BOX) yellow2
	set evv(PGRID)	ivory3
	set evv(HELP_DISABLED_FG) mediumseagreen
	set evv(BRKTABLE_BORDER) $evv(SPECIAL)
	set evv(GRAFSND) $evv(POINT)
	catch {font create userfnt -family $evv(FONT_FAMILY) -size $evv(FONT_SIZE)}
	option add *font userfnt
}

proc GetColour {} {
	global CDPcolour readonlyfg readonlybg evv
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(COLOUR)$evv(CDP_EXT)]
	set CDPcolour 0
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
	}
	if {$CDPcolour == 1} {
		SetLEEDSres
	} else {
#SEP 2010
		SetCDPres
	}		
	set readonlyfg $evv(POINT)
	if {$CDPcolour == 1} {
		set readonlybg black
	} else {
		set readonlybg grey
	}
}

proc SaveColour {} {
	global CDPcolour evv
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(COLOUR)$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Open File '$fnam' To Remember Sound Loom Colour Style"
		return
	}
	puts $zit $CDPcolour
	close $zit
}

proc ChangeColour {init} {
	global CDPcolour pr_colour evv
	if {$init} {
		SetCDPres
		SetLEEDScolours
	} else {
		set orig_colour $CDPcolour
	}
	set f .colour
	if [Dlg_Create $f "Soundloom Colour Style" "set pr_colour 0" -borderwidth 2 -height 24] {
		frame $f.0
		label $f.0.ll -text "Colour Style can be changed from the \n'System State' -> 'System Settings' menu" -font bigfnt
		pack $f.0.ll -side top -pady 4 -padx 4
		frame $f.1
		radiobutton $f.1.0 -variable CDPcolour -text "Original" -value 0 -command Recolour -font bigfnt
		radiobutton $f.1.1 -variable CDPcolour -text "Leeds" -value 1 -command Recolour -font bigfnt
		button $f.1.b -text OK -command "set pr_colour 0" -font bigfnt -highlightbackground [option get . background {}]
		pack $f.1.0 $f.1.1 -side left -padx 16 -pady 40
		pack $f.1.b -side right -padx 16 -pady 40
		pack $f.0 $f.1 -side top
		label $f.2 -text "" -font bigfnt
		pack $f.2 -side top -pady 40
		wm resizable $f 1 1
		bind $f <Return> {set pr_colour 0}
		bind $f <Escape> {set pr_colour 0}
		bind $f <Key-space> {set pr_colour 0}
	}
	raise $f
	set pr_colour 0
	if {$init} {
		set CDPcolour 0
		Recolour
		My_Grab 1 $f pr_colour
	} else {
		set CDPcolour $orig_colour 
		Recolour
		My_Grab 0 $f pr_colour
	}
	tkwait variable pr_colour
	if {$init} {
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	} else {
		if {$CDPcolour != $orig_colour} {
			Inf "Close And Restart The Soundloom To Use The New Colours"
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	}
}

proc Recolour {} {
	global CDPcolour evv
	switch -- $CDPcolour {
		0 { 
			.colour config -bg LemonChiffon3
			.colour.0 config -bg LemonChiffon3
			.colour.1 config -bg LemonChiffon3
			.colour.0.ll config -fg black -bg LemonChiffon3
			.colour.1.0 config -bg LemonChiffon3 -fg black \
				-activebackground LemonChiffon1 -activeforeground blue -selectcolor LemonChiffon1
			.colour.1.1 config -bg LemonChiffon3 -fg black \
				-activebackground LemonChiffon1 -activeforeground blue -selectcolor LemonChiffon1
			.colour.1.b config -bg LemonChiffon3 -fg black \
				-activebackground LemonChiffon1 -activeforeground blue
			.colour.2 config -bg LemonChiffon3 -fg black -text ""
		}
		1 {
			.colour config -bg $evv(LEEDS_BG)
			.colour.0 config -bg $evv(LEEDS_BG)
			.colour.1 config -bg $evv(LEEDS_BG)
			.colour.0.ll config -fg $evv(LEEDS_FG) -bg $evv(LEEDS_BG)
			.colour.1.0 config -bg $evv(LEEDS_BG) -fg $evv(LEEDS_FG) \
				-activebackground $evv(LEEDS_ACTIVE_BG) -activeforeground $evv(LEEDS_ACTIVE_FG) -selectcolor $evv(LEEDS_SELECT)
			.colour.1.1 config -bg $evv(LEEDS_BG) -fg $evv(LEEDS_FG) \
				-activebackground $evv(LEEDS_ACTIVE_BG) -activeforeground $evv(LEEDS_ACTIVE_FG) -selectcolor $evv(LEEDS_SELECT)
			.colour.1.b config -bg $evv(LEEDS_BG) -fg $evv(LEEDS_FG) \
				-activebackground $evv(LEEDS_ACTIVE_BG) -activeforeground $evv(LEEDS_ACTIVE_FG)
			.colour.2 config -bg $evv(LEEDS_BG) -fg $evv(LEEDS_FG) -text "Leeds colour scheme by Dale Perkins"
		}
	}
}

proc EstablishMenuInverse {} {
	global menuinverse evv cdpmenulist cdpmenu
	set menuinverse "--"
	set n 1
	while {$n <=  $evv(TOTAL_PROCS)} {
		foreach name [array names cdpmenulist] {
			set gotit 0	
			foreach item $cdpmenulist($name) {
				if {[lsearch $item $n] >= 0} { 
					lappend menuinverse [lindex $cdpmenu($name) 0]
					set gotit 1
					break
				}
			}
			if {$gotit} {
				break
			}
		}
		if {!$gotit} {
			lappend menuinverse "--"
		}
		incr n
	}
}

proc SetCdpMenulist {args} {
	global prg
	set outlist {}
	foreach item $args {
		if {[info exists prg($item)]} {
			lappend outlist $item
		}
	}
	return $outlist
}

#----- Getting user's Audio Devices

proc GetAudioDevices {} {
	global done_devices prg_abortd devicelist done_maxsamp maxsamp_line evv CDPidrun

	set cmd [file join $evv(CDPROGRAM_DIR) listaudevs]
	if {![file exists $cmd$evv(EXEC)]} {
		return
	}
	catch {unset devicelist}
	set done_devices 0
	set prg_abortd 0
	if [catch {open "|$cmd"} CDPidrun] {
		return
	} else {
	   	fileevent $CDPidrun readable "GetAudioDevicesList"
	}
	vwait done_devices
	if {![info exists devicelist]} {
		return
	}
	foreach line [lrange $devicelist 1 end] {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		catch {unset thisdevice}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend thisdevice $item
			}
		}
		if {![info exists $thisdevice] || ([llength $thisdevice] < 4)} {
			lappend baditems $thisdevice
		}
		lappend thesedevices $thisdevice
	}
	if {![info exists thesedevices]} {		;#	No i/o devices found
		return
	}
	set len [llength $thesedevices]
	set n 0
	while {$n < $len} {
		set thisdevice [lindex $thesedevices $n]
		if {[lindex $thisdevice 2] <= 0} {			;#	Eliminate input devices from list
			set thesedevices [lreplace $thesedevices $n $n]
			incr len -1
		} else {
			incr n
		}
	}
	if {$len == 0} {		;#	No play devices found
		return
	}

	catch {unset devicelist}
	foreach device $thesedevices {
		set num [lindex $device 0]
		if {[regexp {^[\*]+} [string index $num 0]]} {
			set str "Default Sound Driver"
			set num [string range $num 1 end]
			set evv(DEVICE_DFLT) $num
		} else {
			set str [lindex $device 3]
			if {[llength $device] > 4} {
				foreach item [lrange $device 4 end] {
					append str " " $item
				}
			}
		}
		if {![info exists evv(DEVICE_MIN)]} {
			set evv(DEVICE_MIN) $num
		}
		set ochans [lindex $device 2]
		set shortdevice [list $num "$str" $ochans]
		lappend devicelist $shortdevice
	}
	set evv(DEVICE_MAX) $num
	set evv(DEVICE) $evv(DEVICE_DFLT)
}

proc GetAudioDevicesList {} {
	global devicelist done_devices prg_abortd CDPidrun

	if [eof $CDPidrun] {
		set done_devices 1
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if [string match ERROR:* $line] {
			set prg_abortd 1
			return
		} elseif [string match END:* $line] {
			set done_devices 1
			return
		} else {
			lappend devicelist $line
		}
	}
	update idletasks
}

#---- Flag which PC operating system is in use

proc SetPCOpsystem {} {
	global is_snowleopard CDPpcop pr_pcop
	switch -- $CDPpcop {
		1 {
			catch {unset is_snowleopard}
		}
		2 {
			set is_snowleopard 1
		}
	}
	set pr_pcop 1
}

#---- With 13.0.1 Loom and Release 6 CDP, old MAC operating system analysis files
#---- required Rosetta and byte-reversal algos to process files. Therefore ultra slow.
#---- New op system has standard byte-order and uses wav files.

proc Release6CheckForWav {} {
	global evv wstk
	set fnam [file join $evv(URES_DIR) rel6wav$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		return
	}
	set finalchoice "no"
	while {$finalchoice == "no"} {
		set msg "The Latest Version Of The CDP Works Most Efficiently With 'wav' Files.\n\n"
		append msg "If you have a recent MAC machine but are still set up for '.aif' files\n"
		append msg "see the CDP Release 6.0 documentation for the upgrade step.\n\n"
		append msg "If you are not already upgraded, you should exit now and do this.\n\n"
		append msg "Exit to do the upgrade ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			if {[AreYouSure]} {
				exit
			}
		}
		set msg "If you were using aiff files previously: your soundfile names will have the 'aif' extension."
		append msg "\n"
		append msg "Do you still want to continue using the '.aif' filename extension ??\n"
		append msg "\n"
		append msg "(You can change this decision later, from the \"System\" menu on the Workspace)\n"
		set decision [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$decision == "yes"} {
			set msg "Are You Sure you want to CONTINUE using the '.aif' extension ??"
		} else {
			set msg "Are You Sure you want to ABANDON using the '.aif' extension (using '.wav' instead) ??"
		}
		set finalchoice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
	}
	if {$decision == "no"} {
		set evv(SNDFILE_EXT) ".wav"
		RememberUserEnvironment
	}
	if [catch {open $fnam "w"} zit] {
		close $zit
	}
}

#---- May be log naming incompatibility between old logs and new logs. Rationalise.

proc Release6CheckLogNames {} {
	global evv
	set testfnam [file join $evv(URES_DIR) lognamechek$evv(CDP_EXT)]
	if {[file exists $testfnam]} {
		return
	}
	set badfiles 0
	set goodfiles 0
	foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(LOGDIR) "*"]]] {
		set fnam [file tail $fnam]
		if {![string match $fnam $evv(LOGCOUNT_FILE)$evv(CDP_EXT)] && ![string match $fnam $evv(LOGSCNT_FILE)$evv(CDP_EXT)]} {
			lappend logfile_list $fnam
		}
	}
	if {![info exists logfile_list] || ([llength $logfile_list] <= 0)} {
		return
	}
	set new_separator "."
	foreach fnam $logfile_list {
		set k [string length $fnam]
		incr k -5
		set separator [string index $fnam $k]
		if {$separator != $new_separator} {
			incr k -1
			set newname [string range $fnam 0 $k]
			append newname $new_separator
			incr k 2
			append newname [string range $fnam $k end]
			set newname [file join $evv(LOGDIR) $newname]
			lappend newnames $newname
			lappend oldnames [file join $evv(LOGDIR) $fnam]
		}
	}
	if {[info exists newnames]} {
		set len [llength $newnames]
		set k 0
		while {$k  < $len} {
			set oldname [lindex $oldnames $k]
			set newname [lindex $newnames $k]
			if [catch {file rename $oldname $newname} zit] {
				incr badfiles
				set oldnames [lreplace $oldnames $k $k]
				set newnames [lreplace $newnames $k $k]
				incr len -1
			} else {
				incr goodfiles
				incr k
			}
		}
		if {[llength $newnames] <= 0} {
			unset newnames
			if {$badfiles > 0} {
				Inf "Failed To Rename $badfiles Old Log Files\nTake Care When Deleting Logs From Log-Listing\nAs Logs May Occur In The Incorrect Order."
			}
		}
	}
	if {[info exists newnames]} {
		set cntfnam [file join $evv(LOGDIR) $evv(LOGCOUNT_FILE)$evv(CDP_EXT)]
		if [catch {open $cntfnam "r"} zit] {
			set msg "Cannot Open File '$cntfnam' To Update The Information\nConcerning The Number Of Line Entries In '$goodfiles' Oldstyle Log Files\n\n"
			if {$badfiles > 0} {
				append msg "$badfiles Oldstyle Log Files Also Could Not Be Renamed To The New Format"
			}
			Inf $msg
		} else {
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
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
				if {[info exists nuline]} {
					lappend nulines $nuline
				}
			}
			close $zit
			if {![info exists nulines]} {
				Inf "Could Find No Info About Oldstyle Log Files, In File '$cntfnam'"
			} else {
				set lines $nulines
				foreach oldname $oldnames newname $newnames {
					set oldname [file tail $oldname]
					set newname [file tail $newname]
					set n 0
					foreach line $lines {
						set fnam [lindex $line 0]
						if {[string match $oldname $fnam]} {
							set nuline [list $newname [lindex $line 1]]
							set lines [lreplace $lines $n $n $nuline]
							break
						}
						incr n
					}
				}
				set fnam $evv(DFLT_OUTNAME)$evv(CDP_EXT)
				if [catch {open $fnam "w"} zit] {
					Inf "Cannot Write Data About Renamed Log-Files, For Storage In File '$cntfnam'"
				} else {
					foreach line $lines {
						puts $zit $line
					}
					close $zit
					if [catch {file delete $cntfnam} zit] {
						Inf "Cannot Replace Data About Renamed LogFiles Into File '$cntfnam': $zit"
					} elseif [catch {file rename $fnam $cntfnam} zit] {
						Inf "Cannot Rename (As '$cntfnam) The Data-File About Renamed Log-Files.\n\nIt Exists As $fnam\n\nRename It Outside The CDP Before You Do Anything Else (Do Not Quit!)"
					}
				}
			}
		}
	}
	if {![catch {open $testfnam "w"} zit]} {
		close $zit
	}
}

proc Release6TestfilesTest {} {
	global evv
	if {[info exists evv(TESTFILE_A)]} {
		return
	}
	foreach exxt $evv(SNDFILE_EXTS) {
		set fnam [file join $evv(CDPRESOURCE_DIR) $evv(TESTFILE)$exxt]
		if {[file exists $fnam]} {
			break
		}
	}
	if {![file exists $fnam]} {
		Inf "No testfiles exit in directory $evv(CDPRESOURCE_DIR): Cannot proceed."
		DoWkspaceQuit 0 1
	}
	set sndfile_ext [file extension $fnam]
	set evv(TESTFILE_A) $fnam
	set evv(TESTFILE_C)  [file join $evv(CDPRESOURCE_DIR) testfilec$sndfile_ext]
	set evv(TESTFILE_Db) [file join $evv(CDPRESOURCE_DIR) testfiledb$sndfile_ext]
	set evv(TESTFILE_D)  [file join $evv(CDPRESOURCE_DIR) testfiled$sndfile_ext]
	set evv(TESTFILE_Eb) [file join $evv(CDPRESOURCE_DIR) testfileeb$sndfile_ext]
	set evv(TESTFILE_E)  [file join $evv(CDPRESOURCE_DIR) testfilee$sndfile_ext]
	set evv(TESTFILE_F)  [file join $evv(CDPRESOURCE_DIR) testfilef$sndfile_ext]
	set evv(TESTFILE_Gb) [file join $evv(CDPRESOURCE_DIR) testfilegb$sndfile_ext]
	set evv(TESTFILE_G)  [file join $evv(CDPRESOURCE_DIR) testfileg$sndfile_ext]
	set evv(TESTFILE_Ab) [file join $evv(CDPRESOURCE_DIR) testfileab$sndfile_ext]
	set evv(TESTFILE_Bb) [file join $evv(CDPRESOURCE_DIR) testfilebb$sndfile_ext]
	set evv(TESTFILE_B)  [file join $evv(CDPRESOURCE_DIR) testfileb$sndfile_ext]
	set evv(TESTFILE_C2) [file join $evv(CDPRESOURCE_DIR) testfilec2$sndfile_ext]
}

#--- Set up an appropriate play cmd, at startup

proc SetupPlayProgram {reset init} {
	global playcmd stopplay multichanplayer playdir_dummy playcmd_dummy tcl_platform wstk is_vista is_windows7 evv
	global killtype pr_setplay setcdpprog setcdpstop

	set reinit 0
	set dirfnam [file join $evv(CDPRESOURCE_DIR) playdir$evv(CDP_EXT)]
	set cmdfnam [file join $evv(CDPRESOURCE_DIR) playcmd$evv(CDP_EXT)]
	set stopfnam [file join $evv(CDPRESOURCE_DIR) playstop$evv(CDP_EXT)]

	;#	LOOK FOR EXISTING INFO ON PLAYCMD

	if {!$init && !$reset} {
		if {[file exists $dirfnam] && [file exists $cmdfnam]} {
			if {![catch {open $dirfnam "r"} zit]} {
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					set playdir_found $line
					break
				}
			}
			catch {close $zit}
			if {![catch {open $cmdfnam "r"} zit]} {
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					set playcmd_found $line
					break
				}
			}
			catch {close $zit}
			if {[info exists playdir_found] && [info exists playcmd_found]} {
				set playcmd [file join $playdir_found $playcmd_found]
				if {[file exists $playcmd$evv(EXEC)]} {
					if [string match $playcmd_found "pvplay"] {
						lappend playcmd -i -u
						set multichanplayer $playcmd
					} else {
						catch {unset multichanplayer}
						if {[string match $playcmd_found "QuickTime Player.app/Contents/MacOS/QuickTime Player"]} {
							set playcmd [file join $evv(CDPROGRAM_DIR) qtscript.sh]
							if {![file exists $playcmd]} {
								Inf "File \"$playcmd\" (which launches QuickTime Player) no longer exists"
							}
						} elseif {[string match $playcmd_found "QuickTime Player 7.app/Contents/MacOS/QuickTime Player 7"]} {
							set playcmd [file join $evv(CDPROGRAM_DIR) qt7script.sh]
							if {![file exists $playcmd]} {
								Inf "File \"$playcmd\" (which launches QuickTime Pro) no longer exists"
							}
						}
					}
					if {[file exists $stopfnam]} {
						set stopplay 1
					} else {
						set stopplay 0
					}
					set playcmd_dummy $playcmd_found
					set playdir_dummy $playdir_found
					return 1
				}
			}
		}
	}
	if {$init} {			;#	AT NEW SYSTEM INITIALISATION, NO PLAY PROGRAM ESTABLISHED
		set stopplay 0
		catch {unset multichanplayer}
		set setcdpprog -1
		set init_setcdpprog -1
		set setcdpstop -1
		set init_setcdpstop -1
	} elseif {$reset} {		;#	RESET, DURING A SESSION: PLAY PROGRAM ALREADY EXISTS
		set setcdpprog 0
		set init_setcdpprog 0
		if {[file rootname [file tail [lindex $playcmd_dummy 0]]] == "pvplay"} {
			set setcdpprog 1
			set init_setcdpprog 1
			set playdir_dummy $evv(CDPROGRAM_DIR)
		} elseif {$playcmd_dummy == "QuickTime Player.app/Contents/MacOS/QuickTime Player"} {
			set setcdpprog 2
			set init_setcdpprog 2
			set playdir_dummy "/Applications/"
		} elseif {$playcmd_dummy == "QuickTime Player 7.app/Contents/MacOS/QuickTime Player 7"} {
			set setcdpprog 3
			set init_setcdpprog 3
			set playdir_dummy "/Applications/"
		} elseif {$playcmd_dummy == "VLC.app/Contents/MacOS/VLC"} {
			set setcdpprog 4
			set init_setcdpprog 4
			set playdir_dummy "/Applications/"
		}
		set setcdpstop $stopplay
		set init_setcdpstop $stopplay
	} else {							;#	SHOULD ONLY BE CALLED IF BACKUP FILES HAVE BEEN LOST OR CORRUPTED
		if {[file exists $stopfnam]} {
			set stopplay 1
			set setcdpstop 1
			set init_setcdpstop 1
		} else {
			set stopplay 0
			set setcdpstop 0
			set init_setcdpstop 0
		}
		set setcdpprog -1
		set init_setcdpprog -1
		set reinit 1
	}
	set f .setplay
	if [Dlg_Create $f "MODIFY PLAY PROGRAM" "set pr_setplay 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.ok -text "Set Program" -command "set pr_setplay 1" -highlightbackground [option get . background {}]
		button $f.0.qq -text "No Change" -command "set pr_setplay 0" -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.1 -variable setcdpprog -text "CDP player (handles multichannel & analysis files)" -value 1 -command {set setcdpstop 1}
		pack $f.1.1 -side top -pady 2 -anchor w
		if {[file exists "/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player"] && [file exists [file join $evv(CDPROGRAM_DIR) qtscript.sh]]} {
			radiobutton $f.1.2 -variable setcdpprog -text "Quick Time (won't play analysis files or multichannel files)" -value 2 -command {set setcdpstop 0}
			pack $f.1.2 -side top -pady 2 -anchor w
		}
		if {[file exists "/Applications/QuickTime Player 7.app/Contents/MacOS/QuickTime Player 7"] && [file exists [file join $evv(CDPROGRAM_DIR) qt7script.sh]]} {
			radiobutton $f.1.3 -variable setcdpprog -text "Quick Time Pro (won't play analysis files or multichannel files)" -value 3 -command {set setcdpstop 0}
			pack $f.1.3 -side top -pady 2 -anchor w
		}
		if {[file exists "/Applications/VLC.app/Contents/MacOS/VLC"] && [file exists [file join $evv(CDPROGRAM_DIR) vlcscript.sh]]} {
			radiobutton $f.1.4 -variable setcdpprog -text "VLC (won't play analysis files or multichannel files)" -value 4 -command {set setcdpstop 0}
			pack $f.1.4 -side top -pady 2 -anchor w
		}
		pack $f.1 -side top -fill x -expand true
		frame $f.2 -bg black -height 1
		pack $f.2 -side top -pady 4 -fill x -expand true
		frame $f.3
		radiobutton $f.3.1 -variable setcdpstop -text "Use a STOP button" -value 1
		radiobutton $f.3.2 -variable setcdpstop -text "Do NOT use a STOP button" -value 0
		pack $f.3.1 $f.3.2 -side top -pady 2 -anchor w
		pack $f.3 -side top -fill x -expand true
		bind $f <Return> {set pr_setplay 1}
		bind $f <Escape> {set pr_setplay 0}
		wm resizable $f 1 1
	}
	if {$init} {
		wm title $f "ESTABLISH PLAY PROGRAM"
		$f.0.qq config -text "" -command {} -bd 0
		bind $f <Escape> {}
	} elseif {$reinit} {
		wm title $f "REESTABLISH PLAY PROGRAM"
		$f.0.qq config -text "" -command {} -bd 0
		bind $f <Escape> {}
	} else {
		wm title $f "MODIFY PLAY PROGRAM"
		$f.0.qq config -text "No Change" -command "set pr_setplay 0" -bd 2
		bind $f <Escape> {set pr_setplay 0}
	}
	set pr_setplay 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_setplay
	set finished 0
	while {!$finished} {
		tkwait variable pr_setplay
		if {$pr_setplay} {
			if {$setcdpprog < 0} {
				Inf "No Play Program Selected"
				continue
			}
			if {$setcdpstop < 0} {
				Inf "No Stop Play Function Selected"
				continue
			}
			set msg ""
			if {$setcdpprog != $init_setcdpprog} {
				switch -- $setcdpprog {
					1 {
						set new_playcmd [file join $evv(CDPROGRAM_DIR) pvplay]
						if {![file exists $new_playcmd$evv(EXEC)]} {
							if {$init || $reinit} {
								Inf "\"pvplay\"  Is Not On Your System: Use A Native MAC Program"
							} else {
								Inf "\"pvplay\"  Is Not On Your System: Cannot Change The Play Program"
							}
							continue
						}
						set playcmd $new_playcmd 
						set playcmd_dummy [file tail $playcmd]
						set playdir_dummy [file dirname $playcmd]
						lappend playcmd -i -u
						set multichanplayer $playcmd
						if {$reset} {
							append msg "Your New Play Command Is \"$playcmd\"\n\n"
						} else {
							append msg "Your Play Command Is \"$playcmd\"\n\n"
						}
						set stopplay 1
						if {$setcdpstop < 0} {
							set setcdpstop 1
						}
					}
					2 {
						set playcmd_dummy "QuickTime Player.app/Contents/MacOS/QuickTime Player"
						set playdir_dummy "/Applications/"
						set new_playcmd [file join $evv(CDPROGRAM_DIR) qtscript.sh]
						if {![file exists $new_playcmd]} {
							if {$init || $reinit} {
								Inf "File $new_playcmd (Which Launches QuickTime) Is Not On Your System"
							} else {
								Inf "File $new_playcmd (Which Launches QuickTime)  Is Not On Your System: Cannot Change The Play Program"
							}
							continue
						}
						set playcmd $new_playcmd 
						set show_playcmd "QuickTime Player"
						if {($init || $reinit) && ($setcdpstop < 0)} {
							set setcdpstop 0
							set stopplay 0
						}
						if {$reset} {
							append msg "Your New Play Command Is \"$show_playcmd\"\n\n"
						} else {
							append msg "Your Play Command Is \"$show_playcmd\"\n\n"
						}
						catch {unset multichanplayer}
					}
					3 {
						set playcmd_dummy "QuickTime Player 7.app/Contents/MacOS/QuickTime Player 7"
						set playdir_dummy "/Applications/"
						set new_playcmd [file join $evv(CDPROGRAM_DIR) qt7script.sh]
						if {![file exists $new_playcmd]} {
							if {$init || $reinit} {
								Inf "File $new_playcmd (Which Launches QuickTime Pro) Is Not On Your System"
							} else {
								Inf "File $new_playcmd (Which Launches QuickTime Pro)  Is Not On Your System: Cannot Change The Play Program"
							}
							continue
						}
						set playcmd $new_playcmd 
						set show_playcmd "QuickTime Pro"
						if {($init || $reinit) && ($setcdpstop < 0)} {
							set setcdpstop 0
							set stopplay 0
						}
						if {$reset} {
							append msg "Your New Play Command Is \"$show_playcmd\"\n\n"
						} else {
							append msg "Your Play Command Is \"$show_playcmd\"\n\n"
						}
						catch {unset multichanplayer}
					}
					4 {
						set playcmd_dummy "VLC.app/Contents/MacOS/VLC"
						set playdir_dummy "/Applications/"
						set new_playcmd [file join $evv(CDPROGRAM_DIR) vlcscript.sh]
						if {![file exists $new_playcmd]} {
							if {$init || $reinit} {
								Inf "File $new_playcmd (Which Launches VLC) Is Not On Your System"
							} else {
								Inf "File $new_playcmd (Which Launches VLC) Is Not On Your System: Cannot Change The Play Program"
							}
							continue
						}
						set playcmd $new_playcmd 
						set show_playcmd "VLC"
						if {($init || $reinit) && ($setcdpstop < 0)} {
							set setcdpstop 0
							set stopplay 0
						}
						if {$reset} {
							append msg "Your New Play Command Is \"$show_playcmd\"\n\n"
						} else {
							append msg "Your Play Command Is \"$show_playcmd\"\n\n"
						}
						catch {unset multichanplayer}
					}
				}
				if [catch {open $cmdfnam "w"} zit] {
					Inf "Cannot Open File $cmdfnam To Remember Your Play Program"
				} else {
					puts $zit $playcmd_dummy
					close $zit
				}
				if [catch {open $dirfnam "w"} zit] {
					Inf "Cannot Open File $dirfnam To Remember The Directory Of Your Play Program"
				} else {
					puts $zit $playdir_dummy
					close $zit
				}
			}
			if {$setcdpstop != $init_setcdpstop} {
				set stopplay $setcdpstop
				if {$stopplay} {
					append msg "Using A Stop Button"
				} else {
					append msg "Not Using A Stop Button"
				}
			}
			if {[string length $msg] > 0} {
				Inf $msg
			}
			set finished 1
		} else {
			set msg "Your Play Program Has Not Been Changed"
			set finished 1
		}
	}
	if {$stopplay && ![file exists $stopfnam]} {
		if {![catch {open $stopfnam "w"} zit]} {
			close $zit
		}
	}
	if {!$stopplay && [file exists $stopfnam]} {
		catch {file delete $stopfnam}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}
