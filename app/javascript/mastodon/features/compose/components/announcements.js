import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';
import Link from 'react-router-dom/Link';
import FoldButton from '../../../components/fold_button';

const messages = defineMessages({
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
});

@injectIntl
export default class Announcements extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    visible: PropTypes.bool.isRequired,
    onToggle: PropTypes.func.isRequired,
    announcements: ImmutablePropTypes.list.isRequired,
  };

  render () {
    const { intl, visible, onToggle, announcements } = this.props;

    return (
      <div className='announcements'>
        <div className='compose__extra__header'>
          <i className='fa fa-bell' />
          <FormattedMessage id='announcement.title' defaultMessage='information' />
          <div className='compose__extra__header__fold__icon'>
            <FoldButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={onToggle} size={20} animate active={visible} />
          </div>
        </div>
        { visible && (
          <ul>
            {announcements.map((announcement, idx) => (
              <li key={idx}>
                <div className='announcements__body'>
                  <p dangerouslySetInnerHTML={{ __html: announcement.get('body') }} />
                  <div className='links'>
                    {announcement.get('links').map((link, i) => {
                      if (link.get('url').indexOf('/') === 0) {
                        return (
                          <Link to={link.get('url')} key={i}>{link.get('text')}</Link>
                        );
                      } else {
                        return (
                          <a href={link.get('url')} target='_blank' key={i}>{link.get('text')}</a>
                        );
                      }
                    })}
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    );
  }

}
