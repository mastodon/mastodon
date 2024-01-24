import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl, FormattedMessage, FormattedList } from 'react-intl';

import classNames from 'classnames';
import { withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';


import CancelIcon from '@/material-icons/400-24px/cancel-fill.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import { Icon }  from 'flavours/glitch/components/icon';
import { domain, searchEnabled } from 'flavours/glitch/initial_state';
import { HASHTAG_REGEX } from 'flavours/glitch/utils/hashtags';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' },
  placeholderSignedIn: { id: 'search.search_or_paste', defaultMessage: 'Search or paste URL' },
});

const labelForRecentSearch = search => {
  switch(search.get('type')) {
  case 'account':
    return `@${search.get('q')}`;
  case 'hashtag':
    return `#${search.get('q')}`;
  default:
    return search.get('q');
  }
};

class Search extends PureComponent {

  static contextTypes = {
    identity: PropTypes.object.isRequired,
  };

  static propTypes = {
    value: PropTypes.string.isRequired,
    recent: ImmutablePropTypes.orderedSet,
    submitted: PropTypes.bool,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onOpenURL: PropTypes.func.isRequired,
    onClickSearchResult: PropTypes.func.isRequired,
    onForgetSearchResult: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
    onShow: PropTypes.func.isRequired,
    openInRoute: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    singleColumn: PropTypes.bool,
    ...WithRouterPropTypes,
  };

  state = {
    expanded: false,
    selectedOption: -1,
    options: [],
  };

  defaultOptions = [
    { key: 'prompt-has', label: <><mark>has:</mark> <FormattedList type='disjunction' value={['media', 'poll', 'embed']} /></>, action: e => { e.preventDefault(); this._insertText('has:'); } },
    { key: 'prompt-is', label: <><mark>is:</mark> <FormattedList type='disjunction' value={['reply', 'sensitive']} /></>, action: e => { e.preventDefault(); this._insertText('is:'); } },
    { key: 'prompt-language', label: <><mark>language:</mark> <FormattedMessage id='search_popout.language_code' defaultMessage='ISO language code' /></>, action: e => { e.preventDefault(); this._insertText('language:'); } },
    { key: 'prompt-from', label: <><mark>from:</mark> <FormattedMessage id='search_popout.user' defaultMessage='user' /></>, action: e => { e.preventDefault(); this._insertText('from:'); } },
    { key: 'prompt-before', label: <><mark>before:</mark> <FormattedMessage id='search_popout.specific_date' defaultMessage='specific date' /></>, action: e => { e.preventDefault(); this._insertText('before:'); } },
    { key: 'prompt-during', label: <><mark>during:</mark> <FormattedMessage id='search_popout.specific_date' defaultMessage='specific date' /></>, action: e => { e.preventDefault(); this._insertText('during:'); } },
    { key: 'prompt-after', label: <><mark>after:</mark> <FormattedMessage id='search_popout.specific_date' defaultMessage='specific date' /></>, action: e => { e.preventDefault(); this._insertText('after:'); } },
    { key: 'prompt-in', label: <><mark>in:</mark> <FormattedList type='disjunction' value={['all', 'library', 'public']} /></>, action: e => { e.preventDefault(); this._insertText('in:'); } }
  ];

  setRef = c => {
    this.searchForm = c;
  };

  handleChange = ({ target }) => {
    const { onChange } = this.props;

    onChange(target.value);

    this._calculateOptions(target.value);
  };

  handleClear = e => {
    const { value, submitted, onClear } = this.props;

    e.preventDefault();

    if (value.length > 0 || submitted) {
      onClear();
      this.setState({ options: [], selectedOption: -1 });
    }
  };

  handleKeyDown = (e) => {
    const { selectedOption } = this.state;
    const options = searchEnabled ? this._getOptions().concat(this.defaultOptions) : this._getOptions();

    switch(e.key) {
    case 'Escape':
      e.preventDefault();
      this._unfocus();

      break;
    case 'ArrowDown':
      e.preventDefault();

      if (options.length > 0) {
        this.setState({ selectedOption: Math.min(selectedOption + 1, options.length - 1) });
      }

      break;
    case 'ArrowUp':
      e.preventDefault();

      if (options.length > 0) {
        this.setState({ selectedOption: Math.max(selectedOption - 1, -1) });
      }

      break;
    case 'Enter':
      e.preventDefault();

      if (selectedOption === -1) {
        this._submit();
      } else if (options.length > 0) {
        options[selectedOption].action(e);
      }

      break;
    case 'Delete':
      if (selectedOption > -1 && options.length > 0) {
        const search = options[selectedOption];

        if (typeof search.forget === 'function') {
          e.preventDefault();
          search.forget(e);
        }
      }

      break;
    }
  };

