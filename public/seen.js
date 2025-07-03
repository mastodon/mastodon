const API_BASE = `https://postview.argyle.systems`;

const SEEN_ENDPOINT = `${API_BASE}/seen`;
const DWELLING_ENDPOINT = `${API_BASE}/dwelling`;

// Grab the long account ID you injected in your Haml
//const ACCOUNT_ID = document
//  .querySelector("meta[name='mastodon-account-id']")
//  ?.getAttribute("content");

const ACCOUNT_ID_EL = document.querySelector("meta[name='mastodon-account-id']");
const ACCOUNT_ID = ACCOUNT_ID_EL ? ACCOUNT_ID_EL.getAttribute("content") : null;

function isElementVisible(el) {
  const rect = el.getBoundingClientRect();
  return (
      rect.top < window.innerHeight &&
      rect.bottom > 0 &&
      rect.left < window.innerWidth &&
      rect.right > 0
  );
}

function scheduleDwellingChecks(article, dataId, delays) {
  delays.forEach(ms => {
    setTimeout(() => {
      if (!document.body.contains(article)) return;
      if (isElementVisible(article)) {
        dwelling(dataId, ms);
      }
    }, ms);
  });
}

const seenIds = new Set();
let scrolled = true;

window.addEventListener('resize', onScroll);
window.addEventListener('scroll', onScroll);

setInterval(() => {
  if (!window.location.pathname.endsWith('/home') && !window.location.pathname.endsWith('/public/local')) return;
  if (!scrolled) return;

  const articles = document.querySelectorAll('article');
  const newIds = [];

  articles.forEach(article => {
    if (isElementVisible(article)) {
      const dataId = article.getAttribute('data-id');
      if (dataId && !seenIds.has(dataId)) {
        newIds.push(dataId);
        seenIds.add(dataId);

        scheduleDwellingChecks(article, dataId,  [1000, 3000, 5000]);
      }
    }
  });

  if (newIds.length > 0) {
    const seenPayload = { ids: newIds };
    if (ACCOUNT_ID) seenPayload.account_id = ACCOUNT_ID;
    fetch(SEEN_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(seenPayload)
    }).catch(err => {
      console.error('Failed to send /seen POST:', err);
    });
  }

  if (articles.length > 0) scrolled = false;
}, 500);

function dwelling(id, seconds) {
  const dwellPayload = { id, seconds };
  if (ACCOUNT_ID) dwellPayload.account_id = ACCOUNT_ID;
  fetch(DWELLING_ENDPOINT, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(dwellPayload)
  }).catch(err => {
    console.error('Failed to send /dwelling POST:', err);
  });
}

function onScroll() {
  scrolled = true;
}
