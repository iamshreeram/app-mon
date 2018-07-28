# app-mon
Appmon is single page web-app to monitor the health of every Tomcat applications in your organization

## How does it work?
`main.sh` script will accept `url_file` that contains list of all tomcat virtual URLs that hits `version.html` (like http://server:8080/application/version.html). Dashboard is plotted based on response (If the response is 200 OK -> green tile; if not red tile)

##  Dashboard
Output of the script will look like below :

<p align="center">
    <a href="#">
        <img src="https://cdn.rawgit.com/iamshreeram/app-mon/master/AppStatus.png" />
    </a>
    <br>
</p>

## How to use

* Clone this repo 
```
git clone https://github.com/iamshreeram/app-mon.git
cd app-mon
touch url_file

```
* Add the `url_file` that contains list of all tomcat `version.html` URLs 
* Run the script `main.sh`


## Languages
> * Shell
> * HTML, CSS, Javascript 
 
