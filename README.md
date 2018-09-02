# CircuitPlayground Express Monitor for Linux and BSD

A set of scripts to monitor for CircuitPlayground Express downloaded files that puts them onto the CircuitPlayground Express for you.

### Compatibility

These scripts were written on Raspbian on a Raspberry Pi for a CircuitPlayground Express.  However, since it uses pure bash and Systemd, it should be compatible with any system that uses Systemd and any platform (arm, amd64, x86, etc).

* Debian-based distros (Ubuntu, Raspbian, etc)
* BSD
* CentOS

...etc.

### Quick Start

Open a Terminal window and copy-n-paste (or type) the following:

```
cd ~/Downloads	 # if your browser downloads elsewhere, edit ./install.sh
git clone https://github.com/eduncan911/circuitplayground-monitor-systemd
cd circuitplayground-monitor-systemd
./install.sh
```

You are now ready to load up your CircuitPlayground Express.

### How to Use

1. Plug in your Circuit Playground Express (make sure the LEDs turn GREEN).

2. Create your fancy MakeCode project

3. When ready to load, press the Save icon (or the Download button).

POOF!  Your Circuit Playground Express reboots and is running your custom software!

## About CircuitPlayground Systemd Monitor

As a father, I have introduced my kids to several microcontrollers including UP Boards, Arduino and Raspberry Pis. Current their personal tablets all are based on the Raspberry Pi for the GPIO pins.  Since we have several CircuitPlayground devices (Express and Classic, from various Adabox, Starter Kits and other free aquires), I needed a way to ease their programming play by automating the way files are downloaded from MakeCode (and other online editors) and onto the Circuit Playground, without unleashing a six year old onto a local File Manager!  :)

Therefore, the solution I came up with was to leverage Systemd's features to automate the copying process.

Systemd comes with most FreeBSD and Linux flavors, such as Raspbian and Arch Linux (what a couple Raspberry Pis are running in our house).  So why not leverage these built-in utilities?

As a bonus, in case something does go funky, I setup the scripts to run in the local Systemd `--user` space - and not as root.

## How does it work?

These scripts will use Systemd's file monitoring feature to monitor your "Downloads" folder for your browser (configurable in the `./install.sh` script if you need to change it).

When you download a file matching the glob pattern of `~/Downloads/circuitplayground-*.uf2`, the Systemd unit service will run a special script file.

That script file simply `moves` the matching file to your expected CircuitPlayground Express default mount.

## Why not WebUSB?

Google Chrome's `WebUSB` is pretty slick and works perfectly with Microsoft's MakeCode (https://makecode.adafruit.com/beta?webusb=1#editor).  If you are on a normal desktop running Google Chrome, you should really go that route.  Instructions can be found here: https://learn.adafruit.com/makecode/webusb

However, `WebUSB` only works under two conditions:

* Google Chrome only.  No FireFox, Microsoft Edge (Windows), Safari (macOS), etc.
* Works only on amd64 (64-bit) processors using the x86 instruction sets.  No ARM devices.

What is the problem with these restrictions?  Two words: Raspberry Pi.

You cannot install Google Chrome onto any ARM device, such as a Raspberry Pi.  Chromium is available, and it has earlier versions of `WebUSB`.  However, it does not have the version of `WebUSB` that works with the Circuit Playground's newer bootloader.

## Debugging

If you suspect the scripts and services aren't running, here are a few tips to debug what is going on.

### Check the status of the Path and Service Unit files:

Check the file monitor unit:

```
$ systemctl --user status circuitplayground-monitor.path
● circuitplayground-monitor.path - "User circuitplayground-monitor.path to monitor /home/pi/Downloads/circuitplayground-*.uf2"
   Loaded: loaded (/home/pi/.config/systemd/user/circuitplayground-monitor.path; enabled; vendor preset: enabled)
   Active: active (waiting) since Sun 2018-09-02 12:44:36 EDT; 1min 15s ago
     Docs: https://github.com/eduncan911/circuitplayground-monitor-systemd

Sep 02 12:44:36 circuit systemd[540]: Started "User circuitplayground-monitor.path to monitor /home/pi/Downloads/circuitplayground-*.uf2".
```

In the above output, make sure it says `Loaded: loaded` and `Active: active (waiting)`.

If the file monitor matches the above, then check the service to see if it is running the script by viewing its logs:

```
$ systemctl --user status circuitplayground-monitor.service
● circuitplayground-monitor.service - "User circuitplayground-monitor.service that executes /home/pi/Downloads/circuitplayground-monitor-systemd/move-uf2.sh"
   Loaded: loaded (/home/pi/.config/systemd/user/circuitplayground-monitor.service; disabled; vendor preset: enabled)
   Active: inactive (dead) since Sun 2018-09-02 12:44:59 EDT; 8s ago
     Docs: https://github.com/eduncan911/circuitplayground-monitor-systemd
  Process: 10912 ExecStart=/home/pi/Downloads/circuitplayground-monitor-systemd/move-uf2.sh (code=exited, status=0/SUCCESS)
 Main PID: 10912 (code=exited, status=0/SUCCESS)

Sep 02 12:44:59 circuit systemd[540]: Started "User circuitplayground-monitor.service that executes /home/pi/Downloads/circuitplayground-monitor-systemd/move-uf2.sh".
Sep 02 12:44:59 circuit move-uf2.sh[10912]: Found file 'circuitplayground-dice.uf2' to move.
Sep 02 12:44:59 circuit move-uf2.sh[10912]: Found Circuit Playground mounted at '/media/pi/CPLAYBOOT'
Sep 02 12:44:59 circuit move-uf2.sh[10912]: Moving 'circuitplayground-dice.uf2' to '/media/pi/CPLAYBOOT/'
```

Note that in this output, `Active: inactive (dead)` is normal and expected.  The file path monitor runs this service whenever the file is detected; it does not run all the time (nor would we want it to!).

The most important parts to look for is the exit codes of the last run.  You can see that above on the line that starts with `Main PID`.  Focus on the part that says `status=0/SUCCESS`.  If it says anything else but `0/SUCCESS`, then there was a problem.

You can see the log of the output below the `Main PID` entry.  In the example above, we have 4 log entries showing it found the file, where Circuit was mounted at, and that it moved the file.

## Uninstall

NOTE: If you are just trying to re-install, you don't have to remove.  You can just run `./install.sh` again and it will override all existing unit files and re-enable them.

If you want to remove it, follow the steps below to disable and/or remove.

```
systemctl --user stop circuitplayground-monitor.path
systemctl --user disable circuitplayground-monitor.path
rm ~/.config/systemd/user/circuitplayground-monitor.*
```

Then you are free to remove the directory of where you downloaded.
