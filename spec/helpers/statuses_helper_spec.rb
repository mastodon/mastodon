require 'rails_helper'

RSpec.describe StatusesHelper, type: :helper do
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
      status = double(reblog?: false)
      classes = helper.style_classes(status, false, false, false)

      expect(classes).to eq 'entry'
    end

    it do
      status = double(reblog?: true)
      classes = helper.style_classes(status, false, false, false)

      expect(classes).to eq 'entry entry-reblog'
    end

    it do
      status = double(reblog?: false)
      classes = helper.style_classes(status, true, false, false)

      expect(classes).to eq 'entry entry-predecessor'
    end

    it do
      status = double(reblog?: false)
      classes = helper.style_classes(status, false, true, false)

      expect(classes).to eq 'entry entry-successor'
    end

    it do
      status = double(reblog?: false)
      classes = helper.style_classes(status, false, false, true)

      expect(classes).to eq 'entry entry-center'
    end

    it do
      status = double(reblog?: true)
      classes = helper.style_classes(status, true, true, true)

      expect(classes).to eq 'entry entry-predecessor entry-reblog entry-successor entry-center'
    end
  end

  describe '#microformats_classes' do
    it do
      status = double(reblog?: false)
      classes = helper.microformats_classes(status, false, false)

      expect(classes).to eq ''
    end

    it do
      status = double(reblog?: false)
      classes = helper.microformats_classes(status, true, false)

      expect(classes).to eq 'p-in-reply-to'
    end

    it do
      status = double(reblog?: false)
      classes = helper.microformats_classes(status, false, true)

      expect(classes).to eq 'p-comment'
    end

    it do
      status = double(reblog?: true)
      classes = helper.microformats_classes(status, true, false)

      expect(classes).to eq 'p-in-reply-to p-repost-of'
    end

    it do
      status = double(reblog?: true)
      classes = helper.microformats_classes(status, true, true)

      expect(classes).to eq 'p-in-reply-to p-repost-of p-comment'
    end
  end

  describe '#microformats_h_class' do
    it do
      status = double(reblog?: false)
      css_class = helper.microformats_h_class(status, false, false, false)

      expect(css_class).to eq 'h-entry'
    end

    it do
      status = double(reblog?: true)
      css_class = helper.microformats_h_class(status, false, false, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = double(reblog?: false)
      css_class = helper.microformats_h_class(status, true, false, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = double(reblog?: false)
      css_class = helper.microformats_h_class(status, false, true, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = double(reblog?: false)
      css_class = helper.microformats_h_class(status, false, false, true)

      expect(css_class).to eq ''
    end

    it do
      status = double(reblog?: true)
      css_class = helper.microformats_h_class(status, true, true, true)

      expect(css_class).to eq 'h-cite'
    end
  end
end
