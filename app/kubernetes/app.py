from flask import Flask
from flask import render_template
from flask import jsonify
from flask import request

import json
import os

app = Flask(__name__)

DATA_FILE = "data/hall_of_fame.json"


def load_players():

    if not os.path.exists(DATA_FILE):
        return []

    try:

        with open(DATA_FILE, encoding="utf-8") as file:
            return json.load(file)

    except json.JSONDecodeError:

        return []


def save_players(players):

    with open(DATA_FILE, "w", encoding="utf-8") as file:

        json.dump(
            players,
            file,
            indent=4,
            ensure_ascii=False
        )


@app.route("/")
def index():

    return render_template("index.html")


@app.route("/api/ranking")
def ranking():

    return jsonify(load_players())


@app.route("/api/player", methods=["POST"])
def create_player():

    data = request.get_json(silent=True)

    if not data:

        return jsonify({
            "success": False,
            "message": "Petición inválida."
        }), 400

    username = data["user"].strip()

    players = load_players()

    # Buscar si ya existe
    for player in players:

        if player["user"].lower() == username.lower():

            return jsonify({
                "success": True,
                "existing": True,
                "user": player
            })

    # Si NO existe, crearlo
    new_player = {

        "user": username,
        "wins": 0

    }

    players.append(new_player)

    save_players(players)

    return jsonify({

        "success": True,
        "existing": False,
        "user": new_player

    })

@app.route("/api/win", methods=["POST"])
def register_win():

    data = request.get_json(silent=True)

    if not data:

        return jsonify({

            "success": False

        }), 400

    username = data["user"]

    players = load_players()

    for player in players:

        if player["user"].lower() == username.lower():

            player["wins"] += 1

            save_players(players)

            return jsonify({

                "success": True,

                "wins": player["wins"]

            })

    return jsonify({

        "success": False

    }), 404

if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )