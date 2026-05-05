# RamkaX

```
RamkaX is a framework based on Knit by Sleitnick.

The example source code has been built with Rojo.

Documentation can be found inside source code examples.
```

RamkaX is the successor to Ramka. Providing proper typechecking, simplified source code, and a great foundation to start a new project.

RamkaX comes with a ```Library``` folder and a ```Resources``` folder.
* Library is used as a Shared storage for ModuleScripts.
* Resources is required by RamkaX but is open to access for normal development.

Couple things of note:

* RamkaX Tasks can require each other and not cause registering order issues, but RamkaX does not prevent cyclic require paths
* RamkaX has similar intellisense shortcomings as Knit because it is based Knit's code structure