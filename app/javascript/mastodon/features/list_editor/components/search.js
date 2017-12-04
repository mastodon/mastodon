import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import { defineMessages, injectIntl } from 'react-intl';
import AutosuggestAccountContainer from '../../compose/containers/autosuggest_account_container';
import { fetchListSuggestions, addToListEditor } from '../../../actions/lists';
import classNames from 'classnames';

const messages = defineMessages({
  search: { id: 'lists.search', defaultMessage: 'Search among follows' },
});

const mapStateToProps = state => ({
  accountIds: state.getIn(['listEditor', 'suggestions']),
});

const mapDispatchToProps = dispatch => ({
  onSubmit: value => dispatch(fetchListSuggestions(value)),
  onAdd: accountId => dispatch(addToListEditor(accountId)),
});

@connect(mapStateToProps, mapDispatchToProps)
@injectIntl
export default class Search extends ImmutablePureComponent {

  static propTypes = {
    accountIds: ImmutablePropTypes.list.isRequired,
    intl: PropTypes.object.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onAdd: PropTypes.func.isRequired,
  };

  state = {
    value: '',
    selectedSuggestion: 0,
    suggestionsHidden: false,
  };

  handleChange = e => {
    this.setState({ value: e.target.value });
  }

  handleFocus = () => {
    this.setState({ suggestionsHidden: false });
  }

  handleBlur = () => {
    this.setState({ suggestionsHidden: true });
  }

  handleKeyUp = e => {
    if (e.keyCode === 13) {
      this.props.onSubmit(this.state.value);
    }
  }

  handleKeyDown = e => {
    const { accountIds, onAdd } = this.props;
    const { selectedSuggestion, suggestionsHidden } = this.state;

    switch(e.key) {
    case 'ArrowDown':
      if (accountIds.size > 0 && !suggestionsHidden) {
        this.setState({ selectedSuggestion: Math.min(selectedSuggestion + 1, accountIds.size - 1) });
      }

      break;
    case 'ArrowUp':
      if (accountIds.size > 0 && !suggestionsHidden) {
        this.setState({ selectedSuggestion: Math.max(selectedSuggestion - 1, 0) });
      }

      break;
    case 'Enter':
    case 'Tab':
      if (accountIds.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        e.stopPropagation();

        const accountId = accountIds.get(selectedSuggestion);

        onAdd(accountId);
        this.setState({ suggestionsHidden: true });
      }

      break;
    }
  }

  onSuggestionClick = e => {
    const accountId = this.props.accountIds.get(e.currentTarget.getAttribute('data-index'));
    e.preventDefault();

    this.props.onAdd(accountId);
    this.setState({ suggestionsHidden: true });
  }

  renderSuggestion = (accountId, i) => {
    const { selectedSuggestion } = this.state;

    return (
      <div role='button' tabIndex='0' key={accountId} data-index={i} className={classNames('autosuggest-textarea__suggestions__item', { selected: i === selectedSuggestion })} onMouseDown={this.onSuggestionClick}>
        <AutosuggestAccountContainer id={accountId} />
      </div>
    );
  }

  render () {
    const { intl, accountIds } = this.props;
    const { value, suggestionsHidden } = this.state;

    return (
      <div className='list-editor__search'>
        <label>
          <span style={{ display: 'none' }}>{intl.formatMessage(messages.search)}</span>

          <input
            type='text'
            value={value}
            onChange={this.handleChange}
            onKeyUp={this.handleKeyUp}
            onKeyDown={this.handleKeyDown}
            placeholder={intl.formatMessage(messages.search)}
            onFocus={this.handleFocus}
            onBlur={this.handleBlur}
          />
        </label>

        <div className={classNames('autosuggest-textarea__suggestions', { 'autosuggest-textarea__suggestions--visible': accountIds.size > 0 && !suggestionsHidden })}>
          {accountIds.map(this.renderSuggestion)}
        </div>
      </div>
    );
  }

}
