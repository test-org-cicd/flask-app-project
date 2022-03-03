FROM python:3.10.2-slim-buster

ARG FLASK_APP=autoapp.py
ARG FLASK_ENV=production
ARG GUNICORN_WORKERS=2

WORKDIR /app

RUN useradd -m sid
RUN chown -R sid:sid /app
USER sid

ENV PATH="/home/sid/.local/bin:${PATH}"
ENV FLASK_APP=${FLASK_APP}
ENV FLASK_ENV=${FLASK_ENV}
ENV GUNICORN_WORKERS=${GUNICORN_WORKERS}
ENV LOG_LEVEL=debug

COPY autoapp.py .
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisord_programs /etc/supervisor/conf.d
COPY --chown=sid:sid shell_scripts/ ./shell_scripts

COPY --chown=sid:sid ./app/ ./app
COPY ["Pipfile", "Pipfile.lock", "."]
COPY ["VERSION", "."]

RUN pip install --no-cache pipenv
RUN pipenv install

EXPOSE 5000
ENTRYPOINT ["/bin/bash", "shell_scripts/supervisord_entrypoint.sh"]
CMD ["-c", "/etc/supervisor/supervisord.conf"]
