# Default-Setup
function fish_greeting; echo; end;
function add_blank_line --on-event fish_postexec; echo; end;

# Access-Configs
function fishconfig; subl ~/.config/fish/config.fish; end;
function fishreload; source ~/.config/fish/config.fish; end;