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

2. You'll need to install the integration to the account you want
   to use it with (which you must be an owner of.)  Do this from
   the integration settings page.  If you like, restrict permissions
   of the integration to only repositories for which you want
   it to report build statuses.

3. Now you can perform the Heroku installation.  Have ready the ID
   (from the settings integration page) and the private key that
   you generated (using the "Generate private key") button.

4. With the URL Heroku installation, add it to the Travis file
   of the repo which you want to notify upstream:

    ```
    notifications:
        webhooks: https://sake-bot.herokuapp.com/
    ```

5. Whenever Travis builds a commit whose commit message consists
   solely of a JSON object of the form:

   ```
    { "account": "ezyang",
      "repo": "sozu",
      "commit": "e793e18190180f7a2340c6d9acb3aa7196a0c459" }
   ```

   this webhook will push a status update to that commit from this
   repository.  (TODO: Maybe this information should be conveyed
   by some other channel.)

There is an important other piece of the puzzle, which is actually
triggering the subsidiary builds.  There are two strategies:

1. Trigger it using the Travis API.  In this case, you should just
   setup GitHub web hooks to call Travis appropriately.  I've never done this
   so I have no example code.

2. Trigger it via a Git push.  This is pretty useful because it
   means you can SAVE build products from the upstream build,
   speading up downstream builds.

https://github.com/ezyang/sozu is a repository which contains some
example code of how to push build products to
https://github.com/ezyang/sozu-binaries which actually tests the code.
The key ingredients:

1. You'll need an account with push access to `sozu-binaries`.
   It's best to create a new account for this purpose, as you
   will be placing the private SSH key for the account inside a public
   Git repository.  (You could encrypt it using Travis, but this will
   only work for non pull requests).

2. After you're done building (`after_success`), you'll want to
   push to this repository.
   https://github.com/ezyang/sozu/blob/master/sozu-deploy.sh contains
   the juicy bits but you will probably have to tweak this script
   so that it pulls in the information you need.

3. The directory that is pushed to the remote *itself* has a .travis.yml
   https://github.com/ezyang/sozu/blob/master/binaries/.travis.yml which
   runs the tests and then notifies this webhook.

## FAQ

**It didn't work!**  Run `heroku logs` to get some insight into what
went wrong.  Common mistakes I made:

1. I misformatted the JSON in the commit message.

2. I forgot to give the integration access to the repo whose statuses
   I wanted to update.

## How to develop

Do, uh, the usual ruby thing (`bundle`).  Then you can run the
server with `config.ru`.

You're gonna need some environment variables.  We've mentioned
`INTEGRATION_KEY` and `INTEGRATION_ID` (for `INTEGRATION_KEY`
use something like `INTEGRATION_KEY=$(cat private-key.pem)`).
However, if you don't feel like setting up an integration,
`GITHUB_TOKEN` works too (give it one of your personal tokens.)
Remember that the token must have WRITE access to the repo it
wants to update statuses of.

If you want to feed synthetic Travis data, you'll probably want
to also add `SKIP_VERIFY=1`, which will turn off verification of
incoming requests.

We've left some sample data in the root dir for you to
try it with.  Something like
`curl http://localhost:4567/ -X POST --data-urlencode "payload@sample.json"`
should be good enough.

Tests? We ain't got no stinking tests. Maybe if someone ever writes
some good GitHub and Travis fakes we might be able to have an automated
test suite :)
