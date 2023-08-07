#!/usr/bin/env bash

# change directory
cd /config/dynamic_blacklists

#Backup previous list
rm -f BLACKLIST_OLD.txt
mv BLACKLIST.txt BLACKLIST_OLD.txt
touch BLACKLIST.txt

#Download the file from PGL.YOYO
curl -O https://pgl.yoyo.org/adservers/iplist.php
#Download the file from emerging threats
curl -O http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt
#Download the first file from SpamHaus
curl -O http://www.spamhaus.org/drop/drop.txt
#Download the second file from SpamHaus
curl -O http://www.spamhaus.org/drop/edrop.txt
#Download the file from okean Korea
curl -O http://www.okean.com/sinokoreacidr.txt
#Download the file from okean China
curl -O http://www.okean.com/chinacidr.txt
#Download file from myip
curl -O http://www.myip.ms/files/blacklist/general/latest_blacklist.txt
#Download file from Blocklist.de
curl -O http://lists.blocklist.de/lists/all.txt
#Download bogon blacklist from cymru.org
curl -O http://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt
#Download blacklist from Cisco/Talos
curl -L https://www.talosintelligence.com/documents/ip-blacklist >> ip-blacklist.txt

#Combine lists into one file
cat all.txt \
    drop.txt \
    edrop.txt \
    iplist.php \
    sinokoreacidr.txt \
    chinacidr.txt \
    latest_blacklist.txt \
    fullbogons-ipv4.txt \
    ip-blacklist.txt \
    LocalBlacklist.txt \
    emerging-Block-IPs.txt > PreliminaryOutput.txt

#Strip out everything except for the IPV4 addresses
sed -e '/^#/ d' \
    -e '/[:]/ d' \
    -e 's/ .*// g' \
    -e 's/[^0-9,.,/]*// g' \
    -e '/^$/ d' < PreliminaryOutput.txt > PreUniqueOutput.txt

#Count the number of ip's
sed -n '$=' PreUniqueOutput.txt

#Remove any duplicates
sort PreUniqueOutput.txt | uniq -u > PreBlacklist.txt

#Remove any whitelisted ip's from LocalWhitelist.txt
sort PreBlacklist.txt > PreBL.sort
sort LocalWhitelist.txt > LocalWL.sort
comm -23 PreBL.sort LocalWL.sort > BLACKLIST.txt

#Remove any preliminary files
rm Pre*

#Do a final count
sed -n '$=' BLACKLIST.txt

####trying to incorporate old list
getnetblocks() {
cat <<EOF

# Generated by ipset, create hash set of network ranges
-N geotmp nethash --hashsize 1024 --probes 4 --resize 20
EOF

# pre-write command suffixes for adding network ranges
cat /config/dynamic_blacklists/BLACKLIST.txt|egrep '^[0-9]'|egrep '/' |sed -e "s/^/-A geotmp /"
}

getnetblocks > /config/dynamic_blacklists/netblock.txt
# https://ipset.netfilter.org/tips.html
# -! ignore errors
# -R attempt resolving IPs?
# create new set and add network ranges
sudo ipset -! -R < /config/dynamic_blacklists/netblock.txt
# swap newly created set "geotmp" with standard set "ET-N"
sudo ipset -W geotmp ET-N
# delete old set (which is now geotmp after swap)
sudo ipset -X geotmp

getaddblocks() {
cat <<EOF

# Generated by ipset
-N geotmp nethash --hashsize 1024 --probes 4 --resize 20
EOF

cat /config/dynamic_blacklists/BLACKLIST.txt|egrep '^[0-9]'|egrep -v '/' |sed -e "s/^/-A geotmp /"
}

getaddblocks > /config/dynamic_blacklists/addblock.txt
# -! ignore errors
# -R attempt resolving IPs?
# create new set and add IP addresses
sudo ipset -! -R < /config/dynamic_blacklists/addblock.txt
# swap newly created set "geotmp" with standard set "ET-A"
sudo ipset -W geotmp ET-A
# delete temporary old set
sudo ipset -X geotmp

# clean up bulk command suffixes
rm /config/dynamic_blacklists/addblock.txt
rm /config/dynamic_blacklists/netblock.txt

# Remove faulty network(s)
sudo ipset del ET-N 0.0.0.0/1 -exist