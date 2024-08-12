from RealtimeTTS import SystemEngine, TextToAudioStream
streamengine = SystemEngine()
stream = TextToAudioStream(engine=streamengine)
def generateaudio(text, mute):
    stream.feed(text)
    stream.play(muted=mute, output_wavfile="audio/tts.wav")
