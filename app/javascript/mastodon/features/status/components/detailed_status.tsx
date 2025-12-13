/* eslint-disable @typescript-eslint/no-unsafe-member-access,
                  @typescript-eslint/no-unsafe-call,
                  @typescript-eslint/no-explicit-any,
                  @typescript-eslint/no-unsafe-assignment */

import type { CSSProperties } from 'react';
import { useState, useRef, useCallback, useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import { AnimatedNumber } from 'mastodon/components/animated_number';
import { Avatar } from 'mastodon/components/avatar';
import { ContentWarning } from 'mastodon/components/content_warning';
import { DisplayName } from 'mastodon/components/display_name';
import { EditedTimestamp } from 'mastodon/components/edited_timestamp';
import { FilterWarning } from 'mastodon/components/filter_warning';
import { FormattedDateWrapper } from 'mastodon/components/formatted_date';
import type { StatusLike } from 'mastodon/components/hashtag_bar';
import { getHashtagBarForStatus } from 'mastodon/components/hashtag_bar';
import { Icon } from 'mastodon/components/icon';
import { IconLogo } from 'mastodon/components/logo';
import MediaGallery from 'mastodon/components/media_gallery';
import { PictureInPicturePlaceholder } from 'mastodon/components/picture_in_picture_placeholder';
import StatusContent from 'mastodon/components/status_content';
import { QuotedStatus } from 'mastodon/components/status_quoted';
import { VisibilityIcon } from 'mastodon/components/visibility_icon';
import { Audio } from 'mastodon/features/audio';
import scheduleIdleTask from 'mastodon/features/ui/util/schedule_idle_task';
import { Video } from 'mastodon/features/video';
import { useIdentity } from 'mastodon/identity_context';

import Card from './card';

interface VideoModalOptions {
  startTime: number;
  autoPlay?: boolean;
  defaultVolume: number;
}

export const DetailedStatus: React.FC<{
  status: any;
  onOpenMedia?: (status: any, index: number, lang: string) => void;
  onOpenVideo?: (status: any, lang: string, options: VideoModalOptions) => void;
  onTranslate?: (status: any) => void;
  measureHeight?: boolean;
  onHeightChange?: () => void;
  domain: string;
  showMedia?: boolean;
  withLogo?: boolean;
  overrideDisplayName?: React.ReactNode;
  pictureInPicture: any;
  onToggleHidden?: (status: any) => void;
  onToggleMediaVisibility?: () => void;
  ancestors?: number;
  multiColumn?: boolean;
}> = ({
  status,
  onOpenMedia,
  onOpenVideo,
  onTranslate,
  measureHeight,
  onHeightChange,
  domain,
  showMedia,
  withLogo,
  overrideDisplayName,
  pictureInPicture,
  onToggleMediaVisibility,
  onToggleHidden,
  ancestors = 0,
  multiColumn = false,
}) => {
  const properStatus = status?.get('reblog') ?? status;
  const [height, setHeight] = useState(0);
  const [showDespiteFilter, setShowDespiteFilter] = useState(false);
  const nodeRef = useRef<HTMLDivElement>();

  const { signedIn } = useIdentity();

  const handleOpenVideo = useCallback(
    (options: VideoModalOptions) => {
      const lang = (status.getIn(['translation', 'language']) ||
        status.get('language')) as string;
      if (onOpenVideo)
        onOpenVideo(status.getIn(['media_attachments', 0]), lang, options);
    },
    [onOpenVideo, status],
  );

  const handleFilterToggle = useCallback(() => {
    setShowDespiteFilter(!showDespiteFilter);
  }, [showDespiteFilter, setShowDespiteFilter]);

  const handleExpandedToggle = useCallback(() => {
    if (onToggleHidden) onToggleHidden(status);
  }, [onToggleHidden, status]);

  const _measureHeight = useCallback(
    (heightJustChanged?: boolean) => {
      if (measureHeight && nodeRef.current) {
        scheduleIdleTask(() => {
          if (nodeRef.current)
            setHeight(Math.ceil(nodeRef.current.scrollHeight) + 1);
        });

        if (onHeightChange && heightJustChanged) {
          onHeightChange();
        }
      }
    },
    [onHeightChange, measureHeight, setHeight],
  );

  const handleRef = useCallback(
    (c: HTMLDivElement) => {
      nodeRef.current = c;
      _measureHeight();
    },
    [_measureHeight],
  );

  const handleTranslate = useCallback(() => {
    if (onTranslate) onTranslate(status);
  }, [onTranslate, status]);

  // The component is managed and will change if the status changes
  // Ancestors can increase when loading a thread, in which case we want to scroll,
  // or decrease if a post is deleted, in which case we don't want to mess with it
  const previousAncestors = useRef(-1);
  useEffect(() => {
    if (nodeRef.current && previousAncestors.current < ancestors) {
      nodeRef.current.scrollIntoView(true);

      // In the single-column interface, `scrollIntoView` will put the post behind the header, so compensate for that.
      if (!multiColumn) {
        const offset = document
          .querySelector('.column-header__wrapper')
          ?.getBoundingClientRect().bottom;

        if (offset) {
          const scrollingElement = document.scrollingElement ?? document.body;
          scrollingElement.scrollBy(0, -offset);
        }
      }
    }

    previousAncestors.current = ancestors;
  }, [ancestors, multiColumn]);

  if (!properStatus) {
    return null;
  }

  let media;
  let applicationLink;
  let reblogLink;
  let quotesLink;
  let attachmentAspectRatio;

  if (properStatus.get('media_attachments').getIn([0, 'type']) === 'video') {
    attachmentAspectRatio = `${properStatus.get('media_attachments').getIn([0, 'meta', 'original', 'width'])} / ${properStatus.get('media_attachments').getIn([0, 'meta', 'original', 'height'])}`;
  } else if (
    properStatus.get('media_attachments').getIn([0, 'type']) === 'audio'
  ) {
    attachmentAspectRatio = '16 / 9';
  } else {
    attachmentAspectRatio =
      properStatus.get('media_attachments').size === 1 &&
      properStatus
        .get('media_attachments')
        .getIn([0, 'meta', 'small', 'aspect'])
        ? properStatus
            .get('media_attachments')
            .getIn([0, 'meta', 'small', 'aspect'])
        : '3 / 2';
  }

  const outerStyle = { boxSizing: 'border-box' } as CSSProperties;

  if (measureHeight) {
    outerStyle.height = height;
  }

  const language =
    status.getIn(['translation', 'language']) || status.get('language');

  if (pictureInPicture.get('inUse')) {
    media = <PictureInPicturePlaceholder aspectRatio={attachmentAspectRatio} />;
  } else if (status.get('media_attachments').size > 0) {
    if (
      ['image', 'gifv', 'unknown'].includes(
        status.getIn(['media_attachments', 0, 'type']) as string,
      ) ||
      status.get('media_attachments').size > 1
    ) {
      media = (
        <MediaGallery
          standalone
          sensitive={status.get('sensitive')}
          media={status.get('media_attachments')}
          lang={language}
          height={300}
          onOpenMedia={onOpenMedia}
          visible={showMedia}
          onToggleVisibility={onToggleMediaVisibility}
          matchedFilters={status.get('matched_media_filters')}
        />
      );
    } else if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
      const attachment = status.getIn(['media_attachments', 0]);
      const description =
        attachment.getIn(['translation', 'description']) ||
        attachment.get('description');

      media = (
        <Audio
          src={attachment.get('url')}
          alt={description}
          lang={language}
          poster={
            attachment.get('preview_url') ||
            status.getIn(['account', 'avatar_static'])
          }
          duration={attachment.getIn(['meta', 'original', 'duration'], 0)}
          backgroundColor={attachment.getIn(['meta', 'colors', 'background'])}
          foregroundColor={attachment.getIn(['meta', 'colors', 'foreground'])}
          accentColor={attachment.getIn(['meta', 'colors', 'accent'])}
          sensitive={status.get('sensitive')}
          visible={showMedia}
          blurhash={attachment.get('blurhash')}
          onToggleVisibility={onToggleMediaVisibility}
          matchedFilters={status.get('matched_media_filters')}
        />
      );
    } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
      const attachment = status.getIn(['media_attachments', 0]);
      const description =
        attachment.getIn(['translation', 'description']) ||
        attachment.get('description');

      media = (
        <Video
          preview={attachment.get('preview_url')}
          frameRate={attachment.getIn(['meta', 'original', 'frame_rate'])}
          aspectRatio={`${attachment.getIn(['meta', 'original', 'width'])} / ${attachment.getIn(['meta', 'original', 'height'])}`}
          blurhash={attachment.get('blurhash')}
          src={attachment.get('url')}
          alt={description}
          lang={language}
          onOpenVideo={handleOpenVideo}
          sensitive={status.get('sensitive')}
          visible={showMedia}
          onToggleVisibility={onToggleMediaVisibility}
          matchedFilters={status.get('matched_media_filters')}
        />
      );
    }
  } else if (status.get('card') && !status.get('quote')) {
    media = (
      <Card
        key={`${status.get('id')}-${status.get('edited_at')}`}
        sensitive={status.get('sensitive')}
        card={status.get('card')}
      />
    );
  }

  if (status.get('application')) {
    applicationLink = (
      <>
        ·
        <a
          className='detailed-status__application'
          href={status.getIn(['application', 'website'])}
          target='_blank'
          rel='noopener noreferrer'
        >
          {status.getIn(['application', 'name'])}
        </a>
      </>
    );
  }

  const visibilityLink = (
    <>
      ·<VisibilityIcon visibility={status.get('visibility')} />
    </>
  );

  if (['private', 'direct'].includes(status.get('visibility') as string)) {
    reblogLink = '';
  } else {
    reblogLink = (
      <Link
        to={`/@${status.getIn(['account', 'acct'])}/${status.get('id')}/reblogs`}
        className='detailed-status__link'
      >
        <FormattedMessage
          id='status.reblogs_count'
          defaultMessage='{count, plural, one {{counter} boost} other {{counter} boosts}}'
          values={{
            count: status.get('reblogs_count'),
            counter: (
              <span className='detailed-status__reblogs'>
                <AnimatedNumber value={status.get('reblogs_count')} />
              </span>
            ),
          }}
        />
      </Link>
    );
  }

  if (['private', 'direct'].includes(status.get('visibility') as string)) {
    quotesLink = '';
  } else if (signedIn) {
    quotesLink = (
      <Link
        to={`/@${status.getIn(['account', 'acct'])}/${status.get('id')}/quotes`}
        className='detailed-status__link'
      >
        <FormattedMessage
          id='status.quotes_count'
          defaultMessage='{count, plural, one {{counter} quote} other {{counter} quotes}}'
          values={{
            count: status.get('quotes_count'),
            counter: (
              <span className='detailed-status__quotes'>
                <AnimatedNumber value={status.get('quotes_count')} />
              </span>
            ),
          }}
        />
      </Link>
    );
  } else {
    quotesLink = (
      <span className='detailed-status__link'>
        <FormattedMessage
          id='status.quotes_count'
          defaultMessage='{count, plural, one {{counter} quote} other {{counter} quotes}}'
          values={{
            count: status.get('quotes_count'),
            counter: (
              <span className='detailed-status__quotes'>
                <AnimatedNumber value={status.get('quotes_count')} />
              </span>
            ),
          }}
        />
      </span>
    );
  }

  const favouriteLink = (
    <Link
      to={`/@${status.getIn(['account', 'acct'])}/${status.get('id')}/favourites`}
      className='detailed-status__link'
    >
      <FormattedMessage
        id='status.favourites_count'
        defaultMessage='{count, plural, one {{counter} favorite} other {{counter} favorites}}'
        values={{
          count: status.get('favourites_count'),
          counter: (
            <span className='detailed-status__favorites'>
              <AnimatedNumber value={status.get('favourites_count')} />
            </span>
          ),
        }}
      />
    </Link>
  );

  const { statusContentProps, hashtagBar } = getHashtagBarForStatus(
    status as StatusLike,
  );

  const matchedFilters = status.get('matched_filters');

  const expanded =
    (!matchedFilters || showDespiteFilter) &&
    (!status.get('hidden') || status.get('spoiler_text').length === 0);

  return (
    <div style={outerStyle}>
      <div
        ref={handleRef}
        className={classNames('detailed-status', {
          'status--has-quote': !!status.get('quote'),
        })}
      >
        {status.get('visibility') === 'direct' && (
          <div className='status__prepend'>
            <div className='status__prepend-icon-wrapper'>
              <Icon
                id='at'
                icon={AlternateEmailIcon}
                className='status__prepend-icon'
              />
            </div>
            <FormattedMessage
              id='status.direct_indicator'
              defaultMessage='Private mention'
            />
          </div>
        )}
        <Link
          to={`/@${status.getIn(['account', 'acct'])}`}
          data-hover-card-account={status.getIn(['account', 'id'])}
          className='detailed-status__display-name'
        >
          <div className='detailed-status__display-avatar'>
            <Avatar account={status.get('account')} size={46} />
          </div>

          {overrideDisplayName ?? (
            <DisplayName account={status.get('account')} localDomain={domain} />
          )}

          {withLogo && (
            <>
              <div className='spacer' />
              <IconLogo />
            </>
          )}
        </Link>

        {matchedFilters && (
          <FilterWarning
            title={matchedFilters.join(', ')}
            expanded={showDespiteFilter}
            onClick={handleFilterToggle}
          />
        )}

        {(!matchedFilters || showDespiteFilter) && (
          <ContentWarning
            status={status}
            expanded={expanded}
            onClick={handleExpandedToggle}
          />
        )}

        {expanded && (
          <>
            <StatusContent
              status={status}
              onTranslate={handleTranslate}
              {...(statusContentProps as any)}
            />

            {media}
            {hashtagBar}

            {status.get('quote') && (
              <QuotedStatus
                quote={status.get('quote')}
                parentQuotePostId={status.get('id')}
                contextType='thread'
              />
            )}
          </>
        )}

        <div className='detailed-status__meta'>
          <div className='detailed-status__meta__line'>
            <a
              className='detailed-status__datetime'
              href={`/@${status.getIn(['account', 'acct'])}/${status.get('id')}`}
              target='_blank'
              rel='noopener noreferrer'
            >
              <FormattedDateWrapper
                value={new Date(status.get('created_at') as string)}
                year='numeric'
                month='short'
                day='2-digit'
                hour='2-digit'
                minute='2-digit'
              />
            </a>

            {visibilityLink}
            {applicationLink}
          </div>

          {status.get('edited_at') && (
            <div className='detailed-status__meta__line'>
              <EditedTimestamp
                statusId={status.get('id')}
                timestamp={status.get('edited_at')}
              />
            </div>
          )}

          <div className='detailed-status__meta__line'>
            {reblogLink}
            {reblogLink && <>·</>}
            {quotesLink}
            {quotesLink && <>·</>}
            {favouriteLink}
          </div>
        </div>
      </div>
    </div>
  );
};
