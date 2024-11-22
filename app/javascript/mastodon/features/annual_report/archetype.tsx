import { FormattedMessage } from 'react-intl';

import booster from '@/images/archetypes/booster.png';
import lurker from '@/images/archetypes/lurker.png';
import oracle from '@/images/archetypes/oracle.png';
import pollster from '@/images/archetypes/pollster.png';
import replier from '@/images/archetypes/replier.png';
import type { Archetype as ArchetypeData } from 'mastodon/models/annual_report';

export const Archetype: React.FC<{
  data: ArchetypeData;
}> = ({ data }) => {
  let illustration, label;

  switch (data) {
    case 'booster':
      illustration = booster;
      label = (
        <FormattedMessage
          id='annual_report.summary.archetype.booster'
          defaultMessage='The cool-hunter'
        />
      );
      break;
    case 'replier':
      illustration = replier;
      label = (
        <FormattedMessage
          id='annual_report.summary.archetype.replier'
          defaultMessage='The social butterfly'
        />
      );
      break;
    case 'pollster':
      illustration = pollster;
      label = (
        <FormattedMessage
          id='annual_report.summary.archetype.pollster'
          defaultMessage='The pollster'
        />
      );
      break;
    case 'lurker':
      illustration = lurker;
      label = (
        <FormattedMessage
          id='annual_report.summary.archetype.lurker'
          defaultMessage='The lurker'
        />
      );
      break;
    case 'oracle':
      illustration = oracle;
      label = (
        <FormattedMessage
          id='annual_report.summary.archetype.oracle'
          defaultMessage='The oracle'
        />
      );
      break;
  }

  return (
    <div className='annual-report__bento__box annual-report__summary__archetype'>
      <div className='annual-report__summary__archetype__label'>{label}</div>
      <img src={illustration} alt='' />
    </div>
  );
};
