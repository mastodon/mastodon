#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { MastodonStack } from '../lib/mastodon-stack';
import { MailStack } from '../lib/mail-stack';
import { OIDCStack } from '../lib/oidc-stack';

const PRODUCTION = (process.env.NODE_ENV === 'production');

// First run will DESTROY the database and recreate it. 
// Used for (surprisingly) the first run of an environment
// to set up the database.
const FIRST_RUN = (process.env.FIRST_RUN === 'true');

const env = {
    account: PRODUCTION ? '059427179902': '424684280317',
    region: 'us-west-2'
  }

const domain = PRODUCTION ? 'verified.coop' : 'verified-staging.net'

const secrets = PRODUCTION ? require('../secrets').production : require('../secrets').staging

// OIDC Stack
const githubDomain = 'token.actions.githubusercontent.com';
const repositoryConfig = [
  { owner: 'hellocoop', repo: 'mastodon', filter: 'dev' },
]

const app = new cdk.App();

  // Kyle: I'm going to put the template all in one stack
  // typically I have a few different stacks -- not sure how you 
  // think it should best be sliced up

const mail = new MailStack(app, 'MailStack', {
  env,
  domain
})

const oidc = new OIDCStack(app, 'OIDCStack', {
  githubDomain,
  repositoryConfig
})

const mastodon =  new MastodonStack(app, 'MastodonStack', {
  env,
  PRODUCTION,
  domain,
  secrets,
  FIRST_RUN
});