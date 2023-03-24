import json
import os
from getpass import getpass
from web3 import Web3, HTTPProvider

# Connect to the Celo Alfajores Testnet
w3 = Web3(HTTPProvider('https://alfajores-forno.celo-testnet.org'))

# Load the smart contract ABI
contract_abi = json.loads('[YOUR_SMART_CONTRACT_ABI]')

# Set the smart contract address
contract_address = '0x12345...[YOUR_SMART_CONTRACT_ADDRESS]'

# Initialize the contract
contract = w3.eth.contract(address=Web3.toChecksumAddress(contract_address), abi=contract_abi)

def create_identity(private_key, name, email):
    account = w3.eth.account.privateKeyToAccount(private_key)
    nonce = w3.eth.getTransactionCount(account.address)
    
    # Invoke the "createIdentity" function from your smart contract
    tx = contract.functions.createIdentity(name, email).buildTransaction({
        'from': account.address,
        'gas': 1000000,
        'gasPrice': w3.toWei('1', 'gwei'),
        'nonce': nonce
    })

    signed_tx = w3.eth.account.signTransaction(tx, private_key)
    tx_hash = w3.eth.sendRawTransaction(signed_tx.rawTransaction)
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    return tx_receipt

def get_identity(wallet_address):
    identity = contract.functions.getIdentity(wallet_address).call()
    return identity

if __name__ == '__main__':
    choice = input("Choose an option (1: Create Identity, 2: Get Identity): ")
    
    if choice == '1':
        private_key = getpass("Enter your private key: ")
        name = input("Enter your name: ")
        email = input("Enter your email: ")

        tx_receipt = create_identity(private_key, name, email)
        print("Identity created. Transaction receipt:", tx_receipt)
    
    elif choice == '2':
        wallet_address = input("Enter the wallet address: ")
        identity = get_identity(wallet_address)
        print(f"Name: {identity[0]}, Email: {identity[1]}")
    
    else:
        print("Invalid option")
