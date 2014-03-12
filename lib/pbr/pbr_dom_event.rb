#
# -- File: lib/pbr/pbr_dom_event.rb
#

WebKit::DOMEvent

module PBR
  module DOMEvent
    module Target
      # maps windows to views, elements to windows
      @targets = {}
    
      # Sets an event listener on +ele+
      # A repeated call will overide the existing listener (added via this method)
      #
      # @param [WebKit::WebView] view, the view element +ele+ is in
      # @param [WebKit::DOMEventTarget] ele, the element to listen on
      # @paran [String] name, the name of the event to listen for
      # @yield [Boolean]
      # @yieldparam [WebKit::DOMEventTarget] target, the target of the event
      # @yieldparam [WebKit::DOMEvent], event, the event.
      def self.on(view, ele, name, &b)
        # Ensure that when the view is detroyed we unmanage the targets of it
        unless @targets[view]
          view.signal_connect "destroy" do
            @targets.delete(view)
          end
        end
        
        # Ensure that when the window of the element is unloaded, we unmanage targets of it
        unless (@targets[view] ||={})[(window=ele.get_owner_document.get_default_view).to_ptr.address]
          @targets[view][(window=ele.get_owner_document.get_default_view).to_ptr.address] = {}
        
          window.add_event_listener('unload', true) do
            @targets[view].delete(window.to_ptr.address)
            @targets.delete(view) if @targets[view].empty?()
          end
        end
        
        # Ensure only one listener
        unless @targets[view][window.to_ptr.address][ele]
          ele.add_event_listener(name, true) do |e, evt|
            @targets[view][window.to_ptr.address][ele].call(e, evt)
          end
        end
        
        # Update the listener
        @targets[view][window.to_ptr.address][ele] = b      
      end
    end
  end
end

