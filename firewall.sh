#!/bin/bash
#

# Drop ICMP echo-request messages sent to broadcast or multicast addresses
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Drop source routed packets
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
 
# Enable TCP SYN cookie protection from SYN floods
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
 
# Don't accept ICMP redirect messages
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
 
# Don't send ICMP redirect messages
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
 
# Enable source address spoofing protection
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
 
# Log packets with impossible source addresses
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
 
# Flush all chains
/sbin/iptables --flush
 
# Allow unlimited traffic on the loopback interface
/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A OUTPUT -o lo -j ACCEPT
 
# Set default policies
/sbin/iptables --policy INPUT DROP
/sbin/iptables --policy OUTPUT DROP
/sbin/iptables --policy FORWARD DROP
 
# Previously initiated and accepted exchanges bypass rule checking
# Allow unlimited outbound traffic
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
 
#Ratelimit SSH for attack protection
/sbin/iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
/sbin/iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
/sbin/iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
 
# Deny server pinging
/sbin/iptables -A INPUT -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j DROP

  
# Drop all other traffic
/sbin/iptables -A INPUT -j DROP

#spoofing protection
iptables -N spoofing
iptables -I spoofing -j DROP

#block unusual TCP flags

iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP

#Drop ICMP packets to prevent ICMP flood and ICMP fragmentation flood attacks
iptables -t mangle -A PREROUTING -p icmp -j DROP

# print the activated rules to the console when script is completed
/sbin/iptables -nL
