#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#------ Setup a canvas for a rough score

proc EstablishScore {new} {
	global small_screen score pr_score stage score_hzmargin score_vtmargin evv
	global score_left score_right score_chwidth scoresave commentsave score_comment
	global score_p1_top score_p1_bot score_p2_top score_p2_bot scorenameslist
	global score_p3_top score_p3_bot score_p4_top score_p4_bot wstk
	global scoreline1 scoreline2 scoreline3 score_vq upsave dnsave in_unattached_mode
	global localcomment comments_attached uppanelcnt dnpanelcnt uppanel dnpanel scoremixlist
	global score_loaded scoreclip scoredur scorecut sl_real wl new_score score_comment_bak
	global current_scorename pa

	set evv(SKSCORE_HEIGHT) [expr round(($evv(BRKF_HEIGHT)/3.0)*2)]

	if {$new > 0} {
		set ilist [$wl curselection]
		if {[llength $ilist] < 2} {
			if {$ilist < 0} {
				Inf "No Files Selected"
				return
			}
		}
		set OK 0
		foreach i $ilist {
			set fnam [$wl get $i]
			if {[info exists pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(FTYP)) == $evv(SNDFILE))} {
				lappend zfnams $fnam
				set OK 1
			}
		}
		if {!$OK} {
			Inf "None Of These Files Are Soundfiles"
			return
		}
		if {[GappedName $zfnams]} {
			return
		}
	}
	set new_score $new
	catch {destroy .cpd}
	set uppanelcnt 0 
	set dnpanelcnt 0 
	set in_unattached_mode 0 
	catch {unset scoreclip}
	catch {unset scoredur}
	set scorecut $evv(SCORECUT)

	set scoreline1 [expr round($evv(SKSCORE_HEIGHT)/4)]
	set scoreline2 [expr round($evv(SKSCORE_HEIGHT)/2)]
	set scoreline3 [expr $scoreline1 + $scoreline2]
	set score_chwidth 8				;# point size of characters
	catch {unset scoremixlist}
	
	set score_vq [expr $score_chwidth +2]

	set score_hzmargin [expr ($score_chwidth / 2) + 1]
	set score_vtmargin [expr $score_hzmargin + 2]
	set score_left $score_hzmargin
	set score_right [expr $evv(BRKF_WIDTH) - $score_hzmargin]
	set score_p1_top $score_vtmargin
	set score_p1_bot [expr $scoreline1 - $score_vtmargin]
	set score_p2_top [expr $scoreline1 + $score_vtmargin]
	set score_p2_bot [expr $scoreline2 - $score_vtmargin]
	set score_p3_top [expr $scoreline2 + $score_vtmargin]
	set score_p3_bot [expr $scoreline3 - $score_vtmargin]
	set score_p4_top [expr $scoreline3 + $score_vtmargin]
	set score_p4_bot [expr $evv(SKSCORE_HEIGHT) - $score_vtmargin]

	set f .score
	if {$small_screen} {
		set can [Scrolled_Canvas $f.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
							-scrollregion "0 0 $evv(BRKF_WIDTH) $evv(SCROLL_HEIGHT)"]
		pack $f.c -side top -fill x -expand true
		set k [frame $can.f -bd 0]
		$can create window 0 0 -anchor nw -window $k
		set score $k
	} else {
		set score $f
	}	
	if [Dlg_Create $f "SKETCH SCORE" "set pr_score 0" -borderwidth 2] {
		set sb [frame $score.btns -borderwidth 0]
		set sb2 [frame $score.btns2 -borderwidth 0]
		set dum [frame $score.dum -borderwidth 0 -bg [option get . foreground {}] -height 1]
		set dum2 [frame $score.dum2 -borderwidth 0 -bg [option get . foreground {}] -height 1]
		menubutton $sb2.hlp -text "Help" -width 6 -menu $sb2.hlp.menu -relief raised ;# -background $evv(HELP)
		set m [menu $sb2.hlp.menu -tearoff 0]
		$m add command -command {} -label "ADD SOUND"  -foreground black
		$m add separator
		$m add command -command {} -label "1) Use 'Get Sound' To choose (new) sound" -foreground black
		$m add command -command {} -label "2) Hold Control-Key and click mouse at position on score" -foreground black
		$m add separator
		$m add command -command {} -label "REMOVE SOUND (or Comment)" -foreground black
		$m add separator
		$m add command -command {} -label "Hold Control-Key & Shift-Key, click mouse over sound" -foreground black
		$m add separator
		$m add command -command {} -label "MOVE POSITION OF SOUND (or Comment)"  -foreground black
		$m add separator
		$m add command -command {} -label "Hold Shift-Key, Drag with Mouse" -foreground black
		$m add command -command {} -label "To move (closest) comment along with Sound, tick Checkbox" -foreground black
		$m add command -command {} -label "In Group Mode, select Snds &/or Comments 1-by-1, then Shift-Drag Group" -foreground black
		$m add separator
		$m add command -command {} -label "PLAY SOUND"  -foreground black
		$m add separator
		$m add command -command {} -label "Click Mouse On Soundfile Name (No keyboard keys depressed)" -foreground black
		$m add separator
		$m add command -command {} -label "PLAY START OR END OF SOUND ONLY"  -foreground black
		$m add separator
		$m add command -command {} -label "Put In 'Excerpt Mode', Click Mouse On Sndfile Name (see Mouse Action)" -foreground black
		$m add separator
		$m add command -command {} -label "CHOOSE SPECIFIC SOUND(S)"  -foreground black
		$m add separator
		$m add command -command {} -label "Put In 'Choose Mode' And Click Mouse On Soundfile Name" -foreground black
		$m add separator
		$m add command -command {} -label "ADD COMMENTS TO SCORE"  -foreground black
		$m add separator
		$m add command -command {} -label "Write Comment in Box, go to Comment mode, Control-Click place on Score" -foreground black
		$m add separator
		$m add command -command {} -label "TEST SEQUENCES OF SOUNDS"  -foreground black
		$m add separator
		$m add command -command {} -label "Full Mix End-to-end (with Overlap): Files follow on from one another." -foreground black
		$m add command -command {} -label "Full Mix With Timestep : Mix, entries staggered by timestep (safe attenuation)." -foreground black
		$m add command -command {} -label "Join File2 To End Of File1" -foreground black
		$m add command -command {} -label "Overlap End File1 Over Start File2 : Specify overlap time, & what else to hear." -foreground black
		$m add command -command {} -label "Clips Mix : Join Clips of Sounds, of given length/style." -foreground black
		$m add separator
		$m add command -command {} -label "BUTTONS"  -foreground black
		$m add separator
		$m add cascade -command {} -label "Button Operations" -menu $m.b -foreground black
		$m add separator
		set mbut [menu $m.b -tearoff 0]
		$mbut add command -command {} -label "MODE"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "Change Mode            : Play,play Excerpt,choose or Group sounds, or add Comments to Score" -foreground black
		$mbut add separator
		$mbut add command -command {} -label "GET SOUNDS,   HEAR SEQUENCES"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "Get Sound                : Select Sound from elsewhere to place on Score" -foreground black
		$mbut add command -command {} -label "Test A Sequence     : Join (parts of) Sounds-on-score in sequence, and Play" -foreground black
		$mbut add separator
		$mbut add command -command {} -label "USE THE SOUNDS"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "Sounds To Wkspace : Score Sounds to Workspace, or to Chosen Files List on Wkspace" -foreground black
		$mbut add command -command {} -label "To & From B-Lists      : Score-Sounds in sequence to B-List (or all removed from a B-List)" -foreground black
		$mbut add separator
		$mbut add command -command {} -label "CREATE MIXFILES"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "List In Mixfile            : Score-Sounds in sequence to Mixfile for use later" -foreground black
		$mbut add separator
		$mbut add command -command {} -label "SOUND INFO"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "Duration : Find (total) duration of selected sound(s)" -foreground black
		$mbut add command -command {} -label "Origins    : Find references to file in Logs: View processes in Logs" -foreground black

		$mbut add separator
		$mbut add command -command {} -label "SCORE OPERATIONS"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "Erase Score                  : Clear the Display (including any unseen panels)" -foreground black
		$mbut add command -command {} -label "Restore Score             : Restore Previous (state of) Score" -foreground black
		$mbut add command -command {} -label "Save As Named Score  : Save the score, giving it a specific name" -foreground black
		$mbut add command -command {} -label "                                         : (NB score automatically saved & reloaded between Sessions)" -foreground black
		$mbut add command -command {} -label "                                         : (Save with name, ONLY if working on MORE THAN 1 score)" -foreground black
		$mbut add command -command {} -label "Load Named Score       : Load a Specific Score" -foreground black
		$mbut add command -command {} -label "Unlink Display               : Display no longer saved to Named Score (but still saved)" -foreground black
		$mbut add command -command {} -label "Destroy Named Score : Destroy a Specific Score" -foreground black
		$mbut add separator
		$mbut add command -command {} -label "ERASE AND RESTORE COMMENTS"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "Erase And Restore Comments: or permanently remove all comments on score." -foreground black
		$mbut add separator
		$mbut add command -command {} -label "SCROLLING"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "Scroll Up, Down    : Scroll score up or down (unseen panels are not lost!)" -foreground black
		$mbut add separator
		$mbut add command -command {} -label "REFER TO MIXFILES"  -foreground black
		$mbut add separator
		$mbut add command -command {} -label "Add Mixfile To Viewing List : Find mixes you need to refer to" -foreground black
		$mbut add command -command {} -label "Add Sound To Existing Mix     : With possibly an overlap" -foreground black
		$mbut add command -command {} -label "View A Mixfile                         : See contents of a mixfile on your viewing list" -foreground black
		$mbut add command -command {} -label "View Same Mixile                     : See contents of same mixfile (No intervening edits shown)" -foreground black

		$m add command -command {} -label "MODES" -command {}  -foreground black
		$m add separator
		$m add cascade -command {} -label "Modes Of The Sketch Score" -menu $m.md -foreground black
		set mmode [menu $m.md -tearoff 0]
		$mmode add command -label "SOUND" -command {}  -foreground black
		$mmode add separator
		$mmode add command -label "Sounds Play when clicked on, and can be deleted, or dragged." -command {} -foreground black
		$mmode add separator
		$mmode add command -label "EXCERPT" -command {}  -foreground black
		$mmode add separator
		$mmode add command -label "End or Start of sound Plays, (or more of start or end) when clicked." -command {} -foreground black
		$mmode add separator
		$mmode add command -label "CHOOSE" -command {}  -foreground black
		$mmode add separator
		$mmode add command -label "Click to Add sound to Selection List, for Use as 'Selected Files'" -command {} -foreground black
		$mmode add command -label "      Selection list NOT deleted if you go to Comments mode." -command {} -foreground black
		$mmode add command -label "      to Destroy Selection List, go to Sound mode." -command {} -foreground black
		$mmode add separator
		$mmode add command -label "GROUP" -command {}  -foreground black
		$mmode add separator
		$mmode add command -label "Click to Add score-items to Group which can be Moved as a Whole." -command {} -foreground black
		$mmode add separator
		$mmode add command -label "COMMENT" -command {}  -foreground black
		$mmode add separator
		$mmode add command -label "Click to Enter Comments. which can be moved independently, & deleted." -command {} -foreground black
		$mmode add command -label "      Selection list NOT deleted when you are in Comments mode." -command {} -foreground black
		$m add separator
		$m add command -command {} -label "MOUSE ACTIONS (Click on Mode name, at Top Left) "  -foreground black

		frame $sb.bkgd
		if {!$sl_real} {
			button $sb.bkgd.bkgd -text "Get Snds" -width 10 -command TellGetSounds -highlightbackground [option get . background {}]
		} else {
			menubutton $sb.bkgd.bkgd -text "Get Snds" -width 10 -menu $sb.bkgd.bkgd.menu -relief raised
			set mbk [menu $sb.bkgd.bkgd.menu -tearoff 0]
			$mbk add command -label "From B-List" -command {GetBLName 12} -foreground black
			$mbk add separator
			$mbk add command -label "From Same B-List" -command {GetAnotherSoundToScore} -foreground black
			$mbk add separator
			$mbk add command -label "From Workspace" -command {GetSoundFromWkspace 0 1} -foreground black
			$mbk add separator
			$mbk add command -label "From Home Directory" -command {GetSoundFromWkspace 1 1} -foreground black
			$mbk add separator
			$mbk add command -label "From Workspace Chosen Files List" -command {GetSoundFromWkspace 2 1} -foreground black
			$mbk add separator
			$mbk add command -label "From Directory Of File Chosen On Score" -command {GetFileFromChosenFileDir} -foreground black
			$mbk add separator
			$mbk add command -label "From Elsewhere" -command {FileFind 2 0 1} -foreground black
		}
		if {!$sl_real} {
			button $sb.test -text "Test Seq" -width 9 -command TellTestMix -highlightbackground [option get . background {}]
		} else {
			menubutton $sb.test -text "Test Seq" -width 9 -menu $sb.test.menu -relief raised
			set mtt [menu $sb.test.menu -tearoff 0]
			$mtt add command -label "WHOLE SCORE, OR SCORE PANELS" -command {}  -foreground black
			$mtt add separator
			$mtt add cascade -label "Full Mix End-to-end (with Overlap)" -menu $mtt.sub20 -foreground black
			$mtt add separator
			$mtt add cascade -label "Full Mix With Timestep" -menu $mtt.sub0 -foreground black
			$mtt add separator
			$mtt add cascade -label "Clips Mix" -menu $mtt.sub1 -foreground black
			$mtt add separator
			$mtt add command -label "SELECTED FILES" -command {}  -foreground black
			$mtt add separator
			$mtt add command -label "Full Mix With Timestep" -command {ScoreTrueTestOut 0 0} -foreground black
			$mtt add separator
			$mtt add command -label "Join File2 To End Of File1" -command {ScoreTrueEndsTestOut 0} -foreground black
			$mtt add separator
			$mtt add command -label "Overlap End File1 Over Start File2" -command {ScoreTrueEndsTestOut 1} -foreground black
			$mtt add separator
			$mtt add cascade -label "Clips Mix" -command {ScoreTestOut 0} -foreground black

			set mtt0 [menu $mtt.sub0 -tearoff 0]
			$mtt0 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mtt0 add separator
			$mtt0 add command -label "All"  -command {ScoreTrueTestOut all 0} -foreground black
			$mtt0 add command -label "All Visible Panels"  -command {ScoreTrueTestOut 1234 0} -foreground black
			$mtt0 add separator
			$mtt0 add command -label "ADJACENT PANELS" -command {}  -foreground black
			$mtt0 add separator
			$mtt0 add command -label "Panels 1 + 2"  -command {ScoreTrueTestOut 12 0} -foreground black
			$mtt0 add command -label "Panels 1 + 2 + 3"  -command {ScoreTrueTestOut 123 0} -foreground black
			$mtt0 add command -label "Panels 2 + 3"  -command {ScoreTrueTestOut 23 0} -foreground black
			$mtt0 add command -label "Panels 2 + 3 + 4"  -command {ScoreTrueTestOut 234 0} -foreground black
			$mtt0 add command -label "Panels 3 + 4"  -command {ScoreTrueTestOut 34 0} -foreground black
			$mtt0 add separator
			$mtt0 add command -label "SINGLE PANELS"  -command {}  -foreground black
			$mtt0 add separator
			$mtt0 add command -label "Panel 1"  -command {ScoreTrueTestOut 1 0} -foreground black
			$mtt0 add command -label "Panel 2"  -command {ScoreTrueTestOut 2 0} -foreground black
			$mtt0 add command -label "Panel 3"  -command {ScoreTrueTestOut 3 0} -foreground black
			$mtt0 add command -label "Panel 4"  -command {ScoreTrueTestOut 4 0} -foreground black
			$mtt0 add separator
			$mtt0 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mtt0 add separator
			$mtt0 add command -label "Omit 1"  -command {ScoreTrueTestOut 234 0} -foreground black
			$mtt0 add command -label "Omit 2"  -command {ScoreTrueTestOut 134 0} -foreground black
			$mtt0 add command -label "Omit 3"  -command {ScoreTrueTestOut 124 0} -foreground black
			$mtt0 add command -label "Omit 4"  -command {ScoreTrueTestOut 123 0} -foreground black
			$mtt0 add separator
			$mtt0 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mtt0 add separator
			$mtt0 add command -label "Panel 1 + 3"  -command {ScoreTrueTestOut 13 0} -foreground black
			$mtt0 add command -label "Panel 2 + 4"  -command {ScoreTrueTestOut 24 0} -foreground black
			$mtt0 add command -label "Panel 1 + 4"  -command {ScoreTrueTestOut 14 0} -foreground black
			$mtt0 add command -label "Panel 1 + 2 + 4" -command {ScoreTrueTestOut 124 0} -foreground black
			$mtt0 add command -label "Panel 1 + 3 + 4" -command {ScoreTrueTestOut 134 0} -foreground black

			set mtt20 [menu $mtt.sub20 -tearoff 0]
			$mtt20 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mtt20 add separator
			$mtt20 add command -label "All"  -command {ScoreTrueTestOut all 1} -foreground black
			$mtt20 add command -label "All Visible Panels"  -command {ScoreTrueTestOut 1234 1} -foreground black
			$mtt20 add separator
			$mtt20 add command -label "ADJACENT PANELS" -command {}  -foreground black
			$mtt20 add separator
			$mtt20 add command -label "Panels 1 + 2"  -command {ScoreTrueTestOut 12 1} -foreground black
			$mtt20 add command -label "Panels 1 + 2 + 3"  -command {ScoreTrueTestOut 123 1} -foreground black
			$mtt20 add command -label "Panels 2 + 3"  -command {ScoreTrueTestOut 23 1} -foreground black
			$mtt20 add command -label "Panels 2 + 3 + 4"  -command {ScoreTrueTestOut 234 1} -foreground black
			$mtt20 add command -label "Panels 3 + 4"  -command {ScoreTrueTestOut 34 1} -foreground black
			$mtt20 add separator
			$mtt20 add command -label "SINGLE PANELS"  -command {}  -foreground black
			$mtt20 add separator
			$mtt20 add command -label "Panel 1"  -command {ScoreTrueTestOut 1 1} -foreground black
			$mtt20 add command -label "Panel 2"  -command {ScoreTrueTestOut 2 1} -foreground black
			$mtt20 add command -label "Panel 3"  -command {ScoreTrueTestOut 3 1} -foreground black
			$mtt20 add command -label "Panel 4"  -command {ScoreTrueTestOut 4 1} -foreground black
			$mtt20 add separator
			$mtt20 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mtt20 add separator
			$mtt20 add command -label "Omit 1"  -command {ScoreTrueTestOut 234 1} -foreground black
			$mtt20 add command -label "Omit 2"  -command {ScoreTrueTestOut 134 1} -foreground black
			$mtt20 add command -label "Omit 3"  -command {ScoreTrueTestOut 124 1} -foreground black
			$mtt20 add command -label "Omit 4"  -command {ScoreTrueTestOut 123 1} -foreground black
			$mtt20 add separator
			$mtt20 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mtt20 add separator
			$mtt20 add command -label "Panel 1 + 3"  -command {ScoreTrueTestOut 13 1} -foreground black
			$mtt20 add command -label "Panel 2 + 4"  -command {ScoreTrueTestOut 24 1} -foreground black
			$mtt20 add command -label "Panel 1 + 4"  -command {ScoreTrueTestOut 14 1} -foreground black
			$mtt20 add command -label "Panel 1 + 2 + 4" -command {ScoreTrueTestOut 124 1} -foreground black
			$mtt20 add command -label "Panel 1 + 3 + 4" -command {ScoreTrueTestOut 134 1} -foreground black

			set mtt1 [menu $mtt.sub1 -tearoff 0]
			$mtt1 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mtt1 add separator
			$mtt1 add command -label "All"  -command {ScoreTestOut all} -foreground black
			$mtt1 add command -label "All Visible Panels"  -command {ScoreTestOut 1234} -foreground black
			$mtt1 add separator
			$mtt1 add command -label "ADJACENT PANELS" -command {}  -foreground black
			$mtt1 add separator
			$mtt1 add command -label "Panels 1 + 2"  -command {ScoreTestOut 12} -foreground black
			$mtt1 add command -label "Panels 1 + 2 + 3"  -command {ScoreTestOut 123} -foreground black
			$mtt1 add command -label "Panels 2 + 3"  -command {ScoreTestOut 23} -foreground black
			$mtt1 add command -label "Panels 2 + 3 + 4"  -command {ScoreTestOut 234} -foreground black
			$mtt1 add command -label "Panels 3 + 4"  -command {ScoreTestOut 34} -foreground black
			$mtt1 add separator
			$mtt1 add command -label "SINGLE PANELS"  -command {}  -foreground black
			$mtt1 add separator
			$mtt1 add command -label "Panel 1"  -command {ScoreTestOut 1} -foreground black
			$mtt1 add command -label "Panel 2"  -command {ScoreTestOut 2} -foreground black
			$mtt1 add command -label "Panel 3"  -command {ScoreTestOut 3} -foreground black
			$mtt1 add command -label "Panel 4"  -command {ScoreTestOut 4} -foreground black
			$mtt1 add separator
			$mtt1 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mtt1 add separator
			$mtt1 add command -label "Omit 1"  -command {ScoreTestOut 234} -foreground black
			$mtt1 add command -label "Omit 2"  -command {ScoreTestOut 134} -foreground black
			$mtt1 add command -label "Omit 3"  -command {ScoreTestOut 124} -foreground black
			$mtt1 add command -label "Omit 4"  -command {ScoreTestOut 123} -foreground black
			$mtt1 add separator
			$mtt1 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mtt1 add separator
			$mtt1 add command -label "Panel 1 + 3"  -command {ScoreTestOut 13} -foreground black
			$mtt1 add command -label "Panel 2 + 4"  -command {ScoreTestOut 24} -foreground black
			$mtt1 add command -label "Panel 1 + 4"  -command {ScoreTestOut 14} -foreground black
			$mtt1 add command -label "Panel 1 + 2 + 4" -command {ScoreTestOut 124} -foreground black
			$mtt1 add command -label "Panel 1 + 3 + 4" -command {ScoreTestOut 134} -foreground black
		}
		frame $sb.real
		if {!$sl_real} {
			button $sb.real.real -text "Make Mix" -width 10 -command TellRealMix -highlightbackground [option get . background {}]
		} else {
			menubutton $sb.real.real -text "Make Mix" -width 10 -menu $sb.real.real.menu -relief raised
			set mtr [menu $sb.real.real.menu -tearoff 0]
			$mtr add command -label "MAKE MIXFILE OF WHOLE SCORE OR PANELS" -command {}  -foreground black
			$mtr add separator
			$mtr add cascade -label "All At Zero Time" -menu $mtr.menu1 -foreground black
			set mmm0 [menu $mtr.menu1 -tearoff 0]
			$mtr add separator
			$mtr add cascade -label "End To End" -menu $mtr.menu4 -foreground black
			set mmm1 [menu $mtr.menu4 -tearoff 0]
			$mtr add separator
			$mtr add cascade -label "With Timestep From Testmix" -menu $mtr.menu5 -foreground black
			set mmm2 [menu $mtr.menu5 -tearoff 0]
			$mtr add separator
			$mtr add cascade -label "With Overlap From Testmix " -menu $mtr.menu6 -foreground black
			set mmm3 [menu $mtr.menu6 -tearoff 0]
			$mtr add separator

			$mtr add command -label "MAKE MIXFILE FROM SELECTED FILES" -command {}  -foreground black
			$mtr add separator
			$mtr add command -label "All At Zero Time" -command {SaveScoreToMix 0 0} -foreground black
			$mtr add separator
			$mtr add command -label "End To End" -command {SaveScoreToMix 0 1} -foreground black
			$mtr add separator
			$mtr add command -label "With Timestep From Testmix" -command {SaveScoreToMix 0 2} -foreground black
			$mtr add separator
			$mtr add command -label "With Overlap From Testmix " -command {SaveScoreToMix 0 4} -foreground black
			$mtr add separator
			$mtr add command -label "With Overlap From 2 File Testmix" -command {SaveScoreToMix 0 3} -foreground black

			$mmm0 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mmm0 add separator
			$mmm0 add command -label "All"  -command {SaveScoreToMix all 0} -foreground black
			$mmm0 add command -label "All Visible Panels"  -command {SaveScoreToMix 1234 0} -foreground black
			$mmm0 add separator
			$mmm0 add command -label "ADJACENT PANELS ONLY" -command {}  -foreground black
			$mmm0 add separator
			$mmm0 add command -label "Panels 1 + 2"  -command {SaveScoreToMix 12 0} -foreground black
			$mmm0 add command -label "Panels 1 + 2 + 3"  -command {SaveScoreToMix 123 0} -foreground black
			$mmm0 add command -label "Panels 2 + 3"  -command {SaveScoreToMix 23 0} -foreground black
			$mmm0 add command -label "Panels 2 + 3 + 4"  -command {SaveScoreToMix 234 0} -foreground black
			$mmm0 add command -label "Panels 3 + 4"  -command {SaveScoreToMix 34 0} -foreground black
			$mmm0 add separator
			$mmm0 add command -label "SINGLE PANELS ONLY"  -command {}  -foreground black
			$mmm0 add separator
			$mmm0 add command -label "Panel 1"  -command {SaveScoreToMix 1 0} -foreground black
			$mmm0 add command -label "Panel 2"  -command {SaveScoreToMix 2 0} -foreground black
			$mmm0 add command -label "Panel 3"  -command {SaveScoreToMix 3 0} -foreground black
			$mmm0 add command -label "Panel 4"  -command {SaveScoreToMix 4 0} -foreground black
			$mmm0 add separator
			$mmm0 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mmm0 add separator
			$mmm0 add command -label "Omit 1"  -command {SaveScoreToMix 234 0} -foreground black
			$mmm0 add command -label "Omit 2"  -command {SaveScoreToMix 134 0} -foreground black
			$mmm0 add command -label "Omit 3"  -command {SaveScoreToMix 124 0} -foreground black
			$mmm0 add command -label "Omit 4"  -command {SaveScoreToMix 123 0} -foreground black
			$mmm0 add separator
			$mmm0 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mmm0 add separator
			$mmm0 add command -label "Panel 1 + 3"  -command {SaveScoreToMix 13 0} -foreground black
			$mmm0 add command -label "Panel 2 + 4"  -command {SaveScoreToMix 24 0} -foreground black
			$mmm0 add command -label "Panel 1 + 4"  -command {SaveScoreToMix 14 0} -foreground black
			$mmm0 add command -label "Panel 1 + 2 + 4" -command {SaveScoreToMix 124 0} -foreground black
			$mmm0 add command -label "Panel 1 + 3 + 4" -command {SaveScoreToMix 134 0} -foreground black

			$mmm1 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mmm1 add separator
			$mmm1 add command -label "All"  -command {SaveScoreToMix all 1} -foreground black
			$mmm1 add command -label "All Visible Panels"  -command {SaveScoreToMix 1234 1} -foreground black
			$mmm1 add separator
			$mmm1 add command -label "ADJACENT PANELS ONLY" -command {}  -foreground black
			$mmm1 add separator
			$mmm1 add command -label "Panels 1 + 2"  -command {SaveScoreToMix 12 1} -foreground black
			$mmm1 add command -label "Panels 1 + 2 + 3"  -command {SaveScoreToMix 123 1} -foreground black
			$mmm1 add command -label "Panels 2 + 3"  -command {SaveScoreToMix 23 1} -foreground black
			$mmm1 add command -label "Panels 2 + 3 + 4"  -command {SaveScoreToMix 234 1} -foreground black
			$mmm1 add command -label "Panels 3 + 4"  -command {SaveScoreToMix 34 1} -foreground black
			$mmm1 add separator
			$mmm1 add command -label "SINGLE PANELS ONLY"  -command {}  -foreground black
			$mmm1 add separator
			$mmm1 add command -label "Panel 1"  -command {SaveScoreToMix 1 1} -foreground black
			$mmm1 add command -label "Panel 2"  -command {SaveScoreToMix 2 1} -foreground black
			$mmm1 add command -label "Panel 3"  -command {SaveScoreToMix 3 1} -foreground black
			$mmm1 add command -label "Panel 4"  -command {SaveScoreToMix 4 1} -foreground black
			$mmm1 add separator
			$mmm1 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mmm1 add separator
			$mmm1 add command -label "Omit 1"  -command {SaveScoreToMix 234 1} -foreground black
			$mmm1 add command -label "Omit 2"  -command {SaveScoreToMix 134 1} -foreground black
			$mmm1 add command -label "Omit 3"  -command {SaveScoreToMix 124 1} -foreground black
			$mmm1 add command -label "Omit 4"  -command {SaveScoreToMix 123 1} -foreground black
			$mmm1 add separator
			$mmm1 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mmm1 add separator
			$mmm1 add command -label "Panel 1 + 3"  -command {SaveScoreToMix 13 1} -foreground black
			$mmm1 add command -label "Panel 2 + 4"  -command {SaveScoreToMix 24 1} -foreground black
			$mmm1 add command -label "Panel 1 + 4"  -command {SaveScoreToMix 14 1} -foreground black
			$mmm1 add command -label "Panel 1 + 2 + 4" -command {SaveScoreToMix 124 1} -foreground black
			$mmm1 add command -label "Panel 1 + 3 + 4" -command {SaveScoreToMix 134 1} -foreground black

			$mmm2 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mmm2 add separator
			$mmm2 add command -label "All"  -command {SaveScoreToMix all 2} -foreground black
			$mmm2 add command -label "All Visible Panels"  -command {SaveScoreToMix 1234 2} -foreground black
			$mmm2 add separator
			$mmm2 add command -label "ADJACENT PANELS ONLY" -command {}  -foreground black
			$mmm2 add separator
			$mmm2 add command -label "Panels 1 + 2"  -command {SaveScoreToMix 12 2} -foreground black
			$mmm2 add command -label "Panels 1 + 2 + 3"  -command {SaveScoreToMix 123 2} -foreground black
			$mmm2 add command -label "Panels 2 + 3"  -command {SaveScoreToMix 23 2} -foreground black
			$mmm2 add command -label "Panels 2 + 3 + 4"  -command {SaveScoreToMix 234 2} -foreground black
			$mmm2 add command -label "PANELS 3 + 4"  -command {SaveScoreToMix 34 2} -foreground black
			$mmm2 add separator
			$mmm2 add command -label "SINGLE PANELS ONLY"  -command {}  -foreground black
			$mmm2 add separator
			$mmm2 add command -label "Panel 1"  -command {SaveScoreToMix 1 2} -foreground black
			$mmm2 add command -label "Panel 2"  -command {SaveScoreToMix 2 2} -foreground black
			$mmm2 add command -label "Panel 3"  -command {SaveScoreToMix 3 2} -foreground black
			$mmm2 add command -label "Panel 4"  -command {SaveScoreToMix 4 2} -foreground black
			$mmm2 add separator
			$mmm2 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mmm2 add separator
			$mmm2 add command -label "Omit 1"  -command {SaveScoreToMix 234 2} -foreground black
			$mmm2 add command -label "Omit 2"  -command {SaveScoreToMix 134 2} -foreground black
			$mmm2 add command -label "Omit 3"  -command {SaveScoreToMix 124 2} -foreground black
			$mmm2 add command -label "Omit 4"  -command {SaveScoreToMix 123 2} -foreground black
			$mmm2 add separator
			$mmm2 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mmm2 add separator
			$mmm2 add command -label "Panel 1 + 3"  -command {SaveScoreToMix 13 2} -foreground black
			$mmm2 add command -label "Panel 2 + 4"  -command {SaveScoreToMix 24 2} -foreground black
			$mmm2 add command -label "Panel 1 + 4"  -command {SaveScoreToMix 14 2} -foreground black
			$mmm2 add command -label "Panel 1 + 2 + 4" -command {SaveScoreToMix 124 2} -foreground black
			$mmm2 add command -label "Panel 1 + 3 + 4" -command {SaveScoreToMix 134 2} -foreground black

			$mmm3 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mmm3 add separator
			$mmm3 add command -label "All"  -command {SaveScoreToMix all 4} -foreground black
			$mmm3 add command -label "All Visible Panels"  -command {SaveScoreToMix 1234 4} -foreground black
			$mmm3 add separator
			$mmm3 add command -label "ADJACENT PANELS ONLY" -command {}  -foreground black
			$mmm3 add separator
			$mmm3 add command -label "Panels 1 + 2"  -command {SaveScoreToMix 12 4} -foreground black
			$mmm3 add command -label "Panels 1 + 2 + 3"  -command {SaveScoreToMix 123 4} -foreground black
			$mmm3 add command -label "Panels 2 + 3"  -command {SaveScoreToMix 23 4} -foreground black
			$mmm3 add command -label "Panels 2 + 3 + 4"  -command {SaveScoreToMix 234 4} -foreground black
			$mmm3 add command -label "Panels 3 + 4"  -command {SaveScoreToMix 34 4} -foreground black
			$mmm3 add separator
			$mmm3 add command -label "SINGLE PANELS ONLY"  -command {}  -foreground black
			$mmm3 add separator
			$mmm3 add command -label "Panel 1"  -command {SaveScoreToMix 1 4} -foreground black
			$mmm3 add command -label "Panel 2"  -command {SaveScoreToMix 2 4} -foreground black
			$mmm3 add command -label "Panel 3"  -command {SaveScoreToMix 3 4} -foreground black
			$mmm3 add command -label "Panel 4"  -command {SaveScoreToMix 4 4} -foreground black
			$mmm3 add separator
			$mmm3 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mmm3 add separator
			$mmm3 add command -label "Omit 1"  -command {SaveScoreToMix 234 4} -foreground black
			$mmm3 add command -label "Omit 2"  -command {SaveScoreToMix 134 4} -foreground black
			$mmm3 add command -label "Omit 3"  -command {SaveScoreToMix 124 4} -foreground black
			$mmm3 add command -label "Omit 4"  -command {SaveScoreToMix 123 4} -foreground black
			$mmm3 add separator
			$mmm3 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mmm3 add separator
			$mmm3 add command -label "Panel 1 + 3"  -command {SaveScoreToMix 13 4} -foreground black
			$mmm3 add command -label "Panel 2 + 4"  -command {SaveScoreToMix 24 4} -foreground black
			$mmm3 add command -label "Panel 1 + 4"  -command {SaveScoreToMix 14 4} -foreground black
			$mmm3 add command -label "Panel 1 + 2 + 4" -command {SaveScoreToMix 124 4} -foreground black
			$mmm3 add command -label "Panel 1 + 3 + 4" -command {SaveScoreToMix 134 4} -foreground black

		}
		label  $sb2.expl -text "DROP IN NEW SOUNDS WITH Control Mouse-Click" -fg $evv(SPECIAL) -bg $evv(EMPH) -width 54
		button $sb2.scrup -text "Scroll Up" -width 9 -command {ScrollScore up} -highlightbackground [option get . background {}]
		button $sb2.scrdn -text "Down" -width 4 -command {ScrollScore dn} -highlightbackground [option get . background {}]
		menubutton  $sb2.slec -text "Sound Ops" -fg $evv(SPECIAL) -font bigfnt -width 14 -menu $sb2.slec.menu -bd 4
		frame $sb2.zz -width 1 -bg [option get . foreground {}]
		frame $sb2.zz2 -width 1 -bg [option get . foreground {}]
		set mh [menu $sb2.slec.menu -tearoff 0]
		$mh add command -command {} -label "Click                         : Play sound" -foreground black
		$mh add separator
		$mh add command -command {} -label "Control Click            : Put new file in score" -foreground black
		$mh add separator
		$mh add command -command {} -label "Control Shift Click    : Remove Sound (or Comment)" -foreground black
		$mh add separator
		$mh add command -command {} -label "Shift & Drag             : Move Sound (or comment) to new position" -foreground black
		$mh add separator
		$mh add command -command {} -label "(Close Comment can move with sound: Tick the check box)" -foreground black
		$mh add separator
		$mh add command -command {} -label "(Close = Start of Comment close to Start of SoundName)" -foreground black
		$mh add separator
		$mh add command -command {} -label "Control Command Click        : Grab Sound (to Paste Copy elsewhere)" -foreground black
		$mh add separator
		$mh add command -command {} -label "" -foreground black
		$mh add separator
		$mh add command -command {} -label "" -foreground black
		$mh add separator
		$mh add command -command {} -label "" -foreground black
		$mh add separator
		$mh add command -command {} -label "" -foreground black
		frame $sb.nbk
		menubutton $sb.nbk.nbk -text "Notebk"  -menu $sb.nbk.nbk.menu -relief raised -width 8 ;# -background $evv(HELP)
		button $sb.nbk.saver -text "Save" -command SaveScoreWithNewName -width 6 -highlightbackground [option get . background {}]
		pack $sb.nbk.saver $sb.nbk.nbk -side top -pady 2
		set m2 [menu $sb.nbk.nbk.menu -tearoff 0]
		$m2 add command -label "Read / Write" -command NnnSee -foreground black
		$m2 add separator
		$m2 add command -label "Selected Files To Notebook" -command {FilesToNotebook sc} -foreground black

		if {!$sl_real} {
			button $sb.bkgd.savw -text "Use Snds" -width 10 -command TellUseSnds -highlightbackground [option get . background {}]
		} else {
			menubutton $sb.bkgd.savw -text "Use Snds" -width 10 -menu $sb.bkgd.savw.menu -relief raised
			set mw [menu $sb.bkgd.savw.menu -tearoff 0]

			$mw add command -label "SEND WHOLE SCORE, OR SCORE PANELS" -command {}  -foreground black
			$mw add separator
			$mw add cascade -label "To Workspace" -menu $mw.menu0 -foreground black
			set mww0 [menu $mw.menu0 -tearoff 0]
			$mw add separator
			$mw add cascade -label "To Chosen Files List" -menu $mw.menu3 -foreground black
			set mww1 [menu $mw.menu3 -tearoff 0]
			$mw add separator
			$mw add cascade -label "To New B-List" -menu $mw.menu2 -foreground black
			set mss0 [menu $mw.menu2 -tearoff 0]
			$mw add separator
			$mw add command -label "REMOVE ALL SCORE SOUNDS" -command {}  -foreground black
			$mw add separator
			$mw add command -label "From Specified B-List" -command {GetBLName 15} -foreground black
			$mw add separator
			$mw add command -label "SEND SELECTED FILES" -command {}  -foreground black
			$mw add separator
			$mw add command -label "To Workspace" -command {ScoreToWkspace 0 0} -foreground black
			$mw add separator
			$mw add command -label "To Chosen Files List" -command {ScoreToWkspace 0 1} -foreground black
			$mw add separator
			$mw add cascade -label "To Existing B-List"  -command {GetBLName 16} -foreground black
			$mw add separator
			$mw add cascade -label "To New B-List"  -command {SaveScore 0} -foreground black
			$mw add separator
			$mw add command -label "" -command {} -state disabled -foreground black

			$mww0 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mww0 add separator
			$mww0 add command -label "All"  -command {ScoreToWkspace all 0} -foreground black
			$mww0 add command -label "All Visible Panels"  -command {ScoreToWkspace 1234 0} -foreground black
			$mww0 add separator
			$mww0 add command -label "ADJACENT PANELS ONLY" -command {}  -foreground black
			$mww0 add separator
			$mww0 add command -label "Panels 1 + 2"  -command {ScoreToWkspace 12 0} -foreground black
			$mww0 add command -label "Panels 1 + 2 + 3"  -command {ScoreToWkspace 123 0} -foreground black
			$mww0 add command -label "Panels 2 + 3"  -command {ScoreToWkspace 23 0} -foreground black
			$mww0 add command -label "Panels 2 + 3 + 4"  -command {ScoreToWkspace 234 0} -foreground black
			$mww0 add command -label "Panels 3 + 4"  -command {ScoreToWkspace 34 0} -foreground black
			$mww0 add separator
			$mww0 add command -label "SINGLE PANELS ONLY"  -command {}  -foreground black
			$mww0 add separator
			$mww0 add command -label "Panel 1"  -command {ScoreToWkspace 1 0} -foreground black
			$mww0 add command -label "Panel 2"  -command {ScoreToWkspace 2 0} -foreground black
			$mww0 add command -label "Panel 3"  -command {ScoreToWkspace 3 0} -foreground black
			$mww0 add command -label "Panel 4"  -command {ScoreToWkspace 4 0} -foreground black
			$mww0 add separator
			$mww0 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mww0 add separator
			$mww0 add command -label "Omit 1"  -command {ScoreToWkspace 234 0} -foreground black
			$mww0 add command -label "Omit 2"  -command {ScoreToWkspace 134 0} -foreground black
			$mww0 add command -label "Omit 3"  -command {ScoreToWkspace 124 0} -foreground black
			$mww0 add command -label "Omit 4"  -command {ScoreToWkspace 123 0} -foreground black
			$mww0 add separator
			$mww0 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mww0 add separator
			$mww0 add command -label "Panel 1 + 3"  -command {ScoreToWkspace 13 0} -foreground black
			$mww0 add command -label "Panel 2 + 4"  -command {ScoreToWkspace 24 0} -foreground black
			$mww0 add command -label "Panel 1 + 4"  -command {ScoreToWkspace 14 0} -foreground black
			$mww0 add command -label "Panel 1 + 2 + 4" -command {ScoreToWkspace 124 0} -foreground black
			$mww0 add command -label "Panel 1 + 3 + 4" -command {ScoreToWkspace 134 0} -foreground black
			
			$mww1 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mww1 add separator
			$mww1 add command -label "All"  -command {ScoreToWkspace all 1} -foreground black
			$mww1 add command -label "All Visible Panels"  -command {ScoreToWkspace 1234 1} -foreground black
			$mww1 add separator
			$mww1 add command -label "ADJACENT PANELS ONLY" -command {}  -foreground black
			$mww1 add separator
			$mww1 add command -label "Panels 1 + 2"  -command {ScoreToWkspace 12 1} -foreground black
			$mww1 add command -label "Panels 1 + 2 + 3"  -command {ScoreToWkspace 123 1} -foreground black
			$mww1 add command -label "Panels 2 + 3"  -command {ScoreToWkspace 23 1} -foreground black
			$mww1 add command -label "Panels 2 + 3 + 4"  -command {ScoreToWkspace 234 1} -foreground black
			$mww1 add command -label "Panels 3 + 4"  -command {ScoreToWkspace 34 1} -foreground black
			$mww1 add separator
			$mww1 add command -label "SINGLE PANELS ONLY"  -command {}  -foreground black
			$mww1 add separator
			$mww1 add command -label "Panel 1"  -command {ScoreToWkspace 1 1} -foreground black
			$mww1 add command -label "Panel 2"  -command {ScoreToWkspace 2 1} -foreground black
			$mww1 add command -label "Panel 3"  -command {ScoreToWkspace 3 1} -foreground black
			$mww1 add command -label "Panel 4"  -command {ScoreToWkspace 4 1} -foreground black
			$mww1 add separator
			$mww1 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mww1 add separator
			$mww1 add command -label "Omit 1"  -command {ScoreToWkspace 234 1} -foreground black
			$mww1 add command -label "Omit 2"  -command {ScoreToWkspace 134 1} -foreground black
			$mww1 add command -label "Omit 3"  -command {ScoreToWkspace 124 1} -foreground black
			$mww1 add command -label "Omit 4"  -command {ScoreToWkspace 123 1} -foreground black
			$mww1 add separator
			$mww1 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mww1 add separator
			$mww1 add command -label "Panel 1 + 3"  -command {ScoreToWkspace 13 1} -foreground black
			$mww1 add command -label "Panel 2 + 4"  -command {ScoreToWkspace 24 1} -foreground black
			$mww1 add command -label "Panel 1 + 4"  -command {ScoreToWkspace 14 1} -foreground black
			$mww1 add command -label "Panel 1 + 2 + 4" -command {ScoreToWkspace 124 1} -foreground black
			$mww1 add command -label "Panel 1 + 3 + 4" -command {ScoreToWkspace 134 1} -foreground black

			$mss0 add command -label "WHOLE SCORE" -command {}  -foreground black
			$mss0 add separator
			$mss0 add command -label "All"  -command {SaveScore all} -foreground black
			$mss0 add command -label "All Visible Panels"  -command {SaveScore 1234} -foreground black
			$mss0 add separator
			$mss0 add command -label "ADJACENT PANELS ONLY" -command {}  -foreground black
			$mss0 add separator
			$mss0 add command -label "Panels 1 + 2"  -command {SaveScore 12} -foreground black
			$mss0 add command -label "Panels 1 + 2 + 3"  -command {SaveScore 123} -foreground black
			$mss0 add command -label "Panels 2 + 3"  -command {SaveScore 23} -foreground black
			$mss0 add command -label "Panels 2 + 3 + 4"  -command {SaveScore 234} -foreground black
			$mss0 add command -label "Panels 3 + 4"  -command {SaveScore 34} -foreground black
			$mss0 add separator
			$mss0 add command -label "SINGLE PANELS ONLY"  -command {}  -foreground black
			$mss0 add separator
			$mss0 add command -label "Panel 1"  -command {SaveScore 1} -foreground black
			$mss0 add command -label "Panel 2"  -command {SaveScore 2} -foreground black
			$mss0 add command -label "Panel 3"  -command {SaveScore 3} -foreground black
			$mss0 add command -label "Panel 4"  -command {SaveScore 4} -foreground black
			$mss0 add separator
			$mss0 add command -label "OMIT SINGLE PANELS" -command {}  -foreground black
			$mss0 add separator
			$mss0 add command -label "Omit 1"  -command {SaveScore 234} -foreground black
			$mss0 add command -label "Omit 2"  -command {SaveScore 134} -foreground black
			$mss0 add command -label "Omit 3"  -command {SaveScore 124} -foreground black
			$mss0 add command -label "Omit 4"  -command {SaveScore 123} -foreground black
			$mss0 add separator
			$mss0 add command -label "DISJUNCT PANELS"  -command {}  -foreground black
			$mss0 add separator
			$mss0 add command -label "Panel 1 + 3"  -command {SaveScore 13} -foreground black
			$mss0 add command -label "Panel 2 + 4"  -command {SaveScore 24} -foreground black
			$mss0 add command -label "Panel 1 + 4"  -command {SaveScore 14} -foreground black
			$mss0 add command -label "Panel 1 + 2 + 4" -command {SaveScore 124} -foreground black
			$mss0 add command -label "Panel 1 + 3 + 4" -command {SaveScore 134} -foreground black
		}
		pack $sb.bkgd.bkgd $sb.bkgd.savw -side top
		if {!$sl_real} {
			button $sb.comm -text "Score Ops" -width 11 -command TellScoreOps -highlightbackground [option get . background {}]
		} else {
			menubutton $sb.comm -text "Score Ops" -width 11 -menu $sb.comm.menu -relief raised
			set ms [menu $sb.comm.menu -tearoff 0]
			$ms add command -label "SCORE DISPLAY"  -command {}  -foreground black
			$ms add separator
			$ms add command -label "Erase Score Display"  -command {WipeScore} -foreground black
			$ms add separator
			$ms add command -label "Restore Score Display"  -command {RestoreScore 1} -foreground black
			$ms add separator
			$ms add cascade -command {} -label "Swap Visible Panels" -menu $ms.b -foreground black
			set msb [menu $ms.b -tearoff 0]
			$msb add command -label "Panels 1 & 2" -command "SwapPanels 12" -foreground black
			$msb add separator
			$msb add command -label "Panels 1 & 3" -command "SwapPanels 13" -foreground black
			$msb add separator
			$msb add command -label "Panels 1 & 4" -command "SwapPanels 14" -foreground black
			$msb add separator
			$msb add command -label "Panels 2 & 3" -command "SwapPanels 23" -foreground black
			$msb add separator
			$msb add command -label "Panels 2 & 4" -command "SwapPanels 24" -foreground black
			$msb add separator
			$msb add command -label "Panels 3 & 4" -command "SwapPanels 34" -foreground black
			$ms add separator
			$ms add command -label "Rotate Panels Upwards" -command "SwapPanels Up" -foreground black
			$ms add command -command {} -label "To Scroll, including hidden panels, use Scroll" -foreground black
			$ms add separator
			$ms add command -label "Rotate Panels Downwards" -command "SwapPanels Down" -foreground black
			$ms add command -command {} -label "To Scroll, including hidden panels, use Scroll" -foreground black
			$ms add separator
			$ms add command -label "NAMED SCORES"  -command {}  -foreground black
			$ms add separator
			$ms add command -label "Save Already Named Score"  -command {SaveAlreadyNamedScore} -foreground black
			$ms add separator
			$ms add command -label "Save Score With New Name"  -command {SaveScoreWithNewName} -foreground black
			$ms add separator
			$ms add command -label "Load A Named Score"  -command {LoadNamedScore 1 0} -foreground black
			$ms add separator
			$ms add command -label "Unlink Display From Named Score"  -command {UnlinkScore} -foreground black
			$ms add separator
			$ms add command -label "Destroy A Named Score"  -command {DestroyNamedScore} -foreground black
			$ms add separator
			$ms add command -label "SCORE COMMENTS"  -command {}  -foreground black
			$ms add separator
			$ms add command -label "Erase All Visible Comments"  -command {EraseComments 0} -foreground black
			$ms add separator
			$ms add command -label "Restore These (Align Panels Correctly!)"  -command {RestoreCommentsTell} -foreground black
			$ms add separator
			$ms add command -label "Erase Every Comment (Irreversible!)"  -command {EraseComments 1} -foreground black
		}
		if {!$sl_real} {
			button $sb.real.vm -text "See Mixs" -width 10 -command TellReferMix -highlightbackground [option get . background {}]
		} else {
			menubutton $sb.real.vm -text "See Mixs" -width 10 -menu $sb.real.vm.menu -relief raised
			set mmix [menu $sb.real.vm.menu -tearoff 0]

			$mmix add command -label "Select Mixfiles For Viewing" -command {GetMixfileForSubsequentViewing} -foreground black
			$mmix add separator
			$mmix add command -label "View A Mixfile" -command {ViewMixfileFromScore 0} -foreground black
			$mmix add separator
			$mmix add command -label "View Same Mixfile" -command {ViewMixfileFromScore 1} -foreground black
			$mmix add command -label "(No non-CDP editing shown)" -command {ViewMixfileFromScore 1} -foreground black
		}
		pack $sb.real.real $sb.real.vm -side top
		if {!$sl_real} {
			button $sb.inf -text "Snd Info" -width 10 -command TellSndInfo -state normal -highlightbackground [option get . background {}]
		} else {
			menubutton $sb.inf -text "Snd Info" -width 10 -menu $sb.inf.menu -relief raised -state disabled
			set mi [menu $sb.inf.menu -tearoff 0]
			$mi add command -label "TOTAL DURATION" -command {}  -foreground black
			$mi add separator
			$mi add command -label "Total Duration Of Selected Sounds" -command {ScoreSelDur} -foreground black
			$mi add separator
			$mi add command -label "FIND ORIGIN OF SOUND" -command {}  -foreground black
			$mi add separator
			$mi add command -label "Find File In Logs" -command {ScoreSearchLogs} -foreground black
			$mi add separator
			$mi add command -label "See Logs" -command {DisplayHistory 0} -foreground black
		}
		frame $sb.comtex
		label $sb.comtex.1 -text "Comment"
		entry $sb.comtex.2 -textvariable score_comment -width 20 -disabledbackground [option get . background {}]
		pack $sb.comtex.1 $sb.comtex.2 -side top -pady 1
		menubutton $sb.slec -text "Mode" -width 6 -menu $sb.slec.menu -relief raised -background $evv(EMPH) 
		set se [menu $sb.slec.menu -tearoff 0]
		$se add command -label "Sound Ops" -command ScoreToPlayMode -foreground black
		$se add separator
		$se add command -label "Excerpt Ops" -command ScoreToExcerptMode -foreground black
		$se add separator
		$se add command -label "Choose Ops" -command ScoreToChooseMode -foreground black
		$se add separator
		$se add command -label "Group Ops" -command ScoreToGroupMode -foreground black
		$se add separator
		$se add command -label "Comment Ops" -command ScoreToCommentMode -foreground black

		label $sb.name -text "" -fg $evv(SPECIAL) -font bigfnt -width $evv(SCORENAMELEN)

		checkbutton $sb2.tog -variable comments_attached -text "Move Text+Snds?" -command UnattachComments
		pack $sb.slec $sb.bkgd $sb.test $sb.comtex $sb.real $sb.comm $sb.inf -side left -padx 2 -pady 2
		pack $sb.nbk $sb.name -side right -padx 2 -pady 2
		button $sb2.quit -text "Close" -command "set pr_score 0" -highlightbackground [option get . background {}]
		pack $sb2.hlp -side left -padx 1
		pack $sb2.zz -side left -fill y -expand true
		pack $sb2.slec -side left -padx 1
		pack $sb2.zz2 -side left -fill y -expand true
		pack $sb2.expl -side left -padx 1
		pack $sb2.quit $sb2.scrdn $sb2.scrup $sb2.tog -side right -padx 1
		set stage [canvas $score.c -height $evv(SKSCORE_HEIGHT) -width $evv(BRKF_WIDTH) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		$stage create line 0 $scoreline1 $evv(BRKF_WIDTH) $scoreline1 -fill $evv(SPECIAL)
		$stage create line 0 $scoreline2 $evv(BRKF_WIDTH) $scoreline2 -fill $evv(SPECIAL)
		$stage create line 0 $scoreline3 $evv(BRKF_WIDTH) $scoreline3 -fill $evv(SPECIAL)

		pack $sb2 -side top -fill both -expand true
		pack $dum -side top -fill x -pady 4
		pack $sb -side top -fill both
		pack $dum2 -side top -fill x -pady 4
		pack $score.c -side top -fill both
#		wm resizable $f 0 0
		set score_comment_bak ""
		bind $f <Escape> {set pr_score 0}
	}
	catch {unset localcomment}
	set comments_attached 0

	if {$new_score == $evv(NAMED_SCORE)} {					;#	GET NAMED SCORE
		if {![LoadNamedScore 0 1]} {
			Inf "Loading Default Score"		;#	BUT IF IT FAILS TO LOAD, CREATE DEFAULT SCORE PAGE, AND LOAD ANY BKGD DATA
			set current_scorename ""
			GetScore $current_scorename
			if {[info exists scoresave] || [info exists commentsave] || [info exists upsave] || [info exists dnsave]} {
				RestoreScore 0						
			}
		}
		LoadScoreMixList
		set new_score 0
		set score_loaded 1
	} elseif {$new_score == 0} {			;# IF A SCORE HAS PREVIOUSLY BEEN LOADED, RESTORE IT

		if {[info exists scoresave] || [info exists commentsave] || [info exists upsave] || [info exists dnsave]} {
			RestoreScore 0						
		} else {							;# IF NO SCORE HAS BEEN LOADED, CHECK IF THERE ARE named SCORES
			set load_default 1
			if [info exists scorenameslist] {
				set msg "Do You Wish To Load A Specific Named Score ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set load_default 0
					if {![LoadNamedScore 0 0]} {
						set load_default 1
					}
				}
			}
			if {$load_default} {			;# IF STILL NO SCORE HAS BEEN LOADED, CREATE DEFAULT SCORE PAGE, AND LOAD ANY BKGD DATA
				set current_scorename ""
				GetScore $current_scorename
				if {[info exists scoresave] || [info exists commentsave] || [info exists upsave] || [info exists dnsave]} {
					RestoreScore 0						
				}
			}
		}									;# IF THIS IS A FIRST LOADING, RESTORE MIXLIST INFO (POSSIBLY REDUNDANT ????)
		if {![info exists score_loaded] || !$score_loaded} {
			LoadScoreMixList
		}
		set score_loaded 1
	} else {								;# WIPE THE SCORE PAGE, AND BKGD DATA, AND PUT SELECTED WORKSPACE FILES ON SCORE
		DoCleanScore
		set sc_file [file join $evv(URES_DIR) $evv(SKMIX)$evv(CDP_EXT)]
		if {[file exists $sc_file] && [catch {file delete $sc_file} zit]} {
			ErrShow "CANNOT DELETE ORIGINAL MIXFILE INFO ASSOCIATED WITH PREVIOUS SCORE."
		}
		catch {unset scoresave}
		catch {unset commentsave}
		catch {unset upsave}
		catch {unset dnsave}
		set current_scorename ""
		$score.btns.name config -text ""
		$score.btns.nbk.saver config -text "Save"
		GetWkspaceSoundToScore $wl 0
		set score_loaded 1
	}
	if {[string length $current_scorename] <= 0} {
		$score.btns.nbk.saver config -text "Save"
	} else {
		$score.btns.nbk.saver config -text "Rename"
	}

	ScoreToPlayMode
	$f.btns2.expl config -text "DROP IN NEW SOUNDS WITH Control Mouse-Click" -fg $evv(SPECIAL) -bg $evv(EMPH)
	set score_comment ""
	if {$sl_real} {
		$score.btns.inf config -state disabled -bd 0 -text ""
	}
	set pr_score 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_score
	tkwait variable pr_score
	foreach obj [$stage find withtag snd] {
		lappend lastscoresave [$stage itemcget $obj -text]
		lappend lastscoresave [lindex [$stage coords $obj] 0]
		lappend lastscoresave [lindex [$stage coords $obj] 1]
	}
	if {[info exists lastscoresave]} {
		set scoresave $lastscoresave
	} else {
		catch {unset scoresave}
	}
	foreach obj [$stage find withtag comment] {
		set thiscomment [$stage itemcget $obj -text]
		lappend lastscommentsave $thiscomment
		lappend lastscommentsave [lindex [$stage coords $obj] 0]
		lappend lastscommentsave [lindex [$stage coords $obj] 1]
	}
	if {[info exists lastscommentsave]} {
		set commentsave $lastscommentsave 
	} else {
		catch {unset commentsave}
	}
	catch {unset upsave}
	if [info exists uppanel] {
		foreach nam [array names uppanel] {
			set upsave($nam) $uppanel($nam)
			incr uppanelcnt
		}
	}
	catch {unset dnsave}
	if [info exists dnpanel] {
		foreach nam [array names dnpanel] {
			set dnsave($nam) $dnpanel($nam)
			incr dnpanelcnt
		}
	}
	ParsePurge
	if {[info exists current_scorename] && ([string length $current_scorename] > 0)} {
		SaveAlreadyNamedScore
		BakupScoreMixlist
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}	

