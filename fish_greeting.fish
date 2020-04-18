function fish_greeting -d "Welcome Message"
    set n (set_color normal)
    set h (set_color 999)
    set b (set_color -b black)(set_color b58900)''(set_color -b b58900)(set_color 000000) #083743)
    set t (set_color eee)
    set e (set_color normal)(set_color b58900)''(set_color normal)

    if test -e $termux_path/usr/bin/figlet
      set_color -o cb4b16
         figlet '    barracuda'
      set_color normal
    else
      echo (set_color b58900)''$n' Debe instalar '$h'figlet '(set_color normal)'para mostrar el logo.'\n'  Use el comando '$h'pkg install figlet'$n.
      echo
    end

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
    if test -e $termux_path/usr/bin/termux-toast
      termux-toast -b "#222222" -g top -c white \¡Bienvenido a Termux-Barracuda, Marvin\! \n \n '                             }><(({º>'
    end
end
