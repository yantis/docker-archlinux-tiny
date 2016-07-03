# archlinux-tiny

On Docker hub [archlinux-tiny](https://registry.hub.docker.com/u/yantis/archlinux-tiny/)
on Github [docker-archlinux-tiny](https://github.com/yantis/docker-archlinux-tiny)

119 MB Arch Linux base container. The goal of this was to build an extremely small Arch Linux base without giving up any functionality.
I used Les Aker's [dock0/arch](https://github.com/dock0/arch) as a foundation.
I also added some amazing repos like [BlackArch](http://blackarch.org) and [BBQLinux](http://bbqlinux.org).

The goal was to maintain complete functionality so I did not swap out coreutils for busybox.
But you could swap out a few things for the busybox version of them and reduce the size down another 20 MB or so.


## Docker Images Structure

>[yantis/archlinux-tiny](https://github.com/yantis/docker-archlinux-tiny)
>>[yantis/archlinux-small](https://github.com/yantis/docker-archlinux-small)
>>>[yantis/archlinux-small-ssh-hpn](https://github.com/yantis/docker-archlinux-ssh-hpn)
>>>>[yantis/ssh-hpn-x](https://github.com/yantis/docker-ssh-hpn-x)
>>>>>[yantis/dynamic-video](https://github.com/yantis/docker-dynamic-video)
>>>>>>[yantis/virtualgl](https://github.com/yantis/docker-virtualgl)
>>>>>>>[yantis/wine](https://github.com/yantis/docker-wine)


## Features 
* Arch Linux 64 bit core, extra, community repos
* Arch Linux 32 bit multilib repo
* [BBQLinux](http://bbqlinux.org) repo for Android Developers.
* [BlackArch](http://blackarch.org) repo for penetration testers and security professionals.
* [Arch Linux CN](https://github.com/archlinuxcn) repo 
* user:docker password:docker
* [Reflector] (https://wiki.archlinux.org/index.php/Reflector) mirror optimized for western USA.
* cower and package-query for interacting with the AUR. 
* compact (removal of a lot of unneeded stuff that pacman will auto re-install if needed)

7/2/2016 added but currently not taking advantage of it
[Amylum] (https://github.com/amylum/repo) Arch packages primarily compiled statically and built against musl

As an example this is a search for chrome with the above repos installed:
![](http://yantis-scripts.s3.amazonaws.com/screenshot_20150407-030717.jpg)

## How did you get it so small.
The biggest win was the removal of Perl at 40MB. Perl is needed for two things on the base Arch Linux install
OpenSSL (it shouldn't be honestly since it isn't really used other than for one small thing on Windows)
Some other distros have already fixed this [issue] (https://github.com/NixOS/nixpkgs/issues/6763) like NixOS 
Also, see this [thread](https://bbs.archlinux.org/viewtopic.php?id=73200) and [this](https://bugs.archlinux.org/task/14903).
And for [texinfo](http://www.gnu.org/software/texinfo) (8 MB) which we patched out with a fake stub.

As well as aggressively cleaning of info, doc and man pages as well as stripping out the non English international stuff.

## Caveats
This is slimmed down as much as possible while still having full pacman functionality to install any package needed.
This is ment to be more of the lowest possible base to build upon. Try out one of my other Arch Linux versions if you want something more.

Where it might break is all but the English locales have been removed, as well as any terminfo configs that are not xterm based.
Do not expect any info, documents or manual pages to exist locally either as those have been purged as well.

I am currently experimenting with the removal of zoneinfo and i18n and no problems so far.

Anything you install with pacman should just install fine but if you want to install something from the AUR you are going to need
to install dev tools first like make, gcc, autoconf etc.


## Miscellaneous

To save on space the pacman databases are purged. You need run pacman -Sy at least once before using pacman.

```bash
RUN pacman -Sy
```

Most of the time pacman will install packages and dependencies just fine. Sometimes though it will say 
"error: command failed to execute correctly " with a command not found message. That means you need to install a dependency.

For example the git package uses groupadd and useradd which are both in the shadow package but you may not know that so to find it you can use the pkgfile tool.
This will show you which package to install. In this case you would install the shadow package before installing git.

```bash
$ pacman -S pkgfile && pkgfile --update
$ pkgfile useradd
core/shadow
extra/bash-completion
```


This image has a user docker with the password docker. You will most likely want to change the password. Just add this line to your Dockerfile.

```bash
RUN echo -e "docker\nyournewpassword" | passwd docker
```

The mirrors are optimized for US West  If you want it for your area just add this to the top of your Dockerfile.

```bash
RUN pacman -S reflector --noconfirm && \
    reflector --verbose -l 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Rs reflector --noconfirm
```

Included is cower and package-query for interacting with the AUR. You might want another one like
[yaourt](https://wiki.archlinux.org/index.php/Yaourt). To install that just:

```bash
RUN pacman -S --noconfirm yaourt
```

The different repositories have a lot of really nice packages. To get a list just run package-query like this.

```bash
package-query -Sl archassault
```

![](http://yantis-scripts.s3.amazonaws.com/screenshot_20150407-023220.jpg)


## Random Thoughts (Stuff that you could do that wasn't done)
* Tried converting coreutils to busybox. It just wasn't worth breaking GNU compatibility that pacman needs. 
Try [shingonoide's image](https://github.com/shingonoide/docker_archlinux-busybox) first before going this route to see if this works for you.
* The /etc/include directory contains 14 MB of header files. Those could get purged downstream if you knew you were never going to compile or update. Though if that was the case you could delete a whole lot more than that.
* You could remove linux-api-headers and get 3.3MB of space there but you would have to remember to re-install before any builds. 
* One could remove the licenses package and get 1 MB. (ie: zip it up. Upload it and provide a link). I didn't mess with this for obvious reasons.
* glibc is a monster. You could look into using [musl](http://www.musl-libc.org/faq.html) but in this case you should probably just use [Alpine Linux](http://alpinelinux.org)
* /var/lib/pacman/local has 2.5MB in it that could be purged and restored with this [script](https://bbs.archlinux.org/viewtopic.php?pid=670876)