  handleFocus = () => {
    const { onShow, singleColumn } = this.props;

    this.setState({ expanded: true, selectedOption: -1 });
    onShow();

    if (this.searchForm && !singleColumn) {
      const { left, right } = this.searchForm.getBoundingClientRect();

      if (left < 0 || right > (window.innerWidth || document.documentElement.clientWidth)) {
        this.searchForm.scrollIntoView();
      }
    }
  };

  handleBlur = () => {
    this.setState({ expanded: false, selectedOption: -1 });
  };

  handleHashtagClick = () => {
    const { value, onClickSearchResult, history } = this.props;

    const query = value.trim().replace(/^#/, '');

    history.push(`/tags/${query}`);
    onClickSearchResult(query, 'hashtag');
    this._unfocus();
  };

  handleAccountClick = () => {
    const { value, onClickSearchResult, history } = this.props;

    const query = value.trim().replace(/^@/, '');

    history.push(`/@${query}`);
    onClickSearchResult(query, 'account');
    this._unfocus();
  };

  handleURLClick = () => {
    const { onOpenURL, history } = this.props;

    onOpenURL(history);
    this._unfocus();
  };

  handleStatusSearch = () => {
    this._submit('statuses');
  };

  handleAccountSearch = () => {
    this._submit('accounts');
  };

  handleRecentSearchClick = search => {
    const { onChange, history } = this.props;

    if (search.get('type') === 'account') {
      history.push(`/@${search.get('q')}`);
    } else if (search.get('type') === 'hashtag') {
      history.push(`/tags/${search.get('q')}`);
    } else {
      onChange(search.get('q'));
      this._submit(search.get('type'));
    }

    this._unfocus();
  };

  handleForgetRecentSearchClick = search => {
    const { onForgetSearchResult } = this.props;

    onForgetSearchResult(search.get('q'));
  };

  _unfocus () {
    document.querySelector('.ui').parentElement.focus();
  }

  _insertText (text) {
    const { value, onChange } = this.props;

    if (value === '') {
      onChange(text);
    } else if (value[value.length - 1] === ' ') {
      onChange(`${value}${text}`);
    } else {
      onChange(`${value} ${text}`);
    }
  }

  _submit (type) {
    const { onSubmit, openInRoute, value, onClickSearchResult, history } = this.props;

    onSubmit(type);

    if (value) {
      onClickSearchResult(value, type);
    }

    if (openInRoute) {
      history.push('/search');
    }

    this._unfocus();
  }

  _getOptions () {
    const { options } = this.state;

    if (options.length > 0) {
      return options;
    }

    const { recent } = this.props;

    return recent.toArray().map(search => ({
      key: `${search.get('type')}/${search.get('q')}`,

      label: labelForRecentSearch(search),

      action: () => this.handleRecentSearchClick(search),

      forget: e => {
        e.stopPropagation();
        this.handleForgetRecentSearchClick(search);
      },
    }));
  }

  _calculateOptions (value) {
    const { signedIn } = this.context.identity;
    const trimmedValue = value.trim();
    const options = [];

    if (trimmedValue.length > 0) {
      const couldBeURL = trimmedValue.startsWith('https://') && !trimmedValue.includes(' ');

      if (couldBeURL) {
        options.push({ key: 'open-url', label: <FormattedMessage id='search.quick_action.open_url' defaultMessage='Open URL in Mastodon' />, action: this.handleURLClick });
      }

      const couldBeHashtag = (trimmedValue.startsWith('#') && trimmedValue.length > 1) || trimmedValue.match(HASHTAG_REGEX);

      if (couldBeHashtag) {
        options.push({ key: 'go-to-hashtag', label: <FormattedMessage id='search.quick_action.go_to_hashtag' defaultMessage='Go to hashtag {x}' values={{ x: <mark>#{trimmedValue.replace(/^#/, '')}</mark> }} />, action: this.handleHashtagClick });
      }

      const couldBeUsername = trimmedValue.match(/^@?[a-z0-9_-]+(@[^\s]+)?$/i);

      if (couldBeUsername) {
        options.push({ key: 'go-to-account', label: <FormattedMessage id='search.quick_action.go_to_account' defaultMessage='Go to profile {x}' values={{ x: <mark>@{trimmedValue.replace(/^@/, '')}</mark> }} />, action: this.handleAccountClick });
      }

      const couldBeStatusSearch = searchEnabled;

      if (couldBeStatusSearch && signedIn) {
        options.push({ key: 'status-search', label: <FormattedMessage id='search.quick_action.status_search' defaultMessage='Posts matching {x}' values={{ x: <mark>{trimmedValue}</mark> }} />, action: this.handleStatusSearch });
      }

      const couldBeUserSearch = true;

      if (couldBeUserSearch) {
        options.push({ key: 'account-search', label: <FormattedMessage id='search.quick_action.account_search' defaultMessage='Profiles matching {x}' values={{ x: <mark>{trimmedValue}</mark> }} />, action: this.handleAccountSearch });
      }
    }

    this.setState({ options });
  }

  render () {
    const { intl, value, submitted, recent } = this.props;
    const { expanded, options, selectedOption } = this.state;
    const { signedIn } = this.context.identity;

    const hasValue = value.length > 0 || submitted;

    return (
      <div className={classNames('search', { active: expanded })}>
        <input
          ref={this.setRef}
          className='search__input'
          type='text'
          placeholder={intl.formatMessage(signedIn ? messages.placeholderSignedIn : messages.placeholder)}
          aria-label={intl.formatMessage(signedIn ? messages.placeholderSignedIn : messages.placeholder)}
          value={value || ''}
          onChange={this.handleChange}
          onKeyDown={this.handleKeyDown}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
        />

        <div role='button' tabIndex={0} className='search__icon' onClick={this.handleClear}>
          <Icon id='search' icon={SearchIcon}  className={hasValue ? '' : 'active'} />
          <Icon id='times-circle' icon={CancelIcon} className={hasValue ? 'active' : ''} />
        </div>

        <div className='search__popout'>
          {options.length === 0 && (
            <>
              <h4><FormattedMessage id='search_popout.recent' defaultMessage='Recent searches' /></h4>

              <div className='search__popout__menu'>
                {recent.size > 0 ? this._getOptions().map(({ label, key, action, forget }, i) => (
                  <button key={key} onMouseDown={action} className={classNames('search__popout__menu__item search__popout__menu__item--flex', { selected: selectedOption === i })}>
                    <span>{label}</span>
                    <button className='icon-button' onMouseDown={forget}><Icon id='times' icon={CloseIcon} /></button>
                  </button>
                )) : (
                  <div className='search__popout__menu__message'>
                    <FormattedMessage id='search.no_recent_searches' defaultMessage='No recent searches' />
                  </div>
                )}
              </div>
            </>
          )}

          {options.length > 0 && (
            <>
              <h4><FormattedMessage id='search_popout.quick_actions' defaultMessage='Quick actions' /></h4>

              <div className='search__popout__menu'>
                {options.map(({ key, label, action }, i) => (
                  <button key={key} onMouseDown={action} className={classNames('search__popout__menu__item', { selected: selectedOption === i })}>
                    {label}
                  </button>
                ))}
              </div>
            </>
          )}

          <h4><FormattedMessage id='search_popout.options' defaultMessage='Search options' /></h4>

          {searchEnabled && signedIn ? (
            <div className='search__popout__menu'>
              {this.defaultOptions.map(({ key, label, action }, i) => (
                <button key={key} onMouseDown={action} className={classNames('search__popout__menu__item', { selected: selectedOption === ((options.length || recent.size) + i) })}>
                  {label}
                </button>
              ))}
            </div>
          ) : (
            <div className='search__popout__menu__message'>
              {searchEnabled ? (
                <FormattedMessage id='search_popout.full_text_search_logged_out_message' defaultMessage='Only available when logged in.' />
              ) : (
                <FormattedMessage id='search_popout.full_text_search_disabled_message' defaultMessage='Not available on {domain}.' values={{ domain }} />
              )}
            </div>
          )}
        </div>
      </div>
    );
  }

}

export default withRouter(injectIntl(Search));
