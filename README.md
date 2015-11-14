# Trac in a Gentoo Docker container


```
docker build -t gentoo-trac .
docker run -dti -p 8080:80 -p 8443:443 gentoo-trac
```

Warning: Authentication is not yet built-in and `anonymous` will have the
`TRAC_ADMIN` privilege, which means that plugins can be uploaded and code be
executed in the container.

The portage tree is not retained in `/usr/portage` after building this image.
It is first fetched to install the required packages, but deleted immediately
afterwards to avoid expanding the image size too much. It defines a Docker
volume `/usr/portage` so that users can mount a local directory at that
location to store the portage tree locally for containers based on this image.
