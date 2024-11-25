# dotfiles

## Linux

Copy dotfiles to ~/

## MacOS

Mostly follows [this guide](https://blog.larsbehrenberg.com/the-definitive-iterm2-and-oh-my-zsh-setup-on-macos)

### Homebrew

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

+### iTerm2 or Warp.dev
`https://app.warp.dev/download`

`brew cask install iterm2` or [download](https://iterm2.com/downloads.html)

### oh-my-zsh

`brew install zsh && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`

#### ohmyzsh theme

`git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k`

##### Install fonts/fix things

`p10k configure`

### YouTube Music Desktop App

`brew install --cask ytmdesktop-youtube-music`

### Setup TMUX

Install TMUX PLugin Manager

`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

#### Fetch updated tpm module (fixes error)

``

#### Install plugins from tmux.conf

`run ^b-I inside tmux session`

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

`brew install openssl readline sqlite3 xz zlib exa asdf fzf zoxide`

`npm install -g opencommit`

`curl https://pyenv.run | bash`

`source ~/.zshrc`

`python install <go find the latest from python.org>`
