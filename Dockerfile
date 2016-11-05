FROM resin/rpi-raspbian:latest

EXPOSE 80

VOLUME ["/config"]

RUN apt-get update && \
apt-get upgrade; \

RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list; \
echo "Package: * \nPin: origin http.debian.net \nPin-Priority: 1001\n"\ > /etc/apt/preferences.d/zoneminder; \
gpg --keyserver pgpkeys.mit.edu --recv-key  8B48AD6246925553; \
gpg -a --export 8B48AD6246925553 | sudo apt-key add -; \
gpg --keyserver pgpkeys.mit.edu --recv-key  7638D0442B90D010; \
gpg -a --export 7638D0442B90D010 | apt-key add -; \
cat /etc/apt/preferences.d/zoneminder; \
apt-get update && \
apt-get install -y php5 mysql-server php-pear php5-mysql; \
apt-get install -y zoneminder; \
apt-get install -y libvlc-dev libvlccore-dev vlc;

RUN service mysql restart && \ 
service apache2 restart && \
mysql -uroot < /usr/share/zoneminder/db/zm_create.sql && \
mysql -uroot -e "grant all on zm.* to 'zmuser'@localhost identified by 'zmpass';" && \
chmod 740 /etc/zm/zm.conf && \
chown root:www-data /etc/zm/zm.conf;

RUN sudo ln -s /etc/zm/apache.conf /etc/apache2/conf-available/zoneminder.conf && \
a2enconf zoneminder && \
a2enmod rewrite && \
a2enmod cgi;

RUN chown -R www-data:www-data /usr/share/zoneminder/ && \
sed  -i 's/\;date.timezone =/date.timezone = \"Europe\/Berlin\"/' /etc/php5/apache2/php.ini && \
service apache2 restart && \
service mysql restart && \
rm -r /etc/init.d/zoneminder && \
mkdir -p /etc/my_init.d;

COPY zoneminder /etc/init.d/zoneminder
COPY firstrun.sh /etc/my_init.d/firstrun.sh
COPY cambozola.jar /usr/share/zoneminder/www/cambozola.jar

RUN chmod +x /etc/init.d/zoneminder && \
chmod +x /etc/my_init.d/firstrun.sh && \
adduser www-data video && \
service apache2 restart && \
update-rc.d -f apache2 remove && \
update-rc.d -f mysql remove && \
update-rc.d -f zoneminder remove;

### raspbian image does not provid init.d or systemctl therefore we need something else

RUN apt-get install -y supervisor

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]