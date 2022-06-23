# path-to-packer
Runbook
======
This runbook will outline the steps required to configure an ubuntu instance on AWS with an NGINX application.

Creating Ubuntu Server in AWS
======
- Create a new instance by using the Amazon EC2 
- Under the AMI, select Ubuntu 20.04 LTS in the Quick Start section
- Make sure to create a Key pair
- Under Network Settings, find the Firewall section & click _“create security group”_
  - Check all three boxes to create rules for SSH, HTTPs & HTTP traffic

<img width="407" alt="Screen Shot 2022-06-23 at 9 20 33 AM" src="https://user-images.githubusercontent.com/105741288/175322005-dbaa0cc9-b633-49bf-8f01-34c6b1871c67.png">

- Use default settings for everything else and then click _“Launch instance”_
- Connect the Instance to the Ubuntu server by clicking on _“Connect”_ that is located in the Instance summary

Add a New User and Directory in Ubuntu
======
- Add a new user
  - From the Ubuntu user, move to the home directory and add a USERNAME
  - ```sudo adduser <USERNAME>```

- Add the new user to the _‘sudoers’_ directory 
  - This is needed in order to install nginx in our user directory
  - ```sudo adduser <USERNAME> sudo```

- Switch into the user
  - ```su - <USERNAME>```

- Create a directory in your user directory 
  - This is where we can create our app directory 
  - ```mkdir <DIRECTORY-NAME>```


Downloading and Configuring NGINX
  ======
- In the new user directory, download NGINX 
  - Run these commands. When complete, type in the command ```quit```
  ```
  sudo -s
  nginx=stable # use nginx=development for latest development version
  add-apt-repository ppa:nginx/$nginx
  apt update
  apt install nginx
  ```


- Verify the installation with ```nginx -v```
  - It’ll display the software version nginx version: ```nginx/1.18.0 (Ubuntu)```
  
Enable and start the NGINX landing page
  ======
- Start by checking the status where it will display _active (running)_
  - ```sudo systemctl status nginx```
- If NGINX is not running, run the following ```sudo systemctl start nginx```

- Load when the system starts
  - ```sudo systemctl enable nginx```

- Allow NGINX traffic and grant access to the firewall
  ```
   sudo ufw app list
   sudo ufw allow 'nginx full'
   sudo ufw reload
  ```


Deploying the NGINX Page
======
- Open a new web browser with the IP address from the Connect instance page
- It should look like this, where the localhost is the IP address

<img width="361" alt="nginx" src="https://user-images.githubusercontent.com/105741288/175322379-26347833-15a7-4f41-8941-3642523b4442.png">


Resources and References 
  =====
https://phoenixnap.com/kb/how-to-install-nginx-on-ubuntu-20-04

https://ubuntu.com/tutorials/install-and-configure-nginx#1-overview
