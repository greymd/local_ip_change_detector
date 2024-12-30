# local_ip_change_detector

Detect local IPv4 address change

## Usage

```
$ python3 ./main.py enp4s0 2>/dev/null
=> Return exit status 0 if the local IPv4 address is NOT changed
$ python3 ./main.py enp4s0 2>/dev/null
xxx.xxx.xxx.xxx
=> if the local IPv4 address is changed from the last running time, returns exit status 9 and print New IP address to stdout
```

Pure Bash version is available.
It works as same as Python ver.

```
$ bash ./main.sh enp4s0 2>/dev/null
```

## Usecase

```bash
#!/bin/bash
while true;
do
  new_ip="$(python3 ./main.py enp4s0 2>/dev/null)"
  if [ $? -eq 9 ]; then
    # Do something you like
  fi
  sleep 1
done
```
