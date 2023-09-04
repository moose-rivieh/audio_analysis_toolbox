#!/bin/bash

#This scripts generates 3 seconds single tones in 1/6 octave increments and save the results
#The results are meant to process by the wav_thd file which process the last one seconds
#This was done this way to avoid any soft volume ramp up while still achiving 1Hz fft resolution

# Check if exactly 2 arguments were provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <start_freq> <end_freq> <vol> <dir_path>"
    exit 1
fi

start=$1
end=$2
vol=$3
path=$4

mic_card="imxaudiomicfil"
mic_format="S16_LE"
mic_rate="16000"
mic_chs="4"
spk_fomrat="S32LE"
spk_rate="48000"
spk_chs="2"


# Check if start is less than or equal to end
if [ "$start" -gt "$end" ]; then
    echo "Error: Start value must be less than or equal to end value."
    exit 1
fi

# Loop through the range
for ((freq = end; freq >= start; freq=6*(freq/7))); do
    echo "Frequency = $freq @ $vol volume"
    arecord -Dhw:${mic_card},0 -f${mic_format} -r${mic_rate} -c${mic_chs} -d4 -twav ${path}freq_${freq}.wav & sleep 1
    gst-launch-1.0 audiotestsrc wave=0 freq=$freq volume=$vol num-buffers=144 ! audio/x-raw,format=${spk_fomrat},rate=${spk_rate},channels=${spk_chs} ! alsasink 
    sleep 2 
done