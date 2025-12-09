import { useEffect } from 'react';

import classNames from 'classnames';

import { AnnualReport } from '.';
import styles from './index.module.scss';

const AnnualReportModal: React.FC<{
  onChangeBackgroundColor: (color: string) => void;
}> = ({ onChangeBackgroundColor }) => {
  useEffect(() => {
    onChangeBackgroundColor('var(--color-bg-media-base)');
  }, [onChangeBackgroundColor]);

  return (
    <div
      className={classNames(
        'modal-root__modal',
        styles.modalWrapper,
        'theme-dark',
      )}
    >
      <AnnualReport context='modal' />
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default AnnualReportModal;
