#!/usr/bin/env python3

import os
import signal
import subprocess
import time
import secrets
from pathlib import Path

SESSION_SECRET = secrets.token_hex(64)

ROOT = Path.cwd()
COMMAND = ["bundle", "exec", "rackup", "-p", "4567"]
IGNORED_DIRS = {
	".git",
	".bundle",
	"tmp",
	"log",
	"db"
}


def get_file_state():
	state = {}

	for path in ROOT.rglob("*"):
		if not path.is_file():
			continue

		# ignore the ignored!
		if any(part in IGNORED_DIRS for part in path.relative_to(ROOT).parts):
			continue

		try:
			stat = path.stat()
			state[str(path)] = (stat.st_mtime_ns, stat.st_size)
		except OSError:
			pass

	return state


def start_rackup():
	env = os.environ.copy()
	env["SESSION_SECRET"] = SESSION_SECRET
	env["AUTO_ASSIGN"] = "1"

	print("Starting rackup...")

	return subprocess.Popen(
		COMMAND,
		env=env,
	)


def stop_rackup(process):
	if process.poll() is not None:
		return

	print("Stopping rackup...")

	process.terminate()

	try:
		process.wait(timeout=5)
	except subprocess.TimeoutExpired:
		print("Rackup did not stop, killing it...")
		process.kill()
		process.wait()


def main():
	process = start_rackup()
	previous_state = get_file_state()

	try:
		while True:
			time.sleep(0.5)

			current_state = get_file_state()

			if current_state != previous_state:
				print(">> File change detected, restarting rackup...")

				stop_rackup(process)
				process = start_rackup()

				previous_state = current_state

			# If rackup crashes/exits on its own, restart it.
			elif process.poll() is not None:
				print("Rackup exited, restarting...")
				process = start_rackup()
				previous_state = current_state

	except KeyboardInterrupt:
		print("\nBye.")

	finally:
		stop_rackup(process)


if __name__ == "__main__":
	main()