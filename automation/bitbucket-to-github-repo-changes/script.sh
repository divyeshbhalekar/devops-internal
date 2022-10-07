declare -a arr=( "slack-integration" )
for i in "${arr[@]}"
do
    echo "$i"
    git clone  https://divyesh71@bitbucket.org/microsecdevs/$i.git && \
    cd $i && \
    git fetch origin && \
    for b in `git branch -r | grep -v -- '->'`; do git branch --track ${b##origin/} $b; done && \
    echo "$i"; git remote add github https://github.com/microsec-ai/$i.git && \
    git pull github main --rebase=false; git pull github master --rebase=false && \
    git push --all github && \
    git push --tags github
    cd ..
done
