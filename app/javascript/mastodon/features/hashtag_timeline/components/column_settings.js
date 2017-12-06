import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Button from '../../../components/button';
import SettingToggle from '../components/setting_toggle';
import SettingText from '../components/setting_text';
import { Map as ImmutableMap } from 'immutable';

const messages = defineMessages({
  filter_regex: { id: 'tag.column_settings.filter_regex', defaultMessage: 'Filter out by regular expressions' },
  show_local_only: { id: 'tag.column_settings.show_local_only', defaultMessage: 'Show local only' },
  settings: { id: 'tag.settings', defaultMessage: 'Column settings' },
  add_favourite_tags_public: { id: 'tag.add_favourite.public', defaultMessage: 'add in the favourite tags (Public)' },
  add_favourite_tags_unlisted: { id: 'tag.add_favourite.unlisted', defaultMessage: 'add in the favourite tags (Unlisted)' },
  remove_favourite_tags: { id: 'tag.remove_favourite', defaultMessage: 'Remove from the favourite tags' },
});

@injectIntl
export default class ColumnSettings extends React.PureComponent {

  static propTypes = {
    tag: PropTypes.string.isRequired,
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
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
    const { tag, settings, onChange, intl, isRegistered } = this.props;
    const initialSettings = ImmutableMap({
      shows: ImmutableMap({
        local: false,
      }),

      regex: ImmutableMap({
        body: '',
      }),
    });

    const favouriteTagButton = (isRegistered) => {
      if(isRegistered) {
        return (
          <div className='column-settings__row'>
            <Button className='favourite-tags__remove-button-in-column' text={intl.formatMessage(messages.remove_favourite_tags)} onClick={this.removeFavouriteTags} block />
          </div>
        );
      } else {
        return (
          <div className='column-settings__row'>
            <Button className='favourite-tags__add-button-in-column' text={intl.formatMessage(messages.add_favourite_tags_public)} onClick={this.addPublic} block />
            <Button className='favourite-tags__add-button-in-column' text={intl.formatMessage(messages.add_favourite_tags_unlisted)} onClick={this.addUnlisted} block />
          </div>
        );
      }
    };

    return (
      <div>
        {favouriteTagButton(isRegistered)}
        <span className='column-settings__section'><FormattedMessage id='tag.column_settings.basic' defaultMessage='Basic' /></span>

        <div className='column-settings__row'>
          <SettingToggle tag={tag} prefix='hashtag_timeline' settings={settings.get(`${tag}`, initialSettings)} settingKey={['shows', 'local']} onChange={onChange} label={intl.formatMessage(messages.show_local_only)} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='tag.column_settings.advanced' defaultMessage='Advanced' /></span>

        <div className='column-settings__row'>
          <SettingText tag={tag} prefix='hashtag_timeline' settings={settings.get(`${tag}`, initialSettings)} settingKey={['regex', 'body']} onChange={onChange} label={intl.formatMessage(messages.filter_regex)} />
        </div>
      </div>
    );
  }

}
