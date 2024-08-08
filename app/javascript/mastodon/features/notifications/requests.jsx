import PropTypes from 'prop-types';
import { useRef, useCallback, useEffect, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { useSelector, useDispatch } from 'react-redux';

import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { fetchNotificationRequests, expandNotificationRequests } from 'mastodon/actions/notifications';
import { changeSetting } from 'mastodon/actions/settings';
import { CheckBox } from 'mastodon/components/check_box';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import ScrollableList from 'mastodon/components/scrollable_list';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';

import { NotificationRequest } from './components/notification_request';
import { PolicyControls } from './components/policy_controls';
import SettingToggle from './components/setting_toggle';

const messages = defineMessages({
  title: { id: 'notification_requests.title', defaultMessage: 'Filtered notifications' },
  maximize: { id: 'notification_requests.maximize', defaultMessage: 'Maximize' },
  more: { id: 'status.more', defaultMessage: 'More' },
  acceptAll: { id: 'notification_requests.accept_all', defaultMessage: 'Accept all' },
  muteAll: { id: 'notification_requests.mute_all', defaultMessage: 'Mute all' },
  acceptMultiple: { id: 'notification_requests.accept_multiple', defaultMessage: '{count, plural, one {Accept # request} other {Accept # requests}}' },
  muteMultiple: { id: 'notification_requests.mute_multiple', defaultMessage: '{count, plural, one {Mute # request} other {Mute # requests}}' },
});

const ColumnSettings = () => {
  const dispatch = useDispatch();
  const settings = useSelector((state) => state.settings.get('notifications'));

  const onChange = useCallback(
    (key, checked) => {
      dispatch(changeSetting(['notifications', ...key], checked));
    },
    [dispatch],
  );

  return (
    <div className='column-settings'>
      <section>
        <div className='column-settings__row'>
          <SettingToggle
            prefix='notifications'
            settings={settings}
            settingPath={['minimizeFilteredBanner']}
            onChange={onChange}
            label={
              <FormattedMessage id='notification_requests.minimize_banner' defaultMessage='Minimize filtered notifications banner' />
            }
          />
        </div>
      </section>

      <PolicyControls />
    </div>
  );
};

const SelectRow = ({selectAllChecked, toggleSelectAll, selectedCount}) => {
  const intl = useIntl();

  const menu = selectedCount === 0 ?
    [
      { text: intl.formatMessage(messages.acceptAll), action: () => {} },
      { text: intl.formatMessage(messages.muteAll), action: () => {} }
    ] : [
      { text: intl.formatMessage(messages.acceptMultiple, { count: selectedCount }), action: () => {} },
      { text: intl.formatMessage(messages.muteMultiple, { count: selectedCount }), action: () => {} },
    ];

  return (
    <div className='column-header__select-row'>
      <div className='column-header__select-row__checkbox'><CheckBox checked={selectAllChecked} onChange={toggleSelectAll} />
      </div>
      {selectedCount > 0 &&
        <div className='column-header__select-row__selected-count'>
          {selectedCount} selected
        </div>
      }
      <div className='column-header__select-row__actions'>
        <DropdownMenuContainer
          items={menu}
          icons='ellipsis-h'
          iconComponent={MoreHorizIcon}
          direction='right'
          title={intl.formatMessage(messages.more)}
        />
      </div>
    </div>
  );
};

SelectRow.propTypes = {
  selectAllChecked: PropTypes.func.isRequired,
  toggleSelectAll: PropTypes.func.isRequired,
  selectedCount: PropTypes.number.isRequired,
};

export const NotificationRequests = ({ multiColumn }) => {
  const columnRef = useRef();
  const intl = useIntl();
  const dispatch = useDispatch();
  const isLoading = useSelector(state => state.getIn(['notificationRequests', 'isLoading']));
  const notificationRequests = useSelector(state => state.getIn(['notificationRequests', 'items']));
  const hasMore = useSelector(state => !!state.getIn(['notificationRequests', 'next']));

  const [checkedRequestIds, setCheckedRequestIds] = useState([]);
  const [selectAllChecked, setSelectAllChecked] = useState(false);

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, [columnRef]);

  const handleCheck = useCallback(id => {
    setCheckedRequestIds(ids => {
      const position = ids.indexOf(id);

      if(position > -1)
        ids.splice(position, 1);
      else
        ids.push(id);

      setSelectAllChecked(ids.length === notificationRequests.size);

      return [...ids];
    });
  }, [setCheckedRequestIds, notificationRequests]);

  const toggleSelectAll = useCallback(() => {
    setSelectAllChecked(checked => {
      if(checked)
        setCheckedRequestIds([]);
      else
        setCheckedRequestIds(notificationRequests.map(request => request.get('id')).toArray());

      return !checked;
    });
  }, [notificationRequests]);

  const handleLoadMore = useCallback(() => {
    dispatch(expandNotificationRequests());
  }, [dispatch]);

  useEffect(() => {
    dispatch(fetchNotificationRequests());
  }, [dispatch]);

  return (
    <Column bindToDocument={!multiColumn} ref={columnRef} label={intl.formatMessage(messages.title)}>
      <ColumnHeader
        icon='archive'
        iconComponent={InventoryIcon}
        title={intl.formatMessage(messages.title)}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
        showBackButton
        appendContent={
          <SelectRow selectAllChecked={selectAllChecked} toggleSelectAll={toggleSelectAll} selectedCount={checkedRequestIds.length} />}
      >
        <ColumnSettings />
      </ColumnHeader>

      <ScrollableList
        scrollKey='notification_requests'
        trackScroll={!multiColumn}
        bindToDocument={!multiColumn}
        isLoading={isLoading}
        showLoading={isLoading && notificationRequests.size === 0}
        hasMore={hasMore}
        onLoadMore={handleLoadMore}
        emptyMessage={<FormattedMessage id='empty_column.notification_requests' defaultMessage='All clear! There is nothing here. When you receive new notifications, they will appear here according to your settings.' />}
      >
        {notificationRequests.map(request => (
          <NotificationRequest
            key={request.get('id')}
            id={request.get('id')}
            accountId={request.get('account')}
            notificationsCount={request.get('notifications_count')}
            showCheckbox={checkedRequestIds.length > 0 || selectAllChecked}
            checked={checkedRequestIds.includes(request.get('id'))}
            toggleCheck={handleCheck}
          />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

NotificationRequests.propTypes = {
  multiColumn: PropTypes.bool,
};

export default NotificationRequests;
