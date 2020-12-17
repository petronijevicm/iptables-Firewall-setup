
## Download the rules
```
cd /etc/ && git clone https://github.com/petronijevicm/iptables-Firewall-setup
````
## Make the Rules Permenant
### Debian
```
sudo apt install iptables-persistent
sudo /etc/init.d/netfilter-persistent save
```
### Arch
*Use iptable-save which is pre-installed*
```
sudo iptables-save > /etc/iptables/iptables.rules
```
### RHEL

```
chkconfig --list | grep iptables*
sudo chkconfig iptables on
sudo service iptables save
```
