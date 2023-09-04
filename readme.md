# Audio Analysis Toolbox

Collection of python and bash scripts to aid the analysis and characterization of sycamore acoustic system

## process_files.py

This script precess all wav audio files in a specific directory and extract peak, THD and dBc value of all files and channels to an CSV spreadsheet.
It is expected that these files were generated on the device using burst_loop.sh script

```bash
python3 process_files.py \path\to\directory
```

## burst_loop.sh

A bash script that loops through a list of frequencies (ex:300Hz-6666Hz) at a specific volume (ex: 1).
For each frequency a burst of 1.5sec tones will play with 0.5sec separation.
This is done to capture the first peak before the smart amp apply protection (ex: AGL & DRC).
The first delay and burst are meant to be ignored to account for the mic startup and any soft vol ramp.
The second tone should play at 100% and is meant for peak detection
The third tone (mark tone) plays at 25% volume to eliminate most of the smart amp nonlinear DSP processing (some still exist at ~250Hz and lower).

```bash
./burst_loop.sh 300 6666 1 \path\to\directory
```

## wav_thd.py

This script precess a specific channel (ex: 2)  for a specific wav audio file to extract THD and dBc values.
This script is used by precess_files.py script but will print more data specifically if debug is set to 1.

```bash
python3 wav_thd.py \path\to\file 2 1
```