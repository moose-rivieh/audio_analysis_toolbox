#!/bin/bash

if [ $# -ne 5 ]; then
    echo "Usage: $0 <delay> <spk_gain> <mic_gain> <source_signal> <source_volume>"
    exit 1
fi

delay=$1
spk_gain=$2
mic_gain=$3
source_signal=$4
source_vol=$5
freq="2256"

file_path="/unit_tests/nxp-afe/Config.ini"

# Check if the file exists
if [ ! -f "$file_path" ]; then
    echo "File not found: $file_path"
    exit 1
fi

killall afe
killall voice_ui_app

sleep 2


# Replace "test=0" with "test=1" using sed
sed -i "s/DebugEnable = 0/DebugEnable = 1/g" "$file_path"
sed -i "s/\(SignalDelay *= *\).*/\1$delay/g" "$file_path"
echo "Replacement completed."
cat $file_path

#config mixer
amixer -c tas5805mamp sset 'Master' -- ${spk_gain}dB 
amixer -c imxaudiomicfil sset 'MICFIL Quality Select' 'High'
for ((i=0; i<4; i++)); do
    amixer -c imxaudiomicfil sset CH${i} $mic_gain
done

modprobe snd-aloop

#remove old cal files
rm /tmp/mic*
rm /tmp/ref*

cd /unit_tests/nxp-afe
./voice_ui_app &
./afe libvoiceseekerlight hw:tas5805mamp,0 &

case $source_signal in
  0)
    echo "Single tone at $freq Hz and $source_vol volume"
    gst-launch-1.0 audiotestsrc wave=0 freq=${freq} volume=${source_vol} num-buffers=1440 ! audio/x-raw,format=S32LE,rate=48000,channels=2 ! alsasink
    ;;
  1)
    echo "Burst tone at $freq Hz"
    gst-launch-1.0 audiotestsrc wave=8 freq=${freq} volume=${source_vol} num-buffers=336 tick_interval=2000000000 sine-periods-per-tick=3384 marker-tick-period=2 marker-tick-volume=0.25 ! audio/x-raw,format=S32LE,rate=48000,channels=2 ! alsasink
    ;;
  2)
    echo "White noise at $source_vol volume"
    gst-launch-1.0 audiotestsrc wave=5 volume=${source_vol} num-buffers=1440 ! audio/x-raw,format=S32LE,rate=48000,channels=2 ! alsasink
    ;;
  3)
    echo "Pink noise at $source_vol volume"
    gst-launch-1.0 audiotestsrc wave=6 volume=${source_vol} num-buffers=1440 ! audio/x-raw,format=S32LE,rate=48000,channels=2 ! alsasink
    ;;
  *)
    echo "Invalid argument. Please provide a value between 0 and 3."
    ;;
esac

sleep 1

#disable debug
sed -i 's/DebugEnable = 1/DebugEnable = 0/g' "$file_path"

#Kill running processes
killall afe
killall voice_ui_app

sleep 1

echo "All done. Check cal files in /tmp"
