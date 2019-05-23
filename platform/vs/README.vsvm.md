HOWTO Use Virtual Switch (VM)

1. Install libvirt, kvm, qemu

```
sudo apt-get install libvirt-clients qemu-kvm libvirt-bin
```

2. Create SONiC VM

```
$ sudo virsh
Welcome to virsh, the virtualization interactive terminal.

Type:  'help' for help with commands
       'quit' to quit

virsh # 
virsh # create sonic.xml
Domain sonic created from sonic.xml

virsh # 
```

3. Access virtual switch:

    1. Connect SONiC VM via console

    ```
    $ telnet 127.0.0.1 7000
    ```
    
    OR

    2. Connect SONiC VM via SSH
        
        1. Create the `libvirt` group if it doesn't already exist
        
        ```
        $ sudo groupadd libvirt
        ```
        2. Add yourself to the `libvirt` group
        
        ```
        $ sudo usermod -G libvirt -a $USER
        ```
        3. Connect via SSH
        ```
        $ ssh -p 3040 admin@127.0.0.1
        ```
        Note: when connecting via SSH, after starting/rebooting the VM there is a wait period until SSH access is available. This delay is dependent on the number of network interfaces defined in `sonic.xml` (for 32 interfaces the delay is about 15 seconds, and increases from there). Attempting to SSH into the VM during this delay will break SSH access until the VM is rebooted.
