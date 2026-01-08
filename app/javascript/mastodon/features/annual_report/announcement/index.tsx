import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import type { ApiAnnualReportState } from '@/mastodon/api/annual_report';
import { Button } from '@/mastodon/components/button';

import styles from './styles.module.scss';

export interface AnnualReportAnnouncementProps {
  year: string;
  state: Exclude<ApiAnnualReportState, 'ineligible'>;
  onRequestBuild: () => void;
  onOpen?: () => void; // This is optional when inside the modal, as it won't be shown then.
  onDismiss: () => void;
}

export const AnnualReportAnnouncement: React.FC<
  AnnualReportAnnouncementProps
> = ({ year, state, onRequestBuild, onOpen, onDismiss }) => {
  return (
    <div className={classNames('theme-dark', styles.wrapper)}>
      <FormattedMessage
        id='annual_report.announcement.title'
        defaultMessage='Wrapstodon {year} has arrived'
        values={{ year }}
        tagName='h2'
      />
      <FormattedMessage
        id='annual_report.announcement.description'
        defaultMessage='Discover more about your engagement on Mastodon over the past year.'
        tagName='p'
      />
      {state === 'available' ? (
        <Button onClick={onOpen}>
          <FormattedMessage
            id='annual_report.announcement.action_view'
            defaultMessage='View my Wrapstodon'
          />
        </Button>
      ) : (
        <Button loading={state === 'generating'} onClick={onRequestBuild}>
          <FormattedMessage
            id='annual_report.announcement.action_build'
            defaultMessage='Build my Wrapstodon'
          />
        </Button>
      )}
      {state === 'eligible' && (
        <Button onClick={onDismiss} plain className={styles.closeButton}>
          <FormattedMessage
            id='annual_report.announcement.action_dismiss'
            defaultMessage='No thanks'
          />
        </Button>
      )}
    </div>
  );
};
