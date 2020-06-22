---
title: 'Using local SSD storage'
published: true
date: '2020-06-16 10:11'
taxonomy:
    category:
        - docs
---

## Local SSD storage as an alternative to our default distributed storage

## Objective

This tutorial aims to enable you to make use of the local ssd ephemeral storage provided as an alternative to the default distributed ephemeral storage in SysEleven Stack.

## Prerequisites

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../01.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../02.api-access/docs.en.md).

## How to setup an instance with local ssd storage

There are two ways to achieve this goal and we show both, beginning with the quickest one.

### Use our heat-example for a single server using local ssd as epehemeral storage

You will be working with the [heat examples repository](https://github.com/syseleven/heat-examples) on Github. Your first step is to clone it:

```shell
git clone https://github.com/syseleven/heat-examples
cd heat-examples/single-server-on-local-storage
```

Now you can create the example stack for local ssd storage:

```shell
openstack stack create -t example.yaml local-storage-example-stack -e example-env.yaml --parameter key_name=<ssh key name> --wait
```

In this command, `key_name` references an SSH-Key that you created in the [SSH Tutorial](../../03.Howtos/01.ssh-keys/docs.en.md).

You have now created a very basic server with its ephemeral storage on local ssd.

### Use another tutorial or heat-example

You can use any other tutorial or heat-example and modify it to use local ssd storage instead of distributed storage.
That does not always make sense, since not all workload profit from local ssd storage but it is in principle possible.
Just follow the instructions to the point right before `openstack stack create` gets executed.
Edit the stack file(s) and substitute the `m1.*` flavor with the correspondig `l1.*` flavor.
If you then continue to create the stack, the server(s) will be created using local ssd storage as ephemeral storage.
This does not apply to attached volumes, that will [continue to use distributed storage](../../05.Background/02.local-storage/docs.en.md#can-i-combine-local-ssd-storage-with-distributed-storage).

## Implications

See our [Background article about Local SSD Storage](../../05.Background/02.local-storage/docs.en.md) for more information about the implications of using local ssd storage.

## Summary / Conclusion

You now have created a basic server with local ssd storage and learned, how to modify other tutorials to make use of local ssd storage.
You should now be able to do anything you were able to do with distributed storage, with local storage as well.
