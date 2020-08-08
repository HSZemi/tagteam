from datetime import datetime, timedelta

from bottle import get, post, run, request, Bottle, HTTPError

from pathlib import Path
import json

app = application = Bottle()
STATE = {
    "marco": {
        "pro": "MbL",
        "noob": "Snippy",
        "secret": "secret",
        "proActiveUntil": datetime.now(),
        "proCooldownUntil": datetime.now()
    },
    "polo": {
        "pro": "Hera",
        "noob": "Tommie",
        "secret": "secret",
        "proActiveUntil": datetime.now(),
        "proCooldownUntil": datetime.now()
    },
    "secret": "secret",
    "speed": 1.7
}


def load_config():
    config_file = Path('config.json')
    if config_file.exists():
        conf = json.loads(config_file.read_text())
        STATE['marco']['pro'] = conf['marco']['pro']
        STATE['marco']['noob'] = conf['marco']['noob']
        STATE['marco']['secret'] = conf['marco']['secret']
        STATE['polo']['pro'] = conf['polo']['pro']
        STATE['polo']['noob'] = conf['polo']['noob']
        STATE['polo']['secret'] = conf['polo']['secret']
        STATE['secret'] = conf['secret']
        STATE['speed'] = conf['speed']


load_config()


def transformed_state():
    now = datetime.now()
    return {
        "marco": {
            "pro": STATE['marco']['pro'],
            "noob": STATE['marco']['noob'],
            "proActiveFor": max((STATE['marco']['proActiveUntil'] - now).total_seconds() * STATE['speed'], 0),
            "proCooldown": max((STATE['marco']['proCooldownUntil'] - now).total_seconds() * STATE['speed'], 0)
        },
        "polo": {
            "pro": STATE['polo']['pro'],
            "noob": STATE['polo']['noob'],
            "proActiveFor": max((STATE['polo']['proActiveUntil'] - now).total_seconds() * STATE['speed'], 0),
            "proCooldown": max((STATE['polo']['proCooldownUntil'] - now).total_seconds() * STATE['speed'], 0)
        }
    }


@app.get('/status')
def status():
    return transformed_state()


@app.post('/activate')
def activate():
    team = request.forms.get('team')
    secret = request.forms.get('secret')
    now = datetime.now()
    if team in STATE:
        if secret != STATE[team]['secret']:
            raise HTTPError(status=403)
        if STATE[team]['proCooldownUntil'] < now:
            STATE[team]['proActiveUntil'] = now + timedelta(0, 3 * 60 / STATE['speed'])
            STATE[team]['proCooldownUntil'] = now + timedelta(0, 8 * 60 / STATE['speed'])


@app.post('/reset')
def reset():
    secret = request.forms.get('secret')
    team = request.forms.get('team')
    now = datetime.now()
    if secret == STATE['secret']:
        if team in STATE:
            STATE[team]['proActiveUntil'] = now
            STATE[team]['proCooldownUntil'] = now
        elif team is None:
            for team in ('marco', 'polo'):
                STATE[team]['proActiveUntil'] = now
                STATE[team]['proCooldownUntil'] = now
    else:
        raise HTTPError(status=403)


@app.post('/config')
def config():
    secret = request.forms.get('secret')
    if secret != STATE['secret']:
        raise HTTPError(status=403)

    configuration = {
        "marco": {
            "pro": "pro",
            "noob": "noob",
            "secret": "secret"
        },
        "polo": {
            "pro": "pro",
            "noob": "noob",
            "secret": "secret"
        },
        "secret": "secret",
        "speed": 1.7
    }
    config_file = Path('config.json')
    if config_file.exists():
        configuration = json.loads(config_file.read_text())
    team = request.forms.get('team')
    newsecret = request.forms.get('newsecret')
    speed = request.forms.get('speed')
    pro = request.forms.get('pro')
    noob = request.forms.get('noob')

    if team is None:
        if newsecret is not None:
            configuration['secret'] = newsecret
            STATE['secret'] = newsecret
    elif team in ('marco', 'polo'):
        if newsecret is not None:
            configuration[team]['secret'] = newsecret
            STATE[team]['secret'] = newsecret
        if pro is not None:
            configuration[team]['pro'] = pro
            STATE[team]['pro'] = pro
        if noob is not None:
            configuration[team]['noob'] = noob
            STATE[team]['noob'] = noob
    if speed is not None:
        try:
            configuration['speed'] = float(speed)
            STATE['speed'] = float(speed)
        except ValueError:
            pass

    config_file.write_text(json.dumps(configuration, indent=4))


def main():
    run(app=app, host='localhost', port=8080, debug=True, reloader=True)


if __name__ == '__main__':
    main()
