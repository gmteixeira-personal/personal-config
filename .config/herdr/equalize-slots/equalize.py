#!/usr/bin/env python3
"""Equalize a herdr tab: equal-width columns, then equal-height rows in each column.

herdr models a tab as a binary tree of splits. Each split has a direction --
"right" for a vertical divider between columns, "down" for a horizontal one
between rows -- and a ratio, the share given to its first child.

The rule here is one line: every split divides its space evenly among the slots
it separates, counted along its own axis.

    ratio = slots(first) / (slots(first) + slots(second))

A slot is one column (or one row). A pane is one slot. Nested splits of the
same direction flatten into the group, so three columns really do read as
three. A subtree split the other way counts as a single slot: a column that
happens to hold stacked rows is still one column, and gets one column's width.

That last clause is the whole point. Counting panes instead of slots -- which
is what every off-the-shelf equalizer does -- gives a column holding three
stacked panes three times the width of its neighbours.

Only divider positions change. Panes are never created, closed, moved, or
reordered, and nothing running in them is disturbed.

Invoked two ways:

    --action   equalize the tab herdr says is focused, whatever the mode
    --event    a pane changed; equalize the affected tab if mode is "auto"

Mode is read from `config.toml` in the plugin's config directory on every run,
so `herdr-equalize-toggle` can flip it live:

    mode = "auto"      keep tabs equalized as panes come and go (default)
    mode = "keybind"   never resize on our own; only --action does
"""

import json
import os
import re
import socket
import sys
import time

SETTLE_TIMEOUT = 1.5  # seconds to wait for herdr to commit a layout change
SETTLE_STEP = 0.04
EPSILON = 1e-6  # ratios closer than this to the target are left alone


class RpcError(Exception):
    pass


def rpc(method, params):
    """One NDJSON request over herdr's Unix socket."""
    path = os.environ.get("HERDR_SOCKET_PATH")
    if not path:
        raise RpcError("HERDR_SOCKET_PATH is not set")
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(5)
    try:
        sock.connect(path)
        request = {"id": "equalize-slots", "method": method, "params": params}
        sock.sendall((json.dumps(request) + "\n").encode())
        buf = b""
        while b"\n" not in buf:
            chunk = sock.recv(65536)
            if not chunk:
                raise RpcError("socket closed before a reply arrived")
            buf += chunk
    finally:
        sock.close()
    reply = json.loads(buf.split(b"\n", 1)[0])
    if "error" in reply:
        raise RpcError(json.dumps(reply["error"]))
    return reply["result"]


def read_mode():
    """The mode the toggle script writes. Anything unrecognized means "auto"."""
    config_dir = os.environ.get("HERDR_PLUGIN_CONFIG_DIR")
    if not config_dir:
        return "auto"
    try:
        with open(os.path.join(config_dir, "config.toml"), encoding="utf-8") as handle:
            raw = handle.read()
    except OSError:
        return "auto"
    for line in raw.splitlines():
        match = re.match(r'^\s*mode\s*=\s*"([^"]*)"\s*$', line.split("#", 1)[0])
        if match:
            return match.group(1) if match.group(1) in ("auto", "keybind") else "auto"
    return "auto"


def slots(node, direction):
    """Columns (or rows) this subtree occupies along `direction`."""
    if node["type"] == "pane" or node["direction"] != direction:
        return 1
    return slots(node["first"], direction) + slots(node["second"], direction)


def plan(node, path, out):
    """Collect (path, ratio) for every divider that is not already even."""
    if node["type"] == "pane":
        return
    direction = node["direction"]
    first = slots(node["first"], direction)
    second = slots(node["second"], direction)
    target = first / (first + second)
    if abs(target - node["ratio"]) >= EPSILON:
        out.append((list(path), target))
    plan(node["first"], path + [False], out)
    plan(node["second"], path + [True], out)


def equalize(tab_id):
    """Move every divider in one tab into place. Returns how many moved."""
    params = {"tab_id": tab_id} if tab_id else {}
    layout = rpc("layout.export", params)["layout"]
    changes = []
    plan(layout["root"], [], changes)
    moved = 0
    for path, ratio in changes:
        try:
            rpc(
                "layout.set_split_ratio",
                {"tab_id": layout["tab_id"], "path": path, "ratio": ratio},
            )
            moved += 1
        except RpcError:
            # A concurrent split or close invalidated the path. The next event
            # equalizes what is left, so there is nothing useful to do here.
            pass
    return layout["tab_id"], moved


def settle(tab_id):
    """Wait for herdr to finish committing the change that woke us.

    Events can arrive before the tree reflects them, so poll until two reads
    agree on the shape of the tab.
    """
    deadline = time.monotonic() + SETTLE_TIMEOUT
    previous = None
    while time.monotonic() < deadline:
        try:
            layout = rpc("layout.export", {"tab_id": tab_id} if tab_id else {})["layout"]
        except RpcError:
            return  # tab is gone; the caller's equalize will fail the same way
        shape = json.dumps(shape_of(layout["root"]))
        if shape == previous:
            return
        previous = shape
        time.sleep(SETTLE_STEP)


def shape_of(node):
    """The tree without its ratios -- what settle() compares."""
    if node["type"] == "pane":
        return node["pane_id"]
    return [node["direction"], shape_of(node["first"]), shape_of(node["second"])]


def find_key(payload, key):
    """First value for `key` anywhere in the event JSON, whose shape varies."""
    if isinstance(payload, dict):
        if key in payload and isinstance(payload[key], str):
            return payload[key]
        for value in payload.values():
            found = find_key(value, key)
            if found:
                return found
    elif isinstance(payload, list):
        for value in payload:
            found = find_key(value, key)
            if found:
                return found
    return None


def event_tabs():
    """Which tabs the event that woke us could have changed.

    A create or move names its tab. A close often does not -- by the time the
    hook runs the pane is out of the tree -- so fall back to every tab in the
    workspace it names. Equalizing a tab that did not change is a no-op.
    """
    try:
        payload = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON") or "")
    except ValueError:
        payload = {}
    tab_id = find_key(payload, "tab_id")
    if tab_id:
        return [tab_id]
    workspace_id = find_key(payload, "workspace_id")
    if workspace_id:
        try:
            tabs = rpc("tab.list", {"workspace_id": workspace_id})["tabs"]
            return [tab["tab_id"] for tab in tabs]
        except (RpcError, KeyError):
            return []
    return []


def main():
    argument = sys.argv[1] if len(sys.argv) > 1 else ""

    if argument == "--action":
        # No tab id: herdr's own context decides, which is the focused tab.
        tab_id = os.environ.get("HERDR_TAB_ID")
        settle(tab_id)
        tab_id, moved = equalize(tab_id)
        print("equalize-slots: %s, %d divider(s) moved" % (tab_id, moved))
        return 0

    if argument == "--event":
        if read_mode() != "auto":
            return 0
        for tab_id in event_tabs():
            settle(tab_id)
            try:
                tab_id, moved = equalize(tab_id)
            except RpcError as error:
                print("equalize-slots: %s skipped: %s" % (tab_id, error), file=sys.stderr)
                continue
            if moved:
                print("equalize-slots: %s, %d divider(s) moved" % (tab_id, moved))
        return 0

    print("equalize-slots: expected --action or --event", file=sys.stderr)
    return 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except RpcError as error:
        print("equalize-slots: %s" % error, file=sys.stderr)
        sys.exit(1)
