🎟️ Decentralized Raffle (Chainlink VRF v2.5)
A fully decentralized, automated raffle smart contract built on Ethereum that allows users to enter by paying ETH and fairly selects a random winner using **Chainlink VRF v2.5**. The winner receives the entire prize pool trustlessly.

![Solidity](https://img.shields.io/badge/Solidity-0.8.19-blue)
![Chainlink](https://img.shields.io/badge/Chainlink-VRF%20v2.5-brightgreen)
![Foundry](https://img.shields.io/badge/Foundry-Tested-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 💡 Business Scenario

In traditional raffles and lotteries, participants must trust a centralized authority to:
- Collect funds honestly
- Pick winners fairly
- Distribute prizes transparently

This project demonstrates a **trustless, decentralized raffle system** where:

- Anyone can enter by paying a fixed ETH entrance fee.
- A winner is selected using **verifiable randomness** from Chainlink VRF.
- Prize distribution is automatic and transparent.
- The raffle runs on a time-based interval without manual intervention.

### Possible Use Cases
- Decentralized lotteries and lucky draws
- Community giveaways and DAO incentives
- Learning reference for **Chainlink VRF + Automation**
- Fair reward distribution in Web3 applications

---

## ⚙️ Features

| Feature | Description |
|------|------------|
| ETH Raffle Entry | Users enter the raffle by paying a predefined ETH entrance fee |
| Automated Winner Selection | Winner is picked using Chainlink VRF v2.5 for provable randomness |
| Time-Based Raffle | Uses a configurable interval to determine when a winner can be picked |
| Chainlink Automation Ready | `checkUpkeep` and `performUpkeep` enable full automation |
| Secure Payout | Entire contract balance is transferred safely to the winner |
| State Management | Prevents new entries while winner calculation is in progress |
| Event Logging | Emits events for entries, randomness requests, and winner selection |
| Custom Errors | Gas-efficient custom Solidity errors for better debugging |

---

## 🔁 Raffle Flow

1. **Raffle Opens**
   - Contract starts in `OPEN` state.
   - Users can enter by sending ETH.

2. **Users Enter**
   - ETH is added to the prize pool.
   - Entry is recorded on-chain.

3. **Interval Passes**
   - Chainlink Automation checks if conditions are met:
     - Time interval passed
     - At least one player
     - Contract has ETH
     - Raffle is open

4. **Randomness Requested**
   - Contract requests randomness from Chainlink VRF.

5. **Winner Selected**
   - A random index selects the winner.
   - Prize pool is transferred.
   - Raffle resets for the next round.

---

## 🛠 Technical Details

- **Solidity Version:** `0.8.19`
- **Randomness Provider:** Chainlink VRF v2.5
- **Automation:** Chainlink Automation compatible (`checkUpkeep`, `performUpkeep`)
- **Testing Framework:** Foundry (forge)
- **Security Practices:**
  - Checks-Effects-Interactions pattern
  - Custom errors for gas efficiency
  - Reentrancy-safe ETH transfers
  - Immutable configuration values

---

## 📡 Events

| Event | Description |
|-----|------------|
| `RaffleEntered(address)` | Emitted when a player enters the raffle |
| `RandomNumberGenerated(uint256)` | Emitted when randomness is requested |
| `PickedWinner(address)` | Emitted when a winner is selected |

---

## 🔐 Raffle States

- `OPEN` — Users can enter the raffle
- `CALCULATING` — Winner selection in progress, no new entries allowed

---

## 🚀 Getting Started (Local Development)

```bash
git clone https://github.com/GoudhamT/VRFLottery.git
cd raffle-contract
forge install
forge build
forge test