########################
# TOGGLE BETWEEN MODES #
########################

#----- Get Specific File to a mixlist

proc ScoreToChooseMode {} {
	global stage score draglist dragdx dragdy in_unattached_mode comments_attached saved_comments_attached sl_real
	global score_comment score_comment_bak

	if {!$sl_real} {
		Inf "In Choose Mode, Mouse Operations On Soundfiles On The Score Are....\n\n1) Grab File To A List Of Selected Files\n     (For Running A Test Mix, Making A Mixfile, Calculating Duration Etc)\n2) Drag Sound To New Position"
		return
	}
	$score.btns2.expl config -text "TIME SEQUENCE LEFT TO RIGHT & FROM TOP TO BOTTOM PANEL" \
		-bg [option get . background {}] -fg [option get . foreground {}]
	$score.btns.comtex.1 config -text ""
	$score.btns.comtex.2 config -bd 0 -state disabled
	if {[string length $score_comment] > 0} {
		set score_comment_bak $score_comment
		set score_comment ""
	}
	bind $stage <ButtonRelease-1> 					{}
	bind $stage <Control-ButtonRelease-1>			{}
	bind $stage <Control-Shift-ButtonRelease-1>		{}
	bind $stage <Shift-ButtonPress-1> 				{}
	bind $stage <Shift-B1-Motion> 					{}
	bind $stage <Shift-ButtonRelease-1>				{}
	bind $stage <Command-ButtonRelease-1>				{}
	bind $stage <Command-Control-ButtonRelease-1>		{}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{}
	bind $stage <Command-Shift-ButtonRelease-1>			{}
	bind $stage <ButtonRelease-1> 					{GetScoreFileToSelectionList %x %y}
	bind $stage <Control-ButtonRelease-1>			{Inf "Invalid Operation"}
	bind $stage <Control-Shift-ButtonRelease-1>		{Inf "Invalid Operation"}
	bind $stage <Shift-ButtonPress-1> 				{MarkSndOnScore %x %y}
	bind $stage <Shift-B1-Motion> 					{DragSndOnScore %x %y}
	bind $stage <Shift-ButtonRelease-1>				{RelocateSndOnScore}
	bind $stage <Command-ButtonRelease-1>				{ClearSelectionListOnScore}
	bind $stage <Command-Control-ButtonRelease-1>		{GotoSelectNextPanel}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{SelectCurrentPanel}
	bind $stage <Command-Shift-ButtonRelease-1>			{Inf "Invalid Operation"}
	if {$in_unattached_mode} {
		if [info exists saved_comments_attached] {
			set comments_attached $saved_comments_attached
		}
		set in_unattached_mode 0
	}
	catch {unset dragdx}
	catch {unset dragdy}
	catch {unset scoreclip}
	if [info exists draglist] {
		ConfirmDragPosition
		unset draglist
	}
	$score.btns.inf  config -state normal -bd 2 -text "Snd Info"
	$score.btns.bkgd.bkgd config -state normal -bd 2 -text "Get Snds"
	$score.btns.test config -state normal -bd 2 -text "Test Seq"
	$score.btns.bkgd.savw config -state normal -bd 2 -text "Use Snds"
	$score.btns.comm config -state normal -bd 2 -text "Score Ops"
	$score.btns2.slec config -text "Choose Ops"
	$score.btns2.tog config -state normal -bd 2 -text "Move Text+Snds?"

	$score.btns2.slec.menu entryconfig 0 -label "Click                         : Select Sound to list of Sounds to Use"
	$score.btns2.slec.menu entryconfig 2 -label  "Shift & Drag             : Move Sound (or Comment) to new position"
	$score.btns2.slec.menu entryconfig 4 -label  "(Comments can move with sound: Tick the checkbox)"
	$score.btns2.slec.menu entryconfig 6 -label ""
	$score.btns2.slec.menu entryconfig 8 -label "Command Click                : Clear Sound selection."
	$score.btns2.slec.menu entryconfig 10 -label ""
	$score.btns2.slec.menu entryconfig 12 -label "Command Control Click           :  Select Next Panel"
	$score.btns2.slec.menu entryconfig 14 -label "Command Control Shift Click : Select All Sounds in Panel"
	$score.btns2.slec.menu entryconfig 16 -label ""
	$score.btns2.slec.menu entryconfig 18 -label ""
	$score.btns2.slec.menu entryconfig 20 -label ""
}

#----- Play sounds when clicked on

proc ScoreToPlayMode {} {
	global stage score scoremixlist draglist dragdx dragdy in_unattached_mode comments_attached saved_comments_attached sl_real
	global score_comment score_comment_bak lastscoredelete

	if {!$sl_real} {
		Inf "In Sound Mode, Mouse Operations On Files On The Score Are....\n\n1) Play\n2) Position Or Drag To New Position\n3) Select Sound (to Place A Copy Elsewhere On Score)\n4) Remove From Score"
		return
	}
	catch {unset lastscoredelete}

	$score.btns2.expl config -text "TIME SEQUENCE IS LEFT TO RIGHT & TOP PANEL TO BOTTOM" \
		-bg [option get . background {}] -fg [option get . foreground {}]
	$score.btns.comtex.1 config -text ""
	$score.btns.comtex.2 config -bd 0 -state disabled
	if {[string length $score_comment] > 0} {
		set score_comment_bak $score_comment
		set score_comment ""
	}
	bind $stage <ButtonRelease-1>					{}
	bind $stage <Control-ButtonRelease-1>			{}
	bind $stage <Control-Shift-ButtonRelease-1>		{}
	bind $stage <Shift-ButtonPress-1> 				{}
	bind $stage <Shift-B1-Motion> 					{}
	bind $stage <Shift-ButtonRelease-1>				{}
	bind $stage <Command-ButtonRelease-1>				{}
	bind $stage <Command-Control-ButtonRelease-1>		{}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{}
	bind $stage <Command-Shift-ButtonRelease-1>			{}
	bind $stage <ButtonRelease-1> 					{PlaySndOnScore %x %y}
	bind $stage <Control-ButtonRelease-1>			{PutSndOnScore %x %y}
	bind $stage <Control-Shift-ButtonRelease-1>		{DeleteSndOnScore %x %y}
	bind $stage <Shift-ButtonPress-1> 				{MarkSndOnScore %x %y}
	bind $stage <Shift-B1-Motion> 					{DragSndOnScore %x %y}
	bind $stage <Shift-ButtonRelease-1>				{RelocateSndOnScore}
	bind $stage <Command-ButtonRelease-1>				{Inf "Invalid Operation"}
	bind $stage <Command-Control-ButtonRelease-1>		{PickupSoundFromScore %x %y}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{RestoreDeletedObject}
	bind $stage <Command-Shift-ButtonRelease-1>			{Inf "Invalid Operation"}

	if {$in_unattached_mode} {
		if [info exists saved_comments_attached] {
			set comments_attached $saved_comments_attached
		}
		set in_unattached_mode 0
	}
	catch {unset scoremixlist}
	catch {unset dragdx}
	catch {unset dragdy}
	catch {unset scoreclip}
	if [info exists draglist] {
		ConfirmDragPosition
		unset draglist
	}
	$score.btns.inf  config -state disabled -bd 0 -text ""
	$score.btns.bkgd.bkgd config -state normal -bd 2 -text "Get Snds"
	$score.btns.test config -state normal -bd 2 -text "Test Seq"
	$score.btns.bkgd.savw config -state normal -bd 2 -text "Use snds"
	$score.btns.comm config -state normal -bd 2 -text "Score Ops"
	$score.btns2.slec config -text "Sound Ops"
	$score.btns2.tog config -state normal -bd 2 -text "Move Text+Snds?"

	$score.btns2.slec.menu entryconfig 0 -label  "Click                         : Play sound"
	$score.btns2.slec.menu entryconfig 2 -label  "Control Click            : Put new file in score"
	$score.btns2.slec.menu entryconfig 4 -label  "Control Shift Click    : Remove Sound (or Comment)"
	$score.btns2.slec.menu entryconfig 6 -label  "Shift & Drag             : Move Sound (or Comment) to new position"
	$score.btns2.slec.menu entryconfig 8 -label  "(Comments can move with sound: Tick the checkbox)"
	$score.btns2.slec.menu entryconfig 10 -label "Control Command Click        : Grab Sound (to Paste Copy elsewhere)"
	$score.btns2.slec.menu entryconfig 12 -label ""
	$score.btns2.slec.menu entryconfig 14 -label "Command Control Shift Click : Restore last sound"
	$score.btns2.slec.menu entryconfig 16 -label ""
	$score.btns2.slec.menu entryconfig 18 -label ""
	$score.btns2.slec.menu entryconfig 20 -label ""
}

#----- Get Specific File to a group (to drag)

proc ScoreToGroupMode {} {
	global stage score scoremixlist draglist dragdx dragdy in_unattached_mode comments_attached saved_comments_attached sl_real
	global score_comment score_comment_bak

	if {!$sl_real} {
		Inf "In Group Mode, Mouse Operations On Items On The Score Are....\n\n1) Select Sound (or Comment) To Be Part Of A Group Of Sounds\n2) Drag Whole Group Of Sounds To A New Position"
		return
	}
	$score.btns2.expl config -text "TIME SEQUENCE IS LEFT TO RIGHT & TOP PANEL TO BOTTOM" \
		-bg [option get . background {}] -fg [option get . foreground {}]
	$score.btns.comtex.1 config -text ""
	$score.btns.comtex.2 config -bd 0 -state disabled
	if {[string length $score_comment] > 0} {
		set score_comment_bak $score_comment
		set score_comment ""
	}
	if {!$in_unattached_mode} {
		set in_unattached_mode 1
		set saved_comments_attached $comments_attached
		set comments_attached 0
		$score.btns2.tog config -state disabled -bd 0 -text ""
	}
	bind $stage <ButtonRelease-1>					{}
	bind $stage <Control-ButtonRelease-1>			{}
	bind $stage <Control-Shift-ButtonRelease-1>		{}
	bind $stage <Shift-ButtonPress-1> 				{}
	bind $stage <Shift-B1-Motion> 					{}
	bind $stage <Shift-ButtonRelease-1>				{}
	bind $stage <Command-ButtonRelease-1>				{}
	bind $stage <Command-Control-ButtonRelease-1>		{}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{}
	bind $stage <Command-Shift-ButtonRelease-1>			{}
	bind $stage <ButtonRelease-1> 					{GetScoreItemToDragList %x %y}
	bind $stage <Control-ButtonRelease-1>			{RestoreGroupPosition}
	bind $stage <Control-Shift-ButtonRelease-1>		{Inf "Invalid Operation"}
	bind $stage <Shift-ButtonPress-1> 				{MarkGroupOnScore %x %y}
	bind $stage <Shift-B1-Motion> 					{DragGroupOnScore %x %y}
	bind $stage <Shift-ButtonRelease-1>				{RelocateGroupOnScore}
	bind $stage <Command-ButtonRelease-1>				{ClearDraglist}
	bind $stage <Command-Control-ButtonRelease-1>		{Inf "Invalid Operation"}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{Inf "Invalid Operation"}
	bind $stage <Command-Shift-ButtonRelease-1>			{Inf "Invalid Operation"}

	catch {unset scoremixlist}
	catch {unset dragdx}
	catch {unset dragdy}
	if [info exists draglist] {
		ConfirmDragPosition
		unset draglist
	}
	catch {unset scoreclip}
	$score.btns.inf  config -state disabled -text "" -bd 0
	$score.btns.bkgd.bkgd config -state disabled -text "" -bd 0
	$score.btns.test config -state disabled -text "" -bd 0
	$score.btns.bkgd.savw config -state disabled -text "" -bd 0
	$score.btns.comm config -state disabled -text "" -bd 0
	$score.btns2.slec config -text "GROUP OPS"
	$score.btns2.tog config -state disabled -text "" -bd 0

	$score.btns2.slec.menu entryconfig 0 -label "Click               : Add sound to group"
	$score.btns2.slec.menu entryconfig 2 -label "Shift & Drag   : Move GROUP to new position"
	$score.btns2.slec.menu entryconfig 4 -label "Control Click : Restore Original Group Position"
	$score.btns2.slec.menu entryconfig 6 -label "Command Click         : Start another Group"
	$score.btns2.slec.menu entryconfig 8 -label ""
	$score.btns2.slec.menu entryconfig 10 -label ""
	$score.btns2.slec.menu entryconfig 12 -label ""
	$score.btns2.slec.menu entryconfig 14 -label ""
	$score.btns2.slec.menu entryconfig 16 -label ""
	$score.btns2.slec.menu entryconfig 18 -label ""
	$score.btns2.slec.menu entryconfig 20 -label ""
}

