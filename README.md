Mastodon
========

Mastodon is a federated microblogging engine. An alternative implementation of the GNU Social project. Based on ActivityStreams, Webfinger, PubsubHubbub and Salmon.

The core ideals of this project are:

- Independence of legacy Twitter APIs - we don't want to be compatible with Twitter clients, we want our own clients
- In that vein, a strong and clean REST API and OAuth2
- Minimalism. Just because you can do almost anything with ActivityStreams doesn't mean you should. Limit the set of possible functions to what makes sense in a microblogging engine. This will make federation as well as UI design a lot easier
- Ease of deployment. The end-goal of this project is to be distributable as a Docker image.

**Current status of the project is early development. Documentation, licensing information &co will be added later**

## Configuration

- `LOCAL_DOMAIN` should be the domain/hostname of your instance. This is **absolutely required** as it is used for generating unique IDs for everything federation-related
- `LOCAL_HTTPS` set it to `true` if HTTPS works on your website. This is used to generate canonical URLs, which is also important when generating and parsing federation-related IDs
- `HUB_URL` should be the URL of the PubsubHubbub service that your instance is going to use. By default it is the open service of Superfeedr
