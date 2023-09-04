import os
import sys
import subprocess

def list_files_in_directory(directory_path):
    try:
        file_names = [file for file in os.listdir(directory_path) if file.lower().endswith(".wav")]
        return file_names
    except OSError:
        print("Error: Unable to access the directory.")
        return []

if len(sys.argv) > 1:
    # If a directory path is provided as a command-line argument
    directory_path = sys.argv[1]
else:
    # Use the current directory if no command-line argument is provided
    directory_path = os.getcwd()

files = list_files_in_directory(directory_path)
print("List of files in the directory:")
print(files)

max_peak = 0
max_peak_idx = -1
max_peak_ch = -1
max_thd = 0
max_thd_idx = -1
max_thd_ch = -1
max_dBc = -100
max_dBc_idx = -1
max_dBc_ch = -1
idx=-1
max_dBc_harmonic=1000
for file in files:
    idx=idx+1
    for channel in range(4):
        print("i=",idx, " channel=", channel, "file=", file)
        completed_process = subprocess.run(['python3', 'wav_peak.py', directory_path+file, str(channel)], capture_output=True, text=True)
        print("Peak data",completed_process.stdout)
        return_values = completed_process.stdout.strip().split()
        if len(return_values) == 2:
            stats = [float(string) for string in return_values]
            if abs(stats[0]) > abs(max_peak):
                max_peak = stats[0]
                max_peak_idx = idx
                max_peak_ch = channel

        completed_process = subprocess.run(['python3', 'wav_thd.py', directory_path+file, str(channel)], capture_output=True, text=True)
        print("THD data",completed_process.stdout)
        return_values = completed_process.stdout.strip().split()
        if len(return_values) < 3:
            continue
        stats = [float(string) for string in return_values]
        if stats[0] > max_thd:
            max_thd = stats[0]
            max_thd_idx = idx
            max_thd_ch = channel
        if stats[1] > max_dBc:
            max_dBc = stats[1]
            max_dBc_harmonic = stats[2]
            max_dBc_idx = idx
            max_dBc_ch = channel


print("Highest peak file is", files[max_peak_idx], "with peak=", max_peak,"for channel", max_peak_ch)
if max_thd_idx >= 0 and max_dBc_idx >= 0:
    print("Worst case THD file is", files[max_thd_idx], "with THD=", round(max_thd*100,1),"% for channel", max_thd_ch)
    print("Worst case dBc file is", files[max_dBc_idx], "with dBc=", round(max_dBc,1), "dB at harmonic", int(max_dBc_harmonic),"for channel", max_dBc_ch)
else:
    print("negative index, thd=", max_thd_idx,"dBc=", max_dBc_idx)
