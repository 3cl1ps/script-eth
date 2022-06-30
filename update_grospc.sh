#!/bin/bash                                                                                                                             
#get current version                                                                                                                    
echo nethermind                                                                                                                         
remote_version=$(curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | jq .tag_name)                          
remote_version="${remote_version//'"'}"                                                                                                 
echo $remote_version                                                                                                                    
local_version=$(cat /data1/current_version)                                                                                             
echo $local_version                                                                                                                     
                                                                                                                                        
if [ "$remote_version" = "$local_version" ]; then                                                                                       
    echo "nethermind a jour"                                                                                                            
else                                                                                                                                    
    echo "updating"                                                                                                                     
    cd /data1/                                                                                                                          
    curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | jq -r ".assets[] | select(.name | contains(\"netherm
ind-linux-amd64\")) | .browser_download_url" | wget -qi -                                                                               
    sudo service nethermind stop                                                                                                        
    unzip -o -qq nethermind-linux-amd64* -d nethermind                                                                                  
    sudo service nethermind start                                                                                                       
    rm -f *.zip                                                                                                                         
    echo $remote_version > /data1/current_version                                                                                       
fi                                                                                                                                      
                                                                                                                                        
                                                                                                                                        
echo besu                                                                                                                               
remote_version=$(curl -s https://api.github.com/repos/hyperledger/besu/releases/latest | jq .tag_name)                                  
remote_version="${remote_version//'"'}"                                                                                                 
echo $remote_version                                                                                                                    
local_version=$(cat /data3/current_version)                                                                                             
echo $local_version                                                                                                                     
                                                                                                                                        
if [ "$remote_version" = "$local_version" ]; then                                                                                       
    echo "besu a jour"                                                                                                                  
else                                                                                                                                    
    echo "updating"                                                                                                                     
    cd /data3/                                                                                                                          
    input=$(curl -s https://api.github.com/repos/hyperledger/besu/releases/latest | jq -r '.body')                                      
                                                                                                                                        
    while IFS= read -r line                                                                                                             
    do                                                                                                                                  
        if grep -q "https" <<< "$line" && grep -q "zip" <<< "$line"; then                                                               
            echo $line | wget -qi -                                                                                                     
        fi                                                                                                                              
    done < <(printf '%s\n' "$input")                                                                                                    
    sudo service besu stop                                                                                                              
    #unzipping                                                                                                                          
    unzip -o -qq "besu*" -d /data3/temp/                                                                                                
    rm -rf /data3/besu/*                                                                                                                
    mv /data3/temp/besu*/* /data3/besu/                                                                                                 
    rm -rf /data3/temp/*                                                                                                                
    sudo service besu start                                                                                                             
    rm -f /data3/besu*.zip                                                                                                              
    echo $remote_version > /data3/current_version                                                                                       
fi      
echo erigon                                                                                                                             
echo "updating"                                                                                                                         
cd /data4/erigon                                                                                                                        
git pull --quiet                                                                                                                        
make erigon                                                                                                                             
sudo service erigon restart                                                                                                             
                                                                                                                                        
echo teku                                                                                                                               
remote_version=$(curl -s https://api.github.com/repos/ConsenSys/teku/releases/latest | jq .tag_name)                                    
remote_version="${remote_version//'"'}"                                                                                                 
echo $remote_version
local_version=$(cat /data3/current_version_teku)
echo $local_version

if [ "$remote_version" = "$local_version" ]; then
    echo "teku a jour"
else
    echo "updating"
    cd /data3/
    input=$(curl -s https://api.github.com/repos/ConsenSys/teku/releases/latest | jq -r '.body')

    while IFS= read -r line
    do
        if grep -q "https" <<< "$line" && grep -q "zip" <<< "$line"; then
            grep -oP '(?<=]\().*?(?=\))' <<< "$line" | wget -qi -
        fi
    done < <(printf '%s\n' "$input")
                                                                                         
    sudo service teku stop
    #unzipping
    unzip -o -qq "teku*" -d /data3/temp/
    rm -rf /data3/teku/*
    mv /data3/temp/teku*/* /data3/teku/
    rm -rf /data3/temp/*
    sudo service teku start
    rm -f /data3/teku*.zip
    echo $remote_version > /data3/current_version_teku
fi
echo nimbus
remote_version=$(curl -s https://api.github.com/repos/status-im/nimbus-eth2/releases/latest | jq .tag_name)
remote_version="${remote_version//'"'}"
echo $remote_version
local_version=$(cat /data2/current_version_nimbus)
echo $local_version

if [ "$remote_version" = "$local_version" ]; then
    echo "nimbus a jour"
else
    echo "updating"
    cd /data2/nimbus
    sudo service nimbus stop
    curl -s https://api.github.com/repos/status-im/nimbus-eth2/releases/latest | jq -r ".assets[] | select(.name | contains(\"Linux_amd\")) | .browser_download_url" | wget -qi -
    tar xvzf nimbus-eth2_Linux_amd64*.tar.gz  --strip-components=1 -C /data2/nimbus/nimbus-bin
    sudo service nimbus start
    rm -rf /data2/nimbus/nimbus-eth2_Linux_amd64_* 
    echo $remote_version > /data2/current_version_nimbus
fi
echo prysm
remote_version=$(curl -s https://api.github.com/repos/prysmaticlabs/prysm/releases/latest | jq .tag_name)
remote_version="${remote_version//'"'}"
echo $remote_version
local_version=$(cat /data4/current_version_prysm)
echo $local_version

if [ "$remote_version" = "$local_version" ]; then
    echo "prysm a jour"
else
    echo "updating"
    cd /data4/prysm
    curl -s https://api.github.com/repos/prysmaticlabs/prysm/releases/latest | jq -r ".assets[] | select(.name | contains(\"beacon\")) | select(.name | endswith(\"linux-amd64\")) | select(.name | contains(\"modern\") | not) | .browser_download_url" | wget -qi -
    sudo service prysm stop
    mv beacon-chain-* beacon-chain
    chmod +x beacon-chain 
    sudo service prysm start
    echo $remote_version > /data4/current_version_prysm
fi


echo done
