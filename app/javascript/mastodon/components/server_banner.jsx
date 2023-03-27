import PropTypes from 'prop-types';
import React from 'react';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import { fetchServer } from 'mastodon/actions/server';
import ShortNumber from 'mastodon/components/short_number';
import Skeleton from 'mastodon/components/skeleton';
import Account from 'mastodon/containers/account_container';
import { domain } from 'mastodon/initial_state';
import Image from 'mastodon/components/image';
import { Link } from 'react-router-dom';

const messages = defineMessages({
  aboutActiveUsers: { id: 'server_banner.about_active_users', defaultMessage: 'People using this server during the last 30 days (Monthly Active Users)' },
});

const mapStateToProps = state => ({
  server: state.getIn(['server', 'server']),
});

class ServerBanner extends React.PureComponent {

  static propTypes = {
    server: PropTypes.object,
    dispatch: PropTypes.func,
    intl: PropTypes.object,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchServer());
  }

  render () {
    const { server, intl } = this.props;
    const isLoading = server.get('isLoading');

    return (
      <div className='server-banner'>
        <div className='server-banner__introduction'>
          <FormattedMessage id='server_banner.introduction' defaultMessage='{domain} is part of the decentralized social network powered by {mastodon}.' values={{ domain: <strong>{domain}</strong>, mastodon: <a href='https://joinmastodon.org' target='_blank'>Mastodon</a> }} />
        </div>

        <Image blurhash={server.getIn(['thumbnail', 'blurhash'])} src={server.getIn(['thumbnail', 'url'])} className='server-banner__hero' />

        <div className='server-banner__description'>
          {isLoading ? (
            <>
              <Skeleton width='100%' />
              <br />
              <Skeleton width='100%' />
              <br />
              <Skeleton width='70%' />
            </>
          ) : server.get('description')}
        </div>

        <div className='server-banner__meta'>
          <div className='server-banner__meta__column'>
            <h4><FormattedMessage id='server_banner.administered_by' defaultMessage='Administered by:' /></h4>

            <Account id={server.getIn(['contact', 'account', 'id'])} size={36} />
          </div>

          <div className='server-banner__meta__column'>
            <h4><FormattedMessage id='server_banner.server_stats' defaultMessage='Server stats:' /></h4>

            {isLoading ? (
              <>
                <strong className='server-banner__number'><Skeleton width='10ch' /></strong>
                <br />
                <span className='server-banner__number-label'><Skeleton width='5ch' /></span>
              </>
            ) : (
              <>
                <strong className='server-banner__number'><ShortNumber value={server.getIn(['usage', 'users', 'active_month'])} /></strong>
                <br />
                <span className='server-banner__number-label' title={intl.formatMessage(messages.aboutActiveUsers)}><FormattedMessage id='server_banner.active_users' defaultMessage='active users' /></span>
              </>
            )}
          </div>
        </div>

        <hr className='spacer' />

        <Link className='button button--block button-secondary' to='/about'><FormattedMessage id='server_banner.learn_more' defaultMessage='Learn more' /></Link>
      </div>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(ServerBanner));