proc ScoreToCommentMode {} {
	global stage score draglist dragdx dragdy in_unattached_mode comments_attached saved_comments_attached score_comment_bak sl_real
	global score_comment score_comment_bak lastscoredelete

	if {!$sl_real} {
		Inf "In Comment Mode, Mouse Operations On The Score Are....\n\n1) Position Comment On Score\n2) Select Comment And Move To New Position\n3) Delete Comment\n4) Add To An Existing Comment\n5) Replace Comment By A New Comment\n6) Convert Soundfile-name To Comment"
		return
	}
	catch {unset lastscoredelete}

	$score.btns2.expl config -text "TIME SEQUENCE IS LEFT TO RIGHT & TOP PANEL TO BOTTOM" \
		-bg [option get . background {}] -fg [option get . foreground {}]
	$score.btns.comtex.1 config -text "Comment"
	$score.btns.comtex.2 config -bd 2 -state normal
	set score_comment $score_comment_bak
	if {!$in_unattached_mode} {
		set in_unattached_mode 1
		set saved_comments_attached $comments_attached
		set comments_attached 0
		$score.btns2.tog config -state disabled -text "" -bd 0
	}
	bind $stage <ButtonRelease-1>					{}
	bind $stage <Control-ButtonRelease-1>			{}
	bind $stage <Control-Shift-ButtonRelease-1>		{}
	bind $stage <Shift-ButtonPress-1> 				{}
	bind $stage <Shift-B1-Motion> 					{}
	bind $stage <Shift-ButtonRelease-1>				{}
	bind $stage <Command-ButtonRelease-1>				{}
	bind $stage <Command-Control-ButtonRelease-1>		{}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{}
	bind $stage <Command-Shift-ButtonRelease-1>			{}
	bind $stage <ButtonRelease-1> 					{GrabScoreComment %x %y}
	bind $stage <Control-ButtonRelease-1> 			{PutCommentOnScore %x %y}
	bind $stage <Control-Shift-ButtonRelease-1>		{DeleteCommentOnScore %x %y}
	bind $stage <Shift-ButtonPress-1> 				{MarkCommentOnScore %x %y}
	bind $stage <Shift-B1-Motion> 					{DragCommentOnScore %x %y}
	bind $stage <Shift-ButtonRelease-1>				{RelocateCommentOnScore}
	bind $stage <Command-ButtonRelease-1>				{ConvertBetweenSoundAndComment %x %y}
	bind $stage <Command-Control-ButtonRelease-1>		{AddToScoreComment %x %y}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{RestoreDeletedObject}
	bind $stage <Command-Shift-ButtonRelease-1>			{ReplaceScoreComment %x %y}
	catch {unset dragdx}
	catch {unset dragdy}
	if [info exists draglist] {
		ConfirmDragPosition
		unset draglist
	}
	catch {unset scoreclip}
	$score.btns.inf  config -state disabled -text "" -bd 0
	$score.btns.comm config -state normal -bd 2 -text "Score Ops"
	$score.btns.bkgd.bkgd config -state disabled -text "" -bd 0
	$score.btns.test config -state disabled -text "" -bd 0
	$score.btns2.slec config -text "Comment Ops"
	$score.btns.bkgd.savw config -state disabled -text "" -bd 0

	$score.btns2.slec.menu entryconfig 0 -label "Click                      : Grab Comment from Score to Text Box"
	$score.btns2.slec.menu entryconfig 2 -label "Control Click         : Position Comment in Score"
	$score.btns2.slec.menu entryconfig 4 -label "Control Shift Click : Remove Comment"
	$score.btns2.slec.menu entryconfig 6 -label "Shift & Drag           : Move Comment to new position"
	$score.btns2.slec.menu entryconfig 8 -label "             (Comments can be moved with Sounds in SOUND MODE)"
	$score.btns2.slec.menu entryconfig 10 -label "Command Control Click    : Add to Comment"
	$score.btns2.slec.menu entryconfig 12 -label "Command Shift Click         : Replace Comment"
	$score.btns2.slec.menu entryconfig 14 -label "Command Click                 : Convert Sound to Comment, and vice versa"
	$score.btns2.slec.menu entryconfig 16 -label "        (Ability to convert Comment back to Sound is TEMPORARY)"
	$score.btns2.slec.menu entryconfig 18 -label "        (Will not survive Scrolling,Save,Load,Erase or Restore)"
	$score.btns2.slec.menu entryconfig 20 -label "Command Control Shift Click : Restore Comment"
}



#----- Get Specific File to a list of Selected files

proc GetScoreFileToSelectionList {x y} {
	global stage scoremixlist

	set obj [$stage find closest $x $y]
	if {![string match [lindex [$stage itemcget $obj -tag] 0] "snd"]} {
		return
	}
	set snd [$stage itemcget $obj -text]
	if [info exists scoremixlist] {	
		set k [lsearch $scoremixlist $snd] 
		if {$k >= 0} {
			Inf "Already Selected"
			return
		}
	}
	lappend scoremixlist $snd
	set msg "Files Selected\n"
	foreach item $scoremixlist {
		append msg "$item      "
	}
	Inf $msg
}

################################
# BAKUP AND RETRIEVE FROM DISK #
################################

#-- Save Sketch Score info to disk

proc BakupScore {scnam} {
	global scoresave commentsave upsave dnsave evv

	if {![info exists scoresave] && ![info exists commentsave] && ![info exists upsave] && ![info exists dnsave]} {
		return -1
	}
	set tmpfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tmpfnam w} fileId] {
		Inf "Cannot Open Temporary File To Save Sketch Score Information."
		return 0
	}
	if [info exists scoresave] {
		foreach {fnam x y} $scoresave {
			set line $fnam
			append line " $x $y"
			puts $fileId $line
		}
	}
	if [info exists commentsave] {
		puts $fileId "#COMMENTS"
		foreach {comment x y} $commentsave {
			set comment [join $comment "_"]
			set line $comment
			append line " $x $y"
			puts $fileId $line
		}
	}
	if [info exists upsave] {
		foreach n [array names upsave] {
			set thisname "#UPPANEL"
			append thisname $n
			puts $fileId $thisname
			set snds [lindex $upsave($n) 0]
			foreach {fnam x y} $snds {
				set line $fnam
				append line " $x $y"
				puts $fileId $line
			}
			puts $fileId "#COMMENTS"
			set comments [lindex $upsave($n) 1]
			foreach {comment x y} $comments {
				set comment [join $comment "_"]
				set line $comment
				append line " $x $y"
				puts $fileId $line
			}
		}
	}
	if [info exists dnsave] {
		foreach n [array names dnsave] {
			set thisname "#DNPANEL"
			append thisname $n
			puts $fileId $thisname
			set snds [lindex $dnsave($n) 0]
			foreach {fnam x y} $snds {
				set line $fnam
				append line " $x $y"
				puts $fileId $line
			}
			puts $fileId "#COMMENTS"
			set comments [lindex $dnsave($n) 1]
			foreach {comment x y} $comments {
				set comment [join $comment "_"]
				set line $comment
				append line " $x $y"
				puts $fileId $line
			}
		}
	}
	close $fileId
	if {[string length $scnam] <= 0} {
		set sc_file [file join $evv(URES_DIR) $evv(SKETCH)$evv(CDP_EXT)]
	} else {
		set sc_file [file join $evv(URES_DIR) $evv(SKETCH)_$scnam$evv(CDP_EXT)]
	}
	if [file exists $sc_file] {
		if [catch {file delete $sc_file}] {
			ErrShow "CANNOT DELETE ORIGINAL SKETCH-SCORE FILE. CANNOT UPDATE LISTING OF SKETCH-SCORE."
			return 0
		}
	}
	if [catch {file rename $tmpfnam $sc_file}] {
		ErrShow "CANNOT RENAME TEMPORARY SKETCH-SCORE FILE $tmpfnam\n\nYOU MUST RENAME THIS FILE TO $sc_file OUTSIDE THE SOUNDLOOM\nIF YOU WISH TO RETAIN THIS DATA"
		return 0
	}
	return 1
}

#-- Get Sketch Score info from disk

proc GetScore {sname} {
	global scoresave current_scorename commentsave upsave dnsave sketchbadfile 
	global wstk scorenameslist score_vq score_p4_bot score_right evv

	set far_right [expr $score_right - 100]
	set no_arbs 0
	set arbx 10
	set arby $score_vq
	if {[string length $sname] <= 0} {
		set sc_file [file join $evv(URES_DIR) $evv(SKETCH)$evv(CDP_EXT)]
		if {![file exists $sc_file]} {
			return 0
		}
	} else {
		set sc_file [file join $evv(URES_DIR) $evv(SKETCH)_$sname$evv(CDP_EXT)]
		if {![file exists $sc_file]} {
			Inf "Cannot Find The File '$sc_file' To Load The Score '$sname'"
			return 0
		}
	}
	if [catch {open $sc_file r} fileId] {
		Inf "Cannot Open File '$sc_file' To Restore Sketch Score Information."
		return 0
	}
	set is_comments 0
	set is_uppanel 0
	set is_dnpanel 0
	while {[gets $fileId line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if [string match $line "#COMMENTS"] {
			set is_comments 1
			continue
		} elseif [string match #UPPANEL* $line ] {
			set index [string range $line 8 end]
			set is_uppanel 1
			set is_dnpanel 0
			set is_comments 0
			continue
		} elseif [string match #DNPANEL* $line ] {
			set index [string range $line 8 end]
			set is_dnpanel 1
			set is_uppanel 0
			set is_comments 0
			continue
		}
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				if {$is_uppanel} {
					if {$is_comments} {
						lappend upcoms($index) $item
					} else {
						lappend upsnds($index) $item
					}
				} elseif {$is_dnpanel} {
					if {$is_comments} {
						lappend dncoms($index) $item
					} else {
						lappend dnsnds($index) $item
					}
				} elseif {$is_comments} {
					lappend nulist2 $item
				} else {
					lappend nulist $item
				}
				incr cnt
			}
		}
		if {$cnt != 3} {
			Inf "Sketch Score Data: Anomalous Line Encountered : Abandoning Data"
			close $fileId
			return 0
		}
	}
	close $fileId
	if {![info exists nulist] && ![info exists nulist2] \
	&&  ![info exists upsnds] && ![info exists upcoms] \
	&&  ![info exists dnsnds] && ![info exists dncoms]} {
		Inf "Failed to retrieve Sketch Score data"
		return 0
	}
	if [info exists upcoms] {				;# CHANGE COMMENT FORMAT IN UPPANEL DATA
		foreach n [array name upcoms] {
			catch {unset nucoms}
			foreach {comment x y} $upcoms($n) {
				set comment [split $comment "_"]
				lappend nucoms $comment $x $y
			}
			set upcoms($n) $nucoms
		}
	}
	if [info exists upsnds] {				;# PAIR SND DATA WITH COMMENTS FOR UPPANELS
		foreach n [array name upsnds] {
			lappend upsave($n) $upsnds($n)
			if [info exists upcoms($n)] {
				lappend upsave($n) $upcoms($n)
			} else {
				lappend upsave($n) {}
			}
		}
	}
	if [info exists upcoms] {				;# PAIR NULL SND DATA WITH COMMENTS FOR UPPANELS WITH COMMENTS ONLY
		foreach n [array name upcoms] {
			if {![info exists upsave($n)]} {
				set upsave($n) {}
				lappend upsave($n) $upcoms($n)
			}
		}
	}
	if [info exists dncoms] {				;# SIMIL FOR DNPANELS
		foreach n [array name dncoms] {
			catch {unset nucoms}
			foreach {comment x y} $dncoms($n) {
				set comment [split $comment "_"]
				lappend nucoms $comment $x $y
			}
			set dncoms($n) $nucoms
		}
	}
	if [info exists dnsnds] {
		foreach n [array name dnsnds] {
			lappend dnsave($n) $dnsnds($n)
			if [info exists dncoms($n)] {
				lappend dnsave($n) $dncoms($n)
			} else {
				lappend dnsave($n) {}
			}
		}
	}
	if [info exists dncoms] {
		foreach n [array name dncoms] {
			if {![info exists dnsave($n)]} {
				set dnsave($n) {}
				lappend dnsave($n) $dncoms($n)
			}
		}
	}
	catch {unset scoresave}
	catch {unset commentsave}
	if [info exists nulist] {
		catch {unset nunulist}
		foreach {fnam x y} $nulist {
			set OK 1
			if {![file exists $fnam]} {
				set OK 0
				while {$OK == 0} {
					set fcom [string toupper [file rootname [file tail $fnam]]]
					set msg "Sketch Score Data: Soundfile\n\n$fnam\n\nNo Longer Exists"
					append msg "\n\nYou Have Three Options\n"
					append msg "1) Abandon This Score File.\n"
					append msg "2) Replace '$fnam' By A New Filename (Or Give It A Different Directory Path).\n"
					append msg "3) Replace '$fnam' By The Comment '$fcom'\n\n\n"
					append msg "CHOICE 1: Abandon Data ??                      (Named Score Will Be Destroyed!!)"
					set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						if [AreYouSure] {
							catch {unset upsave}
							catch {unset dnsave}
							catch {unset commentsave}
							if {[string length $sname] > 0} {
								if [catch {file delete $sc_file} zitto] {
									Inf "Cannot Delete The Named Score '$sc_file'"
								} else {
									set k [lsearch $scorenameslist $sname]
									if {$k >= 0} {
										set scorenameslist [lreplace $scorenameslist $k $k]
									}
									set k [LstIndx $sname .loadscore.e.ll.list]
									if {$k >= 0} {
										.loadscore.e.ll.list delete $k
									}
								}
							}
							return 0
						}
					}
					set msg "CHOICE 2: Substitute A New Filename Or Directory Path For\n\n$fnam??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set sketchbadfile [file rootname [file tail $fnam]]
						set nufnam [SketchFileRename]
						if {[string length $nufnam] > 0} {
							set fnam $nufnam
							set OK 1
						}
					} else {
						set msg "CHOICE 3: Replace '$fnam' By The Comment '$fcom' ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							lappend commentsave $fcom $x $y
							set OK 2
						} else {
							catch {unset upsave}
							catch {unset dnsave}
							catch {unset commentsave}
							return 0
						}
					}
				}
			}
			if {$x <= 0 || $x >= $evv(BRKF_WIDTH) || $y <= 0 || $y >= $evv(SKSCORE_HEIGHT)} {
				set OK 0
				while {$OK == 0} {
					set msg "Sketch Score Sound: Anomalous Coordinate For '$fnam'"
					append msg "\n\nYou Have Three Options\n"
					append msg "1) Abandon This Score File Altogether.\n"
					append msg "2) Ignore '$fnam' And Continue Loading The Rest Of The Score.\n"
					append msg "3) Put '$fnam' At An Arbitrary Place On The Score\n\n\n"
					append msg "CHOICE 1: Abandon Data ??                      (Named Score Will Be Destroyed!!)"
					set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						catch {unset upsave}
						catch {unset dnsave}
						catch {unset commentsave}
						if {[string length $sname] > 0} {
							if [catch {file delete $sc_file} zitto] {
								Inf "Cannot Delete The Named Score '$sc_file'"
							} else {
								set k [lsearch $scorenameslist $sname]
								if {$k >= 0} {
									set scorenameslist [lreplace $scorenameslist $k $k]
								}
								set k [LstIndx $sname .loadscore.e.ll.list]
								if {$k >= 0} {
									.loadscore.e.ll.list delete $k
								}
							}
						}
						return 0
					}
					set msg "CHOICE 2: Ignore '$fnam' And Continue Loading The Rest Of The Score ??"
					set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set OK 2
					} else {
						if {$no_arbs} {
							Inf "No More Positions Left On Score For Data With Bad Coordinates\n\nChoose Another Option."
							continue
						}
						set msg "CHOICE 3: Put '$fnam' At An Arbitrary Place On The Score ???"
						set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set x $arbx
							set y $arby
							set y [AdjustScoreVertPos $arby]
							set arby [expr $arby + $score_vq]
							if {$arby > $score_p4_bot} {
								set arbx [expr $arbx + 100]
								if {$arbx > $far_right} {
									set no_arbs 1
								} else {
									set arby $score_vq
								}
							}
							set OK 1
						}
					}
				}
			}
			if {$OK==1} {
				lappend nunulist $fnam $x $y
			}
		}
		set scoresave $nunulist
	} 
	if [info exists nulist2] {
		foreach {comment x y} $nulist2 {
			set OK 1
			if {$x <= 0 || $x >= $evv(BRKF_WIDTH) || $y <= 0 || $y >= $evv(SKSCORE_HEIGHT)} {
				set OK 0
				while {$OK == 0} {
					set msg "Sketch Score Sound: Anomalous Coordinate For Comment\n\n'$comment'"
					append msg "\n\nYou Have Three Options\n"
					append msg "1) Abandon This Comment And All Further Comments In This Score.\n"
					append msg "2) Ignore This Comment And Continue Loading The Rest Of The Score.\n"
					append msg "3) Put The Comment At An Arbitrary Place On The Score\n\n\n"
					append msg "CHOICE 1: Abandon This Comment And All Further Comments ??"
					set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						if {[string length $sname] > 0} {
							set current_scorename $sname
						}
						return 1
					}
					set msg "CHOICE 2: Ignore This Comment And Continue Loading The Rest Of The Score ??\n"
					set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set OK 2
					} else {
						if {$no_arbs} {
							Inf "No More Positions Left On Score For Data With Bad Coordinates\n\nChoose Another Option."
							continue
						}
						set msg "CHOICE 3: Put The Comment At An Arbitrary Place On The Score ??"
						if {$choice == "yes"} {
							set x $arbx
							set y $arby
							set y [AdjustScoreVertPos $arby]
							set arby [expr $arby + $score_vq]
							if {$arby > $score_p4_bot} {
								set arbx [expr $arbx + 100]
								if {$arbx > [expr $score_right - 100]} {
									set no_arbs 1
								} else {
									set arby $score_vq
								}
							}
							set OK 1
						}
					}
				}
			}
			if {$OK == 1} {
				set comment [split $comment "_"]
				lappend commentsave $comment $x $y
			}
		}
	}
	if {[string length $sname] > 0} {
		set current_scorename $sname
	}
	return 1
}

#####################
# MANIPULATE SOUNDS #
#####################

#--- Place a soundfile on the score

proc PutSndOnScore {x y} {
	global score_left score_right score_chwidth score_files score_vq score_p4_bot score_p1_top stage evv

	if {![info exists score_files]} {
		Inf "No Sounds Chosen"
		return
	}
	set itemwidth 0
	set extra_itemcnt -1
	foreach item $score_files {
		set thiswidth [expr [string length $item] * $score_chwidth]
		incr thiswidth
		if {$thiswidth > $itemwidth} {
			set itemwidth $thiswidth
		}
		incr extra_itemcnt
	}
	set leftlim  $score_left
	set rightlim [expr $score_right - $itemwidth]
	if {$x <= $leftlim} {						 
		set x $leftlim
	}
	if {$x > $rightlim} {
		set x $rightlim
	}
	set y [AdjustScoreVertPos $y]
	set origy $y
	if {$extra_itemcnt > 0} {
		set ylim [expr $y + ($score_vq * $extra_itemcnt)]
		set end_offset [expr $ylim - $score_p4_bot]
		if {$end_offset > 0} {
			set y [expr $y - $end_offset]
			if {$y < $score_p1_top} {
				Inf "Not Enough Vertical Space On Score For All These Files!!"
				return
			}
		}
		foreach item $score_files {
			$stage create text $x $y -text "$item" -tags snd -anchor w -fill $evv(POINT)
			set y [expr $y + $score_vq]
			set y [AdjustScoreVertPos $y]
		}
	} else {
		$stage create text $x $y -text "$item" -tags snd -anchor w -fill $evv(POINT)
	}
	catch {unset score_files}
}

#--- Play a soundfile on the score

proc PlaySndOnScore {x y} {
	global stage

	set obj [$stage find closest $x $y]						;#	Find closest object
	set displaylist [$stage find withtag snd]				;#	List all objects which are sounds

	if {[lsearch -exact $displaylist $obj] < 0} {			;#	If the closest object is not a sound
		return												;#	abandon the mark
	}
	PlaySndfile [$stage itemcget $obj -text] 0

}

#--- Get soundfile from score, to copy elsewhere

proc PickupSoundFromScore {x y} {
	global stage score_files

	set obj [$stage find closest $x $y]						;#	Find closest object
	set displaylist [$stage find withtag snd]				;#	List all objects which are sounds

	if {[lsearch -exact $displaylist $obj] < 0} {			;#	If the closest object is not a sound
		Inf "No Sound Grabbed"
		return												;#	abandon the mark
	}
	set score_files [$stage itemcget $obj -text]

}

#--- Remove a soundfile or comment from the score

proc DeleteSndOnScore {x y} {
	global stage scoresave lastscoredelete

	foreach obj [$stage find withtag snd] {
		lappend lastscoresave [$stage itemcget $obj -text]
		lappend lastscoresave [lindex [$stage coords $obj] 0]
		lappend lastscoresave [lindex [$stage coords $obj] 1]
		lappend displaylist $obj
	}
	foreach obj [$stage find withtag comment] {
		lappend lastcommentsave [$stage itemcget $obj -text]
		lappend lastcommentsave [lindex [$stage coords $obj] 0]
		lappend lastcommentsave [lindex [$stage coords $obj] 1]
		lappend displaylist $obj
	}
	if {![info exists displaylist]} {
		return
	}
	set obj [$stage find closest $x $y]
	if {[lsearch -exact $displaylist $obj] < 0} {	;#	If the closest object is not a sound or comment
		return										;#	abandon the delete
	}
	if [info exists lastscoresave] { 
		set scoresave $lastscoresave
	}
	if [info exists lastcommentsave] { 
		set commentsave $lastcommentsave
	}
	set lastscoredelete  [$stage itemcget $obj -text]
	lappend lastscoredelete "snd"
	lappend lastscoredelete [lindex [$stage coords $obj] 0]
	lappend lastscoredelete [lindex [$stage coords $obj] 1]
	catch {$stage delete $obj}
}

#--- Mark a soundfile on the score, ready to drag it

proc MarkSndOnScore {x y} {
	global stage scorepnt score_chwidth score_left score_right localcomment comments_attached 

	set scorepnt(ismarked) 0														

	set scorepnt(obj) [$stage find closest $x $y]				;#	Find closest object
	set displaylist [$stage find withtag snd]					;#	List all objects which are snds
	set displaylist [concat $displaylist [$stage find withtag comment]]
	if {[lsearch -exact $displaylist $scorepnt(obj)] < 0} {		;#	If the closest object is not a snd or comment
		return													;#	abandon the mark
	}

	set is_snd 1
	set k [lsearch [$stage itemcget $scorepnt(obj) -tag] "snd"]
	if {$k < 0} {
		set is_snd 0
	}
	set itemwidth [GetStringSize [$stage itemcget $scorepnt(obj) -text]]
	incr itemwidth
	set scorepnt(leftlim)  $score_left
	set scorepnt(rightlim) [expr $score_right - $itemwidth]

	set scorepnt(coords) [$stage coords $scorepnt(obj)]		 	 	

	set scorepnt(mx) $x							 			;# 	Save coords of mouse
	set scorepnt(my) $y

	set scorepnt(x) [expr round([lindex $scorepnt(coords) 0])]	;#	Remember coords of text
	set scorepnt(y) [expr round([lindex $scorepnt(coords) 1])]

	catch {unset localcomment}
	if {$is_snd && $comments_attached} {
		GetLocalComment $scorepnt(x) $scorepnt(y)
	}
	set scorepnt(lastx) $scorepnt(x)						;#	Remember new x coord
	set scorepnt(lasty) $scorepnt(y)

	set scorepnt(ismarked) 1								;#	Flag that a text is marked
}

#--- Measure length of string (in CDP standard font!!)

proc GetStringSize {namm} {
	set len [string length $namm]
	set n 0
	set sum 0
	while {$n < $len} {
		switch -- [string index $namm $n] {
			"i" -
			"l" {incr sum 2 }
			"j" {incr sum 3 }
			"f" -
			"r" -
			"t" -
			"/" -
			":" -
			"-" {incr sum 4 }
			"c" -
			"k" -
			"s" -
			"z" {incr sum 5 }
			"m" -
			"w" {incr sum 8 }
			default {incr sum 6 }
		}
		incr n
	}
	return $sum
}

#--- Drag a soundfile (or comment, or both-attached) on the score

proc DragSndOnScore {x y} {
	global stage scorepnt score_right score_left score_p4_bot score_p1_top 

	if {![info exists scorepnt(ismarked)] || !$scorepnt(ismarked)} {
		return
	}
	set mx $x									 		;#	Map from mouse-coords to canvas-coords
	set my $y						 	
	set dx [expr $mx - $scorepnt(mx)]			;#	Find distance from last marked position of mouse
	set dy [expr $my - $scorepnt(my)]
	incr scorepnt(x) $dx								;#	Get coords of dragged point

	if {$scorepnt(x) > $scorepnt(rightlim)} {			;#	Check for drag too far right, and, if ness
		set scorepnt(x) $scorepnt(rightlim)				;#	adjust coords of point
		set dx [expr $scorepnt(x) - $scorepnt(lastx)]	;#	and adjust drag-distance
	} elseif {$scorepnt(x) < $scorepnt(leftlim)} {		;#	Check for drag too far left, and, if ness
		set scorepnt(x) $scorepnt(leftlim)				;#	adjust coords of point
		set dx [expr $scorepnt(x) - $scorepnt(lastx)]	;#	and adjust drag-distance
	}
	set scorepnt(lastx) $scorepnt(x)					;#	Remember new x coord
 
	incr scorepnt(y) $dy									
	if {$scorepnt(y) > $score_p4_bot} {					;#	Check for drag too far down, and, if ness
		set scorepnt(y) $score_p4_bot					;#	adjust coords of point
		set dy [expr $scorepnt(y) - $scorepnt(lasty)]	;#	and adjust drag-distance
	} elseif {$scorepnt(y) < $score_p1_top} {
		set scorepnt(y) $score_p1_top					;#	adjust coords of point
		set dy [expr $scorepnt(y) - $scorepnt(lasty)]	;#	and adjust drag-distance
	}

	set scorepnt(lasty) $scorepnt(y)					;#	Remember new y coord

	$stage move $scorepnt(obj) $dx $dy				 	;#	Move object to new position
	set scorepnt(mx) $mx							 	;#  Store new mouse coords
	set scorepnt(my) $my
}

#--- Finally position a soundfile on the score, after dragging

proc RelocateSndOnScore {} {
	global scorepnt stage localcomment comments_attached

	if [info exists scorepnt(lasty)] {
		set y [AdjustScoreVertPos $scorepnt(lasty)]
		set dy [expr $y - $scorepnt(lasty)]
		if {$dy != 0} {
			$stage move $scorepnt(obj) 0 $dy
		}
	}
	set scorepnt(ismarked) 0
	if {$comments_attached && [info exists localcomment]} {
		set x [lindex [$stage coords $scorepnt(obj)] 0]
		foreach {cx cy dx dy} $localcomment {
			set obj [$stage find closest $cx $cy]
			if {![string match [lindex [$stage itemcget $obj -tag] 0] "comment"]} {
				return
			}
			set dx [expr ($x + $dx) - $cx]
			set dy [expr ($y + $dy) - $cy]
			$stage move $obj $dx $dy	;#	Move comment to new position
		}
		unset localcomment
	}
}

#--- Adjust vert position of sound-name on score, to avoid the panel-separating lines,
#--- and 'quantised' (at text-height distance) to avoid texts overlaying in vertical direction.

proc AdjustScoreVertPos {y} {
	global score_p4_top score_p4_bot score_p3_top score_p3_bot
	global scoreline3 scoreline2 scoreline1 score_vq
	global score_p2_bot score_p2_top score_p1_bot score_p1_top

	if {$y > $score_p4_bot} {
		set y $score_p4_bot
	} elseif {$y > $score_p3_bot} {
		if {$y < $scoreline3} {
			set y $score_p3_bot
		} elseif {$y < $score_p4_top} {
			set y $score_p4_top
		}
	}
	set y [expr $y - $scoreline3]
	set yq [expr round(double($y) / double($score_vq))]
	set y [expr ($yq * $score_vq) + $scoreline3]

	if {$y < $score_p3_bot} {
		if {$y > $score_p2_bot} {
			if {$y < $scoreline2} {
				set y $score_p2_bot
			} elseif {$y < $score_p3_top} {
				set y $score_p3_top
			}
			set y [expr $y - $scoreline2]
			set yq [expr round(double($y) / double($score_vq))]
			set y [expr ($yq * $score_vq) + $scoreline2]
		}
	}
	if {$y < $score_p2_bot} {
		if {$y > $score_p1_bot} {
			if {$y < $scoreline1} {
				set y $score_p1_bot
			} elseif {$y < $score_p2_top} {
				set y $score_p2_top
			}
			set y [expr $y - $scoreline1]
			set yq [expr round(double($y) / double($score_vq))]
			set y [expr ($yq * $score_vq) + $scoreline1]
		}
	}
	if {$y < $score_p1_bot} {
		if {$y < $score_p1_top} {
			set y $score_p1_top
		}
		set yq [expr round(double($y) / double($score_vq))]
		set y [expr $yq * $score_vq]
	}
	return $y
}

########################
# SAVE & RESTORE SCORE #
########################

#--- Erase all sounds and comments from the score and its panels

proc WipeScore {} {
	global current_scorename
	if [AreYouSure] {
		DoSaveAndWipe
		if {[string length $current_scorename] > 0} {
			PossiblyDestroyNamedScore 1
		}
	}
}

#--- Restore erased (or previous) data to the score 

proc RestoreScore {retrieve} {
	global stage scoresave commentsave upsave dnsave uppanel dnpanel uppanelcnt dnpanelcnt score_loaded evv 
	global current_scorename scorenamesave

	if {![info exists scoresave] && ![info exists commentsave] \
	&&  ![info exists upsave] && ![info exists dnsave] && ![info exists scorenamesave]} {
		Inf "no Score To Restore"
		return
	}

	;# SAVE CURRENT STATE

	if {$score_loaded} {
		foreach obj [$stage find withtag snd] {
			lappend lastscoresave [$stage itemcget $obj -text]
			lappend lastscoresave [lindex [$stage coords $obj] 0]
			lappend lastscoresave [lindex [$stage coords $obj] 1]
		}
		foreach obj [$stage find withtag comment] {
			set thiscomment [$stage itemcget $obj -text]
			lappend lastcommentsave $thiscomment
			lappend lastcommentsave [lindex [$stage coords $obj] 0]
			lappend lastcommentsave [lindex [$stage coords $obj] 1]
		}
		if {[info exists uppanel]} {
			foreach nam [array names uppanel] {
				set lastupsave($nam) $uppanel($nam)
			}
		}
		if {[info exists dnpanel]} {
			foreach nam [array names dnpanel] {
				set lastdnsave($nam) $dnpanel($nam)
			}
		}

		;# CLEAR CURRENT SCORE

		catch {$stage delete snd}
		catch {$stage delete comment}
		catch {unset uppanel}
		catch {unset dnpanel}
		set uppanelcnt 0
		set dnpanelcnt 0
	}
	;# WRITE NEW SCORE

	set viewable 0
	set hidden 0

	if [info exists scoresave] {
		foreach {text x y} $scoresave {
			$stage create text $x $y -text $text -tags snd -anchor w -fill $evv(POINT)
		}
		set viewable 1
	} 

	if [info exists commentsave] {
		foreach {text x y} $commentsave {
			$stage create text $x $y -text $text -tags comment -anchor w -fill $evv(POINT)
		}
		set viewable 1
	}

	if [info exists upsave] {
		foreach nam [array names upsave] {
			set uppanel($nam) $upsave($nam)
			incr uppanelcnt
		}
		set hidden 1
	}

	if [info exists dnsave] {
		foreach nam [array names dnsave] {
			set dnpanel($nam) $dnsave($nam)
			incr dnpanelcnt
		}
		set hidden 1
	}

	;# SAVE REPLACED VALUES

	if {$score_loaded} {
		catch {unset scoresave}
		catch {unset commentsave}
		catch {unset upsave}
		catch {unset dnsave}

		if {[info exists lastscoresave]} {
			set scoresave $lastscoresave
		}
		if {[info exists lastcommentsave]} {
			set commentsave $lastcommentsave
		}
		if {[info exists lastupsave]} {
			foreach nam [array names lastupsave] {
				set upsave($nam) $lastupsave($nam)
			}
		}
		if {[info exists lastdnsave]} {
			foreach nam [array names lastdnsave] {
				set dnsave($nam) $lastdnsave($nam)
			}
		}
		if {[info exists current_scorename]} {
			set zorg $current_scorename
		}
	}
	if {(!$viewable) && $hidden} {
		Inf "There Are Hidden Panels: Try Scrolling The Screen"
	}
	if {$retrieve} {
		if [info exists scorenamesave] {
			set current_scorename $scorenamesave
		}
		if [info exists zorg] {
			set scorenamesave $zorg
		}
	}
	RenameScoreDisplay
}

#######################
# GET SOUNDS TO SCORE #
#######################

#--- Get another soundfile, from the present B-List, to the score

proc GetAnotherSoundToScore {} {
	global last_score_bl

	if [info exists last_score_bl] {
		GetBLName 13
	} else {
		Inf "No B-List Has Been Chosen"
	}
}

#--- Get Sounds to Sketch Score (or to Workpad) from Workspace, when at the Score or Workpad

