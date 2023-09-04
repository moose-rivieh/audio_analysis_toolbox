import sys
import numpy as np
from scipy.fft import fft, ifft
from scipy.signal import find_peaks
import matplotlib.pyplot as plt
import librosa
from librosa import display

def main(wav_file, channel, debug):
  fs = librosa.get_samplerate(wav_file)
  multi_data, fs = librosa.load(wav_file, sr=fs, offset=5,duration=1, mono=False)
  data = multi_data[channel,:]
  Ns = len(data)
  duration = Ns/fs
  if debug>0:
    print("sample rate: ", fs,"Hz")
    print("number of samples: ", Ns/1000,"K")
    print("duration: ", duration*1000,"ms")
    print("samples array dimensions: ", data.shape)
    PLT_X_WIDTH_ms = 100
    n_of_samples_to_show = round(fs * PLT_X_WIDTH_ms / 1000)
    sliced_data = data[:n_of_samples_to_show]
    plt.figure
    librosa.display.waveshow(y = sliced_data, sr = fs)
    plt.xlabel("Time [sec]")
    plt.ylabel("Amp")
    plt.show()

  # Calculate the FFT of the signal.
  fft_data_cplx = fft(data)
  fft_data = np.abs(fft_data_cplx[:fft_data_cplx.shape[0]//2])
  fft_amp = fft_data * 2 / Ns
  fft_dB = 20 * np.log10(fft_amp)
  freq = np.linspace(0,(fs/2)/1000,num=Ns//2)

  if debug>0:
    plt.plot(freq,fft_dB)
    plt.xlabel('Freq [kHz]')
    plt.ylabel('dB')
    plt.ylim(-100,0)
    plt.show()

  #fft_peaks, _ = find_peaks(tmp, threshold=40)
  fft_peaks = np.zeros(10)
  fft_peaks[0] = np.argmax(fft_dB)
  tmp = fft_dB.copy()
  tmp[:int(fft_peaks[0]+25)] = np.min(tmp)
  i=1
  while i < fft_peaks.shape[0]:
    cur_harmonic = np.argmax(tmp)
    tmp[cur_harmonic-25:cur_harmonic+25] = np.min(tmp)
    fft_peaks[i] = cur_harmonic
    i = i + 1

  fft_peaks = np.asarray(fft_peaks, dtype ='int')

  if debug>0:
    print("fft_peaks: ", fft_peaks)
    plt.plot(freq,tmp)
    plt.xlabel('Freq [kHz]')
    plt.ylabel('dB')
    plt.ylim(-100,0)
    plt.show()

  fund_idx = fft_peaks[0]
  fund_freq = fund_idx * fs/Ns
  fund_dB = fft_dB[fund_idx]
  if debug>0:
      print("Fundamental: ", fund_dB, "dB @ ", fund_freq,"Hz")


  harmonics_freq = fft_peaks[1:] * fs/Ns
  harmonics_dB = fft_dB[fft_peaks[1:]]
  harmonics_dBc = fft_dB[fft_peaks[1:]] - fund_dB
  max_dBc = harmonics_dBc[0]
  max_dBc_idx = harmonics_freq[0]/fund_freq
  if debug>0:
    print("Harmonics in Hz: ", np.around(harmonics_freq,0))
    print("Harmonics in dB: ", np.around(harmonics_dB,1))
    print("Harmonics in dBc: ", np.around(harmonics_dBc,1))

  fund_amp = fft_amp[fund_idx]
  THD = np.sqrt(np.sum(np.square(fft_amp[fund_idx+1:]))) / fund_amp
  if debug>0:
    print("THD: ", round(THD*100,1), "%")
  return THD, max_dBc, max_dBc_idx

if __name__ == "__main__":
  wav_file = sys.argv[1]
  channel = 0
  if len(sys.argv) > 2:
    channel = int(sys.argv[2])
  debug = 0
  if len(sys.argv) > 3:
    debug = int(sys.argv[3])
  thd, dBc, idx = main(wav_file, channel, debug)  
  print(thd, dBc, idx)