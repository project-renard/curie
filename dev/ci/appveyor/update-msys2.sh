#!/bin/sh

# Appveyor under MSYS2/MinGW64
pacman -S --needed --noconfirm pacman-mirrors
pacman -S --needed --noconfirm git

# Update
pacman -Syu --noconfirm
