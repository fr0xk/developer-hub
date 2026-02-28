#!/usr/bin/env bash

URL="$1"

if [ -z "$URL" ]; then
    echo "Usage: $0 <youtube-url>"
    exit 1
fi

yt-dlp \
  -f "bestvideo[height=480][ext=mp4]+bestaudio[ext=m4a]\
/bestvideo[height=360][ext=mp4]+bestaudio[ext=m4a]\
/best[height=480][ext=mp4]\
/best[height=360][ext=mp4]" \
  --merge-output-format mp4 \
  "$URL"
