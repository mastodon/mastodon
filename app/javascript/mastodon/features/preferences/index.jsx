import React from 'react';

import { FormattedMessage } from 'react-intl';

import LocalThemeSettings from '../local_themes';
import Column from '../ui/components/column.jsx';
import ColumnBackButton from '../../components/column_back_button.jsx'; // Importación corregida

const Preferences = () => {
  return (
    <Column>
      <ColumnBackButton />
      <div className='scrollable'>
        <div className='column-header'>
          <h1>
            <FormattedMessage
              id='column.preferences'
              defaultMessage='Preferencias'
            />
          </h1>
        </div>

        {/* Otras secciones de preferencias */}

        <div className='column-section'>
          <h2>
            <FormattedMessage
              id='preferences.local_themes'
              defaultMessage='Temas Locales'
            />
          </h2>
          <p className='column-section__description'>
            <FormattedMessage
              id='preferences.local_themes_description'
              defaultMessage='Personaliza la apariencia de Mastodon con tus propios estilos CSS'
            />
          </p>

          <LocalThemeSettings />
        </div>
      </div>
    </Column>
  );
};

export default Preferences;