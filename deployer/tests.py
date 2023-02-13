import http.client
import json
from datetime import datetime as dt
import time

PORT = 8000
HOST = "localhost"
JWT = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0eXBlIjoiQUNDRVNTIFRPS0VOIiwiaWQiOiIzNDc0NDlkNDEyYTYxZDg1NjVjNzU4ODZhMzJlMzFmZDMxMGZmNWFlMDBjODIyMWE1ZGE5NjkyNGE3MmE5ZGI1IiwidXNlcm5hbWUiOiJBdmluYXNoIEtoYW4iLCJyb2xlIjoidXNlciIsImV4cCI6MTY3NjI5NDQ2NywiaWF0IjoxNjc2MjA4MDY3fQ.XdSboRIKpsiAybFVdwqRCHM6zuFUO1UlNqqEO0DbAaQ'


def get_trx_id_from_res(res):
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
    }
    conn.request("POST", "/user/transaction/sign", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))
    if res.status != 200:
        print("transaction failed")

def push(name=None):
    print("running "+name)
    def decorator(func):
        start_time = dt.now()
        def wrapper(*args, **kwargs):
            trx_id = func(*args, **kwargs)
            try:
                push_trx(trx_id)
            except Exception as e:
                print("transaction failed")
            end_time = dt.now()
            t = end_time - start_time
            print("time taken for "+name+" : ",t.seconds)
            return trx_id
        return wrapper
    return decorator

@push("Create Notice Test")
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
    }
    conn.request("POST", "/tdr/notice/create", payload, headers)
    res = conn.getresponse()
    _data = res.read()
    print(_data.decode("utf-8"))
    data = json.loads(_data)
    trx_id = data.get('data').get('trxId')
    return trx_id

#
# def create_and_push_notice_test():
#     start_time = dt.now()
#     trx_id = create_notice_test()
#     try:
#         push_trx(trx_id)
#
#     except Exception as e:
#         print('transaction failed')
#         print(e)
#     end_time = dt.now()
#     t = end_time - start_time
#     print("time for notice creation ", t.seconds)

@push("Create Application Test")
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
        "status": "pending",
        "noticeId": "notice"
    })
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/tdr/application/create", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)


# def create_and_push_application_test():
#     start_time = dt.now()
#     trx_id = create_application_test()
#     try:
#         push_trx(trx_id)
#
#     except Exception as e:
#         print('transaction failed')
#         print(e)
#     end_time = dt.now()
#     t = end_time - start_time
#     print("time for application creation ", t.seconds)
#

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

@push("Sign Application Test")
def signApplication():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "applicationId": "app123"
    })
    headers = {
    'Authorization': 'bearer ' + JWT,
    'Content-Type': 'application/json'
    }
    conn.request("POST", "/tdr/application/sign", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)

def sign_and_push_application_test():
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


def user_signed_status_test():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "applicationId": "app123"
    })
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/tdr/application/UserSignStatus", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))

@push("Verify Application Test")
def verify_application():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "applicationId": "app123"
    })
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/tdr/application/verify", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)




def run_all_test():
    # add_user_test()
    # print("running create and push notice test")
    # create_and_push_notice_test()
    print("adding user to the blockchain")
    add_user_test()
    create_notice_test()
    create_application_test()
    signApplication()
    verify_application()
    # verify_and_push_application()
def main():
    run_all_test()



if __name__ == "__main__":
    main()
