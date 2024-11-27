import time
import multiprocessing
from playsound import playsound

def play_wav_file(wav_file):
    p = multiprocessing.Process(target=playsound, args=(wav_file,))
    p.start()
    time.sleep(5)
    input("press ENTER to stop playback")
    p.terminate()
