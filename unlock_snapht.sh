#!/bin/bash

# 解决工作设备无法修改显示器关闭时常脚本
# 默认1小时以上关闭显示器 
# 工作时间段（24 小时制），注意时间格式为 HH:MM-HH:MM
WORKING_HOURS="09:00-22:00"

LOG_FILE="$HOME/unlock-screen.log"

while true; do
    # 获取当前时间（24 小时制）
    CURRENT_TIME=$(date +"%H:%M")

    # 判断当前是否处于工作时间段内
    if [[ "$CURRENT_TIME" > "${WORKING_HOURS%-*}" && "$CURRENT_TIME" < "${WORKING_HOURS#*-}" ]]; then
        # 如果屏幕已经关闭，则输入密码解锁
        if [ "$(pmset -g ps | awk 'NR==2 {print $2}')" == "1" ]; then
            echo "Unlocking screen..."
            # 输入密码以解锁屏幕，注意需要将 YOUR_PASSWORD 替换为你的密码
            # echo "YOUR_PASSWORD" | sudo -S loginwindow autoLoginUser $(whoami)
        fi
        # 使用防止睡眠模式，时长为 1 小时
        caffeinate -dimsu -t 3600 &
        # 记录日志
        echo "$(date +"%Y-%m-%d %H:%M:%S"): Screen unlocked." >> "$LOG_FILE"
    else
        # 如果屏幕已经关闭，则输入密码解锁
        if [ "$(pmset -g ps | awk 'NR==2 {print $2}')" == "1" ]; then
            echo "Unlocking screen..."
            # 输入密码以解锁屏幕，注意需要将 YOUR_PASSWORD 替换为你的密码
            # echo "YOUR_PASSWORD" | sudo -S loginwindow autoLoginUser $(whoami)
        fi
        # 使用防止睡眠模式，但允许在屏幕锁定时关闭显示器
        caffeinate -dimsu -t 3600 -t 30 &
        echo "$(date +"%Y-%m-%d %H:%M:%S"): Not in working hours." >> "$LOG_FILE"

    fi

    # 休眠 1 分钟后再次检查
    sleep 600
done

