import { useCallback } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import IconPlanet from '@/images/icons/icon_planet.svg?react';
import { openModal } from '@/mastodon/actions/modal';
import { Icon } from '@/mastodon/components/icon';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import classes from './index.module.scss';

const selectReportModalOpen = createAppSelector(
  [(state) => state.modal.getIn(['stack', 0, 'modalType'])],
  (modalType) => modalType === 'ANNUAL_REPORT',
);

export const AnnualReportNavItem: FC = () => {
  const { state, year } = useAppSelector((state) => state.annualReport);
  const active = useAppSelector(selectReportModalOpen);

  const dispatch = useAppDispatch();
  const handleClick = useCallback(() => {
    dispatch(openModal({ modalType: 'ANNUAL_REPORT', modalProps: {} }));
  }, [dispatch]);

  if (!year || !state || state === 'ineligible') {
    return null;
  }

  return (
    <button
      type='button'
      className={classNames('column-link column-link--transparent', { active })}
      onClick={handleClick}
    >
      <Icon icon={IconPlanet} id='wrapstodon-planet' width='24' height='24' />
      <span>Wrapstodon {year}</span>
      <span className={classNames('column-link__badge', classes.navItemBadge)}>
        <FormattedMessage
          id='annual_report.nav_item.badge'
          defaultMessage='New'
        />
      </span>
    </button>
  );
};
