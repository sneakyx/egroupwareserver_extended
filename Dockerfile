FROM sneaky/egroupware:latest
MAINTAINER André Scholz <info@rothaarsystems.de>
# V 2017-01-16-18-55

# load newest version of apps
RUN apt-get update \
	&& apt-get install unzip \
	&& wget -P /usr/share http://downloads.sourceforge.net/project/rosin/current/rosine-2017-01-16.zip \
	&& mv /usr/share/rosine*.zip /usr/share/egroupware/rosine.zip \
	&& unzip /usr/share/egroupware/rosine.zip -d /usr/share/egroupware/ \
	&& mv /usr/share/egroupware/ROSInE /usr/share/egroupware/rosine \
	&& rm /usr/share/egroupware/rosine.zip \
	&& chmod -R +r+x /usr/share/egroupware/rosine  
	
# overwrite standard html from Egroupware because my apps use HTML5 and chmod all changed egroupware files
RUN		sed -i -e 1c"<!-- BEGIN head --><!DOCTYPE html>" /usr/share/egroupware/pixelegg/head.tpl \
	&& 	sed -i -e 2c"<html>" /usr/share/egroupware/pixelegg/head.tpl 
# overwrite docker-entrypoint.sh
COPY assets/docker-entrypoint.sh /bin/entrypoint.sh 
RUN chmod +x /bin/entrypoint.sh 

EXPOSE 80 443

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["app:start"] 