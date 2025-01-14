This is a prebuilt image for the Radxa Zero 3w to stream OpenIPC video. 

v1.9.2 Release Notes:

* This image brings support for groundstation-side rendering of MSPOSD over the wfb-ng tunnel. To enable this functionality, go into `/config/scripts/osd` and change from `air` to `ground`. You must enable the MSPOSD forwarding on the camera for this to work.

***

On first boot, the stream will not start to give the user the ability to set up the system. Please perform the following steps.
 * Step 1 - Flash the image to either your onboard emmc or a micro SD card. Connect a screen and a wired keyboard to your radxa (you may need a usb-a to usb-c adapter or hub) and boot the system.
 
 * Step 2 - The system should boot to a CLI. Login as either `radxa/radxa` or `root/root` 
 
 * Step 3 - Use the onboard wi-fi to connect to your home network: (note - if you are running your fpv system on the 5.8ghz channels, it would be ideal to connect the onboard wifi to a 2.4ghz network to avoid any possible interference.)
 
    Method 1: Enter `nmtui`, go down to `Activate a connection` and activate one of the detected wifi networks.

    Method 2: Edit the config.txt file in `/config` to contain `connect_wi-fi YOUR_WIFI_SSID YOUR_WIFI_PASSWORD`

    Method 3: While in the scripts folder, run the wifi-connect.sh script.

    To check your connection after, run `nmcli` and your wlan0 connection should be green. Make a note of your ip address. We will need this to ssh into the system later.

 * Step 4 - Set your desired screen resolution and refresh rate in the `screen-mode` file. Enter `pixelpilot --screen-mode-list` to list the available modes your connected display can handle. Then enter `sudo nano /config/scripts/screen-mode` and change to your desired specifications. Format is `WxH@fps` -- Common values would be 1920x1080@60, 1920x1080@120. 1280x720@60, 1280x720@120. For smooth DVR playback, set the dvr-fps with `sudo nano /config/scripts/dvr-fps` to the fps at which your camera is shooting. e.g. 60, 90, 120
If you want to run the highest frame-rate your connected screen is capable of, run `sudo ./config/scripts/highest_framerate.sh`
If you want to run the highest resolution your connected screen is capable of, run `sudo ./config/scripts/highest_resolution.sh`

 * Step 5 (optional) - Set your WFB-ng channel in `/etc/wifibroadcast.cfg` and transfer your `gs.key` to `/etc` (A standard gs.key and drone.key are now provided)
 
 * Step 6 - Shutdown the system, disconnect the keyboard, and connect your wifi card. Boot the system and SSH from a separate computer.
 
 * Step 7 - Test the system. Run `wfb-cli gs` and plug in your camera. Make sure you are properly getting video and telemetry packets. Hit `CTRL-C` to exit the wfb-cli.   Run `sudo systemctl start openipc.service` and the display connected to the radxa should change to your video feed. Press your DVR button. The stream should stop (the screen will go black for a second) and a new stream being recorded should start. Press the dvr button again to stop the saving stream and go back to the display stream. (Again, the stream should go black for a second. If it doesn't, press the button again) Confirm there is a .mp4 video file in `/media` by going to `x.x.x.x:8080` in a browser, replacing `x.x.x.x` with your radxa's ip address. . Run `sudo systemctl stop openipc.service` to stop testing. 
 
 * Step 8 - Last and final step. Once you have confirmed the system is working and you have set your desired settings, run `sudo systemctl enable openipc.service` to have the stream begin on boot. 

***

This image includes DVR functionality; It requires a push button to be installed to the gpio header between physical pin 32 and 3.3v.

DVR is saved to the media folder in your root directory. DVR can be accessed either at `/media` or via a media server. Connect your groundstation to your home network and it can be accessed via a web browser at `x.x.x.x:8080` -- replace `x.x.x.x` with your groundstation's local ip address.

***

This image contains GPIO button support to change channels and toggle between 20MHz and 40MHz bandwidth. Connect a button or switch to 3.3v and physical pins 16 and 18 to increase/decrease your vrx channel. Connect a button or switch to physical pin 38 and 3.3v to toggle your vrx bandwidth between 20MHz and 40Mhz. Physical pin 32 still controls DVR recording.
When changing channels or bandwidth, an on-screen message in PixelPilot will display your current actions.
* Note: the openipc.service must be running for buttons to function.
