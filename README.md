# Soundloom
Trevor Wishart's GUI Front End for the CDP System

This is a substatial application written in the scripting language Tcl-Tk. As well as driving all the programs in the current CDP system (repository CDPR8), it supports large-scale macro management of composition projects.

Soundloom was created under Windows, and later the code was adapted to run on the Mac. 
Accordingly there are two separate code sets. 
This repository provides the Mac code set, but the process has started on amalgamating them into one set.
It is not possible to run/test Soundloom without a full CDPR8 system installed (see www.composersdesktop.com for details).

While all Apple computers come with a basic version of tcltk 8.5 (parts of which will not run under Apple silicon), it is recommended that Tcltk 8.6 be installed, e.g. via homebrew.

This repository also includes sources of a custom version of the Snack Toolkit by Kare Solander. The customisation is primarily to support the full range of soundfiles supported by the CDP system (based on WAVEFORMATEXTENSIBLE). Earlier releases of tcltk (e.g. from ActiveState) included this library,
but it has not been updated by the author in a long time, and was removed from those distributions.

This toolkit mut be built and installed before Soundloom can be run.

To come:  the source files; general instructions.

Richard Dobson, 30-09-2024
