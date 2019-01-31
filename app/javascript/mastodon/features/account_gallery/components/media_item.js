import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Permalink from '../../../components/permalink';
import { displayMedia } from '../../../initial_state';
import Icon from 'mastodon/components/icon';

export default class MediaItem extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
  };

  state = {
    visible: displayMedia !== 'hide_all' && !this.props.media.getIn(['status', 'sensitive']) || displayMedia === 'show_all',
  };

  handleClick = () => {
    if (!this.state.visible) {
      this.setState({ visible: true });
      return true;
    }

    return false;
  }

  render () {
    const { media } = this.props;
    const { visible } = this.state;
    const status = media.get('status');
    const focusX = media.getIn(['meta', 'focus', 'x']);
    const focusY = media.getIn(['meta', 'focus', 'y']);
    const x = ((focusX /  2) + .5) * 100;
    const y = ((focusY / -2) + .5) * 100;
    const style = {};

    let label, icon;

    if (media.get('type') === 'gifv') {
      label = <span className='media-gallery__gifv__label'>GIF</span>;
    }

    if (visible) {
      style.backgroundImage    = `url(${media.get('preview_url')})`;
      style.backgroundPosition = `${x}% ${y}%`;
    } else {
      icon = (
        <span className='account-gallery__item__icons'>
          <Icon id='eye-slash' />
        </span>
      );
    }

    return (
      <div className='account-gallery__item'>
        <Permalink to={`/statuses/${status.get('id')}`} href={status.get('url')} style={style} onInterceptClick={this.handleClick}>
          {icon}
          {label}
        </Permalink>
      </div>
    );
  }

}
