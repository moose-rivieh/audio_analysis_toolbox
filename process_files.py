import os
import sys
import subprocess
import csv

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


idx=0
no_of_channels=4+1 #+1 for the for case where we average all channels
records = [['na' for _ in range(10)] for _ in range(len(files)*no_of_channels+1)]
records[0][:] = ['index','file','source','freq_Hz','channel','peak_amplitude','peak_time_ms','THD','dBc','dBc_harmonic']
for file in files:
    print("file=", file)
    for channel in range(no_of_channels):
        idx=idx+1
        print("channel=", channel)
        #expect the following filename formate SRC_freq_xxx.wav
        file_name = file[:-4] #remove .wav
        source = file_name[:3] #get source. Either mic or ref
        freq = file_name[9:] #drop _freq_
        
        records[idx][0:4] = [str(idx), file, source, freq, str(channel)]

        completed_process = subprocess.run(['python3', 'wav_peak.py', directory_path+file, str(channel)], capture_output=True, text=True)
        return_values = completed_process.stdout.strip().split()
        if len(return_values) == 2:
            records[idx][5:6] = return_values

        completed_process = subprocess.run(['python3', 'wav_thd.py', directory_path+file, str(channel)], capture_output=True, text=True)
        return_values = completed_process.stdout.strip().split()
        if len(return_values) < 3:
            continue
        else:
            records[idx][7:9] = return_values

# Specify the CSV file name
csv_filename = "audio_analysis_output.csv"

# Open the CSV file in write mode
with open(csv_filename, mode='w', newline='') as csv_file:
    # Create a CSV writer object
    csv_writer = csv.writer(csv_file)

    # Write each row of the array to the CSV file
    for row in records:
        csv_writer.writerow(row)

print(f"Array has been written to {csv_filename}")
