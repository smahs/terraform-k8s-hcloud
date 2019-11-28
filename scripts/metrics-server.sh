#!/bin/bash
set -eux

cat > patch-metrics-server-deployment.yaml <<EOF
spec:
  template:
    spec:
      containers:
      - name: metrics-server
        args:
          - --cert-dir=/tmp
          - --secure-port=4443
          - --kubelet-insecure-tls
          - --kubelet-preferred-address-types=InternalIP
EOF

git clone https://github.com/kubernetes-incubator/metrics-server.git
kubectl apply -f metrics-server/deploy/1.8+/

kubectl patch deployment --namespace kube-system \
    metrics-server -p "$(cat patch-metrics-server-deployment.yaml)"

rm -r metrics-server patch-metrics-server-deployment.yaml
