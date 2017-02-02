import dotenv from 'dotenv'
import express from 'express'
import redis from 'redis'
import pg from 'pg'
import log from 'npmlog'

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
      log.error(err)
      return next(err)
    }

    client.query('SELECT oauth_access_tokens.resource_owner_id, users.account_id FROM oauth_access_tokens INNER JOIN users ON oauth_access_tokens.resource_owner_id = users.id WHERE token = $1 LIMIT 1', [token], (err, result) => {
      done()

      if (err) {
        log.error(err)
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
  res.end(JSON.stringify({ error: err.statusCode ? `${err}` : 'An unexpected error occured' }))
}

const streamFrom = (id, req, res, needsFiltering = false) => {
  log.verbose(`Starting stream from ${id} for ${req.accountId}`)

  res.setHeader('Content-Type', 'text/event-stream')
  res.setHeader('Transfer-Encoding', 'chunked')

  const redisClient = redis.createClient()

  redisClient.on('message', (channel, message) => {
    const { event, payload } = JSON.parse(message)

    if (needsFiltering) {
      pgPool.connect((err, client, done) => {
        if (err) {
          log.error(err)
          return
        }

        const unpackedPayload  = JSON.parse(payload)
        const targetAccountIds = [unpackedPayload.account.id] + unpackedPayload.mentions.map(item => item.id) + (unpackedPayload.reblog ? unpackedPayload.reblog.account.id : [])

        client.query('SELECT target_account_id FROM blocks WHERE account_id = $1 AND target_account_id IN ($2)', [req.accountId, targetAccountIds], (err, result) => {
          done()

          if (err) {
            log.error(err)
            return
          }

          if (result.rows.length > 0) {
            return
          }

          res.write(`event: ${event}\n`)
          res.write(`data: ${payload}\n\n`)
        })
      })
    } else {
      res.write(`event: ${event}\n`)
      res.write(`data: ${payload}\n\n`)
    }
  })

  // Heartbeat to keep connection alive
  setInterval(() => res.write(':thump\n'), 15000)

  redisClient.subscribe(id)
}

app.use(authenticationMiddleware)
app.use(errorMiddleware)

app.get('/api/v1/streaming/user',    (req, res) => streamFrom(`timeline:${req.accountId}`, req, res))
app.get('/api/v1/streaming/public',  (req, res) => streamFrom('timeline:public', req, res, true))
app.get('/api/v1/streaming/hashtag', (req, res) => streamFrom(`timeline:hashtag:${req.params.tag}`, req, res, true))

log.level = 'verbose'
log.info(`Starting HTTP server on port ${process.env.PORT || 4000}`)

app.listen(process.env.PORT || 4000)
