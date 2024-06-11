import PropTypes from 'prop-types';
import React from 'react';

import { connect } from 'react-redux';

import Image from 'mastodon/components/image';

import { WordmarkLogo } from './logo';

const mapStateToProps = state => ({
  server: state.getIn(['server', 'server'])
});

export default @connect(mapStateToProps)
class CustomLogo extends React.PureComponent {
  static propTypes = {
    server: PropTypes.object,
  }

  render() {
    const { server } = this.props;
    if (!server.getIn(['logo', 'url'])) {
      return (<WordmarkLogo />)
    } else {
      return (<Image blurhash={server.getIn(['logo', 'blurhash'])} src={server.getIn(['logo', 'url'])} className='logo' />)
    }
  }
};
