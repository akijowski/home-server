# Notes

## From Fileserver

### Groups

```csv
id,group
1000,adam
1001,windows
1200,sambaetc
1400,arm
1800,plex
```

### Users

```csv
id,user,group,groups
1000,adam,adam,arm,plex,sambaetc,users
1001,windows,windows,arm,plex,users
1200,sambaetc,sambaetc,
1400,arm,arm,
1800,plex,plex,
```

### Samba Users

```csv
id,user
1000,adam
1001,windows
```

### Samba Groups

```csv
windows,local group
```

### SMB Conf

> /etc/samba/smb.conf

```toml
[global]
	# vfs objects = recycle fruit streams_xattr
    vfs objects = fruit streams_xattr
	# recycle:touch = yes
	panic action = /usr/share/samba/panic-action %d
	# recycle:versions = yes
	delete user script = /usr/sbin/userdel -r '%u'
	log file = /var/log/samba/samba.log
	wins support = yes
	server string = TurnKey FileServer
	# recycle:exclude_dir = tmp quarantine
	passwd program = /usr/bin/passwd %u
	# recycle:keeptree = yes
	passdb backend = tdbsam
	os level = 20
	workgroup = WORKGROUP
	pam password change = yes
	delete group script = /usr/sbin/groupdel '%g'
	netbios name = FILESERVER
	max log size = 1000
	encrypt passwords = true
	restrict anonymous = 2
	socket options = SO_KEEPALIVE TCP_NODELAY IPTOS_LOWDELAY
	guest account = nobody
	unix password sync = yes
	dns proxy = no
	obey pam restrictions = yes
	syslog = 0
	passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
	add user to group script = /usr/sbin/usermod -G '%g' '%u'
	add user script = /usr/sbin/useradd -m '%u' -g users -G users
	admin users = root
	security = user
	add group script = /usr/sbin/groupadd '%g'

# Apple config
# https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X
   fruit:metadata = stream
   fruit:veto_appledouble = yes
   fruit:posix_rename = yes
   fruit:zero_file_id = yes
   fruit:wipe_intentially_left_blank_rfork = yes
   fruit:delete_empty_adfiles = yes
   fruit:model = iMacPro1,1
   fruit:advertise_fullsync = true
   fruit:aapl = yes

# Prevent junk Apple files
   veto files = /._*/.DS_Store/.Trashes/.TemporaryItems
   delete veto files = yes

# Performance Tweaks (most of these are default)
# https://www.oreilly.com/openbook/samba/book/appb.pdf
# https://www.reddit.com/r/truenas/comments/lrbjz8/truenas120u2_slow_smb_transfer_rates/
# https://top-frog.com/2020/07/03/osx-samba-with-linux-server/
   server signing = no
   ea support = yes
   read raw = yes
   write raw = yes
   strict locking = no
   oplocks = yes
   deadtime = 15
   getwd cache = yes
   max xmit = 65535
   use sendfile = true
   aio read size = 16384
   aio write size = 16384


[homes]
    comment = Home Directory
    browseable = no
    read only = no
    valid users = %S

[cdrom]
    comment = CD-ROM
    read only = yes
    locking = no
    guest ok = yes
    path = /media/cdrom
    preexec = /bin/mount /media/cdrom
    postexec = /bin/umount /media/cdrom

[storage]
    comment = Public Share
    path = /srv/storage
    browseable = yes
    read only = no
    create mask = 0644
    directory mask = 0755

[etc]
	force user = sambaetc
	force group = sambaetc
	path = /opt/share/etc
	copy = storage
	comment = samba etc folder shares

[plex-movies]
	force group = plex
	comment = plex movies
	force user = plex
	path = /opt/share/plex/movies
	copy = storage

[plex-uhd-movies]
	comment = plex uhd movies
	force group = plex
	path = /opt/share/plex/uhd-movies
	copy = storage
	force user = plex

[plex-tv-shows]
	copy = storage
	path = /opt/share/plex/tv-shows
	comment = plex tv shows
    force user = plex
    force group = plex


[arm-media]
	copy = storage
	force group = arm
	force user = arm
	path = /opt/share/arm/media
	comment = arm media


[backup]
	comment = Samba Backups
	copy = storage
	path = /opt/share/backup
	force user = sambaetc
	force group = sambaetc
```

## Interesting

https://gist.github.com/pythoninthegrass/2f280c76d5fc9bef5621e1a222823484
http://infotinks.com/testing-samba-smb-cifs-connections-with-linux/
