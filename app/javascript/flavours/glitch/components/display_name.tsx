import React from 'react';

import classNames from 'classnames';

import type { List } from 'immutable';

import type { Account } from 'flavours/glitch/types/resources';

import { autoPlayGif } from '../initial_state';

import { Skeleton } from './skeleton';

interface Props {
  account: Account;
  others: List<Account>;
  localDomain: string;
  inline?: boolean;
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
    const { others, localDomain, inline } = this.props;

    let displayName: React.ReactNode, suffix: React.ReactNode, account: Account;

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
    } else if ((others && others.size > 0) || this.props.account) {
      if (others && others.size > 0) {
        account = others.first();
      } else {
        account = this.props.account;
      }

      let acct = account.get('acct');

      if (acct.indexOf('@') === -1 && localDomain) {
        acct = `${acct}@${localDomain}`;
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
      suffix = <span className='display-name__account'>@{acct}</span>;
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
        className={classNames('display-name', { inline })}
        onMouseEnter={this.handleMouseEnter}
        onMouseLeave={this.handleMouseLeave}
      >
        {displayName}
        {inline ? ' ' : null}
        {suffix}
      </span>
    );
  }
}
