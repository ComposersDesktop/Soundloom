#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

######################################################
# UPDATE ALL procs BELOW, IF A STANDALONE PROG ADDED #
######################################################

#~~~~~~~~~~~~~~~~~~~~~~~~~
#   PROGRAM DEFINITION
#~~~~~~~~~~~~~~~~~~~~~~~~~

proc GetNonCDPFormatBatchlineOutfileIndex {cmdline} {       ;#  THESE VALUES MAKE NO SENSE
    global evv
    switch -regexp -- [lindex $cmdline 0] {
        "tapdelay" {
            set outpos 2
            set outext $evv(SNDFILE_EXT)
        }
        "rmresp" {
            set outpos 1
            set outext $evv(TEXT_EXT)
        }
        "rmverb" {
            set outpos 2
            set outext $evv(SNDFILE_EXT)
        }
        "abfpan"   -
        "abfpan2"  -
        "abfpan2p" -
        "chorder"  -
        "fmdcode"  -
        "interlx"  -
        "copysfx"  -
        "njoin" {
            set outpos 2
            set outext $evv(SNDFILE_EXT)
        }
        "chxformat"  -
        "chxformatg" -
        "chxformatm" -
        "channelx"   {
            set outpos 1
            set outext $evv(SNDFILE_EXT)
        }
        "interlx"    {
            set outpos 1
            set outext $evv(SNDFILE_EXT)
        }
        "nmix" {
            set outpos 3
            set outext $evv(SNDFILE_EXT)
        }
    }
    set n 1         ;#  SKIP OVER FLAGS     (Applies only to non-CDP format cmdlines with flags BEFORE infiles and outfiles)
    while {[string match "-*" [lindex $cmdline $n]]} {
        incr outpos
        incr n
    }
    if {![info exists outpos] || ![info exists outext]} {
        Inf "\"$cmdline\"\nHas No Outfile"
        return {}
    }
    return [list $outpos $outext]
}

#------ Recognise Standalone Program for History Display

proc IsStandaloneProgWithNonCDPFormat {str} {
    global evv
    switch -- $str {
        "tapdelay"  { return $evv(TAPDELAY) }
        "rmresp"    { return $evv(RMRESP) }
        "rmverb"    { return $evv(RMVERB) }
        "abfpan"    { return $evv(ABFPAN) }
        "abfpan2"   { return $evv(ABFPAN2) }
        "channelx"  { return $evv(CHANNELX) }
        "chorder"   { return $evv(CHORDER) }
        "fmdcode"   { return $evv(FMDCODE) }
        "chxformat" { return $evv(CHXFORMAT) }
        "interlx"   { return $evv(INTERLX) }
        "copysfx"   { return $evv(COPYSFX) }
        "njoin"     { return $evv(NJOIN) }
        "njoin"     { return $evv(NJOINCH) }
        "nmix"      { return $evv(MNMIX) }
        "rmsinfo"   { return $evv(RMSINFO) }
        "sfprops"   { return $evv(SFEXPROPS) }
    }
    return 0
}

#------ Recognise Standalone Program for History Display

proc IsStandalonePrognoWithNonCDPFormat {progno} {
    global evv
    switch -regexp -- $progno \
        ^$evv(TAPDELAY)$   - \
        ^$evv(RMRESP)$     - \
        ^$evv(RMVERB)$     - \
        ^$evv(RMVERB)$     - \
        ^$evv(ABFPAN)$     - \
        ^$evv(ABFPAN2)$    - \
        ^$evv(ABFPAN2P)$   - \
        ^$evv(CHANNELX)$   - \
        ^$evv(CHORDER)$    - \
        ^$evv(FMDCODE)$    - \
        ^$evv(CHXFORMAT)$  - \
        ^$evv(CHXFORMATM)$ - \
        ^$evv(CHXFORMATG)$ - \
        ^$evv(INTERLX)$    - \
        ^$evv(COPYSFX)$    - \
        ^$evv(NJOIN)$      - \
        ^$evv(NJOINCH)$    - \
        ^$evv(NMIX)$       - \
        ^$evv(RMSINFO)$    - \
        ^$evv(SFEXPROPS)$   { 
            return 1
        }
    return 0
}

#~~~~~~~~~~~~~~~~~~~~~~~~~
#   CMDLINE FORMAT
#~~~~~~~~~~~~~~~~~~~~~~~~~

#---- Does standalone program have a float out flag: if so, what position in ORIGINAL cmdline ??

proc PosValOfStandaloneProgFloatoutFlagIfany {pprg} {
    global evv
;#                                      POS  VAL
    switch -regexp -- $pprg \
        ^$evv(TAPDELAY)$    { return [list 1 "-f"] } \
        ^$evv(RMVERB)$      { return [list 7 "-f"] }
    return {}
}

proc HasSndoutButNoFloatoutFlag {pprg} {
    global evv
    switch -regexp -- $pprg \
        ^$evv(TAPDELAY)$   {return 0} \
        ^$evv(RMRESP)$     {return 0} \
        ^$evv(RMVERB)$     {return 0} \
        ^$evv(ABFPAN)$     {return 1} \
        ^$evv(ABFPAN2)$    {return 1} \
        ^$evv(ABFPAN2P)$   {return 1} \
        ^$evv(CHANNELX)$   {return 1} \
        ^$evv(CHORDER)$    {return 1} \
        ^$evv(FMDCODE)$    {return 1} \
        ^$evv(CHXFORMAT)$  {return 1} \
        ^$evv(CHXFORMATG)$ {return 1} \
        ^$evv(CHXFORMATM)$ {return 0} \
        ^$evv(INTERLX)$    {return 1} \
        ^$evv(COPYSFX)$    {return 1} \
        ^$evv(NJOIN)$      {return 1} \
        ^$evv(NJOINCH)$    {return 0} \
        ^$evv(NMIX)$       {return 1} \
        ^$evv(RMSINFO)$    {return 0} \
        ^$evv(SFEXPROPS)$  {return 0} \
        default          {return 0}
}

#------ Maps CDP cmd format to standalone prog formats

proc MapFuncForNonCDPFormatProgs {args} {
    global pprg standopos ambextflag float_out pa evv

    set done 0
    set float_out_flag 0

    switch -regexp -- $pprg \
        ^$evv(TAPDELAY)$ {
            ;#  tapdelay       [-f]   infile   outfile tapgain feedback mix taps.txt [trailtime]
            ;#  0                1       2       3        4       5      6     7          8
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INFILE OUTFILE SPECIAL  PARAMS~~~~~~~~~~~~~~ OPTIONS    FLAGS
            ;#  tapdelay        infile outfile taps.txt tapgain feedback mix [trailtime  -f]        
            ;#  0        [none]    1     2       3         4        5     6      7        8
            ;#          
            ;#  1gets8  2gets1  3gets2  4gets4  5gets5  6gets6  7gets3  8gets7
            ;#  map: 8       1       2       4       5       6       3       7

            set map [list 8 1 2 4 5 6 3 7]  ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 3                ;#  Index of any special data on CDPcmdline
            set specialflag ""              ;#  flag for any special data on CDPcmdline
            set opstart 7                   ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 0.0]       ;#  Default values of any options
            set flagstart 8                 ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list " " f]   ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 3                ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 8            ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                    ;#  Program produces sound output (or not)
        } \
        ^$evv(RMRESP)$ {
            ;#  rmresp [-aMAXAMP][-rRES] outfile    liveness nrefs roomL roomW roomH srcL srcW srcH lisL lisW lisH
            ;#  0           1        2      3           4      5    6      7    8     9    10   11    12   13  14   
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INFILE OUTFILE SPECIAL  PARAMS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTIONS~~~~~~~~ FLAGS
            ;#  rmresp                 outfile         liveness nrefs roomL roomW roomH srcL srcW srcH lisL lisW lisH [-aMAXAMP][-rRES]
            ;#  0        [none]  [none]  1      [none]     2      3     4     5     6    7    8     9   10    11  12      13       14
            ;#          
            ;#  1gets13  2gets14  3gets1  4gets2  5gets3  6gets4  7gets5  8gets6  9gets7 10gets8  11gets9 12gets10 13gets11 14gets12
            ;#  map: 13       14       1       2       3       4       5       6       7       8        9       10       11       12

            set map [list 13 14 1 2 3 4 5 6 7 8 9 10 11 12] ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                ;#  Index of any special data on CDPcmdline
            set opstart 13                  ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 1 0.1]     ;#  Default values of any options
            set flagstart 0                 ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list "a" "r"] ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 3                ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0            ;#  Program has a float-out flag? at what position in CDP cmdline
            set sndout 0                    ;#  Program produces sound output (or not)
        } \
        ^$evv(RMVERB)$ {
            ;#  rmverb       [-etaps.txt -LN -HN -pN -cN -d -f] inf outf rmsize rmgain  mix  fdbk  absorb  lpfrq  trailtime
            ;#  0                1        2   3   4   5   6  7   8   9     10     11    12    13      14     15      16
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTIONS~~~~~~~~~ FLAGS
            ;#  rmverb          inf outf taps.txt rmsize rmgain  mix  fdbk  absorb  lpfrq  trailtime [-LN -HN -pN -cN -d -f]        
            ;#  0        [none]  1   2       3      4       5     6     7     8       9         10     11  12  13  14 15 16
            ;#          
            ;#      1gets 2gets 3gets 4gets 5gets 6gets 7gets 8gets 9gets 10gets 11gets 12gets 13gets 14gets 15gets 16gets
            ;#  map:3     11    12    13    14    15    16    1     2     4      5      6      7      8      9      10

            set map [list 3 11 12 13 14 15 16 1 2 4 5 6 7 8 9 10]   ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 3                    ;#  Index of any special data on CDPcmdline
            set specialflag "-e"                ;#  flag for any special data on CDPcmdline
            set opstart 11                      ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 0 0 0 2]       ;#  Default values of any options
            set flagstart 15                    ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list L H p c d f] ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 9                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 16               ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(ABFPAN)$ {
            ;#  abfpan [-b] [-x] [-oN]  infile outfile startpos endpos
            ;#  0       1    2     3      4       5       6       7
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~~~~~~~~~~~~ OPTIONS~~~~~~~~~ FLAGS
            ;#  abfpan          inf outf          startpos endpos       [-oN]           [-b] [-x]
            ;#  0        [none]  1   2   [none]      3      4           5               6     7
            ;#          
            ;#      1gets 2gets 3gets 4gets 5gets 6gets 7gets
            ;#  map:6     7     5     1     2     3     4    

            set map [list 6 7 5 1 2 3 4]        ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set opstart 5                       ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 4]             ;#  Default values of any options
            set flagstart 6                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list o b x]       ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 5                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(ABFPAN2)$ {
            ;#  abfpan2 [-gGAIN] [-w] infile outfile startpos endpos
            ;#  0       1         2     3          4      5     6
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~~~~~~~~~~~~ OPTIONS~~~~ FLAGS
            ;#  abfpan          inf outf          startpos endpos     [-gGAIN]      [-w]
            ;#  0        [none]  1   2   [none]      3      4           5           6
            ;#          
            ;#      1gets 2gets 3gets 4gets 5gets 6gets
            ;#  map:5     6     1       2     3     4    

            set map [list 5 6 1 2 3 4]          ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set opstart 5                       ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 1]             ;#  Default values of any options
            set flagstart 6                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list g w]         ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 4                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(ABFPAN2P)$ {
            ;#  abfpan2 [-gGAIN] [-p[DEG]] [-w]  infile outfile startpos endpos
            ;#  0       1         2         3      4       5        6      7
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~~~~~~~~~~~~ OPTIONS~~~~~~~~~~~~~ FLAGS
            ;#  abfpan2         inf outf          startpos endpos     [-gGAIN]  [-pDEG]     [-w]
            ;#  0        [none]  1   2   [none]      3      4           5           6       7
            ;#          
            ;#      1gets 2gets 3gets 4gets 5gets 6gets 7gets
            ;#  map:5     6       7    1    2     3     4    

            set map [list 5 6 7 1 2 3 4]        ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set opstart 5                       ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 1 0]           ;#  Default values of any options
            set flagstart 7                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list g p w]       ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 4                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(CHANNELX)$ {
            ;#  channelx [-oBASENAME] infile chan_no [chan_no .....]
            ;#  0            1          2      3 .....
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~~~~~~~~~~~~ OPTIONS~~~~~~~~~~~~~ FLAGS
            ;#  channelx        inf out  chan_nos
            ;#  0        [none]  1   2   3
            ;#          
            ;#      1gets 2gets 3gets
            ;#  map:2     1       3

            set map [list 2 1 3]                ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 3                    ;#  Index of any special data on CDPcmdline
            set specialflag ""                  ;#  flag for any special data on CDPcmdline
            set opstart 0                       ;#  Index of first optional CDPcmdline item: zero if none
            set flagstart 0                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set outfilepos 1                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(CHORDER)$ {
            ;#  chorder infile outfile orderstring
            ;#  0         1     2      3 .....
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~~ OPTIONS~~~ FLAGS
            ;#  chorder         inf out  orderstring                    [-a]
            ;#  0        [none]  1   2   3
            ;#          
            ;#      1gets 2gets 3gets
            ;#  map:1     2       3

            set ambextflag [lindex $args end]   ;#  Additional parametere in CDP cmdline, checked && removed
            set args [lreplace $args end end]
            set map [list 1 2 3]                ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 3                    ;#  Index of any special data on CDPcmdline
            set specialflag ""                  ;#  flag for any special data on CDPcmdline
            set opstart 0                       ;#  Index of first optional CDPcmdline item: zero if none
            set flagstart 0                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set outfilepos 2                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(FMDCODE)$ {
            ;#  fmdcode [-x]  [-w] infile outfile layout
            ;#  0         1     2    3      4       5
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~ OPTIONS~~~ FLAGS
            ;#  fmdcode         inf out  layout                         [-x]   [-w]
            ;#  0        [none]  1   2   3        [none]    [none]       4      5
            ;#          
            ;#      1gets 2gets 3gets 4gets 5gets
            ;#  map:4     5       1     2   3

            set map [list 4 5 1 2 3]            ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set specialflag ""                  ;#  flag for any special data on CDPcmdline
            set opstart 0                       ;#  Index of first optional CDPcmdline item: zero if none
            set flagstart 4                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list x w]         ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 4                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(CHXFORMATM)$ {
            ;#  chxformat [-m]
            ;#  0         1
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF   OUTF SPECIAL  PARAMS~~~ OPTIONS~~~ FLAGS
            ;#  chxformat       inf                                     [-m]
            ;#  0        [none][none][none] [none]  [none]  [none]       1
            ;#          
            ;#      1gets
            ;#  map:  1

            set map [list 1]                    ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set specialflag ""                  ;#  flag for any special data on CDPcmdline
            set opstart 0                       ;#  Index of first optional CDPcmdline item: zero if none
            set flagstart 1                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list m]           ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 0                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 0                        ;#  Program produces sound output (or not)
        } \
        ^$evv(CHXFORMATG)$ {
            ;#  chxformat -g2       infile
            ;#  0         1         2
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~ OPTIONS~~~ FLAGS
            ;#  chxformat       inf outf
            ;#  0        [none]  1  2   [none]  [none]      3          [none]
            ;#          
            ;#      1gets
            ;#  map:2

            set map [list 2]                    ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set specialflag ""                  ;#  flag for any special data on CDPcmdline
            set opstart 0                       ;#  Index of first optional CDPcmdline item: zero if none
            set flagstart 0                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set outfilepos -1                   ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(CHXFORMAT)$ {
            ;#  chxformat -g1  [-sMASK] infile
            ;#  0         1         2       3
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~ OPTIONS~~~ FLAGS
            ;#  chxformat       inf outf                    [-sMASK] 
            ;#  0        [none]  1  2   [none]  [none]      3         [none]
            ;#          
            ;#      2gets 3gets
            ;#  map:3     1

            set map [list 3 1]                  ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set specialflag ""                  ;#  flag for any special data on CDPcmdline
            set opstart 3                       ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 1]             ;#  Default values of any options
            set flagstart 0                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list s]           ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos -1                   ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(INTERLX)$ {
            ;#  interlx [-tN] outfile infile [infile2 ....]
            ;#  0         1     2       3       4
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF             OUTF    SPECIAL  PARAMS~~~ OPTIONS~~~ FLAGS
            ;#  interlx infile1 [infile2 ....]  outfile             N 
            ;#  0        1                      2       [none]      3
            ;#  EXCEPTIONAL CASE
            set len [llength $args]
            incr len -2
            set offil [lindex $args $len]
            set val "-t"
            append val [lindex $args end]
            incr len -1
            set cmd [lrange $args 0 $len]
            set cmd [linsert $cmd 1 $val]
            set cmd [linsert $cmd 2 $offil]
            set standopos 2 
            set done 1
        } \
        ^$evv(COPYSFX)$ {
            ;#  copysfx [-d] [-h] [-sSTYPE] [-tFORMAT]  infile outfile
            ;#  0       1     2     3           4       5      6
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~ OPTIONS~~~~~~~~~~~~~~~~~ FLAGS
            ;#  copysfx         inf outf                    [-sSTYPE] [-tFORMAT]    [-d] [-h]
            ;#  0        [none]  1   2   [none]   [none]     3          4            5     6
            ;#          
            ;#      1gets 2gets 3gets 4gets 5gets 6gets
            ;#  map:5     6       3     4     1     2    

            set map [list 5 6 3 4 1 2]          ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set opstart 3                       ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 1 0]           ;#  Default values of any options
            set flagstart 5                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list s t d h]     ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 6                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(NJOIN)$ {
            ;#  njoin [-sSECS | -SSECS]  [-cCUEFILE] [-x] filelist.txt outfile
            ;#  0       1     2     3           4       5      6
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF             OUTF SPECIAL  PARAMS~~~ OPTIONS~~~~~~~~~~~~~~~~ FLAGS
            ;#  njoin           inf1 [inf2 ....] outf                   [-sSECS]    [-x]    [-c]
            ;#  0       [none]  1    etc.             [none]  [none]    len-3       len-2   len-1
            ;#
            ;#  EXCEPTIONAL CASE

            set len [llength $args]
            incr len -1
            set cues [lindex $args $len]
            if {$cues} {
                set cues -c
                append cues $evv(DFLT_OUTNAME)
                append cues "1"
            } else {
                unset cues
            }
            incr len -1
            set xact [lindex $args $len]
            if {$xact} {
                set xact "-x"
            } else {
                unset xact
            }
            incr len -1
            set secs [lindex $args $len]
            if {$secs < 0} {
                set secs [expr -$secs]
                set secsep -S$secs
            } elseif {$secs > 0} {
                set secsep -s$secs
            }
            set cmd [file join  $evv(CDPROGRAM_DIR) njoin]
            if {[info exists secsep]} {
                lappend cmd $secsep
            }
            if {[info exists cues]} {
                lappend cmd $cues
            }
            if {[info exists xact]} {
                lappend cmd $xact
            }
            incr len -1
            set outfil [lindex $args $len]
            incr len -1
            set subcmd [lrange $args 1 $len]
            foreach fnam $subcmd {
                if {![info exists njoin_srate]} {
                    set njoin_srate $pa($fnam,$evv(SRATE))
                } elseif {$njoin_srate != $pa($fnam,$evv(SRATE))} {
                    Inf "File $fnam Has Different Sample Rate To Previous Files: Cannot Proceed"
                    return {}
                }
                if {![info exists njoin_chans]} {
                    set njoin_chans $pa($fnam,$evv(CHANS))
                } elseif {$njoin_chans != $pa($fnam,$evv(CHANS))} {
                    Inf "File $fnam Has Different Number Of Channels To Previous Files: Cannot Proceed"
                    return {}
                }
                if {[info exists xact]} {
                    if {$njoin_srate != 44100} {
                        Inf "File $fnam Has Sample Rate $njoin_srate (Must Be 44100 For Use On C.D.)"
                        return {}
                    }
                    if {$njoin_chans != 2} {
                        Inf "File $fnam Has $njoin_chans Channels (Must Be Stereo For C.D.)"
                        return {}
                    }
                    set njoin_dur $pa($fnam,$evv(DUR))
                    if {$njoin_dur < 4.0} {
                        Inf "File $fnam Too Short ($njoin_dur secs) For Use On C.D. (Min Duration 4 secs)"
                        return {}
                    }
                }
            }
            set infile $evv(MACH_OUTFNAME)$evv(TEXT_EXT) 
            if [catch {open $infile "w"} zit] {
                return {}
            }
            foreach fnam $subcmd {
                puts $zit $fnam
            }
            close $zit
            lappend cmd $infile $outfil
            if {[info exists cues]} {
                set standopos 2 
            } else {
                set standopos 1
            }
            set done 1
        } \
        ^$evv(NJOINCH)$ {
            ;#  njoin [-x]  infile
            ;#  0       1     2
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF             OUTF SPECIAL  PARAMS~~~ OPTIONS~~~ FLAGS
            ;#  njoin           inf1 [inf2 ....]                                    [-x]
            ;#  0        [none]  1   2          [none][none]   [none]   [none]       3
            ;#          
            ;#  EXCEPTIONAL CASE

            set val [lindex $args end]
            set cmd [file join  $evv(CDPROGRAM_DIR) njoin]
            if {[string match $val 1]} {
                lappend cmd "-x"
            }
            set len [llength $args]
            incr len -3
            set subcmd [lrange $args 1 $len]
            set infile $evv(MACH_OUTFNAME)$evv(TEXT_EXT)
            if [catch {open $infile "w"} zit] {
                return {}
            }
            foreach fnam $subcmd {
                puts $zit $fnam
            }
            close $zit
            lappend cmd $infile
            set standopos 0
            set done 1
        } \
        ^$evv(NMIX)$ {
            ;#  nmix [-d] [-f] [-oOFFSET]  infile1 infile2 outfile
            ;#  0      1    2       3       4       5      6
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF         OUTF SPECIAL  PARAMS~~~ OPTIONS~~~~ FLAGS
            ;#  nmix            inf inf2    outf                    [-oOFFSET]  [-d] [-f]
            ;#  0        [none]  1  2       3   [none]   [none]     4           5     6
            ;#          
            ;#      1gets 2gets 3gets 4gets 5gets 6gets
            ;#  map:5     6       4     1     2     3    

            set map [list 5 6 4 1 2 3]          ;#  Position in cdpcmdline of each item in truecmdline
            set specialpos 0                    ;#  Index of any special data on CDPcmdline
            set opstart 4                       ;#  Index of first optional CDPcmdline item: zero if none
            set opdefaults [list 0]             ;#  Default values of any options
            set flagstart 5                     ;#  Index of first rawflag on CDPcmdline: zero if none
            set flag_inserts [list o d f]       ;#  Space (" ") (or flag if flagged) for each option, Lettername for each flag
            set outfilepos 6                    ;#  Position of outfile in true-cmdline, SET TO -1 if none
            set float_out_flag 0                ;#  Program has a float-out flag? at this position in CDP cmdline
            set sndout 1                        ;#  Program produces sound output (or not)
        } \
        ^$evv(RMSINFO)$ {
            ;#  rmsinfo [-n]  infile1 [startpos [endpos]]
            ;#  0       1       2         3         4
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF  OUTF  SPECIAL  PARAMS~~~~~~~~~~~ OPTIONS~~~~ FLAGS
            ;#  rmsinfo         inf  (outf)         startpos endpos              [-n]
            ;#  0        [none]  1  [none]          2          3      [none]      4
            ;#          
            ;#  EXCEPTIONAL CASE
            ;#          

            set cmd [file join $evv(CDPROGRAM_DIR) rmsinfo]
            set val [lindex $args end]
            if {$val} {
                lappend cmd "-n"
            }
            lappend cmd [lindex $args 1]
            set len [llength $args]
            incr len -2
            set stt [expr $len - 1]
            set subcmd [lrange $args $stt $len]
            set cmd [concat $cmd $subcmd]
            set standopos 0
            set done 1
        } \
        ^$evv(SFEXPROPS)$ {
            ;#  sfprops infile1
            ;#  0       1
            ;#  CDP FORMAT....
            ;#  PROGNAME  MODE  INF  OUTF SPECIAL  PARAMS~~~ OPTIONS~~~ FLAGS
            ;#  sfprops         inf  (outf)
            ;#  0        [none]  1        [none]    [none]   [none]    [none]
            ;#          
            ;#  EXCEPTIONAL CASE

            set cmd [file join  $evv(CDPROGRAM_DIR) sfprops]
            lappend cmd [lindex $args 1]
            set standopos 0
            set done 1

        } \
        default {   
            Inf "Unknown Process"
            return {}
        }

    if {!$done} {
        if {$float_out && $sndout && ($float_out_flag == 0)} {
            if {[IsMchanToolkit $pprg]} {
                set str [MchanToolKitNames $pprg]
            } else {
                set str [lindex $prg($pprg) $evv(UMBREL_INDX)]
            }
            Inf "The Standalone Program '$str' Cannot Produce Floating Point Output"
        }
        set cnt 0
        set flag_cnt 0
        set cmd1 [lindex $args 0]
        foreach item [lrange $args 1 end] {
            incr cnt
            if {$cnt == $specialpos} {
                if {[string match $item "0"]} { ;#  SET-FOR-ELIMINATION SPECIAL DATA, WHERE IT IS NOT USED 
                    set item "@"                ;#  (optional special data only)
                } else {
                    set zz $specialflag
                    append zz $item
                    set item $zz
                }
            } elseif {($flagstart > 0) && ($cnt >= $flagstart)} {
                if {[IsNumeric $item] && ($item == 0.0)} {
                    if {($cnt == $float_out_flag) && $float_out} {
                        set item "-"            ;#  FORCE FLOAT_OUT TO BE SET
                        append item [lindex $flag_inserts $flag_cnt]
                    } else {
                        set item "@"            ;#  SET-FOR-ELIMINATION RAW FLAGS WHERE SET TO 0
                    }
                } else {
                    set item "-"            ;#  INSERT TRUE FLAG LETTER
                    append item [lindex $flag_inserts $flag_cnt]
                }
                incr flag_cnt
            } elseif {($opstart > 0) && ($cnt >= $opstart)} {   ;#  INSERT FLAG LETTERS WHERE NESS
                set opval   [lindex $opdefaults $flag_cnt]
                set flagval [lindex $flag_inserts $flag_cnt]
                if {[Flteq $item $opval]} {
                    set item @
                } elseif {![string match $flagval " "]} {
                    set out "-"
                    append out [lindex $flag_inserts $flag_cnt]
                    append out $item
                    set item $out
                }
                incr flag_cnt
            }
            lappend cmd1 $item
        }
        set cmd [lindex $cmd1 0]
        foreach pos $map {                  ;#  REORDER CMDLINE AS ORIGINAL
            lappend cmd [lindex $cmd1 $pos]
        }
        set clen [llength $cmd]
        incr clen -1
        while {$clen > 0} {                 ;#  REMOVE NON-OPERATIONAL FLAGGED ITEMS
            set item [lindex $cmd $clen]
            if {[string match $item "@"]} {
                set cmd [lreplace $cmd $clen $clen]
                if {$clen <$outfilepos} {   ;#  KEEP TRACK OF outfilepos IN CMDLINE USED
                    incr outfilepos -1
                }
            }
            incr clen -1
        }
    set standopos $outfilepos
    }
    if {![ParameterCheckForNonCDPFormatProgs $args]} {
        set cmd {}
    }
    return $cmd
}

#---- Parameters Check for Nonstandard programs

