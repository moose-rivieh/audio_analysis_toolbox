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
spk_card="tas5805mamp"
spk_format="S32_LE"
spk_format_gst="S32LE"
spk_rate="48000"
spk_chs="2"


# Check if start is less than or equal to end
if [ "$start" -gt "$end" ]; then
    echo "Error: Start value must be less than or equal to end value."
    exit 1
fi

# Loop through the range
for ((freq = end; freq >= start; freq=6*(freq/7))); do
    duration=$(((freq*3)/2)) #1.5seconds
    echo "Frequency = $freq @ $vol volume"
    arecord -Dhw:${mic_card},0 -f${mic_format} -r${mic_rate} -c${mic_chs} -d6 -twav ${path}mic_freq_${freq}.wav & \ 
    gst-launch-1.0 audiotestsrc wave=8 freq=$freq volume=$vol num-buffers=336 tick_interval=2000000000 sine-periods-per-tick=$duration marker-tick-period=2 marker-tick-volume=0.25 ! audio/x-raw,format=${spk_format_gst},rate=${spk_rate},channels=${spk_chs} ! alsasink  & \
    arecord -Dhw:${spk_card},0 -f${spk_format} -r${spk_rate} -c${spk_chs} -d6 -twav ${path}ref_freq_${freq}.wav	
    sleep 2 
done
