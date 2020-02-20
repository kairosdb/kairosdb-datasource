Starting in Grafana 3.x the KairosDB data source is no longer included out of the box and is maintained here (currently tested against Grafana v6.6.0).

## Overview
This [data source](https://grafana.com/docs/grafana/latest/plugins/developing/datasources/) plugin consists of two components: a frontend and a backend.

The backend plugin provides support for [alerts](https://grafana.com/docs/alerting/rules), but is not required to use the frontend browser-based KairosDB connectivity.

## Install to Grafana plugins directory

Copy the plugin distribution directory (`./dist`) to the correctly named plugin directory as a child of the grafana plugins directory (eg `cp ./dist /var/lib/grafana/plugins/kairosdb-datasource`). This enables the frontend plugin and backend datasource proxy (enabled by configuring a KairosDB Datasource as "Access: Server"). The pre-compiled backend plugin supports linux-amd64 and macos (darwin-amd64). If you are running grafana on a different architecture you will need to compile the backend go project yourself.

## Build
### Frontend

If building only the front end, the plugin can be cloned anywhere and built:

```
git clone https://github.com/grafana/kairosdb-datasource
cd kairosdb-datasource
make frontend
```

The `./dist` directory can then be copied to your Grafana plugins directory:

```
cp /dist /var/lib/grafana/plugins/kairosdb-datasource
```

The alerting functionality will not be available without deploying the backend compiled binary.

### Backend (Alerts)

If you wish to build the backend plugin for your environment, your project must be setup within a [Go workspace](https://golang.org/doc/code.html#Workspaces).

Ensure your GOPATH environment variable points to your workspace:

```
export GOPATH=$HOME/go
cd $GOPATH/src/github.com/kairosdb
git clone https://github.com/kairosdb/kairosdb-datasource
cd kairosdb-datasource
# vendor dependencies are managed via "dep ensure"
make backend
```

This will attempt to build both the linux and macos binaries. The `./dist` directory can then be copied to your Grafana plugins directory:

```
cp /dist /var/lib/grafana/plugins/kairosdb-datasource
```
## Docker

A custom grafana image can built which includes the kairosdb plugin. After the above build steps have been completed:
```
make docker
docker run -d -p 3000:3000 --name=grafana grafana-kairosdb:latest
```
The default login is admin:kairosdb. There are several build options that can be overridden. The base image was taken from [building-a-custom-grafana-image](https://grafana.com/docs/grafana/latest/installation/docker/#building-a-custom-grafana-image).
