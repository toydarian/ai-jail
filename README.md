# 🔒 AppArmor Profile for AI Coding Agents

> *"Trust, but verify. And by verify, I mean lock that AI in a cozy security sandbox."*

## What is this?

An AppArmor profile that keeps your AI coding agent on a tight leash while it helps you write code. Think of it as a responsible parent: supportive, but not letting the kid drive the car or access the liquor cabinet.

 - Currently, this supports opencode, but it should work with any other agent with only a few tweaks. If you want to add support for other agents, I'll be happy to review your pull-request.
 - I make no claim that this is exhaustive in blocking everything it should. If you want to add something, again, I'm happy to receive a pull-request.

## The Problem

You want an AI agent to help with your work, but you're (rightfully) paranoid about giving an AI access to:
- Your SSH keys 🔑
- Root privileges 👑
- Your shell history (no one needs to see those typos) 📜
- The ability to `sudo rm -rf /` your life away 💀

## The Solution

This AppArmor profile creates a security sandbox that:
- ✅ **Allows**: Editing files in your repos directory
- ✅ **Allows**: Network access (because how else will it talk to the LLM?)
- ✅ **Allows**: Using binaries in `/bin/` without beaking out of jail
- ❌ **Blocks**: All privilege escalation (no `sudo`, no `su`, nada)
- ❌ **Blocks**: SSH keys, AWS credentials, GPG keys
- ❌ **Blocks**: Shell configs and history files
- ❌ **Blocks**: Pretty much everything else

## Installation

### Quick Install

You will need root-privileges, as well as AppArmor working on your system.

On the first install, run 
```bash
sudo cp local/ai-agent /etc/apparmor.d/local/ai-agent
mkdir -p ~/.local/state/opencode ~/.local/share/{opencode,opentui} ~/.config/opencode ~/.bun
```

Open the file `/etc/apparmor.d/local/ai-agent` in your preferred text-editor (with root privileges) and modify it as described in the comments.  
Then proceed with the steps in the next section.

### Update

Use the provided install script:
```bash
sudo ./reload.sh
```

The script will:
- Backup any existing profile to `/var/backups/apparmor/` (with timestamp)
- Install the new profile to `/etc/apparmor.d/ai-agent`
- Reload AppArmor with the updated profile

### Tweaking

The profile will load `/etc/apparmor.d/local/ai-agent`. There is an example that you can copy in the `local/` directory in this repository which you should have copied and modified during your first install.  
You can make any changes you like in this file, your sensitive files (like `~/.ssh`) will still be denied. The `reload.sh` script will not overwrite the included file.  
Don't forget to run `sudo apparmor_parser -r /etc/apparmor.d/ai-agent` to apply any changes you make there.

## Usage

Just run your AI agent as usual. AppArmor will enforce the rules defined in the profile and log anything it denied that is not explicitely marked with `deny` in the profile. When your agent tries to access or do something that it is not supposed to, it will get a `Permission denied`.  
It will probably ask you to fix the permissions, because most LLMs don't know about AppArmor.

## Testing

Want to make sure it's working? Try asking your AI-Agent to list your ssh- or gpg-keys or show you your bash history.

## FAQ

**Q: My agent needs access to something that's blocked. Is the profile broken?**  
A: Probably not! Check the logs, understand what's being denied, and consciously decide if you want to allow it. Security is about informed decisions, not blind trust.

**Q: Is this overkill?**  
A: Maybe. But "overkill" is just "properly paranoid" with better PR.

**Q: What if I want my agent to use SSH?**
A: You can set up keys and everything else in a separate directory and whitelist it. If you want your agent to have access to your production-systems on the other hand, this profile is not for you.

## Contributing

Found a security hole? Have suggestions? Want to support another agent? PRs welcome! Just remember:
- Keep it secure by default
- Document your changes
- Test before submitting
- No, we won't add a "trust me bro" mode - if you want one, just disable the profile