proc ParameterCheckForNonCDPFormatProgs {args} {
    global evv pa pprg chlist notwavexambisonic wavambisonic_to_wxyz ambwxyz ambextflag
    catch {unset ambwxyz}
    set args [lindex $args 0]
    switch -regexp -- $pprg \
        ^$evv(RMVERB)$ {
            ;#  PREDELAY CANNOT EXCEED DURATION + TRAILTIME
            ;#
            ;#  PROGNAME  MODE  INF OUTF SPECIAL  PARAMS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTIONS~~~~~~~~~ FLAGS
            ;#  rmverb          inf outf taps.txt rmsize rmgain  mix  fdbk  absorb  lpfrq  trailtime [-LN -HN -pN -cN -d -f]        
            set fnam [lindex $args 1]
            set trailtime [lindex $args 10]
            set predelay [expr [lindex $args 13] * $evv(MS_TO_SECS)]
            if {[string length [file tail $fnam]] <= 0} {
                append fnam $evv(SNDFILE_EXT)
            }
            set maxval [expr $pa($fnam,$evv(DUR)) + $trailtime]
            if {$predelay >= $maxval} {
                Inf "Predelay Value Is Too Large: Must Be Less Than Infile Duration Plus Decay Tail Duration"
                return 0
            }
        } \
        ^$evv(ABFPAN)$ {
            ;#  abfpan [-b] [-x] [-oN]  infile outfile startpos endos
            if {![info exists chlist]} {
                Inf "This Process Needs A Single Mono Soundfile"
                return 0
            }
            if {[llength $chlist] != 1} {
                Inf "This Process Only Works With A Single Mono Soundfile"
                return 0
            }
            set fnam [lindex $chlist 0]
            if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
                Inf "This Process Only Works With A Single Mono Soundfile"
                return 0
            }
            set len [llength $args]
            incr len -1
            set ambi_wav_flag [lindex $args $len]
            if {$ambi_wav_flag} {
                incr len -1
                set wav_wav_flag [lindex $args $len]
                if {$wav_wav_flag} {
                    Inf "You Cannot Set ~Both~ Output Format Flags"
                    return 0
                }
            }
            if {$ambi_wav_flag || $wav_wav_flag} {      ;#  Anything NOT wavex_ambi is forced to wav extension
                set notwavexambisonic 1
            }
            if {$ambi_wav_flag} {
                if {$wavambisonic_to_wxyz} {
                    set ambwxyz 1
                }
            }
        } \
        ^$evv(ABFPAN2)$ - \
        ^$evv(ABFPAN2P)$ {
            ;#  abfpan2 [-gGAIN] [-w] infile outfile startpos endpos
            ;#  abfpan2 [-gGAIN] [-w] [-p[DEG]]  infile outfile startpos endpos
            if {![info exists chlist]} {
                Inf "This Process Needs A Single Mono Soundfile"
                return 0
            }
            if {[llength $chlist] != 1} {
                Inf "This Process Only Works With A Single Mono Soundfile"
                return 0
            }
            set fnam [lindex $chlist 0]
            if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
                Inf "This Process Only Works With A Single Mono Soundfile"
                return 0
            }
            set ambi_wav_flag [lindex $args end]
            if {$ambi_wav_flag} {       ;#  Anything NOT wavex_ambi is forced to wav extension
                set notwavexambisonic 1
                if {$wavambisonic_to_wxyz} {
                    set ambwxyz 1
                }
            }
        } \
        ^$evv(CHANNELX)$ {
            ;#  channelx [-oBASENAME] infile chan_no [chan_no .....]
            if {![info exists chlist]} {
                Inf "This Process Needs A Single Multichannel Soundfile"
                return 0
            }
            if {[llength $chlist] != 1} {
                Inf "This Process Only Works With A Single Multichannel Soundfile"
                return 0
            }
            set fnam [lindex $chlist 0]
            if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) < 2)} {
                Inf "This Process Only Works With A Single Multichannel Soundfile"
                return 0
            }
        } \
        ^$evv(CHORDER)$ {
            ;#  chorder infile outfile orderstring
            if {![info exists chlist]} {
                Inf "This Process Needs A Single Multichannel Soundfile"
                return 0
            }
            if {[llength $chlist] != 1} {
                Inf "This Process Only Works With A Single Multichannel Soundfile"
                return 0
            }
            set fnam [lindex $chlist 0]
            set inchans $pa($fnam,$evv(CHANS))
            if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($inchans < 2)} {
                Inf "This Process Only Works With A Single Multichannel Soundfile"
                return 0
            }
            set orderstring [lindex $args end]
            set len [string length $orderstring]
            if {$len > 26} {
                Inf "The Orderstring Is Too Long (Max 26 Characters)"
                return 0
            }
            set n 0
            while {$n < $len} {
                set thischar [string index $orderstring $n]
                if {![regexp {^[a-z0]$} $thischar]} {
                    Inf "Invalid Character ($thischar) In Orderstring (Only a-z And Zero Permitted)"
                    return 0
                }
                incr n
            }
            if {([string first "c" $orderstring] >= 0) && ($inchans < 3)}  {set badstring 1}
            if {([string first "d" $orderstring] >= 0) && ($inchans < 4)}  {set badstring 1}
            if {([string first "e" $orderstring] >= 0) && ($inchans < 5)}  {set badstring 1}
            if {([string first "f" $orderstring] >= 0) && ($inchans < 6)}  {set badstring 1}
            if {([string first "g" $orderstring] >= 0) && ($inchans < 7)}  {set badstring 1}
            if {([string first "h" $orderstring] >= 0) && ($inchans < 8)}  {set badstring 1}
            if {([string first "i" $orderstring] >= 0) && ($inchans < 9)}  {set badstring 1}
            if {([string first "j" $orderstring] >= 0) && ($inchans < 10)} {set badstring 1}
            if {([string first "k" $orderstring] >= 0) && ($inchans < 11)} {set badstring 1}
            if {([string first "l" $orderstring] >= 0) && ($inchans < 12)} {set badstring 1}
            if {([string first "m" $orderstring] >= 0) && ($inchans < 13)} {set badstring 1}
            if {([string first "n" $orderstring] >= 0) && ($inchans < 14)} {set badstring 1}
            if {([string first "o" $orderstring] >= 0) && ($inchans < 15)} {set badstring 1}
            if {([string first "p" $orderstring] >= 0) && ($inchans < 16)} {set badstring 1}
            if {([string first "q" $orderstring] >= 0) && ($inchans < 17)} {set badstring 1}
            if {([string first "r" $orderstring] >= 0) && ($inchans < 18)} {set badstring 1}
            if {([string first "s" $orderstring] >= 0) && ($inchans < 19)} {set badstring 1}
            if {([string first "t" $orderstring] >= 0) && ($inchans < 20)} {set badstring 1}
            if {([string first "u" $orderstring] >= 0) && ($inchans < 21)} {set badstring 1}
            if {([string first "v" $orderstring] >= 0) && ($inchans < 22)} {set badstring 1}
            if {([string first "w" $orderstring] >= 0) && ($inchans < 23)} {set badstring 1}
            if {([string first "x" $orderstring] >= 0) && ($inchans < 24)} {set badstring 1}
            if {([string first "y" $orderstring] >= 0) && ($inchans < 25)} {set badstring 1}
            if {([string first "z" $orderstring] >= 0) && ($inchans < 26)} {set badstring 1}
            if {[info exists badstring]} {
                Inf "More Letter Codes Than Channels Used: e.g. 4 channel should use only a-d"
                return 0
            }
            if {[string match [file extension $fnam] ".amb"]} {
                if {($inchans < 3) || ($inchans == 10) || (($inchans >11) && ($inchans < 16)) || ($inchans > 16)} {
                    Inf "Input \".amb\" File Does Not Have Appropriate Channel-Count For An Ambisonic File: Output Will Be \".wav\""
                    set notwavexambisonic 1
                }
            } else {
                if {!$ambextflag} {             ;#  ".amb" extension can be forced
                    set notwavexambisonic 1
                }
                unset ambextflag
            }
        } \
        ^$evv(FMDCODE)$ {
            ;#  fmdcode [-x]  [-w] infile outfile layout
            if {![info exists chlist]} {
                Inf "This Process Needs A Single Ambisonic Soundfile"
                return 0
            }
            if {[llength $chlist] != 1} {
                Inf "This Process Only Works With A Single Ambisonic Soundfile"
                return 0
            }
            set fnam [lindex $chlist 0]
            if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) < 2)} {
                Inf "This Process Only Works With A Single Ambisonic Soundfile"
                return 0
            }
            set flagcnt 0
            set lspkrposset 0
            set len [llength $args]
            incr len -1
            set len_less_one [expr $len - 1]
            if {[string match [lindex $args $len] "1"]} {
                incr flagcnt
            }
            if {[string match [lindex $args $len_less_one] "1"]} {
                set lspkrposset 1
                incr flagcnt
            }
            if {$flagcnt == 2} {
                Inf "You Cannot Set ~Both~ Output Format Flags"
                return 0
            }
            set outformat [lindex $args 3]
            if {$lspkrposset} {
                switch -- $outformat {
                    3 -
                    5 -
                    8 -
                    9 -
                    10 -
                    11 {
                        Inf "Lspkr Positions Cannot Be Set In This Output Format"
                        return 0
                    }
                }
            }
        } \
        ^$evv(CHXFORMAT)$ - \
        ^$evv(CHXFORMATG)$ {
            if {![info exists chlist]} {
                Inf "This Process Needs A Single Multichannel Soundfile"
                return 0
            }
            if {[llength $chlist] != 1} {
                Inf "This Process Only Works With A Single Multichannel Soundfile"
                return 0
            }
            set fnam [lindex $chlist 0]
            set inchans $pa($fnam,$evv(CHANS))
            if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($inchans < 2)} {
                Inf "This Process Only Works With A Single Multichannel Soundfile"
                return 0
            }
            set targetfile [lindex $args 2]
            set infile [lindex $args 1]
            if [catch {file copy $infile $targetfile} zit] {
                Inf "Cannot Create Copy Of Input File"
                return 0
            }
        } \
        ^$evv(INTERLX)$ {
            ;#  interlx [-tN] outfile infile [infile2 ....]
            if {![info exists chlist]} {
                Inf "This Process Needs Mono And/Or Stereo Soundfiles"
                return 0
            }
            if {[llength $chlist] < 2} {
                Inf "This Process Needs At Least Two Soundfiles"
                return 0
            }
            foreach fnam $chlist {
                if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
                    Inf "This Process Accepts Mono And/Or Stereo Soundfiles Only"
                    return 0
                }
                if {![info exists interlchans]} {
                    set interlchans $pa($fnam,$evv(CHANS))
                    if {($interlchans != 1) && ($interlchans != 2)} {
                        Inf "First Soundfile Is Neither Mono Nor Stereo: Cannot Proceed"
                        return 0
                    }
                } elseif {$interlchans != $pa($fnam,$evv(CHANS))} {
                    Inf "Channel Count Of Infiles Do Not Match: Cannot Proceed"
                    return 0
                }
            }
            set in_file_cnt [llength $chlist]
            set outformat [lindex $args end]
            switch -- $outformat {
                2 {
                    if {$interlchans == 1} {
                        if {($in_file_cnt != 1) && ($in_file_cnt != 2) && ($in_file_cnt != 4)} {
                            set badchans 1
                        }
                    } else {
                        if {$in_file_cnt != 2} {
                            set badchans 1
                        }
                    }
                }
                3 { 
                    if {$interlchans == 1} {
                        if {$in_file_cnt != 4} {
                            set badchans 1
                        }
                    } else {
                        if {$in_file_cnt != 2} {
                            set badchans 1
                        }
                    }
                }
                4 { 
                    if {$interlchans == 1} {
                        if {$in_file_cnt != 6} {
                            set badchans 1
                        }
                    } else {
                        if {$in_file_cnt != 3} {
                            set badchans 1
                        }
                    }
                }
                5 { 
                    if {$interlchans == 1} {
                        if {($in_file_cnt < 2) || ($in_file_cnt > 16)} {
                            set badchans 1
                        } elseif {($in_file_cnt > 12) && ($in_file_cnt < 16)} {
                            set badchans 1
                        } elseif {$in_file_cnt == 10} {
                            set badchans 1
                        }
                    } else {                            
                        if {($in_file_cnt != 2) && ($in_file_cnt != 3) && ($in_file_cnt != 4) && ($in_file_cnt != 8)} {
                            set badchans 1
                        }
                    }
                }
                6 { 
                    if {$interlchans == 1} {
                        if {$in_file_cnt != 5} {
                            set badchans 1
                        }
                    } else {
                        set badchans 1
                    }
                }
                7 -
                8 { 
                    if {$interlchans == 1} {
                        if {$in_file_cnt != 8} {
                            set badchans 1
                        }
                    } else {
                        if {$in_file_cnt != 4} {
                            set badchans 1
                        }
                    }
                }
            }
            if [info exists badchans] {
                Inf "Number Of Input Channels Does Not Tally With Output Format"
                return 0
            }
        } \
        ^$evv(COPYSFX)$ {
            ;#  copysfx [-d] [-h] [-sSTYPE] [-tFORMAT]  infile outfile
            if {![info exists chlist]} {
                Inf "This Process Needs A Soundfile Input"
                return 0
            }
            set fnam [lindex $chlist 0]
            if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
                Inf "This Process Needs A Soundfile Input"
                return 0
            }
            if {![string match [file extension $fnam] ".wav"]} {
                Inf "This Process Only Works With \".wav\" Files"
                return 0
            }
            set inchans $pa($fnam,$evv(CHANS))
            set outformat [lindex $args 4]
            switch -- $outformat {
                2 {
                    if {!(($inchans == 1) || ($inchans == 2) || ($inchans == 4))} {
                        Inf "Input File Must Be Mono, Stereo Or 4-Channel For This Output Format"
                        return 0
                    }
                }
                3 {
                    if {$inchans != 4} {
                        Inf "Input File Must Be 4-Channel For This Output Format"
                        return 0
                    }
                }
                4 {
                    if {$inchans != 6} {
                        Inf "Input File Must Be 6-Channel For This Output Format"
                        return 0
                    }
                }
                5 {
                    if {($inchans < 3) || ($inchans > 16) || ($inchans == 10) || (($inchans >11) && ($inchans < 16))} {
                        Inf "Input Channel Count ($inchans) Does Not Tally With Any Known Ambisonic Output Format"
                        return 0
                    }
                }
                6 {
                    if {$inchans != 5} {
                        Inf "Input File Must Be 5-Channel For This Output Format"
                        return 0
                    }
                }
                7 -
                8 {
                    if {$inchans != 8} {
                        Inf "Input File Must Be 8-Channel For This Output Format"
                        return 0
                    }
                }
            }
        }

    return 1
}   

#~~~~~~~~~~~~~~~~~~~~~~~~~
#   BATCHFILING
#~~~~~~~~~~~~~~~~~~~~~~~~~

#----- Syntax of standalone progs

proc StandaloneNonCDPFormatSyntax {ll} {
    $ll delete 0 end
    set line "TAPDELAY  \[-f\]  infile  outfile  tapgain  feedback  mix  taps.txt  \[trailtime\]"
    $ll insert end $line
    set line "(1)   taps.txt is data on individual delays (time amp \[pan\])"
    $ll insert end $line
    set line "RMRESP  \[-amaxamp\] \[-rres\]  outfile  liveness  no-of-reflections  RoomLen  Width  Height  SrcPositionL  W  H  ListenerPosL  W  H"
    $ll insert end $line
    set line "RMVERB  \[-etaps.txt  -LA  -HB  -pC  -cD  -d  -f\]  infile  outfile  rmsize  rmgain  mix  feedback  absorption  lpfrq  trailtime"
    $ll insert end $line
    set line "(1)   taps.txt is data on individual delays (time amp \[pan\])."
    $ll insert end $line
    set line "(2)   -L and -H take cutoff frq(Hz) of lopass and hipass filters on source input."
    $ll insert end $line
    set line "(3)   -p takes predelay in milliseconds..........-c takes number of output channels (1-16): default 2."
    $ll insert end $line
    set line "(4)   -d doubles the air-absorption filtering.........-f Forces floating-point output."
    $ll insert end $line
    set line "(5)   rmsize: 1 for small: 2 for medium: 3 for large."
    $ll insert end $line
    set line "(6)   absorption is cutoff frq for lopass filter representing air-absorption (try 2500 for large, 4200 for small room)."
    $ll insert end $line
    set line "(7)   lpfrq is cutoff frq for lopass filter on input to reverb."
    $ll insert end $line
}

#------ Call function which Maps CDP cmd format to standalone prog formats

proc StandAloneCommand {cmd} {
    global notwavexambisonic pprg evv
    set mapcmd [concat MapFuncForNonCDPFormatProgs $cmd]
    set cmd [eval $mapcmd]
    set cmdname [file rootname [file tail [lindex $cmd 0]]]
    switch -- $cmdname {
        "abfpan" {                                                  
            ;#  CDP uses          -b for wav-ambi,   -x for wav,          noflag for wavex-ambi
            ;#  Mchantoolkit uses -b for wav-ambi,   -x  for wavex-ambi, noflag for wav
            ;#              by this stage BOTH flags cannot have been set
            set k [lsearch $cmd "-x"]
            if {$k >= 0} {
                set cmd [lreplace $cmd $k $k]
            } else {
                set k [lsearch $cmd "-b"]
                if {$k < 0} {
                    set cmd [linsert $cmd 1 "-x"]
                }
            }
            set cmd [ForceMTKFileExtensions 0 $cmd]
        }
        "channelx"  {
            set cmd [ExtractChannelDataAndModifyCmdline $cmd]
            set notwavexambisonic 1
            set cmd [ForceMTKFileExtensions 1 $cmd]
        }
        "chxformat" {
            if {$pprg == $evv(CHXFORMATG)} {
                set cmd [linsert $cmd 1 "-g2"]
            } elseif {$pprg == $evv(CHXFORMAT)} {
                set notwavexambisonic 1
            }
        }
        "copysfx" {
            set k [lsearch $cmd "-t-1"]         ;#  if format set to -1, equivalent to NO -t flag
            if {$k >= 0} {
                set cmd [lreplace $cmd $k $k]
            }
            set k [lsearch $cmd "-s0"]          ;#  if samptype set to 0, equivalent to NO -s flag
            if {$k >= 0} {
                set cmd [lreplace $cmd $k $k]
            }
            set cmd [ForceMTKFileExtensions 0 $cmd]
        }
    }
    return $cmd
}

#---- Deduce from process name, if process is a standalone process

proc GetStandaloneProgramNoIfNonCDPFormat {str} {
    global evv prg
    set n $evv(TOP_OF_CDP)
    incr n
    while {$n <= $evv(MAX_PROCESS_NO)} {
        if {[info exists prg($n)] && [string match -nocase $str [lindex $prg($n) $evv(UMBREL_INDX)]]} {
            switch -regexp -- $str \
                ^$evv(TAPDELAY)$ - \
                ^$evv(RMRESP)$   - \
                ^$evv(RMVERB)$   { 
                    return $n
                }
        }
        incr n
    }
    set n $evv(ABFPAN)
    while {$n <= $evv(ABFPAN2P)} {
        if {[string match -nocase $str [GetMchanToolKitProgname $n]]} {
            return $n
        }
        incr n
    }
    return 0
}

proc ListStandalonesWithNoFloatOutputOption {} {
    global nofloat_standalones evv prg released
    set n $evv(TOP_OF_CDP)
    incr n
    while {$n <= $evv(MAX_PROCESS_NO)} {
        if {[info exists prg($n)] && [HasSndoutButNoFloatoutFlag $n]} {
            lappend nofloat_standalones [lindex $prg($n) 0]
        }
        incr n
    }
    if {[info exists released(mchantoolkit)]} {
        if {![info exists nofloat_standalones]} {
            set nofloat_standalones {}
        }
        set n $evv(ABFPAN)
        while {$n < $evv(ABFPAN2P)} {
            set nam [GetMchanToolKitProgname $n]
            if {[lsearch $nofloat_standalones $nam] < 0} {
                lappend nofloat_standalones $nam
            }
            incr n
        }
        if {[llength $nofloat_standalones] <= 0} {
            unset nofloat_standalones
        }
    }
}

################################################
# THESE PROCESSES DO NOT APPLY TO MCHANTOOLKIT #
################################################

proc SaveStandalone {} {
    global has_standalones prg evv
    set standfile [file join $evv(CDPRESOURCE_DIR) $evv(STANDALONE)$evv(CDP_EXT)]
    set has_standalones 0
    set n $evv(TOP_OF_CDP)
    incr n
    while {$n <= $evv(MAX_PROCESS_NO)} {
        if {[info exists prg($n)]} { 
            set prgname [lindex $prg($n) $evv(UMBREL_INDX)]
            set prgname [file join $evv(CDPROGRAM_DIR) $prgname]
            if {[file exists $prgname$evv(EXEC)]} {
                lappend zz [file tail $prgname]
                set has_standalones 1
            }
        }
        incr n
    }
    if {$has_standalones} {
        if {![file exists $standfile]} {
            set msg "Your System Has The Following Stand Alone Programs\n\n"
            set cnt 0
            foreach nam $zz {
                incr cnt
                if {$cnt > 20} {
                    append msg "\nAnd More"
                    break
                }
                append msg "$nam    "
            }
            append msg "\n\n"
            append msg "1) Standalone programs can be used\n"
            append msg "      just like standard CDP program,\n"
            append msg "      and will work in batchfile operations\n"
            append msg "      and 'Instruments'.\n"
            append msg "2) Some standalone programs cannot be forced\n"
            append msg "      to give floating point output\n"
            append msg "      by the global Sound Loom flag.\n"
            Inf $msg
            if [catch {open $standfile "w"} zit] {
                Inf "Cannot Open File $standfile To Remember You Have Standalone Programs"
                return
            }
            close $zit
        }
    } elseif {[file exists $standfile]} {
        if [catch {file delete $standfile} zit] {
            Inf "Cannot Remove File '$standfile' To Remember You Have No Standalone Programs"
            return
        }
    }
}

#---- Construct a DUMMY cmdline for use in instrument creation or History

proc CreateDummyStandaloneCmd {in_instrument} {
    global evv prg pprg mmod ins pa hst float_out o_nam pmcnt chlist

    if [IsMchanToolkit $pprg] {
        set cmd [file join $evv(CDPROGRAM_DIR) [GetMchanToolKitProgname $pprg]]
    } else {
        set cmd [file join $evv(CDPROGRAM_DIR) [lindex $prg($pprg) $evv(UMBREL_INDX)]]
    }
    lappend cmd $pprg $mmod
    if {$in_instrument} {
        if [info exists ins(chlist)] {
            set infilecnt [llength $ins(chlist)]
            set ch_list $ins(chlist)
        } else {
            set infilecnt 0
        }
    } else {
        if [info exists chlist] {
            set infilecnt [llength chlist]
            set ch_list $chlist
        } else {
            set infilecnt 0
        }
    }
    lappend cmd $infilecnt
    if {$infilecnt > 0} {                               ;#  If there are any infiles
        set fnam [lindex $ch_list 0]
        set propno 0
        while {$propno < $evv(CDP_PROPS_CNT)} {         ;#  Send Properties of first input file
            lappend cmd $pa($fnam,$propno)
            incr propno
        }
    }
    if {$infilecnt > 0} {                               ;#  If there are any infiles
        foreach fnam [lrange $ch_list 0 end] {          ;#  And Names of all the input files
            lappend cmd $fnam
            lappend hst(infiles) $fnam
        }
    }
    if {$float_out} {
        set out_name $evv(FLOAT_OUT)
        append out_name $o_nam
    } else {
        set out_name $o_nam
    }
    append out_name "0"
    set file_ext [GetProcessOutfileExtension $pprg $mmod]
    append out_name $file_ext
    lappend cmd $out_name                               ;#  Name of outfile(s), always a standard default-name
    set i 0
    while {$i < $pmcnt} {                               ;#  all parameters for the program
        set val [MarkNumericVals $i]                    ;#  Distinguish numbers from brkfiles
        lappend cmd $val
        incr i
    }
    return $cmd
}

proc ConvertStoredInsDummyCmdToStandaloneCmdWithNonCDPFormat {cmd} {
    global pprg evv 

    ;# CDP-FORMAT COMMAND AS RETURNED FROM INSTRUMENT STORE
    ;#
    ;#  0         1   2       3        (+CDP_PROPS_CNT) 
    ;# umbrella pprg mmod infilecnt props(if:infilecnt>0)   infiles [-f]outname   vals(@)
    ;# umbrella     [mmod]                                  infiles     outname   vals
    ;#
    ;# CDP-FORMAT COMMAND FOR STANDALONE PROGRAM, BEFORE MAPPING TO ORIGINAL FORMAT

    set propsbase 4
    set infilesbase [expr $propsbase + $evv(CDP_PROPS_CNT)]
    set propstop [expr $infilesbase - 1]
    set infilecnt [lindex $cmd 3]
    if {$infilecnt > 0} {
        set outfilepos [expr $infilesbase + $infilecnt]
    } else {
        set outfilepos $propsbase
    }
    set outname [lindex $cmd $outfilepos]
    set fltout 0
    if {[string match "-f*" $outname]} {
        set outname [string range $outname 2 end]
        set cmd [lreplace $cmd $outfilepos $outfilepos $outname]
        set fltout 1
    }
    set parambase [expr $outfilepos + 1]
    set n $parambase 
    set len [llength $cmd]
    while {$n < $len} {                                 ;#  REMOVE NUMERIC MARKERS
        set param [lindex $cmd $n]
        if {[string match "\@*" $param]} {
            set param [string range $param 1 end]
            set cmd [lreplace $cmd $n $n $param]
        }
        incr n
    }
    if {$infilecnt > 0} {
        set cmd [lreplace $cmd $propsbase $propstop]    ;#  DELETE LIST OF PROPERTIES
    }
    set cmd [lreplace $cmd 3 3]                         ;#  DELETE INFILECNT
    set mode [lindex $cmd 2]
    if {$mode == 0} {
        set cmd [lreplace $cmd 2 2]                     ;#  DELETE MODE, IF NO MODES
    }
    set orig_pprg $pprg
    set pprg [lindex $cmd 1] 
    set cmd [lreplace $cmd 1 1]                         ;#  DELETE PROCESS NUMBER
    set cmd [StandAloneCommand $cmd]                    ;#  MAP CMDLINE TO PROGRAM'S REAL FORMAT
    if {$fltout} {
        set fltlist [PosValOfStandaloneProgFloatoutFlagIfany $pprg]
        if {[llength $fltlist] > 0} {
            set fltpos [lindex $fltlist 0]
            set fltflg [lindex $fltlist 1]
            if {![string match [lindex $cmd $fltpos] $fltflg]} {
                set cmd [linsert $cmd $fltpos $fltflg]
            }
        }
    }
    set pprg $orig_pprg
    return $cmd
}

###################################
# END OF STANDALONE SPECIAL FUNCS #
###################################

#~~~~~~~~~~~~~~~~~~~~~~~~~
#   BULK PROCESSING ETC
#~~~~~~~~~~~~~~~~~~~~~~~~~

#---- Mask for progs which do not (or can be forced to not) change duration (or channel count, or filetype) of output

proc OnlyForEngineer {} {
    set p_mask    "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000001111"
    append p_mask "01000000000000000000000011110111"
    append p_mask "11100000000000000001000000000000"
    append p_mask "00000000000000000000000000100000"
    append p_mask "00000000000010000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000010000"
    append p_mask "00000000010000000010000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    return $p_mask
}

#---- Mask for progs where individual files can be duplicated on chosen files list

proc OnlyForMix {} {
    set p_mask    "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000011111"
    append p_mask "11111111100000000000000000000000"
    append p_mask "00000000001000000000001000000000"
    append p_mask "00000000000000000010100000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000001000000000000"
    append p_mask "00001001000000000000000000000000"
    append p_mask "00000000000000000000000000100000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    return $p_mask
}

#---- Mask for progs where where processes can be panned around multichannel space

proc OnlyForPanProcess {} {
    set p_mask    "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000100000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000001010010"
    append p_mask "00100100100000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000010000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    return $p_mask
}

#---- Mask for prog which pans process around multichannel space

proc OnlyForPanProcessPassTwo {} {
    set p_mask    "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000100000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    return $p_mask
}

#---- Mask for progs where multichan file has been split to individual chans: mono sndfiles out only

