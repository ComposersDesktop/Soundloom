#
# SOUND LOOM RELEASE mac version 17.0.4
#

#################
#	SLIDERS		#
#################

#------ Make a slider object, linked to entry box

proc MakeScale {gcnt pcnt type} {
	global prmgrd ssss actvhi actvlo p_cnt evv
	set scale_len $evv(SCALELEN)
	incr scale_len $evv(SLIDERSIZE)
	set w [canvas $prmgrd.s$gcnt -height $evv(SLIDERSIZE) -width $scale_len -highlightthickness 0]
	$w create rect 0 0 $scale_len $evv(SLIDERSIZE) -fill [option get . troughColor {}] -tag slide
	$w create rect 0 0 $evv(SLIDERSIZE) $evv(SLIDERSIZE) -fill $evv(PBAR_DONECOLOR) -width 2 -tag slider
	set ssss($pcnt) 0
	$w bind slider <Button-1> "ScaleMark %W %x $pcnt"
	$w bind slider <Button1-Motion> "ScaleDrag %W %x $pcnt $gcnt $type"
	$w bind slide <ButtonRelease-1> "ScaleChange %W %x $pcnt $gcnt $type"
	return $w
}

#------ Note position of slider whne mouse is first pressed

proc ScaleMark {w x pcnt} {
	global ssss smark
	set smark($pcnt) $ssss($pcnt)
}

#------ Move slider on display, and reset val in entrybox

proc ScaleDrag {w x pcnt gcnt type} {
	global ssss smark prm evv
	set x1 $smark($pcnt)
	set smark($pcnt) $x
	set dx [expr $x - $x1]
	if {$ssss($pcnt) + $dx < 0} {
		set dx -$ssss($pcnt)
	} elseif {$ssss($pcnt) + $dx > $evv(SCALELEN)} {
		set dx [expr $evv(SCALELEN) - $ssss($pcnt)]
	}
	$w move slider $dx 0
	incr ssss($pcnt) $dx
	switch -- $type {
		"log" {
			set prm($pcnt) [SetLogValFromSlider $pcnt]
		} 
		"plog" {
			set prm($pcnt) [SetLogValFromSlider $pcnt]
			SetPitchValFromSlider $gcnt $pcnt
		} 
		"powtwo" {
			set prm($pcnt) [SetPowtwoValFromSlider $pcnt]
		} 
		default	{
			set prm($pcnt) [SetValFromSlider $pcnt]
		}
	}
}

#------ Move slider on display, and reset val in entrybox

proc ScaleChange {w x pcnt gcnt type} {
	global prm ssss evv
	if {$x > $evv(SCALELEN)} {
		set x $evv(SCALELEN)
	}
	set dx [expr $x - $ssss($pcnt)]
	$w move slider $dx 0
	set ssss($pcnt) $x
	switch -- $type {
		"log" {
			set prm($pcnt) [SetLogValFromSlider $pcnt]
		} 
		"plog" {
			set prm($pcnt) [SetLogValFromSlider $pcnt]
			SetPitchValFromSlider $gcnt $pcnt
		} 
		"powtwo" {
			set prm($pcnt) [SetPowtwoValFromSlider $pcnt]
		} 
		default	{
			set prm($pcnt) [SetValFromSlider $pcnt]
		}
	}
}

#------ Set scale value from entrybox

proc SetScale {pcnt type} {
	global ssss smark scl prm actvlo activeloglo prange powtwo_convertor evv
	if {($type != "powtwo") && ($prange($pcnt) <= 0.0)} {
		return
	}
	if {[info exists scl($pcnt)] && [IsNumeric $prm($pcnt)]} {
		set val [StripLeadingZeros $prm($pcnt)]
		if {[string length $val] <= 0} {
			return
		}
		set prm($pcnt) $val
		switch -- $type {
			"log" {
				set val [expr log($prm($pcnt))]
				set val [expr $val - $activeloglo($pcnt)]
				set	val [expr double($val) / $prange($pcnt)]
			}
			"powtwo" {
				set val [expr log($prm($pcnt))]
				set	val [expr double($val) * $powtwo_convertor($pcnt)]
			}
			default {
				set val [expr $prm($pcnt) - $actvlo($pcnt)]
				set	val [expr double($val) / $prange($pcnt)]
			}
		}
		set val [expr round($val * $evv(SCALELEN))]
		$scl($pcnt) move slider [expr $val - $ssss($pcnt)] 0
		set ssss($pcnt) $val
		set smark($pcnt) $val
	}
}

