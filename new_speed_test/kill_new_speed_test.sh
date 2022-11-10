#!/bin/bash

ps auxf|grep 'tmp'|grep speed|grep ppp|awk '{print $2}'|xargs kill -9  && ps auxf| grep "curl"   | grep -v grep | awk  '{print $2}'   | xargs echo   | xargs  kill -9
sleep 5
ps auxf|grep 'tmp'|grep speed|grep ppp|awk '{print $2}'|xargs kill -9 && ps auxf| grep "curl"   | grep -v grep | awk  '{print $2}'   | xargs echo   | xargs  kill -9

ps -ef | grep 'new_speed_test.py' | grep -v grep | awk '{print $2}' | xargs kill -9
