import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import { useDispatch, useSelector } from 'react-redux';

import {
  changePollSettings,
  changePollOption,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
} from 'mastodon/actions/compose';
import AutosuggestInput from 'mastodon/components/autosuggest_input';

const messages = defineMessages({
  option_placeholder: { id: 'compose_form.poll.option_placeholder', defaultMessage: 'Option {number}' },
  duration: { id: 'compose_form.poll.duration', defaultMessage: 'Poll length' },
  type: { id: 'compose_form.poll.type', defaultMessage: 'Style' },
  switchToMultiple: { id: 'compose_form.poll.switch_to_multiple', defaultMessage: 'Change poll to allow multiple choices' },
  switchToSingle: { id: 'compose_form.poll.switch_to_single', defaultMessage: 'Change poll to allow for a single choice' },
  minutes: { id: 'intervals.full.minutes', defaultMessage: '{number, plural, one {# minute} other {# minutes}}' },
  hours: { id: 'intervals.full.hours', defaultMessage: '{number, plural, one {# hour} other {# hours}}' },
  days: { id: 'intervals.full.days', defaultMessage: '{number, plural, one {# day} other {# days}}' },
  singleChoice: { id: 'compose_form.poll.single', defaultMessage: 'Single choice' },
  multipleChoice: { id: 'compose_form.poll.multiple', defaultMessage: 'Multiple choice' },
});

const Select = ({ label, options, value, onChange }) => {
  return (
    <label className='compose-form__poll__select'>
      <span className='compose-form__poll__select__label'>{label}</span>

      <select className='compose-form__poll__select__value' value={value} onChange={onChange}>
        {options.map((option, i) => (
          <option key={i} value={option.value}>{option.label}</option>
        ))}
      </select>
    </label>
  );
};

Select.propTypes = {
  label: PropTypes.node,
  value: PropTypes.any,
  onChange: PropTypes.func,
  options: PropTypes.arrayOf(PropTypes.shape({
    label: PropTypes.node,
    value: PropTypes.any,
  })),
};

const Option = ({ multipleChoice, index, title, autoFocus }) => {
  const intl = useIntl();
  const dispatch = useDispatch();
  const suggestions = useSelector(state => state.getIn(['compose', 'suggestions']));
  const lang = useSelector(state => state.getIn(['compose', 'language']));
  const maxOptions = useSelector(state => state.getIn(['server', 'server', 'configuration', 'polls', 'max_options']));

  const handleChange = useCallback(({ target: { value } }) => {
    dispatch(changePollOption(index, value, maxOptions));
  }, [dispatch, index, maxOptions]);

  const handleSuggestionsFetchRequested = useCallback(token => {
    dispatch(fetchComposeSuggestions(token));
  }, [dispatch]);

  const handleSuggestionsClearRequested = useCallback(() => {
    dispatch(clearComposeSuggestions());
  }, [dispatch]);

  const handleSuggestionSelected = useCallback((tokenStart, token, value) => {
    dispatch(selectComposeSuggestion(tokenStart, token, value, ['poll', 'options', index]));
  }, [dispatch, index]);

  return (
    <label className={classNames('poll__option editable', { empty: index > 1 && title.length === 0 })}>
      <span className={classNames('poll__input', { checkbox: multipleChoice })} />

      <AutosuggestInput
        placeholder={intl.formatMessage(messages.option_placeholder, { number: index + 1 })}
        maxLength={50}
        value={title}
        lang={lang}
        spellCheck
        onChange={handleChange}
        suggestions={suggestions}
        onSuggestionsFetchRequested={handleSuggestionsFetchRequested}
        onSuggestionsClearRequested={handleSuggestionsClearRequested}
        onSuggestionSelected={handleSuggestionSelected}
        searchTokens={[':']}
        autoFocus={autoFocus}
      />
    </label>
  );
};

Option.propTypes = {
  title: PropTypes.string.isRequired,
  index: PropTypes.number.isRequired,
  multipleChoice: PropTypes.bool,
  autoFocus: PropTypes.bool,
};

export const PollForm = () => {
  const intl = useIntl();
  const dispatch = useDispatch();
  const poll = useSelector(state => state.getIn(['compose', 'poll']));
  const options = poll?.get('options');
  const expiresIn = poll?.get('expires_in');
  const isMultiple = poll?.get('multiple');

  const handleDurationChange = useCallback(({ target: { value } }) => {
    dispatch(changePollSettings(value, isMultiple));
  }, [dispatch, isMultiple]);

  const handleTypeChange = useCallback(({ target: { value } }) => {
    dispatch(changePollSettings(expiresIn, value === 'true'));
  }, [dispatch, expiresIn]);

  if (poll === null) {
    return null;
  }

  return (
    <div className='compose-form__poll'>
      {options.map((title, i) => (
        <Option
          title={title}
          key={i}
          index={i}
          multipleChoice={isMultiple}
          autoFocus={i === 0}
        />
      ))}

      <div className='compose-form__poll__footer'>
        <Select label={intl.formatMessage(messages.duration)} options={[
          { value: 300, label: intl.formatMessage(messages.minutes, { number: 5 })},
          { value: 1800, label: intl.formatMessage(messages.minutes, { number: 30 })},
          { value: 3600, label: intl.formatMessage(messages.hours, { number: 1 })},
          { value: 21600, label: intl.formatMessage(messages.hours, { number: 6 })},
          { value: 43200, label: intl.formatMessage(messages.hours, { number: 12 })},
          { value: 86400, label: intl.formatMessage(messages.days, { number: 1 })},
          { value: 259200, label: intl.formatMessage(messages.days, { number: 3 })},
          { value: 604800, label: intl.formatMessage(messages.days, { number: 7 })},
        ]} value={expiresIn} onChange={handleDurationChange} />

        <div className='compose-form__poll__footer__sep' />

        <Select label={intl.formatMessage(messages.type)} options={[
          { value: false, label: intl.formatMessage(messages.singleChoice) },
          { value: true, label: intl.formatMessage(messages.multipleChoice) },
        ]} value={isMultiple} onChange={handleTypeChange} />
      </div>
    </div>
  );
};
