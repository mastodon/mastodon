import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import IconButton from '../../../components/icon_button';
import classNames from 'classnames';

import { mapValues } from 'lodash';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

const countryFlagsPaths = {
  en: '1f1ec-1f1e7',          // England
  ar: '1f1e6-1f1ea',          // United Arab Emirates
  // ast: '',                 // (Asturian language)
  bg: '1f1e7-1f1ec',          // Bulgaria
  // ca: '',                  // (Catalan language)
  // co: '',                  // (Corsican language)
  da: '1f1e9-1f1f0',          // Denmark
  de: '1f1e9-1f1ea',          // Germany
  el: '1f1ec-1f1f7',          // Greece
  // eo: '',                  // (Esperanto language)
  es: '1f1ea-1f1f8',          // Spain
  // eu: '',                  // (Basque language)
  // fa: '',                  // (Persian language)
  fi: '1f1eb-1f1ee',          // Finland
  fr: '1f1eb-1f1f7',          // France
  // gl: '',                  // (Galician language)
  he: '1f1ee-1f1f1',          // Israel
  hr: '1f1ed-1f1f7',          // Croatia
  hu: '1f1ed-1f1fa',          // Hungary
  hy: '1f1e6-1f1f2',          // Armenia
  id: '1f1ee-1f1e9',          // Indonesia
  // io: '',                  // (Ido language)
  it: '1f1ee-1f1f9',          // Italy
  ja: '1f1ef-1f1f5',          // Japan
  ka: '1f1ec-1f1ea',          // Georgia
  ko: '1f1f0-1f1f7',          // (Korean language)
  nl: '1f1f3-1f1f1',          // Netherlands
  no: '1f1f3-1f1f4',          // Norway
  // oc: '',                  // (Occitan language)
  pl: '1f1f5-1f1f1',          // Poland
  pt: '1f1f5-1f1f9',          // Portugal
  'pt-BR': '1f1e7-1f1f7',     // Brazil
  ru: '1f1f7-1f1fa',          // Russia
  sk: '1f1f8-1f1f0',          // Slovakia
  sl: '1f1f8-1f1ee',          // Slovenia
  sr: '1f1f7-1f1f8',          // Serbia
  // 'sr-Latn': '',           // Serbia (Serbian Latin)
  sv: '1f1f8-1f1ea',          // Sweden
  te: '1f1ee-1f1f3',          // India (Telugu language)
  th: '1f1f9-1f1ed',          // Thailand
  tr: '1f1f9-1f1f7',          // Turkey
  uk: '1f1fa-1f1e6',          // Ukraine
  zh: '1f1e8-1f1f3',          // China
  'zh-CN': '1f1e8-1f1f3',     // China
  'zh-HK': '1f1ed-1f1f0',     // Hong Kong
  'zh-TW': '1f1f9-1f1fc',     // Taiwan
};

const countryFlags = mapValues(countryFlagsPaths, code => {
  return require(`twemoji/2/svg/${code}.svg`);
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

  render () {
    const { locale, supportedLocales, intl, onClose } = this.props;

    const countryFlag = locale => {
      if (countryFlags[locale.code]) {
        const flag = countryFlags[locale.code];
        return (<img src={flag} className='flag-emoji' alt={locale.name} />);
      } else {
        return (<span className='flag-emoji' />);
      }
    };

    return (
      <div className='modal-root__modal language-select-modal'>
        <div className='language-select-modal__header'>
          <IconButton className='media-modal__close language-select-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={16} />
          <FormattedMessage id='language_select_modal.title' defaultMessage='Change language' />
        </div>

        <div className='language-select-modal__container'>
          {supportedLocales.map((option, index) => (
            <span key={index} className={classNames('language-select-modal__entry', { current: option.code === locale })} data-index={index} onClick={this.onLocaleChange} role='option' aria-selected={option.code === locale} tabIndex='0'>
              {countryFlag(option)} {option.name}
            </span>
          ))}
        </div>
      </div>
    );
  }

}
