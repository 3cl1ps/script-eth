#!/bin/bash

version=$(curl -s https://api.github.com/repos/ethereum/go-ethereum/releases/latest | jq .tag_name)
version="${version//'"'}"
commit=$(curl -s https://api.github.com/repos/ethereum/go-ethereum/commits/$version  | jq .sha)
commit=${commit:1:8}
version=${version:1}

cd ~/download
rm -rf geth* beacon* validator*
wget -q https://gethstore.blob.core.windows.net/builds/geth-linux-arm64-$version-$commit.tar.gz
curl -s https://api.github.com/repos/prysmaticlabs/prysm/releases/latest | jq -r ".assets[] | select(.name | contains(\"beacon-chain\")) | select(.name | contains(\"arm\")) | .browser_download_url" | wget -qi -
curl -s https://api.github.com/repos/prysmaticlabs/prysm/releases/latest | jq -r ".assets[] | select(.name | contains(\"validator\")) | select(.name | contains(\"arm\")) | .browser_download_url" | wget -qi -
rm *.sig
rm *.sha256
tar -zxvf geth* geth-linux-arm64-$version-$commit/geth --strip-components 1
