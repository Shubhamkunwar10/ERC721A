import http.client
import json
from datetime import datetime as dt
from time import sleep

PORT = 8000
HOST = "localhost"
JWT = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0eXBlIjoiQUNDRVNTIFRPS0VOIiwiaWQiOiIzNDc0NDlkNDEyYTYxZDg1NjVjNzU4ODZhMzJlMzFmZDMxMGZmNWFlMDBjODIyMWE1ZGE5NjkyNGE3MmE5ZGI1IiwidXNlcm5hbWUiOiJBdmluYXNoIEtoYW4iLCJyb2xlIjoidXNlciIsImV4cCI6MTY3NzQ4ODEwNywiaWF0IjoxNjc3NDg0NTA3fQ.se9byj5XNQ6hLabwpfBPIxdj9B3imP_SghJ8tFFl5Rc'
conn = http.client.HTTPConnection(HOST, PORT)
headers = {
    'Authorization': 'bearer ' + JWT,
    'Content-Type': 'application/json'
}

global notice_id
global tdr_application_id
global dta_id
global dua_id


def get_trx_id_from_res(res):
    _data = res.read()
    print(_data.decode("utf-8"))
    data = json.loads(_data)
    trx_id = data.get('data').get('trxId')
    return trx_id


def push_trx(trx_id):
    sleep(1)
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
    print("running " + name)

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
            print("time taken for " + name + " : ", t.seconds)
            return trx_id

        return wrapper

    return decorator


@push("Create Notice Test")
def create_notice_test():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "timeStamp": int(dt.now().timestamp()),
        "landInfo": {
            "khasraOrPlotNo": "0x1234567890123456789012345678901234567890123456789012345678901234",
            "villageOrWard": "0x1234567890123456789012345678901234567890123456789012345678901234",
            "Tehsil": "0x1234567890123456789012345678901234567890123456789012345678901234",
            "district": "0x1234567890123456789012345678901234567890123456789012345678901234"
        },
        "masterPlanInfo": {
            "landUse": "0x1234567890123456789012345678901234567890123456789012345678901234",
            "masterPlan": "0x1234567890123456789012345678901234567890123456789012345678901234",
            "roadWidth": 20,
            "areaType": "UNDEVELOPED"
        },
        "areaSurrendered": 1000,
        "circleRateSurrendered": 2000,
        "status": "PENDING"
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
    global notice_id
    notice_id = data.get('data').get('noticeId')
    return trx_id


@push("Create Application Test")
def create_application_test():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "tdrApplication": {
            "timeStamp": "1677061679",
            "place": "Mumbai",
            "farRequested": 2,
            "circleRateUtilized": 2,
            "applicants": [
                {
                    "userId": "347449d412a61d8565c75886a32e31fd310ff5ae00c8221a5da96924a72a9db5"
                }
            ],
            "status": "pending",
            "noticeId": notice_id
        },
        "documents": {
            "aadhaar": {
                "file_type": "pdf",
                "file_data": "JVBERi0xLjQKJ..."
            }
        }
    })
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/tdr/application/create", payload, headers)
    res = conn.getresponse()
    _data = res.read()
    print(_data.decode("utf-8"))
    data = json.loads(_data)
    trx_id = data.get('data').get('trxId')
    global tdr_application_id
    tdr_application_id= data.get('data').get('applicationId')
    return trx_id


def add_user_test():
    payload = ''

    conn.request("POST", "/tdr/addUser", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))


def add_officer_test():
    payload = json.dumps({
        "userId": "347449d412a61d8565c75886a32e31fd310ff5ae00c8221a5da96924a72a9db5",
        "role": "verifier",
        "department": "land",
        "zone": "zone_1"
    })
    conn.request("POST", "/user/kda/addOfficer", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))


def update_officer_test():
    payload = json.dumps({
        "userId": "347449d412a61d8565c75886a32e31fd310ff5ae00c8221a5da96924a72a9db5",
        "role": "admin",
        "department": "land",
        "zone": "zone_1"
    })
    conn.request("POST", "/user/kda/updateOfficer", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))


