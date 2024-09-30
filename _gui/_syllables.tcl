#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#--------- Functions to allow Music Testbed Functions to come to top of menu, in DO IT AGAIN

proc TestbedAgain {} {
	global testbedcmd wl ch dl tabed evv

	if {![info exists testbedcmd]} {
		Inf "No Previous Command Used"
		return
	}
	switch -- $testbedcmd {
		findpmarks	{ ManipulatePmarks $wl 0 }
		dopmarks	{ Do_Pitchmark $wl 0 }
		compmarks	{ PmarkCompare $wl }
		allpmarks	{ ManipulatePmarks $wl 1 }
		delpmarks	{ Do_Pitchmark $wl 1 }
		doprops		{ Do_Props 0 }
		remprops	{ Add_Prop $evv(DELETE_ENTIRE_PROP) }
		mtprops		{ Add_Prop $evv(ADD_VOID_PROP) }
		vecprops	{ Add_Prop $evv(ADD_VECTOR_PROP) }
		dsprops		{ Merge_Props 0 }
		isprops		{ Merge_Props 1 }
		mergmanypr	{Merge_Many_Props}
		sndpropsw	{ Do_Props 3 }
		sndprops	{ Do_Props 2 }
		showprops	{ Do_Props 1 }
		proptoorc	{ PropToOrc }
		textpex		{ TextPropExtract }
		propsstats	{ PropsStats }
		propsgather	{ PropsGather }
		propscount	{ PropsFileCount }
		selbkgd		{ BListFromWkspace $wl 1 0}
		allbkgd		{ BListFromWkspace $wl 0 0}
		chosbkgd	{ BListFromWkspace $ch 0 0}
		chosbkgd_dup { BListFromWkspace $ch 0 1}
		dirbkgd		{ BListFromWkspace dirlist 0 0}
		seebkgd		{ GetBLName 2 }
		checkbkgd	{ GetBLName 17 }
		renamebkgd	{ GetBLName 4 }
		desbkgd		{ GetBLName 1 }
		delbkgd		{ DeleteAllBL }
		pmbkgd		{ GetBLName 5 }
		hibkgd		{ GetBLName 6 }
		combkgd		{ GetBLName 7 }
		workpad		{ GetBLName 11 }
		wkrepl		{ LoadToWorkspaceBL 0 0 }
		wkadd		{ LoadToWorkspaceBL 1 0 }
		wksel		{ GetBLName 10 }
		tochos		{ LoadToWorkspaceBL 1 1 }
		tochosel	{ GetBLName 14 }
		remlast		{ RemoveBkgd 0 }
		remlastall	{ RemoveBkgd 1 }
		remacc		{ RemoveBkgd 2 }
		rembl		{ RemoveFromWkspace bkgdthis }
		skwk		{ GetWkspaceSoundToScore $wl 0}
		skch		{ GetWkspaceSoundToScore $ch 0}
		skdir		{ GetWkspaceSoundToScore $dl 0}
		sklist		{ GetWkspaceSoundListToScore 0 }
		skmix		{ GetWkspaceSoundListToScore 1 }
		skorg0		{ EstablishScore 0}
		skorg1		{ EstablishScore 1}
		skorg-1		{ EstablishScore -1}
		skrefr		{ RefreshUnloadedScores 0 }
		skrede		{ DestroyNamedScore}
		interp		{ Interpolator 0 }
		addhead		{ MassageFilenames addhead 1 $wl}
		addtail		{ MassageFilenames addtail 1 $wl}
		addat		{ MassageFilenames addat   1 $wl}
		addatseg	{ MassageFilenames addatseg 1 $wl}
		headtail	{ HeadVTail 1 1 $wl}
		tailhead	{ HeadVTail 0 1 $wl}
		swapseg		{ MassageFilenames swapsegs 1 $wl}
		reverse		{ MassageFilenames reverse 1 $wl}
		delhead		{ MassageFilenames deletehead 1 $wl}
		deltail		{ MassageFilenames deletetail 1 $wl}
		delseg		{ MassageFilenames deleteseg 1 $wl}
		all_addhead { MassageFilenames addhead 0 $wl }
		all_addtail { MassageFilenames addtail 0 $wl}
		all_addat	{ MassageFilenames addat 0 $wl}
		all_addatseg { MassageFilenames addatseg 0 $wl}
		all_headtail { HeadVTail 1 0 $wl}
		all_tailhead { HeadVTail 0 0 $wl}
		all_swapseg { MassageFilenames swapsegs 0 $wl}
		all_reverse { MassageFilenames reverse 0 $wl}
		all_delhead { MassageFilenames deletehead 0 $wl}
		all_deltail	{ MassageFilenames deletetail 0 $wl}
		all_delseg	{ MassageFilenames deleteseg 0 $wl}
		alphabet	{ SortFilenames $wl alphabet 1 sort}
		startcons	{ SortFilenames $wl startcons 1 sort}
		endcons		{ SortFilenames $wl endcons 1 sort}
		vowel		{ SortFilenames $wl vowel 1 sort}
		number		{ SortFilenames $wl numeric 1 sort}
		pclass		{ SortFilenames $wl pitchclass 1 sort}
		entire		{ SortFilenames $wl all 1 sort}
		all_alphabet { SortFilenames $wl alphabet 0 sort}
		all_startcons { SortFilenames $wl startcons 0 sort}
		all_endcons { SortFilenames $wl endcons 0 sort}
		all_vowel	{ SortFilenames $wl vowel 0 sort}
		all_number	{ SortFilenames $wl numeric 0 sort}
		all_pclass	{ SortFilenames $wl pitchclass 0 sort}
		all_entire	{ SortFilenames $wl all 0 sort}
		addhead_ch		{ MassageFilenames addhead 1 $ch}
		addtail_ch		{ MassageFilenames addtail 1 $ch}
		addat_ch		{ MassageFilenames addat   1 $ch}
		addatseg_ch		{ MassageFilenames addatseg 1 $ch}
		headtail_ch		{ HeadVTail 1 1 $ch}
		tailhead_ch		{ HeadVTail 0 1 $ch}
		swapseg_ch		{ MassageFilenames swapsegs 1 $ch}
		reverse_ch		{ MassageFilenames reverse 1 $ch}
		delhead_ch		{ MassageFilenames deletehead 1 $ch}
		deltail_ch		{ MassageFilenames deletetail 1 $ch}
		delseg_ch		{ MassageFilenames deleteseg 1 $ch}
		all_addhead_ch	{  MassageFilenames addhead 0 $ch}
		all_addtail_ch	{ MassageFilenames addtail 0 $ch}
		all_addat_ch	{ MassageFilenames addat   0 $ch}
		all_addatseg_ch	{ MassageFilenames addatseg 0 $ch}
		all_headtail_ch { HeadVTail 1 0 $ch}
		all_tailhead_ch { HeadVTail 0 0 $ch}
		all_swapseg_ch	{ MassageFilenames swapsegs 0 $ch}
		all_reverse_ch	{ MassageFilenames reverse 0 $ch}
		all_delhead_ch	{ MassageFilenames deletehead 0 $ch }
		all_deltail_ch	{ MassageFilenames deletetail 0 $ch }
		all_delseg_ch	{ MassageFilenames deleteseg 0 $ch }
		alphabet_ch		{ SortFilenames $ch alphabet 1 sort}
		startcons_ch	{ SortFilenames $ch startcons 1 sort}
		endcons_ch		{ SortFilenames $ch endcons 1 sort}
		vowel_ch		{ SortFilenames $ch vowel 1 sort}
		number_ch		{ SortFilenames $ch numeric 1 sort}
		pclass_ch		{ SortFilenames $ch pitchclass 1 sort}
		entire_ch		{ SortFilenames $ch all 1 sort}
		all_alphabet_ch { SortFilenames $ch alphabet 0 sort}
		all_startcons_ch { SortFilenames $ch startcons 0 sort}
		all_endcons_ch	{ SortFilenames $ch endcons 0 sort}
		all_vowel_ch	{ SortFilenames $ch vowel 0 sort}
		all_number_ch	{ SortFilenames $ch numeric 0 sort}
		all_pclass_ch	{ SortFilenames $ch pitchclass 0 sort}
		all_entire_ch	{ SortFilenames $ch all 0 sort}
		ialphabet_ch	{ SortFilenames $ch alphabet 1 interleave}
		istartcons_ch	{ SortFilenames $ch startcons 1 interleave}
		iendcons_ch		{ SortFilenames $ch endcons 1 interleave}
		ivowel_ch		{ SortFilenames $ch vowel 1 interleave}
		inumber_ch		{ SortFilenames $ch numeric 1 interleave}
		ipclass_ch		{ SortFilenames $ch pitchclass 1 interleave}
		ientire_ch		{ SortFilenames $ch all 1 interleave}
		all_ialphabet_ch { SortFilenames $ch alphabet 0 interleave}
		all_istartcons_ch { SortFilenames $ch startcons 0 interleave}
		all_iendcons_ch { SortFilenames $ch endcons 0 interleave}
		all_ivowel_ch	{ SortFilenames $ch vowel 0 interleave}
		all_inumber_ch	{ SortFilenames $ch numeric 0 interleave}
		all_ipclass_ch	{ SortFilenames $ch pitchclass 0 interleave}
		all_ientire_ch	{ SortFilenames $ch all 0 interleave}
		alphabet_r		{ SortFilenames $ch alphabet 1 reduce}
		startcons_r		{ SortFilenames $ch startcons 1 reduce}
		endcons_r		{ SortFilenames $ch endcons 1 reduce}
		vowel_r			{ SortFilenames $ch vowel 1 reduce}
		number_r		{ SortFilenames $ch numeric 1 reduce}
		pclass_r		{ SortFilenames $ch pitchclass 1 reduce}
		alphabet_rall	{ SortFilenames $ch alphabet 0 reduce}
		startcons_rall	{ SortFilenames $ch startcons 0 reduce}
		endcons_rall	{ SortFilenames $ch endcons 0 reduce}
		vowel_rall		{ SortFilenames $ch vowel 0 reduce}
		number_rall		{ SortFilenames $ch numeric 0 reduce}
		pclass_rall		{ SortFilenames $ch pitchclass 0 reduce}
		substitute		{ MassageFilenames cycfiles 1 $ch}
		getsegs			{ MassageFilenames getsegs 1 $wl}
		getsegs_ch		{ MassageFilenames getsegs 1 $ch}
		delsegval		{ MassageFilenames delsegval 0 $ch}
		newprops		{ NewPropfile}
		sndtoprop		{ AddSndsToPropfile}
		knownprops		{ ShowKnownPropfiles}
		sndsinprop		{ SndsInPropfile}
		ppartition		{ PlayOutput 3}
		pswap			{ SwapPartitionPlay}
		harmony			{ PitchManips 0}
		nharmony		{ PreNTHarmony}
		timeline		{ EstablishTimeline }
		spacedesign		{ SpaceDesign }
		spacmonmix		{ SpatialiseMonoMix }
		keyboard		{ TheKeyboard }
		shmotif			{ ShowMotifs }
		delmtf0			{ DeleteMotifs 0 }
		delmtf1			{ DeleteMotifs 1 }
		melfix			{ TheMelodyFixer }
		frqexmidi		{ FrqExtractionDataToNotatableMidi }
		cleank			{ CleaningKit }
		proptab			{ TabProps 1}
		features		{ Features }
		correctpitch	{ CorrectPitch }
		bulkpitch		{ BulkPitchExtract }
		massign			{ MelodyAssign 0 }
		miditrim		{ MidiTrim }
		midibrkseq010	{ MidiBrkSeq 0 1 0}
		midibrkseq110	{ MidiBrkSeq 1 1 0}
		midibrkseq101	{ MidiBrkSeq 1 0 1}
		midibrkseq011	{ MidiBrkSeq 0 1 1}
		evffad			{ ExtractVfilterFromAnalData}
		avfdtpos		{ AdjustVfiltToPitchofSrc}
		seqshift		{ TransposeC60SequenceFileToGivenPitch }
		seqpk			{ ConvertFrqbrkpntDataAndPeakLevelDataToSequencer60Data }
		mstandard0		{ FrqBrkToStandardMidi 0}
		mstandard1		{ FrqBrkToStandardMidi 1}
		globprops		{ GlobalPropVals }
		namprops		{ PropNamesChange }
		propnsort		{ PropsNumericSort }
		propnudir		{ PropsDirChange }
		proprenum		{ GenericSubstituteWkspaceNumbersAndPropfileEntries }
		proppush		{ PropfilePush }
		propreorder		{ PropsPropnameSort }
		propsndorder	{ PropsSoundSort }
		propsndrename	{ PropsSoundRename }
		propsremove		{ RemoveSndsFromPropfile }
		exrhythm		{ ExtractRhythm }
		rhshrink		{ RhythmicSyllableShrink }
		mmtrim			{ MMTrim 0}
		mmtrimnew		{ MMTrim 1}
		evemph			{ EventsEmphasize }
		isopeak			{ IsolatePeak }
		matchiso		{ MatchIsolates }
		sndtomx9		{ SndToMix 9 }
		datawarp		{ DataWarp }
		isolator0		{ EventIsolator 0}
		isolator1		{ EventIsolator 1}
		speciso			{ SpectralEventIsolator}
		syncmarks0		{ SynchroniseSoundsAtTimeMarks 0 }
		syncmarks1		{ SynchroniseSoundsAtTimeMarks 1 }
		syncmarks2		{ SynchroniseSoundsAtTimeMarks 2 }
		syncmarks3		{ SynchroniseSoundsAtTimeMarks 3 }
		syncmarks4		{ SynchroniseSoundsAtTimeMarks 4 }
		syncmarks5		{ SynchroniseSoundsAtTimeMarks 5 }
		syncmarks6		{ SynchroniseSoundsAtTimeMarks 6 }
		syncmult		{ SyncSeveralFilesAtTimemarks }
		syncmix			{ RerhythmMixfile }
		timecues		{ CreateTimeCues }
		syncpch0		{ TransposToPitch_SyncingAtTimeMarks 0 }
		syncpch1		{ TransposToPitch_SyncingAtTimeMarks 1 }
		synlev			{ LevelsAtTimeMarks }
		madjusthf0		{ MelodyAdjust 0}
		madjusthf1		{ MelodyAdjust 1}
		cutspecp		{ ExtractSpecificPitchedMaterial}
		isopitch		{ IsolatePitches}
		textstats		{ AnalyseTextPropertyWordData 0}
		textrhyme		{ TextPropRhyme 0 0}
		textasson		{ TextPropertyConsonantStatistics 0}
		textstarts		{ TextPropRhyme 1 0}
		rhymeas			{ CheckForNewRhymes 0}
		fofex			{ FofReco 1}
		fofex1			{ FofReco 2}
		fofreco			{ FofReco 0}
		canon			{ ExtractCanonicTimeStep}
		midipspec		{ PlaySampleWithNormalisedMidiSeq}
		midifpoll0		{ PollOfFilters 0}
		midifpoll1		{ PollOfFilters 1}
		midifdiv		{ FilterDivideByPitch }
		relseq			{FilesRelated seq}
		relflt			{FilesRelated flt}
		relpch			{FilesRelated pch}
		taenv			{TimeAveragedEnvelope}
		restail			{ResTail}
		mrestail		{MresTail}
		revstereo		{RevStereo}
		bytetyb			{ByteReversal}
		thumbmake		{MakeThumbnail 0}
		thumbkill		{ThumbKill 0}
		thumbsee		{ThumbSee 0}
		thumbpurge		{PurgeThumbnails}
		playchan		{PlayChannel 0}
		slistcomp		{SoundlistsCompare}
		slistsort		{SoundlistSort}
		slistmix		{SoundlistsMix}
		findrhyme		{FindSpecifiedRhymesInTextsOfTextPropertyInAllFiles 0}
		findwstts		{FindSpecifiedRhymesInTextsOfTextPropertyInAllFiles 1}
		mch_shred		{DoMchshred}
		mch_zig			{DoMchzig}
		mch_iter		{DoMchiter}
		mchxstereo		{MchXToStereo}
		stereoinmch		{MchFromStereo}
		stereorand		{MultiChanRandStereoPan}
		stereomulti		{MultiChanStereoPan}
		stereopanmch	{MchPanStereo}
		stereorotmch	{MchRotateMchan}
		stereotomch		{StereoToMchMix}
		monotomch		{MonoToMch}
		fadein			{FadeIn}
		maxsnd			{MaxlevelOfAllFilesSelectedOrInSelectedMixfile}
		rearrange		{Rearrange}
		mchactive		{MchanActive}
		mchengineer		{MchanEngineer}
		permchunks		{PermChunks}
		mchtostereo		{MchToStereo}
		mchtostereo2	{MchSelectStereo}
		playgroups0		{PlayN 0}
		playgroups1		{PlayN 1}
		playpm			{PlayPM}
		playch			{PlayCh}
		playchwide		{PlayChWide}
		kmonotonmulti	{KMonoToNMulti}
		multitransfer	{MultiTransfer}
		specav			{SpecAverageMaster}
		fpartition		{FilterPartition}
		fractals		{Fractals}
		gpfilter		{GroupFilter}
		varibox			{Varibox}
		varispec		{Varispec}
		multistack		{MultiStack}
		sidebyside		{SideBySideMix}
		monoinject		{MonoInject}
		rezig			{ReZig}
		dopplerpan		{DopplerPan}
		transposset		{TransposSet}
		mchrandrotate	{MchRandRotate}
		mchranddrift	{MchRandDrift}
		genspecfilt		{GenerateSpectraByFiltering}
		modspecfilt		{ModifySpectraByFilterAndInterp}
		genspecinterp	{GenerateSpectraByInterpolation}
		genspecstak		{GenerateSpectraByStacking}
		genspecrev		{GenerateSpectraByReverb}
		genspecdist		{GenerateSpectraByDistort}
		genspectrem		{GenerateSpectraByTremolo}
		genspechsh		{GenerateSpectraByHShift}
		genspecpsh		{GenerateSpectraByPshift}
		genspecpshset	{GenerateSpectraByPshiftSet}
		genspecoct		{GenerateSpectraByOct}
		genspecmixoct	{GenerateSpectraByMixOrc 0}
		genspectstr		{GenerateSpectraByTstretch}
		genspectshr		{GenerateSpectraByTshrink}
		genspectrim		{GenerateSpectraByETrim}
		genspectris		{GenerateSpectraByETrimSet}
		genspectstrs	{GenerateSpectraByTstretchSet}
		genspectshrs	{GenerateSpectraByTshrinkSet}
		genspectrems	{GenerateSpectraByTremoloSet}
		genspectrin		{GenerateSpectraByETrimNorm}
		genspectrii		{GenerateSpectraByTrim}
		genspecmixoctst	{GenerateSpectraByMixOrc 1}
		stirmix			{StirMix}
		stereowrap		{StereoWrap}
		tuneset			{TuneSet}
		combopmarks		{CombinePmarks}
		sortpmarks		{SortOnPmarks}
		inspmarks0		{InSetPmarks 0}
		inspmarks1		{InSetPmarks 1}
		mchshrink		{MchShrink}
		tuneadj			{PitchNamesAdjust}
		extracthf		{ExtractApplyHF}
		contract		{Contract}
		mch2tomix		{MultiToStereoMix}
		nessscores		{ShowNessData 1}
		nessinstrs		{ShowNessData 0}
		nessrefresh		{RefreshNessData}
		nessprofile		{NessProfile 1 0}
		nessprofile0	{NessProfile 0 0}
		nessscore		{NessScore 1 0}
		nessscore0		{NessScore 0 0}
		datasort		{DataSort 0}
		txtbkwdsort		{ReverseTextSort}
		testrhyme		{TestRhymeExtraction 0}
		darwin			{Darwin 0}
		darwinplay		{Darwin 1}
		reverg			{ReverbdVerges}
		mixmerge		{MixMerge}
		stagger			{StaggerPeaks}
		degrade			{Degrade}
		polyfilter		{Polyfilter}
		transposchord	{TransposChord}
		overlapslice	{OverlapSlice}
		followtoHF0		{Convert_PitchFollowFilt_to_HFFilt 0}
		followtoHF1		{Convert_PitchFollowFilt_to_HFFilt 1}
		chantextend		{ChantExtend}
		internaldelay	{InternalDelay}
		multirotate		{MultiRotate}
		cycconcat		{CycConcat}
		stereoreveal	{StereoReveal}
		listloudest		{ListLoudestChannels}
		playvbankchord	{PlayVbankChord}
		presort			{PreSortTexts}
		selectstarred	{SelectStarredTexts}
		generatephrases	{GeneratePhrases}
		conflatetexts	{ConflateTexts}
		mutualeliminate	{MutualEliminationOfTexts}
		invalidchars	{CheckForInvalidCharacters}
		syllablecount	{SyllableCount}
		firstlast		{SameFirstLastWord}
		selectcats		{SelectCategorisedTexts}
		ordertexts		{OrderTexts 0}
		reordertexts	{OrderTexts 1}
		assembletexts	{AssembleTexts}
		dblfilter		{DoubleFilter}
		chanpairextract {ChanPairExtract}
		pairphrases		{PairPhrases}
		pairphrswap		{PairPhraseSwap}
		phraselink		{PhraseLinkage}
		syncfilespad	{SyncFilesPad}
		sliceinsitu		{SliceInSitu}
		doclick			{DoClick}
		eighttoone		{EightToOne}
		eighttoeight	{EightToEight}
		findmatchans	{FindMatchingChannels}
		reformatmchan	{ReFormatMchan}
		dropoutenv		{DropOutEnv}
		distrev			{DistRev}
		fastconv		{FastConvolution}
		xonsets			{ExtractSuddenOnsets}
		timsfilsmix		{TimesFilesToMix}
		replaceallmix	{ReplaceSndsInMixfile}
		efwo			{ExtendFileWithOnsets}
		onsetstoslice	{OnsetsToSlice}
		cutpeaks		{CutPeaks}
		onsetsequence	{OnsetSequence}
		limiter			{Limiter}
		stereoonleft	{StereoOnLeft}
		compareall		{CompareAll}
	}
}

#-------- Repeater strategy on Music Testbed