proc OnlyForBulksplit {} {
    set p_mask    "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00011111111111111111011111111111"
    append p_mask "11111111101111111010100000000000"
    append p_mask "00000000000000000000000011110111"
    append p_mask "11111111100001111101000000000000"
    append p_mask "00000000000000000000000000100010"
    append p_mask "00000000000010000000000000110000"
    append p_mask "00000100000000000000000010010110"
    append p_mask "00100000001000000011000001011011"
    append p_mask "00000000010000000100001100000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    append p_mask "00000000000000000000000000000000"
    return $p_mask
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   'WHICH?' PROCESS INFO
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#------ This program scans words in user's text for keywords, and relates these to program nos
#
#   outlist is list of possible programs so far
#

proc ScanWordKey {word i} {
    global prog_list cdpmenu evv
        

    #   CHECK WORDS To IGNORE

    if {[string match sound $word] 
    || [string match sounds $word]} {
        set kk 0 
        set tl ""
        while {$kk < $evv(MAXMENUNO)} {
            if [info exists cdpmenu($kk)] {
                set tl [concat $tl [lrange $cdpmenu($kk) $evv(MENUPROGS_INDEX) end]]
            }
            incr kk
        }
        set tl [lsort -integer -increasing $tl]
        Inf "'sound(s)' is not specific enough"

        set prog_list $tl
        return 0
    }

    #   CHECK WORDS WHICH CAN HAVE PREFIXES

    if [string match *align* $word] {
        set tl {148 179 180 313 369 376 418 420 461 482}
    } elseif [string match *bank* $word] {
        set tl {188 189 190 191 348 313 334 482 483}
    } elseif [string match *brk* $word] {
        set tl {163 164 165 166 167 168 342 258 364}
    } elseif [string match *cnt  $word] {
        set tl {76 100 138 347 228 229 278 420}
    } elseif [string match *count* $word] {
        set tl {76 100 138 347 228 229 278 420}
    } elseif [string match *cycl* $word] {
        if [string match cycl* $word] {
            set tl {111 349 340 120 122 140 193 318 320 331 333 338 339 343 344 260 266 380 287 418 419 420 442 449 460 461 463 466 474 476 483}
        } else {
            set tl {100 101 102 103 104 105 106 107 108 109 110 111 349 340 112 113 114 115 116 117 118 120 122 339 140 193 260 287 418 419 420 442 452 455 466 467 474}
        }
    } elseif [string match *format* $word] {
        set tl {182 256 416 482 483}
    } elseif [string match *gap $word] {
        set tl {177 232 310 370 381 376 415 416}
    } elseif [string match *glis* $word] {
        set tl {41 192 197 283 428 429 435 475 478 479}
    } elseif [string match *impos* $word] {
        if [string match impos* $word] {
            set tl {62 63 65 264 66 74 114 152 315 153 310 311 318 271 276 286 358 376 408 428 429 435 450 471 472 475 480 391 500}
        } else {
            set tl {62 63 65 264 66 74 114 152 315 153 169 317 98 170 171 173 256 174 175 176 177 178 326 179 180 181 182 183 379 310 313 314 318}
        }
    } elseif [string match *join* $word] {
        set tl {117 201 213 310 323 333 338 344 256 257 268 272 275 276 286 370 372 95 398 418 435 451 461 477}
    } elseif [string match *leaf $word] {
        set tl {72 171 320 256 257 275 415 416 443 449 451 458 461 468 476 478 482}
    } elseif [string match *leave $word] {
        set tl {72 104 139 171 320 333 338 275 372 95 420 451 463 468}
    } elseif [string match *morph* $word] {
        set tl {45 46 47 112 272 286 415 416 424 428 429 449 458 480 483 500}
    } elseif [string match *names $word] {
        set tl {176 177 309}
    } elseif [string match *order* $word] {
        set tl {110 141 333 338 344 352 256 257 416 443 449 458 478 482}
    } elseif [string match *pitch* $word] {
        if {[string match nonpitch* $word] || [string match unpitched $word]} {
            set tl {85 299 301 310 478}
        } elseif [string match pitch* $word] {
            set tl {48 92 309 50 51 52 53 54 55 56 57 58 59 60 61 62 63 69 304 84 85 86 87 88 118 124 125 126 127 128 129 130 131 132 133 134 135 136 137 374 142 144 197 283 199 200 236 298 299 300 301 302 305 310 334 342 258 344 97 191 348 259 263 271 272 273 276 280 284 364 383 428 429 435 436 437 441 442 450 470 471 472 478 479 482 483}
        } else {
            set tl {12 309 48 92 50 51 52 53 54 55 56 57 58 59 60 61 62 63 69 304 85 118 142 144 197 283 298 299 300 301 310 271 272 273 276 284 365 428 429 435 441 442 450 471 472 478 482 483}
        }
    } elseif [string match *position* $word] {
        if [string match reposit* $word] {
            set tl {147 352 256 370 372 373 374 417 376 380 383 399 404 405 406 407 409 410 411 412 413 414 416 419 420 460 461 466 478 483}
        } else {
            set tl {178 326 196 316 254 329 344 256 369 372 373 374 417 376 380 95 399 404 405 406 407 409 410 411 412 413 414 416 419 420}
        }
    } elseif [string match *rate $word] {
        set tl {217 219 376}
    } elseif [string match *ratio $word] {
        set tl {236 418 443}
    } elseif [string match *rhythm* $word] {
        set tl {143 144 147 318 338 343 344 369 370 372 376 416 418 419 420 475 476}
    } elseif [string match *stretch* $word] {
        if [string match timestretch* $word] {
            set tl {7 9 1003 119 378 433 120 121 122 123 140 141 142 143 145 177 199 323 331 339 345 351 154 155 156 111 352 368 259 260 262 266 277 281 372 376 94 287 417 428 429 474 476 478}
        } else {
            set tl {7 8 9 1003 105 106 119 377 433 120 121 122 123 139 140 145 177 199 200 383 323 331 339 345 351 154 155 156 260 373 94 287 417 483}
        }
    } elseif [string match *shrink* $word] {
        set tl {7 8 9 1003 105 106 119 120 121 122 123 145 154 155 156 177 199 200 383 352 259 370 372 376 416 417 432 468 483}
    } elseif [string match *warp* $word] {
        if [string match timewarp* $word] {
            set tl {7 9 1003 145 177 199 339 352 368 259 260 261 262 277 281 370 372 376 416 418 420 452 468 474}
        } else {
            set tl {8 9 1003 145 154 155 156 177 196 316 199 254 314 318 274 373 380 383 415 416 420 421 428 429 431 432 434 443 449 450 452 458 460 461 462 468 471 473 474 475 476 477 478 480 482 484 483 499 500}
        }
    } elseif [string match *wave $word] {
        set tl {237 403 467 470 478}
    }

    # IF PREFIX-TYPE WORD FOUND: DO THE BUSINESS
    
    if [info exists tl] {               ;#  IF tl already setup
        if {$i == 0} {                      ;#  If it's first pass, copy tl to progs_list
            catch {unset progs_list} in
            set prog_list $tl
        } else {                            ;#  else, compare progs_list so far with tl
            set listlen [llength $tl]
            eval {ResetProgslist $listlen} $tl
        }
        return 1
    }       

    # OTHERWISE, TEST WORDS ALPHABETICALLY, IN THE NORMAL WAY

    switch -- [string index $word 0] {
        "a" {
            switch -- $word {
                "alt"           { set tl {10} }
                "amp"           { set tl {1 159 195 338} }
                "amplitude"     { set tl {1 159 195 338 285 369 419 443 475 484} }
                "array"         { set tl {240 241 242 243 244 245 246 247 250 308 313 320 321 333 338 344 256 399 418 427 463 466} }
                "aura"          { set tl {198 353 355 199 200 383 356 357 382 470} }
                "avrg"          { set tl {23 30 31 45 46 74 84 103 112 408 478} }
                default {
                    if [string match alter* $word] {
                        set tl {1 67 68 79 86 87 163 164 165 166 167 168 195 217 228 229 236 336 338 415 416 443} 
                    } elseif [string match abut* $word] {
                        set tl {213 320 323 333 338 257 370 372 398 418 461 463}
                    } elseif [string match accel* $word] {
                        set tl {197 283 352 370 416 468 481}
                    } elseif [string match accu* $word] {
                        set tl {24 392 70 226 333 338 339 353 266 358 372 373 383 416 420 434 436 437 461 463 468 469 474 476 477 483 481 504}
                    } elseif [string match acoustic* $word] {
                        set tl {198 353 355 199 354 356 357 382}
                    } elseif [string match add* $word] {
                        set tl {70 391 226 313 322 323 324 257 271 272 275 276 284 373 383 95 408 461 474 475 500 504}
                    } elseif [string match alternat* $word] {
                        set tl {72 171 320 333 338 256 257 275 365 393 394 420 443 449 451}
                    } elseif [string match ambien* $word] {
                        set tl {198 353 355 199 199 200 383 354 356 357 358 359 382 434 504}
                    } elseif [string match anal* $word] {
                        set tl {202 204 366 369}
                    } elseif [string match antiph* $word] {
                        set tl {373 418 419}
                    } elseif [string match approx* $word] {
                        set tl {50 310 450}
                    } elseif [string match arpeg* $word] {
                        set tl {20 313 483}
                    } elseif [string match assess* $word] {
                        set tl {174 181 347 369 450}
                    } elseif [string match attack* $word] {
                        set tl {21 160 161 180 313 318 323 338 369 419 473 475}
                    } elseif [string match attenuat* $word] {
                        set tl {1 154 155 156 175 195 280 416 443 481}
                    } elseif [string match audit* $word] {
                        set tl {87 97}
                    } elseif [string match averag* $word] {
                        set tl {23 30 31 45 46 74 84 103 112 408 434 450 461 478 484 504}
                    } else {
                        return 0    ;#  No modification to existing progslist,on unrecognised word.
                    }
                }
            }
        }
        "b" {
            switch -- $word {
                "back"      { set tl {323 220} }
                "bakup"     -
                "backup"    { set tl {220} }
                "balance"   { set tl {98 311 195 362 416 443} }
                "bare"      { set tl {3 319 266 269 359 372 376 483} }
                "batch"     { set tl {335} }
                "bin"       -
                "binary"    { set tl {163 164 165 166 167 168 309 342 258 364 461} }
                "blemish"   { set tl {10 17 18 59 113 185 186 187 188 189 190 192 193 194 209 210 214 246 319 346 280 470 473} }
                "blow"      { set tl {7} }
                "bltr"      { set tl {22 23 30 31} }
                "body"      { set tl {198 353 355 199 200 383 382 475} }
                "bounce"    { set tl {481 373 418 420 469} }
                "brktoenv"  { set tl {67 68 79 86 87 163 164 165 166 167 168 217 228 229 236} }
                default {
                    if [string match backw* $word] {
                        set tl {109 149 201 323 352 119 377 433 94 416}
                    } elseif [string match band* $word] {
                        set tl {19 185 187 293 320 334 256 365 418 436 437 441 442 443 483}
                    } elseif [string match betwee* $word] {
                        set tl {22 40 58 172 337 310 333 338 286 393 394 420 424 461}
                    } elseif [string match bigg* $word] {
                        set tl {26 39 73 81 82 230 99 297 232 313 339 345 351 277 281 373 383 475 504}
                    } elseif [string match bilat* $word] {
                        set tl {380}
                    } elseif [string match blur* $word] {
                        set tl {23 30 31 32 201 318 352 353 355 358 119 377 433 93 94 395 415 416 421 431 434 449 458 459 462 463 468 469 470 471 472 473 477 478 480 482 499 504}
                    } elseif [string match boost* $word] {
                        set tl {1 175 195 373 383 475 484}
                    } elseif [string match brass* $word] {
                        set tl {199 200 383}
                    } elseif [string match bridg* $word] {
                        set tl {45 46 47 112 310 268 272 275 276 286 373 383 424 461}
                    } elseif [string match bundl* $word] {
                        set tl {218 256 257 416 420 442 461 468 469 478 482}
                    } else {
                        return 0
                    }
                }
            }
        }
        "c" {
            switch -- $word {
                "cdiff"         { set tl {234} }
                "ceiling"       { set tl {154 155 156} }
                "choice"        { set tl {48 64 263 66 68 73 151 204 215 216 240 333 338 336 402 443} }
                "choir"         { set tl {33 469 504} }
                "column"        { set tl {240 241 242 243 244 245 246 247 250} }
                default {
                    if [string match chang* $word] {
                        set tl {1 11 12 27 45 46 47 56 60 61 67 68 79 86 87 112 118 141 142 143 144 163 164 165 166 167 168 175 195 197 283 217 228 229 236 309 335 336 339 342 258 364 376 416 424 450 475 480 483 484}
                    } elseif [string match chan* $word] {
                        set tl {75 77 78 171 215 90 231 234 256 365 451}
                    } elseif [string match check* $word] {
                        set tl {181 381 376 422}
                    } elseif [string match chop* $word] {
                        set tl {216 307 318 319 320 332 343 267 279 365 370 372 376 393 394 402 415 416 436 437 455 456 468 469 473 476 477 478 482}
                    } elseif [string match choos* $word] {
                        set tl {48 64 263 66 68 73 151 204 215 216 240 332 333 338 336 266 402}
                    } elseif [string match chord* $word] {
                        set tl {13 14 15 16 124 125 126 127 128 129 130 131 132 133 134 135 136 137 188 189 190 191 348 313 97 483}
                    } elseif [string match chorus* $word] {
                        set tl {33 469}
                    } elseif [string match clarif* $word] {
                        set tl {3 4 360 361 185 186 187 319 346 443}
                    } elseif [string match clean* $word] {
                        set tl {2 3 4 360 361 59 185 186 187 216 319 341 346 269 280 359}
                    } elseif [string match clear* $word] {
                        set tl {75 77 78 104 171 212 215 231 234 239 251 310 319 269 280 359 376}
                    } elseif {[string match clic* $word] || [string match clik* $word]} {
                        set tl {330 341 346 376 473}
                    } elseif [string match clip* $word] {
                        set tl {174 294 341 346 376 415 416 473 476 477 499}
                    } elseif [string match clunk* $word] {
                        set tl {185 186 187 346}
                    } elseif [string match combin* $word] {
                        set tl {45 46 60 61 69 304 70 391 71 72 73 74 75 112 117 171 172 256 337 226 183 379 308 313 322 323 328 333 338 344 257 268 272 275 276 286 373 383 95 408 418 420 422 424 434 437 443 451 461 480 500}
                    } elseif [string match compar* $word] {
                        set tl {233 234 381 422}
                    } elseif [string match concentrat* $word] {
                        set tl {26 27 314 352 266 284 358 370 372 376 421 432 434 468 482 483}
                    } elseif [string match contour* $word] {
                        set tl {2 25 51 62 63 65 264 66 74 79 80 102 114 1002 195 315 153 174 175 303 314 320 323 338 339 343 270 271 272 285 369 92 404 405 406 407 408 409 410 411 412 413 414 416 419 428 429 435 443 455 456 459 471 472 475 482 483 484 391 500}
                    } elseif [string match contract* $word] {
                        set tl {8 9 1003 105 106 115 145 177 199 352 370 372 376 416 432 468 483 481}
                    } elseif [string match conver* $word] {
                        set tl {67 68 79 86 87 163 164 165 166 167 168 202 203 204 217 228 229 236 309 310 335 336 342 258 364 404 405 406 407 450}
                    } elseif [string match convol* $word] {
                        set tl {322 391}
                    } elseif [string match copi* $word] {
                        set tl {214 249 323 469 474}
                    } elseif [string match copy* $word] {
                        set tl {214 249 323 436 437 469 474}
                    } elseif [string match corrugat* $word] {
                        set tl {154 155 156 318 320 338 343 259 376 393 415 421 436 437 462 469 470 471 472 473 476 477}
                    } elseif [string match creat* $word] {
                        set tl {41 62 63 69 304 183 379 308 74 150 172 337 173 256 237 238 239 403 242 247 293 309 314 320 328 330 335 336 343 266 402 408 427 435 436 437 441 442 459 466 467 470 471 472 476 479}
                    } elseif [string match cresc* $word] {
                        set tl {1 159 195 338 404 405 406 407 409 410 411 412 413 414 478}
                    } elseif [string match cross* $word] {
                        if [string match crossfad* $word] {
                            set tl {98 311 169 170 404 405 406 407 409 410 411 412 420 443 461}
                        } else {
                            set tl {75 169 317 98 311 170 201 322 272 275 276 286 408 409 410 411 412 413 414 461 391 500}
                        }
                    } elseif [string match cumul* $word] {
                        set tl {193 323 284 358 372 373 383 421 434 435 459 461 463 469 477 504}
                    } elseif [string match curtail* $word] {
                        set tl {158 371 376 416 468}
                    } elseif [string match cut* $word] {
                        set tl {5 10 58 48 64 263 66 68 113 151 158 371 185 186 187 204 206 397 312 393 207 208 96 209 210 211 325 212 214 215 216 307 240 246 251 252 253 319 320 332 261 266 267 280 365 370 376 402 415 416 455 456 462 473 477 478}
                    } else {
                        return 0
                    }
                }
            }
        }
        "d" {
            switch -- $word {
                "data"          { set tl {216 240 241 242 243 244 245 246 247 250 309 354 369 376} }
                "db"            { set tl {166 167 168 236} }
                "dc"            -
                "d.c."          { set tl {216} }
                "dbtoenv"       { set tl {166} }
                "dbtogain"      { set tl {167} }
                "dip"           { set tl {232 443} }
                "dist"          -
                "distrt"        -
                "distort"       { set tl {100 101 102 103 104 105 106 107 108 109 110 \
                                                111 349 340 112 113 114 115 116 117 118 294 314 318 376 415 416 421 449 452 453 455 458 462 470 471 472 473 474 475 476 477 478 480 482 483 391 499} }
                "dummy"         { set tl {183 379 308 328} }
                "duration"      { set tl {224 225 226 227 339 277 281 416} }
                default {
                    if [string match db* $word] {
                        set tl {a64 166 167 168 236 269}
                    } elseif [string match deemphasiz* $word] {
                        set tl {23 30 31 32 346 280 416 420 443 484 481}
                    } elseif [string match deccel* $word] {
                        set tl {197 283 352 372}
                    } elseif [string match decor* $word] {
                        set tl {22 23 20 126 127 128 313 314 320 323 338 343 270 271 404 405 406 407 409 410 411 412 416 421 460 461 469 470 471 472 473 474 475 500}
                    } elseif [string match decreas* $word] {
                        set tl {1 195 370 416 432}
                    } elseif [string match decresc* $word] {
                        set tl {1 159 195 478 481}
                    } elseif [string match defocus* $word] {
                        set tl {23 30 31 32 353 355 280 373 383 416 420 421 434 449 458 462 470 471 472 474 477 478 480 482 481}
                    } elseif [string match degrad* $word] {
                        set tl {23 30 31 32 201 318 376 93 415 416 421 432 449 458 462 468 469 470 471 472 473 474 477 478 480 482 481 499}
                    } elseif [string match delay* $word] {
                        set tl {120 122 198 353 291 292 354 376 287 401 420 426 469 474 481}
                    } elseif [string match delet* $word] {
                        set tl {10 113 116 209 210 214 246 249 310 319 346 352 261 370}
                    } elseif [string match dens* $word] {
                        set tl {124 125 126 127 128 129 130 131 132 133 134 135 136 137 374 417 169 317 170 171 173 174 175 176 177 178 179 180 181 182 183 379 370 372 416}
                    } elseif [string match diff* $word] {
                        if [string match differen* $word] {
                            set tl {218 219 246 336 418 422}
                        } else {
                            set tl {71 218 219 227 233 234 246}
                        }
                    } elseif [string match dim* $word] {
                        set tl {1 159 195 416}
                    } elseif [string match disk* $word] {
                        set tl {222}
                    } elseif [string match display* $word] {
                        set tl {67 68 77 78 79 83 86 88 189 223 224 225 }
                    } elseif [string match distort* $word] {
                        set tl {100 101 102 103 104 105 106 107 108 109 110 111 349 340 112 113 114 115 116 117 118 318 346 415 416 421 449 452 453 455 458 462 470 471 472 473 474 475 477 478 480 482 483 499}
                    } elseif [string match divid* $word] {
                        set tl {105 106 320 267 365 420 478 482}
                    } elseif [string match dovetail* $word] {
                        set tl {157 170 323 268 370 376 416 443 461}
                    } elseif [string match drunk* $word] {
                        set tl {34 123 377 433 417 431 459 462 469 470 471 472 474 477}
                    } elseif [string match duck* $word] {
                        set tl {154 155 156}
                    } elseif [string match dupl* $word] {
                        set tl {111 349 340 120 122 140 176 214 249 313 323 331 333 338 336 352 260 266 287 416 418 419 421 434 436 437 463 469 473 474 476 481}
                    } elseif [string match dur* $word] {
                        set tl {224 225 226 227 339 277 281 376}
                    } else {
                        return 0
                    }
                }
            }
        }
        "e" {
            switch -- $word {
                "enlarge"       { set tl {177 339 266 362 399 428 429 461 463 469 470 474 475 476 477 483} }
                "envtobrk"      { set tl {163} }
                "envtodb"       { set tl {164} }
                "eq"            { set tl {18} }
                default {
                    if [string match echo* $word] {
                        set tl {111 349 340 120 122 140 193 198 401 353 355 199 323 331 333 338 352 354 256 260 382 287 416 418 419 421 426 436 437 463 469 473 474 481}
                    } elseif [string match edg* $word] {
                        set tl {21 160 161 180 376 475}
                    } elseif [string match edit* $word] {
                        set tl {10 48 58 64 263 66 68 113 151 157 158 371 204 206 397 312 393 207 208 96 209 211 325 212 375 213 215 216 307 240 210 214 246 251 252 253 295 296 310 319 320 332 333 338 335 341 346 257 261 266 267 279 280 282 365 370 372 376 402 416}
                    } elseif [string match element* $word] {
                        set tl {100 101 102 103 104 105 106 107 108 109 110 111 349 340 112 113 114 115 116 117 118 138 347 139 140 141 142 143 144 145 146 147 148 149 352 368 260 266 280 365 376 393 394 402 421 436 437 455 456 467 473 476 478 482 484}
                    } elseif [string match elongat* $word] {
                        set tl {7 9 1003 119 377 433 120 121 122 123 145 177 199 323 339 344 345 351 352 368 259 262 266 277 281 376 373 383 287 399 417 428 429 436 437 473 474 476 481 504}
                    } elseif [string match emphasiz* $word] {
                        set tl {20 21 22 23 24 392 25 51 160 313 314 338 339 343 284 372 419 421 434 443 475}
                    } elseif [string match energy* $word] {
                        set tl {2 79 80 81 174 175 356 357 369 404 405 406 407 409 410 411 412 419 421 470}
                    } elseif [string match enhanc* $word] {
                        set tl {362 373 383 421 460 461 469 471 472 475 483 484}
                    } elseif [string match enlarg* $word] {
                        set tl {7 119 377 433 120 121 122 123 313 339 345 351 352 368 353 355 259 260 262 266 277 281 373 383 94 287 399 417 421 428 429 461 469 470 473 474 476 483 484 481 504}
                    } elseif [string match envel* $word] {
                        set tl {2 16 25 41 51 62 63 64 263 65 264 66 67 68 74 79 80 102 114 152 315 153 174 175 303 314 327 343 272 372 92 408 415 443 455 456 475 476 484 481}
                    } elseif [string match equalis* $word] {
                        set tl {18 195 376 484}
                    } elseif [string match event* $word] {
                        set tl {216 402}
                    } elseif [string match exag* $word] {
                        set tl {25 26 51 154 155 156 313 314 338 339 343 266 284 358 362 372 376 416 421 453 470 473 475 483}
                    } elseif [string match examin* $word] {
                        set tl {67 68 79 86 342 258 347 285 369 377 433 92}
                    } elseif [string match exchang* $word] {
                        set tl {101 104 114 336 443 480}
                    } elseif [string match excis* $word] {
                        set tl {10 113 209 210 214 246 310 319 320 346 261 269 280 370 415 416 419 422}
                    } elseif [string match expan* $word] {
                        set tl {154 155 156 313 323 339 345 351 352 368 353 355 259 260 262 266 277 281 373 383 399 421 428 429 459 461 466 469 470 473 474 475 476 483 484 481 504}
                    } elseif [string match extend* $word] {
                        set tl {7 8 9 1003 105 106 119 377 433 120 121 122 123 145 177 199 318 323 324 335 339 344 345 351 352 368 257 266 277 281 373 383 94 287 399 404 405 406 407 409 410 411 412 417 421 428 429 435 436 437 459 461 473 474 476 478 483 481 504}
                    } elseif [string match extract* $word] {
                        set tl {6 48 92 64 263 66 68 151 185 187 204 215 216 307 237 240 320 332 266 267 285 365 366 372 394 402 416 425 450 467 473 483}
                    } else {
                        return 0
                    }
                }
            }
        }
        "f" {
            switch -- $word {
                "forth"         { set tl {119 377 433 94} }
                "frq"           { set tl {30 77 78 82 105 106 116 236 309 191 348} }
                "frz"           { set tl {28 29 177 248 339 345 351 504} }
                "fugu"          { set tl {323} }
                default {
                    if [string match fad* $word] {
                        set tl {158 371 404 405 406 407 409 410 411 412 416}
                    } elseif [string match fall* $word] {
                        set tl {192}
                    } elseif [string match field* $word] {
                        set tl {13 14 15 16 124 125 126 127 128 129 130 131 132 133 134 135 136 137 374 417 188 189 190 191 348 289 290 333 338 399 418 421 463 469 470 476 477 478 483}
                    } elseif [string match figur* $word] {
                        set tl {20 22 23 333 338 428 429 435 436 437 471 472 476}
                    } elseif [string match filt* $word] {
                        set tl {17 18 19 116 185 186 187 188 189 190 191 348 192 193 194 310 314 319 334 10 113 209 210 246 346 269 280 427 483}
                    } elseif [string match find* $word] {
                        set tl {48 92 64 263 66 68 73 74 146 151 174 182 204 215 216 307 232 240 138 347 352 354 278 369 381 376 402 450}
                    } elseif [string match finish* $word] {
                        set tl {157 158 371}
                    } elseif [string match fix* $word] {
                        set tl {59 178 310 339 346}
                    } elseif [string match flang* $word] {
                        set tl {194 465}
                    } elseif [string match flat* $word] {
                        set tl {154 155 156 483}
                    } elseif [string match float* $word] {
                        set tl {217}
                    } elseif [string match flip* $word] {
                        set tl {295 296 380 460 461 483}
                    } elseif [string match flutt* $word] {
                        set tl {42 57 162 400 197 283 318 343 270 377 433 91 415 421 462 470 471 472 473 476}
                    } elseif [string match fmnt* $word] {
                        set tl {16 41 63 64 263 65 264 66 67 68 69 304 314 408 483 391 500}
                    } elseif [string match focus* $word] {
                        set tl {25 26 51 185 187 310 313 334 338 339 266 358 372 376 396 416 432 434 443 450 467 475 483 504}
                    } elseif [string match fof* $word] {
                        set tl {260 261 262 263 264 265 266 267 268 270 271 272 273 274 275 276 277 278 279 281 284 366 367 449 480}
                    } elseif [string match fold* $word] {
                        set tl {11 27 432 434 442 458 460 461 466 476 477 478 482}
                    } elseif [string match formant* $word] {
                        set tl {16 41 63 64 263 65 264 66 67 68 69 304 305 314 408 483 391 500}
                    } elseif [string match frac* $word] {
                        set tl {108 415 421 434 459 470 471 472 476 478 482}
                    } elseif [string match frame $word] {
                        set tl {380 466 467}
                    } elseif [string match freez* $word] {
                        set tl {28 29 177 248 323 339 345 351 266 277 281 377 433 416 428 429 436 437 473 474 476 504}
                    } elseif [string match freq* $word] {
                        set tl {22 40 30 77 78 82 105 106 116 236 309 318 334 347 191 348 432 479}
                    } elseif [string match frq* $word] {
                        set tl {22 40 30 77 78 82 105 106 116 236 309 334 347 432 479}
                    } else {
                        return 0
                    }
                }
            }
        }
        "g" {
            switch -- $word {
                "gain"          { set tl {1 159 195 236 338 484} }
                "gaintodb"      { set tl {67 68 79 163 164 165 166 167 168 217 228 229 236 381} }
                "gap"           { set tl {177 232 308 310 328 379 267 370 376 393 415 416} }
                "gate"          { set tl {269 2 154 155 156 216 307 319 320 332 346 376 397 400 416} }
                "greq"          { set tl {18 314} }
                "grn"           { set tl {138 347 139 140 141 142 143 144 145 146 147 148 149 199 200 383 352 368} }
                default {
                    if [string match gap* $word] {
                        set tl {177 232 308 328 379 343 267 370 381 376 393 415 416}
                    } elseif [string match gath* $word] {
                        set tl {218 219 246 333 338 416 432 461 482}
                    } elseif [string match gati* $word] {
                        set tl {269 2 154 155 156 319 320 346 376 397 400 415 416 419 476}
                    } elseif [string match generat* $word] {
                        set tl {41 67 68 69 304 74 79 86 87 150 163 164 165 166 167 168 173 256 172 337 183 379 308 328 217 228 229 236 237 238 239 403 242 247 293 309 314 330 335 336 343 97 354 266 271 402 408 428 429 435 436 437 441 442 459 461 463 466 467 469 470 471 472 473 476 477 479 483}
                    } elseif [string match get* $word] {
                        set tl {10 48 92 64 263 66 68 73 74 113 116 146 151 173 182 204 209 210 214 215 216 307 240 242 247 246 334 347 352 266 267 278 369 402 425 450 467}
                    } elseif [string match glid* $word] {
                        set tl {45 46 47 112 192 191 348 268 286 396 424 428 429 435 473 478}
                    } elseif [string match glist* $word] {
                        set tl {395 403 421 470}
                    } elseif [string match gliss* $word] {
                        set tl {478 479 480}
                    } elseif [string match glitch* $word] {
                        set tl {59 310 319 346 280}
                    } elseif [string match grab* $word] {
                        set tl {6 332 266 267 277 281 402 467 473 483}
                    } elseif [string match grain* $word] {
                        set tl {138 347 139 140 141 142 143 144 145 146 147 148 149 199 200 383 318 320 343 345 352 368 259 260 261 266 267 268 270 271 272 277 281 278 279 369 376 393 415 416 417 473 476 478}
                    } elseif [string match gran* $word] {
                        set tl {138 347 139 140 141 142 143 144 145 146 147 148 149 199 200 383 343 352 368 259 260 261 266 270 277 281 278 279 376 415 416 417 421 462 473 476 477 478 482}
                    } elseif [string match graph* $word] {
                        set tl {18}
                    } elseif [string match grat* $word] {
                        set tl {365 393 394 415 421 470 473 476 499}
                    } elseif [string match greate* $word] {
                        set tl {26 39 73 81 82 230 99 297 475}
                    } elseif [string match grit* $word] {
                        set tl {138 347 139 140 141 142 143 144 145 146 147 148 149 199 200 383 318 346 259 376 415 416 417 421 470 473 476 478 499}
                    } elseif [string match grid* $word] {
                        set tl {320 393 394 415 418 419 420 466 476}
                    } elseif [string match group* $word] {
                        set tl {125 135 218 219 246 308 320 321 328 379 333 338 344 256 365 394 399 432 442 461 463 466 481}
                    } elseif [string match grp* $word] {
                        set tl {125 135 218 219 246}
                    } else {
                        return 0
                    }
                }
            }
        }
        "h" {
            switch -- $word {
                "harmonies"     { set tl {13 396 14 15 16 124 125 126 127 128 129 130 131 132 133 134 135 136 137 188 189 190 191 348 97 92 483} }
                "harmony"       { set tl {13 396 14 15 16 124 125 126 127 128 129 130 131 132 133 134 135 136 137 188 189 190 191 348 255 313 97 92 483} }
                "hear"          { set tl {87 97 381} }
                "hi"            { set tl {185 186 187} }
                "high"          { set tl {185 186 187} }
                "hilo"          { set tl {185 186 187} }
                "hole"          { set tl {232 310 347 269 370 381 376 415 416} }
                default {
                    if [string match handwind* $word] {
                        set tl {201 468}
                    } elseif [string match harmon* $word] {
                        set tl {3 10 13 396 14 15 16 22 24 392 27 32 42 107 124 125 126 127 128 129 130 131 132 133 134 135 136 137 188 189 190 191 348 255 313 97 284 285 286 365 92 483}
                    } elseif [string match heighten* $word] {
                        set tl {25 26 51 313 314 323 339 266 270 284 358 362 372 376 373 383 399 416 419 421 443 461 470 471 472 473 475}
                    } elseif [string match hip* $word] {
                        { set tl {185 186 187} }
                    } elseif [string match hold* $word] {
                        set tl {28 29 248 339 345 351 266 277 281 377 433 467 469 474 476 483 504}
                    } elseif [string match hover* $word] {
                        set tl {378 433 459}
                    } else {
                        return 0
                    }
                }
            }
        }
        "i" {
            switch -- $word {
                "insil"         { set tl {212 375 251 282 448} }
                "int"           { set tl {217} }
                default {
                    if [string match improv* $word] {
                        set tl {4 360 361 59 185 186 187 310 313 319 346 269 450 484}
                    } elseif [string match impulse* $word] {
                        set tl {479 480}
                    } elseif [string match inbetwee* $word] {
                        set tl {172 337 310 320 333 267 272 275 276 286 365 370 393 394 404 405 406 407 409 410 411 412 415 416 418 420 424 432 461 391 500}
                    } elseif [string match increas* $word] {
                        set tl {1 8 9 1003 105 106 145 177 195 199 313 345 351 399 421 475 484 504}
                    } elseif [string match info* $word] {
                        set tl {76 77 78 79 80 81 82 83 84 85 86 87 88 223 224 225 226 227 228 229 230 99 231 232 233 234 235 297 354 483}
                    } elseif [string match insert* $word] {
                        set tl {211 325 212 375 282 251 299 300 301 302 308 310 333 338 336 257 95 415 448 461 474 475 480}
                    } elseif [string match instabil* $word] {
                        set tl {42 57 162 400 197 283 91 421 459 462 470 471 472 473 474 477}
                    } elseif [string match integ* $word] {
                        set tl {217}
                    } elseif [string match interact* $word] {
                        set tl {72 117 171 201 322 408 420 461 391}
                    } elseif [string match interlea* $word] {
                        set tl {72 171 308 320 333 338 256 257 272 275 365 95 393 394 415 416 418 419 420 442 443 449 451 461 463 466 476 478 482}
                    } elseif [string match interp* $word] {
                        set tl {45 46 47 112 172 337 310 323 268 286 424 461 484}
                    } elseif [string match interval* $word] {
                        set tl {188 189 236 308 309 313 328 379 191 348 376 416 435 483}
                    } elseif [string match intvl* $word] {
                        set tl {188 189 236}
                    } elseif [string match introdu* $word] {
                        set tl {211 325 212 375 282 251 310 314 336 270 415 448 475 480}
                    } elseif [string match invent* $word] {
                        set tl {41 69 304 150 172 337 239 309 408 427 435 436 437 466 470 473}
                    } elseif [string match invert* $word] {
                        set tl {44 52 154 155 156 323 362 447 449 483}
                    } elseif [string match iter* $word] {
                        set tl {120 122 339 193 323 331 333 338 345 352 368 198 401 353 266 382 287 416 418 419 426 435 436 437 459 463 466 469 473 474 476 477 479 481}
                    } else {
                        return 0
                    }
                }
            }
        }
        "k" {
            switch -- $word {
                "kill"          { set tl {104 139 346} }
                default {
                    if [string match keep* $word] {
                        set tl {6 310 267 402 467}
                    } else {
                        return 0
                    }
                }
            }
        }
        "l" {
            switch -- $word {
                "level"         { set tl {1 2 73 79 80 84 159 174 175 195 230 99 297} }
                "lin"           -
                "linear"        { set tl {40 428 429 435}}
                "list"          { set tl {225 240 241 242 243 244 245 246 247 250 183 379 308 309 321 328 333 338 334 335 336 342 258 344 364 416 483} }
                "lo"            { set tl {185 186 187} }
                "lohi"          { set tl {185 186 187} }
                "loudchan"      { set tl {22 231 92 443} }
                "loudness"      { set tl {2 79 80 1002 174 175 303 338 381 419 443 475 483} }
                "low"           { set tl {185 186 187 269} }
                default {
                    if [string match large* $word] {
                        set tl {232 313 399 421}
                    } elseif [string match layer* $word] {
                        set tl {124 125 126 127 128 129 130 131 132 133 134 135 136 137 374 417 169 317 98 311 170 171 173 256 174 175 176 177 178 179 180 181 182 183 379 313 320 284 365 393 394 418 419 420 421 442 443 451 461 463 469 471 472 482}
                    } elseif [string match len* $word] {
                        if [string match lengthen* $word] {
                            set tl {7 8 9 1003 105 106 119 377 433 120 121 122 123 145 177 199 323 339 345 351 352 368 266 277 281 94 287 417 428 429 459 473 474 476 504}
                        } else {
                            set tl {7 8 9 1003 105 106 119 377 433 120 121 122 339 123 145 177 199 224 225 226 227 354 277 281 94 287 417}
                        }
                    } elseif [string match lift* $word] {
                        set tl {154 155 156 484}
                    } elseif [string match limit* $word] {
                        set tl {2 154 155 156 416}
                    } elseif [string match line* $word] {
                        set tl {176 178 308 309 321 399 428 429 435 436 437}
                    } elseif [string match link* $word] {
                        set tl {213 308 310 328 379 333 338 344 257 267 268 398 416 461}
                    } elseif [string match listen* $word] {
                        set tl {87 97}
                    } elseif [string match locat* $word] {
                        set tl {48 92 64 263 66 68 146 151 196 316 204 215 216 307 240 254 308 329 352 256 278 369 373 383 381 376 399 404 405 406 407 409 410 411 412 413 414 416 419 459}
                    } elseif [string match longe* $word] {
                        set tl {232 345 351 352 368 277 281 476 481 504}
                    } elseif [string match look* $word] {
                        set tl {67 68 79 86 342 258 483}
                    } elseif [string match loop* $word] {
                        set tl {111 349 340 120 122 339 140 193 318 323 331 333 338 345 351 260 266 277 281 287 416 418 419 420 436 437 463 469 471 472 473 474 476 481}
                    } elseif [string match lop* $word] {
                        set tl {185 186 187 416}
                    } elseif [string match loude* $word] {
                        set tl {22 26 39 73 81 82 230 99 297 231 338 475 484}
                    } elseif [string match loudn* $word] {
                        set tl {1 2 79 80 159 174 175 195 303 338 419 443 475 483 484}
                    } elseif [string match lower* $word] {
                        set tl {1 8 9 1003 105 106 145 154 155 156 177 195 199}
                    } else {
                        return 0
                    }
                }
            }
        }
        "m" {
            switch -- $word {
                "mean"          { set tl {74 84 103} }
                "median"        { set tl {74 84 103 450} }
                "memory"        { set tl {222} }
                "midi"          { set tl {236 309 334} }
                "mike"          { set tl {185 186 187} }
                "mono"          { set tl {75 77 78 171 215 90 231 234 451} }
                "mtf"           -
                "mtfs"          -
                "motif"         -
                "motifs"        { set tl {132 133 136 137 308 309 314 321 333 338 344 396 469 471 472} }
                "motion"        { set tl {196 316 254 373 380 383 94 396 404 405 406 407 409 410 411 412 413 414 419 421 442 459 460 461 466 470 481} }
                "multiple"      { set tl {214 313 323 333 338 335 345 352 256 365 373 383 393 394 420 436 437 463 466 469 476 479 481} }
                default {
                    if [string match magnif* $word] {
                        set tl {7 119 377 433 120 121 122 339 123 313 323 345 351 259 260 262 266 284 358 362 372 373 383 94 287 399 417 419 421 428 429 434 443 461 467 469 473 474 475 476 483 484 481 504}
                    } elseif [string match mak* $word] {
                        set tl {41 69 304 74 150 172 337 173 256 237 238 239 403 242 247 293 183 379 308 309 318 328 330 334 336 343 344 97 402 408 427 435 436 437 441 442 467 470 476 479 483}
                    } elseif [string match manufactur* $word] {
                        set tl {41 69 304 150 172 337 239 183 379 308 309 314 318 321 328 334 335 336 343 344 271 402 408 427 428 429 435 436 437 441 442 466 467 470 471 472 476 479 483}
                    } elseif [string match marry* $word] {
                        set tl {60 61 69 304 70 391 71 72 73 74 75 117 201 183 379 308 322 323 328 333 338 336 257 268 272 275 276 286 408 418 461 480}
                    } elseif [string match mass* $word] {
                        set tl {124 125 126 127 128 129 130 131 132 133 134 135 136 137 374 417 183 379 313 469 476}
                    } elseif [string match max* $word] {
                        set tl {22 26 39 73 81 82 84 230 99 297 231}
                    } elseif [string match melod* $word] {
                        set tl {321 344 396 428 429 435 436 437 471 472 483}
                    } elseif [string match merg* $word] {
                        set tl {169 317 98 311 170 171 172 337 173 256 174 175 176 177 178 179 180 181 182 183 379 295 296 333 338 336 257 268 272 275 276 286 95 424 451 461 391}
                    } elseif [string match min* $word] {
                        set tl {84}
                    } elseif [string match mirror* $word] {
                        set tl {196 380 466 483}
                    } elseif [string match mix* $word] {
                        set tl {60 61 69 304 70 391 71 72 73 74 75 117 169 317 98 311 170 171 172 337 173 256 174 175 176 177 178 326 179 180 181 182 183 379 308 328 201 295 296 313 324 336 344 272 275 276 95 408 420 424 451 461}
                    } elseif [string match modulat* $word] {
                        set tl {201 322 270 272 419 421 480}
                    } elseif [string match model* $word] {
                        set tl {335 336 354 467 483}
                    } elseif [string match motiv* $word] {
                        set tl {132 133 136 137 308 309 321 333 338 344 436 437 481}
                    } elseif [string match mov* $word] {
                        set tl {12 27 40 178 326 192 196 316 254 352 373 383 380 376 94 404 405 406 407 409 410 411 412 413 414 459 460 461 483}
                    } elseif [string match multichan* $word] {
                        set tl {75 77 78 171 215 90 231 234 256 373 383 95 91 93 399 418 419 420 421 451 459 461 466 469}
                    } elseif [string match multiplic* $word] {
                        set tl {105 106 345 418 420 421 461 463 466 469 471 472 473 474 476 477 481}
                    } elseif [string match multiply* $word] {
                        set tl {105 106 322 345 352 368 421 391 436 437 473 474 476 477 481 504}
                    } else {
                        return 0
                    }
                }
            }
        }
        "n" {
            switch -- $word {
                "neutral"       { set tl {124} }
                "notch"         { set tl {187 346 280 376 475} }
                default {
                    if [string match nois* $word] {
                        set tl {4 360 361 39 185 186 187 238 299 301 310 319 346 269 271 462 470 476 480 499}
                    } elseif [string match nonpitch* $word] {
                        set tl {85 299 301 310 319}
                    } elseif [string match normalis* $word] {
                        set tl {154 155 156 195 484}
                    } elseif [string match note* $word] {
                        set tl {236 309 321 334 344 436 437 479}
                    } elseif [string match number* $word] {
                        set tl {188 189 240 241 242 243 244 245 246 247 250 308 347 278 418}
                    } else {
                        return 0
                    }
                }
            }
        }
        "o" {
            switch -- $word {
                "ornate"        { set tl {20 22 23 126 127 128 129 130 131 321 333 338 270 271 435 460 461 469 470 471 472 473 474} }
                "offset"        { set tl {188 189 308 328 379 381 376 404 405 406 407 409 410 411 412 443} }
                default {
                    if [string match oct* $word] {
                        set tl {11 12 27 48 56 60 61 62 63 142 144 197 283 236 313 284 450 483}
                    } elseif [string match odd* $word] {
                        set tl {10 14 176 188 189 348}
                    } elseif [string match omit* $word] {
                        set tl {101 104 114 139 176 310 319 267 269 280 370 415 416 419 422 468}
                    } elseif [string match onset* $word] {
                        set tl {216 323 341 381 376 475}
                    } elseif [string match orient* $word] {
                        set tl {380 404 405 406 407 466}
                    } elseif [string match ornament* $word] {
                        set tl {20 22 23 126 127 128 129 130 131 314 321 323 338 270 271 396 415 421 469 470 471 472 473 474 475 481}
                    } elseif [string match overload* $word] {
                        set tl {294 346 499}
                    } elseif [string match overwr* $word] {
                        set tl {211 325 212 335 336}
                    } else {
                        return 0
                    }
                }
            }
        }
        "p" {
            switch -- $word {
                "packet"        { set tl {402 435 436 437 473 476 479 480} }
                "pops"          { set tl {185 186 187} }
                "post"          { set tl {128 131}}
                "power"         { set tl {2 79 80 174 175 453} }
                "pre"           { set tl {127 130} }
                "presence"      { set tl {185 186 187} }
                "prntsnd"       { set tl {235} }
                "put"           { set tl {211 325 212 375 282 251 308 448} }
                "perm"          { set tl {289 290 291 292 333 338 380 418 419 420 466 476 504} }
                default {
                    if [string match pad* $word] {
                        set tl {448}
                    } elseif [string match pan* $word] {
                        set tl {178 326 196 316 254 329 256 373 380 383 94 399 404 405 406 407 409 410 411 412 413 414 419 421 459 460 461 469}
                    } elseif [string match parallel* $word] {
                        set tl {148 365 404 405 406 407 418 419 420 442 443 461}
                    } elseif [string match partial* $word] {
                        set tl {3 10 13 14 22 24 392 27 32 42 107 348 285 286 92 470 483}
                    } elseif [string match peak* $word] {
                        set tl {26 39 81 82 314 369 372 376 92 416 425 475 483}
                    } elseif [string match perm* $word] {
                        set tl {289 290 291 292 308 333 338 418 419 420 443 449 458 466 476 478 504}
                    } elseif [string match phas* $word] {
                        set tl {194 202 204 362 418 443 447 465}
                    } elseif [string match pick* $word] {
                        set tl {13 14 15 16 21 160 161 308 332 336 266 420 467}
                    } elseif [string match pinpoint* $word] {
                        set tl {185 187 313 377 433 376 92 416 475}
                    } elseif [string match pizz* $word] {
                        set tl {161 476}
                    } elseif [string match pitch* $word] {
                        set tl {426 428 429 450 479 483}
                    } elseif [string match pluck* $word] {
                        set tl {21 160 161 313 416 436 437 476}
                    } elseif [string match portamento* $word] {
                        set tl {41 192 197 283 191 348 396 478 479}
                    } elseif [string match postdec* $word] {
                        set tl {128 469}
                    } elseif [string match postorn* $word] {
                        set tl {131}
                    } elseif [string match predec* $word] {
                        set tl {127 323}
                    } elseif [string match preorn* $word] {
                        set tl {130 323}
                    } elseif [string match print* $word] {
                        set tl {77 78 83 88 189 223 224 225 235 342 258}
                    } elseif [string match produc* $word] {
                        set tl {41 69 304 74 150 172 337 173 256 237 238 239 403 242 247 293 183 379 308 309 314 328 330 334 335 336 402 408 427 435 436 437 466 467 470 471 472 479 483}
                    } elseif [string match propor* $word] {
                        set tl {315}
                    } elseif [string match prop* $word] {
                        set tl {217 218 219 223}
                    } elseif [string match pvoc* $word] {
                        set tl {202 203 204}
                    } else {
                        return 0
                    }
                }
            }
        }
        "q" {
            switch -- $word {
                default {
                    if [string match quantis* $word] {
                        set tl {53 308 320 328 379 343 376 393 394 416 420 450 483}
                    } else {
                        return 0
                    }
                }
            }
        }
        "r" {
            switch -- $word {
                "ramp"          { set tl {237} }
                "range"         { set tl {27 84 116 373 383 399 404 405 406 407 409 410 411 412 413 414 459} }
                "ratio"         { set tl {236 418} }
                "ratios"        { set tl {172 418 420 424} }
                "respec"        { set tl {217 219 223 335 336} }
                "revecho"       { set tl {198 401 353 355 199 322 354 256 356 357 358 359 382 404 405 406 407 409 410 411 412 418 426 469 476 481} }
                "room"          { set tl {354 355 356 357 358 359} }
                "ring"          { set tl {201 380 470 473} }
                "rrr"           -
                "rolled"        { set tl {345 476} }
                default {
                    if [string match radical*   $word] {
                        set tl {201 313 314 318 322 271 93 415 416 421 431 434 449 458 460 461 462 468 469 470 471 472 473 474 475 476 477 480 482 483 499}
                    } elseif [string match rais* $word] {
                        set tl {8 9 1003 105 106 145 177 199 483 484}
                    } elseif [string match random* $word] {
                        set tl {34 35 36 38 54 110 121 123 176 199 200 383 245 252 253 333 338 373 417 419 421 427 431 459 462 470 477 478 483}
                    } elseif [string match reconst* $word] {
                        set tl {203 308 309 310 335 336 339 345 352 368 259 262 271 272 277 281 284 366 367 370 372 376 377 433 393 394 416 421 431 434 449 450 458 462 471 472 473 474 476 478 480 482 483 484}
                    } elseif [string match recov* $word] {
                        set tl {310 332 342 258 364}
                    } elseif [string match reduc* $word] {
                        set tl {1 8 9 1003 105 106 145 154 155 156 175 177 195 199 319 269 376 416 422 432 468 483}
                    } elseif [string match reflect* $word] {
                        set tl {354 355 256 460 461 466 483}
                    } elseif [string match reform* $word] {
                        set tl {101 104 114 309 310 313 314 335 336 339 345 351 352 368 276 277 281 372 376 416 421 431 432 434 449 450 452 453 458 461 466 468 478 480 482 483 484 391}
                    } elseif [string match remov* $word] {
                        set tl {2 4 360 361 10 58 101 104 113 114 116 139 185 186 187 206 397 207 209 210 214 246 249 310 319 346 352 261 269 279 280 370 422}
                    } elseif [string match renum* $word] {
                        set tl {380}
                    } elseif [string match reorient* $word] {
                        set tl {380 460 461 466 483}
                    } elseif [string match repeat* $word] {
                        set tl {111 349 340 120 122 339 140 193 255 318 321 331 333 338 335 343 344 345 352 368 260 266 376 287 401 404 405 406 407 409 410 411 412 416 418 419 420 436 437 463 469 473 474 476 477 479 481}
                    } elseif [string match repet* $word] {
                        set tl {111 349 340 120 122 339 140 193 255 321 331 333 338 335 343 344 345 352 368 260 287 401 404 405 406 407 409 410 411 412 416 418 419 420 434 463 469 473 474 476 477 479 481}
                    } elseif [string match replac* $word] {
                        set tl {10 75 101 104 113 114 209 210 214 246 310 325 336 261 271 276 286 408 415 450 480}
                    } elseif [string match replot* $word] {
                        set tl {154 155 156 435}
                    } elseif [string match reposit* $word] {
                        set tl {147 308352 256 370 372 376 380 399 404 405 406 407 409 410 411 412 416 419 460 461 466 478 482 483}
                    } elseif [string match reshape* $word] {
                        set tl {154 155 156 314 323 339 343 345 351 352 259 260 261 262 270 277 281 286 370 376 373 383 416 421 432 435 449 458 460 461 462 466 468 471 472 473 475 478 480 482 483 484 391 500}
                    } elseif [string match resolut* $word] {
                        set tl {201 217}
                    } elseif [string match reson* $word] {
                        set tl {24 392 198 353 355 199 200 383 313 314 322 334 191 348 354 256 356 357 358 359 382 421 426 473 504}
                    } elseif [string match restor* $word] {
                        set tl {214 310 346}
                    } elseif [string match retain* $word] {
                        set tl {3 48 58 64 263 66 68 151 204 206 397 312 207 208 96 215 216 307 240 253 332 339 267 402 483}
                    } elseif [string match retim* $word] {
                        set tl {143 144 147 308 339 344 352 277 281 370 372 376 416 420 468}
                    } elseif [string match retriev* $word] {
                        set tl {332 342 258 267 364}
                    } elseif [string match retro* $word] {
                        set tl {109 149 201 323 352}
                    } elseif [string match reverb* $word] {
                        set tl {24 392 198 353 355 199 200 383 322 354 256 382 469}
                    } elseif [string match revers* $word] {
                        set tl {109 149 154 155 156 201 308 323 352 476}
                    } elseif [string match ris* $word] {
                        set tl {192}
                    } elseif [string match rit* $word] {
                        set tl {197 283}
                    } elseif [string match rogue* $word] {
                        set tl {219}
                    } elseif [string match rotat* $word] {
                        set tl {196 373 380 404 405 406 407 409 410 411 412 413 414 442 460 461 466 469 483}
                    } elseif [string match rumble* $word] {
                        set tl {185 186 187 318}
                    } else {
                        return 0
                    }
                }
            }
        }
        "s" {
            switch -- $word {
                "samprate"      -
                "srate"         { set tl {217 219} }
                "samptype"      -
                "stype"         { set tl {217} }
                "sampcnt"       { set tl {228 229} }
                "sphinx"        { set tl {296 318 271 272 275 276 393 420 421 461 462 463 469 470 471 472 473 474 476 477 478 480 482 391} }
                "sausage"       { set tl {199 200 383 442 461 462 468 474 476 477 478 482} }
                "save"          -
                "store"         { set tl {220 467} }
                "selfsimilar"   { set tl {108 313 345 351 256 420 421 434 449 461 463 466 469 471 472 473 474 476 477 484 481} }
                "shudder"       { set tl {327 462 476} }
                "smptime"       { set tl {67 68 79 86 163 164 165 166 167 168 217 228 229 236} }
                "spec"          { set tl {217 219 223 293 298 305 394} }
                "stadium"       { set tl {198 353 355 199 354 256 356 357 358 359 382 373 383 399 404 405 406 407 409 410 411 412 413 414 469} }
                "stereo"        { set tl {75 77 78 171 215 231 234 362 95 451 460 461} }
                "subtract"      { set tl {227 71 310 319 267 269 280 359 361 370 415 416 422} }
                "sumlen"        { set tl {224 225 226 227} }
                "sync"          { set tl {148 179 180 376 416 420 461} }
                default {

                    switch -- [string index $word 1] {
                        "a" {
                            if [string match sampl* $word] {
                                set tl {28 29 217 219 228 230 99 248 320 339 266 402 467}
                            } elseif [string match salami* $word] {
                                set tl {365 372 415 416 418 421 436 437 442 443 449 462 468 469 471 472 473 474 476 477 478 482}
                            } else {
                                return 0
                            }
                        }
                        "c" {
                            if [string match scatt* $word] {
                                set tl {38 54 121 124 125 126 127 128 129 130 131 132 133 134 135 136 137 374 417 178 245 333 338 256 404 405 406 407 409 410 411 412 413 414 421 459 460 461 462 473 477 478}
                            } elseif [string match scal* $word] {
                            set tl {315 321 344 443}
                            } elseif [string match scrambl* $word] {
                            set tl {34 35 110 121 123 176 199 199 200 383 252 253 333 338 415 417 421 431 462 468 469 470 474 476 477 478 482}
                            } elseif [string match scrub* $word] {
                                set tl {201 416}
                            } else {
                                return 0
                            }
                        }
                        "e" {
                            if [string match see* $word] {
                                set tl {67 68 77 78 79 83 86 88 182 189 223 224 225 235 342 258 369 483}
                            } elseif [string match segm* $word] {
                                set tl {209 210 216 307 308 318 320 332 333 338 343 345 351 347 352 257 259 266 267 278 365 366 367 370 372 376 393 394 402 415 416 436 437 462 467 468 469 471 472 473 474 476 477 478 482 483 484 481}
                            } elseif [string match select* $word] {
                                set tl {48 92 64 263 66 68 73 151 204 215 216 240 310 339 266 267 402}
                            } elseif [string match semit* $word] {
                                set tl {236 450}
                            } elseif [string match sequenc* $word] {
                                set tl {110 183 379 308 309 321 344 328 333 338 336 376 404 405 406 407 409 410 411 412 413 414 416 418 419 435 436 437 463 466 471 472 481}
                            } elseif [string match set* $word] {
                                set tl {13 14 15 16 124 125 126 127 128 129 130 131 132 133 134 135 136 137 188 189 190 191 348 240 241 242 243 244 245 246 247 250 255 289 290 321 333 338 344 97 450}
                            } else {
                                return 0
                            }
                        }
                        "h" {
                            if [string match shap* $word] {
                                set tl {25 51 62 63 65 264 66 74 102 114 152 315 153 154 155 156 308 309 310 313 314 321 323 339 343 344 277 281 285 286 376  399 404 405 406 407 408 409 410 411 412 413 414 416 428 429 435 443 449 455 456 458 460 461 471 472 475 482 484 391}
                            } elseif [string match shak* $word] {
                                set tl {327 460 461 462 474 476 477}
                            } elseif [string match shift* $word] {
                                set tl {12 27 40 452}
                            } elseif [string match short* $word] {
                                if [string match shorten* $word] {
                                    set tl {8 9 1003 115 145 158 371 177 199 352 279 370 376 416 468}
                                } else {
                                    set tl {8 9 1003 105 106 145 177 199 416}
                                }
                            } elseif [string match show* $word] {
                                set tl {67 68 77 78 79 83 86 88 189 223 224 225 235 342 258 285 369 92 483}
                            } elseif [string match shred* $word] {
                                set tl {201 318 320 343 259 365 93 393 394 415 416 421 431 462 468 469 473 474 476 477 478 482}
                            } elseif [string match shud* $word] {
                                set tl {327 421 462 476 477}
                            } elseif [string match shuffl* $word] {
                                set tl {34 35 110 121 123 141 176 199 200 383 253 308 333 338 417 420 421 449 458 468 474 477 478 482 504}
                            } else {
                                return 0
                            }
                        }
                        "i" {
                            if [string match silen* $word] {
                                set tl {104 212 375 282 215 239 251 300 301 302 310 319 320 269 381 376 415 448}
                            } elseif [string match sin* $word] {
                                set tl {237 254 483}
                            } else {
                                return 0
                            }
                        }
                        "l" {
                            if [string match slic* $word] {
                                set tl {365 372 376 393 394 402 415 416 421 436 437 462 467 468 469 473 474 476 477 478 482}
                            } elseif [string match slid* $word] {
                                set tl {41 192 197 283 268}
                            } else {
                                return 0
                            }
                        }
                        "m" {
                            if [string match smooth* $word] {
                                set tl {55 157 310 376 453 483 484}
                            } elseif [string match smpset* $word] {
                                set tl {228 229}
                            } else {
                                return 0
                            }
                        }
                        "o" {
                            if [string match sort* $word] {
                                set tl {177 218 219 246 308 333 338 478}
                            } elseif [string match sound* $word] {
                                set tl {216 467}
                            } elseif [string match sourc* $word] {
                                set tl {216 467}
                            } else {
                                return 0
                            }
                        }
                        "p" {
                            if [string match spac* $word] {
                                if [string match spacewarp* $word] {
                                    set tl {196 254 256 274 373 380 383 94 399 404 405 406 407 409 410 411 412 413 414 418 419 420 421 460 461 462 463 466}
                                } else {
                                    set tl {178 326 196 316 222 254 329 354 355 256 274 373 383 380 95 94 399 404 405 406 407 409 410 411 412 413 414 418 419 420 421 459 460 461 462 466}
                                }
                            } elseif [string match spati* $word] {
                                set tl {178 326 196 316 254 329 354 355 256 274 373 383 374 417 380 95 94 399 404 405 406 407 409 410 411 412 413 414 418 419 420 421 459 460 461 462 466}
                            } elseif [string match speci* $word] {
                                set tl {217 219 223 354}
                            } elseif [string match spectr* $word] {
                                set tl {1 2 3 4 360 361 5 6 7 8 9 1003 10 11 12 13 14 15 16 17 18 19 20 22 22 23 24 392 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 293 303 480}
                                set tl [concat $tl 44 45 46 47 48 92 62 63 64 263 65 264 66 67 68 69 304 70 391 71 72 73 74 75 76 77 78 79 80 81 82 83 202 203 204 248 313 314 322 348 284 285 286 365 408 424 434 449 458]
                            } elseif [string match speed* $word] {
                                set tl {197 283 352 259 260 261 262 370 372 376 404 405 406 407 409 410 411 412 416 418 420 460 461 468 471 476}
                            } elseif [string match speech* $word] {
                                set tl {216 305 314 332 345 351 259 260 261 262 266 267 268 270 271 272 273 274 275 276 277 281 278 279 284 286 366 367 369 370 372 376 416 474 475 476 477 480 483 391}
                            } elseif [string match speak* $word] {
                                set tl {216 305 314 332 260 261 262 266 267 268 270 271 272 273 274 275 276 277 281 278 279 284 370 372 476 477 480}
                            } elseif [string match spike* $word] {
                                set tl {403 475 476}
                            } elseif [string match splic* $word] {
                                set tl {10 48 58 64 263 66 8 113 151 204 206 397 398 312 393 207 208 96 209 210 211 325 212 375 282 213 214 215 216 307 240 246 251 252 253 319 320 323 332 333 338 257 261 266 267 279 365 372 394 402 415 416 476}
                            } elseif [string match spread* $word] {
                                set tl {23 30 31 38 39 54 121 245 308 328 379 353 355 256 373 383 95 399 404 405 406 407 409 410 411 412 459 469 473 476}
                            } else {
                                return 0
                            }
                        }
                        "q" {
                            if [string match squeez* $word] {
                                set tl {8 9 1003 27 105 106 115 145 177 199 370 372 376 416 432 468 483}
                            } elseif [string match squa* $word] {
                                set tl {237 416 499}
                            } else {
                                return 0
                            }
                        }
                        "r" {
                            if [string match src* $word] {
                                set tl {216}
                            } else {
                                return 0
                            }
                        }
                        "t" {
                            if [string match stack* $word] {
                                set tl {188 189 190 191 183 379 308 313 328 333 338 284 418 419 420 421 442 443 461 463 469 473 474 476}
                            } elseif [string match start* $word] {
                                set tl {21 160 161 180 381 376}
                            } elseif [string match step* $word] {
                                set tl {28 29 36 248 308 321 328 379 372 404 405 406 407 409 410 411 412 413 414 416 476}
                            } elseif [string match string* $word] {
                                set tl {213 183 379 308 328 333 338 435 436 437}
                            } elseif [string match stronge* $word] {
                                set tl {22 231 313 338 339 443 475 484}
                            } elseif [string match strum* $word] {
                                set tl {20 473}
                            } else {
                                return 0
                            }
                        }
                        "u" {
                            if [string match subh* $word] {
                                set tl {188 189 348 270 273}
                            } elseif [string match substitut* $word] {
                                set tl {101 104 114 308 310 335 336 272 276 286 434 449 450 480}
                            } elseif [string match sum* $word] {
                                set tl {70 391 226 183 379 308 272 408 461}
                            } elseif [string match suppress* $word] {
                                set tl {23 30 31 32 310 319 346 269 280 359 370 376 415 416 422 443 480 483 499}
                            } elseif [string match sustain* $word] {
                                set tl {24 392 28 29 248 310 339 345 351 353 355 266 277 281 428 429 435 436 437 469 473 474 476 504}
                            } else {
                                return 0
                            }
                        }
                        "w" {
                            if [string match swap* $word] {
                                set tl {101 104 114 141 295 296 335 336 373 449}
                            } elseif [string match sweep* $word] {
                                set tl {192 380 373 383 399 404 405 406 407 409 410 411 412 413 414 460 461}
                            } elseif [string match swell* $word] {
                                set tl {159 323 339 404 405 406 407 443 461 484}
                            } elseif [string match swirl* $word] {
                                set tl {380 404 405 406 407 409 410 411 412 413 414 442 459 460 461 468}
                            } elseif [string match switch* $word] {
                                set tl {295 296 320 373 419 420 449 458}
                            } else {
                                return 0
                            }
                        }
                        "y" {
                            if [string match syllab* $word] {
                                set tl {216 314 332 272 277 281 369 372 416 476 477 483 484}
                            } elseif [string match synch* $word] {
                                set tl {148 179 180 183 379 313 336 376 418 420}
                            } elseif [string match syncop* $word] {
                                set tl {143 144 147 308 321 344 418 419 420 474 475}
                            } elseif [string match synth* $word] {
                                set tl {41 69 304 150 172 337 203 237 238 239 403 293 298 305 309 314 318 330 97 266 271 366 367 408 423 427 435 438 441 442 454 466 479}
                            } else {
                                return 0
                            }
                        }
                        default {
                            return 0
                        }
                    }
                }
            }
        }
        "t" {
            switch -- $word {
                "tape"          { set tl {197 283} }
                "template"      { set tl {183 379 308 309 314 320 321 328 330 333 338 335 336 343 344 345 97 191 348 354 271 272 276 285 365 376 95 393 394 396 399 415 416 420 427 434 450 463 466 467 471 472 473 476 483} }
                "time-extend"   { set tl {7 323 339 345 351 111 352 368 259 260 262 266 277 281 404 405 406 407 409 410 411 412 428 429 435 459 474 476 477 481 504} }
                "timed"         { set tl {134 135 136 137 308 320 328 379 330 321 344 376} }
                "timediff"      { set tl {224 225 226 227 328 379} }
                "times"         { set tl {58 120 174 177 320 328 379 330 369 376 381 416} }
                "time"          { set tl {7 9 1003 119 377 433 120 121 122 123 140 145 177 199 323 331 339 345 351 154 155 156 354 260 261 278 376} }
                "timesmp"       { set tl {67 68 79 86 163 164 165 166 167 168 217 228 229 236 308 278} }
                "timing"        { set tl {146 308 321 328 379 330 339 344 352 368 354 259 260 261 262 277 281 278 372 376 381 416 418 420} }
                "tone"          { set tl {87 334 396 450} }
                "top"           { set tl {216 341} }
                "try out"       { set tl {174 183 379 181 182 97} }
                "tuning"        { set tl {13 396 14 15 16 124 125 126 127 128 129 130 131 132 133 134 135 136 137 188 189 190 191 348 309 313 321 334 344 97 272 92 428 429 435 450 483} }
                "twist"         { set tl {178 380 442 460 461} }
                default {
                    if [string match tail* $word] {
                        set tl {216 341 277 281 404 405 406 407 416 473 481}
                    } elseif [string match tak* $word] {
                        set tl {176 422}
                    } elseif [string match teas* $word] {
                        set tl {48 64 263 66 68 151 204 215 216 240}
                    } elseif [string match telescop* $word] {
                        set tl {115 308 323 352 259 261 370 372 376 416 432 461 468}
                    } elseif [string match test* $word] {
                        set tl {87 174 181 182 183 379 342 258 364 381 92 422}
                    } elseif [string match textur* $word] {
                        set tl {124 125 126 127 128 129 130 131 132 133 134 135 136 137 374 417 308 320 256 259 393 394 399 404 405 406 407 409 410 411 412 418 421 442 459 462 463 469 476 477}
                    } elseif [string match tim* $word] {
                        if [string match timegap* $word] {
                            set tl {177 308 328 379 370 372 376 381 415 416 418 419 420}
                        } else {
                            set tl {9 1003 134 135 136 137 143 144 145 146 147 177 196 316 199 224 225 226 227 183 379 308 328 330 352 277 281 278 381 416 419 420}
                        }
                    } elseif [string match topn* $word] {
                        set tl {216 341 416}
                    } elseif [string match trac* $word] {
                        set tl {20 22 23 404 405 406 407 409 410 411 412 416 483}
                    } elseif [string match transit* $word] {
                        set tl {45 46 47 112 172 337 310 268 404 405 406 407 409 410 411 412 413 414 424}
                    } elseif [string match transpos* $word] {
                        set tl {11 12 27 56 60 61 118 142 144 197 283 313 321 344 259 262 270 273 284 396 428 429 450 471 472 475 483}
                    } elseif [string match tremol* $word] {
                        set tl {42 57 162 400 197 283 318 327 338 343 270 91 460 461 471 472}
                    } elseif [string match tremb* $word] {
                        set tl {327 338 270 415 431 460 461 462 470 476}
                    } elseif [string match tria* $word] {
                        set tl {237}
                    } elseif [string match trigger* $word] {
                        set tl {154 155 156}
                    } elseif [string match tun* $word] {
                        set tl {13 396 14 15 16 321 344 191 348 272 92 428 429 450 480 483}
                    } else {
                        return 0
                    }
                }
            }
        }
        "u" {
            switch -- $word {
                "unit"          { set tl {236 402 473 474} }
                "unite"         { set tl {117 201 183 379 308 310 313 322 323 272 275 276 461} }
                "units"         { set tl {236 308 332 347 278 376 402 404 405 406 407 409 410 411 412 413 414 416 418 419 473 474 476 477 478} }
                "unpitched"     { set tl {85 310 319} }
                default {
                    if [string match unfocus* $word] {
                        set tl {23 30 31 32 198 353 355 382 373 383 399 421 431 443 459 460 461 462 469 470 474 476 477 478 480 482 499}
                    } elseif [string match unif* $word] {
                        set tl {117 201 183 379 308 484}
                    } elseif [string match uniti* $word] {
                        set tl {117 201}
                    } elseif [string match unstabl* $word] {
                        set tl {42 57 162 400 197 283 91 459 462 470 471 472 474 477}
                    } elseif [string match user* $word] {
                        set tl {42 102 119 190}
                    } else {
                        return 0
                    }
                }
            }
        }
        "v" {
            switch -- $word {
                "vector"        { set tl {240 241 242 243 244 245 246 247 250 335} }
                default {
                    if [string match value* $word] {
                        set tl {240 241 242 243 244 245 246 247 250 342 258 278}
                    } elseif [string match vari* $word] {
                        set tl {187 191 348 338 416 474}
                    } elseif [string match vib* $word] {
                        set tl {42 57 197 283 318 270 415 460 461 476}
                    } elseif [string match view* $word] {
                        set tl {67 68 77 78 79 83 86 88 182 189 223 224 225 235 342 258}
                    } elseif [string match vocod* $word] {
                        set tl {65 264 66 314 272 391 500}
                    } elseif [string match vowel* $word] {
                        set tl {305 314 332 266 277 281 402 483}
                    } else {
                        return 0
                    }
                }
            }
        }
        "w" {
            switch -- $word {
                "washout"       { set tl {23 30 31 32 323 198 353 355 382 416 431 462 468 469 473 478 480 482 499} }
                "waveset"       { set tl {100 101 102 103 104 105 106 107 108 109 110 111 349 340 112 113 114 115 116 117 118 393 452 453 455 467 478} }
                default {
                    if [string match wander* $word] {
                        set tl {34 35 36 110 123 176 191 348 377 433 404 405 406 407 409 410 411 412 413 414 417 428 429 459 460 461 470}
                    } elseif [string match warm* $word] {
                        set tl {198 353 355 199}
                    } elseif [string match waver* $word] {
                        set tl {42 57 162 400 197 283 318 338 343 270 91 415 421 460 461 462 470 474 476 477}
                    } elseif [string match weav* $word] {
                        set tl {36 183 379 308 333 338 272 377 433 380 95 393 394 404 405 406 407 409 410 411 412 413 414 418 418 419 421 428 429 442 443 449 458 461 463 469 471 472 474 477 478 482 391}
                    } elseif [string match wide* $word] {
                        set tl {232 362 373 383 399 404 405 406 407 409 410 411 412 413 414}
                    } elseif [string match window* $word] {
                        set tl {35 36 45 76}
                    } elseif [string match wobbl* $word] {
                        set tl {42 57 162 400 197 283 318 327 270 91 415 459 460 461 462 470 471 472 476 477}
                    } elseif [string match writ* $word] {
                        set tl {77 78 83 88 189 223 224 225 235 309 342 258}
                    } else {
                        return 0
                    }
                }
            }
        }
        "z" {
            switch -- $word {
                default {
                    if [string match zcut* $word] {
                        set tl {58 208 96 352 267 467 478}
                    } elseif [string match zero* $word] {
                        set tl {75 77 78 85 171 215 231 234 350 352 381 376}
                    } elseif [string match zig* $word] {
                        set tl {119 377 433 308 333 338 94 404 405 406 407 409 410 411 412 413 414 461 471 472 477}
                    } else {
                        return 0
                    }
                }
            }
        }
        default {
            return 0
        }
    }

    # DO THE BUSINESS

    if {$i == 0} {                      ;#  If it's first pass, copy tl to progs_list
        catch {unset progs_list}
        set prog_list $tl
    } else {                            ;#  else, compare progs_list so far with tl
        set listlen [llength $tl]
        eval {ResetProgslist $listlen} $tl
    }
    return 1
}

#------ This program displays user message, program name ,and menu index, for valid programs

proc DisplayUserMessageAndMenuIndex {ff} {
    global prog_list pr_which query_display_listcnt released snack_enabled 8chanflag released evv
    global specnu_version

    label $ff.la2 -text "MENU"
    label $ff.lb2 -text "PROCESS"
    label $ff.lc2 -text "DESCRIPTION"                           ;#  Title line
    grid  $ff.la2 -row 0 -column 0 -sticky ew
    grid  $ff.lb2 -row 0 -column 2 -sticky ew
    grid  $ff.lc2 -row 0 -column 4 -sticky ew
    frame $ff.f3 -bg [option get . foreground {}] -width 20 -height 1           ;#  separator line
    grid  $ff.f3 -row 1 -column 0 -columnspan 5 -sticky ew
    set query_display_listcnt 2                                 ;#  we already have query line, and titles

    foreach prog_no $prog_list {

        if {($prog_no > $evv(MAX_RELEASE_PROGNO)) && ($prog_no < $evv(PSEUDO_PROGS_BASE))} {
            continue
        }
        switch -- $prog_no {
            1   {
                DisplayFoundItem "simple" "gain" $query_display_listcnt $ff \
                 "change loudness of spectrum"
            }
            2   {
                DisplayFoundItem "simple" "gate" $query_display_listcnt $ff \
                 "remove low level data from spectrum"
            }
            3   {
                DisplayFoundItem "simple" "bare partials" $query_display_listcnt $ff \
                 "retain only harmonic partials"
            }
            4   {
                DisplayFoundItem "simple" "clean" $query_display_listcnt $ff \
                 "remove noise from spectrum"
            }
            5   {
                DisplayFoundItem "simple" "cut" $query_display_listcnt $ff \
                 "cut and keep a timeslice of the spectrum"
            }
            6   {
                DisplayFoundItem "simple" "grab window" $query_display_listcnt $ff \
                 "grab an instantaneous spectral window"
            }
            7   {
                DisplayFoundItem "simple" "magnify window" $query_display_listcnt $ff \
                 "time-extend a single spectral window"
            }
            8   {
                DisplayFoundItem "stretch" "spectral stretch" $query_display_listcnt $ff \
                 "stretch the frequency layout of spectrum"
            }
            9   {
                DisplayFoundItem "stretch" "time stretch" $query_display_listcnt $ff \
                 "timewarp the spectral file"
            }
            10  {
                DisplayFoundItem "pitch & harmony" "alternate harmonics" $query_display_listcnt $ff \
                 "delete alternate harmonics in spectrum"
            }
            11  {
                DisplayFoundItem "pitch & harmony" "octave shift" $query_display_listcnt $ff \
                 "octave shift the spectrum"
            }
            12  {
                DisplayFoundItem "pitch & harmony" "pitch shift" $query_display_listcnt $ff \
                 "transpose the spectrum"
            }
            13  {
                DisplayFoundItem "pitch & harmony" "tune spectrum" $query_display_listcnt $ff \
                 "tune the partials in a spectrum"
            }
            14  {
                DisplayFoundItem "pitch & harmony" "choose partials" $query_display_listcnt $ff \
                 "pick and retain specific partials in a spectrum"
            }
            15  {
                DisplayFoundItem "pitch & harmony" "chord" $query_display_listcnt $ff \
                 "produce chord over spectrum"
            }
            16  {
                DisplayFoundItem "pitch & harmony" "chord (keep fmnts)" $query_display_listcnt $ff \
                 "produce chord over spectrum while retaining spectral envelope"
            }
            17  {
                DisplayFoundItem "highlight" "filter" $query_display_listcnt $ff \
                 "filter the spectrum"
            }
            18  {
                DisplayFoundItem "highlight" "graphic eq" $query_display_listcnt $ff \
                 "graphic eq filter on the spectrum"
            }
            19  {
                DisplayFoundItem "highlight" "bands" $query_display_listcnt $ff \
                 "process spectrum in defined bands"
            }
            20  {
                DisplayFoundItem "highlight" "arpeggiate" $query_display_listcnt $ff \
                 "arpeggiate the spectrum"
            }
            21  {
                DisplayFoundItem "highlight" "pluck" $query_display_listcnt $ff \
                 "add attack to spectral changes"
            }
            22  {
                DisplayFoundItem "highlight" "trace" $query_display_listcnt $ff \
                 "form tracery from loudest partials"
            }
            23  {
                DisplayFoundItem "highlight" "blur & trace" $query_display_listcnt $ff \
                 "blur spectrum and form tracery"
            }
            24  {
                DisplayFoundItem "focus" "accumulate" $query_display_listcnt $ff \
                 "sustain louder partials in spectrum (possibly gliss them)"
            }
            25  {
                DisplayFoundItem "focus" "exaggerate" $query_display_listcnt $ff \
                 "exaggerate the spectral contour"
            }
            26  {
                DisplayFoundItem "focus" "focus" $query_display_listcnt $ff \
                 "focus energy onto spectral peaks"
            }
            27  {
                DisplayFoundItem "focus" "fold in" $query_display_listcnt $ff \
                 "octave shift partials into given range"
            }
            28  {
                DisplayFoundItem "focus" "freeze" $query_display_listcnt $ff \
                 "sample-hold spectral characteristics"
            }
            29  {
                DisplayFoundItem "focus" "step through" $query_display_listcnt $ff \
                 "sample-hold spectrum at regular times"
            }
            30  {
                DisplayFoundItem "blur" "average" $query_display_listcnt $ff \
                 "blur the freq focus of spectrum"
            }
            31  {
                DisplayFoundItem "blur" "blur" $query_display_listcnt $ff \
                 "blur the time resolution of spectrum"
            }
            32  {
                DisplayFoundItem "blur" "supress" $query_display_listcnt $ff \
                 "suppress the most prominent partials"
            }
            33  {
                DisplayFoundItem "blur" "chorus" $query_display_listcnt $ff \
                 "chorus-effect or add noise to spectrum"
            }
            34  {
                DisplayFoundItem "blur" "drunkwalk" $query_display_listcnt $ff \
                 "drunken walk through spectrum"
            }
            35  {
                DisplayFoundItem "blur" "shuffle" $query_display_listcnt $ff \
                 "shuffle order of spectral windows"
            }
            36  {
                DisplayFoundItem "blur" "weave" $query_display_listcnt $ff \
                 "weave a path through spectral windows"
            }
            37  {
                DisplayFoundItem "blur" "noise" $query_display_listcnt $ff \
                 "add controlled noise to the spectrum"
            }
            38  {
                DisplayFoundItem "blur" "scatter" $query_display_listcnt $ff \
                 "randomly thin-out the spectrum"
            }
            39  {
                DisplayFoundItem "blur" "spread" $query_display_listcnt $ff \
                 "spread spectral peaks adding noise"
            }
            40  {
                DisplayFoundItem "strange" "linear shift" $query_display_listcnt $ff \
                 "linear frq shift spectrum making it inharmonic"
            }
            41  {
                DisplayFoundItem "strange" "inner glissando" $query_display_listcnt $ff \
                 "create glissandi inside spectral envelope"
            }
            42  {
                DisplayFoundItem "strange" "waver" $query_display_listcnt $ff \
                 "vibrato from harmonic to inharmonic state"
            }
            44  {
                DisplayFoundItem "strange" "invert" $query_display_listcnt $ff \
                 "invert the spectrum"
            }
            45  {
                DisplayFoundItem "morph" "glide" $query_display_listcnt $ff \
                 "simple interpolation between 2 single spectral windows"
            }
            46  {
                DisplayFoundItem "morph" "bridge" $query_display_listcnt $ff \
                 "simple interpolation between 2 sound spectra"
            }
            47  {
                DisplayFoundItem "morph" "morph" $query_display_listcnt $ff \
                 "morph between 2 possibly time-changing spectra"
            }
            48  {
                DisplayFoundItem "repitch" "extract pitch" $query_display_listcnt $ff \
                 "extract pitch line from spectrum"
            }
            50  {
                DisplayFoundItem "repitch" "approx" $query_display_listcnt $ff \
                 "make approx copy of pitch-line in a pitch file"
            }
            51  {
                DisplayFoundItem "repitch" "exaggerate" $query_display_listcnt $ff \
                 "exaggerate contour of pitch-line in a pitch file"
            }
            52  {
                DisplayFoundItem "repitch" "invert" $query_display_listcnt $ff \
                 "musically invert a pitch-line in a pitch file"
            }
            53  {
                DisplayFoundItem "repitch" "quantise" $query_display_listcnt $ff \
                 "quantise pitches of a pitch-line in a pitch file"
            }
            54  {
                DisplayFoundItem "repitch" "randomise" $query_display_listcnt $ff \
                 "randomise pitches of a pitch-line in a pitch file"
            }
            55  {
                DisplayFoundItem "repitch" "smooth" $query_display_listcnt $ff \
                 "smooth line of a pitch-line in a pitch file"
            }
            56  {
                DisplayFoundItem "repitch" "transpose" $query_display_listcnt $ff \
                 "fixed transposition of a pitch-line in a pitch file"
            }
            57  {
                DisplayFoundItem "repitch" "vibrato" $query_display_listcnt $ff \
                 "add vibrato to a pitch-line in a pitch file"
            }
            58  {
                DisplayFoundItem "repitch" "cut" $query_display_listcnt $ff \
                 "cut and keep timeslice of a pitch-line in a pitch file"
            }
            59  {
                DisplayFoundItem "repitch" "fix" $query_display_listcnt $ff \
                 "fix glitches in a pitch-line in a pitch file"
            }
            60  {
                DisplayFoundItem "repitch" "repitch" $query_display_listcnt $ff \
                 "combine pitch or transposition data to get new data"
            }
            61  {
                DisplayFoundItem "repitch" "repitch to textfile" $query_display_listcnt $ff \
                 "combine pitch or transposition data to get new brkpnt data"
            }
            62  {
                DisplayFoundItem "repitch" "transpose" $query_display_listcnt $ff \
                 "impose pitchline in pitchfile on spectrum"
            }
            63  {
                DisplayFoundItem "repitch" "transpose(keep fmnts)" $query_display_listcnt $ff \
                 "impose pitchline in pitchfile on spectrum but keep original formants"
            }
            64  {
                DisplayFoundItem "formants" "extract" $query_display_listcnt $ff \
                 "extract spectral envelope of spectrum"
            }
            65  {
                DisplayFoundItem "formants" "impose" $query_display_listcnt $ff \
                 "impose spectral envelope on spectrum"
            }
            66  {
                DisplayFoundItem "formants" "vocode" $query_display_listcnt $ff \
                 "get spectral envelope of 1st spectrum imposing it on 2nd"
            }
            67  {
                DisplayFoundItem "formants" "view" $query_display_listcnt $ff \
                 "convert spectral envelope to pseudo-sndfile to view"
            }
            68  {
                DisplayFoundItem "formants" "get & view" $query_display_listcnt $ff \
                 "extract spectral envelope: convert to pseudo-sndfile to view"
            }
            69  {
                DisplayFoundItem "combine spectra" "add pitch to formants" $query_display_listcnt $ff \
                 "make new spectrum by adding pitchline in pitchfile to formantdata"
            }
            70  {
                DisplayFoundItem "combine spectra" "sum" $query_display_listcnt $ff \
                 "sum two spectra"
            }
            71  {
                DisplayFoundItem "combine spectra" "difference" $query_display_listcnt $ff \
                 "find difference of two spectra"
            }
            72  {
                DisplayFoundItem "combine spectra" "interleave" $query_display_listcnt $ff \
                 "interleave spectra"
            }
            73  {
                DisplayFoundItem "combine spectra" "windowwise max" $query_display_listcnt $ff \
                 "select maximum of 2 spectra from moment to moment"
            }
            74  {
                DisplayFoundItem "combine spectra" "mean" $query_display_listcnt $ff \
                 "generate mean of 2 spectra"
            }
            75  {
                DisplayFoundItem "combine spectra" "cross channels" $query_display_listcnt $ff \
                 "replace channel amplitudes of 1st file with those of 2nd"
            }
            76  {
                DisplayFoundItem "spectrum info" "window count" $query_display_listcnt $ff \
                 "count windows in spectrum"
            }
            77  {
                DisplayFoundItem "spectrum info" "channel" $query_display_listcnt $ff \
                 "show analysis channels corresponding to freq in spectrum"
            }
            78  {
                DisplayFoundItem "spectrum info" "get frequency" $query_display_listcnt $ff \
                 "show freq corresponding to analysis channels in spectrum"
            }
            79  {
                DisplayFoundItem "spectrum info" "view level" $query_display_listcnt $ff \
                 "convert varying level of spectrum to pseudo-sndfile to view"
            }
            80  {
                DisplayFoundItem "spectrum info" "print octbands" $query_display_listcnt $ff \
                 "report timevarying spectral level in octave bands"
            }
            81  {
                DisplayFoundItem "spectrum info" "print energy centres" $query_display_listcnt $ff \
                 "report timevarying energy centre of spectrum"
            }
            82  {
                DisplayFoundItem "spectrum info" "print freq peaks" $query_display_listcnt $ff \
                 "report freqs of freq peaks in timevarying spectrum"
            }
            83  {
                DisplayFoundItem "spectrum info" "print analysis data" $query_display_listcnt $ff \
                 "numeric printout of spectrum"
            }
            84  {
                DisplayFoundItem "pitch info" "print pitch info" $query_display_listcnt $ff \
                 "report mean & max & min & range of pitchdata"
            }
            85  {
                DisplayFoundItem "pitch info" "check for pitch zeros" $query_display_listcnt $ff \
                 "report any zeros in pitchdata"
            }
            86  {
                DisplayFoundItem "pitch info" "pitch view" $query_display_listcnt $ff \
                 "convert pitchdata to pseudo-sndfile to view"
            }
            87  {
                DisplayFoundItem "pitch info" "pitch to testtone" $query_display_listcnt $ff \
                 "convert pitchdata to tone in order to hear it"
            }
            88  {
                DisplayFoundItem "pitch info" "pitch write" $query_display_listcnt $ff \
                 "numeric printout of pitchdata"
            }
            90  {
                if {[info exists released(mton)]} {
                    DisplayFoundItem "channels" "mono to multichannel" $query_display_listcnt $ff \
                     "convert mono sound to multichannel sound"
                }
            }
            91  {
                if {[info exists released(flutter)]} {
                    DisplayFoundItem "multichan" "multichannel flutter" $query_display_listcnt $ff \
                     "add multichannel loudness fluttering to a sound"
                }
            }
            92  {
                if {[info exists released(peak)]} {
                    DisplayFoundItem "repitch" "extract peaks" $query_display_listcnt $ff \
                     "Find peaks in analysis file and write to textfile"
                }
            }
            93  {
                if {[info exists released(mchshred)]} {
                    DisplayFoundItem "multichan" "multichannel shred" $query_display_listcnt $ff \
                     "Shred file to multichannel output"
                }
            }
            94  {
                if {[info exists released(mchzig)]} {
                    DisplayFoundItem "multichan" "multichannel zigzag" $query_display_listcnt $ff \
                     "read back and forth in sound and random pan"
                }
            }
            95 {
                if {[info exists released(mchstereo)]} {
                    DisplayFoundItem "multichan" "mix stereo to multichan" $query_display_listcnt $ff \
                     "mix several stereo images to multichannel output space"
                }
            }
            96  {
                DisplayFoundItem "edit" "cutout many at zero-crossings" $query_display_listcnt $ff \
                 "cut and keep time-segments of sound but edit at zero-crossings only"
            }
            97  {
                DisplayFoundItem "synth" "chord" $query_display_listcnt $ff \
                 "synthesize a chord from midi data"
            }
            98  {
                DisplayFoundItem "mix" "balance" $query_display_listcnt $ff \
                 "mix two sounds using a balance function"
            }
            99  {
                DisplayFoundItem "sound info" "max sample in timerange" $query_display_listcnt $ff \
                 "find maximum sample within timerange in sndfiling-system file"
            }
            100 {
                DisplayFoundItem "distort" "cyclecnt" $query_display_listcnt $ff \
                 "report count of wavesets in sound"
            }
            101 {
                DisplayFoundItem "distort" "reshape" $query_display_listcnt $ff \
                 "distort by replacing wavesets with ones of given shape"
            }
            102 {
                DisplayFoundItem "distort" "envelope" $query_display_listcnt $ff \
                 "distort by creating envelope over wavesets"
            }
            103 {
                DisplayFoundItem "distort" "average" $query_display_listcnt $ff \
                 "distort wavesets to average shape"
            }
            104 {
                DisplayFoundItem "distort" "omit" $query_display_listcnt $ff \
                 "distort by replacing some wavesets with silence"
            }
            105 {
                DisplayFoundItem "distort" "multiply" $query_display_listcnt $ff \
                 "distort wavesets by multiplying freq"
            }
            106 {
                DisplayFoundItem "distort" "divide" $query_display_listcnt $ff \
                 "distort wavesets by dividing freq"
            }
            107 {
                DisplayFoundItem "distort" "harmonic" $query_display_listcnt $ff \
                 "distort by adding harmonics to wavesets"
            }
            108 {
                DisplayFoundItem "distort" "fractal" $query_display_listcnt $ff \
                 "distort wavesets by fractalisation"
            }
            109 {
                DisplayFoundItem "distort" "reverse" $query_display_listcnt $ff \
                 "distort by reversing wavesets"
            }
            110 {
                DisplayFoundItem "distort" "shuffle" $query_display_listcnt $ff \
                 "distort by shuffling wavesets"
            }
            111 {
                DisplayFoundItem "distort" "repeat" $query_display_listcnt $ff \
                 "distort by repeating wavesets (or groups of wavesets)"
            }
            112 {
                DisplayFoundItem "distort" "interpolate" $query_display_listcnt $ff \
                 "distort by interpolating between shape of wavesets"
            }
            113 {
                DisplayFoundItem "distort" "delete" $query_display_listcnt $ff \
                 "distort by deleting wavesets"
            }
            114 {
                DisplayFoundItem "distort" "replace" $query_display_listcnt $ff \
                 "distort by replacing wavesets by more prominent neighbours"
            }
            115 {
                DisplayFoundItem "distort" "telescope" $query_display_listcnt $ff \
                 "distort time-contract by telescoping wavesets"
            }
            116 {
                DisplayFoundItem "distort" "filter" $query_display_listcnt $ff \
                 "distort by filtering out wavesets of given freq range"
            }
            117 {
                DisplayFoundItem "distort" "interact" $query_display_listcnt $ff \
                 "distort by combining waveset properties from 2 different sounds"
            }
            118 {
                DisplayFoundItem "distort" "pitch" $query_display_listcnt $ff \
                 "distort by changing pitch of wavesets"
            }
            119 {
                DisplayFoundItem "extend" "zigzag" $query_display_listcnt $ff \
                 "read alternately back and forth in sound"
            }
            120 {
                DisplayFoundItem "extend" "loop" $query_display_listcnt $ff \
                 "continually repeat segment of sndfile mechanically"
            }
            121 {
                DisplayFoundItem "extend" "scramble" $query_display_listcnt $ff \
                 "extend file by scrambling random chunks of it"
            }
            122 {
                DisplayFoundItem "extend" "iterate" $query_display_listcnt $ff \
                 "continually repeat segment of sndfile naturally"
            }
            123 {
                DisplayFoundItem "extend" "drunkwalk" $query_display_listcnt $ff \
                 "drunken walk through sound"
            }
            124 {
                DisplayFoundItem "texture" "simple" $query_display_listcnt $ff \
                 "texture of copies of input sound or of many sounds"
            }
            125 {
                DisplayFoundItem "texture" "of groups" $query_display_listcnt $ff \
                 "texture of copies of input-sounds-in-groups"
            }
            126 {
                DisplayFoundItem "texture" "decorated" $query_display_listcnt $ff \
                 "texture of decorations from copies of input-sounds"
            }
            127 {
                DisplayFoundItem "texture" "pre-decorations" $query_display_listcnt $ff \
                 "texture of pre-decorations from copies input-sounds"
            }
            128 {
                DisplayFoundItem "texture" "post-decorations" $query_display_listcnt $ff \
                 "texture of post-decorations from copies input-sounds"
            }
            129 {
                DisplayFoundItem "texture" "ornamented" $query_display_listcnt $ff \
                 "ornamented texture from copies of input-sounds"
            }
            130 {
                DisplayFoundItem "texture" "pre-ornate" $query_display_listcnt $ff \
                 "pre-ornamented texture from copies of input-sounds"
            }
            131 {
                DisplayFoundItem "texture" "post-ornate" $query_display_listcnt $ff \
                 "post-ornamented texture from copies of input-sounds"
            }
            132 {
                DisplayFoundItem "texture" "of motifs" $query_display_listcnt $ff \
                 "texture of motifs from copies of input-sounds"
            }
            133 {
                DisplayFoundItem "texture" "motifs in hf" $query_display_listcnt $ff \
                 "texture of motifs with harmonic forcing"
            }
            134 {
                DisplayFoundItem "texture" "timed" $query_display_listcnt $ff \
                 "pretimed texture of copies of input sounds"
            }
            135 {
                DisplayFoundItem "texture" "timed groups" $query_display_listcnt $ff \
                 "pretimed texture of copies of input-sounds-in-groups"
            }
            136 {
                DisplayFoundItem "texture" "timed motifs" $query_display_listcnt $ff \
                 "pretimed texture of motifs from copies of input-sounds"
            }
            137 {
                DisplayFoundItem "texture" "timed mtfs in hf" $query_display_listcnt $ff \
                 "pretimed texture of motifs with harmonic forcing"
            }
            138 {
                DisplayFoundItem "grain" "count" $query_display_listcnt $ff \
                 "count grains in input sound"
            }
            139 {
                DisplayFoundItem "grain" "omit" $query_display_listcnt $ff \
                 "omit specified grains from input sound"
            }
            140 {
                DisplayFoundItem "grain" "duplicate" $query_display_listcnt $ff \
                 "repeat grains in input sound"
            }
            141 {
                DisplayFoundItem "grain" "reorder" $query_display_listcnt $ff \
                 "change order of grains in input sound"
            }
            142 {
                DisplayFoundItem "grain" "repitch" $query_display_listcnt $ff \
                 "change pitch of grains in sound but not their time placement"
            }
            143 {
                DisplayFoundItem "grain" "rerhythm" $query_display_listcnt $ff \
                 "change rhythm of grains in input sound"
            }
            144 {
                DisplayFoundItem "grain" "remotif" $query_display_listcnt $ff \
                 "change rhythm and pitch of grains in sound independently of each other"
            }
            145 {
                DisplayFoundItem "grain" "timewarp" $query_display_listcnt $ff \
                 "timewarp input sound but not constituent grains"
            }
            146 {
                DisplayFoundItem "grain" "get" $query_display_listcnt $ff \
                 "locate grains in input sound"
            }
            147 {
                DisplayFoundItem "grain" "position" $query_display_listcnt $ff \
                 "reposition grains in input sound to specified times"
            }
            148 {
                DisplayFoundItem "grain" "align" $query_display_listcnt $ff \
                 "align grains in one input sound with those in another"
            }
            149 {
                DisplayFoundItem "grain" "reverse" $query_display_listcnt $ff \
                 "reverse order of grains but not grains themselves"
            }
            150 {
                DisplayFoundItem "envelope" "create" $query_display_listcnt $ff \
                 "create an envelope data file"
            }
            151 {
                DisplayFoundItem "envelope" "extract" $query_display_listcnt $ff \
                 "extract envelope from sound"
            }
            152 {
                DisplayFoundItem "envelope" "impose" $query_display_listcnt $ff \
                 "impose an envelope onto input sound"
            }
            153 {
                DisplayFoundItem "envelope" "replace" $query_display_listcnt $ff \
                 "replace envelope of input sound with a different envelope"
            }
            154 {
                DisplayFoundItem "envelope" "warping" $query_display_listcnt $ff \
                 "warp the envelope of a sound"
            }
            155 {
                DisplayFoundItem "envelope" "reshaping" $query_display_listcnt $ff \
                 "warp the envelope in a binary envelope file"
            }
            156 {
                DisplayFoundItem "envelope" "replotting" $query_display_listcnt $ff \
                 "warp the envelope in a breakkpoint envelope textfile"
            }
            157 {
                DisplayFoundItem "envelope" "dovetailing" $query_display_listcnt $ff \
                 "dovetail the ends of a sound using any specified slope"
            }
            158 {
                DisplayFoundItem "envelope" "curtailing" $query_display_listcnt $ff \
                 "curtail end of input sound with a fadeout to zero"
            }
            159 {
                DisplayFoundItem "envelope" "swell" $query_display_listcnt $ff \
                 "add loudness swell to a sound"
            }
            160 {
                DisplayFoundItem "envelope" "attack" $query_display_listcnt $ff \
                 "add attack moment to a sound"
            }
            161 {
                DisplayFoundItem "envelope" "pluck" $query_display_listcnt $ff \
                 "add plucked attack to a sound"
            }
            162 {
                DisplayFoundItem "envelope" "tremolo" $query_display_listcnt $ff \
                 "add tremolo to a sound"
            }
            163 {
                DisplayFoundItem "envelope" "bin to brk" $query_display_listcnt $ff \
                 "convert binary envelope data to breakpoint text data"
            }
            164 {
                DisplayFoundItem "envelope" "bin to db-brk" $query_display_listcnt $ff \
                 "convert binary envelope data to breakpoint text data in db"
            }
            165 {
                DisplayFoundItem "envelope" "brk to bin" $query_display_listcnt $ff \
                 "convert envelope breakpoint textdata to binary data"
            }
            166 {
                DisplayFoundItem "envelope" "db-brk to bin" $query_display_listcnt $ff \
                 "convert db envelope breakpoint textdata to binary data"
            }
            167 {
                DisplayFoundItem "envelope" "db-brk to brk" $query_display_listcnt $ff \
                 "convert db envelope textdata to normalised textdata"
            }
            168 {
                DisplayFoundItem "envelope" "brk to db-brk" $query_display_listcnt $ff \
                 "convert envelope textdata to db textdata"
            }
            169 {
                DisplayFoundItem "mix" "merge" $query_display_listcnt $ff \
                 "mix two sounds"
            }
            170 {
                DisplayFoundItem "mix" "crossfade" $query_display_listcnt $ff \
                 "crossfade between two sounds"
            }
            171 {
                DisplayFoundItem "mix" "interleave" $query_display_listcnt $ff \
                 "interleave mono files to make multichannel file"
            }
            172 {
                DisplayFoundItem "mix" "inbetweening" $query_display_listcnt $ff \
                 "make set of sounds intermediate between 2 given sounds"
            }
            173 {
                DisplayFoundItem "mix" "mix" $query_display_listcnt $ff \
                 "mix sounds specified in mixfile to create new sound"
            }
            174 {
                DisplayFoundItem "mix" "get level" $query_display_listcnt $ff \
                 "find level of a proposed mix specified in a mixfile"
            }
            175 {
                DisplayFoundItem "mix" "attenuate" $query_display_listcnt $ff \
                 "change level of a proposed mix specified in a mixfile"
            }
            176 {
                DisplayFoundItem "mix" "shuffle" $query_display_listcnt $ff \
                 "shuffle order of sounds in a mixfile"
            }
            177 {
                DisplayFoundItem "mix" "timewarp" $query_display_listcnt $ff \
                 "modify timings of sounds specified in a mixfile"
            }
            178 {
                DisplayFoundItem "mix" "spacewarp" $query_display_listcnt $ff \
                 "modify spatial positions of sounds listed in a mixfile"
            }
            179 {
                DisplayFoundItem "mix" "sync" $query_display_listcnt $ff \
                 "sync start or end of listed sounds to make a mixfile"
            }
            180 {
                DisplayFoundItem "mix" "sync attack" $query_display_listcnt $ff \
                 "sync attacks of listed sounds to make a mixfile"
            }
            181 {
                DisplayFoundItem "mix" "test" $query_display_listcnt $ff \
                 "check the syntax of a mixfile"
            }
            182 {
                DisplayFoundItem "mix" "format" $query_display_listcnt $ff \
                 "see the required format of mixfiles"
            }
            183 {
                DisplayFoundItem "mix" "create a mixfile" $query_display_listcnt $ff \
                 "create mixfile (to edit) with sounds superimposed or head-to-tail"
            }
            185 {
                DisplayFoundItem "filter" "fixed" $query_display_listcnt $ff \
                 "high low or band pass filter around a fixed frq"
            }
            186 {
                DisplayFoundItem "filter" "lopass-hipass" $query_display_listcnt $ff \
                 "low pass or high pass filter"
            }
            187 {
                DisplayFoundItem "filter" "variable" $query_display_listcnt $ff \
                 "high low or band pass or notch filter with variable frq"
            }
            188 {
                DisplayFoundItem "filter" "bank" $query_display_listcnt $ff \
                 "bank of filters of various designs with variable Q"
            }
            189 {
                DisplayFoundItem "filter" "bank frqs" $query_display_listcnt $ff \
                 "show frqs of cdp filter banks"
            }
            190 {
                DisplayFoundItem "filter" "userbank" $query_display_listcnt $ff \
                 "bank of filters with frqs specified by user and timevariable Q"
            }
            191 {
                DisplayFoundItem "filter" "varibank" $query_display_listcnt $ff \
                 "bank of filters with Q & user-specified-frqs both timevariable"
            }
            192 {
                DisplayFoundItem "filter" "sweeping" $query_display_listcnt $ff \
                 "filter with a sweeping frequency"
            }
            193 {
                DisplayFoundItem "filter" "iterated" $query_display_listcnt $ff \
                 "loop material cumulatively through a given filter"
            }
            194 {
                DisplayFoundItem "filter" "phasing" $query_display_listcnt $ff \
                 "phase-changing filter or phasing filter"
            }
            195 {
                DisplayFoundItem "loudness" "loudness" $query_display_listcnt $ff \
                 "change loudness or normalise or balance with another sound"
            }
            196 {
                DisplayFoundItem "space" "spatialisation" $query_display_listcnt $ff \
                 "move sound in space or alter spatial distribution"
            }
            197 {
                DisplayFoundItem "pitch:speed" "pitch" $query_display_listcnt $ff \
                 "vary speed & pitch of a sound or add vibrato"
            }
            198 {
                DisplayFoundItem "reverb:echo" "rev echo" $query_display_listcnt $ff \
                 "create reverb or echo or resonance around a sound"
            }
            199 {
                DisplayFoundItem "brassage" "brassage" $query_display_listcnt $ff \
                 "brassage for pitchshift timewarp reverb scramble granulate etc"
            }
            200 {
                DisplayFoundItem "brassage" "sausage" $query_display_listcnt $ff \
                 "multifile brassage"
            }
            201 {
                DisplayFoundItem "radical" "radical" $query_display_listcnt $ff \
                 "reverse or shred or ring-modulate or cross-modulate or scrub or lose-resolution"
            }
            202 {
                DisplayFoundItem "pvoc" "analysis" $query_display_listcnt $ff \
                 "analyse sound to produce spectral file"
            }
            203 {
                DisplayFoundItem "pvoc" "synthesis" $query_display_listcnt $ff \
                 "synthesize sound from spectral file"
            }
            204 {
                DisplayFoundItem "pvoc" "extract" $query_display_listcnt $ff \
                 "analyse then resynthesize sound with various options"
            }
            206 {
                DisplayFoundItem "edit" "cutout & keep" $query_display_listcnt $ff \
                 "cut and keep time-segment from a sound"
            }
            207 {
                DisplayFoundItem "edit" "cutend & keep" $query_display_listcnt $ff \
                 "cut and keep time-segment from the end of a sound"
            }
            208 {
                DisplayFoundItem "edit" "cutout at zero-crossings" $query_display_listcnt $ff \
                 "cut and keep time-segment of sound but edit at zero-crossings only"
            }
            209 {
                DisplayFoundItem "edit" "remove segment" $query_display_listcnt $ff \
                 "delete a time-segment from a sound"
            }
            210 {
                DisplayFoundItem "edit" "remove many segments" $query_display_listcnt $ff \
                 "delete several time-segments from a sound"
            }
            211 {
                DisplayFoundItem "edit" "insert sound" $query_display_listcnt $ff \
                 "insert one sound into another"
            }
            212 {
                DisplayFoundItem "edit" "insert silence" $query_display_listcnt $ff \
                 "insert silence into a sound"
            }
            213 {
                DisplayFoundItem "edit" "join" $query_display_listcnt $ff \
                 "join sounds together end to end"
            }
            214 {
                DisplayFoundItem "housekeep" "multiples" $query_display_listcnt $ff \
                 "make one or several copies of a file"
            }
            215 {
                DisplayFoundItem "housekeep" "extract or convert channels" $query_display_listcnt $ff \
                 "extract 1 or more channels of sound or zero a channel or convert between mono and stereo"
            }
            216 {
                DisplayFoundItem "housekeep" "select & clean" $query_display_listcnt $ff \
                 "extract significant events from soundfile or top-and-tail sound or remove dc"
            }
            217 {
                DisplayFoundItem "housekeep" "change specification" $query_display_listcnt $ff \
                 "convert samplerate or convert between int & float samples or change properties"
            }
            218 {
                DisplayFoundItem "housekeep" "bundle" $query_display_listcnt $ff \
                 "bundle names of infiles into lists of files-of-same-type"
            }
            219 {
                DisplayFoundItem "housekeep" "sort files" $query_display_listcnt $ff \
                 "sort lists of filenames by file properties"
            }
            220 {
                DisplayFoundItem "housekeep" "backup as soundfile" $query_display_listcnt $ff \
                 "copy all files into a single soundfile, for storage"
            }
            222 {
                DisplayFoundItem "housekeep" "diskspace" $query_display_listcnt $ff \
                 "report remaining memory space on hard disk"
            }
            223 {
                DisplayFoundItem "sound info" "properties" $query_display_listcnt $ff \
                 "display properties of sndfiling-system file"
            }
            224 {
                DisplayFoundItem "sound info" "duration" $query_display_listcnt $ff \
                 "display duration of sndfiling-system file"
            }
            225 {
                DisplayFoundItem "sound info" "list sound durations" $query_display_listcnt $ff \
                 "display durations of list of sndfiling-system file"
            }
            226 {
                DisplayFoundItem "sound info" "sum durations" $query_display_listcnt $ff \
                 "sum durations of list of sndfiling-system file"
            }
            227 {
                DisplayFoundItem "sound info" "subtract durations" $query_display_listcnt $ff \
                 "find difference in duration of two sounds"
            }
            228 {
                DisplayFoundItem "sound info" "time as sample count" $query_display_listcnt $ff \
                 "convert sample count to time in sound"
            }
            229 {
                DisplayFoundItem "sound info" "sample count as time" $query_display_listcnt $ff \
                 "convert time to sample count in sound"
            }
            230 {
                DisplayFoundItem "sound info" "maximum sample" $query_display_listcnt $ff \
                 "find maximum sample in sndfiling-system file"
            }
            231 {
                DisplayFoundItem "sound info" "loudest channel" $query_display_listcnt $ff \
                 "find loudest channel in a stereo sndfile"
            }
            232 {
                DisplayFoundItem "sound info" "largest hole" $query_display_listcnt $ff \
                 "find longest low-level hole in a sound"
            }
            233 {
                DisplayFoundItem "sound info" "compare files" $query_display_listcnt $ff \
                 "compare 2 soundfiling system files"
            }
            234 {
                DisplayFoundItem "sound info" "compare channels" $query_display_listcnt $ff \
                 "compare channels in a stereo sound"
            }
            235 {
                DisplayFoundItem "sound info" "print sound data" $query_display_listcnt $ff \
                 "print data in a sound to a textfile"
            }
            237 {
                DisplayFoundItem "synthesis" "waveforms" $query_display_listcnt $ff \
                 "synthesize various waveforms"
            }
            238 {
                DisplayFoundItem "synthesis" "noise" $query_display_listcnt $ff \
                 "synthesize noise"
            }
            239 {
                DisplayFoundItem "synthesis" "silence" $query_display_listcnt $ff \
                 "create a file of silence"
            }
            240 {
                DisplayFoundItem "utilities" "extract column" $query_display_listcnt $ff \
                 "extract specified column of values from array of columns"
            }
            241 {
                DisplayFoundItem "utilities" "insert column" $query_display_listcnt $ff \
                 "place a column of values amongst an array of columns"
            }
            242 {
                DisplayFoundItem "utilities" "join columns" $query_display_listcnt $ff \
                 "create array of columns from individual columns of values"
            }
            243 {
                DisplayFoundItem "utilities" "column maths" $query_display_listcnt $ff \
                 "perform mathematical operations on a column of values"
            }
            244 {
                DisplayFoundItem "utilities" "column music" $query_display_listcnt $ff \
                 "perform musical operations on a column of values"
            }
            245 {
                DisplayFoundItem "utilities" "column rand" $query_display_listcnt $ff \
                 "perform randomising operations on column of values"
            }
            246 {
                DisplayFoundItem "utilities" "column sort" $query_display_listcnt $ff \
                 "sort edit delete-duplicates etc in column of values"
            }
            247 {
                DisplayFoundItem "utilities" "column create" $query_display_listcnt $ff \
                 "generate columns of values."
            }
            248 {
                DisplayFoundItem "focus" "hold" $query_display_listcnt $ff \
                 "sample-hold spectrum"
            }
            249 {
                DisplayFoundItem "housekeep" "remove copies" $query_display_listcnt $ff \
                 "remove duplicates of a file"
            }
            250 {
                DisplayFoundItem "utilities" "vectors" $query_display_listcnt $ff \
                 "operations between paired members of 2 columns of values"
            }
            251 {
                DisplayFoundItem "edit" "silence masks" $query_display_listcnt $ff \
                 "insert several silences in file"
            }
            252 {
                DisplayFoundItem "edit" "random slicing" $query_display_listcnt $ff \
                 "cut file at random points"
            }
            253 {
                DisplayFoundItem "edit" "random chunks" $query_display_listcnt $ff \
                 "cut chunks from file at random"
            }
            254 {
                DisplayFoundItem "space" "sinus panning" $query_display_listcnt $ff \
                 "create sinusoidal pan-control textfile"
            }
            255 {
                DisplayFoundItem "extend" "repetitions" $query_display_listcnt $ff \
                 "create timed-pattern of repetitions"
            }
            256 {
                if {[info exists released(newmix)]} {
                    DisplayFoundItem "mix" "multichannel mix" $query_display_listcnt $ff \
                     "mix files with up to 16 channels"
                }
            }
            257 {
                if {[info exists released(analjoin)]} {
                    DisplayFoundItem "simple" "join analfiles" $query_display_listcnt $ff \
                     "splice analysis files together"
                }
            }
            258 {
                if {[info exists released(ptobrk)]} {
                    DisplayFoundItem "repitch" "binary to text: keep zeros" $query_display_listcnt $ff \
                     "convert binary pitchdata to text, keeping 'no-pitch' information"
                }
            }
            259 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "stretch using pitchsync grains" $query_display_listcnt $ff \
                     "Time-stretch using grains syncd to pitch of source"
                }
            }
            260 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "duplicate pitchsync grains" $query_display_listcnt $ff \
                     "duplicate pitch-syncd grains in input sound"
                }
            }
            261 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "delete pitchsync grains" $query_display_listcnt $ff \
                     "delete 1-in-N pitch-syncd grains of input sound"
                }
            }
            262 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "stretch+transpose with pitchsync grains" $query_display_listcnt $ff \
                     "Time-stretch and transpose using grains syncd to pitch"
                }
            }
            263 {
                if {[info exists released(oneform)]} {
                    DisplayFoundItem "formants" "extract one" $query_display_listcnt $ff \
                     "extract single formant at specified time"
                }
            }
            264 {
                if {[info exists released(oneform)]} {
                    DisplayFoundItem "formants" "impose one" $query_display_listcnt $ff \
                     "impose one formant on spectrum"
                }
            }
            265 {
                if {[info exists released(oneform)]} {
                    DisplayFoundItem "combine spectra" "add pitch to one formant" $query_display_listcnt $ff \
                     "make new spectrum by adding pitchline in pitchfile to single formant"
                }
            }
            266 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "grab & use pitch-sync grain(s)" $query_display_listcnt $ff \
                     "Grab a pitch-sync grain from a sound: use to construct new sound"
                }
            }
            267 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "chop sound between pich-sync grains" $query_display_listcnt $ff \
                     "Chop sound into segments separated by spcified pitch-sync grains"
                }
            }
            268 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "interp between pich-sync grains" $query_display_listcnt $ff \
                     "Interpolate between pitch-synchronous grains"
                }
            }
            269 {
                if {[info exists released(gate)]} {
                    DisplayFoundItem "house" "gate low level signal" $query_display_listcnt $ff \
                     "Set to zero parts of signal below specified level"
                }
            }
            270 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "add new features" $query_display_listcnt $ff \
                     "Add new features to sound with pitch-sync grains"
                }
            }
            271 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "synthesize sound with FOF contour" $query_display_listcnt $ff \
                     "Create synthesized sound beneath FOFs of input sound"
                }
            }
            272 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "superimpose FOFs" $query_display_listcnt $ff \
                     "Add FOFs of first sound to a 2nd sound"
                }
            }
            273 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "add subharmonics and transpositions" $query_display_listcnt $ff \
                     "add subharmonics and transpositions to FOF-based sound"
                }
            }
            274 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "spatailise FOFs" $query_display_listcnt $ff \
                     "spatailise FOFs in a sound"
                }
            }
            275 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "interweave FOFs" $query_display_listcnt $ff \
                     "interweave FOFs in 2 sounds"
                }
            }
            276 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "replace FOFs" $query_display_listcnt $ff \
                     "Replace FOFs of 2nd sound by those of 1st"
                }
            }
            277 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "sustain FOF" $query_display_listcnt $ff \
                     "Sustain FOF within existing sound"
                }
            }
            278 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "Find FOF number" $query_display_listcnt $ff \
                     "Get FOF number at specified time, or vice versa"
                }
            }
            279 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "Cut at FOF" $query_display_listcnt $ff \
                     "Cut sound before or after specified FOF number"
                }
            }
            280 {
                if {[info exists released(specnu)]} {
                    DisplayFoundItem "simple" "remove pitch component" $query_display_listcnt $ff \
                     "Remove pitch component (or all else) from a spectrum"
                }
            }
            281 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "sustain FOF" $query_display_listcnt $ff \
                     "Sustain explicit FOF within existing sound"
                }
            }
            282 {
                if {[info exists released(prefix)]} {
                    DisplayFoundItem "edit" "insert silence" $query_display_listcnt $ff \
                     "insert silence into a sound"
                }
            }
            283 {
                if {[info exists released(strans)]} {
                    DisplayFoundItem "multichan" "transpose: change speed" $query_display_listcnt $ff \
                     "vary speed+pitch, or accelerate or vibrato a multichannel sound"
                }
            }
            284 {
                if {[info exists released(psow)]} {
                    DisplayFoundItem "psow" "reinforce harmonics" $query_display_listcnt $ff \
                     "reinforce harmonics in a FOF-based sound"
                }
            }
            285 {
                if {[info exists released(get_partials)]} {
                    DisplayFoundItem "spectrum info" "extract partials contour" $query_display_listcnt $ff \
                     "extract relative amplitudes of partials in pitched source"
                }
            }
            286 {
                if {[info exists released(specross)]} {
                    DisplayFoundItem "specross" "interpolate harmonics" $query_display_listcnt $ff \
                     "with 2 pitched sounds, interpolate towards harmonics of 1st"
                }
            }
            287 {
                if {[info exists released(mchiter)]} {
                    DisplayFoundItem "multichan" "multithchan iterate" $query_display_listcnt $ff \
                     "repeat sndfile naturally + distribute in space"
                }
            }
            289 {
                DisplayFoundItem "harmonic fld" "chords from note field" $query_display_listcnt $ff \
                 "derive all harmonic fields from note field"
            }
            290 {
                DisplayFoundItem "harmonic fld" "chords from note set" $query_display_listcnt $ff \
                 "derive all harmonic fields from note set"
            }
            291 {
                DisplayFoundItem "harmonic fld" "chords from delay and shift" $query_display_listcnt $ff \
                 "generate note cpts using delays and pitch shift"
            }
            292 {
                DisplayFoundItem "harmonic fld" "patterns from delay and shift" $query_display_listcnt $ff \
                 "generate note cpts using delays & pitch shift on input sound"
            }
            293 {
                DisplayFoundItem "synthesis" "spectral bands" $query_display_listcnt $ff \
                 "generate spectra for stereo chans of spectral band"
            }
            294 {
                DisplayFoundItem "distort" "clip" $query_display_listcnt $ff \
                 "distort by clipping signal with noise or oscillator"
            }
            295 {
                DisplayFoundItem "edit" "switchfiles" $query_display_listcnt $ff \
                 "switch between files, at given times, as they (all) play"
            }
            296 {
                DisplayFoundItem "edit" "sphinx" $query_display_listcnt $ff \
                 "switch between files, at given (different) times, as they (all) play"
            }
            297 {
                DisplayFoundItem "sound info" "list levels" $query_display_listcnt $ff \
                 "list levels of  soundfiles"
            }
            298 {
                DisplayFoundItem "repitch" "spectrum over pitch" $query_display_listcnt $ff \
                 "generate spectrum over given binary pitchdata, with specified harmonics"
            }
            299 {
                DisplayFoundItem "repitch" "insert unpitched windows" $query_display_listcnt $ff \
                 "Convert binary pitchdata to unpitched, between specified time-pairs"
            }
            300 {
                DisplayFoundItem "repitch" "convert pitch to silence" $query_display_listcnt $ff \
                 "Silence all pitched windows in binary pitchdata"
            }
            301 {
                DisplayFoundItem "repitch" "convert unpitched to silence" $query_display_listcnt $ff \
                 "Silence all unpitched windows in binary pitchdata"
            }
            302 {
                DisplayFoundItem "repitch" "insert silent windows" $query_display_listcnt $ff \
                 "Convert binary pitchdata to silence, between specified time-pairs"
            }
            303 {
                DisplayFoundItem "envelope" "loudness envelope from analfile" $query_display_listcnt $ff \
                 "Extract the loudness of each window, from an analysis file"
            }
            304 {
                DisplayFoundItem "combine spectra" "pitch+formants+envelope" $query_display_listcnt $ff \
                 "Generate spectrum from pitch, formants and envelope data"
            }
            305 {
                DisplayFoundItem "repitch" "vowels over pitch" $query_display_listcnt $ff \
                 "generate (possibly moving) vowels over given binary pitchdata"
            }
            307 {
                DisplayFoundItem "housekeep" "chop at zeros" $query_display_listcnt $ff \
                 "Cut sound into segments at points where level is zero"
            }
            308 {
                DisplayFoundItem "mix" "create mixfile on timegrid" $query_display_listcnt $ff \
                 "convert list of sounds to basic mixfile on given time grid"
            }
            309 {
                DisplayFoundItem "repitch" "synthesize pitchdata from note names" $query_display_listcnt $ff \
                 "convert time-notename pairs to binary pitch data"
            }
            310 {
                DisplayFoundItem "repitch" "interpolate pitch thro' noise or silence" $query_display_listcnt $ff \
                 "eliminate noise or silence, by interpolating between existing pitches"
            }
            311 {
                DisplayFoundItem "mix" "balance many" $query_display_listcnt $ff \
                 "mix several sounds using a balance function"
            }
            312 {
                DisplayFoundItem "edit" "cutout & keep many" $query_display_listcnt $ff \
                 "cut and keep several time-segments from a sound"
            }
            313 {
                DisplayFoundItem "radical" "stack" $query_display_listcnt $ff \
                 "stack transposed copies of sound on top of one another"
            }
            314 {
                DisplayFoundItem "hilite" "vowels" $query_display_listcnt $ff \
                 "impose (changing?) vowel spectrum on sound"
            }
            315 {
                DisplayFoundItem "envelope" "proportional" $query_display_listcnt $ff \
                 "scale envelope to sound duration, and impose on sound"
            }
            316 {
                DisplayFoundItem "space" "proportional" $query_display_listcnt $ff \
                 "move sound in space, scaling movement data to sound duration"
            }
            317 {
                DisplayFoundItem "mix" "merge many" $query_display_listcnt $ff \
                 "mix several sounds"
            }
            318 {
                DisplayFoundItem "distort" "impose pulsetrain" $query_display_listcnt $ff \
                 "impose pulsetrain on src , or use src segment for pulse synthesis"
            }
            319 {
                DisplayFoundItem "edit" "suppress noise" $query_display_listcnt $ff \
                 "replace noise in signal by silence"
            }
            320 {
                DisplayFoundItem "envelope" "time grids" $query_display_listcnt $ff \
                 "partition file onto time grids"
            }           
            321 {
                DisplayFoundItem "rhythm" "sequencer" $query_display_listcnt $ff \
                 "create sequence of events from src"
            }
            322 {
                DisplayFoundItem "reverb:echo" "convolve" $query_display_listcnt $ff \
                 "Convolve first file with second"
            }
            323 {
                DisplayFoundItem "extend" "back to back" $query_display_listcnt $ff \
                 "Time-Reversed copy of sound spliced before sound itself"
            }
            324 {
                DisplayFoundItem "mix" "add to mix" $query_display_listcnt $ff \
                 "Add sounds (at max level and time zero) to existing mixfile"
            }
            325 {
                DisplayFoundItem "edit" "replace part of sound" $query_display_listcnt $ff \
                 "insert one sound into another, replacing specified part"
            }
            326 {
                DisplayFoundItem "mix" "pan sound positions" $query_display_listcnt $ff \
                 "using pan position data, position sound entries in mixfile"
            }
            327 {
                DisplayFoundItem "radical" "shudder" $query_display_listcnt $ff \
                 "Stereo-randomised random tremolo"
            }
            328 {
                DisplayFoundItem "mix" "create mixfile with timstep" $query_display_listcnt $ff \
                 "convert list of sounds to basic mixfile with given timestep between entries"
            }
            329 {
                DisplayFoundItem "space" "find pan position" $query_display_listcnt $ff \
                 "Find stereo location of previously panned sound"
            }
            330 {
                DisplayFoundItem "synth" "generate clicktrack" $query_display_listcnt $ff \
                 "Generate clicktrack from music information in textfile"
            }
            331 {
                DisplayFoundItem "extend" "make doublets" $query_display_listcnt $ff \
                 "segment the sound, repeating each segment"
            }
            332 {
                DisplayFoundItem "edit" "separate syllables" $query_display_listcnt $ff \
                 "cut and keep conjunct syllables from speech"
            }
            333 {
                DisplayFoundItem "edit" "join in pattern" $query_display_listcnt $ff \
                 "join given sounds in given pattern (repets possible)"
            }
            334 {
                DisplayFoundItem "filter" "make pitched filters" $query_display_listcnt $ff \
                 "convert list of midipitches to fixed-pitch vfilter datafiles"
            }
            335 {
                DisplayFoundItem "housekeep" "expand batchfile" $query_display_listcnt $ff \
                 "convert batchfile to work with more soundfiles"
            }
            336 {
                DisplayFoundItem "mix" "replace soundfiles" $query_display_listcnt $ff \
                 "replace soundfiles in mixfile with new soundfiles"
            }
            337 {
                DisplayFoundItem "mix" "inbetweening zerosyncd" $query_display_listcnt $ff \
                 "create intermediate files: pegged to zero-crossings"
            }
            338 {
                DisplayFoundItem "edit" "join in pattern of loudness" $query_display_listcnt $ff \
                 "join sounds in given pattern (repets possible), with given loudnesses"
            }
            339 {
                DisplayFoundItem "extend" "freeze by iteration" $query_display_listcnt $ff \
                 "extend specified portion sound by 'natural' iteration"
            }
            340 {
                DisplayFoundItem "distort" "repeat cycles below max frq" $query_display_listcnt $ff \
                 "distort by repeating wavesets below max frq"
            }
            341 {
                DisplayFoundItem "housekeep" "remove edge clicks" $query_display_listcnt $ff \
                 "remove click(s) from start or end of sound"
            }
            342 {
                DisplayFoundItem "repitch" "convert binary pitchdata to text" $query_display_listcnt $ff \
                 "convert binary pitchdata to text data"
            }
            343 {
                DisplayFoundItem "envel" "create sequence of repeating envelopes" $query_display_listcnt $ff \
                 "generate envelope file containing repeating cells"
            }
            344 {
                DisplayFoundItem "rhythm" "multisound sequencer" $query_display_listcnt $ff \
                 "create sequence of events from several src sounds"
            }
            345 {
                DisplayFoundItem "grain" "extend iterative sound" $query_display_listcnt $ff \
                 "Extend an iterative sound (e.g. rolled 'rrr') naturalistically."
            }
            346 {
                DisplayFoundItem "house" "remove glitches" $query_display_listcnt $ff \
                 "remove very short glitches from a sound."
            }
            347 {
                DisplayFoundItem "grain" "assess max. no of grains" $query_display_listcnt $ff \
                 "Assess max no. of grains in source, and find best gate value."
            }
            348 {
                DisplayFoundItem "filter" "varipartials" $query_display_listcnt $ff \
                 "filterbank with Q, user-specd frqs & partials, all timevariable"
            }
            349 {
                DisplayFoundItem "distort" "repeat and skip" $query_display_listcnt $ff \
                 "distort by repeating wavesets: then skip to avoid timestretching"
            }
            350 {
                DisplayFoundItem "sndinfo" "proportion of zero crossings" $query_display_listcnt $ff \
                 "Find proportion of zero crossings between specified times in sndfile"
            }
            351 {
                DisplayFoundItem "grain" "extend noise in source" $query_display_listcnt $ff \
                 "Extend 1st noise component of a source sound."
            }
            352 {
                DisplayFoundItem "grain" "find grains using trough zeros" $query_display_listcnt $ff \
                 "Get, reverse, repeat, delete, omit, or reposition grains separated by troughs"
            }
            353 {
                DisplayFoundItem "reverb:echo" "multiple delays + positioning" $query_display_listcnt $ff \
                 "Generate timed delays (at specific stereo locations)"
            }
            354 {
                DisplayFoundItem "reverb:echo" "get room characteristics" $query_display_listcnt $ff \
                 "Generate data file for reverb processes"
            }
            355 {
                DisplayFoundItem "reverb:echo" "reverb with room characteristics" $query_display_listcnt $ff \
                 "Generate reverb by specifying room characteristics"
            }
            356 {
                if {[info exists released(lucier)]} {
                    DisplayFoundItem "filter" "extract room resonance to filter data" $query_display_listcnt $ff \
                     "Generate room resonance data from long recording"
                }
            }
            357 {
                if {[info exists released(lucier)]} {
                    DisplayFoundItem "filter" "extract room resonance to analfile" $query_display_listcnt $ff \
                     "Generate room resonance data from long recording"
                }
            }
            358 {
                if {[info exists released(lucier)]} {
                    DisplayFoundItem "filter" "add room resonance to source" $query_display_listcnt $ff \
                     "Add room resonance data to source"
                }
            }
            359 {
                if {[info exists released(lucier)]} {
                    DisplayFoundItem "filter" "subtract room resonance from source" $query_display_listcnt $ff \
                     "Subtract room resonance from source"
                }
            }
            360 {
                if {[info exists released(specnu)]} {
                    DisplayFoundItem "simple" "clean better" $query_display_listcnt $ff \
                     "Clean persisting noise from source sound"
                }
            }
            361 {
                if {[info exists released(specnu)]} {
                    DisplayFoundItem "simple" "clean by subtraction" $query_display_listcnt $ff \
                     "Subtract persisting noise from source sound"
                }
            }
            362 {
                if {[info exists released(phase)]} {
                    DisplayFoundItem "channels" "phase" $query_display_listcnt $ff \
                     "Invert phase or Enhance stereo"
                }
            }
            364 {
                if {[info exists released(brktopi)]} {
                    DisplayFoundItem "repitch" "convert text pitchdata to binary" $query_display_listcnt $ff \
                     "convert text pitchdata to binary data"
                }
            }
            365 {
                if {[info exists released(specnu)]} {
                    DisplayFoundItem "hilite" "salami slice" $query_display_listcnt $ff \
                     "Salami slice or pivot the spectrum"
                }
            }
            366 {
                if {[info exists released(fofex)]} {
                    DisplayFoundItem "psow" "FOF extract" $query_display_listcnt $ff \
                     "Extract FOFs for reconstruction"
                }
            }
            367 {
                if {[info exists released(fofex)]} {
                    DisplayFoundItem "psow" "FOF reconstruction" $query_display_listcnt $ff \
                     "Create new sound from extracted FOFs"
                }
            }
            368 {
                if {[info exists released(grainex)]} {
                    DisplayFoundItem "grain" "extend grainy part of sound" $query_display_listcnt $ff \
                     "Locate and plausibly extend grainy part of sound"
                }
            }
            369 {
                if {[info exists released(peakfind)]} {
                    DisplayFoundItem "envelope" "list times of sound peaks" $query_display_listcnt $ff \
                     "list times of peaks in sound"
                }
            }
            370 {
                if {[info exists released(constrict)]} {
                    DisplayFoundItem "edit" "shorten zerolevel segments" $query_display_listcnt $ff \
                     "Reduce length of any zerolevel segements in sound"
                }
            }
            371 {
                if {[info exists released(envnu)]} {
                    DisplayFoundItem "envelope" "true exponential" $query_display_listcnt $ff \
                     "curtail end of input sound with true exponential fadeout to zero"
                }
            }
            372 {
                if {[info exists released(envnu)]} {
                    DisplayFoundItem "rhythm" "peaks at tempo" $query_display_listcnt $ff \
                     "isolate peaks of signal and play them at specified tempo"
                }
            }
            373 {
                if {[info exists released(mchanpan)]} {
                    DisplayFoundItem "multichan" "multichannel pan" $query_display_listcnt $ff \
                     "Pan, switch or spread sound around more than 2 loudspeakers"
                }
            }
            374 {
                if {[info exists released(texmchan)]} {
                    DisplayFoundItem "texture" "multichannel texture" $query_display_listcnt $ff \
                     "multichannel texture of copies of input sound or of many sounds"
                }
            }
            375 {
                if {[info exists released(manysil)]} {
                    DisplayFoundItem "edit" "insert silences" $query_display_listcnt $ff \
                     "insert several silence into a sound"
                }
            }
            376 {
                if {[info exists released(retime)]} {
                    DisplayFoundItem "rhythm" "retime events" $query_display_listcnt $ff \
                     "sync peaks with MM, or shorten, move, repeat, reposition, mask"
                }
            }
            378 {
                if {[info exists released(hover)]} {
                    DisplayFoundItem "extend" "hover" $query_display_listcnt $ff \
                     "move around file, zigzag-reading it"
                }
            }
            379 {
                if {[info exists released(multimix)]} {
                    DisplayFoundItem "multichan" "create multichannel mixfile" $query_display_listcnt $ff \
                     "Generate multichan mixfile from list of soundfiles"
                }
            }
            380 {
                if {[info exists released(frame)]} {
                    DisplayFoundItem "multichan" "frame rotation" $query_display_listcnt $ff \
                     "Rotate, reorient, mirror frame; swap, edit chans of multichan file"
                }
            }
            381 {
                if {[info exists released(search)]} {
                    DisplayFoundItem "search" "start of signal(s)" $query_display_listcnt $ff \
                     "Find time of signal(s) after initial silence(s) in file(s)"
                }
            }
            382 {
                if {[info exists released(mchanrev)]} {
                    DisplayFoundItem "multichan" "multichan revecho" $query_display_listcnt $ff \
                     "create multichannel reverb, echo or resonance around a sound"
                }
            }
            383 {
                if {[info exists released(wrappage)]} {
                    DisplayFoundItem "multichan" "wrappage" $query_display_listcnt $ff \
                     "multifile brassage moving over multichan panorama"
                }
            }
            391 {
                if {[info exists released(specsphinx)]} {
                    DisplayFoundItem "combine spectra" "spec sphinx" $query_display_listcnt $ff \
                     "Impose 2nds amps on 1sts freqs: or multiply spectra: or carve 1st with 2nd"
                }
            }
            392 {
                if {[info exists released(superaccu)]} {
                    DisplayFoundItem "focus" "super accumulate" $query_display_listcnt $ff \
                     "sustain louder partials in spectrum, (possibly glis or tune them)"
                }
            }
            393 {
                if {[info exists released(partition)]} {
                    DisplayFoundItem "edit" "partition to grids" $query_display_listcnt $ff \
                     "partition mono file to grids of disjunct events"
                }
            }
            394 {
                if {[info exists released(specgrid)]} {
                    DisplayFoundItem "strange" "partition spectrum to grids" $query_display_listcnt $ff \
                     "partition channels of spectrum to different output files"
                }
            }
            395 {
                if {[info exists released(glisten)]} {
                    DisplayFoundItem "blur" "glisten spectrum" $query_display_listcnt $ff \
                     "randomly partition spectrum to grids and playback in order"
                }
            }
            396 {
                if {[info exists released(tunevary)]} {
                    DisplayFoundItem "pitch & harmony" "varitune spectrum" $query_display_listcnt $ff \
                     "tune the partials in a spectrum: tuning may move"
                }
            }
            397 {
                if {[info exists released(isolate)]} {
                    DisplayFoundItem "edit" "isolate segments in place" $query_display_listcnt $ff \
                     "cut segments with silent surrounds, retaining original timings"
                }
            }
            398 {
                if {[info exists released(rejoin)]} {
                    DisplayFoundItem "edit" "rejoin isolated segments" $query_display_listcnt $ff \
                     "rejoin segments previously isolated with \"isolate\" process"
                }
            }
            399 {
                if {[info exists released(panorama)]} {
                    DisplayFoundItem "edit" "create panorama" $query_display_listcnt $ff \
                     "place mono sounds across multichannel panorama"
                }
            }
            400 {
                if {[info exists released(tremolo)]} {
                    DisplayFoundItem "envelope" "squeezed tremolo" $query_display_listcnt $ff \
                     "add (possibly squeezed) tremolo to a sound"
                }
            }
            401 {
                if {[info exists released(sfecho)]} {
                    DisplayFoundItem "revecho" "create echos" $query_display_listcnt $ff \
                     "create echoes of a sound"
                }
            }
            402 {
                if {[info exists released(packet)]} {
                    DisplayFoundItem "edit" "create sound packet" $query_display_listcnt $ff \
                     "create enveloped sound packet(s) from source"
                }
            }

            403 {
                if {[info exists released(newsynth)]} {
                    DisplayFoundItem "synthesis" "create complex waveforms" $query_display_listcnt $ff \
                     "create complex tones, wave-packet-streams, glistenings or spikes"
                }
            }
            404 {
                if {[info exists released(tangent)]} {
                    DisplayFoundItem "space" "move sound at tangent to 8-circle" $query_display_listcnt $ff \
                     "Create motion on tangent to circle of 8 lspkrs"
                }
            }
            405 {
                if {[info exists released(tangent)]} {
                    DisplayFoundItem "space" "move changing snd at tangent to 8-circle" $query_display_listcnt $ff \
                     "Create motion with sound-change on tangent to circle of 8 lspkrs"
                }
            }
            406 {
                if {[info exists released(tangent)]} {
                    DisplayFoundItem "space" "move sequence at tangent to 8-circle" $query_display_listcnt $ff \
                     "Create motion of snd-sequence on tangent to circle of 8 lspkrs"
                }
            }
            407 {
                if {[info exists released(tangent)]} {
                    DisplayFoundItem "space" "move sequence at tangent to 8-circle" $query_display_listcnt $ff \
                     "Create motion of listed snd-sequence on tangent to circle of 8 lspkrs"
                }
            }
            408 {
                if {[info exists released(spectwin)]} {
                    DisplayFoundItem "combine spectra" "interbreed two spectra" $query_display_listcnt $ff \
                     "Create combination of spectra by interpolating envelopes and frq"
                }
            }
            409 {
                if {[info exists released(transit)]} {
                    DisplayFoundItem "space" "sound crossing 8-channel ring" $query_display_listcnt $ff \
                     "Create motion of sound on tangent to+from circle of 8 lspkrs"
                }
            }
            410 {
                if {[info exists released(transit)]} {
                    DisplayFoundItem "space" "sound-pair crossing 8-channel ring" $query_display_listcnt $ff \
                     "Create motion of snd-pair on tangent to+from circle of 8 lspkrs"
                }
            }
            411 {
                if {[info exists released(transit)]} {
                    DisplayFoundItem "space" "sound crossing 8-channel ring with doppler" $query_display_listcnt $ff \
                     "Create doppler-shifted motion of snd on tangent to+from circle of 8 lspkrs"
                }
            }
            412 {
                if {[info exists released(transit)]} {
                    DisplayFoundItem "space" "sound-pair crossing 8-chan ring + doppler" $query_display_listcnt $ff \
                     "Create motion+doppler of snd-pair on tangent to+from circle of 8 lspkrs"
                }
            }
            413 {
                if {[info exists released(transit)]} {
                    DisplayFoundItem "space" "sound sequence crossing 8-chan ring" $query_display_listcnt $ff \
                     "Create motion of sequence of snds on tangent to+from circle of 8 lspkrs"
                }
            }
            414 {
                if {[info exists released(transit)]} {
                    DisplayFoundItem "space" "sound sequence crossing 8-chan ring" $query_display_listcnt $ff \
                     "Create motion of listed snds on tangent to+from circle of 8 lspkrs"
                }
            }
            415 {
                if {[info exists released(cantor)]} {
                    DisplayFoundItem "radical" "insert more and more holes in source" $query_display_listcnt $ff \
                     "create sequence of sounds with more and more holes (cantor set)"
                }
            }
            416 {
                if {[info exists released(shrink)]} {
                    DisplayFoundItem "radical" "repeat + shrink, or get peaks + shrink" $query_display_listcnt $ff \
                     "repeat sound, or cut snd into segments, shrinking successive events"
                }
            }
            417 {
                if {[info exists released(newtex)]} {
                    DisplayFoundItem "texture" "granulate and spatialise" $query_display_listcnt $ff \
                     "granulate sound and distribute spatially"
                }
            }
            418 {
                if {[info exists released(ceracu)]} {
                    DisplayFoundItem "rhythm" "cyclic polyrhythm" $query_display_listcnt $ff \
                     "regularly repeat sound differently in several different streams"
                }
            }
            419 {
                if {[info exists released(madrid)]} {
                    DisplayFoundItem "rhythm" "spatialised accents" $query_display_listcnt $ff \
                     "regularly repeat sound with accents and spatial dislocations"
                }
            }
            420 {
                if {[info exists released(shifter)]} {
                    DisplayFoundItem "rhythm" "focus-shifting cycles" $query_display_listcnt $ff \
                     "cycles of repetition take focus at different times"
                }
            }
            421 {
                if {[info exists released(fracture)]} {
                    DisplayFoundItem "radical" "fracture spatially" $query_display_listcnt $ff \
                     "fracture mono source into spatialised fragments"
                }
            }
            422 {
                if {[info exists released(subtract)]} {
                    DisplayFoundItem "housekeep" "subtract 1 file from another" $query_display_listcnt $ff \
                     "subtract mono file from (a channnel of) another file"
                }
            }
            423 {
                if {[info exists released(spectrum)]} {
                    DisplayFoundItem "synth" "spectrum from spectra lines" $query_display_listcnt $ff \
                     "Create spectrum from spectral lines textfile"
                }
            }
            424 {
                if {[info exists released(newmorph)]} {
                    DisplayFoundItem "morph" "new morph" $query_display_listcnt $ff \
                     "morph between peaks of different spectra"
                }
            }
            425 {
                if {[info exists released(newmorph)]} {
                    DisplayFoundItem "morph" "peak morph" $query_display_listcnt $ff \
                     "find or morph peaks of spectrum"
                }
            }
            426 {
                if {[info exists released(newdelay)]} {
                    DisplayFoundItem "revecho" "delay with feedback" $query_display_listcnt $ff \
                     "Generates pitch by delayed feedback on src"
                }
            }
            427 {
                if {[info exists released(filtrage)]} {
                    DisplayFoundItem "filter" "random filter sets" $query_display_listcnt $ff \
                     "generates random filter sets for varibank filter"
                }
            }
            428 {
                if {[info exists released(iterline)]} {
                    DisplayFoundItem "extend" "iterate on pitchline" $query_display_listcnt $ff \
                     "repeat segment of sndfile naturally, following a pitchline"
                }
            }
            429 {
                if {[info exists released(iterlinef)]} {
                    DisplayFoundItem "extend" "iterate on pitchline" $query_display_listcnt $ff \
                     "repeat set of transposed sndfiles, following a pitchline"
                }
            }
            431 {
                if {[info exists released(specnu)] && ($specnu_version >= 7)} {
                    DisplayFoundItem "blur" "time-randomise spectrum" $query_display_listcnt $ff \
                     "randomise the spectrum timewise"
                }
            }
            432 {
                if {[info exists released(specnu)] && ($specnu_version >= 7)} {
                    DisplayFoundItem "blur" "squeeze spectrum frqwise" $query_display_listcnt $ff \
                     "squeeze spectrum about a specified frequency"
                }
            }
            433 {
                if {[info exists released(hover2)]} {
                    DisplayFoundItem "extend" "hover2" $query_display_listcnt $ff \
                     "move around file, zigzag-reading it centred on zero-crossings"
                }
            }
            434 {
                if {[info exists released(selfsim)]} {
                    DisplayFoundItem "focus" "make spectrum self-similar" $query_display_listcnt $ff \
                     "Replace spectral windows by most similar louder windows"
                }
            }
            435 {
                if {[info exists released(iterfof)]} {
                    DisplayFoundItem "extend" "make pitched line from FOFS or snd-packets" $query_display_listcnt $ff \
                     "Gliding or stepped pitchlines generated from delay of given source"
                }
            }
            436 {
                if {[info exists released(pulser)]} {
                    DisplayFoundItem "radical" "make stream of pitched packets" $query_display_listcnt $ff \
                     "Stream of pitched pulses generated from src sound"
                }
            }
            437 {
                if {[info exists released(pulser)]} {
                    DisplayFoundItem "radical" "make stream of pitched packets" $query_display_listcnt $ff \
                     "Stream of pitched pulses generated from src sounds"
                }
            }
            438 {
                if {[info exists released(pulser)]} {
                    DisplayFoundItem "synthesis" "synthesize stream of packets" $query_display_listcnt $ff \
                     "Stream of pitched pulses generated by synthesis from partials-data"
                }
            }
            441 {
                if {[info exists released(synfilt)]} {
                    DisplayFoundItem "synthesis" "synthesize pitch-filtered noise" $query_display_listcnt $ff \
                     "pitchy noise generated by filtering noise-band"
                }
            }
            442 {
                if {[info exists released(strands)]} {
                    DisplayFoundItem "synthesis" "synthesize banded flow" $query_display_listcnt $ff \
                     "Synthesize twisted threads of pitch, in specified bands."
                }
            }
            443 {
                if {[info exists released(refocus)]} {
                    DisplayFoundItem "envelope" "change balance of sound-set" $query_display_listcnt $ff \
                     "Create envelopes for sound-set, for shifting balance."
                }
            }
            447 {
                if {[info exists released(chanphase)]} {
                    DisplayFoundItem "channels" "modify channel phase" $query_display_listcnt $ff \
                     "invert phase of one channel of a soundfile"
                }
            }
            448 {
                if {[info exists released(silend)]} {
                    DisplayFoundItem "edit" "add silence to file end" $query_display_listcnt $ff \
                     "pad end of sound with silence"
                }
            }
            449 {
                if {[info exists released(speculate)]} {
                    DisplayFoundItem "strange" "permute analysis channels" $query_display_listcnt $ff \
                     "sound-set with spectral channels systematically permuted"
                }
            }
            450 {
                if {[info exists released(spectune)]} {
                    DisplayFoundItem "repitch" "transpose sound to one of given pitches" $query_display_listcnt $ff \
                     "tune most-prominent pitch of sound, to nearest pitch in a tuning set"
                }
            }
            451 {
                if {[info exists released(repair)]} {
                    DisplayFoundItem "channels" "reassemble several multichannel files" $query_display_listcnt $ff \
                     "Reassemble multichan sounds from ordered lists of mono sources"
                }
            }
            452 {
                if {[info exists released(distshift)]} {
                    DisplayFoundItem "distort" "distort sound by time-shifting wavesets" $query_display_listcnt $ff \
                     "partition to 2 sets of alternate (groups of) wavesets: timeshift one set"
                }
            }
            453 {
                if {[info exists released(quirk)]} {
                    DisplayFoundItem "distort" "warp samples by a power factor" $query_display_listcnt $ff \
                     "Exaggerate or smooth waveform by scaling sample values by power factor"
                }
            }
            454 {
                if {[info exists released(rotor)]} {
                    DisplayFoundItem "radical" "generates cycling scale-sets" $query_display_listcnt $ff \
                     "Use input waveform to synthesize scale-sets cycling in range and speed"
                }
            }
            455 {
                if {[info exists released(distcut)]} {
                    DisplayFoundItem "edit" "cut and envelope over waveset-groups" $query_display_listcnt $ff \
                     "Cut segments by counting wavesets : impose decaying envelope on outputs"
                }
            }
            456 {
                if {[info exists released(envcut)]} {
                    DisplayFoundItem "edit" "cut and envelope segments of source" $query_display_listcnt $ff \
                     "Cut segments from source : impose decaying envelope on outputs"
                }
            }
            458 {
                if {[info exists released(specfold)]} {
                    DisplayFoundItem "edit" "fold the spectrum" $query_display_listcnt $ff \
                     "rearrange order of spectral data by stretching and folding"
                }
            }
            459 {
                if {[info exists released(brownian)]} {
                    DisplayFoundItem "space" "generate brownian motion in pitchand space" $query_display_listcnt $ff \
                     "Use input waveform, or source-sound, to generate wandering event-stream"
                }
            }
            460 {
                if {[info exists released(spin)]} {
                    DisplayFoundItem "space" "spin a stereo sound" $query_display_listcnt $ff \
                     "spin a stereo image in the stereo space"
                }
            }
            461 {
                if {[info exists released(spin)]} {
                    DisplayFoundItem "space" "spin two stereo sounds" $query_display_listcnt $ff \
                     "spin two stereo images together, in a multichannel space"
                }
            }
            462 {
                if {[info exists released(crumble)]} {
                    DisplayFoundItem "radical" "disintegrate sound to many channels" $query_display_listcnt $ff \
                     "gradually disperse a mono sound over many channels"
                }
            }
            463 {
                if {[info exists released(tesselate)]} {
                    DisplayFoundItem "radical" "tesselate in space and time" $query_display_listcnt $ff \
                     "overlayed repetitions in time & space of one or more srcs"
                }
            }
            465 {
                if {[info exists released(phasor)]} {
                    DisplayFoundItem "radical" "phasing of source" $query_display_listcnt $ff \
                     "overlayed pitch-shifted versions of source"
                }
            }
            466 {
                if {[info exists released(crystal)]} {
                    DisplayFoundItem "radical" "rotate 3d crystal" $query_display_listcnt $ff \
                     "outsnds placed at crystal vertices, then rotated, pitch-, time-, proximity-wise"
                }
            }
            467 {
                if {[info exists released(waveform)]} {
                    DisplayFoundItem "radical" "generate waveform" $query_display_listcnt $ff \
                     "create wavetable from sample of source sound, for use in \"crystal\""
                }
            }
            468 {
                if {[info exists released(dvdwind)]} {
                    DisplayFoundItem "radical" "shrink by skipping" $query_display_listcnt $ff \
                     "shorten sound by read-then-skip, read-then-skip etc. procedure"
                }
            }
            469 {
                if {[info exists released(cascade)]} {
                    DisplayFoundItem "radical" "cascade of echos" $query_display_listcnt $ff \
                     "repeat-echo successive segs of src, superimposing on src"
                }
            }
            470 {
                if {[info exists released(synspline)]} {
                    DisplayFoundItem "synth" "synth with random overtones" $query_display_listcnt $ff \
                     "synthesise tome whose overtones randomly vary over time"
                }
            }
            471 {
                if {[info exists released(fractal)]} {
                    DisplayFoundItem "radical" "create a fractal" $query_display_listcnt $ff \
                     "create fractal from waveform or over sound-source"
                }
            }
            472 {
                if {[info exists released(fractal)]} {
                    DisplayFoundItem "radical" "create a fractal spectrum" $query_display_listcnt $ff \
                     "create fractal over a sound-spectrum"
                }
            }
            473 {
                if {[info exists released(splinter)]} {
                    DisplayFoundItem "radical" "create splinters out of source" $query_display_listcnt $ff \
                     "create splinters before or after specified moment in source"
                }
            }
            474 {
                if {[info exists released(repeater)]} {
                    DisplayFoundItem "radical" "play end with elements repeated" $query_display_listcnt $ff \
                     "play source with specified elements repeating themselves"
                }
            }
            475 {
                if {[info exists released(verges)]} {
                    DisplayFoundItem "radical" "add glissed accents to sound" $query_display_listcnt $ff \
                     "play source with brief elements glissed and possibly accented"
                }
            }
            476 {
                if {[info exists released(motor)]} {
                    DisplayFoundItem "radical" "generate pulsed pulsing from source" $query_display_listcnt $ff \
                     "Produce sounds akin to idling motor engine, from any source"
                }
            }
            477 {
                if {[info exists released(stutter)]} {
                    DisplayFoundItem "radical" "stream of cut segments from src elements" $query_display_listcnt $ff \
                     "Slice src to elements, then randomcut these from their starts"
                }
            }
            478 {
                if {[info exists released(scramble)]} {
                    DisplayFoundItem "distort" "scramble order of wavesets" $query_display_listcnt $ff \
                     "scramble order of all (groups of) wavesets in a src"
                }
            }
            479 {
                if {[info exists released(impulse)]} {
                    DisplayFoundItem "synth" "create impulse stream" $query_display_listcnt $ff \
                     "create stream of, or a single, pitched or chirping impulse(s)"
                }
            }
            480 {
                if {[info exists released(tweet)]} {
                    DisplayFoundItem "synth" "insert chirps on vocal fofs" $query_display_listcnt $ff \
                     "substitute chirps or noise for FOFs in a vocal sound"
                }
            }
            481 {
                if {[info exists released(bounce)]} {
                    DisplayFoundItem "extend" "\"Bouncing\"" $query_display_listcnt $ff \
                     "Repeat source in accelerating sequence with falling level."
                }
            }
            482 {
                if {[info exists released(sorter)]} {
                    DisplayFoundItem "radical" "Reorder sound elements" $query_display_listcnt $ff \
                     "Chop source into elements and rearrange"
                }
            }
            483 {
                if {[info exists released(specfnu)]} {
                    DisplayFoundItem "voicebox" "Work with speech" $query_display_listcnt $ff \
                     "Various processes applicable to speech"
                }
            }
            484 {
                if {[info exists released(flatten)]} {
                    DisplayFoundItem "radical" "Equalise level of sound elements" $query_display_listcnt $ff \
                     "Envelope source to make specified elements more equal in level."
                }
            }
            499 {
                if {[info exists released(caltrain)]} {
                    DisplayFoundItem "blur" "Blur high frqs of spectrum" $query_display_listcnt $ff \
                     "Average upper spectrum to make speech incomprehensible."
                }
            }
            500 {
                if {[info exists released(specenv)]} {
                    DisplayFoundItem "formants" "Apply spectral envelope" $query_display_listcnt $ff \
                     "Apply spectral envelope of file2 to file1."
                }
            }
            504 {
                if {[info exists released(specnu)]} {
                    DisplayFoundItem "stretch" "time stretch" $query_display_listcnt $ff \
                     "Timestretch spectrum, randomising windows."
                }
            }
            1002 {
                DisplayFoundItem "envelope" "impose contour" $query_display_listcnt $ff \
                 "impose loudness contour on a sound"
            }
            1003 {
                DisplayFoundItem "stretch" "time stretch" $query_display_listcnt $ff \
                 "timewarp the spectral file around specified unstretched point"
            }
            -1  {
                DisplayFoundItem "PROGRAMS" "AVAILABLE" $query_display_listcnt $ff \
                 " IN FUTURE CDP RELEASE"
            }
        }
        incr query_display_listcnt
    }
    if [info exists 8chanflag] {
        DisplayFoundItem "multichan" "multi-channel staging" $query_display_listcnt $ff \
         "Arrange input soundfile channels on multichannel stage"
        incr query_display_listcnt
        DisplayFoundItem "multichan" "multi-channel staging" $query_display_listcnt $ff \
         "Collapse multi-channel stage to stereo"
        incr query_display_listcnt
        if [info exists released(mchantoolkit)] {
            DisplayFoundItem "" "~~~~~~ MULTICHANNEL TOOLKIT ~~~~~~" $query_display_listcnt $ff ""
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Copy Soundfile, Changing Format" $query_display_listcnt $ff \
             "Copy file from one format or sampletype to another"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "1st Order Ambisonic Pan" $query_display_listcnt $ff \
             "Pan sound in 1st Order Ambisonic Format"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "2nd Order Ambisonic Pan" $query_display_listcnt $ff \
             "Pan sound in 2nd Order Ambisonic Format"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "2nd Order Periphonic Pan" $query_display_listcnt $ff \
             "Pan sound in 2nd Order Ambisonic Format"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Convert WAVEX to Ambisonic" $query_display_listcnt $ff \
             "Change Format of Data (losing lspkr position info)"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Decode Ambisonic Format" $query_display_listcnt $ff \
             "Decode Ambisonic Data to Other Soundfile formats"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Extract Channels from Multichan" $query_display_listcnt $ff \
             "Extract specified channels from a multichannel file"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Interleave Channels" $query_display_listcnt $ff \
             "Interleave input channels in various formats of outfile"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Reorder Output Channels" $query_display_listcnt $ff \
             "Reorder Output Channels variously"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "lspkr position mask vals for WAVEX" $query_display_listcnt $ff \
             "See Acceptable values for Lspkr Position Masks in WAVE_EX files"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Change WAVEX Speaker Positions Mask" $query_display_listcnt $ff \
             "Modify Lspkr Position info in WAVE_EX format files"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Check files compatible for Concatenate" $query_display_listcnt $ff \
             "Check files are compatible for concatenation"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "Concenate Files (for CD Burn)" $query_display_listcnt $ff \
             "Join files end to end, and make Cue list if desired"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "RMS Power And Level Stats" $query_display_listcnt $ff \
             "Get loudness info on sound in file in any format"
            incr query_display_listcnt
            DisplayFoundItem "multichan" "File Properties (including WAVEX)" $query_display_listcnt $ff \
             "Get file properties, including specific WAVEX properties"
            incr query_display_listcnt
        }
        unset 8chanflag
    }
}
                                                                                 
