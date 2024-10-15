# zero3w-gs

Files and installation script for the Radxa Zero 3w to run as an openipc groundstation.

<h2>Instructions</h2>

1. Setup env on Ubuntu 20.04 for rsdk by running these commands:
    ```sh
    sudo apt update
    sudo apt install git npm qemu-user-static binfmt-support curl docker.io -y
    sudo usermod -a -G docker $USER
    # Reboot for the above command to take affect
    sudo reboot
    ```

2. Setup rsdk:
    ```sh
    git clone --recurse-submodules https://github.com/RadxaOS-SDK/rsdk.git
    cd rsdk
    npm install @devcontainers/cli
    export PATH="$PWD/src/bin:$PWD/node_modules/.bin:$PATH"
    ```

3. Create an overlays directory
    ```sh
    mkdir overlays
    cd overlays
    ```

4. Clone Radxa Image build script
    ```sh
    git clone https://github.com/JohnDGodwin/zero3w-gs.git
    #Move back to the rsdk root folder
    cd ..
    ```

5. Modify the file `src/share/rsdk/build/rootfs.jsonnet` to run script during image build. Include the following lines inside the `customize-hooks` section
    ```sh
    'cp -r "overlays/zero3w-gs" "$1/"',
    'chroot "$1" chmod +x /zero3w-gs/install-gs.sh',
    'chroot "$1" sh -c "cd /zero3w-gs && ./install-gs.sh"',
    ```

customize-hooks section should now look like this:

    "customize-hooks"+:
        [
            'echo "127.0.1.1	%(product)s" >> "$1/etc/hosts"' % { product: product },
            'cp "%(output_dir)s/config.yaml" "$1/etc/rsdk/"' % { output_dir: output_dir },
            'echo "FINGERPRINT_VERSION=\'2\'" > "$1/etc/radxa_image_fingerprint"',
            'echo "RSDK_BUILD_DATE=\'$(date -R)\'" >> "$1/etc/radxa_image_fingerprint"',
            'echo "RSDK_REVISION=\'%(rsdk_rev)s\'" >> "$1/etc/radxa_image_fingerprint"' % { rsdk_rev: rsdk_rev },
            'echo "RSDK_CONFIG=\'/etc/rsdk/config.yaml\'" >> "$1/etc/radxa_image_fingerprint"',
            'chroot "$1" update-initramfs -cvk all',
            'chroot "$1" u-boot-update',
            'cp -r "overlays/zero3w-gs" "$1/"',
            'chroot "$1" chmod +x /zero3w-gs/install-gs.sh',
            'chroot "$1" sh -c "cd /zero3w-gs && ./install-gs.sh"',
            |||
                mkdir -p "%(output_dir)s/seed"
                cp "$1/etc/radxa_image_fingerprint" "%(output_dir)s/seed"
                cp "$1/etc/rsdk/"* "%(output_dir)s/seed"
                tar Jvcf "%(output_dir)s/seed.tar.xz" -C "%(output_dir)s/seed" .
                rm -rf "%(output_dir)s/seed"
            ||| % { output_dir: output_dir },
        ]
   

6. Now you can follow the steps to start the devcontainer and build the image
    ```sh
    rsdk devcon up
    rsdk devcon
    rsdk shell
    rsdk build radxa-zero3 bullseye cli
    ```

***

The script will do the following:

* update, upgrade, and install some packages with apt
* setup the /config directory where the user settings and scripts are stored
* setup openipc systemd streaming service
* install a media server for dvr
* install wi-fi drivers
* install wfb-ng
* install PixelPilot
* configure hotplugging of wfb-nics
