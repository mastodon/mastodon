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
    variant={BannerVariant.Blue}
  >
    <p>
      <FormattedMessage
        id='filter_warning.matches_filter'
        defaultMessage='Matches filter “{title}”'
        values={{ title }}
      />
    </p>
  </StatusBanner>
);
