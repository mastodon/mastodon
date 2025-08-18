import type { FC } from 'react';

import { useIntl } from 'react-intl';

import type { Status } from '@/mastodon/models/status';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';

import { Dropdown } from '../dropdown_menu';

import { messages } from './messages';

export const StatusMoreMenu: FC<{ status: Status }> = ({ status }) => {
  const intl = useIntl();
  return (
    <Dropdown
      scrollKey={scrollKey}
      status={status}
      items={menu}
      icon='ellipsis-h'
      iconComponent={MoreHorizIcon}
      direction='right'
      title={intl.formatMessage(messages.more)}
    />
  );
};
