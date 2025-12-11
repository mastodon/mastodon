import { useCallback, useEffect } from 'react';

import classNames from 'classnames';

import { closeModal } from '@/mastodon/actions/modal';
import { useAppDispatch } from '@/mastodon/store';

import { AnnualReport } from '.';
import styles from './index.module.scss';

const AnnualReportModal: React.FC<{
  onChangeBackgroundColor: (color: string) => void;
}> = ({ onChangeBackgroundColor }) => {
  useEffect(() => {
    onChangeBackgroundColor('var(--color-bg-media-base)');
  }, [onChangeBackgroundColor]);

  const dispatch = useAppDispatch();
  const handleCloseModal = useCallback<React.MouseEventHandler<HTMLDivElement>>(
    (e) => {
      if (e.target === e.currentTarget)
        dispatch(
          closeModal({ modalType: 'ANNUAL_REPORT', ignoreFocus: false }),
        );
    },
    [dispatch],
  );

  return (
    // It's fine not to provide a keyboard handler here since there is a global
    // [Esc] key listener that will close open modals.
    // This onClick handler is needed since the modalWrapper styles overlap the
    // default modal backdrop, preventing clicks to pass through.
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions
    <div
      className={classNames(
        'modal-root__modal',
        styles.modalWrapper,
        'theme-dark',
      )}
      onClick={handleCloseModal}
    >
      <AnnualReport context='modal' />
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default AnnualReportModal;
