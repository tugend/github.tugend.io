---
title: "Autumn Code Challenge (Prompt)"
category: challenges
tags: creativity typescript deno web
published: true
---

## Write an personal economy app

Using ideomatic [Deno](https://deno.com/) write an economy app that makes it easy to categorize and summary months of personal transaction data.

## Break down

- [x] Publish this challenge.  
- [x] Install Deno.  
- [ ] Fetch x months of transaction data manually and store them locally.  
- [ ] Implement.  
  - [ ] Automatically parse all transactions and store them idempotently wrt.  content and timeframe.
  - [ ] Apply a rename scheme to add a secondary title e.g. '*12 Lunar 123213213*' -> '*Lunar*'.  
  - [ ] Apply a default categorization to all transactions.  
  - [ ] Present all transactions and their categorization.  
  - [ ] Support persistent category overrides per transaction.
  - [ ] Summarize the categorized transactions in a graphical overview.
- [ ] Publish a conclusion to the challenge.