wk = nil

ARGV.each do |a|
  if a == "--WEBKITGTK_1"
    ARGV.delete a
    wk = 1.0
  elsif a == "--WEBKITGTK_3"
    ARGV.delete a
    wk = 3.0  
  else
    wk = nil
  end
end

unless wk
  GirFFI.setup(:WebKit)
else
  GirFFI.setup(:WebKit, wk)  
end
