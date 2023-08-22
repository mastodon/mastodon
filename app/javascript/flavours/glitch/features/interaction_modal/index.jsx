import PropTypes from 'prop-types';
import React from 'react';

import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';

import classNames from 'classnames';

import { connect } from 'react-redux';

import { throttle, escapeRegExp } from 'lodash';

import { openModal, closeModal } from 'flavours/glitch/actions/modal';
import api from 'flavours/glitch/api';
import Button from 'flavours/glitch/components/button';
import { Icon } from 'flavours/glitch/components/icon';
import { registrationsOpen, sso_redirect } from 'flavours/glitch/initial_state';

const messages = defineMessages({
  loginPrompt: { id: 'interaction_modal.login.prompt', defaultMessage: 'Domain of your home server, e.g. mastodon.social' },
});

const mapStateToProps = (state, { accountId }) => ({
  displayNameHtml: state.getIn(['accounts', accountId, 'display_name_html']),
  signupUrl: state.getIn(['server', 'server', 'registrations', 'url'], null) || '/auth/sign_up',
});

const mapDispatchToProps = (dispatch) => ({
  onSignupClick() {
    dispatch(closeModal({
        modalType: undefined,
        ignoreFocus: false,
      }));
    dispatch(openModal({ modalType: 'CLOSED_REGISTRATIONS' }));
  },
});

const PERSISTENCE_KEY = 'flavours/glitch_home';

const isValidDomain = value => {
  const url = new URL('https:///path');
  url.hostname = value;
  return url.hostname === value;
};

const valueToDomain = value => {
  // If the user starts typing an URL
  if (/^https?:\/\//.test(value)) {
    try {
      const url = new URL(value);

      // Consider that if there is a path, the URL is more meaningful than a bare domain
      if (url.pathname.length > 1) {
        return '';
      }

      return url.host;
    } catch {
      return undefined;
    }
  // If the user writes their full handle including username
  } else if (value.includes('@')) {
    if (value.replace(/^@/, '').split('@').length > 2) {
      return undefined;
    }
    return '';
  }

  return value;
};

const addInputToOptions = (value, options) => {
  value = value.trim();

  if (value.includes('.') && isValidDomain(value)) {
    return [value].concat(options.filter((x) => x !== value));
  }

  return options;
};

class LoginForm extends React.PureComponent {

  static propTypes = {
    resourceUrl: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  state = {
    value: localStorage ? (localStorage.getItem(PERSISTENCE_KEY) || '') : '',
    expanded: false,
    selectedOption: -1,
    isLoading: false,
    isSubmitting: false,
    error: false,
    options: [],
    networkOptions: [],
  };

  setRef = c => {
    this.input = c;
  };

  handleChange = ({ target }) => {
    this.setState(state => ({ value: target.value, isLoading: true, error: false, options: addInputToOptions(target.value, state.networkOptions) }), () => this._loadOptions());
  };

  handleMessage = (event) => {
    const { resourceUrl } = this.props;

    if (event.origin !== window.origin || event.source !== this.iframeRef.contentWindow) {
      return;
    }

    if (event.data?.type === 'fetchInteractionURL-failure') {
      this.setState({ isSubmitting: false, error: true });
    } else if (event.data?.type === 'fetchInteractionURL-success') {
      if (/^https?:\/\//.test(event.data.template)) {
        if (localStorage) {
          localStorage.setItem(PERSISTENCE_KEY, event.data.uri_or_domain);
        }

        window.location.href = event.data.template.replace('{uri}', encodeURIComponent(resourceUrl));
      } else {
        this.setState({ isSubmitting: false, error: true });
      }
    }
  };

  componentDidMount () {
    window.addEventListener('message', this.handleMessage);
  }

  componentWillUnmount () {
    window.removeEventListener('message', this.handleMessage);
  }

  handleSubmit = () => {
    const { value } = this.state;

    this.setState({ isSubmitting: true });

    this.iframeRef.contentWindow.postMessage({
      type: 'fetchInteractionURL',
      uri_or_domain: value.trim(),
    }, window.origin);
  };

  setIFrameRef = (iframe) => {
    this.iframeRef = iframe;
  }

  handleFocus = () => {
    this.setState({ expanded: true });
  };

  handleBlur = () => {
    this.setState({ expanded: false });
  };

  handleKeyDown = (e) => {
    const { options, selectedOption } = this.state;

    switch(e.key) {
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
        this.handleSubmit();
      } else if (options.length > 0) {
        this.setState({ value: options[selectedOption], error: false }, () => this.handleSubmit());
      }

      break;
    }
  };

  handleOptionClick = e => {
    const index  = Number(e.currentTarget.getAttribute('data-index'));
    const option = this.state.options[index];

    e.preventDefault();
    this.setState({ selectedOption: index, value: option, error: false }, () => this.handleSubmit());
  };

