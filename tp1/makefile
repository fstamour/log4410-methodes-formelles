

q1: q1.pml
	spin -a q1.pml
	cc -DSAFETY pan.c -o $@

.PHONY: run-q1
run-q1:
	spin -T q1.pml

clean:
	rm -f q1 q2 pan* *.trail
