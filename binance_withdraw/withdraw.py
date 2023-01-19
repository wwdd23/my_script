#!/usr/bin/env python3
#-*- coding:utf-8 -*-
"""
File Name:
Author: woody
Mail: wudi@cobo.com
Created Time: 2023-01-16 21:41:39
"""

import logging
from binance.spot import Spot as Client
from binance.lib.utils import config_logging
from configparser import ConfigParser
from decimal import Decimal
import time


config = ConfigParser()
config.read("./config.ini")

#config_logging(logging, logging.DEBUG)

api_key = config["keys"]["api_key"]
api_secret = config["keys"]["api_secret"]
coin = config["keys"]["coin"]
set_amount = config["keys"]["set_amount"]
address = config["keys"]["address"]

spot_client = Client(api_key, api_secret)
# logging.info(spot_client.api_trading_status())
# 查询账户镜像数据
# logging.info(spot_client.account_snapshot("SPOT"))
# print(spot_client.account())


# 获取划转币种基本信息
asset_detail = spot_client.coin_info()

info = [x for x in asset_detail if x['coin'] == coin][0]


free = info["free"]
freeze = info["freeze"]
locked = info["locked"]
fee = info["networkList"][0]["withdrawFee"]
wmin =info["networkList"][0]["withdrawMin"]
wmax = info["networkList"][0]["withdrawMax"]
print(f"币种信息 {coin} \nfree {free} | freeze {freeze} | locked {locked}\n提币手续费 {fee} | 最小提币 {wmin} | 最大提币 {wmax}")

input("Press Enter to continue... \n")


# 查询账户现货钱包信息
account = spot_client.account()

# print beth 当前持仓
beth_val = [x for x in account["balances"] if x['asset'] == coin]
print(f"%s 当前持仓信息 %s" % (coin, beth_val))

# 可划余额
amount_val = float(beth_val[0]["free"])
print("%s 可划转余额:  %s \n" % (coin, amount_val))

user_input = input("请确认划转数量是否一致[y/N]...")

yes_choices = ['yes', 'y']
no_choices = ['no', 'n']

if user_input.lower() in yes_choices:
    print('user typed yes')

    # 如果 amount < min_amount 提示 并退出
    if amount_val <= float(wmin): 
        print("%s < 最小提币数量: %s ----- 无法划转" % (coin , wmin))
        input("Press Enter to exit...")
        exit()
    
    print("10s 后执行划转操作 退出 ctrl+c \n")
    for x in range(10, -1, -1):
        s = "倒计时" + str(x) + "秒"
        print(s, end = "")
        print("\b" * (len(s)*2), end= "", flush=True)
        time.sleep(1)
    
    # 转账
    # 提币 coin 数量  地址
    print(coin, amount_val , address)
    # logging.info(spot_client.withdraw(coin="BETH", amount=0.01, address=""))
    
    # logging.info(spot_client.withdraw(coin=coin, amount=amount_val, address=address))
elif user_input.lower() in no_choices:
    print('退出重新确认web端数量')
else:
    print('Type defalut no')
