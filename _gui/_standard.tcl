#
# SOUND LOOM RELEASE mac version 17.0.4
#

#####################
# STANDARD FEATURES #
#####################

#----- Display standard features of required notedata file, in the text edit window

proc StandardTextureFeatures {} {
	global infcnt textfilenamep mmod pprg evv standardk

	set mmode $mmod
	incr mmode -1
	set textfilenamep "notedata"
	set line "60"
	set i 1
	while {$i < $infcnt} {
		append line " 60"
		incr i
	}
	if {(($pprg == $evv(SIMPLE_TEX)) || ($pprg == $evv(TEX_MCHAN))) && ($mmode == $evv(TEX_NEUTRAL))} {
		.maketextp.k.t delete 1.0 end
	} else {
		.maketextp.k.t delete 1.0 2.0
	}
	set k 1
	.maketextp.k.t insert $k.0 "$line\n"
	incr k
	switch -regexp -- $pprg \
		^$evv(SIMPLE_TEX)$ - \
		^$evv(TEX_MCHAN)$ - \
		^$evv(GROUPS)$ {
			if {$mmode != $evv(TEX_NEUTRAL)} {
				if {$mmode == $evv(TEX_HF) || $mmode == $evv(TEX_HS)} {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, in form...)\n"
				} else {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, changing in time where field changes, in form...)\n"
				}
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "#N    (N = count of notes which will follow)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "(Time      Ins-no.    Midi-pitch        Midi-loudness         Duration)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "  0.0          1                60.0                  127.0                  1.0\n"
				.maketextp.k.t insert $k.0 $line
				incr k
			}
		} \
		^$evv(TIMED)$ - \
		^$evv(TGROUPS)$ {
			set line "(Notes defining EVENT ENTRY TIMES, in the form...)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "#N    (N = count of notes in timeset)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Time      Ins-no.    Midi-pitch        Midi-loudness         Duration)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
				set line "  0.0          1                60.0                  127.0                  1.0\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			if {$mmode != $evv(TEX_NEUTRAL)} {
				if {$mmode == $evv(TEX_HF) || $mmode == $evv(TEX_HS)} {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, in form...)\n"
				} else {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, changing in time where field changes, in form...)\n"
				}
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "#N    (N = count of notes which will follow)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "  0.0          1                60.0                  127.0                  1.0\n"
				.maketextp.k.t insert $k.0 $line
				incr k
			}
		} \
		^$evv(DECORATED)$ 	- \
		^$evv(PREDECOR)$ 	- \
		^$evv(POSTDECOR)$ 	{
			set line "(Notes defining MELODIC LINE to be decorated, in the form.....)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "#N    (N = count of notes in melodic line)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Time      Ins-no.    Midi-pitch        Midi-loudness         Duration)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "  0.0          1                60.0                  127.0                  1.0\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			if {$mmode != $evv(TEX_NEUTRAL)} {
				if {$mmode == $evv(TEX_HF) || $mmode == $evv(TEX_HS)} {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, in form...)\n"
				} else {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, changing in time where field changes, in form...)\n"
				}
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "#N    (N = count of notes which will follow)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "  0.0          1                60.0                  127.0                  1.0\n"
				.maketextp.k.t insert $k.0 $line
				incr k
			}
		} \
		^$evv(ORNATE)$ 		- \
		^$evv(PREORNATE)$ 	- \
		^$evv(POSTORNATE)$ 	{
			set line "(Notes defining MELODIC LINE to be ornamented, in the form....)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "#N    (N = count of notes which will follow)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Time      Ins-no.    Midi-pitch        Midi-loudness         Duration)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "  0.0          1                60.0                  127.0                  1.0\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			if {$mmode != $evv(TEX_NEUTRAL)} {
				if {$mmode == $evv(TEX_HF) || $mmode == $evv(TEX_HS)} {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, in form...)\n"
				} else {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, changing in time where field changes, in form...)\n"
				}
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "#N    (N = count of notes which will follow)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "  0.0          1                60.0                  127.0                  1.0\n"
				.maketextp.k.t insert $k.0 $line
				incr k
			}
			set line "(Notes for AT LEAST ONE ORNAMENT, in the form)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "#N    (N = count of notes in 1st ornament, which will follow)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "  0.0          1                60.0                  127.0                  1.0\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Followed by similar #N and note-sets defining any further ornaments.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
		} \
		^$evv(MOTIFS)$ 		- \
		^$evv(MOTIFSIN)$ {
			if {$mmode != $evv(TEX_NEUTRAL)} {
				if {$mmode == $evv(TEX_HF) || $mmode == $evv(TEX_HS)} {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, in form...)\n"
				} else {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, changing in time where field changes, in form...)\n"
				}
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "#N    (N = count of notes which will follow)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "(Time      Ins-no.    Midi-pitch        Midi-loudness         Duration)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "  0.0          1                60.0                  127.0                  1.0\n"
				.maketextp.k.t insert $k.0 $line
				incr k
			}
			set line "(Notes for AT LEAST ONE MOTIF, in the form)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "#N    (N = count of notes which will follow)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			if {$mmode == $evv(TEX_NEUTRAL)} {
				set line "(Time      Ins-no.    Midi-pitch        Midi-loudness         Duration)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
			}
			set line "  0.0          1                60.0                  127.0                  1.0\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Followed by similar #N and note-sets defining any further motifs.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
		} \
		^$evv(TMOTIFS)$ 	- \
		^$evv(TMOTIFSIN)$ {
			set line "(Notes defining EVENT ENTRY TIMES, in the form....)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "#N    (N = count of notes in timeset)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Time      Ins-no.    Midi-pitch        Midi-loudness         Duration)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "  0.0          1                60.0                  127.0                  1.0\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			if {$mmode != $evv(TEX_NEUTRAL)} {
				if {$mmode == $evv(TEX_HF) || $mmode == $evv(TEX_HS)} {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, in form...)\n"
				} else {
					set line "(Notes defining PITCHES IN HARMONIC FIELD or SET, changing in time where field changes, in form...)\n"
				}
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "#N    (N = count of notes which will follow)\n"
				.maketextp.k.t insert $k.0 $line
				incr k
				set line "  0.0          1                60.0                  127.0                  1.0\n"
				.maketextp.k.t insert $k.0 $line
				incr k
			}
			set line "(Notes for AT LEAST ONE MOTIF, in the form......)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "#N    (N = count of notes which will follow)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "  0.0          1                60.0                  127.0                  1.0\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Followed by similar #N and note-sets defining any further motifs.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
		}

	if {!(($pprg == $evv(SIMPLE_TEX)) || ($pprg == $evv(TEX_MCHAN))) && ($mmode == $evv(TEX_NEUTRAL))} {
		set line "(WARNING: Edit this file before attempting to use it. Removing all lines in brackets.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
	}
