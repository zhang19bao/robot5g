#!/bin/bash
if [ $# -ne 2 ]
then
    echo "please input config du_version"
    exit 1
fi

config=$1
du_version=$2
echo "config is $config"
echo "du_version is  $du_version"

sed -i 's/gnb_du_1.7_[0-9]\{4,9\}/gnb_du_1.7_'$du_version'/g' /home/robot5g/config/Beijing/$config/variables.robot

cd /home/robot5g
robot -t 'Nr_case1_attach' --variable config:$config -d results -L Trace --debug debug NR/
