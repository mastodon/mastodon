require 'spec_helper'

describe 'Missing Attachment Styles' do
  before do
    Paperclip::AttachmentRegistry.clear
  end

  after do
    File.unlink(Paperclip.registered_attachments_styles_path) rescue nil
  end

  it "enables to get and set path to registered styles file" do
    assert_equal ROOT.join('tmp/public/system/paperclip_attachments.yml').to_s, Paperclip.registered_attachments_styles_path
    Paperclip.registered_attachments_styles_path = '/tmp/config/paperclip_attachments.yml'
    assert_equal '/tmp/config/paperclip_attachments.yml', Paperclip.registered_attachments_styles_path
    Paperclip.registered_attachments_styles_path = nil
    assert_equal ROOT.join('tmp/public/system/paperclip_attachments.yml').to_s, Paperclip.registered_attachments_styles_path
  end

  it "is able to get current attachment styles" do
    assert_equal Hash.new, Paperclip.send(:current_attachments_styles)
    rebuild_model styles: {croppable: '600x600>', big: '1000x1000>'}
    expected_hash = { Dummy: {avatar: [:big, :croppable]}}
    assert_equal expected_hash, Paperclip.send(:current_attachments_styles)
  end

  it "is able to save current attachment styles for further comparison" do
    rebuild_model styles: {croppable: '600x600>', big: '1000x1000>'}
    Paperclip.save_current_attachments_styles!
    expected_hash = { Dummy: {avatar: [:big, :croppable]}}
    assert_equal expected_hash, YAML.load_file(Paperclip.registered_attachments_styles_path)
  end

  it "is able to read registered attachment styles from file" do
    rebuild_model styles: {croppable: '600x600>', big: '1000x1000>'}
    Paperclip.save_current_attachments_styles!
    expected_hash = { Dummy: {avatar: [:big, :croppable]}}
    assert_equal expected_hash, Paperclip.send(:get_registered_attachments_styles)
  end

  it "is able to calculate differences between registered styles and current styles" do
    rebuild_model styles: {croppable: '600x600>', big: '1000x1000>'}
    Paperclip.save_current_attachments_styles!
    rebuild_model styles: {thumb: 'x100', export: 'x400>', croppable: '600x600>', big: '1000x1000>'}
    expected_hash = { Dummy: {avatar: [:export, :thumb]} }
    assert_equal expected_hash, Paperclip.missing_attachments_styles

    ActiveRecord::Base.connection.create_table :books, force: true
    class ::Book < ActiveRecord::Base
      has_attached_file :cover, styles: {small: 'x100', large: '1000x1000>'}
      has_attached_file :sample, styles: {thumb: 'x100'}
    end

    expected_hash = {
      Dummy: {avatar: [:export, :thumb]},
      Book: {sample: [:thumb], cover: [:large, :small]}
    }
    assert_equal expected_hash, Paperclip.missing_attachments_styles
    Paperclip.save_current_attachments_styles!
    assert_equal Hash.new, Paperclip.missing_attachments_styles
  end

  it "is able to calculate differences when a new attachment is added to a model" do
    rebuild_model styles: {croppable: '600x600>', big: '1000x1000>'}
    Paperclip.save_current_attachments_styles!

    class ::Dummy
      has_attached_file :photo, styles: {small: 'x100', large: '1000x1000>'}
    end

    expected_hash = {
      Dummy: {photo: [:large, :small]}
    }
    assert_equal expected_hash, Paperclip.missing_attachments_styles
    Paperclip.save_current_attachments_styles!
    assert_equal Hash.new, Paperclip.missing_attachments_styles
  end

  # It's impossible to build styles hash without loading from database whole bunch of records
  it "skips lambda-styles" do
    rebuild_model styles: lambda{ |attachment| attachment.instance.other == 'a' ? {thumb: "50x50#"} : {large: "400x400"} }
    assert_equal Hash.new, Paperclip.send(:current_attachments_styles)
  end
end
