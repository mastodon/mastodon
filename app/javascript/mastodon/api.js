import axios from 'axios';
import LinkHeader from './link_header';

export const getLinks = response => {
  const value = response.headers.link;

  if (!value) {
    return { refs: [] };
  }

  return LinkHeader.parse(value);
};

export default getState => axios.create({
  headers: {
    'Authorization': `Bearer ${getState().getIn(['meta', 'access_token'], '')}`
  },

  transformResponse: [function (data) {
    try {
      return JSON.parse(data);
    } catch(Exception) {
      return data;
    }
  }]
});
