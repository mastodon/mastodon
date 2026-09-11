# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin TermsOfService Drafts' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  describe 'Managing TOS drafts' do
    context 'when a draft TOS record exists' do
      let!(:terms) { Fabricate :terms_of_service, published_at: nil }

      it 'saves and publishes TOS drafts' do
        visit admin_terms_of_service_draft_path
        expect(page)
          .to have_title(I18n.t('admin.terms_of_service.title'))

        # Invalid submission
        expect { click_on I18n.t('admin.terms_of_service.save_draft') }
          .to_not(change { terms.reload.published_at })
        expect(page)
          .to have_title(I18n.t('admin.terms_of_service.title'))

        # Valid submission with draft button
        fill_in 'terms_of_service_text', with: 'new'
        expect { click_on I18n.t('admin.terms_of_service.save_draft') }
          .to not_change { terms.reload.published_at }.from(nil)
          .and not_change(Admin::ActionLog, :count)
        expect(page)
          .to have_title(I18n.t('admin.terms_of_service.title'))

        # Valid with publish button
        fill_in 'terms_of_service_text', with: 'newer'
        expect { click_on I18n.t('admin.terms_of_service.publish') }
          .to change { terms.reload.published_at }.from(nil)
          .and change(Admin::ActionLog, :count)
        expect(page)
          .to have_title(I18n.t('admin.terms_of_service.title'))
      end
    end

    context 'when a live TOS record exists' do
      before do
        travel_to 5.days.ago do
          Fabricate :terms_of_service, published_at: 2.days.ago, effective_date: 1.day.from_now
        end
      end

      it 'populates an unsaved record with prior text' do
        visit admin_terms_of_service_draft_path
        expect(page)
          .to have_title(I18n.t('admin.terms_of_service.title'))

        # Valid submission with draft button
        expect { click_on I18n.t('admin.terms_of_service.save_draft') }
          .to change(TermsOfService, :count).by(1)
          .and not_change(Admin::ActionLog, :count)
        expect(TermsOfService.current.text)
          .to eq(TermsOfService.draft.last.text)
        expect(page)
          .to have_title(I18n.t('admin.terms_of_service.title'))
      end
    end

    context 'when there are no TOS records' do
      it 'builds an unsaved record for editing' do
        visit admin_terms_of_service_draft_path
        expect(page)
          .to have_title(I18n.t('admin.terms_of_service.title'))

        # Valid submission with draft button
        fill_in 'terms_of_service_text', with: 'new'
        expect { click_on I18n.t('admin.terms_of_service.save_draft') }
          .to change(TermsOfService, :count).by(1)
          .and not_change(Admin::ActionLog, :count)
        expect(page)
          .to have_title(I18n.t('admin.terms_of_service.title'))
      end
    end
  end
end
