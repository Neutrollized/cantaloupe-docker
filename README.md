# README
This repo shows how build and run a Cantaloupe (v5+) container image as there is [no official Docker image](https://cantaloupe-project.github.io/manual/5.0/getting-started.html#Docker) yet.

## Building
```
docker build -t cantaloupe:5.0.3 .
```

### GrokProcessor
At the time of writing, the [`libgrokj2k` deb package](https://tracker.debian.org/pkg/libgrokj2k) package is still does not have a stable version and hence it is not currently being installed

### TurboJpegProcessor
If you don't need the TurboJpeg proccessor, you can delete that RUN step and change the `default-jdk` package to `default-jre-headless` and this should reduce your image size by ~250MB


## How to Run
```
docker run --env-file env_list.sample -p 8182:8182 cantaloupe:5.0.3
```

- splash page: http://localhost:8182 (can't really do much here though)
- admin control panel: http://localhost:8182/admin (username is always **admin**)

They have some decent [Getting Started](https://cantaloupe-project.github.io/manual/5.0/getting-started.html) documentation as well as [Intro to IIIF](https://iiif.github.io/training/intro-to-iiif/POINTING_YOUR_IMAGE_SERVER.html) so be sure to check those out.


## Gotchas!
When I started working on this, I didn't have much experience with Cantaloupe nor did I have a very complex setup, so I was looking at the Admin Control Panel/UI to validate that settings/values were correct.  What I didn't know was that the UI is not very source of truth for settings and spent more time than I would have like to admit trying to troubleshoot this before I made a [GitHub Issue](https://github.com/cantaloupe-project/cantaloupe/issues/523).  So, don't expect to see the your settings passed via [environment variables](https://cantaloupe-project.github.io/manual/4.1/configuration.html) to show up in the Admin Control Panel/UI. 
