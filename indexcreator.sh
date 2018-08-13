
#!/bin/bash
#set -x
CURRHOME=`pwd`
STATFILE=`echo $CURRHOME/StatusOutput`
OUT=`echo $CURRHOME/today.html`
CONFIG=`echo $CURRHOME/config/app.conf`
INST_URLS=`echo $CURRHOME/config/instanceurl_file`
INST_NAMES=`echo $CURRHOME/config/instance_names`
XDATAFILE=`echo $CURRHOME/xdata.pid`

avgspacefortile=32
height=`expr \`cat config/app.conf | wc -l\` \* $avgspacefortile`

FRAME='<!DOCTYPE html><html lang="en"><head><title>App Mon</title><link rel="icon" type="image/x-icon" href="favicon.ico" /><meta http-equiv="content-type" content="text/html; charset=UTF-8"></meta><meta http-equiv="refresh" content="30"></meta></head><style>body{background-color:black}h1{Color:white}.pass{fill:green}.fail{fill:red}.warn{fill:orange}.status{fill:gray}svg{font-size:14px;fill:#fff;background-color:black;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol"}text.month-90deg{transform:rotate(90deg)}</style><body><div><div>'
SIZEDEF="<svg width=\"1900\" height=\"$height\">"
HEADER=`echo $FRAME $SIZEDEF`
FOOTER='</svg></div></div></div></body></html>'
GTRANSFORM='<g transform="translate(0, 40)">'
CLOSEG='</g>'
TILE='<rect class=status width=20 height=20 x=xdata y=ydata v=version />'
CLOCK='<text x=xtimloc y=ytimloc>hour:00</text>'
COMP='<text dx=xaxis dy=yaxis>comp</text>'
ver_re='^[0-9]+([.][0-9]+)?$'
CURRDATE=`date -d "-1 days" +%Y%m%d`

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
		echo "<h1>Can't monitor the application. Config file is missing or corrupted.</h1>">>$OUT
		exit 1
	fi;
}

xdatafile_checker(){
if [ -f ${XDATAFILE} ]
then
        rm $XDATAFILE
fi
}

statfile_checker(){
if [ -f ${STATFILE} ]
	then
		rm $STATFILE
	fi
}

remove_vhost()
{
	if [ -f vhost_unknown* ]
	then
		rm vhost_unknown*
	fi
}

indexfile_checker(){
	if [ -f ${OUT} ]
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
	apps=`echo $COMPHEADER`
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

index_end(){
   echo $CLOSEG>>$OUT
   echo $FOOTER>>$OUT
}

env_check(){
if [ -f ${OUT} ]
  then
	index_end
	mv $OUT $CURRDATE.html
	xdatafile_checker
  fi
}

main(){
	env_check
	statfile_checker
	indexfile_checker
	index_start
	read_config
	get_compnt_list
	index_addcomp
}
main