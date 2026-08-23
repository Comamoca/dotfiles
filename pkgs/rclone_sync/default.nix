{ pkgs, homeDirectory, ... }:
pkgs.writers.writePython3Bin "rclone-sync"
  {
    libraries = [ pkgs.python3Packages.requests ];
    flakeIgnore = [
      "E501"
      "W503"
    ];
  }
  ''
    import subprocess
    import json
    import sys
    import os

    bisync_dir = os.path.expanduser("~/.cache/rclone/bisync")
    if os.path.isdir(bisync_dir):
        for f in os.listdir(bisync_dir):
            if f.endswith(".lck"):
                os.remove(os.path.join(bisync_dir, f))

    base_cmd = [
        "${pkgs.rclone}/bin/rclone",
        "--config", "${homeDirectory}/.config/rclone/rclone.conf",
        "bisync",
        "r2:memo",
        "${homeDirectory}/.ghq/github.com/Comamoca/memo",
        "--use-json-log",
        "--log-level", "INFO",
    ]

    notify = "${pkgs.libnotify}/bin/notify-send"

    # rclone bisync refuses to run again after a critical error until a
    # --resync is performed (it deliberately won't guess a sync direction
    # once the prior listing snapshots are gone). Without self-healing here,
    # a single interrupted run (e.g. suspend/network drop mid-bisync) leaves
    # the service failing on every timer tick forever.
    needs_resync_markers = (
        "cannot find prior",
        "must run --resync",
    )


    def run_bisync(resync):
        cmd = base_cmd + (["--resync"] if resync else [])
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )

        stats = None
        saw_resync_marker = False

        for line in process.stdout:
            try:
                data = json.loads(line)
            except json.JSONDecodeError:
                continue
            if "stats" in data:
                stats = data["stats"]
            msg = data.get("msg", "").lower()
            if any(marker in msg for marker in needs_resync_markers):
                saw_resync_marker = True

        process.wait()
        return process.returncode, stats, saw_resync_marker


    rc, last_stats, saw_resync_marker = run_bisync(resync=False)

    if rc != 0 and saw_resync_marker:
        subprocess.run([notify, "Memo Sync", "Prior listing lost, running --resync to recover"])
        rc, last_stats, _ = run_bisync(resync=True)

    if rc != 0:
        subprocess.run([notify, "Memo Sync", "Error: rclone exited with code " + str(rc)])
        sys.exit(rc)

    if not last_stats:
        subprocess.run([notify, "Memo Sync", "Error: no stats from rclone"])
        sys.exit(1)

    changes = (
        last_stats["transfers"]
        + last_stats["deletes"]
        + last_stats["renames"]
    )

    errors = last_stats["errors"]

    if errors != 0:
        subprocess.run([notify, "Memo Sync", "Error occurred"])
        sys.exit(1)
    elif changes > 0:
        msg = str(changes) + " changes applied"
        subprocess.run([notify, "Memo Sync", msg])
  ''
