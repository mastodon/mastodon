module TestData
  def attachment(options={})
    Paperclip::Attachment.new(:avatar, FakeModel.new, options)
  end

  def stringy_file
    StringIO.new('.\n')
  end

  def fixture_file(filename)
    File.join(File.dirname(__FILE__), 'fixtures', filename)
  end
end
