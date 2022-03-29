#!/bin/sh

gitPath="/git"
rootPath="/Sub-Store"
backend="$rootPath/backend"
web="$rootPath/web"
nginx="$rootPath/nginx"

cd /git/backend

if [ ! -f "$web/package.json" ]; then    
    echo "初始化配置。。。"
    cp -r /git/. /Sub-Store
    cd "$web" && cnpm install 
    cd "$backend" && cnpm install 
fi

echo "删除自带后端地址，追加配置环境变量配置的后端地址。。。"
sed -i "/BACKEND_BASE\|DEBUG\|DOMIAN/d" "$web/src/config.js"
echo "export const BACKEND_BASE = '${DOMAIN}';" >>"$web/src/config.js"
 
echo "判断是否存在前端静态资源。。。"
if [ ! -f "$web/dist/index.html" ]; then
    cd "$web"
    echo "执行编译前端静态资源。。。"    
    npm run build
    cp -rf  "$web/dist" /var/www/sub-store
    echo "结束编译"
fi

echo "启动前端web服务。。。"
mkdir /etc/nginx/conf.d
cp -r /Sub-Store/nginx/front.conf /etc/nginx/conf.d
nginx -c /etc/nginx/nginx.conf 
nginx -s reload

echo "启动后端服务。。。"
cd "$backend"
pm2 start sub-store.js
echo "打印后端日志"
pm2 log sub-store