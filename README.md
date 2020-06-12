# pca-gophish-composition 🎣🐷📮🐳 #

[![GitHub Build Status](https://github.com/cisagov/pca-gophish-composition/workflows/build/badge.svg)](https://github.com/cisagov/pca-gophish-composition/actions)

Creates a Docker composition containing instances of:

- [gophish](https://github.com/cisagov/docker-gophish/) phishing framework.
- [gophish-tools](https://github.com/cisagov/gophish-tools/) helper scripts.
- [mailhog](https://github.com/mailhog/MailHog) email testing tool.
- [postfix](https://github.com/cisagov/docker-postfix/) mail server.

## Usage ##

A sample [docker composition](docker-compose.yml) is included
in this repository.

To start the composition use the command: `docker-compose up`

It's normal for the `gophish-tools` container to exit shortly after startup;
it is included in this composition as a convenience for phishing operators.
For usage details, read the
[`gophish-tools` documentation](https://github.com/cisagov/gophish-tools/).

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
