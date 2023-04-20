#!/usr/bin/env bash

sql_dump_dir=${BOO_DB_DUMP_DIR}/sql
sql_proxy_bin="${sql_dump_dir}/cloud_sql_proxy"

POSTGRE_PROXY_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PROXY_PORT}/${POSTGRES_DB}"

ensure_sql_proxy_bin_exists() {
  if [ ! -f "${sql_proxy_bin}" ]; then
    mkdir -p ${sql_dump_dir}

    echo "Downloading proxy binary"
    local current_arch="$([ "${OSTYPE}" = "linux-gnu" ] && echo "linux" || echo "darwin")"
    curl -o "${sql_proxy_bin}" "https://dl.google.com/cloudsql/cloud_sql_proxy.${current_arch}.amd64"
    chmod +x ${sql_proxy_bin}

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
    "${sql_proxy_bin}" -verbose=true -instances="${POSTGRES_INSTANCE}=tcp:${POSTGRES_PROXY_PORT}" &
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
