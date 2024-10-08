# RWD version for universal Intel archs only, tcl 8.5
# The path to the tcl.h header file

TCL_INCPATH = /Library/Frameworks/Tcl.framework/Headers

# The path to the tk.h header file

TK_INCPATH  = /Library/Frameworks/Tk.framework/Headers

# The path to the X11 include files

XINCLUDES   = -I/Library/Frameworks/Tk.framework/Versions/8.5/Headers

# Install SNACK package here

SNACK_INSTALL_PATH = ${exec_prefix}/lib
SNACK_HINSTALL_PATH = ${prefix}/include

#

GENERIC_DIR = ./../generic
UNIX_DIR    = ./../unix
MAC_DIR     = ./../mac

VERSION = 2.2

DESTDIR	=

TCL_VERSION = 8.5

CC        = gcc -pipe

INCLUDES  = ${XINCLUDES} -I/Library/Frameworks/Tcl.framework/Versions/8.5/Headers -I${TCL_INCPATH} -I${TK_INCPATH}  
# RWD: used -O  AND -Os - optimize for size, but not at the expense of performance

CFLAGS    = -O2 -arch x86_64 -arch i386 -fno-common -DUSE_TCL_STUBS -DUSE_TK_STUBS -DOS_X_CORE_AUDIO -DMAC_OSX_TCL -DMAC_OSX_TK ${INCLUDES} -DTCL_81_API -I${GENERIC_DIR} -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 

LIBSO     = -lc -framework CoreFoundation -framework CoreAudio -L/Library/Frameworks/Tcl.framework/Versions/8.5 -ltclstub8.5${TCL_DBGX}

LIBSN     = -lc   -lpthread -framework CoreFoundation  -framework CoreFoundation -framework CoreAudio -L/Library/Frameworks/Tcl.framework/Versions/8.5 -ltclstub8.5${TCL_DBGX} -L/Library/Frameworks/Tk.framework/Versions/8.5 -ltkstub8.5${TK_DBGX}

SHLIB_LD     = cc -O2 -dynamiclib -arch x86_64 -arch i386 ${LDFLAGS}
SHLIB_SUFFIX = .dylib

all: libsound${SHLIB_SUFFIX} libsnack${SHLIB_SUFFIX} stublib   editversion

OBJSO = sound.o jkSound.o jkSoundEngine.o jkSoundEdit.o jkSoundFile.o \
	g711.o jkAudIO_osx.o jkFormatMP3.o jkSoundProc.o ffa.o jkPitchCmd.o \
	snackStubInit.o jkAudio.o jkMixer.o shape.o jkFilter.o jkSynthesis.o \
	jkFilterIIR.o jkGetF0.o sigproc.o jkFormant.o sigproc2.o

OBJSN = snack.o jkSound.o jkSoundEngine.o jkSoundEdit.o jkSoundFile.o \
	jkCanvSpeg.o jkCanvWave.o jkCanvSect.o ffa.o g711.o jkAudIO_osx.o \
	jkFormatMP3.o jkSoundProc.o jkPitchCmd.o snackStubInit.o \
	jkAudio.o jkMixer.o shape.o jkFilter.o jkSynthesis.o jkFilterIIR.o \
	jkGetF0.o sigproc.o jkFormant.o sigproc2.o

OBJSNST = snackStubLib.o

sound.o: $(GENERIC_DIR)/sound.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/sound.c

jkSound.o: $(GENERIC_DIR)/jkSound.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkSound.c

jkSoundEngine.o: $(GENERIC_DIR)/jkSoundEngine.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkSoundEngine.c

jkSoundEdit.o: $(GENERIC_DIR)/jkSoundEdit.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkSoundEdit.c

jkSoundFile.o: $(GENERIC_DIR)/jkSoundFile.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkSoundFile.c

g711.o: $(GENERIC_DIR)/g711.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/g711.c

jkFormatMP3.o: $(GENERIC_DIR)/jkFormatMP3.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkFormatMP3.c

jkSoundProc.o: $(GENERIC_DIR)/jkSoundProc.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkSoundProc.c

ffa.o: $(GENERIC_DIR)/ffa.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/ffa.c

