import React from 'react';
import { connect } from 'react-redux';
import Image from 'mastodon/components/image';

const Logo = connect(state => ({
  server: state.getIn(['server', 'server']),
}))(({ server }) => {
  if (server.getIn(['logo', 'url']) === null) {
    return (<svg viewBox='0 0 376 102' className='logo' role='img'>
    <title>decodon</title>
    <use xlinkHref='#decodon-logo' />
  </svg>);
  } else {
    return (<Image blurhash={server.getIn(['logo', 'blurhash'])} src={server.getIn(['logo', 'url'])} className='logo' />)
  }
});

// const Logo = () => (
//   <svg viewBox='0 0 376 102' className='logo' role='img'>
//     <title>decodon</title>
//     <use xlinkHref='#decodon-logo' />
//   </svg>
// );

export default Logo;
