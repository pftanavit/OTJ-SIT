## Session 2.2: Copy Files Into An Image

**Goal:**
- Create a local text file, copy it into an Ubuntu-based image, and make the container print the file content when it runs.

**Constraints**
- Base image must be ubuntu.
- Use COPY.
- The file must be inside /app.

**Expected result**
- Running the image prints the copied file.
- The learner can identify where the file lives inside the image.

## Example

1. Create a local `note.txt` file.

```
"Hello World"
```
2. Inside the same folder, create a `Dockerfile`.
```
FROM ubuntu

COPY note.txt /app/note.txt

CMD ["cat", "/app/note.txt"]
```
3. Build the Image.
```
docker build -t file-print .
```
4. Start a new container from the image:
```
docker run file-print
```
- Output:
    ```
    "Hello World"% 
    ```
5. Check where the file lives:
```
docker run -it file-print bash
cd app
ls
cat note.txt
exit
```
- Output:
    ```
    note.txt
    "Hello World"
    ```
`note.txt` is now inside the container's `/app` folder. It is now completely independent from the `note.txt` that we created on our computer.