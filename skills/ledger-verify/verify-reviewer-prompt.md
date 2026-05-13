# Verify Reviewer Prompt Template

Use this template when dispatching a verify reviewer subagent to audit evidence quality.

```
Task tool (general-purpose):
  description: "Review verify evidence quality for [feature name]"
  prompt: |
    You are reviewing the quality of adversarial verification evidence.

    ## Contract

    [FULL TEXT of contract — paste here]

    ## FC Verification Results

    [Paste all FC subagent results here — the full output from each verify subagent]

    ## CRITICAL: Do Not Trust Claims

    The verify subagents may have been optimistic, incomplete, or used speculative
    language. You MUST audit every piece of evidence independently.

    ## Your Job

    For each FC verdict, verify:

    ### Evidence Presence
    - Does PASS have actual command output? (not "I ran it and it worked")
    - Does the output actually show the expected behavior?
    - Are there any claims without corresponding evidence?

    ### Speculative Language Scan
    Flag any occurrence of:
    - "应该", "预期", "理论上", "理应"
    - "should", "expected", "theoretically", "ought to"
    - "probably", "seems to", "looks like"
    - Any statement about behavior without running the command

    ### Coverage Check
    - Does each FC have tests for normal path AND edge cases?
    - Are boundary values actually tested (not just mentioned)?
    - Are error cases verified with real error output?

    ### Consistency
    - Do the FC verdicts align with the evidence shown?
    - A PASS verdict with incomplete evidence = should be INCONCLUSIVE
    - A FAIL verdict without specific failure details = needs more info

    ## Output Format

    ```
    Approved: Yes / No

    Per-FC Review:
      FC-01: ✅ / ❌
        [Specific findings]

      FC-02: ✅ / ❌
        [Specific findings]

    Issues Found:
      - [FC-N]: [specific issue with line reference]
      - [FC-N]: [specific issue]

    Speculative Language Found:
      - [FC-N]: "[exact quote]" → should be replaced with [what]

    Missing Evidence:
      - [FC-N]: [what test is missing]
    ```

    ## What Makes Evidence Acceptable

    ✅ Good:
    ```
    Command: npm test -- --grep "rejects empty email"
    Output: FAIL: expected "Email required", got undefined
    Result: FAIL (correctly identifies missing validation)
    ```

    ❌ Bad:
    ```
    Tested with empty email, validation works correctly.
    ```
    (No command, no output, just a claim)
```
