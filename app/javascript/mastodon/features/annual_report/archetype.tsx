import { defineMessages, useIntl } from 'react-intl';

import booster from '@/images/archetypes/booster.png';
import lurker from '@/images/archetypes/lurker.png';
import oracle from '@/images/archetypes/oracle.png';
import pollster from '@/images/archetypes/pollster.png';
import replier from '@/images/archetypes/replier.png';
import type { Archetype as ArchetypeData } from '@/mastodon/models/annual_report';

export const archetypeNames = defineMessages<ArchetypeData>({
  booster: {
    id: 'annual_report.summary.archetype.booster',
    defaultMessage: 'The cool-hunter',
  },
  replier: {
    id: 'annual_report.summary.archetype.replier',
    defaultMessage: 'The social butterfly',
  },
  pollster: {
    id: 'annual_report.summary.archetype.pollster',
    defaultMessage: 'The pollster',
  },
  lurker: {
    id: 'annual_report.summary.archetype.lurker',
    defaultMessage: 'The lurker',
  },
  oracle: {
    id: 'annual_report.summary.archetype.oracle',
    defaultMessage: 'The oracle',
  },
});

export const Archetype: React.FC<{
  data: ArchetypeData;
}> = ({ data }) => {
  const intl = useIntl();
  let illustration;

  switch (data) {
    case 'booster':
      illustration = booster;
      break;
    case 'replier':
      illustration = replier;
      break;
    case 'pollster':
      illustration = pollster;
      break;
    case 'lurker':
      illustration = lurker;
      break;
    case 'oracle':
      illustration = oracle;
      break;
  }

  return (
    <div className='annual-report__bento__box annual-report__summary__archetype'>
      <div className='annual-report__summary__archetype__label'>
        {intl.formatMessage(archetypeNames[data])}
      </div>
      <img src={illustration} alt='' />
    </div>
  );
};
