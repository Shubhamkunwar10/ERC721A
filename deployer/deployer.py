from time import sleep

from web3 import Web3
from web3.middleware import geth_poa_middleware
from datetime import datetime as dt
import logging
import json
from web3.contract import ConciseContract
import solcx
import http.client

# load the config from config file
with open("config.json", "r") as config_file:
    config = json.load(config_file)
SOLC_VERSION = "0.8.16"

# Connect to Quorum node
w3 = Web3(Web3.HTTPProvider("http://" + config["nodeHost"] + ":" + config["nodePort"]))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)

# Check if connected
if w3.isConnected():
    print("Connected to Quorum node")
else:
    print("Not connected to Quorum node")
    exit(0)

# connect to the blockchain and show the latest block
solcx.install_solc(SOLC_VERSION)
solcx.set_solc_version(SOLC_VERSION)
files_to_compile = [
    "../contracts/DataTypes.sol",
    "../contracts/TDR.sol",
    "../contracts/DRC.sol",
    "../contracts/Application.sol",
    "../contracts/DRCManager.sol",
    "../contracts/TDRManager.sol",
    "../contracts/UserManager.sol",
    "../contracts/UtilizationApplication.sol"
]

compiled_contract = solcx.compile_files(files_to_compile,
                                        output_values=["abi", "bin"])  # solcx.select("0.8.16")


# compiled_contract = solcx.compile_source(contract)
# print(compiled_contract)
def print_dic(d, s=1):
    """
    A code to print the dictionory object with proper spacing
    """

    for key in d.keys():
        print('  ' * s + key)
        if type(d.get(key)) == dict:
            print_dic(d.get(key), s + 1)
        else:
            print('  ' * s, d.get(key))


# Formatting dictionary
_compiled_contract = {}
for key in compiled_contract.keys():
    value = compiled_contract.get(key)
    # print(key)
    new_key = key.split(":")[1]
    _compiled_contract[new_key] = value
compiled_contract = _compiled_contract

# print_dic(compiled_contract)
# Store  these variables in env file
ADMIN_ACCOUNT = w3.eth.account.from_key('0x12126974647d010ab7999fda6dee24e4fe0550662475343f1508f8c1fd837b8d')
MANAGER_ACCOUNT = w3.eth.account.from_key('0xb8deddcf74c1fb6c4b58dc878fb5e1e0f42924bff0090d3e61f6b170ced3b238')
OWNER_ACCOUNT = w3.eth.account.from_key('0x99834178f94d86a9375170a992a99c723b05ee8cc2ceb67c18540c1583895b3d')
w3.eth.defaultAccount = OWNER_ACCOUNT.address
# extra_key = '0x785ee8d2bec21d02637d1aae6fca04f242c9135028432d0302c24983d0e2b5e3'
if w3.eth.defaultAccount is None:
    print("Default account not found")
    exit(0)


def deploy_contract(abi, bytecode):
    contract = w3.eth.contract(abi=abi, bytecode=bytecode)
    gas_estimate = contract.constructor(ADMIN_ACCOUNT.address, MANAGER_ACCOUNT.address).estimateGas()
    transaction = contract.constructor(ADMIN_ACCOUNT.address, MANAGER_ACCOUNT.address).buildTransaction({
        'from': OWNER_ACCOUNT.address,
        'gas': gas_estimate,
        'gasPrice': w3.eth.gasPrice,
        'nonce': w3.eth.getTransactionCount(OWNER_ACCOUNT.address)
    })
    signed_transaction = OWNER_ACCOUNT.signTransaction(transaction)

    # Send the signed transaction
    tx_hash = w3.eth.sendRawTransaction(signed_transaction.rawTransaction)
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    contract_address = tx_receipt['contractAddress']
    # tx_hash = contract.constructor(ADMIN_ACCOUNT.address, MANAGER_ACCOUNT.address).transact({'from':OWNER_ACCOUNT.address})
    # print(w3.eth.defaultAccount)
    # tx_hash = contract.constructor(ADMIN_ACCOUNT.address, MANAGER_ACCOUNT.address).transact()
    # tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    contract_address = tx_receipt['contractAddress']
    if contract_address is None:
        raise Exception("contract deployment failed")
    return contract_address


# write code to deploy all contracts one by one
# ORDER IN WHICH THE CONTRACTS CAN BE COMPILED AND THE DEPLOYED
#     1. UserManager
#     2. DataTypes
#     3. TDR
#     4. TDR Manager
#     5. DRC
#     6 Application
#     7. Utilization application
#     8. DRC Manager
contracts = ["DrcTransferApplicationStorage", "DrcStorage", "DRCManager", "TdrStorage", "TDRManager", "UserManager",
             "DuaStorage"]

# print_dic(compiled_contract)
for contract in contracts:
    abi = compiled_contract.get(contract).get('abi')
    bytecode = compiled_contract.get(contract).get('bin')
    address = deploy_contract(abi, bytecode)
    print('address for contract named %s is %s', str(contract), str(address))
    sleep(5)
#
# abi = compiled_contract.get("/home/ras/Desktop/code/KDA/smart-contracts/contracts/UtilizationApplication.sol:DuaStorage").get('abi')
# bytecode = compiled_contract.get("/home/ras/Desktop/code/KDA/smart-contracts/contracts/UtilizationApplication.sol:DuaStorage").get('bin-runtime')
# contract = w3.eth.contract(abi=abi, bytecode=bytecode)
# print(contract)
# gas_estimate = contract.constructor().estimateGas()
# # abi = compiled_contract.get("DuaStorage")
# # print(abi)
# # print(bytecode)
# # print(deploy_contract(abi,bytecode))
# # print(compiled_contract.keys())
# # for key in compiled_contract.keys():
# #     print(key + ": ")
# #     print(compiled_contract.get(key))
# #     subKey = compiled_contract.get(key)
# #     print(type(subKey))
# #     for i in subKey.keys():
# #         print(i)
# #     exit(0)
# 
# 

# # send a sign transasction
# # hard coded account access
# # ACCOUNT =0xf865d11aB528F350d8e5a98C4f810d8C4E8F379A
# # PASSWORD=tG8nQxe@KDA
# # USERNAME=kda-dev-admin
# 
# # Need to push the conbtract on the chain, and automate that process and then keep testing and changing the code
# # For that I need a trx signing api and the account address
# 
# # find the order in which contract can be deployed
# def get_admin_sign(trx_data=None, id="kda-dev-admin", password="tG8nQxe@KDA"):
#     conn = http.client.HTTPSConnection("ecdsa-signer-vxfjnuk6xa-uc.a.run.app")
#     payload = json.dumps({
#         "id": id,
#         "password": password,
#         "trxData": trx_data
#     })
#     headers = {
#         'Content-Type': 'application/json'
#     }
#     conn.request("POST", "//users/sign", payload, headers)
#     res = conn.getresponse()
#     sign = res.read()
#     print(sign.decode("utf-8"))
#     return sign