jkPitchCmd.o: $(GENERIC_DIR)/jkPitchCmd.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkPitchCmd.c

snack.o: $(GENERIC_DIR)/snack.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/snack.c

jkCanvSpeg.o: $(GENERIC_DIR)/jkCanvSpeg.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkCanvSpeg.c

jkCanvWave.o: $(GENERIC_DIR)/jkCanvWave.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkCanvWave.c

jkCanvSect.o: $(GENERIC_DIR)/jkCanvSect.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkCanvSect.c

jkAudio.o: $(GENERIC_DIR)/jkAudio.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkAudio.c

jkMixer.o: $(GENERIC_DIR)/jkMixer.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkMixer.c

shape.o: $(GENERIC_DIR)/shape.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/shape.c

jkFilter.o: $(GENERIC_DIR)/jkFilter.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkFilter.c

jkFilterIIR.o: $(GENERIC_DIR)/jkFilterIIR.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkFilterIIR.c

jkSynthesis.o: $(GENERIC_DIR)/jkSynthesis.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkSynthesis.c

snackStubInit.o: $(GENERIC_DIR)/snackStubInit.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/snackStubInit.c

jkAudIO_hp.o: $(UNIX_DIR)/jkAudIO_hp.c
	$(CC) -c $(CFLAGS) $(UNIX_DIR)/jkAudIO_hp.c

jkAudIO_sun.o: $(UNIX_DIR)/jkAudIO_sun.c
	$(CC) -c $(CFLAGS) $(UNIX_DIR)/jkAudIO_sun.c

jkAudIO_sgi.o: $(UNIX_DIR)/jkAudIO_sgi.c
	$(CC) -c $(CFLAGS) $(UNIX_DIR)/jkAudIO_sgi.c

jkAudIO_oss.o: $(UNIX_DIR)/jkAudIO_oss.c
	$(CC) -c $(CFLAGS) $(UNIX_DIR)/jkAudIO_oss.c

jkAudIO_alsa.o: $(UNIX_DIR)/jkAudIO_alsa.c
	$(CC) -c $(CFLAGS) $(UNIX_DIR)/jkAudIO_alsa.c

jkAudIO_osx.o: $(UNIX_DIR)/jkAudIO_osx.c
	$(CC) -c $(CFLAGS) $(UNIX_DIR)/jkAudIO_osx.c

jkAudIO_mac.o: $(MAC_DIR)/jkAudIO_mac.c
	$(CC) -c $(CFLAGS) $(MAC_DIR)/jkAudIO_mac.c

jkAudIO_skel.o: $(UNIX_DIR)/jkAudIO_skel.c
	$(CC) -c $(CFLAGS) $(UNIX_DIR)/jkAudIO_skel.c

jkGetF0.o: $(GENERIC_DIR)/jkGetF0.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkGetF0.c

sigproc.o: $(GENERIC_DIR)/sigproc.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/sigproc.c

jkFormant.o: $(GENERIC_DIR)/jkFormant.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/jkFormant.c

sigproc2.o: $(GENERIC_DIR)/sigproc2.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/sigproc2.c

snackStubLib.o: $(GENERIC_DIR)/snackStubLib.c
	$(CC) -c $(CFLAGS) $(GENERIC_DIR)/snackStubLib.c

libsound${SHLIB_SUFFIX}: ${OBJSO}
	${SHLIB_LD} ${OBJSO} ${LIBSO} -o libsound${SHLIB_SUFFIX} 
	sed s/.dll/${SHLIB_SUFFIX}/ < $(UNIX_DIR)/pkgIndex.tcl.dll > pkgIndex.tcl

libsnack${SHLIB_SUFFIX}: ${OBJSN}
	${SHLIB_LD} ${OBJSN} ${LIBSN} -o libsnack${SHLIB_SUFFIX} 
	sed s/.dll/${SHLIB_SUFFIX}/ < $(UNIX_DIR)/pkgIndex.tcl.dll > pkgIndex.tcl

stublib: ${OBJSNST}
	ar cr libsnackstub${VERSION}.a ${OBJSNST}

