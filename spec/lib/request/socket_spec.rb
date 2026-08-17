# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request::Socket do
  describe '.open' do
    context 'when an IPv6 only host lookup' do
      let(:resolv_service) { instance_double(Resolv) }
      let(:socket_service) { instance_double(Socket).as_null_object }

      before do
        allow(Resolv).to receive(:new).and_return(resolv_service)
        allow(Socket).to receive(:new).and_return(socket_service)
        allow(resolv_service).to receive(:getaddresses).with('example.com').and_return(%w(2001:4860:4860::8844))
      end

      it 'returns a valid socket' do
        described_class.open('example.com')

        expect(Socket)
          .to have_received(:new)
          .with(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
      end
    end
  end
end
