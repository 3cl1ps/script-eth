#!/bin/bash
sudo systemctl stop geth
sudo systemctl stop prysmbeacon
sudo systemctl stop prysmvalidator
sleep 3
cp ~/download/geth ~/current/geth
cp ~/download/validator* ~/current/validator
cp ~/download/beacon* ~/current/beacon-chain
cd ~/current
chmod +x beacon-chain validator geth
sudo systemctl start geth
sudo systemctl start prysmbeacon
sudo systemctl start prysmvalidator
