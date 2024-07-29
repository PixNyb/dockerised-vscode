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
- `CODE_INSIDERS`: Whether to install Visual Studio Code Insiders instead of Visual Studio Code. If this argument is set, Visual Studio Code Insiders will be installed instead of Visual Studio Code. Defaults to ``.

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
    -v /var/run/docker.sock:/var/run/docker.sock
    -v /path/to/workspace:/home/vscode/workspace
    pixnyb/code
```

This command will start the container and expose ports `8000` and `2222` for the web server and SSH server respectively. It will also mount the Docker socket and a workspace directory on the host machine to the container to be able to access the host's Docker daemon and workspace files.

The image is availlable on [Docker Hub](https://hub.docker.com/r/pixnyb/code).

The following tags are available:

| Tag        | Description                                       |
| ---------- | ------------------------------------------------- |
| `latest`   | The latest stable version of Visual Studio Code.  |
| `insiders` | The latest insider version of Visual Studio Code. |

#### Profiles

The repository also builds development containers with additional software and extensions for specific programming languages and toolkits. These containers are available on [Docker Hub](https://hub.docker.com/r/pixnyb/code) with the following tags:

| Categorty | Tag                                        | Description                                                                                            |
| --------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| Basic     | [`html`](profiles/src/html/)               | A basic HTML environment, only includes additional extensions.                                         |
| Basic     | [`jekyll`](profiles/src/jekyll/)           | A basic Jekyll environment.                                                                            |
| Basic     | [`tex`](profiles/src/tex/)                 | A basic LaTeX environment.                                                                             |
| Web       | [`node`](profiles/src/node/)               | Includes NVM and installs the latest version of node.                                                  |
| Web       | [`php-<version>`](profiles/src/php/)       | Includes PHP and Composer. (Available versions: `7.2`, `7.3`, `7.4`, `8.0`, `8.1`, `8.2`, `8.3`)       |
| Web       | [`php-<version>-node`](profiles/src/php/)  | Includes PHP, Composer, and NVM. (Available versions: `7.2`, `7.3`, `7.4`, `8.0`, `8.1`, `8.2`, `8.3`) |
| Web       | [`dotnet-<version>`](profiles/src/dotnet/) | Includes .NET SDK and runtime. (Available versions: `8.0`)                                             |
| Native    | [`java-<version>`](profiles/src/java/)     | Includes OpenJDK, Gradle, Maven and Ant. (Available versions: `8`, `11`, `17`, `21`)                   |
| Native    | [`c++`](profiles/src/cpp/)                 | Includes CMake, GCC, Clang, and GDB.                                                                   |


> [!NOTE]
> The pre-built development containers are based on the `latest` tag of the base image. If you want to use `insiders` instead, you can build the image yourself and use the `insiders` tag.

#### Environment Variables

When running the container, you can pass the following environment variables to customise the container:

- `GH_TOKEN`: The GitHub personal access token to use for authentication in the GitHub CLI and in turn git. (Optional)
- `GPG_SECRET_KEY`: The GPG secret key to use for signing commits. (Optional, base64)
- `GPG_PASSPHRASE`: The passphrase for the GPG secret key. (Optional)
- `REPO_URL`: The URL of the Git repository to clone when the container starts. (Optional)
- `REPO_FOLDER`: The folder to clone the Git repository into. (e.g. ~/projects) (Optional)
- `REPO_BRANCH`: The branch of the Git repository to clone. (Optional)
- `INIT_SCRIPT_URL`: The URL of a shell script to run when the container starts. (Optional)
- `EXTENSION_LIST`: A list of Visual Studio Code extensions to install separated by commas. (Optional, e.g `ms-python.python,ms-vscode.cpptools`)
- `EXTENSION_LIST_URL`: The URL of a file containing a list of Visual Studio Code extensions to install separated by newlines. (Optional, e.g. `https://example.com/extensions.txt`)
- `ENABLE_VNC`: Whether to enable VNC server. (Optional, `true` or `false`)

> [!NOTE]
> In order to insert a GPG secret key, you need to base64 encode the contents of the GPG secret key file and pass it as the `GPG_SECRET_KEY` environment variable.
> You can use the following command to generate a new GPG secret key and base64 encode it:
>
> ```bash
> gpg --gen-key && gpg --export-secret-keys --armor $(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2) | base64 -w 0
> ```
>
> If the GPG key doesn't exist in your GitHub account, and the GitHub CLI is authenticated with a personal access token, the GPG key will be uploaded to GitHub automatically.

> [!NOTE]
> The `INIT_SCRIPT_URL` environment variable can be used to run a shell script when the container starts. This can be used to install additional tools and extensions specific to your needs. Keep in mind the `/usr/local/bin/initialise-vscode.sh` script is run after the `INIT_SCRIPT_URL` script. This allows you to start with a base setup and then customise it further according to your needs.

> [!NOTE]
> The `EXTENSION_LIST_URL` environment variable can be used to install a list of Visual Studio Code extensions from a file. It can also be, itself, a list of URLs separated by commas. The file should contain a list of Visual Studio Code extensions separated by newlines.

> [!NOTE]
> The `ENABLE_VNC` environment variable can be used to enable a VNC server in the container. It forwards the X11 display to a VNC server running on port 5900. You can connect to the VNC server using a VNC client (e.g. RealVNC Viewer) with no password.

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

<kbd>Cmd / Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> -> `Remote-SSH: Connect to Host...` -> `Add New SSH Host...` -> `ssh -p 2222 vscode@localhost`

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

Depending on your use case, you might want to think about mounting databases, configuration files, and other data that you want to persist between container restarts.

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
      - GIT_GLOBAL_USER_NAME=PixNyb
      - GIT_GLOBAL_USER_EMAIL=contact@roelc.me
      - GH_TOKEN=<...>
      - GPG_SECRET_KEY=<...>
      - REPO_URL=<...>
      - INIT_SCRIPT_URL=https://example.com/init.sh
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

In this example, we mount the host's timezone configuration and Docker socket to the container. We also mount a custom shell script to the container that will be run when the container starts. This shell script can be used to install additional tools and extensions specific to your needs.

## Disclaimer

This Docker image is provided as is and is not officially supported by or affiliated with Visual Studio Code or GitHub in any way. Use at your own risk.
