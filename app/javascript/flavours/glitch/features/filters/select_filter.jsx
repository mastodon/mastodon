import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { toServerSideType } from 'flavours/glitch/utils/filters';
import { loupeIcon, deleteIcon } from 'flavours/glitch/utils/icons';
import Icon from 'flavours/glitch/components/icon';
import fuzzysort from 'fuzzysort';

const messages = defineMessages({
  search: { id: 'filter_modal.select_filter.search', defaultMessage: 'Search or create' },
  clear: { id: 'emoji_button.clear', defaultMessage: 'Clear' },
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

class SelectFilter extends React.PureComponent {

  static propTypes = {
    onSelectFilter: PropTypes.func.isRequired,
    onNewFilter: PropTypes.func.isRequired,
    filters: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.object)),
    intl: PropTypes.object.isRequired,
  };

  state = {
    searchValue: '',
  };

  search () {
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
          {filter[3] && <FormattedMessage id='filter_modal.select_filter.expired' defaultMessage='expired' />}
          {filter[3] && filter[4] && ', '}
          {filter[4] && <FormattedMessage id='filter_modal.select_filter.context_mismatch' defaultMessage='does not apply to this context' />}
          )
        </span>
      );
    }

    return (
      <div key={filter[0]} role='button' tabIndex='0' data-index={filter[0]} className='language-dropdown__dropdown__results__item' onClick={this.handleItemClick} onKeyDown={this.handleKeyDown}>
        <span className='language-dropdown__dropdown__results__item__native-name'>{filter[1]}</span> {warning}
      </div>
    );
  };

  renderCreateNew (name) {
    return (
      <div key='add-new-filter' role='button' tabIndex='0' className='language-dropdown__dropdown__results__item' onClick={this.handleNewFilterClick} onKeyDown={this.handleKeyDown}>
        <Icon id='plus' fixedWidth /> <FormattedMessage id='filter_modal.select_filter.prompt_new' defaultMessage='New category: {name}' values={{ name }} />
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

  render () {
    const { intl } = this.props;

    const { searchValue } = this.state;
    const isSearching = searchValue !== '';
    const results = this.search();

    return (
      <React.Fragment>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='filter_modal.select_filter.title' defaultMessage='Filter this post' /></h3>
        <p className='report-dialog-modal__lead'><FormattedMessage id='filter_modal.select_filter.subtitle' defaultMessage='Use an existing category or create a new one' /></p>

        <div className='emoji-mart-search'>
          <input type='search' value={searchValue} onChange={this.handleSearchChange} onKeyDown={this.handleSearchKeyDown} placeholder={intl.formatMessage(messages.search)} autoFocus />
          <button className='emoji-mart-search-icon' disabled={!isSearching} aria-label={intl.formatMessage(messages.clear)} onClick={this.handleClear}>{!isSearching ? loupeIcon : deleteIcon}</button>
        </div>

        <div className='language-dropdown__dropdown__results emoji-mart-scroll' role='listbox' ref={this.setListRef}>
          {results.map(this.renderItem)}
          {isSearching && this.renderCreateNew(searchValue) }
        </div>

      </React.Fragment>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(SelectFilter));
