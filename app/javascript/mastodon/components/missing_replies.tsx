import { FormattedMessage } from 'react-intl';

interface Props {
  href: string;
}

export const MissingReplies: React.FC<Props> = ({ href }) => {
  return (
    <div className='missing-replies' style={{ visibility: 'visible' }}>
      <h3>
        <FormattedMessage
          id='status.missing_replies'
          defaultMessage='Replies from other servers may not be displayed.'
        />
      </h3>
      <a href={href} target='_blank' rel='noreferrer'>
        <FormattedMessage
          id='status.missing_replies.open'
          defaultMessage='See all replies on the original server.'
        />
      </a>
    </div>
  );
};
