#!/bin/bash

echo "HELLO SKS!"

FILE=/home/sks/hello/initialized

if [ -f "$FILE" ]; then
  echo "$FILE EXISTS"
  echo "CREATE /etc/asound.conf"

  echo "GETTING SPEAKER"
  CARD_SPEAKER=$(aplay -l | grep -m 1 "bcm2835 Headphones" | grep -oP 'card \K(.+?)(?=:)')
  DEVICE_SPEAKER=$(aplay -l | grep -m 1 "bcm2835 Headphones" | grep -oP 'device \K(.+?)(?=:)')

  if [[ -z "$CARD_SPEAKER" || -z "$DEVICE_SPEAKER" ]]; then
    echo "NOT FOUND SPEAKER"
    exit 1
  else
    echo "USING (speaker) hw:$CARD_SPEAKER,$DEVICE_SPEAKER"
  fi

  echo "GETTING MIC (SK30)"
  CARD_MIC=$(arecord -l | grep -m 1 "SK30" | grep -oP 'card \K(.+?)(?=:)')
  DEVICE_MIC=$(arecord -l | grep -m 1 "SK30" | grep -oP 'device \K(.+?)(?=:)')

  if [[ -z "$CARD_MIC" || -z "$DEVICE_MIC" ]]; then
    echo "NOT FOUND MIC (SK30)"

    echo "GETTING MIC (USB Microphone)"
    CARD_MIC=$(arecord -l | grep -m 1 "USB Microphone" | grep -oP 'card \K(.+?)(?=:)')
    DEVICE_MIC=$(arecord -l | grep -m 1 "USB Microphone" | grep -oP 'device \K(.+?)(?=:)')
  fi

  if [[ -z "$CARD_MIC" || -z "$DEVICE_MIC" ]]; then
    echo "NOT FOUND MIC (USB Microphone)"
    exit 1
  else
    echo "USING (mic)     hw:$CARD_MIC,$DEVICE_MIC"
  fi

  touch /etc/asound.conf

  cat << EOF > /etc/asound.conf
pcm.!default {
  type asym
  capture.pcm "mic"
  playback.pcm "speaker"
}

pcm.mic {
  type plug
  slave {
    pcm "hw:$CARD_MIC,$DEVICE_MIC"
  }
}

pcm.speaker {
  type plug
  slave {
    pcm "hw:$CARD_SPEAKER,$DEVICE_SPEAKER"
  }
}
EOF

  echo "SET VOLUME TO 100%"
  amixer --card $CARD_MIC sset 'Mic' 100%
  amixer --card $CARD_SPEAKER sset 'Headphone' 100%

  python3 /home/sks/hello/main.py
else 
  echo "$FILE DOESN'T EXIST"
  touch /home/sks/hello/initialized

  echo "ACTIVATE OVERLAYFS"
  raspi-config nonint do_overlayfs 0
  reboot
fi
