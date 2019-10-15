# renew-certificates-kubernetes

### How to use

- edit config in renew.sh (HOSTNAME_MASTER, IP_ADDR_MASTER, IP_ADDR_MASTER_PUBLIC and IP_ADDR_NETWORK)
```
$ nano renew.sh
$ ./renew.sh
```

- check status kubernetes cluster
```
$ kubectl get nodes
$ kubectl get pods --all-namespaces
```

- pod status running is ok
- Good luck!!!
