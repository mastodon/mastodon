import PropTypes from 'prop-types';
import React from 'react';
import { connect } from 'react-redux';
import Image from 'mastodon/components/image';

const mapStateToProps = state => ({
  server: state.getIn(['server', 'server'])
});

export default @connect(mapStateToProps)
class Logo extends React.PureComponent {
  static propTypes = {
    server: PropTypes.object,
  }

  render() {
    const { server } = this.props;
    if (server.getIn(['logo', 'url']) === null) {
      return (<svg viewBox='0 0 376 102' className='logo' role='img'>
      <title>decodon</title>
      <use xlinkHref='#decodon-logo' />
    </svg>);
    } else {
      return (<Image blurhash={server.getIn(['logo', 'blurhash'])} src={server.getIn(['logo', 'url'])} className='logo' />)
    }
  }
};

// const Logo = () => (
//   <svg viewBox='0 0 376 102' className='logo' role='img'>
//     <title>decodon</title>
//     <use xlinkHref='#decodon-logo' />
//   </svg>
// );

