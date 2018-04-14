module AttachmentHelpers
  def fixture_path(filename)
    File.expand_path("#{PROJECT_ROOT}/spec/support/fixtures/#{filename}")
  end

  def attachment_path(filename)
    File.expand_path("public/system/attachments/#{filename}")
  end
end
World(AttachmentHelpers)

When /^I modify my attachment definition to:$/ do |definition|
  content = cd(".") { File.read("app/models/user.rb") }
  name = content[/has_attached_file :\w+/][/:\w+/]
  content.gsub!(/has_attached_file.+end/m, <<-FILE)
      #{definition}
      do_not_validate_attachment_file_type #{name}
    end
  FILE

  write_file "app/models/user.rb", content
  cd(".") { FileUtils.rm_rf ".rbx" }
end

When /^I upload the fixture "([^"]*)"$/ do |filename|
  run_simple %(bundle exec rails runner "User.create!(:attachment => File.open('#{fixture_path(filename)}'))")
end

Then /^the attachment "([^"]*)" should have a dimension of (\d+x\d+)$/ do |filename, dimension|
  cd(".") do
    geometry = `identify -format "%wx%h" "#{attachment_path(filename)}"`.strip
    expect(geometry).to eq(dimension)
  end
end

Then /^the attachment "([^"]*)" should exist$/ do |filename|
  cd(".") do
    expect(File.exist?(attachment_path(filename))).to be true
  end
end

When /^I swap the attachment "([^"]*)" with the fixture "([^"]*)"$/ do |attachment_filename, fixture_filename|
  cd(".") do
    require 'fileutils'
    FileUtils.rm_f attachment_path(attachment_filename)
    FileUtils.cp fixture_path(fixture_filename), attachment_path(attachment_filename)
  end
end

Then /^the attachment should have the same content type as the fixture "([^"]*)"$/ do |filename|
  cd(".") do
    begin
      # Use mime/types/columnar if available, for reduced memory usage
      require "mime/types/columnar"
    rescue LoadError
      require "mime/types"
    end

    attachment_content_type = `bundle exec rails runner "puts User.last.attachment_content_type"`.strip
    expected = MIME::Types.type_for(filename).first.content_type
    expect(attachment_content_type).to eq(expected)
  end
end

Then /^the attachment should have the same file name as the fixture "([^"]*)"$/ do |filename|
  cd(".") do
    attachment_file_name = `bundle exec rails runner "puts User.last.attachment_file_name"`.strip
    expect(attachment_file_name).to eq(File.name(fixture_path(filename)).to_s)
  end
end

Then /^the attachment should have the same file size as the fixture "([^"]*)"$/ do |filename|
  cd(".") do
    attachment_file_size = `bundle exec rails runner "puts User.last.attachment_file_size"`.strip
    expect(attachment_file_size).to eq(File.size(fixture_path(filename)).to_s)
  end
end

Then /^the attachment file "([^"]*)" should (not )?exist$/ do |filename, not_exist|
  cd(".") do
    expect(attachment_path(filename)).not_to be_an_existing_file
  end
end

Then /^I should have attachment columns for "([^"]*)"$/ do |attachment_name|
  cd(".") do
    columns = eval(`bundle exec rails runner "puts User.columns.map{ |column| [column.name, column.type] }.inspect"`.strip)
    expect_columns = [
      ["#{attachment_name}_file_name", :string],
      ["#{attachment_name}_content_type", :string],
      ["#{attachment_name}_file_size", :integer],
      ["#{attachment_name}_updated_at", :datetime]
    ]
    expect(columns).to include(*expect_columns)
  end
end

Then /^I should not have attachment columns for "([^"]*)"$/ do |attachment_name|
  cd(".") do
    columns = eval(`bundle exec rails runner "puts User.columns.map{ |column| [column.name, column.type] }.inspect"`.strip)
    expect_columns = [
      ["#{attachment_name}_file_name", :string],
      ["#{attachment_name}_content_type", :string],
      ["#{attachment_name}_file_size", :integer],
      ["#{attachment_name}_updated_at", :datetime]
    ]

    expect(columns).not_to include(*expect_columns)
  end
end
