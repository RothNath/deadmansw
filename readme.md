**DeadMan's Switch (deadmansw) User Manual**

**Introduction******
DeadMan's Switch (deadmansw) is a Linux-based tool designed to secure sensitive data by automatically shredding specified directories after a defined period of inactivity by the user. This tool starts as a service on boot, monitoring user activity based on login events.

**Features******

Monitor specified user's login inactivity.
Configurable folders to be shredded.
Configurable inactivity duration leading to data shredding.
On/off toggle for safety.
Helper utility for easy status checks
**
Dependencies******

ntpdate: Used to query NTP servers to check the time offset.
hwclock: Used to access the hardware clock (Real-Time Clock, RTC) and compare it with the system clock.
awk: A text processing tool that's used in the script for parsing outputs of various commands.
grep: A text searching utility.
date: Used to convert and compute timestamps.
bc: An arbitrary precision calculator language, used in the script to evaluate a floating-point condition. May need to be installed separately on minimal installations.
cut: Used for cutting out sections from each line of files. Typically comes pre-installed with most distributions, as it's part of the coreutils package.
tr: Used to translate or delete characters. In this script, it's used to remove double quotes. Like cut, this is part of the coreutils package and typically comes pre-installed.
last: Provides the last login info for users. Comes pre-installed with most distributions, as it's part of the sysvinit-tools or util-linux package, depending on the distribution.
tee: Used to append to files (in this case, logs). Part of the coreutils package, it's typically pre-installed.
bash: The shell the script is written in.

**Automated Intallation (Todo)******

**Manual Installation (Most Linux Distributions)******

Copy the deadmansw script to /usr/local/bin/ and ensure it's executable:
sudo cp deadmansw /usr/local/bin/
sudo chmod +x /usr/local/bin/deadmansw
The accompanying systemd service file should be placed in /etc/systemd/system/.

**Script File******

Copy the deadmansw script to /usr/local/bin/ and ensure it's executable:
sudo cp deadmansw.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/deadmansw.sh

**Helper Script******

For the helper utility, do the same:

sudo cp deadmansw-helper /usr/local/bin/
sudo chmod +x /usr/local/bin/deadmansw-helper

**Configuration File******

Place the configuration file in its directory:

sudo mkdir /etc/deadmansw
sudo cp deadmansw.conf /etc/deadmansw/

**Service File******

The accompanying systemd service file should be placed in /etc/systemd/system/.

sudo cp deadmansw.service /etc/systemd/system/

**Configuration:******

The main configuration file for deadmansw is deadmansw.conf normally located at /etc/deadmansw/deadmansw.conf

**Parameters:******

ENABLED: This can be set to "yes" or "no". It determines whether the tool is active. By default, for safety reasons, this is set to "no".
MONITORED_USER: Specify the username whose inactivity will be monitored.
TIME_MINUTES: Inactivity duration in minutes.
TIME_HOURS: Inactivity duration in hours.
TIME_DAYS: Inactivity duration in days.
TIME_WEEKS: Inactivity duration in weeks.
TIME_MONTHS: Inactivity duration in months.
TARGET_X: Paths to the files or directories you want to be shredded when the switch activates. Add multiple target lines for multiple paths (e.g., TARGET_1, TARGET_2, etc.)

**Usage:******

Starting the service
systemctl start deadmansw

**Other commands******

deadmansw-helper  # Check the time remaining on shredding after the service is started

**Safety Notes******

Always Backup: Before setting this tool on any directory, always ensure you have backups of essential data. The shred command is irreversible./
Testing: It's crucial to test the tool in a safe environment (e.g., on dummy data) before deploying it on actual sensitive directories.
Service Start: Ensure that the systemd service is started after any configurations or changes: sudo systemctl start deadmansw.

**Conclusion******

Deadmansw is a powerful tool designed with data security in mind. While it provides a layer of safety against unauthorized data access, always handle with care to avoid unintentional data loss.

**FAQ: ******

Q: Do you know that shred doesn't completely delete data on an SSD?
A: Yes, release version I hope will have the ability to use enhanced erase hdparm's. 

Q: What happens if I sit logged in forever and don't have a lock screen or trigger a logout?
A: Data will never be removed.

Q: What happens if someone pulls the power on my computer and takes the HD?
A: It won't complete the deletion / shred. It'll try if it's powered on in a VM for example, as long as the time hasn't been messed with.

**Author******

Contact: nath.jroth@protonmail.com









