import axios from 'axios';
import LinkHeader from 'http-link-header';

export const getLinks = response => {
  return LinkHeader.parse(response.headers.link);
};

export default getState => axios.create({
  headers: {
    'Authorization': `Bearer ${getState().getIn(['meta', 'access_token'], '')}`
  },

  transformResponse: [function (data) {
    return JSON.parse(data);
  }]
});
