#!/bin/sh



case "$#" in
  4)
    INPUT_FILE="$1"
    START_TIME="$2"
    END_TIME="$3"
    OUTPUT_FILE="$4"
    ;;
  *)
    echo "Usage: $0 <input_file> <start_time> <end_time> <output_file>"
    exit 1
    ;;
esac

ffmpeg \
  -i "$INPUT_FILE" \
  -ss "$START_TIME" \
  -to "$END_TIME" \
  -c copy \
  "$OUTPUT_FILE"
