require 'spec_helper'

describe Chewy::RakeHelper, :orm do
  before { Chewy.massacre }

  before do
    stub_model(:city)
    stub_model(:country)

    stub_index(:places) do
      define_type City do
        field :name
        field :updated_at, type: 'date'
      end
      define_type Country
    end
    stub_index(:users)

    allow(described_class).to receive(:all_indexes) { [PlacesIndex, UsersIndex] }
  end

  let!(:cities) { Array.new(3) { |i| City.create!(name: "Name#{i + 1}") } }
  let!(:countries) { Array.new(2) { |i| Country.create!(name: "Name#{i + 1}") } }
  let(:journal) do
    Chewy::Stash::Journal.import([
      {
        index_name: 'places',
        type_name: 'city',
        action: 'index',
        references: cities.first(2).map(&:id).map(&:to_s)
                      .map(&:to_json).map(&Base64.method(:encode64)),
        created_at: 2.minutes.since
      },
      {
        index_name: 'places',
        type_name: 'country',
        action: 'index',
        references: [Base64.encode64(countries.first.id.to_s.to_json)],
        created_at: 4.minutes.since
      }
    ])
  end

  describe '.reset' do
    before { journal }

    specify do
      output = StringIO.new
      expect { described_class.reset(output: output) }
        .to update_index(PlacesIndex::City)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AResetting PlacesIndex
  Imported PlacesIndex::City in \\d+s, stats: index 3
  Imported PlacesIndex::Country in \\d+s, stats: index 2
  Applying journal to \\[PlacesIndex::City, PlacesIndex::Country\\], 3 entries, stage 1
  Imported PlacesIndex::City in \\d+s, stats: index 2
  Imported PlacesIndex::Country in \\d+s, stats: index 1
  Imported Chewy::Stash::Specification::Specification in \\d+s, stats: index 1
Resetting UsersIndex
  Imported Chewy::Stash::Specification::Specification in \\d+s, stats: index 1
Total: \\d+s\\Z
      OUTPUT
    end

    specify do
      output = StringIO.new
      expect { described_class.reset(only: 'places', output: output) }
        .to update_index(PlacesIndex::City)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AResetting PlacesIndex
  Imported PlacesIndex::City in \\d+s, stats: index 3
  Imported PlacesIndex::Country in \\d+s, stats: index 2
  Applying journal to \\[PlacesIndex::City, PlacesIndex::Country\\], 3 entries, stage 1
  Imported PlacesIndex::City in \\d+s, stats: index 2
  Imported PlacesIndex::Country in \\d+s, stats: index 1
  Imported Chewy::Stash::Specification::Specification in \\d+s, stats: index 1
Total: \\d+s\\Z
      OUTPUT
    end

    specify do
      output = StringIO.new
      expect { described_class.reset(except: PlacesIndex, output: output) }
        .not_to update_index(PlacesIndex::City)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AResetting UsersIndex
  Imported Chewy::Stash::Specification::Specification in \\d+s, stats: index 1
Total: \\d+s\\Z
      OUTPUT
    end
  end

  describe '.upgrade' do
    specify do
      output = StringIO.new
      expect { described_class.upgrade(output: output) }
        .to update_index(PlacesIndex::City)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AResetting PlacesIndex
  Imported PlacesIndex::City in \\d+s, stats: index 3
  Imported PlacesIndex::Country in \\d+s, stats: index 2
  Imported Chewy::Stash::Specification::Specification in \\d+s, stats: index 1
Resetting UsersIndex
  Imported Chewy::Stash::Specification::Specification in \\d+s, stats: index 1
Total: \\d+s\\Z
      OUTPUT
    end

    context do
      before { PlacesIndex.reset! }

      specify do
        output = StringIO.new
        expect { described_class.upgrade(output: output) }
          .not_to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ASkipping PlacesIndex, the specification didn't change
Resetting UsersIndex
  Imported Chewy::Stash::Specification::Specification in \\d+s, stats: index 1
Total: \\d+s\\Z
        OUTPUT
      end

      specify do
        output = StringIO.new
        expect { described_class.upgrade(except: PlacesIndex, output: output) }
          .not_to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AResetting UsersIndex
  Imported Chewy::Stash::Specification::Specification in \\d+s, stats: index 1
Total: \\d+s\\Z
        OUTPUT
      end

      context do
        before { UsersIndex.reset! }

        specify do
          output = StringIO.new
          expect { described_class.upgrade(except: ['places'], output: output) }
            .not_to update_index(PlacesIndex::City)
          expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ANo index specification was changed
Total: \\d+s\\Z
          OUTPUT
        end
      end
    end
  end

  describe '.update' do
    specify do
      output = StringIO.new
      expect { described_class.update(output: output) }
        .not_to update_index(PlacesIndex::City)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ASkipping PlacesIndex, it does not exists \\(use rake chewy:reset\\[places\\] to create and update it\\)
      OUTPUT
    end

    context do
      before { PlacesIndex.reset! }

      specify do
        output = StringIO.new
        expect { described_class.update(output: output) }
          .to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AUpdating PlacesIndex
  Imported PlacesIndex::City in \\d+s, stats: index 3
  Imported PlacesIndex::Country in \\d+s, stats: index 2
Total: \\d+s\\Z
        OUTPUT
      end

      specify do
        output = StringIO.new
        expect { described_class.update(only: 'places#country', output: output) }
          .not_to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AUpdating PlacesIndex
  Imported PlacesIndex::Country in \\d+s, stats: index 2
Total: \\d+s\\Z
        OUTPUT
      end

      specify do
        output = StringIO.new
        expect { described_class.update(except: PlacesIndex::Country, output: output) }
          .to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AUpdating PlacesIndex
  Imported PlacesIndex::City in \\d+s, stats: index 3
