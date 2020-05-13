<<<<<<< HEAD
# pca-gophish-composition 🎣🐷📮🐳 #

[![GitHub Build Status](https://github.com/cisagov/pca-gophish-composition/workflows/build/badge.svg)](https://github.com/cisagov/pca-gophish-composition/actions)

Creates a Docker composition containing instances of:

- [gophish](https://github.com/cisagov/docker-gophish/) phishing framework.
- [mailhog](https://github.com/mailhog/MailHog) email testing tool.
- [postfix](https://github.com/cisagov/docker-postfix/) mail server.

## Usage ##

A sample [docker composition](docker-compose.yml) is included
in this repository.

To start the composition use the command: `docker-compose up`

Connect to the `gophish` admin web interface at:
[https://localhost:3333](https://localhost:3333).
The default credentials are `admin`, `gophish`.

Once the composition is running, `gophish` will need to be
configured to talk to `mailhog` and `postfix`. Create new
sending profiles for the two servers as listed below:

| Name    | Host:Port    |
| ------- | ------------ |
| MailHog | mailhog:1025 |
| Postfix | postfix:587  |

The `mailhog` email testing tool can be accessed at [http://localhost:8025](http://localhost:8025)

⚠️ **NOTE**:  Do not use the sample certificates in a production environment.
They are include to simplify testing.

### Ports ###

This composition exposes the following ports to the localhost:

- 1025: `postfix SMTP`
- 1587: `postfix submission`
- [3333](https://localhost:3333): `gophish admin server`
- [3380](http://localhost:3380): `gophish phish server`
- [8025](http://localhost:8025): `mailhog web interface`

### Environment Variables ###

- postfix
  - `PRIMARY_DOMAIN`: the domain of the mail server
  - `RELAY_IP`: (optional) an IP address that is allowed to relay mail without authentication

### Secrets ###

- gophish
  - `config.json`: gophish configuration file
  - `admin_fullchain.pem`: public key for admin port
  - `admin_privkey.pem`: private key for admin port
  - `phish_fullchain.pem`: public key for phishing port
  - `phish_privkey.pem`: private key for phishing port
- postfix
  - `fullchain.pem`: public key
  - `privkey.pem`: private key
  - `users.txt`: account credentials

### Volumes ###

None.
=======
# skeleton-docker 💀🐳 #

[![GitHub Build Status](https://github.com/cisagov/skeleton-docker/workflows/build/badge.svg)](https://github.com/cisagov/skeleton-docker/actions)
[![Total alerts](https://img.shields.io/lgtm/alerts/g/cisagov/skeleton-docker.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/cisagov/skeleton-docker/alerts/)
[![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/cisagov/skeleton-docker.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/cisagov/skeleton-docker/context:python)

## Docker Image ##

![MicroBadger Layers](https://img.shields.io/microbadger/layers/cisagov/example.svg)
![MicroBadger Size](https://img.shields.io/microbadger/image-size/cisagov/example.svg)

This is a docker skeleton project that can be used to quickly get a
new [cisagov](https://github.com/cisagov) GitHub docker project
started.  This skeleton project contains [licensing
information](LICENSE), as well as [pre-commit hooks](https://pre-commit.com)
and [GitHub Actions](https://github.com/features/actions) configurations
appropriate for docker containers and the major languages that we use.

## Usage ##

### Install ###

Pull `cisagov/example` from the Docker repository:

    docker pull cisagov/example

Or build `cisagov/example` from source:

    git clone https://github.com/cisagov/skeleton-docker.git
    cd skeleton-docker
    docker-compose build --build-arg VERSION=0.0.1

### Run ###

    docker-compose run --rm example

## Ports ##

This container exposes the following ports:

| Port  | Protocol | Service  |
|-------|----------|----------|
| 8080  | TCP      | http     |

## Environment Variables ##

| Variable      | Default Value                 | Purpose      |
|---------------|-------------------------------|--------------|
| ECHO_MESSAGE  | `Hello World from Dockerfile` | Text to echo |

## Secrets ##

| Filename      | Purpose              |
|---------------|----------------------|
| quote.txt     | Secret text to echo  |

## Volumes ##

| Mount point | Purpose        |
|-------------|----------------|
| /var/log    | logging output |
>>>>>>> 4de6b59dd041229073cb15571ec5a1c005f6cad6

## Contributing ##

We welcome contributions! Please see [here](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
