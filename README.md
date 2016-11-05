### Zoneminder docker for Raspian

1. Clone and modify files, if needed, in a folder into RaspbianOS.
2. Run build command:
```
docker build -t luctogno:rpi_zoneminder .
```

3. If the operation goes successfull run container with a command like:
```
docker run \
        -d \
        --name="Zoneminder-Rasp" \
        --privileged=true \
        -v /etc/localtime:/etc/localtime:ro \
        -v /home/pi/docker/zoneminder/config:/config:rw \
        -p 8002:80 \
        --restart=always \
        luctogno:rpi_zoneminder
```

NOTE: If you want you can rename image luctogno:rpi_zoneminder with your own name, but you need to change in line 2 and line 3.
NOTE2: I use port 8002 instead of 80 for my local network. If you want change the "-p" line like this: -p port_outside_container:port_inside_container.

If all go OK you have zoneminder available at url: http://raspberry_ip:8002/zm/

#### Tips and Setup Instructions FROM aptalca, try these if something doen't work:
- This container includes mysql, no need for a separate mysql/mariadb container
- All settings and library files are stored outside of the container and they are preserved when this docker is updated or re-installed (change the variable "/path/to/config" in the run command to a location of your choice)
- This container includes avconv (ffmpeg variant) and cambozola but they need to be enabled in the settings. In the WebUI, click on Options in the top right corner and go to the Images tab
- Click on the box next to OPT_Cambozola to enable
- Click on the box next OPT_FFMPEG to enable ffmpeg
- Enter the following for ffmpeg path: /usr/bin/avconv
- Enter the following for ffmpeg "output" options: -r 30 -vcodec libx264 -threads 2 -b 2000k -minrate 800k -maxrate 5000k (you can change these options to your liking)
- Next to ffmpeg_formats, add mp4 (you can also add a star after mp4 and remove the star after avi to make mp4 the default format)
- Hit save
- Now you should be able to add your cams and record in mp4 x264 format
- PS. In options under display, change the skin to "flat" it looks 100 times nicer

TESTED ON Raspberry 2 with Raspian Lite.

CREDITS:
mrLitter -> https://forums.zoneminder.com/viewtopic.php?t=24683
aptalca -> https://github.com/aptalca/docker-zoneminder