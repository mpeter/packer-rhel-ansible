# packer-rhel-ansible

Create RHEL images using Packer and Ansible.

This project will be successful if it accomplishes the following:
- Provides a turnkey way to generate RHEL images via supported channels for local consumption.
- Prefers Ansible over other configuration methods (bash, etc) to configure hosts

# Pre-requisites
- VirtualBox
- Vagrant
- Packer
- Git
- Homebrew (OSX)
- Homebrew Cask (OSX)

Running `./do setup` will automatically install all dependencies. NOTE: OSX installer only at this time, must manual install on Linux.

# Installation
```
git clone https://github.com/mpeter/packer-rhel-ansible.git
cd packer-rhel-ansible
./do setup
```

# Usage
1. Download a RHEL ISO using your Developer Subscription, or other supported subscription method
2. Create a `install.cfg` file based on the provided `install.cfg.example`. At this time, `rhel-6.8-x86_64.json` is supported with `rhel-7.2` planned
3. `./do build` to build both the OVF as well as the vagrant box. If you would like to do this one at a time, you can also do
    1. `./do build-ovf` to create the base image
    2. `./do build-box` to apply base Ansible playbooks
4. `./do install` to add the finished Vagrant .box to your local installation.
5. Profit! Now you can re-use this local Vagrant .box in other projects with `vagrant init <box_prefix>/rhel-6.8`