proc GetSoundFromWkspace {home fromscore} {
	global wl pr_wktosc score_files pa grabbed_bln ch evv

	catch {unset grabbed_bln}
	set cnt 0
	if {[string match "#" [string index $home 0]]} {		;#	FROM DIRECTORY OF SCORE-CHOSEN FILE
		set thisdir  [string range $home 1 end]
		foreach fnam [glob -nocomplain [file join $thisdir *]] {
			if [file isdirectory $fnam] {
				continue
			}
			set ftyp [FindFileType $fnam]
			if {$ftyp == $evv(SNDFILE)} {
				lappend filelist $fnam
				incr cnt
			}
		}
		if {$cnt <= 0} {
			Inf "There Are No Soundfiles In The Directory '$thisdir'"
			return
		}
		set home 3
	} elseif {$home == 2} {									;#	FROM WORKSPACE'S CHOSEN FILES LIST
		foreach fnam [$ch get 0 end] {
			if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
				lappend filelist $fnam
				incr cnt
			}
		}
		if {$cnt <= 0} {
			Inf "There Are No Soundfiles On The Chosen Files List"
			return
		}
	} else {												;#	FROM WORKSPACE OR FROM HOME-DIRECTORY
		foreach fnam [$wl get 0 end] {
			if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
				if {!$home} {
					lappend filelist $fnam
					incr cnt
				} elseif {[string match $fnam [file tail $fnam]]} {
					lappend filelist $fnam
					incr cnt
				}
			}
		}
		if {$cnt <= 0} {
			if {$home} {
				Inf "There Are No Soundfiles In The Home Directory"
			} else {
				Inf "There Are No Soundfiles On The Workspace"
			}
			return
		}
	}
	set f .wktosc
	if [Dlg_Create $f "GET WORKSPACE FILES" "set pr_wktosc 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		button $f.b.ok -text "Use Files" -command {set pr_wktosc 1} -width 7 -highlightbackground [option get . background {}]
		button $f.b.qu -text "Close" -command {set pr_wktosc 0} -width 7 -highlightbackground [option get . background {}]
		label $f.lab -text "TO PLAY SOUND, DOUBLE-CLICK ON IT" -fg $evv(SPECIAL)
		pack $f.b.ok -side left -padx 1
		pack $f.b.qu -side right -padx 1
		label $f.l -text "WORKSPACE FILES"
		Scrolled_Listbox $f.e.ll -width 64 -height 24 -selectmode single
		pack $f.e.ll -side top -fill both -expand true
		pack $f.b -side top -fill x -expand true
		pack $f.lab -side top -anchor center -pady 3
		pack $f.l -side top -anchor center -pady 3
		pack $f.e -side top -fill both -expand true
#		wm resizable $f 0 0
		bind $f.e.ll.list <Double-1> {PossiblyPlaySnd %W %y}
		bind $f <Return> {set pr_wktosc 1}
		bind $f <Escape> {set pr_wktosc 0}
	}
	switch -- $home {
		0 { 
			$f.l config -text "WORKSPACE FILES" 
			wm title $f "WORKSPACE FILES"
		}
		1 { 
			$f.l config -text "HOME DIRECTORY FILES" 
			wm title $f "HOME DIRECTORY FILES"
		} 
		2 { 
			$f.l config -text "CHOSEN FILES LIST FILES" 
			wm title $f "CHOSEN FILES LIST FILES"
		} 
		3 { 
			$f.l config -text "SOUNDFILES IN SPECIFIED DIRECTORY" 
			wm title $f "SOUNDFILES IN SPECIFIED DIRECTORY"
		} 
	}
	if {$fromscore} {
		$f.e.ll.list config -selectmode multiple
	} else {
		$f.e.ll.list config -selectmode extended
	}
	raise $f
	update idletasks
	StandardPosition $f
	set clipstyle 0
	set pr_wktosc 0
	set finished 0
	$f.e.ll.list delete 0 end
	foreach fnam $filelist {
		$f.e.ll.list insert end $fnam
	}
	My_Grab 0 $f pr_wktosc $f.e.ll
	while {!$finished} {
		tkwait variable pr_wktosc
		if {!$pr_wktosc} {
			break
		}
		if {$fromscore} {
			set ilist [$f.e.ll.list curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "No Files Selected"
				continue
			}
			catch {unset score_files}
			foreach i $ilist {
				lappend score_files [$f.e.ll.list get $i]
			}
		} else {
			set ilist [$f.e.ll.list curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "No Files Selected"
				continue
			}
			catch {unset badfiles}
			foreach i $ilist {
				set fnam [$f.e.ll.list get $i]
				if {[string match $fnam [file tail $fnam]]} {
					lappend badfiles $fnam
					continue
				}
				if [info exists grabbed_bln] {
					set k [lsearch $grabbed_bln $fnam]
					if {$k >= 0} {
						continue
					}
				}
				lappend grabbed_bln $fnam
			}
			if [info exists badfiles] {
				Inf "Home Directory Files Like '$fnam' Cannot Be Used In Background Listings"
			}
		}
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Get Sound to Sketch Score from Workspace when at the Workspace

proc GetWkspaceSoundToScore {ll ismix} {
	global score_files pa wstk hidden_dir dl wl ch chlist new_score evv

	set is_directory 0
	if {[string match $ll $wl] || [string match $ll $dl]} {
		set ilist [$ll curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0)} {
			Inf "No Files Selected"
			return
		}
		if {[llength $ilist] > 60} {
			Inf "No More Than 60 Files Please"
			return
		}
		set is_hidden_dir 0
		if {[string match $ll $dl] & ([string length $hidden_dir] > 0)} {
			set is_hidden_dir 1
		}
		catch {unset score_files}
		foreach i $ilist {
			set fnam [$ll get $i]
			if {[file isdirectory $fnam]} {
				set is_directory 1
				continue
			}
			if {$is_hidden_dir} {
				set fnam [file join $hidden_dir $fnam]
			}
			set ftyp [FindFileType $fnam]
			if {$ftyp != $evv(SNDFILE)} {
				lappend bad_files $fnam
			} else {
				lappend score_files $fnam
			}
		}
		if {[info exists score_files]} {
			if {[GappedName $score_files]} {
				return
			}
		}
	} elseif {[string match $ll $ch]} {		;#	GET FILES FROM CHOSEN FILES LISTING
		if {![info exists chlist] || ([llength $chlist] <= 0)} {
			Inf "No Files On Chosen Files List"
			return
		}
		catch {unset score_files}
		foreach sfnam $chlist {
			if {$pa($sfnam,$evv(FTYP)) == $evv(SNDFILE)} {
				lappend score_files $sfnam
			}
		}
		if {[info exists score_files]} {
			set score_files [RemoveDupls $score_files]
			if {[GappedName $score_files]} {
				return
			}
		}
	} elseif {$ismix} {		;#	GET FILES FROM MIXFILE
		set fnam $ll
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam'"
			return
		}
		catch {unset score_files}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				if {[string match ";" [string index $item 0]]} {
					break
				} elseif {![file exists $item]} {
					lappend bad_files $item
					break
				}
				set ftyp [FindFileType $item]
				if {$ftyp != $evv(SNDFILE)} {
					lappend bad_files $item
				} else {
					lappend score_files $item
				}
				break
			}
		}
		close $zit
		if {[info exists score_files]} {
			set score_files [RemoveDupls $score_files]
			if {[GappedName $score_files]} {
				return
			}
		}
	} else {		;#	GET FILES FROM LISTING IN TEXTFILE SELECTED ON WKSPACE
		set fnam $ll
		if [catch {open $fnam "r"} zit] {
			Inf "Canot Open File '$fnam'"
			return
		}
		catch {unset score_files}
		while {[gets $zit sfnam] >= 0} {
			if {[string length $sfnam] <= 0} {
				continue
			}
			if {![file exists $sfnam]} {
				lappend bad_files $sfnam
				continue
			}
			set ftyp [FindFileType $sfnam]
			if {$ftyp != $evv(SNDFILE)} {
				lappend bad_files $sfnam
			} else {
				lappend score_files $sfnam
			}
		}
		close $zit
		if {[info exists score_files]} {
			if {[GappedName $score_files]} {
				return
			}
		}
	}
	if [info exists bad_files] {
		if {![info exists score_files]} {
			Inf "None Of These Files Are Soundfiles"
			return
		} else {
			set msg "Some Of These Files Are Not Soundfiles : Just Ignore Those Files ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				catch {unset score_files}
				return
			}
		}
	}
	if [info exists score_files] {
		if {[info exists new_score] && ($new_score == 1)} {
			PutSndOnScore 0 0 
			set new_score 0
			catch {unset score_files}
		} else {
			Inf "Soundfiles Are Ready To Place On The Score (Control Click at position you want)" 
		}
	} elseif {$is_directory} {
		Inf "No Soundfiles Found: Some Selected Items Were Directories" 
	}
}

#####################################
# GET SCORE DATA TO VARIOUS OUTPUTS #
#####################################

#--- Save files on score, in correct time-sequence, to a B-List

proc SaveScore {scoretype} {
	global stage pr_scorelist score_bl background_listing b_l wstk scoremixlist evv

	if {$scoretype == 0} {
		if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
			Inf "No Files Selected"
			return
		}
		set filelist $scoremixlist
	} else {
		set filelist [ListFromScore $scoretype 0]
		if {[llength $filelist] <= 0} {
			set i 0
			foreach obj [$stage find withtag snd] {
				incr i
				break
			}
			if {$i == 0} {
				Inf "No Score To Save"
			}
			return
		}
	}
	set queried 0
	set filelist [RemoveDuplicates $filelist]
	set len [llength $filelist]
	incr len -1
	for {set n $len} {$n >= 0} {incr n -1} {
		set fnam [lindex $filelist $n]
		if [string match $fnam [file tail $fnam]] {
			if {!$queried} {
				set msg "This Score Contains Non-Backed-Up Files Which Cannot Be Placed In A B-List.\n\nCreate B-List Which Excludes Them ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
				set filelist [lreplace $filelist $n $n]
				set queried 1
			} else {
				set filelist [lreplace $filelist $n $n]
			}
		}
	}		

	set f .scorefile

	if [Dlg_Create $f "SCORE TO B-LIST" "set pr_scorelist 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		button $f.b.ok -text "Save" -command {set pr_scorelist 1} -width 7 -highlightbackground [option get . background {}]
		button $f.b.qu -text "Abandon" -command {set pr_scorelist 0} -width 7 -highlightbackground [option get . background {}]
		pack $f.b.ok -side left -padx 1
		pack $f.b.qu -side right -padx 1
		label $f.e.l -text "NAME OF B-List"
		entry $f.e.e -textvariable score_bl -width 20
		pack $f.e.l $f.e.e -side left -padx 3 -anchor center
		pack $f.b $f.e -side top -pady 3 -fill x -expand true
#		wm resizable $f 0 0
		bind $f <Return> {set pr_scorelist 1}
		bind $f <Escape> {set pr_scorelist 0}
	}
	raise $f
	set score_bl ""
	set pr_scorelist 0
	set finished 0
	My_Grab 0 $f pr_scorelist $f.e.e
	while {!$finished} {
		tkwait variable pr_scorelist
		if {!$pr_scorelist} {
			break
		}
		if {[string length $score_bl] <= 0} {
			Inf "No B-List Name Given"
			continue
		}
		if {[regexp {[^A-Za-z0-9\-\_]+} $score_bl]} {
			Inf "Invalid Characters Used In B-List Name"
			continue
		}
		set score_bl [string tolower $score_bl]
		set k [lsearch -exact [array names b_l] $score_bl]
		if {$k >= 0} {
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
				-message "This B-List Name Already Exists : Add Files To This List ?"]
			if {$choice == "no"} {
				continue
			}
		}
		foreach fnam $filelist {
			lappend b_l($score_bl) $fnam
		}
		SaveBL $background_listing
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Save files on score, in correct time-sequence, to Workspace or Chosen Files List

