from web3 import Web3
from web3.middleware import geth_poa_middleware
from datetime import datetime as dt
import logging
import json
import json
from web3.contract import ConciseContract
import solcx
#load the config from config file
with open("config.json", "r") as config_file:
    config = json.load(config_file)
SOLC_VERSION="0.8.16"


# Connect to Quorum node
w3 = Web3(Web3.HTTPProvider("http://"+config["nodeHost"]+":"+config["nodePort"]))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)

# Check if connected
if w3.isConnected():
    print("Connected to Quorum node")
else:
    print("Not connected to Quorum node")
    exit(0)

#connect to the blockchain and show the latest block
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

compiled_contract = solcx.compile_files(files_to_compile,output_values=["abi"])# solcx.select("0.8.16")
# compiled_contract = solcx.compile_source(contract)
# print(compiled_contract)
for key in compiled_contract.keys():
    print(key+": ")
    print(compiled_contract.get(key))
# #Given a file name write a deployer thatd deploys the contract
# def deploy_contract_from_file(filename):
#     f = open(filename,'r')
#     contract = f.read()
# 
# def get_abi(filename):
#     f = open(filename,'r')
#     contract = f.read()
#     print("Contract code is as \n")
#     print(contract)
#     compiled_contract = solc.compile_source(contract)
#     print(compiled_contract)
# # read the contents of solidity smart contract from the file
# with open(".sol", 'r') as f:
#     file_contents = f.read()
# 
# # compile the contract
# compiled_sol = compile_standard({
#     'language': 'Solidity',
#     'sources': {
#         '<contract-file-name>': {
#             'content': file_contents
#         },
#     },
#     'settings': {
#         'outputSelection': {
#             '*': {
#                 '*': [ 'evm.bytecode', 'evm.bytecode.sourceMap' ]
#             }
#         }
#     }
# })
# 
# # extract the contract bytecode and abi
# contract_bytecode = compiled_sol['contracts']['<contract-file-name>']['<contract-name>']['evm']['
