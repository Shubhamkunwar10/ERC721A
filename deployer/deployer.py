from time import sleep

from web3 import Web3
from web3.middleware import geth_poa_middleware
import logging
import json
from web3.contract import ConciseContract
import solcx
import http.client

# ORDER IN WHICH THE CONTRACTS CAN BE COMPILED AND ARE DEPLOYED
#     1. UserManager
#     2. DataTypes
#     3. TDR
#     4. TDR Manager
#     5. DRC
#     6 Application
#     7. Utilization application
#     8. DRC Manager


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

logger.debug("Connecting to blockchain host %s:%s ", HOST,PORT)

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
logger.info('following files woud be compiled')
logger.info(FILES_TO_COMPILE)


def get_compiled_contracts():
    """
    This function returns a dictionary of all the compiled contract, their abi and bytecode
    :return:
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
    return compiled_contracts


def log_dict(d, s=1):
    """
    A code to print the dictionory object with proper spacing
    """

    for key in d.keys():
        logger.debug('  ' * s + key)
        if type(d.get(key)) == dict:
            logger.debug(d.get(key), s + 1)
        else:
            logger.debug('  ' * s, d.get(key))


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
    if contract_address is None:
        raise Exception("contract deployment failed")
    return contract_address


def main():
    compiled_contracts = get_compiled_contracts()
    for contract in CONTRACTS:
        abi = compiled_contracts.get(contract).get('abi')
        bytecode = compiled_contracts.get(contract).get('bin')
        address = deploy_contract(abi, bytecode)
        logger.info('address for contract named %s is %s', str(contract), str(address))


if __name__ == "__main__":
    main()
