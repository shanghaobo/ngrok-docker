# Ngrok-Docker

> Docker 一键编译 Ngrok 和一键启动，支持自签名证书和 SSL 证书。

## Ngrok 服务端

#### 启动前的配置

修改`.env`文件配置。

- 使用自己申请的证书时，将证书的`server.crt`、`server.key`、`rootCA.pem`文件放在项目的`ssl`目录内，并配置路径为`/ssl/xxx`。
- 如不使用自己的证书，将`.env`里的`NGROK_TLS_CRT`、`NGROK_TLS_KEY`、`NGROK_TLS_CA`去掉即可在编译时生成自签名证书。（若无 https 代理需求，使用自签名证书即可）
- 如果使用自己申请的证书，旧证书过期后若新申请的证书 CA 与原来的一致，可直接修改此处的证书路径后重启 docker 服务，不需要重新编译客户端。

```env
# ngrok域名
NGROK_DOMAIN=ngrok.xxx.com

# http端口
NGROK_HTTP_PORT=16880

# https端口
NGROK_HTTPS_PORT=16844

# 隧道端口
NGROK_TUNNEL_PORT=4443

# ssl证书路径（可不设置）
NGROK_TLS_CRT=/ssl/server.crt

# ssl证书密钥路径（可不设置）
NGROK_TLS_KEY=/ssl/server.key

# ssl证书CA路径（可不设置）
NGROK_TLS_CA=/ssl/rootCA.pem
```

#### 1.Docker 方式启动

- 构建 Docker 镜像

```bash
docker build -t ngrok-docker .
```

- 启动 Docker 容器

```bash
# 映射的端口分别是 http端口 https端口 隧道端口
docker run -itd --name ngrok-docker -p 16880:16880 -p 16844:16844 -p 4443:4443 --env-file=.env ngrok-docker
```

#### 2.docker-compose 方式启动

- 启动

```bash
docker-compose up -d ngrok
```

## Ngrok 客户端

将编译好的客户端从容器中拷贝出来

```bash
# Windows版
docker cp ngrok-docker:/ngrok/bin/windows_amd64/ngrok.exe .

# Linux版
docker cp ngrok-docker:/ngrok/bin/ngrok .
```

注：`ngrok-docker`为容器名称或容器 id，可用`docker ps -a`查看容器 id 或名称

#### Windows 版

- 配置文件示例

```cfg
# ngrok.cfg
server_addr: "ngrok.xxx.com:4443"
trust_host_root_certs: false
tunnels:
  http:
    subdomain: "test"
    proto:
      http: 8001
  tcp:
    remote_port: 23001
    proto:
      tcp: 8001
```

注：经过测试，若配置自己申请的 ssl 证书，若域名为`ngrok.xxx.com`，支持以下两种配置可正常访问 https 链接：

- 配置 1
  此方式服务端配置的证书域名为`*.ngrok.xxx.com`，支持多个 https 链接。如下配置可正常访问`https://test1.ngrok.xxx.com:16844`和`https://test2.ngrok.xxx.com:16844`（16844 为我配置的 ngrok 监听的 https 端口）。

```cfg
# ngrok.cfg
server_addr: "test.ngrok.xxx.com:4443"
trust_host_root_certs: true
tunnels:
  https:
    subdomain: "test1"
    proto:
      https: 8001
  https2:
    subdomain: "test2"
    proto:
      https: 8002
```

- 配置 2

此方式服务端配置的证书域名为`ngrok.xxx.com`，只支持一个 https 链接。如下配置可正常访问`https://ngrok.xxx.com:16844`（16844 为我配置的 ngrok 监听的 https 端口）。

```cfg
# ngrok.cfg
server_addr: "ngrok.xxx.com:4443"
trust_host_root_certs: true
tunnels:
  https:
    hostname: "ngrok.xxx.com:16844"
    proto:
      https: 8001
```

- 启动客户端

```bash
ngrok.exe -config=ngrok.cfg -log=log.log start-all
```

#### Linux 版

- 配置文件

```yml
# ngrok.yml
server_addr: "ngrok.xxx.com:4443"
trust_host_root_certs: false
tunnels:
  http:
    subdomain: "test"
    proto:
      http: 8001
  tcp:
    remote_port: 23001
    proto:
      tcp: 8001
```

- 启动客户端

```bash
./ngrok --config=ngrok.yml start-all -log stdout
```

## 其他

若配置了 `https` 且没有用 `443` 端口，访问时需要加端口号（如`https://ngrok.xxx.com:16844`），可通过配置 Nginx 去掉端口号访问。具体参考：[https://www.qinyu.cc/archives/128.html](https://www.qinyu.cc/archives/128.html)
