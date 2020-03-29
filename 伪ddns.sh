#!/bin/sh
#腾讯云dns更新
oldIPFile=/tmp/oldip
cookie="xxxxxx"
domain="you_domain"
child_domain="子域"
your_record="抓包获取"
gtk="抓包获取，在提交请求的链接后尾"

updateIp(){
  result=$(curl -s --cookie "$cookie" -d "domain=$domain&sub_domain=$child_domain&record_type=A&record_line=%E9%BB%98%E8%AE%A4&ttl=600&q_project_id=-1&value=$myip&mx=5&record_id=$your_record" https://wss.cloud.tencent.com/dns/api/record/update?g_tk=$gtk)
  grepResult=$(echo  $result | grep "\"code\":0")
  if [ "$grepResult" != "" ]
   then
       logger -t "【DDNS】" '更新成功'
       echo "$myip" > $oldIPFile
   else
       logger -t "【DDNS】" '更新失败'
       logger -t "【DDNS】" "$result"
  fi
}

logger -t "【DDNS】" "正在获取ip"
myip=$(curl -s ifconfig.me)
logger -t "【DDNS】" "当前ip:$myip"


if [ ! -f "$oldIPFile" ]; then
  logger -t "【DDNS】" "文件不存在，更新"
  updateIp;
else
  oldip=$(cat $oldIPFile)
  logger -t "【DDNS】" "旧IP:$oldip"
  if [ "$myip" = "$oldip" ]; then
    logger -t "【DDNS】" "当前IP与旧IP相同，不更新"
  else
    logger -t "【DDNS】" "当前IP与旧IP不同，更新"
    updateIp
  fi
fi
