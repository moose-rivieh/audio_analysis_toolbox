#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Usage: $0 <delay> <spk_gain> <mic_gain> <source_file>"
    exit 1
fi

delay=$1
spk_gain=$2
mic_gain=$3
path=$4

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
aplay ${path}
sleep 1

#disable debug
sed -i 's/DebugEnable = 1/DebugEnable = 0/g' "$file_path"

#Kill running processes
killall afe
killall voice_ui_app

sleep 1

echo "All done. Check cal files in /tmp"
