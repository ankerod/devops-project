# DevOps Project

In this project I will use base stack for DevOps Engineer. <br>

I use technologies such as:
1. Git
2. Docker

I will gradually describe all steps wich I will do.

## 📄 Feature 1. Creation a simple front-end page
I will not create my own page. Instead this, I will take ReactJS app from open-source [GitHub repository](https://github.com/issaafalkattan/React-Landing-Page-Template.git)

### Step 1. Clone repository
`git clone https://github.com/issaafalkattan/React-Landing-Page-Template.git react-web-page`

---

### Step 2. Delete all git/github files
`cd react-web-page` <br>

`rm -rf .git .github`

## 🛠️ Feature 2. Configure Nginx
In order to web server with ReactJS works correctly, you need configure nginx.conf file, which locate in root ReactJS directory

#### nginx.conf

``` conf
working_processes 1;

events {
    worker_connection 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;

    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;

            index index.html index.htm;

            try_files $uri $uri/ /index.html;
        }
    }
}
```
## 🐳 Feature 3. Configure Dockerfile and deploy it

If you want to easy deploy your app on server, you must be use containerization, for example Docker

### Step 1. Downoload Docker desktop
First, you must downoload [Docker desktop](https://www.docker.com/products/docker-desktop/) on your computer. After downoloading you will have Docker and Docker Engine on your computer for easy work.

---

### Step 2. Create and configure Dockerfile
You must create Dockerfile in root directory of your app

#### Dockerfile

``` Dockerfile
FROM node:24-bullseye-slim as builder

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build

FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

COPY nginx.conf /etc.nginx/conf.d/default.conf

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]
```

---

### Step 3. Build Docker image

`docker build -t react-js-app .`

You can also check your images:
`docker images` or `docker image list`

---

### Step 4. Run Docker container

`docker run -d -p 80:80 --name react-js-app react-js-app`

You can also check your conatainers:
`docker ps` for working container or `docker ps -a` for all containers

After the steps above, your container must run on `localhost:80`