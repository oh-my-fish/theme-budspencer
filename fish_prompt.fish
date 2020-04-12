#!/data/data/com.termux/usr/bin/fish

###############################################################################
#
# Prompt theme name:
#   barracuda
#
# Description:
#   a sophisticated airline/powerline theme
#
# Author:
#   Joseph Tannhuber <sepp.tannhuber@yahoo.de>
#
# Sections:
#   -> Color definitions
#   -> Files
#   -> Functions
#     -> Ring bell
#     -> Window title
#     -> Help
#     -> Environment
#     -> Pre execute
#     -> Directory history
#     -> Command history
#     -> Bookmarks
#     -> Sessions
#     -> Commandline editing with $EDITOR
#     -> Git segment
#     -> Bind-mode segment
#     -> Symbols segment
#   -> Prompt initialization
#   -> Left prompt
#
###############################################################################

###############################################################################
# => Color definitions
###############################################################################

# Define colors
set -U barracuda_night 000000 083743 445659 fdf6e3 b58900 cb4b16 dc121f af005f 6c71c4 268bd2 2aa198 859900
set -U barracuda_day 000000 333333 666666 ffffff ffff00 ff6600 ff0000 ff0033 3300ff 00aaff 00ffff 00ff00
if not set -q barracuda_colors
  # Values are: black dark_gray light_gray white yellow orange red magenta violet blue cyan green
  set -U barracuda_colors $barracuda_night
end

# Cursor color changes according to vi-mode
# Define values for: normal_mode insert_mode visual_mode
set -U barracuda_cursors "\033]12;#$barracuda_colors[5]\007" "\033]12;#$barracuda_colors[12]\007" "\033]12;#$barracuda_colors[10]\007" "\033]12;#$barracuda_colors[9]\007"

###############################################################################
# => Files
###############################################################################

# Config file
set -g barracuda_config "$HOME/.config/fish/barracuda_config.fish"

# Temporary files
set -g barracuda_tmpfile '/tmp/'(echo %self)'_barracuda_edit.fish'

###############################################################################
# => Functions
###############################################################################

##############
# => Ring bell
##############
if set -q barracuda_nobell
  function __barracuda_urgency -d 'Do nothing.'
  end
else
  function __barracuda_urgency -d 'Ring the bell in order to set the urgency hint flag.'
    echo -n \a
  end
end

#################
# => Window title
#################
function wt -d 'Set window title'
  set -g window_title $argv
  function fish_title
    echo -n $window_title
  end
end

#########
# => Help
#########
function barracuda_help -d 'Show helpfile'
  set -l readme_file "$OMF_PATH/themes/barracuda/README.md"
  if set -q PAGER
    if [ -e $readme_file ]
      eval $PAGER $readme_file
      else
        set_color $fish_color_error[1]
        echo "$readme_file wasn't found."
      end
  else
    open $readme_file
  end
end

################
# => Environment
################
function day -d "Set color palette for bright environment."
  set barracuda_colors $barracuda_day
  set barracuda_cursors "\033]12;#$barracuda_colors[5]\007" "\033]12;#$barracuda_colors[12]\007" "\033]12;#$barracuda_colors[10]\007" "\033]12;#$barracuda_colors[9]\007"
end

function night -d "Set color palette for dark environment."
  set barracuda_colors $barracuda_night
  set barracuda_cursors "\033]12;#$barracuda_colors[5]\007" "\033]12;#$barracuda_colors[12]\007" "\033]12;#$barracuda_colors[10]\007" "\033]12;#$barracuda_colors[9]\007"
end

