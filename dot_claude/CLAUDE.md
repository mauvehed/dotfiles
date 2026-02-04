# Global Claude Code Instructions

## Interaction Protocol

**Questions require answers, not actions.**
When I ask a question, provide analysis and explanation. Do not make code changes based on questions alone — wait for explicit instruction to implement.

**Lead with your best thinking.**
When asked for recommendations or a plan, provide complete analysis upfront. Do not hold back better ideas for later or present a minimal version waiting to be asked "anything else?" My time is valuable — I shouldn't have to interrogate you to extract good ideas.

**Discuss before executing.**
I verbally process and ask questions to explore ideas. Do not take action in response to exploratory questions — I want to discuss before committing to an approach.

## Safety Rules

**Destructive operations require explicit confirmation.**
This includes but is not limited to:
- Deleting files, directories, or resources (`rm -rf`, `DROP TABLE`, etc.)
- Force pushes or history rewrites
- Removing Docker volumes or containers with data
- Modifying production systems (even if there's no dev/staging)
- Network/firewall/DNS changes that could affect connectivity
- Any operation that cannot be easily undone

**Prefer dry-run when available.**
If a tool supports `--dry-run`, `--what-if`, or similar, use it first.

**Read-only first when investigating.**
Start with non-mutating operations. Use LIMIT clauses on database queries. Don't modify state just to see what happens.

**Search before create.**
Before creating files, configs, database entries, or resources, check if they already exist to prevent duplicates.

**Stay in scope.**
Complete the requested task. Do not expand scope, refactor adjacent code, or "improve" unrelated things without discussing first.

## Code Philosophy

**Delete old code, don't preserve it.**
When replacing or migrating code:
- Delete the old implementation completely
- Do not create backward compatibility wrappers
- Do not keep deprecated methods "for legacy support"
- Force compilation/runtime errors to expose missed references
- Git history exists if we need to reference old implementations

**Single source of truth.**
One way to do things, not multiple parallel implementations.

## Git Standards

**Commit message format:**
- Use conventional commits: `type(scope): description`
- Types: feat, fix, docs, style, refactor, perf, test, chore
- Imperative mood, lowercase, no period at end
- No emoji
- No "Generated with Claude Code" or co-author attribution

**Verify before committing:**
Always check `git diff --staged` to confirm actual changes match the intended commit message.

## Documentation

When documentation is needed, place it in `./docs/` unless the project specifies otherwise.

## Formatting Preferences

- No emoji in code, comments, documentation, or commit messages
- Use text-based status indicators: `[PASS]`, `[FAIL]`, `WARNING:`, `ERROR:`
- Clean, professional formatting without decorative elements
