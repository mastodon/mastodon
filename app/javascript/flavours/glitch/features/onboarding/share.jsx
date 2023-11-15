import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';


import { ReactComponent as ArrowRightAltIcon } from '@material-symbols/svg-600/outlined/arrow_right_alt.svg';
import { ReactComponent as ContentCopyIcon } from '@material-symbols/svg-600/outlined/content_copy.svg';
import SwipeableViews from 'react-swipeable-views';

import { ColumnBackButton } from 'flavours/glitch/components/column_back_button';
import { Icon }  from 'flavours/glitch/components/icon';
import { me, domain } from 'flavours/glitch/initial_state';
import { useAppSelector } from 'flavours/glitch/store';

const messages = defineMessages({
  shareableMessage: { id: 'onboarding.share.message', defaultMessage: 'I\'m {username} on #Mastodon! Come follow me at {url}' },
});

class CopyPasteText extends PureComponent {

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
          <Icon id='copy' icon={ContentCopyIcon} /> {copied ? <FormattedMessage id='copypaste.copied' defaultMessage='Copied' /> : <FormattedMessage id='copypaste.copy_to_clipboard' defaultMessage='Copy to clipboard' />}
        </button>
      </div>
    );
  }

}

class TipCarousel extends PureComponent {

  static propTypes = {
    children: PropTypes.node,
  };

  state = {
    index: 0,
  };

  handleSwipe = index => {
    this.setState({ index });
  };

  handleChangeIndex = e => {
    this.setState({ index: Number(e.currentTarget.getAttribute('data-index')) });
  };

  handleKeyDown = e => {
    switch(e.key) {
    case 'ArrowLeft':
      e.preventDefault();
      this.setState(({ index }, { children }) => ({ index: Math.abs(index - 1) % children.length }));
      break;
    case 'ArrowRight':
      e.preventDefault();
      this.setState(({ index }, { children }) => ({ index: (index + 1) % children.length }));
      break;
    }
  };

  render () {
    const { children } = this.props;
    const { index } = this.state;

    return (
      <div className='tip-carousel' tabIndex='0' onKeyDown={this.handleKeyDown}>
        <SwipeableViews onChangeIndex={this.handleSwipe} index={index} enableMouseEvents tabIndex='-1'>
          {children}
        </SwipeableViews>

        <div className='media-modal__pagination'>
          {children.map((_, i) => (
            <button key={i} className={classNames('media-modal__page-dot', { active: i === index })} data-index={i} onClick={this.handleChangeIndex}>
              {i + 1}
            </button>
          ))}
        </div>
      </div>
    );
  }

}

export const Share = () => {
  const account = useAppSelector(state => state.getIn(['accounts', me]));
  const intl = useIntl();
  const url = (new URL(`/@${account.get('username')}`, document.baseURI)).href;

  return (
    <>
      <ColumnBackButton />

      <div className='scrollable privacy-policy'>
        <div className='column-title'>
          <h3><FormattedMessage id='onboarding.share.title' defaultMessage='Share your profile' /></h3>
          <p><FormattedMessage id='onboarding.share.lead' defaultMessage='Let people know how they can find you on Mastodon!' /></p>
        </div>

        <CopyPasteText value={intl.formatMessage(messages.shareableMessage, { username: `@${account.get('username')}@${domain}`, url })} />

        <TipCarousel>
          <div><p className='onboarding__lead'><FormattedMessage id='onboarding.tips.verification' defaultMessage='<strong>Did you know?</strong> You can verify your account by putting a link to your Mastodon profile on your own website and adding the website to your profile. No fees or documents necessary!'  values={{ strong: chunks => <strong>{chunks}</strong> }}  /></p></div>
          <div><p className='onboarding__lead'><FormattedMessage id='onboarding.tips.migration' defaultMessage='<strong>Did you know?</strong> If you feel like {domain} is not a great server choice for you in the future, you can move to another Mastodon server without losing your followers. You can even host your own server!' values={{ domain, strong: chunks => <strong>{chunks}</strong> }} /></p></div>
          <div><p className='onboarding__lead'><FormattedMessage id='onboarding.tips.2fa' defaultMessage='<strong>Did you know?</strong> You can secure your account by setting up two-factor authentication in your account settings. It works with any TOTP app of your choice, no phone number necessary!'  values={{ strong: chunks => <strong>{chunks}</strong> }}  /></p></div>
        </TipCarousel>

        <p className='onboarding__lead'><FormattedMessage id='onboarding.share.next_steps' defaultMessage='Possible next steps:' /></p>

        <div className='onboarding__links'>
          <Link to='/home' className='onboarding__link'>
            <FormattedMessage id='onboarding.actions.go_to_home' defaultMessage='Take me to my home feed' />
            <Icon icon={ArrowRightAltIcon} />
          </Link>

          <Link to='/explore' className='onboarding__link'>
            <FormattedMessage id='onboarding.actions.go_to_explore' defaultMessage='Take me to trending' />
            <Icon icon={ArrowRightAltIcon} />
          </Link>
        </div>

        <div className='onboarding__footer'>
          <Link className='link-button' to='/start'><FormattedMessage id='onboarding.action.back' defaultMessage='Take me back' /></Link>
        </div>
      </div>
    </>
  );
};
