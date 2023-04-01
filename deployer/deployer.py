"""
Author: Ras Dwivedi
Email: rasd.phd@gmail.com

This scripts deploys all the contract for the KDA-TDR project on the quorum blockchain. Contracts are stored in ../contracts directory and the list of the contract to be deployed is specified.

Contracts might have dependencies and hence it is necessary to deploy them in a specific order
Currently the order in which the contracts should be deployed is
   1. UserManager
   2. DataTypes
   3. TDR
   4. TDR Manager
   5. DRC
   6 Application
   7. Utilization application
   8. DRC Manager
"""

from web3 import Web3
from web3.middleware import geth_poa_middleware
import logging
import json
import solcx
import os
import datetime
from time import sleep
from tests import run_all_test

# Set up the loggig services
# Create a logger
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# Create a file handler
file_handler = logging.FileHandler("logs.log")
file_handler.setLevel(logging.DEBUG)

# Create a format for the logs
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
file_handler.setFormatter(formatter)

# Add the file handler to the logger
logger.addHandler(file_handler)

# Test the logger
logger.info("Contract deployment started")
# load the config from config file
with open("config.json", "r") as config_file:
    config = json.load(config_file)

# loading all the values from the config file
SOLC_VERSION = config["solcVersion"]
HOST = config["nodeHost"]
PORT = config["nodePort"]

logger.debug("Connecting to blockchain host %s:%s ", HOST, PORT)

# Connect to Quorum node
w3 = Web3(Web3.HTTPProvider("http://" + HOST + ":" + PORT))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)

# Check if connected
if w3.isConnected():
    logger.info("Connected to Quorum node")
else:
    logger.error("Not connected to Quorum node, exiting")
    exit(0)

ADMIN_ACCOUNT = w3.eth.account.from_key(config['adminAccount'])
MANAGER_ACCOUNT = w3.eth.account.from_key(config['managerAccount'])
OWNER_ACCOUNT = w3.eth.account.from_key(config['ownerAccount'])
w3.eth.defaultAccount = OWNER_ACCOUNT.address
# settin the solcx latest version
logger.debug("setting solc version to %s", SOLC_VERSION)
solcx.install_solc(SOLC_VERSION)
solcx.set_solc_version(SOLC_VERSION)

FILES_TO_COMPILE = [
    "../contracts/DataTypes.sol",
    "../contracts/TDR.sol",
    "../contracts/DRC.sol",
    "../contracts/Application.sol",
    "../contracts/DRCManager.sol",
    "../contracts/TDRManager.sol",
    "../contracts/UserManager.sol",
    "../contracts/UtilizationApplication.sol",
    "../contracts/nomineeStorage.sol",
    "../contracts/nomineeManager.sol",
    "../contracts/DucStorage.sol",
    "../contracts/UserStorage.sol"
]
CONTRACTS = ["DrcTransferApplicationStorage", "DrcStorage", "DRCManager", "TdrStorage", "TDRManager", "UserManager",
             "DuaStorage", "NomineeStorage", "NomineeManager", "DucStorage", "UserData"]
# SKIPPED_CONTRACTS = ["UserManager","TdrStorage","DrcStorage","NomineeStorage"]
# SKIPPED_CONTRACTS = ["UserManager", "TdrStorage", "NomineeStorage"]
SKIPPED_CONTRACTS = [
                    "DrcTransferApplicationStorage",
                     "DrcStorage",
                     "DRCManager",
                     "TdrStorage",
                     # "TDRManager",
                     "UserManager",
                     "DuaStorage",
                     "NomineeStorage",
                     "NomineeManager",
                     "UserStorage",
                     ]
# SKIPPED_CONTRACTS = []
logger.info('following files would be compiled')
logger.info(FILES_TO_COMPILE)


def save_compiled_contracts(compiled_contracts):
    file = "../build/compiled_contracts/compiled_contracts.txt"
    os.system("mkdir -p ../build/compiled_contracts")
    f = open(file, 'w+')
    f.write(json.dumps(compiled_contracts))


def get_previous_contracts():
    file = "../build/compiled_contracts/compiled_contracts.txt"
    f = open(file, 'r')
    data = f.read()
    compiled_contracts = json.loads(data)
    return compiled_contracts


