# Dynamic Blacklist for EdgeRouter OS

Problem: Various malicious cyber actors continuously scan the internet for vulnerabilities.
A lot of their IPs are known and published by open-source repositories.
However, many organizations do not utilize these bad IP lists (or at least don't update them frequently enough to be effective).

Solution: Implement a cron job to update and apply firewall blacklists based on these known bad IP lists.

Purpose of scripts:
- `update_blacklist.sh` This script downloads new bad IP lists and registers them into ET-A and ET-N sets that are configured through the GUI as firewall rule sets
- `dynamic_blacklists_setup.sh` This script downloads the other script sets up a cron job.
