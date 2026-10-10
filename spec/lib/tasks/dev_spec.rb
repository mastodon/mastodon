# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe Rake::Task do
  subject { Rake::Task['dev:populate_sample_data'] }

  before do
    Rails.application.load_tasks
    subject.reenable
  end

  it 'runs dev:populate_sample_data successfully without aborting' do
    expect { subject.invoke }.to_not raise_error
  end
end
