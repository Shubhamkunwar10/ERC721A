# This repo contains the smart contract in solidity to provide Unique Ownership of Land In the form of NFT's.

## Heirarchy of the contracts
smart contracts are immutable, and hence du diligence has to be observed while writing them. There are two truth however,  
1. The contract once deployed cannote be changed
2. The client's business logic would change   
so, it is necessary to design the contract in such a away, that the data at the lowest level remains least affected as the business logic changes.

Here the heirarchy of the contracts
### The storage level
These are the contracts that deals directly with the blockchain and stores the data. Unless the data storage structure is not changed, these contracts do not change. These are most robust contract having only following functions
1. Storing a data in key value pair
2. Updating the data
3. Removing the data
4. Reading the data
5. allowing the ownership change of the data

### The permission level
These are the contract that do not deal with the business logic, but defines the access control to the data. These contract defines whether the user can access the storage contract or not. Depending upon the access control, it can do the following
1. Allow certain user to just read the data
2. Allow certain user to read/writ the data
3. Allow admin to set the admin of the storage contract

### The business logic layer
These contract executed the business logic and are most susceptible to the change. Given that these contract changes frequently any data should not be stored in these contracts. These contract interact with the storage contracts, and there could be multiple such contract on the same storage on permissioned contract. Any change in the access control contract can be initiated by these contract. Since these contract are most susceptible to the change, they should never be made sole admin of the permissioned contract, because once the access is lost, it cannot  be taken away.


