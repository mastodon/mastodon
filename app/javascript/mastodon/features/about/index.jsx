import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl } from 'react-intl';


import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import appScreenshot from 'mastodon/../images/app-screenshot.png';
import { fetchServer, fetchExtendedDescription, fetchDomainBlocks  } from 'mastodon/actions/server';

const mapStateToProps = state => ({
  server: state.getIn(['server', 'server']),
  extendedDescription: state.getIn(['server', 'extendedDescription']),
  domainBlocks: state.getIn(['server', 'domainBlocks']),
});

class About extends PureComponent {

  static propTypes = {
    server: ImmutablePropTypes.map,
    extendedDescription: ImmutablePropTypes.map,
    domainBlocks: ImmutablePropTypes.contains({
      isLoading: PropTypes.bool,
      isAvailable: PropTypes.bool,
      items: ImmutablePropTypes.list,
    }),
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchServer());
    dispatch(fetchExtendedDescription());
  }

  handleDomainBlocksOpen = () => {
    const { dispatch } = this.props;
    dispatch(fetchDomainBlocks());
  };

  render () {
    return (<div className='about-body'>
      <section className='intro'>
        <div>
          <h1 className='heading'>
            A social network that&apos;s personal and private,
            <br />
            built on decentralized technology of the future
          </h1>
          <div className='bullet-section'>
            <h3>
              <span className='bullet'>»</span>
              Ad-free, surveillance-free
              <br />
              <span className='bullet'>»</span>
              Private photo-sharing, just for your followers
              <br />
              <span className='bullet'>»</span>
              Real people&mdash;no influencers, bots, or companies
              <br />
              <span className='bullet'>»</span>
              Calm design, free from engagement algorithms
              <br />
              <span className='bullet'>»</span>
              Built on top of open source, decentralized protocols
              <br />
              <span className='bullet'>»</span>
              Follow your friends on other federated social networks, like Pixelfed or Mastodon
            </h3>
          </div>
        </div>
        <div>
          <img src={appScreenshot} alt='app screenshot' />
        </div>
      </section>
    </div>);
  }
}

export default connect(mapStateToProps)(injectIntl(About));
