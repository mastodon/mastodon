// @ts-check
import React from 'react';
import { Sparklines, SparklinesCurve } from 'react-sparklines';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { Link } from 'react-router-dom';
// @ts-expect-error
import ShortNumber from 'mastodon/components/short_number';
// @ts-expect-error
import Skeleton from 'mastodon/components/skeleton';
import classNames from 'classnames';

class SilentErrorBoundary extends React.Component {

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
 *
 * @type {(displayNumber: JSX.Element, pluralReady: number) => JSX.Element}
 */
export const accountsCountRenderer = (displayNumber, pluralReady) => (
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
        {name ? <React.Fragment>#<span>{name}</span></React.Fragment> : <Skeleton width={50} />}
      </Link>

      {description ? (
        <span>{description}</span>
      ) : (
        typeof people !== 'undefined' ? <ShortNumber value={people} renderer={accountsCountRenderer} /> : <Skeleton width={100} />
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
