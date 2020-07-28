# tagteam
A small helper program for tag team matches

## Setup

- Run the server somewhere and set the right names in its `config.json`
- Adapt the server url in `tagteam.au3` and compile it
- Replace `marco-on.jpg`, `marco-off.jpg`, `polo-on.jpg`, and `polo-off.jpg` with suitable images
- Spectators and pros use the compiled `tagteam.exe` without the ini file
- Noobs each get a special version with a custom `tagteam.ini` which includes their team and the configured secret for their team

## Configuration

Change the secret:

```sh
http --form https://example.org/tagteam/config secret=wololo newsecret=tilbardaga
```


Set the speed:

```sh
http --form https://example.org/tagteam/config secret=wololo speed=1.5
```


Set names:

```sh
http --form https://example.org/tagteam/config secret=wololo team=marco pro=Hera
http --form https://example.org/tagteam/config secret=wololo team=marco noob=Tommie
http --form https://example.org/tagteam/config secret=wololo team=polo pro=MbL
http --form https://example.org/tagteam/config secret=wololo team=polo pro=azure_sentry
```


Set team secrets:

```sh
http --form https://example.org/tagteam/config secret=wololo team=marco newsecret=arbalester
http --form https://example.org/tagteam/config secret=wololo team=polo newsecret=mangonel
```

## Usage

Activate countdowns:

```sh
http --form https://example.org/tagteam/activate team=marco secret=arbalester
http --form https://example.org/tagteam/activate team=polo secret=mangonel
```

Reset countdowns:

```sh
http --form https://example.org/tagteam/reset secret=wololo team=marco
http --form https://example.org/tagteam/reset secret=wololo team=polo
http --form https://example.org/tagteam/reset secret=wololo
```