#	.maketextp.b.stan config -state disabled
	set standardk $k
	if {!(($pprg == $evv(SIMPLE_TEX)) || ($pprg == $evv(TEX_MCHAN))) && ($mmode == $evv(TEX_NEUTRAL))} {
		.maketextp.b.stan config -text "Delete Features" -command "UnsetStandardSpecialFeatures 1"
	}
}

#----- Display standard features of required special data file, in the text edit window

proc StandardSpecialFeatures {} {
	global pprg mmod evv standardk chlist pa

	set mmode $mmod
	incr mmode -1
	set k 1
	switch -regexp -- $pprg \
		^$evv(GREQ)$ {
			if {$mmode == $evv(GR_ONEBAND)} {
				set line "(bandwidth    frq1   \[frq2    frq3 .......\])\n"
			} else {
				set line "(bandwidth1    frq1    \[bw2    frq2    bw3    frq3 .......\])\n"
			}
		} \
		^$evv(P_INVERT)$ {
			set line "(source-interval	    inverted-interval)\n"
		} \
		^$evv(SUPPRESS)$ {
			set line "(timeslot-start	    timeslot-end)\n"
		} \
		^$evv(P_SYNTH)$ {
			set line "(relative amplitude of harmonics, in turn: value range 0-1)\n"
		} \
		^$evv(VFILT)$ - \
		^$evv(P_VOWELS)$ {
			set line "(time-vowel pairs)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(vowels can be --- ee, i, ai, aii, e, a, ar, o, or, oa, u, uu, ui, oo)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(plus : x for short neutral vowel : xx long neutral vowel)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(plus : n for 'n' : m for 'm' : r for 'r' : th for 'th'\[vowel only\])\n"
		} \
		^$evv(PULSER)$ - \
		^$evv(PULSER2)$ {
			set line "(time and a list of any of the (channel)numbers 1-8)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(channel numbers cannot be repeated within any single line)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(number of channels listed can vary from line to line)\n"
		} \
		^$evv(P_GEN)$ {
			set line "(time-midipitch pairs, where times start at zero and increase.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Midipitch can be A,B,C,D,E,F,or G, possibly followed by '#'\[sharp\] or 'b'\[flat\])\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(followed by numeric value of octave (range -5 to +5), where 0 means octave starting at middle C)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(with NO SPACES in all of this......)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(OR a (numeric) MIDI note value between 0 and 131)\n"
		} \
		^$evv(MIX_ON_GRID)$ {
			set line "(list of times where sounds start in mix, on separate lines)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(OR list, with times-to-be-used marked by 'x' \[before time, with no space\])\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Number of times, or of marked times, must match number of infiles)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Comments, e.g. grid numbering, permitted at end of a line ONLY)\n"
		} \
		^$evv(AUTOMIX)$ {
			set line "(time plus a relative level for each infile e.g.  \"0  .5  .5  .7\")\n"
		} \
		^$evv(MIXBALANCE)$ {
			set line "(time plus relative level of file 1)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Control-t : converts (grouped) samplecnt -> Time)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Control-a : converts pairs of gpd-sampcnts in file 2 to balance func swapping between Files 1 & 2)\n"
		} \
		^$evv(EDIT_CUTMANY)$ - \
		^$evv(MANY_ZCUTS)$ {
			set line "(pair of times for each segment to be cut)\n"
		} \
		^$evv(STACK)$ {
			set line "(one semitone transposition for each item in the stack)\n"
		} \
		^$evv(SYLLABS)$ {
			set line "(one time for start of each conjunct syllable, plus endtime of last syllable)\n"
		} \
		^$evv(JOIN_SEQ)$ {
			set line "(one number for each sound in output sequence: numbers (1 upwards) correspond to input files)\n"
		} \
		^$evv(JOIN_SEQDYN)$ {
			set line "(a list of pairs of numbers)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(one number for each sound in output sequence: numbers (1 upwards) correspond to input files)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(paired with one relative-loudness value for that pattern item)\n"
		} \
		^$evv(P_INSERT)$ {
			set line "(GROUP-sampcnt in source SOUND \[eg count pairs in stereo\])\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			if {$mmode == 0} {
				set line "(starttime	endtime)\n"
			} else {
				set line "(startsample	endsample)\n"
			}
		} \
		^$evv(SPLIT)$ {
			set line "(lofrq    hifrq    4-bits   \[amp1    amp2   \[(+)transpos\]\])\n"
		} \
		^$evv(FLTBANKU)$ - \
		^$evv(FLTITER)$ {
			if {$mmode == $evv(FLT_HZ)} {
				set line "(frq    amplitude)\n"
			} else {
				set line "(midi-pitch    amplitude)\n"
			}
		} \
		^$evv(P_SINSERT)$ {
			set line "(pairs of times, between which silence is to occur)\n"
		} \
		^$evv(FLTBANKV)$ {
			if {$mmode == $evv(FLT_HZ)} {
				set line "(time   frq1   amplitude1  \[frq2   amp2   frq3   amp3 ......\])\n"
			} else {
				set line "(time   midipitch1   amplitude1  \[midi2   amp2   midi3   amp3 ......\])\n"
			}
		} \
		^$evv(SYNFILT)$ {
			if {$mmode == 0} {
				set line "(time   midipitch)\n"
			} else {
				set line "(time   midipitch1   amplitude1  \[midi2   amp2   midi3   amp3 ......\])\n"
			}
		} \
		^$evv(FLTBANKV2)$ {
			if {$mmode == $evv(FLT_HZ)} {
				set line "(time   frq1   amplitude1  \[frq2   amp2   frq3   amp3 ......\] for pitches)\n"
			} else {
				set line "(time   midipitch1   amplitude1  \[midi2   amp2   midi3   amp3 ......\] for pitches)\n"
			}
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Follow all pitch lines with line starting with '#')\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(time   partialno(possibly fractional)  amp1  \[partialno2   amp2   partialno3   amp3 ......\] for partials)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(where partialno is a multiplier of the fundamental frequencies, given as pitches above.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(BOTH sets of datamust start at time ZERO)\n"
		} \
		^$evv(SYNTHESIZER)$ {
			set line "(time   partial-no  level \[partial-no2   level2   partial-no3   level3 ......\])\n"
		} \
		^$evv(PULSER3)$ {
			if {$mmode == 0} {
				set line "(partial-no  level)\n"
			} else {
				set line "(time   partial-no  level \[partial-no2   level2   partial-no3   level3 ......\])\n"
			}
		} \
		^$evv(DEL_PERM2)$ {
			set line "(transpos  time-fraction   transpos   time-fraction .........)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(transpos in semitones; time-fractions must sum to 1.0)\n"
		} \
		^$evv(DISTORT_HRM)$ {
			set line "(harmonic-no    amplitude)\n"
		} \
		^$evv(DISTORT_PULSED)$ {
			set line "(time    amplitude(0-1) ---- time will be scaled to duration of each impulse)\n"
		} \
		^$evv(ENVSYN)$ - \
		^$evv(DISTORT_ENV)$ {
			set line "(time : val \[0-1\] pairs, defining an envelope.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(time is in arbitrary units, and will be scaled to the duration of each envelope imposed.)\n"
		} \
		^$evv(SEQUENCER)$ {
			set line "(event-time    semitone-tranposition    level(0-1))\n"
		} \
		^$evv(SEQUENCER2)$ {
			set line "(Otherwise lines have 5 values for each output event, and these are....)\n"
			.maketextp.k.t insert 1.0 $line
			incr k
			set line "(First line has a MIDI pitch value for each input soundfile.)\n"
			.maketextp.k.t insert 1.0 $line
			incr k
			set line "(sound-number    event-time    MIDI-pitch    level(0-1)    duration)\n"
		} \
		^$evv(GRAIN_REMOTIF)$ {
			set line "(semitone-tranposition   duration-multiplier)\n"
		} \
		^$evv(FREEZE)$ {
			set line "(List of times-in-file where spectrum is frozen, or unfrozen.)\n"
			.maketextp.k.t insert 1.0 $line
			incr k
			set line "(If time value preceeded by 'a' : use this window as freezewindow for AFTER this time.)\n"
			.maketextp.k.t insert 1.0 $line
			incr k
			set line "(If time value preceeded by 'b' : use this window as freezewindow for BEFORE this time.)\n"
			.maketextp.k.t insert 1.0 $line
			incr k
			set line "(Otherwise time(s) are end OR start of freezes thus established.)\n"
		} \
		^$evv(FREEZE2)$ {
			set line "(time of spectrum hold : duration of hold)\n"
		} \
		^$evv(ENV_CREATE)$ {
			set line "(if 'e' used before level val, envelope rises or falls exponentially TO that val)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(time        \[e\]level                           : level range \[0-1\])\n"
		} \
		^$evv(DEL_PERM)$ {
			set line "(LINE 1: a set of midi vals to transpose to, from MIDI 60)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(LINE 2: transpos  time-fraction   transpos   time-fraction .........)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(transpos in semitones; time-fractions must sum to 1.0)\n"
		} \
		^$evv(BATCH_EXPAND)$ {
			set line "(list of values of one of the parameters of the batchfile)\n"
		} \
		^$evv(TWIXT)$ {
			set line "(list of times which partition both input files into segments.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(If you choose 'time segments in sequence')\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(These are the times at which outsound switches from one infile to other.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(and first time in list is start time in first file.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(In other modes, sequence of segments taken from each file is permuted or randomised)\n"
		} \
		^$evv(SPHINX)$ {
			set line "(N columns of values (all of same length) which are times in the N input files.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(These times partition the files into segments.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(If you choose 'time segments in sequence')\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Output takes 1st segment from file1 (col1), then 1st seg from file2, then file3 etc.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Once first segment obtained from every file, takes 2nd segment from File1, File2 etc.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(In other modes, sequence of segments taken from each file is permuted or randomised)\n"
		} \
		^$evv(MULTI_SYN)$ {
			set line "(List of MIDI values, possibly fractional, possibly -ve for very low pitch)\n"
		} \
		^$evv(GRAIN_GET)$ - \
		^$evv(GREV)$ {
			set line "(List of times \[secs\] at which to position grains)\n"
		} \
		^$evv(CLICK)$ {
			set line "(          lineno        tempo           meter      bar-count         accent-pattern (optional)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(e.g.  1                1=87.33        4:4          10                                             )\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(or..   2                1.5=144       6:8          22                   1..10.               )\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(or..   3                1=144to220 6:8          22                                                      \[an accelerando])\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(or..   4                GP                1              3.2)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(The following uses of Function Keys does not operate on the MAC)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Control-1 inserts Next Line Number at end of current list)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(and Control-r    will renumber all lines correctly)\n"
			.maketextp.k.t insert $k.0 $line
		} \
		^$evv(MCHANPAN)$ {
			switch -- $mmode {
				0 {
					set line "(time   panposition   direction)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(panposition range : 0 to outchans)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(                     vals below 1 lie between channels outchan and 1)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(direction: 1 clockwise   -1 anticlockwise   0 direct)\n"
				}
				1 {
					set line "(list of outchan numbers to cycle around)\n"
				}
				6 {
					set line "(time + listing of all outchans in any order)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(OR time + outchan zeros - forces sound \"to centre\")\n"
				}
			}
		} \
		^$evv(FRAME)$ {
			switch -- $mmode {
				0 -
				1 {
					set line "(time + listing of all outchans in any order)\n"
				}
				2 {
					set line "(list of all outchan numbers in any order)\n"
				}
				6 {
					set line "(list the numbers of the outchans you wish to modify)\n"
				}
			}
		} \
		^$evv(FLUTTER)$ {
			set line "(each line has list of any of the outchans)\n"
		} \
		^$evv(MCHSTEREO)$ {
			set line "(list outchannel centre \[integer\] for each stereo input file)\n"
		} \
		^$evv(TAPDELAY)$ - \
		^$evv(RMVERB)$ {
			set line "(          time         amp(range 0-1)        \[pan\])\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(A zero time (no delay) overrides 'src_level_in_mix' param, & sets level & pan of input)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(pan positions column optional: pan is from -1(Left) to 1(Right), larger vals attenuated in L or R lspkr)\n"
		} \
		^$evv(CERACU)$ {
			set line "(list of \[more than 1\] integers, which must all be different)\n"
		} \
		^$evv(MADRID)$ {
			set line "(list of integers which lie between 1 and the number of input files to the process)\n"
		} \
		^$evv(SHIFTER)$ {
			switch -- $mmode {
				0 {
					set line "(list of at least 2 different integers with values >= 2)\n"
				}
				1 {
					set line "(list of different integers, values >= 2 : number of integers must equal number of input files to process)\n"
				}
			}
		} \
		^$evv(FRACTURE)$ {
			set line "(time - followed by 7 pairs of etime-level pairs, both in range 0-1)\n"
		} \
		^$evv(SPEKLINE)$ {
			set line "(value \[representing 1 spectral-line-frq\] followed by amplitude)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(values must increase from line to line: amplitudes must be greater than zero)\n"
		} \
		^$evv(NEWTEX)$ {
			set line "(time transpos1 level1 transpos2 level2 ....etc)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(transpos is a frequency multiplier : e.g. 2 is an octave transposition)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(every transpos value must be followed by a corresponding level)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(every line must have same number of entries: zero the level to \"remove\" a tranpos)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(transpos values must increase from left to right within any line)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(time values must start at zero and increase from line to line)\n"
		} \
		^$evv(ROTOR)$ {
			set line "(increasing-times-from-zero	    level-between-0-and-1)\n"
		} \
		^$evv(TESSELATE)$ {
			set line "(2 Lines of data, each line having one entry for each input-sound)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Line 1 has the \"Cycle Index\" for each input-sound)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Line 2 has the \"Time Stagger\" for each input-sound)\n"
		} \
		^$evv(CASCADE)$ {
			set line "(increasing-times from > 0 to <= duration of input sound)\n"
		} \
		^$evv(FRACTAL)$ {
			switch -- $mmode {
				0 {
					set line "(time : midi-pitch pairs. Times increase from zero.)\n"
					.maketextp.k.t insert $k.0 $line
				}
				1 {
					set line "(time : semitone-transposition pairs. Times increase from zero.)\n"
					.maketextp.k.t insert $k.0 $line
				}
			}
			incr k
			set line "(Last Time = fractal duration : last Value is ignored.)\n"
		} \
		^$evv(FRACSPEC)$ {
			set line "(time : semitone-transposition pairs. Times increase from zero.)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Last Time = fractal duration : last Value is ignored.)\n"
		} \
		^$evv(REPEATER)$ {
			switch -- $mmode {
				0 {
					set line "(start-time      end-time      no-of-repeats      delay-time)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(Delay-time is from start of 1 delayed segment to start of next.)\n"
				}
				1 {
					set line "(start-time      end-time      no-of-repeats      offset-time)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(Offset-time is from end of 1 delayed segment to start of next.)\n"
				}
			}
		} \
		^$evv(SCRUNCH)$ - \
		^$evv(VERGES)$ {
			set line "(increasing-times from >= 0 to <= duration of input sound)\n"
		} \
		^$evv(MOTOR)$ {
			if {[expr $mmode % 3] == 1} {
				set line "(increasing-times from .016 secs to < [expr $pa([lindex $chlist 0],$evv(DUR)) - 0.016] with min timestep of .016 secs)\n"
			}
		} \
		^$evv(STUTTER)$ {
			set line "(increasing-times from .016 secs to < [expr $pa([lindex $chlist 0],$evv(DUR)) - 0.016] with min timestep of .016 secs)\n"
		} \
		^$evv(CRYSTAL)$ {
			set line "(N lines of data, each with x  y  z coords of a vertex of crystal)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(sqrt (x*x + y*y + z*z) must not exceed value 1.0)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(One extra line of time-val pairs defining envelope of sound events created)\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Envelope vals in range 0 to 1, and must start and end with value 0)\n"
		} \
		^$evv(DISTMARK)$ {
			set line "(increasing-times from (>=) 0.0 secs to < [expr $pa([lindex $chlist 0],$evv(DUR)) - 0.0005])\n"
			.maketextp.k.t insert $k.0 $line
			incr k
			set line "(Steps between times must be > 1/2 of the max waveset-gpsize you set)\n"
		} \
		^$evv(SPECFNU)$ {
			switch -- $mmode {
				6 {
					set line "(List of times between which  HFs extracted. Zero means whole file)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(#HF or #HS or #SCALE or #ELACS)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(after #HF or #HS : List of MIDI-val pitches)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(after #SCALE : List of (1) No. of pitches per oct (2) Reference MIDI-val pitch)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(after #ELACS : List of (1) Size of \"octave\" in semitones (2) pitches per \"oct\" (3) Ref MIDI-val pitch)\n"
				}
				14 {
					set line "(source-interval	    inverted-interval)\n"
				}
				16 - 
				17 - 
				22 {
					set line "(#HF or #HS or #THF or #SCALE or #ELACS)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(after #HF or #HS : List of MIDI-val pitches)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(after #THF : Several lines, each with time and list of MIDI-val pitches.)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(In this case, times must increase, & each line must have same number of pitches \[duplicate pitches if ness\])\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(after #SCALE : List of (1) No. of pitches per oct (2) Reference MIDI-val pitch)\n"
					.maketextp.k.t insert $k.0 $line
					incr k
					set line "(after #ELACS : List of (1) Size of \"oct\" in semitones (2) pitches per \"oct\" (3) Ref MIDI-val pitch)\n"
				}
			}
		}

	.maketextp.k.t insert $k.0 $line
	incr k
	set standardk $k
	.maketextp.b.stan config -text "Delete Features" -command "UnsetStandardSpecialFeatures 0"
}

