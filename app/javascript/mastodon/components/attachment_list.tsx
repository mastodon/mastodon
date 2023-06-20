import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import ImmutablePureComponent from 'react-immutable-pure-component';

import type { MediaAttachment } from 'app/javascript/types/media_attachments';
import { Icon } from 'mastodon/components/icon';

const filename = (url: string) => new URL(url).pathname.split('/').pop();

interface Props {
  media: MediaAttachment[];
  compact: boolean;
}
export class AttachmentList extends ImmutablePureComponent<Props> {
  render() {
    const { media, compact } = this.props;

    return (
      <div className={classNames('attachment-list', { compact })}>
        {!compact && (
          <div className='attachment-list__icon'>
            <Icon id='link' />
          </div>
        )}

        <ul className='attachment-list__list'>
          {media.map((attachment) => {
            const displayUrl =
              attachment.get('remote_url', undefined) ||
              attachment.get('url', undefined);

            return (
              <li key={attachment.get('id', undefined)}>
                <a href={displayUrl} target='_blank' rel='noopener noreferrer'>
                  {compact && <Icon id='link' />}
                  {compact && ' '}
                  {displayUrl ? (
                    filename(displayUrl)
                  ) : (
                    <FormattedMessage
                      id='attachments_list.unprocessed'
                      defaultMessage='(unprocessed)'
                    />
                  )}
                </a>
              </li>
            );
          })}
        </ul>
      </div>
    );
  }
}
