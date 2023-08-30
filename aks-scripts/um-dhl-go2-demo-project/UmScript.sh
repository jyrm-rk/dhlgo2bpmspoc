#!/bin/sh


attempt_counter=0
isCondtion=0
max_attempts=100
desiredNumberOfPods=1
foundMyConnectionFactory="false"
runUMTool="true"
jmsChannelList=(MyFirstBpm_MyFirstProcess_SUBQUEUE MyFirstBpm_MyFirstProcess_TRANSQUEUE MySecondBPM_MySecondProcess_TRANSQUEUE MySecondBPM_MySecondProcess_SUBQUEUE mytestq1 mytestq2 MySecondBPM_MySecondBPM_FirstSubProcess_SUBQUEUE MySecondBPM_MySecondBPM_FirstSubProcess_TRANSQUEUE MyThirdBPM_MyThirdProcess_SUBQUEUE MyThirdBPM_MyThirdProcess_TRANSQUEUE MyFourthBPM_MyFourthProcess_SUBQUEUE MyFourthBPM_MyFourthProcess_TRANSQUEUE)


if [ ${runUMTool} = "true" ];then

echo "Will run UM script on the first pod....waiting for all pods to be in READY and RUNNING state...."

until [ $isCondtion -eq "1" ]; do
    numberOfReadyUMPods=$(kubectl get pods $1 | grep dhl-um-demo-my-project | awk '{print $2}' | grep 1/1 | wc -l)
    numberOfRunningPods=$(kubectl get pods $1 | grep dhl-um-demo-my-project | awk '{print $3}' | grep Running | wc -l)
    if [ ${attempt_counter} -eq ${max_attempts} ];then
      echo "Max attempts reached , all pods did not come in READY status within 5 minutes"
      break
    fi
    if [ ${desiredNumberOfPods} -eq ${numberOfReadyUMPods} ] && [ ${desiredNumberOfPods} -eq ${numberOfRunningPods} ];then
      isCondtion=1
      echo "....all Pods are now in RUNNING and READY state...."
      break
    fi
    printf '....waiting for all pods to be in READY and RUNNING state....'
    attempt_counter=$(($attempt_counter+1))
    sleep 3
done

echo "-------------------------------------------"

echo "Number of running UM pods in Ready state :" && echo $numberOfRunningPods

echo "-------------------------------------------"

firstUmPodName=$(kubectl get pods $1 | grep --max-count 1 dhl-um-demo-my-project | awk '{print $1}')

echo "-------------------------------------------"

echo "Pod on which script will be execute :" && echo $firstUmPodName

echo "-------------------------------------------"

echo "-----------executing UMtool instructions-------------------"

echo "----------checking if connection factor already exists---------------------------------"

kubectl $1 exec $firstUmPodName  -- /bin/bash -c "/opt/softwareag/UniversalMessaging/tools/runner/runUMTool.sh ViewConnectionFactory -rname=nsp://dhl-um-demo-my-project-clusterip-svc:9000 -factoryname=local_um" && foundMyConnectionFactory="true"

echo "----------------foundMyConnectionFactory value is : $foundMyConnectionFactory------------------"

echo "-------------------------------------------"

if [ ${foundMyConnectionFactory} = "false" ];then

kubectl $1 exec $firstUmPodName  -- /bin/bash -c "/opt/softwareag/UniversalMessaging/tools/runner/runUMTool.sh CreateConnectionFactory -rname=nsp://dhl-um-demo-my-project-clusterip-svc:9000 -connectionurl=nsp://dhl-um-demo-my-project-clusterip-svc:9000 -factoryname=local_um -durabletype=S"

fi

##check if JMS queue exists

for j in ${jmsChannelList[@]}
do
myChannel=$j
echo "--------------checking if channel $myChannel exists----------"
foundMyChannel="false"

channelDetails=$(kubectl $1 exec $firstUmPodName  -- /bin/bash -c "/opt/softwareag/UniversalMessaging/tools/runner/runUMTool.sh ListChannels -rname=nsp://dhl-um-demo-my-project-clusterip-svc:9000 -format=json")

echo $channelDetails | grep $myChannel && foundMyChannel="true"

echo "----------value of foundMyChannel: $foundMyChannel--------------------"

 if [ ${foundMyChannel} = "false" ];then

echo "-------------- $myChannel not found. Will create the channel ----------" 

kubectl $1 exec $firstUmPodName  -- /bin/bash -c "/opt/softwareag/UniversalMessaging/tools/runner/runUMTool.sh CreateJMSQueue -rname=nsp://dhl-um-demo-my-project-clusterip-svc:9000 -queuename=$myChannel"

else

echo "------------------channel $myChannel already exists. Skipping creation----------------------"

 fi

 done


fi

