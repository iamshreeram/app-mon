#!/bin/bash
#set -x

CURRHOME=`pwd`
CONFIG=`echo $CURRHOME/config/app.conf`
INST_URLS=`echo $CURRHOME/config/instanceurl_file`
INST_NAMES=`echo $CURRHOME/config/instance_names`
STATFILE=`echo $CURRHOME/StatusOutput`
OUT=`echo $CURRHOME/today.html`
XDATAFILE=`echo $CURRHOME/xdata.pid`
LOGFILE="log.out"

STARTXDATA=350
TILE='<rect class=status width=20 height=20 x=xdata y=ydata><title>version</title></rect>'
COMP='<text dx=xaxis dy=yaxis>comp</text>'
#ver_re='^[0-9]+([.][0-9]+)?$'
ver_re='^[0-9]+(.*)?$'

read_config() {
        CONFIG=`cat $CONFIG`;
        if [[ `echo $CONFIG` == *,* ]];
        then
                COMPURL=`echo $CONFIG | sed 's/[A-Za-z0-9_-/]*,//g'`;
        elif [[ `echo $CONFIG` == */* ]];
        then
                COMPURL=`echo $CONFIG`;
        elif ! ([[ `echo $CONFIG` == *,* ]] || [[ `echo $CONFIG` == */* ]]);
        then
                COMPURL=`cat $INST_URLS`
        else
                echo "<h1>Can't monitor the application. Config file is missing or corrupted.</h1>">>$OUT
                exit 1
        fi;
}

remove_vhost()
{
        if [ -f vhost_unknown* ]
        then
                rm vhost_unknown*
        fi
}

add_tile(){
        xdata=$1
        ydata=$2
        status=$3
        version=$4
        echo $TILE | sed "s/xdata/$xdata/g" | sed "s/ydata/$ydata/g" | sed "s/status/$status/g" |  sed "s/version/$version/g" >>$OUT
}


status_puller(){
ydata=5
xdata=$1
for line in $COMPURL
        do
        val=$(wget -S --timeout=1 --waitretry=1 --tries=3 --retry-connrefused "http://$line/version.html" 2>&1 | grep "HTTP/" | awk '{print $2}')
        if [[ $val == 200 ]]; then
                version_no=$(grep 'Version :' version.html|awk  '{print $3}'|awk -F '<' '{print $2}'|awk -F '>' '{print $2}')
		#echo "$line, $version_no">>$LOGFILE
                if ! [[ $version_no =~ $ver_re ]] ; then
                        add_tile $xdata $ydata "pass" "VERSION ISSUE"
                else
                        add_tile $xdata $ydata "pass" $version_no
                fi
                rm -rf version.html*
         else
		echo "$line, Error">>$LOGFILE
                add_tile $xdata $ydata "fail" "ERROR"
                rm -rf version.html*
        fi
        ydata=$((ydata+30))
done
}

post_executor(){
  xdata=$1
  echo $((xdata+30))>$XDATAFILE
  remove_vhost
}

env_check(){
if [ -f ${OUT} ]
then
	index_end
	mv $OUT DATE.html
 fi
}

microexecutor(){
	xdata=$1
	read_config
	status_puller $xdata
	post_executor $xdata
}


getxdata(){
	CSTTIME=`TZ=":US/Central" date +%Y-%m-%d-%H:%M`
	REGEXTZ="^([^-]+)-(.*)-(.*)-(.*):(.*)$"
	INITIALPIXELVALUE=60
	[[ $CSTTIME =~ $REGEXTZ ]] && currhr="${BASH_REMATCH[4]}" && currmin="${BASH_REMATCH[5]}"	
	currhr=$((currhr*INITIALPIXELVALUE))
	xdata=$((STARTXDATA+currhr))
	if [ "$currmin" -ge 30 ]
	then
		xdata=$((xdata+30))
	fi
}

executor(){
    getxdata
    if [[ "$xdata" -ge 350 && "$xdata" -le 1760 ]]
    then
	microexecutor $xdata
    else
	exit 1
    fi
}

main(){
  if [ -f ${OUT} ]
  then
    executor
  else
    exit 1
  fi
}
main
