#
# -- File: lib/pbr/extensions/pbr_ext_uri_scheme.rb
#

module PBR
  module Extension
    module URIScheme
      PBR::Extension.register self
    
      def self.extended q
        super
        self.init
        q.init_uri_scheme 
      end
      
      def init_uri_scheme
        @view_is_loading_custom_uri                          = {} # Store of views loading a custom protocol uri
        back_forward = @view_is_traversing_back_forward_list = {} # Stroe of views traversing thier back/forward list
         
        on_new_view do |view|
          # Bind the :go_back method
          unless view.respond_to?(:go_back)
            view.class.bind_instance_method(:go_back, view.class.find_function(:go_back))
          end
          
          unless view.respond_to?(:go_forward)
            view.class.bind_instance_method(:go_forward, view.class.find_function(:go_forward))
          end          
          
          # Overide the :go_back method to update the store of views traversing thier back/forward list
          view.singleton_class.class_eval do
            alias :_go_back_ :go_back
            
            define_method :go_back do
              back_forward[view] = true
              _go_back_()
            end
            
            alias :_go_forward_ :go_forward
            
            define_method :go_forward do
              back_forward[view] = true
              _go_forward_()
            end            
          end
        
          # Determine if the view is requesting a custom protocol, if so, call its handler
          view.signal_connect "navigation-policy-decision-requested" do |*o|
            # Have a handler
            if h=handle(o[1].get_uri)
              if @view_is_loading_custom_uri[view]
                if @view_is_traversing_back_forward_list[view]
                  # Do not add history item
                  
                  @view_is_traversing_back_forward_list.delete view
                else
                  # Add a history item
                  bfl  = view.get_back_forward_list
                  item = WebKit::WebHistoryItem.new_with_data(o[1].get_uri, "")
                  bfl.add_item(item)
                end
                
                # Remove the loading custom uri status
                @view_is_loading_custom_uri.delete view
                
                next(true) 
              end
            
              @view_is_loading_custom_uri[view] = true
            
              h.request view, o[1].get_uri

              false
            else
              false
            end
          end
        end
      end
      
      # @return [Symbol] the method name of the handle for +uri+.
      def handle uri
        proto, addr = uri.split("://")
        
        return unless proto and uri
        
        if h=PBR::CustomProtocol.protocols[proto]
          return h
        end
      end
    end
  end
end

