import React from 'react';
import PropTypes from 'prop-types';
import api from 'mastodon/api';
import { FormattedMessage, FormattedNumber, FormattedDate } from 'react-intl';
import classNames from 'classnames';
import { roundTo10 } from 'mastodon/utils/numbers';

const dateForCohort = cohort => {
  switch(cohort.frequency) {
  case 'day':
    return <FormattedDate value={cohort.period} month='long' day='2-digit' />;
  default:
    return <FormattedDate value={cohort.period} month='long' year='numeric' />;
  }
};

export default class Retention extends React.PureComponent {

  static propTypes = {
    start_at: PropTypes.string,
    end_at: PropTypes.string,
    frequency: PropTypes.string,
  };

  state = {
    loading: true,
    data: null,
  };

  componentDidMount () {
    const { start_at, end_at, frequency } = this.props;

    api().post('/api/v1/admin/retention', { start_at, end_at, frequency }).then(res => {
      this.setState({
        loading: false,
        data: res.data,
      });
    }).catch(err => {
      console.error(err);
    });
  }

  render () {
    const { loading, data } = this.state;
    const { frequency } = this.props;

    let content;

    if (loading) {
      content = <FormattedMessage id='loading_indicator.label' defaultMessage='Loading...' />;
    } else {
      content = (
        <table className='retention__table'>
          <thead>
            <tr>
              <th>
                <div className='retention__table__date retention__table__label'>
                  <FormattedMessage id='admin.dashboard.retention.cohort' defaultMessage='Sign-up month' />
                </div>
              </th>

              <th>
                <div className='retention__table__number retention__table__label'>
                  <FormattedMessage id='admin.dashboard.retention.cohort_size' defaultMessage='New users' />
                </div>
              </th>

              {data[0].data.slice(1).map((retention, i) => (
                <th key={retention.date}>
                  <div className='retention__table__number retention__table__label'>
                    {i + 1}
                  </div>
                </th>
              ))}
            </tr>

            <tr>
              <td>
                <div className='retention__table__date retention__table__average'>
                  <FormattedMessage id='admin.dashboard.retention.average' defaultMessage='Average' />
                </div>
              </td>

              <td>
                <div className='retention__table__size'>
                  <FormattedNumber value={data.reduce((sum, cohort, i) => sum + ((cohort.data[0].value * 1) - sum) / (i + 1), 0)} maximumFractionDigits={0} />
                </div>
              </td>

              {data[0].data.slice(1).map((retention, i) => {
                const average = data.reduce((sum, cohort, k) => cohort.data[i + 1] ? sum + (cohort.data[i + 1].rate - sum)/(k + 1) : sum, 0);

                return (
                  <td key={retention.date}>
                    <div className={classNames('retention__table__box', 'retention__table__average', `retention__table__box--${roundTo10(average * 100)}`)}>
                      <FormattedNumber value={average} style='percent' />
                    </div>
                  </td>
                );
              })}
            </tr>
          </thead>

          <tbody>
            {data.slice(0, -1).map(cohort => (
              <tr key={cohort.period}>
                <td>
                  <div className='retention__table__date'>
                    {dateForCohort(cohort)}
                  </div>
                </td>

                <td>
                  <div className='retention__table__size'>
                    <FormattedNumber value={cohort.data[0].value} />
                  </div>
                </td>

                {cohort.data.slice(1).map(retention => (
                  <td key={retention.date}>
                    <div className={classNames('retention__table__box', `retention__table__box--${roundTo10(retention.rate * 100)}`)}>
                      <FormattedNumber value={retention.rate} style='percent' />
                    </div>
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      );
    }

    let title = null;
    switch(frequency) {
    case 'day':
      title = <FormattedMessage id='admin.dashboard.daily_retention' defaultMessage='User retention rate by day after sign-up' />;
      break;
    default:
      title = <FormattedMessage id='admin.dashboard.monthly_retention' defaultMessage='User retention rate by month after sign-up' />;
    }

    return (
      <div className='retention'>
        <h4>{title}</h4>

        {content}
      </div>
    );
  }

}
