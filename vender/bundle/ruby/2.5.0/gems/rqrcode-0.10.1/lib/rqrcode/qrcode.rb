Dir[File.dirname(__FILE__) + "/qrcode/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "rqrcode/qrcode/#{filename}"
end
