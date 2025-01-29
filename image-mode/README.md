# Image Mode Basics

## Instruqt Track

Access the lab at [red.ht/im-rhel](https://red.ht/im-rhel)

This lab provides :
- A workstation with terminal access
- A registry to host images
- A bootc VM

Time limit : 60min

## Preparation

Follow these instructions to fast forward to using the bootc VM and skip the long build time during your demo.

Expect less than 10min of total prep (mostly build time).

<details open>
        
### Step 1

- Click **Launch** on the bottom right, expect 3min of provisioning.
- Click **Start** on the bottom right when it appears.

### Step 2

This will build and push the bootc image, then build and run the bootc VM (~6min).

- Paste the following commands all at once in **Terminal** tab
```
reglogin
podman build -t rhel.$INSTRUQT_PARTICIPANT_ID.instruqt.io:5000/test-bootc -f Containerfile
podman push rhel.$INSTRUQT_PARTICIPANT_ID.instruqt.io:5000/test-bootc

podman run --rm --privileged \
        --volume .:/output \
         --volume ./config.json:/config.json \
        registry.redhat.io/rhel9/bootc-image-builder:latest \
        --type qcow2 \
        --config config.json \
         rhel.$INSTRUQT_PARTICIPANT_ID.instruqt.io:5000/test-bootc

cp qcow2/disk.qcow2 /var/lib/libvirt/images/bootc-vm.qcow2

virt-install --name bootc-vm \
 --disk /var/lib/libvirt/images/bootc-vm.qcow2 \
--import \
--memory 2048 \
--graphics none \
--osinfo rhel9-unknown \
--noautoconsole \
--noreboot

virsh start bootc-vm
```

### Step 3

- Click **Check** then **Start** to advance to *exercise 2* screen, you should now see the **VM Console** tab.
- Click **Check** then **Start** to advance to *exercise 3* screen, you should now see both the **Containerfile** and **VM Console** tabs.

It's ready !

</details>

## Demo

Now close the instruction pane on the right with the **>** icon on top.

At this point you have a working bootc VM and you may modify the bootc image as you please.

- Use the **Terminal** tab to build and push the image
- Use the **Containerfile** tab to edit the image file
- Use the **VM Console** tab for bootc commands - Credentials : core/redhat

Demo scenarios are offered below to showcase bootc features and value, but you can design your own.

### 1. Bootc merges local configuration

<details open>
        
Tab **Containerfile** : Add the telnet package (or copy and paste everything)
```text
FROM registry.redhat.io/rhel9/rhel-bootc

ADD etc /etc

RUN dnf install -y httpd telnet
RUN systemctl enable httpd
```
Tab **Terminal** : Update the bootc image and push it to registry
```bash
podman build -t rhel.$INSTRUQT_PARTICIPANT_ID.instruqt.io:5000/test-bootc -f Containerfile
podman push rhel.$INSTRUQT_PARTICIPANT_ID.instruqt.io:5000/test-bootc
```
Tab **VM Console** : Make a local change and show it 
> Credentials : core/redhat
```bash
sudo -i
echo "☆ Bootc is awesome ! ☆" > /var/www/html/index.html
curl localhost
```
Tab **VM Console** : Apply the update to the bootc VM
```bash
bootc upgrade
reboot
```
Tab **VM Console** : Show that the local change was retained
```bash
curl localhost
```
Tab **VM Console** : Show the movie
```
sleep 90 && pkill telnet & telnet towel.blinkenlights.nl
```
Tab **Terminal** : Reboot the VM if you cannot exit the movie
```
virsh reboot bootc-vm
```
</details>

### 2. Bootc provides rollback capability

Tab **VM Console** : Show the available rollback  
> Credentials : core/redhat
```
sudo -i
bootc status
```
Tab **VM Console** : Activate the rollback and reboot
```
bootc rollback
reboot
```
Tab **VM Console** : Show that telnet is missing again 
> Credentials : core/redhat
```
rpm -q telnet
curl localhost
```

### 3. Bootc lets you switch to a different image