#------ Menu items for

proc StandardMenu {item} {
	global tstandard

	$tstandard config -state normal
	$tstandard delete 1.0 end

	switch -- $item {
		"click" {
			set line "Command F1 -> '.5='                 Control Command F1 -> '.5='\n"
			$tstandard insert 1.0 $line
			set line "Control F1 -> '1='           Control Shift F1 -> '2='\n"
			$tstandard insert 1.0 $line
			set line "Also Use modified F1 Key for Tempo Markings\n"
			$tstandard insert 1.0 $line
			set line "Shift F3 = 3:2      Control F3 = 3:8      Command F3 = 3:16      Control Command F3 = 3:32\n"
			$tstandard insert 1.0 $line
			set line "Use other function keys for Meter    F3 = 3:4    F4 = 4:4    F5 = 5:4    etc.\n"
			$tstandard insert 1.0 $line
			set line "and CONTROL-r    will renumber all lines correctly.\n"
			$tstandard insert 1.0 $line
			set line "F1 inserts next line number at end of current list\n"
			$tstandard insert 1.0 $line
			set line "(The following uses of Function Keys does not operate on the MAC)\n"
			$tstandard insert 1.0 $line
			set line "or..   3            1=144to220 6:8          22                          \[accelerando\]\n"
			$tstandard insert 1.0 $line
			set line "or..   2            1.5=144       6:8          22                   1..10.               \n"
			$tstandard insert 1.0 $line
			set line "e.g.   1            1=87.33      4:4          10                                             \n"
			$tstandard insert 1.0 $line
			set line "          lineno     tempo       meter        bar-count        accent-pattern (optional)\n"
		}
		"greqone" {
			set line "bandwidth    frq1   \[frq2    frq3 .......\]\n"
		}
		"greq" {
			set line "bandwidth1    frq1    \[bw2    frq2    bw3    frq3 .......\]\n"
		}
		"p_invert" {
			set line "source-interval	    inverted-interval\n"
		}
		"p_synth" {
			set line "relative amplitude of harmonics, in turn: value range 0-1\n"
		}
		"vfilt" -
		"p_vowels" {
			set line "plus : n for 'n' : m for 'm' : r for 'r' : th for 'th'\[vowel only\]\n"
			$tstandard insert 1.0 $line
			set line "plus : x for short neutral vowel : xx long neutral vowel\n"
			$tstandard insert 1.0 $line
			set line "vowels can be --- ee, i, ai, aii, e, a, ar, o, or, oa, u, uu, ui, oo\n"
			$tstandard insert 1.0 $line
			set line "time-vowel pairs\n"
		}
		"p_gen" {
			set line "OR a (numeric) MIDI note value between 0 and 131\n"
			$tstandard insert 1.0 $line
			set line "with NO SPACES in all of this......\n"
			$tstandard insert 1.0 $line
			set line "followed by numeric value of octave (range -5 to +5), where 0 means octave starting at middle C\n"
			$tstandard insert 1.0 $line
			set line "Midipitch can be A,B,C,D,E,F,or G, possibly followed by '#'\[sharp\] or 'b'\[flat\]\n"
			$tstandard insert 1.0 $line
			set line "time-midipitch pairs, where times start at zero and increase.\n"
		}
		"mix_on_grid" {
			set line "Comments, e.g. grid numbering, permitted at end of a line ONLY\n"
			$tstandard insert 1.0 $line
			set line "Number of times, or of marked times, must match number of infiles\n"
			$tstandard insert 1.0 $line
			set line "OR list, with times-to-be-used marked by 'x' \[before time, with no space\]\n"
			$tstandard insert 1.0 $line
			set line "list of times where sounds start in mix, on separate lines\n"
		}
		"automix" {
			set line "time plus a relative level for each infile\n"
		}
		"edit_cutmany" {
			set line "pair of times for each segment to be cut\n"
		}
		"stack" {
			set line "one semitone transposition for each item in the stack\n"
		}
		"p_insert" {
			set line "starttime	endtime\n"
			$tstandard insert 1.0 $line
			set line "------- OR --------\n"
			$tstandard insert 1.0 $line
			set line "startsample	endsample\n"
			$tstandard insert 1.0 $line
			set line "GROUP-sampcnt in source SOUND \[eg count pairs in stereo\]\n"
		}
		"split" {
			set line "lofrq    hifrq    4-bits   \[amp1    amp2   \[(+)transpos\]\]\n"
		}
		"fltbanku" -
		"fltiter" {
			set line "frq    amplitude\n"
			$tstandard insert 1.0 $line
			set line "----------- OR ----------\n"
			$tstandard insert 1.0 $line
			set line "midi-pitch    amplitude\n"
		}
		"fltbankv" {
			set line "time   midipitch1   amplitude1  \[midi2   amp2   midi3   amp3 ......\]\n"
			$tstandard insert 1.0 $line
			set line "----------- OR ----------\n"
			$tstandard insert 1.0 $line
			set line "time   frq1   amplitude1  \[frq2   amp2   frq3   amp3 ......\]\n"
		}
		"fltbankv2" {
			set line "Times, in both data sets, must start at ZERO\n"
			$tstandard insert 1.0 $line
			set line "time   partialno1   amplitude1  \[pno2   amp2   pno3   amp3 ......\]\n"
			$tstandard insert 1.0 $line
			set line "PITCH LINES FOLLOWED BY line which starts with '#', THEN MORE LINES.....\n"
			$tstandard insert 1.0 $line
			set line "time   midipitch1   amplitude1  \[midi2   amp2   midi3   amp3 ......\]\n"
			$tstandard insert 1.0 $line
			set line "----------- OR ----------\n"
			$tstandard insert 1.0 $line
			set line "time   frq1   amplitude1  \[frq2   amp2   frq3   amp3 ......\]\n"
		}
		"del_perm2" {
			set line "transpos in semitones; time-fractions must sum to 1.0\n"
			$tstandard insert 1.0 $line
			set line "transpos  time-fraction   transpos   time-fraction .........\n"
		}
		"distort_hrm" {
			set line "harmonic-no    amplitude\n"
		}
		"del_perm" {
			set line "transpos in semitones; time-fractions must sum to 1.0\n"
			$tstandard insert 1.0 $line
			set line "LINE 2: transpos  time-fraction   transpos   time-fraction .........\n"
			$tstandard insert 1.0 $line
			set line "LINE 1: a set of midi vals to transpose to, from MIDI 60\n"
		}
		"sequencer" {
			set line "event-time    semitone-tranposition    level(0-1)\n"
		}
		"sequencer2" {
			set line "ALL OTHER LINES:   sound-number    event-time    MIDI-pitch    level(0-1)    duration\n"
			$tstandard insert 1.0 $line
			set line "LINE 1: a set of midipitches, one for each input soundfile.\n"
		}
		"grn_remotif" {
			set line "semitone-tranposition    duration-multiplier\n"
		}
		"twixt" {
			set line "First time in list is start time in first file.\n"
			$tstandard insert 1.0 $line
			set line "list of times at which outsound switches from one infile to other.\n"
		}
		"chords" {
			set line "list of MIDI values, positively fractiona, possibly negative - very low pitches.\n"
		}
		"sphinx" {
			set line "Once first segment obtained from every file, takes 2nd segment from File1, File2 etc.\n"
			$tstandard insert 1.0 $line
			set line "Output takes 1st segment from file1 (col1), then 1st seg from file2, then file3 etc.\n"
			$tstandard insert 1.0 $line
			set line "These times partition the files into segments.\n"
			$tstandard insert 1.0 $line
			set line "N columns of values (all of same length) which are times in the N input files.\n"
		}
		"multidelay" {
			set line "time     amp      \[pan\]\n"
			$tstandard insert end $line
			set line "if time = 0, overrides 'src level in mix' param & just gains and positions input.\n"
			$tstandard insert end $line
			set line "pan -1 = Left, +1 = Right\n"
			$tstandard insert end $line
			set line "time     amp      \[pan\]\n"
			set line "pan vals <-1 are attenuated in L lspkr, vals >1 attenuated in R.\n"
		}
	}
	$tstandard insert 1.0 $line
	$tstandard config -state disabled
}


