# frozen_string_literal: true

shared_examples 'ScopedSettings' do
  describe '[]' do
    it 'inherits default settings' do
      expect(Setting.boost_modal).to be false
      expect(Setting.interactions['must_be_follower']).to be false

      settings = create!

      expect(settings['boost_modal']).to be false
      expect(settings['interactions']['must_be_follower']).to be false
    end
  end

  describe 'all_as_records' do
    # expecting [] and []= works

    it 'returns records merged with default values except hashes' do
      expect(Setting.boost_modal).to be false
      expect(Setting.delete_modal).to be true

      settings = create!
      settings['boost_modal'] = true

      records = settings.all_as_records

      expect(records['boost_modal'].value).to be true
      expect(records['delete_modal'].value).to be true
    end
  end

  describe 'missing methods' do
    # expecting [] and []= works.

    it 'reads settings' do
      expect(Setting.boost_modal).to be false
      settings = create!
      expect(settings.boost_modal).to be false
    end

    it 'updates settings' do
      settings = fabricate
      settings.boost_modal = true
      expect(settings['boost_modal']).to be true
    end
  end

  it 'can update settings with [] and can read with []=' do
    settings = fabricate

    settings['boost_modal'] = true
    settings['interactions'] = settings['interactions'].merge('must_be_follower' => true)

    Setting.save!

    expect(settings['boost_modal']).to be true
    expect(settings['interactions']['must_be_follower']).to be true

    Rails.cache.clear

    expect(settings['boost_modal']).to be true
    expect(settings['interactions']['must_be_follower']).to be true
  end

  xit 'does not mutate defaults via the cache' do
    fabricate['interactions']['must_be_follower'] = true
    # TODO
    # This mutates the global settings default such that future
    # instances will inherit the incorrect starting values

    expect(fabricate.settings['interactions']['must_be_follower']).to be false
  end
end
