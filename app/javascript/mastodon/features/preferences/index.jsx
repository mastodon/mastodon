import React from 'react';

import { injectIntl, FormattedMessage } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';

import Column from '../../components/column';
import ColumnBackButton from '../../components/column_back_button';
import LocalThemeSettings from '../local_themes';

class Preferences extends ImmutablePureComponent {
  render() {
    return (
      <Column>
        <ColumnBackButton />
        <div className='scrollable'>
          <div className='column-header'>
            <h1><FormattedMessage id='column.preferences' defaultMessage='Preferencias' /></h1>
          </div>

          <div className='column-section'>
            <h2>
              <FormattedMessage
                id='preferences.local_themes'
                defaultMessage='Temas Locales'
              />
            </h2>
            <LocalThemeSettings />
          </div>
        </div>
      </Column>
    );
  }
}

export default injectIntl(Preferences);