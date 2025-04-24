#!/bin/bash

OUTPUT_FILE="/config/scripts/screen-mode"

echo "[screen mode]" > "$OUTPUT_FILE"

pixelpilot --screen-mode-list | \
  awk -F'[@x]' '{print $3, $1, $2, $0}' | \
  sort -nr -k1,1 -k2,2 -k3,3 | \
  head -1 | \
  awk '{print $4}' | \
  awk '{print "mode = " $0}' >> "$OUTPUT_FILE"

echo "Saved highest FPS screen mode to $OUTPUT_FILE:"
cat "$OUTPUT_FILE"

exit 0
