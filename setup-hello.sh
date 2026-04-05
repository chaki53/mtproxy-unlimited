#!/bin/bash
# Extract hello-explorers file from official image
echo "Extracting hello-explorers from official Telegram MTProxy image..."
docker pull telegrammessenger/proxy:latest
docker create --name tmp_mtproxy_extract telegrammessenger/proxy:latest
docker cp tmp_mtproxy_extract:/etc/telegram/hello-explorers-how-are-you-doing ./hello-explorers
docker rm tmp_mtproxy_extract
echo "Done! File saved as ./hello-explorers"
