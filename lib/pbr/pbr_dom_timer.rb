#
# -- File: lib/pbr/pbr_dom_timer
#

module PBR
  module DOMTimer
    # Ensure that the manager is managing +window+
    # Connect to the 'destroy' signal of +view+ to ensure +window+ gets unmanaged
    def self.ensure_window_managed(view, window)
      view.signal_connect "destroy" do
        get_manager.unmanage window
      end
      
      MANAGER.manage(window)
    end

    class Manager
      # @return [Array<WebKit::DOMDomWindow] Windows being managed
      def managed
        @managed ||= {}
      end
    
      # Is the +window+ managed?
      # @return [Boolean] true if so, false otherwise
      def managed? window
        !!(@managed ||= {})[window]
      end
    
      # Unmanages the +window+
      # Calls 'GLib::source_remove' on all GSourceFuncs (Timeout's, Interval's) added
      def unmanage window
        if h=managed[window]
          h[:source_funcs].each do |sf|
            sf.remove()
          end
          
          managed.delete window
        end
      end
      
      # Manages +window+
      # Creates a store of +window+ and all GSourceFuncs added (Interval's, Timeout's)
      def manage window
        unless managed?(window)
          managed[window] = {:source_funcs => []}
          
          window.add_event_listener("unload", true) do |evt|
            unmanage(window)
          end
        end
      end
    end
    
    MANAGER = Manager.new
    
    def self.get_manager
      MANAGER
    end
    
    class SourceFunc
      attr_reader :sid
      def remove
        GLib::source_remove sid
      end
    end
    
    # A wrapper around an GLib::Timeout that will repeat at an interval
    class Interval < SourceFunc
      # @param [WebKit::WebView] view, the view the window is in
      # @param [WebKitDOM::DomWindow] window, the window
      # @param [Integer] int, the interval to fire at
      # @yield [void]
      def initialize view, window, int, &b
        DOMTimer.ensure_window_managed(view, window)
        
        @sid = GLib::Timeout.add -1, int do
          # Do not call code unless the window is still managed
          next(false) unless DOMTimer.get_manager().managed?(window)
          
          b.call()
          
          # Repeat
          next true
        end
        
        # Map the GSourceFunc
        DOMTimer.get_manager().managed[window][:source_funcs] << self
      end
    end
    
    # An wrapper around a GLib::Timeout that fires once
    class Timeout < SourceFunc
      # @param [WebKit::WebView] view, the view the window is in
      # @param [WebKitDOM::DomWindow] window, the window
      # @param [Integer] int, the interval to fire at
      # @yield [void]  
      def initialize view, window, int, &b
        DOMTimer.ensure_window_managed(view, window)
        
        sid = GLib::Timeout.add -1, int do
          # Do not call code unless the window is still managed
          next(false) unless DOMTimer.get_manager().managed?(window)
          
          b.call()
          
          # Do not repeat
          next false
        end
        
        # Map the GSourceFunc
        DOMTimer.get_manager().managed[window][:source_funcs] << self
      end
    end
  end
end

