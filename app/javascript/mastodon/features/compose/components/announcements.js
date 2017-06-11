import React from 'react';
import { connect } from 'react-redux';
import Immutable from 'immutable';
import PropTypes from 'prop-types';
import Link from 'react-router/lib/Link';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  welcome: { id: 'welcome.message', defaultMessage: 'Welcome to {domain}!' },
});

const hashtags = Immutable.fromJS([
  'Pの自己紹介',
  'みんなのP名刺',
]);

const mapStateToProps = state => ({
  isEmptyHome: state.getIn(['timelines', 'home', 'items']).size < 5,
});

class Announcements extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    isEmptyHome: PropTypes.bool,
  };

  state = {
    show: true,
  };

  onClick = () => {
    const currentShow = this.state.show;
    this.setState({show: !currentShow});
  }
  nl2br (text) {
    return text.split(/(\n)/g).map(function (line) {
      if (line.match(/(\n)/g)) {
        return React.createElement('br');
      }
      return line;
    });
  }

  render () {
    const { intl, isEmptyHome } = this.props;
    const { show } = this.state;

    if (!isEmptyHome) {
      return null;
    }
    return (
      <ul className='announcements'>
        <li style={{display: show ? '' : 'none'}}>
          <div className='announcements__body'>
            <p>{this.nl2br(intl.formatMessage(messages.welcome, {domain: document.title}))}</p>
            {hashtags.map(hashtag =>
              <Link to={`/timelines/tag/${hashtag}`}>
                #{hashtag}
              </Link>
            )}
          </div>
          <div className='announcements__icon'>
            <IconButton icon='times' onClick={this.onClick} size={16} />
          </div>
        </li>
      </ul>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Announcements));
