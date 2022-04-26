#!/bin/bash
temp=$(/usr/local/bin/lighthouse --version | grep Lighthouse)
current_version=${temp:11:6}
remote_version=$(curl -s https://api.github.com/repos/sigp/lighthouse/releases/latest | jq -r '. | .tag_name')
echo $current_version
echo $remote_version
if [ "$current_version" = "$remote_version" ]; then
        echo "EXIT"
        exit
else
        sudo systemctl stop lighthousebeacon
        sudo systemctl stop lighthousevalidator
        echo updating to $remote_version
        curl -s https://api.github.com/repos/sigp/lighthouse/releases/latest | grep -E 'browser_download_url' | grep x86_64-unknown-linux-gnu.tar | grep -v .asc | cut -d '"' -f 4 | xargs wget -qO - | tar -xz
        sleep 60
        sudo mv lighthouse /usr/local/bin
        sudo systemctl start lighthousebeacon
        sudo systemctl start lighthousevalidator
        echo update complete
fi