#------ Set scale value from entrybox

proc ResetScale {pcnt type} {
	global ssss smark scl prm actvlo activeloglo prange powtwo_convertor evv

	if {($type != "powtwo") && ($prange($pcnt) <= 0.0)} {
		return
	}
	if {[info exists scl($pcnt)] && [IsNumeric $prm($pcnt)]} {
		set val [StripLeadingZeros $prm($pcnt)]
		if {[string length $val] <= 0} {
			return
		}
		set prm($pcnt) $val
		switch -- $type {
			"log" {
				set val [expr log($prm($pcnt))]
				set val [expr $val - $activeloglo($pcnt)]
				set	val [expr double($val) / $prange($pcnt)]
			}
			"powtwo" {
				set val [expr log($prm($pcnt))]
				set	val [expr double($val) * $powtwo_convertor($pcnt)]
			}
			default {
				set val [expr ($prm($pcnt) - $actvlo($pcnt))]
				set	val [expr double($val) / $prange($pcnt)]
			}
		}
		set val [expr round($val * $evv(SCALELEN))]
		set x1 [expr $val + $evv(SLIDERSIZE)]

		$scl($pcnt) coords slider $val 0 $x1 $evv(SLIDERSIZE)
		set ssss($pcnt) $val
		set smark($pcnt) $val
	}
}

########################################################################################
# CONVERSIONS BETWEEN SLIDER, ENTRY-BOX & PITCH-NOTATION DISPLAYS, USED BY GADGETS	   #
########################################################################################

#------ Returns value of variable, given a range & a slider position (0-1)

proc SetValFromSlider {pcnt} {
	global actvlo prange prtype isint ssss actvhi evv

	set val [expr double($ssss($pcnt)) / $evv(SCALELEN)]
	set val [expr ($val * $prange($pcnt)) + $actvlo($pcnt)]
	if {$isint($pcnt)} {
		return [expr round($val)]
	}
	switch -- $prtype($pcnt) {
		1 {
			set val [expr round($val)]
		}
		0 {
		}
		default {
			set val [expr (round($val * $prtype($pcnt))/double($prtype($pcnt)))]
		}
	}
	if {$val > $actvhi($pcnt)} {
		set val $actvhi($pcnt)
	} elseif {$val < $actvlo($pcnt)} {
		set val $actvlo($pcnt)
	}
	return $val
}

#------ Returns value of variable, given a range & a logarithmic slider position (0-1)

proc SetLogValFromSlider {pcnt} {
	global activeloglo prange isint ssss evv
	set val [expr double($ssss($pcnt)) / $evv(SCALELEN)]
	set val [expr ($val * $prange($pcnt)) + $activeloglo($pcnt)]
	set val [expr exp($val)]				   				;# antilog
	if {$isint($pcnt)} {
		return [expr round($val)]
	}
	return $val
}

#------ Returns value of variable, given a range & a slider position (0-1)

proc SetPowtwoValFromSlider {pcnt} {
	global isint ssss powtwo_range actvhi evv
	set val [expr double($ssss($pcnt)) / $evv(SCALELEN)]
	set val [expr round($val * $powtwo_range($pcnt))]
	incr val
	set val [expr pow(2,$val)]
	set val [expr int($val)]
	if {$val > $actvhi($pcnt)} {
		set val [expr int(round($actvhi($pcnt)))]
	}
	return $val
}

#------ Set value in pitch display, in response to slider position

proc SetPitchValFromSlider {gcnt pcnt} {
	global activeloglo activeloghi pitchdisplay prmgrd prange ssss evv
	set val [expr double($ssss($pcnt)) / $evv(SCALELEN)]
	set val [expr ($val * $prange($pcnt)) + $activeloglo($pcnt)]
	# HERE WE HAVE THE LOG OF THE FRQ
	set pitchdisplay($pcnt) [SetPitchDisplay $val $gcnt $pcnt]
	ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
}

#------ Set pitch display from value in entrybox

proc SetPitchValFromEntrybox {gcnt pcnt} {
	global prm pitchdisplay prmgrd
	set val [string trim $prm($pcnt)]
	if {![regexp {([1-9])+} $val]} {		;#	Must contain 1 or more digits > 0
		set pitchdisplay($pcnt) ""
		return
	}										;#	Must be of form 123 || 123. || 123.123 || .123
	if {![regexp {^([0-9]*)(\.?)([0-9]*)$} $val]} {
		set pitchdisplay($pcnt)	""
		return
	}
	set val [expr log($val)]
	set pitchdisplay($pcnt) [SetPitchDisplay $val $gcnt $pcnt]
	ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
}

