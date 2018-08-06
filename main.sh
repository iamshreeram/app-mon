#!/bin/bash
#set -x
STATFILE='StatusOutput'
OUT='index.html'
CONFIG='config/app.conf'
INST_URLS='config/instanceurl_file'
INST_NAMES='config/instance_names'

HEADER='<!DOCTYPE html><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=UTF-8"></meta></head><style>body{background-color:black}.pass{fill:green}.fail{fill:red}.warn{fill:orange}.status{fill:gray}svg{font-size:14px;fill:#fff;background-color:black;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol"}text.month-90deg{transform:rotate(90deg)}</style><body><br /><br /><br /><div><div><svg width="1900" height="1050" >'
FOOTER='</svg></div></div></div></body></html>'
GTRANSFORM='<g transform="translate(0, 40)">'
CLOSEG='</g>'
TILE='<rect class=status width=20 height=20 x=xdata y=ydata v=version />'
CLOCK='<text x=xtimloc y=ytimloc>hour:00</text>'
COMP='<text dx=xaxis dy=yaxis>comp</text>'
ver_re='^[0-9]+([.][0-9]+)?$'

read_config() {
	CONFIG=`cat $CONFIG`;
	if [[ `echo $CONFIG` == *,* ]];
	then
			COMPHEADER=`echo $CONFIG | sed 's/,[A-Za-z0-9.:-]*//g' | sed 's/\/[A-Za-z0-9-]*//g'`;
			COMPURL=`echo $CONFIG | sed 's/[A-Za-z0-9_-/]*,//g'`;
	elif [[ `echo $CONFIG` == */* ]];
	then
			COMPHEADER=`echo $CONFIG | sed 's/[A-Za-z0-9.:-]*\///g'`;
			COMPURL=`echo $CONFIG`;
	elif ! ([[ `echo $CONFIG` == *,* ]] || [[ `echo $CONFIG` == */* ]]);
	then
		COMPHEADER=`cat $INST_NAMES`
		COMPURL=`cat $INST_URLS`
	else
		echo "<h1>Can't monitor the application as the config file is missing or corrupted</h1>">>$OUT
		exit 1
	fi;
}


statfile_checker(){
if [[ ! -z ${STATFILE} ]];
	then
		rm $STATFILE
	fi
}

remove_vhost()
{
	if [[ ! -z vhost_unknown* ]];
	then
		rm vhost_unknown*
	fi
}

indexfile_checker(){
	if [[ ! -z ${OUT} ]];
	then
	  rm $OUT
	fi
}

index_start(){
	echo $HEADER>>$OUT
	echo $GTRANSFORM>>$OUT
}

get_compnt_list()
{
	# apps=`cat $COMPHEADERFILE`
	apps=`echo $COMPHEADER`
}


add_tile(){
	xdata=$1
	ydata=$2
	status=$3
	version=$4
	echo $TILE | sed "s/xdata/$xdata/g" | sed "s/ydata/$ydata/g" | sed "s/status/$status/g" |  sed "s/version/$version/g" >>$OUT
}

index_addcomp(){
  xaxis=15
  yaxis=20
  xdata=350
  ydata=5
  for app in $apps
    do
      echo $COMP | sed "s/comp/$app/g" | sed "s/xaxis/$xaxis/g" | sed "s/yaxis/$yaxis/g">>$OUT
      yaxis=$((yaxis+30))
    done

  xtimloc=360
  ytimloc=-10
  for hour in {00..23}
    do
       echo $CLOCK |  sed "s/hour/$hour/g" | sed "s/xtimloc/$xtimloc/g" | sed "s/ytimloc/$ytimloc/g">>$OUT
       xtimloc=$((xtimloc+60))
    done
}

index_addafterblack(){
  for xdata in {1800..1850..30}
    do
      echo "<rect width=20 height=20 fill="#000000" x=$xdata y=0 />">>$OUT
    done
}

status_puller(){
ydata=5
xdata=$1
for line in $COMPURL
	do
	val=$(wget  -S "http://$line/version.html" 2>&1 | grep "HTTP/" | awk '{print $2}')
	if [[ $val == 200 ]]; then
		version_no=$(grep Version version.html|awk  '{print $3}'|awk -F '<' '{print $2}'|awk -F '>' '{print $2}')
		if ! [[ $yournumber =~ $ver_re ]] ; then
			add_tile $xdata $ydata "pass" "NOTFOUND"
		else
			add_tile $xdata $ydata "pass" $version_no
		fi
			rm -rf version.html*
		else
			add_tile $xdata $ydata "fail" "ERROR"
			rm -rf version.html*
	fi
	ydata=$((ydata+30))
done
}



executor(){
  for xdata in {350..1760..30}
    do
        status_puller $xdata
        remove_vhost
        sleep 10s
  done
}

index_end(){
   echo $CLOSEG>>$OUT
   echo $FOOTER>>$OUT
}

main(){
	statfile_checker
	indexfile_checker
	index_start
	read_config
	get_compnt_list
	index_addcomp
	executor
	index_end
}
main
