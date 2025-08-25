import { forwardRef, useCallback, useId, useMemo, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import { isQuotePolicy } from '@/mastodon/api_types/quotes';
import { isStatusVisibility } from '@/mastodon/api_types/statuses';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { Button } from '@/mastodon/components/button';
import { Dropdown } from '@/mastodon/components/dropdown';
import type { SelectItem } from '@/mastodon/components/dropdown_selector';
import { IconButton } from '@/mastodon/components/icon_button';
import { messages as privacyMessages } from '@/mastodon/features/compose/components/privacy_dropdown';
import { createAppSelector, useAppSelector } from '@/mastodon/store';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';

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
    defaultMessage: 'No one',
  },
});

export type VisibilityModalCallback = (
  visibility: StatusVisibility,
  quotePolicy: ApiQuotePolicy,
) => void;

interface VisibilityModalProps extends BaseConfirmationModalProps {
  statusId?: string;
  onChange: VisibilityModalCallback;
}

const selectStatusPolicy = createAppSelector(
  [
    (state) => state.statuses,
    (_state, statusId?: string) => statusId,
    (state) => state.compose.get('quote_policy') as ApiQuotePolicy,
  ],
  (statuses, statusId, composeQuotePolicy) => {
    if (!statusId) {
      return composeQuotePolicy;
    }
    const status = statuses.get(statusId);
    if (!status) {
      return 'public';
    }
    const policy =
      (status.getIn(['quote_approval', 'automatic', 0]) as string) || 'nobody';
    const visibility = status.get('visibility') as StatusVisibility;

    // If the status is private or direct, it cannot be quoted by anyone.
    if (visibility === 'private' || visibility === 'direct') {
      return 'nobody';
    }

    // If the status has a specific quote policy, return it.
    if (isQuotePolicy(policy)) {
      return policy;
    }

    // Otherwise, return the default based on visibility.
    if (visibility === 'unlisted') {
      return 'followers';
    }
    return 'public';
  },
);

