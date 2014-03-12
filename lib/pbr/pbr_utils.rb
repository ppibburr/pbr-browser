#
# -- File: lib/pbr/pbr_utils.rb
#

module PBR
  def self.get_home_dir
    GLib.get_home_dir()
  end
  
  def self.data_dir
    @data_dir ||= PBR.build_filename(PBR.get_home_dir,".pbr")
  end

  def self.get_last_extensions
    begin
      e = deserialize(read_file(PBR.extensions_file_path))
    rescue
      e = []
    end
    
    e = [] unless e.is_a?(Array)
    e = e.map do |s|
      l = ::Object
      s.split("::").each do |q|
        l = l.const_get(q.to_sym)
      end    
      
      l  
    end
    
    return e
  end

  def self.get_basename path
    GLib::path_get_basename path
  end
  
  def self.build_filename *o
    o.push(nil)
    
    GLib.build_filenamev o
  end
  
  class FileExistsError < Exception
  end
  
  def self.mkdir path, mode = 0700
    if GLib::file_test path, GLib::FileTest::EXISTS
      raise FileExistsError.new("File exits: #{path}")
    end
    
    unless GLib.mkdir path, mode
      raise UnhandledDirectoryCreateError("Creating: #{path} with mode: #{mode}, failed")
    end
    
    true
  end
  
  @extensions_file_path = PBR.build_filename(PBR.data_dir, "extensions.json")
  def self.extensions_file_path
    @extensions_file_path
  end
  
  begin
    PBR.mkdir(PBR.data_dir)
  rescue FileExistsError
  end

  def self.write_file path, body
    GLib::File.set_contents(path, body)
  end
  
  def self.read_file path
    GLib::File.get_contents(path)
  end
  
  def self.read_uri uri
    @soup_session ||= Soup::Session.new
    msg = Soup::Message.new_from_uri("GET",Soup::URI.new("#{uri}"))
    msg.set_request("text/plain",Soup::MemoryUse::COPY,"",0)

    @soup_session.send_message(msg)

    body = Soup::MessageBody.wrap(msg.get_property("response-body"))
    body = body.flatten.get_as_bytes.get_data().map do |b| b.chr end.join()
    
    return body
  end
  
  def self.serialize o
    if MRUBY
      JSON.stringify o
    else
      o.to_json
    end
  end
  
  def self.deserialize str
    JSON.parse str
  end  
  
  def self.dom_input_hook view, frame, document, &handle
    if (inputs = document.get_elements_by_tag_name("INPUT"))
      for i in 0..inputs.get_length-1
        input = inputs.item(i)
        
        input.add_event_listener "blur", true, &handle
        
        case input.get_attribute('type')
        when "text"
        else
          input.add_event_listener "change", true, &handle
        end
      end
    end  
  end
end

