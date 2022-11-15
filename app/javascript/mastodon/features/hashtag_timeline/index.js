import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import ColumnSettingsContainer from './containers/column_settings_container';
import { expandHashtagTimeline, clearTimeline } from 'mastodon/actions/timelines';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import { injectIntl, FormattedMessage, defineMessages } from 'react-intl';
import { connectHashtagStream } from 'mastodon/actions/streaming';
import { isEqual } from 'lodash';
import { fetchHashtag, followHashtag, unfollowHashtag } from 'mastodon/actions/tags';
import Icon from 'mastodon/components/icon';
import classNames from 'classnames';
import { Helmet } from 'react-helmet';

const messages = defineMessages({
  followHashtag: { id: 'hashtag.follow', defaultMessage: 'Follow hashtag' },
  unfollowHashtag: { id: 'hashtag.unfollow', defaultMessage: 'Unfollow hashtag' },
});

const mapStateToProps = (state, props) => ({
  hasUnread: state.getIn(['timelines', `hashtag:${props.params.id}${props.params.local ? ':local' : ''}`, 'unread']) > 0,
  tag: state.getIn(['tags', props.params.id]),
});

export default @connect(mapStateToProps)
@injectIntl
class HashtagTimeline extends React.PureComponent {

  disconnects = [];

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    params: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    hasUnread: PropTypes.bool,
    tag: ImmutablePropTypes.map,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('HASHTAG', { id: this.props.params.id }));
    }
  }

  title = () => {
    const { id } = this.props.params;
    const title  = [id];

    if (this.additionalFor('any')) {
      title.push(' ', <FormattedMessage key='any' id='hashtag.column_header.tag_mode.any'  values={{ additional: this.additionalFor('any') }} defaultMessage='or {additional}' />);
    }

    if (this.additionalFor('all')) {
      title.push(' ', <FormattedMessage key='all' id='hashtag.column_header.tag_mode.all'  values={{ additional: this.additionalFor('all') }} defaultMessage='and {additional}' />);
    }

    if (this.additionalFor('none')) {
      title.push(' ', <FormattedMessage key='none' id='hashtag.column_header.tag_mode.none' values={{ additional: this.additionalFor('none') }} defaultMessage='without {additional}' />);
    }

    return title;
  }

  additionalFor = (mode) => {
    const { tags } = this.props.params;

    if (tags && (tags[mode] || []).length > 0) {
      return tags[mode].map(tag => tag.value).join('/');
    } else {
      return '';
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  _subscribe (dispatch, id, tags = {}, local) {
    const { signedIn } = this.context.identity;

    if (!signedIn) {
      return;
    }

    let any  = (tags.any || []).map(tag => tag.value);
    let all  = (tags.all || []).map(tag => tag.value);
    let none = (tags.none || []).map(tag => tag.value);

    [id, ...any].map(tag => {
      this.disconnects.push(dispatch(connectHashtagStream(id, tag, local, status => {
        let tags = status.tags.map(tag => tag.name);

        return all.filter(tag => tags.includes(tag)).length === all.length &&
               none.filter(tag => tags.includes(tag)).length === 0;
      })));
    });
  }

  _unsubscribe () {
    this.disconnects.map(disconnect => disconnect());
    this.disconnects = [];
  }

  _unload () {
    const { dispatch } = this.props;
    const { id, local } = this.props.params;

    this._unsubscribe();
    dispatch(clearTimeline(`hashtag:${id}${local ? ':local' : ''}`));
  }

  _load() {
    const { dispatch } = this.props;
    const { id, tags, local } = this.props.params;

    this._subscribe(dispatch, id, tags, local);
    dispatch(expandHashtagTimeline(id, { tags, local }));
    dispatch(fetchHashtag(id));
  }

  componentDidMount () {
    this._load();
  }

  componentDidUpdate (prevProps) {
    const { params } = this.props;
    const { id, tags, local } = prevProps.params;

    if (id !== params.id || !isEqual(tags, params.tags) || !isEqual(local, params.local)) {
      this._unload();
      this._load();
    }
  }

  componentWillUnmount () {
    this._unsubscribe();
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = maxId => {
    const { dispatch, params } = this.props;
    const { id, tags, local }  = params;

    dispatch(expandHashtagTimeline(id, { maxId, tags, local }));
  }

  handleFollow = () => {
    const { dispatch, params, tag } = this.props;
    const { id } = params;
    const { signedIn } = this.context.identity;

    if (!signedIn) {
      return;
    }

    if (tag.get('following')) {
      dispatch(unfollowHashtag(id));
    } else {
      dispatch(followHashtag(id));
    }
  }

  render () {
    const { hasUnread, columnId, multiColumn, tag, intl } = this.props;
    const { id, local } = this.props.params;
    const pinned = !!columnId;
    const { signedIn } = this.context.identity;

    let followButton;

    if (tag) {
      const following = tag.get('following');

      followButton = (
        <button className={classNames('column-header__button')} onClick={this.handleFollow} disabled={!signedIn} title={intl.formatMessage(following ? messages.unfollowHashtag : messages.followHashtag)} aria-label={intl.formatMessage(following ? messages.unfollowHashtag : messages.followHashtag)}>
          <Icon id={following ? 'user-times' : 'user-plus'} fixedWidth className='column-header__icon' />
        </button>
      );
    }

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={`#${id}`}>
        <ColumnHeader
          icon='hashtag'
          active={hasUnread}
          title={this.title()}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          extraButton={followButton}
          showBackButton
        >
          {columnId && <ColumnSettingsContainer columnId={columnId} />}
        </ColumnHeader>

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`hashtag_timeline-${columnId}`}
          timelineId={`hashtag:${id}${local ? ':local' : ''}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.hashtag' defaultMessage='There is nothing in this hashtag yet.' />}
          bindToDocument={!multiColumn}
        />

        <Helmet>
          <title>#{id}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}
