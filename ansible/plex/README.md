# Plex LXC

## Configuration

### Allowing root password login

The initial run of the playbook requires running under `root` within the container.  By default `root` is unable to login via `ssh`.  Therefore it is necessary to manually edit the `/etc/ssh/sshd_config` file first.

1. Make a copy of the config, just in case:
```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```
2. Edit the config:
```bash
vi /etc/ssh/sshd_config
```
3. Allow root login by setting the line under Authentication to: `PermitRootLogin yes`
4. **Don't forget** to set this to `prohibit-password`, or disable it (comment it out) after creating another user!

You can verify access with:
```bash
ansible -i hosts plex -m ping -u root -k
```

## Running initial configuration

The playbook can be run with the following command:

```bash
ansible-playbook plex/01_initialize.yml -i hosts -l plex -u root -k -K 
```

This will run under the `root` user.  After the non-root user is created, make sure to change the user parameter as needed.

## Running installation and later configuration

After intialization, later playbooks can be run with the following:

```bash
ansible-playbook plex/02_install.yml -i hosts -l plex -u <user> -K 
```

## Plex Directory configuration

One of the tricky aspects with the container is that the directories Plex needs access to (the media itself, and a 'metadata' folder) must be owned by at least the `plex` group and have `rwx` permissions.  These directories are the ones that you will want to be mounted in to the container so that they can be replaced, backed-up, etc. independently.  You can simply used [bind mount points](https://pve.proxmox.com/wiki/Linux_Container#_bind_mount_points) to attach the directories from the host.

Running the container as unprivileged presents an issue as the container's uid/gid are not mapped 1:1 from the host.  This means that the uid/gid of `plex` needs to be "pinned" so that this relationship can occur.

Looking through the Proxmox [forums](https://forum.proxmox.com/threads/mounting-existing-zfs-datasets.37106/) and [wiki](https://pve.proxmox.com/wiki/Unprivileged_LXC_containers), supposedly the "correct" solution involves editing the container `conf` file as well as the `/etc/subuid` and `/etc/subgid` files.  I attempted this, but I think something got borked in my container `conf` file.  I suddently lost the ability to [ssh in to the container](https://unix.stackexchange.com/questions/201848/cant-connect-to-the-sshd-in-my-unprivileged-lxc-guest-what-to-do).  

I did have the `/etc/subuid` and `/etc/subgid` edits made as recommended, but I rebuilt the container and instead simply `chown`ed the datasets on the Proxmox host to match the Plex uid/gid.  After I did that, when I viewed the directories within the container they were showing as `plex:plex`.  Starting the Plex media server and everything worked as expected.

**Here are the steps I followed**

~~I have two ZFS datasets in my pool: `$POOL/plex` contains my Plex data, with regular directories underneath for movies and music.  `$POOL/plex-metadata` is where Plex's metadata library is stored.  This is where Plex stores preferences, assets, all sorts of stuff.~~

I have two ZFS datasets in my pool: `$POOL/plex/media` for movies and music and `$POOL/plex/metadata` for Plex's metadata library.

In the Proxmox host I used `sudo pct set <container id> -mp0 $POOL/plex/media,mp=/opt/plex/media` and `sudo pct set <container id> -mp1 $POOL/plex/metadata,mp=/opt/plex/metadata`.  Still on the host, I ran `sudo chown -R 998:998 $POOL/plex/media` and `sudo chown -R 998:998 $POOL/plex/metadata` to set the directory ownership ids to match the Plex ids.  I then restarted the container.

Finally, the last piece was to override Plex's default location for metadata: `/var/lib/plexmediaserver`.  I found this [excellent post](https://forums.plex.tv/t/moving-pms-library/197342) on the Plex forums describing how to add an override file to `systemd`.  The Ansible playbook `03_configure_storage.yml` follows these steps.

After mounting the directories, setting the correct ownership ids, and running the Ansible playbook, I opened the Plex web app and verified all of my settings where correct.  I did end up having to edit the location for my Movies, TV Shows, etc within Plex but the UI makes that very easy.
