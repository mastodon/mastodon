import { StatusBanner, BannerVariant } from './status_banner';

export const ContentWarning: React.FC<{
  text: string;
  expanded?: boolean;
  onClick?: () => void;
}> = ({ text, expanded, onClick }) => (
  <StatusBanner
    expanded={expanded}
    onClick={onClick}
    variant={BannerVariant.Warning}
  >
    <p dangerouslySetInnerHTML={{ __html: text }} />
  </StatusBanner>
);
