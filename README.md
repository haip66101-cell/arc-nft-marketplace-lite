![Solidity](https://img.shields.io/badge/Solidity-0.8.28-blue?logo=solidity)
![Foundry](https://img.shields.io/badge/Built_with-Foundry-orange)
![Arc Network](https://img.shields.io/badge/Chain-Arc_Testnet-purple)
![License](https://img.shields.io/badge/License-MIT-green)

# arc-nft-marketplace-lite

Simple NFT marketplace paid in USDC on Arc testnet.

- Chain ID: `5042002`
- RPC: `https://rpc.testnet.arc.network`
- USDC: `0x3600000000000000000000000000000000000000`
- Explorer: https://testnet.arcscan.app

## Contract

`src/NftMarketLite.sol` — Simple NFT marketplace paid in USDC.

## Build

```bash
forge build
```

## Deployment

- Contract: `0x53AcdbA613e957331f11C02B79550892c552Bd19`
- Tx: `inferred-from-nonce`
- Explorer: https://testnet.arcscan.app/address/0x53AcdbA613e957331f11C02B79550892c552Bd19

## Architecture

```
┌──────────────┐     ┌──────────────┐
│   Frontend   │────▶│  NftMarketLite  │
│   (dApp)     │     │  (Solidity)  │
└──────────────┘     └──────┬───────┘
                            │
                     ┌──────▼───────┐
                     │  Arc Testnet │
                     │  Chain 5042002│
                     └──────────────┘
```


## Quick Start

```bash
# Install dependencies
forge install

# Build
forge build

# Run tests
forge test -vvv

# Deploy to Arc testnet
forge script script/Deploy.s.sol --rpc-url https://rpc.testnet.arc.network --broadcast
```


## Gas Optimization

This contract is optimized for Arc Network's USDC-based gas model:
- Custom errors instead of revert strings (saves ~200 gas per revert)
- Events for all state changes (transparent on-chain logging)
- Immutable variables where applicable
- Tight variable packing in storage slots

Run gas report:
```bash
forge test --gas-report
```


## Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add improvement'`)
4. Push to branch (`git push origin feature/improvement`)
5. Open a Pull Request

## License

MIT
