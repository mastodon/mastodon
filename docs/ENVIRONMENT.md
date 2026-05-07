# Mastodon Development Environment

This document describes the recommended and **tested working environment** for Mastodon development as of 2026.

---

## **Requirements**

### **Core:**

- **Ruby**: See the `.ruby-version` file (typically Ruby 3.2.x or newer)
- **Bundler**: Install with `gem install bundler`
- **PostgreSQL**: 13+
- **Redis**: 6+
- **Node.js**: **18.x LTS recommended**  
  - (Node 20.x is usually okay; **Node 22.x is NOT recommended** due to incompatibility with some JS/asset builds)
  - Test with: `node --version` (must be `v18.x`)
- **Yarn**: 4.x+ (*Yarn Classic/1.x will not work*).  
  - Test with: `yarn --version`
- **Vite**: Mastodon `package.json` pins Vite to 5.x (**not** 8.x).

### **Optional:**
- **ffmpeg** (for transcoding media)
- **ImageMagick** or **libvips** (for image processing)

---

## **Setup Steps**

1. **Install correct Node.js:**
   - [NVM (Node Version Manager)](https://github.com/nvm-sh/nvm) recommended:
     ```sh
     nvm install 18
     nvm use 18
     node --version  # should print something like v18.20.8
     ```
2. **Install Yarn 4+:**
   ```sh
   npm install -g yarn
   yarn --version
   ```

3. **Install Ruby, Bundler, Postgres, Redis** using your OS package manager.

4. **Install other dependencies as needed.**
   - Ubuntu/Debian:  
     ```sh
     sudo apt install postgresql redis-server ffmpeg libvips ruby-dev
     ```

5. **Clone Mastodon and enter the project folder.**

---

## **Installation Steps (from repo root)**

```sh
# Install Ruby gems and JS dependencies
bundle install
yarn install

# Clean all JS build caches (if you migrate Node or modify package.json)
rm -rf node_modules .yarn/cache .yarn/unplugged .vite .parcel-cache yarn.lock
yarn cache clean --all
yarn install

# Database and setup
RAILS_ENV=development bin/setup

# Start all dev servers (Rails API, Vite JS, Streaming server, Sidekiq)
RAILS_ENV=development bin/dev
```

---

## **Yarn Resolutions for ESM Compatibility**

Add this to your `package.json` to force compatible versions of certain dependencies:
```json
"resolutions": {
  "@types/react": "^18.2.7",
  "@types/react-dom": "^18.2.4",
  "kind-of": "^6.0.3",
  "jsdom": "^21.1.0",
  "html-encoding-sniffer": "^3.0.0"
}
```

---

## **Common Issues & Fixes**

- **Blank/black UI, console “isImmutable” errors:**  
  Downgrade `immutable` to `^4.0.0-rc.14` in `package.json`, then clean and reinstall.

- **Vite/asset “Pre-transform error”, “MIME type (…)” problems:**  
  Use the exact Node version above and Vite 5.x (not 8.x). Delete all caches and `yarn.lock`, then reinstall.

- **Streaming server fails with ESM error on `html-encoding-sniffer`:**  
  Use “resolutions” for `jsdom` and `html-encoding-sniffer` versions as shown above.

- **Warnings about Dart Sass or `legacy-js-api`:**  
  Safe to ignore during development. Upgrade `sass-loader`/Sass dependencies when possible.

- **Node "path" or "url" browser compatibility warnings in console:**  
  Harmless—no effect on Mastodon operation.

---

## **Production Environment**

- For production, use Node 18.x LTS, and build assets ahead of time.
- Set up Redis, Postgres, Sidekiq, and system mailer according to the [official Mastodon production guide](https://docs.joinmastodon.org/admin/prerequisites/).

---

## **Tested and Known Good Versions (as of May 2026)**
- **Node.js:** 18.20.x
- **Ruby:** 3.2+
- **Bundler:** 2.4+
- **PostgreSQL:** 13+
- **Redis:** 6+
- **Yarn:** 4.12.0
- **Vite:** 5.2.10 (pinned in package.json)
- **immutable:** 4.0.0-rc.14

---

## **Further Reading**

- [Official Mastodon Install Guide](https://docs.joinmastodon.org/admin/install/)
- [Vite browser compatibility warnings](https://vitejs.dev/guide/troubleshooting.html#module-externalized-for-browser-compatibility)
- [Resolutions in Yarn](https://yarnpkg.com/configuration/manifest#resolutions)
- [Node LTS schedule](https://nodejs.org/en/about/releases)

---

**If you encounter new errors, always check your Node, Yarn, and critical dependency versions, then clean and reinstall. The Mastodon community GitHub is a great resource for edge cases and new upgrades.**
