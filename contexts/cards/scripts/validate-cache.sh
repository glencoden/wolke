# fetch remote commit info
git_response=$(git ls-remote https://github.com/glencoden/cards-backend.git | egrep 'main|merge')

# parse for commit hash
parsed_response=$(echo "$git_response" | tr '\t' ' ')
commit_hash=$(echo "$parsed_response" | cut -d' ' -f1)

# store the exit status of the git command in a variable
git_exit_status=$?

if [ $git_exit_status -eq 0 ]; then
  sed -i "" -e "5s/.*/ARG COMMIT_HASH=$commit_hash/" contexts/cards/Dockerfile
else
  echo "git command failed"
fi

# if the commit hash is no option, you can invalidate docker cache every run with a timestamp:

# cache_time=$(date +%s)
# sed -i "" -e "6s/.*/ARG CACHE_TIME=$cache_time/" contexts/tsc/Dockerfile