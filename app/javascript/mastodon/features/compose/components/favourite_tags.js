import React from 'react';
import { List as ImmutableList } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Link from 'react-router-dom/Link';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  favourite_tags: { id: 'compose_form.favourite_tags', defaultMessage: 'Favourite tags' },
});

const icons = [
  { key: 'public', icon: 'globe' },
  { key: 'unlisted', icon: 'unlock-alt' },
  { key: 'private', icon: 'lock' },
];

@injectIntl
class FavouriteTags extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    tags: ImmutablePropTypes.list.isRequired,
    refreshFavouriteTags: PropTypes.func.isRequired,
    onLockTag: PropTypes.func.isRequired,
  };

  state = {
    lockedTag: ImmutableList(),
    lockedVisibility: ImmutableList(),
  };

  componentDidMount () {
    this.props.refreshFavouriteTags();
  }

  componentWillUpdate (nextProps, nextState) {
    // タグ操作に変更があった場合
    if (!this.state.lockedTag.equals(nextState.lockedTag)) {
      const icon = icons.concat().reverse().find(icon => nextState.lockedVisibility.includes(icon.key));
      this.execLockTag(
        nextState.lockedTag.join(' '),
        typeof icon === 'undefined' ? '' : icon.key
      );
    }
  }

  execLockTag (tag, icon) {
    this.props.onLockTag(tag, icon);
  }

  handleLockTag (tag, visibility) {
    const tagName = `#${tag}`;
    return ((e) => {
      e.preventDefault();
      if (this.state.lockedTag.includes(tagName)) {
        this.setState({ lockedTag: this.state.lockedTag.delete(this.state.lockedTag.indexOf(tagName)) });
        this.setState({ lockedVisibility: this.state.lockedVisibility.delete(this.state.lockedTag.indexOf(tagName)) });
      } else {
        this.setState({ lockedTag: this.state.lockedTag.push(tagName) });
        this.setState({ lockedVisibility: this.state.lockedVisibility.push(visibility) });
      }
    }).bind(this);
  }

  visibilityToIcon (val) {
    return icons.find(icon => icon.key === val).icon;
  }

  render () {
    const { intl } = this.props;

    const tags = this.props.tags.map(tag => (
      <li key={tag.get('name')}>
        <div className='favourite-tags__icon'>
          <i className={`fa fa-fw fa-${this.visibilityToIcon(tag.get('visibility'))}`} />
        </div>
        <Link
           to={`/timelines/tag/${tag.get('name').toLowerCase()}`}
           className='favourite-tags__name'
           key={tag.get('name')}
        >
          <i className='fa fa-hashtag' />
          {tag.get('name')}
        </Link>
        <div className='favourite-tags__lock'>
          <a href={`#${tag.get('name')}`} onClick={this.handleLockTag(tag.get('name'), tag.get('visibility'))}>
            <i className={this.state.lockedTag.includes(`#${tag.get('name')}`) ? 'fa fa-lock' : 'fa fa-pencil-square-o'} />
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
