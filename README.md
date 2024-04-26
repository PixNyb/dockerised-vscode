# Dockerised Visual Studio Code

This is a Dockerised version of Visual Studio Code. It includes basic requirements for running Visual Studio Code (and GitHub CLI) on a remote server and can be expanded to include additional tools and extensions specific to your needs.

## Usage

### Build the Docker image

```bash
docker build -t vscode .
```

#### Build Arguments

During the build process, you can pass the following arguments to customise the image:

- `USERNAME`: The username to use when running the container. Defaults to `vscode`.
- `DOCKER_GID`: The GID of the Docker group on the host machine. Defaults to `999` (the default GID of the Docker group on most systems).

For example, to build the image with a custom username:

```bash
docker build -t vscode --build-arg USERNAME=myuser .
```

### Run the Docker container

To run the Docker container, you can use the following command:

```bash
docker run \
    -p 8000:8000 \
    -p 2222:22 \
    -e VSCODE_KEYRING_PASS=mysecretpassword \
    -v /var/run/docker.sock:/var/run/docker.sock
    -v /path/to/workspace:/home/vscode/workspace
    pixnyb/code
```

This command will start the container and expose ports `8000` and `2222` for the web server and SSH server respectively. It will also mount the Docker socket and a workspace directory on the host machine to the container to be able to access the host's Docker daemon and workspace files.

The image is availlable on [Docker Hub](https://hub.docker.com/r/pixnyb/code).

#### Environment Variables

When running the container, you can pass the following environment variables to customise the container:

- `VSCODE_KEYRING_PASS`: The password to use for the keyring. (Required)
- `GH_TOKEN`: The GitHub personal access token to use for authentication in the GitHub CLI and in turn git. (Optional)
- `GPG_SECRET_KEY`: The GPG secret key to use for signing commits. (Optional, base64)
- `GPG_PASSPHRASE`: The passphrase for the GPG secret key. (Optional)

> [!NOTE]
> In order to insert a GPG secret key, you need to base64 encode the contents of the GPG secret key file and pass it as the `GPG_SECRET_KEY` environment variable.
> You can use the following command to generate a new GPG secret key and base64 encode it:
>
> ```bash
> gpg --gen-key && gpg --export-secret-keys --armor $(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2) | base64 -w 0
> ```

> [!NOTE]
> The GPG secret key is expected to be the contents of a GPG secret key file. If it's not present in GitHub, and a GitHub personal access token is provided, the GPG key will be added to GitHub with the title `GPG key for ${hostname}`.

##### Git Configuration

The container comes with a default Git configuration that includes a global gitignore file, a global gitmessage file and some basic configuration settings. You can customise the Git configuration by using the following environment variable naming convention: `GIT_{CONFIGURATION}_{KEY}`.

For example, to set the user name and email for Git:

```bash
docker run \
    -e GIT_GLOBAL_USER_NAME=myname \
    -e GIT_GLOBAL_USER_EMAIL=myemail \
    pixnyb/code
```

### Access the container

To access the container, you can use the following methods:

#### Web Server

You can access the container through the web server by navigating to `http://localhost:8000` in your web browser. This will open Visual Studio Code in your web browser.

> [!WARNING]
> The web server is not secure and should not be exposed to the public internet without additional security measures.
> Make sure to secure the web server before exposing it to the public internet (e.g. by using a reverse proxy with HTTPS and authentication).

#### SSH Server

You can access the container through a VS Code SSH connection by using the following command:

```bash
ssh -p 2222 vscode@localhost
```

This will open Visual Studio Code in your local VS Code instance.

### Volumes

You can customise the Docker image to include additional tools and extensions specific to your needs. To do this, you can mount various files and directories to the container during runtime.

- `/etc/home`: Files and directories to be copied to the home directory of the user.
- `/home/${USERNAME}/.local/bin`: Shell scripts to be included in the PATH of the user.
- `/usr/local/bin/initialise-vscode.sh`: A shell script to be run when the container starts. This can be used to install additional tools and extensions.

> [!NOTE]
> The container comes with sudo installed and a non-root user with sudo privileges.
> You can use this user to install additional tools and extensions during runtime.

#### Recommended Volumes

For a more persistent setup, you can mount the following volumes to the container:

- `/etc/localtime:/etc/localtime:ro`: The host's timezone configuration.
- `/var/run/docker.sock:/var/run/docker.sock:ro`: The host's Docker socket.
- `/path/to/workspace:/home/${USERNAME}/workspace`: The host's workspace directory.
- `/path/to/ssh-keys:/home/${USERNAME}/.ssh`: The host's SSH keys directory.
- `/path/to/config:/home/${USERNAME}/.vscode-server`: The host's Visual Studio Code configuration directory.

## Example

To demonstrate how to use the Dockerised Visual Studio Code, we will create a simple example that includes a custom Git configuration and a custom shell script to install additional tools and extensions in a docker-compose file.

```yaml
services:
  code:
    image: pixnyb/code
    hostname: code
    ports:
      - 8000:8000
    environment:
      - VSCODE_KEYRING_PASS=password
      - GIT_GLOBAL_USER_NAME=PixNyb
      - GIT_GLOBAL_USER_EMAIL=contact@roelc.me
      - GH_TOKEN=<...>
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - config:/home/vscode/.vscode-server
      - ssh-keys:/home/vscode/.ssh
      - home:/etc/home
      - workspaces:/home/vscode/projects

volumes:
  config:
    driver: local
  ssh-keys:
    driver: local
  home:
    driver: local
  workspaces:
    driver: local
```

