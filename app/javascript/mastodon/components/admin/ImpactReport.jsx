import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedNumber, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import api from 'mastodon/api';
import { Skeleton } from 'mastodon/components/skeleton';

export default class ImpactReport extends PureComponent {

  static propTypes = {
    domain: PropTypes.string.isRequired,
  };

  state = {
    loading: true,
    data: null,
  };

  componentDidMount () {
    const { domain } = this.props;

    const params = {
      domain: domain,
      include_subdomains: true,
    };

    api(false).post('/api/v1/admin/measures', {
      keys: ['instance_accounts', 'instance_follows', 'instance_followers'],
      start_at: null,
      end_at: null,
      instance_accounts: params,
      instance_follows: params,
      instance_followers: params,
    }).then(res => {
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

    return (
      <div className='dimension'>
        <h4><FormattedMessage id='admin.impact_report.title' defaultMessage='Impact summary' /></h4>

        <table>
          <tbody>
            <tr className='dimension__item'>
              <td className='dimension__item__key'>
                <FormattedMessage id='admin.impact_report.instance_accounts' defaultMessage='Accounts profiles this would delete' />
              </td>

              <td className='dimension__item__value'>
                {loading ? <Skeleton width={60} /> : <FormattedNumber value={data[0].total} />}
              </td>
            </tr>

            <tr className={classNames('dimension__item', { negative: !loading && data[1].total > 0 })}>
              <td className='dimension__item__key'>
                <FormattedMessage id='admin.impact_report.instance_follows' defaultMessage='Followers their users would lose' />
              </td>

              <td className='dimension__item__value'>
                {loading ? <Skeleton width={60} /> : <FormattedNumber value={data[1].total} />}
              </td>
            </tr>

            <tr className={classNames('dimension__item', { negative: !loading && data[2].total > 0 })}>
              <td className='dimension__item__key'>
                <FormattedMessage id='admin.impact_report.instance_followers' defaultMessage='Followers our users would lose' />
              </td>

              <td className='dimension__item__value'>
                {loading ? <Skeleton width={60} /> : <FormattedNumber value={data[2].total} />}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    );
  }

}
