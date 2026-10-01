source=$(printenv source)
ffmpeg_url="rtmps://${source}:443/${application}" 
ffmpeg -re -i $audioFilePath -c copy -f flv "${ffmpeg_url} flashver=FMLE/3.0\20(compatible;\20FMSc/1.0) live=true pubUser=wowza playpath=$fileName" -loglevel verbose
