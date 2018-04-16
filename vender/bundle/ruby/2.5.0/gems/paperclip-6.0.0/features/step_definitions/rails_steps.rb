Given /^I generate a new rails application$/ do
  steps %{
    When I successfully run `rails new #{APP_NAME} --skip-bundle`
    And I cd to "#{APP_NAME}"
  }

  FileUtils.chdir("tmp/aruba/testapp/")

  steps %{
    And I turn off class caching
    And I write to "Gemfile" with:
      """
      source "http://rubygems.org"
      gem "rails", "#{framework_version}"
      gem "sqlite3", :platform => [:ruby, :rbx]
      gem "activerecord-jdbcsqlite3-adapter", :platform => :jruby
      gem "jruby-openssl", :platform => :jruby
      gem "capybara"
      gem "gherkin"
      gem "aws-sdk-s3"
      gem "racc", :platform => :rbx
      gem "rubysl", :platform => :rbx
      """
    And I remove turbolinks
    And I comment out lines that contain "action_mailer" in "config/environments/*.rb"
    And I empty the application.js file
    And I configure the application to use "paperclip" from this project
  }

  FileUtils.chdir("../../..")
end

Given "I allow the attachment to be submitted" do
  cd(".") do
    transform_file("app/controllers/users_controller.rb") do |content|
      content.gsub("params.require(:user).permit(:name)",
                   "params.require(:user).permit!")
    end
  end
end

Given "I remove turbolinks" do
  cd(".") do
    transform_file("app/assets/javascripts/application.js") do |content|
      content.gsub("//= require turbolinks", "")
    end
    transform_file("app/views/layouts/application.html.erb") do |content|
      content.gsub(', "data-turbolinks-track" => true', "")
    end
  end
end

Given /^I comment out lines that contain "([^"]+)" in "([^"]+)"$/ do |contains, glob|
  cd(".") do
    Dir.glob(glob).each do |file|
      transform_file(file) do |content|
        content.gsub(/^(.*?#{contains}.*?)$/) { |line| "# #{line}" }
      end
    end
  end
end

Given /^I attach :attachment$/ do
  attach_attachment("attachment")
end

Given /^I attach :attachment with:$/ do |definition|
  attach_attachment("attachment", definition)
end

def attach_attachment(name, definition = nil)
  snippet = "has_attached_file :#{name}"
  if definition
    snippet += ", \n"
    snippet += definition
  end
  snippet += "\ndo_not_validate_attachment_file_type :#{name}\n"
  cd(".") do
    transform_file("app/models/user.rb") do |content|
      content.sub(/end\Z/, "#{snippet}\nend")
    end
  end
end

Given "I empty the application.js file" do
  cd(".") do
    transform_file("app/assets/javascripts/application.js") do |content|
      ""
    end
  end
end

Given /^I run a rails generator to generate a "([^"]*)" scaffold with "([^"]*)"$/ do |model_name, attributes|
  step %[I successfully run `rails generate scaffold #{model_name} #{attributes}`]
end

Given /^I run a paperclip generator to add a paperclip "([^"]*)" to the "([^"]*)" model$/ do |attachment_name, model_name|
  step %[I successfully run `rails generate paperclip #{model_name} #{attachment_name}`]
end

Given /^I run a migration$/ do
  step %[I successfully run `rake db:migrate --trace`]
end

When /^I rollback a migration$/ do
  step %[I successfully run `rake db:rollback STEPS=1 --trace`]
end

Given /^I update my new user view to include the file upload field$/ do
  steps %{
    Given I overwrite "app/views/users/new.html.erb" with:
      """
      <%= form_for @user, :html => { :multipart => true } do |f| %>
        <%= f.label :name %>
        <%= f.text_field :name %>
        <%= f.label :attachment %>
        <%= f.file_field :attachment %>
        <%= submit_tag "Submit" %>
      <% end %>
      """
  }
end

Given /^I update my user view to include the attachment$/ do
  steps %{
    Given I overwrite "app/views/users/show.html.erb" with:
      """
      <p>Name: <%= @user.name %></p>
      <p>Attachment: <%= image_tag @user.attachment.url %></p>
      """
  }
end

Given /^I add this snippet to the User model:$/ do |snippet|
  file_name = "app/models/user.rb"
  cd(".") do
    content = File.read(file_name)
    File.open(file_name, 'w') { |f| f << content.sub(/end\Z/, "#{snippet}\nend") }
  end
end

Given /^I add this snippet to config\/application.rb:$/ do |snippet|
  file_name = "config/application.rb"
  cd(".") do
    content = File.read(file_name)
    File.open(file_name, 'w') {|f| f << content.sub(/class Application < Rails::Application.*$/, "class Application < Rails::Application\n#{snippet}\n")}
  end
end

Given /^I start the rails application$/ do
  cd(".") do
    require "rails"
    require "./config/environment"
    require "capybara"
    Capybara.app = Rails.application
  end
end

Given /^I reload my application$/ do
  Rails::Application.reload!
end

When /^I turn off class caching$/ do
  cd(".") do
    file = "config/environments/test.rb"
    config = IO.read(file)
    config.gsub!(%r{^\s*config.cache_classes.*$},
                 "config.cache_classes = false")
    File.open(file, "w"){|f| f.write(config) }
  end
end

Then /^the file at "([^"]*)" should be the same as "([^"]*)"$/ do |web_file, path|
  expected = IO.read(path)
  actual = read_from_web(web_file)
  expect(actual).to eq(expected)
end

When /^I configure the application to use "([^\"]+)" from this project$/ do |name|
  append_to_gemfile "gem '#{name}', :path => '#{PROJECT_ROOT}'"
  steps %{And I successfully run `bundle install --local`}
end

When /^I configure the application to use "([^\"]+)"$/ do |gem_name|
  append_to_gemfile "gem '#{gem_name}'"
end

When /^I append gems from Appraisal Gemfile$/ do
  File.read(ENV['BUNDLE_GEMFILE']).split(/\n/).each do |line|
    if line =~ /^gem "(?!rails|appraisal)/
      append_to_gemfile line.strip
    end
  end
end

When /^I comment out the gem "([^"]*)" from the Gemfile$/ do |gemname|
  comment_out_gem_in_gemfile gemname
end

Given(/^I add a "(.*?)" processor in "(.*?)"$/) do |processor, directory|
  filename = "#{directory}/#{processor}.rb"
  cd(".") do
    FileUtils.mkdir_p directory
    File.open(filename, "w") do |f|
      f.write(<<-CLASS)
        module Paperclip
          class #{processor.capitalize} < Processor
            def make
              basename = File.basename(file.path, File.extname(file.path))
              dst_format = options[:format] ? ".\#{options[:format]}" : ''

              dst = Tempfile.new([basename, dst_format])
              dst.binmode

              convert(':src :dst',
                src: File.expand_path(file.path),
                dst: File.expand_path(dst.path)
              )

              dst
            end
          end
        end
      CLASS
    end
  end
end

def transform_file(filename)
  if File.exist?(filename)
    content = File.read(filename)
    File.open(filename, "w") do |f|
      content = yield(content)
      f.write(content)
    end
  end
end
