# tcmalloc-delphi
A Delphi wrapper around the TCMalloc memory manager from gperftools

The DLLs are compiled from the [gperftools](https://github.com/gperftools/gperftools) project, in minimal mode but without any dependency on the MSVC runtime

To use, simply add the `tcmalloc.pas` file as the first unit in your project `uses` section and place the appropriate DLL next to the exe.

The DLL files retain the original license from gpertools while the `tcmalloc.pas` file is released under MPL2.0 license.
