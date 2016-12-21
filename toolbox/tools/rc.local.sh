#!/bin/bash

# Link scripts to /usr/local/bin
echo "Linking scripts to /usr/local/bin ..."
for i in /opt/mindstorms/tools/*; do
	ln -s $i /usr/local/bin/
done


# copy laboratory documentation
echo "Copying documentation ..."
DOCUMENTATION_DIR=/home/mindstorms/Desktop/Versuchsunterlagen
[ ! -d ${DOCUMENTATION_DIR} ] && ( sudo -u mindstorms mkdir -p ${DOCUMENTATION_DIR} )
wget -q -O - http://www.ient.rwth-aachen.de/cms/uploads/rwthonly/lehre/mindstorms/Versuchsunterlagen_EV3.tar.gz | tar -xzf - -C ${DOCUMENTATION_DIR}
sudo chown -R mindstorms:mindstorms ${DOCUMENTATION_DIR}


# Try to find a mindstorms.fat file / mindstorms.dir directory
# in any local partition.
# If it exists, mount it to /home/mindstorms/work.
# Also try to find mindstorms.swp files to use as swap space.

mkdir -p /mnt/localfs /home/mindstorms/work
chmod 700 /mnt

shopt -s nullglob

# HACK: disable gnome's automount functionality for manual mounting
echo "Disabling gnome's automount functionality for manual mounting..."
su - mindstorms -c "dbus-launch --exit-with-session gsettings set org.gnome.desktop.media-handling automount 'false'"
su - mindstorms -c "dbus-launch --exit-with-session gsettings set org.gnome.desktop.media-handling automount-open 'false'"

# Unmount all auto-mounted devices
shopt -s globstar	# allow '**' path expansion
echo "Unmounting all auto-mounted devices ..."
for PART in /media/**/; do
	if [ ! "$PART" = "/media/cdrom" ]; then
		umount "$PART" 2>/dev/null
	fi
done
shopt -u globstar	# disallow '**' path expansion



# Mount all partitions read-only
echo "Mounting all available partitions read-only ..."
for PART in /dev/disk/by-id/*; do
	DEVICE="$( readlink -f "$PART" )"
	if ! grep -q "^$DEVICE " /etc/mtab; then
		MOUNTPOINT="/mnt/localfs/${PART##*/}"
		mkdir "$MOUNTPOINT" || continue
		# try reading first sector, mount produces a timeout on card reader devices for some reason
		( dd if="$DEVICE" of=/dev/null bs=512 count=1 && mount -o ro "$DEVICE" "$MOUNTPOINT" ) || rmdir "$MOUNTPOINT"
	fi
done

# Try to find mindstorms.dir directory (also on boot medium)
if ! mountpoint -q /home/mindstorms/work; then
	echo "Looking for mindstorms.dir directory (also on boot medium) ..."
	for DIR in /cdrom/mindstorms.dir /mnt/localfs/*/mindstorms.dir; do
		MOUNTPOINT="${DIR%/*}"
		[ -d "$DIR" ] || continue
		echo "Found mindstorms.dir at ${DIR}. Re-mounting as writable ..."
		if [ "$MOUNTPOINT" = "/cdrom" ]; then
			mount -o remount,rw /cdrom || continue
		elif umount "$MOUNTPOINT"; then
			PART="/dev/disk/by-id/${MOUNTPOINT##*/}"
			if [ "$( blkid -s TYPE -o value "$PART" )" = "ntfs" ]; then
				mount -t ntfs-3g -o rw,no_def_opts,umask=077 "$PART" "$MOUNTPOINT" || continue
			else
				mount -o rw "$PART" "$MOUNTPOINT" || continue
			fi
		fi
		bindfs --create-as-mounter -u mindstorms -g mindstorms "$DIR" /home/mindstorms/work && break
	done
fi

# If this failed, try to find a mindstorms.fat file
if ! mountpoint -q /home/mindstorms/work; then
	echo "Looking for mindstorms.fat file (also on boot medium) ..."
	for FAT in /cdrom/mindstorms.fat /mnt/localfs/*/mindstorms.fat; do
		MOUNTPOINT="${FAT%/*}"
		[ "$( blkid -s TYPE -o value "$FAT" )" = "vfat" ] || continue
		echo "Found mindstorms.fat at ${FAT}. Re-mounting as writable ..."
		if [ "$MOUNTPOINT" = "/cdrom" ]; then
			mount -o remount,rw /cdrom || continue
		elif umount "$MOUNTPOINT"; then
			PART="/dev/disk/by-id/${MOUNTPOINT##*/}"
			if [ "$( blkid -s TYPE -o value "$PART" )" = "ntfs" ]; then
				mount -t ntfs-3g -o rw,no_def_opts,umask=077 "$PART" "$MOUNTPOINT" || continue
			else
				mount -o rw "$PART" "$MOUNTPOINT" || continue
			fi
		fi
		mount -t vfat -o loop,rw,uid=999,gid=999,fmask=0133,dmask=0022 "$FAT" /home/mindstorms/work && break
	done
