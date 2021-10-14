// @ts-check
import React from 'react';
import { Sparklines, SparklinesCurve } from 'react-sparklines';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Permalink from './permalink';
import ShortNumber from 'mastodon/components/short_number';
import Skeleton from 'mastodon/components/skeleton';
import classNames from 'classnames';

class SilentErrorBoundary extends React.Component {

  static propTypes = {
    children: PropTypes.node,
  };

  state = {
    error: false,
  };

  componentDidCatch () {
    this.setState({ error: true });
  }

  render () {
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
const accountsCountRenderer = (displayNumber, pluralReady) => (
  <FormattedMessage
    id='trends.counter_by_accounts'
    defaultMessage='{count, plural, one {{counter} person} other {{counter} people}} talking'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

export const ImmutableHashtag = ({ hashtag }) => (
  <Hashtag
    name={hashtag.get('name')}
    href={hashtag.get('url')}
    to={`/tags/${hashtag.get('name')}`}
    people={hashtag.getIn(['history', 0, 'accounts']) * 1 + hashtag.getIn(['history', 1, 'accounts']) * 1}
    uses={hashtag.getIn(['history', 0, 'uses']) * 1 + hashtag.getIn(['history', 1, 'uses']) * 1}
    history={hashtag.get('history').reverse().map((day) => day.get('uses')).toArray()}
  />
);

ImmutableHashtag.propTypes = {
  hashtag: ImmutablePropTypes.map.isRequired,
};

const Hashtag = ({ name, href, to, people, uses, history, className }) => (
  <div className={classNames('trends__item', className)}>
    <div className='trends__item__name'>
      <Permalink href={href} to={to}>
        {name ? <React.Fragment>#<span>{name}</span></React.Fragment> : <Skeleton width={50} />}
      </Permalink>

      {typeof people !== 'undefined' ? <ShortNumber value={people} renderer={accountsCountRenderer} /> : <Skeleton width={100} />}
    </div>

    <div className='trends__item__current'>
      {typeof uses !== 'undefined' ? <ShortNumber value={uses} /> : <Skeleton width={42} height={36} />}
    </div>

    <div className='trends__item__sparkline'>
      <SilentErrorBoundary>
        <Sparklines width={50} height={28} data={history ? history : Array.from(Array(7)).map(() => 0)}>
          <SparklinesCurve style={{ fill: 'none' }} />
        </Sparklines>
      </SilentErrorBoundary>
    </div>
  </div>
);

Hashtag.propTypes = {
  name: PropTypes.string,
  href: PropTypes.string,
  to: PropTypes.string,
  people: PropTypes.number,
  uses: PropTypes.number,
  history: PropTypes.arrayOf(PropTypes.number),
  className: PropTypes.string,
};

export default Hashtag;
