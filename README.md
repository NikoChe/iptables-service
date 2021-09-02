# iptables-service
Iptables for Debian GNU/Linux

**Installation and use**

Clone the repository

Go to your project folder

Add execute permissions to the install.sh file

Run the install.sh file

Note.
After starting the file, a service will be launched that will close all ports except the standard SSH port.
If your SSH port is different from the standard one, make changes to the systemd-iptables.sh file before running the script
