#!/usr/bin/env python3
import subprocess
import os
import sys

def get_local_ip(interface):
    try:
        result = subprocess.run(['ip', 'addr', 'show', interface], capture_output=True, text=True)
        output = result.stdout
        ip_line = [line for line in output.split('\n') if 'inet ' in line]
        if ip_line:
            ip_address = ip_line[0].split()[1].split('/')[0]
            return ip_address
        else:
            raise Exception(f"No IP address found for {interface}")
    except Exception as e:
        print(f"Error getting local IP: {e}", file=sys.stderr)
        return None

def read_cached_ip(cache_file='ip_cache.txt'):
    if os.path.exists(cache_file):
        with open(cache_file, 'r') as file:
            return file.read().strip()
    return None

def write_cached_ip(ip_address, cache_file='ip_cache.txt'):
    with open(cache_file, 'w') as file:
        file.write(ip_address)

def main():
    if len(sys.argv) != 2:
        print(f"Usage: python sys.argv[0] <nic>", file=sys.stderr)
        print(f"       i.e, python {sys.argv[0]} eth0", file=sys.stderr)
        sys.exit(1)
    interface = sys.argv[1]
    print(f"Target NIC: {interface}", file=sys.stderr)
    local_ip = get_local_ip(interface)
    if not local_ip:
        print(f"[ERROR] Local IP is not found ", file=sys.stderr)
        sys.exit(1)
    cached_ip = read_cached_ip()
    if not cached_ip:
        print(f"No cached IP, Creating new cache.", file=sys.stderr)
        cached_ip = ""
    if cached_ip == local_ip:
        print(f"[NO CHANGE] Local IP has NOT changed: {local_ip}", file=sys.stderr)
        sys.exit(0)
    else:
        write_cached_ip(local_ip)
        print(f"[UPDATE] New Local IP is : {local_ip}", file=sys.stderr)
        print(local_ip)
        sys.exit(9)

if __name__ == "__main__":
    main()
    sys.exit(0)
