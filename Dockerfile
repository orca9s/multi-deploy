# docker build -t multi-deploy .
FROM        multi-deploy:base

COPY        .   /srv/backend
WORKDIR     /srv/backend
RUN         mv /srv/backend/front/*  /srv/front/

# supervisor.conf파일 복사
RUN         cp -f   /srv/backend/.config/supervisord.conf \
                    /etc/supervisor/conf.d/

# Nginx관련 설정파일 복사 및 링크
RUN         cp -f   /srv/backend/.config/nginx.conf \
                    /etc/nginx/nginx.conf
RUN         rm -rf  /etc/nginx/sites-enabled/*
RUN         cp -f   /srv/backend/.config/nginx_app.conf \
                    /etc/nginx/sites-available/
RUN         ln -sf  /etc/nginx/sites-available/nginx_app.conf \
                    /etc/nginx/sites-enabled/nginx_app.conf

# Front-end
WORKDIR     /srv/front
RUN         npm run build

# Nginx설치와 동시에 실행되던 nginx daemon종료 후
# supervisor를 사용해 Nginx, Django, Front를 실행
CMD         pkill nginx; supervisord -n