################
# => Pre execute
################
function __barracuda_preexec -d 'Execute after hitting <Enter> before doing anything else'
  set -l cmd (commandline | sed 's|\s\+|\x1e|g')
  if [ $_ = 'fish' ]
    if [ -z $cmd[1] ]
      set -e cmd[1]
    end
    if [ -z $cmd[1] ]
      return
    end
    set -e barracuda_prompt_error[1]
    if not type -q $cmd[1]
      if [ -d $cmd[1] ]
        set barracuda_prompt_error (cd $cmd[1] 2>&1)
        and commandline ''
        commandline -f repaint
        return
      end
    end
    switch $cmd[1]
      case 'c'
        if begin
            [ (count $cmd) -gt 1 ]
            and [ $cmd[2] -gt 0 ]
            and [ $cmd[2] -lt $pcount ]
          end
          commandline $prompt_hist[$cmd[2]]
          echo $prompt_hist[$cmd[2]] | xsel
          commandline -f repaint
          return
        end
      case 'cd'
        if [ (count $cmd) -le 2 ]
          set barracuda_prompt_error (eval $cmd 2>&1)
          and commandline ''
          if [ (count $barracuda_prompt_error) -gt 1 ]
            set barracuda_prompt_error $barracuda_prompt_error[1]
          end
          commandline -f repaint
          return
        end
      case 'day' 'night'
        if [ (count $cmd) -eq 1 ]
          eval $cmd
          commandline ''
          commandline -f repaint
          return
        end
    end
  end
  commandline -f execute
end

#####################
# => Fish termination
#####################
function __barracuda_on_termination -s HUP -s INT -s QUIT -s TERM --on-process %self -d 'Execute when shell terminates'
  set -l item (contains -i %self $barracuda_sessions_active_pid 2> /dev/null)
  __barracuda_detach_session $item
end

######################
# => Directory history
######################
function __barracuda_create_dir_hist -v PWD -d 'Create directory history without duplicates'
  if [ "$pwd_hist_lock" = false ]
    if contains $PWD $$dir_hist
      set -e $dir_hist[1][(contains -i $PWD $$dir_hist)]
    end
    set $dir_hist $$dir_hist $PWD
    set -g dir_hist_val (count $$dir_hist)
  end
end

function __barracuda_cd_prev -d 'Change to previous directory, press H in NORMAL mode.'
  if [ $dir_hist_val -gt 1 ]
    set dir_hist_val (expr $dir_hist_val - 1)
    set pwd_hist_lock true
    cd $$dir_hist[1][$dir_hist_val]
    commandline -f repaint
  end
end

function __barracuda_cd_next -d 'Change to next directory, press L in NORMAL mode.'
  if [ $dir_hist_val -lt (count $$dir_hist) ]
    set dir_hist_val (expr $dir_hist_val + 1)
    set pwd_hist_lock true
    cd $$dir_hist[1][$dir_hist_val]
    commandline -f repaint
  end
end

function d -d 'List directory history, jump to directory in list with d <number>'
  set -l num_items (expr (count $$dir_hist) - 1)
  if [ $num_items -eq 0 ]
    set_color $fish_color_error[1]
    echo 'Directory history is empty. '(set_color normal)'It will be created automatically.'
    return
  end
  if begin
      [ (count $argv) -eq 1 ]
      and [ $argv[1] -ge 0 ]
      and [ $argv[1] -lt $num_items ]
    end
    cd $$dir_hist[1][(expr $num_items - $argv[1])]
  else
    for i in (seq $num_items)
      if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
        set_color normal
      else
        set_color $barracuda_colors[4]
      end
      echo '▶' (expr $num_items - $i)\t$$dir_hist[1][$i] | sed "s|$HOME|~|"
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $barracuda_cursors[2]
    set input_length (expr length (expr $num_items - 1))
    read -p 'echo -n (set_color -b $barracuda_colors[2] $barracuda_colors[5])" ♻ Goto [e|0"$last_item"] "(set_color -b normal $barracuda_colors[2])" "(set_color $barracuda_colors[5])' -n $input_length -l dir_num
    switch $dir_num
      case (seq 0 (expr $num_items - 1))
        cd $$dir_hist[1][(expr $num_items - $dir_num)]
      case 'e'
        read -p 'echo -n (set_color -b $barracuda_colors[2] $barracuda_colors[5])" ♻ Erase [0"$last_item"] "(set_color -b normal $barracuda_colors[2])" "(set_color $barracuda_colors[5])' -n $input_length -l dir_num
        set -e $dir_hist[1][(expr $num_items - $dir_num)] 2> /dev/null
        set dir_hist_val (count $$dir_hist)
        tput cuu1
    end
    for i in (seq (expr $num_items + 1))
      tput cuu1
    end
    tput ed
    tput cuu1
  end
  set pcount (expr $pcount - 1)
  set no_prompt_hist 'T'
end

####################
# => Command history
####################
function __barracuda_create_cmd_hist -e fish_prompt -d 'Create command history without duplicates'
  if [ $_ = 'fish' ]
    set -l IFS ''
    set -l cmd (echo $history[1] | fish_indent | expand -t 4)
    # Create prompt history
    if begin
        [ $pcount -gt 0 ]
        and [ $no_prompt_hist = 'F' ]
      end
      set prompt_hist[$pcount] $cmd
    else
      set no_prompt_hist 'F'
    end
    set pcount (expr $pcount + 1)
    # Create command history
    if not begin
        expr $cmd : '[cdms] ' > /dev/null
        or contains $cmd $barracuda_nocmdhist
      end
      if contains $cmd $$cmd_hist
        set -e $cmd_hist[1][(contains -i $cmd $$cmd_hist)]
      end
      set $cmd_hist $$cmd_hist $cmd
    end
  end
  set fish_bind_mode insert
  #echo -n \a
  __barracuda_urgency
end

function c -d 'List command history, load command from prompt with c <prompt number>'
  set -l num_items (count $$cmd_hist)
  if [ $num_items -eq 0 ]
    set_color $fish_color_error[1]
    echo 'Command history is empty. '(set_color normal)'It will be created automatically.'
    return
  end
  for i in (seq $num_items)
    if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
      set_color normal
    else
      set_color $barracuda_colors[4]
    end
    echo -n '▶ '(expr $num_items - $i)
    set -l item (echo $$cmd_hist[1][$i])
    echo -n \t$item\n
  end
  if [ $num_items -eq 1 ]
    set last_item ''
  else
    set last_item '-'(expr $num_items - 1)
  end
  echo -en $barracuda_cursors[4]
  set input_length (expr length (expr $num_items - 1))
  read -p 'echo -n (set_color -b $barracuda_colors[2] $barracuda_colors[9])" ↩ Exec [e|0"$last_item"] "(set_color -b normal $barracuda_colors[2])" "(set_color $barracuda_colors[9])' -n $input_length -l cmd_num
  switch $cmd_num
    case (seq 0 (expr $num_items - 1))
      commandline $$cmd_hist[1][(expr $num_items - $cmd_num)]
      echo $$cmd_hist[1][(expr $num_items - $cmd_num)] | xsel
      for i in (seq (count (echo $$cmd_hist\n)))
        tput cuu1
      end
    case 'e'
      read -p 'echo -n (set_color -b $barracuda_colors[2] $barracuda_colors[9])" ↩ Erase [0"$last_item"] "(set_color -b normal $barracuda_colors[2])" "(set_color $barracuda_colors[9])' -n $input_length -l cmd_num
      for i in (seq (count (echo $$cmd_hist\n)))
        tput cuu1
      end
      tput cuu1
      set -e $cmd_hist[1][(expr $num_items - $cmd_num)] 2> /dev/null
  end
  tput ed
  tput cuu1
  set pcount (expr $pcount - 1)
  set no_prompt_hist 'T'
end

##############
# => Bookmarks
##############
function mark -d 'Create bookmark for present working directory.'
  if not contains $PWD $bookmarks
    set -U bookmarks $PWD $bookmarks
    set pwd_hist_lock true
    commandline -f repaint
  end
end

function unmark -d 'Remove bookmark for present working directory, or remove the entry given as argument.'
  set -l num_items (count $bookmarks)
  if begin
      [ (count $argv) -eq 1 ]
      and [ $argv[1] -ge 0 ]
      and [ $argv[1] -lt $num_items ]
    end
    set -e bookmarks[(expr $num_items - $argv[1])]
  else if contains $PWD $bookmarks
    set -e bookmarks[(contains -i $PWD $bookmarks)]
  else
    return
  end
  set pwd_hist_lock true
  commandline -f repaint
end

function m -d 'List bookmarks, jump to directory in list with m <number>'
  set -l num_items (count $bookmarks)
  if [ $num_items -eq 0 ]
    set_color $fish_color_error[1]
    echo 'Bookmark list is empty. '(set_color normal)'Enter '(set_color $fish_color_command[1])'mark '(set_color normal)'in INSERT mode or '(set_color $fish_color_command[1])'m '(set_color normal)'in NORMAL mode, if you want to add the current directory to your bookmark list.'
    return
  end
  if begin
      [ (count $argv) -eq 1 ]
      and [ $argv[1] -ge 0 ]
      and [ $argv[1] -lt $num_items ]
    end
    cd $bookmarks[(expr $num_items - $argv[1])]
  else
    for i in (seq $num_items)
      if [ $PWD = $bookmarks[$i] ]
        set_color $barracuda_colors[10]
      else
        if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
          set_color normal
        else
          set_color $barracuda_colors[4]
        end
      end
      echo '▶ '(expr $num_items - $i)\t$bookmarks[$i] | sed "s|$HOME|~|"
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $barracuda_cursors[1]
    set input_length (expr length (expr $num_items - 1))
    read -p 'echo -n (set_color -b $barracuda_colors[2] $barracuda_colors[10])"  Goto [0"$last_item"] "(set_color -b normal $barracuda_colors[2])" "(set_color $barracuda_colors[10])' -n $input_length -l dir_num
    switch $dir_num
      case (seq 0 (expr $num_items - 1))
        cd $bookmarks[(expr $num_items - $dir_num)]
    end
    for i in (seq (expr $num_items + 1))
      tput cuu1
    end
    tput ed
    tput cuu1
  end
end

#############
# => Sessions
#############
function __barracuda_delete_zombi_sessions -d 'Delete zombi sessions'
  for i in $barracuda_sessions_active_pid
    if not contains $i %fish
      set -l item (contains -i $i $barracuda_sessions_active_pid)
      set -e barracuda_sessions_active_pid[$item]
      set -e barracuda_sessions_active[$item]
    end
  end
end

function __barracuda_create_new_session -d 'Create a new session'
  set -U barracuda_session_cmd_hist_$argv[1] $$cmd_hist
  set -U barracuda_session_dir_hist_$argv[1] $$dir_hist
  set -U barracuda_sessions $argv[1] $barracuda_sessions
end

function __barracuda_erase_session -d 'Erase current session'
  if [ (count $argv) -eq 1 ]
    set_color $fish_color_error[1]
    echo 'Missing argument: name of session to erase'
    return
  end
  if contains $argv[2] $barracuda_sessions_active
    set_color $fish_color_error[1]
    echo "Session '$argv[2]' cannot be erased because it's currently active."
    return
  end
  if contains $argv[2] $barracuda_sessions
    set -e barracuda_session_cmd_hist_$argv[2]
    set -e barracuda_session_dir_hist_$argv[2]
    set -e barracuda_sessions[(contains -i $argv[2] $barracuda_sessions)]
  else
    set_color $fish_color_error[1]
    echo "Session '$argv[2]' not found. "(set_color normal)'Enter '(set_color $fish_color_command[1])'s '(set_color normal)'to show a list of all recorded sessions.'
  end
end

function __barracuda_detach_session -d 'Detach current session'
  set cmd_hist cmd_hist_nosession
  set dir_hist dir_hist_nosession
  if [ -z $$dir_hist ] 2> /dev/null
    set $dir_hist $PWD
  end
  set dir_hist_val (count $$dir_hist)
  set -e barracuda_sessions_active_pid[$argv] 2> /dev/null
  set -e barracuda_sessions_active[$argv] 2> /dev/null
  set barracuda_session_current ''
  cd $$dir_hist[1][$dir_hist_val]
  set no_prompt_hist 'T'
end

function __barracuda_attach_session -d 'Attach session'
  set argv (echo -sn $argv\n | sed 's|[^[:alnum:]]|_|g')
  if contains $argv[1] $barracuda_sessions_active
    wmctrl -a " $argv[1]"
  else
    wt " $argv[1]"
    __barracuda_detach_session $argv[-1]
    set barracuda_sessions_active $barracuda_sessions_active $argv[1]
    set barracuda_sessions_active_pid $barracuda_sessions_active_pid %self
    set barracuda_session_current $argv[1]
    if not contains $argv[1] $barracuda_sessions
      __barracuda_create_new_session $argv[1]
    end
    set cmd_hist barracuda_session_cmd_hist_$argv[1]
    set dir_hist barracuda_session_dir_hist_$argv[1]
    if [ -z $$dir_hist ] 2> /dev/null
      set $dir_hist $PWD
    end
    set dir_hist_val (count $$dir_hist)
    cd $$dir_hist[1][$dir_hist_val] 2> /dev/null
  end
  set no_prompt_hist 'T'
