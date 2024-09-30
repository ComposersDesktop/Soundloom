#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#------ Display help for new users

proc DisplayUpdates {} {
	global bl pr_updates released sl_real evv columnsversion upd updend

	set f .updates
	if [Dlg_Create $f "Updates for This Release" "set pr_updates 0" -borderwidth $evv(BBDR)] {
		set fb [frame $f.butn -borderwidth $evv(SBDR)]		;#	frame for buttons
		set fc [frame $f.info -borderwidth $evv(SBDR)]		;#	frame for info
		set fl [frame $f.list -borderwidth $evv(SBDR)]		;#	frame for list
		button $fb.ok   -text "Close" -command "set pr_updates 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $fb.ok  -side top -pady 2
		label $fc.ll -text "Up/Down Keys step up/down page by a line  :  Control Up/Dn by a page  :  Control Home/End navigate to top/bottom" -fg $evv(SPECIAL)
		pack $fc.ll  -side top -pady 2
		set upd [Scrolled_Listbox $fl.list -width 120 -height 48 -selectmode single -background [option get . background {}]]
		pack $fl.list -side top						;#	Create a listbox and
		pack $f.butn $f.info $f.list -side top -fill x
		bind $f <Control-Home> {StepDownUpdates 3 0}
		bind $f <Control-End> {StepDownUpdates 2 0}
		bind $f <Down> {StepDownUpdates 1 0}
		bind $f <Up> {StepDownUpdates 0 0}
		bind $f <Control-Down> {StepDownUpdates 1 1}
		bind $f <Control-Up> {StepDownUpdates 0 1}
		bind $f <Return> {set pr_updates 0}
		bind $f <Escape> {set pr_updates 0}
		bind $f <space>  {set pr_updates 0}
	}
	set pr_updates 0
	wm resizable $f 1 1
	$upd delete 0 end
## WARNING, THIS LINE IS MODIFIED BY sloomset: DO NOT CHANGE IT'S FORMAT
	set msg	"                                                         SOUND LOOM UPDATES: VERSION 17.0.4"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      *** YOU CAN RE-ACCESS THIS INFORMATION FROM THE SYSTEM STATE MENU ON THE WORKSPACE ***"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  WORKSPACE"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      NEW BUTTON \"Display\""
	$upd insert end $msg
	set msg "                     Displays, in a separate Display Window, the CONTENTS of a TEXT FILE."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      NEW SHORTCUT KEYS"
	$upd insert end $msg
	set msg "                     (1)  If in \"Chosen Files Mode\" (Chosen Files list highlighted) \"Escape\" key will exit this mode."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                     (2)  \"Control J\" : \"GET MAXIMUM SAMPLE(s)\" from one OR MORE Selected Soundfiles."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      \"BULK PROCESS\" : Now accepts \"EDIT : add silence at start\"."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      \"ANY/ALL FILES\" menu"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   \"OTHER SPECIFIC FILES\" : \"NAME OF FILE\"  New Option  \"SOUNDS WITH NAMES STARTING WITH ..\""
	$upd insert end $msg
	set msg "                    Highlights all soundfiles whose names start with the specified string."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      \"SELECTED FILES ONLY\" menu"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (1)  \"PROPERTIES\" :  New option to find \"DURATION SUM\" of selected Soundfiles"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (2)  \"RENAME\" :  New option of \"SUBSTITUTE SUFFIXES\""
	$upd insert end $msg
	set msg "                        If files on the Chosen list have suffixes (starting with an underscore) at their ends"
	$upd insert end $msg
	set msg "                        and an equal number of files are selected on the workspace, ALSO having suffixes"
	$upd insert end $msg
	set msg "                        This option will SUBSTITUTE THE SUFFIXES from the Chosen List, for those on the workspace selected files"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (3)  \"RENAME\" :  New option of \"TRANSFER SUFFIXES\""
	$upd insert end $msg
	set msg "                        If files on the Chosen list have suffixes (starting with an underscore) at their ends"
	$upd insert end $msg
	set msg "                        and an equal number of files are selected on the workspace"
	$upd insert end $msg
	set msg "                        This option will ADD THE SUFFIXES to the workspace selected files."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (4)  \"RENAME\" :  New option of \"NAME AS CHOSEN FILE + SUFFIX\""
	$upd insert end $msg
	set msg "                        ONLY for Soundfiles."
	$upd insert end $msg
	set msg "                        Takes the rootnames (DIRECTORY PATH DISCARDED) of the files on the Chosen list,"
	$upd insert end $msg
	set msg "                        adds a suffix to the end of those names,"
	$upd insert end $msg
	set msg "                        and renames the files selected on the workspace with these new, suffixed names."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (5)  \"RENAME\" :  New option of \"NAME AS CHOSEN FILE : INCREMENT INDEX\""
	$upd insert end $msg
	set msg "                        ONLY for Soundfiles."
	$upd insert end $msg
	set msg "                        Takes the rootnames (DIRECTORY PATH DISCARDED) of the files on the Chosen list,"
	$upd insert end $msg
	set msg "                        and, IF THEY HAVE THE SAME NUMERIC SUFFIX, increments the suffix"
	$upd insert end $msg
	set msg "                        and renames the files selected on the workspace with these new names."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (6)  \"CLEAR FILES FROM WORKSPACE\" :"
	$upd insert end $msg
	set msg "                       New option to \"CLEAR BACKED-UP FILES : EXCEPT FILES ON CHOSEN LIST\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (7) \"PROPERTIES\" : \"GET MAXIMUM SAMPLE(s)\"."
	$upd insert end $msg
	set msg "                       Can now select several soundfiles at once."
	$upd insert end $msg
	set msg "                       Now immediately presents a list of selected filenames with their max levels,"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      \"SELECTED FILES OF TYPE\" menu"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (1) \"SOUNDFILES\" : \"IS SOUNDFILE IN ANY KNOWN MIXFILE?\""
	$upd insert end $msg
	set msg "                         Now allows those mixfiles to be highlighted IF they are on the Workspace."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (2) \"SOUNDFILES\" :  New option to \"PLAY ALL SNDS INDIVIDUALLY\""
	$upd insert end $msg
	set msg "                        This differs from \"PLAY ALL SOUNDS SELECTED\", which concatenates all selected files"
	$upd insert end $msg
	set msg "                        into a larger file and plays that as a single event."
	$upd insert end $msg
	set msg "                        This latter now been modified to accept any mix of mono, stereo and multichannel files."
	$upd insert end $msg
	set msg "                        However, it DOES NOT DISPLAY THE NAMES of the individual files being played."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                        The new option DOES NOT CONCATENATE THE FILES (each file-play must be triggered by a keystroke)"
	$upd insert end $msg
	set msg "                        but THE NAMES of the individual files WILL BE DISPLAYED when they play."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (3) \"SOUNDFILES\" :  New option \"PLAY MERGED CHANNELS\""
	$upd insert end $msg
	set msg "                         Takes several mono files (2 - 8) and plays as one multichannel output."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (4) \"SOUNDFILES\" :  New Option \"IS SELECTED SOUND IN SELECTED MIX?\""
	$upd insert end $msg
	set msg "                         If a Soundfile AND a mixfile are selected, checks if sound is in mix."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (5) \"TEXTFILES\" :  \"COMPARE SELECTED TEXT FILES\""
	$upd insert end $msg
	set msg "                        (a)  If a pair of MIXFILES, or a pair of MULTICHANNEL MIXFILES is selected,"
	$upd insert end $msg
	set msg "                                 new option to compare the SOUNDFILES used in one with those used in the other."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                        (b)    New Keyboard Operations allow AN ADJACENT PAIR OF LINES TO BE COMPARED"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                        (c)   New Keyboard Operations : GRAB or PLAY sound at start of Highlighted Line."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (6) \"TEXTFILES\" :  New option to \"MERGE TEXTFILES\""
	$upd insert end $msg
	set msg "                         If TWO TEXTFILES are selected, and they are of THE SAME TYPE"
	$upd insert end $msg
	set msg "                         the 2nd file can be appended to the first."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (7) \"TEXTFILES\" menu:  New option of \"IS TEXTFILE A \"BAD\" MIXFILE ?\""
	$upd insert end $msg
	set msg "                         Checks syntax of file which you believe to be a Mixfile, but the Sound Loom doesn't!!"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (8)  \"LIST OF SOUNDFILES\" : \"SNDLIST SOUNDS MOVED OR DELETED\""
	$upd insert end $msg
	set msg "                         Notes if any sound(s) in a Soundlist file has subsequently been deleted."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (9)  \"MIXFILES\" : MIXFILE SOUNDS MOVED OR DELETED"
	$upd insert end $msg
	set msg "                         Note this option only works with a textfile whose name has a mixfile extension."
	$upd insert end $msg
	set msg "                         Once a mixfile has been reclassified as a \".txt\" file (due to bad syntax),"
	$upd insert end $msg
	set msg "                          use the new option \"IS TEXTFILE A \"BAD\" MIXFILE ?\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (10) \"MIXFILES\"  : new option of \"NUMBER OF MIXLINES USING N CHANNELS\""
	$upd insert end $msg
	set msg "                         Counts number of Mono, Stereo and N-channel (active) Soundfiles used in the mix."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (11) \"MIXFILES\"  : new option of \"ARE ALL FILES IN MIXFILE BACKED-UP ?\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  CHOSEN FILES LISTING"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  (1)  KEYBOARD SHORTCUTS for a MIXFILE currently on the Chosen Files List."
	$upd insert end $msg
	set msg "                         \"Up\" and \"Down\" Arrows can now be used to GRAB SOUNDFILES INSIDE A MIXFILE to the Chosen List."
	$upd insert end $msg
	set msg "                         \"Down\" Gets ALL the soundfiles (in the order they appear in the mixfile)."
	$upd insert end $msg
	set msg "                         \"Up\" Gets all the soundfiles which are NOT CURRENTLY BACKED-UP to directories."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                 (2)  \"GET/MOD\" menu: \"MIXFILES\""
	$upd insert end $msg
	set msg "                         New option to \"GET SNDFILES IN MIXFILE TIME ORDER\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                 (3)  \"REORDER\" menu"
	$upd insert end $msg
	set msg "                         New option to \"INTERLEAVE BY PATTERN\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                 (4)  \"REORDER\" menu"
	$upd insert end $msg
	set msg "                         New option to \"INTERLEAVE BY NAME\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  DIRECTORY LISTING"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                 \"LIST\" menu: \"SEARCH BY SPECIFIED STRING\""
	$upd insert end $msg
	set msg "                         New button option in window to \"SEARCH ON NAME OF FILE SELECTED ON WORKSPACE\"."
	$upd insert end $msg
	set msg "                         Useful where directory contains \".wav\" and \".txt\",\".brk\",\".mix\" (etc) files with the same name."
	$upd insert end $msg
	set msg "                         e.g. filter, or extracted pitch data from a \"motif\" property in a Properties File."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                 \"LIST\"   :  \"SPECIFIED CHANNEL COUNT\""
	$upd insert end $msg
	set msg "                        Lists only (sound)files with the specified number of channels."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  MUSIC TESTBED"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  CLEANING KIT"
	$upd insert end $msg
	set msg "                    (A)  Once Cleaning completed, now able to \"View Output\" (and Play it) rather than simply Play it."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (B)  New Option to \"Subtract Spectrum STEREO\", cleaning a stereo-file."
	$upd insert end $msg
	set msg "                                  The stereo file is displayed, and the noise areas marked in the normal way."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)   NEW OPTION \"COMPARE SEVERAL SOUNDFILES\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (3)  EDIT MENU"
	$upd insert end $msg
	set msg "                    (A)  New option \"SLICE TO OVERLAPPING SEGMENTS\"."
	$upd insert end $msg
	set msg "                           Cuts overlapped segments of a long source, to further process."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (B)  New option \"SLICE FOR PROCESSING IN SITU\""
	$upd insert end $msg
	set msg "                            Cuts a segment from a source, together with the part of the source"
	$upd insert end $msg
	set msg "                            from zero to the segment start, and the part of the source"
	$upd insert end $msg
	set msg "                            from segment end to the end of the source,"
	$upd insert end $msg
	set msg "                            in such a way that these three items can be remixed to recreate the source."
	$upd insert end $msg
	set msg "                            Also produces the mixfile to do this recreation."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                            The segment can then be modified and the modified version used"
	$upd insert end $msg
	set msg "                            to replace the segment in the mix. In this way, the original sound is modified"
	$upd insert end $msg
	set msg "                            only at the segment, and all other events in the sound"
	$upd insert end $msg
	set msg "                            remain in their original timeframe."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                            Process can be applied to a single soundfile, or to a soundfile within a mix."
	$upd insert end $msg
	set msg "                            In the latter case, the time-segment to modify is marked in the mix-output,"
	$upd insert end $msg
	set msg "                            and then mapped to the timeframe of the sound-in-the-mix."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (C)  New option \"JOIN FILES IN RAND-PERMED SEQUENCE\""
	$upd insert end $msg
	set msg "                            Extend sounds with large-scale repeating features (like chanting crowds)"
	$upd insert end $msg
	set msg "                            by cutting individual slices of the source and using these as input to this process"
	$upd insert end $msg
	set msg "                            to generate a longer version of the original,"
	$upd insert end $msg
	set msg "                            made using random-permuted sequences of the cut segments."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (D)  New option \"EXTRACT CHANNEL PAIR\""
	$upd insert end $msg
	set msg "                                   Extract any channel PAIR from a MULTITRACK recording."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (D)  New option \"CREATE DROPOUT IN SOUND\""
	$upd insert end $msg
	set msg "                                   Produces version of source with level dropouts."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (E)  New option \"EXTEND BY RAND-PERMUTING SLICES WITHIN\""
	$upd insert end $msg
	set msg "                                   Takes a slice-edit textfile and the resulting slices"
	$upd insert end $msg
	set msg "                                   retains the first and last slice, in situ, and extends the sound centre"
	$upd insert end $msg
	set msg "                                   by randomly permuting the other slices."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (F)  New option \"REMOVE (CUT OUT) LOUD PEAKS IN SOUND\""
	$upd insert end $msg
	set msg "                                   Allows brief peaks in sound to be cut out."
	$upd insert end $msg
	set msg "                                   Works best with c. 3 successive applications."
	$upd insert end $msg
	set msg "                                   Use for editing textures like applause where some events are too close to the mike."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (G)  Extension of option \"REARRANGE A SOUNDFILE\" "
	$upd insert end $msg
	set msg "                                   Now possible to copy a chunk of a sound, and reinsert it somewhere else in the sound"
	$upd insert end $msg
	set msg "                                   WITHOUT DELETING the original chunk."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (H)  New option \"APPLY LIMITER\" "
	$upd insert end $msg
	set msg "                                   Extracts the envelope of the sound looking for peaks above a Threshold value you specify."
	$upd insert end $msg
	set msg "                                   These peaks are then compressed to a level below a Maximum that you specify."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (4)  ENVELOPES MENU (now \"ENVELOPES & LOUDNESS\")"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (A)  New option \"MAX & MIN LEVEL OF ALL SOUNDS\"."
	$upd insert end $msg
	set msg "                                  Find max & min level of all sounds amongst selected sounds"
	$upd insert end $msg
	set msg "                                  OR all sounds in a mixfile."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (B)  New option \"LOUDEST CHANNEL FOR EACH SND IN LIST\"."
	$upd insert end $msg
	set msg "                                  Lists loudest channel for each sound in a list of files."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (C)  New option \"CREATE MIX WITH SND PEAKS STAGGERED\"."
	$upd insert end $msg
	set msg "                            Creates a mixfile in which there is a fixed timestep"
	$upd insert end $msg
	set msg "                            between the peaks of successive soundfiles."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (D)  New option \"LIST SUDDEN ONSETS IN SOUND\"."
	$upd insert end $msg
	set msg "                            Detect any sudden jumps to a peak, in the sound."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (5)  MULTICHANNEL MENU"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    \"MIXMERGE\" (Currently on the Chosen Files List \"GET/MOD\" menu)."
	$upd insert end $msg
	set msg "                    added to this \"Music Testbed\" menu."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    \"MULTICHANNEL PROCESSES\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                      (A)   New option to \"PAN 8-CHANS GRADUALLY INTO 1\"."
	$upd insert end $msg
	set msg "                                     Each channel pans from its original location, around the edges of the space, to the goal channel"
	$upd insert end $msg
	set msg "                                     apart from the channel directly opposite the goal, which pans directly to the goal channel."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                      (B)   New option to \"FIND ANY MATCHING CHANNELS\"."
	$upd insert end $msg
	set msg "                                     Searches for any channels which are identical within a multichannel sound."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                      (C)   New option to \"REFORMAT TO 8-CHANNEL RING\"."
	$upd insert end $msg
	set msg "                                     Takes N mono files, or one multichannel file, and converts format to 8-channel ring."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                      (D)   New option to \"REARRANGE CHANNELS\"."
	$upd insert end $msg
	set msg "                                     Takes Any multichannel or stereo file and rearranges the order of the channels."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   \"OPERATIONS ON INDIVIDAL CHANNELS\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                       New option \"LIST ONSET SEQUENCE OF CHANNELS\"."
	$upd insert end $msg
	set msg "                            In a multichannel file which has sounds centred in the channels"
	$upd insert end $msg
	set msg "                            (i.e. there are no sounds spread between the channels)"
	$upd insert end $msg
	set msg "                            and where sounds on different channels enter at different times,"
	$upd insert end $msg
	set msg "                            as each sound enters, note ON which channel it is projected"
	$upd insert end $msg
	set msg "                            and list the (temporal) SEQUENCE OF CHANNELS."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    \"STEREO AND MULTICHANNEL\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                            (A)  New option to \"RANDORIENT STEREOPANS IN MULTICHAN\"."
	$upd insert end $msg
	set msg "                                     EITHER Converts a mixfile of stereo files (ONLY) to create new Multichannel mixfile,"
	$upd insert end $msg
	set msg "                                     OR Modifies ALL stereo files (ONLY) in a Multichannel mixfile,"
	$upd insert end $msg
	set msg "                                     and, where the stereo signals already pan across the stereo axis,"
	$upd insert end $msg
	set msg "                                     orients the panning axis in random directions, across the multichannel space."
	$upd insert end $msg
	set msg "                                     (Assumes the output multichannel format is sound-surround)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                            (B)  New option to \"STEREO WRAPAROUND IN 3-CHANNEL SURROUND\"."
	$upd insert end $msg
	set msg "                                     Takes a stereo file and creates a 3-channel output,"
	$upd insert end $msg
	set msg "                                     which wraps gradually around the space (from mono to 3-channel-width)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    \"CONVERSION TO MULTICHANNEL\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                            New option to \"TRANSFER TIMES FROM 1ST MIXFILE TO 2ND\"."
	$upd insert end $msg
	set msg "                            Allows mono-, or stereo-, file-timings to be tested in a mono or stereo mix"
	$upd insert end $msg
	set msg "                            before being retimed in a multichannel context."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    \"SPECIAL MIXES\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (A)     New option \"CREATE MIX WITH SND PEAKS STAGGERED\"."
	$upd insert end $msg
	set msg "                            Creates a mixfile in which there is a fixed timestep"
	$upd insert end $msg
	set msg "                            between the peaks of successive soundfiles."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (B)     New option to \"CREATE MIX FROM SNDFILES AND ONSET-LIST\"."
	$upd insert end $msg
	set msg "                            Creates a mixfile from a list of times, possibly extracted or created elsewhere, and ...."
	$upd insert end $msg
	set msg "                            (A)    A Single soundfile (which repeats in the mix) OR"
	$upd insert end $msg
	set msg "                            (B)    Several soundfiles, where the number of soundfiles equals the number of times in list."
	$upd insert end $msg
	set msg "                                                          If there are less sounds than times, EITHER ..."
	$upd insert end $msg
	set msg "                                                                  (a)    the later times are not used OR...."
	$upd insert end $msg
	set msg "                                                                  (b)    the sounds are cyclically repeated OR..."
	$upd insert end $msg
	set msg "                                                                  (c)    the sounds are random-ordered repeated."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (C)     New option\"STEREO TO \"STEREO\" ON LEFT OR RIGHT\""
	$upd insert end $msg
	set msg "                             Moves centre of stereo image leftward, or rightward."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (6)  PITCH OPERATIONS MENU : NEW OPTION - \"CHORDS FROM NON-VOCAL SAMPLE\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    Allows a MIDI-value-specified chord to be created over a pitched sample."
	$upd insert end $msg
	set msg "                    Values may be entered from a keyboard, an existing file, or by typing them,"
	$upd insert end $msg
	set msg "                    and need not be integers."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (7)  PROPERTIES FILES MENU : ADD NEW SOUND WITH EMPTY PROPERTIES."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    If 2 or more appropriate files are selected on the Workspace"
	$upd insert end $msg
	set msg "                    (but NOT on the Chosen Files list) this option will work immediately,"
	$upd insert end $msg
	set msg "                    without having to first add those files to the Chosen Files List."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    If there is ONLY ONE properties file on the workspace, selecting soundfiles is adequate."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (8)  SPACE DESIGN MENU"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    \"DOPPLER PAN\" Has a new option to save and load named patches, and will now run"
	$upd insert end $msg
	set msg "                    without rise and decay values (for sources which already have this built in)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (9)  NEW MENU : \"DOUBLE PROCESSES\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (A)  \"DEGRADE SOUND\""
	$upd insert end $msg
	set msg "                            Applies (user-defined) sequence of ring-modulations and waveset-distortions to an input sound."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (B)  \"RECURSIVE FILTERING\""
	$upd insert end $msg
	set msg "                            Applies (user-defined) lopass/hipass filtering, recursively, with automatic level adjustments."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (10)  NEW MENU : \"FILTER OPTIONS\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (A)  \"CONVERT PITCHFOLLOW TO HF\""
	$upd insert end $msg
	set msg "                            Converts a MIDI-type Filter Varibank file which follows pitch of signal"
	$upd insert end $msg
	set msg "                            (possibly generated automatically from \"Motif\" property entry in a \"Properties File\")"
	$upd insert end $msg
	set msg "                            into a Varibank Filter File of the Total Harmonic Field of the pitch-follower."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (B)  \"CONVERT PFOLLOW TO HF in KEY\"."
	$upd insert end $msg
	set msg "                            The same except that here a Key for the Filter data can be specified."
	$upd insert end $msg
	set msg "                            Pitches in the output datafile are confined to the triadic (+ flat 7th) notes of the specified key."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (C)    New option to PLAY THE DATA from a Fixed-Harmonic-Field MIDI-style Varibank Filter."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (D)    \"RECURSIVELY FILTER\" : Run sound TWO OR MORE TIMES through Lopass/Hipass filter."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (11)  REVERB OPERATIONS MENU"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (A)  New option \"INTERNAL STEREO DELAY\""
	$upd insert end $msg
	set msg "                            Takes a mono or stereo input file and creates output with delay between channels."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (B)  New option \"STEREO REVEAL\" MONO ->STEREO->MONO\""
	$upd insert end $msg
	set msg "                            Cause stereo sound to emerge from a mono mix in one channel only,"
	$upd insert end $msg
	set msg "                            and/or merge to a mono mix in the same or the other channel."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (C)  New option \"DISTORT REVERB\""
	$upd insert end $msg
	set msg "                            Cause mono sound to cross into a distorted reverberated version."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	if {[info exists released(fastconv)]} {
		set msg "                    (D)  New option \"FAST CONVOLUTION\""
		$upd insert end $msg
		set msg "                            Fast Convolution of two mono, or two stereo sounds."
		$upd insert end $msg
		set msg "      "
		$upd insert end $msg
	}
	set msg "      (12)  PARTITION SOUNDFILES"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                     \"Help\" button added."
	$upd insert end $msg
	set msg "                     \"Escape\" and \"Return\" Keys now function as intended ..."
	$upd insert end $msg
	set msg "                     \"Escape\" =  \"Abandon Partitions\"."
	$upd insert end $msg
	set msg "                     \"Return\" =  \"Keep Partitions So Far\"."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (13)  PATTERNING OPERATIONS"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (A)  New options for \"DETECT, EXTEND OR SYNC-WITH ONSETS\""
	$upd insert end $msg
	set msg "                            (a)   Detect times of sudden onsets within a sound-A -> create list of ONSET-TIMES."
	$upd insert end $msg
	set msg "                            (b)   Convert ONSET-TIMES to SPLICE-TIMES to chop sound-A at onsets -> SOUND-SLICES"
	$upd insert end $msg
	set msg "                            (c)   Use ONSET-TIMES and SOUND-SLICES (from (b)) to internally extend sound-A."
	$upd insert end $msg
	set msg "                            (d)   Use ONSET-TIMES and one or more OTHER SOUNDS, to create a stream of those other sounds,"
	$upd insert end $msg
	set msg "                                          SYNCHRONISED to the original sound."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (14)  PLAY OPTIONS"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                     NEW OPTION \"PLAY PART OF MULTICHAN SND\" : segment of a multichannel file can be played."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                     NEW OPTION \"PLAY SINGLE CHANNEL OF SND\" : Play selected channel of a stereo or multichannel sound."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                     NEW OPTION \"PLAY STEREO IN WIDE MULTICHAN\" : Play on selected channel-pair in Multichannel setup."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (15)  RHYTHM AND TIME OPERATIONS MENU"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                     NEW OPTION \"SYNC FILES TO TIMEMARKS BY SILENCEPADS\""
	$upd insert end $msg
	set msg "                            Two or more soundfiles are graphically displayed successively,"
	$upd insert end $msg
	set msg "                            and the attack peak of each marked on the display."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                            Files with attack peaks earlier than the latest of these attack peaks"
	$upd insert end $msg
	set msg "                            are then padded with initial silence, so that the output files"
	$upd insert end $msg
	set msg "                            all have synchronous attack peaks."
	$upd insert end $msg
	if {[info exists released(clicknew)]} {
		$upd insert end $msg
		set msg "      "
		$upd insert end $msg
		set msg "                     NEW OPTION \"CREATE CLICKTRACK OVER SOUND OR FROM TEXTLIST\""
		$upd insert end $msg
		set msg "                            Creates a clicktrack soundfile either from a text listing of times,"
		$upd insert end $msg
		set msg "                            OR by displaying a sound, and marking the click times on the display."
		$upd insert end $msg
		set msg "                            In the latter case, a soundfile AND a textfile (of click timings) is output."
		$upd insert end $msg
		set msg "      "
		$upd insert end $msg
	}
	set msg "      "
	$upd insert end $msg
	set msg "      (16)  TEXT OPERATIONS : New options"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (A)  \"GENERATE PHRASES FROM WORDLISTS\""
	$upd insert end $msg
	set msg "                            takes a set of files containing lists of words of different grammatical types"
	$upd insert end $msg
	set msg "                            and generates phrases by random permutation of these words."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (B)  \"ALPHABETIC SORT AND REMOVE DUPLICATES\" takes wordlists for use in (A)"
	$upd insert end $msg
	set msg "                            and sorts the words into alphabetical order, eliminating any duplicates found."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (C)  \"CONFLATE (& POSSIBLY RE-SORT) TEXTLINES IN FILES\" takes list of texts in textfiles"
	$upd insert end $msg
	set msg "                            and merges the lists, re-sorting the final merged list."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (D)  \"ELIMINATE TEXTS COMMON TO DIFFERENT FILES\" takes list of texts in textfiles"
	$upd insert end $msg
	set msg "                            and, if the same text is listed in different files,"
	$upd insert end $msg
	set msg "                            that text is deleted from all but the shortest of the files which list it."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (E)  \"CHECK BAD CHARS IN NON-GRABBED TEXTFILE\""
	$upd insert end $msg
	set msg "                            If a textfile fails on a \"Grab\" from the Directory Listing"
	$upd insert end $msg
	set msg "                            (on RHS of Workspace), check if it contains invalid characters."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg

	set msg "                    (F)  \"FIND REPEATED WORDS : PARTITION TEXTS TO FILES\""
	$upd insert end $msg
	set msg "                            Display groups of lines that share similar words,"
	$upd insert end $msg
	set msg "                            either shared first words, shared last words, or any words."
	$upd insert end $msg
	set msg "                            Partition lines amongst files to minimise word-repetition in each file."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (G)  \"MARK & EXTRACT ITEMS FROM TEXTS LIST\""
	$upd insert end $msg
	set msg "                            allows phrases generated by (A) to be selected, by adding a \"*\""
	$upd insert end $msg
	set msg "                            and these starred phrases to be extracted to another text listing."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (H)  \"CATEGORISE & EXTRACT ITEMS FROM TEXTS LIST\""
	$upd insert end $msg
	set msg "                            Assign text-lines in a textfile to different categories."
	$upd insert end $msg
	set msg "                            Extract each category of lines to a different output file."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (I)  \"SPECIFY ORDER & REORDER TEXTS IN A TEXTS LIST\""
	$upd insert end $msg
	set msg "                            Number the lines in a list of text-lines in any desired order."
	$upd insert end $msg
	set msg "                            Extract the lines, in numbered order, to a different output file,"
	$upd insert end $msg
	set msg "                            with or without the line-numberings."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (J)  \"REORDER PRE-NUMBERED TEXTS\""
	$upd insert end $msg
	set msg "                            Extract the lines, in numbered order, to a different output file."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (K)  \"ASSEMBLE TEXT-LINES TO A CONTINUOUS TEXT\""
	$upd insert end $msg
	set msg "                            Extract text-lines from a textfile, and reassemble them"
	$upd insert end $msg
	set msg "                            as a continuous text, with possible paragraph breaks, to a new file."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	append msg "\n"
	set msg "                    (L)  \"COUNT SYLLABLES : ASSESS SPOKEN DURATION\""
	$upd insert end $msg
	set msg "                            Count syllables in a textfile list of words."
	$upd insert end $msg
	set msg "                            Words may incorporate \"-\" or \"_\" but NOT numbers, quotation marks,or punctuation."
	$upd insert end $msg
	set msg "                            Counting assumes \"ious\" or \"ient\" are single syllables, but \"crying\" is two."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (M)  \"GROUP PHRASES FROM TWO OR MORE TEXTFILES\""
	$upd insert end $msg
	set msg "                            Takes two (or more) textfiles listing phrases and generates random groupings in format ...."
	$upd insert end $msg
	set msg "                            (for 2 input files) \"file-1-phrase  :  file-2-phrase\""
	$upd insert end $msg
	set msg "                            (for 3 input files) \"file-1-phrase  :  file-2-phrase  :  file 3 phrase\"   ETC."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (N)  \"LINK PAIRED PHRASES\""
	$upd insert end $msg
	set msg "                            Takes paired phrases from a paired-phrase textfile (see above)"
	$upd insert end $msg
	set msg "                            and a set of linking phrases in any combination of textfiles named .."
	$upd insert end $msg
	set msg "                            \"prelink\", \"midlink\", \"postlink\", or \"inverselink\","
	$upd insert end $msg
	set msg "                            and join the phrases together with the linking texts."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  PROCESS PAGE"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      \"MULTICHAN\"  :  \"MULTICHANNEL STAGING\""
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (1)     New menu item allows RENAMING of multichan-staging and stereo-reduction formats"
	$upd insert end $msg
	set msg "                            independently of the name of the input or output soundfile."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    (2)     The Restaging Formats created can now be RENAMED."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  PARAMETERS PAGE"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (0)  Active \"Sound View\" button added to all \"LOOP\" processes"
	$upd insert end $msg
	set msg "                            enabling (initial) Loop Segment (start time and length) to be specified graphically."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  Active \"Sound View\" button added to \"SOUND INFO\" \"maximum sample in timerage\" process"
	$upd insert end $msg
	set msg "                            enabling timerange to be specified graphically."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)  When \"CHANNELS\" -> \"Extract All Channels\" is used and \"Generic Output Name\" is selected, followed by \"Return\","
	$upd insert end $msg
	set msg "                            creates, by default, names \"name_c1\", \"name_c2\" etc where \"name\" is the name of the input file."
	$upd insert end $msg
	set msg "                            A new option, \"Numbered Channels\", appears which can be used to switch off/on the automatic rename"
	$upd insert end $msg
	set msg "                            before \"Return\" is hit."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (3)  If \"Generic Rename\" is selected for multiple outputs from a process which has ONLY ONE input file,"
	$upd insert end $msg
	set msg "                            the Generic name defaults to the name of the input file" 
	$upd insert end $msg
	set msg "                            plus an underscore and numbers running from 1 upwards."
	$upd insert end $msg
	set msg "                            Hence, a \"Return\" on the keyboard delivers this new default option."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (4)  If you attempted to immediately rerun a program with EXACTLY THE SAME PARAMETERS,"
	$upd insert end $msg
	set msg "                           your command was queried."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                           WITH A MIXFILE you will often want to rerun the same mix process, with a modified mixfile,"
	$upd insert end $msg
	set msg "                           BUT with the same parameters. So in this case NO WARNING DIALOGUE now appears."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                           If you are NOT running a mix, the dialogue window default response is now \"No\""
	$upd insert end $msg
	set msg "                           (meaning you don't want to rerun exactly same process), so a \"Return\" does NOT rerun the process."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (5)   \"Sound View\" Specification of RANGE"
	$upd insert end $msg
	set msg "                           Range specifying dialogue box modified ...."
	$upd insert end $msg
	set msg "                           (1)  True \"Bottom of Range\" now shown (rather than always zero)"
	$upd insert end $msg
	set msg "                           (2)  Toggle buttons to insert EITHER True Minimum OR 1.0, as bottom of range."
	$upd insert end $msg
	set msg "                                        (1.0 useful when parameter is loudness curve to amplify, but not attenuate, source)"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (6)  ONLY WHEN RUNNING A MIX : \"Control Q\" takes you to the \"QIK EDIT\" page,"
	$upd insert end $msg
	set msg "                           and DOING THIS TWICE takes you to the \"VIEW OUTPUT\" graphic display of the mix output."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (7)  ONLY WHEN RUNNING A MIX : If the Mix End Time is beyond the Permissible Range,"
	$upd insert end $msg
	set msg "                           \"Return\" automatically resets it to the range maximum (without a User Query)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (8)  ONLY WHEN ENTERING NUMERIC PARAMETERS : \"mS\" or \"ms\" at the end of a numeric value"
	$upd insert end $msg
	set msg "                           will read the numeric value as milliseconds, and convert automatically to seconds."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (9)  ONLY WHEN RUNNING \"EXTEND\" \"ZIGZAG\" \"USER SPECIFIED\""
	$upd insert end $msg
	set msg "                           When creating a control file from \"Make File\", the Control-1 function button on the keyboard"
	$upd insert end $msg
	set msg "                           will add both time zero (at the start of a created list) and the file duration (at end of the list)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  RUN WINDOW"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)   On running a MIX or a MULTICHANNEL MIX the window NO LONGER WAITS FOR YOU TO HIT \"OK\" after the run,"
	$upd insert end $msg
	set msg "                           EITHER returning directly to the parameters page, OR (for incomplete mix) curtailing the mix,"
	$upd insert end $msg
	set msg "                           then returning directly to the parameters page."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  INSTRUMENTS"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  The \"Sound View\" option is now available during Instrument Creation."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)  Any instruments with the string \"stereo\" in its name, now offers an option"
	$upd insert end $msg
	set msg "                    to assign a control file, selected or created, to two adjacent parameters within the instrument."
	$upd insert end $msg
	set msg "                    Thus a stereo time-stretch instrument (needing a stretch-factor for each channel)"
	$upd insert end $msg
	set msg "                    can be assigned the same file for both channels."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  QIKEDIT"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  PAGE TITLE NOW DISPLAYS THE START-TIME OF THE MIX (IF THIS IS NOT ZERO)"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)  SPACE-BAR TO PLAY : If NO SOUND IS SELECTED..."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   will play the current (or previous) MIX OUTPUT, it if exists."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (3)  \"REROUTE\" MENU: NEW MULTIPAN OPTION for stereo sources in 8 channel mixfiles."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   Data in the form of two equal-length strings of integers, separated by a comma e.g. \"123,468\""
	$upd insert end $msg
	set msg "                   routes channel 1 of the source to the output channels in the 1st string"
	$upd insert end $msg
	set msg "                   (i.e. in the example, input 1 to outputs 1,2 and 3)"
	$upd insert end $msg
	set msg "                   and channel 2 of the source to the channels in the 2nd string"
	$upd insert end $msg
	set msg "                   (i.e. in the example, input 2 to outputs 4,6 and 8)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (4)  NEW BUTTONS \"SHOW STEREO\" : \"SHOW MONO \" (NOT available with multichannel mixes)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   Highlight all active stereo (mono) files in the mix listing."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (5)  \"SEE PAN\": NEW BUTTON (appears only with 8-channel mixes)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   Feature for use with 8 channel mixfiles containing stereo sounds that pan."
	$upd insert end $msg
	set msg "                   The mixfile data can be sorted into the time order of panning-events" 
	$upd insert end $msg
	set msg "                   (which may not correspond to the time order of the soundfile entries)" 
	$upd insert end $msg
	set msg "                   and the panning directions then displayed graphically."
	$upd insert end $msg
	set msg "                   The function assumes that the original pan events are from Left to Right."
	$upd insert end $msg
	set msg "                   Files which do not pan can be set to \"Ignore\" by the ordered pan listing."
	$upd insert end $msg
	set msg "                   Otherwise, non-stereo files are indicated by a closed curve linking the outputs used."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (6)  Call to \"Calculator\" puts any NUMERIC value in the QikEdit \"Value\" box into the \"VALUE\" box of Calculator."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (7)  \"Control Q\" takes you to \"VIEW SOUND\" (displays output of mix)."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (8)  \"MAXGAIN OF SOUND IN LINE (FORCE)\" new option in \"PARAM(S) IN LINE\" menu."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   Sometimes imported files have header formats incompatible with the CDP"
	$upd insert end $msg
	set msg "                   and attempts to read \"MAXGAIN OF SOUND IN LINE\" give anomalous results."
	$upd insert end $msg
	set msg "                   The new menu option re-calculates the Max Gain data, but may not rewrite the header."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (9)  NEW SHORTCUT KEYS."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   Control s,S ...... Get START time of highlighted line to Value box"
	$upd insert end $msg
	set msg "                   Control a,A ...... ADD START time of highlighted line to value in Value box"
	$upd insert end $msg
	set msg "                   Control e,E ...... Get END time of line to Value box"
	$upd insert end $msg
	set msg "                   Control g,G ...... Get maximum possible GAIN for sound in line, to Value box"
	$upd insert end $msg
	set msg "                   Control n,N ...... Get NUMBER of highlighted line to Value box"
	$upd insert end $msg
	set msg "                   Control h,H ...... HIGHLIGHT line whose line-number is in Value box (cursor in Value Box)"
	$upd insert end $msg
	set msg "                   Command b,B ........... Highlight All Active lines BELOW currently Highlighted line(s)."
	$upd insert end $msg
	set msg "                   Command p,P ........... Highlight All lines PLAYING at time in Value Box."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (10)  NEW BUTTON \"EXPAND TIMES AT\"."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   Insert equivalent of a bar of silence before each highlighted line."
	$upd insert end $msg
	set msg "                   Duration of all inserted silences is taken from the QikEdit \"Value\" box."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (11)  BUTTON \"GET POSITION\" NOW AVAILABLE WITH ORDINARY MIXFILES (as well as multichannel mixfiles)"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (12)  NEW OPTION IN \"PARAM(S) IN LINE\"  :  GET \"END TIME OF ENTIRE MIX\" TO THE VALUE BOX"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (13)  \"ALL MUTED TO END\"  now SORTS MUTED LINES INTO TIME ORDER before moving them to end."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (14)  NEW OPTIONS IN \"SELECT LINES\"  :  \"STRING IN \"Value\" BOX\""
	$upd insert end $msg
	set msg "                  (a)  \"FILENAME CONTAINS STRING IN \"Value\" BOX\""
	$upd insert end $msg
	set msg "                  (b)  \"FILENAME-SEGMENT STARTS WITH STRING  IN \"Value\" BOX\""
	$upd insert end $msg
	set msg "                  (a)  \"GET FILENAME TO \"Value\" BOX"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (15)  NEW BUTTON OPTIONS WITH \"Value\" BOX."
	$upd insert end $msg
	set msg "                  (a)  \"Last\" Button restores previous value  in \"Value\" Box (IF there is one)."
	$upd insert end $msg
	set msg "                  (b)  \"Up\" Increments value in \"Value\" Box, IF it is numeric."
	$upd insert end $msg
	set msg "                  (a)  \"Dn\" Decrements value in \"Value\" Box, IF it is numeric."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  PROPERTIES FILES"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  Better \"HELP\" Information for copying, and moving Properties from one sound to another."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)  If \"MOTIF\" property files are generated in a specific directory, they are now automatically remembered"
	$upd insert end $msg
	set msg "                   so that they will be listed for potential backing-up at the end of your session."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (3)  When entering a Motif on the staff-lines, \"Play Both\" now works even if source is stereo."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (4)  Automatic generation of \"HF\" (Harmonic Field) property from \"MOTIF\" if \"HF\" property is added later."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   If both property names exist from the outset, \"HF\" is automatically generated when a \"Motif\" is entered."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                   If \"Motif\" but not \"HF\" already exists, the \"HF\" property can be added."
	$upd insert end $msg
	set msg "                   Then, on the Property page display, Command-Shift-Control-Click on an \"HF\" property box"
	$upd insert end $msg
	set msg "                   and, on the window which comes up, click on the button \"HF from Motif\"."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (5)  On the property file display, when a sound is selected to PLAY or VIEW"
	$upd insert end $msg
	set msg "                    the interface now REMEMBERS the (last) sound selected and RECOLOURS the play(view) button."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (6)  When adding properties to an existing properties file (Shift-Control-Command-Click on property box)"
	$upd insert end $msg
	set msg "                    the window now includes a LARGE KEYBOARD to allow (MIDI) pitch values to be entered."
	$upd insert end $msg
	set msg "                    Keys in the central octave (marked in blue) play the appropriate pitches."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (7)  When displaying a Harmonic Field (HF) property, using Shift-Command-Click,"
	$upd insert end $msg
	set msg "                    and using the \"Play\" button in the Harmonic Field display to play it,"
	$upd insert end $msg
	set msg "                    if the SOUNDFILE RELATED TO THE HF values does not yet exist"
	$upd insert end $msg
	set msg "                    you are offered the option to CREATE IT."
	$upd insert end $msg
	set msg "                    Click on \"Play\" a 2nd time to play the newly created soundfile."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (8)  When ENTERING MOTIF PROPERTY, there are now TWO \"Sound View\" buttons,"
	$upd insert end $msg
	set msg "                    (1)  \"SVSetTime\" allows note-timings to be (re)entered over a graphic of sound."
	$upd insert end $msg
	set msg "                    (2)  \"Sound View\" allows the sound to be viewed (to assess pitches) without erasing timing data."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (9)  When ENTERING MOTIF PROPERTY, and the \"Play\" buttons are used with a \"STOP\" button window,"
	$upd insert end $msg
	set msg "                    the Play Window now appears BELOW the pitch-stave display, so the notes on the stave can still be read."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (10)  If any property is an INTEGER lying within the MIDI range (0 - 127)"
	$upd insert end $msg
	set msg "                    \"Control-Command-Click\" will now play a pitch-class equivalent."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  SOUND VIEW WINDOWS"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  Reference Pitch play button \"A\" modified to a drop-down menu to PLAY ANY OF 12 TEMPERED PITCHES."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)  \"TAB\" Key can now be used to Remove or Restore the \"Play\" Box."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  TEXT VIEW WINDOWS"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  \"GRAB\" with \"Control-G\" will now handle more than one highlighted line."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  TABLE EDITOR"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  \"TABLES\" \"SPECIFIC DATA TYPES\" \"VARIBANK FILTERS\""
	$upd insert end $msg
	set msg "                    NEW OPTION to Convert Pitches in a MIDI Varibank data file to a MIDI list"
	$upd insert end $msg
	set msg "                    which can be SYNTHESIZED AS A CHORD using \"synth\" \"chord\"."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)  \"TABLES\" \"DERIVE EDIT DATA FROM LISTED TIMINGS\""
	$upd insert end $msg
	set msg "                    NEW OPTION to Convert Time list (of sound sudden-onsets) to"
	$upd insert end $msg
	set msg "                    an  \"EDIT SLICE\" File for chopping file apart at onsets.."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	if {[info exists columnsversion] && ($columnsversion >= 7)} {
		set msg "      (3)  \"RAND\" New Version of \"N COPIES, EACH ORDER-RANDOMISED\""
		$upd insert end $msg
		set msg "                    where the process is \"SWITCHING BETWEEN MEMBERS OF 1ST HALF AND 2ND HALF OF SET\""
		$upd insert end $msg
		set msg "                    e.g. If your set is a list of 8 output channels and you wish to do a random pan"
		$upd insert end $msg
		set msg "                     BUT have alternate pan-positions in one half (or the other half) of the set of channels,"
		$upd insert end $msg
		set msg "                     this option will do this."
		$upd insert end $msg
		set msg "      "
		$upd insert end $msg
	}
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  END OF SESSION BAKUP TO EXTERNAL STORAGE"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  Window now displays the SIZE IN MEGABYTES of the data to be stored."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)  MORE THAN TWO Bakups to Memory Stick are now possible."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "  BUG FIXES AND IMPROVEMENTS"
	$upd insert end $msg
	set msg "  --------------------------------------"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (1)  VIEWING VERY LONG SOUNDFILES AS A WAVEFORM GRAPHIC by ..."
	$upd insert end $msg
	set msg "                (a)   DOUBLE-CLICKING on a listed soundfile on the Workspace"
	$upd insert end $msg
	set msg "                (b)   Using \"VIEW SOUND OR TEXTFILE\" on Workspace menu \"FILES OF TYPE\""
	$upd insert end $msg
	set msg "                (c)   Using the \"View\" button on the far right of the Parameter Page, to view the Process Output"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                    there can be a significant delay while the graphic is being created."
	$upd insert end $msg
	set msg "                    In this situation a WAIT message, \"CREATING WAVEFORM DISPLAY\", now appears."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (2)  FOR USERS WHO HAD NOT DOWNLOADED THE \"NESS\" PHYSICAL MODELLING PROGRAMS"
	$upd insert end $msg
	set msg "                    the Table Editor refused to open files, giving an error message."
	$upd insert end $msg
	set msg "                    Problem fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (3)  IF \"SHORT WINDOWS\" WAS SET, INSTRUMENTS COULD BE CREATED, BUT NOT RUN"
	$upd insert end $msg
	set msg "                    Problem fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (4)  MUSIC TESTBED \"FOF RECONSTRUCTION\":"
	$upd insert end $msg
	set msg "                    \"More Information\" added on submenus, to explain how to use this."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (5)  QIKEDIT MIXFILE EDITOR"
	$upd insert end $msg
	set msg "                    (a) Using \"VIEW SOUND\" on the Mix output to mark a TIME, when the mix start was not zero,"
	$upd insert end $msg
	set msg "                           gave an anomalous (doubled) result in some situations. Fixed."
	$upd insert end $msg
	set msg "                    (b) Using \"UNMUTE\" to unmute Muted lines, where any one of the muted files no longer existed,"
	$upd insert end $msg
	set msg "                           returned correctly, without doing the unmuting, but GAVE NO INDICATION OF WHY : Fixed."
	$upd insert end $msg
	set msg "                    (c) Inserting a new file with \"ADD NEW FILE (AT)\" or \"... LAST MADE (AT)\","
	$upd insert end $msg
	set msg "                           IF inserted at the time of a Hilighted Line, AND this line was followed by MUTED lines,"
	$upd insert end $msg
	set msg "                           sometimes caused the Inserted file to insert AFTER all the muted lines : Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (6)  PHYSICAL MODELLING"
	$upd insert end $msg
	set msg "             (a)  Error generated if physical modelling files (extension \".m\") were placed on the Chosen Files list"
	$upd insert end $msg
	set msg "                          and \"PROCESS\", \"BULK PROCESS\" or \"INSTRUMENT\" selected. Fixed."
	$upd insert end $msg
	set msg "                          (Physical Modelling files can only be used through the \"MUSIC TESTBED\".)"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "             (b)  Error generated if Valve-creation was attempted before the instrument shape had been defined. Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (7)  \"CREATE MIXFILE WITH TIMESTEP\" : Using \"Sound View\" to view the 1st of the sounds being processed,"
	$upd insert end $msg
	set msg "                    the TIME-STEP VALUE may now be ENTERED WITH A MOUSE-CLICK on the Sound display graphic."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (8)  \"VARIBANK\" : Using \"Sound View\"."
	$upd insert end $msg
	set msg "                    In \"Make File\" : decoupled from \"Standard Features\" / \"Delete Features\" button"
	$upd insert end $msg
	set msg "                                             so these can still be used when \"Sound View\" generates the data."
	$upd insert end $msg
	set msg "                    In \"Get File\" : times (only) can now be added to an existing filter file, correctly."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (9)  CLEANING KIT"
	$upd insert end $msg
	set msg "              (a)   After running a cleaning process, if you hit \"Return\", instead of hitting \"Keep Output\" or \"Abandon\","
	$upd insert end $msg
	set msg "                    this hung the Loom. Fixed"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "              (b)   Filtering Processes often filtered the entire file, instead of just the specified locations. Fixed"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (10)  \"PROPERTIES FILES\" : \"ADD SOUNDS TO ...\""
	$upd insert end $msg
	set msg "                    If all the sounds in the Properties File are not on workspace, The Soundloom asks if you want to load them."
	$upd insert end $msg
	set msg "                    The default to a carriage-return reponse is now  \"No\"."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (11)   \"Sound View\" QUANTISATION"
	$upd insert end $msg
	set msg "                    Quantisation was prevented if the quantisation value was greater than the parameter's upper limit."
	$upd insert end $msg
	set msg "                    However, this could prevent quantisation of negative values (e.g. if range top was zero). Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (12)  BULK PROCESS : PARAMETERS PAGE : PLAY OUTPUT (When there are several files to play)"
	$upd insert end $msg
	set msg "                    Failed to list available files, and gave an error.  Fixed"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (13)  MUSIC TESTBED : MULTICHANNEL PROCESSING : FIND OR REMOVE EMPTY CHANNELS"
	$upd insert end $msg
	set msg "                    Failed.  Fixed"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (14)  PROPERTIES FILES"
	$upd insert end $msg
	set msg "                    When altering an existing Harmonic Field (HF) property, using Shift-Command-Click, and Graphic Entry,"
	$upd insert end $msg
	set msg "                    error occurred, freezing Loom. Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (15)  COMPARE FILES"
	$upd insert end $msg
	set msg "                    Files containing same lines, but with line-repetitions in one file and not the other,"
	$upd insert end $msg
	set msg "                     were declared identical. Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (16)  SOUND VIEW : ENTRY OF BREAKPOINT VALUES"
	$upd insert end $msg
	set msg "                    Truncation of values of form \"-n.9m\" where \"m\" was greater than 5 gave false results. Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (17)  SOUND VIEW : TOGGLING PLAY BOX TO LEFT OR RIGHT (Command-Control-Click)"
	$upd insert end $msg
	set msg "                    Endtimes of playbox were not rewritten. Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (18)  MUSIC TESTBED  :  EDITING OPERATIONS  :  REARRANGE A SOUNDFILE"
	$upd insert end $msg
	set msg "                    Error in placement of reinserted segment if cut from a time BEFORE reinsertion time : Fixed"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (19)  MUSIC TESTBED  :  PLAY OPTIONS  :  PLAY GROUPS MULTICHANNEL"
	$upd insert end $msg
	set msg "                    Rejected multichannel files as input : Fixed"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (20)  MUSIC TESTBED  :  REVERB OPERATIONS  :  CREATE REVERB ON SOUND TAIL"
	$upd insert end $msg
	set msg "                    (a)  Now remembers the previously used params for the position of the segment to reverb."
	$upd insert end $msg
	set msg "                            Useful if adding reverb to related files (e.g. individual channels of a multichan sound)."
	$upd insert end $msg
	set msg "                    (b)  After saving the output, no longer automatically quits, so you can try other reverb values."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (21)  CHOSEN FILES LIST  :  REORDER  :  INTERLEAVE"
	$upd insert end $msg
	set msg "                    Interleaving of \"abcd\" produced \"bdac\" and not \"acbd\" : Fixed"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (22)   ANY WORKSPACE OR CHOSEN-FILE-LIST MENU-ITEM WHICH ADDS OR CHANGES FILES WITHIN A MIXFILE."
	$upd insert end $msg
	set msg "                     The DURATION of the Mixfile is now UPDATED so that the MIX page behaves properly."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "      (23)   MULTI-CHANNEL STAGING"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  IMPROVEMENTS"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                      Naming the Restaging FORMAT is now AUTOMATICALLY OFFERED with \"Arrange on Multiphonic Stage\""
	$upd insert end $msg
	set msg "                               as is already the case with \"Collapse to Stereo Panorama\"."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                  BUGS"
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                      (a)   \"COLLAPSE TO STEREO\" : Setting the relative levels of input channels not functioning : Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                     (b)   The format-changing mixes created were not entered into the Mix-Management scheme."
	$upd insert end $msg
	set msg "                             Hence if the soundfile-in-the-mixfile was backed up, or moved to a new directory,"
	$upd insert end $msg
	set msg "                             the format-changing mix was not updated and failed to be recognised as a valid mixfile: Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "                     (c)   After creating the re-staging mixfile, the mix would fail to run from the Process Page"
	$upd insert end $msg
	set msg "                             if it was sent IMMEDIATELY to the Chosen Files List."
	$upd insert end $msg
	set msg "                              (A different type of File had to be sent to the Process Page first) : Fixed."
	$upd insert end $msg
	set msg "      "
	$upd insert end $msg
	set msg "        *** YOU CAN RE-ACCESS THIS INFORMATION FROM THE SYSTEM STATE MENU ON THE WORKSPACE ***"
	$upd insert end $msg
	set updend [$upd index end]
	raise $f
	Simple_Grab 0 $f pr_updates $upd
	tkwait variable pr_updates
	Simple_Release_to_Dialog $f
	destroy $f
}

