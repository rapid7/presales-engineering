#!/usr/bin/python
import subprocess
import os
import socket
ip = socket.gethostbyname(socket.gethostname())
user = os.getenv("SUDO_USER")
URL = ""
if user is None:
    print ("Please rerun using 'sudo' permissions")
    exit()
else:
   print ("sudo check passed")
   subprocess.call("clear", shell=True)

def print_graphic():
    print ("""
    _               ____              _          _       ____        _ _     _
   / \   _ __  _ __/ ___|  ___  ___  | |    __ _| |__   | __ ) _   _(_) | __| | ___ _ __
  / _ \ | '_ \| '_ \___ \ / _ \/ __| | |   / _` | '_ \  |  _ \| | | | | |/ _` |/ _ \ '__|
 / ___ \| |_) | |_) |__) |  __/ (__  | |__| (_| | |_) | | |_) | |_| | | | (_| |  __/ |
/_/   \_\ .__/| .__/____/ \___|\___| |_____\__,_|_.__/  |____/ \__,_|_|_|\__,_|\___|_|
        |_|   |_|

                                                      .      //
                                                 /) \ |\    //
                                           (\\|  || \)u|   |F     /)
                                            \```.FF  \  \  |J   .'/
                                         __  `.  `|   \  `-'J .'.'
                  ______           __.--'  `-. \_ J    >.   `'.'   .
               _.-'      ""`-------'           `-.`.`. / )>.  /.' .<'
            .'                                   `-._>--' )\ `--''
            F .                                          ('.--'"
           (_/                                            '\  
            \                                             'o`.
            |\                                                `.
            J \          |              /      |                \  
             L \                       J       (             .  |
             J  \      .               F        _.--'`._  /`. \_)
              F  `.    |                       /        ""   "'
              F   /\   |_          ___|   `-_.'
             /   /  F  J `--.___.-'   F  - /
            /    F  |   L            J    /|
           ( _   F  |   L            F  .'||
            L  F    |   |           |  /J  |
            | J     `.  |           | J  | |              ____.---.__
            |_|______ \  L          | F__|_|___.---------'
          --'        `-`--`--.___.-'-'---
""")

def print_URLs():
    print (URL)

def print_menu():
    print ("""    


                    +-------------------------------------+-------------------------------------+
                    |                            Portable Lab Install                           |
                    +-------------------------------------+-------------------------------------+
                    | 1. Deploy/Update Docker Environment | 6. Install DVWA                     |
                    +-------------------------------------+-------------------------------------+
                    | 2. Install Gruyere                  | 7. Install Rails Goat **in Dev**    |
                    +-------------------------------------+-------------------------------------+
                    | 3. Install JuiceShop                | 8. Install Pet Clinic               |
                    +-------------------------------------+-------------------------------------+
                    | 4. Install WebGoat                  | 9. Install Hackazon                 |
                    +-------------------------------------+-------------------------------------+
                    | 5. Install WebWolf                  | 10. Install All Web Apps            |
                    +-------------------------------------+-------------------------------------+
                    |                                  11. Exit                                 |
                    +-------------------------------------+-------------------------------------+

""")



def print_completed():
    print ("""
Installation Completed

Returning to Main Menu
        """)

loop=True      
  
