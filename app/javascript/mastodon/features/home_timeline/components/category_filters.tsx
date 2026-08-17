import type { ChangeEvent } from 'react';
import { useCallback, useEffect, useMemo, useState } from 'react';

import type { IntlShape } from 'react-intl';
import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import ExpandMoreIcon from '@/material-icons/400-24px/expand_more.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications_active-fill.svg?react';
import { fetchCategories } from 'mastodon/actions/categories';
import {
  addCategoryFilter,
  fetchCategoryFilters,
  removeCategoryFilter,
} from 'mastodon/actions/category_filters';
import {
  addCategoryNotification,
  fetchCategoryNotifications,
  removeCategoryNotification,
} from 'mastodon/actions/category_notifications';
import { requestBrowserPermission } from 'mastodon/actions/notifications';
import {
  changeAlerts,
  register as registerPushNotifications,
} from 'mastodon/actions/push_notifications';
import { CircularProgress } from 'mastodon/components/circular_progress';
import { Toggle } from 'mastodon/components/form_fields';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
import { me } from 'mastodon/initial_state';
import type { AccountCategory } from 'mastodon/models/account_categories';
import {
  selectBrowserPermission,
  selectBrowserSupport,
  selectCategories,
  selectCategoriesLoaded,
  selectCategoriesLoading,
  selectFiltersLoaded,
  selectFiltersLoading,
  selectFiltersSaving,
  selectHiddenCategories,
  selectNotificationCategories,
  selectNotificationsLoaded,
  selectNotificationsLoading,
  selectNotificationsSaving,
  selectPushStatusEnabled,
  selectPushSubscribed,
} from 'mastodon/selectors/category_filters';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  title: {
    id: 'home.category_filters.title',
    defaultMessage: 'Feed categories',
  },
  subtitle: {
    id: 'home.category_filters.subtitle',
    defaultMessage: 'Choose which categories stay in your home feed',
  },
  show: {
    id: 'home.category_filters.show',
    defaultMessage: 'Show category filters',
  },
  hide: {
    id: 'home.category_filters.hide',
    defaultMessage: 'Hide category filters',
  },
  empty: {
    id: 'home.category_filters.empty',
    defaultMessage: 'No categories are available yet.',
  },
  loading: {
    id: 'home.category_filters.loading',
    defaultMessage: 'Loading categories...',
  },
  alwaysOn: {
    id: 'home.category_filters.always_on',
    defaultMessage: 'Always showing',
  },
  on: {
    id: 'home.category_filters.on',
    defaultMessage: 'Showing',
  },
  off: {
    id: 'home.category_filters.off',
    defaultMessage: 'Hidden',
  },
  toggleLabel: {
    id: 'home.category_filters.toggle',
    defaultMessage: 'Toggle {category} category',
  },
  pushEnable: {
    id: 'home.category_filters.push_enable',
    defaultMessage: 'Enable notifications for {category}',
  },
  pushDisable: {
    id: 'home.category_filters.push_disable',
    defaultMessage: 'Disable notifications for {category}',
  },
  pushUnavailable: {
    id: 'home.category_filters.push_unavailable',
    defaultMessage:
      'Enable notifications for {category}. Browser permission may be requested.',
  },
});

const getCategoryId = (category: AccountCategory) =>
  category.get('id') || category.get('name');

interface CategoryFiltersDataParams {
  dispatch: ReturnType<typeof useAppDispatch>;
  isCategoriesLoaded: boolean;
  isCategoriesLoading: boolean;
  areFiltersLoaded: boolean;
  areFiltersLoading: boolean;
  isNotificationsLoaded: boolean;
  isNotificationsLoading: boolean;
  categoriesLength: number;
}

const useCategoryFiltersData = ({
  dispatch,
  isCategoriesLoaded,
  isCategoriesLoading,
  areFiltersLoaded,
  areFiltersLoading,
  isNotificationsLoaded,
  isNotificationsLoading,
  categoriesLength,
}: CategoryFiltersDataParams) => {
  useEffect(() => {
    if (!isCategoriesLoaded && me) {
      void dispatch(fetchCategories());
    }
  }, [dispatch, isCategoriesLoaded]);

  useEffect(() => {
    if (!areFiltersLoaded && me) {
      void dispatch(fetchCategoryFilters());
    }
  }, [dispatch, areFiltersLoaded]);

  useEffect(() => {
    if (!isNotificationsLoaded && me) {
      void dispatch(fetchCategoryNotifications());
    }
  }, [dispatch, isNotificationsLoaded]);

  return (
    (!isCategoriesLoaded ||
      isCategoriesLoading ||
      !areFiltersLoaded ||
      areFiltersLoading ||
      !isNotificationsLoaded ||
      isNotificationsLoading) &&
    categoriesLength === 0
  );
};

