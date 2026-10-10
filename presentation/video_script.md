# Video script (about 4:23)

Read it slowly and naturally. "..." means take a breath. The same text is in each slide's speaker notes.

About 610 words: about 4:23 at 140 words a minute, or 4:43 at a slower 130, so there's slack under the 5-minute limit. The appendix slide is for questions only; don't read it in the video.

| Time | Slide | What to say |
|---|---|---|
| 0:00 | 1. Cover | Hi, I'm Aritra Pal from Great Lakes, Chennai, and I picked the SwiftBasket case. The COO's question was simple: we're growing, but which growth is worth having? I loaded the case data into SQL, answered each question with simple queries, and built two Tableau dashboards. Here's what I found. |
| 0:21 | 2. Three findings | Three things. One... discounts and refunds take sixty-six rupees out of every order, and we keep only forty-four. Two... the Q1 promo lost money: the extra orders didn't cover the cost of the offers. Three... we promise twenty-minute delivery to customers who live too far away, and some stores keep poor stock records. Each one has a fix. |
| 0:45 | 3. Business health | First, health. Orders are nearly flat, about two and a half thousand a month. An average order earns about a hundred and sixty-seven rupees in product margin and fees. Discounts take forty-five, refunds take twenty-one, and after picking and delivery we keep forty-four. That's under 8% of sales, and one order in five loses money. Cancellations are only one percent of orders, but they cost about nine percent of our margin. So leadership should watch margin per order, not order count. |
| 1:20 | 4. Customers | Next, customers. The discount doesn't grow with the basket: it averages forty-five rupees at every size, so orders under four hundred rupees lose about ten rupees each. Customers who lean on discounts come back more often, but earn us fifteen rupees an order against seventy-four. And our busiest customers get the biggest discounts, so they earn the least per order... though they're still worth the most in total. So trim their discounts, don't lose them. |
| 1:52 | 5. Delivery | Now delivery. Twenty, twenty-five and thirty-minute promises all go to customers at the same average distance, so a twenty-minute promise beyond 4 km is late 72% of the time. In rain at peak hours, almost half of all orders are late, and late orders get lower ratings. This is a real-world issue too: Outlook Business reported in January that Blinkit and Zepto dropped their 10-minute claims after the Labour Minister raised rider safety. |
| 2:24 | 6. Stores | Second ops problem: missing items. Two in three delivered orders have at least one. With nothing missing there's no refund at all; with a missing item the refund averages about twenty-eight rupees, and ratings drop. Nine stores have stock records less than 90% accurate, and they earn about eleven rupees less per order than the best stores. Delivery model makes no difference, so the fix is inside the store. |
| 2:53 | 7. Promo test | Now the promo, which was a random test. Customers who got an offer ordered a bit more, but gave twelve and a half rupees less margin each: the extra orders didn't cover the cost. Active customers redeemed the most, yet no offer paid for them. Only free delivery for customers who'd stopped ordering and rarely open the app clearly paid: about eight rupees each, and it held up when I split the data in half. |
| 3:25 | 8. Three actions | So, three actions for next quarter. One... send free delivery only to customers who've stopped ordering and rarely open the app, and stop discounting baskets under four hundred rupees. Two... promise twenty-five minutes within 2 km and thirty beyond. Late deliveries drop from 17% to about seven and a half, though 40% of orders see a longer promise, so I'd pilot it first. Three... fix stock records in the nine weakest stores, worth about 3% more margin. |
| 3:58 | 9. How I worked | On method... all numbers come from the case data, except the news point I mentioned. I used simple SQL in a Kaggle notebook and built the dashboards in Tableau. I used Claude, an AI assistant, to help write the code and draft the text, and I re-checked every number on these slides separately in Python. Thank you. |

## Recording checklist

- Record with Loom, OBS or Zoom (a meeting with just yourself, sharing your screen). Keep your face in a small corner; the brief asks to see you.
- Show the slides full screen. Optional: after slide 3, flip to your Tableau dashboard for about 10 seconds, then come back.
- Quiet room, no music. Earphones with a mic help.
- Do one practice run with a timer. If you go over 5:00, shorten slide 6 first.
- Upload to YouTube as **Unlisted**. In the description, put the GitHub link, your Tableau Public link (if you publish the dashboard there), and the AI-use note below.
- Send the link to your campus SPOC.

## AI-use note (paste in the video description)

> I used Claude (an AI assistant) to help write the SQL/Python code and draft the slide text. I reviewed each step and I'm responsible for every number. I checked the key numbers by re-calculating them in plain Python, without SQL, at the end of the notebook. They match.

## Outside source used

- Outlook Business, 13 Jan 2026: "Quick-commerce giants drop '10-minute delivery' promise after govt intervention" (slide 5). Every other number comes from the case workbook.
