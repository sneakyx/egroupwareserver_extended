# 1. Info

Works now with mysql 8.0


## 1.1 General Info

This dockerfile builds an eGroupware container and inserts my apps. It is based on my egroupware docker image.
You'll also need a MySQL or MariaDB container for the database.

## 1.2 EGroupware
### General
EGroupware is a very powerful open source groupware programm. It consists of a calendar app, contacts, infolog, project manager, ticket system and more.
If you need more information on egroupware, just take a look here: [www.egroupware.org](http://www.egroupware.org)
Although this is a unofficial dockerfile, it uses just the official sources! 


## 1.3 my installed apps
### ROSInE (Rothaar Systems Open Source Incoive for EGroupware) always the newest version!

This is an application just to write invoices, orders, offers and delivery notes. It uses the egroupware addressbook.
It can now use a basic 	multi-client capability - every user can have an own company!
It can easily configurated to assist You with your work. It is easy to use and works with HTML5 and CSS3. If You need special templates and PHP files, feel free to contact me.

### my other apps
...will be added some days later.

# 2. Installation / Configuration
## a) helpful script 
For starting, stopping and updating my egroupware containers, I use my script container_control.sh, which You can download from 
[github](https://github.com/sneakyx/egroupwareserver_extended/blob/master/assets/container_control.sh)

## or b) without script
I don't recommend that, but if You want to do this on own own, you have to write the following lines to get this egroupware container to running:

    Variables for this script:
    
    $2= where to put all egroupware container data
    $3= mysql root database password
    $4= mysql egroupware password
    $5= which port external

Script: (run this script aus sudo!)

        # creating folders
		mkdir -p /home/egroupware/$2/mysql /home/egroupware/$2/data/default/backup /home/egroupware/$2/data/default/files
		touch /home/egroupware/$2/data/header.inc.php
        chown -R www-data:www-data /home/egroupware/$2/data
        chmod 0700 /home/egroupware/$2/data/header.inc.php
        # mysql config for egroupware, problems with new mysql 8.0
        if [ ! -f "/home/egroupware/$2/mysql.cnf" ]; then
            touch /home/egroupware/$2/mysql.cnf
            echo -e "[mysqld]\ndefault_authentication_plugin= mysql_native_password" > /home/egroupware/$2/mysql.cnf
        fi


		# create and run mysql container

		docker run -d --name mysql-egroupware-$2 \
			-e MYSQL_ROOT_PASSWORD=$3 \
			-e MYSQL_DATABASE=egroupware \
			-e MYSQL_USER=egroupware \
			-e MYSQL_PASSWORD=$4 \
			-v /home/egroupware/$2/mysql:/var/lib/mysql \
			-v /home/egroupware/$2/mysql.cnf:/etc/mysql/conf.d/egroupware.cnf \
			mysql
		
		# create and run egroupware container
		
		docker run -d \
			--name egroupware-$2 \
			-p $5:80 \
			-v /home/egroupware/$2/data:/var/lib/egroupware \
			--link mysql-egroupware-$2:mysql \
			-e SUBFOLDER=$6 \
			sneaky/egroupware-extended
		echo container was created/ updated 

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
 
If You updated to a new version of egroupware, don't forget to start the setup and update the database! 

	http://ipOfYourServer:4321/egroupware/setup 

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

	

[![](https://images.microbadger.com/badges/image/sneaky/egroupware-extended.svg)](http://microbadger.com/images/sneaky/egroupware-extended "Get your own image badge on microbadger.com")