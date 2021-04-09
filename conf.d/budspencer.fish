set fish_key_bindings fish_vi_key_bindings
bind '#' __budspencer_toggle_symbols
bind -M visual '#' __budspencer_toggle_symbols
bind ' ' __budspencer_toggle_pwd
bind -M visual ' ' __budspencer_toggle_pwd
bind L __budspencer_cd_next
bind H __budspencer_cd_prev
bind m mark
bind M unmark
bind . __budspencer_edit_commandline
bind -M insert \r __budspencer_preexec
bind \r __budspencer_preexec
