## Day 10 – File Permissions & File Operations Challenge

# Task
Master file permissions and basic file operations in Linux.

Create and read files using touch, cat, vim  
Understand and modify permissions using chmod  

---

# Expected Output
A markdown file: `day-10-file-permissions.md`  
Screenshots showing permission changes  

---

# Challenge Tasks

# Task 1: Create Files (10 minutes)
- Create empty file `devops.txt` using `touch`
- Create `notes.txt` with some content using `cat` or `echo`
- Create `script.sh` using `vim` with content:

echo "Hello DevOps"

- Verify:
```bash
ls -l
```

# Task 2: Read Files (10 minutes)
```bash
Read notes.txt using cat

View script.sh in vim read-only mode

Display first 5 lines of /etc/passwd using head

Display last 5 lines of /etc/passwd using tail
```

# Task 3: Understand Permissions (10 minutes)

```bash
Format: rwxrwxrwx (owner-group-others)

r = read (4)

w = write (2)

x = execute (1)

Check your files:

ls -l devops.txt notes.txt script.sh


Answer:

What are current permissions?

Who can read/write/execute?
```
# Task 4: Modify Permissions (20 minutes)
```bash
Make script.sh executable → run it with ./script.sh

Set devops.txt to read-only (remove write for all)

Set notes.txt to 640 (owner: rw, group: r, others: none)

Create directory project/ with permissions 755

Verify:

ls -l
```

after each change

# Task 5: Test Permissions (10 minutes)
```bash
Try writing to a read-only file – what happens?

Try executing a file without execute permission

Document the error messages

Hints

Create: touch, cat > file, vim file

Read: cat, head -n, tail -n

Permissions: chmod +x, chmod -w, chmod 755

Documentation

Create day-10-file-permissions.md:

# Day 10 Challenge

## Commands Used

```bash
# File creation
touch devops.txt
cat > notes.txt
vim script.sh

# Viewing file permissions
ls -l
ls -l devops.txt notes.txt script.sh

# Reading files
cat notes.txt
vim -R script.sh
head -n 5 /etc/passwd
tail -n 5 /etc/passwd

# Modifying permissions
chmod +x script.sh
chmod a-w devops.txt
chmod 640 notes.txt
chmod 755 project

# Directory creation
mkdir project

# Executing script
./script.sh

# Permission testing
echo "test" >> devops.txt
chmod -x script.sh
./script.sh
```

## What I Learned
[it is a very crusial part of linux so being consistent is very important]