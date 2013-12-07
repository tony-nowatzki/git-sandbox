#!/bin/bash
# Git Sandbox Demo
# Tony Nowatzki
# 12/10/2013
# tjn@cs.wisc.edu

skip_through=0


skip_through=$1
lesson_count=100

ps_str="$(tput setaf 1)--------------------------------------------------------------------------------$(tput sgr0)"

pause() {
  if [ "$skip_through" -le "$lesson_count" ]; then
    read -p $ps_str
  else
    echo $ps_str
  fi
}

cecho() {
#echo -en '\E[47;34m'"\033[1mE\033[0m" 
  tput setaf 4
  echo -e "$@"
  tput sgr0
}

important_point=0
ipoint() {
  ipoint_count=$((ipoint_count + 1))
  tput setaf 5
  echo -e "$ipoint_count. $@"
  tput sgr0
}

defgit() {
#echo -en '\E[47;34m'"\033[1mE\033[0m" 
  tput setaf 3
  echo -ne "$1"
  tput setaf 4
  echo -e "$2"
  tput sgr0
}



runFastCmd() {
  dir=$1
  cd $dir
  shift
#  echo "($dir) >>>" $@
  asdf="$@"
  tput setaf 3
  echo "($dir) >>> $asdf  $(tput sgr0)"
  "$@"
  cd - &> /dev/null
}

runSilent() {
  dir=$1
  cd $dir
  shift
  "$@" &> /dev/null
  cd - &> /dev/null
}


runCmd() {
  dir=$1
  cd $dir
  shift
#  echo "($dir) >>>" $@
  asdf="$@"
  tput setaf 3

  if [ "$skip_through" -le "$lesson_count" ]; then
    read -p  "($dir) >>> $asdf  $(tput sgr0)"
  else
    echo "($dir) >>> $asdf  $(tput sgr0)"
  fi

  "$@"
  cd - &> /dev/null
}



showFiles() {
  cd $1
  for i in $2*; do
    tput setaf 4
    echo -n "File: "
    tput sgr0
    echo -n $i
    tput setaf 4
    echo  ", contents:"
    tput sgr0
    cat $i
  done
  cd - &> /dev/null
}

lesson() {
  lesson_count=$((lesson_count + 1))
  if [ "$skip_through" -le "$lesson_count" ]; then
    read -p $ps_str
  else
    echo $ps_str
  fi
  tput setaf 1
  echo "   LESSON " $lesson_count ": " $@
  tput sgr0
  echo $ps_str
}

commit_n() {
  cd $1  
  #echo "git log | grep commit | sed -n $2p | cut -d" " -f2 | cut -c1-7"
  echo `git log | egrep "^commit" | sed -n $2p | cut -d" " -f2 | cut -c1-7`
  cd - &> /dev/null
}

testSetup() {
  fname=test$1

  if ! $istest ; then
    cecho "This is Test $1"  
    if [ -d "$fname" ]; then
      cecho "We first need to delete the test1 directory. Press enter to delete."
      runCmd . rm -rf $fname
    fi
    mkdir -p $fname
  fi
}


echo $ps_str

if [ "$#" -eq 0 ] ; then
  cecho "Welcome to the git sandbox test."
  cecho "Novice Tests are from 1-3"
  cecho "Adept Test are from 4-6"
  cecho "Run a test like so, and follow directions there: "
  cecho "$0 [Test Number]  (there are X tests total)"
  echo $ps_str
  exit
fi


isnumber() { 
  test "$1" && printf '%f' "$1" >/dev/null; 
}

setupRepo() {
  mkdir -p $1
  pushd $1 &> /dev/null


  mkdir -p repo.git
  cd repo.git
  git init --bare &> /dev/null
  cd ..
  git clone repo.git alice &> /dev/null
  git clone repo.git bob &> /dev/null
  
  popd &> /dev/null
}

istest=false
skip_through=-1

while [ $# -gt 0 ]
do
    case "$1" in
    (-t) istest=true;;
    (--test) istest=true;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*)
      isnumber $1 && skip_through=$1
      ;;
    esac
    shift
done

if $istest; then
  echo "                   TESTING MODE                      "
fi