Total: \\d+s\\Z
        OUTPUT
      end
    end
  end

  describe '.sync' do
    specify do
      output = StringIO.new
      expect { described_class.sync(output: output) }
        .to update_index(PlacesIndex::City)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ASynchronizing PlacesIndex::City
  Imported PlacesIndex::City in \\d+s, stats: index 3
  Missing documents: \\[[^\\]]+\\]
  Took \\d+s
Synchronizing PlacesIndex::Country
  PlacesIndex::Country doesn't support outdated synchronization
  Imported PlacesIndex::Country in \\d+s, stats: index 2
  Missing documents: \\[[^\\]]+\\]
  Took \\d+s
Total: \\d+s\\Z
      OUTPUT
    end

    context do
      before do
        PlacesIndex::City.import(cities.first(2))
        PlacesIndex::Country.import

        sleep(1) if ActiveSupport::VERSION::STRING < '4.1.0'
        cities.first.update(name: 'Name5')
      end

      specify do
        output = StringIO.new
        expect { described_class.sync(output: output) }
          .to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ASynchronizing PlacesIndex::City
  Imported PlacesIndex::City in \\d+s, stats: index 2
  Missing documents: \\["#{cities.last.id}"\\]
  Outdated documents: \\["#{cities.first.id}"\\]
  Took \\d+s
Synchronizing PlacesIndex::Country
  PlacesIndex::Country doesn't support outdated synchronization
  Skipping PlacesIndex::Country, up to date
  Took \\d+s
Total: \\d+s\\Z
        OUTPUT
      end

      specify do
        output = StringIO.new
        expect { described_class.sync(only: PlacesIndex::City, output: output) }
          .to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ASynchronizing PlacesIndex::City
  Imported PlacesIndex::City in \\d+s, stats: index 2
  Missing documents: \\["#{cities.last.id}"\\]
  Outdated documents: \\["#{cities.first.id}"\\]
  Took \\d+s
Total: \\d+s\\Z
        OUTPUT
      end

      specify do
        output = StringIO.new
        expect { described_class.sync(except: ['places#city'], output: output) }
          .not_to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ASynchronizing PlacesIndex::Country
  PlacesIndex::Country doesn't support outdated synchronization
  Skipping PlacesIndex::Country, up to date
  Took \\d+s
Total: \\d+s\\Z
        OUTPUT
      end
    end
  end

  describe '.journal_apply' do
    specify { expect { described_class.journal_apply }.to raise_error ArgumentError }
    specify do
      output = StringIO.new
      described_class.journal_apply(time: Time.now, output: output)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AApplying journal entries created after [+-:\\d\\s]+
No journal entries were created after the specified time
Total: \\d+s\\Z
      OUTPUT
    end

    context do
      before { journal }

      specify do
        output = StringIO.new
        expect { described_class.journal_apply(time: Time.now, output: output) }
          .to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AApplying journal entries created after [+-:\\d\\s]+
  Applying journal to \\[PlacesIndex::City, PlacesIndex::Country\\], 3 entries, stage 1
  Imported PlacesIndex::City in \\d+s, stats: index 2
  Imported PlacesIndex::Country in \\d+s, stats: index 1
Total: \\d+s\\Z
        OUTPUT
      end

      specify do
        output = StringIO.new
        expect { described_class.journal_apply(time: 3.minutes.since, output: output) }
          .not_to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AApplying journal entries created after [+-:\\d\\s]+
  Applying journal to \\[PlacesIndex::Country\\], 1 entries, stage 1
  Imported PlacesIndex::Country in \\d+s, stats: index 1
Total: \\d+s\\Z
        OUTPUT
      end

      specify do
        output = StringIO.new
        expect { described_class.journal_apply(time: Time.now, only: PlacesIndex::City, output: output) }
          .to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AApplying journal entries created after [+-:\\d\\s]+
  Applying journal to \\[PlacesIndex::City\\], 2 entries, stage 1
  Imported PlacesIndex::City in \\d+s, stats: index 2
Total: \\d+s\\Z
        OUTPUT
      end

      specify do
        output = StringIO.new
        expect { described_class.journal_apply(time: Time.now, except: PlacesIndex::City, output: output) }
          .not_to update_index(PlacesIndex::City)
        expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\AApplying journal entries created after [+-:\\d\\s]+
  Applying journal to \\[PlacesIndex::Country\\], 1 entries, stage 1
  Imported PlacesIndex::Country in \\d+s, stats: index 1
Total: \\d+s\\Z
        OUTPUT
      end
    end
  end

  describe '.journal_clean' do
    before { journal }

    specify do
      output = StringIO.new
      described_class.journal_clean(output: output)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ACleaned up 2 journal entries
Total: \\d+s\\Z
      OUTPUT
    end

    specify do
      output = StringIO.new
      described_class.journal_clean(time: 3.minutes.since, output: output)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ACleaning journal entries created before [+-:\\d\\s]+
Cleaned up 1 journal entries
Total: \\d+s\\Z
      OUTPUT
    end

    specify do
      output = StringIO.new
      described_class.journal_clean(only: PlacesIndex::City, output: output)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ACleaned up 1 journal entries
Total: \\d+s\\Z
      OUTPUT
    end

    specify do
      output = StringIO.new
      described_class.journal_clean(except: PlacesIndex::City, output: output)
      expect(output.string).to match(Regexp.new(<<-OUTPUT, Regexp::MULTILINE))
\\ACleaned up 1 journal entries
Total: \\d+s\\Z
      OUTPUT
    end
  end
end
