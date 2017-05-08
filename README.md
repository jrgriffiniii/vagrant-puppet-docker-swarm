# Vagrant for the Hydra Swarm
## Creating the Swarm
### Requirements
- Vagrant 1.9.3 or later
- Ruby 2.4.1 or later
```bash
$ vagrant plugin install vagrant-vbguest
$ bundle install
$ cd puppet/ && bundle exec librarian-puppet install && cd ..
$ vagrant up
```

## Errors for VBoxGuestAdditions for the VirtualBox Provider
You may receive the following error:
```
Vagrant was unable to mount VirtualBox shared folders. This is usually
because the filesystem "vboxsf" is not available. This filesystem is
made available via the VirtualBox Guest Additions and kernel module.
Please verify that these guest additions are properly installed in the
guest. This is not a bug in Vagrant and is usually caused by a faulty
Vagrant box. For context, the command attempted was:

mount -t vboxsf -o uid=0,gid=1000 tmp_vagrant-puppet_manifests-a11d1078b1b1f2e3bdea27312f6ba513 /tmp/vagrant-puppet/manifests-a11d1078b1b1f2e3bdea27312f6ba513

The error output from the command was:

mount: unknown filesystem type 'vboxsf'
```

Please attempt to update the base Box:
`$ vagrant box update`

If this fails to resolve the problem, please attempt to install the Vagrant plugin:
```
$ vagrant plugin install vagrant-vbguest
$ vagrant destroy && vagrant up
```
