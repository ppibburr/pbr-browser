#
# -- File: lib/pbr/extensions/pbr_ext_key_bindings.rb
#

module PBR
  module Extension
    module KeyBindings
      PBR::Extension.register self    
    
      @bindings = {  
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
      }
      
      def self.extended q
        super
        self.init
        q.init_keybindings
      end
      
      def self.init
        super
      end
      
      def self.bindings
        @bindings
      end
      
      def self.edit m, b
        @bindings[m] = b
      end
      
      class << self
        alias :add_binding :edit
      end
      
      def self.get_binding keyval,mod
        p [keyval, mod] #if DEBUG[:KEYS]
        
        kb = @bindings.find do |m, b|
          q = b.split("-")
          key = q.pop
          mods = []
          q.each do |md|
            case md.to_s.downcase
            when 'ctrl'
              modifier = Gdk::ModifierType::CONTROL_MASK
            when 'alt'
              modifier = Gdk::ModifierType::MOD1_MASK
            when 'shift'
              modifier = Gdk::ModifierType::SHIFT_MASK
            else
              modifier = nil
            end 
            
            mods << modifier
          end
          
          l = nil
          for i in 0..mods.length-1
            l = mods[i]
            next unless i > 0
            
            l = l | mods[i-1]
          end
          l ||= 0
          key = key.upcase if mods.index(Gdk::ModifierType::SHIFT_MASK) and key.length == 1
          p [mods, mod, l, keyval, key, Gdk::keyval_from_name(key)] #if DEBUG[:KEYS]
          l == mod and keyval == Gdk::keyval_from_name(key)
        end
        
        if kb
          kb[0]
        end
      end
      
      def init_keybindings
        # Handles our key bindings
        @window.signal_connect "key-press-event" do |*o|
          e = o[0].get_struct
          
          if handle = get_binding(e[:keyval], e[:state])
            send handle
            next true
          end
          
          next false
        end      
      end
      
      def get_binding key, mod
        PBR::Extension::KeyBindings.get_binding key, mod
      end
    end    
  end
end

