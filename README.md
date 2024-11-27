**The Akasha OTC Contract is a POC contract to facilitate over-the-counter (OTC) trades for Akasha tokens. This contract enables users to purchase Akasha tokens directly from preloaded blocks without impacting liquidity pools on the DEX. It is designed to handle large trades efficiently while maintaining flexibility for the market maker to manage token blocks and funds.**


Network: Sepolia ETH
 https://sepolia.etherscan.io

Deployed Contracts
Akasha OTC Contract

Address: 0xb468b34a10d87fd27d41d95bd8275bbd45556ba0
Purpose: Facilitates OTC trades by allowing users to purchase Akasha tokens from predefined blocks using USDC as the payment token.
Akasha Token Contract

Address: 0x188839bfc5399f29a7d2d362fb5d39d08b698500
Purpose: Represents the Akasha token that is traded via the OTC contract. Users receive Akasha tokens when a trade is executed.
USDC Test Contract

Address: 0xc049edfc24828bc4a254200d92614365b8cb95fc
Purpose: A test version of the USDC token with 18 decimals, used as the payment currency for purchasing Akasha tokens.

**High-Level Functionality** 


Market Maker Actions
The market maker (contract owner) can:

Load Token Blocks: Predefine blocks of Akasha tokens with specific sizes and prices.
Example: Load a block of 100 tokens at 10 USDC each.
Deposit Tokens:
Deposit Akasha tokens into the OTC contract to make them available for sale.
Deposit USDC or withdraw excess USDC if needed.
Modify or Cancel Blocks:
Update block details (size or price) or cancel unsold blocks.


User Actions
Buyers can:

View Available Blocks:
Use the getAvailableBlocks function to check available blocks (size, price, and availability status).
Execute a Trade:
Purchase Akasha tokens from an available block by paying USDC.
The trade is executed only if the payment matches the exact total price of the block (size * price).


Example Workflow
Market Maker Prepares Blocks:
Call depositTokens to deposit Akasha tokens into the contract.
Call loadBlocks with block sizes and prices (e.g., [100, 500, 1000] and [10, 10, 10]).
User Executes Trade:
Query getAvailableBlocks to find an available block.


Approve the OTC contract to spend USDC using the USDC contract’s approve function.


Call executeTrade with:


blockIndex: The block index to purchase.
paymentToken: 0xc049edfc24828bc4a254200d92614365b8cb95fc (USDC).
paymentAmount: The exact total price (e.g., 1000 * 10^18 for 1000 USDC).
Tokens are transferred:


Akasha tokens → User.
USDC → Market Maker.
