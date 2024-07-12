suppressMessages({
    library(tidyverse)

    library(here)
    here::i_am("animalese.R")

    library(optparse)
    arguments <- parse_args(OptionParser(
        usage = c(r"(%prog [-p high|med|low|lowest] [-i Intersting.] [-o socuciusErgallaInterjection.wav])",
                  r"(%prog [--pitch high|med|low|lowest] [-input Intersting.] [-output socuciusErgallaInterjection.wav])"),
        option_list = list(
        make_option(c("-i", "--input"),
                    type = "character",
                    default = r"[Ah, yes.
We've been expecting you.
You'll have to be recorded before you're officially released.
There are a few ways we can do this and the choice is yours.]"),
        make_option(c("-p", "--pitch"),
                    type = "character",
                    default = "low"),
        make_option(c("-o", "--output"),
                    type = "character",
                    default = here("output.wav"))),
        add_help_option = TRUE,
        description = r"(%prog is used to generate WAV files for use in the TES Ⅲ: Morrowind Construction Set,
or called directly with MWSE-Lua based mods.
The standard output of %prog contains the output path of the WAV file,
or an empty (null) string if there was an error.
sterr contains error messages and warnings generated through the run of the R code.)",
    ))

    library(tuneR)
    library(memoise)
    readWave <- memoize(tuneR::readWave)

    library(seewave)
    ## Modify the workspace copy of the function seewave::listen so that it does
    ## not call tuneR::play at the end of its function body, then alias the
    ## function so it makes semantic sense.
    body(listen)[9] <- NULL
    resampleWave <- listen
})

### Algorithm to get a usable character vector.
phonemes <- str_split_1(tolower(arguments$input), "")
for (i in seq_along(phonemes)) {
  if (is.na(phonemes[i])) {
    next
  } else if (phonemes[i] == "s" && phonemes[i + 1] == "h") {
    phonemes[i] <- "sh"
    phonemes[i + 1] <- NA
  } else if (phonemes[i] == "t" && phonemes[i + 1] == "h") {
    phonemes[i] <- "th"
    phonemes[i + 1] <- NA
  } else if (phonemes[i] == "h" && (phonemes[i - 1] == "s" || phonemes[i - 1] == "t")) {
    next
  } else if (phonemes[i] %in% c(",", ";", "!", "?")) {
    phonemes[i] <- "."
  }
}

## WAV binding (or concatenation or pasting; pick a gerund).
map(phonemes[!is.na(phonemes)],
    function(character) {
        index <- match(character, c(letters, "th", "sh", " ", "."))
        here("sounds",
            arguments$pitch,
            sprintf("sound%02d.wav", if (is.na(index)) 29 else index)) %>%
            readWave()
}) %>%
    ## If the sentence is a question, adjust the sampling rate of the last
    ## fifth of all sounds so that these sounds further increase in pitch the
    ## closer the sound is to the punctuated end of the sentence, thereby
    ## increasing the sampling rate by x̂ = 1.274895. All other sounds sampling
    ## rate is increased by x̂ = 1.274934.
    imap(function(sound, index) {
        randomizationFactor <- if (arguments$pitch == "med") 0.35 else 0.25
        octaves <- 1.10 + runif(1) * randomizationFactor # 𝑛 octaves
        adjustedSampleRate <-
            sound@samp.rate * 2^{
            octaves +
                if (arguments$input[length(arguments$input)] == "?" &&
                    index >= 0.8 * length(phonemes))
                { (0.8 * index - index) * 0.1 } else { 0.2 }
            }

        if (adjustedSampleRate < 2000) {
            "Adjusted sample rate (%a) for sound is greater than %a; using %a" %>%
            sprintf(adjustedSampleRate, 2000, 2000) %>%
            warning()
            adjustedSampleRate <- 2000
        } else if (adjustedSampleRate > 192000) {
            "Adjusted sample rate (%a) for sound is greater than %a; using %a" %>%
            sprintf(adjustedSampleRate, 192000, 192000) %>%
            warning()
            adjustedSampleRate <- 192000
        }

        downsample(resampleWave(normalize(sound), adjustedSampleRate), 44100)
    }) %>%
    reduce(bind) %>%
    writeWave(arguments$output)

print(arguments$output)