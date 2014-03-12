#
# -- File: lib/pbr/extensions/pbr_ext_pbr_protocol.rb
#

module PBR
  module Extension
    module PBRProtocol
      PBR::Extension.register self    
      
      depends :URIScheme
    
      add_load_finished_hook do |app, view, frame, document|
        next unless view.get_uri == "pbr://pbr"
      
        handle = Proc.new do |ele, event|
          n = ele.get_attribute("name")
          e = ele.get_attribute("extension")
         
          l = ::Object
          e = n if e == ""

          e.split("::").each do |q|
            l = l.const_get(q.to_sym)
          end
          
          if ele.get_attribute("extension") == ""
            bool=ele.get_checked
            next if bool == PBR::Extension.enabled?(l)
          
            if bool
              unless (list = PBR::Extension.get_dependencies_full(l)).empty?
                document.get_default_view.confirm("The following extensions will also be loaded:\r\n"+list.join(" "))
              end
              
              PBR::Extension.load app, l
              next
            end
            
            if PBR::PbrBrowser::CORE.index(l)
              document.get_default_view.alert("REFUSED!!\r\nNow WHY would you unload that one?!, its essential!")
              ele.set_checked(true)
              next
            end
            
            if PBR::PbrBrowser::BASE.index(l)
              if document.get_default_view.confirm("You are about to UNLOAD a BASE extension!\r\nYour browsing experiance WILL become VERY limited.")
              else
                ele.set_checked(true)
                next
              end
            elsif PBR::PbrBrowser::DEFAULT.index(l)
              if document.get_default_view.confirm("You are about to UNLOAD a DEFAULT extension!\r\nYour browsing experiance may become limited.")
              else
                ele.set_checked(true)
                next
              end            
            end            
          
            depends = PBR::Extension.get_dependents_full(l)
            
            unless depends.empty?
              if document.get_default_view.confirm("The following extensions will also be unloaded ...\r\n#{depends.join(" ")}")
                depends.each do |d|
                  PBR::Extension.unload d
                end
              else
                ele.set_checked(true)
                next
              end
            end
            
            PBR::Extension.unload l
            
            document.get_default_view.alert("Extension has been unloaded.\r\nIt is recommended to restart to ensure full unload.")
            view.reload
            next
          else
            case ele.get_attribute("type")
            when "text"
              l.config[n]['value'] = ele.get_value
            when "number"
              l.config[n]['value'] = ele.get_value.to_i
            when "checkbox"
              l.config[n]['value'] = ele.get_checked
            else
            end
            
            l.write_config
          end
        end
        
        PBR.dom_input_hook view,frame,document,&handle
      end
    
      extend PBR::CustomProtocol
    
      def self.extended q
        super
        self.init
      end
      
      def self.init
        super
        
        CustomProtocol.add_protocol("pbr", PBRProtocol)
      end
    
      @page_header_items = {"PBR"=>"pbr://pbr"}
            
      @css_style = "body {
                 background-color:#cfcfcf;
               }
                 
               .page {
                 background-color:white;
                 margin:30 10 30 10;
                 border-radius:5px;
                 border:solid 1px gray; 
                 min-height:95%; 
               }
               
               .content {
                 margin: 5 40 0 40;
               }
               
               td { overflow: hidden; border-bottom:solid 1px #cecece;}
               
               #header {
                 border-bottom: solid 1px #cecece;
                 margin: 20 30 0 30; 
                 padding-left:15px;
               }
               
               #header a {
                 padding-left:15px;
               }
               
               a {text-decoration:none; color:#000;}
               a:visited {color:#000;}
              "+"
                .hbox {
                  display: -webkit-box;             /* WebKit */

                  -webkit-box-orient: horizontal;   /* WebKit */  
                  
                  border-bottom:solid 1px #cecece;   
                  height:26px;    
                }
                  
                .hbox:nth-child(odd) {
                  background-color:#F8F8F8;
                }  
                  
                .right {
                  -webkit-box-flex:1;
                
                  padding-top:5px;
                }
                
                .left {
                  -webkit-box-flex:0;
                
                  padding-top:5px;
                }
                
                .hbox input[type=text] {
                  margin-top:-3px;
                }
                
                .hbox input[type=number] {
                  margin-top:-3px;
                }                                
              "
              
      routes["pbr"] = self
      
      def self.css_style
        @css_style
      end
      
      def self.page_header
        "<div id=header>"+
        @page_header_items.map do |name, uri|
          "<a href=#{uri}><b>#{name}</b></a>"
        end.join(" ")+"</div>"
      end
      
      def self.add_page_header_item name,uri
        @page_header_items[name] = uri
      end
      
      def self.display view, uri
        html = "<html><head><title>PBR: PBR</title><style>#{css_style}</style></head><body><div class=page>#{page_header}<div class=content>"+
        "<pre>"+
        "PBR (PpiBbuRr's Browser in Ruby)\n"+
        "(c) 2014 ppibburr (tulnor33@gmail.com)\n"+
        "\n"+
        "A lightweight WebKit based, key driven browser with minimal UI\n"+
        "</pre><br>"+
        "<div style='border-bottom:solid 1px #cfcfcf; margin-bottom:12px;'>Extensions:</div><div style='margin-left:20px;margin-right:20px;'>"+ 
    
        PBR::Extension.available_extensions.map do |e|
          "<div><div class='hbox' style='background-color:#dfdfdf;'><div class=right><b>#{e.to_s.split("::").last}</b></div><div class=left><input name='#{e}' type=checkbox#{PBR::Extension.enabled?(e) ? " checked=true" : ""}></input></div></div>"+
          e.config.map do |n, h| 
            unless h['type'] == "checkbox"
              default = " value=#{h['value']}"
            else
              default = " checked=#{!!h['value']}"
            end
            
            input = "<input extension='#{e}' type=#{h['type']} name=#{n}#{default}>"
            "<div class='hbox config_entry'><div class=right><small><b>#{n}</b></small></div><div class=left>#{input}</div></div>"
          end.join+
          "</div>"
        end.join+
        "</div></div></div></body></html>"
        
        view.load_html_string html,uri
      end
    end
  end
end

