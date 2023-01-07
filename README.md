# CS:GO Gameserver - Packer Repo
This is a boilerplate to build counterstrike source gameserver image for Proxmox.


## Requirements

* Packer installed
* Proxmox Server/Cluster

## Packer
Builds Counter Strike Gameserver base on Debian 11 - Buster

Check config in working directory gs-debian 
````bash
cd gs-debian

packer validate -var-file='credentials.pkr.hcl' gs-csgo.pkr.hcl
````

### Build Gameserver Template

```bash
packer build -var-file='credentials.pkr.hcl' gs-csgo.pkr.hcl
```