# How to run this code  
## Requirements:
```
python3 -m venv .smcENV
source .smcENV/bin/activate
pip3 install -r requirements.txt
```
``` python3 deployer.py ```   

NOTE: can comment `run_all_test()` in deployer.py to skip running tests as it 
needs `ACCESS_TOKEN` to be set in test.py and the backend is running.

## How to deploy the smart contracts on the blockchain
We use web3 and web3.poa middleware to connect to the quorum blockchain.
