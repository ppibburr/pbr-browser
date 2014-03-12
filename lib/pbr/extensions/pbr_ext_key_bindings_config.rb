#
# -- File: lib/pbr/extensions/pbr_ext_key_bindings_config.rb
#

module PBR
  module Extension
    module KeyBindingsConfig
      PBR::Extension.register self
      
      depends :KeyBindings, :PBRProtocol
    
      add_load_finished_hook do |app, view, frame, document|
        next unless view.get_uri == "pbr://keys"
        
        handle = Proc.new  do |ele, evt|
          PBR::Extension::KeyBindings.edit(ele.get_attribute("name"), ele.get_value)
        end
        
        PBR.dom_input_hook view, frame, document, &handle        
      end
      
      def self.extended q
        super
        self.init
      end
      
      def self.init
        return if @init
        
        super
        
        PBR::Extension::PBRProtocol.add_page_header_item "KeyBindings", "pbr://keys"
        PBR::Extension::PBRProtocol.routes["keys"] = self
      end       
    
      def self.display view,uri
        q=KeyBindings.bindings.map do |m, b|
          "<div class=hbox><div class=right><b><small>#{m}</small></b></div><div class=left><input name=#{m} value='#{b}' type=text></input></div></div>"
        end.join
        
        data = "<html><head><title>PBR: KeyBindings</title><style>#{PBR::Extension::PBRProtocol::css_style}</style></head><body><div class=page>#{PBR::Extension::PBRProtocol::page_header}<div class=content>#{q}</div></div></body></html>"
        
        view.load_html_string data,uri
      end
    end
  end
end

