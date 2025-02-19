# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Rules' do
  describe 'Managing rules' do
    before { sign_in Fabricate(:admin_user) }

    describe 'Viewing rules' do
      let!(:rule) { Fabricate :rule, text: 'This is a rule' }

      it 'lists existing records' do
        visit admin_rules_path

        expect(page)
          .to have_content(I18n.t('admin.rules.title'))
          .and have_content(rule.text)

        click_on(rule.text)
        expect(page)
          .to have_content(I18n.t('admin.rules.title'))
      end
    end

    describe 'Creating a new rule' do
      it 'creates new record with valid attributes' do
        visit admin_rules_path

        # Invalid submission
        fill_in 'rule_text', with: ''
        expect { submit_form }
          .to_not change(Rule, :count)
        expect(page)
          .to have_content(/error below/)

        # Valid submission
        fill_in 'rule_text', with: 'No yelling on the bus!'
        expect { submit_form }
          .to change(Rule, :count).by(1)
        expect(page)
          .to have_content(I18n.t('admin.rules.title'))
      end

      def submit_form
        click_on I18n.t('admin.rules.add_new')
      end
    end

    describe 'Editing an existing rule' do
      let!(:rule) { Fabricate :rule, text: 'Rule text' }

      it 'updates with valid attributes' do
        visit admin_rules_path

        # Invalid submission
        click_on rule.text
        fill_in 'rule_text', with: ''
        expect { submit_form }
          .to_not change(rule.reload, :updated_at)

        # Valid update
        fill_in 'rule_text', with: 'What day is this?'
        expect { submit_form }
          .to(change { rule.reload.text })
      end

      def submit_form
        click_on I18n.t('generic.save_changes')
      end
    end

    describe 'Destroy a rule' do
      let!(:rule) { Fabricate :rule }

      it 'removes the record' do
        visit admin_rules_path

        expect { click_on I18n.t('admin.rules.delete') }
          .to change { rule.reload.discarded? }.to(true)
      end
    end
  end
end
