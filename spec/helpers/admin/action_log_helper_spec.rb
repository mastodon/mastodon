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
end
