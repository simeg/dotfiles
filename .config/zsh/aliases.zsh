########################################
# 📝 Editor / Dotfile / Dev Tools
########################################

# Use Neovim as default editor
# vim aliases handled by functions in .zshrc to prevent override
# alias vim="nvim"
# alias v="nvim"
# alias vi="nvim"

alias vm="nvim ./Makefile"
alias vp="nvim ./package.json"
alias vt="nvim ./.travis.*"

alias vimrc="nvim ~/.config/nvim/init.lua"
alias nvimrc="nvim ~/.config/nvim/init.lua"
alias zshrc="nvim ~/.zshrc ; reload"
alias gitignore="nvim ~/.gitignore"
alias gitconfig="nvim ~/.gitconfig"
alias ali="nvim ~/.config/zsh/aliases.zsh"

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
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"
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

# Essential git aliases (replacing ohmyzsh git plugin)
# Core commands
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gapa="git add --patch"
alias gc="git commit"
alias gcm="git commit --message"
alias gcmsg="git commit --message"
alias gca="git commit --amend"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git pull"
alias gp="git push"
alias ggpush="git push origin \$(git branch --show-current)"
alias ggpull="git pull origin \$(git branch --show-current)"
alias gst="git status"
alias gss="git status --short"

# Branch management
alias gb="git branch"
alias gba="git branch --all"
alias gbd="git branch --delete"
alias gbD="git branch --delete --force"

# Log and history
alias glog="git log --oneline --decorate --graph"
alias glg="git log --stat"
alias glgp="git log --stat --patch"

# Stash
alias gsta="git stash push"
alias gstp="git stash pop"
alias gstd="git stash drop"
alias gstl="git stash list"

# Reset and restore
alias grh="git reset"
alias grhh="git reset --hard"
alias grs="git restore --staged"

# Remote
alias gr="git remote"
alias grv="git remote --verbose"

# Fetch and merge
alias gf="git fetch"
alias gfa="git fetch --all"
alias gm="git merge"

# Custom git aliases
alias gcom="git checkout master &>/dev/null || git checkout main"
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