fi

# Try to find all mindstorms.swp files
echo "Looking for mindstorms.swp files ..."
for SWP in /mnt/localfs/*/mindstorms.swp; do
	MOUNTPOINT="${SWP%/*}"
	PART="/dev/disk/by-id/${MOUNTPOINT##*/}"
	echo "Mounting swap file at ${SWP} as writable ..."
	if umount "$MOUNTPOINT"; then
		if [ "$( blkid -s TYPE -o value "$PART" )" = "ntfs" ]; then
			mount -t ntfs-3g -o rw,no_def_opts,umask=077 "$PART" "$MOUNTPOINT" || continue
		else
			mount -o rw "$PART" "$MOUNTPOINT" || continue
		fi
	fi
	# just in case we mount the same disk twice under a different name,
	# make sure swap space is not yet being used
	swapoff "$SWP"
	mkswap "$SWP" || continue
	swapon "$SWP"
done

# Remove work directory if not mounted
if ! mountpoint -q /home/mindstorms/work; then
	echo "Removing work directory as no available mountpoint found."
	rm -rf /home/mindstorms/work
fi

# Try to find mindstorms.startup directory (also on boot medium) which should include hook.sh
echo "Looking for mindstorms.startup directory (also on boot medium) which should include hook.sh ..."
for DIR in /cdrom/mindstorms.startup /mnt/localfs/*/mindstorms.startup; do
  [ -d "$DIR" ] || continue
  echo "Found mindstorms.startup.dir at ${DIR}. Searching for hook.sh ..."
  if [ ! -f "$DIR/hook.sh" ]; then
    echo "File not found!" && continue
  fi
  # Execute hook as mindstorms user
  su - mindstorms $DIR/hook.sh && break
done



# Try to unmount all unused partitions
echo "Unmounting all unused partitions ..."
for PART in /mnt/localfs/*; do
	echo "Unmounting ${PART}."
	umount "$PART" 2>/dev/null
done

# HACK: re-enable gnome's automount functionality.
echo "Re-enabling gnome's automount functionality ..."
su - mindstorms -c "dbus-launch --exit-with-session gsettings set org.gnome.desktop.media-handling automount 'true'"
su - mindstorms -c "dbus-launch --exit-with-session gsettings set org.gnome.desktop.media-handling automount-open 'true'"

# Download or link lmutil
echo "Downloading lmutil for Matlab license checkout ..."
LMUTIL=/usr/local/bin/lmutil
LMUTIL_LOCAL=/opt/matlab/etc/glnxa64/lmutil
[ -f $LMUTIL_LOCAL -a ! -e $LMUTIL ] && ln -s $LMUTIL_LOCAL $LMUTIL
[ -e $LMUTIL ] || ( wget -q -O - http://www.ient.rwth-aachen.de/cms/uploads/rwthonly/lehre/mindstorms/lmutil.bz2 | bunzip2 >$LMUTIL )
[ -e $LMUTIL ] && chmod 755 $LMUTIL

# check out matlab licence
echo "Checking out Matlab license ..."
[ -e $LMUTIL ] && su - mindstorms /usr/local/bin/licencecheckout.sh

# backup .flexlmborrow to /home/mindstorms/work and add link to home directory
echo "Backing up .flexlmborrow to /home/mindstorms/work ..."
FLEXLM_OLD=/home/mindstorms/.flexlmborrow
FLEXLM_NEW=/home/mindstorms/work/.flexlmborrow
[ -d /home/mindstorms/work -a -f $FLEXLM_OLD -a ! -h $FLEXLM_OLD  ] && ( sudo -u mindstorms mv -f $FLEXLM_OLD $FLEXLM_NEW )
[ -f $FLEXLM_NEW -a ! -f $FLEXLM_OLD  ] && ( sudo -u mindstorms ln -s $FLEXLM_NEW $FLEXLM_OLD )

# add matlab desktop launcher
cp   /usr/share/applications/matlab.desktop /home/mindstorms/Desktop/
chmod +x /home/mindstorms/Desktop/matlab.desktop 
sudo chown mindstorms:mindstorms /home/mindstorms/Desktop/matlab.desktop 


