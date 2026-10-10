"""Independent re-computation of every number used in the slides, straight from the raw workbook.
Plain pandas, no SQL, no cached data. Usage: python qa/independent_check.py data/SwiftBasket_2026_Case_Data.xlsx"""
import sys, numpy as np, pandas as pd
P = sys.argv[1]
O = pd.read_excel(P, sheet_name="orders"); C = pd.read_excel(P, sheet_name="customers")
S = pd.read_excel(P, sheet_name="stores"); K = pd.read_excel(P, sheet_name="campaign_assignments")
R = {}
def put(k, v): R[k] = v; print(f"{k:55s} {v}")

# ---------- Health
gmv = O.basket_value_inr.sum()
put("orders", len(O))
put("ordering customers", O.customer_id.nunique())
put("GM/order", round(O.gross_margin_inr.mean(), 2)); put("fee/order", round(O.delivery_fee_inr.mean(), 2))
put("GM+fee/order", round(O.gross_margin_inr.mean() + O.delivery_fee_inr.mean(), 2))
put("disc/order", round(O.discount_inr.mean(), 2)); put("pick/order", round(O.picking_cost_inr.mean(), 2))
put("lastmile/order", round(O.delivery_cost_inr.mean(), 2)); put("refund/order", round(O.refund_inr.mean(), 2))
put("disc+refund/order", round(O.discount_inr.mean() + O.refund_inr.mean(), 2))
put("CM/order", round(O.contribution_margin_inr.mean(), 2))
put("CM identity max abs err", (O.gross_margin_inr + O.delivery_fee_inr - O.discount_inr - O.picking_cost_inr - O.delivery_cost_inr - O.refund_inr - O.contribution_margin_inr).abs().max())
put("CM % GMV", round(O.contribution_margin_inr.sum() / gmv, 4))
put("disc % GMV", round(O.discount_inr.sum() / gmv, 4)); put("refund % GMV", round(O.refund_inr.sum() / gmv, 4))
put("disc total vs CM total", (round(O.discount_inr.sum()), round(O.contribution_margin_inr.sum())))
put("loss-making order share", round((O.contribution_margin_inr < 0).mean(), 4))
put("late rate (delivered)", round(O.late_delivery_flag.mean(), 4))
put("cancel rate", round(O.cancelled_flag.mean(), 4))
put("orders with stockout", round((O.stockout_item_count > 0).mean(), 4))
put("orders with refund", round((O.refund_inr > 0).mean(), 4))
neg = O[O.contribution_margin_inr < 0]
put("loss orders with refund", round((neg.refund_inr > 0).mean(), 4))
put("refund ₹ on stockout orders share", round(O.loc[O.stockout_item_count > 0, "refund_inr"].sum() / O.refund_inr.sum(), 4))
m = O.groupby(O.order_timestamp.dt.month).agg(n=("order_id", "count"), late=("late_delivery_flag", "mean"))
put("monthly orders min/max", (m.n.min(), m.n.max())); put("late Jun-Sep", m.late.loc[6:9].round(3).tolist())

# ---------- Discount depth
dp = O.discount_inr / O.basket_value_inr
q = pd.qcut(dp.rank(method="first"), 5, labels=False)
put("CM by discount quintile", O.groupby(q).contribution_margin_inr.mean().round(2).tolist())
put("discount quintile lower bounds", dp.groupby(q).min().round(3).tolist())

# ---------- Customers
cu = O.groupby("customer_id").agg(n=("order_id", "count"), cm=("contribution_margin_inr", "sum"),
                                  disc=("discount_inr", "sum"), gmv=("basket_value_inr", "sum"), cats=("unique_category_count", "mean"))
