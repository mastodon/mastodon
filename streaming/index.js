import dotenv from 'dotenv'
import express from 'express'
import redis from 'redis'
import pg from 'pg'

dotenv.config()

const pgConfigs = {
  development: {
    database: 'mastodon_development',
    host:     '/var/run/postgresql',
    max:      10
  },

  production: {
    user:     process.env.DB_USER || 'mastodon',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'mastodon_production',
    host:     process.env.DB_HOST || 'localhost',
    port:     process.env.DB_PORT || 5432,
    max:      10
  }
}

const app = express()
const env = process.env.NODE_ENV || 'development'
const pgPool = new pg.Pool(pgConfigs[env])

const authenticationMiddleware = (req, res, next) => {
  const authorization = req.get('Authorization')

  if (!authorization) {
    err = new Error('Missing access token')
    err.statusCode = 401

    return next(err)
  }

  const token = authorization.replace(/^Bearer /, '')

  pgPool.connect((err, client, done) => {
    if (err) {
      return next(err)
    }

    client.query('SELECT oauth_access_tokens.resource_owner_id, users.account_id FROM oauth_access_tokens INNER JOIN users ON oauth_access_tokens.resource_owner_id = users.id WHERE token = $1 LIMIT 1', [token], (err, result) => {
      done()

      if (err) {
        return next(err)
      }

      if (result.rows.length === 0) {
        err = new Error('Invalid access token')
        err.statusCode = 401

        return next(err)
      }

      req.accountId = result.rows[0].account_id

      next()
    })
  })
}

const errorMiddleware = (err, req, res, next) => {
  res.writeHead(err.statusCode || 500, { 'Content-Type': 'application/json' })
  res.end(JSON.stringify({ error: `${err}` }))
}

const streamFrom = (id, res) => {
  res.setHeader('Content-Type', 'text/event-stream')
  res.setHeader('Transfer-Encoding', 'chunked')

  const redisClient = redis.createClient()

  redisClient.on('message', (channel, message) => {
    const { event, payload } = JSON.parse(message)

    res.write(`event: ${event}\n`)
    res.write(`data: ${payload}\n\n`)
  })

  setInterval(() => res.write('\n'), 15000)

  redisClient.subscribe(id)
}

app.use(authenticationMiddleware)
app.use(errorMiddleware)

app.get('/api/v1/streaming/user',    (req, res) => streamFrom(`timeline:${req.accountId}`, res))
app.get('/api/v1/streaming/public',  (_, res)   => streamFrom('timeline:public', res))
app.get('/api/v1/streaming/hashtag', (req, res) => streamFrom(`timeline:hashtag:${req.params.tag}`, res))

app.listen(4000)
