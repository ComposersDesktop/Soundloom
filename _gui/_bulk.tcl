#
# SOUND LOOM RELEASE mac version 17.0.4
#

###################
# BULK PROCESSING #
###################

#------ Count Parse and List outputs from a Bulk Process

proc CountParseAndListBulkOutputs {procno} {
	global prg_ocnt sndsout asndsout smpsout txtsout vwbl_sndsysout pa evv
	global do_parse_report

	set prg_ocnt 0
	set sndsout 0
	set asndsout 0
	set smpsout 0
	set vwbl_sndsysout 0
	set txtsout 0
	set finished 0
	set i 0
	set fnam $evv(MACH_OUTFNAME)
	append fnam $procno "_"
	while {!$finished} {				 				;#	Create filenames 'outfilenameN' in ascending order
		set j 0
		set fnam $fnam$j 
		if [file exists $fnam] {					;#	Look for file outfilenameN (without extension)
			incr j
		}
		foreach ffname [glob -nocomplain "$fnam.*"] {		;#	Look for file outfilenameN with extension
			incr j									
			if {$j > 1} {
				ErrShow "Naming conflict in output: [file rootname $ffname]"
				set prg_ocnt -1
				return
			}
			set fnam $ffname
		}					
		if {$j == 0} {							;#	If NO file outfilenameN exists, we're at end of output-files: exit
			set finished 1
			break
		}										;#	Parse outfilenameN,if ness change extension,Put on wkspace-listing
		set do_parse_report 1
		set fnam [DoOutputParse $fnam]
		if {[string length $fnam] == 0} {
			ErrShow "DoOutputParse failed"
			set prg_ocnt -1
			return
		}
		incr prg_ocnt									;#	Count output files
		if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
			incr sndsout								;#	Count output sndfiles
			incr smpsout
			incr vwbl_sndsysout					;#	Count displayable sndsystem files
		} elseif {$pa($fnam,$evv(FTYP)) == $evv(PSEUDO_SND)} {								 
			incr smpsout
			incr vwbl_sndsysout					;#	Count displayable sndsystem files
		} elseif {$pa($fnam,$evv(FTYP)) == $evv(ANALFILE)} {
			incr vwbl_sndsysout					;#	Count displayable sndsystem files
			incr smpsout
			incr asndsout
		} elseif {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			incr txtsout								;#	Count text files
		} else {
			incr smpsout
		}
	}
}

#------ Program masking for bulk processing

