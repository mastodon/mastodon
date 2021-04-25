import React from 'react';
import { List as ImmutableList } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Link from 'react-router-dom/Link';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';
import FoldButton from '../../../components/fold_button';
import Foldable from '../../../components/foldable';

const messages = defineMessages({
  favourite_tags: { id: 'compose_form.favourite_tags', defaultMessage: 'Favourite tags' },
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
});

const icons = [
  { key: 'public', icon: 'globe' },
  { key: 'unlisted', icon: 'unlock' },
  { key: 'private', icon: 'lock' },
];

@injectIntl
class FavouriteTags extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    visible: PropTypes.bool.isRequired,
    tags: ImmutablePropTypes.list.isRequired,
    refreshFavouriteTags: PropTypes.func.isRequired,
    onToggle: PropTypes.func.isRequired,
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
    const { intl, visible, onToggle } = this.props;

    const tags = this.props.tags.map(tag => (
      <li key={tag.get('name')}>
        <div className='favourite-tags__icon'>
          <i className={`fa fa-fw fa-${this.visibilityToIcon(tag.get('visibility'))}`} />
        </div>
        <Link
          to={`/timelines/tag/${tag.get('name')}`}
          className='compose__extra__body__name'
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
      <div className='compose__extra'>
        <div className='compose__extra__header'>
          <i className='fa fa-tag' />
          <span>{intl.formatMessage(messages.favourite_tags)}</span>
          <div className='compose__extra__header__icon'>
            <a href='/settings/favourite_tags'>
              <i className='fa fa-gear' />
            </a>
          </div>
          <div className='compose__extra__header__fold__icon'>
            <FoldButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={onToggle} size={20} animate active={visible} />
          </div>
        </div>
        <Foldable isVisible={visible} fullHeight={this.props.tags.size * 30} minHeight={0} >
          <ul className='compose__extra__body'>
            {tags}
          </ul>
        </Foldable>
      </div>
    );
  }

};

export default FavouriteTags;
