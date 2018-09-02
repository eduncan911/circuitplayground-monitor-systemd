#!/bin/bash

####################
# Change settings below to match your system
####################

# set your Downloads directory that your browser downloads to by default
DOWNLOADS_DIR="$HOME/Downloads"


###################
# Do not change anything else below this line
###################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
CP_UNIT_PATH="circuitplayground-monitor.path"
CP_UNIT_SERV="circuitplayground-monitor.service"

# sanity checks
if [ ! -f "$CP_UNIT_PATH" ]; then
  echo "$CP_UNIT_PATH not found, exiting."
  exit 10
fi
if [ ! -f "$CP_UNIT_SERV" ]; then
  echo "$CP_UNIT_SERV not found, exiting."
  exit 11
fi
if [ ! -d "$DOWNLOADS_DIR" ]; then
  echo "$DOWNLOADS_DIR not found, exiting."
  exit 13
fi

echo "Ensuring $SYSTEMD_USER_DIR exists"
mkdir -p "$SYSTEMD_USER_DIR"
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Could not create $SYSTEMD_USER_DIR"
  exit 12
fi

echo "Copying systemd unit files to local user directory"
cp "$CP_UNIT_PATH" "$SYSTEMD_USER_DIR/"
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Error copying file to $SYSTEMD_USER_DIR/$CP_UNIT_PATH"
  exit 14
fi
cp "$CP_UNIT_SERV" "$SYSTEMD_USER_DIR/"
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Error copying file to $SYSTEMD_USER_DIR/$CP_UNIT_SERV"
  exit 15
fi

echo "Modifying $CP_UNIT_PATH files for Downloads dir: $DOWNLOADS_DIR"
sed -i "s@DOWNLOADS_DIR@$DOWNLOADS_DIR@g" "$SYSTEMD_USER_DIR/$CP_UNIT_PATH"
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Error modifying $SYSTEMD_USER_DIR/$CP_UNIT_PATH for $DOWNLOADS_DIR"
  exit 16
fi

echo "Modifying $CP_UNIT_SERV files for Downloads dir: $DOWNLOADS_DIR"
sed -i "s@DOWNLOADS_DIR@$DOWNLOADS_DIR@g" "$SYSTEMD_USER_DIR/$CP_UNIT_SERV"
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Error modifying $SYSTEMD_USER_DIR/$CP_UNIT_SERV for $DOWNLOADS_DIR"
  exit 17
fi

echo "Modifying $CP_UNIT_SERV files for this script: $SCRIPT_DIR"
sed -i "s@SCRIPT_DIR@$SCRIPT_DIR@g" "$SYSTEMD_USER_DIR/$CP_UNIT_SERV"
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Error modifying $SYSTEMD_USER_DIR/$CP_UNIT_SERV for $SCRIPT_DIR"
  exit 18
fi

echo "Enabling systemd monitors"
systemctl --user enable circuitplayground-monitor.path
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Error enabling $CP_UNIT_PATH in the --user space"
  exit 19
fi
systemctl --user start circuitplayground-monitor.path
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  echo "$RESULT: Error starting $CP_UNIT_PATH in the --user space"
  exit 20
fi

echo ""
echo "Installation has been completed!"
echo ""
echo "What's next?"
echo "Go ahead and plug in your CircuitPlayground Express, create a project in MakeFile, press the Save button and BAM - if all goes well, your CircuitPlayground will reboot and run your custom code!"
echo ""
echo "Please drop me a line and let me know how it worked for you!  Would love to hear all about it!"
echo "https://twitter.com/eduncan911"
exit 0