proc UnsetStandardSpecialFeatures {istexture} {
	global standardk

	if {$istexture} {
		.maketextp.k.t delete 2.0 $standardk.0
	} else {
		.maketextp.k.t delete 1.0 $standardk.0
	}
	set standardk 0
	if {$istexture} {
		.maketextp.b.stan config -text "Standard Features" -command StandardTextureFeatures
	} else {
		.maketextp.b.stan config -text "Standard Features" -command StandardSpecialFeatures
	}
}

#--- Create dropouts in a soundfile

proc DropOutEnv {} {
	global chlist wl evv drop wstk pa pr_dropout CDPidrun prg_dun prg_abortd CDPidrun

	set memfile	[file join $evv(URES_DIR) dropout$evv(CDP_EXT)]

	if {![catch {open $memfile "r"} zit]} {
		set k 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {([string length $line] <= 0) || [string match [string index $line 0] ";"]} {
				continue
			}
			switch -- $k {
				0 { set drop(fnam)		$line }
				1 { set drop(stt)		$line }
				2 { set drop(end)		$line }
				3 { set drop(pc)		$line }
				4 { set drop(minloss)	$line }
				5 { set drop(maxloss)	$line }
				6 { set drop(mindur_ms) $line }
				7 { set drop(maxdur_ms) $line }
				8 { set drop(slope_ms)  $line }
				9 { set drop(seed)		$line }
			}
			incr k
		}
		close $zit
	}

	set OK 1
	set zerostep 0.00001				;#	Timestep less than 1 sample at 96K
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam $chlist
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			set OK 0
		}
	} else {
		set i [$wl curselection]
		if {([llength $i] == 1) && ($i != -1)} {
			set fnam [$wl get $i]
			if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				set OK 0
			}
		}
	}
	if {!$OK} {
		Inf "Select a soundfile"
		return
	}
	set dur $pa($fnam,$evv(DUR))
	set f .dropout 
	if [Dlg_Create $f "DROPOUTS" "set pr_dropout 0" -height 20 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Run"  -command "set pr_dropout 1" -width 6 -highlightbackground [option get . background {}]
		button $f.0.h -text "Help" -command HelpDropout -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.q -text "Quit" -command "set pr_dropout 0" -width 6 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.h -side left -padx 4
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Start of dropout" -width 20
		entry $f.1.e -textvariable drop(stt) -width 12
		pack $f.1.ll $f.1.e -side left
		pack $f.1 -side top -fill x -expand true -pady 2
		frame $f.2
		label $f.2.ll -text "End of dropout" -width 20
		entry $f.2.e -textvariable drop(end) -width 12
		pack $f.2.ll $f.2.e -side left
		pack $f.2 -side top -fill x -expand true -pady 2
		frame $f.3
		label $f.3.ll -text "Percentage dropout" -width 20
		entry $f.3.e -textvariable drop(pc) -width 12
		pack $f.3.ll $f.3.e -side left
		pack $f.3 -side top -fill x -expand true -pady 2
		frame $f.4
		label $f.4.ll -text "min loss (0-1)" -width 20
		entry $f.4.e -textvariable drop(minloss) -width 12
		pack $f.4.ll $f.4.e -side left
		pack $f.4 -side top -fill x -expand true -pady 2
		frame $f.5
		label $f.5.ll -text "max loss (0-1)" -width 20
		entry $f.5.e -textvariable drop(maxloss) -width 12
		pack $f.5.ll $f.5.e -side left
		pack $f.5 -side top -fill x -expand true -pady 2
		frame $f.6
		label $f.6.ll -text "min dur (mS)" -width 20
		entry $f.6.e -textvariable drop(mindur_ms) -width 12
		pack $f.6.ll $f.6.e -side left
		pack $f.6 -side top -fill x -expand true -pady 2
		frame $f.7
		label $f.7.ll -text "max dur (mS)" -width 20
		entry $f.7.e -textvariable drop(maxdur_ms) -width 12
		pack $f.7.ll $f.7.e -side left
		pack $f.7 -side top -fill x -expand true -pady 2
		frame $f.8
		label $f.8.ll -text "drop slope (mS)" -width 20
		entry $f.8.e -textvariable drop(slope_ms) -width 12
		pack $f.8.ll $f.8.e -side left
		pack $f.8 -side top -fill x -expand true -pady 2
		frame $f.9
		label $f.9.ll -text "seed: 1 to 256 (or 0)" -width 20
		entry $f.9.e -textvariable drop(seed) -width 12
		pack $f.9.ll $f.9.e -side left
		pack $f.9 -side top -fill x -expand true -pady 2
		frame $f.10
		label $f.10.ll -text "output filename" -width 20
		entry $f.10.e -textvariable drop(ofnam) -width 12
		pack $f.10.ll $f.10.e -side left
		pack $f.10 -side top -fill x -expand true -pady 2
		if {$dur < 1.0} {
			set drop(maxdur_ms) [expr $dur * $evv(SECS_TO_MS)]
		}
		bind $f.1.e <Down> {focus .dropout.2.e}
		bind $f.2.e <Down> {focus .dropout.3.e}
		bind $f.3.e <Down> {focus .dropout.4.e}
		bind $f.4.e <Down> {focus .dropout.5.e}
		bind $f.5.e <Down> {focus .dropout.6.e}
		bind $f.6.e <Down> {focus .dropout.7.e}
		bind $f.7.e <Down> {focus .dropout.8.e}
		bind $f.8.e <Down> {focus .dropout.9.e}
		bind $f.9.e <Down> {focus .dropout.10.e}
		bind $f.10.e <Down> {focus .dropout.1.e}
		bind $f.1.e <Up> {focus .dropout.10.e}
		bind $f.2.e <Up> {focus .dropout.1.e}
		bind $f.3.e <Up> {focus .dropout.2.e}
		bind $f.4.e <Up> {focus .dropout.3.e}
		bind $f.5.e <Up> {focus .dropout.4.e}
		bind $f.6.e <Up> {focus .dropout.5.e}
		bind $f.7.e <Up> {focus .dropout.6.e}
		bind $f.8.e <Up> {focus .dropout.7.e}
		bind $f.9.e <Up> {focus .dropout.8.e}
		bind $f.10.e <Up> {focus .dropout.9.e}
		bind $f <Return> {set pr_dropout 1}
		bind $f <Escape> {set pr_dropout 0}
		wm resizable $f 0 0
	}
	if {![info exists drop(fnam)] || ![string match $fnam $drop(fnam)]} {		;#	SET DEFAULTS
		set drop(stt) 0.0
		set drop(end) $dur
		set drop(pc)  50.0
		set drop(minloss) 0.5
		set drop(maxloss) 1
		set drop(mindur_ms) 1
		set drop(maxdur_ms) 100
		set drop(slope_ms) 0
		set drop(seed) 1
		if {$dur < 1.0} {
			set drop(maxdur_ms) [expr $dur * $evv(SECS_TO_MS)]
		}
		set drop(fnam) $fnam		;#	Remember details of infile
	}
	set dropmaxdur [expr $dur * $evv(SECS_TO_MS)]
	if {[info exists drop(maxdur_ms)] && ($drop(maxdur_ms) > $dropmaxdur)} {
		set drop(maxdur_ms) $dropmaxdur
	}
	set drop(ofnam) [file rootname [file tail $fnam]]						;#	Default output filename derives from inputr filename
	append drop(ofnam) "_drpout"

	set brknam $evv(DFLT_OUTNAME)0$evv(TEXT_EXT)
	set pr_dropout 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_dropout
	while {!$finished} {
		tkwait variable pr_dropout
		DeleteAllTemporaryFiles
		switch -- $pr_dropout {
			1 {
				if {([string length $drop(stt)] <= 0) || ![IsNumeric $drop(stt)] || ($drop(stt) < 0.0) || ($drop(stt) >= $dur)} {
					Inf "Invalid time for dropout start (range : 0 to <$dur)"
					continue
				}
				if {([string length $drop(end)] <= 0) || ![IsNumeric $drop(end)] || ($drop(end) <= 0.0) || ($drop(end) > $dur)} {
					Inf "Invalid time for dropout end (range : >0 to $dur)"
					continue
				}
				set drop(region) [expr $drop(end) - $drop(stt)]
				if {$drop(region) <= 0.0} {
					Inf "Incompatible start ($drop(stt)) and end ($drop(end)) times for dropout"
					continue
				}
				if {([string length $drop(pc)] <= 0) || ![IsNumeric $drop(pc)] || ($drop(pc) <= 0.0) || ($drop(pc) > 100)} {
					Inf "Invalid value for percentage of dropout (range : >0 to 100)"
					continue
				}
				set drop(dur) [expr ($drop(pc)/100.0) * $drop(region)]

				if {([string length $drop(minloss)] <= 0) || ![IsNumeric $drop(minloss)] || ($drop(minloss) <= 0.0) || ($drop(minloss) > 1.0)} {
					Inf "Invalid minimum level drop for dropouts (range : >0 to 1)"
					continue
				}
				if {([string length $drop(maxloss)] <= 0) || ![IsNumeric $drop(maxloss)] || ($drop(maxloss) <= 0.0) || ($drop(maxloss) > 1.0)} {
					Inf "Invalid maximum level drop for dropouts (range : >0 to 1)"
					continue
				}
				if {$drop(maxloss) < $drop(minloss)} {
					set temp $drop(maxloss)
					set drop(maxloss) $drop(minloss)
					set drop(minloss) $temp
				}
				set drop(minlev) [expr 1.0 - $drop(minloss)]
				set drop(maxlev) [expr 1.0 - $drop(maxloss)]
				set drop(levrange) [expr $drop(maxlev) - $drop(minlev)]

				if {([string length $drop(mindur_ms)] <= 0) || ![IsNumeric $drop(mindur_ms)] || ($drop(mindur_ms) < 0.0) || ([expr $drop(mindur_ms) * $evv(MS_TO_SECS)] >= $drop(dur))} {
					Inf "Invalid minimum duration for dropouts (range : >0 to < total duration of all dropouts = [expr $drop(dur) * $evv(SECS_TO_MS)] mS)"
					continue
				}
				if {([string length $drop(maxdur_ms)] <= 0) || ![IsNumeric $drop(maxdur_ms)] || ($drop(maxdur_ms) < 0.0) || ([expr $drop(maxdur_ms) * $evv(MS_TO_SECS)] >= $drop(dur))} {
					Inf "Invalid maximum duration for dropouts (range : >0 to < total duration of all dropouts = [expr $drop(dur) * $evv(SECS_TO_MS)] mS)"
					continue
				}
				set drop(mindur) [expr $drop(mindur_ms) * $evv(MS_TO_SECS)]
				set drop(maxdur) [expr $drop(maxdur_ms) * $evv(MS_TO_SECS)]
				if {$drop(maxdur) < $drop(mindur)} {
					set temp $drop(maxdur)
					set drop(maxdur) $drop(mindur)
					set drop(mindur) $temp
				}
				set minsplic [expr $drop(mindur)/2.0]
				set drop(durrange) [expr $drop(maxdur) - $drop(mindur)]
				if {([string length $drop(slope_ms)] <= 0) || ![IsNumeric $drop(slope_ms)] || ($drop(slope_ms) < 0.0)} {
					Inf "Invalid slope length for dropouts"
					continue
				}
				set drop(slope) [expr $drop(slope_ms) * $evv(MS_TO_SECS)]
				if {$drop(slope) >= $minsplic} {
					Inf "Invalid slope length for dropouts.\nMust be less than 1/2 duration of minimum dropout-segment length\n([expr $minsplic * $evv(SECS_TO_MS)] mS)"
					continue
				}
				if {$drop(slope) < $zerostep} {
					set drop(slope) $zerostep
				}
				if {([string length $drop(seed)] <= 0) || ![IsNumeric $drop(seed)] || ![regexp {^[0-9]+$} $drop(seed)] || ($drop(seed) > 512)} {
					Inf "Invalid seed value (range : 0 (no seed) to 512)"
					continue
				}
				if {[string length $drop(ofnam)] <= 0} {
					Inf "No output filename name entered"
					continue
				}
				if {![ValidCDPRootname $drop(ofnam)]} {
					Inf "Invalid output filename"
					continue
				}
				set ofnam [string tolower $drop(ofnam)]
				append ofnam $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists: please choose a different output file name"
					continue
				}
				if {$drop(seed) > 0} {
					expr srand($drop(seed))
				} else {
					set t [clock clicks]		;#	Set up an asrbitrary rand number from computer clock
					expr srand($t)
				}
					;#	GENERATE A SET OF RANDOM-LENGTH DROPOUT-SEGMENT DURATIONS

				set done 0
				while {!$done} {				;#	Keep generating a rand seq of droput-seg durs until valid sequence found
					set sum 0.0					;#	for each pass ...
					while {$sum < $drop(dur)} {	;#	Generate random dropout lengths until total dur of dropouts reached
						set dt [expr (rand() * $drop(durrange)) + $drop(mindur)]
						lappend dts $dt
						set sum [expr $sum + $dt]
					}
					set overflow [expr $sum - $drop(dur)]
					set done 1					;#	Almost inevitable, total sum is larger than total dur required so ...
					if {$overflow > 0.0} {		;#	attempt to shorten 1 dropout to make total-dur of all dropouts = required total dur
						set len [llength $dts]
						set k 0
						set done 0
						while {$k < $len} {
							set dt [lindex $dts $k]
							if {[expr $dt - $overflow] >= $drop(mindur)} {
								set dt [expr $dt - $overflow]
								set dts [lreplace $dts $k $k $dt]
								set done 1		;#	If succeed, mark as done so drop out of outer loop
								break			;#	and drop out of inner loop
							}
							incr k
						}
					}
				}								;#	We now have a sequence of dropuout-segment durations

					#	GENERATE LEVELS FOR THESE DROPOUT SEGS AND FORM DURATION-LEVEL PAIRS

				catch {unset drop(pairs)}
				foreach dt $dts {
					set lev [expr (rand() * $drop(levrange)) + $drop(minlev)]
					set pair [list $dt $lev]
					lappend drop(pairs) $pair
				}

					;#	GENERATE A SET OF RANDOM-LENGTH ~NON~DROPOUT-SEGMENT DURATIONS BY CUTTING-UP REMAINING TIME (restofregion)

				set drop(restofregion) [expr $drop(region) - $drop(dur)]
				catch {unset brkpairs}
				if {$drop(restofregion) < $evv(FLTERR)} {		;#	100% Dropout :  no interstices
					set brkpair0 [list 0.0 1.0]
					lappend brkpairs $brkpair0
					set len [llength $drop(pairs)]
					set k 0
					set now 0.0
					while {$k < $len} {
						set pair [lindex $drop(pairs) $k]
						set segdur  [lindex $pair 0]
						set thislev [lindex $pair 1]
						set end_dnsplic [expr $now + $drop(slope)]
						set brkpair [list $end_dnsplic $thislev]
						lappend brkpairs $brkpair
						set now [expr $now + $segdur]
						set stt_upsplic [expr $now - $drop(slope)]
						set brkpair [list $stt_upsplic $thislev]
						lappend brkpairs $brkpair
						incr k
					}
					set brkpair [list $now 1.0]
					lappend brkpairs $brkpair
					if {$drop(stt) > 0.0} {
						catch {unset nulist}
						lappend nulist $brkpair0
						set len [llength $brkpairs]
						set k 0
						while {$k < $len} {
							set brkpair [lindex $brkpairs $k]
							set time [expr [lindex $brkpair 0] + $drop(stt)]
							set lev  [lindex $brkpair 1]
							set brkpair [list $time $lev]
							lappend nulist $brkpair
							incr k
						}
						set brkpairs $nulist
					} 
					if {$drop(end) < $dur} {
						set brkpair0 [list $dur 1.0]
						lappend brkpairs $brkpair0
					} 
				} else {

					set nlen [expr $len + 1]										;#	-|-|-|-   3 drops(|) gives 4 interstices (-)
					set drop(intersticelen) [expr $drop(restofregion)/double($nlen)]
					set lasttime 0.0												
					set k 1
					catch {unset interstices}										;#	Generate durations of interstices
					while {$k <= $len} {
						set t [expr $drop(intersticelen) * $k]						;#	Initial interstice-time (equally spaced)			--|--|--|--|--|--|--|--|--
						set tx [expr rand() * 2.0]									;#	Random displacement time by + or - half of seglen	--------------------------
						set tx [expr ($tx - 1.0)/2.0]
						set tx [expr $tx * $drop(intersticelen)]
						set t [expr $t + $tx]										;#	This displaces times randomly						-|---|--|-||------|-|---|-
						set interstice [list $lasttime $t]							;#	but taking up, together, all the interstitial time	--------------------------
						set lasttime $t
						lappend interstices $interstice
						incr k
					}
					set interstice [list $lasttime $drop(restofregion)]
					lappend interstices $interstice

						;#	REPLACE THE CUT SEGMENT-START-END PAIRS BY THEIR DURATIONS

					set idur [lindex [lindex $interstices 0] 1]						;#	Get duration (= endtime) of first interstice
					set interstices [lreplace $interstices 0 0 $idur]				;#	and replace pair by duration
					set k 1
					while {$k < $nlen} {											;#	Now replace all segs by their durations
						set stt [lindex [lindex $interstices $k] 0]
						set end [lindex [lindex $interstices $k] 1]
						set idur [expr $end - $stt]
						set interstices [lreplace $interstices $k $k $idur]
						incr k
					} 

						;#	INTERLEAVE INTERSTICES AND DROPOUTS

					set k 0
					set now 0.0
					while {$k < $len} {
						set brkpair [list $now 1.0]				;#	Start of interstice, level 1
						lappend brkpairs $brkpair			;#	(1)
						set idur [lindex $interstices $k]
						set iendtime [expr $idur + $now]
						set brkpair [list $iendtime 1.0]			;#	End of interstice, level 1
						lappend brkpairs $brkpair			;#	(2)
						set time [expr $iendtime + $drop(slope)]	;#	End of splice into dropout
						set droppair [lindex $drop(pairs) $k]
						set lev [lindex $droppair 1]				;#	droppair  = duration:LEVEL
						set brkpair [list $time $lev]				;#	splice down to dropout level
						lappend brkpairs $brkpair			;#	(3)
						set now [expr $iendtime + [lindex $droppair 0]]	;#	droppair  = DURATION:level	now becomes end of dropout
						set pre_endtime [expr $now - $drop(slope)]		;#	pre_endtime = time before splice-up to end of dropout
						set brkpair [list $pre_endtime $lev]			;#	so we have	   1   23    4  brkpnt pairs
						lappend brkpairs $brkpair			;#	(4)						   ____		
						incr k											;#				       \_____(/)		
					}													;#					   
					set brkpair [list $now 1.0]						;#	Start of final interstice, level 1
					lappend brkpairs $brkpair
					set brkpair [list $drop(region) 1.0]			;#	End
					lappend brkpairs $brkpair

				;#	ADD IN START OR END PORTIONS WHICH QRE NOT DROPOUT-TREATED

					set len [llength $brkpairs]
					set k 0
					set len_less_one [expr $len - 1]
					while {$k < $len} {
						set brkpair [lindex $brkpairs $k]
						set lev [lindex $brkpair 1]
						if {$k == 0} {								;#	First brkpoint to time zero
							set brkpair [list 0.0 $lev]
						} elseif {$k == $len_less_one} {			;#	End breakpoint to infile duration
							set time $dur
							set brkpair [list $time $lev]
						} else {									;#	Intermediate brkpnts advance by start-time of dropout-region
							set time [lindex $brkpair 0]
							set time [expr $time + $drop(stt)]
							set brkpair [list $time $lev]
						}
						set brkpairs [lreplace $brkpairs $k $k $brkpair]
						incr k
					}
				}

					;#	WRITE BREAKPOINT FILE

				if [catch {open $brknam "w"} zit] {
					Inf "Cannot open temporary brkpnt file $brknam to write data\n$zit"
					continue
				}
				foreach brkpair $brkpairs {
					puts $zit $brkpair
				}
				close $zit
				Block "CREATING DROPOUT"
				set OK 1
				while {$OK} {
					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd loudness 1 $fnam $ofnam $brknam
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Dropout process failed to run"
						set OK 0
						break
					} else {
   						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						Inf "Dropout creation failed"
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						Inf "No dropout file generated"
						set OK 0
						break
					}
					break
				}
				if {!$OK} {
					UnBlock
					continue
				}
				if {[FileToWkspace $ofnam 0 0 0 0 1] >= 0} {
					Inf "File $ofnam is on the workspace"
				}
				set params [list $fnam $drop(stt) $drop(end) $drop(pc) $drop(minloss) $drop(maxloss) $drop(mindur_ms) $drop(maxdur_ms) $drop(slope_ms) $drop(seed)]
				if [catch {open $memfile "w"} zit] {
					Inf "Cannot store parameters used"
				} else {
					foreach param $params {	
						puts $zit $param
					}
					close $zit
				}				
				UnBlock
				set finished 1
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

proc HelpDropout {} {
	set msg "                      Do Dropouts in Sound\n"
	append msg "\n"
	append msg "Process generates random-placed signal dropouts\n"
	append msg "of random depth in the input soundfile.\n"
	append msg "\n"
	append msg "\"Start\" and \"End of Dropout\"\n"
	append msg "set a time-range in soundfile where dropouts occur.\n"
	append msg "\n"
	append msg "\"Percentage dropout\"\n"
	append msg "determines how much dropout there is, in that range.\n"
	append msg "\n"
	append msg "\"min\" and \"max loss\"\n"
	append msg "determine the range of level drops in the dropouts.\n"
	append msg "\n"
	append msg "\"min\" and \"max dur (mS)\"\n"
	append msg "determine range of durations of the dropout segments.\n"
	append msg "\n"
	append msg "\"drop slope (mS)\"\n"
	append msg "determines the steepness of the cutoff into dropout.\n"
	append msg "This is a splice-length in mS, and can be zero.\n"
	append msg "\n"
	append msg "\"seed\"\n"
	append msg "This is a seed value for the random generator.\n"
	append msg "Non-zero value generates reproducible randomness.\n"
	append msg "i.e. the same  seed applied to the same sound\n"
	append msg "will produce an identical sound output.\n"
	append msg "Zero seed-value produces different output every time.\n"
	append msg "\n"
	Inf $msg
}