proc GetBulkProgsMask {} {
	global chlist pa evv
	global procmenu chosen_menu pmask

	set last_pmask 0
	if [info exists pmask] {
		set last_pmask [string range $pmask 1 end]
	}

	set multiple_channels 0
	set different_channels 0
	set is_a_sys_file 0
	set ubertype 0

	set fnam [lindex $chlist 0]
	set ftype 		$pa($fnam,$evv(FTYP))
	set chans 		$pa($fnam,$evv(CHANS))
	set srate 		$pa($fnam,$evv(SRATE))
	set arate 		$pa($fnam,$evv(ARATE))
	set origstype 	$pa($fnam,$evv(ORIGSTYPE))
	set origrate 	$pa($fnam,$evv(ORIGRATE))
	set mlen 		$pa($fnam,$evv(MLEN))
	set dfac 		$pa($fnam,$evv(DFAC))
	set origchans 	$pa($fnam,$evv(ORIGCHANS))
	set specenvcnt 	$pa($fnam,$evv(SPECENVCNT))
	set descriptor	$pa($fnam,$evv(DESCRIPTOR_BYTES))

	if {$ftype & $evv(PSEUDO_SND)} {
		Inf "Bulk processes cannot be applied to pseudo_Soundfiles"
		return 0
	}
	if {$ftype & $evv(IS_A_TEXTFILE)} {
		set ubertype $ftype
	} elseif {($ftype == $evv(SNDFILE)) && ($chans > 2)} {
		set multiple_channels 1
	}
	foreach fnam [lrange $chlist 1 end] {
		if {$ftype & $evv(IS_A_TEXTFILE)} {
			if {($pa($fnam,$evv(FTYP)) != $evv(MIX_MULTI)) && ($ubertype == $evv(MIX_MULTI))} {
				Inf "Not all of chosen files are of the same type"
				return 0
			}
			if {($pa($fnam,$evv(FTYP)) == $evv(MIX_MULTI)) && ($ubertype != $evv(MIX_MULTI))} {
				Inf "Not all of chosen files are of the same type"
				return 0
			}
			set ubertype [expr ($ubertype & $pa($fnam,$evv(FTYP)))]
			if {$ubertype == 0} {
				Inf "Not all of chosen files are of the same type"
				return 0
			}
			continue
		} 
		if {$ftype != $pa($fnam,$evv(FTYP))} {
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_SNDSYSTEM_FILE)} {
				set is_a_sys_file 1
				continue
			} else {
				Inf "Not all of chosen files are of the same type:\n\n$fnam\nis [PrintType $pa($fnam,$evv(FTYP))]"
				return 0
			}
		}
		switch -regexp -- $ftype \
			^$evv(FORMANTFILE)$ {
				if {$chans 	!=	$pa($fnam,$evv(CHANS))} {
					Inf "Not all of chosen files are of the same type: $fnam has $pa($fnam,$evv(CHANS)) channels"
					return 0
				}
				if {$srate 	!=	$pa($fnam,$evv(SRATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has srate $pa($fnam,$evv(SRATE))"
					return 0
				}
				if {$arate 	!=	$pa($fnam,$evv(ARATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has arate $pa($fnam,$evv(ARATE))"
					return 0
				}
# NO LONGER IMPORTANT (July 2004)
#				if {$origstype !=	$pa($fnam,$evv(ORIGSTYPE))} {
#					Inf "Not all of chosen files are of the same type: $fnam has origstype $pa($fnam,$evv(ORIGSTYPE))"
#					return 0
#				}
#
				if {$origrate !=	$pa($fnam,$evv(ORIGRATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has origrate $pa($fnam,$evv(ORIGRATE))"
					return 0
				}
				if {$mlen 	!=	$pa($fnam,$evv(MLEN))} {
					Inf "Not all of chosen files are of the same type: $fnam has mlen $pa($fnam,$evv(MLEN))"
					return 0
				}
				if {$dfac 	!=	$pa($fnam,$evv(DFAC))} {
					Inf "Not all of chosen files are of the same type: $fnam has Dec Factor $pa($fnam,$evv(DFAC))"
					return 0
				}
				if {$origchans !=	$pa($fnam,$evv(ORIGCHANS))} {
					Inf "Not all of chosen files are of the same type: $fnam has origchans $pa($fnam,$evv(ORIGCHANS))"
					return 0
				}
				if {$specenvcnt !=	$pa($fnam,$evv(SPECENVCNT))} {
					Inf "Not all of chosen files are of the same type: $fnam has specenvcnt $pa($fnam,$evv(SPECENVCNT))"
					return 0
				}
				if {$descriptor!=	$pa($fnam,$evv(DESCRIPTOR_BYTES))} {
					Inf "Not all of chosen files are of the same type: $fnam has different descriptor bytes"
					return 0
				}
			} \
			^$evv(PITCHFILE)$ - \
			^$evv(TRANSPOSFILE)$ {
				if {$chans 	!=	$pa($fnam,$evv(CHANS))} {
					Inf "Not all of chosen files are of the same type: $fnam has $pa($fnam,$evv(CHANS)) channels"
					return 0
				}
				if {$srate 	!=	$pa($fnam,$evv(SRATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has srate $pa($fnam,$evv(SRATE))"
					return 0
				}
				if {$arate 	!=	$pa($fnam,$evv(ARATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has arate $pa($fnam,$evv(ARATE))"
					return 0
				}
# NO LONGER IMPORTANT (July 2004)
#				if {$origstype !=	$pa($fnam,$evv(ORIGSTYPE))} {
#					Inf "Not all of chosen files are of the same type: $fnam has origstype $pa($fnam,$evv(ORIGSTYPE))"
#					return 0
#				}
#
				if {$origrate !=	$pa($fnam,$evv(ORIGRATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has origrate $pa($fnam,$evv(ORIGRATE))"
					return 0
				}
				if {$mlen 	!=	$pa($fnam,$evv(MLEN))} {
					Inf "Not all of chosen files are of the same type: $fnam has mlen $pa($fnam,$evv(MLEN))"
					return 0
				}
				if {$dfac 	!=	$pa($fnam,$evv(DFAC))} {
					Inf "Not all of chosen files are of the same type: $fnam has dfac $pa($fnam,$evv(DFAC))"
					return 0
				}
				if {$origchans !=	$pa($fnam,$evv(ORIGCHANS))} {
					Inf "Not all of chosen files are of the same type: $fnam has origchans $pa($fnam,$evv(ORIGCHANS))"
					return 0
				}
			} \
			^$evv(ANALFILE)$ {
				if {$chans 	!=	$pa($fnam,$evv(CHANS))} {
					Inf "Not all of chosen files are of the same type: $fnam has $pa($fnam,$evv(CHANS)) channels"
					return 0
				}
				if {$srate 	!=	$pa($fnam,$evv(SRATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has srate $pa($fnam,$evv(SRATE))"
					return 0
				}
				if {$arate 	!=	$pa($fnam,$evv(ARATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has arate $pa($fnam,$evv(ARATE))"
					return 0
				}
# NO LONGER IMPORTANT (July 2004)
#				if {$origstype !=	$pa($fnam,$evv(ORIGSTYPE))} {
#					Inf "Not all of chosen files are of the same type: $fnam has origstype $pa($fnam,$evv(ORIGSTYPE))"
#					return 0
#				}
#
				if {$origrate !=	$pa($fnam,$evv(ORIGRATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has origrate $pa($fnam,$evv(ORIGRATE))"
					return 0
				}
				if {$mlen 	!=	$pa($fnam,$evv(MLEN))} {
					Inf "Not all of chosen files are of the same type: $fnam has mlen $pa($fnam,$evv(MLEN))"
					return 0
				}
				if {$dfac 	!=	$pa($fnam,$evv(DFAC))} {
					Inf "Not all of chosen files are of the same type: $fnam has dfac $pa($fnam,$evv(DFAC))"
					return 0
				}
			} \
			^$evv(SNDFILE)$ {
				if {$chans 	!=	$pa($fnam,$evv(CHANS))} {
					set different_channels 1
				}
				if {$chans > 2} {
					set multiple_channels 1
				}
				if {$srate 	!=	$pa($fnam,$evv(SRATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has srate $pa($fnam,$evv(SRATE))"
					return 0
				}
			} \
			^$evv(ENVFILE)$ {
				if {$srate 	!=	$pa($fnam,$evv(SRATE))} {
					Inf "Not all of chosen files are of the same type: $fnam has srate $pa($fnam,$evv(SRATE))"
					return 0
				}
			}

	}
	if {$is_a_sys_file} {
		set p_mask 	 "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000010000000011"
		append p_mask "00000100000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
		append p_mask "00000000000000000000000000000000"
	} elseif {$ftype & $evv(IS_A_TEXTFILE)} {
		if {$ubertype == $evv(MIX_MULTI)} {
			set p_mask 	 "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000001"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
		} elseif {$ubertype & $evv(IS_A_NORMD_BRKFILE)} {
			set p_mask 	 "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000010000"
			append p_mask "00001001000000000000000000000000"
			append p_mask "00000000000010000000000000000000"
			append p_mask "00000000000000010011110001000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
		} elseif {$ubertype & $evv(IS_A_DB_BRKFILE)} {
			set p_mask 	 "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000110000000000000000000000000"
			append p_mask "00000000000010000000000000000000"
			append p_mask "00000000000000010011110001000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
		} elseif {[IsAMixfile $ubertype]} {
			set p_mask 	 "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000011111111100000000000"
			append p_mask "00000000000010000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000100000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
		} elseif {($ubertype & $evv(IS_A_SNDLIST)) && ($ubertype & $evv(IS_A_SYNCLIST))} {
			set p_mask 	 "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000011000000000000"
			append p_mask "00000000000010000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
		} elseif {[IsAListofNumbers $ubertype]} {
			set p_mask 	 "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000010000"
			append p_mask "00001111000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000010011110001000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
		} elseif {$ubertype & $evv(IS_A_LINELIST)} {
			set p_mask 	 "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000010000"
			append p_mask "00001111000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000010011110001000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
			append p_mask "00000000000000000000000000000000"
		} else {
			set p_mask 0
		}
	} else {
		switch -regexp -- $ftype \
			^$evv(FORMANTFILE)$ {
				set p_mask 	 "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00100000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000010000000011"
				append p_mask "00000100000000000000000000000000"
				append p_mask "00000010000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
			} \
			^$evv(PITCHFILE)$ {
				set p_mask 	 "00000000000000000000000000000000"
				append p_mask "00000000000000000111111111100000"
				append p_mask "00000000000000000001111100000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000010000000011"
				append p_mask "00000100000000000000000000000000"
				append p_mask "01000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000010000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
			} \
			^$evv(TRANSPOSFILE)$ {
				set p_mask 	 "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000010000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000010000000011"
				append p_mask "00000100000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
			} \
			^$evv(ANALFILE)$ {
				set p_mask 	 "11001111100111111111111111111111"
				append p_mask "11111111111100000000000000000111"
				append p_mask "00010000000111111110000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000001000000000010000000011"
				append p_mask "00000100000000000000000100000000"
				append p_mask "00000000000000000000000100000000"
				append p_mask "00000000000000000000000001000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00011110000000000000000000000000"
				append p_mask "00000011000000000000000000000000"
				append p_mask "00000000000000110000000000000000"
				append p_mask "00000000010000000000000000000000"
				append p_mask "00000000000000000000000100000000"
			} \
			^$evv(ENVFILE)$ {
				set p_mask 	 "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000100000"
				append p_mask "00110000000000000000000000000000"
				append p_mask "00000000000000000000010000000011"
				append p_mask "00000100000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
				append p_mask "00000000000000000000000000000000"
			} \
			^$evv(SNDFILE)$ {
				if {$different_channels} {
					if {$multiple_channels} {
						set p_mask 	 "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000101100000"
						append p_mask "00000000011111111110101001001111"
						append p_mask "11000000000000000000000011111111"
						append p_mask "11000000000001111101011110000011"
						append p_mask "00011111011000000000000000100010"
						append p_mask "00000000000000000000000001100000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "10100000000000000000000001010000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
					} else {
						set p_mask 	 "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000001111100000"
						append p_mask "00000000001111111110101001001111"
						append p_mask "11000000000000000000000011111111"
						append p_mask "11111110000101111101011110000011"
						append p_mask "00011111011000000000000000111010"
						append p_mask "00000000000000000000000001100000"
						append p_mask "00000000000000000000000010000000"
						append p_mask "10100000000000000000000001010000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
						append p_mask "00000000000000000000000000000000"
					}
				} elseif {$chans == 1} {
					set p_mask 	 "00000000000000000000000000000000"
					append p_mask "00000000000000000000000000000000"
					append p_mask "00000000000000000000000001000000"
					append p_mask "00011111111111111111011111100000"
					append p_mask "00000000001111111110101001001111"
					append p_mask "11000000001010000000000011111111"
					append p_mask "11111110110101111101011110000011"
					append p_mask "00011101001000000000000000111010"
					append p_mask "00000000000010000000000001110000"
					append p_mask "00000100000000000000000010010110"
					append p_mask "10100000001000000011100111011011"
					append p_mask "10100000010000001110001100000000"
					append p_mask "00000001001100011001001010000011"
					append p_mask "01001000010100000001000000000001"
					append p_mask "00011101000000000000000000000000"
					append p_mask "00000000000000000000000000000000"
				} elseif {$chans == 2} {
					set p_mask 	 "00000000000000000000000000000000"
					append p_mask "00000000000000000000000000000000"
					append p_mask "00000000000000000000000000000000"
					append p_mask "00000000000000000000001111100000"
					append p_mask "00000000001111111110101001001111"
					append p_mask "11000000000000000000000011111111"
					append p_mask "11111110100001101101011110000011"
					append p_mask "00011111011000000000000000111010"
					append p_mask "00000000000010000000000001100000"
					append p_mask "00000000000000000000000010000000"
					append p_mask "10100010101000000010100101010000"
					append p_mask "10100000010000001110001100000000"
					append p_mask "00000001001100011000000000000011"
					append p_mask "01001000010100000000000000000001"
					append p_mask "00000001000000000000000000000000"
					append p_mask "00000000000000000000000000000000"
			} elseif {$chans > 2} {
					set p_mask 	 "00000000000000000000000000000000"
					append p_mask "00000000000000000000000000000000"
					append p_mask "00000000000000000000000000100000"
					append p_mask "00000000000000000000001111100000"
					append p_mask "00000000001111111110101001001111"
					append p_mask "11000000000000000000000011111111"
					append p_mask "11100110100001101101011110000011"
					append p_mask "00011111011000000000000000111010"
					append p_mask "00000000000010000000000001100000"
					append p_mask "00000000000000000000000010000000"
					append p_mask "10100010101000000010100101010000"
					append p_mask "10100000010000001110001100000000"
					append p_mask "00000001001100011000000000000011"
					append p_mask "01001000010100000000000000000001"
					append p_mask "00000001000000000000000000000000"
					append p_mask "00000000000000000000000000000000"
				} else {
					set p_mask 0
				}
			}
	}
	if {![string match $p_mask $last_pmask]} {		;#	If valid-processes-setting changes:
		catch {destroy $procmenu}					;#	 destroy any chosen-menu from previous use of process page
		catch {destroy $chosen_menu}
	}
	set p_mask [DoCryptoProgs $p_mask]
	return $p_mask
}

#------ Create a list of cmdlines for bulk-processing

proc AssembleBulkCmdlines {} {
	global pmcnt prg pprg mmod chlist pa
	global hst ins deleting_status copy_name full_copy_name evv
	global bulk temp_batch float_out prg prm bulksplit panprocess mixfulldur mixmaxdur

	catch {unset temp_batch}

	if {![info exists chlist]} {
		ErrShow "No list of chosen files"
		return 0
	}
	set bulkcmd [file join $evv(CDPROGRAM_DIR) [lindex $prg($pprg) $evv(UMBREL_INDX)]]
	if {[string length $bulkcmd] == 0} {
		ErrShow "Bad cmdline construction"
		return 0
	}
	if [ProgMissing $bulkcmd "Cannot perform this process"] {
		return 0
	}
	if {$float_out} {
		set bulk_out_name $evv(FLOAT_OUT)
		append bulk_out_name $evv(MACH_OUTFNAME)
	} else {
		set bulk_out_name $evv(MACH_OUTFNAME)		;#	update outfile name at each process
	}

 	set infilecnt [llength $chlist]					;#	Number of input files 
	set j 0
	HandleCryptoModes
	while {$j < $infilecnt} {
		set cmd $bulkcmd
		if {![IsStandalonePrognoWithNonCDPFormat $pprg]} {
			lappend cmd $pprg $mmod		 				;#	Program number & Mode number
			lappend cmd "1"
			set fnam [lindex $chlist $j]
			set propno 0
			while {$propno < $evv(CDP_PROPS_CNT)} {			;#	Send Properties of input file
				lappend cmd $pa($fnam,$propno)
				incr propno
			}
			lappend cmd $fnam
			if {($pprg == $evv(RETIME)) && ($mmod == 12)} {
				set out_name [string tolower $prm(0)]
				if {![string match [file extension $out_name] $evv(TEXT_EXT)]} {
					if {[string length [file extension $out_name]] > 0} {
						Inf "Invalid File Extension ([file extension $out_name]): Must Be '$evv(TEXT_EXT)' Or None"
						return 0
					}
					set out_name [file rootname $out_name]
					append out_name $evv(TEXT_EXT)
					set prm(0) $out_name
				}
			} else {
				set out_name $bulk_out_name
				append out_name $j "_0"							;#	so they'll tally with Instrumentcreate-generated names
				append out_name [GetExtensionOfOutfileTypeFromProcess $pprg]
			}
			lappend cmd $out_name							;#	Name of outfile(s), always a standard default-name
			set i 0
			if {[info exists mixfulldur] || [info exists mixmaxdur]} {
				while {$i < $pmcnt} {							;#	all parameters for the program
					set val $evv(NUM_MARK)
					switch -- $i {
						0 {
							if {[info exists mixmaxdur]} {
								if {$prm($i) >= $mixmaxdur} {
									Inf "BULK MIXES CANNOT BEGIN BEYOND $mixmaxdur"
									return 0
								} else {
									append val $prm($i)
								}
							} else {	;#	mixfulldur
								append val 0
							}
						}
						1 {
							if {[info exists mixmaxdur]} {
								if {$prm($i) <= $mixmaxdur} {
									append val $prm($i)
								} else {
									append val $mixmaxdur
									if {![info exists tell]} {
										Inf "MIX DURATIONS CURTAILED TO MAXIMUM DURATION $mixmaxdur"
										set tell 1
									}
								}
							} else {	;#	mixfulldur
								append val $pa([lindex $chlist $j],$evv(DUR))
							}
						}
						default {
							append val $prm($i)
						}
					}
					lappend cmd $val
					incr i
				}
			} else {
				while {$i < $pmcnt} {							;#	all parameters for the program
					set val [MarkNumericVals $i]				;#	Distinguish numbers from brkfiles
					lappend cmd $val
					incr i
					if {[IsDeadParam $i]} {
						set prm($i) 0
						set val $evv(NUM_MARK)
						append val $prm($i)
						lappend cmd $val
						incr i
					}
				}
			}
		} else {
			if {[lindex $prg($pprg) $evv(MODECNT_INDEX)] > 0} {
				lappend cmd $mmod
			}
			lappend cmd [lindex $chlist $j]
			set out_name $bulk_out_name
			append out_name $j "_0"							;#	so they'll tally with Instrumentcreate-generated names
			append out_name [GetExtensionOfOutfileTypeFromProcess $pprg]
			lappend cmd $out_name							;#	Name of outfile(s), always a standard default-name
			set i 0
			while {$i < $pmcnt} {							;#	all parameters for the program
				set val $prm($i)
				lappend cmd $val
				incr i
			}
			set cmd [StandAloneCommand $cmd]
			if {[llength $cmd] <= 0} {
				set badcmd 1
				return 0
			}
		}
		lappend temp_batch $cmd
		incr j
	}
	if {![info exists bulksplit] && ![info exists panprocess]} {
		if {![DeleteAllTemporaryFiles]} {
			ErrShow "Files may be open to VIEW or to READ or to PLAY: close them, to proceed"
		}
	}
	set deleting_status 0
	return 1
}

#--------

proc PrintType {typ} {
	global evv

	switch -regexp -- $typ \
		^$evv(SNDFILE)$ {
			return "a Soundfile"
		} \
		^$evv(ANALFILE)$ {
			return "an Analysis file"
		} \
		^$evv(PITCHFILE)$ {
			return "a Binary Pitch Data File"
		} \
		^$evv(TRANSPOSFILE)$ {
			return "a Binary Transposition Data File"
		} \
		^$evv(FORMANTFILE)$ {
			return "a Formant Data File"
		} \
		^$evv(ENVFILE)$ {
			return "a Binary Envelope Data File"
		} \
		^$evv(PSEUDO_SND)$ {
			return "a Pseudo Sound-Data File"
		}

	if {$typ & $evv(IS_A_TEXTFILE)} {
		if {$typ == $evv(MIX_MULTI)} {
			return "a Multichannel Mixfile"
		} elseif {[IsAMixfile $typ]} {
			return "a Mixfile"
		} elseif {[IsASndlist $typ]} {
			return "a List of Soundfiles"
		} elseif {$typ & $evv(IS_A_SYNCLIST)} {
			return "a List of Soundfiles for syncing"
		} elseif {$typ & $evv(IS_A_BRKFILE)} {
			return "a Breakpoint File (probably)"
		} elseif {[IsAListofNumbers $typ]} {
			return "a List of Numbers"
		} elseif {$typ & $evv(IS_A_LINELIST)} {
			return "a List of Text Lines"
		} else {
			return "a Textfile of Unknown Type"
		}
	} else {
		return "an Unknown file type"
	}
}

proc PurgeBulkOutput {} {
	global evv
	foreach fnam [glob -nocomplain $evv(MACH_OUTFNAME)*] {
		if [catch {file delete $fnam} zit] {
			Inf "Cannot Delete Existing Temporary Output File '$fnam'"
			return 0
		}
	}
	return 1
}

proc GetExtensionOfOutfileTypeFromProcess {prgno} {
	global evv mmod
	set this_mode [expr $mmod - 1]
	switch -regexp -- $prgno \
		^$evv(FORMANTFILE)$ - \
		^$evv(OCTVU)$ - \
		^$evv(PEAK)$ - \
		^$evv(REPORT)$ - \
		^$evv(PRINT)$ - \
		^$evv(P_WRITE)$ - \
		^$evv(SETHARES)$ - \
		^$evv(GRAIN_GET)$ - \
		^$evv(ENV_REPLOTTING)$ - \
		^$evv(ENV_ENVTOBRK)$ - \
		^$evv(ENV_ENVTODBBRK)$ - \
		^$evv(ENV_DBBRKTOBRK)$ - \
		^$evv(ENV_BRKTODBBRK)$ - \
		^$evv(MIXSHUFL)$ - \
		^$evv(MIXTWARP)$ - \
		^$evv(MIXSWARP)$ - \
		^$evv(MIXSYNC)$ - \
		^$evv(MIXSYNCATT)$ - \
		^$evv(MIXDUMMY)$ - \
		^$evv(FLTBANKC)$ - \
		^$evv(HOUSE_BUNDLE)$ - \
		^$evv(INFO_TIMELIST)$ - \
		^$evv(INFO_PRNTSND)$ - \
		^$evv(INFO_LOUDLIST)$ - \
		^$evv(SIN_TAB)$ - \
		^$evv(PTOBRK)$ - \
		^$evv(PARTIALS_HARM)$ - \
		^$evv(MIX_ON_GRID)$ - \
		^$evv(ADDTOMIX)$ - \
		^$evv(MIX_PAN)$ - \
		^$evv(MIX_AT_STEP)$ - \
		^$evv(MAKE_VFILT)$ - \
		^$evv(BATCH_EXPAND)$ - \
		^$evv(MIX_MODEL)$ - \
		^$evv(P_BINTOBRK)$ - \
		^$evv(TAPDELAY)$ - \
		^$evv(RMRESP)$ - \
		^$evv(LUCIER_GETF)$ - \
		^$evv(FEATURES)$ - \
		^$evv(PEAKFIND)$ - \
		^$evv(MULTIMIX)$ {
			set ext ".txt"
		} \
		^$evv(PITCH)$	   - \
		^$evv(TRACK)$	   - \
		^$evv(ENV_CREATE)$ - \
		^$evv(ENV_EXTRACT)$ {
			if {$this_mode == 1} {
				set ext ".txt"
			} else {
				set ext ".wav"
			}
		} \
		^$evv(MIXMAX)$ {
			if {$this_mode == 0} {
				set ext ".wav"
			} else {
				set ext ".txt"
			}
		} \
		^$evv(HOUSE_EXTRACT)$ {
			if {$this_mode == 1} {
				set ext ".txt"
			} else {
				set ext ".wav"
			}
		} \
		^$evv(HF_PERM1)$ - \
		^$evv(HF_PERM2)$ {
			if {$this_mode < 2} {
				set ext ".wav"
			} else {
				set ext ".txt"
			}
		} \
		^$evv(GREV)$ {
			if {$this_mode == 5} {
				set ext ".txt"
			} else {
				set ext ".wav"
			}
		} \
		^$evv(MIXMAX)$ {
			if {$this_mode == 0} {
				set ext ".wav"
			} else {
				set ext ".txt"
			}
		} \
		default {
			set ext ".wav"
		}

	return $ext
}
