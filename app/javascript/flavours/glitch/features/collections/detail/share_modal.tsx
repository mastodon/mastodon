import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { useLocation } from 'react-router';

import { me } from '@/flavours/glitch/initial_state';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { changeCompose, focusCompose } from 'flavours/glitch/actions/compose';
import type { ApiCollectionJSON } from 'flavours/glitch/api_types/collections';
import { AvatarById } from 'flavours/glitch/components/avatar';
import { AvatarGroup } from 'flavours/glitch/components/avatar_group';
import { Button } from 'flavours/glitch/components/button';
import { CopyLinkField } from 'flavours/glitch/components/form_fields';
import { IconButton } from 'flavours/glitch/components/icon_button';
import {
  ModalShell,
  ModalShellActions,
  ModalShellBody,
} from 'flavours/glitch/components/modal_shell';
import { useAppDispatch } from 'flavours/glitch/store';

import { AuthorNote } from '.';
import classes from './share_modal.module.scss';

const messages = defineMessages({
  shareTextOwn: {
    id: 'collection.share_template_own',
    defaultMessage: 'Check out my new collection: {link}',
  },
  shareTextOther: {
    id: 'collection.share_template_other',
    defaultMessage: 'Check out this cool collection: {link}',
  },
});

export const CollectionShareModal: React.FC<{
  collection: ApiCollectionJSON;
  onClose: () => void;
}> = ({ collection, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const location = useLocation<{ newCollection?: boolean }>();
  const isNew = !!location.state.newCollection;
  const isOwnCollection = collection.account_id === me;

  const collectionLink = `${window.location.origin}/collections/${collection.id}`;

  const handleShareOnDevice = useCallback(() => {
    void navigator.share({
      url: collectionLink,
    });
  }, [collectionLink]);

  const handleShareViaPost = useCallback(() => {
    const shareMessage = isOwnCollection
      ? intl.formatMessage(messages.shareTextOwn, {
          link: collectionLink,
        })
      : intl.formatMessage(messages.shareTextOther, {
          link: collectionLink,
        });

    onClose();
    dispatch(changeCompose(shareMessage));
    dispatch(focusCompose());
  }, [collectionLink, dispatch, intl, isOwnCollection, onClose]);

  return (
    <ModalShell>
      <ModalShellBody>
        <h1 className={classes.heading}>
          {isNew ? (
            <FormattedMessage
              id='collection.share_modal.title_new'
              defaultMessage='Share your new collection!'
            />
          ) : (
            <FormattedMessage
              id='collection.share_modal.title'
              defaultMessage='Share collection'
            />
          )}
        </h1>

        <IconButton
          title={intl.formatMessage({
            id: 'lightbox.close',
            defaultMessage: 'Close',
          })}
          iconComponent={CloseIcon}
          icon='close'
          className={classes.closeButtonDesktop}
          onClick={onClose}
        />

        <div className={classes.preview}>
          <div>
            <h2 className={classes.previewHeading}>{collection.name}</h2>
            <AuthorNote previewMode id={collection.account_id} />
          </div>
          <AvatarGroup>
            {collection.items.slice(0, 5).map(({ account_id }) => {
              if (!account_id) return;
              return (
                <AvatarById key={account_id} accountId={account_id} size={28} />
              );
            })}
          </AvatarGroup>
        </div>

        <CopyLinkField
          label={intl.formatMessage({
            id: 'collection.share_modal.share_link_label',
            defaultMessage: 'Invite share link',
          })}
          value={collectionLink}
        />
      </ModalShellBody>

      <ModalShellActions className={classes.actions}>
        <div className={classes.shareButtonWrapper}>
          <Button secondary onClick={handleShareViaPost}>
            <FormattedMessage
              id='collection.share_modal.share_via_post'
              defaultMessage='Post on Mastodon'
            />
          </Button>
          {'share' in navigator && (
            <Button secondary onClick={handleShareOnDevice}>
              <FormattedMessage
                id='collection.share_modal.share_via_system'
                defaultMessage='Share to…'
              />
            </Button>
          )}
        </div>

        <Button plain onClick={onClose} className={classes.closeButtonMobile}>
          <FormattedMessage id='lightbox.close' defaultMessage='Close' />
        </Button>
      </ModalShellActions>
    </ModalShell>
  );
};
