#!/bin/bash

[ -z $1 ] && exit "Specify p4factory repository as first argument"
[ -z $2 ] && exit "Specify name of the target as second argument"
[ -d $1 ] || exit "Invalid p4factory repository root dir $1"

P4FACTORY_DIR=$1
TARGET_DIR=$P4FACTORY_DIR/targets/$2
[ -d $TARGET_DIR ] || exit "Could not find target directory $TARGET_DIR"
CWD="$PWD"

LIONSGATE=$TARGET_DIR/behavioral_model
OFT=$TARGET_DIR/run_tests.py
# Parent directory where the bfn/ directory exists in which the 
# JSON files and the blob are present
# Directory where the tests are present

[ -z $3 ] || TESTDIR=$3
[ -z $3 ] && TESTDIR=$TARGET_DIR/of-tests/tests
echo TESTDIR $TESTDIR

LIONSGATE_LOG=$CWD/lionsgate.log
LIONSGATE_ERR_LOG=$CWD/lionsgate_err.log
OFT_LOG=$CWD/oft.log
OFT_ERR_LOG=$CWD/ofterr.log
OFT_LOG_2=$CWD/oft2

cleanup() {
        local pids=$(jobs -pr)
        [ -n "$pids" ] && kill $pids
}

trap "cleanup" EXIT
#Only EXIT seems sufficient
#trap "cleanup" INT QUIT TERM EXIT
set -e


#Check for the files
[ -e $TARGET_DIR ]  || exit "Target $2 does not exist"
[ -e $OFT ]     || exit "$OFT does not exist"
[ -d $TESTDIR ] || exit "$TESTDIR directory does not exist"


rm -f $LIONSGATE_LOG
rm -f $LIONSGATE_ERR_LOG
rm -f $OFT_LOG
rm -f $OFT_ERR_LOG
rm -f $OFT_LOG_2
rm -f $OFT_LOG_2.pcap

cd $TARGET_DIR
./behavioral-model > $LIONSGATE_LOG 2>$LIONSGATE_ERR_LOG &

sleep 5
echo 'Running tests'
set +e
cd $TARGET_DIR
$OFT --test-dir $TESTDIR --log-file=$OFT_LOG_2 > $OFT_LOG 2>$OFT_ERR_LOG

rc=$?
if [[ $rc != 0 ]] ; then
    echo "OFTests failed. Please check $OFT_LOG and $OFT_ERR_LOG"
    exit 1
else
    echo "All OFTests Passed"
fi