cu["ds"] = cu.disc / cu.gmv; cu["cmpo"] = cu.cm / cu.n
cc = C.merge(cu, left_on="customer_id", right_index=True, how="inner")
b = pd.cut(cc.ds, [-0.01, .05, .08, .11, 1])
put("repeat by discount share", cc.groupby(b, observed=True).repeat_order_30d.mean().round(3).tolist())
put("CM/order by discount share (cust avg)", cc.groupby(b, observed=True).cmpo.mean().round(2).tolist())
put("hist==orders", (C.merge(cu, left_on="customer_id", right_index=True, how="left").fillna({"n": 0}).pipe(lambda d: (d.historical_orders_12m == d.n).mean())))
s = pd.cut(C.app_sessions_30d, [-1, 3, 7, 12, 99])
put("repeat by sessions", C.groupby(s, observed=True).repeat_order_30d.mean().round(3).tolist())
put("repeat by clicks 0..4", C.groupby("campaign_clicks_30d").repeat_order_30d.mean().round(3).tolist())
fo = pd.cut(C.first_order_offer_inr, [-1, 0, 75, 112, 999])
put("repeat by first offer", C.groupby(fo, observed=True).repeat_order_30d.mean().round(3).tolist())
put("first offer max", C.first_order_offer_inr.max())
cb = pd.cut(cc.cats, [0, 3, 5, 99])
put("repeat by categories (<=3,3-5,>5)", cc.groupby(cb, observed=True).repeat_order_30d.mean().round(3).tolist())
put("member disc share / cm per order", cc.groupby("membership_status").agg(d=("ds", "mean"), c=("cmpo", "mean")).round(3).to_dict())
cu2 = cu.reset_index().sort_values(["n", "customer_id"]).reset_index(drop=True)
cu2["fq"] = pd.qcut(cu2.n.rank(method="first"), 5, labels=False)
f = cu2.groupby("fq").agg(orders=("n", "mean"), cm_cust=("cm", "mean"), loss=("cm", lambda x: (x < 0).mean()),
                          cm_per_order=("cm", "sum"), norders=("n", "sum"))
f["cm_per_order"] = f.cm_per_order / f.norders
put("freq quintiles", f.round(2).to_dict("list"))
put("channel repeat range", C.groupby("acquisition_channel").repeat_order_30d.mean().round(3).to_dict())

