#!/usr/bin/env bash

sql_dump_dir=${BOO_DB_DUMP_DIR}/sql
sql_proxy_bin="${sql_dump_dir}/cloud-sql-proxy"

ensure_sql_proxy_bin_exists() {
  if [ ! -f "${sql_proxy_bin}" ]; then
    mkdir -p ${sql_dump_dir}

    local current_os="$([ "${OSTYPE}" = "linux-gnu" ] && echo "linux" || echo "darwin")"
    local current_arch="amd64"

    # support only Apple ARM
    if [ "${current_os}" = "darwin" ] && [ "$(arch)" = "arm64" ]; then
      current_arch="arm64"
    fi

    local binary_url="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.11.3/cloud-sql-proxy.${current_os}.${current_arch}"
    echo "Downloading proxy binary: ${binary_url}"

    curl "${binary_url}" -o "${sql_proxy_bin}" || exit
    chmod +x "${sql_proxy_bin}"

    if [ -f "${sql_proxy_bin}" ]; then
      echo_success "Binary saved at ${sql_proxy_bin}"
    else
      echo_error "Error: failed to download sql proxy binary"
      exit 1
    fi
  fi
}

sql_proxy_pid=none

start_sql_proxy() {
  if [ -z "${POSTGRES_INSTANCE+x}" ]; then
    echo "No instance is set. Treating as local instance."
  else
    ensure_sql_proxy_bin_exists

    echo "Starting ${POSTGRES_INSTANCE} proxy..."
    "${sql_proxy_bin}" --auto-iam-authn --port="${POSTGRES_PROXY_PORT}" "${POSTGRES_INSTANCE}"  &
    sql_proxy_pid=$!

    echo "Waiting for proxy to start..."
    sleep 10

    # check if proxy is running
    curl "http://127.0.0.1:${POSTGRES_PROXY_PORT}" &>/dev/null
    if [ "$?" = "52" ]; then
      # proxy started
      echo_success "Proxy started successfully"
    else
      # proxy failed
      echo_error "Error: failed to start proxy"
      exit 1
    fi
  fi
}

stop_sql_proxy() {
  if [ "${sql_proxy_pid}" != "none" ]; then
    kill "${sql_proxy_pid}"
    kill_res=$?
    echo "Stopping sql proxy (code=${kill_res})"
  fi
}

sql_dump_file_path() {
  local server_name=$1
  echo "${sql_dump_dir}/${server_name}.sql"
}

source_deploy_conf_for_sql() {
  source_deploy_conf "${1}"
  PGUSER=$(gcloud config list account --format "value(core.account)")
  PGUSER=$(node -p "encodeURIComponent('${PGUSER}').replace('.gserviceaccount.com','')")
  POSTGRES_URL="postgresql://${PGUSER}@127.0.0.1:${POSTGRES_PROXY_PORT}/${POSTGRES_DB_NAME}"
}
