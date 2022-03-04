pipeline {
    agent {
        kubernetes {
            inheritFrom 'python'
            yaml '''
      spec:
        containers:
        - name: kaniko
          image: gcr.io/kaniko-project/executor:debug
          command:
          - sleep
          args:
          - 9999999
          volumeMounts:
          - name: docker-config
            mountPath: /kaniko/.docker/
          - name: aws-secret
            mountPath: /root/.aws/
        - name: argo-tools
          image: argoproj/argo-cd-ci-builder:v1.0.0
          command:
          - cat
          tty: true
        volumes:
        - name: docker-config
          configMap:
            name: docker-config
        - name: aws-secret
          secret:
            secretName: aws-secret
'''
        }
    }

    stages {
        stage('Build') {
            steps {
                container('python3-10') {
                    sh '''
                        apt-get update
                        apt-get install git -y
                        pip install pipenv
                        pipenv install --dev
                        pipenv run pre-commit run --all-files
                        pipenv run pytest -v
                    '''
                }
            }
        }
        stage('SAST') {
            parallel{
                stage('Dependency Check') {
                    steps {
                        container('python3-10') {
                            sh '''
                                pip install pipenv
                                pipenv install pip-audit --dev
                                pipenv run pip-audit -f cyclonedx-xml > bom.xml
                            '''
                            withCredentials([string(credentialsId: 'dt-api-key', variable: 'API_KEY')]) {
                                dependencyTrackPublisher artifact: 'bom.xml', autoCreateProjects: true, projectName: 'flask-app-dependency', projectVersion: 'flask-app-dependency', synchronous: true, dependencyTrackApiKey: API_KEY
                            }
                        }
                    }
                }
                stage('Sonarqube') {
                    steps {
                        container('sonar-scanner-4-7') {
                            withSonarQubeEnv('Sonarqube') {
                                sh """
                                    sonar-scanner \
                                        -Dsonar.projectKey=flask-app-sast \
                                        -Dsonar.sources=. \
                                        -Dsonar.host.url=${SONAR_HOST_URL} \
                                        -Dsonar.login=${SONAR_AUTH_TOKEN}
                                """
                            }
                        }
                    }
                }
            }
        }
        stage('Docker Image With Kaniko') {
            steps {
                container('kaniko') {
                        sh """
                            VERSION=\$(cat VERSION)
                            /kaniko/executor --context `pwd` --destination ${IMAGE_REPO}:\$VERSION
                        """
                }
            }
        }
        stage('Deploy To Staging Using ArgoCD') {
            steps {
                container('argo-tools') {
                    withCredentials([string(credentialsId: 'github', variable: 'GIT_TOKEN')]) {
                        sh """
                            VERSION=\$(cat VERSION)
                            GIT_URL=https://${GIT_TOKEN}@github.com/test-org-cicd/flask-app-deploy.git
                            git clone ${GIT_URL}
                            cd flask-app-deploy
                            cd ./stage && kustomize edit set image ${IMAGE_REPO}:\$VERSION
                            git commit -am 'Publish new version' && git push ${GIT_URL} || echo 'no changes'
                        """
                    }
                }
            }
        }
    }
}
