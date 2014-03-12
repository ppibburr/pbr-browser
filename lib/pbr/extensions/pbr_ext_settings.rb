#
# -- File: lib/pbr/extensions/pbr_ext_settings.rb
#

module PBR
  module Extension
    module Settings
      PBR::Extension.register self    
      
      depends :PBRProtocol
    
      def self.extended q
        super
        self.init
        q.init_settings()
      end
      
      add_load_finished_hook do |app, view, frame, document|
        next unless view.get_uri == "pbr://settings"
        
        handle = Proc.new  do |ele, evt|
          case ele.get_attribute('type')
          when "checkbox"
            val = !!ele.get_checked
          when "number"
            val = ele.get_value.to_i
          else
            val = ele.get_value
          end
        
          PBR::Extension::Settings.edit(ele.get_attribute("name"), val)
        end
        
        PBR.dom_input_hook view, frame, document, &handle
      end
      
      def init_settings
        PBR::Extension::Settings.init

        PBR::Extension::KeyBindings.add_binding :edit_settings, "Ctrl-e"

        on_new_view do |view|
          view.set_settings PBR::Extension::Settings.settings
        end
      end
    
      def self.init
        unless @properties
          @properties = WebKit::WebSettings.properties
          @base       = WebKit::WebSettings.new
        end
        
        PBR::Extension::PBRProtocol.add_page_header_item "Settings", "pbr://settings"
        
        PBR::Extension::PBRProtocol.routes["settings"] = self 
      end
      
      def self.settings
        @base
      end
      
      def self.edit name, val
        @base.set_property name, val
      end
      
      def self.display view, uri
        q = @properties.map do |n|
          p n
          p type  = @base.get_property_type(n)
          p value = @base.get_property(n)
          
          case type
          when :string
            input = "<input name=#{n} type=text value='#{value}'>"
          when :bool
            checked = !!value ? " checked=true" : ""
            input = "<input name=#{n} type=checkbox#{checked}>"
          else
            if type == :int32 or type == :int
              input = "<input name=#{n} type=number value=#{value}>"
            elsif type == :float
              input = "<input name=#{n} type=number value=#{value.round(2)} step=0.01>"
            end
          end
          
          "<div width=600px class=hbox><div class=right><small><b>#{n}</b></small></div><div class=left flex=1>  #{input}</div> </div>"
        end.join
        
        data = "<html><head><title>PBR: Settings</title><style>#{PBR::Extension::PBRProtocol::css_style}</style></head><body><div class=page>#{PBR::Extension::PBRProtocol::page_header}<div class=content>#{q}</div></div></body></html>"
        view.load_html_string data, uri
      end
      
      def edit_settings
        navigate "pbr://settings"
      end
    end
  end
end

