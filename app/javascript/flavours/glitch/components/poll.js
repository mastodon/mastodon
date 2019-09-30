import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import classNames from 'classnames';
import { vote, fetchPoll } from 'flavours/glitch/actions/polls';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import escapeTextContentForBrowser from 'escape-html';
import emojify from 'flavours/glitch/util/emoji';
import RelativeTimestamp from './relative_timestamp';
import Icon from 'flavours/glitch/components/icon';

const messages = defineMessages({
  closed: { id: 'poll.closed', defaultMessage: 'Closed' },
  voted: { id: 'poll.voted', defaultMessage: 'You voted for this answer', description: 'Tooltip of the "voted" checkmark in polls' },
});

const makeEmojiMap = record => record.get('emojis').reduce((obj, emoji) => {
  obj[`:${emoji.get('shortcode')}:`] = emoji.toJS();
  return obj;
}, {});

export default @injectIntl
class Poll extends ImmutablePureComponent {

  static propTypes = {
    poll: ImmutablePropTypes.map,
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func,
    disabled: PropTypes.bool,
  };

  state = {
    selected: {},
    expired: null,
  };

  static getDerivedStateFromProps (props, state) {
    const { poll, intl } = props;
    const expired = poll.get('expired') || (new Date(poll.get('expires_at'))).getTime() < intl.now();
    return (expired === state.expired) ? null : { expired };
  }

  componentDidMount () {
    this._setupTimer();
  }

  componentDidUpdate () {
    this._setupTimer();
  }

  componentWillUnmount () {
    clearTimeout(this._timer);
  }

  _setupTimer () {
    const { poll, intl } = this.props;
    clearTimeout(this._timer);
    if (!this.state.expired) {
      const delay = (new Date(poll.get('expires_at'))).getTime() - intl.now();
      this._timer = setTimeout(() => {
        this.setState({ expired: true });
      }, delay);
    }
  }

  handleOptionChange = e => {
    const { target: { value } } = e;

    if (this.props.poll.get('multiple')) {
      const tmp = { ...this.state.selected };
      if (tmp[value]) {
        delete tmp[value];
      } else {
        tmp[value] = true;
      }
      this.setState({ selected: tmp });
    } else {
      const tmp = {};
      tmp[value] = true;
      this.setState({ selected: tmp });
    }
  };

  handleVote = () => {
    if (this.props.disabled) {
      return;
    }

    this.props.dispatch(vote(this.props.poll.get('id'), Object.keys(this.state.selected)));
  };

  handleRefresh = () => {
    if (this.props.disabled) {
      return;
    }

    this.props.dispatch(fetchPoll(this.props.poll.get('id')));
  };

  renderOption (option, optionIndex, showResults) {
    const { poll, disabled, intl } = this.props;
    const pollVotesCount  = poll.get('voters_count') || poll.get('votes_count');
    const percent         = pollVotesCount === 0 ? 0 : (option.get('votes_count') / pollVotesCount) * 100;
    const leading         = poll.get('options').filterNot(other => other.get('title') === option.get('title')).every(other => option.get('votes_count') >= other.get('votes_count'));
    const active          = !!this.state.selected[`${optionIndex}`];
    const voted           = option.get('voted') || (poll.get('own_votes') && poll.get('own_votes').includes(optionIndex));

    let titleEmojified = option.get('title_emojified');
    if (!titleEmojified) {
      const emojiMap = makeEmojiMap(poll);
      titleEmojified = emojify(escapeTextContentForBrowser(option.get('title')), emojiMap);
    }

    return (
      <li key={option.get('title')}>
        {showResults && (
          <Motion defaultStyle={{ width: 0 }} style={{ width: spring(percent, { stiffness: 180, damping: 12 }) }}>
            {({ width }) =>
              <span className={classNames('poll__chart', { leading })} style={{ width: `${width}%` }} />
            }
          </Motion>
        )}

        <label className={classNames('poll__text', { selectable: !showResults })}>
          <input
            name='vote-options'
            type={poll.get('multiple') ? 'checkbox' : 'radio'}
            value={optionIndex}
            checked={active}
            onChange={this.handleOptionChange}
            disabled={disabled}
          />

          {!showResults && <span className={classNames('poll__input', { checkbox: poll.get('multiple'), active })} />}
          {showResults && <span className='poll__number'>
            {!!voted && <Icon id='check' className='poll__vote__mark' title={intl.formatMessage(messages.voted)} />}
            {Math.round(percent)}%
          </span>}

          <span dangerouslySetInnerHTML={{ __html: titleEmojified }} />
        </label>
      </li>
    );
  }

  render () {
    const { poll, intl } = this.props;
    const { expired } = this.state;

    if (!poll) {
      return null;
    }

    const timeRemaining = expired ? intl.formatMessage(messages.closed) : <RelativeTimestamp timestamp={poll.get('expires_at')} futureDate />;
    const showResults   = poll.get('voted') || expired;
    const disabled      = this.props.disabled || Object.entries(this.state.selected).every(item => !item);

    let votesCount = null;

    if (poll.get('voters_count') !== null && poll.get('voters_count') !== undefined) {
      votesCount = <FormattedMessage id='poll.total_people' defaultMessage='{count, plural, one {# person} other {# people}}' values={{ count: poll.get('voters_count') }} />;
    } else {
      votesCount = <FormattedMessage id='poll.total_votes' defaultMessage='{count, plural, one {# vote} other {# votes}}' values={{ count: poll.get('votes_count') }} />;
    }

    return (
      <div className='poll'>
        <ul>
          {poll.get('options').map((option, i) => this.renderOption(option, i, showResults))}
        </ul>

        <div className='poll__footer'>
          {!showResults && <button className='button button-secondary' disabled={disabled} onClick={this.handleVote}><FormattedMessage id='poll.vote' defaultMessage='Vote' /></button>}
          {showResults && !this.props.disabled && <span><button className='poll__link' onClick={this.handleRefresh}><FormattedMessage id='poll.refresh' defaultMessage='Refresh' /></button> · </span>}
          {votesCount}
          {poll.get('expires_at') && <span> · {timeRemaining}</span>}
        </div>
      </div>
    );
  }

}
