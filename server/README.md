# Demo Server in DigitalOcean

To automatically create a demo server with demo photos included in DigitalOcean

- Install [bundler](http://bundler.io).
- Run `bundle install` from the root directory of this repository.
- Install [Fastlane](https://github.com/fastlane/fastlane).
- Generate new [personal access token in DigitalOcean](https://cloud.digitalocean.com/settings/api/tokens).
- Create file `d_o_key` in the root of the repository and put the personal access token inside.
- Run `fastlane demo_server_manual` from the root directory of this repository.
- Due to some (possible) weird bug in Trovebox, you need to login once to Trovebox demo from the website. username: **support@delightfuldev.com** password: **1234**
- Then SSH to the server: `ssh root@<IP_ADDRESS>`
- Then run `mysql -uroot trovebox < update-activity-import.sql`
