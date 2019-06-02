# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ActionLogsHelper, type: :helper do
  klass = Class.new do
    include ActionView::Helpers
    include Admin::ActionLogsHelper
  end

  let(:hoge) { klass.new }

  describe '#log_target' do
    after do
      hoge.log_target(log)
    end

    context 'log.target' do
      let(:log) { double(target: true) }

      it 'calls linkable_log_target' do
        expect(hoge).to receive(:linkable_log_target).with(log.target)
      end
    end

    context '!log.target' do
      let(:log) { double(target: false, target_type: :type, recorded_changes: :change) }

      it 'calls log_target_from_history' do
        expect(hoge).to receive(:log_target_from_history).with(log.target_type, log.recorded_changes)
      end
    end
  end

  describe '#relevant_log_changes' do
    let(:log) { double(target_type: target_type, action: log_action, recorded_changes: recorded_changes) }
    let(:recorded_changes) { double }

    after do
      hoge.relevant_log_changes(log)
    end

    context "log.target_type == 'CustomEmoji' && [:enable, :disable, :destroy].include?(log.action)" do
      let(:target_type) { 'CustomEmoji' }
      let(:log_action)  { :enable }

      it "calls log.recorded_changes.slice('domain')" do
        expect(recorded_changes).to receive(:slice).with('domain')
      end
    end

    context "log.target_type == 'CustomEmoji' && log.action == :update" do
      let(:target_type) { 'CustomEmoji' }
      let(:log_action)  { :update }

      it "calls log.recorded_changes.slice('domain', 'visible_in_picker')" do
        expect(recorded_changes).to receive(:slice).with('domain', 'visible_in_picker')
      end
    end

    context "log.target_type == 'User' && [:promote, :demote].include?(log.action)" do
      let(:target_type) { 'User' }
      let(:log_action)  { :promote }

      it "calls log.recorded_changes.slice('moderator', 'admin')" do
        expect(recorded_changes).to receive(:slice).with('moderator', 'admin')
      end
    end

    context "log.target_type == 'User' && [:change_email].include?(log.action)" do
      let(:target_type) { 'User' }
      let(:log_action)  { :change_email }

      it "calls log.recorded_changes.slice('email', 'unconfirmed_email')" do
        expect(recorded_changes).to receive(:slice).with('email', 'unconfirmed_email')
      end
    end

    context "log.target_type == 'DomainBlock'" do
      let(:target_type) { 'DomainBlock' }
      let(:log_action)  { nil }

      it "calls log.recorded_changes.slice('severity', 'reject_media')" do
        expect(recorded_changes).to receive(:slice).with('severity', 'reject_media')
      end
    end

    context "log.target_type == 'Status' && log.action == :update" do
      let(:target_type) { 'Status' }
      let(:log_action)  { :update }

      it "log.recorded_changes.slice('sensitive')" do
        expect(recorded_changes).to receive(:slice).with('sensitive')
      end
    end
  end

  describe '#log_extra_attributes' do
    after do
      hoge.log_extra_attributes(hoge: 'hoge')
    end

    it "calls content_tag(:span, key, class: 'diff-key')" do
      allow(hoge).to receive(:log_change).with(anything)
      expect(hoge).to receive(:content_tag).with(:span, :hoge, class: 'diff-key')
    end

    it 'calls safe_join twice' do
      expect(hoge).to receive(:safe_join).with(
        ['<span class="diff-key">hoge</span>',
         '=',
         '<span class="diff-neutral">hoge</span>']
      )

      expect(hoge).to receive(:safe_join).with([nil], ' ')
    end
  end

  describe '#log_change' do
    after do
      hoge.log_change(val)
    end

    context '!val.is_a?(Array)' do
      let(:val) { 'hoge' }

      it "calls content_tag(:span, val, class: 'diff-neutral')" do
        expect(hoge).to receive(:content_tag).with(:span, val, class: 'diff-neutral')
      end
    end

    context 'val.is_a?(Array)' do
      let(:val) { %w(foo bar) }

      it 'calls #content_tag twice and #safe_join' do
        expect(hoge).to receive(:content_tag).with(:span, 'foo', class: 'diff-old')
        expect(hoge).to receive(:content_tag).with(:span, 'bar', class: 'diff-new')
        expect(hoge).to receive(:safe_join).with([nil, nil], '→')
      end
    end
  end

  describe '#icon_for_log' do
    subject   { hoge.icon_for_log(log) }

    context "log.target_type == 'Account'" do
      let(:log) { double(target_type: 'Account') }

      it 'returns "user"' do
        expect(subject).to be 'user'
      end
    end

    context "log.target_type == 'User'" do
      let(:log) { double(target_type: 'User') }

      it 'returns "user"' do
        expect(subject).to be 'user'
      end
    end

    context "log.target_type == 'CustomEmoji'" do
      let(:log) { double(target_type: 'CustomEmoji') }

      it 'returns "file"' do
        expect(subject).to be 'file'
      end
    end

    context "log.target_type == 'Report'" do
      let(:log) { double(target_type: 'Report') }

      it 'returns "flag"' do
        expect(subject).to be 'flag'
      end
    end

    context "log.target_type == 'DomainBlock'" do
      let(:log) { double(target_type: 'DomainBlock') }

      it 'returns "lock"' do
        expect(subject).to be 'lock'
      end
    end

    context "log.target_type == 'EmailDomainBlock'" do
      let(:log) { double(target_type: 'EmailDomainBlock') }

      it 'returns "envelope"' do
        expect(subject).to be 'envelope'
      end
    end

    context "log.target_type == 'Status'" do
      let(:log) { double(target_type: 'Status') }

      it 'returns "pencil"' do
        expect(subject).to be 'pencil'
      end
    end
  end

  describe '#class_for_log_icon' do
    subject   { hoge.class_for_log_icon(log) }

    %i(enable unsuspend unsilence confirm promote resolve).each do |action|
      context "log.action == #{action}" do
        let(:log) { double(action: action) }

        it 'returns "positive"' do
          expect(subject).to be 'positive'
        end
      end
    end

    context 'log.action == :create' do
      context 'opposite_verbs?(log)' do
        let(:log) { double(action: :create, target_type: 'DomainBlock') }

        it 'returns "negative"' do
          expect(subject).to be 'negative'
        end
      end

      context '!opposite_verbs?(log)' do
        let(:log) { double(action: :create, target_type: '') }

        it 'returns "positive"' do
          expect(subject).to be 'positive'
        end
      end
    end

    %i(update reset_password disable_2fa memorialize change_email).each do |action|
      context "log.action == #{action}" do
        let(:log) { double(action: action) }

        it 'returns "neutral"' do
          expect(subject).to be 'neutral'
        end
      end
    end

    %i(demote silence disable suspend remove_avatar remove_header reopen).each do |action|
      context "log.action == #{action}" do
        let(:log) { double(action: action) }

        it 'returns "negative"' do
          expect(subject).to be 'negative'
        end
      end
    end

    context 'log.action == :destroy' do
      context 'opposite_verbs?(log)' do
        let(:log) { double(action: :destroy, target_type: 'DomainBlock') }

        it 'returns "positive"' do
          expect(subject).to be 'positive'
        end
      end

      context '!opposite_verbs?(log)' do
        let(:log) { double(action: :destroy, target_type: '') }

        it 'returns "negative"' do
          expect(subject).to be 'negative'
        end
      end
    end
  end
end
