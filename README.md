pbr-browser
===========

Slim WebKit based browser written in ruby  

* Keyboard driven
* UI elements remain hidden until they are needed, then hidden again when done
* Supports multiple views
* Supports downloading

NOTES
===
* Uses GirFFI (currently only mruby-girffi is supported)
* Recommend libwebkitgtk-1.0 as it supports flash (libwebkitgtk-3.0 works aside from flash)
 
Key Bindings
===
* F5 Reload
* Ctrl-o Open location or perform search
* Ctrl-Shift-o Open location with current uri filled in
* Ctrl-t Open location or search in new view
* Ctrl-Left Go back in history
* Ctrl-Right Go forward in history
* Ctrl-Shift-Left Display previous view
* Ctrl-Shift-Right Display next view
* Ctr
