#!/bin/sh
# written mostly by HarryJarry1
# get_stateful take from https://github.com/applefritter-inc/BadApple-icarus
main(){
echo   
get_internal
mkdir /localroot
mount "$intdis$intdis_prefix"3 /localroot -o ro
mount --bindable /dev /localroot/dev
chroot /localroot cgpt add "$intdis" -i 2 -P 10 -T 5 -S 1
    (
        echo "d"
        echo "4"
        echo "d"
        echo "5"

        echo "w"
    ) | chroot /localroot fdisk "$intdis" 2>/dev/null
umount /localroot/dev
umount /localroot
rmdir /localroot
crossystem disable_dev_request=1

}
fail(){
	printf "$1\n"
	printf "exiting...\n"
	exit
}
get_internal() {
	# get_largest_cros_blockdev does not work in BadApple.
	local ROOTDEV_LIST=$(cgpt find -t rootfs) # thanks stella
	if [ -z "$ROOTDEV_LIST" ]; then
		fail "could not parse for rootdev devices. this should not have happened."
	fi
	local device_type=$(echo "$ROOTDEV_LIST" | grep -oE 'mmc|nvme|sda' | head -n 1)
	case $device_type in
	"mmc")
		intdis=/dev/mmcblk0
  		intdis_prefix="p"
		break
		;;
	"nvme")
		intdis=/dev/nvme0
  		intdis_prefix="n"
		break
		;;
	"sda")
		intdis=/dev/sda
  		intdis_prefix=""
		break
		;;
	*)
		fail "an unknown error occured. this should not have happened."
		;;
	esac
}
read -p "NOTE if you have not freshly recovered, THIS WILL BRICK UR CHROMEBOOK UNTIL NEXT RECOVERY!  Proceed?(y/n) " -n 1 -r
echo   
if [[ $REPLY =~ ^[Yy]$ ]]; then
    main
fi
