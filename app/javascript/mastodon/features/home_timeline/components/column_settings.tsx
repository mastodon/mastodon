/* eslint-disable @typescript-eslint/no-unsafe-call,
                  @typescript-eslint/no-unsafe-return,
                  @typescript-eslint/no-unsafe-assignment,
                  @typescript-eslint/no-unsafe-member-access
                  -- the settings store is not yet typed */
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { changeSetting } from '../../../actions/settings';
import SettingToggle from '../../notifications/components/setting_toggle';

export const ColumnSettings: React.FC = () => {
  const settings = useAppSelector((state) => state.settings.get('home'));

  const dispatch = useAppDispatch();
  const onChange = useCallback(
    (key: string[], checked: boolean) => {
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
            settingPath={['shows', 'quote']}
            onChange={onChange}
            label={
              <FormattedMessage
                id='home.column_settings.show_quotes'
                defaultMessage='Show quotes'
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
        </div>
      </section>
    </div>
  );
};
