from web3 import Web3
from web3.middleware import geth_poa_middleware
from datetime import datetime as dt
import logging
import json
import json

#load the config from config file
with open("config.json", "r") as config_file:
    config = json.load(config_file)


from web3 import Web3

# Connect to Quorum node
w3 = Web3(Web3.HTTPProvider("http://"+config["nodeHost"]+":"+config["nodePort"]))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)

# Check if connected
if w3.isConnected():
    print("Connected to Quorum node"
else:
    print("Not connected to Quorum node")

#connect to the blockchain and show the latest block
