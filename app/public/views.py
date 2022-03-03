import socket
from flask import (Blueprint, render_template, request)

blueprint = Blueprint("public", __name__, static_folder="../static")


@blueprint.route("/", methods=["GET"])
def homepage():
    user_agent = request.headers.get('User-Agent')
    hostname = socket.gethostname()
    f = open('./VERSION')
    version = f.read().splitlines()[0]
    f.close()
    return render_template("public/home.html",
                           user_agent=user_agent,
                           hostname=hostname,
                           version=version)
