---
title: 'Timezone/NTP '
published: true
date: '08-08-2018 11:31'
taxonomy:
    category:
        - docs
---

## Overview

The configured time zone in SysEleven Stack is UTC (Coordinated Universal Time).
Please be aware that the time shown in your instance logs may differ from the log entries in the OpenStack (GUI/CLI) log.

## NTP Server

SysEleven does **not** provide time servers for you to use. Please select public time servers in your instances.

The following list could be a starting point:

* <https://www.pool.ntp.org/en/use.html>