while loop:          ## While loop which will keep going until loop = False
    print_graphic()  ## Displays Graphic
    print_URLs()     ## Displays URL(s) for installed applications
    print_menu()    ## Displays menu
    choice = input("Enter your choice [1-11]: ")
    choice = int(choice)
     
    if choice==1:     
        print ("Deploying environment")
        #subprocess.call("sudo apt -qq -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common", shell=True)
        #print ("installed docker dependencies") #remove comment to validate setp for debuging
        #subprocess.call("curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -", shell=True)
        #print ("added package repo for docker") #remove comment to validate step for debugging
        #subprocess.call("sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"", shell=True)
        #print ("downloaded docker repo") #remove comment to validate step for debugging
        #subprocess.call("sudo apt -qq -y update", shell=True)
        #print ("updated and incorporated docker repo") #remove comment to validate step for debugging
        #subprocess.call("sudo apt -qq -y install docker-ce", shell=True)
        #print ("Installed docker-ce and all dependencies") #remove comment to validate step for debugging
        #subprocess.call("curl -L \"https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose", shell=True)
        #print ("Downloaded docker-compose") #remove comment to validate step for debugging
        #subprocess.call("sudo usermod -a -G docker $USER", shell=True)
        #print ("modified user account to allow docker to be run by user") #remove comment to validate step for debugging
        #subprocess.call("sudo chmod +x /usr/local/bin/docker-compose", shell=True)
        #print ("chmod completed to allow docker-compose to be run by user") #remove comment to validate step for debugging
        from os import path
        
        filename = "docker-compose.yml"
        if not path.exists(filename):
            with open(filename, 'w') as f:
              s = """version: '2.1'
        
services:
  webgoat:
    image: webgoat/webgoat-8.0
    environment:
      - WEBWOLF_HOST=webwolf
      - WEBWOLF_PORT=9090
    ports:
      - "8080:8080"                                                                                       
      - "9001:9001"
    volumes:
      - .:/home/webgoat/.webgoat
  webwolf:
    image: webgoat/webwolf
    ports:
      - "9090:9090"
    command: --spring.datasource.url=jdbc:hsqldb:hsql://webgoat:9001/webgoat --server.address=0.0.0.0
  gruyere:
    image: karthequian/gruyere
    ports:
      - "8008:8008"
  juiceshop:
    image: bkimminich/juice-shop
    ports:
      - "3000:3000"
    stdin_open: true
    tty: true
  dvwa:
    image: citizenstig/dvwa
    ports:
      - "8081:80"
      - "3306:3306"
    environment:
      - MYSQL_DATABASE=dvwa
      - MYSQL_USER=admin
      - MYSQL_PASSWORD=p@ssw0rd
      - MYSQL_ROOT_PASSWORD=
  railsgoat:
    image: owasp/railsgoat
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/myapp
    ports:
      - "4000:3000"
  petclinic:
    image: arey/springboot-petclinic
    ports:
    - "4001:8080"
    stdin_open: true
    tty: true
  hackazon:
    image: pierrickv/hackazon
    ports:
    - "4002:80"
    stdin_open: true
    tty: true"""
              f.write(s)
        print ("docker-compose.yml file successfully created") #remove comment to validate step for depugging
        print_completed()
        subprocess.call("clear", shell=True)
    elif choice==2:
        print ("Installing Gruyere")
        subprocess.call("docker-compose up -d gruyere", shell=True)
        print_completed()
        subprocess.call("clear", shell=True)
        URL = ("Gruyere URL: http://"+ip+":8008")
    elif choice==3:
        print ("Installing JuiceShop")
        subprocess.call("docker-compose up -d juiceshop", shell=True)
        print_completed()
        URL = ("JuiceShop URL: http://"+ip+":3000")
        subprocess.call("clear", shell=True)
    elif choice==4:
        print ("Installing WebGoat")
        subprocess.call("docker-compose up -d  webgoat", shell=True)
        print_completed()
        URL = ("WebGoat URL: http://"+ip+":8080/WebGoat/login")
        subprocess.call("clear", shell=True)
    elif choice==5:
        print ("Installing WebWolf")
        subprocess.call("docker-compose up -d  webwolf", shell=True)
        print_completed()
        URL = ("WebWolf URL: http://"+ip+":9090/login")
        subprocess.call("clear", shell=True) 
    elif choice==6:
        print ("Installing DVWA")
        subprocess.call("docker-compose up -d dvwa", shell=True)
        print_completed()
        URL = ("DVWA URL: http://"+ip+":8081")
    elif choice==7:
        print ("Installing Railsgoat *in testing")
        subprocess.call("docker-compose up -d railsgoat", shell=True)
        print_completed()
        URL = ("Railsgoat URL: http://"+ip+":4000")
    elif choice==8:
        print ("Installing Pet Clinic")
        subprocess.call("docker-compose up -d petclinic", shell=True)
        print_completed()
        URL = ("Pet Clinic URL: http://"+ip+":4001")
    elif choice==9:
        print ("Installing Hackazon")
        subprocess.call("docker-compose up -d hackazon", shell=True)
        print_completed()
        URL = ("Hackazon URL: http://"+ip+":4002")
    elif choice==10:
        print ("Installing All Web Apps")
        subprocess.call("docker-compose up -d", shell=True)
        print_completed()
        subprocess.call("clear", shell=True)
        URL = (
            "Gruyere URL: http://"+ip+":8008\n"
            "JuiceShop URL: http://"+ip+":3000\n"
            "WebGoat URL: http://"+ip+":8080/WebGoat/login\n"
            "WebWolf URL: http://"+ip+":9090/login\n"
            "DVWA URL: http://"+ip+":8081\n"
            "Railsgoat URL: http:"+ip+":4000\n"
            "Pet Clinic URL: http://"+ip+":4001\n"
            "Hackazon URL: http://"+ip+":4002\n"
            )
    elif choice==11:
        print ("Exiting Lab Builder")
        ## You can add your code or functions here
        loop=False # This will make the while loop to end as not value of loop is set to False
    else:
        # Any integer inputs other than values 1-11 we print an error message
        raw_input("Wrong option selection. Enter any key to try again..")