proc CutNUH {} {
	global newmac cutmac evv
	if {[info exists cutmac]} {
		Inf "New User Help Is Already Turned Off"
		raise .welcome9
		return
	}
	set msg "Are You Sure You Want To Turn Off New User Help ??"
	set choice [tk_messageBox -type yesno -icon warning -message $msg]
	if {$choice == "no"} {
		return
	}
	set fnam [file join $evv(CDPRESOURCE_DIR) newmac$evv(CDP_EXT)]
	if {![catch {open $fnam "w"} zit]} {
		puts $zit 0
		close $zit
	}
	catch {unset newmac}
	set cutmac 1
	Inf "New User Help turned OFF"
	raise .welcome9
}

proc StepDownUpdates {down page} {
	global upd updend
	set viewstep 36
	set inc 1
	if {$page} {
		set inc $viewstep
	}
	set k [$upd curselection]
	switch -- $down {
		1 {
			if {$k < 0} {
				set k 0
			} elseif {$k < [expr $updend - 1]} {
				incr k $inc
				if {$k >= $updend} {
					set k [expr $updend - 1]
				}
			}
			$upd selection clear 0 end
			$upd selection set $k
		}
		0 {
			if {$k < 0} {
				set k $updend
			} elseif {$k > 0} {
				incr k -$inc
				if {$k < 0} {
					set k 0
				}
			}
			$upd selection clear 0 end
			$upd selection set $k
		}
		2 {
			set k [expr $updend - 1]
			$upd selection clear 0 end
			$upd selection set $k
		}
		3 {
			set k 0
			$upd selection clear 0 end
			$upd selection set $k
		}
	}
	set jj [expr $k/$viewstep]
	set jj [expr $jj * $viewstep]
	$upd yview moveto [expr double($jj)/double($updend)]
}
