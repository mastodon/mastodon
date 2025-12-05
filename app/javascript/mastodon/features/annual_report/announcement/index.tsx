import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { Button } from '@/mastodon/components/button';

import styles from './styles.module.scss';

export const AnnualReportAnnouncement: React.FC<{
  year: string;
  hasData: boolean;
  isLoading: boolean;
  onRequestBuild: () => void;
  onOpen: () => void;
}> = ({ year, hasData, isLoading, onRequestBuild, onOpen }) => {
  return (
    <div className={classNames('theme-dark', styles.wrapper)}>
      <h2>
        <FormattedMessage
          id='annual_report.announcement.title'
          defaultMessage='Wrapstodon {year} has arrived'
          values={{ year }}
        />
      </h2>
      <p>
        <FormattedMessage
          id='annual_report.announcement.description'
          defaultMessage='Discover more about your engagement on Mastodon over the past year.'
        />
      </p>
      {hasData ? (
        <Button onClick={onOpen}>
          <FormattedMessage
            id='annual_report.announcement.action_view'
            defaultMessage='View my Wrapstodon'
          />
        </Button>
      ) : (
        <Button loading={isLoading} onClick={onRequestBuild}>
          <FormattedMessage
            id='annual_report.announcement.action_build'
            defaultMessage='Build my Wrapstodon'
          />
        </Button>
      )}
    </div>
  );
};
