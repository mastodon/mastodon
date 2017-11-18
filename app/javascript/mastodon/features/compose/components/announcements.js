import React from 'react';
import Immutable from 'immutable';
import PropTypes from 'prop-types';
import Link from 'react-router-dom/Link';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/announcement_icon_button';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';

const Collapsable = ({ fullHeight, minHeight, isVisible, children }) => (
  <Motion defaultStyle={{ height: isVisible ? fullHeight : minHeight }} style={{ height: spring(!isVisible ? minHeight : fullHeight) }}>
    {({ height }) =>
      <div style={{ height: `${height}px`, overflow: 'hidden' }}>
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
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
  welcome: { id: 'welcome.message', defaultMessage: 'BBCode' },
  bbcode: { id: 'bbcode.list', defaultMessage: 'Markdown' },
});

const hashtags = Immutable.fromJS([
  '神崎ドン自己紹介',
]);

class Announcements extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    homeSize: PropTypes.number,
    isLoading: PropTypes.bool,
  };

  state = {
    showId: null,
    isLoaded: false,
  };

  onClick = (announcementId, currentState) => {
    this.setState({ showId: currentState.showId === announcementId ? null : announcementId });
  }
  nl2br (text) {
    return text.split(/(\n)/g).map((line, i) => {
      if (line.match(/(\n)/g)) {
        return React.createElement('br', { key: i });
      }
      return line;
    });
  }

  render () {
    const { intl } = this.props;

    return (
      <ul className='announcements'>
        <li>
          <Collapsable isVisible={this.state.showId === 'introduction'} fullHeight={320} minHeight={20} >
            <div className='announcements__body'>
              <p>{ this.nl2br(intl.formatMessage(messages.welcome, { domain: document.title }))}<br />
                <br />
                [spin]回転[/spin]<br />
                [pulse]点滅[/pulse]<br />
                [large=2x]倍角文字[/large]<br />
                [flip=vertical]縦反転[/flip]<br />
                [flip=horizontal]横反転[/flip]<br />
                [b]太字[/b]<br />
                [i]斜体[/i]<br />
                [u]アンダーライン[/u]<br />
                [s]取り消し線[/s]<br />
                [size=5]サイズ変更[/size]<br />
                [color=red]色変更01[/color]<br />
                [colorhex=A55A4A]色変更02[/colorhex]<br />
                [code]コード[/code]<br />
                [quote]引用[/quote]<br />
                [faicon]coffee[/faicon]<br />
                <a href={'http://fontawesome.io/icons/'} target={'_blank'}>アイコン一覧</a>
              </p>
            </div>
          </Collapsable>
          <div className='announcements__icon'>
            <IconButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={() => this.onClick('introduction', this.state)} size={20} animate active={this.state.showId === 'introduction'} />
          </div>
        </li>
        <li>
          <Collapsable isVisible={this.state.showId === 'bbcode'} fullHeight={340} minHeight={20} >
            <div className='announcements__body'>
              <p>{ this.nl2br(intl.formatMessage(messages.bbcode, { domain: document.title }))}<br />
              <br />
				・リスト<br />
				- List1<br />
				- List2<br />
				- List3<br />
				・引用<br />
				> Quote<br />
				・コード<br />
				`code`<br />
				・イタリック<br />
				*italic*<br />
				・太字<br />
				**bold**<br />
				・イタリック+太字<br />
				***italicbold***<br />
				・ハイライト<br />
				==highlighted==<br />
				</p>
            </div>
          </Collapsable>
          <div className='announcements__icon'>
            <IconButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={() => this.onClick('bbcode', this.state)} size={20} animate active={this.state.showId === 'bbcode'} />
          </div>
        </li>
      </ul>
    );
  }

  componentWillReceiveProps (nextProps) {
    if (!this.state.isLoaded) {
      if (!nextProps.isLoading && (nextProps.homeSize === 0 || this.props.homeSize !== nextProps.homeSize)) {
        this.setState({ isLoaded: true });
      }
    }
  }

}

export default injectIntl(Announcements);
