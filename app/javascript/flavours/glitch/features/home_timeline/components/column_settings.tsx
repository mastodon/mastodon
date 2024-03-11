/* eslint-disable @typescript-eslint/no-unsafe-call,
                  @typescript-eslint/no-unsafe-return,
                  @typescript-eslint/no-unsafe-assignment,
                  @typescript-eslint/no-unsafe-member-access
                  -- the settings store is not yet typed */
import { useCallback } from 'react';

import { FormattedMessage, defineMessages, useIntl } from 'react-intl';

import SettingText from 'flavours/glitch/components/setting_text';
import { useAppSelector, useAppDispatch } from 'flavours/glitch/store';

import { changeSetting } from '../../../actions/settings';
import SettingToggle from '../../notifications/components/setting_toggle';

const messages = defineMessages({
  filter_regex: {
    id: 'home.column_settings.filter_regex',
    defaultMessage: 'Filter out by regular expressions',
  },
  settings: { id: 'home.settings', defaultMessage: 'Column settings' },
});

export const ColumnSettings: React.FC = () => {
  const settings = useAppSelector((state) => state.settings.get('home'));

  const intl = useIntl();

  const dispatch = useAppDispatch();
  const onChange = useCallback(
    (key: string, checked: boolean) => {
      dispatch(changeSetting(['home', ...key], checked));
    },
    [dispatch],
  );

  return (
    <div className='column-settings'>
      <section>
        <div className='column-settings__row'>
          <SettingToggle
            prefix='home_timeline'
            settings={settings}
            settingPath={['shows', 'reblog']}
            onChange={onChange}
            label={
              <FormattedMessage
                id='home.column_settings.show_reblogs'
                defaultMessage='Show boosts'
              />
            }
          />

          <SettingToggle
            prefix='home_timeline'
            settings={settings}
            settingPath={['shows', 'reply']}
            onChange={onChange}
            label={
              <FormattedMessage
                id='home.column_settings.show_replies'
                defaultMessage='Show replies'
              />
            }
          />

          <SettingToggle
            prefix='home_timeline'
            settings={settings}
            settingPath={['shows', 'direct']}
            onChange={onChange}
            label={
              <FormattedMessage
                id='home.column_settings.show_direct'
                defaultMessage='Show private mentions'
              />
            }
          />
        </div>
      </section>

      <section aria-labelledby='home-column-advanced'>
        <h3 id='home-column-advanced'>
          <FormattedMessage
            id='home.column_settings.advanced'
            defaultMessage='Advanced'
          />
        </h3>

        <div className='column-settings__row'>
          <SettingText
            prefix='home_timeline'
            settings={settings}
            settingPath={['regex', 'body']}
            onChange={onChange}
            label={intl.formatMessage(messages.filter_regex)}
          />
        </div>
      </section>
    </div>
  );
};
