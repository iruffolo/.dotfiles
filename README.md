# Install Instructions

1. Install Packer from [AUR](https://aur.archlinux.org/packages/nvim-packer-git)

    `yay -S nvim-packer-git`

2. Open nvim, there will be errors from packages not found. Install packages with:

    `:PackerSync`

3. Install a nerd font and set to system mono space font (in gnome tweaks or fonts).
This is required for icons in telescope.

    `pacman -S ttf-hack-nerd`