# ---------- Ops
dl = O[O.cancelled_flag == 0].copy()
dl["band"] = pd.cut(dl.delivery_distance_km, [-.1, 1, 2, 3, 4, 99], labels=["0-1", "1-2", "2-3", "3-4", "4+"])
put("20-min share by band", pd.crosstab(dl.band, dl.promised_minutes, normalize="index")[20].round(3).tolist())
lt = dl.groupby(["band", "promised_minutes"], observed=True).late_delivery_flag.mean().unstack().round(3)
put("late 20/25/30 by band", lt.to_dict("list"))
put("late by promise overall", dl.groupby("promised_minutes").late_delivery_flag.mean().round(3).to_dict())
pw = O.groupby(["weather_flag", "peak_period_flag"]).late_delivery_flag.mean().round(3)
put("late weather x peak", pw.to_dict())
put("peak hours", sorted(O.loc[O.peak_period_flag == 1, "order_timestamp"].dt.hour.unique().tolist()))
dl["b3"] = pd.cut(dl.delivery_distance_km, [-.1, 2, 4, 99])
g = dl.groupby(["b3", "late_delivery_flag"], observed=True).agg(cm=("contribution_margin_inr", "mean"), r=("rating", "mean"), c=("service_contact_flag", "mean")).unstack()
put("late-vs-ontime CM gap by band", (g.cm[0] - g.cm[1]).round(2).tolist())
put("late-vs-ontime rating gap", (g.r[0] - g.r[1]).round(2).tolist())
put("late/ontime contact ratio", (g.c[1] / g.c[0]).round(2).tolist())
db = pd.cut(O.delivery_distance_km, [-.1, 1, 2, 3, 4, 99])
put("CM & late & lastmile by distance", O.groupby(db, observed=True).agg(cm=("contribution_margin_inr", "mean"), late=("late_delivery_flag", "mean"), dc=("delivery_cost_inr", "mean")).round(2).to_dict("list"))
put("lastmile slope ₹/km (OLS)", round(np.polyfit(O.loc[O.cancelled_flag == 0, "delivery_distance_km"], O.loc[O.cancelled_flag == 0, "delivery_cost_inr"], 1)[0], 2))
so = pd.cut(O.stockout_item_count, [-1, 0, 1, 2, 99])
put("stockout -> refund/CM/rating", O.groupby(so, observed=True).agg(r=("refund_inr", "mean"), cm=("contribution_margin_inr", "mean"), rt=("rating", "mean")).round(2).to_dict("list"))
OS = O.merge(S, on="store_id")
st = OS.groupby("store_id").agg(cm=("contribution_margin_inr", "mean"), late=("late_delivery_flag", "mean"), so=("stockout_item_count", "mean")).join(S.set_index("store_id"))
put("corr CM~inv acc", round(st.cm.corr(st.inventory_accuracy_pct), 3))
put("corr stockouts~inv acc", round(st.so.corr(st.inventory_accuracy_pct), 3))
put("corr late~staffing", round(st.late.corr(st.staffing_fill_rate_pct), 3))
put("worst 3 stores CM", st.cm.nsmallest(3).round(2).to_dict())
put("stores <=90% acc", sorted(st.index[st.inventory_accuracy_pct <= 90].tolist()))
OS["iq"] = pd.qcut(OS.inventory_accuracy_pct.rank(method="first"), 4, labels=False)
iq = OS.groupby("iq").agg(cm=("contribution_margin_inr", "mean"), rt=("rating", "mean"), ref=("refund_inr", "mean"), n=("order_id", "count"), hi=("inventory_accuracy_pct", "max"), stores=("store_id", "nunique"))
put("inv quartiles", iq.round(2).to_dict("list"))
lo = st.inventory_accuracy_pct <= 90
OSg = OS.assign(grp=np.where(OS.inventory_accuracy_pct <= 90, "le90", np.where(OS.inventory_accuracy_pct >= 95, "ge95", "mid")))
gg = OSg.groupby("grp").agg(cm=("contribution_margin_inr", "mean"), rt=("rating", "mean"), ref=("refund_inr", "mean"), n=("order_id", "count"), stores=("store_id", "nunique"))
put("groups le90/mid/ge95", gg.round(2).to_dict())
put("le90->mid gain share of CM", round((gg.cm["mid"] - gg.cm["le90"]) * gg.n["le90"] / O.contribution_margin_inr.sum(), 4))
f2 = O.merge(cu2[["customer_id","fq"]], on="customer_id").groupby("fq").agg(disc=("discount_inr","sum"), gmv=("basket_value_inr","sum"), ref=("refund_inr","mean"), aov=("basket_value_inr","mean"), cm=("contribution_margin_inr","mean"))
f2["ds"] = f2.disc / f2.gmv
put("freq quintile discount share/refund/aov/cm", f2[["ds","ref","aov","cm"]].round(3).to_dict("list"))
put("Q3-Q1 gap ₹/order", round(iq.cm[2] - iq.cm[0], 2))
put("gap*Q1 orders / total CM", round((iq.cm[2] - iq.cm[0]) * iq.n[0] / O.contribution_margin_inr.sum(), 4))
OS = OS.merge(C[["customer_id", "city_tier"]], on="customer_id")
for col in ["city", "city_tier", "delivery_partner_model", "store_format", "catchment_density"]:
    v = OS.groupby(col).contribution_margin_inr.mean(); put(f"CM range by {col}", round(v.max() - v.min(), 2))
v = O.groupby(O.order_timestamp.dt.dayofweek).contribution_margin_inr.mean(); put("CM range by weekday", round(v.max() - v.min(), 2))

