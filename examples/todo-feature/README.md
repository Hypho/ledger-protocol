# Example: Todo Feature

This example shows what a completed Ledger feature flow looks like after ship.

Feature:

```text
add-todo
```

Flow:

```text
pid -> contract -> build -> verify -> ship
```

Files included:

```text
.ledger/contracts/archive/add-todo.md
.ledger/knowledge/add-todo-verify.md
.ledger/state.md
.ledger/specs/add-todo-pid.md
package.json
src/todo.js
test/add-todo.test.js
```

The active contract has already been archived, because the feature is shipped.

Use this example to understand:
- how PID captures intent and out-of-scope boundaries
- how contract converts intent into FC/NF entries
- how verify records real command output
- how ship updates state and archives the contract

Run the example test:

```bash
node test/add-todo.test.js
```

Expected output:

```text
output: 4 passed
```
