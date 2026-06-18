# Session 1: Enter A Base OS Container

### Goal: 
Start an Ubuntu container, enter its shell, find where you are, list files, create a file, read it, and exit.

### Constraints:

- Use only the ubuntu image.  
- Do not use a Dockerfile yet.  
- Do not install anything.  
- Show the commands you used.


### Expected result:

- can start a container.  
- can move around the Linux filesystem.  
- can create and read a file inside the container.

![][image1]  
![][image2]  
![][image3]

## Commands:

- **docker run \-it ubuntu:** docker run tells Docker to create a new container using ubuntu that is specified.   
  - **(-i)** Interactive. Forces the container standard input channel (STDIN) to stay open.   
  - **(-t)** TTY or Teletypewriter. Give a visual terminal screen and format the text.  
  - Without both, it will not run properly.  
- **pwd:** Print Working Directory. Shows the current directory of the user.  
- **ls:** List**.** Shows all the files inside the current directories.   
- **echo:** Print command. Takes user input and prints back.   
- **\>:** Redirect/ Overwrite. Redirect the echo command and put it in the file. If the file does not exist, it will create a new file. If the file already exists, it will overwrite the entire file.  
- **\>\>:** Append. Add the new text at the bottom of the new file.  
- **cat:** Concatenate. Read file command. Open and show all the texts inside a text file.  
- **cd:** Change Directory. Used to move around different folders.  
- **exit:** Closes terminal connection to the shell, shutting down the container.


[image1]: https://github.com/user-attachments/assets/9a7a53fe-51f0-4dab-b1a9-c660a1a12d32
[image2]: https://github.com/user-attachments/assets/cb6f29f1-4be4-4121-ace0-cadcd1ba1abc
[image3]: https://github.com/user-attachments/assets/2f7d1a92-b351-4627-85a0-0a55c75c7ccc
