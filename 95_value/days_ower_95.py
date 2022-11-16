# _*_ encoding: utf-8 _*_
# @Author    : fly
# @Time      : 2022/10/10 18:50
# @File      : days_ower_95.py
# @License   : Do What The F*ck You Want To Public License
import datetime
import owner_95
import time
import warnings


def day_95(business , owner_name, _date):
    owner_hosts = owner_95.get_hosts(business, owner_name)
    print(business, owner_name, "共有", len(owner_hosts), "台设备:")
    idc_95 = 0
    date_ = datetime.datetime.strptime(_date, "%Y-%m-%d")
    start_time = date_.strftime("%Y-%m-%d 20:00:00")
    end_time = date_.strftime("%Y-%m-%d 23:00:00")
    s = int(time.mktime(time.strptime(start_time, '%Y-%m-%d %H:%M:%S')))
    e = int(time.mktime(time.strptime(end_time, '%Y-%m-%d %H:%M:%S')))
    for h in owner_hosts:
        v_95 = owner_95.get_v_95(h, s, e)
        #print(h, v_95, "Mbps")
        idc_95 += v_95
    idc_95 = round(idc_95 / 1000, 2)
    print(_date,"机房日 95 值为:", idc_95, "Gbps")


def main(business , owner_name, in_date, days):
    dt = datetime.datetime.strptime(in_date, "%Y-%m-%d")
    for i in range(days):
        date_ = dt + datetime.timedelta(days=i)
        _date = date_.strftime("%Y-%m-%d")
        day_95(business, owner_name, _date)


if __name__ == '__main__':
    warnings.filterwarnings(action='ignore')
    main(business = "长A", owner_name = "MF_0002022", in_date="2022-10-07", days=3) # in_date:开始日期，days：统计天数
