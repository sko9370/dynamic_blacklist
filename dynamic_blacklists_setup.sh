#!/usr/bin/env bash

mkdir /config/dynamic_blacklists
touch /config/dynamic_blacklists/LocalWhitelist.txt /config/dynamic_blacklists/LocalBlacklist.txt
rm /config/dynamic_blacklists/update_blacklist.sh
curl https://raw.githubusercontent.com/sko9370/dynamic_blacklist/main/update_blacklist.sh > /config/dynamic_blacklists/update_blacklist.sh

cronjob="0 * * * * /bin/bash /config/dynamic_blacklists/update_blacklist.sh"

# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
( crontab -l | grep -v -F "blacklist"; echo "$cronjob" ) | crontab -
