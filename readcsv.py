#!/usr/bin/env python
#-*- coding:utf-8 -*-
############################
#File Name:
#Author: wudi
#Mail: programmerwudi@gmail.com
#Created Time: 2015-09-02 08:51:51
############################


#读取cvs表中内容
#转化为list后，取出对应字段对比两个表中指定字段
#将最终结果sort uniq 整理去重
#sort -u 1.lst|wc
#sort 1.lst|uniq |wc




import csv
import uniout
import string


#addres = csv.reader(file(u'adre.csv','rb'))
addres = csv.DictReader(file(u'adre.csv','rb'))
#c_d_id = csv.reader(file(u'c_id.csv','rb'))
c_d_id = csv.DictReader(file(u'uniq_c_id.csv','rb'))

res = list(addres)
resid = list(c_d_id)
i = 0 

for addr in res:
  for da in resid:
    if da['dayu'] == addr['use_id']:
      print da['ctrip']+","+da['dayu']+","+addr['use_id']+","+addr['city']+","+addr['country']+","+addr['addr']
#print i

#while i < len(res):
#  for addr in res:
#   for da in resid:
#     if da['dayu'] == addr['use_id']:
#       print da['ctrip']+","+da['dayu']+","+addr['use_id']+","+addr['city']+","+addr['country']+","+addr['addr']
#  #print i
#  i += 1

   # print i['rBFSe7CS-iM']
   # print "******"
   # print b['rBFSe7CS-iM']



