# Sarracenia v3 Data Pump/Cluster Tools (sr3_tools)

*sr3_tools* are a collection of scripts used to manage data pumps (clusters) running Sarracenia v3 (sr3).

## Installation/Setup

To install, clone the repository:

```bash
git clone https://github.com/MetPX/sr3_tools.git
```

Then add the `bin` directory to your path. Generally this can be done by adding the following line to `~/.bash_profile` or `~/.bashrc`, where `path_to_repo` is substituted for the location where the repository was cloned to:

```
export PATH=path_to_repo/sr3_tools/bin:$PATH
```

[`dsh`](http://www.netfort.gr.jp/~dancer/software/dsh.html) is also required. On Ubuntu, it can be installed using:

```bash
sudo apt install dsh
```

## Configuration Repository Layout

sr3_tools works in conjuction with a Git repository that contains the Sarracenia configuration files for one or more data pump clusters.

The layout of the repository should be similar to the following:

```
config_repo_root
├── _dsh_config
│   ├── pump1.list
│   └── pump2.list
├── pump1
│   ├── cpost
│   ├── credentials.conf
│   ├── default.conf
│   ├── plugins
│   ├── poll
│   ├── post
│   ├── sarra
│   ├── sender
│   ├── shovel
│   ├── subscribe
│   └── winnow
├── pump2
│   ├── cpost
│   ├── credentials.conf
│   ├── default.conf
│   ├── plugins
│   ├── poll
│   ├── post
│   ├── sarra
│   ├── sender
│   ├── shovel
│   ├── subscribe
│   └── winnow
├── .git
└── .gitignore
```



## Command Descriptions

### `sr3d`

Usage: `sr3d [ -h ] (convert|declare|devsnap|dump|edit|log|restart|sanity|setup|show|status|overview|stop)`

*"sr3 distributed"* runs `sr3` on each node, with all command line arguments passed to `sr3`. 

See [`man sr3`](https://metpx.github.io/sarracenia/Reference/sr3.1.html).

**Examples:**  

- `sr3 start subscribe/my_config`
- `sr3 status poll/my_poll`

<br>

### `sr3_pull`

Does a `git pull` on each node in the cluster to update the local configs.

<br>

### `sr3_push`

Usage: `sr3_push file_name ["Commit message"]`

"Pushes" a config file by 1) commiting the file to Git and 2) running `sr3_pull` to update the configs on each node.

This exists for to provide a familiar workflow for people used to using `sr_push`, but using Git branches, merging and `sr3_pull` is preferred. The Git workflow supports changing multiple files at once.

The commit message is optional. If no message is passed on the command line, an editor will open where you can type the commit message.

**Examples:**

- `sr3_push new_config.conf "AA - description of change"`
- `sr3_push another_config.conf Commit message`
- `sr3_push some_file.conf`

<br>

### `sr3_remove`

Usage: `sr3_remove config_file.conf`

Used to remove a configuration. *The config should be stopped first.* Removes the file from Git, runs `sr3_pull` to update the nodes.

**Example:**

- `sr3_remove my_bad_config.conf`

<br>

### `sr3l`

Usage: `sr3l your_command`

*"sr3 log"* is `sr3r`, with `cd ~/.cache/sr3/log` before your command. Used for searching through logs on all nodes, typically in combination with `grep` or `tail`.

Try to be as specific as possible when grepping, e.g. search within `sender*my_config*.log` rather than `sender*.log`.

**Examples:**

- `sr3l grep looking_for_this_filename sender*my_config*.log`
- `sr3l tail -n 2 sarra*.log`

<br>

### `sr3r`

Usage: `sr3r your_command`

*"sr3 run"* executes a shell command on all nodes in the cluster.

<br>