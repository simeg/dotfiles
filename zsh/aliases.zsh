########################################
# 📝 Editor / Dotfile / Dev Tools
########################################

# Use Neovim as default editor
alias vim="nvim"
alias v="nvim"
alias vi="nvim"

alias vm="nvim ./Makefile"
alias vp="nvim ./package.json"
alias vt="nvim ./.travis.*"

alias vimrc="nvim ~/.config/nvim/init.lua"
alias nvimrc="nvim ~/.config/nvim/init.lua"
alias zshrc="nvim ~/.zshrc ; reload"
alias gitignore="nvim ~/.gitignore"
alias ali="nvim ~/repos/dotfiles/zsh/aliases.zsh"

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

########################################
# ☸️ Kubernetes
########################################

alias kubectl="kubecolor"

########################################
# 🚀 Jumping & Navigation
########################################

alias j="z"
alias ji="zi"
