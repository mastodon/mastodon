# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class PriorityInputTest < ActionView::TestCase
  test 'input generates a country select field' do
    with_input_for @user, :country, :country
    assert_select 'select#user_country'
    if ActionPack::VERSION::STRING >= '5'
      assert_select 'select option[value=BR]', 'Brazil'
    elsif ActionPack::VERSION::STRING < '5'
      assert_select 'select option[value=Brazil]', 'Brazil'
    end
    assert_no_select 'select option[value=""][disabled=disabled]'
  end

  test 'input generates a country select with SimpleForm default' do
    swap SimpleForm, country_priority: [ 'Brazil' ] do
      with_input_for @user, :country, :country
      if ActionPack::VERSION::STRING >= '5'
        assert_select 'select option[value="---------------"][disabled=disabled]'
      elsif ActionPack::VERSION::STRING < '5'
        assert_select 'select option[value=""][disabled=disabled]'
      end
    end
  end

  test 'input generates a time zone select field' do
    with_input_for @user, :time_zone, :time_zone
    assert_select 'select#user_time_zone'
    assert_select 'select option[value=Brasilia]', '(GMT-03:00) Brasilia'
    assert_no_select 'select option[value=""][disabled=disabled]'
  end

  test 'input generates a time zone select field with default' do
    with_input_for @user, :time_zone, :time_zone, default: 'Brasilia'
    assert_select 'select option[value=Brasilia][selected=selected]'
    assert_no_select 'select option[value=""]'
  end

  test 'input generates a time zone select using options priority' do
    with_input_for @user, :time_zone, :time_zone, priority: /Brasilia/
    assert_select 'select option[value=""][disabled=disabled]'
    assert_no_select 'select option[value=""]', /^$/
  end

  test 'priority input does not generate invalid required html attribute' do
    with_input_for @user, :country, :country
    assert_select 'select.required'
    assert_no_select 'select[required]'
  end

  test 'priority input does not generate invalid aria-required html attribute' do
    with_input_for @user, :country, :country
    assert_select 'select.required'
    assert_no_select 'select[aria-required]'
  end
end
