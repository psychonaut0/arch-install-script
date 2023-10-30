#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"



# Import all functions
source "${CURRENT_DIR}/libs/main.sh"

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

# Set the hardware clock
hwclock --systohc

# Set the locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

# Generate the locale
locale-gen

# Create the locale.conf file
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Ask for the hostname
read -p "Enter the hostname: " HOSTNAME

# Create the hostname file
echo $HOSTNAME >> /etc/hostname

# Set the root password
echo "Set the root password"
passwd

# Install the bootloader with systemd-boot
bootctl install

# Create the loader.conf file
echo "default @saved" >> /boot/loader/loader.conf
echo "timeout 4" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf
echo "console-mode max" >> /boot/loader/loader.conf

# Create the arch.conf file
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=LABEL=ARCH_OS rw quiet splash" >> /boot/loader/entries/arch.conf

# Enable parallel downloads in pacman
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf

# Enable multilib in pacman
echo "[multilib]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

# Update pacman
pacman -Syu --noconfirm

local vendor_id=$(lscpu | grep "Vendor ID" | awk '{print $3}')

# Check if user has an intel or amd cpu
if [[ $vendor_id == "GenuineIntel" ]]; then
  # Install intel-ucode
  pacman -S intel-ucode --noconfirm
  pacman -S thermald --noconfirm
  systemctl enable thermald
  pacman -S i7z --noconfirm
elif [[ $vendor_id == "AuthenticAMD" ]]; then
  # Install amd-ucode
  pacman -S amd-ucode --noconfirm
  pacman -S turbostat --noconfirm
else
  echo "No cpu found"
fi

# Create a new user
read -p "Enter the username: " USERNAME
useradd -m -g users -G wheel -s /bin/zsh $USERNAME

# Set the user password
echo "Set the user password"
passwd $USERNAME

# Allow users in the wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

# Install zsh
pacman -S zsh --noconfirm

# Change the default shell to zsh
chsh -s /bin/zsh

# log in as the new user
su $USERNAME

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install vim
pacman -S vim --noconfirm

# Install networkmanager
pacman -S networkmanager --noconfirm

# Enable networkmanager
systemctl enable NetworkManager

# Install git
pacman -S git --noconfirm

# Install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

pacman -S power-profiles-daemon --noconfirm
systemctl enable power-profiles-daemon



# Get installed gpu
local gpu=$(lspci | grep VGA | awk '{print $5}')

# Check if user has an intel, amd or nvidia gpu
if [[ $gpu == "Intel" ]]; then
  # Install intel drivers
  pacman -S xf86-video-intel --noconfirm
  pacman -S mesa --noconfirm
  pacman -S vulkan-intel --noconfirm
  pacman -S lib32-mesa --noconfirm
  pacman -S lib32-vulkan-intel --noconfirm
elif [[ $gpu == "AMD" ]]; then
  # Install amd drivers
  pacman -S xf86-video-amdgpu --noconfirm
  pacman -S mesa --noconfirm
  pacman -S vulkan-radeon --noconfirm
  pacman -S lib32-mesa --noconfirm
  pacman -S lib32-vulkan-radeon --noconfirm
elif [[ $gpu == "NVIDIA" ]]; then
  # Install nvidia drivers
  pacman -S nvidia --noconfirm
  pacman -S nvidia-utils --noconfirm
  pacman -S lib32-nvidia-utils --noconfirm
  pacman -S nvidia-settings --noconfirm
else
  echo "No gpu found"
fi


# Install xorg
pacman -S xorg --noconfirm

# Install pipewire
pacman -S pipewire --noconfirm
pacman -S wireplumber --noconfirm
pacman -S pipewire-audio --noconfirm
pacman -S pipewire-pulse --noconfirm
pacman -S pipewire-alsa --noconfirm
pacman -S pipewire-jack --noconfirm
pacman -S lib32-pipewire --noconfirm
pacman -S lib32-pipewire-jack --noconfirm

# Enable pipewire
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse

# Install i3
pacman -S i3-wm --noconfirm

# Install i3status
pacman -S i3status --noconfirm

# Install polkit
pacman -S polkit --noconfirm
pacman -S polkit-gnome --noconfirm

# Create drop in file for disabling username propmt
mkdir -p /etc/systemd/system/getty@tty1.service.d
touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "[Service]" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "ExecStart=-/sbin/agetty -o '-p -- username' --noclear --skip-login - $TERM" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf

# Install plymouth
pacman -S plymouth --noconfirm




# Install picom to get dependencies
pacman -S picom --noconfirm

# Remove picom
pacman -R picom --noconfirm

# Clone picom pijulius fork
git clone https://github.com/pijulius/picom.git

# Build picom with ninja
cd picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
ninja -C build install
cd ..
rm -rf picom

# Install polybar
pacman -S polybar --noconfirm

# Install rofi
pacman -S rofi --noconfirm

# Install feh
pacman -S feh --noconfirm

# Install dunst
pacman -S dunst --noconfirm

# Install python-pywal
pacman -S python-pywal --noconfirm

# Install alacritty
pacman -S alacritty --noconfirm

# Install flatpak
pacman -S flatpak --noconfirm

# Install brave
yay -S brave-bin --noconfirm

# Clone dotfiles
git clone https://github.com/psychonaut0/dotfiles-v2.git

# Copy all the content of the dotfiles folder to the home folder
cp -r dotfiles-v2/. ~/

# Remove the dotfiles folder
rm -rf dotfiles-v2

# Exit the chroot environment
exit