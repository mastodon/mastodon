import { useCallback, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import booster from '@/images/archetypes/booster.png';
import lurker from '@/images/archetypes/lurker.png';
import oracle from '@/images/archetypes/oracle.png';
import pollster from '@/images/archetypes/pollster.png';
import replier from '@/images/archetypes/replier.png';
import space_elements from '@/images/archetypes/space_elements.png';
import { Avatar } from '@/mastodon/components/avatar';
import { Button } from '@/mastodon/components/button';
import { DisplayName } from '@/mastodon/components/display_name';
import { me } from '@/mastodon/initial_state';
import type { Account } from '@/mastodon/models/account';
import type {
  AnnualReport,
  Archetype as ArchetypeData,
} from '@/mastodon/models/annual_report';
import { wrapstodonSettings } from '@/mastodon/settings';

import styles from './index.module.scss';
import { ShareButton } from './share_button';

export const archetypeNames = defineMessages<ArchetypeData>({
  booster: {
    id: 'annual_report.summary.archetype.booster.name',
    defaultMessage: 'The Archer',
  },
  replier: {
    id: 'annual_report.summary.archetype.replier.name',
    defaultMessage: 'The Butterfly',
  },
  pollster: {
    id: 'annual_report.summary.archetype.pollster.name',
    defaultMessage: 'The Wonderer',
  },
  lurker: {
    id: 'annual_report.summary.archetype.lurker.name',
    defaultMessage: 'The Stoic',
  },
  oracle: {
    id: 'annual_report.summary.archetype.oracle.name',
    defaultMessage: 'The Oracle',
  },
});

export const archetypeSelfDescriptions = defineMessages<ArchetypeData>({
  booster: {
    id: 'annual_report.summary.archetype.booster.desc_self',
    defaultMessage:
      'You stayed on the hunt for posts to boost, amplifying other creators with perfect aim.',
  },
  replier: {
    id: 'annual_report.summary.archetype.replier.desc_self',
    defaultMessage:
      'You frequently replied to other people’s posts, pollinating Mastodon with new discussions.',
  },
  pollster: {
    id: 'annual_report.summary.archetype.pollster.desc_self',
    defaultMessage:
      'You created more polls than other post types, cultivating curiosity on Mastodon.',
  },
  lurker: {
    id: 'annual_report.summary.archetype.lurker.desc_self',
    defaultMessage:
      'We know you were out there, somewhere, enjoying Mastodon in your own quiet way.',
  },
  oracle: {
    id: 'annual_report.summary.archetype.oracle.desc_self',
    defaultMessage:
      'You created new posts more than replies, keeping Mastodon fresh and future-facing.',
  },
});

export const archetypePublicDescriptions = defineMessages<ArchetypeData>({
  booster: {
    id: 'annual_report.summary.archetype.booster.desc_public',
    defaultMessage:
      '{name} stayed on the hunt for posts to boost, amplifying other creators with perfect aim.',
  },
  replier: {
    id: 'annual_report.summary.archetype.replier.desc_public',
    defaultMessage:
      '{name} frequently replied to other people’s posts, pollinating Mastodon with new discussions.',
  },
  pollster: {
    id: 'annual_report.summary.archetype.pollster.desc_public',
    defaultMessage:
      '{name} created more polls than other post types, cultivating curiosity on Mastodon.',
  },
  lurker: {
    id: 'annual_report.summary.archetype.lurker.desc_public',
    defaultMessage:
      'We know {name} was out there, somewhere, enjoying Mastodon in their own quiet way.',
  },
  oracle: {
    id: 'annual_report.summary.archetype.oracle.desc_public',
    defaultMessage:
      '{name} created new posts more than replies, keeping Mastodon fresh and future-facing.',
  },
});

const illustrations = {
  booster,
  replier,
  pollster,
  lurker,
  oracle,
} as const;

export const Archetype: React.FC<{
  report: AnnualReport;
  account?: Account;
  context: 'modal' | 'standalone';
}> = ({ report, account, context }) => {
  const intl = useIntl();
  const wrapperRef = useRef<HTMLDivElement>(null);
  const isSelfView = context === 'modal';

  const [isRevealed, setIsRevealed] = useState(
    () =>
      !isSelfView ||
      (me ? (wrapstodonSettings.get(me)?.archetypeRevealed ?? false) : true),
  );
  const reveal = useCallback(() => {
    setIsRevealed(true);
    if (me) {
      wrapstodonSettings.set(me, { archetypeRevealed: true });
    }
    wrapperRef.current?.focus();
  }, []);

  const archetype = report.data.archetype;
  const descriptions = isSelfView
    ? archetypeSelfDescriptions
    : archetypePublicDescriptions;

  return (
    <div
      className={classNames(styles.box, styles.archetype)}
      // eslint-disable-next-line jsx-a11y/no-noninteractive-tabindex
      tabIndex={0}
      ref={wrapperRef}
    >
      <div className={styles.archetypeArtboard}>
        {account && (
          <Avatar
            account={account}
            size={50}
            className={styles.archetypeAvatar}
          />
        )}
        <div className={styles.archetypeIllustrationWrapper}>
          <img
            src={illustrations[archetype]}
            alt=''
            className={classNames(
              styles.archetypeIllustration,
              isRevealed ? '' : styles.blurredImage,
            )}
          />
        </div>
        <img
          src={space_elements}
          alt=''
          className={styles.archetypePlanetRing}
        />
      </div>
      <div className={classNames(styles.content, styles.comfortable)}>
        <h2 className={styles.title}>
          {isSelfView ? (
            <FormattedMessage
              id='annual_report.summary.archetype.title_self'
              defaultMessage='Your archetype'
            />
          ) : (
            <FormattedMessage
              id='annual_report.summary.archetype.title_public'
              defaultMessage="{name}'s archetype"
              values={{
                name: <DisplayName variant='simple' account={account} />,
              }}
            />
          )}
        </h2>
        <p className={styles.statLarge}>
          {isRevealed ? (
            intl.formatMessage(archetypeNames[archetype])
          ) : (
            <FormattedMessage
              id='annual_report.summary.archetype.die_drei_fragezeichen'
              defaultMessage='???'
            />
          )}
        </p>
        <p>
          {isRevealed ? (
            intl.formatMessage(descriptions[archetype], {
              name: <DisplayName variant='simple' account={account} />,
            })
          ) : (
            <FormattedMessage
              id='annual_report.summary.archetype.reveal_description'
              defaultMessage='Thanks for being part of Mastodon! Time to find out which archetype you embodied in {year}.'
              values={{ year: report.year }}
            />
          )}
        </p>
      </div>
      {!isRevealed && (
        <Button onClick={reveal}>
          <FormattedMessage
            id='annual_report.summary.archetype.reveal'
            defaultMessage='Reveal my archetype'
          />
        </Button>
      )}
      {isRevealed && isSelfView && <ShareButton report={report} />}
    </div>
  );
};
