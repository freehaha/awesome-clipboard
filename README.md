#HOW TO USE
simply download clipboard.lua and place it into the same
directory with your rc.lua, import the library:
```lua
require("clipboard")
```
then add your custom key-bindings to trigger the clipboard
manager:
```lua
-- clipboard
-- {{{
awful.key({ modkey },            "c",     copy_to_clipboard),
awful.key({ modkey, "Shift"   }, "c",     clear_clipboard),
awful.key({ modkey },            "v",     clipboard_menu),
-- }}}
```
the default storage of the clipboard is ~/.sel and can be
changed in clipboard.lua to fit your need.