proc SetTestbed {str} {
	global testbedcmd ww

	set testbedcmd $str

	switch -- $testbedcmd {
		findpmarks	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Find Files With Specified Pitch Marks" }
		dopmarks	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Or Edit Pitch Marks" }
		compmarks	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Compare Two Pitch Marks" }
		allpmarks	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Compare Pmark With All Pmarks" }
		delpmarks	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Pitch Mark (!!)" 	}
		doprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort/Select By Properties" }
		addprops	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add New Property With Vals For Some Snds" }
		addpropsx	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Set Null Property Val For Some Snds" }
		remprops	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Remove An Entire Property" }
		mtprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add New (Empty) Prop To All Files" }
		vecprops	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Vectored Prop To All Files" }
		dsprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Merge Prop Tables: Different Sounds" }
		isprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Merge Prop Tables: Identical Sounds" }
		mergmanypr	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Merge Many Property Tables"}
		sndpropsw	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get All Sounds In Props Table To Workspace" }
		sndprops	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get All Sounds In Props Table To Chosen List" }
		showprops	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort/Select Selected Snds By Properties" }
		proptoorc	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Snds In Props Table To Soundlist Of Same Name" }
		textpex		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Extract Snd Name And Text Prop" }
		propsstats	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Statistics On Prop Value In Props File(s)" }
		propsgather	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Gather Sounds With Propval To New Propfile" }
		propscount	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "How Many Sounds In Props File ?" }
		selbkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Selected Wkspace Files To Blist" }
		allbkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "All Workspace Files To Blist" }
		chosbkgd	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Chosen Files To Blist" }
		chosbkgd_dup { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Chosen Files To Blist: Duplicate If Ness" }
		dirbkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Directory Listing Files To Blist" }
		seebkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "See/Play/Edit A B-List" }
		checkbkgd	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Check B-Lists Are Distinct" }
		renamebkgd	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Rename A B-List" }
		desbkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Destroy A Named B-List" }
		delbkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete All B-Lists (!!!)" }
		pmbkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create/Edit/Delete Pitchmarks" }
		hibkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Hilite All / Compare Two Pitchmarks" }
		combkgd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Compare  Pitchmark With All Pitchmarks" }
		workpad		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Music Workpad" }
		wkrepl		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Replace Workspace By Blist" }
		wkadd		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Blist Files To Workspace" }
		wksel		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Selected Blist Files To Workspace" }
		tochos		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Blist Files To Chosen Files List" }
		tochosel	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Selected Blist Files To Chosen List" }
		remlast		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Clear Wkspace Of Last Load From Blist" }
		remlastall	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Clear All Wksp Files In Last Blist Loaded" }
		remacc		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Clear All Wksp Files In Last Blist Used" }
		rembl		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Clear All Wksp Files In Specified Blist" }
		skwk		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get Files For Score From Workspace" }
		skch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get Chosen List Files To Score" }
		skdir		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get Files For Score From Directory Listing" }
		sklist		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get Files For Score From List In Textfile" }
		skmix		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get Files For Score From Mixfile" }
		skorg1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create New Score With Selected Wkspace Files" }
		skorg0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Continue Organizing Sounds On A Sketch Score" }
		skorg-1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Load A Named Sketch Score" }
		skrefr		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Refresh All Score Files" }
		skrede		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Destroy a Named Score" }
		interp		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interpolation Workshop" }
		addhead		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Head (Wksp Sndfiles)" }
		addtail		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Tail (Wksp Sndfiles)" }
		addat		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Seg At Character (Wksp Sndfiles)" }
		addatseg	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Seg After Seg N (Wksp Snds)" }
		headtail	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Head To Tail (Wksp Sndfiles)" }
		tailhead	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Tail To Head (Wksp Sndfiles)" }
		swapseg		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Swap Segments (Wksp Sndfiles)" }
		reverse		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reverse Order Segments (Wksp Sndfiles)" }
		delhead		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Head (Wksp Sndfiles)" }
		deltail		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Tail (Wksp Sndfiles)" }
		delseg		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Segment (Wksp Sndfiles)" }
		all_addhead	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Head (All Wksp Files)" }
		all_addtail	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Tail (All Wksp Files)" }
		all_addat	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Seg At Character (All Wksp Files)" }
		all_addatseg { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Seg After Seg (All Wksp Files)" }
		all_headtail { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Head To Tail (All Wksp Files)" }
		all_tailhead { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Tail To Head (All Wksp Files)" }
		all_swapseg	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Swap Segments (All Wksp Files)" }
		all_reverse	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reverse Order Segments (All Wksp Files)" }
		all_delhead	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Head (All Wksp Files)" }
		all_deltail	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Tail (All Wksp Files)" }
		all_delseg	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Segment (All Wksp Files)" }
		alphabet	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Seg Alphabetic (Wksp Sndfiles)" }
		startcons	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Start Cons (Wksp Sndfiles)" }
		endcons		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort End Cons (Wksp Sndfiles)" }
		vowel		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Vowel (Wksp Sndfiles)" }
		number		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Numeric (Wksp Sndfiles)" }
		pclass		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Pitch-Class (Wksp Sndfiles)" }
		entire		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Basic Filename (Wksp Sndfiles)" }
 		all_alphabet { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Seg Alphabetic (All Wksp Files)" }
		all_startcons { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Start Cons (All Wksp Files)" }
		all_endcons	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort End Cons (All Wksp Files)" }
		all_vowel	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Vowel (All Wksp Files)" }
		all_number	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Numeric (All Wksp Files)" }
		all_pclass	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Pitch-Class (All Wksp Files)" }
		all_entire	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Basic Filename (All Wksp Files)" }

		addhead_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Head (Chosen Sndfiles)" }
		addtail_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Tail (Chosen Sndfiles)" }
		addat_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Seg At Character (Chosen Sndfiles)" }
		addatseg_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Seg After Seg (Chosen Sndfiles)" }
		headtail_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Head To Tail (Chosen Sndfiles)" }
		tailhead_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Tail To Head (Chosen Sndfiles)" }
		swapseg_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Swap Segments (Chosen Sndfiles)" }
		reverse_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reverse Segment Order (Chosen Sndfiles)" }
		delhead_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Head (Chosen Sndfiles)" }
		deltail_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Tail (Chosen Sndfiles)" }
		delseg_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Segment (Chosen Sndfiles)" }
		all_addhead_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Head (All Chosen Files)" }
		all_addtail_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Tail (All Chosen Files)" }
		all_addat_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Seg At Character (All Chosen Files)" }
		all_addatseg_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add Seg After Seg (All Chosen Files)" }
		all_headtail_ch { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Head To Tail (All Chosen Files)" }
		all_tailhead_ch { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Tail To Head (All Chosen Files)" }
		all_swapseg_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Swap Segments (All Chosen Files)" }
		all_reverse_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reverse Segment Order (All Chosen Files)" }
		all_delhead_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Head (All Chosen Files)" }
		all_deltail_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Tail (All Chosen Files)" }
		all_delseg_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Segment (All Chosen Files)" }
		alphabet_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Seg Alphabetic (Chosen Sndfiles)" }
		startcons_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Start Cons (Chosen Sndfiles)" }
		endcons_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort End Cons (Chosen Sndfiles)" }
		vowel_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Vowel (Chosen Sndfiles)" }
		number_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Numeric (Chosen Sndfiles)" }
		pclass_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Pitch-Class (Chosen Sndfiles)" }
		entire_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Basic Filename (Chosen Sndfiles)" }
		all_alphabet_ch { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Seg Alphabetic (All Chosen Files)" }
		all_startcons_ch { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Start Cons (All Chosen Files)" }
		all_endcons_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort End Cons (All Chosen Files)" }
		all_vowel_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Vowel (All Chosen Files)" }
		all_number_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Numeric (All Chosen Files)" }
		all_pclass_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Pitch-Class (All Chosen Files)" }
		all_entire_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Basic Filename (All Chosen Files)" }
		ialphabet_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Seg Alphabetic (Chosen Sndfiles)" }
		istartcons_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Start Cons (Chosen Sndfiles)" }
		iendcons_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf End Cons (Chosen Sndfiles)" }
		ivowel_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Vowel (Chosen Sndfiles)" }
		inumber_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Numeric (Chosen Sndfiles)" }
		ipclass_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Pitch-Class (Chosen Sndfiles)" }
		ientire_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Basic Filename (Chosen Sndfiles)" }
		all_ialphabet_ch { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Seg Alphabetic (All Chosen Files)" }
		all_istartcons_ch { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Start Cons (All Chosen Files)" }
		all_iendcons_ch { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf End Cons (All Chosen Files)" }
		all_ivowel_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Vowel (All Chosen Files)" }
		all_inumber_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Numeric (All Chosen Files)" }
		all_ipclass_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Pitch-Class (All Chosen Files)" }
		all_ientire_ch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Interleaf Basic Filename (All Chosen Files)" }
		alphabet_r		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each Snd By Seg Alphabetic Grouping" }
		startcons_r		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each Snd By Start Cons Grouping" }
		endcons_r		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each Snd By End Cons Grouping" }
		vowel_r			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each Snd By Vowel Grouping" }
		number_r		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each Snd By Numeric Grouping" }
		pclass_r		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each Snd By Pitch-Class Grouping" }
		alphabet_rall	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each By Seg Alphabetic Grouping" }
		startcons_rall	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each By Start Cons Grouping" }
		endcons_rall	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each By End Cons Grouping" }
		vowel_rall		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each By Vowel Grouping" }
		number_rall		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each By Numeric Grouping" }
		pclass_rall		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Equal No Each Snd By Pitch-Class Grouping" }
		substitute		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Change Segment In Every Nth" }
		getsegs			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get Seg From Each Nth Selected File (Wksp)" }
		getsegs_ch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Get Seg From Each Nth Chosenlist File" }
		delsegval		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Change Chosen Files With Specific Seg Value" }
		newprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Start A New Property Table" }
		sndtoprop		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add New Sounds With Empty Properties" }
		knownprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "List Known Property Tables" }
		sndsinprop		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Are Selected Sndfiles In Props Table?" }
		ppartition		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play And Partition Selected Files"}
		pswap			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play And Swap Files Between Lists"}
		harmony			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Tonal Harmony Workshop"}
		nharmony		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Free Harmony Workshop"}
		timeline		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Timeline"}
		spacedesign		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Space Design"}
		spacmonmix		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Spatialise Mono Mix"}
		keyboard		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Keyboard to Midi Sequence"}
		shmotif			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Show Motifs"}
		delmtf0			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete Motifs"}
		delmtf1			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Delete All Existing Motif Markers"}
		melfix			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Timed Midi Data Workshop"}
		frqexmidi		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Pitch Data -> Vocal-Range Midi"}
		cleank			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Cleaning Kit"}
		proptab			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Display Properties Table"}
		features		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Feature Extraction"}
		correctpitch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Smooth : Correct Text Pitchdata"}
		bulkpitch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Bulk Pitch Extraction (As Text)"}
		massign			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Associate Tempered Pitch Line With Sound"}
		miditrim		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Trim Range Of Midi Pitchdata"}
		midibrkseq010	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Frq Brkpnt --> Fixed Level Midi Seq (C60)"}
		midibrkseq110	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Midi Sequence (C60) --> Frq Brkpnt"}
		midibrkseq101	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Midi Sequence (C60) --> Varibank Filter Data"}
		midibrkseq011	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Frq Brkpnt --> Varibank Midi Filter Data"}
		evffad			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Pitched Analysis Data --> Varibank Filter Data"}
		avfdtpos		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Adjust Varibank Filter Data To Pitch Of Sound"}
		seqshift		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Frq Brkpnt --> Fixed Level CDP Seq (C60)"}
		seqpk			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Frq Brkpnt+Peaks --> CDP Sequence (C60)"}
		mstandard0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Frq Brkpnt+Peaks --> Standard Midi"}
		mstandard1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Frq Brkpnt+Peaks --> Midi,Staccato"}
		globprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Globally Change A Property Value"}
		namprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Change A Property Name"}
		propnsort		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Numerically Order Sndfiles In Propfile"}
		propnudir		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Change Directory Of All Snds (Propfile)"}
		proprenum		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Renumber Sndfiles In Propfile"}
		proppush		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Push Down All Props From Line N By M"}
		propreorder		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reorder Property Columns In Propfile"}
		propsndorder	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reorder Property Rows In Propfile"}
		propsndrename	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Rename All Sounds In Propfile"}
		sameprops		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Add The Same Property Value To All Files"}
		propsremove		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Remove Sounds From Property File"}
		exrhythm		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Rhythm Extract"}
		rhshrink		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "contract Events But Retain Rhythm"}
		mmtrim			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync Sound To MM By Editing"}
		mmtrimnew		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync Sound To A Rhythm By Editing"}
		evemph			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Emphasize Specified Events"}
		isopeak			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Emphasize Peak(s)"}
		matchiso		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Match Levels Of Isolated Events"}
		sndtomx9		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Replace All Sndfiles In Mixfile"}
		datawarp		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Warp Timedata In Mix, Brk Or List"}
		isolator0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Isolate Events To Sndfile"}
		isolator1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Isolate Events To Mixfile"}
		speciso			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Isolate Events By Spectral Analysis"}
		syncmarks0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync File2 To File1 At Timemark(s)"}
		syncmarks1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync File To Pulse At Timemarks"}
		syncmarks2		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync File To Rhythm At Timemarks"}
		syncmarks3		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync File To Timecues At Timemarks"}
		syncmarks4		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Copy Timemarks To Other Files"}
		syncmarks5		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Give Tmark File 3 To 2 & Sync 2 To 1"}
		syncmarks6		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Assign Timemarks To File And Save"}
		syncmult		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync Many Files To File1 At Timemark(s)"}
		syncmix			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync Mixfile Times To Rhythm"}
		timecues		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Timecues"}
		syncpch0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Transpose Files To 1st, At Timemarks"}
		syncpch1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Transpose Files To 1st & Sync At Timemarks"}
		synlev			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "List (Normalised) Peaks At Timemarks"}
		madjusthf0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Adjust Snd Pitch Using Associated Line"}
		madjusthf1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Adjust Pitchline To Harmonic Field & Warp Snd"}
		cutspecp		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Cut Specifically-Pitched Segs From Soundset"}
		isopitch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Isolate Specifically-Pitched Segs In Sounds"}
		textstats		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stats On \"Text\" Prop : Words & Phrases"}
		textrhyme		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stats On \"Text\" Prop : Rhyme"}
		textstarts		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stats On \"Text\" Prop : Word Starts"}
		textasson		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stats On \"Text\" Prop : Consonants"}
		rhymeas			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stats On \"Text\" Prop : See Assigned Rhymes"}
		fofex			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "FOFs Extract For Reconstruction"}
		fofex1			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Single FOF(Group) Extract"}
		fofreco			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "FOF Reconstruction"}
		canon			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Canonic Mix From 'Motif' Prop"}
		midipspec		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Sample In Sequence: Specify Pitch"}
		midifpoll0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Poll Midi Filters: Ignore Durations"}
		midifpoll1      { $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Poll Midi Filters: Weigh Durations"}
		midifdiv		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Divide Midi Filter To Subfilters"}
		relseq			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sequencer Files Related To Sndfiles"}
		relflt			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Filter Files Related To Sndfiles"}
		relpch			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Pitch Files Related To Sndfiles"}
		taenv			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Smooth Sound Loudness"}
		restail			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Reverb On Sound Tail"}
		mrestail		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reverb On Multichan Sound Tail"}
		revstereo		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Stereo Reverb"}
		bytetyb			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Byte Reversal"}
		thumbmake		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Make Mono Thumbnail Of Multichan Sound"}
		thumbkill		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Destroy Thumbnail Of Multichan Sound(s)"}
		thumbsee		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "See (Edit) All Thumbnails"}
		thumbpurge		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Find (Remove) Redundant Thumbnails"}
		playchan		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Single Channels Of Multichan File"}
		slistcomp		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Compare Soundlists"}
		slistsort		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Soundlist By Directory"}
		slistmix		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Mix Cyclically From Mono Soundlists"}
		findrhyme		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Find Items From Property Rhyme Statistics"}
		findwstts		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Find Items From Property Wordstarts Statistics"}
		mch_shred		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Multichannel Shred"}
		mch_zig			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Multichannel Zigzag"}
		mch_iter		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Multichannel Iterate"}
		mchxstereo		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Extract Stereos From Multichannel"}
		stereoinmch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Inject Stereos Into Multichannel"}
		stereorand		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Randorient Stereopans In Multichan"}
		stereomulti		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Place Stereo Snd In Multichan Space"}
		stereopanmch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Pan Stereo Round Multichannel Space"}
		stereorotmch	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Rotate Stereo+ Round Multichannel Space"}
		stereotomch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Convert Stereo Mixfile To Multichannel"}
		monotomch		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Convert Mono Soundfile To Multichannel"}
		fadein			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Fade In Beyond Start"}
		maxsnd			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Max & Min Amongst All Sounds"}
		rearrange		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Rearrange A Soundfile"}
		mchactive		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Find Or Remove Empty Channels"}
		mchengineer		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Multichannel Engineering"}
		permchunks		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Random Perm Chunks Of Files"}
		mchtostereo		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Multichannel Sound To Stereo"}
		mchtostereo2	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Multichan Sound Select To Stereo"}
		playgroups0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Groups Sequentially"}
		playgroups1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Groups Multichannel"}
		playpm			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Part Of Multichan Snd"}
		playch			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Single Channel Of Snd"}
		playchwide		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Stereo In Wide Multichan"}
		kmonotonmulti	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "K Mono Sndfiles In An N-Channel Ring"}
		multitransfer	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Transfer Times From 1st Mixfile To 2nd"}
		specav			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Spectral Average Or Movies ($)"}
		fpartition		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Filter Partition"	}
		fractals		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Generate Fractals"}
		gpfilter		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Filter A Sequence"}
		varibox			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Varibox"}
		varispec		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Varispec"}
		multistack		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stack Transposed Multichan Copies"}
		sidebyside		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Files Side-by-Side In Multichan Mix"}
		monoinject		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Place Mono/Stereo File In Multichan Space"}
		rezig			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Related Zigzags"}
		dopplerpan		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Doppler Pan"}
		transposset		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Set Of Semitone-Transposed Copies"}
		mchrandrotate	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Random Rotations Of Several Mono Srcs"}
		mchranddrift	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Random Drift Of Several Mono Srcs"}
		genspecfilt		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Generate Spectra By Filtering"}
		modspecfilt		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Sounds By Filtering"}
		genspecinterp	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Generate Sounds By Interpolation"}
		genspecstak		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Sounds By Stacking"}
		genspecrev		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Sounds By Reverb"}
		genspecdist		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Sounds By Distortion"}
		genspectrem		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Snds By Trem, Vib Or Accel"}
		genspechsh		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Spectrum By Harmonic Shift"}
		genspecpsh		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Pitch Of Sound"}
		genspecpshset	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Pitches Of Soundset"}
		genspecoct		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Pitch By Octave"}
		genspecmixoct	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Mix Orchestras"}
		genspectstr		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Sound By Timestretch"}
		genspectshr		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Sound By Timeshrink"}
		genspectrim		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Sound By Endtrim"}
		genspectrimset	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Trim Ends Of Soundset"}
		genspectstrs	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stretch Durations Of Soundset"}
		genspectshrs	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Shrink Durations Of Soundset"}
		genspectrems	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Set By Trem, Vib Or Accel"}
		genspectrin		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Cut And Normalise"}
		genspectrii		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Modify Sound By Trim"}
		genspecmixoctst	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Merge Mono Orchestras To Stereo"}
		stirmix			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stereo Interleave Rotate In Multichan Mix"}
		stereowrap		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stereo Wraparound In 3 Chan Surround"}
		tuneset			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Tune Whole-Sounds To Given Tuning Set"}
		combopmarks		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Display Harmonic Set Of All Pmarks"}
		sortpmarks		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sort Into Descending Pitchmark Order"}
		inspmarks0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Highlight Files In Harmonic Set"}
		inspmarks1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Highlight Files In Harmonic Field"}
		mchshrink		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Shrink/Expand Space Of Multichan"}
		tuneadj			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Adjust Name Of File Having Pitch-In-Name"}
		extracthf		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Extract/Apply Average Or Time-Varying Harmonic Field"}
		contract		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Internally Contract"}
		mch2tomix		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Multichan Mix To Standard Mixfile"}
		nessscores		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "List Physical Modelling Scores"}
		nessinstrs		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "List Physical Modelling Instruments"}
		nessrefresh		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Refresh Physical Modelling Data"}
		nessprofile		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Profile Of Brass Instrument : View/Edit"}
		nessprofile0	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Profile Of Brass Instrument : Create"}
		nessscore		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Score For Brass Instrument : View/Edit"}
		nessscore0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Score For Brass Instrument : Create"}
		datasort		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Length+AlphaSort On 1stWord Of Line"}
		txtbkwdsort		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reversed-Text Word Sort"}
		rhymesort		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Rhyme Sort On List Of Words"}
		darwin			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "See Multisyn Score"}
		darwinplay		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Multisyn Score"}
		reverg			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Reverbd Verges"}
		mixmerge		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Merge Mixfiles"}
		stagger			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Mix With Snd Peaks Staggered"}
		degrade			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Degrade Sound"}
		polyfilter		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Recursive Filtering"}
		transposchord	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Chords From Non-Vocal Sample"}
		overlapslice	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Slice To Overlapping Segments"}
		followtoHF0		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Convert Pitchfollow To HF"}
		followtoHF1		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Convert Pfollow To HF in Key"}
		chantextend		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Join Files In Rand-Permed Sequence"}
		internaldelay	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Internal Stereo Delay"}
		multirotate		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Multilayered Rotations In 8-Chan"}
		cycconcat		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Cyclically Concatenate"}
		stereoreveal	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stereo Reveal Mono->Stereo->Mono"}
		listloudest		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Loudest Channel For Each Snd In List"}
		playvbankchord	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Play Fixed-Harmony MIDI Varibank Data"}
		presort			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Alphabetic Sort & Remove Duplicates"}
		selectstarred	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Mark & Extract Items From Texts List"}
		generatephrases	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Generate Phrases From Wordlists"}
		conflatetexts	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Conflate (& Possibly Re-Sort) Textlines In Files"}
		mutualeliminate	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Eliminate Texts Common To Different Files"}
		invalidchars	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Check Bad Chars In Non-Grabbed Textfile"}
		syllablecount	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Count Syllables : Assess Spoken Duration"}
		firstlast		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Find Repeated Words : Partition Texts To Files"}
		selectcats		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Categorise & Extract Items From Texts List"}
		ordertexts		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Specify Order & Reorder Texts In A Texts List"}
		reordertexts	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reorder Pre-Numbered Texts"}
		assembletexts	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Assemble Text-Lines To A Continuous Text"}
		dblfilter		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Recursively Filter"}
		chanpairextract	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Extract Channel Pair"}
		pairphrases		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Group Phrases From Two Or More Textfiles"}
		pairphrswap		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Swap Paired Phrases"}
		phraselink		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Link Paired Phrases"}
		syncfilespad	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Sync Files To Timemarks By Silencepads"}
		sliceinsitu		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Slice For Processing In Situ"}
		doclick			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Click Track Over Sound Or From Textlist"}
		eighttoone		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Pan 8-Chans Gradually Into 1"}
		eighttoeight	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Rearrange Channels"}
		findmatchans	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Find Any Matching Channels"}
		reformatmchan	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Reformat To 8-Channel Ring"}
		dropoutenv		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Dropout In Sound"}
		distrev			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Distort Reverb"}
		fastconv		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Fast Convolution"}
		xonsets			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "List Sudden Onsets In Sound"}
		timsfilsmix		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Create Mix From Sndfiles And Onset-List"}
		replaceallmix	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Replace All Sounds In Mixfile"}
		efwo			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Extend By Rand-Permuting Slices Within"}
		onsetstoslice	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Convert Onset-List To Edit-Slices-List"}
		cutpeaks		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Remove (Cut Out) Loud Peaks In Sound"}
		onsetsequence	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "List Onset Sequence Of Channels"}
		limiter			{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Apply Limiter"}
		stereoonleft	{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Stereo To \"Stereo\" On Left Or Right"}
		compareall		{ $ww.1.a.mez.bkgd.menu entryconfig 2 -label "Compare Several Soundfiles"}
	}
	$ww.1.a.mez.bkgd.menu entryconfig 2 -command TestbedAgain
}

# listing = wl (workspace), ch (chosenfile list),
#				tabed.bot.itframe.l.list (table_editor input table), tabed.bot.icframe.l.list (table_editor input column)
# outtyp  = sort,interleave,reduce
# sorttyp = all,alphabet,vowel,startcons,endcons,numeric,pitchclass
# sndonly = only on soundfiles

#----- Perform various sorts on filenames, from various sources.

proc SortFilenames {listing sorttyp sndonly outtyp} {
	global pr_sortonsegs evv segsortno specialchar wl ch dupl_mix dupl_vbx dupl_txt 
	
	if {($listing == $ch) && (($outtyp == "reduce") || ($outtyp == "interleave")) && ($dupl_mix || $dupl_vbx || $dupl_txt)} {
		Inf "Duplicates On Chosen Files List: Cannot Proceed"
		return
	}
	if {$listing == $wl} {
		set ilist [$listing curselection]
	} else {
		set ilist {}
		set j [$listing index end]
		set i 0
		while {$i < $j} {
			lappend ilist $i
			incr i
		}
	}
	if {[llength $ilist] <= 0} {
		Inf "No Files Selected"
		return 0
	}
	;# CODE CHECKS
	if {($listing == $wl) && ($outtyp != "sort")} {
		Inf "Invalid Operation On Workspace"
		return 0
	}

	if {$sndonly} {
		set ilist [GetOnlySnds $ilist $listing 0]
		if {[llength $ilist] <= 0} {
			return 0
		}
	}
	if {$sorttyp == "all"} {
		set segsortno 0
		set returnval [Sort_Filenames $listing $ilist $sorttyp $segsortno $outtyp]
	} else {
		set returnval 0
		set f .segsort
		if [Dlg_Create $f "SORT FILENAMES" "set pr_sortonsegs 0" -borderwidth $evv(BBDR)] {
			frame $f.0 -borderwidth $evv(BBDR)
			frame $f.1 -borderwidth $evv(BBDR)
			frame $f.2 -borderwidth $evv(BBDR)
			frame $f.3 -borderwidth $evv(BBDR)
			frame $f.4 -borderwidth $evv(BBDR)
			frame $f.5 -borderwidth $evv(BBDR)
			button $f.0.add -text "DO SORT" -command {set pr_sortonsegs 1} -highlightbackground [option get . background {}]
			button $f.0.q -text "ABANDON" -command {set pr_sortonsegs 0} -highlightbackground [option get . background {}]
			pack $f.0.add -side left
			pack $f.0.q -side right
			label $f.1.ll -text "SEGMENT TO SORT ON"
			pack $f.1.ll -side left
			radiobutton $f.2.b1 -text "1" -width 8 -variable segsortno -value 1  
			radiobutton $f.2.b2 -text "2" -width 8 -variable segsortno -value 2
			radiobutton $f.2.b3 -text "3" -width 8 -variable segsortno -value 3
			radiobutton $f.2.b4 -text "4" -width 8 -variable segsortno -value 4
			radiobutton $f.2.b5 -text "5" -width 8 -variable segsortno -value 5
			radiobutton $f.3.b6 -text "6" -width 8 -variable segsortno -value 6
			radiobutton $f.3.b7 -text "7" -width 8 -variable segsortno -value 7
			radiobutton $f.3.b8 -text "8" -width 8 -variable segsortno -value 8
			radiobutton $f.3.b9 -text "9" -width 8 -variable segsortno -value 9
			radiobutton $f.3.b10 -text "10" -width 8 -variable segsortno -value 10
			radiobutton $f.4.b11 -text "11" -width 8 -variable segsortno -value 11 
			radiobutton $f.4.b12 -text "12" -width 8 -variable segsortno -value 12  
			radiobutton $f.4.b13 -text "13" -width 8 -variable segsortno -value 13
			radiobutton $f.4.b14 -text "14" -width 8 -variable segsortno -value 14
			radiobutton $f.4.b15 -text "15" -width 8 -variable segsortno -value 15
			radiobutton $f.5.b16 -text "Last" -width 8 -variable segsortno -value -1

			pack $f.2.b1 $f.2.b2 $f.2.b3 $f.2.b4 $f.2.b5 -side left
			pack $f.3.b6 $f.3.b7 $f.3.b8 $f.3.b9 $f.3.b10 -side left
			pack $f.4.b11 $f.4.b12 $f.4.b13 $f.4.b14 $f.4.b15 -side left
			pack $f.5.b16 -side left

			pack $f.0 $f.1 $f.2 $f.3 $f.4 $f.5 -side top -fill x -expand true
			set segsortno 1
			bind $f <Return> {set pr_sortonsegs 1}
			bind $f <Escape> {set pr_sortonsegs 0}
		}
		raise $f
		set pr_sortonsegs 0
		My_Grab 0 $f pr_sortonsegs
		tkwait variable pr_sortonsegs
		if {$pr_sortonsegs} {
			set returnval [Sort_Filenames $listing $ilist $sorttyp $segsortno $outtyp]
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	}
	return $returnval
}

#------ Fundamental sort routine for filenames

proc Sort_Filenames {listing ilist sorttyp segsortno outtyp} {
	global wl ch chlist insitu tabed

	# segsort 0     = whole name
	# segsort 1     = special case, first seg
	# segsort -1    = special case, last seg
	# segsort other = find seg

	;# inname list = 0 origname, 1 rootname, 2 segment_to_sort_on
	
	;# STORE FILE INFO, CHECK SEGMENT EXISTS, AND STORE IT WITH FILENAME

	if {![info exists tabed]} {
		set tabed dummy
	}
	foreach i $ilist {
		set fnam [$listing get $i]		
		set inname $fnam
		set basename [file rootname [file tail $fnam]]
		lappend inname $basename
		if {$segsortno == 0} {
			set sortstr $basename
		} else {
			set separatorlist [CheckSegmentation $basename 1]
			set separatorcnt [llength $separatorlist]
			if {$separatorcnt == 0} {	;# Name is not segmented (properly)
				return 0
			}
			switch -- $segsortno {			
				"-1" {	;# LAST SEGMENT
					set k [lindex $separatorlist end]
					incr k
					set sortstr [string range $basename $k end] ;# From separator to end

				}
				"1" {	;# FIRST SEGMENT
					set k [lindex $separatorlist 0]
					incr k -1
					set sortstr [string range $basename 0 $k]	;# From start to separator
				}
				default {	;# SEGNO > 1
					if {$segsortno > [expr $separatorcnt + 1]} { ;# 1 more segment than separator
						Inf "Insufficient Segments In Name '$basename'"
						return 0
					}
					set separatorno [expr $segsortno - 2]	;#	segsortno cnts from 1: but indexing of segs from zero: 
															;#	so segsortno-index is -1
															;#	AND we're looking for the separator 1 BEFORE the segment, so another -1
					set j [lindex $separatorlist $separatorno]
					incr j
					incr separatorno
					if {$separatorno >= $separatorcnt} {
						set sortstr [string range $basename $j end] ;# From separator to end
					} else {
						set k [lindex $separatorlist $separatorno]
						incr k -1
						set sortstr [string range $basename $j $k]		;# From 1st separator to 2nd separator
					}
				}
			}
		}
		set len [string length $sortstr]
		switch -- $sorttyp {	;#	SET UP THE APPROPRIATE SORTSTR
			"all" {
				;# USES ENTIRE sortstr
			}
			"alphabet" {
				catch {unset vs}
				catch {unset ve}
				set k 0
				while {$k < $len} {
					if {![info exists vs]} {
						if {[IsAlpha [string index $sortstr $k]]} {
							set vs $k
						}
					} elseif {![IsAlpha [string index $sortstr $k]]} {
						set ve $k
						incr ve -1
						break
					}
					incr k
				}
				if {![info exists vs]} {
					Inf "There Is No Alphabetic Data In Segment '$sortstr' Of Filename '$basename'"
					return 0
				}
				if {![info exists ve]} {
					incr k -1
					set ve $k
				}
				set sortstr [string range $sortstr $vs $ve]
			}
			"vowel" {
				catch {unset vs}
				catch {unset ve}
				set k 0
				while {$k < $len} {
					if {![info exists vs]} {
						if {[IsVowel [string index $sortstr $k]]} {
							set vs $k
						}
					} elseif {![IsVowel [string index $sortstr $k]]} {
						set ve $k
						incr ve -1
						break
					}
					incr k
				}
				if {![info exists vs]} {
					Inf "There Is No Vowel In Segment '$sortstr' Of Filename '$basename'"
					return 0
				}
				if {![info exists ve]} {
					incr k -1
					set ve $k
				}
				set sortstr [string range $sortstr $vs $ve]
			}
			"startcons" {
				catch {unset cs}
				catch {unset ce}
				set k 0
				while {$k < $len} {
					set char [string index $sortstr $k]
					if {![info exists cs]} {
						if {[IsCons $char]} {
							set cs $k
						} elseif {[IsAlpha $char] && ![IsCons $char]} {
							Inf "Alphabetic Part Does Not Start With Consonant In Segment '$sortstr' Of Filename '$basename'"
							return 0
						}
					} elseif {![IsCons $char]} {
						set ce $k
						break
					}
					incr k
				}
				if {![info exists cs]} {
					Inf "There Is No Start Consonant In Segment '$sortstr' Of Filename '$basename'"
					return 0
				}
				if {![info exists ce]} {
					set ce $k
				}
				incr ce -1
				set sortstr [string range $sortstr $cs $ce]
			}
			"endcons" {
				catch {unset cs}
				catch {unset ce}
				set k $len
				incr k -1
				while {$k >= 0} {
					set char [string index $sortstr $k]
					if {![info exists ce]} {
						if {[IsCons $char]} {
							set ce $k
						} elseif {[IsAlpha $char] && ![IsCons $char]} {
							Inf "Alphabetic Part Does Not End With Consonant In Segment '$sortstr' Of Filename '$basename'"
							return 0
						}
					} elseif {![IsCons $char]} {
						set cs $k
						break
					}
					incr k -1
				}
				if {![info exists ce]} {
					Inf "There Is No End Consonant In Segment '$sortstr' Of Filename '$basename'"
					return 0
				}
				if {![info exists cs]} {
					set cs $k
				}
				incr cs
				set sortstr [string range $sortstr $cs $ce]
			}
			"numeric" -
			"pitchclass" {
				catch {unset vs}
				catch {unset ve}
				set k 0
				while {$k < $len} {
					if {![info exists vs]} {
						if {[IsNumchar [string index $sortstr $k]]} {
							set vs $k
						}
					} elseif {![IsNumchar [string index $sortstr $k]]} {
						set ve $k
						break
					}
					incr k
				}
				if {![info exists vs]} {
					Inf "There Is No Numeric Value '$sortstr' Of Filename '$basename'"
					return 0
				}
				if {![info exists ve]} {
					set ve $k
				}
				incr ve -1
				set sortstr [string range $sortstr $vs $ve]
				set sortstr [ConvertChars $sortstr]
				if {![IsNumeric $sortstr]} {
					Inf "Value Generated ($sortstr) From Filename '$basename' Is Not Numeric"
					return 0
				}
				if {$sorttyp == "pitchclass"} {
					set sortstr [expr $sortstr % 12]
				}
			}
		}
		lappend inname $sortstr
		lappend innames $inname
	}			
	;# SORT ORIGINAL FILENAMES INTO SETS, EACH SET WITH NAME OF SORTSTRING
	catch {unset gp}
	foreach inname $innames {
		set str [lindex $inname 2]
		if {[info exists gp($str)]} {
			lappend gp($str) [lindex $inname 0]
		} else { 
			set gp($str) [lindex $inname 0]
		}
	}
	;# LIST NAMES OF SETS
	foreach gpname [array names gp] {
		lappend gplist $gpname
	}
	;# SORT NAMES OF SETS, EITHER ALPHABETICALLY OR NUMERICALLY
	set len [llength $gplist]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set name_n [lindex $gplist $n]
		set m $n
		incr m
		while {$m < $len} {
			set name_m [lindex $gplist $m]
			set doswap 0
			switch -- $sorttyp {
				"all" -
				"alphabet" -
				"vowel" -
				"startcons" -
				"endcons" {
					if {[string compare $name_m $name_n] < 0} {
						set doswap 1
					}
				}
				"numeric" -
				"pitchclass" {
					if {$name_m < $name_n} {
						set doswap 1
					}
				}
			}
			if {$doswap} {
				set gplist [lreplace $gplist $m $m $name_n]
				set gplist [lreplace $gplist $n $n $name_m]
				set name_n $name_m
			}
			incr m
		}
		incr n
	}
	catch {unset nufnamslist}
	;# EXTRACT FILENAMES FROM SETS IN THE APPROPRIATE ORDER
	switch -- $outtyp {
		"interleave" -
		"reduce" {
			set minlen 1000000
			foreach gpname $gplist {
				set len [llength $gp($gpname)]
				if {$len < $minlen} {
					set minlen $len
				}
			}
			if {$outtyp == "interleave"} { 
				set n 0
				while {$n < $minlen} {
					foreach gpname $gplist {	;# FROM EACH SET (NOW IN THE CORRECT ORDER) EXTRACT ONE SOUNDFILE
						lappend nufnamslist [lindex $gp($gpname) $n]
					}
					incr n						;# DO THIS CYCLICALLY, UNTIL SMALLEST SET IS EXHAUSTED
				}
			} else {
				foreach gpname $gplist {	;# FROM EACH SET (NOW IN THE CORRECT ORDER) IN TURN
					set n 0					;# SELECT THE MAXIMUM NUMBER OF FILES POSSIBLE WITHOUT EXHAUSTING ANY SET	
					while {$n < $minlen} {	
						lappend nufnamslist [lindex $gp($gpname) $n]
						incr n
					}
				}
			}
		}
		"sort" {
			foreach gpname $gplist {		;# FROM EACH SET (NOW IN THE CORRECT ORDER) IN TURN
				foreach fnam $gp($gpname) {	;# EXTRACT ALL THE SOUNDFILES
					lappend nufnamslist $fnam
				}
			}
		}
	}
	switch -regexp -- $listing \
		^$wl$ {	
			foreach i $ilist fnam $nufnamslist {
				$listing delete $i			;#	REORGANISE WORKSPACE LISTING
				$listing insert $i $fnam
			}
		} \
		^$ch$ {	
			foreach i $ilist fnam $nufnamslist {
				$listing delete $i			;#	REORGANISE CHOSEN FILE LISTING
				$listing insert $i $fnam
				set chlist [lreplace $chlist $i $i $fnam]
			}
		} \
		^$tabed.bot.itframe.l.list$ { 
			set outlist $tabed.bot.otframe.l.list
			$outlist delete 0 end			;#	TABLE EDITOR, TABLE INPUT, WRITE NEW LIST TO TABLE OUTPUT
			foreach fnam $nufnamslist {
				$outlist insert end $fnam
			}
		} \
		^$tabed.bot.icframe.l.list$ {
			if {$insitu} {					;#	TABLE EDITOR, COLUMN INPUT, WRITE NEW LIST TO COLUMN INPUT
				set outlist $listing
			} else {						;#	OR TO COLUMN OUTPUT
				set outlist $tabed.bot.ocframe.l.list
			}
			$outlist delete 0 end
			foreach fnam $nufnamslist {
				$outlist insert end $fnam
			}
		}

	return 1
}

#----- Perform various operations on filenames. or files (see below)

