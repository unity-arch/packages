# unity only, the module hooks every GtkMenuShell and strips it out of the
# window, so loading it under gnome or kde would eat their menus for nothing
case ":${XDG_CURRENT_DESKTOP}:${DESKTOP_SESSION}:" in
  *:[Uu]nity:*)
    case ":${GTK_MODULES}:" in
      *:unity-gtk-module:*) ;;
      *) export GTK_MODULES="${GTK_MODULES:+${GTK_MODULES}:}unity-gtk-module" ;;
    esac
    ;;
esac
