// @ts-check
import PropTypes from 'prop-types';
import { Component, memo } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';

import { Sparklines, SparklinesCurve } from 'react-sparklines';

import { GenericCounter , ShortNumberRenderer } from 'mastodon/components/counters';
import { Skeleton } from 'mastodon/components/skeleton';
import { pluralReady, toShortNumber } from 'mastodon/utils/numbers';


class SilentErrorBoundary extends Component {

  static propTypes = {
    children: PropTypes.node,
  };

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
 * @type {(props: {value: number, children?: never}) => JSX.Element}
 */
const _AccountsCounter = ({ value }) => {
  const shortNumber = toShortNumber(value);
  const [, division] = shortNumber;
  const displayNumber = <ShortNumberRenderer shortNumber={shortNumber} />;

  return (<FormattedMessage
    id='trends.counter_by_accounts'
    defaultMessage='{count, plural, one {{counter} person} other {{counter} people}} in the past {days, plural, one {day} other {# days}}'
    values={{
      count: pluralReady(value, division),
      counter: <strong>{displayNumber}</strong>,
      days: 2,
    }}
  />)
};
export const AccountsCounter = memo(_AccountsCounter)

// @ts-expect-error
export const ImmutableHashtag = ({ hashtag }) => (
  <Hashtag
    name={hashtag.get('name')}
    to={`/tags/${hashtag.get('name')}`}
    people={hashtag.getIn(['history', 0, 'accounts']) * 1 + hashtag.getIn(['history', 1, 'accounts']) * 1}
    // @ts-expect-error
    history={hashtag.get('history').reverse().map((day) => day.get('uses')).toArray()}
  />
);

ImmutableHashtag.propTypes = {
  hashtag: ImmutablePropTypes.map.isRequired,
};

// @ts-expect-error
const Hashtag = ({ name, to, people, uses, history, className, description, withGraph }) => (
  <div className={classNames('trends__item', className)}>
    <div className='trends__item__name'>
      <Link to={to}>
        {name ? <>#<span>{name}</span></> : <Skeleton width={50} />}
      </Link>

      {description ? (
        <span>{description}</span>
      ) : (
        typeof people !== 'undefined' ? <AccountsCounter value={people} /> : <Skeleton width={100} />
      )}
    </div>

    {typeof uses !== 'undefined' && (
      <div className='trends__item__current'>
        <GenericCounter value={uses} />
      </div>
    )}

    {withGraph && (
      <div className='trends__item__sparkline'>
        <SilentErrorBoundary>
          <Sparklines width={50} height={28} data={history ? history : Array.from(Array(7)).map(() => 0)}>
            <SparklinesCurve style={{ fill: 'none' }} />
          </Sparklines>
        </SilentErrorBoundary>
      </div>
    )}
  </div>
);

Hashtag.propTypes = {
  name: PropTypes.string,
  to: PropTypes.string,
  people: PropTypes.number,
  description: PropTypes.node,
  uses: PropTypes.number,
  history: PropTypes.arrayOf(PropTypes.number),
  className: PropTypes.string,
  withGraph: PropTypes.bool,
};

Hashtag.defaultProps = {
  withGraph: true,
};

export default Hashtag;
