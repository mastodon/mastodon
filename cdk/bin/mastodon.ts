#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { MastodonStack } from '../lib/mastodon-stack';

const PRODUCTION = (process.env.NODE_ENV === 'production')

const env = {
    account: PRODUCTION ? '059427179902': '424684280317',
    region: 'us-west-2'
  }

const domain = PRODUCTION ? 'verified.coop' : 'verified-stage.net'


const app = new cdk.App();

  // Kyle: I'm going to put the template all in one stack
  // typically I have a few different stacks -- not sure how you 
  // think it should best be sliced up

const mastodon =  new MastodonStack(app, 'MastodonStack', {
  env,
  PRODUCTION,
  domain
});