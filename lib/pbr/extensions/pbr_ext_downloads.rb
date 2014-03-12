#
# -- File: lib/pbr/extensions/pbr_ext_downloads.rb
#

module PBR
  module Extension
    module Downloads
      PBR::Extension.register self    
    
      config['default_download_path'] ||= {'type'=>"text", 'value'=>"#{PBR::get_home_dir()}"}
    
      def self.extended q
        super
        self.init
        q.init_downloads
      end
      
      def init_downloads
        on_new_view do |view|
          # Handle requests for mime types that can be shown
          # We download them 
          view.signal_connect "mime-type-policy-decision-requested" do |f,r,mt,pd,*o|
            if view.can_show_mime_type(mt)
              pd.use()
            else
              pd.download()
            end
            
            true
          end    
          
          # Handle download requests
          view.signal_connect "download-requested" do |dl,*o|        
            # Perform the download
            prompt_download(dl, dl.get_suggested_filename)
            true
          end          
        end
      end
    
      # Download uri to path
      # Webkit::Download had problems on 64bit, we use libsoup.
      def download path
        dl = @current_prompt_action[:data]
        return unless (path and dl)
      
        dl.set_destination_uri("file://#{path}")
        dl.start()
      end    
      
      def prompt_download(dl, fn)
        path = PBR::Extension::Downloads.get_config_entry_value('default_download_path')+"/#{fn}"
        show_prompt_for(:download, dl, path) 
      end  
    end
  end
end