proc ScoreToWkspace {scoretype toch} {
	global stage pr_scorelist wl ch chlist chcnt chpos scoremixlist nuparse wstk pr_score rememd evv

	if {$scoretype == 0} {
		if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
			Inf "No Files Selected"
			return
		}
		set filelist $scoremixlist
	} else {
		set filelist [ListFromScore $scoretype 0]
		if {[llength $filelist] <= 0} {
			set i 0
			foreach obj [$stage find withtag snd] {
				incr i
				break
			}
			if {$i == 0} {
				Inf "No Score To Save"
			}
			return
		}
	}
	set filelist [RemoveDuplicates $filelist]
	foreach fnam $filelist {
		lappend tochlist $fnam
		if {[LstIndx $fnam $wl] >= 0} {
			lappend gotlist $fnam
		} else {
			lappend grablist $fnam
		}
	}
	if {![info exists grablist] && !$toch} {
		Inf "All These Files Are Already On The Workspace"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message "Exit To Worskpace ?"]
		if {$choice == "yes"} {
			set pr_score 0
		}
		return
	} 
	if [info exists grablist] {
		set grablist [ReverseList $grablist]
		foreach fnam $grablist {
			if {![file exists $fnam]} {
				lappend badfiles(0) $fnam
				continue
			} elseif {![info exists pa($fnam,$evv(FTYP))]} {
				if {[DoParse $fnam $wl 0 0] <= 0} {
					lappend badfiles(1) $fnam
					continue
				}
			}
			if {$evv(DFLT_SR) > 0} {
				set filetype $pa($fnam,$evv(FTYP))
				if {($filetype & $evv(IS_A_SNDSYSTEM_FILE)) && ($filetype != $evv(ENVFILE))} {
					if {$filetype == $evv(SNDFILE)} {
						if {$pa($fnam,$evv(SRATE)) != $evv(DFLT_SR)} {
  							PurgeArray $fnam
							lappend badfiles(2) $fnam
							continue
						}
					} elseif {$pa($fnam,$evv(ORIGRATE)) != $evv(DFLT_SR)} {
						PurgeArray $fnam
						lappend badfiles(2) $fnam
						continue
					}
				} elseif {$filetype == $evv(PSEUDO_SND)} {
					if {$pa($fnam,$evv(SRATE)) != $evv(DFLT_SR)} {
						PurgeArray $fnam
						lappend badfiles(2) $fnam
						continue
					}
				}			
			}
			if [info exists nuparse] {					;# If a pa had been created for file, ONLY whilst on Score
				set kk [lsearch $nuparse $fnam]			;# avoid that pa being deleted once we exit the Sketch Score
				if {$kk >= 0} {
					set nuparse [lreplace $nuparse $kk $kk]	
				}
			}
			$wl insert 0 $fnam
			WkspCnt $fnam 1
			catch {unset rememd}
			lappend done $fnam
		}
	}
	if {$toch} {
		catch {unset done}
		set n 0
		while {$n < 3} {
			if [info exists badfiles($n)] {
				foreach fnam $badfiles($n) {
					set k [lsearch -exact $tochlist $fnam]
					if {$k >= 0} {
						set tochlist [lreplace $tochlist $k $k]
					}
				}
			}
			incr n
		}
		if {[llength $tochlist] > 0} {
			if [info exists chlist] {
				set OK 0
				foreach fnam $tochlist {
					set k [lsearch $chlist $fnam]
					if {$k < 0} {
						set OK 1
						break
					}
				}
				if {!$OK && ([llength $chlist] == [llength $tochlist])} {
					Inf "These Files Already Make Up The Chosen Files List"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message "Exit To Worskpace ?"]
					if {$choice == "yes"} {
						set pr_score 0
					}
					return
				}
			}
			ClearAndSaveChoice
			set chpos -1
			foreach fnam $tochlist {
				lappend chlist $fnam
				$ch insert end $fnam
				incr chcnt
				lappend done $fnam
			}
		}
	}
	if [info exists done] {
		if {$toch} {
			set msg "Files Have Been Placed On The Chosen Files List\n\n"
		} else {
			set msg "Files Have Been Placed On The Workspace\n\n"
		}
	} else {
		if {$toch} {
			set msg "No Files Have Been Placed On The Chosen Files List\n\n"
		} else {
			set msg "No Files Have Been Placed On The Workspace\n\n"
		}
	}
	if [info exists badfiles(0)] {
		append msg "The Following Files No Longer Exist\n\n"
		foreach fnam $badfiles(0) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if [info exists badfiles(1)] {
		append msg "The Following Files Are Not CDP Compatible\n\n"
		foreach fnam $badfiles(1) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if [info exists badfiles(2)] {
		append msg "The Following Files Are At The Wrong Sampling Rate\n\n"
		foreach fnam $badfiles(2) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if {!$toch && [info exists gotlist]} {
		append msg "The Following Files Are Already On The Workspace\n\n"
		set zzcnt 0
		foreach fnam $gotlist {
			if {$zzcnt > 60} {
				append msg "AND MORE"
				break
			}
			append msg "$fnam  "
			incr zzcnt
		}
	}
	if {[string length $msg] > 0} {
		Inf $msg
	}
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message "Exit To Worskpace ?"]
	if {$choice == "yes"} {
		set pr_score 0
	}
}

#---- Save Score as elementary mixfile

proc SaveScoreToMix {scoretype endtoend} {
	global nuparse wstk pa pr_sctomix scmixname scmixdir wl scoremixlist sc_clips2 sc_overlap stage evv

	if {$scoretype == 0} {
		if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
			Inf "No Files Selected"
			return
		}
	}
	switch -- $endtoend {
		2 -
		4 {
			if {![info exists sc_clips2] || ($sc_clips2 < 0.0)} {
				Inf "No Testmix Time-Step Has Previously Been Set"
				return
			}
		}
		3 {
			if {![info exists sc_overlap] || ($sc_overlap < 0.0)} {
				Inf "No Testmix Overlap Has Previously Been Set"
				return
			}
			if {[llength $scoremixlist] != 2} {
				Inf "This Option Only Works With A Pair Of Files"
				return
			}
		}
	}
	if {$scoretype == 0} {
		set filelist $scoremixlist
	} else {
		set filelist [ListFromScore $scoretype 1]
		if {[llength $filelist] <= 0} {
			set i 0
			foreach obj [$stage find withtag snd] {
				incr i
				break
			}
			if {$i == 0} {
				Inf "No Score To Save"
			}
			return
		}
	}
	catch {unset scmix}
	set sum 0

	foreach fnam $filelist {
		if {![info exists pa($fnam,$evv(FTYP))]} {
			if {[DoParse $fnam 0 0 0] <= 0} {
				lappend badfiles(1) $fnam
				continue
			}
			lappend nuparse $fnam
		}
		if {$evv(DFLT_SR) > 0} {
			set filetype $pa($fnam,$evv(FTYP))
			if {($filetype & $evv(IS_A_SNDSYSTEM_FILE)) && ($filetype != $evv(ENVFILE))} {
				if {$filetype == $evv(SNDFILE)} {
					if {$pa($fnam,$evv(SRATE)) != $evv(DFLT_SR)} {
 							PurgeArray $fnam
						lappend badfiles(2) $fnam
						continue
					}
				} elseif {$pa($fnam,$evv(ORIGRATE)) != $evv(DFLT_SR)} {
					PurgeArray $fnam
					lappend badfiles(2) $fnam
					continue
				}
			} elseif {$filetype == $evv(PSEUDO_SND)} {
				if {$pa($fnam,$evv(SRATE)) != $evv(DFLT_SR)} {
					PurgeArray $fnam
					lappend badfiles(2) $fnam
					continue
				}
			}			
		}
		switch -- $endtoend {
			0 {
				switch -- $pa($fnam,$evv(CHANS)) {
					1 { set line "$fnam 0.0 1 1.0 C" }
					2 { set line "$fnam 0.0 2 1.0 L 1.0 R" }
				}
			}
			1 -
			2 -
			3 - 
			4 {
				switch -- $pa($fnam,$evv(CHANS)) {
					1 { set line "$fnam $sum 1 1.0 C" }
					2 { set line "$fnam $sum 2 1.0 L 1.0 R" }
				}
				switch -- $endtoend {
					1 { set sum [expr $sum + $pa($fnam,$evv(DUR))] }
					2 { set sum [expr $sum + $sc_clips2] }
					4 { set sum [expr $sum + $pa($fnam,$evv(DUR)) - $sc_clips2] }
					3 { 
						if {![info exists scmix]} {								;# at line 1,
							set sum [expr $pa($fnam,$evv(DUR)) - $sc_overlap]	;# calculate starttime of file2.
							if {$sum < 0.0} {									;# If starttime file2 falls after overlap start
								set line [lreplace $line 1 1 [expr -$sum]]		;# set file1 to start after zero
								set sum 0.0										;# and file2 to start at zero
							}
						}
					}
				}
			}
		}
		lappend scmix $line
	}
	if {![info exists scmix]} {
		set no_mix 1
		set msg "No CDP-Valid Sound Files Found\n\n"
	} else {
		set msg ""
	}
	if [info exists badfiles(0)] {
		append msg "The Following Files No Longer Exist\n\n"
		foreach fnam $badfiles(0) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if [info exists badfiles(1)] {
		append msg "The Following Files Are Not CDP Compatible\n\n"
		foreach fnam $badfiles(1) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if [info exists badfiles(2)] {
		append msg "The Following Files Are At The Wrong Sampling Rate\n\n"
		foreach fnam $badfiles(2) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if {[string length $msg] > 0} {
		if [info exists no_mix] {
			return
		}
		append msg "\n\nDO You Wish To Proceed ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	set f .sctomix
	if [Dlg_Create $f "MAKE DUMMY MIXFILE" "set pr_sctomix 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		frame $f.d -bd $evv(SBDR)
		button $f.b.ok -text "Make Mix" -command {set pr_sctomix 1} -width 7 -highlightbackground [option get . background {}]
		button $f.b.qu -text "Close" -command {set pr_sctomix 0} -width 7 -highlightbackground [option get . background {}]
		pack $f.b.ok -side left -padx 1
		pack $f.b.qu -side right -padx 1
		label $f.e.l -text "MIXFILE NAME" -width 12
		entry $f.e.n -textvariable scmixname -width 40
		button $f.d.b -text "Directory" -command {DoListingOfDirectories .sctomix.d.e} -width 11 -highlightbackground [option get . background {}]
		entry $f.d.e -textvariable scmixdir -width 40
		pack $f.e.l $f.e.n -side left -padx 3 -anchor center
		pack $f.d.b $f.d.e -side left -padx 3 -anchor center
		pack $f.b $f.e $f.d -side top -fill x -pady 2 -expand true
#		wm resizable $f 0 0
		bind $f <Return> {set pr_sctomix 1}
		bind $f <Escape> {set pr_sctomix 0}
	}
	raise $f
	set finished 0
	set scmixname ""
	if {![info exists scmixdir]} { 
		set scmixdir ""
	}
	set pr_sctomix 0
	My_Grab 0 $f pr_sctomix $f.e.n
	while {!$finished} {
		tkwait variable pr_sctomix
		if {!$pr_sctomix} {
			break
		}
		if {[string length $scmixname] <= 0} {
			Inf "No Mixfile Name Given"
			continue
		}
		if {![ValidCDPRootname $scmixname]} {
			continue
		}
		set this_ext [GetTextfileExtension mix]
		set outname $scmixname$this_ext

		if {[string length $scmixdir] > 0} {
			if {![file exists $scmixdir] || ![file isdirectory $scmixdir]} {
				Inf "The Directory '$scmixdir' Does Not Exist"
				continue
			} else {
				set outname [file join $scmixdir $outname]
			}
		}
		set outname [string tolower $outname]
		if [file exists $outname] {
			set msg "File '$outname' Exists: Overwrite It ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				continue
			} else {
				if {![DeleteTextFileFromSystem $outname]} {
					continue
				}
			}
		}
		if [catch {open $outname w} zit] {
			Inf "Cannot Open File '$outname' To Write Mix"
			continue
		}
		foreach line $scmix {
			puts $zit $line
		}
		close $zit
		set msg "The File '$outname' Has Been Created"
		if {[FileToWkspace $outname 1 0 0 0 1] <= 0} {
			append msg "\n\nBut Is Not Currently On The Workspace"
		}
		UpdatedIfAMix $outname 1 ;#	UPDATES MIX MANAGEMENT , EVEN IF FILETOWKSPACE FAILS
		Inf $msg
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Delete Text file from system

proc DeleteTextFileFromSystem {fnam} {
	global wstk pa background_listing wl rememd evv

#NOV 2011
	if [IgnoreSoundloomxxxFilenames $fnam] {
		return 0
	}
	if [catch {file delete $fnam} q] {
		set choice [tk_messageBox -type yesno -default yes -message "Cannot Delete File '$fnam': Force Deletion?" \
				-icon question -parent [lindex $wstk end]]
		if [string match yes $choice] {				
			if [catch {file delete $fnam} zorg] {
				Inf "Cannot Delete File '$fnam'"
				return 0
			}
		} else {
			return 0
		}
	}
	if {[IsInBlists $fnam]} {
		set OK 1
		set msg "The Overwritten File '$fnam' Was In One Or More Background Listings\n\nRemove Those Mentions ?"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			set OK 0
		}
		if {$OK && [RemoveFromBLists $fnam]} {
			SaveBL $background_listing
		}
	}
	set i [LstIndx $fnam $wl]
	if {$i >= 0} {
		WkspCnt [$wl get $i] -1
		$wl delete $i
		catch {unset rememd}
		RemoveFromChosenlist $fnam
	}
	PurgeArray $fnam
	RemoveFromDirlist $fnam
	return 1
}

#######################################
# DEDUCE FILE ORDER FROM SCORE LAYOUT #
#######################################

#--- Deduce file order from score layout

proc ListFromScore {scoretype nodupl} {
	global stage scoreline1 scoreline2 scoreline3

	foreach obj [$stage find withtag snd] {
		lappend sortlist [$stage itemcget $obj -text]
		lappend sortlist [lindex [$stage coords $obj] 0]
		lappend sortlist [lindex [$stage coords $obj] 1]
	}
	if {![info exists sortlist]} {
		return {}
	}
	foreach {fnam x y} $sortlist {
		if {$y < $scoreline1} {
			lappend scoresys(1) [list $fnam $x]
		} elseif {$y < $scoreline2} {
			lappend scoresys(2) [list $fnam $x]
		} elseif {$y < $scoreline3} {
			lappend scoresys(3) [list $fnam $x]
		} else {
			lappend scoresys(4) [list $fnam $x]
		}
	}
	set switchstep 0

	switch -- $scoretype {
		1		{ set k 1; set limit 1 ; set step 1}
		12		{ set k 1; set limit 2 ; set step 1}
		123		{ set k 1; set limit 3 ; set step 1}
		all		-
		1234	{ set k 1; set limit 4 ; set step 1}
		2		{ set k 2; set limit 2 ; set step 1}
		23		{ set k 2; set limit 3 ; set step 1}
		234		{ set k 2; set limit 4 ; set step 1}
		3		{ set k 3; set limit 3 ; set step 1}
		34		{ set k 3; set limit 4 ; set step 1}
		13		{ set k 1; set limit 3 ; set step 2}
		14		{ set k 1; set limit 4 ; set step 3}
		124		{ set k 1; set limit 4 ; set step 1; set switchstep 1}
		134		{ set k 1; set limit 4 ; set step 2; set switchstep 1}
		23		{ set k 2; set limit 3 ; set step 1}
		24		{ set k 2; set limit 4 ; set step 2}
		234		{ set k 2; set limit 4 ; set step 1}
		4		{ set k 4; set limit 4 ; set step 1}
	}
	set filelist {}
	while {$k <= $limit} {
		if [info exists scoresys($k)] {
			set len [llength $scoresys($k)]
			if {$len > 1} {
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					set x0 [lindex [lindex $scoresys($k) $n] 1]
					set m [expr $n + 1]
					while {$m < $len} {
						set x1 [lindex [lindex $scoresys($k) $m] 1]
						if {$x1 < $x0} {
							set tempn [lindex $scoresys($k) $n]
							set tempm [lindex $scoresys($k) $m]
							set scoresys($k) [lreplace $scoresys($k) $n $n $tempm]
							set scoresys($k) [lreplace $scoresys($k) $m $m $tempn]
							set x0 $x1
							incr m -1
						}
						incr m
					}
					incr n
				}
			}	
			foreach item $scoresys($k) {
				lappend filelist [lindex $item 0]
			}
		}
		incr k $step
		if {$switchstep} {
			if {$step == 1} {
				set step 2
			} else {
				set step 1
			}
		}
	}
	if {($scoretype != 1234) && ($scoretype != "all") && ([llength $filelist] <= 0)} {
		Inf "No Sounds Found In The Specified Panels"
	}
	if {$scoretype == "all"} {
		set filelist [AddPanelsToFilelist $filelist]
	}
	return $filelist
}

#---- Incorporate files in hidden panels into the list of files to be processed.

proc AddPanelsToFilelist {filelist} {
	global uppanel dnpanel uppanelcnt dnpanelcnt 

	set nufiles {}
	if {$uppanelcnt > 0} {
		set k $uppanelcnt
		incr k -1
		while {$k >= 0} {
			set panelsnds [lindex $uppanel($k) 0]
			if {[llength $panelsnds] > 0} {
				set thesefiles [SortPanelSnds $panelsnds]
				set nufiles [concat $nufiles $thesefiles]
			}
			incr k -1
		}
		set filelist [concat $nufiles $filelist]
	}
	set nufiles {}
	if {$dnpanelcnt > 0} {
		set k 0
		while {$k < $dnpanelcnt} {
			set panelsnds [lindex $dnpanel($k) 0]
			if {[llength $panelsnds] > 0} {
				set thesefiles [SortPanelSnds $panelsnds]
				set nufiles [concat $nufiles $thesefiles]
			}
			incr k
		}
		set filelist [concat $filelist $nufiles]
	}
	return $filelist
}

#---- Sort sounds in a panel into left-right order

proc SortPanelSnds {panelsnds} {

	set len 0
	foreach {snd x y} $panelsnds {
		set sortpair [list $x $snd]
		lappend sortpairs $sortpair
		incr len
	}
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {					;# BUBBLE SORT PAIRS
		set nx [lindex [lindex $sortpairs $n] 0]
		set m [expr $n + 1]
		while {$m < $len} {
			set mx [lindex [lindex $sortpairs $m] 0]
			if {$mx < $nx} {
				set sortn [lindex $sortpairs $n]
				set sortm [lindex $sortpairs $m]
				set sortpairs [lreplace $sortpairs $n $n $sortm]
				set sortpairs [lreplace $sortpairs $m $m $sortn]
				set nx $mx
			}
			incr m
		}
		incr n
	}
	foreach sortpair $sortpairs {
		lappend nufiles [lindex $sortpair 1]
	}
	return $nufiles
}

################################
# CREATE TEST MIX SOUND OUTPUT #
################################

#----- Generate a test mix output from the score

proc ScoreTestOut {scoretype} {
	global pr_sctest sc_clips clipstyle pa wstk stage nuparse scoremixlist evv 

	if {$scoretype == 0} {
		if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
			Inf "No Files Selected"
			return
		}
		set filelist $scoremixlist
	} else {
		set filelist [ListFromScore $scoretype 1]
		if {[llength $filelist] <= 0} {
			set i 0
			foreach obj [$stage find withtag snd] {
				incr i
				break
			}
			if {$i == 0} {
				Inf "No Score To Test"
			}
			return
		}
	}
	set msg ""

	if {![ClearTempFiles 0 $msg]} {
		return
	}
	set f .sctest
	if [Dlg_Create $f "TEST A SEQUENCE" "set pr_sctest 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.e1 -bd $evv(SBDR)
		frame $f.e2 -bd $evv(SBDR)
		frame $f.s -bd $evv(SBDR)
		button $f.b.ok -text "Run Mix" -command {set pr_sctest 1} -width 7 -highlightbackground [option get . background {}]
		button $f.b.qu -text "Abandon" -command {set pr_sctest 0} -width 7 -highlightbackground [option get . background {}]
		pack $f.b.ok -side left -padx 1
		pack $f.b.qu -side right -padx 1
		label $f.e1.l -text "MAX DURATION OF FILE CLIPS"
		entry $f.e1.e -textvariable sc_clips -width 20
		pack $f.e1.l $f.e1.e -side left -padx 3 -anchor center
		label $f.e2.l -text "CLIP STYLE"
		radiobutton $f.e2.0 -variable clipstyle -text "File Start" -value 0
		radiobutton $f.e2.1 -variable clipstyle -text "File End"   -value 1
		radiobutton $f.e2.2 -variable clipstyle -text "Start+End"  -value 2
		pack $f.e2.l $f.e2.0 $f.e2.1 $f.e2.2 -side left -padx 3 -anchor center
		Scrolled_Listbox $f.s.ll -width 64 -height 24 -selectmode single
		pack $f.s.ll -side top -fill both -expand true
		pack $f.b $f.e1 $f.e2 $f.s -side top -pady 3 -fill x -expand true
#		wm resizable $f 0 0
		bind .sctest <Control-Key-p> {UniversalPlay list .sctest.s.ll.list}
		bind .sctest <Control-Key-P> {UniversalPlay list .sctest.s.ll.list}
		bind .sctest <Key-space>	 {UniversalPlay list .sctest.s.ll.list}
		bind .sctest <Return> {set pr_sctest 1}
		bind .sctest <Escape> {set pr_sctest 0}
	}
	$f.s.ll.list delete 0 end
	foreach fff $filelist {
		$f.s.ll.list insert end $fff
	}
	raise $f
	set clipstyle 0
	set pr_sctest 0
	if {![info exists sc_clips]} { 
		set sc_clips ""
	}
	set finished 0
	My_Grab 0 $f pr_sctest $f.e1.e
	while {!$finished} {
		tkwait variable pr_sctest
		if {!$pr_sctest} {
			break
		}
		if {[string length $sc_clips] <= 0} {
			Inf "No Maximum Duration Entered"
			continue
		}
		if {![IsPositiveNumber $sc_clips]} {
			Inf "Invalid Maximum Duration Entered"
			continue
		}
		if {$sc_clips < 0.1} {
			Inf "Maximum Duration Is Too Short"
			continue
		}
		foreach fnam $filelist {
			if {![info exists pa($fnam,$evv(FTYP))]} {
				if {[DoParse $fnam 0 0 0] <= 0} {
					set finished 1
					break
				} else {
					lappend nuparse $fnam
				}
			}
		}
		if {$finished} {
			break
		}
		set cnt 0
		set minlen [expr $sc_clips + 0.1]
		set srate $pa([lindex $filelist 0],$evv(SRATE))
		catch {unset cutfiles}
		catch {unset chans}
		foreach fnam $filelist {					;#	DECIDE WHICH FILES TO CUT
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Files Are Not All Of Same Sample Rate: Cannot Do The Mix"
				set finished 1
				break
			}
			lappend chans $pa($fnam,$evv(CHANS))
			if {$pa($fnam,$evv(DUR)) > $minlen} {
				lappend cutfiles 1
			} else {
				lappend cutfiles 0
			}
		}
		if {$finished} {
			break
		}
		set mixedchans 0							;#	ARE ALL FILES SAME NO OF CHANS ?
		set thischan [lindex $chans 0]
		foreach cha [lrange $chans 1 end] {
			if {$cha != $thischan} {
				set mixedchans 1
				break
			}
		}											;# CALCULATE SPACE REQUIRED, AND WHICH FILES NEED MONO-STEREO CONVERSION
		set totlen 0.0
		catch {unset convert}
		foreach cut $cutfiles cha $chans fnam $filelist {
			if {$cut} {
				set len $sc_clips
				if {$cha == 2} {
					set totlen [expr $totlen + ($len * 4)]	;# length of stereo cut + length of segment in final join (2+2)
					lappend convert 0
				} elseif {$mixedchans} {
					set totlen [expr $totlen + ($len * 5)]	;# length mono cut + length stereo derivative + seglen (1+2+2)
					lappend convert 1
				} else {
					set totlen [expr $totlen + ($len * 2)]	;# length of mono cut + seglen(1+1)
					lappend convert 0
				}
			} else {
				set len $pa($fnam,$evv(CHANS))
				if {$cha == 2} {
					set totlen [expr $totlen + ($len * 2)]	;# seglen
					lappend convert 0
				} elseif {$mixedchans} {
					set totlen [expr $totlen + ($len * 4)]	;# length of stereo deriv + seglen (2+2)
					lappend convert 1
				} else {
					set totlen [expr $totlen + $len]		;# seglen
					lappend convert 0
				}
			}
		}											;# CHECK FOR SUFFICIENT DISKSPACE
		set totlen [expr round($totlen * $srate)]
		if {![CheckScoreTestDiskspace $totlen $srate]} {
			break
		}											;# CONSTRUCT APPROPRIATE BATCHFILE
		set batch [ConstructScoreBatch $cutfiles $convert $filelist $sc_clips $clipstyle]
		if {([llength $batch] == 1) && ([lindex $cutfiles 0] == 1)} {
			set len [llength [lindex $batch 0]]
			incr len -3
			set outfilename [lindex [lindex $batch 0] $len]
		} else {
			set outfilename [lindex [lindex $batch end] end]
		}
		append outfilename $evv(SNDFILE_EXT)
		set title "Running Clips Mix"

		if [RunScoreTestBatchFile $batch $title] {			;# ATTEMPT TO RUN BATCHFILE

			set is_playing 0
			set msg "Score Test Mix Completed : Hear The Result ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				PlaySndfile $outfilename 0			;# PLAY OUTPUT
			} 
		}
		set msg "\n   'Make Test Sequence' And Playing Files On The Sketch Score"
		append msg "\n                                     Will Not Respond"		
		if {![ClearTempFiles 1 $msg]} {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Save data sent back from diskspace reading program

proc ScoreWriteDiskData {} {
	global CDPdsk diskvu_got scoredisk evv
	if {[info exists CDPdsk] && [eof $CDPdsk]} {
		set diskvu_got 1
		catch {close $CDPdsk}
		return
	} else {
		while {[gets $CDPdsk line] >= 0} {
			set line [string trim $line]
			set thislen [string length $line]
			if {$thislen > 0} {
				if [string match INFO:* $line] {
					set line [string range $line 6 end] 
					lappend scoredisk "$line"
				} elseif [string match ERROR:* $line] {
					set diskvu_got 1
					catch {close $CDPdsk}
				}
			}
		}
	}
}			

#------ Find available space on disk

proc CheckScoreTestDiskspace {totlen srate} {
	global CDPdsk scoredisk diskvu_got wstk evv

	if [string match $evv(BITRES) "float"] {
		set k 64
		set msg "64-bit Float For Disk Calculation ? (Press NO for 32-bit)"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message "$msg"]
		if {$choice == "no"} {
			set k 32
		}
	} else {
		set k [expr $evv(BITRES) / $evv(BITS_PER_BYTE)]
	}
	set totlen [expr round ($totlen * $k)]

	set diskvu_got 0
	set cmd [file join $evv(CDPROGRAM_DIR) diskspace]
	if [ProgMissing $cmd "CANNOT FIND  THE AMOUNT OF SPACE ON THE DISK."] {
		return 0
	}				
	lappend cmd $srate
	if [catch {open "|$cmd"} CDPdsk] {
		ErrShow "CANNOT RUN THE DISKSPACE UTILITY"
		catch {unset CDPdsk}
		return 0
	} else {
		fileevent $CDPdsk readable ScoreWriteDiskData
		fconfigure $CDPdsk -buffering line
		if {!$diskvu_got} {
			vwait diskvu_got
		}
	}
	if {![info exists scoredisk]} {
		Inf "Failed To Read Available Disk Space"
		return 0
	}
	set gotit 0
	foreach line $scoredisk {
		set line [split $line]
		foreach item $line {
			if [string match $item "bytes"] {
				set gotit 1
				break
			}
		}
		if {$gotit} {
			foreach item $line {
				if [IsPositiveNumber $item] {
					set this_diskspace $item
					break
				}
			}
			break
		}
	}
	if {!$gotit} {
		Inf "Failed To Find Available Disk Space"
		return 0
	}
	if {$totlen > $this_diskspace} {
		Inf "Insufficient Diskspace ($this_diskspace bytes) To Make This Test Mix (requires $totlen bytes)"
		return 0
	}
	return 1
}

#------- Construct batchfile for Score Test Mix

proc ConstructScoreBatch {cutfiles convert filelist sc_clips clipstyle} {
	global pa evv

	set n 0												;#	 CONSTRUCT BATCHFILE

	if {[llength $filelist] == 1} {
		foreach cut $cutfiles con $convert fnam $filelist {
			set dur $pa($fnam,$evv(DUR))
			set excise [expr $sc_clips/2]
			if {$cut} {
				switch -- $clipstyle {
					0 {	set line "sfedit cut 1 $fnam $evv(DFLT_OUTNAME)$n 0 $sc_clips"						;# FILE START }
					1 {	set line "sfedit cut 1 $fnam $evv(DFLT_OUTNAME)$n [expr $dur - $sc_clips] $dur"		;# FILE END	}
					2 {	set line "sfedit excise 1 $fnam $evv(DFLT_OUTNAME)$n $excise [expr $dur - $excise]" ;# FILE START & END }
				}
			} else {
				set line "housekeep copy 1 $fnam $evv(DFLT_OUTNAME)$n"
			}
			lappend batch $line
		}
	} else {
		foreach cut $cutfiles con $convert fnam $filelist {
			set dur $pa($fnam,$evv(DUR))
			set excise [expr $sc_clips/2]
			if {$cut} {
				switch -- $clipstyle {
					0 {	set line "sfedit cut 1 $fnam $evv(DFLT_OUTNAME)$n 0 $sc_clips"						;# FILE START }
					1 {	set line "sfedit cut 1 $fnam $evv(DFLT_OUTNAME)$n [expr $dur - $sc_clips] $dur"		;# FILE END }
					2 {	set line "sfedit excise 1 $fnam $evv(DFLT_OUTNAME)$n $excise [expr $dur - $excise]" ;# FILE START & END }
				}
				lappend batch $line
				if {$con} {
					set m $n
					incr n
					set line "housekeep chans 5 $evv(DFLT_OUTNAME)$m $evv(DFLT_OUTNAME)$n"
					lappend batch $line
				}
				lappend joinlist $evv(DFLT_OUTNAME)$n
				incr n
			} elseif {$con} {
				set line "housekeep chans 5 $fnam $evv(DFLT_OUTNAME)$n"
				lappend batch $line
				lappend joinlist $evv(DFLT_OUTNAME)$n
				incr n
			} else {
				lappend joinlist $fnam
			}
		}
		set line "sfedit join "
		set line [concat $line $joinlist $evv(DFLT_OUTNAME)$n]
		lappend batch $line
	}
	return $batch
}

#--- Run the Batchfile associated with score test

proc RunScoreTestBatchFile {batch_file title} {
	global program_messages CDPidrun prg_dun prg_abortd evv

	Block $title
	set returnval 1
	catch {unset CDPidrun}
	catch {unset program_messages}
	foreach line $batch_file {
		set CDP_cmd $line
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		set firstword [lindex $CDP_cmd 0]
		set firstword [file join $evv(CDPROGRAM_DIR) $firstword]
		set CDP_cmd [lreplace $CDP_cmd 0 0 $firstword]
		if [catch {open "|$CDP_cmd"} CDPidrun] {
			set errorline "$CDPidrun :\nCAN'T RUN BATCH PROCESS\n$line"
			set returnval 0
			break
	   	} else {
	   		fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set errorline "BATCH PROCESS FAILED\n$line"
			set returnval 0
			break
		}
	}
	if [info exists errorline] {
		Inf "$errorline"
	}
	if [info exists program_messages] {
		Inf "$program_messages"
		unset program_messages
	}
	UnBlock
	return $returnval
}

#----- Deal with Info (expecially error info) from score testmix batch run

proc Display_Score_Batch_Running_Info {} {
	global CDPidrun prg_dun prg_abortd program_messages

	if {[info exists CDPidrun] && [eof $CDPidrun]} {
		set prg_dun 1
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match ERROR:* $line] {
			set program_messages "$line"
			set prg_abortd 1
			set prg_dun 0
			return
		} elseif [string match "Unknown*" $line] {
			set program_messages "$line"
			set prg_abortd 1
			set prg_dun 0
			return
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		} else {
			return
		}
	}
	update idletasks
}

#--- Move prop-arrays for files which are not on the workspace

proc ParsePurge {} {
	global nuparse
	if [info exists nuparse] {
		foreach fnam $nuparse {
			PurgeArray $fnam
		}
	}
}

#----- Clear temporary files from Sketch mix process

proc ClearTempFiles {after outmsg} {
	global wstk evv

	set finished 0
	set retried 0
	while {!$finished} {
		catch {unset badfiles}
		foreach fnam [glob -nocomplain -- *] {
			set fnam [string tolower $fnam]
			set ftail [file tail $fnam]
			if [string match $evv(DFLT_OUTNAME)* $ftail] {
				if [catch {file delete $fnam} zit] {
					lappend badfiles [file tail $fnam]
				}
			}
		}
		if [info exists badfiles] {
			set msg "Failed To Delete Temporary Files\n\n"
			set i 0
			foreach fnam $badfiles {
				append msg "$fnam   "
				incr i
				if {$i > 20} {
					append msg "\n\nAnd More"
					break
				}
			}
			if {$after} {
				if {$retried} {
					append msg "\n\n    If You Exit Without Closing Files Which Are Playing"
					append msg "\n(Or Without Waiting For Temporary Files To Be Cleared)"
					append msg $outmsg
					append msg "\n           Until Those Files Have Finished Playing."
					append msg "\n\n(Occasionally You May Have To Restart The Sound Loom)"
					append msg "\n\n                                          Exit Anyway ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						return 0
					}
				}
				append msg "\n\nCLOSE Any Files Which Are Playing : Then Press OK"
				set choice [tk_messageBox -type ok -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "ok"} {
					set retried 1
				}
			} else {
				return 0
			}
		} else {
			break
		}
	}
	return 1
}

#----- Generate a true test mix output from the score

proc ScoreTrueTestOut {scoretype endtoend} {
	global pr_sctest2 sc_clips2 pa wstk stage nuparse scoremixlist propsnds_playlist evv 

	if {$scoretype == "propslist"} {
		set filelist $propsnds_playlist
	} elseif {$scoretype == 0} {
		if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
			Inf "No Files Selected"
			return
		}
		set filelist $scoremixlist
	} else {
		set filelist [ListFromScore $scoretype 1]
		if {[llength $filelist] <= 0} {
			set i 0
			foreach obj [$stage find withtag snd] {
				incr i
				break
			}
			if {$i == 0} {
				Inf "No Score To Test"
			}
			return
		}
	}
	if {[llength $filelist] == 1} {
		Inf "Only One File Selected"
		return
	}
	set msg ""
	if {![ClearTempFiles 0 $msg]} {
		return
	}
	set f .sctest2
	if [Dlg_Create $f "MIX FILES IN SEQUENCE" "set pr_sctest2 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		frame $f.s -bd $evv(SBDR)
		button $f.b.ok -text "Run Mix" -command {set pr_sctest2 1} -width 7 -highlightbackground [option get . background {}]
		button $f.b.qu -text "Abandon" -command {set pr_sctest2 0} -width 7 -highlightbackground [option get . background {}]
		pack $f.b.ok -side left -padx 1
		pack $f.b.qu -side right -padx 1
		label $f.e.l -text "STEP BETWEEN MIX ENTRIES"
		entry $f.e.e -textvariable sc_clips2 -width 20
		pack $f.e.l $f.e.e -side left -padx 3 -anchor center
		Scrolled_Listbox $f.s.ll -width 64 -height 24 -selectmode single
		pack $f.s.ll -side top -fill both -expand true
		pack $f.b $f.e $f.s -side top -pady 3 -fill x -expand true
#		wm resizable $f 0 0
		bind .sctest2 <Control-Key-p> {UniversalPlay list .sctest2.s.ll.list}
		bind .sctest2 <Control-Key-P> {UniversalPlay list .sctest2.s.ll.list}
		bind .sctest2 <Key-space>	  {UniversalPlay list .sctest2.s.ll.list}
		bind .sctest2 <Return> {set pr_sctest2 1}
		bind .sctest2 <Escape> {set pr_sctest2 0}
	}
	$f.s.ll.list delete 0 end
	foreach fff $filelist {
		$f.s.ll.list insert end $fff
	}
	if {$endtoend} {
		$f.e.l config -text "OVERLAP OF MIXFILE ENDS"
		set mmsg "MIX OVERLAP"
	} else {
		$f.e.l config -text "STEP BETWEEN MIX ENTRIES"
		set mmsg "MIX STEP"
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_sctest2 0
	if {![info exists sc_clips2]} { 
		set sc_clips2 ""
	}
	set finished 0
	My_Grab 0 $f pr_sctest2 $f.e.e
	while {!$finished} {
		tkwait variable pr_sctest2
		if {!$pr_sctest2} {
			break
		}
		if {[string length $sc_clips2] <= 0} {
			if {$endtoend} {
				set sc_clips2 0
			} else {
				Inf "No $mmsg Time Entered"
				continue
			}
		}
		if {![IsNumeric $sc_clips2] || ($sc_clips2 < 0.0)} {
			Inf "Invalid $mmsg Time Entered"
			continue
		}
		foreach fnam $filelist {
			if {![info exists pa($fnam,$evv(FTYP))]} {
				if {[DoParse $fnam 0 0 0] <= 0} {
					set finished 1
					break
				} else {
					lappend nuparse $fnam
				}
			}
		}
		if {$finished} {
			break
		}
		set srate $pa([lindex $filelist 0],$evv(SRATE))
		catch {unset chans}
		catch {unset durs}
		foreach fnam $filelist {
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Files Are Not All Of Same Sample Rate: Cannot Do The Mix"
				set finished 1
				break
			}
			lappend chans $pa($fnam,$evv(CHANS))
			lappend durs $pa($fnam,$evv(DUR))
		}
		if {$finished} {
			break
		}
		set totlen 0.0
		set start  0.0
		set bigchan 0						;# CALC DURATION
		catch {unset starttimes}
		catch {unset endtimes}
		set cnt 0
		foreach dur $durs chan $chans {
			if {$chan > $bigchan} {
				set bigchan $chan
			}
			set endtime [expr $dur + $start]
			if {$endtime > $totlen} {
				set totlen $endtime
			}
			lappend starttimes $start
			lappend endtimes $endtime
			if {$endtoend} {
				set rrr [expr $dur - $sc_clips2]
				if {$rrr < 0.0} {
					Inf "Overlap Too Great For File [lindex $filelist $cnt]"
					set finished 1
					break
				}
				set start [expr $start + $rrr]
			} else {
				set start [expr $start + $sc_clips2]
			}
			incr cnt
		}
		if {$finished} {
			break
		}
													;# CHECK FOR SUFFICIENT DISKSPACE
		set totlen [expr round($totlen * double($bigchan) * $srate)]
		if {![CheckScoreTestDiskspace $totlen $srate]} {
			break
		}
		set start 0.0
		set overlay 0
		set n 0										;# CALC MAX OVERLAYS, TO ATTEN LEVEL
		foreach endtime $endtimes starttime $starttimes {
			set m $n
			incr m
			set cnt 0
			foreach thisstarttime [lrange $starttimes $m end] {
				if {$endtime > $thisstarttime} {
					incr cnt
				}
			}
			if {$cnt > $overlay} {
				set overlay $cnt
			}
			incr n
		}
		incr overlay
		set level [expr 1.0 / double($overlay)]
													;# CONSTRUCT APPROPRIATE BATCHFILE

		set batch [ConstructScoreBatch2 $filelist $chans $durs $sc_clips2 $level $endtoend]
		if {[llength $batch] <= 0} {
			break
		} else {
			set outfilename [lindex [lindex $batch end] end]
		}
		append outfilename $evv(SNDFILE_EXT)
		if {$endtoend} {
			set title "Running End to End Mix with overlap $sc_clips2"
		} else {
			set title "Running Test Mix with timestep $sc_clips2"
		}
		if [RunScoreTestBatchFile $batch $title] {			;# ATTEMPT TO RUN BATCHFILE

			set is_playing 0
			set msg "Score Test Mix Completed : Hear The Result ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				PlaySndfile $outfilename 0			;# PLAY OUTPUT
			}
		}
		set msg "\n   'Make Test Sequence' And Playing Files On The Sketch Score"
		append msg "\n                                     Will Not Respond"		
		if {![ClearTempFiles 1 $msg]} {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------- Construct batchfile for Score Test Mix

proc ConstructScoreBatch2 {filelist chans durs timestep level endtoend} {
	global pa evv

	set time 0.0
	foreach fnam $filelist chan $chans dur $durs {
		switch -- $chan {
			1 { set line "$fnam $time 1 $level C" }
			2 { set line "$fnam $time 2 $level" }
		}
		if {$endtoend} {
			set time [expr $time + $dur - $timestep]
		} else {
			set time [expr $time + $timestep]
		}
		lappend batch $line
	}
	set outfile0 $evv(DFLT_OUTNAME)
	append outfile0 "0" $evv(TEXT_EXT)
	if [catch {open $outfile0 w} zit] {
		Inf "Cannot Open Temporary Mixfile '$outfile0'"
		return {}
	}
	foreach line $batch {
		puts $zit $line
	}
	close $zit
	unset batch
	set outfile1 $evv(DFLT_OUTNAME)
	append outfile1 "1"
	set line "submix mix $outfile0 $outfile1"
	lappend batch $line
	return $batch	
}

#----- Generate a true test mix output of end & start of two files

proc ScoreTrueEndsTestOut {with_overlap} {
	global pr_sctest3 sc_overlap sc_pre sc_post pa wstk stage nuparse scoremixlist evv 

	if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
		Inf "No Files Selected"
		return
	}
	if {[llength $scoremixlist] != 2} {
		Inf "This Option Only Works With Two Files"
		return
	}
	set filelist $scoremixlist
	set bigchan 0
	set i 0
	foreach fnam $filelist {
		if {![info exists pa($fnam,$evv(FTYP))]} {
			if {[DoParse $fnam 0 0 0] <= 0} {
				return
			} else {
				lappend nuparse $fnam
			}
		}
		if {![info exists srate]} {
			set srate $pa([lindex $filelist 0],$evv(SRATE))
		} elseif {$pa($fnam,$evv(SRATE)) != $srate} {
			Inf "Files Are Not All Of Same Sample Rate: Cannot Do The Mix"
			return
		}
		set chan($i) $pa($fnam,$evv(CHANS))
		if {$chan($i) > $bigchan} {
			set bigchan $chan($i)
		}
		set dur($i) $pa($fnam,$evv(DUR))
		set cut($i) 1
		incr i
	}
	set msg ""
	if {![ClearTempFiles 0 $msg]} {
		return
	}
	if {$with_overlap} {
		set f .sctest3
		if [Dlg_Create $f "MAKE TEST SEQUENCE OF FILE ENDS" "set pr_sctest3 0" -width 60 -borderwidth $evv(SBDR)] {
			frame $f.b -bd $evv(SBDR)
			frame $f.e -bd $evv(SBDR)
			frame $f.f -bd $evv(SBDR)
			frame $f.g -bd $evv(SBDR)
			button $f.b.ok -text "Run Mix" -command {set pr_sctest3 1} -width 7 -highlightbackground [option get . background {}]
			button $f.b.qu -text "Abandon" -command {set pr_sctest3 0} -width 7 -highlightbackground [option get . background {}]
			pack $f.b.ok -side left -padx 1
			pack $f.b.qu -side right -padx 1
			label $f.e.l -text "FILE OVERLAP DURATION"
			entry $f.e.e -textvariable sc_overlap -width 20
			pack $f.e.l $f.e.e -side left -padx 3 -anchor center
			label $f.f.l -text "DURATION OF FILE 1 BEFORE OVERLAP"
			entry $f.f.e -textvariable sc_pre -width 20
			pack $f.f.l $f.f.e -side left -padx 3 -anchor center
			label $f.g.l -text "DURATION OF FILE 2 AFTER OVERLAP  "
			entry $f.g.e -textvariable sc_post -width 20
			pack $f.g.l $f.g.e -side left -padx 3 -anchor center
			pack $f.b $f.e $f.f $f.g -side top -pady 3 -fill x -expand true
#			wm resizable $f 0 0
			bind $f.e.e <Down> "focus $f.f.e"
			bind $f.f.e <Down> "focus $f.g.e"
			bind $f.g.e <Down> "focus $f.e.e"
			bind $f.e.e <Up> "focus $f.g.e"
			bind $f.f.e <Up> "focus $f.e.e"
			bind $f.g.e <Up> "focus $f.f.e"
			bind $f <Return> {set pr_sctest3 1}
			bind $f <Escape> {set pr_sctest3 0}
		}
		if {![info exists sc_overlap]} { 
			set sc_overlap ""
		}
		if {![info exists sc_pre]} { 
			set sc_pre ""
		}
		if {![info exists sc_post]} { 
			set sc_post ""
		}
		raise $f
		set pr_sctest3 0
		set finished 0
		My_Grab 0 $f pr_sctest3 $f.e.e
		while {!$finished} {
			tkwait variable pr_sctest3
			if {!$pr_sctest3} {
				break
			}
			if {[string length $sc_overlap] <= 0} {
				Inf "No Overlap Duration Entered"
				continue
			}
			if {![IsNumeric $sc_overlap] || ($sc_overlap < 0.0)} {
				Inf "Invalid Overlap Duration Entered"
				continue
			}
			if {[string length $sc_pre] <= 0} {
				Inf "No File 1 Duration Entered"
				continue
			}
			if {![IsPositiveNumber $sc_pre]} {
				Inf "Invalid File 1 Duration Entered"
				continue
			}
			if {[string length $sc_post] <= 0} {
				Inf "No File 2 Duration Entered"
				continue
			}
			if {![IsPositiveNumber $sc_post]} {
				Inf "Invalid File 2 Duration Entered"
				continue
			}
			set mstart(0) 0
			set mstart(1) $sc_pre
			set minlen(0) [expr $sc_pre + $sc_overlap]
			set minlen(1) [expr $sc_overlap + $sc_post]

			if {($dur(0) < $sc_overlap) && ($dur(1) < $sc_overlap)} {
				Inf "Both Files Are Too Short For This Overlap Value"
				continue
			}
			if {$dur(0) < $sc_overlap} {
				set msg "File 1 Is Too Short ($dur(0) secs) For An Overlap Of $sc_overlap secs"
				append msg "\n\nBegin The Mix With File 2 ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					set OK 0
					break
				}
				set mstart(0) [expr $sc_overlap - $dur(0)]
				set mstart(1) 0
				set minlen(0) $dur(0)
			} elseif {$dur(0) < $minlen(0)} {
				set msg "File 1 Is Too Short ($dur(0) secs) For Specified Duration + Overlap ($minlen(0) secs)"
				append msg "\n\nFile 1 Will End Before End Of Overlap"
				append msg "\n\nIs This OK ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					set mstart(1) [expr $dur(0) - $sc_overlap]
					set msg "Reduce Pre Overlap Duration TO $mstart(1) secs?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				set minlen(0) $dur(0)
				set cut(0) 0
			}
			if {$dur(1) < $sc_overlap} {
				set msg "Sound 2 Is Shorter ($dur(1) secs) Than The Overlap Of $sc_overlap secs"
				append msg "\n\nIs This OK ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set minlen(1) $dur(1)
				set cut(1) 0
			} elseif {$dur(1) < $minlen(1)} {
				set msg "Sound 2 Is Too Short ($dur(1) secs) For Specified Duration + Overlap ($minlen(1) secs)"
				append msg "\n\nThe Sound Will End After The Overlap But Before The Specified Duration"
				append msg "\n\nIs This OK ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set minlen(1) $dur(1)
				set cut(1) 0
			}
			set totlen 0.0
			set i 0
			while {$i < 2} {
				set endtime [expr $minlen(0) + $mstart(0)]
				if {$endtime > $totlen} {
					set totlen $endtime
				}
				incr i
			}
														;# CHECK FOR SUFFICIENT DISKSPACE
			set totlen [expr round($totlen * double($bigchan) * $srate)]
			if {![CheckScoreTestDiskspace $totlen $srate]} {
				break
			}
														;# CONSTRUCT APPROPRIATE BATCHFILE

			set batch [ConstructScoreBatch4 [lindex $filelist 0] [lindex $filelist 1] $chan(0) $chan(1) $mstart(0) $mstart(1) $cut(0) $cut(1) $minlen(0) $minlen(1) $dur(0) 0.5]

			if {[llength $batch] <= 0} {
				break
			} else {
				set outfilename [lindex [lindex $batch end] end]
			}
			append outfilename $evv(SNDFILE_EXT)
			set title "Running testmix with overlap $sc_overlap"
			if [RunScoreTestBatchFile $batch $title] {			;# ATTEMPT TO RUN BATCHFILE

				set is_playing 0
				set msg "Score Test Mix Completed : Hear The RESULT ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					PlaySndfile $outfilename 0			;# PLAY OUTPUT
				}
			}
			set msg "\n   'Make Test Sequence' And Playing Files On The Sketch Score"
			append msg "\n                                     Will Not Respond"		
			if {![ClearTempFiles 1 $msg]} {
				break
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	} else {
		set totlen [expr $dur(0) + $dur(1)]
		set totlen [expr round($totlen * double($bigchan) * $srate)]
		if {![CheckScoreTestDiskspace $totlen $srate]} {
			return
		}
		set batch [ConstructScoreBatch5 [lindex $filelist 0] [lindex $filelist 1] $chan(0) $chan(1) $dur(0)]

		if {[llength $batch] <= 0} {
			return
		} else {
			set outfilename [lindex [lindex $batch end] end]
		}
		append outfilename $evv(SNDFILE_EXT)
		set title "Running testmix"
		if [RunScoreTestBatchFile $batch $title] {			;# ATTEMPT TO RUN BATCHFILE
			set is_playing 0
			set msg "Score Test Mix Completed : Hear The Result ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				PlaySndfile $outfilename 0			;# PLAY OUTPUT
			}
		}
		set msg "\n   'Make Test Sequence' And Playing Files On The Sketch Score"
		append msg "\n                                     Will Not Respond"		
		ClearTempFiles 1 $msg
	}	
}

#------- Construct batchfile for Score Test Mix type 4

proc ConstructScoreBatch4 {file0 file1 chan0 chan1 mstart0 mstart1 cut0 cut1 len0 len1 dur0 level} {
	global pa evv

	set filindx 0
	if {$cut0} {
		set start [expr $dur0 - $len0]
		set endd  [expr $dur0 - $evv(FLTERR)]
		set line "sfedit cut 1 $file0 $evv(DFLT_OUTNAME)0 $start $endd"
		lappend batch $line
		set file0 $evv(DFLT_OUTNAME)0
		append file0 $evv(SNDFILE_EXT)
		incr filindx
	}
	if {$cut1} {
		set line "sfedit cut 1 $file1 $evv(DFLT_OUTNAME)$filindx 0 $len1"
		lappend batch $line
		set file1 $evv(DFLT_OUTNAME)$filindx
		append file1 $evv(SNDFILE_EXT)
		incr filindx
	}
	switch -- $chan0 {
		1 { set line "$file0 $mstart0 1 $level C" }
		2 { set line "$file0 $mstart0 2 $level" }
	}
	lappend mixbatch $line
	switch -- $chan1 {
		1 { set line "$file1 $mstart1 1 $level C" }
		2 { set line "$file1 $mstart1 2 $level" }
	}
	lappend mixbatch $line
	set outfile0 $evv(DFLT_OUTNAME)
	append outfile0 $filindx $evv(TEXT_EXT)
	if [catch {open $outfile0 w} zit] {
		Inf "Cannot Open Temporary Mixfile '$outfile0'"
		return {}
	}
	foreach line $mixbatch {
		puts $zit $line
	}
	close $zit
	incr filindx
	set outfile1 $evv(DFLT_OUTNAME)
	append outfile1 $filindx
	set line "submix mix $outfile0 $outfile1"
	lappend batch $line
	return $batch	
}

############################
# HANDLE COMMENTS ON SCORE #
############################

#--- Erase comments from the score 

proc EraseComments {all} {
	global stage commentsave backcommentsave uppanel dnpanel uppanelcnt dnpanelcnt
	if {![AreYouSure]} {
		return
	}
	if {$all} {
		set deletes_possible 1
		if {$uppanelcnt > 0} {
			set n [expr $uppanelcnt - 1] 
			while {$n >= 0} {
				set $uppanel($n) [lreplace $uppanel($n) 1 1 {}]
				if {$deletes_possible && ([llength [lindex $uppanel($n) 0]] <= 0)} {
					catch {unset uppanel($n)}				;#	DELETE EXTREMAL PANELS WITH NO DATA
					incr uppanelcnt -1
				} else {
					set deletes_possible 0
				}
				incr n -1
			}
		}
		set deletes_possible 1
		if {$dnpanelcnt > 0} {
			set n [expr $dnpanelcnt - 1] 
			while {$n >= 0} {
				set dnpanel($n) [lreplace $dnpanel($n) 1 1 {}]
				if {$deletes_possible && ([llength [lindex $dnpanel($n) 0]] <= 0)} {
					catch {unset dnpanel($n)}				;#	DELETE EXTREMAL PANELS WITH NO DATA
					incr dnpanelcnt -1
				} else {
					set deletes_possible 0
				}
				incr n -1
			}
		}
	} else {
		foreach obj [$stage find withtag comment] {
			set thiscomment [$stage itemcget $obj -text]
			lappend lastcommentsave $thiscomment
			lappend lastcommentsave [lindex [$stage coords $obj] 0]
			lappend lastcommentsave [lindex [$stage coords $obj] 1]
		}
		if {[info exists lastcommentsave]} {
			set commentsave $lastcommentsave
			set backcommentsave $lastcommentsave
		}
	}
	catch {$stage delete comment}
}

#--- Restore erased (or previous) set of comments to the score 

proc RestoreCommentsTell {} {
	global stage commentsave backcommentsave wstk evv

	if {![info exists commentsave]} {
		Inf "No Comments To Restore"
		return
	} else {
		set msg "Is The Screen Scrolled To The Correct Place To Restore Your Comments ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	foreach obj [$stage find withtag comment] {
		set thiscomment [$stage itemcget $obj -text]
		lappend lastcommentsave $thiscomment
		lappend lastcommentsave [lindex [$stage coords $obj] 0]
		lappend lastcommentsave [lindex [$stage coords $obj] 1]
	}
	catch {$stage delete comment}
	foreach {text x y} $backcommentsave {
		$stage create text $x $y -text $text -tags comment -anchor w -fill $evv(POINT)
	}
	if {[info exists lastcommentsave]} {
		set commentsave $lastcommentsave
	}
}

#--- Remove a Comment from the score

proc DeleteCommentOnScore {x y} {
	global stage commentsave lastscoredelete wstk

	foreach obj [$stage find withtag comment] {
		set thiscomment [$stage itemcget $obj -text]
		lappend lastcommentsave $thiscomment
		lappend lastcommentsave [lindex [$stage coords $obj] 0]
		lappend lastcommentsave [lindex [$stage coords $obj] 1]
	}
	set obj [$stage find closest $x $y]
	set displaylist [$stage find withtag comment]	;#	List all objects which are comments

	if {[lsearch -exact $displaylist $obj] < 0} {	;#	If the closest object is not a text
		return										;#	abandon the delete
	}
	foreach thistag [$stage itemcget $obj -tag] {
		if [string match #* $thistag] {
			set msg "This Comment Could Be Converted Back To Sound : Are You Sure You Want To Delete It ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			}
			break
		}
	}
	set commentsave $lastcommentsave
	set lastscoredelete  [$stage itemcget $obj -text]
	lappend lastscoredelete "comment"
	lappend lastscoredelete [lindex [$stage coords $obj] 0]
	lappend lastscoredelete [lindex [$stage coords $obj] 1]
	catch {$stage delete $obj}
}

#--- Mark a comment on the score, ready to drag it

proc MarkCommentOnScore {x y} {
	global stage compnt score_chwidth score_left score_right 

	set compnt(ismarked) 0														

	set compnt(obj) [$stage find closest $x $y]				;#	Find closest object
	set displaylist [$stage find withtag comment]			;#	List all objects which are comments

	if {[lsearch -exact $displaylist $compnt(obj)] < 0} {	;#	If the closest object is not a comment
		return												;#	abandon the mark
	}
	set compnt(text) [$stage itemcget $compnt(obj) -text]
	set itemwidth [GetStringSize $compnt(text)]
	incr itemwidth
	set compnt(leftlim) $score_left
	set compnt(rightlim) [expr $score_right - $itemwidth]

	set compnt(coords) [$stage coords $compnt(obj)]		 	 	
	set compnt(mx) $x							 			;# 	Save coords of mouse
	set compnt(my) $y

	set compnt(x) [expr round([lindex $compnt(coords) 0])]	;#	Remember coords of text
	set compnt(y) [expr round([lindex $compnt(coords) 1])]

	set compnt(lastx) $compnt(x)						;#	Remember new x coord
	set compnt(lasty) $compnt(y)

	set compnt(ismarked) 1								;#	Flag that a text is marked
}

#--- Drag a comment on the score

proc DragCommentOnScore {x y} {
	global stage compnt score_right score_left score_p4_bot score_p1_top 

	if {![info exists compnt(ismarked)] || !$compnt(ismarked)} {
		return
	}
	set mx $x									 	;#	Map from mouse-coords to canvas-coords
	set my $y						 	
	set dx [expr $mx - $compnt(mx)]					;#	Find distance from last marked position of mouse
	set dy [expr $my - $compnt(my)]
	incr compnt(x) $dx								;#	Get coords of dragged point

	if {$compnt(x) > $compnt(rightlim)} {			;#	Check for drag too far right, and, if ness
		set compnt(x) $compnt(rightlim)				;#	adjust coords of point
		set dx [expr $compnt(x) - $compnt(lastx)]	;#	and adjust drag-distance
	} elseif {$compnt(x) < $compnt(leftlim)} {		;#	Check for drag too far left, and, if ness
		set compnt(x) $compnt(leftlim)				;#	adjust coords of point
		set dx [expr $compnt(x) - $compnt(lastx)]	;#	and adjust drag-distance
	}
	set compnt(lastx) $compnt(x)					;#	Remember new x coord
 
	incr compnt(y) $dy									
	if {$compnt(y) > $score_p4_bot} {				;#	Check for drag too far down, and, if ness
		set compnt(y) $score_p4_bot					;#	adjust coords of point
		set dy [expr $compnt(y) - $compnt(lasty)]	;#	and adjust drag-distance
	} elseif {$compnt(y) < $score_p1_top} {
		set compnt(y) $score_p1_top					;#	adjust coords of point
		set dy [expr $compnt(y) - $compnt(lasty)]	;#	and adjust drag-distance
	}

	set compnt(lasty) $compnt(y)					;#	Remember new y coord

	$stage move $compnt(obj) $dx $dy				;#	Move object to new position
	set compnt(mx) $mx							 	;#  Store new mouse coords
	set compnt(my) $my
}

#--- Finally position a comment on the score, after dragging

proc RelocateCommentOnScore {} {
	global compnt stage

	if [info exists compnt(lasty)] {
		set y [AdjustScoreVertPos $compnt(lasty)]
		set dy [expr $y - $compnt(lasty)]
		if {$y != 0} {
			$stage move $compnt(obj) 0 $dy
		}
	}
	set compnt(ismarked) 0
}

#--- Place a comment on the score

proc PutCommentOnScore {x y} {
	global score_left score_right score_chwidth score_comment stage evv

	if {![info exists score_comment] || ([string length $score_comment] <= 0)} {
		Inf "No Comment Written"
		return
	} elseif {[string first "_" $score_comment] >= 0} {
		Inf "Use No Underscores In Comments"
		return
	}
	set insert_text [string toupper $score_comment]
	set itemwidth [expr [string length $score_comment] * $score_chwidth]
	incr itemwidth
	set leftlim  $score_left
	set rightlim [expr $score_right - $itemwidth]

	if {$x <= $leftlim} {						 
		set x $leftlim
	}
	if {$x > $rightlim} {
		set x $rightlim
	}
	set y [AdjustScoreVertPos $y]
	$stage create text $x $y -text "$insert_text" -tags comment -anchor w -fill $evv(POINT)
}

#--- Add more text to a comment on the score

proc AddToScoreComment {x y} {
	global score_left score_right score_chwidth score_comment wstk stage evv

	if {![info exists score_comment] || ([string length $score_comment] <= 0)} {
		Inf "No Text To Add"
		return
	} elseif {[string first "_" $score_comment] >= 0} {
		Inf "Use No Underscores In Comments"
		return
	}
	foreach obj [$stage find withtag comment] {
		set thiscomment [$stage itemcget $obj -text]
		lappend lastcommentsave $thiscomment
		lappend lastcommentsave [lindex [$stage coords $obj] 0]
		lappend lastcommentsave [lindex [$stage coords $obj] 1]
	}
	set obj [$stage find closest $x $y]
	set displaylist [$stage find withtag comment]	;#	List all objects which are comments

	if {[lsearch -exact $displaylist $obj] < 0} {	;#	If the closest object is not a text
		return										;#	abandon the delete
	}
	foreach thistag [$stage itemcget $obj -tag] {
		if [string match #* $thistag] {
			set msg "This Comment Could Be Converted Back To Sound : Are You Sure You Want Change It ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			}
			break
		}
	}
	set commentsave $lastcommentsave
	set old_comment [$stage itemcget $obj -text]
	set coords [$stage coords $obj]
	set x [lindex $coords 0]
	set y [lindex $coords 1]
	catch {$stage delete $obj}
	append old_comment " " $score_comment

	set insert_text [string toupper $old_comment]
	set itemwidth [expr [string length $insert_text] * $score_chwidth]
	incr itemwidth
	set leftlim  $score_left
	set rightlim [expr $score_right - $itemwidth]

	if {$x <= $leftlim} {						 
		set x $leftlim
	}
	if {$x > $rightlim} {
		set x $rightlim
	}
	set y [AdjustScoreVertPos $y]
	$stage create text $x $y -text "$insert_text" -tags comment -anchor w -fill $evv(POINT)
}

#--- Replace a comment on the score

proc ReplaceScoreComment {x y} {
	global score_left score_right score_chwidth score_comment wstk stage evv

	if {![info exists score_comment] || ([string length $score_comment] <= 0)} {
		Inf "No Comment To Use For Replacement"
		return
	} elseif {[string first "_" $score_comment] >= 0} {
		Inf "Use No Underscores In Comments"
		return
	}
	foreach obj [$stage find withtag comment] {
		set thiscomment [$stage itemcget $obj -text]
		lappend lastcommentsave $thiscomment
		lappend lastcommentsave [lindex [$stage coords $obj] 0]
		lappend lastcommentsave [lindex [$stage coords $obj] 1]
	}
	set obj [$stage find closest $x $y]
	set displaylist [$stage find withtag comment]	;#	List all objects which are comments

	if {[lsearch -exact $displaylist $obj] < 0} {	;#	If the closest object is not a text
		return										;#	abandon the delete
	}
	foreach thistag [$stage itemcget $obj -tag] {
		if [string match #* $thistag] {
			set msg "This Comment Could Be Converted Back To Sound : Are You Sure You Want Change It ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			}
			break
		}
	}
	set commentsave $lastcommentsave
	set old_comment [$stage itemcget $obj -text]
	set coords [$stage coords $obj]
	set x [lindex $coords 0]
	set y [lindex $coords 1]
	catch {$stage delete $obj}
	set insert_text [string toupper $score_comment]
	set itemwidth [expr [string length $insert_text] * $score_chwidth]
	incr itemwidth
	set leftlim  $score_left
	set rightlim [expr $score_right - $itemwidth]

	if {$x <= $leftlim} {						 
		set x $leftlim
	}
	if {$x > $rightlim} {
		set x $rightlim
	}
	set y [AdjustScoreVertPos $y]
	$stage create text $x $y -text "$insert_text" -tags comment -anchor w -fill $evv(POINT)
}

#--- Grab a score Comment to the comment text-writing box

proc GrabScoreComment {x y} {
	global score_comment stage

	set obj [$stage find closest $x $y]
	set displaylist [$stage find withtag comment]	;#	List all objects which are comments

	if {[lsearch -exact $displaylist $obj] < 0} {	;#	If the closest object is not a text
		return										;#	abandon the delete
	}
	set score_comment [$stage itemcget $obj -text]
}

#--- Toggle whether comments are dragged with Sounds or not.

proc UnattachComments {} {
	global comments_attached localcomment sl_real

	if {!$sl_real} {
		Inf "Comments Written On The Score Can Be Attached To The Nearest Soundfile-Name On The Score\n\nA Comment Close To A Sound Will Then Move Along With The Sound\nWhen The Sound Is Moved To A New Position On The Score."
		return
	}
	if {!$comments_attached} {
		catch {unset localcomment}
	}
}

#######################
# SCROLLING THE SCORE #
#######################

#---- Scroll entire score, including hidden panels

proc ScrollScore {direction} {
	global stage uppanel dnpanel scoreline1 scoreline3 sl_real

	if {!$sl_real} {
		Inf "The Score Can Have More Panels Than The 4 Seen Here.\nThe Score Cab Be Scrolled Up And Down To Reveal These Other Panels"
		return
	}
	set cnt 0
	set topcnt 0
	set botcnt 0
	foreach obj [$stage find withtag snd] {
		set y [lindex [$stage coords $obj] 1]
		if {$y < $scoreline1} {
			set topcnt 1
		} elseif {$y >= $scoreline3} {
			set botcnt 1
		}
		incr cnt
	}
	foreach obj [$stage find withtag comment] {
		set y [lindex [$stage coords $obj] 1]
		if {$y < $scoreline1} {
			set topcnt 1
		} elseif {$y >= $scoreline3} {
			set botcnt 1
		}
		incr cnt
	}
	switch -- $direction {
		"up" {
			if {($cnt == 0) && ![info exists dnpanel]} {
				return
			}
			ScrollUpPanels up $topcnt
			ScrollPanels up
			ScrollDnPanels up $botcnt
		}
		"dn" {
			if {($cnt == 0) && ![info exists uppanel]} {
				return
			}
			ScrollDnPanels dn $botcnt
			ScrollPanels dn
			ScrollUpPanels dn $topcnt
		}
	}
}

#---- Scroll panels which are off top of screen

proc ScrollUpPanels {direction topcnt} {
	global uppanel uppanelcnt

	switch -- $direction {
		"up" {
			if {$uppanelcnt > 0} {
				set n $uppanelcnt
				set m $n
				incr m -1
				while {$n > 0} {
					set uppanel($n) $uppanel($m)
					incr m -1
					incr n -1
				}
				catch {unset uppanel(0)}
				TopPanelToUpPanel
				incr uppanelcnt
			} elseif {$topcnt > 0} {
				TopPanelToUpPanel
				incr uppanelcnt
			}
		}
		"dn" {
			if {$uppanelcnt > 0} {
				UpPanelToTopPanel
				incr uppanelcnt -1
				set n 0
				set m 1
				while {$n < $uppanelcnt} {
					set uppanel($n) $uppanel($m)
					incr m
					incr n
				}
				unset uppanel($uppanelcnt)
				if {$uppanelcnt == 0} {
					unset uppanel
				}
			}
		}
	}
}

proc ScrollDnPanels {direction botcnt} {
	global dnpanel dnpanelcnt

	switch -- $direction {
		"dn" {
			if {$dnpanelcnt > 0} {
				set lo $dnpanelcnt
				set hi $lo
				incr hi -1
				while {$lo > 0} {
					set dnpanel($lo) $dnpanel($hi)
					incr lo -1
					incr hi -1
				}
				catch {unset dnpanel(0)}
				BotPanelToDnPanel
				incr dnpanelcnt
			} elseif {$botcnt > 0} {
				BotPanelToDnPanel
				incr dnpanelcnt
			}
		}
		"up" {
			if {$dnpanelcnt > 0} {
				DnPanelToBotPanel
				set hi 0
				set lo 1
				while {$lo < $dnpanelcnt} {
					set dnpanel($hi) $dnpanel($lo)
					incr hi 1
					incr lo 1
				}
				incr dnpanelcnt -1
				unset dnpanel($dnpanelcnt)
				if {$dnpanelcnt == 0} {
					unset dnpanel
				}
			}
		}
	}
}

proc TopPanelToUpPanel {} {
	global stage scoreline1 uppanel

	foreach obj [$stage find withtag snd] {
		set y [lindex [$stage coords $obj] 1]
		if {$y < $scoreline1} {
			lappend thisscoresave [$stage itemcget $obj -text]
			lappend thisscoresave [lindex [$stage coords $obj] 0]
			lappend thisscoresave [lindex [$stage coords $obj] 1]
		}
	}
	if {[info exists thisscoresave]} {
		lappend uppanel(0) $thisscoresave 
	} else {
		lappend uppanel(0) {}
	}
	foreach obj [$stage find withtag comment] {
		set y [lindex [$stage coords $obj] 1]
		if {$y < $scoreline1} {
			set thiscomment [$stage itemcget $obj -text]
			lappend thisscommentsave $thiscomment
			lappend thisscommentsave [lindex [$stage coords $obj] 0]
			lappend thisscommentsave [lindex [$stage coords $obj] 1]
		}
	}
	if {[info exists thisscommentsave]} {
		lappend uppanel(0) $thisscommentsave 
	} else {
		lappend uppanel(0) {}
	}
}

proc BotPanelToDnPanel {} {
	global stage scoreline3 dnpanel

	foreach obj [$stage find withtag snd] {
		set y [lindex [$stage coords $obj] 1]
		if {$y > $scoreline3} {
			lappend thisscoresave [$stage itemcget $obj -text]
			lappend thisscoresave [lindex [$stage coords $obj] 0]
			lappend thisscoresave [lindex [$stage coords $obj] 1]
		}
	}
	if {[info exists thisscoresave]} {
		lappend dnpanel(0) $thisscoresave 
	} else {
		lappend dnpanel(0) {}
	}
	foreach obj [$stage find withtag comment] {
		set y [lindex [$stage coords $obj] 1]
		if {$y > $scoreline3} {
			set thiscomment [$stage itemcget $obj -text]
			lappend thisscommentsave $thiscomment
			lappend thisscommentsave [lindex [$stage coords $obj] 0]
			lappend thisscommentsave [lindex [$stage coords $obj] 1]
		}
	}
	if {[info exists thisscommentsave]} {
		lappend dnpanel(0) $thisscommentsave 
	} else {
		lappend dnpanel(0) {}
	}
}

proc DnPanelToBotPanel {} {
	global stage dnpanel evv

	if {![info exists dnpanel]} {
		Inf "No Lower Panels Exists"
		return
	}
	ClearPanel 4
	set lastscoresave	[lindex $dnpanel(0) 0]
	set lastcommentsave [lindex $dnpanel(0) 1]
		 
	if {[llength $lastscoresave] > 0} {
		foreach {text x y} $lastscoresave {
			$stage create text $x $y -text $text -tags snd -anchor w -fill $evv(POINT)
		}
	}
	if {[llength $lastcommentsave] > 0} {
		foreach {text x y} $lastcommentsave {
			$stage create text $x $y -text $text -tags comment -anchor w -fill $evv(POINT)
		}
	}
}

proc UpPanelToTopPanel {} {
	global stage uppanel evv

	if {![info exists uppanel]} {
		Inf "No Higher Panels Exist"
		return
	}
	ClearPanel 1
	set lastscoresave	[lindex $uppanel(0) 0]
	set lastcommentsave [lindex $uppanel(0) 1]
		 
	if {[llength $lastscoresave] > 0} {
		foreach {text x y} $lastscoresave {
			$stage create text $x $y -text $text -tags snd -anchor w -fill $evv(POINT)
		}
	}
	if {[llength $lastcommentsave] > 0} {
		foreach {text x y} $lastcommentsave {
			$stage create text $x $y -text $text -tags comment -anchor w -fill $evv(POINT)
		}
	}
}

proc ClearPanel {panelno} {
	global stage

	foreach obj [$stage find withtag snd] {
		DeletePanelObj $panelno $obj
	}
	foreach obj [$stage find withtag comment] {
		DeletePanelObj $panelno $obj
	}
}

proc ScrollPanels {direction} {
	global stage scoreline1
	set dy $scoreline1
	switch -- $direction {
		"up" {
			ClearPanel 1
			set dy [expr -($dy)]
		}
		"dn" {
			ClearPanel 4
		}
	}
	foreach obj [$stage find withtag snd] {
		$stage move $obj 0 $dy
	}
	foreach obj [$stage find withtag comment] {
		$stage move $obj 0 $dy
	}
}

proc DeletePanelObj {panelno obj} {
	global stage scoreline1 scoreline2 scoreline3

	set y [lindex [$stage coords $obj] 1]
	switch -- $panelno {
		1 {
			if {$y < $scoreline1} {
				$stage delete $obj
			}
		}
		2 {
			if {($y < $scoreline2) && ($y >= $scoreline1)} {
				$stage delete $obj
			}
		}
		3 {
			if {($y < $scoreline3) && ($y >= $scoreline2)} {
				$stage delete $obj
			}
		}
		4 {
			if {$y >= $scoreline3} {
				$stage delete $obj
			}
		}
	}
}

################################
# MOVING GROUPS OF SCORE ITEMS #
################################

proc GetScoreItemToDragList {x y} {
	global stage draglist dragminx dragmaxx dragminy dragmaxy

	set obj [$stage find closest $x $y]
	if {![string match [lindex [$stage itemcget $obj -tag] 0] "snd"] && ![string match [lindex [$stage itemcget $obj -tag] 0] "comment"]} {
		return
	}
	if {![info exists draglist] || ([llength $draglist] <= 0)} {
		set dragminx [lindex [$stage coords $obj] 0]
		set dragmaxx [expr $dragminx + [GetStringSize [$stage itemcget $obj -text]]]
		set dragminy [lindex [$stage coords $obj] 1]
		set dragmaxy $dragminy
		lappend draglist $obj
	} else {
		set k [lsearch -exact $draglist $obj]
		if {$k >= 0} {
			Inf "This Item Has Already Been Selected"
			return
		}
		lappend draglist $obj
		set minx [lindex [$stage coords $obj] 0]
		set maxx [expr $minx + [GetStringSize [$stage itemcget $obj -text]]]
		set y [lindex [$stage coords $obj] 1]
		if {$minx < $dragminx } {
			set dragminx $minx
		}
		if {$maxx > $dragmaxx } {
			set dragmaxx $maxx
		}
		if {$y < $dragminy } {
			set dragminy $y
		} elseif {$y > $dragmaxy } {
			set dragmaxy $y
		}
	}
	Inf "Got Item"
}

proc RestoreGroupPosition {} {
	global stage draglist dragdx dragdy
	if {![info exists draglist]} {
		Inf "No Grouping Of Files (Still) Exists"
		return
	}
	foreach obj $draglist {
		$stage move $obj [expr -$dragdx] [expr -$dragdy]
	}
	set dragdx [expr -$dragdx]
	set dragdy [expr -$dragdy]
}

#---- When Drag finished with, check position quantisation on score

proc ConfirmDragPosition {} {
	global stage draglist dragdx dragdy
	if {[info exists draglist] && [info exists dragdx]  && [info exists dragdy]} {
		foreach obj $draglist {
			set y [lindex [$stage coords $obj] 1]
			set yy [AdjustScoreVertPos $y]
			set dy [expr $yy - $y]
			if {$dy != 0} {
				$stage move $obj 0 $dy
			}
		}
	}
}

#--- Mark a soundfile on the score, ready to drag it

proc MarkGroupOnScore {x y} {
	global group stage draglist score_left score_right

	if {![info exists draglist]} {
		Inf "No Group Of Files Has Been Selected"
		return
	}

	set obj [$stage find closest $x $y]				;#	Find closest object

	set tags [$stage itemcget $obj -tag]
	set k1 [lsearch $tags "snd"]
	set k2 [lsearch $tags "comment"]
	if {($k1 >= 0) || ($k2 >= 0)} {
		set group(obj) $obj
	}
	set group(coords) [$stage coords $group(obj)]		 	 	

	set itemwidth [GetStringSize [$stage itemcget $group(obj) -text]]
	incr itemwidth
	set group(leftlim)  $score_left
	set group(rightlim) [expr $score_right - $itemwidth]

	set group(mx) $x							 			;# 	Save coords of mouse
	set group(my) $y

	set group(x) [expr round([lindex $group(coords) 0])]	;#	Remember coords of text
	set group(y) [expr round([lindex $group(coords) 1])]
	set group(lastx) $group(x)								;#	Remember new x coord
	set group(lasty) $group(y)

	set group(ismarked) 1									;#	Flag that a text is marked
}

#--- Drag a group on the score

proc DragGroupOnScore {x y} {
	global stage group score_right score_left score_p4_bot score_p1_top 

	bind $stage <ButtonRelease-1> {}
	bind $stage <ButtonRelease-1> {RelocateGroupOnScore}

	if {![info exists group(ismarked)] || !$group(ismarked)} {
		return
	}
	set mx $x									 		;#	Map from mouse-coords to canvas-coords
	set my $y						 	
	set dx [expr $mx - $group(mx)]						;#	Find distance from last marked position of mouse
	set dy [expr $my - $group(my)]
	incr group(x) $dx									;#	Get coords of dragged point

	if {$group(x) > $group(rightlim)} {				;#	Check for drag too far right, and, if ness
		set group(x) $group(rightlim)				;#	adjust coords of point
		set dx [expr $group(x) - $group(lastx)]		;#	and adjust drag-distance
	} elseif {$group(x) < $group(leftlim)} {		;#	Check for drag too far left, and, if ness
		set group(x) $group(leftlim)				;#	adjust coords of point
		set dx [expr $group(x) - $group(lastx)]		;#	and adjust drag-distance
	}
	set group(lastx) $group(x)						;#	Remember new x coord
 
	incr group(y) $dy									
	if {$group(y) > $score_p4_bot} {				;#	Check for drag too far down, and, if ness
		set group(y) $score_p4_bot					;#	adjust coords of point
		set dy [expr $group(y) - $group(lasty)]		;#	and adjust drag-distance
	} elseif {$group(y) < $score_p1_top} {
		set group(y) $score_p1_top					;#	adjust coords of point
		set dy [expr $group(y) - $group(lasty)]		;#	and adjust drag-distance
	}

	set group(lasty) $group(y)						;#	Remember new y coord

	$stage move $group(obj) $dx $dy				 	;#	Move object to new position
	set group(mx) $mx							 	;#  Store new mouse coords
	set group(my) $my
}

#--- Finally position a soundfile on the score, after dragging

proc RelocateGroupOnScore {} {
	global group stage dragdx dragdy
	global score_left score_right score_p1_top score_p4_bot draglist
	global dragminx dragmaxx dragminy dragmaxy

	if {![info exists draglist]} {
		return
	}

	bind $stage <ButtonRelease-1> {}
	bind $stage <ButtonRelease-1> {GetScoreItemToDragList %x %y}

	if [info exists group(lasty)] {
		set y [AdjustScoreVertPos $group(lasty)]
		set dy [expr $y - $group(lasty)]
		if {$dy != 0} {
			$stage move $group(obj) 0 $dy
			set group(lasty) [expr $group(lasty) + $dy]
		}
	}
	set dragdx [expr $group(lastx) - [lindex $group(coords) 0]]
	set dragdy [expr $group(lasty) - [lindex $group(coords) 1]]

	if {([expr $dragminx + $dragdx] < $score_left) \
	||  ([expr $dragmaxx + $dragdx] > $score_right) \
	||  ([expr $dragminy + $dragdy] < $score_p1_top) \
	||  ([expr $dragmaxy + $dragdy] > $score_p4_bot)} {
		Inf "Group Dragged Off Page!!"
		$stage move $group(obj) [expr -$dragdx] [expr -$dragdy]
		return
	} else {
		foreach obj $draglist {
			if {$obj != $group(obj)} {
				$stage move $obj $dragdx $dragdy
			}
		}
	}
	set group(ismarked) 0
}

#---- Clear selection of Group-for-dragging-on-score

proc ClearDraglist {} {
	global draglist dragdx dragdy
	ConfirmDragPosition
	catch {unset draglist}
	catch {unset dragdx}
	catch {unset dragdy}
}

##########################
# NAMED SCORE OPERATIONS #
##########################

#---- Destroy file associated with named score (or not)

proc PossiblyDestroyNamedScore {wipe_only} {
	global current_scorename scorenameslist scorenamesave wstk evv
	set msg "Do You Wish To Destroy Score '$current_scorename' Completely ?"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "yes"} {
		set fnam [file join $evv(URES_DIR) $evv(SKETCH)_$current_scorename$evv(CDP_EXT)]
		if [catch {file delete $fnam} zit] {
			Inf "Cannot Delete The File '$fnam' : You Must Close The File And Delete It Outside The Sound Loom"
		} else {
			if [info exists scorenameslist] {
				set k [lsearch $scorenameslist $current_scorename]
				if {$k >= 0} {
					set scorenameslist [lreplace $scorenameslist $k $k]
					if {[llength $scorenameslist] <= 0} {
						unset scorenameslist
					}
				}
			}
			catch {unset scorenamesave}
			set msg "Score '$current_scorename' Has Been Destroyed"
			if {$wipe_only} {
				append msg "\n\nYou Can Restore The Display, As The Default,\n\nBut It Is No Longer Linked With A Named Score"
			}
			Inf $msg
			set current_scorename ""
			RenameScoreDisplay
		}
	}
}

#---- Get data of a NAMED score

proc LoadNamedScore {prior_score_exists do_wait} {
	global current_scorename newscorename scorenameslist pr_loadscore wstk evv

	if {![info exists scorenameslist]} {
		Inf "You Do Not Have Any Named Scores To Load\n\nUse 'Erase Score Display' To Clear The Display"
		return 0
	}
	if {$prior_score_exists} {
		RememberLastScoreState
		DoSaveScore
		if {[llength $current_scorename] > 0} {
			set msg "Do You Wish To Save The Current State Of Score '$current_scorename' ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				if {[BakupScore $current_scorename] <= 0} {
					set msg "Failed To Save The Current State Of The Score '$current_scorename'\n\nDo You Still Want To Load A New Score ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						RestoreLastScoreState
						return 0
					}
				}
			} else {
				PossiblyDestroyNamedScore 0
			}
		} else {
			set msg "Do You Wish To Keep The Current Score Data ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				GetScoreName
				if {[llength $newscorename] > 0} {
					if {[BakupScore $newscorename] > 0} {
						lappend scorenameslist $newscorename				
					}
				}
			}
		}
	}
	set f .loadscore

	if [Dlg_Create $f "LOAD A NAMED SCORE" "set pr_loadscore 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		label $f.b.ok -text "CLICK ON SCORE NAME TO LOAD IT"
		button $f.b.qu -text "Close" -command {set pr_loadscore 0} -width 9 -highlightbackground [option get . background {}]
		pack $f.b.ok -side left -padx 1
		pack $f.b.qu -side right -padx 1
		label $f.e.title -text "NAMED SCORES"
		Scrolled_Listbox $f.e.ll -width 64 -height 24 -selectmode single
		pack $f.e.title $f.e.ll -side top -pady 3
		pack $f.b $f.e -side top -pady 3 -fill both -expand true
#		wm resizable $f 0 0
		bind $f.e.ll.list <ButtonRelease-1> {set pr_loadscore 1}
		bind $f <Escape> {set pr_loadscore 0}
	}
	$f.e.ll.list delete 0 end
	foreach name $scorenameslist {
		$f.e.ll.list insert end $name
	}
	set pr_loadscore 0
	set finished 0
	if {$do_wait}  {
		tkwait visibility .score
	}
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_loadscore $f.e.ll.list
	while {!$finished} {
		tkwait variable pr_loadscore
		if {!$pr_loadscore} {
			set returnval 0
			RestoreLastScoreState
			break
		}
		set i [$f.e.ll.list curselection]
		if {![info exists i] || ($i < 0)} {
			Inf "No Score Selected"
			continue
		}
		RememberLastScoreState2
		if {![GetScore [$f.e.ll.list get $i]]} {
			continue
		}
		DoCleanScore
		DisplayNewScore
		RestoreLastScoreState2
		set returnval 1
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $returnval
}

#---- Display a different score (i.e. clear display, and purge variables first)

proc DisplayNewScore {} {
	global stage uppanel dnpanel scoremixlist localcomment uppanelcnt dnpanelcnt evv
	global in_unattached_mode comments_attached score_comment
	global scoresave commentsave upsave dnsave
	global draglist dragdx dragdy

	ParsePurge					;# DESTROY ALL DATA RELATING TO CURRENT SCORE
	catch {$stage delete snd}
	catch {$stage delete comment}
	catch {unset uppanel}
	catch {unset dnpanel}
	catch {unset scoremixlist}
	catch {unset localcomment}
	catch {unset draglist}
	catch {unset dragdx}
	catch {unset dragdy}
	catch {unset nuparse}
	set uppanelcnt 0 
	set dnpanelcnt 0 
	set in_unattached_mode 0 
	set comments_attached 0
	set score_comment ""
	ScoreToPlayMode
								;# LOAD SCOREDATA ONTO SCORE
	set viewable 0
	set hidden 0

	if [info exists scoresave] {
		foreach {text x y} $scoresave {
			$stage create text $x $y -text $text -tags snd -anchor w -fill $evv(POINT)
		}
		set viewable 1
	} 

	if [info exists commentsave] {
		foreach {text x y} $commentsave {
			$stage create text $x $y -text $text -tags comment -anchor w -fill $evv(POINT)
		}
		set viewable 1
	}

	if [info exists upsave] {
		foreach nam [array names upsave] {
			set uppanel($nam) $upsave($nam)
			incr uppanelcnt
		}
		set hidden 1
	}

	if [info exists dnsave] {
		foreach nam [array names dnsave] {
			set dnpanel($nam) $dnsave($nam)
			incr dnpanelcnt
		}
		set hidden 1
	}

	catch {unset scoresave}
	catch {unset commentsave}
	catch {unset upsave}
	catch {unset dnsave}

	if {(!$viewable) && $hidden} {
		Inf "There Are Hidden Panels: Try Scrolling The Screen"
	}
	RenameScoreDisplay
}

#---- Load the names of any NAMED scores in files

proc LoadScoreNamesList {} {
	global scorenameslist evv
	catch {unset scorenameslist}
	foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(URES_DIR) $evv(SKETCH)_*]]] {
		lappend nameslist  [file rootname [file tail $fnam]]
	}
	if {![info exists nameslist]} {
		return
	}
	set len [string length $evv(SKETCH)]
	incr len
	foreach name $nameslist {
		set name [string range $name $len end]
		lappend scorenameslist $name
	}
}

