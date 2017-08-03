import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Link from 'react-router-dom/Link';
import PropTypes from 'prop-types';

class FavouriteTags extends React.PureComponent {

  static propTypes = {
    tags: ImmutablePropTypes.list.isRequired,
    locktag: PropTypes.string.isRequired,
    refreshFavouriteTags: PropTypes.func.isRequired,
    onLockTag: PropTypes.func.isRequired,
  };

  componentDidMount () {
    this.props.refreshFavouriteTags();
  }

  handleLockTag (tag) {
    const tagName = `#${tag}`;
    return ((e) => {
      e.preventDefault();
      if (this.props.locktag === tagName) {
        this.props.onLockTag('');
      } else {
        this.props.onLockTag(tagName);
      }
    }).bind(this);
  }

  render () {
    const tags = this.props.tags.map(tag => (
      <li key={tag.get('name')}>
        <Link
           to={`/timelines/tag/${tag.get('name')}`}
           className='favourite-tags__name'
           key={tag.get('name')}
        >
          <i className='fa fa-hashtag' />
          {tag.get('name')}
        </Link>
        <div className='favourite-tags__lock'>
          <a href={`#${tag.get('name')}`} onClick={this.handleLockTag(tag.get('name'))}>
            <i className={this.props.locktag === `#${tag.get('name')}` ? 'fa fa-lock' : 'fa fa-pencil-square-o'} />
          </a>
        </div>
      </li>
    ));

    return (
      <div className='favourite-tags'>
        <div className='favourite-tags__header'>
          <i className='fa fa-tag' />
          <div className='favourite-tags__header__name'>お気に入りタグ</div>
          <div className='favourite-tags__lock'>
            <a href='/settings/favourite_tags'>
              <i className='fa fa-gear' />
            </a>
          </div>
        </div>
        <ul className='favourite-tags__body'>
          {tags}
        </ul>
      </div>
    );
  }

};

export default FavouriteTags;
