# Possible answsers to Frequently Asked Questions

## "It doesn't work"

Sorry to hear that this application doesn't behave as expected.

Let's go through a few steps that may solve the issues you are experiencing.

1. **Uninstall previous versions.**
In order to do so, open the DNSCrypt OSXClient preferences pane, and click the `Uninstall` button in the `About` tab.
2. **Download the latest official version.**
The package can be installed with `brew cask` or downloaded directly from GitHub: [DNSCrypt OSXClient](https://github.com/alterstep/dnscrypt-osxclient/releases/latest).
Do **not** download this app from unauthorized sources such as MacUpdate or a different GitHub repository. The file you would download from an unauthorized source may be delivered insecurely, may be old, or may contain malware.
3. **Optional:** if you want to double check the authenticity of the file you downloaded, also download the `.minisig` file and use [Minisign](https://jedisct1.github.io/minisign/) to verify the digital signature.
4. **Open the OSXClient preference pane**, select a resolver and try enabling DNSCrypt.
5. Still no joy? **Try a different resolver.** Some of them might experience a temporary outage, or may be blocked by your ISP.
6. **Turn off your VPN.** A VPN already encrypts your data, including DNS data.
7. **Disable antiviruses**, local and remote (router) firewalls, Little Snitch, Little Flocker and other agents preventing applications from working normally.
These can be reenabled later, but we need to make sure that their interaction with OSXClient is not the root cause of the problems you are trying to solve.
8. **Activate logging** by creating a file named `debug.enabled` in the `/Library/Application Support/DNSCrypt/control` directory. The content of that file is not important; only its presence will be checked so an empty file is fine.
When this file is present, OSXClient logs its activity in `/var/log/dnscrypt-osxclient-debug.log`. Reviewing the content of that file while trying to turn DNSCrypt on and off may be very useful in order to understand why things don't work as expected.
9. **Update your operating system** if possible. This user interface, as well as the underlying proxy, have been written for the latest stable major version of MacOS. Apple doesn't make it simple to ensure that an application works on a specific OS version without having a dedicated test device, so the developers can only guess what changes may be required to make these applications also run on older systems.
10. **Report resolver-specific issues to the resolver operator**. OSXClient, Simple DNSCrypt, dnscrypt-proxy, dnsdist, dnscrypt-wrapper are pieces of software, not services. None of the authors work at Yandex or OpenDNS, so we can't help you with your Yandex or OpenDNS account, or with issues specific to a resolver such as a name that cannot be resolved. Please report these issues to the companies and individuals running these services instead. These issues have probably nothing to do with the DNSCrypt protocol itself.

After trying all these steps, open a ticket on the [OSXClient issue tracker](https://github.com/alterstep/dnscrypt-osxclient/issues).

Here are a few hints to maximize the chances for your issue to be addressed as quickly as possible:

1. **Do not post screenshots** unless the bug is specifically about a graphic element of the user interface. Screenshots are not indexed by search engines (not great to helper other users with similar issues), can be hard to read, can be incomplete, don't allow copy/paste, don't play well with command-line tools developers use, and finding what to look for in a screenshot is now always intuitive. Instead, copy/paste relevant information. If that information is short, include it in the description of the issue. If that information is 15 lines or more, save it to a file, and attach the file to the ticket. Or use a GitHub [gist](https://gist.github.com/) or [zerobin](https://zerobin.net/). Short and clear descriptions are always appreciated.
2. **Make sure that you went through the steps above** before filing an issue.
3. **Include some information**: the OSX version you are running, the OSXClient version you installed, and a snippet of the `dnscrypt-osxclient-debug.log` file (not inline, see above). Details such as the model of your computer and the brand of your router are not required.
4. **Summarize your problem**: what you did, what should have happened, and what actually happened. Bugs can be fixed very quickly if the developer can duplicate your problem. But they are very unlikely to be fixed if the developper struggles at understanding why something happens on your machine and not elsewhere. Use a short and meaningful summary as the title of your ticket: this will be immensely useful to other users that look for a solution to the same problem.
5. **Do not write "doesn't work"**: explain exactly what doesn't behave as expected. See the previous point.
6. **Do not hide information**: if you are running an old MacOS version, if didn't try without your antivirus, if you are blocking specific ports and protocols, if you altered the software, if you customized your environment in some way, please mention it.
7. **Share your solution**: did you eventually manage to fix the issue? Fantastic! Before closing the ticket, writing a short description of what you did will be very appreciated by other users!

If the command-line doesn't scare you, you may consider running [dnscrypt-proxy](https://github.com/jedisct1/dnscrypt-proxy/wiki) directly instead of OSXClient.
