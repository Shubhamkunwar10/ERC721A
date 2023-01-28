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
    "../contracts/UtilizationApplication.sol"
]
CONTRACTS = ["DrcTransferApplicationStorage", "DrcStorage", "DRCManager", "TdrStorage", "TDRManager", "UserManager",
             "DuaStorage"]
logger.info('following files would be compiled')
logger.info(FILES_TO_COMPILE)


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
    for key in _compiled_contracts.keys():
        value = _compiled_contracts.get(key)
        # print(key)
        new_key = key.split(":")[1]
        compiled_contracts[new_key] = value
        save_contract(new_key,value)
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
    f_abi = open("../build/abi/"+key + ".abi", 'w+')
    f_bin = open("../build/bytecode/"+key + ".bin", 'w+')
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
    contract_addresses = {}
    for contract in CONTRACTS:
        abi = compiled_contracts.get(contract).get('abi')
        bytecode = compiled_contracts.get(contract).get('bin')
        address = deploy_contract(abi, bytecode)
        contract_addresses[contract] = address
        logger.info('address for contract named %s is %s', str(contract), str(address))
    return contract_addresses

def move_files_to_backend():
    os.system('rm -r ../../backend/backend/services/blockchain/contracts/')
    os.system('mkdir -p ../../backend/backend/services/blockchain/contracts/')
    os.system('cp -r ../build/abi/  ../../backend/backend/services/blockchain/contracts/')
    os.system('cp -r ../build/bytecode/  ../../backend/backend/services/blockchain/contracts/')
    os.system('cp -r ../build/contract_address  ../../backend/backend/services/blockchain/contracts/')

def main():
    """
    The main function
    :return:
    """
    start_time =st = datetime.datetime.now()
    print("Compiling contracts")
    compiled_contracts = get_compiled_contracts()
    print("Contracts compiled")
    print("Deploying contract")
    contract_addresses = deploy_all_contracts(compiled_contracts)
    print("Contracts deployed")
    logger.info(contract_addresses)
    print(json.dumps(contract_addresses))
    f=open('../build/contract_address/addresses.txt','w')
    f.write(json.dumps(contract_addresses))
    f.close()
    move_files_to_backend()
    end_time = datetime.datetime.now()
    print("total execution time: ", end_time - start_time)

if __name__ == "__main__":
    main()
