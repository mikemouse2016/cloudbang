#!/bin/bash

#=====================
# Info    : Cloudbang manage node service check script
# Author  : zhouyq@goodrain.com
# Version : 1.0.0 
# Histroy : 
#=====================

function PrintInfo {
  infotype=$1
  info=$2

  if [ "$infotype" == "info" ];then
    echo -e "\033[32minfo\033[0m: $2"
  else
    echo -e "\033[31merror:\033[0m $2"
  fi

}


BaseServiceList="beanstalkd etcd mysqld"

K8SList="kube-apiserver kube-controller-manager kube-scheduler"

SystemList="nginx supervisor"


clear

# docker
echo -e "\033[42;37mCheck docker daemon service...\033[0m"
for i in {30..0};do
  if pgrep -f /usr/bin/docker >/dev/null 2>&1;then
    PrintInfo info "docker is OK"
    break
  else
    PrintInfo error "docker is down,start service..."
    start docker
  fi
  sleep 1
done

# BaseServiceList
echo -e "\033[42;37mCheck Base Services...\033[0m"
for s in $BaseServiceList
do
    isok=`pgrep -f $s`
    if [ "$isok" == "" ];then
      PrintInfo error "$s is down,start service..."
      service $s start && PrintInfo info "$s started."
    else
      PrintInfo info "$s is OK"
    fi
done

# K8SList
echo -e "\n\033[42;37mCheck Kubernetes services...\033[0m"
for s in $K8SList
do
    isok=`pgrep -f $s`
    if [ "$isok" == "" ];then
      PrintInfo error "$s is down,start service..."
      start $s && PrintInfo info "$s started."
    else
      PrintInfo info "$s is OK"
    fi
done


# SystemList
echo -e "\n\033[42;37mCheck Platform services...\033[0m"
for s in $SystemList
do
    isok=`pgrep -f $s`
    if [ "$isok" == "" ];then
      PrintInfo error "$s is down,start service..."
      service $s start && PrintInfo info "$s started."
    else
      PrintInfo info "$s is OK"
    fi
done


# Docker containers
echo -e "\n\033[42;37mCheck container services...\033[0m"
dc-compose up -d
