| ![alt text][logo] | Integration & Securite Systeme |
| ------------- |:-------------:|

# Cybionet - Ugly Codes Division

## REQUIRED

The `sc_iptables` package installs rules to secure IPv4 and block IPv6 communications. Add-ons must be installed separately using their respective installation file.


<br>

## INSTALLATION

1. Download files from this repository directly with git or via https.
   ```bash
   git clone https://github.com/cybiohub/sc_iptables.git
   ```

2. Deploy the executable of the `install.sh` script.
   ```bash
   chmod 500 ./sc_iptables/install.sh
   ./sc_iptables/install.sh
   ```

3. Configure the IPv4 rules configuration file.
   ```bash
   vim /etc/iptables/40-iptables.conf
   ```

> [!NOTE]
> Don't forget to set the 'isConfigured' parameter to 'true', otherwise the script will not be apply. This is for security purposes for your environment.

4. Reboot to apply, or manually run the script to perform the check first.
   ```bash
   /usr/share/netfilter-persistent/plugins.d/40-iptables
   ```

5. Voilà! Enjoy!

---
[logo]: ./md/logo.png "Cybionet"