###############################################
# THE procs BELOW DO ~NOT~ NEED TO BE UPDATED #
###############################################

proc ProcessHasModes {progno} {
    global prg evv
    set mode [lindex $prg($progno) $evv(MODECNT_INDEX)]
    if {$mode > 0} {
        return 1
    }
    return 0
}

######################################
#--- User defined textfile extensions 
######################################

proc GetTextfileExtension {str} {
    global new_user_text_extensions user_text_extensions evv

    if {[info exists new_user_text_extensions]} {
        switch -- $str {
            "mix"     {return [lindex $new_user_text_extensions 0]}
            "sndlist" {return [lindex $new_user_text_extensions 1]}
            "props"   {return [lindex $new_user_text_extensions 2]}
            "brk"     {return [lindex $new_user_text_extensions 3]}
            "mmx"
            {
                if {[llength $new_user_text_extensions] > 4} { 
                    return  [lindex $new_user_text_extensions 4]
                }
            }
        }
    } elseif {[info exists user_text_extensions]} {
        switch -- $str {
            "mix"     {return [lindex $user_text_extensions 0]}
            "sndlist" {return [lindex $user_text_extensions 1]}
            "props"   {return [lindex $user_text_extensions 2]}
            "brk"     {return [lindex $user_text_extensions 3]}
            "mmx"     
            {
                if {[llength $user_text_extensions] > 4} { 
                    return  [lindex $user_text_extensions 4]
                }
            }
        }
    }
    return $evv(TEXT_EXT)
}

