#! bash oh-my-bash.module

# based of the candy theme, but minimized by odbol
function _omb_theme_PROMPT_COMMAND() {
  # Check if the virtual environment is activated and display it
  local venv_prompt=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    venv_prompt="${_omb_prompt_white}(`basename \"$VIRTUAL_ENV\"`) "
  fi

  # Set the PS1 with the virtual environment information included
  PS1="$(clock_prompt) ${venv_prompt}${_omb_prompt_reset_color}${_omb_prompt_white}\w${_omb_prompt_reset_color}$(scm_prompt_info)${_omb_prompt_navy} →${_omb_prompt_navy} ${_omb_prompt_reset_color}";
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_navy"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%I:%M:%S"}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND