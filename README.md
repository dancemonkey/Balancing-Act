# BalancingAct

## WHY?

I'm kind of obsessed with balancing my bank account. It's so simple to do and do properly, and it's practically the only thing in my life financially that I feel like I have control over (not the balance itself mind you, simply the fact that it's balanced.

Because I'm weird I don't like using Quicken, Money, or any other accounting software. I used something like that years ago and the act of reconciling the account confused me, so I went back to basic: I created a spreadsheet from scratched and learned how to reconcile my account with the bank's transactions that way.

Over the years the spreadsheet migrated to Google Sheets, I wrote a form front-end to be able to enter transactions and have them populate the spreadsheet, and I wrote a script to help me balance the account. But all of that was still a multi-stage process that required me to be at a "real" computer in order to reconcile my account.

So here we are: this app uses Firebase as the back end to store user, account, and transaction info (I'm the only user, I don't currently have plans to release this). Why not just use Core Data? Because eventually I want to also access the data via a website via Javascript, and I also wanted to learn Firebase. Win-win.
