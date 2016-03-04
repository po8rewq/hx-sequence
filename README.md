## What is hx-sequence ?

**hx-sequence** is a toolkit that helps you automate tasks in your **Haxe** development workflow. It's written in Haxe, so no need to install another environment.

 * **Automation**: If your are using haxe for web development, you would probably like to compile both client, server and copy files to a specific location, ...
 * **Simple**: Everything is defined in a json file.

## Install

```batch
haxelib install hx-sequence
haxelib run hx-sequence [config.json]
```

## Use cases

### Project structure
```json
{
  "project": {
    "name": "myProject",
    "version": "0.0.1"
  }
}
```

### Define variables
```json
"define": [
  {
    "name": "src",
    "value": "/workspace/myProject"
  }, {
    "name": "bin",
    "value": "${src}/bin"
  }
]
```

Your *bin* variable will now be */workspace/myProject/bin*.

### Targets

 > Only works with hxml files for now

```json
"targets": [ {
    "hxml": "client.hxml"
  }, {
    "hxml": "server.hxml"
  }
]
```

If you want to add conditional arguments, you can do :

```json
"targets": [ {
    "hxml": "client.hxml",
    "cond": {
      "prod": {
        "flags": ["--no-traces", "-D", "prod"]
      },
      "debug": {
        "flags": ["-debug"]
      }
    }
  }
]
```

So If you run `hx-sequence` with the `-D prod` argument, it will use the `cond.prod.flags` while compiling.

 > For now, there is only to compiling status :
 >  * prod
 >  * default (no `-D` flag)

### Tasks

Tasks are additional component. For example, you have a **Copy** task that can copy an element from a directory to another, or an **Execute** one that can execute any external application.

```json
"tasks": [
    {
      "plugin": "Copy",
      "params": [ "${src}www\\js\\config.js", "${dest}js\\config.js" ]
    },
    {
      "plugin": "Execute",
      "params": ["uglifyjs", ["${dest}js\\client.js", "-o", "${dest}js\\client.js"]]
    },
    {
      "plugin": "Execute",
      "params": ["minify", ["${src}www\\css\\custom.css", "-o", "${dest}css\\custom.css"]]
    }
]
```

If you want to trigger some tasks only during `-D prod` compilation, you can add the `only` property to your task :

```json
{
  "plugin": "Copy",
  "params": ["in.txt", "out.txt"],
  "only": "prod"
}
```

In the other way, the property `except` is also available which let you ignore a task based on an argument :

```json
{
  "plugin": "Copy",
  "params": ["in.txt", "out.txt"],
  "except": "prod"
}
```

#### Implemented tasks

 * **Copy** : copy a file to a location
 * **Execute** : execute an external command
 * **TemploBuilder** (extends **Execute**) : Clean the output directory before running the command

#### Custom tasks

All tasks must extends `ITask` and be imported in the `Flow` class (so it can be called).

## Limitations

If you need to use a **nodejs** package on Windows, you need to call the exec with its complete path (*${node_path}uglifyjs.cmd* where ${node_path} is your **nodejs** directory).
