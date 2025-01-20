This is a prebuilt image for the Radxa Zero 3w to stream OpenIPC video. 

v1.9.4 Release Notes:

* This image brings AP mode and a basic webUI to the radxa groundstation. Long-press the 40MHz_Toggle button, gpio_38, and the onboard wi-fi will enter AP mode and broadcast a wireless network called `RadxaGroundstation` with password `radxaopenipc`. Connect to this network and navigate in a browser to `192.168.4.1:5000` to enter the webUI where you can access DVR files and change groundstation settings.

* The 40MHz_Toggle button is no longer required and the functionality has been removed. 40MHz setting now works as default and still works with 20MHz carrier.

* Because there is no more need to ssh into the system, the Openipc.service now automatically starts on first boot. If one ever desires to access the cli, boot the system with your wfb-ng wifi cards disconnected and the stream will fail to launch, booting to cli.

***

On first boot, the stream will not start to give the user the ability to set up the system. Please perform the following steps.
 * Step 1 - Flash the image to either your onboard emmc or a micro SD card. Connect a screen and wireless cards to your radxa.

 * Step 2 - Re-plug in your sd card to your computer and a directory called `/config` should mount. Inside, navigate to the scripts folder. Set your desired screen resolution and refresh rate in the `screen-mode` file. Format is `WxH@fps` -- Common values would be 1920x1080@60, 1920x1080@120. 1280x720@60, 1280x720@120. This does not need to match your camera settings, you want to set it to either the highest framerate or highest resolution the screen is capable of.
 
   For smooth DVR playback, set the dvr-fps to the fps at which your camera is shooting. e.g. 60, 90, 120

   If you are using ground-based msposd, set your osd file to `ground` now.

* Step 3 - Boot the system. If all your settings are correct and you have a wireless card attached to the usb for wfb-ng, then the openipc.service will begin.
  

***

This image includes DVR functionality; It requires a push button to be installed to the gpio header between physical pin 32 and 3.3v.

DVR is saved to the media folder in your root directory. DVR can be accessed either at `/media` or via a media server. Connect your groundstation to your home network and it can be accessed via a web browser at `x.x.x.x:8080` -- replace `x.x.x.x` with your groundstation's local ip address.

***

This image contains GPIO button support to change channels and toggle between 20MHz and 40MHz bandwidth. Connect a button or switch to 3.3v and physical pins 16 and 18 to increase/decrease your vrx channel. Connect a button or switch to physical pin 38 and 3.3v to toggle your vrx bandwidth between 20MHz and 40Mhz. Physical pin 32 still controls DVR recording.
When changing channels or bandwidth, an on-screen message in PixelPilot will display your current actions.
* Note: the openipc.service must be running for buttons to function.

***

This image has support for groundstation-side rendering of MSPOSD over the wfb-ng tunnel. To enable this functionality, go into `/config/scripts/osd` and change from `air` to `ground`. You must enable the MSPOSD forwarding on the camera for this to work.
