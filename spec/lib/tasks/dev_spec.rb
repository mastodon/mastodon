# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe Rake::Task do
  before do
    Rails.application.load_tasks
  end

  it 'runs dev:populate_sample_data successfully without aborting' do
    task = Rake::Task['dev:populate_sample_data']
    task.reenable

    expect { task.invoke }.to_not raise_error
  end
end
