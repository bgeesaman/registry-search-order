# Container Registry Search Order and "Org Squatting"

## Why am I here?

If you ran a container that displayed the following:

```console
 _   _  ___  _   _ _   ___ _
| | | |/ _ \| \ | | | / / | |
| |_| | | | |  \| | |/ /| | |
|  _  | | | |     |   < |_|_|
| | | | |_| | |\  | |\ \ _ _
|_| |_|\___/|_| \_|_| \_(_|_)

Not the container image you were expecting?
Relax, you have only been h0nX0r3d, not hacked.
For more information on why you are seeing this:
https://github.com/bgeesaman/registry-search-order
```

and you followed that link here, you might be wondering how and why that happened.

First things first: __you have not been hacked, but you came very close__.  Your system either directly or indirectly ran this container, but I assure you, it's a benign image and only prints the message above.

## What Happened?

One of a few things:

1. You searched an image on `docker.io` or `quay.io` that _looked_ official but wasn't and used it.

2. You run RHEL/Centos/Fedora or a system with Podman installed that enables a "registry search order" capability, and you specified a shortened path like `repo/image:tag` .  Your configuration then landed on this image _first_ instead of the desired image in a registry later in your search order.  The `containers-common` package on your system installed a file named `/etc/containers/registries.conf` which specified a configuration with something like:

   ```toml
   # Libpod/Podman/Fedora
   [registries.search]
   registries = ['docker.io', 'registry.fedoraproject.org', 'quay.io', 'registry.access.redhat.com', 'registry.centos.org']
   ```
   
   ```toml
   # Centos 7
   [registries.search]
   registries = ['registry.access.redhat.com', 'docker.io', 'registry.fedoraproject.org', 'quay.io', 'registry.centos.org']
   ```
   
   ```toml
   # Centos 8/RHEL 8
   [registries.search]
   registries = ['registry.redhat.io', 'quay.io', 'docker.io']
   ```


## Org-Squatting

The registry search order feature is useful, but a horrible goose might prevent you from having a beautiful day in the village if they decide to "squat" on your organization name in another registry and "mirror" images of identical names and tags to run an image of their choosing and not the one you were expecting.

__And that's how you might accidentally fall into this form of watering-hole attack and have untrusted code run on your machine or inside your cluster__.

Oops.  Not good.

After some inspiration from [@raesene](https://twitter.com/raesene) [here](https://raesene.github.io/blog/2019/09/25/typosquatting-in-a-multi-registry-world/), I decided to see how practical this form of attack would be and to use this mechanism to raise awareness of [the issue](https://lists.podman.io/archives/list/security@lists.podman.io/thread/BX4PIHHVHGDDLYLX53WUBVLFM3YRVXKM/).  This took the form of:

1. Registering identically named organizations on `quay.io` that were available for common/popular organizations on `docker.io/DockerHub` in case `quay.io` comes first in your search order.
2. Registering identically named organizations that live on `registry.redhat.io/registry.access.redhat.com` on  `docker.io/DockerHub` in case `docker.io` comes first.
3. Creating a benign image with the sole purpose of raising awareness by having it link to an informative repository `README`.
4. Finally, the benign image was mirrored to all the squatted orgs with identical names and tags of the images from their official locations.

Hence the [horrible goose reference](https://goose.game/): _HONK HONK HONK_ 

Note: Neither House House nor Panic are in any way affiliated with this project, nor do they endorse it.

## What Can I Do to Prevent This From Happening Again?

A few things:

1. If you hold an organization in `docker.io` but not in `quay.io` or vice versa, go ahead and register it with a reference back to your official registry location.
2. If your organization name embeds a version number in it like `org3`, be sure to register `org4-org100` in both `docker.io` and `quay.io` to prevent user confusion and trust issues.
3. Configure your `/etc/containers/registries.conf` `registries.search` list to place your trusted registries first and consider removing all public registries from this list.
4. Use the fully-qualified image path when referencing images to run on the command line or in kubernetes pod specs to always ensure you pull from the correct registry.  e.g. `docker.io/myorg/myimage:mytag` instead of `myorg/myimage:mytag` 
5. Instead of referencing a tag like `mytag`, consider using the digest format: `quay.io/myorg/myimage@sha256:9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08` as it prevents both org-squatting and registry compromise situations.
6. Cryptographically sign all container images as they are built and validate the signature before running by configuring [containers-policy.json](https://src.fedoraproject.org/rpms/skopeo/blob/master/f/containers-policy.json.5.md).  If using Kubernetes, run an [admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) or similar to ensure only images being run come from approved registries and/or have a trusted signature.
7. Optionally, submit bugs/feedback to your upstream distribution and politely ask them to adjust the search order.
8. If your organization was already squatted on, contact the registry provider for guidance.  If you are the owner of one of the organizations where this image is currently being mirrored, open an issue in this repo and I will gladly "toss it back".

## Resources

1. [Untitled Goose Game](https://goose.game/)
1. [Registries.conf](https://src.fedoraproject.org/rpms/skopeo/blob/master/f/registries.conf)
1. [Containers-common RPM](https://rpmfind.net/linux/rpm2html/search.php?query=containers-common)
1. [@Raesene's Blog - Typosquatting in a Multi-Registry World](https://raesene.github.io/blog/2019/09/25/typosquatting-in-a-multi-registry-world/)
1. [Reported Issue to Red Hat](https://lists.podman.io/archives/list/security@lists.podman.io/thread/BX4PIHHVHGDDLYLX53WUBVLFM3YRVXKM/)
1. https://access.redhat.com/articles/3116561 and https://bugzilla.redhat.com/show_bug.cgi?id=1700140
1. [Kubernetes Dynamic Admission Control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)