#--- Get Name for a Score

proc GetScoreName {} {
	global current_scorename scorenameslist pr_getscorename newscorename wstk evv

	set f .getscorename

	if [Dlg_Create $f "PROVIDE NAME FOR SCORE" "set pr_getscorename 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.ee -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		button $f.b.ok -text "Use Name" -command {set pr_getscorename 1} -width 9 -highlightbackground [option get . background {}]
		button $f.b.qu -text "Abandon" -command {set pr_getscorename 0} -width 9 -highlightbackground [option get . background {}]
		pack $f.b.ok -side left -padx 1
		pack $f.b.qu -side right -padx 1
		label $f.ee.lab -text "New Score Name  "
		entry $f.ee.e -textvariable newscorename -width 20
		pack $f.ee.lab $f.ee.e -side left -anchor center
		label $f.e.title -text "EXISTING SCORE NAMES"
		Scrolled_Listbox $f.e.ll -width 64 -height 24 -selectmode single
		pack $f.e.title $f.e.ll -side top -pady 3
		pack $f.b $f.ee $f.e -side top -pady 3 -fill both -expand true
#		wm resizable $f 0 0
		bind $f.e.ll.list <ButtonRelease-1> {GetNewScoreName %y}
		bind $f <Return> {set pr_getscorename 1}
		bind $f <Escape> {set pr_getscorename 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set newscorename ""
	$f.e.ll.list delete 0 end
	if [info exists scorenameslist] {
		foreach name $scorenameslist {
			$f.e.ll.list insert end $name
		}
	}
	set pr_getscorename 0
	set finished 0
	My_Grab 0 $f pr_getscorename $f.e.ll.list
	while {!$finished} {
		tkwait variable pr_getscorename
		if {!$pr_getscorename} {
			set newscorename ""
			break
		}
		if {[string length $newscorename] <= 0} {
			Inf "No Score Name Entered"
			continue
		} elseif {[regexp {[^A-Za-z0-9\-\_]+} $newscorename]} {
			Inf "Invalid Characters Used In Score Name (Letters, Numbers, Underscore and Hyphen only)"
			continue
		} elseif {[string length $newscorename] > $evv(SCORENAMELEN)} {
			Inf "This Name Is Too Large To Fit On The Display!!"
			continue
		}
		set newscorename [string tolower $newscorename]
		if [string match $current_scorename $newscorename] {
			Inf "The Score Is Already Called '$current_scorename'"
			continue
		}
		if [info exists scorenameslist] {
			set i 0
			foreach nnam $scorenameslist {
				if [string match $nnam $newscorename] {
					set msg "The Score '$nnam' Already Exists : Do You Wish To Overwrite It?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set fnam [file join $evv(URES_DIR) $evv(SKETCH)_$nnam$evv(CDP_EXT)]
						if [catch {file delete $fnam} zit] {
							Inf "cannot Overwrite The Existing Score '$nnam' In File '$fnam'"
							set newscorename ""
						} else {
							set scorenameslist [lreplace $scorenameslist $i $i]
							$f.e.ll.list delete $i
						} 
					} else {
						set newscorename ""
					}
					break
				}
				incr i
			}
		}
		if {[string length $newscorename] > 0} {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Destroy a named score (file)

proc DestroyNamedScore {} {
	global scorenameslist current_scorename pr_scoredestroy delscorename wstk evv

	if {![info exists scorenameslist]} {
		Inf "You Do Not Have Any Named Scores To Destroy"
		return
	}
	set f .scoredestroy

	if [Dlg_Create $f "DESTROY A NAMED SCORE" "set pr_scoredestroy 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.ee -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		button $f.b.ok -text "Destroy" -command {set pr_scoredestroy 1} -width 9 -highlightbackground [option get . background {}]
		button $f.b.qu -text "Close" -command {set pr_scoredestroy 0} -width 9 -highlightbackground [option get . background {}]
		pack $f.b.ok -side left -padx 1
		pack $f.b.qu -side right -padx 1
		label $f.ee.lab -text "Score Name"
		entry $f.ee.e -textvariable delscorename -width 20 -state disabled
		pack $f.ee.lab $f.ee.e -side left -anchor center
		label $f.e.title -text "SCORE NAMES"
		Scrolled_Listbox $f.e.ll -width 64 -height 24 -selectmode single
		pack $f.e.title $f.e.ll -side top -pady 3
		pack $f.b $f.ee $f.e -side top -pady 3 -fill both -expand true
#		wm resizable $f 0 0
		bind $f.e.ll.list <ButtonRelease-1> {GetDestroyScoreName %y}
		bind $f <Return> {set pr_scoredestroy 1}
		bind $f <Escape> {set pr_scoredestroy 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set delscorename ""
	$f.e.ll.list delete 0 end
	foreach name $scorenameslist {
		$f.e.ll.list insert end $name
	}
	set pr_scoredestroy 0
	set finished 0
	My_Grab 0 $f pr_scoredestroy $f.e.ll.list
	while {!$finished} {
		tkwait variable pr_scoredestroy
		if {!$pr_scoredestroy} {
			break
		}
		if {[string length $delscorename] <= 0} {
			Inf "No Score Name Chosen"
		}
		set msg "Are You Sure You Want To Destroy Score '$delscorename' ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set fnam [file join $evv(URES_DIR) $evv(SKETCH)_$delscorename$evv(CDP_EXT)]
			if [catch {file delete $fnam} zit] {
				Inf "Cannot Destroy The Score '$nnam' In File '$delscorename'\n\nYou Must Close And Delete The File, Outside The Sound Loom"
			} else {
				set k [lsearch $scorenameslist $delscorename]
				if {$k >= 0} {
					set scorenameslist [lreplace $scorenameslist $k $k]
					if {[llength $scorenameslist] <= 0} {
						unset scorenameslist
						break
					}
					$f.e.ll.list delete $k
				}
				if {[string match $delscorename $current_scorename]} {
					set current_scorename ""
					RenameScoreDisplay
				}
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Select the name of the score to destroy, and display it 

proc GetDestroyScoreName {y} {
	global delscorename
	set i [.scoredestroy.e.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	.scoredestroy.ee.e config -state normal
	set delscorename [.scoredestroy.e.ll.list get $i]
	.scoredestroy.ee.e config -state disabled
}

#------ Select the new name of the score and display it 

proc GetNewScoreName {y} {
	global newscorename
	set i [.getscorename.e.ll.list curselection]
	if {![info exists i] || ($i < 0)} {
		return
	}
	set newscorename [.getscorename.e.ll.list get $i]
}

#------ Save  score display with a Name

proc SaveScoreWithNewName {} {
	global current_scorename newscorename wstk scorenameslist evv

	if {[string length $current_scorename] > 0}  {
		set msg "Do You Also Want To Retain The Score '$current_scorename' Which You Originally Loaded ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			set name_to_remove $current_scorename
		}
	}
	GetScoreName
	if {[llength $newscorename] > 0} {
		RememberLastScoreState
		DoSaveScore
		set test [BakupScore $newscorename]
		if {$test > 0} {
			if [info exists name_to_remove] {
				set fnam [file join $evv(URES_DIR) $evv(SKETCH)_$name_to_remove$evv(CDP_EXT)]
				if [catch {file delete $fnam} zit] {
					Inf "Cannot Destroy The Score '$nnam' In File '$name_to_remove'\n\nYou Must Close And Delete The File, Outside The Sound Loom"
				} elseif [info exists scorenameslist] {
					set k [lsearch $scorenameslist $name_to_remove]
					if {$k >= 0} {
						set scorenameslist [lreplace $scorenameslist $k $k]
						if {[llength $scorenameslist] <= 0} {
							unset scorenameslist
						}
					}
				}
			}
			set current_scorename $newscorename
			lappend scorenameslist $current_scorename
		} elseif {$test == 0} {
			set no_action 1
		}
	} else {
		set no_action 1
	} 
	if [info exists no_action] {
		RestoreLastScoreState
		if [info exists name_to_remove] {
			Inf "The Score '$name_to_remove' Has Not Been Destroyed"
		}
	} else {
		RenameScoreDisplay
	}
	return
}

#------ Save  score display with a Name

proc SaveAlreadyNamedScore {} {
	global current_scorename newscorename wstk scorenameslist evv

	if {[string length $current_scorename] <= 0} {
		Inf "The Current Score Display Is Not A Named Score"
		return
	}
	RememberLastScoreState
	DoSaveScore
	BakupScore $current_scorename
	RestoreLastScoreState
}

#---- Post name of score on Score Display

proc RenameScoreDisplay {} {
	global current_scorename score
	$score.btns.name config -text [string toupper $current_scorename]
	$score.btns.nbk.saver config -text "Rename"
}

#--- Display no longer saves to Named score

proc UnlinkScore {} {
	global scorenamesave current_scorename wstk
	if {[llength $current_scorename] <= 0} {
		Inf "The Current Display Is Not Linked To A Named Score"
		return
	}
	DoSaveScore
	set msg "Do You Need To Save The Current State Of Score '$current_scorename' ?"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "yes"} {
		if {[BakupScore $current_scorename] <= 0} {
			set msg "Failed To Save The Current State Of The Score '$current_scorename'"
			set choice [tk_messageBox -type ok -icon warning -parent [lindex $wstk end] -message $msg]
		}
	}
	set current_scorename ""
	RenameScoreDisplay
}

##################################
# REMEMBER & RESTORE SCORE STATE #
##################################

#--- Remember Score State on save or new load

proc RememberLastScoreState {} {
	global sub_scoresave sub_commentsave sub_upsave sub_dnsave stage uppanel upsave dnpanel
	global scoresave commentsave upsave dnsave scorenamesave sub_scorenamesave

	catch {unset sub_scoresave}
	catch {unset sub_commentsave}
	catch {unset sub_upsave}
	catch {unset sub_dnsave}
	catch {unset sub_scorename}

	if [info exists scoresave] {
		set sub_scoresave $scoresave 
	}
	if [info exists commentsave] {
		set sub_commentsave $commentsave 
	}
	if [info exists upsave] {
		foreach nam [array names upsave] {
			set sub_upsave($nam) $upsave($nam)
		}
	}
	if [info exists dnsave] {
		foreach nam [array names dnsave] {
			set sub_dnsave($nam) $dnsave($nam)
		}
	}
	if [info exists scorenamesave] {
		set sub_scorenamesave $scorenamesave
	}
}

#--- Remember Score State on save or new load

proc RememberLastScoreState2 {} {
	global sub_scoresave2 sub_commentsave2 sub_upsave2 sub_dnsave2 stage uppanel upsave dnpanel
	global scoresave commentsave upsave dnsave sub_scorenamesave2 scorenamesave

	catch {unset sub_scoresave2}
	catch {unset sub_commentsave2}
	catch {unset sub_upsave2}
	catch {unset sub_dnsave2}

	if [info exists scoresave] {
		set sub_scoresave2 $scoresave 
	}
	if [info exists commentsave] {
		set sub_commentsave2 $commentsave 
	}
	if [info exists upsave] {
		foreach nam [array names upsave] {
			set sub_upsave2($nam) $upsave($nam)
		}
	}
	if [info exists dnsave] {
		foreach nam [array names dnsave] {
			set sub_dnsave2($nam) $dnsave($nam)
		}
	}
	if [info exists scorenamesave] {
		set sub_scorenamesave2 $scorenamesave
	}
}

#--- Restore Score State on save or new load

proc RestoreLastScoreState {} {
	global sub_scoresave sub_commentsave sub_upsave sub_dnsave
	global scoresave commentsave upsave dnsave scorenamesave sub_scorenamesave

	if [info exists sub_scoresave] {
		set scoresave $sub_scoresave 
	}
	if [info exists sub_commentsave] {
		set commentsave $sub_commentsave 
	}
	if [info exists sub_upsave] {
		foreach nam [array names sub_upsave] {
			set upsave($nam) $sub_upsave($nam)
		}
	}
	if [info exists sub_dnsave] {
		foreach nam [array names sub_dnsave] {
			set dnsave($nam) $sub_dnsave($nam)
		}
	}
	if [info exists sub_scorenamesave] {
		set scorenamesave $sub_scorenamesave
	}
}

#--- Restore Score State on save or new load

proc RestoreLastScoreState2 {} {
	global sub_scoresave2 sub_commentsave2 sub_upsave2 sub_dnsave2
	global scoresave commentsave upsave dnsave scorenamesave sub_scorenamesave2

	if [info exists sub_scoresave2] {
		set scoresave $sub_scoresave2
	}
	if [info exists sub_commentsave2] {
		set commentsave $sub_commentsave2
	}
	if [info exists sub_upsave2] {
		foreach nam [array names sub_upsave2] {
			set upsave($nam) $sub_upsave2($nam)
		}
	}
	if [info exists sub_dnsave2] {
		foreach nam [array names sub_dnsave2] {
			set dnsave($nam) $sub_dnsave2($nam)
		}
	}
	if [info exists sub_scorenamesave2] {
		set scorenamesave $sub_scorenamesave2
	}
}

#--- Save current state of score, and wipe it

proc DoSaveAndWipe {} {
	DoSaveScore
	DoCleanScore
}

#--- Save current state of score (into variables used for backing up score)

proc DoSaveScore {} {
	global stage scoresave commentsave upsave dnsave uppanel dnpanel uppanelcnt dnpanelcnt
	global current_scorename scorenamesave

	catch {unset scoresave}		;# CLEAR EXISTING SAVED DATA
	catch {unset commentsave}
	catch {unset upsave}
	catch {unset dnsave}
	foreach obj [$stage find withtag snd] {
		lappend lastscoresave [$stage itemcget $obj -text]
		lappend lastscoresave [lindex [$stage coords $obj] 0]
		lappend lastscoresave [lindex [$stage coords $obj] 1]
	}
	if {[info exists lastscoresave]} {
		set scoresave $lastscoresave
	}
	foreach obj [$stage find withtag comment] {
		set thiscomment [$stage itemcget $obj -text]
		lappend lastcommentsave $thiscomment
		lappend lastcommentsave [lindex [$stage coords $obj] 0]
		lappend lastcommentsave [lindex [$stage coords $obj] 1]
	}
	if {[info exists lastcommentsave]} {
		set commentsave $lastcommentsave
	}
	if [info exists uppanel] {
		foreach nam [array names uppanel] {
			set upsave($nam) $uppanel($nam)
		}
	}
	if [info exists dnpanel] {
		foreach nam [array names dnpanel] {
			set dnsave($nam) $dnpanel($nam)
		}
	}
	if [info exists current_scorename] {
		set scorenamesave $current_scorename
	}
}

#--- Clean Score

proc DoCleanScore {} {
	global stage uppanel dnpanel uppanelcnt dnpanelcnt
	catch {$stage delete snd}
	catch {$stage delete comment}
	catch {unset uppanel}
	catch {unset dnpanel}
	set uppanelcnt 0
	set dnpanelcnt 0
}

############################
# SOUND/COMMENT CONVERSION #
############################

proc ConvertBetweenSoundAndComment {x y} {
	global stage evv
	set obj [$stage find closest $x $y]						
	set k [lsearch [$stage itemcget $obj -tag] "snd"]			;# SND TO COMMENT
	if {$k >= 0} {
		set sndfile [$stage itemcget $obj -text]
		set sndname [string toupper [file rootname [file tail $sndfile]]]
		set memory "#"
		append memory $sndfile
		set coords [$stage coords $obj]
		set x [lindex $coords 0]
		set y [lindex $coords 1]
		$stage delete $obj
		$stage create text $x $y -text $sndname -tags "comment $memory" -anchor w -fill $evv(POINT)
		return
	}
	set k [lsearch [$stage itemcget $obj -tag] "comment"]		;# COMMENT TO SOUND
	if {$k >= 0} {
		foreach thistag [$stage itemcget $obj -tag] {
			if [string match #* $thistag] {
				set sndfile [string range $thistag 1 end]
				break
			}
		}
		if {![info exists sndfile]} {
			return
		}
		set coords [$stage coords $obj]
		set x [lindex $coords 0]
		set y [lindex $coords 1]
		$stage delete $obj
		$stage create text $x $y -text $sndfile -tags snd -anchor w -fill $evv(POINT)
	}
}

#------ STILL TO IMPLEMENT

proc ReplaceCommentOnScore {x y} {
	global score_left score_right score_chwidth score_comment stage wstk evv

	if {![info exists score_comment] || ([string length $score_comment] <= 0)} {
		Inf "No New Comment Written"
		return
	} elseif {[string first "_" $score_comment] >= 0} {
		Inf "Use No Underscores In Comments"
		return
	}
	set obj [$stage find closest $x $y]
	set k [lsearch [$stage itemcget $obj -tag] "comment"]
	if {$k >= 0} {
		foreach thistag [$stage itemcget $obj -tag] {
			if [string match #* $thistag] {
				set msg "This Comment Could Be Converted Back To Sound.\n\nRenaming It Will Prevent This\n\nAre You Sure You Want To Rename It ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
				break
			}
		}
		set coords [$stage coords $obj]
		set x [lindex $coords 0]
		set y [lindex $coords 1]
		set insert_text [string toupper $score_comment]
		set itemwidth [expr [string length $score_comment] * $score_chwidth]
		incr itemwidth
		set leftlim  $score_left
		set rightlim [expr $score_right - $itemwidth]

		if {$x <= $leftlim} {						 
			set x $leftlim
		}
		if {$x > $rightlim} {
			set x $rightlim
		}
		set y [AdjustScoreVertPos $y]
		$stage delete obj
		$stage create text $x $y -text "$insert_text" -tags comment -anchor w -fill $evv(POINT)
	}
}

##################################################################
# GETTING A LIST OF ACCESSIBLE MIXFILES AND VIEWING THOSE MIXESZ #
##################################################################

#---- Construct a list of mixfiles you want to able to look at from the Sketch Score page

proc GetMixfileForSubsequentViewing {} {
	global scvumixname scvumixdir pr_scvumix scvumixlist zootlist evv

	catch {unset zootlist}
	set f .scvumix
	if [Dlg_Create $f "SELECT MIXFILES FOR VIEWING" "set pr_scvumix 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.d -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		frame $f.e.1 -bd $evv(SBDR)
		frame $f.e.2 -bd $evv(SBDR)
		button $f.b.dir -text "Mixes In Dir" -command {set pr_scvumix 1} -width 13 -highlightbackground [option get . background {}]
		button $f.b.dir2 -text "Keep New List" -command {set pr_scvumix 2} -width 13 -highlightbackground [option get . background {}]
		button $f.b.qu -text "Close" -command {set pr_scvumix 0} -width 7 -highlightbackground [option get . background {}]
		label $f.explan1 -text "SELECT A DIRECTORY  :  MIXFILES IN DIRECTORY WILL BE SHOWN IN LEFT PANEL" -fg $evv(SPECIAL)
		label $f.explan2 -text "SELECT MIXFILES FROM LEFT PANEL WITH MOUSE  :  SELECTED MIXES SHOWN IN RIGHT PANEL" -fg $evv(SPECIAL)
		label $f.explan3 -text "DESELECT A MIX FROM RIGHT PANEL BY CLICKING ON IT WITH WITH MOUSE" -fg $evv(SPECIAL)
		pack $f.b.dir -side left -padx 2
		pack $f.b.qu $f.b.dir2 -side right -padx 4
		button $f.d.b -text "Find Dir" -command {DoListingOfDirectories .scvumix.d.e} -width 8 -highlightbackground [option get . background {}]
		label $f.d.lab -text "Directory to Search  "
		entry $f.d.e -textvariable scvumixdir -width 40
		pack $f.d.lab $f.d.e $f.d.b -side left -padx 3
		label $f.e.1.lab -text "MIXFILES IN SPECIFIED DIRECTORY"
		Scrolled_Listbox $f.e.1.ld -width 64 -height 24 -selectmode extended
		label $f.e.2.lab -text "MIXFILES SELECTED TO WORK WITH"
		Scrolled_Listbox $f.e.2.lf -width 64 -height 24 -selectmode single
		pack $f.e.1.lab $f.e.1.ld -side top -pady 2
		pack $f.e.2.lab $f.e.2.lf -side top -pady 2
		pack $f.e.1 $f.e.2 -side left -fill both -padx 2
		pack $f.b -side top -fill x -pady 2 -expand true
		pack $f.d -side top -fill x -pady 2 -expand true -anchor center
		pack $f.explan1 $f.explan2 $f.explan3 -side top -pady 2 -anchor center
		pack $f.e -side top -fill both -expand true
#		wm resizable $f 0 0
		bind $f.e.1.ld.list <ButtonRelease-1> {SelectMixesForScore .scvumix.e.1.ld.list .scvumix.e.2.lf.list}
		bind $f.e.2.lf.list <ButtonRelease-1> {DeselectMixForScore .scvumix.e.2.lf.list}
		set zootlist {}
		bind $f <Escape> {set pr_scvumix 0}
	}
	$f.e.1.ld.list delete 0 end
	$f.e.2.lf.list delete 0 end
	if [info exists scvumixlist] {
		foreach item $scvumixlist {
			$f.e.2.lf.list insert end $item
			lappend zootlist $item
		}
	}
	set scvumixdir ""
	set finished 0
	set gotmixes {}
	set pr_scvumix 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_scvumix $f.d.e
	while {!$finished} {
		tkwait variable pr_scvumix
		switch -- $pr_scvumix {
			0 { break }
			1 {
				if {[string length $scvumixdir] > 0} {
					if {![file exists $scvumixdir]} {
						Inf "Directory '$scvumixdir' Does Not Exist"
						continue
					}
					if {![file isdirectory $scvumixdir]} {
						Inf "'$scvumixdir' Is Not A Directory"
						continue
					}
				}
				catch {unset gotmixes}

				set this_ext [GetTextfileExtension mix]
				if {![string match $this_ext $evv(TEXT_EXT)]} {
					foreach fnam [glob -nocomplain [file join $scvumixdir *$this_ext]] {
						set ftyp [FindFileType $fnam]
						if {($ftyp != -1) && [IsAMixfile $ftyp]} { 
							lappend gotmixes $fnam
						}
					}
				}
				foreach fnam [glob -nocomplain [file join $scvumixdir *$evv(TEXT_EXT)]] {
					set ftyp [FindFileType $fnam]
					if {($ftyp != -1) && [IsAMixfile $ftyp]} { 
						lappend gotmixes $fnam
					}
				}
				if {![info exists gotmixes]} {
					Inf "There Are No Valid Mixfiles In Directory '$scvumixdir'"
					continue
				}
				$f.e.1.ld.list delete 0 end
				foreach fnam $gotmixes {
					$f.e.1.ld.list insert end $fnam
				}
			}
			2 {
				catch {unset scvumixlist} 
				foreach fnam [lsort -dictionary $zootlist] {
					lappend scvumixlist $fnam
				}
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SelectMixesForScore {ll ll2} {
	global zootlist

	set ilist [$ll curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		return
	}
	foreach i $ilist {
		set fnam [$ll get $i]
		set k [lsearch $zootlist $fnam]
		if {$k < 0} {
			lappend zootlist $fnam
			$ll2 insert end $fnam
		}
	}
}

proc DeselectMixForScore {ll2} {
	global zootlist
	set i [$ll2 curselection]
	if {![info exists i] || ($i < 0)} {
		return
	}
	$ll2 delete $i
	catch {unset zootlist}
	foreach fnam [$ll2 get 0 end] {
		lappend zootlist $fnam
	}
}

#-----Remember the list of mixfiles being accessed from sketch score

proc BakupScoreMixlist {} {
	global scvumixlist evv

	if {![info exists scvumixlist]} {
		return
	}
	set tmpfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tmpfnam w} fileId] {
		Inf "Cannot Open Temporary File To Do Save Sketch Mixlist Information."
		return
	}
	foreach fnam $scvumixlist {
		puts $fileId $fnam
	}
	close $fileId
	set sc_file [file join $evv(URES_DIR) $evv(SKMIX)$evv(CDP_EXT)]
	if [file exists $sc_file] {
		if [catch {file delete $sc_file}] {
			ErrShow "CANNOT DELETE ORIGINAL SKETCH-SCORE MIXLIST FILE. CANNOT UPDATE LISTING OF SKETCH-SCORE MIXFILE LIST."
			return
		}
	}
	if [catch {file rename $tmpfnam $sc_file}] {
		ErrShow "CANNOT RENAME TEMPORARY SKETCH-SCORE MIXLIST FILE $tmpfnam\n\nYOU MUST RENAME THIS FILE TO $sc_file OUTSIDE THE SOUNDLOOM\nIF YOU WISH TO RETAIN THIS DATA"
		return
	}
	return
}

#-----Restore the list of mixfiles being accessed from sketch score

proc LoadScoreMixList {} {
	global scvumixlist wstk evv

	set sc_file [file join $evv(URES_DIR) $evv(SKMIX)$evv(CDP_EXT)]
	if {![file exists $sc_file]} {
		return
	}
	if [catch {open $sc_file r} fileId] {
		Inf "Cannot Open File '$sc_file' To Restore Sketch Score Mix List Information."
		return
	}
	while {[gets $fileId line] >= 0} {
		set fnam [string trim $line]
		if {[string length $fnam] <= 0} {
			continue
		}
		if {![file exists $fnam] || [file isdirectory $fnam]} {
			lappend badfiles $fnam
		}
		set ftyp [FindFileType $fnam]
		if {($ftyp != -1) && [IsAMixfile $ftyp]} { 
			lappend gotmixes $fnam
		} else {
			lappend badfiles $fnam
		}
	}
	close $fileId
	if [info exists gotmixes] {
		set scvumixlist $gotmixes
	} else {
		set msg "The Mixfiles You Have Been Accessing From The Sketch Score\n\nEither No Longer Exist\n\nOr Are No Longer Valid Mixfiles.\n\Delete The Mixfile Listing??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			catch {file delete $sc_file}
		}
		return
	}
	if [info exists badfiles] {
		set msg "Some Of The Mixfiles You Have Been Accessing From The Sketch Score\n\nEither No Longer Exist\n\nOr Are No Longer Valid Mixfiles.\n\nChange The Mixfile Listing??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			BakupScoreMixlist
		}
	}
}

#---- Construct a list of mixfiles you want to able to look at from the Sketch Score page

proc ViewMixfileFromScore {again} {
	global pr_scvumix2 scvumixlist last_scvumix last_scvumixname wstk sc_overlap vm_overlap vm_newtimes vm_i pa vm_chosen_mixfile evv
	global scoremixlist

	catch {unset vm_chosen_mixfile}
	if {$again == 2} {		;#	ADD SOUND(S) TO MIX
		set vm_i -1
		if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
			Inf "No Sound Selected: Select Sound(s) In 'Choose Mode'"
			return
		}
		set vm_overlap 0
		foreach fnam $scoremixlist {
			if {![info exists pa($fnam,$evv(DUR))]} {
				Inf "File '$fnam' Is Not On The Workspace :  Cannot Proceed"
				return
			} else {
				lappend durs $pa($fnam,$evv(DUR))
			}
		}
		set vm_newtimes 0
		set len [llength $durs]
		if {$len > 1} {
			incr len -2
			set durs [lrange $durs 0 $len]
			if {[info exists sc_overlap]} {
				set msg "Use An Overlap Of $sc_overlap When Adding Files ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					foreach dur $durs {
						set newdur [expr $dur - $sc_overlap]
						if {$newdur < 0.0} {
							set msg "This Overlap Value Is Too Large For Some Of The New Files: Continue With No Overlap ?"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								return
							} else {
								break
							}
						} else {
							lappend newdurs $newdur
						}
					}
					if {[info exists newdurs] && ([llength $newdurs] == [llength $durs])} {
						set durs $newdurs
						set vm_overlap $sc_overlap
					}
				}
			}
			set sum 0
			foreach dur $durs {
				set sum [expr $sum + $dur]
				lappend vm_newtimes $sum
			}
		}
	}
	set f .scvumix2
	if [Dlg_Create $f "VIEW A MIXFILE" "set pr_scvumix2 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.b2 -bd $evv(SBDR)
		frame $f.d -bd $evv(SBDR)
		frame $f.d2 -bd $evv(SBDR)
		frame $f.d3 -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		button $f.b.qu -text "Goto Score" -command {set pr_scvumix2 0} -width 10 -highlightbackground [option get . background {}]
		button $f.b.ex -text "Mix->Wkspce"  -command {SketchGetMix .scvumix2.e.1.ll.list} -width 10 -highlightbackground [option get . background {}]
		pack $f.b.qu -side right -pady 2
		pack $f.b.ex -side left -pady 2
		label $f.b2.explan -text "SELECT A MIXFILE FROM THE FIRST LIST" -fg $evv(SPECIAL) -width 44

		pack $f.b2.explan -side top -pady 2 -anchor center
		button $f.d.srch -text "Snd In Logs?" -command {SearchLogsForSketchFile} -width 10 -highlightbackground [option get . background {}]
		button $f.d.play -text "PlaySndinMix" -command {PlaySndInMixfile .scvumix2.e.2.ll.list; raise .scvumix2} -width 10 -highlightbackground [option get . background {}]
		button $f.d.mplay -text "Mix & Play" \
			-command {DoMixAndPlayFromSketchScore .scvumix2.e.1.ll.list .scvumix2.e.2.ll.list; raise .scvumix2; focus .scvumix2} -width 10
		button $f.d2.add -text "Snds to Mix" -command {AddSoundsToMixOnSketchScore .scvumix2.e.1.ll.list .scvumix2.e.2.ll.list; raise .scvumix2} -width 10 -highlightbackground [option get . background {}]
		button $f.d2.keep -text "Save+NuSnds" -command {KeepNewMixOnSketchScore .scvumix2.e.1.ll.list .scvumix2.e.2.ll.list; raise .scvumix2} -width 10 -highlightbackground [option get . background {}]
		button $f.d2.edit -text "Edit Mix"  -command {EditMixOnSketchScore; raise .scvumix2} -width 10 -highlightbackground [option get . background {}]
		button $f.d2.qe -text "Quick Edit"  -command {EditSrcMixfile sketchmix; raise .scvumix2} -width 10 -highlightbackground [option get . background {}]
		pack $f.d.mplay -side left -padx 2
		pack $f.d.srch $f.d.play -side right -padx 2
		pack $f.d2.add $f.d2.keep -side left -padx 2
		pack $f.d2.qe $f.d2.edit -side right -padx 2
		set e1 [frame $f.e.1 -bd $evv(SBDR)]
		set e2 [frame $f.e.2 -bd $evv(SBDR)]
		label $e1.tit -text "MIXFILES"
		Scrolled_Listbox $e1.ll -width 64 -height 8 -selectmode single
		pack $e1.tit $e1.ll -side top -pady 2
		label $e2.tit -text ""
		Scrolled_Listbox $e2.ll -width 64 -height 20 -selectmode single
		pack $e2.tit $e2.ll -side top -pady 2
		pack $e1 $e2 -side top -pady 2
		pack $f.b -side top -fill x -pady 2 -expand true
		pack $f.b2 -side top -fill x -pady 2 -expand true
		pack $f.d -side top -fill x -pady 2 -expand true
		pack $f.d2 -side top -fill x -pady 2 -expand true
		pack $f.e -side top -fill x -pady 2 -expand true
#		wm resizable $f 0 0
		bind $f.e.1.ll.list <ButtonRelease-1> {SelectMixForScoreToView .scvumix2.e.1.ll.list .scvumix2.e.2.ll.list}
		bind $f <Escape> {set pr_scvumix2 0}
	}
	$f.e.1.ll.list delete 0 end
	$f.e.2.ll.list delete 0 end
	if [info exists scvumixlist] {
		foreach item $scvumixlist {
			$f.e.1.ll.list insert end $item
		}
	}
	if {$again == 1} {
		if {[info exists last_scvumix] && [info exists last_scvumixname]} {
			foreach fnam $last_scvumix {
				$f.e.2.ll.list insert end $fnam
			}
			.scvumix2.e.2.tit config -text $last_scvumixname
		} else {
			Inf "No Previous Mix Has Been Viewed"
			return
		}
	}
	set finished 0
	set pr_scvumix2 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_scvumix2 $f.e.1.ll.list
	tkwait variable pr_scvumix2
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SelectMixForScoreToView {ll ll2} {
	global vm_i vm_chosen_mixfile
	set i [$ll curselection]
	if {![info exists i] || ($i < 0)} {
		return
	}
	catch {unset vm_chosen_mixfile}
	set vm_i $i
	DisplayMixForSketch [$ll get $i] $ll2
}

proc DisplayMixForSketch {fnam ll2} {
	global last_scvumix last_scvumixname evv

	if {![file exists $fnam] || [file isdirectory $fnam]} {
		Inf "The Mixfile '$fnam' No Longer Exists"
		return
	}
	set ftyp [FindFileType $fnam]
	if {($ftyp == -1) || ![IsAMixfile $ftyp]} { 
		Inf "The File '$fnam' Is No Longer A Valid Mixfile"
		return
	}
	if [catch {open $fnam r} zit] {
		Inf "Cannot Open The Mixfile '$fnam'"
		return
	}
	$ll2 delete 0 end
	catch {unset last_scvumix} 
	while {[gets $zit line] >= 0} {
		$ll2 insert end $line
		lappend last_scvumix $line
	}
	set last_scvumixname $fnam
	close $zit
	.scvumix2.e.2.tit config -text $last_scvumixname
}	

proc SearchLogsForSketchFile {} {
	global pr_scvumix2

	set i [.scvumix2.e.2.ll.list curselection]
	if {$i < 0} {
		return
	}
	set line [.scvumix2.e.2.ll.list get $i]
	set line [string trim $line]
	set line [split $line]
	set fnam [file rootname [file tail [lindex $line 0]]]
	SearchLogs $fnam 0
	raise .scvumix2
	My_Grab 0 .scvumix2 pr_scvumix2 .scvumix2.e.1.ll.list
}


###########################
# PLAY SOUND START OR END #
###########################

#----- Play sounds when clicked on

proc ScoreToExcerptMode {} {
	global stage score scoremixlist draglist dragdx dragdy in_unattached_mode comments_attached saved_comments_attached sl_real

	if {!$sl_real} {
		Inf "In Excerpt Mode, Mouse Operations On The Score Are....\n\n1) Play Start Of Sound\n2) Play End Of Sound\n3) Play More Of Start (or End) Of Sound"
		return
	}
	$score.btns2.expl config -text "TIME SEQUENCE IS LEFT TO RIGHT & TOP PANEL TO BOTTOM" -bg [option get . background {}] -fg [option get . foreground {}]
	bind $stage <ButtonRelease-1>					{}
	bind $stage <Control-ButtonRelease-1>			{}
	bind $stage <Control-Shift-ButtonRelease-1>		{}
	bind $stage <Shift-ButtonPress-1> 				{}
	bind $stage <Shift-B1-Motion> 					{}
	bind $stage <Shift-ButtonRelease-1>				{}
	bind $stage <Command-ButtonRelease-1>				{}
	bind $stage <Command-Control-ButtonRelease-1>		{}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{}
	bind $stage <Command-Shift-ButtonRelease-1>			{}
	bind $stage <ButtonRelease-1> 					{PlaySoundEdge %x %y start 0}
	bind $stage <Control-ButtonRelease-1>			{PlaySoundEdge %x %y 0 1}
	bind $stage <Control-Shift-ButtonRelease-1>		{Inf "Invalid Operation"}
	bind $stage <Shift-ButtonRelease-1> 			{PlaySoundEdge %x %y end 0}
	bind $stage <Command-ButtonRelease-1>				{PlaySoundEdge %x %y 0 -1}
	bind $stage <Command-Control-ButtonRelease-1>		{PlaySoundEdge %x %y end .5}
	bind $stage <Command-Control-Shift-ButtonRelease-1>	{Inf "Invalid Operation"}
	bind $stage <Command-Shift-ButtonRelease-1>			{Inf "Invalid Operation"}

	if {$in_unattached_mode} {
		if [info exists saved_comments_attached] {
			set comments_attached $saved_comments_attached
		}
		set in_unattached_mode 0
	}
	catch {unset scoremixlist}
	catch {unset dragdx}
	catch {unset dragdy}
	if [info exists draglist] {
		ConfirmDragPosition
		unset draglist
	}
	$score.btns.inf  config -state disabled -bd 0 -text ""
	$score.btns.bkgd.bkgd config -state disabled -bd 0 -text ""
	$score.btns.test config -state normal -bd 2 -text "Test Seq"
	$score.btns.bkgd.savw config -state normal -bd 2 -text "Use Snds"
	$score.btns.comm config -state normal -bd 2 -text "Score Ops"
	$score.btns2.slec config -text "Excerpt Ops"
	$score.btns2.tog config -state normal -bd 2 -text "Move Text+Snds?"

	$score.btns2.slec.menu entryconfig 0 -label "Click                        : Play Start of sound"
	$score.btns2.slec.menu entryconfig 2 -label "Shift Click               : Play End of sound"
	$score.btns2.slec.menu entryconfig 4 -label "Control Click           : Play More of sound"
	$score.btns2.slec.menu entryconfig 6 -label "Command Click                   : Play Less of sound"
	$score.btns2.slec.menu entryconfig 8 -label "Control Command Click      : Start (or End) halfway through"
	$score.btns2.slec.menu entryconfig 10 -label ""
	$score.btns2.slec.menu entryconfig 12 -label ""
	$score.btns2.slec.menu entryconfig 14 -label ""
	$score.btns2.slec.menu entryconfig 16 -label ""
	$score.btns2.slec.menu entryconfig 18 -label ""
	$score.btns2.slec.menu entryconfig 20 -label ""
}

proc PlaySoundEdge {x y where more_or_less} {
	global stage
	set obj [$stage find closest $x $y]
	if {![string match [lindex [$stage itemcget $obj -tag] 0] "snd"]} {
		return
	}
	set snd [$stage itemcget $obj -text]
	PlayEdgeOfScoreSound $snd $where $more_or_less
}


proc PlayEdgeOfScoreSound {fnam where incr} {
	global wstk evv

	set batch [ConstructScoreBatch3 $fnam $where $incr]
	if {[llength $batch] <= 0} {
		return
	}
	set outfilename [lindex [lindex $batch 0] 4]
	append outfilename  $evv(SNDFILE_EXT)
	set title "Getting Edge"
	if {![RunScoreTestBatchFile $batch $title]} {
		return
	}
	set choice "yes"
	PlaySndfile $outfilename 0			;# PLAY OUTPUT
	set msg "\n   'Make Test Sequence' And Playing Files On The Sketch Score"
	append msg "\n                                     Will Not Respond"		
	ClearTempFiles 1 $msg
}


proc ConstructScoreBatch3 {fnam where incr} {
	global scorecut scoredur scoreclip pa evv

	set newfile 0
	if {![info exists scoreclip] || ![string match $fnam $scoreclip]} {
		if {![info exists pa($fnam,$evv(DUR))]} {
			if {[DoParse $fnam 0 0 0] <= 0} {
				return {}
			}
		}
		;# MAXIMUM CLIP THAT CAN BE ASKED FOR IS HALF LENGTH OF SOUND
		set totlen [expr $pa($fnam,$evv(DUR)) * $pa($fnam,$evv(CHANS)) * $pa($fnam,$evv(SRATE)) / 2]
		if {![CheckScoreTestDiskspace $totlen $pa($fnam,$evv(SRATE))]} {
			return {}
		}
		set scoredur [expr $pa($fnam,$evv(DUR)) - $evv(FLTERR)]
		set scoreclip $fnam
		set newfile 1
	}
	switch -- $incr {
		0  { ResetScorecut $where $newfile}		;# Reset position to start or end: Reset excerptlen to min, if new file
		1  {	
			if {$newfile} {
				ResetScorecut $where $newfile
			}
			set where [PlayMore]				;# Plays whichever end already chosen: if none chosen returns 0
		}
		-1 { 
			if {$newfile} {
				ResetScorecut $where $newfile
			}
			set where [PlayLess]				;# Plays whichever end already chosen: if none chosen returns 0
		}
		.5 {
			if [info exists scorewhere] {		;#	Plays end if no previous end-start decision taken
				set where $scorewhere
			}
			set scorecut [expr $scoredur/2.0]
		}	
	}
	if {$where == "0"} {
		return
	}
	switch -- $where {
		"start" {
			if {$scorecut > $scoredur} {
				set scorecut $scoredur
			}
			set line "sfedit cut 1 $fnam $evv(DFLT_OUTNAME)0 0 $scorecut"
		}
		"end" {
			set thisstart [expr $scoredur - $scorecut]
			if {$thisstart < 0} {
				set thisstart 0
			}
			set line "sfedit cut 1 $fnam $evv(DFLT_OUTNAME)0 $thisstart $scoredur"
		}
	}
	lappend batch $line
	return $batch
}

#----- Increase length of sound-end to play

proc PlayMore {} {
	global scorecut scoredur scorewhere evv
	if {![info exists scoredur] || ![info exists scorewhere]} {
		return 0
	}
	set scorecut [expr $scorecut + $evv(SCORECUT)]
	if {$scorecut > $scoredur} {
		set scorecut $scoredur
	}
	return $scorewhere
}

#----- Decrease length of sound-end to play

proc PlayLess {} {
	global scorecut scoredur scorewhere evv
	if {![info exists scoredur] || ![info exists scorewhere]} {
		return 0
	}
	set scorecut [expr $scorecut - $evv(SCORECUT)]
	if {$scorewhere > 0} {
		if {$scorecut < $scoredur} {
			set scorecut $scoredur
		} elseif {$scorecut < $evv(SCORECUT)} {
			set scorecut $evv(SCORECUT)
		}
	} elseif {$scorecut < $evv(SCORECUT)} {
		set scorecut $evv(SCORECUT)
	}
	return $scorewhere
}

#----- Set standard length of sound-end to play

proc ResetScorecut {where newfile} {
	global scorecut scorewhere evv
	if {$newfile || ([info exists scorewhere] && ($where != $scorewhere))} {
		set scorecut $evv(SCORECUT)
		set scorewhere $where
	}
}

###############################################
#  CALCULATE TOTAL DURATION OF SELECTED FILES #
###############################################

proc ScoreSelDur {} {
	global scoremixlist nuparse pa evv
	if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
		Inf "No Files Selected"
		return
	}
	set filelist $scoremixlist
	set sum 0.0
	foreach fnam $filelist {
		if {![info exists pa($fnam,$evv(DUR))]} {
			if {[DoParse $fnam 0 0 0] <= 0} {
				set finished 1
				break
			} else {
				lappend nuparse $fnam
			}
		}
		set sum [expr $sum + $pa($fnam,$evv(DUR))]
	}
	set secs $sum
	set mins [expr floor($secs / 60.0)]
	set secs [expr $secs - ($mins * 60.0)]
	set hrs [expr floor($mins / 60.0)]
	set mins [expr $mins - ($hrs * 60.0)]
	if {$mins <= 0.0} {
		Inf "Total Duration Is $secs seconds"
	} elseif {$hrs <= 0.0} {
		Inf "Total Duration Is $mins mins $secs secs"
	} else {
		Inf "Total Duration Is $hrs hrs $mins mins $secs secs"
	}
}

#----- Search Logs for Origin of Sound

proc ScoreSearchLogs {} {
	global scoremixlist
	if {![info exists scoremixlist]} {
		Inf "No File Has Been Chosen"
		return
	}
	if {[llength $scoremixlist] != 1} {
		Inf "This Option Only Works With A Single File"
		return
	}
	set fnam [file tail [lindex $scoremixlist 0]]
	SearchLogs $fnam 0
}

#----------

proc PlaySndInMixfile {ll} {
	global evv

	set i [$ll curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No Mixfile Line Selected"
		return
	}
	set fnam [lindex [$ll get $i] 0]
	set fnam [string trim $fnam]
	if {([string length $fnam] <= 0) || [string match [string index $fnam 0] ";"]} {
		Inf "Mixfile Line Has No Active File"
		return
	}
	if {![file exists $fnam] || [file isdirectory $fnam]} {
		Inf "This File No Longer Exists"
		return
	}
	set ftyp [FindFileType $fnam]
	if {$ftyp != $evv(SNDFILE)} {
		return
	}
	PlaySndfile $fnam 0
}

#------ Look for a lost or renamed file in a sketch score

proc SketchFileRename {} {
	global sketchbadfile sketchbaddir pr_scfind evv

	set nufnam ""
	set f .skbad
	if [Dlg_Create $f "FIND A LOST FILE" "set pr_scfind 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.b -bd $evv(SBDR)
		frame $f.e -bd $evv(SBDR)
		frame $f.e2 -bd $evv(SBDR)
		frame $f.d -bd $evv(SBDR)
		set msg "You Can Edit The Search String To Match Against Filenames\n\n"
		append msg "Specify A Base Drive Or Directory To Search\n"
		append msg "(Subdirectories Will Be Searched)\n\n"
		append msg "Select A File From The Resulting Displayed List"
		label $f.lab -text $msg -fg $evv(SPECIAL)
		button $f.b.qu -text "Close" -command {set pr_scfind 0} -width 7 -highlightbackground [option get . background {}]
		button $f.b.ok -text "Use File" -command {set pr_scfind 1} -width 7 -highlightbackground [option get . background {}]
		button $f.b.fil -text "Find File" -command {FindSketchFileInDir} -width 10 -highlightbackground [option get . background {}]
		button $f.b.dir -text "Find Dir" -command {DoListingOfDirectories .skbad.e2.e} -width 10 -highlightbackground [option get . background {}]
		pack $f.b.qu -side right -padx 2
		pack $f.b.ok $f.b.fil $f.b.dir -side left -padx 2
		label $f.e.l -text "Search String     "
		entry $f.e.e -textvariable sketchbadfile -width 84
		pack $f.e.l $f.e.e -side left
		label $f.e2.l -text "Base Directory "
		entry $f.e2.e -textvariable sketchbaddir -width 84
		pack $f.e2.l $f.e2.e -side left
		Scrolled_Listbox $f.d.ll -width 84 -height 20 -selectmode single
		pack $f.d.ll -side top -fill both -expand true
		pack $f.b $f.lab $f.e $f.e2 $f.d -side top -pady 2 -fill x -expand true
#		wm resizable $f 0 0
		bind $f <Return> {set pr_scfind 1}
		bind $f <Escape> {set pr_scfind 0}
	}
	set sketchbaddir ""
	$f.d.ll.list delete 0 end
	set finished 0
	set pr_scfind 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_scfind $f.e.e
	while {!$finished} {
		tkwait variable pr_scfind
		if {!$pr_scfind} {
			set nufnam ""
			break
		}
		set i [$f.d.ll.list curselection]
		if {![info exists i] || ($i < 0)} {
			Inf "No File Selected"
			continue
		}
		catch {unset bozo}
		lappend bozo [$f.d.ll.list get $i]
		if [GappedName $bozo] {
			continue
		}
		set nufnam [StripHomeDir [$f.d.ll.list get $i]]
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $nufnam
}

#----- Search directories for a lost or renamed file in a sketch score

proc FindSketchFileInDir {} {
	global sketchbaddir sketchbadfile evv

	if {[string length $sketchbadfile] <= 0} {
		Inf "No Search String Given"
		return
	}
	if {![info exists sketchbaddir]} {
		set sketchbaddir ""
	}
	if {([string length $sketchbaddir] > 0) && ![file isdirectory $sketchbaddir]} {
		Inf "'$sketchbaddir' Is Not A Directory"
		return
	}
	set fdir {}
	set fdir [SearchDirectoriesForFile 0 $sketchbaddir $sketchbadfile $fdir 1 0]
	if {[llength $fdir] > 0} {
		set i 0
		set j -1
		foreach fnam $fdir {
			set drn [file dirname $fnam]
			if {([string match -nocase $drn [pwd]] || ([string length $drn] <= 1)) \
			&& [string match *$evv(GUI_NAME)$evv(TCL_EXT) $fnam]} {
				set j $i
				break
			}
			incr i
		}
		if {$j >= 0} {
			set fdir [lreplace $fdir $j $j]
		}
	}
	if {[llength $fdir] <= 0} {
		Inf "Cannot Find Any Filename Containing '$sketchbadfile'"
		return
	}
	set fdir [lsort $fdir]
	.skbad.d.ll.list delete 0 end
	foreach fnam $fdir {
		.skbad.d.ll.list insert end $fnam
	}
	return
}	

#--- Rename file in current-score listing

proc RenameOnScore {oldfnam nufnam} {
	global scoresave upsave dnsave nuparse

	if [info exists scoresave] {
		set cnt 0
		foreach {text x y} $scoresave {
			if {[string match $text $oldfnam]} {
				lappend onscore $cnt
			}
			incr cnt 3
		}
	}
	if [info exists onscore] {
		foreach pos $onscore {
			set scoresave [lreplace $scoresave $pos $pos $nufnam]
		}
	}
	if [info exists upsave] {
		foreach nam [array names upsave] {
			set xx [lindex $upsave($nam) 0]
			catch {unset onscore}
			set cnt 0
			foreach {text x y} $xx {
				if {[string match $text $oldfnam]} {
					lappend onscore $cnt
				}
				incr cnt 3
			}
			if [info exists onscore] {
				foreach pos $onscore {
					set xx [lreplace $xx $pos $pos $nufnam]
				}
				set upsave($nam) [lreplace $upsave($nam) 0 0 $xx]
			}
		}
	}
	if [info exists dnsave] {
		foreach nam [array names dnsave] {
			set xx [lindex $dnsave($nam) 0]
			catch {unset onscore}
			set cnt 0
			foreach {text x y} $xx {
				if {[string match $text $oldfnam]} {
					lappend onscore $cnt
				}
				incr cnt 3
			}
			if [info exists onscore] {
				foreach pos $onscore {
					set xx [lreplace $xx $pos $pos $nufnam]
				}
				set dnsave($nam) [lreplace $dnsave($nam) 0 0 $xx]
			}
		}
	}
}

#--- Remove file from current-score listing

proc RemoveFromScore {fnam} {
	global scoresave upsave dnsave wstk 

	if [info exists scoresave] {
		set cnt 0
		foreach {text x y} $scoresave {
			if {[string match $text $fnam]} {
				lappend onscore $cnt
			}
			incr cnt 3
		}
	}
	if [info exists onscore] {
		foreach pos [lsort -integer -decreasing $onscore] {
			set uppos [expr $pos + 2]
			set scoresave [lreplace $scoresave $pos $uppos]
		}
	}
	if [info exists upsave] {
		foreach nam [array names upsave] {
			set xx [lindex $upsave($nam) 0]
			catch {unset onscore}
			set cnt 0
			foreach {text x y} $xx {
				if {[string match $text $fnam]} {
					lappend onscore $cnt
				}
				incr cnt 3
			}
			if [info exists onscore] {
				foreach pos [lsort -integer -decreasing $onscore] {
					set uppos [expr $pos + 2]
					set xx [lreplace $xx $pos $uppos]
				}
				set upsave($nam) [lreplace $upsave($nam) 0 0 $xx]
			}
		}
	}
	if [info exists dnsave] {
		foreach nam [array names dnsave] {
			set xx [lindex $dnsave($nam) 0]
			catch {unset onscore}
			set cnt 0
			foreach {text x y} $xx {
				if {[string match $text $fnam]} {
					lappend onscore $cnt
				}
				incr cnt 3
			}
			if [info exists onscore] {
				foreach pos [lsort -integer -decreasing $onscore] {
					set uppos [expr $pos + 2]
					set xx [lreplace $xx $pos $uppos]
				}
				set dnsave($nam) [lreplace $dnsave($nam) 0 0 $xx]
			}
		}
	}
}

#--- Is file on current-score listing

proc IsOnScore {fnam} {
	global scoresave upsave dnsave

	if [info exists scoresave] {
		foreach {text x y} $scoresave {
			if {[string match $text $fnam]} {
				return 1
			}
		}
	}
	if [info exists upsave] {
		foreach nam [array names upsave] {
			foreach {text x y} [lindex $upsave($nam) 0] {
				if {[string match $text $fnam]} {
					return 1
				}
			}
		}
	}
	if [info exists dnsave] {
		foreach nam [array names dnsave] {
			foreach {text x y} [lindex $dnsave($nam) 0] {
				if {[string match $text $fnam]} {
					return 1
				}
			}
		}
	}
	return 0
}

#----- Refresh Unloaded Scores (for namechanges)

proc RefreshUnloadedScores {final} {
	global sketchbadfile wstk scores_refresh sl_real scorenameslist evv

	if {!$sl_real} {
		Inf "If You Have One Or More (Named Or Unnamed) Sketch Scores\nThe Soundloom Will Search These\nFor Names Of Sounds Which No Longer Exist\nAnd Offer You The Opportunity To\nRename Those Items Or Remove Them From Your Scores"
		return
	}
	set cnt 0
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) $evv(SKETCH)*]] {
		incr cnt
	}
	if {$cnt <= 0} {
		return
	}
	if {$final} {
		set msg "Do "
	} else {
		set msg "Are You Sure "
	}
	append msg "You Want To\n\nCheck All Your Scores For\n\nSoundfile Name Changes Or File Deletions ??"
	set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		set tempsketch [file join $evv(URES_DIR) $evv(SKETCH)$evv(CDP_EXT)]
		if {$final && ($cnt == 1) && [string match $fnam $tempsketch]} {
			set msg "Do You Want To Delete The Temporary Sketch Score You Have Been Using ??"
			set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				catch {file delete $tempsketch}
			}
		}
		return
	}
	set delfiles {}
	set renamefiles {}
	set renames {}

	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) $evv(SKETCH)*]] {

		if [catch {open $fnam r} fileId] {
			Inf "Cannot Open File '$fnam' To Refresh It"
		}
		Block "Refreshing $fnam"
		catch {unset lines}
		set is_comments 0
		while {[gets $fileId line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if [string match $line "#COMMENTS"] {
				set is_comments 1
			} elseif [string match #UPPANEL* $line ] {
				set is_comments 0
			} elseif [string match #DNPANEL* $line ] {
				set is_comments 0
			}
			set line [split $line]
			if {!$is_comments} {
				set oldfnam [lindex $line 0]
				if {![file exists $oldfnam]} {
					set k [lsearch $delfiles $oldfnam] 
					if {$k >= 0} {						;# If it's a known deletable file
						if {[info exists bombo] && ([lsearch $bombo $oldfnam] >= 0)} {	
							DeleteScore $fileId $fnam
							unset fileId				;#	If all scores with this sound are to be deleted
							break						;#	Attempt to delete score
						} else {	
							continue					;#	Else delete sound in score, by ignoring line
						}
					}
					set k [lsearch $renamefiles $oldfnam]	;# If it's a known renamble file, set known new name
					if {$k >= 0} {
						set line [lreplace $line 0 0 [lindex $renames $k]]
					
					} else {								;# Otherwise, query user
						set msg "Soundfile\n\n'$oldfnam'\n\nNO Longer Exists\n\nDelete The Score '$fnam' ??"
						set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							if {[AreYouSure]} {
								DeleteScore $fileId $fnam
								set msg "Delete All Other Scores Containing Soundfile\n\n'$oldfnam' ??"
								set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
								if {$choice == "yes"} {
									lappend bombo $oldfnam
								}
								lappend delfiles $oldfnam
								unset fileId
								break
							}
						}
						set msg "Soundfile\n\n$oldfnam\n\nNo Longer Exists\n\nSubstitute A Different Filename Or Directory Path ??"
						set choice [tk_messageBox -type yesno -icon error -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set sketchbadfile [file rootname [file tail $oldfnam]]
							set done 0											
							set delete_it 0									;# If user decides to attempt rename
							while {!$done} {
								set nufnam [SketchFileRename]				;# Go to get a new name
								if {[string length $nufnam] > 0} {			;# IF a new name got
									lappend renamefiles $oldfnam			;# remember the name to substitute (in other scores)
									lappend renames $nufnam					;# remember the substituted name
									set line [lreplace $line 0 0 $nufnam]	;# set new name in this line
									set done 1								;# exit loop

																			;# BUT IF a new name was not got								
								} else {									;# Check user understands they'll delete the file

									set msg "Are You Sure You Want To Delete '$oldfnam' From Score '$fnam' ??"
									set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]

									if {$choice == "yes"} {					;# If deletion confirmed, shall we delete in all scores?

										set msg "Delete References To '$oldfnam' From All Your Scores ??"
										set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
										if {$choice == "yes"} {
											lappend delfiles $oldfnam		;# mark for future deletions
										}
										set delete_it 1						;# in either case, mark this time for deletion
										set done 1							;#exit loop
									}
								}											;# BUT IF user does NOT confirm deletion, continue loop
							}
							if {$delete_it} {								;# If file marked for deletion, forget line
								continue
							}												;# If user decides to delete, shall we delete in all scores?
						} else {
							set msg "Deleted '$oldfnam' From Score '$fnam'\n\nDelete References To '$oldfnam' From All Your Scores ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								lappend delfiles $oldfnam
							}
							continue
						}
					}
				}
			}
			lappend lines $line
		}
		UnBlock
		if {[info exists fileId]}  {
			close $fileId
			if {![info exists lines]} {
				if [string match [file rootname [file tail $fnam]] $evv(SKETCH)] {
					catch {file delete $fnam}
				} else {
					set msg "Score File '$fnam' Now Contains No Data: Delete It ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						if [catch {file delete $fnam} zit] {
							Inf "Cannot Delete Score File '$fnam'"
						}
					}
				}
				continue
			}
			set tmpfnam $evv(DFLT_TMPFNAME)
			if [catch {open $tmpfnam w} fileId] {
				Inf "Cannot Open Temporary File To Refresh '$tmpfnam' Data"
				continue
			}
			if {[info exists lines]} {
				foreach line $lines {
					puts $fileId $line
				}
			} 
			close $fileId
			if [catch {file delete $fnam}] {
				ErrShow "Cannot Delete Original Sketch Score '$fnam'.\n\nThe New Listing Is In File '$tmpfnam'\n\nYou Should Rename This File Outside The Soundloom, Before Proceeding\n\nOther Sketch Score Updates Abandoned For Now"
				return 0
			}
			if [catch {file rename $tmpfnam $fnam}] {
				ErrShow "Cannot Rename Temporary Sketch Score '$tmpfnam' TO '$fnam'\n\nYou Must Rename This File Outside The Soundloom\nIf You Wish To Retain This Data\n\nOther Sketch Score Updates Abandoned For Now"
				return 0
			}
		}
	}
	set scores_refresh 0
}

