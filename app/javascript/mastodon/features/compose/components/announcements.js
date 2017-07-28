import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Immutable from 'immutable';
import { Link } from 'react-router-dom';
import axios from 'axios';
import classnames from 'classnames';

class Announcement extends React.PureComponent {

  static propTypes = {
    item: ImmutablePropTypes.map,
  }

  render() {
    const { item } = this.props;

    const contents = [];
    contents.push(<div key='body' className='announcements__body'>{item.get('body')}</div>);
    if (item.get('icon')) {
      contents.push(
        <div key='icon' className='announcements__icon'>
          <img src={item.get('icon')} alt='' />
        </div>
      );
    }

    const href = item.get('href');

    const classname = classnames({
      'announcements__item': true,
      'announcements__item--clickable': !!href,
    });

    if (!href) {
      return (<div className={classname}>{contents}</div>);
    } else if (href.startsWith('/web/')) {
      return (<Link to={item.get('href').slice(4)} className={classname}>{contents}</Link>);
    } else {
      return (<a href={item.get('href')} target='_blank' className={classname}>{contents}</a>);
    }
  }

}

export default class Announcements extends React.PureComponent {

  state = {
    items: Announcements.cache || Immutable.Map(),
  }

  static isCacheControlled = false
  static lastDate = null
  static cache = null

  constructor () {
    super();
    this.refresh();
  }

  componentWillUnmount() {
    this.cancelPolling();
  }

  setPolling = () => {
    this.timer = setTimeout(this.refresh, 2 * 60 * 1000);
  }

  cancelPolling = () => {
    if (this.timer !== null) {
      clearTimeout(this.timer);
      this.timer = null;
    }
  }

  deleteServiceWorkerCache = () => {
    // files in /system/ will be cached by SW
    if (self.caches) {
      return caches.open('mastodon-system')
        .then(cache => cache.delete(window.origin + '/system/announcements.json'))
        .catch(() => {});
    } else {
      return Promise.resolve();
    }
  }

  refresh = () => {
    this.timer = null;

    axios.get('/announcements.json', {
      headers: {
        'If-Modified-Since': !Announcements.isCacheControlled && Announcements.lastDate || '',
      },
    })
      .then(resp => {
        Announcements.isCacheControlled = !!resp.headers['cache-control'];
        Announcements.lastDate = resp.headers['last-modified'];
        return resp;
      })
      .then(resp => this.setState({ items: Announcements.cache = Immutable.fromJS(resp.data) || {} }))
      .catch(err => err.response.status !== 304 && console.warn(err))
      .then(this.deleteServiceWorkerCache)
      .then(this.setPolling)
      .catch(err => err && console.warn(err));
  }

  render() {
    const { items } = this.state;

    return (
      <ul className='announcements'>
        {items.entrySeq().map(([key, item]) =>
          (<li key={key}>
            <Announcement item={item} />
          </li>)
        )}
      </ul>
    );
  }

}
