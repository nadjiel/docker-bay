# Docker Bay - Personal Docker Practice Center
Docker Bay is this custom repository that contains a todo app forked from the [Getting Started App's](https://github.com/docker/getting-started-app) [@Docker](https://github.com/docker) repository meant for Docker practice.

## Docker Images
An image is an way of providing an isolated filesystem for a container that is based on it. To work, the image must contain everything the app needs to run, its code, binaries, dependencies etc. The image may also contain environment variables, a default command to run and other metadata.

### Building
To build an image, a `Dockerfile` is needed. This file specifies, through a script, what steps should be followed in the image building.

For this project, the following `Dockerfile` was made:

```docker
# syntax=docker/dockerfile:1

# Specifying base image to this image: the official Nodejs 18 alpine linux image
FROM node:18-alpine

# Setting the directory for the following instructions
WORKDIR /app

# Copying the package.json and the yarn.lock from this directory to the working directory specified at WORKDIR
COPY package.json yarn.lock ./

# Installing the dependencies on the package.json, excluding the development ones
RUN yarn install --production

# Copying all files from this directory to the working directory specified at WORKDIR
COPY . .

# Specifying the command to execute when the application starts: node src/index.js
CMD ["node", "src/index.js"]

# Exposing the port 3000 on the container
EXPOSE 3000
```

With the `Dockerfile` created, now the project image can be built, to do so, the command is as follows:

```shell
docker build --tag docker-bay .
```

This command will use the `Dockerfile` specified at the `.` directory to build the image with the `docker-bay` tag. Note that the image tag is customizable - it just serves as a human readable name to reference the image.

### Tagging
To change the tag of an image, this command can be used:

```shell
docker tag docker-bay nadjiel/docker-bay
```

In this case `docker-bay` is the old tag of the image and `nadjiel/docker-bay` is the new tag. You should type your Docker username instead of `nadjiel` which is just my username.

### Login
On the CLI, you can login to your Docker account. To do so, the command `login` is used:

```shell
docker login
```

After entering the command, Docker will ask for your username and password. If you type them right the login should be succeeded.

### Pushing
Docker permits to push your images to an online repository. To do that, the command is the `docker push`:

```shell
docker push nadjiel/docker-bay
```

In this example, the image `nadjiel/docker-bay` is being pushed to an online repository.

### Layering
Docker images are composed of layers. What happens when the image is built is: each command on the `Dockerfile` creates a layer that is based on the previous layer. This goes all the way backwards to the first layer of the first image on which the project is based (in this case, the project is based on the `node:18-alpine`, which, in turn, is based on some other image and so on).

To see about the creation of each layer of an image, the command `image history` is used:

```shell
docker image history nadjiel/docker-bay
```

This will print information about the `nadjiel/docker-bay` image layering.

One important thing about image layering is that when Docker builds an image it creates a cache so that next time the same image is built the process is quite faster.

With this in mind, if one step of the `Dockerfile` is altered, the cache can't be used to this step and its subsequent steps.

That means that slower and less frequent processes such as the download of dependencies should always be put first on the `Dockerfile` than processes like copying the source code to the image.

This happens because, if it was the other way around, everytime the source code was changed, its copying and the next steps would have to be repeated on the build, including the installation of dependencies. If the dependencies installing is put first, though, they will only have to be reinstalled if some dependency is added, updated or removed from the project, which happens way less often than source code changes.

### Multi-stage Building
_Research must be made about this topic. A useful link is [docs.docker.com](https://docs.docker.com/get-started/09_image_best/#multi-stage-builds)_

## Docker Containers
Docker containers are instances of Docker images that can run on a host machine with any OS in the form of an isolated process.

### Running
To run an image, the following command is what you need:

```shell
docker run --detach --publish 127.0.0.1:3000:3000 nadjiel/docker-bay
```

This command will run a container of the image `nadjiel/docker-bay` in the background (`--detach`) and make it accessible through the port `3000` of the localhost (`127.0.0.1`) with the `--publish`. In this command, the part `127.0.0.1:3000:3000` corresponds to `host_address:host_port:container_port`. Since the container exposes the port `3000`, that is the right choice.

With this command, the `docker-bay` app should be accessible on [localhost:3000](http://localhost:3000).

### Listing
If you wanna see a list of your containers, you'll want this command:

```shell
docker container ls
```

Or even:

```shell
docker ps
```

Additionally, if you wanna see your stopped containers included, the flag `--all` or `-a` should be included.

### Stopping
When you wish to stop a container, the command is:

```shell
docker stop f8f00ccd48b0
```

You can use either the container id, which you can find when you list your containers (if the container isn't running when you list it, you have to pass the `--all` parameter), or the container tag:

```shell
docker stop ecstatic_galois
```

Note that both the id and the tag are random from container to container (unless you specify the container tag, then the tag won't be random).

### Removing
To remove a stopped container you can type as follows:

```shell
docker rm f8f00ccd48b0
```

With the id, or, as in stopping a container, using the tag:

```shell
docker rm ecstatic_galois
```

When you want to remove a container no matter if it is running at the moment, you can directly pass the `--force` parameter to the remove command:

```shell
docker rm --force ecstatic_galois
```

## Docker Volumes
Docker volumes are a way to persist the data created with containers, which otherwise would be destroyed on the container deletion.

### Creating
To create a volume the command used is this one:

```shell
docker volume create docker-bay-db
```

Here a volume called `docker-bay-db` was created, but that's just a custom name.

### Using
To make a container have access to a volume, when running this container a `--mount` parameter may be passed:

```shell
docker run --detach --publish 127.0.0.1:3000:3000 --mount type=volume,src=docker-bay-db,target=/etc/todos nadjiel/docker-bay
```

In this example, a container based on the image `nadjiel/docker-bay` that will have access to the `docker-bay-db` volume is being created.

With this, even if the container is deleted, when another container is created with this same `--mount` parameter, it will keep access to the data created with the previous container.

### Inspecting
A cool way to see some information about a volume is using the `inspect` command:

```shell
docker volume inspect docker-bay-db
```

This command should display some informations about the `docker-bay-db` volume.

### Bind Mounts
In Docker, bind mounts are another way of accessing data from the host machine outside the container.

As an example:

```shell
docker run `
  -dp 127.0.0.1:3000:3000 `
  -w /app `
  --mount "type=bind,src=$pwd,target=/app" `
  node:18-alpine `
  sh -c "yarn install && yarn run dev"
```

Here, the `--mount` parameter is receiving the string `"type=bind,src=$pwd,target=/app"`, that means that the container will have a bind mount that links the host current working directory (`$pwd`) with the container `/app` directory. With this, any modifications made on the `/app` directory on the container will reflect on the current working directory of the host machine and vice versa.

Some more things to note about the command:

- `-dp` is a short way of running `--detach --publish`;
- `-w` is a way of setting the directory on which the following commands will be executed on the container;
- `sh -c` will start a shell and execute the following string `"yarn install && yarn run dev"` as a command on the container.

This concept of bind mount can be a useful way for instant restarting modifications on an app with the help of dependencies such as Nodemon. That happens because when any modification is made on the local environment, it will be reflected on the container environment, triggering Nodemon restart.

## Docker Networks
In Docker it is often needed to establish a form of communication between containers, like when an app container needs to communicate with a database container. To allow this there is the concept of Docker networks.

### Creating
To create a network, the command is as follows:

```shell
docker network create docker-bay-net
```

Here, a network called `docker-bay-net` is being created.

### Connecting
Now that a network is created, how does a container connect to it? These parameters on a container creation allow that:

```shell
docker run -d `
  --network docker-bay-net --network-alias mysql `
  -v docker-bay-mysql-vol:/var/lib/mysql `
  -e MYSQL_ROOT_PASSWORD=secret `
  -e MYSQL_DATABASE=docker-bay `
  mysql:8.0
```

This code will create a container for a MySQL database based on the `mysql:8.0` image that will be connected (`--network`) to the `docker-bay-net` network having an alias (`--network-alias`) of `mysql`. This container will also have a volume (`-v`) called `docker-bay-mysql-vol` that will save the files in the container's `/var/lib/mysql` directory, which is the directory where MySQL data is stored. Finally, the container will also have access to the environment variables (`-e`) `MYSQL_ROOT_PASSWORD` and `MYSQL_DATABASE` that will have the values `secret` and `docker-bay` respectively, which means that the password required to access the MySQL root user will be `secret` and the database `docker-bay` will be created.

### Container Interconnection
With the database container created, the app container can be run as well, now being able to connect to it:

```shell
docker run -dp 127.0.0.1:3000:3000 `
  -w /app -v "$(pwd):/app" `
  --network docker-bay-net `
  -e MYSQL_HOST=mysql `
  -e MYSQL_USER=root `
  -e MYSQL_PASSWORD=secret `
  -e MYSQL_DB=docker-bay `
  node:18-alpine `
  sh -c "yarn install && yarn run dev"
```

This snippet creates a development auto-restartable container with the help of bind mounting (`-v "$(pwd):/app"`) and Nodemon for the app that will be on the same network (`--network`) as the MySQL container. This container receives some environment variables that the app needs to connect to the database, which are described next:

- `MYSQL_HOST`, defined as `mysql`, which is the alias of the MySQL container's ip on the network, set with `--network-alias`;
- `MYSQL_USER`, defined as `root`, which is the root user of the MySQL database;
- `MYSQL_PASSWORD`, set as `secret` when the MySQL database was created; 
- `MYSQL_DB`, configured as `docker-bay`, also when the database was created.

## Docker Compose
Docker compose is a file called `compose.yaml` that is usually on the root folder of a Docker app. This file is a way of automatizing the processes of container, volume, and network creations necessary to run the app.

For this project, the Docker compose is the following:

```yaml
# The containers of the project
services:
  # The name of the container, which will be automatically also its network alias
  app:
    # The image on which this container is based
    image: node:18-alpine
    # The initial command to be executed by this container
    command: sh -c "yarn install && yarn run dev"
    # The port mapping from the container to the host
    ports:
      - 127.0.0.1:3000:3000
    # Setting the working directory for the next instructions
    working_dir: /app
    # Bind mount from the container /app to the host current directory
    volumes:
      - ./:/app
    # The evironment variables
    environment:
      MYSQL_HOST: mysql
      MYSQL_USER: root
      MYSQL_PASSWORD: secret
      MYSQL_DB: docker-bay

  mysql:
    image: mysql:8.0
    # The volume of this container
    volumes:
      - mysql-vol:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: docker-bay

volumes:
  mysql-vol:
```

Basically what this file does is:

1. Create a `docker-bay_default` network where the container will be;

2. Create a volume `docker-bay_mysql-vol`;

3. Create a `docker-bay-app-<replica-number>` container with network alias of `app`. This container is based on the image `node:18-alpine`. It will execute `sh -c "yarn install && yarn run dev"` on start; will be opened to the port `127.0.0.1:3000`; will have access to the root directory of the project; and will have some environment variables;

4. Create a `docker-bay-mysql-<replica-number>` container with network alias of `mysql`. This container is based on the image `mysql:8.0`. It will have access to the `docker-bay_mysql-vol` volume and will have some environment variables;

## Docker Ignore
Docker ignore is a file that is usually put on the root folder of a Docker project to signalize to Docker which files shouldn't be taken into account when building an image with the project.

## References
- [Official Docker documentation](https://docs.docker.com).

## Appendix
- More about `Dockerfile`: [docs.docker.com/engine/reference/builder](https://docs.docker.com/engine/reference/builder/);
- More about Docker CLI: [docs.docker.com/engine/reference/commandline/cli](https://docs.docker.com/engine/reference/commandline/cli/).
