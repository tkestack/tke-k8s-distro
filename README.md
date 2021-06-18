# TKE Kubernetes Distro

**Tencent TKE Kubernetes Distro(tke-k8s-distro)** is a kubernetes distribution used by Tencent Kubernetes Engine(TKE) to create secure and reliable Kubernetes clusters. Users can rely on tke-k8s-distro to run Kubernetes services that are exactly the same as TKE on self-built or hosted IDC, physical machines or virtual machines. tke-k8s-distro clusters can be seamlessly integrated with TKE to buiild hybrid cloud. Users can extend worloads in private IDC to TKE through tke-k8s-distro clusters, and take advantage of the flexibility of TKE, EKS and other Tencent cloud services.

## Releases
| Release | TKE Version | Kubernetes Version | Go version |
| --- | --- | --- | --- |
| 1.20 | v1.20.6-tke.1 | v1.20.6 | go 1.15.11+ |

## How to build
`make RELEASE=1.20` 
or 
`make` which will build the latest relase.

The binaries will be placed at `_output/<release>/` directory, and include `kubeadm, kube-apiserver, kube-controller-manager, kubectl, kubelet, kube-proxy, kube-scheduler`

## License

This project is licensed under the [Apache-2.0 License](LICENSE).