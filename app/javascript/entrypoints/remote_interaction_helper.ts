/*

This script is meant to to be used in an `iframe` with the sole purpose of doing webfinger queries
client-side without being restricted by a strict `connect-src` Content-Security-Policy directive.

It communicates with the parent window through message events that are authenticated by origin,
and performs no other task.

*/

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

const intentParams = (intent: string): [string, string] | null => {
  switch (intent) {
    case 'follow':
      return ['https://w3id.org/fep/3b86/Follow', 'object'];
    case 'reblog':
      return ['https://w3id.org/fep/3b86/Announce', 'object'];
    case 'favourite':
      return ['https://w3id.org/fep/3b86/Like', 'object'];
    case 'vote':
    case 'reply':
      return ['https://w3id.org/fep/3b86/Object', 'object'];
    default:
      return null;
  }
};

const findTemplateLink = (
  data: unknown,
  intent: string,
): [string, string] | [null, null] => {
  // Find the FEP-3b86 handler for the specific intent
  const [needle, param] = intentParams(intent) ?? [
    'http://ostatus.org/schema/1.0/subscribe',
    'uri',
  ];

  const match = findLink(needle, data);

  if (match?.template) {
    return [match.template, param];
  }

  // If the specific intent wasn't found, try the FEP-3b86 handler for the `Object` intent
  let fallback = findLink('https://w3id.org/fep/3b86/Object', data);
  if (fallback?.template) {
    return [fallback.template, 'object'];
  }

  // If it's still not found, try the legacy OStatus subscribe handler
  fallback = findLink('http://ostatus.org/schema/1.0/subscribe', data);

  if (fallback?.template) {
    return [fallback.template, 'uri'];
  }

  return [null, null];
};

const fetchInteractionURLSuccess = (
  uri_or_domain: string,
  template: string,
  param: string,
) => {
  window.parent.postMessage(
    {
      type: 'fetchInteractionURL-success',
      uri_or_domain,
      template,
      param,
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

const isValidDomain = (value: unknown) => {
  if (typeof value !== 'string') return false;

  const url = new URL('https:///path');
  url.hostname = value;
  return url.hostname === value;
};

// Attempt to find a remote interaction URL from a domain
const fromDomain = (domain: string, intent: string) => {
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios
    .get(`https://${domain}/.well-known/webfinger`, {
      params: { resource: `https://${domain}` },
    })
    .then(({ data }) => {
      const [template, param] = findTemplateLink(data, intent);
      fetchInteractionURLSuccess(
        domain,
        template ?? fallbackTemplate,
        param ?? 'uri',
      );
      return;
    })
    .catch(() => {
      fetchInteractionURLSuccess(domain, fallbackTemplate, 'uri');
    });
};

// Attempt to find a remote interaction URL from an arbitrary URL
const fromURL = (url: string, intent: string) => {
  const domain = new URL(url).host;
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  axios
    .get(`https://${domain}/.well-known/webfinger`, {
      params: { resource: url },
    })
    .then(({ data }) => {
      const [template, param] = findTemplateLink(data, intent);
      fetchInteractionURLSuccess(
        url,
        template ?? fallbackTemplate,
        param ?? 'uri',
      );
      return;
    })
    .catch(() => {
      fromDomain(domain, intent);
    });
};

// Attempt to find a remote interaction URL from a `user@domain` string
const fromAcct = (acct: string, intent: string) => {
  acct = acct.replace(/^@/, '');

  const segments = acct.split('@');

  if (segments.length !== 2 || !segments[0] || !isValidDomain(segments[1])) {
    fetchInteractionURLFailure();
    return;
  }

  const domain = segments[1];
  const fallbackTemplate = `https://${domain}/authorize_interaction?uri={uri}`;

  if (!domain) {
    fetchInteractionURLFailure();
    return;
  }

  axios
    .get(`https://${domain}/.well-known/webfinger`, {
      params: { resource: `acct:${acct}` },
    })
    .then(({ data }) => {
      const [template, param] = findTemplateLink(data, intent);
      fetchInteractionURLSuccess(
        acct,
        template ?? fallbackTemplate,
        param ?? 'uri',
      );
      return;
    })
    .catch(() => {
      // TODO: handle host-meta?
      fromDomain(domain, intent);
    });
};

const fetchInteractionURL = (uri_or_domain: string, intent: string) => {
  if (uri_or_domain === '') {
    fetchInteractionURLFailure();
  } else if (/^https?:\/\//.test(uri_or_domain)) {
    fromURL(uri_or_domain, intent);
  } else if (uri_or_domain.includes('@')) {
    fromAcct(uri_or_domain, intent);
  } else {
    fromDomain(uri_or_domain, intent);
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
    typeof event.data.uri_or_domain === 'string' &&
    'intent' in event.data &&
    typeof event.data.intent === 'string'
  ) {
    fetchInteractionURL(event.data.uri_or_domain, event.data.intent);
  }
});
