//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import { connect } from 'react-redux';
import {
  injectIntl,
  FormattedMessage,
  defineMessages,
} from 'react-intl';
import Overlay from 'react-overlays/Overlay';

//  Components.
import Icon from 'flavours/glitch/components/icon';

//  Utils.
import { focusRoot } from 'flavours/glitch/utils/dom_helpers';
import { searchEnabled } from 'flavours/glitch/initial_state';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' },
  placeholderSignedIn: { id: 'search.search_or_paste', defaultMessage: 'Search or paste URL' },
});

class SearchPopout extends React.PureComponent {

  render () {
    const extraInformation = searchEnabled ? <FormattedMessage id='search_popout.tips.full_text' defaultMessage='Simple text returns statuses you have written, favourited, boosted, or have been mentioned in, as well as matching usernames, display names, and hashtags.' /> : <FormattedMessage id='search_popout.tips.text' defaultMessage='Simple text returns matching display names, usernames and hashtags' />;
    return (
      <div className='search-popout'>
        <h4><FormattedMessage id='search_popout.search_format' defaultMessage='Advanced search format' /></h4>

        <ul>
          <li><em>#example</em> <FormattedMessage id='search_popout.tips.hashtag' defaultMessage='hashtag' /></li>
          <li><em>@username@domain</em> <FormattedMessage id='search_popout.tips.user' defaultMessage='user' /></li>
          <li><em>URL</em> <FormattedMessage id='search_popout.tips.user' defaultMessage='user' /></li>
          <li><em>URL</em> <FormattedMessage id='search_popout.tips.status' defaultMessage='status' /></li>
        </ul>

        {extraInformation}
      </div>
    );
  }

}

//  The component.
class Search extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
    identity: PropTypes.object.isRequired,
  };

  static propTypes = {
    value: PropTypes.string.isRequired,
    submitted: PropTypes.bool,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
    onShow: PropTypes.func.isRequired,
    openInRoute: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    singleColumn: PropTypes.bool,
  };

  state = {
    expanded: false,
  };

  setRef = c => {
    this.searchForm = c;
  };

  handleChange = (e) => {
    const { onChange } = this.props;
    if (onChange) {
      onChange(e.target.value);
    }
  };

  handleClear = (e) => {
    const {
      onClear,
      submitted,
      value,
    } = this.props;
    e.preventDefault();  //  Prevents focus change ??
    if (onClear && (submitted || value && value.length)) {
      onClear();
    }
  };

  handleBlur = () => {
    this.setState({ expanded: false });
  };

  handleFocus = () => {
    this.setState({ expanded: true });
    this.props.onShow();

    if (this.searchForm && !this.props.singleColumn) {
      const { left, right } = this.searchForm.getBoundingClientRect();
      if (left < 0 || right > (window.innerWidth || document.documentElement.clientWidth)) {
        this.searchForm.scrollIntoView();
      }
    }
  };

  handleKeyUp = (e) => {
    const { onSubmit } = this.props;
    switch (e.key) {
    case 'Enter':
      onSubmit();

      if (this.props.openInRoute) {
        this.context.router.history.push('/search');
      }
      break;
    case 'Escape':
      focusRoot();
    }
  };

  findTarget = () => {
    return this.searchForm;
  };

  render () {
    const { intl, value, submitted } = this.props;
    const { expanded } = this.state;
    const { signedIn } = this.context.identity;
    const hasValue = value.length > 0 || submitted;

    return (
      <div className='search'>
        <input
          ref={this.setRef}
          className='search__input'
          type='text'
          placeholder={intl.formatMessage(signedIn ? messages.placeholderSignedIn : messages.placeholder)}
          aria-label={intl.formatMessage(signedIn ? messages.placeholderSignedIn : messages.placeholder)}
          value={value || ''}
          onChange={this.handleChange}
          onKeyUp={this.handleKeyUp}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
        />

        <div role='button' tabIndex='0' className='search__icon' onClick={this.handleClear}>
          <Icon id='search' className={hasValue ? '' : 'active'} />
          <Icon id='times-circle' className={hasValue ? 'active' : ''} />
        </div>
        <Overlay show={expanded && !hasValue} placement='bottom' target={this.findTarget} popperConfig={{ strategy: 'fixed' }}>
          {({ props, placement }) => (
            <div {...props} style={{ ...props.style, width: 285, zIndex: 2 }}>
              <div className={`dropdown-animation ${placement}`}>
                <SearchPopout />
              </div>
            </div>
          )}
        </Overlay>
      </div>
    );
  }

}

export default injectIntl(Search);
