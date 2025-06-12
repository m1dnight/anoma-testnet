# Anoma

This is the backend implementation of the Anoma testnet application.

To run this locally, you need to use a Twitter application. Ask Christophe for the client id and client secret for his application, to make it all a bit easier to use.

## 💾 From source

```shell
export TWITTER_CLIENT_ID="client_id_here"
export TWITTER_CLIENT_SECRET="client_secret_here"
```

Then, to use the prototype `index.html`, update the `script.js` file based on the environment variables.

```shell
sed -i "s/twitterClientId: '[^']*'/twitterClientId: '$TWITTER_CLIENT_ID'/" priv/static/script.js
```

Start a Docker database for this repository.

```shell
cd scripts && docker compose up -d db && cd ..
```

Run the application and open the webpage.

```shell
# create the database (this will nuke existing databases)
mix ecto.reset
# run the server
iex -S mix phx.server
```

## 🐳 Docker

Make sure you update the `TWITTER_CLIENT*` values in the `docker-compose.yml` file.
```shell
cd scripts && docker compose --build up
```


**⚠️ Important ⚠️**:  the meta data of a user is currently hardcoded to avoid hitting the twitter rate limit. Update this if you want to use real meta data. Toggle the boolean value at `lib/anoma_web/twitter.ex:116` to disable the cache.

Navigate to [http://localhost:4000/index.html](http://localhost:4000/index.html)