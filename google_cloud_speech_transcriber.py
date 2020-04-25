from google.cloud import speech_v1
from google.cloud import speech_v1p1beta1
from google.cloud.speech_v1 import enums
import io
import sys
import os

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/Users/betsysneller/Desktop/mi-covid-diaries/mi covid diaries-31ac6d932f0d.json"
#os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/Users/mattchurgin/Desktop/mi-covid-diaries/mi covid diaries-31ac6d932f0d.json"

def sample_long_running_recognize(storage_uri):
    """
    Transcribe a long audio file using asynchronous speech recognition

    Args:
      local_file_path Path to local audio file, e.g. /path/audio.wav
    """
    # standard speech client
    #client = speech_v1.SpeechClient()

    # if utilizing speaker diarization
    client = speech_v1p1beta1.SpeechClient()

    # local_file_path = 'resources/brooklyn_bridge.raw'

    # The language of the supplied audio
    language_code = "en-US"

    # Enhanced model to use
    model = "phone_call"

    # Sample rate in Hertz of the audio data sent
    sample_rate_hertz = int(sys.argv[2])

    # Optional. Specifies the estimated number of speakers in the conversation.
    diarization_speaker_count = 2

    # Encoding of audio data sent. This sample sets this explicitly.
    # This field is optional for FLAC and WAV audio formats.
    encoding = enums.RecognitionConfig.AudioEncoding.LINEAR16
    config = {
        "model": model,
        "use_enhanced": True,
        "language_code": language_code,
        "sample_rate_hertz": sample_rate_hertz,
        "encoding": encoding,
        "enable_automatic_punctuation": True,
        "enable_speaker_diarization": True,
        "diarization_speaker_count": diarization_speaker_count,
    }
    audio = {"uri": storage_uri}

    operation = client.long_running_recognize(config, audio)

    print(u"Waiting for operation to complete...")
    response = operation.result()
    outtext = list()
    out_text_speaker = list()
    out_text_speaker_label = list()
    for result in response.results:
        # First alternative is the most probable result
        alternative = result.alternatives[0]
#        print(u"Transcript: {}".format(alternative.transcript))
        outtext.append(alternative.transcript)

        for word in alternative.words:
            print(u"Speaker: {}, Word: {}".format(word.speaker_tag, word.word))
            out_text_speaker.append(word.word)
            out_text_speaker_label.append(word.speaker_tag)

    return outtext, out_text_speaker, out_text_speaker_label

audio_file = sys.argv[1]
print(f'Transcribing file: {audio_file}:')
textout, textout_speaker, textout_speaker_label = sample_long_running_recognize(audio_file)

outfilename = os.path.split(audio_file)[-1]
outpath = sys.argv[3]
outpathname = os.path.join(outpath, outfilename[:-4] + '.txt')


with open(outpathname, "w") as text_file:
    text_file.write("\n".join(textout))
#with open("transcript_speaker.txt", "w") as text_file:
#    text_file.write(" ".join(textout_speaker))
#with open("transcript_speaker_label.txt", "w") as text_file:
#    text_file.write(" ".join(str(textout_speaker_label)))

