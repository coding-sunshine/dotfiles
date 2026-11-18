---
description: Deepen a task before building it — what a top professional would do, from the rawest material, with their instruments, judged by something outside the model
argument-hint: <the task to deepen>
allowed-tools: Read, Grep, Glob, Bash
---

Task: **$ARGUMENTS**

I want a deeper version of this task, not a bigger one. Before rewriting it: (1) say what a top professional in this field would do here that I'm not asking for; (2) name the rawest material they would start from instead of what has already been digested for me; (3) name the specific methods and tools they would use; (4) say what, other than you or me, would show the result is right. Then rewrite my prompt to ask for exactly that.

## Rules for the four answers

- **Deeper, not bigger.** Same goal, same scope. An answer that adds a feature
  gets cut.
- **(2) names material that exists here.** A table, a log, a file path, an API,
  a command's output. Look before you name it. If the rawest material is not
  reachable from this machine, say which access is missing; that gap is part of
  the answer.
- **(3) names instruments you will run.** A SQL query, a profiler, a statistical
  test, a benchmark, a fuzzer, a reproduction script. Models switch vocabulary
  without switching methods; a markdown table where a query would answer is
  that switch.
- **(4) is a runnable check.** A test, a benchmark with a number, held-out data,
  a third-party validator. Not you re-reading your work, not me eyeballing it.
  Where the result has a number, set a hard target (ask for 200ms, not 5s) and
  treat it as reachable.

## Output

1. The four answers, one short paragraph each.
2. The rewritten prompt in a fenced block, ready to paste.
3. Stop. Do not start the work. Once I approve, the rewritten prompt goes to
   `/contract` and answer (4) becomes its criteria.
