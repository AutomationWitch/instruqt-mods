# Satellite Day 2 Overview

## Instruqt Track

Access the lab at [https://www.redhat.com/en/satellite-basics-lab](https://www.redhat.com/en/satellite-basics-lab)

This lab provides :
- A Satellite server with pre-synced content
- 2 RHEL 9 clients

Time limit : 2 hours

## Preparation

Follow these instructions to make the Satellite look like it's Day 2.

Expect around 10min of total prep.

<details open>
        
### Step 1

- Click **Launch** on the bottom right, expect 3min of provisioning.
- Click **Start** on the bottom right when it appears.

### Step 2

- Paste the following command in the **Terminal** tab (you can change the CITY)
```
CITY=Paris bash <(curl -sSL https://raw.githubusercontent.com/AutomationWitch/instruqt-mods/refs/heads/main/satellite/satellite_mod.sh)
```

It's ready !

</details>

## Demo

Now close the instructions pane on the right with the **Hide Instructions** button at the top.

Give a tour of the Satellite

Examples :
- Content promotion
- Remote execution
- System roles configuration with Ansible
- Compliance reports

Wants to show hammer CLI samples ? Show the commands used for this mod [here](https://github.com/AutomationWitch/instruqt-mods/blob/main/satellite/satellite_mod.sh)

Backlog :
- Web Console integration
