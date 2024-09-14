import PropTypes from 'prop-types';
import { useRef, useCallback, useEffect, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { useSelector, useDispatch } from 'react-redux';

import ArrowDropDownIcon from '@/material-icons/400-24px/arrow_drop_down.svg?react';
import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { fetchNotificationRequests, expandNotificationRequests, acceptNotificationRequests, dismissNotificationRequests } from 'mastodon/actions/notifications';
import { changeSetting } from 'mastodon/actions/settings';
import { CheckBox } from 'mastodon/components/check_box';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import { Icon } from 'mastodon/components/icon';
import ScrollableList from 'mastodon/components/scrollable_list';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';

import { NotificationRequest } from './components/notification_request';
import { PolicyControls } from './components/policy_controls';
import SettingToggle from './components/setting_toggle';

const messages = defineMessages({
  title: { id: 'notification_requests.title', defaultMessage: 'Filtered notifications' },
  maximize: { id: 'notification_requests.maximize', defaultMessage: 'Maximize' },
  more: { id: 'status.more', defaultMessage: 'More' },
  acceptMultiple: { id: 'notification_requests.accept_multiple', defaultMessage: '{count, plural, one {Accept # request…} other {Accept # requests…}}' },
  dismissMultiple: { id: 'notification_requests.dismiss_multiple', defaultMessage: '{count, plural, one {Dismiss # request…} other {Dismiss # requests…}}' },
  confirmAcceptMultipleTitle: { id: 'notification_requests.confirm_accept_multiple.title', defaultMessage: 'Accept notification requests?' },
  confirmAcceptMultipleMessage: { id: 'notification_requests.confirm_accept_multiple.message', defaultMessage: 'You are about to accept {count, plural, one {one notification request} other {# notification requests}}. Are you sure you want to proceed?' },
  confirmAcceptMultipleButton: { id: 'notification_requests.confirm_accept_multiple.button', defaultMessage: '{count, plural, one {Accept request} other {Accept requests}}' },
  confirmDismissMultipleTitle: { id: 'notification_requests.confirm_dismiss_multiple.title', defaultMessage: 'Dismiss notification requests?' },
  confirmDismissMultipleMessage: { id: 'notification_requests.confirm_dismiss_multiple.message', defaultMessage: "You are about to dismiss {count, plural, one {one notification request} other {# notification requests}}. You won't be able to easily access {count, plural, one {it} other {them}} again. Are you sure you want to proceed?" },
  confirmDismissMultipleButton: { id: 'notification_requests.confirm_dismiss_multiple.button', defaultMessage: '{count, plural, one {Dismiss request} other {Dismiss requests}}' },
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

const SelectRow = ({selectAllChecked, toggleSelectAll, selectedItems, selectionMode, setSelectionMode}) => {
  const intl = useIntl();
  const dispatch = useDispatch();

  const selectedCount = selectedItems.length;

  const handleAcceptMultiple = useCallback(() => {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.confirmAcceptMultipleTitle),
        message: intl.formatMessage(messages.confirmAcceptMultipleMessage, { count: selectedItems.length }),
        confirm: intl.formatMessage(messages.confirmAcceptMultipleButton, { count: selectedItems.length}),
        onConfirm: () =>
          dispatch(acceptNotificationRequests(selectedItems)),
      },
    }));
  }, [dispatch, intl, selectedItems]);

  const handleDismissMultiple = useCallback(() => {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.confirmDismissMultipleTitle),
        message: intl.formatMessage(messages.confirmDismissMultipleMessage, { count: selectedItems.length }),
        confirm: intl.formatMessage(messages.confirmDismissMultipleButton, { count: selectedItems.length}),
        onConfirm: () =>
          dispatch(dismissNotificationRequests(selectedItems)),
      },
    }));
  }, [dispatch, intl, selectedItems]);

  const handleToggleSelectionMode = useCallback(() => {
    setSelectionMode((mode) => !mode);
  }, [setSelectionMode]);

  const menu = [
    { text: intl.formatMessage(messages.acceptMultiple, { count: selectedCount }), action: handleAcceptMultiple },
    { text: intl.formatMessage(messages.dismissMultiple, { count: selectedCount }), action: handleDismissMultiple },
  ];

  const handleSelectAll = useCallback(() => {
    setSelectionMode(true);
    toggleSelectAll();
  }, [setSelectionMode, toggleSelectAll]);

  return (
    <div className='column-header__select-row'>
      <div className='column-header__select-row__checkbox'>
        <CheckBox checked={selectAllChecked} indeterminate={selectedCount > 0 && !selectAllChecked} onChange={handleSelectAll} />
      </div>
      <DropdownMenuContainer
        items={menu}
        icons='ellipsis-h'
        iconComponent={MoreHorizIcon}
        direction='right'
        title={intl.formatMessage(messages.more)}
      >
        <button className='dropdown-button column-header__select-row__select-menu' disabled={selectedItems.length === 0}>
          <span className='dropdown-button__label'>
            {selectedCount} selected
          </span>
          <Icon id='down' icon={ArrowDropDownIcon} />
        </button>
      </DropdownMenuContainer>
      <div className='column-header__select-row__mode-button'>
        <button className='text-btn' tabIndex={0} onClick={handleToggleSelectionMode}>
          {selectionMode ? (
            <FormattedMessage id='notification_requests.exit_selection' defaultMessage='Done' />
          ) :
            (
              <FormattedMessage id='notification_requests.edit_selection' defaultMessage='Edit' />
            )}
        </button>
      </div>
    </div>
  );
};

SelectRow.propTypes = {
  selectAllChecked: PropTypes.func.isRequired,
  toggleSelectAll: PropTypes.func.isRequired,
  selectedItems: PropTypes.arrayOf(PropTypes.string).isRequired,
  selectionMode: PropTypes.bool,
  setSelectionMode: PropTypes.func.isRequired,
};

export const NotificationRequests = ({ multiColumn }) => {
  const columnRef = useRef();
  const intl = useIntl();
  const dispatch = useDispatch();
  const isLoading = useSelector(state => state.getIn(['notificationRequests', 'isLoading']));
  const notificationRequests = useSelector(state => state.getIn(['notificationRequests', 'items']));
  const hasMore = useSelector(state => !!state.getIn(['notificationRequests', 'next']));

  const [selectionMode, setSelectionMode] = useState(false);
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
          notificationRequests.size > 0 && (
            <SelectRow selectionMode={selectionMode} setSelectionMode={setSelectionMode} selectAllChecked={selectAllChecked} toggleSelectAll={toggleSelectAll} selectedItems={checkedRequestIds} />
          )}
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
            showCheckbox={selectionMode}
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
