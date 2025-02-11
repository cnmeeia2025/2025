FROM arm64v8/ubuntu:latest

# 更新 apt 源并安装编译依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libssl-dev \
    git

# 设置工作目录
WORKDIR /iperf3

# 下载 iperf3 源码
RUN git clone https://github.com/esnet/iperf.git .

# 切换到 iperf3 源码目录
WORKDIR /iperf3/src

# 自动配置、编译和安装 iperf3
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# 创建一个精简镜像 (可选，如果需要减小镜像体积)
FROM arm64v8/ubuntu:latest
COPY --from=0 /usr/local/bin/iperf3 /usr/local/bin/iperf3
COPY --from=0 /usr/local/lib /usr/local/lib
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
RUN ldconfig

# 声明 iperf3 默认端口
EXPOSE 5201

# 定义启动命令
CMD ["iperf3", "-s"]
