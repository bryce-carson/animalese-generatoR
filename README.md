# "Animalese" WAV generator
This repository hosts the WAV sounds and an R program that uses those sounds to generate Animal Crossing-like "animalese" WAV files for an input string.

## Animalese.R
This is an R translation of [equalo-official's animalese-generator](https://github.com/equalo-official/animalese-generator) I wrote for use in an TES Ⅲ: Morrowind, MWSE w/ Lua mod.

## Known bugs
At the moment there is some popping, as if someone were breathing heavily near or blowing directly into, the microphone. I'm unsure why this is, but I know it's related to the algorithm that includes and modifies silence (`sound29.wav`). I'll probably replace the inclusion of that WAV file with `tuneR::silence`, but that requires many more changes to the algorithm.

# Installation
## Windows
Install R with `win-get`, then install the several packages loaded with `library` interactively, carefully reading and resolving any error messages you encounter.

## macOS
Install R with `brew`, then install the several packages loaded with `library` interactively, carefully reading and resolving any error messages you encounter.

## Linux
You should know how to install R, gcc, etc. if you're using Linux. If not, I suggest you get into the habit of reading yoru system documentation *now* rather than later, so I'm leaving you on your own as an excercise to you, the reader.

# Packages loaded with `library`
- tidyverse
- here
- optparse
- tuneR
- seewave
- memoise

# COPYING
I received animalese-generator from equalo-official under the terms of the MIT license. The content of this repository is licensed to you under the terms of the same license, with the respective changes that the copyright owner of the R code is myself, while the copyright owner for the WAV files is equalo-official.

A copy of the license terms tendered by equalo-official is available in `sound/LICENSE`.

## Copyright
© 2024 Bryce Carson