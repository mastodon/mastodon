import React from 'react';
import Column from 'mastodon/components/column';
import ColumnBackButton from 'mastodon/components/column_back_button';
import PropTypes from 'prop-types';
import { me, domain } from 'mastodon/initial_state';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import ArrowSmallRight from './components/arrow_small_right';
import { Link } from 'react-router-dom';

const messages = defineMessages({
  shareableMessage: { id: 'onboarding.share.message', defaultMessage: 'I\'m {username} on Mastodon! Come follow me at {url}' },
});

const mapStateToProps = state => ({
  account: state.getIn(['accounts', me]),
});

class CopyPasteText extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string,
  };

  state = {
    copied: false,
    focused: false,
  };

  setRef = c => {
    this.input = c;
  };

  handleInputClick = () => {
    this.setState({ copied: false });
    this.input.focus();
    this.input.select();
    this.input.setSelectionRange(0, this.props.value.length);
  };

  handleButtonClick = e => {
    e.stopPropagation();

    const { value } = this.props;
    navigator.clipboard.writeText(value);
    this.input.blur();
    this.setState({ copied: true });
    this.timeout = setTimeout(() => this.setState({ copied: false }), 700);
  };

  handleFocus = () => {
    this.setState({ focused: true });
  };

  handleBlur = () => {
    this.setState({ focused: false });
  };

  componentWillUnmount () {
    if (this.timeout) clearTimeout(this.timeout);
  }

  render () {
    const { value } = this.props;
    const { copied, focused } = this.state;

    return (
      <div className={classNames('copy-paste-text', { copied, focused })} tabIndex='0' role='button' onClick={this.handleInputClick}>
        <textarea readOnly value={value} ref={this.setRef} onClick={this.handleInputClick} onFocus={this.handleFocus} onBlur={this.handleBlur} />

        <button className='button' onClick={this.handleButtonClick}>
          <Icon id='copy' /> {copied ? <FormattedMessage id='copypaste.copied' defaultMessage='Copied' /> : <FormattedMessage id='copypaste.copy_to_clipboard' defaultMessage='Copy to clipboard' />}
        </button>
      </div>
    );
  }

}

class Share extends React.PureComponent {

  static propTypes = {
    onBack: PropTypes.func,
    account: ImmutablePropTypes.map,
    intl: PropTypes.object,
  };

  render () {
    const { onBack, account, intl } = this.props;

    const url = (new URL(`/@${account.get('username')}`, document.baseURI)).href;

    return (
      <Column>
        <ColumnBackButton onClick={onBack} />

        <div className='scrollable privacy-policy'>
          <div className='column-title'>
            <h3><FormattedMessage id='onboarding.share.title' defaultMessage='Share your profile' /></h3>
            <p><FormattedMessage id='onboarding.share.lead' defaultMessage='Let people know how they can find you on Mastodon!' /></p>
          </div>

          <CopyPasteText value={intl.formatMessage(messages.shareableMessage, { username: `@${account.get('username')}@${domain}`, url })} />

          <p className='onboarding__lead'><FormattedMessage id='onboarding.share.next_steps' defaultMessage='Possible next steps:' /></p>

          <div className='onboarding__links'>
            <Link to='/home' className='onboarding__link'>
              <ArrowSmallRight />
              <FormattedMessage id='onboarding.actions.go_to_home' defaultMessage='Go to your home feed' />
            </Link>

            <Link to='/explore' className='onboarding__link'>
              <ArrowSmallRight />
              <FormattedMessage id='onboarding.actions.go_to_explore' defaultMessage="See what's trending" />
            </Link>
          </div>

          <div className='onboarding__footer'>
            <button className='link-button' onClick={onBack}><FormattedMessage id='onboarding.action.back' defaultMessage='Take me back' /></button>
          </div>
        </div>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Share));