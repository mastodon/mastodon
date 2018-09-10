import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import IconButton from '../../../components/icon_button';
import classNames from 'classnames';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

@injectIntl
export default class LanguageSelectModal extends ImmutablePureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    supportedLocales: PropTypes.arrayOf(PropTypes.object).isRequired,
    onLocaleChange: PropTypes.func,
    intl: PropTypes.object.isRequired,
  };

  onLocaleChange = (e) => {
    const selectedLocale = this.props.supportedLocales[e.currentTarget.getAttribute('data-index')];
    e.preventDefault();

    this.props.onLocaleChange(selectedLocale.code);
  }

  renderItem = (option, index) => {
    const { locale } = this.props;
    const current = option.code === locale;
    const className = classNames('language-select-modal__entry', { current });

    return (
      <span key={index} className={className} data-index={index} onClick={this.onLocaleChange} role='option' aria-selected={current} tabIndex='0'>
        {option.name}
      </span>
    );
  }

  render () {
    const { supportedLocales, intl, onClose } = this.props;

    return (
      <div className='modal-root__modal language-select-modal'>
        <div className='language-select-modal__header'>
          <IconButton className='media-modal__close language-select-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={16} />
          <FormattedMessage id='language_select_modal.title' defaultMessage='Change language' />
        </div>

        <div className='language-select-modal__container'>
          {supportedLocales.map(this.renderItem)}
        </div>
      </div>
    );
  }

}
