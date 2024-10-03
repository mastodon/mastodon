import { FormattedMessage } from 'react-intl';

export enum BannerVariant {
  Yellow = 'yellow',
  Blue = 'blue',
}

export const StatusBanner: React.FC<{
  children: React.ReactNode;
  variant: BannerVariant;
  expanded?: boolean;
  onClick?: () => void;
}> = ({ children, variant, expanded, onClick }) => (
  <div
    className={
      variant === BannerVariant.Yellow
        ? 'content-warning'
        : 'content-warning content-warning--filter'
    }
  >
    {children}

    <button className='link-button' onClick={onClick}>
      {expanded ? (
        <FormattedMessage
          id='content_warning.hide'
          defaultMessage='Hide post'
        />
      ) : (
        <FormattedMessage
          id='content_warning.show'
          defaultMessage='Show anyway'
        />
      )}
    </button>
  </div>
);
