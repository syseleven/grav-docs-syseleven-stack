---
title: 'Resource Limits'
published: true
date: '03-12-2021 17:25'
taxonomy:
    category:
        - docs
---

## Reasoning behind resource limits

The SysEleven Stack imposes resource limits per region on customer projects. This may sound a little bit bossy, given the fact that our customers have access to plans where they pay on-demand what they use. Couldn't we waive all restrictions and let customers use what they want? For the time being, we decided to stick with quota limits, because they serve for the following purposes:

### Infrastructure protection

Quotas prevent individual customers from depleting all resources and thus prevent the platform from possible damage and ensure that other customers remain able to use their fair share.

### Runaway cost protection

Quotas prevent you from surprising costs caused by runaway automation scripts that accidentally use more resources than actually wanted or needed.

### Capacity management

Quotas greatly ease our capacity management, allowing us to react on customers indicating they would like to use more resources by ordering new hardware and providing them to our customers timely.

### Pushing the limits

If your contract contains ondemand tariffs, you can raise (or lower, or shift between projects and or regions) your quota on short notice by letting us know without any formal requirements, via [e-mail](mailto:support@syseleven.de), [ticket](https://helpdesk.syseleven.de/hc/en-us/requests/new), or telephone during our office hours. We do not charge for the adjustment, nor for the buffer capacity, as long as it is not needed. For a balance between too much unused buffer capacity that would impede our capacity management and frequent adjustments, that would impede your flexibility, we recommend to adjust the limits quarterly to the expected need plus some headroom. Still, should your plans change unexpectedly, you can always have your limits changed on short notice.

### Monitoring usage vs. limits

To avoid running into limits unnoticed and having to debug weird effects like instances and/or worker nodes not being created as expected, we recommend to monitor your usage vs. limits using our [Rest API](../../04.Reference/10.get-quota-info/docs.en.md).

### Quota vs. commitments

Some customers prefer to commit to a certain volume paid upfront, other prefer paying on demand, what they have used. We allow for both options and even to combine them.

  upfront commitment + on demand buffer = quota limit

While quota limits apply per project and region, your upfront commitment can be applied over all regions. This comes in handy, if you have a not fully redundant, but fully automated infrastructure in one of our regions and we announce a maintenance. You can get the same quota limits in another region, build a copy of your infrastructure, switch over and tear down the now unused infrastructure in the old region. While the baseline of you setup is covered by the commitment, you only have to pay the exceeding resources on demand for the short duration where the setup is doubled. The idle buffers do not need to be paid.

### Usage

Any occupied resources are considered "used" and counted against your quota limits. They will also be counted against your upfront commitment or charged on demand.
When you create an instance, volume, snapshot, object, loadbalancer, floating ip, dns zone, resources will be allocated and so they will be counted and charged, no matter if they are actually running, attached, assigned.
To save money or free quota, it is thus not sufficient to stop, detach or unassign them, you must delete them completely to free the resources so that we can reuse them.
It is part of higher level automation like kubernetes or terraform or similar tools to recreate them if needed.

