import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

interface Props {
  resource: JSX.Element;
  url: string;
  className?: string;
}

export const TimelineHint: React.FC<Props> = ({ className, resource, url }) => (
  <div className={classNames('timeline-hint', className)}>
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
