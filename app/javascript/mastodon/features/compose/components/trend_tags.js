import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Link from 'react-router-dom/Link';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';
import { Sparklines, SparklinesCurve } from 'react-sparklines';
import FoldButton from '../../../components/fold_button';
import Foldable from '../../../components/foldable';

const messages = defineMessages({
  trend_tags: { id: 'compose_form.trend_tags', defaultMessage: 'Trend tags' },
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
});

@injectIntl
export default class TrendTags extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    visible: PropTypes.bool.isRequired,
    trendTags: ImmutablePropTypes.map.isRequired,
    trendTagsHistory: ImmutablePropTypes.list.isRequired,
    favouriteTags: ImmutablePropTypes.list.isRequired,
    refreshTrendTags: PropTypes.func.isRequired,
    onToggle: PropTypes.func.isRequired,
  };

  state = {
    animate: false,
  };

  componentDidMount() {
    this.props.refreshTrendTags();
  }

  onClickReload = () => {
    if (!this.state.animate) {
      this.setState({ animate: true });
      this.props.refreshTrendTags();
    }
  }

  onAnimationEnd = () => {
    this.setState({ animate: false });
  }

  reloadIcon = (isAnimate) => {
    return isAnimate ? <i className='fa fa-repeat animate' onAnimationEnd={this.onAnimationEnd} /> : <i className='fa fa-repeat' />;
  }

  render () {
    const { intl, visible, trendTags, trendTagsHistory, onToggle } = this.props;
    const hMax = trendTagsHistory.map(item => item.get('score').valueSeq()).flatten().max();

    const tags = trendTags && trendTags.keySeq().filter((v, k) => k < 5).map(name => (
      <li key={name}>
        <Link
          to={`/timelines/tag/${name}`}
          className='compose__extra__body__name'
          key={name}
        >
          <i className='fa fa-hashtag' />
          {name}
        </Link>
        <div className={`trend-tags__sparkline ${trendTags.get(name) < 20 ? 'normal' : 'fever'}`}>
          <Sparklines
            width={50}
            height={18}
            max={hMax}
            data={[...trendTagsHistory.map(item => item.getIn(['score', name]) || 0).toArray().reverse(), trendTags.get(name)]}
          >
            <SparklinesCurve />
          </Sparklines>
        </div>
      </li>
    ));

    return (
      <div className='compose__extra'>
        <div className='compose__extra__header'>
          <i className='fa fa-tag' />
          <div className='compose__extra__header__name'>{intl.formatMessage(messages.trend_tags)}</div>
          <div className='compose__extra__header__icon'>
            <a href='javascript:void(0);' onClick={this.onClickReload} >
              {this.reloadIcon(this.state.animate)}
            </a>
          </div>
          <div className='compose__extra__header__fold__icon'>
            <FoldButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={onToggle} size={20} animate active={visible} />
          </div>
        </div>
        <Foldable isVisible={visible} fullHeight={trendTags ? Math.min(150, trendTags.size * 30) : 0} minHeight={0} >
          <div className='compose__extra__body'>
            <ol>
              {tags}
            </ol>
          </div>
        </Foldable>
      </div>
    );
  }

}
