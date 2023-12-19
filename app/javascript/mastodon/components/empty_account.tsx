import React from 'react';

import classNames from 'classnames';

import { DisplayName } from 'mastodon/components/display_name';
import { Skeleton } from 'mastodon/components/skeleton';

interface Props {
  size?: number;
  minimal?: boolean;
}

export const EmptyAccount: React.FC<Props> = ({
  size = 46,
  minimal = false,
}) => {
  return (
    <div className={classNames('account', { 'account--minimal': minimal })}>
      <div className='account__wrapper'>
        <div className='account__display-name'>
          <div className='account__avatar-wrapper'>
            <Skeleton width={size} height={size} />
          </div>

          <div>
            <DisplayName />
            <Skeleton width='7ch' />
          </div>
        </div>
      </div>
    </div>
  );
};
