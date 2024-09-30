#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD June 30 2013
# ... fixup button rectangles

#################
# NEW USER HELP #
#################

#------ Display help for new users

proc GetNewUserHelp {where} {
	global bl kill_starthelp do_starthlp startemph sl_real evv

	set f .starthelp
	if [Dlg_Create $f "New User Help" "set kill_starthelp 0" -borderwidth $evv(BBDR)] {
		set fb [frame $f.butn -borderwidth $evv(SBDR)]		;#	frame for buttons
		set fl [frame $f.list -borderwidth $evv(SBDR)]		;#	frame for list
		button $fb.ok   -text "Continue"   -command "set kill_starthelp 0" -bg $startemph -highlightbackground [option get . background {}]
		button $fb.kill -text "Abandon ALL New User Help" -command "set kill_starthelp 1; set do_starthlp 0" -highlightbackground [option get . background {}]
# MOVED TO LEFT
		pack $fb.ok  -side left
		pack $fb.kill -side right
# MOVED TO LEFT
#		pack $fb.ok  -side right
#		pack $fb.kill -side left
		set bl [Scrolled_Listbox $fl.list -width 80 -height 32 -selectmode single]
		pack $fl.list -side top						;#	Create a listbox and
		pack $f.butn $f.list -side top -fill x
		bind $f <Escape>  {set kill_starthelp 0}
		bind $f <Return>  {set kill_starthelp 0}
		bind $f <Key-space>  {set kill_starthelp 0}
	}
	wm resizable $f 1 1

	if [string match  $where "finish"] {
		bind .starthelp <ButtonRelease-1> {RaiseWindow %W %x %y}
		.starthelp.butn.ok config -text "End Session" -command "set kill_starthelp 0" -bg $evv(QUIT_COLOR)
		bind $f <Control-Command-Escape> "set kill_starthelp 0"
		.starthelp.butn.kill config -text "" -state disabled -borderwidth 0
	} else {
		bind .starthelp <ButtonRelease-1> {HideWindow %W %x %y kill_starthelp}
		bind $f <Command-Escape> {}
	}
	$bl delete 0 end
	switch -- $where {
		start {
			if {$evv(REDESIGN)} {
				set msg "REDESIGNING THE SOUND LOOM INTERFACE"
				$bl insert end $msg
				set msg ""
				$bl insert end $msg
				set msg "In some previous session, you selected 'Redesign' on the workspace."
				$bl insert end $msg
				set msg "This page lets you change colors and fonts on the Sound Loom interface."
				$bl insert end $msg
				set msg ""
				$bl insert end $msg
				set msg "If you're happy with the design, as it stands, exit with 'Forget redesign: Quit'"
				$bl insert end $msg
				set msg ""
				$bl insert end $msg
				set msg "If you change the design and want to keep the changes, press 'Keep new design'"
				$bl insert end $msg
				set msg "You can reject the changes you just made by pressing 'Forget Design: Quit'"
				$bl insert end $msg
				set msg ""
				$bl insert end $msg
				set msg "If you don't want this page to appear the next time you run the Sound Loom"
				$bl insert end $msg
				set msg "de-select it on the Workspace Page, using 'Set Interface Redesign' on 'System Settings' option of 'System' menu."
				$bl insert end $msg
				set msg ""
				$bl insert end $msg
			}
			set msg "IF, AT ANY STAGE, YOU GET LOST"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "Remember, there is a 'Help' button on each window. Use it if you need advice."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "IF, AT ANY STAGE, YOU WISH TO ABANDON SHIP"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Pressing the 'End Session' button on the current page, will end your session"
			$bl insert end $msg
			set msg "     (backing up your files, if necessary)."
			$bl insert end $msg
			set msg "2) If the system hangs for any reason."
			$bl insert end $msg
			set msg $evv(HANG1)
			$bl insert end $msg
			set msg $evv(HANG2)
			$bl insert end $msg
			set msg $evv(HANG3)
			$bl insert end $msg
			set msg $evv(HANG4)
			$bl insert end $msg
			set msg $evv(HANG5)
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
		}
		workspace {
			set msg "THE WORKSPACE"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "(For what to do at the End Of A Session see the foot of this page)"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "LOADING THE WORKSPACE"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Decide which files you want to work with for the session."
			$bl insert end $msg
			set msg "     These might be soundfiles, textfiles etc."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) Load these onto the workspace"
			$bl insert end $msg
			set msg "    a) Specify a directory (you can use the 'Find Dir' button)"
			$bl insert end $msg
			set msg "    b) Select 'List' : a listing of files in that directory will appear"
			$bl insert end $msg
			set msg "    c) Choose the files you wish to use, and 'Grab' them, onto the workspace"
			$bl insert end $msg
			set msg "    d) To choose files from a different directory. Proceed as before."
			$bl insert end $msg
			set msg "    d) To choose files from a subdirectory listed in the display, click on it."
			$bl insert end $msg
			set msg "           (To return to the original directory, press 'Up')."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "**** At the session end, your workspace listing will be remembered. Next time ****"
			$bl insert end $msg
			set msg "**** you start the Sound Loom the workspace will be Loaded up automatically   ****."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "SELECTING A FILE OR FILES TO PROCESS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Decide which file or files you wish to process. (This may be NO files, for example,"
			$bl insert end $msg
			set msg "     if you are synthesizing a sound, or creating an envelope from scratch)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) Click on 'Enter Chosen Files Mode' : the CHOSEN FILES list will be highlighted"
			$bl insert end $msg
			set msg "    a) Now click on the file(s) listed on the workspace which you want to use."
			$bl insert end $msg
			set msg "       They will be automatically transferred to the CHOSEN FILES list on the left."
			$bl insert end $msg
			set msg "    b) To remove a file from the (highlighted) CHOSEN FILES list, click on the file in THAT list."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "GETTING A PROCESS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Click on 'Process'. This brings up the Processing menu."
			$bl insert end $msg
			set msg "2) Or use 'Bulk Proc' to apply the same process to several (single) files (of the same type)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "WHAT TO DO AT THE END OF A SESSION"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Before finishing, you should decide if you want to store any of the new files you have produced."
			$bl insert end $msg
			set msg "     You can do this at any time in a session, by returning to the workspace ('To Wkspace:New Files')."
			$bl insert end $msg
			set msg "     New files have no directory path in front of their name, on the workspace."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) Make sure the workspace is in 'Workspace Mode' (Click 'Return to Wkspace Mode' button, if it is not)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) Select the new files you wish to store, from the workspace listing. (see note 6)"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "4) Enter a directory name, in the entry box at the top right. This can be an existing directory,"
			$bl insert end $msg
			set msg "     (perhaps chosen using the 'Find Dir' button), or a new directory you wish to create."
			$bl insert end $msg
			set msg "     By default, new directories are stored as subdirectories of your principal directory."
			$bl insert end $msg
			set msg "     If you wish to store files elsewhere, give the full pathname."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "5) Click on 'Backup'."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "6) N.B. files which are already from other directories, but listed on the workspace,"
			$bl insert end $msg
			set msg "     cannot be moved by this means. To move these files to new directories"
			$bl insert end $msg
			set msg "     use the 'Move To New Directory' option on the 'Selected Files' menu"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
		}
		process {
			set msg "THE PROCESS WINDOW"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "There are several groups of processes to use on the Sound Loom."
			$bl insert end $msg
			set msg "Some processes work with some types of files but not with others."
			$bl insert end $msg
			set msg "Only those processes that work with the file(s) you have selected will be active."
			$bl insert end $msg
			set msg " (the names of inactive processes are not shown on the display)."
			$bl insert end $msg
			set msg " If you cannot see the process you want, you may have selected the wrong type or number of files."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "LAUNCHING A PROCESS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Click on one of the menu buttons."
			$bl insert end $msg
			set msg "     A menu will be posted on the left of the screen."
			$bl insert end $msg
			set msg "     (Should this menu disappear at any time. Simply click on the button"
			$bl insert end $msg
			set msg "     at the top of that display, to redisplay it.)"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) Select a process from the posted menu (click on it). This brings up the Parameters window."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) Next time round, if you want to run the same process, simply click on 'Use Process Again'."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "CHANGING YOUR MIND"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "If you decide you have the wrong files, click on the 'To Wkspace: New Files' button."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "GETTING HELP ABOUT WHICH PROCESS TO USE"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) TO GET INFORMATION ABOUT THE PROCESSES AVAILABLE ON ANY MENU"
			$bl insert end $msg
			set msg "     a) Click on the small button labelled 'menu'. Then click on the INFO button."
			$bl insert end $msg
			set msg "     b) The process buttons will change colour."
			$bl insert end $msg
			set msg "     c) Select a menu to see information about processes available on that menu."
			$bl insert end $msg
			set msg "     d) To exit from information mode, click on the 'Action' button which appears."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) TO GET INFORMATION ABOUT ANY INDIVIDUAL PROCESS."
			$bl insert end $msg
			set msg "     a) If you are not already in 'Info' mode. click on the 'Info' button."
			$bl insert end $msg
			set msg "     b) Click on the small button labelled 'process'."
			$bl insert end $msg
			set msg "     b) Click on any menu button. The menu will be posted on the left side of the screen."
			$bl insert end $msg
			set msg "     c) Now click on any process on that menu to display information about that process."
			$bl insert end $msg
			set msg "     d) To exit from information mode, click on the 'Action' button which appears."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) TO GET ADVICE ABOUT WHICH PROCESS TO USE"
			$bl insert end $msg
			set msg "     a) Click on the 'Which?' button."
			$bl insert end $msg
			set msg "     b) In the dialog which appears, type what you want to do (e.g. 'time stretch' or 'pitch shift')"
			$bl insert end $msg
			set msg "     c) Select 'relevant' (for information about processes relevant to the files you are using)"
			$bl insert end $msg
			set msg "          or 'all' (for information about all possible processes that may do what you want)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "     d) A list of possible processes will now appear."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
		}
		parameters {
			set msg "THE PARAMETERS WINDOW"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "If working on soundfiles, (or analysis files etc. derived from soundfiles)"
			$bl insert end $msg
			set msg "you can hear the ORIGINALS at any time. Use the 'Play Src' button"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "If just testing your system, you can usually run the process by simply hitting the 'Run' button."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "SETTING THE PARAMETERS FOR THE PROCESS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "0) Set the parameters for the process, using the entry boxes, or slider bars."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Enter a '*' in (only one) parameter box if you don't yet know what value to use,"
			$bl insert end $msg
			set msg "    and would like to test several values."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) Some parameters have 2 different ranges, a typical range (the default setting when the"
			$bl insert end $msg
			set msg "     parameters window appears) and a maximal range, should you need to use it. To get the"
			$bl insert end $msg
			set msg "     maximal range, click on the 'Range' button on the parameter. Click again to return"
			$bl insert end $msg
			set msg "     to the default range (N.B. some parameters do not have a second range)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) You can also use data which changes through time, in a breakpoint table,"
			$bl insert end $msg
			set msg "     and other kinds of special data in text files."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "     Use the 'Get File' or 'Make File' buttons for this purpose."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "     If you chose 'Get File' You will get a list of tables RELEVANT to the current input file(s)."
			$bl insert end $msg
			set msg "     You can press 'Use' to use one of these files, or 'Edit' to edit, and then use it."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "     You can also chose to see all existing text files (select the 'All' option)"
			$bl insert end $msg
			set msg "     and EDIT a file that has inappropriate values for the current process"
			$bl insert end $msg
			set msg "     so that the values become appropriate."
			$bl insert end $msg
			set msg "      The Sound Loom will recognise when you have typed valid values."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "     If using Special Data files (see manuals), 'Make File' brings up a text editing window"
			$bl insert end $msg
			set msg "     with a 'Standard Features' button. Use this button to see what type of data is required."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "RUNNING THE PROCESS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Click on 'Run'. A display window will appear."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "CHANGING YOUR MIND"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) If you do not like the output sound, you can choose new parameters, and run the process again."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) You can go back to get another process. Select the 'New Process' button"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) You can go back to get new files. Select the 'To Wkspace' button. "
			$bl insert end $msg
			set msg "     In this case, remember that, on the process menu, you can simply choose 'Use Process Again'"
			$bl insert end $msg
			set msg "     to run the same process on the new file(s)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "TO SEE WHAT TO DO WITH THE PROCESS OUTPUT, RUN THE PROCESS NOW,"
			$bl insert end $msg
			set msg "THEN PRESS 'New UserHelp' AGAIN."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
		}
		output {
			set msg "WHAT TO DO WITH THE OUTPUT"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Once you have run a process, if your process has produced some output"
			$bl insert end $msg
			set msg "     you will see that a number of new button-names have appeared."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "    a) The 'Play' button is now active, if your output is soundfiles."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "    b) The 'View' button is highlighted, if your output is sound or analysis data which can"
			$bl insert end $msg
			set msg "         be viewed in a graphic display."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "    c) The 'Read' button is highlighted, if your output is text data."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "    d) The 'MaxSmp' button is active, if your output is a sound file."
			$bl insert end $msg
			set msg "         Use it to find the maximum level. This information will be associated with"
			$bl insert end $msg
			set msg "         the file, and will appear as one of the 'File Properties' which you can view"
			$bl insert end $msg
			set msg "         with the 'Props' button."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "    e) The 'Props' button is active, allowing you to see the properties of any output files."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "    f) The 'Save As' button allows you to keep the output, if it turns out to be what you wanted."
			$bl insert end $msg
			set msg "         On pressing 'Save As' you will be asked to specify a name for the outut file(s)."
			$bl insert end $msg
			set msg "         Once renamed, these files will appear automatically on the workspace"
			$bl insert end $msg
			set msg "         so that you can continue to process them."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "         If You DON'T Use 'Save As', the files produced by the process will be DELETED."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) You can run the process again, whether or not you keep the previous output."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) After saving files, you can reutilise the Output File(s) immediately,"
			$bl insert end $msg
			set msg "     by pressing the 'Recycle Outfile' button."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
		}
		run {
			set msg "THE RUN WINDOW"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "This window has a progress bar (at the bottom) to show you how the process is proceeding."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "Any readable information that the process produces (output data, warnings or errors) "
			$bl insert end $msg
			set msg "will be printed in the window."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "RUNNING THE PROCESS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Click on 'Run'"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) If your process runs successfully, and there is no data to read,"
			$bl insert end $msg
			set msg "     you will return automatically to the parameters window."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) If there is data to read in the display window,"
			$bl insert end $msg
			set msg "     press 'OK', to return to the parameters window."
			$bl insert end $msg
			set msg ""
			set msg "A process may fail, or fail to reach its goal, for various reasons"
			$bl insert end $msg
			set msg "and you will receive an error message in the window here.."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "*** If a process Crashes, (indicated by the appearance of a special window), ***"
			$bl insert end $msg
			set msg "*** press 'Abort' (and NOT 'OK') to continue using the Sound Loom. ***"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			$bl insert end $msg
			set msg "4) If you decide against the process, when it is partway through,"
			$bl insert end $msg
			set msg "     press 'Abort', and wait for the system to reconfigure itself."
			$bl insert end $msg
		}
		finish {
			if {!$sl_real} {
				return
			}
			set msg "AFTERTHOUGHTS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "HOW TO REMEMBER YOUR BEST MOMENTS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) IF YOU DISCOVER A FAVOURITE PROCESS, while working,"
			$bl insert end $msg
			set msg "     you can store it (immediately after using it) on the process page."
			$bl insert end $msg
			set msg "     Here you will find a listbox headed 'FAVOURITES'."
			$bl insert end $msg
			set msg "     Click on 'Add Last Process' to add the process to your list of favourites."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "     Note that, when you are running processes, the favourites list only displays those processes"
			$bl insert end $msg
			set msg "     that would work with your currently selected file(s). (You can see a listing of ALL your"
			$bl insert end $msg
			set msg "     favourite processes by clicking on the 'See All' button)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) IF YOU DISCOVER A FAVOURITE COMBINATION OF PARAMETERS for a particular process,"
			$bl insert end $msg
			set msg "     you can save it as a patch on the parameters page. Here there is a listing (to the right)"
			$bl insert end $msg
			set msg "     headed 'PATCHES'. Add your current patch to the listing by typing a name in the entry box,"
			$bl insert end $msg
			set msg "     and clicking on 'Save'."
			$bl insert end $msg
			set msg "     (Processes which take No parameters don't display the patch-listing, as they have no patches)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) IF YOU DISCOVER A FAVORITE COMBINATION OF PROCESSES,"
			$bl insert end $msg
			set msg "     you can record it as an Instrument."
			$bl insert end $msg
			set msg "     Use the 'Make Instr' button on the workspace."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "     You can also record any process you have just run, saving it to a 'Batch File'"
			$bl insert end $msg
			set msg "     (Use the button on the right of the parameters page)."
			$bl insert end $msg
			set msg "     You can add more and more processes to this 'Batchfile',"
			$bl insert end $msg
			set msg "     then run all of them at once from the 'Batchfile' button on the Workspace."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
		}
		ins {
			set msg "CREATING YOUR OWN INSTRUMENTS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "If you discover a favorite combination of processes, you can record it as an instrument."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) You can change your mind about which files to use, using the 'Choose Files' button."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) Once you have the correct files, click on 'Make Instrument',"
			$bl insert end $msg
			set msg "     then proceed as if running an ordinary process.....BUT ......"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) On the parameters page, most parameters will appear with an extra box, labelled 'variable'."
			$bl insert end $msg
			set msg "     If you want a particular parameter to be adjustable, later, when you USE your instrument,"
			$bl insert end $msg
			set msg "     click in the 'variable' box for this parameter. Otherwise, ignore it (in which case"
			$bl insert end $msg
			set msg "     the parameter will remain fixed for your Instrument, and you won't see it again)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "4) When the process has run, and you finally press 'Keep', you will return to this page,"
			$bl insert end $msg
			set msg "     where you will see a tree diagram of your instrument (so far) drawn in the box below."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "5) You may then select further files from the workspace, with the 'Choose Files' button,"
			$bl insert end $msg
			set msg "     Or Files From The Tree (click on them), for input to the next process... and so on."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "6) When your instrument is complete, click on 'Conclude'. You will be asked to provide names"
			$bl insert end $msg
			set msg "     for the output files you wish to keep (as with a normal single process)."
			$bl insert end $msg
			set msg "     You can tell which output file is which by referring to the tree diagram."
			$bl insert end $msg
			set msg "     You do not need to keep ALL the files (But If You Keep NONE, The Instrument Will Be ERASED)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "7) You will be asked to name the instrument. Once named it will appear on the listing"
			$bl insert end $msg
			set msg "      of 'INSTRUMENTS' on the process page, and can be used just like a single process."
			$bl insert end $msg
			set msg "      (e.g. it can have patches of its own)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "9) On closing your session, the (new) instrument(s) will be saved to disk."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "INSTRUMENT PREDICTABILITY"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "Instruments are not as predictable as processes. For example, a parameter you set as variable"
			$bl insert end $msg
			set msg "in one process, may affect the possible range of a parameter in a later process."
			$bl insert end $msg
			set msg "A parameter for duration which you leave as a fixed feature of your instrument, may turn out"
			$bl insert end $msg
			set msg "to be too long, or too short, for the file you eventually apply your Instrument to."
			$bl insert end $msg
			set msg "The Sound Loom attempts to handle all these exceptions. Occasionally it will not be able"
			$bl insert end $msg
			set msg "to predict how an instrument will behave, will tell you so, and the Instrument will not run."
			$bl insert end $msg
		}
		brkfile {
			set msg "WORKING WITH BREAKPOINT TABLES"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "You can define how a parameter varies through time, using a graph, drawn on the screen."
			$bl insert end $msg
			set msg "If you choose to make a table you will see a graph consisting of two points,"
			$bl insert end $msg
			set msg "joined by a line."
			$bl insert end $msg
			set msg "If you choose to edit an existing table, it will be displayed on the screen."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "The time points are displayed from left to right (see foot of display). The values"
			$bl insert end $msg
			set msg "at these times are displayed from top to bottom (see scale at left). A listing of the"
			$bl insert end $msg
			set msg "time-value pairs appears to the right of the display."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) You may want to Quantise the brktable (restrict entries to multiples of some fixed value)."
			$bl insert end $msg
			set msg "      You can quantise the times or the values in the table using the 'Quantise' butttons."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) You can add, delete, or move points using the mouse (see 'Mouse' menu)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) You can stretch, shrink ,change the scale etc. of the table. See 'Options' menu."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "SAVING AND USING THE TABLE"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) On pressing 'Save' (or 'Use') you will be asked to name the table."
			$bl insert end $msg
			set msg "     It will then be saved to disk and will appear on the workspace."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) If you have pressed 'Save' you will remain on this page, and you can create further tables."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "3) If you are creating or editing a table for a particular parameter of your current process,"
			$bl insert end $msg
			set msg "     you can press 'Use'. In this case the table name will be entered as the value for"
			$bl insert end $msg
			set msg "     that parameter, and you will find yourself back on the parameters page."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "MORE PRECISE VALUES"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) If points become too close together to be adequately displayed on your monitor, the"
			$bl insert end $msg
			set msg "     program will tell you. However, you can continue to edit the table as a textfile."
			$bl insert end $msg
			set msg "     Note that no two points can be at the same time (but you can make the time difference"
			$bl insert end $msg
			set msg "     as small as you like)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) If you need more detail in the time or values than you can get on the screen,"
			$bl insert end $msg
			set msg "     select 'FineTune'. On pressing 'Save' or 'Use' you will be offered the"
			$bl insert end $msg
			set msg "     option to further edit the table, as a textfile."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "THE DURATION OF THE TABLE, AND SCREEN MASKS"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "1) Most tables relate to the (first) input (sound etc.) file you chose (on the workspace"
			$bl insert end $msg
			set msg "     or the Instrument-creation page) for this process. The total duration of the table"
			$bl insert end $msg
			set msg "     (the time value to the right of the screen) will be the duration of that file."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "2) If you have selected a pre-existing table with a duration different to the file,"
			$bl insert end $msg
			set msg "     part of the table will be masked off (where it's too long) or the table will stop part-way"
			$bl insert end $msg
			set msg "     across the screen (where it's too short), and the rest of the screen will be masked."
			$bl insert end $msg
			set msg "    These masks can be removed or restored (see 'Options' menu)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
		}
		pdisplay {
			set msg "MODIFYING PITCH DATA"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "Extracting the pitch from a file is a difficult operation, especially with complex,"
			$bl insert end $msg
			set msg "changing sounds, like human speech."
			$bl insert end $msg
			set msg "On this page you can examine the pitch data, block by block, and modify any part of it."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "You can choose the block of data you want to display and and move up and down the data,"
			$bl insert end $msg
			set msg "half-a-block at a time."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "You can also Zoom the data, to see the pitch varaition in more detail,"
			$bl insert end $msg
			set msg "and Stretch the data in time, to see more closely how the pitch varies with time."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "To modify the data, highlight an area of data on the display, with the mouse,"
			$bl insert end $msg
			set msg "then select 'Stretch', to stretch the highlighted area,"
			$bl insert end $msg
			set msg "or 'Smooth', 'Transpose' or 'Insert', to modify the highlighted area."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "'Smooth' draws a line beween the values at the 2 edges of the highlighted area."
			$bl insert end $msg
			set msg "You can vary the shape of this line with the linear:concave:convex choice, and the value of 'curve'"
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "'Transpose' transposes the highlighted region by the number of semitones you enter in the box."
			$bl insert end $msg
			set msg "(Pitch tracking can typically get out by an octave)."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "'Insert' draws lines from the values at the 2 edges of the highlighted area"
			$bl insert end $msg
			set msg "to a point you mark, WITHIN That Area, using Shift-Mouse-Click."
			$bl insert end $msg
			set msg "Again you can change the shape of the lines drawn, using the curvature choices (see 'Smooth')."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "All these operations, modify the DISPLAY of the data."
			$bl insert end $msg
			set msg "When satisfied with the new shape , modify THE DATA ITSELF by selecting 'Apply'."
			$bl insert end $msg
			set msg "If you now leave this block of data, and later return to it, you will be displaying"
			$bl insert end $msg
			set msg "the MODIFIED data."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "HOWEVER, YOU DO NOT actually generate any new output, until you SAVE the data to an"
			$bl insert end $msg
			set msg "output file, using the 'Save As' button, and provide a name for that file."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
			set msg "You can play (a synthetic rendition of) the pitch data, use the 'Play' button."
			$bl insert end $msg
			set msg "Note that you must APPLY the countour on the screen to the data before you can play it."
			$bl insert end $msg
			set msg "If you fail to do this, you will hear the original data, or the result of the last Apply."
			$bl insert end $msg
			set msg ""
			$bl insert end $msg
		}
	}
	set kill_starthelp 0
	raise $f

	Simple_Grab 0 $f kill_starthelp $f.list.list
	tkwait variable kill_starthelp

	catch {Simple_Release_to_Dialog $f}
	if {$kill_starthelp} {
		KillStartupHelp
	}
	catch {Dlg_Dismiss $f}
}

