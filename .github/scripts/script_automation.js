// .github/scripts/script_automation.js

const fetch = require('node-fetch'); // node-fetch v2

// Replace with your instance, e.g. 'https://mastodon.social'
const INSTANCE_URL = 'https://mastodon.social';
const API_ENDPOINT = `${INSTANCE_URL}/api/v1/timelines/home`;

const MASTODON_TOKEN = process.env.MASTODON_TOKEN;

if (!MASTODON_TOKEN) {
  console.error('MASTODON_TOKEN environment variable is not set.');
  process.exit(1);
}

async function readTimeline() {
  try {
    const response = await fetch(API_ENDPOINT, {
      headers: {
        'Authorization': `Bearer ${MASTODON_TOKEN}`,
        'Accept': 'application/json',
      },
    });

    if (!response.ok) {
      console.error('Error fetching Mastodon timeline:', response.status, response.statusText);
      process.exit(1);
    }

    const data = await response.json();
    // Print the latest 5 posts with basic info (removing HTML tags from content)
    data.slice(0, 5).forEach((status, i) => {
      const content = status.content.replace(/<[^>]+>/g, ''); // Remove HTML tags
      const acct = status.account?.acct || 'unknown';
      console.log(`[${i + 1}] @${acct}: ${content}`);
    });
  } catch (error) {
    console.error('Failed to fetch timeline:', error);
    process.exit(1);
  }
}

readTimeline();
