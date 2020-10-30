### haproxy-binding

On a system with docker:

```
# ./run.sh
```

By default this is using HAProxy 1.8.26, but I get the same behavior with
`latest` which is 2.2.x atm.

### Example run:

Not the *** 44 failed *** towards the end. That IP exists on dummy0 and should
work. It was 43 that was removed. 45 and the stats bind are fine. What does and
doesn't work seems to be consistent here, but we've seen it be fairly random,
different on different boxes during the same process/rollout so it may not be
completely deterministic.

```
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
### sysctl work-around

Setting sysctl `net.ipv4.ip_nonlocal_bind=1` (and `net.ipv6.ip_nonlocal_bind=1`
if you're using IPv6 binds too) works around the issue.

```
box:haproxy-reload ross$ ./run.sh --sysctl net.ipv4.ip_nonlocal_bind=1
Sending build context to Docker daemon  10.75kB
Step 1/6 : FROM haproxy:latest
 ---> 9e2effcbbd93
Step 2/6 : RUN apt-get update   && apt-get install -y --no-install-recommends curl iproute2 net-tools   && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 032bcdc8b376
Step 3/6 : RUN mkdir /app
 ---> Using cache
 ---> da519cc4d41f
Step 4/6 : WORKDIR /app
 ---> Using cache
 ---> 3efcb173d3d0
Step 5/6 : COPY . .
 ---> Using cache
 ---> fe4f1a62f4d9
Step 6/6 : CMD /app/test.sh
 ---> Using cache
 ---> 9df62880070a
Successfully built 9df62880070a
Successfully tagged haproxy-reloads:latest
Creating dummy0
Binding extra ips
with all
[NOTICE] 303/213037 (13) : New worker #1 (16) forked
OK - with
43 worked
OK - with
44 worked
OK - with
45 worked
stats worked
Removing 43, switching to without
[WARNING] 303/213039 (13) : Reexecuting Master process
[WARNING] 303/213039 (16) : Stopping frontend main in 0 ms.
[WARNING] 303/213039 (16) : Stopping backend 200_ok in 0 ms.
[WARNING] 303/213039 (16) : Stopping proxy statsctl in 0 ms.
[WARNING] 303/213039 (16) : Stopping frontend GLOBAL in 0 ms.
[WARNING] 303/213039 (16) : Proxy main stopped (cumulated conns: FE: 3, BE: 0).
[WARNING] 303/213039 (16) : Proxy 200_ok stopped (cumulated conns: FE: 0, BE: 3).
[WARNING] 303/213039 (16) : Proxy statsctl stopped (cumulated conns: FE: 1, BE: 0).
[WARNING] 303/213039 (16) : Proxy GLOBAL stopped (cumulated conns: FE: 0, BE: 0).
[NOTICE] 303/213039 (13) : New worker #1 (30) forked
[WARNING] 303/213039 (13) : Former worker #1 (16) exited with code 0 (Exit)
OK - without
44 worked
OK - without
45 worked
stats worked
Switching back to with, .43 doesn't exist
[WARNING] 303/213041 (13) : Reexecuting Master process
[WARNING] 303/213041 (30) : Stopping frontend main in 0 ms.
[WARNING] 303/213041 (30) : Stopping backend 200_ok in 0 ms.
[WARNING] 303/213041 (30) : Stopping proxy statsctl in 0 ms.
[WARNING] 303/213041 (30) : Stopping frontend GLOBAL in 0 ms.
[WARNING] 303/213041 (30) : Proxy main stopped (cumulated conns: FE: 2, BE: 0).
[WARNING] 303/213041 (30) : Proxy 200_ok stopped (cumulated conns: FE: 0, BE: 2).
[WARNING] 303/213041 (30) : Proxy statsctl stopped (cumulated conns: FE: 1, BE: 0).
[WARNING] 303/213041 (30) : Proxy GLOBAL stopped (cumulated conns: FE: 0, BE: 0).
[NOTICE] 303/213041 (13) : New worker #1 (42) forked
[WARNING] 303/213041 (13) : Former worker #1 (30) exited with code 0 (Exit)
OK - with
44 worked
OK - with
45 worked
stats worked
[WARNING] 303/213043 (13) : Exiting Master process...
```
