########################################
# 📝 Editor / Dotfile / Dev Tools
########################################

# Use Homebrew's Vim for clipboard support
alias vim="/opt/homebrew/bin/vim"
alias v="vim"

alias vm="vim ./Makefile"
alias vp="vim ./package.json"
alias vt="vim ./.travis.*"

alias vimrc="vim ~/.vimrc"
alias vplug="vim ~/.vim/vim-plug.vim"
alias zshrc="vim ~/.zshrc ; reload"
alias gitignore="vim ~/.gitignore"
alias ali="vim ~/repos/dotfiles/shell/.alias"

alias dotfiles="pushd ~/repos/dotfiles"
alias reload="source ~/.zshrc"

########################################
# 🧰 Core CLI Enhancements
########################################

alias mv="mv -i -v"
alias cp="cp -i -v"
alias cat="smart-cat"
alias tt="tree -C"
alias path='echo -e ${PATH//:/\\n}'
alias l="ls -lah"

# Better directory navigation
alias dir="dirs -v | head -10"

# Fuzzy helpers
alias fali="alias | fzf"

########################################
# 🐳 Docker & CLI Utilities
########################################

alias d="docker"
alias h="heroku"
alias cpd="copydir"
alias cpf="copyfile"

########################################
# 💡 Eureka Commands
########################################

alias idea="eureka"
alias videa="eureka --view"

########################################
# 🧪 Custom CLI scripts
########################################

alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

########################################
# 🌱 Java / Maven / Deps
########################################

alias mvn="mvnd"
alias fmt="mvn com.spotify.fmt:fmt-maven-plugin:format"
alias deps='check_maven_deps "$(list_maven_modules | fzf)"'

########################################
# 🔧 GNU Coreutils Overrides
########################################

# Note: if using GNU coreutils, oh-my-zsh may alias `ls` weirdly
# Override it manually:
alias ls="eza"  # Better modern ls alternative

########################################
# 🐙 Git & Git Helpers
########################################

alias gcom="git checkout master"
alias gap="git add --patch"
alias gs="git-show"
alias gf!="super-amend"
alias fixup!="super-amend"

# forgit (fzf-powered git helpers)
alias ga_="forgit::add"
alias glo_="forgit::log"
alias gd_="forgit::diff"

########################################
# ☸️ Kubernetes
########################################

alias kubectl="kubecolor"

########################################
# 🚀 Jumping & Navigation
########################################

alias j="z"
alias ji="zi"
