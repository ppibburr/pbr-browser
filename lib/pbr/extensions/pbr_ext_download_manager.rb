#
# -- File: lib/pbr/extensions/pbr_ext_download_manager.rb
#

module PBR
  module Extension
    module DownloadManager
      PBR::Extension::register self
      
      depends :Downloads, :PBRProtocol
      
      class DownloadHistoryItem
        attr_accessor :get_uri, :get_destination_uri, :get_elapsed_time, :get_total_size, :get_current_size, :get_progress, :get_status
        def initialize i=nil
          return unless i
          
          [:get_uri, :get_destination_uri, :get_elapsed_time, :get_total_size, :get_current_size, :get_progress, :get_status].each do |m|
            self.send(:"#{m}=", i.send(m))
          end
        end
        
        def cancel
          
        end
      end
      
      @downloads = (0..4).map do
        di = DownloadHistoryItem.new
        di.get_uri = "http://foo.org/some/path.ext"
        di.get_destination_uri = "file:///home/foo/bar.ext"
        di.get_elapsed_time = 0
        di.get_progress = 0.0
        di.get_current_size = 0
        di.get_total_size = 1024
        di.get_status = WebKit::DownloadStatus::STARTED
        di
      end # the current downloads we are managing       
            
      def self.downloads
        @downloads
      end
    
      # handle a download
      def self.manage dl
        @downloads << dl
      end
    
      def self.unmanage dl
        @downloads.delete dl
      end
      
      def self.cancel_download di
        downloads[di].cancel
        downloads[di] = DownloadHistoryItem.new(downloads[di])
        downloads[di].get_status = WebKit::DownloadStatus::CANCELLED
      end
      
      def self.restart_download i
        odl = downloads[i]
        nr = WebKit::NetworkRequest.new(odl.get_uri)
        ndl = WebKit::Download.new(nr)
        @downloads[i] = ndl
        ndl.set_destination_uri odl.get_destination_uri 
        ndl.start
      end
    
      add_load_finished_hook do |app, view, frame, document|
        next unless view.get_uri == "pbr://downloads"

        DOMTimer::Interval.new view, document.get_default_view, 1000 do
          for i in 0..@downloads.length-1
            unless document.get_element_by_id("#{i}")
              view.reload
              next
            end
          
            if downloads[i].get_status == WebKit::DownloadStatus::STARTED
              DOMEvent::Target.on(view, document.get_element_by_id("#{i}_action"), "click") do |ele, evt|                 
                di=ele.get_attribute('id').split("_")[0].to_i
                cancel_download(di)
               
                #
                # Below code is to avoid having to perform a reload
                #
               
                ele.set_inner_text "Restart"
                s=document.get_element_by_id("#{di}_status")
                s.set_inner_text "Cancelled"
                s.set_attribute("class","cancelled")
                
                # Next click will restart the download
                DOMEvent::Target.on(view, ele, "click") do |ele,evt|
                  di=ele.get_attribute('id').split("_")[0].to_i
                  restart_download(di)
                  view.reload
                  false
                end
                
                false
              end        
            
              cs = document.get_element_by_id("#{i}_current_size")
              p  = document.get_element_by_id("#{i}_progress")
              tl = document.get_element_by_id("#{i}_remaining")
            
              t = @downloads[i].get_total_size
              c = @downloads[i].get_current_size
              e = @downloads[i].get_elapsed_time#+=1
              tp = c/e.to_f;
              r =  (t-c)/tp;
            
              pct = c/t.to_f
            
              amt = @downloads[i].get_current_size/1024.0
            
              p.set_inner_text("#{(100*pct).round(2)}%")
              cs.set_inner_text("#{amt.to_f.round(2)}Kb")
              tl.set_inner_text("#{r.to_f.round(2)}Secs")
              
            elsif (downloads[i].get_status != WebKit::DownloadStatus::CREATED) and (downloads[i].get_status != WebKit::DownloadStatus::FINISHED)
              DOMEvent::Target.on(view, document.get_element_by_id("#{i}_action"), "click") do |ele, evt|
                di=ele.get_attribute('id').split("_")[0].to_i
                restart_download(di)
              end
              
            elsif downloads[i].get_status == WebKit::DownloadStatus::FINISHED and (u=document.get_element_by_id("#{i}_status")).get_inner_text != "Complete"
              u.set_inner_html("<span class=complete>Complete</span>")
              document.get_element_by_id("#{i}_action").set_inner_text("")
            end
          end
        end
      end
      
      def download *o
        PBR::Extension::DownloadManager.manage @current_prompt_action[:data]   
        super
      end
    
      def self.extended q
        super
        init()
        q.init_downloads_manager
      end
      
      def self.init
        PBR::Extension::PBRProtocol.routes["downloads"] = self
        PBR::Extension::PBRProtocol.add_page_header_item("Downloads", "pbr://downloads")
      end
      
      def init_downloads_manager
        
      end
      
      def self.display view, uri
        local_css = "        
          .hbox * {
            overflow:hidden;
            text-overflow:ellipsis;
            white-space:nowrap;
          }
          
          .hbox:nth-child(odd) {
            background-color:#efefef;
          }         
        "+"
          .dl {
            margin-left:20px;
            margin-right:20px;
            padding-top:3px;
            margin-bottom:5px;
            border-bottom:solid 1px #ddd;
          }
          
          .dl:nth-child(even) {
          #  background-color:#f8f8f8;
          }
          
          .dl span {
            padding-right:15px;
          }
          
          .uri {
            overflow:hidden;
            cursor:pointer;
          }
         
          .basename {
            overflow:hidden;
          }         
        
          .dl {
            font-size:small;
          }
          
          .error {
            color:red;
          }
          
          .cancelled {
            color:green;
          }
          
          .complete {
            color:blue;
          }"+"
          
          .action {
            color:blue;
            margin-left:5px;
            padding-left:5px;
            cursor:pointer;
          }
         
         .left {       
            min-width:80px;
          }        
        "
      
        i = -1
        html = "<html><head><title>PBR: Downloads</title><style>#{PBR::Extension::PBRProtocol::css_style}#{local_css}</style></head><body><div class=page>#{PBR::Extension::PBRProtocol.page_header}<div class=content><div style='margin-top:20px;margin-bottom:12px;border-bottom:solid 1px #cfcfcf;'><b>Downloads</b></div>"+
        @downloads.map do |dl|
          action = "&nbsp;"
          i += 1        
          p [:DL,dl.get_total_size]
          in_progress = "<span><i>Size:</i></span> <span id=#{i}_size>"+
              (dl.get_total_size/1024.0).round(2).to_s+
            "Kb</span>"+ 
            "<span><i>Transfered:</i></span> <span id=#{i}_current_size>"+
              dl.get_current_size.to_s+
            "</span>"+ 
            "<span><i>Progress:</i></span> <span id=#{i}_progress>"+
              dl.get_progress.to_s+
            "</span>"+ 
            "<span><i>Time left:</i></span> <span id=#{i}_remaining>"+
            "</span>" 
          
          info = case dl.get_status
          when WebKit::DownloadStatus::STARTED
            action = "Cancel"
            in_progress                
          when WebKit::DownloadStatus::FINISHED
            "<span class=complete><i>Complete</i></span>"
          when WebKit::DownloadStatus::ERROR
            action = "Retry"
          
            "<span class=error><i>Error</i></span>"
          when WebKit::DownloadStatus::CANCELLED
            action = "Restart"
          
            "<span class=cancelled><i>Cancelled</i></span>"
          when WebKit::DownloadStatus::CREATED
            action = "Cancel"
            in_progress
          end

          "<div class=dl>"+
            "<div class=hbox>"+
              "<div class=right>"+
                "<span class=basename id=#{i}><b>"+      
                  PBR.get_basename(dl.get_destination_uri.to_s)+
                "</b></span>"+
                "<span class=uri><i>"+
                  dl.get_uri+
                "</i></span>"+
              "</div>"+
              "<div class=left>"+
                "<span class=action id=#{i}_action>#{action}</span>"+
              "</div>"+
            "</div>"+  
            "<div id=#{i}_status>"+
              info+
            "</div>"+
          "</div>"
        end.join+
        "</div></div></body></html>"
        
        view.load_html_string html, uri
      end
    end
  end
end

