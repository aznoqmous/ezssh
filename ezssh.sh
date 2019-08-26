#!/bin/bash
SRC=${0%/*}
ip=$1
port=$2
key_name="ezssh_rsa3"
key_file="/home/$USER/.ssh/$key_name"

mkdir -p "/home/$USER/.ssh"
# touch $key_file
echo "" > "$key_name"
yes | ssh-keygen -t rsa -b 2048 -N "" -C "$key_name@ezssh" -f "$key_name" > /dev/null
mv "$key_name" "$key_file"
mv "$key_name.pub" "$key_file.pub"
chmod 700 "$key_file"
key=$(cat $key_file)
pub_key=$(cat $key_file.pub)
known_hosts_file="~/.ssh/known_hosts"
if [[ -z $port ]]
then
  ssh root@$ip -v 'echo "'$pub_key'" >> /root/nopassword_rsa'
else
  ssh root@$ip -v -p $port 'if [[ -z $(cat '$known_hosts_file' | grep "'$key_name'") ]]; then echo "'$pub_key'" >> '$known_hosts_file'; cat '$known_hosts_file'; service ssh restart; fi; exit;'
fi
exit