  _loadOptions = throttle(() => {
    const { value } = this.state;

    const domain = valueToDomain(value.trim());

    if (typeof domain === 'undefined') {
      this.setState({ options: [], networkOptions: [], isLoading: false, error: true });
      return;
    }

    if (domain.length === 0) {
      this.setState({ options: [], networkOptions: [], isLoading: false });
      return;
    }

    api().get('/api/v1/peers/search', { params: { q: domain } }).then(({ data }) => {
      if (!data) {
        data = [];
      }

      this.setState((state) => ({ networkOptions: data, options: addInputToOptions(state.value, data), isLoading: false }));
    }).catch(() => {
      this.setState({ isLoading: false });
    });
  }, 200, { leading: true, trailing: true });

  render () {
    const { intl } = this.props;
    const { value, expanded, options, selectedOption, error, isSubmitting } = this.state;
    const domain = (valueToDomain(value) || '').trim();
    const domainRegExp = new RegExp(`(${escapeRegExp(domain)})`, 'gi');
    const hasPopOut = domain.length > 0 && options.length > 0;

    return (
      <div className={classNames('interaction-modal__login', { focused: expanded, expanded: hasPopOut, invalid: error })}>

        <iframe
          ref={this.setIFrameRef}
          style={{display: 'none'}}
          src='/remote_interaction_helper'
          sandbox='allow-scripts allow-same-origin'
          title='remote interaction helper'
        />

        <div className='interaction-modal__login__input'>
          <input
            ref={this.setRef}
            type='text'
            value={value}
            placeholder={intl.formatMessage(messages.loginPrompt)}
            aria-label={intl.formatMessage(messages.loginPrompt)}
            autoFocus
            onChange={this.handleChange}
            onFocus={this.handleFocus}
            onBlur={this.handleBlur}
            onKeyDown={this.handleKeyDown}
            autocomplete='off'
            autocapitalize='off'
            spellcheck='false'
          />

          <Button onClick={this.handleSubmit} disabled={isSubmitting}><FormattedMessage id='interaction_modal.login.action' defaultMessage='Take me home' /></Button>
        </div>

        {hasPopOut && (
          <div className='search__popout'>
            <div className='search__popout__menu'>
              {options.map((option, i) => (
                <button key={option} onMouseDown={this.handleOptionClick} data-index={i} className={classNames('search__popout__menu__item', { selected: selectedOption === i })}>
                  {option.split(domainRegExp).map((part, i) => (
                    part.toLowerCase() === domain.toLowerCase() ? (
                      <mark key={i}>
                        {part}
                      </mark>
                    ) : (
                      <span key={i}>
                        {part}
                      </span>
                    )
                  ))}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    );
  }

}

const IntlLoginForm = injectIntl(LoginForm);

class InteractionModal extends React.PureComponent {

  static propTypes = {
    displayNameHtml: PropTypes.string,
    url: PropTypes.string,
    type: PropTypes.oneOf(['reply', 'reblog', 'favourite', 'follow']),
    onSignupClick: PropTypes.func.isRequired,
    signupUrl: PropTypes.string.isRequired,
  };

  handleSignupClick = () => {
    this.props.onSignupClick();
  };

  render () {
    const { url, type, displayNameHtml, signupUrl } = this.props;

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
      title = <FormattedMessage id='interaction_modal.title.favourite' defaultMessage="Favorite {name}'s post" values={{ name }} />;
      actionDescription = <FormattedMessage id='interaction_modal.description.favourite' defaultMessage='With an account on Mastodon, you can favorite this post to let the author know you appreciate it and save it for later.' />;
      break;
    case 'follow':
      icon = <Icon id='user-plus' />;
      title = <FormattedMessage id='interaction_modal.title.follow' defaultMessage='Follow {name}' values={{ name }} />;
      actionDescription = <FormattedMessage id='interaction_modal.description.follow' defaultMessage='With an account on Mastodon, you can follow {name} to receive their posts in your home feed.' values={{ name }} />;
      break;
    }

    let signupButton;

    if (sso_redirect) {
      signupButton = (
        <a href={sso_redirect} data-method='post' className='link-button'>
          <FormattedMessage id='sign_in_banner.create_account' defaultMessage='Create account' />
        </a>
      );
    } else if (registrationsOpen) {
      signupButton = (
        <a href={signupUrl} className='link-button'>
          <FormattedMessage id='sign_in_banner.create_account' defaultMessage='Create account' />
        </a>
      );
    } else {
      signupButton = (
        <button className='link-button' onClick={this.handleSignupClick}>
          <FormattedMessage id='sign_in_banner.create_account' defaultMessage='Create account' />
        </button>
      );
    }

    return (
      <div className='modal-root__modal interaction-modal'>
        <div className='interaction-modal__lead'>
          <h3><span className='interaction-modal__icon'>{icon}</span> {title}</h3>
          <p>{actionDescription} <strong><FormattedMessage id='interaction_modal.sign_in' defaultMessage='You are not logged in to this server. Where is your account hosted?' /></strong></p>
        </div>

        <IntlLoginForm resourceUrl={url} />

        <p className='hint'><FormattedMessage id='interaction_modal.sign_in_hint' defaultMessage="Tip: That's the website where you signed up. If you don't remember, look for the welcome e-mail in your inbox. You can also enter your full username! (e.g. @Mastodon@mastodon.social)" /></p>
        <p><FormattedMessage id='interaction_modal.no_account_yet' defaultMessage='Not on Mastodon?' /> {signupButton}</p>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(InteractionModal);
