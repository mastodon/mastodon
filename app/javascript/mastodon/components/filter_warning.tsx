import { FormattedMessage } from 'react-intl';

import { StatusBanner, BannerVariant } from './status_banner';

export const FilterWarning: React.FC<{
  title: string;
  expanded?: boolean;
  onClick?: () => void;
}> = ({ title, expanded, onClick }) => (
  <StatusBanner
    expanded={expanded}
    onClick={onClick}
    variant={BannerVariant.Filter}
  >
    <FormattedMessage
      id='filter_warning.matches_filter'
      defaultMessage='Matches filter “<span>{title}</span>”'
      values={{
        title,
        span: (chunks) => <span className='filter-name'>{chunks}</span>,
      }}
    />
  </StatusBanner>
);
