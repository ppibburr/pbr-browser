task :mruby do
  File.open('mruby/build_config.rb',"w") do |f|
    f.puts open("build_config.rb").read
  end
  
  sh "cd mruby && rake clean"
  sh "cd mruby && rake"
end

task :mrblib do
  sh "mkdir -p ./build/mrblib"
  sh "mkdir -p ./build/include"
    
  out = [
    "./lib/pbr/setup.rb",
    "./lib/pbr/pbr_utils.rb",
    "./lib/pbr/pbr_browser.rb",
    "./lib/pbr/pbr_extension.rb",
    "./lib/pbr/pbr_custom_protocol.rb",
    "./lib/pbr/pbr_dom_event.rb",
    "./lib/pbr/pbr_dom_timer.rb"    
  ].map do |f|
    open(f).read
  end.join("\n\n")+

  Dir.glob("./lib/pbr/extensions/*rb").map do |f|
    open(f).read
  end.join("\n\n")+

  open('./bin/pbr-browser').read

  File.open('./build/mrblib/pbr-browser.rb',"w") do |f|
    f.puts "\n"+out
  end
  
  sh "mruby/bin/mrbc -B pbr_mrb -o ./build/include/pbr_mrb.h ./build/mrblib/pbr-browser.rb"  
end

task :pbr do
  sh "mkdir -p build/bin"

	sh "gcc -c ./src/pbr.c -Imruby/include -Ibuild/include -o ./build/pbr.o"
	sh "gcc -o ./build/bin/pbr ./build/pbr.o -lmruby -lm -Lmruby/build/host/lib -ldl -lffi -lpthread"
end

task :default => [:mruby, :mrblib, :pbr]

task :clean do
  sh "rm -rf ./build"
  sh "cd mruby && rake clean"
end
