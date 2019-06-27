//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import { connect } from 'react-redux';
import spring from 'react-motion/lib/spring';
import {
  injectIntl,
  FormattedMessage,
  defineMessages,
} from 'react-intl';
import Overlay from 'react-overlays/lib/Overlay';

//  Components.
import Icon from 'flavours/glitch/components/icon';

//  Utils.
import { focusRoot } from 'flavours/glitch/util/dom_helpers';
import { searchEnabled } from 'flavours/glitch/util/initial_state';
import Motion from 'flavours/glitch/util/optional_motion';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' },
});

class SearchPopout extends React.PureComponent {

  static propTypes = {
    style: PropTypes.object,
  };

  render () {
    const { style } = this.props;
    const extraInformation = searchEnabled ? <FormattedMessage id='search_popout.tips.full_text' defaultMessage='Simple text returns statuses you have written, favourited, boosted, or have been mentioned in, as well as matching usernames, display names, and hashtags.' /> : <FormattedMessage id='search_popout.tips.text' defaultMessage='Simple text returns matching display names, usernames and hashtags' />;
    return (
      <div style={{ ...style, position: 'absolute', width: 285, zIndex: 2 }}>
        <Motion defaultStyle={{ opacity: 0, scaleX: 0.85, scaleY: 0.75 }} style={{ opacity: spring(1, { damping: 35, stiffness: 400 }), scaleX: spring(1, { damping: 35, stiffness: 400 }), scaleY: spring(1, { damping: 35, stiffness: 400 }) }}>
          {({ opacity, scaleX, scaleY }) => (
            <div className='search-popout' style={{ opacity: opacity, transform: `scale(${scaleX}, ${scaleY})` }}>
              <h4><FormattedMessage id='search_popout.search_format' defaultMessage='Advanced search format' /></h4>

              <ul>
                <li><em>#example</em> <FormattedMessage id='search_popout.tips.hashtag' defaultMessage='hashtag' /></li>
                <li><em>@username@domain</em> <FormattedMessage id='search_popout.tips.user' defaultMessage='user' /></li>
                <li><em>URL</em> <FormattedMessage id='search_popout.tips.user' defaultMessage='user' /></li>
                <li><em>URL</em> <FormattedMessage id='search_popout.tips.status' defaultMessage='status' /></li>
              </ul>

              {extraInformation}
            </div>
          )}
        </Motion>
      </div>
    );
  }

}

//  The component.
export default @injectIntl
class Search extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
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
  };

  state = {
    expanded: false,
  };

  handleChange = (e) => {
    const { onChange } = this.props;
    if (onChange) {
      onChange(e.target.value);
    }
  }

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
  }

  handleBlur = () => {
    this.setState({ expanded: false });
  }

  handleFocus = () => {
    const { onShow } = this.props;
    this.setState({ expanded: true });
    if (onShow) {
      onShow();
    }
  }

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
  }

  render () {
    const { intl, value, submitted } = this.props;
    const { expanded } = this.state;
    const hasValue = value.length > 0 || submitted;

    return (
      <div className='search'>
        <label>
          <span style={{ display: 'none' }}>{intl.formatMessage(messages.placeholder)}</span>
          <input
            className='search__input'
            type='text'
            placeholder={intl.formatMessage(messages.placeholder)}
            value={value || ''}
            onChange={this.handleChange}
            onKeyUp={this.handleKeyUp}
            onFocus={this.handleFocus}
            onBlur={this.handleBlur}
          />
        </label>

        <div
          aria-label={intl.formatMessage(messages.placeholder)}
          className='search__icon'
          onClick={this.handleClear}
          role='button'
          tabIndex='0'
        >
          <Icon icon='search' className={hasValue ? '' : 'active'} />
          <Icon icon='times-circle' className={hasValue ? 'active' : ''} />
        </div>

        <Overlay show={expanded && !hasValue} placement='bottom' target={this}>
          <SearchPopout />
        </Overlay>
      </div>
    );
  }

}
