import { connectStream } from 'flavours/glitch/util/stream';
import {
  updateTimeline,
  deleteFromTimelines,
  expandHomeTimeline,
  connectTimeline,
  disconnectTimeline,
} from './timelines';
import { updateNotifications, expandNotifications } from './notifications';
import { updateConversations } from './conversations';
import {
  fetchAnnouncements,
  updateAnnouncements,
  updateReaction as updateAnnouncementsReaction,
  deleteAnnouncement,
} from './announcements';
import { fetchFilters } from './filters';
import { getLocale } from 'mastodon/locales';

const { messages } = getLocale();

export function connectTimelineStream (timelineId, path, pollingRefresh = null, accept = null) {

  return connectStream (path, pollingRefresh, (dispatch, getState) => {
    const locale = getState().getIn(['meta', 'locale']);

    return {
      onConnect() {
        dispatch(connectTimeline(timelineId));
      },

      onDisconnect() {
        dispatch(disconnectTimeline(timelineId));
      },

      onReceive (data) {
        switch(data.event) {
        case 'update':
          dispatch(updateTimeline(timelineId, JSON.parse(data.payload), accept));
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        case 'notification':
          dispatch(updateNotifications(JSON.parse(data.payload), messages, locale));
          break;
        case 'conversation':
          dispatch(updateConversations(JSON.parse(data.payload)));
          break;
        case 'filters_changed':
          dispatch(fetchFilters());
          break;
        case 'announcement':
          dispatch(updateAnnouncements(JSON.parse(data.payload)));
          break;
        case 'announcement.reaction':
          dispatch(updateAnnouncementsReaction(JSON.parse(data.payload)));
          break;
        case 'announcement.delete':
          dispatch(deleteAnnouncement(data.payload));
          break;
        }
      },
    };
  });
}

const refreshHomeTimelineAndNotification = (dispatch, done) => {
  dispatch(expandHomeTimeline({}, () =>
    dispatch(expandNotifications({}, () =>
      dispatch(fetchAnnouncements(done))))));
};

export const connectUserStream      = () => connectTimelineStream('home', 'user', refreshHomeTimelineAndNotification);
export const connectCommunityStream = ({ onlyMedia } = {}) => connectTimelineStream(`community${onlyMedia ? ':media' : ''}`, `public:local${onlyMedia ? ':media' : ''}`);
export const connectPublicStream    = ({ onlyMedia } = {}) => connectTimelineStream(`public${onlyMedia ? ':media' : ''}`, `public${onlyMedia ? ':media' : ''}`);
export const connectHashtagStream   = (id, tag, accept) => connectTimelineStream(`hashtag:${id}`, `hashtag&tag=${tag}`, null, accept);
export const connectDirectStream    = () => connectTimelineStream('direct', 'direct');
export const connectListStream      = id => connectTimelineStream(`list:${id}`, `list&list=${id}`);