def get_compiled_contracts():
    """
    This function returns a dictionary of all the compiled contracts, their ABI and bytecode.
    It uses the solcx library to compile the contracts specified in the FILES_TO_COMPILE variable.
    The returned dictionary has the
    contract name as the key and a dictionary containing the ABI and bytecode as the value.
    Additionally, it saves the contracts to the local storage using the save_contract function.
    :return: A dictionary with contract name as the key and a dictionary containing the ABI and bytecode as the value.
    """

    _compiled_contracts = solcx.compile_files(FILES_TO_COMPILE,
                                              output_values=["abi", "bin"])
    # Formatting dictionary
    compiled_contracts = {}
    # compiled_contracts = get_previous_contracts()
    # print("###############################################")
    # print("WARNING: Using previous contracts, this may lead to error")
    # print("###############################################")
    for key in _compiled_contracts.keys():
        value = _compiled_contracts.get(key)
        print(key)
        new_key = key.split(":")[1]
        compiled_contracts[new_key] = value
        save_contract(new_key, value)
    # save_compiled_contracts(compiled_contracts)
    return compiled_contracts


def log_dict(d, s=1):
    """
    Prints the dictionary object with proper spacing
    """

    for key in d.keys():
        logger.debug('  ' * s + key)
        if type(d.get(key)) == dict:
            logger.debug(d.get(key), s + 1)
        else:
            logger.debug('  ' * s, d.get(key))


def save_contract(key, value):
    """
    This function saves the ABI and bytecode of a contract to the local storage.
    The ABI is saved in a file named "{key}.abi" in the "../build/abi/" directory,
    and the bytecode is saved in a file named "{key}.bin" in the "../build/bytecode/" directory.
    :param key: The name of the contract
    :param value: A dictionary containing the ABI and bytecode of the contract
    """
    os.system("mkdir -p ../build/abi")
    os.system("mkdir -p ../build/bytecode")
    f_abi = open("../build/abi/" + key + ".abi", 'w+')
    f_bin = open("../build/bytecode/" + key + ".bin", 'w+')
    # logger.debug(type(value.get('abi')))
    # logger.debug(json.dumps(value.get('abi')))
    f_abi.write(json.dumps(value.get('abi')))
    f_abi.close()

    f_bin.write(value.get('bin'))
    f_bin.close()


def deploy_contract(abi, bytecode):
    """
    This function deploys a contract to the Ethereum network.
    It takes in the ABI and bytecode of the contract and uses them to create a contract instance.
    It estimates the gas required for the deployment and builds the deployment transaction.
    The deployment transaction is signed by the owner account and sent to the Ethereum network.
    The function returns the address of the deployed contract.
    :param abi: The ABI of the contract
    :param bytecode: The bytecode of the contract
    :return: The address of the deployed contract.
    """
    contract = w3.eth.contract(abi=abi, bytecode=bytecode)
    gas_estimate = contract.constructor(ADMIN_ACCOUNT.address, MANAGER_ACCOUNT.address).estimateGas()
    print("gas estimate is ", gas_estimate)
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
    if contract_address is None:
        raise Exception("contract deployment failed")
    return contract_address


def deploy_all_contracts(compiled_contracts):
    """
    Deploys all the contracts
    :param compiled_contracts: a dictionary objcet containing all the compiled contracts, with their abi and bytecode
    :return: contract_address: a dictionary containing contract name as key mapped with their address
    """
    # Getting the old deployment
    file = "../build/contract_address/addresses.txt"
    if os.path.isfile(file):
        f = open(file, 'r')
        contract_addresses = json.loads(f.read())
        f.close()
    else:
        if os.path.isdir("../build/contract_address") is False:
            os.system("mkdir -p ../build/contract_address")
        contract_addresses = {}
    for contract in CONTRACTS:
        # skip few contracts
        logger.debug("deploying contract: %s", contract)
        if SKIPPED_CONTRACTS.count(contract) != 0:
            logger.debug("contract %s skipped", contract)
            continue
        abi = compiled_contracts.get(contract).get('abi')
        bytecode = compiled_contracts.get(contract).get('bin')
        address = deploy_contract(abi, bytecode)
        contract_addresses[contract] = address
        logger.info('address for contract named %s is %s', str(contract), str(address))
    return contract_addresses


def move_files_to_backend():
    # move to backend
    os.system('rm -r ../../backend/backend/services/blockchain/contracts/')
    os.system('mkdir -p ../../backend/backend/services/blockchain/contracts/')
    os.system('cp -r ../build/abi/  ../../backend/backend/services/blockchain/contracts/')
    os.system('cp -r ../build/contract_address  ../../backend/backend/services/blockchain/contracts/')
    # move to event parser
    os.system('mkdir -p ../../quorum-event-parser/contracts/')
    os.system('cp -r ../build/abi/  ../../quorum-event-parser/contracts/')
    os.system('cp -r ../build/contract_address  ../../quorum-event-parser/contracts/')


