#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#################
# TEXT ANALYSIS #
#################

################################
# (A) COMPARING WORD-SEQUENCES #
################################

#	phraselen = number of words in phrases to be compared
#	exact = exact matches only: default - allow up to (less than) half of words to be omitted im comparison phrase
#   Run the process several times comparing phrases of lengths from 1 word UP TO phraselen words

proc AnalyseTextPropertyWordData {in_fnam} {
	global phrastor phrascnt propwords wl chlist tstats_phraselen tstats_upto tstats_exact tstats_init homonym wstk pa evv
	global pr_tstats tstats tstats_disp stats_preseematches equivalents_loaded newnewequiv newequiv ts_linindeces
	global ts_propfile

	;#	EXTRACT WORDS FROM PROPERTY FILE, TEXT PROPERTY

	set propfile [GetPropsDataFromFile $in_fnam]
	if {[string length $propfile] <= 0} {
		return
	}
	set ts_propfile $propfile
	if {!$equivalents_loaded} {
		if {![LoadHomonyms]} {
			return
		}
		set equivalents_loaded 1
	}
	if {![info exists tstats_init]} {
		set newequiv 0
		set tstats_init 1
	}
	set newnewequiv 0
	set f .tstats
	if [Dlg_Create $f "TEXT STATISTICS" "set pr_tstats 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1
		frame $f.2
		frame $f.3
		frame $f.4
		frame $f.7
		frame $f.8
		button $f.0.f -text "Get Stats" -command "set pr_tstats 1" -highlightbackground [option get . background {}]
		button $f.0.q -text Quit -command "set pr_tstats 0" -highlightbackground [option get . background {}]
		pack $f.0.f -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1.ll -text "No. of words to match (use Up/Dn arrows to change)"
		entry $f.1.e -textvariable tstats_phraselen -width 3 -state readonly
		label $f.1.dum -text "" -width 10
		checkbutton $f.1.u -variable tstats_upto -text "All phrases up to this length"
		pack $f.1.ll  $f.1.e  $f.1.dum $f.1.u -side left -pady 2
		pack $f.1 -side top -fill x -expand true
		checkbutton $f.2.e -variable tstats_exact -text "Exact phrase matches"
		pack $f.2.e  -side left -pady 2
		pack $f.2 -side top
		label $f.3.ll -text "Display Format : By Wordcnt "
		radiobutton $f.3.r1 -variable tstats_disp -text Alphabetic -value 1
		radiobutton $f.3.r2 -variable tstats_disp -text "By Frq" -value 2
		label $f.3.ll2 -text " : Ignoring Wordcnt "
		radiobutton $f.3.r3 -variable tstats_disp -text Alphabetic -value 3
		radiobutton $f.3.r4 -variable tstats_disp -text "By Frq" -value 4
		pack $f.3.ll $f.3.r1 $f.3.r2 $f.3.ll2 $f.3.r3 $f.3.r4 -side left
		pack $f.3 -side top 
		button $f.4.see -text "" -bd 0 -width 23 -command {} -highlightbackground [option get . background {}]
		button $f.4.ass -text "" -bd 0 -width 23 -command {} -highlightbackground [option get . background {}]
		button $f.4.sav -text "" -bd 0 -width 23 -command {} -highlightbackground [option get . background {}]
		pack $f.4.see $f.4.ass $f.4.sav -side left
		pack $f.4
		label $f.5 -text "" -fg $evv(SPECIAL)
		pack $f.5 -side top
		label $f.6 -text "" -fg $evv(SPECIAL)
		pack $f.6 -side top
		label $f.7.ll -text ""
		button $f.7.e -text "" -command {} -bd 0 -highlightbackground [option get . background {}]
		button $f.7.e2 -text "" -command {} -bd 0 -highlightbackground [option get . background {}]
		pack $f.7.ll $f.7.e $f.7.e2 -side left
		pack $f.7 -side top
		set tstats [Scrolled_Listbox $f.8.ll -width 100 -height 32 -selectmode single]
		pack $f.8.ll -side top
		pack $f.8 -side top -fill x -expand true
		button $f.9 -text "" -command {} -width 30 -bd 0 -highlightbackground [option get . background {}]
		pack $f.9 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Up>		{IncrTstatsPhraselen 1}
		bind $f <Down>		{IncrTstatsPhraselen 0}
		bind $f <Return> {set pr_tstats 1}
		bind $f <Escape> {set pr_tstats 0}
	}
	if {[info exists homonym]} {
		.tstats.9 config -text "Edit List of Word Equivalents" -command EditHomonyms -bd 2
	}
	$tstats delete 0 end
	set tstats_phraselen 1
	set tstats_disp 0
	set pr_tstats 0
	set tstats_exact 1
	set tstats_upto 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_tstats $f
	set finished 0
	while {!$finished} {
		tkwait variable pr_tstats
		switch -- $pr_tstats {
			0 {
				break
			}
			1 {
				if {!$tstats_disp} {
					Inf "No Display Format Specified"
					continue
				}
				Block "GETTING STATISTICS"
				if {![info exists lastsort] \
				||  ($tstats_phraselen != [lindex $lastsort 0]) \
				||  ($tstats_upto != [lindex $lastsort 1]) \
				||  ($tstats_exact != [lindex $lastsort 2]) \
				||  $newnewequiv } {
					catch {unset phrastor}
					catch {unset phrascnt}
					SetupSeeStatsMatches
					if {$tstats_upto} {
						set refgpsize 1					;#	SIZE OF FIRST GROUPS TO BE COMPARED STARTS AT 1 WORD
					} else {
						set refgpsize $tstats_phraselen	;#	SIZE OF FIRST GROUPS TO BE COMPARED IS FULL PHRASE-SIZE SPECIFIED
					}
					set minrefgpsize $refgpsize

					;#	GO THROUGH THE TEXT (SEVERAL TIMES) EXTRACTING PHRASES OF ALL LENGTHS REQUIRED

					while {$refgpsize <= $tstats_phraselen} {

					;#	GO THROUGH THE TEXT EXTRACTING EVERY SUCCESSIVE SET OF gpsize WORDS (ADVANCE 1 WORD AT A TIME)

						set n 0
						set lim [expr [llength $propwords] - $refgpsize]
						set lim_less_one [expr $lim - 1]
						set matches_made {}

						while {$n < $lim_less_one} {

							;#	SKIP ANY REFERENCE PHRASE OF THIS SIZE WHICH HAS ALREADY BEEN MATCHED OR 

							set k [lsearch $matches_made $n]
							if {$k >= 0} {
								incr n
								continue
							}

						;#	ASSEMBLE THE REFERENCE PHRASE

							set k $n
							set cnt 0
							catch {unset refphrase}
							while {$cnt < $refgpsize} {
								lappend refphrase [lindex $propwords $k]
								incr k
								incr cnt
							}

							;#	IGNORE NULL-PROPS (NO TEXT) OR PHRASES WITH A NULL-PROP CONTAINED

							if [string match [lindex $refphrase end] $evv(NULL_PROP)] {
								incr n $refgpsize
								continue
							}

							set m $n
							incr m
							while {$m < $lim} {

								;#	SETUP PARAMETERS FOR THE COMPARISON
					
								set xx $refgpsize				;#	Exact comparison compares only phrases of same size as ref
																;#	Inexact comparison can take place if wordlen > 2
								if {($refgpsize > 2) && !$tstats_exact} {
									set xx [expr $refgpsize/2]	;#	Set minimum-phraselen of phrase being compared
									incr xx
								}

								;#	TRY MATCH WITH MIN NO OF POSSIBLE MATCHING WORDS, UP TO MAX NO (= SAME SIZE AS refphrase)
					
								while {$xx <= $refgpsize} {
									set badmatchespossible [expr $refgpsize - $xx]	;#	MIN OF BADMATCHES TO BE CERTAIN PHRASES CAN'T MATCH

									;#	ASSEMBLE THE COMPARISON PHRASE

									set j $m
									set cnt 0
									catch {unset phrase}
									while {$cnt < $xx} {
										lappend phrase [lindex $propwords $j]
										incr j
										incr cnt
									}
									set badmatches 0
									set cnt 0
									set cntref 0
									while {$cntref < $refgpsize} {
										set phrasword	 [lindex $phrase $cnt]
										set refphrasword [lindex $refphrase $cntref]
										set refphrasword [GetWordEquiv $refphrasword]	;#	IF WORD EQUIV TO SOME OTHER WORD, USE THAT WORD INSTEAD.
										if {![WordMatch $refphrasword $phrasword]} {	;#	WordMatch LOOKS AT ANY LIST OF WORDS EQUIVALENT TO REF WORD,
											if {$cntref == 0} {							;#	AS WELL AS EXACT MATCHES.
												break				;#	1ST WORD MUST MATCH
											} elseif {$cntref == [expr $refgpsize - 1]} {
												break				;#	LAST WORD MUST MATCH
											} else {
												incr badmatches
												if {$badmatches > $badmatchespossible} {
													break			;#	TOO MANY BADMATCHES
												}
												incr cnt -1			;#	IF NO MATCH, PREVENT MOVING UP phrase, WHILE CONTINUING TO MOVE UP refphrase
											}
										}
										incr cntref
										incr cnt
										if {$cnt >= $xx} {			;#	IF AT END OF SHORTER GROUP, QUIT, EVEN IF NOT AT END OF REF GROUP
											break
										}
									}
									if {$cntref == $refgpsize} {	;#	FOUND A MATCH


									;#	AVOID acd MATCHING abacd (i.e. a--cd) BECAUSE acd IS JUST THE END PART OF ABacd

										if {$xx < $refgpsize} {
											set startend [expr $refgpsize - $xx]
											if {[string match [lindex $refphrase 0] [lindex $refphrase $startend]]} {
												incr xx
												continue			;#	NO MATCH
											}
										}

										;#	STORE INDEX OF PHRASE REPETS
										
										if {![info exists phrastor($n,$refgpsize)]} {
											set phrastor($n,$refgpsize) $m		;#	STORE INDEX IN WORDLIST OF PHRASE-REPEAT(S)
											set phrascnt($n,$refgpsize) $xx		;#	STORE NUMBER OF WORDS USED IN MATCHED PHRASE
										} else {
											set jj [lsearch $phrastor($n,$refgpsize) $m]
											if {$jj >= 0} {						;#	IF ALREADY STORED, UPDATE NUMBER OF WORDS USED IN MATCHED PHRASE
												set phrascnt($n,$refgpsize) [lreplace $phrascnt($n,$refgpsize) $jj $jj $xx]
											} else {							;#	ELSE ADD TO PHRASE-REPETITIONS LIST
												lappend phrastor($n,$refgpsize) $m
												lappend phrascnt($n,$refgpsize) $xx
											}
										}

										;#	IF FOUND COMPLETE MATCH, MATCHING PHRASE NEED NOT ITSELF BE USED AS A REFERENCE PHRASE
										;#	SO ADD TO LIST OF REFERENCE PHRASES TO EXCLUDE FROM ONGOING SEARCH

										if {$xx == $refgpsize} {
											lappend matches_made $m
										}
									}
									incr xx
								}
								incr m
							}
							incr n
						}
						incr refgpsize
					}
					set lastsort [list $tstats_phraselen $tstats_upto $tstats_exact]
					catch {unset stats_preseematches}
				}
				catch {unset lines}
				catch {unset frqs}
				foreach phrasnam [array names phrastor] {
					set phrasindex [split $phrasnam ","]
					set phrasstt [lindex $phrasindex 0]
					set phraslen [lindex $phrasindex 1]
					set phrasend [expr $phrasstt + $phraslen - 1]
					set phrase [lrange $propwords $phrasstt $phrasend]
					set frq [llength $phrastor($phrasnam)]
					incr frq
					lappend lines($phraslen) $phrase
					lappend frqs($phraslen) $frq
					lappend phris($phraslen) $phrasindex 
				}
				if {($tstats_disp == 3) || ($tstats_disp == 4)} {
					set lines(0) {}
					set frqs(0) {}
					set phrasnams {}
					set n $minrefgpsize
					while {$n <= $tstats_phraselen} {
						if {![info exists lines($n)]} { 
							incr n
							continue
						}
						set lines(0) [concat $lines(0) $lines($n)]
						set frqs(0)  [concat $frqs(0) $frqs($n)]
						set phris(0) [concat $phris(0) $phrasnams($n)]
						incr n
					}
					set n 0
					set counter 0
				} else {
					set n $minrefgpsize
					set counter $tstats_phraselen
				}
				switch -- $tstats_disp {
					1 { set tstats_typ 1}
					2 { set tstats_typ 2}
					3 { set tstats_typ 1}
					4 { set tstats_typ 2}
				}
				while {$n <= $counter} {
					if {![info exists lines($n)]} { 
						incr n
						continue
					}
					set len [llength $lines($n)]
					set len_less_one [expr $len - 1]
					set j 0
					while {$j < $len_less_one} {
						set phras_j [lindex $lines($n) $j]
						set freq_j  [lindex $frqs($n)  $j]
						set nam_j   [lindex $phris($n) $j]
						set k $j
						incr k
						while {$k < $len} {
							set phras_k [lindex $lines($n) $k]
							set freq_k  [lindex $frqs($n)  $k]
							set nam_k   [lindex $phris($n) $k]
							switch -- $tstats_typ {
								1 {	;#	ALPHABETIC
									if {[string compare $phras_k $phras_j] < 0} {
										set lines($n) [lreplace $lines($n) $j $j $phras_k]
										set lines($n) [lreplace $lines($n) $k $k $phras_j]
										set frqs($n)  [lreplace $frqs($n)  $j $j $freq_k]
										set frqs($n)  [lreplace $frqs($n)  $k $k $freq_j]
										set phris($n) [lreplace $phris($n) $j $j $nam_k]
										set phris($n) [lreplace $phris($n) $k $k $nam_j]
										set phras_j $phras_k
										set freq_j  $freq_k
										set nam_j   $nam_k
									}
								}
								2 {	;#	BY FREQUENCY
									if {$freq_j < $freq_k} {
										set lines($n) [lreplace $lines($n) $j $j $phras_k]
										set lines($n) [lreplace $lines($n) $k $k $phras_j]
										set frqs($n)  [lreplace $frqs($n)  $j $j $freq_k]
										set frqs($n)  [lreplace $frqs($n)  $k $k $freq_j]
										set phris($n) [lreplace $phris($n) $j $j $nam_k]
										set phris($n) [lreplace $phris($n) $k $k $nam_j]
										set phras_j $phras_k
										set freq_j  $freq_k
										set nam_j   $nam_k
									}
								}
							}
							incr k
						}
						incr j
					}
					incr n
				}
				UnBlock
				$tstats delete 0 end
				if {($tstats_disp == 3) || ($tstats_disp == 4)} {
					set n 0
				} else {
					set n $minrefgpsize
				}
				set going 0
				set linecnt 0
				catch {unset ts_linindeces}
				while {$n <= $counter} {
					if {![info exists lines($n)]} { 
						incr n
						continue
					}
					if {$going} {
						$tstats insert end ""
						incr linecnt
					}
					switch -- $n {
						0 {
							$tstats insert end "MATCHED PHRASES"
							incr linecnt
						}
						1 {
							$tstats insert end "MATCH $n WORD"
							incr linecnt
							set going 1
						}
						default {
							$tstats insert end "MATCH $n WORDS"
							incr linecnt
						}
					}
					$tstats insert end ""
					incr linecnt
					foreach line $lines($n) freq $frqs($n) phri $phris($n) {
						set outline $freq
						if {$tstats_phraselen == 1} {
							append outline "  " [GetWordEquiv $line]
						} else {
							append outline "  " $line
						}
						$tstats insert end $outline
						lappend ts_linindeces [concat $linecnt $phri]
						incr linecnt
					}
					incr n
				}
				if {$tstats_phraselen == 1} {
					$f.7.ll config -text "Sounds With Highlighted Word "
				} else {
					$f.7.ll config -text "Sounds With Highlighted Phrase "
				}
				$f.7.e config  -text "To Chosen Files List" -command "SelectSndsWithTextPropSpecified 0" -bd 2
				$f.7.e2 config -text "To New Props File" -command "SelectSndsWithTextPropSpecified 1" -bd 2
				set newnewequiv 0
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

#----- Extract all the words in the consecutive "text" property entries in a properties file, as a list.

proc ExtractWordlist {propfile} {
	global props_info textanal_snds propwords propwordpos gotpropwords ts_props_list ts_propnames evv

	;#	GET PROPNAMES AND PROPERTY LINES FROM PROPFILE

	Block "EXTRACTING WORDS FROM TEXT PROPERTY"
	if {![ThisIsAPropsFile $propfile 1 0]} {
		UnBlock
		return 0
	}
	set ts_propnames [lindex $props_info 0]
	set ts_props_list [lindex $props_info 1]
	set len [llength $ts_propnames]
	set n 0
	set m 1
	foreach nam $ts_propnames {
		if {[string match [string tolower $nam] "text"]} {
			break
		}
		incr n
		incr m
	}
	if {$n == $len} {
		Inf "No \"Text\" Property In This Property File"
		UnBlock
		return 0
	}
	catch {unset propwords}
	catch {unset propwordpos}
	catch {unset textanal_snds}

	;#	GET WORDS (INDEXED TO SOURCE SND) FROM 'TEXT' PROPERTY
	set n 0
	foreach propline $ts_props_list {
		lappend textanal_snds [lindex $propline 0]
		set thistext [lindex $propline $m]
		if [string match $thistext $evv(NULL_PROP)] {
			lappend propwords $evv(NULL_PROP)
			lappend propwordpos $n
		} else {
			set thesewords [GetWordsFromTextPropString $thistext]
			foreach word $thesewords {
				lappend propwords $word
				lappend propwordpos $n
			}
		}
		incr n
	}
	set gotpropwords $propfile
	UnBlock
	return 1
}

#---- Remove word-separators from text-property string and return individual words

proc GetWordsFromTextPropString {text} {
	global evv
	set thesewords {}
	set len [string length $text]
	set n 0
	set wordstart 0
	while {$n < $len} {
		if {[string match [string index $text $n] $evv(TEXTJOIN)]} {
			set wordend [expr $n - 1]
			if {$wordend < $wordstart} {
				incr wordstart
			} else {
				lappend thesewords [string tolower [string range $text $wordstart $wordend]]
				set wordstart $n
				incr wordstart
			}
		}
		incr n
	}
	if {$wordstart < $len} {
		lappend thesewords [string tolower [string range $text $wordstart end]]
	}
	return $thesewords
}
 
#----- Do two words match (assumes wrods in lower case) ??

proc WordMatch {ref comp} {
	global homonym
	if {[string match $ref $comp]} {
		return 1
	}
	if [info exists homonym($ref)] {
		foreach item $homonym($ref) {
			if {[string match $item $comp]} {
				return 1
			}
		}
	}
	return 0
}

#---- Use up and down arrows to incr and decr length of phrases being examined

proc IncrTstatsPhraselen {up} {
	global tstats_phraselen evv
	if {$up} {
		set x [expr $tstats_phraselen + 1]
		if {$x > $evv(MAX_STATSPHRASE)} {
			return
		}
	} else {
		set x [expr $tstats_phraselen - 1]
		if {$x < 1} {
			return
		}
	}
	set tstats_phraselen $x
}

#---- If matching is not exact, set flag to enable button to see phrases that have been matched

proc SetupSeeStatsMatches {} {
	global tstats_exact tstats_seematches tstats_phraselen tstats
	switch -- $tstats_exact  {
		0 {
			if {$tstats_phraselen == 1} {
				.tstats.4.see config -bd 2 -text "Choose Sound Equivalents" -command TextHomonyms
				.tstats.4.ass config -bd 2 -text "Equivalent to Which word" -command AssignHomonyms -width 23
				.tstats.4.sav config -bd 2 -text "Save Equivalent Words" -command SaveHomonyms -width 23
				.tstats.5 config -text "Press \"Choose Sound Equivalents\" button : Then select words with mouse-Clicks"
				.tstats.6 config -text "Then Press \"Equivalent to Which word\" button : and select ONE word to associate equivalents with"
			} else {
				.tstats.4.see config -bd 0 -text "" -command {}
				.tstats.4.ass config -bd 2 -text "See Matching Phrases" -command SeeStatsMatches
				.tstats.4.sav config -bd 0 -text "" -command {}
				.tstats.5 config -text ""
				.tstats.6 config -text ""
				bind $tstats <ButtonRelease-1> {}
			}
		}
		1 {
			if {$tstats_phraselen == 1} {
				.tstats.4.see config -bd 2 -text "Choose Sound Equivalents" -command TextHomonyms
				.tstats.4.ass config -bd 2 -text "Equivalent to Which word" -command AssignHomonyms -width 23
				.tstats.4.sav config -bd 2 -text "Save Equivalent Words" -command SaveHomonyms -width 23
				.tstats.5 config -text "Press \"Choose Sound Equivalents\" button : Then select words with mouse-Clicks"
				.tstats.6 config -text "Then Press \"Equivalent to Which word\" button : and select ONE word to associate equivalents with"
			} else {
				.tstats.4.see config -bd 0 -text "" -command {}
				.tstats.4.ass config -bd 0 -text "" -command {}
				.tstats.4.sav config -bd 0 -text "" -command {}
				.tstats.5 config -text ""
				.tstats.6 config -text ""
				bind $tstats <ButtonRelease-1> {}
			}
		}
	}
}

#---- See phrases that have been matched, where matching is not exact

proc SeeStatsMatches {} {
	global tstats stats_preseematches propwords phrastor phrascnt
	bind $tstats <ButtonRelease-1> {}
	catch {unset stats_preseematches}
	foreach line [$tstats get 0 end] {
		lappend stats_preseematches $line
	}
	$tstats delete 0 end
	foreach phrasnam [array names phrastor] {
		set phrasindex [split $phrasnam ","]
		set phrasstt [lindex $phrasindex 0]
		set phraslen [lindex $phrasindex 1]
		set phrasend [expr $phrasstt + $phraslen - 1]
		set refphrase [lrange $propwords $phrasstt $phrasend]
		set line "MATCH FOR "
		append line $refphrase " :"
		$tstats insert end $line
		foreach phrasstt $phrastor($phrasnam) phraslen $phrascnt($phrasnam) {
			set phrasend [expr $phrasstt + $phraslen - 1]
			set phrase [lrange $propwords $phrasstt $phrasend]
			lappend phrases $phrase
		}
		set phrases [EliminateDuplicatePhrases $phrases]
		foreach phrase $phrases {
			$tstats insert end $phrase
		}
		unset phrases
	}
	.tstats.4.ass config -bd 2 -text "Restore Stats" -command UnSeeStatsMatches
	.tstats.7.ll config -text ""
	.tstats.7.e config -text "" -command {} -bd 0
	.tstats.7.e2 config -text "" -command {} -bd 0
}

#---- Go back to normal tstats display after a listing of matching phrases

proc UnSeeStatsMatches {} {
	global tstats stats_preseematches tstats_phraselen
	$tstats delete 0 end
	if {[info exists stats_preseematches]} {
		foreach line $stats_preseematches {
			$tstats insert end $line
		}
	}
	.tstats.4.see config -bd 0 -text "" -command {}
	.tstats.4.ass config -bd 2 -text "See Matching Phrases" -command SeeStatsMatches
	.tstats.4.sav config -bd 0 -text "" -command {}
	.tstats.7.ll config -text "Sounds With Highlighted Phrase "
	.tstats.7.e config -text "To Chosen Files List" -command "SelectSndsWithTextPropSpecified 0" -bd 2
	.tstats.7.e2 config -text "To New Props File" -command "SelectSndsWithTextPropSpecified 1" -bd 2
}

#---- Eliminate duplicates in a list of phrases (phrase = list of words)

proc EliminateDuplicatePhrases {phrases} {

	set len [llength $phrases]
	if {$len < 2} {
		return $phrases
	}
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set phras_n [lindex $phrases $n]
		set wlen [llength $phras_n]  
		set m $n
		incr m
		while {$m < $len} {
			set phras_m [lindex $phrases $m]
			if {[llength $phras_m] == $wlen} {
				set wcnt 0
				foreach word_n $phras_n word_m $phras_m {
					if {![string match $word_n $word_m]} {
						break
					}
					incr wcnt
				}
				if {$wcnt == $wlen} {
					set phrases [lreplace $phrases $m $m]
					incr m -1
					incr len -1
					incr len_less_one -1
				}
			}
			incr m
		}
		incr n
	}
	return $phrases
}

#---- Various Functions to connect a set of words to (as equivalents to) a base word.

proc TextHomonyms {} {
	global tstats
	bind $tstats <ButtonRelease-1> {}
	bind $tstats <ButtonRelease-1> {SelectTextEquivalentWord}
}

proc AssignHomonyms {} {
	global tstats equivwords
	if {![info exists equivwords]} {
		Inf "NO WORDS SELECTED"
		return
	}
	bind $tstats <ButtonRelease-1> {}
	bind $tstats <ButtonRelease-1> {AssignTextEquivalentWords}
}

proc SelectTextEquivalentWord {} {
	global equivwords tstats
	set i [$tstats curselection]
	if {$i < 0} {
		Inf "No Word Selected"
		return
	}
	set line [$tstats get $i]
	if {([string length $line] <= 0) || [string match [string range $line 0 4] "MATCH"]} {
		Inf "No Word Selected"
		return
	}
	set line [split $line]
	set word [lindex $line end]
	if {[info exists equivwords] && ([lsearch $equivwords $word] >= 0)} {
		Inf "'$word' Has Already Been Selected"
		return
	}
	lappend equivwords $word
}

proc AssignTextEquivalentWords {} {
	global equivwords homonym wstk tstats newequiv newnewequiv pr_tstats
	if {![info exists equivwords]} {
		Inf "No Words Selected"
		return
	}
	set i [$tstats curselection]
	if {$i < 0} {
		Inf "No Word Selected"
		return
	}
	set line [$tstats get $i]
	if {([string length $line] <= 0) || [string match [string range $line 0 4] "MATCH"]} {
		Inf "No Word Selected"
		return
	}
	set line [split $line]
	set word [lindex $line end]
	set k [lsearch $equivwords $word]
	if {$k >= 0} {
		set equivwords [lreplace $equivwords $k $k]
		if {[llength $equivwords] == 0} {
			Inf "No Words (Other Than The Associated Word '$word') Have Been Chosen"
			catch {unset equivwords}
			return
		}
	}
	if {[info exists homonym($word)]} {
		set len [llength $equivwords]
		set origlen $len
		set n 0
		while {$n < $len} {
			set eword [lindex $equivwords $n]
			if {[lsearch $homonym($word) $eword] >= 0} {
				set equivwords [lreplace $equivwords $n $n]
				incr len -1
				if {$len == 0} {
					Inf "These Words Are Already Equivalents"
					return
				}
			} else {
				incr n
			}
		}
		if {$len < $origlen} {
			Inf "Some Of These Words Are Already Equivalents"
		}
	} 
	set msg "Associate\n$equivwords\nWith\n$word ??"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		set msg "Abandon These Words ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			unset equivwords
		}
		return
	}

	if [info exists homonym($word)] {
		set homonym($word) [concat $homonym($word) $equivwords]
	} else {
		set testword [GetWordEquiv $word]
		if {![string match $testword $word]} {
			Inf "\"$word" Is Already Equivalent To \"$testword\""
			return
		} else {
			set homonym($word) $equivwords
		}
	}
	catch {unset equivwords}
	set newequiv 1
	set newnewequiv 1
	.tstats.9 config -text "Edit List of Word Equivalents" -command EditHomonyms -bd 2
	set pr_tstats 1
}

#--- Save listing of sound-equivalents words to permanent file storage

proc SaveHomonyms {} {
	global evv homonym newequiv
	if {![info exists homonym]} {
		Inf "No Sound Equivalents To Save"
		return 0
	}
	if {!$newequiv} {
		Inf "No New Sound Equivalents To Save"
		return 0
	}
	set fnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Open Temporary File '$fnam'	To Store Sound Equivalents\nCannot Store New Equivalents"
		return 0
	}
	foreach nam [array names homonym] {
		set line [concat $nam $homonym($nam)]
		puts $zit $line
	}
	close $zit
	set equivfile [file join $evv(URES_DIR) $evv(WORDEQUIV)]
	set emergencysave "The New Data Is Stored In File '$fnam' In Directory [pwd]\n\n"
	append emergencysave "To Retain It, Rename It Now, Outside The Sound Loom, Before Quitting This Dialog Box."
	if [file exists $equivfile] {
		if [catch {file delete $equivfile} zit] {
			set msg "Cannot Delete Existing Sound Equivalents File.\n\n"
			append emergencysave
			Inf $msg
		}
	}
	if [catch {file rename $fnam $equivfile} zit] {
		set msg "Cannot Rename Sound Equivalents File To '$equivfile'.\n\n"
		append emergencysave
		Inf $msg
	}
	set newequiv 0
	Inf "Sound Equivalents Saved"
	return 1
}

#--- Load listing of sound-equivalents words from permanent file storage

proc LoadHomonyms {} {
	global evv homonym wstk
	set equivfile [file join $evv(URES_DIR) $evv(WORDEQUIV)]
	if {![file exists $equivfile]} {
		return 1
	}
	if [catch {open $equivfile "r"} zit] {
		set msg "Cannot Open Existing Sound Equivalents File '$equivfile' To Read Data"
		append msg "\n\nDo You Want To Proceed ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return 0
		}
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[llength $line] > 0} {
			lappend elist $line
		}
	}
	close $zit
	if {[info exists elist]} {
		foreach line $elist {
			set line [string trim $line]
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt == 0} {
					set nam $item
				} else {
					lappend homonym($nam) $item
				}
				incr cnt
			}
		}
	}
	return 1
}

#--- Edit listing of sound-equivalents words

proc EditHomonyms {} {
	global equivalents_loaded homonym wstk pr_weedit eqbas eqlst eq_bas eq_bas_i wstk newequiv evv

	if {!$equivalents_loaded} {
		if {![LoadHomonyms]} {
			return
		}
	}
	set f .weedit
	if [Dlg_Create $f "EDIT SOUND EQUIVALENTS" "set pr_weedit 0" -width 60 -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		set f3 [frame $f.3]
		button $f1.quit -text "Quit" -command {set pr_weedit 0} -width 10 -highlightbackground [option get . background {}]
		button $f1.del -text "Delete" -command {set pr_weedit 1} -width 10 -highlightbackground [option get . background {}]
		button $f1.save -text "Save Edits" -command {set pr_weedit 2} -width 10 -highlightbackground [option get . background {}]
		pack $f1.del $f1.save -side left -padx 2
		pack $f1.quit -side right
		pack $f1 -side top -fill x -expand true
		label $f2.tell1 -text "Select Word on Left List" -fg $evv(SPECIAL)
		label $f2.tell2 -text "Select Equivalents to Delete on Right Hand List" -fg $evv(SPECIAL)
		label $f2.tell3 -text "Confirm Deletion by pressing button" -fg $evv(SPECIAL)
		pack $f2.tell1 $f2.tell2 $f2.tell3 -side top
		pack $f2 -side top
		set eqbas [Scrolled_Listbox $f3.ll1 -width 24 -height 36 -selectmode single]
		set eqlst [Scrolled_Listbox $f3.ll2 -width 24 -height 36 -selectmode multiple]
		pack $f3.ll1 $f3.ll2 -side left
		pack $f3 -side top -fill both -expand true
		bind $eqbas <ButtonRelease-1> {EqList}
		wm resizable $f 1 1
		bind $f <Escape> {set pr_weedit 0}
	}
	$eqbas delete 0 end
	$eqlst delete 0 end
	foreach nam [array names homonym] {
		$eqbas insert end $nam
	}
	foreach nam [array names homonym] {
		set origequiv($nam) $homonym($nam)
	}
	raise $f
	update idletasks
	StandardPosition $f
	set eqedited 0
	set finished 0
	set pr_weedit 0
	My_Grab 0 $f pr_weedit
	while {!$finished} {
		tkwait variable pr_weedit
		switch -- $pr_weedit {
			1 {
				set ilist [$eqlst curselection] 
				if {(([llength $ilist] == 1) && ([lindex $ilist 0] == -1)) || ([llength $ilist] == 0)} {
					Inf "No Items Selected For Deletion"
					continue
				} elseif {![AreYouSure]} {
					continue
				}
				foreach i $ilist {
					set eq [$eqlst get $i]
					set k [lsearch $homonym($eq_bas) $eq]
					if {$k >= 0} {
						set eqedited 1
						$eqlst delete $i
						set homonym($eq_bas) [lreplace $homonym($eq_bas) $k $k]
						if {[llength $homonym($eq_bas)] <= 0} {
							unset homonym($eq_bas)
							$eqbas delete $eq_bas_i
						}
					}
				}
				if {[llength [array names homonym]] <= 0} {
					catch {unset homonym}
				}
			}
			2 {
				if {!$eqedited} {
					Inf "No Edits To Save"
					continue
				}
				if {![info exists homonym]} {
					set equivfile [file join $evv(URES_DIR) $evv(WORDEQUIV)]
					if [catch {file delete $equivfile} zit] {
						Inf "Cannot Delete Existing Sound Equivalents File."
					} else {
						.tstats.9 config -text "" -command {} -bd 0
					}
				} else {
					set orig_newequiv $newequiv
					set newequiv 1		
					if {![SaveHomonyms]} {
						set newequiv $orig_newequiv
						continue
					}
				}
				set finished 1
			}
			0 {
				if {$eqedited} {
					set msg "Abandon Edits ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					} else {
						catch {unset homonym}
						foreach nam [array names origequiv] {
							set homonym($nam) $origequiv($nam)
						}
					}
				}
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

#---- List sound equivalents of base-word selected

proc EqList {} {
	global eqbas eqlst homonym eq_bas eq_bas_i
	set i [$eqbas curselection]
	if {$i < 0} {
		return
	}
	set eq_bas_i $i
	set eq_bas [$eqbas get $i]
	$eqlst delete 0 end
	foreach word $homonym($eq_bas) {
		$eqlst insert end $word
	}
}

#------ Get sounds contanining selected word or phrase, put on Chosen List and return to Workspace

proc SelectSndsWithTextPropSpecified {tofile} {
	global tstats tstats_phraselen homonym propwords propwordpos ts_linindeces phrastor textanal_snds pr_tstats 
	global pr_tstatsout tstatsoutfnam ts_propfile props_info ts_props_list ts_propnames propfiles_list
	global wl chlist ch rememd wstk evv

	set i [$tstats curselection]
	if {$i < 0} {
		if {$tstats_phraselen == 1} {
			Inf "No Word Selected"
		} else {
			Inf "No Phrase Selected"
		}
		return
	}
	set sndnos {}
	if {$tstats_phraselen == 1} {
		set words [$tstats get $i]
		if {([string length $words] <= 0) || [string match [string range $words 0 4] "MATCH"]} {
			Inf "No Word Selected"
			return
		}
		set words [split $words]
		set words [lindex $words end]
		if [info exists homonym($words)] {
			set words [concat $words $homonym($word)]
		}
		foreach word $words {
			set len [llength $propwords]
			set startpos 0
			while {$startpos < $len} {
				set k [lsearch [lrange $propwords $startpos end] $word]
				if {$k >= 0} {
					set thissndno [lindex $propwordpos [expr $k + $startpos]]
					if {[lsearch $sndnos $thissndno] < 0} {
						lappend sndnos $thissndno
					}
					incr startpos $k
					incr startpos
				} else {
					break
				}
			}
		}
		if {[llength $sndnos] <= 0} {
			return
		}
	} else {
		foreach ts_linindex $ts_linindeces {
			lappend infolines [lindex $ts_linindex 0]
			set wordno		  [lindex $ts_linindex 1]
			set wordcnt		  [lindex $ts_linindex 2]
			lappend wordstts $wordno 
			lappend wordcnts $wordcnt
			lappend wordends [expr $wordno + $wordcnt - 1]
			set nam $wordno
			append nam "," $wordcnt
			lappend nams $nam
		}
		set k [lsearch $infolines $i]
		if {$k < 0} {
			Inf "No Phrase Selected"
			return
		}
		set wordstt [lindex	$wordstts $k]
		set wordend [lindex	$wordends $k]
		foreach thissndno [lrange $propwordpos $wordstt $wordend] {
			if {[lsearch $sndnos $thissndno] < 0} {
				lappend sndnos $thissndno
			}
		}
		set nam [lindex	$nams $k]
		set wordcnt [lindex	$wordcnts $k]
		if [info exists phrastor($nam)] {
			foreach wordstt $phrastor($nam) {
				set wordend [expr $wordstt + $wordcnt - 1]
				foreach thissndno [lrange $propwordpos $wordstt $wordend] {
					if {[lsearch $sndnos $thissndno] < 0} {
						lappend sndnos $thissndno
					}
				}
			}
		}
		if {[llength $sndnos] <= 0} {
			return
		}
	}
	set sndnos [lsort -integer -increasing $sndnos]
	foreach i $sndnos {
		lappend snds [lindex $textanal_snds $i]
	}
	if {[string match $tofile "0"]} {
		set n 0
		set len [llength $snds]
		while {$n < $len} {	
			set fnam [lindex $snds $n]
			if {[LstIndx $fnam $wl] < 0} {
				if {![file exists $fnam]} {
					set snds [lreplace $snds $n $n]
					incr len -1
				} elseif {[FileToWkspace $fnam 0 0 0 0 0] <= 0} {
					set snds [lreplace $snds $n $n]
					incr len -1
				} else {
					incr n
				}
			} else {
				incr n
			}
		}
		if {[llength $snds] > 0} {
			DoChoiceBak
			set chlist $snds
			$ch delete 0 end
			foreach fnam $chlist {
				$ch insert end $fnam
			}
			set pr_tstats 0
		} else {
			Inf "Cannot Get Any Of These Sounds To The Workspace"
		} 
		return
	}
	set f .tstatsout
	if [Dlg_Create $f "OUTPUT SNDS WITH TEXT" "set pr_tstatsout 0" -width 60 -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		button $f1.quit -text "Quit" -command {set pr_tstatsout 0} -width 10 -highlightbackground [option get . background {}]
		button $f1.wr -text "Write To File" -command {set pr_tstatsout 1} -width 10 -highlightbackground [option get . background {}]
		pack $f1.wr -side left
		pack $f1.quit -side right
		pack $f1 -side top -fill x -expand true
		label $f2.ll -text "Outfile Name "
		entry $f2.e -textvariable tstatsoutfnam -width 16
		pack $f2.ll $f2.e -side left
		pack $f2 -side top -fill both -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_tstatsout 1}
		bind $f <Escape> {set pr_tstatsout 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_tstatsout 0
	My_Grab 0 $f pr_tstatsout
	while {!$finished} {
		tkwait variable pr_tstatsout
		if {$pr_tstatsout} {
			if {[string length $tstatsoutfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $tstatsoutfnam]} {
				continue
			}
			set outfnam [string tolower $tstatsoutfnam]
			append outfnam [GetTextfileExtension props]
			if {[string match $ts_propfile $outfnam]} {
				Inf "You Cannot Overwrite The Input Property File Here"
				continue
			}
			if {[file exists $outfnam]} {
				set msg "File '$outfnam' Already Exists: Append This Data To It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set orig_props_info $props_info
					if {![ThisIsAPropsFile $outfnam 0 0]} {
						Inf "'$outfnam' Is Not A Properties File"
						set props_info $orig_props_info
						continue
					}
					set orig_ts_propnames [lindex $props_info 0]
					set orig_ts_props_list [lindex $props_info 1]
					set props_info $orig_props_info
					set OK 1
					foreach nam $ts_propnames orignam $orig_ts_propnames {
						if {![string match $nam $orignam]} {
							Inf "Properties In File '$outfnam' Do Not Correspond To Properties Of New Sounds"
							set OK 0
							break
						}
					}
					if {!$OK} {
						continue
					}
					catch {unset orig_snds}
					foreach line $orig_ts_props_list {
						lappend orig_snds [lindex $line 0]
					}
					set len [llength $snds]
					set n 0
					while {$n < $len} {
						set thissnd  [lindex $snds $n]
						if {[lsearch $orig_snds $thissnd] >= 0} {
							set snds [lreplace $snds $n $n]
							set sndnos [lreplace $sndnos $n $n]
							incr len -1
						} else {
							incr n
						}
					}
					if {$len <= 0} {
						Inf "All These Sounds Are Already In File '$outfnam'"
						break
					}
					catch {unset nu_props_list}
					foreach line $orig_ts_props_list {
						lappend nu_props_list $line
					}
					foreach lineno $sndnos {
						lappend nu_props_list [lindex $ts_props_list $lineno]
					}
					set tmpfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
					if [catch {open $tmpfnam w} zit] {
						Inf "Cannot Open Temporary File To Store Enlarged Properties Listing."
						continue
					}
					puts $zit $ts_propnames
					foreach line $nu_props_list {
						puts $zit $line
					}
					close $zit
					set i [LstIndx $outfnam $wl]
					if {![DeleteFileFromSystem $outfnam 0 1]} {
						set msg "Cannot Delete Original File '$outfnam'"
						append msg "\n\nThe New Data Is In File '$tmpfnam'"
						append msg "\n\nRename This File, Outside The CDP, Before Quitting This Dialogue Box"
						Inf $msg
					} else {
						DummyHistory $outfnam "DESTROYED"
						if {[info exists propfiles_list]} {
							set k [lsearch $propfiles_list $outfnam]
							if {$k > 0} {
								set propfiles_list [lreplace $propfiles_list $k $k]
							}
						}
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
						if [catch {file rename $tmpfnam $outfnam} zit] {
							set msg "Cannot Rename Appended Properties Files To '$outfnam'"
							append msg "\n\nThe New Data Is In File '$tmpfnam'"
							append msg "\n\nRename This File, Outside The CDP, Before Quitting This Dialogue Box"
							Inf $msg
						}
					}
					FileToWkspace $outfnam 0 0 0 0 1
					Inf "File '$outfnam' Is On The Workspace"
					set finished 1
				} else {
					set msg "Overwrite Existing Property File '$outfnam' ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnam $wl]
					if {![DeleteFileFromSystem $outfnam 0 1]} {
						Inf "Cannot Delete Existing File '$outfnam'"
						continue
					} else {
						DummyHistory $outfnam "DESTROYED"
						if {[info exists propfiles_list]} {
							set k [lsearch $propfiles_list $outfnam]
							if {$k > 0} {
								set propfiles_list [lreplace $propfiles_list $k $k]
							}
						}
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
			}
			if {!$finished} {
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot Create File '$outfnam' To Write Data"
					continue
				}
				puts $zit $ts_propnames
				foreach lineno $sndnos {
					puts $zit [lindex $ts_props_list $lineno]
				}
				close $zit
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "File '$outfnam' Is On The Workspace"
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#----- If word in reference phrase is equivalent to another, set it to that word

proc GetWordEquiv {word} {
	global homonym
	if [info exists homonym] {
		foreach nam [array names homonym] {
			if {[lsearch $homonym($nam) $word] >= 0} {
				return $nam
			}

		}
	}
	return $word
}

#------ Extract phrases corresponding in varying degrees to an input text from Table Display

proc AnalyseTextPropertyWordDataFromTable {tofile} {
	global equivalents_loaded getsndprpv tp_props_list proppos propaud_tfil propaud_snds wstk evv 
	global chlist ch pr_prselsnd pr_proptab propaudmin propaudfrac propaud_frac tp_propnames
	global propaud_nu_snds propaud_nu_tfil propaudtstats

	set propaudtstats 0
	if {!$equivalents_loaded} {
		if {![LoadHomonyms]} {
			return
		}
		set equivalents_loaded 1
	}
	if {[string first "_" $getsndprpv] >= 0} {
		Inf "You Cannot Use Underscores (\"_\") In The Text Property"
		return
	}
	Block "COMPARING TEXTS"

		;#	ESTABLISH THE REFERENCE PHRASE AS A LIST OF WORDS

	set propaud_tfil {}
	set refphrase {}
	set words [split $getsndprpv]
	foreach word $words {
		set word [string trim $word]
		if {[string length $word] > 0} {
			lappend refphrase [string tolower $word]
		}
	}
	set refgpsize [llength $refphrase]	;#	SIZE OF FIRST GROUPS TO BE COMPARED IS FULL PHRASE-SIZE SPECIFIED

	set propfilelen [llength $tp_props_list]
	set n 0

			;#	FOR EVERY INPHRASE FROM THE TEXT PROPERTY OF THE SOUNDS

	while {$n < $propfilelen} {
		set propline [lindex $tp_props_list $n]
		set inphrase [lindex $propline $proppos]
		if {[string match $inphrase $evv(NULL_PROP)]} {
			incr n
			continue
		}
		set inphrase [PropsStripUnderscores $inphrase]
		set inphrase [split $inphrase]

		set inlen  [llength $inphrase]
		set matchmade 0

			;#	IF THE inphrase IS NO LONGER THAN THE refphrase

		if {$inlen <= $refgpsize} {

			;#	SET MIN NO OF WORDS FOR A POSSIBLE MATCH, (FROM ENTERED PROPERTY propaudmin .... RANGE (1 - refgpsize)

			set xx $refgpsize
			if {($refgpsize > 1) && ($propaudmin < $refgpsize)} {	;#	Inexact comparison can take place if wordlen > 1
				set xx $propaudmin
			}
			;#	GET PHRASES OF LENGTH FROM MIN TO MAX, FROM THE inphrase
		
			while {$xx <= $refgpsize} {
				set lim [expr $inlen - $xx]

				;#	AND STARTING AT EACH SUCCESSIVE WORD IN THE inphrase

				set m 0
				while {$m <= $lim} {
					set j $m
					set cnt 0

				;#	ASSEMBLE THE COMPARISON PHRASE FROM WITHIN inphrase

					catch {unset phrase}
					while {$cnt < $xx} {
						lappend phrase [lindex $inphrase $j]
						incr j
						incr cnt
					}
					set OK 1
					set xphraslen $refgpsize
					set kk 0
				
					;#	COMPARE SUCCESSIVE SEGMENTS OF REFPHRASE (abcde bcde cde de e) TO AVOID BADMATCHES HALTING COMPARISON BEFORE WE GET TO A MATCH

					while {$xphraslen >= $xx} {
						set refrefphrase [lrange $refphrase $kk end]
						set OK 1

							;#	CALCULATE MIN OF BADMATCHES NEEDED TO BE CERTAIN PHRASES CAN'T MATCH, USING INPUT PARAM propaud_frac

						set badmatchespossible 0
						if {$propaud_frac} {
							set frac [expr 1.0/double($propaud_frac)]
							set badmatchespossible [expr int(floor(double($xphraslen) * $frac))]
						}
						set badmatches 0
						set cnt 0
						set cntref 0
						set goodmatches 0

							;#	COMPARE THE PHRASES

						while {$cntref < $xphraslen} {
							set phrasword	 [lindex $phrase $cnt]
							set refphrasword [lindex $refrefphrase $cntref]
							set refphrasword [GetWordEquiv $refphrasword]	;#	IF REF WORD EQUIV TO SOME OTHER WORD, USE THAT WORD INSTEAD.
							if {![WordMatch $refphrasword $phrasword]} {	;#	WordMatch LOOKS AT ANY LIST OF WORDS EQUIVALENT TO REF WORD,
								if {$cntref == 0} {							;#	IN ADDITION TO SIMPLY MATCHING ACCORDING TO THE SET CRITERIA....
									set OK 0
									break									;#	1ST WORD MUST MATCH
								} elseif {$cntref == [expr $refgpsize - 1]} {
									set OK 0
									break									;#	AND LAST WORD MUST MATCH
								} else {
									incr badmatches							;#	IF TOO MANY BADMATCHES, GO TO NEXT (SHORTER) SEGMENT OF refprase
									if {$badmatches > $badmatchespossible} {;#	LOSING CHRACTERS FROM START OF refphrase	
										set OK 0
										break								
									}
									incr cnt -1				;#	IF A BADMATCH, PREVENT MOVING UP inphrase, WHILE CONTINUING TO MOVE UP refphrase
								}							;#	SO CHARACTERS ARE BEING SKIPPED IN THE refphrase
							} else {
								incr goodmatches
								if {$goodmatches == $xx} {					;#	IF SUFFICIENT GOODMATHCES FOUND break (LEAVING OK = 1)
									break
								}
							}
							incr cntref										;#	ADVANCE ALONG THE PHRASES BEING COMPARED
							incr cnt
							if {$cnt >= $xx} {								;#	IF AT END OF SHORTER GROUP, QUIT, EVEN IF NOT AT END OF REF GROUP
								break
							}
						}
						if {$OK} {											;#	IF A MATCH HAS BEEN FOUND, break FROM OUTER, refphrase SHORTENING, LOOP
							break
						}
						incr kk												;#	OTHERWISE, SHORTEN refphrase, REMOVING CHARS FROM ITS START
						incr xphraslen -1
					}
					if {$OK} {	;#	FOUND A MATCH
						lappend propaud_tfil $n
						lappend propaud_snds [lindex $propline 0]
						set matchmade 1
						break
					}
					incr m
				}
				if {$matchmade} {
					break
				}
				incr xx
			}
		} else {

			;#	WHERE THE inphrase IS LONGER THAN THE refphrase, DO THE WHOLE PROCEDURE THE OTHER WAY AROUND

			;#	SET MIN NO OF POSSIBLE MATCHING WORDS BASED ON inphrase LENGTH

			set xx $inlen
			if {($refgpsize > 1) && ($propaudmin < $refgpsize)} {	;#	Inexact comparison can take place if wordlen > 2
				set xx $propaudmin
			}
				;#	GET PHRASES OF LENGTH FROM MIN TO MAX, FROM THE refphrase

			while {$xx <= $inlen} {
				set lim [expr $refgpsize - $xx]

				;#	STARTING AT EACH SUCCESSIVE WORD IN THE refphrase

				set m 0
				while {$m <= $lim} {

					set j $m
					set cnt 0

				;#	ASSEMBLE THE COMPARISON PHRASE FROM WITHIN refphrase

					catch {unset subrefphrase}
					while {$cnt < $xx} {
						lappend subrefphrase [lindex $refphrase $j]
						incr j
						incr cnt
					}
					set OK 1
					set xphraslen $inlen	;#	COMPARE abcde bcde cde de OF inphrase TO AVOID BADMATCHES KILLING COMPARE BEFORE GET TO MATCH
					set kk 0
					while {$xphraslen >= $xx} {
						set ininphrase [lrange $inphrase $kk end]
						set OK 1
						set badmatchespossible 0
						if {$propaud_frac} {
							set frac [expr 1.0/double($propaud_frac)]
							set badmatchespossible [expr int(floor(double($xphraslen) * $frac))]
						}
						set badmatches 0
						set cnt 0
						set cntref 0
						set goodmatches 0
						while {$cntref < $xphraslen} {
							set refphrasword [lindex $subrefphrase $cnt]
							set phrasword	[lindex $ininphrase $cntref]
							set phrasword [GetWordEquiv $phrasword]
							if {![WordMatch $phrasword $refphrasword ]} {
								if {$cnt == 0} {
									set OK 0
									break
								} elseif {$cnt == [expr $xx - 1]} {
									set OK 0
									break
								} else {
									incr badmatches
									if {$badmatches > $badmatchespossible} {
										set OK 0
										break
									}
									incr cnt -1
								}
							} else {
								incr goodmatches
								if {$goodmatches == $xx} {
									break
								}
							}
							incr cntref
							incr cnt
							if {$cnt >= $xx} {
								break
							}
						}
						if {$OK} {
							break
						}
						incr kk
						incr xphraslen -1
					}
					if {$OK} {	;#	FOUND A MATCH
						lappend propaud_tfil $n
						lappend propaud_snds [lindex $propline 0]
						set matchmade 1
						break
					}
					incr m
				}
				if {$matchmade} {
					break
				}
				incr xx
			}
		}
		incr n
	}
	UnBlock
	if {[llength $propaud_tfil] <= 0} {
		Inf "No Matches Found"
		return
	}
	if {[llength $propaud_tfil] == 1} {
		set msg "No Other Sounds Match This Sound : Keep Just The Original Sound ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			catch {unset propaud_snds}
			catch {unset propaud_nu_snds}
			catch {unset propaud_tfil}
			catch {unset propaud_nu_tfil}
			return
		}
		if {![string match $tofile "0"]} {
			CreateSubPropfile $tofile $tp_propnames $propaud_tfil
		} else {
			DoChoiceBak
			set chlist $propaud_snds
			$ch delete 0 end
			foreach fnam $chlist {
				$ch insert end $fnam
			}
		}
		set pr_prselsnd 0
		set pr_proptab 0
		return
	}
	.prselsnd.3.same config -text "" -state disabled
	.prselsnd.3.incs config -text "" -state disabled
	.prselsnd.3.incd config -text "" -state disabled
	.prselsnd.3.incm config -text "" -state disabled
	.prselsnd.3.incb config -text "" -state disabled
	.prselsnd.3.this config -text ""
	.prselsnd.4.ml config -text ""
	set propaudmin ""
	.prselsnd.4.m  config -bd 0
	.prselsnd.4.fl config -text ""
	set propaudfrac ""
	.prselsnd.4.f  config -bd 0
	.prselsnd.1.a config -text "Keep All" -command {set pr_prselsnd 2} -bd 2
	.prselsnd.1.ll config -text "Listen & Select" -command {set pr_prselsnd 1} -bd 2
}	

#------ Get text data from property file (including sound-no of sound with each word

proc GetPropsDataFromFile {propfile} {
	global wl chlist gotpropwords propwords wstk pa evv
																			;#	IF NO PREVIOUS EXTRACTED DATA, OR NEW FILE SELECTED		
	if {![info exists gotpropwords] || ![string match $gotpropwords $propfile] || ![info exists propwords]} {
		if {![ExtractWordlist $propfile]} {									;#	ATTEMPT TO DO EXTRACTION
			return ""
		}
	}
	return $propfile
}

#################################################
# ASSONANCE (CONSONANT (CLUSTER) CONCENTRATIONS #
#################################################

proc TextPropertyConsonantStatistics {in_fnam} {
	global pr_constats constats_force constatchoice constatexclude constatstate constatsonly con_exclude ts_propfile
	global constats_disp constatcons constatexcons constatdens constatsmin constatsoutfnam constatistics constattexts constatsndnos
	global ts_props_list props_info ts_propnames propfiles_list phonames phoncnts laststatalpha zerophones totalconstats totalconstats_files
	global wl chlist ch wstk rememd readonlyfg readonlybg pa evv

	set propsfile [GetPropsDataFromFile $in_fnam]
	if {[string length $propsfile] <= 0} {
		return
	}
	set ts_propfile $propsfile 
	set constats_force 0
	set constatsonly 0
	set con_exclude 0
	set constatchoice {}
	set constatexclude {}
	set zerophones {}
	catch {unset phonames}
	catch {unset phoncnts}
	set f .constats
	if [Dlg_Create $f "STATISTICS OF CONSONANT (CLUSTERS) IN PROPERTIES FILE [file tail $propsfile]" "set pr_constats 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f0a [frame $f.0a -height 1 -bg black]
		set f1 [frame $f.1]
		set f1a [frame $f.1a -height 1 -bg black]
		set f2 [frame $f.2]
		set f2a [frame $f.2a -bg $evv(POINT) -height 1]
		set f3 [frame $f.3]
		set f3a [frame $f.3a -bg $evv(POINT) -height 1]
		set f4 [frame $f.4]
		set f5 [frame $f.5]
		button $f0.quit -text "Quit" -command {set pr_constats 0} -width 10 -highlightbackground [option get . background {}]
		button $f0.help -text "Help" -command ConstatsHelp -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f0.force -text "Force Reanalysis" -command {set constats_force 1} -width 16 -highlightbackground [option get . background {}]
		label $f0.updn -text "Up/Down Arrows change \"min items\" : L/R Arrows change \"Density\"" -fg $evv(SPECIAL)
		pack $f0.help $f0.force $f0.updn -side left
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		pack $f0a -side top -fill x -expand true -pady 2
		
		button $f1.stat -text "See Statistics" -command {set pr_constats 1} -width 22
		radiobutton $f1.r1 -variable constats_disp -text "By Frequency" -value 0
		radiobutton $f1.r2 -variable constats_disp -text "Alphabetic" -value 1
		radiobutton $f1.r3 -variable constats_disp -text "Raw Alphabetic Data" -value 2
		pack $f1.stat $f1.r1 $f1.r2 $f1.r3 -side left -padx 2
		button $f1.save -text "Save Statistics" -command {set pr_constats 7} -width 18 -highlightbackground [option get . background {}]
		button $f1.totl -text "Add to Total Stats" -command {set pr_constats 8} -width 18 -highlightbackground [option get . background {}]
		pack $f1.totl $f1.save -side right -padx 2
		pack $f1 -side top -fill x -expand true -pady 2

		pack $f1a -side top -fill x -expand true -pady 2

		frame $f2.ser
		frame $f2.ser.1
		frame $f2.ser.2
		button $f2.ser.1.ser -text "Do High Density Search" -command {set pr_constats 2} -width 22 -highlightbackground [option get . background {}]
		label $f2.ser.1.strsl -text " For These Items "
		pack $f2.ser.1.ser -side left
		pack $f2.ser.1.strsl -side right
		pack $f2.ser.1 -side top -fill x -expand true
		radiobutton $f2.ser.2.r1 -variable con_exclude -text "include " -value 0 -command {ConExclude 0}
		radiobutton $f2.ser.2.r2 -variable con_exclude -text "exclude " -value 1 -command {ConExclude 1}
		label $f2.ser.2.not -text "but Not"
		pack $f2.ser.2.r1 $f2.ser.2.r2 -side left
		pack $f2.ser.2.not -side right
		pack $f2.ser.2 -side top -fill x -expand true

		frame $f2.entries
		frame $f2.entries.1
		frame $f2.entries.2
		entry $f2.entries.1.strs -textvariable constatcons  -width 24 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
		checkbutton $f2.entries.1.only -variable constatsonly -text "only" -command {ConstatsOnly}
		pack $f2.entries.1.strs $f2.entries.1.only -side left
		entry $f2.entries.2.exs -textvariable constatexcons -width 24 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
		pack $f2.entries.2.exs -side left
		pack $f2.entries.1 $f2.entries.2 -side top -fill x -expand true

		frame $f2.clr
		button $f2.clr.clr -text "Clear All" -command {ConstatsClearAll} -width 16 -highlightbackground [option get . background {}]
		button $f2.clr.exclr -text "Clear Exclusions" -command {ConstatsClearExcludes} -width 16 -highlightbackground [option get . background {}]
		pack $f2.clr.clr $f2.clr.exclr -side top -pady 2

		label $f2.minl  -text "Min Items in Gp"
		entry $f2.min  -textvariable constatsmin -width 4
		label $f2.densl -text "Min Density(0-1)"
		entry $f2.dens -textvariable constatdens -width 4
		pack $f2.ser $f2.entries $f2.clr $f2.minl $f2.min $f2.densl $f2.dens -side left -padx 2
		pack $f2 -side top -fill x -expand true -pady 2

		pack $f2a -side top -fill x -expand true -pady 2

		label $f3.out -text "" -width 15
		button $f3.snd -text "" -command {} -width 20 -bd 0 -highlightbackground [option get . background {}]
		button $f3.add -text "" -command {} -width 20 -bd 0 -highlightbackground [option get . background {}]
		label $f3.ll -text "" -width 9
		entry $f3.e -textvariable constatsoutfnam -width 16 -state readonly -bd 0 -fg $readonlyfg -readonlybackground $readonlybg
		button $f3.txt -text "" -command {} -width 20 -bd 0 -highlightbackground [option get . background {}]
		button $f3.prp -text "" -command {} -width 20 -bd 0 -highlightbackground [option get . background {}]
		pack $f3.out $f3.prp $f3.txt $f3.e $f3.ll $f3.snd $f3.add -side left -padx 2
		pack $f3 -side top -fill x -expand true -pady 2

		pack $f3a -side top -fill x -expand true -pady 2

		label $f4.l1 -text "" -fg $evv(SPECIAL)
		label $f4.l2 -text "" -fg $evv(SPECIAL)
		label $f4.l3 -text "" -fg $evv(SPECIAL)
		label $f4.l4 -text ""
		pack $f4.l1 $f4.l2 $f4.l3 $f4.l4 -side top
		pack $f4 -side top -pady 2

		set constatistics [Scrolled_Listbox $f5.ll -width 132 -height 40 -selectmode single]
		pack $f5.ll -side top -fill both -expand true
		pack $f5 -side top -pady 2
		bind $constatistics <ButtonRelease-1> {ConstatSelect %y 0}
		bind $f <Up> {ConstatMinChange 1}
		bind $f <Down> {ConstatMinChange 0}
		bind $f <Right> {ConstatDensChange 1}
		bind $f <Left> {ConstatDensChange 0}
		wm resizable $f 1 1
		bind $f <Escape> {set pr_constats 0}
	}
	$constatistics delete 0 end
	set constatstate 0
	set constatcons ""
	set constatdens "0.50"
	set constatsmin 3
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_constats 0
	My_Grab 0 $f pr_constats
	while {!$finished} {
		set constats_disp -1
		tkwait variable pr_constats
		switch -- $pr_constats {
			0 {
				set finished 1
			}
			1 {		;#	OCCURENCE ANALYSIS
				if {$constats_disp < 0} {
					if {[info exists phonames] && [info exists phoncnts] && [info exists laststatalpha]} {
						$constatistics delete 0 end
						if {$laststatalpha == 2} {
							foreach phoname $phonames {
								$constatistics insert end $phoname
							}
							set constatstate 1
						} else {
							foreach phoname $phonames phoncnt $phoncnts {
								set line $phoncnt
								append line "  " $phoname
								$constatistics insert end $line
							}
							set constatstate 2
						}
						.constats.4.l1 config -text "\"Phonetic\" representation of Consonants"
						.constats.4.l2 config -text "b  d  f  g  h  j  k  l  m  n  p  r  s  t  v  w  x  y  z"
						.constats.4.l3 config -text "C (=ch in arch)    X (=ch in loch)     S (=sh)     T (=th in lath)    7 (=th in that)     Z (=zh in occassion)     N(=ng as in ring)"
						.constats.4.l4 config -text "Select items for \"Search\" with mouse click"
						.constats.3.out config -text ""
						.constats.3.snd config -text "" -bd 0 -command {}
						.constats.3.add config -text "" -bd 0 -command {}
						.constats.3.ll config -text ""
						.constats.3.e config -bd 0 -state readonly -fg $readonlyfg -readonlybackground [option get . background {}]
						.constats.3.txt config -text "" -bd 0 -command {}
						.constats.3.prp config -text "" -bd 0 -command {}
						$constatistics config -selectmode single
						if {$con_exclude} {
							bind $constatistics <ButtonRelease-1> {ConstatSelect %y 1}
						} else {
							bind $constatistics <ButtonRelease-1> {ConstatSelect %y 0}
						}
					} else {
						Inf "No Display Type Specified"
					}
					continue
				}
				if {![DoConsonantStatistics $constats_disp $constats_force]} {
					continue
				} else {
					set constats_force 0
				}
			}
			2 {		;#	DENSITY ANALYSIS
				if {[llength $constatchoice] <= 0} {
					Inf "No Search Items Selected"
					continue
				}
				if {![IsNumeric $constatdens] || ($constatdens > 1) || ($constatdens < 0)} {
					Inf "Invalid Density Value"
					continue
				}
				if {![regexp {[0-9]+} $constatsmin] || ($constatsmin < 1)} {
					Inf "Invalid Number Of Minimum Items"
					continue
				}
				if {($constatsmin < 2) && ($constatdens > 0)} {
					Inf "For One Item Item Per Cluster, Density Reverts To Zero"
					set constatdens 0
				}

				if {![AnalyseTextPropertyConsonantDensity $constats_force $constatdens $constatsmin]} {
					continue
				} else {
					set constats_force 0
				}
			}
			3 {		;#	TEXTS TO FILE
				if {![info exists constattexts]} {
					Inf "No Texts Found To Store"
					continue
				}
				if {[string length $constatsoutfnam] <= 0} {
					Inf "No Outfile Name Entered"
					continue
				}
				set outfnam [string tolower $constatsoutfnam]
				if {![ValidCDPRootname $constatsoutfnam]} {
					continue
				}
				catch {unset consavetxts}
				set ilist [$constatistics curselection]
				if {([llength $ilist] == 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					set msg "All Of The Listed Items ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Select Items To Save With Mouse"
						continue
					} else {
						set consavetxts $constattexts
					}
				} else {
					foreach i $ilist {
						lappend consavetxts [lindex $constattexts $i]
					}
				}
				set outfnam $constatsoutfnam
				append outfnam $evv(TEXT_EXT)
				if {[file exists $outfnam]} {
					set msg "File '$outfnam' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if {[DeleteFileFromSystem $outfnam 0 1]} {
						set i [LstIndx $outfnam $wl]
						if {$i >= 0} {
							$wl delete $i
							WkspCnt [$wl get $i] -1
							catch {unset rememd}
							DummyHistory $outfnam "DESTROYED"
						}
					} else {
						continue
					}
				}
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot Open File '$outfnam' To Write Data"
					continue
				}
				foreach txt $consavetxts {
					puts $zit $txt
				}
				close $zit
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "File '$outfnam' Is On The Workspace"
			}
			4 {		;#	SNDS SELECTED TO PROPSFILE
				if {![info exists constatsndnos]} {
					Inf "No Items Found To Store"
					continue
				}
				if {[string length $constatsoutfnam] <= 0} {
					Inf "No Outfile Name Entered"
					continue
				}
				set outfnam [string tolower $constatsoutfnam]
				if {![ValidCDPRootname $constatsoutfnam]} {
					continue
				}
				catch {unset consavesnds}
				set ilist [$constatistics curselection]
				if {([llength $ilist] == 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					set msg "All Of The Listed Items ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Select Items To Save With Mouse"
						continue
					} else {
						set consavesnds $constatsndnos
					}
				} else {
					foreach i $ilist {
						lappend consavesnds [lindex $constatsndnos $i]
					}
				}
				append outfnam [GetTextfileExtension props] 
				if {[string match $ts_propfile $outfnam]} {
					Inf "You Cannot Overwrite The Input Property File Here"
					continue
				}
				catch {unset snds}
				foreach no $consavesnds {
					set line [lindex $ts_props_list $no]
					lappend snds [lindex $line 0]
				}
				set sndnos $consavesnds
				if {[file exists $outfnam]} {
					set msg "File '$outfnam' Already Exists: Append This Data To It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set orig_props_info $props_info
						if {![ThisIsAPropsFile $outfnam 0 0]} {
							Inf "'$outfnam' Is Not A Properties File"
							set props_info $orig_props_info
							continue
						}
						set orig_ts_propnames [lindex $props_info 0]
						set orig_ts_props_list [lindex $props_info 1]
						set props_info $orig_props_info
						set OK 1
						foreach nam $ts_propnames orignam $orig_ts_propnames {
							if {![string match $nam $orignam]} {
								Inf "Properties In File '$outfnam' Do Not Correspond To Properties Of New Sounds"
								set OK 0
								break
							}
						}
						if {!$OK} {
							continue
						}
						catch {unset orig_snds}
						foreach line $orig_ts_props_list {
							lappend orig_snds [lindex $line 0]
						}
						set len [llength $snds]
						set n 0
						while {$n < $len} {
							set thissnd  [lindex $snds $n]
							if {[lsearch $orig_snds $thissnd] >= 0} {
								set snds [lreplace $snds $n $n]
								set sndnos [lreplace $sndnos $n $n]
								incr len -1
							} else {
								incr n
							}
						}
						if {$len <= 0} {
							Inf "All These Sounds Are Already In File '$outfnam'"
							continue
						}
						catch {unset nu_props_list}
						foreach line $orig_ts_props_list {
							lappend nu_props_list $line
						}
						foreach lineno $sndnos {
							lappend nu_props_list [lindex $ts_props_list $lineno]
						}
						set tmpfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
						if [catch {open $tmpfnam w} zit] {
							Inf "Cannot Open Temporary File To Store Enlarged Properties Listing."
							continue
						}
						puts $zit $ts_propnames
						foreach line $nu_props_list {
							puts $zit $line
						}
						close $zit
						set i [LstIndx $outfnam $wl]
						if {![DeleteFileFromSystem $outfnam 0 1]} {
							set msg "Cannot Delete Original File '$outfnam'"
							append msg "\n\nThe New Data Is In File '$tmpfnam'"
							append msg "\n\nRename This File, Outside The CDP, Before Quitting This Dialogue Box"
							Inf $msg
						} else {
							DummyHistory $outfnam "DESTROYED"
							if {[info exists propfiles_list]} {
								set k [lsearch $propfiles_list $outfnam]
								if {$k > 0} {
									set propfiles_list [lreplace $propfiles_list $k $k]
								}
							}
							if {$i >= 0} {
								WkspCnt [$wl get $i] -1
								$wl delete $i
								catch {unset rememd}
							}
							if [catch {file rename $tmpfnam $outfnam} zit] {
								set msg "Cannot Rename Appended Properties Files To '$outfnam'"
								append msg "\n\nThe New Data Is In File '$tmpfnam'"
								append msg "\n\nRename This File, Outside The CDP, Before Quitting This Dialogue Box"
								Inf $msg
							}
						}
						FileToWkspace $outfnam 0 0 0 0 1
						Inf "File '$outfnam' Is On The Workspace"
						set finished 1
					} else {
						set msg "Overwrite Existing Property File '$outfnam' ?"
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						set i [LstIndx $outfnam $wl]
						if {![DeleteFileFromSystem $outfnam 0 1]} {
							Inf "Cannot Delete Existing File '$outfnam'"
							continue
						} else {
							DummyHistory $outfnam "DESTROYED"
							if {[info exists propfiles_list]} {
								set k [lsearch $propfiles_list $outfnam]
								if {$k > 0} {
									set propfiles_list [lreplace $propfiles_list $k $k]
								}
							}
							if {$i >= 0} {
								WkspCnt [$wl get $i] -1
								$wl delete $i
								catch {unset rememd}
							}
						}
					}
				}
				if {!$finished} {
					if [catch {open $outfnam "w"} zit] {
						Inf "Cannot Create File '$outfnam' To Write Data"
						continue
					}
					puts $zit $ts_propnames
					foreach lineno $sndnos {
						puts $zit [lindex $ts_props_list $lineno]
					}
					close $zit
					FileToWkspace $outfnam 0 0 0 0 1
					Inf "File '$outfnam' Is On The Workspace"
				} else {
					set finished 0
				}
			}
			5 {		;#	SNDS SELECTED TO CHOSEN FILES LIST
				if {![info exists constatsndnos]} {
					Inf "No Items Selected To Store"
					continue
				}
				catch {unset consavesnds}
				set ilist [$constatistics curselection]
				if {([llength $ilist] == 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					set msg "All Of The Listed Items ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Select Items To Save With Mouse"
						continue
					} else {
						set consavesnds $constatsndnos
					}
				} else {
					foreach i $ilist {
						lappend consavesnds [lindex $constatsndnos $i]
					}
				}
				catch {unset snds}
				foreach no $consavesnds {
					set line [lindex $ts_props_list $no]
					lappend snds [lindex $line 0]
				}
				DoChoiceBak
				set chlist $snds
				$ch delete 0 end
				foreach fnam $chlist {
					$ch insert end $fnam
				}
				Inf "Files Are Now On The Chosen Files List"
			}
			6 {		;#	SNDS SELECTED ADDED TO CHOSEN FILES LIST
				if {![info exists constatsndnos]} {
					Inf "No Items Selected To Store"
					continue
				}
				catch {unset consavesnds}
				set ilist [$constatistics curselection]
				if {([llength $ilist] == 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					set msg "All Of The Listed Items ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Select Items To Save With Mouse"
						continue
					} else {
						set consavesnds $constatsndnos
					}
				} else {
					foreach i $ilist {
						lappend consavesnds [lindex $constatsndnos $i]
					}
				}
				catch {unset snds}
				foreach no $consavesnds {
					set line [lindex $ts_props_list $no]
					lappend snds [lindex $line 0]
				}
				set remaining_snds {}
				foreach snd $snds {
					if {[lsearch $chlist $snd] < 0} {
						lappend remaining_snds $snd
					}
				}
				if {[llength $remaining_snds] <= 0} {
					Inf "All These Sounds Are Already On The Chosen Files List"
					continue
				}
				DoChoiceBak
				lappend chlist $remaining_snds
				$ch delete 0 end
				foreach fnam $chlist {
					$ch insert end $fnam
				}
				Inf "Files Have Been Added To The Chosen Files List"
			}
			7 {			;#	SAVE CURRENT CONSONANT STATISTICS FOR THIS PROPERTIES FILE

				if {![info exists phonames] || ![info exists phoncnts]} {
					Inf "No Consonant Statistics To Save"
					continue
				}
				set savfnam [file rootname [file tail $ts_propfile]]
				append savfnam "_constats" $evv(CDP_EXT)
				set savfnam [file join $evv(URES_DIR) $savfnam]
				if {[file exists $savfnam]} {
					set msg "Overwrite Existing Consonant-Statistics For This Properties-File ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if [catch {file delete $savfnam} zit] {
						Inf "Cannot Delete Existing Consonant Statistics File '$savfnam'"
						continue
					}
				}
				if [catch {open $savfnam "w"} zit] {
					Inf "Cannot Open File '$savfnam' To Save Consonant Statistics"
					continue
				}
				Block "Saving Consonant Statistics"
				;#	CHECK THEY'RE ALPHA-SORTED
				set len [llength $phonames]
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					set phoname_n [lindex $phonames $n]
					set phoncnt_n [lindex $phoncnts $n]
					if {$phoncnt_n <= 0} {
						set phonames [lreplace $phonames $n $n]		;#	DELETE ZERO FRQ ITEMS
						set phoncnts [lreplace $phoncnts $n $n]
						incr len -1
						incr len_less_one -1
						continue
					}
					set m $n
					incr m
					while {$m < $len} {
						set phoname_m [lindex $phonames $m]
						set phoncnt_m [lindex $phoncnts $m]
						if {$phoncnt_m <= 0} {						;#	DELETE ZERO FRQ ITEMS
							set phonames [lreplace $phonames $m $m]
							set phoncnts [lreplace $phoncnts $m $m]
							incr len -1
							incr len_less_one -1
							continue
						}											;#	OTHERWISE ALPHASORT
						if {[string compare $phoname_m $phoname_n] < 0} {
							set phonames [lreplace $phonames $n $n $phoname_m]
							set phonames [lreplace $phonames $m $m $phoname_n]
							set phoname_n $phoname_m
							set phoncnts [lreplace $phoncnts $n $n $phoncnt_m]
							set phoncnts [lreplace $phoncnts $m $m $phoncnt_n]
							set phoncnt_n $phoncnt_m
						}
						incr m
					}
					incr n
				}
				foreach phoname $phonames phoncnt $phoncnts {
					set line [list $phoname $phoncnt]
					puts $zit $line
				}
				close $zit
				UnBlock
				Inf "Consonant Statistics Saved"
			}
			8 {		;#	ADD FINAL CONSONANT STATS FOR THIS PROPERTIES FILE TO OVERALL CONSONANT STATS

				set msg "You Should Only Do This Operation If The Properties File Is Now Complete: Proceed ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![info exists phonames] || ![info exists phoncnts]} {
					Inf "No Consonant Statistics To Save"
					continue
				}
				set totsavfnam "_constats" 
				append totsavfnam $evv(CDP_EXT)
				set totsavfnam [file join $evv(URES_DIR) $totsavfnam]
				set othersavfnam "_constatsfiles" 
				append othersavfnam $evv(CDP_EXT)
				set othersavfnam [file join $evv(URES_DIR) $othersavfnam]
				Block "Saving Consonant Statistics"
				if {![info exists totalconstats]} {
					if {[file exists $totsavfnam]} {
						if {![file exists $othersavfnam]} {
							set msg "Cannot FIND FILE '$othersavfnam' To Read Which Files Have Already Been Added To Overall Consonant Statistics\n\n" 
							append msg "You Should Recreate This File\n"
							append msg "And List In It The Names Of All The Files (With Full Path And Extension)\n"
							append msg "Whose Statistics Are Already Contained In The \"Overall Consonant Statistics\" File\n"
							Inf $msg
							UnBlock 
							continue
						}
						if [catch {open $othersavfnam "r"} zit] {
							set msg "Cannot Open Existing File '$othersavfnam' To Read Which Files Have Already Been Added To Overall Consonant Statistics\n\n" 
							append msg "You Should Check This File, And If Necessary Recreate It,\n"
							append msg "Listing In It The Names Of All The Files (With Full Path And Extension)\n"
							append msg "Whose Statistics Are Already Contained In The \"Overall Consonant Statistics\" File\n"
							Inf $msg
							UnBlock 
							continue
						}
						catch {unset totalconstats_files} 
						while {[gets $zit line] >= 0} {
							lappend totalconstats_files $line
						}
						close $zit
						if {[lsearch $totalconstats_files $ts_propfile] >= 0} {
							Inf "This Properties File Already Has Its Data Included In The \"Overall Consonant Statistics\" File\n"
							continue
						}
						if [catch {open $totsavfnam "r"} zit] {
							Inf "Cannot Open Existing \"Overall Consonant Statistics\" File '$totsavfnam' To Read Existing Data" 
							UnBlock 
							continue
						}
						while {[gets $zit line] >= 0} {
							set line [split $line]
							set totalconstats([lindex $line 0]) [lindex $line 1]
						}
						close $zit
					}
				} elseif {[lsearch $totalconstats_files $ts_propfile] >= 0} {
					Inf "This Properties File Already Has Its Data Included In The \"Overall Consonant Statistics\" File\n"
					UnBlock
					continue
				}
				foreach phoname $phonames phoncnt $phoncnts {
					if {$phoncnt > 0} {
						if {[info exists totalconstats($phoname)]} {
							incr totalconstats($phoname) $phoncnt
						} else {
							set totalconstats($phoname) $phoncnt
						}
					}
				}
				set tempfnam $evv(MACH_OUTFNAME)
				append tempfnam 0000 $evv(TEXT_EXT) 
				if [catch {open $tempfnam "w"} zit] {
					Inf "Cannot Open Temporary File '$tempfnam' To Write New Overall Consonant Statistics"
					UnBlock
					continue
				}
				foreach phoname [array names totalconstats] {
					set line [list $phoname $totalconstats($phoname)]
					puts $zit $line
				}
				close $zit
				lappend totalconstats_files $ts_propfile
				if [catch {file delete $totsavfnam} zit] {
					set msg "Cannot Delete Existing \"Overall Consonant Statistics\" File To Save New Data\n\n"
					append msg "New Data Is In File '$tempfnam'\n\n"
					append msg "You Should Rename This File To '$totsavfnam', Outside The Loom, Before Quitting This Dialogue Box"
					Inf $msg
				} elseif [catch {file rename $tempfnam $totsavfnam} zit] {
					set msg "Cannot Rename Temporary Data File '$tempfnam' To '$totsavfnam'\n\n"
					append msg "You Should Rename This File, Outside The Loom, Before Quitting This Dialogue Box\n\n"
					append msg "If You Do Not, The Existing Overall Consonant Statistics Will Be Lost !!!!!\n\n"
					Inf $msg
				}
				if [catch {open $tempfnam "w"} zit] {
					set msg "Cannot Open Temporary File '$tempfnam' To Rewrite List Of Property Files\nWhose Data Is Listed In The \"Overall Consonant Statistics\" File"
					append msg "You Should Add The Name Of The Current Property File (Complete With Path And Extension)\n"
					append msg "($ts_propfile)\n"
					append msg "To The Data In File '$othersavfnam'\n"
					Inf $msg
				}
				foreach fffnam $totalconstats_files {
					puts $zit $fffnam
				}
				close $zit
				if [catch {file delete $othersavfnam} zit] {
					set msg "Cannot Delete Existing File 'othersavfnam' To Save New Data\n\n"
					append msg "New Data Is In File '$tempfnam'\n\n"
					append msg "You Should Rename This File To '$othersavfnam', Outside The Loom, Before Quitting This Dialogue Box"
					Inf $msg
					UnBlock
				} elseif [catch {file rename $tempfnam $othersavfnam} zit] {
					set msg "Cannot Rename Temporary Data File '$tempfnam' To '$totsavfnam'\n\n"
					append msg "You Should Rename This File, Outside The Loom, Before Quitting This Dialogue Box\n\n"
					append msg "If You Do Not, You Will Lose The Of Files Already Having Their Data Listed In The Overall Stats !!!!!\n\n"
					Inf $msg
					UnBlock
				} else {
					UnBlock
					Inf "Overall Consonant Statistics Saved"
				}
			}
		}
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

#	THIS FUNCTION RETURNS AN ASSONANCE MEASURE FOR ANY GIVEN SET OF (PHONETIC) CONSONANT(CLUSTER)S
#	This could be returned as list of texts found, OR sounds in which they are located.
#

#--- Measure local density of any particular (phonetic) consonant(s)
#
#	density = minimum density of occurence of  the consonant(-clusters) (args) I'm looking for
#	minoccur = minimum number of consecutive occurences I'm looking for before I check density
#	args = consonants, or consonant clusters (as phonetics) I'm searching for
#

proc DoConsonantStatistics {alpha force} {
	global propwords gotpropwords propwordpos syllabcnt conphones ts_propfile constatstate constatistics phonames phoncnts 
	global laststatalpha zerophones readonlyfg readonlybg con_exclude

	;#	GET TEXT-PROPERTY DATA FROM FILE IF NOT ALREADY AVAILABLE

	if {$force } {
		catch {unset conphones}
		catch {unset propwords}
		catch {unset propwordpos}
	}
	if {![info exists propwords]} {
		set propfile [GetPropsDataFromFile $ts_propfile]
		if {[string length $propfile] <= 0} {
			return 0
		}
	}
	if {![info exists conphones]} {
		ConvertTextPropToConsonantPhonetics ;#	DO PHONETIC CONVERSION CONSONANTS IF NOT ALREADY DONE
	}
	catch {unset phonstat}
	foreach phone $conphones {
		set phones [split $phone "-"]
		foreach phon $phones {
			if {[string length $phon] <= 0} {
				continue
			}
			if {![info exists phonstat($phon)]} {
				set phonstat($phon) 1
			} else {
				incr phonstat($phon)
			}
		}
	}

	catch {unset phonames}
	catch {unset phoncnts}
	foreach name [array names phonstat] {
		lappend phonames $name
		lappend phoncnts $phonstat($name)
	}

		;#	FIND CONSONANTS (OR GROUPS THAT OCCUR WITHIN OTHER GROUPS BUT NEVER AT START)

	set phoneslen [string length $phonames]
	set n 0
	while {$n < $phoneslen} {
		set name [lindex $phonames $n]
		set thisphonelen [string length $name]
		if {$thisphonelen > 1} {
			set j 1
			while {$j < $thisphonelen} {
				set k $j
				while {$k < $thisphonelen} {
					set partphone [string range $name $j $k]
					if {[lsearch $phonames $partphone] < 0} {
						lappend phonames $partphone
						lappend zerophones $partphone
						lappend phoncnts 0
						incr phoneslen 
					}
					incr k
				}
				incr j
			}
		}
		incr n
	}
	set len [llength $phonames]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set phoname_n [lindex $phonames $n]
		set phoncnt_n [lindex $phoncnts $n]
		set m $n
		incr m
		while {$m < $len} {
			set swap 0
			set phoname_m [lindex $phonames $m]
			set phoncnt_m [lindex $phoncnts $m]
			if {$alpha} {
				if {[string compare $phoname_m $phoname_n] < 0} {
					set swap 1
				}
			} else {
				if {$phoncnt_m > $phoncnt_n} {
					set swap 1
				}
			}
			if {$swap} {
				set phonames [lreplace $phonames $n $n $phoname_m]
				set phonames [lreplace $phonames $m $m $phoname_n]
				set phoname_n $phoname_m
				set phoncnts [lreplace $phoncnts $n $n $phoncnt_m]
				set phoncnts [lreplace $phoncnts $m $m $phoncnt_n]
				set phoncnt_n $phoncnt_m
			}
			incr m
		}
		incr n
	}
	if {![info exists phonames]} {
		Inf "No Data To Display"
		return 0
	}
	if {$alpha} {		;#	put "th" represented by "7" in correct sort-order
		set set7nam {}
		set set7cnt {}
		set set0nam {}
		set set0cnt {}
		set set1nam {}
		set set1cnt {}
		set n 0
		while {$n < $len} {
			set phoname_n [lindex $phonames $n]
			set phoncnt_n [lindex $phoncnts $n]
			set firstletter [string index $phoname_n 0]
			if {[string match $firstletter "7"]} {
				lappend set7nam $phoname_n 
				lappend set7cnt $phoncnt_n 
			} elseif {[string compare $firstletter "U"] < 0} {
				lappend set0nam $phoname_n 
				lappend set0cnt $phoncnt_n 
			} else {
				lappend set1nam $phoname_n 
				lappend set1cnt $phoncnt_n 
			}
			incr n
		}
		set phonames [concat $set0nam $set7nam $set1nam]
		set phoncnts [concat $set0cnt $set7cnt $set1cnt]
	}
	$constatistics delete 0 end
	if {$alpha == 2} {
		foreach phoname $phonames {
			$constatistics insert end $phoname
		}
		set constatstate 1
	} else {
		foreach phoname $phonames phoncnt $phoncnts {
			set line $phoncnt
			append line "  " $phoname
			$constatistics insert end $line
		}
		set constatstate 2
	}
	.constats.4.l1 config -text "\"Phonetic\" representation of Consonants"
	.constats.4.l2 config -text "b  d  f  g  h  j  k  l  m  n  p  r  s  t  v  w  x  y  z"
	.constats.4.l3 config -text "C (=ch in arch)    X (=ch in loch)     S (=sh)     T (=th in lath)    7 (=th in that)     Z (=zh in occassion)     N(=ng as in ring)"
	.constats.4.l4 config -text "Select items for \"Search\" with mouse click"
	.constats.3.out config -text ""
	.constats.3.snd config -text "" -command {} -bd 0
	.constats.3.add config -text "" -command {} -bd 0
	.constats.3.ll config -text ""
	.constats.3.e config -bd 0 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
	.constats.3.txt config -text "" -command {} -bd 0
	.constats.3.prp config -text "" -command {} -bd 0
	$constatistics config -selectmode single
	if {$con_exclude} {
		bind $constatistics <ButtonRelease-1> {ConstatSelect %y 1}
	} else {
		bind $constatistics <ButtonRelease-1> {ConstatSelect %y 0}
	}
	set laststatalpha $alpha
	return 1
}

#------ Find sets of high-(specified)-density occurence of specified consonant(cluster)s

proc AnalyseTextPropertyConsonantDensity {force density minoccur} {
	global propwords propwordpos syllabcnt conphones ts_propfile constatstate constatchoice constatexclude constatsonly 
	global constatistics constatsndnos constattexts ts_propnames ts_props_list pr_constats evv

	;#	GET TEXT-PROPERTY DATA FROM FILE IF NOT ALREADY AVAILABLE

	if {$force} {
		catch {unset propwords}
		catch {unset conphones}
	}
	if {![info exists propwords]} {
		set propfile [GetPropsDataFromFile $ts_propfile]
		if {[string length $propfile] <= 0} {
			return 0
		}
		catch {unset conphones}
	}
	if {![info exists conphones]} {

	;#	DO PHONETIC CONVERSION OF CONSONANTS IF NOT ALREADY DONE

		ConvertTextPropToConsonantPhonetics
	}

	set sylcnt 0		;#	Number of syllables
	set findcnt 0		;#	Number of matches
	set gotdens 0		;#	Already found desired density
	set lastfindcnt 0	;#	finds recorded on last pass
	set cluster ""		;#	empty the consonant cluster store
	set hits {}			;#	lists start-and-end sounds of each density cluster I find

	set textproppos 1
	foreach nam $ts_propnames {
		if {[string match [string tolower $nam] "text"]} {
			break
		}
		incr textproppos
	}
	set sylindx 0					;#	index of entries in the array of hit-positions (counted in syllables from 1st hit of group)
	set sylmax [expr $minoccur - 1]	;#	index of last entry in that array

	foreach phone $conphones pos $propwordpos {
		set phlen [string length $phone]
		set n 0
		
		;#	LOOK AT EACH CHARACTER IN PHONETIC-WORD (no duplication of cosonant symbols, all vowel groups represented by SINGLE "-")

		while {$n < $phlen} {
			set char [string index $phone $n]
			
			;#	IF CHARACTER IS VOWEL (-group) 

			if {[string match $char "-"]} {

			;#	IF PREVIOUSLY GOT CONSONANT, SEARCH CONSONANT (CLUSTER) FOR DESIRED MATCHES

				if {[string length $cluster] > 0} {
					set OK 1
					foreach phgp $constatexclude {		;#	LOOK FOR MATCHES TO EXCLUDED SEARCH ITEMS WITHIN THE CLUSTER OF SYLLABS
						if {[string first $phgp $cluster] >= 0} {
							set OK 0
							break
						}
					}
					if {$OK} {
						foreach phgp $constatchoice {	;#	LOOK FOR MATCHES WITHIN THE CLUSTER OF SYLLABS
							if {$constatsonly} {
								if {[string length $phgp] != [string length $cluster]} {
									continue
								}
							}
							if {[string first $phgp $cluster] >= 0} {
								incr findcnt
								break
							}
						}
					}
					if {$findcnt > 0} {
						if {($findcnt == 1) && ($lastfindcnt != 1)} {	;#	IF THIS IS THE FIRST FIND
							if {$density <= 0} {
								lappend hits $pos $pos	;#	STORE THE DENSITY-GROUP POSITIONS, IF DENSITY ZERO
								set findcnt 0			;#	AND IGNORE ALL ELSE
							} else {					;#	OTHERWISE
								set startpos $pos		;#	IF THIS IS FIRST MATCH, NOTE SOUND POSITION AS startpos
								set sylcnt 0			;#	AND START COUNTING SYLLABS FROM HERE
								set sylindx 0
								set sylmark($sylindx) 0	;#	STORING THEM IN THE ARRAY OF SYLLAB-POSITIONS OF MOST RECENT FINDS
								incr sylindx
							}
						} else {
							if {$findcnt != $lastfindcnt} {	;#	IF THIS A FIND, BUT NOT THE FIRST
								if {$sylindx < $minoccur} {	;#	RECORD POSITION (IN SYLLABLE) OF 'minoccur' FINDS (RELATIVE TO START OF FIND-GROUP)
									set sylmark($sylindx) [expr $sylcnt + 1]
									incr sylindx			
								} else {
									set jj 0				;#	ONCE ARRAY IS FULL, SHUFFLE VALS DOWN AND PUT LATEST VAL AT TOP	,
									set kk 1				;#	HENCE RETAINING 'minoccur' FIND POSITIONS (IN SYLLABS) IN THE ARRAY
									while {$kk < $minoccur} {
										set sylmark($jj) $sylmark($kk)
										incr jj
										incr kk
									}
									set sylmark($jj) [expr $sylcnt + 1] 
								}
								if {$findcnt < $minoccur} {		;#	IF WE'VE NOT YET GOT ENOUGH SYLLAB
									set local_gplen [expr $sylcnt + 1 - $sylmark(0)]
									set hitratio [expr double($findcnt) / double($local_gplen)]
									if {$hitratio < $density} {	;#	IF NOT DENSE ENOUGH NOW
										set findcnt 1			;#	START A NEW DENSITY SET.
										set startpos $pos		;#	DO THIS FIND BECOMES THE FIRST MATCH OF THE NEW GROUP.
										set sylcnt 0			;#	(SO RESTART COUNTING SYLLABS FROM HERE)
										set sylindx 0
										set sylmark($sylindx) 0
										incr sylindx
									}
								}
							}

							if {$findcnt >= $minoccur} {				;#	IF ENOUGH FINDS FOUND, FIND LOCAL-DENSITY AND TEST
								set local_gplen [expr $sylcnt + 1 - $sylmark(0)]
								if {$local_gplen == 0} {
									set local_gplen 1
								}
								set hitratio [expr double($minoccur) / double($local_gplen)]
								if {$hitratio >= $density} {			;#	IF LOCAL-DENSITY (STILL) HIGH ENOUGH, A HIT!
									set endpos $pos						;#	NOTE SOUND POSITION HERE AS END OF DENSITY GROUP
									set gotdens 1						;#	MARK WE'VE FOUND GOOD DENSITY
																		;#	(DON'T STORE HERE AS MAY BE MORE FINDS TO COME, FALLING WITHIN THIS HIT-GROUP)
								} else {								;#	BUT IF LOCAL DENSITY NOT (OR NO LONGER) HIGH ENOUGH
									if {$gotdens} {						;#	IF DENSITY WAS PREVIOUSLY HIGH ENOUGH
										lappend hits $startpos $endpos	;#	STORE THE PREVIOUS DENSITY-GROUP SOUND-POSITIONS
										set gotdens 0					;#	AND RESET THE gotdens MARKER
									}									;#	WHETHER WE'VE STORED A PREVIOUSLY GOOD GROUP OR NOT, DENSITY IS NOW NO GOOD			
																		;#	SO RESTART THE SEARCH FOR HITS
									if {$findcnt != $lastfindcnt} {		
										set findcnt 1					;#	IF WE'VE JUST MADE A FIND,
										set startpos $pos				;#	 MAKE THIS THE START OF NEXT DENSITY-TEST GROUP
									} else {							
										set findcnt 0					;#	ELSE, SET findcnt TO ZERO
									}						
									set sylcnt 0						;#	AND IN EITHER CASE, SET SYLLABLE COUNT TO ZERO	
									set sylindx 0
									set sylmark($sylindx) 0
									incr sylindx
								}
							}
						}
						set lastfindcnt $findcnt						;#	STORE findcnt TO USE TO CHECK WHETHER WE MAKE A FIND ON NEXT PASS, OR NOT
					}
				}
				incr sylcnt												;#	WE'RE AT A VOWEL, AND VOWEL OCCURENCES COUNT SYLLABS , SO COUNT A SYLLABLE,
				set cluster ""											;#	AND ALSO EMPTY ANY EXISTING CONSONANT cluster READY TO START ASSEMBLING A NEW ONE
			} else {

				;#	ASSEMBLE SUCCESIVE CONSONANTS INTO A CLUSTER

				append cluster $char
			}
			incr n
		}	
		
		;#	CHECK ANY TERMINATING CONSONANT (CLUSTER) OF A WORD (SAME APPROACH AS ABOVE)

		if {[string length $cluster] > 0} {
			set OK 1
			foreach phgp $constatexclude {
				if {[string first $phgp $cluster] >= 0} {
					set OK 0
					break
				}
			}
			if {$OK} {
				foreach phgp $constatchoice {
					if {$constatsonly} {
						if {[string length $phgp] != [string length $cluster]} {
							continue
						}
					}
					if {[string first $phgp $cluster] >= 0} {
						incr findcnt
						break
					}
				}
			}
			if {$findcnt > 0} {
				if {($findcnt == 1) && ($lastfindcnt != 1)} {
					if {$density <= 0} {
						lappend hits $pos $pos
						set findcnt 0
					} else {
						set startpos $pos
						set sylcnt 0
						set sylindx 0
						set sylmark($sylindx) 0
						incr sylindx
					}
				} else {
					if {$findcnt != $lastfindcnt} {	
						if {$sylindx < $minoccur} {
							set sylmark($sylindx) $sylcnt
							incr sylindx
						} else {
							set jj 0
							set kk 1
							while {$kk < $minoccur} {
								set sylmark($jj) $sylmark($kk)
								incr jj
								incr kk
							}
							set sylmark($jj) $sylcnt
						}
						if {$findcnt < $minoccur} {
							set local_gplen [expr $sylcnt - $sylmark(0)]
							if {$local_gplen == 0} {
								set local_gplen 1
							}
							set hitratio [expr double($findcnt) / double($local_gplen)]
							if {$hitratio < $density} {
								set findcnt 1
								set startpos $pos
								set sylcnt 0
								set sylindx 0
								set sylmark($sylindx) 0
								incr sylindx
							}
						}
					}
					if {$findcnt >= $minoccur} {
						set local_gplen [expr $sylcnt - $sylmark(0)]
						if {$local_gplen == 0} {
							set local_gplen 1
						}
						set hitratio [expr double($minoccur) / double($local_gplen)]
						if {$hitratio >= $density} {
							set endpos $pos
							set gotdens 1
						} else { 
							if {$gotdens} {
								lappend hits $startpos $endpos
								set gotdens 0
							} else {									;#	WHETHER WE'VE STORED A PREVIOUSLY GOOD GROUP OR NOT, DENSITY IS NOW NO GOOD			
							}
							set gotdens 0
							if {$findcnt != $lastfindcnt} {
								set findcnt 1
								set startpos $pos
							} else {
								set findcnt 0
							}
							set sylcnt 0
							set sylindx 0
							set sylmark($sylindx) 0
							incr sylindx
						}
					}
				}
			}
			set lastfindcnt $findcnt
			set cluster ""							;#	COUNT OF SYLLABLES NOT ADVANCED ,AS LOCATION OF EVENT IS WITHIN PREVIOUS SYLLABLE 
		}
	}

	;#	ONCE ALL WORDS PARSED, CATCH ANY HITS LEFT OVER AT END

	if {[info exists hitratio] && ($hitratio >= $density)} {
		lappend hits $startpos $endpos
	}
	if {[llength $hits] <= 0} {
		Inf "No Occurences At This Density"
		return 0
	}
	if {([llength $hits] ==2) && ([lindex $hits 0] ==0) && ([lindex $hits 1] == $pos)} {
		Inf "This Grouping Is This Dense Everywhere"
		return 0
	}	
	set allthosesnds {}

	foreach {strt endd} $hits {
		set thesesnds {}
		set k $strt
		while {$k <= $endd} {
			lappend thesesnds $k
			incr k
		}
		set allthosesnds [concat $allthosesnds $thesesnds]
	}
	set constatsndnos {}

	foreach sndno $allthosesnds {
		if {[lsearch $constatsndnos $sndno] < 0} {
			lappend constatsndnos $sndno
		}
	}
	catch {unset constattexts}
	foreach no $constatsndnos {
		set line [lindex $ts_props_list $no]
		set txt [lindex $line $textproppos]
		if {![string match $txt $evv(NULL_PROP)]} {
			lappend constattexts $txt
		}
	}
	$constatistics delete 0 end
	foreach txt $constattexts {
		set txt [split $txt "_"]
		$constatistics insert end $txt
	}
	set constatstate 3
	.constats.4.l1 config -text ""
	.constats.4.l2 config -text ""
	.constats.4.l3 config -text ""
	.constats.4.l4 config -text "Select items with mouse to save to file, or to send to Chosen List"
	.constats.3.out config -text "OUTPUT"
	.constats.3.snd config -text "Snds As Chosen Files" -bd 2 -command "set pr_constats 5"
	.constats.3.add config -text "Add To Chosen Files" -bd 2 -command "set pr_constats 6"
	.constats.3.ll config -text "Filename "
	.constats.3.e config -bd 2 -state normal
	.constats.3.txt config -text "Texts to Textfile" -bd 2 -command "set pr_constats 3"
	.constats.3.prp config -text "Snds To New Propfile" -bd 2 -command "set pr_constats 4"
	$constatistics config -selectmode extended
	bind $constatistics <ButtonRelease-1> {ConstatSelect %y 2}
	return 1
}

#---- CONVERT words IN TEXT PROPERTY TO PHONETIC RENDERING OF CONSONANTS

proc ConvertTextPropToConsonantPhonetics {} {
	global propwords syllabcnt conphones
	foreach word $propwords {
		set word [StripNonAlpha $word]
		if {[string length $word] <= 0} {
			continue
		}
		catch {unset lastwasconsonant}

			;#	STRIP "ness" ENDINGS

		set ness_end 0
		set wordlen [string length $word]
		set kk $wordlen
		if {$kk >= 6} {
			incr kk -4
			set teststr [string range $word $kk end]
			if {[string match $teststr "ness"]} {
				set ness_end 1
				incr kk -1
				set word [string range $word 0 $kk]
			}
		}
			;#	STRIP "s" USED FOR PLURAL

		if {!$ness_end} {
			set s_end 0
			if {[string match [string index $word end] "s"]} {
				set s_end 1
				set len [string length $word]
				if {$len > 1} {
					set m [expr $len - 2]
					set testchar [string index $word $m]
					if {[string match $testchar "s"] \
					||  [string match $testchar "a"] \
					||  [string match $testchar "i"] \
					||  [string match $testchar "o"] \
					||  [string match $testchar "u"]} { 		;#	double "ss" + few english words end in these vowels
						set s_end 0
					} else {
						set word [string range $word 0 $m]	;# if "s" end, and not "ss", assume s =plural-form & drop "s" from end for now
					}
				}
			}
		}
		set origword $word								;#	Keep original word "origword" (with no plural "s") to do character search on
		set endindex [string length $word]				;#	while "word" is gradually converted to a phonetic format, of same char-length
		incr endindex -1								;#	index of last character in (non-plural) word
		set n 0

			;#	DISTINGUISH CONSONANTS AND VOWELS, (INCLUDING 'augh','ough' as vowel or vowel-ff)

		while {$n <= $endindex} {
			set teststr [string range $origword $n $endindex]
			set testchar [string index $origword $n]
			set test [IsVowelEquiv $origword $teststr $testchar $n $endindex] ;#	TEST FOR CONS OR VOWEL
			set isvowel [lindex $test 0]
			set ghskip  [lindex $test 1]							;#	WITH e.g. "augh" 1 vowel but 3 extra chars to skip
			if {$isvowel} {
				set qufound 0								
				if {[info exists lastwasconsonant] && $lastwasconsonant} {	;#	If there was a preceding consonant

					;# ARRIVED AT VOWEL, AFTER A PRECEDING CONSONANT... PHONETIC SUBSTITUTION FOR CONSONANT

					set test2 [PhoneticReplaceConsonants $origword $word $n] ;#	Convert preceding cons (group) to phonetics (keep same no of chars)
					set word [lindex $test2 0]								;#	test2 = newword : qufound
					set qufound [lindex $test2 1]
				}
					;#	REPLACE VOWELS BY "-"

				if {!$qufound} {												;#	If "qu" found, "u" has already been replaced by "w"
					set word [ReplaceLettersInString $word $wordlen $n "-" 1]	;#	Otherwise, mark true vowel by "-"
				}
				set lastwasconsonant 0											;#	However, even with "qu" ,
																				;#	don't want to trigger first-vowel-after-consonant action
																				;#	on next pass (As dealt with "qu" her), so still mark "u" as vowel	

				if {$ghskip} {													;#	If "ough" or "augh" vowel-sets, write extra "-"
					set k 0														;#	for each extra vowel-constituent (e.g. o-ugh would add "- - -"
					set j [expr $n + 1]
					while {$k < $ghskip} {
						set word [ReplaceLettersInString $word $wordlen $j "-" 1]
						incr j
						incr k
					}
					set lastwasconsonant 0

					;#	DEAL WITH "ough" AND "augh" EXCEPTIONS (WHERE gh = ff)

					if {[llength $test] > 2} {									;#	if found "gh" pronounced as "f" on end of vowel "ough"
						incr j -1												;#	subsitute an "f" for previous final vowel "-"	
						set word [ReplaceLettersInString $word $wordlen $j "f" 1]
						set lastwasconsonant 1
					}
				}
			} else {

				;#	ELSE MARK AS A CONSONANT

				set lastwasconsonant 1								;#	In all cases, mark what the character is (vowel/cons) for next pass
			}
			if {$ghskip} {
				incr n $ghskip										;#	do the skipping along the word, caused by "ough, augh"
			}
			incr n
		}

		;#	DEAL WITH CONSONANTS AT END !!

		if {[info exists lastwasconsonant] && $lastwasconsonant} {	;#	If there was a preceding consonant

			;# ARRIVED AT VOWEL, AFTER A PRECEDING CONSONANT... PHONETIC SUBSTITUTION FOR CONSONANT

			set test2 [PhoneticReplaceConsonants $origword $word $n] ;#	Convert preceding cons (group) to phonetics (keep same no of chars)
			set word [lindex $test2 0]								;#	test2 = newword : qufound
		}

		;#	IF WORD (pre-plural "s") ENDS IN "e", CONVERT "e" TO SILENCE OR NOT

		if {([string index $origword end] == "e") && ([string index $word end] == "-")} {
			set word [DoFinalEConversion $origword $word $s_end]
		}

		;#	IF WORD ENDS IN "S" CONVERT TO "s" OR "z"

		if {$ness_end} {
			append word n-SS
		} elseif {$s_end} {
			set word [DoFinalSConversion $origword $word]
		} else {
			set len [string length $origword]
			set penult [expr $len - 2]
			set matchlist [list as has whereas overseas pyjamas was his cos]
			if {[WordMatchesAnyOfWords $origword $matchlist]} {
				set word [string range $word 0 $penult]
				append word "z"
			} elseif {$len >= 4} {
				set stt [expr $len - 4]
				set teststr [string range $origword $stt end]
				if {[string match $teststr "gris"] \
				||  [string match $origword "debris"]} {	;#	verdigris etc.
					set word [string range $word 0 $penult]
					append word "-"
				}
			}
		}

		;#	REMOVE ALL PHONEME AND VOWEL DUPLICATION  e.g. CC---TT --> C-T

		set word [RemoveAllPhoneticDoubles $word]
		lappend conphones $word
	}
	return $conphones
}

#--- Replace consonant (clusters) by their "phonetic" equivalents
#
# Mostly ...
#
#	b	c	ch  ch(loch) d   f   g   h   j   k   l   m   n   p   ph  
#	b	k	C   X        d   f   g   h   j   k   l   m   n   p   f   
#      (s) (S)			(t) (v) (j)                     
#
#   q  qu   r     s   sh   t  th(ump) th(e) tch  v   w   x   y   z   zh
#   k  kw   r     s   S    t  T       7      C   v   w   ks  y   z   Z
#        (vowel)(S,z)     (S)					  (vowel) (vowel)
#
# retaining the same letter-count (i.e. use double symbols where ness)
#

proc PhoneticReplaceConsonants {origword word n} {

	set wordlen [string length $word]
	set wordend [expr $wordlen - 1]
	if {$n <= 0} {
		Inf "Problem In Algorithm PhoneticReplaceConsonants: Bad n = $n"
		return
	}
	set m $n
	incr m -1
	set consend $m
	while {$m >= 0} {
		if {[string match [string index $word $m] "-"]} {
			incr m
			set constt $m
			break
		}
		incr m -1
	}
	if {$m < 0} {
		set constt 0
	}
	set cluster [string range $word $constt $consend]
	set cluslen [expr $consend - $constt + 1]


	;# ANY LENGTH OF CLUSTER >= 2

	if {$cluslen >= 2} {
		set k [string first "s" $cluster]		;#	looking for "s" at end of cluster
		if {$k == [expr $cluslen - 1]} {
			set afterchars [expr $wordend - $consend]
			if {$afterchars >= 3} {
				set jj [expr $consend + 1]
				set kk [expr $consend + 3]
				set matchstr [string range $origword $jj $kk]
				if {[string match  $matchstr "ure"]} {		;#	-sure
					incr k -1
					set prechar [string index $cluster $k]
					if {$prechar == "s"} {					;#	(rea)ssure etc.
						set cluster [ReplaceLettersInString $cluster $cluslen $k "SS" 2]
						set word [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					} else {
						set word [ReplaceLettersInString $word $wordlen $consend "S" 1]
					}
					return [list $word 0]
				} else {									;#	-sion
					set matchlist [list version aversion diversion inversion conversion perversion inversion]
					if {[WordMatchesAnyOfWords $origword $matchlist]} {
						set word [ReplaceLettersInString $word $wordlen $consend "Z" 1]
						return [list $word 0]
					} else {
						set word [ReplaceLettersInString $word $wordlen $consend "S" 1]
						return [list $word 0]
					}
				}
			}
			if {$afterchars >= 1} {
				set jj [expr $consend + 1]
				set matchstr [string index $origword $jj]
				if [string match  $matchstr "e"] {
					set matchlist [list paradise course merchandise premise promise practise obese geese because]
					set containslist [list lease license condense dispense relapse crease grease chase precise concise]
					if {[WordMatchesAnyOfWords $origword $matchlist] || [WordContainsAnyOf $origword $containslist]} {
						;#	No change
					} else {
						set word [ReplaceLettersInString $word $wordlen $constt "z" 1]
						return [list $word 0]
					}
				}	
			}
		}
		set k [string first "t" $cluster]		
		if {$k == [expr $cluslen - 1]} {		;#	looking for "t" at end
			set afterchars [expr $wordend - $consend]
			if {$afterchars >= 4} {
				set jj [expr $consend + 1]
				set kk [expr $consend + 4]
				set matchstr [string range $origword $jj $kk]
				if {[string match  $matchstr "ious"]} {		;#	-tious
					set word [ReplaceLettersInString $word $wordlen $consend "S" 1]
					return [list $word 0]
				} elseif {[string match  $matchstr "eous"]} {		;#	-teous
					set word [ReplaceLettersInString $word $wordlen $consend "C" 1]
					return [list $word 0]
				}
			}
			if {$afterchars >= 3} {
				set jj [expr $consend + 1]
				set kk [expr $consend + 3]
				set matchstr [string range $origword $jj $kk]
				if {[string match  $matchstr "ion"]} {		;#	-tion
					set word [ReplaceLettersInString $word $wordlen $consend "S" 1]
					return [list $word 0]
				}
			}
		}
		set k [string first "g" $cluster]		
		if {$k == [expr $cluslen - 1]} {		;#	looking for "g" at end of cluster, but NOT "ng" or "gg"
			set afterchars [expr $wordend - $consend]
			if {$afterchars >= 2} {
				set prechar [string index $cluster [expr $cluslen - 2]]
				set jj [expr $consend + 1]
				set kk [expr $consend + 2]
				set matchstr [string range $origword $jj $kk]
				if {($prechar != "n") && ($prechar != "g")} {
					set matchlist [list iu ia io eo]
					if {[WordMatchesAnyOfWords $matchstr $matchlist] } {	;#	e.g. Belgium, belgian, surgeon
						set word [ReplaceLettersInString $word $wordlen $consend "j" 1]
						return [list $word 0]
					}
				}
			}
		}
		set k [string first "stl" $cluster]		
		if {$cluslen == 3} {		;#	castle, hustled, jostling
			set teststr [string range $origword [expr $consend + 1] end]
			set matchlist [list e ing]
			if {[WordBeginsWithAnyOf $teststr $matchlist]} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "ssl" 3]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			}				
		}

		set k [string first "st" $cluster]		
		if {$k == [expr $cluslen - 2]} {		;#	looking for "st" at end
			set teststr [string range $origword [expr $constt + $k] end]
			if {[string first "stion" $teststr] == 0} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "sC--n" 5]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			}				
		}

		set k [string first "sc" $cluster]
		if {$k == [expr $cluslen - 2]} {		;#	looking for "sc" at end
			set teststr [string range $origword [expr $constt + $k] end]
			if {[string first "scious" $teststr] == 0} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "SS---s" 6]
				set word [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "x" $cluster]
		if {$k == [expr $cluslen - 1]} {		;#	looking for "x" at end
			set teststr [string range $origword [expr $constt + $k] end]
			if {[string first "xious" $teststr] == 0} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "SS--s" 5]
				set word [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
			if {[string first "xion" $teststr] == 0} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "S--n" 4]
				set word [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}





		set k [string first "d" $cluster]		;#	looking for "ed- or ed/"
		if {$k == 0} {
			if {([expr $k - 3] >= 0) && ([string index $origword [expr $k - 1]] == "e")} {
				set prechar [string index $origword [expr $k - 2]]
				set preprechar [string index $origword [expr $k - 3]]
				switch -- $prechar {
					"a" -
					"e" -
					"i" -
					"o" -
					"u" {
						;# Previous e was part of a vowel : do nothing
					}
					"d" -
					"t" {
						;# Previous e was part of a vowel : do nothing
					}
					"b" -
					"g" -
					"j" -
					"l" -
					"m" -
					"n" -
					"v" -
					"w" -
					"y" -
					"z" {
						;#	Previous "e" is silent, d pronounced "d"
						set word [ReplaceLettersInString $word $wordlen [expr $constt - 1] "dd" 2]
						return [list $word 0]
					}
					"s" {
						set matchlist [list repulsed deceased licensed versed unhorsed cursed recompensed practised]
						if {([string first "iased" $origword ] > 0) \
						|| [WordMatchesAnyOfWords $origword $matchlist] } {
							set word [ReplaceLettersInString $word $wordlen [$constt - 1] "tt" 2]
							return [list $word 0]
						} elseif {[string match $origword "accursed"]} {
							;#	s-d = s-d : do nothing
							return [list $word 0]
						} else {
							set word [ReplaceLettersInString $word $wordlen [$constt - 2] "zzd" 3]
							return [list $word 0]
						}
					}
					"c" -
					"f" -
					"h" -
					"k" -
					"p" -
					"q" -
					"x" {
						;#	Previous "e" is silent, d pronounced "t"
						set word [ReplaceLettersInString $word $wordlen [expr $constt -1] "tt" 2]
						return [list $word 0]
					}
				}
			}
		}
		set k [string first "cq" $cluster]		;#	cq
		if {$k >= 0} {
			set afterchars [expr $wordend - $consend]
			if {$afterchars} {
				set char [string index $origword [expr $consend + 1]]
				if {$char  == "u"} {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
					if {$afterchars >= 2} {
						set char2 [string index $origword [expr $consend + 2]]
						if {$char2 == "e"} {
							append cluster "k"			;#	cque --> kkk (lacquer, racquet)
						} else {
							append cluster "w"			;#	cqui --> kkw  (acquire)
						}
						set word [ReplaceLettersInString $word $wordlen $constt $cluster [expr $cluslen + 1]]
						return [list $word 1]
					}
				}
			}	;#	???? words ending in cq or words with cqNOTu : none ???
			set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
			set word [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "ng" $cluster]
		if {$k == 0} {
			if {$consend == $wordend} {			;#	ng/ --> "NN" (N = ng as in ring)
				set cluster [ReplaceLettersInString $cluster $cluslen $k "NN" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
			set j [expr $k + 2]
			set char [string index $cluster $j]
			if {$char == "l"} {			;#	ngl --> Ng (angling,dangling...)
				set cluster [ReplaceLettersInString $cluster $cluslen $k "Ng" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			} elseif {$char == "r"} {	;#	ngr --> ng (ingrained...)
				;#	do nothing	
				return [list $word 0]
			} elseif {$char == "e"} {	
				set matchlist [list fanged stringed banger hanger banged hanged slinger ringer swinger]
				set matchlist2 [list anger hunger linger]
				set containslist2 [list finger onger]
				if {[WordMatchesAnyOfWords $origword $matchlist] \
				||  ([string first "singer" $origword] >= 0) } {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "NN" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				} elseif {[WordMatchesAnyOfWords $origword $matchlist2] \
				|| [WordContainsAnyOf $origword $containslist2]} {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "Ng" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				} else {									;#	-nged, -nger etc. (ranged,ranger)
					set cluster [ReplaceLettersInString $cluster $cluslen $k "nj" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			} elseif {$char == "i"} {						;#	-nging (ringing)
				if {[string match [string range $origword [expr $consend + 1] end] "ing"]} {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "NN" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			} elseif {$char == "u"} {
				set jj [expr $consend + 1] 
				set teststr [string range $origword $jj end]
				if {[string first "ue"  $teststr] == 0} {			;#	-ngue (tongue, tongued)
					set cluster [ReplaceLettersInString $cluster $cluslen $k "NNNN" 4]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				} elseif {[string first "uish"  $teststr] == 0} {	;#	languish, distinguish
					set cluster [ReplaceLettersInString $cluster $cluslen $k "Ng" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				} elseif {[string first "uing"  $teststr] == 0} { ;# tonguing
					set cluster [ReplaceLettersInString $cluster $cluslen $k "NN" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			} elseif {[IsVowel $char]} {						;#	Bangor
				set cluster [ReplaceLettersInString $cluster $cluslen $k "Ng" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			} else {											;#	wrongfoot
				set cluster [ReplaceLettersInString $cluster $cluslen $k "NN" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "ph" $cluster]					;#	ph --> ff
		if {$k >= 0} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "ff" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "th" $cluster]					;#	 th --> TT or 77 or tt
		if {$k >= 0} {
			set matchlist [list th thd ths]		;#	the they'd the's
			if {[WordMatchesAnyOfWords $origword $matchlist]} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "77" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
			if {$consend != $wordend} {
				set char [string index $origword [expr $constt + $k + 2]]
				if {[string match $char "e"]} {				;# th as in "bathe" (th = 7)
					set matchlist [list ether anther panther theme thematic theramin]
					set containlist [list theis theo thera therium therm thero thesa thesi thesp theur thew]
					if {[WordMatchesAnyOfWords $origword $matchlist] \
						||  [WordContainsAnyOf $origword $containlist]} {
						set cluster [ReplaceLettersInString $cluster $cluslen $k "TT" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					} else {
						set cluster [ReplaceLettersInString $cluster $cluslen $k "77" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					}
				} elseif {[IsVowel $char] || ($char == "y")} {
					set matchlist [list than that thine this thither tho those though thou thus thy thyself]
					if {[WordMatchesAnyOfWords $origword $matchlist]} {
						set cluster [ReplaceLettersInString $cluster $cluslen $k "77" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					} elseif {([string first "thom" $origword] == 0) \
					|| [string match $origword "thyme"]} {
						set cluster [ReplaceLettersInString $cluster $cluslen $k "tt" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					} else {										;# thorough, pathology
						set cluster [ReplaceLettersInString $cluster $cluslen $k "TT" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					}
				} else {
					set matchlist [list farthing brethren]
					if {[WordMatchesAnyOfWords $origword $matchlist]} {
						set cluster [ReplaceLettersInString $cluster $cluslen $k "77" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					} else {											;# three, pathway
						set cluster [ReplaceLettersInString $cluster $cluslen $k "TT" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					}
				}
			} else {									;#	th at word end == "TT"
				set cluster [ReplaceLettersInString $cluster $cluslen $k "TT" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}

			;#	PROBABLY REDUNDANT

			if {$constt == 0} {
				set matchlist [list than that the thee their them then they though those thou though thus thyself]
				set beginswithlist [list thence there]
				if {[WordMatchesAnyOfWords $origword $matchlist] \
				||  [WordBeginsWithAnyOf $origword $beginswithlist]} {
					set cluster [ReplaceLettersInString $cluster $cluslen 0 "77" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				} else {
					set cluster [ReplaceLettersInString $cluster $cluslen 0 "TT" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			}
			set j [expr $k + 2]
			if {($cluslen > 2) && ($j < $cluslen)}  {
				set testchar [string index $cluster $j]
				if {[string match $testchar "r"]} {		;#	"-thr-"
					set cluster [ReplaceLettersInString $cluster $cluslen $k "TT" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			}												;#	th as in "bath" (th = T) : possibly not universal !!
			set cluster [ReplaceLettersInString $cluster $cluslen $k "TT" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}

		set k [string first "t" $cluster]					;#	 tion, tious, at end
		if {($k == [expr $cluslen - 1]) && ([expr $wordend - $consend] >= 3)} {
			set j [expr $consend + 1]
			set teststr [string range $origword $j end]
			if {[string first "ion" $teststr] == 0} {
				set word    [ReplaceLettersInString $word $wordlen $consend "S" 1]
				return [list $word 0]
			} elseif {[string first "ious" $teststr] == 0} {
				set word    [ReplaceLettersInString $word $wordlen $consend "S" 1]
				return [list $word 0]
			}
		}
		set k [string first "lk" $cluster]					;#	 -alk, -olk
		if {($k == 0) && ($cluslen == 2) && ($constt != 0)} {
			set prechar [string index $origword [expr $constt - 1]]
			if {($prechar == "a") || ($prechar == "o")} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
	}
	if {$cluslen >= 3} {	;#	TRIPLE CONSONANTS
		set k [string first "lch" $cluster]
		if {$k >= 0} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "lSS" 3]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "nch" $cluster]
		if {$k >= 0} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "nSS" 3]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "sch" $cluster]
		if {$k >= 0} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "SSS" 3]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "tch" $cluster]
		if {$k >= 0} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "CCC" 3]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "snt" $cluster]
		if {($k >= 0) && ($consend == $wordend)} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "znt" 3]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
	}
	if {$cluslen >= 2} {	;#	DOUBLE CONSONANTS
		set k [string first "ch" $cluster]
		if {$k >= 0} {
			if {$consend != $wordend} {
				set teststr [lrange $origword $k end]
				set afterchar [lindex $origword [expr $consend + 1]]
				set matchlist [list panache cache moustache gouache]
				set containslist [list eche iche anche oche uche]
				if {$afterchar == "e"} {
					if {[string match $origword "mache"] \
					||  [string match $origword "cliche"] \
					|| ([string first "cheon" $teststr] == 0)} {		;#	truncheon
						set cluster [ReplaceLettersInString $cluster $cluslen $k "SS" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					} elseif {[string match $origword "apache"]} {
						set cluster [ReplaceLettersInString $cluster $cluslen $k "CC" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					} elseif {[string match $origword "synecdoche"] \
					     ||   [string match $origword "psyche"]} {
						set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					} elseif {[WordMatchesAnyOfWords $origword $matchlist] \
					|| [WordContainsAnyOf $origword $containslist]} {
						set cluster [ReplaceLettersInString $cluster $cluslen $k "SS" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					} else {								;#	ache ETC
						set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					}
				}
			}
			if {$constt > 0} {
				set char [string index $origword [expr $constt - 1]]
				if {$char == "r"} {
					if {$constt >= 3} {
						set m [expr $constt - 3]
						set teststr [string range $origword $m $consend]
						set matchlist [list iarch garch rarch narch]
						if {[WordBeginsWithAnyOf $teststr $matchlist]} { ;#	 patriarch,oligarch,hierarchy,anarchy
							set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
							set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
							return [list $word 0]
						}
					}
				} elseif {$char == "o"} {
					if {$consend == $wordend} {						;#	loch
						set cluster [ReplaceLettersInString $cluster $cluslen $k "xx" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					}
				} elseif {$char == "u"} {
					if {$constt >= 2} {
						set m [expr $constt - 2]
						set teststr [string range $origword $m $consend]
						if {([string first "euch" $teststr] == 0) \
						||   [string match $origword "eunuch"]} {			;#	pentateuch,eunuch
							set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
							set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
							return [list $word 0]
						}
					}
				} elseif {$char == "y"} {							;# ....ych
					if {$consend == $wordend} {						
						set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
						set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
						return [list $word 0]
					}
				} elseif {$char == "e"} {							;#  -echo-
					if {($constt > 0) && ($consend < $wordend)} {
						set teststr [string range $origword [expr $constt - 1] end]
						if {[string first "echo" $teststr] == 0} {
							set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
							set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
							return [list $word 0]
						}
					}
				}
			}														;#	arch , chat, birch
			set cluster [ReplaceLettersInString $cluster $cluslen $k "CC" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "bh" $cluster]							;#	 bhopal (!)
		if {$k >= 0} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "bb" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}								
		set k [string first "bt" $cluster]
		if {($k >= 0) && ($consend == $wordend)} {					;#	doubt, debt
			set cluster [ReplaceLettersInString $cluster $cluslen $k "tt" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}								
		set k [string first "ck" $cluster]
		if {$k >= 0} {												;#	lock, docker
			set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}								
		set k [string first "dg" $cluster]
		if {($k >= 0) && ![string match $origword "headgear"]} {		;#	hedge, badger
			set cluster [ReplaceLettersInString $cluster $cluslen $k "jj" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}								
		set k [string first "dh" $cluster]
		if {($k >= 0) && ($constt == 0)} {							;#	dhobi
			set cluster [ReplaceLettersInString $cluster $cluslen $k "dd" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "dj" $cluster]
		if {($k >= 0) && ($constt == 0)} {							;#	djinn
			set cluster [ReplaceLettersInString $cluster $cluslen $k "jj" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "ght" $cluster]
		if {($k >= 0) && [string match $origword "righteous"]} {	;#	righteous
			set cluster [ReplaceLettersInString $cluster $cluslen $k "CCC" 3]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "gh" $cluster]
		if {($k >= 0) && ($constt <= 1)} {							;#	ghost, aghast, ugh
			set cluster [ReplaceLettersInString $cluster $cluslen $k "gg" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "gm" $cluster]			
		if {$k >= 0} {					
			if {($consend == $wordend)	\
			|| ([string index $origword [expr $constt + 2]] != "a")} {	;#	paradigm, but NOT paradigmatic
				set cluster [ReplaceLettersInString $cluster $cluslen $k "mm" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "gn" $cluster]
		if {$k >= 0} {
			if {($constt == 0) || ($consend == $wordend) \
			|| ([string index $origword [expr $constt + 2]] != "a")} {	;#	gnat, sign; but  NOT signature, signalling
				set cluster [ReplaceLettersInString $cluster $cluslen $k "nn" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "jh" $cluster]
		if {$k >= 0} {												;#	jhodpurs
			set cluster [ReplaceLettersInString $cluster $cluslen $k "jj" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "kh" $cluster]
		if {($k >= 0) && ($constt == 0)} {							;#	khaki
			set cluster [ReplaceLettersInString $cluster $cluslen $k "kk" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}								
		set k [string first "kn" $cluster]
		if {($k >= 0) && ($constt == 0)} {							;#	knowledge
			set cluster [ReplaceLettersInString $cluster $cluslen $k "nn" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "lf" $cluster]
		if {($k >= 0) && ($constt > 0) && ([lindex $origword [expr $constt - 1]] == "a")} { ;#	calf
			set cluster [ReplaceLettersInString $cluster $cluslen $k "ff" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "lm" $cluster]
		if {($k >= 0) && ($constt > 0) && ([lindex $origword [expr $constt - 1]] == "a")} {	;#	calm
			if {($constt > 1) && ([lindex $origword [expr $constt - 2]] != "e")} {			;#	NOT realm
				set cluster [ReplaceLettersInString $cluster $cluslen $k "mm" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "mb" $cluster]
		if {$k >= 0} {
			if {$consend == $wordend} {								;#	comb
				set cluster [ReplaceLettersInString $cluster $cluslen $k "mm" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
			if {($wordend - $consend) >= 3} {						;#	combing
				set jj [expr $consend + 1]
				set kk [expr $consend + 3]
				if {[string match [string range $origword $jj $kk] "ing"]} {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "mm" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			}
			if {($wordend - $consend) >= 2} {						;#	combed, beachcomber
				set jj [expr $consend + 1]
				set kk [expr $consend + 2]
				set matchstr [string range $origword $jj $kk]
				if {[string match $matchstr "ed"] \
				||  [string match $matchstr "er"] } {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "mm" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			}
		}
		set k [string first "mh" $cluster]							;#	mhadi
		if {($k >= 0) && ($constt == 0)} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "mm" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "pn" $cluster]							;#	pneumatic
		if {($k >= 0) && ($constt == 0)} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "nn" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "rh" $cluster]							;#	rhodium
		if {($k >= 0) && ($constt == 0)} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "rr" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "ss" $cluster]							;#	assure
		if {($k >= 0) && ($constt > 0)} {
			if {[expr $wordend - $consend] >= 3} {
				set jj [expr $consend + 1]
				set kk [expr $consend + 3]			
				set matchstr [string range $origword $jj $kk]			
				if {[string match $matchstr "ure"]} {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "SS" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			}
		}
		set k [string first "sh" $cluster]							;#	welsh
		if {$k >= 0} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "SS" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "ns" $cluster]							;#	ensure
		if {($k >= 0) && ($constt > 0)} {
			if {[expr $wordend - $consend] >= 3} {
				set jj [expr $consend + 1]
				set kk [expr $consend + 3]			
				set matchstr [string range $matchstr $jj $kk]			
				if {[string match $matchstr "ure"]} {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "nS" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			}
		}
		set k [string first "ks" $cluster]							;#	cocksure
		if {($k >= 0) && ($constt > 0)} {
			if {[expr $wordend - $consend] >= 3} {
				set jj [expr $consend + 1]
				set kk [expr $consend + 3]			
				set matchstr [string range $origword $jj $kk]			
				if {[string match $matchstr "ure"]} {
					set cluster [ReplaceLettersInString $cluster $cluslen $k "kS" 2]
					set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
					return [list $word 0]
				}
			}
		}
		set k [string first "wr" $cluster]							;#	rewrite
		if {$k >= 0} {
			set beginswithlist [list rewr miswr typewr underwr overwr]
			if {$constt == 0} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "rr" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			} elseif {[WordBeginsWithAnyOf $origword $beginswithlist]} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "rr" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		} 
		set k [string first "wh" $cluster]							;#	when
		if {$k >= 0} {
			set teststr [string range $origword $k end]
			set origbeginswith [list what when where whet which whig whim who why]
			set testbeginswith [list whack wheel while whis whit]
			if {[WordBeginsWithAnyOf $origword $origbeginswith] \
			||  [WordBeginsWithAnyOf $teststr $testbeginswith]} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "ww" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "cc" $cluster]							;#	bragadoccio, pistaccio, Ricci
		if {($k >= 0) && ($wordend > $consend)} {
			set postchar [string index $origword [expr $consend + 1]]
			if {[string match $postchar "i"]} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "CC" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "c" $cluster]							;#	-ncy, -lci, rce etc.
		if {($k == [expr $cluslen - 1]) && ($consend != $wordend)} {							
			set prechar  [string index $cluster [expr $k - 1]]
			set postchar [string index $origword [expr $consend + 1]]
			if {([regexp {[lnmrs]} $prechar] && [regexp {[eiy]} $postchar]) \
			||   (($prechar == "p") && [regexp {[ey]} $postchar])} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "s" 1]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "ld" $cluster]							;#	could should would
		if {$k == 0} {
			set matchlist [list could would should]
			if {[WordBeginsWithAnyOf $origword $matchlist]} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "d" 1]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "mn" $cluster]							;#	hymn, column etc.
		if {($k == 0) && ($wordend == $consend)} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "mm" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]
		}
		set k [string first "zz" $cluster]							;#	mezzo
		if {($k >= 0) && ($wordend != $consend)} {
			set postchar [string index $origword [expr $consend + 1]]
			if {$postchar == "o"} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "ts" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "rz" $cluster]							;#	scherzo
		if {($k >= 0) && ($wordend != $consend)} {
			set postchar [string index $origword [expr $consend + 1]]
			if {$postchar == "o"} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "ts" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
		set k [string first "ld" $cluster]							;#	soldier
		if {($k >= 0) && ([string first "soldier" $origword] == 0)} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "lj" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]

		}
		set k [string first "tz" $cluster]							;#	waltzer
		if {($k == [expr $cluslen - 2])} {
			set cluster [ReplaceLettersInString $cluster $cluslen $k "ts" 2]
			set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
			return [list $word 0]

		}
		set k [string first "pt" $cluster]							;#	receipt-
		if {($k == [expr $cluslen - 2]) && ($constt >= 2)} {
			set teststr [string range $origword [expr $constt - 2] end]
			if {[string first "eipt" $teststr]} {
				set cluster [ReplaceLettersInString $cluster $cluslen $k "tt" 2]
				set word    [ReplaceLettersInString $word $wordlen $constt $cluster $cluslen]
				return [list $word 0]
			}
		}
	}
	if {$cluslen == 1} {		;#	SINGLE CONSONANT
		set afterchars [expr $wordend - $consend]
		set nextchar [expr $consend + 1]
		set prevchar [expr $constt - 1]
		switch -- $cluster {
			"c" {
				if {$afterchars} {
					if {$afterchars >= 4} {
						set jj [expr $consend + 1]
						set kk [expr $consend + 4]
						set matchstr [string range $word $jj $kk]
						if {[string match $matchstr "eous"] \
						||  [string match $matchstr "ious"]} {
							set word [ReplaceLettersInString $word $wordlen $constt "S" 1]
							return [list $word 0]
						}
					} elseif {$afterchars >= 3} {
						set jj [expr $consend + 1]
						set kk [expr $consend + 3]
						set matchstr [string range $word $jj $kk]
						if {[string match $matchstr "ion"]} {
							set word [ReplaceLettersInString $word $wordlen $constt "S" 1]
							return [list $word 0]
						}
					} elseif {([lindex $origword $nextchar] == "e") \
					|| ([lindex $origword $nextchar] == "y")} {
						set word [ReplaceLettersInString $word $wordlen $constt "s" 1]
						return [list $word 0]
					} elseif {$prevchar > 0} {
						set teststr [string range $origword $prevchar end]
						if {[string first "icit" $teststr] == 0} {
							set word [ReplaceLettersInString $word $wordlen $constt "s" 1]
							return [list $word 0]
						}
					}
				}
			}
			"f"	{
				if {[string match $origword "of"]} {
					set word [ReplaceLettersInString $word $wordlen $constt "v" 1]
				}
			}
			"g" {
				if {$afterchars} {
					if {$afterchars >= 4} {
						set jj [expr $consend + 1]
						set kk [expr $consend + 4]
						set matchstr [string range $word $jj $kk]
						if {[string match $matchstr "ious"]} {		;#	sacreligious
							set word [ReplaceLettersInString $word $wordlen $constt "j" 1]
							return [list $word 0]
						}
					} elseif {$afterchars >= 3} {
						set jj [expr $consend + 1]
						set kk [expr $consend + 3]
						set matchstr [string range $word $jj $kk]
						if {[string match $matchstr "ion"]} {		;#	religion
							set word [ReplaceLettersInString $word $wordlen $constt "j" 1]
							return [list $word 0]
						}
					} elseif {$afterchars >= 2} {
						set jj [expr $consend + 1]
						set kk [expr $consend + 2]
						set matchstr [string range $word $jj $kk]
						if {[string match $matchstr "ue"]} {		;#	rogue
							set word [ReplaceLettersInString $word $wordlen $constt "ggg" 3]
							return [list $word 0]
						}
					}
					if {[lindex $origword $nextchar] == "e"} {		;# outrageous, cage
						set word [ReplaceLettersInString $word $wordlen $constt "j" 1]
						return [list $word 0]
					}
				}
			}
			"h"	{
				if {!$afterchars} {
					set word [ReplaceLettersInString $word $wordlen $constt "-" 1]
					return [list $word 0]
				}
			}
			"q"	{
				if {!$afterchars} {
					set word [ReplaceLettersInString $word $wordlen $constt "k" 1]
					return [list $word 0]
				}
				if {[lindex $origword $nextchar] == "u"} {
					set teststr [lrange $origword $k end]
					if {[string match "quer" $teststr]} {			;#	lacquer
						set word [ReplaceLettersInString $word $wordlen $constt "kk--" 4]
						return [list $word 0]
					} elseif {[string match "que" $teststr]} {		;#	macaque
						set word [ReplaceLettersInString $word $wordlen $constt "kkk" 3]
						return [list $word 0]
					} else {										;#	loquacious
						set word [ReplaceLettersInString $word $wordlen $constt "kw" 2]
						return [list $word 1]
					}
				} else {
					set word [ReplaceLettersInString $word $wordlen $constt "k" 1]
					return [list $word 0]
				}
			}
			"s"	{
				if {!$afterchars} {
					set backchar [string index $origword $prevchar]
					if {$backchar == "i"} {
						if {[string match $origword "his"] \
						||  [string match $origword "is"]} {
							set word [ReplaceLettersInString $word $wordlen $constt "z" 1]
							return [list $word 0]
						}
					} elseif {$backchar == "a"} {
						if {[string match $origword "has"] \
						||  [string match $origword "was"]} {
							set word [ReplaceLettersInString $word $wordlen $constt "z" 1]
							return [list $word 0]
						}
					}
				} else {
					set char [string index $origword $nextchar]
					if {$afterchars >= 3} {
						set jj [expr $consend + 1]
						set kk [expr $consend + 3]
						set matchstr [string range $origword $jj $kk]
						if [string match  $matchstr "ure"] {
							if {[string match $origword "sure"} {	;#	sure
								set word [ReplaceLettersInString $word $wordlen $constt "S" 1]
								return [list $word 0]
							} else {								;# pleasure
								set word [ReplaceLettersInString $word $wordlen $constt "Z" 1]
								return [list $word 0]
							}
						} elseif [string match  $matchstr "ing"] {
							set matchlist [list pleasing rising losing nosing imposing]
							if {[WordMatchesAnyOfWords $origword $matchlist] \
							||  ([string first "rising "$origword] >= 0)} {
								set word [ReplaceLettersInString $word $wordlen $constt "z" 1]
								return [list $word 0]
							} else {								;#	else e.g. leasing				
								set word [ReplaceLettersInString $word $wordlen $constt "s" 1]
								return [list $word 0]
							}
						} elseif [string match  $matchstr "ion"] {
							set word [ReplaceLettersInString $word $wordlen $constt "Z" 1]
							return [list $word 0]
						}
					}
					if {$afterchars >= 2} {
						set jj [expr $consend + 1]
						set kk [expr $consend + 2]
						set matchstr [string range $origword $jj $kk]
						if [string match  $matchstr "er"] {
							set matchlist [list repulser censer licenser condenser dispenser relapser]
							if {[WordMatchesAnyOfWords $origword $matchlist] \
							||  ([string first "rser" $origword ] > 0) } {
								set word [ReplaceLettersInString $word $wordlen $constt "s" 1]
								return [list $word 0]
							} else {
								set word [ReplaceLettersInString $word $wordlen $constt "z" 1]
								return [list $word 0]
							}
						} elseif [string match  $matchstr "ed"] {
							if {([string first "iased" $origword ] > 0) \
							||  [string match $origword "deceased"] \
							||  [string match $origword "practised"] } {
								;#	s == s (do nothing)
								return [list $word 0]
							} else {
								set word [ReplaceLettersInString $word $wordlen $constt "z" 1]
								return [list $word 0]
							}
						}
					}
					if {$afterchars >= 1} {
						set jj [expr $consend + 1]
						set matchstr [string index $origword $jj]
						if [string match  $matchstr "e"] {
							set matchlist [list paradise course merchandise premise promise practise obese geese because]
							set containslist [list lease crease grease chase precise concise]
							if {[WordMatchesAnyOfWords $origword $matchlist] \
							||  [WordContainsAnyOf $origword $containslist]} {
								;#	No change
							} else {
								set word [ReplaceLettersInString $word $wordlen $constt "z" 1]
								return [list $word 0]
							}
						}	
					}
				}							
			}
			"t"	{
				if {$afterchars >= 4} {
					set jj [expr $consend + 1]
					set kk [expr $consend + 4]
					set matchstr [string range $origword $jj $kk]
					if {[string match  $matchstr "ious"]} {		;#	-tious
						set word [ReplaceLettersInString $word $wordlen $constt "S" 1]
						return [list $word 0]
					} elseif {[string match  $matchstr "eous"]} {		;#	-teous
						set word [ReplaceLettersInString $word $wordlen $constt "C" 1]
						return [list $word 0]
					}
				}
				if {$afterchars >= 3} {
					set jj [expr $consend + 1]
					set kk [expr $consend + 3]
					set matchstr [string range $origword $jj $kk]
					if {[string match  $matchstr "ion"]} {		;#	-tion
						set word [ReplaceLettersInString $word $wordlen $constt "S" 1]
						return [list $word 0]
					}
				} elseif {[string match $origword "imprimatur"]} {
					set word [ReplaceLettersInString $word $wordlen $constt "C" 1]
					return [list $word 0]
				}
			}
			"n" {
				if {[string match $origword "one"]} {
					set word "w-n"
					return [list $word 1]
				}
			}
			"p" {
				set k [expr $n - 3]
				if {($k >= 0) && [string match [string range $origword $k end] "coup"]} {
					set word [ReplaceLettersInString $word $wordlen $n "-" 1]
				}
			}
			"z" {
				if {[string match $origword "kruezer"]} {
					set word "kr-ts--"
				}
			}
		}
	}
	return [list $word 0]		;#		FAILSAFE
}

#--- is character, or character-string, a vowel ??
#
#	testchar = character to test
#	teststr  = all characters from (& including) testchar to end of word
#	position = position of string in word
#	wordend  = index of last character in word
#

proc IsVowelEquiv {origword teststr testchar position wordend} {

	if {[string first "ough" $teststr] == 0} {
		if {$position >= 2} {
			set m [expr $position - 2]
			set str2 [string range $origword $m end]
			if {([string first "ch" $str2] == 0) \
			||  ([string first "cl" $str2] == 0) \
			||  ([string first "tr" $str2] == 0)} {		;#	chough etc, is vowel, skip 1 character
				return [list 1 3 f]
			}
		}
		if {$position >= 1} {
			set m [expr $position -1]
			set char2 [string index $origword $m]
			if {[string match "c" $char2] \
			||  [string match "h" $char2] \
			||  [string match "n" $char2] \
			||  [string match "l" $char2] \
			||  [string match "r" $char2] \
			||  [string match "t" $char2]} {
				return [list 1 3 f]						;#	cough etc, is vowel, skip 1 character 
			}
		}
		return [list 1 3]								;#	plough etc, is vowel, skip 3 characters
	}
	if {[string first "augh" $teststr] == 0} {			;#	"laugh"
		if {($position == 1) && [string match [string index $origword 0] "l"]} {
			return [list 1 3 f]
		} elseif {$position >= 2} {
			set m [expr $position - 2]
			set str2 [string range $origword $m end]
			if {[string first "dr" $str2] == 0} {		;#	"draught"
				return [list 1 3 f]
			}
		}
		return [list 1 3]
	}
	if {[string first "agh" $teststr] == 0} {			;#	"shelalagh"
		if {$position == [expr $wordend - 2]} {
			return [list 1 2]
		}
	}
	if {[string first "eigh" $teststr] == 0} {			;#	"neigh"
		return [list 1 3]
	}
	if {[string first "igh" $teststr] == 0} {			;#	"high"
		return [list 1 2]
	}
	if {[IsVowel $testchar]} {
		return [list 1 0]
	}
	switch -- $testchar {
		"y" {
			if {$position == 0} {
				return [list 0 0]						;#	"y" at start is a consonant
			} elseif {$position == $wordend} {
				return [list 1 0]						;#	"y" at end is a vowel e.g. "lly", "bay" etc.
			}
			if {$position > 0} {
				set prechar [string index $origword [expr $position - 1]]
				if {$prechar == "w"} {
					return [list 0 0]					;#	"y" in "lawyer"
				}
			}
			set char2 [string index $teststr 1]
			set str2 [string range $teststr 1 end]
			if {[IsVowel $char2]} {				
				if {([string first "i" $str2] == 0) \
				||  ([string first "ed" $str2] == 0) \
				||  ([string first "er" $str2] == 0)} {	;#	"y" followed by "ing" etc. is (part of) vowel
					return [list 1 0]
				}
				return [list 0 0]						;#	otherwise "y" followed by a vowel is a consonant (mostly!!)
			}
			return [list 1 0]							;#	Otherwise it's a vowel (mostly??)
		}
		"w" {
			if {$position >= 1} {
				set m [expr $position - 1]
				set char2 [string index $origword $m]
				if {[IsVowel $char2]} {				
					return [list 1 0]					;#	"w" preceded by a vowel is a vowel
				}
			}
			return [list 0 0]							;#	otherwise it's a consonant
		}
		"r" {
			if {$position == $wordend}  {				;#	"r" at end is (part of) a vowel e.g. er,ar, err, etc.
				return [list 1 0]
			} elseif {$position == 0} {					;#	"r" at start is a consonant
				return [list 0 0]
			}
			set m [expr $position - 1]
			set prechar [string index $origword $m]		;#	check previous letter
			set postchar [string index $teststr 1]		;#	& next letter

			if {[string match $postchar "r"] && ([expr $position + 1] != $wordend)} {
				return [list 0 0]						;#	double "rr" is a consonant, except at word end
			}

			if {[string match $prechar "r"] && ($position != $wordend)} {
				return [list 0 0]						;#	double "rr" is a consonant, except at word end
			} elseif {[IsVowel $prechar] || ($prechar == "y")} {
				if {[IsVowel $postchar] || ($postchar == "y")} {
					if {[string first "red" $teststr] == 0} {
						return [list 1 0]				;#	"ired", "ered" etc = vowel
					} elseif {($postchar == "e") && ([expr $position + 1] == $wordend)} {
						return [list 1 0]				;#	"are"  etc, at word-end, is vowel
					} else {
						return [list 0 0]				;#	else if previous & next letters are vowels, "aro" "ering"  etc, is consonant
					}
				} else {
					return [list 1 0]					;#	if previous letter vowel and next a cons, "ard" etc, is a vowel
				}
			} else {
				return [list 0 0]						;#	"r" after consonant (tr, br) is a consonant
			}
		}
	}
	return [list 0 0]									;#	all others are consonants
}

;#---- Substitute letters into an existing string, overwriting the originals

proc ReplaceLettersInString {thisstring stringlen insertpos letters lettercnt} {
	set nustring ""
	if {$insertpos > 0} {
		append nustring [string range $thisstring 0 [expr $insertpos - 1]]
	}
	append nustring $letters
	incr insertpos $lettercnt
	if {$insertpos < $stringlen} {
		append nustring [string range $thisstring $insertpos end]
	}
	return $nustring
}

#------ converts e.g. CC--TT --> C-T
		
proc RemoveAllPhoneticDoubles {word} {
	set len [string length $word]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set char_n [string index $word $n]
		set basword [string range $word 0 $n]
		set m $n
		incr m
		set k $m
		incr k
		set char_m [string index $word $m]
		if {$k < $len} {
			set topword [string range $word $k end]
		} else {
			set topword ""
		}
		if {[string match $char_n $char_m]} {
			set nuword $basword
			append nuword $topword
			set word $nuword
			incr len_less_one -1
			incr len -1
		} else {
			incr n
		}
	}
	return $word
}

#----- Decide phonetic pronunciation of a final single "s"

proc DoFinalSConversion {origword word} {
	set outlen [string length $word]
	set penultout [expr $outlen - 1]
	set len [string length $origword]
	incr len -1
	set penultchar [string index $origword $len]
	if {[string length $origword] >= 2} {
		incr len -1
		set prepenultchar [string index $origword $len]
	}	
	if {[string length $origword] >= 3} {
		incr len -1
		set preprepenultchar [string index $origword $len]
	}	
	switch -- $penultchar {
		"e" {
			switch -- $prepenultchar {
				"h" {
					if {[string length $origword] >= 4} {
						if {$preprepenultchar == "p"} {		;#	-phes
							append word "s"
						} else {			;#	-thes, -ches, etc.
							append word "z"
						}
					} else {	;#	she's 
						append word "z"
					}
				}
				"f" -
				"k" -
				"p" -
				"t" {					;#	capes etc.
					append word "s"
				}
				default {				;#	babes etc.
					append word "z"
				}
			}
		}
		"h" {
			switch -- $prepenultchar {
				"c" -
				"p" -
				"t" {	;#	ch(lochs), ph(graphs), th(laths)
					append word "s"
				}
				"s" {	;#	sh (-shs probably impossible)				
					append word "s"
				}
				"g" {
					set testchar [string index $word $penultout]	;#	look in output for conversion ough, augh, to vowel, or vowel+f
					switch -- $testchar {
						"f" {
							append word "s"
						}
						default {	;#	"-"
							append word "z"
						}
					}
				}
				default {	;# ??
					append word "z"
				}
			}
		}
		"c" -
		"f" -
		"k" -
		"p" -
		"q" -
		"t" {							;#	caps etc.
			append word "s"
		}
		default  {						;#	dabs etc.
			append word "z"
		}
	}
	return $word	
}

#----- Decide phonetic pronunciation of a final single "e" (before pluralising "s")

proc DoFinalEConversion {origword word s_end} {
	set outlen [string length $word]	;#	FAILSAFE, IN CASE PHONETIC REPRESENTATION FAILS TO BE SAME LENGTH AS ORIG (it should be!!)
	set subend [expr $outlen - 2]
	set len [string length $origword]
	incr len -2
	set penultchar [string index $origword $len]
	if {[string length $origword] >= 3} {
		incr len -1
		set prepenultchar [string index $origword $len]
	}	
	set matchlist [list be maybe me the we ye]
	if {[WordMatchesAnyOfWords $origword $matchlist]} {
		;#	"-e" etc IS VOWEL: do nothing
		return $word
	}
	switch -- $penultchar {
		"a" -
		"e" -
		"i" -
		"o" -
		"u" -
		"y" {
				;#	"-ea" etc. IS A VOWEL (already marked as) do nothing
		}
		"h" {
			if {[info exists prepenultchar]} {
				switch -- $prepenultchar {
					"c" - 
					"g" - 
					"s" {	;# ch, gh, sh
						set matchlist [list attache cliche recherche psyche apache she]
						if {$s_end} {
							;#	"-ches" etc A VOWEL WITH S: do nothing
						} elseif {[WordMatchesAnyOfWords $origword $matchlist]} {
							;#	"-che" etc IS VOWEL: do nothing
						} else {
							;#	IS SILENT "e" : "ache, headache" etc.
							set word [string range $word 0 $subend]
						}
					}
					"p" -
					"t" {
						if {[string match $word "apostrophe"]} {
							;#	-phe IS VOWEL: do nothing
						} else {
							;#	ph, th 	: "-phe, -phes, -the, -thes" etc IS SILENT
							set word [string range $word 0 $subend]
						}
					}
					default { ;# vowels and ?? : "-ade, -ades" etc IS SILENT
						set word [string range $word 0 $subend]
					}
				}
			} else {
				;#	A VOWEL (ee) : do nothing
			}
		}
		"c" -
		"g" -
		"j" -
		"s" -
		"x" -
		"z" {
			if {$s_end} {
				;#	"-ices" etc A VOWEL WITH S: do nothing
			} else {
				;#	"ice" IS SILENT
				set word [string range $word 0 $subend]
			}
		}
		default {
			;#	"-ide, -ides" etc IS SILENT
			set word [string range $word 0 $subend]
		}
	}
	;# MODIFY ANY UNMODIFIED END "g" or "c"
	set len [string length $origword]
	if {$len > 2} {
		set precharpos [expr $len - 2]
		set preprecharpos [expr $len - 3]
		set prechar [string index $word $precharpos]
		set preprechar [string index $origword $preprecharpos]
		if {($prechar == "g") && ($preprechar != "g")} {
			set word [ReplaceLettersInString $word $len $precharpos "j" 1]
		}
		if {($prechar == "c") && ($preprechar != "c")} {
			set word [ReplaceLettersInString $word $len $precharpos "s" 1]
		}
	}
	return $word
}

#---- Select a consonant (cluster) listed in the stats consonant-stats-window as parameter for density search

proc ConstatSelect {y excludes} {
	global constatistics constatstate constatchoice constatcons constatexclude constatexcons constatsonly zerophones
	if {($constatstate == 0) || ($constatstate == 3)} {
		return
	}
	set i [$constatistics nearest $y]
	set consclus [$constatistics get $i]
	if {$constatstate > 1} {
		set consclus [split $consclus]
		set consclus [lindex $consclus end]
	}
	switch -- $excludes {
		1 {			;#	CONSONANT(CLUSTER)S TO EXCLUDE FROM SEARCH
			if {![info exists constatchoice] || ([llength $constatchoice] <= 0)} {	;#	SELECT EXCLUDED ITEMS ONLY AFTER SOME SEARCH-FOR ITEMS SELECTED
				Inf "Select Items To Search For, Before Defining Excluded Items"
				return
			}
			set k [lsearch $constatchoice $consclus]								;#	IF SELECTING AN ITEM TO EXCLUDE FROM SEARCH 
			if {$k >= 0} {															;#	WHICH IS ALREADY IN SEARCH LIST,
				if {[llength $constatchoice] == 1} {								;#	IF IT'S THE ONLY SEARCH ITEM IN THE LIST
					set constatchoice {}											;#	EMPTY BOTH THE SEARCH AND EXCLUDE LISTS
					set constatexclude {}											;#	AND RESET exclude BUTTON TO include,
					set constatcons ""
					set constatexcons ""
					ConExclude 0
					return
				} else {															;#	ELSE DELETE FROM SEARCH LIST BEFORE ADDING TO EXCLUDE LIST
					set constatchoice [lreplace $constatchoice $k $k]
					set constatcons [lindex $constatchoice 0]
					if {[llength $constatchoice] > 1} {
						foreach consxx [lrange $constatchoice 1 end] {
							append constatcons "," $consxx
						}
					}
				}
			}																		;#	THEN
			if {[lsearch $constatexclude $consclus] < 0} {							;#	IF NOT ALREADY IN EXCLUSION LIST, ADD TO EXCLUSION LIST
				lappend constatexclude $consclus
			}
			set constatexcons [lindex $constatexclude 0]
			if {[llength $constatexclude] > 1} {
				foreach consclus [lrange $constatexclude 1 end] {
					append constatexcons "," $consclus
				}
			}
		}
		0 {			;#	CONSONANT(CLUSTER)S TO INCLUDE IN SEARCH
			if {[info exists constatexclude] && ([llength $constatexclude] > 0)} {	;#	IF SELECTING SEARCH ITEM WHICH IS ALREADY IN EXCLUSION LIST
				set k [lsearch $constatexclude $consclus]							;#	DELETE FROM EXCLUSION LIST BEFORE PUTTING IN SEARCH LIST
				if {$k >= 0} {
					set constatexclude [lreplace $constatexclude $k $k]
					set constatexcons [lindex $constatexclude 0]
					if {[llength $constatexclude] > 1} {
						foreach consxx [lrange $constatexclude 1 end] {
							append constatexcons "," $consxx
						}
					}
				}
			}
			if { $constatsonly && ([lsearch $zerophones $consclus] >= 0)} {
				Inf "This Item Is Never Used Independently"
				return
			}
			if {[lsearch $constatchoice $consclus] < 0} {							;#	IF NOT ALREADY IN SEARCH LIST, ADD TO SEARCH LIST
				lappend constatchoice $consclus
			}
			set constatcons [lindex $constatchoice 0]
			if {[llength $constatchoice] > 1} {
				foreach consclus [lrange $constatchoice 1 end] {
					append constatcons "," $consclus
				}
			}
		}
		2 {	;#	ITEMS SELECT TO SAVE TO FILE OR PUT ON CHOSEN LIST
		}
	}
}

#----- Help Info for Consonant Statistics 

proc ConstatsHelp {} {
	set msg "CONSONANT STATISTICS\n"
	append msg "\n"
	append msg "(1) SEE STATISTICS : occurences of consonants & consonant clusters\n"
	append msg "\n"
	append msg "        These can be displayed...\n"
	append msg "        (a)  in order of frequency of occurence.\n"
	append msg "        (b)  in alphabetic order.\n"
	append msg "        (c)  alphabetic, with no frequency-of-occurence-data (\"raw\").\n"
	append msg "\n"
	append msg "(2)  DO SEARCH: Find Knots of high density of consonant(cluster)s\n"
	append msg "        (only AFTER \"See Statistics\")\n"
	append msg "\n"
	append msg "        (a) Select consonants or clusters by clicking on stats display.\n"
	append msg "        (b) Possibly select items to exclude from search OR\n"
	append msg "        (c) Reject items occuring WITHIN larger cluster (click \"only\").\n"
	append msg "        (d) \"Density\": min proportion syllables containing chosen consonants,\n"
	append msg "                   to be \"high density\" (UP/DOWN arrows change value)\n"
	append msg "        (e) \"Minimum Items\" min number events in any high-density occurence.\n"
	append msg "                   (RIGHT/LEFT arrows change value)\n"
	append msg "\n"
	append msg "(3)  REANALYSE DATA: (Only from Table display of properties file)\n"
	append msg "         if \"text\" table-data changed, \"Force Reanalysis\" of data\n"
	append msg "\n"
	append msg "(4) OUTPUT RESULTS: as texts- or sounds-found to Chosen Files or to a File.\n"
	append msg "         (Output options appear only AFTER search completed).\n"
	append msg "\n"
	append msg "(5) SAVE STATISTICS: Statistics for this properties file can be saved,\n"
	append msg "         or added to total stats count over several properties files.\n"
	append msg "         (CARE: saving stats of individual file IGNORES directory path.\n"
	append msg "          If you have 2 propfiles with same name in different directories\n"
	append msg "          their saved data will overwrite each others).\n"
	append msg "\n"
	append msg "Consonant(cluster)s compared using actual sound (phonetic equivalent)\n"
	append msg "Explanantion of \"Phonetic\" representation appears, once Stats displayed.\n"
	append msg "        (a)  Letters \"r\",\"w\", and \"y\" may be vowel, or consonant.\n"
	append msg "             \"Phonetic\" symbols \"r\",\"w\",\"y\" only for consonant-use.\n"
	append msg "        (b)  Groupings like \"gh\", (\"f\", or part of vowel) disambiguated.\n"
	Inf $msg
}

#---- Remove non-alphabetic chars from word=representations from text property

proc StripNonAlpha {word} {
	set outword ""
	set len [string length $word]
	set n 0
	while {$n < $len} {
		set char [string index $word $n]
		if {[regexp {[a-z]} $char]} {
			append outword $char
		}
		incr n
	}
	return $outword
}

#------ Does word match any in wordlist ??

proc WordMatchesAnyOfWords {word wordlist} {
	foreach matchword $wordlist {
		if {[string match $word $matchword]} {
			return 1
		}
	}
	return 0
}

#------ Does word contain any string in wordlist ??

proc WordContainsAnyOf {word wordlist} {
	foreach matchword $wordlist {
		if {[string first $matchword $word] >= 0} {
			return 1
		}
	}
	return 0
}

#------ Does word begin with any string in wordlist ??

proc WordBeginsWithAnyOf {word wordlist} {
	foreach matchword $wordlist {
		if {[string first $matchword $word] == 0} {
			return 1
		}
	}
	return 0
}

#------ Does word end with any string in wordlist ??

proc WordEndsWithAnyOf {word wordlist} {
	set wlen [string length $word]
	foreach matchword $wordlist {
		set mlen [string len $matchword]
		set k [expr $wlen - $mlen]
		if {$k >= 0} {
			if {[string first $matchword [string range $word $k end]] == 0} {
				return 1
			}
		}
	}
	return 0
}

#------- Is monosyllabic		i.e. ending OR vowel(s)+ending OR consonant(s)+ending BUT NOT vowel(s)+consonant(s)+ending (= pollysyllabic)

proc IsMonosyllabic {word ending} {
	set wlen [string length $word]
	set endlen [string length $ending]
	set k [expr $wlen - $endlen]
	if {$k == 0} {
		return 1
	}
	set hascons 0
	while {$k > 0} {	
		incr k -1
		set char [string index $word $k]
		if {[IsVowel $char]} {
			if {$hascons} {
				return 0
			}
		} else {
			set hascons 1
		}
		incr k -1
	}
	return 1
}

#---- Set up Consonant Statistics interface to search only for exact copies of items in search list

proc ConstatsOnly {} {
	global constatexclude constatexcons constatsonly constatchoice constatcons zerophones
	if {$constatsonly} {
		ConExclude 0
		set constatexclude {}
		set constatexcons ""
	}
	set dochange 0						;#	ON CHANGING TO WHOLE-CLUSTER ONLY,
	set len [llength $constatchoice]	;#	EXCLUDE ANY CLUSTERS THAT NEVER APPEAR AS WHOLE-CLUSTERS
	set n 0
	while {$n < $len} {
		set consclus [lindex $constatchoice $n]
		set k [lsearch $zerophones $consclus]
		if {$k >= 0} {
			set dochange 1
			set constatchoice [lreplace $constatchoice $n $n]
			incr len -1
		} else {
			incr n
		}
	}
	if {$dochange} {
		if {[llength $constatchoice] <= 0} {
			set constatcons ""
		} else {
			set constatcons [lindex $constatchoice 0]
			if {[llength $constatchoice] > 1} {
				foreach consclus [lrange $constatchoice 1 end] {
					append constatcons "," $consclus
				}
			}
		}
	}
}

#---- Set up Consonant Statistics interface to put selected list items in excluded-items list, or in search list

proc ConExclude {excludestate} {
	global constatistics constatsonly con_exclude
	if {$excludestate} {
		if {$constatsonly} {
			Inf "No Exclusions Necessary In \"Only\" Mode"
			set con_exclude 0
			return
		}
		bind $constatistics <ButtonRelease-1> {}
		bind $constatistics <ButtonRelease-1> {ConstatSelect %y 1}
		set con_exclude 1
	} else {
		bind $constatistics <ButtonRelease-1> {}
		bind $constatistics <ButtonRelease-1> {ConstatSelect %y 0}
		set con_exclude 0
	}
}

#---- Clear all selected search-clusters, and all exclude-from-search clusters

proc ConstatsClearAll {} {
	global constatcons constatchoice constatexcons constatexclude constatsonly
	set constatcons ""
	set constatchoice {}
	set constatexcons ""
	set constatexclude {}
	set constatsonly 0
	ConExclude 0
}

#---- Clear all exclude-from-search clusters

proc ConstatsClearExcludes {} {
	global constatexcons constatexclude
	set constatexcons ""
	set constatexclude {}
}

#--- Change value of constatsmin with up/dn arrows

proc ConstatMinChange {up} {
	global constatsmin
	if {$up} {
		incr constatsmin
	} elseif {$constatsmin > 1} {
		incr constatsmin -1
	}
}
		
#--- Change value of constatsdens with left/right arrows

proc ConstatDensChange {up} {
	global constatdens
	set len [string length $constatdens]
	set endindex [expr $len - 1]
	if {$up} {
		if {$constatdens == 1} {
			return
		} elseif {$constatdens == 0} {
			set constatdens .01
		} else {
			set k [string first "." $constatdens]
			set z [string range $constatdens [expr $k + 1] end]
			set origzlen [string length $z]
			set z [StripLeadingZeros $z]
			set newzlen [string length $z]
			incr z
			set finalzlen [string length $z]
			set zerosneeded [expr $origzlen - $finalzlen]
			if {$zerosneeded < 0} {
				set constatdens 1
			} else {
				if {$zerosneeded > 0} {
					set zeros ""
					set kk 0
					while {$kk < $zerosneeded} {
						append zeros 0
						incr kk
					}
					append zeros $z
					set z $zeros
				}
				set constatdens 0.
				append constatdens $z
			}
		}
	} else {
		if {$constatdens == 0} {
			return
		} elseif {$constatdens == 1} {
			set constatdens .99
		} else {
			set k [string first "." $constatdens]
			set z [string range $constatdens [expr $k + 1] end]
			incr z -1
			if {$z == 0} {
				set constatdens "0"
			} else {
				set constatdens "0."
				append constatdens $z
			}
		}
	}
}

#####################################
# (B) COMPARING RHYMES & WORDSTARTS #
#####################################

proc TextPropRhyme {wordstarts in_fnam} {
	global ts_propfile pr_rhymestats rhyisalpha rhylist rhymesoutfnam rhystatistics rhystatstate rhystatchoice 
	global rhymestats rhyalphastats rhyfrqstats rhymetexts rhymesnds totalrhystats totalrhystats_files
	global sttalphastats sttfrqstats totalsttstats totalsttstats_files sttstats rhyinclude 
	global props_info ts_props_list ts_propnames propfiles_list readonlyfg readonlybg chlist ch wl rememd wstk evv
	global sttexalphastats sttexfrqstats

	if {$wordstarts} {
		set stattype "Start-Syllable"
	} else {
		set stattype "Rhyme"
	}
	set propsfile [GetPropsDataFromFile $in_fnam]
	if {[string length $propsfile] <= 0} {
		return
	}
	set do 1
	set force_do 0
	if {[info exists ts_propfile]} {
		if {![string match $ts_propfile $propsfile]} {
			set force_do 1
		}
	}
	set ts_propfile $propsfile
	if {!$force_do} {
		if {$wordstarts} {
			if {[info exists sttstats]} {
				set msg "Refresh Existing Start-Syllable Statistics ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					set do 0
				}
			}
		} else {
			if {[info exists rhymestats]} {
				set msg "Refresh Existing Rhyme Statistics ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					set do 0
				}
			}
		}
	}
	if {$do} {
		Block "Generating $stattype Statistics"
		if {![GenerateRhymeStatistics $wordstarts]} {
			UnBlock
			return
		}
		UnBlock
	}
	set rhyinclude 1
	set rhymesoutfnam ""
	set f .rhymestats
	if [Dlg_Create $f "$stattype Statistics For [file rootname [file tail $ts_propfile]]" "set pr_rhymestats 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		set f1a [frame $f.1a -bg $evv(POINT) -height 1]
		set f2 [frame $f.2]
		set f2a [frame $f.2a -bg $evv(POINT) -height 1]
		set f3 [frame $f.3]
		set f3a [frame $f.3a -bg $evv(POINT) -height 1]
		set f4 [frame $f.4]
		set f5 [frame $f.5]
		button $f0.quit -text "Quit" -command {set pr_rhymestats 0} -width 10 -highlightbackground [option get . background {}]
		if {$wordstarts} {
			button $f0.help -text "Help" -command {SttHelp} -bg $evv(HELP)
			pack $f0.help -side left
		}
		button $f0.stat -text "See Statistics" -command {set pr_rhymestats 1} -width 22 -highlightbackground [option get . background {}]
		radiobutton $f0.r1 -variable rhyisalpha -text "By Frequency" -value 0
		radiobutton $f0.r2 -variable rhyisalpha -text "Alphabetic" -value 1
		pack $f0.quit -side right
		pack $f0.stat $f0.r1 $f0.r2 -side left
		if {$wordstarts} {
			radiobutton $f0.r3 -variable rhyinclude -text "Exact" -value 0 
			radiobutton $f0.r4 -variable rhyinclude -text "Starts With" -value 1
			menubutton $f0.other -text "" -menu $f0.other.menu -relief raised -bd 0 
			set m [menu $f0.other.menu -tearoff 0]
			$m add command -label "" -command {} -foreground black
			$m add command -label "" -command {} -foreground black
			$m add command -label "" -command {} -foreground black
			$m add command -label "" -command {} -foreground black
			pack $f0.r3 $f0.r4 $f0.other -side left
		} 
		pack $f0 -side top -fill x -expand true -pady 2
		
		button $f1.save -text "" -command {} -width 18 -bd 0 -highlightbackground [option get . background {}]
		button $f1.totl -text "" -command {} -width 18 -bd 0 -highlightbackground [option get . background {}]
		pack $f1.totl $f1.save -side right -padx 2
		pack $f1 -side top -fill x -expand true -pady 2
		pack $f1a -side top -fill x -expand true -pady 2

		button $f2.ser -text "" -command {} -bd 0 -highlightbackground [option get . background {}]
		label $f2.ll -text ""
		entry $f2.e -textvariable rhylist -state readonly -bd 0 -fg $readonlyfg -readonlybackground $readonlybg
		button $f2.clr -text "" -command {} -bd 0 -highlightbackground [option get . background {}]
		pack $f2.ser $f2.ll $f2.e $f2.clr -side left
		pack $f2 -side top
		pack $f2a -side top -fill x -expand true -pady 2

		label $f3.out -text ""
		button $f3.snd -text "" -bd 0 -command {} -highlightbackground [option get . background {}]
		button $f3.add -text "" -bd 0 -command {} -highlightbackground [option get . background {}]
		label $f3.ll -text ""
		entry $f3.e -textvariable rhymesoutfnam -bd 0 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
		button $f3.txt -text "" -bd 0 -command {} -highlightbackground [option get . background {}]
		button $f3.prp -text "" -bd 0 -command {} -highlightbackground [option get . background {}]

		pack $f3.out $f3.snd $f3.add $f3.ll $f3.e $f3.txt $f3.prp -side left -padx 2
		pack $f3 -side top -fill x -expand true -pady 2
		pack $f3a -side top -fill x -expand true -pady 2

		label $f4.l1 -text "" -fg $evv(SPECIAL)
		label $f4.l2 -text "" -fg $evv(SPECIAL)
		label $f4.l3 -text "" -fg $evv(SPECIAL)
		label $f4.l4 -text "" -fg $evv(SPECIAL)
		pack $f4.l1 $f4.l2 $f4.l3 $f4.l4 -side top
		pack $f4 -side top -pady 2

		set rhystatistics [Scrolled_Listbox $f5.ll -width 132 -height 40 -selectmode single]
		pack $f5.ll -side top -fill both -expand true
		pack $f5 -side top -pady 2
		bind .rhymestats <Control-Key-Up> {RhymeGoto top}
		bind .rhymestats <Control-Key-Down> {RhymeGoto bottom}
		wm resizable $f 1 1
		bind $f <Return> {set pr_rhymestats 1}
		bind $f <Escape> {set pr_rhymestats 0}
	}
	$rhystatistics delete 0 end
	set rhyisalpha -1
	set rhystatstate 0
	set rhylist ""
	set rhystatchoice {}
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_rhymestats 0
	My_Grab 0 $f pr_rhymestats
	while {!$finished} {
		tkwait variable pr_rhymestats
		switch -- $pr_rhymestats {
			0 {
				set finished 1
			}
			1 {
				if {$rhyisalpha < 0} {
					Inf "Specify Display As Alphabetic Or By Frequency Of Occurence"
					continue
				}
				$rhystatistics delete 0 end
				if {$wordstarts} {
					if {$rhyinclude} {
						if {$rhyisalpha} {
							set displaylist $sttalphastats
						} else {
							set displaylist $sttfrqstats
						}
					} else {
						if {$rhyisalpha} {
							set displaylist $sttexalphastats
						} else {
							set displaylist $sttexfrqstats
						}
					}
				} else {
					if {$rhyisalpha} {
						set displaylist $rhyalphastats
					} else {
						set displaylist $rhyfrqstats
					}
				}
				set n 0
				set rhymarked ""
				if {[llength $rhystatchoice] > 0} {
					set rhymarked [lindex $rhystatchoice 0]
				}
				foreach {frq val} $displaylist {
					set line $frq
					append line "  " $val
					$rhystatistics insert end $line
					if {[string match $val $rhymarked]} {
						$rhystatistics selection clear 0 end
						$rhystatistics selection set $n
						$rhystatistics yview moveto [expr double($n)/double([$rhystatistics index end])]
					}
					incr n
				}
				if {$wordstarts} {
					$f0.other config -text "Further Options" -bd 2
					$f0.other.menu entryconfig 0 -label "Start With Vowel(s)" -command "StartCharOptions 1 1"
					$f0.other.menu entryconfig 1 -label "Start With Consonant(s)" -command "StartCharOptions 0 1"
					$f0.other.menu entryconfig 2 -label "Leading to Vowel(s)" -command "StartCharOptions 1 0"
					$f0.other.menu entryconfig 3 -label "Leading to Consonant(s)" -command "StartCharOptions 0 0"
				}
				.rhymestats.1.save config -text "Save Statistics" -command "set pr_rhymestats 7" -bd 2
				.rhymestats.1.totl config -text "Add to Total Stats" -command "set pr_rhymestats 8" -bd 2
				.rhymestats.2.ser  config -text "Do Search For Selected Items" -command "set pr_rhymestats 2" -width 28 -bd 2
				.rhymestats.2.ll   config -text "(select search items from display) "
				.rhymestats.2.e    config -bd 2
				.rhymestats.2.clr  config -text "Clear Choice" -command {set rhystatchoice {}; set rhylist ""} -bd 2
				.rhymestats.4.l1   config -text "PHONETIC REPRESENTATION"
				.rhymestats.4.l2   config -text "\".\" (schwa) ~ \":\" (hurt) ~ \"a\" (cat) ~ \"A\" (cart)  ~ \"4\" (rate) ~ \"e\" (bet) ~ \"E\" (bare) ~ \"i\" (bit) ~ \"I\" (beet) ~ \"o\" (pot) ~ \"O\" (port) ~ \"@\" (rote) ~ \"u\" (foot) ~ \"U\" (boot)"
				.rhymestats.4.l3   config -text "\[then diphthongs \"ai\" (kite) \"iU\" (beauty) etc\]                              \"m\"   \"n\"   \"N\" (=ng as in ring)   \"l\"   \"r\"                              \"b\"   \"d\"   \"g\"   \"k\"   \"p\"   \"t\""
				.rhymestats.4.l4   config -text "\"T\" (=th in lath)   \"7\" (=th in that)    \"h\"   \"X\" (=ch in loch)   \"f\"   \"v\"   \"j\"   \"s\"   \"S\" (=sh)   \"z\"   \"Z\" (=zh in occassion)  \"C\" (=ch in arch)"
				.rhymestats.3.out  config -text ""
				.rhymestats.3.snd  config -text "" -bd 0 -command {}
				.rhymestats.3.add  config -text "" -bd 0 -command {}
				.rhymestats.3.ll   config -text ""
				.rhymestats.3.e    config -bd 0 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
				.rhymestats.3.txt  config -text "" -bd 0 -command {}
				.rhymestats.3.prp  config -text "" -bd 0 -command {}
				$rhystatistics config -selectmode single
				bind $rhystatistics <ButtonRelease-1> {RhySelect %y 0 0 0}
				bind $rhystatistics <Shift-ButtonRelease-1> {RhySelect %y 1 0 0}
				bind .rhymestats <Up> {RhySelect %y 0 1 0}
				bind .rhymestats <Down> {RhySelect %y 0 1 1}
				bind .rhymestats <Shift-Up> {RhySelect %y 1 1 0}
				bind .rhymestats <Shift-Down> {RhySelect %y 1 1 1}
				bind .rhymestats <Key-.> {RhymeGoto .}
				bind .rhymestats <Key-:> {RhymeGoto :}
				bind .rhymestats <Key-a> {RhymeGoto a}
				bind .rhymestats <Shift-Key-A> {RhymeGoto A}
				bind .rhymestats <Key-4> {RhymeGoto 4}
				bind .rhymestats <Key-e> {RhymeGoto e}
				bind .rhymestats <Shift-Key-E> {RhymeGoto E}
				bind .rhymestats <Key-i> {RhymeGoto i}
				bind .rhymestats <Shift-Key-I> {RhymeGoto I}
				bind .rhymestats <Key-o> {RhymeGoto o}
				bind .rhymestats <Shift-Key-O> {RhymeGoto O}
				bind .rhymestats <Key-@> {RhymeGoto @}
				bind .rhymestats <Key-u> {RhymeGoto u}
				bind .rhymestats <Shift-Key-U> {RhymeGoto U}
				bind .rhymestats <Key-m> {RhymeGoto m}
				bind .rhymestats <Key-n> {RhymeGoto n}
				bind .rhymestats <Shift-Key-N> {RhymeGoto N}
				bind .rhymestats <Key-l> {RhymeGoto l}
				bind .rhymestats <Key-r> {RhymeGoto r}
				bind .rhymestats <Key-b> {RhymeGoto b}
				bind .rhymestats <Key-d> {RhymeGoto d}
				bind .rhymestats <Key-g> {RhymeGoto g}
				bind .rhymestats <Key-k> {RhymeGoto k}
				bind .rhymestats <Key-p> {RhymeGoto p}
				bind .rhymestats <Key-t> {RhymeGoto t}
				bind .rhymestats <Shift-Key-T> {RhymeGoto T}
				bind .rhymestats <Key-7> {RhymeGoto 7}
				bind .rhymestats <Key-h> {RhymeGoto h}
				bind .rhymestats <Shift-Key-X> {RhymeGoto X}
				bind .rhymestats <Key-f> {RhymeGoto f}
				bind .rhymestats <Key-v> {RhymeGoto v}
				bind .rhymestats <Key-j> {RhymeGoto j}
				bind .rhymestats <Key-s> {RhymeGoto s}
				bind .rhymestats <Shift-Key-S> {RhymeGoto S}
				bind .rhymestats <Key-z> {RhymeGoto z}
				bind .rhymestats <Shift-Key-Z> {RhymeGoto Z}
				bind .rhymestats <Shift-Key-C> {RhymeGoto C}
				set rhymesoutfnam ""
				set rhystatstate 1
			}
			2 {		;#	SEARCH FOR GIVEN RHYMES IN TEXTS

				if {[llength $rhystatchoice] <= 0} {
					Inf "No Search Items Selected"
					continue
				}
				if {![FindSpecifiedRhymesInTextsOfTextProperty $wordstarts]} {
					continue
				}
				if {$wordstarts} {
					.rhymestats.0.other config -text "" -bd 0
					$f0.other.menu entryconfig 0 -label "" -command {}
					$f0.other.menu entryconfig 1 -label "" -command {}
					$f0.other.menu entryconfig 2 -label "" -command {}
					$f0.other.menu entryconfig 3 -label "" -command {}
				}
				.rhymestats.4.l1 config -text ""
				.rhymestats.4.l2 config -text ""
				.rhymestats.4.l3 config -text ""
				.rhymestats.4.l4 config -text "Select items with mouse to save to file, or to send to Chosen List"
				.rhymestats.3.out config -text "OUTPUT"
				.rhymestats.3.snd config -text "Snds As Chosen Files" -bd 2 -command "set pr_rhymestats 5"
				.rhymestats.3.add config -text "Add To Chosen Files" -bd 2 -command "set pr_rhymestats 6"
				.rhymestats.3.ll config -text "Filename "
				.rhymestats.3.e config -bd 2 -state normal
				.rhymestats.3.txt config -text "Texts to Textfile" -bd 2 -command "set pr_rhymestats 3"
				.rhymestats.3.prp config -text "Snds To New Propfile" -bd 2 -command "set pr_rhymestats 4"
				$rhystatistics config -selectmode extended
				bind $rhystatistics <ButtonRelease-1> {}
				bind $rhystatistics <Shift-ButtonRelease-1> {}
				bind .rhymestats <Up> {}
				bind .rhymestats <Down> {}
				bind .rhymestats <Shift-Up> {}
				bind .rhymestats <Shift-Down> {}
				bind .rhymestats <Key-.> {}
				bind .rhymestats <Key-:> {}
				bind .rhymestats <Key-a> {a}
				bind .rhymestats <Shift-Key-A> {}
				bind .rhymestats <Key-4> {}
				bind .rhymestats <Key-e> {}
				bind .rhymestats <Shift-Key-E> {}
				bind .rhymestats <Key-i> {}
				bind .rhymestats <Shift-Key-I> {}
				bind .rhymestats <Key-o> {}
				bind .rhymestats <Shift-Key-O> {}
				bind .rhymestats <Key-@> {}
				bind .rhymestats <Key-u> {}
				bind .rhymestats <Shift-Key-U> {}
				bind .rhymestats <Key-m> {}
				bind .rhymestats <Key-n> {}
				bind .rhymestats <Shift-Key-N> {}
				bind .rhymestats <Key-l> {}
				bind .rhymestats <Key-r> {}
				bind .rhymestats <Key-b> {}
				bind .rhymestats <Key-d> {}
				bind .rhymestats <Key-g> {}
				bind .rhymestats <Key-k> {}
				bind .rhymestats <Key-p> {}
				bind .rhymestats <Key-t> {}
				bind .rhymestats <Shift-Key-T> {}
				bind .rhymestats <Key-7> {}
				bind .rhymestats <Key-h> {}
				bind .rhymestats <Shift-Key-X> {}
				bind .rhymestats <Key-f> {}
				bind .rhymestats <Key-v> {}
				bind .rhymestats <Key-j> {}
				bind .rhymestats <Key-s> {}
				bind .rhymestats <Shift-Key-S> {}
				bind .rhymestats <Key-z> {}
				bind .rhymestats <Shift-Key-Z> {}
				bind .rhymestats <Shift-Key-C> {}
				set rhystatstate 2
			}
			3 {		;#	TEXTS TO FILE
				if {![info exists rhymetexts]} {
					Inf "No Texts Found To Store"
					continue
				}
				if {[string length $rhymesoutfnam] <= 0} {
					Inf "No Outfile Name Entered"
					continue
				}
				set outfnam [string tolower $rhymesoutfnam]
				if {![ValidCDPRootname $rhymesoutfnam]} {
					continue
				}
				catch {unset rhysavetxts}
				set ilist [$rhystatistics curselection]
				if {([llength $ilist] == 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					set msg "All Of The Listed Items ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Select Items To Save With Mouse"
						continue
					} else {
						set rhysavetxts $rhymetexts
					}
				} else {
					foreach i $ilist {
						lappend rhysavetxts [lindex $rhymetexts $i]
					}
				}
				set outfnam $rhymesoutfnam
				append outfnam $evv(TEXT_EXT)
				if {[file exists $outfnam]} {
					set msg "File '$outfnam' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if {[DeleteFileFromSystem $outfnam 0 1]} {
						set i [LstIndx $outfnam $wl]
						if {$i >= 0} {
							$wl delete $i
							WkspCnt [$wl get $i] -1
							catch {unset rememd}
							DummyHistory $outfnam "DESTROYED"
						}
					} else {
						continue
					}
				}
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot Open File '$outfnam' To Write Data"
					continue
				}
				foreach txt $rhysavetxts {
					puts $zit $txt
				}
				close $zit
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "File '$outfnam' Is On The Workspace"
			}
			4 {		;#	SNDS SELECTED TO PROPSFILE
				if {![info exists rhymesnds]} {
					Inf "No Items Found To Store"
					continue
				}
				if {[string length $rhymesoutfnam] <= 0} {
					Inf "No Outfile Name Entered"
					continue
				}
				set outfnam [string tolower $rhymesoutfnam]
				if {![ValidCDPRootname $rhymesoutfnam]} {
					continue
				}
				catch {unset rhysavesnds}
				set ilist [$rhystatistics curselection]
				if {([llength $ilist] == 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					set msg "All Of The Listed Items ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Select Items To Save With Mouse"
						continue
					} else {
						set rhysavesnds $rhymesnds
					}
				} else {
					foreach i $ilist {
						lappend rhysavesnds [lindex $rhymesnds $i]
					}
				}
				append outfnam [GetTextfileExtension props] 
				if {[string match $ts_propfile $outfnam]} {
					Inf "You Cannot Overwrite The Input Property File Here"
					continue
				}
				catch {unset snds}
				foreach no $rhysavesnds {
					set line [lindex $ts_props_list $no]
					lappend snds [lindex $line 0]
				}
				set sndnos $rhysavesnds
				if {[file exists $outfnam]} {
					set msg "File '$outfnam' Already Exists: Append This Data To It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set orig_props_info $props_info
						if {![ThisIsAPropsFile $outfnam 0 0]} {
							Inf "'$outfnam' Is Not A Properties File"
							set props_info $orig_props_info
							continue
						}
						set orig_ts_propnames [lindex $props_info 0]
						set orig_ts_props_list [lindex $props_info 1]
						set props_info $orig_props_info
						set OK 1
						foreach nam $ts_propnames orignam $orig_ts_propnames {
							if {![string match $nam $orignam]} {
								Inf "Properties In File '$outfnam' Do Not Correspond To Properties Of New Sounds"
								set OK 0
								break
							}
						}
						if {!$OK} {
							continue
						}
						catch {unset orig_snds}
						foreach line $orig_ts_props_list {
							lappend orig_snds [lindex $line 0]
						}
						set len [llength $snds]
						set n 0
						while {$n < $len} {
							set thissnd  [lindex $snds $n]
							if {[lsearch $orig_snds $thissnd] >= 0} {
								set snds [lreplace $snds $n $n]
								set sndnos [lreplace $sndnos $n $n]
								incr len -1
							} else {
								incr n
							}
						}
						if {$len <= 0} {
							Inf "All These Sounds Are Already In File '$outfnam'"
							continue
						}
						catch {unset nu_props_list}
						foreach line $orig_ts_props_list {
							lappend nu_props_list $line
						}
						foreach lineno $sndnos {
							lappend nu_props_list [lindex $ts_props_list $lineno]
						}
						set tmpfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
						if [catch {open $tmpfnam w} zit] {
							Inf "Cannot Open Temporary File To Store Enlarged Properties Listing."
							continue
						}
						puts $zit $ts_propnames
						foreach line $nu_props_list {
							puts $zit $line
						}
						close $zit
						set i [LstIndx $outfnam $wl]
						if {![DeleteFileFromSystem $outfnam 0 1]} {
							set msg "Cannot Delete Original File '$outfnam'"
							append msg "\n\nthe New Data Is In File '$tmpfnam'"
							append msg "\n\nrename This File, Outside The CDP, Before Quitting This Dialogue Box"
							Inf $msg
						} else {
							DummyHistory $outfnam "DESTROYED"
							if {[info exists propfiles_list]} {
								set k [lsearch $propfiles_list $outfnam]
								if {$k > 0} {
									set propfiles_list [lreplace $propfiles_list $k $k]
								}
							}
							if {$i >= 0} {
								WkspCnt [$wl get $i] -1
								$wl delete $i
								catch {unset rememd}
							}
							if [catch {file rename $tmpfnam $outfnam} zit] {
								set msg "Cannot Rename Appended Properties Files To '$outfnam'"
								append msg "\n\nThe New Data Is In File '$tmpfnam'"
								append msg "\n\nRename This File, Outside The CDP, Before Quitting This Dialogue Box"
								Inf $msg
							}
						}
						FileToWkspace $outfnam 0 0 0 0 1
						Inf "File '$outfnam' Is On The Workspace"
						set finished 1
					} else {
						set msg "Overwrite Existing Property File '$outfnam' ?"
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						set i [LstIndx $outfnam $wl]
						if {![DeleteFileFromSystem $outfnam 0 1]} {
							Inf "Cannot Delete Existing File '$outfnam'"
							continue
						} else {
							DummyHistory $outfnam "DESTROYED"
							if {[info exists propfiles_list]} {
								set k [lsearch $propfiles_list $outfnam]
								if {$k > 0} {
									set propfiles_list [lreplace $propfiles_list $k $k]
								}
							}
							if {$i >= 0} {
								WkspCnt [$wl get $i] -1
								$wl delete $i
								catch {unset rememd}
							}
						}
					}
				}
				if {!$finished} {
					if [catch {open $outfnam "w"} zit] {
						Inf "Cannot Create File '$outfnam' To Write Data"
						continue
					}
					puts $zit $ts_propnames
					foreach lineno $sndnos {
						puts $zit [lindex $ts_props_list $lineno]
					}
					close $zit
					FileToWkspace $outfnam 0 0 0 0 1
					Inf "File '$outfnam' Is On The Workspace"
				} else {
					set finished 0
				}
			}
			5 {		;#	SNDS SELECTED TO CHOSEN FILES LIST

				if {![info exists rhymesnds]} {
					Inf "No Items Selected To Store"
					continue
				}
				catch {unset rhysavesnds}
				set ilist [$rhystatistics curselection]
				if {([llength $ilist] == 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					set msg "All Of The Listed Items ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Select Items To Save With Mouse"
						continue
					} else {
						set rhysavesnds $rhymesnds
					}
				} else {
					foreach i $ilist {
						lappend rhysavesnds [lindex $rhymesnds $i]
					}
				}
				catch {unset snds}
				foreach no $rhysavesnds {
					set line [lindex $ts_props_list $no]
					lappend snds [lindex $line 0]
				}
				set n 0
				set len [llength $snds]
				while {$n < $len} {	
					set fnam [lindex $snds $n]
					if {[LstIndx $fnam $wl] < 0} {
						if {![file exists $fnam]} {
							set snds [lreplace $snds $n $n]
							incr len -1
						} elseif {[FileToWkspace $fnam 0 0 0 0 0] <= 0} {
							set snds [lreplace $snds $n $n]
							incr len -1
						} else {
							incr n
						}
					} else {
						incr n
					}
				}
				if {[llength $snds] > 0} {
					DoChoiceBak
					set chlist $snds
					$ch delete 0 end
					foreach fnam $chlist {
						$ch insert end $fnam
					}
					Inf "Files Are Now On The Chosen Files List"
				} else {
					Inf "Cannot Get Any Of These Sounds To The Workspace"
				}
			}
			6 {		;#	SNDS SELECTED ADDED TO CHOSEN FILES LIST
				if {![info exists rhymesnds]} {
					Inf "No Items Selected To Store"
					continue
				}
				catch {unset rhysavesnds}
				set ilist [$rhystatistics curselection]
				if {([llength $ilist] == 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					set msg "All Of The Listed Items ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Select Items To Save With Mouse"
						continue
					} else {
						set rhysavesnds $rhymesnds
					}
				} else {
					foreach i $ilist {
						lappend rhysavesnds [lindex $rhymesnds $i]
					}
				}
				catch {unset snds}
				foreach no $rhysavesnds {
					set line [lindex $ts_props_list $no]
					lappend snds [lindex $line 0]
				}
				set remaining_snds {}
				foreach snd $snds {
					if {[lsearch $chlist $snd] < 0} {
						lappend remaining_snds $snd
					}
				}
				if {[llength $remaining_snds] <= 0} {
					Inf "All These Sounds Are Already On The Chosen Files List"
					continue
				}
				set n 0
				set len [llength $remaining_snds]
				while {$n < $len} {	
					set fnam [lindex $remaining_snds $n]
					if {[LstIndx $fnam $wl] < 0} {
						if {![file exists $fnam]} {
							set remaining_snds [lreplace $remaining_snds $n $n]
							incr len -1
						} elseif {[FileToWkspace $fnam 0 0 0 0 0] <= 0} {
							set remaining_snds [lreplace $remaining_snds $n $n]
							incr len -1
						} else {
							incr n
						}
					} else {
						incr n
					}
				}
				if {[llength $remaining_snds] > 0} {
					DoChoiceBak
					lappend chlist $remaining_snds
					$ch delete 0 end
					foreach fnam $chlist {
						$ch insert end $fnam
					}
					Inf "Files Have Been Added To The Chosen Files List"
				} else {
					Inf "Cannot Get Any Of These Files To The Workspace"
				}
			}
			7 {			;#	SAVE CURRENT RHYME STATISTICS FOR THIS PROPERTIES FILE

				if {$wordstarts} {
					if {![info exists sttalphastats]} {
						Inf "No $stattype Statistics To Save"
						continue
					}
					set alphastats $sttalphastats
				} else {
					if {![info exists rhyalphastats]} {
						Inf "No $stattype Statistics To Save"
						continue
					}
					set alphastats $rhyalphastats
				} 
				set savfnam [file rootname [file tail $ts_propfile]]
				if {$wordstarts} {
					append savfnam "_sttstats" $evv(CDP_EXT)
				} else {
					append savfnam "_rhystats" $evv(CDP_EXT)
				}
				set savfnam [file join $evv(URES_DIR) $savfnam]
				if {[file exists $savfnam]} {
					set msg "Overwrite Existing $stattype Statistics For This Properties-File ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if [catch {file delete $savfnam} zit] {
						Inf "Cannot Delete Existing $stattype Statistics File '$savfnam'"
						continue
					}
				}
				if [catch {open $savfnam "w"} zit] {
					Inf "Cannot Open File '$savfnam' To Save $stattype Statistics"
					continue
				}
				Block "Saving $stattype Statistics"

				;#	USE ALPHA-SORTED TO STORE

				if {$wordstarts} {
					foreach {cnt nam} $alphastats {
						set line [concat $nam $sttstats($nam)]
						puts $zit $line
					}
				} else {
					foreach {cnt nam} $alphastats {
						set line [concat $nam $rhymestats($nam)]
						puts $zit $line
					}
				}
				close $zit
				UnBlock
				Inf "$stattype Statistics Saved"
			}
			8 {		;#	ADD FINAL RHYME STATS FOR THIS PROPERTIES FILE TO OVERALL RHYME STATS

				set msg "You Should Only Do This Operation If The Properties File Is Now Complete\n\n Proceed ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {$wordstarts} {
					if {![info exists sttalphastats]} {
						Inf "No $stattype Statistics To Save"
						continue
					}
					set totsavfnam "_sttstats" 
					set othersavfnam "_sttstatsfiles" 
				} else {
					if {![info exists rhyalphastats]} {
						Inf "No $stattype Statistics To Save"
						continue
					}
					set totsavfnam "_rhystats" 
					set othersavfnam "_rhystatsfiles" 
				} 
				append totsavfnam $evv(CDP_EXT)
				set totsavfnam [file join $evv(URES_DIR) $totsavfnam]
				append othersavfnam $evv(CDP_EXT)
				set othersavfnam [file join $evv(URES_DIR) $othersavfnam]
				Block "Saving $stattype Statistics"
				if {![info exists totalrhystats]} {
					if {[file exists $totsavfnam]} {
						if {![file exists $othersavfnam]} {
							set msg "Cannot Find File '$othersavfnam' To Read Which Files Have Already Been Added To Overall $stattype Statistics\n\n" 
							append msg "You Should Recreate This File\n"
							append msg "And List In It The Names Of All The Files (with Full Path And Extension)\n"
							append msg "Whose Statistics Are Already Contained In The \"Overall $stattype Statistics\" File\n"
							Inf $msg
							UnBlock 
							continue
						}
						if [catch {open $othersavfnam "r"} zit] {
							set msg "Cannot Open Existing File '$othersavfnam' To Read Which Files Have Already Been Added To Overall $stattype Statistics\n\n" 
							append msg "You Should Check This File, And If Necessary Recreate It,\n"
							append msg "Listing In It The Names Of All The Files (With Full Path And Extension)\n"
							append msg "Whose Statistics Are Already Contained In The \"Overall $stattype Statistics\" File\n"
							Inf $msg
							UnBlock 
							continue
						}
						if {$wordstarts} {
							catch {unset totalsttstats_files} 
							while {[gets $zit line] >= 0} {
								lappend totalsttstats_files $line
							}
						} else {
							catch {unset totalrhystats_files} 
							while {[gets $zit line] >= 0} {
								lappend totalrhystats_files $line
							}
						}
						close $zit
						if {$wordstarts} {
							if {[lsearch $totalsttstats_files $ts_propfile] >= 0} {
								Inf "This Properties File Already Has Its Data Included In The \"Overall $stattype Statistics\" File\n"
								continue
							}
						} else {
							if {[lsearch $totalrhystats_files $ts_propfile] >= 0} {
								Inf "This Properties File Already Has Its Data Included In The \"Overall $stattype Statistics\" File\n"
								continue
							}
						}
						if [catch {open $totsavfnam "r"} zit] {
							Inf "Cannot Open Existing \"Overall $stattype Statistics\" File '$totsavfnam' To Read Existing Data" 
							UnBlock 
							continue
						}
						if {$wordstarts} {
							while {[gets $zit line] >= 0} {
								set line [split $line]
								set totalsttstats([lindex $line 0]) [lindex $line 1]
							}
						} else {
							while {[gets $zit line] >= 0} {
								set line [split $line]
								set totalrhystats([lindex $line 0]) [lindex $line 1]
							}
						}
					}
				} else {
					if {$wordstarts} {
						if {[lsearch $totalsttstats_files $ts_propfile] >= 0} {
							Inf "This Properties File Already Has Its Data Included In The \"Overall $stattype Statistics\" File\n"
							UnBlock
							continue
						}
					} else {
						if {[lsearch $totalrhystats_files $ts_propfile] >= 0} {
							Inf "This Properties File Already Has Its Data Included In The \"Overall $stattype Statistics\" File\n"
							UnBlock
							continue
						}
					}
				}
				if {$wordstarts} {
					foreach {cnt nam} $sttalphastats {
						if {[info exists totalsttstats($nam)]} {
							incr totalsttstats($nam) $cnt
						} else {
							set totalsttstats($nam) $cnt
						}
					}
				} else {
					foreach {cnt nam} $rhyalphastats {
						if {[info exists totalrhystats($nam)]} {
							incr totalrhystats($nam) $cnt
						} else {
							set totalrhystats($nam) $cnt
						}
					}
				}
				set tempfnam $evv(MACH_OUTFNAME)
				append tempfnam 0000 $evv(TEXT_EXT) 
				if [catch {open $tempfnam "w"} zit] {
					Inf "Cannot Open Temporary File '$tempfnam' To Write New Overall $stattype Statistics"
					UnBlock
					continue
				}
				if {$wordstarts} {
					set total_stats [SortRhymeStatistics 1 totalsttstats]
				} else {
					set total_stats [SortRhymeStatistics 1 totalrhystats]
				}
				foreach {nam cnt} $total_stats {
					set line [list $nam $cnt]
					puts $zit $line
				}
				close $zit
				if {$wordstarts} {
					lappend totalsttstats_files $ts_propfile
				} else {
					lappend totalrhystats_files $ts_propfile
				}
				if [catch {file delete $totsavfnam} zit] {
					set msg "Cannot Delete Existing \"Overall $stattype Statistics\" File To Save New Data\n\n"
					append msg "New Data Is In File '$tempfnam'\n\n"
					append msg "You Should Rename This File To '$totsavfnam', Outside The Loom, Before Quitting This Dialogue Box"
					Inf $msg
				} elseif [catch {file rename $tempfnam $totsavfnam} zit] {
					set msg "Cannot Rename Temporary Data File '$tempfnam' To  '$totsavfnam'\n\n"
					append msg "You Should Rename This File, Outside The Loom, Before Quitting This Dialogue Box\n\n"
					append msg "If You Do Not, The Existing Overall $stattype Statistics Will Be Lost !!!!!\n\n"
					Inf $msg
				}
				if [catch {open $tempfnam "w"} zit] {
					set msg "Cannot Open Temporary File '$tempfnam' To Rewrite List Of Property Files\nwhose Data Is Listed In The \"Overall $stattype Statistics\" File"
					append msg "You Should Add The Name Of The Current Property File (Complete With Path And Extension)\n"
					append msg "($ts_propfile)\n"
					append msg "To The Data In File '$othersavfnam'\n"
					Inf $msg
				} else {
					if {$wordstarts} {
						foreach fffnam $totalsttstats_files {
							puts $zit $fffnam
						}
					} else {
						foreach fffnam $totalrhystats_files {
							puts $zit $fffnam
						}
					}
					close $zit
				}
				if [catch {file delete $othersavfnam} zit] {
					set msg "Cannot Delete Existing File 'othersavfnam' To Save New Data\n\n"
					append msg "New Data Is In File '$tempfnam'\n\n"
					append msg "You Should Rename This File To '$othersavfnam', Outside The Loom, Before Quitting This Dialogue Box"
					Inf $msg
					UnBlock
				} elseif [catch {file rename $tempfnam $othersavfnam} zit] {
					set msg "Cannot Rename Temporary Data File '$tempfnam' To '$totsavfnam'\n\n"
					append msg "You Should Rename This File, Outside The Loom, Before Quitting This Dialogue Box\n\n"
					append msg "If You Do Not, You Will Lose The List Of Files Already Having Their Data Listed In The Overall Stats !!!!!\n\n"
					Inf $msg
					UnBlock
				} else {
					UnBlock
					Inf "Overall $stattype Statistics Saved"
				}
			}
		}
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#------ Get Statistics of Rhyme occurences in "text" property of Properties file 

proc GenerateRhymeStatistics {wordstarts} {
	global propwords propwordpos evv rhymestats rhyfrqstats rhyalphastats sttstats sttfrqstats sttalphastats sttexstats
	global sttexfrqstats sttexalphastats

	set endings $propwords
	set nupos $propwordpos

	;#	REMOVE APOSTROPHES, COMMAS, FULL STOPS

	foreach word $endings {
		set word [string tolower $word]
		set len [string length $word]
		set k 0
		while {$k < $len} {
			set char [string index $word $k]
			if {![regexp {[a-z]} $char]} {
				set nuword ""
				if {$k > 0} {
					append nuword [string range $word 0 [expr $k - 1]]
				}
				incr k
				if {$k < $len} {
					append nuword [string range $word $k end]
				}
				incr k -1
				set word $nuword
				incr len -1
			} else {
				incr k
			}
		}
		lappend nuwords $word 
	}
	if {![info exists nuwords]} {
		Inf "No True Word Data Recovered"
		return 0
	}

	;#	GENERATE WORD STATISTICS

	set nuwordlist $endings
	set len [llength $nuwords]
	set n 0
	while {$n < $len} {									;#	CONCAT DUPLICATES , GENERATING wordstats
		set word [lindex $nuwords $n]					;#	wordstats(word) = cnt pos1 pos2 etc
		set pos  [lindex $nupos $n]						;#	"cnt" = no. of occurences of word
		if {![info exists wordstats($word)]} {			;#	"posN" = sounds in which words occurs
			set wordstats($word) 1
			lappend wordstats($word) $pos
		} else {
			set cnt  [lindex $wordstats($word) 0]		;#	Add to any existing stats for this Word
			set snds [lrange $wordstats($word) 1 end]
			incr cnt									;#	Count word occurences
			if {[lsearch $snds $pos] < 0} {				;#	Check if this is in a new sound
				lappend snds $pos						;#	and if so, add to list of snds
			}
			set snds [lsort -increasing $snds]
			set wordstats($word) [concat $cnt $snds]
		}
		incr n
	}

	if {$wordstarts} {

		;#	GENERATE START-SYLLABLE STATISTICS

		catch {unset sttstats}
		foreach word [array names wordstats] {
			set stt [GetPhoneticStart $word]					;#	foreach word, generate phonetic equiv of start sylab
			if {![string match $stt $evv(NULL_PROP)] && ([string length $stt] > 0)} {
				if {![info exists sttstats($stt)]} {		;#	If no stteequiv stats exist
					set sttstats($stt) $wordstats($word)	;#	transfer word stats to stte stats
				} else {									;#	else, ADD word stats to existing stte stats
					set wcnt  [lindex $wordstats($word) 0]	
					set wsnds [lrange $wordstats($word) 1 end]
					set rcnt  [lindex $sttstats($stt) 0]
					set rsnds [lrange $sttstats($stt) 1 end]
					incr rcnt $wcnt
					foreach pos $wsnds {
						if {[lsearch $rsnds $pos] < 0} {
							lappend rsnds $pos
						}
					}
					set rsnds [lsort -increasing $rsnds]
					set sttstats($stt) [concat $rcnt $rsnds]
				}
			}
		}
		foreach nam [array names sttstats] {
			set sttexstats($nam) $sttstats($nam)
		}
		set sttexfrqstats   [SortRhymeStatistics 0 sttexstats]
		set sttexalphastats [SortRhymeStatistics 1 sttexstats]

		;#	GENERATE NESTED-START-SYLLAB STATISTICS

		catch {unset nested}
		foreach stt [array names sttstats] {
			set len [string length $stt]
			if {$len > 1} {
				set k [expr $len - 2]
				while {$k >= 0} {									;#	if stt = "band"
					set neststt  [string range $stt 0 $k]			;#	"ban" & "ba" are nested stts
					if {![info exists nested($neststt)]} {			;#	if stats for nested stt don't exist
						set nested($neststt) $sttstats($stt)		;#	Copy sttstats to nested stt stats
					} else {										;#	Else
						set rcnt  [lindex $sttstats($stt) 0]		;#	Add stats to existing nested-stt stats
						set rsnds [lrange $sttstats($stt) 1 end]
						set ncnt  [lindex $nested($neststt) 0]
						set nsnds [lrange $nested($neststt) 1 end]
						incr ncnt $rcnt
						foreach pos $rsnds {
							if {[lsearch $nsnds $pos] < 0} {
								lappend nsnds $pos
							}
						}
						set nsnds [lsort -increasing $nsnds]
						set nested($neststt) [concat $ncnt $nsnds]
					}
					incr k -1
				}
			}
		}
		;#	MERGE NESTED-START-SYLLAB STATISTICS WITH UN-NESTED STATS

		if {[info exists nested]} {
			set stts [array names sttstats]
			foreach neststt [array names nested] {
				if {[lsearch $stts $neststt] >= 0} {			;#	If nested stt already exists as a full stt
					set rcnt  [lindex $sttstats($neststt) 0]	;#	Add nested-stt stats to existing stte stat
					set rsnds [lrange $sttstats($neststt) 1 end]
					set ncnt  [lindex $nested($neststt) 0]
					set nsnds [lrange $nested($neststt) 1 end]
					incr rcnt $ncnt
					foreach pos $nsnds {
						if {[lsearch $rsnds $pos] < 0} {
							lappend rsnds $pos
						}
					}
					set rsnds [lsort -increasing $rsnds]
					set sttstats($neststt) [concat $rcnt $rsnds]
				} else {										;#	otherwise, make nested stt a stt-stat
					set sttstats($neststt) $nested($neststt) 
				}
			}
		}
		set sttfrqstats   [SortRhymeStatistics 0 sttstats]
		set sttalphastats [SortRhymeStatistics 1 sttstats]

	} else {

		;#	GENERATE RHYME STATISTICS

		catch {unset rhymestats}
		foreach word [array names wordstats] {
			set rhym [GetPhoneticRhyme $word]				;#	foreach word, generate its rhyme equivalent
			if {![string match $rhym $evv(NULL_PROP)] && ([string length $rhym] > 0)} {
				if {![info exists rhymestats($rhym)]} {		;#	If no rhymeequiv stats exist
					set rhymestats($rhym) $wordstats($word)	;#	transfer word stats to rhyme stats
				} else {									;#	else, ADD word stats to existing rhyme stats
					set wcnt  [lindex $wordstats($word) 0]	
					set wsnds [lrange $wordstats($word) 1 end]
					set rcnt  [lindex $rhymestats($rhym) 0]
					set rsnds [lrange $rhymestats($rhym) 1 end]
					incr rcnt $wcnt
					foreach pos $wsnds {
						if {[lsearch $rsnds $pos] < 0} {
							lappend rsnds $pos
						}
					}
					set rsnds [lsort -increasing $rsnds]
					set rhymestats($rhym) [concat $rcnt $rsnds]
				}
			}
		}

		;#	GENERATE NESTED-RHYME STATISTICS

		catch {unset nested}
		foreach rhym [array names rhymestats] {
			set len [string length $rhym]
			if {$len > 2} {
				set k 1
				while {$k < $len} {									;#	if rhyme = "4ist"
					set nestrhym  [string range $rhym $k end]		;#	"ist" & "st" are nested rhymes
					if {![info exists nested($nestrhym)]} {			;#	if stats for nested rhyme don't exist
						set nested($nestrhym) $rhymestats($rhym)	;#	Copy rhymestats to nested rhyme stats
					} else {										;#	Else
						set rcnt  [lindex $rhymestats($rhym) 0]		;#	Add stats to existing nested-rhyme stats
						set rsnds [lrange $rhymestats($rhym) 1 end]
						set ncnt  [lindex $nested($nestrhym) 0]
						set nsnds [lrange $nested($nestrhym) 1 end]
						incr ncnt $rcnt
						foreach pos $rsnds {
							if {[lsearch $nsnds $pos] < 0} {
								lappend nsnds $pos
							}
						}
						set nsnds [lsort -increasing $nsnds]
						set nested($nestrhym) [concat $ncnt $nsnds]
					}
					incr k
				}
			}
		}
		;#	MERGE NESTED-RHYME STATISTICS WITH UN-NESTED STATS

		if {[info exists nested]} {
			set rhyms [array names rhymestats]
			foreach nestrhym [array names nested] {
				if {[lsearch $rhyms $nestrhym] >= 0} {			;#	If nested rhyme already exists as a full rhyme
					set rcnt  [lindex $rhymestats($nestrhym) 0]	;#	Add nested-rhyme stats to existing rhyme stats
					set rsnds [lrange $rhymestats($nestrhym) 1 end]
					set ncnt  [lindex $nested($nestrhym) 0]
					set nsnds [lrange $nested($nestrhym) 1 end]
					incr rcnt $ncnt
					foreach pos $nsnds {
						if {[lsearch $rsnds $pos] < 0} {
							lappend rsnds $pos
						}
					}
					set rsnds [lsort -increasing $rsnds]
					set rhymestats($nestrhym) [concat $rcnt $rsnds]
				} else {										;#	otherwise, make nested rhyme a rhyme-stat
					set rhymestats($nestrhym) $nested($nestrhym) 
				}
			}
			unset nested
		}
		set rhyfrqstats   [SortRhymeStatistics 0 rhymestats]
		set rhyalphastats [SortRhymeStatistics 1 rhymestats]
	}
	return  1
}

#---- Sort Rhyme Statistics into pseudo-alphabetic order (with letter-order reversed) or order of frequency of occurence

proc SortRhymeStatistics {alpha whichstats} {
	global rhymestats rhyfrqstats rhyalphastats sttstats sttexstats sttalphastats totalsttstats totalrhystats

	switch -- $whichstats {
		"totalsttstats" {
			set wordstarts 1
			foreach nam [array names totalsttstats] {
				lappend rhcnts [lindex $totalsttstats($nam) 0]
				lappend rhnams $nam
			}
		}
		"totalrhystats" {
			set wordstarts 0
			foreach nam [array names totalrhystats] {
				lappend rhcnts [lindex $totalrhystats($nam) 0]
				lappend rhnams $nam
			}
		}
		"sttstats" {
			set wordstarts 1
			foreach nam [array names sttstats] {
				lappend rhcnts [lindex $sttstats($nam) 0]
				lappend rhnams $nam
			}
		}
		"sttexstats" {
			set wordstarts 1
			foreach nam [array names sttexstats] {
				lappend rhcnts [lindex $sttexstats($nam) 0]
				lappend rhnams $nam
			}
		}
		"rhymestats" {
			set wordstarts 0
			foreach nam [array names rhymestats] {
				lappend rhcnts [lindex $rhymestats($nam) 0]
				lappend rhnams $nam
			}
		}
	}
	set len [llength $rhnams]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n [lindex $rhnams $n]
		set cnt_n [lindex $rhcnts $n]
		set m $n
		incr m
		while {$m < $len_less_one} {
			set nam_m [lindex $rhnams $m]
			set cnt_m [lindex $rhcnts $m]
			if {$alpha} {
				if {[LaterRhymeString $nam_n $nam_m $wordstarts]} {
					set rhcnts [lreplace $rhcnts $n $n $cnt_m]
					set rhnams [lreplace $rhnams $n $n $nam_m]
					set rhcnts [lreplace $rhcnts $m $m $cnt_n]
					set rhnams [lreplace $rhnams $m $m $nam_n]
					set cnt_n $cnt_m
					set nam_n $nam_m
				}
			} else {
				if {$cnt_m > $cnt_n} {
					set rhcnts [lreplace $rhcnts $n $n $cnt_m]
					set rhnams [lreplace $rhnams $n $n $nam_m]
					set rhcnts [lreplace $rhcnts $m $m $cnt_n]
					set rhnams [lreplace $rhnams $m $m $nam_n]
					set cnt_n $cnt_m
					set nam_n $nam_m
				} elseif {$cnt_m == $cnt_n} {
					if {[LaterRhymeString $nam_n $nam_m $wordstarts]} {
						set rhcnts [lreplace $rhcnts $n $n $cnt_m]
						set rhnams [lreplace $rhnams $n $n $nam_m]
						set rhcnts [lreplace $rhcnts $m $m $cnt_n]
						set rhnams [lreplace $rhnams $m $m $nam_n]
						set cnt_n $cnt_m
						set nam_n $nam_m
					}
				}
			}
			incr m
		}
		incr n
	}
	catch {unset alphastats}
	foreach rhcnt $rhcnts rhnam $rhnams {
		lappend alphastats $rhcnt $rhnam
	}
	return $alphastats
}

#----- Sort rhymestrings in pesudo-alpha order
#
#	pesudo-alpha order =
#	Vowels first, liquids (w,y), soft consonants (m,n,l,r) ,
#	then 'hard' consonants (b,d,g), then noise consonants (t,s,C)
#

proc LaterRhymeString {str1 str2 wordstarts} {
	set rhymeseq [list "." ":" "a" "A" "4" "e" "E" "i" "I" "o" "O" "@" "u" "U" "w" "y" "m" "n" "N" "l" "r"]
	set rhymeseq [concat $rhymeseq "b" "d" "g" "k" "p" "t" "T" "7" "h" "X" "f" "v" "j" "s" "S" "z" "Z" "C"]
	set len1 [string len $str1]
	set len2 [string len $str2]
	set minlen $len1
	if {$len2 < $minlen} {
		set minlen $len2
	}
	set n 0
	if {!$wordstarts} {
		set str1 [ReverseString $str1]
		set str2 [ReverseString $str2]
	}
	while {$n < $minlen} {
		set char1 [string index $str1 $n]
		set char2 [string index $str2 $n]
		set j [lsearch $rhymeseq $char1]
		set k [lsearch $rhymeseq $char2]
		if {$j > $k} {
			return 1
		} elseif {$j < $k} {
			return 0
		}
		incr n
	}
	if {$len1 > $len2} {
		return 1
	}
	return 0
}

#---- Select a rhyme listed in the rhyme-stats-window as parameter for search

proc RhySelect {y add next down} {
	global rhystatistics rhystatstate rhystatchoice rhylist
	if {$rhystatstate != 1} {
		return
	}
	if {$next} {
		set i [$rhystatistics curselection]
		if {![info exists i] || ($i < 0)} {
			return
		}
		set endindx [expr [$rhystatistics index end] - 1]
		if {$down} {
			incr i
			if {$i > $endindx} {
				set i 0
			}
		} else {
			incr i -1
			if {$i < 0} {
				set i $endindx
			}
		}
		$rhystatistics selection clear 0 end
		$rhystatistics selection set $i
		$rhystatistics yview moveto [expr double($i)/double([$rhystatistics index end])]
	} else {
		set i [$rhystatistics nearest $y]
	}
	set rhyme [$rhystatistics get $i]
	set rhyme [split $rhyme]
	set rhyme [lindex $rhyme end]
				;#	RHYMES TO INCLUDE IN SEARCH
	if {$add} {
		if {[lsearch $rhystatchoice $rhyme] < 0} {	;#	IF NOT ALREADY IN SEARCH LIST, ADD TO SEARCH LIST
			lappend rhystatchoice $rhyme
		}
	} else {
		set rhystatchoice $rhyme
	}
	set rhylist [lindex $rhystatchoice 0]
	if {[llength $rhystatchoice] > 1} {
		foreach rhyme [lrange $rhystatchoice 1 end] {
			append rhylist "  " $rhyme
		}
	}
}

#---- Search texts for specified rhymes

proc FindSpecifiedRhymesInTextsOfTextProperty {wordstarts} {
	global rhystatchoice rhymesnds rhymetexts rhystatistics ts_props_list ts_propnames sttstats rhymestats sttexstats rhyinclude
	set cnt 0
	if {$wordstarts} {
		foreach rhyme $rhystatchoice {
			if {$rhyinclude} {
				if {$cnt == 0} {
					set rhymesnds [lrange $sttstats($rhyme) 1 end]
				} else {
					foreach snd [lrange $sttstats($rhyme) 1 end] {
						if {[lsearch $rhymesnds snd] < 0} {
							lappend rhymesnds $snd
						}
					}
				}
				incr cnt
			} else {	;#	COMPLETE SPECIFIED STRINGS ONLY
				if {$cnt == 0} {
					set rhymesnds [lrange $sttexstats($rhyme) 1 end]
				} else {
					foreach snd [lrange $sttexstats($rhyme) 1 end] {
						if {[lsearch $rhymesnds snd] < 0} {
							lappend rhymesnds $snd
						}
					}
				}
				incr cnt
			}
		}
	} else {
		foreach rhyme $rhystatchoice {
			if {$cnt == 0} {
				set rhymesnds [lrange $rhymestats($rhyme) 1 end]
			} else {
				foreach snd [lrange $rhymestats($rhyme) 1 end] {
					if {[lsearch $rhymesnds snd] < 0} {
						lappend rhymesnds $snd
					}
				}
			}
			incr cnt
		}
	}
	if {![info exists rhymesnds] || ([llength $rhymesnds] <= 0)} {
		Inf "Program Error: No Texts Found With These Phonetics"
		return 0
	}
	if {$cnt > 1} {
		set rhymesnds [lsort -increasing $rhymesnds]
	}
	set textproppos 1
	foreach nam $ts_propnames {
		if {[string match [string tolower $nam] "text"]} {
			break
		}
		incr textproppos
	}
	$rhystatistics delete 0 end
	catch {unset rhymetexts}
	foreach no $rhymesnds {
		set line [lindex $ts_props_list $no]
		set txt [lindex $line $textproppos]
		lappend rhymetexts $txt
	}
	foreach txt $rhymetexts {
		set txt [split $txt "_"]
		$rhystatistics insert end $txt
	}
	return 1
}

#---- Find Phonetic actuality of word-ends

proc GetPhoneticRhyme {word} {
	set k [string length $word]
	set rhymestr [IncludePreviousChar $word $k]
	incr k -1
	switch -- $rhymestr {
		"a" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ca" {
						return "k."
					}
					"da" {	
						return "d."
					}
					"ea" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aea" {
									return "I."
								}
								"cea" {
									return "S."
								}
								"gea" {
									return "j."
								}
								"oea" {
									return "I."
								}
							}
						}
						if {[IsMonosyllabic $word ea]} {
							return "I"
						} else {
							return "i."
						}
					}
					"ha" {
						if {[string match "ha" $word]} {
							return "ha"
						}
					}
					"ia" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"cia" {
									return "S."
								}
								"sia" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"hsia" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match $rhymestr "chsia"]} {
												return "S."	;#	fuchsia
											}
										}
										"ssia" {
											return "S."	;#	Russia
										}
									}
									set wordlist1 [list fresia asia magnesia]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "Z."
									}
									set wordlist1 [list banksia intelligentsia]
									set wordlist2 [list psia]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "si."
									}
									return "zi."	;#	aphasia fantasia
								}
								"tia" {
									return "S."
								}
								"via" {
									return "vi."
								}
							}
						}
						return "i."
					}
					"oa" {
						set wordlist1 [list jerboa moa]
						set wordlist2 [list zoa]
						if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
							return "@."
						} else {
							return "@"	;#	cocoa
						}
					}
				}
			}
			return "."	;#	a
		}
		"b"	{
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ab" {
						return "ab"
					}
					"ib" {
						return "ib"
					}
					"mb" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"amb" {
									set wordlist1 [list lamb jamb]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "am"
									} else {
										return "amb"
									}
								}
								"imb" {
									if {[string match "limb" $word]} {
										return "im"
									} else {
										return "aim"		;#	 climb
									}
								}
								"omb" {
									set wordlist1 [list rhomb]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "omb"
									}
									set wordlist2 [list oomb tomb catacomb]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "Um"
									}
									set wordlist2 [list comb]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "@m"
									}
								}
								"umb" {
									return "um"
								}
							}
						}
					}
					"ob" {
						return "ob"
					}
					"rb" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"erb" {
									return ":b"
								}
								"orb" {
									return "Ob"
								}
								"urb" {
									return ":b"
								}
							}
						}
					}
					"ub" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string match $rhymestr aub]} {
							return "Ob"
						} else {
							return "ub"	;#	ub
						}
					}
				}
			}
		}
		"c" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ac" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match $rhymestr "iac"]} {
							return "iak"
						} else {
							return "ak"
						}
					}
					"ec" {
						return "ek"
					}
					"ic" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aic" {
									return "4ik"
								}
								"cic" {
									return "sik"
								}
								"dic" {
									return "dik"
								}
								"eic" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match $rhymestr "oeic"]} {
										return "Iik"
									} else {
										return "Aik"
									}
								}
								"fic" {
									return "fik"
								}
								"gic" {
									return "jik"
								}
								"hic" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"phic" {
											return "fik"
										} "thic" {
											return "Tik"
										}
									}
								}
								"lic" {
									return "lik"
								}
								"mic" {
									return "mik"
								}
								"nic" {
									return "nik"
								}
								"oic" {
									return "@ik"
								}
								"pic" {
									return "pik"
								}
								"ric" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match $rhymestr "tric"]} {
										return "trik"
									} else {
										return "rik"
									}
								}
								"sic" {
									return "sik"
								}
								"tic" {
									return "tik"
								}
							}
						}
						return "ik"
					}
					"oc" {
						if {[string match "havoc" $word]} {
							return ".k"
						}
						return "ok"
					}
				}
			}
		}
		"d" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ad" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ead" {
									set wordlist1 [list dread thread tread]
									set wordlist2 [list stead bread stead]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "ed"
									} else {
										return "Id"
									}
								}
								"oad" {
									set wordlist2 [list broad]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "Od"
									} else {
										return "@d"
									}
								}
							}
						}
						return "ad"
					}
					"ed" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"bed" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"mbed" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ombed" $rhymestr]} {
												return "@md"
											}
										}
										"bbed" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"abbed" {
													return "abd"
												}
												"ibbed" {
													return "ibd"
												} 
												"obbed" {
													return "obd"
												}
												"ubbed" {
													return "ubd"
												}
											}
										}
										"ibed" {
											return "aibd"
										}
										"obed" {
											return "@bd"
										}
										"rbed" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"arbed" {
													return "Abd"
												}
												"orbed" {
													return "Obd"
												}
											}
										}
										"tbed" {
											if {[string match "hotbed" $word]} {
												return "hotbed"
											}
										}
									}
								}
								"ced" {
									return "st"
								}
								"ded" {
									return "did"
								}
								"eed" {
									return "Id"
								}
								"fed" {
									return "ft"
								}
								"ged" {
									if {[string match "aged" $word]} {
										return "jid"
									} else {
										return "jd"
									}
								}
								"hed" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ched" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "tched" $rhymestr]} {
												return "Ct"
											}
										}
										"shed" {
											return "St"
										}
									}
								}
								"ied" {
									set wordlist1 [list implied applied fried]
									set wordlist2 [list fied]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "aid"
									} else {
										return "id"
									}
								}
								"ked" {
									if {[string match "naked" $word]} {
										return "kid"
									}
									return "kt"
								}
								"led" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match $rhymestr "bled"]} {
										if {[string match $word "bled"]} {
											return "bled"
										} else {
											return "b.ld"
										}
									} else {
										return "ld"
									}
								}
								"med" {
									 return "md"
								}
								"ned" {
									 return "nd"
								}
								"ped" {
									return "pt"
								}
								"red" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ared" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "eared" $rhymestr]} {
												return "i.d"
											} else {
												return "Ad"
											}
										}
										"bred" {
											if {[string match "bred" $word]} {
												return "ed"
											}
											return "b.d"	;#	calibred
										}
										"cred" {
											return "k.d"	;#	massacred
										}
										"ered" {
											switch -- $word {
												"proffered" {
													return ":d"
												}
												"premiered" {
													return "iEd"
												}
												"glowered" -
												"towered" {
													return "aU.d"
												}
												"layered" {
													return "Ed"
												}
											}
											return ".d"
										}
										"hred" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "chred" $rhymestr]} {
												return "k.d"	;#	sepulchred
											}
										}
										"ired" {
											if {[WordEndsWithAnyOf $word [list "aired"]]} {
												return "Ed"
											}
											return "ai.d"		;#	hired
										}
										"ored" {
											if {[WordEndsWithAnyOf $word [list "oored"]]} {
												return "Od"
											}
											return ".d"
										}
										"rred" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"arred" {
													return "Ad"
												}
												"erred" {
													return ":d"
												}
												"irred" {
													return ":d"
												}
												"orred" {
													return "Od"
												}
												"urred" {
													return ":d"
												}
											}
										}
										"tred" {
											if {[string match "hatred" $word]} {
												return "tr.d"
											}
											return "t.d"	;#	mitred
										}
										"ured" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											if {[string match "oured" $rhymestr]} {
												set rhymestr [IncludePreviousChar $word $k]
												if {[string match "ioured" $rhymestr]} {
													return "i.d"
												}
												set wordlist1 [list poured toured]
												if {[WordMatchesAnyOfWords $word $wordlist1]} {
													return "Od"
												}
												return "aU.d"		;#	scoured
											}
											switch -- $word {
												"coiffured" {
													return :d"
												}
												"lured" {
													return "iU.d"
												}
											}
											set wordlist1 [list abjured adjured ensured]
											set wordlist2 [list assured insured]
											if {[WordMatchesAnyOfWords $word $wordlist1] ||[WordEndsWithAnyOf $word $wordlist2]} {
												return "Od"
											}
											set wordlist1 [list endured manured caricatured matured]
											set wordlist2 [list cured vured]
											if {[WordMatchesAnyOfWords $word $wordlist1] ||[WordEndsWithAnyOf $word $wordlist2]} {
												return "iOd"
											}
											return ".d"			;#	natured
										}
										"vred" {
											return "v.d"	;#	manouevred
										}
										"yred" {
											return ".d"		;#	martyred
										}
									}
									return "red"
								}
								"sed" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ased" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"eased" {
													set wordlist [list eased ceased predeceased pleased displeased appeased diseased teased]
													if {[WordMatchesAnyOfWords $word $wordlist]} {
														return "Izd"
													} else {
														return "Ist"
													}
												}
												"hased" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "chased" $rhymestr]} {
														set wordlist [list purchased repurchased]
														if {[WordMatchesAnyOfWords $word $wordlist]} {
															return ".st"
														} else {
															return "4st"
														}
													}
													set wordlist [list phased phrased]
													if {[WordEndsWithAnyOf $word $wordlist]} {
														return "4zd"
													}
												}
												"iased" {
													return "ai.st"		;#	biased
												}
											}
											return "4st"		;#	encased
										}
										"ised" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"aised" {
													return "4zd"
												}
												"oised" {
													return "oizd"
												}
											}
											set wordlist [list practised promised premised]
											if {[WordMatchesAnyOfWords $word $wordlist]} {
												return "ist"
											}
											set wordlist [list cruised bruised]
											if {[WordMatchesAnyOfWords $word $wordlist]} {
												return "Uzd"
											}
											return "aizd"
										}
										"lsed" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ulsed" $rhymestr]} {
												return "ulst"
											}
										}
										"nsed" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"ensed"  {
													set wordlist [list licensed]
													if {[WordMatchesAnyOfWords $word $wordlist]} {
														return ".nst"
													}
													return "enst"
												}
												"insed" {
													return "inst"
												}
											}
										}
										"osed" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"oosed" {
													return "Ust"
												}
												"dosed" {
													return "@st"
												}
											}
											return "@zd"
										}
										"psed" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"apsed" {
													return "apst"
												}
												"ipsed" {
													return "ipst"
												}
												"rpsed" {
													return "Opst"		;#	corpsed
												}
											}
										}
										"rsed" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"arsed" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"earsed" {
															return ":st"
														}
														"oarsed" {
															return "Ost"
														}
													}
													return "Ast"
												}
												"ersed" {
													return ":st"
												}
												"orsed" {
													return "Ost"
												}
												"ursed" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "oursed" $rhymestr]} {
														return "Ost"
													} else {
														return ":st"
													}
												}
											}
										}
										"ssed" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"assed" {
													return "ast"
												}
												"essed" {
													return "est"
												}
											}
										}
										"used" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"aused" { 
													return "Ozd"
												}
												"oused" {
													if {[string match "groused" $word]} {
														return	"aUst"
													}
													return "aUzd"
												}
												"awsed" {
													return "Ozd"
												}
												"owsed" {
													return "aUzd"
												}
											}
											return "iUzd"
										}
										"ysed" {
											return "aizd"
										}
									}
								}
								"ted" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"ated" {
											return "4tid"
										}
										"cted" {
											return "ktid"
										}
										"lted" {
											return "ltid"
										}
										"nted" {
											return "ntid"
										}
										"sted" {
											return "stid"
										}
										"tted" {
											return "tid"
										}
									}
									return "tid"
								}
								"ved" {
									return "vd"
								}
								"wed" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"awed" {
											return "Od"
										}
										"ewed" {
											return "iUd"
										}
										"owed" {
											return "@d"
										}
									}
								}
								"xed" {
									return "kst"
								}
								"zed" {
									return "zd"
								}
							}
							return ".d"
						}
					}
					"id" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aid" {
									set wordlist2 [list said]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "ed"
									} else {
										return "4d"
									}
								}
								"oid" {
									return "oid"
								}
								"uid" {
									return "Uid"
								}
							}
						}
						return "id"
					}
					"ld" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ald" {
									set wordlist1 [list scald]
									set wordlist2 [list bald]
									set wordlist3 [list weald]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "old"
									} elseif {[WordEndsWithAnyOf $word $wordlist2]} {
										return "Old"
									} elseif {[WordMatchesAnyOfWords $word $wordlist3]} {
										return "Ild"
									}
									return ".ld"
								}
								"eld" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ield" $rhymestr]} {
										return "Ild"
									} else {
										return "eld"
									}
								}
								"ild" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "uild" $rhymestr]} {
										return "ild"
									} else {
										if {[string match "gild" $word]} {
											return "ild"
										} else {
											return "aild"
										}
									}
								}
								"old" {
									return "@ld"
								}
								"rld" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "orld" $rhymestr]} {
										return ":ld"
									}
								}
								"uld" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ould" $rhymestr]} {
										return "@ld"
									}
								}
							}
							return "ld"
						}
					}
					"nd" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"and" {
									set wordlist1 [list husband brigand headland midland woodland eland highland holland garland moorland island thousand]
									set wordlist2 [list wand]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return ".nd"
									} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
										return "ond"
									}
									return "and"
								}
								"end" {
									return "end"
								}
								"ind" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "cind" $rhymestr]} {
										return "sind"
									} else {
										set wordlist1 [list tamarind wind]			;#	wind is ambiguous
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return "ind"
										} else {
											return "aind"
										}
									}
								}
								"ond" {
									set wordlist1 [list second diamond almond]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return ".nd"
									} else {
										return "ond"
									}
								}
								"und" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ound" $rhymestr]} {
										return "aUnd"
									} else {
										return "und"
									}
								}
							}
						}
						return "nd"
					}
					"od" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"iod" {
									return "i.d"
								}
								"ood" {
									set wordlist [list food mood snood rood brood]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "Ud"
									} else {
										return "ud"		;#	good, hood
									}
								}
							}
						}
						return "od"
					}
					"rd" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ard" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"eard" {
											set wordlist1 [list hear misheard overheard]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return ":d"
											} else {
												return "i.d"
											}
										}
										"oard" {
											return "Od"
										}
										"uard" {
											return "Ad"
										}
									}
									set wordlist1 [list bombard placard discard pochard galliard milloiard mallard bollard pollard boulevard]
									set wordlist1 [concat $wordlist1 canard communard hansard petard retard]
									set wordlist2 [list regard uard yard hard]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "Ad"
									}
									set wordlist1 [list ward reward sward]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "Od"
									}
									return ".d"
								}
								"erd" {
									if {[string match "shpeherd" $word]} {
										return ".d"
									} else {
										return ":d"
									}
								}
								"ird" {
									return ":d"
								}
								"ord" {
									if {[string match "sword" $word]} {
										return "Od"
									}
									if {[WordEndsWithAnyOf $word [list word]]} {
										return ":d"
									}
									return "Od"
								}
								"urd" {
									return ":d"
								}
							}
						}
					}
					"ud" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aud" {
									return "Od"
								}
								"oud" {
									return "aUd"
								}
							}
						}
						return "ud"
					}
					"wd" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"awd" {
									return "Od"
								}
								"ewd" {
									return "Ud"
								}
								"owd" {
									return "aUd"
								}
							}
						}
					}
					"yd" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string match "oyd" $rhymestr]} {
							return "oid"
						} else {
							return "id"
						}
					}
				}
				return ".d"
			}
		}
		"e" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			switch -- $rhymestr {
				"be" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"abe" {
								return "4b"
							}
							"ebe" {
								return "Ib"
							}
							"ibe" {
								return "aib"
							}
							"mbe" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "ombe" $rhymestr]} {
									return "Um"
								}
							}
							"obe" {
								return "@b"
							}
							"ube" {
								return "iUb"
							}
						}
					}
					return "bI"
				}
				"ce" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ace" {
								set wordlist1 [list terrace]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return ".s"
								}
								set wordlist2 [list rosace]
								if {[WordMatchesAnyOfWords $word $wordlist2]} {
									return "as"
								}
								set wordlist3 [list vivace]
								if {[WordMatchesAnyOfWords $word $wordlist3]} {
									return "AC4"
								}
								return "4s"
							}
							"ece" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"eece" {
										return "Is"
									}
									"iece" {
										return "Is"
									}
								}
							}
							"ice" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"aice" {
										return "4s"
									}
									"oice" {
										return "ois"
									}
									"uice" {
										if {[string match "sluice" $word]} {
											return "Us"
										} else {
											return "iUs"
										}
									}
								}
								set wordlist1 [list	suffice sacrifice entice advice device]
								if {[IsMonosyllabic $word ice] || [WordMatchesAnyOfWords $word $wordlist1]} {
									return "ais"
								}
								set wordlist1 [list	police caprice cockatrice]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "Is"
								}
								return "is"
							}
							"nce" {
								set rhymestr [IncludePreviousChar $word $k]
								incr  k -1
								switch -- $rhymestr {
									"ance" {
										set rhymestr [IncludePreviousChar $word $k]
										incr  k -1
										switch -- $rhymestr {
											"hance" {
												set rhymestr [IncludePreviousChar $word $k]
												if {[string match "chance" $rhymestr]} {
													return "Cans"
												} else {
													return "hans"
												}
											}
											"iance" {
												switch -- $word {
													"fiance" {
														return "iOns4"
													}
													"allegiance" {
														return "j.ns"
													}
												}
												set wordlist1 [list defiance reliance alliance appliance]
												set wordlist2 [list compliance]
												if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
													return "ai.ns"
												}
												return "i.ns"
											}
										}
										set wordlist1 [list enhance askance romance finance advance]
										if {[IsMonosyllabic $word ance] || [WordMatchesAnyOfWords $word $wordlist1]} {
											return "ans"
										}
										return ".ns"	;#	entrance
									}
									"ence" {
										set rhymestr [IncludePreviousChar $word $k]
										incr  k -1
										switch -- $rhymestr {
											"cence" {
												set rhymestr [IncludePreviousChar $word $k]
												incr  k -1
												if {[string match "scence" $rhymestr]} {
													return "s.ns"
												} elseif {[string match "frankincense" $word]} {
													return "sens"
												} else {
													return "s.ns"
												}
											}
											"gence" {
												return "j.ns"
											}
											"ience" {
												set rhymestr [IncludePreviousChar $word $k]
												incr  k -1
												switch -- $rhymestr {
													"cience" {
														set rhymestr [IncludePreviousChar $word $k]
														if {[string match "science" $word]} {
															return "sai.ns"
														} elseif {[string match "omniscience" $word]} {
															return "si.ns"
														}
														return "S.ns"
													}
													"sience" {
														return "si.ns"
													}
													"tience" {
														return "S.ns"
													}
												}
												return "i.ns"
											}
											"uence" {
												return "U.ns"
											}
										}
										set wordlist1 [list offence defence pretence]
										if {[IsMonosyllabic $word ence] || [WordMatchesAnyOfWords $word $wordlist1]} {
											return "ens"
										}
										return ".ns"
									}
									"ince" {
										return "ins"
									}
									"once" {
										if {[string match "once" $word]} {
											return "uns"
										} else {
											return "ons"
										}
									}
									"unce" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "ounce" $rhymestr]} {
											return "aUns"
										} else {
											return "uns"
										}
									}
								}
								return "ns"
							}
							"rce" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"arce" {
										if {[string match "scarce" $word]} {
											return "Es"
										} else {
											return "As"
										}
									}
									"erce" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "ierce" $rhymestr]} {
											return "i.s"
										} else {
											return ":s"
										}
									}
									"orce" {
										return "Os"
									}
									"urce" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "ource" $rhymestr]} {
											return "Os"
										}
									}
								}
							}
							"sce" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "esce" $rhymestr]} {
									return "es"
								}
							}
							"uce" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"auce" {
										return "Os"
									}
									"euce" {
										return "iUS"
									}
									"ouce" {
										return "Us"
									}
								}
								set wordlist1 [list lettuce]
								set wordlist2 [list spruce truce]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "is"
								} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
									return "Us"
								}
								return "iUs"
							}
						}
					}
				}
				"de" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ade" {
								set wordlist1 [list aubade facade ballade roulade promenade charade]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "Ad"
								} else {
									return "4d"
								}
							}
							"ede" {
								return "Id"
							}
							"ide" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "cide" $rhymestr]} {
									return "said"
								} else {
									return "aid"
								}
							}
							"nde" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"ende" {
										return "end"
									}
									"onde" {
										return "ond"
									}
								}
							}
							"ode" {
								return "@d"
							}
							rde {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "orde" $rhymestr]} {
									return "Od"
								}
							}
							"ude" {
								set wordlist1 [list prelude]
								set wordlist2 [list rude]
								set wordlist3 [list lude crude prude trude]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "iUd"
								} elseif {[WordMatchesAnyOfWords $word $wordlist2] || [WordEndsWithAnyOf $word $wordlist3]} {
									return "Ud"
								}
								return "iUd"
							}
							"yde" {
								return "aid"
							}
						}
					}
				}
				"ee" {
					set wordlist1 [list toffee coffee]
					set wordlist2 [list melee epee toupee soiree entree levee corvee]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "i"
					} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
						return "4"
					} else {
						return "I"
					}
				}
				"fe" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ffe" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"affe" {
										return "af"
									}
									"iffe" {
										return "if"
									}
								}
							}
							"ife" {
								return "aif"
							}
							"afe" {
								if {$word == "cafe"} {
									return "fi"
								} elseif {$word == "carafe"} {
									return "af"
								}
								return "4f"
							}
						}
						return "f"
					}
				}
				"ge" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"age" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "iage" $rhymestr]} {
									set wordlist1 [list verbiage foliage]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "Iij"
									}
									return "ij"
								} else {
									set wordlist1 [list encage assuage]
									set wordlist2 [list ngage]
									set wordlist3 [list degage]
									set wordlist4 [list camouflage sabotage barrage massage]
									set wordlist5 [list mirage brassage entourage arbitrage]
									if {[IsMonosyllabic $word age] || [WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "4j"
									}
									if {[WordMatchesAnyOfWords $word $wordlist3]} {
										return "aZ4"
									}
									if {[WordMatchesAnyOfWords $word $wordlist4]} {
										return "Aj"
									}
									if {[WordMatchesAnyOfWords $word $wordlist5]} {
										return "AZ"
									}
									return "ij"
								}
							}
							"dge" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"adge" {
										return "aj"
									}
									"edge" {
										if {[string match "knowledge" $word]} {
											return "ij"
										} else {
											if {[string match "knowledge" $word]} {
												return "ij"
											} else {
												return "ej"
											}
										}
									}
									"odge" {
										return "oj"
									}
									"udge" {
										return "uj"
									}
								}
							}
							"ege" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "iege" $rhymestr]} {
									if {[string match "liege" $word]} {
										return "IZ"
									} else {
										return "Ij"
									}
								}
								switch -- $word {
									"allege" {
										return "ej"
									}
									"cortege" {
										return "eZ"
									}
									"protege" {
										return ".Z4"
									}
								}
								return "ij"
							}
							"ige" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "eige" $rhymestr]} {
									return "4Z"
								}
								switch -- $word {
									"vestige" {
										return "ij"
									}
									"prestige" {
										return "Ij"
									}
									"neglige" {
										return "iZ4"
									}
								}
								return "aij"
							}
							"lge" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"ilge" {
										return "ilj"
									}
									"ulge" {
										return "ulj"
									}
								}
							}
							"nge" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"ange" {
										set wordlist1 [list flange]
										set wordlist2 [list blancmange melange]
										set wordlist3 [list orange]
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return "anj"
										} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
											return "onj"
										} elseif {[WordMatchesAnyOfWords $word $wordlist3]} {
											return "inj"
										}
										return "4nj"
									}
									"enge" {
										set wordlist1 [list lozenge]
										set wordlist2 [list challenge scavenge]
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return "inj"
										} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
											return ".nj"
										} else {
											return "enj"
										}
									}
									"inge" {
										return "inj"
									}
									"unge" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "ounge" $rhymestr]} {
											return "aUnj "
										}
										return "unj"
									}
								}
							}
							"rge" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"arge" {
										return "Aj"
									}
									"erge" {
										if {[string match "concierge" $word]} {
											return "EZ"
										} else {
											return ":j"
										}
									}
									"orge" {
										return "Oj"
									}
									"urge" {				;#	urge, scourge
										return ":j"
									}
								}
							}
							"uge" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"auge" {
										return "4j"
									}
									"ouge" {
										if {[string match "rouge" $word]} {
											return "UZ"
										} else {
											return "aUj"
										}
									}
								}
								return "iUj"
							}
						}
					}
				}
				"he" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"che" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"ache" {
										set wordlist1 [list cache panache tache moustache gouache]
										set wordlist2 [list mache]
										set wordlist3 [list apache]
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return "aS"
										} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
											return "aS4"
										} elseif {[WordMatchesAnyOfWords $word $wordlist3]} {
											return "aCi"
										}
										set rhymestr [IncludePreviousChar $word $k]
										incr k -1
										switch -- $rhymestr {
											"eache" {
												return "IC"
											}
											"oache" {
												return "@C"
											}
										}
										return "4k"
									}
									"nche" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "anche" $rhymestr]} {
											if {[WordEndsWithAnyOf $word [list "blanche"]]} {
												return "OnS"
											} else {
												return "anS"
											}
										}
									}
									"oche" {
										return "oS"
									}
									"tche" {		;#	always plurals (like matches watches: "s" added on repluralisation)
										set rhymestr [IncludePreviousChar $word $k]
										incr k -1
										switch -- $rhymestr {
											"atche" {
												set rhymestr [IncludePreviousChar $word $k]
												if {[string match "watche" $rhymestr]} {
													return "oC"
												} else {
													return "aC"
												}
											}
											"etche" {
												return "eC"
											}
											"itche" {
												set rhymestr [IncludePreviousChar $word $k]
												if {[string match "aitche" $rhymestr]} {
													return "4C"
												} else {
													return "iC"
												}
											}
											"otche" {
												return "oC"
											}
											"utche" {
												set rhymestr [IncludePreviousChar $word $k]
												if {[string match "autche" $rhymestr]} {
													return "OC"
												} else {
													return "uC"
												}
											}
										}
									}
									"uche" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "auche" $rhymestr]} {
											return "@S"
										} else {
											return "US"
										}
									}
								}
							}
							"phe" {
								if {[string match "apostrophe" $word]} {
									return "ofi"
								} else {
									return "of"
								}
							}
							"she" {
								if {[string match "she" $word]} {
									return "SI"
								} else {
									return "S"		;#	typically in a plural e.g. "washe(s)"
								}
							}
							"the" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"athe" {
										set rhymestr [IncludePreviousChar $word $k]
										switch -- $rhymestr {
											"eathe" {
												return "I7"
											}
											"oathe"	{
												return "@7"
											}
										}
										return "47"
									}
									"ethe" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "eethe" $rhymestr]} {
											return "I7"
										} else {
											return "eT"
										}
									}
									"ithe" {
										return "ai7"
									}
									"othe" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "oothe" $rhymestr]} {
											return "U7"
										} else {
											return "@7"
										}
									}
									"ythe" {
										return "ai7"
									}
								}
								return "7."
							}
						}
					} else {
						return "hI"
					}
				}
				"ie" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string match "rie" $rhymestr]} {
						return "ri"
					} else {
						if {[IsMonosyllabic $word ie]} {
							return "ai"
						} else {
							return "i"
						}
					}
				}
				"ke" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ake" {
								return "4k"
							}
							"cke" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "acke" $rhymestr]} {
									return "ak"
								}
							}
							"ike" {
								return "aik"
							}
							"oke" {
								return "@k"
							}
							"uke" {
								if {[string match "fluke" $word]} {
									return "Uk"
								} else {
									return "iUk"
								}
							}
						}
					}
				}
				"le" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ale" {
								set wordlist1 [list pastorale rationale chorale morale]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "Al"
								} else {
									return "4l"
								}
							}
							"ble" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"able" {
										if {[IsMonosyllabic $word able]} {
											return "4b.l"
										} else {
											return ".b.l"
										}
									}
									"ible" {
										if {[IsMonosyllabic $word ible]} {
											return "aib.l"
										}
										if {[string match "impassible" $word]} {
											return ".b.l"
										}
										set wordlist2 [list cible dible gible lible rible sible xible]
										if {[WordEndsWithAnyOf $word $wordlist2]} {
											return "ib.l"
										}
										return ".b.l"
									}
								}
								return "b.l"
							}
							"cle" {
								return "k.l"
							}
							"dle" {
								return "d.l"
							}
							"fle" {
								return "f.l"
							}
							"gle" {
								return "g.l"
							}
							"ile" {
								return "ail"
							}
							"kle" {
								return "k.l"
							}
							"lle" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"elle" {
										return "el"
									}
									"ille" {
										switch -- $word {
											"pastille" {
												return ".l"
											}
											"bastille" -
											"chenille" {
												return "Il"
											}
										}
										return "il"
									}
								}
							}
							"ole" {
								return "@l"
							}
							"ple" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "mple" $rhymestr]} {
									return "mp.l"
								} else {
									return "p.l"
								}
							}
							"tle" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								if {[string match "ttle" $rhymestr]} {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"attle" {
											return "at.l"
										}
										"ettle" {
											return "et.l"
										}
										"ittle" {
											return "it.l"
										}
										"ottle" {
											return "ot.l"
										}
										"uttle" {
											return "ut.l"
										}
									}
								} else {
									return "t.l"
								}
							}
							"ule" {
								return "iUl"
							}
							"yle" {
								return "ail"
							}
							"zle" {
								return "z.l"
							}
						}
					}
				}
				"me" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ame" {
								switch -- $word {
									"sesame" {
										return ".mI"
									}
									"macrame" {
										return "Am4"
									}
								}
								return "4m"
							}
							"eme" {
								return "Im"
							}
							"ime" {
								if {[string match "centime" $word]} {
									return "Im"
								} else {
									return "aim"
								}
							}
							"mme" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"amme" {
										return "am"
									}
									"omme" {
										return "om4"
									}
								}
							}
							"ome" {
								switch -- $word {
									"epitome" {
										return ".mi"
									}
									"some" {
										return "um"
									}
									"welcome" {
										return ".m"
									}
								}
								if {[WordEndsWithAnyOf $word [list some]]} {
									return ".m"
								}
								if {[WordEndsWithAnyOf $word [list come]]} {
									return "um"
								}
								return "@m"
							}
							"rme" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"arme" {
										return "Am"
									}
									"orme" {
										return "Om"
									}
								}
							}
							"ume" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "lume" $rhymestr]} {
									return "lUm"
								} else {
									return "iUm"
								}
							}
							"yme" {
								return "aim"
							}
						}
					} else {
						return "mI"
					}
				}
				"ne" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ane" {
								return "4n"
							}
							"ene" {
								return "In"
							}
							"gne" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "agne" $rhymestr]} {
									return "4n"
								}
							}
							"ine" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"aine" {
										return "4n"
									}
									"eine" {
										return "4n"
									}
									"oine" {
										return "oin"
									}
									"uine" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "guine" $rhymestr]} {
											if {[string match "beguine" $word]} {
												return "In"
											} else {
												return "Uin"
											}
										} else {
											return "Uin"
										}
									}
								}
								set wordlist1 [list	olivine ravine sistine pristine intestine libertine guillotine nicotine]
								set wordlist1 [concat $wordlist1 quarantine benedictine limousine cuisine tambourine figurine]
								set wordlist1 [concat $wordlist1 latrine terrine fluorine chlorine wolverine riverine tangerine]
								set wordlist1 [concat $wordlist1 glycerine alexandrine nectarine margarine atropine strychnine mezanine]
								set wordlist1 [concat $wordlist1 bromine iodine amine quinoline aniline vaseline tourmaline naphthaline]
								set wordlist1 [concat $wordlist1 machine aubergine sardine gaberdine grenadine piscine plasticine vaccine]
								set wordlist2 [list zine marine phine]
								set wordlist3 [list destine gelatine urine doctrine peregrine saccharine heroine feminine illumine]
								set wordlist3 [concat $wordlist3 ermine vitamine famine compline discipline crinoline engine medicine]
								set wordlist4 [list determine examine imagine]
								if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
									return "In"
								}
								if {[WordMatchesAnyOfWords $word $wordlist3] || [WordEndsWithAnyOf $word $wordlist4]} {
									return "in"
								}
								return "ain"
							}
							"nne" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"enne" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "ienne" $rhymestr]} {
											return "ien"
										}
									}
									"onne" {
										return "on"
									}
								}
							}
							"one" {
								set wordlist1 [list	none shone]
								set wordlist2 [list gone]
								set wordlist3 [list	one someone anyone everyone]
								set wordlist4 [list done undone]
								set wordlist5 [list anemone]
								if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
									return "on"
								} elseif {[WordMatchesAnyOfWords $word $wordlist3]} {
									return "Uun"
								} elseif {[WordMatchesAnyOfWords $word $wordlist4]} {
									return "un"
								} elseif {[WordMatchesAnyOfWords $word $wordlist5]} {
									return ".ni"
								}
								return "@n"
							}
							"rne" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"erne" {
										return ":n"
									}
									"orne" {
										return "On"
									}
									"urne" {
										return ":n"
									}
								}
							}
							"une" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"lune" -
									"rune" -
									"prune" {
										return "Un"
									}
									"jejeune" {
										return ":n"
									}
								}
								return "iUn"
							}
							"yne" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "oyne" $rhymestr]} {
									return "oin"
								} else {
									return "ain"
								}
							}
						}
					}
				}
				"oe" {
					if {[string match "shoe" $word]} {
						return "U"
					} else {
						return "@"
					}
				}
				"pe" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ape" {
								return "4p"
							}
							"epe" {
								return "4p"
							}
							"ipe" {
								if {[string match "recipe" $word]} {
									return ".pi"
								} else {
									return "aip"
								}
							}
							"ope" {
								incr k -1
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "scope" $rhymestr]} {
									return "sk@p"
								}
								return "@p"
							}
							"upe" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "oupe" $rhymestr]} {
									if {[string match "coupe" $word]} {
										return "Up4"
									}
									return "Up"
								}
							}
							"ype" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "type" $rhymestr]} {
									return "taip"
								}
								return "aip"
							}
						}
					}
				}
				"re" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"are" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "iare" $rhymestr]} {
									return "iA"
								}
								switch -- $word {
									"curare" {
										return "Ari"
									}
									"are" -
									"hectare" {
										return "A"
									}
								}
								return "E"		;#	"snare"
							}
							"cre" {
								return "k."
							}
							"ere" {
								set wordlist1 [list	trouvere misere confrere compere premiere there]
								set wordlist2 [list where]
								set wordlist3 [list	miserere]
								set wordlist4 [list were]
								if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
									return "E"
								} elseif {[WordMatchesAnyOfWords $word $wordlist3]} {
									return "Er4"
								} elseif {[WordMatchesAnyOfWords $word $wordlist4]} {
									return ":"
								}
								return "i."
							}
							"gre" {
								return "g."
							}
							"ire" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "aire" $rhymestr]} {
									return "E"
								} else {
									return "ai."
								}
							}
							"ore" {
								return "O"
							}
							"tre" {
								return "t."
							}
							"ure" {
								if {[WordEndsWithAnyOf $word [list chure]]} {
									return "SO"
								}
								switch -- $word {
									"coiffure" {
										return "f:"
									}
									"allure" -
									"velure" -
									"lure" -
									"ordure" {
										return "i:"
									}
									"censure" {
										return "si."
									}
									"brochure" -
									"flexure" {
										return "S."
									}
								}
								set wordlist1 [list ure endure]
								set wordlist2 [list cure mure nure pure vure]
								if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
									return "iO"
								}
								set wordlist1 [list caricature ligature mature aperture overture]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "CO"
								} elseif {[WordEndsWithAnyOf $word [list ture]]} {
									return "C."
								}
								if {[WordEndsWithAnyOf $word [list gure]]} {
									return "g."
								}
								set wordlist1 [list abjure adjure]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "jO"
								} elseif {[string match "procedure" $word] || [WordEndsWithAnyOf $word [list jure]]} {
									return "j."
								}
								if {[WordEndsWithAnyOf $word [list rasure]]} {
									return "Z."
								}
								set wordlist1 [list sure ensure cocksure embouchure tonsure]
								set wordlist2 [list ssure insure ]
								if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
									return "SO"
								} elseif {[WordEndsWithAnyOf $word [list sure]]} {
									return "Z."		;#	pleasure
								}
								return "i."
							}
							"vre" {
								incr k -2
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "oeuvre" $rhymestr]} {
									return ":vr."
								} else {
									return "vr."
								}
							}
							"yre" {
								return "ai."
							}
						}
					}
				}
				"se" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ase" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								if {[string match "ease" $rhymestr]} {
									set wordlist [list ease cease predecease please displease pease appease disease tease]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "Iz"
									} else {
										return "Is"
									}
								}
								set wordlist1 [list chase steeplechase]
								set wordlist2 [list purchase repurchase carcase]
								set wordlist3 [list blase]
								set wordlist4 [list vase]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "4s"
								}
								if {[WordMatchesAnyOfWords $word $wordlist2]} {
									return ".s"
								}
								if {[WordMatchesAnyOfWords $word $wordlist3]} {
									return "Az4"
								}
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "Az"
								}
								return "4z"
							}
							"ese" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "eese" $rhymestr]} {
									if {[WordEndsWithAnyOf $word [list geese]]} {
										return "Is"
									}
									return "Iz"			;#	cheese
								}
								switch -- $word {
									"obese" {
										return "Is"
									}
									"bolognese" {
										return "ez"
									}
								}
								return "Iz"
							}
							"ise" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"aise" {
										return "4z"
									}
									"oise" {
										return "oiz"
									}
									"uise" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "guise" $rhymestr]} {
											return "aiz"
										} else {
											return "Uz"		;#	cruise
										}
									}
								}
								switch -- $word {
									"treatise" {
										return "iz"
									}
									"concise" -
									"precise" {
										return "ais"
									}
									"practise" -
									"promise" -
									"premise" {
										return "is"
									}
									"cerise" -
									"chemise" -
									"valise" {
										return "Iz"
									}
									"anise" {
										return "Is"
									}
								}
								return "aiz"
							}
							"lse" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"alse" {
										return "ols"
									}
									"ulse" {
										return "uls"
									}
								}
								return "ls"
							}
							"ose" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "oose" $rhymestr]} {
									return "Us"
								} else {
									switch -- $word {
										"dose" {
											return "@s"
										}
										"lose" -
										"whose" {
											return "Uz"
										}
									}
									return "@z"		;#	reimpose		(some ambiguous like close = cl@s or cl@z)
								}
							}
							"pse" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "apse" $rhymestr]} {
									return "aps"
								} else {
									return "ps"
								}
							}
							"rse" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"arse" {
										set rhymestr [IncludePreviousChar $word $k]
										switch -- $rhymestr {
											"earse" {
												return ":s"
											}
											"oarse" {
												return "Os"
											}
										}
										return "As"
									}
									"erse" {
										return ":s"
									}
									"irse" {
										return ":s"
									}
									"orse" {
										if {[string match "worse" $word]} {
											return ":s"
										}
										return "Os"
									}
									"urse" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "ourse" $rhymestr]} {
											return "Os"
										} else {
											return ":s"
										}
									}
								}
							}
							"sse" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"asse" {
										return "as"
									}
									"esse" {
										return "es"
									}
								}
								return "s"
							}
							"use" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"ause" {
										if {[string match "because" $word]} {
											return "os"
										} else {
											return "Oz"
										}
									}
									"euse" {
										return ":z"
									}
									"ouse" {
										if {[string match "blouse" $word] || [WordEndsWithAnyOf $word [list rouse]]} {
											return "aUz"
										}
										return "aUs"
									}
								}
								switch -- $word {
									"ruse" {
										return "Uz"
									}
									"abstruse" {
										return "Us"
									}
									"obtuse" {
										return "iUs"
									}
								}
								return "iUz"
							}
							"wse" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "awse" $rhymestr]} {
									return "Oz"
								}
							}
							"yse" {
								return "aiz"
							}
						}
					}
				}
				"te" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ate" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"eate" {
										return "i4t"
									}
									"iate" {
										set rhymestr [IncludePreviousChar $word $k]
										incr k -1
										switch -- $rhymestr {
											"ciate" {
												set rhymestr [IncludePreviousChar $word $k]
												if {[string match "nciate" $rhymestr]} {
													return "si4t"
												} else {
													return "Si4t"
												}
											}
										}
										return "i4t"
									}
								}													;#	INTRINSIC PROBLEM "separate" (adj) .t (verb) 4t !!!!
								set wordlist1 [list confederate disparate literate illiterate pirate corporate electorate obdurate]
								set wordlist1 [concat $wordlist1 frigate surrogate chocolate desolate disconsolate articulate inarticulate]
								set wordlist1 [concat $wordlist1 climate importunate senate indiscriminate obstinate affectionate]
								set wordlist1 [concat $wordlist1 celibate predicate syndicate certificate triplicate delegate aggregate]
								set wordlist2 [list considerate moderate glomerate temperate accurate determinate passionate private]
								set wordlist2 [concat $wordlist2  proportionate fortunate parate delicate graduate]
								if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
									return ".t"
								}
								return "4t"
							}
							"ete" {
								switch -- $word {
									"fete" {
										return "4t"
									}
									"machete" {
										return "eti"
									}
								}
								return "It"
							}
							"ite" {
								set wordlist1 [list infinite]
								set wordlist2 [list definite]
								if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
									return ".t"
								}
								set wordlist3 [list favourite]
								set wordlist4 [list quisite composite pposite]
								if {[WordMatchesAnyOfWords $word $wordlist3] || [WordEndsWithAnyOf $word $wordlist4]} {
									return "it"
								}
								set wordlist5 [list elite mesquite]
								if {[WordMatchesAnyOfWords $word $wordlist5]} {
									return "It"
								}
								return "ait"		;#	kite, respite
							}
							"nte" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"ante" {
										return "Ont"
									}
									"ente" {
										return "Ont"
									}
								}
								return "nt"
							}
							"ote" {
								return "@t"
							}
							"rte" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"arte" {
										return "At"
									}
									"orte" {
										return "Ot"
									}
								}
							}
							"ste" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"aste" {
										if {[string match "caste" $word ]} {
											return "ast"
										}
										return "4st"		;#	paste
									}
									"iste" {
										return "Ist"
									}
									"oste" {
										return "ost"
									}
								}
								return "st"
							}
							"tte" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								if {[string match "ette" $rhymestr]} {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "uette" $rhymestr]} {
										return "iUet"
									} else {
										if {[string match "pallette" $word ]} {
											return ".t"
										}
										return "et"		;#	serviette
									}
								}
								return "t"
							}
							"ute" {
								return "iUt"
							}
							"yte" {
								return "ait"
							}
						}
					}
				}
				"ue" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"oue" {
								return "U4"
							}
							"que" {
								set rhymestr [IncludePreviousChar $word $k]
								incr k -1
								switch -- $rhymestr {
									"ique" {
										return "Ik"
									}
									"rque" {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "arque" $rhymestr]} {
											return "Ak"
										}
									}
									"sque" {
										set rhymestr [IncludePreviousChar $word $k]
										switch -- $rhymestr {
											"asque" {
												return "ask"
											}
											"esque" {
												return "esk"
											}
										}
										return "sk"
									}
								}
								return "k"
							}
						}
						if {[WordEndsWithAnyOf $word [list true]]} {
							return "U"
						}
						if {[string match "habitue" $word]} {
							return "iU4"
						}
					}
					return "iU"		;#	undue, cue
				}
				"ve" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"ave" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"eave" {
										return "Iv"
									}
									"uave" {
										return "UAv"
									}
								}
								switch -- $word {
									"have" {
										return "av"
									}
									"octave" {
										return "iv"
									}
								}
								return "4v"		;#	concave
							}
							"eve" {
								return "Iv"
							}
							"ive" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"eive" {
										if {[string match "seive" $word ]} {
											return "iv"
										}
										return "Iv"
									}
									"sive" {
										return "siv"
									}
									"tive" {
										return "tiv"
									}
								}
								set wordlist1 [list five alive connive]
								set wordlist2 [list hive rive vive]
								if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
									return "aiv"
								}
								return "iv"			;#	relive, give
							}
							"lve" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"alve" {
										set wordlist1 [list halve calve]
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return "Av"
										}
										return "alv"		;#	salve
									}
									"elve" {
										return "elv"
									}
									"olve" {
										return "olv"
									}
								}
								return "lv"
							}
							"ove" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"oave" {
										return "@v"
									}
									"oove" {
										return "Uv"
									}
								}
								set wordlist1 [list glove love shove dove above]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "uv"
								}
								set wordlist2 [list prove move]
								if {[WordEndsWithAnyOf $word $wordlist2]} {
									return "Uv"
								}
								return "@v"		;#	drove, alcove
							}
							"rve" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"arve" {
										return "Av"
									}
									"erve" {
										return ":v"
									}
									"urve" {
										return ":v"
									}
								}
							}
						}
					}
				}
				"we" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"awe" {
								return "O"
							}
							"ewe" {
								return "iU"
							}
							"owe" {
								return "@"
							}
						}
					}
					return "wI"
				}
				"ye" {
					if {[string match "ye" $word]} {
						return "I"
					}
					return "ai"		;# bullseye
				}
				"ze" {
					set rhymestr [IncludePreviousChar $word $k]
					incr k -1
					if {[string length $rhymestr] > 0} {
						switch -- $rhymestr {
							"aze" {
								return "4z"
							}
							"eze" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "ieze" $rhymestr]} {
									return "Iz"
								}
							}
							"ize" {
								set rhymestr [IncludePreviousChar $word $k]
								switch -- $rhymestr {
									"aize" {
										if {[IsMonosyllabic $word aize]} {
											return "4z"
										}
										return "4aiz"	;#	archaize
									}
									"cize" {
										return "saiz"
									}
									"eize" {
										return "Iz"
									}
								}
								return "aiz"
							}
							"oze" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "ooze" $rhymestr]} {
									return "Uz"
								} else {
									return "@z"
								}
							}
							"yze" {
								return "aiz"
							}
						}
					}
					return "z"
				}
			}
		}
		"f" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"af" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"eaf" {
									return "If"
								}
								"oaf" {
									return "@f"
								}
							}
						}
						return "af"
					}
					"ef" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ief" {
									return "If"
								}
								"eef" {
									return "If"
								}
							}
							return "ef"
						}
					}
					"ff" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aff" {
									return "af"
								}
								"eff" {
									return "ef"
								}
								"iff" {
									return "if"
								}
								"off" {
									return "of"
								}
								"uff" {
									return "uf"
								}
							}
						}
					}
					"if" {
						return "if"
					}
					"lf" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"alf" {
									return "Af"
								}
								"ulf" {
									return "ulf"
								}
							}
						}
					}
					"of" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string match "oof" $rhymestr]} {
							return "Uf"
						} else {
							if {[string match "of" $word]} {
								return "ov"
							}
							return "of"
						}
					}
					"rf" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "arf" $rhymestr]} {
							return "Af"
						}
					}
				}
			}
		}
		"g" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ag" {
						return "ag"
					}
					"eg" {
						return "eg"
					}
					"ig" {
						return "ig"
					}
					"ng" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ang" {
									return "aN"
								}
								"ing" {
									return "iN"
								}
								"ong" {
									return "oN"
								}
								"ung" {
									return "uN"
								}
							}
						}
					}
					"og" {
						return "og"
					}
					"ug" {
						return "ug"
					}
				}
			}
		}
		"h" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ah" {
						if {[string match "ah" $word ]} {
							return "A"
						}
						return "."
					}
					"ch" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ach" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"each" {
											return "IC"
										}
										"oach" {
											return "OC"
										}
									}
									switch -- $word {
										"spinach" {
											return "iC"
										}
										"stomach" {
											return ".k"
										}
										sassenach" {
											return "ak"
										}
									}
								}
								"ech" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "eech" $rhymestr]} {
										return "IC"
									}
								}
								"ich" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "tich" $rhymestr]} {
										return "tik"
									} else {
										if {[string match "sandwich" $word]} {
											return "ij"
										}
										return "iC"
									}
								}
								"lch" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"elch" {
											return "elS"
										}
										"ilch" {
											return "ilC"
										}
									}
								}
								"nch" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"anch" {
											return "anS"
										}
										"ench" {
											return "enS"
										}
										"inch" {
											return "inS"
										}
										"unch" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "aunch" $rhymestr]} {
												return "Ons"
											} else {
												return "unS"
											}
										}
									}
								}
								"rch" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"arch" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "earch" $rhymestr]} {
												return ":C"
											} else {
												set wordlist1 [list oligarch anarch tetrarch]
												set wordlist2 [list triarch ierarch]
												if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
													return "Ak"
												}
												return "AC"		;#	parch
											}
										}
										"erch" {
											return ":C"
										}
										"irch" {
											return ":C"
										}
										"orch" {
											return "OC"
										}
										"urch" {
											return ":C"
										}
									}
								}
								"tch" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"atch" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "watch" $rhymestr]} {
												return "oC"
											} else {
												return "aC"
											}
										}
										"etch" {
											return "eC"
										}
										"itch" {
											return "iC"
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "aitch" $rhymestr]} {
												return "4C"
											} else {
												return "iC"
											}
										}
										"otch" {
											return "oC"
										}
										"utch" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "autch" $rhymestr]} {
												return "OC"
											} else {
												return "uC"
											}
										}
									}
								}
								"uch" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"auch" {
											return "OC"
										}
										"euch" {
											return "iUk"
										}
										"ouch" {
											if {[string match "touch" $word ]} {
												return "uC"
											}
											return "aUC"
										}
									}
									if {[string match "eunuch" $word ]} {
										return ".k"
									}
									return "uC"			;#	inasmuch
								}
							}
						}
					}
					"gh" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"agh" {
									return "."
								}
								"igh" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "eigh" $rhymestr]} {
										return "4"
									} else {
										return "ai"
									}
								}
								"ugh" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"augh" {
											if {[string match "laugh" $word ]} {
												return "af"
											}
											return "O"
										}
										"ough" {
											set wordlist1 [list rough tough chough clough lough enough]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "uf"
											}
											set wordlist2 [list thorough borough]
											if {[WordMatchesAnyOfWords $word $wordlist2]} {
												return "r."
											}
											set wordlist3 [list through]
											if {[WordMatchesAnyOfWords $word $wordlist3]} {
												return "U"
											}
											set wordlist4 [list though dough although furlough]
											if {[WordMatchesAnyOfWords $word $wordlist4]} {
												return "@"
											}
											set wordlist5 [list hiccough]
											if {[WordMatchesAnyOfWords $word $wordlist5]} {
												return "up"
											}
											set wordlist6 [list trough cough]
											if {[WordMatchesAnyOfWords $word $wordlist6]} {
												return "of"
											}
											set wordlist7 [list plough bough]
											if {[WordMatchesAnyOfWords $word $wordlist7]} {
												return "aU"
											}
										}
									}
								}
							}
						}
					}
					"kh" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							if {[string match "ikh" $rhymestr]} {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string length $rhymestr] > 0} {
									if {[string match "eikh" $rhymestr]} {
										return "4k"		;#	sheikh
									} else {		
										return "Ik"		;#	sikh
									}
								}
							}
						}
					}
					"ph" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aph" {
									return "af"
								}
								"mph" {
									return "mf"
								}
								"rph" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "orph" $rhymestr]} {
										return "Of"
									}
								}
								"yph" {
									return "if"
								}
							}
						}
					}
					"sh" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ash" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"eash" {
											return "Is"
										}
										"uash" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "quash" $rhymestr]} {
												return "kUosh"
											} else {
												return "oS"
											}
										}
										"wash" {
											return "UoS"
										}
									}
									return "aS"
								}
								"esh" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "eesh" $rhymestr]} {
										return "Is"
									} else {
										return "eS"
									}
								}
								"ish" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "uish" $rhymestr]} {
										set wordlist1 [list roguish cliquish]
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return "iS"
										}
										return "UiS"
									}
									return "iS"
								}
								"lsh" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "elsh" $rhymestr]} {
										return "elS"
									}
								}
								"osh" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "oosh" $rhymestr]} {
										return "US"
									} else {
										return "oS"
									}
								}
								"ush" {
									return "uS"
								}
							}
						}
					}
					"th" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ath" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"eath" {
											if {[string match "breath" $word]} {
												return "eT"
											} else {
												return "IT"
											}
										}
										"oath" {
											return "@T"
										}
									}
									return "aT"
								}
								"dth" {
									incr k -1
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "eadth" $rhymestr]} {
										return "edT"
									} else {
										return "dT"
									}
								}
								"eth" {
									return "i.T"
								}
								"ith" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"aith" {
											if {[string match "saith" $word]} {
												return "eT"
											} else {
												return "4T"		;#	wraith
											}
										}
										"mith" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "smith" $rhymestr]} {
												return "smiT"
											} else {
												return "miT"
											}
										}
										"with" {
											if {[string match "forthwith" $word]} {
												return "T"
											} else {
												return "7"
											}
										}
									}
									return "iT"
								}
								"lth" {
									return "tT"
								}
								"nth" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"onth" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ionth" $rhymestr]} {
												return "i.nT"
											} else {
												return "unT"
											}
										}
										"ynth" {
											return "inT"
										}
									}
									return "nT"
								}
								"oth" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ooth" $rhymestr]} {
										if {[string match "tooth" $word]} {
											return "UT"
										} else {
											return "U7"		;#	 booth
										}
									} else {
										set wordlist1 [list both sloth]
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return "@T"
										} else {
											return "oT"		;#	 broth
										}
									}
								}
								"rth" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"arth" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "earth" $rhymestr]} {
												if {[string match "hearth" $word]} {
													return "AT"
												} else {
													return ":T"		;#	earth
												}
											}
										}
										"erth" {
											return ":T"
										}
										"irth" {
											return ":T"
										}
										"orth" {
											set wordlist2 [list worth]
											if {[WordEndsWithAnyOf $word $wordlist2]} {
												return ":T"
											}
											return "OT"		;#	forth
										}
										"urth" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ourth" $rhymestr]} {
												return "OT"
											}
										}
									}
								}
								"uth" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"euth" {
											return "UT"
										}
										"outh" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "youth" $rhymestr]} {
												return "iUT"
											} else {
												return "aUT"
											}
										}
									}
									return "uT"
								}
								"wth" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "owth" $rhymestr]} {
										return "@T"
									}
								}
							}
						}
						if {[string match "th" $word]} {
							return "7."
						}
					}
					"uh" {
						return "."
					}
				}
			}
		}
		"i" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string match $rhymestr "ui"]} {
				return "Ui"
			} else {
				if {[string match "i" $word]} {
					return "ai"
				}
				return "i"
			}
		}
		"k" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ak" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"eak" {
									if {[string match "break" $word]} {
										return "4k"
									} else {
										return "Ik"		;#	 beak , creak
									}
								}
								"oak" {
									return "@k"
								}
							}
						}
						return "ak"
					}
					"ck" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ack" {
									return "ak"
								}
								"eck" {
									return "ek"
								}
								"ick" {
									return "ik"
								}
								"ock" {
									return "ok"
								}
								"uck" {
									return "uk"
								}
							}
						}
					}
					"ek" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"eek" {
									return "Ik"
								}
								"iek" {
									return "Ik"
								}
							}
						}
						return "ek"
					}
					"ik" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "aik" $rhymestr]} {
							return "4k"
						} else {
							return "ik"
						}
					}
					"lk" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"alk" {
									return "Ok"
								}
								"elk" {
									return "elk"
								}
								"ilk" {
									return "ilk"
								}
								"ulk" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "aulk" $rhymestr]} {
										return "olk"
									} else {
										return "ulk"
									}
								}
							}
						}
					}
					"nk" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"enk" {
									return "enk"
								}
								"ink" {
									return "ink"
								}
								"onk" {
									return "onk"
								}
								"unk" {
									return "unk"
								}
							}
						}
					}
					"ok" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ook" {
									incr k -1
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "spook" $rhymestr]} {
										return "spUk"
									} else {
										return "uk"
									}
								}
							}
						}
						if {[string match "ok" $word]} {
							return "@k4"
						}
						return "ok"
					}
					"rk" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ark" {
									return "Ak"
								}
								"erk" {
									return ":k"
								}
								"irk" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "uirk" $rhymestr]} {
										return "U:k"
									} else {
										return ":k"
									}
								}
								"urk" {
									return ":k"
								}
							}
						}
					}
					"sk" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ask" {
									return "ask"
								}
								"esk" {
									return "esk"
								}
								"isk" {
									return "isk"
								}
								"rsk" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"arsk" {
											return "Ask"
										}
										"irsk" {
											return ":sl"
										}
									}
								}
								"usk" {
									return "usk"
								}
							}
						}
					}
					"uk" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "auk" $rhymestr]} {
							return "Ok"
						}
					}
					"wk" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "awk" $rhymestr]} {
							return "Ok"
						}
					}
				}
			}
		}
		"l" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"al" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aal" {
									return "Al"
								}
								"cal" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"acal" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "iacal" $rhymestr]} {
												return "i.k.l"
											} else {
												return ".k.l"
											}
										}
										"ical" {
											return "ik.l"
										}
										"ocal" {
											if {[string match "reciprocal" $word]} {
												return "@.k.l"
											} else {
												return "@k.l"	;#	 vocal
											}
										}
									}
									return "k.l"
								}
								"dal" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									if {[string match "idal" $rhymestr]} {
										set rhymestr [IncludePreviousChar $word $k]
										if {[string match "oidal" $rhymestr]} {
											return "oid.l"
										} else {
											if {[string match "pyramidal" $word]} {
												return "id.l"
											} else {
												return "aid.l"	;#	suicidal
											}
										}
									}
								}
								"eal" {
									if {[string match "congeal" $word]} {
										return "Il"
									}
									set wordlist1 [list tracheal nucleal pineal diarrhoeal]
									set wordlist2 [list geal geneal lineal oneal real]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "i.l"
									}
									return "Il"
								}
								"ial" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"cial" {
											set wordlist1 [list glacial fiducial pronuncial uncial quincuncial]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "si.l"
											} else {
												return "S.l"	;#	special
											}
										}
										"tial" {
											return "S.l"
										}
									}
									return "i.l"
								}
								"mal" {
									return "m.l"
								}
								"nal" {
									return "n.l"
								}
								"oal" {
									return "@l"
								}
								"ral" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"tral" {
											return "tr.l"
										}
										"ural" {
											return "iUr.l"
										}
									}
									return "r.l"

								}
								"sal" {
									return "s.l"
								}
								"tal" {
									return "t.l"
								}
								"ual" {
									return "iU.l"
								}
							}
						}
						if {[IsMonosyllabic $word al]} {
							return "al"
						}
						return ".l"
					}
					"el" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"eel" {
									return "Il"
								}
								"iel" {
									set wordlist2 [list spiel]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "Il"
									} else {
										return "i.l"
									}
								}
							}
							if {[string match "noel" $word]} {
								return "@el"
							}
						}
						return ".l"
					}
					"il" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ail" {
									return "4l"
								}
								"eil" {
									return "4l"
								}
								"oil" {
									return "oil"
								}
								"uil" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ueil" {
											return "oi"
										}
										"quil" {
											return "kUil"
										}
									}
								}
							}
						}
						return "il"
					}
					"ll" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"all" {
									set wordlist1 [list shall]
									set wordlist2 [list mall]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "al"
									} else {
										return "Ol"		;#	small
									}
								}
								"ell" {
									return "el"
								}
								"ill" {
									return "il"
								}
								"oll" {
									set wordlist1 [list poll roll scroll breadroll enroll stroll toll plimsoll]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "@l"
									} else {
										return "ol"		;#	doll, atoll
									}
								}
								"ull" {
									return "ul"
								}
								"yll" {
									return "il"
								}
							}
						}
					}
					"ol" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "ool" $rhymestr]} {
							return "Ul"
						} else {
							return "ol"
						}
					}
					"rl" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"arl" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "earl" $rhymestr]} {
										return ":l"
									} else {
										return "Al"
									}
								}
								"irl" {
									return ":l"
								}
								"url" {
									return ":l"
								}
							}
						}
					}
					"ul" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aul" {
									return "Ol"
								}
								"ful" {
									return "ful"
								}
								"oul" {
									switch -- $word {
										"ghoul" {
											return "Ul"
										}
										"soul" {
											return "@l"
										}
									}
									return "aUl"		;#	foul
								}
							}
						}
						return "ul"
					}
					"wl" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "awl" $rhymestr]} {
							return "Ol"
						}
					}
					"yl" {
						return "il"
					}
				}
			}
		} 
		"m" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"am" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "oam" $rhymestr]} {
							return "@m"
						} else {
							return "am"
						}
					}
					"em" {
						if {[string match "tandem" $word]} {
							return ".m"
						}
						return "em"
					}
					"gm" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"agm" {
									return "am"
								}
								"egm" {
									return "em"
								}
								"igm" {
									return "aim"
								}
							}
						}
					}
					"hm" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string match "thm" $rhymestr]} {
							set rhymestr [IncludePreviousChar $word $k]
							if {[string length $rhymestr] > 0} {
								switch -- $rhymestr {
									"ithm" {
										return "i7m"
									}
									"ythm" {
										return "i7m"
									}
								}
							}
						}
					}
					"im" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "aim" $rhymestr]} {
							return "4m"
						} else {
							return "im"
						}
					}
					"lm" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"alm" {
									return "Am"
								}
								"elm" {
									return "elm"
								}
								"ilm" {
									return "ilm"
								}
								"olm" {
									return "@m"
								}
								"ulm" {
									return "ulm"
								}
							}
						}
					}
					"om" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "dom" $rhymestr]} {
							return "d.m"
						}
					}
					"rm" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"arm" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "warm" $rhymestr]} {
										return "Om"
									} 
									return "Am"		;#	harm, disarm
								}
								"erm" {
									return ":m"
								}
								"irm" {
									return ":m"
								}
								"orm" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "form" $rhymestr]} {
										return "fOm"
									} else {
										return "Om"
									}
								}
							}
						}
					}
					"sm" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"asm" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "iasm" $rhymestr]} {
										return "iaz.m"
									} else {
										return "az.m"
									}
								}
								"ism" {
									return "iz.m"
								}
							}
						}
					}
					"um" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						switch -- $rhymestr {
							"aum" {
								return "Om"
							}
							"oum" {
								return "Um"
							}
							"eum" {
								set rhymestr [IncludePreviousChar $word $k]
								if {[string match "aeum" $rhymestr]} {
									return "4.m"
								}
								set wordlist1 [list lyceum mausoleum colloseum museum]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "I.m"
								}
								return "i.m"
							}
							"ium" {
								if {[string match "belgium" $word]} {
									return ".m"
								}
								return "i.m"
							}
						}
						if {[IsMonosyllabic $word um] || [WordEndsWithAnyOf $word [list drum]]} {
							return "um"
						}
						return ".m"
					}
					"ym" {
						return "im"
					}
				}
			}
		}
		"n" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"an" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ean" {
									if {[string match "galilean" $word]} {	;#	but could be 'galilI.n . from Galilee
										return "4.n"
									}
									set wordlist1 [list pean paean pythagorean]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "I.n"
									}
									if {[IsMonosyllabic $word ean]} {
										return "In"
									}
									set wordlist1 [list jacobean lyncean]
									set wordlist2 [list ucean]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "i.n"
									}
									set wordlist1 [list bemean demean misdemean]
									set wordlist2 [list bean]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "In"
									}
									set wordlist12 [list cean]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "S.n"
									}
									return "i.n"
								}
								"ian" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"cian" -
										"sian" -
										"tian" {
											return "S.n"
										}
										"gian" {
											return "j.n"
										}
									}
									if {[string match "ian" $word]} {
										return "I.n"
									}
									return "i.n"
								}
								"man" {
									set wordlist1 [list man hangman middleman orangeman freeman bargeman lineman exciseman]
									set wordlist1 [concat $wordlist1 taxman horseman norseman ragman bushman packman oilman schoolman merman]
									set wordlist1 [concat $wordlist1 superman talisman pressman batman handyman nurseryman]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "man"
									}
									return "m.n"
								}
								"oan" {
									return "@n"
								}
							}
						}
						if {[IsMonosyllabic $word an]} {
							return "an"
						}
						return ".n"
					}
					"en" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"een" {
									return "In"
								}
								"ien" {
									if {[string match "alien" $word]} {
										return "i.n"
									}
									return "In"		;#	mien
								}
								"ten" {
									if {[string match "ten" $word]} {
										return "ten"
									}
									return "t.n"
								}
							}
							if {[IsMonosyllabic $word en]} {
								return "en"
							}
						}
						return ".n"
					}
					"gn" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string match "ign" $rhymestr]} {
							set rhymestr [IncludePreviousChar $word $k]
							switch -- $rhymestr {
								"aign" {
									return "4n"
								}
								"eign" {
									set wordlist1 [list foreign sovereign]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "in"
									}
									return "4n"		;#	feign
								}
							}
							return "ain"
						}
					}
					"hn" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "ohn" $rhymestr]} {
							return "on"
						}
					}
					"in" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ain" {
									switch -- $word {
										"again" {
											return "en"
										}
										"legerdemain" {
											return "a"
										}
									}
									set wordlist1 [list chaplain chamberlain captain]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "in"
									}
									set wordlist2 [list bargain villain britain fountain mountain certain uncertain curtain]
									if {[WordMatchesAnyOfWords $word $wordlist2]} {
										return ".n"
									}
									return "4n"		;#	main
								}
								"ein" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"rein" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "erein" $rhymestr]} {
												return "i.in"
											} else {
												return "r4n"
											}
										}
										"bein" {				;#	bein'
											return "Iin"
										}
										"sein" {
											return "In"
										}
										"tein" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "stein" $rhymestr]} {
												return "stain"
											} else {
												return "In"
											}
										}
									}
									set wordlist1 [list nuclein olein]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "4in"
									}
									set wordlist2 [list fraulein zollverein]
									if {[WordMatchesAnyOfWords $word $wordlist2]} {
										return "ain"
									}
									return "4n"	;#	skein mullein rein vein
								}
								"oin" {
									return "oin"
								}
								"uin" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "quin" $rhymestr]} {
										return "kUin"
									} else {
										return "Uin"
									}
								}
							}
						}
						return "in"
					}
					"mn" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"amn" {
									return "am"
								}
								"emn" {
									return "em"
								}
								"ymn" {
									return "im"
								}
							}
						}
					}
					"nn" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "inn" $rhymestr]} {
							return "in"
						}
					}
					"on" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"eon" {
									switch -- $word {
										"neon" {
											return "Ion"
										}
										"hereon" {
											return "i.ron"
										}
										"thereon" -
										"whereon" {
											return "Eron"
										}
									}
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"geon" {
											return "j.n"
										}
										"heon" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "cheon" $rhymestr]} {
												return "S.n"
											}
										}
									}
									return "I.n"
								}
								"ion" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"gion" {
											return "j.n"
										}
										"sion" -
										"xion" {
											return "S.n"
										}
										"cion" {
											if {[string match "scion" $word]} {
												return  "sai.n"
											}
											return "Sin"
										}
										"hion" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "chion" $rhymestr]} {
												return "S.n"
											}
										}
										"tion" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"ation" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "cation" $rhymestr]} {
														if {[string match "cation" $word]} {
															return "katai.n"
														} else {
															return "k4S.n"
														}
													} else {
														return "4S.n"
													}
												}
												"ction" {
													return "kS.n"
												}
												"ition" {
													return "iS.n"
												}
												"ption" {
													return "pS.n"
												}
											}
											return "S.n"
										}
									}
									set wordlist1 [list zion ion lion dandelion]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "ai.n"
									}
									return "i.n"	;#	million

								}
								"oon" {
									set wordlist1 [list protozoon pytozoon bryozoon polyzoon]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "@.n"
									}
									return "Un"
								}
								"yon" {
									switch -- $word {
										"crayon" {
											return ".n"
										}
										"rayon" {
											return "on"
										}
										"yon" {
											return "ion"
										}
									}
									return "i.n"	;#	halcyon
								}
							}
						}
						set wordlist1 [list zircon catholicon rubicon icon con on don bombardon bourdon aeon trigon zigon]
						set wordlist1 [concat $wordlist1 orthogon argon ergon polygon archon antiphon solophon autochthon]
						set wordlist1 [concat $wordlist1 anon organon xenon crampon tampon charon diatesaron macron liaison]
						set wordlist1 [concat $wordlist1 acheron aileron boron oxymoron electron neuron chevron diapason]
						set wordlist1 [concat $wordlist1 upon canton lepton krypton won yon]
						if {[WordMatchesAnyOfWords $word $wordlist1]} {
							return "on"
						}
						set wordlist2 [list gascon garcon soupcon bonbon salon chignon mignon environ chanson]
						if {[WordMatchesAnyOfWords $word $wordlist2]} {
							return "o"
						}
						set wordlist3 [list chaperon]
						if {[WordMatchesAnyOfWords $word $wordlist3]} {
							return "@n"
						}
						set wordlist4 [list iron gridiron]
						if {[WordMatchesAnyOfWords $word $wordlist4]} {
							return "ai.n"
						}
						set wordlist5 [list son grandson greatgrandson ton]
						if {[WordMatchesAnyOfWords $word $wordlist5]} {
							return "un"
						}
						return ".n"		;#	singleton
					}
					"rn" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"arn" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "earn" $rhymestr]} {
										return ":n"
									} else {
										return "An"
									}
								}
								"ern" {
									set wordlist1 [list tern intern stern extern astern extern]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return ":n"
									}
									set wordlist1 [list modern]
									set wordlist2 [list thern tern vern]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return ".n"
									}
									return ":n"
								}
								"irn" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "airn" $rhymestr]} {
										return "En"
									}
								}
								"orn" {
									if {[string match "stubborn" $word]} {
										return ".n"
									}
									return "On"		;#	horn
								}
								"urn" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ourn" $rhymestr]} {
										set wordlist1 [list bourn mourn]
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return "On"
										}
										return ":n"		;#	adjourn
									} else {
										set wordlist1 [list auburn saturn]
										if {[WordMatchesAnyOfWords $word $wordlist1]} {
											return ".n"
										}
										return ":n"		;#	burn
									}
								}
							}
						}
					}
					"un" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aun" {
									return "On"
								}
								"oun" {
									return "aUn"
								}
							}
						}
						return "un"
					}
					"wn" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"awn" {
									return "On"
								}
								"own" {
									set wordlist2 [list known lown grown sown]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "@n"
									}
									return "aUn"		;#	gown, town
								}
							}
						}
					}
					"yn" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "oyn" $rhymestr]} {
							return "oin"
						} else {
							return "in"
						}
					}
				}
			}
		} 
		"o" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ao" {
						return "aU"
					}
					"eo" {
						return "i@"
					}
					"io" {
						return "i@"
					}
					"oo" {
						return "U"
					}
					"yo" {	
						return "i@"
					}
				}
				set wordlist1 [list do who two]
				if {[WordMatchesAnyOfWords $word $wordlist1]} {
					return "U"
				}
				set wordlist1 [list to into unto hitherto hereto]
				set wordlist2 [list ereto] 
				if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
					return "u"
				}
			}
			return "@"	;#	prospero alamo
		} 
		"p" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ap" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"eap" {
									return "Ip"
								}
								"oap" {
									return "@p"
								}
							}
						}
						return "ap"
					}
					"ep" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "eep" $rhymestr]} {
							return "Ip"
						} else {
							return "ep"
						}
					}
					"ip" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string match "hip" $rhymestr]} {
							set rhymestr [IncludePreviousChar $word $k]
							if {[string match "ship" $rhymestr]} {
								return "Sip"
							}
						}
						return "ip"
					}
					"lp" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"alp" {
									return "alp"
								}
								"elp" {
									return "elp"
								}
								"ilp" {
									return "ilp"
								}
							}
						}
					}
					"mp" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"amp" {
									return "amp"
								}
								"emp" {
									return "emp"
								}
								"imp" {
									return "imp"
								}
								"omp" {
									return "omp"
								}
								"ump" {
									return "ump"
								}
							}
						}
					}
					"op" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "oop" $rhymestr]} {
							if {[string match "coop" $word]} {
								return "@op"
							}
							return "Up"			;#	loop
						} else {
							if {[string match "orlop" $word] || [IsMonosyllabic $word op] || [WordEndsWithAnyOf $word [list slop]]} {
								return "op"
							}
							set wordlist2 [list bishop hysop lop]
							if {[WordEndsWithAnyOf $word $wordlist2]} {
								return ".p"
							}
							return "op"		;#	beershop, eavesdrop
						}
					}
					"rp" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"arp" {
									if {[string match "warp" $word]} {
										return "Op"
									}
									return "Ap"		;#	harp
								}
								"irp" {
									return ":p"
								}
								"orp" {
									return "Op"
								}
								"urp" {
									return ":p"
								}
							}
						}
					}
					"sp" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"asp" {
									if {[string match "wasp" $word]} {
										return "osp"
									}
									return "asp"		;#	grasp
								}
								"isp" {
									return "isp"
								}
								"usp" {
									return "usp"
								}
							}
						}
					}
					"up" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aup" {
									return "Op"
								}
								"oup" {
									if {[string match "coup" $word]} {
										return "U"
									}
									return "Up"		;#	group, soup
								}
							}
						}
						return "up"
					}
					"yp" {
						return "ip"
					}
				}
			}
		} 
		"r" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ar" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aar" {
									return "A"
								}
								"ear" {
									if {[string match "pear" $word]} {
										return "E"
									}
									set wordlist2 [list bear tear wear]			;#	tear is ambiguous
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "E"
									}
									return "i."					;#	headgear, nuclear
								}
								"iar" {
									if {[IsMonosyllabic $word iar]} {
										return "ai."			;#	friar
									}
									return "i."					;#	peculiar
								}
								"lar" {
									return "l."
								}
								"oar" {
									return "O"
								}
							}
							switch -- $word {
								"seminar" {
									return "A"
								}
								"war" {
									return "O"
								}
							}
							set wordlist1 [list vicar velar burglar grammar cheddar laminar cedar calendar venegar beggar]
							set wordlist1 [concat $wordlist1 vulgar hangar bursar sugar nectar altar tartar mortar jaguar]
							set wordlist2 [list lar nar macassar]
							if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
								return "."
							}
						}
						return "A"
					}
					"er" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ber" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"aber" {
											return "4b."
										}
										"bber" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"abber" {
													return "ab."
												}
												"ibber" {
													return "ib."
												}
												"obber" {
													return "ob."
												}
												"ubber" {
													return "ub."
												}
											}
											return "b."
										}
										"iber" {
											return "aib."
										}
										"mber" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"amber" {
													if {[string match "chamber" $word]} {
														return "4mb."
													}
													return "amb."
												}
												"ember" {
													return "emb."
												}
												"imber" {
													if {[string match "climber" $word]} {
														return "aim."
													}
													return "imb."		;#	timber
												}
												"omber" {
													if {[string match "bomber" $word]} {
														return "om."
													}
													return "@m."		;#	beachcomber
												}
												"umber" {
													if {[string match "plumber" $word]} {
														return "um."
													}
													return "umb."		;#	lumber
												}
											}
										}
										"ober" {
											return "@b."
										}
										"rber" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"arber" {
													return "Ab."
												}
												"erber" {
													return ":b."
												}
												"orber" {
													return "Ob."
												}
												"urber" {
													return ":b."
												}
											}
										}
										"uber" {
											return "iUb."
										}
									}
									return "b."
								}
								"cer" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"acer" {
											if {[string match "surfacer" $word]} {
												return "is."
											}
											set wordlist1 [list prefacer menacer grimacer]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return ".s."
											}
											return "4s."		;#	racer
										}
										"ccer" {
											return "k."
										}
										"ecer" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"eecer" {
													return "Is."
												}
												"iecer" {
													return "Is."
												}
											}
										}
										"icer" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "oicer" $rhymestr]} {
												return "ois."
											} else {
												if {[string match "officer" $word]} {
													return "is."
												}
												return "ais."	;#	slicer
											}
										}
									}
								}
								"der" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ader" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"eader" {
													switch -- $word {
														"reader" {
															return "Id."
														}
														"header" {
															return "ed."
														}
													}
													set wordlist2 [list reader teader]
													if {[WordEndsWithAnyOf $word $wordlist2]} {	;#	homesteader, threader
														return "ed."
													}
													return "Id."	;#	cheerleader
												}
												"oader" {
													return "@d."
												}
											}
											return "4d."
										}
										"dder" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"adder" {
													return "ad."
												}
												"edder" {
													return "ed."
												}
												"idder" {
													return "id."
												}
												"odder" {
													return "od."
												}
												"udder" {
													return "dd."
												}
											}
										}
										"eder" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"eeder" {
													return "Id."
												}
												"ieder" {
													return "Id."
												}
											}
											return "Id."
										}
										"ider" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"aider" {
													return "4d."
												}
												"eider" {
													return "aid."
												}
												"oider" {
													return "oid."
												}
											}
											if {[WordEndsWithAnyOf $word [list consider]]} {
												return "id."
											}
											return "aid."	;#	rider, divider
										}
										"lder" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"alder" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "balder" $rhymestr]} {
														return "Old."
													} else {
														return "old."
													}
												}
												"elder" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "ielder" $rhymestr]} {
														return "Ild."
													} else {
														return "eld."
													}
												}
												"ilder" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "uilder" $rhymestr]} {
														return "ild."
													} else {
														return "aild."
													}
												}
												"older" {
													return "@ld."		;#	northern pronunciation
												}
												"ulder" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "oulder" $rhymestr]} {
														return "oUld."
													}
												}
											}
											return "ld."
										}
										"nder" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"ander" {
													if {[string match "wander" $word]} {
														return "ond."
													}
													return "and."	;#	overlander
												}
												"ender" {
													set wordlist1 [list cullender lavender]
													if {[WordMatchesAnyOfWords $word $wordlist1]} {
														return ".nd."
													}
													return "end."		;#	bender
												}
												"inder" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"ainder" {
															return "4nd."
														}
														"oinder" {
															return "oind."
														}
													}
													set wordlist1 [list hinder cylinder tinder]
													if {[WordMatchesAnyOfWords $word $wordlist1]} {
														return "ind."
													}
													return "aind."		;#	kinder
												}
												"onder" {
													if {[string match "wonder" $word]} {
														return "und."
													}
													return "ond."		;#	yonder
												}
												"under" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"aunder" {
															return "Ond."
														}
														"ounder" {
															return "aUnd."
														}
													}
													return "und."
												}
											}
											return "nd."
										}
										"rder" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"arder" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "oarder" $rhymestr]} {
														return "Od."
													} else {
														switch -- $word {
															"forwarder" {
																return ".d."
															}
															"warder" {
																return "Od."
															}
														}
														return "Ad."	;#	harder
													}
												}
												"irder" {
													return ":d."
												}
												"order" {
													return "Od."
												}
												"urder" {
													return ":d."
												}
											}
										}
										"uder" {
											return "Ud."
										}
										"wder" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "owder" $rhymestr]} {
												return "aUd."
											}
										}
									}
									return "d."
								}
								"eer" {
									switch -- $word {
										"fleer" {
											return "I."
										}
										"whateer" -
										"neer" {				;#	whate'er ne'er
											return "E"
										}
									}
									if {[WordEndsWithAnyOf $word [list oeer]]} {	;#	whoe'er etc.
										return "E"
									}
									return "i."					;#	steer
								}
								"fer" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"afer" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "oafer" $rhymestr]} {
												return "@f."
											} else {
												return "4f."
											}
										}
										"efer" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "eefer" $rhymestr]} {
												return "If."
											}
											return "if:"
										}
										"ffer" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"affer" {
													return "af."
												}
												"iffer" {
													return "if."
												}
												"offer" {
													if {[string match "proffer" $word]} {
														return "of:"
													}
													return "of."
												}
												"uffer" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "auffer" $rhymestr]} {
														return "@f:"
													} else {
														return "uf."
													}
												}
											}
										}
										"ifer" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "eifer" $rhymestr]} {
												return "ef."
											} else {
												if {[string match "lifer" $word]} {
													return "aif."
												}
												return "if."		;#	 conifer
											}
										}
										"ofer" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "oofer" $rhymestr]} {
												return "Uf."
											}
										}
									}
									set wordlist2 [list infer confer]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "f:"
									}
									return "f."
								}
								"ger" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ager" {
											if {[string match "wager" $word]} {
												return "4j."
											}
											return ".j."
										}
										"dger" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"adger" {
													return "aj."
												}
												"edger" {
													return "ej."
												}
												"idger" {
													return "ij."
												}
												"odger" {
													return "oj."
												}
												"udger" {
													return "uj."
												}
											}
										}
										"eger" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ieger" $rhymestr]} {
												return "Ij."
											}
											switch -- $word {
												"colleger" {
													return "ij."
												}
												"integer" {
													return ".j."
												}
											}
										}
										"gger" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"agger" {
													return "ag."
												}
												"egger" {
													return "eg."
												}
												"igger" {
													return "ig."
												}
												"ogger" {
													return "og."
												}
												"ugger" {
													return "ug."
												}
											}
											return "g."
										}
										"iger" {
											if {[string match "tiger" $word]} {
												return "aig."
											}
											return "aij."		;#	 obliger
										}
										"nger" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"anger" {
													if {[string match "anger" $word]} {
														return "aNg."
													}
													set wordlist1 [list banger hanger]
													set wordlist2 [list ganger]
													if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
														return "aN."
													}
													set wordlist1 [list flanger phalanger]
													if {[WordMatchesAnyOfWords $word $wordlist1]} {
														return "anj."
													}
													return "4nj."	;#	manger, danger
												}
												"inger" {
													set wordlist2 [list stinger stringer wringer singer springer]
													if {[WordEndsWithAnyOf $word $wordlist2]} {
														return "iN."
													}
													set wordlist1 [list linger malinger]
													set wordlist2 [list finger]
													if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
														return "iNg."
													}
													return "inj."		;#	ginger
												}
												"onger" {
													switch -- $word {
														"wronger" -
														"prolonger" {
															return "oN."
														}
														"sponger" {
															return "unj."
														}
													}
													return "oNg."		;#	fishmonger, conger
												}
												"unger" {
													if {[string match "hunger" $word]} {
														return "uNg."
													}
													return "unj."		;#	plunger
												}	
											}
											return "nj."
										}
										"oger" {
											return ".j."
										}
										"uger" {
											switch -- $word {
												"auger" {
													return ":j."
												}
												"guager" {
													return "4j."
												}
												"huger" {
													return "iUj."
												}
											}
										}
									}
									return "j."
								}
								"her" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"cher" {
											if {[string match "stomacher" $word]} {
												return ".k."
											}
											if {[WordEndsWithAnyOf $word [list ncher]]} {
												return "S."			;#	clincher
											}
											return "C."
										}
										"pher" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"apher" {
													return ".f."
												}
												"opher" {
													if {[string match "gopher" $word]} {
														return "@f."
													}
													return ".f."	;#	philosopher
												}
											}
											return "f."
										}
										"sher" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"asher" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "washer" $rhymestr]} {
														return "UoS."
													} else {
														return "aS."
													}
												}
												"esher" {
													return "eS."
												}
												"isher" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "uisher" $rhymestr]} {
														return "UiS."
													} else {
														return "iS."
													}
												}
											}
										}
										"ther" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"ather" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"eather" {
															if {[string match "breather" $word]} {
																return "I7."
															}
															return "e7."		;#	leather, weather
														}
														"oather" {
															return "@T."
														}
													}
													if {[WordEndsWithAnyOf $word [list father]]} {
														return "A7."
													}
													return "a7."		;#	lather
												}
												"ether" {
													if {[string match "ether" $word]} {
														return "IT."
													}
													return "e7."
												}
												"ither" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "either" $rhymestr]} {
														return "ai7."
													} else {
														return "i7."
													}
												}
												"nther" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "anther" $rhymestr]} {
														return "anT."
													}
												}
												"other" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "oother" $rhymestr]} {
														return "U7."
													} else {
														set wordlist1 [list other smother another]
														set wordlist2 [list mother brother]
														if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
															return "u7."
														}
														return "o7."		;#	bother
													}
												}
												"rther" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"arther" {
															return "A7."
														}
														"urther" {
															return ":7."
														}
													}
												}
												"uther" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "outher" $rhymestr]} {
														return "aUT."
													}
												}
											}
											return "7."
										}
									}
								}
								"ier" {
									switch -- $word {
										"courier" {
											return "i."
										}
										"costumier" {
											return "i4"
										}
									}
									if {[WordEndsWithAnyOf $word [list rrier]]} {
										return "i."
									}
									set wordlist1 [list prophsier occupier]
									set wordlist2 [list rier]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "ai."
									}
									set wordlist1 [list brigadier grenadier halbedier bombadier cashier cavalier chandelier fuselier]
									set wordlist1 [concat $wordlist1 pier tier bandolier gondolier frontier]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "I."
									}
									return "i."		;#	happier
								}
								"ker" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"aker" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"aaker" {
													return "Ak."
												}
												"eaker" {
													return "Ik."
												}
											}
											if {[string match "spinnaker" $word]} {
												return ".k."
											}
											return "4k."		;#	breadmaker
										}
										"cker" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"acker" {
													return "ak."
												}
												"ecker" {
													return "ek."
												}
												"icker" {
													return "ik."
												}
												"ocker" {
													return "ok."
												}
												"ucker" {
													return "uk."
												}
											}
										}
										"eker" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "eeker" $rhymestr]} {
												return "Ik."
											}
										}
										"iker" {
											return "aik."
										}
										"kker" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ekker" $rhymestr]} {
												return "ek."
											}
										}
										"lker" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "alker" $rhymestr]} {
												return "Ok."
											} else {
												return "lk."
											}
										}
										"nker" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"anker" {
													return "ank."
												}
												"inker" {
													return "ink."
												}
											}
										}
										"oker" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ooker" $rhymestr]} {
												if {[string match "snooker" $word]} {
													return "Uk."
												}
												return "uk."		;#	cooker, looker
											}
											return "@k."
										}
										"rker" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"arker" {
													return "Ak."
												}
												"erker" {
													return ":k."
												}
												"irker" {
													return ":k."
												}
												"urker" {
													return ":k."
												}
											}
										}
									}
									return "k."
								}
								"ler" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"aler" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ealer" $rhymestr]} {
												return "Il."
											} else {
												return "4l."
											}
										}
										"bler" {
											return "bl."
										}
										"dler" {
											return "dl"
										}
										"eler" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "eeler" $rhymestr]} {
												return "Il."
											} else {
												return ".l."
											}
										}
										"fler" {
											return "fl."
										}
										"gler" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ngler" $rhymestr]} {
												return "Ngl."
											} else {
												return "gl."
											}
										}
										"iler" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"ailer" {
													return "4l."
												}
												"oiler" {
													return "oil."
												}
											}
											return "ail."
										}
										"kler" {
											return "kl."
										}
										"ller" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"aller" {
													set wordlist1 [list marshaller singaller hospitaller teetotaller victualler]
													if {[WordMatchesAnyOfWords $word $wordlist1]} {
														return ".l."
													}
													return "Ol."			;#	caller
												}
												"eller" {
													set wordlist1 [list feller smeller repeller propeller impeller seller teller queller dweller]
													if {[WordMatchesAnyOfWords $word $wordlist1]} {
														return "el."
													}
													return ".l."		;#	traveller
												}
												"iller" {
													return "il."
												}
												"oller" {
													if {[string match "caroller" $word]} {
														return ".l."
													}
													return "@l."		;#	stroller
												}
												"uller" {
													return "ul."
												}
											}
										}
										"oler" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"aoler" {
													return "4l."
												}
												"ooler" {
													return "Ul."
												}
											}
											return "@l."
										}
										"rler" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"irler" -
												"urler" {
													return ":l."
												}
											}
										}
										"tler" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "stler" $rhymestr]} {
												return "sl."
											} else {
												return "tl."
											}
										}
										"uler" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "auler" $rhymestr]} {
												return "Ol."
											} else {
												return "Ul."
											}
										}
										"wler" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"awler" {
													return "Ol."
												}
												"owler" {
													return "aUl."
												}
											}
										}
										"zler" {
											return "zl."
										}
									}
									return "l."
								}
								"mer" {
									return "m."
								}
								"ner" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ener" {
											if {[string match "convener" $word]} {
												return "In."
											}
											return ".n."
										}
										"oner" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"ioner" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"sioner" {
															if {[string match "provisioner" $word]} {
																return "Z.n."
															} else {
																return "S.n."
															}
														}
														"tioner" {
															return "S.n."
														}
													}
													return ".n."
												}
											}
											switch -- $word {
												"goner" {
													return "on."
												}
												"postponer" {
													return "@n."
												}
											}
											return ".n."		;#	parishioner
										}
									}
									return "n."
								}
								"per" {
									return "p."
								}
								"rer" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"erer" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "uerer" $rhymestr]} {
												return ".r."
											}
											set wordlist1 [list cohere interferer reverer]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "i.r."
											}
											return ".r."
										}
										"urer" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ourer" $rhymestr]} {
												switch -- $word {
													"scourer" {
														return "aUr."
													}
													"pourer" {
														return "Or."
													}
												}
												return ".r."	;#	labourer
											}
											set wordlist1 [list insurer assurer abjurer]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "Or."
											}
											set wordlist1 [list curer durer]
											if {[WordEndsWithAnyOf $word $wordlist1]} {
												return "iOr."
											}
											return ".r."		;#	treasurer
										}
									}
								}
								"ser" {
									set wordlist1 [list marganser cleanser]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "z."
									}
									set wordlist1 [list grouser dowser answer promiser practiser mouser]
									set wordlist2 [list nser lser pser rser sser]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "s."
									}
									return "z."
								}
								"ter" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"eter" {
											if {[string match "deter" $word]} {
												return "it:"
											}
											set wordlist1 [list altimeter velocimeter peter]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "It."
											}
											return "it."		;#	diameter, parameter
										}
										"lter" {
											return "lt."
										}
										"nter" {
											return "nt."
										}
										"ster" {
											return "st."
										}
									}
									return "t."
								}
								"ver" {
									return "v."
								}
								"wer" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "swer" $rhymestr]} {
										return "s."
									}
								}
								"xer" {
									return "ks."
								}
								"yer" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ayer" {
											if {[string match "prayer" $word]} {
												return "E"
											}
											return "4i."		;#	slayer
										}
										"uyer" {
											return "ai."
										}
									}
								}
								"zer" {
									return "z."
								}
							}
						}
						return "."
					}
					"ir" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"air" {
									return "E"
								}
								"oir" {
									return "Ua"
								}
							}
							set wordlist1 [list kaffir menhir fakir amir emir]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "i."
							}
						}
						return "."
					}
					"or" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ior" {
									if {[string match "prior" $word]} {
										return "ai."
									}
									return "i."		;#	senior
								}
								"oor" {
									return "O"
								}
								"sor" {
									if {[string match "scissor" $word]} {
										return "z."
									}
									set wordlist2 [list nsor rsor ssor]
									if {[WordEndsWithAnyOf $word $wordlist2]} {
										return "s."
									}
									return "z."
								}
								"tor" {
									if {[string match "tor" $word]} {
										return "tO"
									}
									return "t."		;#	visitor
								}
								"uor" {
									return "."		;#	liquor
								}
							}
							set wordlist1 [list ambassador tudor rigor clangor anchor camphor phosphor author major]
							set wordlist2 [list lor mor nor por ror vor zor]
							if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
								return "."
							}
						}
						return "O"		;#	toreador
					}
					"rr" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"arr" {
									return "A"
								}
								"err" {
									return ":"
								}
								"irr" {
									return ":"
								}
								"urr" {
									return ":"
								}
							}
						}

					}
					"ur" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aur" {
									return "O"
								}
								"eur" {
									return ":"
								}
								"our" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "iour" $rhymestr]} {
										return "i."
									}
									set wordlist1 [list four pour tour tambour troubadour downpour outpour amour paramour your]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "O"
									}
									set wordlist1 [list dour velour]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "U."
									}
									return "aU."		;#	flour
								}
							}
						}
						if {[IsMonosyllabic $word ur] || [string match "demur" $word]} {
							return ":"
						}
						return "."		;#	femur
					}
				}
			}
		}
		"s" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"as" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"eas" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "oeas" $rhymestr]} {
										return "I.z"
									} else {
										switch -- $word {
											"whereas" {
												return "az"
											}
											"overseas" {
												return "Iz"
											}
											"pancreas" -
											"boreas" {
												return "i.s"
											}
										}
										return "Iz"		;#	peas
									}
								}
								"ias" {
									if {[string match "paterfamilias" $word]} {
										return "ias"
									}
									set wordlist1 [list bias lias ananias trias]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "ai.s"
									}
									return "i.s"		;#	alias
								}
							}
						}
						switch -- $word {
							"pyjamas" {
								return ".z"
							}
							"was" {
								return "oz"
							}
							"fracas" {
								return "a"
							}
						}
						set wordlist1 [list as has whenas]
						if {[WordMatchesAnyOfWords $word $wordlist1]} {
							return "az"
						}
						set wordlist2 [list abraxas eyas gas candlemas candlemas hallowmas sasafras mithras arras vas alas]
						if {[WordMatchesAnyOfWords $word $wordlist2]} {
							return "as"
						}
						set wordlist3 [list atlas bolas michaelmas christmas pampas mithras canvas judas midas]
						if {[WordMatchesAnyOfWords $word $wordlist3]} {
							return ".s"
						}
						return ".z"
					}
					"es" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ces" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"aces" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "aeces" $rhymestr]} {
												return "Isiz"
											} else {
												return "4siz"
											}
										}
										"eces" {
											if {[string match "faeces" $word]} {
												return "fISIz"
											}
										}
										"ices" {
											set wordlist1 [list appendices indices codices]
											set wordlist2 [list auspices]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "isIz"
											} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
												return "isiz"
											} else {			;#	normal plurals (should be trapped elsewhere)
												return "aisiz"
											}
										}
										"sces" {
											if {[string match "pisces" $word]} {
												return "paisIz"
											} elseif {[string match "fasces" $word]} {
												 return faSIz
											}
										}
										"yces" {
											return "isIz"	;#	calyces
										}
									}
									return "siz"	;#	(normal plural should be trapped elsewhere)
								}
								"des" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ades" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"iades" {
													return "i.dIz"
												}
												"yades" {
													return "i.dIz"
												}
											}
											if {[string match "hades" $word]} {
												return "h4dIz"
											}
											return "4dz"		;#	normal plural should be trapped elsewhere
										}
										"ides" {
											set wordlist [list eumenides leonides]
											if {[WordMatchesAnyOfWords $word $wordlist]} {
												return "idIz" 
											} else {
												return "aidz"
											}
										}
										"odes" {
											if {[string match "antipodes" $word]} {
												return ".diz"
											} else {
												return "aidz"	;#	normal plural should be trapped elsewhere
											}
										}
									}
								}
								"ees" {
									return "Iz"
								}
								"hes" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ches" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"aches" {
													switch -- $word {
														"apaches" {
															return "aCiz"
														}
														"attaches" {
															return aS4z"
														}
													}
													set wordlist1 [list caches taches moustaches gouaches]
													if {[WordMatchesAnyOfWords $word $wordlist1]} {
														return "aSiz"
													}
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"eaches" {
															return "ICiz"
														}
														"oaches" {
															return "@Ciz"
														}
													}
													return "4ks"		;#	toothaches
												}
												"iches" {
													switch -- $word {
														"niches" {
															return "ISiz"
														}
														"cliches" {
															return IS4z"
														}
														"sandwiches" {
															return ijis"
														}
													}
													return "iCiz"		;#	riches, ostriches
												}
												"oches" {
													return "oSiz"		;#	cloches
												}
												"tches" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"atches" {
															set rhymestr [IncludePreviousChar $word $k]
															if {[string match "watches" $rhymestr]} {
																return "oCiz"
															} else {
																return "aCiz"
															}
														}
														"etches" {
															return "eCiz"
														}
														"itches" {
															set rhymestr [IncludePreviousChar $word $k]
															if {[string match "aitches" $rhymestr]} {
																return "4Ciz"
															} else {
																return "iCiz"
															}
														}
														"otches" {
															return "oCiz"
														}
														"utches" {
															set rhymestr [IncludePreviousChar $word $k]
															if {[string match "autches" $rhymestr]} {
																return "OCiz"
															} else {
																return "uCiz"
															}
														}
													}
													return "Ciz"
												}
												"nches" -
												"lches " {
													return "Siz"
												}
												"uches" {
													return "Usiz"
												}
											}
											return "Ciz"		;#	batches
										}
										"shes" {
											if {[string match "shes" $word]} {
												return "SIz"
											} else {
												return "Siz"
											}
										}
										"thes" {
											return "7z"		;#	normal plurals, should be handled elsewhere
										}
									}
								}
								"ies" {
									switch -- $word {
										"caries" -
										"aries" {
											return "ErIz"
										}
									}
									return "iz"	;#	rabies species series (and normal plurals)
								}
								"les" {
									switch -- $word {
										"isoceles" -
										"mephistopheles" {
											return ".lIz"
										}
										"measles" {
											return "Iz.lz"
										}
									}
									return "lz"	;#	(normal plurals; should be trapped elsewhere)
								}
								"mes" {
									if {[string match "hermes" $word]} {
										return  "mIz"
									}
								}
								"oes" {
									if {[string match "does" $word]} {
										return "uz"				;#	ambiguous doe-does, or does-doesn't
									}
									return "@z"
								}
								"pes" {
									if {[string match "herpes" $word]} {
										return ":pIz"
									} else {
										return "ps"		;#	normal plurals, should be trapped elsewhere
									}
								}
								"res" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ares" $rhymestr]} {
										return "Ez"
									}
								}
								"ses" {
									switch -- $word {
										"mollases" -
										"glasses" {
											return "asiz"
										}
									}
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "sses" $rhymestr]} {
										return "siz"
									}
									set wordlist1 [list crises neuroses analyses]
									set wordlist2 [list theses psychoses]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "sIz"
									}												
								}
								"tes" {
									switch -- $word {
										"diabetes" {
											return ItIz"
										}
										"pyrites" {
											return "aitIz"
										}
										"litotes" {
											return "@tIz"
										}
										"cortes" {
											return "Otez"
										}
										"barytes" {
											return "aitIz"
										}
									}
									return "ts"		;#	normal plural should be trapped elsewhere
								}
								"xes" {
									return "sIz"		;#	ambiguity ax -> axes(aksiz), axis -> axes(aksIz)
								}
							}
						}
					}
					"is" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ais" {
									switch -- $word {
										"dais"	{
											return "4is"
										}
										"beaujolais" {
											return "4"
										}
									}
									return 4z"			;#	normal plural should be trapped elsewhere
								}
								"ois" {
									if {[string match "chamois" $word]} {
										retune "mi"
									}
									return "Ua"
								}
								"sis" {
									return "sis"
								}
								"tis" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "itis" $rhymestr]} {
										return "ait.s"
									} else {
										return "tis"
									}
								}
								"uis" {
									if {[string match "louis" $word]} {
										return Ui"
									}
								}
							}
						}
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "gris" $rhymestr]} {
							return "grI"
						}
						if {[string match "debris" $word]} {
							return "ri"
						}
						return "iz"	;#	normal plural, his, is
					}
					"os" {
						set wordlist1 [list cos reredos kudos logos bathos pathos ethos thermos cosmos tripos pharos chaos]
						set wordlist2 [list apropos]
						set wordlist3 [list rhinoceros asbestos]
						set wordlist4 [list taos]
						if {[WordMatchesAnyOfWords $word $wordlist1]} {
							return "os"
						} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
							return "@"
						} elseif {[WordMatchesAnyOfWords $word $wordlist3]} {
							return ".s"
						} elseif {[WordMatchesAnyOfWords $word $wordlist4]} {
							return "aUz"
						}
						return "@z"		;#	 normal plural
					}
					"ss" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ass" {
									if {[string match "bass" $word]} {
										return "4s"
									}
									set wordlist1 [list cutlass trespass canvass]
									set wordlist2 [list embarass]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return ".s"
									}
									return "as"			;#	glass
								}
								"ess" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ness" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"dness" {
													set rhymestr [IncludePreviousChar $word $k]
													incr k -1
													switch -- $rhymestr {
														"edness" {
															set rhymestr [IncludePreviousChar $word $k]
															incr k -1
															if {[string length $rhymestr] > 0} {
																switch -- $rhymestr {
																	"bedness" {
																		return "dn.s"
																	}
																	"cedness" {
																		return "stn.s"
																	}
																	"dedness" {
																		return "didn.s"
																	}
																	"fedness" {
																		return "ftn.s"
																	}
																	"gedness" {
																		if {[string match "agedness" $word]} {
																			return "jidn.s"
																		} else {
																			return "jdn.s"
																		}
																	}
																	"hedness" {
																		set rhymestr [IncludePreviousChar $word $k]
																		incr k -1
																		switch -- $rhymestr {
																			"chedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				if {[string match "tchedness" $rhymestr]} {
																					return "Cidn.s"
																				}
																			}
																			"shedness" {
																				return "Stn.s"
																			}
																		}
																	}
																	"iedness" {
																		set wordlist1 [list impliedness appliedness]
																		set wordlist2 [list fiedness]	;#	????
																		if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
																			return "aidn.s"
																		} else {
																			return "idn.s"
																		}
																	}
																	"kedness" {
																		if {[string match "nakedness" $word]} {
																			return "kidn.s"
																		}
																		return "ktn.s"
																	}
																	"ledness" {
																		set rhymestr [IncludePreviousChar $word $k]
																		if {[string match $rhymestr "bledness"]} {
																			return "b.ldn.s"
																		} else {
																			return "ldn.s"
																		}
																	}
																	"medness" {
																		 return "mdn.s"
																	}
																	"nedness" {
																		 return "ndn.s"
																	}
																	"pedness" {
																		return "ptn.s"
																	}
																	"redness" {
																		set rhymestr [IncludePreviousChar $word $k]
																		incr k -1
																		switch -- $rhymestr {
																			"aredness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				if {[string match "earedness" $rhymestr]} {
																					return "i.dn.s"
																				} else {
																					return "Adn.s"
																				}
																			}
																			"eredness" {
																				return ":dn.s"
																			}
																			"iredness" {
																				return "ai.dn.s"
																			}
																			"rredness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				switch -- $rhymestr {
																					"arredness" {
																						return "Adn.s"
																					}
																					"erredness" {
																						return ":dn.s"
																					}
																					"irredness" {
																						return ":dn.s"
																					}
																					"orredness" {
																						return "Odn.s"
																					}
																					"urredness" {
																						return ":dn.s"
																					}
																				}
																			}
																			"tredness" {
																				return "t.dn.s"
																			}
																			"uredness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				if {[string match "ouredness" $rhymestr]} {
																					return ".dn.s"
																				} else {
																					set wordlist1 [list assuredness insuredness]
																					if {[WordMatchesAnyOfWords $word $wordlist1]} {
																						return "Odn.s"
																					} else {
																						return ".dn.s"
																					}
																				}
																			}
																			"yredness" {
																				return "ai.dn.s"
																			}
																		}
																		return "redn.s"
																	}
																	"sedness" {
																		set rhymestr [IncludePreviousChar $word $k]
																		incr k -1
																		switch -- $rhymestr {
																			"asedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				incr k -1
																				switch -- $rhymestr {
																					"easedness" {
																						set wordlist [list pleasedness displeasedness]
																						if {[WordMatchesAnyOfWords $word $wordlist]} {
																							return "Izdn.s"
																						} else {
																							return "Istn.s"
																						}
																					}
																					"hasedness" {
																						return "4stn.s"
																					}
																					"iasedness" {
																						return "ai.stn.s"		;#	biasedness
																					}
																				}
																				return "4stn.s"
																			}
																			"isedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				incr k -1
																				switch -- $rhymestr {
																					"aisedness" {
																						return "4zdn.s"
																					}
																					"oisedness" {
																						return "oizdn.s"
																					}
																				}
																				return "aizdn.s"
																			}
																			"lsedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				if {[string match "ulsedness" $rhymestr]} {
																					return "ulstn.s"
																				}
																			}
																			"nsedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				switch -- $rhymestr {
																					"ensedness"  {
																						return "enstn.s"
																					}
																					"insedness" {
																						return "instn.s"
																					}
																				}
																			}
																			"osedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				incr k -1
																				switch -- $rhymestr {
																					"oosedness" {
																						return "Ustn.s"
																					}
																					"dosedness" {
																						return "@stn.s"
																					}
																				}
																				return "@zdn.s"
																			}
																			"psedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				incr k -1
																				switch -- $rhymestr {
																					"apsedness" {
																						return "apstn.s"
																					}
																					"ipsedness" {
																						return "ipstn.s"
																					}
																				}
																			}
																			"rsedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				incr k -1
																				switch -- $rhymestr {
																					"arsedness" {
																						set rhymestr [IncludePreviousChar $word $k]
																						switch -- $rhymestr {
																							earsedness {
																								return ":stn.s"
																							}
																							"oarsedness" {
																								return "Ostn.s"
																							}
																						}
																						return "Astn.s"
																					}
																					"ersedness" {
																						return ":stn.s"
																					}
																					"orsedness" {
																						return "Ostn.s"
																					}
																					"ursedness" {
																						set rhymestr [IncludePreviousChar $word $k]
																						if {[string match "oursed" $rhymestr]} {
																							return "Ostn.s"
																						} else {
																							return ":stn.s"
																						}
																					}
																				}
																			}
																			"ssedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				incr k -1
																				switch -- $rhymestr {
																					"assedness" {
																						return "astn.s"
																					}
																					"essedness" {
																						if {[string match "blessedness" $word]} {
																							return "idn.s"
																						}
																						return "estn.s"
																					}
																				}
																			}
																			"usedness" {
																				set rhymestr [IncludePreviousChar $word $k]
																				incr k -1
																				switch -- $rhymestr {
																					"ausedness" { 
																						return "Ozdn.s"
																					}
																					"ousedness" {
																						return "aUzdn.s"
																					}
																					"awsedness" {
																						return "Ozdn.s"
																					}
																					"owsedness" {
																						return "aUzdn.s"
																					}
																				}
																				return "iUzdn.s"
																			}
																			"ysedness" {
																				return "aizdn.s"
																			}
																		}
																	}
																	"tedness" {
																		set rhymestr [IncludePreviousChar $word $k]
																		switch -- $rhymestr {
																			"atedness" {
																				return "4tidn.s"
																			}
																			"ctedness" {
																				return "ktidn.s"
																			}
																			"ltedness" {
																				return "ltidn.s"
																			}
																			"ntedness" {
																				return "ntidn.s"
																			}
																			"stedness" {
																				return "stidn.s"
																			}
																			"ttedness" {
																				return "tidn.s"
																			}
																		}
																		return "tidn.s"

																	}
																	"vedness" {
																		return "vd"
																	}
																	"wedness" {
																		set rhymestr [IncludePreviousChar $word $k]
																		switch -- $rhymestr {
																			"awedness" {
																				return "Odn.s"
																			}
																			"ewedness" {
																				return "iUdn.s"
																			}
																			"owed" {
																				return "@dn.s"
																			}
																		}
																	}
																	"xedness" {
																		return "kstn.s"
																	}
																	"zedness" {
																		return "zdn.s"
																	}
																}
																return ".dn.s"
															}
														}
														"idness" {
															return "idn.s"
														}
														"rdness" {
															set rhymestr [IncludePreviousChar $word $k]
															if {[string match "ardness" $rhymestr]} {
																if {[string match "hardness" $word]} {
																	return "Adn.s"
																}
																return ".dn.s"		;#	backwardness
															}
														}
													}
												}
												"eness" {
													set rhymestr [IncludePreviousChar $word $k]
													incr k -1
													switch -- $rhymestr {
														"leness" {
															set rhymestr [IncludePreviousChar $word $k]
															incr k -1
															if {[string match "bleness" $rhymestr]} {
																set rhymestr [IncludePreviousChar $word $k]
																switch -- $rhymestr {
																	"ableness" {
																		return ".b.ln.s"
																	}
																	"ibleness" {
																		set wordlist2 [list cibleness dibleness gibleness libleness ribleness]
																		set wordlist2 [concat $wordlist2 sibleness xibleness]
																		if {[WordEndsWithAnyOf $word $wordlist2]} {
																			return "ib.ln.s"
																		}
																		return ".b.ln.s"
																	}
																	"obleness" {
																		return "@b.ln.s"
																	}
																}
																return "b.ln.s"
															}
														}
														"veness" {
															set rhymestr [IncludePreviousChar $word $k]
															if {[string match "iveness" $rhymestr]} {
																return "ivn.s"
															}
														}
													}
												}
												"hness" {
													incr k -1
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "ishness" $rhymestr]} {
														return "iSn.s"
													}
												}
												"iness" {
													return "in.s"
												}
												"lness" {
													incr k -1
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "fulness" $rhymestr]} {
														return "fuln.s"
													}
												}
												"sness" {
													set rhymestr [IncludePreviousChar $word $k]
													incr k -1
													switch -- $rhymestr {
														"ssness" {
															set rhymestr [IncludePreviousChar $word $k]
															if {[string match "essness" $rhymestr]} {
																return ".sn.s"
															}
														}
														"usness" {
															set rhymestr [IncludePreviousChar $word $k]
															incr k -1
															if {[string match "ousness" $rhymestr]} {
																set rhymestr [IncludePreviousChar $word $k]
																incr k -1
																switch -- $rhymestr {
																	"eousness" {
																		set rhymestr [IncludePreviousChar $word $k]
																		if {[string match "geousness" $rhymestr]} {
																			return "j.sn.s"
																		} else {
																			return "i.sn.s"
																		}
																	}
																	"iousness" {
																		set rhymestr [IncludePreviousChar $word $k]
																		switch -- $rhymestr {
																			"giousness" {
																				return "j.sn.s"
																			}
																			"ciousness" -
																			"tiousness" -
																			"xiousness" {
																				return "S.sn.s"
																			}
																		}
																		return "i.sn.s"
																	}
																	"lousness" {
																		return "l.sn.s"
																	}
																}
																return ".sn.s"
															}
														}
													}
												}
												"tness" {
													return "tn.s"
												}
											}
											if {[IsMonosyllabic $word "ness"]} {
												return "nes"
											}
											return "n.s"
										}
									}
									if {[string match "cypress" $word]} {
										return ".s"
									}
									set wordlist1 [list	titaness sultaness deaconess pythoness marchioness demoness baroness patroness governess]
									set wordlist1 [concat $wordlist1 voltaress caress procuress duress hermitess gauntess countess viscountess priestess]
									set wordlist1 [concat $wordlist1 hostess tress stress distress]
									set wordlist2 [list cress dress eress gress eiress oress press sess uess wess]
									if {[IsMonosyllabic $word ess] || [WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "es"
									}
									return ".s"
								}
								"iss" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "eiss" $rhymestr]} {
										return "ais"
									} else {
										return "is"
									}
								}
								"oss" {
									return "os"
								}
								"uss" {
									return "us"
								}
								"yss" {
									return "is"
								}
							}
						}
						return "s"
					}
					"us" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aus" {
									if {[string match "claus" $word]} {
										return "Oz"
									} 
									return "aUz"
								}
								"ius" {
									return "i.s"
								}
								"ous" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"eous" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"ceous" {
													return "S.s"
												}
												"geous" {
													return "j.s"
												}
												"teous" {
													incr k -1
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "ghteous" $rhymestr]} {
														return "C.s"
													}
												}
											}
											return "i.s"
										}
										"gous" {
											return "j.s"
										}
										"hous" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "phous" $rhymestr]} {
												return "f.s"
											}
										}
										"ious" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"gious" {
													return "j.s"
												}
												"cious" -
												"tious" -
												"xious" {
													return "S.s"
												}
											}
											return "i.s"
										}
										"lous" {
											return "l.s"
										}
										"uous" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "quous" $rhymestr]} {
												return "U.S"
											} else {
												return "iU.s"
											}
										}
									}
									switch -- $word {
										"couscous" {
											return "Us"
										}
										"rendezvous" {
											return "U"
										}
									}
									return ".s"
								}
							}
						}
						switch -- $word {
							"cuscus" {
								return "Us"
							}
							"bus" {
								return "us"
							}
							"us" {
								return "uz"
							}
						} 
						return ".s"
					}
					"ys" {
						if {[string match "ichthys" $word]} {
							return "is"				;#	all others shopuld be dealt with as plurals
						}
					}
				}
			}
		}
		"t" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"at" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aat" {
									return "At"
								}
								"eat" {
									switch -- $word {
										"hereat" {
											return "i.rat"
										}
										"great" {
											return "4t"
										}
										"caveat" {
											return ""iat"
										}
									}
									if {[WordMatchesAnyOfWords $word [list whereat thereat]]} {
										return "Erat"
									} elseif {[WordMatchesAnyOfWords $word [list threat sweat]]} {
										return "et"
									}
									return "It"			;#	"seat"
								}
								"oat" {
									return "@t"
								}
							}
						}
						set wordlist1 [list entrechat eclat]
						set wordlist2 [list what squat]
						if {[WordMatchesAnyOfWords $word $wordlist1]} {
							return "a"
						} elseif {[WordMatchesAnyOfWords $word $wordlist2]} {
							return "ot"
						} elseif {[string match "nougat" $word]} {
							return "it"		;#	Northern pronunciation
						}
						return "at"
					}
					"bt" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ebt" {
									return "et"
								}
								"ubt" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "oubt" $rhymestr]} {
										return "aUt"
									}
								}
							}
						}
					}
					"ct" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"act" {
									return "akt"
								}
								"ect" {
									return "ekt"
								}
								"ict" {
									return "ikt"
								}
								"nct" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"inct" {
											return "iNkt"
										}
										"unct" {
											return "uNkt"
										}
									}
								}
								"oct" {
									return "okt"
								}
								"uct" {
									return "ukt"
								}
							}
						}
					}
					"dt" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string match "ldt" $rhymestr]} {
							set rhymestr [IncludePreviousChar $word $k]
							if {[string match "eldt" $rhymestr]} {
								return "elt"
							}
						}
					}
					"et" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "eet" $rhymestr]} {
							return "It"
						}
						if {[IsMonosyllabic $word et]} {
							return "et"
						}
						set wordlist [list dget tchet phet ullet cket ommit mpet ppet interpet sset quet]
						if {[WordEndsWithAnyOf $word $wordlist]} {
							return "it"
						}
						set wordlist [list set]
						if {[WordEndsWithAnyOf $word $wordlist]} {
							return "set"
						}
						set wordlist [list abet alphabet quodlibet tibet avocet beget epithet spinet internet epaulet outlet sublet]
						set wordlist [concat $wordlist clarinet martinet baronet coronet minaret spinneret outset regret]
						set wordlist [concat $wordlist duet quartet quintet sextet septet octet nonet decet motet minuet briquet coquet chevet revet]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "et"
						}
						set wordlist [list gibbet gobbet nugget target pellet mallet fillet comet gannet bonnet linnet sonnet cornet garnet hornet]
						set wordlist [concat $wordlist poet carpet ferret cruet suet banquet velvet]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "it"
						}
						set wordlist [list sorbet bidet crotchet trebuchet chalet valet ballet flageolet cabriolet gourmet cabaret douvet bouquet croquet]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "4"
						}
						return ".t"		;#	banquet turret
					}
					"ft" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aft" {
									if {[string match "waft" $word]} {
										return "oft"
									}
									return "aft"
								}
								"eft" {
									return "eft"
								}
								"ift" {
									return "ift"
								}
								"oft" {
									return "oft"
								}
								"uft" {
									return "uft"
								}
							}
						}
					}
					"ht" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"cht" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "acht" $rhymestr]} {
										return "ot"
									}
								}
								"ght" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ight" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"aight" {
													return "4t"
												}
												"eight" {
													set wordlist [list height sleight]
													if {[WordMatchesAnyOfWords $word $wordlist]} {
														return "ait"
													}
													return "4t"			;#	freight, eight
												}
											}
											return "ait"
										}
										"ught" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"aught" {
													set wordlist [list draught]
													if {[WordEndsWithAnyOf $word $wordlist]} {
														return "aft"
													}
													return "Ot"
												}
												"ought" {
													if {[string match "drought" $word]} {													
														return "aUt"
													} else {
														return "Ot"
													}
												}
											}
										}
									}
								}
							}
						}
					}
					"it" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ait" {
									return "4t"
								}
								"eit" {
									switch -- $word {
										"forfeit" {
											return "it"
										}
										"fahrenheit" {
											return "ait"
										}
									}
									return "It"
								}
								"oit" {
									return "oit"
								}
								"uit" {
									set wordlist [list conduit jesuit]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "Uit"
									}
									set wordlist1 [list suit lawsuit]
									set wordlist2 [list ruit]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "Ut"
									}
									if {[string match "pursuit" $word]} {
										return "iUt"
									}
								}
							}
						}
						return "it"				;#	quit
					}
					"lt" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"alt" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ealt" $rhymestr]} {
										return "elt"
									} else {
										set wordlist1 [list cobalt halt exalt]
										set wordlist2 [list malt salt]
										if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
											return "olt"
										}
										return "alt"
									}
								}
								"elt" {
									return "elt"
								}
								"ilt" {
									return "ilt"
								}
								"olt" {
									return "olt"
								}
								"ult" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"ault" {
											return "olt"
										}
										"oult" {
											return "aUlt"
										}
									}
									return "ult"
								}
							}
						}
					}
					"nt" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ant" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"cant" {
											if {[string match "cant" $word]} {	;#	can't
												return "kAnt"
											}
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "icant" $rhymestr]} {
												return "ik.nt"
											} else {
												set wordlist [list decant recant scant descant]
												if {[WordMatchesAnyOfWords $word $wordlist]
													return "kant"
												} else {
													return "k.nt"
												}
											}
										}
										"eant" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "geant" $rhymestr]} {
												return "j.nt"
											} else {
												return "i.nt"
											}
										}
										"tant" {
											return "t.nt"
										}
									}
									switch -- $word {
										"want" {
											return "ont"
										}
										"cant" {		;#	ambiguous, gone for "can't"
											return "Ant"
										}
									}
									if {[IsMonosyllabic $word ant]} {
										return "ant"
									}
									set wordlist1 [list decant recant commandant plainchant enchant disenchant sycophant gallivant]
									set wordlist2 [list scant plant slant]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "ant"
									}
									set wordlist1 [list penchant couchant courant passant]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "O"			;#	sort of!!
									}
									return ".nt"		;#	"relevant"
								}
								"dnt" {
									return "d.nt"	;#	wouldn't
								}
								"ent" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"cent" {
											set wordlist1 [list scent ascent descent]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "sent"
											}
											return "s.nt"
										}
										"dent" {
											if {[string match $word "dent"]} {
												return "dent"
											}
											return "d.nt"		;#	"rodent"
										}
										"gent" {
											return "j.nt"
										}
										"ient" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"cient" -
												"tient" {
													return "S.nt"
												}
											}
											return "i.nt"
										}
										"ment" {
											if {[string match "rapprochement" $word]} {
												return "mO"
											}
											set wordlist1 [list dement cement lament augment comment foment ferment torment]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "ment"
											}
											return "m.nt"		;#	"basement"
										}
										"nent" {
											return "n.nt"
										}
										"pent" {
											if {[string match "serpent" $word]} {
												return "p.nt"
											}
											return "pent"
										}
										"sent" {
											set wordlist [list represent]
											if {[WordEndsWithAnyOf $word $wordlist]} {
												return "zent"
											}
											set wordlist1 [list consent]
											set wordlist2 [list ssent]
											if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
												return "sent"
											}
											return "s.nt"
										}
										"tent" {

											set wordlist1 [list intent extent]
											set wordlist2 [list content]
											if {[IsMonosyllabic $word tent] || [WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
												return "tent"
											}
											return "t.nt"
										}
										"uent" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"luent" {
													return "lU.nt"
												}
												"ruent" {
													return "rU.nt"
												}
											}
											return "iU.nt"
										}
										"vent" {
											set wordlist1 [list event prevent invent circumvent]
											if {[IsMonosyllabic $word vent] || [WordMatchesAnyOfWords $word $wordlist1]} {
												return "vent"
											} else {
												return "v.nt"
											}
										}
									}
									set wordlist1 [list ascent descent]
									if {[IsMonosyllabic $word ent] || [WordMatchesAnyOfWords $word $wordlist1]} {
										return "ent"
									}
									return ".nt"
								}
								"int" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"aint" -
										"eint" {
											return "4nt"
										}
										"cint" {
											return "sint"
										}
										"oint" {
											return "oint"
										}
									}
									if {[string match "pint" $word]} {
										return "aint"
									}
									return "int"
								}
								"ont" {
									if {[string match "dont" $word]} {
										return "@nt"
									}
									if {[WordEndsWithAnyOf $word [list front]]} {
										return "unt"
									}
									return "ont"
								}
								"rnt" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"arnt" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "earnt" $rhymestr]} {
												return ":nt"
											}
										}
										"urnt" {
											return ":nt"
										}
									}
								}
								"unt" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"aunt" {
											if {[string match "aunt" $word]} {
												return "ant"
											} else {
												return "Ont"
											}
										}
										"ount" {
											return "aUnt"
										}
									}
									return "unt"
								}
							}
						}
					}
					"ot" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"iot" {
									return "i.t"
								}
								"oot" {
									set wordlist1 [list soot]
									set wordlist2 [list foot]
									if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
										return "ut"
									}
									return "Ut"
								}
							}
						}
						set wordlist [list mot haricot argot huguenot depot tarot pierrot]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "@"
						}
						set wordlist1 [list ergot forgot ocelot helot despot tosspot ot]			;#	'ot
						set wordlist2 [list scot dot shot glot llot plot mot not trot sot tot quot]
						if {[IsMonosyllabic $word ot] || [WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
							return "ot"
						}
						return ".t"
					}
					"pt" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"apt" {
									return "apt"
								}
								"ept" {
									return "ept"
								}
								"ipt" {
									return "ipt"
								}
								"mpt" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"empt" {
											return "empt"
										}
										"ompt" {
											return "ompt"
										}
									}
								}
								"opt" {
									return "opt"
								}
								"upt" {
									return "upt"
								}
							}
						}
					}
					"rt" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"art" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"eart" {
											return "At"
										}
										"uart" {
											if {[string match "stuart" $word]} {
												return "U.t"
											}
											return "UOt"		;#	quart
										}
										"wart" {
											if {[string match "stalwart" $word]} {
												return ".t"
											}
											return "Ot"		;#	wart
										}
									}
									return "At"			;#	tart
								}
								"ert" {
									return ":t"
								}
								"irt" {
									return ":t"
								}
								"ort" {
									if {[string match "rapport" $word]} {
										return "O"
									}
									set wordlist [list comfort wort]
									if {[WordEndsWithAnyOf $word $wordlist]} {
										return ".t"
									}
									return "Ot"
								}
								"urt" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ourt" $rhymestr]} {
										return "Ot"
									} else {
										return ":t"
									}
								}
							}
						}
					}
					"st" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ast" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"east" {
											if {[WordEndsWithAnyOf $word [list breast]]} {
												return "est"
											}
											return "Ist"
										}
										"oast" {
											return "@st"
										}
									}
									return "ast"
								}
								"est" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "aest" $rhymestr]} {
										return "Ist"
									} else {
										if {[IsMonosyllabic $word est]} {
											return "est"
										}
										set wordlist2 [list dest thest nest tempest forest harvest]
										if {[WordEndsWithAnyOf $word $wordlist2]} {
											return "ist"
										} else {
											return "est"		;#	request
										}
									}
								}
								"ist" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"aist" {
											switch -- $word {
												"lamaist" {
													return ".ist"
												}
												"waist" {
													return "4st"
												}
											}
											return "4ist"	;#	archaist	(not univerally true)
										}
										"cist" {
											return "sist"
										}
										"eist" {
											if {[string match "deist" $word]} {
												return "4ist"
											}
											if {[WordEndsWithAnyOf $word [list geist]]} {
												return "aist"
											}
											if {[WordEndsWithAnyOf $word [list theist]]} {
												return "Iist"
											}
										}
										"gist" {
											return "jist"
										}
										"list" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"alist" {
													set rhymestr [IncludePreviousChar $word $k]
													incr k -1
													switch -- $rhymestr {
														"ealist" -
														"ialist" {
															set rhymestr [IncludePreviousChar $word $k]
															switch -- $rhymestr {
																"cialist" -
																"tialist" {
																	return "S.list"
																}
															}
															return "i.list"
														}
														"ualist" {
															return "iU.list"
														}
													}
													return ".list"
												}
												"elist" {
													return ".list"
												}
												"llist" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"allist" {
															return ".list"
														}
														"ellist" {
															if {[WordEndsWithAnyOf $word [list cellist]]} {
																return "ellist"
															} else {
																return ".list"
															}
														}
													}
												}
											}
										}
										"mist" {
											return "mist"
										}
										"nist" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"anist" {
													return ".nist"
												}
												"enist" {
													if {[string match "plenist" $word]} {
														return "enist"
													}
													return ".nist"
												}
												"inist" {
													return ".nist"
												}
												"onist" {
													set rhymestr [IncludePreviousChar $word $k]
													incr k -1
													switch -- $rhymestr {
														"ionist" {
															set rhymestr [IncludePreviousChar $word $k]
															switch -- $rhymestr {
																"cionist" -
																"sionist" -
																"tionist" {
																	return "S.nist"
																}
																"gionist" {
																	return "j.nist"
																}
															}
															return "i.nist"
														}
														"oonist" {
															return "Unist"
														}
													}
													if {[string match "monist" $word]} {
														return "@nist"
													}
													return ".nist"
												}
												"ynist" {
													return "inist"
												}
											}
											return "nist"
										}
										"oist" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "aoist" $rhymestr ]} {
												return "aUist"
											} else {
												set wordlist1 [list egoist banjoist soloist shintoist]
												if {[WordMatchesAnyOfWords $word $wordlist1]} {
													return "@ist"
												} else {
													return "oist"
												}
											}
										}
										"tist" {
											return "tist"
										}
									}
									if {[string match "christ" $word]} {
										return "aist"
									}
									return "ist"
								}
								"nst" {
									incr k -1
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ainst" $rhymestr]} {
										return "Enst"
									}
								}
								"ost" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "oost" $rhymestr]} {
										return "Ust" 
									} else {
										set wordlist [list ripost impost compost]
										if {[WordMatchesAnyOfWords $word $wordlist]} {
											return "ost"
										}
										set wordlist [list host most post]
										if {[WordEndsWithAnyOf $word $wordlist]} {
											return "@st"
										}
										return "ost"
									}
								}
								"rst" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"erst" -
										"irst" -
										"orst" -
										"urst" {
											return ":st"
										}
									}
								}
								"ust" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "aust" $rhymestr]} {
										return "Ost"
									} else {
										return "ust"
									}
								}
								"yst" {
									return "ist"
								}
							}
						}
					}
					"tt" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"att" {
									if {[WordEndsWithAnyOf $word [list watt]]} {
										return "ot"
									} else {
										return "at"
									}
								}
								"ett" {
									return "et"
								}
								"itt" {
									return "it"
								}
								"ott" {
									return "ot"
								}
								"utt" {
									return "ut"
								}
							}
						}
					}
					"ut" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"aut" {
									return "aUt"
								}
								"out" {
									set wordlist [list ragout passepartout]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "U"
									} else {
										return "aUt"
									}
								}
							}
							if {[string match "debut" $word]} {
								return "iU"
							}
							set wordlist [list halibut gamut]
							if {[WordMatchesAnyOfWords $word $wordlist]} {
								return ".t"
							}
						}
						return "ut"
					}
					"wt" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "ewt" $rhymestr]} {
							return "iUt"
						}
					}
					"xt" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ext" {
									return "ekst"
								}
								"ixt" {
									return "ikst"
								}
							}
							return "kst"
						}
					}
				}
			}
		}
		"u" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"au" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "eau" $rhymestr]} {
							return "@"
						} else {
							return "aU"
						}
					}
					"eu" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "ieu" $rhymestr]} {
							return "iU"
						}
					}
				}
			}
			return "U"
		}
		"v" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			switch -- $rhymestr {
				"av" {
					return "av"
				}
				"ev" {
					return "ev"
				}
				"iv" {
					return "iv"
				}
			}
			return "v"
		}
		"w" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"aw" {
						return "O"
					}
					"ew" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "iew" $rhymestr]} {
							set wordlist1 [list blew slew]
							set wordlist2 [list rew]
							if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
								return "U"
							}
							return "iU"
						} else {
							return "iU"
						}
					}
					"ow" {
						set wordlist1 [list cow endow how dhow somehow plow now brow prow kowtow]
						set wordlist2 [list chow vow wow]
						if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
							return "aU"
						}
						return "@"
					}
				}
			}
		} 
		"x" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ax" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "oax" $rhymestr]} {
							return "@ks"
						} else {
							return "aks"
						}
					}
					"ex" {
						return "eks"
					}
					"ix" {
						return "iks"
					}
					"nx" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"anx" {
									return "aNks"
								}
								"inx" {
									return "iNks"
								}
								"unx" {
									return "uNks"
								}
								"ynx" {
									return "iNks"
								}
							}
						}
					}
					"ox" {
						return "oks"
					}
					"ux" {
						return "uks"
					}
					"yx" {
						return "iks"
					}
				}
			}
			return "ks"
		} 
		"y" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ay" {
						set wordlist [list monday tuesday wednesday thursday friday saturday sunday]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "i"
						} else {
							return "4"
						}
					}
					"by" {
						set wordlist [list by lullaby hushaby]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "ai"
						} else {
							return "i"
						}
					}
					"cy" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"acy" {
									set wordlist [list lacy racy]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "4si"
									} else {
										return ".si"
									}
								}
								"ecy" {
									if {[string match "fleecy" $word]} {
										return "Isi"
									}
									return ".si"
								}
								"ncy" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ancy" {
											set wordlist1 [list fancy chancy]
											if {[WordMatchesAnyOfWords $word $wordlist1]} {
												return "ansi"
											}
											return ".nsi"
										}
										"ency" {
											incr k -1
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ciency" $rhymestr]} {
												return "S.nsi"
											} else {
												return ".nsi"
											}
										}
									}
								}
								"ocy" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "iocy" $rhymestr]} {
										return "i.si"
									}
								}
							}
						}
						return "si"
					}
					"dy" {
						return "di"
					}
					"ey" {
						set wordlist [list whey they survey grey prey osprey convey survey wey]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "4"
						}
						set wordlist [list key ley]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "I"
						}
						return "i"
					}
					"fy" {
						set rhymestr [IncludePreviousChar $word $k]
						if {[string match "ufy" $rhymestr]} {
							return "ufi"
						} else {
							set wordlist [list leafy beefy]
							if {[WordMatchesAnyOfWords $word $wordlist]} {
								return "Ifi"
							}
							set wordlist [list efy ify isfy]
							if {[WordEndsWithAnyOf $word $wordlist]} {
								return "fai"
							}
							return "fi"
						}
					}
					"gy" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ggy" {
									return "gi"
								}
								"lgy" {
									return "lji"
								}
								"ngy" {
									if {[string match "dingy" $word]} {
										return "iNgi"
									}
									set wordlist [list mangy stingy spongy]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "ji"
									}
									return "Ni"
								}
								"ogy" {
									set wordlist [list bogy fogy]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "@gi"
									}
									return ".ji"
								}
							}
						}
						return "ji"
					}
					"hy" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"chy" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "tchy" $rhymestr]} {
										return "Ci"
									} else {
										set wordlist [list starchy churchy]
										if {[WordMatchesAnyOfWords $word $wordlist]} {
											return "Ci"
										}
										set wordlist [list nchy]
										if {[WordEndsWithAnyOf $word $wordlist]} {
											return "Si"		;#	 punchy
										}
										set wordlist [list tchy eachy oachy]
										if {[WordEndsWithAnyOf $word $wordlist]} {
											return "Ci"		;#	 punchy
										}
										set wordlist [list achy echy ochy archy]
										if {[WordEndsWithAnyOf $word $wordlist]} {
											return "ki"
										}
									}
								}
								"phy" {
									set wordlist [list atrophy]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "fai"
									}
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "aphy" $rhymestr]} {
										return ".fi"
									} else {
										return "fi"
									}
								}
								"shy" {
									if {[string match $word "shy"]} {
										return "Sai"
									} else {
										return "Si"
									}
								}
								"thy" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "rthy" $rhymestr]} {
										return "7i"
									}
									switch -- $word {
										"smithy" {
											return "7i"
										}
										"thy" {
											return "7ai"
										}
									}
									return "Ti"
								}
								"why" {
									return "Uai"
								}

							}
						}
					}
					"ky" {
						if {[string match "sky" $word]} {
							return "kai"
						} else {
							return "ki"
						}
					}
					"ly" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"bly" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"ably" {
											return ".bli"
										}
										"ibly" {
											return "ibli"
										}
									}
									return "bli"
								}
								"dly" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"edly" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"iedly" {
													return "idli"
												}
												"nedly" {
													set rhymestr [IncludePreviousChar $word $k]
													if {[string match "inedly" $rhymestr]} {
														if {[string match "refinedly" $word]} {
															return "aindli"
														} else {
															return "indli"		;#	determinedly
														}
													} else {
														return "n.dli"
													}
												}
												"sedly" {
													if {[WordMatchesAnyOfWords $word [list confusedly composedly]]} {
														return "zdli"
													}
													if {[WordEndsWithAnyOf $word [list ssedly]]} {
														return "stli"
													}
													return "z.dli"
												}
											}
											set wordlist [list avowedly] 
											if {[WordMatchesAnyOfWords $word $wordlist]} {
												return "aUdli"
											}
											if {[string match "forcedly" $word]} {
												return "s.dli"
											}
											set wordlist [list bedly gnedly zedly]
											if {[WordEndsWithAnyOf $word $wordlist]} {
												return "dli"
											}
											set wordlist [list tchedly]
											if {[WordEndsWithAnyOf $word $wordlist]} {
												return "Cidli"
											}
											set wordlist [list cedly chedly]
											if {[WordEndsWithAnyOf $word $wordlist]} {
												return "tli"
											}
											set wordlist [list dedly kedly gedly tedly]
											if {[WordEndsWithAnyOf $word $wordlist]} {
												return "idli"
											}
											set wordlist [list eedly]
											if {[WordEndsWithAnyOf $word $wordlist]} {
												return "Idli"
											}
											return ".dli"
										}
										"idly" {
											set wordlist1 [list markedly]
											set wordlist2 [list chedly medly]
											if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
												return ".dli"
											}
											return "idli"			;#	nakedly
										}
									}
								}
								"gly" {
									incr k -1
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ingly" $rhymestr]} {
										return "iNli"
									}
								}
								"hly" {
									incr k -1
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "ishly" $rhymestr]} {
										return "iSli"
									}
								}
								"ily" {
									return "ili"
								}
								"lly" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ally" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"ially" {
													set rhymestr [IncludePreviousChar $word $k]
													incr k -1
													switch -- $rhymestr {
														"cially" {
															return "S.li"
														}
														"tially" {
															set rhymestr [IncludePreviousChar $word $k]
															if {[string match "stially" $rhymestr]} {
																return "i.li"
															} else {
																return "S.li"
															}
														}
													}
													return "i.li"
												}
												"nally" {
													set rhymestr [IncludePreviousChar $word $k]
													incr k -1
													if {[string match "onally" $rhymestr]} {
														incr k -1
														set rhymestr [IncludePreviousChar $word $k]
														incr k -1
														switch -- $rhymestr {
															"sionally" {
																return "S.n.li"
															}
															"tionally" {
																set rhymestr [IncludePreviousChar $word $k]
																if {[string match "stionally" $rhymestr]} {
																	return "sti.n.li"
																} else {
																	return "S.n.li"
																}
															}
														}
														return ".n.li"		;#	-onally
													}
												}
												"rally" {
													if {[string match $word "rally"]} {
														return "rali"
													} else {
														return "r.li"
													}
												}
											}
											if {[string match $word "ally"]} {
												return "alai"
											}
											return ".li"
										}
										"elly" {
											return "eli"
										}
										"illy" {
											return "ili"
										}
										"olly" {
											return "oli"
										}
										"ully" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "fully" $rhymestr]} {
												return "fuli"
											} else {
												return "uli"
											}
										}
									}
								}
								"rly" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"arly" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "early" $rhymestr]} {
												set wordlist1 [list early pearly]
												if {[WordMatchesAnyOfWords $word $wordlist1]} {
													return ":li"
												}
												return "i.li"				;#	yearly, linearly
											}
											set wordlist [list marly gnarly snarly]
											if {[WordMatchesAnyOfWords $word $wordlist]} {
												return "Ali"
											}
											return ".li"
										}
										"erly" {
											incr k -1
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "dierly" $rhymestr]} {
												return "j.li"
											} else {
												return ":li"
											}
										}
										"irly" {
											return ":li"
										}
										"urly" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "ourly" $rhymestr]} {
												switch -- $word {
													"dourly" {
														return "U.li"
													}
													"neighbourly" {
														return ".li"
													}
												}
												return "aU.li"			;#	hourly
											}
											return ":li"
										}
									}
								}
								"sly" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ssly" {
											incr k -1
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"lessly" {
													return ".sli"
												}
												"ressly" {
													return "esli"
												}
												"missly" {
													return "isli"
												}
												"rossly" {
													return "@sli"
												}
											}
											return "sli"
										}
										"usly" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											if {[string match "ously" $rhymestr]} {
												set rhymestr [IncludePreviousChar $word $k]
												incr k -1
												switch -- $rhymestr {
													"eously" {
														set rhymestr [IncludePreviousChar $word $k]
														switch -- $rhymestr {
															"geously" {
																return "j.sli"
															}
															"hteously" {
																return "C.sli"
															}
														}
														return "i.sli"
													}
													"iously" {
														set rhymestr [IncludePreviousChar $word $k]
														switch -- $rhymestr {
															"ciously" -
															"tiously" {
																return "S.sli"
															}
															"giously" {
																return "j.sli"
															}
														}
														return "i.sli"
													}
												}
												return ".sli"	;#	-ously
											}
										}
									}
									if {[string match "sly" $word]} {
										return "slai"
									}
									return "zli"
								}
								"tly" {
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									switch -- $rhymestr {
										"ctly" {
											set rhymestr [IncludePreviousChar $word $k]
											switch -- $rhymestr {
												"actly" {
													return "aktli"
												}
												"ectly" {
													return "ektli"
												}
												"nctly" {
													return "nktli"
												}
											}
										}
										"ftly" {
											return "ftli"
										}
										"ntly" {
											set rhymestr [IncludePreviousChar $word $k]
											incr k -1
											switch -- $rhymestr {
												"antly" {
													return ".ntli"
												}
												"ently" {
													return ".ntli"
												}
												"intly" {
													set rhymestr [IncludePreviousChar $word $k]
													switch -- $rhymestr {
														"aintly" {
															return "4ntli"
														}
														"ointly" {
															return "ointli"
														}
													}
												}
											}
										}
										"xtly" {
											set rhymestr [IncludePreviousChar $word $k]
											if {[string match "extly" $rhymestr]} {
												return "ekstli"
											}
										}
									}
								}
								"yly" {
									return "ili"
								}
							}
						}
						set wordlist [list fly gadfly]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "flai"
						}
						return "li"
					}
					"my" {
						if {[string match "my" $word]} {
							return "mai"
						}
						return "mi"
					}
					"ny" {
						return "ni"
					}
					"oy" {
						return "oi"
					}
					"py" {
						set wordlist [list spy occupy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "pai"
						}
						return "pi"
					}
					"ry" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"ary" {
									set wordlist [list canary flary glary vary]
									if {[WordMatchesAnyOfWords $word $wordlist]} {
										return "Eri"
									}
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									if {[WordEndsWithAnyOf $word [list eary]]} {
										return "i.ri"
									}
									set rhymestr [IncludePreviousChar $word $k]
									incr k -1
									if {[WordEndsWithAnyOf $word [list ciary]]} {
										return "S.ri"
									}
									incr k -1
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"sionary" -
										"tionary" {
											return "S.n.ri"
										}
									}
									return ".ri"
								}
								"ory" {
									set rhymestr [IncludePreviousChar $word $k]
									if {[string match "tory" $rhymestr]} {
										if {[string match "tory" $word]} {
											return "tOri"
										}
										return "t.ri"
									}
									if {[WordEndsWithAnyOf $word [list glory]]} {
										return "Ori"
									}
									return ".ri"
								}
								"try" {
									set rhymestr [IncludePreviousChar $word $k]
									switch -- $rhymestr {
										"atry" -
										"etry" {
											return ".tri"
										}
									}
									return "tri"
								}
							}
						}
						return "ri"
					}
					"sy" {
						set wordlist [list easy uneasy queasy cheesy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "Izi"
						}
						set wordlist [list daisy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "4zi"
						}
						set wordlist [list noisy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "oizi"
						}
						set wordlist [list nosy posy rosy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "@zi"
						}
						set wordlist [list busy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "izi"
						}

						set wordlist [list newsy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "iUzi"
						}
						set wordlist [list drowsy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "aUzi"
						}
						set wordlist [list malagasy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "asi"
						}
						set wordlist [list mousy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "aUsi"
						}
						set wordlist [list prophesy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return "isai"
						}
						set wordlist [list argosy leprosy embassy christmassy jealousy]
						if {[WordMatchesAnyOfWords $word $wordlist]} {
							return ".si"
						}
						if {[WordEndsWithAnyOf $word [list easy]]} {
							return "Isi"
						}
						if {[WordEndsWithAnyOf $word [list asy esy]]} {
							return "isi"
						}
						if {[WordEndsWithAnyOf $word [list isy]]} {
							return "isi"
						}
						if {[WordEndsWithAnyOf $word [list imsy]]} {
							return "imsi"
						}
						if {[WordEndsWithAnyOf $word [list umsy]]} {
							return "umsi"
						}
						if {[WordEndsWithAnyOf $word [list ansy]]} {
							return "anzi"
						}
						if {[WordEndsWithAnyOf $word [list epsy]]} {
							return "epsi"
						}
						if {[WordEndsWithAnyOf $word [list ipsy]]} {
							return "ipsi"
						}
						if {[WordEndsWithAnyOf $word [list opsy]]} {
							return "opsi"
						}
						if {[WordEndsWithAnyOf $word [list orsy]]} {
							return "Osi"
						}
						if {[WordEndsWithAnyOf $word [list ursy]]} {
							return ":si"
						}
						if {[WordEndsWithAnyOf $word [list assy]]} {
							return "asi"
						}
						if {[WordEndsWithAnyOf $word [list essy]]} {
							return "esi"
						}
						if {[WordEndsWithAnyOf $word [list ossy]]} {
							return "osi"
						}
						if {[WordEndsWithAnyOf $word [list ussy]]} {
							return "usi"
						}
						if {[WordEndsWithAnyOf $word [list usy]]} {
							return ".si"
						}
						if {[WordEndsWithAnyOf $word [list ousy owsy]]} {
							return "aUzi"
						}
						return ".si"
					}
				}
			} 
			if {[IsMonosyllabic $word y]} {
				return "ai"		;#	sky, pry
			}
			return "i"			;#	handy
		}
		"z" {
			set rhymestr [IncludePreviousChar $word $k]
			incr k -1
			if {[string length $rhymestr] > 0} {
				switch -- $rhymestr {
					"ez" {
						return "ez"
					}
					"tz" {
						return "ts"
					}
					"zz" {
						set rhymestr [IncludePreviousChar $word $k]
						incr k -1
						if {[string length $rhymestr] > 0} {
							switch -- $rhymestr {
								"azz" {
									return "az"
								}
								"izz" {
									return "iz"
								}
								"uzz" {
									return "uz"
								}
							}
						}
					}
				}
			}
			return "z"
		}
	}
	return "-"		;#	IN CASE ANY VAL MISSED
}

#---- Get end part of word, including an additional character

proc IncludePreviousChar {word k} {
	incr k -1
	if {$k < 0} {
		return ""
	}
	set rhymestr [string range $word $k end]
	return $rhymestr
}

#---- Function returns a de-pluralised word, with 1 for is-plural or 0 for NOT plural

proc RemoveFinalSForRhymes {word} {
	set len [string length $word]
	set j [expr $len - 1]
	set k [expr $len - 2]
	if {$k > 0} {
		set wordlist [list ches shes sses]			;#	These have special plurals : treat as NOT (simple) plurals
		if {[WordEndsWithAnyOf $word $wordlist]} {
			return [list $word 0]
		}											;#	These are special plurals : treat as if NOT plurals						
		set wordlist1 [list crises neuroses analyses praxes]
		set wordlist2 [list theses psychoses]
		if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
			return [list $word 0]
		}												
		set wordlist [list alibis rabbis dhobis mahdis sufis yogis khakis skis bengalis alkalis tuttis agoutis]
		if {[WordMatchesAnyOfWords $word $wordlist]} {
			set word [string range $word 0 $k]		;#	These words are plurals: remove the 's'
			return [list $word 1]
		}
		if {[string match $word "claus"]} {				;#	This is not a plural
			return [list $word 0]
		}
		set wordlist1 [list eaus aus jus flus]		;#	These endings and these words are plurals
		set wordlist2 [list babus zebus hindus adiues lieus emus menus parvenus gnus cachous coypus]
		if {[WordMatchesAnyOfWords $word $wordlist1] || [WordEndsWithAnyOf $word $wordlist2]} {
			set word [string range $word 0 $k]		;#	remove the 's'
			return [list $word 1]
		}
		set wordlist [list ss os us is as]			;#	These endings are NOT plurals
		if {[WordEndsWithAnyOf $word $wordlist]} {
			return [list $word 0]
		}											;#	These words are NOT plurals
		set wordlist [list hades pleiades hyades dryades ides eumenides leonides antipodes rabies species]
		set wordlist [concat $wordlist Aries Caries series isoceles mephistopheles measles herpes mollases glasses]
		set wordlist [concat $wordlist diabetes pyrites litotes cortes barytes faeces isoceles mephistopheles]
		set wordlist [concat $wordlist dais beaujolais cos reredos kudos logos bathos pathos ethos thermos cosmos tripos apropos]
		set wordlist [concat $wordlist pharos rhinoceros asbestos appendices indices codices auspices fasces pisces calyces]
		set wordlist [concat $wordlist ichthys does chamois bourgeois avoirdupois hermes litotes]
		if {[WordMatchesAnyOfWords $word $wordlist]} {
			return [list $word 0]
		}
	} else {
		set wordlist [list us is as]			;#	These words are NOT plurals
		if {[WordMatchesAnyOfWords $word $wordlist]} {
			return [list $word 0]
		}
	}											;#	These words are NOT plurals
	if {[string index $word $j] == "s"} {					;#	All other words ending in "s" assuned to be plural
		set word [string range $word 0 $k]
		return [list $word 1]
	}
	return [list $word 0]
}

#----- Decide phonetic pronunciation of a final single pluralising "s" (removed earlier)

proc DoFinalSConversionForRhymes {origword word} {
	set len [string length $origword]
	incr len -2 		;#	Need to remove the "s" again from origword
	set origword [string range $origword 0 $len]
	set outlen [string length $word]
	set penultout [expr $outlen - 1]
	set len [string length $origword]
	incr len -1
	set penultchar [string index $origword $len]
	if {[string length $origword] >= 2} {
		incr len -1
		set prepenultchar [string index $origword $len]
	}	
	if {[string length $origword] >= 3} {
		incr len -1
		set preprepenultchar [string index $origword $len]
	}	
	if {[string length $origword] >= 4} {
		incr len -1
		set prepreprepenultchar [string index $origword $len]
	}	
	if {[string length $origword] >= 5} {
		incr len -1
		set preprepreprepenultchar [string index $origword $len]
	}
	switch -- $penultchar {
		"e" {
			switch -- $prepenultchar {
				"h" {
					if {[string length $origword] >= 4} {
						if {$preprepenultchar == "p"} {				;#	-phes	->(f)s
							append word "s"
						} elseif {$preprepenultchar == "t"} {		;#	-thes -> (T)z
							append word "z"
					#
					#	} elseif {$preprepenultchar == "s"} {		;#	-shes -> (S)iz
					#		;#	dealt with as specialised routine in main Rhymes prog
					#	} elseif {$preprepenultchar == "c"} {
					#		;#	dealt with as specialised routine in main Rhymes prog
					#
						}
					}
				}
				"f" {
					if {[string match $word "cafe"]} {				;#	cafe -> (cafi)z
						append word "z"
					} else {
						append word "s"								;#	slave -> (sl4v)z
					}
				}
				"c" -
				"g" -
				"s" -
				"z" {				;#	faces, cages, houses, dazes
					append word "iz"
				}
				"k" -
				"p" -
				"t" {					;#	capes etc.
					append word "s"
				}
				"u" {
					if {$preprepenultchar == "q"} {		;#	-ques	->(k)s
						append word "s"
					} else {							;#	cues, dues	-> (kiU)z
						append word "z"
					}
				}
				default {				;#	babe -> (b4b)z
					append word "z"
				}
			}
		}
		"h" {
			switch -- $prepenultchar {
				"c" -
				"p" -
				"t" {	;#	ch(lochs), ph(graphs), th(laths)
					append word "s"
				}
				"s" {	;#	sh (-shs probably impossible)				
					append word "s"
				}
				"g" {
					set wordlist [list igh]
					if {[WordEndsWithAnyOf $origword $wordlist]} {
						append word "z"
					}
					set wordlist [list augh]
					if {[WordEndsWithAnyOf $origword $wordlist]} {
						if [string match $origword "laugh"] {
							append word "s"
						} else {
							append word "z"
						}
					}
					set wordlist [list ough]
					if {[WordEndsWithAnyOf $origword $wordlist]} {
						set wordlist [list rough tough chough lough clough enough trough cough]
						if {[WordMatchesAnyOfWords $origword $wordlist]} {
							append word "s"
						} else {
							append word "z"
						}
					}
				}
				default {	;# ??
					append word "z"
				}
			}
		}
		"c" -
		"f" -
		"k" -
		"p" -
		"q" -
		"t" {							;#	caps etc.
			append word "s"
		}
		default  {						;#	dabs etc.
			append word "z"
		}
	}
	return $word	
}

#--- Does word begin with any of the strings in startlist ?

proc WordStartsWithAnyOf {word startlist} {
	foreach start $startlist {
		if {[string first $start $word] == 0} {
			return 1
		}
	}
	return 0
}

#---- Get start of word up to character number k

proc IncludeNextChar {word len k} {
	if {$k >= $len} {
		return ""
	}
	set rhymestr [string range $word 0 $k]
	return $rhymestr
}

#-- Does word have structure @@@@Ce##### OR @@@@Cing###
#--	where @@@@ = wordstart : C = consonant : ### are any other chars

proc UniversalEing {word wordstart} {
	set wrdlen [string length $word]
	set sttlen [string length $wordstart]
	if {[string first $wordstart $word] != 0} {
		return 0
	}
	if {[IsVowel [string index $word $sttlen]]} {
		return 0
	}
	incr sttlen 1
	if {$wrdlen <= $sttlen} {
		return 0
	}
	set teststr [string range $word $sttlen end]
	if {([string first "e" $teststr] == 0) || ([string first "ing" $teststr] == 0)} {
		return 1
	}
	return 0
}

#-- Does word have structure @@@@e##### OR @@@@ing###
#--	where @@@@ = wordstart : and ### are any other chars

proc SpecificEing {word wordstart} {
	set wrdlen [string length $word]
	set sttlen [string length $wordstart]
	if {[string first $wordstart $word] != 0} {
		return 0
	}
	if {$wrdlen <= $sttlen} {
		return 0
	}
	set teststr [string range $word $sttlen end]
	if {([string first "e" $teststr] == 0) || ([string first "ing" $teststr] == 0)} {
		return 1
	}
	return 0
}

#---- Get phonetic representation of start of a word

proc GetPhoneticStart {word} {
	global evv
	set wlen [string length $word]
	set k 0
	set rhymestr [IncludeNextChar $word $wlen $k]
	if {[string length $rhymestr] <= 0} {
		return $evv(NULL_PROP)
	}
	incr k
	switch -- $rhymestr {
		"a" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ab" { 
					set wordlist1 [list abbatoir abbey abbot abbess]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ab"
					}
					set wordlist2 [list abdicat aberrat abdom abhor abduct abject abnormal aborig abs]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ab"
					}
					set wordlist1 [list ably]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "4b"
					}
					set wordlist2 [list able]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4b"
					}
					return ".b" 
				}
				"ac" { 
					set wordlist1 [list accustom]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return ".c"
					}
					if {[UniversalEing $word accus]} {
						return ".c"
					}
					set wordlist1 [list accolade acumen acne acquisition]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ac"
					}
					set wordlist2 [list acce accur ack acquie acri acrobat act]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ac"
					}
					set wordlist1 [list ace]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "4s"
					}
					set wordlist1 [list aching acorn]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "4k"
					}
					set wordlist2 [list ache acre]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4k"
					}
					set wordlist2 [list ach]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return ".C"
					}
					set wordlist2 [list acidi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return ".s"
					}
					set wordlist2 [list acid]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "as"
					}
					return ".c" 
				}
				"ad" { 
					set wordlist1 [list adriatic]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "4d" 
					}
					set wordlist1 [list ad add adder]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ad" 
					}
					set wordlist2 [list adamant additive adequate adhe adjectiv adm adol adv]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ad" 
					}
					return ".d" 
				}
				"ae" { 
					set wordlist2 [list aeg]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "I"
					}
					set wordlist2 [list aer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "E"
					}
					set wordlist2 [list aes]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "e"
					}
				}
				"af" { 
					return "af" 
				}
				"ag" { 
					set wordlist1 [list agenda]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return ".j" 
					}
					if {[SpecificEing $word ag]} {
						return "4j" 
					}
					set wordlist2 [list aggravat agoni agon agri]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ag" 
					}
					set wordlist1 [list agile]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "aj" 
					}
					if {[SpecificEing $word agitat]} {
						return "aj" 
					}
					return ".g" 
				}
				"ah" { 
					set wordlist1 [list ah]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "A"
					}
					return "."
				}
				"ai" { 
					set wordlist2 [list air]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "E"
					}
					set wordlist1 [list aisle]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ai" 
					}
					return "4"
				}
				"al" { 
					set wordlist1 [list almond]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "A"
					}
					set wordlist1 [list alligator allegation allergy alibi alimony alsatian altitude alto aluminium]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "al" 
					}
					set wordlist2 [list alloy allow ally allie alley albania algebr algeria alphabet alp]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "al" 
					}
					set wordlist2 [list alli allu allergi alleg allay]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return ".l" 
					}
					set wordlist1 [list almost already alright also always]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "Ol" 
					}
					set wordlist2 [list all albeit alder alth alto]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Ol" 
					}
					set wordlist2 [list alt]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ol" 
					}
					set wordlist2 [list ale]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4l" 
					}
					return ".l" 
				}
				"am" { 
					set wordlist1 [list amoral]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "4m" 
					}
					set wordlist2 [list amiab]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4m" 
					}
					set wordlist1 [list ammunition]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "am" 
					}
					set wordlist2 [list amateur amazon amicab amn amorous amp]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "am" 
					}
					return ".m" 
				}
				"an" { 
					set wordlist2 [list anti]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "anti" 
					}
					set wordlist1 [list anaesthetic anaesthesia analog analogue analysis anathema ancillary angelic angina]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "an" 
					}
					set wordlist2 [list analges analyt anarch anatomic ancest anchor anchov and ankle annex annivers annota annual anor answer ant anx ani]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "an" 
					}
					set wordlist2 [list anger angri angl angu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "aNg" 
					}
					set wordlist1 [list angel anus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "4n" 
					}
					set wordlist2 [list ancient]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4n" 
					}
					set wordlist2 [list any]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "en" 
					}
					return ".n" 
				}
				"ao" { 
					return "4O" 
				}
				"ap" { 
					set wordlist1 [list aperture apple]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ap" 
					}
					set wordlist2 [list apath appar appeti applica apprehen apt]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ap" 
					}
					if {[SpecificEing $word ap]} {
						return "4p" 
					}
					set wordlist2 [list apr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4p" 
					}
					return ".p" 
				}
				"aq" { 
					set wordlist1 [list aqualung]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ak" 
					}
					return ".k" 
				}
				"ar" { 
					set wordlist1 [list area aries]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "E" 
					}
					set wordlist1 [list arab arabic arable arithmetical aromatic]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "a" 
					}
					set wordlist2 [list arid arist arro]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "a" 
					}
					set wordlist1 [list arithmetic]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "." 
					}
					set wordlist2 [list arabia arr aro]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "." 
					}
					if {[SpecificEing $word aris]} {
						return "." 
					}
					return "A" 
				}
				"as" { 
					set wordlist1 [list ash ashen ashtray]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "aS" 
					}
					set wordlist2 [list ash]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return ".S" 
					}
					set wordlist2 [list asia]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4Z" 
					}
					set wordlist1 [list ask asking asked aspect aspirin asterisk astronaut]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "as" 
					}
					set wordlist2 [list aspiration asthma astronomical]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "as" 
					}
					return ".s" 
				}
				"at" { 
					set wordlist1 [list ate]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "4t" 
					}
					set wordlist2 [list athei]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4T" 
					}
					set wordlist1 [list at atom]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "at" 
					}
					set wordlist2 [list atl atm atti attribut]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "at" 
					}
					set wordlist2 [list ath]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "aT" 
					}
					return ".t" 
				}
				"au" { 
					set wordlist1 [list aubergine]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "@b" 
					}
					set wordlist2 [list aunt]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ant" 
					}
					set wordlist2 [list austr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "os" 
					}
					return "O" 
				}
				"av" { 
					set wordlist2 [list aviat]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "4v" 
					}
					set wordlist1 [list avalanche avenue avocado]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "av" 
					}
					set wordlist2 [list average avaric]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "av" 
					}
					return ".v" 
				}
				"aw" { 
					set wordlist1 [list awe awning]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "O" 
					}
					set wordlist2 [list awful awkward]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "O" 
					}
					return "." 
				}
				"ax" { 
					return "aks" 
				}
				"ay" { 
					return "ai" 
				}
				"az" { 
					return ".z" 
				}
			}
		}
		"b" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ba" {
					set wordlist1 [list bare baring]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bE" 
					}
					set wordlist1 [list barring]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bA" 
					}
					set wordlist2 [list balm]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bA" 
					}
					set wordlist1 [list bayou]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ba" 
					}
					set wordlist2 [list basil]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ba" 
					}
					set wordlist1 [list banana barometer bassoon bazaar]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "b." 
					}
					set wordlist2 [list ballon]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "b." 
					}
					if {[UniversalEing $word ba]} {
						return "b4" 
					}
					if {[SpecificEing $word bath]} {
						return "b4" 
					}
					set wordlist2 [list baco basi bai bay]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "b4" 
					}
					set wordlist1 [list baltic]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bo" 
					}
					set wordlist2 [list bald baw ball]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bO" 
					}
					set wordlist2 [list barr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ba" 
					}
					set wordlist2 [list bar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bA" 
					}
					return "ba" 
				}
				"be" {
					set wordlist1 [list bereft belligerent beneath being between]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bi" 
					}
					set wordlist2 [list bereaved benign belated betray]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bi" 
					}
					set wordlist1 [list belfry]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "be" 
					}
					set wordlist2 [list belt bench benefact best bell begg beck]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "be" 
					}
					set wordlist1 [list berserk]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "b." 
					}
					set wordlist2 [list benevolen]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "b." 
					}
					set wordlist2 [list ber]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "b:" 
					}
					set wordlist2 [list beard]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bi." 
					}
					set wordlist2 [list beau]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "biU" 
					}
					set wordlist2 [list bear]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bE" 
					}
					set wordlist2 [list bec bef beg bel bem beq bes bew bey]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bi" 
					}
					return "be" 
				}
				"bi" {
					set wordlist1 [list bible bicarbonate]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bai" 
					}
					if {[UniversalEing $word bi]} {
						return "bai" 
					}
					set wordlist2 [list bind bio bias bicyl bifocal bilingial bisect]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bai" 
					}
					set wordlist2 [list bir]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "b:" 
					}
					return "bi" 
				}
				"bl" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"bla" { 
							if {[SpecificEing $word bar]} {
								return "blE" 
							}
							if {[UniversalEing $word bla]} {
								return "bl4" 
							}
							set wordlist2 [list blatant]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "bl4" 
							}
							return "bla"
						}
						"ble" { 
							set wordlist2 [list blear]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "bli." 
							}
							set wordlist2 [list blea blee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "blI" 
							}
							set wordlist1 [list blew]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "bliU" 
							}
							return "ble"
						}
						"bli" { 
							set wordlist1 [list blimey]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "blai"
							}
							set wordlist2 [list blythe blind bligh]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "blai"
							}
							return "bli"
						}
					}
					return "bl" 
				}
				"bo" {
					set wordlist1 [list bollard]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bo" 
					}
					set wordlist2 [list borr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bo" 
					}
					set wordlist1 [list borough bosom]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bu" 
					}
					set wordlist2 [list book]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bu" 
					}
					set wordlist1 [list bouquet]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bU" 
					}
					set wordlist1 [list bowel]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "baU" 
					}
					set wordlist1 [list bought]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bO" 
					}
					set wordlist2 [list bour boar bor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bO" 
					}
					set wordlist1 [list boulder bogus bona bonus bony bosun]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "b@" 
					}
					if {[UniversalEing $word bo]} {
						return "b@" 
					}
					set wordlist2 [list boni bow boa bol bold]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "b@" 
					}
					set wordlist2 [list boi boy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "boi" 
					}
					set wordlist2 [list boo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bU" 
					}
					return "bo" 
				}
				"br" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"bra" { 
							set wordlist1 [list bra]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "brA" 
							}
							set wordlist1 [list bravado]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "br:" 
							}
							set wordlist2 [list brazil]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "br:" 
							}
							set wordlist1 [list brazier]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "br4" 
							}
							if {[UniversalEing $word bra]} {
								return "br4" 
							}
							set wordlist1 [list braw]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "brO" 
							}
							return "bra" 
						}
						"bre" { 
							set wordlist2 [list bread]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "bre" 
								}
							set wordlist2 [list break]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "br4" 
								}
							if {[SpecificEing $word breath]} {
								return "brI" 
							}
							set wordlist2 [list breast breath]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "bre" 
								}
							set wordlist2 [list brew]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "brU" 
								}
							set wordlist2 [list brea bree]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "brI" 
								}
							return "bre" 
						}
						"bri" { 
							set wordlist2 [list brie]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "brI" 
								}
								set wordlist1 [list brai bridal]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "brai"
								}
								if {[UniversalEing $word bri]} {
									return "brai"
								}
								if {[SpecificEing $word bridl]} {
									return "brai"
								}
								set wordlist2 [list bright]
								if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "brai"
								}
							return "bri" 
						}
						"bro" { 
							set wordlist1 [list brochure brooch]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "br@" 
							}
							if {[UniversalEing $word bro]} {
								return "br@" 
							}
							set wordlist2 [list broa]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "br@" 
							}
							set wordlist1 [list broi]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "broi" 
							}
							set wordlist2 [list brook brother]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "bru" 
							}
							set wordlist2 [list broo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "brU" 
							}
							set wordlist2 [list brough]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "brO" 
							}
							set wordlist2 [list brou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "braU" 
							}
							return "bro" 
						}
						"bru" { 
							set wordlist2 [list brui brusq brut]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "brU" 
							}
							return "bru" 
						}
					}
				}
				"bu" {
					set wordlist2 [list bureau]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "biO" 
					}
					set wordlist2 [list buri burrow bury]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bu" 
					}
					set wordlist1 [list busy busily business]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "bi" 
					}
					set wordlist2 [list bui]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bi" 
					}
					set wordlist2 [list but bur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "b." 
					}
					
					set wordlist2 [list bugl]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "biU" 
					}
					
					set wordlist2 [list buy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "bai" 
					}
					
					set wordlist2 [list buoy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "boi" 
					}
					return "bu" 
				}
			}
		}
		"c" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ca" {
					set wordlist1 [list cagoule calamity canal canary casino cassette]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "k." 
					}
					set wordlist2 [list capitulat capricious caress cathedr cavort cajol canoe]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k." 
					}
					set wordlist1 [list camel cameo carafe carat caribbean caterpillar]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ka" 
					}
					set wordlist2 [list cavern carr camera caricatur carol]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ka" 
					}
					set wordlist1 [list cauliflower]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ko" 
					}
					set wordlist2 [list cau]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kO" 
					}
					set wordlist1 [list canine]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "k4" 
					}
					if {[UniversalEing $word ca]} {
						return "k4" 
					}
					if {[SpecificEing $word cabl]} {
						return "k4" 
					}
					set wordlist2 [list capab]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k4" 
					}
					set wordlist1 [list cant]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "kA" 
					}
					set wordlist2 [list car]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kA" 
					}
					set wordlist1 [list cairo]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "kai" 
					}
					set wordlist2 [list ceasar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sI" 
					}
					return "ka" 
				}
				"ce" {
					set wordlist1 [list celestial certificate]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "s." 
					}
					set wordlist2 [list ceramic celebrit]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s." 
					}
					set wordlist1 [list cello cellist]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "Ce" 
					}
					set wordlist2 [list certif]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s:" 
					}
					set wordlist1 [list cement]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "si" 
					}
					set wordlist1 [list cereal]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "sia" 
					}
					if {[UniversalEing $word ce]} {
						return "sI" 
					}
					set wordlist2 [list cea cei cedar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sI" 
					}
					return "se" 
				}
				"ch" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"cha" {
							set wordlist1 [list chalet charade]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "Sa" 
							}
							set wordlist2 [list chass chaperon charlatan]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Sa" 
							}
							set wordlist1 [list chasm]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ka" 
							}
							set wordlist2 [list character]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ka" 
							}
							set wordlist2 [list charit]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Ca" 
							}
							set wordlist2 [list chair]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Ce" 
							}
							set wordlist2 [list chalk]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "CO" 
							}
							set wordlist2 [list chao]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "k4o" 
							}
							set wordlist2 [list char]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "CA" 
							}
							set wordlist2 [list chau]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "S@" 
							}
							if {[UniversalEing $word cha]} {
								return "C4" 
							}
							if {[SpecificEing $word chang]} {
								return "C4" 
							}
							set wordlist2 [list chai chamber]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "C4" 
							}
							return "Ca" 
						}
						"che" {
							set wordlist2 [list cheer]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Ci." 
							}
							set wordlist2 [list chea chee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "CI" 
							}
							set wordlist2 [list chem]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ke" 
							}
							set wordlist1 [list chef]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "Se" 
							}
							set wordlist2 [list chew]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "CiU" 
							}
							return "Ce" 
						}
						"chi" {
							set wordlist1 [list children]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "Ci" 
							}
							set wordlist1 [list chic]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "SI" 
							}
							set wordlist2 [list chief]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "CI" 
							}
							set wordlist1 [list chiffon]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "Si" 
							}
							set wordlist2 [list chivalr]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Si" 
							}
							set wordlist2 [list chiropo chiasm]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ki" 
							}
							set wordlist2 [list chiropra]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kai" 
							}
							set wordlist2 [list chir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "C:" 
							}
							if {[UniversalEing $word chi]} {
								return "Cai" 
							}
							set wordlist2 [list child china]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Cai" 
							}
							return "Ci" 
						}
						"chl" {
							return "klO"
						}
						"cho" {
							set wordlist2 [list choir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kUai"
							}
							set wordlist1 [list cholesterol]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "k." 
							}
							set wordlist2 [list chole chori choreo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ko" 
							}
							set wordlist2 [list choi]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Coi" 
							}
							set wordlist2 [list chora choru]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kO" 
							}
							set wordlist2 [list choo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "CU" 
							}
							if {[UniversalEing $word cho]} {
								return "C@" 
							}
							return "Co" 
						}
						"chr" { 
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"chri" {
									set wordlist1 [list christ]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "krai"
									}
									return "kri" 
								}
								"chro" {
									set wordlist2 [list chrom]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "kr@" 
									}
									return "kro"
								}
							}
						}
						"chu" {
							set wordlist2 [list chur]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "C:" 
							}
							set wordlist1 [list chute]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "SiU" 
							}
							return "Cu" 
						}
					}
				}
				"ci" {
					set wordlist2 [list circumferen]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s." 
					}
					if {[UniversalEing $word ci]} {
						return "sai" 
					}
					if {[SpecificEing $word ciph]} {
						return "sai" 
					}
					return "si" 
				}
				"cl" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"cla" {
							set wordlist2 [list claustro]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klo" 
							}
							set wordlist2 [list clau claw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klO" 
							}
							set wordlist2 [list clair]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klE" 
							}
							set wordlist2 [list clai clay]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kl4" 
							}
							return "kla" 
						}
						"cle" {
							set wordlist2 [list cleansh]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klI" 
							}
							set wordlist2 [list cleans]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kle" 
							}
							set wordlist2 [list clear]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kli" 
							}
							set wordlist2 [list clea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klI" 
							}
							set wordlist2 [list clergy]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kl:" 
							}
							set wordlist2 [list clerk]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klA" 
							}
							return "kle" 
						}
						"cli" {
							set wordlist1 [list cliche]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "klI" 
							}
							set wordlist2 [list client clim]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klai" 
							}
							return "kli" 
						}
						"clo" {
							set wordlist2 [list closet]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klo" 
							}
							if {[SpecificEing $word cloth]} {
								return "kl@" 
							}
							if {[UniversalEing $word clo]} {
								return "kl@" 
							}
							set wordlist2 [list cloa]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kl@" 
							}
							set wordlist2 [list cloi cloy]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kloi" 
							}
							set wordlist2 [list clou clow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klaU" 
							}
							return "klo" 
						}
						"clu" { 
							set wordlist2 [list clue]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "klU" 
							}
							return "klu" 
						}
					}
				}
				"co" {
					set wordlist1 [list comb combing colon cocoa coconut cosy cozy colt]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "k@" 
					}
					set wordlist2 [list cold combe coerci coma copious cosi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k@" 
					}
					set wordlist1 [list comma commerce commune communism comedy]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ko" 
					}
					set wordlist2 [list commuta comment common commuta]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ko" 
					}
					set wordlist1 [list corrode corollary corrall collide]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "k." 
					}
					set wordlist1 [list comedown]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ku" 
					}
					set wordlist2 [list corroborat connect commut comm collap collab collec collis colloq collu collat coloni courag comed corrup corros]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k." 
					}
					set wordlist2 [list coinci]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k@i" 
					}
					set wordlist2 [list coop]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k@o" 
					}
					set wordlist2 [list coor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k@O" 
					}
					set wordlist1 [list coronation coroner coronet]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ko" 
					}
					set wordlist2 [list coronar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ko" 
					}
					set wordlist2 [list cor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kO" 
					}
					set wordlist2 [list coo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kU" 
					}
					set wordlist1 [list courage cousin company compass coming collander comeuppance]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ku" 
					}
					set wordlist2 [list courage]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k." 
					}
					set wordlist2 [list covenant colour come comfort could countr coupl courier conjur cook cover covet]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ku" 
					}
					set wordlist1 [list coup coupon]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "kU" 
					}
					set wordlist1 [list colonel]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "k:" 
					}
					set wordlist2 [list courteous courtes]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k:" 
					}
					set wordlist2 [list cour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kO" 
					}
					set wordlist2 [list cou cow]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kaU" 
					}
					set wordlist2 [list coi coy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "koi" 
					}
					set wordlist1 [list coalition]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "k@." 
					}
					set wordlist2 [list coag]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k@a" 
					}
					set wordlist2 [list coar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kO" 
					}
					set wordlist1 [list co]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "k@" 
					}
					if {[UniversalEing $word co]} {
						return "k@" 
					}
					set wordlist2 [list coa]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k@" 
					}
					return "ko"
				}
				"cr" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"cra" {
							if {[UniversalEing $word cra]} {
								return "kr4" 
							}
							set wordlist2 [list cray craz]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kr4" 
							}
							set wordlist2 [list craw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "krO" 
							}
							return "kra" 
						}
						"cre" {
							set wordlist1 [list creature]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "krI" 
							}
							set wordlist1 [list crepe]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "kre" 
							}
							set wordlist1 [list credential cremate cremation]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "kri" 
							}
							set wordlist2 [list creat]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "krI4" 
							}
							if {[UniversalEing $word cre]} {
								return "krI" 
							}
							set wordlist2 [list cree crea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "krI" 
							}
							set wordlist1 [list crevasse]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "kr." 
							}
							set wordlist2 [list crew]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "krU" 
							}
							return "kre" 
						}
						"cri" {
							set wordlist1 [list crisis]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "krai" 
							}
							if {[UniversalEing $word cri]} {
								return "krai" 
							}
							return "kri" 
						}
						"cro" {
							set wordlist1 [list crocus crow crowbar]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "kr@" 
							}
							set wordlist2 [list croa crochet crony]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kr@" 
							}
							set wordlist1 [list croupier crouton]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "krU" 
							}
							set wordlist2 [list croo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "krU" 
							}
							set wordlist2 [list crow crou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kraU" 
							}
							return "kro" 
						}
						"cru" {
							set wordlist1 [list crux]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "kru" 
							}
							set wordlist2 [list crun crus crut crum]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "kru" 
							}
							return "krU" 
						}
						"cry" {
							set wordlist1 [list cry]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "krai" 
							}
							return "kri" 
						}
					}
				}
				"cu" {
					set wordlist1 [list cuckoo]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ku" 
					}
					set wordlist2 [list curr cubb]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ku" 
					}
					set wordlist1 [list cupid cuticle]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "kiU" 
					}
					if {[UniversalEing $word cu]} {
						return "kiU" 
					}
					set wordlist2 [list curio cub cuc cura cumulative]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kiU" 
					}
					set wordlist2 [list curio]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kiO" 
					}
					set wordlist1 [list cuisine]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "KUi" 
					}
					set wordlist1 [list culotte]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "kU" 
					}
					set wordlist2 [list cur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k:" 
					}
					return "ku" 
				}
				"cy" {
					set wordlist1 [list cypriot]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "si" 
					}
					set wordlist2 [list cya cyc cyp]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sai" 
					}
					return "si" 
				}
				"cz" {
					set wordlist2 [list cze]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Ce" 
					}
					set wordlist2 [list cza]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ZA" 
					}
				}
			}
		}
		"d" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"da" {
					if {[SpecificEing $word dar]} {
						return "dE" 
					}
					set wordlist2 [list dair]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "dE" 
					}
					set wordlist1 [list danish data]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "d4" 
					}
					if {[UniversalEing $word da]} {
						return "d4" 
					}
					set wordlist2 [list dange day dai]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "d4" 
					}
					set wordlist2 [list dark]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "dA" 
					}
					set wordlist2 [list dau daw]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "dO" 
					}
					return "da" 
				}
				"de" {
					set wordlist1 [list dear]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "di." 
					}
					set wordlist2 [list deer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "di." 
					}
					set wordlist2 [list dead deaf death derr		]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "de" 
					}
					set wordlist1 [list detente]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "d4" 
					}
					set wordlist2 [list delegat]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "de" 
					}
					if {[UniversalEing $word de]} {
						return "dI" 
					}
					set wordlist2 [list dea]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "dI" 
					}
					set wordlist1 [list decor]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "d4" 
					}
					set wordlist1 [list decoy defect de]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "dI" 
					}
					set wordlist2 [list devious devolu dereg dehydra demarc demon denatur depopu detail detour deviat]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "dI" 
					}
					set wordlist2 [list dee]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "dI" 
					}
					set wordlist2 [list dei]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "d4" 
					}
					set wordlist2 [list der]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "d:" 
					}
					set wordlist2 [list dew]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "diU" 
					}
					set wordlist1 [list decibel definition deli delving demo demolition den denim denmark depot desk]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "de" 
					}
					set wordlist2 [list delegat delica deluge delve demonstr denig dens desecr devil devas detri deso desper designat dex deton deprivat depu derelic debit debt decaden decima deca deck declara decora dedic defama deft]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "de" 
					}
 					return "di" 
				}
				"dr" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"dra" {
							if {[UniversalEing $word dra]} {
								return "dr4" 
							}
							set wordlist2 [list drai]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "dr4" 
							}
							set wordlist1 [list drama]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "drA" 
							}
							set wordlist2 [list draw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "drO" 
							}
							set wordlist2 [list dramatic]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "dr." 
							}
							return "dra" 
						}
						"dre" {
							set wordlist2 [list dread]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "dre" 
							}
							set wordlist2 [list drear]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "dri." 
							}
							set wordlist2 [list drea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "drI" 
							}
							set wordlist2 [list drew]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "drU" 
							}
							return "dre" 
						}
						"dri" {
							set wordlist1 [list drivel driven]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "dri" 
							}
							if {[UniversalEing $word dri]} {
								return "drai" 
							}
							set wordlist2 [list drie]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "drai" 
							}
							return "dri" 
						}
						"dro" {
							if {[UniversalEing $word dro]} {
								return "dr@" 
							}
							set wordlist2 [list droll]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "dr@" 
							}
							set wordlist2 [list droo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "drU" 
							}
							set wordlist2 [list drough drow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "draU" 
							}
							return "dro" 
						}
						"dru" {
							set wordlist2 [list dru]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "dru"
							}
						}
						"dry" {
							set wordlist2 [list dry]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "drai"
							}
						}
					}
				}
				"du" {
					set wordlist1 [list duvet]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "dU" 
					}
					set wordlist1 [list duality]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "diUa" 
					}
					set wordlist1 [list duly]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "diu" 
					}
					if {[UniversalEing $word du]} {
						return "diu" 
					}
					set wordlist2 [list dual duel dubi due dupl dut]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "diu" 
					}
					set wordlist2 [list dur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "diO" 
					}
 					return "du" 
				}
				"dw" {
					"dwa" {
						return "dwO" 
					}
					"dwe" {
						return "dUe" 
					}
					"dwi" {
						return "dUi" 
					}
				}
				"dy" {
					set wordlist2 [list dys]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "dis" 
					}
					return "dai" 
				}
			}
		}
		"e" {
			set wordlist2 [list earl earn earth]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return ":" 
			}
			set wordlist1 [list era]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "i." 
			}
			set wordlist2 [list ear]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "i." 
			}
			set wordlist1 [list eau]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "@" 
			}
			set wordlist1 [list economic edict ego egypt ether ethos evil equal]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "I" 
			}
			set wordlist2 [list evolu ea ee elong equilibr ethiopia]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "I" 
			}
			set wordlist2 [list eir]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "E" 
			}
			set wordlist2 [list eigh elite]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "4" 
			}
			set wordlist2 [list ei]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "ai" 
			}
			set wordlist1 [list encore en entourage]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "O" 
			}
			set wordlist2 [list erratic]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "i" 
			}
			set wordlist2 [list erm err]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return ":" 
			}
			set wordlist2 [list euph ewe]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "iU" 
			}
			set wordlist2 [list eur]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "iO" 
			}
			set wordlist1 [list electronic enigmatic]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "e" 
			}
			set wordlist1 [list ecology equation equate equator elicit emetic eradi epistle]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "i" 
			}
			set wordlist2 [list enigma equip erratic enorm equiv etern elop emit enunciat ethereal eras evac erect event elu emot emacia enamel evict eclessi elect ela egali egypti eclip electro eject efficien electric elector elabor effect electrif electrocut emanci engl evo eleven emerg]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "i" 
			}
			set wordlist2 [list ex]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "eks" 
			}
			set wordlist2 [list eye]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "ai" 
			}
			if {[UniversalEing $word e]} {
				return "I" 
			}
			return "e" 
		}
		"f" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"fa" {
					set wordlist2 [list fair fare]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fE" 
					}
					set wordlist2 [list falcon fals falt fault]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fo" 
					}
					set wordlist1 [list fallacy fallow]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fa" 
					}
					set wordlist2 [list facetious]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f." 
					}
					set wordlist2 [list facet falli]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fa" 
					}
					set wordlist2 [list fall fau faw]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fO" 
					}
					set wordlist2 [list far father]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fA" 
					}
					set wordlist2 [list facetious familiar facili fanatic fatigu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f." 
					}
					if {[UniversalEing $word fa]} {
						return "f4" 
					}
					if {[SpecificEing $word fabl]} {
						return "f4" 
					}
					set wordlist2 [list favour fai facial famous fatal]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f4" 
					}
					return "fa" 
				}
				"fe" {
					set wordlist2 [list feath]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fE" 
					}
					set wordlist2 [list fear]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fi." 
					}
					set wordlist1 [list feline fetus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fI" 
					}
					set wordlist2 [list fee female fea]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fI" 
					}
					set wordlist1 [list fete]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "f4" 
					}
					set wordlist2 [list fei]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f4" 
					}
					set wordlist1 [list ferric ]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fe" 
					}
					set wordlist2 [list ferocious]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f." 
					}
					set wordlist2 [list fer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f:" 
					}
					set wordlist2 [list feu few]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fiU" 
					}
					return "fe" 
				}
				"fi" {
					set wordlist1 [list fiance]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fiO" 
					}
					set wordlist1 [list fidelity]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fi" 
					}
					set wordlist1 [list finite]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fai" 
					}
					if {[UniversalEing $word fi]} {
						return "fai" 
					}
					if {[SpecificEing $word fibr]} {
						return "fai" 
					}
					set wordlist2 [list final financ find fight]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fai" 
					}
					set wordlist2 [list fierce]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fi." 
					}
					set wordlist1 [list fiery]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fai." 
					}
					set wordlist2 [list fie]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fI" 
					}
					set wordlist2 [list fir]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f:" 
					}
 					return "fi" 
				}
				"fl" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"fla" {
							if {[SpecificEing $word flar]} {
								return "flE" 
							}
							set wordlist2 [list flair]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flE" 
							}
							if {[UniversalEing $word fla]} {
								return "fl4" 
							}
							set wordlist2 [list flavour]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "fl4" 
							}
							set wordlist2 [list flau flaw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flO"
							}
							return "fla" 
						}
						"fle" {
							set wordlist2 [list flea flee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flI" 
							}
							set wordlist1 [list flew]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "flU" 
							}
							return "fle" 
						}
						"fli" {
							set wordlist2 [list flie flight]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flai" 
							}
							set wordlist2 [list flir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "fl:" 
							}
							return "fli" 
						}
						"flo" {
							set wordlist1 [list flow flown flowed flowing]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "fl@" 
							}
							set wordlist2 [list floa]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "fl@" 
							}
							set wordlist2 [list flood]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flu" 
							}
							set wordlist1 [list flora]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "flO" 
							}
							set wordlist2 [list floor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flO" 
							}
							set wordlist2 [list flourish]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flu" 
							}
							set wordlist2 [list flou flow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flaU" 
							}
							return "flo" 
						}
						"flu" {
							set wordlist1 [list flue flu]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "flU" 
							}
							if {[UniversalEing $word flu]} {
								return "flU" 
							}
							set wordlist2 [list flui]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flUi" 
							}
							set wordlist2 [list fluor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "flO" 
							}
							return "flu" 
						}
						"fly" {
							return "flai" 
						}
					}
				}
				"fo" {
					set wordlist1 [list foe foliage]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "f@" 
					}
					set wordlist2 [list folk foa foc fold]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f@" 
					}
					set wordlist1 [list foetus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fI" 
					}
					set wordlist2 [list foi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "foi" 
					}
					set wordlist2 [list foot]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fu" 
					}
					set wordlist2 [list foo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fU" 
					}
					set wordlist2 [list foreign forest]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fo" 
					}
					set wordlist1 [list forever forgave]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "f." 
					}
					set wordlist2 [list forget forensic forgot forbid forgiv]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f." 
					}
					set wordlist2 [list for fore]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fO" 
					}
					return "fo" 
				}
				"fr" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"fra" {
									set wordlist1 [list fraternize fraternise]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "fra" 
									}
									set wordlist2 [list fratern]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "fr." 
									}
									if {[UniversalEing $word fra]} {
										return "fr4" 
									}
									set wordlist2 [list fragran frail fray]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "fr4" 
									}
									set wordlist2 [list frau]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "frO" 
									}
									return "fra" 
						}
						"fre" {
							set wordlist2 [list frea free freq]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "frI" 
							}
							set wordlist2 [list frei]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "fr4" 
							}
							return "fre" 
						}
						"fri" {
							set wordlist2 [list friez]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "frI" 
							}
							set wordlist2 [list friend]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "fre" 
							}
							set wordlist2 [list friar friday fright]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "frai" 
							}
							return "fri" 
						}
						"fro" {
							set wordlist1 [list fro]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "fr@" 
							}
							if {[UniversalEing $word fro]} {
								return "fr@" 
							}
							set wordlist2 [list front]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "fru" 
							}
							set wordlist2 [list frow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "fraU" 
							}
							return "fro" 
						}
						"fru" {
							set wordlist2 [list frus]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "fru" 
							}
							return "frU" 
						}
					}
				}
				"fu" {
					set wordlist1 [list fusion]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fiU" 
					}
					if {[UniversalEing $word fu]} {
						return "fiU" 
					}
					set wordlist2 [list fumigat fue fugi futil]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fiU" 
					}
					set wordlist1 [list fury]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "fiO" 
					}
					set wordlist2 [list furious]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fiO" 
					}
					set wordlist2 [list furr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fu" 
					}
					set wordlist2 [list fur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f:" 
					}
					return "fu" 
				}
			}
		}
		"g" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ga" { 
					set wordlist1 [list gazetteer]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ga" 
					}
					set wordlist2 [list garr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ga" 
					}
					set wordlist1 [list garish]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "gE" 
					}
					set wordlist1 [list gala]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "gA" 
					}
					set wordlist2 [list gar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gA" 
					}
					set wordlist1 [list galore gazelle gazette]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "g." 
					}
					set wordlist2 [list gazump]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "g." 
					}
					set wordlist2 [list gaol]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "j4" 
					}
					set wordlist1 [list gauche]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "g@" 
					}
					set wordlist1 [list gay]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "g4" 
					}
					if {[UniversalEing $word ga]} {
						return "g4" 
					}
					set wordlist2 [list gai gaug]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "g4" 
					}
					set wordlist2 [list gauch]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gaU" 
					}
					set wordlist1 [list gall]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "gO" 
					}
					set wordlist2 [list gallbl gallst gau]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gO" 
					}
					return "ga" 
				}
				"ge" {
					set wordlist2 [list gear]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gi." 
					}
					set wordlist2 [list gee]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gI" 
					}
					set wordlist1 [list genius]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ji" 
					}
					set wordlist2 [list genial]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ji" 
					}
					set wordlist1 [list gerund]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "je" 
					}
					set wordlist2 [list gener]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "je" 
					}
					set wordlist1 [list geneva geranium gerundive]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "j." 
					}
					set wordlist2 [list genetic]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "j." 
					}
					if {[UniversalEing $word ge]} {
						return "jI" 
					}
					set wordlist1 [list geology]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "jio" 
					}
					set wordlist2 [list geologi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ji." 
					}
					set wordlist2 [list geo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jo" 
					}
					set wordlist2 [list gerr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "je" 
					}
					set wordlist2 [list ger]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "j:" 
					}
					set wordlist2 [list gey]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gI" 
					}
					set wordlist2 [list gel gem gen ges]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "je" 
					}
					return "ge" 
				}
				"gh" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"gha"  {
							set wordlist2 [list ghan]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "gA" 
							}
							return "ga" 
						}
						"ghe" {
							set wordlist2 [list gher]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "g:"
							}
							return "ge" 
						}
						"gho" {
							set wordlist2 [list ghoul]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "gU" 
							}
							return "g@" 
						}
					}
				}
				"gi" {
					set wordlist1 [list giant giro gibe]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "jai" 
					}
					set wordlist2 [list gigant]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jai" 
					}
					if {[SpecificEing $word giv]} {
						return "gi" 
					}
					set wordlist2 [list gidd gif gigg gild gill gilt gimm]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gi" 
					}
					set wordlist1 [list gir]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "g:" 
					}
					return "ji" 
				}
				"gl" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"gla" {
							set wordlist1 [list glazier]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "gl4" 
							}
							if {[UniversalEing $word gla]} {
								return "glE" 
							}
							return "gla" 
						}
						"gle" {
							set wordlist2 [list glea glee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "glI" 
							}
							return "gle" 
						}
						"gli" {
								if {[UniversalEing $word gli]} {
									return "glai" 
								}
								return "gli" 
						}
						"glo" {
							set wordlist2 [list glower]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "glaU" 
							}
							set wordlist2 [list globe global glow gloa]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "gl@" 
							}
							set wordlist2 [list gloo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "glU" 
							}
							set wordlist2 [list glor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "glO" 
							}
							set wordlist2 [list glove]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "glu" 
							}
							return "glo" 
						}
						"glu" {
							set wordlist2 [list gluco glue glute]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "glU" 
							}
							return "glu" 
						}
						"gly" {
							return "gli" 
						}
					}
				}
				"gn" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"gna" {
							set wordlist2 [list gnarl]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "nA" 
							}
							set wordlist2 [list gnaw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "nO" 
							}
							return "na" 
						}
						"gno" {
							set wordlist2 [list gnom]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "n@" 
							}
							return "no " 
						}
					}
				}
				"go" {
					set wordlist1 [list go gobetween going]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "g@" 
					}
					set wordlist2 [list goa gold]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "g@" 
					}
					set wordlist2 [list good govern]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gu" 
					}
					set wordlist1 [list gorilla]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "g." 
					}
					set wordlist2 [list goos]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gU" 
					}
					set wordlist2 [list gor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gO" 
					}
					set wordlist2 [list gau gow]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gaU" 
					}
					return "go" 
				}
				"gr" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"gra" {
							set wordlist2 [list gravel]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "gra" 
							}
							set wordlist1 [list gradient]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "gr4" 
							}
							if {[UniversalEing $word gra]} {
								return "gr4" 
							}
							set wordlist2 [list gravy gracious grai]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "gr4" 
							}
							set wordlist1 [list graffiti]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "gr." 
							}
							set wordlist2 [list grammatical gratuit]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "gr." 
							}
							return "gra" 
						}
						"gre" {
								set wordlist2 [list great grey]
								if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "gr4" 
								}
								set wordlist2 [list grea gree]
								if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "grI" 
								}
								set wordlist1 [list grenade]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "gr." 
								}
								set wordlist2 [list gregarious]
								if {[WordStartsWithAnyOf $word $wordlist2]} {
									return "gr." 
								}
								set wordlist1 [list grew]
								if {[WordMatchesAnyOfWords $word $wordlist1]} {
									return "grU" 
								}
								return "gre" 
						}
						"gri" {
							set wordlist2 [list grie]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "grI" 
							}
							set wordlist1 [list grimy]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "grai" 
							}
							if {[UniversalEing $word gri]} {
								return "grai" 
							}
							set wordlist2 [list grind]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "grai" 
							}
							return "gri" 
						}
						"gro" {
							set wordlist2 [list grovel]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "gro" 
							}
							if {[UniversalEing $word gro]} {
								return "gr@" 
							}
							set wordlist2 [list groa gross]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "gr@" 
							}
							set wordlist1 [list groi]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "groi" 
							}
							set wordlist2 [list groo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "grU" 
							}
							set wordlist2 [list grou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "graU" 
							}
							return "gro" 
						}
						"gru" {
							set wordlist2 [list grue]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "grU" 
							}
							return "gru" 
						}
					}
				}
				"gu" {
					set wordlist2 [list guard]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gA" 
					}
					set wordlist1 [list gua]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ga" 
					}
					set wordlist1 [list guerilla]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "g." 
					}
					set wordlist2 [list gue]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ge" 
					}
					set wordlist1 [list guy]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "gai" 
					}
					if {[UniversalEing $word gui]} {
						return "gai" 
					}
					set wordlist2 [list gui]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gi" 
					}
					set wordlist1 [list guru]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "gu" 
					}
					set wordlist2 [list gur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "g:" 
					}
					return "gu" 
				}
				"gy" {
					set wordlist2 [list gym]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ji" 
					}
					set wordlist2 [list gyna]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "gai" 
					}
					set wordlist1 [list gypsy]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ji" 
					}
					set wordlist2 [list gyrat]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jai" 
					}
				}
			}
		}
		"h" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ha" {
					set wordlist2 [list haemor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hem" 
					}
					set wordlist2 [list haemogl]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hIm" 
					}
					set wordlist2 [list hair hare]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hE" 
					}
					set wordlist1 [list hague halo hasty hatred hazy]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "h4" 
					}
					if {[UniversalEing $word ha]} {
						return "h4" 
					}
					if {[SpecificEing $word hast]} {
						return "h4" 
					}
					set wordlist2 [list hai hay]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "h4" 
					}
					set wordlist1 [list harass]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ha" 
					}
					set wordlist2 [list harr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ha" 
					}
					set wordlist2 [list har half halv]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hA" 
					}
					set wordlist2 [list hall hau]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hO" 
					}
					set wordlist2 [list halt]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ho" 
					}
					return "ha" 
				}
				"he" {
					set wordlist2 [list heart]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hA" 
					}
					set wordlist1 [list hearse]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "h:" 
					}
					set wordlist1 [list healthy heather heavy]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "he" 
					}
					set wordlist2 [list hered heres heret herr heaven heavi head herald]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "he" 
					}
					set wordlist1 [list here hero]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "hi." 
					}
					set wordlist2 [list hear]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hi." 
					}
					set wordlist1 [list hebrew he hed hes]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "hI" 
					}
					set wordlist2 [list hea hee]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hI" 
					}
					set wordlist2 [list heir]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "E" 
					}
					set wordlist2 [list heif]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "he" 
					}
					set wordlist2 [list height]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hai" 
					}
					set wordlist2 [list her]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "h:" 
					}
					set wordlist2 [list hew]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hiU" 
					}
					set wordlist1 [list hey]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "h4" 
					}
					return "he" 
				}
				"hi" {
					set wordlist1 [list hindrance]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "hi" 
					}
					set wordlist2 [list hideous hinder hindu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hi" 
					}
					set wordlist1 [list hi hiatus hifi]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "hai" 
					}
					if {[UniversalEing $word hi]} {
						return "hai" 
					}
					set wordlist2 [list hind high hijack]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hai" 
					}
					return "hi" 
				}
				"ho" {
					set wordlist2 [list honest honor honour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "on" 
					}
					set wordlist1 [list hors]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "O" 
					}
					set wordlist2 [list hour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "aU." 
					}
					set wordlist2 [list hoar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hO" 
					}
					set wordlist2 [list honey]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hu" 
					}
					set wordlist1 [list holy holiness holster host hostess hotel]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "h@" 
					}
					if {[UniversalEing $word ho]} {
						return "h@" 
					}
					set wordlist2 [list hoa hoe hosier]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "h@" 
					}
					set wordlist2 [list hoi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hoi" 
					}
					set wordlist1 [list hood hooded hooding]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "hu" 
					}
					set wordlist2 [list hoodw]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hu" 
					}
					set wordlist2 [list hoo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hU" 
					}
					set wordlist2 [list horo horr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ho" 
					}
					set wordlist2 [list hor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hO" 
					}
					set wordlist2 [list hou how]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "haU" 
					}
					return "ho" 
				}
				"hu" {
					set wordlist1 [list hue]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "hiU" 
					}
					if {[UniversalEing $word hu]} {
						return "hiU" 
					}
					set wordlist2 [list human humid humil humo humu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hiU" 
					}
					set wordlist1 [list hurrah hurray]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "h." 
					}
					set wordlist2 [list hurr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hu" 
					}
					set wordlist2 [list hur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "h:" 
					}
					return "hu" 
				}
				"hy" {
					set wordlist2 [list hya hyb hyd hypoth hyper hypo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "hai" 
					}
					return "hi" 
				}
			}
		}
		"i" {
			set wordlist1 [list im irate ireland iron]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "ai" 
			}
			set wordlist2 [list iris]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "ai" 
			}
			set wordlist1 [list is isnt]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "i" 
			}
			set wordlist2 [list ille illi illn illo illu im in ir islam israel iss isth ital itin its idio ig]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "i" 
			}
			set wordlist2 [list inter]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "int."
			}
			return "ai" 
		}
		"j" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ja" {
					if {[UniversalEing $word ja]} {
						return "j4" 
					}
					set wordlist2 [list jai jay]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "j4" 
					}
					set wordlist2 [list jar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jA" 
					}
					set wordlist1 [list japan japaning]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "j." 
					}
					set wordlist2 [list jamaica]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "j." 
					}
					set wordlist2 [list jau jaw]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jO" 
					}
					return "ja" 
				}
				"je" {
					set wordlist2 [list jealous]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "je" 
					}
					set wordlist2 [list jeer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ji." 
					}
					set wordlist1 [list jesus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "jI" 
					}
					set wordlist2 [list jea jee]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jI" 
					}
					set wordlist2 [list jer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "j:" 
					}
					set wordlist2 [list jew]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jU" 
					}
					return "je" 
				}
				"ji" {
					if {[UniversalEing $word ji]} {
						return "jai"
					}
					return "ji" 
				}
				"jo" {
					set wordlist2 [list joi joy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "joi" 
					}
					set wordlist1 [list jolt]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "j@" 
					}
					if {[UniversalEing $word jo]} {
						return "j@" 
					}
					set wordlist2 [list jovial]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "j@" 
					}
					set wordlist2 [list jor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jO" 
					}
					set wordlist2 [list jour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "j:" 
					}
					return "jo" 
				}
				"ju" {
					set wordlist2 [list jury]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jO" 
					}
					set wordlist1 [list judo july junior]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "jU" 
					}
					if {[UniversalEing $word ju]} {
						return "jU" 
					}
					set wordlist2 [list juv jub judi jui jur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "jU" 
					}
					return "ju" 
				}
			}
		}
		"k" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ka" {
					return "ka" 
				}
				"ke" {
					set wordlist1 [list kebab]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ki" 
					}
					set wordlist2 [list kee key]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kI" 
					}
					set wordlist1 [list kerosene]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ke" 
					}
					set wordlist2 [list ker]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "k:" 
					}
					return "ke" 
				}
				"kh" {
					return "kA" 
				}
				"ki" {
					set wordlist1 [list kindred kin]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ki" 
					}
					if {[SpecificEing $word kindl]} {
						return "ki" 
					}
					set wordlist2 [list kinderg]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ki" 
					}
					if {[UniversalEing $word ki]} {
						return "kai" 
					}
					set wordlist2 [list kind]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kai" 
					}
					return "ki" 
				}
				"kn" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
						switch -- $rhymestr {
						"kna" {
							return "na" 
						}
						"kne" {
							set wordlist1 [list knew]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "niU" 
							}
							set wordlist2 [list knee knea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "nI" 
							}
							return "ne" 
						}
						"kni" {
							if {[UniversalEing $word kni]} {
								return "nai" 
							}
							set wordlist2 [list knight]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "nai" 
							}
							return "ni" 
						}
						"kno" {
							set wordlist1 [list know known]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "n@" 
							}
							return "no" 
						}
						"knu" {
							return "nu" 
						}
					}
				}
				"ko" {
					set wordlist1 [list kosher]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "k@" 
					}
					return "k." 
				}
			}
		}
		"l" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"la" {
					set wordlist2 [list lamenta laryn lateral laugh]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "la" 
					}
					set wordlist1 [list lapel laggon lament]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "l." 
					}
					set wordlist2 [list labor lascivi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "l." 
					}
					set wordlist1 [list lager]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lA" 
					}
					set wordlist2 [list lar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lA" 
					}
					set wordlist1 [list lawyer]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lo" 
					}
					set wordlist2 [list laur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lo" 
					}
					set wordlist2 [list lau law]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lO" 
					}
					set wordlist2 [list lair]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lE" 
					}
					set wordlist1 [list lathe]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "l4" 
					}
					if {[UniversalEing $word la]} {
						return "l4" 
					}
					if {[SpecificEing $word ladl]} {
						return "l4" 
					}
					set wordlist2 [list labour lay laz]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "l4" 
					}
					return "la" 
				}
				"le" {
					set wordlist2 [list leer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "li." 
					}
					set wordlist2 [list learn]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "l:" 
					}
					set wordlist1 [list legality]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "li" 
					}
					set wordlist1 [list leper]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "le" 
					}
					set wordlist2 [list leather legend level]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "le" 
					}
					set wordlist1 [list leo lethal]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lI" 
					}
					if {[UniversalEing $word le]} {
						return "lI" 
					}
					set wordlist2 [list lenient lea lee legal]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lI" 
					}
					set wordlist2 [list leu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lU" 
					}
					set wordlist2 [list lew]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "liU" 
					}
					return "le" 
				}
				"li" {
					set wordlist1 [list libra litre]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lI" 
					}
					set wordlist2 [list liais liber linear liver]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "li" 
					}
					set wordlist1 [list lia lie lier lichen lido lilac lino]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lai" 
					}
					if {[UniversalEing $word li]} {
						return "lai" 
					}
					set wordlist2 [list lithe libr light]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lai" 
					}
					set wordlist1 [list lieut]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "le" 
					}
					set wordlist1 [list lieu]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "liU" 
					}
					set wordlist1 [list lingerie]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lA" 
					}
					return "li" 
				}
				"lo" {
					set wordlist1 [list london]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lu" 
					}
					set wordlist2 [list lov look]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lu" 
					}
					set wordlist2 [list lorr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lo" 
					}
					set wordlist2 [list lor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lO" 
					}
					set wordlist1 [list louvre]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lU" 
					}
					if {[SpecificEing $word los]} {
						return "lU" 
					}
					set wordlist2 [list loo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lU" 
					}
					set wordlist2 [list lou]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "laU" 
					}
					set wordlist2 [list loi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "loi" 
					}
					set wordlist1 [list logo lotion]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "l@" 
					}
					if {[UniversalEing $word lo]} {
						return "l@" 
					}
					set wordlist2 [list loca loco locu loa low]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "l@" 
					}
					return "lo" 
				}
				"lu" {
					set wordlist1 [list lurid]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "liO" 
					}
					if {[SpecificEing $word lur]} {
						return "liO" 
					}
					if {[UniversalEing $word lu]} {
						return "lU" 
					}
					set wordlist2 [list luna lubr luci lucr ludi lumi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "lU" 
					}
					set wordlist2 [list lur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "l:" 
					}
					return "lu" 
				}
				"ly" {
					set wordlist1 [list lying]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "lai"
					}
					return "li" 
				}
			}
		}
		"m" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ma" {
					set wordlist1 [list mare]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "mE" 
					}
					set wordlist2 [list mayor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mE" 
					}
					set wordlist1 [list madeira madrid majestic majority mature maniacal manure marina]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "m." 
					}
					set wordlist2 [list matricu material matern machine malarai malay malev malicious malig maniaca manoeuvr manipu maraud maroon]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "m." 
					}
					set wordlist1 [list marathon majesty]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ma" 
					}
					set wordlist2 [list mari marr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ma" 
					}
					set wordlist2 [list mar master]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mA" 
					}
					set wordlist1 [list major mania matrix matrices matron]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "m4" 
					}
					if {[UniversalEing $word ma]} {
						return "m4" 
					}
					set wordlist2 [list mai mason maple may]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "m4" 
					}
					set wordlist1 [list malt malta maltese]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "mo" 
					}
					set wordlist1 [list many]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "me" 
					}
					set wordlist2 [list mau]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mO" 
					}
					return "ma" 
				}
				"me" {
					set wordlist1 [list memento memorial menagier meringue]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "m." 
					}
					set wordlist2 [list mechanic]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "m." 
					}
					set wordlist2 [list meander]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mIa" 
					}
					set wordlist2 [list mere]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mi." 
					}
					set wordlist1 [list merry meant]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "me" 
					}
					set wordlist2 [list merri meadow measur merit]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "me" 
					}
					set wordlist2 [list mer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "m:" 
					}
					set wordlist2 [list mew]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "miU" 
					}
					set wordlist1 [list me medium menial]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "mI" 
					}
					if {[UniversalEing $word me]} {
						return "mI" 
					}
					set wordlist2 [list mea media mee metre meno]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mI" 
					}
					return "me" 
				}
				"mi" {
					set wordlist1 [list migraine]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "mI" 
					}
					set wordlist2 [list mineral miserabl mirr mildew]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mi" 
					}
					set wordlist2 [list mir]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "m:" 
					}
					set wordlist1 [list milometer minus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "mai" 
					}
					if {[UniversalEing $word mi]} {
						return "mai" 
					}
					set wordlist2 [list mild mind minor micro might migr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mai" 
					}
					return "mi" 
				}
				"mo" {
					set wordlist2 [list mov]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mU" 
					}
					set wordlist1 [list monday moslem]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "mu" 
					}
					set wordlist2 [list month moustach money monk mother]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mu" 
					}
					set wordlist1 [list monopoly monotony monotonous morality morass molasses momentum monastic morocco]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "m." 
					}
					set wordlist2 [list molest moros monopoli]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "m." 
					}
					set wordlist2 [list model moder modest moral mori]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mo" 
					}
					set wordlist2 [list moor mor more mour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mO" 
					}
					set wordlist1 [list mogul mohair molar mosaic]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "m@" 
					}
					if {[UniversalEing $word mo]} {
						return "m@" 
					}
					set wordlist2 [list mobil mow moult mould mobili moa]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "m@" 
					}
					set wordlist2 [list moi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "moi" 
					}
					set wordlist1 [list mousse]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "mU" 
					}
					set wordlist2 [list moo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mU" 
					}
					return "mo" 
				}
				"mu" {
					set wordlist1 [list mucus music]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "miU" 
					}
					if {[UniversalEing $word mu]} {
						return "miU" 
					}
					set wordlist2 [list muti muta]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "miU" 
					}
					set wordlist1 [list mural]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "miO" 
					}
					set wordlist2 [list mur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "m:" 
					}
					return "mu" 
				}
				"my" {
					set wordlist1 [list my myself]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "mai" 
					}
					set wordlist2 [list myopic]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "mai" 
					}
					return "mi" 
				}
			}
		}
		"n" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"na" {
					set wordlist1 [list naive]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "nai" 
					}
					set wordlist1 [list native nato nature naval navy]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "n4" 
					}
					if {[UniversalEing $word na]} {
						return "n4" 
					}
					set wordlist2 [list nai]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "n4" 
					}
					set wordlist1 [list nativity namibia]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "n." 
					}
					set wordlist2 [list narr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "na" 
					}
					set wordlist1 [list nazi]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "nA" 
					}
					set wordlist2 [list nar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nA" 
					}
					set wordlist2 [list nau]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nO" 
					}
					return "na" 
				}
				"ne" {
					set wordlist1 [list nee	]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "n4" 
					}
						set wordlist2 [list neigh]
						if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "n4" 
					}
					set wordlist2 [list near]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ni." 
					}
					set wordlist2 [list neith]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nai" 
					}
					set wordlist2 [list ner]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "n:" 
					}
					set wordlist2 [list neu new]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "niU" 
					}
					set wordlist1 [list negro neon]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "nI" 
					}
					set wordlist2 [list nea nee]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nI" 
					}
					set wordlist2 [list neglect negotiat]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ni" 
					}
					return "ne" 
				}
				"ni" {
					set wordlist2 [list nie]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nI" 
					}
					set wordlist1 [list ninth]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "nai" 
					}
					if {[UniversalEing $word ni]} {
						return "nai" 
					}
					set wordlist2 [list nigh nitro]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nai" 
					}
					return "ni" 
				}
				"no" {
					set wordlist1 [list no nosy nowhere noone]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "n@" 
					}
					if {[UniversalEing $word no]} {
						return "n@" 
					}
					set wordlist2 [list nob nota not noto]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "n@" 
					}
					set wordlist1 [list nook]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "nu" 
					}
					set wordlist2 [list nourish]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nu" 
					}
					set wordlist2 [list noo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nU" 
					}
					set wordlist2 [list noi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "noi" 
					}
					set wordlist2 [list nou now]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "naU" 
					}
					return "no" 
				}
				"nu" {
					set wordlist2 [list nutr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "niU" 
					}
					set wordlist2 [list nut nudg null numb nun]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "nu" 
					}
					set wordlist2 [list nur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "n:" 
					}
					return "niU" 
				}
				"ny" {
					return "nai"
				}
			}
		}
		"o" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"oa" {
					set wordlist2 [list oas]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "@4" 
					}
					set wordlist2 [list oar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "O" 
					}
					return "@" 
				}
				"ob" {
					if {[SpecificEing $word oblig]} {
						return ".b"  
					}
					set wordlist2 [list oblit obe]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return ".b"  
					}
					return "ob" 
				}
				"oc" {
					set wordlist1 [list oclock]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return ".c" 
					}
					set wordlist2 [list occas occur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return ".c" 
					}
					set wordlist2 [list ocean]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "@S" 
					}
					return "oc" 
				}
				"od" {
					set wordlist2 [list odd]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "od" 
					}
					return "@d" 
				}
				"of" {
					set wordlist2 [list offer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "of" 
					}
					set wordlist1 [list ommission]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return ".f" 
					}
					set wordlist2 [list offe offici	]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return ".f" 
					}
					set wordlist1 [list of]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ov" 
					}
					return "of" 
				}
				"og" {
					return "og" 
				}
				"oh" {
					return "@" 
				}
				"oi" {
					return "oi" 
				}
				"ok" {
					return "@k4" 
				}
				"ol" {
					set wordlist2 [list old]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "@l" 
					}
					set wordlist1 [list olympic]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return ".l" 
					}
					return "ol" 
				}
				"om" {
					set wordlist1 [list omelette]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "om" 
					}
					set wordlist2 [list ominous]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "om" 
					}
					return "@m" 
				}
				"on" {
					set wordlist1 [list onion]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "un" 
					}
					set wordlist1 [list only onus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "@n" 
					}
					set wordlist2 [list oner]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "@n" 
					}
					set wordlist2 [list one]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Uun" 
					}
					return "on" 
				}
				"op" {
					if {[SpecificEing $word opin]} {
						return "@p" 
					}
					set wordlist2 [list opaq open]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "@p" 
					}
					set wordlist1 [list opponent]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return ".p" 
					}
					set wordlist2 [list opinion]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return ".p" 
					}
					return "op" 
				}
				"or" {
					set wordlist2 [list orang orat]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "o" 
					}
					return "O" 
				}
				"os" {
					return "os" 
				}
				"ot" {
					set wordlist2 [list other]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "u7" 
					}
					return "ot" 
				}
				"ou" {
					set wordlist2 [list ough]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "O" 
					}
					set wordlist2 [list out]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "aUt" 
					}
					return "aU" 
				}
				"ov" {
					set wordlist2 [list oven]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "uv" 
					}
					set wordlist2 [list over]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "@v." 
					}
					return "@v" 
				}
				"ow" {
					set wordlist1 [list owl]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "aU" 
					}
					set wordlist2 [list own]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "@n" 
					}
					return "@" 
				}
				"ox" {
					return "oks"
				}
				"oy" {
					return "oi" 
				}
			}
		}
		"p" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"pa" {
					set wordlist1 [list pacific palatial paralysis parameter parole pathology]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "p." 
					}
					if {[SpecificEing $word parad]} {
						return "p." 
					}
					set wordlist2 [list patern pathetic patrol pavillion parochial particular]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p." 
					}
					set wordlist2 [list parent pair]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pE" 
					}
					set wordlist2 [list pae]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pI" 
					}
					set wordlist2 [list parr pageant palestin palette panel para pari]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pa" 
					}
					set wordlist2 [list par palm]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pA" 
					}
					set wordlist2 [list pau paw pall]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pO" 
					}
					set wordlist1 [list paltry]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "po" 
					}
					set wordlist2 [list paltri]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "po" 
					}
					set wordlist1 [list pathos patron]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "p4" 
					}
					if {[UniversalEing $word pa]} {
						return "p4" 
					}
					if {[SpecificEing $word past]} {
						return "p4" 
					}
					set wordlist2 [list pastry patien pay pai]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p4" 
					}
					return "pa" 
				}
				"pe" {
					set wordlist2 [list peer period]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pi." 
					}
					set wordlist2 [list pear]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pE" 
					}
					set wordlist2 [list peasant peril]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pe" 
					}
					set wordlist1 [list peking]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "pI" 
					}
					set wordlist2 [list pea pedia pee penal peo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pI" 
					}
					set wordlist2 [list peculiar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pi" 
					}
					set wordlist1 [list peremptory petroleum]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "p." 
					}
					if {[SpecificEing $word perspir]} {
						return "p." 
					}
					set wordlist2 [list periph permis pernic perpet perpl persist perspec persua pertain pertur perus perva pervers perverti petit perce percus perennial perform perfunc]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p." 
					}
					set wordlist2 [list per]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p:" 
					}
					set wordlist2 [list pew]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "piU" 
					}
					return "pe" 
				}
				"ph" {
					set wordlist2 [list phar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fA" 
					}
					set wordlist2 [list pheas]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fe" 
					}
					set wordlist2 [list phen phonetic]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f." 
					}
					set wordlist2 [list phi phy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fi" 
					}
					if {[UniversalEing $word pha]} {
						return "f4" 
					}
					set wordlist2 [list pho]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "f@" 
					}
					set wordlist2 [list phle]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "fle" 
					}
					if {[UniversalEing $word phra]} {
						return "fr4" 
					}
				}
				"pi" {
					set wordlist2 [list piteous]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pi" 
					}
					set wordlist1 [list piano]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "pia" 
					}
					set wordlist1 [list pianist]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "pi." 
					}
					set wordlist1 [list piety]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "pai" 
					}
					set wordlist2 [list pious]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pai" 
					}
					set wordlist1 [list pizza]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "pI" 
					}
					set wordlist2 [list piec piq]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pI" 
					}
					set wordlist1 [list pint pisces]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "pai" 
					}
					set wordlist2 [list pie]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pai" 
					}
					if {[UniversalEing $word pi]} {
						return "pai" 
					}
					set wordlist2 [list pirate pilot pio]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pai" 
					}
					return "pi" 
				}
				"pl" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"pla" {
							set wordlist2 [list planet plateau]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "pla" 
							}
							if {[UniversalEing $word pla]} {
								return "pl4" 
							}
							set wordlist2 [list pla play plagu]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "pl4" 
							}
							set wordlist1 [list platoon]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "pl." 
							}
							set wordlist2 [list placat]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "pl." 
							}
							
							set wordlist2 [list plau]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "plO" 
							}
							return "pla" 
						}
						"ple" {
							set wordlist2 [list pleasur]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ple" 
							}
							set wordlist2 [list plea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "plI" 
							}
							set wordlist2 [list pleu]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "plU" 
							}
							return "ple" 
						}
						"pli" {
							set wordlist2 [list plia plie pligh]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "plai" 
							}
							return "pli" 
						}
						"plo" {
							set wordlist2 [list plough]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "plaU" 
							}
							set wordlist1 [list ploy]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ploi" 
							}
							return "plo" 
						}
						"plu" {
							set wordlist2 [list plural]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "plO" 
							}
							set wordlist1 [list plumage pluperfect]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "plU" 
							}
							if {[UniversalEing $word plu]} {
								return "plU" 
							}
							return "plu" 
						}
						"ply" {
							return "plai"
						}
					}
				}
				"pn" {
					return "niU" 
				}
				"po" {
					set wordlist1 [list poet]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "p@i" 
					}
					set wordlist2 [list poete]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p@i" 
					}
					set wordlist2 [list poeti]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p@e" 
					}
					set wordlist2 [list posthumous postu porr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "po" 
					}
					set wordlist1 [list potato]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "p." 
					}
					set wordlist2 [list police polici polite pollut position possess potential]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p." 
					}
					set wordlist1 [list poem]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "poi" 
					}
					set wordlist2 [list poi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "poi" 
					}
					set wordlist1 [list poky poland polish poll polling polled polo pony posy potion poultry]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "p@" 
					}
					if {[UniversalEing $word po]} {
						return "p@" 
					}
					set wordlist2 [list polio polar post poa]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p@" 
					}
					set wordlist2 [list poor por pour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pO" 
					}
					set wordlist1 [list pouffe]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "pU" 
					}
					set wordlist2 [list poo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pU" 
					}
					set wordlist2 [list pou pow]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "paU" 
					}
					return "po" 
				}
				"pr" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"pra" {
							set wordlist2 [list prair prayer]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "prE" 
							}
							set wordlist2 [list prai pray]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "pr4" 
							}
							set wordlist1 [list praw]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "prO" 
							}

							return "pra" 
						}
						"pre" {
							if {[SpecificEing $word prey]} {
								return "pr4" 
							}
							set wordlist2 [list preambl]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "prIa" 
							}
							set wordlist2 [list prejudg]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "prI" 
							}
							set wordlist1 [list precipice predation premise prep preparation preposition prestige preservation]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "pre" 
							}
							set wordlist2 [list prevalent presbyterian presence president press prevalent precious predator preface preg prej prelu premature premier premoni]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "pre" 
							}
							set wordlist1 [list precept precinct predecessor premium prerequisite preschool pretext]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "prI" 
							}
							set wordlist2 [list preh prefab preoccup presuppos previ prew prea preconceiv precondition premari predesti pree]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "prI" 
							}
							return "pri" 
						}
						"pri" {
							set wordlist1 [list privet]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "pri" 
							}
							set wordlist2 [list prie]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "prI" 
							}
							set wordlist1 [list primus]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "prai" 
							}
							if {[UniversalEing $word pri]} {
								return "prai" 
							}
							set wordlist2 [list prior private primar]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "prai" 
							}
							return "pri" 
						}
						"pro" {
							set wordlist1 [list product prodcutivity produce properb]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "pro" 
							}
							set wordlist1 [list protest project progress pronoun prohibition pro]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "pr@" 
							}
							set wordlist2 [list prolog profil procreat prolonga]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "pr@" 
							}
							set wordlist1 [list protestant proverb]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "pro" 
							}
							set wordlist2 [list proverbi]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "pr." 
							}
							if {[SpecificEing $word prov]} {
								return "prU" 
							}
							set wordlist1 [list proceed proposal]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "pr." 
							}
							set wordlist2 [list propose proposing provincial propri protagonist protect protest protru provid provis provocative provok probation procedur procession proclaim procras procur prodigious produc profan profess profic profound profus prohibit proj proverb prolific prolong promot pronounc pronunc propel propen proportional]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "pr." 
							}
							if {[UniversalEing $word pro]} {
								return "pr@" 
							}
							set wordlist2 [list prou prow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "praU" 
							}
							return "pro" 
						}
						"pru" {
							return "prU" 
						}
					}
				}
				"ps" {
					set wordlist2 [list pseu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "siU" 
					}
					set wordlist2 [list psy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sai" 
					}
				}
				"pu" {
					set wordlist1 [list puny putrid]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "piI" 
					}
					if {[UniversalEing $word pu]} {
						return "piI" 
					}
					set wordlist2 [list putref puri pupil]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "piI" 
					}
					set wordlist1 [list pursue]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "p." 
					}
					set wordlist2 [list pur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "p:" 
					}
					return "pu" 
				}
				"py" {
					set wordlist1 [list pyjamas]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "p." 
					}
					set wordlist2 [list pyramid pyrr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "pi" 
					}
					return "pai" 
				}
			}
		}
		"q" {
			incr k
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			switch -- $rhymestr {
				"qua" {
					set wordlist2 [list quack]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kUa" 
					}
					set wordlist1 [list qualm]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "kuA" 
					}
					set wordlist2 [list quasi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kuA" 
					}
					if {[UniversalEing $word qua]} {
						return "ku4" 
					}
					set wordlist2 [list quav quai]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ku4" 
					}
					set wordlist2 [list quay]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kI" 
					}
					return "kUo" 
				}
				"que" {
					set wordlist2 [list queer query queri]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kUi." 
					}
					set wordlist2 [list quea quee]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kUI" 
					}
					set wordlist2 [list queu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kiU" 
					}
					return "kUe" 
				}
				"qui" {
					set wordlist1 [list quite]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "kUai" 
					}
					set wordlist2 [list quiet]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kUai" 
					}
					set wordlist2 [list quir]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kU:" 
					}
					return "kUi" 
				}
				"quo" {
					set wordlist2 [list quor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kUO" 
					}
					set wordlist2 [list quod]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "kUo" 
					}
					return "kU@" 
				}
			}
		}
		"r" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ra" {
					set wordlist2 [list rari rare]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rE" 
					}
					set wordlist1 [list raccoon racoon]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ra" 
					}
					set wordlist2 [list ravenous]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ra" 
					}
					set wordlist1 [list rabies radar radii radius rakish rapist ratio]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "r4" 
					}
					if {[UniversalEing $word ra]} {
						return "r4" 
					}
					if {[SpecificEing $word rang]} {
						return "r4" 
					}
					set wordlist2 [list radio ray razor rai raci radia]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "r4" 
					}
					set wordlist2 [list rau raw]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rO" 
					}
					return "ra" 
				}
				"re" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"rea" {
							set wordlist2 [list reapp]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rI." 
							}
							set wordlist1 [list realm readily ready readiness]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "re" 
							}
							set wordlist1 [list reading read]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rI" 
							}
							set wordlist2 [list reap reason reach]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rI" 
							}
							set wordlist2 [list reage]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ri4" 
							}
							set wordlist2 [list rearm]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "riA" 
							}
							set wordlist1 [list reality]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ria" 
							}
							set wordlist2 [list react]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ria" 
							}
							set wordlist1 [list real really realtor rear rearguard]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ri." 
							}
							set wordlist2 [list reass realis]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ri." 
							}
							return "rI." 
						}
						"reb" {
							set wordlist2 [list rebirth rebuild rebate]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIb" 
							}
							return "rib" 
						}
						"rec" {
							set wordlist2 [list rech]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "riC" 
							}
							set wordlist2 [list reconsider reconstruct reconnect recap recent recreat recondition]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIc" 
							}
							set wordlist1 [list recipe recognition recognize]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rec" 
							}
							set wordlist2 [list recoll recon rect reck reclama recom]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rec" 
							}
							return "ric" 
						}
						"red" {
							set wordlist1 [list red redskin]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "red" 
							}
							set wordlist2 [list redh redolent]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "red" 
							}
							set wordlist1 [list redo redone redoing]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rId" 
							}
							set wordlist2 [list redeploy redirect redoubl redoing]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rId" 
							}
							return "rid" 
						}
						"ref" {
							set wordlist1 [list ref]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ref" 
							}
							set wordlist2 [list referenc referent referend refug referr reformation]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ref" 
							}
							set wordlist1 [list reflex reflexed refund]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rIf" 
							}
							set wordlist2 [list refuel refill]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIf" 
							}
							return "rif" 
						}
						"reg" {
							set wordlist1 [list regal]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rIg" 
							}
							set wordlist2 [list region regroup]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIj" 
							}
							set wordlist1 [list regime]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "r4Z" 
							}
							set wordlist2 [list regis regimen]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rej" 
							}
							set wordlist2 [list regu]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "reg" 
							}
							return "rig" 
						}
						"reh" {
							return "rI" 
						}
						"rei" {
							set wordlist2 [list rein reign]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "r4" 
							}
							return "rIi" 
						}
						"rej" {
							return "rij" 
						}
						"rek" {
							return "rIk" 
						}
						"rel" {
							set wordlist2 [list relay relocat]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIl" 
							}
							set wordlist2 [list relish relativ relegat relevan relic]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rel" 
							}
							return "ril" 
						}
						"rem" {
							set wordlist1 [list remit]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rIm" 
							}
							set wordlist2 [list remould remaster remarry]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIm" 
							}
							set wordlist2 [list remini remn remonstr]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rem" 
							}
							return "rim" 
						}
						"ren" {
							set wordlist1 [list rendezvous]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rOn" 
							}
							set wordlist2 [list rend renovat rent]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ren" 
							}
							return "rin" 
						}
						"reo" {
							return "rIO" 
						}
						"rep" {
							set wordlist1 [list repartee rep repetition]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rep" 
							}
							set wordlist2 [list reporta reptil reput reprimand represent reprehens replic]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rep" 
							}
							set wordlist2 [list reprint reproduc reprecuss repatriat replay]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIp" 
							}
							return "rip" 
						}
						"req" {
							set wordlist2 [list requis]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rek" 
							}
							return "rik" 
						}
						"rer" {
							return "rI " 
						}
						"res" {
							set wordlist2 [list resh]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIS" 
							}
							set wordlist1 [list resale]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rIs" 
							}
							set wordlist2 [list restructur]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIs" 
							}
							set wordlist2 [list restor restrain restrict]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ris" 
							}
							set wordlist1 [list residue resin]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rez" 
							}
							set wordlist2 [list resolu resona ressurec reserva residen]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rez" 
							}
							set wordlist2 [list respira rescu rest]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "res" 
							}
							set wordlist1 [list respire]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ris" 
							}
							set wordlist2 [list respect respon resurg resusc restor research rescind resplendent]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ris" 
							}
							return "riz" 
						}
						"ret" {
							set wordlist2 [list retread retrain retail retell retill]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIt" 
							}
							set wordlist1 [list retinue]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ret" 
							}
							set wordlist2 [list reticent retro retribut retina]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ret" 
							}
							set wordlist1 [list retch]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "reC" 
							}
							return "rit" 
						}
						"reu" {
							return "rIU" 
						}
						"rev" {
							set wordlist2 [list revamp revital]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rIv" 
							}
							set wordlist1 [list rev revenue]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "rev" 
							}
							set wordlist2 [list reveren revel reverie revolution]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rev" 
							}
							return "riv" 
						}
						"rew" {
							if {[SpecificEing $word rewir]} {
								return "rIUai." 
							}
							set wordlist2 [list rewr]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rI" 
							}
							set wordlist2 [list reword]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "riU:" 
							}
						}
					}
				}
				"rh" {
					set wordlist2 [list rhythm]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ri" 
					}
					set wordlist2 [list rheu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rU" 
					}
					set wordlist2 [list rhi rhy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rai" 
					}

					set wordlist1 [list rhonda]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ro" 
					}
					set wordlist2 [list rho]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "r@" 
					}
					set wordlist2 [list rhu]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rU" 
					}
				}
				"ri" {
					set wordlist2 [list river rivet]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "riv" 
					}
					set wordlist2 [list ring]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "riN" 
					}
					if {[UniversalEing $word ri]} {
						return "rai" 
					}
					set wordlist2 [list right riot rival]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rai" 
					}
					return "ri" 
				}
				"ro" {
					set wordlist2 [list roar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rO" 
					}
					set wordlist2 [list romania]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rU" 
					}
					set wordlist1 [list roe rosary rosy rotary rotund]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "r@" 
					}
					if {[UniversalEing $word ra]} {
						return "r@" 
					}
					set wordlist2 [list row roa rogu robot roll roman rota]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "r@" 
					}
					set wordlist2 [list round rous]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "raU" 
					}
					set wordlist2 [list rook rough]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ru" 
					}
					set wordlist2 [list roo rou]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rU" 
					}
					set wordlist2 [list roy roi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "roi" 
					}
					return "ro" 
				}
				"ru" {
					set wordlist1 [list rural]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "rU" 
					}
					if {[UniversalEing $word ru]} {
						return "rU" 
					}
					set wordlist2 [list ruthless rudiment rue ruin rubi rumour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "rU" 
					}
					return "ru" 
				}
				"ry" {
					return "rai"
				}
			}
		}
		"s" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"sa" {
					set wordlist2 [list saluta]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sa" 
					}
					set wordlist1 [list sadistic salami saloon satanic]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "s." 
					}
					set wordlist2 [list sahara saliva salut]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s." 
					}
					set wordlist1 [list said]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "se" 
					}
					set wordlist1 [list satan saviour]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "s4" 
					}
					if {[UniversalEing $word sa]} {
						return "s4" 
					}
					set wordlist2 [list sai say salient]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s4" 
					}
					set wordlist2 [list salt]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "so" 
					}
					set wordlist2 [list sar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sA" 
					}
					set wordlist2 [list saud]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "saU" 
					}
					set wordlist2 [list sausage]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "so" 
					}
					set wordlist2 [list sau saw]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sO" 
					}
					return "sa" 
				}
				"sc" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"sca" {
							set wordlist2 [list scaveng]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ska" 
							}
							set wordlist2 [list scald]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sko" 
							}
							set wordlist1 [list scary]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "skE" 
							}
							if {[SpecificEing $word scar]} {
								return "skE" 
							}
							set wordlist2 [list scar]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skA" 
							}
							if {[UniversalEing $word sca]} {
								return "sk4" 
							}
							if {[SpecificEing $word scath]} {
								return "sk4" 
							}
							return "ska" 
						}
						"sce" {
							set wordlist1 [list scenario]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "s." 
							}
							set wordlist1 [list scene]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sI" 
							}
							set wordlist2 [list sceni]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sI" 
							}
							set wordlist2 [list scent sceptr]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "se" 
							}
							return "ske" 
						}
						"sch" {
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"sche" {
									set wordlist2 [list schedul]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "Se" 
									}
									set wordlist1 [list scheme schema]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "skI" 
									}
									set wordlist2 [list schem]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "ski" 
									}
								}
								"scho" {
									set wordlist2 [list schoo]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "skU" 
									}
									return "sko" 
								}
							}
						}
						"sci" {
							set wordlist2 [list scien]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sai" 
							}
							return "si" 
						}
						"sco" {
							set wordlist2 [list scor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skO" 
							}
							
							set wordlist2 [list scoo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skU" 
							}
						
							set wordlist2 [list scourg]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sk:" 
							}
							set wordlist2 [list scou scow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skaU" 
							}
							if {[UniversalEing $word sco]} {
								return "sk@" 
							}
							set wordlist2 [list scold]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sk@" 
							}
							return "sko" 
						}
						"scr" {
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"scra" {
									if {[UniversalEing $word scra]} {
										return "skr4" 
									}
									set wordlist2 [list scraw]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "skrO" 
									}
									return "skra" 
								}
								"scre" {
									set wordlist2 [list scree screa]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "skrI" 
									}
									set wordlist2 [list screw]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "skrU" 
									}
								}
								"scri" {
									return "skri" 
								}
								"scro" {
									set wordlist2 [list scrou]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "skraU" 
									}
									return "skr@" 
								}
								"scru" {
									set wordlist2 [list scrup scrut]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "skrU" 
									}
									return "skru" 
								}
							}
						}
						"scu" {
							return "sku" 
						}
						"scy" {
							return "sai" 
						}
					}
				}
				"se" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"sea" {
							set wordlist2 [list sear]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "si." 
							}
							return "sI" 
						}
						"seb" {
							return "s." 
						}
						"sec" {
							set wordlist2 [list second secreta sect secular]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sek" 
							}
							set wordlist1 [list secretion]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sik" 
							}
							if {[SpecificEing $word secret]} {
								return "sik" 
							}
							set wordlist2 [list secret]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sIk" 
							}
							return "sik" 
						}
						"sed" {
							set wordlist1 [list sedative sedentary]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sed" 
							}
							set wordlist2 [list sediment]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sed" 
							}
							return "sid" 
						}
						"see" {
							return "sI" 
						}
						"seg" {
							return "seg" 
						}
						"seI" {
							return "sI" 
						}
						"sel" {
							set wordlist2 [list select]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sil" 
							}
							return "sel" 
						}
						"sem" {
							set wordlist1 [list semen]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sIm" 
							}
							return "sem" 
						}
						"sen" {
							set wordlist2 [list senior]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sIn" 
							}
							return "sen" 
						}
						"sep" {
							return "sep" 
						}
						"seq" {
							set wordlist2 [list sequential]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sik" 
							}
							return "sIk" 
						}
						"ser" {
							set wordlist2 [list seren serrat]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "s." 
							}
							set wordlist1 [list sergeant]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sA" 
							}
							set wordlist1 [list series]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "si." 
							}
							set wordlist2 [list serious serial]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "si." 
							}
							set wordlist2 [list ser]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "s:" 
							}
						}
						"ses" {
							set wordlist1 [list sessile]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ses" 
							}
							return "seS" 
						}
						"set" {
							set wordlist1 [list settee]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "s.t" 
							}
							return "set" 
						}
						"sev" {
							set wordlist2 [list severe]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "siv" 
							}
							return "sev" 
						}
						"sew" {
							set wordlist1 [list sew sewn sewing sewed]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "s@" 
							}
							return "siU" 
						}
						"sex" {
							return "seks"
						}
					}
				}
				"sh" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"sha" {
							if {[SpecificEing $word shar]} {
								return "SE" 
							}
							if {[UniversalEing $word sha]} {
								return "S4" 
							}
							set wordlist1 [list shant]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "SA" 
							}
							set wordlist2 [list shar]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "SA" 
							}
							set wordlist2 [list shaw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "SO" 
							}
								return "Sa" 
						}
						"she" {
							set wordlist2 [list sheer shear]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Si." 
							}
							set wordlist1 [list she shes]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "SI" 
							}
							set wordlist2 [list shea shee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "SI" 
							}
							set wordlist2 [list sheik]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "S4" 
							}
							return "Se" 
						}
						"shi" {
							set wordlist1 [list shire]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "Sai." 
							}
							set wordlist2 [list shie]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "SI" 
							}
							if {[UniversalEing $word shi]} {
								return "Sai" 
							}
							set wordlist2 [list shiny]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Sai" 
							}
							set wordlist2 [list shir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "S:" 
							}
							return "Si" 
						}
						"sho" {
							set wordlist2 [list shoa show shoulder]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "S@" 
							}
							set wordlist2 [list shoe]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "SU" 
							}
							set wordlist1 [list shook]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "Su" 
							}
							set wordlist2 [list should shov]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Su" 
							}
							set wordlist2 [list shoo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "SU" 
							}
							set wordlist2 [list shor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "SO" 
							}
							set wordlist2 [list shou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "SaU" 
							}
							return "So" 
						}
						"shr" {
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"shra" {
									return "Sra" 
								}
								"shre" {
									set wordlist2 [list shrew]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "SrU" 
									}
									return "Sre" 
								}
								"shri" {
									set wordlist2 [list shrie]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "SrI" 
									}
									if {[UniversalEing $word shri]} {
										return "Srai" 
									}
									return "Sri" 
								}
								"shro" {
									set wordlist1 [list shrove]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "Sr@" 
									}
									set wordlist2 [list shrou]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "SraU" 
									}
									return "Sro" 
								}
								"shru" {
									return "Sru" 
								}
							}
						}
						"shu" {
							return "Su" 
						}
						"shy" {
							return "Sai"
						}
					}
				}
				"si" {
					if {[SpecificEing $word siev]} {
						return "si" 
					}
					set wordlist2 [list signal]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "si" 
					}
					set wordlist2 [list sie]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sI" 
					}
					set wordlist1 [list sinus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "sai" 
					}
					if {[UniversalEing $word si]} {
						return "sai" 
					}
					if {[SpecificEing $word sidl]} {
						return "sai" 
					}
					set wordlist2 [list sigh sign siam siphon]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sai" 
					}
					set wordlist2 [list sir]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s:" 
					}
					return "si" 
				}
				"sk" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"ska" {
							set wordlist1 [list ska]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "skA" 
							}
							return "ska" 
						}
						"ske" {
							set wordlist1 [list skew]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "skiU" 
							}
							return "ske" 
						}
						"ski" {
							set wordlist1 [list ski skier skiing skied]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "skI" 
							}
							if {[UniversalEing $word ski]} {
								return "skai" 
							}
							set wordlist2 [list skir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sk:" 
							}
							return "ski" 
						}
						"sku" {
							return "sku" 
						}
						"sky" {
							return "skai" 
						}
					}
				}
				"sl" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"sla" {
							if {[UniversalEing $word sla]} {
								return "sl4" 
							}
							set wordlist2 [list slai slay]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sl4" 
							}
							set wordlist2 [list slaugh]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "slO" 
							}
							return "sla" 
						}
						"sle" {
							set wordlist2 [list slee slea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "slI" 
							}
							set wordlist2 [list sleight]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "slai" 
							}
							set wordlist2 [list sleigh]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sl4" 
							}
							set wordlist2 [list slew]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "slU" 
							}
							return "sle" 
						}
						"slo" {
							if {[UniversalEing $word slo]} {
								return "sl@" 
							}
							set wordlist2 [list slogan sloth slow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sl@" 
							}
							set wordlist2 [list slou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "slaU" 
							}
							set wordlist2 [list slov]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "slu" 
							}
							return "slo" 
						}
						"slu" {
							set wordlist2 [list sluic]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "slU" 
							}
							set wordlist2 [list slur]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sl:" 
							}
							return "slu" 
						}
						"sly" {
							return "sla" 
						}
					}
				}
				"sm" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"sma" {
							set wordlist2 [list small]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "smO" 
							}
							set wordlist2 [list smar]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "smA" 
							}
							return "sma" 
						}
						"sme" {
							return "sme" 
						}
						"smi" {
							if {[UniversalEing $word smi]} {
								return "smai" 
							}
							set wordlist2 [list smir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sm:" 
							}
							return "smi" 
						}
						"smo" {
							set wordlist1 [list smoky]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sm@" 
							}
							if {[UniversalEing $word smo]} {
								return "sm@" 
							}
							set wordlist2 [list smolder]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sm@" 
							}
							set wordlist2 [list smoo smou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "smU" 
							}
							set wordlist2 [list smoth]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "smu" 
							}
							return "smo" 
						}
						"smu" {
							return "smu" 
						}
					}
				}
				"sn" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"sna" {
							if {[SpecificEing $word snar]} {
								return "snE" 
							}
							if {[UniversalEing $word sna]} {
								return "sn4" 
							}
							set wordlist2 [list snai]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sn4" 
							}
							set wordlist2 [list snar]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "snA" 
							}
							return "sna" 
						}
						"sne" {
							set wordlist2 [list sneer]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sni." 
							}
							set wordlist2 [list snea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "snI" 
							}
							return "sne" 
						}
						"sni" {
							set wordlist2 [list snivel]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sni" 
							}
							if {[UniversalEing $word sni]} {
								return "snai" 
							}
							return "sni" 
						}
						"sno" {
							set wordlist2 [list snoo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "snu" 
							}
							set wordlist2 [list snor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "snO" 
							}
							set wordlist2 [list snou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "snaU" 
							}
							set wordlist2 [list snow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sn@" 
							}
							return "sno" 
						}
						"snu" {
							return "snu" 
						}
					}
				}
				"so" {
					set wordlist2 [list sorr solemn]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "so" 
					}
					set wordlist1 [list sought]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "sO" 
					}
					set wordlist2 [list soar sor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sO" 
					}
					set wordlist1 [list son sonny]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "su" 
					}
					set wordlist2 [list some soot southern]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "su" 
					}
					set wordlist2 [list soo soup]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sU" 
					}
					set wordlist2 [list soi soy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "soi" 
					}
					set wordlist1 [list solution soprano]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "s." 
					}
					set wordlist2 [list solicit solidif sophisti societ]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s." 
					}
					set wordlist1 [list so soda sodium sofa sonar soviet]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "s@" 
					}
					if {[UniversalEing $word so]} {
						return "s@" 
					}
					set wordlist2 [list soa soul socia socio sold solar solo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s@" 
					}
					set wordlist2 [list sou]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "saU" 
					}
					return "so" 
				}
				"sp" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"spa" {
							if {[SpecificEing $word spar]} {
								return "spE" 
							}
							set wordlist1 [list sparrow]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "spa" 
							}
							set wordlist1 [list spa]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "spA" 
							}
							set wordlist2 [list spar]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spA" 
							}
							if {[UniversalEing $word spa]} {
								return "sp4" 
							}
							set wordlist2 [list spai spacious]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sp4" 
							}
							set wordlist2 [list spaw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spO" 
							}
							return "spa" 
						}
						"spe" {
							set wordlist2 [list spear]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spi." 
							}
							set wordlist1 [list species]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "spI" 
							}
							set wordlist2 [list spee spea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spI" 
							}
							set wordlist2 [list sper]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sp:" 
							}
							set wordlist2 [list spew]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spiU" 
							}
							set wordlist2 [list specific]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sp." 
							}
							return "spe" 
						}
						"sph" {
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"sphe" {
									set wordlist1 [list sphere]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "sfi." 
									}
									return "sfe" 
								}
								"sphi" {
									return "sfi" 
								}
							}
						}
						"spi" {
							set wordlist1 [list spinal]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "spai" 
							}
							if {[UniversalEing $word spi]} {
								return "spai" 
							}
							set wordlist2 [list spiral spicy]
								if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spai" 
							}
							return "spi" 
						}
						"spl" {
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"spla" {
									set wordlist2 [list splay]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "spl4" 
									}
									return "spla" 
								}
								"sple" {
									set wordlist2 [list spleen]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "splI" 
									}
									set wordlist2 [list splenetic]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "spl." 
									}
									return "sple" 
								}
								"spli" {
									if {[UniversalEing $word spli]} {
										return "splai" 
									}
									return "spli" 
								}
								"splo" {
									set wordlist2 [list sploo]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "splU" 
									}
									return "splo" 
								}
								"splu" {
									return "splu" 
								}
							}
						}
						"spo" {
							set wordlist2 [list spoi]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spoi" 
							}
							if {[UniversalEing $word spo]} {
								return "sp@" 
							}
							set wordlist2 [list spong]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spu" 
							}
							set wordlist2 [list spoo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spU" 
							}
							set wordlist2 [list spor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spO" 
							}
							set wordlist2 [list spou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spaU" 
							}
							return "spo" 
						}
						"spr" {
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"spra" {
									set wordlist2 [list sprai spray]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "spr4" 
									}
									set wordlist2 [list spraw]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "sprO" 
									}
									return "spra" 
								}
								"spre" {
									set wordlist2 [list spread]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "spre" 
									}
									set wordlist1 [list spree]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "sprI" 
									}
								}
								"spri" {
									if {[UniversalEing $word spr]} {
										return "sprai" 
									}
									set wordlist2 [list spright]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "sprai" 
									}
									return "spri" 
								}
								"spro" {
									set wordlist2 [list sprou]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "spraU" 
									}
									return "spro" 
								}
								"spru" {
									if {[UniversalEing $word spru]} {
										return "spru" 
									}
									return "spru" 
								}
								"spry" {
									return "sprai"
								}
							}
						}
						"spu" {
							set wordlist2 [list spurious]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "spiU" 
							}
							set wordlist2 [list spur]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sp:" 
							}
							return "spu" 
						}
						"spy" {
							return "spai" 
						}
					}
				}
				"sq" {
					incr k
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"squa" {
							set wordlist2 [list squall squaw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skuO" 
							}
							set wordlist2 [list square]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skUE" 
							}
							return "skUo" 
						}
						"sque" {
							set wordlist2 [list squea squee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skUI" 
							}
							return "skUe" 
						}
						"squi" {
							if {[UniversalEing $word squi]} {
								return "skUai" 
							}
							set wordlist2 [list squirr]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skUi" 
							}
							set wordlist2 [list squir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "skU:" 
							}
							return "skUi" 
						}
					}
				}
				"st" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"sta" {
							set wordlist1 [list stallion]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sta" 
							}
							if {[SpecificEing $word star]} {
								return "stE" 
							}
							set wordlist2 [list stair]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stE" 
							}
							set wordlist1 [list status statism]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "st4" 
							}
							if {[UniversalEing $word sta]} {
								return "st4" 
							}
							if {[SpecificEing $word stapl]} {
								return "st4" 
							}
							set wordlist2 [list stai stay stabilis]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "st4" 
							}
							set wordlist2 [list stalk stall]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stO" 
							}
							set wordlist2 [list star]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stA" 
							}
							set wordlist1 [list stability]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "st." 
							}
							set wordlist2 [list statistic]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "st." 
							}
							return "sta" 
						}
						"ste" {
							set wordlist2 [list steer]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sti." 
							}
							set wordlist2 [list steak]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "st4" 
							}
							set wordlist1 [list sterile]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "ste" 
							}
							set wordlist2 [list stealth sterilis stead]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ste" 
							}
							set wordlist2 [list stea stee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stI" 
							}
							set wordlist1 [list sterility]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "st." 
							}
							set wordlist2 [list ster]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "st:" 
							}
							set wordlist2 [list stew]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stiU" 
							}
							return "ste" 
						}
						"sti" {
							set wordlist2 [list stiletto stirrup]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sti" 
							}
							if {[UniversalEing $word sti]} {
								return "stai" 
							}
							if {[SpecificEing $word stifl]} {
								return "stai" 
							}
							set wordlist2 [list stir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "st:" 
							}
							return "sti" 
						}
						"sto" {
							set wordlist1 [list stony]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "st@" 
							}
							if {[UniversalEing $word sto]} {
								return "st@" 
							}
							set wordlist2 [list stow stoa]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "st@" 
							}
							set wordlist1 [list stood]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "stu" 
							}
							set wordlist2 [list stomach]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stu" 
							}
							set wordlist2 [list stoo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stU" 
							}
							set wordlist2 [list stor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stO" 
							}
							set wordlist2 [list stou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "staU" 
							}
							return "sto" 
						}
						"str" {
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"stra" {
									set wordlist2 [list strange strai]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "str4" 
									}
									set wordlist1 [list strata stratum]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "strA" 
									}
									set wordlist1 [list strategic]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "str." 
									}
									set wordlist2 [list straw]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "strO" 
									}
									return "stra" 
								}
								"stre" {
									set wordlist2 [list strea stree]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "strI" 
									}
									set wordlist2 [list strew]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "strU" 
									}
									return "stre" 
								}
								"stri" {
									if {[UniversalEing $word stri]} {
										return "strai" 
									}
									return "stri" 
								}
								"stro" {
									if {[UniversalEing $word stro]} {
										return "str@" 
									}
									set wordlist2 [list stroll]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "str@" 
									}
									return "stro" 
								}
								"stru" {
									return "stru" 
								}
							}
						}
						"stu" {
							set wordlist2 [list studi stude stup]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "stiU" 
							}
							return "stu" 
						}
						"sty" {
							return "stai"
						}
					}
				}
				"su" {
					set wordlist2 [list suave]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sUA" 
					}
					set wordlist1 [list suede]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "sU4" 
					}
					set wordlist1 [list supply]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "s." 
					}
					set wordlist2 [list sufficient suggest supplie support surmount surpass suppos surpass surrender surround surveill surviv susceptibl]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s." 
					}
					set wordlist2 [list sure]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "SO" 
					}
					set wordlist2 [list surr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "su" 
					}
					set wordlist2 [list sur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "s:" 
					}
					set wordlist1 [list suite]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "sUI" 
					}
					set wordlist2 [list sue sui]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sU" 
					}
					set wordlist2 [list sugar]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Su" 
					}
					set wordlist2 [list sub]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sub" 
					}
					set wordlist2 [list super]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sUp." 
					}
					set wordlist2 [list supine supreme]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "siU" 
					}
					return "su" 
				}
				"sw" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"swa" {
							set wordlist2 [list swag]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sUa" 
							}
							set wordlist2 [list swar]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sUO" 
							}
							set wordlist2 [list sway]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sU4" 
							}
							return "sUo" 
						}
						"swe" {
							set wordlist2 [list swear]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sUE" 
							}
							set wordlist2 [list sweat]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sUE" 
							}
							set wordlist1 [list swedish]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sUI" 
							}
							if {[UniversalEing $word swe]} {
								return "sUI" 
							}
							set wordlist2 [list swee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sUI" 
							}
							set wordlist2 [list swer]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sU:" 
							}
							return "sUe" 
						}
						"swi" {
							if {[UniversalEing $word swi]} {
								return "sUai" 
							}
							set wordlist2 [list swir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sU:" 
							}
							return "sUi" 
						}
						"swo" {
							set wordlist1 [list swore sworn]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "sUO" 
							}
							set wordlist2 [list sword]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "sO" 
							}
							set wordlist2 [list swoo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "suU" 
							}
							return "sUo" 
						}
						"swu" {
							return "suU" 
						}
					}
				}
				"sy" {
					set wordlist2 [list syphon]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "sai" 
					}
					set wordlist1 [list syringe]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "s." 
					}
					return "si" 
				}
			}
		}
		"t" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ta" {
					set wordlist1 [list tablet tarragon]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ta" 
					}
					set wordlist2 [list talent tapestr tabla]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ta" 
					}
					set wordlist1 [list tasty]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "t4" 
					}
					if {[UniversalEing $word ta]} {
						return "t4" 
					}
					if {[SpecificEing $word tabl]} {
						return "t4" 
					}
					set wordlist2 [list tail]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "t4" 
					}
					set wordlist1 [list tall tallboy]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "tO" 
					}
					set wordlist2 [list tau taw talk]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tO" 
					}
					set wordlist1 [list ta]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "tA" 
					}
						set wordlist2 [list tar]
						if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tA" 
					}
					return "ta" 
				}
				"te" {
					set wordlist2 [list tear]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ti." 
					}
					set wordlist2 [list tea tee tedi]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tI" 
					}
					set wordlist1 [list telephonist telegraphist telephony telegraphy]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "tel" 
					}
					set wordlist2 [list tele]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "teli" 
					}
					set wordlist1 [list terrific terrain]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "t." 
					}
					set wordlist2 [list terrif]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "te" 
					}
					set wordlist2 [list ter]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "t:" 
					}
					return "te" 
				}
				"th" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"tha" {
							set wordlist2 [list thai]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tai" 
							}
							set wordlist1 [list thames]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "tE" 
							}
							set wordlist1 [list than]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7a" 
							}
							set wordlist2 [list thaw]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "TO" 
							}
							return "Ta" 
						}
						"the" {
							set wordlist1 [list the]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7." 
							}
							set wordlist1 [list their theyre]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7E" 
							}
							set wordlist2 [list there]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "7E" 
							}
							set wordlist2 [list thematic]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Ti" 
							}
							set wordlist1 [list thesis theses]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "TI" 
							}
							set wordlist2 [list theist theol theme]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "TI" 
							}
							set wordlist1 [list them then]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7e" 
							}
							set wordlist1 [list theory theatre]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "Ti." 
							}
							set wordlist2 [list theore]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Ti." 
							}
							set wordlist2 [list theatric]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Tia" 
							}
							set wordlist1 [list thermometer thesaurus]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "T." 
							}
							set wordlist2 [list ther]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "T:" 
							}
							set wordlist1 [list thee these]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7I" 
							}
							set wordlist1 [list they]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "74" 
							}
							return "Te" 
						}
						"thi" {
							set wordlist2 [list thie]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "TI" 
							}
							set wordlist1 [list thigh]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "Tai" 
							}
							set wordlist2 [list thir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "T:" 
							}
							set wordlist1 [list this]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7i" 
							}
							return "Ti" 
						}
						"tho" {
							set wordlist2 [list thorn thought]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "TO" 
							}
							set wordlist2 [list thorough]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Tu" 
							}
							set wordlist1 [list those though]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7@" 
							}
							set wordlist1 [list thou]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7aU" 
							}
							set wordlist2 [list thou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "TaU" 
							}
							return "To" 
						}
						"thr" {
							set rhymestr [IncludeNextChar $word $wlen $k]
							if {[string length $rhymestr] <= 0} {
								return $evv(NULL_PROP)
							}
							incr k
							switch -- $rhymestr {
								"thra" {
									return "Tra" 
								}
								"thre" {
									set wordlist2 [list thread threat]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "Tre" 
									}
									set wordlist2 [list three]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "Tri" 
									}
									threw 
										return "TrU" 
									return "Tre" 
								}
								"thri" {
									if {[UniversalEing $word thri]} {
										return "Trai 
									}
									return "Tri" 
								}
								"thro" {
									set wordlist1 [list throve]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "Tr@" 
									}
									set wordlist2 [list throw throa throe]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "Tr@" 
									}
									set wordlist2 [list through]
									if {[WordStartsWithAnyOf $word $wordlist2]} {
										return "TrU" 
									}
									return "Tro" 
								}
								"thru" {
									set wordlist1 [list thru]
									if {[WordMatchesAnyOfWords $word $wordlist1]} {
										return "TrU" 
									}
									return "Tru" 
								}
							}
						}
						"thu" {
							set wordlist2 [list thur]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "T:" 
							}
							set wordlist1 [list thus]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7u" 
							}
							return "Tu" 
						}
						"thw" {
							return "TUO"
						}
						"thy" {
							set wordlist1 [list thyme]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "tai"
							}
							set wordlist1 [list thy]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "7ai"
							}
							return "Tai" 
						}
					}
				}
				"ti" {
					set wordlist2 [list tier]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ti." 
					}
					set wordlist1 [list tidal]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "tai" 
					}
					if {[UniversalEing $word ti]} {
						return "tai" 
					}
					if {[SpecificEing $word titl]} {
						return "tai" 
					}
					set wordlist2 [list tie tight tiny tidy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tai" 
					}
					return "ti" 
				}
				"to" {
					set wordlist1 [list to todo took toward]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "tu" 
					}
					set wordlist2 [list tough tongu touch]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tu" 
					}
					set wordlist1 [list today tomorrow todo tobacco tomato tonight]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "t." 
					}
					set wordlist2 [list tower town together toboggan]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "taU" 
					}
					set wordlist1 [list tokyo told]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "t@" 
					}
					if {[UniversalEing $word to]} {
						return "t@" 
					}
					set wordlist2 [list toby toll total tow toa toe]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "t@" 
					}
					set wordlist2 [list toi toy]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "toi" 
					}
					set wordlist1 [list tomboy tombola]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "to" 
					}
					set wordlist2 [list torr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "to" 
					}
					set wordlist2 [list tomb too]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tU" 
					}
					set wordlist2 [list tor tour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tO" 
					}
					set wordlist2 [list tou]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "taU" 
					}
					return "to" 
				}
				"tr" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"tra" {
							set wordlist2 [list tradition trajectory trapeze]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tr." 
							}
							if {[UniversalEing $word tra]} {
								return "tr4" 
							}
							set wordlist2 [list trai tray]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tr4" 
							}
							set wordlist2 [list trans]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "trans" 
							}
							return "tra" 
						}
						"tre" {
							set wordlist2 [list treach tread treasur]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tre" 
							}
							set wordlist2 [list trea tree]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "trI" 
							}
							set wordlist2 [list tremendous]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tri" 
							}
							return "tre" 
						}
						"tri" {
							set wordlist1 [list tribunal tripod]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "trai" 
							}
							if {[UniversalEing $word tri]} {
								return "trai" 
							}
							if {[SpecificEing $word trifl]} {
								return "trai" 
							}
							set wordlist2 [list tribal tricyl tria triumph]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "trai" 
							}
							set wordlist1 [list trio]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "trI" 
							}
							return "tri" 
						}
						"tro" {
							set wordlist2 [list troo]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "trU" 
							}
							set wordlist2 [list troph]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tr@" 
							}
							set wordlist2 [list troubl]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tru" 
							}
							set wordlist2 [list trough]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tro" 
							}
							set wordlist2 [list trou trow]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "traU" 
							}
							return "tro" 
						}
						"tru" {
							set wordlist1 [list true truly]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "trU" 
							}
							if {[UniversalEing $word tru]} {
								return "trU" 
							}
							set wordlist2 [list truth truant]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "trU" 
							}
							return "tru" 
						}
						"try" {
							return "trai"
						}
					}
				}
				"tu" {
					set wordlist1 [list tubular tulip tuna tunic]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "tiU" 
					}
					if {[UniversalEing $word tu]} {
						return "tiU" 
					}
					set wordlist2 [list tue tui tutor tunisia tumour]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tiU" 
					}
					set wordlist1 [list tureen]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "tiO" 
					}
					set wordlist2 [list turret]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "tu" 
					}
					set wordlist2 [list tur]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "t:" 
					}
					return "tu"
				}
				"tw" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"twa" {
							return "tUa" 
						}
						"twe" {
							set wordlist2 [list twee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tUI" 
							}
							return "tUe" 
						}
						"twi" {
							set wordlist1 [list twilight]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "tUai" 
							}
							if {[UniversalEing $word twi]} {
								return "tUai" 
							}
							set wordlist2 [list twirl]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "tU:" 
							}
							return "tUi" 
						}
						"two" {
							return "tU " 
						}
					}
				}
				"ty" {
					set wordlist2 [list typic typif]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ti" 
					}
					return "tai" 
				}
			}
		}
		"u" {
			set wordlist1 [list utmost us]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "u" 
			}
			set wordlist2 [list utter]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "u" 
			}
			set wordlist1 [list ufo uk]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "iU" 
			}
			set wordlist2 [list unit univ unif unil uri ub usa usu ut]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "iU" 
			}
			set wordlist2 [list un]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "un" 
			}
			set wordlist2 [list up]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "up" 
			}
			set wordlist2 [list ur]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return ":" 
			}
			return "u" 
		}
		"v" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"va" {
					set wordlist1 [list varicose]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "va" 
					}
					set wordlist1 [list vanilla	]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "v." 
					}
					set wordlist2 [list variet vagina]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "v." 
					}
					set wordlist1 [list vary]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "vE" 
					}
					set wordlist2 [list vari]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "vE" 
					}
					set wordlist1 [list vase]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "vA" 
					}
					set wordlist2 [list var]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "vA" 
					}
					set wordlist2 [list vau]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "vO" 
					}
					return "va" 
				}
				"ve" {
					set wordlist2 [list vehemen vehicle veer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "vi." 
					}
					set wordlist2 [list vea veto]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "vI" 
					}
					set wordlist2 [list vei]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "v4" 
					}
					set wordlist1 [list velocity venereal venetian vernacular]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "v." 
					}
					set wordlist2 [list vehicul veneer]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "v." 
					}
					set wordlist1 [list very]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "ve" 
					}
					set wordlist2 [list verif verit]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "ve" 
					}
					set wordlist2 [list ver]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "v:" 
					}
					return "ve" 
				}
				"vi" {
					set wordlist1 [list vinegar vineyard viola]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "vi" 
					}
					set wordlist2 [list viri virul]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "vi" 
					}
					set wordlist1 [list virus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "vai" 
					}
					if {[UniversalEing $word vi]} {
						return "vai" 
					}
					set wordlist2 [list view]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "viU" 
					}
					set wordlist2 [list viol vital via vibrf vie visor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "vai" 
					}
					set wordlist2 [list vir]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "v:" 
					}
					set wordlist1 [list visa]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "vI" 
					}
					return "vi" 
				}
				"vo" {
					set wordlist1 [list vocabulary]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "v." 
					}
					set wordlist2 [list voluminous vociferous volition voluptuous]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "v." 
					}
					set wordlist1 [list vocab]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "v@" 
					}
					if {[UniversalEing $word vo]} {
						return "v@" 
					}
					set wordlist2 [list vogu volt vocal vocation]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "v@" 
					}
					set wordlist2 [list voi voy	]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "voi" 
					}
					set wordlist2 [list vou vow]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "vaU" 
					}
					return "vo" 
				}
				"vu" {
					return "vu" 
				}
			}
		}
		"w" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"wa" {
					set wordlist1 [list wallet wally]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "Uo" 
					}
					set wordlist2 [list warrant wallop]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Uo" 
					}
					set wordlist1 [list ware wary warily]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "UE" 
					}
					set wordlist1 [list walnut walrus]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "UO" 
					}
					set wordlist2 [list walk wall war water]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "UO" 
					}
					if {[UniversalEing $word wa]} {
						return "U4" 
					}
					set wordlist2 [list wast way wai wav]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "U4" 
					}
					set wordlist2 [list wag wax]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Ua" 
					}
					return "Uo" 
				}
				"we" {
					set wordlist1 [list weary weir]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "Ui." 
					}
					set wordlist2 [list weird weari]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Ui." 
					}
					set wordlist2 [list wealth weapon wear weather]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Ue" 
					}
					set wordlist1 [list we weve]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "UI" 
					}
					set wordlist2 [list wea wee]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "UI" 
					}
					set wordlist2 [list wei]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "U4" 
					}
					set wordlist1 [list were werent]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "U:" 
					}
					return "Ue" 
				}
				"wh" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"wha" {
							set wordlist2 [list whack]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Ua" 
							}
							set wordlist2 [list whal]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "U4" 
							}
							set wordlist2 [list whar]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "UO" 
							}
							set wordlist2 [list what]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "Uo" 
							}
						}
						"whe" {
							set wordlist2 [list whea whee]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "UI"
							}
							set wordlist2 [list where]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "UE" 
							}
							return "Ue" 
						}
						"whi" {
							if {[UniversalEing $word whi]} {
								return "Uai" 
							}
							set wordlist2 [list whir]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "U:" 
							}
							return "Ui" 
						}
						"who" {
							set wordlist2 [list whole]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "h@" 
							}
							set wordlist1 [list whoa]
							if {[WordMatchesAnyOfWords $word $wordlist1]} {
								return "U@" 
							}
							set wordlist2 [list whor]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "hO" 
							}
							set wordlist2 [list whoop]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "uU" 
							}
							return "hU" 
						}
						"why" {
							return "Uai" 
						}
					}
				}
				"wi" {
					set wordlist1 [list wilderness]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "Ui" 
					}
					set wordlist1 [list wily winding wiry]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "Uai" 
					}
					if {[UniversalEing $word wi]} {
						return "Uai" 
					}
					set wordlist2 [list wild]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Uai" 
					}
					set wordlist2 [list wie]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "UI" 
					}
					return "Ui" 
				}
				"wo" {
					set wordlist1 [list wore worn]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "UO" 
					}
					set wordlist1 [list wont]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "U@" 
					}
					set wordlist1 [list women]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "Ui" 
					}
					if {[UniversalEing $word wo]} {
						return "U@" 
					}
					set wordlist2 [list woe]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "U@" 
					}
					set wordlist2 [list would worr woman won wood wool worr]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Uu" 
					}
					set wordlist2 [list womb wound]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "uU" 
					}
					set wordlist2 [list wor]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "U:" 
					}
				}
				"wr" {
					set rhymestr [IncludeNextChar $word $wlen $k]
					if {[string length $rhymestr] <= 0} {
						return $evv(NULL_PROP)
					}
					incr k
					switch -- $rhymestr {
						"wra" {
							set wordlist2 [list wrath]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "ro" 
							}
							set wordlist2 [list wrai]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "r4" 
							}
							return "ra" 
						}
						"wre" {
							set wordlist2 [list wrea]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rI" 
							}
							return "re" 
						}
						"wri" {
							if {[UniversalEing $word wri]} {
								return "rai" 
							}
							return "ri" 
						}
						"wro" {
							set wordlist2 [list wrou]
							if {[WordStartsWithAnyOf $word $wordlist2]} {
								return "rO" 
							}
							return "ro" 
						}
						"wru" {
							return "ru" 
						}
						"wry" {
							return "rai" 
						}
					}
				}
			}
		}
		"x" {
			set wordlist2 [list xy]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "z" 
			}
			return "eks" 
		}
		"y" {
			set rhymestr [IncludeNextChar $word $wlen $k]
			if {[string length $rhymestr] <= 0} {
				return $evv(NULL_PROP)
			}
			incr k
			switch -- $rhymestr {
				"ya" {
					set wordlist2 [list yaw]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "IO" 
					}
					set wordlist2 [list yacht]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Io" 
					}
					return "Ia"
				}
				"ye" {
					set wordlist2 [list yearn]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "I:" 
					}
					set wordlist2 [list year]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Ii." 
					}
					set wordlist2 [list yeo]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "I@" 
					}
					set wordlist2 [list yew]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "IU" 
					}
					return "Ie" 
				}
				"yi" {
					set wordlist2 [list yie]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "iI" 
					}
					return "Ii" 
				}
				"yo" {
					set wordlist1 [list yoga]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "I@" 
					}
					set wordlist2 [list yoke yolk]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "I@" 
					}
					set wordlist1 [list yoghurt yonder]
					if {[WordMatchesAnyOfWords $word $wordlist1]} {
						return "Io" 
					}
					set wordlist2 [list young]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "Iu" 
					}
					set wordlist2 [list your]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "IO" 
					}
					set wordlist2 [list you]
					if {[WordStartsWithAnyOf $word $wordlist2]} {
						return "IU" 
					}
				}
			}
		}
		"z" {
			set wordlist1 [list zany]
			if {[WordMatchesAnyOfWords $word $wordlist1]} {
				return "z4" 
			}
			set wordlist2 [list za]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "za" 
			}
			set wordlist2 [list zealous]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "ze" 
			}
			set wordlist2 [list zea]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "zI" 
			}
			set wordlist2 [list ze]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "ze" 
			}
			set wordlist2 [list zi]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "zi" 
			}
			set wordlist2 [list zodiac]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "z@" 
			}
			set wordlist2 [list zoo]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "zU" 
			}
			set wordlist2 [list zo]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "zo" 
			}
			set wordlist2 [list zu]
			if {[WordStartsWithAnyOf $word $wordlist2]} {
				return "zu" 
			}
		}
	}
}

#--- Help for Start-Syllable Page

proc SttHelp {} {
	set msg "STATISTICS OF START-SYLLABLES OF WORDS\n"
	append msg "\n"
	append msg "You can display the phonetic equivalents of the starts of words....\n"
	append msg "\n"
	append msg "1)    ranked by the Frequency with which they occur OR\n"
	append msg "2)   (semi-)Alphabetically i.e. in this order....\n"
	append msg "            .  :  a  A  4  e  E  i  I  o  O  @  u  U  (vowels)\n"
	append msg "            m  n  N  l  r  (liquids & fricatives)\n"
	append msg "            b  d  g  k  p  t  (hard consonants)\n"
	append msg "            T  7  h  X  f  v  j  s  S  z  Z  C (noise consonants)\n"
	append msg "            for full explanation see main window, once phonetics listed.\n"
	append msg "\n"
	append msg "You can also choose between listing which are\n"
	append msg "\n"
	append msg "1)   exact : the actual phonetic word-starts found\n"
	append msg "2)   include : the phonetics included at each word start\n"
	append msg "            e.g. \"Tia\" includes \"Ti\" and \"T\"\n"
	append msg "\n"
	append msg "Once phonetic word-starts are displayed you can choose to\n"
	append msg "see the texts or hear the soundfiles where those items occur.\n"
	append msg "\n"
	append msg "1)   Mouse-click selects the phonetic item\n"
	append msg "2)   Shift-click ADDs an item to your choice list\n"
	append msg "3)   Up and Down arrows move to previous & next items.\n"
	append msg "4)   Shift Up and Down arrows add to your existing choice.\n"
	append msg "5)   Alphabetic keys will move the list to the letter selected.\n"
	append msg "\n"
	append msg "You can then...\n"
	append msg "1)    Save the texts displayed to a text file.\n"
	append msg "2)    Save the sounds containing the texts to a new property file.\n"
	append msg "3)    Send or add the sounds to the Chosen Files list on the workspace.\n"
	append msg "\n"
	append msg "These statistics for this property file can also be stored,\n"
	append msg "or added to the total of similar statistics over a number of property files.\n"
	append msg "\n"
	append msg "Additional options allow you to display and use...\n"
	append msg "\n"
	append msg "1)    All starts beginning with particular consonant(s)\n"
	append msg "2)    All starts beginning with particular vowels(s)\n"
	append msg "3)    All starts where a particular vowel (combo) follows consonants\n"
	append msg "4)    All starts where a particular consonant (combo) follows vowels\n"
	append msg "\n"
	Inf $msg
}

#------ Go to first line starting character "inchar" in phonetics display of rhymes

proc RhymeGoto {inchar} {
	global rhystatistics
	set n 0
	if {[string match $inchar bottom]} {
		$rhystatistics selection clear 0 end
		$rhystatistics selection set [expr [$rhystatistics index end] - 1]
		$rhystatistics yview moveto 1.0
		return
	} elseif {[string match $inchar top]} {
		$rhystatistics selection clear 0 end
		$rhystatistics selection set 0
		$rhystatistics yview moveto 0.0
		return
	}
	foreach line [$rhystatistics get 0 end] {
		set phon [split $line]
		set phon [lindex $phon end]
		set char [string index $phon 0]
		if {[string match $char $inchar]} {
			$rhystatistics selection clear 0 end
			$rhystatistics selection set $n
			$rhystatistics yview moveto [expr double($n)/double([$rhystatistics index end])]
			return
		}
		incr n
	}
	Inf "NO ITEM FOUND STARTING WITH \" $inchar \""
}

#------------------------------------------------------------------------------------------------#
#------- Characteristic of start-phonetics of words : start or end with vowel or consonant ------#
#------------------------------------------------------------------------------------------------#

proc StartsWithVowel {y} {
	global sttexstats sttpossibs charopexact pr_charop rhystatistics rhystatchoice rhylist
	set i [$sttpossibs nearest $y]
	set matchstr [$sttpossibs get $i]
	set mlen [string length $matchstr]
	foreach rhym [array names sttexstats] {
		set rhlen [string length $rhym]
		set val [lindex $sttexstats($rhym) 0]
		if {$rhlen < $mlen} {
			continue
		}
		if {[string first $matchstr $rhym] != 0} {
			continue
		}
		if {$charopexact && ($rhlen > $mlen)} {
			set nextchar [string index $rhym $mlen]
			if {[IsPhonVowel $nextchar]} {
				continue
			}
		}
		lappend alphastats $val $rhym
	}
	if {![info exists alphastats]} {
		set pr_charop 0
		return
	}
	set rhystatchoice  {}
	$rhystatistics delete 0 end
	foreach {frq val} $alphastats {
		set line $frq
		append line "  " $val
		$rhystatistics insert end $line
		lappend rhystatchoice $val
	}
	set rhylist [lindex $rhystatchoice 0]
	if {[llength $rhystatchoice] > 1} {
		foreach rhyme [lrange $rhystatchoice 1 end] {
			append rhylist "  " $rhyme
		}
	}
	set pr_charop 0
}

proc StartsWithConsonant {y} {
	global sttexstats sttpossibs charopexact pr_charop rhystatistics rhystatchoice rhylist
	set i [$sttpossibs nearest $y]
	set matchstr [$sttpossibs get $i]
	set mlen [string length $matchstr]
	foreach rhym [array names sttexstats] {
		set rhlen [string length $rhym]
		set val [lindex $sttexstats($rhym) 0]
		if {$rhlen < $mlen} {
			continue
		}
		if {[string first $matchstr $rhym] != 0} {
			continue
		}
		if {$charopexact && ($rhlen > $mlen)} {
			set nextchar [string index $rhym $mlen]
			if {![IsPhonVowel $nextchar]} {
				continue
			}
		}
		lappend alphastats $val $rhym
	}
	if {![info exists alphastats]} {
		set pr_charop 0
		return
	}
	set rhystatchoice  {}
	$rhystatistics delete 0 end
	foreach {frq val} $alphastats {
		set line $frq
		append line "  " $val
		$rhystatistics insert end $line
		lappend rhystatchoice $val
	}
	set rhylist [lindex $rhystatchoice 0]
	if {[llength $rhystatchoice] > 1} {
		foreach rhyme [lrange $rhystatchoice 1 end] {
			append rhylist "  " $rhyme
		}
	}
	set pr_charop 0
}

proc StartConsonantLeadsToVowel {y} {
	global sttexstats sttpossibs charopexact pr_charop rhystatistics rhystatchoice rhylist
	set i [$sttpossibs nearest $y]
	set matchstr [$sttpossibs get $i]
	set mlen [string length $matchstr]
	foreach rhym [array names sttexstats] {
		set rhlen [string length $rhym]
		set val [lindex $sttexstats($rhym) 0]
		if {$rhlen <= $mlen} {
			continue
		}
		set k 0
		set OK 0
		set char [string index $rhym $k]
		while {![IsPhonVowel $char]} {
			set OK 1			;#	has consonants at start
			incr k
			if {$k >= $rhlen} {	;#	has no following vowels
				set OK 0
				break
			}
			set char [string index $rhym $k]
		}
		if {!$OK} {
			continue
		}
		set rhymend [string range $rhym $k end]
		set rhlen [string length $rhymend]
		if {[string first $matchstr $rhymend] != 0} {
			continue
		}
		if {$charopexact && ($rhlen > $mlen)} {
			set nextchar [string index $rhymend $mlen]
			if {[IsPhonVowel $nextchar]} {
				continue
			}
		}
		lappend alphastats $val $rhym
	}
	if {![info exists alphastats]} {
		set pr_charop 0
		return
	}
	set rhystatchoice  {}
	$rhystatistics delete 0 end
	foreach {frq val} $alphastats {
		set line $frq
		append line "  " $val
		$rhystatistics insert end $line
		lappend rhystatchoice $val
	}
	set rhylist [lindex $rhystatchoice 0]
	if {[llength $rhystatchoice] > 1} {
		foreach rhyme [lrange $rhystatchoice 1 end] {
			append rhylist "  " $rhyme
		}
	}
	set pr_charop 0
}

proc StartVowelLeadsToConsonant {y} {
	global sttexstats sttpossibs charopexact pr_charop rhystatistics rhystatchoice rhylist
	set i [$sttpossibs nearest $y]
	set matchstr [$sttpossibs get $i]
	set mlen [string length $matchstr]
	foreach rhym [array names sttexstats] {
		set rhlen [string length $rhym]
		set val [lindex $sttexstats($rhym) 0]
		if {$rhlen <= $mlen} {
			continue
		}
		set k 0
		set OK 0
		set char [string index $rhym $k]
		while {[IsPhonVowel $char]} {
			set OK 1			;#	has vowels at start
			incr k
			if {$k >= $rhlen} {	;#	has no following conconants
				set OK 0
				break
			}
			set char [string index $rhym $k]
		}
		if {!$OK} {
			continue
		}
		set rhymend [string range $rhym $k end]
		set rhlen [string length $rhymend]
		if {[string first $matchstr $rhymend] != 0} {
			continue
		}
		if {$charopexact && ($rhlen > $mlen)} {
			set nextchar [string index $rhymend $mlen]
			if {![IsPhonVowel $nextchar]} {
				continue
			}
		}
		lappend alphastats $val $rhym
	}
	if {![info exists alphastats]} {
		set pr_charop 0
		return
	}
	set rhystatchoice  {}
	$rhystatistics delete 0 end
	foreach {frq val} $alphastats {
		set line $frq
		append line "  " $val
		$rhystatistics insert end $line
		lappend rhystatchoice $val
	}
	set rhylist [lindex $rhystatchoice 0]
	if {[llength $rhystatchoice] > 1} {
		foreach rhyme [lrange $rhystatchoice 1 end] {
			append rhylist "  " $rhyme
		}
	}
	set pr_charop 0
}

#-------------------------------------------------------------------------------#
#------ Various displays of the starts or ends of of the starts-of-words -------#
#-------------------------------------------------------------------------------#

proc DisplayAllStartConsonants {} {
	global sttexstats sttpossibs 
	set allstartcons {}
	foreach rhym [array names sttexstats] {
		set rhlen [string length $rhym]
		set k 0
		set OK 0
		set char [string index $rhym $k]
		while {![IsPhonVowel $char]} {
			set OK 1			;#	has consonants at start
			incr k
			if {$k >= $rhlen} {	;#	has no following characters
				break
			}
			set char [string index $rhym $k]
		}
		if {!$OK} {
			continue
		}
		set startcons [string range $rhym 0 [expr $k - 1]]
		if {[lsearch $allstartcons $startcons] < 0} {
			lappend allstartcons $startcons
		}
	}
	if {[llength $allstartcons] <= 0} {
		Inf "NO START CONSONANTS TO DISPLAY"
		return 0
	}
	set len [llength $allstartcons]
	set n 0
	while {$n < $len} {
		set word [lindex $allstartcons $n]
		set slen [string length $word]
		if {$slen > 1} {
			incr slen -2
			while {$slen >= 0} {
				set nest [string range $word 0 $slen]
				if {[lsearch $allstartcons $nest] < 0} {
					lappend allstartcons $nest
				}
				incr slen -1
			}
		}
		incr n
	}
	set len [llength $allstartcons]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n [lindex $allstartcons $n]
		set m $n
		incr m
		while {$m < $len_less_one} {
			set nam_m [lindex $allstartcons $m]
			if {[LaterRhymeString $nam_n $nam_m 1]} {
				set allstartcons [lreplace $allstartcons $n $n $nam_m]
				set allstartcons [lreplace $allstartcons $m $m $nam_n]
				set nam_n $nam_m
			}
			incr m
		}
		incr n
	}
	$sttpossibs delete 0 end
	foreach rhnam $allstartcons {
		$sttpossibs insert end $rhnam
	}
	return 1
}

proc DisplayAllStartVowels {} {
	global sttexstats sttpossibs 
	set allstartvowels {}
	foreach rhym [array names sttexstats] {
		set rhlen [string length $rhym]
		set k 0
		set OK 0
		set char [string index $rhym $k]
		while {[IsPhonVowel $char]} {
			set OK 1			;#	has vowels at start
			incr k
			if {$k >= $rhlen} {	;#	has no following characters
				break
			}
			set char [string index $rhym $k]
		}
		if {!$OK} {
			continue
		}
		set startcons [string range $rhym 0 [expr $k - 1]]
		if {[lsearch $allstartvowels $startcons] < 0} {
			lappend allstartvowels $startcons
		}
	}
	if {[llength $allstartvowels] <= 0} {
		Inf "NO START VOWELS TO DISPLAY"
		return 0
	}
	set len [llength $allstartvowels]
	set n 0
	while {$n < $len} {
		set word [lindex $allstartvowels $n]
		set slen [string length $word]
		if {$slen > 1} {
			incr slen -2
			while {$slen >= 0} {
				set nest [string range $word 0 $slen]
				if {[lsearch $allstartvowels $nest] < 0} {
					lappend allstartvowels $nest
				}
				incr slen -1
			}
		}
		incr n
	}
	set len [llength $allstartvowels]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n [lindex $allstartvowels $n]
		set m $n
		incr m
		while {$m < $len_less_one} {
			set nam_m [lindex $allstartvowels $m]
			if {[LaterRhymeString $nam_n $nam_m 1]} {
				set allstartvowels [lreplace $allstartvowels $n $n $nam_m]
				set allstartvowels [lreplace $allstartvowels $m $m $nam_n]
				set nam_n $nam_m
			}
			incr m
		}
		incr n
	}
	$sttpossibs delete 0 end
	foreach rhnam $allstartvowels {
		$sttpossibs insert end $rhnam
	}
	return 1
}

proc DisplayAllPostStartConsonants {} {
	global sttexstats sttpossibs 
	set allmidcons {}
	foreach rhym [array names sttexstats] {
		set rhlen [string length $rhym]
		set j 0
		set char [string index $rhym $j]
		set OK 0
		while {[IsPhonVowel $char]} {
			set OK 1			;#	has vowels at start
			incr j
			if {$j >= $rhlen} {	;#	has no following characters
				set OK 0
				break
			}
			set char [string index $rhym $j]
		}
		if {!$OK} {
			continue
		}
		set k $j
		while {![IsPhonVowel $char]} {
			incr k
			if {$k >= $rhlen} {	;#	has no following characters
				break
			}
			set char [string index $rhym $k]
		}
		set midcons [string range $rhym $j [expr $k - 1]]
		if {[lsearch $allmidcons $midcons] < 0} {
			lappend allmidcons $midcons
		}
	}
	if {[llength $allmidcons] <= 0} {
		Inf "No Following Consonants To Display"
		return 0
	}
	set len [llength $allmidcons]
	set n 0
	while {$n < $len} {
		set word [lindex $allmidcons $n]
		set slen [string length $word]
		if {$slen > 1} {
			incr slen -2
			while {$slen >= 0} {
				set nest [string range $word 0 $slen]
				if {[lsearch $allmidcons $nest] < 0} {
					lappend allmidcons $nest
				}
				incr slen -1
			}
		}
		incr n
	}
	set len [llength $allmidcons]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n [lindex $allmidcons $n]
		set m $n
		incr m
		while {$m < $len_less_one} {
			set nam_m [lindex $allmidcons $m]
			if {[LaterRhymeString $nam_n $nam_m 1]} {
				set allmidcons [lreplace $allmidcons $n $n $nam_m]
				set allmidcons [lreplace $allmidcons $m $m $nam_n]
				set nam_n $nam_m
			}
			incr m
		}
		incr n
	}
	$sttpossibs delete 0 end
	foreach rhnam $allmidcons {
		$sttpossibs insert end $rhnam
	}
	return 1
}

proc DisplayAllPostStartVowels {} {
	global sttexstats sttpossibs 
	set allmidvowels {}
	foreach rhym [array names sttexstats] {
		set rhlen [string length $rhym]
		set j 0
		set OK 0
		set char [string index $rhym $j]
		while {![IsPhonVowel $char]} {
			set OK 1			;#	has consonants at start
			incr j
			if {$j >= $rhlen} {	;#	has no following characters
				set OK 0
				break
			}
			set char [string index $rhym $j]
		}
		if {!$OK} {
			continue
		}
		set k $j
		while {[IsPhonVowel $char]} {
			incr k
			if {$k >= $rhlen} {	;#	has no following characters
				break
			}
			set char [string index $rhym $k]
		}
		set midvowels [string range $rhym $j [expr $k - 1]]
		if {[lsearch $allmidvowels $midvowels] < 0} {
			lappend allmidvowels $midvowels
		}
	}
	if {[llength $allmidvowels] <= 0} {
		Inf "No Following Vowels To Display"
		return 0
	}
	set len [llength $allmidvowels]
	set n 0
	while {$n < $len} {
		set word [lindex $allmidvowels $n]
		set slen [string length $word]
		if {$slen > 1} {
			incr slen -2
			while {$slen >= 0} {
				set nest [string range $word 0 $slen]
				if {[lsearch $allmidvowels $nest] < 0} {
					lappend allmidvowels $nest
				}
				incr slen -1
			}
		}
		incr n
	}
	set len [llength $allmidvowels]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n [lindex $allmidvowels $n]
		set m $n
		incr m
		while {$m < $len_less_one} {
			set nam_m [lindex $allmidvowels $m]
			if {[LaterRhymeString $nam_n $nam_m 1]} {
				set allmidvowels [lreplace $allmidvowels $n $n $nam_m]
				set allmidvowels [lreplace $allmidvowels $m $m $nam_n]
				set nam_n $nam_m
			}
			incr m
		}
		incr n
	}
	$sttpossibs delete 0 end
	foreach rhnam $allmidvowels {
		$sttpossibs insert end $rhnam
	}
	return 1
}

#---- Rhymestring char is a vowel or not

proc IsPhonVowel {char} {
	set phons [list "." ":" "a" "A" "4" "e" "E" "i" "I" "o" "O" "@" "u" "U"]
	if {[lsearch $phons $char] >= 0} {
		return 1
	}
	return 0
}

proc StartCharOptions {vowels atstart} {
	global pr_charop charopexact sttpossibs evv
	set charopexact 0
	set pr_charop 0
	set f .charop
	if [Dlg_Create $f "" "set pr_charop 0" -borderwidth $evv(SBDR)] {
		frame $f.1
		frame $f.2
		frame $f.3
		label $f.1.ll -text "Matching Options : "
		radiobutton $f.1.r1 -variable charopexact -text "Exact" -value 1 -command {}
		radiobutton $f.1.r2 -variable charopexact -text "Starting With" -value 0 -command {}
		button $f.1.q -text Quit -command "set pr_charop 0" -highlightbackground [option get . background {}]
		pack $f.1.ll $f.1.r1 $f.1.r2 -side left
		pack $f.1.q -side right
		pack $f.1 -side top -fill x -expand true
		if {$vowels} {
			if {$atstart} {
				label $f.2.ll -text "STARTING VOWELS OF WORDS"
			} else {
				label $f.2.ll -text "VOWELS AFTER START-CONSONANTS OF WORDS"
			}
		} else {
			if {$atstart} {
				label $f.2.ll -text "STARTING CONSONANTS OF WORDS"
			} else {
				label $f.2.ll -text "CONSONANTS AFTER START-VOWELS OF WORDS"
			}
		}
		label $f.2.ll2 -text "Click on selected item below to instigate search"
		pack $f.2.ll $f.2.ll2 -side top -pady 2
		pack $f.2 -side top -pady 2
		set sttpossibs [Scrolled_Listbox $f.3.ll -width 10 -height 40 -selectmode single]
		pack $f.3.ll -side top
		pack $f.3 -side top
		if {$vowels} {
			if {$atstart} {
				bind $sttpossibs <ButtonRelease-1> {StartsWithVowel %y}
			} else {
				bind $sttpossibs <ButtonRelease-1> {StartConsonantLeadsToVowel %y}
			}
		} else {
			if {$atstart} {
				bind $sttpossibs <ButtonRelease-1> {StartsWithConsonant %y} 
			} else {
				bind $sttpossibs <ButtonRelease-1> {StartVowelLeadsToConsonant %y}
			}
		}
		wm resizable $f 1 1
		bind $f <Return> {set pr_charop 0}
		bind $f <Escape> {set pr_charop 0}
	}
	if {$vowels} {
		if {$atstart} {
			wm title $f "START VOWELS"
			if {![DisplayAllStartVowels]} {
				destroy $f
				return
			}
		} else {
			wm title $f "POST-START VOWELS"
			if {![DisplayAllPostStartVowels]} {
				destroy $f
				return
			}
		}
	} else {
		if {$atstart} {
			wm title $f "START CONSONANTS"
			if {![DisplayAllStartConsonants]} {
				destroy $f
				return
			}
		} else {
			wm title $f "POST-START CONSONANTS"
			if {![DisplayAllPostStartConsonants]} {
				destroy $f
				return
			}
		}
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_charop $f
	set finished 0
	tkwait variable pr_charop
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#############################
# (c) ASSOCIATED TEXT SORTS #
#############################

#--- Sort words alphabetically-backwards, (i.e. reverse the letter-order in each word before alphasorting).

proc ReverseTextSort {} {
	global pa evv wl
	set i [$wl curselection]
	if {([llength $i] != 1) || ($i == -1)} {
		Inf "Bad Selection: Select A List Of Words On Workspace"
		return
	}
	set fnam [$wl get $i]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST))} {
		Inf "Bad Selection: Select A List Of Words On Workspace"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Failed To Open File"
		return
	}
	set sdrow {}
	while {[gets $zit line] >= 0} {
		set word [string trim $line]
		if {[string length $word] <= 0} {
			continue
		}
		set drow [ReverseString [string tolower $word]]
		if {[lsearch $sdrow $drow] >= 0} {
			continue
		}
		lappend sdrow $drow
	}
	close $zit
	set sdrow [lsort -dictionary $sdrow]
	foreach drow $sdrow {
		set word [ReverseString $drow]
		lappend words $word
	}
	set outfnam $evv(REVERSETEXT_SORT)$evv(TEXT_EXT)
	if [catch {open $outfnam "w"} zit] {
		Inf "Cannot Open File '$outfnam' To Write Reverse-Sorted Text"
		return
	}
	foreach word $words {
		puts $zit $word
	}
	close $zit
	FileToWkspace $outfnam 0 0 0 0 1
}

#--- Reverse Letter order in Word

proc ReverseString {word} {
	set len [string length $word]
	set indx [expr $len - 1]
	set drow ""
	while {$indx >= 0} {
		set char [string index $word $indx]
		append drow $char
		incr indx -1
	}
	return $drow
}

#----- Test conversion of text-ends to phonetics

proc TestRhymeExtraction {args} {
	global chlist evv pa propwords tstats_nurhymes tstats_nurhyme_pairs

	set from_wk 0
	if {($args == 0) || ($args == 1)} {
		switch -- $args {
			0 {													;#	From a specified file on workspace
				if {![info exists chlist] || ([llength $chlist] != 1)} {
					Inf "Place Textfile Containing List-Of-Words On Chosen Files List"
					return 0
				}
				set fnam [lindex $chlist 0]
				if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
					Inf "Place A Textfile Containing List-Of-Words On Chosen Files List"
					return 0
				}
				set from_wk 1
			}
			1 {													;#	From Previously created wordlist file
				set fnam $evv(NEW_WORDS)$evv(TEXT_EXT)
			}
		}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Read Word List"
			return 0
		}
		while {[gets $zit line] >= 0} {
			set word [string trim $line]
			if {[string length $word] <= 0} {
				continue
			}
			lappend endings $word
		}
		close $zit
	} else {
		set endings [StripCurlies $args]
		set endings [split $endings]
	}

	set tstats_nurhymes $endings
	foreach word $endings {
		set trial [RemoveFinalSForRhymes $word]
		set nuword [lindex $trial 0]
		set isplural [lindex $trial 1]
		set nuword [GetPhoneticRhyme $nuword]
		if {$isplural} {
			set nuword [DoFinalSConversionForRhymes $word $nuword]
		}
		lappend nuwords $word $nuword
	}
	set outfnam $evv(NEW_RHYMES)$evv(TEXT_EXT)
	if [catch {open $outfnam "w"} zit] {
		Inf "Cannot Open File '$outfnam' To Write New Data"
		return 0
	}
	set tstats_nurhyme_pairs $nuwords
	foreach {word rhyme} $nuwords {
		set line $word
		append line "   " $rhyme
		puts $zit $line
	}
	close $zit
	set msg ""
	FileToWkspace $outfnam 0 0 0 0 1
	if {($args == 0) || ($args == 1)} {
		append msg "New Words In File '$fnam'\n\n"
	}
	append msg "New Rhymes In File '$outfnam'"
	Inf $msg
	return 1
}

#----- Sort by rhyme

proc RhymeSort {} {
	global chlist evv pa

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Place A Textfile Containing A List-of-Words On Chosen Files List"
		return 0
	}
	set fnam [lindex $chlist 0]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
		Inf "Place A Textfile Containing A List-of-Words On Chosen Files List"
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam To Read Word List"
		return 0
	}
	while {[gets $zit line] >= 0} {
		set word [string trim $line]
		if {[string length $word] <= 0} {
			continue
		}
		lappend endings $word
	}
	close $zit

	foreach word $endings {
		set trial [RemoveFinalSForRhymes $word]
		set nuword [lindex $trial 0]
		set isplural [lindex $trial 1]
		set nuword [GetPhoneticRhyme $nuword]
		if {$isplural} {
			set nuword [DoFinalSConversionForRhymes $word $nuword]
		}
		lappend nuwords $word $nuword
	}
	foreach {wd rh} $nuwords {
		lappend zz($rh) $wd
	}
	foreach nam [array names zz] {
		foreach wd $zz($nam) {
			lappend rhymelist $wd
		}
		lappend rhymelist ""
	}
	set len [llength $rhymelist]
	incr len -2
	set rhymelist [lrange $rhymelist 0 $len]

	set outfnam $evv(RHYME_SORT)$evv(TEXT_EXT)
	if [catch {open $outfnam "w"} zit] {
		Inf "Cannot Open File $outfnam To Write New Data"
		return 0
	}
	foreach wd $rhymelist {
		puts $zit $wd
	}
	close $zit
	set msg ""
	FileToWkspace $outfnam 0 0 0 0 1
	append msg "Rhymes In File '$outfnam'"
	Inf $msg
	return 1
}

#----- Check New Rhymes: if OK, enter into Rhyme Dictionary

proc CheckForNewRhymes {in_fnam} {
	global propwords gotpropwords propfile rhdic pr_nurhym rhstats wstk tstats_nurhymes tstats_nurhyme_pairs evv wl rememd
	set nwfnam $evv(NEW_WORDS)$evv(TEXT_EXT)
	set rhfnam $evv(NEW_RHYMES)$evv(TEXT_EXT)
	set dicfnam [file join $evv(URES_DIR) $evv(RHYME_DICTIONARY)$evv(CDP_EXT)]
	set propfile [GetPropsDataFromFile $in_fnam]
	if {[string length $propfile] <= 0} {
		return
	}
	if {![info exists propwords]} {
		Inf "No Words Found"
		return
	}
	set f .nurhym
	if [Dlg_Create $f "New Rhymes from [file rootname [file tail $propfile]]" "set pr_nurhym 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.h -text Help -command HelpRhymeCheck -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.f -text "Find New Rhymes" -command "set pr_nurhym 1" -highlightbackground [option get . background {}]
		button $f.0.q -text Quit -command "set pr_nurhym 0" -highlightbackground [option get . background {}]
		pack $f.0.h $f.0.f -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		button $f.1.r -text "Recheck Rhymes"  -command "set pr_nurhym 2"  -width 28 -highlightbackground [option get . background {}]
		label $f.1.a -text "" -fg [option get . foreground {}]
		button $f.1.d -text "" -command {} -width 28 -bd 0 -highlightbackground [option get . background {}]
		pack $f.1.r $f.1.a $f.1.d  -side top -pady 4
		pack $f.1 -side top -pady 2
		frame $f.2
		set rhstats [Scrolled_Listbox $f.2.ll -width 40 -height 40 -selectmode single]
		pack $f.2.ll -side top
		pack $f.2 -side top

		wm resizable $f 1 1
		bind $f <Escape>  {set pr_nurhym 0}
		bind $f <Return>  {set pr_nurhym 1}
	}
	set pr_nurhym 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_nurhym $f
	set finished 0
	while {!$finished} {
		tkwait variable pr_nurhym
		switch -- $pr_nurhym {
			0 {
				set finished 1
			}
			1 {
				if {[file exists $nwfnam]} {
					if {![DeleteFileFromSystem $nwfnam 0 1]} {
						Inf "Cannot Delete Existing File '$nwfnam'"
						continue
					} else {
						DummyHistory $nwfnam "DESTROYED"
						set i [LstIndx $nwfnam $wl]
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
				if {[file exists $rhfnam]} {
					if {![DeleteFileFromSystem $rhfnam 0 1]} {
						Inf "Cannot Delete Existing File '$rhfnam'"
						continue
					} else {
						DummyHistory $rhfnam "DESTROYED"
						set i [LstIndx $rhfnam $wl]
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
				Block "Rhyme Check"
				if {![info exists rhdic]} {
					if {[file exists $dicfnam]} {
						if [catch {open $dicfnam "r"} zit] {
							Inf "Cannot Open File '$dicfnam' To Read Existing Word-Rhyme Data"
							UnBlock
							continue
						}
						while {[gets $zit line] >= 0} {
							set line [string trim $line]
							if {[string length $line] <= 0} {
								continue
							}
							lappend rhdic $line
						}
						close $zit
						if {[llength $rhdic] <= 0} {
							unset rhdic
						}
					}
				}

				;#	SPLIT AT HYPHENS

				foreach word $propwords {
					if {[string match $word $evv(NULL_PROP)]} {
						continue
					}
					set len [string length $word]
					set endindx [expr $len - 1]
					set k [string first "-" $word]
					if {$k >= 0} {
						while {$k >= 0} {
							if {$k == 0} {
								set word [string range $word 1 end]
								incr len -1
								incr endindx -1
								set k [string first "-" $word]
								if {$k < 0} {
									lappend nuwords $word
									break
								}
							} else {
								lappend nuwords [string range $word 0 [expr $k - 1]]
								if {$k < $endindx} {
									set word [string range $word [expr $k + 1] end]
									set len [string length $word]
									set endindx [expr $len - 1]
									set k [string first "-" $word]
									if {$k < 0} {
										lappend nuwords $word
										break
									}
								} else {
									break
								}
							}
						}
					} else {
						lappend nuwords $word
					}
				}
				if {![info exists nuwords]} {
					Inf "No True Word Data Recovered"
					continue
				}
				set endings $nuwords
				unset nuwords

				;#	REMOVE APOSTROPHES, COMMAS, FULL STOPS

				foreach word $endings {
					set word [string tolower $word]
					set len [string length $word]
					set k 0
					while {$k < $len} {
						set char [string index $word $k]
						if {![regexp {[a-z]} $char]} {
							set nuword ""
							if {$k > 0} {
								append nuword [string range $word 0 [expr $k - 1]]
							}
							incr k
							if {$k < $len} {
								append nuword [string range $word $k end]
							}
							incr k -1
							set word $nuword
							incr len -1
						} else {
							incr k
						}
					}
					lappend nuwords $word
				}
				if {![info exists nuwords]} {
					Inf "No True Word Data Recovered"
					continue
				}
				set endings $nuwords
				unset nuwords

				set nuwordlist $endings
				set len [llength $nuwordlist]
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {				;#	REMOVE DUPLICATES
					set word_n [lindex $nuwordlist $n]
					set m $n
					incr m 
					while {$m < $len} {
						set word_m [lindex $nuwordlist $m]
						if {[string match $word_n $word_m]} {
							set nuwordlist [lreplace $nuwordlist $m $m]
							incr len_less_one -1
							incr len -1
						} else {
							incr m
						}
					}
					incr n
				}
				if {[info exists rhdic]} {					;#	REMOVE WORDS ALREADY IN DICTIONARY
					set len [llength $nuwordlist]
					set n 0
					while {$n < $len} {
						set word [lindex $nuwordlist $n]
						if {[lsearch $rhdic $word] >= 0} {
							set nuwordlist [lreplace $nuwordlist $n $n]
							incr len -1
						} else {
							incr n
						}
					}
				}
				set len [llength $nuwordlist]
				if {$len <= 0} {
					Inf "No New Words"
					UnBlock
					continue
				}
				set nuwordlist [lsort -dictionary $nuwordlist]
				if [catch {open $nwfnam "w"} zit] {
					Inf "Cannot Open File '$nwfnam' To Write New Words Discovered"
					UnBlock
					continue
				}
				foreach word $nuwordlist {
					puts $zit $word
				}
				close $zit
				FileToWkspace $nwfnam 0 0 0 0 1
				if {![TestRhymeExtraction $nuwordlist]} {
					Inf "New Words Found Are In File '$nwfnam'"
					UnBlock
					continue
				}
				$rhstats delete 0 end
				foreach {word rhyme} $tstats_nurhyme_pairs {
					set line $word
					append line "   " $rhyme
					$rhstats insert end $line
				}
				UnBlock
				$f.1.a config -text "ONLY if rhymes are VALID" -fg $evv(SPECIAL)
				$f.1.d config -text "Add New Rhymes To Dictionary" -command "set pr_nurhym 3" -bd 2 -bg $evv(EMPH)
			}
			2 {
				if {![file exists $nwfnam]} {
					Inf "No Wordlist To Check (should Be In File '$nwfnam')"
					continue
				}
				if {[file exists $rhfnam]} {
					if {![DeleteFileFromSystem $rhfnam 0 1]} {
						Inf "Cannot Delete Existing File '$rhfnam'"
						continue
					} else {
						DummyHistory $rhfnam "DESTROYED"
						set i [LstIndx $rhfnam $wl]
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
				Block "Rhyme Check"
				if {![TestRhymeExtraction 1]} {
					UnBlock
					continue
				}
				$rhstats delete 0 end
				foreach {word rhyme} $tstats_nurhyme_pairs {
					set line $word
					append line "   " $rhyme
					$rhstats insert end $line
				}
				UnBlock
				$f.1.a config -text "ONLY if rhymes are VALID" -fg $evv(SPECIAL)
				$f.1.d config -text "Add New Rhymes To Dictionary" -command "set pr_nurhym 3" -bd 2 -bg $evv(EMPH)
			}
			3 {
				if {![info exists tstats_nurhymes]} {
					Inf "No Data To Save"
					continue
				}
				set msg "Only Add Words To The Dictionary If Absolutely Certain That\n"
				append msg "Associated Rhymes Are Valid.\n\n"
				append msg "Add These Rhymed Words To Dictionary ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				Block "Saving Rhymes"
				if {[info exists rhdic]} {					;#	REMOVE WORDS ALREADY IN DIC
					set len [llength $tstats_nurhymes]
					set n 0
					while {$n < $len} {
						set word [lindex $tstats_nurhymes $n]
						if {[lsearch $rhdic $word] >= 0} {
							set tstats_nurhymes [lreplace $tstats_nurhymes $n $n]
							incr len -1
						} else {
							incr n
						}
					}
				}
				if {[llength $tstats_nurhymes] <= 0} {
					Inf "No New Words To Save"
					catch {unset tstats_nurhymes}
					UnBlock
					continue
				}
				if {[info exists rhdic]} {
					set new_rhdic $rhdic
				} else {
					set new_rhdic {}
				}
				set new_rhdic [concat $new_rhdic $tstats_nurhymes]				
				set new_rhdic [lsort -dictionary $new_rhdic ]
				set tmpfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
				if [catch {open $tmpfnam "w"} zit] {
					Inf "Cannot Open Temporary File '$tmpfnam' To Write New Dictionary Data"
					UnBlock
					continue
				}
				foreach word $new_rhdic {
					puts $zit $word
				}
				close $zit
				if [catch {file delete $dicfnam} zit] {
					Inf "Cannot Delete Existing Dictionary File '$dicfnam'"	
					catch {file delete $tmpfnam}
					UnBlock
					continue
				}
				if [catch {file rename $tmpfnam $dicfnam} zit] {
					set msg "Cannot Rename New Dictionary File '$tmpfnam' To '$dicfnam'\n\n"
					append msg "Do This, Outside The Soundloom, Before Closing This Dialogue Box."
					Inf $msg
				} else {
					Inf "Dictionary Saved"
				}
				catch {file delete $tmpfnam}
				set rhdic $new_rhdic 
				UnBlock
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- Help Info for RhymeCheck Window

proc HelpRhymeCheck {} {
	global evv
	set nwfnam $evv(NEW_WORDS)$evv(TEXT_EXT)
	set rhfnam $evv(NEW_RHYMES)$evv(TEXT_EXT)
	set msg "HOW TO USE THE RHYME CHECK\n"
	append msg "\n"
	append msg "\"Find New Rhymes\" looks for NEW words\n"
	append msg "in \"Text\" property of Properties File\n"
	append msg "and generates the appropriate phonetic-rhyme equivalents.\n"
	append msg "\n"
	append msg "New words will be stored in file \"$nwfnam\" on the Workspace, and\n"
	append msg "words PLUS corresponding rhymes in file \"$rhfnam\" on Workspace.\n"
	append msg "\n."
	append msg "If any of the rhyme-associations are unsatisfactory....\n"
	append msg "\n"
	append msg "(1)    delete all GOOD rhyme-associations from \"$nwfnam\".\n"
	append msg "(1)    Close the Loom.\n"
	append msg "(3)    Rejig the rhyme-scheme program.\n"
	append msg "(4)    Relaunch the Loom.\n"
	append msg "(5)    Use the \"Recheck Rhymes\" button to check the data again.\n"
	append msg "\n"
	append msg "When satisfied with the rhyme-associations,\n"
	append msg "back up the new words to the Rhyme Dictionary (button will appear)\n"
	Inf $msg
}

#---- Search texts for specified rhymes

proc FindSpecifiedRhymesInTextsOfTextPropertyInAllFiles {wordstarts} {
	global props_info pr_totrhymes totrhymesfnam rhymelist rhymesrclist wl evv pa wstk

	set alpha 0 
	if {$wordstarts} {
		set msg "Wordstarts Data Normally Sorted Numerically: Sort Alphabetically ??"
	} else {
		set msg "rhyme Data Normally Sorted Numerically: Sort Reverse Alphabetically ??"
	}
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "yes"} {
		set alpha 1
	}
	if {$wordstarts} {
		set suffix "_sttstats"
		Block "Finding Wordstart Statistics"
		set r_hyme "WORDSTARTS"
	} else {
		set suffix "_rhystats"
		Block "Finding Rhyme Statistics"
		set r_hyme "RHYMES"
	}
	set allrhymestats [file join $evv(URES_DIR) $suffix$evv(CDP_EXT)]
	if {![file exists $allrhymestats]} {
		set msg "No Overall Statistics Exist For $r_hyme File ($allrhymestats): Generate Them ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			if {![GenerateOverallRhymeStats $suffix $wordstarts]} {
				UnBlock
				return
			}
		} else {
			UnBlock
			return
		}
	} else {
		set msg "Overall Statistics Exist For $r_hyme File ($allrhymestats): Use These ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			if {![GenerateOverallRhymeStats $suffix $wordstarts]} {
				UnBlock
				return
			}
		}
	}
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) *$suffix$evv(CDP_EXT)]] {
		lappend rhystatfnams $fnam
	}
	set k [lsearch $rhystatfnams $allrhymestats]
	if {$k >= 0} {
		set rhystatfnams [lreplace $rhystatfnams $k $k]
	}
	if {![info exists rhystatfnams] || ([llength $rhystatfnams] <= 0)} {
		Inf "NO STATISTICS EXIST FOR $r_hyme"
		UnBlock
		return
	}
	wm title .blocker "PLEASE WAIT:        FINDING ASSOCIATED PROPERTIES FILES"
	foreach fnam $rhystatfnams {
		set nam [file rootname [file tail $fnam]]
		set k [string first $suffix $nam]
		incr k -1
		set nam [string range $nam 0 $k]
		append nam [GetTextfileExtension props]
		set foundit 0
		foreach zfnam [$wl get 0 end] {
			if {[string match [file tail $zfnam] $nam]} {
				lappend propfilenams $zfnam
				set foundit 1
				break
			}
		}
		if {!$foundit} {
			lappend propfilenams 0
			lappend missing $nam
		}
	}
	if {[info exists missing]} {
		set msg "If You Are Interested In The Following Property Files: They Need To Be On The Workspace\n"
		foreach fnam $missing {
			append msg "$fnam\n"
		}
		append msg "Get (Some Of) These Property Files To The Workspace ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			UnBlock
			return
		} else {
			set len [llength $propfilenams]
			set k 0
			while {$k < $len} {
				if {[string match [lindex propfilenams $k] "0"] {
					set propfilenams [lreplace $propfilenams $k $k]
					set rhystatfnams [lreplace $rhystatfnams $k $k]
					incr len -1
				} else {
					incr k
				}
			}
		}
	}
	if {$len == 0}
		UnBlock
		return
	}
	if [catch {open $allrhymestats "r"} zit] {
		Inf "Cannot Open $r_hyme Data File ($allrhymestats) To Read $r_hyme Data"
		UnBlock
		return
	}
	wm title .blocker "PLEASE WAIT:        SEARCHING $r_hyme STATISTICS"
	catch {unset rhymestatslist}
	catch {unset rhymes}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[llength $line] > 0} {
			lappend rhymestatslist $line
		}
	}
	close $zit
	if {![info exists rhymestatslist]} {
		Inf "No Data In $r_hyme Data File ($allrhymestats)"
		UnBlock
		return
	}
	foreach line $rhymestatslist {
		set line [string trim $line]
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					lappend frqs $item
				}
				1 {
					lappend rhymes $item
				}
			}
			incr cnt
		}
		if {$cnt != 2} {
			Inf "Invalid Data ($line) In $r_hyme Data File ($allrhymestats)"
			UnBlock
			return
		}
	}
	wm title .blocker "PLEASE WAIT:        SORTING $r_hyme STATISTICS"
	set len [llength $rhymestatslist]
	set len_less_one [expr $len - 1]
	set n 0
	if {$alpha} {
		while {$n < $len_less_one} {
			set rhyme_n [lindex $rhymes $n]
			set m $n
			incr m
			while {$m < $len} {
				set rhyme_m [lindex $rhymes $m]
				if {[LaterRhymeString $rhyme_n $rhyme_m $wordstarts]} {
					set r_n [lindex $rhymestatslist $n]
					set r_m [lindex $rhymestatslist $m]
					set rhymestatslist [lreplace $rhymestatslist $n $n $r_m]
					set rhymestatslist [lreplace $rhymestatslist $m $m $r_n]
					set r_n [lindex $rhymes $n]
					set r_m [lindex $rhymes $m]
					set rhymes [lreplace $rhymes $n $n $r_m]
					set rhymes [lreplace $rhymes $m $m $r_n]
					set rhyme_n $rhyme_m
				}
				incr m
			}
			incr n
		}
	} else {
		while {$n < $len_less_one} {
			set frq_n [lindex $frqs $n]
			set m $n
			incr m
			while {$m < $len} {
				set frq_m [lindex $frqs $m]
				if {$frq_m > $frq_n} {
					set r_n [lindex $rhymestatslist $n]
					set r_m [lindex $rhymestatslist $m]
					set rhymestatslist [lreplace $rhymestatslist $n $n $r_m]
					set rhymestatslist [lreplace $rhymestatslist $m $m $r_n]
					set r_n [lindex $rhymes $n]
					set r_m [lindex $rhymes $m]
					set rhymes [lreplace $rhymes $n $n $r_m]
					set rhymes [lreplace $rhymes $m $m $r_n]
					set frqs [lreplace $frqs $n $n $frq_m]
					set frqs [lreplace $frqs $m $m $frq_n]
					set frq_n $frq_m
				}
				incr m
			}
			incr n
		}
	}
	set len [llength $propfilenams]
	set n 0
	while {$n < $len} {
		set fnam [lindex $propfilenams $n]
		wm title .blocker "PLEASE WAIT:        EXTRACTING DATA FROM PROPERTY FILE [file rootname [file tail $fnam]]"
		if {![ThisIsAPropsFile $fnam 0 0]} {
			set msg "$fnam Is Not A Properties File: Continue Without It ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				UnBlock
				return
			} else {
				set rhystatfnams [lreplace $rhystatfnams $n $n]
				set propfilenams [lreplace $propfilenams $n $n]
				incr len -1
				continue
			}
		} else {
			set theseprops [lindex $props_info 0]
			set k [lsearch $theseprops "text"]
			if {$k < 0} {
				set k [lsearch $theseprops "Text"]
				if {$k < 0} {
					set k [lsearch $theseprops "TEXT"]
				}
			}
			if {$k < 0} {
				set msg "No Text Property In File $fnam: Continue Without It ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					UnBlock
					return
				} else {
					set rhystatfnams [lreplace $rhystatfnams $n $n]
					set propfilenams [lreplace $propfilenams $n $n]
					incr len -1
					continue
				}
			}
			incr k
			set theseprops  [lindex $props_info 1]
			foreach line $theseprops {
				lappend txtsdata($fnam) [lindex $line $k]
				lappend sndsdata($fnam) [lindex $line 0]
			}
		}
		incr n
	}
	if {$len <= 0} {
		Inf "No Valid Property Data"
		UnBlock
		return
	}

	wm title .blocker "PLEASE WAIT:        READING $r_hyme DATA FOR EACH PROPERTY FILE"
	catch {unset rhymedata}
	set k 0
	set len [llength $rhystatfnams]
	while {$k < $len} {
		set fnam [lindex $rhystatfnams $k]
		set srcfnam [lindex $propfilenams $k]
		
		if [catch {open $fnam "r"} zit] {
			set msg "Cannot Open $r_hyme Data File ($fnam) To Read $r_hyme Data: Continue Without It ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				UnBlock
				return
			} else {
				set rhystatfnams [lreplace $rhystatfnams $k $k]
				set propfilenams [lreplace $propfilenams $k $k]
				unset txtsdata($srcfnam)
				unset sndsdata($srcfnam)
				incr len -1
				continue
			}
		}
		catch {unset inlist}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[llength $line] > 0} {
				lappend inlist $line
			}
		}
		if {![info exists inlist]} {
			set msg "No Data In $r_hyme Data File ($fnam): Continue Without It ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				UnBlock
				return
			} else {
				set rhystatfnams [lreplace $rhystatfnams $k $k]
				set propfilenams [lreplace $propfilenams $k $k]
				unset txtsdata($srcfnam)
				unset sndsdata($srcfnam)
				incr len -1
				continue
			}
		}
		foreach line $inlist {
			set line [string trim $line]
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt == 0} {					;#	DATA STRUCTURE IS rhyme count propline1 [propline2 ....]
					set rhymeitem $item
				} elseif {$cnt > 1} {
					lappend rhymedata($srcfnam,$rhymeitem) $item
				}
				incr cnt
			}
			if {$cnt < 3} {
				set msg "Invalid Data ($line) In $r_hyme Data File ($fnam): Continue Without It ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					UnBlock
					return
				} else {
					unset rhymedata($srcfnam,$item)
					continue
				}
			}
		}
		incr k
	}
	UnBlock
	if {$len <= 0} {
		Inf "NO VALID $r_hyme DATA"
		return
	}
	set f .totrhymes
	if [Dlg_Create $f "FIND ITEMS FROM PROPERTY RHYME STATISTICS" "set pr_totrhymes 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.h -text Help -command HelpFindRhymes -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.t -text "Find Texts with Rhymes" -command "set pr_totrhymes 1" -highlightbackground [option get . background {}]
		button $f.0.s -text "Save Sounds with Rhymes" -command "set pr_totrhymes 2" -highlightbackground [option get . background {}]
		button $f.0.r -text "Restart"  -command "set pr_totrhymes 3" -highlightbackground [option get . background {}]
		button $f.0.q -text Quit -command "set pr_totrhymes 0" -highlightbackground [option get . background {}]
		pack $f.0.h $f.0.t $f.0.s $f.0.r -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output sndlistfile name "
		entry $f.1.e  -textvariable totrhymesfnam -width 20
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -pady 2
		frame $f.2
		label $f.2.l1 -text "PHONETIC REPRESENTATION" -fg $evv(SPECIAL)
		label $f.2.l2 -text "\".\" (schwa) ~ \":\" (hurt) ~ \"a\" (cat) ~ \"A\" (cart)  ~ \"4\" (rate) ~ \"e\" (bet) ~ \"E\" (bare) ~ \"i\" (bit) ~ \"I\" (beet) ~ \"o\" (pot) ~ \"O\" (port) ~ \"@\" (rote) ~ \"u\" (foot) ~ \"U\" (boot)" -fg $evv(SPECIAL)
		label $f.2.l3 -text "\[then diphthongs \"ai\" (kite) \"iU\" (beauty) etc\]                              \"m\"   \"n\"   \"N\" (=ng as in ring)   \"l\"   \"r\"                              \"b\"   \"d\"   \"g\"   \"k\"   \"p\"   \"t\"" -fg $evv(SPECIAL)
		label $f.2.l4 -text "\"T\" (=th in lath)   \"7\" (=th in that)    \"h\"   \"X\" (=ch in loch)   \"f\"   \"v\"   \"j\"   \"s\"   \"S\" (=sh)   \"z\"   \"Z\" (=zh in occassion)  \"C\" (=ch in arch)" -fg $evv(SPECIAL)
		pack $f.2.l1 $f.2.l2 $f.2.l3 $f.2.l4 -side top
		pack $f.2 -side top
		frame $f.3
		set rhymesrclist [Scrolled_Listbox $f.3.ll1 -width 20 -height 40 -selectmode single]
		set rhymelist    [Scrolled_Listbox $f.3.ll2 -width 80 -height 40 -selectmode single]
		pack $f.3.ll1 $f.3.ll2 -side left
		pack $f.3 -side top

		wm resizable $f 1 1
		bind $f <Escape> {set pr_totrhymes 0}
	}
	wm title $f "FIND ITEMS FROM PROPERTY $r_hyme STATISTICS"
	.totrhymes.0.r config -state disabled
	.totrhymes.0.s config -state disabled
	.totrhymes.1.ll config -text ""
	.totrhymes.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
	set pr_totrhymes 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_totrhymes $f
	set finished 0
	$rhymesrclist delete 0 end
	$rhymelist delete 0 end
	foreach item $rhymestatslist {
		$rhymelist insert end $item
	}
	while {!$finished} {
		tkwait variable pr_totrhymes
		switch -- $pr_totrhymes {
			1 {
				.totrhymes.0.s config -state disabled
				.totrhymes.1.ll config -text ""
				.totrhymes.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
				set i [$rhymelist curselection]
				if {$i < 0} {
					Inf "No Item Selected"
					continue
				}
				catch {unset outsnds}
				.totrhymes.0.t config -state disabled
				.totrhymes.0.r config -state normal
				Block "Finding Texts with Rhymes"
				set thisrhyme [lindex $rhymes $i]
				$rhymelist delete 0 end
				foreach rhymenam [array names rhymedata] {
					set rhymenam [split $rhymenam ","]
					set thatsrc   [lindex $rhymenam 0]
					set thatrhyme [lindex $rhymenam 1]
					if {[string match $thisrhyme $thatrhyme]} {
						foreach item $rhymedata($thatsrc,$thatrhyme) {
							set line [file rootname [file tail $thatsrc]]
							$rhymesrclist insert end $line
							set line [lindex $txtsdata($thatsrc) $item]
							lappend outsnds [lindex $sndsdata($thatsrc) $item]
							$rhymelist insert end $line
						}
					}
				}
				UnBlock
				.totrhymes.0.s config -state normal
				.totrhymes.1.ll config -text "Output sndlistfile name "
				.totrhymes.1.e config -bd 2 -state normal
			}
			2 {
				if {![info exists outsnds]} {
					Inf "No Sounds Yet Specified"
					continue
				}
				if {[string length $totrhymesfnam] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				if {![ValidCDPRootname $totrhymesfnam]} {
					continue
				}
				set outfnam [string tolower $totrhymesfnam]
				append outfnam [GetTextfileExtension sndlist]
				if {[file exists $outfnam]} {
					Inf "File '$outfnam' Already Exists: Please Chose Another Name"
					continue
				}
				Block "Finding Sounds with Rhymes"
				if [catch {open $outfnam "w"} zit] {
					Inf	"Cannot Open File '$outfnam'"
					continue
				}
				foreach filenam $outsnds {
					puts $zit $filenam
				}
				close $zit
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "The File '$outfnam' Is On The Workspace"
				UnBlock
				.totrhymes.0.s config -state disabled
				.totrhymes.1.ll config -text ""
				.totrhymes.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			} 
			3 {
				.totrhymes.0.t config -state normal
				.totrhymes.0.s config -state disabled
				.totrhymes.0.r config -state disabled
				.totrhymes.1.ll config -text ""
				.totrhymes.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
				$rhymelist delete 0 end
				$rhymesrclist delete 0 end
				foreach item $rhymestatslist {
					$rhymelist insert end $item
				}
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

proc HelpFindRhymes {} {

	set msg "FIND ITEMS FROM RHYME OR WORD-STARTS STATISTICS FROM PROPERTY FILE(S)"
	append msg ""
	append msg "This procedure assumes that statistics on the \"text\" property"
	append msg "of one or more property files have already been determined"
	append msg "using the \"By Frequncy\" option"
	append msg "(See the STATISTICS button on any property file with a \"text\" property)"
	append msg "and that a total (rhyme or word-starts) stats file has been made"
	append msg "(using the \"Add to Total Stats\" button)."
	append msg "Only rhymes (word-starts) added to the total stats will be accessed here."
	Inf $msg
}

#----- Generatea overall stats on rhymes or wordstarts from existing stats files fromfor individual property files

proc GenerateOverallRhymeStats {suffix wordstarts} {
	global evv wl
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) *$suffix$evv(CDP_EXT)]] {
		lappend rhystatfnams $fnam
	}
	if {![info exists rhystatfnams]} {
		Inf "No Text Stats To Analyse"
		return 0
	}
	foreach fnam $rhystatfnams {							;#	Find the property files from which they are sourced
		set nam [file rootname [file tail $fnam]]
		set k [string first $suffix $nam]
		incr k -1
		set nam [string range $nam 0 $k]
		append nam [GetTextfileExtension props]
		set foundit 0
		foreach zfnam [$wl get 0 end] {
			if {[string match [file tail $zfnam] $nam]} {
				lappend propfilenams $zfnam
				set foundit 1
				break
			}
		}
		if {!$foundit} {
			lappend propfilenams 0
			lappend missing $nam
		}
	}
	if {[info exists missing]} {
		set msg "The Following Property Files Must Be On The Workspace To Complete This Process\n"
		foreach fnam $missing {
			append msg "$fnam\n"
		}
		return 0
	}
	set fnam [file join $suffix]						;#	List all the property files in datafile
	append fnam "files" $evv(CDP_EXT)
	set fnam [file join $evv(URES_DIR) $fnam]
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Open File '$fnam' To List Names Of Stats Files"	
		return 0
	}
	foreach fnam $propfilenams {
		puts $zit $fnam
	}
	close $zit

	foreach fnam $rhystatfnams {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Read Stats Data"
			return 0
		}
		while {[gets $zit line] >= 0} {
			set line [split $line]
			set phrase [lindex $line 0]
			set cnt [lindex $line 1]
			if {[info exists totalsttstats($phrase)]} {
				incr totalsttstats($phrase)
			} else {
				set totalsttstats($phrase) $cnt 
			}
		}
		close $zit
	}
	foreach nam [array names totalsttstats] {
		lappend rhcnts [lindex $totalsttstats($nam) 0]
		lappend rhnams $nam
	}
	set len [llength $rhnams]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n [lindex $rhnams $n]
		set cnt_n [lindex $rhcnts $n]
		set m $n
		incr m
		while {$m < $len_less_one} {
			set nam_m [lindex $rhnams $m]
			set cnt_m [lindex $rhcnts $m]
			if {[LaterRhymeString $nam_n $nam_m $wordstarts]} {
				set rhcnts [lreplace $rhcnts $n $n $cnt_m]
				set rhnams [lreplace $rhnams $n $n $nam_m]
				set rhcnts [lreplace $rhcnts $m $m $cnt_n]
				set rhnams [lreplace $rhnams $m $m $nam_n]
				set cnt_n $cnt_m
				set nam_n $nam_m
			}
			incr m
		}
		incr n
	}
	catch {unset totalsttstats}
	foreach rhcnt $rhcnts rhnam $rhnams {
		lappend totalsttstats [list $rhcnt $rhnam]
	}
	set allrhymestats [file join $evv(URES_DIR) $suffix$evv(CDP_EXT)]
	if [catch {open $allrhymestats "w"} zit] {
		Inf "Cannot Open File '$fnam' To List Complete Stats Data"	
		return 0
	}
	foreach item $totalsttstats {
		puts $zit $item
	}
	close $zit
	return 1
}