proc MassageFilenames {typ sndonly listing} {
	global wl ch chlist chcnt background_listing tabed last_seg_rearrange rememd dupl_mix dupl_vbx dupl_txt

	if {[string match $listing $ch] && ($dupl_mix || $dupl_vbx || $dupl_txt)} {
		Inf "Chosen Files List Contains Duplicates: Cannot Proceed"
		return
	}
	set is_tabed 0
	if {![info exists tabed]} {
		set tabed dummy
	} elseif {($listing != $wl) && ($listing != $ch)} {
		set is_tabed 1
	}
	if {!$is_tabed} {
		if {($typ == "cycfiles") || ($typ == "subfiles") || ($typ == "delfiles")} {
			 if {$listing != $ch} {
				;# CODE CHECK
				Inf "this Option Is Only Accessible From The Chosen Files List"
				return 0
			} elseif {![info exists chlist]} {		;# SAFETY ONLY
				Inf "This Option Is Only Accessible From The Chosen Files List: No Files On Chosen Files List"
				return 0
			}
		}
	}
	if {(($typ == "selfiles") || ($typ == "endnames") || ($typ == "sttnames")) && ($listing == $ch)} {
		;# CODE CHECK
		Inf "This Option Is Not Accessible From The Chosen Files List"
		return 0
	}
	if {($typ == "hiliteseg") && !($listing == $wl)} {
		Inf "This Option Is Only Accessible From The Workspace"
		return 0
	}
	if {($listing == $wl) && ($typ != "selfiles") && ($typ != "endnames") && ($typ != "sttnames") && ($typ != "hiliteseg")} {
		set ilist [$listing curselection]
	} else {
		set ilist {}
		set j [$listing index end]
		set i 0
		while {$i < $j} {
			lappend ilist $i
			incr i
		}
	}
	if {[llength $ilist] <= 0} {
		Inf "No Files Selected"
		return 0
	}
	if {$sndonly} {
		set ilist [GetOnlySnds $ilist $listing $typ]
		if {[llength $ilist] <= 0} {
			return 0
		}
	}
	switch -- $typ {
		"deletehead" {		;#	DELETE FIRST NAME SEGMENT
			set nunames [DeleteNameSeg head $ilist $listing]
		}
		"deletetail" {		;#	DELETE LAST NAME SEGMENT
			set nunames [DeleteNameSeg tail $ilist $listing]
		}
		"deleteseg" {		;#	DELETE SPECIFIC-NUMBER NAME SEGMENT
			set nunames [DeleteNameSegN $ilist $listing]
		}
		"addhead" {			;#	ADD NAME SEGMENT AT START OF NAME
			set nunames [AddNameSeg head $ilist $listing]
		}
		"addtail" {			;#	ADD NAME SEGMENT AT END OF NAME
			set nunames [AddNameSeg tail $ilist $listing]
		}
		"addat" {			;#	ADD NAME SEGMENT AT SPECIFIC-NUMBER CHARACTER
			set nunames [AddNameSeg at $ilist $listing]
		}
		"addatseg" {		;#	ADD NAME SEGMENT AT SPECIFIC-NUMBER NAME SEGMENT
			set nunames [AddNameSeg atseg $ilist $listing]
		}
		"swapsegs" {		;#	SWAP TWO SPECIFIED-NUMBER SEGMENTS
			set nunames [SwapNameSegs $ilist $listing]
		}
		"reverse" {		;#	REVERSE SEGMENT ORDER
			set nunames [ReverseNameSegs $ilist $listing]
		}
		"selfiles" {		;#	SELECT FILES CONTAINING SPECIFIC NAME-SEGMENT
			set nunames [SelSegFiles $ilist $listing]
		}
		"endnames" {		;#	SELECT FILES ENDING WITH SPECIFIED STRING
			set nunames [SelEndNames $ilist $listing]
		}
		"sttnames" {		;#	SELECT FILES STARTING WITH SPECIFIED STRING
			set nunames [SelSttNames $ilist $listing]
		}
		"cycfiles" {		;#	MODIFY NAME SEGMENT IN EVERY Nth FILENAME
			set nunames [CycSegFiles $ilist $listing 0]
		}
		"getsegs" {			;#	GET SPECIFIC-NUMBERED SEGMENT IN EVERY Nth FILENAME
			set nunames [CycSegFiles $ilist $listing 1]
		}
		"subfiles" {		;#	INSERT NEW FILES AT EVERY Nth FILE IN A LISTING
			set nunames [CycSubFiles $ilist $listing 0]
		}
		"delfiles" {		;#	REMOVE EVERY Nth FILE FROM A LISTING
			set nunames [CycSubFiles $ilist $listing 1]
		}
		"getfiles" {		;#	GET EVERY Nth FILE FROM A LISTING
			set nunames [CycSubFiles $ilist $listing -1]
		}
		"delsegval"		{	;#	WORK ON SEGMENTS OF SPECIFIC VALUE
			set nunames [SpecificSegs $ilist $listing]
		}
		"hiliteseg"		{	;#	HILITE WORKSPACE FILES WITH SEGS OF SPECIFIC VALS
			HiliteSegs $ilist $listing
			return 1
		}
		"condsub"		{	;#	WORK ON SEGMENTS OF SPECIFIC VALUE
			set nunames [ConditionalSegmentSubstitution $ilist $listing 0]
		}
		"condsubf"		{	;#	WORK ON SEGMENTS OF SPECIFIC VALUE, CHANGING FILENAME IN PROCESS
			set nunames [ConditionalSegmentSubstitution $ilist $listing 1]
		}
	}
	if {[llength $nunames] <= 0} {
		return 0
	}
	switch -- $typ {
		"selfiles" -
		"sttnames" -
		"endnames" {		;#	OPERATE ON WORKSPACE LISTING ONLY
			$wl selection clear 0 end
			foreach i $nunames {
				$wl selection set $i
			}
			return 0
		}
		"getfiles" {		;#	OPERATES ONTO TABEDITOR COLUMN INPUT LISTING ONLY
			$tabed.bot.icframe.l.list delete 0 end
			foreach item $nunames {
				$tabed.bot.icframe.l.list insert end $item
			}
			return 0
		}
	}
	if {!$is_tabed} {
		switch -- $typ {
			"cycfiles" {
				foreach i $ilist nuname $nunames {
					if {[string match $origfnam $nuname]} {
						continue
					}
					if {[LstIndx $nuname $wl] < 0} {
						if {[FileToWkspace $nuname 0 0 0 0 0] <= 0} {
							return 0
						}
					}
				}
				set bakd_up 0
				foreach i $ilist nuname $nunames {
					set origfnam [$listing get $i]
					if {[string match $origfnam $nuname]} {
						continue
					}
					if {$bakd_up == 0} {
						DoChoiceBak
						set bakd_up 1
					}
					set chlist [lreplace $chlist $i $i $nuname]
					$ch delete $i
					$ch insert $i $nuname
				}
				return 0
			}
			"delsegval" -
			"subfiles" {
				DoChoiceBak
				ClearWkspaceSelectedFiles
				foreach ffnam $nunames {
					if {[LstIndx $ffnam $wl] < 0} {
						if {[FileToWkspace $ffnam 0 0 0 0 0] <= 0} {
							return
						}
					}
					lappend chlist $ffnam		;#	add to end of list
					$ch insert end $ffnam		;#	add to end of display
					incr chcnt
				}
				return 0
			}
			"delfiles" {
				DoChoiceBak
				ClearWkspaceSelectedFiles
				foreach ffnam $nunames {
					lappend chlist $ffnam		;#	add to end of list
					$ch insert end $ffnam		;#	add to end of display
					incr chcnt
				}
				return 0
			}
		}
	}
		
	set ren_blist 0
	switch -regexp -- $listing \
		^$wl$ - \
		^$ch$ {
			catch {unset last_seg_rearrange}
			foreach i $ilist nuname $nunames {
				set origfnam [$listing get $i]
				if {[string match $origfnam $nuname]} {
					continue
				}
				set haspmark [HasPmark $origfnam]
				set hasmmark [HasMmark $origfnam]
				if [catch {file rename $origfnam $nuname} zub] {
					Inf "Cannot Rename File\n$origfnam\nTo\n$nuname"
					continue
				}
				DataManage rename $origfnam $nuname
				lappend couettelist $origfnam $nuname 
				$wl delete $i								
				$wl insert $i $nuname
				catch {unset rememd}
				UpdateChosenFileMemory $origfnam $nuname
				set oldname_pos_on_chosen [LstIndx $origfnam $ch]
				if {$oldname_pos_on_chosen >= 0} {
					RemoveFromChosenlist $origfnam
					set chlist [linsert $chlist $oldname_pos_on_chosen $nuname]
					incr chcnt
					$ch insert $oldname_pos_on_chosen $nuname
				}
				RenameProps	$origfnam $nuname 1				
				DummyHistory $origfnam "RENAMED_$nuname"
				if {$haspmark} {
					MovePmark $origfnam $nuname
				}
				if {$hasmmark} {
					MoveMmark $origfnam $nuname
				}
				if [IsInBlists $origfnam] {
					if [RenameInBlists $origfnam $nuname] {
						set ren_blist 1
					}
				}
				RenameOnDirlist $origfnam $nuname
				set rename_pair [list $origfnam $nuname]
				lappend last_seg_rearrange $rename_pair
			}
			if {$ren_blist} {
				SaveBL $background_listing
			}
		} \
		^$tabed.bot.itframe.l.list$ { 
			set outlist $tabed.bot.otframe.l.list
			$outlist delete 0 end			;#	TABLE EDITOR, TABLE INPUT, WRITE NEW LIST TO TABLE OUTPUT

			catch {unset last_seg_rearrange}
			foreach origfnam $listing nufnam $nunames {
				$outlist insert end $nufnam
				set rename_pair [list $origfnam $nufnam]
				lappend last_seg_rearrange $rename_pair
			}
		} \
		^$tabed.bot.icframe.l.list$ {
			if {$insitu} {					;#	TABLE EDITOR, COLUMN INPUT, WRITE NEW LIST TO COLUMN INPUT
				set outlist $listing
			} else {						;#	OR TO COLUMN OUTPUT
				set outlist $tabed.bot.ocframe.l.list
			}
			catch {unset origfnams}
			catch {unset last_seg_rearrange}
			foreach origfnam $listing {
				lappend origfnams $origfnam
			}
			$outlist delete 0 end
			foreach origfnm $origfnams nufnam $nunames {
				$outlist insert end $nufnam
				set rename_pair [list $origfnam $nufnam]
				lappend last_seg_rearrange $rename_pair
			}
		}

	if {[info exists couettelist]} {
		CouetteManage rename $couettelist
	}
	return 1
}

#---- Swap segments within a filename

proc SwapNameSegs {ilist listing} {
	global pr_namesegs wl ch segswap_a segswap_b example_a example_b new_segmented_names evv wstk

	set segcntmin 10000
	set new_segmented_names {}
	foreach i $ilist {
		set fnam [$listing get $i]
		set inname [file rootname [file tail $fnam]]
		set seglist [CheckSegmentation $inname 1]
		set segcnt [llength $seglist]
		if {$segcnt <= 0} {
			return
		}
		if {$segcnt < $segcntmin} {
			set segcntmin $segcnt
		}
		lappend inname $fnam
		lappend inname $seglist
		lappend innames $inname
	}
	incr segcntmin ;# NO OF SEGMENTS IS ONE MORE THAN NUMBER OF SEPARATORS
	set f .namesegs
	if [Dlg_Create $f "SWAP FILENAME SEGMENTS SEPARATED BY UNDERSCORES" "set pr_namesegs 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		button $f.0.swap -text "SWAP SEGMENTS" -command {set pr_namesegs 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_namesegs 0} -highlightbackground [option get . background {}]
		pack $f.0.swap -side left
		pack $f.0.q -side right
		label $f.1.ll -text "First Segment Number"
		entry $f.1.e -textvariable segswap_a -width 8
		label $f.1.ll2 -text "Second Segment Number"
		entry $f.1.e2 -textvariable segswap_b -width 8
		pack $f.1.ll $f.1.e $f.1.ll2 $f.1.e2 -side left
		label $f.2.ll -text "FOR EXAMPLE"
		pack $f.2.ll -side left
		entry $f.3.e -textvariable example_a -width 32
		label $f.3.ll -text "---->>  Goes To  ---->>"
		entry $f.3.e2 -textvariable example_b -width 32
		pack $f.3.e $f.3.ll $f.3.e2 -side left
		label $f.4.ll -text ""
		pack $f.4.ll -side left
		pack $f.0 $f.1 $f.2 $f.3 $f.4 -side top -fill x -expand true
		bind $f <Return> {set pr_namesegs 1}
		bind $f <Escape> {set pr_namesegs 0}
	}
	$f.3.e config -state normal
	set example_a ""
	$f.3.e config -state disabled
	$f.3.e2 config -state normal
	set example_b ""
	$f.3.e2 config -state disabled

	raise $f
	set pr_namesegs 0
	My_Grab 0 $f pr_namesegs $f.1.e 
	set finished 0 
	while {!$finished} {
		tkwait variable pr_namesegs
		if {$pr_namesegs} {
			if {![regexp {^[0-9]+$} $segswap_a] || ($segswap_a < 1) || ($segswap_a > $segcntmin)} {
				Inf "Invalid Value For First Segment (Range: 1 to $segcntmin)"
				continue
			}
			if {![regexp {^[0-9]+$} $segswap_b] || ($segswap_b < 1) || ($segswap_b > $segcntmin)} {
				Inf "Invalid Value For Second Segment (Range: 1 to $segcntmin)"
				continue
			}
			if {$segswap_a == $segswap_b} {
				Inf "Segments Are The Same"
				continue
			}
			if {$segswap_a > $segswap_b} {
				set temp $segswap_a
				set segswap_a $segswap_b
				set segswap_b $temp 
			}
			catch {unset nunames}
			set OK 1
			set ignore_dupls_in_orig 0
			set ignore_dupls_in_new  0
			foreach inname $innames {
				set origname [lindex $inname 0]
				set fullname [lindex $inname 1]
				set seglist  [lindex $inname 2]
				set preseg   [GetPreseg $origname $segswap_a $seglist]
				set sega     [GetSegA $origname $segswap_a $seglist]
				set interseg [GetInterseg $origname $segswap_a $segswap_b $seglist]
				set segb     [GetSegB $origname $segswap_b $seglist]
				set postseg  [GetPostseg $origname $segswap_b $seglist]
				set nuname $preseg
				append nuname $segb $interseg $sega $postseg
				set thisdir [file dirname $fullname]
				set is_pwd 0 
				if {[string length $thisdir] <= 1} {
					set thisdir ""
					set is_pwd 1
				}
				set nuname [file join $thisdir $nuname]
				append nuname [file extension $fullname]
				if {$listing == $wl || $listing == $ch} {
					if {$is_pwd} {
						set test_nuname [file join [pwd] $nuname]
					} else {
						set test_nuname $nuname
					}
					if {[file exists $test_nuname]} {
						Inf "File '$nuname' Already Exists"
						set OK 0
						break
					}
				} else {
					if {!$ignore_dupls_in_orig} {
						set k [lsearch $innames $nuname]
						if {$k >= 0} {
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
								-message "Name '$nuname' Is Already In Original List : Continue ?"]
							if {$choice == "yes"} {
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
									-message "Ignore Any Other Name Duplication Of Names In Original List ?"]
								if {$choice == "yes"} {
									set ignore_dupls_in_orig 1
								}
							} else {
								set OK 0
								break
							}
						}
					}
					if {!$ignore_dupls_in_new && [info exists nunames]} {
						set k [lsearch $nunames $nuname]
						if {$k >= 0} {
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
								-message "Name '$nuname' Is Already In New Names List : Continue ?"]
							if {$choice == "yes"} {
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
									-message "Ignore Any Other Name Duplication In New Names List ?"]
								if {$choice == "yes"} {
									set ignore_dupls_in_new 1
								}
							} else {
								set OK 0
								break
							}
						}
					}
				}
				if {!$OK} {
					continue
				}
				lappend nunames $nuname
			}
			$f.3.e config -state normal
			set example_a [lindex [lindex $innames 0] 0]
			$f.3.e config -state disabled
			$f.3.e2 config -state normal
			set example_b [lindex $nunames 0]
			$f.3.e2 config -state disabled
			$f.4.ll config -text "Hit 'SWAP SEGMENTS' again if this is OK" -bg $evv(EMPH)
			tkwait variable pr_namesegs
			$f.4.ll config -text ""  -bg [option get . background {}]
			if {$pr_namesegs} {
				set new_segmented_names $nunames
				set finished 1
			} else {
				continue
			}
		} else {
			set new_segmented_names {}
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $new_segmented_names
}

#---- Get part of name before two segments to be swapped

proc GetPreseg {origname segswap_a seglist} {
	incr segswap_a -2
	if {$segswap_a < 0} {
		return ""
	}
	set k [lindex $seglist $segswap_a]
	return [string range $origname 0 $k]
}

#---- Get part of name after two segments to be swapped

proc GetPostseg {origname segswap_b seglist} {
	incr segswap_b -1
	if {$segswap_b >= [llength $seglist]} {
		return ""
	}
	set k [lindex $seglist $segswap_b]
	return [string range $origname $k end]
}

#---- Get part of name between two segments to be swapped

proc GetInterseg {origname segswap_a segswap_b seglist} {
	incr segswap_a -1
	incr segswap_b -2
	set j [lindex $seglist $segswap_a]
	set k [lindex $seglist $segswap_b]
	return [string range $origname $j $k]
}


#---- Get 1st of two segments to be swapped

proc GetSegA {origname segswap_a seglist} {
	if {$segswap_a == 1} {
		set k [lindex $seglist 0]
		incr k -1
		return [string range $origname 0 $k]
	} else {
		incr segswap_a -2
		set j [lindex $seglist $segswap_a]
		incr j
		incr segswap_a
		set k [lindex $seglist $segswap_a]
		incr k -1
		return [string range $origname $j $k]
	}
}

#---- Get 2nd of two segments to be swapped

proc GetSegB {origname segswap_b seglist} {
	incr segswap_b -2
	set j [lindex $seglist $segswap_b]
	incr j
	incr segswap_b
	if {$segswap_b >= [llength $seglist]} {
		return [string range $origname $j end]
	}
	set k [lindex $seglist $segswap_b]
	incr k -1
	return [string range $origname $j $k]
}

#---- Add segments to start of filenames

proc AddNameSeg {which ilist listing} {
	global pr_addseg addseg addsegwhere new_segmented_names evv wl ch wstk

	set nunames {}
	set f .addseg
	if [Dlg_Create $f "ADD HEAD TO FILENAMES" "set pr_addseg 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		button $f.0.add -text "ADD SEGMENT" -command {set pr_addseg 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_addseg 0} -highlightbackground [option get . background {}]
		pack $f.0.add -side left
		pack $f.0.q -side right
		label $f.1.ll -text "Segment To Add"
		entry $f.1.e -textvariable addseg -width 8
		pack $f.1.ll $f.1.e -side left -padx 2
		label $f.2.ll -text ""
		entry $f.2.e -textvariable addsegwhere -width 8 -disabledbackground [option get . background {}]
		pack $f.2.ll $f.2.e -side left -padx 2
		pack $f.0 $f.1 $f.2 -side top -fill x -expand true
		bind $f <Return> {set pr_addseg 1}
		bind $f <Escape> {set pr_addseg 0}
	}
	switch -- $which {
		"head" {
			wm title $f "ADD HEAD TO FILENAMES"
			set addsegwhere ""
			$f.2.ll config -text ""
			$f.2.e config -state disabled -bd 0
		}
		"tail" {
			wm title $f "ADD TAIL TO FILENAMES"
			set addsegwhere ""
			$f.2.ll config -text ""
			$f.2.e config -state disabled -bd 0
		}
		"at" {
			wm title $f "ADD SEGMENT TO FILENAMES"
			$f.2.ll config -text "Insert at character position  "
			$f.2.e config -state normal -bd 2
		}
		"atseg" {
			wm title $f "ADD SEGMENT TO FILENAMES"
			$f.2.ll config -text "Insert after segment no "
			$f.2.e config -state normal -bd 2
		}
	}
	raise $f
	set pr_addseg 0
	My_Grab 0 $f pr_addseg $f.1.e 
	set finished 0 
	while {!$finished} {
		tkwait variable pr_addseg
		if {$pr_addseg} {
			if {[string length $addseg] <= 0} {
				Inf "No Segment String Entered"
				continue
			}
			if {![regexp {^[a-zA-Z0-9\-]+$} $addseg]} {
				Inf "Invalid Segment String : Letters,Numbers & Hyphen Only"
				continue
			}
			if {$which == "at"} {
				if {(![regexp {^[0-9]+$} $addsegwhere]) || ($addsegwhere < 1)} {
					Inf "Invalid Position For New Segment (range: 1  to  total-length+1)"
					continue
				}
			} elseif {$which == "atseg"} {
				if {(![regexp {^[0-9]+$} $addsegwhere]) || ($addsegwhere < 1)} {
					Inf "Invalid Position For New Segment (range: 1  to  total-segs)"
					continue
				}
			}
			set nunames {}
			set innames {}
			set OK 1
			set badseg 0
			set ignore_dupls_in_orig 0
			set ignore_dupls_in_new  0
			set segatend 0
			set ignore_segatend 0
			foreach i $ilist {
				set fullname [$listing get $i]
				lappend innames $fullname
				set basename [file rootname [file tail $fullname]]
				switch -- $which {
					"head" -
					"tail" {
						set separatorlist [CheckSegmentation $basename 1]
						if {[llength $separatorlist] <= 0} {
							set badseg 1
							break
						}
					}
					"atseg" {
						set separatorlist [CheckSegmentation $basename 1]
						set separatorlen [llength $separatorlist]
						set seglen [expr $separatorlen + 1]
						if {$separatorlen <= 0} {
							set badseg 1
							break
						} elseif {$seglen < $addsegwhere} {
							Inf "Too Few Segments In $basename"
							set badseg 1
							break
						}
					}
					"at" {
						if {[string first "_" $basename] >= 0} {
							Inf "This Option Only Works With Unsegmented Names\n\nUse....'Add Segment After Segment N'"
							set badseg 1
							break
						}
					}
				}	
				set thisdir [file dirname $fullname]
				set is_pwd 0 
				if {[string length $thisdir] <= 1} {
					set thisdir ""
					set is_pwd 1
				}
				switch -- $which {
					"head" {
						set nuname $addseg
						append nuname "_" $basename
					}
					"tail" {
						set nuname $basename
						append nuname "_" $addseg
					}
					"at" {
						set pos $addsegwhere
						incr pos -1
						if {$segatend && ($pos != $len)} {
							Inf "Some Segments Will Be At The End, And Others Not"
							set OK 0
							break
						}
						set len [string length $basename]
						if {$pos > $len} {
							Inf "Invalid Character Position For Filename '$basename'"
							set OK 0
							break
						}
						if {$pos == 0} {												;#	AAA -->>	0_AAA
							set nuname $addseg											;#	x			xx	
							append nuname "_" $basename
						} elseif {$pos < $len} {										;#	AAA -->>	A_0_AA
							incr pos -1													;#   x	         xxx
							set nuname [string range $basename 0 $pos]
							append nuname "_" $addseg "_"
							incr pos 
							append nuname [string range $basename $pos end]
						} else {	;# pos == len										;#	AAA  -->>	AAA_0
							set nuname $basename										;#	   x -->>	   xx
							append nuname "_" $addseg
							set segatend 1
						}
					}
					"atseg" {
						set pos $addsegwhere
						if {$pos == $seglen} {
							set nuname $basename
							append nuname "_" $addseg
							if {!$ignore_segatend} {
								if {$segatend == -1} {
									set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
										-message "Some Segments Will Be At The End, And Others Not : Is This OK ?"]
									if {$choice == "yes"} {
										set ignore_segatend 1
									} else {
										set OK 0
										break
									}
								} else {
									set segatend 1
								}
							}
						} else {
							if {!$ignore_segatend} {
								if {$segatend == 1} {
									set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
										-message "Some Segments Will Be At The End, And Others Not : Is This OK ?"]
									if {$choice == "yes"} {
										set ignore_segatend 1
									} else {
										set OK 0
										break
									}
								} else {
									set segatend -1
								}
							}
							incr pos -1
							set k [lindex $separatorlist $pos]
							set nuname [string range $basename 0 $k]
							append nuname $addseg
							append nuname [string range $basename $k end]
						}
					}
				}
				set nuname [file join $thisdir $nuname]
				append nuname [file extension $fullname]
				if {$listing == $wl || $listing == $ch} {
					if {$is_pwd} {
						set test_nuname [file join [pwd] $nuname]
					} else {
						set test_nuname $nuname
					}
					if {[file exists $test_nuname]} {
						Inf "File '$nuname' Already Exists"
						set OK 0
						break
					}
				} else {
					if {!$ignore_dupls_in_orig} {
						set k [lsearch $innames $nuname]
						if {$k >= 0} {
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
								-message "Name '$nuname' Is Already In Original List : Continue ?"]
							if {$choice == "yes"} {
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
									-message "Ignore Any Other Name Duplication Of Names In Original List ?"]
								if {$choice == "yes"} {
									set ignore_dupls_in_orig 1
								}
							} else {
								set OK 0
								break
							}
						}
					}
					if {!$ignore_dupls_in_new && [info exists nunames]} {
						set k [lsearch $nunames $nuname]
						if {$k >= 0} {
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
								-message "Name '$nuname' Is Already In New Names List : Continue ?"]
							if {$choice == "yes"} {
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
									-message "Ignore Any Other Name Duplication In New Names List ?"]
								if {$choice == "yes"} {
									set ignore_dupls_in_new 1
								}
							} else {
								set OK 0
								break
							}
						}
					}
				}
				lappend nunames $nuname
			}
			if {$badseg} {
				set new_segmented_names {}
				break
			}
			if {!$OK} {
				continue
			}
			set new_segmented_names $nunames
			set finished 1
		} else {
			set new_segmented_names {}
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $new_segmented_names
}

#---- Delete first OR last segment in name

proc DeleteNameSeg {which ilist listing} {
	global wl ch wstk
	set ignore_dupls_in_orig 0 
	set ignore_dupls_in_new  0 
	set nunames {}
	foreach i $ilist {
		set fnam [$listing get $i]
		lappend innames $fnam
		set inname [file rootname [file tail $fnam]]
		set separatorlist [CheckSegmentation $inname 1]
		if {[llength $separatorlist] <= 0} {
			return {}
		}
		switch -- $which {
			"head" {
				set k [lindex $separatorlist 0]
				incr k
				set nuname [string range $inname $k end]
			}
			"tail" {
				set k [lindex $separatorlist end]
				incr k -1
				set nuname [string range $inname 0 $k]
			}
		}
		set thisdir [file dirname $fnam]
		set is_pwd 0 
		if {[string length $thisdir] <= 1} {
			set thisdir ""
			set is_pwd 1
		}
		set nuname [file join $thisdir $nuname]
		append nuname [file extension $fnam]
		if {($listing == $wl) || ($listing == $ch)} {
			if {$is_pwd} {
				set test_nuname [file join [pwd] $nuname]
			} else {
				set test_nuname $nuname
			}
			if [file exists $test_nuname] {
				Inf "File '$nuname' Already Exists"
				return {}
			}
		} else {
			if {!$ignore_dupls_in_orig} {
				set k [lsearch $innames $nuname]
				if {$k >= 0} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Name '$nuname' Is Already In Original List : Continue ?"]
					if {$choice == "yes"} {
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
							-message "Ignore Any Other Name Duplication Of Names In Original List ?"]
						if {$choice == "yes"} {
							set ignore_dupls_in_orig 1
						}
					} else {
						return {}
					}
				}
			}
			if {!$ignore_dupls_in_new && [info exists nunames]} {
				set k [lsearch $nunames $nuname]
				if {$k >= 0} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Name '$nuname' Is Already In New Names List : Continue ?"]
					if {$choice == "yes"} {
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
							-message "Ignore Any Other Name Duplication In New Names List ?"]
						if {$choice == "yes"} {
							set ignore_dupls_in_new 1
						}
					} else {
						return {}
					}
				}
			}
		}
		lappend nunames $nuname
	}
	return $nunames
}

#---- Delete specific segment in name

proc DeleteNameSegN {ilist listing} {
	global wl ch pr_delsegn delseg_no new_segmented_names wstk evv

	set f .delsegno
	if [Dlg_Create $f "DELETE SPECIFIC SEGMENT IN NAME" "set pr_delsegn 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		button $f.0.swap -text "DELETE SEGMENT" -command {set pr_delsegn 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_delsegn 0} -highlightbackground [option get . background {}]
		pack $f.0.swap -side left
		pack $f.0.q -side right
		label $f.1.ll -text "Segment Number"
		entry $f.1.e -textvariable delseg_no -width 8
		pack $f.1.ll $f.1.e -side left
		pack $f.0 $f.1 -side top -fill x -expand true
		bind $f <Return> {set pr_delsegn 1}
		bind $f <Escape> {set pr_delsegn 0}
	}
	set finished 0
	raise $f
	set pr_delsegn 0
	My_Grab 0 $f pr_delsegn $f.1.e 
	set finished 0 
	while {!$finished} {
		tkwait variable pr_delsegn
		if {$pr_delsegn} {
			if {![regexp {^[0-9]+$} $delseg_no] || ($delseg_no < 1)} {
				Inf "Invalid Segment Number Entered"
				continue
			}
			set OK 1
			set nunames {}
			set innames {}
			set ignore_dupls_in_orig 0
			set ignore_dupls_in_new  0

			foreach i $ilist {
				set fnam [$listing get $i]
				lappend innames $fnam
				set basename [file rootname [file tail $fnam]]
				set separatorlist [CheckSegmentation $basename 1]
				set separatorlen [llength $separatorlist]
				if {$separatorlen <= 0} {
					set OK 0
					break
				} else {
					set seglen [expr $separatorlen + 1]
					if {$seglen < $delseg_no} {
						Inf "Too Few Segments In Name '$basename'"
						set OK 0
						break
					}
				}
				if {$delseg_no == 1} {
					set k [lindex $separatorlist 0]
					incr k
					set nuname [string range $basename $k end]
				} elseif {$delseg_no == $seglen} {
					set k [lindex $separatorlist end]
					incr k -1
					set nuname [string range $basename 0 $k]
				} else {
					set pos $delseg_no
					incr pos -2
					set k [lindex $separatorlist $pos]
					set nuname [string range $basename 0 $k]
					incr pos
					set k [lindex $separatorlist $pos]
					incr k
					append nuname [string range $basename $k end]
				}
				set thisdir [file dirname $fnam]
				set is_pwd 0
				if {[string length $thisdir] <= 1} {
					set thisdir ""
					set is_pwd 1
				}
				set nuname [file join $thisdir $nuname]
				append nuname [file extension $fnam]
				if {($listing == $wl) || ($listing == $ch)} {
					if {$is_pwd} {
						set test_nuname [file join [pwd] $nuname]
					} else {
						set test_nuname $nuname
					}
					if [file exists $test_nuname] {
						Inf "File '$nuname' Already Exists"
						set OK 0
						break
					}
				} else {
					if {!$ignore_dupls_in_orig} {
						set k [lsearch $innames $nuname]
						if {$k >= 0} {
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
								-message "Name '$nuname' Is Already In Original List : Continue ?"]
							if {$choice == "yes"} {
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
									-message "Ignore Any Other Name Duplication Of Names In Original List ?"]
								if {$choice == "yes"} {
									set ignore_dupls_in_orig 1
								}
							} else {
								set OK 0
								break
							}
						}
					}
					if {!$ignore_dupls_in_new && [info exists nunames]} {
						set k [lsearch $nunames $nuname]
						if {$k >= 0} {
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
								-message "Name '$nuname' Is Already In New Names List : Continue ?"]
							if {$choice == "yes"} {
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
									-message "Ignore Any Other Name Duplication In New Names List ?"]
								if {$choice == "yes"} {
									set ignore_dupls_in_new 1
								}
							} else {
								set OK 0
								break
							}
						}
					}
				}
				lappend nunames $nuname
			}
			if {!$OK} {
				set new_segmented_names {}
				break
			}
			set new_segmented_names $nunames
			break
		} else {
			set new_segmented_names {}
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $new_segmented_names
}

#------ Reverse HEad & Tail of name of each selected files

