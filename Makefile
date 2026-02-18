exe:
	qbe -o out.s -t amd64_win out.qbe
	gcc -o out out.s
	rm out.s

bin:
	qbe -o out.s out.qbe
	gcc -o out out.s
	rm out.s

clean:
	rm out.qbe out
	qbe -o out.s out.qbe