if [ "$skip_through" -eq 1 ] ; then
  testSetup $skip_through 

  cecho "Directions: in this test you will need to create:"
  cecho "... a central repository in $fname/repo.git"
  cecho "... a cloned repository in $fname/alice"
  cecho "... a cloned repository in $fname/bob"
  cecho "... one shared file called called file.txt (containing anything you want)"

  if ! $istest ; then
    cecho "When You're done, run $0 $skip_through --test."
  else
    echo $ps_str
    runFastCmd $fname/alice git pull 
    runFastCmd . touch $fname/alice/random-file.txt
    runFastCmd $fname/alice git add random-file.txt
    runFastCmd $fname/alice git commit -am "\"Initial Commit\""
    runFastCmd $fname/alice git push #origin master
    runFastCmd $fname/bob git pull
    diff $fname/alice/file.txt $fname/bob/file.txt
    cecho "No errors should appear above!"
  fi
  exit
fi


if [ "$skip_through" -eq 2 ] ; then
  testSetup $skip_through 

  cecho "Directions: in this test, a familiar repo structure has been created. Rules:"
  cecho "1. Commit any uncomitted changes from all parties, and resolve any conflicts that occur."
  cecho "2. Don't add/commit any .out files to the repo.  (a .gitignore may help)"

  if ! $istest ; then
    cecho "When You're done, run $0 $skip_through --test."
    setupRepo $fname

    touch $fname/alice/source1.txt
    runSilent $fname/alice git add source1.txt
    runSilent $fname/alice git commit -am "Initial Commit"
    runSilent $fname/alice git push origin master
    runSilent $fname/bob git pull


    (cat <<STUFF
1. This is the first line.
2. The second line, this is.
3. A fourth line, of course.
4. To be sure, this is the fourth line.
STUFF
) > $fname/alice/source1.txt

    (cat <<STUFF
1. This is the first line.
2. The second line, this is.
2. The third line, of course.
4. To be sure, this is the fourth line.
STUFF
) > $fname/bob/source1.txt


    echo "Hello" > $fname/alice/source2.txt

    cecho "# One moment please ... "
    for i in {a..z}; do
      for j in {a..f}; do
        for k in {0..4}; do
          cat /dev/urandom | head -1 > $fname/alice/${i}${i}${j}-${k}.out
          cat /dev/urandom | head -1 > $fname/bob/${i}${i}${j}-${k}.out
        done
      done
    done
    
    cecho "# Done, go ahead. : )"

  else
    echo $ps_str
    (cat <<STUFF
1. This is the first line.
2. The second line, this is.
3. The third line, of course.
4. To be sure, this is the fourth line.
STUFF
) > $fname/.tmp1

    diff $fname/.tmp1 $fname/bob/source1.txt
    diff $fname/.tmp1 $fname/alice/source1.txt

    echo "Hello" > $fname/.tmp2

    diff $fname/.tmp2 $fname/bob/source2.txt
    diff $fname/.tmp2 $fname/alice/source2.txt

    echo "If nothing is printed above, you are successful!"
  fi
  exit
fi

if [ "$skip_through" -eq 3 ] ; then
  testSetup $skip_through 

  cecho "In this test, one of the repositories has a change in a local branch."
  cecho "Directions: Put this change on the master branch, and make sure everyone"
  cecho "has the change. (Hint: a merge may be required)"

  if ! $istest ; then

    setupRepo $fname

    touch $fname/alice/source.txt
    runSilent $fname/alice git add source.txt
    runSilent $fname/alice git commit -am "Initial Commit"
    runSilent $fname/alice git push origin master
    runSilent $fname/bob git pull

    (cat <<STUFF
1. This is the first line.
2. The second line, this is.
3. The third line, of course.
4. To be sure, this is the fourth line.
STUFF
) > $fname/alice/source.txt

    runSilent $fname/alice git add source.txt
    runSilent $fname/alice git commit -am "Commit 2"
    runSilent $fname/alice git push

    runSilent $fname/bob git pull
    runSilent $fname/bob git branch local_branch
    runSilent $fname/bob git checkout local_branch
    echo -n "5. " >> $fname/bob/source.txt
    runSilent $fname/bob git commit -am "added entry 5"
    echo "And finally, the fifth line." >> $fname/bob/source.txt
    runSilent $fname/bob git commit -am "completed entry 5"
    runSilent $fname/bob git checkout master
  else 

    (cat <<STUFF
1. This is the first line.
2. The second line, this is.
3. The third line, of course.
4. To be sure, this is the fourth line.
5. And finally, the fifth line.
STUFF
) > $fname/.tmp1
    cecho $ps_str
    diff $fname/.tmp1 $fname/alice/source.txt
    cecho "If nothing appears above, then you have been successful!"
  fi
  exit
