# premailer-api

Added some files for running as a passenger app.  
## _important_ you'll need to edit .htaccess to suit your environment.

Forked from [bdavid/premailer-api](https://github.com/bdavid/premailer-api)

Reordered docker container so I could build a little faster, and removed the reliance on redis since we don't have it and don't need it.  Simplified the API by making it less restful and responds to get requests.  This introduces some duplicate code, but it's functional and like 30 lines total.

Left some test code in because it's not that important.

