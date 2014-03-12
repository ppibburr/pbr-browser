
module PBR
  module CustomProtocol
    def show_error view, uri
      view.load_html_string("<html><head><title>PBR: Request Error</title></head><body>The URI: #{uri} is invalid,</body></html>","#{uri}") 
    end 
    
    def get_route_handler uri
      proto, addr = uri.split("://")

      (@routes ||= {})[addr]    
    end    
    
    def request view,uri
      if h=get_route_handler(uri)
        h.display view, uri
      else
        show_error(view, uri)
      end
    end
    
    def routes
      @routes ||= {}
    end
    
    def self.add_protocol name, handler
      (@protocols ||= {})[name] = handler
    end
    
    def self.protocols
      @protocols ||= {}
    end
  end
end
