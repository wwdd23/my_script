#!/bin/bash
###################
# Author:  wudi
# Mail: programmerwudi@gmail.com 
# Description: 
# Created Time: 2016-05-16 11:44:27
###################


#### 启动FishTrip analytics 数据环境

# 启动 mongod analytics

PIDS_MONGO= ps aux |grep mongo |grep -v grep | awk '{print $2}'

if [ ! -n "$PIDS_MONGO"  ]; then
  /opt/mongo/bin/mongod &
else
  echo "mongod is running"
  echo $PIDS_MONGO 
  #kill $PIDS_MONGO
fi

# 启动 mongod analytics
PIDS_ELAST= ps aux |grep elasticsearch |grep -v grep | awk '{print $2}'
if [ ! -n "$PIDS_ELAST" ]; then
  echo  ps aux |grep elasticsearch |grep -v grep | awk '{print $2}'
  /opt/elasticsearch-1.7.3/bin/elasticsearch -d
else
  echo "Elasticsearch is running"
  echo $PIDS_ELAST
  #kill $PIDS_ELAST
fi

# 启动pg 
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start

redis-server /usr/local/etc/redis.conf
