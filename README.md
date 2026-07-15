# MongoDB Scripts Toolkit

Features:

- Multiple configurations support
- Multiple deployment environment support
- Additional useful actions that work at context of specific server
- Custom actions support

Super useful for lazy people: configured once - use any time.

Some commands should be executed from Meteor project's root directory (where `.meteor` is located).

Looks for configurations at `../config/<configuration-name>` or where `BOO_CONFIG_ROOT` from `.boorc` points to.

## Installation

```
npm install -g https://github.com/trsdln/boo.git
```

## Configuration example

`../config/production/settings.json`:

```
{
  "comment": "your application settings here"
}
```

`../config/production/boo.conf`:

```
# Deployment configuration example for Meteor Galaxy server

SERVER_DESCRIPTION="Production server"
SERVER_TYPE="galaxy"
VERIFY_TIMEOUT=20

MONGO_URL="mongodb://user:pass@localhost:27017/meteor"

DEPLOY_HOSTNAME="us-east-1.galaxy-deploy.meteor.com"
DOMAIN_NAME='app.company.com'
ROOT_URL="https://${DOMAIN_NAME}/"

# optially you can specify organization name at Galaxy
OWNER_ID="glaxy_organization_name"
```

## Syntax

```
boo <action> [configuration-name] [addtional_keys]
```

## SQL proxy options

When connecting to a Cloud SQL instance, `boo` starts a local
`cloud-sql-proxy`. You can pass extra flags to that proxy via the
`POSTGRES_PROXY_EXTRA_ARGS` environment variable (set it in your `*.conf` file or
shell). It is empty by default, so existing setups are unaffected.

For example, to connect to an instance whose public IP is disabled (private IP
only), route through the private IP:

```
POSTGRES_PROXY_EXTRA_ARGS="--private-ip"
```

Note: `--private-ip` only changes which instance IP the proxy dials — the host
running `boo` still needs a network path into the VPC (e.g. VPN) to reach it.

## Custom actions

You can define your own actions as bash functions at `./conf/boo-actions.conf`.

#### Tested on:

- MacOS
- Arch Linux

## Development

```
git clone git@github.com:trsdln/boo.git
cd boo
npm install -g $(pwd)
```

## Changelog

#### 6.3.0

- [x] added `POSTGRES_PROXY_EXTRA_ARGS` env var to pass extra flags to
      `cloud-sql-proxy` (e.g. `--private-ip`)

#### 5.0.0

- [x] **breaking change**: replaced `mongo` with `mongosh` to support MongoDB
      6+
- [x] **breaking change**: removed MongoDB dev server command
- [x] removed `--verbose` flag support from `mongo-copy`/`mongo-restore` actions.
      Now those are verbose by default

#### 4.0.0

- [x] added PostgreSQL support: `sql`, `sql-copy`, `sql-restore`

#### 3.0.0

- [x] **breaking change**: simplify `db-*` scripts to do single action at a time (gives more
      flexibility). Old vs. new:
  - `boo db-copy test` => `boo db-copy test && boo db-restore test
local -Y`
  - `boo db-restore test` => `boo db-copy local && boo db-restore
local test -Y`
- [x] add `--yes-im-sure` flag to `db-restore` script