editversion: ${OBJSN}
	if test "$(TCL_VERSION)" != "8.5"; then\
	    cd $(UNIX_DIR)/../demos/tcl/ ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ MinSect.tcl > tmp ;\
	    mv -f tmp MinSect.tcl ;\
	    chmod 755 MinSect.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ MinSpeg.tcl > tmp ;\
	    mv -f tmp MinSpeg.tcl ;\
	    chmod 755 MinSpeg.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ MinWave.tcl > tmp ;\
	    mv -f tmp MinWave.tcl ;\
	    chmod 755 MinWave.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ Section.tcl > tmp ;\
	    mv -f tmp Section.tcl ;\
	    chmod 755 Section.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ Spectrogram.tcl > tmp ;\
	    mv -f tmp Spectrogram.tcl ;\
	    chmod 755 Spectrogram.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ SphereTest.tcl > tmp ;\
	    mv -f tmp SphereTest.tcl ;\
	    chmod 755 SphereTest.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ Waveform.tcl > tmp ;\
	    mv -f tmp Waveform.tcl ;\
	    chmod 755 Waveform.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ aserver.tcl > tmp ;\
	    mv -f tmp aserver.tcl ;\
	    chmod 755 aserver.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ compose.tcl > tmp ;\
	    mv -f tmp compose.tcl ;\
	    chmod 755 compose.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ cool.tcl > tmp ;\
	    mv -f tmp cool.tcl ;\
	    chmod 755 cool.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ echo.tcl > tmp ;\
	    mv -f tmp echo.tcl ;\
	    chmod 755 echo.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ formant.tcl > tmp ;\
	    mv -f tmp formant.tcl ;\
	    chmod 755 formant.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ fourChan.tcl > tmp ;\
	    mv -f tmp fourChan.tcl ;\
	    chmod 755 fourChan.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ levelmeter.tcl > tmp ;\
	    mv -f tmp levelmeter.tcl ;\
	    chmod 755 levelmeter.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ mapChan.tcl > tmp ;\
	    mv -f tmp mapChan.tcl ;\
	    chmod 755 mapChan.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ mixer.tcl > tmp ;\
	    mv -f tmp mixer.tcl ;\
	    chmod 755 mixer.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ play.tcl > tmp ;\
	    mv -f tmp play.tcl ;\
	    chmod 755 play.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ record.tcl > tmp ;\
	    mv -f tmp record.tcl ;\
	    chmod 755 record.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ recrplay.tcl > tmp ;\
	    mv -f tmp recrplay.tcl ;\
	    chmod 755 recrplay.tcl ;\
	    sed s/tclsh8.5/tclsh${TCL_VERSION}/ rplay.tcl > tmp ;\
	    mv -f tmp rplay.tcl ;\
	    chmod 755 rplay.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ snamp.tcl > tmp ;\
	    mv -f tmp snamp.tcl ;\
	    chmod 755 snamp.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ spectrum.tcl > tmp ;\
	    mv -f tmp spectrum.tcl ;\
	    chmod 755 spectrum.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ tomAmp.tcl > tmp ;\
	    mv -f tmp tomAmp.tcl ;\
	    chmod 755 tomAmp.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ dbrec.tcl > tmp ;\
	    mv -f tmp dbrec.tcl ;\
	    chmod 755 dbrec.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ widget.tcl > tmp ;\
	    mv -f tmp widget.tcl ;\
	    chmod 755 widget.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ wrap.tcl > tmp ;\
	    mv -f tmp wrap.tcl ;\
	    chmod 755 wrap.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ generator.tcl > tmp ;\
	    mv -f tmp generator.tcl ;\
	    chmod 755 generator.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ notescale.tcl > tmp ;\
	    mv -f tmp notescale.tcl ;\
	    chmod 755 notescale.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ oggstream.tcl > tmp ;\
	    mv -f tmp oggstream.tcl ;\
	    chmod 755 oggstream.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ polarspec.tcl > tmp ;\
	    mv -f tmp polarspec.tcl ;\
	    chmod 755 polarspec.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ pitch.tcl > tmp ;\
	    mv -f tmp pitch.tcl ;\
	    chmod 755 pitch.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ phonetogram.tcl > tmp ;\
	    mv -f tmp phonetogram.tcl ;\
	    chmod 755 phonetogram.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ vowelspace.tcl > tmp ;\
	    mv -f tmp vowelspace.tcl ;\
	    chmod 755 vowelspace.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ CSLwithAB.tcl > tmp ;\
	    mv -f tmp CSLwithAB.tcl ;\
	    chmod 755 CSLwithAB.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ xs.tcl > tmp ;\
	    mv -f tmp xs.tcl ;\
	    chmod 755 xs.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ playlist.tcl > tmp ;\
	    mv -f tmp playlist.tcl ;\
	    chmod 755 playlist.tcl ;\
	    sed s/wish8.5/wish${TCL_VERSION}/ mixplay.tcl > tmp ;\
	    mv -f tmp mixplay.tcl ;\
	    chmod 755 mixplay.tcl ;\
	    cd ../../unix ;\
	fi
