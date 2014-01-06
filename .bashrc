function my_ps()
{ ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
#
function pp()
{ my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }
#
function my_ip() # Obtenir l'adresse IP
{
    IP_eth0=$(/sbin/ifconfig eth0 | awk '/inet a/ { print $2 } ' | sed -e s/adr:/eth0\ :\ /)
}
#
function ii()   # Obtenir des infos sur la machine
{
  echo -e "\n\033[1;31mMachine :\033[0m $HOSTNAME"
  echo -e "\n\033[1;31mNoyau :\033[0m " ; uname -a
  echo -e "\n\033[1;31mUtilisateurs loggés :\033[0m " ; w -h
  echo -e "\n\033[1;31mDate :\033[0m " ; date
  echo -e "\n\033[1;31mStats memoires :\033[0m " ; free
 my_ip 2>&1 ;
  echo -e "\n\033[1;31mAdresse IP :\033[0m" ; echo ${IP_eth0}
}

# Trouve les fichiers les plus récents du repertoire encours
function fr()
{ find . -type f -printf "%TY%Tm%Td %TT %p\n" 2>/dev/null|sort -r|head -1 ; }

# ===============================================
# Prompt
# ===============================================

# affichage sympathique de la ligne de commande
# . gitbashprompt
PS1="[\t] \[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ "
if [[ ${EUID} == 0 ]] ; then
        PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
    else
        PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
    fi

# ===============================================
# Alias
# ===============================================

# Affiche un calendrier avec la journée en cours en rouge
alias c='var=$(cal -m); echo "${var/$(date +%-d)/$(echo -e "\033[1;31m$(date +%-d)\033[0m")}"'

# Affiche en jaune les éléments matché par grep
alias grep='GREP_COLOR="1;33;40" LANG=C grep --color=auto'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

# ls
alias ll='ls -l --color'
alias ls='ls -h -F --show-control-chars --color=auto'
alias l='ls'
alias la='ls -a'
alias lsd='ls -d */'

# affiche les 10 plus gros fichiers a partir du repertoire courrant
alias esp='find $(pwd) -ls|sort +6n|tail'
alias dusort='du -x --block-size=1048576 | sort -nr|head'

alias df='df -h'

alias vi='vim'

alias screen='screen -dRR'
# ===============================================
# Inclassables
# ===============================================

# ne pas mettre en double dans l'historique les commandes tapées 2x
export HISTCONTROL=ignoredups

# Utiliser vim pour lire les pages man sous Gentoo uniquement
#export MANPAGER=vimmanpager
# Pour dÃ©finir l'éditeur par défaut utilisé par de nombreuses commandes (vipw, visudo, less, cvs, svn...) :
export EDITOR=vim

# Pour ne pas avoir de fichiers coredumps
ulimit -S -c 0

# Limite de la polution
unset use_color safe_term match_lhs

# Vérifie la taille de la fenetre apres chaque commande et
# si c'est nécessaire met à  jour les valeurs de LINES et COLUMNS
shopt -s checkwinsize


#export PATH=${PATH}:/media/disk/android-sdk-linux_86/tools:/home/alexandre/texlive/2011/bin/x86_64-linux
#export PATH=${PATH}:/media/disk/opt/texlive/2012/bin/x86_64-linux
#/media/disk/opt/texlive/2012/texmf/doc/man
#Add /media/disk/opt/texlive/2012/texmf/doc/man to MANPATH, if not dynamically determined.
# Add /media/disk/opt/texlive/2012/texmf/doc/info to INFOPATH.
export INFOPATH=$INFOPATH:/usr/local/texlive/2013/texmf-dist/doc/info
export MANPATH=$MANPATH:/usr/local/texlive/2013/texmf-dist/doc/man
export PATH=$PATH:/usr/local/texlive/2013/bin/x86_64-linux


shopt -s histappend
PROMPT_COMMAND='history -a'
set -o vi

alias co='cd ~/coffre;git pull;encfs /home/alexandre/coffre/coffre /home/alexandre/coffre_open'
alias cf='fusermount -u /home/alexandre/coffre_open;cd ~/coffre;git commit -a;git push'

alias tmux='tmux -2 attach'
#alias tmux="TERM=screen-256color-bce tmux"
