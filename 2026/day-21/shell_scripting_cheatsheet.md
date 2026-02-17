Day 21 – Shell Scripting Cheat Sheet

These are my quick notes while revising shell scripting.
Kept it short so I can refer back quickly when writing scripts.

Task 1: Basics
Shebang
```bash
#!/bin/bash


Tells Linux to run the script using bash.

Running a script
chmod +x script.sh
./script.sh
bash script.sh
```

First makes script executable, then runs it.

Comments
```bash
# This is a comment
echo "Hello"  # inline comment
```

Used to leave notes in scripts.

Variables
```bash
NAME="server"
echo $NAME
```

Variables store values. Useful in automation scripts.
```bash
Reading input
read -p "Enter name: " NAME
echo $NAME

```
Takes input from user.

Arguments
```bash
echo $0
echo $1
echo $#
echo $?
```

Used when passing values to scripts.

Task 2: Operators and Conditionals
String comparison
```bash
[ "$a" = "$b" ]
[ -z "$a" ]

```
Used to compare or check empty values.

Integer comparison
```bash
[ $a -lt $b ]
[ $a -gt $b ]
[ $a -eq $b ]
```

Used for numeric checks.

File checks
```bash
[ -f file.txt ]
[ -d folder ]
```

Check if file or directory exists.
```bash
if
If else
if [ -f file.txt ]; then
  echo "Exists"
else
  echo "Not found"
fi
```


Basic condition handling.

Logical operators
`````bash
[ condition ] && echo "OK"
[ condition ] || echo "Fail"
`````

Used for short conditions.
```bash

Case
case $1 in
 start) echo "start";;
 stop) echo "stop";;
 *) echo "invalid";;
esac
```

Cleaner than multiple if-else sometimes.

Task 3: Loops
```bash
for i in 1 2 3
do
 echo $i
done

```

Runs commands multiple times.

While loop
```bash

i=1
while [ $i -le 3 ]
do
 echo $i
 ((i++))
done

```
Runs while condition is true.
```bash

i=1
Until loop
until [ $i -gt 3 ]
do
 echo $i
 ((i++))
done

```
Runs until condition becomes true.

Loop files
```bash
for file in *.log
do
 echo $file
done
```

Useful for log processing.

Task 4: Functions
Function
```bash
greet() {
 echo "hello"
}
```

Used to reuse code.
```bash
Call function
greet
```

Runs the function.
```bash
Arguments in function
sum() {
 echo $(($1+$2))
}
sum 2 3
```

Pass values inside functions.

Task 5: Text Processing
```bash
grep
grep error app.log

```
Search logs quickly.
```bash
awk
awk '{print $1}' file.txt
```

Print columns.
```bash
sed
sed
sed -i 's/dev/test/g' file.txt

```
Replace text in files.
```bash
cut
cut -d',' -f1 file.csv
```

Extract columns.
```bash
sort
sort -r file.txt

sort and uniq
sort file.txt | uniq
```

Remove duplicates.
```bash
wc
wc -l file.txt

```
Count lines.
```bash
tail logs
tail -f app.log

```
Monitor logs in real time.

Task 6: Useful One-Liners

Delete old files:

find . -type f -mtime +7 -delete
```bash

Count logs:

wc -l *.log
```

Check service:
```bash
systemctl status nginx

```
Monitor errors:
```bash
tail -f app.log | grep ERROR

```
Disk usage:
```bash
df -h
```
Task 7: Debugging

Exit code:
```bash
echo $?
```

Stop script on error:
```bash

set -e
```

Debug mode:
```bash
set -x

```
Trap example:
```bash
trap 'cleanup' EXIT
trap 'echo cleanup' EXIT

```
Runs command when script exits.