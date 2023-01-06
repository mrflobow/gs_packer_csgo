# CounterStrike Source Gameserver Packager

## Requirements

* Packager installed
* Proxmox

### MacOSX
```
brew install ansible
```

## Packer
Builds Counter Strike Gameserver base on Ubuntu

Check config in working directory gs-debian

### Config

```bash
packer validate -var-file='credentials.pkr.hcl' gs-cssource.pkr.hcl
```

### Build Gameserver Templae

```bash
packer build -var-file='credentials.pkr.hcl' gs-cssource.pkr.hcl
```