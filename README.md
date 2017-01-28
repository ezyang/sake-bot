# sake-bot


![sake-bot](https://raw.githubusercontent.com/ezyang/sake-bot/master/sake-bot.png)

This is a bot for taking Travis Web Hook notifications and turning them
into GitHub status updates for a DIFFERENT (usually upstream)
repository.

Why would you want this?  Let's say you have a CI setup where after you
successfully build a project, you trigger a Travis build of some
downstream projects to check if they still work.  sake-bot will update
the upstream commit with build statuses of the downstream projects,
so it is easy to tell if you are breaking downstream or not.

It is named sake-bot after the salmon, which swims upstream to spawn.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## How to set it up

This webhook is fairly simple to use:

1. Create a new integration using https://github.com/settings/integrations/new
   The homepage/callback URLs are not important, but the permissions we
   will need are "Commit statuses", set to "Read & Write" and the
   "Status checkbox ticked.

2. Now you can perform the Heroku installation.  Have ready the ID
   (from the settings integration page) and the private key that
   you generated (using the "Generate private key") button.

3. With the URL Heroku installation, add it to the Travis file
   of the repo which you want to notify upstream:

    ```
    notifications:
        webhooks: https://sake-bot.herokuapp.com/
    ```

## How to develop

How to test: `curl http://localhost:4567/ -X POST --data-urlencode "payload@sample.json"`