proc AssignTextfileExtension {ftyp} {
    global evv
    if {[IsAMixfile $ftyp]} {
        set str mix
    } elseif {$ftyp == $evv(MIX_MULTI)} {
        set str mmx
    } elseif {[IsASndlist $ftyp]} {
        set str sndlist
    } elseif {[IsABrkfile $ftyp]} {
        set str brk
    } else {
        set str text
    }
    return [GetTextfileExtension $str]
}

proc IsATextfileExtension {str} {
    global user_text_extensions new_user_text_extensions evv

    if {[info exists new_user_text_extensions]} {
        foreach item $new_user_text_extensions {
            if {[string match $str $item]} {
                return 1
            }
        }
    }
    if {[info exists user_text_extensions]} {
        foreach item $user_text_extensions {
            if {[string match $str $item]} {
                return 1
            }
        }
    }
    if {[string match $str $evv(TEXT_EXT)]} {
        return 1
    }
    return 0
}

proc LoadTextfileExtensions {} {
    global evv user_text_extensions new_user_text_extensions wstk

    set evv(USER_EXTENSIONS) "user_ext"
    set fnam [file join $evv(CDPRESOURCE_DIR) $evv(USER_EXTENSIONS)$evv(CDP_EXT)]
    if {![file exists $fnam]} {
        return
    }
    if {[catch {open $fnam "r"} zit]} {
        Inf "Cannot Open File '$fnam' To Read User Textfile Extensions"
        return
    }
    set cnt 0
    while {[gets $zit line] >= 0} {
        set line [string trim $line]
        if {[string length $line] > 0} {
            set len [string length $line]
            if {![string match [string index $line 0] "."] || ($len < 2) || ($len > 5)} {
                Inf "Bad Data ($line) Found For User Textfile Extension In File '$fnam'"
                catch {unset user_text_extensions}
                close $zit
                return
            }
            set n 1
            while {$n < $len} {
                set item [string index $line $n]
                if {![regexp {^[A-Za-z0-9]$} $item]} {
                    Inf "Bad Data ($line) Found For User Textfile Extension In File '$fnam'"
                    catch {unset user_text_extensions}
                    close $zit
                    return
                }
                incr n
            }
            lappend user_text_extensions $line
            incr cnt
        }
    }
    close $zit
    if {$cnt == 0} {
        Inf "No Data Found For User Textfile Extensions In File '$fnam'"
        catch {unset user_text_extensions}
        return
    }
    if {$cnt < 3} {
        Inf "Insufficient Data (only $cnt items) Found For User Textfile Extensions In File '$fnam'"
        catch {unset user_text_extensions}
        return
    }
    if {$cnt < 4} {
        set msg "No User Extension Set For Breakpoint Files:\n\n"
        append msg "Would You Like To Set '.brk' As The Default Extension ??"
        set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
        if [string match $choice "no"] {
            lappend user_text_extensions $evv(TEXT_EXT)
        } else {
            lappend user_text_extensions ".brk"
        }
    }
    foreach item $user_text_extensions {
        foreach sndext $evv(SNDFILE_EXTS) {
            if {[string match $item $sndext]} {
                Inf "Bad User Textfile Extension ($item : A Reserved Extension) Found In File '$fnam'"
                catch {unset user_text_extensions}
                return
            }
        }
        if {[string match $item $evv(SNDFILE_EXT)]      \
        ||  [string match $item $evv(ANALFILE_EXT)]     \
        ||  [string match $item $evv(PITCHFILE_EXT)]    \
        ||  [string match $item $evv(TRANSPOSFILE_EXT)] \
        ||  [string match $item $evv(FORMANTFILE_EXT)]  \
        ||  [string match $item $evv(ENVFILE_EXT)]} {
            Inf "Bad User Textfile Extension ($item : A Reserved Extension) Found In File '$fnam'"
            catch {unset user_text_extensions}
            return
        }
    }
    if {$cnt < 4} {
        set new_user_text_extensions $user_text_extensions
        set user_text_extensions [list 0 0 0 0]
        SaveTextfileExtensions
        set user_text_extensions $new_user_text_extensions
    }
}

