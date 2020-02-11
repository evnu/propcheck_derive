defmodule DeriveForAllOfElixir do
  # Try to derive all types defined in the :elixir application
  #
  # Modules where retrieved like this:
  #
  # iex(12)> filter = fn m -> t = Code.Typespec.fetch_types(m); t != :error && elem(t, 1) != [] end
  # iex(15)> ms = :application.get_key(:elixir, :modules) |> elem(1) |> Enum.map(&to_string/1) |> Enum.join("\n"); File.write!("/tmp/modules_with_types", ms)
  #

  use PropCheck.Derive, module: Access
  use PropCheck.Derive, module: Agent.Server
  # agent/0 and on_start/0 use pid()
  use PropCheck.Derive, module: Agent, exclude: [agent: 0, on_start: 0]
  use PropCheck.Derive, module: Application
  use PropCheck.Derive, module: ArgumentError
  use PropCheck.Derive, module: ArithmeticError
  use PropCheck.Derive, module: Atom
  use PropCheck.Derive, module: BadArityError
  use PropCheck.Derive, module: BadBooleanError
  use PropCheck.Derive, module: BadFunctionError
  use PropCheck.Derive, module: BadMapError
  use PropCheck.Derive, module: BadStructError
  use PropCheck.Derive, module: Base
  use PropCheck.Derive, module: Behaviour
  use PropCheck.Derive, module: Bitwise
  use PropCheck.Derive, module: Calendar.ISO
  use PropCheck.Derive, module: Calendar.TimeZoneDatabase
  use PropCheck.Derive, module: Calendar.UTCOnlyTimeZoneDatabase
  use PropCheck.Derive, module: Calendar
  use PropCheck.Derive, module: CaseClauseError
  use PropCheck.Derive, module: Code.Formatter
  use PropCheck.Derive, module: Code.Identifier
  use PropCheck.Derive, module: Code.LoadError
  use PropCheck.Derive, module: Code.Typespec
  use PropCheck.Derive, module: Code
  use PropCheck.Derive, module: Collectable.BitString
  use PropCheck.Derive, module: Collectable.File.Stream
  use PropCheck.Derive, module: Collectable.HashDict
  use PropCheck.Derive, module: Collectable.HashSet
  use PropCheck.Derive, module: Collectable.IO.Stream
  use PropCheck.Derive, module: Collectable.List
  use PropCheck.Derive, module: Collectable.Map
  use PropCheck.Derive, module: Collectable.MapSet
  use PropCheck.Derive, module: Collectable
  use PropCheck.Derive, module: CompileError
  use PropCheck.Derive, module: CondClauseError
  use PropCheck.Derive, module: Config.Provider
  use PropCheck.Derive, module: Config.Reader
  use PropCheck.Derive, module: Config
  use PropCheck.Derive, module: Date.Range
  use PropCheck.Derive, module: Date
  use PropCheck.Derive, module: DateTime
  use PropCheck.Derive, module: Dict
  use PropCheck.Derive, module: DynamicSupervisor, exclude: [on_start_child: 0]
  use PropCheck.Derive, module: Enum.EmptyError
  use PropCheck.Derive, module: Enum.OutOfBoundsError
  use PropCheck.Derive, module: Enum
  use PropCheck.Derive, module: Enumerable.Date.Range
  use PropCheck.Derive, module: Enumerable.File.Stream
  use PropCheck.Derive, module: Enumerable.Function
  use PropCheck.Derive, module: Enumerable.GenEvent.Stream
  use PropCheck.Derive, module: Enumerable.HashDict
  use PropCheck.Derive, module: Enumerable.HashSet
  use PropCheck.Derive, module: Enumerable.IO.Stream
  use PropCheck.Derive, module: Enumerable.List
  use PropCheck.Derive, module: Enumerable.Map
  use PropCheck.Derive, module: Enumerable.MapSet
  use PropCheck.Derive, module: Enumerable.Range
  use PropCheck.Derive, module: Enumerable.Stream
  # cycle: continuation -> result -> continuation
  use PropCheck.Derive, module: Enumerable, exclude: [continuation: 0, result: 0]
  use PropCheck.Derive, module: ErlangError
  # non_error_kind/0 uses pid()
  use PropCheck.Derive, module: Exception, exclude: [non_error_kind: 0, kind: 0]
  use PropCheck.Derive, module: File.CopyError
  use PropCheck.Derive, module: File.Error
  use PropCheck.Derive, module: File.LinkError
  use PropCheck.Derive, module: File.RenameError
  use PropCheck.Derive, module: File.Stat
  use PropCheck.Derive, module: File.Stream
  use PropCheck.Derive, module: File
  use PropCheck.Derive, module: Float
  use PropCheck.Derive, module: Function
  use PropCheck.Derive, module: FunctionClauseError
  use PropCheck.Derive, module: GenEvent.Stream
  # manager/0 and on_start/0 use pid()
  use PropCheck.Derive, module: GenEvent, exclude: [manager: 0, on_start: 0]
  # on_start/0, from/0 and server/0 use pid()
  use PropCheck.Derive, module: GenServer, exclude: [from: 0, server: 0, on_start: 0]
  use PropCheck.Derive, module: HashDict
  use PropCheck.Derive, module: HashSet
  use PropCheck.Derive, module: IO.ANSI.Docs
  use PropCheck.Derive, module: IO.ANSI.Sequence
  # ansilist/0 uses maybe_improper_list/2
  use PropCheck.Derive, module: IO.ANSI, exclude: [ansilist: 0, ansidata: 0]
  use PropCheck.Derive, module: IO.Stream
  use PropCheck.Derive, module: IO.StreamError
  # chardata/0 uses maybe_improper_list/2, device/0 uses pid()
  use PropCheck.Derive, module: IO, exclude: [chardata: 0, device: 0]
  # cycle: doc_string/0 - t/0 - doc_string/0; the other types depend on that cycle
  use PropCheck.Derive, module: Inspect.Algebra, include: []
  use PropCheck.Derive, module: Inspect.Any
  use PropCheck.Derive, module: Inspect.Atom
  use PropCheck.Derive, module: Inspect.BitString
  use PropCheck.Derive, module: Inspect.Date.Range
  use PropCheck.Derive, module: Inspect.Date
  use PropCheck.Derive, module: Inspect.DateTime
  use PropCheck.Derive, module: Inspect.Error
  use PropCheck.Derive, module: Inspect.Float
  use PropCheck.Derive, module: Inspect.Function
  use PropCheck.Derive, module: Inspect.HashDict
  use PropCheck.Derive, module: Inspect.HashSet
  use PropCheck.Derive, module: Inspect.Integer
  use PropCheck.Derive, module: Inspect.List
  use PropCheck.Derive, module: Inspect.Map
  use PropCheck.Derive, module: Inspect.MapSet
  use PropCheck.Derive, module: Inspect.NaiveDateTime
  use PropCheck.Derive, module: Inspect.Opts
  use PropCheck.Derive, module: Inspect.PID
  use PropCheck.Derive, module: Inspect.Port
  use PropCheck.Derive, module: Inspect.Range
  use PropCheck.Derive, module: Inspect.Reference
  use PropCheck.Derive, module: Inspect.Regex
  use PropCheck.Derive, module: Inspect.Stream
  use PropCheck.Derive, module: Inspect.Time
  use PropCheck.Derive, module: Inspect.Tuple
  use PropCheck.Derive, module: Inspect.Version.Requirement
  use PropCheck.Derive, module: Inspect.Version
  use PropCheck.Derive, module: Inspect
  use PropCheck.Derive, module: Integer
  use PropCheck.Derive, module: Kernel.CLI
  use PropCheck.Derive, module: Kernel.ErrorHandler
  use PropCheck.Derive, module: Kernel.LexicalTracker
  use PropCheck.Derive, module: Kernel.ParallelCompiler
  use PropCheck.Derive, module: Kernel.ParallelRequire
  use PropCheck.Derive, module: Kernel.SpecialForms
  use PropCheck.Derive, module: Kernel.Typespec
  use PropCheck.Derive, module: Kernel.Utils
  use PropCheck.Derive, module: Kernel
  use PropCheck.Derive, module: KeyError
  use PropCheck.Derive, module: Keyword
  use PropCheck.Derive, module: List.Chars.Atom
  use PropCheck.Derive, module: List.Chars.BitString
  use PropCheck.Derive, module: List.Chars.Float
  use PropCheck.Derive, module: List.Chars.Integer
  use PropCheck.Derive, module: List.Chars.List
  use PropCheck.Derive, module: List.Chars
  use PropCheck.Derive, module: List
  # lexical_tracker/0 uses pid(); t/0 depends on lexical_tracker/0
  use PropCheck.Derive, module: Macro.Env, exclude: [lexical_tracker: 0, t: 0]
  # cycle: t/0 -> expr/0 -> expr/0
  use PropCheck.Derive, module: Macro, include: []
  use PropCheck.Derive, module: Map
  # t/0 is opaque, which is not handled right now
  use PropCheck.Derive, module: MapSet, include: []
  use PropCheck.Derive, module: MatchError
  use PropCheck.Derive, module: Module.LocalsTracker
  use PropCheck.Derive, module: Module
  use PropCheck.Derive, module: NaiveDateTime
  use PropCheck.Derive, module: Node
  use PropCheck.Derive, module: OptionParser.ParseError
  use PropCheck.Derive, module: OptionParser
  use PropCheck.Derive, module: Path.Wildcard
  use PropCheck.Derive, module: Path
  use PropCheck.Derive, module: Port
  # dest/0 uses pid()
  use PropCheck.Derive, module: Process, exclude: [dest: 0]
  use PropCheck.Derive, module: Protocol.UndefinedError
  use PropCheck.Derive, module: Protocol
  use PropCheck.Derive, module: Range
  use PropCheck.Derive, module: Record.Extractor
  use PropCheck.Derive, module: Record
  use PropCheck.Derive, module: Regex.CompileError
  use PropCheck.Derive, module: Regex
  use PropCheck.Derive, module: Registry.Partition
  use PropCheck.Derive, module: Registry.Supervisor
  use PropCheck.Derive, module: Registry
  use PropCheck.Derive, module: RuntimeError
  use PropCheck.Derive, module: Set
  use PropCheck.Derive, module: Stream.Reducers
  use PropCheck.Derive, module: Stream
  use PropCheck.Derive, module: String.Break
  use PropCheck.Derive, module: String.Casing
  use PropCheck.Derive, module: String.Chars.Atom
  use PropCheck.Derive, module: String.Chars.BitString
  use PropCheck.Derive, module: String.Chars.Date
  use PropCheck.Derive, module: String.Chars.DateTime
  use PropCheck.Derive, module: String.Chars.Float
  use PropCheck.Derive, module: String.Chars.Integer
  use PropCheck.Derive, module: String.Chars.List
  use PropCheck.Derive, module: String.Chars.NaiveDateTime
  use PropCheck.Derive, module: String.Chars.Time
  use PropCheck.Derive, module: String.Chars.URI
  use PropCheck.Derive, module: String.Chars.Version.Requirement
  use PropCheck.Derive, module: String.Chars.Version
  use PropCheck.Derive, module: String.Chars
  use PropCheck.Derive, module: String.Tokenizer
  use PropCheck.Derive, module: String.Unicode
  use PropCheck.Derive, module: String
  use PropCheck.Derive, module: StringIO
  use PropCheck.Derive, module: Supervisor.Default
  use PropCheck.Derive, module: Supervisor.Spec
  # The types only make sense with pid()
  use PropCheck.Derive, module: Supervisor, include: []
  use PropCheck.Derive, module: SyntaxError
  use PropCheck.Derive, module: System
  use PropCheck.Derive, module: SystemLimitError
  use PropCheck.Derive, module: Task.Supervised
  use PropCheck.Derive, module: Task.Supervisor
  # t/0 uses pid()
  use PropCheck.Derive, module: Task, exclude: [t: 0]
  use PropCheck.Derive, module: Time
  use PropCheck.Derive, module: TokenMissingError
  use PropCheck.Derive, module: TryClauseError
  use PropCheck.Derive, module: Tuple
  use PropCheck.Derive, module: URI
  use PropCheck.Derive, module: UndefinedFunctionError
  use PropCheck.Derive, module: UnicodeConversionError
  use PropCheck.Derive, module: Version.InvalidRequirementError
  use PropCheck.Derive, module: Version.InvalidVersionError
  use PropCheck.Derive, module: Version.Parser
  use PropCheck.Derive, module: Version.Requirement
  use PropCheck.Derive, module: Version
  use PropCheck.Derive, module: WithClauseError
  use PropCheck.Derive, module: :elixir
  use PropCheck.Derive, module: :elixir_aliases
  use PropCheck.Derive, module: :elixir_bitstring
  use PropCheck.Derive, module: :elixir_bootstrap
  use PropCheck.Derive, module: :elixir_clauses
  use PropCheck.Derive, module: :elixir_code_server
  use PropCheck.Derive, module: :elixir_compiler
  use PropCheck.Derive, module: :elixir_config
  use PropCheck.Derive, module: :elixir_def
  use PropCheck.Derive, module: :elixir_dispatch
  use PropCheck.Derive, module: :elixir_env
  use PropCheck.Derive, module: :elixir_erl
  use PropCheck.Derive, module: :elixir_erl_clauses
  use PropCheck.Derive, module: :elixir_erl_compiler
  use PropCheck.Derive, module: :elixir_erl_for
  use PropCheck.Derive, module: :elixir_erl_pass
  use PropCheck.Derive, module: :elixir_erl_try
  use PropCheck.Derive, module: :elixir_erl_var
  use PropCheck.Derive, module: :elixir_errors
  use PropCheck.Derive, module: :elixir_expand
  use PropCheck.Derive, module: :elixir_fn
  use PropCheck.Derive, module: :elixir_import
  use PropCheck.Derive, module: :elixir_interpolation
  use PropCheck.Derive, module: :elixir_lexical
  use PropCheck.Derive, module: :elixir_locals
  use PropCheck.Derive, module: :elixir_map
  use PropCheck.Derive, module: :elixir_module
  use PropCheck.Derive, module: :elixir_overridable
  # No idea how to handle this type: @typep yecc_ret() :: {:error, _} | {:ok, _}
  use PropCheck.Derive, module: :elixir_parser, include: []
  use PropCheck.Derive, module: :elixir_quote
  use PropCheck.Derive, module: :elixir_rewrite
  use PropCheck.Derive, module: :elixir_sup
  use PropCheck.Derive, module: :elixir_tokenizer
  use PropCheck.Derive, module: :elixir_utils
end
