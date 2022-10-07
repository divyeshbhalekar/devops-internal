echo "Enter the name of existing repo: "
read existing_repo_name
echo "Enter the url of new repo: "
read new_url
git clone git@bitbucket.org:microsecdevs/$existing_repo_name.git

cd $existing_repo_name
git remote add new-origin $new_url
for b in `git branch -r | grep -v -- '->' | grep "new-origin" | sed 's/new-origin\///g'`; do git pull new-origin $b; done
git pull new-origin master
git push --all new-origin
