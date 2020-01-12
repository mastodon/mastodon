# frozen_string_literal: true

shared_examples 'AccountHeader' do |fabricator|
  describe 'base64-encoded files' do
    let(:base64_attachment) { "data:image/jpeg;base64,#{Base64.encode64(attachment_fixture('attachment.jpg').read)}" }
    let(:account) { Fabricate(fabricator, header: base64_attachment) }

    it 'saves header' do
      expect(account.persisted?).to be true
      expect(account.header).to_not be_nil
    end

    it 'gives the header a file name' do
      expect(account.header_file_name).to_not be_blank
    end

    it 'saves a new header under a different file name' do
      previous_file_name = account.header_file_name
      account.update(header: base64_attachment)
      expect(account.header_file_name).to_not eq previous_file_name
    end
  end
end
