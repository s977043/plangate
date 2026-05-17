#!/usr/bin/env python3
"""reporting.py — Reporting & Retrospective (#200 / PBI-HI-006).

PlanGate の実利用シグナル（C-3/C-4/V-1/fix loop/hook violation/Keep Rate/
latency）を **期間指定**で集計し、sprint retrospective に貼れる Markdown を
生成する。決定論・ローカル artifact のみ（Web dashboard / 外部 BI / 自動投稿
は Non-goal）。LLM judge を hard gate にしない。C-3/C-4 は緩和しない。

正本: docs/ai/reporting.md

Usage:
  python3 scripts/reporting.py --from 2026-05-01 --to 2026-05-31 [--no-write]
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
WORKING = REPO / "docs" / "working"


def _date(s: str) -> _dt.date:
    return _dt.datetime.strptime(s, "%Y-%m-%d").date()


def _in_range(ts: str | None, lo: _dt.date, hi: _dt.date) -> bool:
    """approved_at を UTC 日付に正規化して期間判定（両端含む）。

    ISO8601（`...Z` / `+09:00` 等）は fromisoformat で parse し UTC へ。
    parse 不能時のみ先頭 YYYY-MM-DD を fallback 採用。欠落/不正は除外。
    """
    if not ts:
        return False
    d = None
    try:
        iso = ts.strip().replace("Z", "+00:00")
        dt = _dt.datetime.fromisoformat(iso)
        if dt.tzinfo is not None:
            dt = dt.astimezone(_dt.timezone.utc)
        d = dt.date()
    except ValueError:
        m = re.match(r"(\d{4}-\d{2}-\d{2})", ts)
        if m:
            try:
                d = _date(m.group(1))
            except ValueError:
                d = None
    if d is None:
        return False
    return lo <= d <= hi


def collect(lo: _dt.date, hi: _dt.date) -> dict:
    tasks = []
    for d in sorted(WORKING.glob("TASK-*")):
        if not d.is_dir():
            continue
        c3p = d / "approvals" / "c3.json"
        if not c3p.is_file():
            continue
        try:
            c3 = json.loads(c3p.read_text())
        except (OSError, ValueError):
            continue
        if not _in_range(c3.get("approved_at"), lo, hi):
            continue
        rec = {"task_id": d.name, "c3_status": c3.get("c3_status")}
        c4p = d / "approvals" / "c4-approval.json"
        if c4p.is_file():
            try:
                rec["c4_status"] = json.loads(c4p.read_text()).get("c4_status")
            except (OSError, ValueError):
                pass
        ev = d / "eval-result.json"
        if ev.is_file():
            try:
                e = json.loads(ev.read_text())
                rec["release_blockers"] = len(
                    e.get("release_blocker_violations", [])
                )
                rec["ac_coverage"] = e.get("ac_coverage", {}).get(
                    "rate_percent"
                )
                rec["latency_cost"] = e.get("latency_cost", {}).get("decision")
            except (OSError, ValueError):
                pass
        kr = d / "keep-rate-result.json"
        if kr.is_file():
            try:
                k = json.loads(kr.read_text())
                rec["keep_rate"] = {
                    "code": k.get("code_keep_rate", {}).get("value"),
                    "plan": k.get("plan_keep_rate", {}).get("value"),
                }
            except (OSError, ValueError):
                pass
        # fix loop / V-1: status.md ヒューリスティック
        st = d / "status.md"
        if st.is_file():
            try:
                t = st.read_text()
            except OSError:
                t = ""
            # fix loop 回数: 1-2 桁・直後がハイフン(日付)でない・上限 50
            mm = re.findall(
                r"fix[ _-]?loop[^0-9\n]{0,16}?([0-9]{1,2})(?![0-9-])",
                t, re.I,
            )
            vals = [int(x) for x in mm if 0 <= int(x) <= 50]
            if vals:
                rec["fix_loop"] = max(vals)
            if t:
                rec["v1_first_pass"] = bool(
                    re.search(r"V-1[^\n]*(PASS|first[ _-]?pass)", t, re.I)
                )
        tasks.append(rec)
    hook_viol = _hook_violations(lo, hi)
    return _aggregate(tasks, lo, hi, hook_viol)


def _hook_violations(lo: _dt.date, hi: _dt.date) -> dict:
    """docs/working/_audit/hook-events.log の VIOLATION を期間集計（決定論）。

    形式: `<ISO ts>\t<LEVEL>\t<hook>\t<task>\t<msg>`。ts を UTC 日付化し
    期間内の VIOLATION 行を hook 別に数える。ログ無/読めない時は unknown。
    """
    log = REPO / "docs" / "working" / "_audit" / "hook-events.log"
    if not log.is_file():
        return {"total": "unknown", "by_hook": {}}
    try:
        lines = log.read_text().splitlines()
    except OSError:
        return {"total": "unknown", "by_hook": {}}
    total = 0
    by_hook: dict = {}
    for ln in lines:
        cols = ln.split("\t")
        if len(cols) < 3 or cols[1] != "VIOLATION":
            continue
        if not _in_range(cols[0], lo, hi):
            continue
        total += 1
        hk = cols[2] or "unknown"
        by_hook[hk] = by_hook.get(hk, 0) + 1
    return {"total": total, "by_hook": by_hook}


def _aggregate(tasks: list[dict], lo: _dt.date, hi: _dt.date,
               hook_viol: dict | None = None) -> dict:
    n = len(tasks)

    def _count(field: str, val: str) -> int:
        return sum(1 for t in tasks if t.get(field) == val)

    # MJ-1: v1_first_pass は観測済（True/False 記録あり）のみ分母に。
    # 未観測（status.md 無 / 文字列無＝key 未設定）は unknown 扱い。
    known = [t for t in tasks if isinstance(t.get("v1_first_pass"), bool)]
    v1p = sum(1 for t in known if t["v1_first_pass"])
    v1_rate = (round(100.0 * v1p / len(known), 1) if known else "unknown")
    fl = [t["fix_loop"] for t in tasks if isinstance(t.get("fix_loop"), int)]
    rb = sum(t.get("release_blockers", 0) or 0 for t in tasks)
    return {
        "schema": "report/v1",
        "period": {"from": lo.isoformat(), "to": hi.isoformat()},
        "task_count": n,
        "c3": {
            "approved": _count("c3_status", "APPROVED"),
            "conditional": _count("c3_status", "CONDITIONAL"),
            "rejected": _count("c3_status", "REJECTED"),
        },
        "c4": {
            "approved": _count("c4_status", "APPROVED"),
            "request_changes": _count("c4_status", "REQUEST_CHANGES"),
            "rejected": _count("c4_status", "REJECTED"),
        },
        "v1_first_pass_rate": v1_rate,
        "v1_first_pass_observed": len(known),
        "v1_first_pass_unknown": n - len(known),
        "fix_loop_max": (max(fl) if fl else "unknown"),
        "release_blocker_total": rb,
        "hook_violation": hook_viol or {"total": "unknown", "by_hook": {}},
        "tasks": tasks,
    }


def render_md(r: dict) -> str:
    p = r["period"]
    c3, c4 = r["c3"], r["c4"]
    lines = [
        f"# PlanGate Report: {p['from']} 〜 {p['to']}",
        "",
        "> retrospective 貼付用。advisory（C-3/C-4 を緩和しない・"
        "LLM judge を hard gate にしない / #200）",
        "",
        f"- 対象 TASK: **{r['task_count']}**",
        f"- C-3: APPROVED {c3['approved']} / CONDITIONAL "
        f"{c3['conditional']} / REJECTED {c3['rejected']}",
        f"- C-4: APPROVED {c4['approved']} / REQUEST_CHANGES "
        f"{c4['request_changes']} / REJECTED {c4['rejected']}",
        f"- V-1 first pass rate: **{r['v1_first_pass_rate']}"
        f"{'%' if isinstance(r['v1_first_pass_rate'], (int, float)) else ''}**",
        f"- V-1 観測: {r['v1_first_pass_observed']} / 未観測(unknown): "
        f"{r['v1_first_pass_unknown']}",
        f"- fix loop max: {r['fix_loop_max']}",
        f"- release blocker total: {r['release_blocker_total']}",
        f"- hook violation: {r['hook_violation']['total']}"
        + (f" ({r['hook_violation']['by_hook']})"
           if r['hook_violation'].get('by_hook') else ""),
        "",
        "## TASK 内訳",
        "",
        "| TASK | C-3 | C-4 | AC% | blockers | keep(code/plan) | latency |",
        "|------|-----|-----|-----|----------|-----------------|---------|",
    ]
    for t in r["tasks"]:
        kr = t.get("keep_rate", {})
        lines.append(
            f"| {t['task_id']} | {t.get('c3_status', '-')} | "
            f"{t.get('c4_status', '-')} | {t.get('ac_coverage', '-')} | "
            f"{t.get('release_blockers', '-')} | "
            f"{kr.get('code', '-')}/{kr.get('plan', '-')} | "
            f"{t.get('latency_cost') or 'unknown'} |"
        )
    lines += [
        "",
        "## 次の harness improvement PBI 候補（抽出指針）",
        "",
        "- C-3 CONDITIONAL/REJECTED 多 → plan 品質 PBI（Plan Quality "
        "Checks #213 強化）",
        "- C-4 REQUEST_CHANGES 多 → exec/レビュー観点 PBI",
        "- V-1 first pass rate 低 → test-cases 精度 / exec 手順 PBI",
        "- fix loop max 高 → fix loop 上限 / EHS-3 escalation 見直し",
        "- release blocker total 増 → 該当 aspect の Gate/taxonomy 強化",
        "- Keep Rate 低 → 採用されない成果物パターンの retro PBI",
        "",
        "> 抽出は **advisory**。実際の PBI 化は人間が判断（EPIC #193 配下）。",
        "",
        "## 関連",
        "",
        "- [`docs/ai/reporting.md`](../ai/reporting.md)",
        "- [`docs/working/templates/retrospective-template.md`]"
        "(./templates/retrospective-template.md)",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser(description="PlanGate Reporting v1 (#200)")
    ap.add_argument("--from", dest="frm", required=True, help="YYYY-MM-DD")
    ap.add_argument("--to", dest="to", required=True, help="YYYY-MM-DD")
    ap.add_argument("--no-write", action="store_true")
    a = ap.parse_args()
    try:
        lo, hi = _date(a.frm), _date(a.to)
    except ValueError:
        print("error: --from/--to must be YYYY-MM-DD", file=sys.stderr)
        return 2
    if lo > hi:
        print("error: --from is after --to", file=sys.stderr)
        return 2
    r = collect(lo, hi)
    md = render_md(r)
    js = json.dumps(r, indent=2, ensure_ascii=False)
    if a.no_write:
        print("=== report.md ===")
        print(md)
        print("=== report.json ===")
        print(js)
    else:
        out = WORKING / "_reports"
        out.mkdir(parents=True, exist_ok=True)
        stem = f"report-{a.frm}_{a.to}"
        (out / f"{stem}.md").write_text(md + "\n")
        (out / f"{stem}.json").write_text(js + "\n")
        print(f"Written: docs/working/_reports/{stem}.{{md,json}}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