proc HeadVTail {head_to_tail sndonly listing} {
	global wl chlist ch chcnt pa evv wstk tabed last_seg_rearrange rememd
	global background_listing dupl_mix dupl_vbx dupl_txt

	if {[string match $listing $ch] && ($dupl_mix || $dupl_vbx || $dupl_txt)} {
		Inf "Chosen Files List Contains Duplicates: Cannot Proceed"
		return
	}
	if {![info exists tabed]} {
		set tabed dummy
	}
	if {($listing == $ch) && ![info exists chlist]} {
		return 0
	}
	set ren_blist 0

	if {$listing == $wl} {
		set ilist [$listing curselection]						;#	get indices of selected files
	} else {
		set ilist {}
		set j [$listing index end]
		set i 0
		while {$i < $j} {
			lappend ilist $i
			incr i
		}
	}
	if {[llength $ilist] <= 0} {							
		Inf "No Item(s) Selected"
		return 0
	}
	if {$sndonly} {
		set ilist [GetOnlySnds $ilist $listing 0]
		if {[llength $ilist] <= 0} {
			return 0
		}
	}
	foreach i $ilist {										;# check for valid (set of) files
		set fullname [$listing get $i]
		set fnam [file rootname [file tail $fullname]]
		if {$head_to_tail} {
			set k [string first "_" $fnam]
			if {$k <= 0} {
				Inf "File '$fullname' Has No Head"
				return 0
			}
			if {$k == [expr [string length $fnam] -1]} {
				Inf "File '$fullname' Has No Tail"
				return 0
			}
			if {[string last "_" $fnam] == [expr [string length $fnam] -1]} {
				Inf "File '$fullname' Ends With Underscore: Cannot Proceed"
				return 0
			}
		} else {
			set k [string last "_" $fnam]
			if {($k < 0) || $k == [expr [string length $fnam] -1]} {
				Inf "File '$fullname' Has No Tail"
				return 0
			}
			if {$k == 0} {
				Inf "File '$fullname' Has No Head"
				return 0
			}
			if {[string first "_" $fnam] == 0} {
				Inf "File '$fullname' Begins With Underscore: Cannot Proceed"
				return 0
			}
		}
		catch {unset inname}
		lappend inname $fnam
		lappend inname $k
		lappend inname $fullname
		lappend inname $i
		lappend innames $inname
		lappend orignames $fullname
	}
	set cnt 0
	set nunames {}
	set ignore_dupls_in_orig 0
	set ignore_dupls_in_new  0
	foreach inname $innames {
		set oldname [lindex $inname 0]
		set k [lindex $inname 1]
		set oldfullname [lindex $inname 2]
		set olddirname [file dirname $oldfullname]
		set is_pwd 0
		if {[string length $olddirname] <= 1} {
			set olddirname ""
			set is_pwd 1
		}
		if {$head_to_tail} {
			incr k
			set nuname [file join $olddirname [string range $oldname $k end]]
			incr k -2
			append nuname "_" [string range $oldname 0 $k]
		} else {
			incr k 1
			set nuname [file join $olddirname [string range $oldname $k end]]
			incr k -2
			append nuname "_" [string range $oldname 0 $k]
		}
		append nuname [file extension $oldfullname]
		if {$listing == $wl || $listing == $ch} {
			if {$is_pwd} {
				set test_nuname [file join [pwd] $nuname]
			} else {
				set test_nuname $nuname
			}
			if {[file exists $test_nuname]} {
				Inf "File '$nuname' Already Exists"
				return 0
			}
		} else {
			if {!$ignore_dupls_in_orig} {
				set k [lsearch $orignames $nuname]
				if {$k >= 0} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Name '$nuname' Is Already In Original List : Continue ?"]
					if {$choice == "yes"} {
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
							-message "Ignore Any Other Name Duplication Of Names In Original List ?"]
						if {$choice == "yes"} {
							set ignore_dupls_in_orig 1
						}
					} else {
						return 0
					}
				}
			}
			if {!$ignore_dupls_in_new && [info exists nunames]} {
				set k [lsearch $nunames $nuname]
				if {$k >= 0} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Name '$nuname' Is Already In New Names List : Continue ?"]
					if {$choice == "yes"} {
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
							-message "Ignore Any Other Name Duplication In New Names List ?"]
						if {$choice == "yes"} {
							set ignore_dupls_in_new 1
						}
					} else {
						return 0
					}
				}
			}
		}
		lappend nunames $nuname
		incr cnt
	}
	switch -regexp -- $listing \
		^$wl$ - \
		^$ch$ {	
			set cnt 0
			foreach inname $innames {
				set nuname [lindex $nunames $cnt] 
				set origfnam [lindex $inname 2]
				set i        [lindex $inname 3] 
				set haspmark [HasPmark $origfnam]
				set hasmmark [HasMmark $origfnam]
				if [catch {file rename $origfnam $nuname} zub] {
					Inf "Cannot Rename File\n$origfnam\nTO\n$nuname"
					continue
				}
				DataManage rename $origfnam $nuname
				lappend couettelist $origfnam $nuname 
				$wl delete $i								
				$wl insert $i $nuname
				catch {unset rememd}
				UpdateChosenFileMemory $origfnam $nuname
				set oldname_pos_on_chosen [LstIndx $origfnam $ch]
				if {$oldname_pos_on_chosen >= 0} {
					RemoveFromChosenlist $origfnam
					set chlist [linsert $chlist $oldname_pos_on_chosen $nuname]
					incr chcnt
					$ch insert $oldname_pos_on_chosen $nuname
				}
				RenameProps	$origfnam $nuname 1				
				DummyHistory $origfnam "RENAMED_$nuname"
				if {$haspmark} {
					MovePmark $origfnam $nuname
				}
				if {$hasmmark} {
					MoveMmark $origfnam $nuname
				}
				if [IsInBlists $origfnam] {
					if [RenameInBlists $origfnam $nuname] {
						set ren_blist 1
					}
				}
				RenameOnDirlist $origfnam $nuname
				set rename_pair [list $origfnam $nuname]
				lappend last_seg_rearrange $rename_pair
				incr cnt
			}
			if {$ren_blist} {
				SaveBL $background_listing
			}		
		} \
		^$tabed.bot.itframe.l.list$ { 
			set outlist $tabed.bot.otframe.l.list
			$outlist delete 0 end			;#	TABLE EDITOR, TABLE INPUT, WRITE NEW LIST TO TABLE OUTPUT
			catch {unset last_seg_rearrange}
			foreach origfnam $listing nufnam $nunames {
				$outlist insert end $nufnam
				set rename_pair [list $origfnam $nufnam]
				lappend last_seg_rearrange $rename_pair
			}

		} \
		^$tabed.bot.icframe.l.list$ {
			if {$insitu} {					;#	TABLE EDITOR, COLUMN INPUT, WRITE NEW LIST TO COLUMN INPUT
				set outlist $listing
			} else {						;#	OR TO COLUMN OUTPUT
				set outlist $tabed.bot.ocframe.l.list
			}
			catch {unset origfnams}
			catch {unset last_seg_rearrange}
			foreach origfnam $listing {
				lappend origfnams $origfnam
			}
			$outlist delete 0 end
			foreach origfnm $origfnams nufnam $nunames {
				$outlist insert end $nufnam
				set rename_pair [list $origfnam $nufnam]
				lappend last_seg_rearrange $rename_pair
			}
		}
	if {[info exists couettelist]} {
		CouetteManage rename $couettelist
	}
	return 1
}

#-------- Check for valid segmentation of name and Return list of positions of separtors

proc CheckSegmentation {name cant_proceed} {

	if {[string match "_" [string index $name 0]]} {
		if {$cant_proceed} {
			Inf "Name '$name' Starts With Underscore: Cannot Proceed"
		}
		return {}
	}
	if {[string match "_" [string index $name end]]} {
		if {$cant_proceed} {
			Inf "Name '$name' Ends With Underscore: Cannot Proceed"
		}
		return {}
	}
	if {[string first "__" $name] >= 0} {
		if {$cant_proceed} {
			Inf "Name '$name' Has Double Underscore: Cannot Proceed"
		}
		return {}
	}
	set k [string first "_" $name]
	if {$k < 0} {
		if {$cant_proceed} {
			Inf "Name '$name' Has No Segments: Cannot Proceed"
		}
		return {}
	}
	set stringend [string length $name]
	set offset 0
	while {$k >= 0} {
		lappend klist [expr $k + $offset]
		incr k
		incr offset $k
		if {$offset >= $stringend} {
			break
		}
		set k [string first "_" [string range $name $offset end]]
		if {$k < 0} {
			break
		}
	}
	return $klist
}

#-------- Test if character is a vowel

proc IsVowel {charac} {

	if {[regexp {[aeiouAEIOU]} $charac]} {
		return 1
	}
	return 0
}

#-------- Test if character is a consonant

proc IsCons {charac} {

	if {[regexp {[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]} $charac]} {
		return 1
	}
	return 0
}

#-------- Test if character is a digit

proc IsDigit {charac} {

	if {[regexp {[0-9]} $charac]} {
		return 1
	}
	return 0
}

#-------- Test if character is a digit, minus sign, or a hyphen used to substitute for decimal-point

proc IsNumchar {charac} {

	if {[regexp {[0-9\-]} $charac]} {
		return 1
	}
	return 0
}

#-------- Test if character is alphabetic

proc IsAlpha {charac} {

	if {[regexp {[a-zA-Z]} $charac]} {
		return 1
	}
	return 0
}

#------ Where numeric chars use "-" as substitute for decimal-point; substitute "."

proc ConvertChars {str} {

	set len [string length $str]
	set len_less_one [expr $len -1]
	set k 1
	while {$k < $len} {
		if {[string match "-" [string index $str $k]]} {
			incr k -1
			set nustr [string range $str 0 $k]
			incr k
			append nustr "."
			if {$k < $len_less_one} {
				incr k
				append nustr [string range $str $k end]
				incr k -1
			}
			set str $nustr
		}
		incr k
	}
	return $str
}

#------- Get The Sndfiles from list of selected files

proc GetOnlySnds {ilist listing typ} {
	global wl ch pa wstk evv

	;#	CODE CHECK
	if {!($listing == $wl) &&  !($listing == $ch)} {
		Inf "Inappropriate Call To Getonlysnds: Can Only Check File Props From Workspace Listings"
		return
	}
	foreach i $ilist {
		set fnam [$listing get $i]
		if {[info exists pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(FTYP)) == $evv(SNDFILE))} {
			lappend nuilist $i
		}
	}
	if {![info exists nuilist]} {
		Inf "No Sound Files Have Been Selected"
		return {}
	}
	if {$typ != "endnames" } {
		if {[llength $ilist] != [llength $nuilist]} {
			if {$typ == "selfiles"} {
				set msg "Not All The Workspace Files Are Soundfiles : Continue ?"
			} else {
				set msg "Not All The Selected Files Are Soundfiles : Continue ?"
			}
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				return $nuilist
			} else {
				return {}
			}
		}
	}
	return $ilist
}

#------ Reverse previous renaming

proc RestoreOriginalFilenames {} {
	global wl ch tabed last_seg_rearrange chlist chcnt pa rememd evv
	set ren_blist 0
	if {![info exists last_seg_rearrange]} {
		Inf "No Previous Renaming Has Happened"
		return
	}
	foreach rename_pair $last_seg_rearrange {
		set origfnam [lindex $rename_pair 1]
		set nuname [lindex $rename_pair 0]
		if {[string match [file tail $nuname] $nuname]} {
			set test_nuname [file join [pwd] $nuname]
		} else {
			set test_nuname $nuname
		}
		if {[file exists $test_nuname]} {
			Inf "A File Is To Be Renamed To '$nuname' But This File Already Exists"
			return
		}
		set i [LstIndx $origfnam $wl]
		if {($i < 0) || (![info exists pa($origfnam,$evv(FTYP))])} {
			Inf "File '$origfnam' Is No Longer On The Workspace: Cannot Restore Original Names"
			return
		}
		lappend ilist $i
	}
	foreach rename_pair $last_seg_rearrange i $ilist {
		set origfnam [lindex $rename_pair 1]
		set nuname [lindex $rename_pair 0]
		set haspmark [HasPmark $origfnam]
		set hasmmark [HasMmark $origfnam]
		if [catch {file rename $origfnam $nuname} zub] {
			Inf "Cannot Rename File\n$origfnam\nYo\n$nuname"
			continue
		}
		DataManage rename $origfnam $nuname
		lappend couettelist $origfnam $nuname 
		$wl delete $i								
		$wl insert $i $nuname
		catch {unset rememd}
		UpdateChosenFileMemory $origfnam $nuname
		set oldname_pos_on_chosen [LstIndx $origfnam $ch]
		if {$oldname_pos_on_chosen >= 0} {
			RemoveFromChosenlist $origfnam
			set chlist [linsert $chlist $oldname_pos_on_chosen $nuname]
			incr chcnt
			$ch insert $oldname_pos_on_chosen $nuname
		}
		RenameProps	$origfnam $nuname 1				
		DummyHistory $origfnam "RENAMED_$nuname"
		if {$haspmark} {
			MovePmark $origfnam $nuname
		}
		if {$hasmmark} {
			MoveMmark $origfnam $nuname
		}
		if [IsInBlists $origfnam] {
			if [RenameInBlists $origfnam $nuname] {
				set ren_blist 1
			}
		}
		RenameOnDirlist $origfnam $nuname
		set rename_pair [list $origfnam $nuname]
		lappend seg_rearrange $rename_pair
	}
	if {[info exists couettelist]} {
		CouetteManage rename $couettelist
	}
	if {$ren_blist} {
		SaveBL $background_listing
	}
	set last_seg_rearrange $seg_rearrange
}

#---- Select files with specific segment in name

