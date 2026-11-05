FROM ubuntu:24.04

WORKDIR /app

COPY server-stats.sh /app/server-stats.sh
RUN chmod +x /app/server-stats.sh

# Keep the container alive so you can exec into it and run the script manually
CMD ["sleep", "infinity"]
