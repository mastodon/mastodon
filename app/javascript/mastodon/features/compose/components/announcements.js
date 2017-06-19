import React from 'react';
import Immutable from 'immutable';
import PropTypes from 'prop-types';
import Link from 'react-router/lib/Link';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import IconButton from '../../../components/announcement_icon_button';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';

const Collapsable = ({ fullHeight, minHeight, isVisible, children }) => (
  <Motion defaultStyle={{height: isVisible ? fullHeight : minHeight }} style={{height: spring(!isVisible ? minHeight : fullHeight) }}>
    {({ height }) =>
      <div style={{ height: `${height}px`, overflow: 'hidden'}}>
        {children}
      </div>
    }
  </Motion>
);

Collapsable.propTypes = {
  fullHeight: PropTypes.number.isRequired,
  minHeight: PropTypes.number.isRequired,
  isVisible: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired,
};

const messages = defineMessages({
  welcome: { id: 'welcome.message', defaultMessage: 'Welcome to {domain}!' },
});

const hashtags = Immutable.fromJS([
  'Pの自己紹介',
  'みんなのP名刺',
]);

class Announcements extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    homeSize: PropTypes.number,
    isLoading: PropTypes.bool,
  };

  state = {
    show: false,
  };

  onClick = () => {
    this.setState({show: !this.state.show});
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
    const { intl } = this.props;

    return (
      <ul className='announcements'>
        <li>
          <Collapsable isVisible={this.state.show} fullHeight={300} minHeight={20} >
            <div className='announcements__body'>
              <p>{this.nl2br(intl.formatMessage(messages.welcome, {domain: document.title}))}</p>
              {hashtags.map(hashtag =>
                <Link to={`/timelines/tag/${hashtag}`}>
                  #{hashtag}
                </Link>
              )}
            </div>
          </Collapsable>
          <div className='announcements__icon'>
            <IconButton icon='caret-up' onClick={this.onClick} size={20} animate={true} active={this.state.show} />
          </div>
        </li>
      </ul>
    );
  }

  componentWillReceiveProps (nextProps) {
    if (!nextProps.isLoading && (nextProps.homeSize === 0 || this.props.homeSize !== nextProps.homeSize)) {
        this.setState({show: nextProps.homeSize < 5});
    }
  }

}

export default injectIntl(Announcements);
