#!/bin/bash
FILES="$1/*.mx3"
i=0
for file in $FILES
do
	((i++))
	echo "Mumax3 is running: $i"
	mumax3 $file
done

echo ".mx3 files processed"