#!/bin/sh


# You need to install docker-squash from:
# https://github.com/goldmann/docker-squash

docker-squash -f 15 -t yantis/archlinux-tiny:latest yantis/archlinux-tiny:latest
docker push yantis/archlinux-tiny
