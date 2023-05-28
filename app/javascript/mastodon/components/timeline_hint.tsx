import { FormattedMessage } from 'react-intl';

interface Props {
  resource: JSX.Element;
  url: string;
}

export const TimelineHint: React.FC<Props> = ({ resource, url }) => (
  <div className='timeline-hint'>
    <strong>
      <FormattedMessage
        id='timeline_hint.remote_resource_not_displayed'
        defaultMessage='{resource} from other servers are not displayed.'
        values={{ resource }}
      />
    </strong>
    <br />
    <a href={url} target='_blank' rel='noopener noreferrer'>
      <FormattedMessage
        id='account.browse_more_on_origin_server'
        defaultMessage='Browse more on the original profile'
      />
    </a>
  </div>
);
