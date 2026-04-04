{ den, ... }:
{
  den.aspects.ghostty.homeManager = { ... }: {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "FiraCode Nerd Font";
        font-size = 11;
        theme = "catppuccin-frappe";

        keybind = [
          "shift+enter=text:\\n"
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          "alt+t=new_tab"
          "alt+w=close_tab"
          "alt+1=goto_tab:1"
          "alt+2=goto_tab:2"
          "alt+3=goto_tab:3"
          "alt+4=goto_tab:4"
          "alt+5=goto_tab:5"
          "alt+shift+v=new_split:right"
          "alt+shift+s=new_split:down"
          "alt+h=goto_split:left"
          "alt+j=goto_split:down"
          "alt+k=goto_split:up"
          "alt+l=goto_split:right"
          "ctrl+alt+h=resize_split:left,10"
          "ctrl+alt+j=resize_split:down,10"
          "ctrl+alt+k=resize_split:up,10"
          "ctrl+alt+l=resize_split:right,10"
          "shift+page_up=scroll_page_up"
          "shift+page_down=scroll_page_down"
          "ctrl+equal=increase_font_size:1"
          "ctrl+minus=decrease_font_size:1"
          "ctrl+0=reset_font_size"
        ];
      };
    };
  };
}