fi

if [ "$skip_through" -eq 4 ] ; then
  testSetup $skip_through 

  cecho "In this scenario, bob was coding late at night when he couldn't"
  cecho "couldn't think properly."
  cecho "Directions: "
  cecho "1. Revert back to a commit with the source in a proper state."
  cecho "2. Distribute these changes to all."

  if ! $istest ; then

    setupRepo $fname

    touch $fname/alice/source.txt
    runSilent $fname/alice git add source.txt
    runSilent $fname/alice git commit -am "Initial Commit"
    runSilent $fname/alice git push origin master
    runSilent $fname/bob git pull

    (cat <<STUFF
1. This is the first line.
2. The second line, this is.
3. The third line, of course.
4. To be sure, this is the fourth line.
STUFF
) > $fname/alice/source.txt

    runSilent $fname/alice git add source.txt
    runSilent $fname/alice git commit -am "Commit 2"
    runSilent $fname/alice git push

    runSilent $fname/bob git pull
    echo -n "5. " >> $fname/bob/source.txt
    runSilent $fname/bob git commit -am "added entry 5"
    echo "The perfect fifth line." >> $fname/bob/source.txt
    runSilent $fname/bob git commit -am "completed entry 5"
    sed -i 'N;s/\(.*\)\n\(.*\)/\2\n\1/' $fname/bob/source.txt
    runSilent $fname/bob git commit -am "wooo, it's getting late..."
    sed -i 's/ is/ WAS/g' $fname/bob/source.txt
    runSilent $fname/bob git commit -am "OMG, sed is so cool!"
    sed -i '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' $fname/bob/source.txt 
    runSilent $fname/bob git commit -am "asdfkasfkjsdhfkasjh"

    runSilent $fname/bob git push
    runSilent $fname/alice git pull
 
  else 

    (cat <<STUFF
1. This is the first line.
2. The second line, this is.
3. The third line, of course.
4. To be sure, this is the fourth line.
5. The perfect fifth line.
STUFF
) > $fname/.tmp1
    cecho $ps_str
    git pull 
    diff $fname/.tmp1 $fname/alice/source.txt
    diff $fname/.tmp1 $fname/bob/source.txt
    cecho "If nothing appears above, then you have been successful!"
  fi
  exit
fi



if [ "$skip_through" -eq 5 ] ; then
  testSetup $skip_through 

  cecho "In this scenario, Alice's source file is empty and she can't figure"
  cecho "out why. She *swears* she comitted files, but can't see her changes"
  cecho "in the log.  Help her get them back!"
  cecho "Directions: "
  cecho "1. Find alice's missing commits, and restore them.."
  cecho "2. Distribute these changes to all."

  if ! $istest ; then

    setupRepo $fname

    touch $fname/alice/source.txt
    runSilent $fname/alice git add source.txt
    runSilent $fname/alice git commit -am "Initial Commit"

    (cat <<STUFF
1. This is the First line.
2. The Second line, this is.
3. The Third line, of course.
4. To be sure, this is the Fourth line.
STUFF
) > $fname/alice/source.txt

    runSilent $fname/alice git commit -am "Commit 2"

    runSilent $fname/alice git branch local_branch
    echo -n "5. " >> $fname/alice/source.txt
    runSilent $fname/alice git commit -am "added entry 5"
    echo "The perfect Fifth line." >> $fname/alice/source.txt
    runSilent $fname/alice git commit -am "completed entry 5"

    runSilent $fname/alice git reset --hard HEAD~3

  else
    (cat <<STUFF
1. This is the First line.
2. The Second line, this is.
3. The Third line, of course.
4. To be sure, this is the Fourth line.
5. The perfect Fifth line.
STUFF
) > $fname/.tmp1
    runSilent $fname/alice git checkout -f master
    runSilent $fname/bob git checkout -f master

    cecho $ps_str
    diff $fname/.tmp1 $fname/alice/source.txt
    diff $fname/.tmp1 $fname/bob/source.txt
    cecho "If nothing appears above, then you have been successful!"
  
  fi
  exit
fi





echo "There is no Test $skip_through, sorry"









