import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  Button,
  CaretIcon,
} from '@/flavours/glitch/components/button/redesign';
import { Icon } from '@/flavours/glitch/components/icon';
import {
  Menu,
  MenuItemCheckbox,
  MenuItemDivider,
  MenuItemRadio,
  MenuList,
  MenuTrigger,
} from '@/flavours/glitch/components/menu';
import {
  ModalActions,
  ModalShell,
  ModalTitle,
} from '@/flavours/glitch/components/modal_shell/redesign';
import { StatusBoostIcon } from '@/flavours/glitch/components/status/icons';
import { QuotedStatus } from '@/flavours/glitch/components/status/quote';
import { ComposeVisibilityButtonText } from '@/flavours/glitch/features/compose/redesign/visibility';
import { useStatus } from '@/flavours/glitch/hooks/useStatus';
import type { StatusVisibility } from '@/flavours/glitch/models/status';
import { useAppSelector } from '@/flavours/glitch/store';

import classes from './boost_modal.module.scss';

export const BoostModal: React.FC<{
  statusId: string;
  onClose: () => void;
  onReblog: (privacy: StatusVisibility) => void;
  missingMediaDescription?: boolean;
}> = ({ statusId, onReblog, onClose, missingMediaDescription }) => {
  const defaultPrivacy = useAppSelector(
    (state) => state.compose.get('default_privacy') as StatusVisibility,
  );

  const status = useStatus(statusId);
  const statusVisibility = status?.visibility;

  const [privacy, setPrivacy] = useState<StatusVisibility>(
    statusVisibility === 'private' ? 'private' : defaultPrivacy,
  );

  const handlePrivacyChange = useCallback(
    ({ value }: { value: string }) => {
      if (value === 'private' && privacy !== 'private') {
        setPrivacy(value);
      } else if (value === 'public' && privacy === 'private') {
        setPrivacy(defaultPrivacy === 'unlisted' ? 'unlisted' : 'public');
      } else if (value === 'unlisted' && privacy !== 'private') {
        setPrivacy(privacy === 'public' ? 'unlisted' : 'public');
      }
    },
    [defaultPrivacy, privacy],
  );

  const handleReblog = useCallback(() => {
    onReblog(privacy);
    onClose();
  }, [onReblog, onClose, privacy]);

  return (
    <ModalShell maxWidth={600}>
      <ModalTitle className={classes.header}>
        <Icon icon={StatusBoostIcon} className={classes.headerIcon} />
        {status?.reblogged ? (
          <FormattedMessage
            id='boost_modal.undo_reblog'
            defaultMessage='Unboost post?'
            tagName='span'
          />
        ) : (
          <FormattedMessage
            id='boost_modal.reblog'
            defaultMessage='Boost post?'
            tagName='span'
          />
        )}

        <span className={classes.subheader}>
          {missingMediaDescription ? (
            <FormattedMessage
              id='boost_modal.missing_description'
              defaultMessage='This toot contains some media without description'
            />
          ) : (
            <FormattedMessage
              id='boost_modal.combo'
              defaultMessage='You can press {combo} to skip this next time'
              values={{
                combo: (
                  <span className='hotkey-combination'>
                    <kbd>Shift</kbd>+
                    <Icon icon={StatusBoostIcon} />
                  </span>
                ),
              }}
            />
          )}
        </span>
      </ModalTitle>

      <QuotedStatus id={statusId} disableOpen />

      <ModalActions>
        <Menu>
          <MenuTrigger size='sm' trailingIcon={CaretIcon}>
            <ComposeVisibilityButtonText privacy={privacy} />
          </MenuTrigger>

          <MenuList placement='bottom-start' maxWidth={280}>
            <MenuItemRadio
              name='visibility'
              value='public'
              checked={privacy === 'public' || privacy === 'unlisted'}
              onChange={handlePrivacyChange}
            >
              <FormattedMessage
                id='privacy.public.short'
                defaultMessage='Public'
              />
            </MenuItemRadio>

            <MenuItemRadio
              name='visibility'
              value='private'
              checked={privacy === 'private'}
              onChange={handlePrivacyChange}
            >
              <FormattedMessage
                id='compose.privacy.followers'
                defaultMessage='Followers (+ mentions)'
              />
            </MenuItemRadio>

            <MenuItemDivider />

            <MenuItemCheckbox
              value='unlisted'
              disabled={privacy === 'private'}
              checked={privacy === 'unlisted' || privacy === 'private'}
              onChange={handlePrivacyChange}
              description={
                <FormattedMessage
                  id='compose.discoverable.hint'
                  defaultMessage='Also applies to discovery feeds'
                />
              }
            >
              <FormattedMessage
                id='compose.discoverable'
                defaultMessage='Hide from search results'
              />
            </MenuItemCheckbox>
          </MenuList>
        </Menu>

        <div>
          <Button size='sm' variant='ghost' onClick={onClose}>
            <FormattedMessage
              id='confirmation_modal.cancel'
              defaultMessage='Cancel'
            />
          </Button>

          <Button size='sm' variant='solid' onClick={handleReblog}>
            {status?.reblogged ? (
              <FormattedMessage
                id='status.cancel_reblog_private'
                defaultMessage='Unboost'
              />
            ) : (
              <FormattedMessage id='status.reblog' defaultMessage='Boost' />
            )}
          </Button>
        </div>
      </ModalActions>
    </ModalShell>
  );
};
