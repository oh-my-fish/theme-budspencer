<<<<<<< HEAD
function fish_greeting -d "Welcome Message"
    set n (set_color normal)
    set h (set_color 999)
    set b (set_color -b black)(set_color b58900)''(set_color -b b58900)(set_color 000000) #083743)
    set t (set_color eee)
    set e (set_color normal)(set_color b58900)''(set_color normal)

    set_color -o cb4b16
         figlet '    barracuda'
    set_color normal

    echo
    echo $b' Documentación y Ayuda '$e
    echo
    echo $t' * Wiki:                   '$h'https://wiki.termux.com'$n
    echo $t' * Forum de la Comunidad:  '$h'https://termux.com/community'$n
    echo $t' * Chat en Gitter:         '$h'https://gitter.im/termux/termux'$n
    echo $t' * Canal IRC:              '$h'#termux en freenode'$n
    echo
    echo $b' Trabajo con paquetes '$e
    echo
    echo $t' * Buscar paquetes:        '$h'pkg search <query>'$n
    echo $t' * Instalar un paquete:    '$h'pkg install <package>'$n
    echo $t' * Actualizar un paquete:  '$h'pkg upgrade'$n
    echo 
    echo $b' Repositorios adicionales '$e
    echo
    echo $t' * Root:                   '$h'pkg install root-repo'$n
    echo $t' * Unstable:               '$h'pkg install unstable-repo'$n
    echo $t' * X11:                    '$h'pkg install x11-repo'$n
    echo

    echo $b'Reporte cualquier problema en https://termux.com/issues '$e

    termux-toast -b "#222222" -g top -c white \¡Bienvenido a Termux, Marvin\! \n \n '                  }><(({º>'
end

=======
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
>>>>>>> bd36f622b1a3ebef370df1d954e028c284126899
