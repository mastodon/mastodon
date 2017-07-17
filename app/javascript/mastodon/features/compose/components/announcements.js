import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Immutable from 'immutable';
import { Link } from 'react-router-dom';
import axios from 'axios';

class Announcement extends React.PureComponent {

  static propTypes = {
    item: ImmutablePropTypes.map,
  }

  render() {
    const { item } = this.props;

    const contents = [];
    contents.push(<div key='body' className='announcements__body'>{item.get('body')}</div>);
    if (item.get('icon')) {
      const iconStyle = {
        height: '40px',
        width: '40px',
        flex: '0 0 auto',
        textAlign: 'center',
      };
      contents.push(
        <div key='icon' className='announcements__icon' style={iconStyle}>
          <img src={item.get('icon')} alt='' style={{ maxWidth: '100%', maxHeight: '100%' }} />
        </div>
      );
    }

    const href = item.get('href');

    const style = {
      display: 'flex',
      padding: '10px',
      margin: '10px',
      backgroundColor: 'white',
      color: '#313543',
      boxShadow: '0 0 15px rgba(0,0,0,.2)',
      borderRadius: '4px',
      cursor: href ? 'pointer' : null,
      textDecoration: 'none',
    };

    if (!href) {
      return (<div className='announcements__item' style={style}>{contents}</div>);
    } else if (href.startsWith('/web/')) {
      return (<Link to={item.get('href').slice(4)} className='announcements__item' style={style}>{contents}</Link>);
    } else {
      return (<a href={item.get('href')} target='_blank' className='announcements__item' style={style}>{contents}</a>);
    }
  }

}

export default class Announcements extends React.PureComponent {

  state = {
    items: Immutable.Map(),
  }

  constructor () {
    super();
    this.refresh();
  }

  setPolling = () => {
    this.timer = setTimeout(this.refresh, 60 * 1000);
  }

  cancelPolling = () => {
    if (this.timer !== null) {
      clearTimeout(this.timer);
      this.timer = null;
    }
  }

  refresh = () => {
    this.timer = null;
    axios.get('/system/announcements.json')
    .then(resp => this.setState({ items: Immutable.fromJS(resp.data) }), () => {})
    .then(this.setPolling);
  }

  render() {
    const { items } = this.state;

    return (
      <ul className='announcements'>
        {items.entrySeq().map(([key, item]) =>
          <li key={key}>
            <Announcement item={item} />
          </li>
        )}
      </ul>
    );
  }

}