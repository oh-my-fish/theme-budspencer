###############################################################################
#
# prompt theme name:
#   budspencer
#
# description:
#   a sophisticated airline/powerline theme
#
# author:
#   joseph tannhuber <sepp.tannhuber@yahoo.de>
#
# sections:
#   -> Welcome message
#
###############################################################################

####################
# => Welcome message
####################
function fish_greeting -d 'Show greeting in login shell.'
  if not set -q budspencer_nogreeting
    if begin
      not set -q -x LOGIN
      and not set -q -x RANGER_LEVEL
      and not set -q -x VIM
      end
      echo This is (set_color -b $budspencer_colors[2] $budspencer_colors[10])budspencer(set_color normal) theme for fish, a theme for nerds.
      echo Type (set_color -b $budspencer_colors[2] $budspencer_colors[6])»budspencer_help«(set_color normal) in order to see how you can speed up your workflow.
      end
  end
end
