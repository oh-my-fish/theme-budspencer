set fish_key_bindings fish_vi_key_bindings
bind '#' __barracuda_toggle_symbols
bind -M visual '#' __barracuda_toggle_symbols
bind ' ' __barracuda_toggle_pwd
bind -M visual ' ' __barracuda_toggle_pwd
bind L __barracuda_cd_next
bind H __barracuda_cd_prev
bind m mark
bind M unmark
bind . __barracuda_edit_commandline
bind -M insert \r __barracuda_preexec
bind \r __barracuda_preexec
