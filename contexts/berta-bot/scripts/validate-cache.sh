# fetch remote commit info
git_response=$(git ls-remote https://github.com/glencoden/berta-bot.git | egrep 'main|merge')

# parse for commit hash
parsed_response=$(echo "$git_response" | tr '\t' ' ')
commit_hash=$(echo "$parsed_response" | cut -d' ' -f1)

# store the exit status of the git command in a variable
git_exit_status=$?

if [ $git_exit_status -eq 0 ]; then
  sed -i "" -e "5s/.*/ARG COMMIT_HASH=$commit_hash/" contexts/berta-bot/Dockerfile
else
  echo "git command failed"
fi