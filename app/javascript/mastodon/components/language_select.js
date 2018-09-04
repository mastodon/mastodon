import React from 'react';
import { ImmutablePureComponent } from 'react-immutable-pure-component';
import PropTypes from 'prop-types';

import IconButton from './icon_button';

export default class LanguageSelect extends ImmutablePureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    supportedLocales: PropTypes.arrayOf(PropTypes.object).isRequired,
    onLocaleChange: PropTypes.func.isRequired,
  };

  handleClick = () => {
    const { onLocaleChange } = this.props;
    onLocaleChange();
  }

  render () {
    return (
      <IconButton
        icon='language'
        size={24}
        title='Language'
        onClick={this.handleClick}
      />
    );
  }

}