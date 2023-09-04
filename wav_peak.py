import sys
import numpy as np
from scipy.fft import fft, ifft
from scipy.signal import find_peaks
import matplotlib.pyplot as plt
import librosa
from librosa import display

def main(wav_file, channel, debug):
  fs = librosa.get_samplerate(wav_file)
  multi_data, fs = librosa.load(wav_file, sr=fs, offset=0.9, mono=False)
  data = multi_data[channel,:]
  Ns = len(data)
  duration = Ns/fs
  if debug>0:
    print("sample rate: ", fs,"Hz")
    print("number of samples: ", Ns/1000,"K")
    print("duration: ", duration*1000,"ms")
    print("samples array dimensions: ", data.shape)
    plt.figure
    librosa.display.waveshow(data, sr = fs)
    plt.xlabel("Time [sec]")
    plt.ylabel("Amp")
    plt.show()

  peak = -2

  # Find peak
  positive_peak_idx = np.argmax(data)
  positive_peak = data[positive_peak_idx]
  negative_peak_idx = np.argmin(data)
  negative_peak = data[negative_peak_idx]

  if positive_peak >= abs(negative_peak):
    peak=positive_peak
    peak_idx=positive_peak_idx
  else:
    peak=negative_peak
    peak_idx = negative_peak_idx

  peak_sample_time_ms = round(1000*peak_idx/fs,0)

  return peak, peak_sample_time_ms

if __name__ == "__main__":
  wav_file = sys.argv[1]
  channel = 0
  if len(sys.argv) > 2:
    channel = int(sys.argv[2])
  debug = 0
  if len(sys.argv) > 3:
    debug = int(sys.argv[3])
  peak, time = main(wav_file, channel, debug)  
  print(peak, time)