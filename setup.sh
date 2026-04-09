#!/usr/bin/env bash

echo "Updating software..."
sudo apt update
sudo apt full-upgrade -y

echo "Installing software..."
#atuin, fastfetch, rizin, cutter, oletools
sudo apt -q -y install autojump\
    curl\
    git\
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl git \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    bat\
    zsh\
    tmux\
    emacs\
    gdb\
    python3-pip\
    xrdp\
    eza\
    groff\
    bc\
    dc\
    lshw\
    shfmt\
    cmake\
    lolcat\
    cowsay\
    figlet\
    filters\
    fortunes\
    bsdgames\
    dos2unix\
    asciinema\
    avahi-daemon\
    keychain\
    multitail\
    docker.io\
    fontforge\
    doxygen\
    graphviz\
    ruby-dev\
    gdb-multiarch\
    gdbserver\
    lldb\
    hexyl\
    direnv\
    tmuxinator\
    wireshark\
    chafa\
    yara\
    binwalk\
    foremost\
    radare2\
    strace\
    ltrace\
    upx-ucl\
    exiftool\
    p7zip-full\
    ssdeep\
    pev\
    default-jdk\
    afl++\
    clang\
    llvm\
    llvm-dev\
    libclang-dev\
    z3\
    libz3-dev

if [ $? -ne 0 ]; then
    echo "apt installation failure"
    echo "Please correct the error and run this script again"
    exit
fi

type colorls > /dev/null 2>&1
if [ $? -ne 0 ]; then
    sudo gem install colorls mdless
    if [ $? -ne 0 ]; then
        echo "gem installation failure"
        echo "Please correct the error and run this script again"
        exit
    fi
fi

mkdir -p $HOME/bin
mkdir -p $HOME/clones
mkdir -p $HOME/malware/samples
mkdir -p $HOME/malware/analysis

#install a known version of python and use that as the default

type pyenv > /dev/null 2>&1
if [ $? -ne 0 ]; then
    curl https://pyenv.run | bash

    if [ $? -ne 0 ]; then
        echo "pyenv installation failure"
        echo "Please correct the error and run this script again"
        exit
    fi

    PYENV_ROOT="$HOME/.pyenv"
    PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

    pyenv install 3.13.7
    pyenv global 3.13.7
fi

PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pip install --upgrade pip requests python-dateutil pefile capstone yara-python pyelftools angr oletools

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
$HOME/.cargo/bin/cargo install mcat

# IDA Classroom requires a free registration at https://hex-rays.com/ida-free/
# Download the Linux installer manually and run it. The setup.md has instructions.

if [ ! -e $HOME/antigen.zsh ]; then
    curl -L git.io/antigen > $HOME/antigen.zsh
fi

if [ ! -d $HOME/clones/bat-extras ]; then
    git clone https://github.com/eth-p/bat-extras.git $HOME/clones/bat-extras
    cd $HOME/clones/bat-extras
    sudo ./build.sh --install
    cd $HOME
fi

if [ ! -d $HOME/clones/diff-so-fancy ]; then
    git clone https://github.com/so-fancy/diff-so-fancy.git $HOME/clones/diff-so-fancy
fi

if [ ! -d $HOME/.tmux/plugins/tpm ]; then
    mkdir -p $HOME/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi

if [ ! -d $HOME/.oh-my-zsh ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh
fi

if [ ! -d $HOME/clones/nerd-fonts ]; then
    git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git $HOME/clones/nerd-fonts
    cd $HOME/clones/nerd-fonts
    git sparse-checkout add patched-fonts/Hack
    ./install.sh
    cd $HOME
fi

if [ ! -e $HOME/bin/diff-so-fancy ]; then
    ln -s $HOME/clones/diff-so-fancy/diff-so-fancy $HOME/bin/diff-so-fancy
fi

sudo chsh -s $(which zsh) $(whoami)
sudo usermod -aG docker,wireshark $(whoami)

if [ ! -e $HOME/.zshrc.local ]; then
    curl http://web.cecs.pdx.edu/~dmcgrath/setup.tar.bz2 | tar xjvf - -C ~/
fi

sudo systemctl enable --now avahi-daemon
sudo systemctl enable --now snapd
sudo systemctl enable --now snapd.apparmor
sudo systemctl enable --now docker
sudo systemctl enable --now xrdp
sudo systemctl enable --now ssh


###############=====================################
###############= git configuration =################
git config unset --global user.name
#fill in and uncomment the next two lines!
git config --global user.name "Molly Diaz"
git config --global user.email "modiaz@pdx.edu"
git config get --global user.name > /dev/null
if [ $? -ne 0 ]; then
    echo "Please set your git user.name and user.email!"
    echo "You were prompted to do this, but you didn't!"
    echo "git config --global user.name \"Your Name Here\""
    echo "git config --global user.email \"ODIN@pdx.edu\""
fi


git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global color.ui true
git config --global color.diff-highlight.oldNormal    "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal    "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"
git config --global color.diff.meta       "11"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.func       "146 bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"

exec zsh
