sudo systemctl disable wpa_supplicant
sudo systemctl disable bluetooth
sudo systemctl disable hciuart
#vi /boot/config.txt 
#dtoverlay=pi3-disable-wifi
#dtoverlay=pi3-disable-bt
