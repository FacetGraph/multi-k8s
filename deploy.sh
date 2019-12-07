printf "%s\n%s\nus-east-1\njson" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" | aws configure --profile default
aws eks --region us-east-1 update-kubeconfig --name multi-cluster
echo "$DOCKERHUB_PASS" | docker login --username primarydeploy --password-stdin
docker build -t matthoyle/multi-client:latest -t matthoyle/multi-client:$GITHUB_SHA -f ./client/Dockerfile ./client
docker build -t matthoyle/multi-server:latest -t matthoyle/multi-server:$GITHUB_SHA -f ./server/Dockerfile ./server
docker build -t matthoyle/multi-worker:latest -t matthoyle/multi-worker:$GITHUB_SHA -f ./worker/Dockerfile ./worker
docker push matthoyle/multi-client:latest
docker push matthoyle/multi-server:latest
docker push matthoyle/multi-worker:latest
docker push matthoyle/multi-client:$GITHUB_SHA
docker push matthoyle/multi-server:$GITHUB_SHA
docker push matthoyle/multi-worker:$GITHUB_SHA

kubectl apply -f k8s
kubectl set image deployments/server-deployment server=matthoyle/multi-server:$GITHUB_SHA
kubectl set image deployments/client-deployment client=matthoyle/multi-client:$GITHUB_SHA
kubectl set image deployments/worker-deployment worker=matthoyle/multi-worker:$GITHUB_SHA
