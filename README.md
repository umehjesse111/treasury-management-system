# Community Treasury Management System

A decentralized smart contract system for managing community treasury funds with multi-signature governance and robust security controls.

## Features

- **Multi-signature Governance**: Requires multiple steward signatures for fund allocation
- **Allocation Controls**: Enforces minimum contributions and maximum allocation caps
- **Steward Management**: Flexible system for adding and removing treasury stewards
- **Motion System**: Structured proposal and voting system for treasury actions
- **Emergency Controls**: System freeze capabilities for security incidents
- **Comprehensive Tracking**: Records and monitors all allocation history
- **Access Control**: Role-based permissions with admin oversight

## Core Functions

### Administrative Functions
- `update-treasury-admin`: Transfer admin rights to a new address
- `update-minimum-contribution`: Modify the minimum contribution threshold
- `update-allocation-cap`: Adjust the maximum allocation limit
- `update-required-signatures`: Change the required number of signatures for motions

### Steward Management
- `add-steward`: Add a new steward to the system
- `remove-steward`: Remove an existing steward
- `is-steward`: Check if an address has steward privileges

### Motion Management
- `submit-motion`: Create a new motion for voting
- `get-motion`: Retrieve motion details
- `execute-motion`: Process approved motions

### Allocation Management
- `record-allocation`: Track fund allocations to beneficiaries
- `get-beneficiary-allocation-history`: View allocation history
- `validate-allocation-request`: Verify allocation amounts

### Emergency Controls
- `freeze-system`: Pause system operations
- `unfreeze-system`: Resume system operations
- `get-system-status`: Check current system state

## Security Features

- Strict validation of beneficiary addresses
- Prevention of self-allocation by stewards
- Protection against system administrator allocation
- Comprehensive input validation
- Emergency freeze mechanism
- Motion-based governance for major decisions

## Error Codes

- `401`: Unauthorized access
- `402`: Invalid minimum contribution
- `403`: Invalid allocation cap
- `404`: Invalid motion ID
- `405`: Allocation limit exceeded
- `406`: System already frozen
- `407`: System not frozen
- `408`: System currently frozen
- `409`: Self-allocation not allowed
- `410`: Admin allocation not allowed
- `411`: Invalid beneficiary address
- `412`: Invalid beneficiary validation

## Getting Started

1. Deploy the contract to your Stacks network
2. Initialize the treasury admin address
3. Set initial parameters (minimum contribution, allocation cap, required signatures)
4. Add initial stewards through the admin account
5. Begin submitting and processing motions

## Best Practices

- Regularly rotate stewards to maintain security
- Monitor allocation history for unusual patterns
- Maintain a balanced number of required signatures
- Test emergency procedures periodically
- Document all motion submissions and their outcomes

