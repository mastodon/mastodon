import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedNumber } from 'react-intl';

import classNames from 'classnames';

import { Sparklines, SparklinesCurve } from 'react-sparklines';

import api from 'mastodon/api';
import { Skeleton } from 'mastodon/components/skeleton';

const percIncrease = (a, b) => {
  let percent;

  if (b !== 0) {
    if (a !== 0) {
      percent = (b - a) / a;
    } else {
      percent = 1;
    }
  } else if (b === 0 && a === 0) {
    percent = 0;
  } else {
    percent = - 1;
  }

  return percent;
};

export default class Counter extends PureComponent {

  static propTypes = {
    measure: PropTypes.string.isRequired,
    start_at: PropTypes.string.isRequired,
    end_at: PropTypes.string.isRequired,
    label: PropTypes.string.isRequired,
    href: PropTypes.string,
    params: PropTypes.object,
    target: PropTypes.string,
  };

  state = {
    loading: true,
    data: null,
  };

  componentDidMount () {
    const { measure, start_at, end_at, params } = this.props;

    api(false).post('/api/v1/admin/measures', { keys: [measure], start_at, end_at, [measure]: params }).then(res => {
      this.setState({
        loading: false,
        data: res.data,
      });
    }).catch(err => {
      console.error(err);
    });
  }

  render () {
    const { label, href, target } = this.props;
    const { loading, data } = this.state;

    let content;

    if (loading) {
      content = (
        <>
          <span className='sparkline__value__total'><Skeleton width={43} /></span>
          <span className='sparkline__value__change'><Skeleton width={43} /></span>
        </>
      );
    } else {
      const measure = data[0];
      const percentChange = measure.previous_total && percIncrease(measure.previous_total * 1, measure.total * 1);

      content = (
        <>
          <span className='sparkline__value__total'>{measure.human_value || <FormattedNumber value={measure.total} />}</span>
          {measure.previous_total && (<span className={classNames('sparkline__value__change', { positive: percentChange > 0, negative: percentChange < 0 })}>{percentChange > 0 && '+'}<FormattedNumber value={percentChange} style='percent' /></span>)}
        </>
      );
    }

    const inner = (
      <>
        <div className='sparkline__value'>
          {content}
        </div>

        <div className='sparkline__label'>
          {label}
        </div>

        <div className='sparkline__graph'>
          {!loading && (
            <Sparklines width={259} height={55} data={data[0].data.map(x => x.value * 1)}>
              <SparklinesCurve />
            </Sparklines>
          )}
        </div>
      </>
    );

    if (href) {
      return (
        <a href={href} className='sparkline' target={target}>
          {inner}
        </a>
      );
    } else {
      return (
        <div className='sparkline'>
          {inner}
        </div>
      );
    }
  }

}
