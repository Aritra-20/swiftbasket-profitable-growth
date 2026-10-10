# Video script (about 4:22)

Read it slowly and naturally. "..." means take a breath. The same text is in each slide's speaker notes.

About 611 words at roughly 140 words a minute, so there's some slack under the 5-minute limit.

| Time | Slide | What to say |
|---|---|---|
| 0:00 | 1. Cover | Hi, I'm Aritra Pal from Great Lakes, Chennai, and I picked the SwiftBasket case. The COO's question was simple: we're growing, but which growth is worth having? I loaded the case data into SQL, answered each question with simple queries, and built two Tableau dashboards. Here's what I found. |
| 0:21 | 2. Three findings | Three things. One... discounts and refunds take sixty-six rupees out of every order, and we keep only forty-four. Two... the Q1 promo lost money, because most of it went to people who would have ordered anyway. Three... we promise twenty-minute delivery to customers who live too far away, and some stores keep poor stock records. Each one has a fix. |
| 0:47 | 3. Business health | First, health. Orders are flat, about two and a half thousand a month. An average order brings in about a hundred and sixty-seven rupees. Discounts take forty-five, refunds take twenty-one, and after picking and delivery we keep forty-four. That's under 8% of sales, and one order in five actually loses money. So the number leadership should watch is margin per order, not order count. |
| 1:14 | 4. Customers | Next, customers. The bigger the discount, the smaller the margin... and the basket doesn't get any bigger. With no discount an order leaves eighty-seven rupees. With seventy-six or more off, it leaves five. And our most frequent customers get the biggest discounts, so they earn us the least per order: thirty-two rupees against fifty-seven. Membership, channel and the first-order offer barely change repeat rates. App use does. |
| 1:43 | 5. Delivery | Now delivery. Twenty, twenty-five and thirty-minute promises all go to customers at the same average distance. So a twenty-minute promise beyond 4 km is late 72% of the time. In rain at peak hours, almost half of all orders are late. And late orders get lower ratings and more support calls. This is a real-world issue too: according to Outlook Business, in January Blinkit and Zepto agreed to drop their 10-minute delivery claims after the Labour Minister raised rider safety. |
| 2:16 | 6. Stores | Second ops problem: missing items. When nothing is missing, the average refund is ten rupees. When even one item is missing, it's twenty-eight, and ratings drop. Nine stores have stock records that are less than 90% accurate. They earn about eleven rupees less per order than the best stores. City and delivery model barely matter, so the fix is inside the store. |
| 2:43 | 7. Promo test | Now the promo. It was a random test, so I can compare treatment with control fairly. Overall, customers who got an offer ordered a bit more, but gave twelve and a half rupees less margin each. Active customers redeemed the most, and every offer lost money on them, because they were going to order anyway. The only offer that paid was free delivery for lapsed customers: plus four point seven rupees each. The groups are small, so I'd test it again. |
| 3:18 | 8. Three actions | So, three actions for next quarter. One... stop offers to active customers, and send free delivery only to lapsed ones. Per thousand customers, that turns a twelve-thousand-rupee loss into a small gain. Two... set the promise by distance: twenty-five minutes within 2 km, thirty beyond. Late deliveries drop from 17% to about 7%, but customers see a longer promise, so I'd test it in a few stores first. Three... fix stock records in the nine weakest stores, worth about 3% more margin. Start with three or four stores. |
| 3:56 | 9. How I worked | On method... all the numbers come from the case data, except the news point I mentioned, with its source shown. I used simple SQL in a Kaggle notebook and built the dashboards in Tableau. I used Claude, an AI assistant, to help write the code and draft the text, and I double-checked the key numbers in plain Python. They match. Thank you. |

## Recording checklist

- Record with Loom, OBS or Zoom (a meeting with just yourself, sharing your screen). Keep your face in a small corner; the brief asks to see you.
- Show the slides full screen. Optional: after slide 3, flip to your Tableau dashboard for about 10 seconds, then come back.
- Quiet room, no music. Earphones with a mic help.
- Do one practice run with a timer. If you go over 5:00, shorten slide 6 first.
- Upload to YouTube as **Unlisted**. In the description, put the GitHub link, your Tableau Public link, and the AI-use note below.
- Send the link to your campus SPOC.

## AI-use note (paste in the video description)

> I used Claude (an AI assistant) to help write the SQL/Python code and draft the slide text. I reviewed each step and I'm responsible for every number. I checked the key numbers by re-calculating them in plain Python, without SQL, at the end of the notebook. They match.

## Outside source used

- Outlook Business, 13 Jan 2026: "Quick-commerce giants drop '10-minute delivery' promise after govt intervention" (slide 5). Every other number comes from the case workbook.