proc SelSegFiles {ilist listing} {
	global pr_selsegfiles selseg selseg_no seltyp new_segmented_names evv

	set nunames {}
	set f .selsegfiles
	if [Dlg_Create $f "SELECT FILENAMES BY SEGMENT" "set pr_selsegfiles 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		button $f.0.add -text "SELECT FILES" -command {set pr_selsegfiles 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_selsegfiles 0} -highlightbackground [option get . background {}]
		pack $f.0.add -side left
		pack $f.0.q -side right
		label $f.1.ll -text "SEGMENT CONTENT TO USE"
		entry $f.1.e -textvariable selseg -width 8
		pack $f.1.ll $f.1.e -side left -padx 2
		label $f.2.ll -text "WHICH SEGMENT TO LOOK IN"
		entry $f.2.e -textvariable selseg_no -width 8
		pack $f.2.ll $f.2.e -side left -padx 2
		label $f.4.1 -text "WHAT TO MATCH"
		pack $f.4.1 -side top
		radiobutton $f.3.1 -text "Whole Segment" -variable seltyp -value 0
		radiobutton $f.3.2 -text "Any of Segment" -variable seltyp -value 1
		radiobutton $f.3.3 -text "Segment Start" -variable seltyp -value 2
		radiobutton $f.3.4 -text "Segment End" -variable seltyp -value 3
		pack $f.3.1 $f.3.2 $f.3.3 $f.3.4 -side left
		pack $f.0 $f.1 $f.2 $f.4 $f.3 -side top -fill x -expand true
		set seltyp 0
		bind $f <Return> {set pr_selsegfiles 1}
		bind $f <Escape> {set pr_selsegfiles 0}
	}
	raise $f
	set pr_selsegfiles 0
	My_Grab 0 $f pr_selsegfiles $f.1.e 
	set finished 0 
	while {!$finished} {
		tkwait variable pr_selsegfiles
		if {$pr_selsegfiles} {
			if {[string length $selseg] <= 0} {
				Inf "No Segment String Entered"
				continue
			}
			set selseg [string tolower $selseg]
			if {![regexp {^[a-zA-Z0-9\-]+$} $selseg]} {
				Inf "Invalid Segment String : Letters,Numbers & Hyphen Only"
				continue
			}
			if {(![regexp {^[0-9]+$} $selseg_no]) || ($selseg_no <= 0)} {
				Inf "Invalid Position For Segment (range: 1  to  total-segs)"
				continue
			}
			set nunames {}
			foreach i $ilist {
				set fullname [$listing get $i]
				set basename [file rootname [file tail $fullname]]
				set separatorlist [CheckSegmentation $basename 0]
				set slen [llength $separatorlist]
				if {$slen <= 0} {
					continue
				}
				if {$selseg_no > [expr $slen + 1]} {
					continue
				}
				set segindex [expr $selseg_no - 1]
				if {$segindex == 0} {
					set k [lindex $separatorlist 0]
					incr k -1
					set compo [string range $basename 0 $k]
				} elseif {$segindex == $slen} {
					set k [lindex $separatorlist end]
					incr k
					set compo [string range $basename $k end]
				} else {
					set j [lindex $separatorlist [expr $segindex - 1]]
					incr j
					set k [lindex $separatorlist $segindex]
					incr k -1
					set compo [string range $basename $j $k]
				}
				switch -- $seltyp {
					0 {	;#	WHOLE SEGMENT
						if {[string match $selseg $compo]} {
							lappend nunames $i
						}
					}
					1 {	;#	ANY OF SEGMENT
						if {[regexp $selseg $compo]} {
							lappend nunames $i
						}
					}
					2 {	;#	SEGMENT START
						if {[string match $selseg* $compo]} {
							lappend nunames $i
						}
					}
					3 {	;#	SEGMENT END
						if {[string match *$selseg $compo]} {
							lappend nunames $i
						}
					}
				}
			}
			set new_segmented_names $nunames
			set finished 1
		} else {
			set new_segmented_names {}
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $new_segmented_names
}

#---- Select every Nth file and modify segment K in name, or get such segments to a list

proc CycSegFiles {ilist listing get} {
	global wl ch pr_cycsegfiles cycseg cycseg_no cyctyp new_segmented_names only_if_fexists cycch cycseg_cyc cycseg_stt evv
	global example_acyc example_bcyc seg_listing wstk seg_listing_bak cycseg_bak cyctabk

	set nunames {}
	catch {unset cycseg_bak}
	set f .cycsegfiles
	if [Dlg_Create $f "CHANGE SEGMENT IN EVERY Nth FILENAME" "set pr_cycsegfiles 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.00 -borderwidth $evv(BBDR)
		frame $f.01 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		frame $f.5 -borderwidth $evv(BBDR)
		frame $f.6 -borderwidth $evv(BBDR)
		frame $f.7 -borderwidth $evv(BBDR)
		frame $f.8 -borderwidth $evv(BBDR)
		frame $f.9 -borderwidth $evv(BBDR)
		frame $f.10 -borderwidth $evv(BBDR)
		frame $f.11 -borderwidth $evv(BBDR)
		button $f.0.add -text "MAKE CHANGES" -command {set pr_cycsegfiles 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_cycsegfiles 0} -highlightbackground [option get . background {}]
		pack $f.0.add -side left
		pack $f.0.q -side right

		label $f.00.ll -text "STEP BY N FILES"
		label $f.01.ll -text "Use a SINGLE step value 'N' or a CYCLE of step values separated by commas  e.g. 2,7,3,1" -fg $evv(SPECIAL)
		entry $f.00.e -textvariable cycseg_cyc -width 20
		label $f.00.ll2 -text "START AT FILE"
		entry $f.00.e2 -textvariable cycseg_stt -width 8
		pack $f.00.ll $f.00.e $f.00.ll2 $f.00.e2 -side left -padx 2
		pack $f.01.ll -side left

		radiobutton $f.1.1 -text "Insert Before Segment" -variable cyctyp -value 0 
		radiobutton $f.1.2 -text "Substitute Segment" -variable cyctyp -value 1 
		radiobutton $f.1.3 -text "Delete Segment" -variable cyctyp -value 2 
		pack $f.1.1 $f.1.2 $f.1.3 -side left
		checkbutton $f.2.1 -variable only_if_fexists -text "Only if renamed items are existing files"
		pack $f.2.1 -side left
		label $f.3.ll -text "WHICH SEGMENT TO LOOK IN (1,2...etc or 'last')"
		entry $f.3.e -textvariable cycseg_no -width 8
		pack $f.3.ll $f.3.e -side left -padx 2
		radiobutton $f.4.1 -text "Same segment" -variable cycch -value 0 -command HiliteSegSingle
		radiobutton $f.4.2 -text "Cyclic List of Segments" -variable cycch -value 1 -command HiliteSegList 
		pack $f.4.1 $f.4.2 -side left -padx 2
		label $f.5.ll -text "SEGMENT CONTENT TO USE"
		pack $f.5.ll -side top -padx 2
		entry $f.6.1 -textvariable cycseg -width 8 -bg $evv(EMPH)
		label $f.6.ll -text "Single Segment Name"
		button $f.6.2 -text "Get List Of Segments" -command {Dlg_GetTextfile 0 -1 seg}  -highlightbackground [option get . background {}]
		button $f.6.3 -text "Make List Of Segments" -command Dlg_MakeSegfile  -highlightbackground [option get . background {}]
		pack $f.6.1 $f.6.ll -padx 2 -side left
		pack $f.6.3 $f.6.2 -padx 4 -side right
		set seg_listing [Scrolled_Listbox $f.7.1 -width 12 -height 20 -selectmode single]
		pack $f.7.1 -side top -fill x -expand true
		label $f.8.ll -text "FOR EXAMPLE"
		pack $f.8.ll -side left
		entry $f.9.e -textvariable example_acyc -width 32
		label $f.9.ll -text "---->>  Goes To  ---->>"
		entry $f.9.e2 -textvariable example_bcyc -width 32
		pack $f.9.e $f.9.ll $f.9.e2 -side left
		label $f.10.ll -text ""
		pack $f.10.ll -side top
		radiobutton $f.11.1 -text "Keep changed table" -variable cyctabk -value 1
		radiobutton $f.11.2 -text "Keep only the items changed" -variable cyctabk -value 0
		pack $f.11.1 -side left
		pack $f.11.2 -side right
		pack $f.0 $f.00 $f.01 $f.1 $f.2 $f.11 $f.3 $f.4 $f.5 $f.6 $f.7 $f.8 $f.9 $f.10 -side top -fill x -expand true
		set cyctyp 0
		set only_if_fexists 1
		set cycch 0
		set cycseg_cyc 1
		set cycseg_stt 1
		set cyctabk 1
		bind $f <Return> {set pr_cycsegfiles 1}
		bind $f <Escape> {set pr_cycsegfiles 0}
	}

	if {($listing == $wl) || ($listing == $ch)} {
		$f.2.1 config -text "" -state disabled
		set only_if_fexists 1
	} else {
		$f.2.1 config -text "Only if renamed items are existing files" -state normal
	}
	.cycsegfiles.7.1.list config -bg [option get . background {}]
	if {$get} {
		wm title $f "GET NAME-SEGMENT FROM EVERY Nth FILENAME"
		$f.0.add config -text "GET SEGMENTS"
		$f.1.1 config -text "" -state disabled
		$f.1.2 config -text "" -state disabled
		$f.1.3 config -text "" -state disabled

		$f.4.1 config -text "" -state disabled
		$f.4.2 config -text "" -state disabled
		if {($listing == $wl) || ($listing == $ch)} {
			$f.5.ll config -text "NAME OF FILE TO STORE SEGMENT VALUES"
			$f.6.1 config -bg [option get . background {}] -bd 2 -state normal
			$f.6.ll config -text "Textfile Name"
		} else {
			$f.5.ll config -text ""
			set cycseg ""
			$f.6.1 config -bg [option get . background {}] -bd 0 -state disabled
			$f.6.ll config -text ""
		}
		$f.6.2 config -text "" -bd 0 -state disabled
		$f.6.3 config -text "" -bd 0 -state disabled
		set seg_listing_bak [$seg_listing get 0  end] 
		$seg_listing delete 0 end
		$f.8.ll config -text ""
		set example_acyc ""
		set example_bcyc ""
		$f.9.e  config -state disabled -bd 0 
		$f.9.ll config -text ""
		$f.9.e2 config -state disabled -bd 0 
		$f.11.1 config - text "" -state disabled
		$f.11.2 config - text "" -state disabled
		set only_if_fexists 0
		set cyctyp 3
		set cycch -1
	} else {
		wm title $f "CHANGE SEGMENT IN EVERY Nth FILENAME"
		$f.0.add config -text "MAKE CHANGES"
		$f.1.1 config -text "Insert Segment" -state normal
		$f.1.2 config -text "Substitute Segment" -state normal
		$f.1.3 config -text "Delete Segment" -state normal

		$f.4.1 config -text "Same segment" -state normal
		$f.4.2 config -text "Cyclic List of Segments" -state normal
		$f.5.ll config -text "SEGMENT CONTENT TO USE"
		$f.6.1 config -bg $evv(EMPH) -bd 2 -state normal
		$f.6.ll config -text "Single Segment Name"
		$f.6.2 config -text "" -bd 0 -state disabled
		$f.6.3 config -text "" -bd 0 -state disabled

		if {[info exists seg_listing_bak]} {
			foreach item $seg_listing_bak {
				$seg_listing insert end $item
			}
		}
		$f.8.ll config -text "FOR EXAMPLE"
		$f.9.e config -state normal -bd 2 
		$f.9.ll config -text "---->>  Goes To  ---->>"
		$f.9.e2 config -state normal -bd 2 
		$f.11.1 config -text "Keep changed table" -state normal
		$f.11.2 config -text "Keep only the items changed" -state normal
		set example_acyc ""
		set example_bcyc ""
		set cycch 0
	}
	set len_ilist [llength $ilist]
	set finished 0 
	raise $f
	set pr_cycsegfiles 0
	My_Grab 0 $f pr_cycsegfiles $f.3.e 
	while {!$finished} {
		tkwait variable pr_cycsegfiles
		if {$pr_cycsegfiles} {
			catch {unset cycseg_cyclist}
			set cycseg_cyc [split $cycseg_cyc]
			catch {unset dfdf}
			foreach item $cycseg_cyc {
				if {[string length $item] > 0} {
					lappend dfdf $item
				}
			}
			if {[info exists dfdf]} {
				set cycseg_cyc [join $dfdf ""]
			} else {
				Inf "No Step (Sequence) Between Files Has Been Entered"
				continue
			}
			if {[regexp {,} $cycseg_cyc]} {
				if {![regexp {^[0-9,]+$} $cycseg_cyc] || ![regexp {[0-9]} $cycseg_cyc]} {
					Inf "Invalid Step (Sequence) Between Files"
					continue
				} else {
					set lastk 0
					set k [string first "," [string range $cycseg_cyc $lastk end]]
					while {$k >= 0} {
						set j [expr $k + $lastk - 1]
						if {$k >= 1} {
							lappend cycseg_cyclist [string range $cycseg_cyc $lastk $j]
						}
						incr k
						incr j
						if {$j >= [string length $cycseg_cyc]} {
							break
						}
						incr lastk $k
						set k [string first "," [string range $cycseg_cyc $lastk end]]
					}
					if {$lastk <= [string length $cycseg_cyc]} {
						lappend cycseg_cyclist [string range $cycseg_cyc $lastk end]
					}
					if {![info exists cycseg_cyclist]} {
						Inf "Invalid Step (Sequence) Between Files"
						continue
					}
				}
			} else {
				if {![regexp {^[0-9]+$} $cycseg_cyc]} {
					Inf "Invalid Step (Sequence) Between Files"
					continue
				} else {
					lappend cycseg_cyclist $cycseg_cyc
				}
			}
			set OK 1
			foreach item $cycseg_cyclist {
				if {$item <= 0} {
					Inf "Invalid Step Value ($item) For Steps Between Files"
					set OK 0
					break
				}
			}
			if {!$OK} {
				continue
			}
			set warned 0 
			if {([llength $cycseg_cyclist] == 1) && [lindex $cycseg_cyclist 0] >= $len_ilist} {
				set msg "Step Is Longer Than List Of Files: Only One File Will Be Changed: Continue?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				} else {
					set warned 1
				}
			}
			if {(![regexp {^[0-9]+$} $cycseg_stt]) || ($cycseg_stt > $len_ilist) || ($cycseg_stt <= 0)} {
				Inf "Invalid File To Start At"
				continue
			}
			if {[expr $cycseg_stt + [lindex $cycseg_cyclist 0]] > $len_ilist} {
				if {!$warned} {
					set msg "Starting At $cycseg_stt And Stepping By [lindex $cycseg_cyclist 0]\nOnly One Item Will Be Changed: OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
			}
			set last_seg 0
			if {!$get && [string match [string tolower $cycseg_no] "last"]} {
				set last_seg 1
			} elseif {(![regexp {^[0-9]+$} $cycseg_no]) || ($cycseg_no <= 0)} {
				if {$cyctyp == 0} {
					Inf "Invalid Position For Segment (range: 1 to  total-segs+1)"
				} else {
					Inf "Invalid Position For Segment (range: 1  to  total-segs)"
				}
				continue
			}
			if {!$get} {
				if {$cycch == 0} {		;# SINGLE SEGMENT TO SUBSTITUTE OR ETC.
					if {[string length $cycseg] <= 0} {
						Inf "No Segment String Entered"
						continue
					}
					set cycseg [string tolower $cycseg]
					if {![regexp {^[a-z0-9\-]+$} $cycseg]} {
						Inf "Invalid Segment String : Letters,Numbers & Hyphen Only"
						continue
					}
				} else {				;# SEVERAL SEGMENTS TO SUBSTITUTE OR ETC.
					if {[$seg_listing index end] <= 0} {
						Inf "You Have Chosen To Use A List Of Segments, But No Segments Are Listed"
						continue	
					}
				}
			} elseif {($listing == $wl) || ($listing == $ch)} {
				if {[string length $cycseg] <= 0} {
					Inf "No Filename Entered For Storing Segs"
					continue
				}
				if [ValidCDPRootname $cycseg] {		;#	If not a valid name, stays waiting in dialog
					set cycsegf $cycseg$evv(TEXT_EXT)
					if [file exists $cycsegf] {
						set it_exists 1
						set choice [tk_messageBox -type yesno -message "File Already Exists: Overwrite It?" \
							-icon question -parent [lindex $wstk end]]
						if [string match $choice "no"] {
							catch {unset it_exists}
							continue						;#	If file exists, and don't want to overwrite it, 
						}									;#	stays waiting in dialog.
					}
				} else {
					continue
				}
			}
			set nunames {}
			set OK 1
			set badseg 0
			set cyc_cnt 0
			if {$cycch == 0} {
				set this_cycseg $cycseg
			}
			set cnt 0
			set act_cnt 0
			set cycstep_cnt 0
			set cycstep_cnt_max [llength $cycseg_cyclist]
			set act_on [expr $cycseg_stt - 1]
			foreach i $ilist {
				if {$cnt < $act_on} {	;#	SELECT APPROPRIATE FILES
					incr cnt
					if {$cyctabk} {
						lappend nunames [$listing get $i]
					}
					continue
				} elseif {$cnt == $act_on} {
					incr act_on [lindex $cycseg_cyclist $cycstep_cnt]
					incr cycstep_cnt
					if {$cycstep_cnt >= $cycstep_cnt_max} {
						set cycstep_cnt 0
					}
				}
				if {$cycch == 1} {	;#	CYCLE AROUND SEGMENT VALUES, IF REQUESTED
					set this_cycseg [$seg_listing get $cyc_cnt]
					incr cyc_cnt
					if {$cyc_cnt >= [$seg_listing index end]} {
						set cyc_cnt 0
					}
				}
				set fullname [$listing get $i]
				set basename [file rootname [file tail $fullname]]
				set separatorlist [CheckSegmentation $basename 1]
				set dir [file dirname $fullname]
				set ext [file extension $fullname]
				set slen [llength $separatorlist]
				if {$slen <= 0} {
					set badseg 1
					break
				}
				if {!$last_seg} {
					if {$cyctyp == 0} {		;# WHERE SEGMENT IS INSERTED, WE CAN SPECIFY A NUMBER BEYOND TOTAL NO OF SEGS, TO DO INSERT AT END
						
						if {$cycseg_no > [expr $slen + 2]} {
							Inf "Name '$basename' Has Insufficient Segments"
							set start_again 1
							break
						}
					} else {
						if {$cycseg_no > [expr $slen + 1]} {
							Inf "Name '$basename' Has Insufficient Segments"
							set start_again 1
							break
						}
					}
					set segindex [expr $cycseg_no - 1]
				} else {
					set segindex $slen
					if {$cyctyp == 0} {
						incr segindex
					}
				}
				switch -- $cyctyp {
					0 {	;#	INSERT SEGMENT
						if {$segindex == 0} {
							set nuname $this_cycseg
							append nuname "_" $basename 
						} elseif {$segindex > $slen} {
							set nuname $basename
							append nuname "_" $this_cycseg
						} else {
							set j [lindex $separatorlist [expr $segindex - 1]]
							set nuname [string range $basename 0 $j]
							append nuname $this_cycseg
							append nuname [string range $basename $j end]
						}
					}
					1 {	;#	SUBSTITUTE SEGMENT
						if {$segindex == 0} {
							set nuname $this_cycseg
							set k [lindex $separatorlist 0]
							append nuname [string range $basename $k end]
						} elseif {$segindex == $slen} {
							set j [lindex $separatorlist end]
							set nuname [string range $basename 0 $j]
							append nuname $this_cycseg
						} else {
							set j [lindex $separatorlist [expr $segindex - 1]]
							set k [lindex $separatorlist $segindex]
							set nuname [string range $basename 0 $j]
							append nuname $this_cycseg
							append nuname [string range $basename $k end]
						}
					}
					2 {	;#	DELETE SEGMENT
						if {$segindex == 0} {
							set k [lindex $separatorlist 0]
							incr k
							set nuname [string range $basename $k end]
						} elseif {$segindex == $slen} {
							set j [lindex $separatorlist end]
							incr j -1
							set nuname [string range $basename 0 $j]
						} else {
							set j [lindex $separatorlist [expr $segindex - 1]]
							set k [lindex $separatorlist $segindex]
							set nuname [string range $basename 0 $j]
							incr k
							append nuname [string range $basename $k end]
						}
					}
					3 {	;#	GETSEG
						if {$segindex == 0} {
							set k [lindex $separatorlist 0]
							incr k -1
							set nuname [string range $basename 0 $k]
						} elseif {$segindex == $slen} {
							set j [lindex $separatorlist end]
							incr j
							set nuname [string range $basename $j end]
						} else {
							set j [lindex $separatorlist [expr $segindex - 1]]
							set k [lindex $separatorlist $segindex]
							incr j
							incr k -1
							set nuname [string range $basename $j $k]
						}
						
					}
				}
				set is_pwd 0
				set zz $dir
				if {[string length $zz] <= 1} {
					set zz ""
					set is_pwd 1
				}
				append zz $nuname $ext
				if {$only_if_fexists} {
					if {$is_pwd} {
						set test_zz [file join [pwd] $zz]
					} else {
						set test_zz $zz
					}
					if {![file exists $test_zz]} {
						Inf "File '$zz' Does Not Exist"
						set OK 0
						break
					}
				}
				if {!$get} {
					if {$act_cnt == 0} {
						$f.9.e  config -state normal
						set example_acyc $basename
						$f.9.e  config -state disabled
						$f.9.e2  config -state normal
						set example_bcyc $nuname 
						$f.9.e2  config -state disabled
						$f.10.ll config -text "Hit 'MAKE CHANGES' again if this is OK" -bg $evv(EMPH)
						tkwait variable pr_cycsegfiles
						$f.10.ll config -text ""  -bg [option get . background {}]
						if {!$pr_cycsegfiles} {
							set start_again 1
							break
						}
					}
					set nuname $zz
				}
				lappend nunames $nuname
				incr cnt
				incr act_cnt
			}
			if {!$OK} {
				continue
			}
			if {[info exists start_again]} {
				unset start_again
				continue
			}
			if {$badseg} {
				set new_segmented_names {}
				break
			}
			set new_segmented_names $nunames
			set finished 1
		} else {
			set new_segmented_names {}
			break
		}
	}
	if {$get} {
		if {($listing == $wl) || ($listing == $ch)} {
			if {[llength $new_segmented_names] > 0} {
				if {[info exists it_exists]} {
					CreateSegFile $cycsegf $new_segmented_names 1
				} else {
					CreateSegFile $cycsegf $new_segmented_names 0
				}
			}
			set new_segmented_names {}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $new_segmented_names
}

#------ Reconfigure window, for entry of single segment name

proc HiliteSegSingle {} {
	global cycseg cycseg_bak evv
	.cycsegfiles.6.1 config -bg $evv(EMPH) -bd 2 -state normal
	.cycsegfiles.7.1.list config -bg [option get . background {}]
	.cycsegfiles.6.ll config -text "Single Segment Name"
	.cycsegfiles.6.2 config -text "" -bd 0 -state disabled
	.cycsegfiles.6.3 config -text "" -bd 0 -state disabled
	if {[info exists cycseg_bak]} {
		set cycseg $cycseg_bak
	}
}

#------ Reconfigure window, for entry of list of segment names

proc HiliteSegList {} {
	global cycseg cycseg_bak evv
	.cycsegfiles.6.1 config -bg [option get . background {}] -bd 0 -state disabled
	.cycsegfiles.7.1.list config -bg $evv(EMPH)
	.cycsegfiles.6.ll config -text ""
	.cycsegfiles.6.2 config -text "Get List Of Segments" -bd 2 -state normal
	.cycsegfiles.6.3 config -text "Make List Of Segments" -bd 2 -state normal
	if {[info exists cycseg] && ([string length $cycseg] > 0)} {
		set cycseg_bak $cycseg
		set cycseg ""
	}
}

#------ Use a textfile selected from listing of available files, as a parameter

proc UseSegFile {sfl} {
	global pr_textfile brk text_filecnt seg_listing 

	if {$text_filecnt == 1} {
		set i 0
	} else {
		set i [$sfl curselection]
		if {[llength $i] <= 0} {
			Inf "No File Selected"
			return
		}
	}
	set fnam [$sfl get $i]
	if {![file exists $fnam]} {
		Inf "File '$fnam' No Longer Exists"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam'"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [split $line]
		foreach item  $line {
			if {[string length $item] > 0} {
				lappend segs $item
				break
			}
		}
	}
	close $zit
	if {[llength $segs] <= 0} {
		Inf "No Data Found In File '$fnam'"
		return
	}
	$seg_listing selection clear 0 end
	foreach item $segs {
		$seg_listing insert end $item
	}
	set	pr_textfile 0
}

#------ Use a textfile selected from listing of available files, as a param for mchan rotation

proc UseRotFile {sfl} {
	global pr_textfile brk strotmchspeed text_filecnt

	if {$text_filecnt == 1} {
		set i 0
	} else {
		set i [$sfl curselection]
		if {[llength $i] <= 0} {
			Inf "No File Selected"
			return
		}
	}
	set fnam [$sfl get $i]
	if {![file exists $fnam]} {
		Inf "File $fnam No Longer Exists"
		return
	}
	set strotmchspeed $fnam
	set	pr_textfile 0
}

#------ create a textfile fof individual segment-values on separate lines

proc Dlg_MakeSegfile {} {
	global pr_makesegf textfilenameseg wstk evv
	global wl chlist rememd

	catch {destroy .cpd}

	set f .makesegf

	if [Dlg_Create $f "CREATE A LIST OF SEGMENTS" "set pr_makesegf 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b]
		set k [frame $f.k]		
		button $b.keep   -text "Save File" -command "set pr_makesegf 1" -highlightbackground [option get . background {}]
		label  $b.l -text "filename" 
		entry  $b.e -textvariable textfilenameseg
		button $b.calc -text "Calculator" -width 8 -command "MusicUnitConvertor 0 0" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $b.ref   -text "Reference" -width 8 -command "RefSee $f.k.t" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $b.cancel -text "Close" -command "set pr_makesegf 0" -highlightbackground [option get . background {}]
		pack $b.keep $b.l $b.e -side left -padx 1 -pady 1
		pack $b.cancel $b.calc $b.ref -side right -padx 1 -pady 1
		set t [text $k.t -setgrid true -wrap word -width 84 -height 32 \
		-xscrollcommand "$k.sx set" -yscrollcommand "$k.sy set"]
		scrollbar $k.sy -orient vert  -command "$f.k.t yview"
		scrollbar $k.sx -orient horiz -command "$f.k.t xview"
		pack $k.t -side left -fill both -expand true
		pack $k.sy -side right -fill y
		pack $f.b $f.k -side top -fill x
		bind $f <Return> "set pr_makesegf 1"
		bind $f <Escape> "set pr_makesegf 0"
	}
	$f.b.l config -text "filename" 
	set t $f.k.t
	$t delete 1.0 end
	if [info exists textfilenameseg] {
		ForceVal $f.b.e $textfilenameseg
	}
	set pr_makesegf 0			
	set finished 0
	raise $f
	My_Grab 0 $f pr_makesegf $f.k.t
	while {!$finished} {
		tkwait variable pr_makesegf
		if {$pr_makesegf} {
			set textfilenameseg [string tolower $textfilenameseg]
			set textfilenameseg [FixTxt $textfilenameseg "filename"]
			if {[string length $textfilenameseg] <= 0} {
				ForceVal $f.b.e $textfilenameseg
				continue
			}
			if [ValidCDPRootname $textfilenameseg] {		;#	If not a valid name, stays waiting in dialog
				set origtextfilename $textfilenameseg
				set textfilenameseg [file join $textfilenameseg$evv(TEXT_EXT)]
				if [file exists $textfilenameseg] {
					set it_exists 1
					set choice [tk_messageBox -type yesno -message "File already exists: Overwrite it?" \
							-icon question -parent [lindex $wstk end]]
					if [string match $choice "no"] {
						set textfilenameseg $origtextfilename						
						catch {unset it_exists}
						continue						;#	If file exists, and don't want to overwrite it, 
					}									;#	stays waiting in dialog.
				}
				if {![TestSegFileStructure  .makesegf.k.t]} {
					set textfilenameseg [file rootname $textfilenameseg]
					ForceVal $f.b.e $textfilenameseg
					catch {unset it_exists}
					continue
				}
				if [catch {open $textfilenameseg w} fileId] {
					Inf "Cannot Open File '$textfilenameseg'"	;#	If file not opened, stays waiting in dialog
					catch {unset it_exists}
				} else {
					puts -nonewline $fileId "[$t get 1.0 end]"
					close $fileId						;#	Write data to file
					if {[info exists it_exists]} {
						DummyHistory $textfilenameseg "OVERWRITTEN"
						unset it_exists
					} else {
						DummyHistory $textfilenameseg "CREATED"
					}
 					set ii [LstIndx $textfilenameseg $wl]
					if {$ii >= 0} {
						$wl delete $ii
						WkspCntSimple -1
						catch {unset rememd}
					}
					if {[FileToWkspace $textfilenameseg 0 0 0 0 1] <= 0} {
						if [catch {file delete $textfilenameseg} result] {
							ErrShow "Cannot delete invalid file $textfilenameseg"
						} else {
							DummyHistory $textfilenameseg "DESTROYED"
							DeleteFileFromSrcLists $textfilenameseg
						}
						set textfilenameseg [file rootname $textfilenameseg]
						ForceVal $f.b.e $textfilenameseg
						continue
					}
					set textfilenameseg ""
					ForceVal $f.b.e $textfilenameseg
					set finished 1						;#	And quit dialog
				}
			}
		} else {
			set finished 1								;#	CANCEL: exit dialog
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Ensure values entered in Segfile are on separate lines

proc TestSegFileStructure {t} {
	global seg_listing
	set words ""
	set lines [$t get 1.0 end]
	set lines "[split $lines "\n"]"				;#	split line into single-space separated items
	foreach line $lines {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set vals [split $line]
		if {[llength $vals] > 1} {
			Inf "Each Value Should Be On A Separate Line."
			return 0
		}
		set val [lindex $vals 0]
		if {[string length $val] > 0} {
			set words [concat $words $val]
		}
	}
	set wordcnt [llength $words]
	if {$wordcnt <= 0} {
		Inf "No Values In Table."
		return 0
	}
	$seg_listing delete 0 end
	foreach word $words {
		$seg_listing insert end $word
	}
	return 1
}

#----- Put extracted segments into a textfile

proc CreateSegFile {fnam nunames overwrite} {
	global wl rememd

	if [catch {open $fnam w} fileId] {
		Inf "Cannot Open File '$fnam'"	;#	If file not opened, stays waiting in dialog
		return
	} else {
		foreach segname $nunames {
			puts $fileId $segname
		}
	}
	close $fileId
	if {$overwrite} {
		DummyHistory $fnam "OVERWRITTEN"
	} else {
		DummyHistory $fnam "CREATED"
	}
	set ii [LstIndx $fnam $wl]
	if {$ii >= 0} {
		$wl delete $ii
		WkspCntSimple -1
		catch {unset rememd}
	}
	if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
		if [catch {file delete $fnam} result] {
			ErrShow "CANNOT DELETE INVALID FILE $fnam"
		} else {
			DummyHistory $fnam "DESTROYED"
			DeleteFileFromSrcLists $fnam
		}
	}
}

#---- Select every Nth file and insert or substitute a different file (or remove file from list)

proc CycSubFiles {ilist listing del} {
	global wl ch pr_cycsubfiles cycsub cycsubtyp new_segmented_names cycsubch cycsub_cyc cycsub_stt evv
	global example_asub example_bsub sub_listing wstk sub_listing_bak cycsub_bak was_del cycle_list

	set nunames {}
	catch {unset cycsub_bak}
	set f .cycsubfiles
	if [Dlg_Create $f "SUBSTITUTE, INSERT OR REMOVE A FILE AT EVERY Nth FILE" "set pr_cycsubfiles 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.00 -borderwidth $evv(BBDR)
		frame $f.01 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		frame $f.6 -borderwidth $evv(BBDR)
		frame $f.7 -borderwidth $evv(BBDR)
		frame $f.8 -borderwidth $evv(BBDR)
		button $f.0.add -text "MAKE CHANGES" -command {set pr_cycsubfiles 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_cycsubfiles 0} -highlightbackground [option get . background {}]
		pack $f.0.add -side left
		pack $f.0.q -side right

		label $f.00.ll -text "STEP BY N FILES"
		label $f.01.ll -text "Use a SINGLE step value 'N' or a CYCLE of step values separated by commas  e.g. 2,7,3,1" -fg $evv(SPECIAL)
		entry $f.00.e -textvariable cycsub_cyc -width 20
		label $f.00.ll2 -text "START AT FILE"
		entry $f.00.e2 -textvariable cycsub_stt -width 8
		pack $f.00.ll $f.00.e $f.00.ll2 $f.00.e2 -side left -padx 2
		pack $f.01.ll -side left
		radiobutton $f.1.1 -text "Insert Before File" -variable cycsubtyp -value 0 -command {CycUnKeep 0}
		radiobutton $f.1.2 -text "Substitute File" -variable cycsubtyp -value 1 -command {CycUnKeep 0}
		radiobutton $f.1.3 -text "Get Files to Blist" -variable cycsubtyp -value 3 -command {CycKeep 0}
		pack $f.1.1 $f.1.2 $f.1.3 -side left
		radiobutton $f.4.1 -text "Same File" -variable cycsubch -value 0 -command {set cycsub [HiliteSubSingle $cycsub_bak 0 ]}
		radiobutton $f.4.2 -text "Cyclic List of Files" -variable cycsubch -value 1 -command {set cycsub_bak [HiliteSubList $cycsub]}
		pack $f.4.1 $f.4.2 -side left -padx 2
		entry $f.6.1 -textvariable cycsub -width 48 -bg $evv(EMPH)
		label $f.6.ll -text "File Name"
		button $f.6.3 -text "Get Workspace File" -command {GetWkspaceCycsub}  -highlightbackground [option get . background {}]
		button $f.6.2 -text "Get Background Listing Of Files" -command {GetBlistToCycsub}  -highlightbackground [option get . background {}]
		button $f.6.4 -text "Remove Selected Files Below" -command {DelFromCycsubList}  -highlightbackground [option get . background {}]
		pack $f.6.1 $f.6.ll $f.6.3 -padx 2 -side left
		pack $f.6.4 $f.6.2 -padx 4 -side right
		set sub_listing [Scrolled_Listbox $f.7.1 -width 84 -height 20 -selectmode extended]
		pack $f.7.1 -side top -fill x -expand true
		pack $f.0 $f.00 $f.01 $f.1 $f.4 $f.6 $f.7 -side top -fill x -expand true
		set cycsubtyp 0
		set cycsubch 0
		set cycsub_cyc 1
		set cycsub_stt 1
		bind $f <Return> {set pr_cycsubfiles 1}
		bind $f <Escape> {set pr_cycsubfiles 0}
	}
	.cycsubfiles.7.1.list config -bg [option get . background {}]
	if {($listing == $wl) || ($listing == $ch)} {
		$f.00.ll  config -text "STEP BY N FILES"
		$f.00.ll2 config -text "START AT FILE"
		$f.1.1 config -command {CycUnKeep 0}
		$f.1.2 config -command {CycUnKeep 0}
		$f.1.3 config -command {CycKeep 0}
		$f.4.1 config -command {set cycsub [HiliteSubSingle $cycsub_bak 0]}
	} else {	;# ABANDON BACKING UP LIST TO BLIST
		$f.00.ll  config -text "STEP BY N ITEMS"
		$f.00.ll2 config -text "START AT ITEM"
		$f.1.1 config -command {CycUnKeep 1}
		$f.1.2 config -command {CycUnKeep 1}
		$f.1.3 config -command {CycKeep 1}
		$f.4.1 config -command {set cycsub [HiliteSubSingle $cycsub_bak 1]}
	}
	if {$cycsubtyp == 3} {
		set cycsubtyp 1
	}
	switch -- $del {
		-1 {
			wm title $f "GET EVERY Nth ITEM FROM LIST"
			$f.0.add config -text "GET FILES"
			$f.1.1 config -text "" -state disabled
			$f.1.2 config -text "" -state disabled
			$f.1.3 config -text "" -state disabled
			set retain_cyclist 0
			$f.4.1 config -text "" -state disabled
			$f.4.2 config -text "" -state disabled
			$f.6.1 config -bg [option get . background {}] -bd 0 -state disabled
			$f.6.ll config -text ""
			$f.6.2 config -text "" -bd 0 -state disabled
			$f.6.4 config -text "" -bd 0 -state disabled
			$f.6.3 config -text "" -bd 0 -state disabled
			set sub_listing_bak [$sub_listing get 0 end] 
			$sub_listing delete 0 end
			set cycsubtyp 3
			set cycsubch -1
			set cycsub ""
			set was_del 1
		}
		1 {
			if {($listing == $wl) || ($listing == $ch)} {
				wm title $f "REMOVE EVERY Nth FILENAME FROM LIST"
			} else {
				wm title $f "REMOVE EVERY Nth ITEM FROM LIST"
			}
			$f.0.add config -text "REMOVE FILES"
			$f.1.1 config -text "" -state disabled
			$f.1.2 config -text "" -state disabled
			$f.1.3 config -text "" -state disabled
			set retain_cyclist 0
			$f.4.1 config -text "" -state disabled
			$f.4.2 config -text "" -state disabled
			$f.6.1 config -bg [option get . background {}] -bd 0 -state disabled
			$f.6.ll config -text ""
			$f.6.2 config -text "" -bd 0 -state disabled
			$f.6.4 config -text "" -bd 0 -state disabled
			$f.6.3 config -text "" -bd 0 -state disabled
			set sub_listing_bak [$sub_listing get 0 end] 
			$sub_listing delete 0 end
			set cycsubtyp 2
			set cycsubch -1
			set cycsub ""
			set was_del 1
		}
		0 {
			if {($listing == $wl) || ($listing == $ch)} {
				wm title $f "INSERT FILE AT EVERY Nth POSITION IN LIST"
				$f.0.add config -text "INSERT FILES"
				$f.1.1 config -text "Insert Files Before" -state normal
				$f.1.2 config -text "Substitute Files" -state normal
				$f.1.3 config -text "Get Files to Blist" -state normal
				$f.4.1 config -text "Same File" -state normal
				$f.4.2 config -text "Cyclic List of Files" -state normal
				$f.6.ll config -text "File Name"
				set cycsub_stt 2
			} else {
				$f.0.add config -text "INSERT ITEMS"
				wm title $f "INSERT ITEM AT EVERY Nth POSITION IN LIST"
				$f.1.1 config -text "Insert Items Before" -state normal
				$f.1.2 config -text "Substitute Items" -state normal
				$f.1.3 config -text "Get Items to List Below" -state normal
				$f.4.1 config -text "Same Item" -state normal
				$f.4.2 config -text "Cyclic List of Items" -state normal
				$f.6.ll config -text "Item Value"
			}
			set retain_cyclist 1
			$f.6.1 config -bg $evv(EMPH) -bd 2 -state normal
			$f.6.2 config -text "" -bd 0 -state disabled
			$f.6.4 config -text "" -bd 0 -state disabled
			$f.6.3 config -text "Get Workspace File" -bd 2 -state normal
			if {[info exists sub_listing_bak]} {
				foreach item $sub_listing_bak {
					$sub_listing insert end $item
				}
			}
			if {[info exists was_del]} {
				unset was_del
				set cycsubtyp 1
			}
			set cycsubch 0
		}
	}
	set len_ilist [llength $ilist]
	set finished 0 
	raise $f
	set pr_cycsubfiles 0
	My_Grab 0 $f pr_cycsubfiles $f.00.e
	while {!$finished} {
		tkwait variable pr_cycsubfiles
		if {$pr_cycsubfiles} {
			catch {unset cycsub_cyclist}
			set cycsub_cyc [split $cycsub_cyc]
			catch {unset dfdf}
			foreach item $cycsub_cyc {
				if {[string length $item] > 0} {
					lappend dfdf $item
				}
			}
			if {[info exists dfdf]} {
				set cycsub_cyc [join $dfdf ""]
			} else {
				Inf "No Step (Sequence) Between Files Has Been Entered"
				continue
			}
			if {[regexp {,} $cycsub_cyc]} {
				if {![regexp {^[0-9,]+$} $cycsub_cyc] || ![regexp {[0-9]} $cycsub_cyc]} {
					Inf "Invalid Step (Sequence) Between Files"
					continue
				} else {
					set lastk 0
					set k [string first "," [string range $cycsub_cyc $lastk end]]
					while {$k >= 0} {
						set j [expr $k + $lastk - 1]
						if {$k >= 1} {
							lappend cycsub_cyclist [string range $cycsub_cyc $lastk $j]
						}
						incr k
						incr j
						if {$j >= [string length $cycsub_cyc]} {
							break
						}
						incr lastk $k
						set k [string first "," [string range $cycsub_cyc $lastk end]]
					}
					if {$lastk <= [string length $cycsub_cyc]} {
						lappend cycsub_cyclist [string range $cycsub_cyc $lastk end]
					}
					if {![info exists cycsub_cyclist]} {
						Inf "Invalid Step (Sequence) Between Files"
						continue
					}
				}
			} else {
				if {![regexp {^[0-9]+$} $cycsub_cyc]} {
					Inf "Invalid Step (Sequence) Between Files"
					continue
				} else {
					lappend cycsub_cyclist $cycsub_cyc
				}
			}
			set OK 1
			foreach item $cycsub_cyclist {
				if {$item <= 0} {
					Inf "Invalid Step Value ($item) For Steps Between Files"
					set OK 0
					break
				}
			}
			if {!$OK} {
				continue
			}
			set warned 0 
			if {([llength $cycsub_cyclist] == 1) && ([lindex $cycsub_cyclist 0] >= [expr $len_ilist + 1])} {
				set msg "Step Is Longer Than List : Only One Position Will Be Used: Continue?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				} else {
					set warned 1
				}
			}
			if {(![regexp {^[0-9]+$} $cycsub_stt]) || ($cycsub_stt > [expr $len_ilist + 1]) || ($cycsub_stt <= 0)} {
				Inf "Invalid File To Start At"
				continue
			}
			if {[expr $cycsub_stt + [lindex $cycsub_cyclist 0]] > [expr $len_ilist + 1]} {
				if {!$warned} {
					set msg "Starting At $cycsub_stt And Stepping By [lindex $cycsub_cyclist 0]\nonly One Item Will Be Used: OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
			}
			if {$cycsubtyp < 2} {
				if {$cycsubch == 0} {		;# SINGLE FILE TO SUBSTITUTE OR INSERT.
					if {[string length $cycsub] <= 0} {
						Inf "No Item To Insert Entered"
						continue
					}
					set cycsub [string tolower $cycsub]
					set rname [file rootname $cycsub]
					if {[string match $cycsub $rname]} {
						append cycsub $evv(SNDFILE_EXT)
					}
					if {($listing == $wl) || ($listing == $ch)} {
						if {![ValidCdpFilename $rname 1]} {
							continue
						}
						if {[string match [file tail $cycsub] $cycsub]} {
							set test_fnam [file join [pwd] $cycsub]
						} else {
							set test_fnam $cycsub
						}
						if {![file exists $test_fnam]} {
							Inf "File '$cycsub' Does Not Exist"
							continue
						}
					}
				} else {				;# SEVERAL FILES TO SUBSTITUTE OR ETC.
					if {[$sub_listing index end] <= 0} {
						Inf "You Have Chosen To Use A List Of Files, But No Files Are Listed"
						continue	
					} else {
						set OK 1
						foreach fnam [$sub_listing get 0 end] {
							if {![file exists $fnam]} {
								Inf "File '$fnam' Does Not Exist"
								set OK 0 
								break
							}
						}
						if {!$OK} {
							continue
						}
							
					}
				}
			}
			set nunames {}
			set cyclelist {}
			set OK 1
			set cyc_cnt 0
			if {$cycsubch == 0} {
				set this_cycsub $cycsub
			}
			set cnt 0
			set cycstep_cnt 0
			set cycstep_cnt_max [llength $cycsub_cyclist]
			set act_on [expr $cycsub_stt - 1]
			foreach i $ilist {
				if {$cnt < $act_on} {	;#	SELECT APPROPRIATE FILES
					incr cnt
					if {$cycsubtyp != 3} {
						lappend nunames	[$listing get $i]
					}
					continue
				} elseif {$cnt == $act_on} {
					incr act_on [lindex $cycsub_cyclist $cycstep_cnt]
					incr cycstep_cnt
					if {$cycstep_cnt >= $cycstep_cnt_max} {
						set cycstep_cnt 0
					}
					if {$del < 0} {
						lappend cyclelist $i
					}
				}
				if {$cycsubch == 1} {	;#	CYCLE AROUND FILE NAMES, IF REQUESTED
					set this_cycsub [$sub_listing get $cyc_cnt]
					incr cyc_cnt
					if {$cyc_cnt >= [$sub_listing index end]} {
						set cyc_cnt 0
					}
				}
				switch -- $cycsubtyp {
					0 {	lappend nunames $this_cycsub [$listing get $i]	;#	INSERT FILE }
					1 {	lappend nunames $this_cycsub					;#	SUBSTITUTE FILE }
					2 {													;#	REMOVE FILE }
					3 { lappend nunames [$listing get $i]				;#	GET FILES TO BLIST}
				}
				incr cnt
			}
			set OK 1
			if {($cycsubtyp != 2) && (($listing == $wl) || ($listing == $ch))} {
				set cnt [llength $nunames]
				set cnt_less_one [expr $cnt - 1]
				set n 0
				set use_all_existing_copies 0
				while {$n < $cnt_less_one} {
					set file_n [lindex $nunames $n]
					set m $n
					incr m
					set copcnt 0
					if {$use_all_existing_copies} {
						set use_existing_copies 1
					} else {
						set use_existing_copies 0
					}
					while {$m < $cnt} {
						set file_m [lindex $nunames $m]
						if {[string match $file_m $file_n]} {
							set is_pwd 0
							set dir [file dirname $file_n]
							if {[string length $dir] <= 1} {
								set dir ""
								set is_pwd 1
							}
							set ext [file extension $file_n]
							set basename [file rootname [file tail $file_n]]
							append basename "_cop"
							set thisname $basename$copcnt
							if {$is_pwd} {
								set test_nufnam [file join [pwd] $thisname]
							} else {
								set test_nufnam [file join $dir $thisname]
							}
							append test_nufnam $ext
							set nufnam [file join $dir $thisname]
							append nufnam $ext
							set file_preexists 0
							while {[file exists $test_nufnam]} {
								if {$use_existing_copies} {
									set file_preexists 1
									break	
								} else {
									set msg "Copied Files With The Name '$file_m' Already Exist: Use Those ?"
									set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
									if {$choice == "yes"} {
										set use_existing_copies 1
										set file_preexists 1

										set msg "Use Existing Copied Files In All Cases ?"
										set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
										if {$choice == "yes"} {
											set use_all_existing_copies 1
										}
										break	
									}
								}
								incr copcnt
								set thisname $basename$copcnt
								if {$is_pwd} {
									set test_nufnam [file join [pwd] $thisname]
								} else {
									set test_nufnam [file join $dir $thisname]
								}
								append test_nufnam $ext
								set nufnam [file join $dir $thisname]
								append nufnam $ext
							}
							incr copcnt
							if {!$file_preexists} { 
								if {[catch {file copy $file_n $nufnam} zit]} {
									Inf "Failed To Copy File '$file_n' To '$nufnam'"
									set OK 0
									break
								} else {
									if {[HasPmark $file_n]} {
										CopyPmark $file_n $nufnam
									}
									if {[HasMmark $file_n]} {
										CopyMmark $file_n $nufnam
									}
									DummyHistory $nufnam "CREATED"
								}
							}
							if {[LstIndx $nufnam $wl] < 0} {
								if {$file_preexists} { 
									if {[FileToWkspace $nufnam 0 0 0 0 0] <= 0} {
										set OK 0
										break
									}
								} else {
									if {[FileToWkspace $nufnam 0 0 0 0 1] <= 0} {
										set OK 0
										break
									}
								}
							}
							set nunames [lreplace $nunames $m $m $nufnam]
						}	
						incr m
					}
					if {!$OK} {
						break
					}
					incr n
				}
			}
			if {!$OK} {
				continue
			}
			if {$cycsubtyp == 3} {
				if {$del == -1} {
					set cycle_list $cyclelist
					lappend cycle_list [llength $ilist]
					set finished 1
				} else {
					$sub_listing delete 0 end
					foreach item $nunames {
						$sub_listing insert end $item
					}
					if {($listing == $wl) || ($listing == $ch)} {
						set BOK 1
						foreach fnam [$sub_listing get 0 end] {
							if {[string match [file tail $fnam] $fnam]} {
								set BOK 0
								set msg "Files That Are Not Backed Up Cannot Be Put In A Background Listing.\n\nWould You Like To Put These Files In A Textfile ?"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "yes"} {
									if {[string length $cycsub] <= 0} {
										Inf "No File Name Entered"
										break
									}
									set it_exists 0
									if [ValidCDPRootname $cycsub] {		;#	If not a valid name, stays waiting in dialog
										set cycsubf $cycsub$evv(TEXT_EXT)
										if [file exists $cycsubf] {
											set it_exists 1
											set choice [tk_messageBox -type yesno -message "File '$cycsub' Already Exists: Overwrite It?" \
												-icon question -parent [lindex $wstk end]]
											if [string match $choice "no"] {
												catch {unset it_exists}
												break							;#	If file exists, and don't want to overwrite it, 
											}									;#	stays waiting in dialog.
										}
									}
									if {[info exists it_exists]} {
										CreateSegFile $cycsubf [$sub_listing get 0 end] 1
									} else {
										CreateSegFile $cycsubf [$sub_listing get 0 end] 0
									}

								}
								break
							}
						}
						if {$BOK} {
							BListFromWkspace $sub_listing 0 0
						}
					}
					continue
				}
			}
			set new_segmented_names $nunames
			set finished 1
		} else {
			catch {unset cycle_list}
			set new_segmented_names {}
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $new_segmented_names
}

#------- Reconfigure window for use to Keep selected filenames in a Blist

proc CycKeep {typ} {
	global cycsub_state cycsub evv
	switch -- $typ {
		0 {
			.cycsubfiles.0.add config -text "KEEP FILES"
		}
		1 {
			.cycsubfiles.0.add config -text "KEEP ITEMS"
		}
	}
	.cycsubfiles.4.1 config -state disabled -text ""
	.cycsubfiles.4.2 config -state disabled -text ""
	catch {unset cycsub_state}
	lappend cycsub_state [.cycsubfiles.6.1 cget -state]
	lappend cycsub_state [.cycsubfiles.6.1 cget -bg]
	lappend cycsub_state [.cycsubfiles.6.1 cget -bd]
	lappend cycsub_state [.cycsubfiles.6.ll cget -text]
	lappend cycsub_state [.cycsubfiles.6.2 cget -state]
	lappend cycsub_state [.cycsubfiles.6.2 cget -bg]
	lappend cycsub_state [.cycsubfiles.6.2 cget -bd]
	lappend cycsub_state [.cycsubfiles.6.2 cget -text]
	lappend cycsub_state [.cycsubfiles.6.3 cget -state]
	lappend cycsub_state [.cycsubfiles.6.3 cget -bd]
	lappend cycsub_state [.cycsubfiles.6.3 cget -text]
	lappend cycsub_state [.cycsubfiles.6.4 cget -state]
	lappend cycsub_state [.cycsubfiles.6.4 cget -bd]
	lappend cycsub_state [.cycsubfiles.6.4 cget -text]
	lappend cycsub_state $cycsub

	switch -- $typ {
		0 {
			.cycsubfiles.6.1 config -bg $evv(EMPH) -bd 2 -state normal
			.cycsubfiles.6.ll config -text "File name"
		}
		1 {
			.cycsubfiles.6.1 config -bg [option get . background {}] -bd 0 -state disabled
			.cycsubfiles.6.ll config -text ""
		}
	}
	.cycsubfiles.6.3 config -text "" -state disabled -bd 0
	.cycsubfiles.6.4 config -text "" -state disabled -bd 0
	set cycsub ""
	ForceVal .cycsubfiles.6.1 $cycsub
	.cycsubfiles.6.2 config -bg [option get . background {}] -bd 0 -state disabled -text ""
}

#------- Reconfigure window for normal use (inserting files into list)

proc CycUnKeep {typ} {
	global cycsub_state cycsub evv
	switch -- $typ {
		0 {
			.cycsubfiles.0.add config -text "INSERT FILES"
			.cycsubfiles.4.1 config -state normal -text "Same File"
			.cycsubfiles.4.2 config -state normal -text "Cyclic List of Files"
		}
		1 {
			.cycsubfiles.0.add config -text "INSERT ITEMS"
			.cycsubfiles.4.1 config -state normal -text "Same Item"
			.cycsubfiles.4.2 config -state normal -text "Cyclic List of Items"
		}
	}
	set cnt 0
	if {[info exists cycsub_state]} {
		foreach item $cycsub_state {
			switch -- $cnt {
				0  {.cycsubfiles.6.1 config -state $item}
				1  {.cycsubfiles.6.1 config -bg $item}
				2  {.cycsubfiles.6.1 config -bd $item}
				3  {.cycsubfiles.6.ll config -text $item}
				4  {.cycsubfiles.6.2 config -state $item}
				5  {.cycsubfiles.6.2 config -bg $item}
				6  {.cycsubfiles.6.2 config -bd $item}
				7  {.cycsubfiles.6.2 config -text $item}
				8  {.cycsubfiles.6.3 config -state $item}
				9  {.cycsubfiles.6.3 config -bd $item}
				10 {.cycsubfiles.6.3 config -text $item}
				11 {.cycsubfiles.6.4 config -state $item}
				12 {.cycsubfiles.6.4 config -bd $item}
				13 {.cycsubfiles.6.4 config -text $item}
				14 { set cycsub $item}
			}
			incr cnt
		}
		unset cycsub_state
		ForceVal .cycsubfiles.6.1 $cycsub
	}
}

#------ Reconfigure window for use of a single filename for insertion

proc HiliteSubSingle {inval typ} {
	global cycsub evv
	.cycsubfiles.6.1 config -bg $evv(EMPH) -bd 2 -state normal
	.cycsubfiles.7.1.list config -bg [option get . background {}]
	switch -- $typ {
		0 {
			.cycsubfiles.6.ll config -text "File Name"
		}
		1 {
			.cycsubfiles.6.ll config -text "Item Value"
		}
	}
	.cycsubfiles.6.2 config -text "" -bd 0 -state disabled
	.cycsubfiles.6.4 config -text "" -bd 0 -state disabled
	.cycsubfiles.6.3 config -text "Get Workspace File" -bd 2 -state normal
	set cycsub $inval
	ForceVal .cycsubfiles.6.1 $cycsub
	return $inval
}

#------ Reconfigure window for use of a list of filenames for insertion

proc HiliteSubList {inval} {
	global cycsub evv
	.cycsubfiles.7.1.list config -bg $evv(EMPH)
	.cycsubfiles.6.ll config -text ""
	.cycsubfiles.6.2 config -text "Get Background Listing of Files" -bd 2 -state normal
	.cycsubfiles.6.4 config -text "Remove Selected Files Below" -bd 2 -state normal
	.cycsubfiles.6.3 config -text "" -bd 0 -state disabled
	set cycsub ""
	ForceVal .cycsubfiles.6.1 $cycsub
	.cycsubfiles.6.1 config -bg [option get . background {}] -bd 0 -state disabled
	return $inval
}

#------ Load Background Listing to Cycle Files Page

proc GetBlistToCycsub {} {
	global b_l b_l_name sub_listing
	if {![info exists b_l]} {
		Inf "there Are No Background Listings"
		return
	}
	set b_l_name ""
	GetBLName 3
	if {[string length $b_l_name] > 0} {
		$sub_listing delete 0 end
		foreach fnam $b_l($b_l_name) {
			$sub_listing insert end $fnam
		}
	} else {
		catch {unset b_l_name}
	}
}

#----- Show Soundfiles from Workspace, allow use to select one

proc GetWkspaceCycsub {} {
	global pr_wkcycsub wkcycsub_listing wl pa evv

	set f .wkcycsub
	if [Dlg_Create $f "GETO SOUNDFILE FROM WORKSPACE" "set pr_wkcycsub 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		button $f.0.q -text "CLOSE" -command {set pr_wkcycsub 0} -highlightbackground [option get . background {}]
		pack $f.0.q -side top
		label $f.1.1 -text "SOUNDFILES ON WORKSPACE\nClick on Filename to Select It\n"
		pack $f.1.1 -side top
		set wkcycsub_listing [Scrolled_Listbox $f.2.1 -width 80 -height 36 -selectmode single]
		pack $f.2.1 -side top -fill x -expand true
		pack $f.0 $f.1 $f.2 -side top -pady 4
		bind $wkcycsub_listing <ButtonRelease-1> {SelectWkFileToCycSub}
		bind $f <Return> {set pr_wkcycsub 0}
		bind $f <Escape> {set pr_wkcycsub 0}
		bind $f <Key-space> {set pr_wkcycsub 0}
	}
	$wkcycsub_listing delete 0 end
	foreach fnam [$wl get 0 end] {
		if {[info exists pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(FTYP)) == $evv(SNDFILE))} {
			$wkcycsub_listing insert end $fnam
		}
	}
	set pr_wkcycsub 0 
	raise $f
	My_Grab 0 $f pr_wkcycsub $wkcycsub_listing
	tkwait variable pr_wkcycsub
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Select sndfile and put in value box on cyclic substitution page

proc SelectWkFileToCycSub {} {
	global wkcycsub_listing cycsub pr_wkcycsub

	set i [$wkcycsub_listing curselection]
	set cycsub [$wkcycsub_listing get $i]
	set pr_wkcycsub 0
}

proc DelFromCycsubList {} {
	global sub_listing	
	set ilist [$sub_listing curselection]
	switch -- [llength $ilist] {
		0 {
			Inf "No Files Selected"
			return
		}
		1 {
			$sub_listing delete [lindex $ilist 0]
		}
		default {
			set ilist [ReverseList $ilist]
			foreach i $ilist {
				$sub_listing delete $i
			}
		}
	}
}

#---- Select every Nth file and insert or substitute a different file (or remove file from list)

proc SpecificSegs {ilist listing} {
	global wl ch pr_specsegfiles specseg specsegtyp1 specsegtyp2 new_segmented_names specseg_cyc specseg_stt evv
	global wstk only_if_fexists2 specsegstate

	set nunames {}
	set f .specsegfiles
	if [Dlg_Create $f "WORK ON ITEMS CONTAINING SPECIFIC SEGMENTS" "set pr_specsegfiles 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		frame $f.5 -borderwidth $evv(BBDR)
		frame $f.6 -borderwidth $evv(BBDR)
		button $f.0.add -text "DO IT" -command {set pr_specsegfiles 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_specsegfiles 0} -highlightbackground [option get . background {}]
		pack $f.0.add -side left
		pack $f.0.q -side right
		label $f.1.ll -text "STEP BY N ITEMS"
		label $f.2.ll -text "Use a SINGLE step value 'N' or a CYCLE of step values separated by commas  e.g. 2,7,3,1" -fg $evv(SPECIAL)
		entry $f.1.e -textvariable specseg_cyc -width 20
		label $f.1.ll2 -text "START AT ITEM"
		entry $f.1.e2 -textvariable specseg_stt -width 8
		pack $f.1.ll $f.1.e $f.1.ll2 $f.1.e2 -side left -padx 2
		pack $f.2.ll -side left
		radiobutton $f.3.1 -text "REMOVE FIRST SEGMENT\n IN ITEMS" -variable specsegtyp1 -value 0 -command {SpecSegOnly}
		radiobutton $f.3.2 -text "REMOVE LAST SEGMENT\n IN ITEMS" -variable specsegtyp1 -value 3 -command {SpecSegOnly}
		radiobutton $f.3.3 -text "REMOVE ALL SEGMENTS\n IN ITEMS" -variable specsegtyp1 -value 4 -command {SpecSegOnly}
		radiobutton $f.3.4 -text "REMOVE ITEMS\nCONTAINING SEGMENT" -variable specsegtyp1 -value 1 -command {SpecSegNotOnly}
		radiobutton $f.3.5 -text "KEEP ONLY ITEMS\nCONTAINING SEGMENT" -variable specsegtyp1 -value 2 -command {SpecSegNotOnly}
		radiobutton $f.4.1 -text "segments EQUAL TO given value" -variable specsegtyp2 -value 0
		radiobutton $f.4.2 -text "segments CONTAINING given value" -variable specsegtyp2 -value 5
		pack $f.3.1 $f.3.2 $f.3.3 $f.3.4 $f.3.5 -side left
		pack $f.4.1 $f.4.2 -side left
		label $f.5.ll -text "SEGMENT VALUE to look for"
		entry $f.5.1 -textvariable specseg -width 48 -bg $evv(EMPH)
		pack $f.5.1 $f.5.ll -padx 2 -side left
		checkbutton $f.6.1 -variable only_if_fexists2 -text "Only if renamed items are existing files"
		pack $f.6.1  -padx 2 -side left
		pack $f.0 $f.1 $f.2 $f.3 $f.4 $f.5 $f.6 -side top -fill x -expand true
		set only_if_fexists2 0
		set specseg ""
		set specseg_cyc 1
		set specseg_stt 1
		set specsegtyp1 0
		set specsegtyp2 0
		bind $f <Return> {set pr_specsegfiles 1}
		bind $f <Escape> {set pr_specsegfiles 0}
	}
	if {($listing == $wl) || ($listing == $ch)} {
		set only_if_fexists2 1
		$f.6.1 config -text "" -state disabled
	} else {
		$f.6.1 config -text "Only if renamed items are existing files" -state normal
	}
	catch {unset specsegstate}
	lappend specsegstate [.specsegfiles.6.1 cget -state]
	lappend specsegstate [.specsegfiles.6.1 cget -text]
	set len_ilist [llength $ilist]
	set finished 0 
	raise $f
	set pr_specsegfiles 0
	My_Grab 0 $f pr_specsegfiles $f.1.e
	while {!$finished} {
		tkwait variable pr_specsegfiles
		if {$pr_specsegfiles} {
			catch {unset specseg_cyclist}
			set specseg_cyc [split $specseg_cyc]
			catch {unset dfdf}
			foreach item $specseg_cyc {
				if {[string length $item] > 0} {
					lappend dfdf $item
				}
			}
			if {[info exists dfdf]} {
				set specseg_cyc [join $dfdf ""]
			} else {
				Inf "No Step (Sequence) Between Files Has Been Entered"
				continue
			}
			if {[regexp {,} $specseg_cyc]} {
				if {![regexp {^[0-9,]+$} $specseg_cyc] || ![regexp {[0-9]} $specseg_cyc]} {
					Inf "Invalid Step (Sequence) Between Files"
					continue
				} else {
					set lastk 0
					set k [string first "," [string range $specseg_cyc $lastk end]]
					while {$k >= 0} {
						set j [expr $k + $lastk - 1]
						if {$k >= 1} {
							lappend specseg_cyclist [string range $specseg_cyc $lastk $j]
						}
						incr k
						incr j
						if {$j >= [string length $specseg_cyc]} {
							break
						}
						incr lastk $k
						set k [string first "," [string range $specseg_cyc $lastk end]]
					}
					if {$lastk <= [string length $specseg_cyc]} {
						lappend specseg_cyclist [string range $specseg_cyc $lastk end]
					}
					if {![info exists specseg_cyclist]} {
						Inf "Invalid Step (Sequence) Between Files"
						continue
					}
				}
			} else {
				if {![regexp {^[0-9]+$} $specseg_cyc]} {
					Inf "Invalid Step (Sequence) Between Files"
					continue
				} else {
					lappend specseg_cyclist $specseg_cyc
				}
			}
			set OK 1
			foreach item $specseg_cyclist {
				if {$item <= 0} {
					Inf "Invalid Step Value ($item) For Steps Between Files"
					set OK 0
					break
				}
			}
			if {!$OK} {
				continue
			}
			set warned 0 
			if {([llength $specseg_cyclist] == 1) && ([lindex $specseg_cyclist 0] >= [expr $len_ilist + 1])} {
				set msg "Step Is Longer Than List Of Files: Only One Position Will Be Used: Continue?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				} else {
					set warned 1
				}
			}
			if {(![regexp {^[0-9]+$} $specseg_stt]) || ($specseg_stt > [expr $len_ilist + 1]) || ($specseg_stt <= 0)} {
				Inf "Invalid File To Start At"
				continue
			}
			if {[expr $specseg_stt + [lindex $specseg_cyclist 0]] > [expr $len_ilist + 1]} {
				if {!$warned} {
					set msg "Starting At $specseg_stt And Stepping By [lindex $specseg_cyclist 0]\nonly One Item Will Be Used: OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
			}
			if {[string length $specseg] <= 0} {
				Inf "No Segment Value Entered"
				continue
			}
			set specseg [string tolower $specseg]
			if {![regexp {^[a-z0-9\-]+$} $specseg]} {
				Inf "Invalid Segment Value Entered"
				continue
			}
			set nunames {}
			set cnt 0
			set cycstep_cnt 0
			set cycstep_cnt_max [llength $specseg_cyclist]
			set act_on [expr $specseg_stt - 1]
			set is_changed 0
			set OK2 1
			foreach i $ilist {
				set inname [$listing get $i]
				set basename [file rootname [file tail $inname]]
				if {[llength [CheckSegmentation $basename 1]] <= 0} {
					set OK2 0
					break 
				}
				set ext [file extension $inname]
				set dir [file dirname $inname]
				if {[string length $dir] <= 1} {
					set dir ""
				}				
				set inlen [string length $basename]
				if {$cnt < $act_on} {	;#	SELECT APPROPRIATE FILES
					lappend nunames	$inname	;#	KEEP ALL FILES NOT ACTED UPON
					incr cnt
					continue
				} elseif {$cnt == $act_on} {
					incr act_on [lindex $specseg_cyclist $cycstep_cnt]
					incr cycstep_cnt
					if {$cycstep_cnt >= $cycstep_cnt_max} {
						set cycstep_cnt 0
					}
				}
				if {$specsegtyp1 == 4} {			;#	REMOVE ALL SEGMENTS
					set nuname [RecursivelyRemoveSeg $basename $specseg $specsegtyp2 $inlen]
					if {[string length $nuname] <= 0} {
						Inf "Item '$inname' Will Be Completely Deleted: Cannot Proceed"
						set OK2 0
						break
					} elseif {![string match $nuname $basename]} {
						set nuname [file join $dir $nuname]
						append nuname $ext
						if {$only_if_fexists2} {
							set testfnam $nuname
							if {[string length $dir] <= 0} {
								set testfnam [file join [pwd] $testfnam]
							}
							if {![file exists $testfnam]} {
								Inf "File '$testfnam' Does Not Exist"
								set OK2 0
								break
							}
						}
						set is_changed 1
					} else {
						set nuname [file join $dir $nuname]
						append nuname $ext
					}
					lappend nunames $nuname
					incr cnt
					continue
				} else {
					if {$specsegtyp1 == 3} {		;#	LAST SEGMENT
						set flist [FindLastSeg $basename $specseg $specsegtyp2 $inlen]
					} else {						;#	FIRST SEGMENT
						set flist [FindFirstSeg $basename $specseg $specsegtyp2 $inlen]
					}
					if {[llength $flist] <= 0} {	;#	ITEM DOES NOT CONTAIN SEG
						if {$specsegtyp1 == 2} {	;#	specsegtyp1 = 2 KEEP ITEMS HAVING SPECIFIC SEGMENTS, So DON'T KEEP it
							set is_changed 1
						} else {					;#	specsegtyp1 = 0 CHANGE SEGS IN SUCH ITEMS, NOT SUCH AN ITEM So KEEP it without change
							lappend nunames	$inname	;#	specsegtyp1 = 1 REMOVE ITEMS HAVING SPECIFIC SEG: doesn't have seg, So KEEP it
						}
						incr cnt
						continue
					}
					switch -- $specsegtyp1 {
						0 -
						3 {	;#	REMOVE SEGMENT
							set j [lindex $flist 0]			;#	SEGMENT START
							set k [lindex $flist 1]			;#	SEGMENT END
							set at_start [lindex $flist 2]
							set at_end   [lindex $flist 3]
							incr j -2
							incr k 2
							if {$at_start} {
								set nuname [string range $basename $k end]
							} elseif {$at_end} {
								set nuname [string range $basename 0 $j]
							} else {
								set nuname [string range $basename 0 $j]
								incr k -1
								append nuname [string range $basename $k end]
							}
							set nuname [file join $dir $nuname]
							append nuname $ext
							if {$only_if_fexists2} {
								set testfnam $nuname
								if {[string length $dir] <= 0} {
									set testfnam [file join [pwd] $testfnam]
								}
								if {![file exists $testfnam]} {
									Inf "File '$testfnam' Does Not Exist"
									set OK2 0
									break
								}
							}
							lappend nunames $nuname
							set is_changed 1
						}
						1 {	;#	REMOVE ITEM HAVING SEGMENT
							set is_changed 1
						}
						2 {	;#	KEEP ITEM HAVING SEGMENT
							lappend nunames $inname
						}
					}
				}
				incr cnt
			}
			if {!$OK2} {
				set new_segmented_names {}
				break
			}
			if {[llength $nunames] <= 0} {
				Inf "No Items Were Retained"
				continue
			}
			if {!$is_changed} {
				Inf "No Item Was Modified Or Removed"
				continue
			}
			set new_segmented_names $nunames
			set finished 1
		} else {
			set new_segmented_names {}
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $new_segmented_names
}

#------ Remove all occurences of segment in name

proc RecursivelyRemoveSeg {inname specseg can_be_unequal inlen} {

	set nuname $inname
	set inlen [string length $inname]
	set k [string first $specseg $nuname]
	while {$k >= 0} {
		set endk $k
		incr endk [string length $specseg]
		set is_equal 1
		set at_start 0
		set at_end 0
		if {$k == 0} {
			set j 0
			set at_start 1
		} else {
			set j $k
			incr k -1
			while {![string match "_" [string index $nuname $k]]} {
				set is_equal 0
				set j $k
				incr k -1
				if {$k < 0} {
					break
				}
			}
		}
		set k $endk
		if {$k < $inlen} {
			while {![string match "_" [string index $nuname $k]]} {
				set is_equal 0
				incr k
				if {$k >= $inlen} {
					set at_end 1
					break
				}
			}
		} else {
			set at_end 1
		}
		incr k -1
		if {!$can_be_unequal && !$is_equal} {
			if {$at_end} {
				break
			}
			incr k 2			;#	PUT POINTER TO START OF NEXT SEGMENT
			if {$k >= [string length $nuname]} {
				break
			}
			set lastk $k		;#	SEARCH IN REMAINDER OF NAME
			set k [string first $specseg [string range $nuname $lastk end]]
			if {$k >= 0} {
				incr k $lastk	;# BUT INDEX TO WHOLE NAME
			}
			continue
		}
		if {$at_start} {
			incr k 2
			set nuname [string range $nuname $k end]
		} elseif {$at_end} {
			incr j -2		
			set nuname [string range $nuname 0 $j]
			break
		} else {
			incr j -2		
			set xnuname [string range $nuname 0 $j]
			incr k
			append xnuname [string range $nuname $k end]
			set nuname $xnuname
		}
		set inlen [string length $nuname]
		if {!$can_be_unequal} {		;#	IN THIS CASE THERE COULD BE MATCHING SEGMENTS ALREADY IN NAME
			if {$at_start} {		;#	BUT WHICH DON'T MEET THE must_be_equal CRITERION.
				set lastk 0			;#	TO AVOID SEEING THESE AGAIN, WE MUST SEARCH ONLY THE REMAINDER OF THE NAME
			} else {
				set lastk [expr $j + 2]
			}
			set k [string first $specseg [string range $nuname $lastk end]]
			if {$k >= 0} {
				incr k $lastk
			}						;#	IF must_be_equal IS NOT BEING USED, ALL PREVIOUS SEGS HAVE BEEN ELIMINATED
		} else {					;#	SO WE CAN SEARCH FROM THE START OF THE NEW NAME
			set k [string first $specseg $nuname]
		}
	}
	return $nuname
}

#------ Find first occurence of segment in name

proc FindFirstSeg {basename specseg can_be_unequal inlen} {

	set k [string first $specseg $basename]
	while {$k >= 0} {
		set endk $k
		incr endk [string length $specseg]
		set is_equal 1
		set at_start 0
		set at_end 0

		if {$k == 0} {
			set j 0
			set at_start 1
		} else {
			set j $k
			incr k -1
			while {![string match "_" [string index $basename $k]]} {
				set is_equal 0
				set j $k
				incr k -1
				if {$k < 0} {
					break
				}
			}
		}
		set k $endk
		if {$k < $inlen} {
			while {![string match "_" [string index $basename $k]]} {
				set is_equal 0
				incr k
				if {$k >= $inlen} {
					set at_end 1
					break
				}
			}
		} else {
			set at_end 1
		}
		incr k -1

		if {!$can_be_unequal && !$is_equal} {	;#	SEARCH ONLY REMAINDER OF NAME
			if {$at_end} {
				set k -1
				break
			} else {
				set lastk [expr $k + 2]
				if {$lastk >= [string length $basename]} {
					set k -1
					break
				}
			}
			set k [string first $specseg [string range $basename $lastk end]]
			if {$k >= 0} {
				incr k $lastk
			}
		} else {
			break
		}
	}
	if {$k < 0} {					;#	ITEM DOES NOT CONTAIN SEG
		return {}
	}
	return [list $j $k $at_start $at_end]
}

#------ Find last occurence of segment in name

proc FindLastSeg {basename specseg can_be_unequal inlen} {

	set k [string last $specseg $basename]
	while {$k >= 0} {
		set endk $k
		incr endk [string length $specseg]
		set is_equal 1
		set at_start 0
		set at_end 0

		if {$k == 0} {
			set j 0
			set at_start 1
		} else {
			set j $k
			incr k -1
			while {![string match "_" [string index $basename $k]]} {
				set is_equal 0
				set j $k
				incr k -1
				if {$k < 0} {
					break
				}
			}
		}
		set k $endk
		if {$k < $inlen} {
			while {![string match "_" [string index $basename $k]]} {
				set is_equal 0
				incr k
				if {$k >= $inlen} {
					set at_end 1
					break
				}
			}
		} else {
			set at_end 1
		}
		incr k -1
		if {!$can_be_unequal && !$is_equal} {	;#	SEARCH ONLY REMAINDER OF NAME
			if {$at_start} {
				set k -1
				break
			} else {
				set lastj [expr $j - 2]
				if {$lastj < 0} {
					set k -1
					break
				}
			}
			set k [string last $specseg [string range $basename 0 $lastj]]
		} else {
			break
		}
	}
	if {$k < 0} {					;#	ITEM DOES NOT CONTAIN SEG
		return {}
	}
	return [list $j $k $at_start $at_end]
}

#----- Toggle specficsegs checkbutton to allow choice of 'Only if renamed items are existing files" (if appropriate)

proc SpecSegOnly {} {
	global specsegstate

	if {[info exists specsegstate]} {
		set cnt 0
		foreach item $specsegstate {
			switch -- $cnt {
				0  {.specsegfiles.6.1 config -state $item}
				1  {.specsegfiles.6.1 config -text $item}
			}
			incr cnt
		}
	}
}

#----- Toggle specficsegs checkbutton to disable choice on 'Only if renamed items are existing files" 

proc SpecSegNotOnly {} {
	global specsegstate
	catch {unset specsegstate}
	lappend specsegstate [.specsegfiles.6.1 cget -state]
	lappend specsegstate [.specsegfiles.6.1 cget -text]
	
	.specsegfiles.6.1 config -text "" -state disabled
}

#---- Extract pairs of files where wnd is transform of first

proc ExtractTransformationPairs {} {
	global pr_transpairs trans_segs_string tpselseg_no seltyp new_segmented_names evv
	global tp_deleteables tabed tp_endsegs ignore_if_fexists tpseltyp trans_in_list wstk

	set ti $tabed.bot.itframe.l.list
	set to $tabed.bot.otframe.l.list
	set returnval 0
	set namepairs {}
	set f .tranpairfiles
	if [Dlg_Create $f "SELECT TRANSFORMATION PAIRS INDICATED BY NAME SEGMENTS" "set pr_transpairs 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.1a -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		frame $f.5 -borderwidth $evv(BBDR)
		frame $f.5a -borderwidth $evv(BBDR)
		frame $f.6 -borderwidth $evv(BBDR)
		button $f.0.add -text "GET TRANSFORMATION PAIRINGS" -command {set pr_transpairs 1} -width 33 -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_transpairs 0} -highlightbackground [option get . background {}]
		pack $f.0.add -side left
		pack $f.0.q -side right
		label $f.1.ll -text "SEGMENTS, IN ORDER OF THE TRANSFORMATIONS THEY REPRESENT (separated by commas)"
		pack $f.1.ll -side top
		entry $f.1a.e -textvariable trans_segs_string -width 48 -bg $evv(EMPH)
		pack $f.1a.e -side top
		radiobutton $f.2.1 -text "Use leading segments" -variable tp_endsegs -value 0
		radiobutton $f.2.2 -text "Use trailing segments" -variable tp_endsegs -value 1
		pack $f.2.1 $f.2.2 -side left
		label $f.3.1 -text "HOW TO MATCH THE SEGMENTS"
		pack $f.3.1 -side top
		radiobutton $f.4.1 -text "Use Whole Segment" -variable tpseltyp -value 0
		radiobutton $f.4.2 -text "Use Any of Segment" -variable tpseltyp -value 1
		radiobutton $f.4.3 -text "Use Segment Start" -variable tpseltyp -value 2
		radiobutton $f.4.4 -text "Use Segment End" -variable tpseltyp -value 3
		pack $f.4.1 $f.4.2 $f.4.3 $f.4.4 -side left
		checkbutton $f.5.1 -variable ignore_if_fexists -text "Ignore transformed files which already exist"
		pack $f.5.1 -side top
		checkbutton $f.5a.1 -variable trans_in_list -text "Get only transformations made on files already in the list"
		pack $f.5a.1 -side top
		radiobutton $f.6.1 -variable tp_deleteables -text "Show the transformations needed" -value 0 -command ShowTrans
		radiobutton $f.6.2 -variable tp_deleteables -text "Show deleteable intermediate files" -value 1 -command ShowTransDels
		pack $f.6.1 -side left
		pack $f.6.2 -side right
		pack $f.0 $f.1 $f.1a $f.2 $f.3 $f.4 $f.5 $f.5a $f.6 -side top -fill x -expand true
		set tp_endsegs 0
		set tpseltyp 0
		set trans_in_list 0
		set ignore_if_fexists 0
		bind $f <Return> {set pr_transpairs 1}
		bind $f <Escape> {set pr_transpairs 0}
	}
	set tp_deleteables 0
	ShowTrans 
	raise $f
	set pr_transpairs 0
	My_Grab 0 $f pr_transpairs $f.1a.e 
	set finished 0 
	while {!$finished} {
		tkwait variable pr_transpairs
		if {$pr_transpairs} {
			if {[string length $trans_segs_string] <= 0} {
				Inf "No Segment Strings Entered"
				continue
			}
			set trans_segs_string [string tolower $trans_segs_string]
			catch {unset trans_seglist}
			if {[regexp {,} $trans_segs_string]} {
				if {![regexp {^[a-zA-Z0-9\-,]+$} $trans_segs_string] || ![regexp {[a-zA-Z0-9\-]+} $trans_segs_string]} {
					Inf "Invalid Segment Values : Letters,Numbers & Hyphen Only, with segments separated by Commas"
					continue
				} else {
					set lastk 0
					set k [string first "," [string range $trans_segs_string $lastk end]]
					while {$k >= 0} {
						set j [expr $k + $lastk - 1]
						if {$k >= 1} {
							lappend trans_seglist [string range $trans_segs_string $lastk $j]
						}
						incr k
						incr j
						if {$j >= [string length $trans_segs_string]} {
							break
						}
						incr lastk $k
						set k [string first "," [string range $trans_segs_string $lastk end]]
					}
					if {$lastk <= [string length $trans_segs_string]} {
						lappend trans_seglist [string range $trans_segs_string $lastk end]
					}
					if {![info exists trans_seglist]} {
						Inf "Invalid Segment Values"
						continue
					}
				}
			} else {
				if {![regexp {^[a-zA-Z0-9\-]+$} $trans_segs_string]} {
					Inf "Invalid Segment Value : Letters,Numbers & Hyphen Only"
					continue
				} else {
					lappend trans_seglist $trans_segs_string
				}
			}
			set namepairs {}
			set OK 1
			set badsegs {}
			catch {unset found_it}
			foreach item $trans_seglist {
				lappend found_it 0
			}
			Block "SEARCHING FOR SEGMENTS"
			foreach fullname [$ti get 0 end] {
				set basename [file rootname [file tail $fullname]]
				set separatorlist [CheckSegmentation $basename 0]
				set slen [llength $separatorlist]
				if {$slen <= 0} {
					lappend badsegs $basename
					continue
				}
				set seglist_index 0
				foreach trans_seg $trans_seglist {		;# FOR EVERY LISTED SEGMENT-VAL
					set segindex 0
					set seg_occurences 0
					set at -1
					while {$segindex <= $slen} {			;#	SEARCH EVERY SEGMENT IN THE NAME
						if {$segindex == 0} {
							set k [lindex $separatorlist 0]
							incr k -1
							set compo [string range $basename 0 $k]
						} elseif {$segindex == $slen} {
							set k [lindex $separatorlist end]
							incr k
							set compo [string range $basename $k end]
						} else {
							set j [lindex $separatorlist [expr $segindex - 1]]
							incr j
							set k [lindex $separatorlist $segindex]
							incr k -1
							set compo [string range $basename $j $k]
						}
						switch -- $tpseltyp {
							0 {	;#	WHOLE SEGMENT
								if {[string match $trans_seg $compo]} {
									incr seg_occurences
									set at $segindex
								}
							}
							1 {	;#	ANY OF SEGMENT
								if {[regexp $trans_seg $compo]} {
									incr seg_occurences
									set at $segindex
								}
							}
							2 {	;#	SEGMENT START
								if {[string match $trans_seg* $compo]} {
									incr seg_occurences
									set at $segindex
								}
							}
							3 {	;#	SEGMENT END
								if {[string match *$trans_seg $compo]} {
									incr seg_occurences
									set at $segindex
								}
							}
						}
						incr segindex
					}
					if {$seg_occurences > 1} {
						Inf "Segment '$trans_seg' Occurs More Than Once In '$basename': Cannot Proceed"
						set OK 0
						break
					}
					if {($at == 0) && $tp_endsegs} {
						Inf "Segment '$trans_seg' Occurs At The Start Of '$basename': Cannot Proceed"
						set OK 0
						break
					} elseif {($at == $slen) && !$tp_endsegs} {
						Inf "Segment '$trans_seg' Occurs At The End Of '$basename': Cannot Proceed"
						set OK 0
						break
					}
															;#	NOTE THAT AT LEAST ONE OCCURENCE OF SEG HAS BEEN FOUND
					if {$seg_occurences == 1} {
						set found_it [lreplace $found_it $seglist_index $seglist_index 1]
					}
					incr seglist_index
				}
				if {!$OK} {
					break
				}
			}
			UnBlock
			if {!$OK} {
				continue
			}
			if {!$trans_in_list} {
				if {[llength $badsegs] > 0} {
					set msg "The Following Items Are Not Segmented Correctly.\n\n"
					foreach fnam $badsegs {
						append msg $fnam ",  "
					}
					append msg "\n\nDo You Wish To Proceed ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set returnval 0
						break
					}
				}
			}
			set cnt 0
			set msgcnt 0
			catch {unset msg}
			foreach val $found_it {
				if {[lindex $found_it $cnt] == 0} {
					if {$msgcnt == 0} {
						set msg [lindex $trans_seglist $cnt]
						incr msgcnt
					} else {
						append msg ", " [lindex $trans_seglist $cnt]
					}
				}
				incr cnt
			}
			if {[info exists msg]} {
				append msg "  Were Not Found In Any Item In The List"
				Inf $msg
				continue
			}
			Block "PAIRING FILES"
			set a_file_exists 0
			set origlist [$ti get 0 end]
			set origbaselist {}
			foreach fullname $origlist {
				lappend origbaselist [file rootname [file tail $fullname]]
			}
			foreach trans_seg $trans_seglist {		;# FOR EVERY LISTED SEGMENT-VAL
				set transforms_cnt 0
				foreach fullname $origlist basename $origbaselist {
					set dir [file dirname $fullname]
					if {[string length $dir] <= 1} {
						set dir ""
					}
					set ext [file extension $fullname]
					set separatorlist [CheckSegmentation $basename 0]
					set slen [llength $separatorlist]
					if {$slen <= 0} {
						continue
					}
					set seglist_index 0
					set segindex 0
					set OK 0
					while {$segindex <= $slen} {			;#	SEARCH EVERY SEGMENT IN THE NAME
						if {$segindex == 0} {
							set k [lindex $separatorlist 0]
							incr k -1
							set compo [string range $basename 0 $k]
						} elseif {$segindex == $slen} {
							set k [lindex $separatorlist end]
							incr k
							set compo [string range $basename $k end]
						} else {
							set j [lindex $separatorlist [expr $segindex - 1]]
							incr j
							set k [lindex $separatorlist $segindex]
							incr k -1
							set compo [string range $basename $j $k]
						}
						switch -- $tpseltyp {
							0 {	;#	WHOLE SEGMENT
								if {[string match $trans_seg $compo]} {
									set OK 1
									break
								}
							}
							1 {	;#	ANY OF SEGMENT
								if {[regexp $trans_seg $compo]} {
									set OK 1
									break
								}
							}
							2 {	;#	SEGMENT START
								if {[string match $trans_seg* $compo]} {
									set OK 1
									break
								}
							}
							3 {	;#	SEGMENT END
								if {[string match *$trans_seg $compo]} {
									set OK 1
									break
								}
							}
						}
						incr segindex
					}
					if {$OK} {
						if {$tp_endsegs} {		;#	SEGMENTS ARE AT END OF NAME
							if {$segindex == $slen} {
								incr k -2
								set zz [string range $basename 0 $k]
								lappend zz [string range $basename 0 end]
							} else {
								incr j -2
								set zz [string range $basename 0 $j]
								incr j 2
								while {![string match "_" [string index $basename $j]]} {
									incr j
								}
								incr j -1
								lappend zz [string range $basename 0 $j]
							}
						} else {				;#	SEGMENTS ARE AT START OF NAME
							if {$segindex == 0} {
								while {![string match "_" [string index $basename $k]]} {
									incr k
								}
								incr k
								set zz [string range $basename $k end]
								lappend zz [string range $basename 0 end]
							} else {
								set k $j
								while {![string match "_" [string index $basename $k]]} {
									incr k
								}
								incr k
								set zz [string range $basename $k end]
								lappend zz [string range $basename $j end]
							}
						}
						if {$ignore_if_fexists} {
							set fnam [lindex $zz 1]
							if {[string length $dir] <= 0} {
								set fnam [file join [pwd] $fnam]
							} else {
								set fnam [file join $dir $fnam]
							}
							append fnam $ext
							if {[file exists $fnam]} {
								set a_file_exists 1
								continue
							}
						}
						if {$trans_in_list} {
							set fnam [lindex $zz 0]
							if {[lsearch $origbaselist $fnam] < 0} {
								continue
							}
						}
						catch {unset yy}
						foreach fnam $zz {
							set fnam [file join $dir $fnam]
							append fnam $ext
							lappend yy $fnam
						}
						set namepair [join $yy]
						if {[lsearch $namepairs $namepair] < 0} {
							lappend namepairs $namepair
							incr transforms_cnt
						}
					}
				}
				if {$transforms_cnt > 0} {
					if {!$tp_deleteables} {
						lappend namepairs ""
					}
				}
			}
			if {![info exists namepairs] || ([llength $namepairs] <= 0)} {
				if {$a_file_exists} {
					ForceVal $tabed.message.e  "NO TRANSFORMATIONS ARE NECESSARY: ALL FILES EXIST"
					$tabed.message.e config -bg $evv(EMPH)
				} else {
					ForceVal $tabed.message.e  "NO TRANSFORMATIONS ARE NECESSARY"
					$tabed.message.e config -bg $evv(EMPH)
				}
				set returnval 0
				UnBlock
				break
			}
			if {$tp_deleteables} {
				set namepairs [ExtractDeletables $namepairs [$ti get 0 end]]
				if {[llength $namepairs] <= 0} {
					ForceVal $tabed.message.e  "There are no deleteable intermediate files"
					$tabed.message.e config -bg $evv(EMPH)
					set returnval 0
					UnBlock
					break
				}
			} else {
				set len [llength $namepairs]
				incr len -2
				set namepairs [lrange $namepairs 0 $len]	;#	ERASE FINAL BLANK LINE
			}
			$to delete 0 end
			foreach namepair $namepairs {
				$to	insert end $namepair
			}
			set returnval 1
			UnBlock
			break
		} else {
			set returnval 0
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $returnval
}

#--- Extract intermediate transformation files which are not needed

proc ExtractDeletables {namepairs origs} {
	global tabed
	foreach namepair $namepairs {
		set namepair [split $namepair]
		set output [lindex $namepair 1]
		if {[lsearch $origs $output] < 0} {
			lappend deleteables $output
		}
	}
	if {![info exists deleteables]} {
		return {}
	}
	return $deleteables
}

proc ShowTrans {} {
	.tranpairfiles.0.add config -text "GET TRANSFORMATION PAIRINGS"
}

proc ShowTransDels {} {
	.tranpairfiles.0.add config -text "SHOW REDUNDANT INTERMEDIATE FILES"
}

proc SplitTransforms {} {
	global tabed outcolcnt tot_outlines col_tabname wstk wl lmo record_temacro temacro colpar threshold evv

	set to $tabed.bot.otframe.l.list 

	HaltCursCop
	set lmo "st"
	lappend lmo 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	if {([string length $tot_outlines] <= 0) || ($tot_outlines <= 0 )} {
		ForceVal $tabed.message.e  "This process applies to the output table: THERE IS NO OUTPUT TABLE"
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$outcolcnt != 2} {
		ForceVal $tabed.message.e  "The Output Table does not contain two columns"
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	set cnt 0
	set segcnt 0
	foreach line [$to get 0 end] {
		set val [lindex $line 1]
		set separatorlist [CheckSegmentation $val 0]
		if {[llength $separatorlist] <= 0} {
			ForceVal $tabed.message.e  "Output Name $val is not segmented correctly: cannot proceed"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		set k [lindex $separatorlist end]
		incr k
		set thisseg [string range $val $k end]
		if {$cnt == 0} {
			set segval($segcnt) $thisseg
		} elseif {![string match $segval($segcnt) $thisseg]} {
			lappend entrycnts $cnt
			incr segcnt
			set segval($segcnt) $thisseg
			set cnt 0
		} 
		incr cnt
	}
	lappend entrycnts $cnt
	set cnt 0
	set files_exist {}
	while {$cnt <= $segcnt} {
		set this_ext [GetTextfileExtension sndlist]
		set fnam $segval($cnt)$this_ext
		if {[file exists $fnam]} {
			lappend files_exist $fnam
		}
		lappend fnams $fnam
		incr cnt
	}
	if {[llength $files_exist] > 0} {
		set msg "The Following Data Files Already Exist....\n"
		foreach item $files_exist {
			append msg $item "   "
		}
		append msg "\nDo You Want To Overwrite Them ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	set cnt 0
	foreach fnam $fnams {
		if [catch {open $fnam w} zit($cnt)] {
			set closecnt 0
			while {$closecnt < $cnt} {
				catch {close $zit($closecnt)}
				incr closecnt
			}
			ForceVal $tabed.message.e  "Failed to open file $fnam"
			$tabed.message.e config -bg $evv(EMPH)
			return
		}
		incr cnt
	}
	set filecnt 0
	set entrycnt 0
	set entrycntindex 0
	set maxentrycnt [lindex $entrycnts $entrycntindex]
	foreach line [$to get 0 end] {
		if {$entrycnt >= $maxentrycnt} {
			catch {close $zit($filecnt)}
			incr filecnt
			incr entrycntindex
			set maxentrycnt [lindex $entrycnts $entrycntindex]
			set entrycnt 0
		}
		puts $zit($filecnt) [lindex $line 0]
		incr entrycnt
	}
	close $zit($filecnt)
	set fnams [ReverseList $fnams]
	foreach fnam $fnams {
		if {[LstIndx $fnam $wl] < 0} {
			if {[lsearch $files_exist $fnam] >= 0} {
				FileToWkspace $fnam 0 0 0 0 0
			} else {
				FileToWkspace $fnam 0 0 0 0 1
			}
		}
	}
	foreach fnam $fnams {
		if {[LstIndx $fnam $tabed.bot.fframe.l.list] < 0} {
			$tabed.bot.fframe.l.list insert 0 $fnam
		}
	}
}

#---- Reverse segments within a filename

proc ReverseNameSegs {ilist listing} {
	global pr_revsegs wl ch new_segmented_names evv wstk wl ch

	foreach i $ilist {
		set fnam [$listing get $i]
		set inname [file rootname [file tail $fnam]]
		set dir [file dirname $fnam]
		if {[string length $dir] <= 1} {
			set dir ""
		}
		set ext [file extension $fnam]
		set separatorlist [CheckSegmentation $inname 0]
		set separatorcnt [llength $separatorlist]
		if {$separatorcnt <= 0} {
			lappend nunames $fnam
			lappend badfiles $inname
			continue
		}
		set cnt 0
		set k 0
		catch {unset seglist}
		while {$cnt <= $separatorcnt} {
			if {$cnt == $separatorcnt} {
				lappend seglist [string range $inname $k end]
			} else {
				set j $k
				set k [lindex $separatorlist $cnt]
				incr k -1
				lappend seglist [string range $inname $j $k]
				incr k 2
			}
			incr cnt
		}
		set seglist [ReverseList $seglist]
		set nuname ""
		foreach seg $seglist {
			append nuname $seg "_"
		}
		set len [string length $nuname]
		incr len -2
		set nuname [string range $nuname 0 $len]
		if {($listing == $wl) || ($listing == $ch)} {
			if {[string length $dir] <= 1} {
				set testfnam [file join [pwd] $nuname]
			} else {
				set testfnam [file join $dir $nuname]
			}
			append testfnam $ext
			if {[file exists $testfnam]} {
				Inf "File '$testfnam' Already Exists"
				set nunames {}
				return
			}
		}
		set nuname [file join $dir $nuname]
		append nuname $ext
		lappend nunames $nuname
	}
	if {[info exists badfiles]} {
		set msg "The Following Items Were Incorrectly Segmented\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg $fnam "   "
			incr cnt
			if {$cnt > 20} {
				append msg "And More"
				break
			}
		}
		append msg "\n\nDo You Wish To Ignore These, And Continue Reversing The Other Items?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return {}
		}
	}
	return $nunames
}

#
# MUST BE ON JOIN MENU
#

#----- Process takes a listing-of-pairs-of-files, being input and output from processes, gathered in groups
#----- so first process applies to first group of files, 2nd to 2nd group etc.
#----- Plus a list of batchfiles, 1 for each group of file-pairs
#----- And generates a super batchfile to process all the file(pairs).

proc AssembleTransformBatch {} {
	global tabed outcolcnt tot_outlines col_tabname wstk wl lmo record_temacro temacro colpar threshold evv
	global col_files_list ot_has_fnams tabedit_ns tabedit_bind2 col_infnam colinmode float_out

	set to $tabed.bot.otframe.l.list 
	set tb $tabed.bot
	set d "disabled"
	set n "normal"

	HaltCursCop
	set lmo "atb"
	lappend lmo 0
	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz $colpar
		lappend zxz $threshold
		lappend temacrop $zxz
	}

	if {$ot_has_fnams} {						 ;#	If new fnames entered, use them - else use previous
		catch {unset col_files_list}
		foreach fnam [$to get 0 end] {
			lappend col_files_list $fnam
		}
	}
	if {([string length $col_files_list] <= 0) || ($col_files_list <= 0)} {
		ForceVal $tabed.message.e  "No files to process."
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	if {$col_files_list < 2} {
		ForceVal $tabed.message.e  "Insufficient files to process. Requires 1 paired-sndfile textfile, and some batchfiles"
		$tabed.message.e config -bg $evv(EMPH)
		return
	}
	Block "Scanning Files"
	set pairfnam [$to get 0]
	if [catch {open $pairfnam r} zit] {
		ForceVal $tabed.message.e  "Cannot open file '$pairfnam' to read data"
		$tabed.message.e config -bg $evv(EMPH)
		UnBlock
		return
	}
	set docol_OK 1
	while {$docol_OK} {
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				lappend origlines $line		
			}
		}
		close $zit
		if {![info exists origlines]} {
			ForceVal $tabed.message.e  "No data found in file $pairfnam"
			$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
			break
		}
		set infnams {}
		set outfnams {}
		foreach line $origlines {			;#	CHECK VIABILITY & CONSISTENCY OF DATA IN PAIR-FILE
			set line [string trim $line]
			set line [split $line]
			set nuline {}
			foreach item $line {
				if {[string length $item] > 0} {
					lappend nuline $item

				}
			}
			set line $nuline
			if {[llength $line] != 2} {
				ForceVal $tabed.message.e  "$pairfnam contains invalid lines"
				$tabed.message.e config -bg $evv(EMPH)
				set docol_OK 0
				break
			}
			set infnam [lindex $line 0]
			if {[lsearch $infnams $infnam] < 0} {
				if {![file exists $infnam]} {
					if {[lsearch $outfnams $infnam] < 0} {
						ForceVal $tabed.message.e  "Input file $infnam neither exists nor is generated by another process"
						$tabed.message.e config -bg $evv(EMPH)
						set docol_OK 0
						break
					}
				}
				lappend infnams $infnam	
			}
			set outfnam [lindex $line 1]
			if {[lsearch $outfnams $outfnam] < 0} {
				if {[file exists $outfnam]} {
					ForceVal $tabed.message.e  "File $outfnam listed as an output in $pairfnam already exists"
					$tabed.message.e config -bg $evv(EMPH)
					set docol_OK 0
					break
				}
				lappend outfnams $outfnam	
			} else {
				ForceVal $tabed.message.e  "File $outfnam listed as an output in $pairfnam is generated more than once"
				$tabed.message.e config -bg $evv(EMPH)
				set docol_OK 0
				break
			}
			lappend in_pairs $line
		}
		if {!$docol_OK} {
			break
		}
		set cnt 0
		set segcnt 0
		foreach line $in_pairs {			;#	CHECK SYNTAX OF OUTNAMES, AND ASSEMBLE INTO GROUPS FOR PROCESSING
			set val [lindex $line 1]
			set separatorlist [CheckSegmentation $val 0]
			if {[llength $separatorlist] <= 0} {
				ForceVal $tabed.message.e  "Output Name $val in file $pairfnam not segmented correctly: can't proceed"
				$tabed.message.e config -bg $evv(EMPH)
				set docol_OK 0
				break
			}
			set k [lindex $separatorlist end]
			incr k
			set thisseg [string range $val $k end]
			if {$cnt == 0} {
				set segval($segcnt) $thisseg
			} elseif {![string match $segval($segcnt) $thisseg]} {
				lappend entrycnts $cnt
				incr segcnt
				set segval($segcnt) $thisseg
				set cnt 0
			} 
			incr cnt
		}
		if {!$docol_OK} {
			break
		}
		lappend entrycnts $cnt
											;#	CHECK NO OF GRPS-TO-PROCESS = NO OF BATCH-PROCESS FILES
		if {[llength $entrycnts] != [expr [llength $col_files_list] - 1]} {
			ForceVal $tabed.message.e  "No. of groups-of-files to process does not tally with no. of process-batchfiles"
			$tabed.message.e config -bg $evv(EMPH)
			set docol_OK 0
			break
		}
		set file_to_process_no 0
											;#	EXAMINE EACH BATCHFILE
		set nubatch {}
		foreach bfnam [$to get 1 end] entrycnt $entrycnts {
			if [catch {open $bfnam r} zit] {
				ForceVal $tabed.message.e  "Cannot open file '$bfnam' to read data BATCH"
				$tabed.message.e config -bg $evv(EMPH)
				set docol_OK 0
				break
			}
			catch {unset blines}
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				set line [split $line]
				set nuline {}
				foreach item $line {
					if {[string length $item] > 0} {
						lappend nuline $item

					}
				}
				set line $nuline
				if {[string length $line] > 0} {
					lappend blines $line		
				}
			}
			close $zit
			set blen [llength $blines]
			catch {unset nublines}
			set lastline [expr $blen - 1]
			if {$blen <= 0} {
				ForceVal $tabed.message.e  "No data found in file $bfnam"
				$tabed.message.e config -bg $evv(EMPH)
				set docol_OK 0
				break
			}
			set inpos [ExtractPosInBatchLine infile [lindex $blines 0]]
			 if {$inpos <= 0} {
				set docol_OK 0
				break
			}
			set last_line [lindex $blines $lastline]
			set outpos [ExtractPosInBatchLine outfile $last_line]
			if {$outpos <= 0} {
				set docol_OK 0
				break
			}
			set is_balance 0
			if {$blen > 1} {
				set nublines $blines
				catch {unset origoutfnams}
				catch {unset origextensions}
				catch {unset outfnams}
				incr lastline -1
				set cnt 0
				foreach line [lrange $blines 0 $lastline] {			;#	REPLACE ALL INTERMEDIATE OUTFILES BY TEMPORARY FILES
					set o_outpos [ExtractPosInBatchLine outfile $line]
					set origoutfnam [lindex $line $o_outpos]
					if {[string match $evv(FLOAT_OUT)* $origoutfnam]} {
						set origoutfnam [string range $origoutfnam [string length $evv(FLOAT_OUT)] end]
					}
					set ext [file extension $origoutfnam]
					if {[string length $ext] <= 0} {
						set ext [ExtractPosInBatchLine outtype $line]
						if {[string length $ext] <= 0} {
							set docol_OK 0
							break
						}
					}
					lappend origoutfnams $origoutfnam
					lappend origextensions $ext
					set outfnam $evv(DFLT_OUTNAME)
					append outfnam $cnt
					lappend outfnams $outfnam
					if {$float_out} {
						set line [lreplace $line $o_outpos $o_outpos $evv(FLOAT_OUT)$outfnam]
					} else {
						set line [lreplace $line $o_outpos $o_outpos $outfnam]
					}
					set nublines [lreplace $nublines $cnt $cnt $line]
					incr cnt
				}
				if {!$docol_OK} {
					break
				}
				catch {unset origoutfnams_with_ext}
				set xcnt 0
				foreach origoutfnam $origoutfnams origextension $origextensions {
					if {[string match [file rootname $origoutfnam] $origoutfnam]} {
						lappend origoutfnams_with_ext $origoutfnam$origextension
					} else {
						lappend origoutfnams_with_ext $origoutfnam
						set origoutfnams [lreplace $origoutfnams $xcnt $xcnt [file rootname $origoutfnam]]
					}
					incr xcnt
				}
				incr lastline
				if {[info exists origoutfnams]} {					;#	CHECK IF ANY INTERMEDIATE OUTFILES ARE FED BACK INTO PROCESS
					set cnt 0										;#	AND IF SO, REPLACE THEM WITH THE APPROPRIATE TEMP FILE
					foreach line $nublines {
						set i_inpos [ExtractPosInBatchLine infile $line]
						set originfnam [lindex $line $i_inpos]
						set k [lsearch $origoutfnams $originfnam]
						if {$k < 0} {
							set k [lsearch $origoutfnams_with_ext $originfnam]
						}
						if {$k>=0} {
							set outfnam [lindex $outfnams $k]
							set line [lreplace $line $i_inpos $i_inpos $outfnam]
							set nublines [lreplace $nublines $cnt $cnt $line]
						}
						incr cnt
					}
				}
				set blines $nublines
				unset nublines
				foreach outfnam $outfnams ext $origextensions {		;#	CREATE LINES FOR BATCH TO DELETE ALL INTERMEDIATE TEMP FILES
					append outfnam $ext
					set line [list "del" $outfnam]
					lappend nublines $line
				}
				if {[LastLineIsBalance $last_line]} {
					set is_balance 1
				}
			}
			set cnt 0
			while {$cnt < $entrycnt} {
				set thispair [lindex $in_pairs $file_to_process_no]
				set this_infnam [lindex $thispair 0]
				set this_outfnam [lindex $thispair 1]
				set outlines $blines
				set startline [lindex $outlines 0]
				set startline [lreplace $startline $inpos $inpos $this_infnam]
				set outlines [lreplace $outlines 0 0 $startline]
				set endline [lindex $outlines $lastline]
				if {$float_out} {
					set endline [lreplace $endline $outpos $outpos $evv(FLOAT_OUT)$this_outfnam]
				} else {
					set endline [lreplace $endline $outpos $outpos $this_outfnam]
				}
				if {$is_balance} {
					set endline [lreplace $endline 4 4 $this_infnam]
				}
				set outlines [lreplace $outlines $lastline $lastline $endline]
				if [info exists nublines] {
					set outlines [concat $outlines $nublines]
				}
				set nubatch [concat $nubatch $outlines]
				incr cnt
				incr file_to_process_no
			}
		}
		if {!$docol_OK} {
			break
		}
		$to delete 0 end
		foreach line $nubatch {
			$to insert end $line
		}
		break
	}
	if {$docol_OK} {
		catch {close $fileot}
		if [catch {open $evv(COLFILE3) "w"} fileot] {
			ForceVal $tabed.message.e  "Cannot open temporary file $evv(COLFILE3) to write new table"
			$tabed.message.e config -bg $evv(EMPH)
			$tb.otframe.l.list delete 0 end		;#	Clear existing listing of output table
		} else {
			set outcolcnt 0
			set tot_outlines 0
			foreach line [$tb.otframe.l.list get 0 end] {
				if {!$outcolcnt} {
					foreach val $line {
						set val [string trim $val]
						if {[string length $val] > 0} {
							 incr outcolcnt
						}
					}
				}
				incr tot_outlines
				puts $fileot $line
			}
			close $fileot						;#	Write data to file
		}

		EnableOutputTableOptions 0 1
		set colinmode 0
		set ot_has_fnams 0
		ChangeColSelect 0
	}
	UnBlock
}

#------ Find position of infile and outfile, and type of outfile, in CDP command line

proc ExtractPosInBatchLine {which batchline} {	;#	which = infile,outile.outtype
	global wstk new_cdp_extensions evv

	foreach word $batchline {
		set word [string tolower $word]
		lappend nuline $word
	}
	set batchline $nuline

	set ggrp [lindex $batchline 0]
	set pprg [lindex $batchline 1]
	set mmod [lindex $batchline 2]

	if {[IsStandaloneProgWithNonCDPFormat $ggrp]} {
		Inf "This Procedure Does Not Work With Standalone Programs"
		switch -- $which {
			"infile" -
			"outfile" {
				return 0
			}
			default {
				return ""
			}
		}
	}
	switch -- $ggrp {
		"specross"	-
		"analjoin"	{
			Inf "Cannot Handle Process ([string toupper $ggrp] [string toupper $pprg]) With More Than One Input File"
			set pos {}
		}
		"psow" {
			switch -- $pprg {
				"interp"	-
				"impose"	-
				"interleave" -
				"replace" {
					Inf "Cannot Handle Process ([string toupper $ggrp] [string toupper $pprg]) With More Than One Input File"
					set pos {}
				}
				"features"	-
				"synth"		-
				"cutatgrain" -
				"reinforce" {
					set pos [list 3 4 snd]
				} 
				"locate" {
					set pos [list 2 3 text]
				}
				default {
					set pos [list 2 3 snd]
				} 
			}
		}
		"ptobrk"  {	set pos [list 2 3 brk] }
		"oneform" {	set pos [list 2 3 frm]	}
		"specnu"  {	set pos [list 3 4 anal]	}
		"prefix"  {	set pos [list 2 3 snd]	}
		"strans"  {	set pos [list 3 4 snd]	}
		"get_partials" { set pos [list 3 4 text] }
		"lucier" {
			switch -- $pprg {
				"getfilt" {
					set pos [list 2 3 text]
				}
				"get" {
					set pos [list 2 3 anal]
				}
				"impose" {
					set msg "Process (Lucier Impose) Has A 2nd Input Analysis File.\n"
					append msg "If This Is Always The Same As In The Model Batch Process Provided, You Can Proceed.\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 2 4 anal]
					}	
				}
				"suppress" {
					set msg "Process (Lucier Suppress) Has A 2nd Input Analysis File.\n"
					append msg "If This Is Always The Same As In The Model Batch Process Provided, You Can Proceed.\n\n"
					append msg "Is This Ok ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 2 4 anal]
					}
				}
			}
		}
		"blur" {
			if {$pprg == "chorus"} {
				set pos [list 3 4 anal]
			} else {
				set pos [list 2 3 anal]
			}
		}
		"combine" {
			switch -- $pprg {
				"mean" {
					set msg "Process (Combine Mean) Has A 2nd Input Analysis File.\n"
					append msg "If This Is Always The Same As In The Model Batch Process Provided, You Can Proceed.\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 3 5 anal]
					}
				}
				"diff"  -
				"sum"   -
				"cross" {
					set msg "Process ([string toupper $ggrp] [string toupper $pprg]) Has A 2nd Input Analysis File.\n"
					append msg "If This Is Always The Same As In The Model Batch Process Provided, You Can Proceed.\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 2 4 anal]
					}
				}
				"interleave" -
				"max" -
				"make" -
				"make2" {
					Inf "Cannot Handle Process '([string toupper $ggrp] [string toupper $pprg])' With More Than One Input File"
					set pos {}
				}
				default {
					Inf "Unknown Combine Spectra Process Found"
					set pos {}
				}
			}
		}
		"distort" {
			switch -- $pprg {
				"interact" {
					set msg "Process (Distort Interact) Has A 2nd Input File.\n"
					append msg "If This Is Always The Same As In The Model Batch Process Provided, You Can Proceed.\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 3 5 snd]
					}
				}
				"cyclecnt" {
					Inf "Cannot Handle Distort Cyclecnt As It Has No Output Files"
					set pos {}
				}
				"delete"	-
				"envel"		-
				"filter"	-
				"overload"  -
				"reform" {
					set pos [list 3 4 snd]
				}
				default {
					set pos [list 2 3 snd]
				}
			}
		}
		"envel" {
			switch -- $pprg {
				"brktoenv" -
				"dbtoenv" {
					set pos [list 2 3 env]
				}
				"envtobrk" -
				"envtodb"  -
				"dbtogain" -
				"gaintodb" {
					set pos [list 2 3 brk]
				}
				"dovetail" -
				"swell" -
	    		"pluck" {
					set pos [list 2 3 snd]
				}
				"impose" -
				"replace" {
					set msg "Process ([string toupper $ggrp] [string toupper $pprg]) Takes A 2nd (Enveloping) File\n"
					append msg "If This Is Always The Same File, You Can Proceed\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 3 5 snd]
					}
				}
				"scaled" {
					set msg "Process ([string toupper $ggrp] [string toupper $pprg]) Takes A 2nd (enveloping) File\n"
					append msg "If This Is Always The Same File, You Can Proceed\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 2 4 snd]
					}
				}
				"attack" -
				"curtail" -
				"tremolo" {
					set pos [list 3 4 snd]
				}
				"extract" {
					switch -- $mmod {
						1 {
							set pos [list 3 4 env]
						}
						2  {
							set pos [list 3 4 brk]
						}
						default {
							Inf "Unknown Envel Extract Process Found"
							set pos {}
						}
					}
				}
				"replot" {
					set pos [list 3 4 brk]
				}
				"reshape" {
					set pos [list 3 4 env]
				}
				"warp" {
					set pos [list 3 4 snd]
				}
				default {
					Inf "Unknown Envelope Process Found"
					set pos {}
				}
			}
		}
		"extend" {
			set pos [list 3 4 snd]
		}
		"filter" {
			switch -- $pprg {
				"bankfrqs" {
					set pos [list 3 4 text]
				}
				default {
					set pos [list 3 4 snd]
				}
			}
		}
		"flutter" {
			set pos [list 2 3 snd]
		}
		"focus" {
			switch -- $pprg {
				"freeze" {
					set pos [list 3 4 anal]
				}
				default {
					set pos [list 2 3 anal]
				}
			}
		}
		"formants" {
			switch -- $pprg {
				"see" -
				"getsee"  {
					Inf "This Procedure Will Not Work With Formant Viewing Processes"
					set pos {}
				}
				"put" {
					set msg "Process [string toupper $ggrp] [string toupper $pprg] Takes A 2nd (Formant) File\n"
					append msg "If This Is Always The Same File, You Can Proceed\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 3 5 anal]
					}
				}
				"get" {
					set pos [list 2 4 frm]
				}
				"vocode" {
					set msg "Process ([string toupper $ggrp] [string toupper $pprg]) Takes A 2nd (Analysis) File\n"
					append msg "If This Is Always The Same File, You Can Proceed\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 2 4 anal]
					}
				}
				default {
					Inf "Unknown Formants Process Found"
					set pos {}
				}
			}
		}
		"grain" {
			switch -- $pprg {
				"align" {
					set msg "Process ([string toupper $ggrp] [string toupper $pprg]) Takes A 2nd Grainy Sound File\n"
					append msg "If This Is Always The Same File, You Can Proceed\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 2 4 snd]
					}
				}
				"count" {
					Inf "This Procedure Will Not Work With The Grain Counting Process"
					set pos {}
				}
				"find" {
					set pos [list 2 3 text]
				}
				"remotif" -
				"repitch" -
				"rerhythm" {
					set pos [list 3 4 snd]
				}
				default {
					set pos [list 2 3 snd]
				}
			}
		}
		"hfperm" {
			Inf "This Procedure Will Not Work With The Harmonic Field Processes"
			set pos {}
		}
		"hilite" {
			switch -- $pprg {
				"arpeg"	 -
				"filter" -
				"greq"   -
				"trace" {
					set pos [list 3 4 anal]
				}
				default {
					set pos [list 2 3 anal]
				}
			}
		}
		"housekeep" {
			switch -- $pprg {
				"respec" {
					set pos [list 3 4 snd]
				}
				"bundle" {
					Inf "This Procedure Does Not Work With Housekeep Bundle"
					set pos {}
				}
				"chans" {
					switch -- $mmod {
						1 -
						2 {
							Inf "This Procedure Does Not Work With Channel Extraction"
							set pos {}
						}
						default {
							set pos [list 3 4 snd]
						}
					}
				}
				"copy" {
					switch -- $mmod {
						1 {
							set pos [list 3 4 snd]
						}
						2 {
							Inf "This Procedure Does Not Work With Housekeep Multiple Copying"
							set pos {}
						}
					}
				}
				"extract" {
					switch -- $mmod {
						1 -
						2 -
						5 {
							Inf "This Procedure Does Not Work With Housekeep Gated Extraction"
							set pos {}
						}
						3 -
						4 {
							set pos [list 3 4 snd]
						}
						6 {
							set pos [list 3 4 text]
						}
						default {
							Inf "Unknown Housekeep Process Found"
							set pos {}
						}
					}
				}
				"disk" {
					Inf "This Procedure Does Not Work With Housekeep Find Diskspace"
					set pos {}
				}
				"remove" {
					Inf "This Procedure Does Not Work With Housekeep Remove Multiple Copies"
					set pos {}
				}
				"sort" {
					Inf "This Procedure Does Not Work With Housekeep Sorting Procedures"
					set pos {}
				}
				default {
					Inf "This Procedure Does Not Work With A Housekeep Procedure Being Used"
					set pos {}
				}
			}
		}
		"mchanpan" {
			set pos [list 3 4 snd]
		}
		"mchanrev" {
			set pos [list 2 3 snd]
		}
		"modify" {
			switch -- $pprg {
				"brassage" {
					set pos [list 3 4 snd]
				}
				"sausage" -
				"wrappage" {
					Inf "This Procedure Does Not Work With Sausage or Wrappage As They Have Multiple Input Files"
					set pos {}
				}
				"loudness" {
					switch -- $mmod {
						1 -
						2 -
						3 -
						4 -
						6 {
							set pos [list 3 4 snd]
						}
						5 {
							set msg "Process (Loudness Balance) Takes A 2nd Sound File\n"
							append msg "If This Is Always The Same File, Or The 1st Input File To The Batch, You Can Proceed\n\n"
							append msg "Is This OK ?"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set pos {}
							} else {
								set pos [list 3 5 snd]
							}
						}
						7 -
						8 {
							Inf "This Procedure Does Not Work Loudness Processes With Many Input Files"
							set pos {}
						}
						8 {
							Inf "Unknown Loudness Process Found"
							set pos {}
						}
					}
				}
				"speed" {
					switch -- $mmod {
						3 -
						4 {
							set pos [list 3 4 brk]
						}
						default {
							set pos [list 3 4 snd]
						}
					}
				}
				"radical" {
					switch -- $mmod {
						6 {
							set msg "Process (Radical Cross-Modulate) Takes A 2nd Sound File\n"
							append msg "If This Is Always The Same File, You Can Proceed\n\n"
							append msg "Is This OK ?"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set pos {}
							} else {
								set pos [list 3 5 snd]
							}
						}
						default {
							set pos [list 3 4 snd]
						}
					}
				}
				"stack" {
					set pos [list 2 3 snd]
				}
				"revecho" {
					set pos [list 3 4 snd]
				}
				"space" { 
					switch -- $mmod {
						3 {
							set pos [list 3 4 brk]
						}
						default {
							set pos [list 3 4 snd]
						}
					}
				}
				default {
					Inf "Unknown Process Found"
					set pos {}
				}
			}
		}
		"morph" {
			set msg "Process ([string toupper $ggrp] [string toupper $pprg]) Takes A 2nd Analysis File\n"
			append msg "If This Is Always The Same File, You Can Proceed\n\n"
			append msg "Is This OK ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set pos {}
			} else {
				switch -- $pprg {
					"bridge" -
					"morph" {
						set pos [list 3 5 anal]
					}
					"glide" {
						set pos [list 2 4 anal]
					}
				}
			}
		}
		"newmorph" {
			set msg "Process [string toupper $ggrp] [string toupper $pprg] Takes A 2nd Analysis File\n"
			append msg "If This Is Always The Same File, You Can Proceed\n\n"
			append msg "Is This Ok ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set pos {}
			} else {
				set pos [list 3 5 anal]
			}
		}
		"multimix" {
			set msg "Mixing Process May Involve More Than One Input Sound.\n"
			append msg "This Procedure Assumes You Have ~Only One~ Input Sound To The Mix\n\n"
			append msg "Is This Ok ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set pos {}
			} else {
				set pos [list 3 4 snd]
			}
		}
		"newmix" {
			set pos [list 2 3 snd]
		}
		"pitch" {
			switch -- $pprg {
				"chordf" -
				"chord" {
					set pos [list 2 3 anal]
				}
				"pick" -
				"transp" -
				"tune" {
					set pos [list 3 4 anal]
				}
				"altharms" -
				"octmove" {
					set msg "This Procedure Does Not Work With Pitch Processes\n"
					append msg "Octave Move, Or Alternate Harmonics\n"
					append msg "As They Require A 2nd Input (Pitch Data) File Derived From The First\n"
					Inf $msg
					set pos {}
				}
				default {
					Inf "Unknown Spectral Pitch:Harmony Process Found"
					set pos {}
				}
			}

		}
		"pitchinfo" {
			set msg "This Procedure Does Not Work With Pitch Info Processes"
			set pos {}
		}
		"pvoc" {
			switch -- $pprg {
				"anal" {
					set pos [list 3 4 anal]
				}
				"extract" -
				"synth" {
					set pos [list 2 3 snd]
				}
				default {
					Inf "Unknown Pvoc Process Found"
					set pos {}
				}
			}
		}
		"repitch" {
			switch -- $pprg {
				"getpitch" {
					set msg "Process ([string toupper $ggrp] [string toupper $pprg]) Outputs An Analysis File & A Pitchdata File.\n"
					append msg "This Procedure Assumes You Want The Pitch Data File.\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set msg "Do You Want The Analysis Data Output File Instead ??\n"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set pos {}
						} else {
							set pos [list 3 4 pch]
						}
					} else {
						set pos [list 3 5 pch]
					}
				}				
	    		"exag" -
	    		"approx" -
	    		"invert" -
	    		"quantise" -
				"randomise" -
	    		"smooth" -
				"vibrato" {
					switch -- $mmod {
						1 {
							set pos [list 3 4 pch]
						}
						2 {
							set pos [list 3 4 trn]
						}
						default {
							Inf "Unknown Repitch Process Found"
							set pos {}
						}
					}
				}
				"cut" -
				"insertsil" -
				"insertzeros" {
					set pos [list 3 4 pch]
				}
				"fix"		 -
	    		"pchshift"	 -
				"noisetosil" -
				"pitchtosil" {
					set pos [list 2 3 pch]
				}
				"combine" -
				"combineb" {
					set msg "Repitch Combine Processes Takes A 2nd File\n"
					append msg "If This Is Always The Same File, You Can Proceed\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						switch -- $pprg {
							"combine" {
								switch -- $mmod {
									1 { set pos [list 3 5 trn] }
									2 { set pos [list 3 5 pch] }
									3 { set pos [list 3 5 trn] }
									default {
										Inf "Unknown Repitch Process Found"
										set pos {}
									}
								}
							}"combineb" {
								set pos [list 3 5 brk]
							}
						}
					}
				}
				"transposef" -
				"transpose" {
					switch -- $mmod {
						4 {
							set msg "Repitch Transpose Processes Using A Binary Transposition Are Used Here.\n"
							append msg "If This Is Always The Same File, You Can Proceed\n\n"
							append msg "is This OK ?"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set pos {}
							} else {
								set pos [list 3 5 anal]
							}
						}
						default {
							set pos [list 3 4 anal]
						}
					}
				}
				"analenv" {
					set pos [list 2 3 env]
				}
				"vowels" -
				"synth" {
					set pos [list 2 3 anal]
				}
				default {
					Inf "Unknown Repitch Program Found"
					set pos {}
				}
			}
		}
		"sfedit" -
		"editsf" {
			switch -- $pprg {
	    		"twixt" -
	    		"sphinx" -
				"randchunks" -
				"randcuts" -
				"join" {
					set msg "This Procedure Will Not Handle Edit Join, Editing Out Random Chunks Or Splices,\n"
					append msg "Or Edit Switching Or Sphinxing Between Sources, As Multiple Files Are Involved."
					Inf $msg
					set pos {}
				}
				"insert" {
					set msg "Edit Insert Involves A 2nd Input File, For Insertion.\n"
					append msg "If This Is Always The Same File, You Can Proceed\n\n"
					append msg "Is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 3 5 snd]
					}
				}
				default {
					set pos [list 3 4 snd]
				}
			}
		}
		"sndinfo" {
			set msg "This Procedure Does Not Handle Sound Info Processes"
			set pos {}
		}
		"spec" {
			switch -- $pprg {
				"bare" -
				"clean" {
					set msg "This Procedure Does Not Handle Spectral Cleaning Processes, (Bare Partials Or Clean on 'Simple' Menu)"
				}
				default {
					set pos [list 2 3 anal]
				}
			}
		}
		"specinfo" {
			set msg "This Procedure Does Not Handle Spectral Info Processes"
			set pos {}
		}
		"strange" {
			set pos [list 3 4 anal]
		}
		"stretch" {
			switch -- $pprg {
				"spectrum" {
					set pos [list 3 4 snd]
				}					
				"time" {
					switch -- $mmod {
						1 {
							set pos [list 3 4 snd]
						}
						2 {
							set msg "This Procedure Does Not Handle The Process Which Merely Calculates A Time Stretch, But Has No Output"
							set pos {}
						}
						default {
							Inf "Unknown Time Stretch Program Found"
							set pos {}
						}
					}
				}
				default {
					Inf "Unknown Stretch Program Found"
					set pos {}
				}
			}
		}
		"submix" {
			switch -- $pprg {
	    		"dummy" -
				"interleave" {
					set msg "This Procedure Does Not Handle Creating Mixfiles From Multiple Soundfile Inputs,\n"
					append msg "or Interleave-Mixing Of Several Sounds"
					Inf $msg
					set pos {}
				}
				"test" -
	    		"getlevel" {
					Inf "This Procedure Does Not Handle Testing Mixfile Syntax Or Levels."
					set pos {}
				}
				"inbetween" {
					Inf "This Procedure Does Not Handle The Inbetweening Process, As It Has Multiple Outputs"
					set pos {}
				}
				"merge" -
				"balance" {
					set msg "Mix Merge Or Balance Involve A 2nd Input File.\n"
					append msg "if This Is Always The Same File, You Can Proceed\n\n"
					append msg "is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 2 4 snd]
					}
				}
				"crossfade" {
					set msg "Mix Crossfade Involves A 2nd Input File.\n"
					append msg "if This Is Always The Same File, You Can Proceed\n\n"
					append msg "is This OK ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set pos {}
					} else {
						set pos [list 3 5 snd]
					}
				}
	    		"mix" {
					set pos [list 2 3 snd]
				}
				"shuffle" -
				"spacewarp" -
				"sync" -
				"timewarp" {
					set pos [list 3 4 mix]
				}
				"syncattack" -
				"attenuate" {
					set pos [list 2 3 mix]
				}
				default {
					Inf "unknown Mix Process Found"
					set pos {}
				}
			}
		}
		"synth" {
			set msg "This Procedure Does Not Handle Synthesis Processes."
			set pos {}
		}
		"texmchan" -
		"texture" {
			set msg "Texture Processes May Involve More Than One Input Sound.\n"
			append msg "this Procedure Assumes You Have **Only One** Input Sound To The Texture\n\n"
			append msg "is This OK ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set pos {}
			} else {
				set pos [list 3 4 snd]
			}
		}
		"wrappage" {
			set msg "Brassage Processes May Involve More Than One Input Sound.\n"
			append msg "This Procedure Assumes You Have ~Only One~ Input Sound To The Process\n\n"
			append msg "Is This Ok ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set pos {}
			} else {
				set pos [list 2 3 snd]
			}
		}
		"phase" {
			set pos [list 3 4 snd]
		}
		"chanphase" {
			set pos [list 2 3 snd]
		}
		"silend" {
			set pos [list 3 4 snd]
		}
		default {
			Inf "Unknown Process In Batchfile"
			set pos {}
		}
	}
	switch -- $which {
		"infile" {
			if {[llength $pos] <= 0} {
				return 0
			}
			return [lindex $pos 0]
		}
		"outfile" {
			if {[llength $pos] <= 0} {
				return 0
			}
			return [lindex $pos 1]
		}
	}
	;# which == "outtype"
	if {[llength $pos] <= 0} {
		return ""
	}
	set ext [lindex $pos 2]

	if {$new_cdp_extensions} {
		switch -- $ext {
			"snd"	{return $evv(SNDFILE_EXT)}
			"anal" 	{return $evv(ANALFILE_EXT)}
			"pch" 	{return $evv(PITCHFILE_EXT)}
			"trn"	{return $evv(TRANSPOSFILE_EXT)}
			"frm"	{return $evv(FORMANTFILE_EXT)}
			"env" 	{return $evv(ENVFILE_EXT)}
			"mix"	{return [GetTextfileExtension mix]}
			"mmx"	{return [GetTextfileExtension mmx]}
			"brk"	{return [GetTextfileExtension brk]}
			"text" 	{return $evv(TEXT_EXT)}
		}
	} else {
		switch -- $ext {
			"text" 	{return $evv(TEXT_EXT)}
			"snd"	-
			"anal" 	-
			"pch" 	-
			"trn"	-
			"frm"	-
			"mix"	{return [GetTextfileExtension mix]}
			"mmx"	{return [GetTextfileExtension mmx]}
			"brk"	{return [GetTextfileExtension brk]}
			"env" 	{return $evv(SNDFILE_EXT)}
		}
	}
	Inf "Unknown File Extension Generated By Procedure"
	return ""
}

