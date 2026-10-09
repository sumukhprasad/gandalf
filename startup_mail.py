#!/usr/bin/env python3

import os
import signal
import subprocess
import time
from pathlib import Path

ROOT = Path.cwd()
COMMAND = ["ruby", "email_worker.rb"]
SMTP_ADDRESS = input("Value for env var \"SMTP_ADDRESS\"? ")
SMTP_PORT = input("Value for env var \"SMTP_PORT\"? ")
SMTP_USERNAME = input("Value for env var \"SMTP_USERNAME\"? ")
SMTP_PASSWORD = input("Value for env var \"SMTP_PASSWORD\"? ")

def start_worker():
	env = os.environ.copy()

	print("Starting worker...")
	
	env["SMTP_ADDRESS"] = SMTP_ADDRESS
	env["SMTP_PORT"] = SMTP_PORT
	env["SMTP_USERNAME"] = SMTP_USERNAME
	env["SMTP_PASSWORD"] = SMTP_PASSWORD

	return subprocess.Popen(
		COMMAND,
		env=env,
	)


def stop_worker(process):
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
	process = start_worker()
	
	try:
		while True:
			time.sleep(0.5)

			if process.poll() is not None:
				print("Worker exited, restarting...")
				process = start_worker()

	except KeyboardInterrupt:
		print("\nBye.")

	finally:
		stop_worker(process)


if __name__ == "__main__":
	main()