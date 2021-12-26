############################
# VARS
############################

setname=$1
url=$2
filepath="/etc/nftables/$setname.nft"
result=$(curl --fail "$url" 2>/dev/null | tr -s "[:space:]" " ")
status=$?

#############################
# ENTRYPOINT
#############################

if [ ! -d /etc/nftables ]; then
	mkdir /etc/nftables
fi

if [ $status -eq 0 ]; then
	rm -f "$filepath"
	echo "define $setname = {" > "$filepath"

	for ip in $result; do
		echo "	$ip," >> "$filepath"
	done

	echo "}" >> "$filepath"
	echo "Created file $filepath. You can now set elements = \$$setname in your set configuration."
else
	echo "Download failed, set wasn't modified."
fi
