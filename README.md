# What the free sources disagree about when you retry a returned ACH debit

If you build a dunning schedule for ACH debits in the US, you will look up how many
times you may re-present a debit that came back for insufficient funds, and how long
you have to do it. You will find a number. It will be confidently stated and it will
not carry a citation you can open.

This document records what four freely readable sources actually say, measured on
2026-08-24, and which parts of their disagreement are real.

The short version: most of the disagreement is not disagreement. It is three
different questions being answered in the same units by sources that do not say
which question they answered. One piece of it is a genuine open question, and you
cannot close that one for free, because the text that governs it is sold rather
than published.

## The governing text is not free

The rule lives in the Nacha Operating Rules, subsection 2.12.4. Nacha sells that
book. There is no free authoritative copy.

The obvious place to look instead is Federal Reserve Operating Circular No. 4, which
governs ACH clearing and settlement by the Reserve Banks and is published as a PDF at
no cost. OC 4 does not contain the rule.

That is a measurement, not an impression. The current version, effective 2026-01-05,
is 71 pages. Extracted with two independent tools and searched with whitespace
normalised so a phrase broken across a line break can still match:

    reinitiat                0
    return entry             0
    R-code (R01 to R85)      0
    "180 days"               0
    "30 days"                0
    Nacha                   13

