import { useEffect } from 'react';

import { AnnualReport } from 'mastodon/features/annual_report';

const AnnualReportModal: React.FC<{
  onChangeBackgroundColor: (color: string) => void;
}> = ({ onChangeBackgroundColor }) => {
  useEffect(() => {
    onChangeBackgroundColor('var(--indigo-1)');
  }, [onChangeBackgroundColor]);

  return (
    <div className='modal-root__modal annual-report-modal'>
      <AnnualReport />
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default AnnualReportModal;
