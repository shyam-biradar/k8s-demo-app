## Steps to build and run the app
 - Ensure you have Docker installed
 - `git clone https://github.com/shyam-biradar/k8s-demo-app.git`
 - `docker build -t docker.io/trilio/k8s-demo-app:v1 .`
 - 'docker push docker.io/trilio/k8s-demo-app:v1'
 - `docker run -p 8181:80 docker.io/trilio/k8s-demo-app:v1`

## Access web console at http://IP:8181
