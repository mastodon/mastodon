# frozen_string_literal: true

require "test_helper"

class ViewsGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::ViewsGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "Assert all views are properly created with no params" do
    run_generator
    assert_files
    assert_shared_links
  end

  test "Assert all views are properly created with scope param" do
    run_generator %w(users)
    assert_files "users"
    assert_shared_links "users"

    run_generator %w(admins)
    assert_files "admins"
    assert_shared_links "admins"
  end

  test "Assert views with simple form" do
    run_generator %w(-b simple_form_for)
    assert_files
    assert_file "app/views/devise/confirmations/new.html.erb", /simple_form_for/

    run_generator %w(users -b simple_form_for)
    assert_files "users"
    assert_file "app/views/users/confirmations/new.html.erb", /simple_form_for/
  end

  test "Assert views with markerb" do
    run_generator %w(--markerb)
    assert_files nil, mail_template_engine: "markerb"
  end


  test "Assert only views within specified directories" do
    run_generator %w(-v sessions registrations)
    assert_file "app/views/devise/sessions/new.html.erb"
    assert_file "app/views/devise/registrations/new.html.erb"
    assert_file "app/views/devise/registrations/edit.html.erb"
    assert_no_file "app/views/devise/confirmations/new.html.erb"
    assert_no_file "app/views/devise/mailer/confirmation_instructions.html.erb"
  end

  test "Assert mailer specific directory with simple form" do
    run_generator %w(-v mailer -b simple_form_for)
    assert_file "app/views/devise/mailer/confirmation_instructions.html.erb"
    assert_file "app/views/devise/mailer/reset_password_instructions.html.erb"
    assert_file "app/views/devise/mailer/unlock_instructions.html.erb"
  end

  test "Assert specified directories with scope" do
    run_generator %w(users -v sessions)
    assert_file "app/views/users/sessions/new.html.erb"
    assert_no_file "app/views/users/confirmations/new.html.erb"
  end

  test "Assert specified directories with simple form" do
    run_generator %w(-v registrations -b simple_form_for)
    assert_file "app/views/devise/registrations/new.html.erb", /simple_form_for/
    assert_no_file "app/views/devise/confirmations/new.html.erb"
    end

  test "Assert specified directories with markerb" do
    run_generator %w(--markerb -v passwords mailer)
    assert_file "app/views/devise/passwords/new.html.erb"
    assert_no_file "app/views/devise/confirmations/new.html.erb"
    assert_file "app/views/devise/mailer/reset_password_instructions.markerb"
  end

  def assert_files(scope = nil, options={})
    scope = "devise" if scope.nil?
    mail_template_engine = options[:mail_template_engine] || "html.erb"

    assert_file "app/views/#{scope}/confirmations/new.html.erb"
    assert_file "app/views/#{scope}/mailer/confirmation_instructions.#{mail_template_engine}"
    assert_file "app/views/#{scope}/mailer/reset_password_instructions.#{mail_template_engine}"
    assert_file "app/views/#{scope}/mailer/unlock_instructions.#{mail_template_engine}"
    assert_file "app/views/#{scope}/passwords/edit.html.erb"
    assert_file "app/views/#{scope}/passwords/new.html.erb"
    assert_file "app/views/#{scope}/registrations/new.html.erb"
    assert_file "app/views/#{scope}/registrations/edit.html.erb"
    assert_file "app/views/#{scope}/sessions/new.html.erb"
    assert_file "app/views/#{scope}/shared/_links.html.erb"
    assert_file "app/views/#{scope}/unlocks/new.html.erb"
  end

  def assert_shared_links(scope = nil)
    scope = "devise" if scope.nil?
    link = /<%= render \"#{scope}\/shared\/links\" %>/

    assert_file "app/views/#{scope}/passwords/edit.html.erb", link
    assert_file "app/views/#{scope}/passwords/new.html.erb", link
    assert_file "app/views/#{scope}/confirmations/new.html.erb", link
    assert_file "app/views/#{scope}/registrations/new.html.erb", link
    assert_file "app/views/#{scope}/sessions/new.html.erb", link
    assert_file "app/views/#{scope}/unlocks/new.html.erb", link
  end
end