proc SaveTextfileExtensions {} {
    global evv user_text_extensions new_user_text_extensions
    set fnam [file join $evv(CDPRESOURCE_DIR) user_ext$evv(CDP_EXT)]
    set dosave 0
    if {![info exists user_text_extensions] && ![info exists new_user_text_extensions]} {
        if {[file exists $fnam]} {
            if [catch {file delete $fnam} zit] {
                Inf "Cannot Delete File '$fnam' To Remove User Textfile Extensions: Delete This File Outside The Sound Loom"
            }
        }
        return
    }
    if {[info exists new_user_text_extensions]} {
        if {![file exists $fnam]} {
            set dosave 1
        } else {
            if {[info exists user_text_extensions]} {
                if {[llength $new_user_text_extensions] != [llength $user_text_extensions]} {
                    set dosave 1
                } else {
                    foreach ue $user_text_extensions nue $new_user_text_extensions {
                        if {![string match $ue $nue]} {
                            set dosave 1
                        }
                    }
                }
            } else {
                set dosave 1
            }
        }
    }
    if {!$dosave} {
        return
    }
    set tempfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
    if {[catch {open $tempfnam "w"} zit]} {
        Inf "Cannot Open Temporary File '$tempfnam' To Write New User Textfile Extensions"
        return
    }
    foreach item $new_user_text_extensions {
        puts $zit $item
    }
    close $zit
    if {[file exists $fnam] && [catch {file delete $fnam} zit]} {
        set msg "Cannot Delete Existing File '$fnam' Containing User Textfile Extensions\n"
        append msg "The New Extensions Are In File '$tempfnam'\n"
        append msg "Delete File '$fnam', Then Rename File '$tempfnam' To '$fnam', Outside The Sound Loom\n"
        append msg "Before Proceeding"
        Inf $msg
    }
    if [catch {file rename $tempfnam $fnam} zit] {
        Inf $zit
        set msg "Cannot Rename File '$tempfnam' Containing User Textfile Extensions, To '$fnam'\n"
        append msg "Rename The File Outside The Sound Loom, Before Proceeding"
        Inf $msg
    }
}

