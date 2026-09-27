# shell-scripts
Example script
```
$./example_script.sh -h
  Example script description.

  Usage: example_script.sh [-h] [-o argument]
    -h   This text.
    -o argument   Option with argument.
```
Notes
```
$./notes.sh -h
    Simple notes system.

    Usage: notes.sh [-h] [-a] [-u] [-r] [-l]
        -h help
		-l list notes
        -a add new note
        -u update note
        -r remove note
```
Open
```
$./open.sh -h
  Open file.

  Usage: open.sh [-h] file
    -h   This text.
```
Timer
```
$./timer.sh -h
 Description: Timer for film develpment.
 Usage: timer.sh -m minutes [-s seconds] 
  -s seconds 	number
  -m minutes 	number
 Example: timer.sh -m 5 -s 40

```
Todo
```
$./todo.sh -h
  Simple "TODO" system.

  Usage: todo.sh [-h|s] [[-t tag] -j description -w date] 
    -h   This text.
    -s                  Show todo list.
    -j description      Job to do.
    -w date             Job date.

  Examples:
    todo.sh -s                                               #Show todo list.
    todo.sh -t "work"                                        #Add new tag.
    todo.sh -j "Doctor appointment" -w 23-12-2026            #Add new item
    todo.sh -j "Doctor appointment" -w 28-02-2026 -t work    #Add new item with tag
```
