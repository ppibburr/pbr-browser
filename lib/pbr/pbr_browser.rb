#
# -- File: lib/pbr/pbr_browser.rb
#

module PBR
  class Browser
    attr_reader :current, :window, :extensions
  
    def initialize(extensions=[])
      @on_view_removed_callbacks = []
      @on_new_view_callbacks     = []
      @extensions                = []
      
      @views   = []
      @current = 0
      @window  = Gtk::Window.new(:toplevel)
      
      @window.resize 1000,600
      @window.add @vbox = Gtk::VBox.new(false, 5) 
      
      @vbox.pack_start @content = Gtk::VBox.new(false, 5), true, true, 2      
      @vbox.pack_start @prompt = Gtk::Entry.new, false, true, 2
      @vbox.pack_start @status = Gtk::Label.new(""), false, true, 2       
      
      # Perform the action
      @prompt.signal_connect "activate" do
        send @current_prompt_action[:type], @prompt.get_text
        @current_prompt_action = {}
        @prompt.set_text ""
        @prompt.hide
      end
      
      # Dismiss the action
      @prompt.signal_connect "focus-out-event" do
        @prompt.set_text ""
        @current_prompt_action = {}
        @prompt.hide
        
        next false
      end
      
      # So some pages dont make our window super wide ...
      @window.set_size_request *@window.get_size      
    
      @window.show_all    
      @prompt.hide
      
      extensions.each do |e|
        PBR::Extension.load self, e   
      end
    end

    attr_reader :views

    def on_new_view &b
      @on_new_view_callbacks << b
    end
    
    def on_view_removed &b
      @on_view_removed_callbacks << b
    end
    
    def new_view()
      # Create the view
      @views << this = WebKit::WebView.new
      
      # Handle page title changes
      this.signal_connect "title-changed" do
        render_state()
      end
      
      # Handle open other window
      this.signal_connect "create-web-view" do
        v=views[i=new_view]
        set_current_view(i)
        v.to_ptr
      end   
  
      this.signal_connect "icon-loaded" do
        render_state()
      end
      
      this.signal_connect "notify::load-status" do
        case this.get_load_status
        when WebKit::LoadStatus::FINISHED        
          PBR::Extension.available_extensions.find_all do |e|
            is_a?(e)
          end.each do |e|
            if handle = e.get_load_finished_hook
              handle.call(self, this, frame = this.get_main_frame, frame.get_dom_document)
            end
          end
        end
      end

      @on_new_view_callbacks.each do |cb|
        cb.call this
      end      
      
      sw = Gtk::ScrolledWindow.new()
      sw.add this
      
      @content.pack_start(sw, true, true, 2)
    
      @views.index(this)
    end

    def current_view
      views[@current]
    end

    def next_view
      return unless current < views.length-1
      set_current_view i = current + 1      
      i
    end

    def prev_view
      return unless current > 0
      set_current_view i = current - 1
      i
    end

    def render_state
      if current_view.get_view_source_mode
        @window.set_title "View source: #{current_view.get_uri}"
      else
        @window.set_title "#{current_view.get_title}"
      end
      
      @window.set_icon current_view.try_get_favicon_pixbuf( 24,24)
      
      @status.set_label "#{current+1} / #{views.length} #{current_view.get_uri}"      
    end

    def set_current_view i
      current_view.get_parent.hide
      @current = i
        
      render_state()   
            
      current_view.get_parent.show_all
      i
    end

    def go_back
      current_view.go_back
    end

    def go_forward
      current_view.go_forward
    end
    
    def reload_view i = current
      view = views[i]
      view.reload()
    end

    def close_view
      return if views.length == 1

      o = current
      ov = current_view

      unless current == 0
        prev_view
      else
        next_view
      end
      
      c = current_view
      
      views[o].get_parent.destroy
      @views.delete ov 
      
      @on_view_removed_callbacks.each do |cb|
        cb.call ov
      end
      
      @current = views.index(c)
      
      render_state
      
      o
    end
    
    def view_source
      i = new_view
      
      v = views[i]
      
      v.set_view_source_mode(true)
      v.open current_view.get_uri
      
      set_current_view(i)
    end
    
    def save_page
      prompt_download current_view.get_uri, current_view.get_title
    end

    def show_prompt_for action, data = nil, default=""
      @prompt.show
      @prompt.grab_focus
      @prompt.set_text default
      @prompt.set_position -1      
      @current_prompt_action = { 
                                 :type => action,
                                 :data => data
                               }
    end
    
    def find str
      @finding = str
      current_view.mark_text_matches str, false, 0 
      current_view.set_highlight_text_matches(true);
      show_next_text_match(str)    
    end
    
    def show_next_text_match str=@finding
      current_view.search_text(str, false,true,true);      
    end
    
    def show_previous_text_match str=@finding
      current_view.search_text(str, false,false,true);      
    end
    
    def remove_text_match_higlighting
      @finding=nil
      current_view.set_highlight_text_matches(false);
    end    
    
    def prompt_find
      show_prompt_for(:find)
    end

    def prompt_navigate
      show_prompt_for(:navigate)
    end
    
    def prompt_navigate_new_tab
      show_prompt_for(:navigate_new_tab)
    end
    
    def prompt_navigate_with_current_location
      show_prompt_for(:navigate, nil, current_view.get_uri)
    end  

    # Navigate the current view to 'str'
    # if 'str' looks like an url, yet lacks a protocol prefix, 'http://' is prepended to str
    # if 'str' does not look like a url, we search google for 'str'
    #    note, only replaces spaces (' ') with '%20'
    def navigate str
      proto, addr = str.split("://")
      
      if proto and addr
        current_view.open(str)
      elsif str.index('.')
        str = "http://#{str}"
        current_view.open(str)
      else
        current_view.open("https://www.google.com/#q=#{str.split(" ").join("%20")}")    
      end
    end

    def navigate_new_tab str
      set_current_view i=new_view()
      navigate(str)
    end
  end
end

