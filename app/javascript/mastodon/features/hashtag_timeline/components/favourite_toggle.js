import React from 'react';
import PropTypes from 'prop-types';
import Button from '../../../components/button';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

const messages = defineMessages({
  add_favourite_tags_public: { id: 'tag.add_favourite.public', defaultMessage: 'add in the favourite tags (Public)' },
  add_favourite_tags_unlisted: { id: 'tag.add_favourite.unlisted', defaultMessage: 'add in the favourite tags (Unlisted)' },
  remove_favourite_tags: { id: 'tag.remove_favourite', defaultMessage: 'Remove from the favourite tags' },
});

@injectIntl
export default class FavouriteToggle extends React.PureComponent {

  static propTypes = {
    tag: PropTypes.string.isRequired,
    addFavouriteTags: PropTypes.func.isRequired,
    removeFavouriteTags: PropTypes.func.isRequired,
    isRegistered: PropTypes.bool.isRequired,
    intl: PropTypes.object.isRequired,
  };

  addFavouriteTags = (visibility) => {
    this.props.addFavouriteTags(this.props.tag, visibility);
  };

  addPublic = () => {
    this.addFavouriteTags('public');
  };

  addUnlisted = () => {
    this.addFavouriteTags('unlisted');
  };

  removeFavouriteTags = () => {
    this.props.removeFavouriteTags(this.props.tag);
  };

  render () {
    const { intl, isRegistered } = this.props;

    return (
      <div>
        { isRegistered ?
          <div className='column-settings__row'>
            <Button className='favourite-tags__remove-button-in-column' text={intl.formatMessage(messages.remove_favourite_tags)} onClick={this.removeFavouriteTags} block />
          </div>
        :
          <div className='column-settings__row'>
            <Button className='favourite-tags__add-button-in-column' text={intl.formatMessage(messages.add_favourite_tags_public)} onClick={this.addPublic} block />
            <Button className='favourite-tags__add-button-in-column' text={intl.formatMessage(messages.add_favourite_tags_unlisted)} onClick={this.addUnlisted} block />
          </div>
        }
      </div>
    );
  }

}