proc ChangeTextfileExtensions {} {
    global pr_chte evv chte1 chte2 chte3 chte4 chte5 user_text_extensions new_user_text_extensions

    set f .chte

    if [Dlg_Create $f "SPECIFY EXTENSIONS FOR SPECIAL TEXTFILES" "set pr_chte 0" -borderwidth $evv(BBDR)] {
        frame $f.0
        frame $f.00
        frame $f.000
        frame $f.1
        frame $f.2
        frame $f.3
        frame $f.4
        frame $f.5
        button $f.0.ok -text "Keep New Extensions" -command "set pr_chte 1" -highlightbackground [option get . background {}]
        button $f.0.q  -text "Don't Change Extensions" -command "set pr_chte 0" -highlightbackground [option get . background {}]
        pack $f.0.ok -side left
        pack $f.0.q -side right
        button $f.00.a  -text "Abandon All Special Extensions" -command "set pr_chte 2" -highlightbackground [option get . background {}]
        pack $f.00.a -side top
        label $f.000.ll  -text "Once you define your own textfile extensions, and USE them,\nif you redefine these, the system may not recognise\nfiles using previous definitions." -fg $evv(SPECIAL)
        pack $f.000.ll -side top
        button $f.1.b -text ".mix" -command "set chte1 .mix" -width 4 -highlightbackground [option get . background {}]
        entry $f.1.e -textvariable chte1 -width 6
        label $f.1.ll -text "Mixfiles"
        pack $f.1.b  $f.1.e $f.1.ll  -side left -padx 2
        button $f.2.b -text ".orc" -command "set chte2 .orc" -width 4 -highlightbackground [option get . background {}]
        entry $f.2.e -textvariable chte2 -width 6
        label $f.2.ll -text "Lists of Sounds"
        pack $f.2.b $f.2.e $f.2.ll  -side left -padx 2
        button $f.3.b -text ".prp" -command "set chte3 .prp" -width 4 -highlightbackground [option get . background {}]
        entry $f.3.e -textvariable chte3 -width 6
        label $f.3.ll -text "Property Files"
        pack $f.3.b $f.3.e $f.3.ll  -side left -padx 2
        button $f.4.b -text ".brk" -command "set chte4 .brk" -width 4 -highlightbackground [option get . background {}]
        entry $f.4.e -textvariable chte4 -width 6
        label $f.4.ll -text "Brkpoint Files"
        pack $f.4.b $f.4.e $f.4.ll  -side left -padx 2
        button $f.5.b -text ".mmx" -command "set chte5 .mmx" -width 4 -highlightbackground [option get . background {}]
        entry $f.5.e -textvariable chte5 -width 6
        label $f.5.ll -text "Multichan Mixfiles"
        pack $f.5.b  $f.5.e $f.5.ll  -side left -padx 2
        pack $f.0 -side top -fill x -expand true -pady 2
        pack $f.00 $f.000 -side top -pady 2
        pack $f.1 $f.2 $f.3 $f.4 $f.5 -side top -fill x -expand true -pady 2
#       wm resizable $f 0 0
        bind $f.1.e <Down>   "focus .chte.2.e"
        bind $f.1.e <Up>     "focus .chte.5.e"
        bind $f.2.e <Down>   "focus .chte.3.e"
        bind $f.2.e <Up>     "focus .chte.1.e"
        bind $f.3.e <Down>   "focus .chte.4.e"
        bind $f.3.e <Up>     "focus .chte.2.e"
        bind $f.4.e <Down>   "focus .chte.5.e"
        bind $f.4.e <Up>     "focus .chte.3.e"
        bind $f.5.e <Down>   "focus .chte.1.e"
        bind $f.5.e <Up>     "focus .chte.4.e"
        bind $f <Escape>  {set pr_chte 0}
    }
    if {[info exists new_user_text_extensions]} {
        set chte1 [lindex $new_user_text_extensions 0]
        set chte2 [lindex $new_user_text_extensions 1]
        set chte3 [lindex $new_user_text_extensions 2]
        set chte4 [lindex $new_user_text_extensions 3]
        catch {set chte5 [lindex $new_user_text_extensions 4]}
    } elseif {[info exists user_text_extensions]} {
        set chte1 [lindex $user_text_extensions 0]
        set chte2 [lindex $user_text_extensions 1]
        set chte3 [lindex $user_text_extensions 2]
        set chte4 [lindex $user_text_extensions 3]
        catch {set chte5 [lindex $user_text_extensions 4]}
    } else {
        set chte1 $evv(TEXT_EXT)
        set chte2 $evv(TEXT_EXT)
        set chte3 $evv(TEXT_EXT)
        set chte4 $evv(TEXT_EXT)
        catch {set chte5 $evv(TEXT_EXT)}
    }
    set pr_chte 0
    set finished 0
    raise $f
    My_Grab 0 $f pr_chte $f.1.e
    while {!$finished} {
        tkwait variable pr_chte
        if {$pr_chte == 0} {
            break
        } elseif {$pr_chte == 2} {
            catch {unset new_user_text_extensions}
            catch {unset user_text_extensions}
            break
        }
        set n 1
        set OK 1
        while {$n < 6} {
            set str chte$n
            upvar $str var
            if {![ValidUserExt $var [$f.$n.ll cget -text]]} {
                set OK 0
                break
            }
            incr n
        }
        if {!$OK} {
            continue
        }
        catch {unset new_user_text_extensions} 
        set n 1
        while {$n < 6} {
            set str chte$n
            upvar $str var
            lappend new_user_text_extensions $var
            incr n
        }
        break
    }
    My_Release_to_Dialog $f
    Dlg_Dismiss $f
}