#------ Get rid if Display help for new users

proc KillStartupHelp {} {
	global wstk  do_not_close_wrksp sl_real kill_starthelp do_starthlp pim papag icp bfw pdw ww evv

	if {[info exists sl_real] && !$sl_real} {
		Inf "You Can Get Rid Of New-User-Help When You No Longer Need It"
		set kill_starthelp 0
		set do_starthlp 1
		return
	}
	set evv(NEWUSER_HELP) 0
	catch {destroy $ww.1.b.db0.starthelp}
	catch {destroy $pim.help.starthelp}
	catch {destroy $papag.help.starthelp}
	catch {destroy $icp.help.starthelp}
	catch {destroy $bfw.help.starthelp}
	catch {destroy .running.t.starthelp}
	catch {destroy $pdw.t.starthelp}
	set do_not_close_wrksp 1 
}

#------ Establish new users help

proc SetupNewUserHelp {} {
	global do_starthlp evv

	set fnam [file join $evv(URES_DIR) $evv(BHELP)$evv(CDP_EXT)]
	if {![file exists $fnam] || ! [file isfile $fnam]} {
		set evv(NEWUSER_HELP) 1
	} elseif [catch {open $fnam "r"} helpId] {
		Inf "Cannot open file '$evv(BHELP)$evv(CDP_EXT)' to learn state of startup help"
		set evv(NEWUSER_HELP) 1
	} else {
		if {[gets $helpId thisline] < 0} {
			Inf "No data in file '$evv(BHELP)$evv(CDP_EXT)'"
			set evv(NEWUSER_HELP) 1
		} else {
			set evv(NEWUSER_HELP) [string trim $thisline]
		}
		close $helpId
	}
	if {$evv(NEWUSER_HELP)} {
		set do_starthlp 1
	} else {
		set do_starthlp 0
	}
}

