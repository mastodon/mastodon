import React from 'react';

import type { List } from 'immutable';

import type { Account } from '../../types/resources';
import { autoPlayGif } from '../initial_state';

import { Skeleton } from './skeleton';

interface Props {
  account?: Account;
  others?: List<Account>;
  localDomain?: string;
}

export class DisplayName extends React.PureComponent<Props> {
  handleMouseEnter: React.ReactEventHandler<HTMLSpanElement> = ({
    currentTarget,
  }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis =
      currentTarget.querySelectorAll<HTMLImageElement>('img.custom-emoji');

    emojis.forEach((emoji) => {
      const originalSrc = emoji.getAttribute('data-original');
      if (originalSrc != null) emoji.src = originalSrc;
    });
  };

  handleMouseLeave: React.ReactEventHandler<HTMLSpanElement> = ({
    currentTarget,
  }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis =
      currentTarget.querySelectorAll<HTMLImageElement>('img.custom-emoji');

    emojis.forEach((emoji) => {
      const staticSrc = emoji.getAttribute('data-static');
      if (staticSrc != null) emoji.src = staticSrc;
    });
  };

  render() {
    const { others, localDomain } = this.props;

    let displayName: React.ReactNode,
      suffix: React.ReactNode,
      account: Account | undefined;

    if (others && others.size > 0) {
      account = others.first();
    } else if (this.props.account) {
      account = this.props.account;
    }

    if (others && others.size > 1) {
      displayName = others
        .take(2)
        .map((a) => (
          <bdi key={a.get('id')}>
            <strong
              className='display-name__html'
              dangerouslySetInnerHTML={{ __html: a.get('display_name_html') }}
            />
          </bdi>
        ))
        .reduce((prev, cur) => [prev, ', ', cur]);

      if (others.size - 2 > 0) {
        suffix = `+${others.size - 2}`;
      }
    } else if (account) {
      let acct = account.get('acct');

      if (!acct.includes('@') && localDomain) {
        acct = `${acct}@${localDomain}`;
      }

      let role = null;
      if (account.getIn(['roles', 0])) {
        role = (<div key='role' className={`information-badge mcd_rolebadge_parent user-role-${account.getIn(['roles', 0, 'id'])}`}><svg viewBox='0 0 24 24'><g><path d='M 14.626 6.269 L 14.626 15.884 L 9.193 15.884 L 9.193 6.269 L 14.626 6.269 Z' style={{fill: '#FFF'}} transform='matrix(0.707107, 0.707107, -0.707107, 0.707107, 11.32048, -5.177056)' /><path class='mcd_rolebadge' d='M22.25 12c0-1.43-.88-2.67-2.19-3.34.46-1.39.2-2.9-.81-3.91s-2.52-1.27-3.91-.81c-.66-1.31-1.91-2.19-3.34-2.19s-2.67.88-3.33 2.19c-1.4-.46-2.91-.2-3.92.81s-1.26 2.52-.8 3.91c-1.31.67-2.2 1.91-2.2 3.34s.89 2.67 2.2 3.34c-.46 1.39-.21 2.9.8 3.91s2.52 1.26 3.91.81c.67 1.31 1.91 2.19 3.34 2.19s2.68-.88 3.34-2.19c1.39.45 2.9.2 3.91-.81s1.27-2.52.81-3.91c1.31-.67 2.19-1.91 2.19-3.34zm-11.71 4.2L6.8 12.46l1.41-1.42 2.26 2.26 4.8-5.23 1.47 1.36-6.2 6.77z' /></g></svg></div>);
      }

      displayName = (
        <bdi>
          <strong
            className='display-name__html'
            dangerouslySetInnerHTML={{
              __html: account.get('display_name_html'),
            }}
          />
        </bdi>
      );
      suffix = <span className='display-name__account'>@{acct}{role ? ` · ` : ""}{role}</span>;
    } else {
      displayName = (
        <bdi>
          <strong className='display-name__html'>
            <Skeleton width='10ch' />
          </strong>
        </bdi>
      );
      suffix = (
        <span className='display-name__account'>
          <Skeleton width='7ch' />
        </span>
      );
    }

    return (
      <span
        className='display-name'
        onMouseEnter={this.handleMouseEnter}
        onMouseLeave={this.handleMouseLeave}
      >
        {displayName} {suffix}
      </span>
    );
  }
}