proc ValidUserExt {str str2} {
    global evv
    set len [string length $str]
    if {($len < 2) || ($len > 5) || ![string match [string index $str 0] "."]} {
        Inf "Invalid Extension For $str2 (Must Be '.' Followed By 1-4 Alphanumeric Characters)"
        return 0
    }
    set n 1
    while {$n < $len} {
        set item [string index $str $n]
        if {![regexp {^[A-Za-z0-9]$} $item]} {
            Inf "Invalid Extension For $str2 (must Be '.' Followed By 1-4 Alphanumeric Characters)"
            return 0
        }
        incr n
    }
    foreach sndext $evv(SNDFILE_EXTS) {
        if {[string match $str $sndext]} {
            Inf "Reserved Extension Entered For $str2"
            return 0
        }
    }
    if {[string match $str $evv(SNDFILE_EXT)]       \
    ||  [string match $str $evv(ANALFILE_EXT)]      \
    ||  [string match $str $evv(PITCHFILE_EXT)] \
    ||  [string match $str $evv(TRANSPOSFILE_EXT)] \
    ||  [string match $str $evv(FORMANTFILE_EXT)]   \
    ||  [string match $str $evv(ENVFILE_EXT)]} {
        Inf "Reserved Extension Entered For $str2"
        return 0
    }
    return 1
}

proc ForceMTKFileExtensions {typ cmd} {
    global evv
    set len [llength $cmd]
    switch -- $typ {
        0 { ;#  ABFPAN, COPYSFX
            set n 1
            set doneinfile 0
            while {$n < $len} {
                set item [lindex $cmd $n]
                if {[string match [string index $item 0] "-"]} {        ;#  Skip over flags
                    incr n
                    continue
                } elseif {!$doneinfile} {                               ;#  If ness, add extension to infile
                    set zzz [file rootname $item]
                    if {[string length $item] == [string length $zzz]} {
                        append item $evv(SNDFILE_EXT)
                        set cmd [lreplace $cmd $n $n $item]
                    }
                    set doneinfile 1
                    incr n
                    continue
                } else {                                                ;#  If ness, add extension to outfile
                    set zzz [file rootname $item]
                    if {[string length $item] == [string length $zzz]} {
                        append item $evv(SNDFILE_EXT)
                        set cmd [lreplace $cmd $n $n $item]
                    }
                    break
                }
            }
        }
        1 { ;#  CHANNELX
            set n 1
            set doneinfile 0
            while {$n < $len} {
                set item [lindex $cmd $n]                               ;#  Find any "-o" flagged entry
                if {[string match [string index $item 0] "-"] && [string match [string index $item 1] "o"]} {
                    set fnam [string range $item 2 end]
                    set zzz [file rootname $fnam]                       ;#  and add file extension to filename if ness
                    if {[string length $fnam] == [string length $zzz]} {
                        append fnam $evv(SNDFILE_EXT)
                        set item "-o"
                        append item $fnam
                        set cmd [lreplace $cmd $n $n $item]
                    }
                    incr n
                } elseif {!$doneinfile} {                               ;#  If ness, add extension to infile    
                    set zzz [file rootname $item]
                    if {[string length $item] == [string length $zzz]} {
                        append item $evv(SNDFILE_EXT)
                        set cmd [lreplace $cmd $n $n $item]
                    }
                    break
                }
            }
        }
    }
    return $cmd
}

