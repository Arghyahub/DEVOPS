# server-stats

A small Bash script that prints basic server performance stats:

- Total CPU usage (sampled over 1 second)
- Memory: total, used, free, available, and usage %
- Disk usage for `/`
- Top 5 processes by CPU
- Top 5 processes by memory

## Requirements

- **Linux** (reads `/proc/stat` and uses GNU `free` and `ps aux --sort`)
- Bash, `awk`, `df`, `free`, `ps` (procps)
- The disk check matches an `overlay` root filesystem (typical in Docker containers)

> **macOS:** it won't run natively because there is no `/proc` or `free`. Run it in a Linux container instead (see below).

## Run

```bash
chmod +x server-stats.sh
./server-stats.sh
```

Or without changing permissions:

```bash
bash server-stats.sh
```

## Run in Docker (e.g. from macOS)

**1. Build** the image (once, and again whenever `server-stats.sh` changes):

```bash
docker build -t server-stats .
```

**2. Run** the container in the background (it stays alive with `sleep infinity`):

```bash
docker run -d --name server-stats server-stats
```

**3. Exec** into it and run the script manually:

```bash
docker exec -it server-stats bash
./server-stats.sh
```

Or run it in one go without opening a shell:

```bash
docker exec server-stats bash /app/server-stats.sh
```

**Stop and clean up:**

```bash
docker rm -f server-stats
```

### With Docker Compose

The script is bind-mounted, so edits on the host apply without rebuilding:

```bash
docker compose up -d --build
docker compose exec server-stats bash /app/server-stats.sh
docker compose down
```

Docker's root filesystem is `overlay`, which is what the disk check expects.

## Sample output

```
CPU Usage: 3.25%

Total Memory: 7940 MB
Used Memory: 812 MB
Free Memory: 6500 MB
Available Memory: 6900 MB
Memory Usage: 13.10%

Disk Usage:
Total Size: 59G
Used Size: 12G
Free Size: 44G
Usage Percent: 21%

Top Processes by CPU Usage:
PID        COMMAND    %CPU
...

Top Processes by Memory Usage:
PID        COMMAND    %MEM
...
```

## Troubleshooting

- **Disk section is empty:** the script greps for a filesystem named `overlay`. On a regular Linux host, change `grep '^overlay'` in `print_disk_parameters` to match your root device (or use `df -h / | tail -n 1`).
- **`Permission denied`:** run `chmod +x server-stats.sh`.
