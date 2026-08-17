import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { Details } from '@/mastodon/components/details';
import { CopyLinkField } from '@/mastodon/components/form_fields/copy_link_field';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

import type { DialogModalProps } from '../../ui/components/dialog_modal';
import { DialogModal } from '../../ui/components/dialog_modal';

import classes from './styles.module.scss';

const selectAccountUrl = createAppSelector(
  [(state) => state.meta.get('me') as string, (state) => state.accounts],
  (accountId, accounts) => {
    const account = accounts.get(accountId);
    return account?.get('url') ?? '';
  },
);

export const VerifiedModal: FC<DialogModalProps> = ({ onClose }) => {
  const accountUrl = useAppSelector(selectAccountUrl);

  return (
    <DialogModal
      onClose={onClose}
      title={
        <FormattedMessage
          id='account_edit.verified_modal.title'
          defaultMessage='How to add a verified link'
        />
      }
      noCancelButton
      wrapperClassName={classes.wrapper}
    >
      <FormattedMessage
        id='account_edit.verified_modal.details'
        defaultMessage='Add credibility to your Mastodon profile by verifying links to personal websites. Here’s how it works:'
        tagName='p'
      />

      <ol className={classes.verifiedSteps}>
        <li>
          <CopyLinkField
            label={
              <FormattedMessage
                id='account_edit.verified_modal.step1.header'
                defaultMessage='Copy the HTML code below and paste into the header of your website'
                tagName='h2'
              />
            }
            value={`<a rel="me" href="${accountUrl}">Mastodon</a>`}
          />
          <Details
            summary={
              <FormattedMessage
                id='account_edit.verified_modal.invisible_link.summary'
                defaultMessage='How do I make the link invisible?'
              />
            }
          >
            <FormattedMessage
              id='account_edit.verified_modal.invisible_link.details'
              defaultMessage='Add the link to your header. The important part is rel="me" which prevents impersonation on websites with user-generated content. You can even use a link tag in the header of the page instead of {tag}, but the HTML must be accessible without executing JavaScript.'
              values={{ tag: <code>&lt;a&gt;</code> }}
            />
          </Details>
        </li>
        <li>
          <FormattedMessage
            id='account_edit.verified_modal.step2.header'
            defaultMessage='Add your website as a custom field'
            tagName='h2'
          />
          <FormattedMessage
            id='account_edit.verified_modal.step2.details'
            defaultMessage='If you’ve already added your website as a custom field, you’ll need to delete and re-add it to trigger verification.'
            tagName='p'
          />
        </li>
      </ol>
    </DialogModal>
  );
};
