import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import emojify from '../../../features/emoji/emoji';
import Immutable from 'immutable';

export default class EnqueteContent extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onVote: PropTypes.func,
    onVoteLoad: PropTypes.func,
    onEnqueteTimeout: PropTypes.func,
  };

  componentWillMount() {
    const { status } = this.props;
    const enquete = Immutable.fromJS(JSON.parse(status.get('enquete')));
    if (enquete.get('type') === 'enquete_result') {
      this.setState({ alive: false });
    } else {
      const id = status.get('id');
      const isAlreadyVoted = this.readVoteHistory(id);
      if (isAlreadyVoted !== null) {
        this.props.onVoteLoad(id, isAlreadyVoted);
      }
      const createdAt = Date.parse(status.get('created_at'));
      const now = Date.now();
      const duration = enquete.get('duration');
      if ((createdAt + duration * 1000) < now) {
        //already dead enquete when rendered
        this.props.onEnqueteTimeout(id);
        this.setState({
          alive: false,
          createdAt: createdAt,
          remaining: -1,
          duration,
        });
      } else {
        //still alive enquete
        this.setState({
          alive: true,
          createdAt: createdAt,
          remaining: 1,
          duration,
        });
      }
    }
  };

  readVoteHistory(id) {
    let result = null;

    const cookieName = 'vote_to_' + String(id) + '=';
    const allCookies = document.cookie;
    const position = allCookies.indexOf(cookieName);
    if (position !== -1) {
      var startIndex = position + cookieName.length;
      var endIndex   = allCookies.indexOf(';', startIndex);
      if (endIndex === -1) {
        endIndex = allCookies.length;
      }
      result = allCookies.substring(startIndex, endIndex);
    }
    return result;
  }

  tick() {
    const tr = this.state.duration - (Date.now() - this.state.createdAt) / 1000;
    if (tr < 0) {
      clearInterval(this.state.intervalId);
      this.setState({ remaining: -1 });
      this.props.onEnqueteTimeout(this.props.status.get('id'));
    } else {
      this.setState({ remaining: tr.toFixed(2) });
    }
  };

  componentDidMount() {
    if (this.state.alive) {
      this.setState({ intervalId: setInterval(this.tick.bind(this), 30) });
    }
  };

  componentWillUnmount() {
    clearInterval(this.state.intervalId);
  };

  // call onVote
  handleEnqueteButtonClick = (e) => {
    const index = e.currentTarget.getAttribute('data-number');
    this.props.onVote(this.props.status.get('id'), index);
  }

  render() {
    const { status } = this.props;
    const enquete = Immutable.fromJS(JSON.parse(status.get('enquete')));
    const questionContent = { __html: emojify(enquete.get('question')) };

    const itemsContent = enquete.get('type') === 'enquete' ?
            this.voteContent(status, enquete) : this.resultContent(enquete);

    return (
      <div className='enquete-form'>
        <div className='enquete-question' dangerouslySetInnerHTML={questionContent} />
        { itemsContent }
      </div>
    );
  }

  voteContent(status, enquete) {
    const enable = !(status.get('vote') || status.get('enquete_timeout'));
    const voted = parseInt(status.get('voted_num'), 10);
    const gauge = this.gaugeContent(status);
    const itemClassName = (index) => {
      const base = 'enquete-button';
      if (enable)
        return `${base} active`;
      if (index === voted)
        return `${base} disable__voted`;
      return `${base} disable`;
    };

    return (
      <div className='enquete-vote-items'>
        {enquete.get('items').filter(item => item !== '').map((item, index) => {
          const itemHTML = { __html: emojify(item) };
          return (
            <button
               key={index}
               className={itemClassName(index)}
               dangerouslySetInnerHTML={itemHTML}
               onClick={enable ? this.handleEnqueteButtonClick : null}
               data-number={index}
            />);
        })}
        {gauge}
      </div>
    );
  }

  resultContent(enquete) {
    return (
      <div className='enquete-result-items'>
        {enquete.get('items').filter(item => item !== '').map((item, index) => {
          // ratios is not immutable component
          const itemRatio = (enquete.get('ratios')).get(index) + '%';
          const itemRatioText = enquete.get('ratios_text').get(index);
          const itemRatioHTML = { __html: emojify(itemRatioText) };
          const itemHTML = { __html: emojify(item) };
          const resultGaugeClassName = 'item-gauge__inner';
          return (
            <div className='enquete-result-item-gauge' key={index} >
              <div className='item-gauge__content'>
                <div className='item-gauge__text__wrapper'>
                  <span className='item-gauge__text' dangerouslySetInnerHTML={itemHTML} />
                </div>
                <div className='item-gauge__ratio__wrapper'>
                  <span className='item-gauge__ratio' dangerouslySetInnerHTML={itemRatioHTML} />
                </div>
              </div>
              <div className='item-gauge__outer' style={{ width: '100%' }} />
              <div className={resultGaugeClassName} style={{ width: itemRatio }} />
            </div>);
        })}
      </div>
    );
  }

  gaugeContent(status) {
    const { remaining, duration } = this.state;
    const gauge_width = {
      width: String(100 - (remaining / duration) * 100) + '%',
    };

    return (
      <div className='enquete-deadline'>
        <div className='enquete-gauge'>
          <div className='enquete-gauge-outer'>
            <div className='enquete-gauge-inner' style={gauge_width}>
              <i className='tv-chan knzk-gauge-icon' />
            </div>
          </div>
        </div>
        <div className='enquete-time'>
          {status.get('enquete_timeout') ? '終了' : remaining}
        </div>
      </div>
    );
  }

}