#!/bin/bash

# Get cpu time
get_cpu_time() {
    cpu=$(awk '/^cpu / {print $2 + $3 + $4 + $5 + $6 + $7 + $8}' /proc/stat)
    echo $cpu
}

# Get idle time
get_idle_time() {
    idle=$(awk '/^cpu / {print $5 + $6}' /proc/stat)
    echo $idle
}

fmt_divide() {
    awk "BEGIN {printf \"%.2f\", $1 / $2}"
}

# Get Total Memory
get_total_memory() {
    total=$(free -m | awk '/^Mem:/ {print $2}')
    echo $total
}

# Get Used Memory
get_used_memory() {
    used=$(free -m | awk '/^Mem:/ {print $3}')
    echo $used
}

# Get Free Memory
get_free_memory() {
    free=$(free -m | awk '/^Mem:/ {print $4}')
    echo $free
}

# Get Available Memory
get_available_memory() {
    available=$(free -m | awk '/^Mem:/ {print $7}')
    echo $available
}

# Get Disk Usage
print_disk_parameters() {
    disk=$(df -h / | grep '^overlay')
    total_size=$(echo $disk | awk '{print $2}')
    used_size=$(echo $disk | awk '{print $3}')
    free_size=$(echo $disk | awk '{print $4}')
    usage_percent=$(echo $disk | awk '{print $5}')
    echo "Total Size: $total_size"
    echo "Used Size: $used_size"
    echo "Free Size: $free_size"
    echo "Usage Percent: $usage_percent"
}

# Cpu prev
prev_cpu=$(get_cpu_time)
prev_idle=$(get_idle_time)

sleep 1

curr_cpu=$(get_cpu_time)
curr_idle=$(get_idle_time)

cpu_usage=$((curr_cpu - prev_cpu))
idle_usage=$((curr_idle - prev_idle))

# Ouput
cpu_percent=$(fmt_divide $(((cpu_usage - idle_usage)*100)) $cpu_usage)

# Final Output
echo "CPU Usage: $cpu_percent%"

echo ""

total_memory=$(get_total_memory)
used_memory=$(get_used_memory)
free_memory=$(get_free_memory)
available_memory=$(get_available_memory)
memory_usage_percent=$(fmt_divide $(( (total_memory - available_memory)*100 )) $((total_memory)))

echo "Total Memory: $total_memory MB"
echo "Used Memory: $used_memory MB"
echo "Free Memory: $free_memory MB"
echo "Available Memory: $available_memory MB"
echo "Memory Usage: $memory_usage_percent%"

echo ""

echo "Disk Usage:"
print_disk_parameters

echo ""

echo "Top Processes by CPU Usage:"
ps aux --sort=-%cpu | head -n 6 | awk '{printf "%-10s %-10s %-10s\n" , $2,$11,$3}'

echo ""

echo "Top Processes by Memory Usage:"
ps aux --sort=-%mem | head -n 6 | awk '{printf "%-10s %-10s %-10s\n" , $2,$11,$4}'