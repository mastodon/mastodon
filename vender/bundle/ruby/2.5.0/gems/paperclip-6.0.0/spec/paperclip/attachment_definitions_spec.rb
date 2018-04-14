require 'spec_helper'

describe "Attachment Definitions" do
  it 'returns all of the attachments on the class' do
    reset_class "Dummy"
    Dummy.has_attached_file :avatar, {path: "abc"}
    Dummy.has_attached_file :other_attachment, {url: "123"}
    Dummy.do_not_validate_attachment_file_type :avatar
    expected = {avatar: {path: "abc"}, other_attachment: {url: "123"}}

    expect(Dummy.attachment_definitions).to eq expected
  end
end
