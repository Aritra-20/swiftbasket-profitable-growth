# Video script (about 4.5 minutes)

Read it out loud slowly. "..." means take a breath. The same text is in each slide's speaker notes.

Target: about 615 words at roughly 140 words a minute, which leaves about 30 seconds of slack under the 5-minute limit.

| Time | Slide | What to say |
|---|---|---|
| 0:00 | 1. Cover | Hi, I'm Aritra Pal, a PGPM student at Great Lakes, Chennai... and I picked the SwiftBasket case. Ms. Nair asked Rohan one question: which growth is worth having? My answer in one line... SwiftBasket doesn't have a growth problem. It has a leak problem. And every leak I found can be fixed next quarter. |
| 0:25 | 2. Three leaks | Here are the three leaks. One... discounts and refunds take sixty-six rupees from every order, and we keep forty-four. Two... the Q1 promo lost money, because it went to people who were buying anyway. Three... a delivery promise that ignores distance, and stores with bad stock records. Then, three actions for next quarter. |
| 0:50 | 3. Business health | Start with health. Order volume is flat, about two and a half thousand a month. But look at one order. We earn about a hundred and sixty-seven rupees of margin and fees... discounts take forty-five, refunds take twenty-one, and after picking and delivery we keep forty-four. That's under 8% of GMV, and one order in five loses money. So the scorecard I'd give leadership is these five lines... not the order count. |
| 1:20 | 4. Who is valuable | So who is actually valuable? Customers who lean on discounts repeat as often as anyone... but earn fifteen rupees an order, against seventy-four for light-discount customers. Bigger first-order offers and marketing clicks didn't buy any extra repeat. What goes with repeat is habit, like app sessions. And a surprise for the COO... the busiest customers are the most profitable. The leak isn't frequency. It's discount depth. |
| 1:50 | 5. Delivery promise | Now operations. Every order gets a 20, 25 or 30-minute promise... and the mix is the same whether the customer is half a kilometre away or five. So a 20-minute promise beyond 4 km is late 72% of the time. In rain at peak hours, almost one order in two is late. And late orders get rated lower and call support far more. This isn't just our problem... in January, Blinkit and Zepto dropped their 10-minute claims after the Labour Minister raised rider safety. |
| 2:30 | 6. Stock accuracy | The second ops leak is stock accuracy. Wrong stock records mean missing items at picking... missing items mean refunds... and refunds kill margin. Store margin tracks inventory accuracy with a correlation of 0.77. The worst quarter of stores earn seven rupees less per order and are rated 3.8 instead of 4.3. City and delivery model barely matter, so this is a store operations fix. |
| 3:00 | 7. The promo | Now the promo. It was randomized and the groups are balanced, so this is causal. As run, it lost twelve and a half rupees of margin per customer. Here's the trap. The customers who redeemed most, active and engaged, are the ones it hurt most. They were buying anyway. Only one cell paid back: free delivery for customers lapsed over 90 days who barely open the app. Plus eight rupees each, and it held on a holdout half. |
| 3:35 | 8. Three actions | So, three actions for next quarter. One... send free delivery only to lapsed, low-engagement customers. Per ten thousand customers, a 1.25 lakh loss becomes a small gain, with two-thirds fewer offers. Test it with a holdout and judge it on margin, not redemption. Two... a distance-aware promise. Late deliveries drop from 17 to about 12 percent. The risk is conversion, so I'd run a switchback test. Three... fix stock accuracy in the worst quarter of stores, for roughly 4% more contribution margin. Pilot four stores against four matched ones. |
| 4:15 | 9. How I worked | On method... every core number is SQL on DuckDB, with Python for confidence intervals and charts. Links are below. I used Claude, an AI assistant, to help draft code and chart styling, and then re-computed every headline number in pandas myself. They all match. Thank you. |

## Recording checklist

- Record with Loom, OBS or Zoom (record a meeting with just yourself and share your screen). Keep your face in a small corner bubble; the brief asks to see you.
- Present the deck full screen. Optional, 10 seconds: after slide 3, flip to the dashboard to show it's live, then come back.
- Quiet room, no music, earphones with a mic if you have them.
- Do one full practice run with a timer. If you go over 5:00, cut the Blinkit sentence on slide 5 first.
- Upload to YouTube as **Unlisted** (or Vimeo). Put these in the description:
  - GitHub: https://github.com/Aritra-20/swiftbasket-profitable-growth
  - The AI-use note (below)
- Share the link with your campus SPOC.

## AI-use note (paste in the video description and in the submission)

> I used Claude (an AI assistant) to help with the analysis code (Python and SQL), charts and slide drafts. I reviewed each step and I'm responsible for every number and recommendation. I checked the output by re-computing every headline number in plain pandas, separately from the SQL (all match), and by confirming that the contribution-margin formula reconciles to the rupee on all 30,000 orders.
