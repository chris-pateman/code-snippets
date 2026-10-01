
application="audiostream1"
audioFilePath="${AUDIO_FILE_PATH:-./audio-example.mp4}"
fileName="test-stream"
source="127.0.0.1"

ffmpeg_url="rtmps://$source:443/$application/$fileName"

echo "URL: $ffmpeg_url"
echo "Audio Path: $audioFilePath"

ffmpeg -re -i $audioFilePath -c copy -f flv "$ffmpeg_url flashver=FMLE/3.0\20(compatible;\20FMSc/1.0) live=true pubUser=wowza title=$fileName" -loglevel verbose