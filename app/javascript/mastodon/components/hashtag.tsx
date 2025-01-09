import type { JSX } from 'react';
import { Component } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type Immutable from 'immutable';

import { Sparklines, SparklinesCurve } from 'react-sparklines';

import { ShortNumber } from 'mastodon/components/short_number';
import { Skeleton } from 'mastodon/components/skeleton';
import type { Hashtag as HashtagType } from 'mastodon/models/tags';

interface SilentErrorBoundaryProps {
  children: React.ReactNode;
}

class SilentErrorBoundary extends Component<SilentErrorBoundaryProps> {
  state = {
    error: false,
  };

  componentDidCatch() {
    this.setState({ error: true });
  }

  render() {
    if (this.state.error) {
      return null;
    }

    return this.props.children;
  }
}

/**
 * Used to render counter of how much people are talking about hashtag
 * @param displayNumber Counter number to display
 * @param pluralReady Whether the count is plural
 * @returns Formatted counter of how much people are talking about hashtag
 */
export const accountsCountRenderer = (
  displayNumber: JSX.Element,
  pluralReady: number,
) => (
  <FormattedMessage
    id='trends.counter_by_accounts'
    defaultMessage='{count, plural, one {{counter} person} other {{counter} people}} in the past {days, plural, one {day} other {# days}}'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
      days: 2,
    }}
  />
);

interface ImmutableHashtagProps {
  hashtag: Immutable.Map<string, unknown>;
}

export const ImmutableHashtag = ({ hashtag }: ImmutableHashtagProps) => (
  <Hashtag
    name={hashtag.get('name') as string}
    to={`/tags/${hashtag.get('name') as string}`}
    people={
      (hashtag.getIn(['history', 0, 'accounts']) as number) * 1 +
      (hashtag.getIn(['history', 1, 'accounts']) as number) * 1
    }
    history={(
      hashtag.get('history') as Immutable.Collection.Indexed<
        Immutable.Map<string, number>
      >
    )
      .reverse()
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      .map((day) => day.get('uses')!)
      .toArray()}
  />
);

export const CompatibilityHashtag: React.FC<{
  hashtag: HashtagType;
}> = ({ hashtag }) => (
  <Hashtag
    name={hashtag.name}
    to={`/tags/${hashtag.name}`}
    people={
      (hashtag.history[0].accounts as unknown as number) * 1 +
      ((hashtag.history[1]?.accounts ?? 0) as unknown as number) * 1
    }
    history={hashtag.history
      .map((day) => (day.uses as unknown as number) * 1)
      .reverse()}
  />
);

export interface HashtagProps {
  className?: string;
  description?: React.ReactNode;
  history?: number[];
  name: string;
  people: number;
  to: string;
  uses?: number;
  withGraph?: boolean;
}

export const Hashtag: React.FC<HashtagProps> = ({
  name,
  to,
  people,
  uses,
  history,
  className,
  description,
  withGraph = true,
}) => (
  <div className={classNames('trends__item', className)}>
    <div className='trends__item__name'>
      <Link to={to}>
        {name ? (
          <>
            #<span>{name}</span>
          </>
        ) : (
          <Skeleton width={50} />
        )}
      </Link>

      {description ? (
        <span>{description}</span>
      ) : typeof people !== 'undefined' ? (
        <ShortNumber value={people} renderer={accountsCountRenderer} />
      ) : (
        <Skeleton width={100} />
      )}
    </div>

    {typeof uses !== 'undefined' && (
      <div className='trends__item__current'>
        <ShortNumber value={uses} />
      </div>
    )}

    {withGraph && (
      <div className='trends__item__sparkline'>
        <SilentErrorBoundary>
          <Sparklines
            width={50}
            height={28}
            data={history ? history : Array.from(Array(7)).map(() => 0)}
          >
            <SparklinesCurve style={{ fill: 'none' }} />
          </Sparklines>
        </SilentErrorBoundary>
      </div>
    )}
  </div>
);
