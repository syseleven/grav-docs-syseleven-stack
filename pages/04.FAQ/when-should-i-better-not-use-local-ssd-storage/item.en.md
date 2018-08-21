---
title: 'When should I better not use local SSD storage?'
published: true
date: '08-08-2018 12:16'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - localstorage
        - SSD
---

Traditional single server setups often suffer from performance penalty when run on distributed storage. While it may be tempting to build them on local storage to gain speed, we discourage to use is this way because of the lower redundancy and availability. To put it into simple words, you put your service and your data at risk, when running a single server setup on local storage.