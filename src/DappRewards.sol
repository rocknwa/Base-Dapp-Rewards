// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./RewardToken.sol"; // Import your ERC20 token contract

contract DappRewards is ERC721, Ownable, ERC721URIStorage {
    uint256 private tokenCounter;
    RewardToken public rewardToken;  // Use RewardToken instead of ERC20

    string[] internal courseURIs = [
        "https://aquamarine-rare-firefly-756.mypinata.cloud/ipfs/QmWiuq91sw81mcLPWuchS7uBRQugFrY5wXuUHUJdDP9LwA",
        "https://aquamarine-rare-firefly-756.mypinata.cloud/ipfs/QmUUNCYUMvTiTbe3h2biAtGKZU1j565y5fx72p67buN1qT",
        "https://aquamarine-rare-firefly-756.mypinata.cloud/ipfs/QmazxqJXVjjdmVhS4NziuojQxhuXHsJvprzoqfKfPisCwT",
        "https://aquamarine-rare-firefly-756.mypinata.cloud/ipfs/QmRQ2d1FXA4jYagsKwgheEj6ZdgeAteCt3S5Kw3ZcMCBj8"
    ];

    mapping(address => bool) public hasReceivedWelcomeNFT;
    mapping(address => bool) public hasReceivedCryptoNFT;
    mapping(address => bool) public hasReceivedFundamentalNFT;
    mapping(address => bool) public hasReceivedWalletNFT;
    mapping(address => uint256) public userXP;
    mapping(address => uint256) public userTokenID;

    uint256 public xpPerLesson = 10;
    uint256 public tokenPerLesson = 1 * 10 ** 18;

    event NftMinted(address recipient, uint256 tokenId);
    event XPGained(address user, uint256 xpGained);
    event LessonCompleted(address user, string description);
    event TokensRewarded(address user, uint256 tokenAmount);
    event TokensTransferred(address from, address to, uint256 tokenAmount);

    constructor(RewardToken _token) ERC721("DappNFT", "DAPP") {
        rewardToken = _token;
        tokenCounter = 0;
    }

    // Mint welcome NFT on login
    function login() external {
        require(!hasReceivedWelcomeNFT[msg.sender], "Welcome NFT already received");
        mintNFT(msg.sender, 0); // Mint welcome NFT
        hasReceivedWelcomeNFT[msg.sender] = true;
    }

    // Complete Fundamental lesson
    function completeFundamentalLesson() external {
        require(!hasReceivedFundamentalNFT[msg.sender], "Fundamental lesson NFT already received");
        emit LessonCompleted(msg.sender, "Fundamental lesson completed!");
        mintNFT(msg.sender, 1);
        hasReceivedFundamentalNFT[msg.sender] = true;
    }

    // Complete Wallet lesson
    function completeWalletLesson() external {
        require(!hasReceivedWalletNFT[msg.sender], "Wallet lesson NFT already received");
        emit LessonCompleted(msg.sender, "Wallet lesson completed!");
        mintNFT(msg.sender, 2);
        hasReceivedWalletNFT[msg.sender] = true;
    }

    // Complete Crypto lesson
    function completeCryptoLesson() external {
        require(!hasReceivedCryptoNFT[msg.sender], "Crypto lesson NFT already received");
        emit LessonCompleted(msg.sender, "Crypto lesson completed!");
        mintNFT(msg.sender, 3);
        hasReceivedCryptoNFT[msg.sender] = true;
    }

     function transferTokens(address recipient, uint256 amount) external {
        require(rewardToken.balanceOf(msg.sender) >= amount, "Not enough tokens to transfer");
        rewardToken.transfer(recipient, amount); // Transfer tokens from the sender to the recipient
        emit TokensTransferred(msg.sender, recipient, amount);
    }

    // Function to reward tokens after lesson completion
    function claimTokens() external {
        uint256 rewardAmount = tokenPerLesson;
        rewardToken.mint(msg.sender, rewardAmount); // Mint new tokens
        emit TokensRewarded(msg.sender, rewardAmount);
    }

    // Function to gain XP
    function gainXP() external {
        userXP[msg.sender] += xpPerLesson;
        emit XPGained(msg.sender, xpPerLesson);
    }

    // Internal function to mint NFTs with URI storage
    function mintNFT(address recipient, uint256 indexId) internal {
        uint256 tokenId = tokenCounter;
        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, courseURIs[indexId]);
        userTokenID[recipient] = tokenId;
        tokenCounter++;
        emit NftMinted(recipient, tokenId);
    }

    // Override necessary functions for ERC721URIStorage
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Prevent transfer of NFTs (soulbound)
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        require(from == address(0) || to == address(0), "NFTs are non-transferable (soulbound)");
    }
}
