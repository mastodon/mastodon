import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import AutosuggestInput from 'flavours/glitch/components/autosuggest_input';
import { Icon } from 'flavours/glitch/components/icon';
import { IconButton } from 'flavours/glitch/components/icon_button';
import { pollLimits } from 'flavours/glitch/initial_state';

const messages = defineMessages({
  option_placeholder: { id: 'compose_form.poll.option_placeholder', defaultMessage: 'Choice {number}' },
  add_option: { id: 'compose_form.poll.add_option', defaultMessage: 'Add a choice' },
  remove_option: { id: 'compose_form.poll.remove_option', defaultMessage: 'Remove this choice' },
  poll_duration: { id: 'compose_form.poll.duration', defaultMessage: 'Poll duration' },
  single_choice: { id: 'compose_form.poll.single_choice', defaultMessage: 'Allow one choice' },
  multiple_choices: { id: 'compose_form.poll.multiple_choices', defaultMessage: 'Allow multiple choices' },
  minutes: { id: 'intervals.full.minutes', defaultMessage: '{number, plural, one {# minute} other {# minutes}}' },
  hours: { id: 'intervals.full.hours', defaultMessage: '{number, plural, one {# hour} other {# hours}}' },
  days: { id: 'intervals.full.days', defaultMessage: '{number, plural, one {# day} other {# days}}' },
});

class OptionIntl extends PureComponent {

  static propTypes = {
    title: PropTypes.string.isRequired,
    lang: PropTypes.string,
    index: PropTypes.number.isRequired,
    isPollMultiple: PropTypes.bool,
    autoFocus: PropTypes.bool,
    onChange: PropTypes.func.isRequired,
    onRemove: PropTypes.func.isRequired,
    suggestions: ImmutablePropTypes.list,
    onClearSuggestions: PropTypes.func.isRequired,
    onFetchSuggestions: PropTypes.func.isRequired,
    onSuggestionSelected: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleOptionTitleChange = e => {
    this.props.onChange(this.props.index, e.target.value);
  };

  handleOptionRemove = () => {
    this.props.onRemove(this.props.index);
  };

  onSuggestionsClearRequested = () => {
    this.props.onClearSuggestions();
  };

  onSuggestionsFetchRequested = (token) => {
    this.props.onFetchSuggestions(token);
  };

  onSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['poll', 'options', this.props.index]);
  };

  render () {
    const { isPollMultiple, title, lang, index, autoFocus, intl } = this.props;

    return (
      <li>
        <label className='poll__option editable'>
          <span className={classNames('poll__input', { checkbox: isPollMultiple })} />

          <AutosuggestInput
            placeholder={intl.formatMessage(messages.option_placeholder, { number: index + 1 })}
            maxLength={pollLimits.max_option_chars}
            value={title}
            lang={lang}
            spellCheck
            onChange={this.handleOptionTitleChange}
            suggestions={this.props.suggestions}
            onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
            onSuggestionsClearRequested={this.onSuggestionsClearRequested}
            onSuggestionSelected={this.onSuggestionSelected}
            searchTokens={[':']}
            autoFocus={autoFocus}
          />
        </label>

        <div className='poll__cancel'>
          <IconButton disabled={index <= 1} title={intl.formatMessage(messages.remove_option)} icon='times' onClick={this.handleOptionRemove} />
        </div>
      </li>
    );
  }

}

const Option = injectIntl(OptionIntl);

class PollForm extends ImmutablePureComponent {

  static propTypes = {
    options: ImmutablePropTypes.list,
    lang: PropTypes.string,
    expiresIn: PropTypes.number,
    isMultiple: PropTypes.bool,
    onChangeOption: PropTypes.func.isRequired,
    onAddOption: PropTypes.func.isRequired,
    onRemoveOption: PropTypes.func.isRequired,
    onChangeSettings: PropTypes.func.isRequired,
    suggestions: ImmutablePropTypes.list,
    onClearSuggestions: PropTypes.func.isRequired,
    onFetchSuggestions: PropTypes.func.isRequired,
    onSuggestionSelected: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleAddOption = () => {
    this.props.onAddOption('');
  };

  handleSelectDuration = e => {
    this.props.onChangeSettings(e.target.value, this.props.isMultiple);
  };

  handleSelectMultiple = e => {
    this.props.onChangeSettings(this.props.expiresIn, e.target.value === 'true');
  };

  render () {
    const { options, lang, expiresIn, isMultiple, onChangeOption, onRemoveOption, intl, ...other } = this.props;

    if (!options) {
      return null;
    }

    const autoFocusIndex = options.indexOf('');

    return (
      <div className='compose-form__poll-wrapper'>
        <ul>
          {options.map((title, i) => <Option title={title} lang={lang} key={i} index={i} onChange={onChangeOption} onRemove={onRemoveOption} isPollMultiple={isMultiple} autoFocus={i === autoFocusIndex} {...other} />)}
          {options.size < pollLimits.max_options && (
            <label className='poll__text editable'>
              <span className={classNames('poll__input')} style={{ opacity: 0 }} />
              <button className='button button-secondary' onClick={this.handleAddOption}><Icon id='plus' /> <FormattedMessage {...messages.add_option} /></button>
            </label>
          )}
        </ul>

        <div className='poll__footer'>
          {/* eslint-disable-next-line jsx-a11y/no-onchange */}
          <select value={isMultiple ? 'true' : 'false'} onChange={this.handleSelectMultiple}>
            <option value='false'>{intl.formatMessage(messages.single_choice)}</option>
            <option value='true'>{intl.formatMessage(messages.multiple_choices)}</option>
          </select>

          {/* eslint-disable-next-line jsx-a11y/no-onchange */}
          <select value={expiresIn} onChange={this.handleSelectDuration}>
            <option value={300}>{intl.formatMessage(messages.minutes, { number: 5 })}</option>
            <option value={1800}>{intl.formatMessage(messages.minutes, { number: 30 })}</option>
            <option value={3600}>{intl.formatMessage(messages.hours, { number: 1 })}</option>
            <option value={21600}>{intl.formatMessage(messages.hours, { number: 6 })}</option>
            <option value={43200}>{intl.formatMessage(messages.hours, { number: 12 })}</option>
            <option value={86400}>{intl.formatMessage(messages.days, { number: 1 })}</option>
            <option value={259200}>{intl.formatMessage(messages.days, { number: 3 })}</option>
            <option value={604800}>{intl.formatMessage(messages.days, { number: 7 })}</option>
          </select>
        </div>
      </div>
    );
  }

}

export default injectIntl(PollForm);
