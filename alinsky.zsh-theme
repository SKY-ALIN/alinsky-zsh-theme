# NOTICE: This code is part of alinsky-zsh-theme.  
# Any modifications must remain open-source under GPL-3.0  
# and retain this copyright notice.
#
# alinsky-zsh-theme - Custom ZSH theme
# Copyright (C) 2025 Vladimir Alinsky (github.com/SKY-ALIN)

setopt prompt_subst

typeset -g CURRENT_BG='NONE'
typeset -g STAR='*'
typeset -g SEGMENT_SEPARATOR_RIGHT='\ue0b2'
typeset -g SEGMENT_SEPARATOR_LEFT='\ue0b0'
typeset -g CMD_START_TIME
typeset -g CMD_DURATION

function git_prompt() {
  local git_branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2> /dev/null)

	if [[ -n "$git_branch" ]]; then
		local git_status=$(git --no-optional-locks status --porcelain 2> /dev/null | tail -n 1)
		if [[ -n "$git_status" ]]; then
      if git status --porcelain 2> /dev/null | grep -q '^??'; then
        prompt_segment_right 208 default
        echo -n "%{%B%}[${git_branch}${STAR}]%{%b%} "
      else
        prompt_segment_right green default
        echo -n "%{%B%}[${git_branch}${STAR}]%{%b%} "
      fi
    else
      prompt_segment_right green default
      echo -n "[${git_branch}] "
    fi
	fi
}

function time_prompt() {
  local time_format="%D{%H:%M}"
  [[ -n "$CMD_DURATION" ]] && time_format+=" "
  prompt_segment_right blue default "$time_format"
}

function duration_prompt() {
  [[ -n "$CMD_DURATION" ]] && {
    prompt_segment_right magenta default "$CMD_DURATION"
  }
}

function dir_prompt() {
  prompt_segment blue default "%~"
}

function format_duration() {
  local seconds=$1
  (( $seconds > 60 )) && {
    local minutes=$(( seconds / 60 ))
    seconds=$(( seconds % 60 ))
    echo "${minutes}m ${seconds}s"
    return
  }
  echo "${seconds}s"
}

function prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR_LEFT%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

function prompt_segment_right() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    echo -n "%K{$CURRENT_BG}%F{$1}$SEGMENT_SEPARATOR_RIGHT%{$bg%}%{$fg%} "
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

function prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR_LEFT"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

function prompt_end_right() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

function build_prompt() {
  dir_prompt
  prompt_end
}

function build_rprompt() {
  git_prompt
  time_prompt
  duration_prompt
  prompt_end_right
}

PROMPT='$(build_prompt)'
RPROMPT='$(build_rprompt)'

function custom-accept-line() {
  zle reset-prompt
  zle .accept-line
}
zle -N custom-accept-line
bindkey '^M' custom-accept-line

function preexec() {
  CMD_START_TIME=$EPOCHREALTIME
}

function precmd() {
  if [[ -n $CMD_START_TIME ]]; then
    local cmd_end_time=$EPOCHREALTIME
    local duration=$(( cmd_end_time - CMD_START_TIME ))
    unset CMD_START_TIME

    (( duration > 1 )) && {
      CMD_DURATION=$(format_duration ${duration%.*})
    } || unset CMD_DURATION
  else
    unset CMD_DURATION
  fi
  
  RPROMPT='$(build_rprompt)'
}
