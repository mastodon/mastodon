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
    defaultMessage: 'Just me',
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

const selectDisablePublicVisibilities = createAppSelector(
  [
    (state) => state.statuses,
    (_state, statusId?: string) => !!statusId,
    (state) => state.compose.get('quoted_status_id') as string | null,
  ],
  (statuses, isEditing, statusId) => {
    if (isEditing || !statusId) return false;

    const status = statuses.get(statusId);
    if (!status) {
      return false;
    }

    return status.get('visibility') === 'private';
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
    const disablePublicVisibilities = useAppSelector(
      selectDisablePublicVisibilities,
    );
    const isQuotePost = useAppSelector(
      (state) => state.compose.get('quoted_status_id') !== null,
    );

    const visibilityItems = useMemo<SelectItem<StatusVisibility>[]>(() => {
      const items: SelectItem<StatusVisibility>[] = [
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
      ];

      if (!disablePublicVisibilities) {
        items.unshift(
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
            icon: 'unlock',
            iconComponent: QuietTimeIcon,
          },
        );
      }

      return items;
    }, [intl, disablePublicVisibilities]);
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

    const uniqueId = useId();
    const visibilityLabelId = `${uniqueId}-visibility-label`;
    const visibilityDescriptionId = `${uniqueId}-visibility-desc`;
    const quoteLabelId = `${uniqueId}-quote-label`;
    const quoteDescriptionId = `${uniqueId}-quote-desc`;

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
              defaultMessage='Control who can interact with this post. You can also apply settings to all future posts by navigating to <link>Preferences > Posting defaults</link>.'
              values={{
                link: (chunks) => (
                  <a href='/settings/preferences/posting_defaults'>{chunks}</a>
                ),
              }}
              tagName='p'
            />
          </div>
          <div className='dialog-modal__content__form'>
            <div
              className={classNames('visibility-dropdown', {
                disabled: disableVisibility,
              })}
            >
              {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
              <label
                className='visibility-dropdown__label'
                id={visibilityLabelId}
              >
                <FormattedMessage
                  id='visibility_modal.privacy_label'
                  defaultMessage='Visibility'
                />
              </label>

              <Dropdown
                items={visibilityItems}
                current={visibility}
                onChange={handleVisibilityChange}
                labelId={visibilityLabelId}
                descriptionId={visibilityDescriptionId}
                classPrefix='visibility-dropdown'
                disabled={disableVisibility}
              />
              {!!statusId && (
                <p
                  className='visibility-dropdown__helper'
                  id='visibilityDescriptionId'
                >
                  <FormattedMessage
                    id='visibility_modal.helper.privacy_editing'
                    defaultMessage="Visibility can't be changed after a post is published."
                  />
                </p>
              )}
              {!statusId && disablePublicVisibilities && (
                <p
                  className='visibility-dropdown__helper'
                  id='visibilityDescriptionId'
                >
                  <FormattedMessage
                    id='visibility_modal.helper.privacy_private_self_quote'
                    defaultMessage='Self-quotes of private posts cannot be made public.'
                  />
                </p>
              )}
            </div>

            <div
              className={classNames('visibility-dropdown', {
                disabled: disableQuotePolicy,
              })}
            >
              {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
              <label className='visibility-dropdown__label' id={quoteLabelId}>
                <FormattedMessage
                  id='visibility_modal.quote_label'
                  defaultMessage='Who can quote'
                />
              </label>

              <Dropdown
                items={quoteItems}
                current={disableQuotePolicy ? 'nobody' : quotePolicy}
                onChange={handleQuotePolicyChange}
                labelId={quoteLabelId}
                descriptionId={quoteDescriptionId}
                classPrefix='visibility-dropdown'
                disabled={disableQuotePolicy}
              />
              <QuotePolicyHelper
                policy={quotePolicy}
                visibility={visibility}
                className='visibility-dropdown__helper'
                id={quoteDescriptionId}
              />
            </div>

            {isQuotePost && visibility === 'direct' && (
              <div className='visibility-modal__quote-warning'>
                <FormattedMessage
                  id='visibility_modal.direct_quote_warning.title'
                  defaultMessage="Quotes can't be embedded in private mentions"
                  tagName='h3'
                />
                <FormattedMessage
                  id='visibility_modal.direct_quote_warning.text'
                  defaultMessage='If you save the current settings, the embedded quote will be converted to a link.'
                  tagName='p'
                />
              </div>
            )}
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

const QuotePolicyHelper: FC<
  {
    policy: ApiQuotePolicy;
    visibility: StatusVisibility;
  } & React.ComponentPropsWithoutRef<'p'>
> = ({ policy, visibility, ...otherProps }) => {
  let hintText: React.ReactElement | undefined;

  if (visibility === 'unlisted' && policy !== 'nobody') {
    hintText = (
      <FormattedMessage
        id='visibility_modal.helper.unlisted_quoting'
        defaultMessage='When people quote you, their post will also be hidden from trending timelines.'
      />
    );
  }

  if (visibility === 'private') {
    hintText = (
      <FormattedMessage
        id='visibility_modal.helper.private_quoting'
        defaultMessage="Follower-only posts authored on Mastodon can't be quoted by others."
      />
    );
  }

  if (visibility === 'direct') {
    hintText = (
      <FormattedMessage
        id='visibility_modal.helper.direct_quoting'
        defaultMessage="Private mentions authored on Mastodon can't be quoted by others."
      />
    );
  }

  if (!hintText) {
    return null;
  }

  return <p {...otherProps}>{hintText}</p>;
};
