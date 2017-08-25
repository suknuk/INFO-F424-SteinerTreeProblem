#!/bin/bash
for formulation in PF P2T PF2; do
	for file in instances/*
	do
		for i in {1..1}
		do
			echo executing $file $formulation
			julia main.jl --file "$file" --formulation $formulation --verbose true --saveresult results.txt
		done
	done
done

