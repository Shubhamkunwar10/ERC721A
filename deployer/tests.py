import http.client
import json
from datetime import datetime as dt
import time

PORT = 8000
HOST = "localhost"
JWT = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0eXBlIjoiQUNDRVNTIFRPS0VOIiwiaWQiOiIzNDc0NDlkNDEyYTYxZDg1NjVjNzU4ODZhMzJlMzFmZDMxMGZmNWFlMDBjODIyMWE1ZGE5NjkyNGE3MmE5ZGI1IiwidXNlcm5hbWUiOiJBdmluYXNoIEtoYW4iLCJyb2xlIjoidXNlciIsImV4cCI6MTY3NjExMjM2MiwiaWF0IjoxNjc2MDI1OTYyfQ.7QqJDgtrKI06cJvDlbTpLTl2RLdQkx-druf7jjI8qTI'


def get_trx_id_from_res(res):
    _data = res.read()
    print(_data.decode("utf-8"))
    data = json.loads(_data)
    trx_id = data.get('data').get('trxId')
    return trx_id


def create_notice_test():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "noticeId": "notice",
        "noticeDate": "01/01/2023",
        "khasraOrPlotNo": "Field is required",
        "villageOrWard": "Field is required",
        "Tehsil": "Field is required",
        "district": "Field is required",
        "landUse": "Field is required",
        "masterPlan": "Field is required"
    })
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json',
        'Cookie': 'refreshToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0eXBlIjoiUkVGUkVTSCBUT0tFTiIsImlkIjoiMzQ3NDQ5ZDQxMmE2MWQ4NTY1Yzc1ODg2YTMyZTMxZmQzMTBmZjVhZTAwYzgyMjFhNWRhOTY5MjRhNzJhOWRiNSIsInVzZXJuYW1lIjoiQXZpbmFzaCBLaGFuIiwicm9sZSI6InVzZXIiLCJleHAiOjE2NzYwMTM1NjksImlhdCI6MTY3NTQwODc2OSwidG9rZW5faWQiOiJrWm5RaFJLTjEzajdoNTdOUnp4NHBmUGRzYVRLV0szZSJ9.3p1RdbW2g9VwrtiHcfORGLqw_Yo1Ef0hammN_pWMSi8'
    }
    conn.request("POST", "/tdr/notice/create", payload, headers)
    res = conn.getresponse()
    _data = res.read()
    print(_data.decode("utf-8"))
    data = json.loads(_data)
    trx_id = data.get('data').get('trxId')
    return trx_id


def push_trx(trx_id):
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "otp": "1234565",
        "password": "ramdwivedI12=",
        "trxId": trx_id
    })
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json',
        'Cookie': 'refreshToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0eXBlIjoiUkVGUkVTSCBUT0tFTiIsImlkIjoiMzQ3NDQ5ZDQxMmE2MWQ4NTY1Yzc1ODg2YTMyZTMxZmQzMTBmZjVhZTAwYzgyMjFhNWRhOTY5MjRhNzJhOWRiNSIsInVzZXJuYW1lIjoiQXZpbmFzaCBLaGFuIiwicm9sZSI6InVzZXIiLCJleHAiOjE2NzU5MzI1NzksImlhdCI6MTY3NTMyNzc3OSwidG9rZW5faWQiOiJpZXFaQVh2dXluOHRuTWlJdnJYcnpvbGMyQ25acVE5aiJ9.FoYC78ZqGBK74wIyain1zfN7j4PY7fOuZ-oKjSzqdYc'
    }
    conn.request("POST", "/user/transaction/sign", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))
    if res.status != 200:
        print("transaction failed")


def create_and_push_notice_test():
    start_time = dt.now()
    trx_id = create_notice_test()
    try:
        push_trx(trx_id)

    except Exception as e:
        print('transaction failed')
        print(e)
    end_time = dt.now()
    t = end_time - start_time
    print("time for notice creation ", t.seconds)


def create_application_test():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "applicationId": "app123",
        "applicationDate": "01/01/2023",
        "place": "Mumbai",
        "farRequested": 2,
        "farGranted": 1,
        "applicants": [
            {
                "userId": "347449d412a61d8565c75886a32e31fd310ff5ae00c8221a5da96924a72a9db5"
            }
        ],
        "status": "submitted",
        "noticeId": "notice"
    })
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/tdr/application/create", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)


def create_and_push_applicatin_test():
    start_time = dt.now()
    trx_id = create_application_test()
    try:
        push_trx(trx_id)

    except Exception as e:
        print('transaction failed')
        print(e)
    end_time = dt.now()
    t = end_time - start_time
    print("time for application creation ", t.seconds)


def add_user_test():
    conn = http.client.HTTPConnection(HOST, PORT)
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json'
    }
    payload = ''

    conn.request("POST", "/tdr/addUser", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))

def signApplication():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "applicationId": "app123"
    })
    headers = {
    'Authorization': 'bearer ' + JWT,
    'Content-Type': 'application/json'
    }
    conn.request("POST", "/tdr/signApplication", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)

def sign_and_push_applicatin_test():
    start_time = dt.now()
    trx_id = signApplication()
    try:
        push_trx(trx_id)

    except Exception as e:
        print('transaction failed')
        print(e)
    end_time = dt.now()
    t = end_time - start_time
    print("time for application creation ", t.seconds)
def run_all_test():
    print("adding user to the blockchain")
    add_user_test()
    print("running create and push notice test")
    create_and_push_notice_test()
    print('running create and push application test')
    create_and_push_applicatin_test()
    print("runing sign and push application test")
    sign_and_push_applicatin_test()

def main():
    run_all_test()



if __name__ == "__main__":
    main()
