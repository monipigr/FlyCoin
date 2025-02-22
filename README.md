# 🗳️ FlyCoin Voting System

## 📝 Overview

**FlyCoin** is a ERC20 token designed to manage voting rights securely. Tokens represent votes and are burned upon use, ensuring transparency and tramper-proof decision-making.

---

## ✨ Features

🛸 **Airdrop Claiming system**

Users can claim their airdrop only if they are on the voters list.

🔐 **Token-based voting mechanism to control voting rights**

Allowed voters can vote if they have tokens and have not already voted

🔥 **Token burned after vote right used**

After using the voting right, tokens are burned to control and ensure contract viability.

🤝 **Vote delegation feature**

Voters can delegate their vote right to other allowed voters.

👑 **Ownership voting control**

Only the smart contract owner can transfer tokens.

📢 **Vote transparency**

Events track votes for transparency and public verification.

---

## 🛠 Technical Details

- **Solidity Version**: `^0.8.24`
- **Inheritance**:
  - `ERC20`: For FlyCoin token implementation.
  - `Ownable`: Ensures only the owner can control voting session state.
- **Key Functions**:
  - `claim()`: Users can claim their tokens.
  - `transfer()`: Only the admin can transfer tokens to allowed voters.
  - `transferFrom()`: Transfers between users are not allowed.
  - `vote()`: Voters can use their voting right and tokens are burned after it.
  - `delegateVote(address)`: Voters who has not already vote can delegate their voting right.
  - `voteDelegated()`: Votes with delegated votes can use their delegated voting right.

---

## ⚙️ How to Use

### 🚀 Deploying the Smart Contract

1. Open [Remix IDE](https://remix.ethereum.org/).
2. Create a new Solidity file and paste the contract code.
3. Compile the contract using **Solidity 0.8.24**.
4. Deploy using **Remix VM** for local testing.

### ✅ Interacting and Testing

#### 🛸 **Claim the airdrop**

- Ensure their **token balance decreases by 5** after voting.
- Ensure they **cannot vote twice**, even if they have tokens.
- Ensure they **cannot delegate their vote** if they have already voted.

#### 🗳️ **Casting a Vote**

- Users **with tokens** can vote
- Ensure their **token balance is reduced by 5** after voting.
- Ensure they **cannot vote twice**, even if they have tokens.
- Ensure they **cannot delegate their vote** if they have already voted.

#### 🤝 **Delegating the voting right**

- Users **with voting rights** can delegate their vote.
- Ensure **they cannot delegate** their vote if they have already voted.
- Ensure **they have enough tokens** to delegate.
- Ensure **they cannot delegate** their vote if they have alredy delegated.

#### 🗳️ **Using a delegated vote**

- Users who **received a delegated vote** can vote.
- Ensure **they cannot vote twice** with delegating votes.
- Ensure they can also **vote if they have claimed they airdrop**.

---

## 📜 License

This project is licensed under **LGPL-3.0-only**.