interface CategoryRowProps {
  category: AccountCategory;
  isHidden: boolean;
  isMandatory: boolean;
  isSaving: boolean;
  isNotifySaving: boolean;
  isNotifyEnabled: boolean;
  notifyTitle: string;
  toggleAriaLabel: string;
  onToggleChange: (event: ChangeEvent<HTMLInputElement>) => void;
  onNotifyToggle: () => void;
}

const CategoryRow: React.FC<CategoryRowProps> = ({
  category,
  isHidden,
  isMandatory,
  isSaving,
  isNotifySaving,
  isNotifyEnabled,
  notifyTitle,
  toggleAriaLabel,
  onToggleChange,
  onNotifyToggle,
}) => {
  const categoryId = getCategoryId(category);
  const stateMessage = isMandatory
    ? messages.alwaysOn
    : isHidden
      ? messages.off
      : messages.on;

  const categoryLabel = (
    <div className='home-category-filters__label'>
      <span className='home-category-filters__name'>
        {category.get('name')}
      </span>

      <div className='home-category-filters__meta'>
        <span className='home-category-filters__state'>
          <FormattedMessage {...stateMessage} />
        </span>
      </div>
    </div>
  );

  return (
    <div className='home-category-filters__item'>
      {isMandatory ? (
        <div className='home-category-filters__content'>{categoryLabel}</div>
      ) : (
        <label
          htmlFor={`home-category-filter-${categoryId}`}
          className='home-category-filters__control'
        >
          <Toggle
            id={`home-category-filter-${categoryId}`}
            checked={!isHidden}
            disabled={isSaving}
            onChange={onToggleChange}
            aria-label={toggleAriaLabel}
          />

          {categoryLabel}
        </label>
      )}

      <IconButton
        className='home-category-filters__notify'
        icon={isNotifyEnabled ? 'bell' : 'bell-o'}
        iconComponent={
          isNotifyEnabled ? NotificationsActiveIcon : NotificationsIcon
        }
        active={isNotifyEnabled}
        title={notifyTitle}
        onClick={onNotifyToggle}
        disabled={isNotifySaving}
      />
    </div>
  );
};

const getNotifyTitle = (
  intl: IntlShape,
  categoryName: string,
  isNotifyEnabled: boolean,
  browserSupport: boolean,
  browserPermission: string,
) => {
  if (!isNotifyEnabled && browserSupport && browserPermission !== 'granted') {
    return intl.formatMessage(messages.pushUnavailable, {
      category: categoryName,
    });
  }

  return intl.formatMessage(
    isNotifyEnabled ? messages.pushDisable : messages.pushEnable,
    { category: categoryName },
  );
};

