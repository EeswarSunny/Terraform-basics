Resources Links
1. https://docs.docker.com/engine/containers/resource_constraints/
2. https://youtu.be/CnqjHRCZEt0?si=0ZlNebA77uHpnZgV

docker run ubuntu:25.10 to check
1. [https://udlabs.kodekloud.com/courses/udemy-labs-docker-for-the-absolute-beginner/](https://udlabs.kodekloud.com/courses/udemy-labs-docker-for-the-absolute-beginner/)
2. https://udlabs.kodekloud.com/topic/labs-docker-run-commands-5/
3. https://udlabs.kodekloud.com/topic/labs-docker-images-5/
4. https://udlabs.kodekloud.com/topic/labs-environment-variables-5/ 
5. https://udlabs.kodekloud.com/topic/labs-command-entrypoint-3/ ‎
10.  
11. 
12.  
13. 
14. 
15. 
16. 
 
6. https://udlabs.kodekloud.com/topic/labs-volumes-5/ 
7. https://udlabs.kodekloud.com/topic/labs-networks-5/ 
8. https://udlabs.kodekloud.com/topic/labs-docker-compose-5/ 
9. https://udlabs.kodekloud.com/topic/labs-docker-compose-5/ 



### Sections 1
1. diff services require different os config thats why we use docker
2. containers vs virtual machines 
	1. each vm uses single os
	2. all docker uses single os
	3. we can use vm to deploy different docker os  under on ehardware
	4. 
3. container vs image
4. image is like a package  , container is a running application 


### Basic docker commnads 
6. docker run -d --name <container_name> <image_name> 
6. docker run -it -d --name <container_name> <image_name> desc: run a container in interactive mode
7. docker run -d --name <container_name> <image_name> sleep 1d
7. docker ps -a desc: list all containers
8. docker stop <container_name> desc: stop a container
9. docker images desc: list all images
10. docker rmi <image_name> desc: remove an image
11. docker start <container_name> desc: start a container
12. docker restart <container_name> desc: restart a container
13. docker rm <container_name> desc: remove a container
14. docker rmi <image_name> desc: remove an image
15. docker exec -it <container_name> /bin/bash desc: execute a command in a container
16. docker logs <container_name> desc: show logs of a container
17. docker inspect <container_name> desc: show details of a container
18. docker top <container_name> desc: show running processes in a container
19. docker stats <container_name> desc: show stats of a container
20. docker commit <container_name> <image_name> desc: commit a container to an image
21. docker save <image_name> -o <image_name>.tar desc: save an image to a tar file
22. docker load -i <image_name>.tar desc: load an image from a tar file
23. docker tag <image_name> <new_image_name> desc: tag an image
24. docker push <image_name> desc: push an image to a registry
25. docker pull <image_name> desc: pull an image from a registry
26. docker network create <network_name> desc: create a network
27. docker network connect <network_name> <container_name> desc: connect a container to a network
28. docker network disconnect <network_name> <container_name> desc: disconnect a container from a network
29. docker network rm <network_name> desc: remove a network
30. dokcer attach <container_name> desc: attach to a running container
31. docker port <container_name> desc: show port mapping
32. docker run -d --name <container_name> <image_name> sleep 1d desc: run a container in detached mode
33. docker exec -it <container_name> /bin/bash desc: execute a command in a container
34. dokcer run -v <host_path>:<container_path> <image_name> desc: run a container with a volume
35. dokcer run -p <host_port>:<container_port> <image_name> desc: run a container with a port mapping
36. dokcer run -p <host_port>:<container_port> -v <host_path>:<container_path> <image_name> desc: run a container with a port mapping and volume
37. docker inspect <container_name> desc: inspect a container   
38. dokcer run -e <env_name>=<env_value> <image_name> desc: run a container with environment variables


### Sections 2 docker commands

### Sections 3 docker run commands

### Sections 4 docker images 
FROM 
RUN 
COPY
ENTRYPOINT
CMD


docker build . -t <image_name> desc: build an image
docker push to ppublic registry 
docker pull from public registry
dokcer run image 

### Sections 5 docker compose 


### Sections 6 docker registry

### Sections 7 docker Engine , storage, Networking 

### Sections 8 docker on mac and windows

### Sections 9 container orchestration-  docker swarm and kubernetes



S