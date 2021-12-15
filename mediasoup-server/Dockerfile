FROM node:carbon

WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install

RUN rm -rf node_modules/clang-tools-prebuilt node_modules/mediasoup/worker/out/Release/*.a node_modules/mediasoup/worker/out/obj.target

FROM node:carbon

WORKDIR /usr/src/app

COPY --from=0 /usr/src/app/node_modules ./node_modules


# Bundle app source.
COPY . .

EXPOSE 8000
ENV PORT 8000
ENV HOST 0.0.0.0
CMD ["/usr/local/bin/node", "index.js"]
