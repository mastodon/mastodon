// .github/scripts/script_automation.js

const fs = require("fs");
const fetch = require("node-fetch");

// Example main function
async function main() {
  try {
    const mastodonToken = process.env.MASTODON_TOKEN;
    if (!mastodonToken) {
      throw new Error("MASTODON_TOKEN environment variable not set");
    }

    const response = await fetch("https://mastodon.example/api/v1/timelines/home", {
      headers: {
        Authorization: `Bearer ${mastodonToken}`,
      },
    });

    if (!response.ok) {
      throw new Error(`Mastodon API request failed: ${response.statusText}`);
    }

    const timeline = await response.json();
    fs.writeFileSync("timeline.json", JSON.stringify(timeline, null, 2));
    console.log("Timeline saved to timeline.json");
  } catch (error) {
    console.error("Error:", error);
    process.exit(1);
  }
}

main();
