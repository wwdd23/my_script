#!/usr/bin/env python3
#-*- coding:utf-8 -*-
############################
#File Name:
#Author: wudi
#Mail: programmerwudi@gmail.com
#Created Time: 2023-03-18 03:39:13
############################

import openai
import readline

openai.api_key ='skC' 

print("Welcome to ChatGPT! Type 'exit' to quit.\n")
model_engine = "text-davinci-003"


while True:
    prompt = input("You: ")
    if prompt == "exit":
        break
    response = openai.Completion.create(
        engine=model_engine,
        prompt=prompt,
        max_tokens=1024,
        n=1,
        stop=None,
        temperature=0.5,


    )
    message = response.choices[0].text.strip()
    print("ChatGPT: " + message + "\n")