proc TransformationBatchfileHelp {} {
	set msg "PROCESSING TRANSFORMATIONS-PAIRS\n"
	append msg "WITH EXISTING BATCHFILES\n"
	append msg "___________________________________________________________\n"
	append msg "\n"
	append msg "The Output File From 'Extract Transformation Pairs'\n"
	append msg "Can Be Combined With (Multi-)Processes\n"
	append msg "In Existing Batchfiles.\n"
	append msg "\n"
	append msg "IN Multiple Files Mode....\n"
	append msg "\n"
	append msg "1) Select The Transformation-Pairs File.\n"
	append msg "\n"
	append msg "2) Select N Existing Batchfiles, Where N Is \n"
	append msg "     The Number Of ~Groups Of~ Transformation Pairs.\n"
	append msg "     i.e. no. of Different transformations to be done:\n"
	append msg "     NOT the no. of file->file processes to be done.\n"
	append msg "\n"
	append msg "Run The Procedure.\n"
	append msg "\n"
	append msg "N.B. Certain Processes Won't Work With This Procedure,\n"
	append msg "     Especially Those With No Input Or No Output File,\n"
	append msg "     Those With Multiple Input Or Multiple Output Files,\n"
	append msg "     Those With A Variable no. of Input Or Output Files,\n"
	append msg "     And Standalone Programs.\n"
	Inf $msg
}

