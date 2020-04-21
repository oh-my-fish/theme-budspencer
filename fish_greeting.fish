# -- Languages (SP-EN) --

  set -U g_lang_sp ' Documentación y Ayuda ' ' * Wiki:                   ' ' * Forum de la Comunidad:  ' ' * Chat en Gitter:         ' ' * Canal IRC:              ' ' Trabajo con paquetes ' ' * Buscar paquetes:        ' ' * Instalar un paquete:    ' ' * Actualizar un paquete:  ' ' Repositorios adicionales ' ' * Root:                   ' ' * Unstable:               ' ' * X11:                    ' 'Reporte cualquier problema en https://termux.com/issues ' '¡Bienvenido a Termux Barracuda, Marvin!'
  set -U g_lang_en ' Documents and help ' ' * Wiki:                   ' ' * Comunity Forum:         ' ' * Chat on Gitter:         ' ' * IRC Channel:            ' ' Working with packages ' ' * Search packages:        ' ' * Install packages:       ' ' * Update a package:       ' ' Extra repositories ' ' * Root:                   ' ' * Unstable:               ' ' * X11:                    ' 'Report any issue in https://termux.com/issues ' 'Welcome to Termux Barracuda, Marvin!'
  set -U g_lang_fr ' Documents et aide ' ' * Wiki:		      ' ' * Forum communautaire:	      ' ' * Chat sur Gitter:	      ' ' * Canal IRC:		      ' ' Travailler avec les packages ' ' * Rechercher les packages:   ' ' * Installer les packages:    ' ' * Mettre à jour un package:  ' ' Référentiels supplémentaires ' ' * Root:		      ' ' * Unstable:		      ' ' * X11:			      ' 'Signaler tout problème dans https://termux.com/issues ' 'Bienvenue à Termux Barracuda, Marvin!'

  if not set -q bg_lang
    set -U bg_lang $g_lang_sp
  end

function fish_greeting -d "Welcome Message"
    set n (set_color normal)
    set h (set_color 999)
    set b (set_color -b black)(set_color b58900)''(set_color -b b58900)(set_color 000000) #083743)
    set t (set_color eee)
    set e (set_color normal)(set_color b58900)''(set_color normal)
    set -g barracuda_version (echo (set_color -b 000 cb4b16)''(set_color -b cb4b16 -o 000)'v1.6'(set_color -b 000 cb4b16)''$n)

    set_color -o cb4b16
    tput cuu1 && tput cuu1
    echo " _                                         _       "
    echo "| |__   __ _ _ __ _ __ __ _  ___ _   _  __| | __ _ "
    echo "| '_ \ / _` | '__| '__/ _` |/ __| | | |/ _` |/ _` |"
    echo "| |_) | (_| | |  | | | (_| | (__| |_| | (_| | (_| |"
    echo "|_.__/ \__,_|_|  |_|  \__,_|\___|\__,_|\__,_|\__,_| $barracuda_version"
    echo \n
    set_color normal

    echo $b$bg_lang[1]$e
    echo
    echo $t$bg_lang[2]$h'https://wiki.termux.com'$n
    echo $t$bg_lang[3]$h'https://termux.com/community'$n
    echo $t$bg_lang[4]$h'https://gitter.im/termux/termux'$n
    echo $t$bg_lang[5]$h'#termux en freenode'$n
    echo
    echo $b$bg_lang[6]$e
    echo
    echo $t$bg_lang[7]$h'pkg search <query>'$n
    echo $t$bg_lang[8]$h'pkg install <package>'$n
    echo $t$bg_lang[9]$h'pkg upgrade'$n
    echo
    echo $b$bg_lang[10]$e
    echo
    echo $t$bg_lang[11]$h'pkg install root-repo'$n
    echo $t$bg_lang[12]$h'pkg install unstable-repo'$n
    echo $t$bg_lang[13]$h'pkg install x11-repo'$n
    echo

    echo $b$bg_lang[14]$e
    if test -e $termux_path/usr/bin/termux-toast
      termux-toast -b "#222222" -g top -c white "$bg_lang[15]" \n \n '                             }><(({º>'
    end
end