#--- Find any local comment

proc GetLocalComment {scx scy} {
	global localcomment scorepnt stage evv

	set mindx $evv(SCORE_MINDX)				;# Max horizontal distance at which a comment can be 'close'

	catch {unset localcomment}
	foreach com [$stage find withtag comment] {
		set thiscoords [$stage coords $com]
		set dy [expr [lindex $thiscoords 1] - $scy]
		set thisabsdy [expr abs($dy)]				;#	Find x-axis closest of any close comments
		if {$thisabsdy < $evv(SCORE_MINDY)} {		;#	within a vertical & horizontal minimum range
			set dx [expr [lindex $thiscoords 0] - $scx]
			set thisabsdx [expr abs($dx)]
			if {$thisabsdx < $mindx} {
				set mindx $thisabsdx
				set thiscom $thiscoords
				set thisdx $dx
				set thisdy $dy
				set thisobj $com
			}
		}
	}										;# If a closest comment has been found
	if [info exists thiscom] {				;# Find any other snds close to that comment in horiz (x-axis) range
		set scx [lindex $thiscom 0]			;# and if any of these snds is vertically (y-axis) closer
		set scy [lindex $thiscom 1]			;# then found-comment is NOT local to orig sound
		foreach snd [$stage find withtag snd] {
			if {$snd == $thisobj} {
				continue
			}
			set thiscoords [$stage coords $snd]
			set dy [expr [lindex $thiscoords 1] - $scy]
			set thisabsdy [expr abs($dy)]
			set dx [expr [lindex $thiscoords 0] - $scx]
			set thisabsdx [expr abs($dx)]
			if {($thisabsdx < $evv(SCORE_MINDX)) && ($thisabsdy < $thisdy)} {
				return
			}
		}
		set localcomment $thiscom
		lappend localcomment $thisdx $thisdy
	}
}

