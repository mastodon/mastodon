import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Link from 'react-router-dom/Link';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  favourite_tags: { id: 'compose_form.favourite_tags', defaultMessage: 'Favourite tags' },
});

const icons = {
  public: 'globe',
  unlisted: 'unlock-alt',
  private: 'lock',
};

@injectIntl
class FavouriteTags extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    tags: ImmutablePropTypes.list.isRequired,
    locktag: PropTypes.string.isRequired,
    refreshFavouriteTags: PropTypes.func.isRequired,
    onLockTag: PropTypes.func.isRequired,
  };

  componentDidMount () {
    this.props.refreshFavouriteTags();
  }

  handleLockTag (tag, visibility) {
    const tagName = `#${tag}`;
    return ((e) => {
      e.preventDefault();
      if (this.props.locktag === tagName) {
        this.props.onLockTag('', '');
      } else {
        this.props.onLockTag(tagName, visibility);
      }
    }).bind(this);
  }

  visibilityToIcon (val) {
    return icons[val];
  }

  render () {
    const { intl } = this.props;

    const tags = this.props.tags.map(tag => (
      <li key={tag.get('name')}>
        <div className='favourite-tags__icon'>
          <i className={`fa fa-fw fa-${this.visibilityToIcon(tag.get('visibility'))}`} />
        </div>
        <Link
           to={`/timelines/tag/${tag.get('name')}`}
           className='favourite-tags__name'
           key={tag.get('name')}
        >
          <i className='fa fa-hashtag' />
          {tag.get('name')}
        </Link>
        <div className='favourite-tags__lock'>
          <a href={`#${tag.get('name')}`} onClick={this.handleLockTag(tag.get('name'), tag.get('visibility'))}>
            <i className={this.props.locktag === `#${tag.get('name')}` ? 'fa fa-lock' : 'fa fa-pencil-square-o'} />
          </a>
        </div>
      </li>
    ));

    return (
      <div className='favourite-tags'>
        <div className='favourite-tags__header'>
          <i className='fa fa-tag' />
          <div className='favourite-tags__header__name'>{intl.formatMessage(messages.favourite_tags)}</div>
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
