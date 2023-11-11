| ![alt text][logo] | Integration & Securite Systeme |
| ------------- |:-------------:|

# Cybionet - Ugly Codes Division

## REQUIRED

The `sc_iptables` package installs rules to secure IPv4 and block IPv6 communications. Add-ons must be installed separately using their respective installation file.


<br>

## INSTALLATION

1. Download files from this repository directly with git or via https.
   ```bash
   wget -O sc_iptables.zip https://github.com/cybiohub/sc_iptables/archive/refs/heads/main.zip
   ```

2. Unzip the zip file.
   ```bash
   unzip sc_iptables.zip
   ```

3. Deploy the executable of the `install.sh` script.
   ```bash
   chmod 500 install.sh
   ./sc_iptables/install.sh
   ```

4. Configure the IPv4 rules configuration file.
   ```bash
   vim /etc/iptables/40-iptables.conf
   ```

5. Reboot to apply, or manually run the script to perform the check first.
   ```bash
   /usr/share/netfilter-persistent/plugins.d/40-iptables
   ```

6. Voilà! Enjoy!

---
[logo]: ./md/logo.png "Cybionet"
