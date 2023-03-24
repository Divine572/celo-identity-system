import os
import deploy
from web3 import Web3




# Set up web3 connection
provider_url = os.environ.get("CELO_PROVIDER_URL")
w3 = Web3(Web3.HTTPProvider(provider_url))
assert w3.is_connected(), "Not connected to a Celo node"

syncing = w3.eth.syncing
print(syncing)


# Set deployer account and private key
account = os.environ.get("CELO_DEPLOYER_ADDRESS")
private_key = os.environ.get("CELO_DEPLOYER_PRIVATE_KEY")

abi = deploy.abi
contract_address = deploy.contract_address


identity_contract = w3.eth.contract(address=contract_address, abi=abi)



def create_identity(name: str, email: str):
    nonce = w3.eth.get_transaction_count(account)
    txn = identity_contract.functions.createIdentity(name, email).build_transaction({
        'gas': 200000,
        'gasPrice': w3.eth.gas_price,
        'nonce': nonce,
    })
    signed_txn = w3.eth.account.sign_transaction(txn, private_key)
    txn_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
    receipt = w3.eth.wait_for_transaction_receipt(txn_hash)
    return receipt


def get_identity(address: str) -> (str, str):
    name, email = identity_contract.functions.getIdentity(address).call()
    return name, email

# Create an identity
create_identity("Kate Wolfsen", "kate@example.com")

# Get an identity
name, email = get_identity(account)
print(f"Name: {name}, Email: {email}")

