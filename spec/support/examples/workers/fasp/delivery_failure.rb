# frozen_string_literal: true

RSpec.shared_examples 'worker handling fasp delivery failures' do
  context 'when provider is not available' do
    before do
      provider.update(delivery_last_failed_at: 1.minute.ago)
      domain = Addressable::URI.parse(provider.base_url).normalized_host
      UnavailableDomain.create!(domain:)
    end

    it 'does not attempt connecting and does not fail the job' do
      expect { subject }.to_not raise_error
      expect(stubbed_request).to_not have_been_made
    end
  end

  context 'when connection to provider fails' do
    before do
      base_stubbed_request
        .to_raise(HTTP::ConnectionError)
    end

    context 'when provider becomes unavailable' do
      before do
        travel_to 5.minutes.ago
        4.times do
          provider.delivery_failure_tracker.track_failure!
          travel_to 1.minute.since
        end
      end

      it 'updates the provider and does not fail the job, so it will not be retried' do
        expect { subject }.to_not raise_error
        expect(provider.reload.delivery_last_failed_at).to eq Time.current
      end
    end

    context 'when provider is still marked as available' do
      it 'fails the job so it can be retried' do
        expect { subject }.to raise_error(HTTP::ConnectionError)
      end
    end
  end

  context 'when connection to a previously unavailable provider succeeds' do
    before do
      provider.update(delivery_last_failed_at: 2.hours.ago)
      domain = Addressable::URI.parse(provider.base_url).normalized_host
      UnavailableDomain.create!(domain:)
    end

    it 'marks the provider as being available again' do
      expect { subject }.to_not raise_error
      expect(provider).to be_available
    end
  end
end
