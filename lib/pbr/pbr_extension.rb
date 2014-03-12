#
# -- File: lib/pbr/extensions/pbr_extension.rb
#

module PBR
  module Extension
    @enabled    = []
    @extensions = []
  
    @local_path = PBR.build_filename(PBR.data_dir,"extensions")
    def self.local_path
      @local_path
    end
  
    begin
      PBR.mkdir(PBR::Extension.local_path)
    rescue PBR::FileExistsError
    end     
  
    def self.write
      PBR.write_file PBR.extensions_file_path, PBR.serialize(@enabled.map do |q| q.to_s end)
    end
  
    def self.load instance, extension
      instance.extend extension
      @enabled << extension
      write()
    end
    
    def self.unload extension
      @enabled.delete extension
      write()
    end
    
    def self.enabled? e
      !!@enabled.index(e)
    end    
    
    def self.register extension
      extension.extend PBR::Extension
      (@extensions ||= []) << extension
    end
    
    def self.available_extensions
      @extensions
    end
    
    def init
      @init = true
    end
    
    def write_config
      path = PBR.build_filename(PBR::Extension.local_path(), "#{self.to_s.split("::").last}.json")
      PBR.write_file(path, PBR.serialize(@config))
    end
    
    def load_config
      path = PBR.build_filename(PBR::Extension.local_path(), "#{self.to_s.split("::").last}.json")
      
      @config = PBR.deserialize PBR.read_file(path)
      @config = {} unless @config.is_a?(Hash)
    rescue
      @config = {}
    end
    
    def self.extended e
      begin
        e.load_config()
      rescue => e
      end
    end
    
    def config
      @config ||= {}
    end
    
    def depends *o
      p @depends = o
    end
    
    def get_depends    
      @depends ||= []
    end
    
    def self.get_dependencies e
      e = const_get(e) if e.is_a?(Symbol)
      
      e.get_depends
    end
    
    def self.get_dependencies_full e
      get_dependencies(e).push(*get_dependencies(e).map do |d|
        get_dependencies(d).map do |dd|
          get_dependencies_full(dd)
        end
      end).flatten
    end
    
    def self.get_dependents e
      available_extensions.find_all do |ext|
        ext = const_get(ext) if ext.is_a?(Symbol)
        ext.depends_on?(e)
      end
    end
    
    def self.get_dependents_full e
      get_dependents(e).push(*get_dependents(e).map do |d|
        p d
        p get_dependents(d)
        get_dependents(d).map do |dd|
          get_dependents_full(dd)
        end
      end).flatten
    end    
    
    def depends_on? e
      (get_depends).find do |qd|
      p qd
        if qd == e
          next true
        end
        
        qd = PBR::Extension.const_get(qd) if qd.is_a?(Symbol)
        if qd == e
          next true
        end
        p qd
        qd.depends_on?(e)
      end
    end
    
    def get_config_entry_value n
      config[n]['value']
    end
    
    def add_load_finished_hook &cb
      @load_finished = cb
    end
    
    def get_load_finished_hook
      @load_finished
    end
  end
end

