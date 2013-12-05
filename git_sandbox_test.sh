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
  cecho "This is Test $1"
  fname=test$1

  if [ -d "$fname" ]; then
    cecho "We first need to delete the test1 directory. Press enter to delete."
    runCmd . rm -rf $fname
  fi
  mkdir -p $fname
}


echo $ps_str

if [ "$#" -ne 1 ] ; then
  cecho "Welcome to the git sandbox test."
  cecho "Novice Tests are from 1-3"
  cecho "Adept Test are from 4-6"
  cecho "Run a test like so, and follow directions there: "
  cecho "$0 [Test Number]  (there are X tests total)"
  echo $ps_str
  exit
fi


if [ "$skip_through" -eq 1 ] ; then
  testSetup $skip_through 

  cecho "Directions: in this test you will need to create:"
  cecho "... a central repository in $fname/repo.git"
  cecho "... a cloned repository in $fname/alice"
  cecho "... a cloned repository in $fname/bob"

  pause

  cecho "To begin, press CTRL-Z to pause this script."
  cecho "After you are done, type \"fg\" to continue"
  cecho " You're back, press enter, and we will test your work"
  pause

  runFastCmd . touch $fname/alice/file1.txt
  runFastCmd $fname/alice git add $fname/alice/file1.txt
  runFastCmd $fname/alice git commit -am "\"Initial Commit\""
  runFastCmd $fname/alice git push
  runFastCmd $fname/bob git pull

  cecho "If no errors appear above, then all is working great!"
fi



if [ "$skip_through" -eq 2 ] ; then
  cecho "This is Test $skip_through"

fi








