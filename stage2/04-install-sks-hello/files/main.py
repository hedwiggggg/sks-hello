import os
import struct
from datetime import datetime

from threading import Thread
import subprocess

import pvporcupine
import pyaudio


KEYWORD_PATHS = [
    pvporcupine.KEYWORD_PATHS["alexa"],
    pvporcupine.KEYWORD_PATHS["hey siri"],
    pvporcupine.KEYWORD_PATHS["ok google"]
]

SENSITIVITIES = [1.0] * len(KEYWORD_PATHS)
LIBRARY_PATH = pvporcupine.LIBRARY_PATH
MODEL_PATH = pvporcupine.MODEL_PATH

WAV_READY_FILENAME = "/boot/sks-hello/_ready.wav"
WAV_DETECTED_FILENAME = "/boot/sks-hello/_detected.wav"


class SKSHello(Thread):
    def __init__(self):
        super(SKSHello, self).__init__()

        self._library_path = LIBRARY_PATH
        self._model_path = MODEL_PATH
        self._keyword_paths = KEYWORD_PATHS
        self._sensitivities = SENSITIVITIES
        self._pa = None

    def play_audio(self, path):
        print('[%s] Play sound - start %s' %
                (str(datetime.now()), path))

        def target():
            subprocess.call(["aplay", path])

        thread = Thread(target=target)
        thread.start()

    def run(self):
        keywords = list()
        for x in self._keyword_paths:
            keywords.append(os.path.basename(
                x).replace('.ppn', '').split('_')[0])

        porcupine = None
        audio_stream_mic = None

        try:
            porcupine = pvporcupine.create(
                library_path=self._library_path,
                model_path=self._model_path,
                keyword_paths=self._keyword_paths,
                sensitivities=self._sensitivities)

            self._pa = pyaudio.PyAudio()
            self.play_audio(WAV_READY_FILENAME)

            audio_stream_mic = self._pa.open(
                rate=porcupine.sample_rate,
                channels=1,
                format=pyaudio.paInt16,
                input=True,
                frames_per_buffer=porcupine.frame_length)

            print('Listening {')
            for keyword, sensitivity in zip(keywords, self._sensitivities):
                print('  %s (%.2f)' % (keyword, sensitivity))
            print('}')

            while True:
                pcm = audio_stream_mic.read(porcupine.frame_length)
                pcm = struct.unpack_from("h" * porcupine.frame_length, pcm)
                result = porcupine.process(pcm)

                if result >= 0:
                    print('[%s] Detected %s' %
                          (str(datetime.now()), keywords[result]))
                    
                    self.play_audio(WAV_DETECTED_FILENAME)

        except KeyboardInterrupt:
            print('Stopping ...')

        finally:
            if porcupine is not None:
                porcupine.delete()

            if audio_stream_mic is not None:
                audio_stream_mic.close()

            if self._pa is not None:
                self._pa.terminate()


if __name__ == '__main__':
    SKSHello().run()
