import './public-path';

import axios from 'axios';

const fetchInteractionURLSuccess = (uri_or_domain, template) => {
  window.parent.postMessage({
    type: 'fetchInteractionURL-success',
    uri_or_domain,
    template,
  }, window.origin);
};

const fetchInteractionURLFailure = (uri_or_domain) => {
  window.parent.postMessage({
    type: 'fetchInteractionURL-failure',
    uri_or_domain,
  }, window.origin);
};

const fromDomain = (domain) => {
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios.get(`https://${domain}/.well-known/webfinger`, { params: { resource: `https://${domain}` } }).then(({ data }) => {
    const template = data.links.find(link => link.rel === 'http://ostatus.org/schema/1.0/subscribe')?.template;
    fetchInteractionURLSuccess(domain, template || fallbackTemplate);
  }).catch(() => {
    fetchInteractionURLSuccess(domain, fallbackTemplate);
  });
};

const fromURL = (url) => {
  const domain = (new URL(url)).host;
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios.get(`https://${domain}/.well-known/webfinger`, { params: { resource: url } }).then(({ data }) => {
    const template = data.links.find(link => link.rel === 'http://ostatus.org/schema/1.0/subscribe')?.template;
    fetchInteractionURLSuccess(url, template || fallbackTemplate);
  }).catch(() => {
    fromDomain(domain);
  });
};

const isValidDomain = value => {
  const url = new URL('https:///path');
  url.hostname = value;
  return url.hostname === value;
};

const fromAcct = (acct) => {
  acct = acct.replace(/^@/, '');

  const segments = acct.split('@');

  if (segments.length !== 2 || !segments[0] || !isValidDomain(segments[1])) {
    fetchInteractionURLFailure();
    return;
  }

  const domain = segments[1];
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios.get(`https://${domain}/.well-known/webfinger`, { params: { resource: `acct:${acct}` } }).then(({ data }) => {
    const template = data.links.find(link => link.rel === 'http://ostatus.org/schema/1.0/subscribe')?.template;
    fetchInteractionURLSuccess(acct, template || fallbackTemplate);
  }).catch(() => {
    // TODO: handle host-meta?
    fromDomain(domain);
  });
};

const fetchInteractionURL = (uri_or_domain) => {
  if (/^https?:\/\//.test(uri_or_domain)) {
    fromURL(uri_or_domain);
  } else if (uri_or_domain.includes('@')) {
    fromAcct(uri_or_domain);
  } else {
    fromDomain(uri_or_domain);
  }
};

window.addEventListener('message', event => {
  if (!window.parent || window.parent !== event.source || event.data?.type !== 'fetchInteractionURL') {
    return;
  }

  fetchInteractionURL(event.data.uri_or_domain);
});
