import { useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { DotsThreeIcon, PlusIcon, TrashIcon } from '@phosphor-icons/react';

import { IconButton } from '@/mastodon/components/button/redesign';
import { Icon } from '@/mastodon/components/icon';
import { Popover } from '@/mastodon/components/popover';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

import { selectComposeAttachments } from './selectors';
import classes from './styles.module.scss';

const selectAttachment = createAppSelector(
  [selectComposeAttachments, (_, id?: string) => id],
  (attachments, id) => {
    if (!id) {
      return null;
    }
    return attachments.find((attachment) => attachment.id === id) ?? null;
  },
);

export const ComposeUpload: React.FC<{ id?: string }> = ({ id }) => {
  const attachment = useAppSelector((state) => selectAttachment(state, id));
  const [open, { onToggle, onFalse }] = useToggle();
  const [target, setTarget] = useState<HTMLButtonElement | null>(null);

  if (!attachment) {
    return <div className={classes.mediaUpload} />;
  }

  return (
    <div
      className={classes.mediaUpload}
      style={{
        backgroundImage: attachment.preview_url
          ? `url(${attachment.preview_url})`
          : undefined,
      }}
      data-color-scheme='dark'
    >
      <IconButton
        icon={DotsThreeIcon}
        size='sm'
        color='neutral'
        className={classes.mediaMenuButton}
        onClick={onToggle}
        ref={setTarget}
      >
        <FormattedMessage
          id='compose.upload.menu'
          defaultMessage='Add alt text or remove the image'
        />
      </IconButton>

      <Popover
        isOpen={open}
        onClose={onFalse}
        reference={target}
        placement='bottom-end'
        offset={4}
      >
        {({ props }) => (
          <div
            {...props}
            className={classNames(classes.menu, classes.mediaMenu)}
          >
            <button type='button' className={classes.menuItemButton}>
              <Icon id='plus' icon={PlusIcon} />
              <FormattedMessage
                id='compose.upload.menu.add_alt'
                defaultMessage='Add alt text'
              />
            </button>

            <hr />

            <button
              type='button'
              className={classNames(
                classes.menuItemButton,
                classes.mediaMenuDelete,
              )}
            >
              <Icon id='trash' icon={TrashIcon} />
              <FormattedMessage
                id='compose.upload.menu.delete'
                defaultMessage='Remove image'
              />
            </button>
          </div>
        )}
      </Popover>

      {attachment.description && (
        <span className={classes.mediaAlt}>
          <FormattedMessage id='compose.upload.alt' defaultMessage='Alt' />
        </span>
      )}
    </div>
  );
};
