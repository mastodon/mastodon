# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::ApplicationsVacuum do
  subject { described_class.new }

  describe '#perform' do
    let!(:app1) { Fabricate(:application, created_at: 1.month.ago) }
    let!(:app2) { Fabricate(:application, created_at: 1.month.ago) }
    let!(:app3) { Fabricate(:application, created_at: 1.month.ago) }
    let!(:app4) { Fabricate(:application, created_at: 1.month.ago, owner: Fabricate(:user)) }
    let!(:app5) { Fabricate(:application, created_at: 1.month.ago) }
    let!(:app6) { Fabricate(:application, created_at: 1.hour.ago) }

    let!(:active_access_token) { Fabricate(:access_token, application: app1) }
    let!(:active_access_grant) { Fabricate(:access_grant, application: app2) }
    let!(:user) { Fabricate(:user, created_by_application: app3) }

    before do
      subject.perform
    end

    it 'does not delete applications with valid access tokens' do
      expect { app1.reload }.to_not raise_error
    end

    it 'does not delete applications with valid access grants' do
      expect { app2.reload }.to_not raise_error
    end

    it 'does not delete applications that were used to create users' do
      expect { app3.reload }.to_not raise_error
    end

    it 'does not delete owned applications' do
      expect { app4.reload }.to_not raise_error
    end

    it 'does not delete applications registered less than a day ago' do
      expect { app6.reload }.to_not raise_error
    end

    it 'deletes unused applications' do
      expect { app5.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
