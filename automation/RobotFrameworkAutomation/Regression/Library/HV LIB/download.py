import os.path
def verify_wav_file_existence(wav_file):
    if not os.path.exists(wav_file):
        raise Exception("The wav file is missing.")