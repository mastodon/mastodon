import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import emojify from '../../../emoji';
import escapeTextContentForBrowser from 'escape-html';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import IconButton from '../../../components/icon_button';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
});

/*
  THIS IS A MESS BECAUSE EFFING MASTODON AND ITS EFFING HTML BIOS
  INSTEAD OF JUST STORING EVERYTHING IN PLAIN EFFING TEXT ! ! ! !
  BLANK LINES ALSO WON'T WORK BECAUSE RIGHT NOW MASTODON CONVERTS
  THOSE INTO `<P>` ELEMENTS INSTEAD OF LEAVING IT AS `<BR><BR>` !
  TL:DR; THIS IS LARGELY A HACK. WITH BETTER BACKEND STUFF WE CAN
  IMPROVE THIS BY BETTER PREDICTING HOW THE METADATA WILL BE SENT
  WHILE MAINTAINING BASIC PLAIN-TEXT PROCESSING. THE OTHER OPTION
  IS TO TURN ALL BIOS INTO PLAIN-TEXT VIA A TREE-WALKER, AND THEN
  PROCESS THE YAML AND LINKS AND EVERYTHING OURSELVES. THIS WOULD
  BE INCREDIBLY COMPLICATED, AND IT WOULD BE A MILLION TIMES LESS
  DIFFICULT IF MASTODON JUST GAVE US PLAIN-TEXT BIOS (WHICH QUITE
  FRANKLY MAKES THE MOST SENSE SINCE THAT'S WHAT USERS PROVIDE IN
  SETTINGS) TO BEGIN WITH AND LEFT ALL PROCESSING TO THE FRONTEND
  TO HANDLE ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
  ANYWAY I KNOW WHAT NEEDS TO BE DONE REGARDING BACKEND STUFF BUT
  I'M NOT SMART ENOUGH TO FIGURE OUT HOW TO ACTUALLY IMPLEMENT IT
  SO FEEL FREE TO @ ME IF YOU NEED MY IDEAS REGARDING THAT. UNTIL
  THEN WE'LL JUST HAVE TO MAKE DO WITH THIS MESSY AND UNFORTUNATE
  HACKING ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !

                                           with love,
                                           @kibi@glitch.social <3
*/

const NEW_LINE    = /(?:^|\r?\n|<br\s*\/?>)/g
const YAML_OPENER = /---/;
const YAML_CLOSER = /(?:---|\.\.\.)/;
const YAML_STRING = /(?:"(?:[^"\n]){1,32}"|'(?:[^'\n]){1,32}'|(?:[^'":\n]){1,32})/g;
const YAML_LINE = new RegExp("\\s*" + YAML_STRING.source + "\\s*:\\s*" + YAML_STRING.source + "\\s*", "g");
const BIO_REGEX = new RegExp(NEW_LINE.source + "*" + YAML_OPENER.source + NEW_LINE.source + "+(?:" + YAML_LINE.source + NEW_LINE.source + "+){0,4}" + YAML_CLOSER.source + NEW_LINE.source + "*");

const processBio = (data) => {
  let props = {text: data, metadata: []};
  let yaml = data.match(BIO_REGEX);
  if (!yaml) return props;
  else yaml = yaml[0];
  let start = props.text.indexOf(yaml);
  let end = start + yaml.length;
  props.text = props.text.substr(0, start) + props.text.substr(end);
  yaml = yaml.replace(NEW_LINE, "\n");
  let metadata = (yaml ? yaml.match(YAML_LINE) : []) || [];
  for (let i = 0; i < metadata.length; i++) {
    let result = metadata[i].match(YAML_STRING);
    if (result[0][0] === '"' || result[0][0] === "'") result[0] = result[0].substr(1, result[0].length - 2);
    if (result[1][0] === '"' || result[1][0] === "'") result[0] = result[1].substr(1, result[1].length - 2);
    props.metadata.push(result);
  }
  return props;
};

const makeMapStateToProps = () => {
  const mapStateToProps = state => ({
    autoPlayGif: state.getIn(['meta', 'auto_play_gif']),
  });

  return mapStateToProps;
};

