# Example: Order Flow

This example shows Global Spine Lite in a completed Ledger feature flow.

Feature:

```text
create-order
```

Flow:

```text
Product Spine -> PID -> contract -> build -> verify -> ship
```

Files included:

```text
.ledger/specs/PAD.md
.ledger/core/architecture.md
.ledger/design/create-order-sequence.md
.ledger/design/create-order-interaction.md
.ledger/specs/create-order-pid.md
.ledger/contracts/archive/create-order.md
.ledger/knowledge/create-order-verify.md
package.json
src/orders.js
test/create-order.test.js
```

Use this example to understand:
- how PAD defines a core business flow
- how a PID maps a feature to a flow step
- how architecture.md defines a module and entity owner
- how optional design attachments capture sequence and interaction details
- how verify records runtime output plus flow / state evidence

Run the example test:

```bash
node test/create-order.test.js
```

Expected output:

```text
output: 5 passed
```
