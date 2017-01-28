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
