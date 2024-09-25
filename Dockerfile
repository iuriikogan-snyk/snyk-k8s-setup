FROM node:latest as installer
COPY ./juice-shop-goof /juice-shop-goof
WORKDIR /juice-shop-goof
RUN --mount=type=cache,target=node_modules \
    npm i -g typescript ts-node
RUN --mount=type=cache,target=node_modules \
    npm install --legacy-peer-deps
RUN --mount=type=cache,target=node_modules \
    npm dedupe
RUN rm -rf frontend/node_modules
RUN rm -rf frontend/.angular
RUN rm -rf frontend/src/assets
RUN mkdir logs
RUN chown -R 65532 logs
RUN chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/
RUN chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/
RUN rm data/chatbot/botDefaultTrainingData.json || true
RUN rm ftp/legal.md || true
RUN rm i18n/*.json || true

# workaround for libxmljs startup error
FROM node:20-buster as libxmljs-builder
WORKDIR /juice-shop-shop
RUN apt-get update && apt-get install -y build-essential python3
COPY --from=installer ./juice-shop-goof/node_modules ./node_modules
RUN --mount=type=cache,target=node_modules \
  rm -rf node_modules/libxmljs2/build && \
  cd node_modules/libxmljs2 && \
  npm run build

FROM gcr.io/distroless/nodejs20-debian11
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/iuriikogan-snyk/juice-shop-goof"
LABEL io.snyk.containers.image.dockerfile="/Dockerfile"
WORKDIR /juice-shop-goof
COPY --from=installer --chown=65532:0 /juice-shop-goof ./juice-shop-goof
COPY --chown=65532:0 --from=libxmljs-builder ./juice-shop-goof/node_modules/libxmljs2 ./node_modules/libxmljs2
USER 65532
EXPOSE 3000
CMD ["/juice-shop-goof/build/app.js"]
