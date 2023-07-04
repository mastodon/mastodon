# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Field do
  describe '#verified?' do
    subject { described_class.new(account, 'name' => 'Foo', 'value' => 'Bar', 'verified_at' => verified_at) }

    let(:account) { instance_double(Account, local?: true) }

    context 'when verified_at is set' do
      let(:verified_at) { Time.now.utc.iso8601 }

      it 'returns true' do
        expect(subject.verified?).to be true
      end
    end

    context 'when verified_at is not set' do
      let(:verified_at) { nil }

      it 'returns false' do
        expect(subject.verified?).to be false
      end
    end
  end

  describe '#mark_verified!' do
    subject { described_class.new(account, original_hash) }

    let(:account) { instance_double(Account, local?: true) }
    let(:original_hash) { { 'name' => 'Foo', 'value' => 'Bar' } }

    before do
      subject.mark_verified!
    end

    it 'updates verified_at' do
      expect(subject.verified_at).to_not be_nil
    end

    it 'updates original hash' do
      expect(original_hash['verified_at']).to_not be_nil
    end
  end

  describe '#verifiable?' do
    subject { described_class.new(account, 'name' => 'Foo', 'value' => value) }

    let(:account) { instance_double(Account, local?: local) }

    context 'with local accounts' do
      let(:local) { true }

      context 'with a URL with misleading authentication' do
        let(:value) { 'https://spacex.com                                                                                            @h.43z.one' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with a URL' do
        let(:value) { 'https://example.com' }

        it 'returns true' do
          expect(subject.verifiable?).to be true
        end
      end

      context 'with an IDN URL' do
        let(:value) { 'https://twitter.com∕dougallj∕status∕1590357240443437057.ê.cc/twitter.html' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with a URL with a non-normalized path' do
        let(:value) { 'https://github.com/octocatxxxxxxxx/../mastodon' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with text that is not a URL' do
        let(:value) { 'Hello world' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with text that contains a URL' do
        let(:value) { 'Hello https://example.com world' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with text which is blank' do
        let(:value) { '' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end
    end

    context 'with remote accounts' do
      let(:local) { false }

      context 'with a link' do
        let(:value) { '<a href="https://www.patreon.com/mastodon" target="_blank" rel="nofollow noopener noreferrer me"><span class="invisible">https://www.</span><span class="">patreon.com/mastodon</span><span class="invisible"></span></a>' }

        it 'returns true' do
          expect(subject.verifiable?).to be true
        end
      end

      context 'with a link with misleading authentication' do
        let(:value) { '<a href="https://google.com                                                                                            @h.43z.one" target="_blank" rel="nofollow noopener noreferrer me"><span class="invisible">https://</span><span class="">google.com</span><span class="invisible">                                                                                            @h.43z.one</span></a>' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with HTML that has more than just a link' do
        let(:value) { '<a href="https://google.com" target="_blank" rel="nofollow noopener noreferrer me"><span class="invisible">https://</span><span class="">google.com</span><span class="invisible"></span></a>                                                                                            @h.43z.one' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with a link with different visible text' do
        let(:value) { '<a href="https://google.com/bar">https://example.com/foo</a>' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with text that is a URL but is not linked' do
        let(:value) { 'https://example.com/foo' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end

      context 'with text which is blank' do
        let(:value) { '' }

        it 'returns false' do
          expect(subject.verifiable?).to be false
        end
      end
    end
  end
end
