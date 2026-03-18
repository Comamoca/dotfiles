{ pkgs, homeDirectory, ... }:

pkgs.writers.writePython3Bin "rclone-sync" {
        libraries = [ pkgs.python3Packages.requests ];
      } ''
      import subprocess
      import json
      import sys
      
      cmd = [
          "${pkgs.rclone}/bin/rclone",
          "--config", "${homeDirectory}/.config/rclone/rclone.conf",
          "bisync",
          "r2:memo",
          "${homeDirectory}/.ghq/github.com/Comamoca/memo/mount/",
          "--use-json-log",
          "--log-level", "INFO",
      ]
      
      process = subprocess.Popen(
          cmd,
          stdout=subprocess.PIPE,
          stderr=subprocess.STDOUT,
          text=True,
      )
      
      last_stats = None
      
      for line in process.stdout:
          try:
              data = json.loads(line)
              if "stats" in data:
                  last_stats = data["stats"]
          except json.JSONDecodeError:
              continue
      
      process.wait()
      
      if not last_stats:
          sys.exit(0)
      
      changes = (
          last_stats["transfers"]
          + last_stats["deletes"]
          + last_stats["renames"]
      )
      
      errors = last_stats["errors"]
      
      if errors != 0:
          subprocess.run(["${pkgs.libnotify}/bin/notify-send", "Memo Sync ❌", "Error occurred"])
      elif changes > 0:
          subprocess.run(["${pkgs.libnotify}/bin/notify-send", "Memo Sync 🔄", f"{changes} changes applied"])
      '';
