# frozen_string_literal: true

require 'rails_helper'

describe StatusesHelper do
  describe 'status_text_summary' do
    context 'with blank text' do
      let(:status) { Status.new(spoiler_text: '') }

      it 'returns immediately with nil' do
        result = helper.status_text_summary(status)
        expect(result).to be_nil
      end
    end

    context 'with present text' do
      let(:status) { Status.new(spoiler_text: 'SPOILERS!!!') }

      it 'returns the content warning' do
        result = helper.status_text_summary(status)
        expect(result).to eq(I18n.t('statuses.content_warning', warning: 'SPOILERS!!!'))
      end
    end
  end

  def status_text_summary(status)
    return if status.spoiler_text.blank?

    I18n.t('statuses.content_warning', warning: status.spoiler_text)
  end

  describe 'link_to_newer' do
    it 'returns a link to newer content' do
      url = 'https://example.com'
      result = helper.link_to_newer(url)

      expect(result).to match('load-more')
      expect(result).to match(I18n.t('statuses.show_newer'))
    end
  end

  describe 'link_to_older' do
    it 'returns a link to older content' do
      url = 'https://example.com'
      result = helper.link_to_older(url)

      expect(result).to match('load-more')
      expect(result).to match(I18n.t('statuses.show_older'))
    end
  end

  describe 'fa_visibility_icon' do
    context 'with a status that is public' do
      let(:status) { Status.new(visibility: 'public') }

      it 'returns the correct fa icon' do
        result = helper.fa_visibility_icon(status)

        expect(result).to match('fa-globe')
      end
    end

    context 'with a status that is unlisted' do
      let(:status) { Status.new(visibility: 'unlisted') }

      it 'returns the correct fa icon' do
        result = helper.fa_visibility_icon(status)

        expect(result).to match('fa-unlock')
      end
    end

    context 'with a status that is private' do
      let(:status) { Status.new(visibility: 'private') }

      it 'returns the correct fa icon' do
        result = helper.fa_visibility_icon(status)

        expect(result).to match('fa-lock')
      end
    end

    context 'with a status that is direct' do
      let(:status) { Status.new(visibility: 'direct') }

      it 'returns the correct fa icon' do
        result = helper.fa_visibility_icon(status)

        expect(result).to match('fa-at')
      end
    end
  end

  describe '#stream_link_target' do
    it 'returns nil if it is not an embedded view' do
      set_not_embedded_view

      expect(helper.stream_link_target).to be_nil
    end

    it 'returns _blank if it is an embedded view' do
      set_embedded_view

      expect(helper.stream_link_target).to eq '_blank'
    end
  end

  def set_not_embedded_view
    params[:controller] = "not_#{StatusesHelper::EMBEDDED_CONTROLLER}"
    params[:action] = "not_#{StatusesHelper::EMBEDDED_ACTION}"
  end

  def set_embedded_view
    params[:controller] = StatusesHelper::EMBEDDED_CONTROLLER
    params[:action] = StatusesHelper::EMBEDDED_ACTION
  end

  describe '#style_classes' do
    it do
      status = instance_double(Status, reblog?: false)
      classes = helper.style_classes(status, false, false, false)

      expect(classes).to eq 'entry'
    end

    it do
      status = instance_double(Status, reblog?: true)
      classes = helper.style_classes(status, false, false, false)

      expect(classes).to eq 'entry entry-reblog'
    end

    it do
      status = instance_double(Status, reblog?: false)
      classes = helper.style_classes(status, true, false, false)

      expect(classes).to eq 'entry entry-predecessor'
    end

    it do
      status = instance_double(Status, reblog?: false)
      classes = helper.style_classes(status, false, true, false)

      expect(classes).to eq 'entry entry-successor'
    end

    it do
      status = instance_double(Status, reblog?: false)
      classes = helper.style_classes(status, false, false, true)

      expect(classes).to eq 'entry entry-center'
    end

    it do
      status = instance_double(Status, reblog?: true)
      classes = helper.style_classes(status, true, true, true)

      expect(classes).to eq 'entry entry-predecessor entry-reblog entry-successor entry-center'
    end
  end

  describe '#microformats_classes' do
    it do
      status = instance_double(Status, reblog?: false)
      classes = helper.microformats_classes(status, false, false)

      expect(classes).to eq ''
    end

    it do
      status = instance_double(Status, reblog?: false)
      classes = helper.microformats_classes(status, true, false)

      expect(classes).to eq 'p-in-reply-to'
    end

    it do
      status = instance_double(Status, reblog?: false)
      classes = helper.microformats_classes(status, false, true)

      expect(classes).to eq 'p-comment'
    end

    it do
      status = instance_double(Status, reblog?: true)
      classes = helper.microformats_classes(status, true, false)

      expect(classes).to eq 'p-in-reply-to p-repost-of'
    end

    it do
      status = instance_double(Status, reblog?: true)
      classes = helper.microformats_classes(status, true, true)

      expect(classes).to eq 'p-in-reply-to p-repost-of p-comment'
    end
  end

  describe '#microformats_h_class' do
    it do
      status = instance_double(Status, reblog?: false)
      css_class = helper.microformats_h_class(status, false, false, false)

      expect(css_class).to eq 'h-entry'
    end

    it do
      status = instance_double(Status, reblog?: true)
      css_class = helper.microformats_h_class(status, false, false, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = instance_double(Status, reblog?: false)
      css_class = helper.microformats_h_class(status, true, false, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = instance_double(Status, reblog?: false)
      css_class = helper.microformats_h_class(status, false, true, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = instance_double(Status, reblog?: false)
      css_class = helper.microformats_h_class(status, false, false, true)

      expect(css_class).to eq ''
    end

    it do
      status = instance_double(Status, reblog?: true)
      css_class = helper.microformats_h_class(status, true, true, true)

      expect(css_class).to eq 'h-cite'
    end
  end
end
