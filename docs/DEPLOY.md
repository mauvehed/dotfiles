# dotfiles

>This document is out of date/old and was a manual install process. Please follow the directions in [Chezmoi README](../README.md) instead of using this document.
>
>I am keeping this for historical reference in case I need any steps from here.

## Linux

Follow [Chezmoi README](../README.md)

## MacOS

Mostly follows [this guide](https://blog.larsbehrenberg.com/the-definitive-iterm2-and-oh-my-zsh-setup-on-macos)

### Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### iTerm2 or Warp.dev

`https://app.warp.dev/download`

`brew cask install iterm2` or [download](https://iterm2.com/downloads.html)

### oh-my-zsh

```sh
brew install zsh && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

#### ohmyzsh theme

```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

##### Install fonts/fix things

```sh
p10k configure
```

### YouTube Music Desktop App

```sh
brew install --cask ytmdesktop-youtube-music
```

### Setup TMUX

Install TMUX PLugin Manager

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### Fetch updated tpm module (fixes error)

``

#### Install plugins from tmux.conf

```sh
run ^b-I inside tmux session
```

### Enable fingerprint auth for sudo on macOS

```bash
#!/bin/bash
#
# credit to machupicchubeta/dotfiles/bin/enable_to_sudo_authenticate_with_touch_id.sh
set -eu
set -o pipefail

sudo chmod +w /etc/pam.d/sudo
if ! grep -Eq '^auth\s.*\spam_tid\.so$' /etc/pam.d/sudo; then
    ( set -e; set -o pipefail
      # Add "pam_tid.so" to a first authentication
      pam_sudo=$(awk 'fixed||!/^auth /{print} !fixed&&/^auth/{print "auth       sufficient     pam_tid.so";print;fixed=1}' /etc/pam.d/sudo)
      sudo tee /etc/pam.d/sudo <<<"$pam_sudo"
    )
fi
```

## pyenv (& friends)

Adopted from <https://realpython.com/intro-to-pyenv/>

### macOS

```sh
brew install openssl readline sqlite3 xz zlib exa asdf fzf zoxide
```

```sh
npm install -g opencommit
```

```sh
curl https://pyenv.run | bash
```

```sh
source ~/.zshrc
```

```sh
python install <go find the latest from python.org>
```
