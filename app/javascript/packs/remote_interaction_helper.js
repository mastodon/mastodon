import './public-path';

import axios from 'axios';

const PERSISTENCE_KEY = 'mastodon_home';

const navigateToProxy = (uri_or_domain, proxyUrl, resourceUrl) => {
  if (!/^https?:\/\//.test(proxyUrl)) {
    remoteInteractionFailure();
    return;
  }

  if (localStorage) {
    localStorage.setItem(PERSISTENCE_KEY, uri_or_domain);
  }

  document.getElementById('resourceUrlField').value = resourceUrl;

  const form = document.getElementById('proxy-form');
  form.action = proxyUrl;
  form.submit();
};

const navigateToTemplate = (uri_or_domain, template, resourceUrl) => {
  if (!/^https?:\/\//.test(template)) {
    remoteInteractionFailure();
    return;
  }

  if (localStorage) {
    localStorage.setItem(PERSISTENCE_KEY, uri_or_domain);
  }

  window.parent.location.href = template.replace('{uri}', encodeURIComponent(resourceUrl));
};

const remoteInteractionFailure = () => {
  window.parent.postMessage({
    type: 'remoteInteractionFailure',
  }, window.origin);
};

const fromDomain = (domain, resourceUrl) => {
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios.get(`https://${domain}/.well-known/webfinger`, { params: { resource: `https://${domain}` } }).then(({ data }) => {
    const proxyUrl = data.links.find(link => link.rel === 'https://www.w3.org/ns/activitystreams#proxyUrl')?.href;
    if (proxyUrl) {
      navigateToProxy(domain, proxyUrl, resourceUrl);
    } else {
      const template = data.links.find(link => link.rel === 'http://ostatus.org/schema/1.0/subscribe')?.template;
      navigateToTemplate(domain, template || fallbackTemplate, resourceUrl);
    }
  }).catch(() => {
    navigateToTemplate(domain, fallbackTemplate, resourceUrl);
  });
};

const fromURL = (url, resourceUrl) => {
  const domain = (new URL(url)).host;
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios.get(`https://${domain}/.well-known/webfinger`, { params: { resource: url } }).then(({ data }) => {
    const proxyUrl = data.links.find(link => link.rel === 'https://www.w3.org/ns/activitystreams#proxyUrl')?.href;
    if (proxyUrl) {
      navigateToProxy(url, proxyUrl, resourceUrl);
    } else {
      const template = data.links.find(link => link.rel === 'http://ostatus.org/schema/1.0/subscribe')?.template;
      navigateToTemplate(url, template || fallbackTemplate, resourceUrl);
    }
  }).catch(() => {
    fromDomain(domain);
  });
};

const isValidDomain = value => {
  const url = new URL('https:///path');
  url.hostname = value;
  return url.hostname === value;
};

const fromAcct = (acct, resourceUrl) => {
  acct = acct.replace(/^@/, '');

  const segments = acct.split('@');

  if (segments.length !== 2 || !segments[0] || !isValidDomain(segments[1])) {
    remoteInteractionFailure();
    return;
  }

  const domain = segments[1];
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios.get(`https://${domain}/.well-known/webfinger`, { params: { resource: `acct:${acct}` } }).then(({ data }) => {
    const proxyUrl = data.links.find(link => link.rel === 'https://www.w3.org/ns/activitystreams#proxyUrl')?.href;
    if (proxyUrl) {
      navigateToProxy(acct, proxyUrl, resourceUrl);
    } else {
      const template = data.links.find(link => link.rel === 'http://ostatus.org/schema/1.0/subscribe')?.template;
      navigateToTemplate(acct, template || fallbackTemplate, resourceUrl);
    }
  }).catch(() => {
    // TODO: handle host-meta?
    fromDomain(domain, resourceUrl);
  });
};

const initiateRemoteInteraction = (uri_or_domain, resourceUrl) => {
  if (/^https?:\/\//.test(uri_or_domain)) {
    fromURL(uri_or_domain, resourceUrl);
  } else if (uri_or_domain.includes('@')) {
    fromAcct(uri_or_domain, resourceUrl);
  } else {
    fromDomain(uri_or_domain, resourceUrl);
  }
};

window.addEventListener('message', event => {
  // Check message type and origin
  if (!window.parent || !window.origin || window.parent !== event.source || event.origin !== window.origin || event.data?.type !== 'initiateRemoteInteraction') {
    return;
  }

  // Sanity check on message data
  if (!event.data.resourceUrl || !event.data.uri_or_domain || !/^https?:\/\//.test(event.data.resourceUrl)) {
    remoteInteractionFailure();
    return;
  }

  initiateRemoteInteraction(event.data.uri_or_domain, event.data.resourceUrl);
});
