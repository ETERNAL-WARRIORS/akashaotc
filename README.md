<p align="center">
<img width="597" alt="Screenshot 2024-11-27 at 8 40 01 PM" src="https://github.com/user-attachments/assets/b402ce69-8e89-41f6-abd6-ed4fce7b7292">
</p>

# Akasha OTC Contract

The **Akasha OTC Contract** is a proof-of-concept (POC) contract designed to facilitate over-the-counter (OTC) trades for Akasha tokens. This contract enables users to purchase Akasha tokens directly from preloaded blocks without impacting liquidity pools on the DEX. It is built to handle large trades efficiently while providing flexibility for the market maker to manage token blocks and funds.

## Network
**Sepolia ETH**  
[https://sepolia.etherscan.io](https://sepolia.etherscan.io)

---

## Deployed Contracts

### Akasha OTC Contract
- **Address:** `0xb468b34a10d87fd27d41d95bd8275bbd45556ba0`
- **Purpose:** Facilitates OTC trades by allowing users to purchase Akasha tokens from predefined blocks using USDC as the payment token.

### Akasha Token Contract
- **Address:** `0x188839bfc5399f29a7d2d362fb5d39d08b698500`
- **Purpose:** Represents the Akasha token that is traded via the OTC contract. Users receive Akasha tokens when a trade is executed.

### USDC Test Contract
- **Address:** `0xc049edfc24828bc4a254200d92614365b8cb95fc`
- **Purpose:** A test version of the USDC token with 18 decimals, used as the payment currency for purchasing Akasha tokens.

---

## High-Level Functionality

### Market Maker Actions
The market maker (contract owner) can:
- **Load Token Blocks:** Predefine blocks of Akasha tokens with specific sizes and prices.  
  Example: Load a block of 100 tokens at 10 USDC each.
- **Deposit Tokens:** Deposit Akasha tokens into the OTC contract to make them available for sale.
- **Manage Funds:** Deposit USDC or withdraw excess USDC as needed.
- **Modify or Cancel Blocks:** Update block details (size or price) or cancel unsold blocks.

### User Actions
Buyers can:
- **View Available Blocks:** Use the `getAvailableBlocks` function to check available blocks (size, price, and availability status).
- **Execute a Trade:** Purchase Akasha tokens from an available block by paying USDC. The trade is executed only if the payment matches the exact total price of the block (`size * price`).

---

## Example Workflow

### Market Maker Prepares Blocks
1. **Deposit Tokens:** Call `depositTokens` to deposit Akasha tokens into the contract.
2. **Load Blocks:** Call `loadBlocks` with block sizes and prices (e.g., `[100, 500, 1000]` and `[10, 10, 10]`).

### User Executes Trade
1. **Query Blocks:** Use `getAvailableBlocks` to find an available block.
2. **Approve USDC Spending:**  
   Call the USDC contract’s `approve` function to allow the OTC contract to spend USDC on the user's behalf.
3. **Execute Trade:** Call `executeTrade` with:
   - `blockIndex`: The index of the block to purchase.
   - `paymentToken`: `0xc049edfc24828bc4a254200d92614365b8cb95fc` (USDC address).
   - `paymentAmount`: The exact total price (e.g., `1000 * 10^18` for 1000 USDC).

### Token Transfers
- **Akasha Tokens:** Transferred to the user.
- **USDC:** Transferred to the market maker.

--- 

### Notes
- Ensure the `paymentAmount` matches the total block price for successful execution.
- The contract allows flexibility for modifying block details and handling large token trades efficiently.
