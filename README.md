# Træfik Deployment With Automated Script

<!-- markdownlint-disable line-length -->
[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a>
<!-- markdownlint-enable line-length -->

This fork enhances the original [Træfik deployment template](https://github.com/b-data/docker-deployment-traefik) with an **automated deployment script** (`deploy.sh`) for both **testing** and **production** environments, as well as a **Makefile** for streamlined execution.

This project serves as a template to run [Træfik](https://hub.docker.com/_/traefik) v3.2 in a Docker container using Docker Compose.

The goal is to set up a TLS termination proxy for all Docker containers providing web services on a **single host**.

---

## About Træfik

Træfik is a modern reverse proxy and load balancer designed to simplify managing web traffic to your services. As a **TLS termination proxy**, Træfik handles HTTPS encryption and decryption, allowing secure communication between your users and your services.

This project sets up Træfik to manage and secure web services hosted on a **single server** using Docker. With minimal configuration, Træfik automatically routes traffic to your Docker containers, manages certificates, and applies essential security features.

### Key Features

1. **Automatic TLS Termination**:
   - Træfik uses Let's Encrypt to automatically generate and renew SSL/TLS certificates, ensuring secure connections (via the HTTP challenge).

2. **Middleware Support**:
   - Træfik provides essential middlewares for enhanced functionality and security:
     - **RedirectScheme**: Automatically redirects HTTP traffic to HTTPS.
     - **RateLimit**: Controls the rate of incoming requests to prevent abuse.
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

1. **Host Requirements**:
   - A publicly accessible host allowing connections on ports **80** and **443**.
   - A DNS record pointing to the host for the domain you want to expose.

2. **Install Docker and Docker Compose**:
   - Follow these guides:
     - [Install Docker Engine](https://docs.docker.com/engine/install/#supported-platforms) (includes Docker Compose V2).
     - [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/).

---

## Usage

The deployment process can be handled via the `deploy.sh` script or the `Makefile`.

### Script Usage

The `deploy.sh` script automates the deployment process. Use the following options:

| Option               | Description                                                                                              |
|----------------------|----------------------------------------------------------------------------------------------------------|
| `--email <email>`    | Valid email address for Let's Encrypt (default: `postmaster@mydomain.com`).                              |
| `--domain-name <name>` | Domain name to use for deployment (e.g., `sub.domain.com`).                                             |
| `--test`             | Deploy in testing mode, using `sample.docker-compose-test.yml`.                                          |
| `--help`             | Display the help message and usage instructions.                                                        |

#### Examples

- **Testing Deployment**:
    - Deploy Traefik in testing mode using `sample.docker-compose-test.yml` as template.
    - Enable the service `whoami` for testing.
    - Make sure to specify a valid email address and domain oor sub-domain name.

  ```bash
  ./deploy.sh --email contact@datanovia.com --domain-name dev.datanovia.com --test
  ```

  Verify the deployment by accessing `https://dev.datanovia.com` in your browser.

- **Production Deployment**:
    - Deploy Traefik in production mode using `sample.docker-compose.yml` as template.
    - The argument `--test` is not needed.
    - Make sure to specify a valid email address and domain oor sub-domain name.

  ```bash
  ./deploy.sh --email contact@datanovia.com --domain-name dev.datanovia.com
  ```

---

### Makefile Commands

The `Makefile` simplifies deployment and management with predefined targets:

| Command           | Description                                                                                              |
|-------------------|----------------------------------------------------------------------------------------------------------|
| `make help`       | Display the help message and available commands.                                                         |
| `make deploy`     | Deploy services for production using the default domain and email (or overridden variables).             |
| `make deploy-test`| Deploy services for testing using the default domain and email (or overridden variables).                |
| `make stop`       | Stop all running Docker Compose containers defined in the `docker-compose.yml`.                          |
| `make start`      | Start existing Docker Compose containers without running full deployment steps.                          |

#### Examples

1. **Testing Deployment**:
   ```bash
   make deploy-test
   ```

2. **Production Deployment**:
   ```bash
   make deploy
   ```

3. **Stop Running Services**:
   ```bash
   make stop
   ```

4. **Start Existing Containers**:
   ```bash
   make start
   ```

5. **Override Variables**:
   ```bash
   make deploy EMAIL=admin@example.com DOMAIN=prod.example.com
   make deploy-test EMAIL=test@example.com DOMAIN=test.example.com
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

---

## License

This project is licensed under the terms of the [MIT License](LICENSE).  
Original template © 2019 b-data GmbH.  

---