#---- If name contains string A, substitute seg 2 for seg 1

proc ConditionalSegmentSubstitution {ilist listing are_files} {
	global wl ch pr_condsub condseg condseg_old condseg_new new_segmented_names condseg_str condseg_noteq condseg_suball evv
	global wstk only_if_fexists3 rememd

	set nunames {}
	set f .condsegfiles
	if [Dlg_Create $f "SUBSTITUTE SEGMENT IN ITEMS CONTAINING SPECIFIC STRING" "set pr_condsub 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		frame $f.5 -borderwidth $evv(BBDR)
		button $f.0.add -text "DO IT" -command {set pr_condsub 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_condsub 0} -highlightbackground [option get . background {}]
		pack $f.0.add -side left
		pack $f.0.q -side right
		label $f.1.ll -text "SEARCH FOR STRING"
		entry $f.1.e -textvariable condseg_str -width 16
		pack $f.1.ll $f.1.e -side left -padx 2
		label $f.2.ll -text "SEGMENT TO CHANGE"
		entry $f.2.e -textvariable condseg_old -width 8
		label $f.2.ll2 -text "NEW SEGMENT"
		entry $f.2.e2 -textvariable condseg_new -width 8
		pack $f.2.ll $f.2.e $f.2.ll2 $f.2.e2 -side left -padx 2
		radiobutton $f.3.1 -text "original segment EQUAL TO given value" -variable condseg_noteq -value 0
		radiobutton $f.3.2 -text "original segment CONTAINS given value" -variable condseg_noteq -value 1
		pack $f.3.1 $f.3.2 -side left
		radiobutton $f.4.1 -text "Substitute ALL of original segment" -variable condseg_suball -value 1
		radiobutton $f.4.2 -text "Substitute PART of original segment" -variable condseg_suball -value 0
		pack $f.4.1 $f.4.2 -side left
		checkbutton $f.5.1 -variable only_if_fexists3 -text "Only if renamed items are existing files"
		pack $f.5.1  -padx 2 -side left
		pack $f.0 $f.1 $f.2 $f.3 $f.4 $f.5 -side top -fill x -expand true
		set only_if_fexists3 0
		set condseg_str ""
		set condseg_old ""
		set condseg_new ""
		set condseg_noteq 0
		set condseg_suball 1
		bind $f <Return> {set pr_condsub 1}
		bind $f <Escape> {set pr_condsub 0}
	}
	if {$are_files} {
		set only_if_fexists3 0
		$f.5.1 config -text "" -state disabled
	} else {		
		$f.5.1 config -text "Only if renamed items are existing files" -state normal
	}
	set len_ilist [llength $ilist]
	set finished 0 
	raise $f
	set pr_condsub 0
	My_Grab 0 $f pr_condsub $f.1.e
	while {!$finished} {
		tkwait variable pr_condsub
		if {$pr_condsub} {
			set condseg_str [string tolower $condseg_str]
			if {([string length $condseg_str] <= 0) || ![regexp {^[a-z0-9_\-]+$} $condseg_str]} {
				Inf "Invalid Search String Entered"
				continue
			}
			set condseg_old [string tolower $condseg_old]
			if {([string length $condseg_old] <= 0) || ![regexp {^[a-z0-9\-]+$} $condseg_old]} {
				Inf "Invalid Value Entered For Original Segment"
				continue
			}
			set condseg_new [string tolower $condseg_new]
			if {([string length $condseg_new] <= 0) || ![regexp {^[a-z0-9\-]+$} $condseg_new]} {
				Inf "Invalid Value Entered For New Segment"
				continue
			}
			set nunames {}
			set innames {}
			set is_changed 0
			set OK 1
			foreach i $ilist {
				set inname [$listing get $i]
				lappend innames $inname
				set basename [file rootname [file tail $inname]]
				if {[llength [CheckSegmentation $basename 1]] <= 0} {	;#	NO SEGMENTATION == NO SUBSTITUTION
					lappend nunames $inname
					continue
				}
				if {[string first $condseg_str $basename] < 0} {		;#	SEARCH STRING NOT FOUND == NO SUBSTITUTION
					lappend nunames $inname
					continue
				}
				set ext [file extension $inname]
				set dir [file dirname $inname]
				if {[string length $dir] <= 1} {
					set dir ""
				}				
				set inlen [string length $basename]
				set endindex [expr $inlen - 1]
				set flist [FindSegs $basename $condseg_old $condseg_noteq $inlen]
				if {[llength $flist] <= 0} {							;#	SEG TO BE REPLACED NOT FOUND == NO SUBSTITUTION
					lappend nunames $inname
					continue
				}
				if {[llength $flist] > 1} {								;# AMBIGUITY
					Inf "Item '$basename' Contains Two Segments Corresponding To The Original Segment Value Entered"
					set OK 0
					break
				}
				set flist [lindex $flist 0]
				set j [lindex $flist 0]
				set k [lindex $flist 1]
				if {!$condseg_suball} {
					set offset $j
					set subinlen [string length $condseg_old]
					set flist [FindFirstSeg [string range $basename $j $k] $condseg_old 0 $subinlen]
					set j [lindex $flist 0]
					set k [lindex $flist 1]
					incr j $offset
					incr k $offset
				}
				if {$j == 0} {
					set nuname $condseg_new
					incr k 1
					append nuname [string range $basename $k end]
				} elseif {$k == $endindex} {
					incr j -1
					set nuname [string range $basename 0 $j]
					append nuname $condseg_new
				} else {
					incr j -1
					set nuname [string range $basename 0 $j]
					append nuname $condseg_new
					incr k 1
					append nuname [string range $basename $k end]
				}
				set nuname [file join $dir $nuname]
				append nuname $ext
				lappend nunames $nuname
				set is_changed 1
			}
			if {!$OK} {
				continue
			}
			if {!$is_changed} {
				Inf "No Item Was Modified"
				continue
			}
			set OK 1
			if {$are_files} {
				catch {unset bad_files}
				set fcnt 0
				set ren_blist 0
				set is_snd 0
				set rename_cnt 0
				foreach inname $innames nuname $nunames {
					if {![string match $inname $nuname]} {				;#	IF RENAMED
						if [catch {file rename $inname $nuname} zit] {
							lappend bad_files $inname
							set nunames [lreplace $nunames $fcnt $fcnt $inname]
						} else {
							DataManage rename $inname $nuname
							lappend couettelist $inname $nuname
							set i [LstIndx $inname $wl]
							if {$i >= 0} {
								set outlist [RenameWkspaceFileFromTabed $i $inname $nuname]
								if {[lindex $outlist 0] == 1} {
									set is_snd 1
								}
								if {[lindex $outlist 1] == 1} {
									set ren_blist 1
								}
								incr rename_cnt
							}
						}
					}
					incr fcnt
				}
				if {[info exists couettelist]} {
					CouetteManage rename $couettelist
				}
				if {$rename_cnt > 0} {
					if {$ren_blist} {
						SaveBL $background_listing
					}		
					if {$is_snd} {
						set scores_refresh 1
					}
					catch {unset rememd}
				}
				if {[info exists bad_files]} {
					if {[llength $bad_files] == [llength $nunames]} {
						Inf "No Files Could Be Renamed"
						set OK 0
						continue
					}
					set msg "The Following Files Could Not Be Renamed\n\n"
					set fcnt 0
					foreach fnam $bad_files {
						if {$fcnt > 20} {
							append msg "\nAnd More"
							break
						}
						append msg "$fnam    "
						incr fcnt
					}
					Inf $msg
				}
			} elseif {$only_if_fexists3} {
				foreach nuname $nunames {
					if [string match [file tail $nuname] $nuname] {
						set testfnam [file join [pwd] $nuname]
					} else {
						set testfnam $nuname
					}
					if {![file exists $testfnam]} {
						Inf "File '$testfnam' Does Not Exist"
						set OK 0
						break			
					}
				}
			}
			if {!$OK} {
				continue
			}
			set new_segmented_names $nunames
			set finished 1
		} else {
			set new_segmented_names {}
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $new_segmented_names
}

#------ Find all occurences of segment in name

proc FindSegs {basename specseg can_be_unequal inlen} {

	set offset 0
	set k 0
	while {$k >= 0} {
		set searchstr [string range $basename $offset end]
		set k [string first $specseg $searchstr]
		while {$k >= 0} {
			set endk $k
			incr endk [string length $specseg]
			set is_equal 1
			set at_start 0
			set at_end 0

			if {$k == 0} {
				set j 0
				set at_start 1
			} else {
				set j $k
				incr k -1
				while {![string match "_" [string index $searchstr $k]]} {
					set is_equal 0
					set j $k
					incr k -1
					if {$k < 0} {
						break
					}
				}
			}
			set k $endk
			if {$k < $inlen} {
				while {![string match "_" [string index $searchstr $k]]} {
					set is_equal 0
					incr k
					if {$k >= $inlen} {
						set at_end 1
						break
					}
				}
			} else {
				set at_end 1
			}
			incr k -1

			if {!$can_be_unequal && !$is_equal} {	;#	SEARCH ONLY REMAINDER OF NAME
				if {$at_end} {
					set k -1
					break
				} else {
					set lastk [expr $k + 2]
					if {$lastk >= [string length $searchstr]} {
						set k -1
						break
					}
				}
				set k [string first $specseg [string range $searchstr $lastk end]]
				if {$k >= 0} {
					incr k $lastk
				}
			} else {
				break
			}
		}
		if {$k < 0} {					;#	THIS PART OF ITEM DOES NOT CONTAIN SEG
			break
		}
		set jj $j 
		set kk $k 
		incr jj $offset
		incr kk $offset
		if {$offset != 0} {				;#	ITEM AT START OF (PART)STRING SEARCHED IS ONLY AT START OF WHOLE ITEM, 
			set at_start 0				;#	IF WE'RE SEARCHING WITH NO OFFSET
		} 
		lappend outlist [list $jj $kk $at_start $at_end]
		incr k 2
		set offset $k
	}
	if {$offset == 0} {				;#	ITEM DOES NOT CONTAIN SEG
		return {}
	}
	return $outlist
}

#----- Deal with loudness balance

proc LastLineIsBalance {last_line} {
	global wstk
	set ggrp [string tolower [lindex $last_line 0]]
	set pprg [string tolower [lindex $last_line 1]]
	set mmod [string tolower [lindex $last_line 2]]
	if {[string match $ggrp "modify"] && [string match $pprg "loudness"] && [string match $mmod "5"]} {
		set msg "Last Line Of This Batch Is A Loudness Balancing Process.\n"
		append msg "Assuming You Want To Balance Level With The Original Input To This Whole Batch Process.\n\n"
		append msg "Is This OK ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return 0
		}
		return 1
	}
	return 0
}	

#---- Select every Nth file and insert or substitute a different file (or remove file from list)

proc HiliteSegs {ilist listing} {
	global wl ch pr_hiliteseg hiliseg new_segmented_names evv wstk hiliothers hilipos hilisegeq

	set nunames {}
	set f .hilisegfiles
	if [Dlg_Create $f "HILITE FILES CONTAINING SPECIFIC TYPES OF SEGMENT" "set pr_hiliteseg 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		frame $f.5 -borderwidth $evv(BBDR)
		frame $f.6 -borderwidth $evv(BBDR)
		frame $f.7 -borderwidth $evv(BBDR)
		button $f.0.add -text "DO IT" -command {set pr_hiliteseg 1} -highlightbackground [option get . background {}]
		button $f.0.q -text "CLOSE" -command {set pr_hiliteseg 0} -highlightbackground [option get . background {}]
		pack $f.0.add -side left
		pack $f.0.q -side right
		label $f.1.1 -text "HILIGHT FILES WHICH...."
		pack $f.1.1 -side top
		radiobutton $f.2.1 -text "CONTAIN THE SEGMENT" -variable hiliothers -value 0
		radiobutton $f.2.2 -text "DO NOT CONTAIN THE SEGMENT" -variable hiliothers -value 1
		pack $f.2.1 $f.2.2 -side left
		label $f.3.1 -text "WITH THE SEGMENT IN POSITION..."
		pack $f.3.1 -side top
		radiobutton $f.4.1 -text "START OF FILENAME" -variable hilipos -value 0
		radiobutton $f.4.2 -text "END OF FILENAME" -variable hilipos -value 1
		radiobutton $f.4.3 -text "ANYWHERE IN FILENAME" -variable hilipos -value 2
		pack $f.4.1 $f.4.2 $f.4.3 -side left
		label $f.5.1 -text "WHERE A MATCH MEANS..."
		pack $f.5.1 -side top
		radiobutton $f.6.1 -text "EQUAL TO THE GIVEN SEGMENT VALUE" -variable hilisegeq -value 1
		radiobutton $f.6.2 -text "CONTAINING THE GIVEN SEGMENT VALUE" -variable hilisegeq -value 0
		pack $f.6.1 $f.6.2 -side left
		label $f.7.ll -text "SEGMENT VALUE to look for"
		entry $f.7.1 -textvariable hiliseg -width 48 -bg $evv(EMPH)
		pack $f.7.1 $f.7.ll -padx 2 -side left
		pack $f.0 $f.1 $f.2 $f.3 $f.4 $f.5 $f.6 $f.7 -side top -fill x -expand true
		set only_if_fexists2 0
		set hiliseg ""
		set hiliothers 0
		set hilipos 0
		set hilisegeq 1
		bind $f <Return> {set pr_hiliteseg 1}
		bind $f <Escape> {set pr_hiliteseg 0}
	}
	set finished 0 
	raise $f
	set pr_hiliteseg 0
	My_Grab 0 $f pr_hiliteseg $f.7.1
	while {!$finished} {
		tkwait variable pr_hiliteseg
		if {$pr_hiliteseg} {
			if {[string length $hiliseg] <= 0} {
				Inf "No Segment Value Entered"
				continue
			}
			set hiliseg [string tolower $hiliseg]
			if {![regexp {^[a-z0-9\-]+$} $hiliseg]} {
				Inf "Invalid Segment Value Entered"
				continue
			}
			set nu_ilist {}
			foreach i $ilist {
				set inname [$listing get $i]
				set basename [file rootname [file tail $inname]]
				set separatorlist [CheckSegmentation $basename 0]
				if {[llength $separatorlist] <= 0} {
					continue
				}
				if {$hilipos == 2} {			;#	SEGMENT ANYWHERE
					if [FoundSegmentSomewhere $basename $hiliseg $hilisegeq $separatorlist] {
						lappend nu_ilist $i
					}
				} else {
					switch -- $hilipos {
						0 {			;#	SEGMENT AT START
							set k [lindex $separatorlist 0]
							incr k -1
							set thisseg [string range $basename 0 $k]

						}
						1 {			;#	SEGMENT AT END
							set k [lindex $separatorlist end]
							incr k
							set thisseg [string range $basename $k end]
						}
					}				
					if {$hilisegeq} {
						if {[string match $thisseg $hiliseg]} {
							lappend nu_ilist $i
						}
					} else {
						if {[regexp $hiliseg $thisseg]} {
							lappend nu_ilist $i
						}
					}
				}
			}
			if {$hiliothers} {
				$wl selection set 0 end
				foreach i $nu_ilist {
					$wl selection clear $i
				}
			} else {
				$wl selection clear 0 end
				foreach i $nu_ilist {
					$wl selection set $i
				}
			}
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Check all segments

proc FoundSegmentSomewhere {basename specseg must_be_equal separatorlist} {

	set j 0
	foreach k $separatorlist {
		set jj $k 
		incr k -1
		set thisseg [string range $basename $j $k]
		if {$must_be_equal} {
			if {[string match $thisseg $specseg]} {
				return 1
			}
		} else {
			if {[regexp $specseg $thisseg]} {
				return 1
			}
		}
		incr jj
		set j $jj
	}
	set thisseg [string range $basename $j end]
	if {$must_be_equal} {
		if {[string match $thisseg $specseg]} {
			return 1
		}
	} else {
		if {[regexp $specseg $thisseg]} {
			return 1
		}
	}
	return 0
}

#------- Rename a file on the workspace

proc RenameWkspaceFileFromTabed {i inname nuname} {
	global pa evv ch wl chlist chcnt scores_refresh rememd

	set outlist [list 0 0]
	if {$pa($inname,$evv(FTYP)) == $evv(SNDFILE)} {
		set outlist [lreplace $outlist 0 0 1]
	}
	$wl delete $i								
	$wl insert $i $nuname
	catch {unset rememd}
	set oldname_pos_on_chosen [LstIndx $inname $ch]
	if {$oldname_pos_on_chosen >= 0} {
		RemoveFromChosenlist $inname
		set chlist [linsert $chlist $oldname_pos_on_chosen $nuname]
		incr chcnt
		$ch insert $oldname_pos_on_chosen $nuname
	}
	UpdateChosenFileMemory $inname $nuname
	RenameOnDirlist $inname $nuname
	if {[HasPmark $inname]} {
		MovePmark $inname $nuname
	}
	if {[HasMmark $inname]} {
		MoveMmark $inname $nuname
	}
	if [IsInBlists $inname] {
		if [RenameInBlists $inname $nuname] {
			set outlist [lreplace $outlist 1 1 1]
		}
	}
	if [IsOnScore $inname] {
		RenameOnScore $inname $nuname
	}
	RenameProps	$inname $nuname 1
	DummyHistory $inname "RENAMED_$nuname"
	AddNameToNameslist [file tail $nuname] 0
	return $outlist
}

#--- Highlight worksapce files whose names end in a specified string

proc SelEndNames {ilist listing} {
	global pf_fnamend name_ending endnamsout evv
	set endnamsout {}
	set f .fnamend
	if [Dlg_Create $f "HIGHLIGHT NAMES ENDING IN ..." "set pf_fnamend 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b]
		set k [frame $f.k]		
		button $b.keep -text "Find Files" -command "set pf_fnamend 1"
		button $b.quit -text "Abandon"	  -command "set pf_fnamend 0"
		pack $b.keep -side left
		pack $b.quit -side right
		pack $b -side top -fill x -expand true
		label $k.ll -text "String at name end "
		entry $k.e -textvariable name_ending -width 12
		pack $k.ll $k.e -side left
		pack $k -side top -pady 2
		bind $f <Return> "set pf_fnamend 1"
		bind $f <Escape> "set pf_fnamend 0"
	}
	set pf_fnamend 0			
	set finished 0
	raise $f
	My_Grab 0 $f pf_fnamend $f.k.e
	while {!$finished} {
		tkwait variable pf_fnamend
		if {$pf_fnamend} {
			if {[string length $name_ending] <= 0} {
				Inf "No Filename Ending Entered"
				continue
			}
			if {![ValidCdpFilename $name_ending 1]} {
				continue
			}
			set namend [string tolower $name_ending]
			set slen [string length $namend]
			catch {unset foundnams}
			foreach fnam [$listing get 0 end] i $ilist {
				set fnam [file rootname [file tail $fnam]]
				set k [string first $namend $fnam]
				if {$k >= 0} {
					set len [string length $fnam]
					if {$len - $k == $slen} {
						lappend foundnams $i
					}
				}
			}
			if {![info exists foundnams]} {
				Inf "No Files On The Workspace Have Names Ending In \"$namend\""
				continue
			}
			set endnamsout $foundnams
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $endnamsout
}

#--- Highlight worksapce files whose names starT with a specified string

proc SelSttNames {ilist listing} {
	global pf_fnamstt name_stting sttnamsout evv
	set sttnamsout {}
	set f .fnamstt
	if [Dlg_Create $f "HIGHLIGHT NAMES STARTING WITH ..." "set pf_fnamstt 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b]
		set k [frame $f.k]		
		button $b.keep -text "Find Files" -command "set pf_fnamstt 1"
		button $b.quit -text "Abandon"	  -command "set pf_fnamstt 0"
		pack $b.keep -side left
		pack $b.quit -side right
		pack $b -side top -fill x -expand true
		label $k.ll -text "String at name start "
		entry $k.e -textvariable name_stting -width 12
		pack $k.ll $k.e -side left
		pack $k -side top -pady 2
		bind $f <Return> "set pf_fnamstt 1"
		bind $f <Escape> "set pf_fnamstt 0"
	}
	set pf_fnamstt 0			
	set finished 0
	raise $f
	My_Grab 0 $f pf_fnamstt $f.k.e
	while {!$finished} {
		tkwait variable pf_fnamstt
		if {$pf_fnamstt} {
			if {[string length $name_stting] <= 0} {
				Inf "No filename ending entered"
				continue
			}
			if {![ValidCdpFilename $name_stting 1]} {
				continue
			}
			set namstt [string tolower $name_stting]
			catch {unset foundnams}
			foreach fnam [$listing get 0 end] i $ilist {
				set fnam [file rootname [file tail $fnam]]
				set k [string first $namstt $fnam]
				if {$k == 0} {
					lappend foundnams $i
				}
			}
			if {![info exists foundnams]} {
				Inf "No files on the workspace have names starting with \"$namstt\""
				continue
			}
			set sttnamsout $foundnams
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $sttnamsout
}
