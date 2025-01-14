#! bash oh-my-bash.module

function _omb_theme_PROMPT_COMMAND() {
	local venv_prompt=""
	if [[ -n "$VIRTUAL_ENV" ]]; then
		venv_prompt="${_omb_prompt_white}(`basename \"$VIRTUAL_ENV\"`) "
	fi

	PS1="\n${_omb_prompt_blue}\u@\h ${venv_prompt}${_omb_prompt_white}\w $(scm_prompt_info)\n${_omb_prompt_blue}\$ ${_omb_prompt_white}"
}

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX="${_omb_prompt_white}→ ${_omb_prompt_bold_teal}"
SCM_THEME_PROMPT_SUFFIX=""

OMB_PROMPT_VIRTUALENV_FORMAT="${_omb_prompt_bold_gray}(%s)${_omb_prompt_reset_color}"
OMB_PROMPT_CONDAENV_FORMAT="${_omb_prompt_bold_gray}(%s)${_omb_prompt_reset_color}"

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND