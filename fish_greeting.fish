function fish_greeting -d 'Show greeting in login shell.'
  if not set -q barracuda_nogreeting
    if begin
      not set -q -x LOGIN
      and not set -q -x RANGER_LEVEL
      and not set -q -x VIM
      end
      echo This is (set_color -b $barracuda_colors[2] $barracuda_colors[10])barracuda(set_color normal) theme for fish, a theme for nerds.
      echo Type (set_color -b $barracuda_colors[2] $barracuda_colors[6])»barracuda_help«(set_color normal) in order to see how you can speed up your workflow.
      end
  end
end
