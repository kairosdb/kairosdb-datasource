ARG GRAFANA_VERSION="latest"

FROM grafana/grafana:${GRAFANA_VERSION}-ubuntu

USER root

# Set DEBIAN_FRONTEND=noninteractive in environment at build-time
ARG DEBIAN_FRONTEND=noninteractive

ARG GF_INSTALL_IMAGE_RENDERER_PLUGIN="true"

RUN if [ $GF_INSTALL_IMAGE_RENDERER_PLUGIN = "true" ]; then \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y chromium-browser && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/grafana/tools/phantomjs; \
fi

USER grafana

ENV GF_RENDERER_PLUGIN_CHROME_BIN="/usr/bin/chromium-browser"

RUN if [ $GF_INSTALL_IMAGE_RENDERER_PLUGIN = "true" ]; then \
    grafana-cli \
        --pluginsDir "$GF_PATHS_PLUGINS" \
        --pluginUrl https://github.com/grafana/grafana-image-renderer/releases/latest/download/plugin-linux-x64-glibc-no-chromium.zip \
        plugins install grafana-image-renderer; \
fi

ARG GF_INSTALL_PLUGINS="grafana-clock-panel,grafana-simple-json-datasource"

RUN if [ ! -z "${GF_INSTALL_PLUGINS}" ]; then \
    OLDIFS=$IFS; \
        IFS=','; \
    for plugin in ${GF_INSTALL_PLUGINS}; do \
        IFS=$OLDIFS; \
        grafana-cli --pluginsDir "$GF_PATHS_PLUGINS" plugins install ${plugin}; \
    done; \
fi


# chown database folder to the grafana user to be able to mount a named volume to it
RUN mkdir -p "/var/lib/grafana/database" && \
  chown -R grafana:grafana "/var/lib/grafana/database"

USER grafana

COPY dist $GF_PATHS_PLUGINS/kairosdb-datasource

# add provisioning information
# ADD ./docker/provisioning /etc/grafana/provisioning
# ADD ./dashboards $GF_PATHS_DATA/dashboards

# override configuration with env variables
ENV GF_SECURITY_ADMIN_PASSWORD=kairosdb
#ENV GF_USERS_DEFAULT_THEME=light
ENV GF_SERVER_ENABLE_GZIP=true

# set up tls by default
#ENV GF_SERVER_PROTOCOL=https
#ENV GF_SERVER_CERT_FILE=$GF_PATHS_HOME/.tls/grafana.crt
#ENV GF_SERVER_CERT_KEY=$GF_PATHS_HOME/.tls/grafana.key

# move Grafana database to a separate path to enable specifying a persistent volume just for the db
ENV GF_DATABASE_PATH="database/grafana.db"
