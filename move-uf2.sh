#!/bin/bash

#####################
# Settings are below
#####################

# set to the downloads directory where your browser downloads to
DOWNLOADS=~/Downloads

# set to the file pattern to glob
CP_GLOB=circuitplayground-*.uf2

# set to the location circuit playground mounts to when connected
CP_MOUNT=/media/pi/CPLAYBOOT

#####################
# Do not modify the remainder of this script
#####################

# get the last downloaded file to move (ignore the rest)
cd $DOWNLOADS
LATEST=$(ls -dt $CP_GLOB | head -1)
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Error occured looking for latest '$DOWNLOADS/$CP_GLOB'"
  exit 10
fi
if [ -z "$LATEST" ]; then
  echo "Could not find a file matching '$DOWNLOADS/$GP_GLOB'"
  exit 11
fi
echo "Found file '$LATEST' to move."

# test to see if circuit playground is connected
if [ ! -d "$CP_MOUNT" ]; then
  echo "Circuit Playground not found at '$CP_MOUNT'. Make sure it is plugged in and all LEDs are GREEN."
  exit 12
fi
echo "Found Circuit Playground mounted at '$CP_MOUNT'"

# ready!  let's move it!
echo "Moving '$LATEST' to '$CP_MOUNT/'"
mv "$LATEST" "$CP_MOUNT/"
if [ $RESULT -ne 0 ]; then
  echo "$RESULT: Error occured moving '$DOWNLOADS/$CP_GLOB' to '$CP_MOUNT'"
  exit 13
fi
echo "Move complete! Exiting script."
exit 0