@push("Sign Application Test")
def signApplication():
    payload = json.dumps({
        "applicationId": tdr_application_id
    })
    conn.request("POST", "/tdr/application/sign", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)


def user_signed_status_test():
    conn = http.client.HTTPConnection(HOST, PORT)
    payload = json.dumps({
        "applicationId": tdr_application_id
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
        "applicationId": tdr_application_id
    })
    headers = {
        'Authorization': 'bearer ' + JWT,
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/tdr/application/verify", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)


@push("Approve Application Test")
def approve_applicaiton_test():
    payload = json.dumps({
        "applicationId":tdr_application_id
    })
    conn.request("POST", "/tdr/application/approve", payload, headers)
    res = conn.getresponse()
    # data = res.read()
    # print(data.decode("utf-8"))
    return get_trx_id_from_res(res)


@push("Issue DRC Test")
def issue_drc_test():
    payload = json.dumps({
        "applicationId": tdr_application_id,
        "farGranted": 150
    })
    conn.request("POST", "/tdr/application/issueDrc", payload, headers)
    res = conn.getresponse()
    # data = res.read()
    # print(data.decode("utf-8"))
    return get_trx_id_from_res(res)


@push("create dta  Test")
def create_dta_test():
    payload = json.dumps({
        "dta": {
            "drcId": "KDATA0000067",
            "farTransferred": 50,
            "buyers": [
                "347449d412a61d8565c75886a32e31fd310ff5ae00c8221a5da96924a72a9d23"
            ],
            "status": "pending"
        },
        "documents": {
            "saleDeed": {
                "file_type": "pdf",
                "file_data": "JVBERi0xLjQKJ..."
            }
        }
    })
    conn.request("POST", "/drc/application/transfer/create", payload, headers)
    res = conn.getresponse()
    _data = res.read()
    print(_data.decode("utf-8"))
    data = json.loads(_data)
    trx_id = data.get('data').get('trxId')
    global dta_id
    dta_id= data.get('data').get('applicationId')
    return trx_id

@push("sign dta")
def sign_dta():
    payload = json.dumps({
        "applicationId": dta_id
    })
    conn.request("POST", "/drc/application/transfer/sign", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)


@push("verify dta")
def verify_dta():
    payload = json.dumps({
        "applicationId": dta_id
    })
    conn.request("POST", "/drc/application/transfer/verify", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)


@push("approve dta")
def approve_dta():
    payload = json.dumps({
        "applicationId": dta_id
    })
    conn.request("POST", "/drc/application/transfer/approve", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)


@push("create dua")
def create_dua():
    payload = json.dumps({
        "drcId": tdr_application_id,
        "farUtilized": 100,
    })
    conn.request("POST", "/drc/application/utilization/create", payload, headers)
    res = conn.getresponse()
    _data = res.read()
    print(_data.decode("utf-8"))
    data = json.loads(_data)
    trx_id = data.get('data').get('trxId')
    global dua_id
    dua_id= data.get('data').get('applicationId')
    return trx_id

@push("sign dua")
def sign_dua():
    payload = json.dumps({
        "applicationId": dua_id
    })
    conn.request("POST", "/drc/application/utilization/sign", payload, headers)
    res = conn.getresponse()
    return get_trx_id_from_res(res)


def get_dua():
    payload = json.dumps({
        "applicationId": dua_id
    })
    conn.request("POST", "/drc/application/utilization/get", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))


def get_dashboard_data():
    payload = ''
    conn.request("GET", "/user/getDashboardData", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))


def run_all_test():
    # add_user_test()
    create_notice_test()
    create_application_test()
    signApplication()
    add_officer_test()
    update_officer_test()
    verify_application()
    approve_applicaiton_test()
    user_signed_status_test()
    issue_drc_test()
    create_dta_test()
    sign_dta()
    verify_dta()
    approve_dta()
    create_dua()
    sign_dua()
    get_dua()
    get_dashboard_data()


def main():
    run_all_test()


if __name__ == "__main__":
    main()
