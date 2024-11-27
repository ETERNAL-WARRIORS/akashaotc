// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AkashaOTC {
    struct Block {
        uint256 size;         // Number of tokens in the block
        uint256 price;        // Price per token (in stablecoins or ETH)
        bool isAvailable;     // Block availability status
    }

    address public marketMaker; // Address of the market maker
    address public akashaToken; // Token being traded

    mapping(address => bool) public paymentTokens; // Supported payment tokens (USDT/USDC)
    Block[] public blocks; // Array of token blocks
    uint256 public tradeExpiry; // Expiry duration for blocks (e.g., 7 days)

    event BlockLoaded(uint256 blockIndex, uint256 size, uint256 price);
    event BlockModified(uint256 blockIndex, uint256 newSize, uint256 newPrice);
    event BlockSplit(uint256 originalBlockIndex, uint256 newBlockIndex, uint256 newSize);
    event TradeExecuted(address buyer, uint256 blockIndex, address paymentToken, uint256 amount);
    event BlockCancelled(uint256 blockIndex);
    event TokensDeposited(address token, uint256 amount);
    event TokensWithdrawn(address token, uint256 amount);

    modifier onlyMarketMaker() {
        require(msg.sender == marketMaker, "Not authorized");
        _;
    }

    modifier validateBlockIndex(uint256 blockIndex) {
        require(blockIndex < blocks.length, "Invalid block index");
        _;
    }

    constructor(address _marketMaker, address _akashaToken, uint256 _tradeExpiry) {
        require(_marketMaker != address(0), "Invalid market maker address");
        require(_akashaToken != address(0), "Invalid token address");
        require(_tradeExpiry > 0, "Invalid trade expiry");
        
        // Check if the token contract exists
        require(IERC20(_akashaToken).totalSupply() >= 0, "Invalid token contract");
        
        marketMaker = _marketMaker;
        akashaToken = _akashaToken;
        tradeExpiry = _tradeExpiry;
    }

    // Add a payment token for the OTC trades
    function addPaymentToken(address _paymentToken) external onlyMarketMaker {
        paymentTokens[_paymentToken] = true;
    }

    // Remove a payment token
    function removePaymentToken(address _paymentToken) external onlyMarketMaker {
        paymentTokens[_paymentToken] = false;
    }

    // Deposit tokens (Akasha or payment tokens) into the contract
    function depositTokens(address token, uint256 amount) external onlyMarketMaker {
        require(amount > 0, "Deposit amount must be greater than 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit TokensDeposited(token, amount);
    }

    // Withdraw tokens (Akasha or payment tokens) from the contract
    function withdrawTokens(address token, uint256 amount) external onlyMarketMaker {
        require(amount > 0, "Withdraw amount must be greater than 0");
        IERC20(token).transfer(msg.sender, amount);
        emit TokensWithdrawn(token, amount);
    }

    // Load pre-defined blocks of tokens into the contract
    function loadBlocks(uint256[] memory sizes, uint256[] memory prices) external onlyMarketMaker {
        require(sizes.length == prices.length, "Mismatched input lengths");
        
        for (uint256 i = 0; i < sizes.length; i++) {
            blocks.push(Block({
                size: sizes[i],
                price: prices[i],
                isAvailable: true
            }));
            emit BlockLoaded(blocks.length - 1, sizes[i], prices[i]);
        }
    }

    // Modify an existing block
    function modifyBlock(uint256 blockIndex, uint256 newSize, uint256 newPrice) 
        external 
        onlyMarketMaker 
        validateBlockIndex(blockIndex) 
    {
        Block storage blockInfo = blocks[blockIndex];
        require(blockInfo.isAvailable, "Block not available for modification");

        blockInfo.size = newSize;
        blockInfo.price = newPrice;

        emit BlockModified(blockIndex, newSize, newPrice);
    }

    // Split an existing block into two smaller blocks
    function splitBlock(uint256 blockIndex, uint256 newSize) 
        external 
        onlyMarketMaker 
        validateBlockIndex(blockIndex) 
    {
        Block storage blockInfo = blocks[blockIndex];
        require(blockInfo.isAvailable, "Block not available for splitting");
        require(newSize < blockInfo.size, "Split size must be less than original");

        uint256 remainingSize = blockInfo.size - newSize;

        // Modify the original block
        blockInfo.size = newSize;

        // Create a new block with the remaining size
        blocks.push(Block({
            size: remainingSize,
            price: blockInfo.price,
            isAvailable: true
        }));

        emit BlockSplit(blockIndex, blocks.length - 1, remainingSize);
    }

    // Cancel an unsold block
    function cancelBlock(uint256 blockIndex) 
        external 
        onlyMarketMaker 
        validateBlockIndex(blockIndex) 
    {
        Block storage blockInfo = blocks[blockIndex];
        require(blockInfo.isAvailable, "Block is not available for cancellation");

        blockInfo.isAvailable = false;

        emit BlockCancelled(blockIndex);
    }

    // Execute a trade against a preloaded block
    function executeTrade(uint256 blockIndex, address paymentToken, uint256 paymentAmount) 
        external 
        payable 
        validateBlockIndex(blockIndex) 
    {
        Block storage blockInfo = blocks[blockIndex];
        require(blockInfo.isAvailable, "Block not available");
        require(paymentTokens[paymentToken] || paymentToken == address(0), "Unsupported payment token");

        uint256 totalPrice = blockInfo.size * blockInfo.price;
        require(paymentAmount == totalPrice, "Incorrect payment amount");

        if (paymentToken == address(0)) {
            // ETH payment
            require(msg.value == totalPrice, "Incorrect ETH amount");
            payable(marketMaker).transfer(msg.value);
        } else {
            // Stablecoin payment
            IERC20(paymentToken).transferFrom(msg.sender, marketMaker, paymentAmount);
        }

        // Ensure the contract has enough Akasha tokens to fulfill the trade
        require(IERC20(akashaToken).balanceOf(address(this)) >= blockInfo.size, "Insufficient Akasha tokens in contract");

        // Transfer Akasha tokens to the buyer
        IERC20(akashaToken).transfer(msg.sender, blockInfo.size);

        // Mark block as sold
        blockInfo.isAvailable = false;

        emit TradeExecuted(msg.sender, blockIndex, paymentToken, paymentAmount);
    }

    // Helper function to get all available blocks
    function getAvailableBlocks() external view returns (Block[] memory) {
        uint256 availableCount = 0;
        for (uint256 i = 0; i < blocks.length; i++) {
            if (blocks[i].isAvailable) {
                availableCount++;
            }
        }

        Block[] memory availableBlocks = new Block[](availableCount);
        uint256 j = 0;

        for (uint256 i = 0; i < blocks.length; i++) {
            if (blocks[i].isAvailable) {
                availableBlocks[j] = blocks[i];
                j++;
            }
        }

        return availableBlocks;
    }
}
