cache_time=$(date +%s)

sed -i "" -e "6s/.*/ARG CACHE_TIME=$cache_time/" contexts/tsc/Dockerfile