def execute_contract_method(f, account):
    logger.debug("START execute contract for function %s", str(f))
    gas_estimate = f.estimateGas()
    transaction = f.buildTransaction({
        'from': OWNER_ACCOUNT.address,
        'gas': gas_estimate,
        'gasPrice': w3.eth.gasPrice,
        'nonce': w3.eth.getTransactionCount(OWNER_ACCOUNT.address)
    })

    # buildTransaction()({
    #     'from': account.address,
    #     'gas': gas_estimate,
    #     'gasPrice': w3.eth.gasPrice,
    #     'nonce': w3.eth.getTransactionCount(account.address)
    # })
    signed_transaction = OWNER_ACCOUNT.signTransaction(transaction)
    tx_hash = w3.eth.sendRawTransaction(signed_transaction.rawTransaction)
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    if not tx_receipt.transactionHash.hex():
        raise Exception("execution failed %s", str(f))


def set_contract_address(contract, _func, address, message):
    func = getattr(contract.functions, _func)
    logger.debug("UPDATING: %s", message)
    logger.debug("with address %s", address)
    print("UPDATING: " + message)
    print("with address " + str(address))
    execute_contract_method(func(address), OWNER_ACCOUNT)
    # sleep(1)


def instantiate(contract_address, compiled_contracts):
    """
    Managers of all the functions needs to be instantiated
    1. TDR manager manages TdrStorage
    2. TDR manager also needs user manager

    """
    # For user manager
    tdr_storage_address = contract_address.get('TdrStorage')
    user_manager_address = contract_address.get('UserManager')
    tdr_manager_address = contract_address.get('TDRManager')
    drc_storage_address = contract_address.get('DrcStorage')
    drc_manager_address = contract_address.get('DRCManager')
    dta_storage_address = contract_address.get('DrcTransferApplicationStorage')
    dua_storage_address = contract_address.get('DuaStorage')
    nominee_storage_address = contract_address.get('NomineeStorage')
    nominee_manager_address = contract_address.get('NomineeManager')
    duc_storage_address = contract_address.get('DucStorage')

    # load tdr manager abi
    tdr_storage_contract = w3.eth.contract(address=tdr_storage_address,
                                           abi=compiled_contracts.get('TdrStorage').get('abi'))
    user_manager_contract = w3.eth.contract(address=user_manager_address,
                                            abi=compiled_contracts.get('UserManager').get('abi'))
    tdr_manager_contract = w3.eth.contract(address=tdr_manager_address,
                                           abi=compiled_contracts.get('TDRManager').get('abi'))
    drc_storage_contract = w3.eth.contract(address=drc_storage_address,
                                           abi=compiled_contracts.get('DrcStorage').get('abi'))
    drc_manager_contract = w3.eth.contract(address=drc_manager_address,
                                           abi=compiled_contracts.get('DRCManager').get('abi'))
    dta_storage_contract = w3.eth.contract(address=dta_storage_address,
                                           abi=compiled_contracts.get('DrcTransferApplicationStorage').get('abi'))
    dua_storage_contract = w3.eth.contract(address=dua_storage_address,
                                           abi=compiled_contracts.get('DuaStorage').get('abi'))
    nominee_storage_contract = w3.eth.contract(address=nominee_storage_address,
                                               abi=compiled_contracts.get('NomineeStorage').get('abi'))
    nominee_manager_contract = w3.eth.contract(address=nominee_manager_address,
                                               abi=compiled_contracts.get('NomineeManager').get('abi'))
    duc_storage_contract = w3.eth.contract(address=duc_storage_address,
                                           abi=compiled_contracts.get('DucStorage').get('abi'))

    # # updating storage in tdr manager
    # update_tdr_storage_method = tdr_manager_contract.functions.updateTdrStorage(tdr_storage_address)
    # logger.debug("updating  tdr storage in tdr manager contract")
    # execute_contract_method(update_tdr_storage_method, OWNER_ACCOUNT)

    # updating user manager in tdr manager
    set_contract_address(tdr_manager_contract, 'updateTdrStorage', tdr_storage_address,
                         "updating tdr storage in tdr manager contract")

    # # updating user manager in tdr manager
    # update_user_manager_method = tdr_manager_contract.functions.updateUserManager(user_manager_address)
    # logger.debug("updating user manager in tdr manager contract")
    # execute_contract_method(update_user_manager_method, OWNER_ACCOUNT)

    # updating user manager in tdr manager
    set_contract_address(tdr_manager_contract, 'updateUserManager', user_manager_address,
                         "updating user manager addres in tdr manager contract")
    # # setting manager for tdrStorage
    # update_tdr_storage_manager_method = tdr_storage_contract.functions.setManager(tdr_manager_address)
    # print('updating manager in tdr storage contract')
    # execute_contract_method(update_tdr_storage_manager_method, OWNER_ACCOUNT)

    # setting manager for tdrStorage
    set_contract_address(tdr_storage_contract, 'setManager', tdr_manager_address,
                         "updating manager in tdr manager contract")

    # # setting manager for userManager
    # set_user_manager_method = user_manager_contract.functions.setManager(MANAGER_ACCOUNT.address)
    # print('updating manager in user manager contract')
    # execute_contract_method(set_user_manager_method, OWNER_ACCOUNT)
    # print("updated manager to ", MANAGER_ACCOUNT.address)

    # setting manager for userManager
    set_contract_address(user_manager_contract, 'setManager', MANAGER_ACCOUNT.address,
                         "updating manager in user manager contract")

    # # updating drc storage in tdr manager
    # update_drc_storage_method = tdr_manager_contract.functions.updateDrcStorage(drc_storage_address)
    # logger.debug("updating  drc storage in tdr manager contract")
    # execute_contract_method(update_drc_storage_method, OWNER_ACCOUNT)

    # updating drc storage in tdr manager
    set_contract_address(tdr_manager_contract, 'updateDrcStorage', drc_storage_address,
                         "update drc storage in drc manager")

    # updating drc storage in drc manager
    set_contract_address(drc_manager_contract, 'updateDrcStorage', drc_storage_address,
                         "update drc storage in drc manager")

    # updating user manager in drc manager
    set_contract_address(drc_manager_contract, 'loadUserManager', user_manager_address,
                         "update user manager in drc manager")
    # updating drc manager address in dta storage
    set_contract_address(dta_storage_contract, 'setManager', drc_manager_address,
                         "update drc manager in dta storage")
    # updating drc manager address in dua storage
    set_contract_address(dua_storage_contract, 'setManager', drc_manager_address,
                         "update user manager in dua manager")
    # updating dta storage in drc manager
    set_contract_address(drc_manager_contract, 'updateDtaStorage', dta_storage_address,
                         "update dta storage in drc manager")
    # updating dua storage in drc manager
    set_contract_address(drc_manager_contract, 'updateDuaStorage', dua_storage_address,
                         "update dua storage in drc manager")

    set_contract_address(duc_storage_contract, 'setManager', drc_manager_address,
                         "update drc manager in duc storage")
    # updating duc storage in drc manager
    set_contract_address(drc_manager_contract, 'updateDucStorage', duc_storage_address,
                         "update duc storage in drc manager")

    set_contract_address(drc_storage_contract, 'setTdrManager', tdr_manager_address,
                         "update tdr manager in drc storage")
    set_contract_address(drc_storage_contract, 'setManager', drc_manager_address, "update drc manager in drc storage")
    set_contract_address(drc_manager_contract, 'loadNomineeManager', nominee_manager_address,
                         "update nominee manager in drc manager")
    set_contract_address(nominee_manager_contract, 'loadNomineeStorage', nominee_storage_address,
                         "update nominee storage in nominee manager")
    set_contract_address(nominee_manager_contract, 'loadUserManager', user_manager_address,
                         "update user manager in nominee manager")
    set_contract_address(nominee_storage_contract, 'setManager', nominee_manager_address,
                         "update nominee manager in nominee storage")


def main():
    """
    The main function
    :return:
    """
    # os.system('rm logs.log')
    start_time = st = datetime.datetime.now()
    print("Compiling contracts")
    compiled_contracts = get_compiled_contracts()
    print("Contracts compiled")
    print("Deploying contract")
    # f=open('../build/contract_address/addresses.txt')
    # contract_addresses = json.loads(f.read())
    contract_addresses = deploy_all_contracts(compiled_contracts)
    print("Contracts deployed")
    logger.info(contract_addresses)
    print(json.dumps(contract_addresses))
    f = open('../build/contract_address/addresses.txt', 'w')
    f.write(json.dumps(contract_addresses))
    f.close()
    move_files_to_backend()
    end_time = datetime.datetime.now()
    print("instantiating")
    instantiate(contract_addresses, compiled_contracts)
    print("total execution time: ", end_time - start_time)
    b = w3.eth.blockNumber
    # run_all_test()
    print("last mined block after instantiation was ", w3.eth.blockNumber)


if __name__ == "__main__":
    main()
