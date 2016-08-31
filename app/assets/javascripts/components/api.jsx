import axios from 'axios';

export default getState => axios.create({
  headers: {
    'Authorization': `Bearer ${getState().getIn(['meta', 'access_token'], '')}`
  },

  transformResponse: [function (data) {
    return JSON.parse(data);
  }]
});
