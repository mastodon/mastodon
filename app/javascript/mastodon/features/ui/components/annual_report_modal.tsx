import { useEffect } from 'react';

import { AnnualReport } from 'mastodon/features/annual_report';

const AnnualReportModal: React.FC<{
  year: string;
  onChangeBackgroundColor: (arg0: string) => void;
}> = ({ year, onChangeBackgroundColor }) => {
  useEffect(() => {
    onChangeBackgroundColor('var(--indigo-1)');
  }, [onChangeBackgroundColor]);

  return (
    <div className='modal-root__modal annual-report-modal'>
      <AnnualReport year={year} />
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default AnnualReportModal;
