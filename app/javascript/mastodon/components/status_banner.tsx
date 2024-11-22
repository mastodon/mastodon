import { FormattedMessage } from 'react-intl';

export enum BannerVariant {
  Warning = 'warning',
  Filter = 'filter',
}

export const StatusBanner: React.FC<{
  children: React.ReactNode;
  variant: BannerVariant;
  expanded?: boolean;
  onClick?: () => void;
}> = ({ children, variant, expanded, onClick }) => (
  <label
    className={
      variant === BannerVariant.Warning
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
      ) : variant === BannerVariant.Warning ? (
        <FormattedMessage
          id='content_warning.show_more'
          defaultMessage='Show more'
        />
      ) : (
        <FormattedMessage
          id='content_warning.show'
          defaultMessage='Show anyway'
        />
      )}
    </button>
  </label>
);
