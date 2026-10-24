"""Archive every issue and pull request of a GitHub repository.

GitHub cannot move issues or pull requests to another repository, so this
script saves them: the raw API data as JSON and one readable Markdown page per
issue or pull request, with every comment, review and label, plus an index.

Usage (needs the GitHub CLI, logged in):
    python export_github.py andersoxie/xpact

Writes next to this script:
    json/       raw API responses
    items/      issue-0079.md, pr-0080.md, ...
    README.md   index of all items
"""

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent


def gh_api(path):
    """Return the parsed JSON of a paginated GitHub API GET."""
    output = subprocess.run(["gh", "api", "--paginate", "--slurp", path],
                            check=True, capture_output=True, text=True, encoding="utf-8").stdout
    pages = json.loads(output)
    if pages and isinstance(pages[0], list):
        return [item for page in pages for item in page]
    return pages[0] if len(pages) == 1 else pages


def short(date):
    return date[:16].replace("T", " ") if date else ""


def quote_block(text):
    return text.strip() if text and text.strip() else "_(no text)_"


def main(repo):
    json_dir = HERE / "json"
    items_dir = HERE / "items"
    json_dir.mkdir(exist_ok=True)
    items_dir.mkdir(exist_ok=True)

    issues = gh_api(f"repos/{repo}/issues?state=all&per_page=100")
    pulls = {p["number"]: p for p in gh_api(f"repos/{repo}/pulls?state=all&per_page=100")}
    labels = gh_api(f"repos/{repo}/labels?per_page=100")
    milestones = gh_api(f"repos/{repo}/milestones?state=all&per_page=100")

    archive = []
    for issue in sorted(issues, key=lambda i: i["number"]):
        number = issue["number"]
        is_pr = "pull_request" in issue
        entry = {"issue": issue,
                 "comments": gh_api(f"repos/{repo}/issues/{number}/comments?per_page=100") if issue["comments"] else []}
        if is_pr:
            entry["pull"] = gh_api(f"repos/{repo}/pulls/{number}")
            entry["reviews"] = gh_api(f"repos/{repo}/pulls/{number}/reviews?per_page=100")
            entry["review_comments"] = gh_api(f"repos/{repo}/pulls/{number}/comments?per_page=100")
            entry["commits"] = gh_api(f"repos/{repo}/pulls/{number}/commits?per_page=100")
        archive.append(entry)
        print(f"{'PR' if is_pr else 'issue'} #{number}", file=sys.stderr)

    exported = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    (json_dir / "items.json").write_text(json.dumps(archive, indent=1, ensure_ascii=False), encoding="utf-8")
    (json_dir / "labels.json").write_text(json.dumps(labels, indent=1, ensure_ascii=False), encoding="utf-8")
    (json_dir / "milestones.json").write_text(json.dumps(milestones, indent=1, ensure_ascii=False), encoding="utf-8")

    rows = []
    for entry in archive:
        issue = entry["issue"]
        number = issue["number"]
        pull = entry.get("pull")
        kind = "pr" if pull else "issue"
        name = f"{kind}-{number:04d}.md"
        label_names = [l["name"] for l in issue["labels"]]
        if pull:
            state = "merged" if pull.get("merged_at") else issue["state"]
            if pull.get("draft"):
                state += " (draft)"
        else:
            state = issue["state"] + (f" ({issue['state_reason']})" if issue.get("state_reason") else "")

        lines = [f"# {'Pull request' if pull else 'Issue'} #{number}: {issue['title']}", "",
                 f"Archived from <{issue['html_url']}> on {exported}.", "",
                 "| | |", "|---|---|",
                 f"| State | {state} |",
                 f"| Author | {issue['user']['login']} |",
                 f"| Created | {short(issue['created_at'])} |",
                 f"| Closed | {short(issue.get('closed_at'))} |",
                 f"| Labels | {', '.join(f'`{n}`' for n in label_names) or '-'} |",
                 f"| Milestone | {issue['milestone']['title'] if issue.get('milestone') else '-'} |"]
        if pull:
            lines += [f"| Branches | `{pull['head']['ref']}` → `{pull['base']['ref']}` |",
                      f"| Merged | {short(pull.get('merged_at')) or '-'} by {(pull.get('merged_by') or {}).get('login', '-')} |",
                      f"| Merge commit | `{(pull.get('merge_commit_sha') or '')[:7]}` |",
                      f"| Changes | +{pull['additions']} −{pull['deletions']} in {pull['changed_files']} files, {pull['commits']} commits |"]
        lines += ["", "## Description", "", quote_block(issue.get("body")), ""]
        if pull and entry["commits"]:
            lines += ["## Commits", ""]
            lines += [f"- `{c['sha'][:7]}` {c['commit']['message'].splitlines()[0]}" for c in entry["commits"]]
            lines.append("")
        events = [("comment", c) for c in entry["comments"]]
        events += [("review", r) for r in entry.get("reviews", []) if r.get("body") or r.get("state") != "COMMENTED"]
        events += [("review comment", c) for c in entry.get("review_comments", [])]
        events.sort(key=lambda e: e[1].get("created_at") or e[1].get("submitted_at") or "")
        if events:
            lines += ["## Discussion", ""]
            for kind_name, event in events:
                when = short(event.get("created_at") or event.get("submitted_at"))
                extra = f" ({event['state'].lower()})" if kind_name == "review" else ""
                extra += f" on `{event['path']}`" if kind_name == "review comment" else ""
                lines += [f"### {event['user']['login']}, {when}: {kind_name}{extra}", "", quote_block(event.get("body")), ""]
        (items_dir / name).write_text("\n".join(lines), encoding="utf-8")
        rows.append(f"| [#{number}](items/{name}) | {'PR' if pull else 'Issue'} | {issue['title'].replace('|', '/')} | {state} "
                    f"| {', '.join(label_names) or '-'} | {short(issue['created_at'])[:10]} |")

    issue_count = sum(1 for e in archive if "pull" not in e)
    index = [f"# GitHub archive of {repo}", "",
             f"Every issue and pull request of <https://github.com/{repo}>, exported on {exported} "
             f"with [`export_github.py`](export_github.py): {issue_count} issues and {len(archive) - issue_count} pull requests, "
             "with all comments, reviews, labels and milestones.", "",
             "GitHub cannot move issues or pull requests to another repository, so this archive keeps them. "
             "Numbers match the original repository, so `#79` in a report is [items/issue-0079.md](items/issue-0079.md). "
             "Raw API data: [`json/`](json/).", "",
             "| # | Type | Title | State | Labels | Created |", "|---|---|---|---|---|---|"] + rows + [""]
    (HERE / "README.md").write_text("\n".join(index), encoding="utf-8")
    print(f"{len(archive)} items archived", file=sys.stderr)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "andersoxie/xpact")
