require 'rails_helper'

RSpec.describe FetchAtomService do
  describe '#link_header' do
    context 'Link is Array' do
      target = FetchAtomService.new
      target.instance_variable_set('@response', 'Link' => [
        '<http://example.com/>; rel="up"; meta="bar"',
        '<http://example.com/foo>; rel="self"',
      ])

      it 'set first link as link_header' do
        expect(target.send(:link_header).links[0].href).to eq 'http://example.com/'
      end
    end

    context 'Link is not Array' do
      target = FetchAtomService.new
      target.instance_variable_set('@response', 'Link' => '<http://example.com/foo>; rel="self", <http://example.com/>; rel = "up"')

      it { expect(target.send(:link_header).links[0].href).to eq 'http://example.com/foo' }
    end
  end
end
