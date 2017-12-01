# 1. Info
## 1.1 General Info

This dockerfile builds an eGroupware container and inserts my apps. It is based on my egroupware docker image.
You'll also need a MySQL or MariaDB container for the database.

## 1.2 Egroupware
### General
Egroupware is a very powerful open source groupware programm. It consists of a calendar app, contacts, infolog, project manager, ticket system and more.
If you need more information on egroupware, just take a look here: [www.egroupware.org](http://www.egroupware.org)
Although this is a unofficial dockerfile, it uses just the official sources! 


## 1.3 my installed apps
### ROSInE (Rothaar Systems Open Source Incoive for Egroupware) always the newest version!

This is an application just to write invoices, orders, offers and delivery notes. It uses the egroupware addressbook.
It can easily configurated to assist You with your work. It is easy to use and works with HTML5 and CSS3. If You need special templates and PHP files, feel free to contact me.

### my other apps
...will be added some days later.

# 2. Installation / Configuration
## a) helpful script 
For starting, stopping and updating my egroupware containers, I use my script container_control.sh, which You can download from 
[github](https://github.com/sneakyx/egroupwareserver_extended/blob/master/assets/container_control_develop.sh)

## or b) without script

### b) 1. Data directories (storage)
First, it would be wise to create directories for storing everything in place. I usually pack everything into subfolders under the same superior directory. This way it's easier to create a backup using rsync. (Remember to stop the database before creating a backup!)
I suggest the following directory hierarchy:

/home/egroupware/xxx/mysql  	-> Database
/home/egroupware/xxx/data  	-> Egroupware Files, backups, header.inc and templates for rosine

	mkdir -p /home/egroupware/xxx/mysql /home/egroupware/xxx/data
-> Please replace xxx with Your favourite name! <-

### b) 2. start mysql container

	docker run -d --name mysql-egroupware-xxx \
	-e MYSQL_ROOT_PASSWORD=123456 \
	-e MYSQL_DATABASE=egroupware \
	-e MYSQL_USER=egroupware \
	-e MYSQL_PASSWORD=123456 \
	-v /home/egroupware/xxx/mysql:/var/lib/mysql mysql
	
-> Please replace xxx with Your favourite name and 123456 with Your password! <-

### b) 3. start egroupware container
To start the egroupware container, just use:

	docker run -d \
	--name egroupware-xxx \
	-p 4321:80 \
	-v /home/egroupware/xxx/data:/var/lib/egroupware \
	-e SUBFOLDER=/egroupware \
	--link mysql-egroupware-xxx:mysql \
	sneaky/egroupware-extended	

-> Please replace xxx with Your favourite name and 4321 with the port projected for using.<-
-> The SUBFOLDER variable is optional, if You leave it, the login address is without subfolder!<-

# 3. Setup 
## 3.1 Egroupware
### a) First time logging in?
If You started the image for first time, You have to login via
	
	http://ipOfYourServer:4321/
or

	http://ifOfYourServer:4321/egroupware

depending on Your subfolder variable!

You don't have to add databse info during installation manually - I updated the files 
- class.setup_header.inc.php
- class.setup_process.inc.php
this way the installation is a bit more automated.
Now the installation imports also an existing database backup from egroupware!    
   
### or b) Logging in with existing database and data? 

If the file header.inc.php already exists (former installation), the docker-entrypoint.sh updates the database host ip and port in the header.inc.php automaticly!
 
If there's a new version of egroupware, You have to start the setup and update the database! (But egroupware will tell You this!) 

## 3.2 Setup Rosine
When You login to egroupware, you have to activate rosine for your the users. If you need assistance with that, don't hesitate to ask me.
After that, You just have to click on the rosine button on the left side. If it's the first time you started rosine or the data directory changes, the template folder is activated. After that, just click on "Click here"  and everything works! 

# 4. Additional info
Change all passwords from 123456 to Your own password! 

Remember to put the following informations external, otherwise all data will be lost after updating the image:
- folder for egroupware
- Mysql Database files
- template for rosine
(see above for example directory hierarchy!)

If You restart the docker container (former stoped with "docker stop xxx" and now start with "docker start xxx") don't forget to update the mysql-IP-adress by using

	docker exec -it xxx /bin/docker-entrypoint.sh update
	
# 5. Mount Your Samba Folders
Login to Your docker container with

	docker exec -it egroupware-xxx /bin/bash
then create Your mount points with

	filemanager/cli.php mount --user root_admin --password 123456 'smb://Workgroup\$user:$pass@adressOfServer/path' '/whereToMountInFilemanager'

	


If you have any suggestions, questions or You need a special egroupware application, just contact me via: info@rothaarsystems.de

[![](https://images.microbadger.com/badges/image/sneaky/egroupware-extended.svg)](http://microbadger.com/images/sneaky/egroupware-extended "Get your own image badge on microbadger.com")