end

function s -d 'Create, delete or attach session'
  __barracuda_delete_zombi_sessions
  if [ (count $argv) -eq 0 ]
    set -l active_indicator
    set -l num_items (count $barracuda_sessions)
    if [ $num_items -eq 0 ]
      set_color $fish_color_error[1]
      echo -n 'Session list is empty. '
      set_color normal
      echo -n 'Enter '
      set_color $fish_color_command[1]
      echo -n 's '
      set_color $fish_color_param[1]
      echo -n 'session-name'
      set_color normal
      echo ' to record the current session.'
      return
    end
    for i in (seq $num_items)
      if [ $barracuda_sessions[$i] = $barracuda_session_current ]
        set_color $barracuda_colors[8]
      else
        if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
          set_color normal
        else
          set_color $barracuda_colors[4]
        end
      end
      if contains $barracuda_sessions[$i] $barracuda_sessions_active
        set active_indicator ' '
      else
        set active_indicator ' '
      end
      echo '▶ '(expr $num_items - $i)\t$active_indicator$barracuda_sessions[$i]
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $barracuda_cursors[3]
    set input_length (expr length (expr $num_items - 1))
    read -p 'echo -n (set_color -b $barracuda_colors[2] $barracuda_colors[8])"  Attach [e|0"$last_item"] "(set_color -b normal $barracuda_colors[2])" "(set_color $barracuda_colors[8])' -n $input_length -l session_num
    set pcount (expr $pcount - 1)
    switch $session_num
      case (seq 0 (expr $num_items - 1))
        set argv[1] $barracuda_sessions[(expr $num_items - $session_num)]
        for i in (seq (expr $num_items + 1))
          tput cuu1
        end
        tput ed
        tput cuu1
      case 'e'
        read -p 'echo -n (set_color -b $barracuda_colors[2] $barracuda_colors[8])"  Erase [0"$last_item"] "(set_color -b normal $barracuda_colors[2])" "(set_color $barracuda_colors[8])' -n $input_length -l session_num
        if [ (expr $num_items - $session_num) -gt 0 ]
          __barracuda_erase_session -e $barracuda_sessions[(expr $num_items - $session_num)]
        end
        for i in (seq (expr $num_items + 3))
          tput cuu1
        end
        tput ed
        return
      case '*'
        for i in (seq (expr $num_items + 1))
          tput cuu1
        end
        tput ed
        tput cuu1
        return
    end
  end
  set -l item (contains -i %self $barracuda_sessions_active_pid 2> /dev/null)
  switch $argv[1]
    case '-e'
      __barracuda_erase_session $argv
    case '-d'
      wt 'fish'
      __barracuda_detach_session $item
      tput cuu1
      tput ed
      set pcount (expr $pcount - 1)
    case '-*'
      set_color $fish_color_error[1]
      echo "Invalid argument: $argv[1]"
    case '*'
      __barracuda_attach_session $argv $item
  end
end

#####################################
# => Commandline editing with $EDITOR
#####################################
function __barracuda_edit_commandline -d 'Open current commandline with your editor'
  commandline > $barracuda_tmpfile
  eval $EDITOR $barracuda_tmpfile
  set -l IFS ''
  if [ -s $barracuda_tmpfile ]
    commandline (sed 's|^\s*||' $barracuda_tmpfile)
  else
    commandline ''
  end
  rm $barracuda_tmpfile
end

########################
# => Virtual Env segment
########################
function __barracuda_prompt_virtual_env -d 'Return the current virtual env name or other custom environment information'
  if set -q VIRTUAL_ENV; or set -q barracuda_alt_environment
    set_color -b $barracuda_colors[9]
    echo -n ''
    if set -q VIRTUAL_ENV
      echo -n ' '(basename "$VIRTUAL_ENV")' '
    end
    if set -q barracuda_alt_environment
      echo -n ' '(eval "$barracuda_alt_environment")' '
    end
    set_color -b $barracuda_colors[1] $barracuda_colors[9]
  end
end

