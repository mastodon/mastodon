/*

This script is meant to to be used in an `iframe` with the sole purpose of doing webfinger queries
client-side without being restricted by a strict `connect-src` Content-Security-Policy directive.

It communicates with the parent window through message events that are authenticated by origin,
and performs no other task.

*/

import '@/entrypoints/public-path';

import axios from 'axios';

interface JRDLink {
  rel: string;
  template?: string;
  href?: string;
}

const isJRDLink = (link: unknown): link is JRDLink =>
  typeof link === 'object' &&
  link !== null &&
  'rel' in link &&
  typeof link.rel === 'string' &&
  (!('template' in link) || typeof link.template === 'string') &&
  (!('href' in link) || typeof link.href === 'string');

const findLink = (rel: string, data: unknown): JRDLink | undefined => {
  if (
    typeof data === 'object' &&
    data !== null &&
    'links' in data &&
    data.links instanceof Array
  ) {
    return data.links.find(
      (link): link is JRDLink => isJRDLink(link) && link.rel === rel,
    );
  } else {
    return undefined;
  }
};

const findTemplateLink = (data: unknown) =>
  findLink('http://ostatus.org/schema/1.0/subscribe', data)?.template;

const fetchInteractionURLSuccess = (
  uri_or_domain: string,
  template: string,
) => {
  window.parent.postMessage(
    {
      type: 'fetchInteractionURL-success',
      uri_or_domain,
      template,
    },
    window.origin,
  );
};

const fetchInteractionURLFailure = () => {
  window.parent.postMessage(
    {
      type: 'fetchInteractionURL-failure',
    },
    window.origin,
  );
};

const isValidDomain = (value: string) => {
  const url = new URL('https:///path');
  url.hostname = value;
  return url.hostname === value;
};

// Attempt to find a remote interaction URL from a domain
const fromDomain = (domain: string) => {
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios
    .get(`https://${domain}/.well-known/webfinger`, {
      params: { resource: `https://${domain}` },
    })
    .then(({ data }) => {
      const template = findTemplateLink(data);
      fetchInteractionURLSuccess(domain, template ?? fallbackTemplate);
      return;
    })
    .catch(() => {
      fetchInteractionURLSuccess(domain, fallbackTemplate);
    });
};

// Attempt to find a remote interaction URL from an arbitrary URL
const fromURL = (url: string) => {
  const domain = new URL(url).host;
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios
    .get(`https://${domain}/.well-known/webfinger`, {
      params: { resource: url },
    })
    .then(({ data }) => {
      const template = findTemplateLink(data);
      fetchInteractionURLSuccess(url, template ?? fallbackTemplate);
      return;
    })
    .catch(() => {
      fromDomain(domain);
    });
};

// Attempt to find a remote interaction URL from a `user@domain` string
const fromAcct = (acct: string) => {
  acct = acct.replace(/^@/, '');

  const segments = acct.split('@');

  if (segments.length !== 2 || !segments[0] || !isValidDomain(segments[1])) {
    fetchInteractionURLFailure();
    return;
  }

  const domain = segments[1];
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios
    .get(`https://${domain}/.well-known/webfinger`, {
      params: { resource: `acct:${acct}` },
    })
    .then(({ data }) => {
      const template = findTemplateLink(data);
      fetchInteractionURLSuccess(acct, template ?? fallbackTemplate);
      return;
    })
    .catch(() => {
      // TODO: handle host-meta?
      fromDomain(domain);
    });
};

const fetchInteractionURL = (uri_or_domain: string) => {
  if (uri_or_domain === '') {
    fetchInteractionURLFailure();
  } else if (/^https?:\/\//.test(uri_or_domain)) {
    fromURL(uri_or_domain);
  } else if (uri_or_domain.includes('@')) {
    fromAcct(uri_or_domain);
  } else {
    fromDomain(uri_or_domain);
  }
};

window.addEventListener('message', (event: MessageEvent<unknown>) => {
  // Check message origin
  if (
    !window.origin ||
    window.parent !== event.source ||
    event.origin !== window.origin
  ) {
    return;
  }

  if (
    event.data &&
    typeof event.data === 'object' &&
    'type' in event.data &&
    event.data.type === 'fetchInteractionURL' &&
    'uri_or_domain' in event.data &&
    typeof event.data.uri_or_domain === 'string'
  ) {
    fetchInteractionURL(event.data.uri_or_domain);
  }
});
