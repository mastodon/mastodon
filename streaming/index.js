import dotenv from 'dotenv'
import express from 'express'
import http from 'http'
import redis from 'redis'
import pg from 'pg'
import log from 'npmlog'
import url from 'url'
import WebSocket from 'ws'

const env = process.env.NODE_ENV || 'development'

dotenv.config({
  path: env === 'production' ? '.env.production' : '.env'
})

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

const app    = express()
const pgPool = new pg.Pool(pgConfigs[env])
const server = http.createServer(app)
const wss    = new WebSocket.Server({ server })

const allowCrossDomain = (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Headers', 'Authorization, Accept, Cache-Control')
  res.header('Access-Control-Allow-Methods', 'GET, OPTIONS')

  next()
}

const accountFromToken = (token, req, next) => {
  pgPool.connect((err, client, done) => {
    if (err) {
      return next(err)
    }

    client.query('SELECT oauth_access_tokens.resource_owner_id, users.account_id FROM oauth_access_tokens INNER JOIN users ON oauth_access_tokens.resource_owner_id = users.id WHERE oauth_access_tokens.token = $1 LIMIT 1', [token], (err, result) => {
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

const authenticationMiddleware = (req, res, next) => {
  if (req.method === 'OPTIONS') {
    return next()
  }

  const authorization = req.get('Authorization')

  if (!authorization) {
    const err = new Error('Missing access token')
    err.statusCode = 401

    return next(err)
  }

  const token = authorization.replace(/^Bearer /, '')

  accountFromToken(token, req, next)
}

const errorMiddleware = (err, req, res, next) => {
  log.error(err)
  res.writeHead(err.statusCode || 500, { 'Content-Type': 'application/json' })
  res.end(JSON.stringify({ error: err.statusCode ? `${err}` : 'An unexpected error occurred' }))
}

const placeholders = (arr, shift = 0) => arr.map((_, i) => `$${i + 1 + shift}`).join(', ');

const streamFrom = (redisClient, id, req, output, needsFiltering = false) => {
  log.verbose(`Starting stream from ${id} for ${req.accountId}`)

  redisClient.on('message', (channel, message) => {
    const { event, payload, queued_at } = JSON.parse(message)

    const transmit = () => {
      const now   = new Date().getTime()
      const delta = now - queued_at;

      log.silly(`Transmitting for ${req.accountId}: ${event} ${payload} Delay: ${delta}ms`)
      output(event, payload)
    }

    // Only messages that may require filtering are statuses, since notifications
    // are already personalized and deletes do not matter
    if (needsFiltering && event === 'update') {
      pgPool.connect((err, client, done) => {
        if (err) {
          log.error(err)
          return
        }

        const unpackedPayload  = JSON.parse(payload)
        const targetAccountIds = [unpackedPayload.account.id].concat(unpackedPayload.mentions.map(item => item.id)).concat(unpackedPayload.reblog ? [unpackedPayload.reblog.account.id] : [])

        client.query(`SELECT target_account_id FROM blocks WHERE account_id = $1 AND target_account_id IN (${placeholders(targetAccountIds, 1)})`, [req.accountId].concat(targetAccountIds), (err, result) => {
          done()

          if (err) {
            log.error(err)
            return
          }

          if (result.rows.length > 0) {
            return
          }

          transmit()
        })
      })
    } else {
      transmit()
    }
  })

  redisClient.subscribe(id)
}

// Setup stream output to HTTP
const streamToHttp = (req, res, redisClient) => {
  res.setHeader('Content-Type', 'text/event-stream')
  res.setHeader('Transfer-Encoding', 'chunked')

  const heartbeat = setInterval(() => res.write(':thump\n'), 15000)

  req.on('close', () => {
    log.verbose(`Ending stream for ${req.accountId}`)
    clearInterval(heartbeat)
    redisClient.quit()
  })

  return (event, payload) => {
    res.write(`event: ${event}\n`)
    res.write(`data: ${payload}\n\n`)
  }
}

// Setup stream output to WebSockets
const streamToWs = (req, ws, redisClient) => {
  ws.on('close', () => {
    log.verbose(`Ending stream for ${req.accountId}`)
    redisClient.quit()
  })

  return (event, payload) => {
    ws.send(JSON.stringify({ event, payload }))
  }
}

// Get new redis connection
const getRedisClient = () => redis.createClient({
  host:     process.env.REDIS_HOST     || '127.0.0.1',
  port:     process.env.REDIS_PORT     || 6379,
  password: process.env.REDIS_PASSWORD
})

app.use(allowCrossDomain)
app.use(authenticationMiddleware)
app.use(errorMiddleware)

app.get('/api/v1/streaming/user', (req, res) => {
  const redisClient = getRedisClient()
  streamFrom(redisClient, `timeline:${req.accountId}`, req, streamToHttp(req, res, redisClient))
})

app.get('/api/v1/streaming/public', (req, res) => {
  const redisClient = getRedisClient()
  streamFrom(redisClient, 'timeline:public', req, streamToHttp(req, res, redisClient), true)
})

app.get('/api/v1/streaming/hashtag', (req, res) => {
  const redisClient = getRedisClient()
  streamFrom(redisClient, `timeline:hashtag:${req.params.tag}`, req, streamToHttp(req, res, redisClient), true)
})

wss.on('connection', ws => {
  const location = url.parse(ws.upgradeReq.url, true)
  const token    = location.query.access_token
  const req      = {}

  accountFromToken(token, req, err => {
    if (err) {
      log.error(err)
      ws.close()
      return
    }

    const redisClient = getRedisClient()

    switch(location.query.stream) {
    case 'user':
      streamFrom(redisClient, `timeline:${req.accountId}`, req, streamToWs(req, ws, redisClient))
      break;
    case 'public':
      streamFrom(redisClient, 'timeline:public', req, streamToWs(req, ws, redisClient), true)
      break;
    case 'hashtag':
      streamFrom(redisClient, `timeline:hashtag:${location.query.tag}`, req, streamToWs(req, ws, redisClient), true)
      break;
    default:
      ws.close()
    }
  })
})

server.listen(process.env.PORT || 4000, () => {
  log.level = process.env.LOG_LEVEL || 'verbose'
  log.info(`Starting streaming API server on port ${server.address().port}`)
})
