

model: model.pml
	spin -a model.pml
	cc -DNOREDUCE -DSAFETY pan.c -o $@

.PHONY: run-model
run-model:
	spin -T model.pml

clean:
	rm -f model q2 pan* *.trail
