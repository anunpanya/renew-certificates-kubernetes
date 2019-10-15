SSL_KUBERNETES=/etc/kubernetes/pki
SSL_CONF_PATH=./conf
SSL_PATH=./ssl
SSL_PATH_ETCD=$SSL_PATH/etcd
HOST_CLUSTER=kube-test
HOST_CLUSTER_IP=10.128.0.2
HOST_CLUSTER_PUBLIC=35.224.227.89
HOST_NETWORK=10.96.0.1

echo "Prepare..."
mkdir -p $SSL_PATH_ETCD

echo "Generate configure."
rm -r $SSL_CONF_PATH
cp -rf ./tmpl $SSL_CONF_PATH
sed -i 's/{HOST_NETWORK}/'$HOST_NETWORK'/g' ./conf/*
sed -i 's/{HOST_CLUSTER}/'$HOST_CLUSTER'/g' ./conf/*
sed -i 's/{HOST_CLUSTER_IP}/'$HOST_CLUSTER_IP'/g' ./conf/*
sed -i 's/{HOST_CLUSTER_PUBLIC}/'$HOST_CLUSTER_PUBLIC'/g' ./conf/*
#egrep -r "IP.|DNS." conf/*
egrep -r "$HOST_NETWORK|$HOST_CLUSTER|$HOST_CLUSTER_IP|$HOST_CLUSTER_PUBLIC" conf/*

echo "Generate ca."
openssl genrsa -out $SSL_PATH/ca.key 2048
openssl req -x509 -new -nodes -key $SSL_PATH/ca.key -days 36500 -out $SSL_PATH/ca.crt -subj "/CN=kubernetes" -extensions v3_ext -config $SSL_CONF_PATH/openssl.ca.cnf
#openssl x509 -text -noout -in $SSL_PATH/ca.crt

echo "Generate apiserver."
openssl genrsa -out $SSL_PATH/apiserver.key 2048
openssl req -new -key $SSL_PATH/apiserver.key -out $SSL_PATH/apiserver.csr -subj "/CN=kube-apiserver" -config $SSL_CONF_PATH/openssl.apiserver.cnf
openssl x509 -req -in $SSL_PATH/apiserver.csr -CA $SSL_PATH/ca.crt -CAkey $SSL_PATH/ca.key -CAcreateserial -out $SSL_PATH/apiserver.crt -days 36500 -extensions v3_ext -extfile $SSL_CONF_PATH/openssl.apiserver.cnf
#openssl x509  -noout -text -in $SSL_PATH/apiserver.crt

echo "Generate apiserver kubelet client."
openssl genrsa -out $SSL_PATH/apiserver-kubelet-client.key 2048
openssl req -new -key $SSL_PATH/apiserver-kubelet-client.key -out $SSL_PATH/apiserver-kubelet-client.csr -subj "/O=system:masters/CN=kube-apiserver-kubelet-client" -config $SSL_CONF_PATH/openssl.apiserver-kubelet-client.cnf
openssl x509 -req -in $SSL_PATH/apiserver-kubelet-client.csr -CA $SSL_PATH/ca.crt -CAkey $SSL_PATH/ca.key -CAcreateserial -out $SSL_PATH/apiserver-kubelet-client.crt -days 36500 -extensions v3_ext -extfile $SSL_CONF_PATH/openssl.apiserver-kubelet-client.cnf
#openssl x509  -noout -text -in $SSL_PATH/apiserver-kubelet-client.crt

echo "Generate front proxy ca."
openssl genrsa -out $SSL_PATH/front-proxy-ca.key 2048
openssl req -x509 -new -nodes -key $SSL_PATH/front-proxy-ca.key -days 36500 -out $SSL_PATH/front-proxy-ca.crt -subj "/CN=front-proxy-ca" -extensions v3_ext -config $SSL_CONF_PATH/openssl.front-proxy-ca.cnf
#openssl x509  -noout -text -in $SSL_PATH/front-proxy-ca.crt

echo "Generate front proxy client."
openssl genrsa -out $SSL_PATH/front-proxy-client.key 2048
openssl req -new -key $SSL_PATH/front-proxy-client.key -out $SSL_PATH/front-proxy-client.csr -subj "/CN=front-proxy-client" -config $SSL_CONF_PATH/openssl.front-proxy-client.cnf
openssl x509 -req -in $SSL_PATH/front-proxy-client.csr -CA $SSL_PATH/front-proxy-ca.crt -CAkey $SSL_PATH/front-proxy-ca.key -CAcreateserial -out $SSL_PATH/front-proxy-client.crt -days 36500 -extensions v3_ext -extfile $SSL_CONF_PATH/openssl.front-proxy-client.cnf
#openssl x509  -noout -text -in $SSL_PATH/front-proxy-client.crt

echo "Generate etcd ca:"
openssl genrsa -out $SSL_PATH_ETCD/ca.key 2048
openssl req -x509 -new -nodes -key $SSL_PATH_ETCD/ca.key -days 36500 -out $SSL_PATH_ETCD/ca.crt -subj "/CN=etcd-ca" -extensions v3_ext -config $SSL_CONF_PATH/openssl.etcd-ca.cnf
#openssl x509 -text -noout -in $SSL_PATH_ETCD/ca.crt

echo "Generate apiserver etcd client."
openssl genrsa -out $SSL_PATH/apiserver-etcd-client.key 2048
openssl req -new -key $SSL_PATH/apiserver-etcd-client.key -out $SSL_PATH/apiserver-etcd-client.csr -subj "/O=system:masters/CN=kube-apiserver-etcd-client" -config $SSL_CONF_PATH/openssl.apiserver-etcd-client.cnf
openssl x509 -req -in $SSL_PATH/apiserver-etcd-client.csr -CA $SSL_PATH_ETCD/ca.crt -CAkey $SSL_PATH_ETCD/ca.key -CAcreateserial -out $SSL_PATH/apiserver-etcd-client.crt -days 36500 -extensions v3_ext -extfile $SSL_CONF_PATH/openssl.apiserver-etcd-client.cnf
#openssl x509  -noout -text -in $SSL_PATH/apiserver-etcd-client.crt

echo "Generate healthcheck client."
openssl genrsa -out $SSL_PATH_ETCD/healthcheck-client.key 2048
openssl req -new -key $SSL_PATH_ETCD/healthcheck-client.key -out $SSL_PATH_ETCD/healthcheck-client.csr -subj "/O=system:masters/CN=kube-etcd-healthcheck-client" -config $SSL_CONF_PATH/openssl.healthcheck-client.cnf
openssl x509 -req -in $SSL_PATH_ETCD/healthcheck-client.csr -CA $SSL_PATH_ETCD/ca.crt -CAkey $SSL_PATH_ETCD/ca.key -CAcreateserial -out $SSL_PATH_ETCD/healthcheck-client.crt -days 36500 -extensions v3_ext -extfile $SSL_CONF_PATH/openssl.healthcheck-client.cnf
#openssl x509  -noout -text -in $SSL_PATH_ETCD/healthcheck-client.crt

echo "Generate peer."
openssl genrsa -out $SSL_PATH_ETCD/peer.key 2048
openssl req -new -key $SSL_PATH_ETCD/peer.key -out $SSL_PATH_ETCD/peer.csr -subj "/CN=kube-test" -config $SSL_CONF_PATH/openssl.peer.cnf
openssl x509 -req -in $SSL_PATH_ETCD/peer.csr -CA $SSL_PATH_ETCD/ca.crt -CAkey $SSL_PATH_ETCD/ca.key -CAcreateserial -out $SSL_PATH_ETCD/peer.crt -days 36500 -extensions v3_ext -extfile $SSL_CONF_PATH/openssl.peer.cnf
#openssl x509  -noout -text -in $SSL_PATH_ETCD/peer.crt

echo "Generate server."
openssl genrsa -out $SSL_PATH_ETCD/server.key 2048
openssl req -new -key $SSL_PATH_ETCD/server.key -out $SSL_PATH_ETCD/server.csr -subj "/CN=kube-test" -config $SSL_CONF_PATH/openssl.server.cnf
openssl x509 -req -in $SSL_PATH_ETCD/server.csr -CA $SSL_PATH_ETCD/ca.crt -CAkey $SSL_PATH_ETCD/ca.key -CAcreateserial -out $SSL_PATH_ETCD/server.crt -days 36500 -extensions v3_ext -extfile $SSL_CONF_PATH/openssl.server.cnf
#openssl x509  -noout -text -in $SSL_PATH_ETCD/server.crt

echo "Set permission."
chmod 644 $SSL_PATH/*.key $SSL_PATH_ETCD/*.key
chmod 600 $SSL_PATH/*.crt $SSL_PATH_ETCD/*.crt
cp $SSL_PATH/*.key $SSL_KUBERNETES/
cp $SSL_PATH/*.crt $SSL_KUBERNETES/
cp $SSL_PATH_ETCD/*.key $SSL_KUBERNETES/etcd/
cp $SSL_PATH_ETCD/*.crt $SSL_KUBERNETES/etcd/

echo "Generate kubeconfig."
rm -f /etc/kubernetes/*.conf
rm -r /var/lib/kubelet/pki
kubeadm init phase kubeconfig all
mkdir -p /root/.kube
cp -f /etc/kubernetes/admin.conf /root/.kube/config
chmod 600 /root/.kube/config
cat /etc/kubernetes/admin.conf > /home/ubuntu/.kube/config

echo "Restart service kubernetes cluster."
systemctl daemon-reload
sleep 1
systemctl stop kubelet
sleep 1
systemctl start kubelet
sleep 1
systemctl enable kubelet
systemctl stop docker
sleep 1
systemctl start docker

echo "Check service with command line:"
echo "  $ kubectl get nodes"
echo "  $ kubectl get pod --all-namespaces"
