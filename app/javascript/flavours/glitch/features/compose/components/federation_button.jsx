import { useCallback } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import SmallShareIcon from '@/material-icons/400-20px/share.svg?react';
import SmallShareOffIcon from '@/material-icons/400-20px/share_off.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import ShareOffIcon from '@/material-icons/400-24px/share_off.svg?react';
import { changeComposeAdvancedOption } from 'flavours/glitch/actions/compose';
import { useAppSelector, useAppDispatch } from 'flavours/glitch/store';

import { DropdownIconButton } from './dropdown_icon_button';

const messages = defineMessages({
  change_federation_settings: { id: 'compose.change_federation', defaultMessage: 'Change federation settings' },
  local_only_label: { id: 'federation.local_only.short', defaultMessage: 'Local-only' },
  local_only_meta: { id: 'federation.local_only.long', defaultMessage: 'Prevent this post from reaching other servers' },
  federated_label: { id: 'federation.federated.short', defaultMessage: 'Federated' },
  federated_meta: { id: 'federation.federated.long', defaultMessage: 'Allow this post to reach other servers' },
});

export const FederationButton = () => {
  const intl = useIntl();

  const isEditing = useAppSelector((state) => state.getIn(['compose', 'id']) !== null);
  const do_not_federate = useAppSelector((state) => state.getIn(['compose', 'advanced_options', 'do_not_federate']));
  const dispatch = useAppDispatch();

  const handleChange = useCallback((value) => {
    dispatch(changeComposeAdvancedOption('do_not_federate', value === 'local-only'));
  }, [dispatch]);

  const options = [
    { icon: 'link', iconComponent: ShareIcon, value: 'federated', text: intl.formatMessage(messages.federated_label), meta: intl.formatMessage(messages.federated_meta) },
    { icon: 'link-slash', iconComponent: ShareOffIcon, value: 'local-only', text: intl.formatMessage(messages.local_only_label), meta: intl.formatMessage(messages.local_only_meta) },
  ];

  return (
    <DropdownIconButton
      disabled={isEditing}
      icon={do_not_federate ? 'link-slash' : 'link'}
      iconComponent={do_not_federate ? SmallShareOffIcon : SmallShareIcon}
      onChange={handleChange}
      options={options}
      title={intl.formatMessage(messages.change_federation_settings)}
      value={do_not_federate ? 'local-only' : 'federated'}
    />
  );
};
