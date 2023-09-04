#!/bin/bash



# Check if exactly 3 arguments were provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <freq> <vol> <dir_path>"
    exit 1
fi

freq=$1
vol=$2
path=$3

mic_card="tas5805mamp"
mic_format="S32_LE"
mic_rate="48000"
mic_chs="2"
spk_fomrat="S32LE"
spk_rate="48000"
spk_chs="2"



echo "mode 0 (sine) Frequency = $freq @ $vol volume"
arecord -Dhw:${mic_card},0 -f${mic_format} -r${mic_rate} -c${mic_chs} -d4 -twav ${path}mode0_freq${freq}_vol${vol}.wav & \
gst-launch-1.0 audiotestsrc wave=0 freq=$freq volume=$vol num-buffers=144 ! audio/x-raw,format=${spk_fomrat},rate=${spk_rate},channels=${spk_chs} ! alsasink
sleep 2

echo "mode 8 (ticks) Frequency = $freq @ $vol volume"
arecord -Dhw:${mic_card},0 -f${mic_format} -r${mic_rate} -c${mic_chs} -d4 -twav ${path}mode8__freq${freq}_vol${vol}.wav & \
gst-launch-1.0 audiotestsrc wave=8 freq=$freq volume=$vol num-buffers=144 tick_interval=1500000000 sine-periods-per-tick=$freq ! audio/x-raw,format=${spk_fomrat},rate=${spk_rate},channels=${spk_chs} ! alsasink
sleep 2

echo "mode 8 (ticks) Frequency = $freq @ $vol volume and 25%"
arecord -Dhw:${mic_card},0 -f${mic_format} -r${mic_rate} -c${mic_chs} -d6 -twav ${path}mode8__freq${freq}_vol${vol}_and_25%.wav & \
gst-launch-1.0 audiotestsrc wave=8 freq=$freq volume=$vol num-buffers=216 tick_interval=1500000000 sine-periods-per-tick=$freq marker-tick-period=2 marker-tick-volume=0.25 ! audio/x-raw,format=${spk_fomrat},rate=${spk_rate},channels=${spk_chs} ! alsasink
sleep 2

echo "mode 5 (while noise) @ $vol volume"
arecord -Dhw:${mic_card},0 -f${mic_format} -r${mic_rate} -c${mic_chs} -d4 -twav ${path}mode5_vol${vol}.wav & \
gst-launch-1.0 audiotestsrc wave=5 volume=$vol num-buffers=144 ! audio/x-raw,format=${spk_fomrat},rate=${spk_rate},channels=${spk_chs} ! alsasink
sleep 2

echo "mode 6 (pink noise) @ $vol volume"
arecord -Dhw:${mic_card},0 -f${mic_format} -r${mic_rate} -c${mic_chs} -d4 -twav ${path}mode6_vol${vol}.wav & \
gst-launch-1.0 audiotestsrc wave=6 volume=$vol num-buffers=144 ! audio/x-raw,format=${spk_fomrat},rate=${spk_rate},channels=${spk_chs} ! alsasink
sleep 2
