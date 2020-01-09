Nginx for PHP
=============

Docker web-server image to serve static files and redirect router PHP file to PHP-FPM.

Env vars
--------

* public dir is `/code/public`. If not change `APP_WORKDIR`
* any domain is ok. If not chage `APP_DOMAIN`
* app file is `index.php`. If not change `PHP_APP_FILE`
* php-fpm at `fpm:9000`. If not change `PHP_HOST` and `PHP_PORT`
* traffic is proxied via CloudFlare or other nginx, real IP is in header "X-Real-IP" (nginx - "http_x_real_ip"). If not change `REMOTE_ADDR_PARAM` - for direct connection set "remote_addr"
* timeouts: send "300", php "600". If not change `SEND_TIMEOUT` and `PHP_TIMEOUT`.
* you want logs in `/var/log/nginx/`. If not change `LOG` (2 - access and error, 1 - only error, 0 - no logs)
* prod environment. If not change `APP_ENV`
* if prod env then people come via https (via other nginx with certificates or directly). To override change `HTTPS`
* if https then you have local certificates. To override change `SSL`
* show nginx config before nginx start. To hide set `VERBOSE="0"`

Additional files
----------------

Files you can mount:

* `/opt/nginx/fix.sh`: if exists it will be executed after config before nginx start. Good place for replacements
  `sed -i 's/incorrect/correct/' /etc/nginx/nginx.conf`
* `/opt/nginx/locations.conf`: if exists it is appended to server locations

Build
-----

    make build

Usage
-----

docker:

    docker run --rm -it --name nginx -p 80:80 -v /path/to/your/app/:/code/ gupalo/nginx

docker-compose.yaml:

    nginx:
        image: 'gupalo/nginx'
        ports: ['0.0.0.0:80:80']
        depends_on: ['fpm']
        volumes_from: ['fpm:ro']
        #env_file: ['./env.conf']
        restart: 'always'
        networks: ['default']
