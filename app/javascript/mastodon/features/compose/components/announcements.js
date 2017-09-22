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
  welcome: { id: 'welcome.message', defaultMessage: '{domain}へようこそ!' },
  bbcode: { id: 'bbcode.list', defaultMessage: 'BBCode一覧' },
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
    show: false,
    isLoaded: false,
  };

  onClick = () => {
    this.setState({ show: !this.state.show });
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
          <Collapsable isVisible={this.state.show} fullHeight={300} minHeight={20} >
            <div className='announcements__body'>
              <p>{ this.nl2br(intl.formatMessage(messages.welcome, { domain: document.title }))}<br />
			  <br />
			  このインスタンスではBBCodeを使ってテキストをアニメーションさせたり、多くのカスタム絵文字を使うことが出来ます。<br />
			  about/moreではBBCodeやカスタム絵文字の使い方などを見ることが出来ます。<br />
			  <br />
			  あなたがまだフォローする人を決めていない場合、下記のタグを付けて投稿しているユーザーを確認してみると良いかもしれません。</p>
              {hashtags.map((hashtag, i) =>
                <Link key={i} to={`/timelines/tag/${hashtag}`}>
                  #{hashtag}
                </Link>
              )}
            </div>
          </Collapsable>
          <div className='announcements__icon'>
            <IconButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={this.onClick} size={20} animate active={this.state.show} />
          </div>
        </li>
        <li>
          <Collapsable isVisible={this.state.show} fullHeight={300} minHeight={20} >
            <div className='announcements__body'>
              <p>{ this.nl2br(intl.formatMessage(messages.bbcode, { domain: document.title }))}<br />
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
			  [color=red]色変更[/color]<br />
			  [code]コード[/code]<br />
			  [quote]引用[/quote]<br />
			  </p>
            </div>
          </Collapsable>
          <div className='announcements__icon'>
            <IconButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={this.onClick} size={20} animate active={this.state.show} />
          </div>
        </li>
      </ul>
    );
  }

  componentWillReceiveProps (nextProps) {
    if (!this.state.isLoaded) {
      if (!nextProps.isLoading && (nextProps.homeSize === 0 || this.props.homeSize !== nextProps.homeSize)) {
        this.setState({ show: nextProps.homeSize < 5, isLoaded: true });
      }
    }
  }

}

export default injectIntl(Announcements);
