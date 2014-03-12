pbr-browser
===========

Slim WebKit based browser and browser library written in ruby  

* Keyboard driven
* UI elements remain hidden until they are needed, then hidden again when done
* Supports multiple views

Features
===
* The PBR library (implement your own browser)
* Extension system

Extensions
===
Here is a list of extensions maintained in this project.  
The browser application includes these by default.  

* KeyBindings (core)
* URIScheme (base)
* PBRProtocol (base)
* Downloads (base)
* History (default)
* Settings (default)
* KeyBindingsConfig (default)
* DownloadManager (default)

Key Bindings
===
```ruby
:prompt_navigate                        => 'Ctrl-o',
:prompt_navigate_with_current_location  => 'Ctrl-Shift-o',
:prompt_navigate_new_tab                => 'Ctrl-t',
:close_view                             => 'Ctrl-w',
:reload_view                            => 'Ctrl-r',   
:save_page                              => 'Ctrl-s', 
:prompt_find                            => 'Ctrl-f',  
:remove_text_match_higlighting          => 'F1',
:show_previous_text_match               => 'F2', 
:show_next_text_match                   => 'F3',                               
:view_source                            => 'F4',             
:reload_view                            => 'F5',            
:go_back                                => 'Ctrl-Left',
:go_forward                             => 'Ctrl-Right',

:prev_view                              => 'Ctrl-Shift-Left',
:next_view                              => 'Ctrl-Shift-Right'
```

NOTES
===
* Uses GirFFI (currently only mruby-girffi is supported)
* Recommend libwebkitgtk-1.0 as it supports flash (libwebkitgtk-3.0 works aside from flash)
 
