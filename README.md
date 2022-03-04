<p align="center"><img src="https://raw.githubusercontent.com/test-org-cicd/flask-app-project/main/docs/_static/flask-app.jpg" /></p>


# Flask App Project

This is a simple demo flask application that greet user with welcome message. The application is containarized using **Dockerfile** and integrate with Jenkins for CI using **Jenkinsfile**.


## Installing Flask App

**Python3 is required.**

The application has been develop and tested on `Python 3.10.2`

0. Clone the git repository and enter into the folder

```
git clone https://github.com/test-org-cicd/flask-app-project.git
cd flask-app-project
```

1. Create and activate a virtual environment:

```
pip install pipenv
pipenv shell
```

2. Install the dependencies

```
pipenv install --dev
```

## Run Test

1. For testing `pytest` is being used
```
pytest -v
```

## Pre-commit Hook
The application is using some pre-commit hooks for SAST, Secret Leak Protection, Style Guide and Linting. The tools used are:
1. [Bandit](https://bandit.readthedocs.io/en/latest/)
2. [Detect-secrets](https://github.com/Yelp/detect-secrets)
3. [Flake8](https://github.com/pycqa/flake8)
4. [Yapf](https://github.com/google/yapf)

To run all pre-commit type
```
pipenv run pre-commit run --all-files
```

## QuickStart

To start the application do the following

```
export FLASK_ENV=development
export FLASK_APP=autoapp.py
flask run --host=0.0.0.0
```

Now you can browse the application at `http://localhost:5000`

## PRODUCTION DEPLOYMENT

For production deployment the CI/CD pipelin is being used. **Jenkins** is used to complete the CI(Continous Integration) process and for CD(Continuous Deployment) **ArgoCD** is being used.

**Jenkins steps**

<p align="center"><img src="https://raw.githubusercontent.com/test-org-cicd/flask-app-project/main/docs/_static/flask-app-jenkins-pipeline.png" /></p>

1. Build
    - Install all the pipenv dev dependencies
    - Run all pre-commit
    - Run all pytest
2. SAST
    - Dependency Check
        - Integrate with [Dependency Track](https://dependencytrack.org/) for software composition analysis. It will upload [CycloneDX](https://cyclonedx.org/) SBOM to Dependency Track.
        - Integrate with [Sonarqube](https://www.sonarqube.org/) for `Code Quality and Code Security`.
3. Docker Image With Kaniko
    - Build Image using [Kaniko](https://github.com/GoogleContainerTools/kaniko) tool within the container. For this project the container image is being pushed to `Amazon ECR`. The container image is being tagged by reading the `VERSION` file from the code repo.
4. Deploy To Staging Using ArgoCD
    - In this stage it reads the `VERSION` file and update the kubernetes manifest file using [Kustomize](https://kustomize.io/) in the seperate git repo for this application at [https://github.com/test-org-cicd/flask-app-deploy](https://github.com/test-org-cicd/flask-app-deploy). This manifest repo is being monitored by **ArgoCD** for any changes and deploy to `Kubernetes` cluster accordingly.

## LICENSE

The Flask Application is GNU GPL3 licensed. See the LICENSE file for details.
