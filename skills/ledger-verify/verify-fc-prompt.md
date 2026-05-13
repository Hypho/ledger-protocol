# FC Verify Subagent Prompt Template

Use this template when dispatching a verify subagent for a specific FC entry.

```
Task tool (general-purpose):
  description: "Verify FC-[N]: [FC description]"
  prompt: |
    You are verifying a specific functional contract entry through adversarial testing.

    ## FC Entry

    [FULL TEXT of FC entry from contract — paste here, don't make subagent read file]

    ## Acceptance Criteria

    [From contract: what constitutes PASS for this FC]

    ## Project Context

    - Test command: [project test command]
    - Relevant source files: [list files]
    - Relevant test files: [list files]
    - Runtime environment: [any special setup needed]

    ## Your Job

    1. **Construct boundary inputs** for this FC:
       - Normal case (expected to work)
       - Edge cases (boundary values, empty inputs, max values)
       - Error cases (invalid inputs, permission denied, not found)

    2. **Run the code** with each input:
       - Use real commands, not reasoning
       - Capture actual output (stdout, stderr, exit codes)
       - If you can't run something, mark as INCONCLUSIVE with reason

    3. **Record evidence**:
       - For each test: command run, actual output (first 30 lines), pass/fail
       - Do NOT use "should", "expected", "theoretically"
       - Record what ACTUALLY happened, not what SHOULD happen

    4. **Determine verdict** for this FC:
       - PASS: all boundary inputs produce expected behavior with real evidence
       - FAIL: any boundary input produces wrong behavior
       - INCONCLUSIVE: cannot run tests (missing env, external dependency, etc.)

    ## Output Format

    ```
    FC-ID: [FC-N]
    Verdict: PASS / FAIL / INCONCLUSIVE
    Tests Run:
      1. [test description]
         Command: [actual command]
         Output: [first 30 lines of actual output]
         Result: PASS / FAIL
      2. [next test]
         ...
    Evidence Summary:
      [What you observed — factual, not speculative]
    Issues Found:
      [If FAIL: specific description of what went wrong]
      [If INCONCLUSIVE: what prevented verification]
    ```

    ## Critical Rules

    - NO speculative language: "should", "expected", "理论上", "应该"
    - NO claims without running the command
    - NO skipping edge cases because "it should work"
    - If you can't verify something, say INCONCLUSIVE, don't guess

    Work from: [project directory]
```
