# Session 1.3: Install Packages In A Container

### Goal:
Start an Ubuntu container, install curl, use it to make an HTTP request, then exit and explain whether the installed package is saved for future new containers.

### Constraints:
- Use only ubuntu.
- Install packages manually inside the running container.
- Do not use a Dockerfile yet.

### Expected results:
- The learner can install a package inside a container.
- The learner can explain why manual installation is not repeatable.

## Example:

Start a new container.
```
docker run -it ubuntu
```
Try to use `curl`
```
curl https://www.google.com
```
Output:
```
bash: curl: command not found
```
Install curl manually:
```
apt-get update
apt-get install -y curl
```
Try to use `curl` again:
```
curl -I https://www.google.com
```
Output:
```
HTTP/2 200 
content-type: text/html; charset=ISO-8859-1
content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-4ZuNA9E1guavWYxRflK8Rg' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
accept-ch: Sec-CH-Prefers-Color-Scheme
p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
date: Mon, 08 Jun 2026 07:55:51 GMT
server: gws
x-xss-protection: 0
x-frame-options: SAMEORIGIN
expires: Mon, 08 Jun 2026 07:55:51 GMT
cache-control: private
set-cookie: AEC=AaJma5sSUWyW0DYiU1o1Sc4RhbiigDiMtvXvBWJOM1jVjomZziYGgjbypvY; expires=Sat, 05-Dec-2026 07:55:51 GMT; path=/; domain=.google.com; Secure; HttpOnly; SameSite=lax
set-cookie: NID=532=f6pAPluNzOaDdwnxepWWl-9PexGVwvK80pWFW39FzOSQ1DEIUdAFOvvmH3xwZrd_xcsNbOSV2YdaBvJOegI7SE72714oLr9YnbX0GPsq-mh2nIOvRYOBMeQEt2cCYhn7HZIFrqHPcA2AwWCSUbOEtIjo5RFzsKgHH836uzhSpawqugqBRCgd9qxufEljfQckt6nWHrddD0DbVP7FshAH; expires=Tue, 08-Dec-2026 07:55:51 GMT; path=/; domain=.google.com; HttpOnly
alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000

```
Exit the container and create a new one.

```
exit
docker run -it ubuntu
```
Try using `curl` again:
```
curl https://www.google.com
exit
```
Output:
```
bash: curl: command not found
```
When we create a new container, the packages that were previously installed another container did not transfer to the new one.

Try using the old container that has installed the package

```
docker ps -a
docker start -i <container-id>
```
Try using `curl`
```
curl -I https://www.google.com
```
Output:
```
HTTP/2 200 
content-type: text/html; charset=ISO-8859-1
content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-zu0MsJhjVS-ipfKb_98kxw' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
accept-ch: Sec-CH-Prefers-Color-Scheme
p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
date: Mon, 08 Jun 2026 08:05:59 GMT
server: gws
x-xss-protection: 0
x-frame-options: SAMEORIGIN
expires: Mon, 08 Jun 2026 08:05:59 GMT
cache-control: private
set-cookie: AEC=AaJma5t_O2LHlER2E-M-cuM32AgCj64YGceD9wW7Cpl8voa1hkeMaYdQwA; expires=Sat, 05-Dec-2026 08:05:59 GMT; path=/; domain=.google.com; Secure; HttpOnly; SameSite=lax
set-cookie: NID=532=BdjoHjF4cKNu1vRTliJgmGm4UgUkINzfiHNUAFEL8VhLDKNsPYq4d1uUJKY6ZSMpNGU9ZQxkp1e2_0Zsz8DvqsMSVPi7ulwTJxInurLd-zO55HSCFSpHDKfHNYxAEfsHqMt61I8R00IwjqSMYTNfL0uhDy-GrSh04Fz0hxEF4Xs-yOEtvB2uNh6OfBO4u8wW5YdFBr20KvYOHWR7evpm; expires=Tue, 08-Dec-2026 08:05:59 GMT; path=/; domain=.google.com; HttpOnly
alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000

```
The container that installed the package was still able to use the packages again after exited.

## Explaination

**Why manual installation is not repeatable?**

**Answer:** _When we run `apt-get install` inside a running container, the installation process modifies that container's isolated file system by adding files and binaries. These changes live strictly inside that specific container's temporary writable layer. Because this layer is uniquely bound to that single container instance, the changes are not transferable; when you create a brand-new container, Docker builds it fresh from the pristine, read-only base image where those packages do not exist._

## Questions

1. **What did apt update download, and why is it needed before apt install?**
    
    * `apt-get update` downloads the latest package lists and metadata from your configured software repositories but does not actually download or install any software upgrades. Basically, it updates all the local index of the available packages that are available for download. It is needed because this step ensures the package manager is aware of the software's existence, its dependencies, and the correct download paths.

2. **What problem would a Dockerfile solve here?**
    
    * A Dockerfile would solve the repeating manual installation every time. Dockerfile provides a blueprint and automated the installation process. Any container that is started from the custom image will have all the packages required pre-installed.

3. **Run apt update, then apt install -y curl, then "which curl". Which full path did curl get installed to?**

    * `which curl` gives out put: `/usr/bin/curl`.
     
    It is installed at `usr/bin/curl`.

4. **The binary lives under /usr/bin. What is PATH, and how does the shell use it to find curl?**

    * The `PATH` is a crucial environment variable that lists the directories your shell searches for executable programs. The shell uses the `PATH` string like a sequential checklist to find the `curl` binary file.

    `echo $PATH` shows `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`. 
    
    `PATH` goes through each folder that is separated by `:` until it finds `curl`.