LIBNIST = /libsp.a /libutil.a -lc -L/Library/Frameworks/Tcl.framework/Versions/8.5 -ltclstub8.5${TCL_DBGX} -L. -lsnackstub2.2
OBJNIST = SphereFile.o

SphereFile.o: $(GENERIC_DIR)/SphereFile.c
	$(CC) -c $(CFLAGS) -DUSE_SNACK_STUBS $(GENERIC_DIR)/SphereFile.c

libsnacksphere${SHLIB_SUFFIX}: ${OBJNIST}
	${SHLIB_LD} ${OBJNIST} ${LIBNIST} -o libsnacksphere${SHLIB_SUFFIX}

LIBOGG = -L -lvorbisenc -lvorbis -logg -lc -L/Library/Frameworks/Tcl.framework/Versions/8.5 -ltclstub8.5${TCL_DBGX} -L. -lsnackstub2.2
OBJOGG = SnackOgg.o

SnackOgg.o: $(GENERIC_DIR)/SnackOgg.c
	$(CC) -I -c $(CFLAGS) -DUSE_SNACK_STUBS $(GENERIC_DIR)/SnackOgg.c

libsnackogg${SHLIB_SUFFIX}: ${OBJOGG}
	${SHLIB_LD} ${OBJOGG} ${LIBOGG} -o libsnackogg${SHLIB_SUFFIX}

install:
	@if [ ! -d ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION} ] ; then \
	    echo "Making directory ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}"; \
	    mkdir -p ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}; \
	    chmod 755 ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}; \
        else true; \
        fi;
	cp -f libsound${SHLIB_SUFFIX} ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}/
	cp -f libsnack${SHLIB_SUFFIX} ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}/
	if test -f libsnackstub${VERSION}.a; then cp -f libsnackstub${VERSION}.a ${DESTDIR}${SNACK_INSTALL_PATH}/; fi
	if test -f libsnacksphere${SHLIB_SUFFIX}; then cp -f libsnacksphere${SHLIB_SUFFIX} ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}/; fi
	if test -f libsnackogg${SHLIB_SUFFIX}; then cp -f libsnackogg${SHLIB_SUFFIX} ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}/; fi
	cp -f $(UNIX_DIR)/snack.tcl ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}/
	cp -f pkgIndex.tcl ${DESTDIR}${SNACK_INSTALL_PATH}/snack${VERSION}/

clean:
	rm -f *.o libsound${SHLIB_SUFFIX} libsnack${SHLIB_SUFFIX} libsnacksphere${SHLIB_SUFFIX}

distclean: clean
	rm -f Makefile config.status config.cache config.log

# Tests are run using wish because of play/record commands

test:
	LD_LIBRARY_PATH=`pwd`:${LD_LIBRARY_PATH}; export LD_LIBRARY_PATH; \
	DYLD_LIBRARY_PATH=`pwd`:${DYLD_LIBRARY_PATH}; export DYLD_LIBRARY_PATH; \
	LIBPATH=`pwd`:${LIBPATH}; export LIBPATH; \
	SHLIB_PATH=`pwd`:${SHLIB_PATH}; export SHLIB_PATH; \
	TCL_LIBRARY="${TCL_BUILDTIME_LIBRARY}"; export TCL_LIBRARY; \
	cp -f $(UNIX_DIR)/../demos/tcl/ex1.wav ex1.wav; \
	wish${TCL_VERSION} $(UNIX_DIR)/../tests/all.tcl
