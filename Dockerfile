FROM haproxy:1.8.26

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl iproute2 net-tools \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app
COPY . .

CMD /app/test.sh
