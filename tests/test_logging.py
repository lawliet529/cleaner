import os
from pathlib import Path
import subprocess
import sys
import tempfile


entrypoint = Path(__file__).resolve().parents[1] / "entrypoint.sh"
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    cleanup = root / "cleanup.sh"
    cleanup.write_text("#!/bin/sh\nprintf 'cleanup output\\n'\nprintf 'cleanup error\\n' >&2\n")
    cleanup.chmod(0o755)
    cron = root / "cron"
    script = root / "entrypoint.sh"
    script.write_text(
        entrypoint.read_text()
        .replace("/etc/cleanup_env", str(root / "cleanup_env"))
        .replace("/etc/crontabs/root", str(cron))
        .replace("/cleanup.sh", str(cleanup))
    )
    crond = root / "crond"
    crond.write_text(
        f"#!{sys.executable}\n"
        "import pathlib, shlex, subprocess\n"
        "print('cron output', flush=True)\n"
        f"job = pathlib.Path({str(cron)!r}).read_text()\n"
        "subprocess.run(shlex.split(job[job.index('/bin/sh'):]), check=True)\n"
    )
    crond.chmod(0o755)
    env = dict(os.environ, PATH=f"{root}:{os.environ['PATH']}",
               CLEAN_DIR=str(root), CLEAN_OLDER_THAN="30m", CLEAN_SCHEDULE="0 * * * *")
    env.pop("LOG_FILE", None)
    for log_file in (None, "", str(root / "cleaner's log.txt")):
        current_env = env.copy()
        if log_file is not None:
            current_env["LOG_FILE"] = log_file
        result = subprocess.run(["sh", str(script)], env=current_env, capture_output=True, text=True)
        assert result.returncode == 0, result.stderr
        output = Path(log_file).read_text() if log_file else result.stdout
        for message in ("cron output", "cleanup output", "cleanup error"):
            assert message in output, output
        assert result.stderr == "", result.stderr
        if log_file:
            assert result.stdout == "", result.stdout
        else:
            assert not list(root.glob("*.log"))
    result = subprocess.run(["sh", str(script)],
                            env=dict(env, LOG_FILE=str(root / "missing" / "log.txt")),
                            capture_output=True, text=True)
    assert result.returncode != 0

print("Logging checks passed")
