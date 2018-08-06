# app-mon
Appmon is single page web-app to monitor the health of every Tomcat applications in your organization

## How does it work?
`main.sh` script will accept `url_file` that contains list of all tomcat virtual URLs that hits `version.html` (like http://server:8080/application/version.html). Dashboard is plotted based on response (If the response is 200 OK -> green tile; if not red tile)

##  Dashboard
Output of the script will look like below :

<p align="center">
    <a href="#">
        <img src="https://raw.githubusercontent.com/iamshreeram/app-mon/master/images/AppStatus.png" />
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

## Notes 
* Dashboard is based on response of `version.html`
* Script needs a HTTP server to run
* To make it simple and light weight, Addition of external libraries are avoided 
 
## Enhancements
* ~~Position of version is hard coded and script doesn't have any intelligence. Need to make it as regex~~
* Need to make the `add_tile` function as asynchronous recursion. Currently, `sleep` is using lot of CPU
* Enable to run sub-processes which can monitor the health of direct URLs
	1. Create .conf file which contains list of components to be created 
	2. For each component in list, create a file with same name and add list of all direct URLs
	3. Script will create a new folder with component name and move the direct url file to created folder
	4. Copy of Script will be posted in folder and self started
	5. Script would read the urls from file and create the status tile based on direct urls
* `xdata` in the script is not dependent on time. Make it a dependent variable. So that each `tile` will get created based on time of validation
* Add Date picker, Search bar to look at specific application on specific date
* Enable Javascript to display version of application in tooltip on mouse over of tile
* Create and append a Logo on left top of dashboard 