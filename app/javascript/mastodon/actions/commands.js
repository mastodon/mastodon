import { connectStream } from '../stream';
import { refreshTrendTags } from './trend_tags';

export function connectCommandStream(pollingRefresh = null) {
  return connectStream('commands', pollingRefresh, (dispatch) => ({
    onConnect() {},
    onDisconnect() {},
    onReceive(data) {
      switch(data.event) {
      case 'trend_tags':
        dispatch(refreshTrendTags());
        break;
      default:
        return;
      }
    },
  }));
}
