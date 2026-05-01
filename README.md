# rball-payer
Reimburse for racquetball court time

This application was initially developed with Anthropic Claude Sonnet 4.6 (free version), using the following prompt:
> Every Saturday, from 9am-noon, four of my friends and I play racquetball at a racket club called Spark.  Each day that we play, Spark charges us $30 per hour per court.  We typically use just one court.  So, if we play 9am-noon, that means we pay $90 total.  One of us usually pays the entire Spark bill.  Then the rest of us reimburse the person who paid.

> In fairness, we let players reimburse based only on the actual amount of time they played, down to the half hour.  To accommodate this, we divide the three-hour time period into half-hour sub-periods (e.g. 9-9:30, 9:30-10, 10-10:30, etc.).  During any one half-hour sub-period, the players who were actually playing on the court during that time split the $15 per half-hour cost evenly.  So if three people are playing from 10-10:30, each person will pay $5.  

> At the end of the day, each person's pay amounts for all six half-hour periods are added up, and the sum is the total amount they owe the person who paid Spark for that day.

> A spreadsheet is then prepared with all the above calculations and sent out so that all players know how much they owe for the day.  Reimbursement to the player who paid Spark is then done using apps like Venmo or Zelle.

> Let's build an application to facilitate this racquetball reimbursement.  The app should run in a desktop browser or as a phone app.  The data for the application should be stored in the cloud.  The data for each day's reimbursements should be easily separable from other days.  However, a nice-to-have feature would include a way to track and summarize what one individual player has paid and owes for several days.

> The phone version of the application in particular should make it very easy for players to indicate which half-hour periods they played. 

> Finally, the application should be written in a way that is easy to maintain, modify and scale.

> Can you implement this?
