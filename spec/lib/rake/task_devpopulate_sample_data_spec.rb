# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe Rake::Task do
  describe 'dev:populate_sample_data' do
    subject { described_class['dev:populate_sample_data'] }

    before do
      Rails.application.load_tasks unless described_class.tasks.any?
      subject.reenable
    end

    describe '.invoke' do
      context 'when the task is invoked successfully' do
        it 'runs without aborting' do
          expect { subject.invoke }.to_not raise_error
        end

        it 'populates accounts and users' do
          expect { subject.invoke }
            .to change(Account, :count).by(3)
            .and change(User, :count).by(2)
        end
      end
    end
  end
end
