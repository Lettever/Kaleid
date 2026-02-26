import subprocess, os, sys

"""
def compile_qbe_file(file):
	print(f"{file=}")
	with open(file, "r") as f:
		print(f.read())
	subprocess.call(f"qbe -o out.s -t amd64_win {file}".split())
	subprocess.call("gcc -o out out.s".split())
	subprocess.call("rm out.s".split())
	subprocess.call("./out.exe".split())
"""
def compile_qbe_file(file):
	print(f"{file=}")
	with open(file, "r") as f:
		print(f.read())
	if sys.platform.startswith('win'):
		# Windows version
		subprocess.call(f"qbe -o out.s -t amd64_win {file}".split())
		subprocess.call("gcc -o out out.s".split())
		subprocess.call("rm out.s".split())
		subprocess.call("./out.exe".split())
	else:
		# Linux/Unix version
		subprocess.call(f"qbe -o out.s {file}".split())
		subprocess.call("gcc -o out out.s".split())
		subprocess.call("rm out.s".split())
		subprocess.call("./out".split())

folder = "out-qbe"
files = [os.path.join(folder, f) for f in os.listdir(folder)]
print(f"{files=}")

for f in files:
	compile_qbe_file(f)
	print("\n\n\n\n")

subprocess.call("rm out".split())
