import { connect } from 'react-redux';
import { addReaction, removeReaction, dismissAnnouncement } from 'flavours/glitch/actions/announcements';
import Announcements from '../components/announcements';
import { createSelector } from 'reselect';
import { Map as ImmutableMap } from 'immutable';

const customEmojiMap = createSelector([state => state.get('custom_emojis')], items => items.reduce((map, emoji) => map.set(emoji.get('shortcode'), emoji), ImmutableMap()));

const mapStateToProps = state => ({
  announcements: state.getIn(['announcements', 'items']),
  emojiMap: customEmojiMap(state),
});

const mapDispatchToProps = dispatch => ({
  dismissAnnouncement: id => dispatch(dismissAnnouncement(id)),
  addReaction: (id, name) => dispatch(addReaction(id, name)),
  removeReaction: (id, name) => dispatch(removeReaction(id, name)),
});

export default connect(mapStateToProps, mapDispatchToProps)(Announcements);
