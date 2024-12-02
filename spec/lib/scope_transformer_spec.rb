# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScopeTransformer do
  describe '#apply' do
    subject { described_class.new.apply(ScopeParser.new.parse(input)) }

    shared_examples 'a scope' do |namespace, term, access|
      it 'parses the attributes' do
        expect(subject)
          .to have_attributes(
            term: term,
            namespace: namespace,
            access: access
          )
      end
    end

    context 'with scope "profile"' do
      let(:input) { 'profile' }

      it_behaves_like 'a scope', nil, 'profile', 'read'
    end

    context 'with scope "read"' do
      let(:input) { 'read' }

      it_behaves_like 'a scope', nil, 'all', 'read'
    end

    context 'with scope "write"' do
      let(:input) { 'write' }

      it_behaves_like 'a scope', nil, 'all', 'write'
    end

    context 'with scope "follow"' do
      let(:input) { 'follow' }

      it_behaves_like 'a scope', nil, 'follow', 'read/write'
    end

    context 'with scope "crypto"' do
      let(:input) { 'crypto' }

      it_behaves_like 'a scope', nil, 'crypto', 'read/write'
    end

    context 'with scope "push"' do
      let(:input) { 'push' }

      it_behaves_like 'a scope', nil, 'push', 'read/write'
    end

    context 'with scope "admin:read"' do
      let(:input) { 'admin:read' }

      it_behaves_like 'a scope', 'admin', 'all', 'read'
    end

    context 'with scope "admin:write"' do
      let(:input) { 'admin:write' }

      it_behaves_like 'a scope', 'admin', 'all', 'write'
    end

    context 'with scope "admin:read:accounts"' do
      let(:input) { 'admin:read:accounts' }

      it_behaves_like 'a scope', 'admin', 'accounts', 'read'
    end

    context 'with scope "admin:write:accounts"' do
      let(:input) { 'admin:write:accounts' }

      it_behaves_like 'a scope', 'admin', 'accounts', 'write'
    end

    context 'with scope "read:accounts"' do
      let(:input) { 'read:accounts' }

      it_behaves_like 'a scope', nil, 'accounts', 'read'
    end

    context 'with scope "write:accounts"' do
      let(:input) { 'write:accounts' }

      it_behaves_like 'a scope', nil, 'accounts', 'write'
    end
  end
end