#------ Set pitch display from LOGe of frequency

proc SetPitchDisplay {val gcnt pcnt} {							;# Oct interval = log(2)val - log(2)LOWC
	global evv in_midival prmgrd
	set interval [expr $val - $evv(LOGLOWCFRQ)]					;# 				= log(e)val - log(e)LOWC
																;#				  ----------------------
																;#						log(e)2
																;#
																;# Semitone interval = ditto * 12
	set interval [expr $interval * $evv(12OVERLOG2)]			;#
	set in_midival($pcnt) [expr round($interval)]				;#	= (log(e)val - log(e)LOWC) *   12
	set pitch_deviance [expr abs($in_midival($pcnt) - $interval)]	;#							 -------
	if {$pitch_deviance > .2} {									;#				 				 log(e)2
		$prmgrd.pi$gcnt config -bg $evv(DISABLE_COLOR)
	} else {
		$prmgrd.pi$gcnt config -bg $evv(OFF_COLOR)
	}
	set thispitch [expr round($in_midival($pcnt) % $evv(SEMITONES_PER_OCTAVE))] 

	set oct [expr int($in_midival($pcnt) / $evv(SEMITONES_PER_OCTAVE))]
	incr oct -5
																;#	NB: Octave 0 starts at Middle C
	switch  -exact -- $thispitch {				
		0	{return "C  $oct"}
		1	{return "C# $oct"}
		2	{return "D  $oct"}
		3	{return "Eb $oct"}
		4	{return "E  $oct"}
		5	{return "F  $oct"}
		6	{return "F# $oct"}
		7	{return "G  $oct"}
		8	{return "G# $oct"}
		9	{return "A  $oct"}	
		10	{return "Bb $oct"}
		11	{return "B  $oct"}	
	}
}

#------ Force displayed frequency val to exact pitch value.

