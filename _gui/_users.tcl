#
# SOUND LOOM RELEASE mac version 17.0.4
#

##########################################################################
# COPYING NETWORK DATA TO AND FROM NETWORK AT START AND END OF A SESSION #
##########################################################################

#---- Copy entire Loom environment to external storage medium

proc CopyToStick {} {
	global pr_stik stikdir stikotherdir true_stikdir true_stikotherdir stikdrive stikdrivecnt stiksame wstk evv
	global usetype top_user

	set msg "\n\nBackup Entire Environment ??\n\ne.g. To External Storage Medium (Memory Stick)\n\n"
	set choice [tk_messageBox -type yesno -default no -message $msg -icon question -parent [lindex $wstk end]]
	if {$choice == "no"} {
		return
	}
	set msg "To Backup Your Entire Environment To An External Storage Medium (Memory Stick)\n\n"
	append msg "\n"
	append msg "After Quitting the Loom\n"
	append msg "\n"
	append msg "(1) Create A Named Bakup Directory On Your Storage Device\n"
	append msg "\n"
	append msg "(2) Do ~~~NOT~~~ Copy The \"Soundloom\" Program\n"
	append msg "        In The \"_cdp\" Directory On The Workstation\n"
	append msg "\n"
	append msg "(3) Copy All The Other Files In The Directory \"_cdp\" On The Workstation\n"
	append msg "        To The Bakup Directory On Your Backup Device\n\n"
	append msg "\n"
	append msg "(4) Copy The Files In All Subdirectories Of \"_cdp\"\n"
	append msg "        ~~EXCEPT~~\n"
	append msg "                \"_cdprogs\"\n"
	append msg "                \"_cdpenv\"\n"
	append msg "                \"_cdpgui\" (If It Exists)\n"
	append msg "        To Corresponding Subdirectories In Your Bakup Directory."
	Inf $msg
}

#---- Copy entire Loom environment from external storage medium

proc CopyFromStick {} {
	global wstk

	set msg "The Loom is flagged to Load-up Your Environment.\n"
	append msg "\n"
	append msg "\n"
	append msg "Have You Already Loaded Your Environment ??\n"
	set choice [tk_messageBox -type yesno -icon question -default yes -message $msg -parent [lindex $wstk end]]
	if {$choice == "yes"} {
		return
	}
	set msg "To Load Your Environment\n"
	append msg "\n"
	append msg "You Will Need To Quit The Loom And Do The Following...\n"
	append msg "\n"
	append msg "If Someone Else Has Been Using The Workstation\n"
	append msg "\n"
	append msg "(1)  Delete All Files ~~~EXCEPT~~~ The SOUNDLOOM Program, In The '_cdp' Directory\n"
	append msg "\n"
	append msg "(2)  Delete All The Subdirectories ~~~EXCEPT~~~\n"
	append msg "          \"_cdpenv\"\n"
	append msg "          \"_cdprogs\"\n"
	append msg "          \"_cdgui\" (If It Exists)\n"
	append msg "\n"
	append msg "Next, Copy To The \"_cdp\" Directory On The Workstation\n"
	append msg "\n"
	append msg "All The Files And All The Subdirectories\n"
	append msg "        In The \"_cdp\" Directory On Your Backup Device\n"
	append msg "\n"
	append msg "Do You Want To Quit the Loom and Load Your Environment Now ??\n"
	set choice [tk_messageBox -type yesno -icon question -default no -message $msg -parent [lindex $wstk end]]
	if {$choice == "yes"} {
		exit
	}
	set msg "If You No Longer Intend To Load Up Your Environment Before Sessions\n"
	append msg "\n"
	append msg "You Can Un-Flag This Option On The \"System Menu\"."
	Inf $msg
}
