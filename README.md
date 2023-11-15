# Excalifork

Welcome to excalifork!

## Overview

This repository collects forks of the very well known Excalidraw.
Main objective of excalifork is to have a fast way to deploy and build images of
Excalidraw that enable collaboration features.

Sources:

    - https://gitlab.com/kiliandeca/excalidraw-fork
    - https://github.com/alswl/excalidraw-storage-backend/tree/fork
    - https://github.com/alswl/excalidraw/tree/fork

Why not using alswl <https://github.com/alswl/excalidraw-collaboration>? Mainly because
there are too many branches in their submodules and is not updated to use with v0.16 of
Excalidraw. In `docker/excalifork/0001-v0.16.1.patch` you can find modifications applied
(mainly coming from <https://github.com/alswl/excalidraw/tree/fork>).

Following sections describe how to build and deploy excalifork using docker or
kubernetes.

### Docker

#### Prerequisites

- Docker and ansible installed on your system
- A domain to issue SSL certificates
- Use provided Pipfile

#### Usage

1. Clone the repository to your local machine:

```bash
git clone https://github.com/rizlas/excalifork.git
```

2. Navigate to the ansible directory:

```bash
cd excalifork/ansible
```

3. Build docker images:

```bash
ansible-playbook -i inventories/<select_inventory>/hosts.ini build.yml -e domain=yourdomain.tld
```

4. Run the Docker container:

```bash
ansible-playbook -i inventories/<select_inventory>/hosts.ini docker.yml -e domain=yourdomain.tld -e acme_email=myacme@email.com
```

Access Excalifork by opening your browser and navigating to your FQDN.

### Kubernetes

#### Prerequisites

- Kubernetes cluster configured
- `kubectl` installed

> **_NOTE:_** In `ansible/templates/kubernetes_resources.yml.j2` only based resources are provided.
Further tuning of those should be done based on the cluster used, or other
specifications, that cannot be known a priori (e.g. ingress controller, cert-manager...)

#### Deployment

1. Select cluster:

```bash
export KUBECONFIG=path_to_your_kubeconfig
```

2. Expose the service:

```bash
ansible-playbook -i inventories/<select_inventory>/hosts.ini kubernetes.yml
```

Access Excalifork by opening your browser and navigating to your FQDN.

### Ansible

#### Prerequisites

- SSH access to your deployment target

#### Deployment

1. Create/update hosts.ini file in prod inventory with your deployment details.

### Proxy and TLS

TLS is highly suggested cause excalidraw use WSS protocol (do not use self signed
certificates
<https://stackoverflow.com/questions/5312311/secure-websockets-with-self-signed-certificate>).
In docker-compose you'll find <https://github.com/nginx-proxy/acme-companion>.

Proxy is nginx with autobuild configuration thanks to
<https://github.com/nginx-proxy/nginx-proxy>.

## Contributing

Feel free to make pull requests, fork, destroy or whatever you like most. Any criticism
is more than welcome.

## License

This project is licensed under the [MIT License](LICENSE).

<p align="center">
    <img src="https://avatars1.githubusercontent.com/u/8522635?s=96&v=4" />
    <br/>#followtheturtle
</p>
