exe:
	qbe out.qbe -o out.s && gcc out.s -o out
	rm out.s

clean:
	rm out.qbe out