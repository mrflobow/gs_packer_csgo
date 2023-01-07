# CounterStrike Global Offensive Gameserver Packager Repo
This is a boilerplate to build counterstrike source gameserver image for Proxmox.


## Requirements

* Packager installed
* Proxmox

## Packer
Builds Counter Strike Gameserver base on Ubuntu

Check config in working directory gs-debian (Gameserver Debian 11 - Buster )
````bash
cd gs-debian

packer validate -var-file='credentials.pkr.hcl' gs-csgo.pkr.hcl
````

### Build Gameserver Templae

```bash
packer build -var-file='credentials.pkr.hcl' gs-csgo.pkr.hcl
```