class Avatar extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    autoPlayGif: PropTypes.bool.isRequired,
  };

  state = {
    isHovered: false,
  };

  handleMouseOver = () => {
    if (this.state.isHovered) return;
    this.setState({ isHovered: true });
  }

  handleMouseOut = () => {
    if (!this.state.isHovered) return;
    this.setState({ isHovered: false });
  }

  render () {
    const { account, autoPlayGif }   = this.props;
    const { isHovered } = this.state;

    return (
      <Motion defaultStyle={{ radius: 90 }} style={{ radius: spring(isHovered ? 30 : 90, { stiffness: 180, damping: 12 }) }}>
        {({ radius }) =>
          <a // eslint-disable-line jsx-a11y/anchor-has-content
            href={account.get('url')}
            className='account__header__avatar'
            target='_blank'
            rel='noopener'
            style={{ borderRadius: `${radius}px`, backgroundImage: `url(${autoPlayGif || isHovered ? account.get('avatar') : account.get('avatar_static')})` }}
            onMouseOver={this.handleMouseOver}
            onMouseOut={this.handleMouseOut}
            onFocus={this.handleMouseOver}
            onBlur={this.handleMouseOut}
          />
        }
      </Motion>
    );
  }

}

@connect(makeMapStateToProps)
@injectIntl
export default class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    me: PropTypes.number.isRequired,
    onFollow: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    autoPlayGif: PropTypes.bool.isRequired,
  };

  render () {
    const { account, me, intl } = this.props;

    if (!account) {
      return null;
    }

    let displayName = account.get('display_name');
    let info        = '';
    let actionBtn   = '';
    let lockedIcon  = '';

    if (displayName.length === 0) {
      displayName = account.get('username');
    }

    if (me !== account.get('id') && account.getIn(['relationship', 'followed_by'])) {
      info = <span className='account--follows-info'><FormattedMessage id='account.follows_you' defaultMessage='Follows you' /></span>;
    }

    if (me !== account.get('id')) {
      if (account.getIn(['relationship', 'requested'])) {
        actionBtn = (
          <div className='account--action-button'>
            <IconButton size={26} disabled icon='hourglass' title={intl.formatMessage(messages.requested)} />
          </div>
        );
      } else if (!account.getIn(['relationship', 'blocking'])) {
        actionBtn = (
          <div className='account--action-button'>
            <IconButton size={26} icon={account.getIn(['relationship', 'following']) ? 'user-times' : 'user-plus'} active={account.getIn(['relationship', 'following'])} title={intl.formatMessage(account.getIn(['relationship', 'following']) ? messages.unfollow : messages.follow)} onClick={this.props.onFollow} />
          </div>
        );
      }
    }

    if (account.get('locked')) {
      lockedIcon = <i className='fa fa-lock' />;
    }

    const displayNameHTML    = { __html: emojify(escapeTextContentForBrowser(displayName)) };
    const { text, metadata } = processBio(account.get('note'));

    return (
      <div className='account__header__wrapper'>
        <div className='account__header' style={{ backgroundImage: `url(${account.get('header')})` }}>
          <div>
            <Avatar account={account} autoPlayGif={this.props.autoPlayGif} />

            <span className='account__header__display-name' dangerouslySetInnerHTML={displayNameHTML} />
            <span className='account__header__username'>@{account.get('acct')} {lockedIcon}</span>
            <div className='account__header__content' dangerouslySetInnerHTML={{__html: emojify(text)}} />

            {info}
            {actionBtn}
          </div>
        </div>

        {metadata.length && (
          <div className='account__metadata'>
            {(() => {
              let data = [];
              for (let i = 0; i < metadata.length; i++) {
                data.push(
                  <div
                    className='account__metadata-item'
                    title={metadata[i][0] + ":" + metadata[i][1]}
                    key={i}
                  >
                    <span dangerouslySetInnerHTML={{__html: emojify(metadata[i][0])}} />
                    <strong dangerouslySetInnerHTML={{__html: emojify(metadata[i][1])}} />
                  </div>
                );
              }
              return data;
            })()}
          </div>
        ) || null}
      </div>
    );
  }

}
