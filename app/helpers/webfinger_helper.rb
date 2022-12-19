module WebfingerHelper
  def webfinger!(uri)
    Webfinger.new(uri).perform
  end
end
