#!/usr/bin/python
import os
import random
import re


import sys
import datetime
import requests
import threading
import time
import inspect
import ctypes
import psutil
import uuid
import netifaces
import platform


def save_log(text):
    with open("/tmp/download_speed.log", "a") as f:
    # with open("speed.log", "a") as f:
        f.write(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + " " + text + "\n")

save_log("running...")



def get_response_time(url):
    global near_nodes
    try:
        start_time = time.time()
        res = requests.get(url, timeout=5)
        use_time = time.time() - start_time
        # print("finish: ", {"url": url, "use_time": use_time})
        near_nodes.append({"url": url, "use_time": use_time})
    except:
        pass


def start_download(nics):
    node = random.choice(near_nodes)
    url = node["url"] + "/speedtest/random7000x7000.jpg"
    while True:
        for nic in nics:
            try:
                cmd = "curl -s -o /dev/null --interface {} --connect-timeout 10 --max-time 180 {} && echo 'ok'".format(nic,url)
                print(cmd)
                os.popen(cmd).read()
            except:
                time.sleep(1)
                continue


def getNetworkAdapters():
    nicList = []
    if platform.system() == "Windows":
        for adapter in psutil.net_io_counters(pernic=True):
            nicList.append(adapter)
    else:
        allList = netifaces.interfaces()
        for adapter in allList:
            if adapter.startswith("bond"):
                nicList.append(adapter)
        if not nicList:
            print(allList)
            for adapter in allList:
                if adapter.startswith("ppp"):
                    nicList.append(adapter)
        if not nicList:
            for adapter in allList:
                if not (adapter.startswith("lo") or adapter.startswith("br") or adapter.startswith("docker") or adapter.startswith("virbr") or adapter.startswith("ppp") or adapter.startswith("yk") or adapter.startswith("macvlan") or adapter.startswith("wan") or "." in adapter):
                    nicList.append(adapter)
    return nicList

nicList = getNetworkAdapters()


def get_recv_bytes():
    total = 0
    nets = psutil.net_io_counters(pernic=True)
    for i in nicList:
        total += nets[i].bytes_recv
    return total


def get_speed():
    before = 0
    add, reduce = 0, 0
    global run
    run = True

    pool = []
    for i in range(100):
        th = threading.Thread(target=start_download,args=(nicList,))
        pool.append(th)
    for th in pool:
        th.start()

    while True:
        before = get_recv_bytes()
        time.sleep(1)
        now = get_recv_bytes()
        bytes = now - before
        speed = bytes * 8 / 1024 / 1024.0
        record = "bytes: {}  {} Mbps/s".format(bytes, round(speed, 2))
        print(record)
        save_log(record)
        time.sleep(60)

    # for th in pool:
    #     th.join()


if __name__ == '__main__':

    run = False

    urls = [
        'http://www.speedtest.net/speedtest-servers-static.php',
        'http://c.speedtest.net/speedtest-servers-static.php',
        'http://www.speedtest.net/speedtest-servers.php',
        'http://c.speedtest.net/speedtest-servers.php',
    ]

    nodes = []
    for url in urls:
        try:
            res = requests.get(url, timeout=(5, 5))
            us = re.findall('<server url="(.*)" lat', res.text)
            for u in us:
                # print(u)
                nodes.append(u)
        except:
            pass

    near_nodes = []

    th_l = []
    for node in nodes:
        # node = "http://speedtest.arrowebonline.com:8080/speedtest/upload.php"
        path = "speedtest/"
        start = node.index(path)
        url = node[:start]  # + len(path)] + "random350x350.jpg"
        print(url)
        th_l.append(threading.Thread(target=get_response_time, args=(url,)))

    for th in th_l:
        th.start()

    time.sleep(5)

    for th in th_l:
        th.join()

    print("len(near_nodes): ", len(near_nodes))

    thread_controler = {}

    nicList = getNetworkAdapters()

  #  print nicList
 #   sys.exit()


    get_speed()