proc FixPitch {pcnt gcnt} {
	global prm prmgrd in_midival evv
	switch -exact -- $in_midival($pcnt) {			 
		0	{ set prm($pcnt) "8.175799" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		1	{ set prm($pcnt) "8.661957" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		2	{ set prm($pcnt) "9.177024" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		3	{ set prm($pcnt) "9.722718" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		4	{ set prm($pcnt) "10.300861" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		5	{ set prm($pcnt) "10.913382" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		6	{ set prm($pcnt) "11.562326" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		7	{ set prm($pcnt) "12.249857" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		8	{ set prm($pcnt) "12.978272" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		9	{ set prm($pcnt) "13.750000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		10	{ set prm($pcnt) "14.567618" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		11	{ set prm($pcnt) "15.433853" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		12	{ set prm($pcnt) "16.351598" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		13	{ set prm($pcnt) "17.323914" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		14	{ set prm($pcnt) "18.354048" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		15	{ set prm($pcnt) "19.445436" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		16	{ set prm($pcnt) "20.601722" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		17	{ set prm($pcnt) "21.826764" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		18	{ set prm($pcnt) "23.124651" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		19	{ set prm($pcnt) "24.499715" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		20	{ set prm($pcnt) "25.956544" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		21	{ set prm($pcnt) "27.500000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		22	{ set prm($pcnt) "29.135235" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		23	{ set prm($pcnt) "30.867706" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		24	{ set prm($pcnt) "32.703196" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		25	{ set prm($pcnt) "34.647829" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		26	{ set prm($pcnt) "36.708096" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		27	{ set prm($pcnt) "38.890873" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		28	{ set prm($pcnt) "41.203445" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		29	{ set prm($pcnt) "43.653529" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		30	{ set prm($pcnt) "46.249303" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		31	{ set prm($pcnt) "48.999429" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		32	{ set prm($pcnt) "51.913087" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		33	{ set prm($pcnt) "55.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		34	{ set prm($pcnt) "58.270470" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		35	{ set prm($pcnt) "61.735413" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		36	{ set prm($pcnt) "65.406391" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		37	{ set prm($pcnt) "69.295658" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		38	{ set prm($pcnt) "73.416192" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		39	{ set prm($pcnt) "77.781746" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		40	{ set prm($pcnt) "82.406889" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		41	{ set prm($pcnt) "87.307058" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		42	{ set prm($pcnt) "92.498606" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		43	{ set prm($pcnt) "97.998859" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		44	{ set prm($pcnt) "103.826174" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		45	{ set prm($pcnt) "110.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		46	{ set prm($pcnt) "116.540940" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		47	{ set prm($pcnt) "123.470825" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		48	{ set prm($pcnt) "130.812783" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		49	{ set prm($pcnt) "138.591315" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		50	{ set prm($pcnt) "146.832384" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		51	{ set prm($pcnt) "155.563492" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		52	{ set prm($pcnt) "164.813778" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		53	{ set prm($pcnt) "174.614116" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		54	{ set prm($pcnt) "184.997211" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		55	{ set prm($pcnt) "195.997718" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		56	{ set prm($pcnt) "207.652349" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		57	{ set prm($pcnt) "220.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		58	{ set prm($pcnt) "233.081881" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		59	{ set prm($pcnt) "246.941651" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		60	{ set prm($pcnt) "261.625565" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		61	{ set prm($pcnt) "277.182631" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		62	{ set prm($pcnt) "293.664768" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		63	{ set prm($pcnt) "311.126984" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		64	{ set prm($pcnt) "329.627557" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		65	{ set prm($pcnt) "349.228231" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		66	{ set prm($pcnt) "369.994423" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		67	{ set prm($pcnt) "391.995436" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		68	{ set prm($pcnt) "415.304698" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		69	{ set prm($pcnt) "440.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		70	{ set prm($pcnt) "466.163762" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		71	{ set prm($pcnt) "493.883301" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		72	{ set prm($pcnt) "523.251131" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		73	{ set prm($pcnt) "554.365262" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		74	{ set prm($pcnt) "587.329536" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		75	{ set prm($pcnt) "622.253967" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		76	{ set prm($pcnt) "659.255114" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		77	{ set prm($pcnt) "698.456463" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		78	{ set prm($pcnt) "739.988845" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		79	{ set prm($pcnt) "783.990872" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		80	{ set prm($pcnt) "830.609395" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		81	{ set prm($pcnt) "880.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		82	{ set prm($pcnt) "932.327523" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		83	{ set prm($pcnt) "987.766603" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		84	{ set prm($pcnt) "1046.502261" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		85	{ set prm($pcnt) "1108.730524" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		86	{ set prm($pcnt) "1174.659072" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		87	{ set prm($pcnt) "1244.507935" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		88	{ set prm($pcnt) "1318.510228" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		89	{ set prm($pcnt) "1396.912926" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		90	{ set prm($pcnt) "1479.977691" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		91	{ set prm($pcnt) "1567.981744" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		92	{ set prm($pcnt) "1661.218790" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		93	{ set prm($pcnt) "1760.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		94	{ set prm($pcnt) "1864.655046" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		95	{ set prm($pcnt) "1975.533205" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		96	{ set prm($pcnt) "2093.004522" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		97	{ set prm($pcnt) "2217.461048" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		98	{ set prm($pcnt) "2349.318143" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		99	{ set prm($pcnt) "2489.015870" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		100	{ set prm($pcnt) "2637.020455" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		101	{ set prm($pcnt) "2793.825851" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		102	{ set prm($pcnt) "2959.955382" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		103	{ set prm($pcnt) "3135.963488" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		104	{ set prm($pcnt) "3322.437581" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		105	{ set prm($pcnt) "3520.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		106	{ set prm($pcnt) "3729.310092" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		107	{ set prm($pcnt) "3951.066410" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		108	{ set prm($pcnt) "4186.009045" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		109	{ set prm($pcnt) "4434.922096" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		110	{ set prm($pcnt) "4698.636287" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		111	{ set prm($pcnt) "4978.031740" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		112	{ set prm($pcnt) "5274.040911" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		113	{ set prm($pcnt) "5587.651703" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		114	{ set prm($pcnt) "5919.910763" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		115	{ set prm($pcnt) "6271.926976" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		116	{ set prm($pcnt) "6644.875161" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		117	{ set prm($pcnt) "7040.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		118	{ set prm($pcnt) "7458.620184" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		119	{ set prm($pcnt) "7902.132820" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		120	{ set prm($pcnt) "8372.018090" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		121	{ set prm($pcnt) "8869.844191" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		122	{ set prm($pcnt) "9397.272573" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		123	{ set prm($pcnt) "9956.063479" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		124	{ set prm($pcnt) "10548.081821" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		125	{ set prm($pcnt) "11175.303406" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		126	{ set prm($pcnt) "11839.821527" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		127	{ set prm($pcnt) "12543.853951" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		128	{ set prm($pcnt) "13289.750323" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		129	{ set prm($pcnt) "14080.000000" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		130	{ set prm($pcnt) "14917.240369" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		131	{ set prm($pcnt) "15804.265640" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		132	{ set prm($pcnt) "16744.036179" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		133	{ set prm($pcnt) "17739.688383" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		134	{ set prm($pcnt) "18794.545147" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		135	{ set prm($pcnt) "19912.126958" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		136	{ set prm($pcnt) "21096.163642" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		137	{ set prm($pcnt) "22350.606812" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		138	{ set prm($pcnt) "23679.643054" ; $prmgrd.pi$gcnt config -bg $evv(ON_COLOR)}
		default { set prm($pcnt) "----"}
	}
}

###############################################################
# CHECK VALIDITY OF VALS OR STRINGS ENTERED AT ENTRY-BOX	  #
###############################################################

#------ Check validity of entered parameter.

proc ThisParamOK {gcnt pcnt e} {
	global prm pprg parname prmgrd dfault gdg_typeflag canhavefiles actvhi evv
	set gadgetno $gcnt
	incr gadgetno

	CheckCurrentPatchDisplay
	set par_name [StripName	$parname($gcnt)]

	set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) $par_name $gdg_typeflag($gcnt) $pcnt $gcnt]
	ForceVal $e $prm($pcnt)
	if {[string length $prm($pcnt)] <= 0} {
		return 0
	}

	switch -regexp -- $gdg_typeflag($gcnt) \
		^$evv(FILE_OR_VAL)$ {
			if [IsNumeric $prm($pcnt)] {
				if {![IsInRange $pcnt $gcnt]} {
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
				}
				SetScale $pcnt linear
			} else {
#JUNE 30 UC-LC FIX
				set prm($pcnt) [string tolower $prm($pcnt)]
				if {![file isfile $prm($pcnt)]} {
					Inf "File $prm($pcnt) is not in the working directory"
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
					SetScale $pcnt linear
					return 1
				}						 ;#	File data is not checkable for range
			}					  	
		}			     \
		^$evv(SWITCHED)$ {
			if [IsNumeric $prm($pcnt)] {
				if {![IsInRange $pcnt $gcnt]} {
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
				}
				SetScale $pcnt linear
			} else {
				Inf "Numeric values only for parameter $par_name"
				set prm($pcnt) $dfault($pcnt)
				InsertParamValueInEntryDisplay $e $pcnt
				SetScale $pcnt linear
			}
		}			     \
		^$evv(LINEAR)$ {
			if [IsNumeric $prm($pcnt)] {
				if {![IsInRange $pcnt $gcnt]} {
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
				}
				SetScale $pcnt linear
			} elseif {$canhavefiles($pcnt)} {			 		;#	Could be a file
#JUNE 30 UC-LC FIX
				set prm($pcnt) [string tolower $prm($pcnt)]
				if {![file isfile $prm($pcnt)]} {
					Inf "File $prm($pcnt) is not in the working directory"
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
					SetScale $pcnt linear
					return 1
				} elseif {[FilevalIsInRange $pcnt $gcnt] == 0} {
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
					SetScale $pcnt linear
					return 1
				}
			} else {
				Inf "Numeric values only for parameter $par_name"
				set prm($pcnt) $dfault($pcnt)
				InsertParamValueInEntryDisplay $e $pcnt
				SetScale $pcnt linear
			}
		}			     \
		^$evv(LOG)$     - \
		^$evv(PLOG)$ {
			if [IsNumeric $prm($pcnt)] {
				if {![IsInRange $pcnt $gcnt]} {
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
				}
				SetScale $pcnt log
			} elseif {$canhavefiles($pcnt)} {
#JUNE 30 UC-LC FIX
				set prm($pcnt) [string tolower $prm($pcnt)]
				if {![file isfile $prm($pcnt)]} {
					Inf "File $prm($pcnt) is not in the working directory"
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
					SetScale $pcnt log
				} elseif {[FilevalIsInRange $pcnt $gcnt] == 0} {		
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
					SetScale $pcnt log
				}
			} else {
				Inf "Numeric values only for parameter $par_name"
				set prm($pcnt) $dfault($pcnt)
				InsertParamValueInEntryDisplay $e $pcnt
				SetScale $pcnt log
			}
		}				     \
		^$evv(NUMERIC)$ {
			if [IsNumeric $prm($pcnt)] {
				if {![IsInRange $pcnt $gcnt]} {
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
				}
				SetScale $pcnt linear
			} else {
				Inf "Numeric values only for parameter $par_name"
				set prm($pcnt) $dfault($pcnt)
				InsertParamValueInEntryDisplay $e $pcnt
				SetScale $pcnt linear
			}
		}				   \
		^$evv(LOGNUMERIC)$ {
			if [IsNumeric $prm($pcnt)] {
				if {![IsInRange $pcnt $gcnt]} {
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
				}
				SetScale $pcnt log
			} else {
				Inf "Numeric values only for parameter $par_name"
				set prm($pcnt) $dfault($pcnt)
				InsertParamValueInEntryDisplay $e $pcnt
				SetScale $pcnt log
			}
		}				   \
		^$evv(POWTWO)$ {
			if [IsNumeric $prm($pcnt)] {
				set prm($pcnt) [expr int($prm($pcnt))]
				set x [expr int($actvhi($pcnt))]
				set p2OK 0
				while {$x > 1} {
					if {$x == $prm($pcnt)} {
						set p2OK 1
						break
					}
					set x [expr int($x / 2)]
				}
				if {!$p2OK} {
					set prm($pcnt) [expr int(round(log($prm($pcnt)) * $evv(ONE_OVER_LN2)))]  
					set prm($pcnt) [expr int(pow(2,$prm($pcnt)))]  
					InsertParamValueInEntryDisplay $e $pcnt
					SetScale $pcnt powtwo
				}
				if {![IsInRange $pcnt $gcnt]} {
					set prm($pcnt) $dfault($pcnt)
					InsertParamValueInEntryDisplay $e $pcnt
				}
				InsertParamValueInEntryDisplay $e $pcnt
				SetScale $pcnt powtwo
			} else {
				Inf "Numeric values, powers of 2 only, for parameter $par_name"
				set prm($pcnt) $dfault($pcnt)
				InsertParamValueInEntryDisplay $e $pcnt
				SetScale $pcnt powtwo
			}
		}				   \
		^$evv(FILENAME)$ {
#JUNE 30 UC-LC FIX
			set prm($pcnt) [string tolower $prm($pcnt)]
			if {![file isfile $prm($pcnt)]} { 
				Inf "File $prm($pcnt) is not in the working directory"
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		}				  \
		^$evv(VOWELS)$ {
			set prm($pcnt) [string tolower $prm($pcnt)]
			if {![ValidVowelName $prm($pcnt)]} {
				if {![file isfile $prm($pcnt)] || [file isdirectory $prm($pcnt)]} { 
					Inf "File $prm($pcnt) is not a vowel-name or a file in the working directory"
					set prm($pcnt) ""
					InsertParamValueInEntryDisplay $e $pcnt
				}
			}
		}				  \
		^$evv(GENERICNAME)$ {
#JUNE 30 UC-LC FIX
			set prm($pcnt) [string tolower $prm($pcnt)]
			if {![ValidCDPRootname $prm($pcnt)]} { 
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		}				  \
		^$evv(STRING_A)$ {
			if {![ValidStringA $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		}				  \
		^$evv(STRING_B)$ {
			if {![ValidStringB $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		}				  \
		^$evv(STRING_C)$ {
			if {![ValidStringC $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		}				  \
		^$evv(STRING_D)$ {
			if {![ValidStringD $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		}				  \
		^$evv(STRING_E)$ {
			if {![ValidStringE $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		}

	return 1
}

#------ No ins-prm can be used to vary number of outfiles of a process

proc ParamIsInsCompatible {gcnt} {
	global pprg mmod evv

 	set mmode $mmod
	incr mmode -1

	switch -regexp -- $pprg \
		^$evv(HOUSE_COPY)$ {
			if {$mmode == $evv(DUPL)} {
				if {$gcnt == 0} {					;#	NO. OF COPIES
					return 0
				}
			}
		} \
		^$evv(MIXINBETWEEN)$ {
			if {$gcnt == 1} {						;#	"FILES BETWEEN"	or "MIXING RATIOS"
				return 0
			}
		} \
		^$evv(EDIT_EXCISEMANY)$ {
			if {$gcnt == 0} {						;#	"START & END TIMES FOR EXCISIONS"
				return 0
			}
		} \
		^$evv(RANDCHUNKS)$ {
			if {$gcnt == 0} {						;#	"NUMBER OF CHUNKS"
				return 0
			}
		}
	
	return 1
}
