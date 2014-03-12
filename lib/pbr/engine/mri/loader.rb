require 'json'

ARGV << '--GFFI_GLIB'

require "../mruby-girffi/tools/mri/loader.rb"

require "../lib/pbr/setup.rb"

require "../lib/pbr/pbr_utils.rb"
require "../lib/pbr/pbr_browser.rb"
require "../lib/pbr/pbr_extension.rb"
require "../lib/pbr/pbr_custom_protocol.rb"
require "../lib/pbr/pbr_dom_event.rb"
require "../lib/pbr/pbr_dom_timer.rb"

Dir.glob("../lib/pbr/extensions/*rb").each do |ext|
  require ext
end

Dir.glob("#{PBR::Extension.local_path}/*rb").each do |ext|
  require ext
end
