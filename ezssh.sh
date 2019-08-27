#!/bin/bash
SRC=${0%/*}
host=$1
user=$2
ip=$3
port=$4

usage(){
  echo "Usage: ezssh <config alias> <ssh user> <ip> <port>"
}

if [[ -z $ip ]]
then
  usage
  exit
fi
if [[ -z $port ]]
then
  port='22'
fi

default_key_name='ezssh_rsa'
read -p "Chose a name for the generated keyfile (default to '$default_key_name'):" key_name
if [[ -z $key_name ]]
then
  key_name=$( echo "$default_key_name" )
fi

default_key_file_dir="$HOME/.ssh/ezssh"
read -p "Chose where to save the keyfile (default to '$default_key_file_dir'):" key_file_dir
if [[ -z $key_file_dir ]]
then
  key_file_dir=$( echo "$default_key_file_dir" )
fi

key_file="$key_file_dir/$key_name"
if [[ -f $key_file ]]
then
  echo "Key already exists"
else
  mkdir -p "$key_file_dir"
  echo "" > "$key_name"
  user_host=$(uname -n)
  yes | ssh-keygen -t rsa -b 2048 -N "" -C "$USER@$user_host($key_name)" -f "$key_name" > /dev/null
  mv "$key_name" "$key_file"
  mv "$key_name.pub" "$key_file.pub"
  chmod 700 "$key_file"
  echo "Created private key $key_file"
  echo "Created public key $key_file.pub"
fi

key=$(cat "$key_file")
pub_key=$(cat "$key_file.pub")

printf "Here is your public key : \n$pub_key\n"

default_config_file="$HOME/.ssh/config"
read -p "Chose where to save the config (default to '$default_config_file'):" config_file
if [[ -z $config_file ]]
then
  config_file=$( echo "$default_config_file" )
fi
echo "Host $host" >> $config_file
echo "    HostName $ip" >> $config_file
echo "    User $user" >> $config_file
echo '    IdentityFile "'$key_file'"' >> $config_file
echo "    Port $port" >> $config_file


### WRITE PUB TO SERVER AND RESTART
# default_known_hosts_file="~/.ssh/known_hosts"
# read -p "Chose the destination known_hosts or authorized_keys file (default to '$default_known_hosts_file'):" known_hosts_file
# if [[ -z $known_hosts_file ]]
# then
#   known_hosts_file="$default_known_hosts_file"
# fi
#
# if [[ -z $port ]]
# then
#   ssh root@$ip -v 'if [[ -z $(cat '$known_hosts_file' | grep "'$key_name'") ]]; then echo "'$pub_key'" >> '$known_hosts_file'; cat '$known_hosts_file'; service ssh restart; fi; exit;'
# else
#   ssh root@$ip -v -p $port 'if [[ -z $(cat '$known_hosts_file' | grep "'$key_name'") ]]; then echo "'$pub_key'" >> '$known_hosts_file'; cat '$known_hosts_file'; service ssh restart; fi; exit;'
# fi
# exit
