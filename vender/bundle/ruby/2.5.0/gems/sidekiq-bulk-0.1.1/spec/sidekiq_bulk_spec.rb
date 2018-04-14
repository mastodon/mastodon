RSpec.describe SidekiqBulk do
  class FooJob
    include Sidekiq::Worker

    def perform(x, *args)
      raise x.to_s
    end
  end

  class BarJob < FooJob
  end

  shared_examples "a bulk push method" do |method_name|
    it "provides a push_bulk method on job classes" do
      expect(FooJob).to respond_to(method_name)
    end

    it "enqueues the job" do
      FooJob.public_send(method_name, [1, 2, 3]) { |el| [2*el, "some-value"] }

      expect(FooJob.jobs.length).to eq(3)
      expect(FooJob).to have_enqueued_job(2, "some-value")
      expect(FooJob).to have_enqueued_job(4, "some-value")
      expect(FooJob).to have_enqueued_job(6, "some-value")
    end

    it "goes through the Sidekiq::Client interface" do
      expect(Sidekiq::Client).to receive(:push_bulk).once.with("class" => FooJob, "args" => [[1], [2], [3]])

      FooJob.public_send(method_name, [1, 2, 3])
    end

    it "uses the correct class name for subclasses" do
      expect(Sidekiq::Client).to receive(:push_bulk).once.with("class" => BarJob, "args" => [[1], [2], [3]])

      BarJob.push_bulk([1, 2, 3])
    end

    it "defaults to the identity function with no block given" do
      FooJob.public_send(method_name, [10, -6.1, "a thing"])

      expect(FooJob.jobs.length).to eq(3)
      expect(FooJob).to have_enqueued_job(10)
      expect(FooJob).to have_enqueued_job(-6.1)
      expect(FooJob).to have_enqueued_job("a thing")
    end
  end

  describe "#push_bulk" do
    include_examples "a bulk push method", :push_bulk

    it "limits the size of groups" do
      FooJob.push_bulk([1, 2, 3, 4, 5, 6, 7], limit: 3)

      expect(FooJob.jobs.length).to eq(7)
      expect(FooJob).to have_enqueued_job(1)
      expect(FooJob).to have_enqueued_job(2)
      expect(FooJob).to have_enqueued_job(3)
      expect(FooJob).to have_enqueued_job(4)
      expect(FooJob).to have_enqueued_job(5)
      expect(FooJob).to have_enqueued_job(6)
      expect(FooJob).to have_enqueued_job(7)
    end

    it "limits with the item transformation" do
      allow(Sidekiq::Client).to receive(:push_bulk)

      FooJob.push_bulk([1, 2, 3, 4, 5, 6, 7], limit: 4) do |item|
        [2*item, "some-value"]
      end

      expect(Sidekiq::Client).to have_received(:push_bulk).exactly(2).times
      expect(Sidekiq::Client).to have_received(:push_bulk).with("class" => FooJob, "args" => [[2, "some-value"], [4, "some-value"], [6, "some-value"], [8, "some-value"]])
      expect(Sidekiq::Client).to have_received(:push_bulk).with("class" => FooJob, "args" => [[10, "some-value"], [12, "some-value"], [14, "some-value"]])
    end

    it "goes through the Sidekiq::Client interface" do
      allow(Sidekiq::Client).to receive(:push_bulk)

      FooJob.push_bulk([1, 2, 3, 4, 5, 6, 7], limit: 3)

      expect(Sidekiq::Client).to have_received(:push_bulk).exactly(3).times
      expect(Sidekiq::Client).to have_received(:push_bulk).with("class" => FooJob, "args" => [[1], [2], [3]])
      expect(Sidekiq::Client).to have_received(:push_bulk).with("class" => FooJob, "args" => [[4], [5], [6]])
      expect(Sidekiq::Client).to have_received(:push_bulk).with("class" => FooJob, "args" => [[7]])
    end

    context "when no limit is specified" do
      let(:item_count) { 9_999 }

      before do
        allow(Sidekiq::Client).to receive(:push_bulk)

        FooJob.push_bulk((1..item_count).to_a)
      end

      context "when the item count is 10,000" do
        let(:item_count) { 10_000 }

        specify { expect(Sidekiq::Client).to have_received(:push_bulk).exactly(1).times }
      end

      context "when the item count is 10,001" do
        let(:item_count) { 10_001 }

        specify { expect(Sidekiq::Client).to have_received(:push_bulk).exactly(2).times }
      end

      context "when the item count is 40,000" do
        let(:item_count) { 40_000 }

        specify { expect(Sidekiq::Client).to have_received(:push_bulk).exactly(4).times }
      end
    end
  end

  describe "#push_bulk!" do
    include_examples "a bulk push method", :push_bulk!

    it "does not limit the number of jobs in one push" do
      expect(Sidekiq::Client).to receive(:push_bulk).once.with("class" => FooJob, "args" => (1..100_000).map { |e| [e] })

      FooJob.push_bulk!((1..100_000).to_a)
    end
  end

  describe "inline test", sidekiq: :inline do
    specify { expect { FooJob.push_bulk([1, 2, 3]) }.to raise_error(RuntimeError, "1") }
    specify { expect { FooJob.push_bulk!([1, 2, 3]) }.to raise_error(RuntimeError, "1") }
  end
end
