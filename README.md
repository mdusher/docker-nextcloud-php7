# NextCloud

NextCloud docker image running on apache using PHP 7.0.8, redis and memcached.

###Build
```
git clone https://github.com/mdusher/docker-nextcloud-php7.git
cd docker-nextcloud-php7
docker build -t docker-nextcloud-php7 .
docker run -d -p 80:80 -v /path/to/persistent/data/folder:/var/www/html docker-nextcloud-php7
```