########################
# => Node version segment
########################
function __barracuda_prompt_node_version -d 'Return the current Node version'
  if set -q barracuda_alt_environment
    set_color -b $barracuda_colors[9]
    echo -n ''
    echo -n ' '(node -v)' '
    set_color -b $barracuda_colors[1] $barracuda_colors[9]
  end
end

################
# => Git segment
################
function __barracuda_prompt_git_branch -d 'Return the current branch name'
  set -l branch (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
  if not test $branch > /dev/null
    set -l position (command git describe --contains --all HEAD 2> /dev/null)
    if not test $position > /dev/null
      set -l commit (command git rev-parse HEAD 2> /dev/null | sed 's|\(^.......\).*|\1|')
      if test $commit
        set_color -b $barracuda_colors[11]
        switch $pwd_style
          case short long
            echo -n ''(set_color $barracuda_colors[1])' ➦ '$commit' '(set_color $barracuda_colors[11])
          case none
            echo -n ''
        end
        set_color normal
        set_color $barracuda_colors[11]
      end
    else
      set_color -b $barracuda_colors[9]
      switch $pwd_style
        case short long
          echo -n (set_color $barracuda_colors[1])'  '$position' '(set_color $barracuda_colors[9])
        case none
          echo -n ''
      end
      set_color normal
      set_color $barracuda_colors[9]
    end
  else
    set_color -b $barracuda_colors[3]
    switch $pwd_style
      case short long
        echo -n (set_color $barracuda_colors[1])'  '$branch' '(set_color $barracuda_colors[3])
      case none
        echo -n ''
    end
    set_color normal
    set_color $barracuda_colors[3]
  end
end

######################
# => Bind-mode segment
######################
function __barracuda_prompt_bindmode -d 'Displays the current mode'
  switch $fish_bind_mode
    case default
      set barracuda_current_bindmode_color $barracuda_colors[12]
      echo -en $barracuda_cursors[2](set_color $barracuda_colors[12])
    case insert
      set barracuda_current_bindmode_color $barracuda_colors[6]
      echo -en  $barracuda_cursors[1](set_color $barracuda_colors[6])
      if [ "$pwd_hist_lock" = true ]
        set pwd_hist_lock false
        __barracuda_create_dir_hist
      end
    case visual
      set barracuda_current_bindmode_color $barracuda_colors[12]
      echo -en $barracuda_cursors[3](set_color $barracuda_colors[10])
  end
  if [ (count $barracuda_prompt_error) -eq 1 ]
    set barracuda_current_bindmode_color $barracuda_colors[7]
  end
  set_color -b $barracuda_current_bindmode_color $barracuda_colors[1]
  switch $pwd_style
    case short long
      echo -n (set_color -o)" $pcount "(set_color normal)(set_color -b $barracuda_colors[5] $barracuda_current_bindmode_color)(set_color -b $barracuda_colors[5])(set_color -o 000)' }><(({º> '(set_color normal)(set_color -b $barracuda_colors[2])(set_color $barracuda_colors[5])      
  end
  set_color $barracuda_colors[5]
end

####################
# => Symbols segment
####################
function __barracuda_prompt_left_symbols -d 'Display symbols'
    set -l symbols_urgent 'F'
    set -l symbols (set_color -b $barracuda_colors[2])''

    set -l jobs (jobs | wc -l | tr -d '[:space:]')
    if [ -e ~/.taskrc ]
        set todo (task due.before:sunday 2> /dev/null | tail -1 | cut -f1 -d' ')
        set overdue (task due.before:today 2> /dev/null | tail -1 | cut -f1 -d' ')
    end
    if [ -e ~/.reminders ]
        set appointments (rem -a | cut -f1 -d' ')
    end
    if [ (count $todo) -eq 0 ]
        set todo 0
    end
    if [ (count $overdue) -eq 0 ]
        set overdue 0
    end
    if [ (count $appointments) -eq 0 ]
        set appointments 0
    end

    if [ $symbols_style = 'symbols' ]
        if [ $barracuda_session_current != '' ]
            set symbols $symbols(set_color -o $barracuda_colors[8])' '
            set symbols_urgent 'T'
        end
        if contains $PWD $bookmarks
            set symbols $symbols(set_color -o $barracuda_colors[10])' '
        end
        if set -q -x VIM
            set symbols $symbols(set_color -o $barracuda_colors[9])' V'
            set symbols_urgent 'T'
        end
        if set -q -x RANGER_LEVEL
            set symbols $symbols(set_color -o $barracuda_colors[9])' R'
            set symbols_urgent 'T'
        end
        if [ $jobs -gt 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[11])' '
            set symbols_urgent 'T'
        end
        if [ ! -w . ]
            set symbols $symbols(set_color -o $barracuda_colors[6])' '
        end
        if [ $todo -gt 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[4])
        end
        if [ $overdue -gt 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[8])
        end
        if [ (expr $todo + $overdue) -gt 0 ]
            set symbols $symbols' ⚔'
            set symbols_urgent 'T'
        end
        if [ $appointments -gt 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[5])' ⚑'
            set symbols_urgent 'T'
        end
        if [ $last_status -eq 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[12])' ✔'
        else
            set symbols $symbols(set_color -o $barracuda_colors[7])' ✘'
        end
        if [ $USER = 'root' ]
            set symbols $symbols(set_color -o $barracuda_colors[6])' ⚡'
            set symbols_urgent 'T'
        end
    else
        if [ $barracuda_session_current != '' ] 2> /dev/null
            set symbols $symbols(set_color $barracuda_colors[8])' '(expr (count $barracuda_sessions) - (contains -i $barracuda_session_current $barracuda_sessions))
            set symbols_urgent 'T'
        end
        if contains $PWD $bookmarks
            set symbols $symbols(set_color $barracuda_colors[10])' '(expr (count $bookmarks) - (contains -i $PWD $bookmarks))
        end
        if set -q -x VIM
            set symbols $symbols(set_color -o $barracuda_colors[9])' V'(set_color normal)(set_color -b $barracuda_colors[2])
            set symbols_urgent 'T'
        end
        if set -q -x RANGER_LEVEL
            set symbols $symbols(set_color $barracuda_colors[9])' '$RANGER_LEVEL
            set symbols_urgent 'T'
        end
        if [ $jobs -gt 0 ]
            set symbols $symbols(set_color $barracuda_colors[11])' '$jobs
            set symbols_urgent 'T'
        end
        if [ ! -w . ]
            set symbols $symbols(set_color -o $barracuda_colors[6])' '(set_color normal)(set_color -b $barracuda_colors[2])
        end
        if [ $todo -gt 0 ]
            set symbols $symbols(set_color $barracuda_colors[4])
        end
        if [ $overdue -gt 0 ]
            set symbols $symbols(set_color $barracuda_colors[8])
        end
        if [ (expr $todo + $overdue) -gt 0 ]
            set symbols $symbols" $todo"
            set symbols_urgent 'T'
        end
        if [ $appointments -gt 0 ]
            set symbols $symbols(set_color $barracuda_colors[5])" $appointments"
            set symbols_urgent 'T'
        end
        if [ $last_status -eq 0 ]
            set symbols $symbols(set_color $barracuda_colors[12])' '$last_status
        else
            set symbols $symbols(set_color $barracuda_colors[7])' '$last_status
        end
        if [ $USER = 'root' ]
            set symbols $symbols(set_color -o $barracuda_colors[6])' ⚡'
            set symbols_urgent 'T'
        end
    end
    set symbols $symbols(set_color $barracuda_colors[2])' '(set_color normal)(set_color $barracuda_colors[2])
    switch $pwd_style
        case none
            if test $symbols_urgent = 'T'
                set symbols (set_color -b $barracuda_colors[2])''(set_color normal)(set_color $barracuda_colors[2])
            else
                set symbols ''
            end
    end
    echo -n $symbols
end

###############################################################################
# => Prompt initialization
###############################################################################

# Initialize some global variables
set -g barracuda_prompt_error
set -g barracuda_current_bindmode_color
set -U barracuda_sessions_active $barracuda_sessions_active
set -U barracuda_sessions_active_pid $barracuda_sessions_active_pid
set -g barracuda_session_current ''
set -g cmd_hist_nosession
set -g cmd_hist cmd_hist_nosession
set -g CMD_DURATION 0
set -g dir_hist_nosession
set -g dir_hist dir_hist_nosession
set -g pwd_hist_lock true
set -g pcount 1
set -g prompt_hist
set -g no_prompt_hist 'F'
set -g symbols_style 'symbols'

# Load user defined key bindings
if functions --query fish_user_key_bindings
  fish_user_key_bindings
end

# Set favorite editor
if not set -q EDITOR
  set -g EDITOR nano
end

# Source config file
if [ -e $barracuda_config ]
  source $barracuda_config
end

# Don't save in command history
if not set -q barracuda_nocmdhist
  set -U barracuda_nocmdhist 'c' 'd' 'll' 'ls' 'm' 's'
end

# Set PWD segment style
if not set -q barracuda_pwdstyle
  set -U barracuda_pwdstyle short long none
end
set pwd_style $barracuda_pwdstyle[1]

# Cd to newest bookmark if this is a login shell
if not begin
    set -q -x LOGIN
    or set -q -x RANGER_LEVEL
    or set -q -x VIM
  end 2> /dev/null
  if not set -q barracuda_no_cd_bookmark
    if set -q bookmarks[1]
      cd $bookmarks[1]
    end
  end
end
set -x LOGIN $USER

###############################################################################
# => Custom functions
###############################################################################
function termux-backup -d 'Backup file system' --argument file_name

## Set defaults:

  [ $file_name ]; or set file_name 'Backup'

  set current_path (pwd)
  set tmp_dir $HOME/.backup_termux
  set -g bkup_dir $HOME/storage/shared/
  set -U termux_path (cd $HOME && .. && pwd)
  set bkup_date (date +%s)
  set file $file_name-$bkup_date
  set f_count (find . -type f | wc -l)

## Start backup:

#echo $f_count && sleep 10

  clear
  echo "home/storage/"\n"home/.backup_termux/"\n"home/exclude"\n"termux_backup_log.txt"\n".links" > home/exclude  
  if test -d $HOME/storage1
    if test -d $tmp_dir
      rsync -av --exclude-from 'home/exclude' $termux_path/ $tmp_dir/$file/ 2>> home/termux_backup_log.txt
      rm home/exclude && cd $tmp_dir && tar -czvf $file.tar.gz $file/ && rm -Rf $file/
      clear
      cp -rf $tmp_dir/ $bkup_dir/
      rm -Rf $tmp_dir
      cd $current_path
    else
      mkdir $tmp_dir
      rsync -av --exclude-from home/exclude $termux_path/ $tmp_dir/$file/ 2>> home/termux_backup_log.txt
      rm home/exclude && cd $tmp_dir && tar -czvf $file.tar.gz $file/ && rm -Rf $file/
      clear
      cp -rf $tmp_dir/ $bkup_dir/
      rm -Rf $tmp_dir
      cd $current_path
    end
  else
    mkdir $tmp_dir 2>/dev/null
    echo 'No EXTERNAL_STORAGE mounted.'\n'Backup has will be stored in User folder.'
    echo 'Try using '(set_color 777)'termux-setup-storage'(set_color normal) && echo
    rsync -av --stats --exclude-from 'home/exclude' $termux_path/ $tmp_dir/$file/ | pv -lpes (math $f_count + 10000) >/dev/null

    set f_count_tmp (find $tmp_dir -type f | wc -l)

#    rm home/exclude && cd $tmp_dir && tar -czvf $file.tar.gz $file/ | progress -mc tar && rm -Rf $file/
    rm home/exclude && cd $tmp_dir && tar -czf - $file/ | pv -leps $f_count_tmp > $file.tar.gz && rm -Rf $file/
    cd $current_path
  end
  termux-toast -b "#222222" -g top -c white All done\! System backup is finished.
end

###############################################################################
# => Left prompt
###############################################################################

function fish_prompt -d 'Write out the left prompt of the barracuda theme'
  echo
  fish_vi_key_bindings
  echo (set_color -b black)(set_color 777)''(set_color -b 777)(set_color 000) $PWD (set_color normal)(set_color 777)''
  set -g last_status $status
  echo -n -s (__barracuda_prompt_bindmode) (__barracuda_prompt_node_version) (__barracuda_prompt_git_branch) (__barracuda_prompt_left_symbols) (set_color normal)(set_color $barracuda_colors[2])
end

