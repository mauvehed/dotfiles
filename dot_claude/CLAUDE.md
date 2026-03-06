# Global Claude Code Instructions

## Explicitness — No Ambiguity, Ever

**Every reference to a file must include its full absolute path and the host/machine it lives on.**
Never say "edit .env" or "update the config." Say "edit `/home/nate/project/app/.env` on `server-name`" or "edit `/Users/nate/project/.env` on the local Mac."

**Every proposed action must state exactly what it will do.**
Never say "apply the changes" or "update the service." Be explicit:
- If editing a file: state the full file path and host.
- If restarting a service: state the exact command (e.g., `systemctl restart nginx`), the full working directory, and the host.
- If running docker compose: state the exact command (e.g., `docker compose up -d`), the full path to the compose file, and the host.
- If running any command: state the exact command, the working directory, and the host/machine.

**Never use vague verbs like "apply", "update", "configure", or "set up" without immediately specifying the concrete action** — what command, what file, what path, what host. If multiple steps are involved, list each one explicitly.

**When asking for confirmation, the confirmation prompt itself must be explicit.**
Bad: "Shall I apply the changes?"
Good: "Shall I edit `/Users/nate/myproject/docker-compose.yml` on this Mac to add the new volume mount, then run `docker compose up -d` from `/Users/nate/myproject/`?"

## Interaction Protocol

**Questions require answers, not actions.**
When I ask a question, provide analysis and explanation. Do not make code changes based on questions alone — wait for explicit instruction to implement.

**Lead with your best thinking.**
When asked for recommendations or a plan, provide complete analysis upfront. Do not hold back better ideas for later or present a minimal version waiting to be asked "anything else?" My time is valuable — I shouldn't have to interrogate you to extract good ideas.

**Discuss before executing.**
I verbally process and ask questions to explore ideas. Do not take action in response to exploratory questions — I want to discuss before committing to an approach.

## SSH Command Execution

**SSH commands MUST always include `cd` to the working directory.**
When running commands on remote hosts via `ssh`, ALWAYS use the form:
```
ssh <host> "cd <working-directory> && <command>"
```
NEVER run `ssh <host> "docker compose ..."` or `ssh <host> "systemctl ..."` or any service/deployment command without an explicit `cd` to the working directory first. There are no exceptions. The remote shell starts in `~`, which is never the right place.

**When retrying a failed SSH command, actually fix the command.**
If an SSH command fails because of a missing `cd`, do not re-run the same broken command. Add the `cd <directory> &&` prefix. If you catch yourself about to run the same failing command again, stop and think about what went wrong.

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