# ---------- Campaign
KC = K.merge(C, on="customer_id")
put("control/treated", KC.assignment_group.value_counts().to_dict())
put("treated all sent?", KC.loc[KC.assignment_group == "Treatment", "offer_sent_flag"].mean())
c0 = KC[KC.assignment_group == "Control"]
put("overall uplift ₹", round(KC[KC.assignment_group == "Treatment"].post_campaign_margin_inr.mean() - c0.post_campaign_margin_inr.mean(), 2))
put("uplift by offer", {o: round(d.post_campaign_margin_inr.mean() - c0.post_campaign_margin_inr.mean(), 2) for o, d in KC[KC.assignment_group == "Treatment"].groupby("offer_type")})
put("redemption by offer", KC[KC.assignment_group == "Treatment"].groupby("offer_type").offer_redeemed_flag.mean().round(3).to_dict())
KC["seg"] = np.where(KC.days_since_last_order > 90, "L", "A") + np.where(KC.app_sessions_30d <= 7, "low", "high")
put("segment share", KC.seg.value_counts(normalize=True).round(3).to_dict())
put("redemption by seg", KC[KC.assignment_group == "Treatment"].groupby("seg").offer_redeemed_flag.mean().round(3).to_dict())
put("blended uplift by seg", {s_: round(d[d.assignment_group == "Treatment"].post_campaign_margin_inr.mean() - d[d.assignment_group == "Control"].post_campaign_margin_inr.mean(), 2) for s_, d in KC.groupby("seg")})
rng = np.random.default_rng(123)
for seg in ["Llow", "Ahigh", "Alow", "Lhigh"]:
    d = KC[KC.seg == seg]; t = d[d.offer_type == "Free delivery"].post_campaign_margin_inr.values; c = d[d.offer_type == "No offer"].post_campaign_margin_inr.values
    bs = [rng.choice(t, len(t)).mean() - rng.choice(c, len(c)).mean() for _ in range(4000)]
    to = d[d.offer_type == "Free delivery"].post_campaign_orders.mean() - d[d.offer_type == "No offer"].post_campaign_orders.mean()
    put(f"FD uplift {seg} (pt, CI, Δorders)", (round(t.mean() - c.mean(), 2), np.percentile(bs, [2.5, 97.5]).round(2).tolist(), round(to, 3)))
t = KC[KC.offer_type == "Fixed discount"].post_campaign_margin_inr.values; c = c0.post_campaign_margin_inr.values
bs = [rng.choice(t, len(t)).mean() - rng.choice(c, len(c)).mean() for _ in range(4000)]
put("Fixed CI", np.percentile(bs, [2.5, 97.5]).round(1).tolist())
put("policy blanket per 10k", round((KC[KC.assignment_group == "Treatment"].post_campaign_margin_inr.mean() - c0.post_campaign_margin_inr.mean()) * 1e4))
d = KC[KC.seg == "Llow"]
put("policy targeted per 10k", round((d[d.offer_type == "Free delivery"].post_campaign_margin_inr.mean() - d[d.offer_type == "No offer"].post_campaign_margin_inr.mean()) * 1e4 * (KC.seg == "Llow").mean()))

# ---------- Promise counterfactual
cell = dl.groupby(["band", "promised_minutes"], observed=True).late_delivery_flag.mean()
newp = {"0-1": 20, "1-2": 25, "2-3": 25, "3-4": 30, "4+": 30}
put("late new policy", round(np.mean([cell[(b_, newp[b_])] for b_ in dl.band]), 4))
put("share <=25 new vs now", (round((dl.band.map(newp) <= 25).mean(), 3), round((dl.promised_minutes <= 25).mean(), 3)))

# ---------- Randomization balance and the holdout check (same split rule as the notebook)
put("balance: mean pre-period by offer", KC.groupby("offer_type")[["days_since_last_order", "app_sessions_30d", "historical_orders_12m"]].mean().round(1).to_dict())
KC["half"] = np.random.default_rng(2026).random(len(KC)) < 0.5
def cell_uplift(df, seg, offer):
    d = df[df.seg == seg]
    return d[d.offer_type == offer].post_campaign_margin_inr.mean() - d[d.offer_type == "No offer"].post_campaign_margin_inr.mean()
cells = [(s_, o_) for s_ in KC.seg.unique() for o_ in ["Fixed discount", "Percentage discount", "Free delivery"]]
best = max(cells, key=lambda x: cell_uplift(KC[KC.half], *x))
put("holdout: best cell on train half", (best, round(cell_uplift(KC[KC.half], *best), 2)))
put("holdout: same cell on test half", round(cell_uplift(KC[~KC.half], *best), 2))