proc SwapPanels {typ} {
	global scoresave commentsave scoreline1 scoreline2 scoreline3 stage

	foreach obj [$stage find withtag snd] {
		lappend lastscoresave [$stage itemcget $obj -text]
		set y [lindex [$stage coords $obj] 1]
		if {$y < $scoreline1} {
			lappend panel(1) $obj
		} elseif {$y < $scoreline2} {
			lappend panel(2) $obj
		} elseif {$y < $scoreline3} {
			lappend panel(3) $obj
		} else {
			lappend panel(4) $obj
		}
		lappend lastscoresave [lindex [$stage coords $obj] 0]
		lappend lastscoresave $y
	}
	if {[info exists lastscoresave]} {
		set scoresave $lastscoresave
	}
	foreach obj [$stage find withtag comment] {
		set thiscomment [$stage itemcget $obj -text]
		set y [lindex [$stage coords $obj] 1]
		if {$y < $scoreline1} {
			lappend panel(1) $obj
		} elseif {$y < $scoreline2} {
			lappend panel(2) $obj
		} elseif {$y < $scoreline3} {
			lappend panel(3) $obj
		} else {
			lappend panel(4) $obj
		}
		lappend lastscommentsave $thiscomment
		lappend lastscommentsave [lindex [$stage coords $obj] 0]
		lappend lastscommentsave $y
	}
	if {[info exists lastscommentsave]} {
		set commentsave $lastscommentsave 
	}
	switch -- $typ {
		Up {
			set dy $scoreline3
			if [info exists panel(1)]	{
				foreach obj $panel(1) {
					$stage move $obj 0 $dy
				}
			}
			set dy [expr -$scoreline1]
			if [info exists panel(2)]	{
				foreach obj $panel(2) {
					$stage move $obj 0 $dy
				}
			}
			if [info exists panel(3)]	{
				foreach obj $panel(3) {
					$stage move $obj 0 $dy
				}
			}
			if [info exists panel(4)]	{
				foreach obj $panel(4) {
					$stage move $obj 0 $dy
				}
			}
			return
		}
		Down {
			set dy [expr -$scoreline3]
			if [info exists panel(4)]	{
				foreach obj $panel(4) {
					$stage move $obj 0 $dy
				}
			}
			set dy $scoreline1
			if [info exists panel(1)]	{
				foreach obj $panel(1) {
					$stage move $obj 0 $dy
				}
			}
			if [info exists panel(2)]	{
				foreach obj $panel(2) {
					$stage move $obj 0 $dy
				}
			}
			if [info exists panel(3)]	{
				foreach obj $panel(3) {
					$stage move $obj 0 $dy
				}
			}
			return
		}
		12 -
		23 -
		34 { set dy $scoreline1 }
		13 -
		24 { set dy $scoreline2 }
		14 { set dy $scoreline3 }
	}
	set a [string index $typ 0]
	set b [string index $typ 1]
	if [info exists panel($a)]	{
		foreach obj $panel($a) {
			$stage move $obj 0 $dy
		}
	}
	set dy [expr -$dy]
	if [info exists panel($b)]	{
		foreach obj $panel($b) {
			$stage move $obj 0 $dy
		}
	}
}

#---- Get Soundfile from directory of a chosen file

proc GetFileFromChosenFileDir {} {
	global stage scoremixlist

	if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
		Inf "No File Selected"
		return
	}
	set thisdir [file dirname [lindex $scoremixlist 0]]
	if {[llength $scoremixlist] > 1} {
		foreach fnam [lrange $scoremixlist 1 end] {
			if {![string match [file dirname $fnam] $thisdir]} {
				Inf "Files From More Than One Directory Have Been Selected"
				return
			}
		}
	}
	if {[string length $thisdir] <= 1}  {
		GetSoundFromWkspace 1 1
	} else {
		set dir "#"
		append dir $thisdir
		GetSoundFromWkspace $dir 1
	}
	ScoreToPlayMode
}

#--- Find duplicate file in list, and return its name (if any)

proc HasFileDuplicates {filelist} {

	set last [llength $filelist]
	incr last -1
	set n 0 
	while {$n < $last} {
		set fnam0 [lindex $filelist $n] 
		set m $n
		incr m
		while {$m <= $last} {
			if {[string match $fnam0 [lindex $filelist $m]]} {
				return $fnam0
			}
			incr m
		}
		incr n
	}
	return ""
}

#--- Remove duplicate file from a list

proc RemoveDuplicates {filelist} {

	set last [llength $filelist]
	incr last -1
	set n 0 
	while {$n < $last} {
		set fnam0 [lindex $filelist $n] 
		set m $n
		incr m
		while {$m <= $last} {
			set fnam1 [lindex $filelist $m] 
			if {[string match $fnam0 $fnam1]} {
				set filelist [lreplace $filelist $m $m]
				incr last -1
			} else {
				incr m
			}
		}
		incr n
	}
	return $filelist
}


#------- Construct batchfile for Score Test Mix type 5

proc ConstructScoreBatch5 {file0 file1 chan0 chan1 dur0} {
	global pa evv

	set filindx 0
	switch -- $chan0 {
		1 { set line "$file0 0.0 1 1 C" }
		2 { set line "$file0 0.0 2 1" }
	}
	lappend mixbatch $line
	switch -- $chan1 {
		1 { set line "$file1 $dur0 1 1 C" }
		2 { set line "$file1 $dur0 2 1" }
	}
	lappend mixbatch $line
	set outfile0 $evv(DFLT_OUTNAME)
	append outfile0 $filindx $evv(TEXT_EXT)
	if [catch {open $outfile0 w} zit] {
		Inf "Cannot Open Temporary Mixfile '$outfile0'"
		return {}
	}
	foreach line $mixbatch {
		puts $zit $line
	}
	close $zit
	incr filindx
	set outfile1 $evv(DFLT_OUTNAME)
	append outfile1 $filindx
	set line "submix mix $outfile0 $outfile1"
	lappend batch $line
	return $batch	
}

proc TellGetSounds {} {
	Inf "Sounds May Be Grabbed...\n\n1) From Workspace Windows\n2) From B-Lists\n3) From Anywhere Else\n\nAnd Positioned On The Score Below"
	return
}

proc TellTestMix {} {
	Inf "Soundfiles On The Score May Be Joined In Various Ways\nAnd In Various Combinations\n\nYou May Hear...\n\n1) The Whole Score\n2) Particular Combinations Of Score Panels\n3) Specifically Selected Files\n\nYou May Make And Hear A Sequence Of \n\n1) Files Joined End To End\n2) Files Overlapped By N Seconds\n3) Files Starting A Specified Timestep Apart\n4) End Of One File To Start Of Next\n5) Only The Starts And Ends Of Files."
	return
}

proc TellRealMix {} {
	Inf "Soundfiles On The Score May Be Saved In A Mixfile, For Use Elsewhere,\nPossibly Using Features Of Test Mixes Already Heard."
	return
}

proc TellUseSnds {} {
	Inf "You Can Use The Whole Score Or Part Of It In Various Ways....\n\nYou May Use....\n\n1) The Whole Score\n2) Specified Combinations Of Score Panels\n3) Selected Sounds\n\nYou May Send Those Files........\n\n1) To The Workspace\n2) To The Chosen Files List On The Workspace\n3) To A New Or Existing B-List\n4) To (Create) A Mixfile, For More Detailed Work\n\nMixfiles May Be Created\n\n1) With All Files Synced At Start\n2) With All Files End-To-End\n3) With Specified Timestep Between Files\n4) With Specified Overlap Of Files"
	return
}

proc TellScoreOps {} {
	Inf "Using The Mouse, Sounds Can Be....\n\n1) Positioned\n2) Moved About\n3) Selected (For Other Operations)\n4) Removed\n5) Played\n\n	The Score Display May Be...\n\n1) Erased\n2) Restored\n3) Visible Panels Swapped Around Or Rotated\n\nComments May Be Written On The Score: These Can Be....\n\n1) Moved\n2) Removed\n3) Moved Along With The Nearest Sound When It Is Moved\n\nScores May Be Named: Named Scores May Be....\n\n1) Saved\n2) Loaded\n3) Renamed\n4) Destroyed"
	return
}

proc TellReferMix {} {
	Inf "Existing Mixfiles May Be Searched For And Placed On A Mixfile-Reference-List,\nMixfiles On The List May Be Displayed, For Reference"
	return
}

proc TellSndInfo {} {
	Inf "Information About Sounds Can Be Obtained....\n\n1) Calculate Total Duration Of Score\n2) Calculate Duration Of Selected File(s)\n3) Locate Creation Or Use Of Selected File In Logs Of Your Previous Sesions\n4) See Those Logs"
	return
}


proc GetWkspaceSoundListToScore {ismix} {
	global wl pa evv
	set i [$wl curselection]
 	if {([llength $i] <= 0) || [lindex $i 0] < 0} {
		Inf "No File Selected"
		return
	} elseif {[llength $i] > 1} {
		Inf "Select A Single File"
		return
	}
	set fnam [$wl get $i]
	if {$ismix} {
		if {![IsAMixfile $pa($fnam,$evv(FTYP))]} {
			Inf "File '$fnam' Is Not A Mixfile"
			return
		}
	} else {
		if {![IsASndlist $pa($fnam,$evv(FTYP))]} {
			Inf "File '$fnam' Is Not A Listing Of Soundfiles"
			return
		}
	}
	GetWkspaceSoundToScore $fnam $ismix
}

proc RestoreDeletedObject {} {
	global lastscoredelete stage lastscoresave lastcommentsave evv
	if {![info exists lastscoredelete]} {
		Inf "No Recently Deleted Item Remembered"
		return
	}
	set thistext [lindex $lastscoredelete 0]
	set thistag [lindex $lastscoredelete 1]
	set x [lindex $lastscoredelete 2]
	set y [lindex $lastscoredelete 3]
	$stage create text $x $y -text "$thistext" -tags $thistag -anchor w -fill $evv(POINT)
	unset lastscoredelete
}

proc AddSoundsToMixOnSketchScore {ll ll2} {
	global vm_i vm_overlap vm_chosen_mixfile vm_newtimes scoremixlist pa orig_vm_list evv 

	if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
		Inf "No Sounds Selected From Score"
		return
	}
	set endtime -1
	if {$vm_i < 0} {
		Inf "No Mixfile Selected"
		return
	}
	catch {unset orig_vm_list}
	set vm_chosen_mixfile [$ll get $vm_i]
	foreach line [$ll2 get 0 end] {
		lappend orig_vm_list $line
		set line [string trim $line]
		set line [split $line]
		set nuline {}
		foreach item $line {
			string trim $item
			if {[string length $item] > 0} {
				if {[string match [string index $item 0] ";"]} {
					set nuline {}
					break
				} else {
					lappend nuline $item
				}
			}
		}
		if {[llength $nuline] > 1} {
			set fnam [lindex $nuline 0]
			set time [lindex $nuline 1]
			if {$time > $endtime} {
				set endtime $time
				set lastfnam $fnam
			} elseif {$time == $endtime} {
				set endtime $time
				lappend lastfnam $fnam
			}
		}
	}
	if {![info exists lastfnam]} {
		Inf "No Mix Score File Data Found"
		catch {unset vm_chosen_mixfile}
		catch {unset vm_i}
		return
	}
	set maxdur 0
	foreach fnam $lastfnam {
		if {![info exists pa($fnam,$evv(DUR))]} {
			Inf "File '$fnam' Is Not On The Workspace: Cannot Add New Sounds To End Of This Mix"
			catch {unset vm_chosen_mixfile}
			catch {unset vm_i}
			return
		}
		if {$pa($fnam,$evv(DUR)) > $maxdur} {
			set maxdur $pa($fnam,$evv(DUR))
		}
	}
	set endtime [expr $endtime + $maxdur - $vm_overlap]
	if {$endtime  < 0.0} {
		Inf "Overlap Too Large To Work With Existing Mix"
		catch {unset vm_chosen_mixfile}
		catch {unset vm_i}
		return
	}

	;# IF FIRST SOUND OF LIST IS LAST SOUND IN EXISTING MIX, GET RID OF IT AND SHUFFLE TIMES

	if {[lsearch $lastfnam [lindex $scoremixlist 0]] >= 0} {
		if {[llength $scoremixlist] == 1} {
			Inf "This Sound Is Already In The Mix"
			catch {unset vm_chosen_mixfile}
			catch {unset vm_i}
			return
		}
		set scoremixlist [lrange $scoremixlist 1 end]
		set bottime [lindex $vm_newtimes 1]
		foreach time [lrange $vm_newtimes 1 end] {
			lappend nutimes [expr $time - $bottime]
		}
		set vm_newtimes $nutimes 
	}
#
#	foreach fnam $scoremixlist {
#		if {[lsearch $orig_vm_list $fnam] >= 0} {
#			Inf "Sound '$fnam' Is Already In The Mix"
#			catch {unset vm_chosen_mixfile}
#			catch {unset vm_i}
#			return
#		}
#	}
#
	set n 0
	set len [llength $vm_newtimes]
	while {$n < $len} {
		set time [lindex $vm_newtimes $n]
		set time [expr $time + $endtime]
		set vm_newtimes [lreplace $vm_newtimes $n $n $time]
		incr n
	}
	set n 0
	foreach fnam $scoremixlist {
		set time [lindex $vm_newtimes $n]
		switch -- $pa($fnam,$evv(CHANS)) {
			1 { set line "$fnam $time 1 1.0 C" }
			2 { set line "$fnam $time 2 1.0 L 1.0 R" }
		}
		$ll2 insert end $line
		incr n
	}
	$ll2 yview moveto 1.0
}

proc KeepNewMixOnSketchScore {ll ll2} {
	global last_mix wl rememd vm_i vm_chosen_mixfile do_parse_report orig_vm_list pa evv

	if {![info exists vm_chosen_mixfile]} {
		Inf "Mixfile Shown Is Already Saved"
		return
	}
	set fnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Open Temporary File '$fnam' To Write New Mixfile"
		return
	}
	foreach line [$ll2 get 0 end] {
		puts $zit $line
	}
	close $zit
	set do_parse_report 0
	if {[DoParse $fnam 0 0 0] <= 0} {
		ErrShow "PARSING FAILED FOR EDITED FILE."
		$ll2 delete 0 end
		foreach fnam $orig_vm_list {
			$ll2 inbsert end $fnam
		}
		return
	}
	if [catch {set ftype $pa($fnam,$evv(FTYP))}] {
		Inf "Cannot Find Properties Of Edited File."
		$ll2 delete 0 end
		foreach fnam $orig_vm_list {
			$ll2 inbsert end $fnam
		}
		return
	}
	if {!(($ftype & $evv(MIXFILE)) && ($ftype != $evv(WORDLIST))) } {
		Inf "Edited File Is No Longer A Valid Mixfile."
		PurgeArray $fnam
		$ll2 delete 0 end
		foreach fnam $orig_vm_list {
			$ll2 inbsert end $fnam
		}
		return
	}
	if [catch {file delete $vm_chosen_mixfile} zit] {
		Inf "Cannot Delete Original Mixfile, To Write New Data"
		catch {file delete $fnam}
		PurgeArray $fnam
		$ll2 delete 0 end
		foreach fnam $orig_vm_list {
			$ll2 inbsert end $fnam
		}
		return
	}
	if [catch {file rename $fnam $vm_chosen_mixfile} zit] {
		Inf "Cannot Save Data: Original Mixfile Lost\nOriginal Mixfile Data Is In '$fnam'\n\nSave It Now, Outside The CDP, Before Proceeding!!"
		PurgeArray $fnam
		PurgeArray $vm_chosen_mixfile
		RemoveFromChosenlist $vm_chosen_mixfile
		RemoveFromDirlist $vm_chosen_mixfile
		if {[string match $last_mix $vm_chosen_mixfile]} {
			set last_mix ""
		}
		set i [LstIndx $vm_chosen_mixfile $wl]
		if {$i >= 0} {
			$wl delete $i
			WkspCnt $vm_chosen_mixfile -1
			catch {unset rememd}
		}
		DummyHistory $vm_chosen_mixfile "LOST"
		$ll2 delete 0 end
		foreach fnam $orig_vm_list {
			$ll2 inbsert end $fnam
		}
		$ll delete $vm_i
		return
	}
	DummyHistory $vm_chosen_mixfile "EDITED"
	PurgeArray $vm_chosen_mixfile				
	RenameProps $fnam $vm_chosen_mixfile 0
	Inf "File '$vm_chosen_mixfile' Has Been Updated"
}

proc ClearSelectionListOnScore {} {
	global scoremixlist
	catch {unset scoremixlist}
	Inf "Selection Cleared"
}

proc GotoSelectNextPanel {} {
	global score_selected_panel
	if {![info exists score_selected_panel]} {
		set score_selected_panel 0
	} else {
		incr score_selected_panel
		if {$score_selected_panel == 4} {
			set score_selected_panel 0
		}
	}
	Inf "Panel To Select Is Panel [expr $score_selected_panel + 1]"
}

proc SelectCurrentPanel {} {
	global score_selected_panel scoremixlist wstk
	if {![info exists score_selected_panel]} {
		set score_selected_panel 0
	}
	set panel_no [expr $score_selected_panel + 1]
	set msg "Choose All Files On Panel $panel_no ?"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	set snds [ListFromScore $panel_no 1]
	if {[llength $snds] <= 0} {
		Inf "No Sounds Found In Panel $panel_no"
		return
	}
	if [info exists scoremixlist] {	
		set matches 0
		set origlen [llength $snds]
		set len $origlen
		set n 0
		while {$n < $len} {
			set snd [lindex $snds $n]
			set k [lsearch $scoremixlist $snd] 
			if {$k >= 0} {
				set snds [lreplace $snds $n $n]
				incr matches
				incr len -1
			} else {
				incr n
			}
		}
		if {$matches == $origlen} {
			Inf "All These Sounds Are Already Selected"
			return
		}
		set scoremixlist [concat $scoremixlist $snds]
	} else {
		set scoremixlist $snds
	}
	set msg "Files Selected\n"
	foreach item $scoremixlist {
		append msg "$item      "
	}
	Inf $msg
}

proc EditMixOnSketchScore {} {
	global vm_i

	if {![info exists vm_i] || ($vm_i < 0)} {
		Inf "No Mixfile Selected"
		return
	}
	EditSrcTextfile sketchmix
}

proc DoMixAndPlayFromSketchScore {ll ll2} {
	global vm_i wstk pa pr_scvumix2 evv

	if {![info exists vm_i] || ($vm_i) < 0} {
		Inf "No Mixfile Selected"
		return
	}
	set fnam [$ll get $vm_i]
	if {![file exists $fnam]} {
		Inf "The File '$fnam' Does Not Exist"
		return
	}
	set ftyp [FindFileType $fnam]
	if {($ftyp == -1) || ![IsAMixfile $ftyp]} {
		Inf "The File '$fnam' Is Not A Mixfile"
		return
	}
	set atten 1.0	;# DEFAULT
	set can_assess_level 1
	foreach line [$ll2 get 0 end] {
		set line [string trim $line]
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set orig_line $line
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				if {$cnt == 0} {
					set sfnam $item
					incr cnt
				} else {
					set thisstart $item
					incr cnt
				}
				if {$cnt == 2} {					
					if {![info exists pa($sfnam,$evv(DUR))]} {
						Inf "File '$fnam' Is Not On The Workspace\nCannot Assess Safe Level For Mix\n\nWarning: Using Full Level!!"
						set can_assess_level 0
					} else {
						lappend starts $thisstart
						lappend ends [expr $thisstart + $pa($sfnam,$evv(DUR))]
					}
					break
				}	
			}
		}
		if {$cnt != 2} {
			Inf "Invalid Line Encountered\n\n$orig_line"
			return
		}
		if {!$can_assess_level} {
			break
		}
	}
	if {![info exists starts]} {
		Inf "Got No Data From The Mix Display Screen"
		return
	}
	if {$can_assess_level} {
		set len [llength $starts]
		set len_less_one [expr $len - 1]
		set n 0
		set maxoverlap 0
		while {$n < $len_less_one} {
			set thisend [lindex $ends $n]
			set m $n
			incr m
			set overlapcnt 0
			while {$m < $len} {
				set thatstart [lindex $starts $m]
				if {$thatstart < $thisend} {
					incr overlapcnt
				}
				incr m
			}
			if {$overlapcnt > $maxoverlap} {
				set maxoverlap $overlapcnt
			}
			incr n
		}
		incr maxoverlap
		set atten [expr 1.0 / double($maxoverlap)]
	}
	set outfile1 $evv(DFLT_OUTNAME)
	append outfile1 "1"
	set cmd "submix mix $fnam $outfile1 -g$atten"
	lappend batch $cmd
	set outfilename $outfile1
	append outfilename $evv(SNDFILE_EXT)
	set title "Mixing MIXFILE $fnam"
	if [RunScoreTestBatchFile $batch $title] {			;# ATTEMPT TO RUN BATCHFILE
		set is_playing 0
		set msg "Score Test Mix Completed : Hear The Result ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			PlaySndfile $outfilename 0			;# PLAY OUTPUT
		}
	}
	set msg "\n   'Do The Mix And Play' And Playing Files On The Sketch Score"
	append msg "\n                                     Will Not Respond"		
	ClearTempFiles 1 $msg
	My_Grab 0 .scvumix2 pr_scvumix2 $ll
}

proc SketchGetMix {ll} {
	global vm_i wl chlist ch chcnt pr_scvumix2 pr_score

	if {![info exists vm_i] || ($vm_i < 0)} {
		Inf "No Mixfile Selected"
		raise .scvumix2
		return
	}
	set fnam [$ll get $vm_i]
	if {[LstIndx $fnam $wl] < 0} {
		if {[FileToWkspace $fnam 0 0 0 1 0] <= 0} {
			Inf "Cannot Put The File '$fnam' On The Workspace"
			raise .scvumix2
			return
		}
	}
	DoChoiceBak
	ClearWkspaceSelectedFiles
	lappend chlist $fnam
	$ch insert end $fnam
	incr chcnt
	set pr_scvumix2 0
	set pr_score 0
}

proc DeleteScore {fileId fnam} {
	global scorenameslist
	catch {close $fileId}
	if [catch {file delete $fnam} zit] {
		Inf "Cannot Delete The Score '$fnam'"
	} elseif [info exists scorenameslist] {
		set nnam [file rootname [file tail $fnam]]
		set k [string first "_" $nnam]
		incr k
		set nnam [string range $nnam $k end]
		set k [lsearch $scorenameslist $nnam]
		if {$k >= 0} {
			set scorenameslist [lreplace $scorenameslist $k $k]
			if {[llength $scorenameslist] <= 0} {
				unset scorenameslist
			}
		}
	}
}
