from flask import Flask
from app import public


def create_app(config_object="app.settings"):
    app = Flask(__name__.split(".")[0])
    app.config.from_object(config_object)
    register_blueprints(app)
    return app


def register_blueprints(app):
    """Register Flask blueprints."""
    app.register_blueprint(public.views.blueprint)
    return None
