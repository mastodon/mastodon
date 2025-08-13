import { forwardRef, useCallback, useMemo } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { setStatusQuotePolicy } from '@/mastodon/actions/statuses_typed';
import { isQuotePolicy } from '@/mastodon/api_types/quotes';
import { Dropdown } from '@/mastodon/components/dropdown';
import type { SelectItem } from '@/mastodon/components/dropdown_selector';
import { IconButton } from '@/mastodon/components/icon_button';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import type { BaseConfirmationModalProps } from './confirmation_modals/confirmation_modal';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  buttonTitle: {
    id: 'visibility_modal.button_title',
    defaultMessage: 'Set visibility',
  },
  quotePublic: {
    id: 'visibility_modal.quote_public',
    defaultMessage: 'Anyone',
  },
  quoteFollowers: {
    id: 'visibility_modal.quote_followers',
    defaultMessage: 'Followers only',
  },
  quoteNobody: {
    id: 'visibility_modal.quote_nobody',
    defaultMessage: 'Nobody',
  },
});

interface VisibilityModalProps extends BaseConfirmationModalProps {
  statusId: string;
}

const selectStatusPolicy = createAppSelector(
  [(state) => state.statuses, (_state, statusId: string) => statusId],
  (statuses, statusId) => {
    const status = statuses.get(statusId);
    if (!status) {
      return null;
    }
    const policy = status.getIn(['quote_approval', 'automatic', 0]) as string;
    if (isQuotePolicy(policy)) {
      return policy;
    }
    return 'nobody'; // Automatic is empty when nobody is allowed.
  },
);

export const VisibilityModal: FC<VisibilityModalProps> = forwardRef(
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  ({ onClose, statusId }, ref) => {
    const intl = useIntl();
    const currentPolicy = useAppSelector((state) =>
      selectStatusPolicy(state, statusId),
    );
    const isSaving = useAppSelector(
      (state) =>
        state.statuses.getIn([statusId, 'isSavingQuotePolicy']) === true,
    );

    const quoteItems = useMemo<SelectItem[]>(
      () => [
        { value: 'public', text: intl.formatMessage(messages.quotePublic) },
        {
          value: 'followers',
          text: intl.formatMessage(messages.quoteFollowers),
        },
        { value: 'nobody', text: intl.formatMessage(messages.quoteNobody) },
      ],
      [intl],
    );

    const dispatch = useAppDispatch();
    const handleChange = useCallback(
      (value: string) => {
        if (isQuotePolicy(value)) {
          void dispatch(setStatusQuotePolicy({ policy: value, statusId }));
        }
      },
      [dispatch, statusId],
    );

    return (
      <div className='modal-root__modal dialog-modal'>
        <div className='dialog-modal__header'>
          <IconButton
            className='dialog-modal__header__close'
            title={intl.formatMessage(messages.close)}
            icon='times'
            iconComponent={CloseIcon}
            onClick={onClose}
          />
          <FormattedMessage
            id='visibility_modal.header'
            defaultMessage='Visibility and Interaction'
          >
            {(chunks) => (
              <span className='dialog-modal__header__title'>{chunks}</span>
            )}
          </FormattedMessage>
        </div>
        <div className='dialog-modal__content'>
          <div className='dialog-modal__content__description'>
            <FormattedMessage
              id='visibility_modal.instructions'
              defaultMessage='Control who can interact with this post. Global settings can be found under <link>Preferences > Other.</link>'
              values={{
                link: (chunks) => (
                  <a href='/settings/preferences/other'>{chunks}</a>
                ),
              }}
              tagName='p'
            />
          </div>
          <div className='dialog-modal__content__form'>
            <Dropdown
              items={quoteItems}
              onChange={handleChange}
              classPrefix='visibility-dropdown'
              current={currentPolicy ?? 'public'}
              title={intl.formatMessage(messages.buttonTitle)}
              disabled={isSaving}
            />
          </div>
        </div>
      </div>
    );
  },
);
VisibilityModal.displayName = 'VisibilityModal';
