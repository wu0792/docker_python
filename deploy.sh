#!/bin/bash

# === 配置部分（你可以按需修改） ===
APP_NAME="hello-world-app"
APP_VERSION="1.0.0"
TAR_NAME="${APP_NAME}-${APP_VERSION}.tar"
SERVER_USER="root"
SERVER_IP="182.92.76.247"
SERVER_PATH="/home/${SERVER_USER}/docker-images"

# === 构建镜像为 Linux 平台（兼容 Linux 服务器） ===
echo "🚧 Building Docker image for linux/amd64..."
docker buildx build --platform=linux/amd64 -t ${APP_NAME}:${APP_VERSION} --load .

# === 导出镜像为 tar 文件 ===
echo "📦 Saving Docker image as ${TAR_NAME}..."
docker save -o ${TAR_NAME} ${APP_NAME}:${APP_VERSION}

# === 上传镜像到服务器 ===
echo "🚀 Uploading to ${SERVER_USER}@${SERVER_IP}..."
ssh ${SERVER_USER}@${SERVER_IP} "mkdir -p ${SERVER_PATH}"
scp ${TAR_NAME} ${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/

# === 在服务器加载并运行容器 ===
echo "🎮 Deploying on remote server..."
ssh ${SERVER_USER}@${SERVER_IP} <<EOF
  cd ${SERVER_PATH}
  docker load < ${TAR_NAME}
  docker stop ${APP_NAME} || true
  docker rm ${APP_NAME} || true
  docker run -d --name ${APP_NAME} -p 9000:9000 ${APP_NAME}:${APP_VERSION}
EOF

# === 清理本地临时 tar 文件 ===
echo "🧹 Cleaning up..."
rm -f ${TAR_NAME}

echo "✅ Deployment complete! App is live at http://${SERVER_IP}:9000"