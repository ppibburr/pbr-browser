#
# -- File: lib/pbr/extensions/pbr_ext_history.rb
#

module PBR
  module Extension
    module History
      PBR::Extension.register self    
      
      depends PBRProtocol
      
      config['max_items'] ||= {'type'=>"number", 'value'=>500}
      config['persists']  ||= {'type'=>"checkbox", 'value'=>true}     
    
      def self.extended q
        super
        self.init
        q.init_history
      end
      
      class << self
        attr_reader :history_file 
      end
      
      def self.init   
        return if @init
        super
        
        path = PBR.build_filename(PBR::Extension.local_path(), "History")
        
        begin
          PBR.mkdir(path)
        rescue PBR::FileExistsError
        end
        
        @history_file = PBR.build_filename(path, "history.json") 
        
        PBR::Extension::PBRProtocol.add_page_header_item "History", "pbr://history"
        PBR::Extension::PBRProtocol.routes["history"] = PBR::Extension::History
      end
      
      def init_history
        on_new_view do |view|
          view.signal_connect "notify::load-status" do |*o|
            case view.get_load_status
            when WebKit::LoadStatus::COMMITTED
              PBR::Extension::History.update_history(view)
            end
          end
          
          view.signal_connect "title-changed" do
            PBR::Extension::History.update_history(view)
          end
        end
      end
      
      def self.display view, uri
      p 99
      p history_file
      p PBR.read_file(history_file)
        data = JSON.parse(PBR.read_file(history_file))
        
        local = "
          .hbox div {
            max-width:50%;
            min-width:50%;
            overflow:hidden;
            white-space:nowrap;
          }
        
        "
        
        html = "<html><head><title>PBR: History</title><style>#{PBR::Extension::PBRProtocol::css_style}#{local}</style></head><body><div class=page>#{PBR::Extension::PBRProtocol.page_header}<div class=content>"+data.sort do |a,b|
          a[1]["visited"] <=> b[1]["visited"]
        end.reverse.map do |uri, h|
          "<div class=hbox><div class=right><b><small><a href='#{uri}'>#{h["title"].to_s == "" ? "Untitled" : h["title"]}</a></b></small></div><div class=left><small><i><a href='#{uri}'>#{uri}</a></i></small></div></div>"
        end.join()+"</div></body></html>"
        
        view.load_html_string(html, uri)
      end
      
      def self.update_history view
        return if view.get_settings.get_property('enable-private-browsing')
        begin
          history = JSON.parse(PBR.read_file(history_file))
        rescue
          history = {}
        end
        history[view.get_uri] = {:visited=>Time.now.to_f, :title=>view.get_title}
        out = PBR.serialize(history)
        
        PBR.write_file history_file, out
      end
    end    
  end
end

