
application="audiostream1"
audioFilePath="/mnt/c/Users/patemanc/pateman.workspace/test-area/cpexample.mp4"
fileName="new-licence"

## _________________________ ##
source=$(printenv source)
if [[ $source -eq "" ]]; then
  source="127.0.0.1"
fi

ffmpeg_url="rtmps://${source}:443/${application}"

ffmpeg -re -i $audioFilePath -c copy -f flv "${ffmpeg_url} flashver=FMLE/3.0\20(compatible;\20FMSc/1.0) live=true pubUser=wowza playpath=$fileName" -loglevel debug