Both tools returned identical counts on every term. A known-true control (the
document's own title) was present in both extractions and a fabricated control term
was absent, so the zeros are a finding rather than a failed extraction.

The reason OC 4 says nothing is stated in its own section 1.3, verbatim:

> (a) Except as provided in paragraph 1.3(b) below, the Nacha Operating Rules are
> incorporated into this operating circular as "applicable ACH rules" with respect
> to ACH items sent to or received by a Reserve Bank, regardless of whether the
> sending bank or receiving bank is a member of an ACH association.

and, in its definitions:

> (q) Nacha Operating Rules means the operating rules published by Nacha.

So the free primary source is a pointer to the paid primary source. It incorporates
the rule by reference and reproduces none of it. Section 1.3(b) then lists what is
NOT incorporated, which is worth reading if you are relying on OC 4 for anything:
provisions that conflict with applicable law, provisions that conflict with
non-variable parts of Article 4A for credit items, provisions limiting applicability
to members of an ACH association, and provisions requiring dues or fees.

## What the free sources say

| Source | What it is | Limit | Window | Clock starts at |
|---|---|---|---|---|
| Nacha Operating Rules 2.12.4 | primary, paid | not readable | not readable | not readable |
| Fed Operating Circular 4, eff. 2026-01-05 | primary, free | states nothing | states nothing | states nothing |
| Increase, ACH returns documentation | processor, live implementation | "a maximum of two times" | 180 days | settlement date of the original transfer |
| Crowded | processor | two additional attempts | 180 calendar days | settlement |
| Adyen, ACH chargeback guidelines | processor, live implementation | "up to two times" | **30 days** | **original authorization date** |
| Fiserv, CardPointe BluePay ACH guide | processor, live implementation | "up to two times" | **30 days** | **original authorization date** |
| Stripe, ACH Direct Debit documentation | processor, live implementation | "a maximum of 2 times" | 40 days | original payment attempt |
| Unattributed originator quick-reference card, hosted by a US community bank | secondary, cites the **2017** edition of the rules | "a total of 3 presentments" | 180 days | settlement date of the original entry |
| Widely repeated summary phrasing | secondary | "two re-presentments" | 180 days | original entry date |

All retrieved 2026-08-24. The Fed circular carries an effective date on its own face;
none of the others carry a last-updated stamp, so each stands only on the date it
was read. The quick-reference card is the weakest source in the table and is included
because of what it demonstrates rather than what it asserts: it names no author, and
it cites the 2017 edition of a rulebook that has been revised repeatedly since, while
sitting on a live bank website where an originator would reasonably take it as
current.

## Three of the four disagreements dissolve

**Two reinitiations and three presentments are the same rule.** Increase says a
returned debit may be reinitiated a maximum of two times. The quick-reference card says
the originator may reinitiate "for a total of 3 presentments". Those agree: the original
attempt plus two reinitiations is three presentments. They are counting in different
units and neither says which unit it is using. If you take the larger number from one
source and the unit from the other you will build a schedule with one attempt too
many in it, and nothing in either document will tell you that you have.

**A platform limit is not the network rule.** Stripe's 40 days is Stripe's own cap on
its automatic retry feature. That is a platform policy sitting on top of a network
rule, and the page does not label it as either, so a schedule built to 180 days on
Stripe simply stops retrying at day 41 without anybody having broken a rule. Read
every processor's number as a platform policy until something proves otherwise.

**Only R01 and R09 are re-presentable in the ordinary case.** Every source that
addresses it agrees: insufficient funds and uncollected funds. Two sources add the
same two exceptions, a return for stop payment where the account holder has
authorised the reinitiation, and any return where the originator has remedied the
underlying reason. The word RETRY PYMT goes in the company entry description field,
in upper case, and the reinitiated entry must otherwise carry identical company name,
company identification and amount.

## The one that does not dissolve

The window and the clock, together, and it is not a quibble. Among parties who each
operate a live ACH system and are documenting their own behaviour:

- Increase: two reinitiations, **180 days**, from the **settlement date**
- Crowded: two additional attempts, **180 calendar days**, from **settlement**
- Adyen: "up to two times", **30 days**, from the **original authorization date**
- Fiserv, CardPointe BluePay: "up to two times", **30 days**, from the **original
  authorization date**
- Stripe: "a maximum of 2 times", **40 days**, from the **original payment attempt**

Thirty days against a hundred and eighty is a six-fold spread on the same rule, and
authorisation is not settlement: authorisation happens before the entry is even sent,
settlement one or two banking days after. Two processors sit on each side of it. This
is not a case of summaries garbling a clear rule, because the sources disagreeing here
are the ones with the strongest reason to be right.

Adyen also publishes something the "only R01 and R09" framing does not survive:
**R11, entry not in accordance with the terms of the authorization, is retryable
within 60 days of the original settlement date.** A third window, a third clock, on a
return code most summaries list as not retryable at all.

I cannot settle this for free. The governing sentence is in the paid text. What I can
say is that anybody holding one of these numbers and believing it to be the network
rule is holding one processor's implementation of it, and there are at least three
mutually exclusive candidates.

## If you are building a schedule

Read your processor's stated limit as a platform policy until you have checked
whether it matches the network rule, because at least one major processor's number
is materially stricter and does not say so.

Count in presentments or in reinitiations, decide which, and write it down next to
the number, because the two most careful sources here disagree by exactly one and
only because of that.

If your schedule places an attempt anywhere near day 180, the entry date against
settlement date question decides whether that attempt is inside the network, and no
free source resolves it. Either pull the attempt well inside the window or read
2.12.4.

Beyond 180 days there is no ACH remedy at all. Collection moves outside the network.

## How to reproduce the measurement

Run `./verify.sh`. It resolves the current circular from the Fed's index, downloads
it, extracts it, asserts its controls and prints the counts, and exits non-zero if
any of that fails. The manual version is below.

    # the circular, from the Fed's own index rather than a remembered URL
    curl -sL -A 'Mozilla/5.0' \
      https://www.frbservices.org/resources/rules-regulations/operating-circulars.html \
      | grep -o '[^"]*operating-circular-4[^"]*\.pdf'

    curl -sL -A 'Mozilla/5.0' -o oc4.pdf \
      https://www.frbservices.org/binaries/content/assets/crsocms/resources/rules-regulations/010526-operating-circular-4.pdf

    pdftotext -layout oc4.pdf oc4.txt

    # normalise whitespace first: this PDF wraps, and a two-word phrase
    # split across a line break will not match otherwise
    python3 -c "
    import re,sys
    a=re.sub(r'\s+',' ',open('oc4.txt').read())
    assert 'Automated Clearing House Items' in a, 'control failed, extraction is broken'
    assert 'zzq-not-in-this-document' not in a, 'control failed, matcher is broken'
    for t in ['reinitiat','180 days','Nacha']:
        print(t, len(re.findall(t,a,re.I)))
    "

Run the control assertions. A zero from a broken extraction and a zero from a clean
document are the same number, and only one of them means anything.

## What I did not verify

I have not read Nacha Operating Rules 2.12.4. Every statement above about what that
subsection contains is second-hand, and is presented as what a named source claims
rather than as the rule.

I did not test any of this against a live ACH transfer. The processor documentation
is taken at its word as a description of its own behaviour.

Crowded returned HTTP 403 and the Fiserv developer site rendered no text to a fetch,
so those two rows are recorded from readings taken on 2026-08-12 and 2026-08-22 by
earlier work of mine rather than re-verified today. Adyen I read at source on
2026-08-24. Increase and Stripe likewise.

## Correction, 2026-08-24

The first version of this document, commit `34f47ca`, said that the "30 days from the
authorisation date" variant "is not in any source I could retrieve today, and I am
not repeating it as a finding". **That was false, and it was false in the direction
that made my own piece look tidier.** Adyen and Fiserv both publish it, and Adyen's
page is quoted above from a reading taken at source.

I had searched for it, found nothing, and reported the absence. The search covered
three directories and did not cover the one holding a two-page mapping of this exact
question that had already been exported and sent to somebody. A zero inherits the
boundary of whatever produced it, and the boundary is the part nobody writes down.

The correction makes the finding stronger rather than weaker, which is the usual shape
when a negative turns out to be a gap in the search. The original version had one open
question about a clock. This one has three incompatible windows published by five
parties who each run a live ACH system.

## A wrong turn worth recording

My first measurement returned 225,810 characters of extracted text and zero hits,
and it was on the wrong document. OC 4 was revised effective 2026-01-05; I had the
superseded 2024-10-28 version, and I only noticed because that character count
matched an earlier note exactly, which is not what a fresh reading of a current
document should do. The finding survived on the current version, unchanged.

Then the verification script in this repository made the same mistake, which is the
part worth keeping. It resolved the PDF from the Fed's index and picked the newest
by sorting the filenames in reverse. The Fed names these files with an MMDDYY
prefix, so as text `102824` sorts above `010526` and the script confidently selected
the October 2024 version over the January 2026 one. It printed a clean run with its
controls firing, because the controls were doing their job: the extraction was fine
and the document was real. Nothing in a control can tell you that you are measuring
the right object.

It was caught by the Nacha count, 15 where this document says 13. The number that did
not match was the only thing that surfaced it, twice, on the same error. `verify.sh`
now parses the prefix into a date and cross-checks it against the effective date the
index page states in prose, and refuses to proceed when those disagree.

## Sources

All retrieved 2026-08-24.

- Federal Reserve Operating Circular No. 4, Automated Clearing House Items, effective
  2026-01-05, 71 pages:
  https://www.frbservices.org/binaries/content/assets/crsocms/resources/rules-regulations/010526-operating-circular-4.pdf
- The superseded 2024-10-28 version, 76 pages, which returns the same zeros:
  https://www.frbservices.org/binaries/content/assets/crsocms/resources/rules-regulations/102824-operating-circular-4.pdf
- The Fed's own index of operating circulars, which is where both of the above should
  be found rather than from a remembered URL:
  https://www.frbservices.org/resources/rules-regulations/operating-circulars.html
- Increase, ACH returns documentation:
  https://increase.com/documentation/ach-returns
- Stripe, ACH Direct Debit documentation, "Billing retries":
  https://docs.stripe.com/payments/ach-direct-debit
- Adyen, ACH chargeback guidelines, read at source 2026-08-24:
  https://docs.adyen.com/risk-management/chargeback-guidelines/ach-chargebacks
- Fiserv, CardPointe BluePay ACH guide, read 2026-08-22, not re-reachable 2026-08-24:
  https://developer.fiserv.com/product/CardPointe/docs/documentation/BluePayACHGuide.md
- Crowded, read 2026-08-12, returned HTTP 403 on 2026-08-24:
  https://www.bankingcrowded.com/all-blogs/ach-return-codes-r02-r03-r04-nonprofit-platforms
- Nacha, which sells the Operating Rules:
  https://www.nacha.org/rules
- The unattributed originator quick-reference card, cited for what it demonstrates
  rather than for its authority:
  https://www.bankfivenine.com/wp-content/uploads/2021/09/ach_return_and_noc_reference_guide.pdf

A page with no last-updated stamp stands only on the date it was read. Of the seven
above, only the Fed circulars carry a date on their own face.

---

Retrieved and measured 2026-08-24. Nothing here is legal advice. If a payment
schedule's compliance depends on the clock start, read the paid rulebook.
