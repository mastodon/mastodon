import type { MouseEventHandler } from 'react';
import { useCallback, useEffect } from 'react';

import classNames from 'classnames';

import { closeModal } from '@/mastodon/actions/modal';
import { generateReport } from '@/mastodon/reducers/slices/annual_report';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { AnnualReport } from '.';
import { AnnualReportAnnouncement } from './announcement';
import styles from './index.module.scss';

const AnnualReportModal: React.FC<{
  onChangeBackgroundColor: (color: string) => void;
}> = ({ onChangeBackgroundColor }) => {
  useEffect(() => {
    onChangeBackgroundColor('var(--color-bg-media-base)');
  }, [onChangeBackgroundColor]);

  const { state, year } = useAppSelector((state) => state.annualReport);

  const showAnnouncement = year && state && state !== 'available';

  const dispatch = useAppDispatch();

  const handleBuildRequest = useCallback(() => {
    void dispatch(generateReport());
  }, [dispatch]);

  const handleClose = useCallback(() => {
    dispatch(closeModal({ modalType: 'ANNUAL_REPORT', ignoreFocus: false }));
  }, [dispatch]);

  const handleCloseModal: MouseEventHandler = useCallback(
    (e) => {
      if (e.target === e.currentTarget) {
        handleClose();
      }
    },
    [handleClose],
  );

  // Auto-close if ineligible
  useEffect(() => {
    if (state === 'ineligible') {
      handleClose();
    }
  }, [handleClose, state]);

  if (state === 'ineligible') {
    // Not sure how you got here, but don't show anything.
    return null;
  }

  return (
    // It's fine not to provide a keyboard handler here since there is a global
    // [Esc] key listener that will close open modals.
    // This onClick handler is needed since the modalWrapper styles overlap the
    // default modal backdrop, preventing clicks to pass through.
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions
    <div
      className={classNames('modal-root__modal', styles.modalWrapper)}
      data-color-scheme='dark'
      onClick={handleCloseModal}
    >
      {!showAnnouncement ? (
        <AnnualReport context='modal' />
      ) : (
        <AnnualReportAnnouncement
          year={year.toString()}
          state={state}
          onDismiss={handleClose}
          onRequestBuild={handleBuildRequest}
        />
      )}
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default AnnualReportModal;
