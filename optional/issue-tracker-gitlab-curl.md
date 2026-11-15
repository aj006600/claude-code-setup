# Issue tracker: GitLab (REST API with curl)

For GitLab hosts where the `glab` CLI is not available. Copy this file to the project as `docs/agents/issue-tracker.md`, replacing the `glab` version that `/setup-matt-pocock-skills` generates. Issues and specs for the repo live as GitLab issues; every operation goes through the GitLab REST API with `curl`.

## Authentication

Per `CLAUDE.md`, the token embedded in the remote URL is the sole credential, and the API host is the remote's host. Read both from `git remote get-url origin` in the same shell that makes the calls. Never write the token into a file, a doc, an issue or a commit.

```bash
url=$(git remote get-url origin)
tok=${url#*:}; tok=${tok#*:}; tok=${tok%%@*}
host=${url#*@}; host=${host%%/*}
proj=${url#*@}; proj=${proj#*/}; proj=${proj%.git}; proj=${proj//\//%2F}
api="https://$host/api/v4/projects/$proj"
auth="PRIVATE-TOKEN: $tok"
```

Every example below assumes these variables. Use `--data-urlencode` for any text field so that Markdown, quotes and non-ASCII text survive; `field@file` reads the value from a file, which is the easy way to send a multi-line description.

## Issues

- **Create**: `curl -s -H "$auth" -X POST "$api/issues" --data-urlencode "title=..." --data-urlencode "description@body.md" --data-urlencode "labels=needs-triage"`. The response's `iid` is the issue number.
- **Read**: `curl -s -H "$auth" "$api/issues/<iid>"` for the issue, and `curl -s -H "$auth" "$api/issues/<iid>/notes?sort=asc&per_page=100"` for its comments. Notes with `"system": true` are GitLab's own activity lines; skip them.
- **List**: `curl -s -H "$auth" "$api/issues?state=opened&labels=ready-for-agent&per_page=100"`. `labels` takes a comma-separated list and matches issues carrying all of them.
- **Comment**: `curl -s -H "$auth" -X POST "$api/issues/<iid>/notes" --data-urlencode "body@comment.md"`. GitLab calls comments "notes".
- **Change labels**: `curl -s -H "$auth" -X PUT "$api/issues/<iid>" --data-urlencode "add_labels=ready-for-agent" --data-urlencode "remove_labels=needs-triage"`. Both take comma-separated lists.
- **Edit the description**: `curl -s -H "$auth" -X PUT "$api/issues/<iid>" --data-urlencode "description@body.md"`. This replaces the whole description.
- **Close**: post the explanation as a comment first, then `curl -s -H "$auth" -X PUT "$api/issues/<iid>" -d state_event=close`. `state_event=reopen` reopens.

Pipe a response through `python3 -m json.tool`, or a short `python3 -c` that prints the fields you need, to read it.

## Blocking relationships

Native blocking links are a Premium / Ultimate feature; on tiers where the issue-links API rejects them, record blocking only in the blocked issue's description, as a `## Blocked by` section that lists the blockers:

```markdown
## Blocked by

- #229
- #230
```

An issue with no blockers lists `- None (can start immediately).` An issue is unblocked when every issue in that section is closed. To change it, edit the description.

## Merge requests

GitLab calls PRs "merge requests" (MRs). Ask the user before opening one, as `CLAUDE.md` requires.

- **Create**: `curl -s -H "$auth" -X POST "$api/merge_requests" -d source_branch=<branch> -d target_branch=main --data-urlencode "title=..." --data-urlencode "description@mr.md"`. The response's `iid` and `web_url` identify it.
- **Read**: `curl -s -H "$auth" "$api/merge_requests/<iid>"`; its comments are at `$api/merge_requests/<iid>/notes`, and its diff at `$api/merge_requests/<iid>/diffs`.
- **List by branch**: `curl -s -H "$auth" "$api/merge_requests?source_branch=<branch>&state=opened"`.
- **Comment**: `curl -s -H "$auth" -X POST "$api/merge_requests/<iid>/notes" --data-urlencode "body@comment.md"`.
- **Pipelines**: `curl -s -H "$auth" "$api/merge_requests/<iid>/pipelines"` lists them; `$api/pipelines/<id>/jobs` gives each job's status, and `$api/jobs/<job_id>/trace` its log.
- **Merge**: `curl -s -H "$auth" -X PUT "$api/merge_requests/<iid>/merge"`. Only when the user has asked for the merge.

Unlike GitHub, GitLab numbers issues and MRs separately: `#42` is an issue and `!42` is an MR.

## When a skill says "publish to the issue tracker"

Create a GitLab issue.

## When a skill says "fetch the relevant ticket"

Read the issue and its notes.

## Merge requests as a triage surface

**MRs as a request surface: no.** `/triage` reads this flag: external merge requests are not treated as feature requests, so triage covers issues only.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body.
- **Child ticket**: an issue carrying `Part of #<map>` at the top of its description and labels `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: the `## Blocked by` section in the description, as in "Blocking relationships".
- **Frontier query**: list the map's open children, drop any with an open issue in its `Blocked by` section or with an assignee; first in map order wins.
- **Claim**: set the assignee, `curl -s -H "$auth" -X PUT "$api/issues/<n>" -d assignee_ids=<your user id>` (your id is `id` in `curl -s -H "$auth" "https://$host/api/v4/user"`). This is the session's first write.
- **Resolve**: comment with the answer, close the issue, then append a context pointer (gist + link) to the map's Decisions-so-far.
