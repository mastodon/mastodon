import { useCallback } from 'react';

import { useIntl, defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { changeComposeSensitivity } from 'flavours/glitch/actions/compose';
import { useAppSelector, useAppDispatch } from 'flavours/glitch/store';

const messages = defineMessages({
  marked: {
    id: 'compose_form.sensitive.marked',
    defaultMessage: '{count, plural, one {Media is marked as sensitive} other {Media is marked as sensitive}}',
  },
  unmarked: {
    id: 'compose_form.sensitive.unmarked',
    defaultMessage: '{count, plural, one {Media is not marked as sensitive} other {Media is not marked as sensitive}}',
  },
});

export const SensitiveButton = () => {
  const intl = useIntl();

  const spoilersAlwaysOn = useAppSelector((state) => state.getIn(['local_settings', 'always_show_spoilers_field']));
  const spoilerText = useAppSelector((state) => state.getIn(['compose', 'spoiler_text']));
  const sensitive = useAppSelector((state) => state.getIn(['compose', 'sensitive']));
  const spoiler = useAppSelector((state) => state.getIn(['compose', 'spoiler']));
  const mediaCount = useAppSelector((state) => state.getIn(['compose', 'media_attachments']).size);
  const disabled = spoilersAlwaysOn ? (spoilerText && spoilerText.length > 0) : spoiler;

  const active = sensitive || (spoilersAlwaysOn && spoilerText && spoilerText.length > 0);

  const dispatch = useAppDispatch();

  const handleClick = useCallback(() => {
    dispatch(changeComposeSensitivity());
  }, [dispatch]);

  return (
    <div className='compose-form__sensitive-button'>
      <label className={classNames('icon-button', { active })} title={intl.formatMessage(active ? messages.marked : messages.unmarked, { count: mediaCount })}>
        <input
          name='mark-sensitive'
          type='checkbox'
          checked={active}
          onChange={handleClick}
          disabled={disabled}
        />

        <FormattedMessage
          id='compose_form.sensitive.hide'
          defaultMessage='{count, plural, one {Mark media as sensitive} other {Mark media as sensitive}}'
          values={{ count: mediaCount }}
        />
      </label>
    </div>
  );
};
