# SupplyChainTracker Smart Contract

A Clarity smart contract for tracking items through a supply chain with built-in validation and certification capabilities. This contract enables transparent tracking of item lifecycles, state changes, and third-party validations on the Stacks blockchain.

## Features

- Item lifecycle tracking with state history
- Multi-party validation system
- Certification authority management
- Secure state transitions
- Comprehensive audit trail
- Role-based access control

## Contract States

### Item States
- `ITEM_STATE_MANUFACTURED` (u1): Initial state when item is produced
- `ITEM_STATE_SHIPPING` (u2): Item is in transit
- `ITEM_STATE_RECEIVED` (u3): Item has been delivered
- `ITEM_STATE_INSPECTED` (u4): Item has passed quality checks

### Validation Types
- `VALIDATION_TYPE_ECO` (u1): Environmental certification
- `VALIDATION_TYPE_ETHICAL` (u2): Fair trade/ethical practices validation
- `VALIDATION_TYPE_GREEN` (u3): Sustainability certification
- `VALIDATION_TYPE_VERIFIED` (u4): Quality assurance validation

## Key Functions

### Administrative
- `register-item`: Create new item in the system
- `add-validator`: Add new validation authority
- `update-item-state`: Update item lifecycle state

### Validation
- `add-validation`: Add validation to an item
- `verify-validation`: Check validation status
- `revoke-validation`: Remove validation from item

### Query
- `get-item-timeline`: Retrieve item history
- `get-item-state`: Get current item state
- `get-validation-details`: Get validation information

## Security Features

- Principal address validation
- Role-based access control
- State transition validation
- Input boundary checking
- Zero-address protection
- Contract self-reference protection

## Error Codes

- `ERR_NOT_AUTHORIZED` (u1): Unauthorized access attempt
- `ERR_INVALID_ITEM` (u2): Invalid item ID
- `ERR_STATE_UPDATE_FAILED` (u3): State transition failed
- `ERR_INVALID_STATE` (u4): Invalid state value
- `ERR_INVALID_VALIDATION` (u5): Invalid validation type
- `ERR_VALIDATION_EXISTS` (u6): Duplicate validation attempt
- `ERR_INVALID_PRINCIPAL` (u7): Invalid principal address

## Usage Example

```clarity
;; Register a new item
(contract-call? .supply-chain-tracker register-item u1 ITEM_STATE_MANUFACTURED)

;; Add a validator
(contract-call? .supply-chain-tracker add-validator 'SP456... VALIDATION_TYPE_ECO)

;; Add validation to item
(contract-call? .supply-chain-tracker add-validation u1 VALIDATION_TYPE_ECO)
```

## Development

### Prerequisites
- Clarity CLI
- Stacks blockchain environment
- [Clarinet](https://github.com/hirosystems/clarinet) for testing

### Testing
Run the test suite:
```bash
clarinet test
```

---

