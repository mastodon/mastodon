# frozen_string_literal: true

require 'rails_helper'

describe 'shared/_error_messages.html.haml' do
  let(:status) { Status.new }

  before { status.errors.add :base, :invalid }

  context 'with a locale that has `one` and `other` plural values' do
    around do |example|
      I18n.with_locale(:en) do
        example.run
      end
    end

    it 'renders the view with one error' do
      render partial: 'shared/error_messages', locals: { object: status }

      expect(rendered).to match(/is invalid/)
    end
  end

  context 'with a locale that has only `other` plural value' do
    around do |example|
      I18n.with_locale(:my) do
        example.run
      end
    end

    it 'renders the view with one error' do
      render partial: 'shared/error_messages', locals: { object: status }

      expect(rendered).to match(/is invalid/)
    end
  end
end