export const VisibilityModal: FC<VisibilityModalProps> = forwardRef(
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  ({ onClose, onChange, statusId }, _ref) => {
    const intl = useIntl();
    const currentVisibility = useAppSelector((state) =>
      statusId
        ? ((state.statuses.getIn([statusId, 'visibility'], 'public') as
            | StatusVisibility
            | undefined) ?? 'public')
        : (state.compose.get('privacy') as StatusVisibility),
    );
    const currentQuotePolicy = useAppSelector((state) =>
      selectStatusPolicy(state, statusId),
    );

    const [visibility, setVisibility] = useState(currentVisibility);
    const [quotePolicy, setQuotePolicy] = useState(currentQuotePolicy);

    const disableVisibility = !!statusId;
    const disableQuotePolicy =
      visibility === 'private' || visibility === 'direct';

    const visibilityItems = useMemo<SelectItem<StatusVisibility>[]>(
      () => [
        {
          value: 'public',
          text: intl.formatMessage(privacyMessages.public_short),
          meta: intl.formatMessage(privacyMessages.public_long),
          icon: 'globe',
          iconComponent: PublicIcon,
        },
        {
          value: 'unlisted',
          text: intl.formatMessage(privacyMessages.unlisted_short),
          meta: intl.formatMessage(privacyMessages.unlisted_long),
          extra: intl.formatMessage(privacyMessages.unlisted_extra),
          icon: 'unlock',
          iconComponent: QuietTimeIcon,
        },
        {
          value: 'private',
          text: intl.formatMessage(privacyMessages.private_short),
          meta: intl.formatMessage(privacyMessages.private_long),
          icon: 'lock',
          iconComponent: LockIcon,
        },
        {
          value: 'direct',
          text: intl.formatMessage(privacyMessages.direct_short),
          meta: intl.formatMessage(privacyMessages.direct_long),
          icon: 'at',
          iconComponent: AlternateEmailIcon,
        },
      ],
      [intl],
    );
    const quoteItems = useMemo<SelectItem<ApiQuotePolicy>[]>(
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

    const handleVisibilityChange = useCallback((value: string) => {
      if (isStatusVisibility(value)) {
        setVisibility(value);
      }
    }, []);
    const handleQuotePolicyChange = useCallback((value: string) => {
      if (isQuotePolicy(value)) {
        setQuotePolicy(value);
      }
    }, []);
    const handleSave = useCallback(() => {
      onChange(visibility, quotePolicy);
      onClose();
    }, [onChange, onClose, visibility, quotePolicy]);

    const privacyDropdownId = useId();
    const quoteDropdownId = useId();

    return (
      <div className='modal-root__modal dialog-modal visibility-modal'>
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
            defaultMessage='Visibility and interaction'
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
              defaultMessage='Control who can interact with this post. Global settings can be found under <link>Preferences > Other</link>.'
              values={{
                link: (chunks) => (
                  <a href='/settings/preferences/other'>{chunks}</a>
                ),
              }}
              tagName='p'
            />
          </div>
          <div className='dialog-modal__content__form'>
            <label
              htmlFor={privacyDropdownId}
              className={classNames('visibility-dropdown__label', {
                disabled: disableVisibility,
              })}
            >
              <FormattedMessage
                id='visibility_modal.privacy_label'
                defaultMessage='Privacy'
              />

              <Dropdown
                items={visibilityItems}
                classPrefix='visibility-dropdown'
                current={visibility}
                onChange={handleVisibilityChange}
                title={intl.formatMessage(privacyMessages.change_privacy)}
                disabled={disableVisibility}
                id={privacyDropdownId}
              />
              {!!statusId && (
                <p className='visibility-dropdown__helper'>
                  <FormattedMessage
                    id='visibility_modal.helper.privacy_editing'
                    defaultMessage="Visibility can't be changed after a post is published."
                  />
                </p>
              )}
            </label>

            <label
              htmlFor={quoteDropdownId}
              className={classNames('visibility-dropdown__label', {
                disabled: disableQuotePolicy,
              })}
            >
              <FormattedMessage
                id='visibility_modal.quote_label'
                defaultMessage='Change who can quote'
              />

              <Dropdown
                items={quoteItems}
                onChange={handleQuotePolicyChange}
                classPrefix='visibility-dropdown'
                current={quotePolicy}
                title={intl.formatMessage(messages.buttonTitle)}
                disabled={disableQuotePolicy}
                id={quoteDropdownId}
              />
              <QuotePolicyHelper policy={quotePolicy} visibility={visibility} />
            </label>
          </div>
          <div className='dialog-modal__content__actions'>
            <Button onClick={onClose} secondary>
              <FormattedMessage
                id='confirmation_modal.cancel'
                defaultMessage='Cancel'
              />
            </Button>
            <Button onClick={handleSave}>
              <FormattedMessage
                id='visibility_modal.save'
                defaultMessage='Save'
              />
            </Button>
          </div>
        </div>
      </div>
    );
  },
);
VisibilityModal.displayName = 'VisibilityModal';

const QuotePolicyHelper: FC<{
  policy: ApiQuotePolicy;
  visibility: StatusVisibility;
}> = ({ policy, visibility }) => {
  if (visibility === 'unlisted' && policy !== 'nobody') {
    return (
      <p className='visibility-dropdown__helper'>
        <FormattedMessage
          id='visibility_modal.helper.unlisted_quoting'
          defaultMessage='When people quote you, their post will also be hidden from trending timelines.'
        />
      </p>
    );
  }

  if (visibility === 'private') {
    return (
      <p className='visibility-dropdown__helper'>
        <FormattedMessage
          id='visibility_modal.helper.private_quoting'
          defaultMessage="Follower-only posts can't be quoted."
        />
      </p>
    );
  }

  if (visibility === 'direct') {
    return (
      <p className='visibility-dropdown__helper'>
        <FormattedMessage
          id='visibility_modal.helper.direct_quoting'
          defaultMessage="Private mentions can't be quoted."
        />
      </p>
    );
  }

  return null;
};
