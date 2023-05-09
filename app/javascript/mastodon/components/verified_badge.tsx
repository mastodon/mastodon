import React from 'react';
import { Icon } from './icon';

type Props = {
  link: string;
};
export const VerifiedBadge: React.FC<Props> = ({ link }) => (
  <span className='verified-badge'>
    <Icon id='check' className='verified-badge__mark' />
    <span dangerouslySetInnerHTML={{ __html: link }} />
  </span>
);
