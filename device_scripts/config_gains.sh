#!/bin/bash

# Check if exactly 2 arguments were provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <start_freq> <end_freq>"
    exit 1
fi

mic_gain=$2
mic_card="imxaudiomicfil"
spk_gain=$1
spk_card="tas5805mamp"
mic_quality="High"

echo "Set mic card $mic_card gain to $2"

# Check if mic_gain is less than or equal 0
if [ "0" -gt "$mic_gain" ]; then
    echo "Error: Mic gain is less than 0."
    exit 1
fi

# Check if mic_gain is less than or equal 0
if [ "$mic_gain" -gt "7" ]; then
    echo "Error: Mic gain is greater than 6."
    exit 1
fi

# Loop through the range
for ((i = 0; i<=7 ; i++)); do
    amixer -c $mic_card sset CH$i $mic_gain
done

echo "set mic card $mic_card quality to ${mic_quality}"
amixer -c $mic_card sset 'MICFIL Quality Select' $mic_quality

echo "set spk card $spk_card gain to ${1}dB"
amixer -c $spk_card sset 'Master' -- ${spk_gain}dB