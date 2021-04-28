# Tencent TKE Kubernetes Distribution

Tencent **tke-k8s-distro** is the kubernetes distribution used by TencentCloud
[TKE](https://cloud.tencent.com/product/tke) product. 
This distro is based on the community [kubernetes](https://github.com/kubernetes/kubernetes),
and includes additional fetaures and fixes.

With this repository, you can build the same versions of k8s components as used in TencentCloud TKE.

## Releases
Following release are supported.

| Release | TKE Version |Base K8s Version | Go version |
| --- | --- | --- | --- |
| 1.20 | v1.20.6-tke.1| v1.20.6 | go 1.15.11+ |

## Build Binaries

`make RELEASE=1.20` 

or 

`make` which will build the latest relase.

The binaries will be placed at `_output/<release>/` directory, and include `kubeadm, kube-apiserver, kube-controller-manager, kubectl, kubelet, kube-proxy, kube-scheduler`