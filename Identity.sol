// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "node_modules/@openzeppelin/contracts/utils/Counters.sol";



contract IdentityNFT is ERC1155, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct Identity {
        string name;
        string email;
        uint256 age;
        bool exists;
    }

    mapping(uint256 => Identity) public identities;
    mapping(address => uint256) public addressToTokenId;
    mapping(address => uint256) public otps;
    mapping(address => uint256) public otpExpirations;

    uint256 private constant OTP_EXPIRATION_TIME = 5 minutes;
    uint256 private constant OTP_RANGE = 1000000;

    constructor(string memory _uri) ERC1155(_uri) {}

    modifier identityExists(address _user) {
        require(identities[addressToTokenId[_user]].exists, "Identity not found");
        _;
    }

    function createIdentity(string memory _name, string memory _email, uint256 _age) public onlyOwner {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        require(_age > 0, "Age must be greater than 0");
        require(!identities[addressToTokenId[msg.sender]].exists, "Identity already exists");

        uint256 tokenId = _tokenIdCounter.current();

        _mint(msg.sender, tokenId, 1, "");
        identities[tokenId] = Identity(_name, _email, _age, true);
        addressToTokenId[msg.sender] = tokenId;

        _tokenIdCounter.increment();
    }

    function updateIdentity(string memory _name, string memory _email, uint256 _age) public identityExists(msg.sender) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        require(_age > 0, "Age must be greater than 0");

        uint256 tokenId = addressToTokenId[msg.sender];

        identities[tokenId].name = _name;
        identities[tokenId].email = _email;
        identities[tokenId].age = _age;
    }

    function getIdentity(address _address) public view identityExists(_address) returns (string memory name, string memory email, uint256 age) {
        uint256 tokenId = addressToTokenId[_address];
        Identity storage identity = identities[tokenId];
        return (identity.name, identity.email, identity.age);
    }

    function deleteIdentity() public identityExists(msg.sender) {
        uint256 tokenId = addressToTokenId[msg.sender];
        _burn(msg.sender, tokenId, 1);
        delete identities[tokenId];
    }

    function uri(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "ERC1155Metadata: URI query for nonexistent token");

        string memory baseURI = super.uri(_tokenId);
        return string(abi.encodePacked(baseURI, _tokenId.toString()));
    }

    function _exists(uint256 _tokenId) internal view returns (bool) {
        return _tokenId < _tokenIdCounter.current();
    }

    function requestOtp() public identityExists(msg.sender) {
        uint256 tokenId = addressToTokenId[msg.sender];
        uint256 otp = _generateOtp(tokenId);
        otps[msg.sender] = otp;
        otpExpirations[msg.sender] = block.timestamp + OTP_EXPIRATION_TIME;
    }

    function verifyOtp(uint256 _otp) public identityExists(msg.sender) returns (bool) {
        require(otpExpirations[msg.sender] >= block.timestamp, "OTP expired");
        return otps[msg.sender] == _otp;
    }

    function _generateOtp(uint256 _seed) private view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, _seed))) % OTP_RANGE;
        return randomNumber;
    }

}
