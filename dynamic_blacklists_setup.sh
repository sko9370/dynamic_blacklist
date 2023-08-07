#!/usr/bin/env bash

mkdir /config/dynamic_blacklists
touch /config/dynamic_blacklists/LocalWhitelist.txt /config/dynamic_blacklists/LocalBlacklist.txt

#cronjob="0 * * * * bash update_blacklist.sh"
cronjob="* * * * * bash /config/dynamic_blacklists/update_blacklist.sh"

# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
( crontab -l | grep -v -F "blacklist"; echo "$cronjob" ) | crontab -
