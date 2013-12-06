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
  if !$istest; then
    cecho "This is Test $1"
    fname=test$1
  
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
  echo "TESTING MODE"
fi



if [ "$skip_through" -eq 1 ] ; then
  if [ ! $istest ]; then
    testSetup $skip_through 
    cecho "Directions: in this test you will need to create:"
    cecho "... a central repository in $fname/repo.git"
    cecho "... a cloned repository in $fname/alice"
    cecho "... a cloned repository in $fname/bob"
  
    pause
  
    cecho "When You're done, run $0 $skip_through --test."
  else
    runFastCmd $fname/alice git pull 
    runFastCmd . touch $fname/alice/file1.txt
    runFastCmd $fname/alice git add file1.txt
    runFastCmd $fname/alice git commit -am "\"Initial Commit\""
    runFastCmd $fname/alice git push origin master
    runFastCmd $fname/bob git pull 
    cecho "No errors should appear above!"
  fi
  exit
fi



if [ "$skip_through" -eq 2 ] ; then
  cecho "This is Test $skip_through"
  exit
fi

echo "There is no Test $skip_through, sorry"






