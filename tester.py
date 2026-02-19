import subprocess, os

def compile_qbe_file(file):
	print(f"{file=}")
	with open(file, "r") as f:
		print(f.read())
	subprocess.call(f"qbe -o out.s -t amd64_win {file}".split())
	subprocess.call("gcc -o out out.s".split())
	subprocess.call("rm out.s".split())
	subprocess.call("./out.exe".split())

files = [os.path.join("out", f) for f in os.listdir("out")]
print(files)

for f in files:
	compile_qbe_file(f)
	print("\n\n\n\n")