export const CategoryFilters: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const [expanded, setExpanded] = useState(false);

  const categories = useAppSelector(selectCategories);
  const isCategoriesLoading = useAppSelector(selectCategoriesLoading);
  const isCategoriesLoaded = useAppSelector(selectCategoriesLoaded);
  const hiddenCategories = useAppSelector(selectHiddenCategories);
  const areFiltersLoading = useAppSelector(selectFiltersLoading);
  const areFiltersLoaded = useAppSelector(selectFiltersLoaded);
  const filtersSaving = useAppSelector(selectFiltersSaving);
  const notificationCategories = useAppSelector(selectNotificationCategories);
  const isNotificationsLoading = useAppSelector(selectNotificationsLoading);
  const isNotificationsLoaded = useAppSelector(selectNotificationsLoaded);
  const notificationsSaving = useAppSelector(selectNotificationsSaving);
  const pushSubscribed = useAppSelector(selectPushSubscribed);
  const pushStatusEnabled = useAppSelector(selectPushStatusEnabled);
  const browserSupport = useAppSelector(selectBrowserSupport);
  const browserPermission = useAppSelector(selectBrowserPermission);
  const categoryItems = useMemo(
    () => categories?.toArray() ?? [],
    [categories],
  );

  const isStillLoading = useCategoryFiltersData({
    dispatch,
    isCategoriesLoaded,
    isCategoriesLoading,
    areFiltersLoaded,
    areFiltersLoading,
    isNotificationsLoaded,
    isNotificationsLoading,
    categoriesLength: categoryItems.length,
  });

  useEffect(() => {
    if (!pushSubscribed || pushStatusEnabled) {
      return;
    }

    if (notificationCategories && notificationCategories.size > 0) {
      dispatch(changeAlerts(['alerts', 'status'], true));
    }
  }, [dispatch, notificationCategories, pushStatusEnabled, pushSubscribed]);

  const handleToggle = useCallback(
    (categoryId: string, checked: boolean) => {
      if (!checked) {
        void dispatch(addCategoryFilter({ categoryId }));
      } else {
        void dispatch(removeCategoryFilter({ categoryId }));
      }
    },
    [dispatch],
  );

  const handleToggleChange = useCallback(
    (categoryId: string) => (event: ChangeEvent<HTMLInputElement>) => {
      handleToggle(categoryId, event.target.checked);
    },
    [handleToggle],
  );

  const handleToggleExpanded = useCallback(() => {
    setExpanded((value) => !value);
  }, []);

  const handleNotificationToggle = useCallback(
    (categoryId: string) => () => {
      const isEnabled = notificationCategories?.has(categoryId);

      if (isEnabled) {
        void dispatch(removeCategoryNotification({ categoryId }));
        return;
      }

      void dispatch(addCategoryNotification({ categoryId }));

      if (browserSupport) {
        if (browserPermission !== 'granted') {
          dispatch(requestBrowserPermission());
        } else if (!pushSubscribed) {
          dispatch(registerPushNotifications());
        }
      }

      if (pushSubscribed && !pushStatusEnabled) {
        dispatch(changeAlerts(['alerts', 'status'], true));
      }
    },
    [
      browserPermission,
      browserSupport,
      dispatch,
      notificationCategories,
      pushSubscribed,
      pushStatusEnabled,
    ],
  );

  const renderBody = () => {
    if (isStillLoading) {
      return (
        <div className='home-category-filters__loading'>
          <CircularProgress size={24} strokeWidth={3} />
          <span>{intl.formatMessage(messages.loading)}</span>
        </div>
      );
    }

    if (!categoryItems.length) {
      return (
        <p className='home-category-filters__empty'>
          <FormattedMessage {...messages.empty} />
        </p>
      );
    }

    return (
      <div className='home-category-filters__list'>
        {categoryItems.map((category) => {
          const categoryId = getCategoryId(category);
          const categoryName = category.get('name');
          const isMandatory = category.get('mandatory_for_readers');
          const isHidden =
            !isMandatory && Boolean(hiddenCategories?.has(categoryId));
          const isSaving = Boolean(filtersSaving?.get(categoryId));
          const isNotifySaving = Boolean(notificationsSaving?.get(categoryId));
          const isNotifyEnabled = Boolean(
            notificationCategories?.has(categoryId),
          );
          const notifyTitle = getNotifyTitle(
            intl,
            categoryName,
            isNotifyEnabled,
            browserSupport,
            browserPermission,
          );
          const toggleAriaLabel = intl.formatMessage(messages.toggleLabel, {
            category: categoryName,
          });

          return (
            <CategoryRow
              key={categoryId}
              category={category}
              isHidden={isHidden}
              isMandatory={isMandatory}
              isSaving={isSaving}
              isNotifySaving={isNotifySaving}
              isNotifyEnabled={isNotifyEnabled}
              notifyTitle={notifyTitle}
              toggleAriaLabel={toggleAriaLabel}
              onToggleChange={handleToggleChange(categoryId)}
              onNotifyToggle={handleNotificationToggle(categoryId)}
            />
          );
        })}
      </div>
    );
  };

  if (!me) return null;

  return (
    <div className='home-category-filters'>
      <button
        type='button'
        className='home-category-filters__header'
        onClick={handleToggleExpanded}
        aria-expanded={expanded}
      >
        <div className='home-category-filters__titles'>
          <span className='home-category-filters__title'>
            <FormattedMessage {...messages.title} />
          </span>
          <span className='home-category-filters__subtitle'>
            <FormattedMessage {...messages.subtitle} />
          </span>
        </div>

        <Icon
          id={expanded ? 'expand-more' : 'chevron-right'}
          icon={expanded ? ExpandMoreIcon : ChevronRightIcon}
        />

        <span className='sr-only'>
          <FormattedMessage {...(expanded ? messages.hide : messages.show)} />
        </span>
      </button>

      {expanded && renderBody()}
    </div>
  );
};
