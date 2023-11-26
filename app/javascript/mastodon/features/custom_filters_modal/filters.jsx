import PropTypes from 'prop-types';
import * as React from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { ReactComponent as AddIcon } from '@material-symbols/svg-600/outlined/add.svg';
import fuzzysort from 'fuzzysort';

import { Icon } from 'mastodon/components/icon';
import { toServerSideType } from 'mastodon/utils/filters';
import { loupeIcon, deleteIcon } from 'mastodon/utils/icons';

import { CustomFilterTypes } from './custom_filter_types';

const messages = defineMessages({
  title:            { id: 'custom_filters_modal.filters.title',            defaultMessage: 'Filter this {entity}' },
  account_entity:   { id: 'custom_filters_modal.filters.entity.account',   defaultMessage: 'account' },
  status_entity:    { id: 'custom_filters_modal.filters.entity.post',      defaultMessage: 'post' },
  subtitle:         { id: 'custom_filters_modal.filters.subtitle',         defaultMessage: 'Use an existing filter or create a new one' },
  expired:          { id: 'custom_filters_modal.filters.expired',          defaultMessage: 'expired' },
  context_mismatch: { id: 'custom_filters_modal.filters.context_mismatch', defaultMessage: 'does not apply to this context' },
  prompt_new:       { id: 'custom_filters_modal.filters.prompt_new',       defaultMessage: 'Create new filter: {name}...' },
  search:           { id: 'custom_filters_modal.filters.search',           defaultMessage: 'Search or create' },
  clear:            { id: 'emoji_button.clear',                            defaultMessage: 'Clear' },
});

const mapStateToProps = (state, { contextType }) => ({
  filters: Array.from(state.get('filters').values()).map((filter) => [
    filter.get('id'),
    filter.get('title'),
    filter.get('keywords')?.map((keyword) => keyword.get('keyword')).join('\n'),
    filter.get('expires_at') && filter.get('expires_at') < new Date(),
    contextType && !filter.get('context').includes(toServerSideType(contextType)),
  ]),
});

class Filters extends React.PureComponent {
  static propTypes = {
    onSelectFilter: PropTypes.func.isRequired,
    onNewFilter: PropTypes.func.isRequired,
    filters: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.object)),
    filterType: PropTypes.oneOf(CustomFilterTypes).isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    searchValue: '',
  };

  search() {
    const { filters } = this.props;
    const { searchValue } = this.state;

    if (searchValue === '') {
      return filters;
    }

    return fuzzysort.go(searchValue, filters, {
      keys: ['1', '2'],
      limit: 5,
      threshold: -10000,
    }).map(result => result.obj);
  }

  renderItem = filter => {
    let warning = null;
    if (filter[3] || filter[4]) {
      warning = (
        <span className='language-dropdown__dropdown__results__item__common-name'>
          (
          {filter[3] && <FormattedMessage {...messages.expired} />}
          {filter[3] && filter[4] && ', '}
          {filter[4] && <FormattedMessage {...messages.context_mismatch} />}
          )
        </span>
      );
    }

    return (
      <div key={filter[0]} role='button' tabIndex={0} data-index={filter[0]} className='language-dropdown__dropdown__results__item' onClick={this.handleItemClick} onKeyDown={this.handleKeyDown}>
        <span className='language-dropdown__dropdown__results__item__native-name'>{filter[1]}</span> {warning}
      </div>
    );
  };

  renderCreateNew (name) {
    return (
      <div key='add-new-filter' role='button' tabIndex={0} className='language-dropdown__dropdown__results__item' onClick={this.handleNewFilterClick} onKeyDown={this.handleKeyDown}>
        <Icon id='plus' icon={AddIcon} /> <FormattedMessage {...messages.prompt_new} values={{ name }} />
      </div>
    );
  }

  handleSearchChange = ({ target }) => {
    this.setState({ searchValue: target.value });
  };

  setListRef = c => {
    this.listNode = c;
  };

  handleKeyDown = e => {
    const index = Array.from(this.listNode.childNodes).findIndex(node => node === e.currentTarget);

    let element = null;

    switch(e.key) {
    case ' ':
    case 'Enter':
      e.currentTarget.click();
      break;
    case 'ArrowDown':
      element = this.listNode.childNodes[index + 1] || this.listNode.firstChild;
      break;
    case 'ArrowUp':
      element = this.listNode.childNodes[index - 1] || this.listNode.lastChild;
      break;
    case 'Tab':
      if (e.shiftKey) {
        element = this.listNode.childNodes[index - 1] || this.listNode.lastChild;
      } else {
        element = this.listNode.childNodes[index + 1] || this.listNode.firstChild;
      }
      break;
    case 'Home':
      element = this.listNode.firstChild;
      break;
    case 'End':
      element = this.listNode.lastChild;
      break;
    }

    if (element) {
      element.focus();
      e.preventDefault();
      e.stopPropagation();
    }
  };

  handleSearchKeyDown = e => {
    let element = null;

    switch(e.key) {
    case 'Tab':
    case 'ArrowDown':
      element = this.listNode.firstChild;

      if (element) {
        element.focus();
        e.preventDefault();
        e.stopPropagation();
      }

      break;
    }
  };

  handleClear = () => {
    this.setState({ searchValue: '' });
  };

  handleItemClick = e => {
    const value = e.currentTarget.getAttribute('data-index');

    e.preventDefault();

    this.props.onSelectFilter(value);
  };

  handleNewFilterClick = e => {
    e.preventDefault();

    this.props.onNewFilter(this.state.searchValue);
  };

  entityMessage() {
    switch (this.props.filterType) {
    case CustomFilterTypes.Account:
      return this.props.intl.formatMessage(messages.account_entity);
    case CustomFilterTypes.Status:
      return this.props.intl.formatMessage(messages.status_entity);
    default:
      return null;
    }
  }

  render () {
    const { intl } = this.props;

    const { searchValue } = this.state;
    const isSearching = searchValue !== '';
    const results = this.search();

    return (
      <>
        <h3 className='report-dialog-modal__title'><FormattedMessage {...messages.title} values={{ entity: this.entityMessage() }} /></h3>
        <p className='report-dialog-modal__lead'><FormattedMessage {...messages.subtitle} /></p>

        <div className='emoji-mart-search'>
          <input type='search' value={searchValue} onChange={this.handleSearchChange} onKeyDown={this.handleSearchKeyDown} placeholder={intl.formatMessage(messages.search)} autoFocus />
          <button type='button' className='emoji-mart-search-icon' disabled={!isSearching} aria-label={intl.formatMessage(messages.clear)} onClick={this.handleClear}>{!isSearching ? loupeIcon : deleteIcon}</button>
        </div>

        <div className='language-dropdown__dropdown__results emoji-mart-scroll' role='listbox' ref={this.setListRef}>
          {results.map(this.renderItem)}
          {isSearching && this.renderCreateNew(searchValue) }
        </div>

      </>
    );
  }
}

export default connect(mapStateToProps)(injectIntl(Filters));
