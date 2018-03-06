import { connectStream } from '../stream';
import { UPDATE_ANNOUNCEMENTS } from './announcements';
import { refreshTrendTags } from './trend_tags';

export function connectCommandStream(pollingRefresh = null) {
  return connectStream('commands', pollingRefresh, (dispatch) => ({
    onConnect() {},
    onDisconnect() {},
    onReceive(data) {
      switch(data.event) {
      case 'announcements':
        dispatch({
          type: UPDATE_ANNOUNCEMENTS,
          data: JSON.parse(data.payload),
        });
        break;
      case 'trend_tags':
        dispatch(refreshTrendTags());
        break;
      default:
        return;
      }
    },
  }));
}
