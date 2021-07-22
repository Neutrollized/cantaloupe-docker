# README

The Alpine Linux version of the Cantaloupe server is about half the size of the Debian version.

If you don't to run the Admin Control Panel (i.e. `ENDPOINT_ADMIN_ENABLED=false`), then you can futher slim down this image by leaving out the installation of **msttcorefonts-installer** and **fontconfig** packages and not running `update-ms-fonts` as those packages are only required for displaying the UI.
