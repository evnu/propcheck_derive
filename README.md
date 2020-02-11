# PropCheck.Derive

Generating simple PropCheck generators from type definitions.

## TODOs

* [ ] When using this downstream, the application is only started automatically in tests. How can one use
      it outside of tests without `Application.ensure_all_started(:propcheck_derive)`?
* [ ] When a module is redefined, the type server crashes
    * We could delete the known information about the module again
    * We could raise a proper error
* [ ] The semantics for `maybe_improper_list` is unclear. Can we add generators for that type?
* [ ] Opaque types are not handled. Should we create a generator for them?
