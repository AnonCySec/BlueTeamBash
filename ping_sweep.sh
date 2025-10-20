#!/bin/bash

# Ping every host on a subnet to see which ones are active
echo "Enter the first three octets of the subnet (e.g., 192.138.1): "
read subnet

for i in $(seq 1 254); do
  ping -c 1 "$subnet.$ip" | grep "64 bytes" | cut -d " " -f 4 | sed 's/.$//' & 
done
