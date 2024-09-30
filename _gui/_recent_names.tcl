#
# SOUND LOOM RELEASE mac version 17.0.4
#

################
# RECENT NAMES #
################

#------ Read recently used names

proc ReadRecentNames {fileId} {
	global nu_names
	while {[gets $fileId line] >= 0} {
		set line [split $line]
		if {[llength $line] > 0} {
			lappend nu_names $line
		}
	}
}

#------ Save User-defined Environment & resources to Files, if it has changed

proc SaveRecentNames {} {
	global evv nu_names

	set fnam [file join $evv(URES_DIR) $evv(NUNAMES)$evv(CDP_EXT)]
	if [catch {open $evv(DFLT_RNAM) w} fileId] {
		Inf "Cannot open temporary file to save new list of recent names"
		return
	}				
	foreach nname $nu_names {
		puts $fileId "$nname"
	}
	close $fileId
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete existing file of recent names: Cannot save new list"
			return
		}
	}
	file rename $evv(DFLT_RNAM) $fnam
}

#------ Collect names used by user

proc AddNameToNameslist {name ll} {
	global nu_names evv
	set name [string tolower [file rootname $name]]
	set found 0
	if [info exists nu_names] { 
		set i 0
		foreach nname $nu_names {
			if [string match $nname $name] {
				set nu_names [lreplace $nu_names $i $i]
				set nu_names [linsert $nu_names 0 $name]
				set found 1
				break				
			}
			incr i
		}
	}
	if {!$found} {
		if [info exists nu_names] {
			set nu_names [concat $name $nu_names]
		} else {
			set nu_names [list $name]
		}
		if {[llength $nu_names] > $evv(NSTORLEN)} {
			set nu_names [lrange $nu_names 0 [expr $evv(NSTORLEN) - 1]]
		}
	}
	SaveRecentNames
	if [string match $ll "0"] {
		return
	}
	$ll delete 0 end
	foreach nname $nu_names {
		$ll insert end $nname
	}					
}

#------ Put standard name into name box 

proc PutName {e nam} {
	$e delete 0 end
 	$e insert 0 $nam
}

###########################
# HANDLING NESS DATA FILE #
###########################

#
# nes(valve_events)	  = TOTAL NUMBER of valving events (where several valves may change at each event)
# nes(valve_eventcnt) = COUNT of the number of valving events processed so far
#

proc NessInit {} {
	global nes nessrange nesstypicalrange nessinit evv nessparamset nesdef ness_longparamname
	set nessinit 1

	;#	File extensions and management data

	set evv(NESS_MANAGE)	"nessdata"
	set evv(NESS_PROFILE)	"nessprofiles"
	set evv(NESS_INTERP)	"nessinterps"
	set	nes(CONTROL_SRATE)	1000		;#	"sample-rate" for ness_display	(mS or microns)
	set nes(PWIDTH)			1
	;#	Parameter Ranges (LO HI are RECOMMENDED limits)

	set nes(MAXOUT_MIN)		0.5			;#	Max output level
	set nes(MAXOUT_LO)		0.5
	set nes(MAXOUT_HI)		1.0
	set nes(MAXOUT_MAX)		1.0
	set nes(SR_MIN)			0.00000001	;#	Lip area
	set nes(SR_LO)			0.0000001	;#		Recommended 0.0000001 0.000001 (1e-7 1e-6) ???
	set nes(SR_HI)			0.0000146
	set nes(SR_MAX)			0.0001000
	set nes(MU_MIN)			0.000000001;#	Lip mass
	set nes(MU_LO)			0.00000001	;#		Recommended 0.00000001	0.0001 (1e-8 1e-4)
	set nes(MU_HI)			0.0000537
	set nes(MU_MAX)			0.0001
	set nes(SIGMA_MIN)		0			;#	Lip Damping
	set nes(SIGMA_LO)		0			;#		Recommended <1000 (1e3)
	set nes(SIGMA_HI)		1000
	set nes(SIGMA_MAX)		10000
	set nes(H_MIN)			0		;#	Lip Equilibrium separation		
	set nes(H_LO)			0			;#		Recommended <0.01 (1e-2)
	set nes(H_HI)			0.01
	set nes(H_MAX)			0.1
	set nes(W_MIN)			0.00000001	;#	Lip width
	set nes(W_LO)			0.00000001	;#		Recommended <0.1 (1e-1)
	set nes(W_HI)			0.01
	set nes(W_MAX)			0.1
	set nes(T_MIN)			1			;#	score length ??????????
	set nes(T_LO)			1			;#		recommended ????
	set nes(T_HI)			20
	set nes(T_MAX)			100
	set nes(PRESSURE_MIN)	0			;#	Lip Pressure
	set nes(PRESSURE_LO)	0			;#		Recommended >1000 (1e3) BUT MUST BE zero at time 0
	set nes(PRESSURE_HI)	10000
	set nes(PRESSURE_MAX)	100000
	set nes(LIPFRQ_MIN)		0			;#	Lip Vibration frq
	set nes(LIPFRQ_LO)		0			;#		stable at all values
	set nes(LIPFRQ_HI)		5000
	set nes(LIPFRQ_MAX)		5000
	set nes(VIBAMP_MIN)		0			;#	Lip vibrato amplitude, as fraction of amplitude of normal frq
	set nes(VIBAMP_LO)		0			;#		frq vals < 1000
	set nes(VIBAMP_HI)		.999
	set nes(VIBAMP_MAX)		1
	set nes(VIBFRQ_MIN)		0			;#	Lip vibrato frequency
	set nes(VIBFRQ_LO)		0			;#		frq vals < 1000
	set nes(VIBFRQ_HI)		1000
	set nes(VIBFRQ_MAX)		1000
	set nes(TREMAMP_MIN)	0			;#	Lip tremolo amplitude, as fraction of normal mouth pressure
	set nes(TREMAMP_LO)		0			;#		tremamp < 1
	set nes(TREMAMP_HI)		1
	set nes(TREMAMP_MAX)	1
	set nes(TREMFRQ_MIN)	0			;#	Lip tremolo frequency
	set nes(TREMFRQ_LO)		0			;#		tremfreq < 1000
	set nes(TREMFRQ_HI)		1000
	set nes(TREMFRQ_MAX)	44099
	set nes(NOIS_MIN)		0			;#	noise component
	set nes(NOIS_LO)		0			;#		becomes noticeable between (and above?) 0.05 and 0.1
	set nes(NOIS_HI)		0.1
	set nes(NOIS_MAX)		.999
	set nes(VVIBAMP_MIN)	0			;#	Valve vibrato amplitude
	set nes(VVIBAMP_LO)		0			;#		Dependent on valve-opening settings
	set nes(VVIBAMP_HI)		0.999
	set nes(VVIBAMP_MAX)	0.999
	set nes(VVIBFRQ_MIN)	0			;#	Valve vibrato frequency
	set nes(VVIBFRQ_LO)		0			;#		Dependent on valve-opening settings
	set nes(VVIBFRQ_HI)		10000
	set nes(VVIBFRQ_MAX)	10000
	set nes(OPENING_MIN)	0			;#	Default tube openings, Range >0 to 1
	set nes(OPENING_LO)		0			;#		must be between 0 and 1
	set nes(OPENING_HI)		1
	set nes(OPENING_MAX)	1
	
	set nes(CUSTOM_MIN)		0			;#	Custominstrument ??
	set nes(CUSTOM_MAX)		1					;#	Flag 0 or 1 only 
	set nes(TEMP_MIN)		0			;#	Temperature in C
	set nes(TEMP_LO)		10			;#		Typical
	set nes(TEMP_TYPICAL)	20
	set nes(TEMP_HI)		50
	set nes(TEMP_MAX)		200 
	set nes(INTERP_RES)		2			;#	Resolution of interpolated points on bell, 2mm
	set nes(INTERP_HIRES)	1			;#	Resolution of interpolated points in mouthpiece, mm

	;#	Valve values, assumes that the valve is a constant cylinder
	;#  where cross section the in and out of the valves is the same as at that point on the instrument

	set nes(VPOS_MIN)		0			;#	Position of valve in millimetres
	set nes(VPOS_LO)		400			;#		Typical
	set nes(VPOS_HI)		800
	set nes(VPOS_MAX)		100000 
	set nes(VDL_MIN)		10			;#	Default tube-length in mm
	set nes(VDL_LO)			20			;#		Typical
	set nes(VDL_HI)			20
	set nes(VDL_MAX)		200 
	set nes(VBL_MIN)		10			;#	Bypass tube length mm (will add default length to either side of bypass tubes)
	set nes(VBL_LO)			200			;#		Typical
	set nes(VBL_HI)			200
	set nes(VBL_MAX)		2000
	set nes(BORE_MIN)		0			;#	Bore expressed as position along instrument (mm) and diameter(mm), i.e. as a pairs [x,d]
	set nes(BORE_LO)		0			;#		Typical
	set nes(BORE_HI)		5000
	set nes(BORE_MAX)		10000

	set nes(BORELEN_MIN)	100			;#	Bore expressed as position along instrument (mm) and diameter(mm), i.e. as a pairs [x,d]
	set nes(BORELEN_MAX)	100000
	set nes(BORELEN_TPT)	1385
	set nes(BORELEN_TBN)	2735
	set nes(BORELEN_HN)		4520
	set nes(BRASSDUR)		60			;#	Typical Output Duration

	set nes(BOREMAX_TPT)	127
	set nes(BOREMAX_TBN)	215
	set nes(BOREMAX_HN)		190

	set nes(CHARWIDTH) 6				;#	WIdth of numeric characters in bore-profile display
	set nes(BELSLOPE_MIN)	.1			;#	Min power for slope of bell
	set nes(BELSLOPE_MAX)	100			;#	Max power for slope of bell

	set nesdef(fs)			 44100		;# Default values for score
	set nesdef(maxout)		 0.95
	set nesdef(sr)			 0.0000146
	set nesdef(mu)			 0.0000537
	set nesdef(sigma)		 5
	set nesdef(h)			 0.00029
	set nesdef(w)			 0.01
	set nesdef(pressure)	 [list 0 0 0.010 3000]
	set nesdef(noiseamp)	 0
	set nesdef(vibfreq)		 0
	set nesdef(vibamp)		 0
	set nesdef(tremfreq)	 0
	set nesdef(tremamp)		 0
	set nesdef(valvevibfreq) 0
	set nesdef(valvevibamp)  0
	set nesdef(t)			   ""
	set nesdef(valveopening)   ""
	set nesdef(instrumentfile) ""
	set nesdef(lip_frequency)  ""

	set nes(BIG_HEIGHT) 600
	set nes(SMALL_HEIGHT) 300

	set nessrange(maxout)		 [list $nes(MAXOUT_MIN)   $nes(MAXOUT_MAX)]
	set nessrange(Sr)			 [list $nes(SR_MIN)		  $nes(SR_MAX)]
	set nessrange(sr)			 [list $nes(SR_MIN)		  $nes(SR_MAX)]
	set nessrange(mu)			 [list $nes(MU_MIN)		  $nes(MU_MAX)]
	set nessrange(sigma)		 [list $nes(SIGMA_MIN)	  $nes(SIGMA_MAX)]
	set nessrange(H)			 [list $nes(H_MIN)		  $nes(H_MAX)]
	set nessrange(h)			 [list $nes(H_MIN)		  $nes(H_MAX)]
	set nessrange(w)			 [list $nes(W_MIN)		  $nes(W_MAX)]
	set nessrange(T)			 [list $nes(T_MIN)		  $nes(T_MAX)]
	set nessrange(t)			 [list $nes(T_MIN)		  $nes(T_MAX)]
	set nessrange(pressure)		 [list $nes(PRESSURE_MIN) $nes(PRESSURE_MAX)]
	set nessrange(lip_frequency) [list $nes(LIPFRQ_MIN)   $nes(LIPFRQ_MAX)]
	set nessrange(vibamp)		 [list $nes(VIBAMP_MIN)   $nes(VIBAMP_MAX)]
	set nessrange(vibfreq)		 [list $nes(VIBFRQ_MIN)   $nes(VIBFRQ_MAX)]
	set nessrange(tremamp)		 [list $nes(TREMAMP_MIN)  $nes(TREMAMP_MAX)]
	set nessrange(tremfreq)		 [list $nes(TREMFRQ_MIN)  $nes(TREMFRQ_MAX)]
	set nessrange(noiseamp)		 [list $nes(NOIS_MIN)	  $nes(NOIS_MAX)]
	set nessrange(valvevibamp)	 [list $nes(VVIBAMP_MIN)  $nes(VVIBAMP_MAX)]
	set nessrange(valvevibfreq)	 [list $nes(VVIBFRQ_MIN)  $nes(VVIBFRQ_MAX)]
	set nessrange(valveopening)	 [list $nes(OPENING_MIN)  $nes(OPENING_MAX)]

	set nesstypicalrange(maxout)		[list $nes(MAXOUT_LO)	$nes(MAXOUT_HI)]
	set nesstypicalrange(Sr)			[list $nes(SR_LO)		$nes(SR_HI)]
	set nesstypicalrange(sr)			[list $nes(SR_LO)		$nes(SR_HI)]
	set nesstypicalrange(mu)			[list $nes(MU_LO)		$nes(MU_HI)]
	set nesstypicalrange(sigma)			[list $nes(SIGMA_LO)	$nes(SIGMA_HI)]
	set nesstypicalrange(H)				[list $nes(H_LO)		$nes(H_HI)]
	set nesstypicalrange(h)				[list $nes(H_LO)		$nes(H_HI)]
	set nesstypicalrange(w)				[list $nes(W_LO)		$nes(W_HI)]
	set nesstypicalrange(T)				[list $nes(T_LO)		$nes(T_HI)]
	set nesstypicalrange(t)				[list $nes(T_LO)		$nes(T_HI)]
	set nesstypicalrange(pressure)		[list $nes(PRESSURE_LO) $nes(PRESSURE_HI)]
	set nesstypicalrange(lip_frequency)	[list $nes(LIPFRQ_LO)   $nes(LIPFRQ_HI)]
	set nesstypicalrange(vibamp)		[list $nes(VIBAMP_LO)   $nes(VIBAMP_HI)]
	set nesstypicalrange(vibfreq)		[list $nes(VIBFRQ_LO)   $nes(VIBFRQ_HI)]
	set nesstypicalrange(tremamp)		[list $nes(TREMAMP_LO)  $nes(TREMAMP_HI)]
	set nesstypicalrange(tremfreq)		[list $nes(TREMFRQ_LO)  $nes(TREMFRQ_HI)]
	set nesstypicalrange(noiseamp)		[list $nes(NOIS_LO)		$nes(NOIS_HI)]
	set nesstypicalrange(valvevibamp)	[list $nes(VVIBAMP_LO)  $nes(VVIBAMP_HI)]
	set nesstypicalrange(valvevibfreq)	[list $nes(VVIBFRQ_LO)  $nes(VVIBFRQ_HI)]
	set nesstypicalrange(valveopening)	[list $nes(OPENING_LO)  $nes(OPENING_HI)]

	set nessrange(custominstrument)		[list $nes(CUSTOM_MIN) $nes(CUSTOM_MAX)]
	set nessrange(temperature)			[list $nes(TEMP_MIN)   $nes(TEMP_MAX)]
	set nessrange(vpos)					[list $nes(VPOS_MIN)   $nes(VPOS_MAX)]
	set nessrange(vdl)					[list $nes(VDL_MIN)    $nes(VDL_MAX)]
	set nessrange(vbl)					[list $nes(VBL_MIN)    $nes(VBL_MAX)]
	set nessrange(bore)					[list $nes(BORE_MIN)   $nes(BORE_MAX)]

	set nessparamset(ins) [list temperature bore vpos vdl vbl custominstrument]
	set nessparamset(sco) [list T pressure lip_frequency Sr mu sigma H w FS vibamp vibfreq tremamp tremfreq noiseamp valveopening valvevibfreq valvevibamp instrumentfile maxout]
	set nessparamset(sco2) [list fs maxout t instrumentfile sr mu sigma h w valveopening pressure lip_frequency vibfreq vibamp tremfreq tremamp valvevibfreq valvevibamp noiseamp]
		;#	sco2 is used in parameter calls
	set nessparamset(sco3) [list maxout instrumentfile FS T Sr mu sigma H w pressure lip_frequency vibamp vibfreq tremamp tremfreq noiseamp valvevibfreq valvevibamp valveopening]
		;#	sco3 is correct order for outputting data to score file
	set nessparamset(sco4) [list fs maxout t instrumentfile sr mu sigma h w valveopening valvevibfreq valvevibamp pressure lip_frequency vibfreq vibamp tremfreq tremamp noiseamp]
		;#	sco4 is order of parameters in window

	set ness_longparamname(vpos) "VALVE POSITION(S)"
	set ness_longparamname(vdl)	 "BYPASS TUBE MIN(S)"
	set ness_longparamname(vbl)  "BYPASS TUBE LEN(S)"

	set ness_longparamname(maxout)		   "MAXIMUM OUTPUT LEVEL"
	set ness_longparamname(instrumentfile) "INSTRUMENT FILE"
	set ness_longparamname(t)			   "DURATION"
	set ness_longparamname(fs)			   "SAMPLING RATE"
	set ness_longparamname(sr)			   "LIP AREA"
	set ness_longparamname(mu)			   "LIP MASS"
	set ness_longparamname(sigma)		   "LIP DAMPING"
	set ness_longparamname(h)			   "LIP EQUILIBRIUM SEPARATION"
	set ness_longparamname(w)			   "LIP WIDTH"
	set ness_longparamname(pressure)	   "PRESSURE"
	set ness_longparamname(lip_frequency)  "LIP FREQUENCY"
	set ness_longparamname(vibfreq)		   "LIP VIBRATO FREQUENCY"
	set ness_longparamname(vibamp)		   "LIP VIBRATO AMPLITUDE"
	set ness_longparamname(tremfreq)	   "LIP TREMOLO FREQUENCY"
	set ness_longparamname(tremamp)		   "LIP TREMOLO AMPLITUDE"
	set ness_longparamname(noiseamp)	   "NOISE AMPLITUDE"
	set ness_longparamname(valvevibfreq)   "VALVE VIBRATO FREQUENCY"
	set ness_longparamname(valvevibamp)	   "VALVE VIBRATO AMPLITUDE"
	set ness_longparamname(valveopening)   "VALVE OPENING"

	set nes(colour) DarkSeaGreen1
	set nes(minscoredur)	0.01
	set nes(hiscoredur)		60
	set nes(maxscoredur)	3600
	
	set nes(valving_params) [list valveopening valvevibfreq valvevibamp]

}

proc GetNessRangeTop {nam} {
	global nes
	switch -- $nam {
		"maxout"		{ set maxx $nes(MAXOUT_MAX)		}
		"Sr"			{ set maxx $nes(SR_MAX)			}
		"sr"			{ set maxx $nes(SR_MAX)			}
		"mu"			{ set maxx $nes(MU_MAX)			}
		"sigma"			{ set maxx $nes(SIGMA_MAX)		}
		"H"				{ set maxx $nes(H_MAX)			}
		"h"				{ set maxx $nes(H_MAX)			}
		"w"				{ set maxx $nes(W_MAX)			}
		"T"				{ set maxx $nes(T_MAX)			}
		"t"				{ set maxx $nes(T_MAX)			}
		"pressure"		{ set maxx $nes(PRESSURE_MAX)	}
		"lip_frequency" { set maxx $nes(LIPFRQ_MAX)		}
		"vibamp"		{ set maxx $nes(VIBAMP_MAX)		}
		"vibfreq"		{ set maxx $nes(VIBFRQ_MAX)		}
		"tremamp"		{ set maxx $nes(TREMAMP_MAX)	}
		"tremfreq"		{ set maxx $nes(TREMFRQ_MAX)	}
		"noiseamp"		{ set maxx $nes(NOIS_MAX)		}
		"valvevibamp"	{ set maxx $nes(VVIBAMP_MAX)	}
		"valvevibfreq"	{ set maxx $nes(VVIBFRQ_MAX)	}
		"valveopening"	{ set maxx $nes(OPENING_MAX)	}
		"custominstrument" { set maxx $nes(CUSTOM_MAX)	} 
		"temperature"	{ set maxx $nes(TEMP_MAX)		}	 
		"vpos"			{ set maxx $nes(VPOS_MAX)		} 
		"vdl"			{ set maxx $nes(VDL_MAX)		} 
		"vbl"			{ set maxx $nes(VBL_MAX)		} 
		"bore"			{ set maxx $nes(BORE_MAX)		}
	}
	return $maxx
}

proc GetTypicalNessRangeTop {nam} {
	global nes
	switch -- $nam {
		"maxout"		{ set tpcval $nes(MAXOUT_HI)	}
		"Sr"			{ set tpcval $nes(SR_HI)		}
		"sr"			{ set tpcval $nes(SR_HI)		}
		"mu"			{ set tpcval $nes(MU_HI)		}
		"sigma"			{ set tpcval $nes(SIGMA_HI)		}
		"H"				{ set tpcval $nes(H_HI)			}
		"h"				{ set tpcval $nes(H_HI)			}
		"w"				{ set tpcval $nes(W_HI)			}
		"T"				{ set tpcval $nes(T_HI)			}
		"t"				{ set tpcval $nes(T_HI)			}
		"pressure"		{ set tpcval $nes(PRESSURE_HI)	}
		"lip_frequency" { set tpcval $nes(LIPFRQ_HI)	}
		"vibamp"		{ set tpcval $nes(VIBAMP_HI)	}
		"vibfreq"		{ set tpcval $nes(VIBFRQ_HI)	}
		"tremamp"		{ set tpcval $nes(TREMAMP_HI)	}
		"tremfreq"		{ set tpcval $nes(TREMFRQ_HI)	}
		"noiseamp"		{ set tpcval $nes(NOIS_HI)		}
		"valvevibamp"	{ set tpcval $nes(VVIBAMP_HI)	}
		"valvevibfreq"	{ set tpcval $nes(VVIBFRQ_HI)	}
		"valveopening"	{ set tpcval $nes(OPENING_HI)	}
		"custominstrument" { set tpcval $nes(CUSTOM_MAX) } 
		"temperature"	{ set tpcval $nes(TEMP_HI)		}	 
		"vpos"			{ set tpcval $nes(VPOS_HI)		} 
		"vdl"			{ set tpcval $nes(VDL_HI)		} 
		"vbl"			{ set tpcval $nes(VBL_HI)		}
		"bore"			{ set tpcval $nes(BORE_HI)		}
	}
	return $tpcval
}

proc GetNessRangeBot {nam} {
	global nes
	switch -- $nam {
		"maxout"		{ set minn $nes(MAXOUT_MIN)		}
		"Sr"			{ set minn $nes(SR_MIN)			}
		"sr"			{ set minn $nes(SR_MIN)			}
		"mu"			{ set minn $nes(MU_MIN)			}
		"sigma"			{ set minn $nes(SIGMA_MIN)		}
		"H"				{ set minn $nes(H_MIN)			}
		"h"				{ set minn $nes(H_MIN)			}
		"w"				{ set minn $nes(W_MIN)			}
		"T"				{ set minn $nes(T_MIN)			}
		"t"				{ set minn $nes(T_MIN)			}
		"pressure"		{ set minn $nes(PRESSURE_MIN)	}
		"lip_frequency" { set minn $nes(LIPFRQ_MIN)		}
		"vibamp"		{ set minn $nes(VIBAMP_MIN)		}
		"vibfreq"		{ set minn $nes(VIBFRQ_MIN)		}
		"tremamp"		{ set minn $nes(TREMAMP_MIN)	}
		"tremfreq"		{ set minn $nes(TREMFRQ_MIN)	}
		"noiseamp"		{ set minn $nes(NOIS_MIN)		}
		"valvevibamp"	{ set minn $nes(VVIBAMP_MIN)	}
		"valvevibfreq"	{ set minn $nes(VVIBFRQ_MIN)	}
		"valveopening"	{ set minn $nes(OPENING_MIN)	}
		"custominstrument" { set minn $nes(CUSTOM_MIN)	} 
		"temperature"	{ set minn $nes(TEMP_MIN)		} 
		"vpos"			{ set minn $nes(VPOS_MIN)		} 
		"vdl"			{ set minn $nes(VDL_MIN)		} 
		"vbl"			{ set minn $nes(VBL_MIN)		} 
		"bore"			{ set minn $nes(BORE_MIN)		}
	}
	return $minn
}

###########################
# MANAGEMENT OF NESSFILES #
###########################

#----- loads existing ness management data from storage, and checks for file-existence, with warnings

proc NessMLoad {} {
	global nesstype evv nessprof nesinterp

	set fnam [file join $evv(URES_DIR) $evv(NESS_MANAGE)$evv(CDP_EXT)]
	set fnambakup [file join $evv(URES_DIR) $evv(NESS_MANAGE)_bak$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		catch {file copy -force $fnam $fnambakup}
	}
	while {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file '$fnam' to manage your nessfiles"
			break
		}
		set linecnt 0
		while {[gets $zit line] >= 0} {
			incr linecnt
			set line [string trim $line]
			set line [split $line]
			catch {unset nuline}
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				lappend nuline $item
			}
			if {[info exists nuline]} {
				if {[llength $nuline] != 2} {
					lappend badsyn $linecnt
				} else {
					set OK 1
					set typ [lindex $nuline 0]						;#	type specified in stored management file
					if {!([string match $typ "i"] || [string match $typ "s"])} {
						lappend badsyn $linecnt
						continue
					}
					set nessfnam [lindex $nuline 1]
					if {![file exists $nessfnam]} {
						lappend badfiles $nessfnam
						continue
					}
					set gottyp [IsAValidNessFile $nessfnam 1 0 0]	;#	type extracted from file itself
					if {$gottyp == "0"} {
						lappend badnesses $nessfnam					;#	Remember files that are SUPPOSED to be valid NESS files, but aren't
					} elseif {$typ != $gottyp} {
						lappend nulines [list $gottyp $nessfnam]	;#	Correct any type changes (should be redundant)
					} else {
						lappend nulines $nuline						;#	Remebver valid lines	
					}
				}
			}
		}
		close $zit
		if [info exists badsyn] {
			set msg "Physical modelling data info file $fnam has bad syntax at line\n"
			if {[llength $badsyn] > 1} {
				append msg "s"
			}
			append msg "\n"
			foreach lineno $badsyn {
				append msg "$lineno "
			}
			Inf $msg
		}
		if [info exists badfiles] {
			set msg "The following physical modelling data files no longer exist\n"
			set cnt 0
			foreach badfile $badfiles {
				if {$cnt > 20} {
					append msg "AND MORE\n"
					break
				}
				append msg $badfile "\n"
				incr cnt
			}
			Inf $msg
		}
		if [info exists badnesses] {
			set msg "The following files listed as physical modelling data are no longer valid\n"
			set cnt 0
			foreach badfile $badnesses {
				if {$cnt > 20} {
					append msg "and more\n"
					break
				}
				append msg $badfile "\n"
				incr cnt
			}
			Inf $msg
		}
		if {[info exists nulines]} {
			foreach line $nulines {
				set nam [lindex $line 1]
				set nesstype($nam) [lindex $line 0]
			}
			if {[info exists badsyn] || [info exists badfiles]} {
				NessMStore
			}
		} else {
			catch {file delete $fnam}
		}
		break
	}
	set fnam [file join $evv(URES_DIR) $evv(NESS_PROFILE)$evv(CDP_EXT)]
	set fnambakup [file join $evv(URES_DIR) $evv(NESS_PROFILE)_bak$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		catch {file copy -force $fnam $fnambakup}
	}
	while {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file '$fnam' to find your brass-instrument profiles"
			break
		}
		while {[gets $zit line] >= 0} {
			set itemcnt 0
			set isdist 1
			set OK 1
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			set line [split $line]
			catch {unset nuline}
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				if {$itemcnt == 0} {
					if {![ValidCDPRootname $item]} {
						Inf "Invalid filename in bore profile of $item"
						set dostore 1
						set OK 0
						break
					} else {
						set profname $item
					}
				} else {
					if {![IsNumeric $item] || ($item < 0)} {
						Inf "Non numeric (or negative) data in bore profile of $profname"
						set dostore 1
						set OK 0
						break
					}
					if {$isdist} {
						if {$itemcnt > 1} {
							if {$item <=  $lastdist} {
								Inf "Distances along bore do not increase at line in bore profile of $profname"
								set dostore 1
								set OK 0
								break
							}
						}
						set lastdist $item
					} else {
						if {$item <= 0.0} {
							Inf "Bore constricted to zero at line in profile of $profname"
							set dostore 1
							set OK 0
							break
						}
					}
					set isdist [expr !$isdist]
				}
				lappend nuline $item
				incr itemcnt
			}
			if {!$OK} {
				continue
			}
			if {[info exists nuline]} {
				set len [llength $nuline]
				if {($len < 11) || [IsEven $len]} {
					Inf "Invalid bore profile for $profname \n\nafter bore name, must have even number of entries (at least 10)"
					set dostore 1
					continue
				} else {
					set nessprof($profname) [lrange $nuline 1 end]
					lappend profnams $profname
				}
			}
		}
		close $zit
		break
	}
	if {[info exists dostore]} {	;#	Corrects stored data
		NessProfileStore
	}

	set fnam [file join $evv(URES_DIR) $evv(NESS_INTERP)$evv(CDP_EXT)]
	set fnambakup [file join $evv(URES_DIR) $evv(NESS_INTERP)_bak$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		catch {file copy -force $fnam $fnambakup}
	}
	if {[file exists $fnam]} {

		if {![info exists profnams]} {		;#	If there is no profile data
			catch {file delete $fnam}
			return
		}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file '$fnam' to find your interpolated brass-instrument profiles"
			return
		}
		while {[gets $zit line] >= 0} {
			set OK 1
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			set line [split $line]
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				if {![ValidCDPRootname $item]} {
					Inf "Invalid filename in interpolated bore profiles listing"
					set OK 0
					break
				} else {
					lappend nams $item
				}
			}
			if {!$OK} {
				continue
			}
		}
		close $zit
	}
	catch {unset goodnams}
	if {[info exists nams]} {
		set dostore 0
		foreach nam $nams {
			if {[lsearch $profnams $nam] >= 0} {
				lappend goodnams $nam
			} else {
				set dostore 1
			}
		}
		if {![info exists goodnams]} {
			catch {file delete $fnam}
		} else {
			foreach nam $goodnams {
				set nesinterp($nam) 1
			}
			if {$dostore} {
				NessInterpStore
			}
		}
	}
}

#----- stores ness management data to a file

proc NessMStore {} {
	global nesstype evv nes nesinterp nessprof
	set tempfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)

	if {[info exists nesstype]} {
		foreach name [array names nesstype] {
			lappend names $name
		}
		if {[info exists nes(istore)] || [CheckInterpStore $names]} {		;#	interp files copied, or related data files possibly modified
			NessInterpStore
			catch {unset nes(istore)}
		}
		if {[info exists nes(pstore)] || [CheckProfileStore $names]} {		;#	profile files copied, or related data files possibly modified
			NessProfileStore
			catch {unset nes(pstore)}
		}
		set names [lsort -dictionary $names]
		if [catch {open $tempfnam "w"} zit] {
			Inf "Cannot open temporary file '$tempfnam' to record physical modelling management data"
			return
		}
		foreach name $names {
			set nuline $nesstype($name)			;#	type, name
			lappend nuline $name
			puts $zit $nuline
		}
		close $zit
	} else {
		catch {unset nesinterp}
		NessInterpStore
		catch {unset nessprof}
		NessProfileStore
	}
	set fnam [file join $evv(URES_DIR) $evv(NESS_MANAGE)$evv(CDP_EXT)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zit1] {
			set msg	"Cannot delete existing nessmanager file ($fnam) to write new one.\n"
			append msg "New data is in file '$tempfnam'.\n"
			append msg " to preserve this data, delete the existing file '$fnam',\n"
			append msg "And rename '$tempfnam' to '$fnam' outside the sound loom, before proceeding"
			Inf $msg
			return
		}
	}
	if {[file exists $tempfnam]} {
		if [catch {file rename $tempfnam $fnam} zit2] {
			set msg	"Cannot rename temporary file '$tempfnam' to '$fnam'\n"
			append msg "To preserve physical modelling management data,\n"
			append msg "Rename this file outside the sound loom, before proceeding"
			Inf $msg
			return
		}
	}
}

#----- stores ness brass-instrument profile data to a file: 

proc NessProfileStore {} {
	global nessprof evv
	set tempfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
	set fnam [file join $evv(URES_DIR) $evv(NESS_PROFILE)$evv(CDP_EXT)]
	if {![info exists nessprof]} {
		if {[file exists $fnam]} {
			catch {file delete $fnam} zit
		}
		return
	}
	foreach name [array names nessprof] {
		if {$name == "cdptest"} {
			continue
		}
		lappend names $name
	}
	if {![info exists names]} {
		if {[file exists $fnam]} {
			catch {file delete $fnam} zit
		}
		return
	}
	if {[CheckInterpStore $names]} {
		NessInterpStore
	}
	set names [lsort -dictionary $names]
	if [catch {open $tempfnam "w"} zit] {
		Inf "Canot open temporary file '$tempfnam' to record physical modelling brass profile data"
		return
	}
	foreach name $names {
		set nuline [concat $name $nessprof($name)]			;#	name, bore-profile-display pairs
		puts $zit $nuline
	}
	close $zit
	if [file exists $fnam] {
		if [catch {file delete $fnam} zit1] {
			set msg	"Cannot delete existing ness brass-instrument profile data file ($fnam) to write new one.\n"
			append msg "New data is in file '$tempfnam'.\n"
			append msg " to preserve this data, delete the existing file '$fnam',\n"
			append msg "And rename '$tempfnam' to '$fnam' outside the sound loom, before proceeding"
			Inf $msg
			return
		}
	}
	if [catch {file rename $tempfnam $fnam} zit2] {
		set msg	"Cannot rename temporary file '$tempfnam' to '$fnam'\n"
		append msg "To preserve brass-instrument profile data,\n"
		append msg "Rename this file outside the sound loom, before proceeding"
		Inf $msg
		return
	}
}

#----- stores ness brass-instrument INTERPOLATED profile data to a file.

proc NessInterpStore {} {
	global nesinterp evv
	set tempfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
	set fnam [file join $evv(URES_DIR) $evv(NESS_INTERP)$evv(CDP_EXT)]
	if {![info exists nesinterp]} {
		if {[file exists $fnam]} {
			catch {file delete $fnam} zit
		}
		return
	}
	foreach name [array names nesinterp] {
		if {$name == "cdptest"} {
			continue
		}
		lappend names $name
	}
	if {![info exists names]} {
		if {[file exists $fnam]} {
			catch {file delete $fnam} zit
		}
		return
	}
	set names [lsort -dictionary $names]
	if [catch {open $tempfnam "w"} zit] {
		Inf "Canot open temporary file '$tempfnam' to record physical modelling interpolated brass profile data"
		return
	}
	foreach name $names {
		puts $zit $name
	}
	close $zit
	if [file exists $fnam] {
		if [catch {file delete $fnam} zit1] {
			set msg	"Cannot delete existing ness brass-instrument interpolated profile data file ($fnam) to write new one.\n"
			append msg "New data is in file '$tempfnam'.\n"
			append msg " to preserve this data, delete the existing file '$fnam',\n"
			append msg "And rename '$tempfnam' to '$fnam' outside the sound loom, before proceeding"
			Inf $msg
			return
		}
	}
	if [catch {file rename -force $tempfnam $fnam} zit2] {
		set msg	"Cannot rename temporary file '$tempfnam' to '$fnam'\n\n\n$zit2\n\n"
		append msg "To preserve interpolated brass-instrument profile data,\n"
		append msg "Rename this file outside the sound loom, before proceeding"
		Inf $msg
		return
	}
}

#--- When profile listing is updated, or nessdatafiles are updated deleted etc : check the interp info

proc CheckInterpStore {names} {
	global nesinterp
	if {![info exists nesinterp]} {
		return 0
	} 
	foreach nam $names {
		lappend basnames [file rootname [file tail $nam]]
	}
	set names $basnames
	foreach inam [array names nesinterp] {
		if {$inam == "cdptest"} {
			continue
		}
		lappend inams $inam
	}
	if {![info exists inams]} {
		return 0
	}
	set len [llength $inams]
	set ilen $len
	set cnt 0 
	while {$cnt < $len} {
		set thisinam [lindex $inams $cnt]
		if {[lsearch $names $thisinam] < 0} {
			unset nesinterp($thisinam)
			set inams [lreplace $inams $cnt $cnt]
			incr len -1
		} else {
			incr cnt
		}
	}
	if {($len == 0) && ![info exists nesinterp(cdptest)]} {
		unset nesinterp
	} 
	if {$len != $ilen} {
		return 1
	}
	return 0
}

#--- When nesstype listing is updated, check the profile info

proc CheckProfileStore {names} {
	global nessprof
	if {![info exists nessprof]} {
		return 0
	} 
	foreach nam $names {
		lappend basnames [file rootname [file tail $nam]]
	}
	set names $basnames
	foreach inam [array names nessprof] {
		if {$inam == "cdptest"} {
			continue
		}
		lappend inams $inam
	}
	if {![info exists inams]} {
		return 0
	}
	set len [llength $inams]
	set ilen $len
	set cnt 0 
	while {$cnt < $len} {
		set thisinam [lindex $inams $cnt]
		if {[lsearch $names $thisinam] < 0} {
			unset nessprof($thisinam)
			set inams [lreplace $inams $cnt $cnt]
			incr len -1
		} else {
			incr cnt
		}
	}
	if {($len == 0) && ![info exists nessprof(cdptest)]} {
		unset nessprof
	} 
	if {$len != $ilen} {
		return 1
	}
	return 0
}

#-----  On Creating a NEW nessfile, or editing an existing nessfile, OR OVERWRITING an existing file, updates the ness management data

proc NessMUpdate {nessfnam dostore typ} {
	global nesstype
	if {$typ == "0"} {							;#	This implies we've NOT already checked the type
		set typ [IsAValidNessFile $nessfnam 1 0 0]
		if {$typ == "0"} {
			if {[info exists nesstype($nessfnam)]} {
				PurgeNessData $nessfnam
				if {$dostore} {					;#	IF NESS_MANAGE DATA EXISTS FOR FILE, DELETE IT
					NessMStore
				}
				return 1
			}
			return 0							;#	OTHERWISE RETURN 'NO-UPDATE'
		}
	}											;#	IF VALID DATA
	set newdata 1							
	if {[info exists nesstype($nessfnam)]} {	;#	IF NESS_MANAGE DATA FOR FILE ALREADY EXISTS

		if {$typ == $nesstype($nessfnam)} {		;#	CHECK IF IT HAS CHANGED
			set newdata 0
		} elseif {$typ == "s"} {				;#	HAS CHANGED FROM "i" TO "s", SO INSTRUMENT DESTROYED
			RemoveNessInterp $nessfnam
		}
	}
	if {$newdata} {								;#	IF DATA HAS CHANGED (OR IF THIS IS ENTIRELY NEW NESSFILE)
		set nesstype($nessfnam) $typ			;#	UPDATE NESS MANAGER
		if {$dostore} {
			NessMStore
		}
		return 1
	}
	return 0									;#	IF NO CHANGE,  RETURN 'NO-UPDATE'
}

#-----  On Deleting any nessfile, updates the ness management data 

proc NessMDelete {fnam dostore} {
	global nesstype
	set storable 0
	if [info exists nesstype($fnam)] {
		PurgeNessData $fnam
		set storable 1
	} else {
		return 0
	}
	if {$storable && $dostore} {
		NessMStore
	}
	return 1
}

#--- Checks file extension, and if ".m" does NOT do a full scan

proc UpdatedIfANess {fnam} {
	global nessinit
	if {![info exists nessinit]} {
		return 0
	}
	set typ [IsAValidNessFile $fnam 1 0 0]
	if {$typ == "0"} {
		return 0
	}
	return [NessMUpdate $fnam 0 $typ]
}

#--- Ignores the file extension and does a full scan

proc UpdatedIfANessFull {fnam} {
	global nessinit
	if {![info exists nessinit]} {
		return 0
	}
	set typ [IsAValidNessFile $fnam 0 0 0]		;#	Ignore what file extension is and do full parse
	if {$typ == "0"} {
		return 0
	}
	return [NessMUpdate $fnam 0 $typ]
}

proc NessMPurge {dostore} {
	global nesstype
	set storable 0
	if {![info exists nesstype]} {
		return 0
	}
	foreach name [array names nesstype] {
		if {![file exists $name]} {
			PurgeNessData $name
			set storable 1
		}
	}
	if {$storable} {
		if {$dostore} {
			NessMStore
		}
		return 1
	}
	return 0
}

proc CopiedIfANess {fnam nufnam dostore} {
	global evv nesstype nessins nes nessprof nesinterp
	if {[file extension $fnam] != $evv(NESS_EXT)} {
		return 0
	}
	if {[info exists nesstype($fnam)]} {
		set nesstype($nufnam) $nesstype($fnam)
		if {[info exists nessins($fnam)]} {
			set nessins($nufnam) $nessins($fnam)
		}
		set fnam [file rootname [file tail $fnam]]
		if {[info exists nesinterp($fnam)]} {
			set nesinterp([file rootname [file tail $nufnam]]) $nesinterp($fnam)
			set nes(istore) 1
		}
		if {[info exists nessprof($fnam)]} {
			set nessprof([file rootname [file tail $nufnam]]) $nessprof($fnam)
			set nes(pstore) 1
		}
		if {$dostore} {
			NessMStore
		}
	}
	return 1
}

##################################
# TEST FOR VALID NESS DATA FILES #
##################################

proc IsAValidNessFile {nessfnam checkext intyp instronly} {
	global evv nessparam nessinit

	if {![info exists nessinit]} {
		return 0
	}
	if {$checkext} {
		if {![string match [file extension $nessfnam] $evv(NESS_EXT)]} {
			return 0
		}
	}
	set ftyp [FindFileType $nessfnam]
	if {![IsNotMixText $ftyp]} {
		return 0
	}
	if {$ftyp != $evv(WORDLIST)} {
		return 0
	}
	if [catch {open $nessfnam "r"} zit] {
		Inf "Cannot open possible nessfile '$nessfnam'"
		return 0
	}
	while {[gets $zit line] >= 0} {				;#	GET NESSFILE DATA FROM NESSFILE
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set k [string first "%" $line]			;#	REMOVE COMMENT LINES, AND TRAILING COMMENTS
		if {$k >= 0} {
			if {$k == 0} {
				continue
			} else {
				incr k -1
				set line [string range $line 0 $k]
				set line [string trim $line]
			}
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend nuline $item
		}
		if {[info exists nuline]} {
			lappend nulines $nuline
		}
	}
	close $zit
	if {![info exists nulines]} {
		return 0
	}
	catch {unset nessparam(bore)}
	switch -- $intyp {
		0 {
			set typ [ValidNessInstr $nulines 0 $nessfnam]
			if {$typ == "0"} {
				if {$instronly} {
					return $typ
				}
				set typ [ValidNessScore $nulines 0 $nessfnam]
			}
		}
		"i" {
			set typ [ValidNessInstr $nulines 1 $nessfnam]
		}
		"s" {
			set typ [ValidNessScore $nulines 1 $nessfnam]
		}
	}
	return $typ
}

#---- Test a ".m" file to see if it is a valid instrument

proc ValidNessInstr {lines report fnam} {
	global nessrange nessparam nessparamset nessinit

	if {![info exists nessinit]} {
		return 0
	}
	set paramset $nessparamset(ins)
	UnsetNessParams ins
	
	set line [lindex $lines 0]
	set item [lindex $line 0]

	;#	CHECK "global" DECLARATIONS

	if {![string match $item "global"]} {
		if {$report} {
			Inf "Missing global declarations "
		}
		return 0
	}
	set globcnt 0
	set globals {}

	set len [llength $lines]
	while {$globcnt < $len} {
		set line [lindex $lines $globcnt]
		if {[string match [lindex $line 0] "global"]} {
			set globals [concat $globals [lrange $line 1 end]]
			while {[string match [lindex $globals end] "..."]} {
				set len [llength $globals]
				incr len -2
				set globals [lrange $globals 0 $len]
				incr globcnt
				set line [lindex $lines $globcnt]
				set globals [concat $globals [lrange $line 0 end]]
			}
			incr globcnt
		} else {
			break
		}
	}

	foreach item $globals {

		if {[lsearch $paramset $item] < 0} {
			if {$report} {
				Inf "Unknown parameter $item declared"
			}
			lappend unknown_globals $item
		}
		if {[info exists found($item)]} {
			if {$report} {
				Inf "Parameter $item globally declared more than once"
			}
		} else {
			set found($item) 1
		}
		if {$item == "temperature"} {
			set typ "i"
		}
	}
	
	foreach paramname $paramset {
		if {![info exists found($paramname)]} {
			lappend badparams $paramname
		}
	}
	if {[info exists badparams]} {
		set msg "The following  instrument parameters are not declared\n"
		foreach item $badparams {
			append msg $item\n
		}
		if {$report} {
			Inf $msg
		}
		UnsetNessParams ins
		return 0
	}
	if {[info exists unknown_globals]} {
		set msg "The following unknown global parameters were declared"
		if {$fnam != "0"} {
			append msg " in file $fnam"
		}
		append msg "\n"
		foreach item $unknown_globals {
			append msg $item\n
		}
		Inf $msg
	}

	catch {unset found}

	;#	CHECK PARAMETER LINES

	set lines [lrange $lines $globcnt end]

	;#	SEPARATE EQUALS e.g. "custominstrument=0;" TO "custominstrument" "=" "0;"

	set lines [SeparateEquals $lines]

	;#	CHECK SINGLE VALUES AND CONCATENATE TABLES ONTO SINGLE LINES

	set paramcnt 0
	set len [llength $lines]
	set linecnt 0
	catch {unset nulines}
	while {$linecnt < $len} {								
		set line [lindex $lines $linecnt]
		set paramname [lindex $line 0]
		if {[lsearch $paramset $paramname] < 0} {
			if {$report} {
				Inf "Unknown parameter $paramname assigned values"
			}
			UnsetNessParams ins
			return 0
		}
		set paramval [lindex $line 2]
		if [info exists nessrange($paramname)] {
			set lo [lindex $nessrange($paramname) 0]
			set hi [lindex $nessrange($paramname) 1]
		}
		switch -- $paramname {
			"custominstrument" -
			"temperature" {
				if {[string index $paramval end] != ";"} {
					if {$report} {
						Inf "Invalid line ending  for parameter $paramname (should be \"\;\")"
					}
					UnsetNessParams ins
					return 0
				}
				set slen [string length $paramval]
				incr slen -2
				set paramval [string range $paramval 0 $slen]
				if {[IsEngineeringNotation $paramval]} {
					set paramval [UnEngineer $paramval]
				}
				if {$paramname == "custominstrument"} {
					if {!(($paramval == $hi) || ($paramval == $lo))} {
						if {$report} {
							Inf "Invalid value ($paramval) for '$paramname' ($lo or $hi ONLY)"
						}
						UnsetNessParams ins
						return 0
					}
				} elseif {![IsNumeric $paramval] || ($paramval > $hi) || ($paramval <$lo)} {
					if {$report} {
						Inf "Invalid value ($paramval) for '$paramname' (Range $lo to $hi)"
					}
					UnsetNessParams ins
					return 0
				}
				lappend nulines $line
				incr paramcnt
				set found($paramname) 1
			}
			"vpos" -
			"vdl"  -
			"vbl"  {									;#	Strip out enclosing square-brackets
				set k [string first "\[" $paramval]
				if {$k < 0} {
					if {$report} {
						Inf "No opening bracket around param vals for $paramname"
					}
					UnsetNessParams ins
					return 0
				}
				set k [string first "\]" $paramval]
				if {$k < 0} {
					if {$report} {
						Inf "No closing bracket around param vals for $paramname"
					}
					UnsetNessParams ins
					return 0
				}
				incr k -1
				set nuparamval [string range $paramval 1 $k]
				append nuparamval ";"
				set nuline [lreplace $line 2 2 $nuparamval]
				lappend nulines $nuline
				incr paramcnt
				set found($paramname) 1
			}
			"bore" {									;#	Concatenate all lines belonging to same [] brackets
				set k [string first "\[" $line]
				if {$k >= 0} {
					set nuline $line
					set j [string first "\]" $line]
					while {$j < 0} {
						incr linecnt
						if {$linecnt >= $len} {
							if {$report} {
								Inf "No closing bracket \"\]\" for param $paramname data"
							}
							UnsetNessParams ins
							return 0
						}
						set line [lindex $lines $linecnt]
						set nuline [concat $nuline $line]
						set j [string first "\]" $line]
					}
					lappend nulines $nuline
				} else {
					lappend nulines $line
				}
				incr paramcnt
				set found($paramname) 1
			}		
			default {
				if {$report} {
					Inf "Unknown parameter $paramname"
				}
				UnsetNessParams ins
				return 0
			}
		}
		incr linecnt
	}

	foreach paramname $paramset {
		if {![info exists found($paramname)]} {
			lappend badparams $paramname
		}
	}
	if {[info exists badparams]} {
		set msg "The following instrument parameters have no values assigned\n"
		foreach item $badparams {
			append msg $item\n
		}
		if {$report} {
			Inf $msg
		}
		UnsetNessParams ins
		return 0
	}
	
	;#	STRIP OUT TRAILING ";" FROM EACH LINE

	set lines $nulines					
	set lineslen [llength $lines]
	set linecnt 0
	while {$linecnt < $lineslen} {
		set line [lindex $lines $linecnt]
		set paramname [lindex $line 0]
		set paramval  [lindex $line end]
		if {[string index $paramval end] != ";"} {
			if {$report} {
				Inf "Error in parsing $paramname line,looking for trailing \";\" (found \"[string index $paramval end]\")"
			}
			UnsetNessParams ins
			return 0
		}
		set paramlen [string length $paramval]
		incr paramlen -2
		set paramval [string range $paramval 0 $paramlen]
		set line [lreplace $line end end $paramval]
		set lines [lreplace $lines $linecnt $linecnt $line]
		incr linecnt
		if {$paramname == "temperature"} {
			set nessparam($paramname) $paramval
		}
	}

	;#	CHECK RANGES OF PARAMS, AND INCREASING TIMES (OR DISTANCES, IN TERMS OF BORE)

	set linecnt 0
	while {$linecnt < $lineslen} {
		set gotbracket 0
		set line [lindex $lines $linecnt]
		set len [llength $line]
		set paramname [lindex $line 0]
		set n 1
		while {$n < $len} {
			set item [lindex $line $n]
			set k [string first "\[" $item]				;#	Check for opening bracket "["
			if {$k >= 0} {
				incr k
				set item [string range $item $k end]
				set line [lreplace $line $n $n $item]
				set lines [lreplace $lines $linecnt $linecnt $line]
				set gotbracket 1
				break
			}
			incr n
		}
		if {$gotbracket} {
			while {$n < $len} {
				set item [lindex $line $n]
				set k [string first "\]" $item]			;#	Check for closing bracket "]"
				if {$k >= 0} {
					incr k -1
					if {$k < 0} {						;#	Closing bracket is item on its own
						set line [lreplace $line $n $n]
					} else {
						set item [string range $item 0 $k]
						set line [lreplace $line $n $n $item]
					}
					set lines [lreplace $lines $linecnt $linecnt $line]
					break
				}
				incr n
			}
			if {$n == $len} {
				if {$report} {
					Inf "No closing bracket found for parameter $paramname"
				}
				UnsetNessParams ins
				return 0
			}
		}
		set lo [lindex $nessrange($paramname) 0]
		set hi [lindex $nessrange($paramname) 1]
		set cnt 0
		switch -- $paramname {
			"vpos" -
			"vdl"  -
			"vbl" {
				set vals {}
				set values [split [lrange $line end end] ',']			;#	Split the values into a list
				set valcnt 0
				foreach val $values {
					set val [string trim $val]
					if {[IsEngineeringNotation $val]} {
						set val [UnEngineer $val]
					}
					if {![IsNumeric $val] || ($val < $lo) || ($val > $hi)} {
						if {$report} {
							Inf "Parameter $paramname ($val) out of range ($lo to $hi)"
						}
						UnsetNessParams ins
						return 0
					}								;#	Valves cannot be superimposed at same place
					if {($paramname == "vpos") && ([lsearch $vals $val] >= 0)} {
						if {$report} {
							Inf "Two valves in same place ($val)"
						}
						UnsetNessParams ins
						return 0
					}
					lappend vals $val
					incr valcnt
				}
				set nessparam($paramname) $vals
				if {$paramname == "vpos"} {			;#	Find position of highest valve	
					set maxvalve -1
					foreach val $vals {
						if {$val > $maxvalve} {
							set maxvalve $val
						}
					}
				}									;#	Must be same number of entries in each valve parameter
				if {[info exists previous_valcnt]} {
					if {$valcnt != $previous_valcnt} {
						if {$report} {
							Inf "List of $paramname values should have same number of entries as $previous_name"
						}
						UnsetNessParams ins
						return 0
					}
				} else {
					set previous_valcnt $valcnt
					set previous_name $paramname
				}
			}
			"bore" {
				set brkfile {}
				set values [lrange $line 2 end]	
				foreach item $values {
					set k [string first ";" $item]
					if {$k > 0} {
						incr k -1
						set item [string range $item 0 $k]
					}
					set valpair [split $item ',']	;#	Split the value pairs to time val values
					if {[llength $valpair] != 2} {
						if {$report} {
							Inf "Values incorrectly paired for $paramname"
						}
						UnsetNessParams ins
						return 0
					}
					foreach val $valpair {
						set val [string trim $val]
						set brkfile [concat $brkfile $val]
					}
				}
				foreach {distance diameter} $brkfile {		;#	Check for distance increasing, from zero, and Range of params
					if {[IsEngineeringNotation $distance]} {
						set distance [UnEngineer $distance]
					}
					if {[IsEngineeringNotation $diameter]} {
						set diameter [UnEngineer $diameter]
					}
					if {![IsNumeric $distance]} {
						if {$report} {
							Inf "Invalid bore-distance value ($distance) in parameter $paramname"
						}
						UnsetNessParams ins
						return 0
					}
					if {$cnt == 0} {
						if {$distance != 0.0} {
							if {$report} {
								Inf "First bore-position not zero for parameter $paramname"
							}
							UnsetNessParams ins
							return 0
						}
					} else {
						if {$distance <=  $lastdistance} {
							if {$report} {
								Inf "Distances along bore do not increase at $lastdistance in param $paramname"
							}
							UnsetNessParams ins
							return 0
						}
					}
					set lastdistance $distance
					if {![IsNumeric $diameter] || ($diameter < $lo) || ($diameter > $hi)} {
						if {$report} {
							Inf "Parameter $paramname ($diameter) out of range ($lo to $hi)"
						}
						UnsetNessParams ins
						return 0
					}
					set maxbore $lastdistance
					incr cnt
				}
				set nessparam(bore) $brkfile
			}
		}
		incr linecnt
	}
	if {$maxvalve >= $maxbore} {
		if {$report} {
			Inf "Valves fall beyond end of instrument (last valve position = $maxvalve end of bore = $maxbore)"
		}
		UnsetNessParams ins
		return 0
	}
	return $typ
}

proc UnsetNessParams {typ} {
	global nessparamset nessparam
	foreach nam $nessparamset($typ) {
		catch {unset nessparam($nam)}
	}
}

#---- Test a ".m" file to see if it is a valid score

proc ValidNessScore {lines report infnam} {
	global nessrange nessins evv nessparamset nessparam ness_longparamname
	set paramset $nessparamset(sco)

	UnsetNessParams sco

	set line [lindex $lines 0]						;#	lines = ALL LINES IN FILE
	set item [lindex $line 0]

	;#	TEST GLOBAL DECLARATIONS					

	if {![string match $item "global"]} {
		if {$report} {
			Inf "Missing global declarations"
		}
		return 0
	}
	set globcnt 0
	set globals {}
	set len [llength $lines]
	while {$globcnt < $len} {
		set line [lindex $lines $globcnt]
		if {[string match [lindex $line 0] "global"]} {
			set globals [concat $globals [lrange $line 1 end]]
			while {[string match [lindex $globals end] "..."]} {
				set len [llength $globals]
				incr len -2
				set globals [lrange $globals 0 $len]
				incr globcnt
				set line [lindex $lines $globcnt]
				set globals [concat $globals [lrange $line 0 end]]
			}
			incr globcnt
		} else {
			break
		}
	}
	if {$globcnt == 0} {
		if {$report} {
			Inf "No global declarations found"
			return 0
		}
	}
	if {$globcnt == $len} {
		if {$report} {
			Inf "No parameter information found after global declarations"
			return 0
		}
	}

	foreach item $globals {

		if {[lsearch $paramset $item] < 0} {
			if {$report} {
				Inf "Unknown parameter $item declared"
			}
			return 0
		}
		if {[info exists found($item)]} {
			if {$report} {
				Inf "Parameter $item globally declared more than once"
			}
		} else {
			set found($item) 1
		}
		if {$item == "T"} {
			set typ "s"
		}
	}
	foreach paramname $paramset {
		if {![info exists found($paramname)]} {
			lappend badparams $paramname
		}
	}
	if {[info exists badparams]} {
		set msg "The following score parameters are not declared\n"
		foreach item $badparams {
			append msg $item\n
		}
		if {$report} {
			Inf $msg
		}
		return 0
	}
	catch {unset found}

	;#	CHECK PARAMETER LINES

	set lines [lrange $lines $globcnt end]				;#	lines = ALL LINES EXCEPT GLOBAL DECLARATIONS

	;#	SEPARATE EQUALS e.g. "maxout=0.95;" TO "maxout" "=" "0.95;"

	set lines [SeparateEquals $lines]

	;#	CHECK SINGLE VALUES AND CONCATENATE TABLES ONTO SINGLE LINES

	set paramcnt 0
	set lineslen [llength $lines]
	set linecnt 0
	catch {unset nulines}
	while {$linecnt < $lineslen} {
		set line [lindex $lines $linecnt]
		set paramname [lindex $line 0]
		if {[lsearch $paramset $paramname] < 0} {
			if {$report} {
				Inf "Unknown parameter $paramname assigned values"
			}
			return 0
		}
		set paramval [lindex $line 2]
		if [info exists nessrange($paramname)] {
			set lo [lindex $nessrange($paramname) 0]
			set hi [lindex $nessrange($paramname) 1]
		}
		switch -- $paramname {
			"maxout" -
			"instrumentfile" -
			"FS" -
			"T" {
				if {[string index $paramval end] != ";"} {
					if {$report} {
						Inf "Invalid line ending (should be \"\;\") for parameter $paramname"
					}
					UnsetNessParams sco
					return 0
				}
				set slen [string length $paramval]
				incr slen -2
				set paramval [string range $paramval 0 $slen]
				switch -- $paramname {
					"maxout" {
						if {[IsEngineeringNotation $paramval]} {
							set paramval [UnEngineer $paramval]
						}
						if {![IsNumeric $paramval] || ($paramval > $hi) || ($paramval <= $lo)} {
							if {$report} {
								Inf "Invalid value ($paramval) for 'maxout' (Range >$lo to $hi)"
							}
							UnsetNessParams sco
							return 0
						}
						set nessparam($paramname) $paramval
						if {[IsEngineeringNotation $nessparam($paramname)]} {
							set nessparam($paramname) [UnEngineer $nessparam($paramname)]
						}
					}
					"instrumentfile" {
						if {[string first "'" $paramval] == 0} {					;#	strip any quote-marks from instr-filename
							if {[string match "'" [string index $paramval end]]} {
								set l_len [string length $paramval]
								incr l_len -2
								set paramval [string range $paramval 1 $l_len]
								if {[string length $paramval] <= 0} {
									if {$report} {
										Inf "No valid instrument file parameter in score file."
									}
									UnsetNessParams sco
									return 0
								}
							}
						}
						append paramval $evv(NESS_EXT)
						if {![string match [string tolower $paramval] $paramval]} {
							if {$report} {
								Inf "Warning: instrument filename = $paramval : CDP doesn't recognise upper case (file $infnam)"
								UnsetNessParams sco
								return 0
							}
						}
						if {![file exists $paramval]} {
							set msg "Instrument file '$paramval' "
							if {![string match $infnam "0"]} {
								append msg "(used in score $infnam) "
							}
							append msg " does not exist"
							Inf $msg
							UnsetNessParams sco
							return 0
						}
						set nessins($infnam) $paramval							
						set nessparam($paramname) $paramval
					}
					"FS" {
						if {[IsEngineeringNotation $paramval]} {
							set paramval [UnEngineer $paramval]
						}
						if {![IsNumeric $paramval] || ![ValidSrate $paramval]} {
							if {$report} {
								Inf "Invalid value ($paramval) for srate (96000,88200,48000,44100,32000,24000,22050,16000 only)"
							}
							UnsetNessParams sco
							return 0
						}
						set nessparam($paramname) $paramval
						if {[IsEngineeringNotation $nessparam($paramname)]} {
							set nessparam($paramname) [UnEngineer $nessparam($paramname)]
						}
					}
					"T" {
						if {[IsEngineeringNotation $paramval]} {
							set paramval [UnEngineer $paramval]
						}
						if {![IsNumeric $paramval] || ![regexp {^[0-9]+} $paramval] || ($paramval > $hi) || ($paramval < $lo)} {
							if {$report} {
								Inf "Invalid value ($paramval) for \"T\""
							}
							UnsetNessParams sco
							return 0
						}
						set nessparam($paramname) $paramval
						if {[IsEngineeringNotation $nessparam($paramname)]} {
							set nessparam($paramname) [UnEngineer $nessparam($paramname)]
						}
					}
				}
				incr paramcnt
				set found($paramname) 1
			}
			"Sr"             -
			"mu"             -
			"sigma"          -
			"H"              -
			"w" {
				set k [string first "\[" $paramval]
				if {$k < 0} {
					if {$report} {
						Inf "No opening bracket around param vals for $paramname"
					}
					UnsetNessParams sco
					return 0
				}
				set k [string first "\]" $paramval]
				if {$k < 0} {
					if {$report} {
						Inf "No closing bracket around param vals for $paramname"
					}
					UnsetNessParams sco
					return 0
				}
				incr k -1
				set nuparamval [string range $paramval 1 $k]

				set theval [split $nuparamval ","]
				set nessparam($paramname) [lindex $theval 1]		;#	These params always have format "0,val"
				if {[IsEngineeringNotation $nessparam($paramname)]} {
					set nessparam($paramname) [UnEngineer $nessparam($paramname)]
				}
				append nuparamval ";"
				set nuline [lreplace $line 2 2 $nuparamval]
				lappend nulines $nuline
				incr paramcnt
				set found($paramname) 1
			}		
			"pressure"       -
			"lip_frequency"  -
			"vibamp"         -
			"vibfreq"        -
			"tremamp"        -
			"tremfreq"       -
			"noiseamp"       -
			"valvevibfreq"   -
			"valvevibamp"    -
			"valveopening" {							;#	CONCATENATE ALL LINES BELONGING TO SAME [] BRACKETS
				set k [string first "\[" $paramval]
				if {$k < 0} {
					if {$report} {
						Inf "No opening bracket around param vals for $paramname"
					}
					UnsetNessParams sco
					return 0
				}
				set nuline $line
				set j [string first "\]" $paramval]
				set origline $line
				while {$j < 0} {
					set multivalued($paramname) 1		;#	flag as multivalued
					incr linecnt
					if {$linecnt >= $lineslen} {
						if {$report} {
							Inf "No closing bracket \"\]\" for param $paramname data"
						}
						UnsetNessParams sco
						return 0
					}
					set line [lindex $lines $linecnt]
					append paramval [StripCurlies $line]
					set j [string first "\]" $paramval]
				}
				incr k
				incr j -1
				set paramval [string range $paramval $k $j]
				append paramval ";"
				set nuline [lreplace $origline 2 2 $paramval]
				lappend nulines $nuline
				incr paramcnt
				set found($paramname) 1
			}		
			default {
				if {$report} {
					Inf "Unknown parameter $paramname"
				}
				UnsetNessParams sco
				return 0
			}
		}
		incr linecnt
	}

	foreach paramname $paramset {
		if {![info exists found($paramname)]} {
			lappend badparams $paramname
		}
	}
	if {[info exists badparams]} {
		set msg "The following instrument parameters have no values assigned\n"
		foreach item $badparams {
			append msg $item\n
		}
		if {$report} {
			Inf $msg
		}
		UnsetNessParams sco
		return 0
	}

	;#	STRIP OUT TRAILING ";" FROM EACH LINE

	set lines $nulines		;# 		lines = ALL LINES EXCEPT GLOBALS AND SINGLEVAL PARAMS - maxout, instrumentfile, FS, T
			

	set lineslen [llength $lines]
	set linecnt 0
	while {$linecnt < $lineslen} {
		set line [lindex $lines $linecnt]
		set paramname [lindex $line 0]
		set paramval  [lindex $line end]
		if {[string index $paramval end] != ";"} {
			if {$report} {
				Inf "Error in parsing $paramname line,looking for trailing \";\" (found \"[string index $paramval end]\")"
			}
			UnsetNessParams sco
			return 0
		}
		set paramlen [string length $paramval]
		incr paramlen -2
		set paramval [string range $paramval 0 $paramlen]

		;#	DEAL WITH SPECIAL GROUPINGS OF VALVEOPENING DATA

		if {$paramname == "valveopening"} {
			set nessparam(valveopening) {}
			set paramval [split $paramval ";"]
			set valvolist $paramval
			set vlen [llength $valvolist]
			set kcnt 0
			foreach item $valvolist {
				set valveset [split $item ","]
				if {$kcnt == 0} {
					set setsize [llength $valveset]
				} else {
					if {$setsize != [llength $valveset]} {
						Inf "Number of valve-opening values does not tally at different times"
						UnsetNessParams sco
						return 0
					}
				}
				set nessparam(valveopening) [concat $nessparam(valveopening) $valveset] 
				incr kcnt
			}
			if {$vlen != $nessparam(T)} {
				Inf "\"T\" value ($nessparam(T)) and number of time-entries for \"valveopening\" ($vlen) do not tally"
				UnsetNessParams sco
				return 0
			}

			;#	DO FINAL SYNTAX CHECK ON VALVE-OPENING PARAMETER

			set valvecnt $setsize
			incr valvecnt -1

			set len [llength $nessparam(valveopening)]
			set cnt 0
			while {$cnt < $len} {
				set val [lindex $nessparam(valveopening) $cnt]
				if {[IsEngineeringNotation $val]} {
					set val [UnEngineer $val]
					set nessparam(valveopening) [lreplace $nessparam(valveopening) $cnt $cnt $val] 
				}
				if {$cnt == 0} {
					if {$val != 0.0} {
						Inf "Valve-opening values do not start at time zero"
						UnsetNessParams sco
						return 0
					}
					set lasttime 0.0
				} elseif {($cnt % $setsize) == 0} {
					if {$lasttime >=  $val} {
						Inf "Valve-opening times do not increase after time $lasttime"
						UnsetNessParams sco
						return 0
					}
					set lasttime $val
				} else {
					if {($val < 0.0) || ($val > 1.0)} {
						Inf "Valve-opening out of range (0-1) at time $lasttime"
						UnsetNessParams sco
						return 0
					}
				}
				incr cnt
			}
			set lines [lreplace $lines $linecnt $linecnt]		;#	VALVE-OPENING COMPLETELY CHECKED
			incr lineslen -1									;#	REMOVE FROM CHECKABLE LINES
			continue											;# 	lines = ALL EXCEPT GLOBALS, valveopening, AND SINGLEVAL PARAMS - maxout, instrumentfile, FS, T
		}
		if {[info exists multivalued($paramname)]} {			;#	Concatenate multilines, into comma-separated list
			set paramval [split $paramval ";"]
			set paramval [join $paramval ","]
		}
		set line [lreplace $line end end $paramval]
		set lines [lreplace $lines $linecnt $linecnt $line]
		incr linecnt
	}

	;#	CHECK RANGES OF PARAMS, AND INCREASING TIMES

	set linecnt 0
	while {$linecnt < $lineslen} {
		set line [lindex $lines $linecnt]
		set paramname [lindex $line 0]
		set lo [lindex $nessrange($paramname) 0]
		set hi [lindex $nessrange($paramname) 1]
		set brkfile {}											;#	Convert data into a list of values (no commas)
		set values [lrange $line 2 end]	
		set brkfile [split $values ","]
		set lenn [llength $brkfile]
		set cnt 0
		if {($paramname == "valvevibfreq") || ($paramname == "valvevibamp")} {

			;#	POSSIBLY MULTIVALUED : CHECK FOR CORRECT GROUPING, TIME INCREASING FROM ZERO, AND VALID RANGE OF PARAM

			set lo [lindex $nessrange($paramname) 0]
			set hi [lindex $nessrange($paramname) 1]
			set div [expr $lenn / $setsize]
			if {($div * $setsize) != $lenn} {
				Inf "Number of entries in $ness_longparamname($paramname) incompatible with $valvecnt valve instrument"
				UnsetNessParams sco
				return 0
			}
			while {$cnt < $lenn} {
				set val [lindex $brkfile $cnt]
				if {[IsEngineeringNotation $val]} {
					set val [UnEngineer $val]
					set brkfile [lreplace $brkfile $cnt $cnt $val] 
				}
				if {$cnt == 0} {
					if {$val != 0} {
						Inf "Times do not start at zero in $ness_longparamname($paramname)"
						UnsetNessParams sco
						return 0
					}
					set lasttime $val
				} elseif {($cnt % $setsize) == 0} {
					if {$lasttime >= $val} {
						Inf "Times do not increase after $lasttime in $ness_longparamname($paramname)"
						UnsetNessParams sco
						return 0
					}
					set lasttime $val
				} else {
					if {($val < $lo) || ($val > $hi)} {
						Inf "Values are out of range in $ness_longparamname($paramname)"
						UnsetNessParams sco
						return 0
					}
				}
				incr cnt
			}
		} else {

			;#	BRKPNT PAIRS ONLY : CHECK FOR TIME INCREASING FROM ZERO, AND VALID RANGE OF PARAM

			set istime 1
			while {$cnt < $lenn} {
				set val [lindex $brkfile $cnt]
				if {[IsEngineeringNotation $val]} {
					set val [UnEngineer $val]
					set brkfile [lreplace $brkfile $cnt $cnt $val] 
				}
				if {$istime} {
					if {![IsNumeric $val]} {
						if {$report} {
							Inf "Invalid time value ($val) in parameter $paramname"
						}
						UnsetNessParams sco
						return 0
					}
					if {$cnt == 0} {
						if {$val != 0.0} {
							if {$report} {
								Inf "First time not zero for parameter $paramname"
							}
							UnsetNessParams sco
							return 0
						}
					} else {
						if {$val <=  $lasttime} {
							if {$report} {
								Inf "Times do not increase at $lasttime in param $paramname"
							}
							UnsetNessParams sco
							return 0
						}
					}
					set lasttime $val
				} else {
					if {![IsNumeric $val] || ($val < $lo) || ($val > $hi)} {
						if {$report} {
							Inf "Parameter $paramname ($val) out of range ($lo to $hi)"
						}
						UnsetNessParams sco
						return 0
					}
				}
				set istime [expr !$istime]
				incr cnt
			}
		}
		set nessparam($paramname) $brkfile
		incr linecnt
	}
	return $typ
}

########################
# ENGINEERING NOTATION #
########################

proc IsEngineeringNotation {val} {

	set len [string length $val]
	set k [string first "e" $val]
	if {$k > 0} {
		incr k -1
		set preval [string range $val 0 $k]
		incr k 2
		if {$k >= $len} {
			return 0
		}
		set postval [string range $val $k end] 
		if {![IsNumeric $preval]} {
			return 0
		}
		if {[string index $postval 0] == "-"} {
			set postval [string range $postval 1 end]
		}
		if {![regexp {^[0-9]+$} $postval] || ($postval == 0.0)} {
			return 0
		}
		return 1
	}
	return 0
}

#---- Convert from and to Engineering notation

proc UnEngineer {val} {
	set val [StripLeadingZeros $val]
	set k [string first "e" $val]
	if {$k > 0} {
		set j [expr $k + 1]
		if {[string match [string index $val $j] "-"]} {	;#---- Convert 7.03750878125e-005 TO 0.0000703750878125
			set kk [string range $val [expr $k + 2] end]	;#	kk = 005
			set kk [StripLeadingZerosFromInteger $kk]		;#	kk = 5
			set numstr [string range $val 0 [expr $k - 1]]
			set len [string length $numstr]
			set jj [string first "." $numstr]
			if {$jj < 0} {
				set decat $len
			} else {
				set decat $jj
			}
			set numstra [string range $numstr 0 [expr $decat - 1]]
			if {$decat < [expr $len - 1]} {
				append numstra [string range $numstr [expr $decat + 1] end]
			}
			set numstr $numstra
			set decat [expr $decat - $kk]
			if {$decat <= 0} {
				set nuval "0."
				while {$decat < 0} {
					append nuval "0"
					incr decat
				}
				append nuval $numstr
			} else {
				set numval [string range $numstr 0 [expr $decat - 1]]
				append numval "."
				append numval [string range $numstr $decat end]
			}
		} else {											;#	Convert 37e5 TO 70000 OR  37.03750878125e5 TO 370375.0878125
			set nuval [string range $val 0 [expr $k - 1]]	;#	nuval = 37  or 	37.03750878125
			set kk [string range $val [expr $k + 1] end]	;#	kk = 5
			set kk [StripLeadingZerosFromInteger $kk]		;#
			set jj [string first "." $val]
			if {$jj < 0} {									;#---- Convert 37e5 TO 370000
				set n 0
				while {$n < $kk} {							;#	nuval = 370000
					append nuval 0
					incr n
				}
			} else {										;# ELSE Convert 37.03750878125e5 TO 3703750.878125 ~~OR~~ 37.03e5 to 3703000
				set predec [string range $val 0 [expr $jj - 1]] 
				set afterdec [string range $val [expr $jj + 1] [expr $k - 1]]
				set numstr $predec
				append numstr $afterdec
				set decat [expr $jj + $kk]
				set len [string length $numstr]
				if {$decat >= $len} {
					while {$decat > $len} {
						append numstr "0"
						incr len
					}
					set nuval $numstr
				} else {
					set nuval [string range $numstr 0 [expr $decat - 1]]
					append nuval "."
					append nuval [string range $numstr $decat end]
				}
			}
		}
		set val $nuval
	}
	return $val
}

proc Engineer {val} {
	set val [StripLeadingZeros $val]
	set j [string first "." $val]		
	if {$val >= 10.0} {
		if {$j < 0} {										;#	Convert 370000 to 3.7e5
			set len [string length $val]					;#	len = 6
			set kk [expr $len - 1]							;#	kk = 5
			set nuval [string index $val 0]					;#	nuval = 3	
			set afterdec [string range $val 1 end]			;#	afterdec = 70000
			set afterdec [StripZerosAtEnd $afterdec]		;#	afterdec = 7
			set len [string length $afterdec]
			if {$len > 0} {
				append nuval "."							;#	nuval = 3.	
				set len [string length $afterdec]
				set n 0
				while {$n < $len} {
					append nuval [string index $afterdec $n]	;#	nuval = 3.7
					incr n
				}
			}
			append nuval "e" $kk							;#	nuval = 3.7e5

		} else {											;#	Convert 371234.56700 to 3.1234567e5	
			set prelen $j									;#	j = 6 prelen = 6
			set kk [expr $prelen - 1]						;#	kk = 5
			set nuval [string range $val 0 $kk]				;#	nuval = 371234
			incr j
			set afterdec [string range $val $j end]			;#	afterdec = 56700
			set afterdec [StripZerosAtEnd $afterdec]		;#	afterdec = 567
			append nuval $afterdec							;#	nuval = 371234567
			set len [string length $nuval]
			set nunuval [string index $nuval 0]				;#	nunuval = 3
			append nunuval "."								;#	nunuval = 3.
			set n 1
			while {$n < $len} {
				append nunuval [string index $nuval $n]		;#	nunuval = 3.71234567
				incr n
			}
			set nuval $nunuval
			if {$nuval == 1} {
				set nuval 10
				incr e -1
			}
			append nuval "e" $kk							;#	nunuval = 3.71234567e5
		}
	} elseif {$val == 0.0} {
		set nuval 0
	} elseif {$val >= 1.0} {								;#	val = 7.632
		set nuval $val
	} else {												;#	val < 1 e.g. 0.3	OR 0.36500	OR 0.00004270  (j = 1)
		set val [StripZerosAtEnd $val]						;#				 0.3	OR 0.365	OR 0.0000427
		set cnt 1
		incr j												;#	j = 2
		while {[string match [string index $val $j] "0"]} {
			incr j											;#				j2,cnt1 OR  j2.cnt1	OR j6,cnt5	
			incr cnt
		}
		set val [string range $val $j end]					;#	val = 		3		OR	365		OR	427
		set len [string length $val]
		set nuval [string index $val 0]						;#	nuval = 	3		OR	3		OR	4
		if {$len > 1} {
			append nuval "."								;#	nuval =		3		OR	3.		OR	4.
			set n 1
			while {$n < $len} {
				append nuval [string index $val $n]			;#	nuval = 	3		OR	3.65	OR	4.27
				incr n
			}
		}
		if {$nuval == 1} {									;#	0.01 --> 1e-2 --> 10e-3
			set nuval 10
			incr cnt
		}
		append nuval "e-" $cnt								;#	nuval = 	3e-5	OR	3.65e-5	OR	4.27e-5
	}
	return $nuval
}

#---- separate "val=7" into "val = 7"

proc SeparateEquals {lines} {
	set len [llength $lines]
	set linecnt 0
	while {$linecnt < $len} {
		set line [lindex $lines $linecnt]
		set expanded 0
		set nuline {}
		foreach item $line {
			set k [string first "=" $item]
			if {$k >= 0} {
				set expanded 1
				set xitems [split $item "="]
				set xitems [linsert $xitems 1 "="]
				set nuline [concat $nuline $xitems]
			} else {
				lappend nuline $item
			}
		}
		if {$expanded} {
			set lines [lreplace $lines $linecnt $linecnt $nuline]
		}
		incr linecnt
	}
	return $lines
}

proc StripZerosAtEnd {val} {
	set indx [string length $val]							;#	get string length
	incr indx -1											;# 	point to last item
	while {[string match "0" [string index $val $indx]]} {	;#	and cut off any trailing zeros
		incr indx -1										;#	recursively
		set val [string range $val 0 $indx]
	}
	return $val
}

#--- Swap between ness-extension and text-extension during file editing, where file type might be changed

proc NessExt {fnam add} {
	global evv
	set fnam [file rootname $fnam]
	if {$add} {
		append fnam $evv(NESS_EXT)
	} else {
		append fnam $evv(TEXT_EXT)
	}
	return $fnam
}

#--- Check text window for nessfile structure

proc HasNessfileStructure {t intyp} {
	global nessinit
	
	if {![info exists nessinit]} {
		return 0
	}

	foreach nessline [$t get 1.0 end] {
		lappend nesslines $nessline
	}
	switch  -- $intyp {
		"i" {
			set typ [ValidNessInstr $nesslines 1 0]
		}
		"s" {
			set typ [ValidNessScore $nesslines 1 0]
		}
		0 {
			set typ [ValidNessInstr $nesslines 0 0]
			if {$typ == "0"} {
				set typ [ValidNessScore $nesslines 0 0]
			}
		}
	}
	if {$typ == "0"} {
		return 0
	}
	return 1
}

#--- Remove any listed scorefiles whose instrument has been deleted
#--- As well as removing the specified item

proc PurgeNessData {infnam} {
	global nesstype nessins nesinterp
	set delitems $infnam							;#	Remove ref to the ness item
	if {$nesstype($infnam) == "i"} {				;#	IF it's an instrument
		RemoveNessInterp $infnam
		foreach nam [array names nesstype] {		;#	Remove refs to all scores which use the deleted instrument
			if {$nesstype($nam) == "s"} {			;#	(as they are no longer valid scores)
				if {[info exists nessins($nam)] && ($nessins($nam) == $infnam)} {
					lappend delitems $nam
				}
			}
		}
	} else {										;#	If it's a score
		lappend delitems nessins($infnam)			;#	Remove ref to the instrument used by this score
	}
	foreach fnam $delitems {
		catch {unset nesstype($fnam)}
	}
	if {[llength [array names nesstype]] <= 0} {
		unset nesstype
		catch {unset nesinterp}
	}
}

proc RemoveNessInterp {fnam} {
	global nesinterp nes
	if {![info exists nesinterp]} {
		return
	}
	set nam [file rootname [file tail $fnam]]
	if {[info exists nesinterp($nam)]} {
		unset nesinterp($nam)
		if {[llength [array names nesinterp]] <= 0} {
			unset nesinterp
		}
	}
	set nes(istore) 1
}

#-------- If an instrument name is changed, update any scores using that instrument

proc UpdateNessScores {nufnam updatescores} {
	global nessins
	foreach fnam $updatescores {
		catch {unset lines}
		catch {unset nulines}
		catch {unset moreglobal}
		catch {unset keptcomment}
		if [catch {open $fnam "r"} zit] {
			lappend badmsgs "COULD NOT OPEN PHYSICAL MODELLING SCORE $fnam TO READ DATA FOR UPDATING"
			continue
		} else {
			while {[gets $zit line] >= 0} {
				lappend lines $line
			}
			close $zit
		}
		set OK 1
		foreach line $lines {
			set line [string trim $line]
			if {([string first "global" $line] == 0) || [info exists moreglobal]} {		;#	Keep global declarations
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					lappend nuline $item
				}
				if {[string match [lindex $item end] "..."]} {
					set moreglobal 1
				} else {
					catch {unset moreglobal}
				}
				lappend nulines $line
				continue
			}
			set k [string first "instrumentfile" $line]		;#	Keep all lines  with no  "instrumentfile" word in
			if {$k < 0} {
				lappend nulines $line
				continue
			}
			set j [string first "%" $line]					;#	If "instrumentfile" in a comment, ignore, keep line
			if {$j >= 0} {
				if {$j < $k} {
					lappend nulines $line
					continue
				} else {
					set keptcomment [string range $line $j end]
				}
			}
			set j [string first "'" $line]
			if {$j < 0} {
				lappend badmsgs "BAD SYNTAX FOR INSTRUMENT FILENAME IN PHYSICAL MODELLING SCORE $fnam"
				set OK 0
				break
			}
			set nuline [string range $line 0 $j]
			append nuline [file rootname $nufnam]
			append nuline "';"
			if {[info exists keptcomment]} {
				append nuline $keptcomment
			}
			lappend nulines $nuline
		}
		if {!$OK} {
			continue
		}
		if [catch {open $fnam "w"} zit] {
			lappend badmsgs "COULD NOT OPEN PHYSICAL MODELLING SCORE $fnam TO WRITE UPDATED DATA"
			continue
		}
		foreach line $nulines {
			puts $zit $line
		}
		close $zit
		set nessins($fnam) $nufnam
	}
	if {[info exists badmsgs]} {
		set msg ""
		set cnt 0
		foreach item $badmsgs {
			append msg $item\n
			incr cnt
			if {$cnt >= 20} {
				append msg "and more\n"
				break
			}
		}
		Inf $msg
	}
}

#----- Display Ness Data Files

proc ShowNessData {isscores} {
	global nesstype nessins pr_nessdata evv
	if {![info exists nesstype]} {
		Inf "No physical modelling data on your system"
		return
	}
	foreach nam [array names nesstype] {
		lappend names $nam
	}
	set names [lsort -dictionary $names]
	foreach nam $names {
		if {$nesstype($nam) == "s"} {
			lappend scores $nam
			if {[info exists nessins]} {
				lappend scorins $nessins($nam)
			} else {
				lappend scorins "-"
			}
		} else {
			lappend instrs $nam
		}
	}
	set data {}
	if {$isscores}  {
		if {![info exists scores]} {
			Inf "No physical modelling scores on your system"
			return
		}
		foreach score $scores scorins $scorins {
			set thisdata [list $score    USING     $scorins]
			lappend data $thisdata
		}
	} else {
		if {![info exists scores]} {
			Inf "No physical modelling instruments on your system"
			return
		}
		foreach instr $instrs {
			lappend data $instr
		}
	}
	if {$isscores} {
		set msg "Physical modelling scores"
	} else  {
		set msg "Physical modelling instruments"
	}
	set f .nessdata
	if [Dlg_Create $f "PHYSICAL MODELLING DATA" "set pr_nessdata 0" -borderwidth $evv(BBDR)] {
		set b  [frame $f.b]
		set ll  [frame $f.ll]
		button $b.ok -text "OK"   -width 5 -command "set pr_nessdata 1"  -highlightbackground [option get . background {}]
		button $b.q  -text "Quit" -width 5 -command "set pr_nessdata 0" -highlightbackground [option get . background {}]
		pack $b.ok -side left
		pack $b.q -side right
		pack $b -side top -fill x -expand true
		Scrolled_Listbox $ll.ll -width 64 -height 24 -selectmode single
		pack $ll.ll -side top -fill both -expand true
		pack $ll -side top -pady 4
		wm resizable $f 0 0
		bind $f <Return> {set pr_nessdata 1}
		bind $f <Escape> {set pr_nessdata 0}
	}
	.nessdata.ll.ll.list delete 0 end
	foreach item $data {
		.nessdata.ll.ll.list insert end $item
	}
	wm title $f $msg
	set pr_nessdata 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_nessdata $f
	tkwait variable pr_nessdata
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}	

#-----  On Renaming any file.  NB Must have file EXTENSION!!!! ... updates the ness management data

proc NessMRename {oldfnam nufnam dostore} {
	global nesstype nessins nessorig nesinterp nessprof nes
	set iiofnam [file rootname [file tail $oldfnam]]
	set iinfnam [file rootname [file tail $nufnam]]
	if [info exists nesstype($oldfnam)] {
		set nutyp [IsAValidNessFile $nufnam 1 0 0]
		if {[info exists nessorig]} {
			set oldtyp $nessorig
		} else {
			set oldtyp $nutyp
		}
		if {$nutyp == "s"} {
			if {$oldtyp == "i"} {							;#	Instrument destroyed
				if {[info exists nesinterp($iiofnam)]} {
					unset nesinterp($iiofnam)
					if {[llength [array names nesinterp]] <= 0} {
						unset nesinterp
					}
					set nes(istore) 1
				}
				if {[info exists nessprof($iiofnam)]} {
					unset nessprof($iiofnam)
					if {[llength [array names nessprof]] <= 0} {
						unset nessprof
					}
					set nes(pstore) 1
				}
				if {[info exists nessins]} {
					foreach nam [array names nessins] {		;#	Find all scores-refering to the overwritten instrument
						if {$nessins($nam) == $nufnam} {	;#	and mark scores (and score-refsto-instrs) for deletion
							lappend delscores $nam
						}
					}
				}
				if {[info exists delscores]} {
					foreach nam $delscores {
						catch {unset nesstype($nam)}		;#	If score used the overwritten instrument
						catch {unset nessins($nam)}			;#	Remove ref to both score and score-refsto-instrs
					}
				}

			} else { ;# $oldtyp == "s"
				if {[info exists nessins($oldfnam)]} {		;#	If a score overwrites a score
					set nessins($nufnam) $nessins($oldfnam)	;#	rename ref to instrument used by renamed score
					unset nessins($oldfnam)					;#	(possibly overwriting existing same-named ref of overwritten score)
				}
			}

		} else { ;# nutyp == "i"

			if {$oldtyp == "i"} {							;#	if an instrument is renamed (or overwrites an instrument)
				foreach nam [array names nesstype] {		;#	Find all scores
					if {$nesstype($nam) == "s"} {
						if {[info exists nessins($nam)]} {
							if {$nessins($nam) == $oldfnam} {		;#	If score used the now-renamed instrument
								lappend updatescores $nam			;#	mark them to update the score FILES themselves
							} elseif {$nessins($nam) == $nufnam} {
								lappend delscores $nam				;#	If score used the overwritten instrument
							}										;#	Mark then to remove ref to both score and instrument
						}
					}
				}
				if {[info exists updatescores]} {
					UpdateNessScores $nufnam $updatescores
				}
				if {[info exists delscores]} {
					foreach nam $delscores {
						catch {unset nesstype($nam)}		;#	If score used the overwritten instrument
						catch {unset nessins($nam)}			;#	Remove ref to both score and instrument
					}
				}
				if {[info exists nesinterp($iiofnam)]} {
					if {$iiofnam != $iinfnam} {
						unset nesinterp($iiofnam)
						set nesinterp($iinfnam) 1
						set nes(istore) 1
					}
				}
				if {[info exists nessprof($iiofnam)]} {
					if {$iinfnam != $iiofnam} {
						set nessprof($iinfnam) $nessprof($iiofnam)
						unset nessprof($iiofnam)
						set nes(pstore) 1
					}
				}
			} else { ;# $oldtyp == "s"
				foreach nam [array names nesstype] {		;#	Find all scores
					if {$nesstype($nam) == "s"} {
						if {[info exists nessins($nam)]} {
							if {$nessins($nam) == $oldfnam} {		;#	If score used the now-renamed instrument
								lappend updatescores $nam			;#	mark them to update the score FILES themselves
							}
						}
					}
				}
				if {[info exists updatescores]} {
					UpdateNessScores $nufnam $updatescores
				}
				if {[info exists nessins($oldfnam)]} {		;#	If an instrument overwrites a score
					catch {unset nessins($oldfnam)}			;#	Remove score-refsto-instrs	
				}
			}
		}
		set nesstype($nufnam) $nesstype($oldfnam)			;#	rename the score or ins
		unset nesstype($oldfnam)
		if {[llength [array names nesstype]] <= 0} {
			unset nesstype
		}
		if {[llength [array names nessins]] <= 0} {
			unset nessins
		}
		if {$dostore} {
			NessMStore
		}
		return 1
	}
	return 0
}

;#-- Refresh all ".m" data on workspace, and elsewhere

proc RefreshNessData {} {
	global wl nesstype nessins nessprof
	set done {}

	if {[info exists nessprof(cdptest)]} {
		unset nessprof(cdptest)
		set dostore 1
	}
	foreach fnam [$wl get 0 end] {
		set typ [IsAValidNessFile $fnam 1 0 0]
		if {[info exists nesstype($fnam)]} {
			switch -- $typ {
				0 -
				"s" {
					if {$nesstype($fnam) == "i"} {
						lappend buminstrs $fnam		;#	Scores with this instrument must be deleted
					}
				}
				"i" {
					if {$nesstype($fnam) == "s"} {	;#	instrument reference from ex-score deleted
						catch {unset nessins($fnam)}
					}
				}
			}
			if {$typ == 0} {
				unset nesstype($fnam)
				catch {unset nessins($fnam)}
			}
		}
		if {$typ != 0} {
			set nesstype($fnam) $typ
			lappend done $fnam
		}
	}
	foreach fnam [array names nesstype] {
		if {[lsearch $done $fnam] < 0} {
			set typ [IsAValidNessFile $fnam 1 0 0]
			if {$typ == 0} {
				unset nesstype($fnam)
				catch {unset nessins($fnam)}
			} else {
				switch -- $typ {
					0 -
					"s" {
						if {$nesstype($fnam) == "i"} {
							lappend buminstrs $fnam		;#	Scores with this instrument must be deleted
						}
					}
					"i" {
						if {$nesstype($fnam) == "s"} {	;#	instrument reference from ex-score deleted
							catch {unset nessins($fnam)}
						}
					}
				}
				if {$typ == 0} {
					unset nesstype($fnam)
					catch {unset nessins($fnam)}
				}
			}
		}
	}
	if {[info exists buminstrs]} {						;#	For all deleted or overwritten (with scores) instrs
		foreach nam [array names nesstype] {			;#	Find all scores
			if {$nesstype($nam) == "s"} {
				if {[info exists nessins($nam)]} {		
					foreach bumfnam $buminstrs {		;#	If score uses a bum instrument
						if {$nessins($nam) == $bumfnam} {
							lappend delscores $nam		;#	Mark then to remove ref to both score and scor-ref-to-instr
							break
						}										
					}
				}
			}
		}
		set doistore 0
		foreach zz $buminstr {
			set nam [file rootname [file tail $zz]]
			if {[info exists nesinterp($nam)]} {
				unset nesinterp($nam)
				set doistore 1
			}
		}
		if {[llength [array names nesinterp]] <= 0} {
			unset nesinterp
		}
		if {$doistore} {
			NessInterpStore
		}
	}
	if {[info exists delscores]} {
		foreach nam $delscores {
			catch {unset nesstype($nam)}		;#	If score used the overwritten instrument
			catch {unset nessins($nam)}			;#	Remove ref to both score and instrument
		}
	}
	if {[info exists nessprof]} {
		foreach nam [array names nessprof] {
			lappend profnames $nam
		}
		foreach nam [array names nesstype] {
			if {$nesstype($nam) == "i"} {
				lappend insnames [file rootname [file tail $nam]]
			}
		}
		foreach nam $profnames {
			if {[lsearch $insnames $nam] < 0} {
				set dostore 1
				unset nessprof($nam)
			}
		}
		if {[llength [array names nesstype]] <= 0} {
			unset nesstype
			catch {unset nesinterp}
		}
		if {[llength [array names nessins]] <= 0} {
			unset nessins
		}
		if {[info exists dostore]} {
			NessProfileStore
		}
	}
}

##################################
# ENTERING BRASS INSTRUMENT DATA #
##################################

proc NessProfile {input fnam} {
	global wl chlist pa evv wstk nessprof pr_brass nessparamset nessparam brassfnam nessrange nes
	global nes_first orig_nes_pts nesorig nesinterp nes_fnam nessco ness_longparamname

	set nes(not_valvedisplay) 1
	catch {unset nessprof(cdptest)}		;#	Clear any existing pnts from a previous run
	catch {unset nesinterp(cdptest)}
	catch {unset orig_nes_pts}
	catch {unset nesorig}
	set nes_first 1						;#	Flag that we are at the first of any calls to NessCreate
	set nes(bellslopebak) ""
						
	if {$input} {
		if {$fnam == 0} {				;#	Input from wkspace

			if {![info exists chlist] || ([llength $chlist] !=1)} {
				set ilist [$wl curselection]
				if {![info exists ilist] || ([llength $ilist] != 1) || ($ilist == -1)} {
					Inf "No physical modelling instrument file selected"
					return
				} else {
					set fnam [$wl get $ilist]
				}
			} else {
				set fnam [lindex $chlist 0]
			}
		}
		set typ [IsAValidNessFile $fnam 1 0 0]
		if {$typ != "i"} {
			Inf "Select a physical modelling instrument file"
			return
		}
		set basfnam [file rootname [file tail $fnam]]
		if {![info exists nessprof($basfnam)]} {
			if {![info exists nessparam(bore)]} {
				Inf "Problem reading instrument \"bore\" data"
				return
			}
			foreach {x y} $nessparam(bore) {		;#	convert to distance/radius pairs
				set rad [DecPlaces [expr $y/2.0] 1]
				lappend nessprof($basfnam) $x $rad
			}
		}
		set maxrad 0
		foreach {dist rad} $nessprof($basfnam) {
			if {$rad > $maxrad} {
				set maxrad $rad
			}
			set maxdist $dist
		}
	} else {
		set fnam cdptest.m 
		foreach paramname $nessparamset(ins) {
			if {$paramname == "custominstrument"} {
				set brass(custominstrument) 0
			} elseif {$paramname != "bore"} {
				set brass($paramname) ""
			}
		}
		set basfnam "cdptest"
	}
	set nes_fnam $fnam

	set f .brass

	if [Dlg_Create $f "BRASS INSTRUMENT" "set pr_brass 0" -borderwidth $evv(BBDR)] {
		set b  [frame $f.b]
		set ll [frame $f.ll]
		button $b.ok -text "Save"   -width 8 -command "set pr_brass 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.hh -text "Help" -width 5 -command "BrassHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $b.dd -text "Defaults" -width 8 -command "BrassInstrDefaults" -highlightbackground [option get . background {}]
		button $b.q  -text "Abandon" -width 8 -command "set pr_brass 0" -highlightbackground [option get . background {}]
		pack $b.ok $b.hh $b.dd -side left -padx 2
		pack $b.q -side right
		pack $b -side top -fill x -expand true
		set n 0
		foreach paramname $nessparamset(ins) {
			if {$paramname == "temperature"} {
				set nnam "Temperature(deg C)"			
			} elseif {$paramname == "vpos"} {
				set nnam "Valve position(s)"			
			} elseif {$paramname == "vdl"} {
				set nnam "Bypass tube min(s)"
			} elseif {$paramname == "vbl"} {
				set nnam "Bypass tube len(s)"
			} elseif {$paramname == "bore"} {
				set nnam "Bore Profile"
			} else  {
				set nnam $paramname			
			}
			frame $f.$paramname
			if {$paramname == "custominstrument"} {
				label $f.$paramname.ll -text $nnam -width 18 -anchor e
				checkbutton $f.$paramname.e -text "" -variable nessparam($paramname)
				pack $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "bore"} {
				label $f.$paramname.ll -text $nnam -width 18 -anchor e
				button $f.$paramname.e -text "Edit Bore Profile" -command "NessDisplay 1 1 $paramname $fnam 0 0" -borderwidth 4 -width 20 -highlightbackground [option get . background {}]
				button $f.$paramname.e2 -text "Display To Scale" -command "NessDisplay 1 1 $paramname $fnam 1 0" -borderwidth 4 -width 20 -highlightbackground [option get . background {}]
				button $f.$paramname.e3 -text "ReScale Profile"  -command "NessDisplay 1 1 $paramname $fnam 0 1" -borderwidth 4 -width 20 -highlightbackground [option get . background {}]
				pack $f.$paramname.ll $f.$paramname.e $f.$paramname.e2 $f.$paramname.e3 -side left -padx 2
			} else {
				label $f.$paramname.ll -text $nnam -width 18 -anchor e 
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				pack $f.$paramname.ll $f.$paramname.e -side left -padx 2
			}
			if {($paramname == "vpos") || ($paramname == "vdl") || ($paramname == "vbl")} {
				if {$paramname == "vpos"} {
					button $f.$paramname.b -text "Draw" -command "NessDisplay 2 1 $paramname $fnam 0 0" -borderwidth 4 -width 7 -highlightbackground [option get . background {}]
					pack $f.$paramname.b -side left -padx 2
				}
			}
			pack $f.$paramname -side top -pady 2 -fill x -expand true
		}
		frame $f.o
		label $f.o.ll -text "Output Filename"
		entry $f.o.e -textvariable brassfnam
		pack $f.o.ll $f.o.e -side left -padx 2
		pack $f.o -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_brass 1}
		bind $f <Escape> {set pr_brass 0}
	}
	set nessparam(custominstrument) 0
	if {$input} {
		$f.bore.e config -text "Edit Bore Profile (^B)" -command "NessDisplay 1 1 bore $fnam 0 0" -bd 4
		$f.bore.e2 config -text "Display To Scale" -command "NessDisplay 1 1 bore $fnam 1 0" -borderwidth 4
		$f.bore.e3 config -text "ReScale Profile (^R)"  -command "NessDisplay 1 1 bore $fnam 0 1" -borderwidth 4
		$f.b.dd config -text "" -bd 0 -state disabled -bg [option get  . background {}]
	} else {
		$f.bore.e config -text "Create Bore Profile (^B)" -command "NessDisplay 1 0 bore $fnam 0 0" -bd 4
		$f.bore.e2 config -text ""  -command {} -bd 0
		$f.bore.e3 config -text ""  -command {} -bd 0
		$f.b.dd config -text "Defaults" -bd 2 -state normal
		foreach nam $nessparamset(ins) {
			if {$nam == "custominstrument"} {
				set nessparam($nam) 0
			} else {
				set nessparam($nam) ""
			}
		}
	}
	set pr_brass 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_brass $f
	set finished 0
	while {!$finished} {
		tkwait variable pr_brass
		if {$pr_brass} {
			catch {unset checkcnt}
			set OK 1
			foreach paramname $nessparamset(ins) {
				if {$paramname == "bore"} {
					if {![info exists nessprof($basfnam)]} {
						Inf "No (valid) bore profile exists yet"
						set OK 0	
						break
					}
				} else {
					if {$paramname == "custominstrument"} {
						if {$nessparam($paramname) == 1} {
							Inf "Custominstrument option not yet available"
							set OK 0	
							break
						}
						continue
					} 
					set val $nessparam($paramname)
					set val [string trim $val]
					if {[string length $val] <= 0} {
						Inf "No parameter value entered for $paramname"
						set OK 0	
						break
					}
					switch -- $paramname {
						"temperature " {
							if {![IsNumeric $val] || ($val < [lindex $nessrange($paramname) 0]) || ($val > [lindex $nessrange($paramname) 1])} {
								Inf "[string toupper $paramname] invalid (range [lindex $nessrange($paramname) 0] to [lindex $nessrange($paramname) 1])"
								set OK 0	
								break
							}
						}
						vpos -
						vdl -
						vbl {
							catch {unset nuvals}
							set val [split $val]
							set thiscnt 0
							foreach item $val {
								set item [string trim $item]
								if {[string length $item] <= 0} {
									continue
								}
								if {![IsNumeric $item] || ($item < [lindex $nessrange($paramname) 0]) || ($item > [lindex $nessrange($paramname) 1])} {
									Inf "[string toupper $paramname] invalid (range [lindex $nessrange($paramname) 0] to [lindex $nessrange($paramname) 1])"
									set OK 0	
									break
								}
								incr thiscnt
								lappend nuvals $val
							}
							if {[info exists checkcnt]} {
								if {$checkcnt != $thiscnt} {
									Inf "Number of entries for $ness_longparamname($paramname) does not tally with other multiple entries"
									set OK 0	
									break
								}
							} else {
								if {$thiscnt < 1} {
									Inf "No entries for [string toupper $paramname]"
									set OK 0	
									break
								}
								set checkcnt $thiscnt
							}
							set $nessparam($paramname) $nuvals
						}
					}
					if {!$OK} {
						break
					}
				}
			}
			if {!$OK} {
				continue
			}
			if {![ValidCDPRootname $brassfnam]} {
				continue
			}
			set outfnam [string tolower $brassfnam]
			append outfnam $evv(NESS_EXT)
			if {[file exists $outfnam]} {
				Inf "File $outfnam already exists, please chose a different name"
				continue
			}
			set lines [ConvertBrassDataToFileFormat [file rootname $outfnam]]
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot open file $outfnam to write the new instrument file"
				continue
			}
			foreach line $lines {
				puts $zit $line
			}
			close $zit
			set nessco(insfnam) $outfnam
			FileToWkspace $outfnam 0 0 0 0 1
			Inf "File $outfnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	catch {unset nessprof(cdptest)}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc BrassHelp {} {
	set msg "CREATING A BRASS INSTRUMENT\n"
	append msg "\n"
	append msg "YOU CAN CREATE A BORE PROFILE GRAPHICALLY\n"
	append msg "\n"
	append msg "Apart from the endpoints, 3 other points are needed, indicating...\n"
	append msg "(1) The end of the mouthpiece.\n"
	append msg "(2) The end of the throat.\n"
	append msg "(3) The start of the Bell.\n"
	append msg "\n"
	append msg "See further instructions on the graphics page which appears.\n"
	append msg "\n"
	append msg "YOU CAN ENTER VALVE POSITIONS GRAPHICALLY (ONCE A PROFILE EXISTS)\n"
	append msg "\n"
	append msg "\"Valve position(s)\" gives the Position of the valves along the bore\n"
	append msg "        in millimetres, measured from the mouthpiece.\n"
	append msg "        Once a bore profile exists, you can enter these graphically\n"
	append msg "        from the \"Draw\" button.\n"
	append msg "\n"
	append msg "\"Bypass tune min(s)\" is the minimum bypass tube length within valves, in mm.\n"
	append msg "\n"
	append msg "\"Bypass tune len(s)\" is the bypass tube length within the valves, in mm.\n"
	append msg "        (NB \"Bypass tune min\" is ADDED to both ends of valve tubing).\n"
	append msg "\n"
	append msg "MULTIPLE VALUES FOR VALVES\n"
	append msg "\n"
	append msg "You can enter a list of several valve positions.\n"
	append msg "(1)  Theses values should be separated by spaces.\n"
	append msg "(2)  \"Valve position\", \"Bypass tune min\" \"Bypass tune len\"\n"
	append msg "               must have the SAME number of values.\n"
	append msg "\n"
	append msg "INTERPOLATING VALUES\n"
	append msg "\n"
	append msg "The \"Interpolate\" option produces curviliear profiles for\n"
	append msg "\n"
	append msg "(1)  The MOUTHPIECE (a cosinusoidal curve).\n"
	append msg "         Interpolation is between the start and the 1st minimum\n"
	append msg "         in the profile (any intervening points will be overwritten).\n"
	append msg "\n"
	append msg "(2)  The BELL, (a slope governed by a user-defined power factor).\n"
	append msg "         Interpolation is over the area marked by you using the Zoom Box.\n"
	append msg "\n"
	append msg "(3)  INTERNAL CAVITIES (cubic-spline interpolation).\n"
	append msg "         applied to any part of the profile,\n"
	append msg "         after the mouthpiece and before the bell, where the bore narrows.\n"
	append msg "\n"
	append msg "The \"UNDO\" option returns to the profile before any interpolation\n"
	append msg "(intervening profile modifications will be lost).\n"
	append msg "\n"
	Inf $msg
}

proc NessGrafixHelp {typ} {
	set msg "CREATING A BRASS INSTRUMENT\n"
	append msg "\n"
	switch -- $typ {
		"valves" {
			append msg "YOU CAN ENTER VALVE POSITIONS GRAPHICALLY\n"
			append msg "\n"
			append msg "Just click on the interface to mark the valve positions.\n"
			append msg "You can, of course, enter several valve positions.\n"
			append msg "\n"
			append msg "\"Click\" Creates a valve-position marker.\n"
			append msg "\"Control-Click\" deletes the (nearest) valve-position marker.\n"
			append msg "\"Shift-Click and Drag\", creates a Zoom Box, for magnification with \"ZOOM IN\".\n"
			append msg "\"Command-Control-Click\" Moves the Zoom Box Left or Right.\n"
			append msg "\"Control-1\" Sets a Mark at the Zoom Box Start.\n"
			append msg "\"Control-2\" Moves the Zoom Box Start to the Mark (if the Mark is not outside the box to the right).\n"
			append msg "\"Control-3\" Move the Zoom Box End to the Mark (if the Mark is not outside the box to the left).\n"
			append msg "The Zoom Box can be removed with \"Remove Box\" (and restored with \"Restore Box\").\n"
			append msg "\n"
			append msg "You can see the values of the positions entered, with \"SHOW VALUES\".\n"
			append msg "\n"
		} 
		"valveopening" {
			append msg "ENTER VALVE OPENING VALUES\n"
			append msg "\n"
			append msg "Valve-opening values for EVERY valve are set at a fixed series of times (to be entered later).\n"
			append msg "Begin by marking the valve-opening values at these times for Valve 1.\n"
			append msg "\n"
			append msg "When you output the data (and if your instrument has more than 1 valve)\n"
			append msg "a new graphic display will appear to allow you to enter the SAME NUMBER OF VALUES FOR valve 2,\n"
			append msg "and so on, until all valve values have been entered.\n"
			append msg "\n"
			append msg "You can then enter the timing-sequence of these valve-changes from the \"Time\" button.\n"
			append msg "\n"
			append msg "To enter values, just click on the interface to mark the valve-opening heights.\n"
			append msg "(The left-to-right order of these is important, but NOT there exact left-right positions).\n"
			append msg "\n"
			append msg "\"Click\" Creates a valve-heigth marker.\n"
			append msg "\"Control-Click\" deletes the (nearest) valve-height marker.\n"
			append msg "\"Command-Click and Drag\", drags the nearest existing point.\n"
			append msg "\n"
		} 
		default {
			if {$typ == "bore"} {
				append msg "YOU CAN CREATE A BORE PROFILE GRAPHICALLY\n"
				append msg "\n"
				append msg "Apart from the endpoints, AT LEAST 3 other points are needed, indicating...\n"
				append msg "\n"
				append msg "(1) The end of the mouthpiece.\n"
				append msg "(2) The end of the throat.\n"
				append msg "(3) The start of the Bell.\n"
			} else {
				append msg "YOU CAN CREATE A PROFILE GRAPHICALLY\n"
			}
			append msg "\n"
			append msg "\"Click\" Creates a new point on the profile.\n"
			append msg "\"Control-Click\" deletes the (nearest) profile point.\n"
			append msg "\"Command-Click and Drag\" moves the (nearest) point.\n"
			append msg "       Normally this is in the Up-Down direction.\n"
			if {$typ == "bore"} {
				append msg "       To move points in the Left-Right direction, select \"Drag Position\".\n"
				append msg "       To return to Up-Down motion, select \"Drag Radius\".\n"
			} else {
				append msg "       To move points in the Left-Right direction, select \"Drag Time\".\n"
				append msg "       To return to Up-Down motion, select \"Drag Value\".\n"
			}
			append msg "\"Shift-Click and Drag\", creates a Zoom Box, for magnification with \"ZOOM IN\".\n"
			append msg "\n"
			append msg "You can see the values of the profile points entered, with \"SHOW VALUES\".\n"
			append msg "You can DISPLAY a SCALE to assist in chosing values, with \"SEE VAL SCALE\".\n"
			append msg "\n"
			if {$typ == "bore"} {
				append msg "INTERPOLATING VALUES\n"
				append msg "\n"
				append msg "The \"Interpolate\" option produces curvilinear profiles for\n"
				append msg "\n"
				append msg "(1)  The MOUTHPIECE (a cosinusoidal curve).\n"
				append msg "         Interpolation is between the start and the 1st minimum\n"
				append msg "         in the profile (any intervening points will be overwritten).\n"
				append msg "\n"
				append msg "(2)  The BELL, (a slope governed by a user-defined power factor).\n"
				append msg "         Interpolation is over the area marked by you using the Zoom Box\n"      
				append msg "         (Bell assumed to start at the leftmost point inside the Box.\n"
				append msg "         Any points to the right of this will be overwritten.\n"
				append msg "         Marking the bell will not work if you are Zoomed in.\n"
				append msg "         Marking the bell is undone if you then add, delete or move points).\n"
				append msg "         Change the power factor with the \"Up\" and \"Down\" Arrow Keys\n"
				append msg "         using the Shift Key to move faster.\n"
				append msg "\n"
				append msg "(3)  INTERNAL CAVITIES (cubic-spline interpolation).\n"
				append msg "         applied to any part of the profile where the bore narrows, \n"
				append msg "         after the mouthpiece and before the bell.\n"
				append msg "         You must mark the bell - highlight with Zoom Box, and Press \"Mark Bell\".\n"
				append msg "\n"
				append msg "You must mark the position of the bell (use the Zoom Box and click \"Mark Bell\").\n"
				append msg "(You can change your mind ... just mark the bell position again).\n"
				append msg "(Marking the bell will not work if you are Zoomed in).\n"
				append msg "(Marking the bell is undone if you then add, delete or move points).\n"
				append msg "\n"
				append msg "The \"UNDO\" option returns to the profile before any interpolation.\n"
				append msg "(Any intervening profile modifications will be lost)\n"
				append msg "NB \"UNDO\" will no longer be available if you QUIT the graphics window.\n"
				append msg "\n"
				append msg "Interpolation (unless undone) can only be applied once.\n"
				append msg "\n"
			}
		}
	}
	Inf $msg
}

#######################################################
# GRAPHIC ENTRY OF BORE PROFILE, OR TIME-VARYING DATA #
#######################################################

#---- Display param brkpoints, bore profiles, and insert valves on profile

proc NessDisplay {typ edit paramname fnam toscale rescale} {
	global nesnak_list evv nes_pts neswking nes_starty nessparam nessprof wstk nes nessco
	global nesorig nes_first orig_nes_pts ness_longparamname wstk nessparamset

	set lo [GetNessRangeBot $paramname]
	set hi [GetNessRangeTop $paramname]
	set basfnam [file rootname [file tail $fnam]]
	catch {.nessco.t.e config -bg [option get . background {}]}

	catch {unset nes_starty}
	switch -- $typ {
		0 {
			set brktype $evv(SN_BRKPNTPAIRS)	;#	Breakpoint time-val pairs, with float vals
		}
		1 {
			set brktype $evv(SN_BRKPNTPAIRS)	;#	Breakpoint distance-radius pairs, with ALMOST int vals
		}
		2 {
			set brktype $evv(SN_TIMESLIST)		;#	Distances list, for valves
		}
	}
	if {($paramname == "bore") || ($paramname == "vpos")} {
		set maxdur $nes(BORELEN_MAX)
		set mindur $nes(BORELEN_MIN)
	} else {
		set maxdur $nes(maxscoredur)		;#	Hour max !!!
		set mindur $nes(minscoredur)
	}

	if {[lsearch $nessparamset(ins) $paramname] >= 0} {	;#	Instrument param
		if {![info exists nesorig]} {

			;#	IF FIRST CALL TO INERFACE, ESTABLISH THE INITIAL LIST OF POINTS AND THE INITIAL RANGE

			if {$edit > 0} {
				if {![info exists nessprof($basfnam)]} {
					Inf "Specify the bore profile before positiong the valves"
					return 0
				}
				if {($paramname == "bore") || ($paramname == "vpos")} {
					set orig_nes_pts $nessprof($basfnam)	;#	Read RADIUS, not diameter
				} else {
					set orig_nes_pts $nessparam($paramname)
				}
				set maxy [lindex $orig_nes_pts 1]
				foreach {x y} [lrange $orig_nes_pts 2 end] {
					if {$y > $maxy} {
						set  maxy $y
					}
				}
				set dur $x
			} else {
				if {$brktype == $evv(SN_TIMESLIST)} {		;#	Cannot enter valve-positions if no bore profile
					Inf "You must first create (or read) a bore profile"
					return 0
				}
				set orig_nes_pts {}
				set maxy $hi
				set dur $maxdur
			}
			set nesorig(lo) $lo
			set nesorig(hi) $maxy
			set nesorig(valsco) [expr $nesorig(hi) - $nesorig(lo)]
			set nesorig(dur) $dur

		}
	} else {	;#	Score Parameter

		if {![info exists nessparam(t)] || ![IsNumeric $nessparam(t)]} {
			Inf "No (valid) duration specified"
			.nessco.t.e config -bg $evv(EMPH)
			focus .nessco.t.e 
			return 0
		}
		if {($nessparam(t) < $nes(minscoredur)) || ($nessparam(t) > $nes(maxscoredur))} {
			Inf "Duration out of range ($nes(minscoredur) to  $nes(maxscoredur))"
			return 0
		}
		if {($nessparam(t) > $nes(hiscoredur))} {
			set msg "Output duration ($nessparam(t)) is very high : do you want to proceed ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return 0
			}
		}
		if {[IsScoreValveParameter $paramname]} {
			if {![info exists nes(valvecnt)]} {
				if {![file exists $nessparam(instrumentfile)]} {
					Inf "No valve count established"
					return 0
				} elseif {![GetValveCnt $nessparam(instrumentfile) 1]} {
					Inf "No valve count established"
					return 0
				}
			}
		}
		if {![info exists nesorig]} {

			;#	IF FIRST CALL TO INTERFACE, ESTABLISH THE INITIAL LIST OF POINTS AND THE INITIAL RANGE

			if {$paramname == "valveopening"} {	;#			This always has the same range and fixed (irrelevant) duration
				set orig_nes_pts {}
				set nesorig(lo) $lo
				set nesorig(hi) $hi
				set nesorig(valsco) [expr $nesorig(hi) - $nesorig(lo)]
				set nesorig(dur) $nessparam(t)

			} else {

				if {[IsScoreValveParameter $paramname]} {
					set gpsize [expr $nes(valvecnt) + 1]	;#	sizeof timed-groups of parameters
				} else {
					set gpsize 2							;#	ditto for brkpnt data
				}
				set p_len [llength $nessparam($paramname)]
				if {$edit > 0} {
					if {$p_len == 1} {						;#	Single value, turn it into a fixed-value brkpoint over whole duration
						set maxy $nessparam($paramname)
						set miny $nessparam($paramname)
						set orig_nes_pts [list 0 $nessparam($paramname) $nessparam(t) $nessparam($paramname)]
						set dur $nessparam(t)
					} else {								;#	Find existing max and min and duration
						set orig_nes_pts $nessparam($paramname)
						set x    [lindex $orig_nes_pts 0]
						set maxy [lindex $orig_nes_pts 1]
						set miny $maxy
						set cnt 2
						while {$cnt < $p_len} {
							if {($cnt % $gpsize) == 0} {	;#	Find end time
								set x [lindex $orig_nes_pts $cnt]
							} else {						;#	Find max and min value
								set y [lindex $orig_nes_pts $cnt]
								if {$y > $maxy} {
									set maxy $y
								}
								if {$y < $miny} {
									set miny $y
								}
							}
							incr cnt
						}					
						set dur $x
						if {$dur > $nessparam(t)} {
							Inf "Parameter endtime ($dur) exceeds given duration ($nessparam(t))"
							return 0
						} elseif {$dur < $nessparam(t)} {
							lappend orig_nes_pts $nessparam(t) $y
							set dur $nessparam(t)
						}
					}
				} else {
					set orig_nes_pts {}
					set maxy $hi
					set miny $lo
					set dur $nessparam(t)
				}
				set nesorig(lo) $miny
				set nesorig(hi) $maxy
				set nesorig(valsco) [expr $nesorig(hi) - $nesorig(lo)]
				set nesorig(dur) $dur
			}
		}
	}

	if {[IsAnotherValvingEntry $paramname]} {

		;#	IF A VALVING-PARAMETER, AND ALREADY DONE FIRST VALVE, DON'T RESET RANGE

	} else {

	;#	SET THE WORKING RANGE, INITIALLY, TO BE THE START RANGE (MAY BE MODIFIED BY SpecifyNessRange)

		set neswking(lo)  $nesorig(lo)
		set neswking(hi)  $nesorig(hi)
		set neswking(valsco) $nesorig(valsco)
		set neswking(dur) $nesorig(dur) 
	}

	;#	USE THE POINTS ARRAY THAT IS INPUT, OR RECYCLED AFTER A PREVIOUS SAVE

	set nes_pts $orig_nes_pts	;#	nes_pts is the set that we are working on, and may be modified

		;#	IF ENTERING VALVE POSITIONS, BORE PROFILE MUST ALREADY EXIST

	set is_score 0
	if {$toscale} {				;#	instruments only
		if {![info exists nessprof($basfnam)]} {
			Inf "Bore profile does not yet exist."
			return 0
		}
		;#	NO RANGE CHANGES PERMITTED

	} else {

		;#	OFFER AN OPTION TO ALTER THE RANGE: THIS MAY ALSO MODIFY THE SET OF WORKING pts
		;#	(Do this for all params except bore, and for bore if FIRST call, or rescaling flagged)
		
		if {[lsearch $nessparamset(sco2) $paramname] >= 0} {
			set is_score 1
		}
		if {$is_score} {
			if {$paramname == "valveopening"} {

				;#	IF VALVING-OPENING, RANGE ALWAYS FIXED (0-1)
	
				set neswking(lo) $nesorig(lo)
				set neswking(hi) $nesorig(hi)
				set neswking(valsco) $nesorig(valsco)

			} elseif {[IsAnotherValvingEntry $paramname]} {

				;#	IF ANY OTHER VALVING-PARAMETER, AND ALREADY DONE FIRST VALVE, DON'T RESET RANGE
	
			} else {
				set rr [SpecifyNessScoreRange $neswking(lo) $neswking(hi) $edit $paramname]
				if {[llength $rr] <= 1} {
					return 0
				}
				set neswking(lo) [lindex $rr 0]
				set neswking(hi) [lindex $rr 1]
				set neswking(valsco) [expr $neswking(hi) - $neswking(lo)]
			}
		} else {
			if {$paramname != "vpos"} {
				if {($paramname != "bore") || [info exists nes_first] || $rescale} {
					set rr [SpecifyNessRange $neswking(lo) $neswking(hi) $neswking(dur) $mindur $maxdur $typ $edit $paramname $fnam]
					if {[llength $rr] <= 1} {
						return 0
					}
					catch {unset nes_first}

					;#	MODIFY WORKING RANGE AND (POSSIBLY) SET OF nes_pts

					set neswking(lo) [lindex $rr 0]
					set neswking(hi) [lindex $rr 1]
					set neswking(valsco) [expr $neswking(hi) - $neswking(lo)]
					set neswking(dur) [lindex $rr 2]

					;#	NB "stretching" and "lengthen" get zero, if we're not doing an edit

					set stretching [lindex $rr 3]		;#	If table stretched or shrunk, do that to existing points
					catch {unset nu_xy}
					if {$stretching != 0.0} {
						foreach {x y} $nes_pts {
							set x [expr $x * $stretching]
							if {$typ == 1} {
								set x [DecPlaces $x 1]
							}
							lappend nu_xy $x $y
						}
						set len [llength $nu_xy]
						set endt [expr $len - 2]
						set nu_xy [lreplace $nu_xy $endt $endt $neswking(dur)]
						set nes_pts $nu_xy
					} else {								;#	Stretching and lengthening/curtailing are alternatives
						set lengthen [lindex $rr 4]
						if {$lengthen > 0.0} {				;#	(else) if table extended
							lappend nes_pts $neswking(dur) $lo	;#	add a new point at end of exsiting table
						} elseif {$lengthen < 0.0} {		;#	else if table curtailed, curtail existing table
							set xy [ReverseList $nes_pts]
							foreach {v t} $xy {				;#	NB reversing list reverses order ot time and val pairs
								if {$t > $neswking(dur)} {
									set nextt $t			;#	Remember first time-and-value beyond end of newly cut table
									set nextv $v
								} else {
									lappend nu_xy $v $t		;#	Retain all values within new time-range
								}
							}
							set nu_xy [ReverseList $nu_xy]	;#	Revert to increasing-time, and t-v order
							set len [llength $nu_xy]
							set endt [expr $len - 2]
							set endv [expr $len - 1]		;#	Interpolate a value at new endtime of table
							if {[lindex $nes_pts $endt] < $neswking(dur)} {
								set tdiff [expr $nextt - $endt]
								set vdiff [expr $nextv - $endv]
								set ratio [expr double($neswking(dur) - $endt)/double($tdiff)]
								set vdiff [expr $vdiff * $ratio]
								set endv [expr $endv + $vdiff]
								if {$typ == 1} {
									set endv [DecPlaces $endv 1]
								}
								lappend nu_xy $neswking(dur) $endv
							}
							if {($paramname == "bore") && ([llength $nu_xy] < 10)} {
								Inf "Too few points in curtailed profile (5 needed)"
								return 0
							} 
							set nes_pts $nu_xy
						}
					}
					set squeezing [lindex $rr 5]		;#	If table range (y-val) stretched or shrunk, do that to existing points
					catch {unset nu_xy}
					if {$squeezing != 0.0} {
						foreach {x y} [lrange $nes_pts 0 end] {
							set y [expr $y * $squeezing]
							if {$typ == 1} {
								set y [DecPlaces $y  1]
							}
							lappend nu_xy $x $y
						}
						set nes_pts $nu_xy

					} else {								;#	Stretching and clipping are alternatives
						set clipping [lindex $rr 6]
						if {$clipping < 0.0} {				;#	if table range is clipped, clip existing table
							catch {unset xy}
							catch {unset lastx}
							catch {unset lasty}
							foreach {x y} $nes_pts {
								if {$y <= $nes(valhi)} {
									if {[info exists lasty] && ($lasty > $nes(valhi))} {	;#	This is below, last was above cliplimt
										set dointerp 1

									} else {												;#	Both are at or below cliplimit
										lappend xy $x $y									;#	retain orig value
										set dointerp 0
									}
								} else {
									if {[info exists lasty] && ($lasty <= $nes(valhi))} {	;#	This is above, last was below cliplimit
										set dointerp 1
									} else {												;#	This and last are above cliplimit
										lappend xy $x $nes(valhi)							;#	Set at cliplimit
										set dointerp 0
									}
								}
								if {$dointerp} {
									set xdiff [expr $x - $lastx]
									set ydiff [expr $y - $lasty]							;#	+ve or -ve
									set yrat [expr double($nes(valhi) - $lasty)/double($ydiff)]	;#	+ve/+ve = +ve OR -ve/-ve = +ve
									set x [expr $x + ($xdiff * $yrat)]
									lappend xy $x $nes(valhi)								;#	Inject new time-interpd point at max value
								}
								set lastx $x
								set lasty $y
							}
							set llen [llength $xy]			;#	Eliminate redundant maxval points
							set xcnt 0
							set ycnt 1
							set ishi 0
							while {$xcnt < $llen} {
								set thisy [lindex $xy $ycnt]
								if {$thisy >= $nes(valhi)} {
									incr ishi				;#	count adjacent maxvalued points
									if {$ishi > 2} {		;#	if 3 in a row, eliminate middle point
										set xy [lreplace $xy [expr $xcnt - 2] [expr $ycnt -2 ]]
										incr ishi -1
										incr llen -2		;#	and shorten table (but don't advance cntrs)
									}
								} else {
									set ishi 0				;#	else advance along table
									incr xcnt 2
									incr ycnt 2
								}
							}
							if {$typ == 1} {
								foreach val $xy {
									lappend nu_xy [DecPlaces $val 1]
								}
								set xy $nu_xy
							}

							if {($paramname == "bore) && ([llength $xy] < 10)} {
								Inf "Too few points in clipped profile (5 needed)"
								return 0
							} 
							set nes_pts $xy
						}
					}
				}
			}
		}
	}

	set nes_starty $neswking(lo)

	if {$toscale} {
		set enable_output 0		;#	THIS OPTION IS FOR VIEWING ONLY
	} else {
		set enable_output 1		;#	THIS OPTION IS FOR EDITING
	}

	NessCreate $typ $brktype $fnam $paramname $enable_output $neswking(dur) $edit $toscale
	if {[info exist nes(forcequit)]} {
		unset nes(forcequit)
		return 0
	}
	if {[info exists nesnak_list] && ([llength $nesnak_list] > 0)} {

		;#	IF OUTPUT MADE RECYCLE THE WORKING RANGE AS THE REAL RANGE, AND RESET THE INITIAL POINT-SET orig_nes_pts

		set nesorig(lo) $neswking(lo)
		set nesorig(hi) $neswking(hi)
		set nesorig(valsco) $neswking(valsco)
		set nesorig(dur) $neswking(dur)
		switch -- $typ {
			0 {
				if {($is_score) && [IsScoreValveParameter $paramname]} {
					if {![ValveChangesGrab $paramname]} {
						return 0
					}
				} else {
					set orig_nes_pts [WriteNessParamData $paramname]
				}
			}
			1 {
				set orig_nes_pts [WriteToBoreData $fnam]
			}
			2 {
				WriteValvePositionsData $fnam
			}
		}
	}
	catch {unset nesnak_list}
	return 1
}

#---- Where existing data is being uploaded to the Ness display: allows user to limit range of values displayed, to get best resolution

proc SpecifyNessRange {lo hi dur mindur maxdur typ edit paramname fnam} {
	global newnesrange pr_newnesrange nr_nestop nr_nesbot nr_nesdur nr_nestyp lastrun_nestop lastrun_nesdur evv
	global nr_stretch nr_extend nr_squeeze nr_clip previous_nestop previous_nesdur nes wstk

	set f .newnesrange

	set realhi [GetNessRangeTop $paramname]
	set typic  [GetTypicalNessRangeTop $paramname]
	set typicdur $nes(BRASSDUR)

	set fnam [file rootname [file tail $fnam]]

	if {[info exists nr_nesdur]} {
		set lastrun_nesdur $nr_nesdur
	}
	if [Dlg_Create $f "SPECIFY RANGE" "set pr_newnesrange 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.s -text "Set Ranges" -command "set pr_newnesrange 1" -width 10 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.h -text "Help" -command "NessRangeHelp" -width 10 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_newnesrange 0" -width 16 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.h -side left -padx 2
		pack $f.0.q -side right

		frame $f.2
		label $f.2.s -text "Top of Range (max [expr int(round($realhi))])" -width 25
		button $f.2.l -text "Prev"  -command "set pr_newnesrange 4" -width 5 -highlightbackground [option get . background {}]
		button $f.2.u -text "Undo"  -command "set pr_newnesrange 8" -width 5 -highlightbackground [option get . background {}]
		button $f.2.m -text "Max"   -command "set pr_newnesrange 5" -width 5 -highlightbackground [option get . background {}]
		button $f.2.h -text "Hn"    -command "set pr_newnesrange 15" -width 3 -highlightbackground [option get . background {}]
		button $f.2.t -text "Tpt"   -command "set pr_newnesrange 16" -width 3 -highlightbackground [option get . background {}]
		button $f.2.b -text "Tbn"   -command "set pr_newnesrange 17" -width 3 -highlightbackground [option get . background {}]
		entry $f.2.e -textvariable nr_nestop -width 16
		pack $f.2.s -side left
		pack $f.2.e $f.2.u $f.2.l $f.2.m $f.2.b $f.2.t $f.2.h -side right -padx 2

		frame $f.4
		label $f.4.s -text "Duration (max [expr int(round($maxdur))])" -width 25
		button $f.4.l -text "Prev"  -command "set pr_newnesrange 7" -width 5 -highlightbackground [option get . background {}]
		button $f.4.u -text "Undo"  -command "set pr_newnesrange 9" -width 5 -highlightbackground [option get . background {}]
		button $f.4.m -text "Max"   -command "set pr_newnesrange 10" -width 5 -highlightbackground [option get . background {}]
		button $f.4.h -text "Hn"    -command "set pr_newnesrange 11" -width 3 -highlightbackground [option get . background {}]
		button $f.4.t -text "Tpt"   -command "set pr_newnesrange 12" -width 3 -highlightbackground [option get . background {}]
		button $f.4.b -text "Tbn"   -command "set pr_newnesrange 13" -width 3 -highlightbackground [option get . background {}]
		entry $f.4.e -textvariable nr_nesdur -width 16
		pack $f.4.s  -side left
		pack $f.4.e $f.4.u $f.4.l $f.4.m $f.4.b $f.4.t $f.4.h -side right -padx 2

		pack $f.0 $f.2 $f.4 -side top -fill x -expand true -pady 2
		bind $f <Return> "set pr_newnesrange 1" 
		bind $f <Escape> "set pr_newnesrange 0" 
		wm resizable $f 0 0
	}
	if {$edit} {
		set nesdur $dur
		set nr_nesdur $dur
		set previous_nesdur $dur
		set nr_nestop $hi
		set previous_nestop $hi
	} else {
		catch {unset previous_nestop}
		catch {unset previous_nesdur}
	}
	$f.2.s config -text "Top of Range (max [expr int(round($realhi))])"
	set nam [GetNessDisplayName $paramname]
	if {($paramname == "bore") && $edit} {
		lappend nam $fnam
	}
	wm title $f "SPECIFY RANGE FOR $nam"
	if {$typ == 1} {
		$f.4.s config -text "Length (max [expr int(round($maxdur))])"
		$f.4.h config -text "Hn"    -command "set pr_newnesrange 11" -bd 2
		$f.4.t config -text "Tpt"   -command "set pr_newnesrange 12" -bd 2
		$f.4.b config -text "Tbn"   -command "set pr_newnesrange 13" -bd 2 -width 3
		$f.2.h config -text "Hn"    -command "set pr_newnesrange 15" -bd 2
		$f.2.t config -text "Tpt"   -command "set pr_newnesrange 16" -bd 2
		$f.2.b config -text "Tbn"   -command "set pr_newnesrange 17" -bd 2 -width 3
	} else {
		$f.4.s config -text "Duration (max [expr int(round($maxdur))])"
		$f.4.h config -text "" -command {} -bd 0
		$f.4.t config -text "" -command {} -bd 0
		$f.4.b config -text "Typical" -command "set pr_newnesrange 14" -bd 2  -width 8
		$f.2.s config -text "Range (max [expr int(round($realhi))])"
		$f.2.h config -text "" -command {} -bd 0
		$f.2.t config -text "" -command {} -bd 0
		$f.2.b config -text "" -command {} -bd 0
	}
	set nr_nestyp $typ
	bind $f <Up> "IncRNestop 1 $lo $hi $typ"
	bind $f <Down> "IncRNestop 0 $lo $hi $typ"
	set nr_nestop $hi
	set nr_nesbot $lo
	set pr_newnesrange 0
	update idletasks
	StandardPosition2 $f
	raise $f
	My_Grab 0 $f pr_newnesrange $f.2.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_newnesrange
		switch -- $pr_newnesrange {
			1 {
				if {![IsNumeric $nr_nestop]} {
					Inf "Invalid parameter value entered (must be numeric)"
					continue
				}
				if {($nr_nestop <= $lo) || ($nr_nestop > $realhi)} {
					Inf "Parameter value out of range (> $lo to $realhi)"
					continue
				}
				if {![IsNumeric $nr_nesdur] || ($nr_nesdur <= 0)} {
					if {$typ == 1} {
						Inf "Invalid length value entered"
					} else {
						Inf "Invalid duration value entered"
					}
					continue
				}
				if {($nr_nesdur < $mindur) || ($nr_nesdur > $maxdur)} {
					if {$typ == 1} {
						set msg "Bore length "
					} else {
						set msg "Duration "
					}
					append msg "value out of range ($mindur to $maxdur)"
					Inf $msg
					continue
				}
				set nr_stretch 0
				set nr_squeeze 0
				set nr_extend 0
				set nr_clip 0
				if {$edit && ($nr_nesdur != $nesdur)} {
					if {$typ == 1} {
						set msg2 "PROFILE"
					} else {
						set msg2 "CONTOUR"
					}
					if {$nr_nesdur < $nesdur} {
						set msg3 "SHRINK"
						set msg4 "CURTAIL"
					} else {
						set msg3 "STRETCH"
						set msg4 "EXTEND"
					}
					set msg "New length different to original : you can $msg3 or $msg4 the $msg2 .\n\n"
					append msg "$msg3 THE $msg2 ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set nr_stretch [expr double($nr_nesdur)/double($nesdur)]	;#	a val > 1 or < 1
					} else {
						set msg "$msg4 THE $msg2 ??\n"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set nr_extend [expr $nr_nesdur - $nesdur]	;#	A +ve OR -ve value
						} else {
							continue
						}
					}
				}
				if {$edit && ($nr_nestop != $hi)} {
					if {$typ == 1} {
						set msg2 "PROFILE"
					} else {
						set msg2 "CONTOUR"
					}
					if {$nr_nestop < $hi} {
						set isclip 1
						set msg "New $msg2 range less than original : you can shrink or clip the $msg2 .\n\n"
						append msg "Shrink the $msg2 ??"
					} else {
						set isclip 0
						set msg "New $msg2 range greater than original : stretch the $msg2 ??"
					}
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set nr_squeeze [expr double($nr_nestop)/double($hi)]	;#	a val > 1 or < 1
					} elseif {$isclip} {
						set msg "Clip the $msg2 ??\n"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set nr_clip [expr $nr_nestop - $hi]	;#	A -ve value
						} else {
							continue
						}
					} else {
						continue
					}
				}
				set lastrun_nestop $nr_nestop
				set newnesrange  [list $nr_nesbot $nr_nestop $nr_nesdur $nr_stretch $nr_extend $nr_squeeze $nr_clip]
				set finished 1
			}
			2 {
				set previous_nestop $nr_nestop
				set nr_nestop $realhi
				set nr_nesbot $lo
			}
			3 {
				set previous_nestop $nr_nestop
				set nr_nestop $typic
			} 
			4 {
				set previous_nestop $nr_nestop
				if {[info exists lastrun_nestop]} {
					set nr_nestop $lastrun_nestop
				}
			} 
			5 {
				set previous_nestop $nr_nestop
				set nr_nestop $realhi
			}
			6 {
				if {[info exists nr_nesdur]} {
					set previous_nesdur $nr_nesdur
				}
				set nr_nesdur $dur
			}
			7 {
				if {[info exists nr_nesdur]} {
					set previous_nesdur $nr_nesdur
				}
				if {[info exists lastrun_nesdur]} {
					set nr_nesdur $lastrun_nesdur
				}
			} 
			8 {
				if {[info exists previous_nestop]} {
					set nr_nestop $previous_nestop
				}
			} 
			9 {
				if {[info exists previous_nesdur]} {
					set nr_nesdur $previous_nesdur
				}
			} 
			10 {
				if {[info exists nr_nesdur]} {
					set previous_nesdur $nr_nesdur
				}
				set nr_nesdur $maxdur
			} 
			11 -
			12 -
			13 -
			14 {
				if {[info exists nr_nesdur]} {
					set previous_nesdur $nr_nesdur
				}
				switch -- $pr_newnesrange {
					11 { set nr_nesdur $nes(BORELEN_HN) }
					12 { set nr_nesdur $nes(BORELEN_TPT) }
					13 { set nr_nesdur $nes(BORELEN_TBN) }
					14 { set nr_nesdur $typicdur }
				}
			} 
			15 -
			16 -
			17 {
				if {[info exists nestop]} {
					set previous_nestop $nestop
				}
				switch -- $pr_newnesrange {
					15 { set nr_nestop $nes(BOREMAX_HN) }
					16 { set nr_nestop $nes(BOREMAX_TPT) }
					17 { set nr_nestop $nes(BOREMAX_TBN) }
				}
			} 
			0 {
				set newnesrange -1
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $newnesrange
}

#---- Where existing data is being uploaded to the Ness display: allows user to limit range of values displayed, to get best resolution

proc SpecifyNessScoreRange {lo hi edit paramname} {
	global newnescrange pr_newnescrange nr_scnestop nr_scnesbot lastrun_scnestop lastrun_scnesbot evv
	global previous_scnestop previous_scnesbot nes wstk

	set f .newnescrange

	set realhi [GetNessRangeTop $paramname]
	set reallo [GetNessRangeBot $paramname]
	set typic  [GetTypicalNessRangeTop $paramname]

	if [Dlg_Create $f "SPECIFY RANGE" "set pr_newnescrange 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.s -text "Set Ranges" -command "set pr_newnescrange 1" -width 10 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_newnescrange 0" -width 16 -highlightbackground [option get . background {}]
		pack $f.0.s -side left -padx 2
		pack $f.0.q -side right
		label $f.1 -text "Up/Down Keys modify Range Top   :   Control-Up/Down modifies Range Bottom" -fg $evv(SPECIAL)
		pack $f.1 -side top -pady 2

		frame $f.2
		label $f.2.s -text "Top of Range (max [expr int(ceil($realhi))])" -width 25
		button $f.2.l -text "Prev"  -command "set pr_newnescrange 2" -width 5 -highlightbackground [option get . background {}]
		button $f.2.u -text "Undo"  -command "set pr_newnescrange 3" -width 5 -highlightbackground [option get . background {}]
		button $f.2.m -text "Max"   -command "set pr_newnescrange 4" -width 5 -highlightbackground [option get . background {}]
		entry $f.2.e -textvariable nr_scnestop -width 16
		pack $f.2.s -side left
		pack $f.2.e $f.2.u $f.2.l $f.2.m -side right -padx 2

		frame $f.4
		label $f.4.s -text "Bottom of Range (min [expr int(floor($reallo))])" -width 25
		button $f.4.l -text "Prev"  -command "set pr_newnescrange 5" -width 5 -highlightbackground [option get . background {}]
		button $f.4.u -text "Undo"  -command "set pr_newnescrange 6" -width 5 -highlightbackground [option get . background {}]
		button $f.4.m -text "Min"   -command "set pr_newnescrange 7" -width 5 -highlightbackground [option get . background {}]
		entry $f.4.e -textvariable nr_scnesbot -width 16
		pack $f.4.s  -side left
		pack $f.4.e $f.4.u $f.4.l $f.4.m -side right -padx 2

		pack $f.0 $f.2 $f.4 -side top -fill x -expand true -pady 2
		bind $f <Return> "set pr_newnescrange 1" 
		bind $f <Escape> "set pr_newnescrange 0" 
		bind $f <Up> "IncRcNestop 1 $lo $hi top"
		bind $f <Down> "IncRcNestop 0 $lo $hi top"
		bind $f <Control-Up> "IncRcNestop 1 $lo $hi bot"
		bind $f <Control-Down> "IncRcNestop 0 $lo $hi bot"
		wm resizable $f 0 0
	}
	if {$edit} {
		set nr_scnesbot $lo
		set previous_scnesbot $lo
		set nr_scnestop $hi
		set previous_scnestop $hi
	} else {
		catch {unset previous_scnestop}
		catch {unset previous_scnesbot}
	}

	set nam [GetNessDisplayName $paramname]

	wm title $f "SPECIFY RANGE FOR $nam"
	set nr_scnestop $hi
	set nr_scnesbot $lo
	set pr_newnescrange 0
	update idletasks
	StandardPosition2 $f
	raise $f
	My_Grab 0 $f pr_newnescrange $f.2.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_newnescrange
		switch -- $pr_newnescrange {
			1 {
				if {![IsNumeric $nr_scnestop]} {
					Inf "Invalid parameter value for top of range (must be numeric)"
					continue
				}
				if {($nr_scnestop <= $reallo) || ($nr_scnestop > $realhi)} {
					Inf "Parameter value for top of range out of range (> $lo to $realhi)"
					continue
				}
				if {![IsNumeric $nr_scnesbot]} {
					Inf "Invalid parameter value for bottoms of range (must be numeric)"
					continue
				}
				if {($nr_scnesbot < $reallo) || ($nr_scnesbot >= $realhi)} {
					Inf "Parameter value for bottom of range out of range ($lo to < $realhi)"
					continue
				}
				if {$nr_scnestop < $nr_scnesbot} {
					Inf "Range inverted"
					continue
				}
				if {$nr_scnestop == $nr_scnesbot} {
					Inf "Zero range"
					continue
				}
				set lastrun_scnestop $nr_scnestop
				set newnescrange [list $nr_scnesbot $nr_scnestop]
				set finished 1
			}
			2 {
				if {[info exists lastrun_scnestop]} {
					set previous_scnestop $nr_scnestop
					set nr_scnestop $lastrun_scnestop
				}
			} 
			3 {
				if {[info exists previous_scnestop]} {
					set nr_scnestop $previous_scnestop
				}
			} 
			4 {
				set previous_scnestop $nr_scnestop
				set nr_scnestop $realhi
			}
			5 {
				if {[info exists lastrun_scnesbot]} {
					set previous_scnesbot $nr_scnesbot
					set nr_scnesbot $lastrun_scnesbot
				}
			} 
			6 {
				if {[info exists previous_scnesbot]} {
					set nr_scnesbot $previous_scnesbot
				}
			} 
			7 {
				set previous_scnesbot $nr_scnesbot
				set nr_scnesbot $reallo
			} 
			0 {
				set newnescrange -1
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $newnescrange
}

proc NessRangeHelp {} {
	set msg    "\"Prev\"   gets the value set in the previous range-setting.\n"
	append msg "\"Undo\"   returns to the immediately previous value in the entry box.\n"
	append msg "\"Typical\" sets a typical maximum range.\n"
	append msg "\"Max\"   sets the absolute maximum range.\n"
	append msg "\"Hn\"     sets a typical maximum range for a Horn.\n"
	append msg "\"Tpt\"    sets a typical maximum range for a Trumpet.\n"
	append msg "\"Tbn\"   sets a typical maximum range  for a Trombone.\n"
	Inf $msg
}

proc IncRNestop {up lo hi typ} {
	global nr_nestop

	if {![IsNumeric $nr_nestop]} {
		return
	}
	if {$up} {
		if {$nr_nestop < $hi} {
			if {$typ == 1} {
				incr nr_nestop
			} else {
				if {$nr_nestop < 1} { 
					set nr_nestop [expr $nr_nestop + 0.1]
				} else {
					set nr_nestop [expr $nr_nestop + 1]
				}
				if {$nr_nestop > $hi} {
					set nr_nestop $hi
				}
			}
		}
	} else {
		set range [expr $nr_nestop - $lo]
		if {$range < 0.0} {
			return
		}
		if {$typ == 1} {
			set loup [expr $lo + 1]
			if {$nr_nestop > $loup} {
				incr nr_nestop -1
			}
		} else {
			if {$range  < 0.1} { 
				set nr_nestop [expr $nr_nestop - 0.01]
			} elseif {$range  < 1} { 
				set nr_nestop [expr $nr_nestop - 0.1]
			} else {
				set nr_nestop [expr $nr_nestop - 1]
			}
			if {$nr_nestop < $lo} {
				set nr_nestop $lo
			}
		}
	}
}

proc IncRcNestop {up lo hi typ} {
	global nr_scnestop nr_scnesbot

	if {$typ == "bot"} {
		if {![IsNumeric $nr_scnesbot]} {
			return
		}
	} else {
		if {![IsNumeric $nr_scnestop]} {
			return
		}
	}
	if {$up} {
		if {$typ == "bot"} {	;#	Move bottom of range up
			if {$nr_scnesbot < $nr_scnestop} {
				set origbot $nr_scnesbot
				set range [expr $nr_scnestop - $nr_scnesbot]
				if {$range < 0.1} { 
					set nr_scnesbot [expr $nr_scnesbot + 0.01]
				} elseif {$range < 1} { 
					set nr_scnesbot [expr $nr_scnesbot + 0.1]
				} else {
					set nr_scnesbot [expr $nr_scnesbot + 1]
				}
				if {$nr_scnesbot >= $nr_scnestop} {
					set nr_scnesbot $origbot
				}
			}
		} else {				;#	Move top of range up
			if {$nr_scnestop < $hi} {
				set range [expr $hi - $nr_scnestop]
				if {$range < 0.1} { 
					set nr_scnestop [expr $nr_scnestop + 0.01]
				} elseif {$range < 1} { 
					set nr_scnestop [expr $nr_scnestop + 0.1]
				} else {
					set nr_scnestop [expr $nr_scnestop + 1]
				}
				if {$nr_scnestop > $hi} {
					set nr_scnestop $hi
				}
			}
		}
	} else {
		if {$typ == "bot"} {	;#	Move bottom of range down
			if {$nr_scnesbot > $lo} {
				set range [expr $nr_scnesbot - $lo]
				if {$range < 0.1} { 
					set nr_scnesbot [expr $nr_scnesbot - 0.01]
				} elseif {$range < 1} { 
					set nr_scnesbot [expr $nr_scnesbot - 0.1]
				} else {
					set nr_scnesbot [expr $nr_scnesbot - 1]
				}
				if {$nr_scnesbot < $lo} {
					set nr_scnesbot $lo
				}
			}
		} else {				;#	Move top of range down
			set origtop $nr_scnestop
			set range [expr $nr_scnestop - $nr_scnesbot]
			if {$range  < 0.1} { 
				set nr_scnestop [expr $nr_scnestop - 0.01]
			} elseif {$range < 1} { 
				set nr_scnestop [expr $nr_scnestop - 0.1]
			} else {
				set nr_scnestop [expr $nr_scnestop - 1]
			}
			if {$nr_scnestop <= $nr_scnesbot} {
				set nr_scnestop $origtop
			}
		}
	}
}

proc GetNessDisplayName {innam} {
	switch -- $innam {
		"bore" {
			set displayname "Bore Profile"
		}
		"pressure" {
			set displayname "Pressure"
		}
		"lip_frequency" {
			set displayname "Lip Frequency"
		}
		"vibamp" {
			set displayname "Lip Vibrato Amp"
		}
		"vibfreq" {
			set displayname "Lip Vibrato Frq"
		}
		"tremamp" {
			set displayname "Tremolo Amplitude"
		}
		"tremfreq" {
			set displayname "Tremolo Frequency"
		}
		"noiseamp" {
			set displayname "Noise Fraction"
		}
		"valvevibamp" {
			set displayname "Valve Vibrato Amp"
		}
		"valvevibfreq" {
			set displayname "Valve Vibrato Frq"
		}
		"valveopening" {
			set displayname "Valve Opening"
		}
		"sr" - 
		"Sr" {
			set displayname "Lip Area"
		}
		"mu" {
			set displayname "Lip Mass"
		}
		"sigma" {
			set displayname "Lip Damping"
		}
		"H" -
		"h" {
			set displayname "Lip Separation"
		}
		"T" -
		"t" {
			set displayname "Duration"
		}
		"w" {
			set displayname "Lip Width"
		}
	}
	return $displayname
}

################################
# SOUND VIEW DISPLAY FUNCTIONS #
################################

proc NesnakOutput {time_out paramname} {
	global nes_other nes_remainder nes_starty evv nes wstk nesinterp
	global pr_nesnak pprg nes_fnam
											;#	Trap wrong-number of valve-param entries BEFORE NessCreate exits

	if {[IsScoreValveParameter $paramname] && ($nes(valveopeningdisplaycnt) > $nes(valvecheck))} {
		set len [llength $nes(brk)]
		set len [expr $len/2]				;#	Count pairs
		incr len -2							;#	Drop end points
		if {$len != $nes(valve_eventcnt)} {
			Inf "Wrong number of valve-events ($len) : should be $nes(valve_eventcnt)"
			return
		}
	}
	if {$nes(brktype) == $evv(SN_BRKPNTPAIRS)} {
		foreach {x y} $nes(brk) {
			set y [expr $nes(height) - $y]
			set y [expr double($y) / double($nes(height))]
			set y [expr $y * $nes(valsco)]
			set y [expr $y + $nes(vallo)]
			set x [expr double($x) * $nes(inv_sr)]
			if {[IsEngineeringNotation $x]} {
				set x [UnEngineer $x]
			}
			if {[IsEngineeringNotation $y]} {
				set y [UnEngineer $y]
			}
			switch -- $nes(isprof) {
				0 { 
					switch -- $paramname {
						"vpos" -
						"bore" {
							lappend nes(nesnak_list) "[DecPlaces $x 6] [DecPlaces $y 6]"
						}
						"sr" -
						"Sr" -
						"mu" -
						"H" -
						"h" -
						"w" {
							lappend nes(nesnak_list) "[DecPlaces $x 3] [DecPlaces $y 12]"
						}
						"sigma" -
						"pressure" {
							lappend nes(nesnak_list) "[DecPlaces $x 3] [DecPlaces $y 1]"
						}
						"lip_frequency" -
						"vibfreq"  -
						"tremfreq" {
							lappend nes(nesnak_list) "[DecPlaces $x 3] [DecPlaces $y 2]"
						}
						"vibamp"   -
						"tremamp"  -
						"noiseamp" {
							lappend nes(nesnak_list) "[DecPlaces $x 3] [DecPlaces $y 3]"
						}
						"valveopening" {
							lappend nes(nesnak_list) "[DecPlaces [expr 1.0 - $y] 2]"	;#	Time not retained :	0 at top, 1 at bottom (inversion of normal)
						}
						"valvevibfreq" {
							lappend nes(nesnak_list) "[DecPlaces $y 2]"					;#	Time not retained
						}
						"valvevibamp" {
							lappend nes(nesnak_list) "[DecPlaces $y 3]"					;#	Time not retained
						}
					}
				}
				1 { lappend nes(nesnak_list) "[DecPlaces $x 1] [DecPlaces $y 1]"			}
				2 { lappend nes(nesnak_list) "[expr int(round($x))] [expr int(round($y))]"	}
			}
		}
		if {$paramname == "bore"} {
			set llen [llength $nes(nesnak_list)] 
			if {$llen < 5} {
				Inf "Bore profile ([llength $nes(nesnak_list)] entered) must have at least 5 values"
				unset nes(nesnak_list)
				return
			}
			set OK 0
			set min_bore 10000000000000
			set min_bore_at 0
			set c_cnt 0
			foreach bore_pair $nes(nesnak_list) {
				set thisbore [lindex $bore_pair 1]
				set thisbore_at $c_cnt
				if {$thisbore < $min_bore} {
					set min_bore $thisbore
					set min_bore_at $c_cnt
				}
				incr c_cnt
			}

			if {($min_bore_at == 0) || ($min_bore_at == [expr $llen - 1]) || ($min_bore_at == [expr $llen - 2])} {
				Inf "Bore profile has no minimum appropriate to a mouthpiece endpoint"
				unset nes(nesnak_list)
				return
			}
			if {[info exists nesinterp(cdptest)]} {
				set msg "Save the interpolated data ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}													;#	If data interpolated, Data can no longer be edited 
				.brass.bore.e config -text "" -command {} -bd 0		;#	So disable/hide "Edit Bore Profile" button
			}
																	;#	Otherwise, if CREATING a profile, we now have a profile to edit, so
			if {!$nes(edit)} {										;#	Force interface into "edit" mode, rather than "create" mode	

				.brass.bore.e config -text "Edit Bore Profile" -command "NessDisplay 1 1 bore $nes_fnam 0 0" -borderwidth 4 -width 20
			
			}														;#	In all cases, data can still be displayd-to-scale or rescaled

			.brass.bore.e2 config -text "Display To Scale" -command "NessDisplay 1 1 bore $nes_fnam 1 0" -borderwidth 4
			.brass.bore.e3 config -text "ReScale Profile (^R)"  -command "NessDisplay 1 1 bore $nes_fnam 0 1" -borderwidth 4
		}
	} else {	;#	SN_TIMESLIST
		if {[info exists nes(marklist)]} {
			NessDeleteDuplMarks
			set nes(marklist) [lsort -integer $nes(marklist)]
			foreach outsamp $nes(marklist) {
				set outtime [expr double($outsamp) * $nes(inv_sr)]
				lappend nes(nesnak_list) [expr round($outtime)]
			}
		}
	}

	Inf "Data output"
	set pr_nesnak 1
}

proc NessAbandon {} {
	global nesinterp pr_nesnak nes evv
	if {[info exists nesinterp(cdptest)] && ![info exists nesinterp($nes(fnam))]} {
		NessInterpolate 1
	}
	catch {unset nes(belpoints)}
	catch {unset nes(prebelend)}
	catch {unset nes(prebelx)}
	catch {unset nes(prebely)}
	.nesnak.f3.bel.mbel config -bg $evv(EMPH)
	set pr_nesnak 0
}

proc NesCreatePoint {x y} {
	global nes evv nes
	set xa [expr $x - $nes(PWIDTH)]
	set xb [expr $x + $nes(PWIDTH)]
	set ya [expr $y - $nes(PWIDTH)]
	set yb [expr $y + $nes(PWIDTH)]
	$nes(nesnakan) create rect $xa $ya $xb $yb -fill $nes(color) -tag point
}

proc NesCreateVal {x y} {
	global nes
	set ofzt 0
	set ya [expr $y - 10]
	if {$ya < 8} {
		set ya 8
		set ofzt 1
	}
	if {$nes(not_valvedisplay)} {
		set val [expr $nes(height) - $y]	;#	Normnal val display max at top, min at bottom
	} else {
		set val $y							;#	Valving display has 0 at top, 1 at bottom
	}
	set val [expr double($val) / double($nes(height))]
	set range [expr $nes(valhi) - $nes(vallo)]
	set val [expr $range * $val]
	set val [expr $val + $nes(vallo)]
	if {$range > 100} {
		set val [expr round($val)]
	} elseif {$range > 10} {
		set val [DecPlaces $val 1]
	} elseif {$range > 1} {
		set val [DecPlaces $val 2]
	} elseif {$range > .1} {
		set val [DecPlaces $val 3]
	} elseif {$range > .01} {
		set val [DecPlaces $val 4]
	} elseif {$range > .001} {
		set val [DecPlaces $val 5]
	}
	set txtlen [expr [string length $val] * $nes(CHARWIDTH)]
	set halftxtlen [expr $txtlen/2]
	set txtend [expr $x + $halftxtlen]
	if {$txtend > $nes(width)} {
		set xa [expr $x - $halftxtlen]
	} else {
		set txtend [expr $x - $halftxtlen]
		if {$txtend < 0} {
			set xa [expr $x + $halftxtlen]
		} else {
			set xa $x
		}
	}
	$nes(nesnakan) create text $xa $ya -text $val -fill blue -tags "val val$x"

	if {$nes(not_valvedisplay)} {			;#	Valving display does not show time
		set ya [expr $y + 10]
		if {$ya > [expr $nes(height) - 6]} {
			set ya $y
		}
		set val [expr double($x) / double($nes(width))]
		set range [expr $nes(dispend) - $nes(dispstart)]
		set trange [expr $range * $nes(inv_sr)]
		set val [expr $range * $val]
		set val [expr $val + $nes(dispstart)]
		set val [expr $val * $nes(inv_sr)]
		if {$trange > 100} {
			set val [expr round($val)]
		} elseif {$trange > 10} {
			set val [DecPlaces $val 1]
		} elseif {$trange > 1} {
			set val [DecPlaces $val 2]
		} elseif {$trange > .1} {
			set val [DecPlaces $val 3]
		} elseif {$trange > .01} {
			set val [DecPlaces $val 4]
		} elseif {$trange > .001} {
			set val [DecPlaces $val 5]
		}
		set txtlen [expr [string length $val] * $nes(CHARWIDTH)]
		set halftxtlen [expr $txtlen/2]
		set txtend [expr $x + $halftxtlen]
		if {$txtend > $nes(width)} {
			set xa [expr $x - $halftxtlen]
		} else {
			set txtend [expr $x - $halftxtlen]
			if {$txtend < 0} {
				set xa [expr $x + $halftxtlen]
			} else {
				set xa $x
			}
		}
		if {$ofzt} {
			set ya 20
		} 
		$nes(nesnakan) create text $xa $ya -text $val -fill red -tags "val val$x"
	}
}

proc NesCreateMarkVal {x xpos} {
	global nes
	set y [expr $nes(height)/2]
	set val [expr round($x * $nes(inv_sr))]
	set txtlen [expr [string length $val] * $nes(CHARWIDTH)]
	set txthalflen [expr $txtlen/2]
	set offset $txthalflen
	incr offset 4
	set xpos [expr $xpos + $offset]
	set farend [expr $xpos + $txthalflen]
	if {$farend >= $nes(width)} {
		set movetxt [expr -(4 + $txtlen)]
		incr xpos $movetxt
		incr y 6
	}
	$nes(nesnakan) create text $xpos $y -text $val -fill blue -tags "mval mval$x"
}

proc NesRemoveVal {x} {
	global nes
	catch [$nes(nesnakan) delete val$x] in
}

proc NesRemoveMarkVal {x} {
	global nes
	catch [$nes(nesnakan) delete mval$x] in
}

proc NesHideVals {hide} {
	global nes
	if {$hide == -1} {
		catch {$nes(nesnakan) delete val} in
		return
	}
	if {$hide} {
		catch {$nes(nesnakan) delete val} in
		.nesnak.f6.1.zs config -text "SHOW VALUES" -bd 2 -command "NesHideVals 0"
		set nes(hidden) 1
	} else {
		foreach {x y} $nes(brk_disp) {
			NesCreateVal $x $y
		}
		.nesnak.f6.1.zs config -text "HIDE VALUES" -bd 2 -command "NesHideVals 1"
		set nes(hidden) 0
	}
}

proc NesHideMarkVals {hide} {
	global nes
	if {$hide == -1} {
		catch {$nes(nesnakan) delete mval} in
		return
	}
	if {$hide} {
		catch {$nes(nesnakan) delete mval} in
		.nesnak.f6.1.zs config -text "SHOW VALUES" -bd 2 -command "NesHideMarkVals 0"
		set nes(hidden) 1
	} else {
		if {[info exists nes(marklist)]} {
			set hasmarks 0
			foreach x $nes(marklist) {
				if {($x >= $nes(dispstart)) && ($x < $nes(dispend))} {
					set xa [expr double($x - $nes(dispstart))/double($nes(dispend) - $nes(dispstart))]
					set xa [expr int(round($xa * double($nes(width))))]
					NesCreateMarkVal $x $xa
					set hasmarks 1
				}
			}
			if {$hasmarks} {
				.nesnak.f6.1.zs config -text "HIDE VALUES" -bd 2 -command "NesHideMarkVals 1"
				set nes(hidden) 0
			}
		}
	}
}

proc NesPointAdd {x y} {
	global nes
	if {$x < $nes(left)} {
		set x $nes(left)
	} elseif {$x > $nes(right)} {
		set x $nes(right)
	}
	if {$y < 0} {
		set y 0
	} elseif {$y > $nes(height)} {
		set y $nes(height)
	}
	set sttindx -1
	set endindx 0
	set nu {}
	set cnt 0
	foreach {xa ya} $nes(brk_disp) {
		if {$x == $xa} {
			return
		} elseif {$x > $xa} {
			incr sttindx 2
			incr endindx 2
			incr cnt
		} else {
			break
		}
	}
	set nes(localindx) $cnt
	if {$sttindx > 0} {
		set nu [lrange $nes(brk_disp) 0 $sttindx]
	}
	lappend nu $x $y
	if {$endindx < $nes(localcnt)} {
		set nu [concat $nu [lrange $nes(brk_disp) $endindx end]]
	}
	set nes(brk_disp) $nu
	incr nes(localcnt) 2
	incr nes(endx) 2
	NesCreatePoint $x $y
	NesCreateVal $x $y
	NesPointSet add
	NesDrawLine
}

proc NesPointDel {x y} {
	global nes evv
	set obj [NessGetClosest $x $y point]
	if {$obj < 0} {
		return
	}
	set coords [$nes(nesnakan) coords $obj]
	set x [expr round([lindex $coords 0])]
	incr x $nes(PWIDTH)
	NesRemoveVal $x
	set indx [NessFindPointInList $x]
	set nes(localindx) [expr $indx / 2] 
	if {$indx < 0} {
		return
	} elseif {($indx == 0) && $nes(atzero)} {
		return
	} elseif {($indx == $nes(endx)) && $nes(atend)} {
		return
	}
	NessRemovePointFromList $indx
	NesPointSet delete
	catch {$nes(nesnakan) delete $obj} in
	NesDrawLine
}

proc NesPointMark {x y} {
	global nes evv
	set nes(marked) 0
	set nes(obj) [NessGetClosest $x $y point]
	if {$nes(obj) < 0} {
		return
	}
	set coords [$nes(nesnakan) coords $nes(obj)]
	set nes(x) [expr round([lindex $coords 0])]
	incr nes(x) $nes(PWIDTH)
	NesRemoveVal $nes(x)
	set nes(y) [expr round([lindex $coords 1])]
	incr nes(y) $nes(PWIDTH)
	set nes(mx) $x
	set nes(my) $y
	set nes(lastx) $nes(x)
	set nes(lasty) $nes(y)
	set nes(indx) [NessFindPointInList $nes(x)]
	set nes(localindx) [expr $nes(indx) / 2]
	if {$nes(drag)} {	;# MOVE TIME
		if {$nes(indx) < 0} {
			return
		} elseif {($nes(indx) == 0) && $nes(atzero)} {
			return
		} elseif {($nes(indx) == $nes(endx)) && $nes(atend)} {
			return
		}
		if {![NessFindMotionLimits]} {
			return
		}
	} else {
		incr nes(indx)
	}
	set nes(marked) 1
}

proc NesPointDrag {x y} {
	global nes
	if {!$nes(marked)} {
		return
	}
	if {$nes(drag)} { ;# MOVE TIME
		set mx $x
		set dx [expr $mx - $nes(mx)]
		incr nes(x) $dx
		if {$nes(x) > $nes(rightstop)} {
			set nes(x) $nes(rightstop)
			set dx [expr $nes(x) - $nes(lastx)]
		} elseif {$nes(x) < $nes(leftstop)} {
			set nes(x) $nes(leftstop)
			set dx [expr $nes(x) - $nes(lastx)]
		}
		set nes(lastx) $nes(x)
		$nes(nesnakan) move $nes(obj) $dx 0
		set nes(mx) $mx
		set x [expr round($nes(x))]
		set nes(brk_disp) [lreplace $nes(brk_disp) $nes(indx) $nes(indx) $x]
	} else {
		set my $y
		set dy [expr $my - $nes(my)]
		incr nes(y) $dy
		if {$nes(y) > $nes(height)} {
			set nes(y) $nes(height)
			set dy [expr $nes(y) - $nes(lasty)]
		} elseif {$nes(y) < 0} {
			set nes(y) 0
			set dy [expr $nes(y) - $nes(lasty)]
		}
		set nes(lasty) $nes(y)
		$nes(nesnakan) move $nes(obj) 0 $dy
		set nes(my) $my
		set y [expr round($nes(y))]
		set nes(brk_disp) [lreplace $nes(brk_disp) $nes(indx) $nes(indx) $y]
	}
	NesDrawLine
}

proc NesValSet {} {
	global nes evv
	set coords [$nes(nesnakan) coords $nes(obj)]
	if {[llength $coords] >= 2} {
		set x [expr round([lindex $coords 0])]
		set y [lindex $coords 1]
		incr x $nes(PWIDTH)
		NesCreateVal $x $y
	}
}

proc NesPointSet {act} {
	global nes evv
	if {![info exists nes(localindx)]} {
		return					;#	'localindx' is position in local_brk of point added, deleted or moved
	}
	if {[info exists nes(brk_local)] && ([llength $nes(brk_local)] > 0)} {
		set len [llength $nes(brk_local)]
		incr len -2
		set start [lindex $nes(brk_local) 0]		;#	Total brkpnt set reconstructed from brk_local and all non-local points
		set thend [lindex $nes(brk_local) $len]
	} else {
		set start $nes(startsamp)
		set thend $nes(endsamp)
	}
	if {[info exists nes(belpoints)]} {
		unset nes(belpoints)
		catch {unset nes(prebelend)}
		catch {unset nes(prebelx)}
		catch {unset nes(prebely)}
		.nesnak.f3.bel.mbel config -bg $evv(EMPH)
	}

	switch -- $act {			;#	NesPointSet modified so only changes added, deleted or moved point: all others unaffected
		"add" {
			set cnt 0
			set localbrkindx 0
			foreach {x y} $nes(brk_disp) {
				if {$cnt == $nes(localindx)} {
					set g [expr int(round(($x - $nes(left)) * $nes(timescale)))]
					incr g $nes(dispstart)
					lappend nuvals $g $y
				} else {
					lappend nuvals [lindex $nes(brk_local) $localbrkindx]
					incr localbrkindx
					lappend nuvals [lindex $nes(brk_local) $localbrkindx]
					incr localbrkindx
				}
				incr cnt
			}
		}
		"delete" {
			set cnt 0
			foreach {x y} $nes(brk_local) {
				if {$cnt != $nes(localindx)} {
					lappend nuvals $x $y
				}
				incr cnt
			}
		}
		"move" {
			set cnt 0
			foreach {x y} $nes(brk_local) {xa ya} $nes(brk_disp) {
				if {$cnt == $nes(localindx)} {
					set g [expr int(round(($xa - $nes(left)) * $nes(timescale)))]
					incr g $nes(dispstart)
					lappend nuvals $g $ya
				} else {
					lappend nuvals $x $y
				}
				incr cnt
			}
		}
	}
	if {![info exists nuvals]} {
		set nes(localcnt) 0
	} else {
		set nes(brk_local) $nuvals
		set nes(localcnt) [llength $nes(brk_local)]
	}
	switch -- $nes(localcnt) {
		0 {
			set nes(atcanstart) 0
			set nes(atcanend) 0
		}
		2 {
			if {[lindex $nes(brk_disp) 0] <= $nes(left)} {
				set nes(atcanstart) 1
			} else {
				set nes(atcanstart) 0
			}
			if {[lindex $nes(brk_disp) 0] >= $nes(right)} {
				set nes(atcanend) 1
			} else {
				set nes(atcanend) 0
			}
		}
		default {
			if {[lindex $nes(brk_disp) 0] <= $nes(left)} {
				set nes(atcanstart) 1
			} else {
				set nes(atcanstart) 0
			}
			if {[lindex $nes(brk_disp) $nes(endx)] >= $nes(right)} {
				set nes(atcanend) 1
			} else {
				set nes(atcanend) 0
			}
		}
	}
	set nuvals {}
	set gotend 0
	catch {unset nes(previous)}
	catch {unset nes(next)}
	set indx 0
	if {([lindex $nes(brk_local) 0] == 0)  && ([lindex $nes(brk_local) [expr [llength $nes(brk_local)] - 2]] == $nes(sampdur))} {
		set nes(brk) $nes(brk_local)
		set nes(marked) 0
		return
	}
	switch -- $nes(localcnt) {
		0 {
			foreach {x y} $nes(brk) {
				if {$x < $nes(dispstart)} {
					lappend nuvals $x $y
					set nes(previous) [list $x $y]
				} elseif {$x > $nes(dispend)} {
					set nuvals [concat $nuvals [lrange $nes(brk) $indx end]]
					set nes(next) [list $x $y]
					set gotend 1
					break
				}
				incr indx 2
			}
		}
		default {
			foreach {x y} $nes(brk) {
				if {$x < $start} {
					lappend nuvals $x $y
					set nes(previous) [list $x $y]
				} elseif {$x > $thend} {
					set nuvals [concat $nuvals $nes(brk_local) [lrange $nes(brk) $indx end]]
					set nes(next) [list $x $y]
					set gotend 1
					break
				}
				incr indx 2
			}
		}
	}
	if {!$gotend} {
		set nuvals [concat $nuvals $nes(brk_local)]
		set nes(next) [list $x $y]
	}
	set nes(brk) $nuvals
	set nes(marked) 0
}

proc NessFindPointInList {xa} {
	global nes
	set timindex 0
	foreach {x y} $nes(brk_disp) {
		if [string match $x $xa] {
			return $timindex
		}
		incr timindex 2
	}
	return -1
}

proc NessRemovePointFromList {timindex} {
	global nes
	set valindex $timindex
	incr valindex
	set nes(brk_disp) [lreplace $nes(brk_disp) $timindex $valindex]
	incr nes(localcnt) -2
	incr nes(endx) -2
}

proc NesDrawUnityLine {} {
	global nes
	set coords [list $nes(left) $nes(starty) $nes(right) $nes(starty)]
	$nes(nesnakan) create line $coords -fill blue -tag line
}
	
proc NesDrawLine {} {
	global nes
	set coords {}
	if {$nes(localcnt) <= 0} {
		if {![info exists nes(previous)] || ![info exists nes(next)]} {
			return
		}
		set prevtime [lindex $nes(previous) 0]
		set prevval  [lindex $nes(previous) 1]
		set nexttime [lindex $nes(next) 0]
		set nextval  [lindex $nes(next) 1]
		set longstep [expr double($nexttime - $prevtime)]
		set ystep [expr $nextval - $prevval]
		set ratio [expr double($nes(dispstart) - $prevtime) / $longstep]
		set yval [expr int(round($ystep * $ratio)) + $prevval]
		set coords [list $nes(left) $yval]
		set ratio [expr double($nes(dispend) - $prevtime) / $longstep]
		set yval [expr int(round($ystep * $ratio)) + $prevval]
		set coords [concat $coords $nes(right) $yval]
	} else {
		if {!$nes(atcanstart)} {
			if [info exists nes(previous)] {
				set brkstart [lindex $nes(brk_local) 0]
				set brkval   [lindex $nes(brk_local) 1]
				set prevtime [lindex $nes(previous) 0]
				set prevval  [lindex $nes(previous) 1]
				set ratio 1.0
				if {$brkstart != $prevtime} {
					set ratio [expr double($nes(dispstart) - $prevtime) / double($brkstart - $prevtime)]
				}
				set ystep [expr $brkval - $prevval]
				set yval [expr int(round($ystep * $ratio)) + $prevval]
				set coords [list $nes(left) $yval]
			}
		}
		set coords [concat $coords $nes(brk_disp)]
		if {!$nes(atcanend)} {
			if [info exists nes(next)] {
				set endindx $nes(endx)
				set canend  $nes(dispend)
				set brkend  [lindex $nes(brk_local) $endindx]
				incr endindx
				set brkval   [lindex $nes(brk_local) $endindx]
				set nexttime [lindex $nes(next) 0]
				set nextval  [lindex $nes(next) 1]
				if {$nexttime == $brkend} {
					set yval $brkval
				} else {
					set ratio [expr double($canend - $brkend) / double($nexttime - $brkend)]
					set ystep [expr $nextval - $brkval]
					set yval [expr int(round($ystep * $ratio)) + $brkval]
				}
				set coords [concat $coords $nes(right) $yval]
			}
		}
	}
	catch {$nes(nesnakan) delete line}
	$nes(nesnakan) create line $coords -fill $nes(color) -tag line
}

proc NessFindMotionLimits {} {
	global nes
	if {$nes(indx) == 0} {
		set nes(leftstop) $nes(left)
		if {$nes(localcnt) == 2} {
			set nes(rightstop) $nes(right)
		} else {
			set nes(rightstop) [lindex $nes(brk_disp) [expr $nes(indx) + 2]]
			incr nes(rightstop) -1
		}
	} elseif {$nes(indx) == $nes(endx)} {
		set nes(rightstop) $nes(right)
		if {$nes(localcnt) == 2} {
			set nes(leftstop) $nes(left)
		} else {
			set nes(leftstop) [lindex $nes(brk_disp) [expr $nes(indx) - 2]]
			incr nes(leftstop)
		}
	} else {
		set nes(leftstop) [lindex $nes(brk_disp) [expr $nes(indx) - 2]]
		incr nes(leftstop)
		set nes(rightstop) [lindex $nes(brk_disp) [expr $nes(indx) + 2]]
		incr nes(rightstop) -1
	}
	if {$nes(leftstop) >= $nes(rightstop)} {
		return 0
	}
	return 1
}

proc NesMarkDel {x y} {
	global nes
	if {![info exists nes(marklist)]} {
		return
	}
	set obj [NessGetClosest $x $y mark]
	if {$obj < 0} {
		return
	}
	catch {$nes(nesnakan) delete $obj} in

	set wratio [expr double($x - $nes(left)) / double($nes(width))]
	set x [expr int(round(double($nes(displen)) * $wratio))]
	set x [expr $nes(dispstart) + $x]

	set mindiff [expr $nes(sampdur) + 10]
	set cnt 0
	foreach xx $nes(marklist) {
		set diff [expr abs($xx - $x)]
		if {$diff < $mindiff} {
			set mindiff $diff
			set item $cnt
		}
		incr cnt
	}
	if {[info exists item]} {
		NesRemoveMarkVal [lindex $nes(marklist) $item]
		set nes(marklist) [lreplace $nes(marklist) $item $item]
	}
}

proc NessDeleteDuplMarks {} {
	global nes
	set len [llength $nes(marklist)] 
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set n_mark [lindex $nes(marklist) $n]
		set m $n
		incr m
		while {$m < $len} {
			set m_mark [lindex $nes(marklist) $m]
			if {$n_mark == $m_mark} {
				set nes(marklist) [lreplace $nes(marklist) $m $m]
				incr m -1
				incr len -1
				incr len_less_one -1
			}
			incr m
		}
		incr n
	}
}

proc NesMark {x} {
	global nes
	if {($x < $nes(left)) || ($x > $nes(right))} {
		return
	}
	set xx $x
	set nes(markthis) [eval {$nes(nesnakan) create line} {$x $nes(height) $x 0 -tag mark -fill blue}]
	set wratio [expr double($xx - $nes(left)) / double($nes(width))]
	set x [expr int(round(double($nes(displen)) * $wratio))]
	set outsamp [expr $nes(dispstart) + $x]
	lappend nes(marklist) $outsamp
}

proc NesMarkBig {x} {
	global nes
	set xa [expr $x - 1]
	set xb [expr $x + 1]
	set ya $nes(height)
	set yb 0
	$nes(nesnakan) create rect $xa $ya $xb $yb -fill blue -tag "mark mark$x"
}

proc NessZoom {in} {
	global nes evv
	catch {$nes(nesnakan) delete pm}
	catch {s stop}
	if {[info exists nes(lastbox_startsamp)]} {
		NessUnsetLastBox
	}
	if {$in == 1} {
		if {$nes(displen) <= $nes(width)} {
			return
		} elseif {[info exists nes(boxlen)] && ($nes(boxlen) <= $nes(width))} {
			if {$nes(displen) <= $nes(width)} {
				return
			}
		}
		catch {$nes(nesnakan) delete val}
	} else {
		if {$nes(displen) >= $nes(sampdur)} {
			return
		}
		catch {$nes(nesnakan) delete val}
		if {[info exists nes(boxthis)]} {
			set oldboxstart $nes(startsamp)
			set oldboxend $nes(endsamp)
		} else {
			set oldboxstart $nes(dispstart)
			set oldboxend $nes(dispend)
		}
	}
	if {[info exists nes(marklist)]} {
		catch {$nes(nesnakan) delete mark}
		catch {unset nes(markout)}
		catch {unset nes(markthis)}
		catch {unset nes(markx)}
		set washid $nes(hidden)
		NesHideMarkVals 1
		set nes(hidden) $washid
	}
	set centre [expr $nes(displen) / 2]
	set centre [expr $centre + $nes(startsamp)]
	if {$in == 1} {
		if {[info exists nes(boxthis)] && [info exists nes(boxlen)]} {
			set len $nes(boxlen)
			set centre [expr $len / 2]
			set centre [expr $centre + $nes(startsamp)]
			if {$len <= $nes(width)} {
				set len $nes(width)
				set oldboxstart $nes(startsamp)
				set oldboxend $nes(endsamp)
			} else {
				DelNesBox 0
			}
		} else {
			set len [expr $nes(displen) / 4]
			set len [expr ($len / 2) * 2]
			if {$len <= $nes(width)} {
				set len $nes(width)
			}
		}
	} elseif {$in == 2} {
		set len $nes(sampdur)
		set centre [expr $nes(sampdur) / 2]
	} else {
		set len [expr $nes(dispend) - $nes(dispstart)]
		set centre [expr $len / 2]
		set centre [expr $centre + $nes(dispstart)]
		set len [expr $len * 4]
		set len [expr ($len / 2) * 2]
		if {$len >= $nes(sampdur)} {
			set len $nes(sampdur)
			set centre [expr $nes(sampdur) / 2]
		}
	}
	set start [expr $centre - ($len/2)]
	if {$start < 0} {
		set thisstart 0
	} else {
		set thisstart $start
	}
	set thisend [expr $thisstart + $len]
	if {$thisend > $nes(sampdur)} {
		set thisend $nes(sampdur)
		set thisstart [expr $thisend - $len]
	}
	set nes(dispstart) $thisstart
	set nes(dispend) $thisend
	set thisstarttime [expr double($nes(dispstart)) * $nes(inv_sr)]
	set thisendtime   [expr double($nes(dispend))   * $nes(inv_sr)]
	set len [expr $thisendtime - $thisstarttime]
	set nes(displen) [expr $nes(dispend) - $nes(dispstart)]
	if {[info exists oldboxstart]} {
		catch {$nes(nesnakan) delete $nes(boxthis)}
		catch {$nes(nesnakan) delete box}
		catch {unset nes(boxthis)}
	} else {
		set nes(startsamp) $nes(dispstart)
		set nes(endsamp)   $nes(dispend)
		set nes(starttime) $thisstarttime
		set nes(endtime)   $thisendtime
		set nes(starttime_shown) [ShowNessTime $nes(starttime)]
		set nes(endtime_shown)   [ShowNessTime $nes(endtime)]
		set nes(dur) [ShowNessTime [expr $nes(endtime) - $nes(starttime)]]
	}
	catch {$nes(nesnakan) delete pm}
	$nes(nesnakan) create poly -1 -1 -1 -1 -1 -1 -fill red -tags pm
	if {$nes(brktype) == $evv(SN_BRKPNTPAIRS)} {
		if {$nes(hidden)} {
			.nesnak.f6.1.zs config -text "SHOW VALUES" -bd 2 -command {NesHideVals 0}
		} else {
			.nesnak.f6.1.zs config -text "HIDE VALUES" -bd 2 -command {NesHideVals 1}
		}
	} else {
		if {$nes(hidden)} {
			.nesnak.f6.1.zs config -text "SHOW VALUES" -bd 2 -command {NesHideMarkVals 0}
		} else {
			.nesnak.f6.1.zs config -text "HIDE VALUES" -bd 2 -command {NesHideMarkVals 1}
			NesHideMarkVals 0
		}
	}
	if {[info exists oldboxstart]} {
		set k [expr double($oldboxstart - $nes(dispstart))]
		set k [expr $k / double($nes(displen))]
		set k [expr int(round($k * $nes(width)))]
		set nes(boxanchor) [list $k $nes(height)]
		set k [expr double($oldboxend - $nes(dispstart))]
		set k [expr $k / double($nes(displen))]
		set k [expr int(round($k * $nes(width)))]
		set nes(boxend) $k
		set nes(boxthis) [eval {$nes(nesnakan) create rect} $nes(boxanchor) {$nes(boxend) 0 -tag box -outline blue -fill blue -stipple gray12}]
		if {$in != 1} {
			set nes(boxlen) [expr $nes(endsamp) - $nes(startsamp)]
		}
	}
	set nes(brk_local) {}
	set nes(brk_disp) {}
	set nes(localcnt) 0
	foreach {x y} $nes(brk) {
		if {$x >= $nes(dispstart)} {
			if {$x <= $nes(dispend)} {
				lappend nes(brk_local) $x $y
				incr nes(localcnt) 2
			} else {
				set nes(next) [list $x $y]
				break
			}
		} else {
			set nes(previous) [list $x $y]
		}
	}
	set nes(endx) [expr $nes(localcnt) - 2]
	set nes(atzero) 0
	set nes(atend) 0
	set nes(atcanstart) 0
	set nes(atcanend) 0
	if {$nes(localcnt) > 0} {
		if {[lindex $nes(brk_local) 0] == $nes(dispstart)} {
			if {$nes(dispstart) <= 0} {
				set nes(atzero) 1
			}
			set nes(atcanstart) 1
		}
		if {[lindex $nes(brk_local) $nes(endx)] == $nes(dispend)} {
			if {$nes(dispend) >= $nes(sampdur)} {
				set nes(atend) 1
			}
			set nes(atcanend) 1
		}
		foreach {x y} $nes(brk_local) {
			set xa [expr $x - $nes(dispstart)]
			set xa [expr double($xa) / double($nes(displen))]
			set xa [expr int(round($xa * $nes(width)))]
			incr xa $nes(left)
			lappend nes(brk_disp) $xa $y
		}
	}
	set nes(timescale) [expr double($nes(displen)) / double($nes(width))]
	catch {$nes(nesnakan) delete point}
	foreach {x y} $nes(brk_disp) {
		NesCreatePoint $x $y
		if {($nes(brktype) == $evv(SN_BRKPNTPAIRS)) && !$nes(hidden)} {
			NesCreateVal $x $y
		}
	}
	NesDrawLine
	if {$nes(brktype) == $evv(SN_TIMESLIST)} {
		if {[info exists nes(marklist)]} {
			$nes(nesnakan) delete mark
			catch {unset nes(markthis)}
			foreach x $nes(marklist) {
				if {($x >= $nes(dispstart)) && ($x <= $nes(dispend))} {
					set wratio [expr double($x - $nes(dispstart)) / double($nes(displen))]
					set x [expr int(round(double($nes(width)) * $wratio))]
					incr x $nes(left)
					set nes(markthis) [eval {$nes(nesnakan) create line} {$x $nes(height) $x 0 -tag mark -fill blue}]
				}
			}
		}
	}
}

proc NesBoxBegin {x y} {
	global nes evv
	NessUnsetLastBox
	catch {unset nes(boxdrag)}
	set nes(done) 0
	DelNesBox 0
	set nes(boxanchor) [list $x $nes(height)]
	set nes(boxthis) [eval {$nes(nesnakan) create rect} $nes(boxanchor) {$x 0 -tag box -outline blue -fill blue -stipple gray12}]
}

proc NessGetClosest {x y z} {
	global nes
	set mindist $nes(width)
	incr mindist $nes(width)
	set displaylist [$nes(nesnakan) find withtag $z]
	if {![info exists displaylist] || ([llength $displaylist] <= 0)} {
		return -1
	}
	foreach obj $displaylist {
		set coords [$nes(nesnakan) coords $obj]
		set objx [expr round([lindex $coords 0])]
		set thisdist [expr abs($x - $objx)]
		if {$thisdist < $mindist} {
			set mindist $thisdist
			set closest_obj $obj
			set objy [expr round([lindex $coords 1])]
			set thatydist [expr abs($y - $objy)]
		} elseif {$thisdist == $mindist} {
			if {[info exists thisydist]} {
				set objy [expr round([lindex $coords 1])]
				set thisydist [expr abs($y - $objy)]
				if {$thisydist < $thatydist} {
					set thatydist $thisydist
					set closest_obj $obj
				}
			}
		} else {
			catch {unset thisydist}
		}
	}
	return $closest_obj
}

proc DelNesBox {recall} {
	global nes
	if {$recall && [info exists nes(boxthis)] && [info exists nes(boxlen)]} {
		set nes(lastbox_start)    [lindex $nes(boxanchor) 0]
		set nes(lastbox_end)       $nes(boxend)
		set nes(lastbox_startsamp) $nes(startsamp)
		set nes(lastbox_endsamp)   $nes(endsamp)
		set nes(lastbox_starttime) $nes(starttime)
		set nes(lastbox_endtime)   $nes(endtime)
		set nes(lastboxlen)		  $nes(boxlen)
	}
	set nes(startsamp) $nes(dispstart)
	set nes(endsamp) $nes(dispend)
	set nes(starttime) [expr double($nes(startsamp)) * $nes(inv_sr)]
	set nes(endtime)   [expr double($nes(endsamp))   * $nes(inv_sr)]
	set nes(starttime_shown) [ShowNessTime $nes(starttime)]
	set nes(endtime_shown)   [ShowNessTime $nes(endtime)]
	set nes(dur) [ShowNessTime [expr $nes(endtime) - $nes(starttime)]]
	catch {$nes(nesnakan) delete $nes(boxthis)}
	catch {$nes(nesnakan) delete box}
	catch {unset nes(boxlen)}
	catch {unset nes(boxthis)}
}

proc RestoreNesBox {} {
	global nes
	if {[info exists nes(lastbox_startsamp)]} {
		set nes(boxanchor) [list $nes(lastbox_start) $nes(height)]
		set nes(boxend)		$nes(lastbox_end)
		set nes(startsamp)	$nes(lastbox_startsamp)
		set nes(endsamp)		$nes(lastbox_endsamp)
		set nes(starttime)	$nes(lastbox_starttime)
		set nes(endtime)		$nes(lastbox_endtime)
		set nes(boxlen)		$nes(lastboxlen)
		set nes(boxthis) [eval {$nes(nesnakan) create rect} $nes(boxanchor) {$nes(boxend) 0 -tag box -outline blue -fill blue -stipple gray12}]
		NessUnsetLastBox
	}
}

proc NessUnsetLastBox {} {
	global nes
	catch {unset nes(lastbox_start)}
	catch {unset nes(lastbox_end)}
	catch {unset nes(lastbox_startsamp)}
	catch {unset nes(lastbox_endsamp)}
	catch {unset nes(lastbox_starttime)}
	catch {unset nes(lastbox_endtime)}
	catch {unset nes(lastboxlen)}
}

proc NessUnsetBox {} {
	global nes
	catch {unset nes(boxlen)}
	catch {unset nes(boxthis)}
	catch {unset nes(boxanchor)}
	catch {unset nes(boxend)}
	catch {unset nes(boxdrag)}
}

proc NesBoxDrag {x y} {
	global nes evv
	if {![info exists nes(boxanchor)] || $nes(done)} {
		return
	}
	if {($x >= $nes(left)) && ($x <= $nes(right))} {
		catch {$nes(nesnakan) delete $nes(boxthis)}
		set nes(boxthis) [eval {$nes(nesnakan) create rect} $nes(boxanchor) {$x 0 -tag box -outline blue -fill blue -stipple gray12}]
	} else {
		set nes(done) 1
	}
	set nes(boxend) $x
	set nes(boxdrag) 1
	if {$nes(done)} {
		NesBoxSet	
	}
}

proc NesBoxSet {} {
	global nes evv
	if {![info exists nes(boxdrag)]} {
			if {$nes(marked)} {
				NesPointSet move
		}
		return
	}
	if {$nes(boxend) < $nes(left)} {
		set nes(boxend) $nes(left)
	} elseif {$nes(boxend) > $nes(right)} {
		set nes(boxend) $nes(right)
	}
	set stt [lindex $nes(boxanchor) 0]
	if {$nes(boxend) < $stt} {
	    set temp $stt
	    set stt $nes(boxend)
		set nes(boxanchor) [lreplace $nes(boxanchor) 0 0 $stt ]
	    set nes(boxend) $temp
	}
	if {$stt < $nes(left)} {
		set stt $nes(left)
	}
	if {$nes(boxend) > $nes(right)} {
		set nes(boxend) $nes(right)
	}
	if {$nes(boxend) == $stt} {
		DelNesBox 0
		unset nes(boxdrag)
		return
	}
	catch {$nes(nesnakan) delete $nes(boxthis)}
	set nes(boxthis) [eval {$nes(nesnakan) create rect} $nes(boxanchor) {$nes(boxend) 0 -tag box -outline blue -fill blue -stipple gray12}]
	set wratio [expr double($stt - $nes(left)) / double($nes(width))]
	set x [expr int(round(double($nes(displen)) * $wratio))]
	set nes(startsamp) [expr $nes(dispstart) + $x]
	set wratio [expr double($nes(boxend) - $nes(left)) / double($nes(width))]
	set x [expr int(round(double($nes(displen)) * $wratio))]
	set nes(endsamp) [expr $nes(dispstart) + $x]
	set nes(starttime) [expr double($nes(startsamp)) * $nes(inv_sr)]
	set nes(endtime)   [expr double($nes(endsamp))   * $nes(inv_sr)]
	set nes(starttime_shown) [ShowNessTime $nes(starttime)]
	set nes(endtime_shown)   [ShowNessTime $nes(endtime)]
	set nes(dur) [ShowNessTime [expr $nes(endtime) - $nes(starttime)]]
	set nes(boxlen) [expr $nes(endsamp) - $nes(startsamp)]
	unset nes(boxdrag)
}

proc ShowNessTime {time} {
	global nes
	if {$nes(isprof)} {
		set show $time
		append show "mm"
		return $show
	} else {
		set show ""
		if {$time >= 3600} {
			set hrs [expr int(floor($time)) / 3600]
			set time [expr $time - double($hrs * 3600)]
			append show "$hrs h: "
		}
		if {$time >= 60} {
			set mins [expr int(floor($time)) / 60]
			set time [expr $time - double($mins * 60)]
			append show "$mins m: "
		}
		set time [DecPlaces $time 4]
		append show "$time s"
		return $show
	}
}

proc NessScale {on} {
	global nes evv
	catch {$nes(nesnakan) delete scale}
	if {$on} {
		set range [expr $nes(valhi) - $nes(vallo)]
		set stepdata [NesGetStep $range]
		set step [lindex $stepdata 0]
		set scaling [lindex $stepdata 1]
		set scaletext [NessTrimTrailingZeros $nes(vallo)]
		set scbot [expr $nes(height) - $evv(SN_TEXTTRIM)]
		$nes(nesnakan) create text $nes(left)   $scbot -text $scaletext -fill red -anchor w -tag scale
		$nes(nesnakan) create text $nes(centre) $scbot -text $scaletext -fill red -anchor center -tag scale
		$nes(nesnakan) create text $nes(right)  $scbot -text $scaletext -fill red -anchor e -tag scale
		set topval [expr $nes(valhi) * pow(10.0,$scaling)]		
		set botval [expr $nes(vallo) * pow(10.0,$scaling)]				
		set range  [expr $range   * pow(10.0,$scaling)]				
		set thisval [expr $botval + double($step)]
		while {$thisval <= $topval} {
			set thisintval [expr int(floor($thisval))]
			set scaletext [MakeScaleText $thisintval $scaling]
			set y [expr (double($thisintval) - $botval) / double($range)]
			set y [expr int(round($y * $nes(height)))]
			set y [expr $nes(height) - $y]
			if {$y < $evv(SN_TEXTTRIM)} {
				set y $evv(SN_TEXTTRIM)
			} else {
				$nes(nesnakan) create line $nes(scaleleft) $y $nes(scalecleft) $y -fill red -tag scale
				$nes(nesnakan) create line $nes(scalecright) $y $nes(scaleright) $y -fill red -tag scale
			}
			$nes(nesnakan) create text $nes(left) $y -text  $scaletext -fill red -anchor w -tag scale
			$nes(nesnakan) create text $nes(centre) $y -text  $scaletext -fill red -anchor center -tag scale
			$nes(nesnakan) create text $nes(right) $y -text $scaletext -fill red -anchor e -tag scale
			set thisval [expr $thisval + $step]
		}
		.nesnak.f6.1.sf config -text "HIDE SCALE" -bd 2 -command "NessScale 0"
		set nes(scale) 1
	} else {
		.nesnak.f6.1.sf config -text "SEE VAL SCALE" -bd 2 -command "NessScale 1"
		set nes(scale) 0
	}
}

proc NesGetStep {range} {
	set scaling 0
	if {$range > 100.0} {
		while {$range > 100.0} {
			set range [expr $range / 10.0]
			incr scaling -1
		}
	} elseif {$range < 10.0} {
		while {$range < 10.0} {
			set range [expr $range * 10.0]
			incr scaling
		}
	}
	if {$range > 80} {
		set step 10
	} elseif {$range > 50} {
		set step 5
	} elseif {$range > 35} {
		set step 4
	} elseif {$range > 20} {
		set step 2
	} else {
		set step 1
	}
	return [list $step $scaling]
}

proc MakeScaleText {thisintval scaling} {
	if {$scaling > 0} {
		set outval "0."
		set cnt 1
		if {[string length $thisintval] > 1} {
			incr cnt
		}
		while {$cnt < $scaling} {
			append outval "0"
			incr cnt
		}
		append outval $thisintval
		return $outval
	} elseif {$scaling < 0} {
		set scaling [expr -$scaling]
		set cnt 0
		while {$cnt < $scaling} {
			append thisintval "0"
			incr cnt
		}
		return $thisintval
	}
	set thisintval [NessTrimTrailingZeros $thisintval]
	return $thisintval
}

proc NessTrimTrailingZeros {val} {
	set len [string length $val]
	if {($len > 1) && ([string first "." $val] >= 0)} {
		incr len -1
		while {[string match [string index $val $len] "0"]} {
			incr len -1
		}
		if {[string match [string index $val $len] "."]} {
			incr len -1
		}
		set val [string range $val 0 $len]
	}
	return $val
}

proc NesBoxMove {x} {
	global nes
	if {![info exists nes(boxlen)] || ($nes(boxlen) >= $nes(displen))} {
		return
	}
	if {![info exists nes(boxthis)]} {
		return
	}
	set box_start [lindex $nes(boxanchor) 0]
	set left [expr $box_start - $x]
	if {$left < 0} {
		set left [expr -$left]
	}
	set right [expr $nes(boxend) - $x]
	if {$right < 0} {
		set right [expr -$right]
	}
	if {$left < $right} {
		set right 0
	} else {
		set right 1
	}
	if {$right} {
		set newboxstart $nes(endsamp)
		set newboxend	[expr $newboxstart + $nes(boxlen)]

		if {$newboxend > $nes(dispend)} {
			set newboxend $nes(dispend)
		}
	} else {
		set newboxend $nes(startsamp)
		set newboxstart	[expr $nes(startsamp) - $nes(boxlen)]
		if {$newboxstart < $nes(dispstart)} {
			set newboxstart $nes(dispstart)
		}
	}
	if {[expr $newboxend - $newboxstart] <= 1} {
		return
	}
	set nes(startsamp) $newboxstart
	set nes(endsamp) $newboxend
	set nes(starttime) [expr double($nes(startsamp)) * $nes(inv_sr)]
	set nes(endtime)   [expr double($nes(endsamp))   * $nes(inv_sr)]
	set nes(boxlen) [expr $nes(endsamp) - $nes(startsamp)]
	catch {$nes(nesnakan) delete $nes(boxthis)}
	catch {$nes(nesnakan) delete box}
	set k [expr double($nes(startsamp) - $nes(dispstart))]
	set k [expr $k / double($nes(displen))]
	set k [expr int(round($k * $nes(width)))]
	set nes(boxanchor) [list $k $nes(height)]
	set k [expr double($nes(endsamp) - $nes(dispstart))]
	set k [expr $k / double($nes(displen))]
	set k [expr int(round($k * $nes(width)))]
	set nes(boxend) $k
	set nes(boxthis) [eval {$nes(nesnakan) create rect} $nes(boxanchor) {$nes(boxend) 0 -tag box -outline blue -fill blue -stipple gray12}]
}

#--- Convert start of existing playbox to a timemark

proc NessTimeMarkAtPlayBoxStart {} {
	global nes
	if {![info exists nes(boxlen)] || ($nes(boxlen) >= $nes(displen))} {
		return
	}
	if {![info exists nes(boxthis)]} {
		return
	}
	set x [lindex $nes(boxanchor) 0]
	set xx $x
	set nes(markthis) [eval {$nes(nesnakan) create line} {$x $nes(height) $x 0 -tag mark -fill blue}]
	set wratio [expr double($xx - $nes(left)) / double($nes(width))]
	set x [expr int(round(double($nes(displen)) * $wratio))]
	set outsamp [expr $nes(dispstart) + $x]
	lappend nes(marklist) $outsamp
}

#--- Move start of existing playbox to nearest timemark within or before playbox

proc NesBoxToTimeMark {} {
	global nes
	if {![info exists nes(boxlen)] || ($nes(boxlen) >= $nes(displen))} {
		return
	}
	if {![info exists nes(boxthis)]} {
		return
	}
	if {![info exists nes(marklist)]} {
		return
	}
	set x [lindex $nes(boxanchor) 0]

	set kk 0
	foreach mk $nes(marklist) {
		if {($mk >= $nes(dispstart)) && ($mk <= $nes(dispend))} {
			set wratio [expr double($mk - $nes(dispstart)) / double($nes(displen))]
			set mk [expr int(round(double($nes(width)) * $wratio))]
			incr mk $nes(left)
		}
		if {[expr $nes(boxend) - $mk] >= 0} {
			lappend possiblemks $mk
			lappend possiblepos $kk
		}
		incr kk
	}
	if {![info exists possiblemks]} {
		return
	}
	set leastdiff 10000000000
	foreach mk $possiblemks pos $possiblepos {
		set thisdiff [expr abs($x - $mk)]
		if {$thisdiff < $leastdiff} {
			set closemk $mk
			set closepos $pos
			set leastdiff $thisdiff
		}
	}
	if {![info exists closemk]} {
		return
	}
	set nes(startsamp) [lindex $nes(marklist) $closepos]
	set nes(starttime) [expr double($nes(startsamp)) * $nes(inv_sr)]
	set nes(endtime)   [expr double($nes(endsamp))   * $nes(inv_sr)]
	set nes(boxlen) [expr $nes(endsamp) - $nes(startsamp)]
	catch {$nes(nesnakan) delete $nes(boxthis)}
	catch {$nes(nesnakan) delete box}
	set k [expr double($nes(startsamp) - $nes(dispstart))]
	set k [expr $k / double($nes(displen))]
	set k [expr int(round($k * $nes(width)))]
	incr k $nes(left)
	set nes(boxanchor) [list $k $nes(height)]
	set k [expr double($nes(endsamp) - $nes(dispstart))]
	set k [expr $k / double($nes(displen))]
	set k [expr int(round($k * $nes(width)))]
	incr k $nes(left)
	set nes(boxend) $k
	set nes(boxthis) [eval {$nes(nesnakan) create rect} $nes(boxanchor) {$nes(boxend) 0 -tag box -outline blue -fill blue -stipple gray12}]
}

#--- Move end of existing playbox to nearest timemark within or after playbox

proc NesBoxEndToTimeMark {} {
	global nes
	if {![info exists nes(boxlen)] || ($nes(boxlen) >= $nes(displen))} {
		return
	}
	if {![info exists nes(boxthis)]} {
		return
	}
	if {![info exists nes(marklist)]} {
		return
	}
	set x [lindex $nes(boxend) 0]
	set stt [lindex $nes(boxanchor) 0]

	set kk 0
	foreach mk $nes(marklist) {
		if {($mk >= $nes(dispstart)) && ($mk <= $nes(dispend))} {
			set wratio [expr double($mk - $nes(dispstart)) / double($nes(displen))]
			set mk [expr int(round(double($nes(width)) * $wratio))]
		}
		if {[expr $mk - $stt] > 0} {
			lappend possiblemks $mk
			lappend possiblepos $kk
		}
		incr kk
	}
	if {![info exists possiblemks]} {
		return
	}
	set leastdiff 10000000000
	foreach mk $possiblemks pos $possiblepos {
		set thisdiff [expr abs($x - $mk)]
		if {$thisdiff < $leastdiff} {
			set closemk $mk
			set closepos $pos
			set leastdiff $thisdiff
		}
	}
	if {![info exists closemk]} {
		return
	}
	set nes(endsamp) [lindex $nes(marklist) $closepos]
	set nes(endtime) [expr double($nes(endsamp)) * $nes(inv_sr)]
	set nes(starttime)   [expr double($nes(startsamp))   * $nes(inv_sr)]
	set nes(boxlen) [expr $nes(endsamp) - $nes(startsamp)]
	catch {$nes(nesnakan) delete $nes(boxthis)}
	catch {$nes(nesnakan) delete box}
	set k [expr double($nes(startsamp) - $nes(dispstart))]
	set k [expr $k / double($nes(displen))]
	set k [expr int(round($k * $nes(width)))]
	incr k $nes(left)
	set nes(boxanchor) [list $k $nes(height)]
	set k [expr double($nes(endsamp) - $nes(dispstart))]
	set k [expr $k / double($nes(displen))]
	set k [expr int(round($k * $nes(width)))]
	incr k $nes(left)
	set nes(boxend) $k
	set nes(boxthis) [eval {$nes(nesnakan) create rect} $nes(boxanchor) {$nes(boxend) 0 -tag box -outline blue -fill blue -stipple gray12}]
}

#------ Creates the nesnak display
#
# isprof 0 = brkpnt file time-val pairs  1 = dist/radius pairs   2 = timemarks for valves on displayed profile
#

proc NessCreate {typ brktype fnam paramname enable_output dur edit toscale} {
	global evv nes nes_pts neswking nes_other nes_remainder nessparam nesinterp ness_longparamname
	global nes_starty readonlyfg readonlybg nesnak_list big_snack
	global wstk pr_nesnak

	set nes(fnam) [file rootname [file tail $fnam]]
	if {[info exists nesinterp($nes(fnam))]} {
		set nes(interpd) 1
	} else {
		set nes(interpd) 0
	}
	set nes(dointerp) 0
	set nes(paramname) $paramname
	set nes(inv_sr) [expr 1.0 / $nes(CONTROL_SRATE)]		;#	ASSUMED CONVERSION TO 1/1000
	set nes(brktype) $brktype
	set nes(sr) $nes(CONTROL_SRATE)
	set nes(sampdur)  [expr int(round($dur * $nes(sr)))]
	set nes(indur) $dur
	set nes(isprof) $typ					;#	output is brkpnt float , or ALMOST int, or INT
	set nes(to_scale) $toscale
	catch {set nes(valsco)     $neswking(valsco)}
	catch {set nes(vallo)      $neswking(lo)}
	catch {set nes(valhi)      $neswking(hi)}
	catch {set nes(edit)       $edit}

	catch {unset nes(nesnak_list)}

	catch {unset nes(brk)}
	catch {unset nes(brk_local)}
	catch {unset nes(brk_disp)}
	catch {unset nes(previous)}
	catch {unset nes(next)}
	set nes(color) blue
	if {$nes(brktype) == $evv(SN_TIMESLIST)} {
		set nes(color) black
	}
	NessUnsetBox
	catch {unset nes(markout)}
	catch {unset nes(markthis)}
	catch {unset nes(marklist)}

	set nes(width) 1200
	if {$nes(to_scale) > 0} {		;#	Displaying profiles
		catch {destroy .nesnak}
		set aspect_ratio [expr double($nes(valhi)) / double($nes(indur))]
		set nes(height) [expr int(round(double($nes(width)) * $aspect_ratio))]
		if {$big_snack} {
			if {$nes(height) > $nes(BIG_HEIGHT)} {
				set nes(height) $nes(BIG_HEIGHT)
				set nes(width) [expr int(round(double($nes(height)) / $aspect_ratio))]
			}
		} else {
			if {$nes(height) > $nes(SMALL_HEIGHT)} {
				set nes(height) $nes(SMALL_HEIGHT)
				set nes(width) [expr int(round(double($nes(height)) / $aspect_ratio))]
			}
		}
	} else {
		if {$big_snack} {
			set nes(height) $nes(BIG_HEIGHT)
		} else {
			set nes(height) $nes(SMALL_HEIGHT)
		}
	}
	set nes(left) 2
	set nes(right) [expr $nes(width) + $nes(left)]
	set nes(scaleleft)  [expr $nes(left)  + $evv(SN_SCALE_OFFSET)]
	set nes(scaleright) [expr $nes(right) - $evv(SN_SCALE_OFFSET)]
	set nes(centre) [expr ($nes(width) / 2) + $nes(left)]
	set halfoffset [expr $evv(SN_SCALE_OFFSET) / 2]
	set nes(scalecleft)  [expr $nes(centre) - $halfoffset]
	set nes(scalecright) [expr $nes(centre) + $halfoffset]
	set nes(res) -1
	set nes(drag) 0
	set nes(starttime) 0.0
	set nes(endtime) $dur
	set nes(starttime_shown) [ShowNessTime $nes(starttime)]
	set nes(endtime_shown)   [ShowNessTime $nes(endtime)]
	set nes(dur)   [ShowNessTime [expr $nes(endtime) - $nes(starttime)]]
	set nes(startsamp) 0
	set nes(endsamp) $nes(sampdur)

	if {[info exists nes(nesnakan)]} {
		catch {$nes(nesnakan) delete line}
		catch {$nes(nesnakan) delete point}
		catch {$nes(nesnakan) delete val}
		unset nes(nesnakan)
	}
	set f .nesnak
	if [Dlg_Create $f "BRKPNT CONTOUR" "set pr_nesnak 0" -borderwidth 2 -width 80] {
		pack [canvas $f.cnu -height $nes(height) -width [expr $nes(left) + $nes(width)] -background grey]
		set nes(nesnakan) $f.cnu
		frame $f.f0 -height 1 -bg [option get . foreground {}]
		pack $f.f0 -side top -fill x -expand true -pady 6
		if {$nes(brktype) == $evv(SN_BRKPNTPAIRS)} {
			label $f.f1 -text "Click creates point: Control-Click deletes nearest: Command-Click drags nearest : Shift-Click & Drag creates Zoom Box"
		} else {
			label $f.f1 -text "Click creates Mark : Cntrl-Click Deletes Mark : Shift-Click+Drag creates Zoom Box: Command-Cntrl-Click Moves ZB L or R: Control-1 Sets Mark at ZB Start : Control-2 Move ZB Start to Mark : Control-3 Move ZB End to Mark"
		}
		pack $f.f1 -side top
		frame $f.f2 -borderwidth 0
		entry $f.f2.stime -textvariable nes(starttime_shown) -width 16
		label $f.f2.sll -text "Start Time of Selection"
		entry $f.f2.etime -textvariable nes(endtime_shown)   -width 16
		label $f.f2.ell -text "End Time of Selection"
		pack $f.f2.stime $f.f2.sll -side left
		frame $f.f2.1 -borderwidth 0
		radiobutton $f.f2.1.val -text "Drag Value" -variable nes(drag) -value 0 -width 20
		radiobutton $f.f2.1.tim  -text "Drag Time" -variable nes(drag) -value 1 -width 20
		pack $f.f2.1.val $f.f2.1.tim -side left
		pack $f.f2.1 -side left -padx 140
		pack $f.f2.etime $f.f2.ell -side right
		pack $f.f2 -side top -fill x -expand true
		frame $f.f3 -borderwidth 0
		label $f.f3.dll -text "Dur"
		entry $f.f3.dur -textvariable nes(dur)   -width 16
		frame $f.f3.1 -borderwidth 0
		radiobutton $f.f3.1.del -text "Remove Box" -variable nes(res) -value 0 -command "DelNesBox 1; set nes(res) -1"
		radiobutton $f.f3.1.res -text "Restore Box" -variable nes(res) -value 1 -command "RestoreNesBox; set nes(res) -1"
		pack $f.f3.1.del $f.f3.1.res -side left
		pack $f.f3.dll $f.f3.dur -side left -padx 2
		pack $f.f3.1 -side left -padx 70
		frame $f.f3.bel
		button $f.f3.bel.mbel -text "Mark Bell" -command SaveBellValues -bg $evv(EMPH) -highlightbackground [option get . background {}]
		label $f.f3.bel.bll -text "Bell Slope"
		entry $f.f3.bel.bslope -textvariable nes(bellslope) -width 4
		label $f.f3.bel.ud -text "(Use Up/Dn Arrows)"
		pack $f.f3.bel.mbel $f.f3.bel.bll $f.f3.bel.bslope $f.f3.bel.ud -side left -padx 2
		frame $f.f3.interp
		frame $f.f3.interp.1
		frame $f.f3.interp.2
		label $f.f3.interp.1.ii -text "Interpolate"
		radiobutton $f.f3.interp.1.iion -text "Do" -variable nes(dointerp) -value 1 -command "NessInterpolate 0" -width 8
		radiobutton $f.f3.interp.1.iioff -text "Undo" -variable nes(dointerp) -value -1 -command "NessInterpolate 0" -width 8
		pack $f.f3.interp.1.ii $f.f3.interp.1.iion $f.f3.interp.1.iioff -side left -padx 2

		checkbutton $f.f3.interp.2.all -text "all" -variable nes(iiall) -command {NessSetAllInterps 1} -width 7
		checkbutton $f.f3.interp.2.bel -text "bell" -variable nes(iibel) -width 8
		checkbutton $f.f3.interp.2.bor -text "bore" -variable nes(iibor) -width 8
		checkbutton $f.f3.interp.2.mpc -text "mouthpiece" -variable nes(iimpc) -width 14
		pack $f.f3.interp.2.all $f.f3.interp.2.bel $f.f3.interp.2.bor $f.f3.interp.2.mpc -side left

		pack $f.f3.interp.1 $f.f3.interp.2 -side top -anchor w
		pack $f.f3.interp $f.f3.bel -side right -padx 10
		pack $f.f3 -side top -fill x -expand true
		frame $f.f4 -height 1 -bg [option get . foreground {}]
		pack $f.f4 -side top -fill x -expand true -pady 6
		frame $f.f6 -borderwidth 0
		switch -- $enable_output {
			1 {
				button $f.f6.close -text "OUTPUT DATA" -width 12  -command "NesnakOutput 0 $paramname" -bg $evv(EMPH) -highlightbackground [option get . background {}]
				button $f.f6.quit -text "ABANDON"      -width 12  -command "NessAbandon"  -bd 2 -highlightbackground [option get . background {}]
				bind $f <Escape> "set pr_nesnak 0"
				bind $f <Return> "NesnakOutput 0 $paramname"
			}
			0 {
				button $f.f6.close -text "CLOSE" -width 12  -command "set pr_nesnak 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]
				button $f.f6.quit -text "" -command {} -bd 0 -highlightbackground [option get . background {}]
				bind $f <Escape> "set pr_nesnak 0"
				bind $f <Return> "set pr_nesnak 0"
			}
		}
		button $f.f6.help -text "" -command {} -bg [option get . background {}] -bd 0 -width 12 -highlightbackground [option get . background {}]
		frame $f.f6.1 -borderwidth 0
		button $f.f6.1.zi -text "ZOOM IN"  -width 12 -command "NessZoom 1" -highlightbackground [option get . background {}]
		button $f.f6.1.zo -text "ZOOM OUT" -width 12 -command "NessZoom 0" -highlightbackground [option get . background {}]
		button $f.f6.1.fl -text "FULL VIEW" -width 12 -command "NessZoom 2" -highlightbackground [option get . background {}]
		button $f.f6.1.sf -text "SEE VAL SCALE" -width 16 -command "NessScale 1" -highlightbackground [option get . background {}]
		button $f.f6.1.zs -text "SHOW VALUES" -width 16 -command {NesHideVals 0} -highlightbackground [option get . background {}]
		pack $f.f6.1.zi $f.f6.1.zo $f.f6.1.fl -side left -padx 2
		pack $f.f6.1.sf $f.f6.1.zs -side left -padx 2
		pack $f.f6.close $f.f6.quit $f.f6.help -side right -padx 2
		pack $f.f6.1 -side left
		pack $f.f6 -side top -fill x -expand true -pady 4
		set nes(dispstart) $nes(startsamp)
		set nes(dispend)   $nes(endsamp)
		set nes(displen) $nes(sampdur)
		if {$nes(to_scale)} {
			set aspect_ratio [expr double($nes(valhi)) / double($nes(indur))]
			set nes(height) [expr int(round(double($nes(width)) * $aspect_ratio))]
			if {$big_snack} {
				if {$nes(height) > $nes(BIG_HEIGHT)} {
					set nes(height) $nes(BIG_HEIGHT)
					set nes(width) [expr int(round(double($nes(height)) / $aspect_ratio))]
				}
			} else {
				if {$nes(height) > $nes(SMALL_HEIGHT)} {
					set nes(height) $nes(SMALL_HEIGHT)
					set nes(width) [expr int(round(double($nes(height)) / $aspect_ratio))]
				}
			}
		} else {
			if {$big_snack} {
				set nes(height) $nes(BIG_HEIGHT)
			} else {
				set nes(height) $nes(SMALL_HEIGHT)
			}
		}
		$nes(nesnakan) config -height $nes(height)
		catch {$nes(nesnakan) delete pm}
		$nes(nesnakan) create poly -1 -1 -1 -1 -1 -1 -fill red -tags pm
		bind .nesnak <Escape> "set pr_nesnak 0"
		bind .nesnak <Up>   {BellSlope 1 0}
		bind .nesnak <Down> {BellSlope 0 0}
		bind .nesnak <Shift-Up>   {BellSlope 1 1}
		bind .nesnak <Shift-Down> {BellSlope 0 1}
	}
	NessSetAllInterps 0
	switch -- $nes(isprof) {
		0 { 
			if {[IsScoreValveParameter $paramname]} {
				wm title $f "$ness_longparamname($paramname) FOR VALVE $nes(valveopeningdisplaycnt)" 
			} else {
				wm title $f "BRKPNT PROFILE $paramname"
			}
		} 
		1 { 
			if {$edit} {
				wm title $f "BORE PROFILE [file rootname [file tail $fnam]]"
			} else {
				wm title $f "BORE PROFILE"
			}
		} 
		2 {
			if {$edit} {
				wm title $f "VALVE POSITION [file rootname [file tail $fnam]]"
			} else {
				wm title $f "VALVE POSITION"
			}
		}
	}
	if {$paramname == "bore"} {
		if {$nes(to_scale)} {
			$f.f1 config -text ""
			set nes(drag) -1
			$f.f2.1.val config -text "" -state disabled
			$f.f2.1.tim config -text "" -state disabled
			$f.f6.1.sf config -text "" -bd 0 -command {}
			$f.f6.help config -text "" -command {} -bg [option get . background {}] -bd 0
			$f.f3.bel.mbel config -text "" -command {} -bd 0 -bg [option get . background {}]
			$f.f3.bel.bll config -text ""
			$f.f3.bel.bslope config -bd 0 -state disabled -bg [option get . background {}]
			$f.f3.bel.ud config -text ""
			set nes(bellslopebak) $nes(bellslope)
			set nes(bellslope) ""
			$f.f3.interp.1.ii config -text ""
			$f.f3.interp.1.iion config -text "" -state disabled
			$f.f3.interp.1.iioff config -text "" -state disabled
			NessSetAllInterps 0
			$f.f3.interp.2.all config -text "" -state disabled
			$f.f3.interp.2.mpc config -text "" -state disabled
			$f.f3.interp.2.bel config -text "" -state disabled
			$f.f3.interp.2.bor config -text "" -state disabled
		} else {
			$f.f1 config -text "Click creates point: Control-Click deletes nearest: Command-Click drags nearest : Shift-Click & Drag creates Zoom Box"
			$f.f2.1.val config -text "Drag Radius" -state normal
			$f.f2.1.tim config -text "Drag Distance"  -state normal
			$f.f6.1.sf config -text "SEE VAL SCALE" -bd 2 -command "NessScale 1"
			$f.f6.help config -text Help -command "NessGrafixHelp bore" -bg $evv(HELP) -bd 2
			$f.f3.bel.mbel config -text "Mark Bell" -command SaveBellValues -bd 2 -bg $evv(EMPH)
			$f.f3.bel.bll config -text "Bell Slope"
			$f.f3.bel.bslope config -bd 2 -state readonly
			if {[IsNumeric $nes(bellslopebak)]} {
				set nes(bellslope) $nes(bellslopebak)
			} else {
				set nes(bellslope) 2.0
			}
			$f.f3.bel.ud config -text "(Use Up/Dn Arrows)"
			$f.f3.interp.1.ii config -text "Interpolate"
			if {$nes(interpd)} {
				$f.f3.interp.1.iion config  -text "" -state disabled
				$f.f3.interp.1.iioff config -text "" -state disabled
				NessSetAllInterps 0
				$f.f3.interp.2.all config -text "" -state disabled
				$f.f3.interp.2.mpc config -text "" -state disabled
				$f.f3.interp.2.bel config -text "" -state disabled
				$f.f3.interp.2.bor config -text "" -state disabled
			} else {
				$f.f3.interp.1.iion config  -text "Do" -state normal   
				$f.f3.interp.1.iioff config -text ""   -state disabled 
				NessSetAllInterps 0
				$f.f3.interp.2.all config -text "all" -state normal
				$f.f3.interp.2.mpc config -text "mouthpiece" -state normal
				$f.f3.interp.2.bel config -text "bell" -state normal
				$f.f3.interp.2.bor config -text "bore" -state normal
			}
		}
	} else {
		set nes(bellslope) ""
		$f.f3.bel.mbel config -text "" -command {} -bd 0 -bg [option get . background {}]
		$f.f3.bel.bll config -text ""
		$f.f3.bel.bslope config -bd 0 -state disabled -bg [option get . background {}]
		$f.f3.bel.ud config -text ""
		$f.f3.interp.1.ii config -text ""
		$f.f3.interp.1.iion  config -text "" -state disabled
		$f.f3.interp.1.iioff config -text "" -state disabled
		NessSetAllInterps 0
		$f.f3.interp.2.all config -text "" -state disabled
		$f.f3.interp.2.mpc config -text "" -state disabled
		$f.f3.interp.2.bel config -text "" -state disabled
		$f.f3.interp.2.bor config -text "" -state disabled
		if {$nes(brktype) == $evv(SN_TIMESLIST)} {
			set nes(drag) -1
			$f.f1 config -text "Click Marks point: Control-click deletes nearest: Shift-Click & Drag creates Zoom Box"
			$f.f2.1.val config -text "" -state disabled
			$f.f2.1.tim config -text "" -state disabled
			$f.f6.1.sf config -text "" -bd 0 -command {}
			if {$paramname == "vpos"} {
				$f.f6.help config -text Help -command "NessGrafixHelp valves" -bg $evv(HELP) -bd 2
			} else {
				$f.f6.help config -text "" -command {} -bg [option get . background {}] -bd 0
			}
		} else {	;#	SN_BRKPNTPAIRS
			set nes(drag) 0
			$f.f1 config -text "Click creates point: Control-Click deletes nearest: Command-Click drags nearest : Shift-Click & Drag creates Zoom Box"
			$f.f2.1.val config -text "Drag Value" -state normal
			$f.f2.1.tim config -text "Drag Time"  -state normal
			$f.f6.1.sf config -text "SEE VAL SCALE" -bd 2 -command "NessScale 1"
			if {$paramname == "valveopening"} {
				$f.f6.help config -text Help -command "NessGrafixHelp valveopening" -bg $evv(HELP) -bd 2
			} else {
				$f.f6.help config -text Help -command "NessGrafixHelp brkfile" -bg $evv(HELP) -bd 2
			}
		}
	}
	if {$nes(isprof)} {
		$f.f2.sll config -text "Start Position of Selection" -width 27
		$f.f2.ell config -text "End Position of Selection"   -width 25
		if {$nes(brktype) == $evv(SN_BRKPNTPAIRS)} {
			$f.f2.1.val config -text "Drag Radius" -variable nes(drag) -value 0 -width 20
			$f.f2.1.tim config -text "Drag Position" -variable nes(drag) -value 1 -width 20
		}
		$f.f3.dll config -text "Length"
	} else {
		$f.f2.sll config -text "Start Time of Selection" -width 27
		$f.f2.ell config -text "End Time of Selection"   -width 25
		$f.f2.1.val config -text "Drag Value" -variable nes(drag) -value 0 -width 20
		$f.f2.1.tim config -text "Drag Time" -variable nes(drag) -value 1 -width 20
		$f.f3.dll config -text "Duration"
	}
	switch -- $enable_output {
		1 {
			$f.f6.close config -text "OUTPUT DATA" -command "NesnakOutput 0 $paramname" 
			$f.f6.quit config  -text "ABANDON" -command "NessAbandon" -bd 2
			bind $f <Return> "NesnakOutput 0 $paramname"
		}
		0 {
			$f.f6.close config -text "CLOSE" -command "set pr_nesnak 0"
			$f.f6.quit config  -text "" -command {} -bd 0
			bind $f <Return> "set pr_nesnak 0"
		}
	}

	set nes(marked) 0
	set nes(timescale) [expr double($nes(sampdur)) / double($nes(width))]
	set nes(atcanstart) 1
	set nes(atcanend) 1
	if {!$nes(edit)} {
		if {[info exists nes_starty]} {
			if {$nes(paramname) == "bore"} {
				set y [expr $nes(height)/2]
			} else {
				set yratio [expr ($nes_starty - $nes(vallo)) / $nes(valsco)]
				set yratio [expr 1.0 - $yratio]
				set y [expr $nes(height) * $yratio]
			}
			set nes(starty) $y
		}
		set nes(brk) [list 0 $y $nes(sampdur) $y]
		set nes(brk_local) [list 0 $y $nes(sampdur) $y]
		set nes(brk_disp) [list $nes(left) $y $nes(right) $y]
		NesCreatePoint $nes(left) $y
		NesCreatePoint $nes(right) $y
		set nes(localcnt) 4
		set nes(endx) 2
		if {[info exists nes_starty]} {
			NesDrawUnityLine
		} else {
			NesDrawLine
		}
	}
	set nes(atend) 1
	set nes(atzero) 1
	if {$nes(brktype) == $evv(SN_BRKPNTPAIRS)} {
		.nesnak.f6.1.zs config -command {NesHideVals 0}
		if {$nes(to_scale)} {
			bind $nes(nesnakan)	<ButtonPress-1> 		{}
			bind $nes(nesnakan)	<Control-ButtonPress-1> {}
			bind $nes(nesnakan)	<Command-ButtonPress-1> 	{}
			bind $nes(nesnakan)	<Command-B1-Motion> 		{}
			bind $nes(nesnakan)	<Command-ButtonRelease-1>	{}
		} else {
			bind $nes(nesnakan)	<ButtonPress-1> 		{NesPointAdd %x %y}
			bind $nes(nesnakan)	<Control-ButtonPress-1> {NesPointDel %x %y}
			bind $nes(nesnakan)	<Command-ButtonPress-1> 	{NesPointMark %x %y}
			bind $nes(nesnakan)	<Command-B1-Motion> 		{NesPointDrag %x %y}
			bind $nes(nesnakan)	<Command-ButtonRelease-1>	{NesPointSet move; NesValSet}
		}
		bind $nes(nesnakan)	<Shift-ButtonPress-1> 	{NesBoxBegin %x %y}
		bind $nes(nesnakan)	<Shift-B1-Motion> 		{NesBoxDrag %x %y}
		bind $nes(nesnakan)	<Shift-ButtonRelease-1> {NesBoxSet}
		bind $nes(nesnakan)	<ButtonRelease-1>		{NesBoxSet}
		bind .nesnak			<Control-1>					{}
		bind .nesnak			<Control-2>					{}
		bind .nesnak			<Control-3>					{}
	} else {  ;# SN_TIMESLIST
		.nesnak.f6.1.zs config -command {NesHideMarkVals 0}
		set nes(timescale) [expr double($nes(sampdur)) / double($nes(width))]
		bind $nes(nesnakan)	<Shift-ButtonPress-1>	{NesBoxBegin %x %y}
		bind $nes(nesnakan)	<Shift-B1-Motion> 		{NesBoxDrag %x %y}
		bind $nes(nesnakan)	<Shift-ButtonRelease-1>	{NesBoxSet}
		bind $nes(nesnakan)	<ButtonPress-1> 		{NesMark %x}
		bind $nes(nesnakan)	<Command-Control-ButtonPress-1>	{NesBoxMove %x}
		bind .nesnak			<Control-1>					{NessTimeMarkAtPlayBoxStart}
		bind .nesnak			<Control-2>					{NesBoxToTimeMark}
		bind .nesnak			<Control-3>					{NesBoxEndToTimeMark}
		bind $nes(nesnakan)	<Control-ButtonPress-1> {NesMarkDel %x %y}
		bind $nes(nesnakan)	<ButtonRelease-1>		{NesBoxSet}
	}
	set nes(done) 0
	set pr_nesnak 0


	if {$nes(edit)} {
		foreach {x y} $nes_pts {
			set xa [expr int(round($x * $nes(sr)))]
			lappend nuvals $xa $y
		}
		set indx [llength $nuvals]
		incr indx -2
		set endsamp $nes(sampdur)
		set nes(pts) $nuvals
		set endtime [lindex $nuvals $indx]	;#	ENSURE LAST TIME-POINT AT END-EDGE
		if {$endtime != $endsamp} {
			set nuvals [lreplace $nuvals $indx $indx $endsamp]
		}
		catch {unset nes(brk)}
		set nes(pts) $nuvals
		foreach {x y} $nes(pts) {		;#	CONVERT INTO 0-1 VALUE RANGE
			set ya [expr $y - $nes(vallo)]
			set ya [expr double($ya) / double($nes(valsco))]
			lappend nes(brk) $x $ya
		}
		set nes(brk_local) $nes(brk)
										;#	CREATE DISPLAY COORDS 	
		catch {unset nes(brk_disp)}
		foreach {x y} $nes(brk_local) {
			set xa [expr int(round($x / $nes(timescale)))]
			incr xa $nes(left)
			set ya [expr int(round($y * double($nes(height))))]
			set ya [expr $nes(height) - $ya]
			lappend nes(brk_disp) $xa $ya
		}
		set valindx 1
		foreach {x y} $nes(brk_disp) {
			set nes(brk) [lreplace $nes(brk) $valindx $valindx $y]
			set nes(brk_local) [lreplace $nes(brk_local) $valindx $valindx $y]
			incr valindx 2
		}
		set nes(localcnt) [llength $nes(brk_disp)]
		set nes(endx) [expr $nes(localcnt) - 2]
		foreach {x y} $nes(brk_disp) {
			NesCreatePoint $x $y
			NesCreateVal $x $y
		}
		NesDrawLine
		set nes(atcanstart) 1
		set nes(atcanend) 1
		set nes(atzero) 1
		set nes(atend) 1

		if {$nes(to_scale)} {						;#	DRAW VALVES
			if {[info exists nessparam(vpos)]} {
				foreach x $nessparam(vpos) {
					set x [expr $x * $nes(sr)]
					set x [expr double($x) / double($nes(dispend))]
					set x [expr int(round($x * $nes(width)))]
					NesMarkBig $x
				}
			}
		}
	}
	if {$nes(brktype) == $evv(SN_BRKPNTPAIRS)} {
		NesHideVals 1
	} else {
		catch {$nes(nesnakan) delete val} in
	}
	raise $f
	update idletasks
	StandardPosition2 $f

	catch {unset nes(forcequit)}
	My_Grab 0 $f pr_nesnak
	tkwait variable pr_nesnak
	if {($paramname == "valveopening") && ($pr_nesnak == 0)} {
		set nes(forcequit) 1
	}
	if {[info exists nes(nesnak_list)]} {
		set nesnak_list $nes(nesnak_list)
	}
	if {[info exists nes(pts_ibak)]} {
		catch {unset nes(pts_ibak)}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc WriteToBoreData {fnam} {
	global nesnak_list nessprof
	catch {unset nessprof(cdptest)}
	foreach item $nesnak_list {
		set x [lindex $item 0]		
		set y [lindex $item 1]
		lappend nessprof(cdptest) $x $y
	}
	return $nessprof(cdptest)
}

proc WriteValvePositionsData {fnam} {
	global nesnak_list nessparam
	if {[info exists nessparam(vpos)]} {
		set nessparam(vpos) {}
	}
	foreach item $nesnak_list {
		lappend nessparam(vpos) $item
	}
}

proc WriteNessParamData {paramname} {
	global nesnak_list ness_brkdata nessparam
	set nessparam($paramname) {}
	foreach item $nesnak_list {
		set x [lindex $item 0]		
		set y [lindex $item 1]
		lappend nessparam($paramname) $x $y
	}
	return $nessparam($paramname)
}

################## CONVERTING DATA BACK TO MATLAB FORMAT #####################

proc ConvertBrassDataToFileFormat {fnam} {
	global nessparam nessprof nessparamset nesinterp evv nesstype
	set line "%Instrument file"
	lappend lines $line
	set line "global"
	foreach item $nessparamset(ins) {
		append line " $item"
	}
	lappend lines $line
	set line "custominstrument="
	append line $nessparam(custominstrument) ";"
	lappend lines $line
	set line "temperature="
	append line $nessparam(temperature) ";%temperature in C"
	lappend lines $line
	set line "%valve values, assumes that valve is constant cylinder where cross section"
	lappend lines $line
	set line "%in and out of valves is same as point on instrument"
	lappend lines $line
	set line "vpos="
	append line \[
	append line [lindex $nessparam(vpos) 0]
	foreach val [lrange $nessparam(vpos) 1 end] {
		append line ",$val"
	}
	append line \]
	append line ";%position of valve in mm"
	lappend lines $line
	set line "vdl="
	append line \[
	append line [lindex $nessparam(vdl) 0]
	foreach val [lrange $nessparam(vdl) 1 end] {
		append line ",$val"
	}
	append line \]
	append line ";%default tube length mm"
	lappend lines $line

	set line "vbl="
	append line \[
	append line [lindex $nessparam(vbl) 0]
	foreach val [lrange $nessparam(vbl) 1 end] {
		append line ",$val"
	}
	append line \]
	append line ";%bypass tube length mm (will add default length to either side of bypass tubes)"
	lappend lines $line
	set line "%bore in axial position (mm) and diameter(mm) pairs \[x,d\]"
	lappend lines $line
	set line "bore="
	append line \[
	set cnt 0
	set nessprof($fnam) {}
	foreach {x y} $nessprof(cdptest) {
		lappend nessprof($fnam) $x $y
		set y [DecPlaces [expr $y * 2.0] 1]		;#	CONVERT TO DIAMETER
		append line "$x,$y;"
		lappend lines $line
		set line ""
	}
	NessProfileStore
	if {[info exists nesinterp(cdptest)]} {
		set nesinterp($fnam) $nesinterp(cdptest)
		append fnam $evv(NESS_EXT)
		set nesstype($fnam) "i"
		unset nesinterp(cdptest)
		NessInterpStore
	}
	append line \]
	append line ";"
	lappend lines $line
	return $lines
}

#--- Convert interface data to a real brass-instrument score lines

proc ConvertBrassScoreDataToFileFormat {fnam} {
	global nessparam nessparamset evv nesstype nes

	set line global								;#	GLOBAL DECLARATIONS
	foreach nam $nessparamset(sco) {
		append line " $nam"
		if {$nam == "tremamp"} {
			append line " ..."
			lappend lines $line
			set line ""
		}
	}
	lappend lines $line
	lappend lines ""

	foreach nam $nessparamset(sco3) {			;#	DATA IN ORDER REQUIRED IN OUTPUT FILE
		set nnam [string tolower $nam]			;#	Lower case names used for mess parameter names in interface
		switch -- $nam {
			"maxout" -
			"FS" -
			"T" {
				set line $nam					;#	SINGLE VALUES IN SCORE FILE
				append line "=" $nessparam($nnam) ";"
				if {$nam == "FS"} {
					append line "%Sample rate Hz"
				} elseif {$nam == "T"} {
					append line "%Length of score s"
				}
			}
			"instrumentfile" {					;#	IN SCORE FILE, NO FILE EXTENSION, AND QUOTE-MARKS USED
				set line $nam
				append line "=" 
				set val [file rootname $nessparam($nnam)]
				append line "'$val'"
				append line ";"
			}
			"Sr" -
			"mu" -
			"sigma" -
			"H" -
			"w" -
			"pressure" -
			"lip_frequency" -
			"vibamp"   -
			"vibfreq"  -
			"tremamp"  -
			"tremfreq" -
			"noiseamp" {						;#	ALL PARAMETERS TIME-VARIABLE
				if {$nam == "Sr"} {
					set line "%Lip area, mass, damping, equilibrium separation, width"		;#	INSERT EXPLANATIONS AT START
					lappend lines $line
				} elseif {$nam == "pressure"} {
					set line "%mouth pressure pressure as time(s) pressure(Pa) pairs \[t,p\]"
					lappend lines $line
					set line "%assumes that if final time entry is less than length of score pressure"
					lappend lines $line
					set line "%remains the same as final pressure entry"
					lappend lines $line
				} elseif {$nam == "lip_frequency"} {
					set line "%lip frequency as time(s) frequency(Hz) pairs \[t,f\]"
					lappend lines $line
				} elseif {$nam == "vibamp"} {
					set line "%vibrato amplitude and frequency"
					lappend lines $line
				}
				set lenn [llength $nessparam($nnam)]
				set line $nam
				append line "="
				append line \[
				if {$lenn == 1} {				;#	SINGLE VALUE LINES BECOME \[0,val\];
					append line "0,"
					set val $nessparam($nnam)
					if {($val != 0) && (($val > 999) || ($val <0.01))} {
						set val [Engineer $val]
					}
					append line $val 
					append line "\]" 
					append line ";"
					if {$nam == "vibamp"} {												;#	INSERT EXPLANATIONS AT END
						append line "%fraction of normal frequency"
					} elseif {$nam == "vibfreq"} {
						append line "%frequency of vibrato"
					} elseif {$nam == "tremamp"} {
						append line "%fraction of normal mouth pressure"
					} elseif {$nam == "tremfreq"} {
						append line "%frequency of tremolo"
					} elseif {$nam == "noiseamp"} {
						append line "%fraction of normal mouth pressure"
					}
				} else {						;#	PAIRS --> \[time,val\];		LISTS --> \[time1,val1;
					set cnt 0					;#											time2,val2;
					set vals {}					;#											time3,val3\];
					while {$cnt < $lenn} {
						set val [lindex $nessparam($nnam) $cnt]
						if {($val != 0) && (($val > 999) || ($val <0.01))} {
							set val [Engineer $val]
						}
						lappend vals $val
						incr cnt
					}
					set paircnt [expr $cnt/2]
					set endpair [expr $paircnt - 1]
					set cnt 0
					foreach {x y} $vals {
						append line "$x,$y"
						if {$cnt < $endpair} {
							append line ";"
							lappend lines $line
							set line ""
						} else {
							append line \]
							append line ";"
						}
						incr cnt
					}
					if {$nam == "vibamp"} {												;#	INSERT EXPLANATIONS AT END
						append line "%fraction of normal frequency"
					} elseif {$nam == "vibfreq"} {
						append line "%frequency of vibrato"
					} elseif {$nam == "tremamp"} {
						append line "%fraction of normal mouth pressure"
					} elseif {$nam == "tremfreq"} {
						append line "%frequency of tremolo"
					} elseif {$nam == "noiseamp"} {
						append line "%fraction of normal mouth pressure"
					}
				}
			}
			"valveopening" -
			"valvevibfreq" -
			"valvevibamp" {						;#	PARAMETERS CAN HAVE MULTIPLE ENTRIES (>1 VALVES), AND TIME-VARIABLE
				if {$nnam == "valveopening"} {
					set line "%default tube openings(0-1) 1st column time, 2nd-1st valve, 3rd-2nd valve etc"
					lappend lines $line
				}
				set line $nam
				append line "="
				append line \[
				if {[llength $nessparam($nnam)] == 1} {
					append line "0,"
					set c_cnt 1
					while {$c_cnt < $nes(valvecnt)} {
						append line $nessparam($nnam) ","
						incr c_cnt
					}
					append line $nessparam($nnam)
					append line "\]"
					append line ";"
					if {$nam == "valvevibfreq"} {
						append line "%valve vibrato frequency"
					} elseif {$nam == "valvevibamp"} {
						append line "%valve vibrato amplitude"
					}
				} else {
					set vals $nessparam($nnam)
					set lenn [llength $vals]
					set valvcnt [expr $lenn/$nes(valve_events)]
					set tend [expr $nes(valve_events) - 1]
					set vend [expr $valvcnt - 1]
					set valno 0
					set tcnt 0
					while {$tcnt < $nes(valve_events)} {
						set vcnt 0 
						while {$vcnt < $valvcnt} {
							set val [lindex $vals $valno]
							if {($val != 0) && (($val > 999) || ($val <0.01))} {
								set val [Engineer $val]
							}
							incr valno
							if {$vcnt < $vend} {
								append line "$val,"
							} else {
								append line "$val"
							}
							incr vcnt
						}
						if {$tcnt < $tend} {
							append line ";"
							lappend lines $line
							set line ""
						} else {
							append line \]
						}
						incr tcnt
					}
					append line ";"
					if {$nam == "valvevibfreq"} {
						append line "%valve vibrato frequency"
					} elseif {$nam == "valvevibamp"} {
						append line "%valve vibrato amplitude"
					}
				}
			}
		}
		lappend lines $line
	}
	append fnam $evv(NESS_EXT)
	if {[string first $evv(DFLT_OUTNAME) $fnam] < 0} {	;#	Don't store temporary score files
		set nesstype($fnam) "s"
	}
	return $lines
}

#--- Modify Slope of bell

proc BellSlope {up fast} {
	global nes
	if {($nes(paramname) != "bore") || $nes(to_scale)} {
		return
	}
	if {$fast} {
		set in_cr 1.0
	} else {
		set in_cr 0.1
	}
	if {$up} {
		if {$nes(bellslope) < $nes(BELSLOPE_MAX)} {
			set nes(bellslope) [expr $nes(bellslope) + $in_cr]
			if {$nes(bellslope) > $nes(BELSLOPE_MAX)} {
				set nes(bellslope) $nes(BELSLOPE_MAX)
			}
		}
	} else {
		if {$nes(bellslope) > $nes(BELSLOPE_MIN)} {
			set nes(bellslope) [expr $nes(bellslope) - $in_cr]
			if {$nes(bellslope) < $nes(BELSLOPE_MIN)} {
				set nes(bellslope) $nes(BELSLOPE_MIN)
			}
		}
	}
}

#--- Interpolating contour of brass instrument

proc NessInterpolate {abandon} {
	global nes nesinterp wstk evv
	if {!$abandon} {
		switch -- $nes(dointerp) {
			1 {
				if {$nes(localcnt) < [llength $nes(brk)]} {
					NessZoom 2
					DelNesBox 1
					set nes(res) -1
				}
				if {[info exists nesinterp(cdptest)]} {
					Inf "Profile $nes(fnam) has already been interpolated"
					return
				}
				if {!($nes(iibel) || $nes(iibor) || $nes(iimpc))} {
					Inf "No areas selected for interpolation"
					set nes(dointerp) 0
					return
				}
				
				;#	CHECK , IF BELL TO BE INTERPD, THAT BELL PORTION IS MARKED
				
				if {$nes(iibel) || $nes(iibor)} {
					if {![info exists nes(belpoints)]} {
						if {[info exists nes(boxthis)]} {
							Inf "Bell portion not marked"
							.nesnak.f3.bel.mbel config -bg $evv(EMPH)
						} else {
							Inf "Bell portion not drawn on graphic or marked"
						}
						set nes(iibel) 0
						set nes(iibor) 0
						set nes(iimpc) 0
						set nes(dointerp) 0
						return
					} else {
						set startrad [lindex $nes(belpoints) 1]
						set startrad [expr $nes(height) - $startrad]
						set klen [llength $nes(brk)]
						incr klen -1
						set endrad [lindex $nes(brk) $klen]
						set endrad [expr $nes(height) - $endrad]
						if {$endrad <= $startrad} {
							Inf "Bell portion must expand in diameter"
							return
						}	
					}
				}

				;#	BAKUP PRE-INTERP VALS
				
				set nes(pts_ibak) $nes(brk)

				;#	DO ANY MOUTHPIECE INTERPOLATION (remembering mouthpiece end "minpos" for any interior-bore interpolation)

				if {$nes(iimpc) || $nes(iibor)} {

					;#	Find (1st) narrowest bore after start

					set mpclen 0
					set minpos 0
					set sttrad [lindex $nes(brk) 1]
					set sttrad [expr $nes(height) - $sttrad]
					set lastrad $sttrad
					set endrad $sttrad
					set cnt 2
					foreach {x y} [lrange $nes(brk) 2 end] {
						set rad [expr $nes(height) - $y]
						if {$rad < $endrad} {
							set mpclen $x
							set endrad $rad
							set minpos $cnt
						}
						set lastrad $rad
						incr cnt 2
					}
					if {$minpos == 0} {
						Inf "No viable mouthpiece section indicated"
						return
					}
					if {$nes(iimpc)} {

					;#	Interpolate Mouthpiece (cosinusoidal) up to narrowest point
	
						if {$nes(iibel)} {
							if {$nes(prebelend) < $minpos} {
								Inf "Bell start incompatible with mouthpiece end"
								return
							}
						}
						set prelen [llength $nes(brk)]
						set afterpts [lrange $nes(brk) $minpos end]
						catch {unset mpcpnts}
						set narrowing [expr $sttrad - $endrad]
						set intpcnt [expr int(ceil($mpclen/($nes(CONTROL_SRATE) * $nes(INTERP_HIRES))))]
						set n 0
						while {$n < $intpcnt} {
							set frac [expr (double($n)/double($intpcnt))]	;#	Range 0 to 1
							set x [expr $frac * $mpclen]					;#	Range 0 to mpclen
							set frac [expr $frac * $evv(PI)]				;#	Range 0 to PI
							set frac [expr (cos($frac) + 1.0)/2.0]			;#	--> Range -1 to 1 --> 0 to 2 --> 0 to 1
							set rad [expr $frac * $narrowing]				;#	Range 0 to narrowing
							set rad [expr $rad + $endrad]					;#	Range endrad to startrad
							set y [expr $nes(height) - $rad]				;#	y coords are upside-down
							lappend mpcpnts $x $y
							incr n
						}
						set nes(brk) [concat $mpcpnts $afterpts]
						set postlen [llength $nes(brk)]
						set expansion [expr $postlen - $prelen]
						incr minpos $expansion 
						catch {incr nes(prebelend) $expansion}
						catch {incr nes(prebelx) $expansion}
						catch {incr nes(prebely) $expansion}

					}
				}

				;#	DO ANY BELL INTERPOLATION

				if {$nes(iibel)} {

					;#	Interpolate Bell (power slope)

					.nesnak.f3.bel.mbel config -bg [option get . background {}]

					;#	Gradient = (y - lasty)/(x - lastx)
					;#	NB Because y coord is 0 at TOP, y distance for gradient is NOT (y - lasty)
					;#	BUT (height - y) - (height - lasty) = lasty - y
					;#	So Gradient = (lasty - y)/(x - lastx)

					set bellstart [lindex $nes(belpoints) 0]
					set startrad  [lindex $nes(belpoints) 1]
					set len [llength $nes(belpoints)]
					incr len -2
					set bellend	 [lindex $nes(belpoints) $len]
					incr len 1
					set endrad   [lindex $nes(belpoints) $len]
					set bellen [expr $bellend - $bellstart]
					set intpcnt [expr $bellen/($nes(CONTROL_SRATE) * $nes(INTERP_RES))]
					set bellwiden [expr $startrad - $endrad]	;#	Upside down because display coords are ZERO at TOP

					set lastgrad [expr double($nes(prebely) - $startrad)/double($bellstart - $nes(prebelx))]

					;#		on a gradient line from 0 to 1, at point n of N
					;#		ystart, yend are (n-1)/N and n/N		(N = intpcnt)
					;#		With pow factor
					;#		ystart, yend are pow((n-1)/N,powval) and pow(n/N,powval)
					;#		ystepup = pow(n/N,powval) - pow((n-1)/N,powval)
					;#		realystepup = ystepup * bellwiden
					;#		distance moved is 1/N of the bellen = bellen/N
					;#		so grad = (ystepup * bellwiden)/(bellen/N)
					;#		so grad = ystepup * ((N * bellwiden)/bellen)
					;#		Let aspectratio = ((N * bellwiden)/bellen)
					;#		set grad = ystepup * aspectratio

					set n 1
					set lastratio 0
					set aspectratio [expr (double($bellwiden)/double($bellen))]
					set aspectratio [expr $aspectratio * $intpcnt]

					set lastdist [expr [lindex $nes(belpoints) 0] - $nes(prebelx)]
					set lastwidn [expr [lindex $nes(belpoints) 1] - $nes(prebely)]
					set lastgrad [expr double($lastwidn)/double($lastdist)]
					set len [llength $nes(belpoints)]
					incr len -2
					set thisdist [expr [lindex $nes(belpoints) $len] - [lindex $nes(belpoints) 0]]
					incr len
					set thiswidn [expr [lindex $nes(belpoints) $len] - [lindex $nes(belpoints) 1]]
					set thisgrad [expr double($thiswidn)/double($thisdist)]
					if {$lastgrad < $thisgrad} {		;#	Cannot use arc
						Inf "Impossible start gradient for bell of this length : starting bell with level bore"
						set n 0
					} elseif {$nes(iibor)} {
						set n 0							;#	Splining makes gradient before bell zero
					} elseif {$lastgrad > 0.0} {
						set n 0							;#	Prevent bell-start narrowing
					} else {
					#	Find the place on power curve where it becomes equal to the pre-bell gradient

						set lastgrad [expr -$lastgrad]
						while {$n <= $intpcnt} {
							set thisratio [expr double($n)/double($intpcnt)]
							set ystepup [expr pow($thisratio,$nes(bellslope))]
							set ystepup [expr $ystepup - pow($lastratio,$nes(bellslope))]
							set thisgrad [expr $ystepup * $aspectratio]
							if {$thisgrad >= $lastgrad} {
								incr n -1
								break
							}
							set lastratio $thisratio
							incr n
						}
					}	

					if {$n > $intpcnt} {		;#	SAFETY
						set n 0
					}

					if {$n == 0} {
						set newbellwiden $bellwiden
						set newbellen $bellen
						set newbellstart $bellstart
						set newintpcnt $intpcnt
					} else {

					;#	Scale the arc-portion found into the bellen, bellwiden area

						set expansionratio [expr double($intpcnt)/double($intpcnt - $n)]
						set newbellwiden [expr $bellwiden * $expansionratio]
						set newbellen	 [expr $bellen * $expansionratio]
						set newbellstart [expr $bellend - $newbellen]
						set newintpcnt  [expr int(round($intpcnt * $expansionratio))]
					}
					set dobreak 0
					set n [expr $newintpcnt - $intpcnt]
					set lastx $newbellstart		;#	KLUDGE

														;#	Calculate position of First point in new arc
														;#	and adjust params if it doesn't exactly correspond to true first point

					set thisratio [expr double($n)/double($newintpcnt)]
					set y [expr pow($thisratio,$nes(bellslope))]
					set y [expr $y * $newbellwiden]
					set y [expr $startrad - $y]			;#	-ve, as y coord is ZERO at TOP
					if {![Flteq $y $startrad]} {				
						set adjustment [expr double($startrad)/$y]
						set newbellwiden [expr $newbellwiden * $adjustment]
					}

					while {$n < $newintpcnt} {
						set thisratio [expr double($n)/double($newintpcnt)]
						set x [expr $thisratio * $newbellen]
						set x [expr $x + $newbellstart]
						if {$x >= $bellend} {
							so dobreak1
						}
						set y [expr pow($thisratio,$nes(bellslope))]
						set y [expr $y * $newbellwiden]
						set y [expr $startrad - $y]			;#	-ve, as y coord is ZERO at TOP
						set lastratio $thisratio
						if {($y < 0) || $dobreak} {
							break
						}
						lappend nubelpoints $x $y 
						set lastx $x
						incr n
					}

					;#	If there's a mismatch at the preiphery, rescale values

					if {$y < 0} {
						set adjust [expr double($bellen)/double($lastx - $bellstart)]
						foreach {x y} $nubelpoints {
							set x [expr $x - $bellstart]
							set x [expr $x * $adjust]
							set x [expr $x + $bellstart]
							lappend kk $x $y
						}
						set nubelpoints $kk
					}

					;#	Add final point at display top corner

					lappend nubelpoints $bellend $endrad
					set nes(brk) [concat [lrange $nes(brk) 0 $nes(prebelend)] $nubelpoints] 		

				}

				;#	DO ANY INTERIOR BORE INTERPOLATION

				if {$nes(iibor)} {

					if {![info exists nes(belpoints)]} {
						if {[info exists nes(boxthis)]} {
							Inf "Bell portion not marked"
							.nesnak.f3.bel.mbel config -bg $evv(EMPH)
						} else {
							Inf "Bell portion not drawn on graphic or marked"
						}
						set nes(dointerp) 0
						return
					}
					set thebell [lindex $nes(belpoints) 0]
					set len 0
					foreach {x y} $nes(brk) {
						if {$x >= $thebell} {
							set thisend [expr $len + 1]
							break
						}
						incr len 2
					}

					;#	Search (recursively) for any internal narrowings, starting at "minpos"
																;#													(prepos) (postpos)
					set m $minpos								;#	Pointer to previous entry pair.			NB  Q		K	   N
																;#	k (NOT USED) indicates pre-last pair.        *	  *  *    *
					set j [expr $minpos - 2]					;#	j indicates pre-pre-last pair.		 preslope *  *    *  *
					set q [expr $minpos - 4]					;#	q indicates pre-pre-pre-last pair.		OR	    J		M (Bore narrows)
					incr minpos									;#										 preslope *(preprepos)	
					set lasty [lindex $nes(brk) $minpos]		;#												 * (initial minpos)
					set lastrad [expr $nes(height) - $lasty]	;#	Last bore								    Q
					incr minpos

					catch {unset splinelist}
					foreach {x y} [lrange $nes(brk) $minpos [expr $thisend + 2]] {
						set rad [expr $nes(height) - $y]
						if {$rad < $lastrad} {					;#	If bore narrows
							if {![info exists splinstt]} {		;#	If this is 1st narrowing (locally)
								set splinstt $j					;#	Mark start of section to spline, as point 2 before this (preprepoint)
								if {$q < 0} {
									set preslope 0
								} else {
									set preprepos [lindex $nes(brk) $j]
									incr j
									set preprerad [expr $nes(height) - [lindex $nes(brk) $j]]
									incr j -1
									set prepreprepos [lindex $nes(brk) $q]
									incr q
									set prepreprerad [expr $nes(height) - [lindex $nes(brk) $q]]
									incr q -1
									set radchange [expr double($preprerad) - double($prepreprerad)]
									if {$radchange < 0} {
										set preslope 0				;#	Don't allow spline to start-off with downward (narrowing bore) slope
									} else {
										set radchangelen [expr double($preprepos) - double($prepreprepos)]
										set radchangelen [expr $radchangelen / double($nes(CONTROL_SRATE))]
										set preslope [expr $radchange/$radchangelen]
									}
								}
							}
						} elseif {[info exists splinstt]} {						;#	If bore is same or increasing at end of a splinable segment.
							if {![info exists splinelist]} {					;#	Mark its end
								lappend splinelist $splinstt $m					;#	preslope    spline	postslope
								set nes(preslope) $preslope						;#     -----____________-----  
																				;# 	   *   *   *   *   *   *
							} else {											;#        stt          x
								set splinelist [lreplace $splinelist 1 1 $m]	
							}													
							unset splinstt
						}
						set lastrad $rad
						incr m 2
						incr j 2
						incr q 2
					}
				
					if {[info exists splinelist]} {
						incr thisend -1
						set splinelist [lreplace $splinelist 1 1 $thisend]		;#	Force spline to start of bell

						set thispos [lindex $nes(brk) $thisend]					;#	Find slope of start of bell
						incr thisend
						set thisrad [expr $nes(height) - [lindex $nes(brk) $thisend]]
						incr thisend
						set postpos [lindex $nes(brk) $thisend]
						incr thisend
						set postrad [expr $nes(height) - [lindex $nes(brk) $thisend]]
						set radchange [expr double($postrad) - double($thisrad)]
						set radchangelen [expr double($postpos) - double($thispos)]
						set radchangelen [expr $radchangelen / double($nes(CONTROL_SRATE))]
						set nes(postslope) [expr $radchange/$radchangelen]

					;#	Do splines

						set x [lindex $splinelist 0]
						set y [lindex $splinelist 1]
						set csplinelist [DoSplines $x $y $nes(preslope) $nes(postslope)]

					;#	Insert into nes(brk)

						set len [llength $nes(brk)]
						set prestart [expr $x - 1]		;#	End of brk prior to insertion
						set postend  [expr $y + 2]		;#	Start of brk after insertion
						set prebrk  [lrange $nes(brk) 0 $prestart]
						if {$postend >= $len} {
							set postbrk {}
						} else {
							set postbrk [lrange $nes(brk) $postend end]
						}
						set nes(brk) [concat $prebrk $csplinelist $postbrk]

					} else {

						set nes(iibor) 0
						if {!($nes(iimpc) && $nes(iibel))} {	;#	If we're ONLY doing a central bore interp
							Inf "No kinks to smooth in central bore"
							set nes(dointerp) 0
							return
						}
					}


				}

				;#	Calculate corresponding nex(pts) and nes(disp) (latter so we can calc and display values)

				catch {unset nes(pts)}

				foreach {x y} $nes(brk) {		;#	CONVERT x TO REAL VALUE RANGE
					set ya [expr $nes(height) - $y]
					set ya [expr double($ya)/double($nes(height))]
					set ya [expr $ya * $nes(valsco)]
					set ya [DecPlaces [expr $ya + $nes(vallo)] 1]
					lappend nes(pts) $x $ya
				}
				RefreshNesGrafix

				.nesnak.f3.interp.1.iioff config -state normal -text "Undo"
				.nesnak.f3.interp.1.iion config -state disabled -text ""
					NessSetAllInterps 0
				.nesnak.f3.interp.2.all config -text "" -state disabled
				.nesnak.f3.interp.2.mpc config -text "" -state disabled
				.nesnak.f3.interp.2.bel config -text "" -state disabled
				.nesnak.f3.interp.2.bor config -text "" -state disabled
				set nesinterp(cdptest) 1
			}
			-1 {
				if {![info exists nes(pts_ibak)]} {
					Inf "Cannot restore the pre-interpolated profile"
					return
				}
				set nes(brk) $nes(pts_ibak)
				unset nes(pts_ibak)
				.nesnak.f3.interp.1.iion config -state normal -text "Do"
				.nesnak.f3.interp.1.iioff config -state disabled -text ""
				NessSetAllInterps 0
				.nesnak.f3.interp.2.all config -text "all" -state normal
				.nesnak.f3.interp.2.mpc config -text "mouthpiece" -state normal
				.nesnak.f3.interp.2.bel config -text "bell" -state normal
				.nesnak.f3.interp.2.bor config -text "bore" -state normal
				RefreshNesGrafix
				set nes(dointerp) 0
				catch {unset nesinterp(cdptest)}
				if {[info exists nes(belpoints)]} {
					catch {unset nes(belpoints)}
					catch {unset nes(prebelend)}
					catch {unset nes(prebelx)}
					catch {unset nes(prebely)}
					.nesnak.f3.bel.mbel config -bg $evv(EMPH)
				}
				if {[llength [array names nesinterp]] <= 0} {
					unset nesinterp
				}
			}
		} 
	} else {
		if {![info exists nes(pts_ibak)]} {
			Inf "Cannot restore the pre-interpolated profile"
			return
		}
		set nes(brk) $nes(pts_ibak)
		unset nes(pts_ibak)
		.nesnak.f3.interp.1.iion  config -state normal -text "Do"
		.nesnak.f3.interp.1.iioff config -state disabled -text ""
		NessSetAllInterps 0
		.nesnak.f3.interp.2.all config -text "all" -state normal
		.nesnak.f3.interp.2.mpc config -text "mouthpiece" -state normal
		.nesnak.f3.interp.2.bel config -text "bell" -state normal
		.nesnak.f3.interp.2.bor config -text "bore" -state normal
		RefreshNesGrafix
		set nes(dointerp) 0
		if {[info exists nes(belpoints)]} {
			catch {unset nes(belpoints)}
			catch {unset nes(prebelend)}
			catch {unset nes(prebelx)}
			catch {unset nes(prebely)}
			.nesnak.f3.bel.mbel config -bg $evv(EMPH)
		}
		catch {unset nesinterp(cdptest)}
		if {[llength [array names nesinterp]] <= 0} {
			unset nesinterp
		}
	}
}

#--- Redraw Ness Grafix after "Undo Interp"

proc RefreshNesGrafix {} {
	global nes
	set nes(hidden) 1
	NessZoom 2								;#	Restore unzoomed view
	NessScale 0								;#	Remove any scale display
	NesHideVals 1							;#	Get rid of all numeric-displays of values
	if {[info exists nes(marklist)]} {
		NesHideMarkVals 1
	}
	catch {$nes(nesnakan) delete line}		;#	Delete all lines, points and zoom-boxes
	catch {$nes(nesnakan) delete point}
	catch {$nes(nesnakan) delete box}
	catch {$nes(nesnakan) delete $nes(boxthis)}
	catch {$nes(nesnakan) delete box}
	catch {unset nes(boxlen)}
	catch {unset nes(boxthis)}
	NessUnsetBox

	set nes(startsamp) 0
	set nes(endsamp) $nes(sampdur)
	set nes(starttime) [expr double($nes(startsamp)) * $nes(inv_sr)]
	set nes(endtime)   [expr double($nes(endsamp))   * $nes(inv_sr)]
	set nes(starttime_shown) [ShowNessTime $nes(starttime)]
	set nes(endtime_shown)   [ShowNessTime $nes(endtime)]

	;#	REDRAW PROFILE

	set nes(brk_local) $nes(brk)
	set nes(timescale) [expr double($nes(sampdur)) / double($nes(width))]
								;#	CREATE DISPLAY COORDS 	
	catch {unset nes(brk_disp)}
	foreach {x y} $nes(brk_local) {
		set xa [expr int(round($x / $nes(timescale)))]
		incr xa $nes(left)
		lappend nes(brk_disp) $xa $y
	}
	set nes(localcnt) [llength $nes(brk_disp)]
	set nes(endx) [expr $nes(localcnt) - 2]
	foreach {x y} $nes(brk_disp) {
		NesCreatePoint $x $y
	}
	NesDrawLine
	set nes(atcanstart) 1
	set nes(atcanend) 1
	set nes(atzero) 1
	set nes(atend) 1

	catch {unset nes(nesnak_list)}	;#	Probably redundant
}

#--- Save part of profile which marked as the bell

proc SaveBellValues {} {
	global nes

	if {![info exists nes(boxanchor)]} {
		Inf "No zoom box drawn"
		return
	}
	if {$nes(localcnt) != [llength $nes(brk)]} {
		Inf "Return to full view first"
		NessZoom 2
		DelNesBox 1
		set nes(res) -1
	}
	.nesnak.f3.bel.mbel config -bg [option get . background {}]

	catch {unset nes(belpoints)}
	set belstart [lindex $nes(boxanchor) 0]
	set belstart [expr double($belstart)/double($nes(width))]
	set belstart [expr int(round($belstart * $nes(displen)))]
	set cnt 0
	foreach {x y} $nes(brk) {
		if {$x > $belstart} {
			lappend nes(belpoints) $x $y
		} else {
			set endcnt $cnt
			set lastx $x
			set lasty $y
		}
		incr cnt 2
	}
	if {![info exists nes(belpoints)]} {
		Inf "No bell points captured"
	} else {
		Inf "Bell marked"
	}
	incr endcnt 1
	set nes(prebelend) $endcnt
	set nes(prebelx) $lastx
	set nes(prebely) $lasty
}

#--- Set all interpolation checkbuttons ON

proc NessSetAllInterps {seton} {
	global nes
	if {$seton} {
		set nes(iimpc) 1
		set nes(iibel) 1
		set nes(iibor) 1
		set nes(iiall) 0
	} else {
		set nes(iimpc) 0
		set nes(iibel) 0
		set nes(iibor) 0
		set nes(iiall) 0
	}
}

#---- Do Cubic splining

proc DoCubicSpline {stt endd preslope postslope} {
	global nes
	set secondderivs [GetSecondDerivatives $stt $endd $preslope $postslope]

	set outx [lindex $nes(brk) $stt]							;#	Start value of interpolation set
	set outx [expr $outx/$nes(CONTROL_SRATE)]
	set endx [lindex $nes(brk) $endd]							;#	Limit value of interpolation set
	set endx [expr $endx /$nes(CONTROL_SRATE)]
	set brkvals [lrange $nes(brk) $stt [expr $endd + 1]]		;#	Get the segment of nes(brk) to be splined

	set intpinc $nes(INTERP_RES)								;#	set incr at 2mm

	set len [llength $secondderivs]								;#	Number of secondderivs, and of pairs in brktable
	catch {unset nes(klo)}										;#	Initialise klo

	foreach {x y} $brkvals {
		set x [expr double($x) / double($nes(CONTROL_SRATE))]
		set y [expr $nes(height) - $y]							;#	Invert y params (as display is inverted)
		lappend nubrkvals $x $y
	}
	set brkvals $nubrkvals								

	while {$outx < $endx} {
		set outy [Splint $brkvals $secondderivs $len $outx]
		set x [expr $outx * $nes(CONTROL_SRATE)]
		set y [expr $nes(height) - $outy]
		if {($y < 0) || ($y > $nes(height))} {
			if {![info exists nes(spline_warning)]} {
				Inf "Cubic spline between some points too extreme"
				set nes(spline_warning) 1
			}
			set splinevals {}
			set thisindx $stt 
			while {$thisindx < $endd} {
				lappend splinevals [lindex $nes(brk) $thisindx]
				incr thisindx
				lappend splinevals [lindex $nes(brk) $thisindx]
				incr thisindx
			}
			return {}
		}
		lappend splinevals $x $y								;#	Convert back to inverted display frame
		set outx [expr $outx + $intpinc]
	}
	return $splinevals
}

#--- Use 2nd derivatives to do cubic spline interpolation

proc Splint {brkpnts secondderivs len xout} {
	global nes
	if {![info exists nes(klo)]} {
		set nes(klo) 0
	}
	set klo $nes(klo)
	set khi $klo			
	incr khi						;#	Next point in brktable
	set tabindex [expr $khi * 2]	;#	Position of pair in brktable
	while {$khi < $len} {
		set xhi [lindex $brkpnts $tabindex]
		if {$xhi > $xout} {
			break
		} else {
			incr klo
			incr tabindex 2
		}
		incr khi
	}
	incr tabindex
	set yhi [lindex $brkpnts $tabindex]
	set tabindexlo [expr $klo * 2]
	set xlo [lindex $brkpnts $tabindexlo]
	incr tabindexlo 
	set ylo [lindex $brkpnts $tabindexlo]
	set diff [expr double($xhi) - double($xlo)]
	set a   [expr (double($xhi) - double($xout))/$diff]
	set b   [expr (double($xout) - double($xlo))/$diff]
	set yout [expr ($a * $ylo) + ($b * $yhi)]
	set kk [expr (($a * $a * $a) - $a) * [lindex $secondderivs $klo]]
	set jj [expr (($b * $b * $b) - $b) * [lindex $secondderivs $khi]]
	set kk [expr (($kk + $jj) * $diff * $diff)/6.0]
	set yout [expr $yout + $kk]
	set nes(klo) $klo
	return $yout
}

#----- Calcualte 2nd dervatives for cubic-spline calculations

proc GetSecondDerivatives {stt endd preslope postslope} {
	global nes
	;#	Slope at start and end defined to be zero

	set brkvals [lrange $nes(brk) $stt [expr $endd + 1]]	;#	Points to spline
	set len [expr [llength $brkvals]/2]
	set len_less_one [expr $len - 1]	;#	Number of points to be splined, except last

	foreach {x y} $brkvals {
		set x [expr double($x) / double($nes(CONTROL_SRATE))]
		set y [expr $nes(height) - $y]
		lappend nubrkvals $x $y
	}
	set brkvals $nubrkvals
	set brkcnt 0								;#	brkcnt = counter in nes(brk)
	set prepos [lindex $brkvals $brkcnt]
	incr brkcnt									;#	brkcnt 1+2 correspond to point = 0
	set preval [lindex $brkvals $brkcnt]
	incr brkcnt
	set pos [lindex $brkvals $brkcnt]
	incr brkcnt									;#	brkcnt 3+4 correspond to point = 1
	set val [lindex $brkvals $brkcnt]
	incr brkcnt									;#	brkcnt now = 4 (pointing to brkvals for point 2)
												;#	NB In loop pointcnt starts at 1, so brkcnt starts out pointing to point 2

												;#	Establish steps between values and positions

	set preposstep [expr double($pos) - double($prepos)]		;#	distance-step from prior-point to point
	set prevalstep [expr double($val) - double($preval)]		;#	radius-step from prior-point to point

	set lasty2 [expr -0.5]						;#	Set 2nd deriv at point 0 (Loop starts at point 1, so this LAST y2)
	set y2 $lasty2								;#	Assemble initial 2nd deriv vals in list "y2"
	set lastu [expr 3/$preposstep]
	set kk  [expr ($prevalstep/$preposstep) - $preslope]
	set lastu [expr $lastu * $kk]
	set u $lastu								;#	Assemble scaling factors in list "u"

	set pointcnt 1								;#	pointcnt = counter of points = val-pairs in brkvals, counts from 1 to len-1
	while {$pointcnt < $len_less_one} {			;#	brkcnt starts pointing to point 2 and therefore gets brkvals for points 2 to len
		set postpos [lindex $brkvals $brkcnt]
		incr brkcnt								;#	Get point ahead
		set postval [lindex $brkvals $brkcnt]
		incr brkcnt
		set bigstep [expr double($postpos) - double($prepos)]	;#	distance-step from prior-point to ahead-point
		set postposstep [expr double($postpos) - double($pos)]	;#	distance-step from point to ahead-point
		set postvalstep [expr double($postval) - double($val)]	;#	radius-step from point to ahead-point
		set sig [expr $preposstep/$bigstep]
		set p [expr ($sig * $lasty2) + 2.0]
		set thisy2 [expr ($sig - 1.0)/$p]
		lappend y2 $thisy2						;#	Continue to assemble initial 2nd deriv vals in list "y2"
		set lasty2 $thisy2
		set thisu [expr ($postvalstep/$postposstep) - ($prevalstep/$preposstep)]
		set thisu [expr ((6.0 * $thisu)/$bigstep) - ($sig * $lastu)]
		set thisu [expr $thisu/$p]
		lappend u $thisu						;#	Continue to assemble "u" components in list "u"
												;#	Cascade values and positions
		set lastu $thisu
		set preval $val
		set prepos $pos
		set val $postval
		set pos $postpos
		set preposstep $postposstep
		set prevalstep $postvalstep
		incr pointcnt
	}
	set qn 0.5									;#	Set 2nd deriv at end
	set thisu [expr 3.0 / $preposstep]
	set kk [expr $postslope - ($prevalstep/$preposstep)]
	set thisu [expr $thisu * $kk]
	lappend u $thisu							;#	Finish assembling scaling factors in list "u"

	set thisy2 [expr $thisu - ($qn * $lastu)]		
	set kk [expr ($qn * $lasty2) + 1.0]			;#	Generate end derivative
	set thisy2 [expr $thisy2/$kk]
	lappend y2 $thisy2							;#	Finish assembling initial 2nd deriv vals in list "y2"

												;#	Loop back through derivs doing final calcs with scaling factor "u"
	set nextpointcnt $len_less_one				;#	Points to y2 value above current = nexty2 = end of list of values
	set pointcnt [expr $len_less_one - 1]		;#	Points to current y2 value = thisy2 = 1 below end of list of values
	while {$pointcnt >= 0} {
		set thisu  [lindex $u $pointcnt]
		set thisy2 [lindex $y2 $pointcnt]
		set nexty2 [lindex $y2 $nextpointcnt]
		set thisy2 [expr ($thisy2 * $nexty2) + $thisu]
		set y2 [lreplace $y2 $pointcnt $pointcnt $thisy2]
		incr pointcnt -1
		incr nextpointcnt -1
	}
	return $y2
}

#--- Decide what kind of splines needed, and do them

proc DoSplines {sttindx endindx preslope postslope} {
	global nes

	;#	find how the line moves

	set thisindx $sttindx
	while {$thisindx <= $endindx} {
		set startrad [expr $nes(height) - [lindex $nes(brk) [expr $thisindx + 1]]]
		if {$thisindx > $sttindx} {
			if {$lastrad > $startrad} {
				lappend grads -1
			} elseif {$lastrad == $startrad} {
				lappend grads 0
			} else {
				lappend grads 1
			}
		}
		incr thisindx 2
		set lastrad $startrad
	}

	;#	Choose spline type

	set gradset_start 0													;#	Divide nespoints into sets of same-oriented gradient
	set gradset_cnt 1
	set len [llength $grads]
	set startgrad_of_set [lindex $grads 0]								;#	First gradient of gradient set
	set setstart_nesindex $sttindx										;#	Position in nes(brk) of start of grad
	set setend_nesindex [expr $setstart_nesindex + 2]					;#	Position in nes(brk) of end of gradset
	while {$gradset_cnt <= $len} {										
		set setcnt 1													;#	Startoff with the grad of the first item
		while {$gradset_cnt < $len} {									;#	Start to go through all grads

			set endgrad_of_set [lindex $grads $gradset_cnt]				;#	Compare last grad of this group, with first grad
			if {$endgrad_of_set == $startgrad_of_set} {					;#	If it's same, count the number of same-grads
				incr setcnt												;#	If not break, (gradient orientation has changed)		
			} else {													
				break
			}
			incr setend_nesindex 2										;#	If orientation has not changed
			incr gradset_cnt											;#	go to next item in grads, and update index in nes(brk) of its end
			set finished 0
		}
		if {($setcnt == 1) || ($startgrad_of_set == 0)} {				;#	If only a single gradient with this orientation, this is a Sinusoidal spline
			set startpos [lindex $nes(brk) $setstart_nesindex]			;#	If its a set of zero gradients, do sinus (which will come out as straight line)
			set startrad [lindex $nes(brk) [expr $setstart_nesindex + 1]]
			set endpos [lindex $nes(brk) $setend_nesindex]
			set endrad [lindex $nes(brk) [expr $setend_nesindex + 1]]
			if {$gradset_start == 0} {									;#	If we're at start of all grads, use preslope
				set cmd DoInitialSinusiodalSpline
				lappend cmd $setstart_nesindex $setend_nesindex  $preslope
				lappend cmds $cmd
				set lastspline sinus
			} else {			
				set cmd DoInternalSinusiodalSpline
				lappend cmd $setstart_nesindex $setend_nesindex
				lappend cmds $cmd
				set lastspline sinus
			}
		} else {														;#	If more than 1 grad of same orientation, do a cubic spline
			if {$gradset_start == 0} {
				set cmd DoCubicSpline									;#	If this is the first spline, use the preslope		
				lappend cmd $setstart_nesindex $setend_nesindex $preslope 0
				lappend cmds $cmd
				set lastspline cubic
			} else {			
				set cmd DoCubicSpline 
				lappend cmd $setstart_nesindex $setend_nesindex 0 0
				lappend cmds $cmd
				set lastspline cubic
			}
		}
		set startgrad_of_set $endgrad_of_set
		set gradset_start $gradset_cnt									;#	Start a new set at the point we've reached
		set setstart_nesindex $setend_nesindex							;#	Reset the nes(brk) index of set start
		set setend_nesindex [expr $setstart_nesindex + 2]				;#	Reset the nes(brk) index of set end
		incr gradset_cnt												;#	Move up in gradset
		set finished 1
	}
	if {!$finished} {
		if {($setcnt == 1) || ($startgrad_of_set == 0)} {				;#	If only a single gradient with this orientation, this is a Sinusoidal spline
			set startpos [lindex $nes(brk) $setstart_nesindex]			;#	If its a set of zero gradients, do sinus (which will come out as straight line)
			set startrad [lindex $nes(brk) [expr $setstart_nesindex + 1]]
			set endpos [lindex $nes(brk) $setend_nesindex]
			set endrad [lindex $nes(brk) [expr $setend_nesindex + 1]]
			if {$gradset_start == 0} {									;#	If we're at start of all grads, use preslope
				set cmd DoInitialSinusiodalSpline
				lappend cmd $setstart_nesindex $setend_nesindex  $preslope
				lappend cmds $cmd
				set lastspline sinus
			} else {			
				set cmd DoInternalSinusiodalSpline
				lappend cmd $setstart_nesindex $setend_nesindex
				lappend cmds $cmd
				set lastspline sinus
			}
		} else {														;#	If more than 1 grad of same orientation, do a cubic spline
			if {$gradset_start == 0} {
				set cmd DoCubicSpline									;#	If this is the first spline, use the preslope		
				lappend cmd $setstart_nesindex $setend_nesindex $preslope 0
				lappend cmds $cmd
				set lastspline cubic
			} else {			
				set cmd DoCubicSpline 
				lappend cmd $setstart_nesindex $setend_nesindex 0 0
				lappend cmds $cmd
				set lastspline cubic
			}
		}
	}
	if {$lastspline == "cubic"} {										;#	If the last spline was a cubic spline
		if {($startgrad_of_set == -1) && ($postslope > 0)} {			;#	If cubic spline falls, and postslope (bell) rises
			;#															;#	Avoid pre-bell bore narrowing, by keeping 0 slope at end of cubicspline
		} elseif {($startgrad_of_set == 1) && ($postslope < 0)} {		;#	Similarly, vice versa, avoid pre-bell balloning
			;#	
		} else {
			set lastcmd [lindex $cmds end]								;#	If spline AND postslope rising, or spline AND postslope falling, 
			set lastcmd [lreplace $lastcmd end end [expr $postslope]]			;#	attempt to match postslope
			set cmds [lreplace $cmds end end $lastcmd]
		}
	}
	set splinevals {}													;#	Assemble spline from all subsplines	
	catch {unset nes(spline_warning)}
	foreach cmd $cmds {
		set splinevals [concat $splinevals [eval $cmd]]
	}	
	catch {unset nes(spline_warning)}
	lappend splinevals [lindex $nes(brk) $endindx]
	incr endindx
	lappend splinevals [lindex $nes(brk) $endindx]
	return $splinevals
}

#--- Do sinusoidal spline from starting at zero slope and finishing at zero slope

proc DoInternalSinusiodalSpline {sttindx endindx} {
	global nes evv

	set startpos [lindex $nes(brk) $sttindx ]
	set startrad [lindex $nes(brk) [expr $sttindx + 1]]
	set endpos [lindex $nes(brk) $endindx]
	set endrad [lindex $nes(brk) [expr $endindx + 1]]

	set startpos [expr double($startpos) / double($nes(CONTROL_SRATE))]	;#	Convert to more manageable distance vals
	set startrad [expr $nes(height) - $startrad]						;#	Invert y params (as display is inverted)
	set endpos   [expr double($endpos) / double($nes(CONTROL_SRATE))]	;#	Convert to more manageable distance vals
	set endrad   [expr $nes(height) - $endrad]						;#	Invert y params (as display is inverted)

	set splinelen [expr double($endpos) - double($startpos)]
	set narrowing [expr double($endrad) - double($startrad)]

	set intpcnt [expr int(ceil($splinelen/$nes(INTERP_HIRES)))]
	set n 0
	while {$n < $intpcnt} {
		set frac [expr (double($n)/double($intpcnt))]	;#	Range 0 to 1
		set x [expr $frac * $splinelen]					;#	Range 0 to splinelen
		set x [expr $x + $startpos]
		set frac [expr $frac * $evv(PI)]				;#	Range 0 to PI
		set frac [expr (cos($frac) + 1.0)/2.0]			;#	--> Range 1 to -1 --> 2 to 0 --> 1 to 0
		set frac [expr 1.0 - $frac]						;#	--> Range 1 to 0 --> 0 to 1
		set rad [expr $frac * $narrowing]				;#	Range 0 to narrowing
		set rad [expr $rad + $startrad]					;#	Range startrad to endrad
		set y [expr $nes(height) - $rad]				;#	y coords are upside-down
		lappend splinepnts $x $y
		incr n
	}
	foreach {x y} $splinepnts {
		set x [expr double($x) * double($nes(CONTROL_SRATE))]
		lappend nupts $x $y
	}
	set splinepnts $nupts
	return $splinepnts
}

#--- Do sinusoidal spline from starting at preslope slope and finishing at zero slope

proc DoInitialSinusiodalSpline {sttindx endindx preslope} {
	global nes evv

	set startpos [lindex $nes(brk) $sttindx ]
	set startrad [lindex $nes(brk) [expr $sttindx + 1]]
	set endpos [lindex $nes(brk) $endindx]
	set endrad [lindex $nes(brk) [expr $endindx + 1]]

	if {$preslope < 0.0} {
		set preslope 0				;#	Avoid narrowing of bore at start of interp
	}
	set startpos [expr double($startpos) / double($nes(CONTROL_SRATE))]	;#	Convert to more manageable distance vals
	set startrad [expr $nes(height) - $startrad]						;#	Invert y params (as display is inverted)
	set endpos   [expr double($endpos) / double($nes(CONTROL_SRATE))]	;#	Convert to more manageable distance vals
	set endrad   [expr $nes(height) - $endrad]							;#	Invert y params (as display is inverted)

	set splinelen [expr double($endpos) - double($startpos)]
	set narrowing [expr double($endrad) - double($startrad)]

	set intpcnt [expr int(ceil($splinelen/$nes(INTERP_HIRES)))]
	set n 0

	;#	Find point where gradient of interp would equal preslope
	
	if {$preslope > 0.0} {

		while {$n < $intpcnt} {
			set frac [expr (double($n)/double($intpcnt))]	;#	Range 0 to 1
			set x [expr $frac * $splinelen]					;#	Range 0 to splinelen
			set x [expr $x + $startpos]
			set frac [expr $frac * $evv(PI)]				;#	Range 0 to PI
			set frac [expr (cos($frac) + 1.0)/2.0]			;#	--> Range 1 to -1 --> 2 to 0 --> 1 to 0
			set frac [expr 1.0 - $frac]						;#	--> Range 0 to 1
			set rad [expr $frac * $narrowing]				;#	Range 0 to narrowing
			set rad [expr $rad + $startrad]					;#	Range startrad to endrad
			if {$n > 0} {
				set grad [expr ($rad - $lastrad)/($x - $lastpos)]
				if {$grad >= $preslope} {
					incr n -1
					break
				}
			}
			set lastpos $x
			set lastrad $rad
			incr n
		}
		if {$n >= $intpcnt} {								;#	spline never reaches preslope
			set n 0
			set nuintpcnt $intpcnt
			set nunarrowing $narrowing
			set nustartrad $startrad
		} else {		

			;# Expand the scale of the semi-arc

			set expansion [expr double($intpcnt) / double($intpcnt - $n)]
			set nuintpcnt [expr int(floor($intpcnt * $expansion))]
			set nunarrowing [expr $narrowing * $expansion]	;#	Narrowing over the COMPLETE new arc (we shall only use the last part of the new arc)
			set nustartrad [expr $endrad - $nunarrowing]	;#	Start rad of the COMPLETE new arc. We will begin partway into the new arc
															;#	at the point where its radius corresponds to the true startrad			
			;#	adjust

			set n [expr $nuintpcnt - $intpcnt]				;#	Position of 1st point in expanded interpolation arc, to ensure we still will get "intpcnt" points

															;#	Calculate position of First point in new arc
			set frac [expr (double($n)/double($nuintpcnt))]	;#	Range 0 to 1
			set frac [expr $frac * $evv(PI)]				;#	Range 0 to PI
			set frac [expr (cos($frac) + 1.0)/2.0]			;#	--> Range 1 to -1 --> 2 to 0 --> 1 to 0
			set frac [expr 1.0 - $frac]						;#	--> Range 0 to 1
			set rad [expr $frac * $nunarrowing]				;#	Range 0 to narrowing
			set rad [expr $rad + $nustartrad]				;#	Range endrad to nustartrad

			set new_narrowing [expr $endrad - $rad]			;#	Distance from 1st-point-on-new-arc to endrad should corresponds to original "narrowing" val

			if {![Flteq $narrowing $new_narrowing]} {		;#	If not, adjust params accordingly
				set adjustment [expr $narrowing/$new_narrowing]
				set nunarrowing [expr $nunarrowing * $adjustment]
				set nustartrad [expr $endrad - $nunarrowing]
			}
		}
	} else {
		set nuintpcnt $intpcnt
		set nunarrowing $narrowing
		set nustartrad $startrad
	}
	set m 0
	while {$n < $nuintpcnt} {
		set frac [expr (double($m)/double($intpcnt))]	;#	Range 0 to 1
		set x [expr $frac * $splinelen]					;#	Range 0 to splinelen
		set x [expr $x + $startpos]
		set frac [expr (double($n)/double($nuintpcnt))]	;#	Range 0 to 1
		set frac [expr $frac * $evv(PI)]				;#	Range 0 to PI
		set frac [expr (cos($frac) + 1.0)/2.0]			;#	--> Range 1 to -1 --> 2 to 0 --> 1 to 0
		set frac [expr 1.0 - $frac]						;#	--> Range 0 to 1
		set rad [expr $frac * $nunarrowing]				;#	Range 0 to narrowing
		set rad [expr $rad + $nustartrad]				;#	Range endrad to nustartrad
		set y [expr $nes(height) - $rad]				;#	y coords are upside-down
		lappend splinepnts $x $y
		incr n
		incr m
	}
	foreach {x y} $splinepnts {
		set x [expr double($x) * double($nes(CONTROL_SRATE))]
		lappend nupts $x $y
	}
	set splinepnts $nupts
	return $splinepnts
}

##################################
# ENTERING BRASS INSTRUMENT DATA #
##################################

proc NessScore {input fnam} {
	global wl chlist pa evv wstk nessprof pr_nessco nessparamset nessparam nessco nessrange nes
	global nes_first nescorig nesinterp nessco_fnam nes_def nes_ori nes_fsave nes_fload nes_finj nes_sync nes_clr ness_longparamname
	global nes_lastdisplaycall nes_displayconstants nes_rand
	global CDPidrun prg_dun prg_abortd simple_program_messages maxsamp_line done_maxsamp CDPmaxId shortwindows

	catch {unset nes_lastdisplaycall}
	catch {unset nes_displayconstants}

;#	T					FIXED duration
;#	Sr mu sigma H w		FIXED lip params
;#	FS					FIXED sample rate
;#	maxout				FIXED output level
;#	pressure lip_frequency vibamp vibfreq tremamp tremfreq noiseamp valvevibfreq valvevibamp	TIME VARIABLE
;#	valveopening		MULTIPLE ENTRY, IF MULTIPLE VALVES
;#	instrumentfile		SPECIAL ENTRY

	catch {unset nescorig}
	if {$input} {
		if {$fnam == 0} {				;#	Input from wkspace

			if {![info exists chlist] || ([llength $chlist] !=1)} {
				set ilist [$wl curselection]
				if {![info exists ilist] || ([llength $ilist] != 1) || ($ilist == -1)} {
					Inf "No physical modelling score file selected"
					return
				} else {
					set fnam [$wl get $ilist]
				}
			} else {
				set fnam [lindex $chlist 0]
			}
		}
		set typ [IsAValidNessFile $fnam 1 0 0]
		if {$typ != "s"} {
			Inf "Select a physical modelling score file"
			return
		}
		if {![GetValveCnt $nessparam(instrumentfile) 1]} {
			return
		}
	} else {
		set fnam cdptest.m 
		foreach paramname $nessparamset(sco2) {
			set nessco($paramname) ""
		}
		catch {unset nes(valvecnt)}
	}
	set nessco_fnam $fnam

	set nessco(sound) $evv(DFLT_OUTNAME)
	append nessco(sound) $evv(SNDFILE_EXT)
	set nessco(tempscore) $evv(DFLT_OUTNAME)
	append nessco(tempscore) $evv(TEXT_EXT)

	set f .nessco

	if [Dlg_Create $f "BRASS INSTRUMENT SCORE" "set pr_nessco 0" -borderwidth $evv(BBDR)] {
		set b  [frame $f.b]
		set b2 [frame $f.b2]
		set ll [frame $f.ll]
		button $b.ok1 -text "Save Score"	  -width 12 -command "set pr_nessco 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.ok2 -text "Create Sound"	  -width 12 -command "set pr_nessco 2" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.hh  -text "Help"			  -width 12 -command "BrassScoreHelp" -bg $evv(HELP) -bd 4 -highlightbackground [option get . background {}]
		button $b.c  -text "Clear All (C)"    -width 12 -command "NessClear all" -highlightbackground [option get . background {}]
		button $b.d  -text "All Defaults (D)" -width 12 -command "NessDefault all" -highlightbackground [option get . background {}]
		button $b.i  -text "Restore All (R)"  -width 12 -command "NessOriginal all" -highlightbackground [option get . background {}]
		button $b.sy -text "Sync All (Sy)"    -width 12 -command "NessSync all" -highlightbackground [option get . background {}]
		button $b.q  -text "Quit" -width 10 -command "set pr_nessco 0" -highlightbackground [option get . background {}]
		if {[info exists shortwindows]} {
			label $f.b.ll -text "Output Filename" -width 15 -anchor w
			entry $f.b.e -textvariable nessco(fnam)
			pack $b.ok1 $b.ok2 $b.hh $f.b.ll $f.b.e -side left -padx 2
		} else {
			pack $b.ok1 $b.ok2 $b.hh -side left -padx 4
		}
		pack $b.q $b.c $b.d $b.i $b.sy -side right -padx 2
		pack $b -side top -fill x -expand true -pady 2
		button $b2.ok3 -text "Save Sound"	 -width 12 -command "set pr_nessco 4" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b2.ok4 -text "Play Output"	 -width 12 -command "set pr_nessco 3" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b2.ok5 -text "View Output"	 -width 12 -command "set pr_nessco 5" -bg $evv(SNCOLOROFF) -highlightbackground [option get . background {}]
		button $b2.ok6 -text "Max Sample"	 -width 12 -command "set pr_nessco 6" -highlightbackground [option get . background {}]
		pack $b2.ok3 $b2.ok4 $b2.ok5 $b2.ok6 -side left -padx 4
		pack $b2 -side top -fill x -expand true -pady 2
		label $f.tit -text "" -fg $evv(SPECIAL)
		if {![info exists shortwindows]} {
			pack $f.tit -side top -pady 2
		}
		frame $f.00 -bg black -height 1
		pack $f.00 -side top -pady 4 -fill x -expand true
		if {![info exists shortwindows]} {
			frame $f.xx
			button $f.xx.i  -text "Instrument Used" -command "NessDisplayInstrumentFile" -width 16 -highlightbackground [option get . background {}]
			button $f.xx.sc -text "Input Score" -command "SimpleDisplayTextfile $nessco_fnam" -width 16 -highlightbackground [option get . background {}]
			pack $f.xx.i $f.xx.sc -side left -padx 2
			pack $f.xx -side top -fill x -expand true 
		}
		set n 0
		foreach paramname $nessparamset(sco4) {
			if {$paramname == "fs"} {
				label $f.sound -text "SOUND OUTPUT" -fg $evv(SPECIAL)
				if {![info exists shortwindows]} {
					pack $f.sound -side top -pady 4
				}
				set nnam "Sampling Rate"
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 20
				button $f.$paramname.e2 -text ""  -command {} -borderwidth 0 -width 17 -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
				if {[info exists shortwindows]} {
					button $f.$paramname.i  -text "Instrument Used" -command "NessDisplayInstrumentFile" -width 16 -highlightbackground [option get . background {}]
					button $f.$paramname.sc -text "Input Score" -command "SimpleDisplayTextfile $nessco_fnam" -width 16 -highlightbackground [option get . background {}]
					pack $f.$paramname.sc $f.$paramname.i -side right -padx 2
				}
			} elseif {$paramname == "maxout"} {
				set nnam "Max Output Level"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 20
				button $f.$paramname.e2 -text ""  -command {} -borderwidth 0 -width 17 -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "t"} {
				set nnam "Duration"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				button $f.$paramname.e2 -text "Time Warp"  -command NessTimeWarp -width 16 -bd 4 -bg $nes(colour) -highlightbackground [option get . background {}]
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 20
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "instrumentfile"} {
				label $f.ins -text "INSTRUMENT" -fg $evv(SPECIAL)
				if {![info exists shortwindows]} {
					pack $f.ins -side top -pady 4
				}
				set nnam "Instrument File"			
				frame $f.$paramname
				label $f.$paramname.ll -text "Instrument File" -width 15 -anchor w
				button $f.$paramname.e2 -text "Select:Edit" -command "SelectNessScoreIns" -borderwidth 4 -width 8 -bg $nes(colour) -highlightbackground [option get . background {}]
				button $f.$paramname.e3 -text "Create" -command "CreateNessScoreIns" -borderwidth 4 -width 6 -bg $nes(colour) -highlightbackground [option get . background {}]
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 40 -state readonly
				pack $f.$paramname.e2 $f.$paramname.e3 -side left
				pack $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "sr"} {
				label $f.lips -text "LIP CHARACTERISTICS" -fg $evv(SPECIAL)
				if {![info exists shortwindows]} {
					pack $f.lips -side top -pady 4
				}
				set nnam "Lip Area"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "mu"} {
				set nnam "Lip Mass"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "sigma"} {
				set nnam "Lip Damping"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "h"} {
				set nnam "Lip Separation"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "w"} {
				set nnam "Width of Lips"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "pressure"} {
				label $f.artic -text "ARTICULATION" -fg $evv(SPECIAL)
				if {![info exists shortwindows]} {
					pack $f.artic -side top -pady 4
				}
				set nnam "Pressure"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "valveopening"} {
				label $f.valving -text "VALVING" -fg $evv(SPECIAL)
				if {![info exists shortwindows]} {
					pack $f.valving -side top -pady 4
				}
				set nnam "Valve Opening"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Valving"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 8 -bg $nes(colour) -highlightbackground [option get . background {}]
				button $f.$paramname.e3 -text "Times"   -command "GetValveChangeTimes $paramname" -width 6 -bg $nes(colour) -bd 4 -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.e3 -side left
				pack $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "lip_frequency"} {
				set nnam "Lip Frequency"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "vibfreq"} {
				set nnam "Lip Vibrato Frq"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "vibamp"} {
				set nnam "Lip Vibrato Amp"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname -side top -pady 2 -fill x -expand true
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "tremfreq"} {
				set nnam "Lip Tremolo Frq"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "tremamp"} {
				set nnam "Lip Tremolo Amp"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "valvevibfreq"} {
				set nnam "Valve Vibrato Frq"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary Frq"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 8 -bg $nes(colour) -highlightbackground [option get . background {}]
				button $f.$paramname.e3 -text "Times"   -command "GetValveChangeTimes $paramname" -width 6 -bg $nes(colour) -bd 4 -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.e3 -side left
				pack $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "valvevibamp"} {
				set nnam "Valve Vibrato Amp"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary Amp"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 8 -bg $nes(colour) -highlightbackground [option get . background {}]
				button $f.$paramname.e3 -text "Times"   -command "GetValveChangeTimes $paramname" -width 6 -bg $nes(colour) -bd 4 -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.e3 -side left
				pack $f.$paramname.ll $f.$paramname.e -side left -padx 2
			} elseif {$paramname == "noiseamp"} {
				set nnam "Noise Amplitude"			
				frame $f.$paramname
				label $f.$paramname.ll -text $nnam -width 15 -anchor w
				entry $f.$paramname.e -textvariable nessparam($paramname) -width 72
				button $f.$paramname.e2 -text "Vary over Time"  -command "NessDisplayX $input $paramname $fnam" -borderwidth 4 -width 16 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
				pack $f.$paramname.e2 $f.$paramname.ll $f.$paramname.e -side left -padx 2
			}
			radiobutton $f.$paramname.ro -text "R" -variable nes_ori($paramname) -value 1 -command "NessOriginal $paramname" -width 5
			if {($paramname == "instrumentfile") || ($paramname == "valveopening") || ($paramname == "valvevibfreq") \
			|| ($paramname == "valvevibamp") || ($paramname == "lip_frequency") || ($paramname == "t")} {
				radiobutton $f.$paramname.rd -text "" -variable nes_def($paramname) -value 1 -command {} -width 0 -state disabled
			} else {
				radiobutton $f.$paramname.rd -text "D" -variable nes_def($paramname) -value 1 -command "NessDefault $paramname"  -width 5
			}
			radiobutton $f.$paramname.cc -text "C" -variable nes_clr($paramname) -value 1 -command "NessClear $paramname" -width 5
			pack $f.$paramname.ro $f.$paramname.rd $f.$paramname.cc  -side left
			if {($paramname != "fs") && ($paramname != "maxout") && ($paramname != "instrumentfile") && ($paramname != "t")} {
				radiobutton $f.$paramname.ffs -text "S" -variable nes_fsave($paramname) -value 1 -command "SaveNessScoreFile $paramname" -width 5
				radiobutton $f.$paramname.ffl -text "F" -variable nes_fload($paramname) -value 1 -command "LoadNessFile $paramname" -width 5
				radiobutton $f.$paramname.ffi -text "B" -variable nes_finj($paramname)  -value 1 -command "InjectFromNessScore $paramname" -width 5
				pack $f.$paramname.ffs $f.$paramname.ffl $f.$paramname.ffi -side left
			}
			if {$paramname == "instrumentfile"} {
				radiobutton $f.$paramname.ffi -text "B" -variable nes_finj($paramname)  -value 1 -command "InjectFromNessScore $paramname" -width 5
				pack $f.$paramname.ffi -side left
			}
			if {$paramname  == "valveopening"} {
				radiobutton $f.$paramname.sy -text "" -variable nes_sync($paramname)  -value 1 -command {} -width 5 -state disabled
				radiobutton $f.$paramname.ra -text "ra" -variable nes_rand($paramname)  -value 1 -command "NessRand $paramname" -width 5
				pack $f.$paramname.sy $f.$paramname.ra -side left
			} elseif {($paramname != "fs") && ($paramname != "maxout") && ($paramname != "instrumentfile") && ($paramname != "t")} {
				radiobutton $f.$paramname.sy -text "Sy" -variable nes_sync($paramname)  -value 1 -command "NessSync $paramname" -width 5
				radiobutton $f.$paramname.ra -text "ra" -variable nes_rand($paramname)  -value 1 -command "NessRand $paramname" -width 5
				pack $f.$paramname.sy $f.$paramname.ra -side left
			}
			if {$paramname  == "t"} {
				if {![info exists shortwindows]} {
					frame $f.o
					label $f.o.ll -text "Output Filename" -width 15 -anchor w
					button $f.o.e2 -text ""  -command {} -borderwidth 0 -width 17 -highlightbackground [option get . background {}]
					entry $f.o.e -textvariable nessco(fnam)
					set nessco(fnam) ""
					pack $f.o.e2 $f.o.ll $f.o.e -side left -padx 2
					pack $f.o -side top -pady 2 -fill x -expand true
				}
			}
			pack $f.$paramname -side top -pady 2 -fill x -expand true
		}
		wm resizable $f 0 0
		bind $f <Return> {set pr_nessco 1}
		bind $f <Escape> {set pr_nessco 0}
	}
	.nessco.b2.ok3 config -text "" -command {} -bg [option get . background {}] -bd 0
	.nessco.b2.ok4 config -text "" -command {} -bg [option get . background {}] -bd 0
	.nessco.b2.ok5 config -text "" -command {} -bg [option get . background {}] -bd 0
	.nessco.b2.ok6 config -text "" -command {} -bg [option get . background {}] -bd 0
	.nessco.b.ok2  config -text "Create Sound" -command "set pr_nessco 2" -bg $evv(EMPH) -bd 2

	if {$input} {
		.nessco.tit  config -text "\"R\" Restore value    :   \"D\" Default value    :    \"C\" Clear value   :    \"S\" Save to file    :    \"F\" get from File    :    \"B\" Borrow from another score    :    \"Sy\" Sync to valve-changes    :    \"ra\" Randomise"
		.nessco.b.i  config -command "NessOriginal all" -bd 2 -text "Restore All (R)"
		set nessparam(sr) $nessparam(Sr)
		set nessparam(h) $nessparam(H)
		set nessparam(t) $nessparam(T)
		set nessparam(fs) $nessparam(FS)
		foreach nam $nessparamset(sco2) {
			if {([llength $nessparam($nam)] == 2) && ([lindex $nessparam($nam) 0] == 0.0)} {
				set nessparam($nam) [lindex $nessparam($nam) 1]
			}
			set nescorig($nam) $nessparam($nam)
			set nes_def($nam) 0
			set nes_ori($nam) 0
			catch {set nes_fsave($nam) 0}
			catch {set nes_fload($nam) 0}
			catch {set nes_finj($nam) 0}
			catch {set nes_sync($nam) 0}
			.nessco.$nam.ro config -text "R" -command "NessOriginal $nam" -state normal
		}
		if {[info exists shortwindows]} {
			.nessco.fs.sc config -text "Input Score" -state normal -bd 2
		} else {
			.nessco.xx.sc config -text "Input Score" -state normal -bd 2
		}
	} else {
		.nessco.tit  config -text "\"D\" set Default value    :    \"C\" Clear value   :    \"S\" Save to file    :    \"F\" get from File    :    \"B\" Borrow from another score    :    \"Sy\" Sync to valve-changes    :    \"ra\" Randomise"
		.nessco.b.i  config -command {} -bd 0 -text ""
		foreach nam $nessparamset(sco2) {
			set nessparam($nam) ""
			set nes_def($nam) 0
			set nes_ori($nam) 0
			.nessco.$nam.ro config -text "" -command {} -state disabled
		}
		if {[info exists shortwindows]} {
			.nessco.fs.sc config -text "" -bd 0 -state disabled -background [option get . background {}]
		} else {
			.nessco.xx.sc config -text "" -bd 0 -state disabled -background [option get . background {}]
		}
	}
	set pr_nessco 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_nessco $f
	set finished 0
	while {!$finished} {
		tkwait variable pr_nessco
		switch -- $pr_nessco {
			1 -
			2 {
				.nessco.t.e config -background [option get . background {}]

				;#	CHECK ALL PARAMS

				set OK 1
				foreach nam $nessparamset(sco2) {
					if {![CheckNescoParam $nam $ness_longparamname($nam) $nessparam($nam) 1]} {
						set OK 0
						break
					}
				}
				if {!$OK} {
					continue
				}
				if {($nessparam(t) > $nes(hiscoredur))} {
					.nessco.t.e config -background $evv(EMPH)
					focus .nessco.t.e 
					set msg "Very long duration entered : are you sure you want to proceed ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						.nessco.t.e config -background [option get . background {}]
						continue
					}
				}
				set len [llength $nessparam(valveopening)]
				incr len -2
				set lastvalvingtime [lindex $nessparam(valveopening) $len]
				if {$nessparam(t) < $lastvalvingtime} {  
					set msg "Last valving event is after end of score : is this ok ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						.nessco.t.e config -background $evv(EMPH)
						focus .nessco.t.e 
						continue
					}
				}
				.nessco.t.e config -background [option get . background {}]

				if {$pr_nessco == 1} {

					;#	FOR SCORE OUTPUT, (PROBABLY) DON'T SAVE IF NOTHING CHANGED

					if {[info exists nescorig]} {
						set isnew 0
						foreach paramname $nessparamset(sco2) {
							if {$nescorig($paramname) != $nessparam($paramname)} {
								set isnew 1
								break
							}
						}
						if {!$isnew} {
							set msg "No parameters have been changed : continue to save ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								continue
							}
						}
					}

					;#	AND MUST ALREADY HAVE A VALID OUTPUT FILENAME (NO EXISTING SCORE or SOUND WITH SAME NAME)

					if {[string length $nessco(fnam)] <= 0} {
						Inf "No output filename entered"
						if {[info exists shortwindows]} {
							.nessco.b.e config -background $evv(EMPH)
							focus .nessco.b.e 
						} else {
							.nessco.o.e config -background $evv(EMPH)
							focus .nessco.o.e 
						}
						continue
					}
					if {![ValidCDPRootname $nessco(fnam)]} {
						if {[info exists shortwindows]} {
							.nessco.b.e config -background $evv(EMPH)
							focus .nessco.b.e 
						} else {
							.nessco.o.e config -background $evv(EMPH)
							focus .nessco.o.e 
						}
						continue
					}
					if {[info exists shortwindows]} {
						.nessco.b.e config -background [option get . background {}]
					} else {
						.nessco.o.e config -background [option get . background {}]
					}
					set outfnam [string tolower $nessco(fnam)]
					append outfnam $evv(SNDFILE_EXT)
					if {[file exists $outfnam]} {
						Inf "Soundfile $outfnam already exists, please chose a different name"
						if {[info exists shortwindows]} {
							.nessco.b.e config -background $evv(EMPH)
							focus .nessco.b.e 
						} else {
							.nessco.o.e config -background $evv(EMPH)
							focus .nessco.o.e 
						}
						continue
					}
					set outfnam [string tolower $nessco(fnam)]
					append outfnam $evv(NESS_EXT)
					if {[file exists $outfnam]} {
						Inf "Score file $outfnam already exists, please chose a different name"
						if {[info exists shortwindows]} {
							.nessco.b.e config -background $evv(EMPH)
							focus .nessco.b.e 
						} else {
							.nessco.o.e config -background $evv(EMPH)
							focus .nessco.o.e 
						}
						continue
					}
				} else { 

					;#	FOR SOUND OUTPUT, USE TEMPORARY SCORE-FILE AND SOUNDFILE

					if {[file exists $nessco(tempscore)]} {
						if [catch {file delete $nessco(tempscore)} zit] {
							Inf "Cannot delete temporary score file $nessco(tempscore)"
							continue
						}
					}
					if {[file exists $nessco(sound)]} {
						if [catch {file delete $nessco(sound)} zit] {
							Inf "Cannot delete temporary soundfile $nessco(sound)"
							continue
						}
					}
					set outfnam $nessco(tempscore)
				}

				;#	PROCEED TO CREATE THE SCORE

				set lines [ConvertBrassScoreDataToFileFormat [file rootname $outfnam]]
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot open file $outfnam to write the new score file"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit

				if {$pr_nessco == 1} {

				;#	FOR SCORE OUTPUT, REMEMBER THE LAST VALID SCORE, AND PUT SCORE FILE ON WORKSPACE

					foreach nam $nessparamset(sco2) {
						set nescorig($nam) $nessparam($nam)
					}
					FileToWkspace $outfnam 0 0 0 0 1
					Inf "File $outfnam is on the workspace"
					continue
				}

				;#	FOR SOUND OUTPUT, GENERATE THE SOUND

				Block "SYNTHESIZING $nessco(fnam)"

				;#	CMDLINE = ness-brass -i instrumentfile -s scorefile -o outputfile

				set cmd [file join $evv(CDPROGRAM_DIR) ness-brass]
				lappend cmd -i $nessparam(instrumentfile) -s $outfnam -o [file rootname $nessco(sound)]
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "FAILED TO RUN SYNTHESIS OF $nessparam(instrumentfile)"
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
					set msg "Failed to synthesize $nessparam(instrumentfile)"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					UnBlock
					continue
				}
				UnBlock
				if {![file exists $nessco(sound)]} {
					Inf "Synthesis of $nessparam(instrumentfile) produced no output"
					continue
				}
				if {[file exists $nessco(sound)]} {
					set isparsed 1
					if {[DoParse $nessco(sound) 0 0 0] <= 0} {
						set isparsed 0
					}

					;#	ACTIVATE "PLAY SOUND" and "SAVE SOUND" BUTTONS : DEACTIVATE THE "CREATE SOUND" BUTTON

					.nessco.b2.ok3 config -text "Save Sound"  -command "set pr_nessco 4" -bg $evv(EMPH) -bd 2
					.nessco.b2.ok4 config -text "Play Output" -command "set pr_nessco 3" -bg $evv(EMPH) -bd 2
					if {$isparsed} {
						.nessco.b2.ok5 config -text "View Output" -command "set pr_nessco 5" -bg $evv(SNCOLOROFF) -bd 2
					}
					.nessco.b2.ok6 config -text "Max Samp"    -command "set pr_nessco 6" -bd 2
					.nessco.b.ok2  config -text "" -command {} -bg [option get . background {}] -bd 0
				}
			}
			3 {
				;#	PLAY OUTPUT

				if {![file exists $nessco(sound)]} {
					Inf "No sound created yet"
				}
				PlaySndfile $nessco(sound) 0
			}
			4 {
				;#	SAVE SCORE AND SOUND

				;#	CHECK FOR VALID FILENAME FOR BOTH SCORE AND SOUND

				if {[string length $nessco(fnam)] <= 0} {
					Inf "No output filename entered"
					if {[info exists shortwindows]} {
						.nessco.b.e config -background $evv(EMPH)
						focus .nessco.b.e 
					} else {
						.nessco.o.e config -background $evv(EMPH)
						focus .nessco.o.e 
					}
					continue
				}
				if {![ValidCDPRootname $nessco(fnam)]} {
					if {[info exists shortwindows]} {
						.nessco.b.e config -background $evv(EMPH)
						focus .nessco.b.e 
					} else {
						.nessco.o.e config -background $evv(EMPH)
						focus .nessco.o.e 
					}
					continue
				}
				if {[info exists shortwindows]} {
					.nessco.b.e config -background [option get . background {}]
				} else {
					.nessco.o.e config -background [option get . background {}]
				}
				set outsnd [string tolower $nessco(fnam)]
				append outsnd $evv(SNDFILE_EXT)
				if {[file exists $outsnd]} {
					Inf "Soundfile $outsnd already exists, please chose a different name"
					if {[info exists shortwindows]} {
						.nessco.b.e config -background $evv(EMPH)
						focus .nessco.b.e 
					} else {
						.nessco.o.e config -background $evv(EMPH)
						focus .nessco.o.e 
					}
					continue
				}
				set outfnam [string tolower $nessco(fnam)]
				append outfnam $evv(NESS_EXT)
				if {[file exists $outfnam]} {
					Inf "Score file $outfnam already exists, please chose a different name"
					if {[info exists shortwindows]} {
						.nessco.b.e config -background $evv(EMPH)
						focus .nessco.b.e 
					} else {
						.nessco.o.e config -background $evv(EMPH)
						focus .nessco.o.e 
					}
					continue
				}
				if {[info exists shortwindows]} {
					.nessco.b.e config -background [option get . background {}]
				} else {
					.nessco.o.e config -background [option get . background {}]
				}

				;#	SAVE THE SCORE FILE

				set files_on_wkspace {}
				if [catch {file rename $nessco(tempscore) $outfnam} zit] {
					Inf "Cannot rename temporary score file $nessco(tempscore) to $outfnam\n\nto preserve the file, rename it outside the loom, now."
				} else {
					FileToWkspace $outfnam 0 0 0 0 1
					lappend file_on_wkspace $outfnam
				}
	
				;#	ONCE SCORE SAVED, REMEMBER LAST VALID SCORE PARAMETERS

				foreach nam $nessparamset(sco2) {
					set nescorig($nam) $nessparam($nam)
				}

				;#	SAVE THE SOUND FILE

				if [catch {file rename $nessco(sound) $outsnd} zit] {
					Inf "Cannot rename temporary sound file $nessco(sound) to $outsnd\n\nto preserve the file, rename it outside the loom, now."
				} else {
					FileToWkspace $outsnd 0 0 0 0 1
					lappend file_on_wkspace $outsnd
				}
				switch -- [llength $file_on_wkspace] {
					1 {
						Inf "File $file_on_wkspace is on the workspace"
					}
					2 {
						Inf "Files [file rootname $outfnam] are on the workspace"
					}
				}

				;#	DEACTIVATE THE "PLAY SOUND" AND "SAVE SOUND" BUTTONS : REACTIVATE THE "CREATE SOUND" BUTTON

				.nessco.b2.ok3 config -text "" -command {} -bg [option get . background {}] -bd 0
				.nessco.b2.ok4 config -text "" -command {} -bg [option get . background {}] -bd 0
				.nessco.b2.ok5 config -text "" -command {} -bg [option get . background {}] -bd 0
				.nessco.b2.ok6 config -text "" -command {} -bg [option get . background {}] -bd 0
				.nessco.b.ok2  config -text "Create Sound" -command "set pr_nessco 2" -bg $evv(EMPH) -bd 2
			}
			5 {
				;#	VIEW OUTPUT
				SnackDisplay 0 nessco $evv(TIME_OUT) $nessco(sound)

			} 
			6 {
				;#	OUTPUT MAX SAMPLE
				catch {unset maxsamp_line}
				set done_maxsamp 0
				set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
				lappend cmd $nessco(sound)
				lappend cmd 1		;#	1 flag added to FORCE read of maxsample
				if [catch {open "|$cmd"} CDPmaxId] {
					ErrShow "$CDPmaxId"
					continue
	   			} else {
	   				fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
				}
	 			vwait done_maxsamp
				if {[info exists maxsamp_line]} {
					if {[lindex $maxsamp_line 3] == 1} {
						Inf "Maximum level [lindex $maxsamp_line 1] at sample [lindex $maxsamp_line 2]"
					} else {
						Inf "Maximum level [lindex $maxsamp_line 1] occurs first at sample [lindex $maxsamp_line 2]"
					}
				}
			}
			0 {
				set finished 1
			}
		}
	}
	catch {unset nessprof(cdptest)}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

;# Find number of valves in Instrument File

proc GetValveCnt {fnam check} {
	global nes
	if {$check} {
		if {![file exists $fnam]} {
			Inf "Instrument file $fnam no longer exists"
			return 0
		}
		set typ [IsAValidNessFile $fnam 1 0 1]
		if {$typ != "i"} {
			Inf "Instrument file $fnam used by the score is no longer a valid instrument file"
			return 0
		}
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open instrument file $fnam to check number of valves"
		return 0
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set k [string first "vpos=\[" $line]
		if {$k >= 0} {
			incr k 6
			set line [string range $line $k end]
			set k [string first "\]" $line]
			if {$k >= 0} {
				incr k -1
				set line [string range $line  0 $k]
			} else {
				Inf "Invalid syntax for valve position in file $fnam"
				break
			} 
			set line [split $line ',']
			set OK 1
			foreach item $line {
				if {![IsNumeric $item]} {
					set OK 0
					break
				}
			} 
			if {$OK} {
				set valvecnt [llength $line]
			}
			break
		}
	}
	close $zit
	if {![info exists valvecnt]} {
		Inf "Failed to find valve specification in instrument file $fnam"
		return 0
	}
	set nes(valvecnt) $valvecnt
	return 1
}

proc BrassScoreHelp {} {
	global pr_nessbrhelp
	set f .brasshelp
	if [Dlg_Create $f "BRASS SCORE HELP" "set pr_nessbrhelp 0" -borderwidth 2] {
		frame $f.0
		button $f.0.ee -text "Overview"         -width 16 -command "set pr_nessbrhelp 1" -highlightbackground [option get . background {}]
		button $f.0.rr -text "Parameter Ranges" -width 16 -command "set pr_nessbrhelp 2" -highlightbackground [option get . background {}]
		button $f.0.oo -text "Other Features"   -width 16 -command "set pr_nessbrhelp 3" -highlightbackground [option get . background {}]
		button $f.0.q  -text "Quit"             -width 16 -command "set pr_nessbrhelp 0" -highlightbackground [option get . background {}]
		pack $f.0.ee $f.0.rr $f.0.oo $f.0.q -side left -padx 6
		pack $f.0 -side top -pady 4
		wm resizable $f 0 0
		bind $f <Return> {set pr_nessbrhelp 0}
		bind $f <Escape> {set pr_nessbrhelp 0}
	}
	set pr_nessbrhelp 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_nessbrhelp $f
	set finished 0
	while {!$finished} {
		tkwait variable pr_nessbrhelp
		switch -- $pr_nessbrhelp {
			1 {
				BrassHelpGeneral
			}
			2 {
				BrassHelpParamRanges
			}
			3 {
				BrassHelpOtherFeatures
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc BrassHelpGeneral {} {
	set msg "CREATING A SCORE OR PLAYING IT.\n"
	append msg "\n"
	append msg "You can edit an existing score, or create a new score from scratch, generate its sound output, and play it.\n"
	append msg "You can save a new score (without generating sound) from the \"Save Score\" button.\n"
	append msg "You can generate sound output from a score from the \"Create Sound\" button.\n"
	append msg "\n"
	append msg "To Save an edited or newly created score, or the Sound it generates, enter a name in \"Output Filename\".\n"
	append msg "The name of the score and output sound will be the same (except for file extensions \".m\" and \".wav\").\n"
	append msg "\n"
	append msg "When you successfully create a sound output new buttons will appear which allow you to\n"
	append msg "\n"
	append msg "Save the sound (\"Save Sound\" - which will also save the Score file)\n"
	append msg "Play the  sound (\"Play Sound\")\n"
	append msg "View the sound waveform (\"View Sound\")\n"
	append msg "Check the Sound level (\"Max Samp\").\n"
	append msg "\n"
	append msg "To output sound, or to make score parameters vary over time, you must also enter an \"Output Duration\".\n"
	append msg "\n"
	append msg "CHOSING OR CREATING AN INSTRUMENT\n"
	append msg "\n"
	append msg "Use \"Select:Edit\" to select or edit an Instrument profile, in an existing instrument file.\n"
	append msg "Use \"Create\" to generate a new Instrument profile.\n"
	append msg "\n"
	append msg "PARAMETER VALUES\n"
	append msg "\n"
	append msg "All other parameters are lists of numbers.\n"
	append msg "\n"
	append msg "Except for those associated with Valve motion, they are entered as single values,\n"
	append msg "OR (for those parameters with an associated \"Vary over Time\" button) optionally as \"time value\" pairs,\n"
	append msg "where time values start at zero and increase.\n"
	append msg "\n"
	append msg "Using the \"Vary over Time\" button, the parameter changes can be entered graphically.\n"
	append msg "Timings are read from left to right on the display, with maximum time set by \"Duration\".\n"
	append msg "\n"
	append msg "VALVING PARAMETERS.\n"
	append msg "\n"
	append msg "\"Valve Opening\" is a list of value-sets in the format...\n"
	append msg "            TimeA     opening-of-valve-1     opening-of-valve-2    etc\n"
	append msg "            TimeB     opening-of-valve-1     opening-of-valve-2    etc\n"
	append msg "for increasing time values, starting at time zero.  Valve-opening is in the range 0 to 1.\n"
	append msg "\n"
	append msg "\"Valve Vibrato\" parameters can have a similar multivalued structure, but also accept a single value (like \"0\").\n"
	append msg "If \"Valve Vibrato Frequency\" has a multivalue entry (values for each valve),\n"
	append msg " \"Valve Vibrato Amplitude\" must also have a (corresponding) multivalve entry, and vice versa.\n"
	append msg "\n"
	append msg "Valving parameters can be entered graphically, from the \"Valving\" or \"Vary Frq\" or \"Vary Amp\" buttons.\n"
	append msg "For valve-opening, points created on the graphic display correspond to valve-depression.\n"
	append msg "from 0 = no valve depression (top of the display) to 1 = fully depressed (bottom of display).\n"
	append msg "\n"
	append msg "If there is more than one valve, graphic display entry will be offered for EACH valve,\n"
	append msg "and the SAME NUMBER of values must be marked on the graph for each valve in turn.\n"
	append msg "(Points at the right and left edges of the graphs are ignored).\n"
	append msg "The timing of the valve changes is entered afterwards, via the \"Times\" button.\n"
	append msg "If another valving parameter has already been entered,\n"
	append msg "you can sync parameter changes in the current parameter to those in the existing valving parameter.\n"
	append msg "\n"
	append msg "PARAMETER RANGES\n"
	append msg "\n"
	append msg "Amplitudes (of vibrato,tremolo and noise) are fractions of the mouth pressure, and lie in the range 0 to 1.\n"
	append msg "To find the appropriate range for any other parameter, consult \"Parameter Ranges\".\n"
	append msg "The values you enter will be automatically checked for syntax and range.\n"
	Inf $msg
}
proc BrassHelpOtherFeatures {} {
	set msg "TIME WARPING THE SCORE\n"
	append msg "\n"
	append msg "The \"Time Warp\" button allows the whole time-frame of the score to be expanded or contracted.\n"
	append msg "A Duration value must be in the \"Output Duration\" entry box, for this to work.\n"
	append msg "Time-varying parameters will be appropriately time-warped (if they have the correct syntax).\n"
	append msg "The onset Pressure-increase may be preserved during a timewarp by selecting this option (the default) in the Timewarp window.\n"
	append msg "\n"
	append msg "The \"R\" button for \"Output Duration\" only works after the duration is changed by a Time Warp.\n"
	append msg "\n"
	append msg "RANDOMISING VALUES (\"ra\")\n"
	append msg "\n"
	append msg "Any parameter can be randomised using the \"ra\" buttons.\n"
	append msg "You can specify a range within which random values are selected.\n"
	append msg "Multiple value parameters have all (non-time) values randomised,\n"
	append msg "but \"Pressure\" always retains its initial zero value.\n"
	append msg "\n"
	append msg "SYNCHRONISING DATA CHANGES TO VALVE CHANGES (\"Sy\")\n"
	append msg "\n"
	append msg "Time-variations in any parameter can by synchronised to the valve-opening changes with the \"Sync\" and \"Sy\" buttons.\n"
	append msg "\n"
	append msg "GRABBING AND RESTORING EXISTING DATA (\"R\",\"D\",\"S\",\"F\",\"B\")\n"
	append msg "\n"
	append msg "If Editing an Existing score, you can restore ALL the original values with the \"Restore\" button at the top of the window.\n"
	append msg "You can also restore the original value of a single parameter, using the buttons marked \"R\" on the right of the display.\n"
	append msg "\n"
	append msg "After \"Time Warp\" or Randomisation, \"Restore All\" and \"R\" buttons restore values prior to the Warp or Randomisation.\n"
	append msg "\n"
	append msg "Default Values for individual parameters or ALL parameters can be similarly accessed with \"Defaults\" and \"D\" buttons.\n"
	append msg "\n"
	append msg "The parameter displays can be cleared with \"Clear All\" or the \"C\" buttons.\n"
	append msg "\n"
	append msg "Time-Varying parameter-values can be STORED IN A FILE, (the \"S\" buttons)\n"
	append msg "and grabbed from a File (the \"F\" buttons).\n"
	append msg "\n"
	append msg "Alternatively, parameter values can be BORROWED from another score file, using the \"B\" buttons.\n"
	append msg "\n"
	Inf $msg
}

proc BrassHelpParamRanges {} {
	global nessrange nesstypicalrange nessparamset
	set thiscolor white
	set f .brasshr
	if [Dlg_Create $f "BRASS SCORE PARAMETER RANGES & FORMAT" "set pr_nessbrhelp 0" -borderwidth 2 -bg $thiscolor] {
		button $f.0 -text OK -command "set pr_nessbrhelp 0" -bg $thiscolor -highlightbackground [option get . background {}]
		pack $f.0 -side top -pady 2
		label $f.1 -text "Sampling Rate   96000   88200   48000   44100   32000   24000   22050   16000    ONLY" -bg $thiscolor
		pack $f.1 -side top -anchor w -pady 2
		label $f.2 -text "Output Level   RANGE   >0   TO   1   :::   TYPICAL VALUE    0.95" -bg $thiscolor
		pack $f.2 -side top -anchor w -pady 2
		frame $f.3 -bg $thiscolor
		frame $f.3.nmm -bg $thiscolor
		frame $f.3.000 -bg black -width 1
		frame $f.3.typ -bg $thiscolor
		frame $f.3.111 -bg black -width 1
		frame $f.3.tlo -bg $thiscolor
		frame $f.3.222 -bg black -width 1
		frame $f.3.thi -bg $thiscolor
		frame $f.3.333 -bg black -width 1
		frame $f.3.max -bg $thiscolor
		frame $f.3.444 -bg black -width 1
		frame $f.3.lo  -bg $thiscolor
		frame $f.3.555 -bg black -width 1
		frame $f.3.hi  -bg $thiscolor
		frame $f.3.nmm.000 -bg black -width 1
		pack $f.3.nmm.000  -side top -fill x -expand true
		frame $f.3.typ.000 -bg black -width 1
		pack $f.3.typ.000  -side top -fill x -expand true
		frame $f.3.tlo.000 -bg black -width 1
		pack $f.3.tlo.000  -side top -fill x -expand true
		frame $f.3.thi.000 -bg black -width 1
		pack $f.3.thi.000  -side top -fill x -expand true
		frame $f.3.max.000 -bg black -width 1
		pack $f.3.max.000  -side top -fill x -expand true
		frame $f.3.lo.000  -bg black -width 1
		pack $f.3.lo.000   -side top -fill x -expand true
		frame $f.3.hi.000  -bg black -width 1
		pack $f.3.hi.000   -side top -fill x -expand true
		label $f.3.nmm.ll -text "" -bg $thiscolor
		pack $f.3.nmm.ll -side top
		label $f.3.typ.ll -text "TYPICAL" -bg $thiscolor
		pack $f.3.typ.ll -side top
		label $f.3.tlo.ll -text "From" -bg $thiscolor
		pack $f.3.tlo.ll -side top -anchor w
		label $f.3.thi.ll -text "To" -bg $thiscolor
		pack $f.3.thi.ll -side top -anchor w
		label $f.3.max.ll   -text MAXIMAL -bg $thiscolor
		pack $f.3.max.ll -side top
		label $f.3.lo.ll -text "From" -bg $thiscolor
		pack $f.3.lo.ll -side top -anchor w
		label $f.3.hi.ll -text "To" -bg $thiscolor
		pack $f.3.hi.ll -side top -anchor w
		frame $f.3.nmm.111 -bg black -width 1
		pack $f.3.nmm.111  -side top -fill x -expand true
		frame $f.3.typ.111 -bg black -width 1
		pack $f.3.typ.111  -side top -fill x -expand true
		frame $f.3.tlo.111 -bg black -width 1
		pack $f.3.tlo.111  -side top -fill x -expand true
		frame $f.3.thi.111 -bg black -width 1
		pack $f.3.thi.111  -side top -fill x -expand true
		frame $f.3.max.111 -bg black -width 1
		pack $f.3.max.111  -side top -fill x -expand true
		frame $f.3.lo.111  -bg black -width 1
		pack $f.3.lo.111   -side top -fill x -expand true
		frame $f.3.hi.111  -bg black -width 1
		pack $f.3.hi.111   -side top -fill x -expand true

		foreach nam $nessparamset(sco4) {
			switch -- $nam {
				"instrumentfile" -
				"maxout" -
				"fs" -
				"t" {
					;#	NO RANGE
				}
				default {
					set lo [lindex $nessrange($nam) 0]
					set lo [NumDisplayAdjust $lo]
					set hi [lindex $nessrange($nam) 1]
					set hi [NumDisplayAdjust $hi]
					set tlo [lindex $nesstypicalrange($nam) 0]
					set tlo [NumDisplayAdjust $tlo]
					set thi [lindex $nesstypicalrange($nam) 1]
					set thi [NumDisplayAdjust $thi]
					label $f.3.nmm.$nam -text [GetNessDisplayName $nam] -bg $thiscolor
					pack $f.3.nmm.$nam  -side top -anchor e 
					frame $f.3.nmm.000$nam -bg black -width 1
					pack $f.3.nmm.000$nam -side top -fill x -expand true
					label $f.3.typ.$nam -text ""   -bg $thiscolor
					pack $f.3.typ.$nam  -side top
					frame $f.3.typ.000$nam -bg black -width 1
					pack $f.3.typ.000$nam -side top -fill x -expand true
					label $f.3.tlo.$nam -text $tlo -bg $thiscolor
					pack $f.3.tlo.$nam  -side top -anchor w
					frame $f.3.tlo.000$nam -bg black -width 1
					pack $f.3.tlo.000$nam -side top -fill x -expand true
					label $f.3.thi.$nam -text $thi -bg $thiscolor
					pack $f.3.thi.$nam  -side top -anchor w
					frame $f.3.thi.000$nam -bg black -width 1
					pack $f.3.thi.000$nam -side top -fill x -expand true
					label $f.3.max.$nam -text ""   -bg $thiscolor
					pack $f.3.max.$nam  -side top
					frame $f.3.max.000$nam -bg black -width 1
					pack $f.3.max.000$nam -side top -fill x -expand true
					label $f.3.lo.$nam  -text $lo  -bg $thiscolor
					pack $f.3.lo.$nam   -side top -anchor w
					frame $f.3.lo.000$nam -bg black -width 1
					pack $f.3.lo.000$nam -side top -fill x -expand true
					label $f.3.hi.$nam  -text $hi  -bg $thiscolor
					pack $f.3.hi.$nam   -side top -anchor w
					frame $f.3.hi.000$nam -bg black -width 1
					pack $f.3.hi.000$nam -side top -fill x -expand true
				}
			}
		}
		pack $f.3.nmm -side left 
		pack $f.3.000 -side left -fill y -expand true
		pack $f.3.typ -side left 
		pack $f.3.111 -side left -fill y -expand true
		pack $f.3.tlo -side left
		pack $f.3.222 -side left -fill y -expand true
		pack $f.3.thi -side left 
		pack $f.3.333 -side left -fill y -expand true
		pack $f.3.max -side left
		pack $f.3.444 -side left -fill y -expand true
		pack $f.3.lo  -side left 
		pack $f.3.555 -side left -fill y -expand true
		pack $f.3.hi  -side left
		pack $f.3 -side top  -pady 2
		label $f.4 -text "Valve Opening Parameter Format: " -bg $thiscolor
		label $f.5 -text "Time then vals for each valve, then next time etc." -bg $thiscolor
		label $f.6 -text "T1 v1 v2 v3 ETC... T2 v1 v2 v3 ETC...  T3 ETC" -bg $thiscolor
		pack $f.4 $f.5 $f.6 -side top -anchor w -pady 2
		wm resizable $f 0 0
		bind $f <Return> {set pr_nessbrhelp 1}
		bind $f <Escape> {set pr_nessbrhelp 0}
	}
	set pr_nessbrhelp 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_nessbrhelp $f
	set finished 0
	tkwait variable pr_nessbrhelp
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Neaten up number display

proc NumDisplayAdjust {val} {
	if {$val >= 1000} {
		set val [Engineer $val]
	} elseif {($val > 0.0) && ($val <= 0.0001)} {
		set val [Engineer $val]
	}
	if {[string first "." $val] >= 0} {
		set val [StripTrailingZeros $val]
	}
	return $val
}

#---- NessScore Interface, Select or Edit an instrument file to use in score

proc SelectNessScoreIns {} {
	global nessco nesstype evv pr_neselect nessparam

	if {![info exists nesstype]} {
		Inf "No physical modelling scores on your system"
		return
	}
	foreach nam [array names nesstype] {
		lappend names $nam
	}
	set names [lsort -dictionary $names]
	foreach nam $names {
		if {$nesstype($nam) == "i"} {
			lappend instruments $nam
		}
	}
	if {![info exists instruments]} {
		Inf "No physical modelling instruments on your system"
		return
	}
		
	set f .neselect
	if [Dlg_Create $f "PHYSICAL MODELLING SCORES" "set pr_neselect 0" -borderwidth $evv(BBDR)] {
		set b  [frame $f.b]
		set ll  [frame $f.ll]
		button $b.sel -text "Select" -width 5 -command "set pr_neselect 1" -highlightbackground [option get . background {}]
		button $b.ed  -text "Edit"   -width 5 -command "set pr_neselect 2" -highlightbackground [option get . background {}]
		button $b.vw  -text "View"   -width 5 -command "set pr_neselect 3" -highlightbackground [option get . background {}]
		button $b.q   -text "Quit"   -width 5 -command "set pr_neselect 0" -highlightbackground [option get . background {}]
		pack $b.sel $b.vw $b.ed -side left -padx 2
		pack $b.q -side right
		pack $b -side top -fill x -expand true
		Scrolled_Listbox $ll.ll -width 64 -height 24 -selectmode single
		pack $ll.ll -side top -fill both -expand true
		pack $ll -side top -pady 4
		wm resizable $f 0 0
		bind $f <Escape> {set pr_neselect 0}
	}
	.neselect.ll.ll.list delete 0 end
	foreach item $instruments {
		.neselect.ll.ll.list insert end $item
	}
	.neselect.ll.ll.list selection clear 0 end
	if {[file exists $nessparam(instrumentfile)]} {
		set k [lsearch $instruments $nessparam(instrumentfile)]
		if {$k >= 0} {
			.neselect.ll.ll.list selection set $k
		}
	}
	set pr_neselect 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_neselect $f
	set finished 0
	while {!$finished} {
		tkwait variable pr_neselect
		switch -- $pr_neselect {
			1 -
			2 -
			3 {
				set i [.neselect.ll.ll.list curselection]
				if {![info exists i] || ($i < 0)} {
					Inf "No file selected"
					continue
				} else {
					set fnam [.neselect.ll.ll.list get $i]
				}
				switch -- $pr_neselect {
					1 {
						set nessparam(instrumentfile) $fnam
						if {[GetValveCnt $nessparam(instrumentfile) 0]} {
							set finished 1
						}
					}
					2 {
						NessProfile 1 $fnam
						if {[info exists nessco(insfnam)] && [file exists $nessco(insfnam)]} {
							set nessparam(instrumentfile) $nessco(insfnam)
							unset nessco(insfnam)
							if {[GetValveCnt $nessparam(instrumentfile) 0]} {
								set finished 1
							}
						}
					}
					3 {
						SimpleDisplayTextfile $fnam
					}
				}
			}
			0 {
				set finished 1
			}
		}
	}
	catch {unset nessco(insfnam)}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CreateNessScoreIns {} {
	global nessco
	catch {unset nessco(insfnam)}
	NessProfile 0 0
	if {[info exists nessco(insfnam)] && [file exists $nessco(insfnam)]} {
		set nessparam(instrumentfile) $nessco(insfnam)
		unset nessco(insfnam)
	}
}

proc CheckNescoParam {nam longnam paramval report} {
	global nessparam nessrange nes ness_longparamname

	set paramval [string trim $paramval]
	set nessparam($nam) $paramval			;#	Convert to a normal list format

	if {[string length $paramval] <= 0} {
		if {$report} {
			Inf "No parameter entered for $longnam"
		}
		return 0
	}
	if {($nam != "fs") && ($nam != "instrumentfile")} {
		set lo [lindex $nessrange($nam) 0]		;#	Find valid ranges
		set hi [lindex $nessrange($nam) 1]
	}
	switch -- $nam {
		"fs" {
			if {![IsNumeric $paramval] || ![ValidSrate $paramval]} {
				if {$report} {
					Inf "Invalid value ($paramval) for srate (96000,88200,48000,44100,32000,24000,22050,16000 only)"
				}
				return 0
			}
		}
		"t" {
			if {![IsNumeric $paramval]} {
				if {$report} {
					Inf "Invalid duration entered"
				}
				return 0
			}
			if {($paramval < $lo) || ($paramval > $hi)} {
				if {$report} {
					Inf "Duration out of range ($lo to $hi)"
				}
				return 0
			}
		}
		"instrumentfile" {
			;#	ONLY VALID INSTRUMENT FILES CAN BE INPUT TO THE PARAMETER BOX IN THE FIRST PLACE
		}
		"valveopening" -
		"valvevibfreq" -
		"valvevibamp" {
			set paramval [split $paramval]
			catch {unset items}
			foreach item $paramval {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend items $item
				}
			}
			if {![info exists items]} {
				if {$report} {
					Inf "No parameter entered for $ness_longparamname($nam)"
				}
				return 0
			}
			set vcnt [llength $items]
			if {$vcnt == 1} {							;#	Single valued entries converted to time,val format, for data-testing
				set singlentry 1
				set vvals 0
				set c_cnt 0
				while {$c_cnt < $nes(valvecnt)} {
					lappend vvals $items
					incr c_cnt
				}
				set items $vvals
				incr vcnt $nes(valvecnt)
			}
			set entrycnt [expr $nes(valvecnt) + 1]		;#	Number of numeric entries at each time = (time valve1 valve2 valve2 etc.)
			if {$nam == "valveopening"} {
				set nes(valve_events) [expr $vcnt/$entrycnt] ;# Number of timed valve-settings
			}
			set eventcnt [expr $vcnt/$entrycnt]		
			if {$eventcnt * $entrycnt != $vcnt} {
				if {$report} {
					Inf "Invalid number of values (must be a multiple of $entrycnt) for $ness_longparamname($nam) data"
				}
				return 0
			}
			set cnt 0
			catch {unset lasttime}
			while {$cnt < $vcnt} {
				set val [lindex $items $cnt]
				if {[info exists lasttime]} {
					if {$val <= $lasttime} {
						if {$report} {
							Inf "Times do not increase after $lasttime in $ness_longparamname($nam) data"
						}
						return 0
					}
				} elseif {$val != 0.0} {
					if {$report} {
						Inf "First time in $ness_longparamname($nam) data must be zero"
					}
					return 0
				}
				set lasttime $val
				incr cnt
				set valveno 0
				while {$valveno < $nes(valvecnt)} {
					set val [lindex $items $cnt]
					if {![IsNumeric $val] || ($val < $lo) || ($val > $hi)} {
						if {$report} {
							Inf "Invalid $ness_longparamname($nam) value $val (range $lo to $hi) at time $lasttime"
						}
						return 0
					}
					incr valveno
					incr cnt
				}
			}
			if {[info exists singlentry]} {				;#	If originally a single entry, revert to single entry format
				set items [lindex $items 1]				
				unset singlentry
			}
			set nessparam($nam) $items					;#	Convert data to a proper list format
		}
		default {
			set paramval [split $paramval]
			catch {unset items}
			foreach item $paramval {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend items $item
				}
			}
			if {![info exists items]} {
				if {$report} {
					Inf "No parameter entered for $longnam"
				}
				return 0
			}
			if {[llength $items] == 1} {
				if {![IsNumeric $item] || ($item < $lo) || ($item > $hi)} {
					if {$report} {
						Inf "Invalid value ($item) (range $lo to $hi) for parameter $longnam"
					}
					return 0
				}
			} else {
				set istime 1
				catch {unset lasttime}
				foreach item $items {
					if {![IsNumeric $item]} {
						if {$report} {
							Inf "Invalid value ($item) in parameter $longnam"
						}
						return 0
					}
					if {$istime} {
						if {![info exists lasttime]} {
							if {$item != 0} {
								if {$report} {
									Inf "Times do not begin at zero in parameter $longnam"
								}
								return 0
							}
						} elseif {$lasttime >= $item} {
							if {$report} {
								Inf "Times do not increase after $lasttime in parameter $longnam"
							}
							return 0
						}
						set lasttime $item
					} else {
						if {($item < $lo) || ($item > $hi)} {
							if {$report} {
								Inf "Value ($item) out of range ($lo to $hi) in parameter $longnam"
							}
							return 0
						}
					}
					set istime [expr !$istime]
				}
			}
			set nessparam($nam) $items		;#	Convert data to a proper list format
		}
	}
	return 1
}

#---- Set Brass Score Interface values to Defaults, Original Vals, or Clear the value

proc NessDefault {nam} {
	global nesdef nessparamset nessparam nes_def
	if {$nam == "all"} {
		foreach nnam $nessparamset(sco2) {
			set nessparam($nnam) $nesdef($nnam)
		}
	} else {
		set nessparam($nam)	$nesdef($nam)
		set nes_def($nam) 0
	}
}

proc NessOriginal {nam} {
	global nescorig nessparamset nessparam nes_ori nessco
	if {![info exists nescorig]} {
		Inf "No original values to restore"
		return
	}
	if {$nam == "all"} {
		foreach nnam $nessparamset(sco2) {
			set nessparam($nnam) $nescorig($nnam)
		}
	} else {
		set nessparam($nam) $nescorig($nam)
		set nes_ori($nam) 0
	}
}

proc NessClear {nam} {
	global nessparamset nessparam nes_clr
	if {$nam == "all"} {
		foreach nnam $nessparamset(sco2) {
			set nessparam($nnam) ""
		}
	} else {
		set nessparam($nam) ""
		set nes_clr($nam) 0
	}
}

#---- Load and Save Files of time-varying Brass Score Data

proc LoadNessFile {nam} {
	global nes_fload wl pa nessparam nessrange ness_longparamname pr_nesfload evv nes wstk
	set nes_fload($nam) 0
	catch {unset use_valvecnt}
	switch -- $nam {
		"sr"	-
		"mu"	-
		"sigma"	-
		"h"		-
		"w"		-
		"pressure" -	
		"lip_frequency" -
		"vibfreq"  -
		"tremfreq" {
			set ptyp brk
		}
		"vibamp"	  -
		"tremamp"	  -
		"noiseamp" {
			set ptyp nbrk
		}
		"valvevibfreq" -
		"valvevibamp"  -
		"valveopening" {
			set ptyp vset
		}
	}

	;#	FIND FILES OF APPROPRIATE TYPE

	foreach fnam [$wl get 0 end] {
		set ftyp $pa($fnam,$evv(FTYP))
		switch -- $ptyp {
			"brk" {
				if {[IsABrkfile $ftyp]} {
					lappend fnams $fnam
				}
			}
			"nbrk" {
				if {[IsANormdBrkfile $ftyp]} {
					lappend fnams $fnam
				}
			}
			"vset" {
				if {[IsAListofNumbers $ftyp]} {
					lappend fnams $fnam
				}
			}
		}
	}
	if {![info exists fnams]} {
		Inf "There are no appropriate files on the workspace"
		return
	}

	if {$ptyp == "brk"} {

		;#	CHECK BRKFILES ARE IN RANGE

		set lo [lindex $nessrange($nam) 0]
		set hi [lindex $nessrange($nam) 1]
		foreach fnam $fnams {
			if {($pa($fnam,$evv(MINBRK)) >= $lo) && ($pa($fnam,$evv(MAXBRK)) <= $hi)} {
				lappend nufnams $fnam
			}
		}
		if {![info exists nufnams]} {
			Inf "There are no appropriate files on the workspace"
			return
		}
		set fnams $nufnams

	} elseif {$ptyp == "vset"} {

		;#	CHECK IF A VALVE-COUNT IS ALREADY SPECIFIED BY AN INSTRUMENT-FILE USED IN THE SCORE DATA

		if {[file exists $nessparam(instrumentfile)]} {
			set msg "Use valve count in instrument file $nessparam(instrumentfile) ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set use_valvecnt 1
			}
		}
	}
	set fnams [lsort -dictionary $fnams]
	set origfnams $fnams
	set f .nesfload
	if [Dlg_Create $f "GET DATA FROM FILE" "set pr_nesfload 0" -borderwidth 2] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		button $f0.ok -text "Load File" -width 9 -command "set pr_nesfload 1" -highlightbackground [option get . background {}]
		button $f0.vw -text "View File" -width 9 -command "set pr_nesfload 3" -highlightbackground [option get . background {}]
		button $f0.q   -text "Quit"     -width 9 -command "set pr_nesfload 0" -highlightbackground [option get . background {}]
		pack $f0.ok $f0.vw -side left -padx 2
		pack $f0.q -side right
		pack $f0 -side top -fill x -expand true
		label $f1.vll -text "Number of Valves" -width 16
		entry $f1.ve -textvariable nes(fload_vcnt) -width 4 -state readonly
		label $f1.ex -text "Use Up/Dn Arrows" -fg $evv(SPECIAL) -width 16
		button $f1.vv -text "Select Files" -command "set pr_nesfload 2" -highlightbackground [option get . background {}]
		pack $f1.vll $f1.ve $f1.ex $f1.vv -side left -padx 2
		pack $f1 -side top
		label $f2.tit -text "Possible Data Files on Workspace" -fg $evv(SPECIAL)
		pack $f2.tit -side top -pady 2
		set nes(flodlist) [Scrolled_Listbox $f2.ll -width 64 -height 24 -selectmode single]
		pack $f2.ll -side top -fill both -expand true
		pack $f2 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Up>   {IncrValveCnt load 0}
		bind $f <Down> {IncrValveCnt load 1}
		bind $f <Return> {set pr_nesfload 1}
		bind $f <Escape> {set pr_nesfload 0}
	}
	$nes(flodlist) delete 0 end
	if {$ptyp == "vset"} {
		.nesfload.0.ok  config -text "" -state disabled -bg [option get . background {}] -bd 0
		.nesfload.0.vw  config -text "" -state disabled -bg [option get . background {}] -bd 0
		.nesfload.1.vll config -text "Number of Valves"
		.nesfload.1.ve  config -state readonly -readonlybackground [option get . background {}] -bd 2
		if {[info exists use_valvecnt]} {
			set nes(fload_vcnt) $nes(valvecnt)
		} else {
			set nes(fload_vcnt) 0
		}
		.nesfload.1.ex  config -text "Use Up/Dn Arrows" -fg $evv(SPECIAL)
		.nesfload.1.vv  config -text "Select Files" -command "set pr_nesfload 2" -bd 2
		.nesfload.2.tit config -text "" -fg $evv(SPECIAL)
		bind $f <Up>   {IncrValveCnt load 0}
		bind $f <Down> {IncrValveCnt load 1}
	} else {
		foreach fnam $fnams {
			$nes(flodlist) insert end $fnam
		}
		.nesfload.0.ok  config -text "Load File" -state normal -bd 2 -bg $evv(EMPH)
		.nesfload.0.vw  config -text "View File" -state normal -bd 2
		.nesfload.1.vll config -text ""
		set nes(fload_vcnt) ""
		.nesfload.1.ve  config -state disabled -bd 0 -bg [option get . background {}]
		.nesfload.1.ex  config -text ""
		.nesfload.1.vv  config -text "" -state disabled -bd 0 -bg [option get . background {}] 
		.nesfload.2.tit config -text "Possible Data Files on Workspace" -fg $evv(SPECIAL)
		bind $f <Up>   {}
		bind $f <Down> {}
	}
	wm title $f "GET $ness_longparamname($nam) DATA FROM FILE"
	set pr_nesfload 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_nesfload $nes(flodlist)
	set finished 0
	while {!$finished} {
		tkwait variable pr_nesfload
		switch -- $pr_nesfload {
			2 {					
				;#	SELECT FILES, FOR VALVE-OPENING AND VALVE-VIBRATO CASES ONLY
				
				$nes(flodlist) delete 0 end
				if {$nes(fload_vcnt) <= 0} {
					Inf "Valve count not set (use \"up\"/\"down\" arrows)"
					continue
				}
				Block "Checking Workspace Files"
				catch {unset nufnams}
				set setsize $nes(fload_vcnt)
				incr setsize			;#	Data must be in groups of valve-cnt+1(time value)
				foreach fnam $origfnams {
					set numsize $pa($fnam,$evv(NUMSIZE))
					set div [expr $numsize/$setsize]
					if {($div * $setsize) == $numsize} {
						lappend nufnams $fnam
					}
				}
				if {![info exists nufnams]} {
					Inf "No appropriate files on the workspace, for a $nes(fload_vcnt) valve instrument"
					.nesfload.0.ok  config -text "" -bd 0 -state disabled -bg [option get . background {}]
					.nesfload.0.vw  config -text "" -bd 0 -state disabled -bg [option get . background {}]
					UnBlock
					continue
				}
				set fnams $nufnams
				catch {unset nufnams}
				set lo [lindex $nessrange($nam) 0]
				set hi [lindex $nessrange($nam) 1]
				foreach fnam $fnams {
					set OK 1
					catch {unset outlist}
					if [catch {open $fnam "r"} zit] {
						Inf "Cannot open file $fnam to check its contents"
						continue
					}
					set cnt 0
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						set line [split $line]
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] <= 0} {
								continue
							}
							if {$cnt == 0} {
								if {$item != 0} {				;#	INITIAL TIME MUST BE ZERO
									set OK 0
									break
								}
								set lasttime $item
							} elseif {($cnt % $setsize) == 0} {
								if {$lasttime >= $item} {		;#	TIMES MUST INCREASE
									set OK 0
									break
								}
								set lasttime $item
							} else {							;#	VALUES MUST BE IN RANGE
								if {($item < $lo) || ($item > $hi)} {
									set OK 0
									break
								}
							}
							lappend outlist $item
							incr cnt
						}
						if {!$OK} {
							break
						}
					}
					close $zit
					if {![info exists outlist]} {
						set OK 0
					}
					if {$OK} {
						lappend nufnams $fnam
					}
				}
				UnBlock
				if {![info exists nufnams]} {
					Inf "No appropriate files on the workspace, for a $nes(fload_vcnt) valve instrument"
					.nesfload.0.ok  config -text "" -bd 0 -state disabled -bg [option get . background {}]
					.nesfload.0.vw  config -text "" -bd 0 -state disabled -bg [option get . background {}]
					continue
				}
				set fnams $nufnams
				foreach fnam $fnams {
					$nes(flodlist) insert end $fnam
				}
				.nesfload.2.tit config -text "Possible Data Files on Workspace"
				.nesfload.0.ok  config -text "Load File" -state normal -bd 2 -bg $evv(EMPH)
				.nesfload.0.vw  config -text "View File" -state normal -bd 2
			}
			1 {
				;#	SELECT AND LOAD A FILE

				set i [$nes(flodlist) curselection]
				if {![info exists i] || ($i == -1)} {
					Inf "No file selected"
					continue
				}
				set thisfnam [$nes(flodlist) get $i]
				if [catch {open $thisfnam "r"} zit] {
					Inf "Cannot open file $thisfnam"
					continue
				}
				catch {unset outlist}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					set line [split $line]
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						lappend outlist $item
					}
				}
				close $zit
				set nessparam($nam) $outlist
				set finished 1
			}
			3 {
				;#	VIEW FILE

				set i [$nes(flodlist) curselection]
				if {![info exists i] || ($i == -1)} {
					Inf "No file selected"
					continue
				}
				set thsfnam [$nes(flodlist) get $i]
				SimpleDisplayTextfile $thsfnam
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc IncrValveCnt {typ down} {
	global nes
	if {$typ == "load"} {
		if {$down} {
			incr nes(fload_vcnt) -1
			if {$nes(fload_vcnt) < 0} {
				set nes(fload_vcnt) 0
			}
		} else {
			incr nes(fload_vcnt)
			if {$nes(fload_vcnt) > 100} {
				set nes(fload_vcnt) 100
			}
		}
	} else {
		if {$down} {
			incr nes(fsave_vcnt) -1
			if {$nes(fsave_vcnt) < 0} {
				set nes(fsave_vcnt) 0
			}
		} else {
			incr nes(fsave_vcnt)
			if {$nes(fsave_vcnt) > 100} {
				set nes(fsave_vcnt) 100
			}
		}
	}
}

#--- Save created or edited Ness Score File data to a ".m" format file
		
proc SaveNessScoreFile {nam} {
	global nes_fsave nes_data_fnam pr_nesfsave nessparam ness_longparamname nessrange evv nes wstk
	set nes_fsave($nam) 0
	if {[IsScoreValveParameter $nam]} {
		set vals [string trim $nessparam($nam)]
		if {[string length $vals] == 0} {
			Inf "No $ness_longparamname($nam) data to save"
			return
		}
		set vals [split $vals]
		foreach val $vals {
			set val [string trim $val]
			if {[string length $val] > 0} {
				lappend nuvals $val
			}
		}
		set nessparam($nam) $nuvals
		if {[llength $nessparam($nam)] < 2} {
			if {$nam == "valveopening"} {
				Inf "Invalid valve opening data"
				return
			} else {
				Inf "This is not time-varying data."
				return
			}
		}
		foreach val $nessparam($nam) {
			if {![IsNumeric $val] || ($val < 0)} {
				Inf "Invalid $ness_longparamname($nam) data"
				return
			}
		}
		if {[file exists $nessparam(instrumentfile)]} {
			set msg "Use valve count in instrument file $nessparam(instrumentfile) ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set use_valvecnt 1
			}
		}
	} elseif {![CheckNescoParam $nam $ness_longparamname($nam) $nessparam($nam) 1]} {
		return
	}
	if {[llength $nessparam($nam)] == 1} {
		Inf "This is not time-varying data."
		return
	}
	set f .nesfsave
	if [Dlg_Create $f "SAVE DATA TO FILE" "set pr_nesfsave 0" -borderwidth 2] {
		set f0  [frame $f.0]
		set f1  [frame $f.1]
		set f2  [frame $f.2]
		button $f0.ok -text "Save"    -width 5 -command "set pr_nesfsave 1" -highlightbackground [option get . background {}]
		button $f0.q   -text "Quit"   -width 5 -command "set pr_nesfsave 0" -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.q -side right
		pack $f0 -side top -fill x -expand true
		label $f1.vll -text "Number of Valves" -width 16
		entry $f1.ve -textvariable nes(fsave_vcnt) -width 4 -state readonly
		label $f1.ex -text "Use Up/Dn Arrows" -fg $evv(SPECIAL) -width 16
		button $f1.vv -text "Set Valve Count" -width 16 -command "set pr_nesfsave 2" -highlightbackground [option get . background {}]
		pack $f1.vll $f1.ve $f1.ex $f1.vv -side right -padx 2
		pack $f1 -side top
		label $f2.ll -text "Data File Name"
		entry $f2.e -textvariable nes_data_fnam -width 24
		pack $f2.ll $f2.e -side left -padx 2
		pack $f2 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Up>   {IncrValveCnt save 0}
		bind $f <Down> {IncrValveCnt save 1}
		bind $f <Return> {set pr_nesfsave 1}
		bind $f <Escape> {set pr_nesfsave 0}
	}
	wm title $f "SAVE $ness_longparamname($nam) DATA TO FILE"
	set nes_data_fnam ""
	set pr_nesfsave 0
	set finished 0
	raise $f
	if {[IsScoreValveParameter $nam]} {
		.nesfsave.0.ok  config -text "" -bd 0 -state disabled -bg [option get . background {}]
		.nesfsave.1.vll config -text "Number of Valves"
		if {[info exists use_valvecnt]} {
			set nes(fsave_vcnt) $nes(valvecnt)
		} else {
			set nes(fsave_vcnt) 0
		}
		.nesfsave.1.ve  config -state readonly -bd 2
		.nesfsave.1.ex  config -text "Use Up/Dn Arrows"
		.nesfsave.1.vv  config -text "Set Valve Count" -state normal -bd 2
		bind $f <Up>   {IncrValveCnt save 0}
		bind $f <Down> {IncrValveCnt save 1}
		My_Grab 0 $f pr_nesfsave $f.1.ve
	} else {
		.nesfsave.0.ok config -text "Save" -bd 2 -state normal
		set nes(fsave_vcnt) ""
		.nesfsave.1.vll config -text ""
		.nesfsave.1.ve  config -state disabled -bg [option get . background {}] -bd 0
		.nesfsave.1.ex  config -text ""
		.nesfsave.1.vv  config -text "" -state disabled -bg [option get . background {}] -bd 0
		bind $f <Up>   {}
		bind $f <Down> {}
		My_Grab 0 $f pr_nesfsave $f.2.e
	}
	set finished 0
	while {!$finished} {
		tkwait variable pr_nesfsave
		switch -- $pr_nesfsave {
			2 {
				if {$nes(fsave_vcnt) <= 0} {
					Inf "Valve count not set (use \"up\"/\"down\" arrows)"
					continue
				}
				set setsize $nes(fsave_vcnt)
				incr setsize			;#	Data must be in groups of valve-cnt+1(time value)
				set numsize [llength $nessparam($nam)]
				set div [expr $numsize/$setsize]
				if {($div * $setsize) != $numsize} {
					Inf "Wrong number of entries for a $nes(fsave_vcnt) valve instrument"
					.nesfsave.0.ok  config -text "" -bd 0 -state disabled -bg [option get . background {}]
					continue
				}
				set cnt 0
				set OK 1
				set lo [lindex $nessrange($nam) 0]
				set hi [lindex $nessrange($nam) 1]
				while {$cnt < $numsize} {
					set val [lindex $nessparam($nam) $cnt]
					if {$cnt == 0} {
						if {$val != 0} {
							Inf "Initial time is not zero"	
							set OK 0
							break
						}
						set lasttime $val
					} elseif {($cnt % $setsize) == 0} {
						if {$lasttime >= $val} {
							Inf "Times do not increase, if this is $nes(fsave_vcnt) valve data"	
							set OK 0
							break
						}
						set lasttime $val
					} else {
						if {($val < $lo) || ($val > $hi)} {
							Inf "Values out of range ($lo to $hi), if this is $nes(fsave_vcnt) valve data"	
							set OK 0
							break
						}
					}
					incr cnt
				}
				if {!$OK} {
					continue
				}
				.nesfsave.0.ok config -text "Save" -bd 2 -state normal
			}
			1 {
				if {[string length $nes_data_fnam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				set outfnam [string tolower $nes_data_fnam]
				append outfnam $evv(TEXT_EXT)
				if {[file exists $outfnam]} {
					Inf "File $outfnam already exists : please choose a different name"
					continue
				}
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot open file $outfnam to write the data"
					continue
				}
				if {[IsScoreValveParameter $nam]} {
					set setsize $nes(fsave_vcnt)
					incr setsize
					set cnt 0
					foreach val $nessparam($nam) {
						if {($cnt % $setsize) == 0} {
							catch {unset line}
						}
						lappend line $val
						incr cnt
						if {($cnt % $setsize) == 0} {
							puts $zit $line
						}
					}
				} else {
					foreach {time val} $nessparam($nam) {
						set line [list $time $val]
						puts $zit $line
					}
				}
				close $zit
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "File $outfnam is on the workspace"
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

#---  Get a value from inside an existing Brass Instrument Score File

proc InjectFromNessScore {nam} {
	global nesstype nes_finj nessparam ness_longparamname ness_longparamname pr_nesinject evv nes nessco_fnam
	set nes_finj($nam) 0
	if {![info exists nesstype]} {
		Inf "No physical modelling data on your system"
		return
	}
	foreach nnam [array names nesstype] {
		lappend names $nnam
	}
	set names [lsort -dictionary $names]
	foreach nnam $names {
		if {$nesstype($nnam) == "s"} {
			lappend scores $nnam
		}
	}
	if {[info exists scores]} {
		set k [lsearch $scores $nessco_fnam]
		if {$k >= 0} {
			set scores [lreplace $scores $k $k]
			if {[llength $scores] <= 0} {
				unset scores
			}
		}
	}
	if {![info exists scores]} {
		Inf "There are no other physical modelling scores on your system"
		return
	}

	switch -- $nam {
		"sr" { 
			set nnam Sr
		}
		"h" {
			set nnam "H"
		}
		"t" {
			set nnam "T"
		}
		default {
			set nnam $nam
		}
	}
	set searchstr $nnam
	set jump [string length $nnam]			;#	Number of characters to jump over, to find start of value
	if {$nnam == "instrumentfile"} {
		append searchstr "="
		incr jump 1
	} else {
		append searchstr "=\["
		incr jump 2
	}
	set f .nesinject
	if [Dlg_Create $f "GET DATA FROM SCORE FILE" "set pr_nesinject 0" -borderwidth 2] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		button $f0.ok -text "Load Data" -width 9 -command "set pr_nesinject 1" -highlightbackground [option get . background {}]
		button $f0.vw -text "View File" -width 9 -command "set pr_nesinject 2" -highlightbackground [option get . background {}]
		button $f0.q   -text "Quit"     -width 9 -command "set pr_nesinject 0" -highlightbackground [option get . background {}]
		pack $f0.ok $f0.vw -side left -padx 2
		pack $f0.q -side right
		pack $f0 -side top -fill x -expand true
		label $f1.tit -text "Physical Modelling Score Files" -fg $evv(SPECIAL)
		pack $f1.tit -side top -pady 2
		set nes(injlist) [Scrolled_Listbox $f1.ll -width 64 -height 24 -selectmode single]
		pack $f1.ll -side top -fill both -expand true
		pack $f1 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Return> {set pr_nesinject 1}
		bind $f <Escape> {set pr_nesinject 0}
	}
	$nes(injlist) delete 0 end
	foreach fnam $scores {
		$nes(injlist) insert end $fnam
	}
	wm title $f "GET $ness_longparamname($nam) DATA FROM SCORE FILE"
	set pr_nesinject 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_nesinject $nes(injlist)
	set finished 0
	while {!$finished} {
		tkwait variable pr_nesinject
		switch -- $pr_nesinject {
			1 {
				;#	SELECT AND LOAD A FILE

				set i [$nes(injlist) curselection]
				if {![info exists i] || ($i == -1)} {
					Inf "No file selected"
					continue
				}
				set thisfnam [$nes(injlist) get $i]
				if [catch {open $thisfnam "r"} zit] {
					Inf "Cannot open file $thisfnam"
					continue
				}
				catch {unset ongoingvals}
				catch {unset vals}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[llength $line] <= 0} {
						continue
					}
					if {[info exists ongoingvals]} {			;#	IF AN ONGOING SET OF VALUES ALREADY EXISTS
						set k [string first "\]" $line]			;#	Look for end-bracket, end of all values
						if {$k >= 0} {
							incr k -1
							set line [string range $line 0 $k]	;#	If it exists
							set line [split $line ',']			;#	concatenate these final vals with existing vals
							set vals [concat $ongoingvals $line]
							break
						} else {								;#	IF no end-bracket, look for end of this group of values	
							set k [string first ";" $line]
							incr k -1
							set line [string range $line 0 $k]
							set line [split $line ","]			;#	concatenate these vals with the ongoing vals
							set ongoingvals [concat $ongoingvals $line]
						}
					} else {									;#	BUT IF NOT YET FOUND ANY VALUES
						set k [string first $searchstr $line]	;#	Look for initial search string, to locate start of values
						if {$k >= 0} {							;#	If this is found
							incr k $jump
							set line [string range $line $k end]
							set k [string first "\]" $line]		;#	Look for end of values
							if {$k >= 0} {
								incr k -1						;#	If end of values found	
								set line [string range $line  0 $k]
								set line [split $line ","]
								if {([llength $line] == 2) && ([lindex $line 0] == 0)} {
									set vals [lindex $line 1]	;#	Return a single "0,val" pair as just "val"
								} else {
									set vals $line				;#	And otherwise return "time val" pairs list
								}
								break
							} else {							;#	If end of values not found
								set k [string first ";" $line]	;#	Look for end of this set of values
								incr k -1						;#	and establish these as an ongoing set of values
								set line [string range $line 0 $k]
								set ongoingvals [split $line ","]
							}
						}
					}
				}
				if {![info exists vals]} {
					Inf "Failed to find value for $ness_longparamname($nam)"
					continue
				}
				if {$nam == "instrumentfile"} {
					set k [string first "'" $vals]
					incr k 1
					set vals [string range $vals $k end]  
					set k [string first "'" $vals]
					incr k -1
					set vals [string range $vals 0 $k]  
					append vals $evv(NESS_EXT)
				} else {
					catch {unset nuvals}
					foreach item $vals { 
						if {[IsEngineeringNotation $item]} {
							set item [UnEngineer $item]
						}
						lappend nuvals $item
					}
					set vals $nuvals
					if {[IsScoreValveParameter $nam]} {
						set len [llength $vals]
						set setsize $nes(valvecnt)
						incr setsize
						set div [expr $len / $setsize]
						if {($div * $setsize) != $len} {
							Inf "Values for ness_longparamname($nam) not compatible with $nes(valvecnt) valve instrument"
							continue
						}
						set cnt $setsize
						set lasttime 0.0
						set OK 1
						while {$cnt < $len} {
							set val [lindex vals $cnt]
							if {$lasttime >= $val} {
								Inf "Values for ness_longparamname($nam) not compatible with $nes(valvecnt) valve instrument"
								set OK 0
								break
							}
							set lasttime $val
							incr cnt $setsize
						}
						if {!$OK} {
							continue
						}
					}
				}
				set nessparam($nam) $vals
				set finished 1
			}
			2 {
				;#	VIEW FILE

				set i [$nes(injlist) curselection]
				if {![info exists i] || ($i == -1)} {
					Inf "No file selected"
					continue
				}
				set thsfnam [$nes(injlist) get $i]
				SimpleDisplayTextfile $thsfnam
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Sync time-changing parameter(s) to valve-changes

proc NessSync {nam} {
	global nessparam nes nessparamset nes_sync ness_longparamname
	if {![CheckNescoParam valveopening $ness_longparamname(valveopening) $nessparam(valveopening) 1]} {
		return
	}
	if {![info exists nes(valvecnt)]} {
		if {![file exists $nessparam(instrumentfile)]} {
			set msg "No instrument valve-count information"
			return
		} elseif {![GetValveCnt $nessparam(instrumentfile) 1]} {
			return
		}
	}
	set grouping [expr $nes(valvecnt) + 1]
	set len [llength $nessparam(valveopening)]
	set cnt 0
	while {$cnt < $len} {
		lappend times [lindex $nessparam(valveopening) $cnt]
		incr cnt $grouping
	}
	set timeslen [llength $times]
	if {$timeslen <= 1} {
		Inf "No valve changes to sync to"
		return
	}
	if {$nam == "all"} {
		foreach nnam $nessparamset(sco2) {
			switch -- $nnam {
				"valvevibfreq" -
				"valvevibamp" {
					if {![CheckNescoParam $nnam $ness_longparamname($nnam) $nessparam($nnam) 0]} {
						continue
					}
					set grouping [expr $nes(valvecnt) + 1]
				}
				"sr" -
				"mu" -
				"sigma" -
				"h" -
				"w" -
				"pressure" -
				"lip_frequency" -
				"vibfreq" -
				"vibamp" -
				"tremfreq" -
				"tremamp" -
				"noiseamp" {
					if {![CheckNescoParam $nnam $ness_longparamname($nnam) $nessparam($nnam) 0]} {
						continue
					}
					set grouping 2
				}
			}
			set paramlen [expr [llength $nessparam($nnam)] / $grouping]
			if {$paramlen != $timeslen} {
				continue
			}
			set cnt 0
			set tcnt 0
			while {$tcnt < $timeslen} {
				set thistime [lindex $times $tcnt]
				set nessparam($nnam) [lreplace $nessparam($nnam) $cnt $cnt $thistime]
				incr cnt $grouping
				incr tcnt
			}
		}
	} else {
		set nes_sync($nam) 0
		if {![CheckNescoParam $nam $ness_longparamname($nam) $nessparam($nam) 1]} {
			return
		}
		switch -- $nam {
			"valvevibfreq" -
			"valvevibamp" {
				set grouping [expr $nes(valvecnt) + 1]
			}
			default {
				set grouping 2
			}
		}
		set paramlen [expr [llength $nessparam($nam)] / $grouping]
		if {$paramlen != $timeslen} {
			Inf "$ness_longparamname($nam) does not vary with valve-opening"
			return
		}
		set cnt 0
		set tcnt 0
		while {$tcnt < $timeslen} {
			set thistime [lindex $times $tcnt]
			set nessparam($nam) [lreplace $nessparam($nam) $cnt $cnt $thistime]
			incr cnt $grouping
			incr tcnt
		}
	}
}

#--- Time-warp all data in a brass score

proc NessTimeWarp {} {
	global pr_nestwarp nessco nes wstk nessparamset nessparam evv ness_longparamname nescorig
	.nessco.t.e config -background [option get . background {}]
	if {[string length $nessparam(t)] <= 0} {
		Inf "No duration entered"
		.nessco.t.e config -background $evv(EMPH)
		focus .nessco.t.e 
		return
	}
	if {![IsNumeric $nessparam(t)] || ($nessparam(t) < $nes(minscoredur)) || ($nessparam(t) > $nes(maxscoredur))} {
		Inf "Invalid duration (range $nes(minscoredur) to $nes(maxscoredur))"
		.nessco.t.e config -background $evv(EMPH)
		focus .nessco.t.e 
		return
	}
	set f .nestwarp
	if [Dlg_Create $f "TIME WARP THE SCORE FILE" "set pr_nestwarp 0" -borderwidth 2] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		button $f0.ok -text "Warp Time" -width 9 -command "set pr_nestwarp 1" -highlightbackground [option get . background {}]
		button $f0.q   -text "Quit"     -width 9 -command "set pr_nestwarp 0" -highlightbackground [option get . background {}]
		pack $f0.ok -side left -padx 2
		pack $f0.q -side right
		pack $f0 -side top -fill x -expand true
		label $f1.ll -text "Warp Value (>0)"
		entry $f1.e -textvariable nes(twarp) -width 8
		set nes(twarp) ""
		pack $f1.ll $f1.e -side left -padx 2
		pack $f1 -side top -pady 2
		checkbutton $f.cb -text "Retain initial pressure onset" -variable nes(ponset)
		pack $f.cb -side top -pady 2
		set nes(ponset) 1
		wm resizable $f 0 0
		bind $f <Return> {set pr_nestwarp 1}
		bind $f <Escape> {set pr_nestwarp 0}
	}
	set pr_nestwarp 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_nestwarp $f.1.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_nestwarp
		switch -- $pr_nestwarp {
			1 {
				if {[string length $nes(twarp)] <= 0} {
					Inf "No time warp value entered"
					continue
				}
				if {![IsNumeric $nes(twarp)] || ($nes(twarp) <= 0.0)} {
					Inf "Invalid time warp value"
					continue
				}
				set outdur [expr $nessparam(t) * $nes(twarp)]
				if {($outdur < $nes(minscoredur)) || ($outdur > $nes(maxscoredur))} {
					Inf "New output duration ($outdur) is out of range ($nes(minscoredur) to $nes(maxscoredur))"
					continue
				}
				if {$outdur > $nes(hiscoredur)} {
					set msg "New output duration ($outdur) is very long : do you want to proceed ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				set dovwarp 1
				catch {unset times}

				;#	CHECK FOR PARAMS WITH (POSSIBLY) SEVERAL VALVE ENTRIES, IF NUMBER OF INSTRUMENT VALVES IS KNOWN

				if {![info exists nes(valvecnt)]} {
					if {![file exists $nessparam(instrumentfile)]} {
						set dovwarp 0
					} elseif {![GetValveCnt $nessparam(instrumentfile) 1]} {
						set dovwarp 0
					}
				}
				;#	IF NUMBER OF INSTRUMENT VALVES IS KNOWN, CHECK IF VALVE-POSITIONS CHANGE

				if {$dovwarp} {
					set grouping [expr $nes(valvecnt) + 1]
					if {![CheckNescoParam valveopening $ness_longparamname(valveopening) $nessparam(valveopening) 0]} {
						set dovwarp 0
					} else {
						set len [llength $nessparam(valveopening)]
						set cnt 0
						while {$cnt < $len} {
							lappend times [lindex $nessparam(valveopening) $cnt]
							incr cnt $grouping
						}
						set timeslen [llength $times]
						if {$timeslen <= 1} {		;#	No time-variation to warp
							set dovwarp 0
						}
					}
				}

				;#	IF VALVE-POSITIONS CHANGE, CHECK PARAMS WITH (POSSIBLY) SEVERAL VALVE ENTRIES 

				if {$dovwarp} {
					set grouping [expr $nes(valvecnt) + 1]
					foreach nam $nes(valving_params) {
						if {$nam == "valveopening"} {
							set len [llength $nessparam($nam)]
						} else {
							if {![CheckNescoParam $nam $ness_longparamname($nam) $nessparam($nam) 0]} {
								continue			;#	Not valid entry
							}
							if {[llength $nessparam($nam)] < $grouping} {
								continue			;#	Not time-varying
							}
							set len [llength $nessparam($nam)]
							set paramlen [expr $len / $grouping]
							if {$paramlen != $timeslen} {
								continue			;#	Entries must tally with those in valveopening data
							}
						}
						set cnt 0
						set nescorig($nam) $nessparam($nam)
						while {$cnt < $len} {
							set thistime [lindex $nessparam($nam) $cnt]
							set thistime [expr $thistime * $nes(twarp)]
							set nessparam($nam) [lreplace $nessparam($nam) $cnt $cnt $thistime]
							incr cnt $grouping
						}
					}
				}

				;#	CHECK OTHER PARAMS FOR TIME-CHANGE

				foreach nam $nessparamset(sco2) {
					set grouping 2
					switch -- $nam {
						"sr" -
						"mu" -
						"sigma" -
						"h" -
						"w" -
						"pressure" -
						"lip_frequency" -
						"vibfreq" -
						"vibamp" -
						"tremfreq" -
						"tremamp" -
						"noiseamp" {
							if {![CheckNescoParam $nam $ness_longparamname($nam) $nessparam($nam) 0]} {
								continue			;#	Not valid entry
							}
							if {[llength $nessparam($nam)] < $grouping} {
								continue			;#	Not time-varying
							}
						}
						default {
							continue				;#	Ignore other params
						}
					}
					set len [llength $nessparam($nam)]
					set paramlen [expr $len / $grouping]
					if {($paramlen * $grouping) != $len} {
						continue					;#	Not valid time-varying entry
					}
					set cnt 0
					set nescorig($nam) $nessparam($nam)
					while {$cnt < $len} {
						set thistime [lindex $nessparam($nam) $cnt]
						if {($nam == "pressure") && ($cnt == $grouping) && $nes(ponset)} {
							incr cnt $grouping
							continue
						}
						set thistime [expr $thistime * $nes(twarp)]
						set nessparam($nam) [lreplace $nessparam($nam) $cnt $cnt $thistime]
						incr cnt $grouping
					}
				}
				set nescorig(t) $nessparam(t)
				set nessparam(t) $outdur				;#	Finally, reset actual duration
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

#--- Call to NessDisplay from ScoreFile Editing Window

proc NessDisplayX {input paramname fnam} {
	global nesorig nes_lastdisplaycall nes_displayconstants nessparam nes ness_longparamname wstk

	if {[info exists nes_lastdisplaycall]} {

		;#	IF NessDisplay HAS BEEN PREVIOUSLY CALLED

		if {$paramname == $nes_lastdisplaycall} {

			;#	WER'E CALLING NessDisplay AGAIN, WITH THE SAME PARAM, SO DISPLAY PARAMETERS HAVE NOT CHANGED

		} else {

			;#	WER'E CALLING NessDisplay WITH A NEW PARAMETER

			;#	REMEMBER THE DISPLAY CONSTANTS FOR THE PREVIOUS PARAMETER

			set nes_displayconstants($nes_lastdisplaycall) [list $nesorig(lo) $nesorig(hi) $nesorig(valsco) $nesorig(dur)]

			;#	IF  DISPLAY CONSTANTS EXIST FOR THE CURRENT PARAMETER, LOAD THEM

			if {[info exists nes_displayconstants($paramname)]} {
				set nesorig(lo)		[lindex $nes_displayconstants($paramname) 0]
				set nesorig(hi)		[lindex $nes_displayconstants($paramname) 1]
				set nesorig(valsco)	[lindex $nes_displayconstants($paramname) 2]
				set nesorig(dur)	[lindex $nes_displayconstants($paramname) 3]
			} else {

			;#	IF  DISPLAY CONSTANTS DON'T EXIST, UNSET THE DISPLAY PARAMETERS

				catch {unset nesorig}
			}
	
			;#	REMEMBER THE NEW PARAMETER CALLED

			set nes_lastdisplaycall $paramname
		}
	} else {
	
		;#	IF NessDisplay HAS NOT BEEN PREVIOUSLY CALLED (BY ANY SCORE PARAMETER), UNSET THE DISPLAY PARAMETERS

		catch {unset nesorig}
	}

	;#	FINALLY CALL NessDisplay

	if {[IsScoreValveParameter  $paramname]} {
		if {![info exists nes(valvecnt)]} {
			if {![file exists $nessparam(instrumentfile)]} {
				Inf "No valve count information available : specify instrument file first"
				return
			} elseif {![GetValveCnt $nessparam(instrumentfile) 1]} {
				return
			}
		}
		set nes(valvecheck) 1		;#	i.e. Check all entries have same number of valve position-changes as 1st entry

		if {[ValidValveChangingDataAlreadyExistsAndSyncToIt $paramname]} {

			set nes(valvecheck) 0	;#	i.e. Check all entries have same number of valve position-changes as existing valving parameter

		}
		set nes(not_valvedisplay) 0
		set nes(valveopeningdisplaycnt) 1
		catch {unset nessparam(provisional)}
		set nes(provisional_param) $paramname
		while {$nes(valveopeningdisplaycnt) <= $nes(valvecnt)} {
			if {![NessDisplay 0 0 $paramname $fnam 0 0]} {
				catch {unset nessparam(provisional)}
				break
			}
			incr nes(valveopeningdisplaycnt)
		}
		set nes(not_valvedisplay) 1
	} else {
		set nes(not_valvedisplay) 1
		NessDisplay 0 $input $paramname $fnam 0 0
	}
	return
}

#--- Does Valid valve-changing data already exist, amd should we sync to it ??

proc ValidValveChangingDataAlreadyExistsAndSyncToIt {paramname} {
	global nes ness_longparamname nessparam wstk 
	foreach nam $nes(valving_params) {
		if {$nam != $paramname} {
			if {[CheckNescoParam $nam $ness_longparamname($nam) $nessparam($nam) 0] && ([llength $nessparam($nam)] > 1)} {
				set msg "Sync $ness_longparamname($paramname) changes to the changes in $ness_longparamname($nam) ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set nes(valve_eventcnt) [expr [llength $nessparam($nam)] / ($nes(valvecnt) + 1)]
					return 1
				} 
			}
		}
	}
	return 0
}

#--- Is this a valving parameter ?

proc IsScoreValveParameter {nam} {
	global nes
	if {[lsearch $nes(valving_params) $nam] >= 0} {
		return 1
	}
	return 0
}

#--- Display an Instrument File, if it exists 

proc NessDisplayInstrumentFile {} {
	global nessparam
	if {[string length $nessparam(instrumentfile)] <= 0} {
		Inf "No instrument file specified"
		return
	} elseif {![file exists $nessparam(instrumentfile)]} {
		Inf "Instrument file $nessparam(instrumentfile) does not exist"
		return
	}
	SimpleDisplayTextfile $nessparam(instrumentfile)
}

#---- Concatenate the valve-opening data from NessCreate

proc ValveChangesGrab {paramname} {
	global nesnak_list nes nessparam ness_longparamname wstk
	if {![info exists nesnak_list]} {
		return 0
	}
	if {$nes(valveopeningdisplaycnt) == 1} {
		set nessparam(provisional) {}
	}
	set len [llength $nesnak_list]
	incr len -2										;#	Don't cont edgepoints of data
	if {$len <= 0} {
		Inf "No $ness_longparamname data entered"
		return 0
	}
	set nesnak_list [lrange $nesnak_list 1 $len]	;#	Drop edge points of data

	if {$nes(valveopeningdisplaycnt) == 1} {
		set nes(valve_eventcnt) $len				;#	Use to check that all valves have same number of entries
	}
	foreach item $nesnak_list {						;#	nesnak_list has y vals only
		if {$paramname == "valveopening"} {
			if {$item >= 0.95} {
				set item 1
			}
			if {$item <= 0.05} {
				set item 0
			}
		}
		lappend nessparam(provisional) $item
	}
	if {$nes(valveopeningdisplaycnt) == $nes(valvecnt)} {
		if {$nes(valve_eventcnt) == 1} {							;#	If only ONE valving event, set it at time zero

			set nessparam($nes(provisional_param)) [concat 0 $nessparam(provisional)]

		} elseif {$nes(valvecheck) == 0} {							;#	Flags that time-entries already known from "valveopening" values
			set cnt 0
			set vcnt 0
			catch {unset vals}
			set setsize [expr $nes(valvecnt) + 1]
			set total_cnt [expr $nes(valve_eventcnt) * $setsize]
			while {$cnt < $total_cnt} {
				if {($cnt % $setsize) == 0} {
					set val [lindex $nessparam(valveopening) $cnt]	;#	Sync to valve opening events
				} else {
					set val [lindex $nessparam(provisional) $vcnt]
					incr vcnt
				}
				lappend vals $val
				incr cnt
			}
			set nessparam($nes(provisional_param)) $vals

		} else {													;#	Else time-values need to be set

			Inf "Now set the $nes(valve_eventcnt) valve-change timings"

		}
	}
	return 1
}

#--- Enter Timing of Valving events

proc GetValveChangeTimes {paramname} {
	global nessparam nes wstk ness_longparamname 
	if {![info exists nessparam(provisional)]} {
		Inf "First enter the $ness_longparamname($paramname) settings, from the adjacent button"
		return
	}
	while {![info exists nes(got_valvetimes)]} {

		DoNuTimer		;#	nessparam(valveopening,etc) is (or is not) set in "DoNuTimer"

		if {![info exists nes(got_valvetimes)]} {
			set msg "No timings set : abandon $ness_longparamname($paramname) setting ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				break
			}
		} else {
			break
		}
	}
	catch {unset nes(provisional_param)}
	catch {unset nes(got_valvetimes)}
	catch {unset nessparam(provisional)}
	catch {unset nes(valve_eventcnt)}
}

#----

proc NessRand {nam} {
	global ness_longparamname nessparam nes
															;#	If value already entered on interface, check it, and if it's OK			
	if {[CheckNescoParam $nam $ness_longparamname($nam) $nessparam($nam) 0]} {

		NessRandval $nam [llength $nessparam($nam)]			;#	Replace all existing values by rand vals

	} elseif {[string length $nessparam($nam)] == 0} {		;#	If no value yet entered on interface (rather than an invalid value)	
		if {[IsScoreValveParameter $nam]} {
			if {![info exists nes(valvecnt)]} {
				if {![file exists $nessparam(instrumentfile)]} {
					Inf "No valve count information available"
					return
				} elseif {![GetValveCnt $nessparam(instrumentfile) 1]} {
					return
				}
			}
			if {$nam == "valveopening"} {					;#	Insert valvecnt values
				NessRandval $nam $nes(valvecnt)
			} else {
				NessRandval $nam 1							;#	Insert single value
			}
		} else {
			NessRandval $nam 1								;#	Insert single values ("pressure" is special case)
		}
	} else {
		Inf "The $ness_longparamname($nam) value is invalid"
	}
}

#--- Generate random values, in a defined range, for specified parameter

proc NessRandval {nam goalvaluecnt} {
	global pr_nesrand nessrange nesstypicalrange nessparam nes ness_longparamname evv nescorig
	set lo [lindex $nessrange($nam) 0]
	set hi [lindex $nessrange($nam) 1]
	set tlo [lindex $nesstypicalrange($nam) 0]
	set thi [lindex $nesstypicalrange($nam) 1]

	if {[IsScoreValveParameter $nam]} {
		set setsize [expr $nes(valvecnt) + 1]
	}	
	set f .nessrand
	if [Dlg_Create $f "RANDOM VALUES" "set pr_nesrand 0" -borderwidth 2] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		button $f0.ok -text "Randomise" -width 9 -command "set pr_nesrand 1" -highlightbackground [option get . background {}]
		button $f0.q   -text "Quit"     -width 9 -command "set pr_nesrand 0" -highlightbackground [option get . background {}]
		pack $f0.ok -side left -padx 2
		pack $f0.q -side right
		pack $f0 -side top -fill x -expand true
		label $f.00 -text "Up/Down Keys to change \"Min Value\"   :   Control Up/Down Keys to change \"Max Value\"   : " -fg $evv(SPECIAL)
		pack $f.00 -side top -pady 2
		label $f1.ll  -text "Min Value"
		entry $f1.e  -textvariable nes(randmin,$nam) -width 12
		label $f1.ll2 -text "Max Value"
		entry $f1.e2 -textvariable nes(randmax,$nam) -width 12
		button $f1.b -text "Set Maximum Range" -command "set pr_nesrand 2" -highlightbackground [option get . background {}]
		button $f1.t -text "Set Typical Range" -command "set pr_nesrand 3" -highlightbackground [option get . background {}]
		pack $f1.ll $f1.e $f1.ll2 $f1.e2 -side left -padx 2
		pack $f1.b -side left -padx 4
		pack $f1.t -side left -padx 2
		pack $f1 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Return> {set pr_nesrand 1}
		bind $f <Escape> {set pr_nesrand 0}
	}
	bind $f <Up>   "IncrNesRand 0 bot $nam $lo $hi"
	bind $f <Down> "IncrNesRand 1 bot $nam $lo $hi"
	bind $f <Control-Up>   "IncrNesRand 0 top $nam $lo $hi"
	bind $f <Control-Down> "IncrNesRand 1 top $nam $lo $hi"
	$f.1.e  config -textvariable nes(randmin,$nam)
	$f.1.e2 config -textvariable nes(randmax,$nam)
	wm title $f "RANDOM VALUES FOR $ness_longparamname($nam)"
	if {![info exists nes(randprevious)] || ($nam != $nes(randprevious))} {
		set nes(randmin,$nam) ""
	}
	set nes(randprevious) $nam
	if {![info exists nes(randmin,$nam)] || ([string length $nes(randmin,$nam)] == 0)} {
		set nes(randmin,$nam) $tlo
		set nes(randmax,$nam) $thi
	}
	switch -- $nam {
		"sr"		{ set decplaces 7 }
		"mu"		{ set decplaces 7 }
		"sigma"		{ set decplaces 1 }
		"h"			{ set decplaces 5 }	
		"w"			{ set decplaces 3 }
		"pressure"	{ set decplaces 1 }
		default		{ set decplaces 2 }
	}
	set isamp 0
	switch -- $nam {
		"vibamp"   -
		"tremamp"  -
		"noiseamp" -
		"vavlevibamp" {
			set isamp 1
		}
	}
	set pr_nesrand 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_nesrand
	set finished 0
	while {!$finished} {
		tkwait variable pr_nesrand
		switch -- $pr_nesrand {
			1 {
				if {![IsNumeric $nes(randmin,$nam)] || ![IsNumeric $nes(randmax,$nam)]} {
					Inf "Numeric values only"
					continue
				}
				if {($nes(randmin,$nam) < $lo) || ($nes(randmax,$nam) > $hi)} {
					Inf "Out of range ($lo to $hi)"
					continue
				}
				if {$nes(randmin,$nam) > $nes(randmax,$nam)} {
					Inf "Range inverted"
					continue
				}
				set thisrange [expr $nes(randmax,$nam) - $nes(randmin,$nam)]
				if {$nam == "pressure"} {
					set cnt 2										;#	Retain initial zero pressure
				} else {
					set cnt 0
				}
				set outvals {}
				while {$cnt < $goalvaluecnt} {
					set val [UnEngineer [expr (rand() * $thisrange) + $nes(randmin,$nam)]]
					set val [DecPlaces $val $decplaces]
					if {$isamp && ($val == 0)} {
						set val 0.01
					}

					if {$goalvaluecnt == 1} {						;#	SINGLE VALUES
						if {$nam == "pressure"} {
							set	outvals	[list 0 0 0.01 $val]		;#	Pressure preserves onset, and has 4 vals
						} else {	
							set outvals $val						;#	Single Value (all other params except valve-opening)
						}
						break
					} else {
						if {[IsScoreValveParameter $nam]} {			;#	MULTIPLE VALUES FOR VALVING PARAMETERS
							set vals [lindex $nessparam($nam) $cnt]	;#	Get original time
							set m 0
							while {$m < $nes(valvecnt)} {			;#	Insert valvecnt random vals
								lappend vals $val
								set val [UnEngineer [expr rand() * $thisrange]]
								set val [DecPlaces $val $decplaces]
								if {$isamp && ($val == 0)} {
									set val 0.01
								}
								incr m
							}
							set outvals [concat $outvals $vals]		;#	Assemble the output list
							incr cnt $setsize						;#	Advance to next valve-set

						} else {									;#	MULTIPLE VALUES FOR OTHER PARAMS
																	;#	2nd item of time-value pairs replaced	
							lappend outvals [lindex $nessparam($nam) $cnt]
							lappend outvals $val
							incr cnt 2
						}
					}
				}
				set nescorig($nam) $nessparam($nam)
				set nessparam($nam) $outvals
				.nessco.$nam.ro config  -text "R" -command "NessOriginal $nam" -state normal
				set finished 1
			}
			0 {
				set finished 1
			}
			2 {
				set nes(randmin,$nam) $lo
				set nes(randmax,$nam) $hi
			}
			3 {
				set nes(randmin,$nam) $tlo
				set nes(randmax,$nam) $thi
			}
		} 
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc IncrNesRand {down where nam lo hi} {
	global nes
	if {$where == "bot"} {	;#	Move bottom of range down
		if {![IsNumeric $nes(randmin,$nam)]} {
			return
		}
	} else {
		if {![IsNumeric $nes(randmax,$nam)]} {
			return
		}
	}
	if {$down} {
		if {$where == "bot"} {	;#	Move bottom of range down
			if {$nes(randmin,$nam) > $lo} {
				if {$nes(randmin,$nam) < 0.0000001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) - 0.00000001]]
				} elseif {$nes(randmin,$nam) < 0.000001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) - 0.0000001]]
				} elseif {$nes(randmin,$nam) < 0.00001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) - 0.000001]]
				} elseif {$nes(randmin,$nam) < 0.0001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) - 0.00001]]
				} elseif {$nes(randmin,$nam) < 0.001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) - 0.0001]]
				} elseif {$nes(randmin,$nam) < 0.01} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) - 0.001]]
				} elseif {$nes(randmin,$nam) < 0.1} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) - 0.01]]
				} elseif {$nes(randmin,$nam) < 1} { 
					set nes(randmin,$nam) [expr $nes(randmin,$nam) - 0.1]
				} elseif {$nes(randmin,$nam) < 10} { 
					set nes(randmin,$nam) [expr $nes(randmin,$nam) - 1]
				} elseif {$nes(randmin,$nam) < 100} { 
					set nes(randmin,$nam) [expr $nes(randmin,$nam) - 10]
				} else {
					set nes(randmin,$nam) [expr $nes(randmin,$nam) - 100]
				}
				if {$nes(randmin,$nam) < $lo} {
					set nes(randmin,$nam) $lo
				}
			}
		} else {				;#	Move top of range down
			set origtop $nes(randmax,$nam)
			set range [expr $nes(randmax,$nam) - $nes(randmin,$nam)]
			if {$range <= 0.000001} { 
				set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) - 0.0000001]]
			} elseif {$range <= 0.00001} { 
				set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) - 0.000001]]
			} elseif {$range <= 0.0001} { 
				set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) - 0.00001]]
			} elseif {$range <= 0.001} { 
				set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) - 0.0001]]
			} elseif {$range <= 0.01} { 
				set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) - 0.001]]
			} elseif {$range  <= 0.1} { 
				set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) - 0.01]]
			} elseif {$range <= 1} { 
				set nes(randmax,$nam) [expr $nes(randmax,$nam) - 0.1]
			} elseif {$range <= 10} { 
				set nes(randmax,$nam) [expr $nes(randmax,$nam) - 1]
			} elseif {$range <= 100} { 
				set nes(randmax,$nam) [expr $nes(randmax,$nam) - 10]
			} else {
				set nes(randmax,$nam) [expr $nes(randmax,$nam) - 100]
			}
			if {$nes(randmax,$nam) <= $nes(randmin,$nam)} {
				set nes(randmax,$nam) $origtop
			}
		}
	} else {
		if {$where == "bot"} {	;#	Move bottom of range up
			if {$nes(randmin,$nam) < $nes(randmax,$nam)} {
				set origbot $nes(randmin,$nam)
				if {$nes(randmin,$nam) < 0.000001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) + 0.0000001]]
				} elseif {$nes(randmin,$nam) < 0.00001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) + 0.000001]]
				} elseif {$nes(randmin,$nam) < 0.0001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) + 0.00001]]
				} elseif {$nes(randmin,$nam) < 0.001} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) + 0.0001]]
				} elseif {$nes(randmin,$nam) < 0.01} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) + 0.001]]
				} elseif {$nes(randmin,$nam) < 0.1} { 
					set nes(randmin,$nam) [UnEngineer [expr $nes(randmin,$nam) + 0.01]]
				} elseif {$nes(randmin,$nam) < 1} { 
					set nes(randmin,$nam) [expr $nes(randmin,$nam) + 0.1]
				} elseif {$nes(randmin,$nam) < 10} { 
					set nes(randmin,$nam) [expr $nes(randmin,$nam) + 1]
				} elseif {$nes(randmin,$nam) < 100} { 
					set nes(randmin,$nam) [expr $nes(randmin,$nam) + 10]
				} else {
					set nes(randmin,$nam) [expr $nes(randmin,$nam) + 100]
				}
				if {$nes(randmin,$nam) >= $nes(randmax,$nam)} {
					set nes(randmin,$nam) $origbot
				}
			}
		} else {				;#	Move top of range up
			if {$nes(randmax,$nam) < $hi} {
				set range [expr $hi - $nes(randmax,$nam)]
				if {$range < 0.000001} { 
					set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) + 0.0000001]]
				} elseif {$range <= 0.00001} { 
					set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) + 0.000001]]
				} elseif {$range <= 0.0001} { 
					set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) + 0.00001]]
				} elseif {$range <= 0.001} { 
					set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) + 0.0001]]
				} elseif {$range <= 0.01} { 
					set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) + 0.001]]
				} elseif {$range <= 0.1} { 
					set nes(randmax,$nam) [UnEngineer [expr $nes(randmax,$nam) + 0.01]]
				} elseif {$range <= 1} { 
					set nes(randmax,$nam) [expr $nes(randmax,$nam) + 0.1]
				} elseif {$range <= 10} { 
					set nes(randmax,$nam) [expr $nes(randmax,$nam) + 1]
				} elseif {$range <= 100} { 
					set nes(randmax,$nam) [expr $nes(randmax,$nam) + 10]
				} else {
					set nes(randmax,$nam) [expr $nes(randmax,$nam) + 100]
				}
				if {$nes(randmax,$nam) > $hi} {
					set nes(randmax,$nam) $hi
				}
			}
		}
	}
}

proc IsAnotherValvingEntry {paramname} {
	global nes
	if {[IsScoreValveParameter $paramname] && ($nes(valveopeningdisplaycnt) > 1)} {
		return 1
	}
	return 0
}

proc BrassInstrDefaults {} {
	global nessparam nes
	set nessparam(vdl) $nes(VDL_LO)
	set nessparam(vbl) $nes(VBL_LO)
	set nessparam(temperature) $nes(TEMP_TYPICAL)
}

############################################
# DISPLAYING AND EDITING MULTISYNTH SCORES #
############################################

proc Darwin {play} {
	global pr_darwin wl ch chlist evv mscore darplay darwin_instruments

	ScoreDisplayInit

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] != 1) || ($ilist == -1)} {
		if {[info exists chlist] && ([llength $chlist] == 1)} {
			set fnam [lindex $chlist 0]
		} else {
			Inf "Select a multisynth scorefile on the workspace, or put it on the chosen-files list"
			return
		}
	} else {
		set fnam [$wl get $ilist]
	}

	if {![file exists $fnam]} {
		Inf "Score $fnam does not exist"
		return
	}

	;#	TEST FILES AND CREATE NAMED STAVES

	if {![IsMultisynthScorefile $fnam]} {
		Inf "$fnam is not a valid multisynth score file"
		return
	}
	catch {unset mscore(sndout)}
	catch {unset darplay}
	if {$play} {
		DarwinPlay $fnam 0
		return
	}
	set mscore(infnam) $fnam
	set darplay(mm) $mscore(dflt_mm)
	DeleteAllTemporaryFiles
	set f .darwin
	if [Dlg_Create $f "SCORE DISPLAY" "set pr_darwin 0" -width 120 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set i [frame $f.i -borderwidth $evv(SBDR)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		button $b.q -text "Quit" -command "set pr_darwin 0" -highlightbackground [option get . background {}]
		label $b.ll -text "Sound of Whole Ensemble" -width 24
		button $b.c -text "Create New Sound Output" -command "set pr_darwin 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.p -text "Play Existing Sound Output" -command "set pr_darwin 2" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.d -text "Choose Different Sound Output" -command "set pr_darwin 3" -highlightbackground [option get . background {}]
		pack $b.q $b.ll -side left -padx 2
		pack $b.c $b.p $b.d -side right -padx 2
		label $i.ll -text "MM"
		label $i.uu -text "(Up/Dn Keys)" -fg $evv(SPECIAL)
		entry $i.mm -textvariable darplay(mm) -width 4 -state readonly
		pack $i.mm $i.ll $i.uu -side left 
		foreach nam $darwin_instruments {
			if {[string first "piano" $nam] == 0} {
				continue
			}
			frame $f.i.$nam
			label $f.i.$nam.ll -text $nam -width 7 -anchor w
			button $f.i.$nam.create -text Snd -width 4 -command "DarwinPlayStave $nam create scoresee" -highlightbackground [option get . background {}]
			pack $f.i.$nam.create $f.i.$nam.ll -side left -padx 2
			pack $f.i.$nam -side left
		}
		frame $f.i.piano
		label $f.i.piano.ll -text Piano -width 7 -anchor w
		button $f.i.piano.create -text Snd -width 4  -command "DarwinPlayStave piano create scoresee" -highlightbackground [option get . background {}]
		pack $f.i.piano.create $f.i.piano.ll -side left -padx 2
		pack $f.i.piano -side left
		set mscore(grafix) [EstablishScoreDisplay $d]
		pack $mscore(grafix) -side top -pady 1
		pack $b -side top -fill x -expand true -pady 1
		pack $f.i -side top
		pack $d -side top -fill both -expand true -pady 1
		wm resizable $f 0 0
		bind $f <Up> {IncrDarwinMM 0}
		bind $f <Down> {IncrDarwinMM 1}
		bind $f <Return> {set pr_darwin 0}
		bind $f <Escape> {set pr_darwin 0}
	}
	wm title $f "SCORE DISPLAY [file rootname [file tail $fnam]]"

	$f.b.ll config -text ""
	foreach nam $darwin_instruments {
		if {[string first "piano" $nam] == 0} {
			continue
		}
		if {([llength $mscore(insnams)] > 1) && ([lsearch $mscore(insnams) $nam] >= 0)} {
			$f.i.$nam.create config -text "Snd" -bd 2 -state normal -command "DarwinPlayStave $nam create scoresee" -bg [option get . background {}]
			$f.b.ll config -text "Sound of Whole Ensemble"
		} else {
			$f.i.$nam.create config -text "" -bd 0 -state disabled -background [option get . background {}]
		}
	}
	if {([llength $mscore(insnams)] > 2) && (([lsearch $mscore(insnams) "pianoRH"] >= 0) && ([lsearch $mscore(insnams) "pianoLH"] >= 0))} {
		$f.i.piano.create config -text "Snd" -bd 2 -state normal -command "DarwinPlayStave piano create scoresee" -bg [option get . background {}]
		$f.b.ll config -text "Sound of Whole Ensemble"
	} else {
		$f.i.piano.create config -text "" -bd 0 -state disabled -background [option get . background {}]
	}

	if {![DisplayMultisynthScore]} { 	;#	DISPLAY NOTES
		Dlg_Dismiss $f
		destroy $f
		return
	}
	set pr_darwin 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_darwin
	while {!$finished} {
		tkwait variable pr_darwin
		switch -- $pr_darwin {
			0 {
				set finished 1
			}
			default {
				DarwinPlay $fnam $pr_darwin
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc ScoreDisplayInit {} {
	global mscore mscore_init s_o evv trebleclef bassclef
	if {[info exists mscore_init]} {
		return
	}
	
	;#	Set up colour-scheme for possible note-clusters

	set mscore(clustercolor) [list $evv(POINT) red blue yellow Chartreuse4 DarkOrange purple]
	if {[string match $evv(POINT) "black"]} {
		lappend mscore(clustercolor) white
	} else {
		lappend mscore(clustercolor) CornflowerBlue
	}

	;#	Data Array Index offsets: accessing each of 4 grouped-items of the data

	set evv(MSC_TIME)	0
	set evv(MSC_MIDI)	1
	set evv(MSC_LOUD)	2
	set evv(MSC_DUR)	3

	;#	Pitch_Units

	set evv(MIDI_OCT)	12			;#	simetones per octave
	set evv(STAVE_OCT)	8			;#	staff-representation of octave-transposition
	set evv(MIDILO_Db)	1			;#	MIDI note values % MIDI_OCT
	set evv(MIDILO_Eb)	3
	set evv(MIDILO_E)	4
	set evv(MIDILO_Gb)	6
	set evv(MIDILO_Ab)	8
	set evv(MIDILO_Bb)	10
	set evv(MIDILO_B)	11

	;#	time-units

	set evv(QP_SEMIQ)		3		;#	3  time-units = 1 semiquaver
	set evv(QP_QUAVER)		6		;#	6  time-units = 1 quaver
	set evv(QP_CROTCHET)	12		;#	12 time-units = 1 crotchet
	set evv(QP_MINIM)		24		;#	24 time-units = 1 minim
	set evv(QP_SEMIBREVE)	48		;#	48 time-units = 1 semibreve

	set evv(QP_TRIPQ)		4		;#	4  time-units = 1 quaver-triplet
	set evv(QP_TRIPC)		8		;#	8  time-units = 1 crotchet-triplet
	set evv(QP_TRIPM)		16		;#	16 time-units = 1 minim-triplet
	set evv(QP_TRIPSB)		32		;#	32 time-units = 1 semibreve-triplet


	set evv(MSYNMAXQDUR) [expr 256 * $evv(QP_SEMIQ)]	;#	Longest note representable: maxdur = 16-tied-sembireves

	;#	score length restriction

	set evv(MAXNOTECNT)			480							;#	Maximum number of SEMIQUAVERS on one staff : 120 beats (2 mins at MM=60 1 min at MM=120 40sces at MM = 180)

	;#	y-dimension of staves

	set evv(notespan)	17				;#	Represent 2 8vas + 3rd on each staff (i.e. 2 leg lines up and down from each staff)
	set mscore(topline) 20				;#	y coord of topmost line of topmost staff
	set mscore(topstavemiddle) 60		;#	y coord of middle line of topmost staff
	set mscore(staffoffset)	90			;#	distance between staves
	set mscore(noteoffset)	5			;#	vertical distance between notes C and D (say)
	set mscore(lineoffset)	[expr $mscore(noteoffset) * 2]		;#	vertical distance between staff lines
	set mscore(stemlen)		[expr ($mscore(lineoffset) * 2) + 5];#	length of note stems
	set mscore(noteheight) 6			;#	Vertical height of notehead NB: MUST BE EVEN!!!!!
	set mscore(halfnoteheight) [expr $mscore(noteheight)/2]
	set mscore(doublestaffoffset) 60	;#	distance between staves when staves paired (as for piano)
	set mscore(middblstaffoffset) [expr $mscore(doublestaffoffset)/2]
	set mscore(timemarkoffset) $mscore(lineoffset) 
	set mscore(doubletimemarkoffset) [expr $mscore(timemarkoffset) * 2]
	set mscore(doubleclefspacer) [expr $mscore(lineoffset) * 2]

	;#	x-dimension of staves

	set mscore(staff_start)	80			;#	start of staves, on display
	set mscore(notes_start)	120			;#	position of 1st note (time 0) on display
	set mscore(note_width)	8			;#	width of notehead
	set mscore(gridstep)	3			;#	time-unit separation on display
	set mscore(semiq)		9			;#	semiquaver separation on display
	set mscore(notewidth)	6	
	set mscore(halfnotewidth) [expr $mscore(notewidth)/2]

	set mscore(notes_end) [expr ($evv(MAXNOTECNT) * $mscore(semiq)) + $mscore(notes_start)]	;#	position of last possible note-display
	set mscore(screenend) [expr $mscore(notes_end) + $mscore(semiq)]						;#	length of display

	set stafftop -40					;#	Offset of topmost note from centre of treble staff

	set n 0
	while {$n < $evv(notespan)} {
		set s_o($n) $stafftop			;#	s_o = staff_offset, offset of each stave line or note position from staff-centre
		incr stafftop $mscore(noteoffset)
		incr n
	}
	;# coords of clefs (4 segments), relative to stave centre

	set trebleclef [list 90 -30 90 35 90 -36 102 -24 98 -25 80 10 80 0 100 20]
	set bassclef   [list 80 -20 107 15 25 -45 105 25 109 -16 111 -14 109 -6 111 -4]

	set mscore(insname_pos)	40

	set mscore(min_mm) 30
	set mscore(max_mm) 500
	set mscore(dflt_mm) 60
	set mscore(min_ochans) 2
	set mscore(max_ochans) 8
	set mscore(dflt_ochans) 8
	set mscore(min_jitter) 0
	set mscore(max_jitter) 20
	set mscore(dflt_jitter) 15
	
	set mscore_init 1
}

#--- Draw appropriate staves

proc EstablishScoreDisplay {pstaff} {
	global pr_scoccreen evv mscore_nampos s_o trebleclef bassclef mscore

	set has_piano 0
	set stavecnt [llength $mscore(insnams)]
	if {[lsearch $mscore(insnams) "pianoRH"] >= 0} {
		set has_piano 1
	}
	set screenfoot [expr ($stavecnt + $has_piano) * 120] 		;#	Total depth of staff-displays

	set mscore(can) [Scrolled_Canvas $pstaff.c -width 600 -height 1000 -scrollregion "0 0 $mscore(screenend) $screenfoot"]

	set s_e $mscore(screenend)
	set stave 0
	set sm $mscore(topstavemiddle)
	set lastinsnam banana
	while {$stave < $stavecnt} {
		;#	Establish instrument name and its positioning

		set insnam [lindex $mscore(insnams) $stave]
		switch -- $insnam {
			"flute" {
				set treble 1
				set displaynam "Flute"
			}
			"clarinet" {
				set treble 1
				set displaynam "Clar"
			}
			"trumpet" {
				set treble 1
				set displaynam "Tpt"
			}
			"violin" {
				set treble 1
				set displaynam "Violin"
				if {$stave > 0} {
					incr sm $mscore(doubletimemarkoffset)
				}
			}
			"cello" {
				set treble 0
				set displaynam "VC"
				if {$stave > 0} {
					incr sm $mscore(doubletimemarkoffset)
				}
			}
			"pianoRH" {
				set treble 2
				set displaynam "Piano"
				incr sm $mscore(staffoffset)
			}
			"pianoLH" {
				set treble 3
				incr stave
				continue
			}
		}
		if {$lastinsnam == "pianoRH"} {
			incr sm $mscore(staffoffset)
		}
		if {$insnam == "pianoRH"} {
			set mscore_nampos [list $mscore(insname_pos) [expr $sm + ($mscore(doublestaffoffset)/2)]]
		} else {
			set mscore_nampos [list $mscore(insname_pos) $sm]
		}
		set lastinsnam $insnam
		$mscore(can) create text [lindex $mscore_nampos 0] [lindex $mscore_nampos 1] -text $displaynam -font {helvetica 14 bold} -fill $evv(GRAF)
		switch -- $treble {
			1 {		;#	TREBLE
				set n 0
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill $evv(POINT)	
				set top [expr $sm + $s_o($n)]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT) 
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				set bot [expr $sm + $s_o($n)]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)]0 -tag {notehite flathite} -fill [option get . background {}]

				$mscore(can) create line 80  $top 80 $bot -fill $evv(POINT) -width 2
				DrawClef 1 $sm
				
			}
			0 {		;#	BASS
				set n 0
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				set top [expr $sm + $s_o($n)]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill $evv(POINT) 
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				set bot [expr $sm + $s_o($n)]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)]0 -tag notehite -fill [option get . background {}]

				$mscore(can) create line 80  $top 80 $bot -fill $evv(POINT) -width 2
				DrawClef 0 $sm
			}
			2 {		;#	DOUBLE (TREBLE-BASS) STAFF
				set n 0
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill $evv(POINT)	
				set top [expr $sm + $s_o($n)]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT) 
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)]0 -tag {notehite flathite} -fill [option get . background {}]
				
				DrawClef 1 $sm

				incr sm $mscore(doublestaffoffset)

				set n 0
			# OMIT Bass-stave top dummy-line, as it overwrites Treble staff real line
			#	$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)	
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill $evv(POINT) 
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill $evv(POINT)
				set bot [expr $sm + $s_o($n)]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag notehite -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)] -tag {notehite flathite} -fill [option get . background {}]
				incr n
				$mscore(can) create line 80  [expr $sm + $s_o($n)] $s_e [expr $sm + $s_o($n)]0 -tag notehite -fill [option get . background {}]

				$mscore(can) create line 80  $top 80 $bot -fill $evv(POINT) -width 2
				DrawClef 0 $sm
			}
		}
		incr sm $mscore(staffoffset)
		if {$treble == 2} {
			incr sm $mscore(doubleclefspacer)
		}
		incr sm $mscore(doubletimemarkoffset)
		incr stave
	}
	return $pstaff.c
}

proc DrawClef {treble stavemiddle} {
	global trebleclef bassclef evv mscore
	set sm $stavemiddle
	if {$treble} {
		set n 0
		while {$n < 16} {
			set c($n) [lindex $trebleclef $n]
			incr n
		}
		set clef1a [$mscore(can) create line $c(0)  [expr $c(1)+$sm]  $c(2)  [expr $c(3)+$sm]  -width 1 -fill $evv(POINT)]
		set clef1b [$mscore(can) create arc  $c(4)  [expr $c(5)+$sm]  $c(6)  [expr $c(7)+$sm]  -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
		set clef1c [$mscore(can) create line $c(8)  [expr $c(9)+$sm]  $c(10) [expr $c(11)+$sm] -width 1 -fill $evv(POINT)]
		set clef1d [$mscore(can) create arc  $c(12) [expr $c(13)+$sm] $c(14) [expr $c(15)+$sm] -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]
	} else {
		set n 0
		while {$n < 16} {
			set c($n) [lindex $bassclef $n]
			incr n
		}
		set bclef3a [$mscore(can) create arc  $c(0)  [expr $c(1)+$sm]  $c(2)  [expr $c(3)+$sm]  -style arc -start 30 -extent 120 -width 1 -outline $evv(POINT)]
		set bclef3b [$mscore(can) create arc  $c(4)  [expr $c(5)+$sm]  $c(6)  [expr $c(7)+$sm]  -style arc -start 5 -extent -75 -width 1 -outline $evv(POINT)]
		set bclef3c [$mscore(can) create oval $c(8)  [expr $c(9)+$sm]  $c(10) [expr $c(11)+$sm] -fill $evv(POINT) -outline $evv(POINT)]
		set bclef3d [$mscore(can) create oval $c(12) [expr $c(13)+$sm] $c(14) [expr $c(15)+$sm] -fill $evv(POINT) -outline $evv(POINT)]
	}
}

#--	Read and parse the multisynth score textfile

proc IsMultisynthScorefile {fnam} {
	global evv pa mscore
	if {![file exists $fnam]} {
		Inf "File $fnam no longer exists"
		return 0
	}
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
		Inf "File $fnam is not a textfile"
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to check its contents"
		return 0
	}
	catch {unset mscore(score)}
	catch {unset mscore(insnams)}
	set OK 1
	set linecnt 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			incr linecnt
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			incr linecnt
			continue
		}
		set line [split $line]
		set cnt 0
		set numbercnt -1
		set coincident 1
		catch {unset lastpitch}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {$cnt == 0} {
				set mscoreranges [MscoreRanges $item $fnam]
				if {[llength $mscoreranges] <= 0} {
					set OK 0
					break
				}
				set rangebot  [lindex $mscoreranges 0]
				set rangetop  [lindex $mscoreranges 1]
				set overlap   [lindex $mscoreranges 2]
				set doublestop [lindex $mscoreranges 3]
				set insnam $item
				lappend mscore(insnams) $insnam
				catch {unset scoreline}
			} else {
				set typ [expr $numbercnt % 4]
				switch -- $typ {
					0 {			;#	time
						if {![IsNumeric $item] || ![regexp {^[0-9]+$} $item] || ($item < 0.0)} {
							Inf "Invalid time value ($item) on line $linecnt in file $fnam (must be an integer : time in semiquavers)"
							set OK 0
							break
						}
						if {[expr $item % $evv(QP_SEMIQ)] && [expr $item % $evv(QP_TRIPQ)]} {
							Inf "Invalid time value ($item) on line $linecnt in file $fnam (must be a multiple of $evv(qp_semiq) or $evv(qp_tripq))"
							set OK 0
							break
						}
						if {$numbercnt > 0} {
							set timestep [expr $item - $lasttime]
							if {$timestep < 0} {
								Inf "Times do not advance between $lasttime and $item in line $linecnt"
								set OK 0
								break
							} elseif {$timestep == 0} {
								incr coincident
								if {$coincident > $doublestop} {
									Inf "Too many coincident notes at $lasttime on line $linecnt : instrument $insnam"
									set OK 0
									break
								}
							} elseif {$timestep < $evv(QP_SEMIQ)} {
								Inf "Times do not advance sufficiently ($lasttime to $item = [expr $item - $lasttime] units : min = $evv(qp_semiq) units)  on line $linecnt : instrument $insnam"
								set OK 0
								break
							} else {
								set coincident 1
							}
							if {($coincident <= 1) && ($timestep < $lastdur)} {
								Inf "Notes at $lasttime and $item overlap one another on line $linecnt : instrument $insnam"
								set OK 0
								break
							}
						}
						set lasttime $item
					}
					1 {			;#	pitch
						if {![IsNumeric $item] || ![regexp {^[0-9]+$} $item]} {
							Inf "Invalid pitch value ($item) on line $linecnt in file $fnam (must be an integer : midi pitch)"
							set OK 0
							break
						}
						if {($item < $rangebot) || ($item > $rangetop)} {
							Inf "Pitch value $item out of range ($rangebot to $rangetop) for instrument $insnam in line $linecnt"
							set OK 0
							break
						}
						if {($coincident > 1) && ($item == $lastpitch)} {
							Inf "Two identical pitches ($item) at same time ($lasttime) for instrument $insnam in line $linecnt"
							set OK 0
							break
						}
						set lastpitch $item
					}
					2 {			;#	level
						if {![IsNumeric $item] } {
							Inf "Invalid level value ($item) on line $linecnt in file $fnam (must be numeric)"
							set OK 0
							break
						}
						if {($item <= 0.0) || ($item > 1.0)} {
							Inf "Level value $item out of range (>0 to 1) for instrument $insnam on line $linecnt"
							set OK 0
							break
						}
					}
					3 {			;#	dur
						if {![IsNumeric $item] || ![regexp {^[0-9]+$} $item]} {
							Inf "Invalid duration value ($item) on line $linecnt in file $fnam (must be an integer : semiquaver count)"
							set OK 0
							break
						}
						if {[expr $item % $evv(QP_SEMIQ)] && [expr $item % $evv(QP_TRIPQ)]} {
							Inf "Invalid duration value ($item) on line $linecnt in file $fnam (must be a multiple of $evv(qp_semiq) or $evv(qp_tripq))"
							set OK 0
							break
						}
						if {($item < 1) || ($item > $evv(MSYNMAXQDUR))} {
							Inf "Duration in semiquavers ($item) out of range (1 to $evv(msynmaxqdur)) for instrument $insnam on line $linecnt"
							set OK 0
							break
						}
						if {$coincident > 1} {
							if {$item != $lastdur} {
								Inf "Simultaneous notes at time $lasttime for instrument $insnam on line $linecnt must have same duration"
								set OK 0
								break
							}
						}
						set lastdur $item
					}
				}
				lappend scoreline $item
			}
			incr cnt
			incr numbercnt
		}
		if {!$OK} {
			break
		}
		if {[expr $numbercnt % 4] != 0} {
			Inf "Invalid number of numeric entries ($numbercnt) on line $linecnt (must be in sets of 4: time,pitch,level,duration)"
			set OK 0
			break
		}
		lappend mscore(score) $scoreline
		incr linecnt
	}
	close $zit
	if {!$OK} {
		return 0
	}
	if {![ForceOrchestralOrder]} {
		return 0
	}
	return 1
}

#--- Display notes on multisynth score

proc DisplayMultisynthScore {} {
	global mscore evv
	set s_e $mscore(screenend)
	set stave 0
	set sm $mscore(topstavemiddle)
	set lastinsnam banana
	foreach line $mscore(score) insnam $mscore(insnams) {
		if {![CheckTriplets $insnam $line]} {
			return 0
		}
		if {![TripletTyping $line $insnam]} {
			return 0
		}
		catch {unset coset}
		switch -- $insnam {
			"flute" -
			"clarinet" -
			"trumpet" -
			"violin" {
				set treble 1
				if {($insnam == "violin") && ($stave > 0)} {
					incr sm $mscore(doubletimemarkoffset)
				}
			}
			"cello" {
				set treble 0
				if {$stave > 0} {
					incr sm $mscore(doubletimemarkoffset)
				}
			}
			"pianoRH" {
				set treble 2
				incr sm $mscore(staffoffset)	;#	Space for upper ledger lines
			}
			"pianoLH" {
				set treble 3
				;#	Remains at same double stave
			}
		}
		if {$lastinsnam == "pianoLH"} {
			incr sm $mscore(doublestaffoffset)	;#	Allow for double staff
			incr sm $mscore(staffoffset)		;#	Space for lower ledger lines
		}
		set lastinsnam $insnam
		
		catch {unset coinc}
		catch {unset coincs}

		;#	FORCE COINCIDENT NOTES TO BE IN increasing MIDI order

		set xlen [llength $line]
		set cc 0
		while {$cc < [expr $xlen - 4]} {
			set ti_cc [lindex $line $cc]	;#	Time
			incr cc
			set kk $cc						;#	Midi-location
			set mi_cc [lindex $line $cc]	;#	MIDI
			incr cc 3
			set dd $cc
			while {$dd < $xlen} {
				set ti_dd [lindex $line $dd]
				incr dd
				set ee $dd
				set mi_dd [lindex $line $dd]
				incr dd 3
				if {$ti_cc == $ti_dd} {
					if {$mi_cc > $mi_dd} {
						set line [lreplace $line $kk $kk $mi_dd]						
						set line [lreplace $line $ee $ee $mi_cc]
						set mi_cc $mi_dd
					}
				} 
			}
		}

		set coindex -1
		set lasttime -1								;#	Find any coincident notes (chords)
		foreach {time midi loudness dur} $line {
			if {$time == $lasttime} {				;#	If note at same time as previous note
				incr coinc							;#	Count the coincident notes
				lappend coset($coindex) $midi		;#	Add to list of the coincident pitches
			} else {
				if {[info exists coinc]} {			;#	If we've got to the end of the coincident notes
					lappend coincs $coinc			;#	Remember number of coincident-notes in this set
				}
				set coinc 1							;#	Reset coincident-notes count to just 1
				incr coindex						;#	Increment the index to the sets of coincident-notes
				set coset($coindex) $midi			;#	Start a new coincident set
			}
			set lasttime $time
			set lastmidi $midi
		}
		lappend coincs $coinc
		incr coindex
		set testcluster 0
		set nuline {}
		while {$testcluster < $coindex} {
			set cluster($testcluster) [AssessCluster $insnam $coset($testcluster)]
			if {$cluster($testcluster) == -1} {
				return 0
			} 
			incr testcluster
		}
		set cluster($testcluster) 0	;#	Dummy last value
		lappend coincs -1	;# dummy last value
		set coindex 0
		set lastnotend 0
		set coinc [lindex $coincs 0]
		set clust cluster(0)
		if {$coinc > 1} {
			set coincidents 1
		} else {
			set coincidents 0
		}
		set colorno 0
		set colorindex [lindex $cluster($coindex) $colorno]
		set nextcolorindex [lindex $cluster($coindex) [expr $colorno + 1]]
		if {$colorindex < 0} {
			set colorindex [expr -$colorindex]
			set note_shift 1
		} else {
			set note_shift 0
		}
		if {$nextcolorindex < 0} {
			set suppressdot 1
		} else {
			set suppressdot 0
		}
		set lastmidi [lindex $line $evv(MSC_MIDI)]
		set dolongstemandflags 0
		foreach {time midi loudness dur} $line {
			set x1 [expr ($time * $mscore(gridstep)) + $mscore(notes_start)]		;#	x params of notehead determined by "time" and gridstep
			set x2 [expr $x1 + $mscore(notewidth)]
			set noteparams [MidiToNoteParams $treble $midi $insnam] 
			set offset [lindex $noteparams 0]			;#	note offset from staff centreline
			set flat   [lindex $noteparams 1]			;#	note has (has not) a flat sign
			set ledger [lindex $noteparams 2]			;#	note has (has not) ledger lines
			set octave [lindex $noteparams 3]			;#	note has 8va transposition
			set offset [expr $offset * $mscore(noteoffset)]
			if {($treble > 1) && ($midi < 60)} {		;#	instrument has treble-and-bass staves, and note is on bass-stave
					set ycentre [expr $sm + $mscore(doublestaffoffset) + $offset]
			} else {
				set ycentre [expr $sm + $offset]		;#	y params of notehead determined by staff-centre, and offset from centre
			} 
			if {$lastnotend < $time} {
				if {![DoRest $lastnotend $time $sm $stave $treble]} {
					return 0
				}
			}
			set y1 [expr $ycentre - $mscore(halfnoteheight)]
			set y2 [expr $y1 + $mscore(noteheight)]

			set under_triplet [IsStartUnderTriplet $time]

			set durparams [SetStemFlagsTies $treble $midi $dur $offset $time $under_triplet $insnam]
			if {[llength $durparams] <= 0} {
				return 0
			}
			set lastnotend [expr $time + $dur]
			set raised [lindex $durparams 0]
			set fill [lindex $durparams 1]
			set stem [lindex $durparams 2]
			set flag [lindex $durparams 3]
			set dot  [lindex $durparams 4]
			set tie  [lindex $durparams 5]
			set staffcentre $sm
			if {($insnam == "piano") && ($midi < 60)} {
				incr staffcentre $mscore(doublestaffoffset)
			}
			set x0 $x1
			if {$suppressdot} {
				set dot 0
			}
			CreateNote $insnam $midi $x0 $x1 $y1 $x2 $y2 $ycentre $offset $fill $stem $flag $dot $raised $ledger $staffcentre $stave $coincidents $colorindex $note_shift
			if {$flat} {								;#	establish coords of any flat sign
				AddFlat $x1 $x1 $ycentre $offset $stave
			}
			if {$octave} {								;#	establish coords of any 8va transposition sign
				AddOctaveTransposition $octave $x1 $x1 $y1 $y2 $offset $stave $insnam $stem
			}
			set lastmidi $midi
			incr coinc -1
			if {$coinc == 0} {
				if {$coincidents && $stem} {
					set midimax -60
					set midimin 200
					foreach zz $coset($coindex) {
						if {$zz > $midimax} {
							set midimax $zz
						} 
						if {$zz < $midimin} {
							set midimin $zz
						}
					}
					DoLongStemAndFlags $x0 $x1 $midimin $midimax $flag $treble $insnam $sm $stave
					set dolongstemandflags 1
				}
			}
			set kk 6
			while {$tie > 0} {
				if {$coincidents} {
					if {![info exists coincoffset]} {
						set coincoffset $offset
					}
					set tieoffset $coincoffset
				} else {
					catch {unset coincoffset}
					set tieoffset $offset
				}
				set x0 $x1
				incr x1 [expr $tie * $mscore(gridstep)]
				incr x2 [expr $tie * $mscore(gridstep)]
				set fill [lindex $durparams $kk]
				incr kk
				set stem [lindex $durparams $kk]
				incr kk
				set flag [lindex $durparams $kk]
				incr kk
				set dot  [lindex $durparams $kk]
				incr kk
				set tie  [lindex $durparams $kk]
				incr kk
				CreateTie $x0 $x1 $ycentre $tieoffset $stave
				if {$suppressdot} {
					set dot 0
				}
				CreateNote $insnam $midi $x0 $x1 $y1 $x2 $y2 $ycentre $offset $fill $stem $flag $dot $raised $ledger $staffcentre $stave $coincidents $colorindex $note_shift
				if {$flat} {
					AddFlat $x0 $x1 $ycentre $offset $stave
				}
				if {$octave} {
					AddOctaveTransposition $octave $x0 $x1 $y1 $y2 $offset $stave $insnam $stem
				}
				if {$dolongstemandflags} {
					DoLongStemAndFlags $x0 $x1 $midimin $midimax $flag $treble $insnam $sm $stave
				}
			}
			incr colorno
			set colorindex [lindex $cluster($coindex) $colorno]
			set nextcolorindex [lindex $cluster($coindex) [expr $colorno + 1]]
			if {$colorindex < 0} {
				set colorindex [expr -$colorindex]
				set note_shift 1
			} else {
				set note_shift 0
			}
			if {$nextcolorindex < 0} {
				set suppressdot 1
			} else {
				set suppressdot 0
			}
			set lastmidi $midi
#	HEREH : WRITING TRIPLET TIES
# I KNOW IF THERE'S A LONG STEM, as "dolongstemandflags" is set, and can write the 3-tie in correct place, y-wise
#	
			if {$coinc == 0} {
				set dolongstemandflags 0
				incr coindex
				set colorno 0
				set colorindex [lindex $cluster($coindex) $colorno]
				set nextcolorindex [lindex $cluster($coindex) [expr $colorno + 1]]
				if {$colorindex < 0} {
					set colorindex [expr -$colorindex]
					set note_shift 1
				} else {
					set note_shift 0
				}
				set coinc [lindex $coincs $coindex]
				if {$coinc > 1} {
					set coincidents 1
				} else {
					set coincidents 0
				}
				if {$nextcolorindex < 0} {
					set suppressdot 1
				} else {
					set suppressdot 0
				}
			}
		}
		set endrest [expr $lastnotend % $evv(QP_CROTCHET)]
		if {$endrest != 0} {
			set endrest [expr $evv(QP_CROTCHET) - $endrest]
			set time [expr $lastnotend + $endrest]
			if {![DoRest $lastnotend $time $sm $stave $treble]} {
				return 0
			}
		}

		;#	ADD TIME MARKERS

		if {$lastinsnam != "pianoRH"} {
			set x [expr $mscore(notes_start) - $mscore(halfnotewidth)]
			incr x 5
			set markcnt 0
			set y [expr $sm + $mscore(staffoffset)/2]
			if {$lastinsnam == "pianoLH"} {
				incr y $mscore(staffoffset)
				incr y $mscore(doubleclefspacer)			;#	Allows time-mark to avoid extended downward stems in piano LH
				incr sm $mscore(doubleclefspacer)
			}
			incr y $mscore(timemarkoffset)
			incr sm $mscore(doubletimemarkoffset)

			while {$x < $mscore(screenend)} {
				if {![TimeMarkerWithinATripletTie $x]} {
					if {[expr $markcnt % 4] == 0} {
						$mscore(can) create oval $x [expr $y - 2] [expr $x + 3] [expr $y + 1] -outline $evv(POINT) -fill $evv(POINT) -tag score
					} else {
						$mscore(can) create oval $x [expr $y - 2] [expr $x + 3] [expr $y + 1] -outline $evv(POINT) -tag score
					}
				}
				incr x [expr 4 * $mscore(semiq)]
				incr markcnt
			}
			;#	ADD TRIPLET TIES
			
			if {[info exists mscore(triplet_ties)]} {
				DoTripletTies $y 0
			}

			incr sm $mscore(staffoffset)
		} else {
			if {[info exists mscore(triplet_ties)]} {
				set y [expr $sm - (12 * $mscore(lineoffset))]
				DoTripletTies $y 1
			}
		}
		incr stave
	}
	return 1
}

#---- Deduce how many notes the current note is offset from the centre line of the staff
#---- plus determine if it needs a flat sign or ledger lines

proc MidiToNoteParams {treble midi insnam} {
	global evv
	set octave 0
	if {$treble > 1} {	 ;# Double stave (e.g. piano)
		if {$midi < 60} {
			set treble 0
		} else {
			set treble 1
		}
	}
	if {$treble} {	;#	TREBLE CLEF
		while {$midi < 54} { ;#	Out of range, downwards, need an 8va (16va) marker
			incr midi $evv(MIDI_OCT)
			incr octave 1	
		}
		if {$insnam != "pianoRH"} {
			while {$midi >84} {	 ;#	Out of range, upwards, need an 8va (16va) marker
				incr midi [expr -$evv(MIDI_OCT)]
				incr octave 1
			}
		}
		set flat 0		;#	Flags that a "flat" sign needed
		set ledg 0		;#	Flags ledger-lines needed
		switch -- $midi {
			54 { set offset 9; set flat 1 ;	set ledg -2	 ;#	Gb }
			55 { set offset 9;				set ledg -2	 ;#	G  }
			56 { set offset 8; set flat 1 ; set ledg -2	 ;#	Ab }
			57 { set offset 8;				set ledg -2	 ;#	A  }
			58 { set offset 7; set flat 1 ; set ledg -1	 ;#	Bb }
			59 { set offset 7;				set ledg -1	 ;#	B  }
			60 { set offset 6;				set ledg -1	 ;#	C0 }
			61 { set offset 5; set flat 1 	 ;#	Db }
			62 { set offset 5 				 ;#	D  }
			63 { set offset 4; set flat 1   ;#	Eb }
			64 { set offset 4 				 ;#	E  }
			65 { set offset 3 				 ;#	F  }
			66 { set offset 2; set flat 1 	 ;#	Gb }
			67 { set offset 2 				 ;#	G  }
			68 { set offset 1; set flat 1 	 ;#	Ab }
			69 { set offset 1 				 ;#	A  }
			70 { set offset 0; set flat 1 	 ;#	Bb }
			71 { set offset 0 				 ;#	B  }
			72 { set offset -1 				 ;#	C  }
			73 { set offset -2; set flat 1   ;#	Db }
			74 { set offset -2 				 ;#	D  }
			75 { set offset -3; set flat 1   ;#	Eb }
			76 { set offset -3 				 ;#	E  }
			77 { set offset -4 				 ;#	F  }
			78 { set offset -5; set flat 1   ;#	Gb }
			79 { set offset -5 				 ;#	G  }
			80 { set offset -6; set flat 1;	  set ledg 1  ;# Ab }
			81 { set offset -6;			  ;	  set ledg 1  ;# A  }
			82 { set offset -7; set flat 1;	  set ledg 1  ;# Bb }
			83 { set offset -7;				  set ledg 1  ;# B  }
			84 { set offset -8;				  set ledg 2  ;# C  }
			85 { set offset -9; set flat 1;	  set ledg 2  ;# Dd }
			86 { set offset -9;				  set ledg 2  ;# D  }
			87 { set offset -10; set flat 1;  set ledg 3  ;# Eb }
			88 { set offset -10;			  set ledg 3  ;# E  }
			89 { set offset -11;			  set ledg 3  ;# F  }
			90 { set offset -12; set flat 1;  set ledg 4  ;# Gb }
			91 { set offset -12;			  set ledg 4  ;# G  }
			92 { set offset -13; set flat 1;  set ledg 4  ;# Ab }
			93 { set offset -13;			  set ledg 4  ;# A  }
			94 { set offset -14; set flat 1;  set ledg 5  ;# Bb }
			95 { set offset -14;			  set ledg 5  ;# B  }
			96 { set offset -15;			  set ledg 5  ;# C  }
			97 { set offset -16; set flat 1;  set ledg 6  ;# Dd }
			98 { set offset -16;			  set ledg 6  ;# D  }
			99 { set offset -17; set flat 1;  set ledg 6  ;# Eb }
			100 { set offset -17;			  set ledg 6  ;# E  }
			101 { set offset -18;			  set ledg 7  ;# F  }
			102 { set offset -19; set flat 1; set ledg 7  ;# Gb }
			103 { set offset -19;			  set ledg 7  ;# G  }
			104 { set offset -20; set flat 1; set ledg 8  ;# Ab }
			105 { set offset -20;			  set ledg 8  ;# A  }
			106 { set offset -21; set flat 1; set ledg 8  ;# Bb }
			107 { set offset -21;			  set ledg 8  ;# B  }
			108 { set offset -22;			  set ledg 9  ;# C  }
		}
	} else {	;#	BASS CLEF
		if {$insnam != "pianoLH"} {
			while {$midi < 36} { ;#	Out of range, downwards, need an 8va (16va) marker
				incr midi $evv(MIDI_OCT)
				incr octave -1	
			}
		}
		while {$midi > 64} { ;#	Out of range, upwards, need an 8va (16va) marker
			incr midi [expr -$evv(MIDI_OCT)]
			incr octave 1
		}
		set flat 0		;#	Flags that a "flat" sign needed
		set ledg 0		;#	Flags ledger-lines needed
		switch -- $midi {
			21 { set offset 17;			    set ledg -6  ;# A  }
			22 { set offset 16; set flat 1; set ledg -6  ;# Bb }
			23 { set offset 16;			    set ledg -6  ;# B  }
			24 { set offset 15;			    set ledg -5  ;# C  }
			25 { set offset 14; set flat 1; set ledg -5  ;# Db }
			26 { set offset 14;			    set ledg -5  ;# D  }
			27 { set offset 13; set flat 1; set ledg -4  ;# Eb }
			28 { set offset 13;			    set ledg -4  ;# E  }
			29 { set offset 12;			    set ledg -4  ;# F  }
			30 { set offset 11; set flat 1; set ledg -3  ;# Gb }
			31 { set offset 11;			    set ledg -3  ;# G  }
			32 { set offset 10; set flat 1; set ledg -3  ;# Ab }
			33 { set offset 10;			    set ledg -3  ;# A  }
			34 { set offset 9; set flat 1; set ledg -2  ;# Bb }
			35 { set offset 9;			   set ledg -2  ;# B  }
			36 { set offset 8;			   set ledg -2  ;# C }
			37 { set offset 7; set flat 1; set ledg -1  ;# Db }
			38 { set offset 7;			   set ledg -1  ;# D }
			39 { set offset 6; set flat 1; set ledg -1  ;# Eb }
			40 { set offset 6;			   set ledg -1  ;# E }
			41 { set offset 5			    			;# F }
			42 { set offset 6; set flat 1	;#	Gb }
			43 { set offset 6				;#	G  }
			44 { set offset 3; set flat 1	;#	Ab }
			45 { set offset 3				;#	A  }
			46 { set offset 2; set flat 1  ;#	Bb }
			47 { set offset 2				;#	B  }
			48 { set offset 1				;#	C  }
			49 { set offset 0; set flat 1	;#	Db }
			50 { set offset 0				;#	D  }
			51 { set offset -1; set flat 1	;#	Eb }
			52 { set offset -1				;#	E  }
			53 { set offset -2				;#	F  }
			54 { set offset -3; set flat 1	;#	Gb }
			55 { set offset -3				;#	G  }
			56 { set offset -4; set flat 1	;#	Ab }
			57 { set offset -4				;#	A  }
			58 { set offset -5; set flat 1	;#	Bb }
			59 { set offset -5				;#	B  }
			60 { set offset -6;				set ledg 1  ;#	C  }
			61 { set offset -7; set flat 1;	set ledg 1  ;#	Db }
			62 { set offset -7;				set ledg 1  ;#	D  }
			63 { set offset -8; set flat 1;	set ledg 2  ;#	Eb }
			64 { set offset -8;				set ledg 2  ;#	E  }
		}
	}
	set noteparams [list $offset $flat $ledg $octave]
	return $noteparams
}

#--- Use coords of notehead, to determine coords of flat-sign

proc AddFlat {x0 x1 ycentre offset stave} {
	global mscore evv
	set stavetag stave$stave
	set x [expr $x1 - $mscore(halfnotewidth) + 1]
	$mscore(can) create text $x $ycentre -text "b" -font tiny_fnt -tag "$x0 $stavetag flat" -fill $evv(POINT) 
}

#--- Use coords of notehead, to determine coords of octave-transposition-sign

proc AddOctaveTransposition {octave x0 x1 y1 y2 offset stave insnam stem} {
	global mscore evv
	set stavetag stave$stave
	set x [expr $x1 + $mscore(halfnotewidth)]
	if {$offset < 0} {							;#	Notehead is in upper part of staff
		set y [expr $y1 - $mscore(lineoffset)]	;#	8va transpos info is above notehead
		if {($insnam == "pianoRH") && $stem} {
			incr x 2
		}
	} else {									;#	vice versa
		set y [expr $y2 + $mscore(lineoffset)]
		if {($insnam == "pianoLH") && $stem} {
			incr x 2
		}
	}
	set octave [expr $octave * $evv(STAVE_OCT)]
	if {$octave < 0} {
		set octave [expr -$octave]
	}
	set coords [list $x $y $octave]
	$mscore(can) create text $x $y -text $octave -font tiny_fnt -tag "$x0 $stavetag octave" -fill $evv(POINT)
}

#--- Determine coords of stem, flags and any ties

proc SetStemFlagsTies {treble midi dur offset time under_triplet insnam} {
	global evv mscore
	if {$under_triplet} {	;#	ties beyond triplet group not permitted
		if {[expr $time + $dur] > $mscore(tripletlimit)} {
			Inf "Triplet tied beyond bound of triplet-bracket at time $time in instrument $insnam"
			return {} 
		}
	} elseif {$dur % $evv(QP_SEMIQ) != 0} {
		Inf "Invalid duration ($dur) outside a triplet, at time $time (or triplet not detected)"
		return {} 
	}

	if {$offset < 0} {
		set up 0		;#	stems down
	} else {
		set up 1		;#	stems up
	}	
	set tie 0						
	if {$treble > 1} {	 ;# Double stave (e.g. piano)
		if {$midi < 60} {
			set treble 0
		} else {
			set treble 1
		}
	}
	set raised 0		;#	Do the dots (of dotted notes) need to be raised above the staff-line

	if {$treble} {
		switch -- $midi {
			56 {set raised 1 ;# Ab }
			57 {set raised 1 ;# A  }
			60 {set raised 1 ;# C  }
			63 {set raised 1 ;# Eb }
			64 {set raised 1 ;# E  }
			66 {set raised 1 ;# Gb }
			67 {set raised 1 ;# G  }
			70 {set raised 1 ;# Bb }
			71 {set raised 1 ;# B  }
			73 {set raised 1 ;# Db }
			74 {set raised 1 ;# D  }
			77 {set raised 1 ;# F  }
			80 {set raised 1 ;# Ab }
			81 {set raised 1 ;# A  }
			84 {set raised 1 ;# C  }
		} 
	} else {
		switch -- $midi {
			36 {set raised 1 ;# C  }
			39 {set raised 1 ;# Eb }
			40 {set raised 1 ;# E  }
			42 {set raised 1 ;# Gb }
			43 {set raised 1 ;# G  }
			46 {set raised 1 ;# Bb }
			47 {set raised 1 ;# B  }
			49 {set raised 1 ;# Db }
			50 {set raised 1 ;# D  }
			53 {set raised 1 ;# F  }
			56 {set raised 1 ;# Ab }
			57 {set raised 1 ;# A  }
			60 {set raised 1 ;# C  }
			63 {set raised 1 ;# Eb }
			64 {set raised 1 ;# E  }
		}
	}
	set coords $raised

	;#	Raised = dot on any dotted notes needs to be raised above the staff-line
	;#	Tie    = length of any tie between tied notes
	;#	Fill   = is black notehead
	;#	Stem   = has (has no) stem
	;#	Flag   = has (does note have) flags (for quaver, semiquaver)
	;#	Dot    = does (does not have) dot or double-dot extender

	if {$under_triplet} {	
	
	;#	NB switch is on "dur" which counts quantisation-units (1/3rd of semitones) involved in note-durations
	;#
	;#	Double-dotted notes under triplets not permitted
	;#
	;#	The following triplet-event durations are possible (where q implies a TRIPLET-q etc.)
	;#	4 = q		8  = c		16 = m		32 = sb
	;#	12 = c.		24 = m.
	;#
	;#	20 m->q		28 m->c.
	;#	16+4		16+12
	
		switch -- $dur {
			4	{ set fill 1; set stem 1; set flag 1; set dot 0; set tie 0 }
			8	{ set fill 1; set stem 1; set flag 0; set dot 0; set tie 0 }
			12	{ set fill 1; set stem 1; set flag 0; set dot 1; set tie 0 }
			16 { 
				set pos [expr ($time - $mscore(tripletstart)) % $evv(QP_TRIPM)]
				switch -- $pos {
					0 -
					8 {
						set fill 0; set stem 1; set flag 0; set dot 0; set tie 0
					}
					4 -
					12 {
						set fill 1; set stem 1; set flag 0; set dot 1; set tie 4
					}
				}
			}
			20 { 
				set pos [expr ($time - $mscore(tripletstart)) % $evv(QP_TRIPM)]
				switch -- $pos {
					0 {
						set fill 0; set stem 1; set flag 0; set dot 0; set tie 4
					}
					4 {
						set fill 1; set stem 1; set flag 0; set dot 1; set tie 8
					}
					8 {
						set fill 1; set stem 1; set flag 0; set dot 0; set tie 12
					}
					12 {
						set fill 1; set stem 1; set flag 1; set dot 0; set tie 16
					}
				}
			}
			24 { 
				set pos [expr ($time - $mscore(tripletstart)) % $evv(QP_TRIPM)]
				switch -- $pos {
					0 -
					8 {
						set fill 0; set stem 1; set flag 0; set dot 1; set tie 0
					} 
					4 -
					12 {
						set fill 1; set stem 1; set flag 0; set dot 1; set tie 12
					}
				}
			}
			28 { 
				set pos [expr ($time - $mscore(tripletstart)) % $evv(QP_TRIPM)]
				switch -- $pos {
					0 -
					8 {
						set fill 0; set stem 1; set flag 0; set dot 0; set tie 12
					} 
					4 -
					12 {
						set fill 1; set stem 1; set flag 0; set dot 1; set tie 16
					}
				}
			}
			32	{ set fill 0; set stem 0; set flag 0; set dot 0; set tie 0 }
			default {
				Inf "Invalid triplet duration $dur at time $time in instrument $insnam" 
				return {}
			}
		}
		if {$tie} {
			set outtie [expr $dur - $tie]
		} else {
			set outtie 0
		}
		lappend coords $fill $stem $flag $dot $outtie
		if {$tie > 0} {
			switch -- $tie {
				4  { set fill 1; set stem 1; set flag 1; set dot 0; set tie 0 }
				8  { set fill 1; set stem 1; set flag 0; set dot 0; set tie 0 }
				12 { set fill 1; set stem 1; set flag 0; set dot 1; set tie 0 }
				16 { set fill 0; set stem 1; set flag 0; set dot 0; set tie 0 }
			}
			lappend coords $fill $stem $flag $dot $tie
		}
		return $coords
	}
	set unitoffset [expr $time % $evv(QP_CROTCHET)]
	set crotchetoffset [expr $unitoffset/$evv(QP_SEMIQ)]
	if {$crotchetoffset * $evv(QP_SEMIQ) != $unitoffset} {
		Inf "Invalid non-triplet duration $dur at time $time in instrument $insnam" 
		return {}
	}
	if {($crotchetoffset > 0) && ([expr $unitoffset + $dur] > $evv(QP_CROTCHET))} {
		set tie [expr $evv(QP_CROTCHET) - $unitoffset]
		switch -- $crotchetoffset {
			1 {
				set fill 1; set stem 1; set flag 1; set dot 1
			}
			2 {
				set fill 1; set stem 1; set flag 1; set dot 0
			}
			3 {
				set fill 1; set stem 1; set flag 2; set dot 0
			}
		}
		lappend coords $fill $stem $flag $dot $tie
		incr dur [expr -$tie]
	}
	set note_continues 1
	set dursemiq [expr $dur/$evv(QP_SEMIQ)]
	while {$note_continues} {

	;#	NB switch is on "dursemiq" which counts semiquaver-units involved in note-durations

		switch -- $dursemiq {
			1	{ set fill 1; set stem 1; set flag 2; set dot 0; set tie 0}
			2	{ set fill 1; set stem 1; set flag 1; set dot 0; set tie 0}
			3	{ set fill 1; set stem 1; set flag 1; set dot 1; set tie 0}
			4	{ set fill 1; set stem 1; set flag 0; set dot 0; set tie 0}
			5	{ set fill 1; set stem 1; set flag 0; set dot 0; set tie 4}
			6	{ set fill 1; set stem 1; set flag 0; set dot 1; set tie 0}		
			7	{ set fill 1; set stem 1; set flag 0; set dot 2; set tie 0}		
			8	{ set fill 0; set stem 1; set flag 0; set dot 0; set tie 0}				
			9	{ set fill 0; set stem 1; set flag 0; set dot 0; set tie 8}				
			10	{ set fill 0; set stem 1; set flag 0; set dot 0; set tie 8}
			11	{ set fill 0; set stem 1; set flag 0; set dot 0; set tie 8}				
			12	{ set fill 0; set stem 1; set flag 0; set dot 1; set tie 0}
			13	{ set fill 0; set stem 1; set flag 0; set dot 1; set tie 12}
			14	{ set fill 0; set stem 1; set flag 0; set dot 0; set tie 8}
			15	{ set fill 0; set stem 1; set flag 0; set dot 0; set tie 8}
			16	{ set fill 0; set stem 0; set flag 0; set dot 0; set tie 0}
			default { 
				  set fill 0; set stem 0; set flag 0; set dot 0; set tie 16
			}
		}
		lappend coords $fill $stem $flag $dot $tie

		if {$tie > 0} {
			switch -- $dursemiq {
				5  { set fill 1; set stem 1; set flag 2; set dot 0; set tie 0 }
				9  { set fill 1; set stem 1; set flag 2; set dot 0; set tie 0 }
				10 { set fill 1; set stem 1; set flag 1; set dot 0; set tie 0 }
				11 { set fill 1; set stem 1; set flag 1; set dot 1; set tie 0 }
				13 { set fill 1; set stem 1; set flag 2; set dot 0; set tie 0 }
				14 { set fill 1; set stem 1; set flag 0; set dot 1; set tie 0 }
				15 { set fill 1; set stem 1; set flag 0; set dot 2; set tie 0 }
				default {
					incr dursemiq -16
					continue
				}
			}
			lappend coords $fill $stem $flag $dot $tie
		}
		set note_continues 0
	}
	;#	output = raised fill stem flag dot tie [fill stem flag dot tie ......]

	return $coords
}

#---- Create note on staff, with stem, flags, dots
#
# NB x0 is the position of the first note in a tied-group, or of a single untied note
#	 x1 is the position of this note

proc CreateNote {insnam midi x0 x1 y1 x2 y2 ycentre offset fill stem flag dot raised ledger staffmiddle stave coincidents colorindex note_shift} {
	global evv mscore
	set stavetag stave$stave
	switch -- $colorindex {
		0 { set note_colour $evv(POINT) }
		1 { set note_colour red }
		2 { set note_colour green }
		3 { set note_colour blue }
		4 { set note_colour orange }
	}
	if {$note_shift} {
		incr x1 $mscore(notewidth)
		incr x2 $mscore(halfnotewidth)
	}
	if {$fill} {
		$mscore(can) create oval $x1 $y1 $x2 $y2 -fill $note_colour -outline $note_colour -tag "notes $x0 $stavetag"	;#	Black notehead
	} else {
		$mscore(can) create oval $x1 $y1 $x2 $y2 -outline $note_colour -tag "notes $x0 $stavetag"					;#	Empty notehead
	}
	if {$insnam == "pianoLH"} {								;#	LH piano note written on upper stave
		set stemorient -1									;#	stem is down
	} elseif {$insnam == "pianoRH"} {						;#	RH piano note written on lower stave
		set stemorient 1									;#	stem is up
	} else {												
		set stemorient $offset								;# otherwise, stem down if offset above stave-middle, and vice-versa
	}
	if {$stem && !$coincidents} {
		if {$stemorient < 0} {								;#	stem is down
			set stemend [expr $ycentre + $mscore(stemlen)]
		} else {											;#	stem is up
			set stemend [expr $ycentre - $mscore(stemlen)]
		}													;#	stem shares tag with notehead	
		$mscore(can) create line $x1 $ycentre $x1 $stemend -fill $evv(POINT) -tag "$x0 $stavetag stem"
	}
	if {($flag > 0) && !$coincidents} {
		if {$stemorient < 0} {								;#	stem down, flags rise from stemend 
			set flagstart $stemend							
			set flagend  [expr $stemend - $mscore(halfnotewidth)]
			set flagleft $x1
			set flagright [expr $x1 + $mscore(halfnotewidth)]
		} else {											;#	stem up, flags rise TO stemend 
			set flagstart $stemend
			set flagend  [expr $stemend + $mscore(halfnotewidth)]
			set flagleft $x1
			set flagright [expr $x1 + $mscore(halfnotewidth)]
		}
		$mscore(can) create line $flagleft $flagstart $flagright $flagend -fill $evv(POINT) -width 2 -tag "$x0 $stavetag flag1"
		if {$flag > 1} {
			if {$stemorient < 0} {							;#	stem down, 2nd flag is ABOVE 1st
				incr flagstart [expr -$mscore(noteoffset)]
				incr flagend   [expr -$mscore(noteoffset)]
			} else {										;#	stem up, 2nd flag is BELOW 1st
				incr flagstart $mscore(noteoffset)
				incr flagend   $mscore(noteoffset)
			}
			$mscore(can) create line $flagleft $flagstart $flagright $flagend -fill $evv(POINT) -width 2 -tag  "$x0 $stavetag flag2"
		}
	}
	if {$dot} {												;#	DOTTED NOTE
		set y $ycentre
		if {$raised} {
			incr y [expr -($mscore(halfnoteheight)+1)]			;#	note on line, dots must be raised above lines
		}
		set x [expr $x1 + $mscore(notewidth) + ($mscore(halfnotewidth)/2)]	;#	Dot after note
		$mscore(can) create oval $x $y [expr $x + 2] [expr $y + 2] -fill $evv(POINT) -tag "$x0 $stavetag dot1"	;#	Tagged with note-position
		if {$dot > 1} {											;#	Double dotted
			incr x [expr $mscore(halfnotewidth)]
			$mscore(can) create oval $x $y [expr $x + 2] [expr $y + 2] -fill $evv(POINT) -tag "$x0 $stavetag dot2"
		}
	}
	if {$ledger != 0} {										;#	LEDGER LINES
		if {($insnam == "pianoLH") && ($midi < 60)} {
			incr staffmiddle $mscore(doublestaffoffset)
		}
		set xa [expr $x1 - $mscore(halfnotewidth)]
		set xb [expr $xa + (2 * $mscore(notewidth))]
		if {$ledger > 0} {
			set upcnt [expr $ledger + 2]
			while {$ledger > 0} {
				set legtag leg$ledger
				set y [expr $staffmiddle - ($upcnt * $mscore(lineoffset))]
				$mscore(can) create line $xa $y $xb $y -fill $evv(POINT) -tag "$x0 $stavetag $legtag"
				incr upcnt -1
				incr ledger -1
			}
		} elseif {$ledger < 0} {
			set dncnt [expr $ledger - 2]
			set dncnt [expr -$dncnt]

			while {$ledger < 0} {
				set legtag leg$ledger
				set y [expr $staffmiddle + ($dncnt * $mscore(lineoffset))]
				$mscore(can) create line $xa $y $xb $y -fill $evv(POINT) -tag "$x0 $stavetag $legtag"
				incr dncnt -1
				incr ledger
			}
		}
	}
}

#--- Draw tiebar

proc CreateTie {x0 x1 ycentre offset stave} {
	global mscore evv

	set stavetag stave$stave
	set noteposition $x0

	incr x0 $mscore(halfnotewidth)	;#	Ties start and end above/below middle of note-head
	incr x1 $mscore(halfnotewidth)

	set halfspan [expr ($x1 - $x0)/2]
	set tiecentre [expr $x0 + $halfspan]
	set radius [expr double($halfspan)/$evv(SIN30)]
	set yoffset [expr $radius - ($radius * $evv(COS30))]
	set xa [expr $tiecentre - $radius]
	set xb [expr $tiecentre + $radius]
	
	;#		xa,ya														       . . . . . . * . . . . . .
	;#  _      . . . . . . * . . . . . .	t = (x1 + x0)/2 : cord-midpoint    .	  *    |    *	   .	
	;# |	   .	  *    |    *	   .	A = (x1 - x0)/2	: half-cord		   .   *			   *   .	
	;# y-offset.		   |O		   .	R = A/(sin 30)	: radius		   .	       |           .		
	;# |_  y-> .   x0------t------x1   .	xa = t - R		: x-coords..	   .*	  	   |          *.	yb = y + C	
	;#		   .	\   A  |      /    .	xb = t + R		: of bounding box  . 	       |           .	ya = yb - 2R
	;#		   .*	  \	   |Z   /     *.	Z = Rcos30		: dist-to-cord	   *		   |           *
	;#		   . 	  R	\30|  /        .	O = R - Z		: y-offset         .          /|\          .
	;#		   *		  \|/          *	ya = y - O		: y-coords..	   .*	   R/30|  \       *.
	;#         .                       .	yb = ya + 2R	: of bounding box  .      /    |Z   \      .	
	;#		   .*	   	              *.							    _  y-> .   x0------t------x1   .		
	;#         .                       .							   |       .		A  |		   .		
	;#		   .   *			   *   .							   y-offset.	  *    |O   *      .				
	;#         .					   .							   |_	   . . . . . . * . . . . . . 			
	;#		   .	  *         *      .								
	;#		   . . . . . . * . . . . . . xb,yb								
	;#
	;#
	;#

	if {$offset < 0} {				;#	Note in upper half of stave: stems down : make tie-bar above noteheads
		set y [expr $ycentre - $mscore(notewidth)]
		set ya [expr $y - $yoffset]
		set yb [expr $ya + ($radius * 2.0)]
		$mscore(can) create arc $xa $ya $xb $yb -start 120 -extent -60 -style arc -outline $evv(POINT) -tag "$noteposition $stavetag"
	} else {						;#	Note in lower half of stave: stems up : make tie-bar below noteheads
		set y [expr $ycentre + $mscore(notewidth)]
		set yb [expr $y + $yoffset]
		set ya [expr $yb - ($radius * 2.0)]
		$mscore(can) create arc $xa $ya $xb $yb -start -120 -extent 60 -style arc -outline $evv(POINT) -tag "$noteposition $stavetag"
	}
}	

#--- Establish Instrument Ranges

proc MscoreRanges {item fnam} {
	if {[string match $item "flute"]} {
		set rangebot 60
		set rangetop 92
		set overlap 0
		set doublestop 1
	} elseif {[string match $item "clarinet"]} {
		set rangebot 50
		set rangetop 91
		set overlap 0
		set doublestop 1
	} elseif {[string match $item "trumpet"]} {
		set rangebot 54
		set rangetop 79
		set overlap 0
		set doublestop 1
	} elseif {[string match $item "pianoRH"]} {
		set rangebot 48
		set rangetop 108
		set overlap 1
		set doublestop 4
	} elseif {[string match $item "pianoLH"]} {
		set rangebot 21
		set rangetop 72
		set overlap 1
		set doublestop 4
	} elseif {[string match $item "violin"]} {
		set rangebot 55
		set rangetop 96
		set overlap 0
		set doublestop 4
	} elseif {[string match $item "cello"]} {
		set rangebot 36
		set rangetop 72
		set overlap 0
		set doublestop 4
	} else {
		if {$fnam == "0"} {
			Inf "Unknown instrument $item"
		} else {
			Inf "Unknown instrument $item in file $fnam"
		}
		return {}
	}
	return [list $rangebot $rangetop $overlap $doublestop]
}

#---- Create rests

proc DoRest {lastnotend time staffcentre stave treble} {
	global mscore evv
	set stavetag stave$stave
	set reststart $lastnotend
	set restdur [expr $time - $reststart]
	set x $reststart							;#	horizontally position rest-left at end of 1st note
	set y $staffcentre							;#	vertically position rest-centre on centre of stave
	if {$treble == 2} {							;#	for double-staff, piano  RH
		incr y [expr $mscore(noteoffset) * -4]	;#	move rest-centre to top of upper stave
	} elseif {$treble == 3} {					;#	for double-staff, piano  LH
		incr y $mscore(doublestaffoffset)		;#	move rest-centre to centre of lower stave
		incr y [expr $mscore(noteoffset) * 4]	;#	move rest-centre to bottom of lower stave
	}
	if {$reststart != 0} {
		if {[IsStartUnderTriplet $reststart]} {		;#	Places (initial) rests under triplet bracketing
		;#	EITHER ALL OF REST UNDER SAME TRIPLET	(Finishes in this loop)
		;#	OR 1ST PART OF REST UNDER TRIPLET, AND 2nd PART NOT UNDER TRIPLET	(starts in this loop and progresses out of it)
		;#	OR 1ST PART OF REST UNDER TRIPLET, AND next PART UNDER DIFFERENT TRIPLET (Stays in this loop : but "tripletlimit" changes)
			
			if {$mscore(tripletlimit) < $time} {
				set firstrestend $mscore(tripletlimit)		;#	Rest ends either within, or at end of triplet-bracket
			} else {
				set firstrestend $time
			}
			set firstrest [expr $firstrestend - $reststart]
			;#	4->q 6->q. 8->c	10->q.q 6+4	12->c. 14->c+q.	16->m	20->m+q	22->m+q.	24->m.	28->m+c.	32->sb	ALL OF TRIPLET TYPE 
			;#	triptie just tells me what's left of the rest: redundant variable

			switch -- $firstrest {
				4  { set triptyp 4;  set dot 0; set triptie 0 } 
				6  { set triptyp 4;  set dot 1; set triptie 0 }
				8  { set triptyp 8;  set dot 0; set triptie 0 }
				12 { set triptyp 8; set dot 1; set triptie 0 }
				16 { 
					set restpos [expr ($reststart - $mscore(tripletstart)) % $evv(QP_TRIPM)]
					switch -- $restpos {
						0 -
						8 {
							set triptyp 16; set dot 0; set triptie 0 
						}
						4 {
							set triptyp 8; set dot 1; set triptie 4 
							incr firstrest -4
						}
						12 {
							set triptyp 4; set dot 0; set triptie 12 
							incr firstrest -12
						}
					}
				}
				20 { 
					set restpos [expr ($reststart - $mscore(tripletstart)) % $evv(QP_TRIPM)]
					switch -- $restpos {
						0 {
							set triptyp 16; set dot 0; set triptie 4 
							incr firstrest -4
						}
						4 {
							set triptyp 8;  set dot 1; set triptie 8 
							incr firstrest -8
						}
						8 {
							set triptyp 8;  set dot 0; set triptie 12 
							incr firstrest -12
						}
						12 {
							set triptyp 4;  set dot 0; set triptie 16 
							incr firstrest -16
						}
					}
				}
				24 { 
					set restpos [expr ($reststart - $mscore(tripletstart)) % $evv(QP_TRIPM)]
					switch -- $restpos {
						0 {
							set triptyp 16; set dot 1; set triptie 0
						} 
						4 {
							set triptyp 8;  set dot 1; set triptie 12 
							incr firstrest -12
						}
						8 {
							set triptyp 8;  set dot 0; set triptie 16 
							incr firstrest -16
						}
						12 {
							set triptyp 16; set dot 1; set triptie 0
						}
					}
				}
				28 { 
					set restpos [expr ($reststart - $mscore(tripletstart)) % $evv(QP_TRIPC)]
					switch -- $restpos {
						0 {
							set triptyp 16; set dot 0; set triptie 12
							incr firstrest -12
						}
						4 {
							set triptyp 8;  set dot 1; set triptie 16
							incr firstrest -16
						}
					}
				}
				32 { 
					set triptyp 32; set dot 0; set triptie 0 
				}
				default {
					Inf "Invalid rest duration under a triplet: before note at time $time"
					return 0
				}

			}
			set x1 [expr ($reststart * $mscore(gridstep)) + $mscore(notes_start)] 		;#	Get grafix x-coord of 1st rest
			switch -- $triptyp {
				4  { MakeQuavertypeRest $x1 $y $dot 0 $stavetag}
				8  { MakeCrotchetRest	$x1 $y $dot $stavetag}
				16 { MakeMinimtypeRest	$x1 $y $dot 0 $stavetag 1}
				32 { MakeMinimtypeRest	$x1 $y $dot 1 $stavetag 1}
			}
			incr reststart $firstrest
			incr restdur [expr -$firstrest]

		} else {	;#	NOT IN TRIPLET: Advances to (no further than) next crotchet boundary (if not at a crotchet  boundary) before continuing

			set crotchetoffset [expr $reststart % $evv(QP_CROTCHET)]	;#	Align end of first rest with a crotchet  boundary, if poss
			if {$crotchetoffset != 0} {
				set firstrest [expr $evv(QP_CROTCHET) - $crotchetoffset]	;#	Duration up to end of next crotchet

				set tie [expr $restdur - $firstrest]		;#	Duration of rest beyond next crotchet-boundary
				if {($firstrest) && ($tie > 0)} {			;#	If rest-duration goes over crotchet boundary, add a rest up to crotchet-boundary
															;#	(if doesn't go over boundary, still adds rest after this code-section quits
					set firstrestsemiq [expr $firstrest/$evv(QP_SEMIQ)]
					switch -- $firstrestsemiq {
						1 { set typ 1; set dot 0} 
						2 { set typ 2; set dot 0}
						3 { set typ 2; set dot 1}
						4 { set typ 4; set dot 0}
					}
					set x1 [expr ($reststart * $mscore(gridstep)) + $mscore(notes_start)] 	;#	Get grafix x-coord of 1st rest
					switch -- $typ {
						1  { MakeQuavertypeRest $x1 $y $dot 1 $stavetag}
						2  { MakeQuavertypeRest $x1 $y $dot 0 $stavetag}
						4  { MakeCrotchetRest	$x1 $y $dot $stavetag}
					}
					incr reststart $firstrest												;#	Advance to associated-rest
					incr restdur [expr -$firstrest]
				}
			}
		}
	}
	while {$restdur > 0} {
		if {[IsStartUnderTriplet $reststart]} {
			if {$mscore(tripletlimit) < $time} {			;#	Rest ends either within, or at end of current triplet-bracket
				set firstrestend $mscore(tripletlimit)
			} else {
				set firstrestend $time
			}
			set firstrest [expr $firstrestend - $reststart]
			;#	NB calculations done on duration in time-units = 1/3 of semiq, triptie represents silence ONLY <= end of (current) triple-tie
			switch -- $firstrest {
				4  { set triptyp 4;  set dot 0; set triptie 0 } 
				8  { set triptyp 8;  set dot 0; set triptie 0 }
				12 { set triptyp 8;  set dot 1; set triptie 0 }
				16 { 
					set restpos [expr ($reststart - $mscore(tripletstart)) % $evv(QP_TRIPM)]
					switch -- $restpos {
						0 {
							set triptyp 16; set dot 0; set triptie 0 
						}
						4 {
							set triptyp 8; set dot 1; set triptie 4 
						}
						8 {
							set triptyp 8; set dot 0; set triptie 8 
						}
						12 {
							set triptyp 4; set dot 0; set triptie 12 
						}
					}
				}
				20 { 
					set restpos [expr ($reststart - $mscore(tripletstart)) % $evv(QP_TRIPM)]
					switch -- $restpos {
						0 {
							set triptyp 16; set dot 0; set triptie 4 
						}
						4 {
							set triptyp 8;  set dot 1; set triptie 8 
						}
						8 {
							set triptyp 8;  set dot 0; set triptie 12 
						}
						12 {
							set triptyp 4;  set dot 0; set triptie 16 
						}
					}
				}
				24 { 
					set restpos [expr ($reststart - $mscore(tripletstart)) % $evv(QP_TRIPM)]
					switch -- $restpos {
						0 {
							set triptyp 16; set dot 1; set triptie 0
						} 
						4 {
							set triptyp 8;  set dot 1; set triptie 12 
						}
						8 {
							set triptyp 8;  set dot 0; set triptie 16 
						}
						12 {
							set triptyp 16; set dot 1; set triptie 0
						}
					}
				}
				28 { 
					set restpos [expr ($reststart - $mscore(tripletstart)) % $evv(QP_TRIPC)]
					switch -- $restpos {
						0 {
							set triptyp 16; set dot 0; set triptie 12
						}
						4 {
							set triptyp 8;  set dot 1; set triptie 16
						}
					}
				}
				32 { 
					set triptyp 32; set dot 0; set triptie 0 
				}
				default {
					Inf "Invalid rest duration under a triplet: before note at time $time"
					return 0
				}
			}
			set x1 [expr ($reststart * $mscore(gridstep)) + $mscore(notes_start)] 		;#	Get grafix x-coord of 1st rest
			switch -- $triptyp {
				4  { MakeQuavertypeRest $x1 $y $dot 0 $stavetag}
				8  { MakeCrotchetRest	$x1 $y $dot $stavetag}
				16 { MakeMinimtypeRest	$x1 $y $dot 0 $stavetag 1}
				32 { MakeMinimtypeRest	$x1 $y $dot 1 $stavetag 1}
			}
			incr restdur [expr -$firstrest]
			incr reststart $firstrest													;#	Advance to end of rest

		} else {													;#	NOT in a triplet-bracket

			;#	NB calculations done on duration in semiquavers, tie always represents ALL silence up to next note

			set restdursemiq [expr $restdur/$evv(QP_SEMIQ)]

			if {[IsEndWithinTriplet $time]} {					;#	Total-rest ends within an ensuing triplet-brace
				set firstrestend $mscore(tripletstart)			;#	So current part-rest ends at start of that triplet-brace	
				set firstrest [expr $firstrestend - $reststart]
				set firstrestsemiq [expr $firstrest/$evv(QP_SEMIQ)]
			} else {											;#	Else rest continues to its true end
				set firstrestsemiq $restdursemiq
			}
			;#	tie just tells me what's left of the rest (in semiqs): redundant variable
			switch -- $firstrestsemiq {
				1  { set typ 1;  set dot 0; set tie 0} 
				2  { set typ 2;  set dot 0; set tie 0}
				3  { set typ 2;  set dot 1; set tie 0}
				4  { set typ 4;  set dot 0; set tie 0}
				5  { set typ 4;  set dot 0; set tie 1}
				6  { set typ 4;  set dot 1; set tie 0}
				7  { set typ 4;  set dot 0; set tie 3}
				8  { set typ 8;  set dot 0; set tie 0}
				9  { set typ 8;  set dot 0; set tie 1}
				10 { set typ 8;  set dot 0; set tie 2}
				11 { set typ 8;  set dot 0; set tie 3}
				12 { set typ 8;  set dot 0; set tie 4}
				13 { set typ 8;  set dot 0; set tie 5}
				14 { set typ 8;  set dot 0; set tie 6}
				15 { set typ 8;  set dot 0; set tie 7}
				16 { set typ 16; set dot 0; set tie 0}
				default {
					set typ 16; set dot 0; set tie [expr $restdursemiq - 16]
				}
			}
			set x1 [expr ($reststart * $mscore(gridstep)) + $mscore(notes_start)] 		;#	Get grafix x-coord of 1st rest
			switch -- $typ {
				1  { MakeQuavertypeRest $x1 $y $dot 1 $stavetag}
				2  { MakeQuavertypeRest $x1 $y $dot 0 $stavetag}
				4  { MakeCrotchetRest	$x1 $y $dot $stavetag}
				8  { MakeMinimtypeRest  $x1 $y $dot 0 $stavetag 0}
				16 { MakeMinimtypeRest	$x1 $y $dot 1 $stavetag 0}
			}
			incr firstrestsemiq [expr -$tie]
			incr restdursemiq [expr -$firstrestsemiq]
			set restdur [expr $restdursemiq * $evv(QP_SEMIQ)]
			incr reststart [expr $firstrestsemiq * $evv(QP_SEMIQ)]						;#	Advance to end of rest
		}
	}
	return 1
}

proc MakeQuavertypeRest {x y dot semiquaver stavetag} {
	global evv mscore
	set left [expr $x + 2]									;#    /
	set right [expr $left + $mscore(notewidth) - 2]			;#   /
	set top [expr $y - $mscore(lineoffset)]					;#  /
	set bot	[expr $y + $mscore(lineoffset)]
	$mscore(can) create line $left $bot $right $top -fill $evv(POINT) -width 2 -tag "rest $stavetag"
	set y $top
	set halfspan [expr $mscore(notewidth) - 2]
	set curvcentre [expr ($left + $right)/2]
	set radius [expr double($halfspan)/$evv(SIN60)]
	set yoffset [expr $radius - ($radius * $evv(COS60))]

	set xa [expr $curvcentre - $radius]
	set xb [expr $curvcentre + $radius]
	
	;#		xa,ya	
	;#		   . . . . . . * . . . . . .	t = (x1 + x0)/2 : cord-midpoint
	;#	       .	  *    |    *	   .	A = (x1 - x0)/2	: half-cord
	;# 		   .   *			   *   .	R = A/(sin 60)	: radius
	;#		   .	       |           .	xa = t - R		: x-coords..
	;#		   .*	  	   |          *.	xb = t + R		: of bounding box
	;#		   . 	       |           .	Z =	Rcos60		: dist-to-cord
	;#		   *		   |           *	O = R - Z		: y-offset
	;#		   .          /|\          .	yb = y + C	
	;#		   .	   R/60|  \       *.	ya = yb - 2R
	;#		   .      /    |Z   \      .	
	;#  _  y-> .   x0------t------x1   .		
	;# |       .		A  |		   .		
	;# y-offset.	  *    |O   *      .				
	;# |_	   . . . . . . * . . . . . . 			
	;#								  xb,yb								
	;#
	;#
	;#

	set yb [expr $y + $yoffset]
	set ya [expr $yb - ($radius * 2.0)]
	$mscore(can) create arc $xa $ya $xb $yb -start -135 -extent 70 -style arc -outline $evv(POINT) -width 2 -tag "rest $stavetag"
	if {$semiquaver} {
		set ya [expr $ya + $mscore(halfnotewidth)]
		set yb [expr $yb + $mscore(halfnotewidth)]
		$mscore(can) create arc $xa $ya $xb $yb -start -135 -extent 60 -style arc -outline $evv(POINT) -width 2 -tag "rest $stavetag"
	}
	if {$dot > 0} {
		incr y [expr $mscore(noteheight)]
		incr right
		$mscore(can) create oval $right $y [expr $right + 2] [expr $y + 2] -fill $evv(POINT) -tag "rest $stavetag"
	}
	if {$dot > 1} {
		incr right $mscore(halfnotewidth)
		$mscore(can) create oval $right $y [expr $right + 2] [expr $y + 2] -fill $evv(POINT) -tag "rest $stavetag"
	}
}	

proc MakeMinimtypeRest {x y dot semibreve stavetag undertriplet} {
	global evv mscore
	set restheight [expr $mscore(halfnoteheight) + ($mscore(halfnoteheight)/2)] 
	set right [expr $mscore(notewidth) + 2]
	set left  0												;#	 __
	set top   [expr -$restheight]							;#  |__|
	set bot   0												;#  

	if {$semibreve} {
		incr x [expr $evv(QP_CROTCHET) * $mscore(gridstep)]
		if {!$undertriplet} {
			incr x [expr $evv(QP_QUAVER) * $mscore(gridstep)]
		}
		incr right $x
		incr left $x
		incr top [expr $y + $restheight]
		incr bot [expr $y + $restheight]
	} else {
		if {$undertriplet} {
			incr x [expr $evv(QP_SEMIQ) * $mscore(gridstep)]
		} else {
			incr x [expr $evv(QP_QUAVER) * $mscore(gridstep)]
		}
		incr right $x
		incr left $x
		incr top $y
		incr bot $y
	}
	$mscore(can) create poly $left $top $right $top $right $bot $left $bot -outline $evv(POINT) -fill $evv(POINT) -tag "rest $stavetag"
	if {$dot > 0} {
		set x1 [expr $x + $mscore(notewidth) + 4]
		incr y [expr -$mscore(halfnoteheight)]
		$mscore(can) create oval $x1 $y [expr $x1 + 2] [expr $y + 2] -fill $evv(POINT) -tag "rest $stavetag"
	}
	if {$dot > 1} {
		incr x1 $mscore(halfnotewidth)
		$mscore(can) create oval $x1 $y [expr $x1 + 2] [expr $y + 2] -fill $evv(POINT) -tag "rest $stavetag"
	}
}

proc MakeCrotchetRest {x y dot stavetag} {
	global evv mscore
	set seglen [expr $mscore(lineoffset) - 3]		;#  \  (b) 
	set left $x										;#  // (a)
	set right [expr $x + $mscore(notewidth)]			;#  \  (c)
	;# (a)											;#  CC (d)
	set top [expr $y - $seglen]
	set bot	$y
	$mscore(can) create line $left $bot $right $top -fill $evv(POINT) -width 2 -tag "rest $stavetag"
	;# (b)
	set bot $top
	set top [expr $top - $seglen]
	$mscore(can) create line $right $bot [expr $left + 2] $top -fill $evv(POINT) -width 1 -tag "rest $stavetag"
	;# (c)
	set top $y
	set bot [expr $top + $seglen]
	$mscore(can) create line $right $bot $left $top -fill $evv(POINT) -width 1 -tag "rest $stavetag"
	;# (d)
	set xa $left
	set xb [expr $left + ($mscore(notewidth) * 2)]
	set ya $bot
	set yb [expr $bot + $mscore(notewidth) + 1]
	$mscore(can) create arc $xa $ya $xb $yb -start 90 -extent 180 -style arc -outline $evv(POINT) -width 2 -tag "rest $stavetag"
	if {$dot > 0} {
		incr y [expr -$mscore(halfnoteheight)]
		set x1 [expr $x + $mscore(notewidth) + 2]
		$mscore(can) create oval $x1 $y [expr $x1 + 2] [expr $y + 2] -fill $evv(POINT) -tag "rest $stavetag"
	}
	if {$dot > 1} {
		incr x1 $mscore(halfnotewidth)
		$mscore(can) create oval $x1 $y [expr $x1 + 2] [expr $y + 2] -fill $evv(POINT) -tag "rest $stavetag"
	}
}

#---- Show information held by Loom on multisynth instruments

proc DarwinShow {} {
	global darwin_instruments evv
	set msg "\tSCORE FORMAT\n\n"
	append msg "Name1  T1  M1  L1  D1 \[T2  M2  L2  D2 etc.\]\n"  
	append msg "\[Name2 Tn  Mn  Ln  Dn etc.\]\n"  
	append msg "etc\n\n"
	append msg "Name = Name of instrument\n"
	append msg "T = Time: integer no of thirds-of-semiquaver.\n"
	append msg "M = Pitch as MIDI value\n"
	append msg "L = Loudness in range >0 to 1\n"
	append msg "D = Duration in whole thirds-of-semiquavers.\n"
	append msg "\n"
	append msg "Times in any named instrument must increase,\n"
	append msg "unless \"Chords\" is greater than 1 (see below).\n"
	append msg "\n"
	append msg "When time advances\n"
	append msg "Minimum advance = 3 units (1 semiquaver).\n"
	append msg "\n"
	append msg "Times must occur at some multiple of $evv(QP_SEMIQ) or $evv(QP_TRIPQ)\n"
	append msg "(multiple of semiquavers or quaver-triplets).\n"
	append msg "Dotted triplet-quavers are not permitted.\n"
	append msg "Double-dotted triplet-notes are not permitted.\n"
	append msg "Ties into and out-of triplet groupings are not permitted.\n"
	append msg "\n"
	append msg "T1+D1 must not be greater than T2 (etc)\n"
	append msg "but sustaining instruments (\"sustain\" = 1)\n"
	append msg "with short notes will overlay successive notes\n"
	append msg "in sound output.\n"
	append msg "\n"
	append msg "KNOWN INSTRUMENTS AND PROPERTIES\n\n"
	append msg	"Name        lo--MIDI--hi       Sustain    Chords\n"
	append msg	"\n"
	foreach instr $darwin_instruments {
		append msg "$instr\t"
		set mscorerange [MscoreRanges $instr 0]
		foreach item $mscorerange {
			append msg "$item\t"
		}
		append msg "\n"
	}
	Inf $msg
}

#---- Initialise Loom's knowledge of synth instruments

proc LoadDarwinInstrs {} {
	global darwin_instruments
	set darwin_instruments [list flute clarinet trumpet violin cello pianoRH pianoLH]
}

#------ Play sound from a multisynth score file

proc DarwinPlay {fnam fromscore} {
	global pr_darplay darplay mscore evv pa wstk wl total_wksp_cnt rememd pr_darchoice darwin_instruments
	global prg_dun prg_abortd simple_program_messages CDPidrun

	set ofnambas [file rootname $fnam]
	set outfnam $evv(DFLT_OUTNAME)
	append outfnam $evv(SNDFILE_EXT)

	if {($fromscore == 2) || ($fromscore == 3)} {		;#	Play sound output (that already exists) from the score-display page
		set zfnam $ofnambas
		append zfnam "_mm"
														;#	If one (of several) snd outputs has already been selected, choose that
		if {($fromscore == 2) && [info exists mscore(sndout)] && ([string first $zfnam $mscore(sndout)] == 0)} {
			set sndtoplay $mscore(sndout)
		} else {										;#	Otherwise look for possible sound-output files	
			set kcnt 0
			foreach xfnam [$wl get 0 end] {
				if {($pa($xfnam,$evv(FTYP)) == $evv(SNDFILE)) && ([string first $zfnam $xfnam] == 0)} {
					lappend xfnams $xfnam
					incr kcnt
				}
			}
			if {[info exists xfnams]} {
				if {[llength $xfnams] == 1} {			;#	If there's only one possible  sound-output, choose that to play
					if {$fromscore == 3} {
						Inf "There is only one available sound output from this score"
					}
					set sndtoplay [lindex $xfnams 0]
				} else {								;#	Otherwise, choose output to play from a list of possible outputs

					if {$fromscore != 3} {
						Inf "There is more than one possible output from this score\n\nchoose the output you want to hear on the workspace"
					}
					set f .darwinchoice
					if [Dlg_Create $f "SELECT SOUND OF SCORE" "set pr_darchoice 0" -borderwidth $evv(SBDR)] {
						frame $f.0
						frame $f.1
						frame $f.2
						button $f.0.s -text "Select"  -command "set pr_darchoice 1" -highlightbackground [option get . background {}]
						button $f.0.p -text "Play"    -command "set pr_darchoice 2" -highlightbackground [option get . background {}]
						button $f.0.q -text "Abandon" -command "set pr_darchoice 0" -highlightbackground [option get . background {}]
						pack $f.0.s -side left
						pack $f.0.q -side right
						pack $f.0 -side top -fill x -expand true
						label $f.1.ll -text "Select required sound with mouse-click" -fg $evv(SPECIAL)
						pack $f.1.ll -side left
						pack $f.1 -side top
						Scrolled_Listbox $f.2.ll -width 64 -height 24 -selectmode single]
						pack $f.2.ll -side top -fill both -expand true
						pack $f.2 -side top
						wm resizable $f 0 0
						bind $f <Return> {set pr_darchoice 1}
						bind $f <Escape> {set pr_darchoice 0}
					}
					$f.2.ll.list delete 0 end
					foreach ff $xfnams {
						$f.2.ll.list insert end $ff
					}
					set pr_darchoice 0
					update idletasks
					StandardPosition2 $f
					raise $f
					My_Grab 0 $f pr_darchoice $f.2.ll.list
					set finished 0
					while {!$finished} {
						tkwait variable pr_darchoice
						switch -- $pr_darchoice {
							1 {
								set i [$f.2.ll.list	curselection]
								if {![info exists i] || ($i < 0)} {
									Inf "No sound selected"
									continue
								}
								set mscore(sndout) [$f.2.ll.list get $i]		;#	Set the selected file as the file to use on any future call
								set finished 1
							}
							2 {
								set i [$f.2.ll.list	curselection]
								if {![info exists i] || ($i < 0)} {
									Inf "No sound selected"
									continue
								}
								set ff [$f.2.ll.list get $i]
								PlaySndfile $ff 0
							}
							0 {
								set finished 1
							}
						}
					}
					My_Release_to_Dialog $f
					Dlg_Dismiss $f
					if [info exists mscore(sndout)] {
						set sndtoplay $mscore(sndout)
					} else {
						return
					}
				}
			}
		}
		if {[info exists sndtoplay]} {
			PlaySndfile $sndtoplay 0
			return

		} else {

			set msg "No pre-existing score sound output exists. create one ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			}
		}
	} elseif {![IsMultisynthScorefile $fnam]} {
		return
	}
	set mscore(infnam) $fnam
	if {![info exists darplay(mm)]} {
		set darplay(mm) $mscore(dflt_mm)
		set darplay(ochans) $mscore(dflt_ochans)
		set darplay(jitter) $mscore(dflt_jitter)
	}
	if {![info exists darplay(linear)]} {
		set darplay(linear) 0
	}
	DeleteAllTemporaryFiles
	set namwidth [string length [file rootname [file tail $fnam]]]
	incr namwidth 20
	set f .darplay
	if [Dlg_Create $f "CREATE SOUND FROM SCORE" "set pr_darplay 0" -width 120 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		frame $f.0
		frame $f.1
		frame $f.2
		frame $f.3
		frame $f.4
		button $b.q -text "Quit" -command "set pr_darplay 0" -width 6 -highlightbackground [option get . background {}]
		button $b.c -text "Create" -command "set pr_darplay 1" -width 6 -highlightbackground [option get . background {}]
		button $b.p -text "Play" -command "set pr_darplay 2" -width 6 -highlightbackground [option get . background {}]
		button $b.s -text "Save" -command "set pr_darplay 3" -highlightbackground [option get . background {}]
		pack $b.q -side right -padx 2
		pack $b.c $b.p $b.s -side left -padx 2
		pack $b -side top -pady 2 -fill x -expand true
		label $f.msg1 -text "If sound output is saved, it adopts the name of the score" -fg $evv(SPECIAL)
		label $f.msg2 -text "" -fg $evv(SPECIAL)
		pack $f.msg1 $f.msg2 -side top
		button $f.0.b -text Dflt -command "set darplay(mm) $mscore(dflt_mm)" -highlightbackground [option get . background {}]
		entry $f.0.e -textvariable darplay(mm) -width 6
		label $f.0.ll -text "MM (Range $mscore(min_mm) to $mscore(max_mm))" 
		pack $f.0.b $f.0.e $f.0.ll -side left -pady 2 -padx 2
		pack $f.0 -side top -fill x -expand true
		button $f.1.b -text Dflt -command "set darplay(ochans) $mscore(dflt_ochans)" -highlightbackground [option get . background {}]
		entry $f.1.e -textvariable darplay(ochans) -width 6
		label $f.1.ll -text "output channel cnt (Range $mscore(min_ochans) to $mscore(max_ochans))" 
		pack $f.1.b $f.1.e $f.1.ll -side left -pady 2 -padx 2
		pack $f.1 -side top -fill x -expand true
		button $f.2.b -text Dflt -command "set darplay(jitter) $mscore(dflt_jitter)" -highlightbackground [option get . background {}]
		entry $f.2.e -textvariable darplay(jitter) -width 6
		label $f.2.ll -text "jitter (mS) (Range $mscore(min_jitter) TO $mscore(max_jitter))" 
		pack $f.2.b $f.2.e $f.2.ll -side left -pady 2 -padx 2
		pack $f.2 -side top -fill x -expand true
		checkbutton $f.3.cb -text "Linear array output" -variable darplay(linear)
		pack $f.3.cb -side top -pady 2
		pack $f.3 -side top -pady 2 -fill x -expand true
		label $f.4a -text "Play individual score lines" -fg $evv(SPECIAL)
		pack $f.4a -side top -pady 2
		foreach nam $darwin_instruments {
			if {[string first "piano" $nam] == 0} {
				continue
			}
			frame $f.4.$nam
			label $f.4.$nam.ll -text $nam -width 8 -anchor w
			button $f.4.$nam.create -text Create -width 8 -command "DarwinPlayStave $nam create scoreplay" -highlightbackground [option get . background {}]
			pack $f.4.$nam.ll $f.4.$nam.create -side left -padx 2
			pack $f.4.$nam -side top -fill x -expand true
		}
		frame $f.4.piano
		label $f.4.piano.ll -text piano -width 8 -anchor w
		button $f.4.piano.create -text Create -width 8  -command "DarwinPlayStave piano create scoreplay" -highlightbackground [option get . background {}]
		pack $f.4.piano.ll $f.4.piano.create -side left -padx 2
		pack $f.4.piano -side top -fill x -expand true
		pack $f.4 -side top -pady 2 -fill x -expand true
		wm resizable $f 0 0
		bind $f <Return> {set pr_darplay 1}
		bind $f <Key-space> {set pr_darplay 2}
		bind $f <Escape> {set pr_darplay 0}
	}
	if {($fromscore == 2) || ($fromscore == 3)} {
		foreach nam $darwin_instruments {
			if {[string first "piano" $nam] == 0} {
				continue
			}
			$f.4.$nam.create config -text "" -bd 0 -state disabled -background [option get . background {}]
		}
		$f.4.piano.create config -text "" -bd 0 -state disabled -background [option get . background {}]
	} else  {
		foreach nam $darwin_instruments {
			if {[string first "piano" $nam] == 0} {
				continue
			}
			if {[lsearch $mscore(insnams) $nam] >= 0} {
				$f.4.$nam.create config -text "Make Snd" -bd 2 -state normal -command "DarwinPlayStave $nam create scoreplay" -bg [option get . background {}]
				set ispiano 1
			} else {
				$f.4.$nam.create config -text "" -bd 0 -state disabled -background [option get . background {}]
			}
		}
		if {([lsearch $mscore(insnams) "pianoRH"] >= 0) || ([lsearch $mscore(insnams) "pianoLH"] >= 0)} {
			$f.4.piano.create config -text "Make Snd" -bd 2 -state normal -command "DarwinPlayStave piano create scoreplay" -bg [option get . background {}]
		} else {
			$f.4.piano.create config -text "" -bd 0 -state disabled -background [option get . background {}]
		}
	}
	wm title $f "CREATE SOUND FROM SCORE [file rootname [file tail $fnam]]"
	$f.msg2 config -text "\"[file rootname [file tail $fnam]].wav\""
	$f.b.p config -bd 0 -command {} -text "" -background [option get . background {}]  -state disabled
	$f.b.s config -bd 0 -command {} -text "" -background [option get . background {}]  -state disabled -width $namwidth 
	$f.b.c config -bd 2 -command "set pr_darplay 1" -text "CREATE" -state normal -bg $evv(EMPH)

	set pr_darplay 0
	update idletasks
	StandardPosition2 $f
	raise $f
	My_Grab 0 $f pr_darplay $f.1.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_darplay
		switch -- $pr_darplay {
			1 {

				;#	THIS MAY BE A 2ND PASS AROUND SOUND-CREATION, SO DISABLE THE "PLAY" BUTTON

				$f.b.p config -bd 0 -command {} -text "" -background [option get . background {}]  -state disabled
				DeleteAllTemporaryFiles

				;#	Get the MM

				if {![IsNumeric $darplay(mm)] || ($darplay(mm) < $mscore(min_mm)) || ($darplay(mm) > $mscore(max_mm))} {
					Inf "Invalid MM value entered (must be numeric,  in range $mscore(min_mm) to $mscore(max_mm))"
					continue
				}

				;#	CREATE THE OUTPUT FILENAME, INCORPORATING THE MM VALUE

				set ofnam $ofnambas
				append ofnam "_" "mm" $darplay(mm) $evv(SNDFILE_EXT)

				;#	CHECK IF THE OUTPUT FILE ALREADY EXISTS, AND IF SO, PRESENT OPTIONS TO PLAY, OVERWRITE, OR CHANGE NAME

				if {[file exists $ofnam]} {									;#	Play existing sound, and quit
					set msg "Play existing soundfile $ofnam ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						PlaySndfile $ofnam 0
						if {$fromscore} {									;#	If called from the score-diplay page, play and return
							set mscore(sndout) $ofnam						;#	set this as the sound to use on future calls from the score-display page
							set finished 1									;#	and quit
							break
						} else {
							$f.b.p config -bd 2 -command "set pr_darplay 4" -text "PLAY" -state normal -bg $evv(EMPH)
							continue
						}
					} else {
						$f.b.p config -bd 0 -command {} -text "" -background [option get . background {}]  -state disabled
					}
					set msg "If you want to save the output of this process"
					append msg "\nyou can overwrite the existing soundfile"
					append msg "\nor you can create a file, with a different name."
					append msg "\n\noverwrite the existing file ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						if [catch {file delete $ofnam} zit] {				;#	Overwrite the existing sound
							Inf "Cannot delete existing soundfile $ofnam"
							continue
						} else {
							set i [LstIndx $ofnam $wl]
							if {$i >= 0} {
								PurgeArray $ofnam
								RemoveFromChosenlist $ofnam
								incr total_wksp_cnt -1
								$wl delete $i
								catch {unset rememd}
							}
						}
					} else {
						set msg "Create a new output file name ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set kcnt 2											;#	Create file with a new name
							set rroot [file rootname $ofnam]
							set nuofnam $rroot 
							append nuofnam "_" $kcnt $evv(SNDFILE_EXT)
							while {[file exists $nuofnam]} {
								incr kcnt
								set nuofnam $rroot
								append nuofnam "_" $kcnt $evv(SNDFILE_EXT)
							}
							set ofnam $nuofnam						
							Inf "File will be named $ofnam"
						} else {
							continue
						}
					}
				}
				if {![IsNumeric $darplay(ochans)] || ![regexp {^[0-9]+$} $darplay(ochans)] \
				|| ($darplay(ochans) < $mscore(min_ochans)) || ($darplay(ochans) > $mscore(max_ochans))} {
					Inf "Invalid output channel count entered (must be integer, in range $mscore(min_ochans) to $mscore(max_ochans))"
					continue
				}
				if {![IsNumeric $darplay(mm)] || ($darplay(mm) < $mscore(min_mm)) || ($darplay(mm) > $mscore(max_mm))} {
					Inf "Invalid MM value entered (must be numeric,  in range $mscore(min_mm) to $mscore(max_mm))"
					continue
				}
				if {[string length $darplay(jitter)] == 0} {
					set darplay(jitter) $mscore(dflt_jitter)
				} elseif {![IsNumeric $darplay(jitter)] || ($darplay(jitter) < $mscore(min_jitter)) || ($darplay(jitter) > $mscore(max_jitter))} {
					Inf "Invalid jitter value entered (must be numeric,  in range $mscore(min_jitter) to $mscore(max_jitter))"
					continue
				}
				Block "Creating sound from score [file rootname [file tail $fnam]]"
				set cmd [file join $evv(CDPROGRAM_DIR) multisynth]
				lappend cmd synth $outfnam $fnam $darplay(mm) -o$darplay(ochans) -j$darplay(jitter)
				if {$darplay(linear)} {
					lappend cmd "-b"
				}
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "FAILED TO RUN SYNTHESIS OF $ofnam"
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
					set msg "Failed to synthesize $ofnam"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					UnBlock
					continue
				}
				if {![file exists $outfnam]} {
					set msg "FAILED TO CREATE THE OUTPUT FILE"
					set msg [Addsimplemessages $msg]
					ErrShow $msg
					UnBlock
					continue
				}
				$f.b.c config -bd 2 -command "set pr_darplay 5" -text "RESET" -state normal -bg [option get . background {}]
				$f.b.p config -bd 2 -command "set pr_darplay 2" -text "PLAY" -state normal -bg $evv(EMPH)
				$f.b.s config -bd 2 -command "set pr_darplay 3" -text "SAVE \"$ofnam\"" -state normal -bg $evv(EMPH)
				UnBlock
				continue
			}
			2 {
				PlaySndfile $outfnam 0
				continue
			}
			3 {
				if {![file exists $outfnam]} {
					Inf "No output file to save"
					continue
				}
				if [catch {file rename $outfnam $ofnam} zit] {
					Inf "Cannot rename the output file"
					continue
				}
				FileToWkspace $ofnam 0 0 0 0 1
				Inf "File $ofnam is on the workspace"
				$f.b.s config -bd 0 -command {} -text "" -background [option get . background {}]  -state disabled -width $namwidth 
				$f.b.p config -bd 0 -command {} -text "" -background [option get . background {}]  -state disabled 
				$f.b.c config -bd 2 -command "set pr_darplay 1" -text "CREATE" -state normal -bg $evv(EMPH)
				continue
			}
			4 {
				PlaySndfile $ofnam 0
				continue
			}
			5 {
				$f.b.s config -bd 0 -command {} -text "" -background [option get . background {}]  -state disabled -width $namwidth 
				$f.b.p config -bd 0 -command {} -text "" -background [option get . background {}]  -state disabled 
				$f.b.c config -bd 2 -command "set pr_darplay 1" -text "CREATE" -state normal -bg $evv(EMPH)
			}
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc DoLongStemAndFlags {x0 x1 midimin midimax flag treble insnam sm stave} {
	global mscore evv
	set stavetag stave$stave
	set midimean [expr ($midimax + $midimin)/2.0]
	if {$insnam == "pianoLH"} {								;#	piano LH; stem down
		set stemfoot [ConvertToCoords $midimax $treble $insnam $sm]
		set stemend [expr [ConvertToCoords $midimin $treble $insnam $sm] + $mscore(stemlen)]
		set offset -1
	} elseif {$insnam == "pianoRH"} {						;#	or piano RH; stem up
		set stemfoot [ConvertToCoords $midimin $treble $insnam $sm]
		set stemend [expr [ConvertToCoords $midimax $treble $insnam $sm] - $mscore(stemlen)]
		set offset 1
	} elseif {$midimean >= 60} {								;#	notes on average high: stem down
		set stemfoot [ConvertToCoords $midimax $treble $insnam $sm]
		set stemend [expr [ConvertToCoords $midimin $treble $insnam $sm] + $mscore(stemlen)]
		set offset -1
	} else {												;#	notes on average low : stem up
		set stemfoot [ConvertToCoords $midimin $treble $insnam $sm]
		set stemend [expr [ConvertToCoords $midimax $treble $insnam $sm] - $mscore(stemlen)]
		set offset 1
	}													
															;#	stem shares tag with notehead	
	$mscore(can) create line $x1 $stemfoot $x1 $stemend -fill $evv(POINT) -tag "$x0 $stavetag stem"

	if {$flag > 0} {
		if {$offset < 0} {									;#	High note, stem down, flags rise from stemend 
			set flagstart $stemend
			set flagend  [expr $stemend - $mscore(halfnotewidth)]
			set flagleft $x1
			set flagright [expr $x1 + $mscore(halfnotewidth)]
		} else {											;#	Low note, stem up, flags rise TO stemend 
			set flagstart $stemend
			set flagend  [expr $stemend + $mscore(halfnotewidth)]
			set flagleft $x1
			set flagright [expr $x1 + $mscore(halfnotewidth)]
		}
		$mscore(can) create line $flagleft $flagstart $flagright $flagend -fill $evv(POINT) -width 2 -tag "$x0 $stavetag flag1"
		if {$flag > 1} {
			if {$offset < 0} {								;#	stem down, 2nd flag is ABOVE 1st
				incr flagstart [expr -$mscore(noteoffset)]
				incr flagend   [expr -$mscore(noteoffset)]
			} else {										;#	stem up, 2nd flag is BELOW 1st
				incr flagstart $mscore(noteoffset)
				incr flagend   $mscore(noteoffset)
			}
			$mscore(can) create line $flagleft $flagstart $flagright $flagend -fill $evv(POINT) -width 2 -tag  "$x0 $stavetag flag2"
		}
	}
}

proc ConvertToCoords {midi treble insnam sm} {
	global mscore
	set noteparams [MidiToNoteParams $treble $midi $insnam] 
	set offset [lindex $noteparams 0]			;#	note offset from staff centreline
	set offset [expr $offset * $mscore(noteoffset)]
	if {($treble > 1) && ($midi < 60)} {		;#	instrument has treble-and-bass staves, and note is on bass-stave
			set ycentre [expr $sm + $mscore(doublestaffoffset) + $offset]
	} else {
		set ycentre [expr $sm + $offset]		;#	y params of notehead determined by staff-centre, and offset from centre
	} 
	return $ycentre
}

#--- Look for note-clusters
;#											  SAME	  NO   CLUST
;#											  LINE	CLUST  WITH
;#								pitch%12	   +1	  +2    +3
;#	C	Db	1	(adjacent)		0  + 1
;#	C	D	1	(adjacent)		0  + 2 @
;#	Db	D	2	(coincident)	1  + 1			1
;#	Db	Eb	1	(adjacent)		1  + 2 @
;#	Dd	E	1	(adjacent)		1  + 3 *					1
;#	D	Eb	1	(adjacent)		2  + 1
;#	D	E	1	(adjacent)		2  + 2 @
;#	Eb	E	2	(coincident)	3  + 1			3
;#	Eb	F	1	(adjacent)		3  + 2 @
;#	E	F	1	(adjacent)		4  + 1				  4
;#	F	Gb	1	(adjacent)		5  + 1
;#	F	G	1	(adjacent)		5  + 2 @
;#	Gb	G	2	(coincident)	6  + 1			6
;#	Gb	Ab	1	(adjacent)		6  + 2 @
;#	Gb	A	1	(adjacent)		6  + 3 *					6
;#	G	Ab	1	(adjacent)		7  + 1
;#	G	A	1	(adjacent)		7  + 2 @
;#	Ab	A	2	(coincident)	8  + 1			8	
;#	Ab	Bb	1	(adjacent)		8  + 2 @
;#	Ab	B	1	(adjacent)		8  + 3 *					8
;#	A	Bb	1	(adjacent)		9  + 1
;#	A	B	1	(adjacent)		9  + 2 @
;#	Bb	B	2	(coincident)	10 + 1			10
;#	Bb	C	1	(adjacent)		10 + 2 @
;#	B	C	1	(adjacent)		11 + 1				  11

proc AssessCluster {insnam midinotes} {
	global evv
	set len [llength $midinotes]
	set midinotes [lsort -integer $midinotes]
	if {![ValidCluster $insnam $midinotes]} {
		return -1
	}
	set outval [list 0]	;#	1st note coloured black
	set k 2
	while {$k <= $len} {
		set loindex [expr $k - 2]
		set hiindex [expr $k - 1]
		set lowpitch [lindex $midinotes $loindex]
		set interval [expr [lindex $midinotes $hiindex] - $lowpitch]
		set lowpitch [expr $lowpitch % $evv(MIDI_OCT)]
		set lenout [llength $outval]
		set lastindex [expr $lenout - 1]
		set nextcolor [lindex $outval $lastindex]
		if {$nextcolor < 0} {
			set nextcolor [expr -$nextcolor]
		}
		incr nextcolor	;#	Get next colour
		switch -- $interval {
			1 {
				if {($lowpitch == $evv(MIDILO_Db)) || ($lowpitch == $evv(MIDILO_Eb)) || ($lowpitch == $evv(MIDILO_Gb)) || ($lowpitch == $evv(MIDILO_Ab)) || ($lowpitch == $evv(MIDILO_Bb))} {
					set nextcolor [expr -$nextcolor]				;#	Db/Eb/Gb/Ab/Bb cluster on-same-line with D/E/G/A/B, 1 semitones higher 
																	;#	Mark note offset by -ve value
				} else { 
																	;#	cluster-on-next-line with pitches 1 semitones higher
				}
				lappend outval $nextcolor
			}
			2 {
				if {($lowpitch == $evv(MIDILO_E)) || ($lowpitch == $evv(MIDILO_B))} {		;#	E/B, don't cluster with Gb/Dd, 2 semitones higher
					lappend outval 0
				} else {
					lappend outval $nextcolor						;#	All other pitches, cluster-on-next-line with pitches 2 semitones higher
				}
			}
			3 {
				if {($lowpitch == $evv(MIDILO_Db)) || ($lowpitch == $evv(MIDILO_Gb)) || ($lowpitch == $evv(MIDILO_Ab))} {
					lappend outval $nextcolor						;#	Only Db/Gb/Ab cluster-on-next-line with E/A/B, 3 semitones higher
				} else {
					lappend outval 0
				}
			}
			default {
				lappend outval 0
			}
		}
		incr k
	}
	lappend outval 0	;#	Dummy endvalue
	return $outval
}

#--- Check playability of clusters

proc ValidCluster {insnam midinotes} {
	global evv
	set lo [lindex $midinotes 0]
	set hi [lindex $midinotes end]
	set range [expr $hi - $lo]
	set maxposition -1
	set minposition 10000
	switch -- $insnam {
		"pianoRH" -
		"pianoLH" {
			if {$range > $evv(MIDI_OCT)} {
				Inf "Cluster range ($range semitones) too large for $insnam"
				return 0
			}
		}
		"violin" {
			set open 55
			set n 0
			foreach note $midinotes {
				switch -- $open {
					55 { set openname "G"}
					62 { set openname "D"}
					69 { set openname "A"}
					76 { set openname "E"}
				}
				if {$note < $open} {
					Inf "Cluster note $note not accessible on $openname string of $insnam"
					return 0
				}
				set position [expr $note - ($n * 7)]
				if {$position < $minposition} {
					set minposition $position
				}
				if {$position > $maxposition} {
					set maxposition $position
				}
				incr n
				incr open 7
			}
			if {$maxposition - $minposition > 7} {
				Inf "Cluster has impossible stretch from position $minposition to position $maxposition on $insnam"
				return 0
			}
		}
		"cello" {
			set open 36
			set n 0
			foreach note $midinotes {
				switch -- $open {
					36 { set openname "C"}
					43 { set openname "G"}
					50 { set openname "D"}
					57 { set openname "A"}
				}
				if {$note < $open} {
					Inf "Cluster note $note not accessible on $openname string of $insnam"
					return 0
				}
				set position [expr $note - ($n * 7)]
				if {$position < $minposition} {
					set minposition $position
				}
				if {$position > $maxposition} {
					set maxposition $position
				}
				incr n
				incr open 7
			}
			if {$maxposition - $minposition > 7} {
				Inf "Cluster has impossible stretch from position $minposition to position $maxposition on $insnam"
				return 0
			}
		}
	}
	return 1
}

#--- For any event occuring on an exclusively triplet time-placement...
#--- assemble time/dur/dataindeces in a list 
#--- putting all simultaneous events in same data-structure, keeping data-indeces of first AND LAST event

proc CheckTriplets {insnam data} {
	global evv mscore
	set returnval 1
	set outcnt 0					;#	Counts time-different events
	set datacnt 0					;#	Counts all data

	catch {unset mscore(triplets)}	;#	Stores time, start-event-index and end-event-index of any triplet-placed (possibly chordal) events
	set istriple 0

	foreach {time midi level dur} $data {
		if {$datacnt == 0} {									;#	For 1st event
			if {[TripletOnlyPlacementOrTripletOnlyDur $time $dur]} {			;#	if this is a triplet-placed item, at (N + 1/3) or (N + 2/3) crotchets
				set tripevent [list $time $dur $datacnt $datacnt]	;#	Save time+dur and (start and end) data-index-in-INPUT-array where triplet occurs
				lappend mscore(triplets) $tripevent
				set istriple 1
			}
			incr outcnt
		} elseif {$time != $lasttime} {							;#	(After skipping over coincident events)
			set gap [expr $time - $notend]						;#	Check any rest between end of event, and subsequent event
			if {($gap != 0) && ($gap < $evv(QP_SEMIQ))} {
				Inf "Impossible rest ($gap) between event at $lasttime (duration $lastdur) and event at $time in instrument $insnam"
				return 0
			}
			if {[TripletOnlyPlacementOrTripletOnlyDur $time $dur]} {	;#	Check for next triplet-placed event
				set tripevent [list $time $dur $datacnt $datacnt]
				lappend mscore(triplets) $tripevent
				set istriple 1
			} else {
				set istriple 0
			}
			incr outcnt
		} elseif {$istriple} {									;#	else, with coincident triple-placed events
			set tripevent [lindex $mscore(triplets) end]		;#	Store LAST of the coincident-set in the mscore(triplets) info
			set tripevent [lreplace $tripevent end end $datacnt]
			set mscore(triplets) [lreplace $mscore(triplets) end end $tripevent]
		}
		set lasttime $time
		set lastdur $dur
		set notend [expr $time + $dur]			;#	NB all simultaneous events have same dur (pre-checked)
		incr datacnt 4
	}
	return 1
}

#---- Triplet-ONLY-placed item, at (N + 1/3) or (N + 2/3) crotchets

proc TripletOnlyPlacementOrTripletOnlyDur {time dur} {
	global evv
	if {([expr $time % $evv(QP_TRIPQ)] == 0) && ([expr $time % $evv(QP_SEMIQ)] != 0)} {		;#	Item placed at (N+1/3) or (N+2/3) crotchets
		return 1
	} elseif {([expr $dur % $evv(QP_TRIPQ)] == 0) && ([expr $dur % $evv(QP_SEMIQ)] != 0)} {	;#	Item placed at N but of triplet length
		return 1
	}
	return 0
}

#---- Triplet-placed item, at N, (N + 1/3) or (N + 2/3) crotchets

proc ValidTripletEvent {time dur} {
	global evv
	if {[expr $dur % $evv(QP_TRIPQ)] != 0} {	;#	Duration must be a multiple of quaver-triplet-duration
		return 0
	}
	if {[expr $time % $evv(QP_TRIPQ)] == 0} {	;#	Time placement must be at a multiple of quaver-triplet-duration
		return 1
	}
	return 0
}

##--- Determine the type of triplet bracketing (quaver,crotchet, minim) required
#
#	mscore(triplet) = (time dur startindex endindex)
#		(indices are to data, and point to times of first event and last event occuring at a must-be-a-triplet timing-point)
#	"edi" = event-data-index: points to the start of each group-of-4-vals making up the data (TIME MIDI LOUDNESS DUR)

proc TripletTyping {data insnam} {
	global mscore evv
	set tripouts {}
	catch {unset mscore(triplet_ties)}
	if {![info exists mscore(triplets)]} {
		return 1
	}
	set datalen [llength $data] 

	;#	STARTING WITH THE LONGEST TRIPLET DURATION

	set testdur $evv(QP_TRIPSB)

	;#	TEST TRIPLET-PLACED EVENTS, AND PLACE THEM IN APPROPRIATE triplet-barred GROUPINGS

	while {$testdur >= $evv(QP_TRIPQ)} {

		set nu_tripouts 0

	;#	ESTABLISH APPROPRIATE triplet-TIEBAR FLAGS

		switch -- $testdur {
			32 -
			28 -
			24 -
			20 {
				set tielen $evv(QP_SEMIBREVE)
				set halftielen $evv(QP_MINIM)
			}
			16 {
				set tielen $evv(QP_SEMIBREVE)
				set halftielen $evv(QP_MINIM)
			}
			12 -
			8 {
				set tielen $evv(QP_MINIM)
				set halftielen $evv(QP_CROTCHET)
			}
			4 {
				set tielen $evv(QP_CROTCHET)
			}
		}

		foreach tripevent $mscore(triplets) {


			;#	LOOK FOR TRIPLET EVENTS OF REQUIRED LENGTH (longest first)
			
			set dur  [lindex $tripevent 1]
			if {$dur != $testdur} {
				continue
			}
			set time [lindex $tripevent 0]

			if {![ValidTripletEvent $time $dur]} {
				Inf "Invalidly placed triplet events at $time in instrument $insnam"
				return 0
			}

			set pos [expr $time % $evv(QP_SEMIQ)]				;#	position of event within semiquaver

			set sblokend 0
			set sbloken2 0
			set sblokstt 0

			set curtailable 0

			;#	TEST ALL OTHER EVENTS WHICH WOULD LIE UNDER THE appropriate TRIPLET-TIEBAR

			switch -- $testdur {
				32 {
					switch -- $pos {
						0 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt 0					;#	Start of tripltime-block is at 0										;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend $evv(QP_SEMIBREVE)	;#	End   of tripltime-block is 3 triplet-minims later = semibreve			;#	|X								   --			   |
						}
						1 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt $evv(QP_TRIPM)		;#	Start of tripltime-block is 1 triplet-minim earlier = triplet-minim		;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend $evv(QP_TRIPSB)	;#	End   of tripltime-block is 2 triplet-minims later  = triplet-semibreve	;#	|--	 			  X			  					   |
							set sblokstt $evv(QP_TRIPQ)		;#	Start of tripltime-block is 1 triplet-quav earlier  = triplet-quaver	;#	|0120120120120120 1201201201201201 2012012012012012
							set sblokend 44					;#	End   of tripltime-block is 11 triplet-crotch later = 44				;#	|--	 X			  			  		   --  --  --  |
							set curtailable 1
						}
						2 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt $evv(QP_TRIPC)		;#	Start of tripltime-block is 1 triplet-minim earlier = triplet-crotchet	;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend 40					;#	End   of tripltime-block is 5 triplet-crotchets later  = 40				;#	|--		 X		  							 --	   |

						}
					}
				}
				28 -
				24 {
					switch -- $pos {
						0 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt 0					;#	Start of tripltime-block is at 0										;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend $evv(QP_SEMIBREVE)	;#	End   of tripltime-block is 3 triplet-minims later = semibreve			;#	|X								   --			   |
						}
						1 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt $evv(QP_TRIPM)		;#	Start of tripltime-block is 1 triplet-minim earlier = triplet-minim		;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend $evv(QP_TRIPSB)	;#	End   of tripltime-block is 2 triplet-minims later  = triplet-semibreve	;#	|--	 			  X			  					   |
							set sblokstt $evv(QP_TRIPQ)		;#	Start of tripltime-block is 1 triplet-quav earlier  = triplet-quaver	;#	|0120120120120120 1201201201201201 2012012012012012
							set sblokend 44					;#	End   of tripltime-block is 11 triplet-quavs later	= 44				;#	|--	 X			  			  		   --  --  --  |
							set curtailable 1
						}
						2 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt 20					;#	Start of tripltime-block is 5 triplet-quavers earlier = 20				;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend 28					;#	End   of tripltime-block is 7 triplet-quavers later  =  28				;#	|--		 --		  --  X							   |
							set sblokstt $evv(QP_TRIPC)		;#	Start of tripltime-block is 1 triplet-crotch earlier = triplet-crotchet	;#	|0120120120120120 1201201201201201 2012012012012012
							set sblokend 40					;#	End   of tripltime-block is 5 triplet-crotchets later  = 40				;#	|--		 X		  				   --	  --	   |
							set curtailable 1
						}
					}
				}
				20 {
					switch -- $pos {
						0 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt 0					;#	Start of tripltime-block is at 0										;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend $evv(QP_SEMIBREVE)	;#	End   of tripltime-block is 3 triplet-minims later = semibreve			;#	|X								   --			   |
							set sblokstt 0					;#	Start of tripltime-block is 1 triplet-quav earlier  = triplet-quaver	;#	|0120120120120120 1201201201201201 2012012012012012
							set sblokend $evv(QP_MINIM)		;#	End   of tripltime-block is 3 triplet-crotch later	= minim				;#	|X			  		  --  |
						}
						1 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt $evv(QP_TRIPM)		;#	Start of tripltime-block is 1 triplet-minim earlier = triplet-minim		;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend $evv(QP_TRIPSB)	;#	End   of tripltime-block is 2 triplet-minims later  = triplet-semibreve	;#	|--	 			  X			  					   |
							set sblokstt $evv(QP_TRIPQ)		;#	Start of tripltime-block is 1 triplet-quav earlier  = triplet-quaver	;#	|0120120120120120 1201201201201201 2012012012012012
							set sblokend 44					;#	End   of tripltime-block is 11 triplet-quavs later	= 44				;#	|--	 X			  			  		   --  --  --  |
							set sbloken2 $evv(QP_MINIM)		;#	End   of tripltime-block is 5 triplet-quavs later	= 20				;#	|--	 X			  	      |
							set curtailable 1
						}
						2 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt 20					;#	Start of tripltime-block is 5 triplet-quavers earlier = 20				;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend 28					;#	End   of tripltime-block is 7 triplet-quavers later  =  28				;#	|--		 --		  --  X							   |
							set sblokstt $evv(QP_TRIPC)		;#	Start of tripltime-block is 1 triplet-crotch earlier = triplet-crotchet	;#	|0120120120120120 1201201201201201 2012012012012012
							set sblokend 40					;#	End   of tripltime-block is 5 triplet-crotchets later  = 40				;#	|--		 X		  				   --	  --	   |
							set curtailable 1
						}
					}
				}
				16 {
					switch -- $pos {
						0 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt 0					;#	Start of tripltime-block is at 0										;#	|0120120120120120 1201201201201201 2012012012012012
							set sblokend $evv(QP_MINIM)		;#	End of short tripltime-block is 1 minim later							;#	|X				  -		  |
							set tblokend $evv(QP_SEMIBREVE)	;#	End   of tripltime-block is 3 triplet-minims later = semibreve			;#	|X				  --			   --			   |
						}
						1 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt $evv(QP_TRIPM)		;#	Start of tripltime-block is 1 triplet-minim earlier = triplet-minim		;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend $evv(QP_TRIPSB)	;#	End   of tripltime-block is 2 triplet-minims later  = triplet-semibreve	;#	|--				  X				   --			   |
							set sblokstt $evv(QP_TRIPQ)		;#	Start of tripltime-block is 1 triplet-quaver earlier= triplet-quaver	;#	|0120120120120120 1201201201201201 2012012012012012
							set sblokend 44					;#	End   of tripltime-block is 11 triplet-quavs later	= 44				;#	|--	 X			  	  --  --	   --			   |
							set sbloken2 20					;#	End   of tripltime-block is 5 triplet-quavs later	= 20				;#	|--	 X			  	  --  |
							set curtailable 1
						}
						2 {																												;#	 0123012301230123,0123012301230123,0123012301230123
							set tblokstt $evv(QP_TRIPSB)	;#	Start of tripltime-block is 2 triplet-minims earlier = triplet-semibreve;#	|0120120120120120 1201201201201201 2012012012012012
							set tblokend $evv(QP_TRIPM)		;#	End   of tripltime-block is 1 triplet-minims later   = triplet-minim	;#	|--				  --			   X			   |
							set sblokstt $evv(QP_TRIPC)		;#	Start of short tripltime-block 1 triplcrotch earlier = triplet-crotchet ;#							  |		   X			   |
						}
					}
				}
				12 {
					switch -- $pos {
						1 {																												;#	 0123012301230123,01230123
							set tblokstt $evv(QP_TRIPQ)		;#	Start of tripltime-block is 1 triplet-quav earlier = triplet-quav		;#	|0120120120120120 12012012
							set tblokend 20					;#	End   of tripltime-block is 5 triplet-quav later  = 20					;#	|--	 X			  --	  |
						}
						2 {																												;#	 0123012301230123,01230123
							set tblokstt $evv(QP_TRIPC)		;#	Start of tripltime-block is 1 triplet-crotch earlier = triplet-crotchet	;#	|0120120120120120 12012012
							set tblokend $evv(QP_TRIPM)		;#	End   of tripltime-block is 1 triplet-minim later   = triplet-minim		;#	|--		 X			  --  |
						}
					}
				}
				8 {
					switch -- $pos {
						0 {																												;#	 01230123,01230123,01230123
							set tblokstt 0					;#	Start of tripltime-block is at 0										;#	|01201201 20120120 12012012
							set tblokend $evv(QP_MINIM)		;#	End   of tripltime-block is 3 triplet-crotchets later = minim			;#	|X		  --	   --	   |
							set sblokend $evv(QP_CROTCHET)	;#	End of short tripltime-block is 1 crotchet later						;#	|X		  -	  |
						}
						2 {																												;#	 01230123,01230123,01230123
							set tblokstt $evv(QP_TRIPC)		;#	Start of tripltime-block is 1 triplet-crotch earlier = triplet-crotch	;#	|01201201 20120120 12012012
							set tblokend $evv(QP_TRIPM)		;#	End   of tripltime-block is 2 triplet-crotchs later  = triplet-minim	;#	|--		  X		   --	   | 
						}
						1 {																												;#	 01230123,01230123,01230123
							set tblokstt $evv(QP_TRIPM)		;#	Start of tripltime-block is 2 triplet-crotch earlier = triplet-minim	;#	|01201201 20120120 12012012
							set tblokend $evv(QP_TRIPC)		;#	End   of tripltime-block is 1 triplet-crotch later   = triplet-crotchet	;#	|--		  --	   X	   |
							set sblokstt $evv(QP_TRIPQ)		;#	Start of short tripltime-block is 1 triplquav earlier = triplet-quaver	;#	 			  |	   X	   |
						}
					}
				}
				4 {
					switch -- $pos {
						0 {																												;#	 0123,0123,0123
							set tblokstt 0					;#	Start of tripltime-block is at 0										;#	|0120 1201 2012
							set tblokend $evv(QP_CROTCHET)	;#	End of tripltime-block is 3 triplet-quavers later = crotchet			;#	|X	  --   --  |
						}
						1 {																												;#	 0123,0123,0123
							set tblokstt $evv(QP_TRIPQ)		;#	Start of tripltime-block is 1 triplet-quav earlier = triplet-quaver		;#	|0120 1201 2012
							set tblokend $evv(QP_TRIPC)		;#	End   of tripltime-block is 2 triplet-quav later  = triplet-crotchet	;#	|--	  X	   --  |
						}
						2 {																												;#	 0123,0123,0123
							set tblokstt $evv(QP_TRIPC)		;#	Start of tripltime-block is 2 triplet-quavs earlier = triplet-crotchet	;#	|0120 1201 2012
							set tblokend $evv(QP_TRIPQ)		;#	End   of tripltime-block is 1 triplet-quavs later   = triplet-quaver	;#	|--	  --   X   |
						}
					}
				}
			}

			;#	CHECK TRIPLET EVENT NOT ALREADY CONTAINED IN AN EXISTING new-TRIPLET-GROUPINGS

			set this_edi [lindex $tripevent 2]				;#	data index of FIRST (possibly coincident) note in this triplet-timed event
			set gotit 0
			foreach tripout $tripouts {
				set estart [lindex $tripout 2]
				set eend   [lindex $tripout 3]
				if {($this_edi >= $estart) && ($this_edi <= $eend)} {
					set gotit
					break
				}
			}
			if {$gotit} {									;#	If triplet event already in an existing tie, go to next event
				continue
			}

			;#	Check that any following events do not form a triplet grouping at 1/2 the scale (e.g. minim->crotchet ETC)
			;#		m->c : m->q->(qr) : m->(qr)->q : m->q->q	 OR		c->q : c->(qr)

			set special_shortener 0
			if {$sblokend > 0} {
				if {$sbloken2 > 0} {							;#	IF two possibilities of curtailment (1 at end, other at start) test the 2nd option
					set dur_to_test [expr $testdur/2]			;#	setting length of triplet-brace to half the length of current testdur 
					set this_tielen $halftielen
					set endtime [expr $time + $sbloken2]
					set stttime [expr $time - $sblokstt]
					set this_edi [lindex $tripevent 3]
					set final_edi [expr $this_edi + 4]
					set is_short 1								;#	Assume its short
					if {$final_edi < $datalen} {
						set nexttime [lindex $data $final_edi]
						if {$nexttime < $endtime} {				;#	impossible in |(q)m+q|
							set is_short 0						;#	so go on to test the alternative shortening option
						}										;#	if end of data reached, also no point in having longer brace
					} 
					if {$is_short}  {
						set special_shortener 1					;#	Flag that we have already tested the LATER events
						set thistielen $this_tielen
						set final_edi $this_edi					;#	Only one event is special-shorteners
					}
				}
				if {!$special_shortener} {								;#	In all other cases
					if {$curtailable} {									;#	if "curtailable" the "sblokend" refers to a different placement of block start in the COMPLETE testdur							
						set dur_to_test $testdur						;#	Length of triplet unit = length of current testdur 
						set this_tielen $tielen							;#	Length of tie = full length of tie
	
					} else {											;#	OTHERWISE "sblokend" defines a block HALF the length of the principal block		
						set dur_to_test [expr $testdur/2]				;#	so Length of triplet unit half the length of current testdur 
						set this_tielen $halftielen						;#	and length of tie = HALF
					}
					set endtime [expr $time + $sblokend]				;#	End of time-block containing triplet-of-half-testlen
					set stttime [expr $time - $sblokstt]
					set this_edi [lindex $tripevent 3]					;#	event number of LAST (possibly coincident) note in this triplet-timed event
					set final_edi [expr $this_edi + 4]					;#	Get next event
					catch {unset nextdur}
					if {$final_edi < $datalen} {						;#	but quit if end of data is reached
						set nexttime [lindex $data $final_edi]
						if {$nexttime < $endtime} {						;#	If another event exists inside the triplet, check its duration
							set nextdur [lindex  $data [expr $final_edi + $evv(MSC_DUR)]]
						}
					}													;#	If we have a grouping with a SHORTER triplet-event of 1/2 the length, Save it
					if {[info exists nextdur]} {						;#	m->c	m->q->(qr)		m->(qr)->q			m->q->q	  OR	c->q
						if {![ValidTripletEvent $nexttime $nextdur]} {
							Inf "Incompatible triplet events at $time and $nexttime in instrument $insnam AAA"
							return 0
						}
						if {$nextdur == $dur_to_test} {					;#	m->c  OR  c->q
							set tripout [list $stttime $this_tielen $this_edi $final_edi]
							lappend tripouts $tripout					;#	Valid shortblock grouping : KEEP
							set nu_tripouts 1
							continue
						} elseif {$nextdur < $dur_to_test} {			;#	min->q->q :					mi->(qr)->q : m ->q->(qr)  
							unset nextdur								;#	Will find valid nextdur   : Will drop out at endtime
							catch {unset fffinal_edi}									
							set fffinal_edi [expr $final_edi + 4]		;#	Get next event
							if {$fffinal_edi < $datalen} {
								set nexttime [lindex $data $fffinal_edi]
								if {$nexttime < $endtime} {
									set nextdur [lindex  $data [expr $fffinal_edi + $evv(MSC_DUR)]]
								}
							}
							if {[info exists nextdur]} {				;#	m->q->q ONLY possible

								if {![ValidTripletEvent $nexttime $nextdur] || ($nextdur != $evv(QP_TRIPQ))} {
									Inf "Incompatible triplet events at $time and $nexttime in instrument $insnam BBB"
									return 0
								} else {								;#	m->q->q
									set final_edi $fffinal_edi			;#	Tie-bar takes in 3rd event of group
								}
							}											;#	ELSE m->q->(qr) : OR  m->(qr)->q
							if {$curtailable} {							;#	Check any preceding events for possible inclusion in the triplet-brace
								set testpriors [TripletBracePriorsOK $time $sblokstt $insnam $tripevent $data]
								if {[llength $testpriors] > 1} {
									set this_edi [lindex $testpriors 1]	;#	Include prior event
									set testpriors [lindex $testpriors 0]
								}
								if {$testpriors < 0} {					;#	Invalid triplet placement prior to this event
									return 0
								}
								if {$testpriors == 1} {					;#	Valid shortblock grouping : KEEP
									set tripout [list $stttime $this_tielen $this_edi $final_edi]
									lappend tripouts $tripout
									set nu_tripouts 1
									continue
								}
							} else {

								set tripout [list $stttime $this_tielen $this_edi $final_edi]
								lappend tripouts $tripout
								set nu_tripouts 1
								continue
							}
						}
					} else {											;#	No following events	(end of data), same logic applied
						if {$sblokstt == 0} {							;#	m->(cr)	c->(qr)				
							set tripout [list $stttime $this_tielen $this_edi $this_edi]
							lappend tripouts $tripout
							set nu_tripouts 1
							continue
						} elseif {$curtailable} {
							set testpriors [TripletBracePriorsOK $time $sblokstt $insnam $tripevent $data]
							if {[llength $testpriors] > 1} {
								set this_edi [lindex $testpriors 1]		;#	Include prior event
								set testpriors [lindex $testpriors 0]
							}
							if {$testpriors < 0} {						;#	Invalid triplet placement prior to this event
								return 0
							}
							if {$testpriors == 1} {						;#	Valid grouping : KEEP
								set tripout [list $stttime $this_tielen $this_edi $final_edi]
								lappend tripouts $tripout
								set nu_tripouts 1
								continue
							}
						}													
					}
				}
			}		;#	If we reach here, not a short-block but could still be valid grouping, but starting earlier

			;#	If we haven't already checked the events-that-follow (as we have with the special_shortener)
			;#	Check that any following events that would be under the triplet-grouping would be at valid (triplet) timings

			if {!$special_shortener} {

				set endtime [expr $time + $tblokend]			;#	End of time-block containing triplet-testlen
				set this_edi [lindex $tripevent 3]				;#	event number of LAST (possibly coincident) note in this triplet-timed event
				set next_edi [expr $this_edi + 4]				;#	Get next event
				while {$next_edi < $datalen} {					;#	but quit if end of data is reached
					set nexttime [lindex $data $next_edi]
					if {$nexttime >= $endtime} {				;#	Once entire span has been searched, quit loop
						break
					}											;#	Check that all other events within triplet-span are triplet-placement compatible
					set nextdur [lindex  $data [expr $next_edi + $evv(MSC_DUR)]]
					if {![ValidTripletEvent $nexttime $nextdur]} {
						Inf "Incompatible triplet events at $time and $nexttime in instrument $insnam CCC"
						return 0
					}
					set this_edi $next_edi
					set next_edi [expr $next_edi + 4]
				}
				set final_edi $this_edi								;#	Remember index of last event within triplet-spanned events
			}

			;#	Check that any preceding events that would be under the triplet-grouping would be at valid (triplet) timings

			if {$tblokstt > 0} {
#HEREH
				set semibr_short 0
				set shortevent 0
				if {$sblokstt > 0} {							;#	If this could be a short-long grouping
					set shortstart [expr $time - $sblokstt]		;#	set start of short-long grouping
					set shortevtest 1							;#	Set flag to test for it
				} else {
					set shortevtest 0							;#	else, turn off test flag	
				}
				if {$special_shortener} {
					set starttime [expr $time - $sblokstt]
				} else {
					set starttime [expr $time - $tblokstt]		;#	Start of time-block containing triplet-minim
				}
				set this_edi [lindex $tripevent 2]				;#	event number of FIRST (possibly coincident) note in this triplet-timed event
				set last_edi [expr $this_edi - 4]				;#	Get previous event
				while {$last_edi >= 0} {						;#	but quit if start of data is reached
					set lasttime [lindex $data $last_edi]
					if {$lasttime < $starttime} {				;#	Once entire semibreve span has been searched, quit loop
						break
					}											;#	Check that all other events within triplet-span are triplet-placement compatible
					set lastdur [lindex  $data [expr $last_edi + $evv(MSC_DUR)]]
																;#	If not yet checked for possible short-long grouping, and we've stepped back before start of that grouping
					if {$shortevtest && ($lasttime < $shortstart)} {	
						set shortevtest 0						;#	We're doing the test, so turn off the testing flag, so test is not repeated
						if {[expr $lasttime + $lastdur] <= $shortstart} {
							set shortevent 1					;#	If event before start of any short-long grouping does not persist into that grouping
							if {$curtailable} {
								set semibr_short 1				;#	With triplet-semibr we MIGHT have a have a QUAVER-semibr-grouping
								set semibr_short_this_edi $this_edi
							} else {
								break							;#	otherwise we definitely have a short-long event
							}
						} else {
							set shortevent 0
						}
					}
					if {![ValidTripletEvent $lasttime $lastdur]} {
						if {$semibr_short} {					;#	If we've established there's a potential QUAVER-semibr-grouping: this non-triplet event is outside that grouping
							break								;#	So QUAVER-semibr-grouping is valid, but larger grouping isn't: so quit the search, retaining short-event flag
						}										;#	Otherwise, we're still under a triplet bracket, and have an invalid event
						Inf "Incompatible triplet events at $lasttime and $time in instrument $insnam DDD"
						return 0
					}
					set this_edi $last_edi
					set last_edi [expr $last_edi - 4]
				}
				if {$shortevtest} {								;#	If this could be a short-long grouping, but this has not yet been tested
					if {$last_edi < 0} {						
						if {$curtailable} {
							if {$time == 4} {					;#	If event is a sembr, and it occurs after a quav-trip-rest, then we have the quav-sembibr shortevent
								set shortevent 1
							}
						} else {								;#	Otherwise
							set shortevent 1					;#	If there's no previous event, then this IS a short-long grouping
						}
					} else {									;#	Else
						set lastdur [lindex  $data [expr $last_edi + $evv(MSC_DUR)]]
						if {$curtailable} {						;#	If this could be a QUAVER-semibr-grouping
							if {[expr $lasttime + $lastdur] <= $starttime} {		;#	If instead it were a a MINIM-semibr-grouping
								set shortevent 0				;#	If the event before that minim-semibr doesn't cross into the minim-semibr-grouping
																;#	We can have a minim-semibr grouping ... not a quaver-semibr grouping, so abandon the "shortevent" flag	
							} else {							
								set semibr_short 1				;#	But if it does cross-in, forced to have a quav-semibr-grouping
							}								
						} else {								;# if the duration of the previous event doesn't cross the start of the short-long grouping
							if {[expr $lasttime + $lastdur] <= $shortstart} {
								set shortevent 1				;#	then this is a short grouping
							}		
						}

					}
				}
				if {$shortevent == 1} {
					set thistime $shortstart
					if {$semibr_short} {						;#	This is a quav-sembr event
						set thistielen $tielen
						set this_edi $semibr_short_this_edi		;#	First event in it is this one!!!
					} else {
						set thistielen $halftielen
					}
				} else {
					set thistime $starttime						;#	Time of start of triplet-tie-block
					set thistielen $tielen
				}
				set first_edi $this_edi							;#	event number of FIRST (possibly coincident) note within this triplet-timed event
			} else {
																;#	(or, event starts at crotchet start)
				set thistime $time								;#	Time = time of event
				set first_edi [lindex $tripevent 2]				;#	event number of FIRST (possibly coincident) note within this triplet-timed event
				set thistielen $tielen

			}

			;#	Establish triplet-bar

			if {$special_shortener} {
				set thistielen $this_tielen
			}
			set tripout [list $thistime $thistielen $first_edi $final_edi]	;#	Remember start-time of triplet-span, tielen & startevent-index and endevent-index
			lappend tripouts $tripout
			set nu_tripouts 1
		}

		;#	AFTER TESTING ALL TRIPLET-EVENTS OF GIVEN LENGTH, EDIT LIST OF input-TRIPLET-EVENTS TO REMOVE THOSE ALREADY PUT INTO TIE-GROUPS
		
		if {$nu_tripouts} {										;#	ONLY If new groupings found, at this test-length
			catch {unset nutrips}								
			set m 0
			set len [llength $mscore(triplets)]					;#	Go through all listed triplet events
			while {$m < $len} {									
				set thistrip [lindex $mscore(triplets) $m]
				set this_edi [lindex $thistrip 2]	
				set gotit 0
				foreach tripout $tripouts {						;#	Compare the event with already group-tied sets
					set tripoutstt [lindex $tripout 2]			;#	and if is now in a group-tied set, 
					set tripoutend [lindex $tripout 3]			;#	forget it
					if {($this_edi >= $tripoutstt) && ($this_edi <= $tripoutend)} {
						set gotit 1
						break
					}
				}
				if {!$gotit} {									;#	but if not, remember it
					lappend nutrips $thistrip
				}
				incr m
			}
			if {[info exists nutrips]} {						;#	If there are still triplet-events to process
				set mscore(triplets) $nutrips					;#	make (only) these the list of input-events to test
			} else {											;#	But
				break											;#	If there are no events left to test, finish
			}
		}
		set nu_tripouts 0

		set testdur [expr $testdur - $evv(QP_TRIPQ)]	;#	Step down the possible triplet durations
	}

	;#	RETAIN JUST THE TIME AND TYPE OF THE TRIPLET-TIES

	if {[llength $tripouts] <= 0} {
		Inf "Problem in logic of triplet grouping"
		return 0
	}
	catch {unset mscore(triplet_ties)} 	
	foreach tripout $tripouts {
		set tripout [lrange $tripout 0 1]
		lappend mscore(triplet_ties) $tripout
	}
	return 1
}

#------	Order score lines rationally

proc ForceOrchestralOrder {} {
	global mscore
	foreach insnam $mscore(insnams) {
		switch -- $insnam {
			"flute"	   { lappend oorder 1}
			"clarinet" { lappend oorder 2}
			"trumpet"  { lappend oorder 3}
			"violin"   { lappend oorder 4}
			"cello"	   { lappend oorder 5}
			"pianoRH"  { lappend oorder 6}
			"pianoLH"  { lappend oorder 7}
			default {
				Inf "Unknown instrument name in  \"ForceOrchestralOrder\""
				return 0
			}
		}
	}
	set len [llength $oorder]
	set len_less_one [expr $len - 1]
	set n 0 
	while {$n < $len_less_one} {
		set insnam_n [lindex $mscore(insnams) $n]
		set line_n   [lindex $mscore(score) $n]
		set oo_n	 [lindex $oorder $n]
		set m $n
		incr m
		while {$m < $len} {
			set insnam_m [lindex $mscore(insnams) $m]
			set line_m   [lindex $mscore(score) $m]
			set oo_m	 [lindex $oorder $m]
			if {$oo_m < $oo_n} {
				set mscore(insnams) [lreplace $mscore(insnams) $n $n $insnam_m]
				set mscore(insnams) [lreplace $mscore(insnams) $m $m $insnam_n]
				set insnam_n $insnam_m
				set mscore(score) [lreplace $mscore(score) $n $n $line_m]
				set mscore(score) [lreplace $mscore(score) $m $m $line_n]
				set line_n $line_m
				set oorder [lreplace $oorder $n $n $oo_m]
				set oorder [lreplace $oorder $m $m $oo_n]
				set oo_n $oo_m
			}
			incr m
		}
		incr n
	}
	return 1
}

#--- Write in any triplet ties

proc DoTripletTies {y above} {
	global mscore evv
	foreach tie $mscore(triplet_ties) {
		set starttime [lindex $tie 0]
		set len  [lindex $tie 1]
		set endtime [expr $starttime + $len]
		set midtime [expr ($starttime + $endtime)/2]
		set x0 [expr ($starttime + 1) * $mscore(gridstep)]
		set x0 [expr $x0 + $mscore(notes_start)]
		set x1 [expr ($endtime - 1)   * $mscore(gridstep)]
		set x1 [expr $x1 + $mscore(notes_start)]
		set xt [expr $midtime * $mscore(gridstep)] 
		set xt [expr $xt + $mscore(notes_start)]
		if {$above} {
			set ydn [expr $y - 1]
			set yup [expr $y - 6]
			set yt  [expr $y - 2]
			set coords [list $x0 $ydn $x0 $yup $x1 $yup $x1 $ydn]
		} else {
			set yup [expr $y + 1]
			set ydn [expr $y + 6]
			set coords [list $x0 $yup $x0 $ydn $x1 $ydn $x1 $yup]
		}
		$mscore(can) create line $coords -width 2 -tag "triplet" -fill $evv(POINT) 
		$mscore(can) create text $xt $y -text "3" -tag "triplet" -fill $evv(POINT)
	}
}

#--- If time-marker is inside triplet tie, avoid it overwriting the "3" text

proc TimeMarkerWithinATripletTie {x} {
	global mscore evv
	if {[info exists mscore(triplet_ties)]} {
		foreach tie $mscore(triplet_ties) {
			set len [lindex $tie 1]
			if {$len > $evv(QP_CROTCHET)} {
				set starttime [lindex $tie 0]
				set endtime [expr $starttime + $len]
				set midtime [expr ($starttime + $endtime)/2]
				set xt [expr $midtime * $mscore(gridstep)] 
				set xt [expr $xt + $mscore(notes_start)]
				if {[expr abs($xt - $x) < 5]} {
					return 1
				}
			}
		}
	}
	return 0
}

#--- Does a timed-event fall in a triplet grouping

proc IsStartUnderTriplet {time} {
	global mscore
	if {![info exists mscore(triplet_ties)]} {
		return 0
	}
	foreach tie $mscore(triplet_ties) {
		set starttime [lindex $tie 0]
		set len  [lindex $tie 1]
		set endtime [expr $starttime + $len]
		if {($time >= $starttime) && ($time < $endtime)} {
			set mscore(tripletlimit) $endtime
			set mscore(tripletstart) $starttime
			return 1
		}
	}
	return 0
}

#--- Does a timed-event end inside a triplet grouping

proc IsEndWithinTriplet {time} {
	global mscore
	if {![info exists mscore(triplet_ties)]} {
		return 0
	}
	foreach tie $mscore(triplet_ties) {
		set starttime [lindex $tie 0]
		set len  [lindex $tie 1]
		set endtime [expr $starttime + $len]
		if {($time > $starttime) && ($time < $endtime)} {
			set mscore(tripletstart) $starttime
			return 1
		}
	}
	return 0
}

#---- Check events prior to a grouping		|--x---------
#----	which might also be interpreted as  |-------x---

proc TripletBracePriorsOK {time sblokstt insnam tripevent data} {
	global evv
	set starttime [expr $time - $sblokstt]
	set this_edi [lindex $tripevent 2]
	set last_edi [expr $this_edi - 4]
	while {$last_edi >= 0} {
		set lasttime [lindex $data $last_edi]
		if {$lasttime < $starttime} {
			break
		}
		set lastdur [lindex  $data [expr $last_edi + $evv(MSC_DUR)]]
		if {$lasttime < $starttime} {	
			if {[expr $lasttime + $lastdur] <= $starttime} {
				return 1			;#	Valid grouping with |--x---------- orientation
			}
			if {![ValidTripletEvent $lasttime $lastdur]} {
				Inf "Incompatible triplet events at $lasttime and $time in instrument $insnam EEE"
				return -1			;#	Invalid grouping
			} else {
				return 0			;# Could be valid grouping with |----------x-- orientation
			}
		} elseif {$lasttime == $starttime} {
			return [list 1 $last_edi]
		}
		set this_edi $last_edi
		set last_edi [expr $last_edi - 4]
	}
	if {$last_edi < 0} {						
		return 1
	}			
	set lastdur [lindex  $data [expr $last_edi + $evv(MSC_DUR)]]
	if {[expr $lasttime + $lastdur] < $starttime} {
		return 1
	} elseif {$lasttime == $starttime} {
		return [list 1 $last_edi]
	}
	if {![ValidTripletEvent $lasttime $lastdur]} {
		Inf "Incompatible triplet events at $lasttime and $time in instrument $insnam DDD"
		return -1
	} else {
		return 0
	}
}

#--- Play individual instrumental part from Multisynth score

proc DarwinPlayStave {ins action typ} {
	global mscore evv darplay CDPidrun prg_dun prg_aborted simple_program_messages 
	if {![info exists mscore(infnam)] || ![file exists $mscore(infnam)] || ![info exists mscore(score)] || ![info exists mscore(insnams)]} {
		Inf "Problem 1 to $action individual $ins line in score [file rootname [file tail $fnam]]"
		return 0
	}
	set fnam $mscore(infnam)
	set tempfnam $evv(DFLT_TMPFNAME)
	switch -- $ins {
		"flute"		{ append tempfnam 1 }
		"clarinet"	{ append tempfnam 2 }
		"trumpet"	{ append tempfnam 3 }
		"violin"	{ append tempfnam 4 }
		"cello"		{ append tempfnam 5 }
		"piano"		{ append tempfnam 6 }
	}
	set tempsnd $tempfnam 
	append tempsnd $evv(SNDFILE_EXT)
	append tempfnam $evv(TEXT_EXT)

	if {$action == "create"} {
		if {![info exists darplay(mm)]} {
			Inf "No MM set"
			return 0
		} elseif {![IsNumeric $darplay(mm)] || ![regexp {^[0-9]+$} $darplay(mm)] || ($darplay(mm) < $mscore(min_mm)) || ($darplay(mm) > $mscore(max_mm))} {
			Inf "Invalid MM set"
			return 0
		}
		set ispiano 0
		if {$ins == "piano"} {
			set ispiano 1
			set ins "pianoRH"
		}
		foreach line $mscore(score) insnam $mscore(insnams) {
			if {[string match $insnam $ins]} {
				set line [concat $insnam $line]
				lappend outlines $line
				break
			}
		}
		if {$ispiano} {
			set ins "pianoLH"
			foreach line $mscore(score) insnam $mscore(insnams) {
				if {[string match $insnam $ins]} {
					set line [concat $insnam $line]
					lappend outlines $line
					break
				}
			}
			set ins "piano"
		}
		if {![info exists outlines]} {
			Inf "Problem 2 creating individual $ins line in score [file rootname [file tail $fnam]]"
			return 0
		}
		if [catch {open $tempfnam "w"} zit] {
			Inf "Cannot open temporary score file, to create sound of $ins line in score [file rootname [file tail $fnam]]" 
			return 0
		}
		foreach line $outlines {
			puts $zit $line
		}
		close $zit
		Block "Creating sound for instrument $ins"
		set cmd [file join $evv(CDPROGRAM_DIR) multisynth]
		lappend cmd synth $tempsnd $tempfnam $darplay(mm) -o2
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "FAILED TO RUN SYNTHESIS OF INSTRUMENT $ins"
			catch {unset CDPidrun}
			UnBlock
			return 0
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Failed to synthesize instrument $ins"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			UnBlock
			return 0
		}
		if {![file exists $tempsnd]} {
			set msg "Failed to create the output file for instrument $ins"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			UnBlock
			return 0
		}
		UnBlock
		if {$typ == "scoresee"} {
			.darwin.i.$ins.create config -text Play -bg $evv(EMPH) -command "DarwinPlayStave $ins play scoresee"
		} else {
			.darplay.4.$ins.create config -text Play -bg $evv(EMPH) -command "DarwinPlayStave $ins play scoreplay"
		}
		return 1
	} else {
		if {![file exists $tempsnd]} {
			Inf "Sound not yet created"
			return 0
		}
		PlaySndfile $tempsnd 0
		return 1
	}
}

proc IncrDarwinMM {down} {
	global darplay mscore
	if {$down} {
		if {$darplay(mm) > $mscore(min_mm)} {
			incr darplay(mm) -1
		}
	} else {
		if {$darplay(mm) < $mscore(max_mm)} {
			incr darplay(mm)
		}
	}
}
