# _*_ encoding: utf-8 _*_
# @Author    : fly
# @Time      : 2022/8/25 23:22
# @File      : owner_95.py
# @License   : Do What The F*ck You Want To Public License
import datetime
import time
import requests

cookie = ""
hosts_url = "https://new.p2pcdn.com/app.py/devapi/getTableStatus?key=QNaUjD71KWZv4DXyEtmf"
all_host = "https://new.p2pcdn.com/app.py/devapi/getServersJSON?key=QNaUjD71KWZv4DXyEtmf"


def get_host_id():
    res = requests.get(all_host, verify=False)
    return {i["hostname"]: i["id"] for i in res.json() if i["status"] in {1, 2, 4}} # 1：离线，2：在线， 4：已审核


def get_v_95(hostname, s, e):
    host_id = get_host_id()
    d = {
        "timeStart": s,
        "timeEnd": e,
        "graphType": "single",
        "dataType": "netSpeed",
        "id": host_id[hostname],
        "location": "",
        "carrier": ""
    }
    v_95 = 0
    url = "https://p2pcdn.com/app.py/graph"
    headers = {"cookie": cookie}
    res = requests.post(url, headers = headers, data=d)
    v_95 = round(res.json()["data"]["netSentSpeed"]["y95"] / 1000000, 2)
    # print(hostname, v_95)
    return v_95


def get_hosts(business, owner_name):
    res = requests.get(hosts_url, verify=False)
    host_list = []

    for host in res.json():
        if host["business"] == business:
            host_list.append(host)

    if "｜" not in owner_name:
        owner_hosts = []
        for host in host_list:
            if host['owner'] == owner_name:
                owner_hosts.append(host['hostname'])
        # print(business, owner_name, "共有", len(owner_hosts), "台设备:")
        # for host in owner_hosts:
        #     print(host)
        return owner_hosts
    else:
        owner_location_hosts = []
        for host in host_list:
            if f"{host['owner']}｜{host['location']}" == owner_name:
                owner_location_hosts.append(host['hostname'])
        # print(business, owner_name, "共有", len(owner_location_hosts), "台设备：")
        # for host in owner_location_hosts:
        #     print(host)
        return owner_location_hosts


def main(business , owner_name, _date):
    owner_hosts = get_hosts(business, owner_name)
    print(business, owner_name, "共有", len(owner_hosts), "台设备:")
    idc_95 = 0
    date_ = datetime.datetime.strptime(_date, "%Y-%m-%d")
    start_time = date_.strftime("%Y-%m-%d 20:00:00")
    end_time = date_.strftime("%Y-%m-%d 23:00:00")
    s = int(time.mktime(time.strptime(start_time, '%Y-%m-%d %H:%M:%S')))
    e = int(time.mktime(time.strptime(end_time, '%Y-%m-%d %H:%M:%S')))
    for h in owner_hosts:
        v_95 = get_v_95(h, s, e)
        print(h, v_95, "Mbps")
        idc_95 += v_95
    idc_95 = round(idc_95 / 1000, 2)
    print("\n机房日 95 值为:", idc_95, "Gbps")


if __name__ == '__main__':
    main(business = "长A", owner_name = "MF_000711", _date="2022-10-09")
