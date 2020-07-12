{
  "name": "kuma-marketplace-app",
  "version": "0.1.0",
  "description": "A demo app to illustrate the capabilities and advantages of Kuma.",
  "scripts": {
    "setup": "(cd app && npm install); (cd api && npm install)",
    "api:postgresql": "docker run --rm -p 5432:5432 --name kuma-postgres -e POSTGRES_USER=kumademo -e POSTGRES_PASSWORD=kumademo -e POSTGRES_DB=kumademo kvn0218/postgres:latest",
    "api:redis": "docker run --rm -p 6379:6379 --name kuma-redis kvn0218:kuma-redis",
    "api:start": "cd api && npm run start",
    "app:start": "cd app && npm run serve",
    "app:build": "cd app && npm run build"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/kumahq/kuma-demo.git"
  },
  "keywords": [
    "service-mesh",
    "kuma",
    "kong"
  ],
  "license": "Apache-2.0",
  "bugs": {
    "url": "https://github.com/kumahq/kuma-demo/issues"
  },
  "homepage": "https://github.com/kumahq/kuma-demo#readme"
}
