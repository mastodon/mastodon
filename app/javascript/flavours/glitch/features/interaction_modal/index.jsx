import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { registrationsOpen } from 'flavours/glitch/initial_state';
import { connect } from 'react-redux';
import Icon from 'flavours/glitch/components/icon';
import classNames from 'classnames';
import { openModal, closeModal } from 'flavours/glitch/actions/modal';

const mapStateToProps = (state, { accountId }) => ({
  displayNameHtml: state.getIn(['accounts', accountId, 'display_name_html']),
});

const mapDispatchToProps = (dispatch) => ({
  onSignupClick() {
    dispatch(closeModal());
    dispatch(openModal('CLOSED_REGISTRATIONS'));
  },
});

class Copypaste extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string,
  };

  state = {
    copied: false,
  };

  setRef = c => {
    this.input = c;
  };

  handleInputClick = () => {
    this.setState({ copied: false });
    this.input.focus();
    this.input.select();
    this.input.setSelectionRange(0, this.input.value.length);
  };

  handleButtonClick = () => {
    const { value } = this.props;
    navigator.clipboard.writeText(value);
    this.input.blur();
    this.setState({ copied: true });
    this.timeout = setTimeout(() => this.setState({ copied: false }), 700);
  };

  componentWillUnmount () {
    if (this.timeout) clearTimeout(this.timeout);
  }

  render () {
    const { value } = this.props;
    const { copied } = this.state;

    return (
      <div className={classNames('copypaste', { copied })}>
        <input
          type='text'
          ref={this.setRef}
          value={value}
          readOnly
          onClick={this.handleInputClick}
        />

        <button className='button' onClick={this.handleButtonClick}>
          {copied ? <FormattedMessage id='copypaste.copied' defaultMessage='Copied' /> : <FormattedMessage id='copypaste.copy' defaultMessage='Copy' />}
        </button>
      </div>
    );
  }

}

class InteractionModal extends React.PureComponent {

  static propTypes = {
    displayNameHtml: PropTypes.string,
    url: PropTypes.string,
    type: PropTypes.oneOf(['reply', 'reblog', 'favourite', 'follow']),
    onSignupClick: PropTypes.func.isRequired,
  };

  handleSignupClick = () => {
    this.props.onSignupClick();
  };

  render () {
    const { url, type, displayNameHtml } = this.props;

    const name = <bdi dangerouslySetInnerHTML={{ __html: displayNameHtml }} />;

    let title, actionDescription, icon;

    switch(type) {
    case 'reply':
      icon = <Icon id='reply' />;
      title = <FormattedMessage id='interaction_modal.title.reply' defaultMessage="Reply to {name}'s post" values={{ name }} />;
      actionDescription = <FormattedMessage id='interaction_modal.description.reply' defaultMessage='With an account on Mastodon, you can respond to this post.' />;
      break;
    case 'reblog':
      icon = <Icon id='retweet' />;
      title = <FormattedMessage id='interaction_modal.title.reblog' defaultMessage="Boost {name}'s post" values={{ name }} />;
      actionDescription = <FormattedMessage id='interaction_modal.description.reblog' defaultMessage='With an account on Mastodon, you can boost this post to share it with your own followers.' />;
      break;
    case 'favourite':
      icon = <Icon id='star' />;
      title = <FormattedMessage id='interaction_modal.title.favourite' defaultMessage="Favourite {name}'s post" values={{ name }} />;
      actionDescription = <FormattedMessage id='interaction_modal.description.favourite' defaultMessage='With an account on Mastodon, you can favourite this post to let the author know you appreciate it and save it for later.' />;
      break;
    case 'follow':
      icon = <Icon id='user-plus' />;
      title = <FormattedMessage id='interaction_modal.title.follow' defaultMessage='Follow {name}' values={{ name }} />;
      actionDescription = <FormattedMessage id='interaction_modal.description.follow' defaultMessage='With an account on Mastodon, you can follow {name} to receive their posts in your home feed.' values={{ name }} />;
      break;
    }

    let signupButton;

    if (registrationsOpen) {
      signupButton = (
        <a href='/auth/sign_up' className='button button--block button-tertiary'>
          <FormattedMessage id='sign_in_banner.create_account' defaultMessage='Create account' />
        </a>
      );
    } else {
      signupButton = (
        <button className='button button--block button-tertiary' onClick={this.handleSignupClick}>
          <FormattedMessage id='sign_in_banner.create_account' defaultMessage='Create account' />
        </button>
      );
    }

    return (
      <div className='modal-root__modal interaction-modal'>
        <div className='interaction-modal__lead'>
          <h3><span className='interaction-modal__icon'>{icon}</span> {title}</h3>
          <p>{actionDescription} <FormattedMessage id='interaction_modal.preamble' defaultMessage="Since Mastodon is decentralized, you can use your existing account hosted by another Mastodon server or compatible platform if you don't have an account on this one." /></p>
        </div>

        <div className='interaction-modal__choices'>
          <div className='interaction-modal__choices__choice'>
            <h3><FormattedMessage id='interaction_modal.on_this_server' defaultMessage='On this server' /></h3>
            <a href='/auth/sign_in' className='button button--block'><FormattedMessage id='sign_in_banner.sign_in' defaultMessage='Sign in' /></a>
            {signupButton}
          </div>

          <div className='interaction-modal__choices__choice'>
            <h3><FormattedMessage id='interaction_modal.on_another_server' defaultMessage='On a different server' /></h3>
            <p><FormattedMessage id='interaction_modal.other_server_instructions' defaultMessage='Copy and paste this URL into the search field of your favourite Mastodon app or the web interface of your Mastodon server.' /></p>
            <Copypaste value={url} />
          </div>
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(InteractionModal);
