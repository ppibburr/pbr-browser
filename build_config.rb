MRuby::Build.new do |conf|
  # load specific toolchain settings

  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  # include the default GEMs 
  conf.gembox 'default'
  
  conf.gem :github => 'mattn/mruby-json', :branch => 'master'  
  conf.gem :github => 'ppibburr/mruby-allocate', :branch => 'master'    
  conf.gem :github => 'ppibburr/mruby-named-constants', :branch => 'master' 
  conf.gem :github => 'mobiruby/mruby-cfunc', :branch => 'master'
  conf.gem :github => 'ppibburr/mruby-rubyffi-compat', :branch => 'master'
  
  conf.gem '../mruby-gobject-introspection'   
  conf.gem '../mruby-girffi'  
  conf.gem '../mruby-glib2' 
  conf.gem '../mruby-gobject'
  conf.gem '../mruby-javascriptcore'
  
  #conf.gem :github => 'mattn/mruby-require', :branch => 'master'      
end

