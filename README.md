Tunnelling X (GUI) in Docker + SSH
================================


Docker + X (locally)
--------------------
Docker GUI applications can use the host X server by:

- propagating to the container the host's X unix socket

- propagating to the container the host's Xauthority file

- setting the `DISPLAY` variable on the docker container accordingly

i.e. `-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/vivado/.Xauthority`

The dockerizer application will try to connect to the X server as if it run on the host; it will look at its DISPLAY variable to see wich unix socket to connect to (in `/tmp/.X11-unix`), and it will use the authentication cookie in its ~/.Xauthority. since we "propagate" this three things from the host to the container we are OK.


SSH + X (without docker)
------------------------

If we have SSH access to a remote machine, and we wish to run a graphical application, we need to

- enable SSH X forwarding in the ssh server config (on remote machine)

- connect to the remote machine using `-X` option

In this way SSH will handle everitying for us; it will tunnel the X connection on a TCP socket, and it will set the DISPLAY variable accordingly. The remote applications will connect to a TCP port (instead of a unix socket) that SSH will forward to out X server


Putting the two things together
-------------------------------

Trying to combine the two things above is not straightforward: you need to fixup things by hand

- you need to fix the container DISPLAY variable to point to the host IP and proper display number

- you need to fix the container Xauthority to correcly propagate the authentication cookie

The key here is to fix things wrt the container-host docker network IPs. The container DISPLAY variable need to be adjusted so that it refers to the host docker-network IP; the same for the authentication entry in Xauthority.

While adjusting the DISPLAY variable is trivial, to fix the authentication cookie we perform this process:

- extract the authentication cookie (`AUTH_COOKIE=$(xauth list ${DISPLAY})`).

- create a new Xauthority file using this cookie, but associated to the docket-network host ip (`xauth -f Xauthority add ${HOST_DOCKER_IP}:${DISPLAY_NUMBER} MIT-MAGIC-COOKIE-1 ${AUTH_COOKIE}`)

- forward our forged Xauthority file to the docker container and pass to it the proper DISPLAY variable(`docker run -it --rm  -e DISPLAY=${HOST_DOCKER_IP}:${DISPLAY_NUMBER} -v ${PWD}/Xauthority:/home/${CONTAINER_HOME}/.Xauthority docker-x-test /bin/bash`)

That's it :)

Try it
------

In this repo you find a working (I hope) example.

- Connect to your remote SSH machine **using `-X` option**
- Clone this repo there
- Build the example container: `./build_docker`
- Run the docker container: `./run` - NOTE: you may need to fix your docker host IP address and home directory in the script
- Run an awesome GUI app in the container: `xclock`


The socat method
----------------

In previous commits, and somewhere on the internet, another method is used:
the `socat` utility is used to forward the TCP socket to a UNIX socket. This kind of worked but

- seemed overkilling to me

- has some issues (i.e. it worked only on the first connection, then socat exits.. Some attempts adding the *fork* option failed..)
