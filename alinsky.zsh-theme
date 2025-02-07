setopt prompt_subst

typeset -g CURRENT_BG='NONE'
typeset -g DEFAULT_BG='black'
typeset -g SEGMENT_SEPARATOR_RIGHT='\ue0b2'
typeset -g SEGMENT_SEPARATOR_LEFT='\ue0b0'

function git_prompt() {
    local git_branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2> /dev/null)

	if [[ -n "$git_branch" ]]; then
		local git_status=$(git --no-optional-locks status --porcelain 2> /dev/null | tail -n 1)
		if [[ -n "$git_status" ]]; then
            if git status --porcelain 2> /dev/null | grep -q '^??'; then
                prompt_segment_right 208 default
                echo -n "%{%B%}[${git_branch}]%{%b%} "
            else
                prompt_segment_right green default
                echo -n "%{%B%}[${git_branch}*]%{%b%} "
            fi
            # prompt_segment_right 208 default
            # echo -n "%{%B%}[${git_branch}]%{%b%} "
        else
            prompt_segment_right green default
            echo -n "[${git_branch}] "
        fi
	fi
}

function time_prompt() {
    prompt_segment_right blue default "%D{%H:%M:%S}"
}

function dir_prompt() {
    prompt_segment blue default
    echo -n "%~"
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
    prompt_end_right
}

PROMPT='$(build_prompt)'
RPROMPT='$(build_rprompt)'
