### haproxy-binding

On a system with docker:

# ./run.sh

### Example run:

Not the *** 44 failed *** towards the end. That IP exists on dummy0 and should
work. It was 43 that was removed. 45 and the stats bind are fine. What does and
doesn't work seems to be consistent here, but we've seen it be fairly random,
different on different boxes during the same process/rollout so it may not be
completely deterministic.

``
box:haproxy-reload ross$ ./run.sh
Sending build context to Docker daemon  10.75kB
Step 1/6 : FROM haproxy:1.8.26
 ---> 91f093348f56
Step 2/6 : RUN apt-get update   && apt-get install -y --no-install-recommends curl iproute2 net-tools   && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 081f602b8d32
Step 3/6 : RUN mkdir /app
 ---> Using cache
 ---> 81ff78015a78
Step 4/6 : WORKDIR /app
 ---> Using cache
 ---> 085e666c55a9
Step 5/6 : COPY . .
 ---> Using cache
 ---> d0b335475a80
Step 6/6 : CMD /app/test.sh
 ---> Using cache
 ---> a535798c5ea8
Successfully built a535798c5ea8
Successfully tagged haproxy-reloads:latest
Creating dummy0
Binding extra ips
with all
OK - with
43 worked
OK - with
44 worked
OK - with
45 worked
stats worked
Removing 43, switching to without
[WARNING] 303/161811 (12) : Reexecuting Master process
[WARNING] 303/161813 (12) : Former worker 14 exited with code 0
OK - without
44 worked
OK - without
45 worked
stats worked
Switching back to with, .43 doesn't exist
[WARNING] 303/161813 (12) : Reexecuting Master process
[WARNING] 303/161815 (12) : [/usr/local/sbin/haproxy.main()] Cannot raise FD limit to 4017, limit is 4016.
[ALERT] 303/161815 (12) : Starting frontend main: cannot bind socket [192.168.42.43:80]
[WARNING] 303/161815 (12) : Reexecuting Master process in waitpid mode
[WARNING] 303/161815 (12) : Reexecuting Master process
curl: (56) Recv failure: Connection reset by peer
*** 44 failed ***
OK - without
45 worked
stats worked
[WARNING] 303/161817 (12) : Exiting Master process...
```
