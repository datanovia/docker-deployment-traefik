# Træfik Deployment With Automated Script

<!-- markdownlint-disable line-length -->
[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a>
<!-- markdownlint-enable line-length -->

This fork enhances the original [Træfik deployment template](https://github.com/b-data/docker-deployment-traefik) with an **automated deployment script** (`deploy.sh`) for both **testing** and **production** environments. The script simplifies the setup process and reduces manual errors, enabling seamless deployment of Træfik and associated services.


This project serves as a template to run [Træfik](https://hub.docker.com/_/traefik) v3.2 in a docker
container using docker compose.

The goal is to set up a TLS termination proxy for all Docker containers
providing web services on a **single host**.

## About Træfik

Træfik is a modern reverse proxy and load balancer designed to simplify managing web traffic to your services. As a **TLS termination proxy**, Træfik handles HTTPS encryption and decryption, allowing secure communication between your users and your services.

This project sets up Træfik to manage and secure web services hosted on a **single server** using Docker. With minimal configuration, Træfik automatically routes traffic to your Docker containers, manages certificates, and applies essential security features.

### Key Features

1. **Automatic TLS Termination**:
   - Træfik uses Let's Encrypt to automatically generate and renew SSL/TLS certificates, ensuring secure connections (via the HTTP challenge).

2. **Middleware Support**:
   Træfik provides essential middlewares for enhanced functionality and security:
   - **RedirectScheme**: Automatically redirects HTTP traffic to HTTPS.
   - **RateLimit**: Controls the rate of incoming requests to prevent abuse:
     - Average: 100 requests per second.
     - Burst: 50 additional requests in short bursts.
   - **Headers**: Enforces HTTP Strict Transport Security (HSTS) with long durations for enhanced security.

3. **Customizable TLS Configurations**:
   - Offers three pre-configured TLS settings (modern, intermediate, and old) based on your compatibility requirements.
   - Configurations align with recommendations from the [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org).

4. **Environment Variable Support**:
   - Uses an [.env file](https://docs.docker.com/compose/env-file/) for configuration.
   - Simplifies variable management and allows dynamic updates through [Compose file variable substitution](https://docs.docker.com/compose/compose-file/#variable-substitution).

### Why Use Træfik?

Træfik is particularly suitable for dynamic environments where containers or services may frequently change. It automatically discovers and adapts to changes in your Docker environment, minimizing manual intervention. With its robust TLS handling, middleware options, and easy configuration, Træfik is ideal for managing web services securely and efficiently on a single host.  

For more information, visit the official Træfik resources:

* Homepage: <https://traefik.io/traefik/>
* Documentation: <https://doc.traefik.io/traefik/>

## Table of Contents

* [Prerequisites](#prerequisites)
* [Install](#install)
* [Usage](#usage)
* [Test](#test)
* [Debugging](#debugging)
* [Contributing](#contributing)
* [Support](#support)
* [License](#license)


## Prerequisites

For the HTTP challenge you require:

* A publicly accessible host allowing connections on port 80 & 443.
* A DNS record for the domain you want to expose pointing to this host.

## Install

Follow these steps to install Docker and Docker Compose:

* [Install Docker Engine](https://docs.docker.com/engine/install/#supported-platforms)
  * Includes Docker Compose V2
* [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)



## Usage

The `deploy.sh` script handles the deployment process automatically.

### Options

| Option               | Description                                                                                              |
|----------------------|----------------------------------------------------------------------------------------------------------|
| `--email <email>`    | Valid email address for Let's Encrypt (default: `postmaster@mydomain.com`).                              |
| `--domain-name <name>` | Domain name to use for deployment (e.g., `sub.domain.com`).                                         |
| `--test`             | Deploy in testing mode, using `sample.docker-compose-test.yml`.                                          |
| `--help`             | Display the help message and usage instructions.                                                        |


### Example Commands

#### Deploy in Testing Mode

- Deploy Traefik in testing mode using `sample.docker-compose-test.yml` as template.
- Enable the service `whoami` for testing.

```bash
./deploy.sh --email postmaster@mydomain.com --domain-name sub.domain.com --test
```

- Replace `postmaster@mydomain.com` with a valid email address.
- Replace `sub.domain.com` with a valid domain or subdomain name.

To verify the deployment, visit `https://sub.domain.com` in your browser.

#### Deploy in Production Mode

- Deploy Traefik in production mode using `sample.docker-compose.yml` as template.
- The argument `--test` is not needed.

```bash
./deploy.sh --email your-email@example.com --domain-name prod.datanovia.com
```

Again, make sure to specify a valid email address and domain oor sub-domain name.


---


### Display Help
  
```bash
./deploy.sh --help
```

---

### What the Script Does

1. **Creates a Docker Network**:
    - Checks for the existence of the `webproxy` network and creates it if not found.

2. **Updates Permissions**:
   - Ensures `config/acme` is writable.

3. **Copies Configuration Files**:
    - Automatically copies appropriate configuration files based on the deployment mode (testing or production).

4. **Updates `.env` Variables**:
    - Modifies `.env` with the provided email and domain name details.

5. **Stops Existing Containers**:
    - Ensures any running containers from the previous deployment are stopped to avoid orphan containers.

6. **Starts New Containers**:
    - Runs `docker compose up -d` to start the deployment.

---


## Debugging

Use the `docker logs` command to check the output of the Traefik container:

```bash
docker logs webproxy-traefik-1
```


---

## Contributing

PRs are welcome! Submit them to the forked repository. Contributions should align with the original project's goals and standards.

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).

---


## License

This project is licensed under the terms of the [MIT License](LICENSE).  
Original template © 2019 b-data GmbH.  


---


## Support

Community support: Open a new discussion
[here](https://github.com/orgs/b-data/discussions).

Commercial support: Contact b-data by [email](mailto:support@b-data.ch).

## License

Copyright © 2019 b-data GmbH

Distributed under the terms of the [MIT License](LICENSE).
