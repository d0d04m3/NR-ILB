# nginx-reverse-proxy-in-docker

- [working solution on okteto](https://reverseproxy-nginx-reverse-proxy-in-docker-bronifty.cloud.okteto.net/)

- [Youtube Tutorial](https://youtu.be/bUBBv3PkxMI)

- [Blog Poast](https://dev.to/bronifty/nginx-reverse-proxy-in-docker-42lm)

- usage

```
docker-compose up -d
```

- GET endpoints (4 servers being proxied - hit each one in your browser window):

  - /
  - /nginx
  - /apache
  - /node2

- notes:

  - 4 servers running; 2 on port 80, 2 on port 3000; nginx reverse proxy's all 4 on localhost (default port 80) by the location (route or path on the browser bar - like /node or /apache)

- other helpful docker commands:

```
docker-compose down
docker container stop $(docker ps -aq)
docker system prune -af
```
