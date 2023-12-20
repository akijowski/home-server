$ORIGIN home.kijowski.io.
$TTL    86400
@    IN    SOA    ns1.home.kijowski.io. hostmaster.kijowski.io. (
      1          ; serial, update on changes
			21600      ; refresh after 6 hours
			3600       ; retry after 1 hour
			604800     ; expire after 1 week
			86400 )    ; minimum TTL of 1 day
;

; name servers - NS records
@    IN    NS    ns1

; name servers - A records
ns1.home.kijowski.io.    IN    A    192.168.50.2

; servers
adguard IN  A 192.168.50.2
proxmox IN  A 192.168.50.3
truenas IN  A 192.168.50.4


*.k8s IN  A 192.168.50.7



plex  IN  A 192.168.50.11
samba IN  A 192.168.50.12
arm IN  A 192.168.50.13

homebridge  IN  A 192.168.50.15
