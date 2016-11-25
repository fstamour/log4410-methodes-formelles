
tp3.tar.gz: rapport.pdf $(wildcard *.cpn)
	 tar -zcvvf $@ $^

rapport.pdf: rapport.tex Ex_1_3_state_space.txt
	pdflatex $<

Ex_1_3_state_space.txt: Ex_1_3+SS.cpn 
	extract_state_space_from_report.sh $^


